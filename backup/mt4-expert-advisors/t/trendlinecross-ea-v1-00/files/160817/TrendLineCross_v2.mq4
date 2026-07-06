// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        TrendLineCross_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76361
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
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
double ArrowUp[];
double ArrowDn[];
input string T0_Line               = "== Trendline Settings =="; // Trendline Settings
input color    TrendlineColor      = clrYellow;                 // Trendline Color
input int      TrendlineWidth      = 2;                         // Trendline Width
input int      TrendlineStyle      = STYLE_SOLID;              // Trendline Style

datetime StartDate = 0;
double   StartRate = 0;
datetime EndDate = 0;
double   EndRate = 0;
string trendlineName = "TrendLineCross_MainLine";
bool drawingMode = false;
int clickCount = 0;
input string T0                    = "== Break Setup ==";   // Break Setup
input int    nCandles              = 2;                     // Maximum candle to break previous:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
input int    ArrowCode             = 233;                   // Arrow Code (Wingdings):
input int    ArrowSize             = 3;                     // Arrow Size (1-5):
input int    ArrowOffset           = 20;                     // Arrow Offset (Points):

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNewCandle
  {
private:
   int               _initialCandles;
   string            _symbol;
   int               _tf;
public:

                     CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}

                     CNewCandle()
     {
      _initialCandles = iBars(Symbol(), Period());
      _symbol         = Symbol();
      _tf             = Period();
     }

                    ~CNewCandle() { ; }

   bool              IsNewCandle()
     {
      int _currentCandles = iBars(_symbol, _tf);
      if(_currentCandles > _initialCandles)
        {
         _initialCandles = _currentCandles;
         return true;
        }
      return false;
     }
  };

CNewCandle newCandle();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
   SetIndexArrow(0, ArrowCode);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, ArrowSize, ArrowUpClr);
   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, ArrowSize, ArrowDnClr);
   SetIndexArrow(1, ArrowCode + 1);
   ArraySetAsSeries(ArrowUp, true);
   ArraySetAsSeries(ArrowDn, true);
   if(!ArrowsOn)
     {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
     }
   ArrayInitialize(ArrowUp, EMPTY_VALUE);
   ArrayInitialize(ArrowDn, EMPTY_VALUE);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   Comment("Click twice on chart to draw trendline\nFirst click: Start point\nSecond click: End point\n\nPress DELETE or ESC to remove trendline");
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_KEYDOWN)
     {
      if(lparam == 46 || lparam == 27)
        {
         if(ObjectFind(0, trendlineName) >= 0)
           {
            ObjectDelete(0, trendlineName);
            StartDate = 0;
            StartRate = 0;
            EndDate = 0;
            EndRate = 0;
            clickCount = 0;
            ArrayInitialize(ArrowUp, EMPTY_VALUE);
            ArrayInitialize(ArrowDn, EMPTY_VALUE);
            CalculateCrossings(Bars);
            Comment("Trendline deleted!\nClick twice on chart to draw new trendline");
            ChartRedraw(0);
           }
        }
     }
   if(id == CHARTEVENT_CLICK)
     {
      int x = (int)lparam;
      int y = (int)dparam;
      datetime clickTime;
      double clickPrice;
      int window = 0;
      if(ChartXYToTimePrice(0, x, y, window, clickTime, clickPrice))
        {
         if(clickCount == 0)
           {
            StartDate = clickTime;
            StartRate = clickPrice;
            clickCount = 1;
            Comment("First point set at ", TimeToString(StartDate), " @ ", DoubleToString(StartRate, _Digits),
                    "\nClick second point to complete trendline");
            UpdateTrendline();
           }
         else
            if(clickCount == 1)
              {
               EndDate = clickTime;
               EndRate = clickPrice;
               clickCount = 2;
               Comment("Trendline created!\nFrom: ", TimeToString(StartDate), " @ ", DoubleToString(StartRate, _Digits),
                       "\nTo: ", TimeToString(EndDate), " @ ", DoubleToString(EndRate, _Digits),
                       "\n\nPress DELETE or ESC to remove and reset");
               UpdateTrendline();
               CalculateCrossings(Bars);
              }
        }
     }
   else
      if(id == CHARTEVENT_CHART_CHANGE)
        {
         UpdateTrendline();
        }
      else
         if(id == CHARTEVENT_OBJECT_DRAG)
           {
            if(sparam == trendlineName)
              {
               StartDate = (datetime)ObjectGetInteger(0, trendlineName, OBJPROP_TIME, 0);
               StartRate = ObjectGetDouble(0, trendlineName, OBJPROP_PRICE, 0);
               EndDate = (datetime)ObjectGetInteger(0, trendlineName, OBJPROP_TIME, 1);
               EndRate = ObjectGetDouble(0, trendlineName, OBJPROP_PRICE, 1);
               CalculateCrossings(Bars);
              }
           }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateTrendline()
  {
   if(ObjectFind(0, trendlineName) >= 0)
      ObjectDelete(0, trendlineName);
   if(StartDate == 0 || StartRate == 0)
      return;
   datetime endDateToDraw = EndDate;
   double endRateToDraw = EndRate;
   if(clickCount == 1)
     {
      endDateToDraw = TimeCurrent();
      endRateToDraw = StartRate;
     }
   if(!ObjectCreate(0, trendlineName, OBJ_TREND, 0, StartDate, StartRate, endDateToDraw, endRateToDraw))
     {
      Print("Failed to create trendline: ", GetLastError());
      return;
     }
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, TrendlineColor);
   ObjectSetInteger(0, trendlineName, OBJPROP_WIDTH, TrendlineWidth);
   ObjectSetInteger(0, trendlineName, OBJPROP_STYLE, TrendlineStyle);
   ObjectSetInteger(0, trendlineName, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, trendlineName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, trendlineName, OBJPROP_SELECTED, false);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ObjectFind(0, trendlineName) >= 0)
      ObjectDelete(0, trendlineName);
   Comment("");
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateCrossings(int rates_total)
  {
   if(ObjectFind(0, trendlineName) < 0)
     {
      Comment("Trendline not found. Click twice on chart to draw trendline.\nOr create OBJ_TREND object named: ", trendlineName);
      return;
     }
   StartDate = (datetime)ObjectGetInteger(0, trendlineName, OBJPROP_TIME, 0);
   StartRate = ObjectGetDouble(0, trendlineName, OBJPROP_PRICE, 0);
   EndDate = (datetime)ObjectGetInteger(0, trendlineName, OBJPROP_TIME, 1);
   EndRate = ObjectGetDouble(0, trendlineName, OBJPROP_PRICE, 1);
   Comment("Trendline OK. Checking crossings...\nBars: ", rates_total);
   int startShift = iBarShift(Symbol(), 0, StartDate, false);
   if(startShift < 0)
      startShift = rates_total - 1;
   for(int shift = startShift; shift >= 0; shift--)
     {
      ArrowUp[shift] = EMPTY_VALUE;
      ArrowDn[shift] = EMPTY_VALUE;
     }
   for(int shift = startShift; shift >= 0; shift--)
     {
      double TrendPrice0 = ObjectGetValueByShift(trendlineName, shift);
      double TrendPrice1 = ObjectGetValueByShift(trendlineName, shift + 1);
      if(TrendPrice0 <= 0 || TrendPrice1 <= 0 ||
         TrendPrice0 == EMPTY_VALUE || TrendPrice1 == EMPTY_VALUE)
        {
         continue;
        }
      double close0 = shift == 0 ? iClose(Symbol(), 0, 0) : iClose(Symbol(), 0, shift);
      double open0  = iOpen(Symbol(), 0, shift);
      double close1 = iClose(Symbol(), 0, shift + 1);
      double high0  = iHigh(Symbol(), 0, shift);
      double low0   = iLow(Symbol(), 0, shift);
      if(shift == 0)
        {
         close0 = (Bid + Ask) / 2.0;
         high0 = iHigh(Symbol(), 0, 0) > close0 ? iHigh(Symbol(), 0, 0) : close0;
         low0 = iLow(Symbol(), 0, 0) < close0 ? iLow(Symbol(), 0, 0) : close0;
        }
      if(close1 < TrendPrice1 && close0 > TrendPrice0)
        {
         ArrowUp[shift] = low0 - (ArrowOffset * _Point);
         if(shift == 1 && newCandle.IsNewCandle())
           {
            Notifications(0);
           }
        }
      else
         if(close1 > TrendPrice1 && close0 < TrendPrice0)
           {
            ArrowDn[shift] = high0 + (ArrowOffset * _Point);
            if(shift == 1 && newCandle.IsNewCandle())
              {
               Notifications(1);
              }
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   if(prev_calculated == 0)
     {
      ArrayInitialize(ArrowUp, EMPTY_VALUE);
      ArrayInitialize(ArrowDn, EMPTY_VALUE);
     }
   CalculateCrossings(rates_total);
   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceCrossedTrendline(int shift = 0)
  {
   if(ObjectFind(0, trendlineName) < 0)
     {
      return 0;
     }
   double TrendPrice1  = ObjectGetValueByShift(trendlineName, 1);
   double TrendPrice2  = ObjectGetValueByShift(trendlineName, 2);
   double close0 = iClose(Symbol(), 0, 1);
   double open0  = iOpen(Symbol(), 0, 1);
   double close1 = iClose(Symbol(), 0, 2);
   double high0  = iHigh(Symbol(), 0, 1);
   double low0   = iLow(Symbol(), 0, 1);
   if(close0 < TrendPrice1)
     {
      if(open0 > TrendPrice1 || close1 > TrendPrice2)
        {
         return -1;
        }
     }
   if(close0 > TrendPrice1)
     {
      if(open0 < TrendPrice1 || close1 < TrendPrice2)
        {
         return 1;
        }
     }
   return 0;
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
// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        TrendLineCross_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76361
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