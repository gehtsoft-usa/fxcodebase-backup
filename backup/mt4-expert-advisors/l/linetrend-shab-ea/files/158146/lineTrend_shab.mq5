// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75585

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
#property strict

#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots 3

#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property  indicator_type2  DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_type3  DRAW_COLOR_LINE
#property indicator_color3 DeepSkyBlue, Tomato
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
#property indicator_label3 "Line Trend"


//--- indicator buffers
double line[];
double lineColor[];

//--- indicator input
input int Amplitude = 2; // Amplitude
input string T0                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = DeepSkyBlue;           // Arrow Up Color:
input color  ArrowDnClr            = Tomato;                // Arrow Down Color:

int    _atrHandle, _lowmaHandle, _highmaHandle;
bool   nexttrend;
double minhighprice, maxlowprice;

double up[], down[], trend[], atrlo[], atrhi[], lowma[], highma[], lowprice[], highprice[], _atr[];
double ArrowUp[];
double ArrowDn[];
// ------------------------------------------------------------------

void OnInit()
{
    
    //--- indicator short name
    string short_name = "Line Trend Shab";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);

    //--- Buffers

    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_ARROW, 233);
    PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 234);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);

    if (!ArrowsOn) {
        PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
    }

    SetIndexBuffer(2, line, INDICATOR_DATA);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    SetIndexBuffer(3, lineColor, INDICATOR_COLOR_INDEX);

    SetIndexBuffer(4, up, INDICATOR_DATA);
    SetIndexBuffer(5, down, INDICATOR_DATA);
    SetIndexBuffer(6, _atr, INDICATOR_DATA);
    SetIndexBuffer(7, atrlo, INDICATOR_DATA);
    SetIndexBuffer(8, atrhi, INDICATOR_DATA);
    SetIndexBuffer(9, trend, INDICATOR_DATA);
    SetIndexBuffer(10, lowma, INDICATOR_CALCULATIONS);
    SetIndexBuffer(11, highma, INDICATOR_CALCULATIONS);
    SetIndexBuffer(12, lowprice, INDICATOR_CALCULATIONS);
    SetIndexBuffer(13, highprice, INDICATOR_CALCULATIONS);

    // --------------

    nexttrend    = false;
    int b        = Bars(_Symbol, _Period) - 1;
    minhighprice = iHigh(NULL, 0, b);
    maxlowprice  = iLow(NULL, 0, b);

    // clang-format off
    _atrHandle = iATR(_Symbol, 0, 100); if (!_checkHandle(_atrHandle, "ATR")) return; 
    _lowmaHandle = iMA(_Symbol, 0, Amplitude, 0, MODE_SMA, PRICE_LOW); if (!_checkHandle(_lowmaHandle, "Average")) return;
    _highmaHandle = iMA(_Symbol, 0, Amplitude, 0, MODE_SMA, PRICE_HIGH); if (!_checkHandle(_highmaHandle, "Average")) return;
    // clang-format on
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{

    int _copyCount = rates_total - prev_calculated + 1;
    if (_copyCount > rates_total) _copyCount = rates_total;

    // clang-format off
    int start;
    if (prev_calculated > 1) start = prev_calculated - 2; else { start = 1; }
    // clang-format on

    for (int i = start; i < rates_total && !IsStopped(); i++) {
        CopyBuffer(_atrHandle, 0, i, 1, _atr);
        CopyBuffer(_lowmaHandle, 0, i, 1, lowma);
        CopyBuffer(_highmaHandle, 0, i, 1, highma);

        int b        = Bars(_Symbol, _Period) - i;
        lowprice[i]  = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Amplitude, b));
        highprice[i] = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Amplitude, b));

        // trend[i]   = 0;
        trend[i]   = trend[i-1];
        double atr = _atr[i] / 2;

        if (nexttrend == true) {
            maxlowprice = MathMax(lowprice[i], maxlowprice);
            if (highma[i] < maxlowprice && close[i] < low[i - 1]) {
                trend[i]     = 1.0;
                nexttrend    = false;
                minhighprice = highprice[i];
            }
        }

        if (nexttrend == false) {
            minhighprice = MathMin(highprice[i], minhighprice);
            if (lowma[i] > minhighprice && close[i] > high[i - 1]) {
                trend[i]    = 0.0;
                nexttrend   = true;
                maxlowprice = lowprice[i];
            }
        }

        if (trend[i] == 0) 
        {
            if (trend[i - 1] != 0.0) {
                up[i]     = down[i - 1];
                up[i - 1] = up[i];
                
                // cambio: de alcista a bajista    
                line[i] = up[i-1];
                lineColor[i] = 0;
                
                ArrowUp[i]  = up[i] - 2 * atr;
            } else {
                up[i] = MathMax(maxlowprice, up[i - 1]);                
            }

            atrhi[i] = up[i] - atr;
            atrlo[i] = up[i];
            down[i]  = 0.0;
            
            line[i] = up[i];
            lineColor[i] = 0;
        }

        if (trend[i] == 1) 
        {
            if (trend[i - 1] != 1.0) {
                down[i]     = up[i - 1];
                down[i - 1] = down[i];

                line[i-1]      =  down[i];
                lineColor[i-1] = 1;

                ArrowDn[i]   = down[i] + 2 * atr;

            } else {
                down[i] = MathMin(minhighprice, down[i - 1]);                
            }

            atrhi[i] = down[i] + atr;
            atrlo[i] = down[i];
            up[i]    = 0.0;

            line[i] = down[i];
            lineColor[i] = 1;
        }

    }

    return (rates_total);
}
//+------------------------------------------------------------------+

bool _checkHandle(int _handle, string _description)
{
    static int _chandles[];
    int        _size   = ArraySize(_chandles);
    bool       _answer = (_handle != INVALID_HANDLE);
    if (_answer) {
        ArrayResize(_chandles, _size + 1);
        _chandles[_size] = _handle;
    } else {
        for (int i = _size - 1; i >= 0; i--)
            IndicatorRelease(_chandles[i]);
        ArrayResize(_chandles, 0);
        Alert(_description + " initialization failed");
    }
    return (_answer);
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75585

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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