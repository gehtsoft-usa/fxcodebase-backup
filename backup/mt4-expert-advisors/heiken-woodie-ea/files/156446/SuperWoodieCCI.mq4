//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75144

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
//----
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 White // CCI Colour (note the superfluous vowel, cheers mates ;)
#property indicator_color2 Yellow // TCCI Colour
#property indicator_color3 LimeGreen // Long Trend Histogram Colour 
#property indicator_color4 Red // Short Trend Histogram Colour
#property indicator_color5 Blue // No Trend Histogram Colour
//---- input parameters
extern int       CCI_Period=50;
extern int       TCCI_Period=0;
//---- buffers
double ExtCCIBuffer[];
double ExtTCCIBuffer[];
double ExtLongHistBuffer[];
double ExtShortHistBuffer[];
double ExtFlatHistBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(0,ExtCCIBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtTCCIBuffer);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(2,ExtLongHistBuffer);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(3,ExtShortHistBuffer);
   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(4,ExtFlatHistBuffer);
   ArrayInitialize(ExtCCIBuffer,0);
   ArrayInitialize(ExtTCCIBuffer,0);
   ArrayInitialize(ExtLongHistBuffer,0);
   ArrayInitialize(ExtShortHistBuffer,0);
   ArrayInitialize(ExtFlatHistBuffer,0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
  int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  int start()
  {
   int i,j;
   int uptrending=0,downtrending=0;
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+6;
   
   //---- main loop
     for(i=0; i<limit; i++)
     {
      ExtCCIBuffer[i]=iCCI(NULL,0,CCI_Period,PRICE_TYPICAL,i);
      ExtTCCIBuffer[i]=iCCI(NULL,0,TCCI_Period,PRICE_TYPICAL,i);
      ExtFlatHistBuffer[i]=ExtCCIBuffer[i];
     }
     for(i=0;i<limit;i++)
     {
        for(j=0;j<6;j++)
        {
           if(ExtCCIBuffer[i+j] > 0)
           {
            uptrending++;
            } else if(ExtCCIBuffer[i+j] < 0)
               {
               uptrending=0;
               }
        }
        if(uptrending>5)
        {
         ExtLongHistBuffer[i]=ExtCCIBuffer[i];
         ExtShortHistBuffer[i]=0;
         ExtFlatHistBuffer[i]=0;
        }
     }
     for(i=0;i<limit;i++)
     {
        for(j=0;j<6;j++)
        {
           if(ExtCCIBuffer[i+j] < 0)
           {
            downtrending++;
            }
             else if(ExtCCIBuffer[i+j] > 0)
            {
               downtrending=0;
            }
        }
        if(downtrending>5)
        {
         ExtShortHistBuffer[i]=ExtCCIBuffer[i];
         ExtLongHistBuffer[i]=0;
         ExtFlatHistBuffer[i]=0;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 