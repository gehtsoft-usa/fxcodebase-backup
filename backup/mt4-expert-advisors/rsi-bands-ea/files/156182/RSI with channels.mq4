// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75078

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
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrYellow
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_width5  2

input int                inpRsiPeriod        = 14;          // RSI period
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE; // RSI price

input int                inpSmoothing        = 14;          // Smoothing period for RSI
input double             inpOverbought       = 70;          // Overbought level %
input double             inpOversold         = 30;          // Oversold level %
input double             inpUpperNeutral     = 55;          // Upper neutral level %
input double             inpLowerNeutral     = 45;          // Lower neutral level %

double bupu[],bupd[],bdnu[],bdnd[],rsi[];
//+------------------------------------------------------------------+
int OnInit() {
   SetIndexBuffer(0,bupu,INDICATOR_DATA);
   SetIndexBuffer(1,bupd,INDICATOR_DATA);
   SetIndexBuffer(2,bdnu,INDICATOR_DATA);
   SetIndexBuffer(3,bdnd,INDICATOR_DATA);
   SetIndexBuffer(4,rsi,INDICATOR_DATA);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
   
   int limit = prev_calculated>0 ? rates_total - prev_calculated + 1 : rates_total - 1;
   
   for(int i=limit;i>=0;i--) {
      Print(i);
      rsi[i] = iRSI(NULL,PERIOD_CURRENT,inpRsiPeriod,inpPrice,i);
      double _rsi = (rsi[i]!=EMPTY_VALUE) ? rsi[i] : 0;
      /* 
      bupu[i]     = iEma(_rsi-inpOverbought  ,inpSmoothing,index,0);
      bdnu[i]     = iEma(_rsi-inpOversold    ,inpSmoothing,index,1);
      bupd[i]     = iEma(_rsi-inpUpperNeutral,inpSmoothing,index,2);
      bdnd[i]     = iEma(_rsi-inpLowerNeutral,inpSmoothing,index,3);
      */
      double pr=2.0/(inpSmoothing+1.0);
      //bupu[i]     = (_rsi-inpOverbought) * pr + bupu[i+1]*(1-pr);
      if(i<rates_total-1) {
         bupu[i]     = (_rsi-inpOverbought) * pr + bupu[i+1]*(1-pr);
         bdnu[i]     = (_rsi-inpOversold) * pr + bdnu[i+1]*(1-pr);
         bupd[i]     = (_rsi-inpUpperNeutral) * pr + bupd[i+1]*(1-pr);
         bdnd[i]     = (_rsi-inpLowerNeutral) * pr + bdnd[i+1]*(1-pr);
      }else{
         bupu[i]     = (_rsi-inpOverbought);
         bdnu[i]     = (_rsi-inpOversold);
         bupd[i]     = (_rsi-inpUpperNeutral);
         bdnd[i]     = (_rsi-inpLowerNeutral);
      }
      
      rsi[i] -= 50;
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
#define _emaInstances 4
#define _emaRingSize 6
double workEma[_emaRingSize][_emaInstances];
//
//---
//


double iEma(double price, double period,int i, int _inst=0)
{
   int _indCurrent = (i  )%_emaRingSize;
   int _indPrevious = (i-1)%_emaRingSize;

   if(i>0 && period>1)
      workEma[_indCurrent][_inst] = workEma[_indPrevious][_inst] + (2.0/(1.0+period)) * (price-workEma[_indPrevious][_inst]);
   else   workEma[_indCurrent][_inst]=price;
   return(workEma[_indCurrent][_inst]);
}

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