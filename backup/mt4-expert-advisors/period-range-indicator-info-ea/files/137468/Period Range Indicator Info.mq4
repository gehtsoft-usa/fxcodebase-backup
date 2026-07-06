// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70411

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
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Green
#property indicator_color6 Red

input int Period = 24; // Number of Periods
input double Ratio = 1; // Risk/Reward
input double Position = 25; // Position %
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

double EntryLong[], EntryShort[], StopLong[], StopShort[], LimitLong[], LimitShort[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("prii");
   IndicatorShortName("Period Range Indicator Info");

   IndicatorBuffers(6);
   int id = 0;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, EntryLong);
   id++;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, EntryShort);
   id++;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, StopLong);
   id++;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, StopShort);
   id++;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, LimitLong);
   id++;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, LimitShort);
   id++;

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
      ArrayInitialize(EntryLong, EMPTY_VALUE);
      ArrayInitialize(EntryShort, EMPTY_VALUE);
      ArrayInitialize(StopLong, EMPTY_VALUE);
      ArrayInitialize(StopShort, EMPTY_VALUE);
      ArrayInitialize(LimitLong, EMPTY_VALUE);
      ArrayInitialize(LimitShort, EMPTY_VALUE);
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

   int toSkip = Period;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, Period, pos + 1);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Period, pos + 1);
      EntryLong[pos] = close[pos + 1] + ((high[highestIndex] - low[lowestIndex]) * Position / 100.0);
      EntryShort[pos] = close[pos + 1] - ((high[highestIndex] - low[lowestIndex]) * Position / 100.0);
      StopLong[pos] = EntryLong[pos] - ((high[highestIndex] - low[lowestIndex]) * Position / 100.0); 
      StopShort[pos] = EntryShort[pos] + ((high[highestIndex] - low[lowestIndex]) * Position / 100.0); 
      LimitLong[pos] = EntryLong[pos] + (((high[highestIndex] - low[lowestIndex]) * Position / 100.0) * Ratio);
      LimitShort[pos] = EntryShort[pos] - (((high[highestIndex] - low[lowestIndex]) * Position / 100.0) * Ratio);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
