//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76330
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
#property indicator_buffers 5
#property indicator_color1 Black

//---- indicator parameters
int InpDepth     = 6; // Depth
int InpDeviation = 5; // Deviation
int InpBackstep  = 3; // Backstep

input bool pinbarOn   = true; // Control if the candle is PinBar
input int  swingsBack = 5;    // Swing Back to find liquidity
input bool showLines  = true; // Show liquidity line
input int periods = 500; // Candles Back


//---- indicator buffers
double zz_line[];
double swHigh[];
double swLow[];

double Buy[];
double Sell[];
int    nextSide = 1;

//--- globals
int ExtLevel = 3; // recounting's depth of extremums

//+------------------------------------------------------------------+
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "line"); }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    if (InpBackstep >= InpDepth) {
        InpBackstep = InpDepth + 1;
    }

    IndicatorBuffers(5);

    SetIndexStyle(0, DRAW_NONE);
    SetIndexArrow(0, 108);
    SetIndexBuffer(0, zz_line);

    SetIndexBuffer(1, swHigh);
    // SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, Red);
    SetIndexStyle(1, DRAW_NONE, EMPTY, 1, Red);
    SetIndexArrow(1, 234);

    SetIndexBuffer(2, swLow);
    SetIndexArrow(2, 233);
    // SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, Blue);
    SetIndexStyle(2, DRAW_NONE, EMPTY, 1, Blue);
    SetIndexEmptyValue(0, 0.0);

    //---- indicator short name

    IndicatorShortName("Liquidity Sweep(" + string(InpDepth) + "," + string(InpDeviation) + "," + string(InpBackstep) + ")");

    SetIndexBuffer(3, Buy, INDICATOR_DATA);
    SetIndexArrow(3, 233);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, Navy);
    SetIndexBuffer(4, Sell, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, Crimson);
    SetIndexArrow(4, 234);

    //---- initialization done
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
// clang-format off
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    // clang-format on

    int    i, limit, counterZ, whatlookfor = 0;
    int    back, pos, lasthighpos = 0, lastlowpos = 0;
    double extremum;
    double curlow = 0.0, curhigh = 0.0, lasthigh = 0.0, lastlow = 0.0;

    if (rates_total < InpDepth || InpBackstep >= InpDepth) return (0);

    if (prev_calculated == 0)
        limit = InitializeAll();
    else {
        //--- find first extremum in the depth ExtLevel or 100 last bars
        i = counterZ = 0;
        while (counterZ < ExtLevel && i < 100) {
            if (zz_line[i] != 0.0) counterZ++;
            i++;
        }
        //--- no extremum found - recounting all from begin
        if (counterZ == 0)
            limit = InitializeAll();
        else {
            limit = i - 1;
            if (swLow[i] != 0.0) {
                curlow      = swLow[i];
                whatlookfor = 1;
            } else {
                curhigh     = swHigh[i];
                whatlookfor = -1;
            }

            //--- clear the rest data
            for (i = limit - 1; i >= 0; i--) {
                zz_line[i] = 0.0;
                swLow[i]   = 0.0;
                swHigh[i]  = 0.0;
            }
        }
    }
    //--- main loop
    for (i = limit; i >= 0; i--) {
        extremum = low[iLowest(NULL, 0, MODE_LOW, InpDepth, i)];
        if (extremum == lastlow)
            extremum = 0.0;
        else {
            lastlow = extremum;
            if (low[i] - extremum > InpDeviation * Point)
                extremum = 0.0;
            else {
                for (back = 1; back <= InpBackstep; back++) {
                    pos = i + back;
                    if (swLow[pos] != 0 && swLow[pos] > extremum) swLow[pos] = 0.0;
                }
            }
        }
        if (low[i] == extremum)
            swLow[i] = extremum;
        else
            swLow[i] = 0.0;
        extremum = high[iHighest(NULL, 0, MODE_HIGH, InpDepth, i)];
        if (extremum == lasthigh)
            extremum = 0.0;
        else {
            lasthigh = extremum;
            if (extremum - high[i] > InpDeviation * Point)
                extremum = 0.0;
            else {
                for (back = 1; back <= InpBackstep; back++) {
                    pos = i + back;
                    if (swHigh[pos] != 0 && swHigh[pos] < extremum) swHigh[pos] = 0.0;
                }
            }
        }
        if (high[i] == extremum)
            swHigh[i] = extremum;
        else
            swHigh[i] = 0.0;
    }
    if (whatlookfor == 0) {
        lastlow  = 0.0;
        lasthigh = 0.0;
    } else {
        lastlow  = curlow;
        lasthigh = curhigh;
    }
    for (i = limit; i >= 0; i--) {
        switch (whatlookfor) {
        case 0: // look for peak or lawn
            if (lastlow == 0.0 && lasthigh == 0.0) {
                if (swHigh[i] != 0.0) {
                    lasthigh    = High[i];
                    lasthighpos = i;
                    whatlookfor = -1;
                    zz_line[i]  = lasthigh;
                }
                if (swLow[i] != 0.0) {
                    lastlow     = Low[i];
                    lastlowpos  = i;
                    whatlookfor = 1;
                    zz_line[i]  = lastlow;
                }
            }
            break;
        case 1: // look for peak
            if (swLow[i] != 0.0 && swLow[i] < lastlow && swHigh[i] == 0.0) {
                zz_line[lastlowpos] = 0.0;
                lastlowpos          = i;
                lastlow             = swLow[i];
                zz_line[i]          = lastlow;
            }
            if (swHigh[i] != 0.0 && swLow[i] == 0.0) {
                lasthigh    = swHigh[i];
                lasthighpos = i;
                zz_line[i]  = lasthigh;
                whatlookfor = -1;
            }
            break;
        case -1: // look for lawn
            if (swHigh[i] != 0.0 && swHigh[i] > lasthigh && swLow[i] == 0.0) {
                zz_line[lasthighpos] = 0.0;
                lasthighpos          = i;
                lasthigh             = swHigh[i];
                zz_line[i]           = lasthigh;
            }
            if (swLow[i] != 0.0 && swHigh[i] == 0.0) {
                lastlow     = swLow[i];
                lastlowpos  = i;
                zz_line[i]  = lastlow;
                whatlookfor = 1;
            }
            break;
        }
    } // main loop
    
    
    // SELL:
    // . si la ultima vela cierra por debajo de un swingHigh y
    // . llendo para atrás unas 10 velas tengo un zz_line con swingHigh superiores al mismo swHigh detectado antes,
    for (i = periods; i >= 0; i--) {
        int _back = swingsBack;
        // int n = i+1;
        // if (i < periods) {
            for (int n = 1; n < _back; n++) {
                // tengo una vela bajista que cerro abajo de una zwHigh
                int j = zzHighShift(i + 1, n);
                if (close[i + 1] < swHigh[j] && close[i + 1] < open[i + 1]) {
                    // el ultimo zz está por encima
                    int u = zzHighShift(i + 1, 1);
                    if (zz_line[u] > swHigh[j]) {
                        if (pinbarOn == true && isPinbar("dn", u)) {
                            Sell[u] = high[u];
                            if (showLines) drawLine(high[j], j, u, Crimson);
                        } else if (!pinbarOn) {
                            Sell[u] = high[u];
                            if (showLines) drawLine(high[j], j, u, Crimson);
                        }

                        break;
                    }
                }
            }
            for (int n = 1; n < _back; n++) {
                int j = zzLowShift(i + 1, n);
                if (close[i + 1] > swLow[j] && close[i + 1] > open[i + 1]) {
                    // el ultimo zz está por debajo
                    int u = zzLowShift(i + 1, 1);
                    if (zz_line[u] < swLow[j]) {
                        if (pinbarOn == true && isPinbar("up", u)) {
                            Buy[u] = low[u];
                            if (showLines) drawLine(low[j], j, u, Navy);
                        } else if (!pinbarOn) {
                            Buy[u] = low[u];
                            if (showLines) drawLine(low[j], j, u, Navy);
                        }
                        break;
                    }
                }
            }
        }
    
    

    //--- done
    return (rates_total);
}

int InitializeAll()
{
    ArrayInitialize(swHigh, 0.0);
    ArrayInitialize(swLow, 0.0);

    return (Bars - InpDepth);
}

bool notEmpty(double value) { return value != 0 && value != EMPTY_VALUE; }

bool isPinbar(string side, int i)
{
    double o = iOpen(NULL, 0, i);
    double h = iHigh(NULL, 0, i);
    double l = iLow(NULL, 0, i);
    double c = iClose(NULL, 0, i);

    double body      = MathAbs(o - c);
    double candle    = h - l;
    double upperWick = h - MathMax(o, c);
    double lowerWick = MathMin(o, c) - l;

    if (candle == 0) return false;

    double bodyToRange = body / candle;

    if (side == "up") {
        // Pinbar alcista: mecha inferior larga
        if (lowerWick >= body * 2 && bodyToRange < 0.3 && upperWick < lowerWick * 0.5) return true;
    } else if (side == "dn") {
        // Pinbar bajista: mecha superior larga
        if (upperWick >= body * 2 && bodyToRange < 0.3 && lowerWick < upperWick * 0.5) return true;
    }
    return false;
}

int zzHighShift(int i, int find)
{
    int j     = i;
    int count = 0;
    // cuando encuentre el anterior que no está vacío
    while (count < find && j < i+200) {
        if (notEmpty(zz_line[j]) == true && notEmpty(swHigh[j]) == true) {
            count++;
        }
        j++;
    }
    return j - 1;
}
int zzLowShift(int i, int find)
{
    int j     = i;
    int count = 0;
    // cuando encuentre el anterior que no está vacío
    while (count < find && j < i+200) {
        if (notEmpty(zz_line[j]) == true && notEmpty(swLow[j]) == true) {
            count++;
        }
        j++;
    }
    return j - 1;
}

void drawLine(double price, int iniPos, int endPos, color clr)
{
    string name = "line" + (string)iTime(NULL, 0, iniPos);
    ObjectCreate(0, name, OBJ_TREND, 0, iTime(NULL, 0, iniPos), price, iTime(NULL, 0, endPos), price);
    ObjectSet(name, OBJPROP_RAY, false);
    ObjectSet(name, OBJPROP_COLOR, clr);
}
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76330
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