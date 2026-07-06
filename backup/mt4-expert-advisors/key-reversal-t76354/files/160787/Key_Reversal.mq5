// -- Project -------------------------------------------------------------------------------
/*
Name:        Key_Reversal
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76354
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
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label1  "Line Up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label2  "Line Dn"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrBlue
#property indicator_width3  1
#property indicator_label3  "Arrow Up"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  1
#property indicator_label4  "Arrow Dn"
double ArrowUp[];
double ArrowDn[];
double LineUp[];
double LineDn[];
enum gap_filter_type { no_filter, wopag, wpag };
input gap_filter_type gap_filter = no_filter;
input int    Lookback_Period       = 2;
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT5 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                // Push Mobile Notifications
input string T2                    = "== Set Lines ==";     // === Set  Lines ===
input bool   LinesOn               = true;                  // Line On?
input color  LineUpClr             = clrBlue;               // Line Up Color:
input color  LineDnClr             = clrRed;                // Line Down Color:
input string T3                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(LineUp, true);
   ArraySetAsSeries(LineDn, true);
   ArraySetAsSeries(ArrowUp, true);
   ArraySetAsSeries(ArrowDn, true);
   SetIndexBuffer(0, LineUp, INDICATOR_DATA);
   SetIndexBuffer(1, LineDn, INDICATOR_DATA);
   SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
   SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);
   if(!LinesOn)
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   if(!ArrowsOn)
     {
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, LineUpClr);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, LineDnClr);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);
   return (INIT_SUCCEEDED);
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
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);
   int limit;
   if(prev_calculated == 0)
     {
      limit = rates_total - Lookback_Period - 1;
      ArrayInitialize(LineUp, EMPTY_VALUE);
      ArrayInitialize(LineDn, EMPTY_VALUE);
      ArrayInitialize(ArrowUp, EMPTY_VALUE);
      ArrayInitialize(ArrowDn, EMPTY_VALUE);
     }
   else
     {
      limit = rates_total - prev_calculated + 1;
     }
   for(int i = limit; i >= 0; i--)
     {
      ArrowUp[i] = EMPTY_VALUE;
      ArrowDn[i] = EMPTY_VALUE;
      LineUp[i] = EMPTY_VALUE;
      LineDn[i] = EMPTY_VALUE;
      if(haveSignalUp(i, open, high, low, close) == 1)
        {
         ArrowUp[i] = low[i];
         LineUp[i] = low[i];
         notify(0, i, time);
        }
      if(haveSignalDown(i, open, high, low, close) == -1)
        {
         ArrowDn[i] = high[i];
         LineDn[i] = high[i];
         notify(1, i, time);
        }
     }
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int haveSignalUp(int i, const double &open[], const double &high[], const double &low[], const double &close[])
  {
   if(i + Lookback_Period >= Bars(_Symbol, _Period))
      return 0;
   double op = open[i];
   double cl2 = close[i + 1];
   int signal = 0;
   if(close[i] > high[i + 1])
      signal = 1;
   if(signal == 1 && gap_filter == wpag)
     {
      if(op >= cl2)
         signal = 0;
     }
   else
      if(signal == 1 && gap_filter == wopag)
        {
         if(op == cl2)
            signal = 0;
        }
   for(int n = 1; n < Lookback_Period; n++)
     {
      if(signal == 1 && close[i + n] > open[i + n])
        {
         signal = 0;
         break;
        }
     }
   return signal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int haveSignalDown(int i, const double &open[], const double &high[], const double &low[], const double &close[])
  {
   if(i + Lookback_Period >= Bars(_Symbol, _Period))
      return 0;
   int signal = 0;
   double op = open[i];
   double cl2 = close[i + 1];
   if(close[i] < low[i + 1])
      signal = -1;
   if(signal == -1 && gap_filter == wpag)
     {
      if(op <= cl2)
         signal = 0;
     }
   else
      if(signal == -1 && gap_filter == wopag)
        {
         if(op == cl2)
            signal = 0;
        }
   for(int n = 1; n < Lookback_Period; n++)
     {
      if(signal == -1 && close[i + n] < open[i + n])
        {
         signal = 0;
         break;
        }
     }
   return signal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void notify(int type, int bar_index, const datetime &time[])
  {
   if(IsNewCandle(bar_index, time))
     {
      Notifications(type);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type)
  {
   string text = "";
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";
   text += " ";
   if(!notifications)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(ENUM_TIMEFRAMES lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M2:
         return ("M2");
      case PERIOD_M3:
         return ("M3");
      case PERIOD_M4:
         return ("M4");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M6:
         return ("M6");
      case PERIOD_M10:
         return ("M10");
      case PERIOD_M12:
         return ("M12");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M20:
         return ("M20");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H2:
         return ("H2");
      case PERIOD_H3:
         return ("H3");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_H6:
         return ("H6");
      case PERIOD_H8:
         return ("H8");
      case PERIOD_H12:
         return ("H12");
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
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle(int bar_index, const datetime &time[])
  {
   if(bar_index != 1)
      return false;
   static datetime last = 0;
   datetime current = time[1];
   if(last != current)
     {
      last = current;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
// -- Project -------------------------------------------------------------------------------
/*
Name:        Key_Reversal
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76354
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