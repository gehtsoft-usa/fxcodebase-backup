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
#property indicator_buffers 2
#property indicator_color1 clrLime
#property indicator_color2 clrLime

int ExtDepth = 10;
int ExtTimeframe = PERIOD_H4;

input string T1 = "== Notifications ==";
input bool   notifications = false;
input bool   desktop_notifications = false;
input bool   email_notifications = false;
input bool   push_notifications = false;

double UpArrowBuffer[];
double DownArrowBuffer[];
datetime TimeframeTimeArray[];
datetime lastUpNotificationTime = 0;
datetime lastDownNotificationTime = 0;

int init() {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 228);
   SetIndexBuffer(0, UpArrowBuffer);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 230);
   SetIndexBuffer(1, DownArrowBuffer);
   SetIndexEmptyValue(1, 0.0);
   if (Period() > ExtTimeframe) {
      Alert("Signal in Bamsbung-Trend2 ", ExtTimeframe);
      return (0);
   }
   ArrayCopySeries(TimeframeTimeArray, 5, Symbol(), ExtTimeframe);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int timeframeBarIndex;
   double zigzagValue;
   int countedBars = IndicatorCounted();
   int limitBars = 50;
   if (countedBars < 0) return (-1);
   if (countedBars > 0) countedBars--;
   limitBars = Bars - countedBars;
   
   bool prevHasUpSignal = false;
   bool prevHasDownSignal = false;
   
   for (int i = 0; i < limitBars; i++) {
      UpArrowBuffer[i] = 0.0;
      DownArrowBuffer[i] = 0.0;
      
      if (Time[i] >= TimeframeTimeArray[0]) timeframeBarIndex = 0;
      else {
         timeframeBarIndex = ArrayBsearch(TimeframeTimeArray, Time[i - 1], WHOLE_ARRAY, 0, MODE_DESCEND);
         if (Period() <= ExtTimeframe) timeframeBarIndex++;
      }
      
      zigzagValue = 0.0;
      for (int j = timeframeBarIndex; j < timeframeBarIndex + 100; j++) {
         zigzagValue = iCustom(NULL, ExtTimeframe, "ZigZag", ExtDepth, 5, 3, 0, j + 1);
         if (zigzagValue != 0.0) break;
      }
      
      if (zigzagValue == 0.0) continue;
      
      double prevClose = iClose(NULL, 0, i + 1);
      bool hasUpSignal = (prevClose >= zigzagValue);
      bool hasDownSignal = (prevClose <= zigzagValue);
      
      if (i > 0) {
         double prevZigzagValue = 0.0;
         int prevTimeframeBarIndex = timeframeBarIndex;
         for (int k = prevTimeframeBarIndex; k < prevTimeframeBarIndex + 100; k++) {
            prevZigzagValue = iCustom(NULL, ExtTimeframe, "ZigZag", ExtDepth, 5, 3, 0, k + 1);
            if (prevZigzagValue != 0.0) break;
         }
         
         if (prevZigzagValue != 0.0 && i + 1 < Bars) {
            double prevPrevClose = iClose(NULL, 0, i + 2);
            prevHasUpSignal = (prevPrevClose >= prevZigzagValue);
            prevHasDownSignal = (prevPrevClose <= prevZigzagValue);
         }
      }
      
      if (hasUpSignal && !prevHasUpSignal) {
         UpArrowBuffer[i] = zigzagValue;
         if (countedBars > 0 && Time[i] != lastUpNotificationTime) {
            Notifications(0);
            lastUpNotificationTime = Time[i];
         }
      }
      
      if (hasDownSignal && !prevHasDownSignal) {
         DownArrowBuffer[i] = zigzagValue;
         if (countedBars > 0 && Time[i] != lastDownNotificationTime) {
            Notifications(1);
            lastDownNotificationTime = Time[i];
         }
      }
      
      prevHasUpSignal = hasUpSignal;
      prevHasDownSignal = hasDownSignal;
      WindowRedraw();
   }
   return (0);
}

string GetTimeFrame(int period) {
   switch(period) {
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
   return IntegerToString(period);
}

void Notifications(int type) {
   if (!notifications) return;
   
   string text = "";
   if (type == 0)
      text = Symbol() + " " + GetTimeFrame(Period()) + " BUY";
   else
      text = Symbol() + " " + GetTimeFrame(Period()) + " SELL";
   
   if (desktop_notifications)
      Alert(text);
   
   if (push_notifications)
      SendNotification(text);
   
   if (email_notifications)
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