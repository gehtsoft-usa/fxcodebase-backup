// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69392

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
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Red

input int Period1 = 5; // Period #1
input int Period2 = 10; // Period #2

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

double Top1[], Top2[], Bottom1[], Bottom2[];

int init()
{
   IndicatorName = GenerateIndicatorName("Trend Bands");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Top1);
   SetIndexLabel(0, "Top #1");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Top2);
   SetIndexLabel(1, "Top #2");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Bottom1);
   SetIndexLabel(2, "Bottom #1");

   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, Bottom2);
   SetIndexLabel(3, "Bottom #2");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMin(Bars - 1 - 0, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, Period1, i);
      Top1[i] = iHigh(_Symbol, _Period, highestIndex);
      highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, Period2, i);
      Top2[i] = iHigh(_Symbol, _Period, highestIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Period1, i);
      Bottom1[i] = iLow(_Symbol, _Period, lowestIndex);
      lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Period2, i);
      Bottom2[i] = iLow(_Symbol, _Period, lowestIndex);
   }
   return 0;
}
