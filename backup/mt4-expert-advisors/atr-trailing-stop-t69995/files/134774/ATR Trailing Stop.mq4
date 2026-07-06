
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69995

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
//#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

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

double FUB[], FLB[], out[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("atrts");
   IndicatorShortName("ATR Trailing Stop");

   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "ATRTS");
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, FUB);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, FLB);

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

input int period = 5; // Period;
input double coeff = 3.5; // Coeff

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
      ArrayInitialize(out, EMPTY_VALUE);
      ArrayInitialize(FUB, EMPTY_VALUE);
      ArrayInitialize(FLB, EMPTY_VALUE);
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

   int toSkip = 1;
   for (int pos = rates_total - 1 - toSkip; pos >= 0; --pos)
   {
      double atrValue = iATR(_Symbol, _Period, period, pos);
      double OFFSET = coeff * atrValue;
      double STR = close[pos] + OFFSET;
      double STS = close[pos] - OFFSET;
      FUB[pos] = STR < FUB[pos + 1] || close[pos + 1] > FUB[pos + 1] ? STR : FUB[pos + 1];
      FLB[pos] = STS > FLB[pos + 1] || close[pos + 1] < FLB[pos + 1] ? STS : FLB[pos + 1];
      if (close[pos] < FUB[pos])
      {
         out[pos] = FUB[pos];
      }
      else if (close[pos] > FUB[pos])
      {
         out[pos] = FLB[pos];
      }
      else if (close[pos] > FLB[pos])
      {
         out[pos] = FLB[pos];
      }
      else
      {
         out[pos] = FUB[pos];
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
