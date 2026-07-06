// Id: 25482
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=64369&p=114750#p114750
//+------------------------------------------------------------------+
//|                 MTF_MCP_3_Level_Semafor_Dashboard_Alerts.mq4.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property indicator_separate_window

extern string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M5               = true;
extern bool     Include_M15              = true;
extern bool     Include_M30              = true;
extern bool     Include_H1               = true;
extern bool     Include_H4               = true;
extern bool     Include_D1               = true;
extern bool     Include_W1               = true;
extern bool     Include_MN1              = true;
extern color    Labels_Color             = clrWhite;
extern color    Up_Color                 = clrLime;
extern color    Dn_Color                 = clrRed;
extern color    Neutral_Color            = clrDarkGray;
extern int      Update_History_Every_Seconds   = 7;
//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = true; // Popup message
extern bool     notification_alert       = false; // Push notification
extern bool     email_alert              = false; // Email
extern bool     play_sound               = false; // Play sound on alert
extern string   sound_file               = ""; // Sound file
extern bool     start_program            = false; // Start external program
extern string   program_path             = ""; // Path to the external program executable
extern bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
extern string   advanced_key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, symbol, timeframe);
   }
};

int      i;
string   WindowName;
int      WindowNumber;

string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols

// Optimization
datetime Last_History_Process;

datetime LastAlert;
Signaler* signaler;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}


int init()
{
   WindowName = "MTF_MCP_3_Level_Semafor_Dashboard_Alerts";
   IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   double temp = iCustom(NULL, 0, "Semaphor_3Level_ZZ", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Semaphor_3Level_ZZ' indicator");
      return INIT_FAILED;
   }

   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);

   return(0);
}

int deinit()
{
   delete signaler;
   signaler = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   WindowNumber = WindowFind(WindowName);
   
   int Pair_y = 50;
   int TF_x   =  1000;
   int Original_x = TF_x;
   
   if (Include_M5){
      int M5_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M5_Label", M5_x, 20, "M5", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M15){
      int M15_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M15_Label", M15_x, 20, "M15", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M30){
      int M30_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M30_Label", M30_x, 20, "M30", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H1){
      int H1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H1_Label", H1_x, 20, "H1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H4){
      int H4_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H4_Label", H4_x, 20, "H4", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_D1){
      int D1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("D1_Label", D1_x, 20, "D1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_W1){
      int W1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("W1_Label", W1_x, 20, "W1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   double divisor;
      
   string arrow;
   color  diff_color;
   
   double up, down;
   
   // For optimization, just check every certain seconds
   if ( TimeCurrent()-Last_History_Process > Update_History_Every_Seconds ){
   
   string Alerts = "";
   
   for (i=0; i < Sym_count; i++) {
   
      if (MarketInfo(Sym_arr[i],MODE_DIGITS)==3||MarketInfo(Sym_arr[i],MODE_DIGITS)==5)
         divisor = 10;
      else
         divisor = 1;
      
      ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+80, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
      if (Include_M5){
         up   = iCustom(Sym_arr[i],PERIOD_M5,"Semaphor_3Level_ZZ",4,0);
         down = iCustom(Sym_arr[i],PERIOD_M5,"Semaphor_3Level_ZZ",5,0);
         if (up > 0.0){
            diff_color = Up_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (M5) Up 3 Semafor\n";
         }else if (down > 0.0){
            diff_color = Dn_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (M5) Down 3 Semafor\n";
         }else{
            diff_color = Neutral_Color;
            arrow = "§";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x-0, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_M15){
         up   = iCustom(Sym_arr[i],PERIOD_M15,"Semaphor_3Level_ZZ",4,0);
         down = iCustom(Sym_arr[i],PERIOD_M15,"Semaphor_3Level_ZZ",5,0);
         if (up > 0.0){
            diff_color = Up_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (M15) Up 3 Semafor\n";
         }else if (down > 0.0){
            diff_color = Dn_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (M15) Down 3 Semafor\n";
         }else{
            diff_color = Neutral_Color;
            arrow = "§";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x-0, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_M30){
         up   = iCustom(Sym_arr[i],PERIOD_M30,"Semaphor_3Level_ZZ",4,0);
         down = iCustom(Sym_arr[i],PERIOD_M30,"Semaphor_3Level_ZZ",5,0);
         if (up > 0.0){
            diff_color = Up_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (M30) Up 3 Semafor\n";
         }else if (down > 0.0){
            diff_color = Dn_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (M30) Down 3 Semafor\n";
         }else{
            diff_color = Neutral_Color;
            arrow = "§";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x-0, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_H1){
         up   = iCustom(Sym_arr[i],PERIOD_H1,"Semaphor_3Level_ZZ",4,0);
         down = iCustom(Sym_arr[i],PERIOD_H1,"Semaphor_3Level_ZZ",5,0);
         if (up > 0.0){
            diff_color = Up_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (H1) Up 3 Semafor\n";
         }else if (down > 0.0){
            diff_color = Dn_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (H1) Down 3 Semafor\n";
         }else{
            diff_color = Neutral_Color;
            arrow = "§";
         }
         ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x-0, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_H4){
         up   = iCustom(Sym_arr[i],PERIOD_H4,"Semaphor_3Level_ZZ",4,0);
         down = iCustom(Sym_arr[i],PERIOD_H4,"Semaphor_3Level_ZZ",5,0);
         if (up > 0.0){
            diff_color = Up_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (H4) Up 3 Semafor\n";
         }else if (down > 0.0){
            diff_color = Dn_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (H4) Down 3 Semafor\n";
         }else{
            diff_color = Neutral_Color;
            arrow = "§";
         }
         ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x-0, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_D1){
         up   = iCustom(Sym_arr[i],PERIOD_D1,"Semaphor_3Level_ZZ",4,0);
         down = iCustom(Sym_arr[i],PERIOD_D1,"Semaphor_3Level_ZZ",5,0);
         if (up > 0.0){
            diff_color = Up_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (D1) Up 3 Semafor\n";
         }else if (down > 0.0){
            diff_color = Dn_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (D1) Down 3 Semafor\n";
         }else{
            diff_color = Neutral_Color;
            arrow = "§";
         }
         ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x-0, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_W1){
         up   = iCustom(Sym_arr[i],PERIOD_W1,"Semaphor_3Level_ZZ",4,0);
         down = iCustom(Sym_arr[i],PERIOD_W1,"Semaphor_3Level_ZZ",5,0);
         if (up > 0.0){
            diff_color = Up_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (W1) Up 3 Semafor\n";
         }else if (down > 0.0){
            diff_color = Dn_Color;
            arrow = "%";
            Alerts+=Sym_arr[i]+" (W1) Down 3 Semafor\n";
         }else{
            diff_color = Neutral_Color;
            arrow = "§";
         }
         ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x-0, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      
      Pair_y = Pair_y+30;
      
   }
   
   if (TimeCurrent() > (LastAlert+60) && Alerts!=""){
      signaler.SendNotifications("MTF MCP 3 Level Semafor", "MTF MCP 3 Level Semafor:\n" + Alerts);
      LastAlert = TimeCurrent();
   }
   
   Last_History_Process = TimeCurrent();       
   
   }
   
//----
   return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
   return;
}

void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (i=0; i < len;) {
    pos = StringFind(str, sym, i);
    if (pos == -1) pos = len;
    
    item = StringSubstr(str, i, pos-i);
    item = StringTrimLeft(item);
    item = StringTrimRight(item);
    
    size = ArraySize(arr);
    ArrayResize(arr, size+1);
    arr[size] = item;
    
    i = pos+1;
  }
}