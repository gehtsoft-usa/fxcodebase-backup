// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67166

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

#property copyright "Sciurus 2015"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green
#property indicator_label1 "Result"

extern int ma_period = 14; // MA Period
double close[];
double Curr_Bid;
double Prev_Bid;
double Curr_Ask;
double Prev_Ask;
datetime timestamp;
bool firstTick=true;
double out[];

int init()
{
   IndicatorBuffers(2);
   SetIndexBuffer(0, out);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(1, close);
   SetIndexEmptyValue(1, 0);
   SetIndexStyle(1, DRAW_NONE);
   return (0);
}

int deinit()
{
   return (0);
}

int start()
{
   Prev_Bid = Curr_Bid;
   Curr_Bid = Bid;
   Prev_Ask = Curr_Ask;
   Curr_Ask = Ask;
   
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 2;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   int pos = 0;
   if (Time[pos] != timestamp)
   {
      close[pos] = close[pos + 1];
      timestamp = Time[pos];      
   }

   if (Curr_Ask > Prev_Ask)
   {
      close[pos] = close[pos] + (Volume[pos] - Volume[pos + 1]);
   }   
   if (Curr_Bid < Prev_Bid)
   { 
      close[pos] = close[pos] - (Volume[pos] - Volume[pos + 1]);
   }
   out[0] = close[0] - iMAOnArray(close, 0, ma_period, 0, MODE_SMA, 0);

   return (0);
}
