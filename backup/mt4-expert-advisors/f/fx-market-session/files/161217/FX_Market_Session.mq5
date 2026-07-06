/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        FX_Market_Session
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=153412#p153412
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property description "FX Market Sessions indicator - converted from Pine Script"
#property description "Displays trading session boxes with Fibonacci levels and opening ranges"
#define MAX_BARS 500
#define TRANSPARENT clrNONE
const string option_yes = "Yes";
const string option_no = "× No";
const string option_extend1 = "Yes";
const string option_hide = "× Hide";
const string option_border_style1 = "────";
const string option_border_style2 = "- - - - - -";
const string option_border_style3 = "•••••••••";
const string option_chart_x = "× No";
const string option_chart_1 = "Bar color";
const string option_chart_2 = "Candles";
const string option_opr_label1 = "High・Low";
const string option_opr_label2 = "Buy・Sell";
const string option_opr_label_none = "None";
const string option_candle_color1 = "Session color";
const string option_candle_color2 = "Red • Green";
const string option_candle_body = "OC";
const string option_candle_wick = "OHLC";
const string icon_separator = " • ";
color color_text;
struct OHLC
  {
   double            open;
   double            high;
   double            low;
   double            close;
   double            hl;
  };
struct OpeningRange
  {
   double            top;
   double            btm;
   double            avg;
   double            R1, R2, S1, S2;
   int               total_count;
   int               reached_count;
   int               reached_R1_count;
   int               reached_R2_count;
   int               reached_S1_count;
   int               reached_S2_count;
  };
struct State
  {
   string            extend_style;
   bool              show_fibs;
   bool              show_op;
  };
struct SessionData
  {
   string            sess;
   string            tz;
   string            name;
   color             colour;
   double            price_ranges[];
   double            price_range_avg;
   string            boxes[];
   string            lines[];
   string            labels[];
   string            oclines[];
   string            oc_labels[];
   string            opr_boxes[];
   string            opr_lines[];
   string            opr_labels[];
   string            fib[];
   bool              is_extended;
   bool              in_session;
   OHLC              ohlc;
   State             state;
   OpeningRange      op;
  };
SessionData sess1_data, sess2_data, sess3_data, sess4_data;
int session_end_offset;
input int i_history_period = 10;        // History
input bool i_show = true;                 // Show sessions
input bool i_show_sess1 = true;           // Session 1
input string i_sess1_label = "London";    // Session 1 Name
input color i_sess1_color = clrCyan;      // Session 1 Color
input string i_sess1 = "0800-1700";       // Session 1 Time
input bool i_sess1_op = false;            // Session 1 Opening range
input bool i_sess1_fib = false;           // Session 1 Fibonacci levels
input bool i_show_sess2 = true;           // Session 2
input string i_sess2_label = "New York";  // Session 2 Name
input color i_sess2_color = clrOrange;    // Session 2 Color
input string i_sess2 = "1300-2200";       // Session 2 Time
input bool i_sess2_op = false;            // Session 2 Opening range
input bool i_sess2_fib = false;           // Session 2 Fibonacci levels
input bool i_show_sess3 = true;           // Session 3
input string i_sess3_label = "Tokyo";     // Session 3 Name
input color i_sess3_color = clrMagenta;   // Session 3 Color
input string i_sess3 = "0000-0900";       // Session 3 Time
input bool i_sess3_op = false;            // Session 3 Opening range
input bool i_sess3_fib = false;           // Session 3 Fibonacci levels
input bool i_show_sess4 = false;          // Session 4
input string i_sess4_label = "Sydney";    // Session 4 Name
input color i_sess4_color = clrPink;      // Session 4 Color
input string i_sess4 = "2000-0500";       // Session 4 Time
input bool i_sess4_op = false;            // Session 4 Opening range
input bool i_sess4_fib = false;           // Session 4 Fibonacci levels
input int i_sess_border_width = 1;        // Border width
input bool i_label_show = true;           // Show labels
input bool i_label_format_name = true;    // Label: Name
input bool i_label_format_price = false;  // Label: Price
input int i_o_minutes = 15;               // Opening range minutes
input bool i_f_show = true;               // Show Fibonacci
input int i_f_linewidth = 1;              // Fibonacci line width
input bool i_show_info = true;            // Show information table
input int i_info_period = 50;             // Information table period
input string i_info_value_type = "Pips";  // Information value type (Price/Pips)
input int i_info_font_size = 10;          // Information table font size
input color i_info_text_color = clrWhite; // Information table text color
input color i_info_bg_color = clrDarkSlateGray; // Information table background color

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ParseSessionTime(string sess_str, int &start_hour, int &start_min, int &end_hour, int &end_min)
  {
   string parts[];
   if(StringSplit(sess_str, '-', parts) == 2)
     {
      start_hour = (int)StringToInteger(StringSubstr(parts[0], 0, 2));
      start_min = (int)StringToInteger(StringSubstr(parts[0], 2, 2));
      end_hour = (int)StringToInteger(StringSubstr(parts[1], 0, 2));
      end_min = (int)StringToInteger(StringSubstr(parts[1], 2, 2));
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsInSession(datetime check_time, string sess_str)
  {
   int start_h, start_m, end_h, end_m;
   ParseSessionTime(sess_str, start_h, start_m, end_h, end_m);
   MqlDateTime dt;
   TimeToStruct(check_time, dt);
   int current_minutes = dt.hour * 60 + dt.min;
   int start_minutes = start_h * 60 + start_m;
   int end_minutes = end_h * 60 + end_m;
   if(end_minutes < start_minutes)
     {
      return (current_minutes >= start_minutes || current_minutes < end_minutes);
     }
   else
     {
      return (current_minutes >= start_minutes && current_minutes < end_minutes);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SessionStarted(int bar, const datetime &time[], string sess_str)
  {
   if(bar >= Bars(_Symbol, PERIOD_CURRENT) - 1)
      return false;
   bool current_in = IsInSession(time[bar], sess_str);
   bool prev_in = IsInSession(time[bar + 1], sess_str);
   return (current_in && !prev_in);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SessionEnded(int bar, const datetime &time[], string sess_str)
  {
   if(bar >= Bars(_Symbol, PERIOD_CURRENT) - 1)
      return false;
   bool current_in = IsInSession(time[bar], sess_str);
   bool prev_in = IsInSession(time[bar + 1], sess_str);
   return (!current_in && prev_in);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindHighest(int start_bar, int end_bar, const double &high[])
  {
   ArraySetAsSeries(high, true);
   double max_val = high[start_bar];
   for(int i = start_bar; i <= end_bar; i++)
     {
      if(high[i] > max_val)
         max_val = high[i];
     }
   return max_val;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindLowest(int start_bar, int end_bar, const double &low[])
  {
   ArraySetAsSeries(low, true);
   double min_val = low[start_bar];
   for(int i = start_bar; i <= end_bar; i++)
     {
      if(low[i] < min_val)
         min_val = low[i];
     }
   return min_val;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetObjectName(string prefix, int session_num, int obj_num)
  {
   return StringFormat("%s_S%d_O%d", prefix, session_num, obj_num);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearOldObjects(string &obj_names[], int keep_count)
  {
   int size = ArraySize(obj_names);
   for(int i = size - 1; i >= keep_count; i--)
     {
      if(obj_names[i] != "")
        {
         ObjectDelete(0, obj_names[i]);
        }
     }
   if(keep_count < size)
      ArrayResize(obj_names, keep_count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPriceRange(SessionData &data, double range_price, int max_length = 50)
  {
   int size = ArraySize(data.price_ranges);
   ArrayResize(data.price_ranges, size + 1);
   for(int i = size; i > 0; i--)
     {
      data.price_ranges[i] = data.price_ranges[i - 1];
     }
   data.price_ranges[0] = range_price;
   if(ArraySize(data.price_ranges) > max_length)
      ArrayResize(data.price_ranges, max_length);
   double sum = 0;
   int count = ArraySize(data.price_ranges);
   for(int i = 0; i < count; i++)
      sum += data.price_ranges[i];
   data.price_range_avg = (count > 0) ? sum / count : 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenderSessionBox(SessionData &data, int session_num, int start_bar, int end_bar,
                      double top, double bottom, const datetime &time[], bool is_started, bool is_ended)
  {
   if(!i_show)
      return;
   string obj_name = GetObjectName("SessionBox", session_num, 0);
   if(is_started)
     {
      int size = ArraySize(data.boxes);
      ArrayResize(data.boxes, size + 1);
      data.boxes[size] = obj_name;
      ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0, time[start_bar], top, time[end_bar], bottom);
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, data.colour);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, i_sess_border_width);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
      ObjectSetInteger(0, obj_name, OBJPROP_FILL, true);
      color bg_color = data.colour;
      ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, bg_color);
      ClearOldObjects(data.boxes, i_history_period);
     }
   else
      if(is_ended)
        {
         if(ObjectFind(0, obj_name) >= 0)
           {
            ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, time[end_bar - session_end_offset]);
           }
        }
      else
        {
         if(ObjectFind(0, obj_name) >= 0)
           {
            ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 0, top);
            ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 1, bottom);
            ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, time[end_bar]);
           }
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenderLabel(SessionData &data, int session_num, int bar_idx, double top, double bottom,
                 const datetime &time[], bool is_started)
  {
   if(!i_label_show || !i_show)
      return;
   string obj_name = GetObjectName("SessionLabel", session_num, 0);
   if(is_started)
     {
      string label_text = "";
      if(i_label_format_name && data.name != "")
         label_text += data.name;
      if(i_label_format_price)
        {
         if(label_text != "")
            label_text += icon_separator;
         label_text += DoubleToString(top - bottom, _Digits);
        }
      int size = ArraySize(data.labels);
      ArrayResize(data.labels, size + 1);
      data.labels[size] = obj_name;
      ObjectCreate(0, obj_name, OBJ_TEXT, 0, time[bar_idx], top);
      ObjectSetString(0, obj_name, OBJPROP_TEXT, label_text);
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, data.colour);
      ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ClearOldObjects(data.labels, i_history_period);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenderFibonacci(SessionData &data, int session_num, int fib_num, int start_bar, int end_bar,
                     double top, double bottom, double level, const datetime &time[],
                     bool is_started, bool is_ended)
  {
   if(!i_f_show)
      return;
   if(!data.state.show_fibs)
      return;
   string obj_name = GetObjectName("Fib", session_num, fib_num);
   double price = (top - bottom) * level + bottom;
   if(is_started)
     {
      int size = ArraySize(data.fib);
      ArrayResize(data.fib, size + 1);
      data.fib[size] = obj_name;
      ObjectCreate(0, obj_name, OBJ_TREND, 0, time[start_bar], price, time[end_bar], price);
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, data.colour);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, i_f_linewidth);
      ObjectSetInteger(0, obj_name, OBJPROP_RAY_RIGHT, data.is_extended);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
      ClearOldObjects(data.fib, i_history_period * 3);
     }
   else
      if(is_ended)
        {
         if(ObjectFind(0, obj_name) >= 0)
           {
            ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, time[end_bar - session_end_offset]);
            ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 1, price);
           }
        }
      else
        {
         if(ObjectFind(0, obj_name) >= 0)
           {
            ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 0, price);
            ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 1, price);
            ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, time[end_bar]);
           }
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenderOpeningRange(SessionData &data, int session_num, int start_bar, int end_bar,
                        const datetime &time[], const double &high[], const double &low[],
                        bool is_started, bool is_ended)
  {
   if(!data.state.show_op)
      return;
   static double saved_top = 0;
   static double saved_btm = 0;
   if(is_started)
     {
      saved_top = 0;
      saved_btm = 0;
     }
   else
      if(!is_ended)
        {
         int minutes_passed = (int)((time[start_bar] - time[end_bar]) / 60);
         if(minutes_passed <= i_o_minutes && minutes_passed > 0)
           {
            saved_top = FindHighest(start_bar, end_bar, high);
            saved_btm = FindLowest(start_bar, end_bar, low);
            string box_name = GetObjectName("OPRBox", session_num, 0);
            if(ObjectFind(0, box_name) < 0)
              {
               ObjectCreate(0, box_name, OBJ_RECTANGLE, 0, time[start_bar], saved_top, time[end_bar], saved_btm);
               ObjectSetInteger(0, box_name, OBJPROP_COLOR, data.colour);
               ObjectSetInteger(0, box_name, OBJPROP_STYLE, STYLE_DOT);
               ObjectSetInteger(0, box_name, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, box_name, OBJPROP_BACK, true);
               ObjectSetInteger(0, box_name, OBJPROP_FILL, false);
              }
            else
              {
               ObjectSetDouble(0, box_name, OBJPROP_PRICE, 0, saved_top);
               ObjectSetDouble(0, box_name, OBJPROP_PRICE, 1, saved_btm);
               ObjectSetInteger(0, box_name, OBJPROP_TIME, 1, time[end_bar]);
              }
           }
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSession(SessionData &data, int session_num, string sess_str, bool show_fib, bool show_op,
                 const datetime &time[], const double &high[], const double &low[],
                 const double &open[], const double &close[])
  {
   if(!i_show)
      return;
   int bars_total = Bars(_Symbol, PERIOD_CURRENT);
   if(bars_total < 2)
      return;
   int sessions_drawn = 0;
   int i = 0;
   while(i < MathMin(bars_total - 1, MAX_BARS) && sessions_drawn < i_history_period + 1)
     {
      if(!IsInSession(time[i], sess_str))
        {
         i++;
         continue;
        }
      int sess_start = i;
      int sess_end = i;
      while(i < MathMin(bars_total - 1, MAX_BARS) && IsInSession(time[i], sess_str))
        {
         sess_end = i;
         i++;
        }
      double sess_high = high[sess_start];
      double sess_low = low[sess_start];
      for(int j = sess_start; j <= sess_end; j++)
        {
         if(high[j] > sess_high)
            sess_high = high[j];
         if(low[j] < sess_low)
            sess_low = low[j];
        }
      double sess_range = sess_high - sess_low;
      data.ohlc.high = sess_high;
      data.ohlc.low = sess_low;
      data.ohlc.hl = sess_range;
      data.in_session = (sess_start == 0);
      if(sess_start > 0 || !data.in_session)
        {
         int range_size = ArraySize(data.price_ranges);
         if(range_size >= i_info_period)
           {
            ArrayResize(data.price_ranges, i_info_period);
            for(int k = i_info_period - 1; k > 0; k--)
               data.price_ranges[k] = data.price_ranges[k - 1];
            data.price_ranges[0] = sess_range;
           }
         else
           {
            ArrayResize(data.price_ranges, range_size + 1);
            data.price_ranges[range_size] = sess_range;
           }
         double sum = 0;
         for(int k = 0; k < ArraySize(data.price_ranges); k++)
            sum += data.price_ranges[k];
         data.price_range_avg = sum / ArraySize(data.price_ranges);
        }
      string box_name = StringFormat("SessBox_S%d_T%d", session_num, (int)time[sess_end]);
      bool is_live = (sess_start == 0);
      if(ObjectFind(0, box_name) < 0)
        {
         ObjectCreate(0, box_name, OBJ_RECTANGLE, 0,
                      time[sess_end], sess_high,
                      time[sess_start], sess_low);
         ObjectSetInteger(0, box_name, OBJPROP_COLOR, data.colour);
         ObjectSetInteger(0, box_name, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, box_name, OBJPROP_WIDTH, i_sess_border_width);
         ObjectSetInteger(0, box_name, OBJPROP_BACK, true);
         ObjectSetInteger(0, box_name, OBJPROP_FILL, true);
         ObjectSetInteger(0, box_name, OBJPROP_BGCOLOR, data.colour);
        }
      else
         if(is_live)
           {
            ObjectSetInteger(0, box_name, OBJPROP_TIME, 0, time[sess_end]);
            ObjectSetDouble(0, box_name, OBJPROP_PRICE, 0, sess_high);
            ObjectSetInteger(0, box_name, OBJPROP_TIME, 1, time[sess_start]);
            ObjectSetDouble(0, box_name, OBJPROP_PRICE, 1, sess_low);
           }
      if(i_label_show && i_label_format_name)
        {
         string label_name = StringFormat("SessLabel_S%d_T%d", session_num, (int)time[sess_end]);
         if(ObjectFind(0, label_name) < 0)
           {
            ObjectCreate(0, label_name, OBJ_TEXT, 0, time[sess_start], sess_high);
            ObjectSetString(0, label_name, OBJPROP_TEXT, data.name);
            ObjectSetInteger(0, label_name, OBJPROP_COLOR, data.colour);
            ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, 8);
            ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, label_name, OBJPROP_BACK, false);
           }
         else
            if(is_live)
              {
               ObjectSetDouble(0, label_name, OBJPROP_PRICE, 0, sess_high);
              }
        }
      if(show_fib && i_f_show && (sess_high - sess_low) > 0)
        {
         double levels[] = {0.382, 0.500, 0.618};
         for(int lv = 0; lv < 3; lv++)
           {
            double fib_price = sess_low + (sess_high - sess_low) * levels[lv];
            string fib_name = StringFormat("SessFib_S%d_L%d_T%d", session_num, lv, (int)time[sess_end]);
            if(ObjectFind(0, fib_name) < 0)
              {
               ObjectCreate(0, fib_name, OBJ_TREND, 0,
                            time[sess_end], fib_price,
                            time[sess_start], fib_price);
               ObjectSetInteger(0, fib_name, OBJPROP_COLOR, data.colour);
               ObjectSetInteger(0, fib_name, OBJPROP_STYLE, STYLE_DOT);
               ObjectSetInteger(0, fib_name, OBJPROP_WIDTH, i_f_linewidth);
               ObjectSetInteger(0, fib_name, OBJPROP_BACK, true);
               ObjectSetInteger(0, fib_name, OBJPROP_RAY_RIGHT, false);
              }
            else
               if(is_live)
                 {
                  ObjectSetInteger(0, fib_name, OBJPROP_TIME, 0, time[sess_end]);
                  ObjectSetDouble(0, fib_name, OBJPROP_PRICE, 0, fib_price);
                  ObjectSetInteger(0, fib_name, OBJPROP_TIME, 1, time[sess_start]);
                  ObjectSetDouble(0, fib_name, OBJPROP_PRICE, 1, fib_price);
                 }
           }
        }
      sessions_drawn++;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawInfoTable()
  {
   int active_sessions = 0;
   if(i_show_sess1 && ArraySize(sess1_data.price_ranges) > 0)
      active_sessions++;
   if(i_show_sess2 && ArraySize(sess2_data.price_ranges) > 0)
      active_sessions++;
   if(i_show_sess3 && ArraySize(sess3_data.price_ranges) > 0)
      active_sessions++;
   if(i_show_sess4 && ArraySize(sess4_data.price_ranges) > 0)
      active_sessions++;
   if(active_sessions == 0)
      return;
   int y_offset = 30;
   int x_distance = 15;
   int row_height = 18;
   int total_rows = active_sessions + 1;
   string bg_name = "InfoTable_BG";
   int bg_width = 320;
   int bg_height = total_rows * row_height + 10;
   string header_name = "InfoTable_Header";
   if(ObjectFind(0, header_name) < 0)
     {
      ObjectCreate(0, header_name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, header_name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, header_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, header_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, header_name, OBJPROP_ZORDER, 1);
     }
   ObjectSetInteger(0, header_name, OBJPROP_XDISTANCE, x_distance);
   ObjectSetInteger(0, header_name, OBJPROP_YDISTANCE, y_offset);
   ObjectSetString(0, header_name, OBJPROP_TEXT,
                   StringFormat("Session       • Cur        Avg(%d)      %%", i_info_period));
   ObjectSetInteger(0, header_name, OBJPROP_FONTSIZE, i_info_font_size - 1);
   ObjectSetInteger(0, header_name, OBJPROP_COLOR, clrSilver);
   y_offset = y_offset + row_height;
   int row = 0;
   if(i_show_sess1 && ArraySize(sess1_data.price_ranges) > 0)
     {
      DrawInfoTableRow(sess1_data, 1, x_distance, y_offset);
      y_offset = y_offset + row_height;
      row++;
     }
   if(i_show_sess2 && ArraySize(sess2_data.price_ranges) > 0)
     {
      DrawInfoTableRow(sess2_data, 2, x_distance, y_offset);
      y_offset = y_offset + row_height;
      row++;
     }
   if(i_show_sess3 && ArraySize(sess3_data.price_ranges) > 0)
     {
      DrawInfoTableRow(sess3_data, 3, x_distance, y_offset);
      y_offset = y_offset + row_height;
      row++;
     }
   if(i_show_sess4 && ArraySize(sess4_data.price_ranges) > 0)
     {
      DrawInfoTableRow(sess4_data, 4, x_distance, y_offset);
      y_offset = y_offset + row_height;
      row++;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawInfoTableRow(SessionData &data, int session_num, int x_dist, int y_dist)
  {
   string obj_name = StringFormat("InfoTable_Row%d", session_num);
   double cur_range = data.ohlc.hl;
   double avg_range = data.price_range_avg;
   string cur_val = "";
   string avg_val = "";
   if(i_info_value_type == "Price")
     {
      cur_val = DoubleToString(cur_range, _Digits);
      avg_val = DoubleToString(avg_range, _Digits);
     }
   else
     {
      cur_val = DoubleToString(cur_range / _Point / 10, 1);
      avg_val = DoubleToString(avg_range / _Point / 10, 1);
     }
   double percent = (avg_range > 0) ? (cur_range / avg_range) * 100.0 : 0;
   string pct_val = DoubleToString(percent, 0);
   string name_padded = data.name;
   while(StringLen(name_padded) < 10)
      name_padded = name_padded + " ";
   string indicator = data.in_session ? "◉" : "•";
   string row_text = StringFormat("%s %s %8s %10s %5s%%",
                                  name_padded, indicator, cur_val, avg_val, pct_val);
   if(ObjectFind(0, obj_name) < 0)
     {
      ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, obj_name, OBJPROP_ZORDER, 1);
     }
   ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x_dist);
   ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y_dist);
   ObjectSetString(0, obj_name, OBJPROP_TEXT, row_text);
   ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, i_info_font_size);
   color row_color = i_info_text_color;
   if(data.in_session)
     {
      if(percent < 75)
         row_color = clrLimeGreen;
      else
         if(percent > 125)
            row_color = clrTomato;
         else
            row_color = clrOrange;
     }
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, row_color);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitSessionData(SessionData &data, string sess, string label, color col,
                     bool extended, bool fib, bool op)
  {
   data.sess = sess;
   data.name = label;
   data.colour = col;
   data.is_extended = extended;
   data.state.extend_style = extended ? option_extend1 : option_no;
   data.state.show_fibs = fib;
   data.state.show_op = op;
   data.in_session = false;
   data.price_range_avg = 0;
   data.ohlc.open = 0;
   data.ohlc.high = 0;
   data.ohlc.low = 0;
   data.ohlc.close = 0;
   data.ohlc.hl = 0;
   data.op.total_count = 0;
   data.op.reached_count = 0;
   data.op.reached_R1_count = 0;
   data.op.reached_R2_count = 0;
   data.op.reached_S1_count = 0;
   data.op.reached_S2_count = 0;
   ArrayResize(data.price_ranges, 0);
   ArrayResize(data.boxes, 0);
   ArrayResize(data.lines, 0);
   ArrayResize(data.labels, 0);
   ArrayResize(data.oclines, 0);
   ArrayResize(data.oc_labels, 0);
   ArrayResize(data.opr_boxes, 0);
   ArrayResize(data.opr_lines, 0);
   ArrayResize(data.opr_labels, 0);
   ArrayResize(data.fib, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllSessionObjects(SessionData &data)
  {
   ClearOldObjects(data.boxes, 0);
   ClearOldObjects(data.lines, 0);
   ClearOldObjects(data.labels, 0);
   ClearOldObjects(data.oclines, 0);
   ClearOldObjects(data.oc_labels, 0);
   ClearOldObjects(data.opr_boxes, 0);
   ClearOldObjects(data.opr_lines, 0);
   ClearOldObjects(data.opr_labels, 0);
   ClearOldObjects(data.fib, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   color_text = clrWhite;
   session_end_offset = 0;
   InitSessionData(sess1_data, i_sess1, i_sess1_label, i_sess1_color, false, i_sess1_fib, i_sess1_op);
   InitSessionData(sess2_data, i_sess2, i_sess2_label, i_sess2_color, false, i_sess2_fib, i_sess2_op);
   InitSessionData(sess3_data, i_sess3, i_sess3_label, i_sess3_color, false, i_sess3_fib, i_sess3_op);
   InitSessionData(sess4_data, i_sess4, i_sess4_label, i_sess4_color, false, i_sess4_fib, i_sess4_op);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllSessionObjects(sess1_data);
   DeleteAllSessionObjects(sess2_data);
   DeleteAllSessionObjects(sess3_data);
   DeleteAllSessionObjects(sess4_data);
   ChartRedraw();
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
   if(rates_total < 2)
      return 0;
   static datetime last_bar_time = 0;
   ArraySetAsSeries(time, true);
   last_bar_time = time[0];
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   if(i_show_sess1)
      DrawSession(sess1_data, 1, i_sess1, i_sess1_fib, i_sess1_op, time, high, low, open, close);
   if(i_show_sess2)
      DrawSession(sess2_data, 2, i_sess2, i_sess2_fib, i_sess2_op, time, high, low, open, close);
   if(i_show_sess3)
      DrawSession(sess3_data, 3, i_sess3, i_sess3_fib, i_sess3_op, time, high, low, open, close);
   if(i_show_sess4)
      DrawSession(sess4_data, 4, i_sess4, i_sess4_fib, i_sess4_op, time, high, low, open, close);
   if(i_show_info)
      DrawInfoTable();
   return rates_total;
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        FX_Market_Session
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=153412#p153412
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
