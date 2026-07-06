// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74783
//
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
#property strict
#property indicator_separate_window

#property indicator_buffers 5
#property indicator_plots 3
#property indicator_type1  DRAW_LINE
#property indicator_color1 Red
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "Small"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Green
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label2 "Large"
#property indicator_type3  DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label3 "Normal"

//--- indicator buffers
double lineSmall[];
double lineLarge[];
double lineNormal[];
double small[];
double large[];

//--- indicator input
input int    Period     = 20;  // Indicator Periods
input double ratioSmall = 33;  // Small (0-100)
input double ratioLarge = 66;  // Large (0-100)

// ------------------------------------------------------------------
void OnInit()
{
  //--- indicator short name
  string short_name = "Ratio Small vs Large Candles";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, 2);

  //--- Buffers
  SetIndexBuffer(0, lineSmall);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Period);
  SetIndexBuffer(1, lineLarge);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Period);
  SetIndexBuffer(2, lineNormal);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, Period);
  SetIndexBuffer(3, small, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, large, INDICATOR_CALCULATIONS);
}

//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  if (rates_total < Period) return (0);

  int start;
  if (prev_calculated > 1)
    start = prev_calculated - 1;
  else {
    start = Period + 1;
  }

  for (int i = start; i < rates_total && !IsStopped(); i++) {

    double wick = (high[i] - low[i]) / 100;
    double body = fabs(close[i] - open[i]);

    if ((body / wick) < ratioSmall) {
      small[i] = 1;
    } else if ((body / wick) > ratioLarge) {
      large[i] = 1;
    }

    if (i > Period + 1) {

    double smallNumber = 0;
    double largeNumber = 0;
    for (int p = i - Period + 1; p <= i; p++) { smallNumber += small[p]; }
    for (int p = i - Period + 1; p <= i; p++) { largeNumber += large[p]; }

    lineSmall[i]  = smallNumber / Period;
    lineLarge[i]  = largeNumber / Period;
    lineNormal[i] = 1 - (lineSmall[i] + lineLarge[i]);
    }
  }

  return (rates_total);
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