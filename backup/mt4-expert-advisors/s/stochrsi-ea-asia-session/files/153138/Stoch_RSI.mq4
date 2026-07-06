// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74307

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

//--- plot Main
#property indicator_label1  "K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
input int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
input ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double         KBuffer[];
double         DBuffer[];
double         RSIBuffer[];
double         StochBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorBuffers(4);
   IndicatorDigits(_Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0,KBuffer);
   SetIndexBuffer(1,DBuffer);
   SetIndexBuffer(2,RSIBuffer);
   SetIndexBuffer(3,StochBuffer);

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                const int &spread[])
{
//---
   int limit=prev_calculated==0?rates_total-(InpRSIPeriod+1):rates_total-prev_calculated+1;

   for(int i=limit; i>=0; i--)
   {
      RSIBuffer[i]=iRSI(_Symbol,_Period,InpRSIPeriod,InpRSIAppliedPrice,i);
      if(i<rates_total-(InpRSIPeriod+2))                 StochBuffer[i]=Stoch(RSIBuffer, RSIBuffer, RSIBuffer, InpStochastikPeriod,i,rates_total);
      if(StochBuffer[i+InpStockKPeriod-1]!=EMPTY_VALUE)  KBuffer[i]=SimpleMA(i,InpStockKPeriod,StochBuffer,rates_total);
      if(KBuffer[i+InpStockDPeriod-1]!=EMPTY_VALUE)      DBuffer[i]=SimpleMA(i,InpStockDPeriod,KBuffer,rates_total);
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| calculating stochastic                                           |
//+------------------------------------------------------------------+
double Stoch(const double &source[], double &high[], double &low[], int length, int shift, const int &rates_total)
{
   if(shift+length>=rates_total)           return EMPTY_VALUE;

   double Highest = Highest(high,length,shift);
   double Lowest = Lowest(low,length,shift);
   if(Highest-Lowest==0)         return EMPTY_VALUE;
   return 100 * (source[shift] - Lowest) / (Highest-Lowest);
}
//+------------------------------------------------------------------+
//| find lowest value in prev. X periods                             |
//+------------------------------------------------------------------+
double Lowest(double &low[], int length, int shift)
{
   double Result=0;
   for(int i=shift; i<=shift+length; i++)
   {
      if(Result==0 || (low[i]<Result && low[i]!=EMPTY_VALUE))
      {
         Result=low[i];
      }
   }

   return Result;
}
//+------------------------------------------------------------------+
//| find highest value in prev. X periods                            |
//+------------------------------------------------------------------+
double Highest(double &high[], int length, int shift)
{
   double Result=0;
   for(int i=shift; i<=shift+length; i++)
   {
      if(Result==0 || (high[i]>Result && high[i]!=EMPTY_VALUE))
      {
         Result=high[i];
      }
   }

   return Result;
}
//+------------------------------------------------------------------+
//| calculating simple moving average of an array                    |
//+------------------------------------------------------------------+
double SimpleMA(const int position,const int period,const double &price[], const int &rates_total)
{
//---
   double result=0.0;
   if(position<=rates_total-period && period>0)
   {
      for(int i=0; i<period; i++)
      {
         if(price[position+i]!=EMPTY_VALUE)
         {
            result+=price[position+i];
         }
      }
      result/=period;
   }
   return(result);
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