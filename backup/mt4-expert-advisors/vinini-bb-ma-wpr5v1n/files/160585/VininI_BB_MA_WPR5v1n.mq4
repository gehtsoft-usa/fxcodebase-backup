//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160549#p160549
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
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_type1   DRAW_LINE
#property indicator_color1  Aqua
#property indicator_label1  "MA(WPR)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Green
#property indicator_type3   DRAW_LINE
#property indicator_color3  Yellow
#property indicator_type4   DRAW_LINE
#property indicator_color4  Yellow
#property indicator_level1  0
#property indicator_level2  60
#property indicator_level3  -60


//---- input parameters
input int WPR_Period = 55;
input int MA_Period  = 3;
input int MA_Mode    = MODE_SMA;
input int BB_Period  = 89;
input double BB_Div  = 1.0;
input int Limit      = 1440;

enum Arrow_Mode
  {
   none = 0,   // No arrows
   middle = 1, // Arrows on middle line cross
   uplow = 2   // Arrows on upper/lower line cross
  };
input Arrow_Mode Arrow_Condition = middle;                     // Arrow condition
input int Arrow_Size = 1;                                      // Arrow size
input int Arrow_Offset = 30;                                   // Arrow distance from candles (in points)
input color Up_Arrow_Color = Red;                              // Color of down arrows
input int Up_Arrow_Symbol = 234;                               // Symbol of down arrows
input color Down_Arrow_Color = Blue;                           // Color of up arrows
input int Down_Arrow_Symbol = 233;                             // Symbol of up arrows

double MA_Buffer[];
double WPRMidle_Buffer[];
double WPRUP_Buffer[];
double WPRDN_Buffer[];
double WPR_Buffer[];
double ArrowUp[];
double ArrowDn[];

int min_bars;
string shortname = "BB_MA_WPR5v1n";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll(0, shortname + "_u_");
   ObjectsDeleteAll(0, shortname + "_d_");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(WPR_Period <= 0 || MA_Period <= 0 || BB_Period <= 0)
      return(INIT_PARAMETERS_INCORRECT);
   min_bars = WPR_Period + MA_Period + BB_Period;
   SetIndexBuffer(0, MA_Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, WPRMidle_Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, WPRUP_Buffer, INDICATOR_DATA);
   SetIndexBuffer(3, WPRDN_Buffer, INDICATOR_DATA);
   SetIndexBuffer(4, WPR_Buffer, INDICATOR_CALCULATIONS);
   IndicatorSetString(INDICATOR_SHORTNAME, "MA_WPR(" + IntegerToString(WPR_Period) + "," + IntegerToString(MA_Period) + ")");
   PlotIndexSetString(0, PLOT_LABEL, "MA(WPR)");
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, min_bars);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, min_bars);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, min_bars);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, min_bars);
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateBandsOnArray(const double &array[], const int position, const int period, const double deviations,
                           double &midle, double &upper, double &lower)
  {
   bool original_series = ArrayGetAsSeries(array);
   ArraySetAsSeries(array, false);
   if(position < period - 1)
     {
      midle = 0.0;
      upper = 0.0;
      lower = 0.0;
      ArraySetAsSeries(array, original_series);
      return;
     }
   double sum = 0.0;
   for(int i = 0; i < period; i++)
      sum += array[position - period + 1 + i];
   midle = sum / period;
   double variance = 0.0;
   for(int i = 0; i < period; i++)
     {
      double diff = array[position - period + 1 + i] - midle;
      variance += diff * diff;
     }
   variance /= period;
   double stddev = MathSqrt(variance);
   upper = midle + deviations * stddev;
   lower = midle - deviations * stddev;
   ArraySetAsSeries(array, original_series);
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
   if(rates_total < min_bars)
      return(0);
   int start;
   if(prev_calculated == 0)
     {
      ArrayInitialize(WPR_Buffer, 0.0);
      ArrayInitialize(MA_Buffer, 0.0);
      ArrayInitialize(WPRMidle_Buffer, 0.0);
      ArrayInitialize(WPRUP_Buffer, 0.0);
      ArrayInitialize(WPRDN_Buffer, 0.0);
      start = WPR_Period - 1;
     }
   else
     {
      start = rates_total - 1;
     }
   for(int i = rates_total - 1; i >= 0; i--)
     {
      WPR_Buffer[i] = iWPR(Symbol(), Period(), WPR_Period, i);
     }
   for(int i = rates_total - 1; i >= 0; i--)
     {
      MA_Buffer[i] = iMAOnArray(WPR_Buffer, 0, MA_Period, 0, MA_Mode, i);
     }
   int bb_start = BB_Period - 1;
   if(prev_calculated > 0)
      bb_start = prev_calculated - 1;
   bool orig_middle = ArrayGetAsSeries(WPRMidle_Buffer);
   bool orig_upper = ArrayGetAsSeries(WPRUP_Buffer);
   bool orig_lower = ArrayGetAsSeries(WPRDN_Buffer);
   ArraySetAsSeries(WPRMidle_Buffer, false);
   ArraySetAsSeries(WPRUP_Buffer, false);
   ArraySetAsSeries(WPRDN_Buffer, false);
   for(int i = bb_start; i < rates_total; i++)
     {
      if(i >= BB_Period - 1)
        {
         double midle, upper, lower;
         CalculateBandsOnArray(WPR_Buffer, i, BB_Period, BB_Div, midle, upper, lower);
         WPRMidle_Buffer[i] = midle;
         WPRUP_Buffer[i] = upper;
         WPRDN_Buffer[i] = lower;
        }
      else
        {
         WPRMidle_Buffer[i] = 0.0;
         WPRUP_Buffer[i] = 0.0;
         WPRDN_Buffer[i] = 0.0;
        }
     }
   ArraySetAsSeries(WPRMidle_Buffer, orig_middle);
   ArraySetAsSeries(WPRUP_Buffer, orig_upper);
   ArraySetAsSeries(WPRDN_Buffer, orig_lower);
   int astart = MathMin(start, bb_start);
   for(int i = 0; i < rates_total; i++)
     {
      drawArrow(0, i, high, low, time);
     }
   if(Arrow_Condition == middle)
     {
      for(int i = rates_total - 1; i >= 0; i--)
        {
         if(MA_Buffer[i] > WPRMidle_Buffer[i] && MA_Buffer[i + 1] <= WPRMidle_Buffer[i + 1])
            drawArrow(2, i, high, low, time);
         if(MA_Buffer[i] < WPRMidle_Buffer[i] && MA_Buffer[i + 1] >= WPRMidle_Buffer[i + 1])
            drawArrow(1, i, high, low, time);
        }
     }
   if(Arrow_Condition == uplow)
     {
      for(int i = rates_total - 1; i >= 0; i--)
        {
         if(MA_Buffer[i] < WPRUP_Buffer[i] && MA_Buffer[i + 1] >= WPRUP_Buffer[i + 1])
            drawArrow(1, i, high, low, time);
         if(MA_Buffer[i] > WPRDN_Buffer[i] && MA_Buffer[i + 1] <= WPRDN_Buffer[i + 1])
            drawArrow(2, i, high, low, time);
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(int dir, int bar, const double &high[], const double &low[], const datetime &time[])
  {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(dir == 0)
     {
      ObjectDelete(0, shortname + "_u_" + IntegerToString(bar));
      ObjectDelete(0, shortname + "_d_" + IntegerToString(bar));
     }
   if(dir == 1)
     {
      string objname = shortname + "_u_" + IntegerToString(bar);
      ObjectCreate(0, objname, OBJ_ARROW, 0, time[bar], high[bar] + Arrow_Offset * point);
      ObjectSetInteger(0, objname, OBJPROP_COLOR, Up_Arrow_Color);
      ObjectSetInteger(0, objname, OBJPROP_ARROWCODE, Up_Arrow_Symbol);
      ObjectSetInteger(0, objname, OBJPROP_WIDTH, Arrow_Size);
      ObjectSetInteger(0, objname, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
     }
   if(dir == 2)
     {
      string objname = shortname + "_d_" + IntegerToString(bar);
      ObjectCreate(0, objname, OBJ_ARROW, 0, time[bar], low[bar] - Arrow_Offset * point);
      ObjectSetInteger(0, objname, OBJPROP_COLOR, Down_Arrow_Color);
      ObjectSetInteger(0, objname, OBJPROP_ARROWCODE, Down_Arrow_Symbol);
      ObjectSetInteger(0, objname, OBJPROP_WIDTH, Arrow_Size);
      ObjectSetInteger(0, objname, OBJPROP_ANCHOR, ANCHOR_TOP);
     }
   if(bar == 0)
     {
      if(dir == 1)
        {
         string objname = shortname + "_u_0";
         double new_price = high[bar] + Arrow_Offset * point;
         if(ObjectGetDouble(0, objname, OBJPROP_PRICE) != new_price)
           {
            ObjectSetDouble(0, objname, OBJPROP_PRICE, new_price);
           }
        }
      if(dir == 2)
        {
         string objname = shortname + "_d_0";
         double new_price = low[bar] - Arrow_Offset * point;
         if(ObjectGetDouble(0, objname, OBJPROP_PRICE) != new_price)
           {
            ObjectSetDouble(0, objname, OBJPROP_PRICE, new_price);
           }
        }
     }
  }
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160549#p160549
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
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   |
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        |
// |                                                             Patreon: http://tiny.cc/1ybwxz      |
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     |
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           |
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// +-----------------+----------------------+---------------------------------------------------------+
