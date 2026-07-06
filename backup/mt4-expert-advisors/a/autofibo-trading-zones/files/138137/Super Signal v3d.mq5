// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70523

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

// based on Nick Bilak, alterations by Mark Tomlinson, alterations by Money Duck @ 4xCampus.com, http://www.forex-tsd.com/"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_color1 Yellow
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Aqua
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1

input int  dist2           = 21;
input int  dist1           = 14;
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
#ifdef ADVANCED_ALERTS
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";
#endif

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#endif

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
   bool _popupAlert;
   bool _emailAlert;
   bool _playSound;
   string _soundFile;
   bool _notificationAlert;
   bool _advancedAlert;
   string _advancedKey;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _popupAlert = false;
      _emailAlert = false;
      _playSound = false;
      _notificationAlert = false;
      _advancedAlert = false;
   }

   void SetPopupAlert(bool isEnabled) { _popupAlert = isEnabled; }
   void SetEmailAlert(bool isEnabled) { _emailAlert = isEnabled; }
   void SetPlaySound(bool isEnabled, string fileName) 
   { 
      _playSound = isEnabled;
      _soundFile = fileName;
   }
   void SetNotificationAlert(bool isEnabled) { _notificationAlert = isEnabled; }
   void SetAdvancedAlert(bool isEnabled, string key)
   {
      _advancedAlert = isEnabled;
      _advancedKey = key;
   }

   void SendNotifications(string message, string subject = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (subject == NULL)
         subject = message;

      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (_popupAlert)
         Alert(message);
      if (_emailAlert)
         SendMail(subject, message);
      if (_playSound)
         PlaySound(_soundFile);
      if (_notificationAlert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (_advancedAlert && _advancedKey != "")
         AdvancedAlert(_advancedKey, message, symbol, timeframe);
#endif
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
         case PERIOD_M2: return "M2";
         case PERIOD_M3: return "M3";
         case PERIOD_M4: return "M4";
         case PERIOD_M5: return "M5";
         case PERIOD_M6: return "M6";
         case PERIOD_M10: return "M10";
         case PERIOD_M12: return "M12";
         case PERIOD_M15: return "M15";
         case PERIOD_M20: return "M20";
         case PERIOD_M30: return "M30";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H2: return "H2";
         case PERIOD_H3: return "H3";
         case PERIOD_H4: return "H4";
         case PERIOD_H6: return "H6";
         case PERIOD_H8: return "H8";
         case PERIOD_H12: return "H12";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

double b1[];
double b2[];
double b3[];
double b4[];
int atr;
Signaler* mainSignaler;
int OnInit(void)
{
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetPopupAlert(Popup_Alert);
   mainSignaler.SetEmailAlert(Email_Alert);
   mainSignaler.SetPlaySound(Play_Sound, Sound_File);
   mainSignaler.SetNotificationAlert(Notification_Alert);
   #ifdef ADVANCED_ALERTS
   mainSignaler.SetAdvancedAlert(Advanced_Alert, Advanced_Key);
   #endif
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");

   int id = 0;
   SetIndexBuffer(id, b1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 334);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, b2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 333);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, b3, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 233);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, b4, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 234);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;
   atr = iATR(_Symbol, _Period, 50);
   return(0);
}

void OnDeinit(const int reason)
{
   delete mainSignaler;
   mainSignaler = NULL;
   IndicatorRelease(atr);
}

datetime last_signal;
int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(b1, EMPTY_VALUE);
      ArrayInitialize(b2, EMPTY_VALUE);
      ArrayInitialize(b3, EMPTY_VALUE);
      ArrayInitialize(b4, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldIndex = rates_total - 1 - pos;
      int hhb1 = iHighest(_Symbol, _Period, MODE_HIGH, dist1, MathMax(0, oldIndex - dist1 / 2));
      int llb1 = iLowest(_Symbol, _Period, MODE_LOW, dist1, MathMax(0, oldIndex - dist1 / 2));

      int hhb = iHighest(_Symbol, _Period, MODE_HIGH, dist2, MathMax(0, oldIndex - dist2 / 2));
      int llb = iLowest(_Symbol, _Period, MODE_LOW, dist2, MathMax(0, oldIndex - dist2 / 2));
      double tr[1];
      if (CopyBuffer(atr, 0, oldIndex, 1, tr) != 1)
      {
         continue;
      }
   
      if (oldIndex == hhb)
         b1[pos] = high[pos] + tr[0];
      if (oldIndex == llb)
         b2[pos] = low[pos] - tr[0];
      if (oldIndex == hhb1)
         b3[pos] = high[pos] + tr[0] / 2;
      if (oldIndex == llb1)
         b4[pos] = low[pos] - tr[0] / 2;
   }
   if (last_signal != time[rates_total - 1])
   {
      if (b1[rates_total - 1] != EMPTY_VALUE && b3[rates_total - 1] != EMPTY_VALUE)
      {
         mainSignaler.SendNotifications("strong sell");
         last_signal = time[rates_total - 1];
      }
      if (b1[rates_total - 1] != EMPTY_VALUE && b3[rates_total - 1] == EMPTY_VALUE)
      {
         mainSignaler.SendNotifications("sell");
         last_signal = time[rates_total - 1];
      }
      if (b1[rates_total - 1] == EMPTY_VALUE && b3[rates_total - 1] != EMPTY_VALUE)
      {
         mainSignaler.SendNotifications("minor sell or exit buy");
         last_signal = time[rates_total - 1];
      }
      if (b2[rates_total - 1] != EMPTY_VALUE && b4[rates_total - 1] != EMPTY_VALUE)
      {
         mainSignaler.SendNotifications("strong buy");
         last_signal = time[rates_total - 1];
      }
      if (b2[rates_total - 1] != EMPTY_VALUE && b4[rates_total - 1] == EMPTY_VALUE)
      {
         mainSignaler.SendNotifications("buy");
         last_signal = time[rates_total - 1];
      }
      if (b2[rates_total - 1] == EMPTY_VALUE && b4[rates_total - 1] != EMPTY_VALUE)
      {
         mainSignaler.SendNotifications("minor buy or exit sell");
         last_signal = time[rates_total - 1];
      }
   }
   return rates_total;
}
