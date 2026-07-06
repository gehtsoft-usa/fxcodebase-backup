//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160485#p160485
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
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID

//--- indicator buffers
double LineUp[];
double LineDn[];

// ------------------------------------------------------------------
input string       Tcustom               = "==== Indicator Setup ===="; // ————————————————————————
input const string indicator_file        = "ZZ_Delta_v2";               // Indicator File:
input int          InpDepth              = 12;                          // Depth
input int          InpDeviation          = 5;                           // Deviation
input int          InpBackstep           = 3;                           // Backstep
string             T1                    = "== Notifications ==";       // ————————————
bool               notifications         = false;                       // Notifications On?
bool               desktop_notifications = false;                       // Desktop MT4 Notifications
bool               email_notifications   = false;                       // Email Notifications
bool               push_notifications    = false;                       // Push Mobile Notifications
input string       T2                    = "== Set Lines ==";           // ————————————
input bool         LinesOn               = true;                        // Line On?
input color        LineUpClr             = clrRoyalBlue;                // Line Up Color:
input color        LineDnClr             = clrFireBrick;                // Line Down Color:
// ------------------------------------------------------------------

class CNewCandle
{
  private:
    int    _initialCandles;
    string _symbol;
    int    _tf;

  public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
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

double HighDelta(int index) { return iCustom(NULL, 0, indicator_file, InpDepth, InpDeviation, InpBackstep, 5, index); }
double LowDelta(int index) { return iCustom(NULL, 0, indicator_file, InpDepth, InpDeviation, InpBackstep, 6, index); }

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 4, LineUpClr);
    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 4, LineDnClr);
    if (!LinesOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    //---
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    // clang-format off
    int start, i;
  if (prev_calculated == 0) { start = 1000; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    for (i = start; i >= 0; i--) {

        LineUp[i] = LineUp[i+1];
        LineDn[i] = LineDn[i+1];

        double h = HighDelta(i);
        double l = LowDelta(i);

        if (h != 0 && h != EMPTY_VALUE) {
            if( h >0 ) {LineUp[i] = h; LineDn[i] = EMPTY_VALUE;}
            if( h <0 ) {LineDn[i] = h; LineUp[i] = EMPTY_VALUE;}
        }

        if (l != 0 && l != EMPTY_VALUE) {
            if( l < 0 ) {LineDn[i] = l; LineUp[i] = EMPTY_VALUE;}
            if( l > 0 ) {LineUp[i] = l; LineDn[i] = EMPTY_VALUE;}
        }
    }
    return (rates_total);
}

// ------------------------------------------------------------------

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
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160485#p160485
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