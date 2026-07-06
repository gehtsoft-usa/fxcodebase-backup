// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71988


//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  |
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   |
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |
//+------------------------------------------------------------------------+
#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
//----
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_level1 40
#property indicator_level2 60
//---- input parameters
extern int       Per=5;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   IndicatorShortName("IBS("+Per+")");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   int i,limit;
   if (counted_bars==0) limit=Bars-1;
   if (counted_bars>0) limit=Bars-counted_bars;
   double delitel;
   limit--;
   for(i=limit;i>=0;i--)
     {
      delitel=High[i]-Low[i];
      if (delitel>0)  ExtMapBuffer2[i]=(Close[i]-Low[i])/delitel;
      else ExtMapBuffer2[i]=0.0;
     }
   for(i=limit;i>=0;i--)
     {
      ExtMapBuffer1[i]=iMAOnArray(ExtMapBuffer2,0,Per,0,MODE_SMA,i)*100.0;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+