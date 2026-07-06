// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70132

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

input string comparativeSymbol = "USDJPY"; // Comparative Symbol
input int length = 50; // Period
input bool showMA = false; // Show Moving Average
input int lengthMA = 10; // Moving Average Period
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int bars_limit = 1000; // Bars limit

double res[], sma_1[];

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

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("rs");
   IndicatorShortName("Relative Strength");

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, res);
   SetIndexLabel(0, "RS");

   SetIndexStyle(1, showMA ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(1, sma_1);
   SetIndexLabel(1, "SMA");

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
      ArrayInitialize(res, EMPTY_VALUE);
      ArrayInitialize(sma_1, EMPTY_VALUE);
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

   int toSkip = length;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0; --pos)
   {
      if (tf != _Period && tf != PERIOD_CURRENT)
      {
         int index = iBarShift(_Symbol, tf, time[pos]);
         if (index < 0)
         {
            continue;
         }
         res[pos] = iCustom(_Symbol, tf, "Relative Strength", comparativeSymbol, length, showMA, lengthMA, 0, index);
         sma_1[pos] = iCustom(_Symbol, tf, "Relative Strength", comparativeSymbol, length, showMA, lengthMA, 1, index);
      }
      else
      {
         int index = iBarShift(comparativeSymbol, _Period, time[pos]);
         if (index < 0)
         {
            continue;
         }
         double close2 = iClose(comparativeSymbol, _Period, index + length);
         if (close2 == 0)
         {
            continue;
         }
         res[pos] = (close[pos] / close[pos + length]) / (iClose(comparativeSymbol, _Period, index) / close2) - 1;
         sma_1[pos] = iMAOnArray(res, 0, lengthMA, 0, MODE_SMA, pos);
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
