// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67167

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Gray
#property indicator_color2 Red

extern int period = 34; // Period

double Result[];
double Vol[];

int init()
{
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, Vol);
   SetIndexLabel(0, "Volume");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Result);
   SetIndexLabel(1, "Regression");

   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return -1;
   if (counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - period, Bars - counted_bars);
   if (counted_bars == 0)
      limit -= 1 + 1;
   for (int i = limit; i >= 0; i--)
   {
      Vol[i] = (double)Volume[i];
      long sumy = 0.0;
      double sumx = 0.0;
      long sumxy = 0.0;
      double sumx2 = 0.0;
      for (int ii = 0; ii < period; ii++)
      {
         sumy += Volume[i + ii];
         sumxy += Volume[i + ii] * ii;
         sumx += ii;
         sumx2 += ii * ii;
      }
      double c = sumx2 * period - sumx * sumx;
      double b = (sumxy * period - sumx * sumy) / c;
      Result[i] = (sumy - sumx * b) / period;
   }
   return 0;
}
