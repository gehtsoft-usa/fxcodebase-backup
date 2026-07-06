//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76376
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window
// #property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double LineUp[];
double LineDn[];

// ------------------------------------------------------------------
input string T0                    = "== CCI =="; // === CCI ===
input int    periods               = 20;
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Lines ==";     // === Set  Lines ===
bool         LinesOn               = false;                 // Line On?
color        LineUpClr             = clrBlue;               // Line Up Color:
color        LineDnClr             = clrRed;                // Line Down Color:
input int    CandlesBack           = 10;                    // Candles Back to SL:
input double tpMultiplier          = 2;                     // TP Ratio:
input string T3                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
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

void OnDeinit(const int reason) { ObjectsDeleteAll(0, "line"); }


// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    // clang-format off
    int start, i;
    if (prev_calculated == 0) { start = rates_total - periods; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    for (i = start; i >= 0; i--) {

        if (ConditionsToLineUp(i)) {
            LineUp[i] = valueLineUp(i);
        }

        if (ConditionsToLineDn(i)) {
            LineDn[i] = valueLineDn(i);
        }

        if (haveSignalUp(i)) {
            ArrowUp[i] = close[i + 1];
            drawLine(close[i + 1], i + 5, i, Black);

            double sl = Stop("buy", i);
            drawLine(sl, i + 5, i, Red);
            drawLine(TP("buy", i, sl), i + 5, i, Blue);

            notify(0);
        }

        if (haveSignalDown(i)) {
            ArrowDn[i] = close[i + 1];
            drawLine(close[i + 1], i + 5, i, Black);
            
            double sl = Stop("sell", i);
            drawLine(sl, i + 5, i, Red);
            drawLine(TP("sell", i, sl), i + 5, i, Blue);
            
            notify(1);
        }
    }
    return (rates_total);
}

double valueLineUp(int i) { return iCCI(NULL, 0, periods, PRICE_TYPICAL, i); }

double valueLineDn(int i) { return 0; }

bool ConditionsToLineUp(int i) { return true; }

bool ConditionsToLineDn(int i) { return true; }

bool haveSignalUp(int i)
{
    // TODO: signal up
    double cci0 = iCCI(NULL, 0, periods, PRICE_TYPICAL, i);
    double cci1 = iCCI(NULL, 0, periods, PRICE_TYPICAL, i + 1);

    return (cci1 <= 0 && cci0 > 0);
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    double cci0 = iCCI(NULL, 0, periods, PRICE_TYPICAL, i);
    double cci1 = iCCI(NULL, 0, periods, PRICE_TYPICAL, i + 1);

    return (cci1 >= 0 && cci0 < 0);
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

void drawLine(double price, int iniPos, int endPos, color clr)
{
    string tx;
    if(clr == Red) tx = "SL";
    if(clr == Black) tx = "Entry";

    string name = "line" + (string)iTime(NULL, 0, iniPos) + tx;
    ObjectCreate(0, name, OBJ_TREND, 0, iTime(NULL, 0, iniPos), price, iTime(NULL, 0, endPos), price);
    ObjectSet(name, OBJPROP_RAY, false);
    ObjectSet(name, OBJPROP_COLOR, clr);
}

double Stop(string side, int in)
{
    if (side == "buy") return findLastMin(in);
    if (side == "sell") return findLastMax(in);

    return 0;
}

double TP(string side, int in, double sl)
{
    double entry = iClose(NULL, 0, in + 1);
    if (side == "buy") return entry + (entry - sl) * tpMultiplier;
    if (side == "sell") return entry - (sl - entry) * tpMultiplier;

    return 0;
}

double findLastMax(int index)
{
    double m    = 0;
    int    back = CandlesBack;
    for (int i = index; i < index+back; i++) {
        double h = iHigh(NULL, 0, i);
        if (m == 0 || h > m) {
            m = h;
        }
    }
    return m;
}
double findLastMin(int index)
{
    double m    = 0;
    int    back = CandlesBack;
    for (int i = index; i < index+back; i++) {
        double l = iLow(NULL, 0, i);
        if (m == 0 || l < m) {
            m = l;
        }
    }
    return m;
}

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76376
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/