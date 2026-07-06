//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76450
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
#property indicator_buffers 3
#property indicator_plots   2

#property indicator_label1  "UP"
#property indicator_type1   DRAW_LINE
#property indicator_color1   clrBlue
#property indicator_style1   STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "DOWN"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

input bool ShowText = true;           // Show Text Label
input int  LookbackPeriod = 14;       // Lookback Period
input int  TextHorOffset = 50;        // Text Horizontal Offset

double IndicatorBuffer[];
double UpBuffer[];
double DownBuffer[];

string SignalText = "";
string IndicatorName = "TRENDSENTRY";
int MA_High_Handle = INVALID_HANDLE;
int MA_Low_Handle = INVALID_HANDLE;

int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);

   SetIndexBuffer(0, UpBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DownBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, IndicatorBuffer, INDICATOR_CALCULATIONS);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   ArraySetAsSeries(UpBuffer, true);
   ArraySetAsSeries(DownBuffer, true);
   ArraySetAsSeries(IndicatorBuffer, true);

   MA_High_Handle = iMA(_Symbol, _Period, 5, 0, MODE_SMA, PRICE_HIGH);
   MA_Low_Handle = iMA(_Symbol, _Period, 5, 0, MODE_SMA, PRICE_LOW);

   if(MA_High_Handle == INVALID_HANDLE || MA_Low_Handle == INVALID_HANDLE)
   {
      Print("Error creating MA indicators");
      return(INIT_FAILED);
   }

   if(ShowText) InitTextLabel();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   if(MA_High_Handle != INVALID_HANDLE)
      IndicatorRelease(MA_High_Handle);
   if(MA_Low_Handle != INVALID_HANDLE)
      IndicatorRelease(MA_Low_Handle);

   if(ObjectFind(0, IndicatorName) >= 0)
      ObjectDelete(0, IndicatorName);
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
   if(rates_total < LookbackPeriod + 35)
      return(0);

   int start_pos = 1;
   int limit;

   if(prev_calculated == 0)
   {
      ArrayInitialize(IndicatorBuffer, 0.0);
      ArrayInitialize(UpBuffer, EMPTY_VALUE);
      ArrayInitialize(DownBuffer, EMPTY_VALUE);
      limit = rates_total - LookbackPeriod - 35;
      if(limit < start_pos) limit = start_pos;
   }
   else
   {
      limit = rates_total - prev_calculated;
      if(limit < 1) limit = 1;
   }

   ArraySetAsSeries(UpBuffer, true);
   ArraySetAsSeries(DownBuffer, true);
   ArraySetAsSeries(IndicatorBuffer, true);

   double MA_High[];
   ArraySetAsSeries(MA_High, true);
   double MA_Low[];
   ArraySetAsSeries(MA_Low, true);

   if(CopyBuffer(MA_High_Handle, 0, 0, rates_total, MA_High) <= 0)
      return(0);
   if(CopyBuffer(MA_Low_Handle, 0, 0, rates_total, MA_Low) <= 0)
      return(0);

   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   double PreviousFilteredValue = 0;
   double PreviousIndicatorValue = 0;

   int calc_start = (prev_calculated == 0) ? rates_total - LookbackPeriod - 35 : rates_total - prev_calculated;
   if(calc_start < start_pos) calc_start = start_pos;

   for(int i = calc_start; i >= start_pos; i--)
   {
      if(prev_calculated > 0 && i < calc_start && IndicatorBuffer[i] != 0.0 && IndicatorBuffer[i] != EMPTY_VALUE)
      {
         if(i + 1 < rates_total)
         {
            PreviousIndicatorValue = IndicatorBuffer[i + 1];
            double PrevHigh = high[i + 1];
            double PrevLow = low[i + 1];
            int end_idx = i + 1 + LookbackPeriod;
            if(end_idx >= rates_total) end_idx = rates_total - 1;
            for(int j = i + 1; j <= end_idx; j++)
            {
               if(high[j] > PrevHigh) PrevHigh = high[j];
               if(low[j] < PrevLow) PrevLow = low[j];
            }
            if(PrevHigh != PrevLow)
            {
               double PrevTP = (high[i + 1] + low[i + 1] + close[i + 1]) / 3.0;
               PreviousFilteredValue = 0.66 * ((PrevTP - PrevLow) / (PrevHigh - PrevLow) - 0.5) + 0.67 * PreviousFilteredValue;
            }
         }
         continue;
      }

      double FilteredValue = 0;

      if(i + 1 < rates_total)
      {
         PreviousIndicatorValue = IndicatorBuffer[i + 1];

         double PrevHigh = high[i + 1];
         double PrevLow = low[i + 1];
         int end_idx = i + 1 + LookbackPeriod;
         if(end_idx >= rates_total) end_idx = rates_total - 1;
         for(int j = i + 1; j <= end_idx; j++)
         {
            if(high[j] > PrevHigh) PrevHigh = high[j];
            if(low[j] < PrevLow) PrevLow = low[j];
         }

         double PrevTP = (high[i + 1] + low[i + 1] + close[i + 1]) / 3.0;

         if(PrevHigh != PrevLow)
         {
            PreviousFilteredValue = 0.66 * ((PrevTP - PrevLow) / (PrevHigh - PrevLow) - 0.5) + 0.67 * PreviousFilteredValue;
         }
         else
         {
            PreviousFilteredValue = 0;
         }
      }
      else
      {
         PreviousFilteredValue = 0;
         PreviousIndicatorValue = 0;
      }

      double HighestPrice = high[i];
      double LowestPrice = low[i];
      int end_idx = i + LookbackPeriod;
      if(end_idx >= rates_total) end_idx = rates_total - 1;
      for(int j = i; j <= end_idx; j++)
      {
         if(high[j] > HighestPrice) HighestPrice = high[j];
         if(low[j] < LowestPrice) LowestPrice = low[j];
      }

      double TypicalPrice = (high[i] + low[i] + close[i]) / 3.0;

      if(HighestPrice != LowestPrice)
      {
         FilteredValue = 0.66 * ((TypicalPrice - LowestPrice) / (HighestPrice - LowestPrice) - 0.5) + 0.67 * PreviousFilteredValue;
      }
      else
      {
         FilteredValue = 0;
      }

      FilteredValue = MathMin(MathMax(FilteredValue, -0.999), 0.999);

      if(FilteredValue != -1.0 && FilteredValue != 1.0)
      {
         IndicatorBuffer[i] = MathLog((FilteredValue + 1.0) / (1.0 - FilteredValue)) / 2.0 + PreviousIndicatorValue / 2.0;
      }
      else
      {
         IndicatorBuffer[i] = PreviousIndicatorValue;
      }

      PreviousFilteredValue = FilteredValue;
      PreviousIndicatorValue = IndicatorBuffer[i];
   }

   bool IsBullish = true;
   int SignalColor = clrWhite;

   for(int i = calc_start; i >= start_pos; i--)
   {
      if(UpBuffer[i] != EMPTY_VALUE || DownBuffer[i] != EMPTY_VALUE)
      {
         if(i == start_pos)
         {
            if(UpBuffer[i] != EMPTY_VALUE)
            {
               SignalText = "LONG";
               SignalColor = clrLime;
            }
            else if(DownBuffer[i] != EMPTY_VALUE)
            {
               SignalText = "SHORT";
               SignalColor = clrRed;
            }
         }
         continue;
      }

      UpBuffer[i] = EMPTY_VALUE;
      DownBuffer[i] = EMPTY_VALUE;

      if(IndicatorBuffer[i] < 0.0)
         IsBullish = false;
      else
         IsBullish = true;

      if(!IsBullish)
      {
         DownBuffer[i] = MA_High[i];
         UpBuffer[i] = EMPTY_VALUE;
         if(i == start_pos)
         {
            SignalText = "SHORT";
            SignalColor = clrRed;
         }
      }
      else
      {
         UpBuffer[i] = MA_Low[i];
         DownBuffer[i] = EMPTY_VALUE;
         if(i == start_pos)
         {
            SignalText = "LONG";
            SignalColor = clrLime;
         }
      }
   }

   UpBuffer[0] = EMPTY_VALUE;
   DownBuffer[0] = EMPTY_VALUE;

   if(ShowText)
      UpdateTextLabel(IndicatorName, SignalText, 20, SignalColor, TextHorOffset + 100, 50);

   return(rates_total);
}

void InitTextLabel()
{
   if(ObjectFind(0, IndicatorName) < 0)
   {
      ObjectCreate(0, IndicatorName, OBJ_LABEL, 0, 0, 0);
   }
   UpdateTextLabel(IndicatorName, "", 20, clrWhite, TextHorOffset + 100, 50);
}

void UpdateTextLabel(string ObjectName, string Text, int FontSize, color TextColor, int XPosition, int YPosition)
{
   ObjectSetInteger(0, ObjectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, ObjectName, OBJPROP_XDISTANCE, XPosition);
   ObjectSetInteger(0, ObjectName, OBJPROP_YDISTANCE, YPosition);
   ObjectSetString(0, ObjectName, OBJPROP_TEXT, Text);
   ObjectSetString(0, ObjectName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, ObjectName, OBJPROP_FONTSIZE, FontSize);
   ObjectSetInteger(0, ObjectName, OBJPROP_COLOR, TextColor);
   ObjectSetInteger(0, ObjectName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, ObjectName, OBJPROP_BACK, false);
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76450
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