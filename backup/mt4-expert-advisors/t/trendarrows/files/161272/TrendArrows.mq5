/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        TrendArrows
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161114#p161114
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

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1   DRAW_ARROW
#property indicator_color1  Magenta
#property indicator_width1  1
#property indicator_label1  "Sell Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_width2  1
#property indicator_label2  "Buy Signal"
enum AlertType
  {
   Current = 0,   // At current bar
   Previous = 1   // At previous closed bar
  };
input int ADX_Period = 14;           // ADX Period
input int DeltaAdx = 3;              // Delta ADX
input int Smoothing = 3;             // Smoothing Period
input int SignalGap = 10;            // Signal Gap (points)
input bool UseAlerts = true;         // Use Alerts
input AlertType AlertOn = Current;   // Alert On
double b1[];
double b2[];
double b3[];
int adxHandle;
datetime lastAlertUpCurrent = 0;
datetime lastAlertDownCurrent = 0;
datetime lastAlertUpPrevious = 0;
datetime lastAlertDownPrevious = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   adxHandle = iADX(_Symbol, _Period, ADX_Period);
   if(adxHandle == INVALID_HANDLE)
     {
      Print("Failed to create ADX indicator handle");
      return(INIT_FAILED);
     }
   SetIndexBuffer(0, b2, INDICATOR_DATA);
   SetIndexBuffer(1, b3, INDICATOR_DATA);
   SetIndexBuffer(2, b1, INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_ARROW, 234);
   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   ArraySetAsSeries(b1, true);
   ArraySetAsSeries(b2, true);
   ArraySetAsSeries(b3, true);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(adxHandle != INVALID_HANDLE)
      IndicatorRelease(adxHandle);
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
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(time, true);
   int counted_bars = prev_calculated;
   int limit;
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   limit = rates_total - 1;
   if(counted_bars >= 1)
      limit = rates_total - counted_bars - 1;
   if(limit < 0)
      limit = 0;
   if(rates_total < ADX_Period + Smoothing)
      return(0);
   double tempADX[];
   if(CopyBuffer(adxHandle, 0, 0, rates_total, tempADX) <= 0)
     {
      Print("Failed to copy ADX buffer");
      return(0);
     }
   ArraySetAsSeries(tempADX, true);
   for(int i = 0; i <= limit; i++)
     {
      b1[i] = tempADX[i];
     }
   double plusDI[], minusDI[];
   if(CopyBuffer(adxHandle, 1, 0, rates_total, plusDI) <= 0)
     {
      Print("Failed to copy +DI buffer");
      return(0);
     }
   ArraySetAsSeries(plusDI, true);
   if(CopyBuffer(adxHandle, 2, 0, rates_total, minusDI) <= 0)
     {
      Print("Failed to copy -DI buffer");
      return(0);
     }
   ArraySetAsSeries(minusDI, true);
   for(int i = limit; i >= 0; i--)
     {
      b2[i] = 0.0;
      b3[i] = 0.0;
      double sma_i_minus_1 = CalculateSMA(b1, i - 1, Smoothing, rates_total);
      double sma_i = CalculateSMA(b1, i, Smoothing, rates_total);
      double Delta = sma_i_minus_1 - sma_i;
      double Signal = plusDI[i] - minusDI[i];
      if(Delta > DeltaAdx && Signal < 0)
        {
         b2[i] = high[i] + SignalGap * _Point;
        }
      if(Delta > DeltaAdx && Signal > 0)
        {
         b3[i] = low[i] - SignalGap * _Point;
        }
     }
   if(UseAlerts && rates_total > 1)
     {
      double sma_0_minus_1 = CalculateSMA(b1, -1, Smoothing, rates_total);
      double sma_0 = CalculateSMA(b1, 0, Smoothing, rates_total);
      double Delta0 = sma_0_minus_1 - sma_0;
      double Signal0 = plusDI[0] - minusDI[0];
      double sma_1_minus_1 = CalculateSMA(b1, 0, Smoothing, rates_total);
      double sma_1 = CalculateSMA(b1, 1, Smoothing, rates_total);
      double Delta1 = sma_1_minus_1 - sma_1;
      double Signal1 = plusDI[1] - minusDI[1];
      bool isSell0 = (Delta0 > DeltaAdx && Signal0 < 0);
      bool isBuy0  = (Delta0 > DeltaAdx && Signal0 > 0);
      bool isSell1 = (Delta1 > DeltaAdx && Signal1 < 0);
      bool isBuy1  = (Delta1 > DeltaAdx && Signal1 > 0);
      if(AlertOn == Current)
        {
         if(isBuy0 && lastAlertUpCurrent != time[0])
           {
            Alert(_Symbol, " ", EnumToString((ENUM_TIMEFRAMES)_Period), ": Buy signal on current candle");
            lastAlertUpCurrent = time[0];
           }
         if(isSell0 && lastAlertDownCurrent != time[0])
           {
            Alert(_Symbol, " ", EnumToString((ENUM_TIMEFRAMES)_Period), ": Sell signal on current candle");
            lastAlertDownCurrent = time[0];
           }
        }
      if(AlertOn == Previous)
        {
         if(isBuy1 && lastAlertUpPrevious != time[1])
           {
            Alert(_Symbol, " ", EnumToString((ENUM_TIMEFRAMES)_Period), ": Buy signal on previous candle close");
            lastAlertUpPrevious = time[1];
           }
         if(isSell1 && lastAlertDownPrevious != time[1])
           {
            Alert(_Symbol, " ", EnumToString((ENUM_TIMEFRAMES)_Period), ": Sell signal on previous candle close");
            lastAlertDownPrevious = time[1];
           }
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateSMA(const double &array[], int shift, int period, int rates_total)
  {
   if(shift < 0)
     {
      shift = 0;
     }
   if(shift + period > rates_total)
      return(0.0);
   double sum = 0.0;
   for(int i = shift; i < shift + period; i++)
     {
      sum += array[i];
     }
   return(sum / period);
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        TrendArrows
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161114#p161114
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
