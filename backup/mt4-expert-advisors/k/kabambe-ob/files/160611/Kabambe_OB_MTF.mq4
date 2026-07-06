//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160559#p160559
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
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 8

// clang-format off
#define BullColor C'255,82,82'
#define BearColor C'76,175,80'
// clang-format on

input ENUM_TIMEFRAMES TF = PERIOD_H1; // Timeframe for MTF

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double supUp[];
double supDn[];
double resUp[];
double resDn[];
double SignalUp[];
double SignalDn[];

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

   SetIndexBuffer(6, SignalUp, INDICATOR_DATA);
    SetIndexArrow(6, 233);
    SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(6, "Signal Up");

   SetIndexBuffer(7, SignalDn, INDICATOR_DATA);
    SetIndexStyle(7, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(7, 234);
    SetIndexLabel(7, "Signal Dn");

    return (INIT_SUCCEEDED);
    // clang-format on
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    // clang-format off
    int start, i;
    if (prev_calculated == 0) { start = rates_total - periods; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    for (i = start; i >= 0; i--) {
        if (haveSignalUp(i) > 0) {
            ArrowUp[i + 3] = Low[i + 3];
            notify(0);
        }
        if (haveSignalDown(i) > 0) {
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
        double cur_max = MathMax(iHigh(NULL, 0, i), iLow(NULL, 0, i));
        double cur_min = MathMin(iHigh(NULL, 0, i), iLow(NULL, 0, i));
    
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

    for (int n = 0; n < 100; n++) 
    {
        if(ArrowUp[n] != EMPTY_VALUE) {
            SignalUp[n] = ArrowUp[n];
            break;
        }
        if(ArrowDn[n] != EMPTY_VALUE){ 
            SignalDn[n] = ArrowDn[n];
            break;
        }
    }

    drawRectangles();
    return (rates_total);
}
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "ob"); }


datetime haveSignalUp(int iCurrTF)
{
    int i = iBarShift(NULL, TF, iTime(NULL, 0, iCurrTF));
    
    // TODO: signal up
    double op4 = iOpen(NULL,  TF, i + 4);
    double hi4 = iHigh(NULL,  TF, i + 4);
    double lo4 = iLow(NULL,   TF, i + 4);
    double cl4 = iClose(NULL, TF, i + 4);
    double op3 = iOpen(NULL,  TF, i + 3);
    double hi3 = iHigh(NULL,  TF, i + 3);
    double lo3 = iLow(NULL,   TF, i + 3);
    double cl3 = iClose(NULL, TF, i + 3);
    double op2 = iOpen(NULL,  TF, i + 2);
    double hi2 = iHigh(NULL,  TF, i + 2);
    double lo2 = iLow(NULL,   TF, i + 2);
    double cl2 = iClose(NULL, TF, i + 2);
    double op1 = iOpen(NULL,  TF, i + 1);
    double hi1 = iHigh(NULL,  TF, i + 1);
    double lo1 = iLow(NULL,   TF, i + 1);
    double cl1 = iClose(NULL, TF, i + 1);

    // if (fabs(cl1 - op1) < avSize) return false;
    if(lo3 < lo4 && lo2 > lo3 && (lo2 > lo3 ||  lo1 > lo3) == true)
    {
        return iTime(NULL, TF, i);
    }
    return -1;
}

datetime haveSignalDown(int iCurrTF)
{
    // TODO: signal down
    int i = iBarShift(NULL, TF, iTime(NULL, 0, iCurrTF));
    double op4 = iOpen(NULL,  TF, i + 4);
    double hi4 = iHigh(NULL,  TF, i + 4);
    double lo4 = iLow(NULL,   TF, i + 4);
    double cl4 = iClose(NULL, TF, i + 4);
    double op3 = iOpen(NULL,  TF, i + 3);
    double hi3 = iHigh(NULL,  TF, i + 3);
    double lo3 = iLow(NULL,   TF, i + 3);
    double cl3 = iClose(NULL, TF, i + 3);
    double op2 = iOpen(NULL,  TF, i + 2);
    double hi2 = iHigh(NULL,  TF, i + 2);
    double lo2 = iLow(NULL,   TF, i + 2);
    double cl2 = iClose(NULL, TF, i + 2);
    double op1 = iOpen(NULL,  TF, i + 1);
    double hi1 = iHigh(NULL,  TF, i + 1);
    double lo1 = iLow(NULL,   TF, i + 1);
    double cl1 = iClose(NULL, TF, i + 1);

    if(hi3 > hi4 && hi2 < hi3 && (hi2 < hi3 ||  hi1 < lo3)==true)
    {
        return iTime(NULL, TF, i);
    }
    return -1;
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
    color  clr  = side == 0 ? BullColor : BearColor;
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

//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160559#p160559
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
//FOOTER:END
 