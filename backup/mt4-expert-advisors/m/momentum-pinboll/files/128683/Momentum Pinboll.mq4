// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68917

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

#property  indicator_separate_window
#property  indicator_buffers 1

#property  indicator_color1 Blue

#property  indicator_level1 70
#property  indicator_level2 30

#property  indicator_minimum   0
#property  indicator_maximum 100

//---- indicator parameters
extern int ExtPeriodRSI = 3;
extern int ExtPeriodROC = 1;
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int bars_limit = 1000; // Bars limit

//---- indicator buffers
double BufferRSI[];
double BufferROC[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers( 2 );
   
   SetIndexStyle( 0, DRAW_LINE );
   SetIndexDrawBegin( 0, ExtPeriodRSI );
   IndicatorDigits( Digits + 1 );
   
   SetIndexBuffer( 0, BufferRSI );
   SetIndexBuffer( 1, BufferROC );
   
   IndicatorShortName( "Momentum Pinboll(" + ExtPeriodRSI + "," + ExtPeriodROC + ")" );
   
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) 
      return -1;
   if (counted_bars > 0)
      counted_bars--;
      
   int iCount = Bars - counted_bars - ExtPeriodROC - 1;
   for (int i = iCount; i >= 0; i--)
   {
      if (tf != PERIOD_CURRENT && tf != _Period)
      {
         if (i < bars_limit)
         {
            int index = iBarShift(_Symbol, tf, Time[i]);
            BufferRSI[i] = iCustom(_Symbol, tf, "Momentum Pinboll", ExtPeriodRSI, ExtPeriodROC, 0, index);
            BufferROC[i] = iCustom(_Symbol, tf, "Momentum Pinboll", ExtPeriodRSI, ExtPeriodROC, 1, index);
         }
      }
      else
      {
         BufferROC[i] = Close[i] - Close[i + ExtPeriodROC];
         if (i <= bars_limit)
            BufferRSI[i] = iRSIOnArray(BufferROC, 0, ExtPeriodRSI, i);
      }
   }
   
   return 0;
}
