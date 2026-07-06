// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74279

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
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 2
#property  indicator_color1  Gold
#property  indicator_color2  Gold
#property  indicator_width1  1
#property  indicator_width2  1

//---- indicator parameters
extern int periods = 20;

//---- indicator buffers
double     upper [];
double     lower [];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    //---- drawing settings
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);

    //---- indicator buffers mapping
    SetIndexBuffer(0, upper);
    SetIndexBuffer(1, lower);

    //---- name for DataWindow and indicator subwindow label
    IndicatorShortName("Donchian Channel(" + periods + ")");
    SetIndexLabel(0, "Upper");
    SetIndexLabel(1, "Lower");

    //---- initialization done
    return(0);
}
//+------------------------------------------------------------------+
//| now do the dance.                           |
//+------------------------------------------------------------------+
int start()
{
    int limit;
    int counted_bars = IndicatorCounted();

    //---- last counted bar will be recounted
    if(counted_bars > 0) counted_bars--;
    limit = Bars - counted_bars;

    //---- calculate values
    for(int i = 0; i < limit; i++) {
        upper[i] = iHigh(Symbol(), Period(), iHighest(Symbol(), Period(), MODE_HIGH, periods, i));
        lower[i] = iLow(Symbol(), Period(), iLowest(Symbol(), Period(), MODE_LOW, periods, i));
    }

    return(0);
}
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