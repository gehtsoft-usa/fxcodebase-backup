/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Kaspricci_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76439
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

#property description "The Only EURUSD Trading Strategy You Need - Kaspricci"
#include <Trade\Trade.mqh>
enum ENUM_SL_TYPE
  {
   SL_ATR,    // ATR
   SL_FIX     // FIX
  };
input group "===== Entry Settings ====="
input int    inp_sh_bars = 5;                          // Swing High Bars
input int    inp_sl_bars = 5;                          // Swing Low Bars
input int    inp_session_start_hour = 13;              // Session Start Hour (GMT)
input int    inp_session_start_minute = 30;            // Session Start Minute
input int    inp_session_end_hour = 20;                // Session End Hour (GMT)
input int    inp_session_end_minute = 0;               // Session End Minute
input group "===== Trade Settings ====="
input ENUM_SL_TYPE inp_sl_type = SL_ATR;               // Stop Loss Type
input int    inp_atr_length = 14;                      // ATR Length
input double inp_atr_factor = 2.0;                     // ATR Factor
input double inp_tp_ratio = 2.0;                       // Take Profit Ratio
input double inp_fix_sl_pips = 10.0;                   // FIX: Stop Loss (pips)
input double inp_fix_tp_pips = 20.0;                   // FIX: Take Profit (pips)
input bool   inp_use_risk_mgmt = false;                // Use Risk Management
input double inp_risk_percent = 1.0;                   // Risk in %
CTrade trade;
int atr_handle;
double atr_buffer[];
double buyStopPrice = 0;
double sellStopPrice = 0;
double swingHigh = 0;
double swingLow = 0;
bool sessionActive = false;
bool ordersPlaced = false;
string currentTradeID = "";
int tradeCounter = 0;
datetime lastSessionStart = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   atr_handle = iATR(_Symbol, PERIOD_CURRENT, inp_atr_length);
   if(atr_handle == INVALID_HANDLE)
     {
      Print("Error creating ATR indicator");
      return(INIT_FAILED);
     }
   ArraySetAsSeries(atr_buffer, true);
   trade.SetExpertMagicNumber(472);
   trade.SetDeviationInPoints(10);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   trade.SetAsyncMode(false);
   Print("Kaspricci EA initialized successfully");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(atr_handle != INVALID_HANDLE)
      IndicatorRelease(atr_handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBar == lastBar)
      return;
   lastBar = currentBar;
   UpdateSwingPoints();
   bool inSession = IsInSession();
   if(inSession && !sessionActive)
     {
      OnSessionStart();
      sessionActive = true;
      ordersPlaced = false;
     }
   if(!inSession && sessionActive)
     {
      OnSessionEnd();
      sessionActive = false;
      ordersPlaced = false;
     }
   if(PositionsTotal() > 0 && !ordersPlaced)
     {
      CancelRemainingOrders();
      ordersPlaced = true;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsInSession()
  {
   MqlDateTime dt;
   TimeGMT(dt);
   int currentMinutes = dt.hour * 60 + dt.min;
   int startMinutes = inp_session_start_hour * 60 + inp_session_start_minute;
   int endMinutes = inp_session_end_hour * 60 + inp_session_end_minute;
   if(dt.day_of_week < 1 || dt.day_of_week > 5)
      return false;
   return (currentMinutes >= startMinutes && currentMinutes < endMinutes);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateSwingPoints()
  {
   double pivotHigh = FindPivotHigh(inp_sh_bars, inp_sh_bars);
   if(pivotHigh > 0)
      swingHigh = pivotHigh;
   double pivotLow = FindPivotLow(inp_sl_bars, inp_sl_bars);
   if(pivotLow > 0)
      swingLow = pivotLow;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindPivotHigh(int leftBars, int rightBars)
  {
   if(Bars(_Symbol, PERIOD_CURRENT) < leftBars + rightBars + 1)
      return 0;
   int centerShift = rightBars;
   double centerHigh = iHigh(_Symbol, PERIOD_CURRENT, centerShift);
   for(int i = 1; i <= leftBars; i++)
     {
      double compareHigh = iHigh(_Symbol, PERIOD_CURRENT, centerShift + i);
      if(compareHigh >= centerHigh)
         return 0;
     }
   for(int i = 1; i <= rightBars; i++)
     {
      double compareHigh = iHigh(_Symbol, PERIOD_CURRENT, centerShift - i);
      if(compareHigh > centerHigh)
         return 0;
     }
   return centerHigh;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindPivotLow(int leftBars, int rightBars)
  {
   if(Bars(_Symbol, PERIOD_CURRENT) < leftBars + rightBars + 1)
      return 0;
   int centerShift = rightBars;
   double centerLow = iLow(_Symbol, PERIOD_CURRENT, centerShift);
   for(int i = 1; i <= leftBars; i++)
     {
      double compareLow = iLow(_Symbol, PERIOD_CURRENT, centerShift + i);
      if(compareLow <= centerLow)
         return 0;
     }
   for(int i = 1; i <= rightBars; i++)
     {
      double compareLow = iLow(_Symbol, PERIOD_CURRENT, centerShift - i);
      if(compareLow < centerLow)
         return 0;
     }
   return centerLow;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLossPoints()
  {
   if(inp_sl_type == SL_ATR)
     {
      if(CopyBuffer(atr_handle, 0, 0, 2, atr_buffer) < 2)
         return 0;
      double atr = atr_buffer[0];
      double slPoints = (atr * inp_atr_factor) / _Point;
      return NormalizeDouble(slPoints, 0);
     }
   else
     {
      return inp_fix_sl_pips * 10;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTakeProfitPoints(double slPoints)
  {
   if(inp_sl_type == SL_ATR)
     {
      return NormalizeDouble(slPoints * inp_tp_ratio, 0);
     }
   else
     {
      return inp_fix_tp_pips * 10;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateLotSize(double slPoints)
  {
   if(!inp_use_risk_mgmt)
      return 0;
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (inp_risk_percent / 100.0);
   double slMoney = slPoints * _Point * tickValue / tickSize;
   double lots = riskAmount / slMoney;
   lots = MathFloor(lots / lotStep) * lotStep;
   if(lots < minLot)
      lots = minLot;
   if(lots > maxLot)
      lots = maxLot;
   return NormalizeDouble(lots, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnSessionStart()
  {
   Print("Session started");
   buyStopPrice = swingHigh;
   sellStopPrice = swingLow;
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slPoints = GetStopLossPoints();
   double tpPoints = GetTakeProfitPoints(slPoints);
   if(slPoints <= 0 || tpPoints <= 0)
     {
      Print("Invalid SL or TP values");
      return;
     }
   double lots = CalculateLotSize(slPoints);
   if(lots <= 0)
      lots = 0.01;
   tradeCounter++;
   currentTradeID = IntegerToString(tradeCounter);
   double slPrice, tpPrice;
   if(sellStopPrice < currentPrice && currentPrice < buyStopPrice)
     {
      Print("Price between swings - placing both orders");
      slPrice = buyStopPrice - slPoints * _Point;
      tpPrice = buyStopPrice + tpPoints * _Point;
      trade.BuyStop(lots, NormalizeDouble(buyStopPrice, _Digits), _Symbol,
                    NormalizeDouble(slPrice, _Digits),
                    NormalizeDouble(tpPrice, _Digits),
                    ORDER_TIME_DAY, 0,
                    currentTradeID + "L");
      slPrice = sellStopPrice + slPoints * _Point;
      tpPrice = sellStopPrice - tpPoints * _Point;
      trade.SellStop(lots, NormalizeDouble(sellStopPrice, _Digits), _Symbol,
                     NormalizeDouble(slPrice, _Digits),
                     NormalizeDouble(tpPrice, _Digits),
                     ORDER_TIME_DAY, 0,
                     currentTradeID + "S");
     }
   else
      if(currentPrice > buyStopPrice)
        {
         Print("Price above swing high - placing sell stop");
         slPrice = buyStopPrice + slPoints * _Point;
         tpPrice = buyStopPrice - tpPoints * _Point;
         trade.SellStop(lots, NormalizeDouble(buyStopPrice, _Digits), _Symbol,
                        NormalizeDouble(slPrice, _Digits),
                        NormalizeDouble(tpPrice, _Digits),
                        ORDER_TIME_DAY, 0,
                        currentTradeID + "S");
        }
      else
         if(currentPrice < sellStopPrice)
           {
            Print("Price below swing low - placing buy stop");
            slPrice = sellStopPrice - slPoints * _Point;
            tpPrice = sellStopPrice + tpPoints * _Point;
            trade.BuyStop(lots, NormalizeDouble(sellStopPrice, _Digits), _Symbol,
                          NormalizeDouble(slPrice, _Digits),
                          NormalizeDouble(tpPrice, _Digits),
                          ORDER_TIME_DAY, 0,
                          currentTradeID + "L");
           }
   Print("Orders placed. SL: ", slPoints / 10, " pips, TP: ", tpPoints / 10, " pips, Lots: ", lots);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnSessionEnd()
  {
   Print("Session ended - closing all positions and canceling orders");
   CancelAllOrders();
   CloseAllPositions();
   buyStopPrice = 0;
   sellStopPrice = 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CancelRemainingOrders()
  {
   Print("Position opened - canceling remaining pending orders");
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
        {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol)
           {
            string comment = OrderGetString(ORDER_COMMENT);
            if(StringFind(comment, currentTradeID) >= 0)
              {
               trade.OrderDelete(ticket);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CancelAllOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
        {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol)
           {
            trade.OrderDelete(ticket);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
           {
            trade.PositionClose(ticket);
           }
        }
     }
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Kaspricci_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76439
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
