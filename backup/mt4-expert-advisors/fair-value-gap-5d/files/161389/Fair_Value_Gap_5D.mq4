//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76477
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
PayPal:      https://paypal.me/mariojemic
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
#property indicator_chart_window

input string   grp_settings = "=== Settings ==="; 
input double   InpThresholdPer = 0.0;     // Threshold %
input bool     InpAuto         = false;   // Auto Threshold
input int      InpShowLast     = 0;       // Unmitigated Levels (Count)
input bool     InpMitigation   = false;   // Mitigation Levels (Draw Lines)

input string   grp_style    = "=== Style ===";
input int      InpExtend    = 20;         // Extend Bars
input bool     InpDynamic   = false;      // Dynamic Mode
input color    InpBullCss   = C'8,153,129'; // Bullish FVG Color
input color    InpBearCss   = C'242,54,69'; // Bearish FVG Color

input string   grp_dash     = "=== Dashboard ===";
input bool     InpShowDash  = false;      // Show Dashboard

string PREFIX = "FVG_Lux_";
int    total_bull = 0;
int    total_bear = 0;
int    mitigated_bull = 0;
int    mitigated_bear = 0;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, PREFIX);
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
   if(rates_total < 3) return(0);
   
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0) limit += 1;
   
   if(prev_calculated == 0) {
      ObjectsDeleteAll(0, PREFIX);
      total_bull = 0;
      total_bear = 0;
      mitigated_bull = 0;
      mitigated_bear = 0;
      limit = rates_total - 3;
   }

   double cum_volatility = 0;
   if(InpAuto && prev_calculated == 0) {
      for(int i=rates_total-1; i>=0; i--) {
         if(low[i] > 0)
            cum_volatility += (high[i] - low[i]) / low[i];
      }
   }

   CheckExistingFVGMitigation(time, high, low, rates_total);
   
   for(int i = limit; i >= 0; i--) {
      if(i > rates_total - 4) continue;

      double threshold = InpAuto ? (rates_total > 0 ? cum_volatility / rates_total : InpThresholdPer / 100.0) : InpThresholdPer / 100.0;
      
      bool is_bull = false;
      bool is_bear = false;
      
      if(low[i] > high[i+2] && close[i+1] > high[i+2] && high[i+2] > 0 && (low[i] - high[i+2])/high[i+2] > threshold) {
         is_bull = true;
      }
      
      if(high[i] < low[i+2] && close[i+1] < low[i+2] && high[i] > 0 && (low[i+2] - high[i])/high[i] > threshold) {
         is_bear = true;
      }

      if(is_bull || is_bear) {
         datetime fvg_time = time[i+2];
         string obj_name = PREFIX + "Box_" + TimeToString(fvg_time);
         double fvg_top, fvg_bottom;
         color fvg_color;
         
         if(is_bull) {
            fvg_top = low[i];
            fvg_bottom = high[i+2];
            fvg_color = InpBullCss;
            if(ObjectFind(0, obj_name) < 0) total_bull++;
         } else {
            fvg_top = low[i+2];
            fvg_bottom = high[i];
            fvg_color = InpBearCss;
            if(ObjectFind(0, obj_name) < 0) total_bear++;
         }

         bool mitigated = false;
         datetime end_time = time[i] + InpExtend * PeriodSeconds();
         int mitigated_idx = -1;

         for(int k = i - 1; k >= 0; k--) {
            if(is_bull) {
               if(low[k] < fvg_bottom) {
                  mitigated = true;
                  mitigated_idx = k;
                  break;
               }
            } else {
               if(high[k] > fvg_top) {
                  mitigated = true;
                  mitigated_idx = k;
                  break;
               }
            }
         }
         
         if(mitigated) {
            end_time = time[mitigated_idx];
            if(ObjectFind(0, obj_name) < 0) {
               if(is_bull) mitigated_bull++; else mitigated_bear++;
            }
         }
         
         if(mitigated && !InpMitigation) {
            ObjectDelete(0, obj_name);
         } else {
            DrawBox(obj_name, fvg_time, end_time, fvg_top, fvg_bottom, fvg_color, !mitigated);
            if(mitigated && InpMitigation) {
               string line_name = PREFIX + "Line_" + TimeToString(fvg_time);
               DrawLine(line_name, fvg_time, end_time, (is_bull?fvg_bottom:fvg_top), fvg_color);
               ObjectDelete(0, obj_name);
            }
         }
      }
   }
   
   if(InpShowDash) UpdateDashboard();
   return(rates_total);
}

void CheckExistingFVGMitigation(const datetime &time[], const double &high[], const double &low[], int rates_total)
{
   int total = ObjectsTotal(0, 0, OBJ_RECTANGLE);
   for(int i = total - 1; i >= 0; i--) {
      string obj_name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      if(StringFind(obj_name, PREFIX + "Box_") != 0) continue;

      double price1 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE1);
      double price2 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE2);
      double fvg_top    = MathMax(price1, price2);
      double fvg_bottom = MathMin(price1, price2);
      bool is_bull = (ObjectGetInteger(0, obj_name, OBJPROP_COLOR) == InpBullCss);

      bool mitigated = false;
      if(is_bull) {
         if(low[0] < fvg_bottom) mitigated = true;
      } else {
         if(high[0] > fvg_top)   mitigated = true;
      }

      if(mitigated) {
         if(InpMitigation) {
            string line_name = PREFIX + "Line_" + obj_name;
            if(ObjectFind(0, line_name) < 0)
               DrawLine(line_name, ObjectGetInteger(0, obj_name, OBJPROP_TIME1), time[0], (is_bull?fvg_bottom:fvg_top), is_bull?InpBullCss:InpBearCss);
         }
         ObjectDelete(0, obj_name);
      }
   }
}

void DrawBox(string name, datetime t1, datetime t2, double price1, double price2, color clr, bool fill)
{
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, price1, t2, price2);
   } else {
      ObjectSetDouble(0, name, OBJPROP_PRICE1, price1);
      ObjectSetDouble(0, name, OBJPROP_PRICE2, price2);
      ObjectSetInteger(0, name, OBJPROP_TIME1, t1);
      ObjectSetInteger(0, name, OBJPROP_TIME2, t2);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 0);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

void DrawLine(string name, datetime t1, datetime t2, double price, color clr)
{
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
}

void UpdateDashboard()
{
   string label_prefix = PREFIX + "Dash_";
   int x_base = 20;
   int y_base = 20;
   int corner = 0;
   color c_text = clrWhite;
   color c_bull = InpBullCss;
   color c_bear = InpBearCss;
   
   DrawLabel(label_prefix+"H1", x_base+60, y_base, "Bullish", c_bull, corner, 10);
   DrawLabel(label_prefix+"H2", x_base+120, y_base, "Bearish", c_bear, corner, 10);
   DrawLabel(label_prefix+"R1C0", x_base, y_base+20, "Count", c_text, corner, 10);
   DrawLabel(label_prefix+"R1C1", x_base+60, y_base+20, IntegerToString(total_bull), c_bull, corner, 10);
   DrawLabel(label_prefix+"R1C2", x_base+120, y_base+20, IntegerToString(total_bear), c_bear, corner, 10);
   DrawLabel(label_prefix+"R2C0", x_base, y_base+40, "Mitigated", c_text, corner, 10);
   DrawLabel(label_prefix+"R2C1", x_base+60, y_base+40, TotalPercent(mitigated_bull, total_bull), c_bull, corner, 10);
   DrawLabel(label_prefix+"R2C2", x_base+120, y_base+40, TotalPercent(mitigated_bear, total_bear), c_bear, corner, 10);
}

string TotalPercent(int val, int total)
{
   if(total == 0) return "0%";
   return DoubleToString(((double)val/total)*100, 1) + "%";
}

void DrawLabel(string name, int x, int y, string text, color clr, int corner, int fsize)
{
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fsize);
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76477
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
PayPal:      https://paypal.me/mariojemic
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