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
#property indicator_buffers 6
#property indicator_plots 2
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 Green
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

//--- indicator buffers
double LineUp[];
double LineDn[];
double Indicator1[];
double Indicator2[];
double TrueRange[];
double source[];

// ------------------------------------------------------------------
input int periods = 20;

enum calc_mode { Channel, Bands };
input calc_mode mode       = Channel; // Mode:
input double    Multiplier = 2;       // Multiplier:

int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, EMPTY, 2);
    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, EMPTY, 2);
    SetIndexBuffer(2, Indicator2);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexBuffer(3, Indicator1);
    SetIndexStyle(3, DRAW_NONE);
    SetIndexBuffer(4, TrueRange);
    SetIndexStyle(4, DRAW_NONE);
    SetIndexBuffer(5, source);
    SetIndexStyle(5, DRAW_NONE);

    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    // clang-format off
    int start, i;
    if (prev_calculated == 0) { start = rates_total - periods; } else { start = rates_total - (prev_calculated - 1); } // clang-format on

    for (i = start; i >= 0; i--) {

        double hl = fabs(high[i] - low[i]);
        double hc = fabs(high[i] - close[i + 1]);
        double lc = fabs(low[i] - close[i + 1]);
        double tr = hl;
        if (tr < hc) tr = hc;
        if (tr < lc) tr = lc;
        TrueRange[i]  = tr;
        Indicator1[i] = iCustom(NULL, 0, "Ultimate_Smoother", periods, 0, i);
        source[i] = pow(close[i] - Indicator1[i], 2);
        
    }

    for (i = start; i >= 0; i--) {

        if (mode == Channel) {
            double a1 = exp(-1.414 * 3.1415 / periods);
            double c2 = 2.0 * a1 * cos(1.414 * 3.1415 / periods);
            double c3 = -a1 * a1;
            double c1 = (1.0 + c2 - c3) / 4.0;

            Indicator2[i] = (1.0 - c1) * TrueRange[i] + (2.0 * c1 - c2) * TrueRange[i + 1] 
                - (c1 + c3) * TrueRange[i + 2] + c2 * Indicator2[i + 1] + c3 * Indicator2[i + 2];

            double str = Indicator2[i] * Multiplier;
            LineUp[i]  = Indicator1[i] + str;
            LineDn[i]  = Indicator1[i] - str;
        }

        if (mode == Bands) {
            
            double sum = 0;
            for(int j= 1; j <= periods; j++)
            {
               sum += source[j];
            }
            Indicator2[i] = sum / periods;

            double sd = sqrt(Indicator2[i] * Multiplier);
            LineUp[i]  = Indicator1[i] + sd;
            LineDn[i]  = Indicator1[i] - sd;

        }
    }
    return (rates_total);
}

// double getTrueRange(int i)
// {
//     double hl = fabs(high[i] - low[i]);
//     double hc = fabs(high[i] - close[i + 1]);
//     double lc = fabs(low[i] - close[i + 1]);

//     double tr = hl;
//     if (tr < hc) tr = hc;

//     if (tr < lc) tr = lc;

//     return tr;
// }

// ------------------------------------------------------------------

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