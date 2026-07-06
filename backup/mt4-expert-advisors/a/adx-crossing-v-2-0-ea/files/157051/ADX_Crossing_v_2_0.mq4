// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75298

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
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
//---- input parameters
extern int ADXbars=50;
extern int CountBars=350;
extern bool UseSound=True;
extern string SoundFile="wait.waw";
//---- buffers
double val1[];
double val2[];
double b4plusdi,nowplusdi,b4minusdi,nowminusdi;
bool SoundBuy=False;
bool SoundSell=False;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,108);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,108);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| AltrTrend_Signal_v2_2                                            |
//+------------------------------------------------------------------+
int start()
  {
   if (CountBars>=Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars);
   SetIndexDrawBegin(1,Bars-CountBars);
   int i,shift,limit,CountedBars=IndicatorCounted();
   if (CountedBars < 1)
     {
      for(i=0; i<=CountBars; i++) {val1[i]=0.0; val2[i]=0.0;}
     }

   if(CountedBars > 0) CountedBars--;
//----   
   limit=Bars - CountedBars;
//----
   for(shift=limit; shift>=0; shift--)
     {
      b4plusdi=iADX(NULL,0,ADXbars,PRICE_CLOSE,MODE_PLUSDI,shift+1);
      nowplusdi=iADX(NULL,0,ADXbars,PRICE_CLOSE,MODE_PLUSDI,shift);
      b4minusdi=iADX(NULL,0,ADXbars,PRICE_CLOSE,MODE_MINUSDI,shift+1);
      nowminusdi=iADX(NULL,0,ADXbars,PRICE_CLOSE,MODE_MINUSDI,shift);
      if (b4plusdi<b4minusdi && nowplusdi>nowminusdi)
        {
         val1[shift]=Low[shift]-5*Point;
        }
      if (b4plusdi>b4minusdi && nowplusdi<nowminusdi)
        {
         val2[shift]=High[shift]+5*Point;
        }
     }
   if (val1[0]!=EMPTY_VALUE && val1[0]!=0 && SoundBuy)
     {
      SoundBuy=False;
      if (UseSound) PlaySound (SoundFile);
     }
   if (!SoundBuy && (val1[0]==EMPTY_VALUE || val1[0]==0)) SoundBuy=True;
   if (val2[0]!=EMPTY_VALUE && val2[0]!=0 && SoundSell)
     {
      SoundSell=False;
      if (UseSound) PlaySound (SoundFile);
     }
   if (!SoundSell && (val2[0]==EMPTY_VALUE || val2[0]==0)) SoundSell=True;
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
