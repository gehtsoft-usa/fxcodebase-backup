// Available @ https://fxcodebase.com/code/viewtopic.php?f=17&p=160399#p160399
//
// Copyright © 2025, Gehtsoft USA LLC
// Website: http://fxcodebase.com
// PayPal: https://goo.gl/9Rj74e
//
// Developed by: Mario Jemic
// Email: mario.jemic@gmail.com
// Website: https://mario-jemic.com
// Patreon: http://tiny.cc/1ybwxz
// Buy Me a Coffee: http://tiny.cc/bj7vxz
//
// Crypto Donations
// BTC  : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
// SOL  : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
// ETH / BNB / USDT / XRP (ERC20 & BEP20) : 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
//

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double LineUp[];
double LineDn[];
enum gap_filter_type { no_filter, wopag, wpag };
input gap_filter_type gap_filter = no_filter;
// ------------------------------------------------------------------
input int    Period                = 2;
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
color        ArrowUpClr            = clrBlue;               // Arrow Up Color:
color        ArrowDnClr            = clrRed;                // Arrow Down Color:
// ------------------------------------------------------------------

// Mark: Oninit
int OnInit()
{
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexLabel(0, "Line Up");

    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexLabel(1, "Line Dn");

    if (!LinesOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(2, 233);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(2, "Arrow Up");

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(3, 234);
    SetIndexLabel(3, "Arrow Dn");

    if (!ArrowsOn) {
        SetIndexStyle(2, DRAW_NONE);
        SetIndexStyle(3, DRAW_NONE);
    }
    return (INIT_SUCCEEDED);
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    // clang-format off
    if (prev_calculated == 0) { start = rates_total - Period; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    for (i = start; i >= 0; i--) {
        if (haveSignalUp(i) == 1) {
            ArrowUp[i] = Low[i];
            notify(0);
        }

        if (haveSignalDown(i) == -1) {
            ArrowDn[i] = High[i];
            notify(1);
        }
    }
    return (rates_total);
}


int haveSignalUp(int i)
{
    // TODO: signal up
    double op = iOpen(NULL, 0, i);
    double cl2 = iClose(NULL, 0, i + 1);

    int signal=0;
    if (iClose(NULL, 0, i) > iHigh(NULL, 0, i + 1)) signal = 1;
    
    // gap filter
    if (signal == 1 && gap_filter == wpag) {
        if (op >= cl2) signal = 0;
    } else if (signal == 1 && gap_filter == wopag) {
        if (op == cl2) signal = 0;
    }

    for (int n = 1; n < Period; n++) {
        if (signal == 1 && iClose(NULL, 0, i + n) > iOpen(NULL, 0, i + n)) {
            signal = 0;
            break;
        }
    }

    return signal;
}

int haveSignalDown(int i)
{
    // TODO: signal down
    int signal = 0;
    double op = iOpen(NULL, 0, i);
    double cl2 = iClose(NULL, 0, i + 1);
    
    if (iClose(NULL, 0, i) < iLow(NULL, 0, i + 1)) signal = -1;

    if (signal == -1 && gap_filter == wpag) {
        if (op <= cl2) signal = 0;
    } else if (signal == -1 && gap_filter == wopag) {
        if (op == cl2) signal = 0;
    }

    for (int n = 1; n < Period; n++) {
        if (signal == -1 && iClose(NULL, 0, i + n) < iOpen(NULL, 0, i + n)) {
            signal = 0;
            break;
        }
    }

    return signal;
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
// Available @ https://fxcodebase.com/code/viewtopic.php?f=17&p=160399#p160399
//
// Copyright © 2025, Gehtsoft USA LLC
// Website: http://fxcodebase.com
// PayPal: https://goo.gl/9Rj74e
//
// Developed by: Mario Jemic
// Email: mario.jemic@gmail.com
// Website: https://mario-jemic.com
// Patreon: http://tiny.cc/1ybwxz
// Buy Me a Coffee: http://tiny.cc/bj7vxz
//
// Crypto Donations
// BTC  : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
// SOL  : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
// ETH / BNB / USDT / XRP (ERC20 & BEP20) : 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7