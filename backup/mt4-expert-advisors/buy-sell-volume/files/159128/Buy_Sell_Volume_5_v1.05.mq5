//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75899

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
//---- indicator settings
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 6
#property indicator_plots 6

#property indicator_label1 "Total Volume Histo"
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 White
#property indicator_width1 1

#property indicator_label2 "Total Volume Line"
#property indicator_type2 DRAW_LINE
#property indicator_color2 White
#property indicator_width2 1

#property indicator_label3 "Buy Volume Histo"
#property indicator_type3 DRAW_HISTOGRAM
#property indicator_color3 Green
#property indicator_width3 1

#property indicator_label4 "Buy Volume Line"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Green
#property indicator_width4 1

#property indicator_label5 "Sell Volume Histo"
#property indicator_type5 DRAW_HISTOGRAM
#property indicator_color5 Red
#property indicator_width5 1

#property indicator_label6 "Sell Volume Line"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Red
#property indicator_width6 1

input int BearsBullsPeriods = 2; // Number of periods for Bulls and Bears Power

//---- indicator buffers
double ExtVolumesBufferHisto[];
double ExtVolumesBufferLine[];
double ExtVolumesUpBufferHisto[];
double ExtVolumesUpBufferLine[];
double ExtVolumesDownBufferHisto[];
double ExtVolumesDownBufferLine[];

int handleBullsPower;
int handleBearsPower;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //---- indicator buffers mapping
    SetIndexBuffer(0, ExtVolumesBufferHisto, INDICATOR_DATA);
    SetIndexBuffer(1, ExtVolumesBufferLine, INDICATOR_DATA);
    SetIndexBuffer(2, ExtVolumesUpBufferHisto, INDICATOR_DATA);
    SetIndexBuffer(3, ExtVolumesUpBufferLine, INDICATOR_DATA);
    SetIndexBuffer(4, ExtVolumesDownBufferHisto, INDICATOR_DATA);
    SetIndexBuffer(5, ExtVolumesDownBufferLine, INDICATOR_DATA);

    //---- name for DataWindow and indicator subwindow label
    IndicatorSetString(INDICATOR_SHORTNAME, "Buy_Sell Volume Pressure");
    IndicatorSetInteger(INDICATOR_DIGITS, 0);

    // double bullp = MathAbs(iBullsPower(NULL, 0, 1, PRICE_CLOSE, i));
    // double bearp = MathAbs(iBearsPower(NULL, 0, 1, PRICE_CLOSE, i));
    
    handleBullsPower = iBullsPower(NULL, 0, BearsBullsPeriods);
    handleBearsPower = iBearsPower(NULL, 0, BearsBullsPeriods);

    return(INIT_SUCCEEDED);
}

double BullPower(int shift)
{
    double value[1];
    // int    shift = Bars(_Symbol, _Period) - 1;
    // int shift = 1;
    int copy  = CopyBuffer(handleBullsPower, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

double BearPower(int shift)
{
    double value[1];
    // int    shift = Bars(_Symbol, _Period) - 1;
    // int shift = 1;
    int copy  = CopyBuffer(handleBearsPower, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
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

    int i, start;
    start = 1;
    if (prev_calculated > 1) start = prev_calculated - 1;

    for (i = start; i < rates_total && !IsStopped(); i++) {
        // double bullp = MathAbs(iBullsPower(NULL, 0, 1, PRICE_CLOSE, i));
        // double bearp = MathAbs(iBearsPower(NULL, 0, 1, PRICE_CLOSE, i));
    
        double bullp = MathAbs(BullPower(i));
        double bearp = MathAbs(BearPower(i));    
    
        double vol     = tick_volume[i];
        double Buyers  = (bullp * vol) / MathMax((bullp + bearp), 0.000001);
        double Sellers = (bearp * vol) / MathMax((bullp + bearp), 0.000001);

        ExtVolumesBufferHisto[i] = vol;
        ExtVolumesBufferLine[i] = vol;
        ExtVolumesUpBufferHisto[i] = Buyers;
        ExtVolumesUpBufferLine[i] = Buyers;
        ExtVolumesDownBufferHisto[i] = Sellers;
        ExtVolumesDownBufferLine[i] = Sellers;
    }

    return(rates_total);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75899

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 