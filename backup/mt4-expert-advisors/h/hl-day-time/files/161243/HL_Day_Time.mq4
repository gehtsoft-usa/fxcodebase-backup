//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76445
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
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Daily Max"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 4
#property indicator_label2 "Daily Min"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 4

//--- indicator buffers
double HistoUp[];
double HistoDn[];

datetime maxHours[];    // Array to store the times of daily highs
datetime minHours[];    // Array to store the times of daily lows
double   maxPercents[24]; // Array to store the percentage of daily highs per hour
double   minPercents[24]; // Array to store the percentage of daily lows per hour

// ------------------------------------------------------------------
string       T1                    = "== Notifications =="; // ————————————
bool         notifications         = false;                 // Notifications On?
bool         desktop_notifications = false;                 // Desktop MT4 Notifications
bool         email_notifications   = false;                 // Email Notifications
bool         push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Lines ==";     // ————————————
input bool   LinesOn               = true;                  // Line On?
input color  LineUpClr             = clrBlue;               // Line Up Color:
input color  LineDnClr             = clrRed;                // Line Down Color:
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
    //--- indicator buffers mapping
    SetIndexBuffer(0, HistoUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 3, LineUpClr);
    SetIndexBuffer(1, HistoDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 3, LineDnClr);
    if (!LinesOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    GetDailyMaxMinHours();
    GetHourlyMaxMinPercentages();
    //---
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - 1;
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    if (newCandle.IsNewCandle()) {
        ArrayInitialize(HistoDn, EMPTY_VALUE);
        ArrayInitialize(HistoUp, EMPTY_VALUE);
    }
    
MqlDateTime  dt;    
TimeToStruct(TimeCurrent()-86400, dt);
dt.hour= 0; dt.min=0; dt.sec=0;
datetime yesterday = StructToTime(dt);

int cero = iBarShift(NULL, PERIOD_H1,  yesterday, false); 
int n = 23;
    for (int j = cero; j > 0 && n >=0; j--, n--) { 
         HistoUp[j] = maxPercents[n];
         HistoDn[j] = -minPercents[n];
    } 
        
    return (rates_total);
}

// ------------------------------------------------------------------

void GetDailyMaxMinHours()
{
    int year = TimeYear(TimeCurrent());
    // inicio del año a las 00:00
    datetime startDay = StringToTime(IntegerToString(year) + ".01.01 00:00");
    // hasta ayer (hora 00:00) inclusive
    datetime endDay = StringToTime(TimeToString(TimeCurrent() - 86400, TIME_DATE) + " 00:00");

    ArrayResize(maxHours, 0);
    ArrayResize(minHours, 0);

    // Recorre día por día usando PERIOD_H1 para buscar max/min por hora
    for(datetime d = startDay; d <= endDay; d += 86400)
    {
        // índice de la primera barra H1 del día (00:00)
        int firstBar = iBarShift(NULL, PERIOD_H1, d, false);
        // índice de la última barra H1 del día (23:00)
        int lastBar  = iBarShift(NULL, PERIOD_H1, d + 23*3600, false);

        if (firstBar == -1 || lastBar == -1) continue;
        if (firstBar < lastBar) continue; // seguridad: esperamos firstBar >= lastBar

        double maxPrice = -DBL_MAX;
        double minPrice =  DBL_MAX;
        datetime maxTime = 0;
        datetime minTime = 0;

        // recorremos desde la barra más antigua del día (firstBar) hacia la más reciente (lastBar)
        for(int i = firstBar; i >= lastBar; i--)
        {
            double h = iHigh(NULL, PERIOD_H1, i);
            double l = iLow(NULL, PERIOD_H1, i);
            datetime t = iTime(NULL, PERIOD_H1, i);

            if (h > maxPrice)
            {
                maxPrice = h;
                maxTime  = t;
            }
            if (l < minPrice)
            {
                minPrice = l;
                minTime  = t;
            }
        }

        // si encontramos valores válidos, los guardamos
        if (maxTime != 0 && minTime != 0)
        {
            int idx = ArraySize(maxHours);
            ArrayResize(maxHours, idx + 1);
            ArrayResize(minHours, idx + 1);
            maxHours[idx] = maxTime;
            minHours[idx] = minTime;
        }
    }
}

void GetHourlyMaxMinPercentages()
{
    int maxCounts[24];
    int minCounts[24];
    ArrayInitialize(maxCounts, 0);
    ArrayInitialize(minCounts, 0);

    int totalDays = ArraySize(maxHours);

    // Contar ocurrencias por hora
    for (int i = 0; i < totalDays; i++) {
        int hourMax = TimeHour(maxHours[i]);
        int hourMin = TimeHour(minHours[i]);
        if (hourMax >= 0 && hourMax < 24) maxCounts[hourMax]++;
        if (hourMin >= 0 && hourMin < 24) minCounts[hourMin]++;
    }

    ArrayResize(maxPercents, 24);
    ArrayResize(minPercents, 24);

    // Calcular porcentajes
    for (int h = 0; h < 24; h++) {
        maxPercents[h] = totalDays > 0 ? (100.0 * maxCounts[h] / totalDays) : 0.0;
        minPercents[h] = totalDays > 0 ? (100.0 * minCounts[h] / totalDays) : 0.0;

    }
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
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76445
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