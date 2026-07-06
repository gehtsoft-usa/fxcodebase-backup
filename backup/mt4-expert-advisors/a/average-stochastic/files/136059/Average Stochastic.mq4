// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70188

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
#property indicator_color2 Blue

input int      K_periods      = 5;
input int      D_periods      = 3;
input int      Slowing        = 3;

input string symbol1 = "EURUSD"; // Symbol 1
input string symbol2 = "USDJPY"; // Symbol 2
input string symbol3 = "CADJPY"; // Symbol 3
input string symbol4 = "GBPUSD"; // Symbol 4
input string symbol5 = "AUDUSD"; // Symbol 5

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

double k[], d[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("as");
   IndicatorShortName("Average Stochastic");

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, k);
   SetIndexLabel(0, "K");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, d);
   SetIndexLabel(1, "D");

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double Get(int period, string symbol, int stream)
{
   int index = iBarShift(symbol, (ENUM_TIMEFRAMES)_Period, Time[period]);
   if (index < 0)
   {
      return 0;
   }
   return iStochastic(symbol, _Period, K_periods, D_periods, Slowing, MODE_SMA, 0, stream, index);
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
      ArrayInitialize(k, EMPTY_VALUE);
      ArrayInitialize(d, EMPTY_VALUE);
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
   for (int pos = rates_total - 1 - MathMax(prev_calculated, toSkip); pos >= 0 && !IsStopped(); --pos)
   {
      k[pos] = (Get(pos, symbol1, 0) + Get(pos, symbol2, 0) + Get(pos, symbol3, 0) + Get(pos, symbol4, 0) + Get(pos, symbol5, 0)) / 5;
      d[pos] = (Get(pos, symbol1, 1) + Get(pos, symbol2, 1) + Get(pos, symbol3, 1) + Get(pos, symbol4, 1) + Get(pos, symbol5, 1)) / 5;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
