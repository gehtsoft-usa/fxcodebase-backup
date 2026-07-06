/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        FVG_Rejection
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=161376#p161376
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
#property indicator_buffers 2
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_width1 2
#property indicator_width2 2
input int    ArrowSize   = 2;           // Arrow size
input int    ArrowOffset = 20;          // Arrow offset (points from candle)
input color  UpColor     = clrGreen;    // Bullish arrow color
input color  DownColor   = clrRed;      // Bearish arrow color
input int    FVG_Validity = 20;         // FVG validity (bars, 0=unlimited)
input bool   ShowFVGZones = true;       // Show FVG zones as rectangles
double UpArrowBuffer[];
double DownArrowBuffer[];
struct FVG_Data
  {
   double            high;
   double            low;
   int               start_bar;
   bool              used;
   string            box_name;
  };
#define MAX_FVG 500
FVG_Data bullish_fvg[MAX_FVG];
FVG_Data bearish_fvg[MAX_FVG];
int bullish_count = 0;
int bearish_count = 0;
int debug_tick_count = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, UpArrowBuffer);
   SetIndexBuffer(1, DownArrowBuffer);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   ArrayInitialize(UpArrowBuffer, EMPTY_VALUE);
   ArrayInitialize(DownArrowBuffer, EMPTY_VALUE);
   for(int i = 0; i < MAX_FVG; i++)
     {
      bullish_fvg[i].high = 0;
      bullish_fvg[i].low = 0;
      bullish_fvg[i].start_bar = -1;
      bullish_fvg[i].used = false;
      bullish_fvg[i].box_name = "";
      bearish_fvg[i].high = 0;
      bearish_fvg[i].low = 0;
      bearish_fvg[i].start_bar = -1;
      bearish_fvg[i].used = false;
      bearish_fvg[i].box_name = "";
     }
   bullish_count = 0;
   bearish_count = 0;
   IndicatorShortName("FVG Rejection");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i = 0; i < bullish_count; i++)
     {
      if(bullish_fvg[i].box_name != "")
         ObjectDelete(0, bullish_fvg[i].box_name);
     }
   for(int i = 0; i < bearish_count; i++)
     {
      if(bearish_fvg[i].box_name != "")
         ObjectDelete(0, bearish_fvg[i].box_name);
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
   int limit;
   if(prev_calculated == 0)
     {
      limit = rates_total - 3;
      ArrayInitialize(UpArrowBuffer, EMPTY_VALUE);
      ArrayInitialize(DownArrowBuffer, EMPTY_VALUE);
      bullish_count = 0;
      bearish_count = 0;
      for(int i = 0; i < MAX_FVG; i++)
        {
         if(bullish_fvg[i].box_name != "")
            ObjectDelete(0, bullish_fvg[i].box_name);
         if(bearish_fvg[i].box_name != "")
            ObjectDelete(0, bearish_fvg[i].box_name);
         bullish_fvg[i].start_bar = -1;
         bullish_fvg[i].used = false;
         bullish_fvg[i].box_name = "";
         bearish_fvg[i].start_bar = -1;
         bearish_fvg[i].used = false;
         bearish_fvg[i].box_name = "";
        }
     }
   else
     {
      limit = rates_total - prev_calculated;
     }
   for(int i = limit; i >= 0; i--)
     {
      if(i >= rates_total - 3)
         continue;
      if(low[i + 2] > high[i])
        {
         if(bullish_count >= MAX_FVG)
           {
            Print("WARNING: Bullish FVG array full, resetting...");
            for(int k = 0; k < MAX_FVG; k++)
              {
               if(bullish_fvg[k].box_name != "")
                  ObjectDelete(0, bullish_fvg[k].box_name);
               bullish_fvg[k].start_bar = -1;
               bullish_fvg[k].used = false;
               bullish_fvg[k].box_name = "";
              }
            bullish_count = 0;
           }
         if(bullish_count < MAX_FVG)
           {
            bullish_fvg[bullish_count].high = low[i + 2];
            bullish_fvg[bullish_count].low = high[i];
            bullish_fvg[bullish_count].start_bar = i + 1;
            bullish_fvg[bullish_count].used = false;
            if(ShowFVGZones)
              {
               string box_name = "FVG_BULL_" + IntegerToString(i + 1) + "_" + TimeToString(time[i + 1], TIME_DATE | TIME_SECONDS);
               bullish_fvg[bullish_count].box_name = box_name;
               ObjectCreate(0, box_name, OBJ_RECTANGLE, 0, time[i + 2], bullish_fvg[bullish_count].low, time[i], bullish_fvg[bullish_count].high);
               ObjectSetInteger(0, box_name, OBJPROP_COLOR, clrGreen);
               ObjectSetInteger(0, box_name, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, box_name, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, box_name, OBJPROP_BACK, true);
               ObjectSetInteger(0, box_name, OBJPROP_FILL, false);
               ObjectSetInteger(0, box_name, OBJPROP_RAY_RIGHT, false);
               ObjectSetInteger(0, box_name, OBJPROP_SELECTABLE, false);
               Print("BULLISH BOX: ", box_name, " | i=", i, " Time=", TimeToString(time[i + 1]), " | High=", bullish_fvg[bullish_count].high, " Low=", bullish_fvg[bullish_count].low);
              }
            bullish_count++;
           }
        }
      if(high[i + 2] < low[i])
        {
         if(bearish_count >= MAX_FVG)
           {
            Print("WARNING: Bearish FVG array full, resetting...");
            for(int k = 0; k < MAX_FVG; k++)
              {
               if(bearish_fvg[k].box_name != "")
                  ObjectDelete(0, bearish_fvg[k].box_name);
               bearish_fvg[k].start_bar = -1;
               bearish_fvg[k].used = false;
               bearish_fvg[k].box_name = "";
              }
            bearish_count = 0;
           }
         if(bearish_count < MAX_FVG)
           {
            bearish_fvg[bearish_count].high = low[i];
            bearish_fvg[bearish_count].low = high[i + 2];
            bearish_fvg[bearish_count].start_bar = i + 1;
            bearish_fvg[bearish_count].used = false;
            if(ShowFVGZones)
              {
               string box_name = "FVG_BEAR_" + IntegerToString(i + 1) + "_" + TimeToString(time[i + 1], TIME_DATE | TIME_SECONDS);
               bearish_fvg[bearish_count].box_name = box_name;
               ObjectCreate(0, box_name, OBJ_RECTANGLE, 0, time[i + 2], bearish_fvg[bearish_count].low, time[i], bearish_fvg[bearish_count].high);
               ObjectSetInteger(0, box_name, OBJPROP_COLOR, clrRed);
               ObjectSetInteger(0, box_name, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, box_name, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, box_name, OBJPROP_BACK, true);
               ObjectSetInteger(0, box_name, OBJPROP_FILL, false);
               ObjectSetInteger(0, box_name, OBJPROP_RAY_RIGHT, false);
               ObjectSetInteger(0, box_name, OBJPROP_SELECTABLE, false);
               Print("BEARISH BOX: ", box_name, " | i=", i, " Time=", TimeToString(time[i + 1]), " | High=", bearish_fvg[bearish_count].high, " Low=", bearish_fvg[bearish_count].low);
              }
            bearish_count++;
           }
        }
      for(int j = 0; j < bullish_count; j++)
        {
         if(bullish_fvg[j].used)
            continue;
         if(bullish_fvg[j].start_bar < 0)
            continue;
         int bars_since_fvg = bullish_fvg[j].start_bar - i;
         if(FVG_Validity > 0 && bars_since_fvg > FVG_Validity)
           {
            bullish_fvg[j].used = true;
            if(ShowFVGZones && bullish_fvg[j].box_name != "")
               ObjectDelete(0, bullish_fvg[j].box_name);
            continue;
           }
         double candle_low = low[i];
         double candle_open = open[i];
         double candle_close = close[i];
         double body_low = MathMin(candle_open, candle_close);
         bool wick_touches = (candle_low <= bullish_fvg[j].high);
         bool body_above = (body_low > bullish_fvg[j].high);
         bool is_bullish = (candle_close > candle_open);
         if(wick_touches && body_above && is_bullish)
           {
            UpArrowBuffer[i] = low[i] - ArrowOffset * Point;
            bullish_fvg[j].used = true;
            Print(">>> BULLISH ARROW at i=", i, " Time=", TimeToString(time[i]), " FVG#", j);
           }
        }
      for(int j = 0; j < bearish_count; j++)
        {
         if(bearish_fvg[j].used)
            continue;
         if(bearish_fvg[j].start_bar < 0)
            continue;
         int bars_since_fvg = bearish_fvg[j].start_bar - i;
         if(FVG_Validity > 0 && bars_since_fvg > FVG_Validity)
           {
            bearish_fvg[j].used = true;
            if(ShowFVGZones && bearish_fvg[j].box_name != "")
               ObjectDelete(0, bearish_fvg[j].box_name);
            continue;
           }
         double candle_high = high[i];
         double candle_open = open[i];
         double candle_close = close[i];
         double body_high = MathMax(candle_open, candle_close);
         bool wick_touches = (candle_high >= bearish_fvg[j].low);
         bool body_below = (body_high < bearish_fvg[j].low);
         bool is_bearish = (candle_close < candle_open);
         if(wick_touches && body_below && is_bearish)
           {
            DownArrowBuffer[i] = high[i] + ArrowOffset * Point;
            bearish_fvg[j].used = true;
            Print(">>> BEARISH ARROW at i=", i, " Time=", TimeToString(time[i]), " FVG#", j);
           }
        }
     }
   return(rates_total);
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        FVG_Rejection
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=161376#p161376
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
