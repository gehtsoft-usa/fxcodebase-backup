//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=62034&p=99446&hilit=Reverse+Engineered#p99446
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

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3

#property indicator_label1  "Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Bottom"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Central"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

input int Price = 0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

input int RSI_Period = 14;
input double OB = 70;
input double CL = 50;
input double OS = 30;

double ExpPeriod;
double K;

double Top[];
double Bottom[];
double Central[];
double AUC[];
double ADC[];
double OB_Ratio, OS_Ratio, CL_Ratio;

int OnInit()
{
   if(RSI_Period <= 0) 
   {
      Print("Invalid RSI_Period");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(OB <= 0 || OB >= 100) 
   {
      Print("Invalid OB value");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(OS <= 0 || OS >= 100) 
   {
      Print("Invalid OS value");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(CL <= 0 || CL >= 100) 
   {
      Print("Invalid CL value");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   SetIndexBuffer(0, Top, INDICATOR_DATA);
   SetIndexBuffer(1, Bottom, INDICATOR_DATA);
   SetIndexBuffer(2, Central, INDICATOR_DATA);
   SetIndexBuffer(3, AUC, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, ADC, INDICATOR_CALCULATIONS);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "Reverse Engineered RSI");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   ExpPeriod = 2 * RSI_Period - 1;
   K = 2 / (ExpPeriod + 1);
   OB_Ratio = OB / (100.0 - OB);
   OS_Ratio = OS / (100.0 - OS);
   CL_Ratio = CL / (100.0 - CL);
   
   PlotIndexSetString(0, PLOT_LABEL, "Top");
   PlotIndexSetString(1, PLOT_LABEL, "Bottom");
   PlotIndexSetString(2, PLOT_LABEL, "Central");
   
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   
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
                const int &spread[])
{
   if(rates_total <= RSI_Period) return(0);
   
   int limit = rates_total - 1;
   if(prev_calculated > 0) 
      limit = rates_total - prev_calculated;
   
   if(limit < rates_total - 1) limit = rates_total - 1;
   
   if(prev_calculated == 0)
   {
      ArrayInitialize(AUC, 0.0);
      ArrayInitialize(ADC, 0.0);
      ArrayInitialize(Top, EMPTY_VALUE);
      ArrayInitialize(Bottom, EMPTY_VALUE);
      ArrayInitialize(Central, EMPTY_VALUE);
   }
   
   for(int pos = RSI_Period; pos <= limit; pos++)
   {
      double current_price = GetPriceValue(open, high, low, close, pos);
      double prev_price = GetPriceValue(open, high, low, close, pos - 1);
      
      if(current_price > prev_price)
      {
         AUC[pos] = K * (current_price - prev_price) + (1 - K) * AUC[pos - 1];
         ADC[pos] = (1 - K) * ADC[pos - 1];
      }
      else
      {
         AUC[pos] = (1 - K) * AUC[pos - 1];
         ADC[pos] = K * (prev_price - current_price) + (1 - K) * ADC[pos - 1];
      }
   }
   
   for(int pos = RSI_Period; pos <= limit; pos++)
   {
      double current_price = GetPriceValue(open, high, low, close, pos);
      CalculateRSILines(pos, current_price, AUC[pos], ADC[pos]);
   }
   
   if(limit >= 0 && rates_total > RSI_Period)
   {
      int pos = 0;
      double current_price = GetPriceValue(open, high, low, close, pos);
      CalculateRSILines(pos, current_price, AUC[pos], ADC[pos]);
   }
   
   return(rates_total);
}

double GetPriceValue(const double &open[], const double &high[], const double &low[], const double &close[], int index)
{
   switch(Price)
   {
      case 0: return close[index];
      case 1: return open[index];
      case 2: return high[index];
      case 3: return low[index];
      case 4: return (high[index] + low[index]) * 0.5;
      case 5: return (high[index] + low[index] + close[index]) / 3.0;
      case 6: return (high[index] + low[index] + 2.0 * close[index]) * 0.25;
      default: return close[index];
   }
}

void CalculateRSILines(int pos, double current_price, double auc, double adc)
{
   double x1, x2, x3;
   double multiplier = RSI_Period - 1;
   
   x1 = multiplier * (adc * OB_Ratio - auc);
   Top[pos] = current_price + (x1 >= 0 ? x1 : x1 * (100.0 - OB) / OB);
   
   x2 = multiplier * (adc * OS_Ratio - auc);
   Bottom[pos] = current_price + (x2 >= 0 ? x2 : x2 * (100.0 - OS) / OS);
   
   x3 = multiplier * (adc * CL_Ratio - auc);
   Central[pos] = current_price + (x3 >= 0 ? x3 : x3 * (100.0 - CL) / CL);
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=62034&p=99446&hilit=Reverse+Engineered#p99446
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