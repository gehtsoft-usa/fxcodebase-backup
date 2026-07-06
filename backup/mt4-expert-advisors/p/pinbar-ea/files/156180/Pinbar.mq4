// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75077

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
#property indicator_buffers 10
#property indicator_plots 8

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double supUp[];
double supDn[];
double resUp[];
double resDn[];
double SignalUp[];
double SignalDn[];
double ShiftRes[];
double ShiftSup[];

// ------------------------------------------------------------------
int          periods               = 10;
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
string       T2                    = "== Set Lines ==";     // === Set  Lines ===
bool         LinesOn               = true;                  // Line On?
color        LineUpClr             = clrBlue;               // Line Up Color:
color        LineDnClr             = clrRed;                // Line Down Color:
string       T3                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = clrGreen;              // Arrow Up Color:
color        ArrowDnClr            = clrCrimson;            // Arrow Down Color:
// ------------------------------------------------------------------

int nrZones     = 20;
int candlesBack = 1000;

// clang-format off
// Mark: Oninit
int OnInit()
{
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 159);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(0, "Arrow Up");

   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 159);
    SetIndexLabel(1, "Arrow Dn");

   SetIndexBuffer(2, supUp, INDICATOR_DATA);
    // SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexLabel(2, "Support Up");

   SetIndexBuffer(3, supDn, INDICATOR_DATA);
    // SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexStyle(3, DRAW_NONE);
    SetIndexLabel(3, "Support Dn");

   SetIndexBuffer(4, resUp, INDICATOR_DATA);
    // SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexStyle(4, DRAW_NONE);
    SetIndexLabel(4, "Resistance Up");

   SetIndexBuffer(5, resDn, INDICATOR_DATA);
    // SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexStyle(5, DRAW_NONE);
    SetIndexLabel(5, "Resistance Dn");
   
   SetIndexBuffer(6, ShiftSup, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_NONE);
    SetIndexLabel(6, "Shift Support");

   SetIndexBuffer(7, ShiftRes, INDICATOR_DATA);
    SetIndexStyle(7, DRAW_NONE);
    SetIndexLabel(7, "Shift Resistance");

   SetIndexBuffer(8, SignalUp, INDICATOR_DATA);
    SetIndexArrow(8, 233);
    SetIndexStyle(8, DRAW_ARROW, EMPTY, 1, PaleGreen);
    SetIndexLabel(8, "Signal Up");

   SetIndexBuffer(9, SignalDn, INDICATOR_DATA);
    SetIndexStyle(9, DRAW_ARROW, EMPTY, 1, Crimson);
    SetIndexArrow(9, 234);
    SetIndexLabel(9, "Signal Dn");

    return (INIT_SUCCEEDED);
    // clang-format on
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - periods;
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = 0; i <= candlesBack; i++) {

        if (havePinbarUp(i)) {
            ArrowUp[i + 1] = Low[i + 1];
            notify(0);
        }

        if (havePinbarDown(i)) {
            ArrowDn[i + 1] = High[i + 1];
            notify(1);
        }
    }

    // dibujar rectangulos
    i            = 0;
    double max   = 0;
    double min   = 0;
    int    count = 0;
    int    limit = candlesBack;

    while (count < nrZones && i < candlesBack) {
        double cur_max = MathMax(iClose(NULL, 0, i), iOpen(NULL, 0, i));
        double cur_min = MathMin(iClose(NULL, 0, i), iOpen(NULL, 0, i));
        if (cur_max > max || max == 0) {
            max = cur_max;
        }
        if (cur_min < min || min == 0) {
            min = cur_min;
        }

        i++;
        resUp[i] = EMPTY_VALUE;
        resDn[i] = EMPTY_VALUE;
        supUp[i] = EMPTY_VALUE;
        supDn[i] = EMPTY_VALUE;

        if (ArrowDn[i] != EMPTY_VALUE && iHigh(NULL, 0, i) > max) {
            resUp[i]         = iHigh(NULL, 0, i);
            resDn[i]         = iLow(NULL, 0, i);
            count++;
        }
        if (ArrowUp[i] != EMPTY_VALUE && iLow(NULL, 0, i) < min) {
            supUp[i] = iHigh(NULL, 0, i);
            supDn[i] = iLow(NULL, 0, i);            
            count++;
        }
    }

    drawRectangles();

    // Find Signals:
    double lastSup = 0;
    double lastRes = 0;
    int    n       = 0;

    while (lastSup == 0 && n < limit) {
        if (supUp[n] > 0 && supUp[n] != EMPTY_VALUE) {
            lastSup = supUp[n];
            ShiftSup[0] = n;
            break;
        }
        n++;
    }
    n = 0;
    while (lastRes == 0 && n < limit) {
        if (resDn[n] > 0 && resDn[n] != EMPTY_VALUE) {
            lastRes = resDn[n];
            ShiftRes[0] = n;
            break;
        }
        n++;
    }


    // up signal
    // if (lastSup > 0 && Bid < lastSup) {
    //     SignalUp[0] = low[0];
    // }
    // // dn signal
    // if (lastRes > 0 && Ask > lastRes) {
    //     SignalDn[0] = high[0];
    // }

    return (rates_total);
}
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "ob"); }

bool havePinbarUp(int i)
{
    double sum = 0;
    for (int j = 0; j < 50; j++) {
        sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    }
    double avSize = sum / 50;

    // TODO: signal up
    double op3 = iOpen(NULL, 0, i + 3);
    double hi3 = iHigh(NULL, 0, i + 3);
    double lo3 = iLow(NULL, 0, i + 3);
    double cl3 = iClose(NULL, 0, i + 3);
    double op2 = iOpen(NULL, 0, i + 2);
    double hi2 = iHigh(NULL, 0, i + 2);
    double lo2 = iLow(NULL, 0, i + 2);
    double cl2 = iClose(NULL, 0, i + 2);
    double op1 = iOpen(NULL, 0, i + 1);
    double hi1 = iHigh(NULL, 0, i + 1);
    double lo1 = iLow(NULL, 0, i + 1);
    double cl1 = iClose(NULL, 0, i + 1);

    // if (fabs(cl1 - op1) < avSize) return false;
    if (fabs(hi1 - lo1) < avSize) return false;

    // return (cl3 < op3 && cl2 < op3 && cl1 > op1 && cl1 > op2 && op1 > lo2 && lo2 < cl3 && cl1 > (op3 * 0.70));
    // return (cl2 < op2 && cl1 > op1 && cl1 >= op2);  // Engoulfing de dos velas

    // pinbar:
    double body_high;
    double body_low;
    double body_size;
    double wick_inf_size;
    double wick_sup_size;
    if (cl1 > op1) {
        body_high = cl1;
    } else {
        body_high = op1;
    }
    if (cl1 < op1) {
        body_low = cl1;
    } else {
        body_low = op1;
    }
    wick_inf_size = body_low - lo1;
    wick_sup_size = hi1 - body_high;
    body_size     = fabs(cl1 - op1);
    return (wick_inf_size >= 2 * body_size && wick_inf_size > wick_sup_size * 2);
}

bool havePinbarDown(int i)
{
    // TODO: signal down
    double sum = 0;
    for (int j = 0; j < 50; j++) {
        sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    }
    double avSize = sum / 50;

    double op3 = iOpen(NULL, 0, i + 3);
    double hi3 = iHigh(NULL, 0, i + 3);
    double lo3 = iLow(NULL, 0, i + 3);
    double cl3 = iClose(NULL, 0, i + 3);
    double op2 = iOpen(NULL, 0, i + 2);
    double hi2 = iHigh(NULL, 0, i + 2);
    double lo2 = iLow(NULL, 0, i + 2);
    double cl2 = iClose(NULL, 0, i + 2);
    double op1 = iOpen(NULL, 0, i + 1);
    double hi1 = iHigh(NULL, 0, i + 1);
    double lo1 = iLow(NULL, 0, i + 1);
    double cl1 = iClose(NULL, 0, i + 1);

    // if (fabs(cl1 - op1) < avSize) return false;
    if (fabs(hi1 - lo1) < avSize) return false;

    // return (cl3 > op3 && cl2 > op3 && cl1 < op1 && cl1 < op2 && op1 < hi2 && hi2 > cl3 && cl1 < (op3 * 1.70));
    // return (cl2 > op2 && cl1 < op1 && cl1 <= op2); // Engoulfing de dos velas
    // pinbar:
    double body_high;
    double body_low;
    double body_size;
    double wick_inf_size;
    double wick_sup_size;
    if (cl1 > op1) {
        body_high = cl1;
    } else {
        body_high = op1;
    }
    if (cl1 < op1) {
        body_low = cl1;
    } else {
        body_low = op1;
    }
    wick_inf_size = body_low - lo1;
    wick_sup_size = hi1 - body_high;
    body_size     = fabs(cl1 - op1);
    return (wick_sup_size >= 2 * body_size && wick_sup_size >= wick_inf_size * 2);
}

void drawRectangles()
{
    ObjectsDeleteAll(0, "ob");

    int i     = 1;
    int count = 0;
    while (count < nrZones && i < candlesBack) {
        if (resUp[i] != EMPTY_VALUE) {
            drawRectangle(i, 0);
            count++;
        }
        if (supUp[i] != EMPTY_VALUE) {
            drawRectangle(i, 1);
            count++;
        }
        i++;
    }
}

bool drawRectangle(int shift, uchar side)
{
    color  clr  = side == 0 ? FireBrick : ForestGreen;
    string name = "ob_" + (string)shift;

    datetime time1  = iTime(NULL, 0, shift);
    double   price1 = iHigh(NULL, 0, shift);
    datetime time2  = iTime(NULL, 0, 0);
    double   price2 = iLow(NULL, 0, shift);

    if (!ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2)) {
        Print(__FUNCTION__, ": failed to create a rectangle! Error code = ", GetLastError());
        return (false);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    return true;
}

void notify(int type)
{
    if (IsNewCandle()) {
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

bool IsNewCandle()
{
    static datetime last;
    datetime        current = iTime(NULL, 0, 1);
    if (last != current) {
        last = current;
        return true;
    }
    return false;
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