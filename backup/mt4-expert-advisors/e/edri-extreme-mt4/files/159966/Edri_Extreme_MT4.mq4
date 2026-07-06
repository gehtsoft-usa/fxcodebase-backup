//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76167

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Fuchsia
#property indicator_color4 Gray
#property indicator_color5 Blue

//---- Inputs
enum SignalSource { CCI = 0, Momentum = 1 };
input SignalSource EntrySignalSource = CCI;
input int          ccimomLength      = 10;
input bool         useDivergence     = true;
input int          rsiOverbought     = 65;
input int          rsiOversold       = 35;
input int          rsiLength         = 14;
input bool         plotMeanReversion = true;
input int          emaPeriod         = 200;
input double       bandMultiplier    = 1.8;

//---- Buffers
double BuyBuffer[];
double SellBuffer[];
double UpperBandBuffer[];
double MeanBuffer[];
double LowerBandBuffer[];

//---- Indicator initialization
int OnInit()
{
    SetIndexBuffer(0, BuyBuffer, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_ARROW, 0, 1, clrLime);
    SetIndexArrow(0, 233); // triangle up

    SetIndexBuffer(1, SellBuffer, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, 0, 1, clrRed);
    SetIndexArrow(1, 234); // triangle down

    SetIndexBuffer(2, UpperBandBuffer);
    SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, Magenta);
    SetIndexBuffer(3, MeanBuffer);
    SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, Gray);
    SetIndexBuffer(4, LowerBandBuffer);
    SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, Blue);


    IndicatorShortName("Edri Extreme Points Buy & Sell");
    return (INIT_SUCCEEDED);
}

//---- Main calculation
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - 1000;
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = start; i >= 0; i--) {
        // --- CCI and Momentum calculation
        double mom = close[i] - close[i + ccimomLength];
        double cci = iCCI(NULL, 0, ccimomLength, PRICE_CLOSE, i);

        bool ccimomCrossUp, ccimomCrossDown;
        if (EntrySignalSource == Momentum) {
            ccimomCrossUp   = (mom > 0 && close[i + 1] - close[i + 1 + ccimomLength] <= 0);
            ccimomCrossDown = (mom < 0 && close[i + 1] - close[i + 1 + ccimomLength] >= 0);
        } else // CCI
        {
            ccimomCrossUp   = (cci > 0 && iCCI(NULL, 0, ccimomLength, PRICE_CLOSE, i + 1) <= 0);
            ccimomCrossDown = (cci < 0 && iCCI(NULL, 0, ccimomLength, PRICE_CLOSE, i + 1) >= 0);
        }

        // --- RSI calculation
        double rsi         = iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i);
        bool   oversoldAgo = false, overboughtAgo = false;
        for (int j = 0; j < 4; j++) {
            double rsi_j = iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i + j);
            if (rsi_j <= rsiOversold) oversoldAgo = true;
            if (rsi_j >= rsiOverbought) overboughtAgo = true;
        }

        // --- Regular Divergence Conditions
        bool bullishDivergenceCondition =
            iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i) > iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i + 1) && iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i + 1) < iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i + 2);
        bool bearishDivergenceCondition =
            iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i) < iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i + 1) && iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i + 1) > iRSI(NULL, 0, rsiLength, PRICE_CLOSE, i + 2);

        // --- Entry Conditions
        bool longEntryCondition  = ccimomCrossUp && oversoldAgo && (!useDivergence || bullishDivergenceCondition);
        bool shortEntryCondition = ccimomCrossDown && overboughtAgo && (!useDivergence || bearishDivergenceCondition);

        BuyBuffer[i]  = longEntryCondition ? low[i] - (0.5 * (high[i] - low[i])) : EMPTY_VALUE;
        SellBuffer[i] = shortEntryCondition ? high[i] + (0.5 * (high[i] - low[i])) : EMPTY_VALUE;

        // --- Mean Reversion Bands
        if (plotMeanReversion) {
            double mean        = iMA(NULL, 0, emaPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
            double stddev      = iStdDev(NULL, 0, emaPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
            UpperBandBuffer[i] = mean + stddev * bandMultiplier;
            MeanBuffer[i]      = mean;
            LowerBandBuffer[i] = mean - stddev * bandMultiplier;
        } else {
            UpperBandBuffer[i] = EMPTY_VALUE;
            MeanBuffer[i]      = EMPTY_VALUE;
            LowerBandBuffer[i] = EMPTY_VALUE;
        }
    }
    return (rates_total);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76167

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+