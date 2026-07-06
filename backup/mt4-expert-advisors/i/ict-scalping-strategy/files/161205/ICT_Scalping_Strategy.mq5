//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76437
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
#include <Trade/OrderInfo.mqh>

CTrade trade;

// --- Inputs ---
input double LotSize = 0.01;          // Lot size for trades
input int SwingDepth = 5;             // Depth for swing high/low detection
input double FibLevel = 0.619;        // Fibonacci retracement level for entry
input double RiskReward = 1.5;        // Risk to reward ratio
input int Magic = 1234;               // Magic number for trades
input int Slippage = 3;               // Maximum slippage for orders

double High[], Low[], Close[], Open[];

bool sellSweepDetected = false;
double sellSweepHigh = 0;
double sellOrderBlockLow = 0;
bool sellConfirmed = false;
double sellNewLow = 0;
bool sellSetupActive = false;
double sellEntry = 0;
double sellSL = 0;
double sellTP = 0;
ulong sellTicket = 0;

bool buySweepDetected = false;
double buySweepLow = 0;
double buyOrderBlockHigh = 0;
bool buyConfirmed = false;
double buyNewHigh = 0;
bool buySetupActive = false;
double buyEntry = 0;
double buySL = 0;
double buyTP = 0;
ulong buyTicket = 0;

bool IsNewBar() {
  static datetime last = 0;
  datetime now = iTime(_Symbol, PERIOD_CURRENT, 0);
  if (now != last) {
    last = now;
    return true;
  }
  return false;
}

int FindLastSwingHigh(int start, int depth) {
  for (int i = start; i < start + 100; i++) {
    bool isHigh = true;
    for (int j = 1; j <= depth; j++) {
      if (i - j >= 0 && High[i] <= High[i - j]) isHigh = false;
      if (i + j < ArraySize(High) && High[i] <= High[i + j]) isHigh = false;
    }
    if (isHigh) return i;
  }
  return -1;
}

int FindLastSwingLow(int start, int depth) {
  for (int i = start; i < start + 100; i++) {
    bool isLow = true;
    for (int j = 1; j <= depth; j++) {
      if (i - j >= 0 && Low[i] >= Low[i - j]) isLow = false;
      if (i + j < ArraySize(Low) && Low[i] >= Low[i + j]) isLow = false;
    }
    if (isLow) return i;
  }
  return -1;
}

bool HasOpenPosition(int dir) {
  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong ticket = PositionGetTicket(i);
    if (ticket == 0) continue;
    if (!PositionSelectByTicket(ticket)) continue;
    if (PositionGetInteger(POSITION_MAGIC) != Magic) continue;
    string sym;
    if (!PositionGetString(POSITION_SYMBOL, sym)) continue;
    if (sym != _Symbol) continue;

    long type = PositionGetInteger(POSITION_TYPE);
    if (dir == 0) return true;
    if (dir == 1 && type == POSITION_TYPE_BUY) return true;
    if (dir == 2 && type == POSITION_TYPE_SELL) return true;
  }
  return false;
}

bool HasPendingOrder(int dir) {
  COrderInfo order;
  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    if (!order.SelectByIndex(i)) continue;
    if (order.Magic() != Magic) continue;
    if (order.Symbol() != _Symbol) continue;

    ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)order.Type();

    if (dir == 0) return true;
    if (dir == 1 && type == ORDER_TYPE_BUY_LIMIT) return true;
    if (dir == 2 && type == ORDER_TYPE_SELL_LIMIT) return true;
  }
  return false;
}

void ResetSellState() {
  sellSweepDetected = false;
  sellSweepHigh = 0.0;
  sellOrderBlockLow = 0.0;
  sellConfirmed = false;
  sellNewLow = 0.0;
  sellSetupActive = false;
  sellEntry = 0.0;
  sellSL = 0.0;
  sellTP = 0.0;
  sellTicket = 0;
}

void ResetBuyState() {
  buySweepDetected = false;
  buySweepLow = 0.0;
  buyOrderBlockHigh = 0.0;
  buyConfirmed = false;
  buyNewHigh = 0.0;
  buySetupActive = false;
  buyEntry = 0.0;
  buySL = 0.0;
  buyTP = 0.0;
  buyTicket = 0;
}

void OnInit() {
  trade.SetExpertMagicNumber(Magic);
  trade.SetDeviationInPoints(Slippage);
}

void OnTick() {
  if (!IsNewBar()) return;

  int bars_to_copy = MathMax(SwingDepth * 5, 200);
  int copiedHigh = CopyHigh(_Symbol, PERIOD_CURRENT, 0, bars_to_copy, High);
  int copiedLow = CopyLow(_Symbol, PERIOD_CURRENT, 0, bars_to_copy, Low);
  int copiedClose = CopyClose(_Symbol, PERIOD_CURRENT, 0, bars_to_copy, Close);
  int copiedOpen = CopyOpen(_Symbol, PERIOD_CURRENT, 0, bars_to_copy, Open);
  if (copiedHigh <= SwingDepth + 3 || copiedLow <= SwingDepth + 3 || copiedClose <= SwingDepth + 3 || copiedOpen <= SwingDepth + 3)
    return;

  ArraySetAsSeries(High, true);
  ArraySetAsSeries(Low, true);
  ArraySetAsSeries(Close, true);
  ArraySetAsSeries(Open, true);

  int totalBars = ArraySize(High);
  if (totalBars <= SwingDepth + 2 || ArraySize(Low) != totalBars || ArraySize(Close) <= 1) return;

  bool sellPos = HasOpenPosition(2);
  bool buyPos = HasOpenPosition(1);
  bool sellPending = HasPendingOrder(2);
  bool buyPending = HasPendingOrder(1);

  if (!sellPos && !sellPending && sellSetupActive) ResetSellState();
  if (!buyPos && !buyPending && buySetupActive) ResetBuyState();

  bool canSell = (!sellPos && !sellPending);
  bool canBuy = (!buyPos && !buyPending);

  if (canSell) {
    int swing_high_bar = FindLastSwingHigh(2, SwingDepth);
    if (swing_high_bar != -1 && swing_high_bar < totalBars) {
      double swing_high = High[swing_high_bar];

      if (!sellSweepDetected && High[1] > swing_high && Close[1] < swing_high) {
        sellSweepDetected = true;
        sellSweepHigh = High[1];

        int ob_end = swing_high_bar;
        int ob_start = ob_end;
        while (ob_start > 0 && Close[ob_start] < Open[ob_start]) ob_start--;
        ob_start++;

        if (ob_start <= ob_end && ob_end < totalBars) {
          double obLow = Low[ob_start];
          for (int idx = ob_start; idx <= ob_end; idx++) obLow = MathMin(obLow, Low[idx]);
          sellOrderBlockLow = obLow;
        } else {
          sellSweepDetected = false;
          sellOrderBlockLow = 0.0;
        }
      }

      if (sellSweepDetected && sellOrderBlockLow > 0.0 && !sellConfirmed && Close[1] < sellOrderBlockLow) {
        sellConfirmed = true;
      }

      if (sellConfirmed && !sellSetupActive) {
        int new_low_bar = FindLastSwingLow(1, SwingDepth);
        if (new_low_bar != -1 && new_low_bar < totalBars) {
          sellNewLow = Low[new_low_bar];
          double fib_high = sellSweepHigh;
          double fib_low = sellNewLow;
          sellEntry = fib_low + FibLevel * (fib_high - fib_low);
          sellSL = fib_high + _Point * 10;
          double risk = sellSL - sellEntry;
          if (risk <= 0) {
            ResetSellState();
          } else {
            sellTP = sellEntry - RiskReward * risk;
            double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double minDist = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
            sellEntry = NormalizeDouble(sellEntry, _Digits);
            sellSL = NormalizeDouble(sellSL, _Digits);
            sellTP = NormalizeDouble(sellTP, _Digits);
            if (sellEntry >= currentAsk + minDist) {
              if (trade.SellLimit(LotSize, sellEntry, _Symbol, sellSL, sellTP, 0, 0, "ICT Sell")) {
                sellSetupActive = true;
                sellTicket = trade.ResultOrder();
              }
            } else {
              ResetSellState();
            }
          }
        }
      }
    }
  }

  if (canBuy) {
    int swing_low_bar = FindLastSwingLow(2, SwingDepth);
    if (swing_low_bar != -1 && swing_low_bar < totalBars) {
      double swing_low = Low[swing_low_bar];

      if (!buySweepDetected && Low[1] < swing_low && Close[1] > swing_low) {
        buySweepDetected = true;
        buySweepLow = Low[1];

        int ob_end = swing_low_bar;
        int ob_start = ob_end;
        while (ob_start > 0 && Close[ob_start] > Open[ob_start]) ob_start--;
        ob_start++;

        if (ob_start <= ob_end && ob_end < totalBars) {
          double obHigh = High[ob_start];
          for (int idx = ob_start; idx <= ob_end; idx++) obHigh = MathMax(obHigh, High[idx]);
          buyOrderBlockHigh = obHigh;
        } else {
          buySweepDetected = false;
          buyOrderBlockHigh = 0.0;
        }
      }

      if (buySweepDetected && buyOrderBlockHigh > 0.0 && !buyConfirmed && Close[1] > buyOrderBlockHigh) {
        buyConfirmed = true;
      }

      if (buyConfirmed && !buySetupActive) {
        int new_high_bar = FindLastSwingHigh(1, SwingDepth);
        if (new_high_bar != -1 && new_high_bar < totalBars) {
          buyNewHigh = High[new_high_bar];
          double fib_low = buySweepLow;
          double fib_high = buyNewHigh;
          buyEntry = fib_high - FibLevel * (fib_high - fib_low);
          buySL = fib_low - _Point * 10;
          double risk = buyEntry - buySL;
          if (risk <= 0) {
            ResetBuyState();
          } else {
            buyTP = buyEntry + RiskReward * risk;
            double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double minDist = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
            buyEntry = NormalizeDouble(buyEntry, _Digits);
            buySL = NormalizeDouble(buySL, _Digits);
            buyTP = NormalizeDouble(buyTP, _Digits);
            if (buyEntry <= currentBid - minDist) {
              if (trade.BuyLimit(LotSize, buyEntry, _Symbol, buySL, buyTP, 0, 0, "ICT Buy")) {
                buySetupActive = true;
                buyTicket = trade.ResultOrder();
              }
            } else {
              ResetBuyState();
            }
          }
        }
      }
    }
  }
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76437
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