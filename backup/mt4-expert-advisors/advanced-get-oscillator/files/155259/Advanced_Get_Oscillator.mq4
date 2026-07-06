//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74846

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
#property indicator_buffers 6
#property indicator_plots 4
#property indicator_label1 "Bar Up"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Bar Down"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrCrimson
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

#property indicator_label3 "Line Up"
#property indicator_type3  DRAW_LINE
#property indicator_color3 C'40,40,40'
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Line Down"
#property indicator_type4  DRAW_LINE
#property indicator_color4 C'40,40,40'
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

//--- indicator buffers
double histoUp[];
double histoDn[];
double top[];
double bottom[];
double lineUp[];
double lineDn[];

// ------------------------------------------------------------------
input int periods = 5; // Periods
input int oscFast = 35;
input int oscSlow = 100;

string T1                    = "== Notifications =="; // ————————————
bool   notifications         = false;                 // Notifications On?
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications

string T2         = "== Set Lines =="; // ————————————
color  histoUpClr = C'30,160,24';          // Line Up Color:
color  histoDnClr = clrCrimson;            // Line Down Color:
// ------------------------------------------------------------------

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
    SetIndexBuffer(0, histoUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2, histoUpClr);
    SetIndexBuffer(1, histoDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 2, histoDnClr);

    SetIndexBuffer(2, top, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, EMPTY, 1, C'40,40,40');
    SetIndexBuffer(3, bottom, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_LINE, EMPTY, 1, C'40,40,40');

    SetIndexBuffer(4, lineUp);
    SetIndexStyle(4, DRAW_NONE);
    SetIndexBuffer(5, lineDn);
    SetIndexStyle(5, DRAW_NONE);
    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   high[],
                const double&   open[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
    // clang-format off
    int start, i;
    
    if (prev_calculated == 0) { start = rates_total - oscSlow; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    double coef = 2 / ((double)oscFast + (double)oscSlow);

    for (i = start; i >= 0; i--) {
        double FastMa = iMA(NULL, 0, oscFast, 0, MODE_SMA, PRICE_CLOSE, i);
        double SlowMa = iMA(NULL, 0, oscSlow, 0, MODE_SMA, PRICE_CLOSE, i);
        double os     = FastMa - SlowMa;

        if (os >= 0) {
            histoUp[i] = os;
            lineUp[i]  = os * coef + lineUp[i + 1] * (1 - coef);
            lineDn[i]  = lineDn[i + 1];
        } else {
            histoDn[i] = os;
            lineDn[i]  = os * coef + lineDn[i + 1] * (1 - coef);
            lineUp[i]  = lineUp[i + 1];
        }
        top[i]    = lineUp[i] * (1 + (periods / 100));
        bottom[i] = lineDn[i] * (1 - (periods / 100));
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