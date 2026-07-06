//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76370
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
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "K"
#property indicator_type1   DRAW_LINE
#property indicator_label2  "D"
#property indicator_type2   DRAW_LINE
#property indicator_minimum 0
#property indicator_maximum 100

extern int K = 5;
extern int D = 3;
extern int SD = 3;
extern double os = 20.0;
extern double ob = 80.0;

extern color K_color = clrRed;
extern int K_width = 1;
extern int K_style = STYLE_SOLID;

extern color D_color = clrBlue;
extern int D_width = 1;
extern int D_style = STYLE_SOLID;

extern color divergence_color_up = clrGreen;
extern color divergence_color_down = clrRed;
extern int divergence_width = 1;
extern int divergence_style = STYLE_SOLID;

extern color trace_color_up = clrGreen;
extern color trace_color_down = clrRed;
extern int trace_width = 1;
extern int trace_style = STYLE_DASH;

extern color arrow_color_up = clrGreen;
extern color arrow_color_down = clrRed;
extern int arrow_size = 2;

double stochK[];
double stochD[];

int peaks[10000];
int num_peaks;

int init()
{
   SetIndexBuffer(0, stochK);
   SetIndexStyle(0, DRAW_LINE, K_style, K_width, K_color);
   SetIndexLabel(0, "K");

   SetIndexBuffer(1, stochD);
   SetIndexStyle(1, DRAW_LINE, D_style, D_width, D_color);
   SetIndexLabel(1, "D");

   IndicatorShortName("Slow Stochastic With Divergences");
   IndicatorDigits(2);

   IndicatorSetInteger(INDICATOR_LEVELS, 2);
   SetLevelValue(0, os);
   SetLevelValue(1, ob);
   SetLevelStyle(STYLE_DOT, 1, clrYellow);

   return(0);
}

int deinit()
{
   ObjectDelete("DivTrend");
   ObjectDelete("DivTrace");
   ObjectDelete("DivArrow");
   return(0);
}

int start()
{
   int counted = IndicatorCounted();
   if (counted < 0) return(-1);
   if (counted > 0) counted--;
   int limit = Bars - counted;

   for (int i = 0; i < limit; i++)
   {
      stochK[i] = iStochastic(NULL, 0, K, SD, D, MODE_SMA, 0, MODE_MAIN, i);
      stochD[i] = iStochastic(NULL, 0, K, SD, D, MODE_SMA, 0, MODE_SIGNAL, i);
   }

   num_peaks = 0;
   for (int shift = 1; shift < Bars - 1 && num_peaks < 10000; shift++)
   {
      bool is_max = (stochD[shift + 1] < stochD[shift]) && (stochD[shift] > stochD[shift - 1]);
      bool is_min = (stochD[shift + 1] > stochD[shift]) && (stochD[shift] < stochD[shift - 1]);
      if (is_max || is_min)
      {
         peaks[num_peaks] = shift;
         num_peaks++;
      }
   }

   ObjectDelete("DivTrend");
   ObjectDelete("DivTrace");
   ObjectDelete("DivArrow");

   int subwin = WindowFind("Slow Stochastic With Divergences");
   if (subwin == -1) subwin = 1;

   int ii = 0;
   int curr_shift = (ii < num_peaks ? peaks[ii] : -1);
   int prev1_shift = -1;
   int prev2_shift = -1;
   while (curr_shift != -1)
   {
      ii++;
      prev2_shift = prev1_shift;
      prev1_shift = curr_shift;
      curr_shift = (ii < num_peaks ? peaks[ii] : -1);

      if (prev2_shift != -1 && curr_shift != -1)
      {
         if (stochD[curr_shift] > ob && stochD[curr_shift] > stochD[prev2_shift] &&
             stochD[curr_shift - 1] < stochD[curr_shift] &&
             Close[curr_shift] < Close[prev2_shift])
         {
            datetime t1 = Time[curr_shift];
            datetime t2 = Time[prev2_shift];
            double v1 = stochD[curr_shift];
            double v2 = stochD[prev2_shift];

            ObjectCreate("DivTrend", OBJ_TREND, subwin, t1, v1, t2, v2);
            ObjectSet("DivTrend", OBJPROP_COLOR, divergence_color_down);
            ObjectSet("DivTrend", OBJPROP_WIDTH, divergence_width);
            ObjectSet("DivTrend", OBJPROP_STYLE, divergence_style);
            ObjectSet("DivTrend", OBJPROP_RAY, false);
            ObjectSet("DivTrend", OBJPROP_BACK, false);

            double dx = (double)(t2 - t1);
            double dy = v2 - v1;
            double a = (dx != 0) ? dy / dx : 0;
            int per_sec = Period() * 60;
            datetime right_t = Time[0] + per_sec * 100;
            double right_v = v2 + a * (right_t - t2);

            ObjectCreate("DivTrace", OBJ_TREND, subwin, t2, v2, right_t, right_v);
            ObjectSet("DivTrace", OBJPROP_COLOR, trace_color_down);
            ObjectSet("DivTrace", OBJPROP_WIDTH, trace_width);
            ObjectSet("DivTrace", OBJPROP_STYLE, trace_style);
            ObjectSet("DivTrace", OBJPROP_RAY, false);
            ObjectSet("DivTrace", OBJPROP_BACK, false);

            ObjectCreate("DivArrow", OBJ_ARROW, 0, t1, High[curr_shift] + (High[curr_shift] - Low[curr_shift]) * 0.1);
            ObjectSet("DivArrow", OBJPROP_ARROWCODE, 234);
            ObjectSet("DivArrow", OBJPROP_COLOR, arrow_color_down);
            ObjectSet("DivArrow", OBJPROP_WIDTH, arrow_size);
            ObjectSet("DivArrow", OBJPROP_BACK, false);

            return(0);
         }
         else if (stochD[curr_shift] < os && stochD[curr_shift] < stochD[prev2_shift] &&
                  stochD[curr_shift - 1] > stochD[curr_shift] &&
                  Close[curr_shift] > Close[prev2_shift])
         {
            datetime t1 = Time[curr_shift];
            datetime t2 = Time[prev2_shift];
            double v1 = stochD[curr_shift];
            double v2 = stochD[prev2_shift];

            ObjectCreate("DivTrend", OBJ_TREND, subwin, t1, v1, t2, v2);
            ObjectSet("DivTrend", OBJPROP_COLOR, divergence_color_up);
            ObjectSet("DivTrend", OBJPROP_WIDTH, divergence_width);
            ObjectSet("DivTrend", OBJPROP_STYLE, divergence_style);
            ObjectSet("DivTrend", OBJPROP_RAY, false);
            ObjectSet("DivTrend", OBJPROP_BACK, false);

            double dx = (double)(t2 - t1);
            double dy = v2 - v1;
            double a = (dx != 0) ? dy / dx : 0;
            int per_sec = Period() * 60;
            datetime right_t = Time[0] + per_sec * 100;
            double right_v = v2 + a * (right_t - t2);

            ObjectCreate("DivTrace", OBJ_TREND, subwin, t2, v2, right_t, right_v);
            ObjectSet("DivTrace", OBJPROP_COLOR, trace_color_up);
            ObjectSet("DivTrace", OBJPROP_WIDTH, trace_width);
            ObjectSet("DivTrace", OBJPROP_STYLE, trace_style);
            ObjectSet("DivTrace", OBJPROP_RAY, false);
            ObjectSet("DivTrace", OBJPROP_BACK, false);

            ObjectCreate("DivArrow", OBJ_ARROW, 0, t1, Low[curr_shift] - (High[curr_shift] - Low[curr_shift]) * 0.1);
            ObjectSet("DivArrow", OBJPROP_ARROWCODE, 233);
            ObjectSet("DivArrow", OBJPROP_COLOR, arrow_color_up);
            ObjectSet("DivArrow", OBJPROP_WIDTH, arrow_size);
            ObjectSet("DivArrow", OBJPROP_BACK, false);

            return(0);
         }
      }
   }

   return(0);
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76370
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