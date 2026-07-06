// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72773

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

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
#property version "1.0"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
//---- input parameters 
extern int       period=15;
extern int       method=3;                        
extern int       price=0;                           
//---- buffers 
double Uptrend[];
double Dntrend[];
double ExtMapBuffer[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init()
  {
   IndicatorBuffers(3);
   SetIndexBuffer(0, Uptrend);
   //ArraySetAsSeries(Uptrend, true); 
   SetIndexBuffer(1, Dntrend);
   //ArraySetAsSeries(Dntrend, true); 
   SetIndexBuffer(2, ExtMapBuffer);
   ArraySetAsSeries(ExtMapBuffer, true);
//----
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
//----
   IndicatorShortName("Signal Line("+period+")");
   return(0);
  }
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit()
  { 
   return(0);
  } 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double WMA(int x, int p)
  {
   return(iMA(NULL, 0, p, 0, method, price, x));
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)
      return(-1);
//----
   int x=0;
   int p=MathSqrt(period);
   int e=Bars - counted_bars + period + 1;
//----
   double vect[], trend[];
//----
   if(e > Bars)
      e=Bars;
//----
   ArrayResize(vect, e);
   ArraySetAsSeries(vect, true);
   ArrayResize(trend, e);
   ArraySetAsSeries(trend, true);
//----
   for(x=0; x < e; x++)
     {
      vect[x]=2*WMA(x, period/2) - WMA(x, period);
      }
   for(x=0; x < e-period; x++)
//----
      ExtMapBuffer[x]=iMAOnArray(vect, 0, p, 0, method, x);
   for(x=e-period; x>=0; x--)
     {
      trend[x]=trend[x+1];
      if (ExtMapBuffer[x]> ExtMapBuffer[x+1]) trend[x] =1;
      if (ExtMapBuffer[x]< ExtMapBuffer[x+1]) trend[x] =-1;
      if (trend[x]>0)
        { 
         Uptrend[x]=ExtMapBuffer[x];
         if (trend[x+1]<0) Uptrend[x+1]=ExtMapBuffer[x+1];
         Dntrend[x]=EMPTY_VALUE;
        }
      else
         if (trend[x]<0)
           {
            Dntrend[x]=ExtMapBuffer[x];
            if (trend[x+1]>0) Dntrend[x+1]=ExtMapBuffer[x+1];
            Uptrend[x]=EMPTY_VALUE;
           }
      }
   return(0);
  }
//+------------------------------------------------------------------+ 

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+