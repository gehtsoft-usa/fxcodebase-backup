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
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Green

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input double channel_width = 10; // Channel width, pips
input int period = 14; // MA period
input ENUM_MA_METHOD method = MODE_SMA; // Smoothing method
input ENUM_APPLIED_PRICE price = PRICE_CLOSE; // Price type
input int shift = 0; // Shift
input int bars_limit = 1000; // Bars limit

double ma[], up[], dn[];

int init()
{
   IndicatorShortName("MA Channel");
   IndicatorDigits(Digits);
   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ma);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, up);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, dn);

   return 0;
}

int deinit()
{
   return 0;
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
      ArrayInitialize(ma, EMPTY_VALUE);
      ArrayInitialize(up, EMPTY_VALUE);
      ArrayInitialize(dn, EMPTY_VALUE);
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

   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      int index = iBarShift(_Symbol, tf, time[pos]);
      if (index < 0)
      {
         continue;
      }
      ma[pos] = iMA(_Symbol, tf, period, shift, method, price, index);
      up[pos] = ma[pos] + channel_width * pipSize;
      dn[pos] = ma[pos] - channel_width * pipSize;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
