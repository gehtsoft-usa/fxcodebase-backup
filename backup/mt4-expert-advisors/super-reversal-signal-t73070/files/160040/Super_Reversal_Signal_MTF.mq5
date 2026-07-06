// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=153514#p153514

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property indicator_chart_window
#property indicator_buffers 4
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
input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Timeframe for the indicator
input int BarLimit = 1000;
input bool ArrowOnlyTrendChange = true;
input int    LagBar      = 1;
input string NoteLagBar  = "0 = Signal on current ; 1 = Wait for close";
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
//+------------------------------------------------------------------------------------------------+

double ArrowsUp[];
double ArrowsDn[];
double body[];
double trend[];
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
   SetIndexBuffer(1, ArrowsUp, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, 0);
   PlotIndexSetString(1, PLOT_LABEL, "Trendsignal Buy");
   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   ArraySetAsSeries(ArrowsUp, true);
   SetIndexBuffer(0, ArrowsDn, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
   PlotIndexSetString(0, PLOT_LABEL, "Trendsignal Sell");
   PlotIndexSetInteger(0, PLOT_ARROW, 234);
   ArraySetAsSeries(ArrowsDn, true);
   SetIndexBuffer(2, body, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(body, true);
   SetIndexBuffer(3, trend, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(trend, true);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   string short_name = "Trendsignal";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
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
   
   int i, limit;
   int tr = 0;
   limit = MathMin(iBars(Symbol(), Period()) - 4, BarLimit);
    int mtfShift;

   for(i=limit; i>=0; i--)
   {
       mtfShift = iBarShift(NULL, TimeFrame, iTime(Symbol(), Period(), i));
      
      double gap = 3.0*iATRMQL4(NULL,Period(),20,i)/4.0;
      
      double mtfOpen = iOpen(NULL, TimeFrame, mtfShift);
      double mtfClose = iClose(NULL, TimeFrame, mtfShift);
      double mtfHigh = iHigh(NULL, TimeFrame, mtfShift);
      double mtfLow = iLow(NULL, TimeFrame, mtfShift);
      
      double mtfOpen1 = iOpen(NULL, TimeFrame, mtfShift+1);
      double mtfClose1 = iClose(NULL, TimeFrame, mtfShift+1);
      
      double mtfOpen2 = iOpen(NULL, TimeFrame, mtfShift+2);
      double mtfClose2 = iClose(NULL, TimeFrame, mtfShift+2);
      double mtfHigh2 = iHigh(NULL, TimeFrame, mtfShift+2);
      double mtfLow2 = iLow(NULL, TimeFrame, mtfShift+2);
      
      double mtfOpen3 = iOpen(NULL, TimeFrame, mtfShift+3);
      double mtfClose3 = iClose(NULL, TimeFrame, mtfShift+3);
      
      double mtfOpen4 = iOpen(NULL, TimeFrame, mtfShift+4);
      double mtfClose4 = iClose(NULL, TimeFrame, mtfShift+4);

      body[i] = MathAbs(mtfOpen-mtfClose);
      
      double body1 = MathAbs(mtfOpen1-mtfClose1);
      double body2 = MathAbs(mtfOpen2-mtfClose2);
      double body3 = MathAbs(mtfOpen3-mtfClose3);
      double body4 = MathAbs(mtfOpen4-mtfClose4);

      trend[i] =  0.0;

      if((mtfHigh2 < mtfLow) && (body1 > body2) && (body1 > body3) && (body1 > body4) && (iVolume(NULL,TimeFrame,mtfShift-LagBar)>1))
      {
         trend[i] = 1;
      }
      if((mtfLow2 > mtfHigh) && (body1 > body2) && (body1 > body3) && (body1 > body4) && (iVolume(NULL,TimeFrame,mtfShift-LagBar)>1))
      {
         trend[i] =- 1;
      }

      ArrowsUp[i] =  EMPTY_VALUE;
      ArrowsDn[i] =  EMPTY_VALUE;

      if (trend[i] != trend[i+1])
      {
         if (trend[i] == 1)
         ArrowsUp[i] =iLow(Symbol(),Period(),i) - gap;
        
         else if (trend[i] ==- 1)
         ArrowsDn[i] = iHigh(Symbol(),Period(),i) + gap;
         
      }

   }
   if(ArrowsUp[1] != EMPTY_VALUE)
     {
      Notifications(0);
     }
   if(ArrowsDn[1] != EMPTY_VALUE)
     {
      Notifications(1);
     }
    return (rates_total);
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iATRMQL4(string symbol, int tf, int period, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   int handle = iATR(symbol, timeframe, period);
   if(handle < 0)
     {
      Print("The iATR object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=153514#p153514

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+