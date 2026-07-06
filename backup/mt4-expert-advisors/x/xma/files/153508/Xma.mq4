// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74394

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
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property strict

input int period = 12; // Period:
input int treesold   = 3; // Limit:
input ENUM_MA_METHOD method1 = MODE_SMA; // Method1:
input ENUM_MA_METHOD method2 = MODE_SMA; // Method2:
input ENUM_APPLIED_PRICE price   = PRICE_CLOSE; // Price:

//---- buffers
double Line [];

//+------------------------------------------------------------------+
int OnInit()
{
  //--- indicator buffers mapping
    SetIndexStyle(0, DRAW_LINE);
    SetIndexDrawBegin(0, 0);
    SetIndexBuffer(0, Line);

    return (INIT_SUCCEEDED);
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
    double ma1, ma2;
 int start, i;
  if (prev_calculated == 0)
  {
    start = rates_total - period;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
    {
        ma1 = iMA(Symbol(), 0, period, 0, method1, price, i);
        ma2 = iMA(Symbol(), 0, period, 1, method2, price, i);
        if(MathAbs(ma1 - ma2) >= treesold * Point)
        {
            Line[i] = ma2;
        }
        else{
            Line[i] = Line[i + 1];
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