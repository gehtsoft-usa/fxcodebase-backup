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
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

double TM[];

int init()
{
   IndicatorShortName("William Blau Trend Momentum");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TM);

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
   int limit=Bars-2 - Length;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   int pos;

   double H, L;
   pos=limit;
   while(pos>=0)
   {
      if (timeframe == _Period || timeframe == PERIOD_CURRENT)
      {
         H=High[pos]-High[pos+Length];
         if (H<0) H=0;
         L=Low[pos+Length]-Low[pos];
         if (L<0) L=0;
         TM[pos]=H-L;
      }
      else
      {
         int index = pos == 0 ? 0 : iBarShift(_Symbol, timeframe, Time[pos]);
         if (index != -1)
         {
            H = iHigh(_Symbol, timeframe, index) - iHigh(_Symbol, timeframe, index + Length);
            if (H<0) 
               H=0;
            L = iLow(_Symbol, timeframe, index + Length) - iLow(_Symbol, timeframe, index);
            if (L<0) 
               L=0;
            TM[pos]=H-L;
         }
      }
      pos--;
   }
   
   return(0);
}

