//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160580#p160580
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

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1
//--- plot ZigZag
#property indicator_label1 "ZigZag"
#property indicator_type1  DRAW_SECTION
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

int nrZones     = 20;
int candlesBack = 1000;
bool DrawPatterns = true; // Enable/disable pattern drawing

//--- input parameters
input int InpDepth     = 12; // Depth
input int InpDeviation = 5;  // Deviation
input int InpBackstep  = 3;  // Back Step

input color  TopColorHH    = clrYellow;
input color  TopColorLH    = clrLime;
input color  BotColorHL    = clrRed;
input color  BotColorLL    = clrYellow;
input int    Labeldistance = 2;
input int    TxtSize1      = 7;
input int    TxtSize2      = 6;
input string Fonts         = "Arial Black";
//--- indicator buffers
double ZigZagBuffer[];  // main buffer
double HighMapBuffer[]; // ZigZag high extremes (peaks)
double LowMapBuffer[];  // ZigZag low extremes (bottoms)

int ExtRecalc = 3; // number of last extremes for recalculation

double   Poin, Mut;
int      level    = 3;
bool     firstRun = true;
double   lastlow = 0.0, lasthigh = 0.0;
int      lastlowpos = -1, lasthighpos = -1;
int      whatlookfor     = 0;
datetime lastTime        = 0;
int      lastZigzagIndex = -1;
double   lastZigzagValue = 0.0;

enum EnSearchMode {
    Extremum = 0, // searching for the first extremum
    Peak     = 1, // searching for the next ZigZag peak
    Bottom   = -1 // searching for the next ZigZag bottom
};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ZigZagBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, HighMapBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(2, LowMapBuffer, INDICATOR_CALCULATIONS);
    //--- set short name and digits
    string short_name = StringFormat("ZigZag(%d,%d,%d)", InpDepth, InpDeviation, InpBackstep);
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    //--- set an empty value
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { 
   ObjectsDeleteAll(0, "ZZ_Label"); 
   ObjectsDeleteAll(0, prefix); 
}
//+------------------------------------------------------------------+
//| ZigZag calculation                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (rates_total < 100) return (0);

    // Initialize variables
    Poin = _Point;
    Mut  = Labeldistance;

    // Delete old labels at the beginning of calculation
    if (prev_calculated == 0) {
        ObjectsDeleteAll(0, "ZZ_Label");
    }

    //---
    int    i     = 0;
    int    start = 0, extreme_counter = 0, extreme_search = Extremum;
    int    shift = 0, back = 0, last_high_pos = 0, last_low_pos = 0;
    double val = 0, res = 0;
    double curlow = 0, curhigh = 0, last_high = 0, last_low = 0;

    //--- initializing
    if (prev_calculated == 0) {
        ArrayInitialize(ZigZagBuffer, 0.0);
        ArrayInitialize(HighMapBuffer, 0.0);
        ArrayInitialize(LowMapBuffer, 0.0);
        start = InpDepth;
    }

    //--- ZigZag was already calculated before
    if (prev_calculated > 0) {
        i = rates_total - 1;
        //--- searching for the third extremum from the last uncompleted bar
        while (extreme_counter < ExtRecalc && i > rates_total - 100) {
            res = ZigZagBuffer[i];
            if (res != 0.0) extreme_counter++;
            i--;
        }
        i++;
        start = i;

        //--- what type of exremum we search for
        if (LowMapBuffer[i] != 0.0) {
            curlow         = LowMapBuffer[i];
            extreme_search = Peak;
        } else {
            curhigh        = HighMapBuffer[i];
            extreme_search = Bottom;
        }
        //--- clear indicator values
        for (i = start + 1; i < rates_total && !IsStopped(); i++) {
            ZigZagBuffer[i]  = 0.0;
            LowMapBuffer[i]  = 0.0;
            HighMapBuffer[i] = 0.0;
        }
    }

    //--- searching for high and low extremes
    for (shift = start; shift < rates_total && !IsStopped(); shift++) {
        //--- low
        val = low[Lowest(low, InpDepth, shift)];
        if (val == last_low)
            val = 0.0;
        else {
            last_low = val;
            if ((low[shift] - val) > InpDeviation * _Point)
                val = 0.0;
            else {
                for (back = 1; back <= InpBackstep; back++) {
                    res = LowMapBuffer[shift - back];
                    if ((res != 0) && (res > val)) LowMapBuffer[shift - back] = 0.0;
                }
            }
        }
        if (low[shift] == val)
            LowMapBuffer[shift] = val;
        else
            LowMapBuffer[shift] = 0.0;
        //--- high
        val = high[Highest(high, InpDepth, shift)];
        if (val == last_high)
            val = 0.0;
        else {
            last_high = val;
            if ((val - high[shift]) > InpDeviation * _Point)
                val = 0.0;
            else {
                for (back = 1; back <= InpBackstep; back++) {
                    res = HighMapBuffer[shift - back];
                    if ((res != 0) && (res < val)) HighMapBuffer[shift - back] = 0.0;
                }
            }
        }
        if (high[shift] == val)
            HighMapBuffer[shift] = val;
        else
            HighMapBuffer[shift] = 0.0;
    }

    //--- set last values
    if (extreme_search == 0) // undefined values
    {
        last_low  = 0.0;
        last_high = 0.0;
    } else {
        last_low  = curlow;
        last_high = curhigh;
    }

    //--- final selection of extreme points for ZigZag
    for (shift = start; shift < rates_total && !IsStopped(); shift++) {
        res = 0.0;
        switch (extreme_search) {
        case Extremum:
            if (last_low == 0.0 && last_high == 0.0) {
                if (HighMapBuffer[shift] != 0) {
                    last_high           = high[shift];
                    last_high_pos       = shift;
                    extreme_search      = Bottom;
                    ZigZagBuffer[shift] = last_high;
                    res                 = 1;
                }
                if (LowMapBuffer[shift] != 0.0) {
                    last_low            = low[shift];
                    last_low_pos        = shift;
                    extreme_search      = Peak;
                    ZigZagBuffer[shift] = last_low;
                    res                 = 1;
                }
            }
            break;
        case Peak:
            if (LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < last_low && HighMapBuffer[shift] == 0.0) {
                ZigZagBuffer[last_low_pos] = 0.0;
                last_low_pos               = shift;
                last_low                   = LowMapBuffer[shift];
                ZigZagBuffer[shift]        = last_low;
                res                        = 1;
            }
            if (HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0) {
                last_high           = HighMapBuffer[shift];
                last_high_pos       = shift;
                ZigZagBuffer[shift] = last_high;
                extreme_search      = Bottom;
                res                 = 1;
            }
            break;
        case Bottom:
            if (HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > last_high && LowMapBuffer[shift] == 0.0) {
                ZigZagBuffer[last_high_pos] = 0.0;
                last_high_pos               = shift;
                last_high                   = HighMapBuffer[shift];
                ZigZagBuffer[shift]         = last_high;
                res                         = 1;
            }
            if (LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0) {
                last_low            = LowMapBuffer[shift];
                last_low_pos        = shift;
                ZigZagBuffer[shift] = last_low;
                extreme_search      = Peak;
                res                 = 1;
            }
            break;
        default:
            return (rates_total);
        }
    }

    // Draw labels after full calculation
    for (i = start; i < rates_total; i++) {
        if (ZigZagBuffer[i] != 0.0) {
            if (HighMapBuffer[i] != 0.0) {
                DrawHighLabel(i, time, high, low);
            } else if (LowMapBuffer[i] != 0.0) {
                DrawLowLabel(i, time, high, low);
            }
        }
    }

    if(DrawPatterns)
    {
       GetLabels(time, ZigZagBuffer);
       FindAndMarkPattern_LL_HH_HL();
       FindAndMarkPattern_HH_LL_LH();
    }

    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+
//|  Search for the index of the highest bar                         |
//+------------------------------------------------------------------+
int Highest(const double &array[], const int depth, const int start)
{
    if (start < 0) return (0);

    double max   = array[start];
    int    index = start;
    //--- start searching
    for (int i = start - 1; i > start - depth && i >= 0; i--) {
        if (array[i] > max) {
            index = i;
            max   = array[i];
        }
    }
    //--- return index of the highest bar
    return (index);
}
//+------------------------------------------------------------------+
//|  Search for the index of the lowest bar                          |
//+------------------------------------------------------------------+
int Lowest(const double &array[], const int depth, const int start)
{
    if (start < 0) return (0);

    double min   = array[start];
    int    index = start;
    //--- start searching
    for (int i = start - 1; i > start - depth && i >= 0; i--) {
        if (array[i] < min) {
            index = i;
            min   = array[i];
        }
    }
    //--- return index of the lowest bar
    return (index);
}
//+------------------------------------------------------------------+

void DrawHighLabel(int shift, const datetime &time_array[], const double &high_array[], const double &low_array[])
{
    string obj_name = "ZZ_Label" + IntegerToString(time_array[shift]);

    //--- Check if object already exists
    if (ObjectFind(0, obj_name) >= 0) return;

    double position = high_array[shift] + (Mut * Poin);
    string text     = "";
    int    size     = TxtSize1;
    color  clr      = TopColorHH;

    //--- Find previous high
    double previousHigh = 0.0;
    int    found        = -1;
    for (int i = shift - 1; i >= 0; i--) {
        if (HighMapBuffer[i] != 0.0 && ZigZagBuffer[i] != 0.0) {
            previousHigh = high_array[i];
            found        = i;
            break;
        }
    }

    //--- Determine label properties
    if (found >= 0) {
        if (high_array[shift] >= previousHigh) {
            text = "HH";
            clr  = TopColorHH;
            size = TxtSize1;
        } else {
            text = "LH";
            clr  = TopColorLH;
            size = TxtSize2;
        }
    } else {
        // First high point
        text = "HH";
        clr  = TopColorHH;
        size = TxtSize1;
    }

    //--- Create object
    ObjectCreate(0, obj_name, OBJ_TEXT, 0, time_array[shift], position);
    ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, size);
    ObjectSetString(0, obj_name, OBJPROP_FONT, Fonts);
    ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_LOWER);
}

void DrawLowLabel(int shift, const datetime &time_array[], const double &high_array[], const double &low_array[])
{
    string obj_name = "ZZ_Label" + IntegerToString(time_array[shift]);

    //--- Check if object already exists
    if (ObjectFind(0, obj_name) >= 0) return;

    double position = low_array[shift] - (Mut * Poin);
    string text     = "";
    int    size     = TxtSize1;
    color  clr      = BotColorLL;

    //--- Find previous low
    double previousLow = 0.0;
    int    found       = -1;
    for (int i = shift - 1; i >= 0; i--) {
        if (LowMapBuffer[i] != 0.0 && ZigZagBuffer[i] != 0.0) {
            previousLow = low_array[i];
            found       = i;
            break;
        }
    }

    //--- Determine label properties
    if (found >= 0) {
        if (low_array[shift] <= previousLow) {
            text = "LL";
            clr  = BotColorLL;
            size = TxtSize1;
        } else {
            text = "HL";
            clr  = BotColorHL;
            size = TxtSize2;
        }
    } else {
        // First low point
        text = "LL";
        clr  = BotColorLL;
        size = TxtSize1;
    }

    //--- Create object
    ObjectCreate(0, obj_name, OBJ_TEXT, 0, time_array[shift], position);
    ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, size);
    ObjectSetString(0, obj_name, OBJPROP_FONT, Fonts);
    ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_UPPER);
}

struct Pattern {
    string label;
    int    pos;
};
Pattern LabelAndPos[100];

void GetLabels(const datetime &time_array[], const double &ZZBuffer[])
{
    int printed = 0;
    int bars    = ArraySize(ZZBuffer);
    int lb      = 3;

    for (int i = bars - 1; i >= 0 && printed < 100; i--) {
        if (ZZBuffer[i] != 0.0) {
            string obj_name = "ZZ_Label" + IntegerToString(time_array[i]);
            if (ObjectFind(0, obj_name) >= 0) {
                string label_text = ObjectGetString(0, obj_name, OBJPROP_TEXT);

                LabelAndPos[printed].label = label_text;
                LabelAndPos[printed].pos   = i;

                printed++;
            }
        }
    }
}

string prefix = "Pattern_";
void FindAndMarkPattern_LL_HH_HL()
{
    for (int i = 0; i < ArraySize(LabelAndPos) - 2; i++) {
        if (LabelAndPos[i].label == "LL" && LabelAndPos[i + 1].label == "HH" && LabelAndPos[i + 2].label == "HL") {
            string name   = prefix + "LL_HH_HL_" + IntegerToString(i);
            int    bars   = Bars(NULL, 0);
            int    shift1 = bars - LabelAndPos[i].pos - 1;
            int    shift2 = bars - LabelAndPos[i + 1].pos - 1;
            int    shift3 = bars - LabelAndPos[i + 2].pos - 1;

            datetime time1  = iTime(NULL, 0, shift3);
            double   price1 = iHigh(NULL, 0, shift2);
            datetime time2  = iTime(NULL, 0, shift1);
            double   price2 = iLow(NULL, 0, shift1);

            ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
            ObjectSetInteger(0, name, OBJPROP_COLOR, FireBrick);
            ObjectSetInteger(0, name, OBJPROP_FILL, true);
            ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
            ObjectSetInteger(0, name, OBJPROP_BACK, true);
        }
    }
}

void FindAndMarkPattern_HH_LL_LH()
{
    for (int i = 0; i < ArraySize(LabelAndPos) - 2; i++) {
        if (LabelAndPos[i].label == "HH" && LabelAndPos[i + 1].label == "LL" && LabelAndPos[i + 2].label == "LH") {
            string name   =  prefix +"HH_LL_LH_" + IntegerToString(i);
            int    bars   = Bars(NULL, 0);
            int    shift1 = bars - LabelAndPos[i].pos - 1;
            int    shift2 = bars - LabelAndPos[i + 1].pos - 1;
            int    shift3 = bars - LabelAndPos[i + 2].pos - 1;

            datetime time1  = iTime(NULL, 0, shift3);
            double   price1 = iLow(NULL, 0, shift2);
            datetime time2  = iTime(NULL, 0, shift1);
            double   price2 = iHigh(NULL, 0, shift1);

            ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
            ObjectSetInteger(0, name, OBJPROP_COLOR, ForestGreen);
            ObjectSetInteger(0, name, OBJPROP_FILL, true);
            ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
            ObjectSetInteger(0, name, OBJPROP_BACK, true);
        }
    }
}


//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160580#p160580
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