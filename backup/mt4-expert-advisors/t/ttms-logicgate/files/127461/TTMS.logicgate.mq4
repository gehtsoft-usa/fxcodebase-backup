// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68690

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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Orange
#property indicator_color3 Brown

extern int BB_Length=20;
extern double BB_Deviation=2;
extern int Keltner_Length=20;
extern int Keltner_Smooth_Length=20;
extern int Keltner_Smooth_Method=0;  // 0 - SMA
                                     // 1 - EMA
                                     // 2 - SMMA
                                     // 3 - LWMA
extern double Keltner_Deviation=2;
extern int momPeriod = 12; // Momemtum Period
extern int momEMA = 5; // Momentum EMA Period

double TTMS_Up[], TTMS_Dn[], TTMS_N[], momHist[];

int init()
{
   IndicatorShortName("TTM Squeeze");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,TTMS_Up);
   SetIndexLabel(0, "TTM Squeeze - Momentum Up");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,TTMS_Dn);
   SetIndexLabel(1, "TTM Squeeze - Momentum Down");
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,TTMS_N);
   SetIndexLabel(2, "TTM Squeeze - Momentum Mid");

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, momHist);

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
   int limit = Bars - 2 - momPeriod;
   if(ExtCountedBars>2) 
      limit = MathMin(limit, Bars - ExtCountedBars - 1);
   int pos=limit;
   while (pos>=0)
   {
      double ATR=iATR(NULL, 0, Keltner_Smooth_Length, pos);
      double MA=iMA(NULL, 0, Keltner_Length, 0, Keltner_Smooth_Method, PRICE_CLOSE, pos);
      double H=MA+ATR*Keltner_Deviation;
      double L=MA-ATR*Keltner_Deviation;

      double ML=iMA(NULL, 0, BB_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
      double D=iStdDev(NULL, 0, BB_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
      double TL=ML+BB_Deviation*D;
      double BL=ML-BB_Deviation*D;

      momHist[pos] = Close[pos] - Close[pos + momPeriod];
      double momHistVal = iMAOnArray(momHist, 0, momEMA, 0, MODE_EMA, pos);
      if (TL > H && momHistVal > 0)
      {
         TTMS_Up[pos] = momHistVal;
         TTMS_Dn[pos] = 0;
         TTMS_N[pos] = 0;
      }
      else if (TL < H && momHistVal < 0)
      {
         TTMS_Up[pos] = 0;
         TTMS_Dn[pos] = momHistVal;
         TTMS_N[pos] = 0;
      }
      else
      {
         TTMS_Up[pos] = 0;
         TTMS_Dn[pos] = 0;
         TTMS_N[pos] = momHistVal;
      }
      pos--;
   } 
   return(0);
}

