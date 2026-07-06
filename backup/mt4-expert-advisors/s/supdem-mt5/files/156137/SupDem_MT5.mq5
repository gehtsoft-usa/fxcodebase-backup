//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75065

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
#property link "http://fxcodebase.com"
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

//--- indicator buffers
double OBUp[];
double OBDn[];
double supUp[];
double supDn[];
double resUp[];
double resDn[];

// NOTE: Inputs
// ------------------------------------------------------------------
string       T0                    = "== Set Arrows ==";    // Set Arrows
color        ArrowUpClr            = clrBlue;               // Arrow Up Color:
color        ArrowDnClr            = clrRed;                // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

int nrZones     = 20;
int candlesBack = 1000;

int                handle         = 0;
input const string indicator_file = "ZigZag"; // Indicator File:

void setHandle() { handle = iCustom(NULL, 0, indicator_file, 12, 5, 3); }

double zzValue(int buffer, int candle = 1)
{
    double value[1];
    int    sh   = iBars(NULL, 0) - candle - 1;
    int    copy = CopyBuffer(handle, buffer, sh, 1, value);

    if (copy > 0) {
        return value[0];
    }

    return -1;
}

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
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);

    SetIndexBuffer(1, OBDn, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 159);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);

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

    setHandle();

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

    for (i = start; i < rates_total && !IsStopped(); i++) {
        OBDn[i] = zzValue(1, i);
        OBUp[i] = zzValue(2, i);
    }

    // Find Fresh Suports and Ressitances
    int cur_bar  = iBars(NULL, 0) - 1;
    i            = cur_bar;
    int    limit = cur_bar + 1 - candlesBack;
    double max   = 0;
    double min   = 0;
    int    count = 0;

    while (count < nrZones && i > limit) {
        double cur_max = MathMax(high[i], open[i]);
        double cur_min = MathMin(low[i], open[i]);
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
            // volver al inicio y borrar si hay algúna res adentro de la zona de high low
            for (int n = i+1; n < cur_bar; n++) {
                // if (resUp[n] < resUp[i] && resDn[n] > resDn[i]) {
                if (resUp[n] < resUp[i] && resUp[n] > resDn[i]) {
                    resUp[n] = EMPTY_VALUE;
                    resDn[n] = EMPTY_VALUE;
                }
            }
        }
        if (OBUp[i] > 0 && OBUp[i] != EMPTY_VALUE && low[i] < min) {
            supUp[i] = high[i];
            supDn[i] = low[i];
            count++;

            for (int n = i+1; n < cur_bar; n++) {
                // if (supUp[n] < supUp[i] && supDn[n] > supDn[i]) {
                if (supDn[n] < supUp[i] && supDn[n] > supDn[i]) {
                    supUp[n] = EMPTY_VALUE;
                    supDn[n] = EMPTY_VALUE;
                }
            }
        }
    }
    drawRectangles();

    return (rates_total);
}
//+------------------------------------------------------------------+

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
    color  clr  = side == 0 ? Yellow : Aqua;
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