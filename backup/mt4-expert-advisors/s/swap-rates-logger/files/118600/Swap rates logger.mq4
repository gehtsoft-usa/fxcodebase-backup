// Id: 20940
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65916

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                   Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                 Patreon : https://goo.gl/9Rj74e  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property description "Swap Logger"
#property indicator_chart_window

extern string Comment1 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string Pairs = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern string fileName = "swaps.csv"; // File name
extern color    Labels_Color             = clrWhite;
extern bool     Sound_Alert              = true; // Sound alert
extern bool     Notification_Alert       = false; // Notification alert
extern bool     Email_Alert              = false; // Email alert
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Also, you need to install AdvancedNotificationsLib.dll and allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Make sure that Microsoft .NET Framework 4.6 is installed on your PC -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
string   WindowName;
int      WindowNumber;
string Sym_arr[]; // Pairs symbols
double Last_Swap_Long[];
double Last_Swap_Short[];
string col_0[];
string col_1[];
string col_2[];
int    Sym_count; // Number of symbols

string _font = "Arial";
int _fontSize = 12;

void split(string& arr[], string str, string sym) 
{
   ArrayResize(arr, 0);
   string item;
   int pos, size;
   
   int len = StringLen(str);
   for (int i=0; i < len;) {
      pos = StringFind(str, sym, i);
      if (pos == -1) pos = len;
      
      item = StringSubstr(str, i, pos-i);
      item = StringTrimLeft(item);
      item = StringTrimRight(item);
      
      size = ArraySize(arr);
      ArrayResize(arr, size+1);
      ArrayResize(Last_Swap_Long, size + 1);
      ArrayResize(Last_Swap_Short, size + 1);
      arr[size] = item;
      
      i = pos+1;
   }
}

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
   WindowName = "Swap Rates List";
   IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   WindowName = IndicatorName;

   split(Sym_arr, Pairs, ",");
   
   for (int i = 0; i < Sym_count; i++)
   {
      Last_Swap_Long[i] = GlobalVariableGet(Sym_arr[i] + "_Swap_Long");
      Last_Swap_Short[i] = GlobalVariableGet(Sym_arr[i] + "_Swap_Short");
   }
    
   Sym_count = ArraySize(Sym_arr);
   ArrayResize(col_0, Sym_count);
   ArrayResize(col_1, Sym_count);
   ArrayResize(col_2, Sym_count);

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

class TextMaxSizeCalculator
{
    int _width;
    int _height;
public:
    TextMaxSizeCalculator()
    {
        _width = 0;
        _height = 0;
    }

    void AddText(const string text)
    {
        int width;
        int height;
        TextGetSize(text, width, height);
        if (_width < width)
        {
            _width = width;
        }
        if (_height < height)
        {
            _height = height;
        }
    }

    int GetWidth()
    {
        return _width;
    }
    int GetHeight()
    {
        return _height;
    }
};

void SendNotifications(const string subject, const string message, const string symbol, const string timeframe)
{
   if (Sound_Alert)
      Alert(message);
   if (Email_Alert)
      SendMail(subject, message);
   if (Play_Sound)
      PlaySound(Sound_File);
   if (Notification_Alert)
      SendNotification(message);
   if (Advanced_Alert && Advanced_Key != "")
      AdvancedAlert(Advanced_Key, message, symbol, timeframe);
}

int start()
{
   WindowNumber = 0;

   int y = 50;
   int x = 50;
   TextMaxSizeCalculator col0;
   TextMaxSizeCalculator col1;
   TextMaxSizeCalculator col2;
   for (int i = 0; i < Sym_count; i++)
   {
      int current_y = y + (i + 1) * 20;
      col_0[i] = Sym_arr[i];
      col0.AddText(col_0[i]);
      
      double swap_long = SymbolInfoDouble(Sym_arr[i], SYMBOL_SWAP_LONG);
      col_1[i] = DoubleToStr(swap_long, 8);
      col1.AddText(col_1[i]);
      if (Last_Swap_Long[i] != swap_long)
      {
         string alert_Body = "Swap Long for " + Sym_arr[i] + " changed to " + col_1[i];
         SendNotifications(alert_Body, alert_Body, Sym_arr[i], "m1");
         Last_Swap_Long[i] = swap_long;
         GlobalVariableSet(Sym_arr[i] + "_Swap_Long", swap_long);
         int fileHandle = FileOpen(fileName + ".csv", FILE_WRITE | FILE_CSV, ",");
         if (fileHandle != -1)
         {
            FileWrite(fileHandle, TimeToStr(Time[0]), Sym_arr[i] + " long swap", DoubleToStr(swap_long)); 
            FileClose(fileHandle);
         }
      }

      double swap_short = SymbolInfoDouble(Sym_arr[i], SYMBOL_SWAP_SHORT);
      col_2[i] = DoubleToStr(swap_short, 8);
      col2.AddText(col_2[i]);
      if (Last_Swap_Short[i] != swap_short)
      {
         alert_Body = "Swap Short for " + Sym_arr[i] + " changed to " + col_2[i];
         SendNotifications(alert_Body, alert_Body, Sym_arr[i], "m1");
         Last_Swap_Short[i] = swap_short;
         GlobalVariableSet(Sym_arr[i] + "_Swap_Short", swap_short);
         int fileHandle2 = FileOpen(fileName + ".csv", FILE_WRITE | FILE_CSV, ",");
         if (fileHandle2 != -1)
         {
            FileWrite(fileHandle2, TimeToStr(Time[0]), Sym_arr[i] + " short swap", DoubleToStr(swap_short)); 
            FileClose(fileHandle2);
         }
      }
   }
   col1.AddText("Swap Long");
   col2.AddText("Swap Short");
   int col_0_x = x;
   int col_1_x = col_0_x + col0.GetWidth() * 1.1;
   int col_2_x = col_1_x + col1.GetWidth() * 1.1;
   ObjectMakeLabel("col_1", col_1_x, y, "Swap Long", Labels_Color, 1, WindowNumber, _font, _fontSize);
   ObjectMakeLabel("col_2", col_2_x, y, "Swap Short", Labels_Color, 1, WindowNumber, _font, _fontSize);
   int h = col0.GetHeight() * 1.1;
   for (i = 0; i < Sym_count; i++)
   {
      ObjectMakeLabel("col_0_" + i, col_0_x, y + (i + 1) * h, col_0[i], Labels_Color, 1, WindowNumber, _font, _fontSize);
      ObjectMakeLabel("col_1_" + i, col_1_x, y + (i + 1) * h, col_1[i], Labels_Color, 1, WindowNumber, _font, _fontSize);
      ObjectMakeLabel("col_2_" + i, col_2_x, y + (i + 1) * h, col_2[i], Labels_Color, 1, WindowNumber, _font, _fontSize);
   }
   return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
{
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
}