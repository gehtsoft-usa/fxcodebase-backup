// More information about this indicator can be found at:
// http://fxcodebase.com/

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

// Trading arrow with alert template v.1.1

string IndicatorName = "BB Arrow LTF";

extern ENUM_TIMEFRAMES TF = PERIOD_M1; // BB Timeframe
extern int        Bollinger_Bands_Periods       = 20; // BB periods
extern double     Bollinger_Bands_Deviations    = 2; // BB Deviations
extern int barsLimit = 1000; // Bars limit

//Signaler v 1.2.1
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- Telegram/Discord/other platform (like FXTS2). You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
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
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"

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
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

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
         alert_Subject = "Buy signal on " + _Symbol + "/" + tf;
         alert_Body = "Buy signal on " + _Symbol + "/" + tf;
         break;
      case ENTER_SELL_SIGNAL:
         alert_Subject = "Sell signal on " + _Symbol + "/" + tf;
         alert_Body = "Sell signal on " + _Symbol + "/" + tf;
         break;
      case EXIT_BUY_SIGNAL:
         alert_Subject = "Exit buy signal on " + _Symbol + "/" + tf;
         alert_Body = "Exit buy signal on " + _Symbol + "/" + tf;
         break;
      case EXIT_SELL_SIGNAL:
         alert_Subject = "Exit sell signal on " + _Symbol + "/" + tf;
         alert_Body = "Exit sell signal on " + _Symbol + "/" + tf;
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
   int limit = Bars - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = MathMin(barsLimit, limit);
   while (pos >= 0)
   {
      sell[pos] = EMPTY_VALUE;
      buy[pos] = EMPTY_VALUE;
      double open = Open[pos];
      double close = Close[pos];
      int fromIndex = iBarShift(NULL, TF, Time[pos], false);
      int toIndex = pos == 0 ? 0 : iBarShift(NULL, TF, Time[pos - 1], false);
      for (int i = fromIndex; i >= toIndex; --i)
      {
         double top = iBands(NULL, TF, Bollinger_Bands_Periods, Bollinger_Bands_Deviations, 0, PRICE_CLOSE,MODE_UPPER, i);
         double bottom = iBands(NULL, TF, Bollinger_Bands_Periods, Bollinger_Bands_Deviations, 0, PRICE_CLOSE, MODE_LOWER, i);
         if (open < top && close >= top)
         {
            sell[pos] = High[pos];
            if (pos == 0)
               SendNotifications(ENTER_SELL_SIGNAL);
         }
         if (open > bottom && close <= bottom)
         {
            buy[pos] = Low[pos];
            if (pos == 0)
               SendNotifications(ENTER_BUY_SIGNAL);
         }
      }
      pos--;
   } 
   return(0);
}

