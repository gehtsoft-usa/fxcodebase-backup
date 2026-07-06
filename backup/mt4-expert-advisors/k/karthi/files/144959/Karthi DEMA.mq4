// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71859

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com" 
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  Red
#property indicator_width1  1
//---- input parameters
extern int PERIOD  =12;
//---- indicator buffer
double Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("DEMA("+PERIOD+")");
   SetIndexBuffer(0,Buffer);
   SetIndexStyle(0,DRAW_LINE);
  }
//+------------------------------------------------------------------+
int start()
  {
   int limit=Bars-1-IndicatorCounted();
//----
   static double lastEMA, lastEMA_of_EMA;
   double weight=2.0/(1.0+PERIOD);
   if(IndicatorCounted()==0)
     {
      Buffer[limit]  =Close[limit];
      lastEMA        =Close[limit];
      lastEMA_of_EMA  =Close[limit];
      limit--;
     }
//----
   //	Calculate old bars (not the latest), if necessary
   for(int i=limit; i > 0; i--)
     {
      lastEMA        =weight*Close[i]   + (1.0-weight)*lastEMA;
      lastEMA_of_EMA  =weight*lastEMA   + (1.0-weight)*lastEMA_of_EMA;
      Buffer[i]=2.0*lastEMA - lastEMA_of_EMA;
     }
//----
   //	(Re)calculate current bar
   double EMA        =weight*Close[0]   + (1.0-weight)*lastEMA,
   EMA_of_EMA  =weight*EMA      + (1.0-weight)*lastEMA_of_EMA;
   Buffer[0]=2.0*EMA - EMA_of_EMA;
//----
   return(0);
  }

//+------------------------------------------------------------------+