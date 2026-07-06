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

#include <Trade/Trade.mqh>
#include <Indicators/Trend.mqh>
CTrade trade;

MqlTick tick;
double Ask, Bid;

input string ____INITIAL_POSITION____ = "=== Initial Position Settings ===";
input bool   EnableAutoOpen = true;                    // Enable automatic initial position
input int    InitialDirection = 0;                     // Initial Direction (0=Auto, 1=Buy, -1=Sell)
input double InitialLotSize = 0.01;                    // Initial lot size

input string ____GRID_SETTINGS____ = "=== Grid Settings ===";
input int    GridDistance = 20;                        // Grid distance
input bool   UsePipMode = true;                        // True=Pips, False=Points
input double LotMultiplier = 2.0;                      // Lot multiplier for grid positions
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Grid EA v1.10 initialized");
   trade.SetExpertMagicNumber(MagicNumber);
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
double GetPipSize()
  {
   double pipSize = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
   if(UsePipMode)
     {
      int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
      if(digits == 4 || digits == 2)
         pipSize = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
      else
         if(digits == 5 || digits == 3)
            pipSize = SymbolInfoDouble(Symbol(), SYMBOL_POINT) * 10;
     }
   return pipSize;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ObjectCreate(0,"",OBJ_RECTANGLE,0,)
void OnTick()
  {
   SymbolInfoTick(Symbol(), tick);
   Ask = tick.ask;
   Bid = tick.bid;
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
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) != MagicNumber)
           {
            InitialPrice = PositionGetDouble(POSITION_PRICE_OPEN);
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
      double ma = (Ask + Bid) / 2; // Simple average instead of iMA
      double close = iClose(Symbol(), PERIOD_CURRENT, 0);
      direction = (close > ma) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
     }
   else
      if(direction == 1)
        {
         direction = POSITION_TYPE_BUY;
        }
      else
         if(direction == -1)
           {
            direction = POSITION_TYPE_SELL;
           }
   double sl = 0, tp = 0;
   if(EnableStopLoss)
     {
      sl = (direction == POSITION_TYPE_BUY) ?
           Ask - StopLossDistance * GetPipSize() :
           Bid + StopLossDistance * GetPipSize();
     }
   if(EnableTakeProfit)
     {
      tp = (direction == POSITION_TYPE_BUY) ?
           Ask + TakeProfitDistance * GetPipSize() :
           Bid - TakeProfitDistance * GetPipSize();
     }
   if(direction == POSITION_TYPE_BUY)
     {
      if(trade.Buy(InitialLotSize, Symbol(), 0, sl, tp, CommentPrefix + "Initial"))
        {
         Print("Initial position opened: BUY at ", trade.ResultPrice(), " with lot size ", InitialLotSize);
        }
      else
        {
         Print("Failed to open initial position. Error: ", trade.ResultRetcode());
        }
     }
   else
     {
      if(trade.Sell(InitialLotSize, Symbol(), 0, sl, tp, CommentPrefix + "Initial"))
        {
         Print("Initial position opened: SELL at ", trade.ResultPrice(), " with lot size ", InitialLotSize);
        }
      else
        {
         Print("Failed to open initial position. Error: ", trade.ResultRetcode());
        }
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
            OpenGridPosition(POSITION_TYPE_BUY, GridBuyLevels + 1);
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
            OpenGridPosition(POSITION_TYPE_SELL, GridSellLevels + 1);
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
   double minLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   lotSize = MathMax(minLot, MathMin(maxLot, NormalizeDouble(lotSize / lotStep, 0) * lotStep));
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double positionValue = lotSize * SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
   double riskPercent = (positionValue / accountBalance) * 100;
   if(riskPercent > MaxRiskPercent)
     {
      Print("Risk too high for grid level ", level, ": ", riskPercent, "%");
      return;
     }
   double sl = 0, tp = 0;
   if(EnableStopLoss)
     {
      sl = (orderType == POSITION_TYPE_BUY) ?
           Bid - StopLossDistance * GetPipSize() :
           Ask + StopLossDistance * GetPipSize();
     }
   if(EnableTakeProfit)
     {
      tp = (orderType == POSITION_TYPE_BUY) ?
           Bid + TakeProfitDistance * GetPipSize() :
           Ask - TakeProfitDistance * GetPipSize();
     }
   string comment = CommentPrefix + "Grid_" + IntegerToString(level);
   if(orderType == POSITION_TYPE_BUY)
     {
      if(trade.Buy(lotSize, Symbol(), 0, sl, tp, comment))
        {
         Print("Grid position opened: BUY Level ", level, " at ", trade.ResultPrice(), " with lot size ", lotSize);
        }
      else
        {
         Print("Failed to open grid position. Error: ", trade.ResultRetcode());
        }
     }
   else
     {
      if(trade.Sell(lotSize, Symbol(), 0, sl, tp, comment))
        {
         Print("Grid position opened: SELL Level ", level, " at ", trade.ResultPrice(), " with lot size ", lotSize);
        }
      else
        {
         Print("Failed to open grid position. Error: ", trade.ResultRetcode());
        }
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
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == Symbol())
           {
            totalProfit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            double pips = 0;
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
               pips = (Bid - PositionGetDouble(POSITION_PRICE_OPEN)) / GetPipSize();
            else
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                  pips = (PositionGetDouble(POSITION_PRICE_OPEN) - Ask) / GetPipSize();
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
   double profitPercent = (totalProfit / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
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
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == Symbol())
           {
            ulong ticket2 = PositionGetInteger(POSITION_TICKET);
            if(trade.PositionClose(ticket2))
              {
               string orderType = (PositionGetInteger(POSITION_MAGIC) == MagicNumber) ? "EA" : "Manual";
               Print("Closed ", orderType, " position ", ticket2, " with profit: ",
                     DoubleToString(PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP), 2));
              }
            else
              {
               Print("Failed to close position ", ticket2, ". Error: ", trade.ResultRetcode());
              }
           }
        }
     }
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
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == Symbol())
           {
            totalProfit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            totalPositions++;
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber)
               eaPositions++;
            else
               manualPositions++;
           }
        }
     }
   string info = "GridEA v1.10 | Status: " + (GridInitialized ? "Active" : "Waiting") +
                 " | InitPrice: " + DoubleToString(InitialPrice, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS)) +
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