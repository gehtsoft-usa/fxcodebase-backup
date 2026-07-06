// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69805

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Yellow

input int per = 150; // Calculate for last bars

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

double f1[], f2[], f3[];

int init()
{
   IndicatorName = GenerateIndicatorName("Fibonacci retracement lines");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0, f1);
   SetIndexLabel(0, "0.0");

   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(1, f2);
   SetIndexLabel(1, "0.5");

   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(2, f3);
   SetIndexLabel(2, "1.0");

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = per;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      int highIndex = iHighest(_Symbol, _Period, MODE_HIGH, per, i);
      double hl = iHigh(_Symbol, _Period, highIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, per, i);
      double ll = iLow(_Symbol, _Period, lowestIndex);
      double dist = hl - ll;
      f1[i] = Close[i + per] > Close[i] ? hl : ll + dist;
      f2[i] = Close[i + per] > Close[i] ? hl - dist * 0.5 : ll + dist * 0.5;
      f3[i] = Close[i + per] > Close[i] ? hl - dist : ll;
   }
   return 0;
}
