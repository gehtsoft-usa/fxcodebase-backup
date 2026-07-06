//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=61129
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
#property indicator_buffers 7
#property indicator_plots   3

#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Hist"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

input int Short_Length=12;
input int Long_Length=26;
input int Signal_Length=9;
input ENUM_MA_METHOD Method=MODE_SMA;
input ENUM_APPLIED_PRICE Price=PRICE_CLOSE;

double MACD[];
double Signal[];
double Hist[];
double cmacd[];
double xMA[];
double yMA[];
double Pr[];

double ax, ay, az;

int handle_short_ma;
int handle_long_ma;
int handle_price_ma;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   PlotIndexSetString(0, PLOT_LABEL, "MACD");
   PlotIndexSetString(1, PLOT_LABEL, "Signal");
   PlotIndexSetString(2, PLOT_LABEL, "Hist");
   
   IndicatorSetString(INDICATOR_SHORTNAME, "Reverse MACD");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   SetIndexBuffer(0, MACD, INDICATOR_DATA);
   SetIndexBuffer(1, Signal, INDICATOR_DATA);
   SetIndexBuffer(2, Hist, INDICATOR_DATA);
   SetIndexBuffer(3, cmacd, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, xMA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, yMA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, Pr, INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(MACD, true);
   ArraySetAsSeries(Signal, true);
   ArraySetAsSeries(Hist, true);
   ArraySetAsSeries(cmacd, true);
   ArraySetAsSeries(xMA, true);
   ArraySetAsSeries(yMA, true);
   ArraySetAsSeries(Pr, true);
   
   ax = 2.0 / (1.0 + Short_Length);
   ay = 2.0 / (1.0 + Long_Length);
   az = 2.0 / (1.0 + Signal_Length);
   
   handle_short_ma = iMA(_Symbol, _Period, Short_Length, 0, Method, Price);
   handle_long_ma = iMA(_Symbol, _Period, Long_Length, 0, Method, Price);
   
   if(Method == MODE_SMA)
   {
      handle_price_ma = iMA(_Symbol, _Period, 1, 0, MODE_SMA, Price);
   }
   else
   {
      handle_price_ma = -1;
   }
   
   if(handle_short_ma == INVALID_HANDLE || handle_long_ma == INVALID_HANDLE)
   {
      Print("Error creating MA handles");
      return(INIT_FAILED);
   }
   
   if(Method == MODE_SMA && handle_price_ma == INVALID_HANDLE)
   {
      Print("Error creating price MA handle");
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handle_short_ma != INVALID_HANDLE) IndicatorRelease(handle_short_ma);
   if(handle_long_ma != INVALID_HANDLE) IndicatorRelease(handle_long_ma);
   if(handle_price_ma != INVALID_HANDLE) IndicatorRelease(handle_price_ma);
}

//+------------------------------------------------------------------+
//| Calculate MA on array                                              |
//+------------------------------------------------------------------+
double CalculateMAOnArray(double &array[], int period, ENUM_MA_METHOD method, int pos)
{
   if(method == MODE_SMA)
   {
      double sum = 0.0;
      for(int i = 0; i < period; i++)
      {
         if(pos + i >= ArraySize(array)) return 0.0;
         sum += array[pos + i];
      }
      return sum / period;
   }
   else // EMA
   {
      double alpha = 2.0 / (1.0 + period);
      double ema = array[pos];
      for(int i = 1; i < period; i++)
      {
         if(pos + i >= ArraySize(array)) break;
         ema = alpha * array[pos + i] + (1.0 - alpha) * ema;
      }
      return ema;
   }
}

//+------------------------------------------------------------------+
//| Get price value                                                   |
//+------------------------------------------------------------------+
double GetPrice(int shift)
{
   switch(Price)
   {
      case PRICE_CLOSE: return iClose(_Symbol, _Period, shift);
      case PRICE_OPEN: return iOpen(_Symbol, _Period, shift);
      case PRICE_HIGH: return iHigh(_Symbol, _Period, shift);
      case PRICE_LOW: return iLow(_Symbol, _Period, shift);
      case PRICE_MEDIAN: return (iHigh(_Symbol, _Period, shift) + iLow(_Symbol, _Period, shift)) / 2.0;
      case PRICE_TYPICAL: return (iHigh(_Symbol, _Period, shift) + iLow(_Symbol, _Period, shift) + iClose(_Symbol, _Period, shift)) / 3.0;
      case PRICE_WEIGHTED: return (iHigh(_Symbol, _Period, shift) + iLow(_Symbol, _Period, shift) + iClose(_Symbol, _Period, shift) + iClose(_Symbol, _Period, shift)) / 4.0;
      default: return iClose(_Symbol, _Period, shift);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                  |
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
   if(rates_total <= 3) return(0);
   
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   
   int limit = rates_total - 2;
   if(prev_calculated > 2) limit = rates_total - prev_calculated - 1;
   
   if(limit < 0) limit = 0;
   
   int max_shift = rates_total - 1;
   if(Long_Length > Short_Length)
      max_shift = rates_total - Long_Length - 1;
   else
      max_shift = rates_total - Short_Length - 1;
   
   if(limit > max_shift) limit = max_shift;
   
   double ma_short[], ma_long[], ma_price[];
   ArraySetAsSeries(ma_short, true);
   ArraySetAsSeries(ma_long, true);
   ArraySetAsSeries(ma_price, true);
   
   if(CopyBuffer(handle_short_ma, 0, 0, rates_total, ma_short) <= 0) return(0);
   if(CopyBuffer(handle_long_ma, 0, 0, rates_total, ma_long) <= 0) return(0);
   
   if(Method == MODE_SMA)
   {
      if(CopyBuffer(handle_price_ma, 0, 0, rates_total, ma_price) <= 0) return(0);
   }
   
   int pos;
   double zMA;
   
   if(Method == MODE_SMA) // SMA
   {
      pos = limit;
      while(pos >= 0)
      {
         if(pos + Short_Length - 1 >= rates_total || pos + Long_Length - 1 >= rates_total)
         {
            pos--;
            continue;
         }
         
         xMA[pos] = ma_short[pos];
         yMA[pos] = ma_long[pos];
         Pr[pos] = ma_price[pos];
         
         cmacd[pos] = xMA[pos] - yMA[pos];
         
         pos--;
      }
      
      pos = limit;
      while(pos >= 0)
      {
         if(pos + Short_Length - 1 >= rates_total || pos + Long_Length - 1 >= rates_total || 
            pos + Signal_Length - 1 >= rates_total)
         {
            pos--;
            continue;
         }
         
         zMA = CalculateMAOnArray(cmacd, Signal_Length, Method, pos);
         
         int idx1 = pos + Long_Length - 1;
         int idx2 = pos + Short_Length - 1;
         int idx3 = pos + Signal_Length - 1;
         
         if(idx1 >= rates_total || idx2 >= rates_total || idx3 >= rates_total)
         {
            pos--;
            continue;
         }
         
         MACD[pos] = (Short_Length * Pr[idx1] - Long_Length * Pr[idx2]) / (Short_Length - Long_Length);
         Signal[pos] = (Short_Length * Long_Length * (xMA[pos] - yMA[pos]) + Short_Length * Pr[idx1] - Long_Length * Pr[idx2]) / (Short_Length - Long_Length);
         Hist[pos] = ((Short_Length * Long_Length * Signal_Length - Short_Length * Long_Length) * cmacd[pos] - 
                     Short_Length * Long_Length * Signal_Length * zMA - 
                     (Long_Length * Signal_Length - Long_Length) * Pr[idx2] + 
                     (Short_Length * Signal_Length - Short_Length) * Pr[idx1] + 
                     Short_Length * Long_Length * cmacd[idx3]) / 
                     (Short_Length * Signal_Length - Long_Length * Signal_Length - Short_Length + Long_Length);
         
         pos--;
      }
   }
   else // EMA
   {
      pos = limit;
      while(pos >= 0)
      {
         if(pos + Short_Length - 1 >= rates_total || pos + Long_Length - 1 >= rates_total)
         {
            pos--;
            continue;
         }
         
         xMA[pos] = ma_short[pos];
         yMA[pos] = ma_long[pos];
         
         cmacd[pos] = xMA[pos] - yMA[pos];
         
         pos--;
      }
      
      pos = limit;
      while(pos >= 0)
      {
         if(pos + Signal_Length - 1 >= rates_total)
         {
            pos--;
            continue;
         }
         
         zMA = CalculateMAOnArray(cmacd, Signal_Length, Method, pos);
         
         MACD[pos] = (ax * xMA[pos] - ay * yMA[pos]) / (ax - ay);
         Signal[pos] = ((1.0 - ay) * yMA[pos] - (1.0 - ax) * xMA[pos]) / (ax - ay);
         Hist[pos] = (zMA - (1.0 - ax) * xMA[pos] + (1.0 - ay) * yMA[pos]) / (ax - ay);
         
         pos--;
      }
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=61129
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