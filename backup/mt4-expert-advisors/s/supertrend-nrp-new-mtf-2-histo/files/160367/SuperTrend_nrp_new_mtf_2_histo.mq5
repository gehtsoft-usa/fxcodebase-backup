//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76272 

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


#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrOrange
#property indicator_width1 2
#property indicator_width2 2
#property indicator_minimum 0
#property indicator_maximum 1

input int                ATRperiod       = 10;
input ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE;
input double             multiplier   = 3.0;
input ENUM_TIMEFRAMES    inpTimeFrame    = PERIOD_CURRENT; //default chart TF
input int                BarLimit     = 1000;
double TrendUp[];
double TrendDo[];
double Direction[];
double Up[];
double Dn[];
ENUM_TIMEFRAMES TimeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   if(inpTimeFrame == PERIOD_CURRENT || inpTimeFrame <= Period())
      TimeFrame = Period();
   else
     {
      TimeFrame = inpTimeFrame;
      EventSetMillisecondTimer(500);
     }
   SetIndexBuffer(0, TrendUp, INDICATOR_DATA);
   SetIndexBuffer(1, TrendDo, INDICATOR_DATA);
   SetIndexBuffer(2, Direction, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, Up, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, Dn, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(TrendUp, true);
   ArraySetAsSeries(TrendDo, true);
   ArraySetAsSeries(Direction, true);
   ArraySetAsSeries(Up, true);
   ArraySetAsSeries(Dn, true);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetString(0, PLOT_LABEL, "Trend Up");
   PlotIndexSetString(1, PLOT_LABEL, "Trend Down");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
   IndicatorSetString(INDICATOR_SHORTNAME, "SuperTrend MTF");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ChartSetSymbolPeriod(ChartID(), _Symbol, Period());
   ChartRedraw();
  }


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
   int counted_bars = prev_calculated;
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = MathMin(rates_total, BarLimit);
   ArrayInitialize(TrendUp, 0);
   ArrayInitialize(TrendDo, 0);
   for(int i = limit - 1; i >= 0; i--)
     {
      datetime barTime = iTime(_Symbol, Period(), i);
      int y = iBarShift(_Symbol, TimeFrame, barTime);
      if(y < 0)
         y = 0;
      double atr    = iATRMQL4(_Symbol, TimeFrame, ATRperiod, y);
      double cprice = iMAMQL4(_Symbol, TimeFrame, 1, 0, MODE_SMA, appliedPrice, y);
      double mprice = (iHigh(NULL, TimeFrame, y) + iLow(NULL, TimeFrame, y)) / 2;
      Up[i]  = mprice + multiplier * atr;
      Dn[i]  = mprice - multiplier * atr;
       Direction[i] = Direction[i + 1];
      if(cprice > Up[i + 1])
         Direction[i] =  1;
      if(cprice < Dn[i + 1])
         Direction[i] = -1;
      TrendUp[i] = 0;
      TrendDo[i] = 0;
      if(Direction[i] > 0)
        {
         Dn[i] = MathMax(Dn[i], Dn[i + 1]);
          TrendUp[i] = 1;
        }
      else
        {
         Up[i] = MathMin(Up[i], Up[i + 1]);
          TrendDo[i] = 1;
        }
           }
   return(rates_total);
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
double iMAMQL4(string symbol, int tf, int period, int ma_shift, int method, int price, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_MA_METHOD ma_method = MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price = PriceMigrate(price);
   int handle = iMA(symbol, timeframe, period, ma_shift,
                    ma_method, applied_price);
   if(handle < 0)
     {
      Print("The iMA object is not created: Error", GetLastError());
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
   ArraySetAsSeries(buf, true);
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
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0:
         return(MODE_SMA);
      case 1:
         return(MODE_EMA);
      case 2:
         return(MODE_SMMA);
      case 3:
         return(MODE_LWMA);
      default:
         return(MODE_SMA);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1:
         return(PRICE_CLOSE);
      case 2:
         return(PRICE_OPEN);
      case 3:
         return(PRICE_HIGH);
      case 4:
         return(PRICE_LOW);
      case 5:
         return(PRICE_MEDIAN);
      case 6:
         return(PRICE_TYPICAL);
      case 7:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76272 

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