// Available https://fxcodebase.com/code/viewtopic.php?f=38&t=75956

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
#property indicator_buffers 6
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double supUp[];
double supDn[];
double resUp[];
double resDn[];

// ------------------------------------------------------------------
input int    periods               = 10;
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

int nrZones = 20;
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

    for (i = start; i >= 0; i--) {
        if (haveSignalUp(i)) {
            ArrowUp[i + 3] = Low[i + 3];
            notify(0);
        }

        if (haveSignalDown(i)) {
            ArrowDn[i + 3] = High[i + 3];
            notify(1);
        }
    }

    // dibujar rectangulos
    i            = 0;
    double max   = 0;
    double min   = 0;
    int    count = 0;

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
        if (ArrowDn[i] != EMPTY_VALUE && iHigh(NULL, 0, i) > max) {
            resUp[i] = iHigh(NULL, 0, i);
            resDn[i] = iLow(NULL, 0, i);
            count++;
        }
        if (ArrowUp[i] != EMPTY_VALUE && iLow(NULL, 0, i) < min) {
            supUp[i] = iHigh(NULL, 0, i);
            supDn[i] = iLow(NULL, 0, i);
            count++;
        }
    }

    drawRectangles();
    return (rates_total);
}
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "ob"); }

double valueLineUp(int i)
{
    double sum = 0;
    for (int j = 0; j < periods; j++) {
        sum += iLow(NULL, 0, i + j);
    }
    return sum / periods;
}

double valueLineDn(int i)
{
    double sum = 0;
    for (int j = 0; j < periods; j++) {
        sum += iHigh(NULL, 0, i + j);
    }
    return sum / periods;
}

bool ConditionsToLineUp(int i) { return true; }

bool ConditionsToLineDn(int i) { return true; }

bool haveSignalUp(int i)
{
    // double sum = 0;
    // for (int j = 0; j < 50; j++) {
    //     sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    // }
    // double avSize = sum / 50;

    // TODO: signal up
    double op5 = iOpen(NULL, 0, i + 5);
    double hi5 = iHigh(NULL, 0, i + 5);
    double lo5 = iLow(NULL, 0, i + 5);
    double cl5 = iClose(NULL, 0, i + 5);
    
    double op4 = iOpen(NULL, 0, i + 4);
    double hi4 = iHigh(NULL, 0, i + 4);
    double lo4 = iLow(NULL, 0, i + 4);
    double cl4 = iClose(NULL, 0, i + 4);

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

    return (cl5 < op5 && cl4 < op4 && cl3 < op3 &&  cl2 > op2 && cl1 > op1  && lo1 > hi3);
        // && cl2 < op3 && cl1 > op1 && cl1 > op2 && op1 > lo2 && lo2 < cl3 && cl1 > (op3 * 0.70));
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    // double sum = 0;
    // for (int j = 0; j < 50; j++) {
    //     sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    // }
    // double avSize = sum / 50;

    double op5 = iOpen(NULL, 0, i + 5);
    double hi5 = iHigh(NULL, 0, i + 5);
    double lo5 = iLow(NULL, 0, i + 5);
    double cl5 = iClose(NULL, 0, i + 5);
    
    double op4 = iOpen(NULL, 0, i + 4);
    double hi4 = iHigh(NULL, 0, i + 4);
    double lo4 = iLow(NULL, 0, i + 4);
    double cl4 = iClose(NULL, 0, i + 4);

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

    return (cl5 > op5 && cl4 > op4 && cl3 > op3 && cl2 < op2 && cl1 < op1 && hi1 < lo3);
    // return (cl3 > op3 && cl2 > op3 && cl1 < op1 && cl1 < op2 && op1 < hi2 && hi2 > cl3 && cl1 < (op3 * 1.70));
}

void drawRectangles()
{
    ObjectsDeleteAll(0, "ob");
    int i     = 1;
    int count = 0;
    while (count < nrZones && i <candlesBack) {
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

// Available @   https://fxcodebase.com/code/viewtopic.php?f=38&t=75956

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
