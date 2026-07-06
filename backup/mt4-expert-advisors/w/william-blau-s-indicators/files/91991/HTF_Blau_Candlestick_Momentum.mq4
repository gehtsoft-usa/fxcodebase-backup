// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=60201

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
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

double CM[];

int init()
{
   IndicatorShortName("William Blau Candlestick Momentum");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,CM);

   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=Length) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   int pos = limit;

   while (pos >= 0)
   {
      if (timeframe == _Period || timeframe == PERIOD_CURRENT)
      {
         CM[pos] = iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) - iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos + Length);
      }
      else
      {
         int index = pos == 0 ? 0 : iBarShift(_Symbol, timeframe, Time[pos]);
         if (index != -1)
            CM[pos] = iMA(_Symbol, timeframe, 1, 0, MODE_SMA, Price, index) 
               - iMA(_Symbol, timeframe, 1, 0, MODE_SMA, Price, index + Length);
      }
      pos--;
   }
      
   return(0);
}

