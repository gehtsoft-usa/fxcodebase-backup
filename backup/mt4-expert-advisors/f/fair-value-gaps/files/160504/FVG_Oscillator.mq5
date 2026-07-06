/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160398#p160398
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


#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1  DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "Up"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Crimson
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label2 "Dn"

//--- indicator buffers
double LineUp[];
double LineDn[];
double Data[];

//--- indicator input
input int Periods = 10;  // Indicator Periods

// ------------------------------------------------------------------
void OnInit()
{
  //--- indicator short name
  string short_name = "Line Indicator";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, 2);
  
  //--- Buffers 
	SetIndexBuffer(0, LineUp);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Periods);
  SetIndexBuffer(1, LineDn);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Periods);
  SetIndexBuffer(2, Data);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  if (rates_total < Periods) return (0);

  int start;
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = Periods + 1; }

  for(int i = start; i < rates_total && !IsStopped(); i++)
  {
        Data[i] = Data[i - 1];
        LineDn[i] = LineDn[i - 1];
        LineUp[i] = LineUp[i - 1];

        if(low[i] > high[i - 2])
        {
            if(Data[i - 1]>0)
                Data[i] += low[i] - high[i - 2];
            else
                Data[i] = low[i] - high[i - 2];

            LineUp[i]     = close[i] + Data[i];
            LineUp[i - 1] = close[i - 1] + Data[i - 1];
            LineDn[i]     = EMPTY_VALUE;

            // if(newCandle.IsNewCandle())
            // {
            //     Notifications(0);
            // }
        }

        if(high[i] < low[i - 2])
        {
            if(Data[i-1]<0)
                Data[i] += high[i] - low[i - 2];
            else
                Data[i] = high[i] - low[i - 2];
                
            LineDn[i] = close[i] + Data[i];
            LineDn[i - 1] = close[i - 1] + Data[i - 1];
            LineUp[i] = EMPTY_VALUE;

            // if(newCandle.IsNewCandle())
            // {
            //     Notifications(1);
            // }
        }
  }

  return (rates_total);
}
//+------------------------------------------------------------------+

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160398#p160398
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
