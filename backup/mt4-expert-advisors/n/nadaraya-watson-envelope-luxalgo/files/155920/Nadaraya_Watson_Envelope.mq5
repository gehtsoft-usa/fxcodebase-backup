//Available @  https://fxcodebase.com/ 

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
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_width1  2
#property indicator_width2  2
#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_applied_price PRICE_WEIGHTED
//--- input parameters
input int                Length=500;              // Bars Count
input int                Bandwidth=17;                // Bandwidth
input double             Multiplayer=1.5;
// n = get the bar index

//--- indicator buffers
double                   ExtUpBuffer[];
double                   ExtDownBuffer[];
double                   ExtCABuffer[];
double                   y[]; // for calculation
int                      ExtBarsHandle;
int                      k = 2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUpBuffer);
   SetIndexBuffer(1,ExtDownBuffer);
   SetIndexBuffer(2,y,INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,0);
   PlotIndexGetInteger(1,PLOT_DRAW_BEGIN,0);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
//--- name for DataWindow
   string short_name=StringFormat("Nadraya",Length);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name+" Upper");
   PlotIndexSetString(1,PLOT_LABEL,short_name+" Lower");
   
   ExtBarsHandle = iMA(_Symbol,_Period,Length,0,MODE_EMA,PRICE_WEIGHTED);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   if(IsStopped()) return 0;
   int calculated=BarsCalculated(ExtBarsHandle);
   if(rates_total<calculated) return(0);
   if(rates_total<Length)
      return(0);
   
   int copyBars = 0;
   if (prev_calculated>rates_total || prev_calculated<=0){
      copyBars = rates_total;
   }
   else{
      copyBars = rates_total-prev_calculated;
      if(prev_calculated>0) copyBars++;
   }
   int start=prev_calculated-1;
   if(start<Length)
      start=Length;
   
   
   double sum_e = 0.0;
   for(int i=rates_total-Length; i<rates_total && !IsStopped(); i++){
      double sum = 0.0;
      double sumw= 0.0;
      for(int j = rates_total-Length;j<rates_total-1;j++){
         double w = MathExp(-(MathPow(i-j,2)/(Bandwidth*Bandwidth*2)));
         sum += price[j]*w;
         sumw += w;
      }
      double y2 = sum/sumw;
      sum_e += (MathAbs(price[i]-y2));
      y[i] = y2;
   }
   double mae = sum_e/Length*Multiplayer;
   for(int i=rates_total-Length+1; i<rates_total && !IsStopped(); i++){
      double y2 = y[i];
      double y1 = y[i-1];
         
      ExtUpBuffer[i]=y2+mae;
      ExtDownBuffer[i]=y2-mae;
      //Print(mae);
      //Print(y[i]);
   }
//--- return value of prev_calculated for next call
   return(rates_total);
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