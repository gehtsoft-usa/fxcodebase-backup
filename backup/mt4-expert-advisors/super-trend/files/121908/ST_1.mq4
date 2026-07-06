// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66882

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
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 White

extern int N = 10; // Number of periods
extern double M = 1.5; // Multiplier

double UP[], DN[], TR[];

int init()
{
   IndicatorShortName("SuperTrend Indicator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,UP);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,DN);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,TR);

   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   int pos = limit;
   while (pos >= 0)
   {
      double atr = iATR(_Symbol, _Period, N, pos);
      double median = (High[pos] + Low[pos]) / 2;
      UP[pos] = median + atr * M;
      DN[pos] = median - atr * M;
      if (Close[pos] > UP[pos + 1])
         TR[pos] = 1;
      else
      {
         if (Close[pos] < DN[pos + 1])
            TR[pos] = -1;
         else
            TR[pos] = TR[pos + 1];
      }

      bool flag = TR[pos] < 0 && TR[pos + 1] > 0;
      bool flagh = TR[pos] > 0 && TR[pos + 1] < 0;
      if (TR[pos] > 0 && DN[pos] < DN[pos + 1])
         DN[pos] = DN[pos + 1];
      if (TR[pos] < 0 && UP[pos] > UP[pos + 1])
         UP[pos] = UP[pos + 1];
      if (flag)
         UP[pos] = median + atr * M;
      if (flagh)
         DN[pos] = median - atr * M;
      pos--;
   } 
   return(0);
}

