/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76299
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
// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

#property strict

// Input Parameters
input double qnt_grid = 5;                    // Number of grid levels
input double grid_gap = 100;                  // Distance between grid levels in points
input double grid_m = 0.1;                    // Multiplier for grid Lots
input double LotSize = 0.1;                   // Default Lot Size
input double Magic = 1111;                    // Magic Number
input double Slippage = 100;                  // Slippage

input bool UseTP = true;                      // Use Take Profit
input bool UseSL = true;                      // Use Stop Loss
input double TP_Amount = 200.0;               // Take Profit Amount (Points)
input double SL_Amount = 100.0;               // Stop Loss Amount (Points)

input bool CloseGridInProfit = true;          // Close Grid in Profit
input double CloseGridTP = 200.0;             // Close by $ Profit
input bool CloseGridInLoss = true;            // Close Grid in Loss
input double CloseGridSL = 100.0;             // Close by $ Loss

input double MaxSpread = 5000;                // Maximum Spread (points)
input int StartHour = 0;                      // Start Hour
input int EndHour = 23;                       // End Hour
// Global Variables
double lastBuyPrice = 0;
double lastSellPrice = 0;
bool gridActive = false;
int initialOrderCount = 0;

int OnInit() { return (INIT_SUCCEEDED); }
void OnDeinit(const int reason) {}
void OnTick()
{
    // Debug
    /*
    if (CountOrdersOnSymbol() == 0) {
        static int lastAttemptTime = 0;
        if (TimeCurrent() - lastAttemptTime > 5) {
            double lot = LotSize;
            double sl = 0, tp = 0;
            double price = Ask;
            Print("Attempting to create initial order - Ask: ", DoubleToStr(price, Digits), " Lot: ", lot);
            int ticket = OrderSend(Symbol(), OP_BUY, lot, price, (int)Slippage, sl, tp, "Initial Order", (int)Magic, 0, clrBlue);
            if (ticket > 0) {
                Print("Initial order created: Ticket #", ticket, " at price: ", DoubleToStr(price, Digits));
                lastBuyPrice = price;
                lastSellPrice = 0;
                gridActive = true;
                initialOrderCount = 1;
                Print("Grid activated! LastBuyPrice: ", DoubleToStr(lastBuyPrice, Digits));
            } else {
                Print("Initial order failed: ", GetLastError(), " Ask: ", DoubleToStr(price, Digits));
            }
            lastAttemptTime = (int)TimeCurrent();
        }
        return;
    }
    */
    
    if (!IsTimeAllowed()) {
        static int lastTimeWarning = 0;
        if (TimeCurrent() - lastTimeWarning > 30) {
            Print("Trading time not allowed. Current hour: ", Hour(), " Start: ", StartHour, " End: ", EndHour);
            lastTimeWarning = (int)TimeCurrent();
        }
        return;
    }
    
    if (!IsSpreadOK()) {
        static int lastSpreadWarning = 0;
        if (TimeCurrent() - lastSpreadWarning > 30) {
            double currentSpread = (Ask - Bid) / Point;
            Print("Spread too high: ", DoubleToStr(currentSpread, 1), " Max allowed: ", DoubleToStr(MaxSpread, 1));
            lastSpreadWarning = (int)TimeCurrent();
        }
        return;
    }
    
    int currentOrders = CountOrdersOnSymbol();
    
    if (currentOrders == 0) {
        gridActive = false;
        lastBuyPrice = 0;
        lastSellPrice = 0;
        initialOrderCount = 0;
        return;
    }
    
    // Activate grid if first time seeing orders
    if (!gridActive && currentOrders > 0) {
        gridActive = true;
        initialOrderCount = currentOrders;
        SetInitialPrices();
        Print("Grid activated! Initial orders: ", initialOrderCount, " LastBuyPrice: ", lastBuyPrice, " LastSellPrice: ", lastSellPrice);
    }
    
    CheckGridCloseConditions();
    CheckGridEntries();
}

void OnTimer(void) {}

int CountOrdersOnSymbol()
{
    int count = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderSymbol() == Symbol() && 
            OrderMagicNumber() == (int)Magic) {
            count++;
        }
    }
    return count;
}

void SetInitialPrices()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderSymbol() == Symbol() && 
            OrderMagicNumber() == (int)Magic) {
            if (OrderType() == OP_BUY) {
                if (lastBuyPrice == 0 || OrderOpenPrice() > lastBuyPrice) {
                    lastBuyPrice = OrderOpenPrice();
                }
            }
            else if (OrderType() == OP_SELL) {
                if (lastSellPrice == 0 || OrderOpenPrice() < lastSellPrice) {
                    lastSellPrice = OrderOpenPrice();
                }
            }
        }
    }
}
void CheckGridEntries()
{
    if (!gridActive) return;
    
    double gap = grid_gap * Point;
    
    if (lastBuyPrice > 0) {
        static int lastDebugTime = 0;
        if (TimeCurrent() - lastDebugTime > 5) {
            double priceDiff = (lastBuyPrice - Ask) / Point;
            Print("Grid Check - Ask: ", DoubleToStr(Ask, Digits), " LastBuyPrice: ", DoubleToStr(lastBuyPrice, Digits), 
                  " Price diff: ", DoubleToStr(priceDiff, 1), " Gap needed: ", DoubleToStr(gap/Point, 1), " points");
            lastDebugTime = (int)TimeCurrent();
        }
    }
    
    // Grid BUY entries (when price goes down)
    if (lastBuyPrice > 0 && Ask <= lastBuyPrice - gap) {
        double lot = LotSize * (1 + (CountOrdersOnSymbol() - initialOrderCount) * grid_m);
        double sl = 0, tp = 0;
        
        if (UseSL) sl = CalculateSL(OP_BUY, Ask);
        if (UseTP) tp = CalculateTP(OP_BUY, Ask);
        
        int ticket = OrderSend(Symbol(), OP_BUY, lot, Ask, (int)Slippage, sl, tp, "Grid Buy", (int)Magic, 0, clrBlue);
        if (ticket < 0) Print("Grid Buy Order failed: ", GetLastError());
        else {
            lastBuyPrice = Ask;
            Print("Grid Buy opened at: ", DoubleToStr(Ask, Digits), " Gap: ", DoubleToStr(gap/Point, 1), " points");
        }
    }
    
    // Grid SELL entries (when price goes up)
    if (lastSellPrice > 0 && Bid >= lastSellPrice + gap) {
        double lot = LotSize * (1 + (CountOrdersOnSymbol() - initialOrderCount) * grid_m);
        double sl = 0, tp = 0;
        
        if (UseSL) sl = CalculateSL(OP_SELL, Bid);
        if (UseTP) tp = CalculateTP(OP_SELL, Bid);
        
        int ticket = OrderSend(Symbol(), OP_SELL, lot, Bid, (int)Slippage, sl, tp, "Grid Sell", (int)Magic, 0, clrRed);
        if (ticket < 0) Print("Grid Sell Order failed: ", GetLastError());
        else {
            lastSellPrice = Bid;
            Print("Grid Sell opened at: ", DoubleToStr(Bid, Digits), " Gap: ", DoubleToStr(gap/Point, 1), " points");
        }
    }
    // First SELL grid when price goes up from BUY orders
    else if (lastSellPrice == 0 && lastBuyPrice > 0 && Bid >= lastBuyPrice + gap) {
        double lot = LotSize * (1 + (CountOrdersOnSymbol() - initialOrderCount) * grid_m);
        double sl = 0, tp = 0;
        
        if (UseSL) sl = CalculateSL(OP_SELL, Bid);
        if (UseTP) tp = CalculateTP(OP_SELL, Bid);
        
        int ticket = OrderSend(Symbol(), OP_SELL, lot, Bid, (int)Slippage, sl, tp, "Grid Sell", (int)Magic, 0, clrRed);
        if (ticket < 0) Print("Grid Sell Order failed: ", GetLastError());
        else {
            lastSellPrice = Bid;
            Print("First Grid Sell opened at: ", DoubleToStr(Bid, Digits), " Gap: ", DoubleToStr(gap/Point, 1), " points");
        }
    }
}

double CalculateSL(int orderType, double price)
{
    if (SL_Amount <= 0) return 0;
    
    double slDistance = SL_Amount * Point;
    
    if (orderType == OP_BUY) {
        return price - slDistance;
    } else {
        return price + slDistance;
    }
}

double CalculateTP(int orderType, double price)
{
    if (TP_Amount <= 0) return 0;
    
    double tpDistance = TP_Amount * Point;
    
    if (orderType == OP_BUY) {
        return price + tpDistance;
    } else {
        return price - tpDistance;
    }
}

void CheckGridCloseConditions()
{
    double totalProfit = GetTotalProfit();
    
    if (CloseGridInProfit && totalProfit >= CloseGridTP) {
        Print("Grid closed by profit: $", DoubleToStr(totalProfit, 2), " >= $", DoubleToStr(CloseGridTP, 2));
        CloseAllOrders();
        return;
    }
    
    if (CloseGridInLoss && totalProfit <= -CloseGridSL) {
        Print("Grid closed by loss: $", DoubleToStr(totalProfit, 2), " <= -$", DoubleToStr(CloseGridSL, 2));
        CloseAllOrders();
        return;
    }
}

double GetTotalProfit()
{
    double totalProfit = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderSymbol() == Symbol() && 
            OrderMagicNumber() == (int)Magic) {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
        }
    }
    return totalProfit;
}

void CloseAllOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderSymbol() == Symbol() && 
            OrderMagicNumber() == (int)Magic) {
            if (OrderType() == OP_BUY) {
                bool result = OrderClose(OrderTicket(), OrderLots(), Bid, (int)Slippage, clrRed);
                if (!result) Print("Close Buy Order failed: ", GetLastError());
            }
            else if (OrderType() == OP_SELL) {
                bool result = OrderClose(OrderTicket(), OrderLots(), Ask, (int)Slippage, clrRed);
                if (!result) Print("Close Sell Order failed: ", GetLastError());
            }
        }
    }
}

bool IsTimeAllowed()
{
    int currentHour = Hour();
    
    if (StartHour <= EndHour) {
        return (currentHour >= StartHour && currentHour <= EndHour);
    } else {
        return (currentHour >= StartHour || currentHour <= EndHour);
    }
}

bool IsSpreadOK()
{
    double spread = (Ask - Bid) / Point;
    return (spread <= MaxSpread);
}

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160315#p160315
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
