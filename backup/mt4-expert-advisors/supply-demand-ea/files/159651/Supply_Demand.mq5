//https://fxcodebase.com/code/viewtopic.php?f=38&p=158939#p158939

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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
#property indicator_buffers 8
#property indicator_plots 8
#property indicator_label1 "OB Up"
#property indicator_type1  DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "OB Down"
#property indicator_type2  DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label7 "Signal Up"
#property  indicator_type7  DRAW_ARROW
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Signal Dn"
#property  indicator_type8  DRAW_ARROW
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

//--- indicator buffers
double SignalUp[];
double SignalDn[];
double OBUp[];
double OBDn[];
double supUp[];
double supDn[];
double resUp[];
double resDn[];

// NOTE: Inputs
// ------------------------------------------------------------------
input string T0                    = "== Set Arrows ==";    // Set Arrows
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

int nrZones     = 20;
int candlesBack = 1000;

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

// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
    SetIndexBuffer(0, OBUp, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_ARROW, 159);
    PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(1, OBDn, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 159);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);

    SetIndexBuffer(2, supUp, INDICATOR_DATA);
    PlotIndexSetString(2, PLOT_LABEL, "Support Up");
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    SetIndexBuffer(3, supDn, INDICATOR_DATA);
    PlotIndexSetString(3, PLOT_LABEL, "Support Dn");
    PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
    SetIndexBuffer(4, resUp, INDICATOR_DATA);
    PlotIndexSetString(4, PLOT_LABEL, "Ressistance Up");
    PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
    SetIndexBuffer(5, resDn, INDICATOR_DATA);
    PlotIndexSetString(5, PLOT_LABEL, "Ressistance Dn");
    PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);

    SetIndexBuffer(6, SignalUp, INDICATOR_DATA);
    PlotIndexSetInteger(6, PLOT_ARROW, 233);
    PlotIndexSetString(6, PLOT_LABEL, "Signal Up");
    PlotIndexSetInteger(6, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, Blue);

    SetIndexBuffer(7, SignalDn, INDICATOR_DATA);
    PlotIndexSetString(7, PLOT_LABEL, "Signal Dn");
    PlotIndexSetInteger(7, PLOT_ARROW, 234);
    PlotIndexSetInteger(7, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(7, PLOT_LINE_COLOR, Crimson);

    

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { ObjectsDeleteAll(0, "ob"); }

// NOTE: OnCalculate
// ------------------------------------------------------------------
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int i, start;
    start = 51;
    if (prev_calculated > 1) start = prev_calculated - 1;    
    
    if (prev_calculated == 0)
    {
    ArrayInitialize(SignalUp, EMPTY_VALUE);
    ArrayInitialize(SignalDn, EMPTY_VALUE);
    ArrayInitialize(OBUp, EMPTY_VALUE);
    ArrayInitialize(OBDn, EMPTY_VALUE);
    ArrayInitialize(supUp, EMPTY_VALUE);
    ArrayInitialize(supDn, EMPTY_VALUE);
    ArrayInitialize(resUp, EMPTY_VALUE);
    ArrayInitialize(resDn, EMPTY_VALUE);
    }
    

    for (i = start; i < rates_total && !IsStopped(); i++) {
        if (haveOrderBlockUp(i, open, high, low, close)) {
            OBUp[i - 2] = low[i - 2];

            if (newCandle.IsNewCandle()) {
                Notifications(0);
            }
        }

        if (haveOrderBlockDown(i, open, high, low, close)) {
            OBDn[i - 2] = high[i - 2];

            if (newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }
    }

    // Find Fresh Suports and Ressitances
    int cur_bar  = iBars(NULL, 0) - 1;
    if(candlesBack > iBars(NULL, 0) - 1) candlesBack = iBars(NULL, 0) - 5;
    i            = cur_bar;
    int    limit = cur_bar + 1 - candlesBack;
    double max   = 0;
    double min   = 0;
    int    count = 0;

    while (count < nrZones && i > limit) {
        double cur_max = MathMax(close[i], open[i]);
        double cur_min = MathMin(close[i], open[i]);
        if (cur_max > max || max == 0) {
            max = cur_max;
        }
        if (cur_min < min || min == 0) {
            min = cur_min;
        }

        i--;
        resUp[i] = 0;
        resDn[i] = 0;
        supUp[i] = 0;
        supDn[i] = 0;

        if (OBDn[i] > 0 && OBDn[i] != EMPTY_VALUE && high[i] > max) {
            resUp[i] = high[i];
            resDn[i] = low[i];
            count++;
        }
        if (OBUp[i] > 0 && OBUp[i] != EMPTY_VALUE && low[i] < min) {
            supUp[i] = high[i];
            supDn[i] = low[i];
            count++;
        }
    }
    drawRectangles();

    // Find Signals:
    double lastSup = 0;
    double lastRes = 0;
    int    n       = cur_bar-3;    
    while (lastSup == 0 && n > limit) {
        if (supUp[n] > 0 && supUp[n] != EMPTY_VALUE) {
            lastSup = supUp[n];
            // Print(" lastSup: ", lastSup);
            break;
        }
        n--;
    }
    n = cur_bar;
    while (lastRes == 0 && n > limit) {
        if (resDn[n] > 0 && resDn[n] != EMPTY_VALUE) {
            lastRes = resDn[n];
            // Print(" lastRes: ", lastRes);
            break;
        }
        n--;
    }

    int j = cur_bar-1;
        // up signal
        if (lastSup > 0 && low[j] < lastSup && close[j] >= lastSup) {
            SignalUp[j] = low[j];
        }
        // dn signal
        if (lastRes > 0 && high[j] > lastRes && close[j] <= lastRes) {
            SignalDn[j] = high[j];
        }

    return (rates_total);
}
//+------------------------------------------------------------------+

bool haveOrderBlockUp(int i, const double &op[], const double &hi[], const double &lo[], const double &cl[])
{

    double sum = 0;
    for (int j = 0; j < 50; j++) {
        sum += fabs(op[i - j] - cl[i - j]);
    }
    double avSize = sum / 50;

    // TODO: signal up
    double op3 = op[i - 3];
    double hi3 = hi[i - 3];
    double lo3 = lo[i - 3];
    double cl3 = cl[i - 3];
    double op2 = op[i - 2];
    double hi2 = hi[i - 2];
    double lo2 = lo[i - 2];
    double cl2 = cl[i - 2];
    double op1 = op[i - 1];
    double hi1 = hi[i - 1];
    double lo1 = lo[i - 1];
    double cl1 = cl[i - 1];

    if (fabs(cl1 - op1) < avSize) return false;

    return (cl3 < op3 && cl2 < op3 && cl1 > op1 && cl1 > op2 && op1 > lo2 && lo2 < cl3 && cl1 > (op3 * 0.70));
}

bool haveOrderBlockDown(int i, const double &op[], const double &hi[], const double &lo[], const double &cl[])
{
    // TODO: signal down
    double sum = 0;
    for (int j = 0; j < 50; j++) {
        sum += fabs(op[i - j] - cl[i - j]);
    }
    double avSize = sum / 50;

    double op3 = op[i - 3];
    double hi3 = hi[i - 3];
    double lo3 = lo[i - 3];
    double cl3 = cl[i - 3];
    double op2 = op[i - 2];
    double hi2 = hi[i - 2];
    double lo2 = lo[i - 2];
    double cl2 = cl[i - 2];
    double op1 = op[i - 1];
    double hi1 = hi[i - 1];
    double lo1 = lo[i - 1];
    double cl1 = cl[i - 1];

    if (fabs(cl1 - op1) < avSize) return false;

    return (cl3 > op3 && cl2 > op3 && cl1 < op1 && cl1 < op2 && op1 < hi2 && hi2 > cl3 && cl1 < (op3 * 1.70));
}

void drawRectangles()
{
    ObjectsDeleteAll(0, "ob");
    int i     = iBars(NULL, 0) - 1;
    int limit = iBars(NULL, 0) - candlesBack;
    int count = 0;
    while (count < nrZones && i >= limit) {
        if (resUp[i] > 0 && resUp[i] != EMPTY_VALUE) {
            drawRectangle(i, 0);
            count++;
        }
        if (supUp[i] > 0 && supUp[i] != EMPTY_VALUE) {
            drawRectangle(i, 1);
            count++;
        }
        i--;
    }
}

bool drawRectangle(int shift, uchar side)
{

    shift       = iBars(NULL, 0) - 1 - shift;
    color  clr  = side == 0 ? FireBrick : ForestGreen;
    string name = "ob_" + (string)shift;

    datetime time1  = iTime(NULL, 0, shift);
    double   price1 = iHigh(NULL, 0, shift);
    datetime time2  = iTime(NULL, 0, 0);
    double   price2 = iLow(NULL, 0, shift);

    if (!ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2)) {
        return (false);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    return true;
}

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
//https://fxcodebase.com/code/viewtopic.php?f=38&p=158939#p158939

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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