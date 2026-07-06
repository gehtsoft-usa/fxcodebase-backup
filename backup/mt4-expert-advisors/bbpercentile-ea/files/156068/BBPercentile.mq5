//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=156092#p156092

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "Line"
#property indicator_type1  DRAW_LINE
#property indicator_color1 RoyalBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Up"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Arrow Down"
#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrRed
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

// NOTE: Inputs
// ------------------------------------------------------------------
input int    Period                = 20;                    // Indicator Periods
input string T0                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double line[];
double ArrowUp[];
double ArrowDn[];
int    bb_handle = 0;

double             deviation     = 2;
int                bands_shift   = 0;
ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;

// ------------------------------------------------------------------
void OnInit()
{
    //--- indicator short name
    PlotIndexSetString(0, PLOT_LABEL, "BBPercentile");
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    SetIndexBuffer(0, line);

    SetIndexBuffer(1, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 233);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(2, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_ARROW, 234);

    PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowDnClr);

    IndicatorSetInteger(INDICATOR_LEVELS, 1);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 0);
    IndicatorSetInteger(INDICATOR_LEVELSTYLE, STYLE_DOT);
    IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrGray);

    bb_handle = iBands(_Symbol, _Period, Period, bands_shift, deviation, applied_price);
}

double bands_up(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy = CopyBuffer(bb_handle, 1, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}
double bands_dn(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy = CopyBuffer(bb_handle, 2, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}
double bands_main(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy = CopyBuffer(bb_handle, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{

    int start;
    if (prev_calculated > 1)
        start = prev_calculated - 1;
    else {
        start = Period + 1;
    }

    for (int i = start; i < rates_total && !IsStopped(); i++) {
        double bbup                 = bands_up(i - 1);
        double bbdn                 = bands_dn(i - 1);
        double bbmain               = bands_main(i - 1);
        int    shift                = Bars(_Symbol, _Period) - i;
        double cl                   = iClose(NULL, 0, shift);
        double positionBetweenBands = 100 * (cl - bbmain) / (bbup - bbdn);
        line[i]                     = positionBetweenBands;

        ArrowUp[i] = EMPTY_VALUE;
        ArrowDn[i] = EMPTY_VALUE;

        if (cl < bbdn && positionBetweenBands < -55) {
            ArrowUp[i] = line[i];
            if (newCandle.IsNewCandle()) {
                Notifications(0);
            }
        }

        if (cl > bbup && positionBetweenBands > 55) {
            ArrowDn[i] = line[i];
            if (newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }
    }
    return (rates_total);
}

// ------------------------------------------------------------------

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

    text += " ";

    if (!notifications) return;
    if (desktop_notifications) Alert(text);
    if (push_notifications) SendNotification(text);
    if (email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch (lPeriod) {
    case PERIOD_M1:
        return ("M1");
    case PERIOD_M5:
        return ("M5");
    case PERIOD_M15:
        return ("M15");
    case PERIOD_M30:
        return ("M30");
    case PERIOD_H1:
        return ("H1");
    case PERIOD_H4:
        return ("H4");
    case PERIOD_D1:
        return ("D1");
    case PERIOD_W1:
        return ("W1");
    case PERIOD_MN1:
        return ("MN1");
    }
    return IntegerToString(lPeriod);
}

class CNewCandle
{
  private:
    int             _initialCandles;
    string          _symbol;
    ENUM_TIMEFRAMES _tf;

  public:
    CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
    CNewCandle()
    {
        // toma los valores del chart actual
        _initialCandles = iBars(Symbol(), Period());
        _symbol         = Symbol();
        _tf             = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if (_currentCandles > _initialCandles) {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();
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