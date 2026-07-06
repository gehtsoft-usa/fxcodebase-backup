//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76436
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
#property indicator_plots 2
#property indicator_buffers 2

#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrLime
#property indicator_width1 1
#property indicator_label1 "Up"

#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_label2 "Down"

input int               InpExtDepth      = 10;
input int               InpDeviation     = 5;
input int               InpBackstep      = 3;
input ENUM_TIMEFRAMES   InpExtTimeframe  = PERIOD_CURRENT;

input string T1 = "== Notifications ==";
input bool   InpNotifications         = false;
input bool   InpDesktopNotifications  = false;
input bool   InpEmailNotifications    = false;
input bool   InpPushNotifications     = false;

double   UpArrowBuffer[];
double   DownArrowBuffer[];
datetime TimeframeTimeArray[];

int      zigzagHandle           = INVALID_HANDLE;
datetime lastUpNotificationTime = 0;
datetime lastDownNotificationTime = 0;

int OnInit()
{
   ArraySetAsSeries(UpArrowBuffer, true);
   ArraySetAsSeries(DownArrowBuffer, true);
   ArraySetAsSeries(TimeframeTimeArray, true);

   SetIndexBuffer(0, UpArrowBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_ARROW, 228);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(1, DownArrowBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_ARROW, 230);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

   zigzagHandle = iCustom(_Symbol, InpExtTimeframe, "ZigZag", InpExtDepth, InpDeviation, InpBackstep);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(zigzagHandle != INVALID_HANDLE)
   {
      IndicatorRelease(zigzagHandle);
      zigzagHandle = INVALID_HANDLE;
   }
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
   if(rates_total < 2)
      return 0;

   if(InpExtTimeframe != PERIOD_CURRENT && _Period > InpExtTimeframe)
      return prev_calculated;

   if(zigzagHandle == INVALID_HANDLE)
      return prev_calculated;

   int calculatedBars = BarsCalculated(zigzagHandle);
   if(calculatedBars <= 0)
      return prev_calculated;

   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;
   if(limit > rates_total)
      limit = rates_total;
   if(limit > 300)
      limit = 300;

   if(ArraySize(UpArrowBuffer) < rates_total)
   {
      ArrayResize(UpArrowBuffer, rates_total);
      ArrayResize(DownArrowBuffer, rates_total);
   }
   ArraySetAsSeries(UpArrowBuffer, true);
   ArraySetAsSeries(DownArrowBuffer, true);

   double zigzagBuffer[];
   ArrayResize(zigzagBuffer, calculatedBars);
   if(CopyBuffer(zigzagHandle, 0, 0, calculatedBars, zigzagBuffer) <= 0)
      return prev_calculated;
   ArraySetAsSeries(zigzagBuffer, true);

   if(InpExtTimeframe == PERIOD_CURRENT)
   {
      for(int i = 0; i < limit && i < rates_total - 1; i++)
      {
         UpArrowBuffer[i] = 0.0;
         DownArrowBuffer[i] = 0.0;

         int barIdx = rates_total - 1 - i;
         if(barIdx <= 0)
            continue;

         int prevBarIdx = barIdx - 1;
         if(prevBarIdx < 0)
            continue;

         double zigzagValue = FindZigZagValue(zigzagBuffer, i, calculatedBars);

         if(zigzagValue == 0.0)
            continue;

         double prevClose = close[prevBarIdx];
         bool prevHasUpSignal = false;
         bool prevHasDownSignal = false;
         
         if(i + 1 < rates_total)
         {
            int nextBarIdx = rates_total - 1 - (i + 1);
            if(nextBarIdx > 0)
            {
               double prevZigzagValue = FindZigZagValue(zigzagBuffer, i + 1, calculatedBars);
               if(prevZigzagValue != 0.0 && nextBarIdx - 1 >= 0)
               {
                  double prevPrevClose = close[nextBarIdx - 1];
                  prevHasUpSignal = (prevPrevClose >= prevZigzagValue);
                  prevHasDownSignal = (prevPrevClose <= prevZigzagValue);
               }
            }
         }

         ProcessSignal(i, zigzagValue, prevClose, prevHasUpSignal, prevHasDownSignal, time[barIdx], prev_calculated);
      }
   }
   else
   {
      int copyCount = CopyTime(_Symbol, InpExtTimeframe, 0, rates_total + 200, TimeframeTimeArray);
      if(copyCount <= 0)
         return prev_calculated;

      datetime timeArray[];
      double closeArray[];
      ArrayResize(timeArray, rates_total);
      ArrayResize(closeArray, rates_total);
      ArrayCopy(timeArray, time, 0, 0, rates_total);
      ArrayCopy(closeArray, close, 0, 0, rates_total);
      ArraySetAsSeries(timeArray, true);
      ArraySetAsSeries(closeArray, true);

      for(int i = 0; i < limit && i < rates_total - 1; i++)
      {
         UpArrowBuffer[i] = 0.0;
         DownArrowBuffer[i] = 0.0;

         if(i + 1 >= rates_total)
            continue;

         int timeframeBarIndex = 0;
         if(timeArray[i] >= TimeframeTimeArray[0])
            timeframeBarIndex = 0;
         else
         {
            datetime searchTime = (i > 0) ? timeArray[i - 1] : timeArray[i];
            timeframeBarIndex = copyCount - 1;
            for(int idx = 0; idx < copyCount; idx++)
            {
               if(TimeframeTimeArray[idx] <= searchTime)
               {
                  timeframeBarIndex = idx;
                  break;
               }
            }
            if(_Period <= InpExtTimeframe && timeframeBarIndex < copyCount - 1)
               timeframeBarIndex++;
         }

         if(timeframeBarIndex < 0)
            timeframeBarIndex = 0;
         if(timeframeBarIndex >= copyCount)
            timeframeBarIndex = copyCount - 1;

         double zigzagValue = FindZigZagValue(zigzagBuffer, timeframeBarIndex, calculatedBars);

         if(zigzagValue == 0.0)
            continue;

         double prevClose = closeArray[i + 1];
         bool prevHasUpSignal = false;
         bool prevHasDownSignal = false;
         
         if(i + 2 < rates_total)
         {
            double prevZigzagValue = FindZigZagValue(zigzagBuffer, timeframeBarIndex, calculatedBars);
            if(prevZigzagValue != 0.0)
            {
               double prevPrevClose = closeArray[i + 2];
               prevHasUpSignal = (prevPrevClose >= prevZigzagValue);
               prevHasDownSignal = (prevPrevClose <= prevZigzagValue);
            }
         }

         ProcessSignal(i, zigzagValue, prevClose, prevHasUpSignal, prevHasDownSignal, timeArray[i], prev_calculated);
      }
   }

   return rates_total;
}

double FindZigZagValue(double &zigzagBuffer[], int startIdx, int calculatedBars)
{
   for(int j = 0; j < 100 && startIdx + j + 1 < calculatedBars; j++)
   {
      if(zigzagBuffer[startIdx + j + 1] != 0.0)
         return zigzagBuffer[startIdx + j + 1];
   }
   return 0.0;
}

void ProcessSignal(int i, double zigzagValue, double prevClose, 
                   bool prevHasUpSignal, bool prevHasDownSignal, 
                   datetime barTime, int prev_calculated)
{
   bool hasUpSignal = (prevClose >= zigzagValue);
   bool hasDownSignal = (prevClose <= zigzagValue);

   if(hasUpSignal && !prevHasUpSignal)
   {
      UpArrowBuffer[i] = zigzagValue;
      if(prev_calculated > 0 && barTime != lastUpNotificationTime)
      {
         Notifications(0);
         lastUpNotificationTime = barTime;
      }
   }

   if(hasDownSignal && !prevHasDownSignal)
   {
      DownArrowBuffer[i] = zigzagValue;
      if(prev_calculated > 0 && barTime != lastDownNotificationTime)
      {
         Notifications(1);
         lastDownNotificationTime = barTime;
      }
   }
}

string GetTimeFrame(ENUM_TIMEFRAMES period)
{
   switch(period)
   {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
   }
   return IntegerToString((int)period);
}

void Notifications(int type)
{
   if(!InpNotifications)
      return;
   
   string text = "";
   if(type == 0)
      text = _Symbol + " " + GetTimeFrame(_Period) + " BUY";
   else
      text = _Symbol + " " + GetTimeFrame(_Period) + " SELL";
   
   if(InpDesktopNotifications)
      Alert(text);
   
   if(InpPushNotifications)
      SendNotification(text);
   
   if(InpEmailNotifications)
      SendMail("Bamsbung-Trend2 Notification", text);
}

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76436
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