/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76302
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
// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"


#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_label1  "Winner"
#property indicator_minimum 0
#property indicator_maximum 100

input int Periods = 10;
input int SmoothingPeriod = 5;
input color UpColor = clrLime;
input color DownColor = clrRed;

double HighBuffer[];
double LowBuffer[];
double ColorBuffer[];

double COST[];
double pa5[];
double rsv[];
double pak[];
double pad[];

double alpha1, alpha2;

int OnInit() {
   IndicatorSetString(INDICATOR_SHORTNAME, "Winner (" + IntegerToString(Periods) + ", " + IntegerToString(SmoothingPeriod) + ")");
   
   SetIndexBuffer(0, HighBuffer);
   SetIndexBuffer(1, LowBuffer);
   SetIndexBuffer(2, ColorBuffer, INDICATOR_COLOR_INDEX);
   
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
   
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, UpColor);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, DownColor);
   
   alpha1 = 2.0 / (Periods + 1);
   alpha2 = 2.0 / (Periods + 1);
   
   ArraySetAsSeries(HighBuffer, false);
   ArraySetAsSeries(LowBuffer, false);
   ArraySetAsSeries(ColorBuffer, false);
   ArraySetAsSeries(COST, false);
   ArraySetAsSeries(pa5, false);
   ArraySetAsSeries(rsv, false);
   ArraySetAsSeries(pak, false);
   ArraySetAsSeries(pad, false);
   
   return(INIT_SUCCEEDED);
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
                const int &spread[]) {
   if (rates_total < SmoothingPeriod + 2 * Periods) return(0);
   
   int start = (prev_calculated == 0) ? 0 : prev_calculated - 1;
   
   ArrayResize(COST, rates_total);
   ArrayResize(pa5, rates_total);
   ArrayResize(rsv, rates_total);
   ArrayResize(pak, rates_total);
   ArrayResize(pad, rates_total);
   ArrayResize(HighBuffer, rates_total);
   ArrayResize(LowBuffer, rates_total);
   ArrayResize(ColorBuffer, rates_total);
   
   for (int period = start; period < rates_total; period++) {
      HighBuffer[period] = 0;
      LowBuffer[period] = 0;
      ColorBuffer[period] = 0;
      
      COST[period] = ((2 * close[period] + high[period] + low[period]) / 4) * tick_volume[period];
      
      if (period < SmoothingPeriod - 1) continue;
      
      double scost5 = SumArray(COST, period - SmoothingPeriod + 1, period);
      double svolume5 = 0;
      for (int i = period - SmoothingPeriod + 1; i <= period; i++) svolume5 += tick_volume[i];
      pa5[period] = (svolume5 != 0) ? scost5 / svolume5 : 0;
      
      if (period < SmoothingPeriod + Periods - 1) continue;
      
      double min_pa5 = MinArray(pa5, period - Periods + 1, period);
      double max_pa5 = MaxArray(pa5, period - Periods + 1, period);
      if (max_pa5 - min_pa5 == 0) rsv[period] = 50;
      else rsv[period] = (pa5[period] - min_pa5) / (max_pa5 - min_pa5) * 100;
      
      if (period == SmoothingPeriod + Periods - 1) {
         pak[period] = rsv[period];
      } else if (period > SmoothingPeriod + Periods - 1) {
         pak[period] = CalculateEMA(pak[period - 1], rsv[period], alpha1);
      } else continue;
      
      if (period < SmoothingPeriod + 2 * Periods - 1) continue;
      
      if (period == SmoothingPeriod + 2 * Periods - 1) {
         pad[period] = pak[period];
      } else {
         pad[period] = CalculateEMA(pad[period - 1], pak[period], alpha2);
      }
      
      HighBuffer[period] = MathMax(pak[period], pad[period]);
      LowBuffer[period] = MathMin(pak[period], pad[period]);
      ColorBuffer[period] = (pak[period] > pad[period]) ? 0 : 1;
   }
   
   return(rates_total);
}

double SumArray(double &arr[], int start, int end) {
   double sum = 0;
   for (int i = start; i <= end; i++) sum += arr[i];
   return sum;
}

double MinArray(double &arr[], int start, int end) {
   double min_val = arr[start];
   for (int i = start + 1; i <= end; i++) if (arr[i] < min_val) min_val = arr[i];
   return min_val;
}

double MaxArray(double &arr[], int start, int end) {
   double max_val = arr[start];
   for (int i = start + 1; i <= end; i++) if (arr[i] > max_val) max_val = arr[i];
   return max_val;
}

double CalculateEMA(double prev_ema, double value, double alpha) {
   return alpha * value + (1 - alpha) * prev_ema;
}

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76302
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
