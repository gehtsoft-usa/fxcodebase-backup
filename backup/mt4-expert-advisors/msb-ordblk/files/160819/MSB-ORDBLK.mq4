// -- Project -------------------------------------------------------------------------------
/*
Name:        MSB-ORDBLK
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76362
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

input int zigzag_len = 9;                    // ZigZag Length
input bool show_zigzag = true;               // Show Zigzag
input double fib_factor = 0.33;              // Fib Factor for breakout confirmation
input bool delete_boxes = true;              // Delete Old/Broken Boxes
input int bar_limit = 1000;                  // Max bars to process per calculation (0 = all)
input bool draw_boxes = true;               // Draw rectangle boxes
input color bu_ob_color = C'70,255,70';      // Bu-OB Color
input color bu_ob_border_color = clrGreen;   // Bu-OB Border Color
input color bu_ob_text_color = clrGreen;     // Bu-OB Text Color
input color be_ob_color = C'255,70,70';      // Be-OB Color
input color be_ob_border_color = clrRed;     // Be-OB Border Color
input color be_ob_text_color = clrRed;       // Be-OB Text Color
input color bu_bb_color = C'70,255,70';      // Bu-BB Color
input color bu_bb_border_color = clrGreen;   // Bu-BB Border Color
input color bu_bb_text_color = clrGreen;     // Bu-BB Text Color
input color be_bb_color = C'255,70,70';      // Be-BB Color
input color be_bb_border_color = clrRed;     // Be-BB Border Color
input color be_bb_text_color = clrRed;       // Be-BB Text Color
enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 1;                      // Notifications
input bool   desktop_notifications = true;                  // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications
int trend = 1;
int market = 1;
double last_l0 = 0;
double last_h0 = 0;
double h0, h1, l0, l1;
int h0i, h1i, l0i, l1i;
struct Box
  {
   string            name;
   datetime          time1;
   double            price1;
   datetime          time2;
   double            price2;
   bool              is_bullish;
  };
Box bu_ob_boxes[];
Box be_ob_boxes[];
Box bu_bb_boxes[];
Box be_bb_boxes[];
int h0i_series[];
int h1i_series[];
int l0i_series[];
int l1i_series[];
int bu_ob_index_series[];
int be_ob_index_series[];
int bu_bb_index_series[];
int be_bb_index_series[];
bool alerted_bu_ob;
bool alerted_be_ob;
bool alerted_bu_bb;
bool alerted_be_bb;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(bu_ob_boxes, 0);
   ArrayResize(be_ob_boxes, 0);
   ArrayResize(bu_bb_boxes, 0);
   ArrayResize(be_bb_boxes, 0);
   alerted_bu_ob = false;
   alerted_be_ob = false;
   alerted_bu_bb = false;
   alerted_be_bb = false;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "MSB_");
   ObjectsDeleteAll(0, "BuOB_");
   ObjectsDeleteAll(0, "BeOB_");
   ObjectsDeleteAll(0, "BuBB_");
   ObjectsDeleteAll(0, "BeBB_");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetHighestShift(int start, int count)
  {
   double max_val = High[start];
   int max_shift = start;
   for(int i = start; i < start + count && i < Bars; i++)
     {
      if(High[i] > max_val)
        {
         max_val = High[i];
         max_shift = i;
        }
     }
   return max_shift;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetLowestShift(int start, int count)
  {
   double min_val = Low[start];
   int min_shift = start;
   for(int i = start; i < start + count && i < Bars; i++)
     {
      if(Low[i] < min_val)
        {
         min_val = Low[i];
         min_shift = i;
        }
     }
   return min_shift;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSeriesValue(int &series[], int index, int fallback)
  {
   if(index < 0 || index >= ArraySize(series))
      return fallback;
   int value = series[index];
   if(value < 0)
      return fallback;
   return value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void NormalizeShiftRange(int &start_shift, int &end_shift)
  {
   if(start_shift >= Bars)
      start_shift = Bars - 1;
   if(end_shift >= Bars)
      end_shift = Bars - 1;
   if(start_shift < 0)
      start_shift = 0;
   if(end_shift < 0)
      end_shift = 0;
   if(start_shift < end_shift)
     {
      int tmp = start_shift;
      start_shift = end_shift;
      end_shift = tmp;
     }
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
   if(Bars < zigzag_len + 10)
      return(0);
   int max_bars_to_process = bar_limit;
   if(max_bars_to_process <= 0 || max_bars_to_process > Bars)
      max_bars_to_process = Bars;
   if(max_bars_to_process < zigzag_len + 10)
      max_bars_to_process = zigzag_len + 10;
   int start_shift = max_bars_to_process - 1;
   if(start_shift >= Bars)
      start_shift = Bars - 1;
   trend = 1;
   market = 1;
   last_l0 = 0;
   last_h0 = 0;
   h0 = 0;
   h1 = 0;
   l0 = 0;
   l1 = 0;
   h0i = 0;
   h1i = 0;
   l0i = 0;
   l1i = 0;
   ArrayResize(bu_ob_boxes, 0);
   ArrayResize(be_ob_boxes, 0);
   ArrayResize(bu_bb_boxes, 0);
   ArrayResize(be_bb_boxes, 0);
   ObjectsDeleteAll(0, "MSB_");
   ObjectsDeleteAll(0, "BuOB_");
   ObjectsDeleteAll(0, "BeOB_");
   ObjectsDeleteAll(0, "BuBB_");
   ObjectsDeleteAll(0, "BeBB_");
   int series_size = Bars;
   ArrayResize(h0i_series, series_size);
   ArrayResize(h1i_series, series_size);
   ArrayResize(l0i_series, series_size);
   ArrayResize(l1i_series, series_size);
   ArrayResize(bu_ob_index_series, series_size);
   ArrayResize(be_ob_index_series, series_size);
   ArrayResize(bu_bb_index_series, series_size);
   ArrayResize(be_bb_index_series, series_size);
   ArrayInitialize(h0i_series, -1);
   ArrayInitialize(h1i_series, -1);
   ArrayInitialize(l0i_series, -1);
   ArrayInitialize(l1i_series, -1);
   ArrayInitialize(bu_ob_index_series, -1);
   ArrayInitialize(be_ob_index_series, -1);
   ArrayInitialize(bu_bb_index_series, -1);
   ArrayInitialize(be_bb_index_series, -1);
   if(start_shift < 0)
      start_shift = 0;
   for(int shift = start_shift; shift >= 0; shift--)
     {
      ProcessBar(shift);
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProcessBar(int shift)
  {
   if(shift < 0 || shift >= Bars)
      return;
   int max_count = zigzag_len;
   int remaining_bars = Bars - shift;
   if(remaining_bars < max_count)
      max_count = remaining_bars;
   if(max_count <= 0)
      return;
   int highest_shift = iHighest(NULL, 0, MODE_HIGH, max_count, shift);
   int lowest_shift = iLowest(NULL, 0, MODE_LOW, max_count, shift);
   if(highest_shift < 0 || lowest_shift < 0)
      return;
   int bu_ob_index_shift = GetSeriesValue(bu_ob_index_series, shift + 1, shift);
   int be_ob_index_shift = GetSeriesValue(be_ob_index_series, shift + 1, shift);
   int bu_bb_index_shift = GetSeriesValue(bu_bb_index_series, shift + 1, shift);
   int be_bb_index_shift = GetSeriesValue(be_bb_index_series, shift + 1, shift);
   bool to_up = (High[shift] >= High[highest_shift]);
   bool to_down = (Low[shift] <= Low[lowest_shift]);
   int prev_trend = trend;
   if(trend == 1 && to_down)
      trend = -1;
   else
      if(trend == -1 && to_up)
         trend = 1;
   if(trend != prev_trend)
     {
      if(trend == 1)
        {
         int previous_l0i = l0i;
         double previous_l0 = l0;
         int bars_since_bull = 0;
         int bull_limit = shift + 500;
         if(bull_limit > Bars)
            bull_limit = Bars;
         for(int bull_offset = shift + 2; bull_offset < bull_limit; bull_offset++)
           {
            int count_high = zigzag_len;
            int remaining_high = Bars - bull_offset;
            if(remaining_high < count_high)
               count_high = remaining_high;
            if(count_high <= 0)
               break;
            int ref_high = iHighest(NULL, 0, MODE_HIGH, count_high, bull_offset);
            if(ref_high < 0)
               break;
            if(High[bull_offset] >= High[ref_high])
              {
               bars_since_bull = bull_offset - shift - 1;
               break;
              }
           }
         if(bars_since_bull > 0)
           {
            if(previous_l0i > 0)
              {
               l1 = previous_l0;
               l1i = previous_l0i;
              }
            int low_count = bars_since_bull;
            int remaining_low = Bars - (shift + 1);
            if(remaining_low < low_count)
               low_count = remaining_low;
            if(low_count > 0)
              {
               l0i = iLowest(NULL, 0, MODE_LOW, low_count, shift + 1);
               l0 = Low[l0i];
               if(l1i <= 0)
                 {
                  l1 = l0;
                  l1i = l0i;
                 }
              }
           }
         if(show_zigzag && h0i > 0)
           {
            string zz_name_bull = "MSB_ZZ_" + TimeToString(Time[l0i]);
            if(ObjectFind(0, zz_name_bull) < 0 &&
               ObjectCreate(0, zz_name_bull, OBJ_TREND, 0, Time[h0i], h0, Time[l0i], l0))
              {
               ObjectSetInteger(0, zz_name_bull, OBJPROP_COLOR, clrDodgerBlue);
               ObjectSetInteger(0, zz_name_bull, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, zz_name_bull, OBJPROP_RAY_RIGHT, false);
              }
           }
        }
      if(trend == -1)
        {
         int previous_h0i = h0i;
         double previous_h0 = h0;
         int bars_since_bear = 0;
         int bear_limit = shift + 500;
         if(bear_limit > Bars)
            bear_limit = Bars;
         for(int bear_offset = shift + 2; bear_offset < bear_limit; bear_offset++)
           {
            int count_low = zigzag_len;
            int remaining_low2 = Bars - bear_offset;
            if(remaining_low2 < count_low)
               count_low = remaining_low2;
            if(count_low <= 0)
               break;
            int ref_low = iLowest(NULL, 0, MODE_LOW, count_low, bear_offset);
            if(ref_low < 0)
               break;
            if(Low[bear_offset] <= Low[ref_low])
              {
               bars_since_bear = bear_offset - shift - 1;
               break;
              }
           }
         if(bars_since_bear > 0)
           {
            if(previous_h0i > 0)
              {
               h1 = previous_h0;
               h1i = previous_h0i;
              }
            int high_count = bars_since_bear;
            int remaining_high2 = Bars - (shift + 1);
            if(remaining_high2 < high_count)
               high_count = remaining_high2;
            if(high_count > 0)
              {
               h0i = iHighest(NULL, 0, MODE_HIGH, high_count, shift + 1);
               h0 = High[h0i];
               if(h1i <= 0)
                 {
                  h1 = h0;
                  h1i = h0i;
                 }
              }
           }
         if(show_zigzag && l0i > 0)
           {
            string zz_name_bear = "MSB_ZZ_" + TimeToString(Time[h0i]);
            if(ObjectFind(0, zz_name_bear) < 0 &&
               ObjectCreate(0, zz_name_bear, OBJ_TREND, 0, Time[l0i], l0, Time[h0i], h0))
              {
               ObjectSetInteger(0, zz_name_bear, OBJPROP_COLOR, clrDodgerBlue);
               ObjectSetInteger(0, zz_name_bear, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, zz_name_bear, OBJPROP_RAY_RIGHT, false);
              }
           }
        }
     }
   if(h0i > 0 && h1i > 0 && l0i > 0 && l1i > 0)
     {
      int prev_market = market;
      int l0i_hist = GetSeriesValue(l0i_series, shift + zigzag_len, l0i);
      int h0i_hist = GetSeriesValue(h0i_series, shift + zigzag_len, h0i);
      if(Bars > 0)
        {
         int bu_ob_start = h1i;
         int bu_ob_end = l0i_hist;
         if(bu_ob_start >= 0 && bu_ob_end >= 0)
           {
            NormalizeShiftRange(bu_ob_start, bu_ob_end);
            for(int bu_ob_shift = bu_ob_start; bu_ob_shift >= bu_ob_end; bu_ob_shift--)
              {
               if(Open[bu_ob_shift] > Close[bu_ob_shift])
                  bu_ob_index_shift = bu_ob_shift;
              }
           }
         int be_ob_start = l1i;
         int be_ob_end = h0i_hist;
         if(be_ob_start >= 0 && be_ob_end >= 0)
           {
            NormalizeShiftRange(be_ob_start, be_ob_end);
            for(int be_ob_shift = be_ob_start; be_ob_shift >= be_ob_end; be_ob_shift--)
              {
               if(Open[be_ob_shift] < Close[be_ob_shift])
                  be_ob_index_shift = be_ob_shift;
              }
           }
         int be_bb_start = h1i + zigzag_len;
         int be_bb_end = l1i;
         if(be_bb_start >= Bars)
            be_bb_start = Bars - 1;
         if(be_bb_start >= 0 && be_bb_end >= 0)
           {
            NormalizeShiftRange(be_bb_start, be_bb_end);
            for(int be_bb_shift = be_bb_start; be_bb_shift >= be_bb_end; be_bb_shift--)
              {
               if(Open[be_bb_shift] > Close[be_bb_shift])
                  be_bb_index_shift = be_bb_shift;
              }
           }
         int bu_bb_start = l1i + zigzag_len;
         int bu_bb_end = h1i;
         if(bu_bb_start >= Bars)
            bu_bb_start = Bars - 1;
         if(bu_bb_start >= 0 && bu_bb_end >= 0)
           {
            NormalizeShiftRange(bu_bb_start, bu_bb_end);
            for(int bu_bb_shift = bu_bb_start; bu_bb_shift >= bu_bb_end; bu_bb_shift--)
              {
               if(Open[bu_bb_shift] < Close[bu_bb_shift])
                  bu_bb_index_shift = bu_bb_shift;
              }
           }
        }
      if(!(last_l0 == l0 || last_h0 == h0))
        {
         if(market == 1 && l0 < l1 && l0 < l1 - MathAbs(h0 - l1) * fib_factor)
            market = -1;
         else
            if(market == -1 && h0 > h1 && h0 > h1 + MathAbs(h1 - l0) * fib_factor)
               market = 1;
        }
      if(market != prev_market)
        {
         last_l0 = l0;
         last_h0 = h0;
         if(market == 1)
           {
            string ln1 = "MSB_Line_Bull_" + TimeToString(Time[h0i]) + "_" + TimeToString(Time[h1i]);
            if(ObjectFind(0, ln1) < 0 &&
               ObjectCreate(0, ln1, OBJ_TREND, 0, Time[h1i], h1, Time[h0i], h1))
              {
               ObjectSetInteger(0, ln1, OBJPROP_COLOR, clrGreen);
               ObjectSetInteger(0, ln1, OBJPROP_WIDTH, 2);
               ObjectSetInteger(0, ln1, OBJPROP_RAY_RIGHT, false);
              }
            int mid_bar_bull = (h1i + l0i) / 2;
            if(mid_bar_bull < 0)
               mid_bar_bull = 0;
            if(mid_bar_bull >= Bars)
               mid_bar_bull = Bars - 1;
            string lb1 = "MSB_Label_Bull_" + IntegerToString(mid_bar_bull) + "_" + TimeToString(Time[mid_bar_bull]);
            if(ObjectFind(0, lb1) < 0 &&
               ObjectCreate(0, lb1, OBJ_TEXT, 0, Time[mid_bar_bull], h1))
              {
               ObjectSetString(0, lb1, OBJPROP_TEXT, "MSB");
               ObjectSetInteger(0, lb1, OBJPROP_COLOR, clrGreen);
               ObjectSetInteger(0, lb1, OBJPROP_FONTSIZE, 10);
              }
            if(draw_boxes)
              {
               int bu_ob_bar = (bu_ob_index_shift >= 0 && bu_ob_index_shift < Bars) ? bu_ob_index_shift : -1;
               if(bu_ob_bar >= 0)
                 {
                  string bu_ob_box_name = "BuOB_" + TimeToString(Time[bu_ob_bar]);
                  datetime bu_ob_right_time = Time[shift] + PeriodSeconds() * 10;
                  if(ObjectFind(0, bu_ob_box_name) < 0 &&
                     ObjectCreate(0, bu_ob_box_name, OBJ_RECTANGLE, 0,
                                  Time[bu_ob_bar], High[bu_ob_bar],
                                  bu_ob_right_time, Low[bu_ob_bar]))
                    {
                     ObjectSetInteger(0, bu_ob_box_name, OBJPROP_COLOR, bu_ob_border_color);
                     ObjectSetInteger(0, bu_ob_box_name, OBJPROP_BGCOLOR, bu_ob_color);
                     ObjectSetInteger(0, bu_ob_box_name, OBJPROP_BACK, false);
                     ObjectSetInteger(0, bu_ob_box_name, OBJPROP_WIDTH, 1);
                     ObjectSetInteger(0, bu_ob_box_name, OBJPROP_FILL, true);
                     string bu_ob_txt_name = bu_ob_box_name + "_text";
                     if(ObjectFind(0, bu_ob_txt_name) < 0 &&
                        ObjectCreate(0, bu_ob_txt_name, OBJ_TEXT, 0, bu_ob_right_time, High[bu_ob_bar]))
                       {
                        ObjectSetString(0, bu_ob_txt_name, OBJPROP_TEXT, "Bu-OB");
                        ObjectSetInteger(0, bu_ob_txt_name, OBJPROP_COLOR, bu_ob_text_color);
                        ObjectSetInteger(0, bu_ob_txt_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
                        ObjectSetInteger(0, bu_ob_txt_name, OBJPROP_FONTSIZE, 8);
                       }
                     AddBullishBox(bu_ob_boxes, bu_ob_box_name, Time[bu_ob_bar], bu_ob_right_time, High[bu_ob_bar], Low[bu_ob_bar]);
                    }
                 }
               int bu_bb_bar = (bu_bb_index_shift >= 0 && bu_bb_index_shift < Bars) ? bu_bb_index_shift : -1;
               if(bu_bb_bar >= 0)
                 {
                  string bu_bb_box_name = "BuBB_" + TimeToString(Time[bu_bb_bar]);
                  string bu_bb_label = (l0 < l1) ? "Bu-BB" : "Bu-MB";
                  datetime bu_bb_right_time = Time[shift] + PeriodSeconds() * 10;
                  if(ObjectFind(0, bu_bb_box_name) < 0 &&
                     ObjectCreate(0, bu_bb_box_name, OBJ_RECTANGLE, 0,
                                  Time[bu_bb_bar], High[bu_bb_bar],
                                  bu_bb_right_time, Low[bu_bb_bar]))
                    {
                     ObjectSetInteger(0, bu_bb_box_name, OBJPROP_COLOR, bu_bb_border_color);
                     ObjectSetInteger(0, bu_bb_box_name, OBJPROP_BGCOLOR, bu_bb_color);
                     ObjectSetInteger(0, bu_bb_box_name, OBJPROP_BACK, false);
                     ObjectSetInteger(0, bu_bb_box_name, OBJPROP_WIDTH, 1);
                     ObjectSetInteger(0, bu_bb_box_name, OBJPROP_FILL, true);
                     string bu_bb_txt_name = bu_bb_box_name + "_text";
                     if(ObjectFind(0, bu_bb_txt_name) < 0 &&
                        ObjectCreate(0, bu_bb_txt_name, OBJ_TEXT, 0, bu_bb_right_time, High[bu_bb_bar]))
                       {
                        ObjectSetString(0, bu_bb_txt_name, OBJPROP_TEXT, bu_bb_label);
                        ObjectSetInteger(0, bu_bb_txt_name, OBJPROP_COLOR, bu_bb_text_color);
                        ObjectSetInteger(0, bu_bb_txt_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
                        ObjectSetInteger(0, bu_bb_txt_name, OBJPROP_FONTSIZE, 8);
                       }
                     AddBullishBox(bu_bb_boxes, bu_bb_box_name, Time[bu_bb_bar], bu_bb_right_time, High[bu_bb_bar], Low[bu_bb_bar]);
                    }
                 }
              }
           }
         if(market == -1)
           {
            string ln2 = "MSB_Line_Bear_" + TimeToString(Time[l0i]) + "_" + TimeToString(Time[l1i]);
            if(ObjectFind(0, ln2) < 0 &&
               ObjectCreate(0, ln2, OBJ_TREND, 0, Time[l1i], l1, Time[l0i], l1))
              {
               ObjectSetInteger(0, ln2, OBJPROP_COLOR, clrRed);
               ObjectSetInteger(0, ln2, OBJPROP_WIDTH, 2);
               ObjectSetInteger(0, ln2, OBJPROP_RAY_RIGHT, false);
              }
            int mid_bar_bear = (l1i + h0i) / 2;
            if(mid_bar_bear < 0)
               mid_bar_bear = 0;
            if(mid_bar_bear >= Bars)
               mid_bar_bear = Bars - 1;
            string lb2 = "MSB_Label_Bear_" + IntegerToString(mid_bar_bear) + "_" + TimeToString(Time[mid_bar_bear]);
            if(ObjectFind(0, lb2) < 0 &&
               ObjectCreate(0, lb2, OBJ_TEXT, 0, Time[mid_bar_bear], l1))
              {
               ObjectSetString(0, lb2, OBJPROP_TEXT, "MSB");
               ObjectSetInteger(0, lb2, OBJPROP_COLOR, clrRed);
               ObjectSetInteger(0, lb2, OBJPROP_FONTSIZE, 10);
              }
            if(draw_boxes)
              {
               int be_ob_bar = (be_ob_index_shift >= 0 && be_ob_index_shift < Bars) ? be_ob_index_shift : -1;
               if(be_ob_bar >= 0)
                 {
                  string be_ob_box_name = "BeOB_" + TimeToString(Time[be_ob_bar]);
                  datetime be_ob_right_time = Time[shift] + PeriodSeconds() * 10;
                  if(ObjectFind(0, be_ob_box_name) < 0 &&
                     ObjectCreate(0, be_ob_box_name, OBJ_RECTANGLE, 0,
                                  Time[be_ob_bar], High[be_ob_bar],
                                  be_ob_right_time, Low[be_ob_bar]))
                    {
                     ObjectSetInteger(0, be_ob_box_name, OBJPROP_COLOR, be_ob_border_color);
                     ObjectSetInteger(0, be_ob_box_name, OBJPROP_BGCOLOR, be_ob_color);
                     ObjectSetInteger(0, be_ob_box_name, OBJPROP_BACK, false);
                     ObjectSetInteger(0, be_ob_box_name, OBJPROP_WIDTH, 1);
                     ObjectSetInteger(0, be_ob_box_name, OBJPROP_FILL, true);
                     string be_ob_txt_name = be_ob_box_name + "_text";
                     if(ObjectFind(0, be_ob_txt_name) < 0 &&
                        ObjectCreate(0, be_ob_txt_name, OBJ_TEXT, 0, be_ob_right_time, High[be_ob_bar]))
                       {
                        ObjectSetString(0, be_ob_txt_name, OBJPROP_TEXT, "Be-OB");
                        ObjectSetInteger(0, be_ob_txt_name, OBJPROP_COLOR, be_ob_text_color);
                        ObjectSetInteger(0, be_ob_txt_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
                        ObjectSetInteger(0, be_ob_txt_name, OBJPROP_FONTSIZE, 8);
                       }
                     AddBearishBox(be_ob_boxes, be_ob_box_name, Time[be_ob_bar], be_ob_right_time, High[be_ob_bar], Low[be_ob_bar]);
                    }
                 }
               int be_bb_bar = (be_bb_index_shift >= 0 && be_bb_index_shift < Bars) ? be_bb_index_shift : -1;
               if(be_bb_bar >= 0)
                 {
                  string be_bb_box_name = "BeBB_" + TimeToString(Time[be_bb_bar]);
                  string be_bb_label = (h0 > h1) ? "Be-BB" : "Be-MB";
                  datetime be_bb_right_time = Time[shift] + PeriodSeconds() * 10;
                  if(ObjectFind(0, be_bb_box_name) < 0 &&
                     ObjectCreate(0, be_bb_box_name, OBJ_RECTANGLE, 0,
                                  Time[be_bb_bar], High[be_bb_bar],
                                  be_bb_right_time, Low[be_bb_bar]))
                    {
                     ObjectSetInteger(0, be_bb_box_name, OBJPROP_COLOR, be_bb_border_color);
                     ObjectSetInteger(0, be_bb_box_name, OBJPROP_BGCOLOR, be_bb_color);
                     ObjectSetInteger(0, be_bb_box_name, OBJPROP_BACK, false);
                     ObjectSetInteger(0, be_bb_box_name, OBJPROP_WIDTH, 1);
                     ObjectSetInteger(0, be_bb_box_name, OBJPROP_FILL, true);
                     string be_bb_txt_name = be_bb_box_name + "_text";
                     if(ObjectFind(0, be_bb_txt_name) < 0 &&
                        ObjectCreate(0, be_bb_txt_name, OBJ_TEXT, 0, be_bb_right_time, High[be_bb_bar]))
                       {
                        ObjectSetString(0, be_bb_txt_name, OBJPROP_TEXT, be_bb_label);
                        ObjectSetInteger(0, be_bb_txt_name, OBJPROP_COLOR, be_bb_text_color);
                        ObjectSetInteger(0, be_bb_txt_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
                        ObjectSetInteger(0, be_bb_txt_name, OBJPROP_FONTSIZE, 8);
                       }
                     AddBearishBox(be_bb_boxes, be_bb_box_name, Time[be_bb_bar], be_bb_right_time, High[be_bb_bar], Low[be_bb_bar]);
                    }
                 }
              }
           }
        }
     }
   if(shift >= 0 && shift < ArraySize(h0i_series))
     {
      h0i_series[shift] = h0i;
      h1i_series[shift] = h1i;
      l0i_series[shift] = l0i;
      l1i_series[shift] = l1i;
     }
   if(shift >= 0 && shift < ArraySize(bu_ob_index_series))
     {
      bu_ob_index_series[shift] = bu_ob_index_shift;
      be_ob_index_series[shift] = be_ob_index_shift;
      bu_bb_index_series[shift] = bu_bb_index_shift;
      be_bb_index_series[shift] = be_bb_index_shift;
     }
   if(draw_boxes)
     {
      UpdateBullishBoxesAtShift(bu_ob_boxes, shift);
      UpdateBullishBoxesAtShift(bu_bb_boxes, shift);
      UpdateBearishBoxesAtShift(be_ob_boxes, shift);
      UpdateBearishBoxesAtShift(be_bb_boxes, shift);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddBullishBox(Box &boxes[], string name, datetime left_time, datetime right_time, double high_val, double low_val)
  {
   int size = ArraySize(boxes);
   ArrayResize(boxes, size + 1);
   boxes[size].name = name;
   boxes[size].time1 = left_time;
   boxes[size].time2 = right_time;
   boxes[size].price1 = high_val;
   boxes[size].price2 = low_val;
   boxes[size].is_bullish = true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddBearishBox(Box &boxes[], string name, datetime left_time, datetime right_time, double high_val, double low_val)
  {
   int size = ArraySize(boxes);
   ArrayResize(boxes, size + 1);
   boxes[size].name = name;
   boxes[size].time1 = left_time;
   boxes[size].time2 = right_time;
   boxes[size].price1 = high_val;
   boxes[size].price2 = low_val;
   boxes[size].is_bullish = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveBoxAtIndex(Box &boxes[], int index)
  {
   if(index < 0 || index >= ArraySize(boxes))
      return;
   string base_name = boxes[index].name;
   if(delete_boxes)
     {
      ObjectDelete(0, base_name);
      ObjectDelete(0, base_name + "_text");
     }
   int size = ArraySize(boxes);
   for(int j = index; j < size - 1; j++)
      boxes[j] = boxes[j + 1];
   if(size > 0)
      ArrayResize(boxes, size - 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateBullishBoxesAtShift(Box &boxes[], int shift)
  {
   if(shift < 0 || shift >= Bars)
      return;
   double close_val = Close[shift];
   datetime right_time = Time[shift] + PeriodSeconds() * 10;
   for(int i = ArraySize(boxes) - 1; i >= 0; i--)
     {
      if(ObjectFind(0, boxes[i].name) < 0)
         continue;
      double top = boxes[i].price1;
      double bottom = boxes[i].price2;
      if(close_val < bottom)
        {
         RemoveBoxAtIndex(boxes, i);
         continue;
        }
      ObjectSetInteger(0, boxes[i].name, OBJPROP_TIME, 1, right_time);
      ObjectMove(0, boxes[i].name + "_text", 0, right_time, top);
      boxes[i].time2 = right_time;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateBearishBoxesAtShift(Box &boxes[], int shift)
  {
   if(shift < 0 || shift >= Bars)
      return;
   double close_val = Close[shift];
   datetime right_time = Time[shift] + PeriodSeconds() * 10;
   for(int i = ArraySize(boxes) - 1; i >= 0; i--)
     {
      if(ObjectFind(0, boxes[i].name) < 0)
         continue;
      double top = boxes[i].price1;
      double bottom = boxes[i].price2;
      if(close_val > top)
        {
         RemoveBoxAtIndex(boxes, i);
         continue;
        }
      ObjectSetInteger(0, boxes[i].name, OBJPROP_TIME, 1, right_time);
      ObjectMove(0, boxes[i].name + "_text", 0, right_time, top);
      boxes[i].time2 = right_time;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
     {
      alerted_bu_ob = false;
      alerted_be_ob = false;
      alerted_bu_bb = false;
      alerted_be_bb = false;
     }
   int check_bar = 0;
   if(notificationsOn == 2)
      check_bar = 1;
   if(check_bar >= Bars)
      return;
   double check_price = Close[check_bar];
   if(!alerted_bu_ob || notificationsOn == 2)
     {
      if(IsPriceInZone(check_price, bu_ob_boxes))
        {
         Notify(1);
         alerted_bu_ob = true;
        }
     }
   if(!alerted_be_ob || notificationsOn == 2)
     {
      if(IsPriceInZone(check_price, be_ob_boxes))
        {
         Notify(2);
         alerted_be_ob = true;
        }
     }
   if(!alerted_bu_bb || notificationsOn == 2)
     {
      if(IsPriceInZone(check_price, bu_bb_boxes))
        {
         Notify(3);
         alerted_bu_bb = true;
        }
     }
   if(!alerted_be_bb || notificationsOn == 2)
     {
      if(IsPriceInZone(check_price, be_bb_boxes))
        {
         Notify(4);
         alerted_be_bb = true;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsPriceInZone(double price, Box &boxes[])
  {
   for(int i = 0; i < ArraySize(boxes); i++)
     {
      if(ObjectFind(0, boxes[i].name) < 0)
         continue;
      double top = boxes[i].price1;
      double bottom = boxes[i].price2;
      if(price >= bottom && price <= top)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "MSB-ORDBLK: ";
   switch(type)
     {
      case 1:
         text += "Price in the BU-OB zone - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += "Price in the BE-OB zone - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 3:
         text += "Price in the BU-BB zone - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 4:
         text += "Price in the BE-BB zone - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
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
//+------------------------------------------------------------------+
// -- Project -------------------------------------------------------------------------------
/*
Name:        MSB-ORDBLK
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76362
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