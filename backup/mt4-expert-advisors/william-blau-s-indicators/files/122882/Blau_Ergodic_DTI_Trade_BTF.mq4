// More information about this indicator can be found at:
// http://fxcodebase.com/

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
#property indicator_buffers 8
#property indicator_color1 Gray
#property indicator_color2 Yellow

extern int Length=2;
extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Signal_Length=3;
extern ENUM_TIMEFRAMES Period = PERIOD_CURRENT; // Timeframe

double Blau_DTI[], Signal[];
double HLM[], HLM_EMA1[], HLM_EMA2[];
double Abs[], Abs_EMA1[], Abs_EMA2[];

int init()
{
   IndicatorShortName("William Blau Ergodic DTI-Oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Blau_DTI);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Signal);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,HLM);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,HLM_EMA1);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,HLM_EMA2);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,Abs);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,Abs_EMA1);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,Abs_EMA2);

   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if (Bars <= Length)
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return -1;
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      if (Period == PERIOD_CURRENT)
      {
         double HM = High[pos] - High[pos + Length - 1];
         double LM = Low[pos + Length - 1] - Low[pos];
         if (HM < 0.)
            HM = 0.;
         if (LM < 0.)
            LM = 0.;
         HLM[pos] = HM - LM;
         Abs[pos] = MathAbs(HLM[pos]);
         HLM_EMA1[pos]=iMAOnArray(HLM, 0, Smooth_Length1, 0, MODE_EMA, pos);
         Abs_EMA1[pos]=iMAOnArray(Abs, 0, Smooth_Length1, 0, MODE_EMA, pos);
         HLM_EMA2[pos]=iMAOnArray(HLM_EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
         Abs_EMA2[pos]=iMAOnArray(Abs_EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
         Blau_DTI[pos] = Abs_EMA2[pos] > 0 ? 100. * HLM_EMA2[pos] / Abs_EMA2[pos] : 0;
         Signal[pos]=iMAOnArray(Blau_DTI, 0, Signal_Length, 0, MODE_EMA, pos);
      }
      else
      {
         int index = iBarShift(_Symbol, Period, Time[pos]);
         Blau_DTI[pos] = iCustom(_Symbol, Period, "Blau_Ergodic_DTI_Trade_BTF", Length, Smooth_Length1, Smooth_Length2, Signal_Length, 0, index);
         Signal[pos] = iCustom(_Symbol, Period, "Blau_Ergodic_DTI_Trade_BTF", Length, Smooth_Length1, Smooth_Length2, Signal_Length, 1, index);
      }
      pos--;
   }  

   return(0);
}

