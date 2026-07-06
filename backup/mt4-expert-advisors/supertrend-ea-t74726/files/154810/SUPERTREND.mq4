// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74726

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_buffers 2
double TrendUp[], TrendDown[];
int changeOfTrend;
extern int Nbr_Periods = 10;
extern double Multiplier = 3.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0, TrendUp);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(0, "Trend Up");
   SetIndexBuffer(1, TrendDown);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(1, "Trend Down");
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
   int limit, i, flag, flagh, trend[5000];
   double up[5000], dn[5000], medianPrice, atr;
   int counted_bars = IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) counted_bars--;
   limit=Bars-counted_bars;
   //Print(limit);
   
//----
   for (i = Bars; i >= 0; i--) {
      TrendUp[i] = EMPTY_VALUE;
      TrendDown[i] = EMPTY_VALUE;
      atr = iATR(NULL, 0, Nbr_Periods, i);
      //Print("atr: "+atr[i]);
      medianPrice = (High[i]+Low[i])/2;
      //Print("medianPrice: "+medianPrice[i]);
      up[i]=medianPrice+(Multiplier*atr);
      //Print("up: "+up[i]);
      dn[i]=medianPrice-(Multiplier*atr);
      //Print("dn: "+dn[i]);
      trend[i]=1;
   
      
      if (Close[i]>up[i+1]) {
         trend[i]=1;
         if (trend[i+1] == -1) changeOfTrend = 1;
         //Print("trend: "+trend[i]);
         
      }
      else if (Close[i]<dn[i+1]) {
         trend[i]=-1;
         if (trend[i+1] == 1) changeOfTrend = 1;
         //Print("trend: "+trend[i]);
      }
      else if (trend[i+1]==1) {
         trend[i]=1;
         changeOfTrend = 0;       
      }
      else if (trend[i+1]==-1) {
         trend[i]=-1;
         changeOfTrend = 0;
      }

      if (trend[i]<0 && trend[i+1]>0) {
         flag=1;
         //Print("flag: "+flag);
      }
      else {
         flag=0;
         //Print("flagh: "+flag);
      }
      
      if (trend[i]>0 && trend[i+1]<0) {
         flagh=1;
         //Print("flagh: "+flagh);
      }
      else {
         flagh=0;
         //Print("flagh: "+flagh);
      }
      
      if (trend[i]>0 && dn[i]<dn[i+1])
         dn[i]=dn[i+1];
      
      if (trend[i]<0 && up[i]>up[i+1])
         up[i]=up[i+1];
      
      if (flag==1)
         up[i]=medianPrice+(Multiplier*atr);
         
      if (flagh==1)
         dn[i]=medianPrice-(Multiplier*atr);
         
      //-- Draw the indicator
      if (trend[i]==1) {
         TrendUp[i]=dn[i];
         if (changeOfTrend == 1) {
            TrendUp[i+1] = TrendDown[i+1];
            changeOfTrend = 0;
         }
      }
      else if (trend[i]==-1) {
         TrendDown[i]=up[i];
         if (changeOfTrend == 1) {
            TrendDown[i+1] = TrendUp[i+1];
            changeOfTrend = 0;
         }
      }
   }
   WindowRedraw();
      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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