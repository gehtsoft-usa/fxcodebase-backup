// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67332

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
#property version   "1.0"
#property strict

// Trading arrow with alert template v.1.0.0

string IndicatorName = "Engulfing Pattern";

//Signaler v 1.2.1
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_label1 "Bullish"
#property indicator_label2 "Bearish"

double buy[], sell[];

int init()
{
   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, buy);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, sell);
   
   return(0);
}

int deinit()
{
   return(0);
}

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1

int GetDirection(const int period)
{
   if (Low[period] <= Low[period + 1] && Close[period] > High[period + 1])
      return ENTER_BUY_SIGNAL;
   if (Open[period] <= MathMin(Open[period + 1], Close[period + 1]) && Close[period] > MathMax(Open[period + 1], Close[period + 1]))
      return ENTER_BUY_SIGNAL;

   if (High[period] >= High[period + 1] && Close[period] < Low[period + 1])
	   return ENTER_SELL_SIGNAL;
   if (Open[period] >= MathMax(Open[period + 1], Close[period + 1]) && Close[period] < MathMin(Open[period + 1], Close[period + 1]))
	   return ENTER_SELL_SIGNAL;
   return 0;
}

string GetTimeframe()
{
   switch (_Period)
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

datetime _lastDatetime;

void SendNotifications(const int direction)
{
   if (direction == 0 || IsTesting())
      return;

   datetime currentTime = iTime(_Symbol, _Period, 0);
   if (_lastDatetime == currentTime)
      return;

   _lastDatetime = currentTime;
   string tf = GetTimeframe();
   string alert_Subject;
   string alert_Body;
   switch (direction)
   {
      case ENTER_BUY_SIGNAL:
         alert_Subject = "Bullish engulfing on " + _Symbol + "/" + tf;
         alert_Body = "Bullish engulfing on " + _Symbol + "/" + tf;
         break;
      case ENTER_SELL_SIGNAL:
         alert_Subject = "Bearish engulfing on " + _Symbol + "/" + tf;
         alert_Body = "Bearish engulfing on " + _Symbol + "/" + tf;
         break;
   }
   SendNotifications(alert_Subject, alert_Body, _Symbol, tf);
}

void SendNotifications(const string subject, const string message, const string symbol, const string timeframe)
{
   if (Popup_Alert)
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
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 1 - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      int direction = GetDirection(pos);
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            buy[pos] = Low[pos];
            sell[pos] = EMPTY_VALUE;
            break;
         case ENTER_SELL_SIGNAL:
            buy[pos] = EMPTY_VALUE;
            sell[pos] = High[pos];
            break;
      }
      if (pos == 0)
         SendNotifications(direction);
      pos--;
   } 
   return(0);
}

