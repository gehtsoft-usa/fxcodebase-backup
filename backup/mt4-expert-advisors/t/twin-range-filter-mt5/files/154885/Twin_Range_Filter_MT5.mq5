// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74747

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
#property indicator_chart_window

#include <MovingAverages.mqh>

#property indicator_buffers 9
#property indicator_plots 1
#property  indicator_type1  DRAW_COLOR_LINE
#property indicator_color1 Green, Crimson
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "LineColor"

//--- indicator buffers
double line[];
double lineColor[];
double Delta[];
double MA_A[];
double MA_B[];
double MA_AS[];
double MA_BS[];
double upward[];
double downward[];

int seeking = 0;


// NOTE: Inputs
// ------------------------------------------------------------------
input int    per1       = 27;                  // Fast MA:
input double mult1      = 1.6;                 // Fast Range:
input int    per2       = 55;                  // Slow MA:
input double mult2      = 2;                   // Slow Range:

//--- indicator input
int wper1 = per1 * 2 - 1;
int wper2 = per2 * 2 - 1;

// ------------------------------------------------------------------
void OnInit()
{
  //--- Buffers

  SetIndexBuffer(0, line, INDICATOR_DATA);
  PlotIndexSetInteger(0,PLOT_LINE_WIDTH,0); 
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, per2);
  SetIndexBuffer(1, lineColor, INDICATOR_COLOR_INDEX);

  SetIndexBuffer(2, Delta, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, MA_A, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, MA_B, INDICATOR_CALCULATIONS);
  SetIndexBuffer(5, MA_AS, INDICATOR_CALCULATIONS);
  SetIndexBuffer(6, MA_BS, INDICATOR_CALCULATIONS);
  SetIndexBuffer(7, upward, INDICATOR_CALCULATIONS);
  SetIndexBuffer(8, downward, INDICATOR_CALCULATIONS);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
  if (rates_total < per2) return (0);

  int start;
  if (prev_calculated > 1)
    start = prev_calculated - 1;
  else {
    start = per2 + 1;
  }


  for (int i = start; i < rates_total && !IsStopped(); i++) {
   
   Delta[i] = fabs(close[i] - close[i-1]);
   MA_A[i] = SimpleMA(i, per1, Delta);
   MA_B[i] = SimpleMA(i, per2, Delta);
   MA_AS[i] = SimpleMA(i, wper1, MA_A);
   MA_BS[i] = SimpleMA(i, wper2, MA_B);

    double Central =  (MA_AS[i]*mult1 + MA_BS[i]*mult2) / 2;
    
    // line[i] = line[i-1];

    if(close[i] >=line[i-1])
    {
        if(close[i] - Central < line[i-1])
        {
            line[i]=line[i-1];
        } else 
        {
            line[i] = close[i] - Central;
        }      

    } 
    if(close[i] < line[i-1]) {
        if (close[i] + Central > line[i-1])
        { 
            line[i] = line[i-1];
        } else 
        {
            line[i] = close[i] + Central;
        }        
    }

        if(close[i] > close[i-1] && close[i] > line[i-1] && line[i]>line[i-1])
        {
            lineColor[i] = 0;
        } 
        if(close[i] < close[i-1] && close[i] < line[i-1] && line[i]<line[i-1])
        {
            lineColor[i] = 1;
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