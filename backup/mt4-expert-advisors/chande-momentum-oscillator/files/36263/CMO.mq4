// Id: 6926
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property strict

extern int Length=9;
input ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Applied price

double CMO[];
double cmo1[], cmo2[];

int init()
{
   IndicatorShortName("Chande Momentum Oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,CMO);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,cmo1);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,cmo2);

   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=3) 
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars<0) 
      return(-1);
   int limit = MathMin(Bars - 2, Bars - ExtCountedBars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      double diff = iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) - iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
      cmo1[pos] = 0;
      cmo2[pos] = 0;
      if (diff > 0)
         cmo1[pos] = diff;
      else if (diff < 0)
         cmo2[pos] = -diff;
      
      if (pos >= Bars - 2 - Length)
         continue;
      double s1 = iMAOnArray(cmo1, 0, Length, 0, MODE_SMA, pos);
      double s2 = iMAOnArray(cmo2, 0, Length, 0, MODE_SMA, pos);
      double summ = s1 + s2;
      CMO[pos] = summ != 0 ? ((s1 - s2) / summ) * 100 : EMPTY_VALUE;
   } 

   return Bars;
}


