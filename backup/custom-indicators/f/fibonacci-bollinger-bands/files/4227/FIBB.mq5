// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 9
#property indicator_plots 9


// NOTE: Inputs
// ------------------------------------------------------------------
input string T_ = "== Set Bollinger Bands ==";        // Bands
input int    bbPeriod = 20;                       // BB Periods:
input int    bbShift = 1;                        // BB Shift:
input int    bbDesviation = 0;                        // BB Desviation:
input ENUM_APPLIED_PRICE bbApliedPrice = PRICE_CLOSE; // BB Applied Price:
input int atrPeriods = 20; // ATR Periods:
input string T2 = "== Fibo Lebels ==";        // Fibo Levels
input double level1 =  0.382;                 // Level 1:
input double level2 =  1.0;                   // Level 2:
input double level3 =  1.618;                 // Level 3:

input string T0 = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:
input string T1 = "== Notifications ==";  // Notifications
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications



// NOTE: Buffers
//--- indicator buffers
double media [];
double up1 [];
double up2 [];
double up3 [];
double dn1 [];
double dn2 [];
double dn3 [];

double ArrowUp [];
double ArrowDn [];

int _handle;
int _atr;


// NOTE: Objects
// ------------------------------------------------------------------
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
        _symbol = Symbol();
        _tf = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if(_currentCandles > _initialCandles) {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

// ------------------------------------------------------------------
void OnInit()
{
    //--- indicator short name
    string short_name = "FIBB";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    // PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    int n = 0;
    SetIndexBuffer(n, media); n++;
    SetIndexBuffer(n, up1); n++;
    SetIndexBuffer(n, up2); n++;
    SetIndexBuffer(n, up3); n++;
    SetIndexBuffer(n, dn1); n++;
    SetIndexBuffer(n, dn2); n++;
    SetIndexBuffer(n, dn3); n++;

    // SetIndexBuffer(n, ArrowUp, INDICATOR_DATA); n++;
    // SetIndexBuffer(n, ArrowDn, INDICATOR_DATA); n++;

    n = 0;
    for (int i = 0; i < 8; i++)
    {
        PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE); 
        PlotIndexSetInteger(i, PLOT_LINE_STYLE, STYLE_SOLID);
        PlotIndexSetInteger(i, PLOT_LINE_WIDTH, 2); 
    }

    n = 0;
    PlotIndexSetInteger(n, PLOT_LINE_COLOR, clrGray);n++;
    PlotIndexSetInteger(n, PLOT_LINE_COLOR, clrBlue); n++;
    PlotIndexSetInteger(n, PLOT_LINE_COLOR, clrGreen); n++;
    PlotIndexSetInteger(n, PLOT_LINE_COLOR, clrRed); n++;
    PlotIndexSetInteger(n, PLOT_LINE_COLOR, clrBlue); n++;
    PlotIndexSetInteger(n, PLOT_LINE_COLOR, clrGreen); n++;
    PlotIndexSetInteger(n, PLOT_LINE_COLOR, clrRed); n++;

    
    // PlotIndexSetInteger(n, PLOT_ARROW, 233);
    // PlotIndexSetInteger(n, PLOT_ARROW_SHIFT, 10);
    // PlotIndexSetInteger(n, PLOT_LINE_COLOR, ArrowUpClr); n++;

    // PlotIndexSetInteger(n, PLOT_ARROW, 234);
    // PlotIndexSetInteger(n, PLOT_ARROW_SHIFT, -10);
    // PlotIndexSetInteger(n, PLOT_LINE_COLOR, ArrowDnClr); n++;

    // NOTE: Handle

    _handle = iBands(_Symbol, 0, bbPeriod, bbDesviation, bbShift, bbApliedPrice);
    _atr = iATR(_Symbol, 0, atrPeriods);

}



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{
    if(rates_total < bbPeriod) return (0);

    int start;
    if(prev_calculated > 1) start = prev_calculated - 1; else { start = bbPeriod + 1; }

    for(int i = start; i < rates_total && !IsStopped(); i++)
    {
        media[i] = calculate(0, i);
        up1[i] = media[i] + ATR(i) * level1;
        up2[i] = media[i] + ATR(i) * level2;
        up3[i] = media[i] + ATR(i) * level3;
        dn1[i] = media[i] - ATR(i) * level1;
        dn2[i] = media[i] - ATR(i) * level2;
        dn3[i] = media[i] - ATR(i) * level3;

        if(haveSignalUp(i)) {
            // ArrowUp[i - 1] = low[i - 1];
            if(newCandle.IsNewCandle()) { Notifications(0); }
        }

        if(haveSignalDown(i)) {
            // ArrowDn[i - 1] = high[i - 1];
            if(newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }
    }

    return (rates_total);
}
// ------------------------------------------------------------------

double calculate(int buffer, int shift)
{
    int sh = iBars(NULL, 0) - shift;
    double value[1];

    int copy = CopyBuffer(_handle, buffer, sh, 1, value);
    if(copy > 0) { return value[0]; }
    //---
    return -1;
}
double ATR(int shift)
{
    int sh = iBars(NULL, 0) - shift;
    double value[1];

    int copy = CopyBuffer(_atr, 0, sh, 1, value);
    if(copy > 0) { return value[0]; }
    //---
    return -1;
}

bool haveSignalUp(int i)
{
    int shift = iBars(_Symbol, Period()) - i;
    if(iOpen(_Symbol, Period(), shift) < iClose(_Symbol, Period(), shift)) { return true; }

    return false;
}
bool haveSignalDown(int i)
{
    int shift = iBars(_Symbol, Period()) - i;
    if(iOpen(_Symbol, Period(), shift) > iClose(_Symbol, Period(), shift)) { return true; }

    return false;
}

void Notifications(int type)
{
    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

    text += " ";

    if(!notifications)
        return;
    if(desktop_notifications)
        Alert(text);
    if(push_notifications)
        SendNotification(text);
    if(email_notifications)
        SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod) {
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