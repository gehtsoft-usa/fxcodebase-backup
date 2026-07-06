// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=60781
//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

#define Pi 3.1415926

extern int Length=14;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern color TrendColor=Yellow; 
extern int Font_Size=10;
//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start inputal program
input string   program_path             = ""; // Path to the inputal program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

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

double TA[];

string ObjName;

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

Signaler* signaler;

int init()
{
   IndicatorName = GenerateIndicatorName("Trend Angle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");

   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, TA);
   ObjName = IndicatorObjPrefix + "Trend_Angle" + Length + Method + Price;

   return 0;
}

int deinit()
{
   delete signaler;
   signaler = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

datetime lastSignal;
int start()
{
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   int pos;
   pos=limit;
   while(pos>=0)
   {
      TA[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
      pos--;
   } 
   
   double Price1, Price2;
   datetime Time1, Time2;
   Price1=TA[1];
   Price2=TA[0];
   Time1=Time[1];
   Time2=Time[0];
   if (ObjectFind(0, ObjName) == -1)
   {
      ObjectCreate(0, ObjName, OBJ_TREND, 0, Time1, Price1, Time2, Price2);
   }
   else
   {
      if (ObjectGet(ObjName, OBJPROP_TIME1) != Time1)
      {
         ObjectSet(ObjName, OBJPROP_TIME1, Time1);
      }
      if (ObjectGet(ObjName, OBJPROP_TIME2) != Time2)
      {
         ObjectSet(ObjName, OBJPROP_TIME2, Time2);
      }
      if (ObjectGet(ObjName, OBJPROP_PRICE1) != Price1)
      {
         ObjectSet(ObjName, OBJPROP_PRICE1, Price1);
      }
      if (ObjectGet(ObjName, OBJPROP_PRICE2) != Price2)
      {
         ObjectSet(ObjName, OBJPROP_PRICE2, Price2);
      }
   }
   if (ObjectGet(ObjName, OBJPROP_COLOR) != TrendColor)
   {
      ObjectSet(ObjName, OBJPROP_COLOR, TrendColor);
   }
   
   double Angle;
   string AngleStr;
   int x1, x2, y1, y2;
   ChartTimePriceToXY(0, 0, Time[10], 10. * Price1 - 9. * Price2, x1, y1);
   ChartTimePriceToXY(0, 0, Time2, Price2, x2, y2);
   Angle = 90 - MathArctan((0. + x1 - x2) / (0. + y2 - y1)) * 180. / Pi;
   AngleStr = DoubleToString(Angle, 2);
   if (lastSignal != Time[0] && Angle >= 50)
   {
      signaler.SendNotifications("Angle >= 50");
   }
   else if (lastSignal != Time[0] && Angle <= 130)
   {
      signaler.SendNotifications("Angle <= 130");
   }
   
   if (ObjectFind(0, ObjName+"T")==-1)
   {
      ObjectCreate(0, ObjName+"T", OBJ_TEXT, 0, Time2, Price2);
   }
   else
   {
      if (ObjectGet(ObjName+"T", OBJPROP_TIME1)!=Time2)
      {
         ObjectSet(ObjName+"T", OBJPROP_TIME1, Time2);
      }
      if (ObjectGet(ObjName+"T", OBJPROP_PRICE1)!=Price2)
      {
         ObjectSet(ObjName+"T", OBJPROP_PRICE1, Price2);
      }
   } 
   ObjectSetText(ObjName+"T", AngleStr, Font_Size, NULL, TrendColor);
   
   return(0);
}

