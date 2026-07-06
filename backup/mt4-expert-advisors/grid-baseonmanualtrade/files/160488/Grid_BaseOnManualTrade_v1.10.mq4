// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160372#p160372
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
#property strict

input string ____INITIAL_POSITION____ = "=== Initial Position Settings ===";
input bool   EnableAutoOpen = true;                    // Enable automatic initial position
input int    InitialDirection = 0;                     // Initial Direction (0=Auto, 1=Buy, -1=Sell)
input double InitialLotSize = 0.01;                    // Initial lot size

input string ____GRID_SETTINGS____ = "=== Grid Settings ===";
input int    GridDistance = 20;                        // Grid distance
input bool   UsePipMode = true;                        // True=Pips, False=Points
input double LotMultiplier = 1.5;                      // Lot multiplier for grid positions
input int    MaxGridLevels = 10;                       // Maximum grid levels
input int    SpreadFilter = 5;                         // Maximum spread to open positions (pips)

input string ____CLOSE_SETTINGS____ = "=== Close Settings ===";
input bool   EnableCloseAll = true;                    // Enable close all functionality
input bool   CloseByMoney = false;                     // Close by profit/loss amount
input double TargetProfit = 100.0;                     // Target profit amount
input double TargetLoss = -50.0;                       // Target loss amount (negative)
input bool   CloseByPercent = false;                   // Close by account percent
input double TargetProfitPercent = 5.0;                // Target profit percent
input double TargetLossPercent = -2.5;                 // Target loss percent (negative)
input bool   CloseByPips = true;                       // Close by total pips
input double TargetProfitPips = 50.0;                  // Target profit in pips
input double TargetLossPips = -25.0;                   // Target loss in pips (negative)

input string ____RISK_SETTINGS____ = "=== Risk Management ===";
input bool   EnableStopLoss = false;                   // Enable stop loss
input double StopLossDistance = 100.0;                 // Stop loss distance in pips
input bool   EnableTakeProfit = false;                 // Enable take profit
input double TakeProfitDistance = 50.0;                // Take profit distance in pips
input double MaxRiskPercent = 10.0;                    // Maximum risk percent of account

input string ____OTHER_SETTINGS____ = "=== Other Settings ===";
input int    MagicNumber = 123456;                     // Magic number
input string CommentPrefix = "GridEA_";                // Comment prefix
input bool   ShowInfo = true;                          // Show information panel

double InitialPrice = 0.0;
int    GridBuyLevels = 0;
int    GridSellLevels = 0;
bool   GridInitialized = false;
double CurrentSpread = 0.0;
datetime LastBarTime = 0;
int OnInit()
  {
   Print("Grid EA v1.10 initialized");
   if(!ValidateInputs())
      return INIT_PARAMETERS_INCORRECT;
   if(EnableAutoOpen)
     {
      InitializeGrid();
     }
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("Grid EA deinitialized. Reason: ", reason);
   Comment("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   CurrentSpread = (Ask - Bid) / GetPipSize();
   if(CurrentSpread > SpreadFilter)
     {
      Print("Spread too high: ", CurrentSpread, " > ", SpreadFilter);
      return;
     }
   if(!GridInitialized)
     {
      CheckForManualTrade();
     }
   if(GridInitialized)
     {
      ManageGrid();
      CheckCloseConditions();
     }
   UpdateInfoPanel();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidateInputs()
  {
   if(InitialLotSize <= 0)
     {
      Print("Error: Initial lot size must be greater than 0");
      return false;
     }
   if(GridDistance <= 0)
     {
      Print("Error: Grid distance must be greater than 0");
      return false;
     }
   if(LotMultiplier <= 0)
     {
      Print("Error: Lot multiplier must be greater than 0");
      return false;
     }
   if(MaxGridLevels <= 0)
     {
      Print("Error: Maximum grid levels must be greater than 0");
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitializeGrid()
  {
   if(GridInitialized)
      return;
   InitialPrice = (Ask + Bid) / 2;
   if(EnableAutoOpen)
     {
      OpenInitialPosition();
     }
   GridInitialized = true;
   GridBuyLevels = 0;
   GridSellLevels = 0;
   Print("Grid initialized at price: ", InitialPrice);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForManualTrade()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() != MagicNumber)
           {
            InitialPrice = OrderOpenPrice();
            GridInitialized = true;
            GridBuyLevels = 0;
            GridSellLevels = 0;
            Print("Grid initialized based on manual trade at: ", InitialPrice);
            break;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenInitialPosition()
  {
   int direction = InitialDirection;
   if(direction == 0)
     {
      double ma = iMA(Symbol(), PERIOD_H1, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
      direction = (Close[0] > ma) ? OP_BUY : OP_SELL;
     }
   else
      if(direction == 1)
        {
         direction = OP_BUY;
        }
      else
         if(direction == -1)
           {
            direction = OP_SELL;
           }
   double price = (direction == OP_BUY) ? Ask : Bid;
   double sl = 0, tp = 0;
   if(EnableStopLoss)
     {
      sl = (direction == OP_BUY) ?
           price - StopLossDistance * GetPipSize() :
           price + StopLossDistance * GetPipSize();
     }
   if(EnableTakeProfit)
     {
      tp = (direction == OP_BUY) ?
           price + TakeProfitDistance * GetPipSize() :
           price - TakeProfitDistance * GetPipSize();
     }
   int ticket = OrderSend(Symbol(), direction, InitialLotSize, price, 3, sl, tp,
                          CommentPrefix + "Initial", MagicNumber, 0,
                          (direction == OP_BUY) ? clrBlue : clrRed);
   if(ticket > 0)
     {
      Print("Initial position opened: ", (direction == OP_BUY) ? "BUY" : "SELL",
            " at ", price, " with lot size ", InitialLotSize);
     }
   else
     {
      Print("Failed to open initial position. Error: ", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageGrid()
  {
   if(!GridInitialized)
      return;
   double currentPrice = (Ask + Bid) / 2;
   double gridSize = GridDistance * GetPipSize();
   if(currentPrice > InitialPrice)
     {
      double buyLevel = InitialPrice + (GridBuyLevels + 1) * gridSize;
      if(currentPrice >= buyLevel && GridBuyLevels < MaxGridLevels)
        {
         if(CurrentSpread <= SpreadFilter)
           {
            OpenGridPosition(OP_BUY, GridBuyLevels + 1);
            GridBuyLevels++;
           }
        }
     }
   if(currentPrice < InitialPrice)
     {
      double sellLevel = InitialPrice - (GridSellLevels + 1) * gridSize;
      if(currentPrice <= sellLevel && GridSellLevels < MaxGridLevels)
        {
         if(CurrentSpread <= SpreadFilter)
           {
            OpenGridPosition(OP_SELL, GridSellLevels + 1);
            GridSellLevels++;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenGridPosition(int orderType, int level)
  {
   double lotSize = InitialLotSize;
   if(level > 1)
     {
      lotSize = InitialLotSize * MathPow(LotMultiplier, level - 1);
     }
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   lotSize = MathMax(minLot, MathMin(maxLot, NormalizeDouble(lotSize / lotStep, 0) * lotStep));
   double accountBalance = AccountBalance();
   double positionValue = lotSize * MarketInfo(Symbol(), MODE_TICKVALUE) *
                          MarketInfo(Symbol(), MODE_TICKSIZE) * 10000;
   double riskPercent = (positionValue / accountBalance) * 100;
   if(riskPercent > MaxRiskPercent)
     {
      Print("Risk too high for grid level ", level, ": ", riskPercent, "%");
      return;
     }
   double price = (orderType == OP_BUY) ? Ask : Bid;
   double sl = 0, tp = 0;
   if(EnableStopLoss)
     {
      sl = (orderType == OP_BUY) ?
           price - StopLossDistance * GetPipSize() :
           price + StopLossDistance * GetPipSize();
     }
   if(EnableTakeProfit)
     {
      tp = (orderType == OP_BUY) ?
           price + TakeProfitDistance * GetPipSize() :
           price - TakeProfitDistance * GetPipSize();
     }
   string comment = CommentPrefix + "Grid_" + IntegerToString(level);
   int ticket = OrderSend(Symbol(), orderType, lotSize, price, 3, sl, tp,
                          comment, MagicNumber, 0,
                          (orderType == OP_BUY) ? clrBlue : clrRed);
   if(ticket > 0)
     {
      Print("Grid position opened: ", (orderType == OP_BUY) ? "BUY" : "SELL",
            " Level ", level, " at ", price, " with lot size ", lotSize);
     }
   else
     {
      Print("Failed to open grid position. Error: ", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckCloseConditions()
  {
   if(!EnableCloseAll)
      return;
   double totalProfit = 0;
   double totalPips = 0;
   int totalPositions = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
            double pips = 0;
            if(OrderType() == OP_BUY)
               pips = (Bid - OrderOpenPrice()) / GetPipSize();
            else
               if(OrderType() == OP_SELL)
                  pips = (OrderOpenPrice() - Ask) / GetPipSize();
            totalPips += pips;
            totalPositions++;
           }
        }
     }
   if(totalPositions == 0)
      return;
   bool shouldClose = false;
   string closeReason = "";
   if(CloseByMoney && (totalProfit >= TargetProfit || totalProfit <= TargetLoss))
     {
      shouldClose = true;
      closeReason = (totalProfit >= TargetProfit) ? "Profit target reached: " + DoubleToString(totalProfit, 2) :
                    "Loss limit reached: " + DoubleToString(totalProfit, 2);
     }
   double profitPercent = (totalProfit / AccountBalance()) * 100;
   if(CloseByPercent && (profitPercent >= TargetProfitPercent || profitPercent <= TargetLossPercent))
     {
      shouldClose = true;
      closeReason = (profitPercent >= TargetProfitPercent) ? "Profit percent reached: " + DoubleToString(profitPercent, 2) + "%" :
                    "Loss percent reached: " + DoubleToString(profitPercent, 2) + "%";
     }
   if(CloseByPips && (totalPips >= TargetProfitPips || totalPips <= TargetLossPips))
     {
      shouldClose = true;
      closeReason = (totalPips >= TargetProfitPips) ? "Profit pips reached: " + DoubleToString(totalPips, 1) + " pips" :
                    "Loss pips reached: " + DoubleToString(totalPips, 1) + " pips";
     }
   if(shouldClose)
     {
      CloseAllPositions();
      Print("All positions closed. Reason: ", closeReason);
      GridInitialized = false;
      GridBuyLevels = 0;
      GridSellLevels = 0;
      InitialPrice = 0;
      if(EnableAutoOpen)
        {
         InitializeGrid();
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            double closePrice = (OrderType() == OP_BUY) ? Bid : Ask;
            bool closed = OrderClose(OrderTicket(), OrderLots(), closePrice, 3, clrYellow);
            if(!closed)
              {
               Print("Failed to close order ", OrderTicket(), ". Error: ", GetLastError());
              }
            else
              {
               string orderType = (OrderMagicNumber() == MagicNumber) ? "EA" : "Manual";
               Print("Closed ", orderType, " order ", OrderTicket(), " with profit: ",
                     DoubleToString(OrderProfit() + OrderSwap() + OrderCommission(), 2));
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPipSize()
  {
   double pipSize = Point;
   if(UsePipMode)
     {
      if(Digits == 4 || Digits == 2)
         pipSize = Point;
      else
         if(Digits == 5 || Digits == 3)
            pipSize = Point * 10;
     }
   return pipSize;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateInfoPanel()
  {
   if(!ShowInfo)
      return;
   double totalProfit = 0;
   int totalPositions = 0;
   int eaPositions = 0;
   int manualPositions = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
            totalPositions++;
            if(OrderMagicNumber() == MagicNumber)
               eaPositions++;
            else
               manualPositions++;
           }
        }
     }
   string info = "GridEA v1.10 | Status: " + (GridInitialized ? "Active" : "Waiting") +
                 " | InitPrice: " + DoubleToString(InitialPrice, Digits) +
                 " | Spread: " + DoubleToString(CurrentSpread, 1) + "p" +
                 " | BuyLvl: " + IntegerToString(GridBuyLevels) +
                 " | SellLvl: " + IntegerToString(GridSellLevels) +
                 " | Total: " + IntegerToString(totalPositions) +
                 " | EA: " + IntegerToString(eaPositions) +
                 " | Manual: " + IntegerToString(manualPositions) +
                 " | Profit: " + DoubleToString(totalProfit, 2);
   Comment(info);
  }
//+------------------------------------------------------------------+
// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160372#p160372
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