// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72038

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


//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrRed

#property indicator_width1  2
#property indicator_width2  2

extern int    ArrowCodeDn          =   233;
extern int    ArrowCodeUp          =   234;
int    LagBar               =     0;
string NoteLagBar           = "0 = Signal on current ; 1 = Wait for close";
 

double ArrowsUp[];
double ArrowsDn[];
double body[];
double trend[];


int init()
{
   IndicatorBuffers(4);
      SetIndexBuffer(0,ArrowsUp); SetIndexArrow(0,ArrowCodeDn);
      SetIndexBuffer(1,ArrowsDn); SetIndexArrow(1,ArrowCodeUp);
      SetIndexBuffer(2,trend);
      SetIndexBuffer(3,body);
      

      SetIndexStyle(0,DRAW_ARROW);
      SetIndexStyle(1,DRAW_ARROW);

      
   return(0);
}
int deinit()

{
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int counted_bars=IndicatorCounted();
   int i, limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);

      for(i=limit; i>=0; i--)
      {
         double gap = 3.0*iATR(NULL,0,20,i)/4.0;

         body[i] = MathAbs(Open[i]-Close[i]);

         trend[i] =  trend[i+1];

// 
         if((High[i+1] < Low[i-1]) && (body[i] > body[i+1]) && (body[i] > body[i+2]) && (body[i] > body[i+3]) && (iVolume(NULL,0,i-LagBar)>1))
         {
            trend[i] = 1;
         }

// 
         if((Low[i+1] > High[i-1]) && (body[i] > body[i+1]) && (body[i] > body[i+2]) && (body[i] > body[i+3]) && (iVolume(NULL,0,i-LagBar)>1))
         {
            trend[i] =- 1;
         }

        ArrowsUp[i] =  EMPTY_VALUE;
        ArrowsDn[i] =  EMPTY_VALUE;

        if (trend[i] != trend[i+1])
        {
           if (trend[i] == 1)
           ArrowsUp[i] = Low[i] - gap;
          
           else if (trend[i] ==- 1)
           ArrowsDn[i] = High[i] + gap;
           
        }
     }



   return(0);
   }      

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+