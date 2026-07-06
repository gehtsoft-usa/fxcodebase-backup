// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69442

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

int p = 20;
double s = 0.5;

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 C'205,55,55'
#property indicator_color2 C'55,55,155'

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

double dnh[], uph[], ZHL[];

int init()
{
   IndicatorName = GenerateIndicatorName("ZiBoll");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_SECTION);
   SetIndexBuffer(0, dnh);
   SetIndexLabel(0, "boll-");

   SetIndexStyle(1, DRAW_SECTION);
   SetIndexBuffer(1, uph);
   SetIndexLabel(1, "boll+");

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, ZHL);

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
   int minBars = p;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double BollMALow = iMA(_Symbol, _Period, p, 0, MODE_LWMA, PRICE_LOW, i);
      double BollMAHigh = iMA(_Symbol, _Period, p, 0, MODE_LWMA, PRICE_HIGH, i);
      double sumy2 = 0;
      double sumy = 0;
      for (int ii = 0; ii < p; ++ii)
      {
         sumy2 = sumy2 + Close[i + ii] * Close[i + ii];
         sumy = sumy + Close[i + ii];
      }
      double STDDEV = MathSqrt(sumy2 / p - (sumy / p) * (sumy / p));
      double BdnL = BollMALow - (s * STDDEV);
      double Buph = BollMAHigh + (s * STDDEV);
      if (Close[i] < BdnL)
         ZHL[i] = -1;
      else if (Close[i] > Buph)
         ZHL[i] = 1;
      else
         ZHL[i] = ZHL[i + 1];

      uph[i] = uph[i + 1];
      dnh[i] = dnh[i + 1];
      if (ZHL[i] > 0 && ZHL[i + 1] < 0)
      {
         dnh[i] = Buph;
      }
      if (ZHL[i] < 0 && ZHL[i + 1] > 0)
      {
         uph[i] = BdnL;
      }
   }
   return 0;
}

