//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75200

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |
//|                                                                         mario.jemic@gmail.com  |
//|                                                        https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots 1
#property indicator_label1 "ARIMA_MA"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

// NOTE: Inputs
// ------------------------------------------------------------------
input int p                = 1; // AR Order (p):
input int d                = 1; // Differencing Order (d):
input int q                = 1; // MA Order (q):
input int periods          = 14; // MA periods:

//--- indicator buffers
double ARIMA[];
double MA[];

void OnInit()
{
    //--- indicator short name
    string short_name = "ARIMA or MA";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    SetIndexBuffer(0, ARIMA);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 10);
    SetIndexBuffer(1, MA);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);

}


int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start;
    if (prev_calculated > 1)
        start = prev_calculated - 1;
    else {
        start = periods+1+p+q+d;
    }

    for (int i = start; i < rates_total && !IsStopped(); i++) {
        double sum = 0;
        for (int j = 1; j <= periods; j++) 
        sum += close[i-j];        
        MA[i] = sum / periods;
    }

    for (int i = start; i < rates_total && !IsStopped(); i++) {
        
        double ar = 0;
        for (int j = 1; j <= p; j++) ar = ar + MA[i-j];
        
        double ma = 0;
        for (int j = 1; j <= q; j++) ma = ma + (MA[i-j]-MA[i-j-d]);


        double diff = MA[i] - MA[i-d];
        ARIMA[i] = diff + ar + ma;        

    }

    return (rates_total);
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