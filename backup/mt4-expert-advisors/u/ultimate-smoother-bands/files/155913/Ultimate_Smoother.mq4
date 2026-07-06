// -- Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75007
// 
// --+------------------------------------------------------------------------------------------------+
// --|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
// --|                                                                         http://fxcodebase.com  |
// --+------------------------------------------------------------------------------------------------+
// --|                                                                   Developed by : Mario Jemic   |                    
// --|                                                                       mario.jemic@gmail.com    |
// --|                                               https://appliedmachinelearning.systems/contact/  | 
// --+------------------------------------------------------------------------------------------------+
// 
// --+------------------------------------------------------------------------------------------------+
// --|                                           Our work would not be possible without your support. |
// --+------------------------------------------------------------------------------------------------+
// --|                                                               Paypal:  https://goo.gl/9Rj74e   |
// --|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
// --|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
// --+------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

double Line[];

input int    periods               = 10;

int OnInit()
{
  SetIndexBuffer(0, Line, INDICATOR_DATA);
  SetIndexArrow(0, 233);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 1, RoyalBlue);
  
  return (INIT_SUCCEEDED);
}


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
  int start, i;
  if (prev_calculated == 0) { start = rates_total - periods; } else { start = rates_total - (prev_calculated - 1); }

  for (i = start; i >= 0; i--)
  {
    double a1 = exp(-1.414 * 3.1415 / periods);
    double c2 = 2.0 * a1 * cos(1.414 * 3.1415 / periods);
    double c3 = -a1 * a1;
    double c1 = (1.0 + c2 - c3) / 4.0;

    Line[i]= (1.0 - c1) * close[i] + (2.0 * c1 - c2) *  close[i+1] - (c1 + c3) *  close[i+2] + c2 * Line[i+1] + c3 *  Line[i+2];

  }
    return (rates_total);
}


// --+------------------------------------------------------------------------------------------------+
// --|                                                                    We appreciate your support. | 
// --+------------------------------------------------------------------------------------------------+
// --|                                                               Paypal:  https://goo.gl/9Rj74e   |
// --|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
// --|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
// --+------------------------------------------------------------------------------------------------+
// --|  Cryptocurrency  |  Network                    |  Address                                      |
// --+------------------------------------------------+-----------------------------------------------+
// --|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
// --|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
// --|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
// --|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
// --|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
// --|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
// --+------------------------------------------------+-----------------------------------------------+