/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        ICT_Scalping_Strategy
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=161257#p161257
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

input double LotSize = 0.01;          // Lot size for trades
input int SwingDepth = 5;             // Depth for swing high/low detection
input double FibLevel = 0.619;        // Fibonacci retracement level for entry
input double RiskReward = 1.5;        // Risk to reward ratio
input int Magic = 1234;               // Magic number for trades
input int Slippage = 3;               // Maximum slippage for orders
bool sellSweepDetected = false;
double sellSweepHigh = 0;
double sellOrderBlockLow = 0;
bool sellConfirmed = false;
double sellNewLow = 0;
bool sellSetupActive = false;
double sellEntry = 0;
double sellSL = 0;
double sellTP = 0;
int sellTicket = 0;
bool buySweepDetected = false;
double buySweepLow = 0;
double buyOrderBlockHigh = 0;
bool buyConfirmed = false;
double buyNewHigh = 0;
bool buySetupActive = false;
double buyEntry = 0;
double buySL = 0;
double buyTP = 0;
int buyTicket = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime last = 0;
   datetime now = Time[0];
   if(now != last)
     {
      last = now;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FindLastSwingHigh(int start, int depth)
  {
   for(int i = start; i < start + 100; i++)
     {
      if(i >= Bars)
         break;
      bool isHigh = true;
      for(int j = 1; j <= depth; j++)
        {
         if(i - j >= 0 && High[i] <= High[i - j])
            isHigh = false;
         if(i + j < Bars && High[i] <= High[i + j])
            isHigh = false;
        }
      if(isHigh)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FindLastSwingLow(int start, int depth)
  {
   for(int i = start; i < start + 100; i++)
     {
      if(i >= Bars)
         break;
      bool isLow = true;
      for(int j = 1; j <= depth; j++)
        {
         if(i - j >= 0 && Low[i] >= Low[i - j])
            isLow = false;
         if(i + j < Bars && Low[i] >= Low[i + j])
            isLow = false;
        }
      if(isLow)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasOpenPosition(int dir)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderMagicNumber() != Magic)
         continue;
      if(OrderSymbol() != Symbol())
         continue;
      int type = OrderType();
      if(type != OP_BUY && type != OP_SELL)
         continue;
      if(dir == 0)
         return true;
      if(dir == 1 && type == OP_BUY)
         return true;
      if(dir == 2 && type == OP_SELL)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasPendingOrder(int dir)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderMagicNumber() != Magic)
         continue;
      if(OrderSymbol() != Symbol())
         continue;
      int type = OrderType();
      if(type != OP_BUYLIMIT && type != OP_SELLLIMIT)
         continue;
      if(dir == 0)
         return true;
      if(dir == 1 && type == OP_BUYLIMIT)
         return true;
      if(dir == 2 && type == OP_SELLLIMIT)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetSellState()
  {
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetBuyState()
  {
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!IsNewBar())
      return;
   int totalBars = Bars;
   if(totalBars <= SwingDepth + 2)
      return;
   bool sellPos = HasOpenPosition(2);
   bool buyPos = HasOpenPosition(1);
   bool sellPending = HasPendingOrder(2);
   bool buyPending = HasPendingOrder(1);
   if(!sellPos && !sellPending && sellSetupActive)
      ResetSellState();
   if(!buyPos && !buyPending && buySetupActive)
      ResetBuyState();
   bool canSell = (!sellPos && !sellPending);
   bool canBuy = (!buyPos && !buyPending);
   if(canSell)
     {
      int swing_high_bar = FindLastSwingHigh(2, SwingDepth);
      if(swing_high_bar != -1 && swing_high_bar < totalBars)
        {
         double swing_high = High[swing_high_bar];
         if(!sellSweepDetected && High[1] > swing_high && Close[1] < swing_high)
           {
            sellSweepDetected = true;
            sellSweepHigh = High[1];
            int sell_ob_end = swing_high_bar;
            int sell_ob_start = sell_ob_end;
            while(sell_ob_start > 0 && Close[sell_ob_start] < Open[sell_ob_start])
               sell_ob_start--;
            sell_ob_start++;
            if(sell_ob_start <= sell_ob_end && sell_ob_end < totalBars)
              {
               double obLow = Low[sell_ob_start];
               for(int sell_idx = sell_ob_start; sell_idx <= sell_ob_end; sell_idx++)
                  obLow = MathMin(obLow, Low[sell_idx]);
               sellOrderBlockLow = obLow;
              }
            else
              {
               sellSweepDetected = false;
               sellOrderBlockLow = 0.0;
              }
           }
         if(sellSweepDetected && sellOrderBlockLow > 0.0 && !sellConfirmed && Close[1] < sellOrderBlockLow)
           {
            sellConfirmed = true;
           }
         if(sellConfirmed && !sellSetupActive)
           {
            int new_low_bar = FindLastSwingLow(1, SwingDepth);
            if(new_low_bar != -1 && new_low_bar < totalBars)
              {
               sellNewLow = Low[new_low_bar];
               double sell_fib_high = sellSweepHigh;
               double sell_fib_low = sellNewLow;
               sellEntry = sell_fib_low + FibLevel * (sell_fib_high - sell_fib_low);
               sellSL = sell_fib_high + Point * 10;
               double sell_risk = sellSL - sellEntry;
               if(sell_risk <= 0)
                 {
                  ResetSellState();
                 }
               else
                 {
                  sellTP = sellEntry - RiskReward * sell_risk;
                  double currentAsk = Ask;
                  double sell_minDist = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
                  sellEntry = NormalizeDouble(sellEntry, Digits);
                  sellSL = NormalizeDouble(sellSL, Digits);
                  sellTP = NormalizeDouble(sellTP, Digits);
                  if(sellEntry >= currentAsk + sell_minDist)
                    {
                     int sell_ticket = OrderSend(Symbol(), OP_SELLLIMIT, LotSize, sellEntry, Slippage, sellSL, sellTP, "ICT Sell", Magic, 0, clrRed);
                     if(sell_ticket > 0)
                       {
                        sellSetupActive = true;
                        sellTicket = sell_ticket;
                       }
                    }
                  else
                    {
                     ResetSellState();
                    }
                 }
              }
           }
        }
     }
   if(canBuy)
     {
      int swing_low_bar = FindLastSwingLow(2, SwingDepth);
      if(swing_low_bar != -1 && swing_low_bar < totalBars)
        {
         double swing_low = Low[swing_low_bar];
         if(!buySweepDetected && Low[1] < swing_low && Close[1] > swing_low)
           {
            buySweepDetected = true;
            buySweepLow = Low[1];
            int buy_ob_end = swing_low_bar;
            int buy_ob_start = buy_ob_end;
            while(buy_ob_start > 0 && Close[buy_ob_start] > Open[buy_ob_start])
               buy_ob_start--;
            buy_ob_start++;
            if(buy_ob_start <= buy_ob_end && buy_ob_end < totalBars)
              {
               double obHigh = High[buy_ob_start];
               for(int buy_idx = buy_ob_start; buy_idx <= buy_ob_end; buy_idx++)
                  obHigh = MathMax(obHigh, High[buy_idx]);
               buyOrderBlockHigh = obHigh;
              }
            else
              {
               buySweepDetected = false;
               buyOrderBlockHigh = 0.0;
              }
           }
         if(buySweepDetected && buyOrderBlockHigh > 0.0 && !buyConfirmed && Close[1] > buyOrderBlockHigh)
           {
            buyConfirmed = true;
           }
         if(buyConfirmed && !buySetupActive)
           {
            int new_high_bar = FindLastSwingHigh(1, SwingDepth);
            if(new_high_bar != -1 && new_high_bar < totalBars)
              {
               buyNewHigh = High[new_high_bar];
               double buy_fib_low = buySweepLow;
               double buy_fib_high = buyNewHigh;
               buyEntry = buy_fib_high - FibLevel * (buy_fib_high - buy_fib_low);
               buySL = buy_fib_low - Point * 10;
               double buy_risk = buyEntry - buySL;
               if(buy_risk <= 0)
                 {
                  ResetBuyState();
                 }
               else
                 {
                  buyTP = buyEntry + RiskReward * buy_risk;
                  double currentBid = Bid;
                  double buy_minDist = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
                  buyEntry = NormalizeDouble(buyEntry, Digits);
                  buySL = NormalizeDouble(buySL, Digits);
                  buyTP = NormalizeDouble(buyTP, Digits);
                  if(buyEntry <= currentBid - buy_minDist)
                    {
                     int buy_ticket = OrderSend(Symbol(), OP_BUYLIMIT, LotSize, buyEntry, Slippage, buySL, buyTP, "ICT Buy", Magic, 0, clrGreen);
                     if(buy_ticket > 0)
                       {
                        buySetupActive = true;
                        buyTicket = buy_ticket;
                       }
                    }
                  else
                    {
                     ResetBuyState();
                    }
                 }
              }
           }
        }
     }
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        ICT_Scalping_Strategy
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=161257#p161257
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
