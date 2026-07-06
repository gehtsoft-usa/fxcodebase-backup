/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        SMC_v2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160947#p160947
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


#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
enum ENUM_MODE { Historical, Present };
enum ENUM_STYLE { Colored, Monochrome };
enum ENUM_STRUCTURE_FILTER { All, BOS, CHoCH };
enum ENUM_LABEL_SIZE { Tiny, Small, Normal };
enum ENUM_OB_FILTER { Atr, Cumulative_Mean_Range };
enum ENUM_LINESTYLE { Solid, Dashed, Dotted };
input ENUM_MODE Mode = Historical; // Mode
input ENUM_STYLE Style = Colored; // Style
input bool ShowTrend = false; // Color Candles
input bool ShowInternals = true; // Show Internal Structure
input ENUM_STRUCTURE_FILTER ShowIBull = All; // Bullish Internal Structure
input color SwingIBullCss = 0x819908; // Internal Bullish Color (Pine: #089981)
input ENUM_STRUCTURE_FILTER ShowIBear = All; // Bearish Internal Structure
input color SwingIBearCss = 0x4536F2; // Internal Bearish Color (Pine: #f23645)
input bool IFilterConfluence = false; // Confluence Filter
input ENUM_LABEL_SIZE InternalStructureSize = Tiny; // Internal Label Size
input bool ShowStructure = true; // Show Swing Structure
input ENUM_STRUCTURE_FILTER ShowBull = All; // Bullish Swing Structure
input color SwingBullCss = 0x819908; // Swing Bullish Color (Pine: #089981)
input ENUM_STRUCTURE_FILTER ShowBear = All; // Bearish Swing Structure
input color SwingBearCss = 0x4536F2; // Swing Bearish Color (Pine: #f23645)
input ENUM_LABEL_SIZE SwingStructureSize = Small; // Swing Label Size
input bool ShowSwings = true; // Show Swing Points
input int SwingHistoryBars = 500; // Max Swing History (bars, 0=all)
input int Length = 50; // Swing Length
input bool ShowHlSwings = true; // Show Strong/Weak High/Low
input bool ShowIob = true; // Internal Order Blocks
input int IobShowLast = 5; // Internal OB Count
input bool ShowOb = false; // Swing Order Blocks
input int ObShowLast = 5; // Swing OB Count
input ENUM_OB_FILTER ObFilter = Atr; // Order Block Filter
input color IBullObCss = 0x80F57931; // Internal Bullish OB (Pine: #3179f5 with 80% transparency)
input color IBearObCss = 0x8080C7F7; // Internal Bearish OB (Pine: #f77c80 with 80% transparency)
input color BullObCss = 0x80CC4818; // Bullish OB (Pine: #1848cc with 80% transparency)
input color BearObCss = 0x803328B2; // Bearish OB (Pine: #b22833 with 80% transparency)
input bool ShowEq = true; // Equal High/Low
input int EqLen = 3; // Bars Confirmation
input double EqThreshold = 0.1; // Threshold
input ENUM_LABEL_SIZE EqSize = Tiny; // Label Size
input bool ShowFvg = false; // Fair Value Gaps
input bool FvgAuto = true; // Auto Threshold
input ENUM_TIMEFRAMES FvgTf = PERIOD_CURRENT; // FVG Timeframe
input color BullFvgCss = 0x4668FF00; // Bullish FVG (Pine: #00ff68 with 70% transparency)
input color BearFvgCss = 0x460800FF; // Bearish FVG (Pine: #ff0008 with 70% transparency)
input int FvgExtend = 1; // Extend FVG
input bool ShowPdhl = false; // Daily High/Low
input ENUM_LINESTYLE PdhlStyle = Solid; // Daily Line Style
input color PdhlCss = 0xF3572E; // Daily Color (Pine: #2157f3)
input bool ShowPwhl = false; // Weekly High/Low
input ENUM_LINESTYLE PwhlStyle = Solid; // Weekly Line Style
input color PwhlCss = 0xF3572E; // Weekly Color (Pine: #2157f3)
input bool ShowPmhl = false; // Monthly High/Low
input ENUM_LINESTYLE PmhlStyle = Solid; // Monthly Line Style
input color PmhlCss = 0xF3572E; // Monthly Color (Pine: #2157f3)
input bool ShowSd = false; // Premium/Discount Zones
input color PremiumCss = 0x4536F2; // Premium Zone (Pine: #f23645)
input color EqCss = 0xBEB5B2; // Equilibrium Zone (Pine: #b2b5be)
input color DiscountCss = clrLimeGreen; // Discount Zone Color
input bool ShowZoneBreakArrows = true; // Show Zone Break Arrows
input int ZoneBreakArrowUpCode = 233; // Zone Break Arrow Up Code
input int ZoneBreakArrowDownCode = 234; // Zone Break Arrow Down Code
input color ZoneBreakArrowUpColor = clrLime; // Zone Break Arrow Up Color
input color ZoneBreakArrowDownColor = clrRed; // Zone Break Arrow Down Color
input int ZoneBreakArrowOffset = 10; // Zone Break Arrow Offset (points)
input int ZoneBreakArrowSize = 3; // Zone Break Arrow Size
input bool ShowTrendBreakArrows = true; // Show Trend Break Arrows
input int TrendBreakArrowUpCode = 233; // Trend Break Arrow Up Code
input int TrendBreakArrowDownCode = 234; // Trend Break Arrow Down Code
input color TrendBreakArrowUpColor = clrAqua; // Trend Break Arrow Up Color
input color TrendBreakArrowDownColor = clrMagenta; // Trend Break Arrow Down Color
input int TrendBreakArrowOffset = 10; // Trend Break Arrow Offset (points)
input int TrendBreakArrowSize = 3; // Trend Break Arrow Size
double ZoneBreakArrowUpBuffer[];
double ZoneBreakArrowDownBuffer[];
double TrendBreakArrowUpBuffer[];
double TrendBreakArrowDownBuffer[];
double atr[];
double cmean_range[];
int atr_handle = INVALID_HANDLE;
int trend = 0, itrend = 0;
double top_y = 0, top_x = 0;
double btm_y = 0, btm_x = 0;
double itop_y = 0, itop_x = 0;
double ibtm_y = 0, ibtm_x = 0;
double trail_up = 0, trail_dn = 0;
int trail_up_x = 0, trail_dn_x = 0;
bool top_cross = true, btm_cross = true;
bool itop_cross = true, ibtm_cross = true;
string txt_top = "", txt_btm = "";
double iob_top[], iob_btm[];
datetime iob_left[];
int iob_type[];
double ob_top[], ob_btm[];
datetime ob_left[];
int ob_type[];
int swingHighBars[];
double swingHighPrices[];
string swingHighLabels[];
int swingHighDetectBars[];
int swingLowBars[];
double swingLowPrices[];
string swingLowLabels[];
int swingLowDetectBars[];
int internalHighBars[];
double internalHighPrices[];
int internalHighDetectBars[];
int internalLowBars[];
double internalLowPrices[];
int internalLowDetectBars[];
string obj_prefix = "SMC_";
int obj_counter = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeKey(datetime value)
  {
   return IntegerToString((int)value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BarIndexToSeriesIndex(int total, int bar_index)
  {
   if(total <= 0)
      return 0;
   int series_index = (total - 1) - bar_index;
   if(series_index < 0)
      series_index = 0;
   else
      if(series_index >= total)
         series_index = total - 1;
   return series_index;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AppendSwingHigh(int pivot_index, int detect_index, double price, string label_text)
  {
   int size = ArraySize(swingHighBars);
   if(size > 0 && swingHighBars[size - 1] == pivot_index && swingHighDetectBars[size - 1] == detect_index)
      return;
   ArrayResize(swingHighBars, size + 1);
   ArrayResize(swingHighPrices, size + 1);
   ArrayResize(swingHighLabels, size + 1);
   ArrayResize(swingHighDetectBars, size + 1);
   swingHighBars[size] = pivot_index;
   swingHighPrices[size] = price;
   swingHighLabels[size] = label_text;
   swingHighDetectBars[size] = detect_index;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AppendSwingLow(int pivot_index, int detect_index, double price, string label_text)
  {
   int size = ArraySize(swingLowBars);
   if(size > 0 && swingLowBars[size - 1] == pivot_index && swingLowDetectBars[size - 1] == detect_index)
      return;
   ArrayResize(swingLowBars, size + 1);
   ArrayResize(swingLowPrices, size + 1);
   ArrayResize(swingLowLabels, size + 1);
   ArrayResize(swingLowDetectBars, size + 1);
   swingLowBars[size] = pivot_index;
   swingLowPrices[size] = price;
   swingLowLabels[size] = label_text;
   swingLowDetectBars[size] = detect_index;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AppendInternalHigh(int pivot_index, int detect_index, double price)
  {
   int size = ArraySize(internalHighBars);
   if(size > 0 && internalHighBars[size - 1] == pivot_index && internalHighDetectBars[size - 1] == detect_index)
      return;
   ArrayResize(internalHighBars, size + 1);
   ArrayResize(internalHighPrices, size + 1);
   ArrayResize(internalHighDetectBars, size + 1);
   internalHighBars[size] = pivot_index;
   internalHighPrices[size] = price;
   internalHighDetectBars[size] = detect_index;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AppendInternalLow(int pivot_index, int detect_index, double price)
  {
   int size = ArraySize(internalLowBars);
   if(size > 0 && internalLowBars[size - 1] == pivot_index && internalLowDetectBars[size - 1] == detect_index)
      return;
   ArrayResize(internalLowBars, size + 1);
   ArrayResize(internalLowPrices, size + 1);
   ArrayResize(internalLowDetectBars, size + 1);
   internalLowBars[size] = pivot_index;
   internalLowPrices[size] = price;
   internalLowDetectBars[size] = detect_index;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ZoneBreakArrowUpBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, ShowZoneBreakArrows ? DRAW_ARROW : DRAW_NONE);
   PlotIndexSetInteger(0, PLOT_ARROW, ZoneBreakArrowUpCode);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, ZoneBreakArrowUpColor);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, ZoneBreakArrowSize);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "Zone Break Up");
   ArraySetAsSeries(ZoneBreakArrowUpBuffer, true);
   SetIndexBuffer(1, ZoneBreakArrowDownBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, ShowZoneBreakArrows ? DRAW_ARROW : DRAW_NONE);
   PlotIndexSetInteger(1, PLOT_ARROW, ZoneBreakArrowDownCode);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, ZoneBreakArrowDownColor);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, ZoneBreakArrowSize);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(1, PLOT_LABEL, "Zone Break Down");
   ArraySetAsSeries(ZoneBreakArrowDownBuffer, true);
   SetIndexBuffer(2, TrendBreakArrowUpBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, ShowTrendBreakArrows ? DRAW_ARROW : DRAW_NONE);
   PlotIndexSetInteger(2, PLOT_ARROW, TrendBreakArrowUpCode);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, TrendBreakArrowUpColor);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, TrendBreakArrowSize);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(2, PLOT_LABEL, "Trend Break Up");
   ArraySetAsSeries(TrendBreakArrowUpBuffer, true);
   SetIndexBuffer(3, TrendBreakArrowDownBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, ShowTrendBreakArrows ? DRAW_ARROW : DRAW_NONE);
   PlotIndexSetInteger(3, PLOT_ARROW, TrendBreakArrowDownCode);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, TrendBreakArrowDownColor);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, TrendBreakArrowSize);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(3, PLOT_LABEL, "Trend Break Down");
   ArraySetAsSeries(TrendBreakArrowDownBuffer, true);
   atr_handle = iATR(_Symbol, _Period, 200);
   if(atr_handle == INVALID_HANDLE)
     {
      Print("Failed to create ATR indicator handle");
      return(INIT_FAILED);
     }
   int bars = Bars(_Symbol, _Period);
   ArrayResize(atr, bars);
   ArrayResize(cmean_range, bars);
   ArrayResize(iob_top, 0);
   ArrayResize(iob_btm, 0);
   ArrayResize(iob_left, 0);
   ArrayResize(iob_type, 0);
   ArrayResize(ob_top, 0);
   ArrayResize(ob_btm, 0);
   ArrayResize(ob_left, 0);
   ArrayResize(ob_type, 0);
   ArrayResize(swingHighBars, 0);
   ArrayResize(swingHighPrices, 0);
   ArrayResize(swingHighLabels, 0);
   ArrayResize(swingHighDetectBars, 0);
   ArrayResize(swingLowBars, 0);
   ArrayResize(swingLowPrices, 0);
   ArrayResize(swingLowLabels, 0);
   ArrayResize(swingLowDetectBars, 0);
   ArrayResize(internalHighBars, 0);
   ArrayResize(internalHighPrices, 0);
   ArrayResize(internalHighDetectBars, 0);
   ArrayResize(internalLowBars, 0);
   ArrayResize(internalLowPrices, 0);
   ArrayResize(internalLowDetectBars, 0);
   trend = 0;
   itrend = 0;
   top_y = 0;
   top_x = 0;
   btm_y = 0;
   btm_x = 0;
   itop_y = 0;
   itop_x = 0;
   ibtm_y = 0;
   ibtm_x = 0;
   trail_up = 0;
   trail_dn = 0;
   trail_up_x = 0;
   trail_dn_x = 0;
   top_cross = true;
   btm_cross = true;
   itop_cross = true;
   ibtm_cross = true;
   txt_top = "";
   txt_btm = "";
   IndicatorSetString(INDICATOR_SHORTNAME, "Smart Money Concepts [LuxAlgo]");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllObjects();
   if(atr_handle != INVALID_HANDLE)
      IndicatorRelease(atr_handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int total = ObjectsTotal(0, 0, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, obj_prefix) == 0)
        {
         ObjectDelete(0, name);
        }
     }
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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   static datetime last_time = 0;
   static int last_rates_total = 0;
   bool need_full_recalc = false;
   if(prev_calculated == 0)
     {
      need_full_recalc = true;
      last_rates_total = rates_total;
     }
   else
      if(rates_total != last_rates_total)
        {
         need_full_recalc = true;
         last_rates_total = rates_total;
        }
   if(need_full_recalc)
     {
      DeleteAllObjects();
      CalculateATR(rates_total);
      CalculateCMeanRange(rates_total, high, low);
      DetectSwings(rates_total, time, high, low);
      DetectInternalSwings(rates_total, time, high, low, close);
      CheckStructureBreaks(rates_total, time, close, high, low, open, true);
      if(ShowIob || ShowOb)
         DisplayOrderBlocks(rates_total, time);
      if(ShowEq)
         DetectEqualHighLow(rates_total, time, high, low);
      if(ShowFvg)
         DetectFVG(rates_total, time, open, high, low, close);
      DisplayPreviousHighLow(time);
      if(ShowSd)
         DisplayPremiumDiscount(rates_total, time);
      if(ShowZoneBreakArrows)
         DetectZoneBreakouts(rates_total);
      if(ShowTrendBreakArrows)
         DetectTrendBreakouts(rates_total);
      last_time = time[0];
     }
   else
      if(time[0] != last_time)
        {
         last_time = time[0];
         DeleteAllObjects();
         CalculateATR(rates_total);
         CalculateCMeanRange(rates_total, high, low);
         DetectSwings(rates_total, time, high, low);
         DetectInternalSwings(rates_total, time, high, low, close);
         CheckStructureBreaks(rates_total, time, close, high, low, open, true);
         if(ShowIob || ShowOb)
            DisplayOrderBlocks(rates_total, time);
         if(ShowEq)
            DetectEqualHighLow(rates_total, time, high, low);
         if(ShowFvg)
            DetectFVG(rates_total, time, open, high, low, close);
         DisplayPreviousHighLow(time);
         if(ShowSd)
            DisplayPremiumDiscount(rates_total, time);
         if(ShowZoneBreakArrows)
            DetectZoneBreakouts(rates_total);
         if(ShowTrendBreakArrows)
            DetectTrendBreakouts(rates_total);
        }
   if(ShowTrend)
      ColorCandles(rates_total);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateATR(int total)
  {
   if(total <= 0 || atr_handle == INVALID_HANDLE)
      return;
   if(ArraySize(atr) != total)
      ArrayResize(atr, total);
   if(CopyBuffer(atr_handle, 0, 0, total, atr) <= 0)
     {
      Print("Failed to copy ATR buffer");
      return;
     }
   ArraySetAsSeries(atr, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateCMeanRange(int total, const double &high[], const double &low[])
  {
   if(ArraySize(cmean_range) != total)
      ArrayResize(cmean_range, total);
   double sum = 0;
   for(int i = total - 1; i >= 0; i--)
     {
      sum += high[i] - low[i];
      cmean_range[i] = sum / (total - i);
     }
   ArraySetAsSeries(cmean_range, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectSwings(int total, const datetime &time[], const double &high[], const double &low[])
  {
   static int os_swing = 0;
   static int prev_total = 0;
   bool is_first_run = (prev_total == 0);
   if(prev_total > 0 && MathAbs(total - prev_total) > 10)
     {
      os_swing = 0;
      is_first_run = true;
     }
   prev_total = total;
   if(is_first_run)
     {
      ArrayResize(swingHighBars, 0);
      ArrayResize(swingHighPrices, 0);
      ArrayResize(swingHighLabels, 0);
      ArrayResize(swingHighDetectBars, 0);
      ArrayResize(swingLowBars, 0);
      ArrayResize(swingLowPrices, 0);
      ArrayResize(swingLowLabels, 0);
      ArrayResize(swingLowDetectBars, 0);
      os_swing = 0;
     }
   int start_from = total - 1;
   for(int i = start_from; i >= Length; i--)
     {
      double upper = high[i];
      double lower = low[i];
      for(int j = 1; j < Length; j++)
        {
         if(i + j < total)
           {
            if(high[i + j] > upper)
               upper = high[i + j];
            if(low[i + j] < lower)
               lower = low[i + j];
           }
        }
      int old_state = os_swing;
      if(i + Length < total)
        {
         if(high[i + Length] > upper)
            os_swing = 0;
         else
            if(low[i + Length] < lower)
               os_swing = 1;
        }
      if(os_swing == 0 && old_state != 0 && i + Length < total)
        {
         double swing_high = high[i + Length];
         int swing_bar = i + Length;
         top_cross = true;
         string label_text = (top_y == 0 || swing_high > top_y) ? "HH" : "LH";
         txt_top = label_text;
         int pivot_index = (int)(total - swing_bar - 1);
         int detect_index = (int)(total - 1 - i);
         AppendSwingHigh(pivot_index, detect_index, swing_high, label_text);
         bool within_limit = (SwingHistoryBars == 0) || (swing_bar < SwingHistoryBars);
         if(ShowSwings && within_limit)
           {
            string name = obj_prefix + "SwingH_" + TimeKey(time[swing_bar]);
            if(Mode == Present)
              {
               for(int del_i = swing_bar + 100; del_i < total && del_i < swing_bar + 200; del_i++)
                 {
                  string old_name = obj_prefix + "SwingH_" + TimeKey(time[del_i]);
                  if(ObjectFind(0, old_name) >= 0)
                     ObjectDelete(0, old_name);
                 }
              }
            if(ObjectFind(0, name) == -1)
              {
               ObjectCreate(0, name, OBJ_TEXT, 0, time[swing_bar], swing_high);
               ObjectSetString(0, name, OBJPROP_TEXT, label_text);
               ObjectSetString(0, name, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
               ObjectSetInteger(0, name, OBJPROP_COLOR, SwingBearCss);
               ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LOWER);
              }
           }
         top_y = swing_high;
         top_x = (double)(total - swing_bar - 1);
         trail_up = swing_high;
         trail_up_x = swing_bar;
        }
      if(os_swing == 1 && old_state != 1 && i + Length < total)
        {
         double swing_low = low[i + Length];
         int swing_bar = i + Length;
         btm_cross = true;
         string label_text = (btm_y == 0 || swing_low < btm_y) ? "LL" : "HL";
         txt_btm = label_text;
         int pivot_index = (int)(total - swing_bar - 1);
         int detect_index = (int)(total - 1 - i);
         AppendSwingLow(pivot_index, detect_index, swing_low, label_text);
         bool within_limit = (SwingHistoryBars == 0) || (swing_bar < SwingHistoryBars);
         if(ShowSwings && within_limit)
           {
            string name = obj_prefix + "SwingL_" + TimeKey(time[swing_bar]);
            if(Mode == Present)
              {
               for(int del_i = swing_bar + 100; del_i < total && del_i < swing_bar + 200; del_i++)
                 {
                  string old_name = obj_prefix + "SwingL_" + TimeKey(time[del_i]);
                  if(ObjectFind(0, old_name) >= 0)
                     ObjectDelete(0, old_name);
                 }
              }
            if(ObjectFind(0, name) == -1)
              {
               ObjectCreate(0, name, OBJ_TEXT, 0, time[swing_bar], swing_low);
               ObjectSetString(0, name, OBJPROP_TEXT, label_text);
               ObjectSetString(0, name, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
               ObjectSetInteger(0, name, OBJPROP_COLOR, SwingBullCss);
               ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_UPPER);
              }
           }
         btm_y = swing_low;
         btm_x = (double)(total - swing_bar - 1);
         trail_dn = swing_low;
         trail_dn_x = swing_bar;
        }
     }
   if(high[0] > trail_up)
     {
      trail_up = high[0];
      trail_up_x = 0;
     }
   if(low[0] < trail_dn)
     {
      trail_dn = low[0];
      trail_dn_x = 0;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectInternalSwings(int total, const datetime &time[], const double &high[], const double &low[], const double &close[])
  {
   static int os_internal = 0;
   static int prev_total_int = 0;
   int len = 5;
   bool is_first_run = (prev_total_int == 0);
   if(total != prev_total_int && prev_total_int > 0)
     {
      os_internal = 0;
      is_first_run = true;
     }
   prev_total_int = total;
   if(is_first_run)
     {
      os_internal = 0;
      ArrayResize(internalHighBars, 0);
      ArrayResize(internalHighPrices, 0);
      ArrayResize(internalHighDetectBars, 0);
      ArrayResize(internalLowBars, 0);
      ArrayResize(internalLowPrices, 0);
      ArrayResize(internalLowDetectBars, 0);
     }
   int start_from = total - 1;
   for(int i = start_from; i >= len; i--)
     {
      double upper = high[i];
      double lower = low[i];
      for(int j = 1; j < len; j++)
        {
         if(i + j < total)
           {
            if(high[i + j] > upper)
               upper = high[i + j];
            if(low[i + j] < lower)
               lower = low[i + j];
           }
        }
      int old_state = os_internal;
      if(i + len < total)
        {
         if(high[i + len] > upper)
            os_internal = 0;
         else
            if(low[i + len] < lower)
               os_internal = 1;
        }
      if(os_internal == 0 && old_state != 0 && i + len < total)
        {
         itop_cross = true;
         itop_y = high[i + len];
         itop_x = (double)(total - (i + len) - 1);
         int detect_index = (int)(total - 1 - i);
         AppendInternalHigh((int)itop_x, detect_index, itop_y);
        }
      if(os_internal == 1 && old_state != 1 && i + len < total)
        {
         ibtm_cross = true;
         ibtm_y = low[i + len];
         ibtm_x = (double)(total - (i + len) - 1);
         int detect_index = (int)(total - 1 - i);
         AppendInternalLow((int)ibtm_x, detect_index, ibtm_y);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckStructureBreaks(int total, const datetime &time[], const double &close[], const double &high[], const double &low[], const double &open[], bool process_all)
  {
   static int last_processed_pine = -1;
   static int swingHighPtr = 0;
   static int swingLowPtr = 0;
   static int internalHighPtr = 0;
   static int internalLowPtr = 0;
   if(process_all)
     {
      last_processed_pine = -1;
      swingHighPtr = 0;
      swingLowPtr = 0;
      internalHighPtr = 0;
      internalLowPtr = 0;
      trend = 0;
      itrend = 0;
      top_cross = false;
      btm_cross = false;
      itop_cross = false;
      ibtm_cross = false;
     }
   int high_count = ArraySize(swingHighBars);
   int low_count = ArraySize(swingLowBars);
   int ihigh_count = ArraySize(internalHighBars);
   int ilow_count = ArraySize(internalLowBars);
   for(int pine_index = last_processed_pine + 1; pine_index < total; pine_index++)
     {
      int series_index = BarIndexToSeriesIndex(total, pine_index);
      if(swingHighPtr < high_count && swingHighDetectBars[swingHighPtr] == pine_index)
        {
         top_y = swingHighPrices[swingHighPtr];
         top_x = swingHighBars[swingHighPtr];
         txt_top = swingHighLabels[swingHighPtr];
         top_cross = true;
         swingHighPtr++;
        }
      if(swingLowPtr < low_count && swingLowDetectBars[swingLowPtr] == pine_index)
        {
         btm_y = swingLowPrices[swingLowPtr];
         btm_x = swingLowBars[swingLowPtr];
         txt_btm = swingLowLabels[swingLowPtr];
         btm_cross = true;
         swingLowPtr++;
        }
      if(internalHighPtr < ihigh_count && internalHighDetectBars[internalHighPtr] == pine_index)
        {
         itop_y = internalHighPrices[internalHighPtr];
         itop_x = internalHighBars[internalHighPtr];
         itop_cross = true;
         internalHighPtr++;
        }
      if(internalLowPtr < ilow_count && internalLowDetectBars[internalLowPtr] == pine_index)
        {
         ibtm_y = internalLowPrices[internalLowPtr];
         ibtm_x = internalLowBars[internalLowPtr];
         ibtm_cross = true;
         internalLowPtr++;
        }
      if(series_index + 1 >= total)
         continue;
      double prev_close_val = close[series_index + 1];
      double curr_close = close[series_index];
      double curr_high = high[series_index];
      double curr_low = low[series_index];
      double curr_open = open[series_index];
      if(ShowInternals && itop_cross && top_y != itop_y)
        {
         bool crossover_up = (prev_close_val <= itop_y && curr_close > itop_y);
         if(crossover_up)
           {
            bool bull_concordant = true;
            if(IFilterConfluence)
               bull_concordant = (curr_high - MathMax(curr_close, curr_open)) > (MathMin(curr_close, curr_open) - curr_low);
            if(bull_concordant)
              {
               bool choch = (itrend < 0);
               string txt = choch ? "CHoCH" : "BOS";
               if(ShowIBull == All || (ShowIBull == BOS && !choch) || (ShowIBull == CHoCH && choch))
                  DisplayStructure(total, (int)itop_x, pine_index, itop_y, txt, SwingIBullCss, true, true, time, InternalStructureSize);
               itop_cross = false;
               itrend = 1;
               if(ShowIob)
                  AddOrderBlock(total, false, (int)itop_x, true, high, low);
              }
           }
        }
      if(ShowInternals && ibtm_cross && btm_y != ibtm_y)
        {
         bool crossunder_dn = (prev_close_val >= ibtm_y && curr_close < ibtm_y);
         if(crossunder_dn)
           {
            bool bear_concordant = true;
            if(IFilterConfluence)
               bear_concordant = (curr_high - MathMax(curr_close, curr_open)) < (MathMin(curr_close, curr_open) - curr_low);
            if(bear_concordant)
              {
               bool choch = (itrend > 0);
               string txt = choch ? "CHoCH" : "BOS";
               if(ShowIBear == All || (ShowIBear == BOS && !choch) || (ShowIBear == CHoCH && choch))
                  DisplayStructure(total, (int)ibtm_x, pine_index, ibtm_y, txt, SwingIBearCss, true, false, time, InternalStructureSize);
               ibtm_cross = false;
               itrend = -1;
               if(ShowIob)
                  AddOrderBlock(total, true, (int)ibtm_x, true, high, low);
              }
           }
        }
      if(ShowStructure && top_cross)
        {
         bool crossover_up = (prev_close_val <= top_y && curr_close > top_y);
         if(crossover_up)
           {
            bool choch = (trend < 0);
            string txt = choch ? "CHoCH" : "BOS";
            if(ShowBull == All || (ShowBull == BOS && !choch) || (ShowBull == CHoCH && choch))
               DisplayStructure(total, (int)top_x, pine_index, top_y, txt, SwingBullCss, false, true, time, SwingStructureSize);
            if(ShowOb)
               AddOrderBlock(total, false, (int)top_x, false, high, low);
            top_cross = false;
            trend = 1;
           }
        }
      if(ShowStructure && btm_cross)
        {
         bool crossunder_dn = (prev_close_val >= btm_y && curr_close < btm_y);
         if(crossunder_dn)
           {
            bool choch = (trend > 0);
            string txt = choch ? "CHoCH" : "BOS";
            if(ShowBear == All || (ShowBear == BOS && !choch) || (ShowBear == CHoCH && choch))
               DisplayStructure(total, (int)btm_x, pine_index, btm_y, txt, SwingBearCss, false, false, time, SwingStructureSize);
            if(ShowOb)
               AddOrderBlock(total, true, (int)btm_x, false, high, low);
            btm_cross = false;
            trend = -1;
           }
        }
     }
   last_processed_pine = total - 1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayStructure(int total, int pivot_index, int detect_index, double y, string txt, color css, bool dashed, bool down, const datetime &time[], ENUM_LABEL_SIZE label_size)
  {
   int start_index = BarIndexToSeriesIndex(total, pivot_index);
   int end_index = BarIndexToSeriesIndex(total, detect_index);
   if(start_index < 0 || start_index >= total || end_index < 0 || end_index >= total)
      return;
   datetime start_time = time[start_index];
   datetime end_time = time[end_index];
   if(end_time < start_time)
      end_time = start_time;
   string line_name = obj_prefix + "Line_" + txt + "_" + TimeKey(start_time) + "_" + TimeKey(end_time);
   string label_name = obj_prefix + "Label_" + txt + "_" + TimeKey(start_time) + "_" + TimeKey(end_time);
   datetime label_time = (datetime)(((long)start_time + (long)end_time) / 2);
   double point_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point_value <= 0)
      point_value = 0.0001;
   double offset = point_value * 10.0;
   double label_y = y;
   ENUM_ANCHOR_POINT anchor = down ? ANCHOR_LOWER : ANCHOR_UPPER;
   if(down)
      label_y = y + offset;
   else
      label_y = y - offset;
   int font_size = 8;
   if(label_size == Tiny)
      font_size = 6;
   else
      if(label_size == Small)
         font_size = 8;
      else
         if(label_size == Normal)
            font_size = 10;
   if(ObjectFind(0, line_name) == -1)
     {
      ObjectCreate(0, line_name, OBJ_TREND, 0, start_time, y, end_time, y);
      ObjectSetInteger(0, line_name, OBJPROP_COLOR, css);
      ObjectSetInteger(0, line_name, OBJPROP_STYLE, dashed ? STYLE_DASH : STYLE_SOLID);
      ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, line_name, OBJPROP_RAY_RIGHT, false);
     }
   else
     {
      ObjectSetInteger(0, line_name, OBJPROP_TIME, 1, end_time);
      ObjectSetDouble(0, line_name, OBJPROP_PRICE, 1, y);
     }
   if(ObjectFind(0, label_name) == -1)
     {
      ObjectCreate(0, label_name, OBJ_TEXT, 0, label_time, label_y);
      ObjectSetString(0, label_name, OBJPROP_TEXT, txt);
      ObjectSetString(0, label_name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, font_size);
      ObjectSetInteger(0, label_name, OBJPROP_COLOR, css);
      ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, anchor);
     }
   else
     {
      ObjectMove(0, label_name, 0, label_time, label_y);
      ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, anchor);
      ObjectSetString(0, label_name, OBJPROP_TEXT, txt);
      ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, font_size);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddOrderBlock(int total, bool use_max, int loc, bool is_internal, const double &high[], const double &low[])
  {
   double min_price = 999999999.0;
   double max_price = 0.0;
   int idx = 1;
   int loc_series = BarIndexToSeriesIndex(total, loc);
   if(loc_series < 0 || loc_series >= ArraySize(atr) || loc_series >= ArraySize(cmean_range))
      return;
   double ob_threshold = (ObFilter == Atr) ? atr[loc_series] : cmean_range[loc_series];
   int bars_back = total - loc - 1;
   if(use_max)
     {
      for(int i = 1; i < bars_back; i++)
        {
         if((high[i] - low[i]) < ob_threshold * 2)
           {
            if(high[i] > max_price)
              {
               max_price = high[i];
               min_price = low[i];
               idx = i;
              }
           }
        }
     }
   else
     {
      for(int i = 1; i < bars_back; i++)
        {
         if((high[i] - low[i]) < ob_threshold * 2)
           {
            if(low[i] < min_price)
              {
               min_price = low[i];
               max_price = high[i];
               idx = i;
              }
           }
        }
     }
   datetime block_time = iTime(_Symbol, _Period, idx);
   if(is_internal)
     {
      ArrayInsertDouble(iob_top, 0, max_price);
      ArrayInsertDouble(iob_btm, 0, min_price);
      ArrayInsertDatetime(iob_left, 0, block_time);
      ArrayInsertInt(iob_type, 0, use_max ? -1 : 1);
     }
   else
     {
      ArrayInsertDouble(ob_top, 0, max_price);
      ArrayInsertDouble(ob_btm, 0, min_price);
      ArrayInsertDatetime(ob_left, 0, block_time);
      ArrayInsertInt(ob_type, 0, use_max ? -1 : 1);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayInsertDouble(double &arr[], int pos, double value)
  {
   int size = ArraySize(arr);
   ArrayResize(arr, size + 1);
   for(int i = size; i > pos; i--)
     {
      arr[i] = arr[i - 1];
     }
   arr[pos] = value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayInsertDatetime(datetime &arr[], int pos, datetime value)
  {
   int size = ArraySize(arr);
   ArrayResize(arr, size + 1);
   for(int i = size; i > pos; i--)
     {
      arr[i] = arr[i - 1];
     }
   arr[pos] = value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayInsertInt(int &arr[], int pos, int value)
  {
   int size = ArraySize(arr);
   ArrayResize(arr, size + 1);
   for(int i = size; i > pos; i--)
     {
      arr[i] = arr[i - 1];
     }
   arr[pos] = value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayRemoveDouble(double &arr[], int index)
  {
   int size = ArraySize(arr);
   if(index < 0 || index >= size)
      return;
   for(int i = index; i < size - 1; i++)
     {
      arr[i] = arr[i + 1];
     }
   ArrayResize(arr, size - 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayRemoveDatetime(datetime &arr[], int index)
  {
   int size = ArraySize(arr);
   if(index < 0 || index >= size)
      return;
   for(int i = index; i < size - 1; i++)
     {
      arr[i] = arr[i + 1];
     }
   ArrayResize(arr, size - 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayRemoveInt(int &arr[], int index)
  {
   int size = ArraySize(arr);
   if(index < 0 || index >= size)
      return;
   for(int i = index; i < size - 1; i++)
     {
      arr[i] = arr[i + 1];
     }
   ArrayResize(arr, size - 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayOrderBlocks(int total, const datetime &time[])
  {
   double current_close = iClose(_Symbol, _Period, 0);
   for(int i = ArraySize(iob_type) - 1; i >= 0; i--)
     {
      if(current_close < iob_btm[i] && iob_type[i] == 1)
        {
         ArrayRemoveDouble(iob_top, i);
         ArrayRemoveDouble(iob_btm, i);
         ArrayRemoveDatetime(iob_left, i);
         ArrayRemoveInt(iob_type, i);
        }
      else
         if(current_close > iob_top[i] && iob_type[i] == -1)
           {
            ArrayRemoveDouble(iob_top, i);
            ArrayRemoveDouble(iob_btm, i);
            ArrayRemoveDatetime(iob_left, i);
            ArrayRemoveInt(iob_type, i);
           }
     }
   for(int i = ArraySize(ob_type) - 1; i >= 0; i--)
     {
      if(current_close < ob_btm[i] && ob_type[i] == 1)
        {
         ArrayRemoveDouble(ob_top, i);
         ArrayRemoveDouble(ob_btm, i);
         ArrayRemoveDatetime(ob_left, i);
         ArrayRemoveInt(ob_type, i);
        }
      else
         if(current_close > ob_top[i] && ob_type[i] == -1)
           {
            ArrayRemoveDouble(ob_top, i);
            ArrayRemoveDouble(ob_btm, i);
            ArrayRemoveDatetime(ob_left, i);
            ArrayRemoveInt(ob_type, i);
           }
     }
   datetime current_time = iTime(_Symbol, _Period, 0);
   if(ShowIob)
     {
      int iob_size = ArraySize(iob_type);
      int show_count = (int)MathMin((double)IobShowLast, (double)iob_size);
      int displayed = 0;
      string displayed_zones = "";
      for(int i = 0; i < iob_size && displayed < IobShowLast; i++)
        {
         string zone_key = TimeToString(iob_left[i]) + "_" + DoubleToString(iob_top[i], 5) + "_" + DoubleToString(iob_btm[i], 5);
         if(StringFind(displayed_zones, zone_key) >= 0)
            continue;
         displayed_zones = displayed_zones + zone_key + ";";
         string name = obj_prefix + "IOB_" + IntegerToString(displayed);
         color box_color = (Style == Monochrome) ?
                           (color)(iob_type[i] == 1 ? 0x80B5B2B2 : 0x806B5D60) :
                           (color)(iob_type[i] == 1 ? IBullObCss : IBearObCss);
         ObjectCreate(0, name, OBJ_RECTANGLE, 0, iob_left[i], iob_top[i], current_time, iob_btm[i]);
         ObjectSetInteger(0, name, OBJPROP_COLOR, box_color);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
         ObjectSetInteger(0, name, OBJPROP_FILL, true);
         displayed++;
        }
     }
   if(ShowOb)
     {
      int ob_size = ArraySize(ob_type);
      int show_count = (int)MathMin((double)ObShowLast, (double)ob_size);
      int displayed = 0;
      string displayed_zones = "";
      for(int i = 0; i < ob_size && displayed < ObShowLast; i++)
        {
         string zone_key = TimeToString(ob_left[i]) + "_" + DoubleToString(ob_top[i], 5) + "_" + DoubleToString(ob_btm[i], 5);
         if(StringFind(displayed_zones, zone_key) >= 0)
            continue;
         displayed_zones = displayed_zones + zone_key + ";";
         string name = obj_prefix + "OB_" + IntegerToString(displayed);
         uint box_color = (Style == Monochrome) ?
                          (ob_type[i] == 1 ? 0x80B5B2B2 : 0x806B5D60) :
                          (ob_type[i] == 1 ? BullObCss : BearObCss);
         ObjectCreate(0, name, OBJ_RECTANGLE, 0, ob_left[i], ob_top[i], current_time, ob_btm[i]);
         ObjectSetInteger(0, name, OBJPROP_COLOR, box_color);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
         ObjectSetInteger(0, name, OBJPROP_FILL, true);
         displayed++;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectEqualHighLow(int total, const datetime &time[], const double &high[], const double &low[])
  {
   static double s_eq_prev_top = 0;
   static double s_eq_prev_btm = 0;
   static int s_eq_top_x = -1;
   static int s_eq_btm_x = -1;
   int max_index = total - EqLen - 1;
   if(max_index < EqLen)
      return;
   for(int i = max_index; i >= EqLen; i--)
     {
      bool is_pivot_high = true;
      double pivot_h = high[i];
      for(int j = 1; j <= EqLen; j++)
        {
         if(high[i + j] >= pivot_h || high[i - j] > pivot_h)
           {
            is_pivot_high = false;
            break;
           }
        }
      if(is_pivot_high)
        {
         if(s_eq_prev_top > 0 && s_eq_top_x >= 0)
           {
            double max_h = MathMax(pivot_h, s_eq_prev_top);
            double min_h = MathMin(pivot_h, s_eq_prev_top);
            if(max_h < min_h + atr[i] * EqThreshold)
              {
               string line_name = obj_prefix + "EQH_Line_" + TimeKey(time[s_eq_top_x]) + "_" + TimeKey(time[i]);
               string label_name = obj_prefix + "EQH_Label_" + TimeKey(time[s_eq_top_x]) + "_" + TimeKey(time[i]);
               int eqh_font_size = (EqSize == Tiny) ? 6 : (EqSize == Small) ? 8 : 10;
               if(ObjectFind(0, line_name) == -1)
                 {
                  ObjectCreate(0, line_name, OBJ_TREND, 0, time[s_eq_top_x], s_eq_prev_top, time[i], pivot_h);
                  ObjectSetInteger(0, line_name, OBJPROP_COLOR, SwingBearCss);
                  ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DOT);
                  ObjectSetInteger(0, line_name, OBJPROP_RAY_RIGHT, false);
                  ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
                  double label_price = pivot_h + 20 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                  ObjectCreate(0, label_name, OBJ_TEXT, 0, time[(s_eq_top_x + i) / 2], label_price);
                  ObjectSetString(0, label_name, OBJPROP_TEXT, "EQH");
                  ObjectSetString(0, label_name, OBJPROP_FONT, "Arial");
                  ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, eqh_font_size);
                  ObjectSetInteger(0, label_name, OBJPROP_COLOR, SwingBearCss);
                  ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, ANCHOR_LOWER);
                 }
              }
           }
         s_eq_prev_top = pivot_h;
         s_eq_top_x = i;
        }
      bool is_pivot_low = true;
      double pivot_l = low[i];
      for(int j = 1; j <= EqLen; j++)
        {
         if(low[i + j] <= pivot_l || low[i - j] < pivot_l)
           {
            is_pivot_low = false;
            break;
           }
        }
      if(is_pivot_low)
        {
         if(s_eq_prev_btm > 0 && s_eq_btm_x >= 0)
           {
            double max_l = MathMax(pivot_l, s_eq_prev_btm);
            double min_l = MathMin(pivot_l, s_eq_prev_btm);
            if(min_l > max_l - atr[i] * EqThreshold)
              {
               string line_name = obj_prefix + "EQL_Line_" + TimeKey(time[s_eq_btm_x]) + "_" + TimeKey(time[i]);
               string label_name = obj_prefix + "EQL_Label_" + TimeKey(time[s_eq_btm_x]) + "_" + TimeKey(time[i]);
               int eql_font_size = (EqSize == Tiny) ? 6 : (EqSize == Small) ? 8 : 10;
               if(ObjectFind(0, line_name) == -1)
                 {
                  ObjectCreate(0, line_name, OBJ_TREND, 0, time[s_eq_btm_x], s_eq_prev_btm, time[i], pivot_l);
                  ObjectSetInteger(0, line_name, OBJPROP_COLOR, SwingBullCss);
                  ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DOT);
                  ObjectSetInteger(0, line_name, OBJPROP_RAY_RIGHT, false);
                  ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
                  double label_price = pivot_l - 20 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                  ObjectCreate(0, label_name, OBJ_TEXT, 0, time[(s_eq_btm_x + i) / 2], label_price);
                  ObjectSetString(0, label_name, OBJPROP_TEXT, "EQL");
                  ObjectSetString(0, label_name, OBJPROP_FONT, "Arial");
                  ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, eql_font_size);
                  ObjectSetInteger(0, label_name, OBJPROP_COLOR, SwingBullCss);
                  ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, ANCHOR_UPPER);
                 }
              }
           }
         s_eq_prev_btm = pivot_l;
         s_eq_btm_x = i;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectFVG(int total, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
  {
   for(int i = 2; i < total - 1; i++)
     {
      if(low[i] > high[i + 2])
        {
         double gap_top = low[i];
         double gap_btm = high[i + 2];
         double gap_mid = (gap_top + gap_btm) / 2;
         string name1 = obj_prefix + "FVG_Bull1_" + IntegerToString(i);
         string name2 = obj_prefix + "FVG_Bull2_" + IntegerToString(i);
         int extend_idx = MathMax(i - FvgExtend, 0);
         ObjectCreate(0, name1, OBJ_RECTANGLE, 0, time[i + 1], gap_top, time[extend_idx], gap_mid);
         ObjectSetInteger(0, name1, OBJPROP_COLOR, BullFvgCss);
         ObjectSetInteger(0, name1, OBJPROP_BACK, true);
         ObjectSetInteger(0, name1, OBJPROP_FILL, true);
         ObjectCreate(0, name2, OBJ_RECTANGLE, 0, time[i + 1], gap_mid, time[extend_idx], gap_btm);
         ObjectSetInteger(0, name2, OBJPROP_COLOR, BullFvgCss);
         ObjectSetInteger(0, name2, OBJPROP_BACK, true);
         ObjectSetInteger(0, name2, OBJPROP_FILL, true);
        }
      if(high[i] < low[i + 2])
        {
         double gap_top = low[i + 2];
         double gap_btm = high[i];
         double gap_mid = (gap_top + gap_btm) / 2;
         string name1 = obj_prefix + "FVG_Bear1_" + IntegerToString(i);
         string name2 = obj_prefix + "FVG_Bear2_" + IntegerToString(i);
         int extend_idx = MathMax(i - FvgExtend, 0);
         ObjectCreate(0, name1, OBJ_RECTANGLE, 0, time[i + 1], gap_top, time[extend_idx], gap_mid);
         ObjectSetInteger(0, name1, OBJPROP_COLOR, BearFvgCss);
         ObjectSetInteger(0, name1, OBJPROP_BACK, true);
         ObjectSetInteger(0, name1, OBJPROP_FILL, true);
         ObjectCreate(0, name2, OBJ_RECTANGLE, 0, time[i + 1], gap_mid, time[extend_idx], gap_btm);
         ObjectSetInteger(0, name2, OBJPROP_COLOR, BearFvgCss);
         ObjectSetInteger(0, name2, OBJPROP_BACK, true);
         ObjectSetInteger(0, name2, OBJPROP_FILL, true);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayPreviousHighLow(const datetime &time[])
  {
   if(ShowPdhl)
     {
      double pdh = iHigh(_Symbol, PERIOD_D1, 1);
      double pdl = iLow(_Symbol, PERIOD_D1, 1);
      string name_h = obj_prefix + "PDH";
      string name_l = obj_prefix + "PDL";
      ObjectCreate(0, name_h, OBJ_HLINE, 0, 0, pdh);
      ObjectSetInteger(0, name_h, OBJPROP_COLOR, PdhlCss);
      ObjectSetInteger(0, name_h, OBJPROP_STYLE, GetLineStyle(PdhlStyle));
      ObjectSetString(0, name_h, OBJPROP_TEXT, "PDH");
      ObjectCreate(0, name_l, OBJ_HLINE, 0, 0, pdl);
      ObjectSetInteger(0, name_l, OBJPROP_COLOR, PdhlCss);
      ObjectSetInteger(0, name_l, OBJPROP_STYLE, GetLineStyle(PdhlStyle));
      ObjectSetString(0, name_l, OBJPROP_TEXT, "PDL");
     }
   if(ShowPwhl)
     {
      double pwh = iHigh(_Symbol, PERIOD_W1, 1);
      double pwl = iLow(_Symbol, PERIOD_W1, 1);
      string name_h = obj_prefix + "PWH";
      string name_l = obj_prefix + "PWL";
      ObjectCreate(0, name_h, OBJ_HLINE, 0, 0, pwh);
      ObjectSetInteger(0, name_h, OBJPROP_COLOR, PwhlCss);
      ObjectSetInteger(0, name_h, OBJPROP_STYLE, GetLineStyle(PwhlStyle));
      ObjectSetString(0, name_h, OBJPROP_TEXT, "PWH");
      ObjectCreate(0, name_l, OBJ_HLINE, 0, 0, pwl);
      ObjectSetInteger(0, name_l, OBJPROP_COLOR, PwhlCss);
      ObjectSetInteger(0, name_l, OBJPROP_STYLE, GetLineStyle(PwhlStyle));
      ObjectSetString(0, name_l, OBJPROP_TEXT, "PWL");
     }
   if(ShowPmhl)
     {
      double pmh = iHigh(_Symbol, PERIOD_MN1, 1);
      double pml = iLow(_Symbol, PERIOD_MN1, 1);
      string name_h = obj_prefix + "PMH";
      string name_l = obj_prefix + "PML";
      ObjectCreate(0, name_h, OBJ_HLINE, 0, 0, pmh);
      ObjectSetInteger(0, name_h, OBJPROP_COLOR, PmhlCss);
      ObjectSetInteger(0, name_h, OBJPROP_STYLE, GetLineStyle(PmhlStyle));
      ObjectSetString(0, name_h, OBJPROP_TEXT, "PMH");
      ObjectCreate(0, name_l, OBJ_HLINE, 0, 0, pml);
      ObjectSetInteger(0, name_l, OBJPROP_COLOR, PmhlCss);
      ObjectSetInteger(0, name_l, OBJPROP_STYLE, GetLineStyle(PmhlStyle));
      ObjectSetString(0, name_l, OBJPROP_TEXT, "PML");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetLineStyle(ENUM_LINESTYLE style)
  {
   if(style == Solid)
      return STYLE_SOLID;
   if(style == Dashed)
      return STYLE_DASH;
   if(style == Dotted)
      return STYLE_DOT;
   return STYLE_SOLID;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayPremiumDiscount(int total, const datetime &time[])
  {
   double avg = (trail_up + trail_dn) / 2;
   string premium_name = obj_prefix + "Premium";
   string eq_name = obj_prefix + "Equilibrium";
   string discount_name = obj_prefix + "Discount";
   int bar_index = (int)MathMax(top_x, btm_x);
   int start_index = BarIndexToSeriesIndex(total, bar_index);
   datetime start_time = time[start_index];
   datetime current_time = iTime(_Symbol, _Period, 0);
   ObjectCreate(0, premium_name, OBJ_RECTANGLE, 0, start_time, trail_up, current_time, 0.95 * trail_up + 0.05 * trail_dn);
   ObjectSetInteger(0, premium_name, OBJPROP_COLOR, PremiumCss);
   ObjectSetInteger(0, premium_name, OBJPROP_BACK, true);
   ObjectSetInteger(0, premium_name, OBJPROP_FILL, true);
   ObjectCreate(0, eq_name, OBJ_RECTANGLE, 0, start_time, 0.525 * trail_up + 0.475 * trail_dn, current_time, 0.525 * trail_dn + 0.475 * trail_up);
   ObjectSetInteger(0, eq_name, OBJPROP_COLOR, EqCss);
   ObjectSetInteger(0, eq_name, OBJPROP_BACK, true);
   ObjectSetInteger(0, eq_name, OBJPROP_FILL, true);
   ObjectCreate(0, discount_name, OBJ_RECTANGLE, 0, start_time, 0.95 * trail_dn + 0.05 * trail_up, current_time, trail_dn);
   ObjectSetInteger(0, discount_name, OBJPROP_COLOR, DiscountCss);
   ObjectSetInteger(0, discount_name, OBJPROP_BACK, true);
   ObjectSetInteger(0, discount_name, OBJPROP_FILL, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ColorCandles(int total)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectZoneBreakouts(int rates_total)
  {
   if(!ShowZoneBreakArrows)
      return;
   ArrayInitialize(ZoneBreakArrowUpBuffer, EMPTY_VALUE);
   ArrayInitialize(ZoneBreakArrowDownBuffer, EMPTY_VALUE);
   double offset_price = ZoneBreakArrowOffset * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   for(int obj = ObjectsTotal(0) - 1; obj >= 0; obj--)
     {
      string obj_name = ObjectName(0, obj);
      bool is_iob = (StringFind(obj_name, obj_prefix + "IOB_") == 0);
      bool is_ob = (StringFind(obj_name, obj_prefix + "OB_") == 0);
      if(!is_iob && !is_ob)
         continue;
      if(ObjectGetInteger(0, obj_name, OBJPROP_TYPE) != OBJ_RECTANGLE)
         continue;
      datetime zone_start_time = (datetime)ObjectGetInteger(0, obj_name, OBJPROP_TIME, 0);
      double zone_price1 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0);
      double zone_price2 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 1);
      double zone_high = MathMax(zone_price1, zone_price2);
      double zone_low = MathMin(zone_price1, zone_price2);
      int zone_bar = iBarShift(_Symbol, _Period, zone_start_time);
      if(zone_bar < 0)
         continue;
      for(int bar = zone_bar; bar >= 0; bar--)
        {
         double bar_close = iClose(_Symbol, _Period, bar);
         double bar_open = iOpen(_Symbol, _Period, bar);
         double bar_high = iHigh(_Symbol, _Period, bar);
         double bar_low = iLow(_Symbol, _Period, bar);
         double prev_close = (bar + 1 < Bars(_Symbol, _Period)) ? iClose(_Symbol, _Period, bar + 1) : bar_open;
         if(bar_close > zone_high && bar_close > bar_open)
           {
            if(bar_open <= zone_high || prev_close <= zone_high)
              {
               if(ZoneBreakArrowUpBuffer[bar] == EMPTY_VALUE)
                  ZoneBreakArrowUpBuffer[bar] = bar_low - offset_price;
               break;
              }
           }
         if(bar_close < zone_low && bar_close < bar_open)
           {
            if(bar_open >= zone_low || prev_close >= zone_low)
              {
               if(ZoneBreakArrowDownBuffer[bar] == EMPTY_VALUE)
                  ZoneBreakArrowDownBuffer[bar] = bar_high + offset_price;
               break;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectTrendBreakouts(int rates_total)
  {
   if(!ShowTrendBreakArrows)
      return;
   ArrayInitialize(TrendBreakArrowUpBuffer, EMPTY_VALUE);
   ArrayInitialize(TrendBreakArrowDownBuffer, EMPTY_VALUE);
   double offset_price = TrendBreakArrowOffset * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   for(int obj = ObjectsTotal(0) - 1; obj >= 0; obj--)
     {
      string obj_name = ObjectName(0, obj);
      if(StringFind(obj_name, "SMC") == -1)
         continue;
      if(ObjectGetInteger(0, obj_name, OBJPROP_TYPE) == OBJ_TREND)
        {
         datetime time1 = (datetime)ObjectGetInteger(0, obj_name, OBJPROP_TIME, 0);
         double price1 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0);
         datetime time2 = (datetime)ObjectGetInteger(0, obj_name, OBJPROP_TIME, 1);
         double price2 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 1);
         if(time1 == 0 || time2 == 0)
            continue;
         datetime earliest_time = (time1 < time2) ? time1 : time2;
         int start_bar = iBarShift(_Symbol, _Period, earliest_time);
         if(start_bar <= 1)
            continue;
         for(int bar = start_bar; bar >= 1; bar--)
           {
            datetime bar_time = iTime(_Symbol, _Period, bar);
            if(bar_time < earliest_time)
               continue;
            double time_diff = (double)(time2 - time1);
            if(time_diff == 0)
               continue;
            double price_diff = price2 - price1;
            double bar_time_diff = (double)(bar_time - time1);
            double trend_price = price1 + (price_diff / time_diff) * bar_time_diff;
            double bar_close = iClose(_Symbol, _Period, bar);
            double bar_open = iOpen(_Symbol, _Period, bar);
            double bar_high = iHigh(_Symbol, _Period, bar);
            double bar_low = iLow(_Symbol, _Period, bar);
            double prev_close = iClose(_Symbol, _Period, bar + 1);
            if(bar_close > trend_price && bar_close > bar_open &&
               (bar_open < trend_price || prev_close < trend_price))
              {
               TrendBreakArrowUpBuffer[bar] = bar_low - offset_price;
               break;
              }
            if(bar_close < trend_price && bar_close < bar_open &&
               (bar_open > trend_price || prev_close > trend_price))
              {
               TrendBreakArrowDownBuffer[bar] = bar_high + offset_price;
               break;
              }
           }
        }
     }
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        SMC_v2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160947#p160947
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
