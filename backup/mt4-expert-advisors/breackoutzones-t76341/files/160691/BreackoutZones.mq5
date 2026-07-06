//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76341
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
#property indicator_label7 "Signal Up"
#property indicator_type7  DRAW_ARROW
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Signal Dn"
#property indicator_type8  DRAW_ARROW
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

//--- indicator buffers
double SignalUp[];
double SignalDn[];
double OBUp[];
double OBDn[];
double supUp[];
double supDn[];
double resUp[];
double resDn[];

// NOTE: Inputs
// ------------------------------------------------------------------
input string T0                    = "== Set Arrows ==";    // Set Arrows
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

int nrZones     = 20;
int candlesBack = 1000;

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

    SetIndexBuffer(1, OBDn, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 159);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);

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

    SetIndexBuffer(6, SignalUp, INDICATOR_DATA);
    PlotIndexSetInteger(6, PLOT_ARROW, 233);
    PlotIndexSetString(6, PLOT_LABEL, "Signal Up");
    PlotIndexSetInteger(6, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, Blue);

    SetIndexBuffer(7, SignalDn, INDICATOR_DATA);
    PlotIndexSetString(7, PLOT_LABEL, "Signal Dn");
    PlotIndexSetInteger(7, PLOT_ARROW, 234);
    PlotIndexSetInteger(7, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(7, PLOT_LINE_COLOR, Crimson);

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

    if (prev_calculated == 0) {
        ArrayInitialize(SignalUp, EMPTY_VALUE);
        ArrayInitialize(SignalDn, EMPTY_VALUE);
        ArrayInitialize(OBUp, EMPTY_VALUE);
        ArrayInitialize(OBDn, EMPTY_VALUE);
        ArrayInitialize(supUp, EMPTY_VALUE);
        ArrayInitialize(supDn, EMPTY_VALUE);
        ArrayInitialize(resUp, EMPTY_VALUE);
        ArrayInitialize(resDn, EMPTY_VALUE);
    }

    int last = 0;
    for (i = start; i < rates_total && !IsStopped(); i++) {
        if(last != 1)
        if (haveBreackoutUp(i, open, high, low, close)) {
            OBUp[i - 5] = low[i - 5];
            last = 1;

            if (newCandle.IsNewCandle()) {
                Notifications(0);
            }
        }

        if(last != -1)
        if (haveBreackoutDown(i, open, high, low, close)) {
            OBDn[i - 5] = high[i - 5];
            last = -1;

            if (newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }
    }

    // Find Fresh Suports and Ressitances
    int cur_bar = iBars(NULL, 0) - 1;
    if (candlesBack > iBars(NULL, 0) - 1) candlesBack = iBars(NULL, 0) - 5;
    i            = cur_bar;
    int    limit = cur_bar + 1 - candlesBack;
    double max   = 0;
    double min   = 0;
    int    count = 0;

    while (count < nrZones && i > limit) {
        i--;
        resUp[i] = 0;
        resDn[i] = 0;
        supUp[i] = 0;
        supDn[i] = 0;

        if (OBDn[i] > 0 && OBDn[i] != EMPTY_VALUE) {
            resUp[i] = high[i];
            resDn[i] = low[i];
            count++;
        }
        if (OBUp[i] > 0 && OBUp[i] != EMPTY_VALUE) {
            supUp[i] = high[i];
            supDn[i] = low[i];
            count++;
        }
    }
    drawRectangles();

  
    return (rates_total);
}
//+------------------------------------------------------------------+

bool haveBreackoutUp(int i, const double &op[], const double &hi[], const double &lo[], const double &cl[])
{

    // TODO: signal up
    double lo1 = lo[i - 1];
    double lo2 = lo[i - 2];
    double lo3 = lo[i - 3];
    double hi4 = hi[i - 5];
    
    return (lo1 > hi4 && lo2 > hi4 && lo3 > hi4);
}

bool haveBreackoutDown(int i, const double &op[], const double &hi[], const double &lo[], const double &cl[])
{
    // TODO: signal down
    double hi1 = hi[i - 1];
    double hi2 = hi[i - 2];
    double hi3 = hi[i - 3];
    double lo4 = lo[i - 5];
    
    return (hi1 < lo4 && hi2 < lo4 && hi3 < lo4);
}

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
    color  clr  = side == 0 ? FireBrick : ForestGreen;
    string name = "ob_" + (string)shift;

    datetime time1  = iTime(NULL, 0, shift);
    double   price1 = iHigh(NULL, 0, shift);
    datetime time2  = iTime(NULL, 0, 0);
    double   price2 = iLow(NULL, 0, shift);

    int i = 1;
    time2  = iTime(NULL, 0, shift + i);
    while (iClose(Symbol(),0,shift+i) >= price2  && iClose(Symbol(),0,shift+i) <= price1)
    {
        i++;
        time2  = iTime(NULL, 0, shift + i);
    }

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
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76341
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