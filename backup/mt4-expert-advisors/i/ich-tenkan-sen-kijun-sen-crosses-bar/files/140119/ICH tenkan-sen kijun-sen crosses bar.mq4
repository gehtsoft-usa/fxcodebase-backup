// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70802

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_minimum 0

input int tenkan_sen = 9; // Tenkan sen
input int kijun_sen = 26; // Kijun sen
input int senkou_span_b = 52; // Senkou span b
input int bars_limit = 100000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double up[], down[], neutral[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("ichtskscb");
   IndicatorShortName("ICH tenkan-sen & kijun-sen crosses bar");

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, up);
   SetIndexLabel(0, "Up");
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, down);
   SetIndexLabel(1, "Down");
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(2, neutral);
   SetIndexLabel(2, "Neutral");

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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
      ArrayInitialize(up, EMPTY_VALUE);
      ArrayInitialize(down, EMPTY_VALUE);
      ArrayInitialize(neutral, EMPTY_VALUE);
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

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double ich0 = iIchimoku(_Symbol, _Period, tenkan_sen, kijun_sen, senkou_span_b, MODE_TENKANSEN, pos);
      double ich1 = iIchimoku(_Symbol, _Period, tenkan_sen, kijun_sen, senkou_span_b, MODE_KIJUNSEN, pos);
      if (ich0 > ich1)
      {
         down[pos] = 1;
      }
      else if (ich0 < ich1)
      {
         up[pos] = 1;
      }
      else
      {
         neutral[pos] = 1;
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
