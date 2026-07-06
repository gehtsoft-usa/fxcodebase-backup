// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74876

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
#property indicator_buffers 9
#property indicator_plots 9

//--- indicator buffers
double       ArrowUp[];
double       ArrowDn[];
double       LineUp[];
double       LineDn[];
double       LineCenter[];

double       clound_up[];
double       clound_up_low[];
double       clound_dn_up[];
double       clound_dn[];

// ------------------------------------------------------------------
input int    main_period           = 10;
input int    adx_period            = 7;

input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

                                                            // clang-format off
string       T2                    = "== Set Lines ==";     // === Set  Lines ===
bool         LinesOn               = true;                  // Line On?
color        LineUpClr             = C'30,30,30';          // Line Up Color:
color        LineDnClr             = C'30,30,30';          // Line Down Color:
string       T3                    = "== Set Arrows ==";    // Set Arrows
color        ArrowUpClr            = clrGreen;              // Arrow Up Color:
color        ArrowDnClr            = clrRed;                // Arrow Down Color:
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
int        OnInit()
{
    SetIndexBuffer(0, clound_up, INDICATOR_DATA);
     SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 1, Red);
    SetIndexBuffer(1, clound_up_low, INDICATOR_DATA);
     SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 0, LimeGreen);
    SetIndexBuffer(2, clound_dn_up, INDICATOR_DATA);
     SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 1, LimeGreen);
    SetIndexBuffer(3, clound_dn, INDICATOR_DATA);
     SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 0, LimeGreen);
    
    //--- indicator buffers mapping
   SetIndexBuffer(4, LineUp, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexLabel(4, "Line Up");

   SetIndexBuffer(5, LineDn, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexLabel(5, "Line Dn");

   SetIndexBuffer(6, LineCenter, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 1, Gold);
    SetIndexLabel(6, "Line Main");

   SetIndexBuffer(7, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(7, 233);
    SetIndexStyle(7, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(7, "Arrow Up");

   SetIndexBuffer(8, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(8, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(8, 234);
    SetIndexLabel(8, "Arrow Dn");


    //---
    return (INIT_SUCCEEDED);
}

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
    // clang-format off
    int start, i;
    if (prev_calculated == 0) { start = rates_total - main_period; } else { start = rates_total - (prev_calculated - 1); }

    // clang-format on
    for (i = start; i >= 0; i--) {
        double isar_8  = iSAR(Symbol(), 0, NormalizeDouble(1 / (10 * main_period + 0.00001), 3), 0.5, i + 1);
        double isar_0  = iSAR(Symbol(), 0, NormalizeDouble(1 / (10 * main_period + 0.00001), 3), 0.5, i);
        double iadx_24 = iADX(Symbol(), 0, adx_period, PRICE_CLOSE, MODE_MAIN, i);

        if (isar_0 > Close[i] && isar_8 < Close[i + 1] && iadx_24 > 20.0) {
            ArrowDn[i] = High[i] + iATR(NULL, 0, 20, i);
            notify(0);
        }
        if (isar_0 < Close[i] && isar_8 > Close[i + 1] && iadx_24 > 20.0) {
            ArrowUp[i] = Low[i] - iATR(NULL, 0, 20, i);
            notify(1);
        }
        LineUp[i]        = iBands(NULL, 0, 20, 2, 0, PRICE_HIGH, MODE_UPPER, i);
        LineCenter[i]    = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_MAIN, i);
        LineDn[i]        = iBands(NULL, 0, 20, 2, 0, PRICE_LOW, MODE_LOWER, i);

        clound_up[i]     = LineUp[i];
        clound_up_low[i] = LineCenter[i];
        clound_dn_up[i]  = LineCenter[i];
        clound_dn[i]     = LineDn[i];
    }
    return (rates_total);
}

// ------------------------------------------------------------------


void notify(int type)
{
    if (newCandle.IsNewCandle()) {
        Notifications(type);
    }
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