/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        ALMA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75853#p159026
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
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrPurple
#property indicator_color2 clrSilver
#property indicator_width1 2
#property indicator_width2 2
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
double Alma1Buffer[];
double Alma2Buffer[];
input int ALMA1_Length = 60;           // ALMA Length 1 (Fast)
input double ALMA1_Offset = 0.85;      // ALMA 1 - Offset Value
input int ALMA1_Sigma = 6;             // ALMA 1 - Sigma Value
input int ALMA2_Length = 120;          // ALMA Length 2 (Slow)
input double ALMA2_Offset = 0.85;      // ALMA 2 - Offset Value
input int ALMA2_Sigma = 6;             // ALMA 2 - Sigma Value

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, Alma1Buffer);
   SetIndexBuffer(1, Alma2Buffer);
   SetIndexLabel(0, "ALMA Fast");
   SetIndexLabel(1, "ALMA Slow");
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 2, clrPurple);
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 2, clrSilver);
   IndicatorShortName("ALMA Cross");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateALMA(const double &price[], int period, double offset, int sigma, int shift)
  {
   if(period <= 0 || sigma <= 0)
      return 0.0;
   double m = offset * (period - 1);
   double s = period / (double)sigma;
   double alma = 0.0;
   double wtdsum = 0.0;
   for(int i = 0; i < period; i++)
     {
      int bar_index = shift + (period - 1 - i);
      double weight = MathExp(-((i - m) * (i - m)) / (2 * s * s));
      alma += price[bar_index] * weight;
      wtdsum += weight;
     }
   if(wtdsum != 0.0)
      alma = alma / wtdsum;
   else
      alma = 0.0;
   return alma;
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
   int limit;
   if(prev_calculated == 0)
     {
      int max_period = MathMax(ALMA1_Length, ALMA2_Length);
      limit = rates_total - max_period - 1;
     }
   else
     {
      limit = rates_total - prev_calculated;
     }
   for(int i = limit; i >= 0; i--)
     {
      if(i + ALMA1_Length > rates_total - 1)
        {
         Alma1Buffer[i] = 0.0;
        }
      else
        {
         Alma1Buffer[i] = CalculateALMA(close, ALMA1_Length, ALMA1_Offset, ALMA1_Sigma, i);
        }
      if(i + ALMA2_Length > rates_total - 1)
        {
         Alma2Buffer[i] = 0.0;
        }
      else
        {
         Alma2Buffer[i] = CalculateALMA(close, ALMA2_Length, ALMA2_Offset, ALMA2_Sigma, i);
        }
     }
   return(rates_total);
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        ALMA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75853#p159026
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
