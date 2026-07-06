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

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 1
#include <MovingAverages.mqh>

input int Indicator_Period = 21; 
 
double CMF[];
double VOLUME[], vol[];

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
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

int ad, a;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("cmf");
   IndicatorSetString(INDICATOR_SHORTNAME, "Chaikin Money Flow");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, CMF, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "CMF");
   ++id;
   SetIndexBuffer(id++, vol, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, VOLUME, INDICATOR_CALCULATIONS);
   
   ad = iAD(_Symbol, _Period, VOLUME_TICK);
   a = iMA(_Symbol, _Period, Indicator_Period, 0, MODE_SMA, ad);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(ad);
   IndicatorRelease(a);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
      ArrayInitialize(VOLUME, EMPTY_VALUE);
      ArrayInitialize(CMF, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      vol[pos] = tick_volume[pos];
   }
   SimpleMAOnBuffer(rates_total, prev_calculated, 0, Indicator_Period, vol, VOLUME);
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double aVal[1];
      if (CopyBuffer(a, 0, oldPos, 1, aVal) != 1)
      {
         continue;
      }
      CMF[pos] = VOLUME[pos] != 0 ? aVal[0] / VOLUME[pos] : 0;
   }
   return rates_total;
}