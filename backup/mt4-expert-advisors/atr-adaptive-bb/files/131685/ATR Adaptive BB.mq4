// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69490

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

#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Yellow

extern int Length=20;
extern int Deviation=2;

double UpperBuff[], MiddleBuff[], LowerBuff[];

int init()
{
   double temp = iCustom(NULL, 0, "ATR adaptive EMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'ATR adaptive EMA' indicator");
      return INIT_FAILED;
   }
   IndicatorShortName("ATR adaptive BB");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,LowerBuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MiddleBuff);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,UpperBuff);
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
      MiddleBuff[pos] = iCustom(_Symbol, _Period, "ATR adaptive EMA", Length, 0, pos);

      double sum = 0;
      double ssum = 0;
      for (int i = 0; i < Length; i++)
      {
         double __data = Close[pos + i];
         sum += __data;
         ssum += MathPow(__data, 2);
      }
      double stdev = MathSqrt((ssum * Length - sum * sum) / (Length * (Length - 1)));

      UpperBuff[pos] = MiddleBuff[pos] + stdev * Deviation;
      LowerBuff[pos] = MiddleBuff[pos] - stdev * Deviation;
   }
   
   return(0);
}

