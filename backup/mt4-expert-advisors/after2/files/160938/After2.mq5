// -- Project -------------------------------------------------------------------------------
/*
Name:        After2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76382
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
#property version   "1.00"
#property strict
#include <Trade/Trade.mqh>
CTrade trade;
enum OPBySignal
  {
   ON = 0,
   OFF = 1,
  };
enum PorcentSignal
  {
   Balances = 0, // Por Balance
   Equidades = 1, // Por Equidad
  };
input    double         LOTS               = 0.01;                  // Lot fijo.
input    double         risk               = 0.00;                  //risk: 0-->Lot fijo
input    double         SL_Pip             = 500;                    // Stoploss
input    double         TP_Pip             = 1000;                   // Take Profit
input    bool           UsePorcentLoss     = false;                  // Usar Porcentaje de Perdida?
input    PorcentSignal  Porcent_BySignal   = Equidades;              // Tipo de Calculo
input    double         PorcentLoss        = 5.0;                    // Porcentaje de Perdidas permitidas
input    bool           UseTralling_Stop   = true;                   // Usar Tralling
input    double         TrallingStart      = 100;                    // Tralling Star
input    string         Ordercomment       = "";                     // Comentario
input    int            MagicID            = 24523;                  // Numero Magico
input group "========== MARTINGALE SETTINGS =========="
input    bool           UseMartingale      = false;                  // Enable Martingale
input    double         MartingaleMultiplier = 2.0;                  // Lot Multiplier after loss
input    double         MaxMartingaleLot   = 1.0;                    // Maximum Lot Size
input    int            MaxMartingaleSteps = 5;                      // Maximum Martingale Steps
input    bool           ResetOnProfit      = true;                   // Reset to base lot on profit
input    double         MartingaleStartLot = 0.01;                   // Starting Lot for Martingale
OPBySignal Trade_BySignal = OFF;
int        Order_Distance = 230;
double     LotMultiply  = 1;
bool       Close_BySignal = false;
int        Max_Order = 15;
bool       TPLinier = true;
double     LockProfit    = 10;
bool       UseTimeFilter   = false;
string     Start           = "00:00";
string     End1            = "15:00";
int Slippage = 3;
int    Retries = 10;
bool   AutoTrade = true;
bool   ecnBroker = false;
union Price
  {
   uchar             buffer[8];
   double            close;
  };
double g_Point;
ulong    g_ticket = 0;
int      StopLoss  = 0;
double   SL_BEP_minus = 0;
double    Buy, lotbuy, lotsbuy, Sell, lotsell, lotssell, SUM, SWAP,
          profitbuy, profitsell, OP, dg,
          sumbuy, sumsell, bepbuy, bepsell, lowlotbuy, lowlotsell, hisell,
          lobuy;
double   g_CurrentMartingaleLot = 0.01;
int      g_MartingaleStep = 0;
bool     g_LastTradeWasLoss = false;
datetime g_LastTradeCloseTime = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_Point = _Point;
   if(_Digits == 5 || _Digits == 3)
     {
      g_Point *= 10;
      Slippage *= 10;
     }
   trade.SetExpertMagicNumber(MagicID);
   trade.SetDeviationInPoints(Slippage);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   trade.SetAsyncMode(false);
   ChartSetInteger(0, CHART_SHOW_GRID, 0);
   ChartSetInteger(0, CHART_AUTOSCROLL, 1);
   if(UseMartingale)
     {
      g_CurrentMartingaleLot = MartingaleStartLot;
      g_MartingaleStep = 0;
      Print("EA Initialized - Using H1 Close price as level (matching MT4 logic) - Martingale ENABLED");
     }
   else
     {
      Print("EA Initialized - Using H1 Close price as level (matching MT4 logic) - Martingale DISABLED");
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   CheckAndUpdateMartingale();
   static int debugCounter = 0;
   debugCounter++;
   if(UsePorcentLoss && PorcentLoss > 0)
     {
      double TotalLoss;
      double PercentageLoss;
      LossandWon(TotalLoss, PercentageLoss);
      if(PercentageLoss < PorcentLoss)
        {
         Comment("Las Perdidas del dia son de: ", TotalLoss, " $", "\n"
                 "Actualmente lleva un ", DoubleToString(PercentageLoss, 2), " %", " en perdida");
        }
      else
         if(PercentageLoss >= PorcentLoss)
           {
            Comment("El Monto de Perdidas del dia son de: ", TotalLoss, " $", "\n"
                    "Actualmente tiene un ", DoubleToString(PercentageLoss, 2), " %", " en perdida", "\n"
                    "ALERTA.... El EA se ha detenido hasta mañana");
            return;
           }
     }
   double SetPoint = g_Point;
   if(UseTralling_Stop  && TrallingStart > 0 && LockProfit < TrallingStart)
     {
      double rtb = rata_price(ORDER_TYPE_BUY);
      for(int iTrade = 0; iTrade < PositionsTotal(); iTrade++)
        {
         ulong posTicket = PositionGetTicket(iTrade);
         if(PositionSelectByTicket(posTicket))
           {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_MAGIC) == MagicID)
              {
               double tr;
               if(TPLinier)
                  tr = rtb;
               else
                  tr = PositionGetDouble(POSITION_PRICE_OPEN);
               double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               if(bid - tr > TrallingStart * SetPoint)
                 {
                  double currentSL = PositionGetDouble(POSITION_SL);
                  double newSL = bid - ((TrallingStart - LockProfit) * SetPoint);
                  if(newSL > currentSL)
                    {
                     trade.PositionModify(posTicket, newSL, PositionGetDouble(POSITION_TP));
                    }
                 }
              }
           }
        }
      double rts = rata_price(ORDER_TYPE_SELL);
      for(int iTrade2 = 0; iTrade2 < PositionsTotal(); iTrade2++)
        {
         ulong posTicket = PositionGetTicket(iTrade2);
         if(PositionSelectByTicket(posTicket))
           {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_MAGIC) == MagicID)
              {
               double tr;
               if(TPLinier)
                  tr = rts;
               else
                  tr = PositionGetDouble(POSITION_PRICE_OPEN);
               double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               if(tr - ask > TrallingStart * SetPoint)
                 {
                  double currentSL = PositionGetDouble(POSITION_SL);
                  double newSL = ask + ((TrallingStart - LockProfit) * SetPoint);
                  if(newSL < currentSL || currentSL == 0)
                    {
                     trade.PositionModify(posTicket, newSL, PositionGetDouble(POSITION_TP));
                    }
                 }
              }
           }
        }
     }
   static datetime previousBar;
   MqlRates currentRates[];
   ArraySetAsSeries(currentRates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, currentRates) <= 0)
     {
      Print("ERROR: Cannot copy current rates");
      return;
     }
   if(previousBar != currentRates[0].time)
     {
      previousBar = currentRates[0].time;
      Print("DEBUG: New bar detected at ", TimeToString(currentRates[0].time));
      ChartRedraw();
     }
   else
     {
      return;
     }
   MqlRates ratesH1[];
   ArraySetAsSeries(ratesH1, true);
   if(CopyRates(_Symbol, PERIOD_H1, 0, 2, ratesH1) < 2)
     {
      Comment("ERROR: Cannot copy H1 rates");
      Print("ERROR: Cannot copy H1 rates");
      return;
     }
   Print("DEBUG: H1[0].tick_volume = ", ratesH1[0].tick_volume, " | H1[1].tick_volume = ", ratesH1[1].tick_volume);
   if(ratesH1[0].tick_volume > ratesH1[1].tick_volume)
     {
      Print("DEBUG: Volume filter BLOCKING trade. H1[0].tick_volume (", ratesH1[0].tick_volume, ") > H1[1].tick_volume (", ratesH1[1].tick_volume, ")");
      Comment("Volume filter active - waiting...");
      return;
     }
   Print("DEBUG: Volume filter PASSED - continuing to trade logic...");
   MqlRates h1Rates[];
   ArraySetAsSeries(h1Rates, true);
   int copiedBars = CopyRates(_Symbol, PERIOD_H1, 0, 5, h1Rates);
   if(copiedBars < 5)
     {
      Comment("ERROR: Cannot copy H1 data. Copied: ", copiedBars);
      return;
     }
   int pos = 1;
   double level = h1Rates[pos].close;
   Print("DEBUG: Level = ", DoubleToString(level, 5), " | H1[", pos, "].close = ", DoubleToString(h1Rates[pos].close, 5));
   if(ObjectFind(0, "level") >= 0)
      ObjectDelete(0, "level");
   if(ObjectCreate(0, "level", OBJ_HLINE, 0, 0, level))
     {
      ObjectSetInteger(0, "level", OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, "level", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, "level", OBJPROP_WIDTH, 2);
      Print("DEBUG: Line created at level: ", DoubleToString(level, 5));
     }
   else
     {
      Print("ERROR: Cannot create line object! Error: ", GetLastError());
     }
   ChartRedraw();
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > 150)
      return;
   int TB = 0, TS = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong posTicket = PositionGetTicket(i);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
         PositionGetInteger(POSITION_MAGIC) != MagicID)
         continue;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         TB++;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         TS++;
     }
   string signal = "NEUTRAL";
   if(level > currentRates[0].open)
      signal = "BUY";
   else
      if(level < currentRates[0].open)
         signal = "SELL";
   bool buyPinbar = IsBuyPinbar();
   bool sellPinbar = IsSellPinbar();
   bool jamOPcheck = jamOP();
   string debugInfo = "=== DEBUG INFO ===\n";
   debugInfo += StringFormat("H1 Close Level: %.5f | Current Open: %.5f | Signal: %s\n",
                             level, currentRates[0].open, signal);
   debugInfo += StringFormat("Trade_BySignal: %s | TPLinier: %s | Close_BySignal: %s\n",
                             (Trade_BySignal == ON ? "ON" : "OFF"),
                             (TPLinier ? "ON" : "OFF"),
                             (Close_BySignal ? "ON" : "OFF"));
   debugInfo += StringFormat("TB: %d | TS: %d | Max: %d | CountTrades: %d\n",
                             TB, TS, Max_Order, CountTrades());
   debugInfo += StringFormat("IsBuyPinbar: %s | IsSellPinbar: %s | jamOP: %s\n",
                             (buyPinbar ? "YES" : "NO"),
                             (sellPinbar ? "YES" : "NO"),
                             (jamOPcheck ? "YES" : "NO"));
   debugInfo += StringFormat("Spread: %d | MaxSpread: 150 | pos: %d\n",
                             (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), pos);
   debugInfo += StringFormat("CheckMarketBuy: %d | CheckMarketSell: %d\n",
                             CheckMarketBuyOrders(), CheckMarketSellOrders());
   if(UseMartingale)
     {
      debugInfo += StringFormat("MARTINGALE: ON | Lot: %.2f | Step: %d/%d | MaxLot: %.2f\n",
                                g_CurrentMartingaleLot, g_MartingaleStep, MaxMartingaleSteps, MaxMartingaleLot);
     }
   else
     {
      debugInfo += "MARTINGALE: OFF\n";
     }
   Comment(debugInfo);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(pos >= 0)
     {
      if(CheckMarketBuyOrders() < 70 && CheckMarketSellOrders() < 70)
        {
         Print("DEBUG: Market orders check passed. BuyOrders: ", CheckMarketBuyOrders(), " SellOrders: ", CheckMarketSellOrders());
         if(level > currentRates[0].open &&  Trade_BySignal == OFF)
           {
            Print("DEBUG: BUY Signal detected (Trade_BySignal=OFF). Checking pinbar...");
            if(IsBuyPinbar() && TB < Max_Order && (jamOP() || TB > 0))
              {
               Print("DEBUG: All BUY conditions met! Opening BUY position...");
               double BuySL = NormalizeDouble(ask - SL_Pip * g_Point, _Digits);
               double BuyTP = NormalizeDouble(ask + TP_Pip * g_Point, _Digits);
               if(trade.Buy(GetLots(), _Symbol, ask, BuySL, BuyTP, "AfterScalper_V1.1"))
                 {
                  Print("SUCCESS: BUY position opened!");
                  CloseSell();
                 }
               else
                 {
                  Print("ERROR: Failed to open BUY position. Error: ", GetLastError());
                 }
              }
            else
              {
               Print("DEBUG: BUY conditions NOT met. IsBuyPinbar: ", IsBuyPinbar(), " TB: ", TB, " Max: ", Max_Order, " jamOP: ", jamOP());
              }
           }
         if(level < currentRates[0].open  &&  Trade_BySignal == OFF)
           {
            Print("DEBUG: SELL Signal detected (Trade_BySignal=OFF). Checking pinbar...");
            if(IsSellPinbar() && TS < Max_Order && (jamOP() || TS > 0))
              {
               Print("DEBUG: All SELL conditions met! Opening SELL position...");
               double SellSL = NormalizeDouble(bid + SL_Pip * g_Point, _Digits);
               double SellTP = NormalizeDouble(bid - TP_Pip * g_Point, _Digits);
               if(trade.Sell(GetLots(), _Symbol, bid, SellSL, SellTP, "AfterScalper_V1.1"))
                 {
                  Print("SUCCESS: SELL position opened!");
                  CloseBuy();
                 }
               else
                 {
                  Print("ERROR: Failed to open SELL position. Error: ", GetLastError());
                 }
              }
            else
              {
               Print("DEBUG: SELL conditions NOT met. IsSellPinbar: ", IsSellPinbar(), " TS: ", TS, " Max: ", Max_Order, " jamOP: ", jamOP());
              }
           }
        }
      else
        {
         Print("DEBUG: Market orders check FAILED. BuyOrders: ", CheckMarketBuyOrders(), " SellOrders: ", CheckMarketSellOrders());
        }
     }
   else
     {
      Print("DEBUG: pos < 0, skipping Trade_BySignal=OFF logic");
     }
   if(CountTrades() == 0)
     {
      if(level > currentRates[0].open  &&  Trade_BySignal == ON)
        {
         Print("DEBUG: BUY Signal (Trade_BySignal=ON). CountTrades: ", CountTrades());
         if(IsBuyPinbar()  && CountTrades() < Max_Order)
           {
            Print("DEBUG: Opening BUY position (Trade_BySignal=ON)...");
            if(trade.Buy(GetLots(), _Symbol, ask, 0, 0, "AfterScalper_V1.1"))
              {
               g_ticket = trade.ResultOrder();
               double newSL = ask - SL_Pip * g_Point;
               double newTP = ask + (TP_Pip * g_Point);
               trade.PositionModify(g_ticket, newSL, newTP);
               Print("SUCCESS: BUY position opened (Trade_BySignal=ON). Ticket: ", g_ticket);
              }
            else
              {
               Print("ERROR: Failed to open BUY (Trade_BySignal=ON). Error: ", GetLastError());
              }
           }
         else
           {
            Print("DEBUG: BUY pinbar check failed. IsBuyPinbar: ", IsBuyPinbar());
           }
        }
     }
   if(CountTrades() == 0)
     {
      if(level < currentRates[0].open  &&  Trade_BySignal == ON)
        {
         Print("DEBUG: SELL Signal (Trade_BySignal=ON). CountTrades: ", CountTrades());
         if(IsSellPinbar() &&  CountTrades() < Max_Order)
           {
            Print("DEBUG: Opening SELL position (Trade_BySignal=ON)...");
            if(trade.Sell(GetLots(), _Symbol, bid, 0, 0, "AfterScalper_V1.1"))
              {
               g_ticket = trade.ResultOrder();
               double newSL = bid + SL_Pip * g_Point;
               double newTP = bid - (TP_Pip * g_Point);
               trade.PositionModify(g_ticket, newSL, newTP);
               Print("SUCCESS: SELL position opened (Trade_BySignal=ON). Ticket: ", g_ticket);
              }
            else
              {
               Print("ERROR: Failed to open SELL (Trade_BySignal=ON). Error: ", GetLastError());
              }
           }
         else
           {
            Print("DEBUG: SELL pinbar check failed. IsSellPinbar: ", IsSellPinbar());
           }
        }
     }
   if(Close_BySignal == true)
     {
      if(level > currentRates[0].open &&  Trade_BySignal == ON)
        {
         if(IsBuyPinbar()  && Sell > 0)
           {
            CloseSell();
           }
        }
      if(level < currentRates[0].open &&  Trade_BySignal == ON)
        {
         if(IsSellPinbar() && Buy > 0)
           {
            CloseBuy();
           }
        }
     }
   if(Trade_BySignal == ON && CountTradesBuy() >= 1 && CountTradesBuy() < Max_Order &&  TPLinier == false)
     {
      myAvg();
     }
   if(Trade_BySignal == ON && CountTradesSell() >= 1 && CountTradesSell() < Max_Order &&  TPLinier == false)
     {
      myAvg();
     }
   if(Trade_BySignal == ON && CountTradesBuy() >= 1 && CountTradesBuy() < Max_Order &&  TPLinier == true)
     {
      myAvg1();
     }
   if(Trade_BySignal == ON && CountTradesSell() >= 1 && CountTradesSell() < Max_Order &&  TPLinier == true)
     {
      myAvg1();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong posTicket = PositionGetTicket(i);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
         PositionGetInteger(POSITION_MAGIC) != MagicID)
         continue;
      count++;
     }
   return(count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTradesBuy()
  {
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong posTicket = PositionGetTicket(i);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
         PositionGetInteger(POSITION_MAGIC) != MagicID)
         continue;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         count++;
     }
   return(count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTradesSell()
  {
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong posTicket = PositionGetTicket(i);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
         PositionGetInteger(POSITION_MAGIC) != MagicID)
         continue;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         count++;
     }
   return(count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myAvg()
  {
   int      iCount      =  0;
   double   LastOP      =  0;
   double   LastLots    =  0;
   bool     LastIsBuy   =  false;
   int      iTotalBuy   =  0;
   int      iTotalSell  =  0;
   MqlRates h1Rates[];
   ArraySetAsSeries(h1Rates, true);
   if(CopyRates(_Symbol, PERIOD_H1, 0, 5, h1Rates) < 5)
      return;
   double level = h1Rates[1].close;
   MqlRates currentRates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, currentRates) <= 0)
      return;
   for(iCount = 0; iCount < PositionsTotal(); iCount++)
     {
      ulong posTicket = PositionGetTicket(iCount);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
         PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicID)
        {
         if(LastOP == 0)
            LastOP = PositionGetDouble(POSITION_PRICE_OPEN);
         if(LastOP > PositionGetDouble(POSITION_PRICE_OPEN))
            LastOP = PositionGetDouble(POSITION_PRICE_OPEN);
         if(LastLots < PositionGetDouble(POSITION_VOLUME))
            LastLots = PositionGetDouble(POSITION_VOLUME);
         LastIsBuy = true;
         iTotalBuy++;
        }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
         PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicID)
        {
         if(LastOP == 0)
            LastOP = PositionGetDouble(POSITION_PRICE_OPEN);
         if(LastOP < PositionGetDouble(POSITION_PRICE_OPEN))
            LastOP = PositionGetDouble(POSITION_PRICE_OPEN);
         if(LastLots < PositionGetDouble(POSITION_VOLUME))
            LastLots = PositionGetDouble(POSITION_VOLUME);
         LastIsBuy = false;
         iTotalSell++;
        }
     }
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(LastIsBuy)
     {
      if(level > currentRates[0].open)
        {
         if(IsBuyPinbar() && bid <= LastOP - (Order_Distance * _Point))
           {
            double newLot = NormalizeDouble((LastLots * LotMultiply), 2);
            double newSL = ask - SL_Pip * g_Point;
            double newTP = ask + (TP_Pip * g_Point);
            trade.Buy(newLot, _Symbol, ask, newSL, newTP, "AfterScalper_V1.1");
            LastIsBuy = false;
            return;
           }
        }
     }
   else
      if(!LastIsBuy)
        {
         if(level < currentRates[0].open)
           {
            if(IsSellPinbar() && ask >= LastOP + (Order_Distance * _Point))
              {
               double newLot = NormalizeDouble((LastLots * LotMultiply), 2);
               double newSL = bid + SL_Pip * g_Point;
               double newTP = bid - (TP_Pip * g_Point);
               trade.Sell(newLot, _Symbol, bid, newSL, newTP, "AfterScalper_V1.1");
               return;
              }
           }
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myAvg1()
  {
   int      iCount      =  0;
   double   LastOP      =  0;
   double   LastLots    =  0;
   bool     LastIsBuy   =  false;
   int      iTotalBuy   =  0;
   int      iTotalSell  =  0;
   MqlRates h1Rates[];
   ArraySetAsSeries(h1Rates, true);
   if(CopyRates(_Symbol, PERIOD_H1, 0, 5, h1Rates) < 5)
      return;
   double level = h1Rates[1].close;
   MqlRates currentRates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, currentRates) <= 0)
      return;
   for(iCount = 0; iCount < PositionsTotal(); iCount++)
     {
      ulong posTicket = PositionGetTicket(iCount);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
         PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicID)
        {
         if(LastOP == 0)
            LastOP = PositionGetDouble(POSITION_PRICE_OPEN);
         if(LastOP > PositionGetDouble(POSITION_PRICE_OPEN))
            LastOP = PositionGetDouble(POSITION_PRICE_OPEN);
         if(LastLots < PositionGetDouble(POSITION_VOLUME))
            LastLots = PositionGetDouble(POSITION_VOLUME);
         LastIsBuy = true;
         iTotalBuy++;
        }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
         PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicID)
        {
         if(LastOP == 0)
            LastOP = PositionGetDouble(POSITION_PRICE_OPEN);
         if(LastOP < PositionGetDouble(POSITION_PRICE_OPEN))
            LastOP = PositionGetDouble(POSITION_PRICE_OPEN);
         if(LastLots < PositionGetDouble(POSITION_VOLUME))
            LastLots = PositionGetDouble(POSITION_VOLUME);
         LastIsBuy = false;
         iTotalSell++;
        }
     }
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(LastIsBuy)
     {
      if(level > currentRates[0].open)
        {
         if(IsBuyPinbar() && bid <= LastOP - (Order_Distance * _Point))
           {
            double newLot = NormalizeDouble((LastLots * LotMultiply), 2);
            if(trade.Buy(newLot, _Symbol, ask, 0, 0, "AfterScalper_V1.1"))
              {
               hitung();
               tpsl();
              }
            LastIsBuy = false;
            return;
           }
        }
     }
   else
      if(!LastIsBuy)
        {
         if(level < currentRates[0].open)
           {
            if(IsSellPinbar() && ask >= LastOP + (Order_Distance * _Point))
              {
               double newLot = NormalizeDouble((LastLots * LotMultiply), 2);
               if(trade.Sell(newLot, _Symbol, bid, 0, 0, "AfterScalper_V1.1"))
                 {
                  hitung();
                  tpsl();
                 }
               return;
              }
           }
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void hitung()
  {
   Buy    = 0;
   lotbuy = 0;
   lotsbuy = 0;
   Sell = 0;
   lotsell = 0;
   lotssell = 0;
   SUM = 0;
   SWAP = 0;
   profitbuy = 0;
   profitsell = 0;
   sumbuy = 0;
   sumsell = 0;
   bepbuy = 0;
   bepsell = 0;
   lowlotbuy = 9999;
   lowlotsell = 9999;
   hisell = 0;
   lobuy = 999999999;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong posTicket = PositionGetTicket(i);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         Buy++;
         OP++;
         lotbuy = PositionGetDouble(POSITION_VOLUME);
         profitbuy          += PositionGetDouble(POSITION_PROFIT);
         lotsbuy += PositionGetDouble(POSITION_VOLUME);
         lowlotbuy = MathMin(lowlotbuy, PositionGetDouble(POSITION_VOLUME));
         sumbuy             += PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_OPEN);
         lobuy = MathMin(lobuy, PositionGetDouble(POSITION_PRICE_OPEN));
        }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         Sell++;
         OP++;
         lotsell = PositionGetDouble(POSITION_VOLUME);
         profitsell           += PositionGetDouble(POSITION_PROFIT);
         lotssell += PositionGetDouble(POSITION_VOLUME);
         lowlotsell = MathMin(lowlotsell, PositionGetDouble(POSITION_VOLUME));
         sumsell              += PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_OPEN);
         hisell = MathMax(hisell, PositionGetDouble(POSITION_PRICE_OPEN));
        }
     }
   if(lotsbuy > 0)
      bepbuy = sumbuy / lotsbuy;
   if(lotssell > 0)
      bepsell = sumsell / lotssell;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ND(double p)
  {
   return(NormalizeDouble(p, _Digits));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void tpsl()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         double oTPB = (bepbuy + TP_Pip * _Point) * (TP_Pip > 0);
         double oSLB = PositionGetDouble(POSITION_SL);
         if(SL_BEP_minus > 0)
            oSLB = (bepbuy - SL_BEP_minus * _Point);
         if(Buy == 1)
           {
            oTPB = ND(PositionGetDouble(POSITION_PRICE_OPEN) + TP_Pip * _Point) * (TP_Pip > 0);
            if(StopLoss  > 0)
               oSLB = (PositionGetDouble(POSITION_PRICE_OPEN) -  StopLoss  * _Point);
           }
         oTPB = ND(oTPB);
         oSLB = ND(oSLB);
         if(bid >= oTPB && oTPB > 0)
            trade.PositionClose(posTicket);
         else
            if(bid <= oSLB)
               trade.PositionClose(posTicket);
            else
               if(ND(PositionGetDouble(POSITION_TP)) != oTPB || ND(PositionGetDouble(POSITION_SL)) != oSLB)
                 {
                  if(!trade.PositionModify(posTicket, oSLB, oTPB))
                    {
                     Print(IntegerToString(posTicket) + " MODIFY TP  @ " + DoubleToString(oTPB, _Digits) + " SL @ " + DoubleToString(oSLB, _Digits) + " ");
                    }
                 }
        }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         double oTPS = (bepsell - TP_Pip * _Point) * (TP_Pip > 0);
         double oSLS = PositionGetDouble(POSITION_SL);
         if(SL_BEP_minus > 0)
            oSLS = (bepsell + SL_BEP_minus * _Point);
         if(Sell == 1)
           {
            oTPS = (PositionGetDouble(POSITION_PRICE_OPEN) - TP_Pip * _Point) * (TP_Pip > 0);
            if(StopLoss  > 0)
               oSLS = (PositionGetDouble(POSITION_PRICE_OPEN) +  StopLoss  * _Point);
           }
         oTPS = ND(oTPS);
         oSLS = ND(oSLS);
         if(ask <= oTPS)
            trade.PositionClose(posTicket);
         else
            if(ask >= oSLS && oSLS > 0)
               trade.PositionClose(posTicket);
            else
               if(ND(PositionGetDouble(POSITION_TP)) != oTPS || ND(PositionGetDouble(POSITION_SL)) != oSLS)
                 {
                  if(!trade.PositionModify(posTicket, oSLS, oTPS))
                    {
                     Print(IntegerToString(posTicket) + "MODIFY TP  @ " + DoubleToString(oTPS, _Digits) + " SL @ " + DoubleToString(oSLS, _Digits) + " ");
                    }
                 }
        }
     }
  }
/*

void ReadFileHst(string FileName)
  {
   int fileHandle = FileOpen(FileName, FILE_READ|FILE_BIN|FILE_COMMON);

   if(fileHandle == INVALID_HANDLE)
     {
      string shortName = _Symbol + "60.hst";
      fileHandle = FileOpen(shortName, FILE_READ|FILE_BIN);

      if(fileHandle == INVALID_HANDLE)
        {

         Print("Cannot open file: ", FileName);

         Print("Also tried: ", shortName);

         Print("Error: ", GetLastError());

         Comment("WARNING: Cannot load history file - EA will use alternative method");
         BytesToRead = 0;
         return;
        }
     }
   int fileSize = (int)FileSize(fileHandle);

   if(fileSize <= 148)
     {

      FileClose(fileHandle);
      return;
     }

   FileSeek(fileHandle, 148, SEEK_SET);
   BytesToRead = (fileSize - 148) / 60;

   ArrayResize(data, BytesToRead);
   uchar buffer[60];

   for(int i = 0; i < BytesToRead; i++)
     {

      if(FileReadArray(fileHandle, buffer, 0, 60) != 60)
         break;
      long timeValue = 0;

      for(int b = 0; b < 8; b++)
         timeValue |= (long)buffer[b] << (b * 8);
      m_price.buffer[0] = buffer[32];
      m_price.buffer[1] = buffer[33];
      m_price.buffer[2] = buffer[34];
      m_price.buffer[3] = buffer[35];
      m_price.buffer[4] = buffer[36];
      m_price.buffer[5] = buffer[37];
      m_price.buffer[6] = buffer[38];
      m_price.buffer[7] = buffer[39];
      data[i][0] = (double)timeValue;
      data[i][1] = m_price.close;
     }

   FileClose(fileHandle);
  }
*/

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
int CheckMarketSellOrders()
  {
   int op = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong posTicket = PositionGetTicket(i);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicID)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            op++;
        }
     }
   return(op);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketBuyOrders()
  {
   int op = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong posTicket = PositionGetTicket(i);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicID)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            op++;
        }
     }
   return(op);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == MagicID &&
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            trade.PositionClose(posTicket);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSell()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == MagicID &&
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            trade.PositionClose(posTicket);
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
   if(UseMartingale)
     {
      lot = g_CurrentMartingaleLot;
      Print("DEBUG Martingale: Using lot ", lot, " (Step: ", g_MartingaleStep, ")");
     }
   else
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
   if(lot < minlot)
      lot = minlot;
   if(lot > maxlot)
      lot = maxlot;
   return(lot);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool jamOP()
  {
   bool Oc = false;
   if(UseTimeFilter)
     {
      datetime currentTime = TimeCurrent();
      MqlDateTime currentDT;
      TimeToStruct(currentTime, currentDT);
      string dateStr = StringFormat("%04d.%02d.%02d", currentDT.year, currentDT.mon, currentDT.day);
      string j1 = dateStr + " " + Start;
      string j2 = dateStr + " " + End1;
      datetime startTime = StringToTime(j1);
      datetime endTime = StringToTime(j2);
      if(currentTime >= startTime && currentTime < endTime)
         return(true);
     }
   else
     {
      return(true);
     }
   return(Oc);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CandleStick_Analyzer()
  {
   string CandleStick, Comment1 = "", Comment2 = "", Comment3 = "", Comment4 = "", Comment5 = "", Comment6 = "", Comment7 = "", Comment8 = "", Comment9 = "";
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
   CandleStick = Comment1 + Comment2 + Comment3 + Comment4 + Comment5 + Comment6 + Comment7 + Comment8 + Comment9;
   return (CandleStick);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishEngulfingExists()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, rates) < 3)
      return false;
   if(rates[1].open <= rates[2].close && rates[1].close >= rates[2].open &&
      rates[2].open - rates[2].close >= 10 * _Point && rates[1].close - rates[1].open >= 10 * _Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishHaramiExists()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, rates) < 3)
      return false;
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(iATR(_Symbol, PERIOD_CURRENT, 14), 0, 0, 3, atr) < 3)
      return false;
   if(rates[2].close < rates[2].open && rates[1].open < rates[1].close &&
      rates[2].open - rates[2].close > atr[2] &&
      rates[2].open - rates[2].close > 4 * (rates[1].close - rates[1].open))
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DojiAtBottomExists()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 4, rates) < 4)
      return false;
   if(rates[3].open - rates[3].close >= 8 * _Point &&
      MathAbs(rates[2].close - rates[2].open) <= 1 * _Point &&
      rates[1].close - rates[1].open >= 8 * _Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DojiAtTopExists()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 4, rates) < 4)
      return false;
   if(rates[3].close - rates[3].open >= 8 * _Point &&
      MathAbs(rates[2].close - rates[2].open) <= 1 * _Point &&
      rates[1].open - rates[1].close >= 8 * _Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishHaramiExists()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, rates) < 3)
      return false;
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(iATR(_Symbol, PERIOD_CURRENT, 14), 0, 0, 3, atr) < 3)
      return false;
   if(rates[2].close > rates[1].close && rates[2].open < rates[1].open &&
      rates[2].close > rates[2].open && rates[1].open > rates[1].close &&
      rates[2].close - rates[2].open > atr[2] &&
      rates[2].close - rates[2].open > 4 * (rates[1].open - rates[1].close))
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongUpCandleExists()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, rates) < 3)
      return false;
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(iATR(_Symbol, PERIOD_CURRENT, 14), 0, 0, 3, atr) < 3)
      return false;
   if(rates[2].open < rates[2].close && rates[2].high - rates[2].low >= 40 * _Point &&
      rates[2].high - rates[2].low > 2.5 * atr[2] &&
      rates[1].close < rates[1].open && rates[1].open - rates[1].close > 10 * _Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongDownCandleExists()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 2, rates) < 2)
      return false;
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(iATR(_Symbol, PERIOD_CURRENT, 14), 0, 0, 2, atr) < 2)
      return false;
   if(rates[1].open > rates[1].close && rates[1].high - rates[1].low >= 40 * _Point &&
      rates[1].high - rates[1].low > 2.5 * atr[1])
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishEngulfingExists()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, rates) < 3)
      return false;
   if(rates[1].open >= rates[2].close && rates[1].close <= rates[2].open &&
      rates[2].open - rates[2].close >= 10 * _Point && rates[1].close - rates[1].open >= 10 * _Point)
      return (true);
   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MakeLine(double price)
  {
   string name = "level";
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_M5, 0, 1, rates) > 0)
     {
      if(price > rates[0].open)
         Comment("BUY = " + DoubleToString(price, _Digits));
      if(price < rates[0].open)
         Comment("SELL= " + DoubleToString(price, _Digits));
     }
   if(ObjectFind(0, name) != -1)
     {
      MqlRates ratesM1[];
      if(CopyRates(_Symbol, PERIOD_M1, 0, 1, ratesM1) > 0)
        {
         ObjectMove(0, name, 0, ratesM1[0].time, price);
        }
      return;
     }
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBuyPinbar()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, rates) < 3)
      return false;
   double actOp = rates[1].open;
   double actCl = rates[1].close;
   double actHi = rates[0].high;
   double actLo = rates[1].low;
   double preOp = rates[2].open;
   double preCl = rates[2].close;
   double preHi = rates[2].high;
   double preLo = rates[2].low;
   double actRange = actHi - actLo;
   double preRange = preHi - preLo;
   double actHigherPart = actHi - actRange * 0.4;
   double actHigherPart1 = actHi - actRange * 0.4;
   double dayRange = AveRange4();
   if((actCl > actHigherPart1 && actOp > actHigherPart) &&
      (actRange > dayRange * 0.5) &&
      (actLo + actRange * 0.25 < preLo))
     {
      double lows[];
      ArraySetAsSeries(lows, true);
      if(CopyLow(_Symbol, PERIOD_CURRENT, 0, 6, lows) >= 6)
        {
         int minIdx = ArrayMinimum(lows, 3, 3);
         if(lows[minIdx] > rates[1].low)
            return (true);
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSellPinbar()
  {
   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, rates) < 3)
      return false;
   double actOp = rates[1].open;
   double actCl = rates[1].close;
   double actHi = rates[1].high;
   double actLo = rates[1].low;
   double preOp = rates[2].open;
   double preCl = rates[2].close;
   double preHi = rates[2].high;
   double preLo = rates[2].low;
   double actRange = actHi - actLo;
   double preRange = preHi - preLo;
   double actLowerPart = actLo + actRange * 0.4;
   double actLowerPart1 = actLo + actRange * 0.4;
   double dayRange = AveRange4();
   if((actCl < actLowerPart1 && actOp < actLowerPart) &&
      (actRange > dayRange * 0.5) &&
      (actHi - actRange * 0.25 > preHi))
     {
      double highs[];
      ArraySetAsSeries(highs, true);
      if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, 6, highs) >= 6)
        {
         int maxIdx = ArrayMaximum(highs, 3, 3);
         if(highs[maxIdx] < rates[1].high)
            return (true);
        }
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
      TimeToStruct(rates[ind].time, dt);
      if(dt.day_of_week != 0)
        {
         sum += rates[ind].high - rates[ind].low;
         i++;
        }
      ind++;
     }
   return (sum / 4.0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTP(int tipe, double TP_5)
  {
   for(int cnt = PositionsTotal() - 1; cnt >= 0; cnt--)
     {
      ulong posTicket = PositionGetTicket(cnt);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicID &&
         PositionGetInteger(POSITION_TYPE) == tipe)
        {
         if(NormalizeDouble(PositionGetDouble(POSITION_TP), _Digits) != NormalizeDouble(TP_5, _Digits))
           {
            trade.PositionModify(posTicket,
                                 PositionGetDouble(POSITION_SL),
                                 NormalizeDouble(TP_5, _Digits));
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double rata_price(int tipe)
  {
   double total_lot = 0;
   double total_kali = 0;
   double rata_price = 0;
   for(int cnt = 0; cnt < PositionsTotal(); cnt++)
     {
      ulong posTicket = PositionGetTicket(cnt);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicID &&
         PositionGetInteger(POSITION_TYPE) == tipe)
        {
         total_lot  = total_lot + PositionGetDouble(POSITION_VOLUME);
         total_kali = total_kali + (PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_OPEN));
        }
     }
   if(total_lot != 0)
      rata_price = total_kali / total_lot;
   else
      rata_price = 0;
   return (rata_price);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeOP(int tipe)
  {
   for(int cnt = PositionsTotal() - 1; cnt >= 0; cnt--)
     {
      ulong posTicket = PositionGetTicket(cnt);
      if(!PositionSelectByTicket(posTicket))
         continue;
      if(PositionGetInteger(POSITION_TYPE) == tipe &&
         PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicID)
        {
         trade.PositionClose(posTicket);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(ObjectGetInteger(0, "CLOSE ALL1", OBJPROP_STATE) != 0)
     {
      ObjectSetInteger(0, "CLOSE ALL1", OBJPROP_STATE, 0);
      PlaySound("alert2.wav");
      for(int cnt = PositionsTotal() - 1; cnt >= 0; cnt--)
        {
         ulong posTicket = PositionGetTicket(cnt);
         if(PositionSelectByTicket(posTicket))
           {
            trade.PositionClose(posTicket);
           }
        }
      return;
     }
   if(ObjectGetInteger(0, "CLOSE ALL", OBJPROP_STATE) != 0)
     {
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_STATE, 0);
      for(int li_0 = PositionsTotal() - 1; li_0 >= 0; li_0--)
        {
         ulong posTicket = PositionGetTicket(li_0);
         if(PositionSelectByTicket(posTicket))
           {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
              {
               trade.PositionClose(posTicket);
               Sleep(1000);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LossandWon(double &TotalLoss, double &PercentageLoss)
  {
   datetime today = TimeCurrent();
   TotalLoss = 0;
   double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double Equidad = AccountInfoDouble(ACCOUNT_EQUITY);
   HistorySelect(0, TimeCurrent());
   for(int l = HistoryDealsTotal() - 1; l >= 0; l--)
     {
      ulong dealTicket = HistoryDealGetTicket(l);
      if(dealTicket > 0)
        {
         if(HistoryDealGetString(dealTicket, DEAL_SYMBOL) == _Symbol)
           {
            if(HistoryDealGetInteger(dealTicket, DEAL_MAGIC) == MagicID)
              {
               datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
               MqlDateTime dealDT, todayDT;
               TimeToStruct(dealTime, dealDT);
               TimeToStruct(today, todayDT);
               if(dealDT.day == todayDT.day &&
                  dealDT.mon == todayDT.mon &&
                  dealDT.year == todayDT.year)
                 {
                  double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
                  if(profit <= 0)
                     TotalLoss += profit;
                 }
              }
           }
        }
     }
   if(Porcent_BySignal == Balances && Balance > 0)
      PercentageLoss = (TotalLoss / Balance) * 100.0;
   else
      if(Porcent_BySignal == Equidades && Equidad > 0)
         PercentageLoss = (TotalLoss / Equidad) * 100.0;
      else
         PercentageLoss = 0;
   PercentageLoss = MathAbs(PercentageLoss);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckAndUpdateMartingale()
  {
   if(!UseMartingale)
      return;
   datetime from = iTime(_Symbol, PERIOD_D1, 0);
   datetime to = TimeCurrent();
   HistorySelect(from, to);
   int totalDeals = HistoryDealsTotal();
   if(totalDeals == 0)
      return;
   ulong lastDealTicket = 0;
   datetime lastDealTime = 0;
   for(int i = totalDeals - 1; i >= 0; i--)
     {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket > 0)
        {
         if(HistoryDealGetInteger(dealTicket, DEAL_MAGIC) == MagicID &&
            HistoryDealGetString(dealTicket, DEAL_SYMBOL) == _Symbol)
           {
            ENUM_DEAL_ENTRY dealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
            if(dealEntry == DEAL_ENTRY_OUT)
              {
               datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
               if(dealTime > lastDealTime)
                 {
                  lastDealTime = dealTime;
                  lastDealTicket = dealTicket;
                 }
              }
           }
        }
     }
   if(lastDealTicket > 0 && lastDealTime > g_LastTradeCloseTime)
     {
      g_LastTradeCloseTime = lastDealTime;
      double profit = HistoryDealGetDouble(lastDealTicket, DEAL_PROFIT);
      double swap = HistoryDealGetDouble(lastDealTicket, DEAL_SWAP);
      double commission = HistoryDealGetDouble(lastDealTicket, DEAL_COMMISSION);
      double totalProfit = profit + swap + commission;
      Print("DEBUG Martingale: Last closed deal profit: ", totalProfit);
      if(totalProfit < 0)
        {
         g_LastTradeWasLoss = true;
         if(g_MartingaleStep < MaxMartingaleSteps)
           {
            g_MartingaleStep++;
            g_CurrentMartingaleLot = NormalizeDouble(g_CurrentMartingaleLot * MartingaleMultiplier, 2);
            if(g_CurrentMartingaleLot > MaxMartingaleLot)
               g_CurrentMartingaleLot = MaxMartingaleLot;
            Print("MARTINGALE: Loss detected! Increasing lot to ", g_CurrentMartingaleLot, " (Step ", g_MartingaleStep, ")");
           }
         else
           {
            Print("MARTINGALE: Max steps reached! Resetting...");
            ResetMartingale();
           }
        }
      else
         if(totalProfit > 0)
           {
            g_LastTradeWasLoss = false;
            if(ResetOnProfit)
              {
               Print("MARTINGALE: Profit detected! Resetting to base lot.");
               ResetMartingale();
              }
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetMartingale()
  {
   g_CurrentMartingaleLot = MartingaleStartLot;
   g_MartingaleStep = 0;
   g_LastTradeWasLoss = false;
   Print("MARTINGALE: Reset to base lot ", g_CurrentMartingaleLot);
  }
//+------------------------------------------------------------------+
// -- Project -------------------------------------------------------------------------------
/*
Name:        After2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76382
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