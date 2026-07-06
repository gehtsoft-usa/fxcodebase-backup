// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70290

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
#property indicator_plots 1
#property indicator_type1  DRAW_COLOR_LINE
#property indicator_color1 Green, Red
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "Tether"

input int Length = 55; // Length

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

double out[], outColor[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("tli");
   IndicatorSetString(INDICATOR_SHORTNAME, "Tetger Line Indicator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id++, out, INDICATOR_DATA);
   SetIndexBuffer(id++, outColor, INDICATOR_COLOR_INDEX);
}

void OnDeinit(const int reason)
{
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
      ArrayInitialize(out, EMPTY_VALUE);
      ArrayInitialize(outColor, 0);
   }
   int first = Length;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, Length, oldPos);
      double highest = iHigh(_Symbol, _Period, highestIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Length, oldPos);
      double lowest = iLow(_Symbol, _Period, lowestIndex);
      out[pos] = (highest + lowest) / 2;
      outColor[pos] = close[pos] > out[pos] ? 0 : 1;
   }
   return rates_total;
}