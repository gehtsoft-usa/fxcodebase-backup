// -- Project -------------------------------------------------------------------------------
/*
Name:        SignalaArrow_v3.0
Version:     3.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160656#p160656
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
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

#property copyright "Copyright (c) 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "3.00"
#property strict
#property description "ZigZag Arrow Indicator - Compatible with MQL5 version"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrCrimson
input int        ExtDepth        = 17;              // ZigZag Depth
input int        ExtDeviation    = 5;               // ZigZag Deviation
input int        ExtBackstep     = 3;               // ZigZag Backstep
input int        ArrowBuyCode    = 233;             // Arrow Buy Code
input int        ArrowSellCode   = 234;             // Arrow Sell Code
input int        ArrowBuyWidth   = 2;               // Arrow Buy Width
input int        ArrowSellWidth  = 2;               // Arrow Sell Width
input color      ArrowBuyColor   = clrDodgerBlue;   // Arrow Buy Color
input color      ArrowSellColor  = clrCrimson;      // Arrow Sell Color
input int        Move_Arrow      = 50;              // Arrow Distance (points)
input bool       alert           = FALSE;           // Alert On?
input bool       sound           = FALSE;           // Sound On?
input bool       email           = FALSE;           // Email On?
double ArrowUp[];
double ArrowDn[];
long LatBarTime;
bool Gi_264;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, ArrowUp);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, ArrowBuyWidth, ArrowBuyColor);
   SetIndexEmptyValue(0, 0.0);
   SetIndexArrow(0, ArrowBuyCode);
   SetIndexLabel(0, "Arrow Up");
   SetIndexBuffer(1, ArrowDn);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, ArrowSellWidth, ArrowSellColor);
   SetIndexEmptyValue(1, 0.0);
   SetIndexArrow(1, ArrowSellCode);
   SetIndexLabel(1, "Arrow Down");
   ArrayInitialize(ArrowUp, 0.0);
   ArrayInitialize(ArrowDn, 0.0);
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(iTime(NULL, 0, 0) == LatBarTime)
      return (0);
   LatBarTime = iTime(NULL, 0, 0);
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)
      return (-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = Bars - counted_bars;
   if(limit > Bars - 100)
      limit = Bars - 100;
   for(int i = 0; i < limit; i++)
     {
      ArrowUp[i] = 0.0;
      ArrowDn[i] = 0.0;
     }
   for(int i = limit; i >= 0; i--)
     {
      double zzValue = iCustom(NULL, 0, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, i);
      if(zzValue > 0.0001)
        {
         double diffHigh = MathAbs(zzValue - High[i]);
         double diffLow = MathAbs(zzValue - Low[i]);
         if(diffLow < diffHigh * Point)
           {
            ArrowUp[i] = Low[i] - Move_Arrow * Point;
           }
         else
           {
            ArrowDn[i] = High[i] + Move_Arrow * Point;
           }
        }
     }
   string Ls_44 = "";
   if(ArrowUp[0] > 0.0001)
     {
      Ls_44 = Symbol() + " Signal " + WindowExpertName() + " BUY";
     }
   if(ArrowDn[0] > 0.0001)
     {
      Ls_44 = Symbol() + " Signal " + WindowExpertName() + " SELL";
     }
   if(Ls_44 != "" && (!IsTesting()))
     {
      if(sound && Gi_264 == FALSE)
         PlaySound("Wait.wav");
      if(alert && Gi_264 == FALSE)
         Alert(Ls_44);
      if(email && Gi_264 == FALSE)
         SendMail(WindowExpertName(), Ls_44);
      Gi_264 = TRUE;
     }
   else
     {
      Gi_264 = FALSE;
     }
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
  }
//+------------------------------------------------------------------+
