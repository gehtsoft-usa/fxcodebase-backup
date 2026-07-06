// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68892

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
#property indicator_buffers 2
//----
#property indicator_color1 SkyBlue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 1
#property indicator_style2 2
//---- user changeable stuff
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalEMA=9;
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe;
//---- two buffers
double     PPOBuffer[];
double     SignalBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   double temp = iCustom(NULL, 0, "PPO", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'PPO' indicator");
      return INIT_FAILED;
   }
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,SignalEMA);
   IndicatorDigits(Digits+1);
   SetIndexBuffer(0,PPOBuffer);
   SetIndexBuffer(1,SignalBuffer);
//----
   IndicatorShortName("PPO ("+FastEMA+","+SlowEMA+","+SignalEMA+")");
   SetIndexLabel(0,"PPO");
   SetIndexLabel(1,"Signal");
//----
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit = Bars - 1 - counted_bars;
//---- (FastEMA-SlowEMA)/SlowEMA
//---- PPO counted in the 1st buffer
   for(int i = limit; i >= 0; --i)
   {
      int shift = iBarShift(_Symbol, tf, Time[i]);
      PPOBuffer[i] = iCustom(_Symbol, tf, "PPO", FastEMA, SlowEMA, SignalEMA, 0, shift);
      SignalBuffer[i] = iCustom(_Symbol, tf, "PPO", FastEMA, SlowEMA, SignalEMA, 1, shift);
   }
   return(0);
}
//+------------------------------------------------------------------+
