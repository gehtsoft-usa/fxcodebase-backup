// -- Project -------------------------------------------------------------------------------
/*
Name:        Swing_Failure_Pattern_LuxAlgo
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76380 
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
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

#property copyright "Copyright (c) 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
input int    SwingLength = 5;           // Swings
input bool   ShowBullishSFP = true;     // Bullish SFP
input bool   ShowBearishSFP = true;     // Bearish SFP
input bool   ShowSwingLines = true;     // Swing Lines
input bool   ShowConfirmationLines = true; // Confirmation Lines
input bool   ShowSFPWick = true;        // Swing Failure Wick
input bool   ShowSFPLabel = true;       // Swing Failure Label
input bool   ShowDebugInfo = false;     // Show Debug Info
input color  BullishColor = clrLimeGreen;  // Bullish Color
input color  BearishColor = clrRed;        // Bearish Color
int sfp_count_bearish = 0;
int sfp_count_bullish = 0;
int pivot_count_high = 0;
int pivot_count_low = 0;
struct SwingData
  {
   int               bar_index;
   double            price;
  };
struct PivotData
  {
   double            swing_price;
   int               swing_bar_index;
   double            opposite_price;
   int               opposite_bar_index;
   bool              active;
   bool              confirmed;
   string            swing_line_name;
   string            opposite_line_name;
   string            wick_line_name;
   string            label_name;
  };
SwingData swingHigh, swingLow;
PivotData pivotHigh, pivotLow;
int max_objects = 500;
int object_counter = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorShortName("Swing Failure Pattern [LuxAlgo]");
   swingHigh.bar_index = -1;
   swingHigh.price = 0;
   swingLow.bar_index = -1;
   swingLow.price = 0;
   pivotHigh.active = false;
   pivotHigh.confirmed = false;
   pivotHigh.swing_bar_index = -1;
   pivotLow.active = false;
   pivotLow.confirmed = false;
   pivotLow.swing_bar_index = -1;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "SFP_");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   if(rates_total < SwingLength * 2 + 2)
      return(0);
   int limit;
   if(prev_calculated == 0)
     {
      limit = rates_total - SwingLength - 2;
      sfp_count_bearish = 0;
      sfp_count_bullish = 0;
      pivot_count_high = 0;
      pivot_count_low = 0;
     }
   else
     {
      limit = MathMin(50, rates_total - SwingLength - 2);
     }
   for(int i = limit; i >= 0; i--)
     {
      double ph = 0, pl = 0;
      if(i + SwingLength + 1 < rates_total)
        {
         ph = FindPivotHigh(high, i + 1, SwingLength);
         pl = FindPivotLow(low, i + 1, SwingLength);
        }
      if(ShowBearishSFP && ph != 0)
        {
         swingHigh.bar_index = i + 1;
         swingHigh.price = ph;
         if(prev_calculated == 0)
            pivot_count_high++;
        }
      if(ShowBearishSFP && swingHigh.bar_index >= 0 && swingHigh.bar_index > i)
        {
         double sw = swingHigh.price;
         int bx = swingHigh.bar_index;
         if(high[i] > sw && open[i] < sw && close[i] < sw)
           {
            double opposL = sw;
            int opposB = i;
            for(int j = bx - 1; j > i; j--)
              {
               if(low[j] < opposL)
                 {
                  opposL = low[j];
                  opposB = j;
                 }
              }
            string suffix = "H_" + IntegerToString(bx) + "_" + IntegerToString(i);
            string swing_name = "SFP_SwingH_" + suffix;
            if(ObjectFind(0, swing_name) < 0)
              {
               if(prev_calculated == 0)
                  sfp_count_bearish++;
               if(ShowSwingLines)
                 {
                  ObjectCreate(0, swing_name, OBJ_TREND, 0,
                               time[bx], sw, time[i], sw);
                  ObjectSetInteger(0, swing_name, OBJPROP_COLOR, BearishColor);
                  ObjectSetInteger(0, swing_name, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, swing_name, OBJPROP_RAY_RIGHT, false);
                  ObjectSetInteger(0, swing_name, OBJPROP_RAY_LEFT, false);
                 }
               if(ShowConfirmationLines)
                 {
                  string oppos_name = "SFP_OpposH_" + suffix;
                  ObjectCreate(0, oppos_name, OBJ_TREND, 0,
                               time[opposB], opposL, time[i], opposL);
                  ObjectSetInteger(0, oppos_name, OBJPROP_COLOR, BearishColor);
                  ObjectSetInteger(0, oppos_name, OBJPROP_STYLE, STYLE_DOT);
                  ObjectSetInteger(0, oppos_name, OBJPROP_RAY_RIGHT, false);
                  ObjectSetInteger(0, oppos_name, OBJPROP_RAY_LEFT, false);
                 }
               if(ShowSFPWick)
                 {
                  string wick_name = "SFP_WickH_" + suffix;
                  ObjectCreate(0, wick_name, OBJ_TREND, 0,
                               time[i], high[i], time[i], sw);
                  ObjectSetInteger(0, wick_name, OBJPROP_COLOR, BearishColor);
                  ObjectSetInteger(0, wick_name, OBJPROP_WIDTH, 3);
                  ObjectSetInteger(0, wick_name, OBJPROP_RAY, false);
                 }
               if(ShowSFPLabel)
                 {
                  string label_name = "SFP_LabelH_" + suffix;
                  ObjectCreate(0, label_name, OBJ_TEXT, 0, time[i], high[i]);
                  ObjectSetString(0, label_name, OBJPROP_TEXT, "SFP");
                  ObjectSetInteger(0, label_name, OBJPROP_COLOR, BearishColor);
                  ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, 8);
                  ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, ANCHOR_LOWER);
                 }
               pivotHigh.swing_price = sw;
               pivotHigh.swing_bar_index = bx;
               pivotHigh.opposite_price = opposL;
               pivotHigh.opposite_bar_index = opposB;
               pivotHigh.swing_line_name = swing_name;
               pivotHigh.opposite_line_name = "SFP_OpposH_" + suffix;
               pivotHigh.active = true;
               pivotHigh.confirmed = false;
              }
           }
        }
      if(i == 0 && pivotHigh.active && !pivotHigh.confirmed)
        {
         if(close[0] < pivotHigh.opposite_price)
           {
            pivotHigh.confirmed = true;
            if(ShowSFPLabel)
              {
               string suffix_conf = StringSubstr(pivotHigh.swing_line_name, 13);
               string label_name = "SFP_LabelH_" + suffix_conf;
               if(ObjectFind(0, label_name) >= 0)
                 {
                  ObjectSetString(0, label_name, OBJPROP_TEXT, "SFP▼");
                 }
              }
           }
         else
           {
            if(ShowSwingLines && ObjectFind(0, pivotHigh.swing_line_name) >= 0)
              {
               ObjectSetInteger(0, pivotHigh.swing_line_name, OBJPROP_TIME, 1, time[0]);
              }
            if(ShowConfirmationLines && ObjectFind(0, pivotHigh.opposite_line_name) >= 0)
              {
               ObjectSetInteger(0, pivotHigh.opposite_line_name, OBJPROP_TIME, 1, time[0]);
              }
           }
        }
      if(ShowBullishSFP && pl != 0)
        {
         swingLow.bar_index = i + 1;
         swingLow.price = pl;
         if(prev_calculated == 0)
            pivot_count_low++;
        }
      if(ShowBullishSFP && swingLow.bar_index >= 0 && swingLow.bar_index > i)
        {
         double sw_low = swingLow.price;
         int bx_low = swingLow.bar_index;
         if(low[i] < sw_low && open[i] > sw_low && close[i] > sw_low)
           {
            double opposH = sw_low;
            int opposB_low = i;
            for(int j = bx_low - 1; j > i; j--)
              {
               if(high[j] > opposH)
                 {
                  opposH = high[j];
                  opposB_low = j;
                 }
              }
            string suffix_low = "L_" + IntegerToString(bx_low) + "_" + IntegerToString(i);
            string swing_name_low = "SFP_SwingL_" + suffix_low;
            if(ObjectFind(0, swing_name_low) < 0)
              {
               if(prev_calculated == 0)
                  sfp_count_bullish++;
               if(ShowSwingLines)
                 {
                  ObjectCreate(0, swing_name_low, OBJ_TREND, 0,
                               time[bx_low], sw_low, time[i], sw_low);
                  ObjectSetInteger(0, swing_name_low, OBJPROP_COLOR, BullishColor);
                  ObjectSetInteger(0, swing_name_low, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, swing_name_low, OBJPROP_RAY_RIGHT, false);
                  ObjectSetInteger(0, swing_name_low, OBJPROP_RAY_LEFT, false);
                 }
               if(ShowConfirmationLines)
                 {
                  string oppos_name_low = "SFP_OpposL_" + suffix_low;
                  ObjectCreate(0, oppos_name_low, OBJ_TREND, 0,
                               time[opposB_low], opposH, time[i], opposH);
                  ObjectSetInteger(0, oppos_name_low, OBJPROP_COLOR, BullishColor);
                  ObjectSetInteger(0, oppos_name_low, OBJPROP_STYLE, STYLE_DOT);
                  ObjectSetInteger(0, oppos_name_low, OBJPROP_RAY_RIGHT, false);
                  ObjectSetInteger(0, oppos_name_low, OBJPROP_RAY_LEFT, false);
                 }
               if(ShowSFPWick)
                 {
                  string wick_name_low = "SFP_WickL_" + suffix_low;
                  ObjectCreate(0, wick_name_low, OBJ_TREND, 0,
                               time[i], low[i], time[i], sw_low);
                  ObjectSetInteger(0, wick_name_low, OBJPROP_COLOR, BullishColor);
                  ObjectSetInteger(0, wick_name_low, OBJPROP_WIDTH, 3);
                  ObjectSetInteger(0, wick_name_low, OBJPROP_RAY, false);
                 }
               if(ShowSFPLabel)
                 {
                  string label_name_low = "SFP_LabelL_" + suffix_low;
                  ObjectCreate(0, label_name_low, OBJ_TEXT, 0, time[i], low[i]);
                  ObjectSetString(0, label_name_low, OBJPROP_TEXT, "SFP");
                  ObjectSetInteger(0, label_name_low, OBJPROP_COLOR, BullishColor);
                  ObjectSetInteger(0, label_name_low, OBJPROP_FONTSIZE, 8);
                  ObjectSetInteger(0, label_name_low, OBJPROP_ANCHOR, ANCHOR_UPPER);
                 }
               pivotLow.swing_price = sw_low;
               pivotLow.swing_bar_index = bx_low;
               pivotLow.opposite_price = opposH;
               pivotLow.opposite_bar_index = opposB_low;
               pivotLow.swing_line_name = swing_name_low;
               pivotLow.opposite_line_name = "SFP_OpposL_" + suffix_low;
               pivotLow.active = true;
               pivotLow.confirmed = false;
              }
           }
        }
      if(i == 0 && pivotLow.active && !pivotLow.confirmed)
        {
         if(close[0] > pivotLow.opposite_price)
           {
            pivotLow.confirmed = true;
            if(ShowSFPLabel)
              {
               string suffix_conf_low = StringSubstr(pivotLow.swing_line_name, 13);
               string label_name_low = "SFP_LabelL_" + suffix_conf_low;
               if(ObjectFind(0, label_name_low) >= 0)
                 {
                  ObjectSetString(0, label_name_low, OBJPROP_TEXT, "▲SFP");
                 }
              }
           }
         else
           {
            if(ShowSwingLines && ObjectFind(0, pivotLow.swing_line_name) >= 0)
              {
               ObjectSetInteger(0, pivotLow.swing_line_name, OBJPROP_TIME, 1, time[0]);
              }
            if(ShowConfirmationLines && ObjectFind(0, pivotLow.opposite_line_name) >= 0)
              {
               ObjectSetInteger(0, pivotLow.opposite_line_name, OBJPROP_TIME, 1, time[0]);
              }
           }
        }
     }
   if(ShowDebugInfo)
     {
      string info = StringFormat("Pivots H/L: %d/%d | SFP Bear/Bull: %d/%d",
                                 pivot_count_high, pivot_count_low,
                                 sfp_count_bearish, sfp_count_bullish);
      Comment(info);
     }
   else
     {
      Comment("");
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindPivotHigh(const double &high[], int center, int length)
  {
   if(center < 1 || center + length >= ArraySize(high))
      return 0;
   double center_high = high[center];
   for(int i = center + 1; i <= center + length; i++)
     {
      if(i >= ArraySize(high))
         return 0;
      if(high[i] >= center_high)
         return 0;
     }
   for(int i = center - 1; i >= center - 1 && i >= 0; i--)
     {
      if(high[i] > center_high)
         return 0;
     }
   return center_high;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindPivotLow(const double &low[], int center, int length)
  {
   if(center < 1 || center + length >= ArraySize(low))
      return 0;
   double center_low = low[center];
   for(int i = center + 1; i <= center + length; i++)
     {
      if(i >= ArraySize(low))
         return 0;
      if(low[i] <= center_low)
         return 0;
     }
   for(int i = center - 1; i >= center - 1 && i >= 0; i--)
     {
      if(low[i] < center_low)
         return 0;
     }
   return center_low;
  }
//+------------------------------------------------------------------+
// -- Project -------------------------------------------------------------------------------
/*
Name:        Swing_Failure_Pattern_LuxAlgo
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76380 
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
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