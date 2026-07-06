//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161112#p161112
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
#include <Trade/PositionInfo.mqh>
CTrade trade;
CPositionInfo position;

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
input int    InpAtrPeriod      = 20;                        // ATR Period
input double InpAtrMulti      = 3.0;                       // ATR Multiplier

input string T3              = "== Magic Number ==";
input ulong  InpMagicNumber     = 723;                       // Magic Number
input string  InpComment     = "Fibo_Algo";       // Comment

int    indiHandle = INVALID_HANDLE;
datetime lastSignalBarBuy  = 0;
datetime lastSignalBarSell = 0;

int OnInit()
{
    indiHandle = iCustom(_Symbol, _Period, IndiFile,
                        "== ATR Setup ==",
                        true,
                        InpAtrPeriod,
                        InpAtrMulti,
                        "== Notifications ==",
                        false,
                        false,
                        false,
                        false);
    
    if(indiHandle == INVALID_HANDLE)
    {
        Print("Failed to load indicator: ", IndiFile);
        return(INIT_FAILED);
    }
    
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetDeviationInPoints(30);
    trade.SetTypeFilling(ORDER_FILLING_FOK);
    trade.SetAsyncMode(false);
    
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
    
    if(CopyBuffer(indiHandle, 2, 1, 1, buySignal) < 0 ||
       CopyBuffer(indiHandle, 3, 1, 1, sellSignal) < 0)
    {
        return;
    }
    
    bool isBuySignal  = (buySignal[0] != EMPTY_VALUE && buySignal[0] != 0);
    bool isSellSignal = (sellSignal[0] != EMPTY_VALUE && sellSignal[0] != 0);
    
    datetime prevBarTime = iTime(_Symbol, _Period, 1);
    
    if(InpTradingMode == MODE_FIXED_SL_TP)
    {
        if(isBuySignal && lastSignalBarBuy != prevBarTime)
        {
            bool sellClosed = ClosePositionsByType(POSITION_TYPE_SELL);
            if(!sellClosed && HasPosition(ORDER_TYPE_SELL))
            {
                return;
            }
            else if(!HasPosition(ORDER_TYPE_BUY))
            {
                ProcessSignalFixed(ORDER_TYPE_BUY, prevBarTime);
            }
        }
        
        if(isSellSignal && lastSignalBarSell != prevBarTime)
        {
            bool buyClosed = ClosePositionsByType(POSITION_TYPE_BUY);
            if(!buyClosed && HasPosition(ORDER_TYPE_BUY))
            {
                return;
            }
            else if(!HasPosition(ORDER_TYPE_SELL))
            {
                ProcessSignalFixed(ORDER_TYPE_SELL, prevBarTime);
            }
        }
    }
    else if(InpTradingMode == MODE_CLOSE_ON_REVERSE)
    {
        if(isBuySignal && lastSignalBarBuy != prevBarTime)
        {
            ClosePositionsByType(POSITION_TYPE_SELL);
            if(!HasPosition(ORDER_TYPE_BUY))
                ProcessSignalReverse(ORDER_TYPE_BUY, prevBarTime);
        }
        
        if(isSellSignal && lastSignalBarSell != prevBarTime)
        {
            ClosePositionsByType(POSITION_TYPE_BUY);
            if(!HasPosition(ORDER_TYPE_SELL))
                ProcessSignalReverse(ORDER_TYPE_SELL, prevBarTime);
        }
    }
}

void ProcessSignalFixed(ENUM_ORDER_TYPE orderType, datetime barTime)
{
    double sl = 0, tp = 0;
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    if(InpSlPoints > 0)
    {
        sl = (orderType == ORDER_TYPE_BUY) ? 
             NormalizeDouble(ask - InpSlPoints * _Point, _Digits) : 
             NormalizeDouble(bid + InpSlPoints * _Point, _Digits);
    }
    
    if(InpTpPoints > 0)
    {
        tp = (orderType == ORDER_TYPE_BUY) ? 
             NormalizeDouble(ask + InpTpPoints * _Point, _Digits) : 
             NormalizeDouble(bid - InpTpPoints * _Point, _Digits);
    }
    
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
}

void ProcessSignalReverse(ENUM_ORDER_TYPE orderType, datetime barTime)
{
    bool result = (orderType == ORDER_TYPE_BUY) ?
                  trade.Buy(InpLots, _Symbol, 0, 0, 0, InpComment) :
                  trade.Sell(InpLots, _Symbol, 0, 0, 0, InpComment);
    
    if(result)
    {
        if(orderType == ORDER_TYPE_BUY)
            lastSignalBarBuy = barTime;
        else
            lastSignalBarSell = barTime;
    }
}

bool ClosePositionsByType(ENUM_POSITION_TYPE posTypeToClose)
{
    bool found = false;
    bool allClosed = true;
    
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!position.SelectByIndex(i))
            continue;
        
        if(position.Symbol() != _Symbol)
            continue;
        
        if(position.Magic() != InpMagicNumber)
            continue;
        
        ENUM_POSITION_TYPE posType = position.PositionType();
        
        if(posType == posTypeToClose)
        {
            found = true;
            ulong ticket = position.Ticket();
            if(!trade.PositionClose(ticket))
            {
                allClosed = false;
            }
        }
    }
    
    if(!found)
        return true;
    
    return allClosed;
}

bool HasPosition(ENUM_ORDER_TYPE orderType)
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!position.SelectByIndex(i))
            continue;
        
        if(position.Symbol() != _Symbol)
            continue;
        
        if(position.Magic() != InpMagicNumber)
            continue;
        
        ENUM_POSITION_TYPE posType = position.PositionType();
        
        if(orderType == ORDER_TYPE_BUY && posType == POSITION_TYPE_BUY)
            return true;
        
        if(orderType == ORDER_TYPE_SELL && posType == POSITION_TYPE_SELL)
            return true;
    }
    
    return false;
}

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161112#p161112
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