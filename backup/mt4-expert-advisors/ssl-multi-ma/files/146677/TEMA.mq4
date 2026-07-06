// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72480

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
#property indicator_color1 DarkBlue
#property  indicator_width1  2
//---- input parameters
extern int       EMA_period=14;
extern ENUM_APPLIED_PRICE  AppliedPrice = PRICE_CLOSE;                    // Applied Price
//---- buffers
double TemaBuffer[];
double Ema[];
double EmaOfEma[];
double EmaOfEmaOfEma[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TemaBuffer);
   SetIndexBuffer(1,Ema);
   SetIndexBuffer(2,EmaOfEma);
   SetIndexBuffer(3,EmaOfEmaOfEma);

   IndicatorShortName("TEMA("+EMA_period+")");
   
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
   int i,limit,limit2,limit3,counted_bars=IndicatorCounted();
//----
   if (counted_bars==0)
      {
      limit=Bars-1;
      limit2=limit-EMA_period;
      limit3=limit2-EMA_period;
      }
   if (counted_bars>0)
      {
      limit=Bars-counted_bars-1;
      limit2=limit;
      limit3=limit2;
      }
   for (i=limit;i>=0;i--)  Ema[i]=iMA(NULL,0,EMA_period,0,MODE_EMA,AppliedPrice,i);
   for (i=limit2;i>=0;i--) EmaOfEma[i]=iMAOnArray(Ema,0,EMA_period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) EmaOfEmaOfEma[i]=iMAOnArray(EmaOfEma,0,EMA_period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) TemaBuffer[i]=3*Ema[i]-3*EmaOfEma[i]+EmaOfEmaOfEma[i];
//----
   return(0);
  }
//+------------------------------------------------------------------+