//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76365
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
#property indicator_separate_window
#property indicator_buffers 16
#property indicator_plots 12
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_style3 STYLE_SOLID
#property indicator_type4  DRAW_HISTOGRAM
#property indicator_style4 STYLE_SOLID
#property indicator_type5  DRAW_HISTOGRAM
#property indicator_style5 STYLE_SOLID
#property indicator_type6  DRAW_HISTOGRAM
#property indicator_style6 STYLE_SOLID

//--- indicator buffers
double _up_BodyHigh[];
double _up_BodyLow[];
double _up_high[];
double _up_basehigh[];
double _up_low[];
double _up_baselow[];

double _dn_BodyHigh[];
double _dn_BodyLow[];
double _dn_high[];
double _dn_basehigh[];
double _dn_low[];
double _dn_baselow[];

// To Show in Data Window
double _open[];
double _high[];
double _low[];
double _close[];

input string tmacd               = "== MACD Setup =="; // ————————————————————————
input int    macd_fast_periods   = 12;                 // Fast Periods:
input int    macd_slow_periods   = 26;                 // Slow Periods:
input int    macd_signal_periods = 9;                  // MACD Periods:

double macd(int i) { return iMACD(NULL, 0, macd_fast_periods, macd_slow_periods, macd_signal_periods, PRICE_CLOSE, 0, i); }
double macd_m1(int i) { return iMACD(NULL, PERIOD_M1, macd_fast_periods, macd_slow_periods, macd_signal_periods, PRICE_CLOSE, 0, i); }

// ------------------------------------------------------------------
input string T2          = "== Set Colors =="; // ————————————
input color  CandleUpClr = clrBlue;            // Candle Up Color:
input color  CandleDnClr = clrRed;             // Candle Down Color:

string T1                    = "== Notifications =="; // ————————————
bool   notifications         = false;                 // Notifications On?
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications
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

// ------------------------------------------------------------------
int OnInit()
{
    // tomar el color de background del chart
    color backColor = ChartGetInteger(0, CHART_COLOR_BACKGROUND);

    //--- indicator buffers mapping

    // Up Candles:
    SetIndexBuffer(0, _up_high, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 1, CandleUpClr);
    SetIndexBuffer(1, _up_basehigh, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 1, backColor);
    SetIndexBuffer(2, _up_BodyHigh, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, 3, CandleUpClr);
    SetIndexBuffer(3, _up_BodyLow, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, 3, backColor);
    SetIndexBuffer(4, _up_low, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_HISTOGRAM, EMPTY, 1, CandleUpClr);
    SetIndexBuffer(5, _up_baselow, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_HISTOGRAM, EMPTY, 1, backColor);

    // Down Candles:
    SetIndexBuffer(6, _dn_high, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_HISTOGRAM, EMPTY, 1, CandleDnClr);
    SetIndexBuffer(7, _dn_basehigh, INDICATOR_DATA);
    SetIndexStyle(7, DRAW_HISTOGRAM, EMPTY, 1, backColor);
    SetIndexBuffer(8, _dn_BodyHigh, INDICATOR_DATA);
    SetIndexStyle(8, DRAW_HISTOGRAM, EMPTY, 3, CandleDnClr);
    SetIndexBuffer(9, _dn_BodyLow, INDICATOR_DATA);
    SetIndexStyle(9, DRAW_HISTOGRAM, EMPTY, 3, backColor);
    SetIndexBuffer(10, _dn_low, INDICATOR_DATA);
    SetIndexStyle(10, DRAW_HISTOGRAM, EMPTY, 1, CandleDnClr);
    SetIndexBuffer(11, _dn_baselow, INDICATOR_DATA);
    SetIndexStyle(11, DRAW_HISTOGRAM, EMPTY, 1, backColor);

    SetIndexLabel(0, NULL);
    SetIndexLabel(1, NULL);
    SetIndexLabel(2, NULL);
    SetIndexLabel(3, NULL);
    SetIndexLabel(4, NULL);
    SetIndexLabel(5, NULL);
    SetIndexLabel(6, NULL);
    SetIndexLabel(7, NULL);
    SetIndexLabel(8, NULL);
    SetIndexLabel(9, NULL);
    SetIndexLabel(10, NULL);
    SetIndexLabel(11, NULL);

    SetIndexBuffer(12, _open, INDICATOR_DATA);
    SetIndexBuffer(13, _high, INDICATOR_DATA);
    SetIndexBuffer(14, _low, INDICATOR_DATA);
    SetIndexBuffer(15, _close, INDICATOR_DATA);

    SetIndexStyle(12, DRAW_NONE);
    SetIndexStyle(13, DRAW_NONE);
    SetIndexStyle(14, DRAW_NONE);
    SetIndexStyle(15, DRAW_NONE);

    SetIndexLabel(12, "Open");
    SetIndexLabel(13, "High");
    SetIndexLabel(14, "Low");
    SetIndexLabel(15, "Close");

    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

double o, h, l, c;

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    // clang-format off
  if (prev_calculated == 0) { start = rates_total - 1; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    for (i = start; i >= 0; i--) 
    {
        if (prev_calculated == 0)
        {
            // tomar los valores del macd de cada minuto interno de la vela 
            // 
            datetime TM_Left = Time[i+1];
            int           sh = iBarShift(NULL, PERIOD_M1, Time[i]);
            datetime      tm = iTime(NULL, PERIOD_M1, sh);
            
            while (tm > TM_Left)
            {
                c = macd_m1(j);
                if (o == 0) o = c;
                if (h == 0 || c > h) h = c;
                if (l == 0 || c < l) l = c;
            }
            
            
            iTime(NULL, PERIOD_M1, i)

        // vela verde
        if (o < c) {
            _up_BodyHigh[i] = c;
            _up_BodyLow[i]  = o;

            _up_high[i] = h;
            _up_low[i]  = o;

            _up_basehigh[i] = c;
            _up_baselow[i]  = l;
        }

        // vela roja
        if (o > c) {
            _dn_BodyHigh[i] = o;
            _dn_BodyLow[i]  = c;

            _dn_high[i] = h;
            _dn_low[i]  = c;

            _dn_basehigh[i] = o;
            _dn_baselow[i]  = l;
        }

            continue;
        }

        if (newCandle.IsNewCandle()) {
            o = 0;
            h = 0;
            l = 0;
        }

        c = macd(i) +100;
        Print("line: ", __LINE__, "         c: ", c);
        if (o == 0) o = c;
        if (h == 0 || c > h) h = c;
        if (l == 0 || c < l) l = c;

        // vela verde
        if (o < c) {
            _up_BodyHigh[i] = c;
            _up_BodyLow[i]  = o;

            _up_high[i] = h;
            _up_low[i]  = o;

            _up_basehigh[i] = c;
            _up_baselow[i]  = l;
        }

        // vela roja
        if (o > c) {
            _dn_BodyHigh[i] = o;
            _dn_BodyLow[i]  = c;

            _dn_high[i] = h;
            _dn_low[i]  = c;

            _dn_basehigh[i] = o;
            _dn_baselow[i]  = l;
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

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76365
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