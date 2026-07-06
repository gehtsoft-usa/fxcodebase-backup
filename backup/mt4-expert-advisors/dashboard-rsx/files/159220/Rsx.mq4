// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75929

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

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 LimeGreen
#property indicator_color2 Red
#property indicator_color3 DarkSlateGray
#property indicator_width1 5
#property indicator_width2 5
#property indicator_width3 2
#property indicator_minimum - 1
#property indicator_maximum 1
#property indicator_levelcolor Yellow
#property indicator_level1 0.5
#property indicator_level2 - 0.5
#property indicator_level3 0
#property indicator_level4 0.75
#property indicator_level5 - 0.75

extern string TimeFrame = "Current time frame";
extern int    Length    = 13;
extern int    Price     = PRICE_TYPICAL;

double rsx[];
double rsxDa[];
double rsxDb[];
double slope[];

string shortName;
int    timeFrame;
double pipMultiplier = 1;

int init()
{
    IndicatorBuffers(4);
    SetIndexBuffer(0, rsxDa);
    SetIndexStyle(0, DRAW_HISTOGRAM);
    SetIndexBuffer(1, rsxDb);
    SetIndexStyle(1, DRAW_HISTOGRAM);
    SetIndexBuffer(2, rsx);
    SetIndexBuffer(3, slope);

    SetLevelValue(0, 0.5);
    SetLevelValue(1, -0.5);
    SetLevelValue(2, 0);

    timeFrame = Period();
    shortName = "RSX (" + Length + ")";
    IndicatorShortName(shortName);

    return (0);
}

double wrkBuffer[][13];

int start()
{
    int counted_bars = IndicatorCounted();
    if (counted_bars < 0) return (-1);
    if (counted_bars > 0) counted_bars--;

    int limit = MathMin(Bars - counted_bars, Bars - 1);
    if (Digits == 3 || Digits == 5)
        pipMultiplier = 10;
    else
        pipMultiplier = 1;

    double Kg = (3.0) / (2.0 + Length);
    double Hg = 1.0 - Kg;
    if (ArrayRange(wrkBuffer, 0) != Bars) ArrayResize(wrkBuffer, Bars);

    for (int i = limit, r = Bars - i - 1; i >= 0; i--, r++) {
        wrkBuffer[r][12] = iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
        if (i == Bars - 1) {
            for (int c = 0; c < 12; c++)
                wrkBuffer[r][c] = 0;
            continue;
        }

        double mom = wrkBuffer[r][12] - wrkBuffer[r - 1][12];
        double     moa = MathAbs(mom);

        for (int k = 0; k < 3; k++) {
            int kk               = k * 2;
            wrkBuffer[r][kk + 0] = Kg * mom + Hg * wrkBuffer[r - 1][kk + 0];
            wrkBuffer[r][kk + 1] = Kg * wrkBuffer[r][kk + 0] + Hg * wrkBuffer[r - 1][kk + 1];
            mom                  = 1.5 * wrkBuffer[r][kk + 0] - 0.5 * wrkBuffer[r][kk + 1];

            wrkBuffer[r][kk + 6] = Kg * moa + Hg * wrkBuffer[r - 1][kk + 6];
            wrkBuffer[r][kk + 7] = Kg * wrkBuffer[r][kk + 6] + Hg * wrkBuffer[r - 1][kk + 7];
            moa                  = 1.5 * wrkBuffer[r][kk + 6] - 0.5 * wrkBuffer[r][kk + 7];
        }

        if (moa != 0)
            rsx[i] = MathMax(MathMin((mom / moa + 1.0) * 50.0, 100.0), 0.0) / 50 - 1;
        else
            rsx[i] = 0;

        rsxDa[i] = EMPTY_VALUE;
        rsxDb[i] = EMPTY_VALUE;
        slope[i] = slope[i + 1];
        if (rsx[i] > rsx[i + 1]) slope[i] = 1;
        if (rsx[i] < rsx[i + 1]) slope[i] = -1;
        if (slope[i] == 1) rsxDa[i] = rsx[i];
        if (slope[i] == -1) rsxDb[i] = rsx[i];
        
    }

    return (0);
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75929

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
