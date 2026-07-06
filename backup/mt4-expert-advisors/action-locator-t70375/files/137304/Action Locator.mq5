// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=27&t=70158
// -------------------------------------------------------------------------------------------
// 
//     BERLIN Renegade
//     ACTION Locator
//     Version 2.8
// 
// -------------------------------------------------------------------------------------------
// 
// This is the volatility and range identifying part of a larger algorithm called the
// "BERLIN Renegade". It is based on the NNFX way of trading, with some modifications.
// 
// The indicator is based on making the standard deviation (where the mean is a moving
// average) a two-lines cross indicator, by applying an MA over it.
// 
// When the standard deviation is above the MA, there is considered to be enough volatility
// in the market for trends to form. This is the middle blue bars.
// 
// Included is also two other parts. The upper bars consist of the BERLIN Range Index.
// It is used to identify choppiness and is originally based on the choppiness index, but
// improved using an ATR filter.
// 
// The lower green (teal) bars check when there is force behind the ACTION by applying a
// moving average on a selected volatility index (VIX), and plotting teal bars when the
// VIX crosses above the moving average, indicating that the market the VIX is measuring is
// getting more volatile.
// 
// Included in this indicator is also basic trade management tools using the ATR. It helps you
// find suitable stoploss and take profit distances for trades using the ATR. The ATR is also
// used to find what VP from NNFX calls 'FU-candles'. These are candles that are very big and
// what happens next after candles like these is very hard to predict, and therefore it is
// safer to avoid trading them.
// 
// Yellow bars (upper row) = Trending
// Orange bars (upper row) = Exhausted trend (could potentially reverse, so if trend trading,
//                           use less risk)
// Red bars (upper row)    = Exhausted trend is losing momentum (reversal or pullback is very
//                           likely ahead, use less risk)
// Gray bars (upper row)   = Ranging - DO NOT TRADE!
// 
// Blue bars (mid row) = There is ACTION in the market -- signals it should be safe to trade
// Gray bars (mid row) = No ACTION - DO NOT TRADE!
// 
// Teal bars (lower row) = There is force behind the ACTION!
// Gray bars (lower row) = Less volatility in the market, be careful!
// 
// -------------------------------------------------------------------------------------------
// 
// Changelog:
// 
// - Version 2.8 -
//    * Added a custom VIX that is calculated in a similar waythat the Bitcoin Historical
//      Volatility Index (BVOL24H) is calculated, to make a kind of "adaptive" VIX that works
//      on any market.
//    * Cleaned up a code a bit with line breaks.
// - Version 2.7 -
//    * Made some options more clear and added dummy checkboxes to divide the settings into
//      categories.
//    * Added more VIX tickers to the VIX ticker list to cover more markets.
//    * Added an option to adapt colors to bright mode (the TradingView color theme).
// - Version 2.6 -
//    * Added option to alert for orange bars in the BERLIN Range Index (upper row).
// - Version 2.5 -
//    * Changed name to include the name of the algo this indicator is part of.
//    * Added licensing information in the comments.
//    * Added more information in the header comment to make the indicator easier to
//      understand.
// - Version 2.4 -
//    * Changed out the choppiness index for the BERLIN Range Index, as it is less laggy.
// - Version 2.3 -
//    * Added a choppiness index filter as a third confirmation for volatility.
// - Version 2.2 -
//    * Added checks against volatility indices in order to indicate whether or not there is
//      volatility in the market. You can choose between a volatility index for Forex (EVZ)
//      and two stock indices (VIX). The idea is that if there is volatility in the overall
//      market, there is a higher probability that the market will take ACTION.
// - Version 2.1 -
//    * Added the Average Sigma Price Build-up signal to the indicator. This is usually quite
//      a strong indication of possible ACTION in the market. Whenever this signals the
//      upper bar is brighter, signaling a stronger volatility and a higher probability
//      that the market will take ACTION.
//    * Corrected a bug in the LSMA calculation.
// - Version 2.0 -
//    * Initial release.
// 
// -------------------------------------------------------------------------------------------
// 
// Licensed under CC BY-NC.
// https://creativecommons.org/licenses/by-nc/4.0/
// 
// Copyright © Anton "lejmer" Berlin, 2020.
// 
// -------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 27
#property indicator_plots 9
#property indicator_type1  DRAW_COLOR_ARROW
#property indicator_type2  DRAW_COLOR_ARROW
#property indicator_type3  DRAW_COLOR_ARROW
#property indicator_color1 Teal,DimGray
#property indicator_color2 DimGray,0xEFDB2B,Orange,Red;
#property indicator_color3 Blue,0x115193,DimGray;
#property indicator_minimum 0
#property indicator_maximum 5

#include <MovingAverages.mqh>

input string dummy_brx = ""; // ------------ BERLIN Range Index (BRX) ------------
input int range_length = 9; // Length
input int range_max_val = 40; // Max value
input int range_min_val = 10; // Min value
input int af_atr_length = 14; // ATR Filter: Period
input int af_low_lookback = 14; // ATR Filter: Low Lookback Period
input bool af_use_normalized = true; // ATR Filter: Used normalized true range?
input int af_stddev_length = 14; // ATR Filter: Standard Deviation - Length
input bool alert_orange_bmx = true; // Alert for orange bars?
input bool range_bypass = true; // Skip BERLIN Range Index?
input string dummy_stddev = ""; // ------------ Standard Deviation ------------
input int stddev_length = 14; // Length
input bool stddev_use_ha_src = false; // Use Heikin Ashi as source?
input bool stddev_bypass = false; // Skip standard deviation?
input int ma_length = 6; // Threshold MA - Length
input ENUM_MA_METHOD ma_type = MODE_SMA; // Threshold MA - Type
input string dummy_asp = ""; // ------------ Average Sigma Price Build-up ------------
input int asp_length = 7; // Period
input ENUM_MA_METHOD asp_smoothing_ma_type = MODE_SMA; // Smoothing MA
input int asp_smoothing = 2; // Smoothing period
input ENUM_MA_METHOD asp_signal_ma_type = MODE_SMA; // Signal MA
input int asp_signal_ma_length = 14; // Signal MA length
input double asp_threshold = 0.02; // Threshold
input bool asp_use_ha_src = false; // Use Heikin Ashi as source?
input bool asp_bypass = false; // Skip Average Sigma Price Build-up?
input string dummy_vix = ""; // ------------ Volatility Index (VIX) ------------
input ENUM_MA_METHOD vix_ma_type = MODE_SMA; // Threshold MA Type
input int vix_ma_length = 20; // Threshold MA Period
input string dummy_fu_atrf = ""; // ------------ FU Candle ATR Filter ------------
input int fu_atr_length = 14; // ATR Length
input double fu_atr_max_mult = 2.0; // ATR Threshold Factor
input bool fu_atr_bypass = false; // Skip FU Candle ATR Filter?
input string dummy_atr_tm = ""; // ------------ ATR Trade management ------------
input int atr_len = 14; // ATR Length
input double atr_sl_factor = 1.5; // SL multiplier
input double atr_tp_factor = 1.0; // TP multiplier
input bool atr_bypass = false; // Skip ATR Trade management?

//+------------------------------------------------------------------------------------------------------------------+
double StDev(double& data[], int period, int pos)
{
   return MathSqrt(Variance(data, period, pos));
}
//+------------------------------------------------------------------------------------------------------------------+
double Variance(double& data[], int period, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < period; i++)
   {
      sum += data[pos - i];
      ssum += MathPow(data[pos - i], 2);
   }
   return (ssum * period - sum * sum) / (period * (period - 1));
}
//+------------------------------------------------------------------------------------------------------------------+
string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

int atr, ha;
double al_lowerbar[];
double al_upperbar[];
double al_rangebar[];
double al_lowerbar_clr[];
double al_upperbar_clr[];
double al_rangebar_clr[];
double vix_ma[], threshold_ma[], asp_signal_base_p[];
double tr_val[], atr_val[], af_stddev[], range_index[], stddev_src[], stddev_val[], asp_src[], asp_src_stdev[], asp_pval[], asp_price_stdev[], acc_ln_price[], adaptive_vix_val[];
//+------------------------------------------------------------------------------------------------------------------+
int OnInit(void)
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("al");
   IndicatorSetString(INDICATOR_SHORTNAME, "Action Locator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0; 
   SetIndexBuffer(id, al_lowerbar, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_ARROW, 110);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, al_lowerbar_clr, INDICATOR_COLOR_INDEX);
   ++id;
   SetIndexBuffer(id, al_rangebar, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_ARROW, 110);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, al_rangebar_clr, INDICATOR_COLOR_INDEX);
   ++id;
   SetIndexBuffer(id, al_upperbar, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_ARROW, 110);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, al_upperbar_clr, INDICATOR_COLOR_INDEX);
   ++id;

   SetIndexBuffer(id, tr_val, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, atr_val, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, af_stddev, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, range_index, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, stddev_src, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, stddev_val, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, asp_src, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, asp_src_stdev, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, asp_pval, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, asp_price_stdev, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, acc_ln_price, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, adaptive_vix_val, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, vix_ma, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, threshold_ma, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, asp_signal_base_p, INDICATOR_CALCULATIONS);
   ++id;
   atr = iATR(_Symbol, _Period, fu_atr_length);
   ha = iCustom(_Symbol, _Period, "Examples\\Heiken_Ashi");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(atr);
   IndicatorRelease(ha);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

double TrueRange(const int p,                
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[])

{
   double hl = MathAbs(high[p] - low[p]);
   double hc = MathAbs(high[p] - close[p - 1]);
   double lc = MathAbs(low[p] - close[p - 1]);

   double tr = hl;
   if (tr < hc)
      tr = hc;
   if (tr < lc)
      tr = lc;
   return tr;
}

void MAOnArray(const int rates_total, const int prev_calculated, int sourceFirst, ENUM_MA_METHOD method, int period, double& in[], double& out[])
{
   if (period == 1)
   {
      for (int pos = sourceFirst; pos < rates_total; ++pos)
      {
         out[pos] = in[pos];
      }
      return;
   }
   int weightsum;
   switch (method)
   {
      case MODE_SMA:
         SimpleMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_EMA:
         ExponentialMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_SMMA:
         SmoothedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_LWMA:
         LinearWeightedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out, weightsum);
         break;
   }
}

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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(tr_val, EMPTY_VALUE);
      ArrayInitialize(atr_val, EMPTY_VALUE);
      ArrayInitialize(af_stddev, EMPTY_VALUE);
      ArrayInitialize(range_index, EMPTY_VALUE);
      ArrayInitialize(stddev_src, EMPTY_VALUE);
      ArrayInitialize(stddev_val, EMPTY_VALUE);
      ArrayInitialize(asp_src, EMPTY_VALUE);
      ArrayInitialize(asp_src_stdev, EMPTY_VALUE);
      ArrayInitialize(asp_pval, 0);
      ArrayInitialize(asp_price_stdev, EMPTY_VALUE);
      ArrayInitialize(acc_ln_price, EMPTY_VALUE);
      ArrayInitialize(adaptive_vix_val, EMPTY_VALUE);
      ArrayInitialize(al_lowerbar, EMPTY_VALUE);
      ArrayInitialize(al_rangebar, EMPTY_VALUE);
      ArrayInitialize(al_upperbar, EMPTY_VALUE);
      ArrayInitialize(vix_ma, EMPTY_VALUE);
      ArrayInitialize(threshold_ma, EMPTY_VALUE);
      ArrayInitialize(asp_signal_base_p, EMPTY_VALUE);
      ArrayInitialize(al_lowerbar_clr, 0);
      ArrayInitialize(al_rangebar_clr, 0);
      ArrayInitialize(al_upperbar_clr, 0);
   }
   int toSkip = fu_atr_length + 1;
   int first = 1 + toSkip;
   int stddev_val_first = first + stddev_length;
   int atr_val_first = first + af_atr_length;
   int af_stddev_first = atr_val_first + af_stddev_length;
   int range_index_first = af_stddev_first + af_low_lookback;
   int asp_src_stdev_first = first + asp_length;
   int asp_price_stdev_first = asp_src_stdev_first + asp_smoothing;
   int al_upperbar_first = MathMin(asp_price_stdev_first + asp_signal_ma_length, stddev_val_first + ma_length);
   int adaptive_vix_val_first = first + 10;
   int vix_ma_first = adaptive_vix_val_first + vix_ma_length;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double tr = TrueRange(pos, time, open, high, low, close);
      tr_val[pos] = af_use_normalized ? MathMax(MathMax(tr, high[pos] - close[pos]), close[pos] - low[pos]) / close[pos] : tr;
      double stddev_ha_close[1];
      if (CopyBuffer(ha, 2, oldPos, 1, stddev_ha_close) != 1)
      {
         continue;
      }
      asp_src[pos] = asp_use_ha_src ? stddev_ha_close[0] : close[pos];
      stddev_src[pos] = stddev_use_ha_src ? stddev_ha_close[0] : close[pos];
      acc_ln_price[pos] = 0.0;
      for (int i = 0; i < 9; ++i)
      {
         acc_ln_price[pos] += MathLog(close[pos - i - 1]) / MathLog(close[pos - i]);
      }
   }
   SimpleMAOnBuffer(rates_total, prev_calculated, first, af_atr_length, tr_val, atr_val);
   for (int pos = MathMax(af_stddev_first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      af_stddev[pos] = StDev(atr_val, af_stddev_length, pos);
   }
   for (int pos = MathMax(range_index_first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      double chop_str = TrueRange(pos, time, open, high, low, close);
      double chop_ltl = low[pos] <= close[pos - 1] ? low[pos] : close[pos - 1];
      double chop_hth = high[pos] >= close[pos - 1] ? high[pos] : close[pos - 1];
      for (int i = 1; i < range_length; ++i)
      {
         chop_str += TrueRange(pos - i, time, open, high, low, close);
         chop_ltl = MathMin(chop_ltl, low[pos - i] <= close[pos - i - 1] ? low[pos - i] : close[pos - i - 1]);
         chop_hth = MathMax(chop_hth, high[pos - i] >= close[pos - i - 1] ? high[pos - i] : close[pos - i - 1]);
      }
      double chop_height = chop_hth - chop_ltl;
      double chop_value = chop_height == 0 ? 0 : 100 * (MathLog10(chop_str / chop_height) / MathLog10(range_length));
      int lowestIndex = ArrayMinimum(af_stddev, af_low_lookback, pos);
      double af_stddev_lo = af_stddev[lowestIndex];
      double af_stddev_factor = af_stddev[pos] == 0 ? 0 : af_stddev_lo / af_stddev[pos];
      range_index[pos] = chop_value * af_stddev_factor;
      bool range_strong_trend_condition = range_index[pos] < range_min_val;
      bool range_weakening_trend_condition = range_index[pos - 1] < range_min_val && range_index[pos] > range_min_val;
      bool range_trend_condition = range_index[pos - 1] > range_min_val && range_index[pos] < range_max_val && range_index[pos] > range_min_val;
      al_rangebar[pos] = 3;
      al_rangebar_clr[pos] = range_index[pos] > range_max_val 
         ? 0 : range_trend_condition 
         ? 1 : range_strong_trend_condition 
         ? 2 : range_weakening_trend_condition 
         ? 3 : 0;
   }
   for (int pos = MathMax(asp_src_stdev_first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      asp_src_stdev[pos] = StDev(asp_src, asp_length, pos);
   }
   MAOnArray(rates_total, prev_calculated, asp_src_stdev_first, asp_smoothing_ma_type, asp_smoothing, asp_src_stdev, asp_price_stdev);
   for (int pos = MathMax(asp_price_stdev_first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      asp_pval[pos] = MathMax(asp_pval[pos - 1] + (asp_price_stdev[pos] - asp_price_stdev[pos - asp_length]) / asp_length, 0);
   }
   for (int pos = MathMax(stddev_val_first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      stddev_val[pos] = StDev(stddev_src, stddev_length, pos);
   }
   MAOnArray(rates_total, prev_calculated, asp_price_stdev_first, asp_signal_ma_type, asp_signal_ma_length, asp_pval, asp_signal_base_p);
   MAOnArray(rates_total, prev_calculated, stddev_val_first, ma_type, ma_length, stddev_val, threshold_ma);
   for (int pos = MathMax(al_upperbar_first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      if (asp_pval[pos] == 0)
      {
         continue;
      }
      int oldPos = rates_total - pos - 1;
      double asp_diff = MathMax(asp_pval[pos] - asp_signal_base_p[pos], 0);
      double asp_factor = asp_diff / asp_pval[pos];
      if (asp_factor == 1)
      {
         continue;
      }
      double asp_val = 1.0 / (1.0 - asp_factor) - 1.0;
      double asp_main_out = asp_bypass ? 0 : MathMax(asp_val - asp_threshold, 0);
      double tr = TrueRange(pos, time, open, high, low, close);
      double fu_atr_val[1];
      if (CopyBuffer(atr, 0, oldPos, 1, fu_atr_val) != 1)
      {
         continue;
      }
      bool fu_atr_filter = fu_atr_bypass ? false : tr >= (fu_atr_val[0] * fu_atr_max_mult);
      double stddev_main_out = fu_atr_filter || stddev_bypass ? 0 : MathMax(0, stddev_val[pos] - threshold_ma[pos]);
      al_upperbar[pos] = 2;
      al_upperbar_clr[pos] = asp_main_out > 0 ? 0 : (stddev_main_out > 0 && asp_main_out == 0) ? 1 : 2;
   }
   for (int pos = MathMax(adaptive_vix_val_first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      adaptive_vix_val[pos] = StDev(acc_ln_price, 10, pos) * MathSqrt(10);
   }
   MAOnArray(rates_total, prev_calculated, adaptive_vix_val_first, vix_ma_type, vix_ma_length, adaptive_vix_val, vix_ma);
   for (int pos = MathMax(vix_ma_first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      al_lowerbar[pos] = 1;
      al_lowerbar_clr[pos] = adaptive_vix_val[pos] > vix_ma[pos] ? 0 : 1;
   }
   return rates_total;
}
