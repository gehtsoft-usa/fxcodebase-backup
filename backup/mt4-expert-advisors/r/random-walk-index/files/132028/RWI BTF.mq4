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
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

input int Length = 2;
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe

double RWIH[], RWIL[];
double TR[];

int init()
{
   IndicatorShortName("Random Walk Index");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RWIH);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,RWIL);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,TR);

   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = Length;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; pos--)
   {
      if (tf == _Period || tf == PERIOD_CURRENT)
      {
         TR[pos] = MathMax(High[pos] - Low[pos], MathMax(MathAbs(High[pos] - Close[pos + 1]), MathAbs(Close[pos + 1] - Low[pos])));
         double H = 0;
         double L = 0;
         for (int i = 1; i <= Length; i++)
         {
            double ATR = iMAOnArray(TR, 0, i, 0, MODE_SMA, pos) / MathSqrt(i + 1);
            if (ATR != 0)
            {
               H = MathMax(H, (High[pos] - Low[pos + i]) / ATR);
               L = MathMax(L, (High[pos + i] - Low[pos]) / ATR);
            }
         } 
         RWIH[pos] = H;
         RWIL[pos] = L;
      }
      else
      {
         int index = iBarShift(_Symbol, tf, Time[pos]);
         if (index < 0)
         {
            continue;
         }
         TR[pos] = iCustom(_Symbol, tf, "RWI BTF", Length, 2, index);
         RWIH[pos] = iCustom(_Symbol, tf, "RWI BTF", Length, 0, index);
         RWIL[pos] = iCustom(_Symbol, tf, "RWI BTF", Length, 1, index);
      }
   }
   return 0;
}
