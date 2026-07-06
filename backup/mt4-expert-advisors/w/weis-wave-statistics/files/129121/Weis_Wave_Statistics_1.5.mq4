// Id:  
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67761

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.5"
#property strict

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red

enum CalcMethod
{
   Total, // Total
   Average // Average
};

enum LegSize
{
   DoNotShow, // Do not show
   ShowPips, // Pips
   ShowBars // Bars
};

extern int dif=1;
extern color up_leg_color = Green; // Up Leg Color
extern color down_leg_color = Red; // Down Leg Color
extern CalcMethod leg_volume_calc_method = Total; // Leg Volume Calculation Method
extern bool show_leg_volume_total = false; // Show Leg Total Volume
extern bool show_leg_volume_avg = false; // Show Leg Average Volume
extern color labels_color = Gray; // Labels Color
extern color now_label_color = Red; // Now Label Color
extern double now_label_shift_pips = 1; // Now Label Shift, pips
extern bool show_time = false; // Show Time
extern LegSize show_leg_size = DoNotShow; // Show Leg Size
extern int bars_limit = 1000;
input int total_volume_divisor = 10; // Total Volume divisor
input int average_volume_divisor = 10; // Average Volume divisor
input bool show_current_volume = true; // Show current volume
input bool show_percentage = true; // Show percentage

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = false; // Popup message
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

// int OnInit()
// {
//    if (!IsDllsAllowed() && advanced_alert)
//    {
//       Print("Error: Dll calls must be allowed!");
//       return INIT_FAILED;
//    }
// }

double WW[], WW_DN[];
double mov[], trend[], wave[], vol[];
double difPip;

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

// Instrument info v.1.2
class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathCeil(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};

double pipSize;
Signaler* signaler;

int init()
{
   IndicatorName = GenerateIndicatorName("WeisWave Statistics");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   InstrumentInfo info(_Symbol);
   pipSize = info.GetPipSize();

   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, WW);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, WW_DN);

   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,mov);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,trend);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,wave);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,vol);
   
   difPip = dif * Point;

   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES) _Period);
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");

   return(0);
}

int deinit()
{
   delete signaler;
   signaler = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int findPreviousPosition(const int pos)
{
   int direction = (int)wave[pos];
   for (int i = pos + 1; i < Bars - 1; ++i)
   {
      if (wave[i] != direction)
         return i;
   }
   return -1;
}

void DrawLine(const string id, const double rate1, const int pos1, const double rate2, const int pos2, const color clr, int prev_prev_pos)
{
   if (!ObjectCreate(ChartID(), id, OBJ_TREND, 0, Time[pos1], rate1, Time[pos2], rate2)) 
      return;
      
   ObjectSetInteger(ChartID(), id, OBJPROP_COLOR, clr); 
   ObjectSetInteger(ChartID(), id, OBJPROP_RAY_RIGHT, false); 
   string label = "";
   if (show_leg_volume_total)
   {
      label = label + " " + IntegerToString((int)vol[pos2] / total_volume_divisor);
      if (show_percentage)
      {
         double pr = (vol[pos2] / vol[pos1]) * 100 - 100;
         if (pr > 0)
            label = label + "(+" + DoubleToStr(pr, 1) + "%)";
         else
            label = label + "(" + DoubleToStr(pr, 1) + "%)";
      }
         
   }
   if (show_leg_volume_avg)
   {
      double currentValue = vol[pos2] / (pos1 - pos2);
      label = label + " " + IntegerToString((int)MathCeil(currentValue / average_volume_divisor));
      if (show_percentage && prev_prev_pos != -1)
      {
         double prevValue = vol[pos1] / (prev_prev_pos - pos1);
         double pr = (currentValue / prevValue) * 100 - 100;
         if (pr > 0)
            label = label + "(+" + DoubleToStr((currentValue / prevValue) * 100 - 100, 1) + "%)";
         else
            label = label + "(" + DoubleToStr((currentValue / prevValue) * 100 - 100, 1) + "%)";
      }
   }
   if (show_time)
      label = label + " " + IntegerToString((int)MathCeil((Time[pos2] - Time[pos1]) / 60 )) + "min";

   switch (show_leg_size)
   {
      case DoNotShow:
         break;
      case ShowPips:
         label = label + " " + DoubleToStr(MathAbs(Low[pos1] - High[pos2]) / pipSize, 1) + "p";
         break;
      case ShowBars:
         label = label + " " + IntegerToString(pos1 - pos2) + " bars";
         break;
   }
   if (label != "")
   {
      if (!ObjectCreate(ChartID(), id + "_label", OBJ_TEXT, 0, Time[pos2], rate2))
         return;
      ObjectSetString(ChartID(), id + "_label", OBJPROP_TEXT, label); 
      ObjectSetString(ChartID(), id + "_label", OBJPROP_FONT, "Arial"); 
      ObjectSetInteger(ChartID(), id + "_label", OBJPROP_FONTSIZE, 10); 
      ObjectSetInteger(ChartID(), id + "_label", OBJPROP_ANCHOR, rate1 > rate2 ? ANCHOR_UPPER : ANCHOR_LOWER); 
      ObjectSetInteger(ChartID(), id + "_label", OBJPROP_COLOR, labels_color); 
   }
}

int start()
{
   if (Bars <= 3)
      return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars < 0)
      return(-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   int pos = MathMin(bars_limit, limit);
   while (pos >= 0)
   {
      if (Close[pos] > Close[pos+1])
         mov[pos] = 1.;
      else
      {
         if (Close[pos] < Close[pos+1])
            mov[pos] = -1.;
         else
            mov[pos] = 0.;
      }
      
      if (mov[pos] != 0. && mov[pos] != mov[pos + 1])
         trend[pos] = mov[pos];
      else
         trend[pos]=trend[pos+1];
      
      if (trend[pos] != wave[pos + 1] && MathAbs(Close[pos] - Close[pos + 1]) >= difPip)
      {
         wave[pos] = trend[pos];
         int prev_pos = findPreviousPosition(pos + 1);
         if (prev_pos != -1)
         {
            int prev_prev_pos = findPreviousPosition(prev_pos);
            if (wave[pos] == 1)
            {
               DrawLine(IndicatorObjPrefix + TimeToStr(Time[prev_pos]) + "wave", 
                  High[prev_pos], prev_pos, Low[pos + 1], pos + 1, down_leg_color, prev_prev_pos);
            }
            else
            {
               DrawLine(IndicatorObjPrefix + TimeToStr(Time[prev_pos]) + "wave", 
                  Low[prev_pos], prev_pos, High[pos + 1], pos + 1, up_leg_color, prev_prev_pos);
            }
         }
      }
      else
         wave[pos]=wave[pos+1];
      
      if (wave[pos]==wave[pos+1])
         vol[pos] = vol[pos + 1] + Volume[pos];
      else
         vol[pos] = (double)Volume[pos];

      WW[pos]=EMPTY_VALUE;
      WW_DN[pos]=EMPTY_VALUE;
      
      int period = 1;
      if (leg_volume_calc_method != Total)
      {
         int prev_pos = findPreviousPosition(pos);
         if (prev_pos != -1)
            period = pos - prev_pos;
      } 
      if (wave[pos] == 1)
         WW[pos] = vol[pos] / period;
      else if (wave[pos] == -1)
         WW_DN[pos] = vol[pos] / period;

      pos--;
   } 
   if (wave[1] != wave[2])
   {
      if (wave[1] == 1)
         signaler.SendNotifications("Up trend started");
      else
         signaler.SendNotifications("Down trend started");
   }
   if (show_current_volume)
   {
      string id = IndicatorObjPrefix + "idValueCurrent";
      double rate = wave[0] == 1 ? Low[0] - now_label_shift_pips * pipSize : High[0] + now_label_shift_pips * pipSize;
      ObjectCreate(0, id, OBJ_TEXT, 0, Time[0], rate);
      ObjectSetString(0, id, OBJPROP_TEXT, DoubleToString(vol[0] / total_volume_divisor, 0));
      ObjectSetString(0, id, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, id, OBJPROP_COLOR, now_label_color);
      ObjectSetInteger(0, id, OBJPROP_ANCHOR, wave[0] == 1 ? ANCHOR_UPPER : ANCHOR_LOWER);
      ObjectMove(0, id, 0, Time[0], rate);
   }
   return(0);
}

