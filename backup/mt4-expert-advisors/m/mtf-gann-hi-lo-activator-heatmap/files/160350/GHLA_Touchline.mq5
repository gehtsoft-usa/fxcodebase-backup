//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=153537#p153537

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
#property indicator_buffers 3
#property indicator_plots   2

#property indicator_label1   "UP"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrGreen
#property indicator_style1   STYLE_SOLID
#property indicator_width1   2

#property indicator_label2   "DN"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrRed
#property indicator_style2   STYLE_SOLID
#property indicator_width2   2


input ENUM_MA_METHOD MA_Type = MODE_SMA;
input int      Length  = 10;
double UP[], DN[];
double pdir[];

int  g_maHighHandle = INVALID_HANDLE;
int  g_maLowHandle  = INVALID_HANDLE;
int  g_lastLength   = -1;
int  g_lastMethod   = -1;
ENUM_TIMEFRAMES g_lastTF = PERIOD_CURRENT;
string g_lastSymbol = "";



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAMQL4(string symbol, int tf, int period, int ma_shift, int method, int price, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_MA_METHOD ma_method = MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price = PriceMigrate(price);
   if((symbol == _Symbol || symbol == NULL || symbol == "") && timeframe == PERIOD_CURRENT && ma_shift == 0 && period == g_lastLength && method == g_lastMethod)
     {
      int handle = (applied_price == PRICE_HIGH ? g_maHighHandle : (applied_price == PRICE_LOW ? g_maLowHandle : INVALID_HANDLE));
      if(handle != INVALID_HANDLE)
        {
         return CopyBufferMQL4(handle, 0, shift);
        }
     }
   int handle = iMA(symbol, timeframe, period, ma_shift, ma_method, applied_price);
   if(handle < 0)
     {
      Print("iMA create failed: ", GetLastError(), " price=", (int)applied_price, " tf=", (int)timeframe);
      return(EMPTY_VALUE);
     }
   double result = CopyBufferMQL4(handle, 0, shift);
   IndicatorRelease(handle);
   return result;
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
      case 0:
         return(PRICE_CLOSE);
      case 1:
         return(PRICE_OPEN);
      case 2:
         return(PRICE_HIGH);
      case 3:
         return(PRICE_LOW);
      case 4:
         return(PRICE_MEDIAN);
      case 5:
         return(PRICE_TYPICAL);
      case 6:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
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
   int copied = 0;
   switch(index)
     {
      case 0:
         copied = CopyBuffer(handle, 0, shift, 1, buf);
         if(copied > 0)
            return(buf[0]);
         else
           {
            Print("CopyBuffer failed: handle=", handle, " shift=", shift, " copied=", copied, " error=", GetLastError());
           }
         break;
      case 1:
         copied = CopyBuffer(handle, 1, shift, 1, buf);
         if(copied > 0)
            return(buf[0]);
         break;
      case 2:
         copied = CopyBuffer(handle, 2, shift, 1, buf);
         if(copied > 0)
            return(buf[0]);
         break;
      case 3:
         copied = CopyBuffer(handle, 3, shift, 1, buf);
         if(copied > 0)
            return(buf[0]);
         break;
      case 4:
         copied = CopyBuffer(handle, 4, shift, 1, buf);
         if(copied > 0)
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
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "GHLA Touchline");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   SetIndexBuffer(0, UP,   INDICATOR_DATA);
   SetIndexBuffer(1, DN,   INDICATOR_DATA);
   SetIndexBuffer(2, pdir, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(UP,   true);
   ArraySetAsSeries(DN,   true);
   ArraySetAsSeries(pdir, true);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "UP");
   PlotIndexSetString(1, PLOT_LABEL, "DN");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   g_lastSymbol = _Symbol;
   g_lastTF     = PERIOD_CURRENT;
   g_lastLength = Length;
   g_lastMethod = (int)MA_Type;
   g_maHighHandle = iMA(g_lastSymbol, g_lastTF, g_lastLength, 0, (ENUM_MA_METHOD)MA_Type, PRICE_HIGH);
   g_maLowHandle  = iMA(g_lastSymbol, g_lastTF, g_lastLength, 0, (ENUM_MA_METHOD)MA_Type, PRICE_LOW);
   if(g_maHighHandle == INVALID_HANDLE || g_maLowHandle == INVALID_HANDLE)
     {
      Print("Failed to create MA handles: high=", g_maHighHandle, " low=", g_maLowHandle, " err=", GetLastError());
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(open, true);
   if(rates_total <= 3)
      return 0;
   if(g_lastLength != Length || g_lastMethod != (int)MA_Type)
     {
      if(g_maHighHandle != INVALID_HANDLE)
         IndicatorRelease(g_maHighHandle);
      if(g_maLowHandle != INVALID_HANDLE)
         IndicatorRelease(g_maLowHandle);
      g_lastLength = Length;
      g_lastMethod = (int)MA_Type;
      g_maHighHandle = iMA(_Symbol, PERIOD_CURRENT, g_lastLength, 0, (ENUM_MA_METHOD)MA_Type, PRICE_HIGH);
      g_maLowHandle  = iMA(_Symbol, PERIOD_CURRENT, g_lastLength, 0, (ENUM_MA_METHOD)MA_Type, PRICE_LOW);
     }
   int barsHigh = BarsCalculated(g_maHighHandle);
   int barsLow  = BarsCalculated(g_maLowHandle);
   if(barsHigh <= 0 || barsLow <= 0)
      return prev_calculated;
   int limit = rates_total - 2;
   if(prev_calculated > 2)
      limit = rates_total - prev_calculated - 1;
   if(limit + 1 < rates_total && (prev_calculated <= 2))
      pdir[limit + 1] = 0.0;
   int effectiveLimit = limit;
   effectiveLimit = MathMin(effectiveLimit, barsHigh - 1);
   effectiveLimit = MathMin(effectiveLimit, barsLow - 1);
   if(effectiveLimit < 0)
      return prev_calculated;
   int pos = effectiveLimit;
   while(pos >= 0)
     {
      double AvgHigh = iMAMQL4(_Symbol, 0, Length, 0, (int)MA_Type, 2, pos);
      double AvgLow  = iMAMQL4(_Symbol, 0, Length, 0, (int)MA_Type, 3, pos);
      int Switch = 0;
      if(close[pos] > AvgHigh)
        {
         Switch = 1;
        }
      else
         if(close[pos] < AvgLow)
           {
            Switch = -1;
           }
      if(Switch != 0)
        {
         pdir[pos] = (double)Switch;
        }
      else
        {
         pdir[pos] = (pos + 1 < rates_total ? pdir[pos + 1] : 0.0);
        }
      if(pdir[pos] < 0.0)
        {
         UP[pos] = AvgHigh;
         DN[pos] = AvgHigh;
        }
      else
        {
         UP[pos] = AvgLow;
         DN[pos] = EMPTY_VALUE;
        }
      --pos;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=153537#p153537

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