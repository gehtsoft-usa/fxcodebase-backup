// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=59967

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
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

input string symbol_1 = "EURUSD"; // Symbol 1
input string symbol_2 = "GBPUSD"; // Symbol 2
input int Length = 20; // Period
input ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Price type

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

double roc1[], roc2[];
int init()
{
   double temp = iCustom(NULL, 0, "ROC", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'ROC' indicator");
      return INIT_FAILED;
   }
   IndicatorObjPrefix = GenerateIndicatorPrefix("2sroc");
   IndicatorShortName("2 Symbol ROC");

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0, roc1);
   SetIndexLabel(0, "ROC 1");
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(1, roc2);
   SetIndexLabel(1, "ROC 2");

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
      ArrayInitialize(roc1, EMPTY_VALUE);
      ArrayInitialize(roc2, EMPTY_VALUE);
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
      int index1 = iBarShift(symbol_1, _Period, time[pos]);
      int index2 = iBarShift(symbol_2, _Period, time[pos]);
      if (index1 < 0 || index2 < 0)
      {
         continue;
      }
      if (iClose(symbol_1, _Period, index1) > iClose(symbol_1, _Period, index2))
      {
         roc1[pos] = iCustom(symbol_1, _Period, "ROC", Length, Price, 0, index1);
         roc2[pos] = -iCustom(symbol_2, _Period, "ROC", Length, Price, 0, index2);
      }
      else
      {
         roc1[pos] = -iCustom(symbol_1, _Period, "ROC", Length, Price, 0, index1);
         roc2[pos] = iCustom(symbol_2, _Period, "ROC", Length, Price, 0, index2);
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
