/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        [FXI]TrendFinder_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74129&sid=ef53b4c8a4d8b70032c2325fd2fba82f&start=10
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

enum posDirection
  {
   booth = 0,           // Open BUY and SELL positions
   buy = 1,             // Open only BUY position
   sell = 2             // Open only SELL position
  };
enum openPosition
  {
   immediately = 0,     // Immediately
   afterClose = 1,      // After candle closed
   afterClose2 = 2,     // After candle closed + 1 bar
   afterClose3 = 3,     // After candle closed + 2 bars
   afterClose4 = 4,     // After candle closed + 3 bars
   afterClose5 = 5,     // After candle closed + 4 bars
   afterClose6 = 6,     // After candle closed + 5 bars
   afterClose7 = 7,     // After candle closed + 6 bars
   afterClose8 = 8      // After candle closed + 7 bars
  };
enum closePosition
  {
   offC = -1,            // Off
   immediatelyC = 0,     // Immediately
   afterCloseC = 1,      // After candle closed
   afterClose2C = 2,     // After candle closed + 1 bar
   afterClose3C = 3,     // After candle closed + 2 bars
   afterClose4C = 4,     // After candle closed + 3 bars
   afterClose5C = 5,     // After candle closed + 4 bars
   afterClose6C = 6,     // After candle closed + 5 bars
   afterClose7C = 7,     // After candle closed + 6 bars
   afterClose8C = 8      // After candle closed + 7 bars
  };
enum closeAllBy
  {
   off = 0,             // Off
   pip = 1,             // Pip/point (as set in "Pip/Point Mode" setting)
   currency = 2,        // Deposit currency
   percentage = 3       // Percentage of the equity
  };
enum cMode
  {
   pips = 0,            // Pips
   points = 1           // Points
  };
enum globalPL
  {
   live = 0,            // Running
   liveGrid = 2,        // Running and closed (from the first opened)
  };
enum trailingAndBe
  {
   disabled = 0,                             // Off
   normal = 1                                // On
  };
enum lMode
  {
   lotMoney = 0,                             // Money (depends on exact SL value)
   lotAccountPercent = 1,                    // Percent of equity (depends on exact SL value)
   lotAccountBalance = 2,                    // Percent of balance (depends on exact SL value)
   lotFixLots = 3,                           // Fixed lots
   lotMoneyMargin = 4,                       // Money / margin requirement
   lotPercentMargin = 5                      // Percent / margin requirement
  };
enum slMode
  {
   slOff = 0,                                // Don't use (depends on fixed or margin determined lots)
   slMoney = 1,                              // Money (depends on fixed or margin determined lots)
   slAccountPercent = 2,                     // Percent of equity (depends on fixed or margin determined lots)
   slFix = 3,                                // Pip/point (as set in "Pip/Point Mode" setting)
   slAbsolute = 4,                           // Absolute Value (for buy = value, for sell = value 2)
   slATR = 5,                                // ATR (period = value, multiplicator = value 2)
   slBars = 6,                               // Highest/lowest of (value) bars, +/- (value 2) offset pip/point
   slPricePercent = 7                        // Percent of price
  };
enum tpMode
  {
   tpOff = 0,                                // Don't use (depends on fixed or margin determined lots)
   tpMoney = 1,                              // Money (depends on fixed or margin determined lots)
   tpAccountPercent = 2,                     // Percent of equity (depends on fixed or margin determined lots)
   tpFix = 3,                                // Pip/point (as set in "Pip/Point Mode")
   tpPricePercent = 7,                       // Percent of price
   tpAbsolute = 4,                           // Absolute Value (for buy = value, for sell = value 2)
   tpATR = 5,                                // ATR (period = value, multiplicator = value 2)
   tpBars = 6,                               // Highest /lowest of (value) bars, +/- (value 2) offset pip/point
   tpSlRatio = 100                           // Stop loss distance ratio (R:R)
  };
enum entlogic
  {
   Direct = 0,
   Reversal = 1
  };
enum ENUM_timeZone
  {
   timeGMT = 0,                              // GMT
   timeLocal = 1,                            // Local
   timeCurrent = 2                           // Server
  };
enum enPrices
  {
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted

   pr_average,    // Average (high+low+open+close)/4

   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price

   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen,     // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price

   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
  };
input string ea = "==========  EA Settings  =========="; // ==========  EA Settings  ==========
input int slp = 30;                          // Slippage in points
input cMode calcMode = 0;                    // Pip/Point mode (for SL, TP, etc.)
input int MagicNumber = 3535;                // Magic number
input bool ecn_broker = false;               // ECN Broker?
input openPosition whenOpen = 1;             // Open position at
input closePosition whenClose = 1;             // Close position at
input posDirection posDir = 0;               // Position direction
input  entlogic entryLogic = 0;              // Entry logic
input bool closeAtOpposite = true;           // Close position at opposite signal
input string mp = "==========  Max Positions at Same Time  =========="; // ==========  Max Positions at Same Time  ==========
input int maxPos = 2;                        // Max sell-buy positions at same time (0=unlimited)
input int maxBuyPos = 1;                     // Max buy positions at same time (0=unlimited)
input int maxSellPos = 1;                    // Max sell positions at same time (0=unlimited)
input string ps = "==========  Position Size Settings  =========="; // ==========  Position Size Settings  ==========
input lMode lotMode = 3;                     // Lot calculation mode
input double Lot = 0.01;                     // Lot value (as set in "Lot calculation mode")
input double maxLot = 1.00;                  // Maximum size of lots (All positions)
input string sltp = "==========  SL / TP Settings  =========="; // ==========  SL / TP Settings  ==========
input slMode SlMode = 3;                     // SL by
input double SlVal = 40;                     // SL value
input double SlVal2 = 1;                     // SL value 2 (if required in the "SL by" setting
input double SlMin = 10;                     // Min SL distance pip/point (as set in "Pip/Point mode")
input tpMode TpMode = 3;                     // TP by
input double TpVal = 40;                     // TP value
input double TpVal2 = 1;                     // TP value 2 (if required in the "TP by" setting)
input double TpMin = 10;                     // Min TP distance pip/point (as set in "Pip/Point mode")
input bool addSpread = true;                 // Add current spread to SL/TP calculation
input string tsl = "==========  Trailing Stop  =========="; // ==========  Trailing Stop  ==========
input trailingAndBe trailing_sl = 0;         // Trailing stop loss
input double trailing_stop_start = 20;       // Trailing stop loss start
input double trailing_stop_dist = 40;        // Trailing stop loss distance
input double trailing_stop_step = 5;         // Trailing stop loss step
input string bev = "==========  Breakeven =========="; // ==========  Breakeven  ==========
input trailingAndBe be = 0;                  // Breakeven
input double be_trigger = 10;                // Beakeven trigger
input double be_level = 0;                   // Breakeven target
input string rsxf = "==========  RSX Filter =========="; // ==========  RSX Filter  ==========
input bool rsxEntryFilter = false;           // Use RSX for entry filter
input bool rsxExitFilter = false;            // Use RSX for exit filter
input int Length = 14;                       // Rsx length
input enPrices Price = pr_median;            // Rsx price
input double levelOb = 70;                   // RSX Overbought level
input double levelOs = 30;                   // RSX Oversold level
input int rsxMaxBars = 200;                  // Max bars to look back for RSX signal
bool initOK = true;
string symbols[];
string EAName = "[FXI]TrendFinder_EA";
string custom_indicator = "[FXI]TrendFinder";
int globalCalcMode = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(symbols, 1);
   symbols[0] = Symbol();
   ResetLastError();
   if(custom_indicator != "")
     {
      double temp = iCustom(NULL, 0, custom_indicator, 0, 0);
      if(GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
        {
         Alert("Please install the: " + custom_indicator + " indicator to the MQL4/Indicators folder");
         initOK = false;
        }
     }
   if(lotMode < 3 && SlMode < 3)
     {
      Alert("Incompatible \"Lot calculation mode\" and \"Stop loss by\" settings. Please check the dependencies.");
      initOK = false;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!initOK)
      return;
   int ticket;
   double slPrice = 0.0, tpPrice = 0.0;
   double lot;
   bool newBar = IsNewBar();
   bool trade = true;
   int logic = entryLogic;
   if(((whenClose > 0 && newBar) || whenClose == 0))
     {
      for(int closeIdx = 0; closeIdx < ArraySize(symbols); closeIdx++)
        {
         string closeSym = symbols[closeIdx];
         int exitDir = checkExit(whenClose, closeSym);
         if(numberOfPositions(1, closeSym) > 0 && exitDir == 1)
            closeAll(1, closeSym);
         if(numberOfPositions(2, closeSym) > 0 && exitDir == 2)
            closeAll(2, closeSym);
        }
     }
   if(((whenOpen > 0 && newBar) || whenOpen == 0) && trade)
     {
      for(int openIdx = 0; openIdx < ArraySize(symbols); openIdx++)
        {
         string openSym = symbols[openIdx];
         string orderComment = EAName;
         int multi = multi(openSym);
         int dig = (int)MarketInfo(openSym, MODE_DIGITS);
         double sLevel = MarketInfo(openSym, MODE_STOPLEVEL);
         double poi = MarketInfo(openSym, MODE_POINT);
         double bid = MarketInfo(openSym, MODE_BID);
         double ask = MarketInfo(openSym, MODE_ASK);
         double spread = MarketInfo(openSym, MODE_SPREAD);
         int entryDir = checkEntry(whenOpen, openSym);
         if((entryDir == 1 && logic == 0) || (entryDir == 2 && logic == 1))
           {
            if(posDir == 2)
               continue;
            if(numberOfPositions(2, openSym) > 0 && closeAtOpposite)
              {
               closeAll(2, openSym);
              }
            if((numberOfPositions(1, openSym) < maxBuyPos || maxBuyPos == 0) && (numberOfPositions(0, openSym) < maxPos || maxPos == 0)  && lastOpenedPosition(1, openSym) < Time[0])
              {
               if(numberOfPositions(0, "") == 0)
                  orderComment += "_fp";
               orderComment += "_ip#" + (string)(numberOfPositions(1, openSym) + 1);
               ResetLastError();
               RefreshRates();
               slPrice = calcSL(1, openSym, Lot);
               tpPrice = calcTP(1, openSym, Lot, slPrice);
               lot = calcLot(1, openSym, slPrice);
               if(ecn_broker)
                 {
                  ticket = OrderSend(openSym, OP_BUY, lot, ask, slp, 0, 0, orderComment, MagicNumber, 0, clrGreen);
                  ticket = OrderModify(ticket, OrderOpenPrice(), slPrice, tpPrice, 0, 0);
                 }
               else
                 {
                  ticket = OrderSend(openSym, OP_BUY, lot, ask, slp, slPrice, tpPrice, orderComment, MagicNumber, 0, clrGreen);
                 }
               if(ticket < 0)
                 {
                  Alert(EAName + ":OrderSend BUY on " + openSym + " failed with error #", GetLastError(),
                        " lot: " + DoubleToString(lot, 2) +
                        " price: " + DoubleToString(ask, dig) +
                        " sl: " + DoubleToString(slPrice, dig) +
                        " tp: " + DoubleToString(tpPrice, dig));
                 }
              }
           }
         if((entryDir == 2 && logic == 0) || (entryDir == 1 && logic == 1))
           {
            if(posDir == 1)
               continue;
            if(numberOfPositions(1, openSym) > 0 && closeAtOpposite)
              {
               closeAll(1, openSym);
              }
            if((numberOfPositions(2, openSym)  < maxSellPos || maxSellPos == 0) && (numberOfPositions(0, openSym) < maxPos || maxPos == 0) && lastOpenedPosition(2, openSym) < Time[0])
              {
               if(numberOfPositions(0, "") == 0)
                  orderComment += "_fp";
               orderComment += "_ip#" + (string)(numberOfPositions(2, openSym) + 1);
               ResetLastError();
               RefreshRates();
               slPrice = calcSL(2, openSym, Lot);
               tpPrice = calcTP(2, openSym, Lot, slPrice);
               lot = calcLot(2, openSym, slPrice);
               if(ecn_broker)
                 {
                  ticket = OrderSend(openSym, OP_SELL, lot, bid, slp, 0, 0, orderComment, MagicNumber, 0, clrRed);
                  ticket = OrderModify(ticket, OrderOpenPrice(), slPrice, tpPrice, 0, 0);
                 }
               else
                 {
                  ticket = OrderSend(openSym, OP_SELL, lot, bid, slp, slPrice, tpPrice, orderComment, MagicNumber, 0, clrRed);
                 }
               if(ticket < 0)
                 {
                  Alert(EAName + ": OrderSend SELL on " + openSym + " failed with error #", GetLastError(),
                        " lot: " + DoubleToString(lot, 2) +
                        " price: " + DoubleToString(bid, dig) +
                        " sl: " + DoubleToString(slPrice, dig) +
                        " tp: " + DoubleToString(tpPrice, dig));
                 }
              }
           }
        }
     }
   if(trailing_sl > 0)
      SetTrailingStop();
   if(be > 0)
      SetBreakeven();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcSL(int dir, string sym, double lot)
  {
   int dig = (int)MarketInfo(sym, MODE_DIGITS);
   double sLevel = MarketInfo(sym, MODE_STOPLEVEL);
   double poi = MarketInfo(sym, MODE_POINT);
   double bid = MarketInfo(sym, MODE_BID);
   double ask = MarketInfo(sym, MODE_ASK);
   double spread = MarketInfo(sym, MODE_SPREAD);
   double tickval = MarketInfo(sym, MODE_TICKVALUE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double val = 0.0;
   int bar = 0;
   double aSpread = 0.0;
   if(addSpread)
     {
      if(dir == 1)
         aSpread = (spread * poi);
      if(dir == 2)
         aSpread = (spread * poi);
     }
   if(SlMode == 1)
     {
      val = MathMax(((SlVal * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask - val, dig);
      if(dir == 2)
         return NormalizeDouble(bid + val, dig);
     }
   if(SlMode == 2)
     {
      val = MathMax((((eq * SlVal * 0.01) * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask - val, dig);
      if(dir == 2)
         return NormalizeDouble(bid + val, dig);
     }
   if(SlMode == 3)
     {
      val = MathMax(SlVal * multi(sym), sLevel + spread + slp) * poi;
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask - val, dig);
      if(dir == 2)
         return NormalizeDouble(bid + val, dig);
     }
   if(SlMode == 4)
     {
      val = SlMin * pip(sym);
      if(dir == 1)
         return NormalizeDouble(MathMin(SlVal, ask - val), dig);
      if(dir == 2)
         return NormalizeDouble(MathMax(SlVal, bid + val), dig);
     }
   if(SlMode == 5)
     {
      val = MathMax(iATR(sym, Period(), (int)SlVal, 1) * SlVal2, (sLevel + spread + slp) * poi);
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask - val, dig);
      if(dir == 2)
         return NormalizeDouble(bid + val, dig);
     }
   if(SlMode == 6)
     {
      if(dir == 1)
        {
         bar = iLowest(sym, Period(), MODE_LOW, (int)SlVal, 0);
         val = MathMin(ask - MathMax((sLevel + spread + slp) * poi, SlMin * pip(sym)), (iLow(sym, Period(), bar) + aSpread) - SlVal2 * pip(sym) - spread * poi);
         return NormalizeDouble(val, dig);
        }
      if(dir == 2)
        {
         bar = iHighest(sym, Period(), MODE_HIGH, (int)SlVal, 0);
         val = MathMax(bid + MathMax((sLevel + spread + slp) * poi, SlMin * pip(sym)), (iHigh(sym, Period(), bar) + aSpread) + SlVal2 * pip(sym) + spread * poi);
         return NormalizeDouble(val, dig);
        }
     }
   if(SlMode == 7)
     {
      val = MathMax((bid * (SlVal / 100)) * pip(sym), sLevel + spread + slp) * poi;
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask - val, dig);
      if(dir == 2)
         return NormalizeDouble(bid + val, dig);
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcTP(int dir, string sym, double lot, double slprice)
  {
   int dig = (int)MarketInfo(sym, MODE_DIGITS);
   double sLevel = MarketInfo(sym, MODE_STOPLEVEL);
   double poi = MarketInfo(sym, MODE_POINT);
   double bid = MarketInfo(sym, MODE_BID);
   double ask = MarketInfo(sym, MODE_ASK);
   double spread = MarketInfo(sym, MODE_SPREAD);
   double tickval = MarketInfo(sym, MODE_TICKVALUE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double val = 0.0;
   double aSpread = 0.0;
   if(addSpread)
     {
      if(dir == 1)
         aSpread = (spread * poi);
      if(dir == 2)
         aSpread = (spread * poi);
     }
   int bar = 0;
   if(TpMode == 1)
     {
      val = MathMax(((TpVal * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
      val = MathMax(TpMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask + val, dig);
      if(dir == 2)
         return NormalizeDouble(bid - val, dig);
     }
   if(TpMode == 2)
     {
      val = MathMax((((eq * TpVal * 0.01) * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
      val = MathMax(TpMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask + val, dig);
      if(dir == 2)
         return NormalizeDouble(bid - val, dig);
     }
   if(TpMode == 3)
     {
      val = MathMax(TpVal * multi(sym), sLevel + spread + slp) * poi;
      val = MathMax(TpMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask + val, dig);
      if(dir == 2)
         return NormalizeDouble(bid - val, dig);
     }
   if(TpMode == 4)
     {
      val = TpMin * pip(sym);
      if(dir == 1)
         return NormalizeDouble(TpVal, dig);
      if(dir == 2)
         return NormalizeDouble(TpVal2, dig);
     }
   if(TpMode == 5)
     {
      val = MathMax(iATR(sym, Period(), (int)TpVal, 1) * TpVal2, (sLevel + spread + slp) * poi);
      val = MathMax(TpMin * pip(sym), val + aSpread);
      if(dir == 1)
         return NormalizeDouble(ask + val, dig);
      if(dir == 2)
         return NormalizeDouble(bid - val, dig);
     }
   if(TpMode == 6)
     {
      if(dir == 1)
        {
         bar = iHighest(sym, Period(), MODE_HIGH, (int)TpVal, 0);
         val = MathMax(ask + MathMax((sLevel + spread + slp) * poi, TpMin * pip(sym)), (iHigh(sym, Period(), bar) + aSpread) + TpVal2 * pip(sym) + spread * poi);
         return NormalizeDouble(val, dig);
        }
      if(dir == 2)
        {
         bar = iLowest(sym, Period(), MODE_LOW, (int)TpVal, 0);
         val = MathMin(bid - MathMax((sLevel + spread + slp) * poi, TpMin * pip(sym)), (iLow(sym, Period(), bar) + aSpread) - TpVal2 * pip(sym) - spread * poi);
         return NormalizeDouble(val, dig);
        }
     }
   if(TpMode == 7)
     {
      val = MathMax((bid * (TpVal / 100)) * pip(sym), sLevel + spread + slp) * poi;
      val = MathMax(TpMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(ask + val, dig);
      if(dir == 2)
         return NormalizeDouble(bid - val, dig);
     }
   if(TpMode == 100 && slprice > 0.0)
     {
      if(dir == 1)
        {
         return NormalizeDouble(ask + (ask - slprice) * TpVal, dig);
        }
      if(dir == 2)
        {
         return NormalizeDouble(bid - (slprice - bid) * TpVal, dig);
        }
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PLOfPositions(int mode, int dir, string sym)
  {
   double countPip = 0.0;
   double countCur = 0.0;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      string ordersym = OrderSymbol();
      string comment = OrderComment();
      if((ordersym == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(OrderType() == OP_BUY)
            if(dir == 1 || dir == 0)
              {
               countPip += (MarketInfo(ordersym, MODE_BID) - OrderOpenPrice()) / pip(ordersym);
               countCur += OrderProfit();
              }
         if(OrderType() == OP_SELL)
            if(dir == 2 || dir == 0)
              {
               countPip += (OrderOpenPrice() - MarketInfo(ordersym, MODE_ASK)) / pip(ordersym);
               countCur += OrderProfit();
              }
        }
     }
   if(mode == 1)
      return countPip;
   if(mode == 2)
      return countCur;
   if(mode == 3 && countCur != 0 && AccountEquity() != 0)
      return 1 / (AccountEquity() * countCur) * 100;
   return countCur;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PLOfPositionsHistory(int mode, int dir, string sym, datetime from)
  {
   double countPip = 0.0;
   double countCur = 0.0;
   for(int pos = OrdersHistoryTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
      string ordersym = OrderSymbol();
      datetime openTime = OrderOpenTime();
      string comment = OrderComment();
      if((ordersym == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && openTime >= from)
        {
         if(OrderType() == OP_BUY)
            if(dir == 1 || dir == 0)
              {
               countPip += (MarketInfo(ordersym, MODE_BID) - OrderOpenPrice()) / pip(ordersym);
               countCur += OrderProfit();
              }
         if(OrderType() == OP_SELL)
            if(dir == 2 || dir == 0)
              {
               countPip += (OrderOpenPrice() - MarketInfo(ordersym, MODE_ASK)) / pip(ordersym);
               countCur += OrderProfit();
              }
        }
     }
   if(mode == 1)
      return countPip;
   if(mode == 2)
      return countCur;
   if(mode == 3 && countCur != 0 && AccountEquity() != 0)
      return 1 / (AccountEquity() * countCur) * 100;
   return countCur;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime findFirstPosDate()
  {
   datetime firstPos = 0;
   int ordPos;
   bool ordSel;
   string ordComment;
   datetime ordOpenTime;
   for(ordPos = OrdersTotal() - 1; ordPos >= 0 ; ordPos--)
     {
      ordSel = OrderSelect(ordPos, SELECT_BY_POS, MODE_TRADES);
      ordComment = OrderComment();
      ordOpenTime = OrderOpenTime();
      if(OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && StringFind(ordComment, "_fp", 0) >= 0)
        {
         return ordOpenTime;
        }
     }
   for(ordPos = OrdersHistoryTotal() - 1; ordPos >= 0 ; ordPos--)
     {
      ordSel = OrderSelect(ordPos, SELECT_BY_POS, MODE_HISTORY);
      ordComment = OrderComment();
      ordOpenTime = OrderOpenTime();
      if(OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && StringFind(ordComment, "_fp", 0) >= 0)
        {
         if(ordOpenTime > firstPos)
            firstPos = ordOpenTime;
        }
     }
   return firstPos;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pip(string sy)
  {
   sy == "" ? sy = Symbol() :;
   double po = MarketInfo(sy, MODE_POINT);
   int di = (int)MarketInfo(sy, MODE_DIGITS);
   if(calcMode == 1)
     {
      return po;
     }
   return (di % 2 == 1 ? po * 10 : po);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int multi(string sy)
  {
   sy == "" ? sy = Symbol() :;
   if(calcMode == 1)
     {
      return 1;
     }
   int di = (int)MarketInfo(sy, MODE_DIGITS);
   return (di % 2 == 1 ? 10 : 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int numberOfPositions(int dir, string sym)
  {
   int countPos = 0;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      if((OrderSymbol() == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && StringFind(OrderComment(), "_ip", 0) >= 0)
        {
         if(StringFind(OrderComment(), "_gr#", 0) >= 0)
            continue;
         if(OrderType() == OP_BUY)
            if(dir == 1 || dir == 0)
               countPos++;
         if(OrderType() == OP_SELL)
            if(dir == 2 || dir == 0)
               countPos++;
        }
     }
   return countPos;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime lastOpenedPosition(int dir, string sym)
  {
   datetime maxDate = 0;
   datetime openDate = 0;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      if((OrderSymbol() == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         openDate = OrderOpenTime();
         if(OrderType() == OP_BUY)
            if(dir == 1 || dir == 0)
               maxDate = MathMax(maxDate, openDate);
         if(OrderType() == OP_SELL)
            if(dir == 2 || dir == 0)
               maxDate = MathMax(maxDate, openDate);
        }
     }
   return maxDate;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime lastDailyClosedPosition(int dir, string sym)
  {
   datetime maxDate = 0;
   datetime closeDate = 0;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
      if((OrderSymbol() == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         closeDate = OrderCloseTime();
         if(OrderType() == OP_BUY && closeDate > iTime(sym, PERIOD_D1, 0))
            if(dir == 1 || dir == 0)
               maxDate = MathMax(maxDate, closeDate);
         if(OrderType() == OP_SELL && closeDate > iTime(sym, PERIOD_D1, 0))
            if(dir == 2 || dir == 0)
               maxDate = MathMax(maxDate, closeDate);
        }
     }
   return maxDate;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAll(int dir, string sym)
  {
   int succ;
   string commentPart = "";
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      string symbol = OrderSymbol();
      RefreshRates();
      ResetLastError();
      if((symbol == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(dir == 0 || (dir == 1 && OrderType() == OP_BUY) || (dir == 2 && OrderType() == OP_SELL))
           {
            succ = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slp, 0);
            if(succ < 0)
              {
               Alert(EAName + ": OrderClose on " + sym + " failed with error #", GetLastError());
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetTrailingStop()
  {
   int  succ;
   string sym, comment;
   double buyTrailingStop, sellTrailingStop;
   for(int pos = OrdersTotal() - 1; pos >= 0; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      if(OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         ResetLastError();
         RefreshRates();
         sym = OrderSymbol();
         comment = OrderComment();
         if(StringFind(comment, "_gr#", 0) >= 0 && trailing_sl < 2)
            continue;
         if(OrderType() == OP_BUY)
           {
            buyTrailingStop = MathMin(MarketInfo(sym, MODE_BID) - trailing_stop_dist * pip(sym), MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_STOPLEVEL) * MarketInfo(sym, MODE_POINT));
            buyTrailingStop = NormalizeDouble(buyTrailingStop, (int)MarketInfo(sym, MODE_DIGITS));
            if(buyTrailingStop - trailing_stop_step * pip(sym) > OrderStopLoss() && MarketInfo(sym, MODE_BID) - OrderOpenPrice() > trailing_stop_start * pip(sym))
              {
               succ = OrderModify(OrderTicket(), OrderOpenPrice(), buyTrailingStop, OrderTakeProfit(), 0);
               if(succ < 0)
                 {
                  Alert(EAName + " (" + OrderSymbol() + " SL_MODIFY): OrderSend on " + sym + " failed with error #", (string)GetLastError());
                 }
              }
           }
         if(OrderType() == OP_SELL)
           {
            sellTrailingStop = MathMax(MarketInfo(sym, MODE_ASK) + trailing_stop_dist * pip(sym), MarketInfo(sym, MODE_ASK) + MarketInfo(sym, MODE_STOPLEVEL) * MarketInfo(sym, MODE_POINT));
            sellTrailingStop = NormalizeDouble(sellTrailingStop, (int)MarketInfo(sym, MODE_DIGITS));
            if(sellTrailingStop + trailing_stop_step * pip(sym) < OrderStopLoss() && OrderOpenPrice() - MarketInfo(sym, MODE_ASK) > trailing_stop_start * pip(sym))
              {
               succ = OrderModify(OrderTicket(), OrderOpenPrice(), sellTrailingStop, OrderTakeProfit(), 0);
               if(succ < 0)
                 {
                  Alert(EAName + " (" + OrderSymbol() + " SL_MODIFY): OrderSend on " + sym + " failed with error #", (string)GetLastError());
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetBreakeven()
  {
   int  succ;
   string sym, comment;
   double buySL, sellSL;
   for(int pos = OrdersTotal() - 1; pos >= 0; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      if(OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         ResetLastError();
         RefreshRates();
         sym = OrderSymbol();
         comment = OrderComment();
         if(StringFind(comment, "_gr#", 0) >= 0 && be < 2)
            continue;
         if(OrderType() == OP_BUY)
           {
            buySL = MathMin(OrderOpenPrice() + be_level * pip(sym), MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_STOPLEVEL) * MarketInfo(sym, MODE_POINT));
            buySL = NormalizeDouble(buySL, (int)MarketInfo(sym, MODE_DIGITS));
            if(buySL > OrderStopLoss() && MarketInfo(sym, MODE_BID) > OrderOpenPrice() + be_trigger * pip(sym))
              {
               succ = OrderModify(OrderTicket(), OrderOpenPrice(), buySL, OrderTakeProfit(), 0);
               if(succ < 0)
                 {
                  Alert(EAName + " (" + OrderSymbol() + " Breakeven): OrderSend on " + sym + " failed with error #", (string)GetLastError());
                 }
              }
           }
         if(OrderType() == OP_SELL)
           {
            sellSL = MathMax(OrderOpenPrice() - be_level * pip(sym), MarketInfo(sym, MODE_ASK) + MarketInfo(sym, MODE_STOPLEVEL) * MarketInfo(sym, MODE_POINT));
            sellSL = NormalizeDouble(sellSL, (int)MarketInfo(sym, MODE_DIGITS));
            if(sellSL < OrderStopLoss() && MarketInfo(sym, MODE_ASK) < OrderOpenPrice() - be_trigger * pip(sym))
              {
               succ = OrderModify(OrderTicket(), OrderOpenPrice(), sellSL, OrderTakeProfit(), 0);
               if(succ < 0)
                 {
                  Alert(EAName + " (" + OrderSymbol() + " Breakeven): OrderSend on " + sym + " failed with error #", (string)GetLastError());
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcLot(int dir, string sym, double priceLotVal)
  {
   double tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double poi = MarketInfo(sym, MODE_POINT);
   double ask =  SymbolInfoDouble(sym, SYMBOL_ASK);
   double bid =  SymbolInfoDouble(sym, SYMBOL_BID);
   double minlot = MarketInfo(sym, MODE_MINLOT);
   double maxlot = MarketInfo(sym, MODE_MAXLOT);
   double marginReq = MarketInfo(sym, MODE_MARGINREQUIRED);
   double maxlotMargin = (AccountEquity() / marginReq) * 0.95;
   double final_lot = minlot;
   double distance = 0.0, risk = 0.0, val = 0.0;
   if(dir == 0)
     {
      final_lot =  priceLotVal;
     }
   if(dir == 1 || dir == 2)
     {
      if(dir == 1)
         distance = (ask - priceLotVal) / poi;
      if(dir == 2)
         distance = (priceLotVal - bid) / poi;
      if(lotMode == 0)
        {
         risk = fabs(Lot);
         final_lot = risk / distance / tickValue;
        }
      if(lotMode == 1)
        {
         risk =  AccountInfoDouble(ACCOUNT_EQUITY) * Lot / 100;
         final_lot = risk / distance / tickValue;
        }
      if(lotMode == 2)
        {
         risk =  AccountInfoDouble(ACCOUNT_BALANCE) * Lot / 100;
         final_lot = risk / distance / tickValue;
        }
      if(lotMode == 3)
        {
         final_lot =  Lot;
        }
      if(lotMode == 4)
        {
         final_lot =  Lot / marginReq;
        }
      if(lotMode == 5)
        {
         final_lot = (AccountInfoDouble(ACCOUNT_EQUITY) * Lot / 100) / marginReq;
        }
     }
   final_lot = MathMin(final_lot, maxLot);
   final_lot = MathMin(final_lot, maxlotMargin);
   final_lot = MathMax(final_lot, minlot);
   final_lot = MathMin(final_lot, maxlot);
   final_lot = MathRound(final_lot / step) * step;
   return final_lot;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int lastLossPosAmount(string sym, datetime from, bool consecutive)
  {
   int count = 0;
   for(int pos = OrdersHistoryTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
      string ordersym = OrderSymbol();
      string comment = OrderComment();
      datetime openTime = OrderOpenTime();
      if(openTime < from)
         break;
      double PL = OrderProfit();
      if(StringFind(comment, "_gr#", 0) >= 0)
         continue;
      if((ordersym == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(PL < 0)
            count++;
         else
           {
            if(consecutive)
               return count;
           }
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int lastWinPosAmount(string sym, datetime from, bool consecutive)
  {
   int count = 0;
   for(int pos = OrdersHistoryTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
      string ordersym = OrderSymbol();
      string comment = OrderComment();
      datetime openTime = OrderOpenTime();
      if(openTime < from)
         break;
      double PL = OrderProfit();
      if(StringFind(comment, "_gr#", 0) >= 0)
         continue;
      if((ordersym == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(PL > 0)
            count++;
         else
           {
            if(consecutive)
               return count;
           }
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int checkEntry(int bar, string sym)
  {
   double buyArr = iCustom(Symbol(), PERIOD_CURRENT, custom_indicator, 0, bar);
   double sellArr = iCustom(Symbol(), PERIOD_CURRENT, custom_indicator, 1, bar);
   int entrySignal = 0;
   if(buyArr > 0.0)
      entrySignal = 1;
   if(sellArr > 0.0)
      entrySignal = 2;
   if(entrySignal == 0)
      return 0;
   if(rsxEntryFilter)
     {
      int rsxSignal = checkRsxSignal();
      if(rsxSignal == 0)
         return entrySignal;
      if(entrySignal == 1 && rsxSignal != 1)
         return 0;
      if(entrySignal == 2 && rsxSignal != 2)
         return 0;
     }
   return entrySignal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int checkExit(int bar, string sym)
  {
   if(whenClose == -1)
      return 0;
   double buyExArr = iCustom(Symbol(), PERIOD_CURRENT, custom_indicator, 2, bar);
   double sellExArr = iCustom(Symbol(), PERIOD_CURRENT, custom_indicator, 3, bar);
   int exitSignal = 0;
   if(buyExArr > 0.0)
      exitSignal = 1;
   if(sellExArr > 0.0)
      exitSignal = 2;
   if(rsxExitFilter)
     {
      int rsxSignal = checkRsxSignal();
      if(rsxSignal == 0)
        {
         return exitSignal;
        }
      if(rsxSignal == 1)
        {
         if(exitSignal == 0)
            exitSignal = 2;
         else
            if(exitSignal == 1)
               exitSignal = 0;
        }
      if(rsxSignal == 2)
        {
         if(exitSignal == 0)
            exitSignal = 1;
         else
            if(exitSignal == 2)
               exitSignal = 0;
        }
     }
   return exitSignal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int checkRsxSignal()
  {
   int maxBars = MathMin(rsxMaxBars, Bars - 1);
   int rsxBar, rsxCheckBar;
   double rsxValue, rsxCheckValue;
   bool hadOverbought, hadOversold;
   for(rsxBar = 0; rsxBar < maxBars; rsxBar++)
     {
      rsxValue = iCustom(Symbol(), PERIOD_CURRENT, "rsx_v3", Length, Price, 0, rsxBar);
      if(rsxValue < levelOs && rsxValue != EMPTY_VALUE)
        {
         hadOverbought = false;
         for(rsxCheckBar = 0; rsxCheckBar < rsxBar; rsxCheckBar++)
           {
            rsxCheckValue = iCustom(Symbol(), PERIOD_CURRENT, "rsx_v3", Length, Price, 0, rsxCheckBar);
            if(rsxCheckValue > levelOb && rsxCheckValue != EMPTY_VALUE)
              {
               hadOverbought = true;
               break;
              }
           }
         if(!hadOverbought)
            return 1;
        }
      if(rsxValue > levelOb && rsxValue != EMPTY_VALUE)
        {
         hadOversold = false;
         for(rsxCheckBar = 0; rsxCheckBar < rsxBar; rsxCheckBar++)
           {
            rsxCheckValue = iCustom(Symbol(), PERIOD_CURRENT, "rsx_v3", Length, Price, 0, rsxCheckBar);
            if(rsxCheckValue < levelOs && rsxCheckValue != EMPTY_VALUE)
              {
               hadOversold = true;
               break;
              }
           }
         if(!hadOversold)
            return 2;
        }
     }
   return 0;
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        [FXI]TrendFinder_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74129&sid=ef53b4c8a4d8b70032c2325fd2fba82f&start=10
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
