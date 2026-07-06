// -- Project -------------------------------------------------------------------------------
/*
Name:        Kurutoga_Histogram
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76378
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

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
#property indicator_label1  "LTF Divergence"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
#property indicator_label2  "HTF Divergence"
input int BaseLength = 14;           // Base Length
input ENUM_TIMEFRAMES HigherTF = PERIOD_D1; // Higher Time Frame
input int LTFTransparency = 10;      // LTF Transparency (0-100)
input int HTFMinTransparency = 60;   // HTF Min Transparency (0-100)
input int HTFMaxTransparency = 90;   // HTF Max Transparency (0-100)
double LTFDivergenceBuffer[];
double HTFDivergenceBuffer[];
double htfHighArray[];
double htfLowArray[];
double htfDivergenceHistory[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, LTFDivergenceBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HTFDivergenceBuffer, INDICATOR_DATA);
   ArraySetAsSeries(LTFDivergenceBuffer, true);
   ArraySetAsSeries(HTFDivergenceBuffer, true);
   PlotIndexSetString(0, PLOT_LABEL, "LTF Divergence");
   PlotIndexSetString(1, PLOT_LABEL, "HTF Divergence");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrDodgerBlue);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   ArrayResize(htfHighArray, 1000);
   ArrayResize(htfLowArray, 1000);
   ArrayResize(htfDivergenceHistory, 1000);
   ArrayInitialize(htfHighArray, 0);
   ArrayInitialize(htfLowArray, 0);
   ArrayInitialize(htfDivergenceHistory, 0);
   ArraySetAsSeries(htfHighArray, true);
   ArraySetAsSeries(htfLowArray, true);
   ArraySetAsSeries(htfDivergenceHistory, true);
   IndicatorSetString(INDICATOR_SHORTNAME, "Kurutoga Histogram HTF(" + EnumToString(HigherTF) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcMidpoint(double high_val, double low_val)
  {
   return (high_val + low_val) / 2.0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetHighest(const double &array[], int period, int start_pos)
  {
   double highest = -DBL_MAX;
   for(int i = start_pos; i < start_pos + period; i++)
     {
      if(i >= ArraySize(array))
         break;
      if(array[i] > highest)
         highest = array[i];
     }
   return highest;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLowest(const double &array[], int period, int start_pos)
  {
   double lowest = DBL_MAX;
   for(int i = start_pos; i < start_pos + period; i++)
     {
      if(i >= ArraySize(array))
         break;
      if(array[i] < lowest)
         lowest = array[i];
     }
   return lowest;
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
   ArraySetAsSeries(LTFDivergenceBuffer, true);
   ArraySetAsSeries(HTFDivergenceBuffer, true);
   if(rates_total < BaseLength)
      return(0);
   int start = prev_calculated;
   if(start == 0)
      start = BaseLength;
   int limit = rates_total - prev_calculated;
   if(prev_calculated == 0)
      limit = rates_total - BaseLength;
   for(int i = 0; i < limit; i++)
     {
      double cur_high = GetHighest(high, BaseLength, i);
      double cur_low = GetLowest(low, BaseLength, i);
      double cur_midpoint = CalcMidpoint(cur_high, cur_low);
      double ltf_divergence = close[i] - cur_midpoint;
      int htf_shift = iBarShift(Symbol(), HigherTF, time[i], false);
      double htf_high_array[];
      double htf_low_array[];
      ArraySetAsSeries(htf_high_array, true);
      ArraySetAsSeries(htf_low_array, true);
      int copied_high = CopyHigh(Symbol(), HigherTF, htf_shift, BaseLength, htf_high_array);
      int copied_low = CopyLow(Symbol(), HigherTF, htf_shift, BaseLength, htf_low_array);
      double htf_high_max = -DBL_MAX;
      double htf_low_min = DBL_MAX;
      if(copied_high > 0 && copied_low > 0)
        {
         for(int j = 0; j < copied_high; j++)
           {
            if(htf_high_array[j] > htf_high_max)
               htf_high_max = htf_high_array[j];
           }
         for(int j = 0; j < copied_low; j++)
           {
            if(htf_low_array[j] < htf_low_min)
               htf_low_min = htf_low_array[j];
           }
        }
      double higher_midpoint = CalcMidpoint(htf_high_max, htf_low_min);
      double htf_divergence = close[i] - higher_midpoint;
      LTFDivergenceBuffer[i] = ltf_divergence;
      HTFDivergenceBuffer[i] = htf_divergence;
      if(i < ArraySize(htfDivergenceHistory))
         htfDivergenceHistory[i] = MathAbs(htf_divergence);
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetMaxHTFDivergence(int lookback_period)
  {
   double max_val = 0;
   int start_idx = MathMax(0, ArraySize(htfDivergenceHistory) - lookback_period);
   for(int i = start_idx; i < ArraySize(htfDivergenceHistory); i++)
     {
      if(htfDivergenceHistory[i] > max_val)
         max_val = htfDivergenceHistory[i];
     }
   return max_val;
  }
//+------------------------------------------------------------------+
// -- Project -------------------------------------------------------------------------------
/*
Name:        Kurutoga_Histogram
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76378
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