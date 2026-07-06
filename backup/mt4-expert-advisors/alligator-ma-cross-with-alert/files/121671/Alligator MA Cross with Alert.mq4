// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66846

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

// Trading arrow with alert template v.1.0.0

string IndicatorName = "Alligator MA Cross with Alert";

enum AveragesMethod
{
   SMA = MODE_SMA, // SMA
   EMA = MODE_EMA, // EMA
   SMMA = MODE_SMMA, // SMMA
   LWMA = MODE_LWMA, // LWMA
   WMA,
   SineWMA,
   TriMA,
   LSMA,
   HMA,
   ZeroLagEMA,
   DEMA,
   T3MA,
   ITrend,
   Median,
   GeoMean,
   REMA,
   ILRS,
   IE2,
   TriMAgen,
   JSmooth
};

extern int JawN = 13; // Alligator Jaw smoothing periods
extern int JawS = 8; // Alligator Jaw shifting periods
extern int TeethN = 8; // Alligator Teeth smoothing periods
extern int TeethS = 5; // Alligator Teeth shifting periods
extern int LipsN = 5; // Alligator Lips smoothing periods
extern int LipsS = 3; // Alligator Lips shifting periods
extern AveragesMethod MTH = SMMA; // Smoothing method
extern ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Price Source
extern AveragesMethod Method = SMA; // Smoothing method
extern int Period = 50; // Period
extern bool AlertMAJawUp = true; // Alert MA/Jaw up cross
extern bool AlertMAJawDown = true; // Alert MA/Jaw down cross
extern bool AlertMATeethUp = true; // Alert MA/Teeth up cross
extern bool AlertMATeethDown = true; // Alert MA/Teeth down cross
extern bool AlertMALipsUp = true; // Alert MA/Lips up cross
extern bool AlertMALipsDown = true; // Alert MA/Lips down cross

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
#property indicator_buffers 10
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_color7 Blue
#property indicator_color8 Red
#property indicator_color9 Green
#property indicator_color10 Yellow
#property indicator_label1 "MA/Jaw Up Cross"
#property indicator_label2 "MA/Jaw Down Cross"
#property indicator_label3 "MA/Teeth Up Cross"
#property indicator_label4 "MA/Teeth Down Cross"
#property indicator_label5 "MA/Lips Up Cross"
#property indicator_label6 "MA/Lips Down Cross"
#property indicator_label7 "Jaw"
#property indicator_label8 "Teeth"
#property indicator_label9 "Lips"
#property indicator_label10 "MA"

double MAJawUp[], MAJawDown[], MATeethUp[], MATeethDown[], MALipsUp[], MALipsDown[];
double JawSrc[], TeethSrc[], LipsSrc[], ma[];
class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframe();

      if (Popup_Alert)
         Alert(message);
      if (Email_Alert)
         SendMail(subject, message);
      if (Play_Sound)
         PlaySound(Sound_File);
      if (Notification_Alert)
         SendNotification(message);
      if (Advanced_Alert && Advanced_Key != "" && !IsTesting())
         AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

private:
   string GetTimeframe()
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
};
Signaler *_signaler;

int init()
{
   double temp = iCustom(NULL, 0, "averages", JawN, PRICE_MEDIAN, MTH, 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the averages indicator");
      return INIT_FAILED;
   }
   
   _signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, MAJawUp);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, MAJawDown);
   SetIndexStyle(2, DRAW_ARROW, 0, 2);
   SetIndexArrow(2, 217);
   SetIndexBuffer(2, MATeethUp);
   SetIndexStyle(3, DRAW_ARROW, 0, 2);
   SetIndexArrow(3, 218);
   SetIndexBuffer(3, MATeethDown);
   SetIndexStyle(4, DRAW_ARROW, 0, 2);
   SetIndexArrow(4, 217);
   SetIndexBuffer(4, MALipsUp);
   SetIndexStyle(5, DRAW_ARROW, 0, 2);
   SetIndexArrow(5, 218);
   SetIndexBuffer(5, MALipsDown);

   SetIndexStyle(6, DRAW_LINE);
   SetIndexBuffer(6, JawSrc);
   SetIndexStyle(7, DRAW_LINE);
   SetIndexBuffer(7, TeethSrc);
   SetIndexStyle(8, DRAW_LINE);
   SetIndexBuffer(8, LipsSrc);
   SetIndexStyle(9, DRAW_LINE);
   SetIndexBuffer(9, ma);

   return(0);
}

int deinit()
{
   delete _signaler;
   return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 2;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 2;
   int pos = limit;
   while (pos >= 0)
   {
      JawSrc[pos] = iCustom(_Symbol, _Period, "averages", JawN, PRICE_MEDIAN, MTH, 0, pos);
      TeethSrc[pos] = iCustom(_Symbol, _Period, "averages", TeethN, PRICE_MEDIAN, MTH, 0, pos);
      LipsSrc[pos] = iCustom(_Symbol, _Period, "averages", LipsN, PRICE_MEDIAN, MTH, 0, pos);
      ma[pos] = iCustom(_Symbol, _Period, "averages", Period, Price, Method, 0, pos);
      MAJawUp[pos] = EMPTY_VALUE;
      MAJawDown[pos] = EMPTY_VALUE;
      MATeethUp[pos] = EMPTY_VALUE;
      MATeethDown[pos] = EMPTY_VALUE;
      MALipsUp[pos] = EMPTY_VALUE;
      MALipsDown[pos] = EMPTY_VALUE;

      if (ma[pos] >= JawSrc[pos] && ma[pos + 1] < JawSrc[pos + 1])
      {
         MAJawUp[pos] = Low[pos];
         if (pos == 0)
            _signaler.SendNotifications("MA crossed over Jaw");
      }
      else if (ma[pos] <= JawSrc[pos] && ma[pos + 1] > JawSrc[pos + 1])
      {
         MAJawDown[pos] = High[pos];
         if (pos == 0)
            _signaler.SendNotifications("MA crossed under Jaw");
      }
      if (ma[pos] >= TeethSrc[pos] && ma[pos + 1] < TeethSrc[pos + 1])
      {
         MATeethUp[pos] = Low[pos];
         if (pos == 0)
            _signaler.SendNotifications("MA crossed over Teeth");
      }
      else if (ma[pos] <= TeethSrc[pos] && ma[pos + 1] > TeethSrc[pos + 1])
      {
         MATeethDown[pos] = High[pos];
         if (pos == 0)
            _signaler.SendNotifications("MA crossed under Teeth");
      }
      if (ma[pos] >= LipsSrc[pos] && ma[pos + 1] < LipsSrc[pos + 1])
      {
         MALipsUp[pos] = Low[pos];
         if (pos == 0)
            _signaler.SendNotifications("MA crossed over Lips");
      }
      else if (ma[pos] <= LipsSrc[pos] && ma[pos + 1] > LipsSrc[pos + 1])
      {
         MALipsDown[pos] = High[pos];
         if (pos == 0)
            _signaler.SendNotifications("MA crossed under Lips");
      }
      pos--;
   } 
   return(0);
}

