// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71766

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 

#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_type1  DRAW_ARROW
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_label1 "Trendsignal Sell"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 Lime
#property indicator_width2 2
#property indicator_label2 "Trendsignal Buy"

//+------------------------------------------------------------------------------------------------+

input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
//+------------------------------------------------------------------------------------------------+

double SellBuffer[];
double BuyBuffer[];
string message;

// NOTE: Objects
// ------------------------------------------------------------------
class CNewCandle
  {
private:
   int               _initialCandles;
   string            _symbol;
   ENUM_TIMEFRAMES   _tf;

public:
                     CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
                     CNewCandle()
     {
      // toma los valores del chart actual
      _initialCandles = iBars(Symbol(), Period());
      _symbol         = Symbol();
      _tf             = Period();
     }
                    ~CNewCandle() { ; }

   bool              IsNewCandle()
     {
      int _currentCandles = iBars(_symbol, _tf);
      if(_currentCandles > _initialCandles)
        {
         _initialCandles = _currentCandles;
         return true;
        }
      return false;
     }
  };
CNewCandle newCandle();

//+------------------------------------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(1, BuyBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, 0);
   PlotIndexSetString(1, PLOT_LABEL, "Trendsignal Buy");
   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   ArraySetAsSeries(BuyBuffer, true);
   SetIndexBuffer(0, SellBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
   PlotIndexSetString(0, PLOT_LABEL, "Trendsignal Sell");
   PlotIndexSetInteger(0, PLOT_ARROW, 234);
   ArraySetAsSeries(SellBuffer, true);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   string short_name = "Trendsignal";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
  {
   int lookback = 3;
   int tr = 0;
// for(int i=1000; i>=LagBar; i--)
   for(int i = Bars(_Symbol, PERIOD_CURRENT) - 1 - MathMax(lookback, prev_calculated); i >= 0; --i)
     {
      BuyBuffer[i]  = EMPTY_VALUE;
      SellBuffer[i] = EMPTY_VALUE;
      if(iHigh(Symbol(), Period(), i + 1) < iLow(Symbol(), Period(), i - 1) &&
         MathAbs(iOpen(Symbol(), Period(), i) - iClose(Symbol(), Period(), i)) > MathAbs(iOpen(Symbol(), Period(), i + 1) - iClose(Symbol(), Period(), i + 1)) &&
         MathAbs(iOpen(Symbol(), Period(), i) - iClose(Symbol(), Period(), i)) > MathAbs(iOpen(Symbol(), Period(), i + 2) - iClose(Symbol(), Period(), i + 2)) &&
         MathAbs(iOpen(Symbol(), Period(), i) - iClose(Symbol(), Period(), i)) > MathAbs(iOpen(Symbol(), Period(), i + 3) - iClose(Symbol(), Period(), i + 3)))
        {
         if(tr == 0 || tr == -1)
           {
            BuyBuffer[i] = iLow(Symbol(), Period(), i);
            tr = 1;
            if(newCandle.IsNewCandle())
              {
               Notifications(0);
              }
           }
        }
      if(iLow(Symbol(), Period(), i + 1) > iHigh(Symbol(), Period(), i - 1) &&
         MathAbs(iOpen(Symbol(), Period(), i) - iClose(Symbol(), Period(), i)) > MathAbs(iOpen(Symbol(), Period(), i + 1) - iClose(Symbol(), Period(), i + 1)) &&
         MathAbs(iOpen(Symbol(), Period(), i) - iClose(Symbol(), Period(), i)) > MathAbs(iOpen(Symbol(), Period(), i + 2) - iClose(Symbol(), Period(), i + 2)) &&
         MathAbs(iOpen(Symbol(), Period(), i) - iClose(Symbol(), Period(), i)) > MathAbs(iOpen(Symbol(), Period(), i + 3) - iClose(Symbol(), Period(), i + 3)))
        {
         if(tr == 0 || tr == 1)
           {
            SellBuffer[i] = iHigh(Symbol(), Period(), i);
            tr = -1;
            if(newCandle.IsNewCandle())
              {
               Notifications(1);
              }
           }
        }
     }
   return (rates_total - 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type)
  {
   string text = "";
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";
   text += " ";
   if(!notifications)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }

// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71766

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 
