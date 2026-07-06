// Id: 25287
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68572

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
#property version   "1.1"
#property strict
#property indicator_chart_window

input int Period = 13; // Period
input double Multiplier = 0.7; // Multiplier
input color Color = Blue; // Color
input int FontSize = 20; // Font size
input ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER; // Corner
input int H_Shift = 0; // Horizontal shift
input int V_Shift = 50; // Vertical shift
input double AlertLevel = 20; // Alert Level
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
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("ATR pips indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete signaler;
   signaler = NULL;
   return 0;
}

datetime last_date;
int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   double atrValue0 = iATR(_Symbol, _Period, Period, 0) * Multiplier / pipSize;
   double atrValue1 = iATR(_Symbol, _Period, Period, 1) * Multiplier / pipSize;
   
   string text = DoubleToStr(MathFloor(Multiplier * 100), 0) + "% of ATR (" + IntegerToString(Period) + "):" 
      + DoubleToStr(atrValue0, 1) + " pips";
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   string mainLabelId = IndicatorObjPrefix + "mainLabel";
   ObjectCreate(0, mainLabelId, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, mainLabelId, OBJPROP_XDISTANCE, H_Shift);
   ObjectSetInteger(0, mainLabelId, OBJPROP_YDISTANCE, V_Shift);
   ObjectSetInteger(0, mainLabelId, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, mainLabelId, OBJPROP_ANCHOR, (corner == CORNER_LEFT_UPPER || corner == CORNER_LEFT_LOWER) ?  ANCHOR_LEFT : ANCHOR_RIGHT);
   ObjectSetString(0, mainLabelId, OBJPROP_TEXT, text);
   ObjectSetString(0, mainLabelId, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, mainLabelId, OBJPROP_FONTSIZE, FontSize);
   ObjectSetInteger(0, mainLabelId, OBJPROP_COLOR, Color);

   if (last_date != Time[0])
   {
      if (AlertLevel < atrValue0 && AlertLevel >= atrValue1)
      {
         signaler.SendNotifications("Cross under");
         last_date = Time[0];
      }
      if (AlertLevel > atrValue0 && AlertLevel <= atrValue1)
      {
         signaler.SendNotifications("Cross over");
         last_date = Time[0];
      }
   }
   return 0;
}