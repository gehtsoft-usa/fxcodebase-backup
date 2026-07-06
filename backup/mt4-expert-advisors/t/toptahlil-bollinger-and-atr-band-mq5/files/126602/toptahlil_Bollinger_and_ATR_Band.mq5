// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68471

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
#property indicator_buffers 6
#property indicator_plots 6
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 Yellow
#property indicator_color4 Yellow
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
#property indicator_style4  STYLE_SOLID
//Signaler v 1.6
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
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll and cpprest141_2_10.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
//#import "AdvancedNotificationsLib.dll"
//void AdvancedAlert(string key, string text, string instrument, string timeframe);
//#import

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

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

   void SendNotifications(const int direction)
   {
      if (direction == 0 || MQLInfoInteger(MQL_TESTER))
         return;

      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            alert_Subject = "Buy signal on " + _symbol + "/" + tf;
            alert_Body = "Buy signal on " + _symbol + "/" + tf;
            break;
         case ENTER_SELL_SIGNAL:
            alert_Subject = "Sell signal on " + _symbol + "/" + tf;
            alert_Body = "Sell signal on " + _symbol + "/" + tf;
            break;
         case EXIT_BUY_SIGNAL:
            alert_Subject = "Exit buy signal on " + _symbol + "/" + tf;
            alert_Body = "Exit buy signal on " + _symbol + "/" + tf;
            break;
         case EXIT_SELL_SIGNAL:
            alert_Subject = "Exit sell signal on " + _symbol + "/" + tf;
            alert_Body = "Exit sell signal on " + _symbol + "/" + tf;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _symbol, tf);
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
      //if (Advanced_Alert && Advanced_Key != "")
      //   AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

   void SendNotifications(const string message)
   {
      SendNotifications("Alert", message, _symbol, GetTimeframe());
   }

private:
   string GetTimeframe()
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
//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+
input double ATRMult=2;
input int ATR_Period=10;
input int Band_Period=20;
input double  Band_Diviations=3;
input int Band_Shift=0;
input ENUM_APPLIED_PRICE Band_ApplyPrice=PRICE_MEDIAN;

//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+
int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];
double ExtHistoBuffer3[];
double ExtHistoBuffer4[], _up[], _down[];
int _bbhandle;
int _atrhandle;
Signaler* signaler;

int OnInit()
{
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(0, ExtHistoBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, indicator_style1);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, indicator_color1);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 1);

   SetIndexBuffer(1, ExtHistoBuffer2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, indicator_style2);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, indicator_color2);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 1);

   SetIndexBuffer(2, ExtHistoBuffer3, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, indicator_style3);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, indicator_color3);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 1);
   
   SetIndexBuffer(3, ExtHistoBuffer4, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, indicator_style4);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, indicator_color4);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);

   SetIndexBuffer(4, _up, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(4, PLOT_ARROW, 233);
   PlotIndexSetString(4, PLOT_LABEL, "Up");

   SetIndexBuffer(5, _down, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(5, PLOT_ARROW, 234);
   PlotIndexSetString(5, PLOT_LABEL, "Down");

   _bbhandle = iBands(_Symbol, Period(), Band_Period, Band_Shift, Band_Diviations, Band_ApplyPrice); 
   _atrhandle = iATR(_Symbol, Period(), ATR_Period); 

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete signaler;
   signaler = NULL;
   IndicatorRelease(_bbhandle);
   IndicatorRelease(_atrhandle);
}

datetime last_alert;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated == 0)
   {
      ArrayInitialize(ExtHistoBuffer, EMPTY_VALUE);
      ArrayInitialize(ExtHistoBuffer2, EMPTY_VALUE);
      ArrayInitialize(ExtHistoBuffer3, EMPTY_VALUE);
      ArrayInitialize(ExtHistoBuffer4, EMPTY_VALUE);
      ArrayInitialize(_up, EMPTY_VALUE);
      ArrayInitialize(_down, EMPTY_VALUE);
   }
   int start = MathMax(0, rates_total - 1 - prev_calculated);
   for (int shift = start; shift >= 0; shift--)
   {
      double up[1];
      if (CopyBuffer(_bbhandle, UPPER_BAND, shift, 1, up) != 1 && up[0] != EMPTY_VALUE)
         continue;
      double down[1];
      if (CopyBuffer(_bbhandle, LOWER_BAND, shift, 1, down) != 1 && down[0] != EMPTY_VALUE)
         continue;

      double atr[1];
      if (CopyBuffer(_atrhandle, 0, shift, 1, atr) != 1 && atr[0] != EMPTY_VALUE)
         continue;

      double KU = up[0] + ATRMult * atr[0];
      double KL = down[0] - ATRMult * atr[0];
      int period = rates_total - 1 - shift;
      ExtHistoBuffer[period] = KU;
      ExtHistoBuffer2[period] = KL;
      ExtHistoBuffer3[period] = up[0];
      ExtHistoBuffer4[period] = down[0];

      if (high[period] > up[0])
         _up[period] = high[period];
      else
         _up[period] = EMPTY_VALUE;
      if (low[period] < down[0])
         _down[period] = low[period];
      else
         _down[period] = EMPTY_VALUE;
      if (shift == 0 && last_alert != time[period])
      {
         if (_up[period] != EMPTY_VALUE && _up[period - 1] == EMPTY_VALUE)
         {
            signaler.SendNotifications("Price crossed over top BB line on " + _Symbol);
            last_alert = time[period];
         }
         else if (_down[period] != EMPTY_VALUE && _down[period - 1] == EMPTY_VALUE)
         {
            signaler.SendNotifications("Price crossed under bottom BB line on " + _Symbol);
            last_alert = time[period];
         }
      }
   }
      
   return rates_total;
}
//+------------------------------------------------------------------+
