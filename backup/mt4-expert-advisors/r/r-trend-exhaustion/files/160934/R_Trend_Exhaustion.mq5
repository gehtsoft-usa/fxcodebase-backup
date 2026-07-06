// -- Project -------------------------------------------------------------------------------
/*
Name:        R_Trend_Exhaustion
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76381
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
#property description "%R Trend Exhaustion Indicator - MQL5 Version"
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   7

#property indicator_label1  "Fast %R"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label2  "Slow %R"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCornflowerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label3  "Average %R"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrNONE
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
#property indicator_label4  "OB Reversal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  2
#property indicator_label5  "OS Reversal"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrBlue
#property indicator_width5  2
#property indicator_label6  "OB Warning"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrDarkRed
#property indicator_width6  1
#property indicator_label7  "OS Warning"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrDarkBlue
#property indicator_width7  1
input group "Settings v2.2"
input color InpBullColor = clrBlue;                    // Cold Color
input color InpBearColor = clrRed;                     // Hot Color
input string InpDisplayMode = "1 Oscillator Mode";     // Display Mode
input string InpFormula = "Standard (2 Period)";       // Formula
input ENUM_APPLIED_PRICE InpSource = PRICE_CLOSE;      // Source
input int InpThreshold = 20;                           // Exhaustion Threshold (1-50)
input ENUM_MA_METHOD InpSmoothType = MODE_EMA;          // Smoothing Type
input int InpAverageMA = 3;                            // Average Formula MA
input bool InpPlotShading = true;                      // Fill Gradients in OB/OS Zone
input bool InpPlotCrosses = false;                     // Highlight Crossovers
input bool InpPlotZeroCrosses = false;                 // Plot Zero Line Crosses
input group "Alerts"
input bool InpBullStartOn = true;                     // Bull trend start alert
input bool InpBearStartOn = true;                     // Bear trend start alert
input bool InpBullReversalOn = true;                  // Bull trend reversal alert
input bool InpBearReversalOn = true;                  // Bear trend reversal alert
input bool InpEnablePopupAlerts = true;               // Enable popup alerts
input bool InpEnableSoundAlerts = true;               // Enable sound alerts
input bool InpEnableEmailAlerts = false;              // Enable email alerts
input bool InpEnablePushAlerts = false;               // Enable push notifications
input group "Dual Signal Setup (Fast/Slow Lookback)"
input int InpShortLength = 21;                         // Fast Length
input int InpShortSmoothingLength = 7;                 // Fast Smoothing Length
input int InpLongLength = 112;                         // Slow Length
input int InpLongSmoothingLength = 3;                  // Slow Smoothing Length
double FastPercentRBuffer[];
double SlowPercentRBuffer[];
double AvgPercentRBuffer[];
double OBReversalBuffer[];
double OSReversalBuffer[];
double OBWarningBuffer[];
double OSWarningBuffer[];

double HighestBuffer[];
double LowestBuffer[];
double FastRawBuffer[];
double SlowRawBuffer[];
bool was_ob = false;
bool was_os = false;
bool use_average = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, FastPercentRBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SlowPercentRBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, AvgPercentRBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, OBReversalBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, OSReversalBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, OBWarningBuffer, INDICATOR_DATA);
   SetIndexBuffer(6, OSWarningBuffer, INDICATOR_DATA);
   SetIndexBuffer(7, HighestBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, LowestBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, FastRawBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, SlowRawBuffer, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(FastPercentRBuffer, true);
   ArraySetAsSeries(SlowPercentRBuffer, true);
   ArraySetAsSeries(AvgPercentRBuffer, true);
   ArraySetAsSeries(OBReversalBuffer, true);
   ArraySetAsSeries(OSReversalBuffer, true);
   ArraySetAsSeries(OBWarningBuffer, true);
   ArraySetAsSeries(OSWarningBuffer, true);
   ArraySetAsSeries(HighestBuffer, true);
   ArraySetAsSeries(LowestBuffer, true);
   ArraySetAsSeries(FastRawBuffer, true);
   ArraySetAsSeries(SlowRawBuffer, true);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);
   PlotIndexSetInteger(4, PLOT_ARROW, 233);
   PlotIndexSetInteger(5, PLOT_ARROW, 110);
   PlotIndexSetInteger(6, PLOT_ARROW, 110);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpBullColor);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpBearColor);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, InpBearColor);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, InpBullColor);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, InpBearColor);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, InpBullColor);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   use_average = (InpFormula == "Average");
   IndicatorSetString(INDICATOR_SHORTNAME, "%R Trend Exhaustion");
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, -InpThreshold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, -50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 3, -(100 - InpThreshold));
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 4, -100);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculatePercentR(int shift, int period)
  {
   double highest = 0;
   double lowest = 999999;
   for(int i = shift; i < shift + period && i < Bars(_Symbol, _Period); i++)
     {
      double high_val = iHigh(_Symbol, _Period, i);
      double low_val = iLow(_Symbol, _Period, i);
      if(high_val > highest)
         highest = high_val;
      if(low_val < lowest)
         lowest = low_val;
     }
   double src_val = 0;
   switch(InpSource)
     {
      case PRICE_OPEN:
         src_val = iOpen(_Symbol, _Period, shift);
         break;
      case PRICE_HIGH:
         src_val = iHigh(_Symbol, _Period, shift);
         break;
      case PRICE_LOW:
         src_val = iLow(_Symbol, _Period, shift);
         break;
      case PRICE_CLOSE:
         src_val = iClose(_Symbol, _Period, shift);
         break;
      case PRICE_MEDIAN:
         src_val = (iHigh(_Symbol, _Period, shift) + iLow(_Symbol, _Period, shift)) / 2;
         break;
      case PRICE_TYPICAL:
         src_val = (iHigh(_Symbol, _Period, shift) + iLow(_Symbol, _Period, shift) + iClose(_Symbol, _Period, shift)) / 3;
         break;
      case PRICE_WEIGHTED:
         src_val = (iHigh(_Symbol, _Period, shift) + iLow(_Symbol, _Period, shift) + 2 * iClose(_Symbol, _Period, shift)) / 4;
         break;
     }
   if(highest == lowest)
      return -50;
   return 100.0 * (src_val - highest) / (highest - lowest);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMA(double& buffer[], int shift, int period, ENUM_MA_METHOD method)
  {
   if(period <= 1 || shift >= ArraySize(buffer))
      return buffer[shift];
   double sum = 0;
   int count = 0;
   for(int i = 0; i < period; i++)
     {
      int index = shift + i;
      if(index >= ArraySize(buffer))
         break;
      sum += buffer[index];
      count++;
     }
   return count > 0 ? sum / count : 0;
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
   if(rates_total < MathMax(InpShortLength, InpLongLength))
      return 0;
   if(ArraySize(FastPercentRBuffer) != rates_total)
     {
      ArrayResize(FastPercentRBuffer, rates_total);
      ArrayResize(SlowPercentRBuffer, rates_total);
      ArrayResize(AvgPercentRBuffer, rates_total);
      ArrayResize(OBReversalBuffer, rates_total);
      ArrayResize(OSReversalBuffer, rates_total);
      ArrayResize(OBWarningBuffer, rates_total);
      ArrayResize(OSWarningBuffer, rates_total);
      ArrayResize(HighestBuffer, rates_total);
      ArrayResize(LowestBuffer, rates_total);
      ArrayResize(FastRawBuffer, rates_total);
      ArrayResize(SlowRawBuffer, rates_total);
     }
   int limit = prev_calculated > 0 ? prev_calculated - 1 : rates_total - 1;
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   for(int i = limit; i >= 0; i--)
     {
      if(i >= rates_total || i < 0)
         continue;
      FastRawBuffer[i] = CalculatePercentR(i, InpShortLength);
      SlowRawBuffer[i] = CalculatePercentR(i, InpLongLength);
      if(InpShortSmoothingLength > 1 && i + InpShortSmoothingLength < rates_total)
         FastPercentRBuffer[i] = CalculateMA(FastRawBuffer, i, InpShortSmoothingLength, InpSmoothType);
      else
         FastPercentRBuffer[i] = FastRawBuffer[i];
      if(InpLongSmoothingLength > 1 && i + InpLongSmoothingLength < rates_total)
         SlowPercentRBuffer[i] = CalculateMA(SlowRawBuffer, i, InpLongSmoothingLength, InpSmoothType);
      else
         SlowPercentRBuffer[i] = SlowRawBuffer[i];
      AvgPercentRBuffer[i] = (FastPercentRBuffer[i] + SlowPercentRBuffer[i]) / 2.0;
      if(InpAverageMA > 1 && i + InpAverageMA < rates_total)
         AvgPercentRBuffer[i] = CalculateMA(AvgPercentRBuffer, i, InpAverageMA, InpSmoothType);
      OBReversalBuffer[i] = EMPTY_VALUE;
      OSReversalBuffer[i] = EMPTY_VALUE;
      OBWarningBuffer[i] = EMPTY_VALUE;
      OSWarningBuffer[i] = EMPTY_VALUE;
      if(i == rates_total - 1 || i + 1 >= rates_total)
         continue;
      double current_fast = use_average ? AvgPercentRBuffer[i] : FastPercentRBuffer[i];
      double current_slow = use_average ? AvgPercentRBuffer[i] : SlowPercentRBuffer[i];
      double prev_fast = use_average ? AvgPercentRBuffer[i + 1] : FastPercentRBuffer[i + 1];
      double prev_slow = use_average ? AvgPercentRBuffer[i + 1] : SlowPercentRBuffer[i + 1];
      bool overbought = current_fast >= -InpThreshold && current_slow >= -InpThreshold;
      bool oversold = current_fast <= -(100 - InpThreshold) && current_slow <= -(100 - InpThreshold);
      bool prev_overbought = prev_fast >= -InpThreshold && prev_slow >= -InpThreshold;
      bool prev_oversold = prev_fast <= -(100 - InpThreshold) && prev_slow <= -(100 - InpThreshold);
      bool ob_reversal = !overbought && prev_overbought;
      bool os_reversal = !oversold && prev_oversold;
      bool ob_trend_start = overbought && !prev_overbought;
      bool os_trend_start = oversold && !prev_oversold;
      if(ob_reversal)
         OBReversalBuffer[i] = 5;
      if(os_reversal)
         OSReversalBuffer[i] = -107;
      if(overbought)
         OBWarningBuffer[i] = 5;
      if(oversold)
         OSWarningBuffer[i] = -107;
      if(i == 0)
        {
         if(ob_trend_start && InpBearStartOn)
            SendAlert("Bear trend start", "Possible overbought trend exhaustion on " + _Symbol);
         if(os_trend_start && InpBullStartOn)
            SendAlert("Bull trend start", "Possible oversold trend exhaustion on " + _Symbol);
         if(ob_reversal && InpBearReversalOn)
            SendAlert("Bear reversal", "Overbought trend is exhausted on " + _Symbol);
         if(os_reversal && InpBullReversalOn)
            SendAlert("Bull reversal", "Oversold trend is exhausted on " + _Symbol);
        }
     }
   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string title, string message)
  {
   static datetime last_alert_time = 0;
   if(last_alert_time == iTime(_Symbol, _Period, 0))
      return;
   last_alert_time = iTime(_Symbol, _Period, 0);
   string alert_text = "[" + title + "] " + message;
   if(InpEnablePopupAlerts)
      Alert(alert_text);
   if(InpEnableSoundAlerts)
      PlaySound("alert.wav");
   if(InpEnableEmailAlerts)
      SendMail(title, alert_text);
   if(InpEnablePushAlerts)
      SendNotification(alert_text);
  }

//+------------------------------------------------------------------+
// -- Project -------------------------------------------------------------------------------
/*
Name:        R_Trend_Exhaustion
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76381
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