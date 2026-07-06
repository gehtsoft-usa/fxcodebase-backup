//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76366
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
#property indicator_buffers 4
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double LineUp[];
double LineDn[];

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
    if (prev_calculated == 0) {
        start = rates_total - periods;
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = start; i >= 0; i--) {

        if (ConditionsToLineUp(i)) {
            LineUp[i] = valueLineUp(i);
        }

        
        if (ConditionsToLineDn(i)) {
            LineDn[i] = valueLineDn(i);
        }
        
        if (haveSignalUp(i)) {
            ArrowUp[i] = Low[i];
            notify(0);
        }

        if (haveSignalDown(i)) {
            ArrowDn[i] = High[i];
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

bool ConditionsToLineUp(int i) { return true; }

bool ConditionsToLineDn(int i) { return true; }

bool haveSignalUp(int i)
{
    // TODO: signal up
    return (iClose(NULL, 0, i + 2) > iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) > iOpen(NULL, 0, i + 1));
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    return (iClose(NULL, 0, i + 2) < iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) < iOpen(NULL, 0, i + 1));
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


//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76366
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