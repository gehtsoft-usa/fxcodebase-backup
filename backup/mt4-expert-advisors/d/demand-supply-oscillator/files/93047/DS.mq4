// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=60407
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
#property indicator_color1 Green
#property indicator_color2 Red

input int Length = 14;
input int Method = 0; // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA

double DS[], DS_DN[];
double Raw[];

int init()
{
   IndicatorShortName("Demand/Supply oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, DS);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, DS_DN);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, Raw);

   return (0);
}

int deinit()
{
   return (0);
}

int start()
{
   if (Bars <= 3)
      return (0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return (-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   int pos;
   double buy, sell;
   pos = limit;
   while (pos >= 0)
   {
      double highlow = High[pos] - Low[pos];
      buy = highlow == 0 ? 0 : (MathAbs(Close[pos] - Low[pos]) / highlow) * Volume[pos];
      sell = highlow == 0 ? 0 : (MathAbs(High[pos] - Close[pos]) / highlow) * Volume[pos];
      Raw[pos] = buy - sell;

      pos--;
   }

   pos = limit;
   while (pos >= 0)
   {
      DS[pos] = iMAOnArray(Raw, 0, Length, 0, Method, pos) * 10;
      if (DS[pos] < DS[pos + 1])
      {
         DS_DN[pos] = DS[pos];
      }
      else
      {
         DS_DN[pos] = EMPTY_VALUE;
      }
      pos--;
   }

   return (0);
}
