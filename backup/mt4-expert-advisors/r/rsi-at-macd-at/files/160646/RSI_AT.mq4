//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76329
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
//HEADER:END

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4


// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double Rsi[];
double LineDn[];

// ------------------------------------------------------------------

input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
string       T2                    = "== Set Lines ==";     // === Set  Lines ===
bool         LinesOn               = true;                  // Line On?
color        LineUpClr             = Black;                 // Line Up Color:
string       T3                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = clrBlue;               // Arrow Up Color:
color        ArrowDnClr            = clrRed;                // Arrow Down Color:
// ------------------------------------------------------------------

#define Section_RSI
#ifdef Section_RSI

// Mark: Section_RSI
input string             trsi          = "== RSI Setup =="; // ————————————————————————
input int                rsi_periods   = 14;                // RSI periods:
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;       // Applied price
input double             ob_level      = 70;                // Overbougth:
input double             os_level      = 30;                // Oversold:
input bool               consider_ta   = true;              // Consider Thecnical Analysis

class ConditionRsiOverbougth
{
  public:
    bool evaluate(int i) { return iRSI(NULL, 0, rsi_periods, applied_price, i + 1) > ob_level; }
};
ConditionRsiOverbougth cdRsiOverbougth;

class ConditionRsiOversold
{
  public:
    bool evaluate(int i) { return iRSI(NULL, 0, rsi_periods, applied_price, i + 1) < os_level; }
};
ConditionRsiOversold cdRsiOversold;

#endif

// Mark: Oninit
int OnInit()
{
    SetIndexBuffer(0, Rsi, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexLabel(0, "RSI");

    SetIndexBuffer(1, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(1, 233);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(1, "Over Sold");

    SetIndexBuffer(2, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(2, 234);
    SetIndexLabel(2, "Over Bougth");

    IndicatorSetInteger(INDICATOR_LEVELS, 2);
    IndicatorSetDouble(INDICATOR_LEVELVALUE,0,os_level); 
    IndicatorSetDouble(INDICATOR_LEVELVALUE,1,ob_level); 
    SetLevelStyle(STYLE_DOT, 1, C'50,50,50');

    return (INIT_SUCCEEDED);
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;

    // clang-format off
    if (prev_calculated == 0) { start = rates_total - rsi_periods+1; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    for (i = start; i >= 0; i--) {
        Rsi[i] = iRSI(NULL, 0, rsi_periods, applied_price, i);

        if (cdRsiOversold.evaluate(i)) {
            if (consider_ta) {
                if (iClose(NULL, 0, i + 2) < iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) >= iOpen(NULL, 0, i + 2)) {
                    ArrowUp[i] = Rsi[i];
                    notify(1);
                }
            } else {
                    ArrowUp[i] = Rsi[i];
                    notify(0);
                }
        }

        if (cdRsiOverbougth.evaluate(i)) {
            if (consider_ta) {
                if (iClose(NULL, 0, i + 2) > iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) <= iOpen(NULL, 0, i + 2)) {
                    ArrowDn[i] = Rsi[i];
                    notify(1);
                }
            } else {
                ArrowDn[i] = Rsi[i];
                notify(1);
            }
        }
    }
    return (rates_total);
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

//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76329
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
//HEADER:END