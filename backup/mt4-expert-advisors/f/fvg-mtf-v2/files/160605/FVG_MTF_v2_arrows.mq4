//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=160546#p160546
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
//HEADER:END

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 4
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_style3 STYLE_SOLID
#property indicator_type4  DRAW_HISTOGRAM
#property indicator_style4 STYLE_SOLID

double ArrowUp[];
double ArrowDn[];

//--- indicator buffers
double _up_BodyHigh[];
double _up_BodyLow[];
double _dn_BodyHigh[];
double _dn_BodyLow[];
double priceInFvg[];

bool alerted;
// ------------------------------------------------------------------
input ENUM_TIMEFRAMES uTFsup = PERIOD_CURRENT; // Higher Time Frame
ENUM_TIMEFRAMES TFsup = uTFsup;
input bool deleteHalfFVG = true; // Delete FVG if price fills half of the FVG body
input string T2          = "== Set Colors ==";  // ————————————
input color  CandleUpClr = C'22,206,239';             // Candle Up Color:
input color  CandleDnClr = C'241,42,212';              // Candle Down Color:

input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

input string T3                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:

// ------------------------------------------------------------------


// ------------------------------------------------------------------
int OnInit()
  {
// tomar el color de background del chart
   color backColor = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   if(TFsup < (int)_Period)
      TFsup = (ENUM_TIMEFRAMES)_Period;
   SetIndexBuffer(0, _up_BodyHigh, INDICATOR_DATA);
   SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 3, CandleUpClr);
   SetIndexBuffer(1, _up_BodyLow, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 3, backColor);
   SetIndexBuffer(2, _dn_BodyHigh, INDICATOR_DATA);
   SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, 3, CandleDnClr);
   SetIndexBuffer(3, _dn_BodyLow, INDICATOR_DATA);
   SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, 3, CandleDnClr);
   SetIndexBuffer(4, priceInFvg, INDICATOR_DATA);
   SetIndexStyle(4, DRAW_NONE);
   IndicatorSetString(INDICATOR_SHORTNAME, "FVG MTF");
   SetIndexLabel(0, "Up Body High");
   SetIndexLabel(1, "Up Body Low");
   SetIndexLabel(2, "Down Body High");
   SetIndexLabel(3, "Down Body Low");
   SetIndexLabel(4, "Price In FVG");
   
   SetIndexBuffer(5, ArrowUp, INDICATOR_DATA); 
   SetIndexArrow(5, 233);
   SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
   SetIndexLabel(5, "Arrow Up");
   SetIndexBuffer(6, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(6, 234);
   SetIndexLabel(6, "Arrow Dn");
   if (!ArrowsOn)
   {
      SetIndexStyle(5, DRAW_NONE);
      SetIndexStyle(6, DRAW_NONE);
   }



//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
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
   int start, i, j, iPrev;
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(prev_calculated == 0)
     {
      start = 500;
     }
   else
     {
      start = rates_total - (prev_calculated - 1);
     }
   for(j = start; j >= 0; j--)
     {
      i = iBarShift(NULL, TFsup, time[j], true);
      iPrev = iBarShift(NULL, TFsup, time[j] - (TFsup * 60 * 2), true);
      double lo = iLow(NULL, TFsup, i);
      double hi = iHigh(NULL, TFsup, i);
      double op = iOpen(NULL, TFsup, i);
      double cl = iClose(NULL, TFsup, i);
      double loPrev = iLow(NULL, TFsup, iPrev);
      double hiPrev = iHigh(NULL, TFsup, iPrev);
      if(lo > hiPrev && hiPrev != 0)
        {
         _up_BodyHigh[j] = lo;
         _up_BodyLow[j]  = hiPrev;
         ArrowUp[j] = lo - (100 * (Point));
        }
      if(hi < loPrev && loPrev != 0)
        {
         _dn_BodyHigh[j] = loPrev;
         _dn_BodyLow[j]  = hi;
         ArrowDn[j] = hi + (100 * (Point));
        }
      priceInFvg[j] = 0;
      if(deleteHalfFVG)
        {
         if(_up_BodyHigh[j] != EMPTY_VALUE && _up_BodyLow[j] != EMPTY_VALUE)
           {
            if(cl <= _up_BodyHigh[j] && cl >= _up_BodyLow[j])
              {
               priceInFvg[j] = 1;
               if(!alerted)
                 {
                  alerted = true;
                  Notifications(0);
                 }
              }
            if(deleteHalfFVG)
              {
               double midPoint = hiPrev + ((op - hiPrev) / 2.0);
               if(low[j] <= midPoint)
                 {
                  _up_BodyHigh[j] = EMPTY_VALUE;
                  _up_BodyLow[j] = EMPTY_VALUE;
                 }
              }
           }
         if(_dn_BodyHigh[j] != EMPTY_VALUE && _dn_BodyLow[j] != EMPTY_VALUE)
           {
            if(cl <= _dn_BodyHigh[j] && cl >= _dn_BodyLow[j])
              {
               priceInFvg[j] = -1;
               if(!alerted)
                 {
                  alerted = true;
                  Notifications(1);
                 }
              }
            if(deleteHalfFVG)
              {
               double midPoint = loPrev - ((loPrev - op) / 2.0);
               if(high[j] >= midPoint)
                 {
                  _dn_BodyHigh[j] = EMPTY_VALUE;
                  _dn_BodyLow[j] = EMPTY_VALUE;
                 }
              }
           }
        }
     }
   return (rates_total);
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type)
  {
   string text = "";
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";
   text += " ";
   if(!notifications)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }


// ------------------------------------------------------------------

//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=160546#p160546
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
//FOOTER:END