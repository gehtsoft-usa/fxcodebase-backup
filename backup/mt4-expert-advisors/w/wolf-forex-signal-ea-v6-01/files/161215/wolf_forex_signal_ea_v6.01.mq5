/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        wolf_forex_signal_ea_v6.01
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=157940#p157940
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

#property description "This Expert Advisor Works on EURUSD - tf 15m - Default settings."
#include <Trade/Trade.mqh>
CTrade trade;
double Gd_560 = 0.0;
input string     ExpertName           = " WOLF FOREX SIGNAL EA v 6.01 ";
input string     TELEGRAMName         = " https://t.me/WOLF_FOREXSIGNAL ";
input string     SIrialnumber         = " 11ME-55jH-BN61-Mjk2-NM66 ";
input bool       AutoTrade            = true;  // start true=ON
bool             ecnBroker            = false;
input int        MagicID              = 11223366;  // Magic NEMPER
input double     LOTS                 = 0.01;      // fixed lots
input int        risk                 = 10;        // risk:? 0=fixed lots
input double     SL                   = 1000;
input double     TP                   = 1000;
int              Slippage             = 4;
bool             TrailingStopFr       = true;
int              Retries              = 1000;
input string     filter               = "========= Variable filter =========";
input string     ICC                  = "ICC";
input int        period_CC            = 19;
input ENUM_APPLIED_PRICE applied_CC   = PRICE_CLOSE;
input int        Level_buy            = -80;
input int        Level_sell           = 80;
input string     R                    = "RSI";
input int        period_Rsi           = 19;
input ENUM_APPLIED_PRICE applied      = PRICE_CLOSE;
input string     desc3                = "=========ATR Indicator =====";
input int        InpAtrPeriod         = 19;        // ATR Indicator Period
input string     hgg                  = "========= Stochasti Indicator =====";
input int        StochasticKperiod    = 5;         // Stochastic Indicator Period
input int        StochasticDperiod    = 3;         // Stochastic Indicator Period
input int        StochasticSlowing    = 3;         // Stochastic Indicator Slowing
input int        BuyZone              = 30;        // Stochastic Low
input int        SellZone             = 70;        // Stochastic High
input string     gtdd                 = "=========CCI Indicators =====";
input int        CCIperiod            = 12;        // CCI Indicator Period
input int        RSIperiod            = 14;        // RSI Indicator Period
double g_Point;
datetime previousBar = 0;
int handle_CCI;
int handle_RSI;
int handle_WPR;
int handle_AO;
int handle_ATR;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!MQLInfoInteger(MQL_DLLS_ALLOWED))
     {
      Alert("Make Sure DLL Import is Allowed");
      return(INIT_FAILED);
     }
   trade.SetExpertMagicNumber(MagicID);
   trade.SetDeviationInPoints(Slippage);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   handle_CCI = iCCI(_Symbol, PERIOD_CURRENT, period_CC, applied_CC);
   handle_RSI = iRSI(_Symbol, PERIOD_CURRENT, period_Rsi, applied);
   handle_WPR = iWPR(_Symbol, PERIOD_CURRENT, 4);
   handle_AO = iAO(_Symbol, PERIOD_CURRENT);
   handle_ATR = iATR(_Symbol, PERIOD_CURRENT, InpAtrPeriod);
   if(handle_CCI == INVALID_HANDLE || handle_RSI == INVALID_HANDLE ||
      handle_WPR == INVALID_HANDLE || handle_AO == INVALID_HANDLE ||
      handle_ATR == INVALID_HANDLE)
     {
      Print("Error creating indicator handles");
      return(INIT_FAILED);
     }
   g_Point = _Point;
   if(_Digits == 5 || _Digits == 3)
     {
      g_Point *= 10;
      Slippage *= 30;
     }
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_AUTOSCROLL, true);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0);
   ChartRedraw();
   IndicatorRelease(handle_CCI);
   IndicatorRelease(handle_RSI);
   IndicatorRelease(handle_WPR);
   IndicatorRelease(handle_AO);
   IndicatorRelease(handle_ATR);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(previousBar != currentBar)
     {
      previousBar = currentBar;
      ChartRedraw();
     }
   else
     {
      return;
     }
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_H4, 0, 2, rates) < 2)
      return;
   if(rates[0].tick_volume > rates[1].tick_volume)
      return;
   double iCC1_array[], RSI_array[];
   ArraySetAsSeries(iCC1_array, true);
   ArraySetAsSeries(RSI_array, true);
   if(CopyBuffer(handle_CCI, 0, 0, 2, iCC1_array) < 2)
      return;
   if(CopyBuffer(handle_RSI, 0, 0, 2, RSI_array) < 2)
      return;
   double iCC1 = iCC1_array[1];
   double RSI = RSI_array[1];
   MqlRates h4_rates[];
   ArraySetAsSeries(h4_rates, true);
   if(CopyRates(_Symbol, PERIOD_H4, 0, 2, h4_rates) < 2)
     {
      Print("DEBUG: Cannot get H4 data");
      return;
     }
   double signal_price = h4_rates[1].close;
   double wpr_array[], ao_array[];
   ArraySetAsSeries(wpr_array, true);
   ArraySetAsSeries(ao_array, true);
   CopyBuffer(handle_WPR, 0, 0, 1, wpr_array);
   CopyBuffer(handle_AO, 0, 0, 1, ao_array);
   double wpr = wpr_array[0];
   double ao = ao_array[0];
   double level = NormalizeDouble(signal_price, _Digits);
   ObjectDelete(0, "level");
   MakeLine(level);
   MqlRates open_rates[];
   ArraySetAsSeries(open_rates, true);
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, open_rates);
   if(signal_price > open_rates[0].open)
      Comment("BUY - ", signal_price);
   if(signal_price < open_rates[0].open)
      Comment("SELL - ", signal_price);
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread > 150)
      return;
   Print("DEBUG: Checking orders - Buy: ", CheckMarketBuyOrders(), ", Sell: ", CheckMarketSellOrders());
   Print("DEBUG: Signal - signal_price=", signal_price, ", open=", open_rates[0].open);
   if(CheckMarketBuyOrders() < 70 && CheckMarketSellOrders() < 70)
     {
      if(signal_price > open_rates[0].open)
        {
         Print("DEBUG: BUY signal detected, checking pinbar...");
         if(IsBuyPinbar())
           {
            Print("DEBUG: BUY Pinbar confirmed, placing order...");
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double BuySL = NormalizeDouble(ask - SL * g_Point, _Digits);
            double BuyTP = NormalizeDouble(ask + TP * g_Point, _Digits);
            double lots = GetLots();
            if(trade.Buy(lots, _Symbol, ask, BuySL, BuyTP, "WOLF FOREX SIGNAL EA_BUY"))
              {
               Print("DEBUG: BUY order placed successfully");
               CloseSell();
              }
            else
               Print("DEBUG: BUY order FAILED - ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
           }
         else
            Print("DEBUG: BUY Pinbar NOT confirmed");
        }
      if(signal_price < open_rates[0].open)
        {
         Print("DEBUG: SELL signal detected, checking pinbar...");
         if(IsSellPinbar())
           {
            Print("DEBUG: SELL Pinbar confirmed, placing order...");
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double SellSL = NormalizeDouble(bid + SL * g_Point, _Digits);
            double SellTP = NormalizeDouble(bid - TP * g_Point, _Digits);
            double lots = GetLots();
            if(trade.Sell(lots, _Symbol, bid, SellSL, SellTP, "WOLF FOREX SIGNAL EA_sell"))
              {
               Print("DEBUG: SELL order placed successfully");
               CloseBuy();
              }
            else
               Print("DEBUG: SELL order FAILED - ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
           }
         else
            Print("DEBUG: SELL Pinbar NOT confirmed");
        }
     }
   else
      Print("DEBUG: Too many orders already open");
   f0_20();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_20()
  {
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return;
   if(ObjectFind(0, "BG") < 0)
     {
      ObjectCreate(0, "BG", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "BG", OBJPROP_TEXT, "g");
      ObjectSetString(0, "BG", OBJPROP_FONT, "Webdings");
      ObjectSetInteger(0, "BG", OBJPROP_FONTSIZE, 210);
      ObjectSetInteger(0, "BG", OBJPROP_COLOR, clrTeal);
      ObjectSetInteger(0, "BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, "BG", OBJPROP_BACK, true);
      ObjectSetInteger(0, "BG", OBJPROP_XDISTANCE, 0);
      ObjectSetInteger(0, "BG", OBJPROP_YDISTANCE, 15);
     }
   if(ObjectFind(0, "BG1") < 0)
     {
      ObjectCreate(0, "BG1", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "BG1", OBJPROP_TEXT, "g");
      ObjectSetString(0, "BG1", OBJPROP_FONT, "Webdings");
      ObjectSetInteger(0, "BG1", OBJPROP_FONTSIZE, 210);
      ObjectSetInteger(0, "BG1", OBJPROP_COLOR, clrSlateGray);
      ObjectSetInteger(0, "BG1", OBJPROP_BACK, false);
      ObjectSetInteger(0, "BG1", OBJPROP_XDISTANCE, 0);
      ObjectSetInteger(0, "BG1", OBJPROP_YDISTANCE, 42);
     }
   if(ObjectFind(0, "BG2") < 0)
     {
      ObjectCreate(0, "BG2", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "BG2", OBJPROP_TEXT, "g");
      ObjectSetString(0, "BG2", OBJPROP_FONT, "Webdings");
      ObjectSetInteger(0, "BG2", OBJPROP_FONTSIZE, 210);
      ObjectSetInteger(0, "BG2", OBJPROP_COLOR, clrSlateGray);
      ObjectSetInteger(0, "BG2", OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, "BG2", OBJPROP_BACK, true);
      ObjectSetInteger(0, "BG2", OBJPROP_XDISTANCE, 0);
      ObjectSetInteger(0, "BG2", OBJPROP_YDISTANCE, 42);
     }
   if(ObjectFind(0, "NAME") < 0)
     {
      ObjectCreate(0, "NAME", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "NAME", OBJPROP_TEXT, "WOLF FOREX SIGNAL EA v 6.01 - " + _Symbol);
      ObjectSetString(0, "NAME", OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, "NAME", OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, "NAME", OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, "NAME", OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, "NAME", OBJPROP_BACK, false);
      ObjectSetInteger(0, "NAME", OBJPROP_XDISTANCE, 5);
      ObjectSetInteger(0, "NAME", OBJPROP_YDISTANCE, 23);
     }
   if(ObjectFind(0, "BG3") < 0)
     {
      ObjectCreate(0, "BG3", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "BG3", OBJPROP_TEXT, "g");
      ObjectSetString(0, "BG3", OBJPROP_FONT, "Webdings");
      ObjectSetInteger(0, "BG3", OBJPROP_FONTSIZE, 110);
      ObjectSetInteger(0, "BG3", OBJPROP_COLOR, clrSlateGray);
      ObjectSetInteger(0, "BG3", OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, "BG3", OBJPROP_BACK, true);
      ObjectSetInteger(0, "BG3", OBJPROP_XDISTANCE, 0);
      ObjectSetInteger(0, "BG3", OBJPROP_YDISTANCE, 73);
     }
   if(ObjectFind(0, "BG5") < 0)
     {
      ObjectCreate(0, "BG5", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "BG5", OBJPROP_TEXT, "g");
      ObjectSetString(0, "BG5", OBJPROP_FONT, "Webdings");
      ObjectSetInteger(0, "BG5", OBJPROP_FONTSIZE, 210);
      ObjectSetInteger(0, "BG5", OBJPROP_COLOR, clrSlateGray);
      ObjectSetInteger(0, "BG5", OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, "BG5", OBJPROP_BACK, false);
      ObjectSetInteger(0, "BG5", OBJPROP_XDISTANCE, 0);
      ObjectSetInteger(0, "BG5", OBJPROP_YDISTANCE, 73);
     }
   f0_7();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fnGetLotDigit()
  {
   double l_LotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(l_LotStep == 1)
      return(0);
   if(l_LotStep == 0.1)
      return(1);
   if(l_LotStep == 0.01)
      return(2);
   if(l_LotStep == 0.001)
      return(3);
   if(l_LotStep == 0.0001)
      return(4);
   return(1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketBuyOrders()
  {
   int op = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong pos_ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(pos_ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC) != MagicID)
            continue;
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
           {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               op++;
              }
           }
        }
     }
   return(op);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketSellOrders()
  {
   int op = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong pos_ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(pos_ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC) != MagicID)
            continue;
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
           {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               op++;
              }
           }
        }
     }
   return(op);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy()
  {
   while(CheckMarketBuyOrders() > 0)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong pos_ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(pos_ticket))
           {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_MAGIC) == MagicID)
              {
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                 {
                  trade.PositionClose(pos_ticket);
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSell()
  {
   while(CheckMarketSellOrders() > 0)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong pos_ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(pos_ticket))
           {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_MAGIC) == MagicID)
              {
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                 {
                  trade.PositionClose(pos_ticket);
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLots()
  {
   double lot;
   double minlot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxlot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(risk != 0)
     {
      lot = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE) * risk / 100 / 10000, 2);
      if(lot < minlot)
         lot = minlot;
      if(lot > maxlot)
         lot = maxlot;
     }
   else
      lot = LOTS;
   return(lot);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MakeLine(double price)
  {
   string name = "level";
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   CopyRates(_Symbol, PERIOD_M1, 0, 1, rates);
   if(price > rates[0].open)
      Comment("BUY = " + DoubleToString(price, _Digits));
   if(price < rates[0].open)
      Comment("SELL= " + DoubleToString(price, _Digits));
   if(ObjectFind(0, name) != -1)
     {
      ObjectMove(0, name, 0, iTime(_Symbol, PERIOD_M1, 0), price);
      return;
     }
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrOrange);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 42);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBuyPinbar()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 4, rates) < 4)
      return false;
   double actOp = rates[1].open;
   double actCl = rates[1].close;
   double actHi = rates[1].high;
   double actLo = rates[1].low;
   double preOp = rates[2].open;
   double preCl = rates[2].close;
   double preHi = rates[2].high;
   double preLo = rates[2].low;
   Print("DEBUG BUY PINBAR: Vizsgált gyertya index = 1 (rates[1])");
   Print("DEBUG BUY: rates[0].high (AKTUÁLIS)=", DoubleToString(rates[0].high, 5));
   Print("DEBUG BUY: rates[1] OHLC: O=", DoubleToString(actOp, 5),
         " H=", DoubleToString(rates[1].high, 5),
         " L=", DoubleToString(actLo, 5),
         " C=", DoubleToString(actCl, 5));
   Print("DEBUG BUY: rates[2] OHLC: O=", DoubleToString(preOp, 5),
         " H=", DoubleToString(preHi, 5),
         " L=", DoubleToString(preLo, 5),
         " C=", DoubleToString(preCl, 5));
   double actRange = actHi - actLo;
   double preRange = preHi - preLo;
   double actHigherPart = actHi - actRange * 0.4;
   double actHigherPart1 = actHi - actRange * 0.4;
   double dayRange = AveRange4();
   Print("DEBUG BUY: actHi=", DoubleToString(actHi, 5), " actLo=", DoubleToString(actLo, 5));
   Print("DEBUG BUY: actRange=", DoubleToString(actRange, 5),
         " dayRange=", DoubleToString(dayRange, 5),
         " dayRange*0.5=", DoubleToString(dayRange * 0.5, 5));
   Print("DEBUG BUY: actHigherPart=", DoubleToString(actHigherPart, 5),
         " actCl=", DoubleToString(actCl, 5),
         " actOp=", DoubleToString(actOp, 5));
   Print("DEBUG BUY: actLo + actRange*0.25 = ", DoubleToString(actLo + actRange * 0.25, 5),
         " preLo=", DoubleToString(preLo, 5));
   if((actCl > actHigherPart1 && actOp > actHigherPart) &&
      (actRange > dayRange * 0.5) &&
      (actLo + actRange * 0.25 < preLo))
     {
      Print("DEBUG BUY: Első 3 feltétel TELJESÜLT!");
      double lows[];
      ArraySetAsSeries(lows, true);
      if(CopyLow(_Symbol, PERIOD_CURRENT, 3, 3, lows) >= 3)
        {
         int minIdx = ArrayMinimum(lows);
         Print("DEBUG BUY: Checking rates[3,4,5] - lows[", minIdx, "]=", DoubleToString(lows[minIdx], 5),
               " rates[1].low=", DoubleToString(rates[1].low, 5));
         if(lows[minIdx] > rates[1].low)
           {
            Print("DEBUG BUY: *** PINBAR CONFIRMED! ***");
            return true;
           }
         else
           {
            Print("DEBUG BUY: Utolsó feltétel FAIL - lows[minIdx] <= rates[1].low");
           }
        }
     }
   else
     {
      Print("DEBUG BUY: Első 3 feltétel FAIL - nincs pinbar");
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSellPinbar()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 4, rates) < 4)
      return false;
   double actOp = rates[1].open;
   double actCl = rates[1].close;
   double actHi = rates[1].high;
   double actLo = rates[1].low;
   double preOp = rates[2].open;
   double preCl = rates[2].close;
   double preHi = rates[2].high;
   double preLo = rates[2].low;
   Print("DEBUG SELL PINBAR: Vizsgált gyertya index = 1 (rates[1])");
   Print("DEBUG SELL: rates[1] OHLC: O=", DoubleToString(actOp, 5),
         " H=", DoubleToString(actHi, 5),
         " L=", DoubleToString(actLo, 5),
         " C=", DoubleToString(actCl, 5));
   Print("DEBUG SELL: rates[2] OHLC: O=", DoubleToString(preOp, 5),
         " H=", DoubleToString(preHi, 5),
         " L=", DoubleToString(preLo, 5),
         " C=", DoubleToString(preCl, 5));
   double actRange = actHi - actLo;
   double preRange = preHi - preLo;
   double actLowerPart = actLo + actRange * 0.4;
   double actLowerPart1 = actLo + actRange * 0.4;
   double dayRange = AveRange4();
   Print("DEBUG SELL: actRange=", DoubleToString(actRange, 5),
         " dayRange=", DoubleToString(dayRange, 5),
         " dayRange*0.5=", DoubleToString(dayRange * 0.5, 5));
   Print("DEBUG SELL: actLowerPart=", DoubleToString(actLowerPart, 5),
         " actCl=", DoubleToString(actCl, 5),
         " actOp=", DoubleToString(actOp, 5));
   Print("DEBUG SELL: actHi - actRange*0.25 = ", DoubleToString(actHi - actRange * 0.25, 5),
         " preHi=", DoubleToString(preHi, 5));
   if((actCl < actLowerPart1 && actOp < actLowerPart) &&
      (actRange > dayRange * 0.5) &&
      (actHi - actRange * 0.25 > preHi))
     {
      Print("DEBUG SELL: Első 3 feltétel TELJESÜLT!");
      double highs[];
      ArraySetAsSeries(highs, true);
      if(CopyHigh(_Symbol, PERIOD_CURRENT, 3, 3, highs) >= 3)
        {
         int maxIdx = ArrayMaximum(highs);
         Print("DEBUG SELL: Checking rates[3,4,5] - highs[", maxIdx, "]=", DoubleToString(highs[maxIdx], 5),
               " rates[1].high=", DoubleToString(rates[1].high, 5));
         if(highs[maxIdx] < rates[1].high)
           {
            Print("DEBUG SELL: *** PINBAR CONFIRMED! ***");
            return true;
           }
         else
           {
            Print("DEBUG SELL: Utolsó feltétel FAIL - highs[maxIdx] >= rates[1].high");
           }
        }
     }
   else
     {
      Print("DEBUG SELL: Első 3 feltétel FAIL - nincs pinbar");
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AveRange4()
  {
   double sum = 0;
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 10, rates) < 10)
      return 0;
   int i = 0;
   int ind = 1;
   while(i < 4 && ind < 10)
     {
      MqlDateTime dt;
      TimeToStruct((datetime)rates[ind].time, dt);
      if(dt.day_of_week != 0)
        {
         sum += rates[ind].high - rates[ind].low;
         i++;
        }
      ind++;
     }
   return(sum / 4.0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CandleStick_Analyzer()
  {
   string CandleStick, Comment1 = "", Comment2 = "", Comment3 = "", Comment4 = "";
   string Comment5 = "", Comment6 = "", Comment7 = "", Comment8 = "", Comment9 = "";
   if(BullishEngulfingExists())
      Comment1 = " Bullish Engulfing ";
   if(BullishHaramiExists())
      Comment2 = " Bullish Harami ";
   if(LongUpCandleExists())
      Comment3 = " Bullish LongUp ";
   if(DojiAtBottomExists())
      Comment4 = " MorningStar Doji ";
   if(DojiAtTopExists())
      Comment5 = " EveningStar Doji ";
   if(BearishHaramiExists())
      Comment6 = " Bearish Harami ";
   if(BearishEngulfingExists())
      Comment7 = " Bearish Engulfing ";
   if(LongDownCandleExists())
      Comment8 = " Bearish LongDown ";
   CandleStick = Comment1 + Comment2 + Comment3 + Comment4 + Comment5 +
                 Comment6 + Comment7 + Comment8 + Comment9;
   return(CandleStick);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishEngulfingExists()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 1, 2, rates) < 2)
      return false;
   if(rates[0].open <= rates[1].close && rates[0].close >= rates[1].open &&
      rates[1].open - rates[1].close >= 10 * _Point && rates[0].close - rates[0].open >= 10 * _Point)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishHaramiExists()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 1, 2, rates) < 2)
      return false;
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(handle_ATR, 0, 1, 1, atr) < 1)
      return false;
   if(rates[1].close < rates[1].open && rates[0].open < rates[0].close &&
      rates[1].open - rates[1].close > atr[0] &&
      rates[1].open - rates[1].close > 4 * (rates[0].close - rates[0].open))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DojiAtBottomExists()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 1, 3, rates) < 3)
      return false;
   if(rates[2].open - rates[2].close >= 8 * _Point &&
      MathAbs(rates[1].close - rates[1].open) <= 1 * _Point &&
      rates[0].close - rates[0].open >= 8 * _Point)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DojiAtTopExists()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 1, 3, rates) < 3)
      return false;
   if(rates[2].close - rates[2].open >= 8 * _Point &&
      MathAbs(rates[1].close - rates[1].open) <= 1 * _Point &&
      rates[0].open - rates[0].close >= 8 * _Point)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishHaramiExists()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 1, 2, rates) < 2)
      return false;
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(handle_ATR, 0, 1, 1, atr) < 1)
      return false;
   if(rates[1].close > rates[0].close && rates[1].open < rates[0].open &&
      rates[1].close > rates[1].open && rates[0].open > rates[0].close &&
      rates[1].close - rates[1].open > atr[0] &&
      rates[1].close - rates[1].open > 4 * (rates[0].open - rates[0].close))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongUpCandleExists()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 1, 2, rates) < 2)
      return false;
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(handle_ATR, 0, 1, 1, atr) < 1)
      return false;
   if(rates[1].open < rates[1].close && rates[1].high - rates[1].low >= 40 * _Point &&
      rates[1].high - rates[1].low > 2.5 * atr[0] &&
      rates[0].close < rates[0].open && rates[0].open - rates[0].close > 10 * _Point)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongDownCandleExists()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 2, rates) < 2)
      return false;
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(handle_ATR, 0, 0, 1, atr) < 1)
      return false;
   if(rates[0].open > rates[0].close && rates[0].high - rates[0].low >= 40 * _Point &&
      rates[0].high - rates[0].low > 2.5 * atr[0])
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishEngulfingExists()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 2, rates) < 2)
      return false;
   if(rates[0].open >= rates[1].close && rates[0].close <= rates[1].open &&
      rates[1].open - rates[1].close >= 10 * _Point && rates[0].close - rates[0].open >= 10 * _Point)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_7()
  {
   string Ls_16 = "Margin Usage:                            " +
                  DoubleToString(100 - 100.0 * (AccountInfoDouble(ACCOUNT_MARGIN_FREE) /
                                 AccountInfoDouble(ACCOUNT_BALANCE)), 2) + "%\n";
   string dbl2str_24 = DoubleToString(f0_13(), 2);
   if(f0_13() > Gd_560)
      Gd_560 = f0_13();
   Comment(""
           + "\n"
           + "\n"
           + "-----------------------------------------------------------------------------------"
           + "\n"
           + "ACCOUNT INFORMATION"
           + "\n"
           + "-----------------------------------------------------------------------------------"
           + "\n"
           + "Broker             :  " + AccountInfoString(ACCOUNT_COMPANY) + " "
           + "\n"
           + "Acc. Name       :  " + AccountInfoString(ACCOUNT_NAME) + " "
           + "\n"
           + "Account Number:             " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + " "
           + "\n"
           + "Account Leverage:           1:" + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE))
           + "\n"
           + "Account Balance:             " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2)
           + "\n"
           + "Account Equity:               " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2)
           + "\n"
           + "Server Time:                   " + TimeToString(TimeCurrent(), TIME_SECONDS)
           + "\n"
           + "-----------------------------------------------------------------------------------"
           + "\n"
           + "TRADE INFORMATIONS "
           + "\n"
           + "-----------------------------------------------------------------------------------"
           + "\n"
           + "FLOATING P/L :                          " + DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT), 2)
           + "\n"
           + "Drawdown :                               " + dbl2str_24 + "%"
           + "\n"
           + "Drawdown (Max) :                      " + DoubleToString(Gd_560, 2) + "%"
           + "\n"
           + Ls_16 + "Total Profit/Loss :                        " + DoubleToString(f0_3(), 2)
           + "\n"
           + "-----------------------------------------------------------------------------------"
           + "\n"
           + "MORE INFORMATIONS "
           + "\n"
           + "-----------------------------------------------------------------------------------"
           + "\n"
           + "Symbol: " + _Symbol + " "
           + "\n"
           + "Price:  " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), 4) + " "
           + "\n"
           + "Current Spread  :  " + IntegerToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), 0) + " ");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double f0_3()
  {
   double Ld_ret_0 = 0;
   HistorySelect(0, TimeCurrent());
   int hist_total = HistoryDealsTotal();
   for(int i = 0; i < hist_total; i++)
     {
      ulong deal_ticket = HistoryDealGetTicket(i);
      if(deal_ticket > 0)
        {
         long deal_magic = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
         if(deal_magic == MagicID)
           {
            Ld_ret_0 += HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
            Ld_ret_0 += HistoryDealGetDouble(deal_ticket, DEAL_SWAP);
            Ld_ret_0 += HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
           }
        }
     }
   return(Ld_ret_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double f0_13()
  {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance == 0)
      return 0;
   double Ld_ret_0 = (AccountInfoDouble(ACCOUNT_EQUITY) / balance - 1.0) / (-0.01);
   if(Ld_ret_0 <= 0.0)
      return(0);
   return(Ld_ret_0);
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        wolf_forex_signal_ea_v6.01
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=157940#p157940
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
