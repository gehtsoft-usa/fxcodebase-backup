// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69618

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
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

input int x_days = 3; // Days back

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

double h[], l[];

int init()
{
   IndicatorName = GenerateIndicatorName("HHV-LLV");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, h);
   SetIndexLabel(0, "High");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, l);
   SetIndexLabel(1, "Low");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = x_days;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, x_days, i);
      double highest = iHigh(_Symbol, _Period, highestIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, x_days, i);
      double lowest = iLow(_Symbol, _Period, lowestIndex);
      double range = highest - lowest;
      h[i] = High[i] + range;
      l[i] = Low[i] - range;
   }
   return 0;
}
