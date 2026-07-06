// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74821

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

#include <MovingAverages.mqh>
//---
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 7
#property indicator_type1  DRAW_LINE
#property indicator_color1 Black

#property indicator_type2  DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_color2 Gray

#property indicator_type3  DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_color3 RoyalBlue

#property indicator_type4  DRAW_LINE
#property indicator_style4 STYLE_DOT
#property indicator_color4 Navy

#property indicator_type5  DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_color5 Gray

#property indicator_type6  DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_color6 RoyalBlue

#property indicator_type7  DRAW_LINE
#property indicator_style7 STYLE_DOT
#property indicator_color7 Navy


//--- input parametrs
input int    uPeriod     = 20;   // Period
input int    uShift      = 0;    // Shift
input double uDeviation1 = 1.0;  // Deviation 1
input double uDeviation2 = 2.0;  // Deviation 2
input double uDeviation3 = 3.0;  // Deviation 3
//--- global variables
int    Periods, Shift;
double Deviation1, Deviation2, Deviation3;
int    plotBegin = 0;
//--- indicator buffer
double bMidle[];
double bUpper1[];
double bUpper2[];
double bUpper3[];
double bLower1[];
double bLower2[];
double bLower3[];
double bStdDev[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
  // clang-format off
  //--- check for input values
  if (uPeriod < 2)        { Periods   = 20;  } else Periods   = uPeriod;
  if (uShift  < 0)        { Shift     = 0;   } else Shift     = uShift; 
  if (uDeviation1 <= 0.0) { Deviation1 = 1.0; } else Deviation1 = uDeviation1;
  if (uDeviation2 <= 0.0) { Deviation2 = 2.0; } else Deviation2 = uDeviation2;
  if (uDeviation3 <= 0.0) { Deviation3 = 3.0; } else Deviation3 = uDeviation3;
  // clang-format on

  //--- define buffers
  SetIndexBuffer(0, bMidle); 
  SetIndexBuffer(1, bUpper1);
  SetIndexBuffer(2, bUpper2);
  SetIndexBuffer(3, bUpper3);
  SetIndexBuffer(4, bLower1);
  SetIndexBuffer(5, bLower2);
  SetIndexBuffer(6, bLower3);
  SetIndexBuffer(7, bStdDev, INDICATOR_CALCULATIONS);
  //--- set index labels
  PlotIndexSetString(0, PLOT_LABEL, "Bands(" + string(Periods) + ") Middle");
  PlotIndexSetString(1, PLOT_LABEL, "Bands(" + string(Periods) + ") Upper1");
  PlotIndexSetString(2, PLOT_LABEL, "Bands(" + string(Periods) + ") Upper2");
  PlotIndexSetString(3, PLOT_LABEL, "Bands(" + string(Periods) + ") Upper3");
  PlotIndexSetString(4, PLOT_LABEL, "Bands(" + string(Periods) + ") Lower1");
  PlotIndexSetString(5, PLOT_LABEL, "Bands(" + string(Periods) + ") Lower2");
  PlotIndexSetString(6, PLOT_LABEL, "Bands(" + string(Periods) + ") Lower3");
  //--- indicator name
  IndicatorSetString(INDICATOR_SHORTNAME, "BB3");
  //--- indexes draw begin settings
  plotBegin = Periods - 1;
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Periods);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Periods);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, Periods);
  PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, Periods);
  PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, Periods);
  PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, Periods);
  PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, Periods);
  //--- indexes shift settings
  PlotIndexSetInteger(0, PLOT_SHIFT, Shift);
  PlotIndexSetInteger(1, PLOT_SHIFT, Shift);
  PlotIndexSetInteger(2, PLOT_SHIFT, Shift);
  PlotIndexSetInteger(3, PLOT_SHIFT, Shift);
  PlotIndexSetInteger(4, PLOT_SHIFT, Shift);
  PlotIndexSetInteger(5, PLOT_SHIFT, Shift);
  PlotIndexSetInteger(6, PLOT_SHIFT, Shift);  
  //--- number of digits of indicator value
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
}

//+------------------------------------------------------------------+
//| BB3                                                              |
//+------------------------------------------------------------------+

int OnCalculate(const int     rates_total,
                const int     prev_calculated,
                const int     begin,
                const double& price[])
{
  if (rates_total < plotBegin)
    return (0);
  
  if (plotBegin != Periods + begin) {
    plotBegin = Periods + begin;
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, plotBegin);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, plotBegin);
    PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, plotBegin);
    PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, plotBegin);
    PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, plotBegin);
    PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, plotBegin);
    PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, plotBegin);
  }
  
  int pos;
  if (prev_calculated > 1) pos = prev_calculated - 1; else pos = 0;
  
  //--- main cycle
  for (int i = pos; i < rates_total && !IsStopped(); i++) {
    bMidle[i] = SimpleMA(i, Periods, price);
    //--- StdDev
    bStdDev[i] = StdDev_Func(i, price, bMidle, Periods);
    //--- upper line
    bUpper1[i] = bMidle[i] + Deviation1 * bStdDev[i];
    bUpper2[i] = bMidle[i] + Deviation2 * bStdDev[i];
    bUpper3[i] = bMidle[i] + Deviation3 * bStdDev[i];
    //--- lower line
    bLower1[i] = bMidle[i] - Deviation1 * bStdDev[i];
    bLower2[i] = bMidle[i] - Deviation2 * bStdDev[i];
    bLower3[i] = bMidle[i] - Deviation3 * bStdDev[i];
  }

  return (rates_total);
}

double StdDev_Func(const int position, const double& price[], const double& ma_price[], const int period)
{
  double std_dev = 0.0;

  if (position >= period) {
    for (int i = 0; i < period; i++)
      std_dev += MathPow(price[position - i] - ma_price[position], 2.0);
    std_dev = MathSqrt(std_dev / period);
  }

  return (std_dev);
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