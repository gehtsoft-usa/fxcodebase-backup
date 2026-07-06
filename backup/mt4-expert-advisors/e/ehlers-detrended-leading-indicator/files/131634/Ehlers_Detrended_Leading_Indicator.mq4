// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69481

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
#property indicator_buffers 1
#property indicator_color1 Red

input int length = 50; // Length

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

double deli[], ema1[], ema2[], temp[];

int init()
{
   IndicatorName = GenerateIndicatorName("Ehlers Detrended Leading Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, deli);
   SetIndexLabel(0, "DELI");

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, ema1);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, ema2);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, temp);

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
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, length, i);
      double prevhigh = iHigh(_Symbol, _Period, highestIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, length, i);
      double prevlow = iLow(_Symbol, _Period, lowestIndex);  
      double price = (prevhigh + prevlow) / 2;
      double alpha = i > 2 ? 2.0 / (14 + 1) : 0.67;
      double alpha2 = alpha / 2;
      ema1[i] = ema1[i + 1] == EMPTY_VALUE ? (alpha * price) : (alpha * price) + ((1 - alpha) * ema1[i + 1]);
      ema2[i] = ema2[i + 1] == EMPTY_VALUE ? (alpha2 * price) : (alpha2 * price) + ((1 - alpha2) * ema2[i + 1]);
      double dsp = ema1[i] - ema2[i];
      temp[i] = temp[i + 1] == EMPTY_VALUE ? (alpha * dsp) : (alpha * dsp) + ((1 - alpha) * temp[i + 1]);
      deli[i] = dsp - temp[i];
   }
   return 0;
}

