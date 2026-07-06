// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70408

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
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_label1  "PB Line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_label2  "+ RMS Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Green
#property indicator_label3  "- RMS Line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  Red

input int Period1 = 40; // Period 1
input int Period2 = 60; // Period 2
input int Average = 50; // Average Period

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

double PB[], PRMS[], NRMS[];
double a1, a2;

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("spf");
   IndicatorShortName("Super Passband Filter");

   IndicatorBuffers(3);

   a1 = 5.0 / Period1;
   a2 = 5.0 / Period2;

   int id = 0;
   SetIndexBuffer(id, PB);
   SetIndexEmptyValue(id++, 0);
   SetIndexBuffer(id++, PRMS);
   SetIndexBuffer(id++, NRMS);

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
      ArrayInitialize(PB, 0);
      ArrayInitialize(PRMS, EMPTY_VALUE);
      ArrayInitialize(NRMS, EMPTY_VALUE);
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

   int toSkip = Average;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      PB[pos] = (a1 - a2) * close[pos] + (a2 * (1 - a1) - a1 * (1 - a2)) * close[pos + 1] + ((1 - a1) + (1 - a2)) * PB[pos + 1] - (1 - a1) * (1 - a2) * PB[pos + 2];
      double RMS = 0;
      for (int count = 0; count < Average; ++count)
      {
         RMS += MathPow(PB[pos + count], 2);
      }
      RMS = MathSqrt(RMS / Average);
      PRMS[pos] = RMS;
      NRMS[pos] = -RMS;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
