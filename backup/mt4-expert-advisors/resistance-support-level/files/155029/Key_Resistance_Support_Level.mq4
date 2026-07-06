//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74782

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
#property indicator_buffers 2
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
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
input int    fractals = 2;    // Fractals:
input bool   confiron = true; // Confirmation On?
input int    qconfir  = 5;    // Confirmations Bars:
input bool   zoneon   = true; // Check Zone Size?
input double zoneSize = 10;   // Pips Zone:

input string T1                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";    // ————————————
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
// ------------------------------------------------------------------

float Distance(double precioA, double precioB, string par)
{
    double mPoint     = MarketInfo(par, MODE_POINT);
    double dist       = fabs(precioA - precioB);
    double distReturn = 0;
    if (mPoint > 0)
        distReturn = dist / mPoint;
    return distReturn;
}

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
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    if (!ArrowsOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

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
    // int i = rates_total - (prev_calculated + 100);
    int i = 500;
    
    if (i >= rates_total) i = rates_total - 1;

    for (; i > 0; i--) {
        if (haveSignalUp(i, open, high, low, close)) {
            ArrowUp[i+1] = Low[i+1];
            if (newCandle.IsNewCandle()) {
                Notifications(0);
            }
        }
        if (haveSignalDown(i, open, high, low, close)) {
            ArrowDn[i+1] = High[i+1];
            if (newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }
    }

    return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalDown(int i, const double& open[], const double& high[], const double& low[], const double& close[])
{
    i = i+1; // para que evalue la vela cerrada;

    // TODO: signal dn
    bool result = true;
    for (int j = 1; j <= fractals; j++) {
        if (i - j >= 0)
            if (high[i] < high[i + j] || high[i] < high[i - j]) {
                result = false;
            }
    }

    if (confiron && result) {
        for (int j = 1; j <= qconfir; j++) {
            if (high[i] < high[i + j]) {
                result = false;
            }
        }
    }
    if (zoneon && result) {
        for (int j = 1; j <= qconfir; j++) {
            if (high[i] - zoneSize * _Point * 10 < high[i + j]) {
                result = false;
            }
        }
    }

    return result;
}
bool haveSignalUp(int i, const double& open[], const double& high[], const double& low[], const double& close[])
{
    i = i+1; // para que evalue la vela cerrada;

    // TODO: signal up
    bool result = true;
    for (int j = 1; j <= fractals; j++) {
        if (i - j <= 0)
            if (low[i] > low[i + j] || low[i] > low[i - j]) {
                result = false;
            }
    }

    if (confiron && result) {
        for (int j = 1; j <= qconfir; j++) {
            if (low[i] > low[i + j]) {
                result = false;
            }
        }
    }
    if (zoneon && result) {
        for (int j = 1; j <= qconfir; j++) {
            if (low[i] + zoneSize * _Point * 10 > low[i + j]) {
                result = false;
            }
        }
    }

    return result;
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