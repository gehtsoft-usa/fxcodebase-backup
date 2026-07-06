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
#property description "VIX indicator"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

#property indicator_type1 DRAW_ARROW
#property indicator_width1 1
#property indicator_color1 0xFF0000
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 1
#property indicator_color2 0x0000FF
#property indicator_label2 "Sell"

#property indicator_type3 DRAW_ARROW
#property indicator_width3 1
#property indicator_color3 0xFF0000
#property indicator_label3 "Buy"

#property indicator_type4 DRAW_ARROW
#property indicator_width4 1
#property indicator_color4 0x0000FF
#property indicator_label4 "Sell"

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];

input int FastMA = 14;
input int SlowMA = 21;
datetime time_alert; //used when sending alert
input bool Push_Notifications = true;
double myPoint; //initialized in OnInit
int MA_handle;
double MA[];
int MA_handle2;
double MA2[];
int ADX_handle;
double ADX_Main[];
int MACD_handle;
double MACD_Main[];
double Low[];
int ATR_handle;
double ATR[];
double High[];

//Signaler v 1.4
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment5                 = "- DISABLED IN THIS VERSION -";
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";

#define ADVANCED_ALERTS

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

Signaler* signaler;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix("VT system @ " + _Symbol + "," + signaler.GetTimeframeStr() + " | ");
   signaler.SetPopupAlert(Popup_Alert);
   signaler.SetEmailAlert(Email_Alert);
   signaler.SetPlaySound(Play_Sound, Sound_File);
   signaler.SetNotificationAlert(Notification_Alert);
   signaler.SetAdvancedAlert(Advanced_Alert, Advanced_Key);

   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 241);
   SetIndexBuffer(1, Buffer2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_ARROW, 242);
   SetIndexBuffer(2, Buffer3);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(2, PLOT_ARROW, 241);
   SetIndexBuffer(3, Buffer4);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(3, PLOT_ARROW, 242);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
   {
      myPoint *= 10;
   }
   MA_handle = iMA(NULL, PERIOD_CURRENT, FastMA, 0, MODE_EMA, PRICE_CLOSE);
   if(MA_handle < 0)
   {
      Print("The creation of iMA has failed: MA_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
   }
   
   MA_handle2 = iMA(NULL, PERIOD_CURRENT, SlowMA, 0, MODE_EMA, PRICE_CLOSE);
   if(MA_handle2 < 0)
   {
      Print("The creation of iMA has failed: MA_handle2=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
   }
   
   ADX_handle = iADX(NULL, PERIOD_CURRENT, 14);
   if(ADX_handle < 0)
   {
      Print("The creation of iADX has failed: ADX_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
   }
   
   MACD_handle = iMACD(NULL, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
   if(MACD_handle < 0)
   {
      Print("The creation of iMACD has failed: MACD_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
   }
   
   ATR_handle = iATR(NULL, PERIOD_CURRENT, 14);
   if(ATR_handle < 0)
   {
      Print("The creation of iATR has failed: ATR_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete signaler;
   signaler = NULL;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   //--- initial zero
   if(prev_calculated < 1)
   {
      ArrayInitialize(Buffer1, 0);
      ArrayInitialize(Buffer2, 0);
      ArrayInitialize(Buffer3, 0);
      ArrayInitialize(Buffer4, 0);
   }
   else
      limit++;
   datetime Time[];
   
   if(CopyBuffer(MA_handle, 0, 0, rates_total, MA) <= 0) return(rates_total);
   ArraySetAsSeries(MA, true);
   if(CopyBuffer(MA_handle2, 0, 0, rates_total, MA2) <= 0) return(rates_total);
   ArraySetAsSeries(MA2, true);
   if(CopyBuffer(ADX_handle, MAIN_LINE, 0, rates_total, ADX_Main) <= 0) return(rates_total);
   ArraySetAsSeries(ADX_Main, true);
   if(CopyBuffer(MACD_handle, MAIN_LINE, 0, rates_total, MACD_Main) <= 0) return(rates_total);
   ArraySetAsSeries(MACD_Main, true);
   if(CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0) return(rates_total);
   ArraySetAsSeries(Low, true);
   if(CopyBuffer(ATR_handle, 0, 0, rates_total, ATR) <= 0) return(rates_total);
   ArraySetAsSeries(ATR, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0) return(rates_total);
   ArraySetAsSeries(High, true);
   if(CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0) return(rates_total);
   ArraySetAsSeries(Time, true);
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
   {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      //Indicator Buffer 1
      if(MA[i] > MA2[i]
         && MA[i+1] < MA2[i+1] //Moving Average crosses above Moving Average
         && ADX_Main[i] > 25 //Average Directional Movement Index > fixed value
         && MACD_Main[i] > 0 //MACD > fixed value
         )
      {
         Buffer1[i] = Low[i] - ATR[i]; //Set indicator value at Candlestick Low - Average True Range
         if(i == 1 && Time[1] != time_alert) 
         {
            signaler.SendNotifications("Buy"); //Alert on next bar open
         }
         time_alert = Time[1];
      }
      else
      {
         Buffer1[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 2
      if(MA[i] < MA2[i]
         && MA[i+1] > MA2[i+1] //Moving Average crosses below Moving Average
         && ADX_Main[i] > 25 //Average Directional Movement Index > fixed value
         && MACD_Main[i] < 0 //MACD < fixed value
         )
      {
         Buffer2[i] = High[i] + ATR[i]; //Set indicator value at Candlestick High + Average True Range
         if(i == 1 && Time[1] != time_alert)
         {
            signaler.SendNotifications("Sell"); //Alert on next bar open
         }
         time_alert = Time[1];
      }
      else
      {
         Buffer2[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 3
      if(MACD_Main[i] > 0
         && MACD_Main[i+1] < 0 //MACD crosses above fixed value
         && MA[i] > MA2[i] //Moving Average > Moving Average
         && ADX_Main[i] > 25 //Average Directional Movement Index > fixed value
         )
      {
         Buffer3[i] = Low[i] - ATR[i]; //Set indicator value at Candlestick Low - Average True Range
         if(i == 1 && Time[1] != time_alert)
         {
            signaler.SendNotifications("Buy"); //Alert on next bar open
         }
         time_alert = Time[1];
      }
      else
      {
         Buffer3[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 4
      if(MACD_Main[i] < 0
         && MACD_Main[i+1] > 0 //MACD crosses below fixed value
         && MA[i] < MA2[i] //Moving Average < Moving Average
         && ADX_Main[i] > 25 //Average Directional Movement Index > fixed value
         )
      {
         Buffer4[i] = High[i] + ATR[i]; //Set indicator value at Candlestick High + Average True Range
         if(i == 1 && Time[1] != time_alert)
         {
            signaler.SendNotifications("Sell"); //Alert on next bar open
         }
         time_alert = Time[1];
      }
      else
      {
         Buffer4[i] = EMPTY_VALUE;
      }
   }
   return(rates_total);
}
//+------------------------------------------------------------------+