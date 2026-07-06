// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70737

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
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red

input ENUM_MA_METHOD method = MODE_SMA; // Smoothing method
input int Period1 = 14; // MA Period
input int Period2 = 14; // Min Max Period
input double Delta = 10; // Delta (In Pips)
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

double dm[], du[], dn[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("mvamm");
   IndicatorShortName("MVA Min Max");

   IndicatorBuffers(3);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, dm);
   SetIndexLabel(id, "DM");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, du);
   SetIndexLabel(id, "DU");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, dn);
   SetIndexLabel(id, "DN");
   ++id;

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
      ArrayInitialize(dm, EMPTY_VALUE);
      ArrayInitialize(du, EMPTY_VALUE);
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

   int toSkip = Period2;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      dm[pos] = iMA(_Symbol, _Period, Period1, 0, method, PRICE_CLOSE, pos);
      if (dm[pos + Period2] == EMPTY_VALUE)
      {
         continue;
      }
      int lowestIndex = ArrayMinimum(dm, Period2, pos);
      double min = dm[lowestIndex];
      int highestIndex = ArrayMaximum(dm, Period2, pos);
      double max = dm[highestIndex];
      du[pos] = max + Delta * pipSize;
      dn[pos] = min - Delta * pipSize;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
