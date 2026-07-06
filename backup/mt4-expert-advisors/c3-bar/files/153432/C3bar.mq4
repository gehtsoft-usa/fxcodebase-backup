// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74378

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
//
#property indicator_chart_window
#property indicator_buffers 4
//
input color BarColor = clrOrange;                           // Color of signal bar
input bool   desktop_notifications = true;                  // Desktop MT4 notifications
double Bar1[], Bar2[], Candle1[], Candle2[];
string iName = "Custom 3 bars pattern";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName(iName);
   IndicatorDigits(Digits);
   SetIndexBuffer(0, Bar1);
   SetIndexBuffer(1, Bar2);
   SetIndexBuffer(2, Candle1);
   SetIndexBuffer(3, Candle2);
   int width = calculateWidth();
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, BarColor);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1, BarColor);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0, width, BarColor);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0, width, BarColor);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      int width = calculateWidth();
      SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, BarColor);
      SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1, BarColor);
      SetIndexStyle(2, DRAW_HISTOGRAM, 0, width, BarColor);
      SetIndexStyle(3, DRAW_HISTOGRAM, 0, width, BarColor);
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int calculateWidth()
  {
   int chartScale = (int)ChartGetInteger(0, CHART_SCALE, 0);
   switch(chartScale)
     {
      case 4:
         return(6);
         break;
      case 5:
         return(14);
         break;
     }
   return(chartScale);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   bool pat;
   if(Bars <= 4)
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if(ExtCountedBars < 0)
      return(-1);
   int    pos = Bars - 3;
   if(ExtCountedBars > 2)
      pos = Bars - ExtCountedBars - 1;
   while(pos >= 0)
     {
      pat = false;
      if(Open[pos + 2] < Close[pos + 2] && Open[pos + 1] > Close[pos + 1] && Open[pos] < Close[pos] && Close[pos] > High[pos + 1])
         pat = true;
      if(Open[pos + 2] > Close[pos + 2] && Open[pos + 1] < Close[pos + 1] && Open[pos] > Close[pos] && Close[pos] < Low[pos + 1])
         pat = true;
      if(pat)
        {
         SetCandleColor(pos, true);
         if(pos == 1 && desktop_notifications)
           {
            if(Open[1] < Close[1])
               Alert(iName + ": Bullish Pattern");
            if(Open[1] > Close[1])
               Alert(iName + ": Bearish Pattern");
           }
        }
      else
        {
         SetCandleColor(pos, false);
        }
      pos--;
     }
   return(0);
  }
//+------------------------------------------------------------------+
void SetCandleColor(int i, bool coloring)
  {
   double high, low, bodyHigh, bodyLow;
//---
   bodyHigh = MathMax(Open[i], Close[i]);
   bodyLow = MathMin(Open[i], Close[i]);
   high = High[i];
   low = Low[i];
//---
   Bar1[i]    = EMPTY_VALUE;
   Bar2[i]    = EMPTY_VALUE;
   Candle1[i] = EMPTY_VALUE;
   Candle2[i] = EMPTY_VALUE;
//---
   if(!coloring)
      return;
   Bar1[i] = high;
   Bar2[i] = low;
   Candle1[i] = bodyHigh;
   Candle2[i] = bodyLow;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+