/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        R_Trend_Exhaustion_arrow
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160957#p160957
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
#property description "%R Trend Exhaustion Indicator - MQL4 Version"
#property indicator_separate_window
#property indicator_buffers 7
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
input color InpBullColor = clrBlue;                    // Cold Color
input color InpBearColor = clrRed;                     // Hot Color
input string InpDisplayMode = "1 Oscillator Mode";     // Display Mode
input string InpFormula = "Standard (2 Period)";       // Formula
input int InpSource = PRICE_CLOSE;                     // Source
input int InpThreshold = 20;                           // Exhaustion Threshold (1-50)
input int InpSmoothType = MODE_EMA;                    // Smoothing Type
input int InpAverageMA = 3;                            // Average Formula MA
input bool InpPlotShading = true;                      // Fill Gradients in OB/OS Zone
input bool InpPlotCrosses = false;                     // Highlight Crossovers
input bool InpPlotZeroCrosses = false;                 // Plot Zero Line Crosses
input bool InpBullStartOn = true;                     // Bull trend start alert
input bool InpBearStartOn = true;                     // Bear trend start alert
input bool InpBullReversalOn = true;                  // Bull trend reversal alert
input bool InpBearReversalOn = true;                  // Bear trend reversal alert
input bool InpEnablePopupAlerts = true;               // Enable popup alerts
input bool InpEnableSoundAlerts = true;               // Enable sound alerts
input bool InpEnableEmailAlerts = false;              // Enable email alerts
input bool InpEnablePushAlerts = false;               // Enable push notifications
input int InpShortLength = 21;                         // Fast Length
input int InpShortSmoothingLength = 7;                 // Fast Smoothing Length
input int InpLongLength = 112;                         // Slow Length
input int InpLongSmoothingLength = 3;                  // Slow Smoothing Length
input color arrUpColor = clrBlue;                      // Arrow Up Color
input color arrDoColor = clrRed;                       // Arrow Down Color
input int arrUpCode = 233;                             // Arrow Up Code
input int arrDoCode = 234;                             // Arrow Down Code
input int arrWidth = 2;                                // Arrow Width
input int Distance = 20;                               // Arrow distance from Hi/Lo
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
datetime last_arrow_time = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "arrD");
   ObjectsDeleteAll(0, "arrU");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, FastPercentRBuffer);
   SetIndexBuffer(1, SlowPercentRBuffer);
   SetIndexBuffer(2, AvgPercentRBuffer);
   SetIndexBuffer(3, OBReversalBuffer);
   SetIndexBuffer(4, OSReversalBuffer);
   SetIndexBuffer(5, OBWarningBuffer);
   SetIndexBuffer(6, OSWarningBuffer);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, InpBullColor);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, InpBearColor);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, clrNONE);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2, InpBearColor);
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 2, InpBullColor);
   SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID, 1, InpBearColor);
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID, 1, InpBullColor);
   SetIndexArrow(3, 234);
   SetIndexArrow(4, 233);
   SetIndexArrow(5, 110);
   SetIndexArrow(6, 110);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexEmptyValue(6, EMPTY_VALUE);
   SetIndexLabel(0, "Fast %R");
   SetIndexLabel(1, "Slow %R");
   SetIndexLabel(2, "Average %R");
   SetIndexLabel(3, "OB Reversal");
   SetIndexLabel(4, "OS Reversal");
   SetIndexLabel(5, "OB Warning");
   SetIndexLabel(6, "OS Warning");
   use_average = (InpFormula == "Average");
   IndicatorShortName("%R Trend Exhaustion");
   IndicatorDigits(2);
   SetLevelValue(0, 0);
   SetLevelValue(1, -InpThreshold);
   SetLevelValue(2, -50);
   SetLevelValue(3, -(100 - InpThreshold));
   SetLevelValue(4, -100);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculatePercentR(int shift, int period)
  {
   double highest = 0;
   double lowest = 999999;
   for(int i = shift; i < shift + period && i < Bars; i++)
     {
      double high_val = High[i];
      double low_val = Low[i];
      if(high_val > highest)
         highest = high_val;
      if(low_val < lowest)
         lowest = low_val;
     }
   double src_val = 0;
   switch(InpSource)
     {
      case PRICE_OPEN:
         src_val = Open[shift];
         break;
      case PRICE_HIGH:
         src_val = High[shift];
         break;
      case PRICE_LOW:
         src_val = Low[shift];
         break;
      case PRICE_CLOSE:
         src_val = Close[shift];
         break;
      case PRICE_MEDIAN:
         src_val = (High[shift] + Low[shift]) / 2;
         break;
      case PRICE_TYPICAL:
         src_val = (High[shift] + Low[shift] + Close[shift]) / 3;
         break;
      case PRICE_WEIGHTED:
         src_val = (High[shift] + Low[shift] + 2 * Close[shift]) / 4;
         break;
     }
   if(highest == lowest)
      return -50;
   return 100.0 * (src_val - highest) / (highest - lowest);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMA(double& buffer[], int shift, int period, int method)
  {
   if(period <= 1)
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
   int limit;
   if(prev_calculated == 0)
     {
      limit = rates_total - MathMax(InpShortLength, InpLongLength) - 1;
      ArrayInitialize(FastPercentRBuffer, EMPTY_VALUE);
      ArrayInitialize(SlowPercentRBuffer, EMPTY_VALUE);
      ArrayInitialize(AvgPercentRBuffer, EMPTY_VALUE);
      ArrayInitialize(OBReversalBuffer, EMPTY_VALUE);
      ArrayInitialize(OSReversalBuffer, EMPTY_VALUE);
      ArrayInitialize(OBWarningBuffer, EMPTY_VALUE);
      ArrayInitialize(OSWarningBuffer, EMPTY_VALUE);
     }
   else
     {
      limit = rates_total - prev_calculated;
     }
   if(ArraySize(FastRawBuffer) != rates_total)
     {
      ArrayResize(FastRawBuffer, rates_total);
      ArrayResize(SlowRawBuffer, rates_total);
      ArrayResize(HighestBuffer, rates_total);
      ArrayResize(LowestBuffer, rates_total);
     }
   for(int i = limit; i >= 0; i--)
     {
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
      if(i + 1 >= rates_total)
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
      if(ob_reversal)
         drawArrow(-1, i);
      else
         drawArrow(-11, i);
      if(os_reversal)
         drawArrow(1, i);
      else
         drawArrow(11, i);
      if(i == 0)
        {
         if(ob_trend_start && InpBearStartOn)
            SendAlert("Bear trend start", "Possible overbought trend exhaustion on " + Symbol());
         if(os_trend_start && InpBullStartOn)
            SendAlert("Bull trend start", "Possible oversold trend exhaustion on " + Symbol());
         if(ob_reversal && InpBearReversalOn)
            SendAlert("Bear reversal", "Overbought trend is exhausted on " + Symbol());
         if(os_reversal && InpBullReversalOn)
            SendAlert("Bull reversal", "Oversold trend is exhausted on " + Symbol());
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
   if(last_alert_time == Time[0])
      return;
   last_alert_time = Time[0];
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
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(int dir, int bar)
  {
   string obj_name;
   if(dir == 11)
     {
      obj_name = "arrU" + IntegerToString(bar);
      ObjectDelete(0, obj_name);
      return;
     }
   if(dir == -11)
     {
      obj_name = "arrD" + IntegerToString(bar);
      ObjectDelete(0, obj_name);
      return;
     }
   datetime bar_time = Time[bar];
   if(dir == -1)
     {
      obj_name = "arrD" + IntegerToString(bar);
      ObjectDelete(0, obj_name);
      double arrow_price = High[bar] + Distance * Point;
      if(ObjectCreate(0, obj_name, OBJ_ARROW, 0, bar_time, arrow_price))
        {
         ObjectSet(obj_name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
         ObjectSet(obj_name, OBJPROP_COLOR, arrDoColor);
         ObjectSet(obj_name, OBJPROP_WIDTH, arrWidth);
         ObjectSet(obj_name, OBJPROP_ARROWCODE, arrDoCode);
         ObjectSet(obj_name, OBJPROP_BACK, false);
         ObjectSet(obj_name, OBJPROP_SELECTABLE, false);
         ObjectSet(obj_name, OBJPROP_SELECTED, false);
         ObjectSet(obj_name, OBJPROP_HIDDEN, true);
        }
     }
   if(dir == 1)
     {
      obj_name = "arrU" + IntegerToString(bar);
      ObjectDelete(0, obj_name);
      double arrow_price = Low[bar] - Distance * Point;
      if(ObjectCreate(0, obj_name, OBJ_ARROW, 0, bar_time, arrow_price))
        {
         ObjectSet(obj_name, OBJPROP_COLOR, arrUpColor);
         ObjectSet(obj_name, OBJPROP_WIDTH, arrWidth);
         ObjectSet(obj_name, OBJPROP_ARROWCODE, arrUpCode);
         ObjectSet(obj_name, OBJPROP_BACK, false);
         ObjectSet(obj_name, OBJPROP_SELECTABLE, false);
         ObjectSet(obj_name, OBJPROP_SELECTED, false);
         ObjectSet(obj_name, OBJPROP_HIDDEN, true);
        }
     }
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        R_Trend_Exhaustion_arrow
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160957#p160957
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
