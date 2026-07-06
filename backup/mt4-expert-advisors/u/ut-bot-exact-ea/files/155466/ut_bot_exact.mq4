// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74898

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
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrLimeGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrCrimson
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "atr"
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrGray
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double xatr[];

//--- variables
double nLoss, atr;
//
enum candle {
    curr = -1, // Current candle
    prev = 0   // Previous closed candle
};
// ------------------------------------------------------------------
input double m                     = 2;                     // Key value:
input double atrPeriods            = 14;                    // ATR periods:
input bool   h                     = false;                 // Signals From Heinken Ashi Candles
candle       s                     = prev;                  // Show arrows on:
input int    p                     = 30;                    // Arrow position in Points
input int    b                     = 5000;                  // Lookback bars
input string T1                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";    // ————————————
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrLimeGreen;          // Arrow Up Color:
input color  ArrowDnClr            = clrCrimson;            // Arrow Down Color:
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
int        OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexArrow(1, 234);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexBuffer(2, xatr);
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
int  OnCalculate(const int       rates_total,
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
    int i = iBars(NULL, 0) / 2;
    if (i >= rates_total)
        i = rates_total - 1;
    i = MathMin(i, b);

    for (; i > 0; i--) {
        atr        = iATR(NULL, 0, atrPeriods, i);
        nLoss      = m * atr;
        double cl  = close[i];
        double cl1 = close[i + 1];


        if (cl > xatr[i + 1] && cl1 > xatr[i + 1]) {
            xatr[i] = fmax(xatr[i + 1], cl - nLoss);

        } else if (cl < xatr[i + 1] && cl1 < xatr[i + 1]) {
            xatr[i] = fmin(xatr[i + 1], cl + nLoss);

        } else if (cl > xatr[i + 1]) {
            xatr[i] = cl - nLoss;
        } else {
            xatr[i] = cl + nLoss;
        }


        double ema     = iMA(NULL, 0, 1, 0, MODE_EMA, PRICE_CLOSE, i);
        double ema1    = iMA(NULL, 0, 1, 0, MODE_EMA, PRICE_CLOSE, i + 1);

        bool   crossUp = ema > xatr[i] && ema1 < xatr[i + 1];
        bool   crossDn = ema < xatr[i] && ema1 > xatr[i + 1];


        if (cl > xatr[i] && crossUp == true) {
            ArrowUp[i + s] = low[i + s] - p * Point;
        }
        if (cl < xatr[i] && crossDn == true) {
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
