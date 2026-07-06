// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        RSIMACD
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161157#p161157
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
BuyMeACoffee:https://tiny.cc/bj7vzj

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

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 clrGray    // MACD Main Line
#property indicator_color2 clrRed     // MACD Signal Line

#property indicator_color3 clrNONE    // Arrow Signal Buffer (1=buy, -1=sell, 0=none)
input int MACD_Fast_EMI = 12;
input int MACD_Slow_EMI = 26;
input int MACD_SMA_Line = 9;
input double RSI_Level_Buy = 10.0;
input double RSI_Level_Sell = 90.0;
input int MaxBars = 1000;
input int NormalizationBars = 300; // Bars for MACD 0-100 normalization
input int ArrowCode_Buy = 233;
input int ArrowCode_Sell = 234;
input int ArrowSize = 2;
input int ArrowOffset = 20;
input color ArrowColor_Buy = clrGreen; // object arrow buy color
input color ArrowColor_Sell = clrRed;  // object arrow sell color
double MACD_Main_Buffer[];
double MACD_Signal_Buffer[];
double Arrow_Signal_Buffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, MACD_Main_Buffer);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrGray);
   SetIndexLabel(0, "MACD Main");
   SetIndexBuffer(1, MACD_Signal_Buffer);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, clrRed);
   SetIndexLabel(1, "MACD Signal");
   SetIndexBuffer(2, Arrow_Signal_Buffer);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexLabel(2, "Arrow Signal");
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, RSI_Level_Buy);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, RSI_Level_Sell);
   IndicatorSetInteger(INDICATOR_LEVELS, 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "RSI+MACD Signals");
   IndicatorDigits(2);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int total = ObjectsTotal(ChartID(), 0, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(ChartID(), i, 0, -1);
      if(StringFind(name, "RSIMACD_") >= 0)
        {
         ObjectDelete(ChartID(), name);
        }
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
   static int tick_count = 0;
   tick_count++;
   static bool prevBelowBuy = false;
   static bool prevAboveSell = false;
   static double saved_min = 0;
   static double saved_max = 0;
   static bool initialized = false;
   if(prev_calculated == 0)
     {
      prevBelowBuy = false;
      prevAboveSell = false;
     }
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;
   int bars_to_calc = MathMin(rates_total, MaxBars);
   if(limit > bars_to_calc)
      limit = bars_to_calc;
   int calc_bars = MathMin(rates_total, MaxBars);
   for(int i = calc_bars - 1; i >= 0; i--)
     {
      MACD_Main_Buffer[i] = iMACD(NULL, 0, MACD_Fast_EMI, MACD_Slow_EMI, MACD_SMA_Line, PRICE_CLOSE, MODE_MAIN, i);
      MACD_Signal_Buffer[i] = iMACD(NULL, 0, MACD_Fast_EMI, MACD_Slow_EMI, MACD_SMA_Line, PRICE_CLOSE, MODE_SIGNAL, i);
     }
   int norm_bars = MathMin(calc_bars, NormalizationBars);
   double macd_min = saved_min;
   double macd_max = saved_max;
   if(!initialized || prev_calculated == 0)
     {
      macd_min = DBL_MAX;
      macd_max = -DBL_MAX;
      for(int i = 0; i < norm_bars; i++)
        {
         if(MACD_Main_Buffer[i] < macd_min)
            macd_min = MACD_Main_Buffer[i];
         if(MACD_Main_Buffer[i] > macd_max)
            macd_max = MACD_Main_Buffer[i];
         if(MACD_Signal_Buffer[i] < macd_min)
            macd_min = MACD_Signal_Buffer[i];
         if(MACD_Signal_Buffer[i] > macd_max)
            macd_max = MACD_Signal_Buffer[i];
        }
      saved_min = macd_min;
      saved_max = macd_max;
      initialized = true;
     }
   double macd_range = macd_max - macd_min;
   if(macd_range == 0)
      macd_range = 1;
   for(int i = calc_bars - 1; i >= 0; i--)
     {
      double macd_main_norm = ((MACD_Main_Buffer[i] - macd_min) / macd_range) * 100.0;
      double macd_signal_norm = ((MACD_Signal_Buffer[i] - macd_min) / macd_range) * 100.0;
      if(macd_main_norm < 0)
         macd_main_norm = 0;
      if(macd_main_norm > 100)
         macd_main_norm = 100;
      if(macd_signal_norm < 0)
         macd_signal_norm = 0;
      if(macd_signal_norm > 100)
         macd_signal_norm = 100;
      MACD_Main_Buffer[i] = macd_main_norm;
      MACD_Signal_Buffer[i] = macd_signal_norm;
      if(tick_count <= 3 && i == 0)
        {
         Print("Bar[0] MACD_Main=", MACD_Main_Buffer[0],
               " MACD_Signal=", MACD_Signal_Buffer[0],
               " Range=", macd_range);
        }
     }
   for(int i = limit - 1; i >= 0; i--)
     {
      Arrow_Signal_Buffer[i] = 0;
      bool aboveSell = (MACD_Signal_Buffer[i] > RSI_Level_Sell);
      bool belowBuy  = (MACD_Signal_Buffer[i] < RSI_Level_Buy);
      if(aboveSell && !prevAboveSell)
        {
         Arrow_Signal_Buffer[i] = -1;
         string name = StringFormat("RSIMACD_SELL_%d", iTime(NULL, 0, i));
         if(ObjectFind(ChartID(), name) < 0)
           {
            ObjectCreate(ChartID(), name, OBJ_ARROW, 0, iTime(NULL, 0, i), iHigh(NULL, 0, i) + ArrowOffset * Point());
            ObjectSetInteger(ChartID(), name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
            ObjectSetInteger(ChartID(), name, OBJPROP_COLOR, ArrowColor_Sell);
            ObjectSetInteger(ChartID(), name, OBJPROP_WIDTH, ArrowSize);
            ObjectSetInteger(ChartID(), name, OBJPROP_ARROWCODE, ArrowCode_Sell);
            ObjectSetInteger(ChartID(), name, OBJPROP_BACK, false);
            Print("SELL ARROW CREATED: ", name, " at ", iTime(NULL, 0, i), " price=", iHigh(NULL, 0, i) + ArrowOffset * Point());
            ChartRedraw();
           }
        }
      if(belowBuy && !prevBelowBuy)
        {
         Arrow_Signal_Buffer[i] = 1;
         string name2 = StringFormat("RSIMACD_BUY_%d", iTime(NULL, 0, i));
         if(ObjectFind(ChartID(), name2) < 0)
           {
            ObjectCreate(ChartID(), name2, OBJ_ARROW, 0, iTime(NULL, 0, i), iLow(NULL, 0, i) - ArrowOffset * Point());
            ObjectSetInteger(ChartID(), name2, OBJPROP_ANCHOR, ANCHOR_TOP);
            ObjectSetInteger(ChartID(), name2, OBJPROP_COLOR, ArrowColor_Buy);
            ObjectSetInteger(ChartID(), name2, OBJPROP_WIDTH, ArrowSize);
            ObjectSetInteger(ChartID(), name2, OBJPROP_ARROWCODE, ArrowCode_Buy);
            ObjectSetInteger(ChartID(), name2, OBJPROP_BACK, false);
            Print("BUY ARROW CREATED: ", name2, " at ", iTime(NULL, 0, i), " price=", iLow(NULL, 0, i) - ArrowOffset * Point());
            ChartRedraw();
           }
        }
      prevAboveSell = aboveSell;
      prevBelowBuy  = belowBuy;
     }
   return(rates_total);
  }

// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        RSIMACD
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161157#p161157
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
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
