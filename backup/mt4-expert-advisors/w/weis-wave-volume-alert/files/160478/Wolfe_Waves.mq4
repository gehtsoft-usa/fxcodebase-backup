// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160325#p160325
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

// ------------------------------------------------------------------
input int depth=12;     // Depth
input int deviation=5;  // Deviation
input int backstep=3;   // Backstep
int    periods               = 10;
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

int lastSignal=0;

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
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    // clang-format off
    if (prev_calculated == 0) { start = 1000; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on


    for (i = start; i >= 0; i--) {
        double z = iCustom(NULL, 0, "ZigZag", depth, deviation, backstep, 0, i);
        if(z == 0.0) continue;

        if(lastSignal != 1)
        if (haveSignalUp(i)) {
            ArrowUp[i] = Low[i];
            lastSignal = 1;
            notify(0);
        }

        if(lastSignal != -1)
        if (haveSignalDown(i)) {
            ArrowDn[i] = High[i];
            lastSignal =-1;
            notify(1);
        }
    }
    return (rates_total);
}

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


double ZigZagPoint(int target, int ini)
{
    int found = 0;
    for(int i = ini; i <= ini+50; i++)
    {
        double zz = iCustom(NULL, 0, "ZigZag", depth, deviation, backstep, 0, i);
        if(zz != 0.0 && zz != EMPTY_VALUE)
        {
            found++;
            if(found > 10) return 0.0; // Evita bucle infinito si no encuentra suficientes puntos
            
            if(found == target) // +1 porque el primer punto es el 0
                return zz;
        }
    }
    return 0.0; // No encontrado
}

bool haveSignalUp(int i)
{
    // TODO: signal up
    double zz0 = ZigZagPoint(1, i);
    double zz1 = ZigZagPoint(2, i);
    double zz2 = ZigZagPoint(3, i);
    double zz3 = ZigZagPoint(4, i);
    double zz4 = ZigZagPoint(5, i);

    // BUY:  0 < 1 , 2 < 1 ,  2 < 3 , 1 < 3 , 2 < 4
    if( zz0 != 0 && zz1 != 0 && zz2 != 0 && zz3 != 0 && zz4 != 0 )
    return (zz1 >= zz0 && zz1 >= zz2 && zz3 >= zz2 && zz3 >= zz4 );
    else return 0;
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    double zz0 = ZigZagPoint(1, i);
    double zz1 = ZigZagPoint(2, i);
    double zz2 = ZigZagPoint(3, i);
    double zz3 = ZigZagPoint(4, i);
    double zz4 = ZigZagPoint(5, i);

    // SELL: 0 > 1 , 2 > 1 , 2 > 3 , 1 > 3 , 2 > 4
    if( zz0 != 0 && zz1 != 0 && zz2 != 0 && zz3 != 0 && zz4 != 0 )
    return (zz1 <= zz0 && zz1 <= zz2 && zz3 <= zz2 && zz3 <= zz4);
    else return 0;

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
// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160325#p160325
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