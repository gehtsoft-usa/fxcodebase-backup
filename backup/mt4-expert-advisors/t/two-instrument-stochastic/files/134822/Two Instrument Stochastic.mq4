// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69998

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

input string symbol_1 = "EURUSD"; // Instrument 1
input int K_periods_1 = 5; // K 1
input int D_periods_1 = 3; // D 1
input int   Slowing_1 = 3; // Slowing 1
input string symbol_2 = "USDJPY"; // Instrument 2
input int K_periods_2 = 5; // K 2
input int D_periods_2 = 3; // D 2
input int   Slowing_2 = 3; // Slowing 2

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

double out1[], out2[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("tis");
   IndicatorShortName("Two Instrument Stochastic");

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out1);
   SetIndexLabel(0, "Stochastic " + symbol_1);

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, out2);
   SetIndexLabel(1, "Stochastic " + symbol_2);

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
      ArrayInitialize(out1, EMPTY_VALUE);
      ArrayInitialize(out2, EMPTY_VALUE);
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
   for (int pos = rates_total - 1 - toSkip; pos >= 0; --pos)
   {
      int pos_1 = iBarShift(symbol_1, _Period, time[pos]);
      if (pos_1 < 0)
      {
         continue;
      }
      int pos_2 = iBarShift(symbol_1, _Period, time[pos]);
      if (pos_2 < 0)
      {
         continue;
      }
      out1[pos] = iStochastic(symbol_1, _Period, K_periods_1, D_periods_1, Slowing_1, MODE_SMA, 0, MODE_MAIN, pos_1);
      out2[pos] = iStochastic(symbol_2, _Period, K_periods_2, D_periods_2, Slowing_2, MODE_SMA, 0, MODE_MAIN, pos_2);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
