// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75974

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
//
#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   11

input int InpTrendLength = 10;
input int InpTarget = 0;
input int barsLimit = 500;

double UpTrendBuffer[];
double DownTrendBuffer[];
double TrendValueBuffer[];
double TrendSignalUp[];
double TrendSignalDn[];
double UpColorCandle[];
double DownColorCandle[];
double ATRBuffer[];
double ATRSMABuffer[];
double SmaHighBuffer[];
double SmaLowBuffer[];
bool   TrendArrayBuffer[];
double TrendRawBuffer[];

color clrUp = clrTurquoise;
color clrDn = clrOrange;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, UpTrendBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DownTrendBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, TrendValueBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, TrendSignalUp, INDICATOR_DATA);
   SetIndexBuffer(4, TrendSignalDn, INDICATOR_DATA);
   SetIndexBuffer(5, UpColorCandle, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6, DownColorCandle, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7, ATRBuffer, INDICATOR_DATA);
   SetIndexBuffer(8, ATRSMABuffer, INDICATOR_DATA);
   SetIndexBuffer(9, SmaHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(10, SmaLowBuffer, INDICATOR_DATA);
   SetIndexBuffer(11, TrendRawBuffer, INDICATOR_DATA);
//
   ArraySetAsSeries(TrendArrayBuffer, true);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(3, PLOT_ARROW, 233);
   PlotIndexSetInteger(4, PLOT_ARROW, 234);
//
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
//
   PlotIndexSetString(0, PLOT_LABEL, "Up Trend");
   PlotIndexSetString(1, PLOT_LABEL, "Down Trend");
   PlotIndexSetString(2, PLOT_LABEL, "Trend Value");
   PlotIndexSetString(3, PLOT_LABEL, "Signal Up");
   PlotIndexSetString(4, PLOT_LABEL, "Signal Down");
   PlotIndexSetString(5, PLOT_LABEL, "Bull Candle");
   PlotIndexSetString(6, PLOT_LABEL, "Bear Candle");
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrUp);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrDn);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, clrGray);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, clrUp);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, clrDn);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, clrUp);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, clrDn);
   return(INIT_SUCCEEDED);
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
   ArrayResize(UpTrendBuffer, rates_total);
   ArrayResize(DownTrendBuffer, rates_total);
   ArrayResize(TrendValueBuffer, rates_total);
   ArrayResize(TrendSignalUp, rates_total);
   ArrayResize(TrendSignalDn, rates_total);
   ArrayResize(UpColorCandle, rates_total);
   ArrayResize(DownColorCandle, rates_total);
   ArrayResize(ATRBuffer, rates_total);
   ArrayResize(ATRSMABuffer, rates_total);
   ArrayResize(SmaHighBuffer, rates_total);
   ArrayResize(SmaLowBuffer, rates_total);
   ArrayResize(TrendArrayBuffer, rates_total);
   ArrayResize(TrendRawBuffer, rates_total);
//
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
//
   ArraySetAsSeries(ATRBuffer, true);
   ArraySetAsSeries(ATRSMABuffer, true);
   ArraySetAsSeries(SmaHighBuffer, true);
   ArraySetAsSeries(SmaLowBuffer, true);
   ArraySetAsSeries(TrendValueBuffer, true);
   ArraySetAsSeries(UpTrendBuffer, true);
   ArraySetAsSeries(DownTrendBuffer, true);
   ArraySetAsSeries(TrendSignalUp, true);
   ArraySetAsSeries(TrendSignalDn, true);
   ArraySetAsSeries(UpColorCandle, true);
   ArraySetAsSeries(DownColorCandle, true);
   ArraySetAsSeries(TrendRawBuffer, true);
   if(rates_total < 220)
      return(0);
      int limit = MathMin(rates_total,barsLimit);
   for(int i = 0; i < limit; i++)
      ATRBuffer[i] = iATRMQL4(NULL, 0, 200, i);
   SimpleMAOnBuffer(ATRBuffer, ATRSMABuffer, 200, rates_total);
   for(int i = 0; i < limit; i++)
     {
      int shift = i;
      double atr_val = (ATRSMABuffer[shift] > 0) ? ATRSMABuffer[shift] * 0.8 : 0.0;
      SmaHighBuffer[shift] = iMAMQL4(NULL, 0, InpTrendLength, 0, MODE_SMA, MODE_HIGH, shift) + atr_val;
      SmaLowBuffer[shift]  = iMAMQL4(NULL, 0, InpTrendLength, 0, MODE_SMA, MODE_LOW, shift) - atr_val;
     }
   for(int i = 0; i < limit; i++)
      TrendArrayBuffer[i] = false;
   TrendArrayBuffer[0] = false;
   for(int i = 1; i < limit; i++)
     {
      int shift = i;
      TrendArrayBuffer[shift] = TrendArrayBuffer[shift - 1];
      if(close[shift] > SmaHighBuffer[shift] && close[shift - 1] <= SmaHighBuffer[shift - 1])
         TrendArrayBuffer[shift] = true;
      if(close[shift] < SmaLowBuffer[shift] && close[shift - 1] >= SmaLowBuffer[shift - 1])
         TrendArrayBuffer[shift] = false;
     }
   for(int i = 0; i < limit; i++)
     {
      int shift = i;
      if(TrendArrayBuffer[shift])
        {
         UpTrendBuffer[shift] = SmaLowBuffer[shift];
         DownTrendBuffer[shift] = EMPTY_VALUE;
         TrendValueBuffer[shift] = SmaLowBuffer[shift];
         UpColorCandle[shift] = 1;
         DownColorCandle[shift] = EMPTY_VALUE;
        }
      else
        {
         UpTrendBuffer[shift] = EMPTY_VALUE;
         DownTrendBuffer[shift] = SmaHighBuffer[shift];
         TrendValueBuffer[shift] = SmaHighBuffer[shift];
         UpColorCandle[shift] = EMPTY_VALUE;
         DownColorCandle[shift] = 1;
        }
      if(shift > 0)
        {
         TrendSignalUp[shift] = (TrendArrayBuffer[shift] && !TrendArrayBuffer[shift - 1]) ? low[shift] - ATRSMABuffer[shift] * 1.6 : EMPTY_VALUE;
         TrendSignalDn[shift] = (!TrendArrayBuffer[shift] && TrendArrayBuffer[shift - 1]) ? high[shift] + ATRSMABuffer[shift] * 1.6 : EMPTY_VALUE;
        }
      else
        {
         TrendSignalUp[shift] = EMPTY_VALUE;
         TrendSignalDn[shift] = EMPTY_VALUE;
        }
      TrendRawBuffer[shift] = (double)TrendArrayBuffer[shift];
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimpleMAOnBuffer(const double &in[], double &out[], int period, int bars)
  {
   for(int i = 0; i < bars; i++)
     {
      double sum = 0;
      int cnt = 0;
      for(int j = 0; j < period && (i + j) < bars; j++)
        {
         sum += in[i + j];
         cnt++;
        }
      out[i] = (cnt > 0) ? sum / cnt : 0;
     }
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
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75974

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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