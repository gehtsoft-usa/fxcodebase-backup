// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=74786

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
#property indicator_buffers 6
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 3
#property indicator_width6 3

//--- buffers
double ExtLowHighBuffer[];
double ExtHighLowBuffer[];
double ExtOpenBuffer[];
double ExtCloseBuffer[];
double OpenBuffer[];
double CloseBuffer[];

input string             IMACD           = "== MACD Setup =="; // == MACD Setup ==
input int                fast_ema_period = 12;                 // fast ema period:
input int                slow_ema_period = 26;                 // slow ema period:
input int                signal_period   = 9;                  // signal period:
input ENUM_APPLIED_PRICE applied_price   = PRICE_CLOSE;        // applied price:

class MACD
{
    string             _symbol;
    int                _tf;
    int                _fast_ema;
    int                _slow_ema;
    int                _signal;
    ENUM_APPLIED_PRICE _applied_price;

  public:
    MACD()
    {
        _symbol        = _Symbol;
        _tf            = Period();
        _fast_ema      = 12;
        _slow_ema      = 26;
        _signal        = 9;
        _applied_price = PRICE_CLOSE;
    }

    MACD(string Symbol, int TimeFrame, int Fast_ema, int Slow_ema, int Signal, ENUM_APPLIED_PRICE Applied_price)
    {
        _symbol        = Symbol;
        _tf            = TimeFrame;
        _fast_ema      = Fast_ema;
        _slow_ema      = Slow_ema;
        _signal        = Signal;
        _applied_price = Applied_price;
    }
    ~MACD() { ; }

    double calculate(int buffer, int shift)
    {
        return iMACD(_symbol, _tf, _fast_ema, _slow_ema, _signal, _applied_price, buffer, shift);
    }
    double macd_line(int shift) { return calculate(0, shift); }
    double signal_line(int shift) { return calculate(1, shift); }
};
MACD* macd;

// ------------------------------------------------------------------
void OnInit(void)
{
    // setup the chart
    color clrback = ChartGetInteger(0, CHART_COLOR_BACKGROUND);
    ChartSetInteger(0, CHART_MODE, CHART_LINE);
    ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrback);

    macd = new MACD(_Symbol, Period(), fast_ema_period, slow_ema_period, signal_period, applied_price);

    IndicatorShortName("Heiken Ashi");
    IndicatorDigits(Digits);
    //--- indicator lines
    SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, Gray);
    SetIndexBuffer(0, ExtLowHighBuffer);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1, Gray);
    SetIndexBuffer(1, ExtHighLowBuffer);
    SetIndexStyle(2, DRAW_HISTOGRAM, 0, 3, Gray);
    SetIndexBuffer(2, ExtOpenBuffer);
    SetIndexStyle(3, DRAW_HISTOGRAM, 0, 3, Gray);
    SetIndexBuffer(3, ExtCloseBuffer);
    SetIndexStyle(4, DRAW_HISTOGRAM, 0, 4, Lime);
    SetIndexBuffer(4, OpenBuffer);
    SetIndexStyle(5, DRAW_HISTOGRAM, 0, 4, Red);
    SetIndexBuffer(5, CloseBuffer);
    //---
    SetIndexLabel(0, "Low/High");
    SetIndexLabel(1, "High/Low");
    SetIndexLabel(2, "Open");
    SetIndexLabel(3, "Close");
    SetIndexLabel(4, "_Open");
    SetIndexLabel(5, "_Close");
    SetIndexDrawBegin(0, 10);
    SetIndexDrawBegin(1, 10);
    SetIndexDrawBegin(2, 10);
    SetIndexDrawBegin(3, 10);
    SetIndexDrawBegin(4, 10);
    SetIndexDrawBegin(5, 10);
    //--- indicator buffers mapping
    SetIndexBuffer(0, ExtLowHighBuffer);
    SetIndexBuffer(1, ExtHighLowBuffer);
    SetIndexBuffer(2, ExtOpenBuffer);
    SetIndexBuffer(3, ExtCloseBuffer);

    SetIndexBuffer(4, OpenBuffer);
    SetIndexBuffer(5, CloseBuffer);
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
    int    i, pos;
    double haOpen, haHigh, haLow, haClose;
    //---
    if (rates_total <= 10)
        return (0);

    //--- counting from 0 to rates_total
    ArraySetAsSeries(ExtLowHighBuffer, false);
    ArraySetAsSeries(ExtHighLowBuffer, false);
    ArraySetAsSeries(ExtOpenBuffer, false);
    ArraySetAsSeries(ExtCloseBuffer, false);
    ArraySetAsSeries(OpenBuffer, false);
    ArraySetAsSeries(CloseBuffer, false);
    ArraySetAsSeries(open, false);
    ArraySetAsSeries(high, false);
    ArraySetAsSeries(low, false);
    ArraySetAsSeries(close, false);

    //--- preliminary calculation
    if (prev_calculated > 1)
        pos = prev_calculated - 1;
    else {
        //--- set first candle
        if (open[0] < close[0]) {
            ExtLowHighBuffer[0] = low[0];
            ExtHighLowBuffer[0] = high[0];
        } else {
            ExtLowHighBuffer[0] = high[0];
            ExtHighLowBuffer[0] = low[0];
        }
        ExtOpenBuffer[0]  = open[0];
        ExtCloseBuffer[0] = close[0];
        //---
        pos = 1;
    }

    //--- main loop of calculations
    for (i = pos; i < rates_total; i++) {
        haOpen  = (ExtOpenBuffer[i - 1] + ExtCloseBuffer[i - 1]) / 2;
        haClose = (open[i] + high[i] + low[i] + close[i]) / 4;
        haHigh  = MathMax(high[i], MathMax(haOpen, haClose));
        haLow   = MathMin(low[i], MathMin(haOpen, haClose));

        // bull
        if (haOpen < haClose) {
            ExtLowHighBuffer[i] = haLow;
            ExtHighLowBuffer[i] = haHigh;
        } else {
            ExtLowHighBuffer[i] = haHigh;
            ExtHighLowBuffer[i] = haLow;
        }
        // normal
        ExtOpenBuffer[i]  = haOpen;
        ExtCloseBuffer[i] = haClose;

        OpenBuffer[i]  = EMPTY_VALUE;
        CloseBuffer[i] = EMPTY_VALUE;

        int _i = Bars -i;
        if ( macd.macd_line(_i) > macd.signal_line(_i) && haOpen<haClose ) {
            OpenBuffer[i]  = haClose;
            CloseBuffer[i] = haOpen;
        }
        if ( macd.macd_line(_i) < macd.signal_line(_i) && haOpen>haClose ) {
            OpenBuffer[i]  = haClose;
            CloseBuffer[i] = haOpen;
        }
    }
    //--- done
    return (rates_total);
}

void OnDeinit(const int reason)
{
    ChartSetInteger(0, CHART_MODE, CHART_CANDLE);
    delete macd;
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