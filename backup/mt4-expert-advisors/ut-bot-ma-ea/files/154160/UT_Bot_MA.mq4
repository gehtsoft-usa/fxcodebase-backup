// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74559

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
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "xATR"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrGray
#property indicator_style3 STYLE_DOT
#property indicator_width3 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double xATRTrailingStop[];

//--- variables
double nLoss, xATR;
//
enum candle {
    curr = -1, // Current candle
    prev = 0   // Previous closed candle
};
// ------------------------------------------------------------------
input double             m                     = 2;                            // Key value:
input int                atrPeriods            = 14;                           // ATR periods:
input bool               h                     = false;                        // Signals From Heinken Ashi Candles
input candle             s                     = curr;                         // Show arrows on:
input int                p                     = 30;                           // Arrow position in Points
input int                b                     = 5000;                         // Lookback bars
input string             Iema                  = "== Moving Average Setup =="; // ————————————
input bool               maON                  = true;                         // Filter By MA ?
input int                maPeriod              = 200;                          // Period
int                      maShift               = 0;                            // Ma Shift
input ENUM_MA_METHOD     maMethod              = MODE_EMA;                     // Method
input ENUM_APPLIED_PRICE maAppliedPrice        = PRICE_CLOSE;                  // Applied Price
input string             T1                    = "== Notifications ==";        // ————————————
input bool               notifications         = false;                        // Notifications On?
input bool               desktop_notifications = false;                        // Desktop MT4 Notifications
input bool               email_notifications   = false;                        // Email Notifications
input bool               push_notifications    = false;                        // Push Mobile Notifications
string                   T2                    = "== Set Arrows ==";           // ————————————
bool                     ArrowsOn              = true;                         // Arrows On?
color                    ArrowUpClr            = clrNavy;                      // Arrow Up Color:
color                    ArrowDnClr            = clrCrimson;                   // Arrow Down Color:
// ------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNewCandle
{
  private:
    int    _initialCandles;
    string _symbol;
    int    _tf;

  public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
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

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexArrow(1, 234);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexBuffer(2, xATRTrailingStop);
    SetIndexStyle(2, DRAW_NONE, INDICATOR_DATA);

    if (!ArrowsOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    //---
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//|                                                                  |
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
// clang-format off
    int i = iBars(NULL, 0) / 2;
    if (i >= rates_total) i = rates_total - 1;
    i = MathMin(i, b);

    for (; i > 0; i--) {
        xATR       = iATR(NULL, 0, atrPeriods, i);
        nLoss      = m * xATR;
        double cl  = close[i];
        double cl1 = close[i + 1];

        xATRTrailingStop[i] = cl > xATRTrailingStop[i + 1] && cl1 > xATRTrailingStop[i + 1] ? 
            fmax(xATRTrailingStop[i + 1], cl - nLoss) : cl < xATRTrailingStop[i + 1] && cl1 < xATRTrailingStop[i + 1] ? 
            fmin(xATRTrailingStop[i + 1], cl + nLoss) : cl > xATRTrailingStop[i + 1] ? 
            cl - nLoss : cl + nLoss;

        bool crossUp = cl > xATRTrailingStop[i] && cl1 < xATRTrailingStop[i + 1];
        bool crossDn = cl < xATRTrailingStop[i] && cl1 > xATRTrailingStop[i + 1];

ArrowUp[i] = EMPTY_VALUE;
ArrowDn[i] = EMPTY_VALUE;

        // Ma Filter
        int maFilter = 0;
        if(maON) {
            if(cl1 > iMA(NULL, 0, maPeriod, maShift, maMethod, maAppliedPrice, i)) maFilter = 1;
            if(cl1 < iMA(NULL, 0, maPeriod, maShift, maMethod, maAppliedPrice, i)) maFilter = -1;            
        }

        // Buy Signal
        if(maFilter == 0 || maFilter == 1)
        if (cl > xATRTrailingStop[i] && crossUp == true) {
            ArrowUp[i + s] = low[i + s] - p * Point;
        }

        // Sell Signal
        if(maFilter == 0 || maFilter == -1)
        if (cl < xATRTrailingStop[i] && crossDn == true) {
            ArrowDn[i + s] = high[i + s] + p * Point;
        }
    }
    if (ArrowUp[1 + s] != EMPTY_VALUE && newCandle.IsNewCandle()) {
        Notifications(0);
    }
    if (ArrowDn[1 + s] != EMPTY_VALUE && newCandle.IsNewCandle()) {
        Notifications(1);
    }
    return (rates_total);
}

// ------------------------------------------------------------------

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";
    text += " ";
    if (!notifications)
        return;
    if (desktop_notifications)
        Alert(text);
    if (push_notifications)
        SendNotification(text);
    if (email_notifications)
        SendMail("MetaTrader Notification", text);
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
