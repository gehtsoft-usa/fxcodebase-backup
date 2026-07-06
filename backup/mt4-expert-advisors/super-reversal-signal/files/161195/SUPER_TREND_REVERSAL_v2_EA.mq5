//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=71766&p=161195#p161195
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

#include <Trade/Trade.mqh>

enum ENUM_TRADING_MODE
{
    MODE_FIXED_SL_TP = 1, //Fixed SL/TP
    MODE_CLOSE_ON_REVERSE = 2 //Close on Reverse
};

input string T0              = "== Trading Setup ==";
input double InpLots            = 0.1;                       // Lot Size
input ENUM_TRADING_MODE InpTradingMode = MODE_FIXED_SL_TP;   // Trading Mode

input string T1              = "== Fixed SL/TP (Mode Fixed) ==";
input int    InpSlPoints       = 200;                       // Stop Loss in points (0 = disabled)
input int    InpTpPoints       = 400;                       // Take Profit in points (0 = disabled)

input string T2              = "== Indicator Setup ==";
input string IndiFile        = "Fibo_Algo";               // Indicator Name

input string T3              = "== Magic Number ==";
input ulong  InpMagicNumber     = 723;                       // Magic Number
input string  InpComment     = "SUPER_TREND_REVERSAL_v2";       // Comment

int    indiHandle = INVALID_HANDLE;
CTrade trade;

datetime  lastSignalBarBuy  = 0;
datetime  lastSignalBarSell = 0;

int OnInit()
  {
   trade.SetExpertMagicNumber((long)InpMagicNumber);
   indiHandle = iCustom(_Symbol, _Period, IndiFile);
   if(indiHandle == INVALID_HANDLE)
     {
      Print("Indicator initialization failed: ", GetLastError());
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   if(indiHandle != INVALID_HANDLE)
      IndicatorRelease(indiHandle);
  }

void OnTick()
  {
   static datetime lastBarTime = 0;
   datetime curBarTime = iTime(_Symbol, _Period, 0);
   if(curBarTime == lastBarTime)
      return;
   lastBarTime = curBarTime;

   double buySignal[1];
   double sellSignal[1];
   if(CopyBuffer(indiHandle, 1, 1, 1, buySignal) < 0 ||
      CopyBuffer(indiHandle, 0, 1, 1, sellSignal) < 0)
     {
      Print("CopyBuffer failed: ", GetLastError());
      return;
     }

   bool isBuySignal  = (buySignal[0] != EMPTY_VALUE);
   bool isSellSignal = (sellSignal[0] != EMPTY_VALUE);

   datetime prevBarTime = iTime(_Symbol, _Period, 1);

   if(isBuySignal)
     {
      if(lastSignalBarBuy != prevBarTime)
         ProcessSignal(ORDER_TYPE_BUY, prevBarTime);
     }

   if(isSellSignal)
     {
      if(lastSignalBarSell != prevBarTime)
         ProcessSignal(ORDER_TYPE_SELL, prevBarTime);
     }

   if(InpTradingMode == MODE_CLOSE_ON_REVERSE)
      CloseOnOppositeSignal(isBuySignal, isSellSignal);
  }

void ProcessSignal(ENUM_ORDER_TYPE orderType, datetime barTime)
  {
   if(PositionSelect(_Symbol))
     {
      if(PositionGetInteger(POSITION_TYPE) == orderType)
         return;
     }

   double sl = 0, tp = 0;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   if(InpTradingMode == MODE_FIXED_SL_TP)
     {
      if(InpSlPoints > 0)
        {
         sl = (orderType == ORDER_TYPE_BUY) ? ask - InpSlPoints*_Point : bid + InpSlPoints*_Point;
        }
      if(InpTpPoints > 0)
        {
         tp = (orderType == ORDER_TYPE_BUY) ? ask + InpTpPoints*_Point : bid - InpTpPoints*_Point;
        }
     }

   trade.SetDeviationInPoints(30);
   bool result = (orderType == ORDER_TYPE_BUY) ?
                 trade.Buy(InpLots, _Symbol, 0, sl, tp, InpComment) :
                 trade.Sell(InpLots, _Symbol, 0, sl, tp, InpComment);

   if(result)
     {
      if(orderType == ORDER_TYPE_BUY)
         lastSignalBarBuy = barTime;
      else
         lastSignalBarSell = barTime;
     }
   else
      Print("Order send failed: ", trade.ResultRetcode());
  }

void CloseOnOppositeSignal(bool isBuySignal, bool isSellSignal)
  {
   if(!PositionSelect(_Symbol))
      return;

   ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

   if(posType == POSITION_TYPE_BUY && isSellSignal)
     {
      trade.PositionClose(_Symbol);
     }
   if(posType == POSITION_TYPE_SELL && isBuySignal)
     {
      trade.PositionClose(_Symbol);
     }
  }

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=71766&p=161195#p161195
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