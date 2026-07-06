// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        beluga_tt_boxes
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76339
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
BuyMeACoffee:https://tiny.cc/bj7vzj

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

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4

input int    TrendLength = 10;          // Trend Length
input int    SetTargets = 0;            // Set Targets
input int    MaxBoxes = 200;            // Max boxes to keep
input bool   ShowActiveLeg = true;      // Show active leg box
input int    BarsToProcess = 5000;      // Bars to process (0 = all available)

color UpColor = C'0,182,144';
color DnColor = C'182,112,6';

double SignalUpBuffer[];
double SignalDnBuffer[];
double TrendUpperBuffer[];
double TrendLowerBuffer[];

bool g_trend = false;
int g_lastCalculatedBar = -1;

struct HistoricalLeg
  {
   int               startBar;
   int               endBar;
   double            highPrice;
   double            lowPrice;
   double            entryPrice;
   bool              isLong;
  };

HistoricalLeg g_legs[];
int g_legCount = 0;

bool g_legActive = false;
bool g_legLong = false;
double g_legHigh = 0;
double g_legLow = 0;
double g_legEntry = 0;
string g_activeBoxName = "";
bool g_legPending = false;
bool g_legPendingLong = false;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(4);
   SetIndexBuffer(0, SignalUpBuffer);
   SetIndexBuffer(1, SignalDnBuffer);
   SetIndexBuffer(2, TrendUpperBuffer);
   SetIndexBuffer(3, TrendLowerBuffer);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);
   SetIndexStyle(2, DRAW_LINE, STYLE_DOT);
   SetIndexStyle(3, DRAW_LINE, STYLE_DOT);
   IndicatorShortName("BELUGA TT BOXES");
   ArrayResize(g_legs, MaxBoxes + 10);
   g_legCount = 0;
   g_trend = false;
   g_lastCalculatedBar = -1;
   g_legActive = false;
   g_legPending = false;
   g_activeBoxName = "";
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllObjects();
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
   if(rates_total < TrendLength + 200)
      return(0);
   int limit;
   int startBar;
   bool firstRun = false;
   if(prev_calculated == 0)
     {
      firstRun = true;
      ArrayInitialize(SignalUpBuffer, EMPTY_VALUE);
      ArrayInitialize(SignalDnBuffer, EMPTY_VALUE);
      g_legCount = 0;
      int maxBars = (BarsToProcess > 0 && BarsToProcess < rates_total) ? BarsToProcess : rates_total;
      startBar = MathMin(maxBars - 1, rates_total - TrendLength - 200);
      limit = startBar;
      double atrInit = iATR(NULL, 0, 200, startBar) * 0.8;
      double smaHInit = iMA(NULL, 0, TrendLength, 0, MODE_SMA, PRICE_HIGH, startBar) + atrInit;
      double smaLInit = iMA(NULL, 0, TrendLength, 0, MODE_SMA, PRICE_LOW, startBar) - atrInit;
      g_trend = (close[startBar] > smaHInit);
     }
   else
     {
      limit = 1;
      startBar = 1;
     }
   for(int i = limit; i >= 0; i--)
     {
      double atr = iATR(NULL, 0, 200, i) * 0.8;
      double smaH = iMA(NULL, 0, TrendLength, 0, MODE_SMA, PRICE_HIGH, i) + atr;
      double smaL = iMA(NULL, 0, TrendLength, 0, MODE_SMA, PRICE_LOW, i) - atr;
      TrendUpperBuffer[i] = smaH;
      TrendLowerBuffer[i] = smaL;
      bool signalUp = false;
      bool signalDown = false;
      if(i < rates_total - 1)
        {
         double prevSmaH = TrendUpperBuffer[i + 1];
         double prevSmaL = TrendLowerBuffer[i + 1];
         if(close[i] > smaH && close[i + 1] <= prevSmaH && !g_trend)
           {
            g_trend = true;
            signalUp = true;
           }
         else
            if(close[i] < smaL && close[i + 1] >= prevSmaL && g_trend)
              {
               g_trend = false;
               signalDown = true;
              }
        }
      if(signalUp)
        {
         SignalUpBuffer[i] = low[i] - atr;
         SignalDnBuffer[i] = EMPTY_VALUE;
         if(firstRun)
           {
            if(g_legCount > 0 && g_legs[g_legCount - 1].endBar == -1)
              {
               g_legs[g_legCount - 1].endBar = i;
               CreateHistoricalLegBox(g_legCount - 1);
              }
            if(g_legCount < ArraySize(g_legs))
              {
               g_legs[g_legCount].startBar = i;
               g_legs[g_legCount].endBar = -1;
               g_legs[g_legCount].entryPrice = (i > 0) ? open[i - 1] : open[i];
               g_legs[g_legCount].highPrice = MathMax(open[i], close[i]);
               g_legs[g_legCount].lowPrice = MathMin(open[i], close[i]);
               g_legs[g_legCount].isLong = true;
               g_legCount++;
              }
            DrawTargets(true, smaL, close[i], atr, time[i]);
           }
        }
      else
         if(signalDown)
           {
            SignalDnBuffer[i] = high[i] + atr;
            SignalUpBuffer[i] = EMPTY_VALUE;
            if(firstRun)
              {
               if(g_legCount > 0 && g_legs[g_legCount - 1].endBar == -1)
                 {
                  g_legs[g_legCount - 1].endBar = i;
                  CreateHistoricalLegBox(g_legCount - 1);
                 }
               if(g_legCount < ArraySize(g_legs))
                 {
                  g_legs[g_legCount].startBar = i;
                  g_legs[g_legCount].endBar = -1;
                  g_legs[g_legCount].entryPrice = (i > 0) ? open[i - 1] : open[i];
                  g_legs[g_legCount].highPrice = MathMax(open[i], close[i]);
                  g_legs[g_legCount].lowPrice = MathMin(open[i], close[i]);
                  g_legs[g_legCount].isLong = false;
                  g_legCount++;
                 }
               DrawTargets(false, smaH, close[i], atr, time[i]);
              }
           }
         else
           {
            SignalUpBuffer[i] = EMPTY_VALUE;
            SignalDnBuffer[i] = EMPTY_VALUE;
           }
      if(firstRun && g_legCount > 0 && g_legs[g_legCount - 1].endBar == -1)
        {
         double bodyH = MathMax(open[i], close[i]);
         double bodyL = MathMin(open[i], close[i]);
         g_legs[g_legCount - 1].highPrice = MathMax(g_legs[g_legCount - 1].highPrice, bodyH);
         g_legs[g_legCount - 1].lowPrice = MathMin(g_legs[g_legCount - 1].lowPrice, bodyL);
        }
      if(i == 0)
        {
         if(g_legPending)
           {
            StartNewLeg(g_legPendingLong, open[0]);
            g_legPending = false;
           }
         if(g_legActive)
           {
            double bodyH = MathMax(open[0], close[0]);
            double bodyL = MathMin(open[0], close[0]);
            g_legHigh = MathMax(g_legHigh, bodyH);
            g_legLow = MathMin(g_legLow, bodyL);
            UpdateActiveLegBox();
           }
         if(signalUp)
           {
            if(g_legActive)
               CloseLeg();
            g_legPending = true;
            g_legPendingLong = true;
           }
         else
            if(signalDown)
              {
               if(g_legActive)
                  CloseLeg();
               g_legPending = true;
               g_legPendingLong = false;
              }
        }
     }
   g_lastCalculatedBar = rates_total;
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateHistoricalLegBox(int legIdx)
  {
   if(legIdx >= g_legCount)
     {
      return;
     }
   HistoricalLeg leg = g_legs[legIdx];
   datetime startTime = iTime(NULL, 0, leg.startBar);
   datetime endTime = iTime(NULL, 0, leg.endBar);
   if(startTime == 0 || endTime == 0)
     {
      return;
     }
   double rangeH = leg.highPrice;
   double rangeL = leg.lowPrice;
   double entryP = leg.entryPrice;
   if(rangeH <= rangeL)
     {
      return;
     }
   double pctMax = 0;
   if(leg.isLong)
      pctMax = ((rangeH - entryP) / entryP) * 100.0;
   else
      pctMax = ((entryP - rangeL) / entryP) * 100.0;
   double exitOpen = iOpen(NULL, 0, leg.endBar);
   double exitClose = iClose(NULL, 0, leg.endBar);
   double exitPrice = leg.isLong ? MathMin(exitOpen, exitClose) : MathMax(exitOpen, exitClose);
   double pctNet = 0;
   if(leg.isLong)
      pctNet = ((exitPrice - entryP) / entryP) * 100.0;
   else
      pctNet = ((entryP - exitPrice) / entryP) * 100.0;
   string boxName = "LegBox_" + IntegerToString(legIdx);
   color bcol = leg.isLong ? UpColor : DnColor;
   if(ObjectFind(0, boxName) >= 0)
     {
      ObjectDelete(0, boxName);
     }
   if(!ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, startTime, rangeH, endTime, rangeL))
     {
      return;
     }
   ObjectSetInteger(0, boxName, OBJPROP_COLOR, bcol);
   ObjectSetInteger(0, boxName, OBJPROP_BGCOLOR, bcol);
   ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
   ObjectSetInteger(0, boxName, OBJPROP_BACK, true);
   ObjectSetInteger(0, boxName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, boxName, OBJPROP_RAY_RIGHT, false);
   datetime midTime = startTime + (endTime - startTime) / 2;
   double midPrice = (rangeH + rangeL) / 2;
   string maxLabel = "MaxLbl_" + IntegerToString(legIdx);
   if(ObjectFind(0, maxLabel) >= 0)
      ObjectDelete(0, maxLabel);
   ObjectCreate(0, maxLabel, OBJ_TEXT, 0, midTime, midPrice);
   ObjectSetString(0, maxLabel, OBJPROP_TEXT, DoubleToString(pctMax, 2) + "% MAX");
   ObjectSetInteger(0, maxLabel, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, maxLabel, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, maxLabel, OBJPROP_ANCHOR, ANCHOR_CENTER);
   double offset = (rangeH - rangeL) * 0.35;
   color netCol = (pctNet >= 0) ? clrLime : clrRed;
   string netLabel = "NetLbl_" + IntegerToString(legIdx);
   if(ObjectFind(0, netLabel) >= 0)
      ObjectDelete(0, netLabel);
   ObjectCreate(0, netLabel, OBJ_TEXT, 0, midTime, midPrice - offset);
   ObjectSetString(0, netLabel, OBJPROP_TEXT, "Sig2Sig: " + DoubleToString(pctNet, 2) + "%");
   ObjectSetInteger(0, netLabel, OBJPROP_COLOR, netCol);
   ObjectSetInteger(0, netLabel, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, netLabel, OBJPROP_ANCHOR, ANCHOR_CENTER);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StartNewLeg(bool isLong, double entryPrice)
  {
   g_legActive = true;
   g_legLong = isLong;
   g_legEntry = entryPrice;
   g_legHigh = MathMax(Open[0], Close[0]);
   g_legLow = MathMin(Open[0], Close[0]);
   if(ShowActiveLeg)
     {
      if(g_activeBoxName != "")
         ObjectDelete(0, g_activeBoxName);
      g_activeBoxName = "ActiveLeg";
      color bcol = isLong ? UpColor : DnColor;
      ObjectCreate(0, g_activeBoxName, OBJ_RECTANGLE, 0, Time[0], g_legHigh, Time[0], g_legLow);
      ObjectSetInteger(0, g_activeBoxName, OBJPROP_COLOR, bcol);
      ObjectSetInteger(0, g_activeBoxName, OBJPROP_BGCOLOR, bcol);
      ObjectSetInteger(0, g_activeBoxName, OBJPROP_FILL, true);
      ObjectSetInteger(0, g_activeBoxName, OBJPROP_BACK, true);
      ObjectSetInteger(0, g_activeBoxName, OBJPROP_WIDTH, 2);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateActiveLegBox()
  {
   if(g_activeBoxName != "" && ObjectFind(0, g_activeBoxName) >= 0)
     {
      ObjectSetDouble(0, g_activeBoxName, OBJPROP_PRICE, 0, g_legHigh);
      ObjectSetDouble(0, g_activeBoxName, OBJPROP_PRICE, 1, g_legLow);
      ObjectSetInteger(0, g_activeBoxName, OBJPROP_TIME, 1, Time[0]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseLeg()
  {
   if(!g_legActive)
      return;
   double rangeH = g_legHigh;
   double rangeL = g_legLow;
   double entryP = g_legEntry;
   double pctMax = g_legLong ? ((rangeH - entryP) / entryP) * 100.0 : ((entryP - rangeL) / entryP) * 100.0;
   double exitPrice = g_legLong ? MathMin(Open[0], Close[0]) : MathMax(Open[0], Close[0]);
   double pctNet = g_legLong ? ((exitPrice - entryP) / entryP) * 100.0 : ((entryP - exitPrice) / entryP) * 100.0;
   string boxName = "LegBox_" + IntegerToString(g_legCount);
   color bcol = g_legLong ? UpColor : DnColor;
   ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, Time[0], rangeH, Time[0], rangeL);
   ObjectSetInteger(0, boxName, OBJPROP_COLOR, bcol);
   ObjectSetInteger(0, boxName, OBJPROP_BGCOLOR, bcol);
   ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
   ObjectSetInteger(0, boxName, OBJPROP_BACK, true);
   ObjectSetInteger(0, boxName, OBJPROP_WIDTH, 1);
   double midPrice = (rangeH + rangeL) / 2;
   string maxLabel = "MaxLbl_" + IntegerToString(g_legCount);
   ObjectCreate(0, maxLabel, OBJ_TEXT, 0, Time[0], midPrice);
   ObjectSetString(0, maxLabel, OBJPROP_TEXT, DoubleToString(pctMax, 2) + "% MAX");
   ObjectSetInteger(0, maxLabel, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, maxLabel, OBJPROP_FONTSIZE, 8);
   double offset = (rangeH - rangeL) * 0.35;
   string netLabel = "NetLbl_" + IntegerToString(g_legCount);
   color netCol = (pctNet >= 0) ? clrLime : clrRed;
   ObjectCreate(0, netLabel, OBJ_TEXT, 0, Time[0], midPrice - offset);
   ObjectSetString(0, netLabel, OBJPROP_TEXT, "Sig2Sig: " + DoubleToString(pctNet, 2) + "%");
   ObjectSetInteger(0, netLabel, OBJPROP_COLOR, netCol);
   ObjectSetInteger(0, netLabel, OBJPROP_FONTSIZE, 8);
   if(g_activeBoxName != "")
     {
      ObjectDelete(0, g_activeBoxName);
      g_activeBoxName = "";
     }
   g_legCount++;
   g_legActive = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTargets(bool isLong, double base, double entry, double atr, datetime barTime)
  {
   string prefix = isLong ? "UpTgt_" : "DnTgt_";
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      if(StringFind(name, prefix) == 0)
         ObjectDelete(0, name);
     }
   double mult = isLong ? 1.0 : -1.0;
   double t1 = entry + mult * atr * (5 + SetTargets);
   double t2 = entry + mult * atr * (10 + SetTargets * 2);
   double t3 = entry + mult * atr * (15 + SetTargets * 3);
   datetime time1 = barTime;
   datetime time2 = barTime + PeriodSeconds() * 30;
   CreateTargetLine(prefix + "SL", time1, time2, base, "SL:" + DoubleToString(base, Digits), clrRed);
   CreateTargetLine(prefix + "Entry", time1, time2, entry, "Entry:" + DoubleToString(entry, Digits), clrYellow);
   CreateTargetLine(prefix + "T1", time1, time2, t1, "T1:" + DoubleToString(t1, Digits), clrLime);
   CreateTargetLine(prefix + "T2", time1, time2, t2, "T2:" + DoubleToString(t2, Digits), clrLime);
   CreateTargetLine(prefix + "T3", time1, time2, t3, "T3:" + DoubleToString(t3, Digits), clrLime);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateTargetLine(string name, datetime t1, datetime t2, double price, string text, color col)
  {
   ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   string lblName = name + "_lbl";
   ObjectCreate(0, lblName, OBJ_TEXT, 0, t2, price);
   ObjectSetString(0, lblName, OBJPROP_TEXT, " " + text);
   ObjectSetInteger(0, lblName, OBJPROP_COLOR, col);
   ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 7);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      if(StringFind(name, "LegBox_") >= 0 ||
         StringFind(name, "ActiveLeg") >= 0 ||
         StringFind(name, "MaxLbl_") >= 0 ||
         StringFind(name, "NetLbl_") >= 0 ||
         StringFind(name, "UpTgt_") >= 0 ||
         StringFind(name, "DnTgt_") >= 0)
        {
         ObjectDelete(0, name);
        }
     }
  }
//+------------------------------------------------------------------+
// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        beluga_tt_boxes
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76339
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
BuyMeACoffee:https://tiny.cc/bj7vzj

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