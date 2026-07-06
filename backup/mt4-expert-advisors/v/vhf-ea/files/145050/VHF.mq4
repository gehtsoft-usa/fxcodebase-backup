// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71888

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

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
//----
extern int N=28;
//----
double VHFBuffer[];
double TempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   IndicatorBuffers(2);
//----   
   SetIndexBuffer(0,VHFBuffer);
   SetIndexBuffer(1,TempBuffer);
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
//----   
   SetIndexDrawBegin(0,N+1);
//----
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
//----
   int i,k;
//---- 
   if(N<=1) return(0);
   if(Bars<=N) return(0);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2+N;

//----
   for(i=0; i<limit; i++)
     {
      TempBuffer[i]=MathAbs(Close[i]-Close[i+1]);
     }

   i=limit;
   while(i>=0)
     {
      double hh = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, N, i));
      double ll = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, N, i));
      double a = hh-ll;
      double b = 0.0;
      k=i+N-1;
      while(k>=i)
        {
         b+=TempBuffer[k];
         k--;
        }
      VHFBuffer[i]=a/b;
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
