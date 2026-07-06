//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76331&p=160653#p160653
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

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 4

#property indicator_label1  "Bottom Line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Top Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrHotPink
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Arrow Up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDeepSkyBlue

#property indicator_label4  "Arrow Down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrHotPink

input string T0                    = "== ATR Setup ==";     // === ATR Setup ===
input bool   LinesOn    = true;              // Line On?
input int    atr_period = 20;                // Amplitude
input double atr_multi  = 3;                 // Multiplier

input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = true;   // Notifications On?
input bool   desktop_notifications = true;  // Desktop MT5 Notifications
input bool   email_notifications   = true;   // Email Notifications
input bool   push_notifications    = true;   // Push Mobile Notifications

string       T2                    = "== Set Lines ==";     // === Set  Lines ===
color        LineUpClr             = clrHotPink;          // Line Up Color:
color        LineDnClr             = clrDeepSkyBlue;      // Line Down Color:

string       T3                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowDnClr            = clrHotPink;          // Arrow Down Color:
color        ArrowUpClr            = clrDeepSkyBlue;      // Arrow Up Color:

double ArrowUpBuffer[];
double ArrowDnBuffer[];
double shortStopBuffer[];
double longStopBuffer[];
double topLineBuffer[];
double bottomLineBuffer[];
double dirBuffer[];

int atr_handle;
int periods = 10;
datetime lastNotificationTime = 0;

int OnInit()
{
    SetIndexBuffer(0, bottomLineBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, topLineBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, ArrowUpBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, ArrowDnBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, dirBuffer, INDICATOR_DATA);
    SetIndexBuffer(5, shortStopBuffer, INDICATOR_DATA);
    SetIndexBuffer(6, longStopBuffer, INDICATOR_DATA);
    
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, LineDnClr);
    PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
    
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, LineUpClr);
    PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
    
    PlotIndexSetInteger(2, PLOT_ARROW, 233);
    PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 0);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);
    
    PlotIndexSetInteger(3, PLOT_ARROW, 234);
    PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 0);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);
    
    if (!LinesOn) {
        PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
    }
    
    if (!ArrowsOn) {
        PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
    }
    
    PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_NONE);
    
    atr_handle = iATR(_Symbol, _Period, atr_period);
    if (atr_handle == INVALID_HANDLE) {
        Print("Error creating ATR indicator");
        return INIT_FAILED;
    }
    
    IndicatorSetString(INDICATOR_SHORTNAME, "Fibo Algo");
    
    return INIT_SUCCEEDED;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    if (rates_total < periods) return 0;
    
    int start = prev_calculated == 0 ? 0 : rates_total - prev_calculated;
    if (start < 0) start = 0;
    
    double atr_values[];
    if (CopyBuffer(atr_handle, 0, 0, rates_total, atr_values) <= 0) {
        Print("Error copying ATR buffer");
        return 0;
    }
    
    for (int i = start; i < rates_total; i++) {
        double atr = atr_values[i];
        double atrm = atr * atr_multi;
        double hl2 = (high[i] + low[i]) / 2;
        
        if (i == 0) {
            dirBuffer[i] = 0;
        } else {
            dirBuffer[i] = dirBuffer[i - 1];
        }
        
        ArrowDnBuffer[i] = EMPTY_VALUE;
        ArrowUpBuffer[i] = EMPTY_VALUE;
        
        longStopBuffer[i] = hl2 - atrm;
        if (i > 0 && close[i - 1] > longStopBuffer[i - 1]) {
            longStopBuffer[i] = MathMax(longStopBuffer[i], longStopBuffer[i - 1]);
        }
        
        shortStopBuffer[i] = hl2 + atrm;
        if (i > 0 && close[i - 1] < shortStopBuffer[i - 1]) {
            shortStopBuffer[i] = MathMin(shortStopBuffer[i], shortStopBuffer[i - 1]);
        }
        
        if (i > 0 && close[i - 1] > shortStopBuffer[i - 1]) {
            dirBuffer[i] = 1;
            
            if (i > 0 && dirBuffer[i - 1] == -1) {
                ArrowUpBuffer[i - 1] = low[i - 1];
                if (i == rates_total - 1 && time[i - 1] != lastNotificationTime) {
                    Notifications(0);
                    lastNotificationTime = time[i - 1];
                }
            }
        }
        
        if (i > 0 && close[i - 1] < longStopBuffer[i - 1]) {
            dirBuffer[i] = -1;
            
            if (i > 0 && dirBuffer[i - 1] == 1) {
                ArrowDnBuffer[i - 1] = high[i - 1];
                if (i == rates_total - 1 && time[i - 1] != lastNotificationTime) {
                    Notifications(1);
                    lastNotificationTime = time[i - 1];
                }
            }
        }
        
        if (dirBuffer[i] == 1) {
            bottomLineBuffer[i] = longStopBuffer[i];
            topLineBuffer[i] = EMPTY_VALUE;
        }
        if (dirBuffer[i] == -1) {
            topLineBuffer[i] = shortStopBuffer[i];
            bottomLineBuffer[i] = EMPTY_VALUE;
        }
    }
    
    return rates_total;
}

void OnDeinit(const int reason)
{
    if (atr_handle != INVALID_HANDLE) {
        IndicatorRelease(atr_handle);
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

string GetTimeFrame(ENUM_TIMEFRAMES period)
{
    switch (period) {
        case PERIOD_M1:  return "M1";
        case PERIOD_M5:  return "M5";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_H1:  return "H1";
        case PERIOD_H4:  return "H4";
        case PERIOD_D1:  return "D1";
        case PERIOD_W1:  return "W1";
        case PERIOD_MN1: return "MN1";
    }
    return IntegerToString((int)period);
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76331&p=160653#p160653
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