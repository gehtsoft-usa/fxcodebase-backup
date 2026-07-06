// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69409

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
#property indicator_buffers 1
#property indicator_color1 Red

input int period = 14; // Period

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

double out[];

int init()
{
   IndicatorName = GenerateIndicatorName("ATR Adaptive EMA");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "EMA");

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
      double ll = 0;
      double hh = 0;
      for (int ii = 0; ii < period; ++ii)
      {
         double atrValue = iATR(_Symbol, _Period, period, i + ii);
         if (hh == 0)
         {
            hh = atrValue;
            ll = atrValue;
         }
         if (hh < atrValue)
         {
            hh = atrValue;
         }
         if (ll > atrValue)
         {
            ll = atrValue;
         }
      }
      double atrValue = iATR(_Symbol, _Period, period, i);
      double coeff = (hh - ll) == 0 ? 1 : 1 - (atrValue - ll) / (hh - ll);
      double alpha = 2.0 / (1 + period * (coeff + 1.0) / 2.0);
      if (i == Bars - 1)
      {
         out[i] = Close[i];
      }
      else
      {
         out[i] = out[i + 1] + alpha * (Close[i] - out[i + 1]);
      }
   }
   return 0;
}
