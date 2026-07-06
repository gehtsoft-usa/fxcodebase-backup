
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=750216

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
#property indicator_chart_window

/*-------------------------------------------------------------------
10.06.2019  v2 - Bands calculation with StdDev
--------------------------------------------------------------------*/

#property indicator_buffers 12

//---
#property indicator_color1  clrDodgerBlue       //TMA
#property indicator_color2  clrTomato

#property indicator_color3  clrChocolate        //upper bands
#property indicator_color4  clrHotPink
#property indicator_color5  clrMagenta
#property indicator_color6  clrMagenta

#property indicator_color7  clrChocolate        //lower bands
#property indicator_color8  clrSpringGreen
#property indicator_color9  clrMediumSeaGreen
#property indicator_color10 clrMediumSeaGreen

#property indicator_color11  clrAqua       //Signal arrows
#property indicator_color12  clrOrange

//---
#property indicator_width1  4
#property indicator_width2  4

#property indicator_width3  1
#property indicator_width4  2
#property indicator_width5  1
#property indicator_width6  1

#property indicator_width7  1
#property indicator_width8  2
#property indicator_width9  1
#property indicator_width10 1

#property indicator_width11  2
#property indicator_width12  2

//---
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID

#property indicator_style3  STYLE_DASH
#property indicator_style4  STYLE_SOLID
#property indicator_style5  STYLE_SOLID
#property indicator_style6  STYLE_DOT

#property indicator_style7  STYLE_DASH
#property indicator_style8  STYLE_SOLID
#property indicator_style9  STYLE_SOLID
#property indicator_style10 STYLE_DOT


//+------------------------------------------------------------------+
//|         INPUTS
//+------------------------------------------------------------------+
extern int                   HalfLength      =  6;            // Half Length
input int                    ma_period       =  6;             // MA averaging period
input int                    ma_shift        =  0;             // MA shift at right
input ENUM_MA_METHOD         ma_method       =  MODE_EMA;     // MA averaging method
input ENUM_APPLIED_PRICE     applied_price   = PRICE_CLOSE;   // Applied Price
input int                    ATR_Period      =  6;           // ATR Period
input bool                   Show_Comments   =  true;
input int                    Total_Bars      = 2000;
input string ___Bands_Deviation_Multiplier = "----------------------------------------------";
input double ATR_Multiplier_Band1   = 1.27;
input double ATR_Multiplier_Band2   = 1.618;
input double ATR_Multiplier_Band3   = 2.618;
input double ATR_Multiplier_Band4   = 4.0;
//
input string ___Bands_To_Draw = "----------------------------------------------";
input bool Draw_Band1               = true;
input bool Draw_Band2               = true;
input bool Draw_Band3               = true;
input bool Draw_Band4               = true;
//====================================================================
//
//--- constants
string CR = "\n";
//---
//--- buffers
double tmaUP[], tmaDN[], tmaCentered[];
double bandUP1[], bandUP2[], bandUP3[], bandUP4[];
double bandDN1[], bandDN2[], bandDN3[], bandDN4[];
double slope[];
double arrowUP[], arrowDN[];
//---
//--- variables
//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(14);
   HalfLength = MathMax(HalfLength, 1);
//--- indicator buffers mapping
   SetIndexBuffer(0, tmaUP);
   SetIndexLabel(0, "TMA UP");
   SetIndexBuffer(1, tmaDN);
   SetIndexLabel(1, "TMA DOWN");
   SetIndexBuffer(2, bandUP1);
   SetIndexLabel(2, "Upper Band 1");
   SetIndexBuffer(3, bandUP2);
   SetIndexLabel(3, "Upper Band 2");
   SetIndexBuffer(4, bandUP3);
   SetIndexLabel(4, "Upper Band 3");
   SetIndexBuffer(5, bandUP4);
   SetIndexLabel(5, "Upper Band 4");
   SetIndexBuffer(6, bandDN1);
   SetIndexLabel(6, "Lower Band 1");
   SetIndexBuffer(7, bandDN2);
   SetIndexLabel(7, "Lower Band 2");
   SetIndexBuffer(8, bandDN3);
   SetIndexLabel(8, "Lower Band 3");
   SetIndexBuffer(9, bandDN4);
   SetIndexLabel(9, "Lower Band 4");
   int iArrowUP = 233;
   int iArrowDN = 234;
   SetIndexBuffer(10, arrowUP);
   SetIndexLabel(10, "LONG signal");
   SetIndexStyle(10, DRAW_ARROW);
   SetIndexArrow(10, iArrowUP);
   SetIndexBuffer(11, arrowDN);
   SetIndexLabel(11, "SHORT signal");
   SetIndexStyle(11, DRAW_ARROW);
   SetIndexArrow(11, iArrowDN);
//--- more buffers
   SetIndexBuffer(12, tmaCentered);
   SetIndexBuffer(13, slope);
//--- settings
   for(int ii = 0; ii <= 13; ii++)
     {
      //SetIndexShift(ii,ma_shift);
      SetIndexEmptyValue(ii, EMPTY_VALUE);
      SetIndexDrawBegin(ii, HalfLength + ATR_Period + 10);
     }
   IndicatorDigits(Digits + 3);
//----
   string shortName = StringConcatenate(WindowExpertName(), CR, "================", CR);
   IndicatorShortName(shortName);
   if(Show_Comments)
      Comment(shortName);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(Show_Comments == true)
      Comment("");
  }
//
//
//
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
   int i, j, k, limit;
//   int counted_bars=IndicatorCounted();
//
//   if(counted_bars<0) return(-1);
//   if(counted_bars>0) counted_bars--;
//   limit=MathMin(Bars-1,Bars-counted_bars+HalfLength);
//   //if(returnBars) { buffer1[0]=limit+1; return(0); }
//##############
//---
   if(rates_total <= HalfLength)
      return(0);
//--- last counted bar will be recounted
   limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;
   else
      limit = rates_total - HalfLength - 1 - ATR_Period;
//limit=rates_total-HalfLength-1;
//limit=rates_total-HalfLength-1-ma_shift;
//limit=rates_total-HalfLength-1;
   limit = MathMin(limit, Total_Bars);
//##############
//--- settings
//for(int ii=0; ii<=13; ii++)
//  {
//   SetIndexDrawBegin(ii,limit);
//  }
//--- TMA centered ----------------------------------------
   for(i = limit; i >= 0 && !IsStopped(); i--)
     {
      double sum = (HalfLength + 1) * iMA(NULL, 0, ma_period, 0, ma_method, applied_price, i);
      double sumw = (HalfLength + 1);
      for(j = 1, k = HalfLength; j <= HalfLength; j++, k--)
        {
         sum  += k * iMA(NULL, 0, ma_period, 0, ma_method, applied_price, i + j);
         sumw += k;
         if(j <= i)
           {
            sum  += k * iMA(NULL, 0, ma_period, 0, ma_method, applied_price, i - j);
            sumw += k;
           }
        }
      tmaCentered[i] = sum / sumw;
     }
//--- colored TMA -----------------------------------------
   for(i = limit; i >= 0 && !IsStopped(); i--)
     {
      if(tmaCentered[i + 1] != 0)
         slope[i] = 10000 * (tmaCentered[i] - tmaCentered[i + 1]) / tmaCentered[i + 1];
     }
   for(i = limit; i >= 0 && !IsStopped(); i--)
     {
      int ii = i + 1;
      tmaUP[i] = EMPTY_VALUE;
      tmaDN[i] = EMPTY_VALUE;
      if(slope[ii] >= 0)
        {
         tmaUP[i] = tmaCentered[i];
         if(slope[ii + 1] < 0)
           {
            tmaUP[i + 1] = tmaCentered[i + 1];
           }
        }
      else
         if(slope[ii] < 0)
           {
            tmaDN[i] = tmaCentered[i];
            if(slope[ii + 1] > 0)
               tmaDN[i + 1] = tmaCentered[i + 1];
           }
     }
//--- TMA bands -------------------------------------------
   double deviation = 0;
//   int limit0=limit-ATR_Period;
//
//   Comment("limit= ",limit,CR,
//           "limit0= ",limit0,CR,CR,
//           "rates_total= ",rates_total,CR,
//           "prev_calculated= ",prev_calculated);
//limit=200;
//for(i=limit; i>=0 && !IsStopped(); i--)
   for(i = limit; i >= 0 && !IsStopped(); i--)
     {
      bandUP1[i] = EMPTY_VALUE;
      bandUP2[i] = EMPTY_VALUE;
      bandUP3[i] = EMPTY_VALUE;
      bandUP4[i] = EMPTY_VALUE;
      bandDN1[i] = EMPTY_VALUE;
      bandDN2[i] = EMPTY_VALUE;
      bandDN3[i] = EMPTY_VALUE;
      bandDN4[i] = EMPTY_VALUE;
      //--- calculate StdDev ------------------------------
      double StdDev_dTmp = 0;
      for(int ij = 0; ij < ATR_Period; ij++)
         StdDev_dTmp += MathPow(Close[i + ij] - tmaCentered[i + ij], 2);
      deviation = MathSqrt(StdDev_dTmp / ATR_Period);
      //--- Band distances --------------------------------
      double bandDistance1 = deviation * ATR_Multiplier_Band1;
      double bandDistance2 = deviation * ATR_Multiplier_Band2;
      double bandDistance3 = deviation * ATR_Multiplier_Band3;
      double bandDistance4 = deviation * ATR_Multiplier_Band4;
      double tmaValue = tmaCentered[i];
      bandUP1[i] = tmaValue + bandDistance1;
      bandUP2[i] = tmaValue + bandDistance2;
      bandUP3[i] = tmaValue + bandDistance3;
      bandUP4[i] = tmaValue + bandDistance4;
      bandDN1[i] = tmaValue - bandDistance1;
      bandDN2[i] = tmaValue - bandDistance2;
      bandDN3[i] = tmaValue - bandDistance3;
      bandDN4[i] = tmaValue - bandDistance4;
     }
//--- Signals -------------------------------------------
   for(i = limit; i >= 0 && !IsStopped(); i--)
     {
      double dClose0 = Close[i];
      double dClose1 = Close[i + 1];
      arrowUP[i] = EMPTY_VALUE;
      arrowDN[i] = EMPTY_VALUE;
      //--- LONG signals ----------------------------------
      if(slope[i] >= 0)
        {
         if(dClose0 < bandDN4[i] && dClose1 > bandDN4[i + 1])
            arrowUP[i] = Low[i];
         else
            if(dClose0 < bandDN3[i] && dClose1 > bandDN3[i + 1])
               arrowUP[i] = Low[i];
            else
               if(dClose0 < bandDN2[i] && dClose1 > bandDN2[i + 1])
                  arrowUP[i] = Low[i];
               else
                  if(dClose0 < bandDN1[i] && dClose1 > bandDN1[i + 1])
                     arrowUP[i] = Low[i];
        }
      //--- SHORT signals ----------------------------------
      if(slope[i] < 0)
        {
         if(dClose0 > bandUP4[i] && dClose1 < bandUP4[i + 1])
            arrowDN[i] = High[i];
         else
            if(dClose0 > bandUP3[i] && dClose1 < bandUP3[i + 1])
               arrowDN[i] = High[i];
            else
               if(dClose0 > bandUP2[i] && dClose1 < bandUP2[i + 1])
                  arrowDN[i] = High[i];
               else
                  if(dClose0 > bandUP1[i] && dClose1 < bandUP1[i + 1])
                     arrowDN[i] = High[i];
        }
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