// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70700

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

// based on version Kalenzo bartlomiej.gorski@gmail.com

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Orange
#property indicator_color3 Lime

#property indicator_width1 2
#property indicator_width2 0 
#property indicator_width3 3

input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Timeframe
input int    RsiPeriod        = 5;
input int    MaType           = MODE_EMA;
input int    MaPeriod         = 3;
input bool   Interpolate      = true;
input int bars_limit = 10000; // Bars limit

double rsi[],ema[],trend[];

string indicatorFileName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   
   IndicatorBuffers(4);      
   SetIndexBuffer(0,rsi);     SetIndexLabel(0,"rsi");
   SetIndexBuffer(1,ema);     SetIndexLabel(1,"ema");
   SetIndexBuffer(2,trend);   SetIndexLabel(2,"trend");
   
   indicatorFileName = WindowExpertName();
   IndicatorShortName("RK-ml-RSI_EMA_mtf v1.2");
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }


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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(rsi, EMPTY_VALUE);
      ArrayInitialize(ema, EMPTY_VALUE);
      ArrayInitialize(trend, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = RsiPeriod;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      rsi[pos] = iRSI(NULL, 0, RsiPeriod, PRICE_CLOSE, pos);
      ema[pos] = iMAOnArray(rsi, 0, MaPeriod, 0, MaType, pos);
      if (rsi[pos] > ema[pos])
      {
         trend[pos] = 1;
      }
      else
      {
         trend[pos] = -1;
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
