// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70778

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
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

input double level1 = 0.127; // Level 1
input double level2 = 0.382; // Level 2
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

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("fc");
   IndicatorShortName("Fibonacci Comments");

   IndicatorBuffers(1);

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
   double currentHigh = iHigh(_Symbol, _Period, 0);
   double currentLow = iLow(_Symbol, _Period, 0);
   double currentLevel1 = currentHigh - (currentHigh - currentLow) * level1;
   double currentLevel2 = currentHigh - (currentHigh - currentLow) * level2;
   double prevHigh = iHigh(_Symbol, _Period, 1);
   double prevLow = iLow(_Symbol, _Period, 1);
   double prevLevel1 = prevHigh - (prevHigh - prevLow) * level1;
   double prevLevel2 = prevHigh - (prevHigh - prevLow) * level2;
   string text = "Current Period High = " + DoubleToString(currentHigh, _Digits) + "\n"
      + "Current Period Low = " + DoubleToString(currentLow, _Digits) + "\n"
      + "Current Period Level 1 = " + DoubleToString(currentLevel1, _Digits) + "\n"
      + "Current Period Level 2 = " + DoubleToString(currentLevel2, _Digits) + "\n\n"
      + "Previous Period High = " + DoubleToString(prevHigh, _Digits) + "\n"
      + "Previous Period Low = " + DoubleToString(prevLow, _Digits) + "\n"
      + "Previous Period Level 1 = " + DoubleToString(prevLevel1, _Digits) + "\n"
      + "Previous Period Level 2 = " + DoubleToString(prevLevel2, _Digits);
   Comment(text);
   return rates_total;
}
