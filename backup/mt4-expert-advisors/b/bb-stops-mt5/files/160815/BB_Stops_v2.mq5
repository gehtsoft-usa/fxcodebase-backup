// -- Project -------------------------------------------------------------------------------
/*
Name:        BB_Stops
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=145433#p145433
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
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Stop Line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "Buy Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_width2  2
#property indicator_label3  "Sell Signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_width3  2
enum MA_TYPE_ENUM
  {
   MA_SMA,        // SMA
   MA_EMA,        // EMA
   MA_WMA,        // WMA
   MA_VWMA,       // VWMA
   MA_SWMA,       // SWMA
   MA_DEMA,       // Double EMA
   MA_TEMA_TYPE,  // Triple EMA
   MA_HULL,       // Hull MA
   MA_TEMA        // TEMA
  };
input group "-------- BB settings --------"
input ENUM_TIMEFRAMES  InpTimeframe = PERIOD_CURRENT; // Timeframe (MTF)
input MA_TYPE_ENUM InpMAType = MA_WMA;          // Base MA Type
input int          InpLength = 20;              // MA Length
input ENUM_APPLIED_PRICE InpPrice = PRICE_TYPICAL; // Source Price
input double       InpMultiplier = 1.0;         // Band Multiplier
input color        InpColorUp = clrGreen;       // Up Color
input color        InpColorDn = clrRed;         // Down Color
input bool         InpFillArea = true;          // Fill Stop Area
input color        InpColorUpStop = 0x6EC071;   // Up Stop Area Color
input color        InpColorDnStop = 0xFF8585;   // Down Stop Area Color
input group "---------- Alerts ----------"
input bool         InpBuyAlert = true;          // Enable Buy Alert
input string       InpBuyAlertMsg = "Buy alert"; // Buy Alert Message
input bool         InpSellAlert = true;         // Enable Sell Alert
input string       InpSellAlertMsg = "Sell alert"; // Sell Alert Message
double StopLineBuffer[];
double StopLineColorBuffer[];
double BuySignalBuffer[];
double SellSignalBuffer[];
double UpperBandBuffer[];
bool   g_down = false;
bool   g_up = false;
int    g_rates_total_prev = 0;
string g_symbol;
ENUM_TIMEFRAMES g_timeframe;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_symbol = _Symbol;
   g_timeframe = (InpTimeframe == PERIOD_CURRENT) ? _Period : InpTimeframe;
   SetIndexBuffer(0, StopLineBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, StopLineColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, BuySignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, SellSignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, UpperBandBuffer, INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   PlotIndexSetInteger(2, PLOT_ARROW, 234);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
   string timeframe_str = "";
   if(InpTimeframe != PERIOD_CURRENT)
      timeframe_str = " [" + StringSubstr(EnumToString(g_timeframe), 7) + "]";
   IndicatorSetString(INDICATOR_SHORTNAME, "BB Stops" + timeframe_str);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
   ArraySetAsSeries(StopLineBuffer, true);
   ArraySetAsSeries(StopLineColorBuffer, true);
   ArraySetAsSeries(BuySignalBuffer, true);
   ArraySetAsSeries(SellSignalBuffer, true);
   ArraySetAsSeries(UpperBandBuffer, true);
   return(INIT_SUCCEEDED);
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
   datetime mtf_time[];
   double mtf_open[], mtf_high[], mtf_low[], mtf_close[];
   long mtf_volume[];
   int mtf_bars = 0;
   if(g_timeframe != _Period)
     {
      mtf_bars = Bars(g_symbol, g_timeframe);
      if(mtf_bars < InpLength)
         return(0);
      ArraySetAsSeries(mtf_time, true);
      ArraySetAsSeries(mtf_open, true);
      ArraySetAsSeries(mtf_high, true);
      ArraySetAsSeries(mtf_low, true);
      ArraySetAsSeries(mtf_close, true);
      ArraySetAsSeries(mtf_volume, true);
      if(CopyTime(g_symbol, g_timeframe, 0, mtf_bars, mtf_time) <= 0)
         return(0);
      if(CopyOpen(g_symbol, g_timeframe, 0, mtf_bars, mtf_open) <= 0)
         return(0);
      if(CopyHigh(g_symbol, g_timeframe, 0, mtf_bars, mtf_high) <= 0)
         return(0);
      if(CopyLow(g_symbol, g_timeframe, 0, mtf_bars, mtf_low) <= 0)
         return(0);
      if(CopyClose(g_symbol, g_timeframe, 0, mtf_bars, mtf_close) <= 0)
         return(0);
      if(CopyTickVolume(g_symbol, g_timeframe, 0, mtf_bars, mtf_volume) <= 0)
         return(0);
     }
   else
     {
      mtf_bars = rates_total;
      ArrayResize(mtf_time, rates_total);
      ArrayResize(mtf_open, rates_total);
      ArrayResize(mtf_high, rates_total);
      ArrayResize(mtf_low, rates_total);
      ArrayResize(mtf_close, rates_total);
      ArrayResize(mtf_volume, rates_total);
      ArraySetAsSeries(mtf_time, true);
      ArraySetAsSeries(mtf_open, true);
      ArraySetAsSeries(mtf_high, true);
      ArraySetAsSeries(mtf_low, true);
      ArraySetAsSeries(mtf_close, true);
      ArraySetAsSeries(mtf_volume, true);
      ArrayCopy(mtf_time, time);
      ArrayCopy(mtf_open, open);
      ArrayCopy(mtf_high, high);
      ArrayCopy(mtf_low, low);
      ArrayCopy(mtf_close, close);
      ArrayCopy(mtf_volume, tick_volume);
     }
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(time, true);
   if(mtf_bars < InpLength)
      return(0);
   int start_pos = 0;
   if(prev_calculated == 0 || rates_total != g_rates_total_prev)
     {
      start_pos = rates_total - 1;
      g_rates_total_prev = rates_total;
      ArrayInitialize(StopLineBuffer, 0.0);
      ArrayInitialize(StopLineColorBuffer, 0);
      ArrayInitialize(BuySignalBuffer, 0.0);
      ArrayInitialize(SellSignalBuffer, 0.0);
      g_down = false;
      g_up = false;
     }
   else
     {
      start_pos = rates_total - prev_calculated;
     }
   for(int i = start_pos; i >= 0; i--)
     {
      int mtf_bar = iBarShift(g_symbol, g_timeframe, time[i]);
      if(mtf_bar < 0 || mtf_bar >= mtf_bars)
         continue;
      double src = GetSourcePriceMTF(mtf_bar, mtf_open, mtf_high, mtf_low, mtf_close);
      double basis = CalculateMAMTF(mtf_bar, mtf_bars, mtf_open, mtf_high, mtf_low, mtf_close, mtf_volume);
      double dev = InpMultiplier * CalculateStdDevMTF(mtf_bar, mtf_bars, mtf_open, mtf_high, mtf_low, mtf_close);
      double upper = basis + dev;
      double lower = basis - dev;
      UpperBandBuffer[i] = upper;
      bool crossover_up = false;
      bool crossunder_down = false;
      if(i < rates_total - 1)
        {
         int mtf_bar_prev = iBarShift(g_symbol, g_timeframe, time[i + 1]);
         if(mtf_bar_prev >= 0 && mtf_bar_prev < mtf_bars)
           {
            double src_prev = GetSourcePriceMTF(mtf_bar_prev, mtf_open, mtf_high, mtf_low, mtf_close);
            double upper_prev = UpperBandBuffer[i + 1];
            double basis_prev = CalculateMAMTF(mtf_bar_prev, mtf_bars, mtf_open, mtf_high, mtf_low, mtf_close, mtf_volume);
            double dev_prev = InpMultiplier * CalculateStdDevMTF(mtf_bar_prev, mtf_bars, mtf_open, mtf_high, mtf_low, mtf_close);
            double lower_prev = basis_prev - dev_prev;
            crossover_up = (src > upper && src_prev <= upper_prev);
            crossunder_down = (src < lower && src_prev >= lower_prev);
           }
        }
      if(crossover_up)
        {
         g_up = true;
         g_down = false;
        }
      if(crossunder_down)
        {
         g_up = false;
         g_down = true;
        }
      double stop_line = 0.0;
      if(g_up)
         stop_line = lower;
      else
         if(g_down)
            stop_line = upper;
      StopLineBuffer[i] = stop_line;
      if(stop_line == upper)
         StopLineColorBuffer[i] = 1;
      else
         StopLineColorBuffer[i] = 0;
      bool change_up = false;
      bool change_down = false;
      if(i < rates_total - 1)
        {
         bool prev_down = (StopLineBuffer[i + 1] == UpperBandBuffer[i + 1]);
         bool prev_up = !prev_down;
         change_up = prev_down && g_up;
         change_down = prev_up && g_down;
        }
      BuySignalBuffer[i] = 0.0;
      SellSignalBuffer[i] = 0.0;
      if(change_up)
        {
         BuySignalBuffer[i] = lower;
         if(InpBuyAlert && i == 0)
            Alert(InpBuyAlertMsg);
        }
      if(change_down)
        {
         SellSignalBuffer[i] = upper;
         if(InpSellAlert && i == 0)
            Alert(InpSellAlertMsg);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSourcePrice(int shift, const double &open[], const double &high[],
                      const double &low[], const double &close[])
  {
   switch(InpPrice)
     {
      case PRICE_CLOSE:
         return close[shift];
      case PRICE_OPEN:
         return open[shift];
      case PRICE_HIGH:
         return high[shift];
      case PRICE_LOW:
         return low[shift];
      case PRICE_MEDIAN:
         return (high[shift] + low[shift]) / 2.0;
      case PRICE_TYPICAL:
         return (high[shift] + low[shift] + close[shift]) / 3.0;
      case PRICE_WEIGHTED:
         return (high[shift] + low[shift] + close[shift] * 2.0) / 4.0;
     }
   return close[shift];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMA(int shift, int rates_total, const double &open[],
                   const double &high[], const double &low[],
                   const double &close[], const long &volume[])
  {
   double result = 0.0;
   switch(InpMAType)
     {
      case MA_SMA:
         result = CalculateSMA(shift, rates_total, open, high, low, close);
         break;
      case MA_EMA:
         result = CalculateEMA(shift, rates_total, open, high, low, close);
         break;
      case MA_WMA:
         result = CalculateWMA(shift, rates_total, open, high, low, close);
         break;
      case MA_VWMA:
         result = CalculateVWMA(shift, rates_total, open, high, low, close, volume);
         break;
      case MA_SWMA:
         result = CalculateSWMA(shift, open, high, low, close);
         break;
      case MA_DEMA:
         result = CalculateDEMA(shift, rates_total, open, high, low, close);
         break;
      case MA_TEMA_TYPE:
         result = CalculateTripleEMA(shift, rates_total, open, high, low, close);
         break;
      case MA_HULL:
         result = CalculateHullMA(shift, rates_total, open, high, low, close);
         break;
      case MA_TEMA:
         result = CalculateTEMA(shift, rates_total, open, high, low, close);
         break;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateSMA(int shift, int rates_total, const double &open[],
                    const double &high[], const double &low[], const double &close[])
  {
   if(shift + InpLength > rates_total)
      return 0.0;
   double sum = 0.0;
   for(int i = 0; i < InpLength; i++)
     {
      sum += GetSourcePrice(shift + i, open, high, low, close);
     }
   return sum / InpLength;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(int shift, int rates_total, const double &open[],
                    const double &high[], const double &low[], const double &close[])
  {
   static double prev_ema = 0.0;
   double alpha = 2.0 / (InpLength + 1.0);
   if(shift >= rates_total - InpLength)
     {
      prev_ema = CalculateSMA(shift, rates_total, open, high, low, close);
      return prev_ema;
     }
   double src = GetSourcePrice(shift, open, high, low, close);
   double ema = alpha * src + (1.0 - alpha) * prev_ema;
   prev_ema = ema;
   return ema;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateWMA(int shift, int rates_total, const double &open[],
                    const double &high[], const double &low[], const double &close[])
  {
   if(shift + InpLength > rates_total)
      return 0.0;
   double sum = 0.0;
   double weight_sum = 0.0;
   for(int i = 0; i < InpLength; i++)
     {
      int weight = InpLength - i;
      sum += GetSourcePrice(shift + i, open, high, low, close) * weight;
      weight_sum += weight;
     }
   return sum / weight_sum;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateVWMA(int shift, int rates_total, const double &open[],
                     const double &high[], const double &low[],
                     const double &close[], const long &volume[])
  {
   if(shift + InpLength > rates_total)
      return 0.0;
   double sum = 0.0;
   double volume_sum = 0.0;
   for(int i = 0; i < InpLength; i++)
     {
      double vol = (double)volume[shift + i];
      if(vol == 0)
         vol = 1.0;
      sum += GetSourcePrice(shift + i, open, high, low, close) * vol;
      volume_sum += vol;
     }
   return (volume_sum > 0) ? sum / volume_sum : 0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateSWMA(int shift, const double &open[], const double &high[],
                     const double &low[], const double &close[])
  {
   double w1 = GetSourcePrice(shift + 3, open, high, low, close) * 1.0;
   double w2 = GetSourcePrice(shift + 2, open, high, low, close) * 2.0;
   double w3 = GetSourcePrice(shift + 1, open, high, low, close) * 2.0;
   double w4 = GetSourcePrice(shift, open, high, low, close) * 1.0;
   return (w1 + w2 + w3 + w4) / 6.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateDEMA(int shift, int rates_total, const double &open[],
                     const double &high[], const double &low[], const double &close[])
  {
   static double ema1_values[];
   static int prev_calculated_dema = 0;
   if(shift >= rates_total - InpLength || prev_calculated_dema == 0)
     {
      ArrayResize(ema1_values, rates_total);
      ArraySetAsSeries(ema1_values, true);
      prev_calculated_dema = rates_total;
     }
   double alpha = 2.0 / (InpLength + 1.0);
   if(shift >= rates_total - InpLength)
     {
      ema1_values[shift] = CalculateSMA(shift, rates_total, open, high, low, close);
     }
   else
     {
      double src = GetSourcePrice(shift, open, high, low, close);
      ema1_values[shift] = alpha * src + (1.0 - alpha) * ema1_values[shift + 1];
     }
   double ema2;
   if(shift >= rates_total - InpLength * 2)
     {
      double sum = 0.0;
      for(int i = 0; i < InpLength && (shift + i) < rates_total; i++)
        {
         sum += ema1_values[shift + i];
        }
      ema2 = sum / InpLength;
     }
   else
     {
      static double prev_ema2 = 0.0;
      ema2 = alpha * ema1_values[shift] + (1.0 - alpha) * prev_ema2;
      prev_ema2 = ema2;
     }
   return ema2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTripleEMA(int shift, int rates_total, const double &open[],
                          const double &high[], const double &low[], const double &close[])
  {
   return CalculateDEMA(shift, rates_total, open, high, low, close);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateHullMA(int shift, int rates_total, const double &open[],
                       const double &high[], const double &low[], const double &close[])
  {
   int half_length = InpLength / 2;
   int sqrt_length = (int)MathSqrt(InpLength);
   if(shift + InpLength > rates_total)
      return 0.0;
   double wma_half = 0.0;
   double weight_sum_half = 0.0;
   for(int i = 0; i < half_length && (shift + i) < rates_total; i++)
     {
      int weight = half_length - i;
      wma_half += GetSourcePrice(shift + i, open, high, low, close) * weight;
      weight_sum_half += weight;
     }
   if(weight_sum_half > 0)
      wma_half /= weight_sum_half;
   double wma_full = CalculateWMA(shift, rates_total, open, high, low, close);
   double raw_hull = 2.0 * wma_half - wma_full;
   return raw_hull;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTEMA(int shift, int rates_total, const double &open[],
                     const double &high[], const double &low[], const double &close[])
  {
   static double ema1_values[], ema2_values[], ema3_values[];
   static int prev_calc_tema = 0;
   if(shift >= rates_total - InpLength || prev_calc_tema == 0)
     {
      ArrayResize(ema1_values, rates_total);
      ArrayResize(ema2_values, rates_total);
      ArrayResize(ema3_values, rates_total);
      ArraySetAsSeries(ema1_values, true);
      ArraySetAsSeries(ema2_values, true);
      ArraySetAsSeries(ema3_values, true);
      prev_calc_tema = rates_total;
     }
   double alpha = 2.0 / (InpLength + 1.0);
   if(shift >= rates_total - InpLength)
     {
      ema1_values[shift] = CalculateSMA(shift, rates_total, open, high, low, close);
     }
   else
     {
      double src = GetSourcePrice(shift, open, high, low, close);
      ema1_values[shift] = alpha * src + (1.0 - alpha) * ema1_values[shift + 1];
     }
   if(shift >= rates_total - InpLength * 2)
     {
      ema2_values[shift] = ema1_values[shift];
     }
   else
     {
      ema2_values[shift] = alpha * ema1_values[shift] + (1.0 - alpha) * ema2_values[shift + 1];
     }
   if(shift >= rates_total - InpLength * 3)
     {
      ema3_values[shift] = ema2_values[shift];
     }
   else
     {
      ema3_values[shift] = alpha * ema2_values[shift] + (1.0 - alpha) * ema3_values[shift + 1];
     }
   return 3.0 * (ema1_values[shift] - ema2_values[shift]) + ema3_values[shift];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateStdDev(int shift, int rates_total, const double &open[],
                       const double &high[], const double &low[], const double &close[])
  {
   if(shift + InpLength > rates_total)
      return 0.0;
   double mean = CalculateSMA(shift, rates_total, open, high, low, close);
   double variance = 0.0;
   for(int i = 0; i < InpLength; i++)
     {
      double diff = GetSourcePrice(shift + i, open, high, low, close) - mean;
      variance += diff * diff;
     }
   variance /= InpLength;
   return MathSqrt(variance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSourcePriceMTF(int shift, const double &open[], const double &high[],
                         const double &low[], const double &close[])
  {
   switch(InpPrice)
     {
      case PRICE_CLOSE:
         return close[shift];
      case PRICE_OPEN:
         return open[shift];
      case PRICE_HIGH:
         return high[shift];
      case PRICE_LOW:
         return low[shift];
      case PRICE_MEDIAN:
         return (high[shift] + low[shift]) / 2.0;
      case PRICE_TYPICAL:
         return (high[shift] + low[shift] + close[shift]) / 3.0;
      case PRICE_WEIGHTED:
         return (high[shift] + low[shift] + close[shift] * 2.0) / 4.0;
     }
   return close[shift];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMAMTF(int shift, int bars_total, const double &open[],
                      const double &high[], const double &low[],
                      const double &close[], const long &volume[])
  {
   return CalculateMA(shift, bars_total, open, high, low, close, volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateStdDevMTF(int shift, int bars_total, const double &open[],
                          const double &high[], const double &low[], const double &close[])
  {
   return CalculateStdDev(shift, bars_total, open, high, low, close);
  }
//+------------------------------------------------------------------+
// -- Project -------------------------------------------------------------------------------
/*
Name:        BB_Stops
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=145433#p145433
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