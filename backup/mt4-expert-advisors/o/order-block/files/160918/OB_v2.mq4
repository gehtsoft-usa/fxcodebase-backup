//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160734#p160734
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
#property indicator_buffers 6
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
input int    periods               = 10;
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
string       T3                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = clrSkyBlue;              // Arrow Up Color:
color        ArrowDnClr            = clrRed;            // Arrow Down Color:
// ------------------------------------------------------------------

int nrZones = 20;
int candlesBack = 1000;

// clang-format off
// Mark: Oninit
int OnInit()
{
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(0, "Arrow Up");

   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    SetIndexLabel(1, "Arrow Dn");


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
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "ob"); }

bool haveSignalUp(int i)
{
    double sum = 0;
    for (int j = 0; j < 20; j++) {
        sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    }
    double avSize = sum / 20;

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

    if (fabs(cl1 - op1) < avSize) return false;

    double size3 = fabs(op3-cl3);
    return (cl3 < op3 && cl2 < op3 && cl1 > op1 && cl1 > op2 && op1 > lo2 && lo2 < cl3 && cl1 > ( cl3 + size3 * 0.80));
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    double sum = 0;
    for (int j = 0; j < 20; j++) {
        sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    }
    double avSize = sum / 20;

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

    if (fabs(cl1 - op1) < avSize) return false;
    
    double size3 = fabs(op3-cl3);
    return (cl3 > op3 && cl2 > op3 && cl1 < op1 && cl1 < op2 && op1 < hi2 && hi2 > cl3 && cl1 < (cl3- size3 * 0.70));
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
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160734#p160734
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