
/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        RSIMACD_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161157#p161157
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

#define EANAME "RSIMACD_EA"
int iCustom_handle;
string custom_indicator = "RSIMACD";
input string is = "==========  Entry Settings  =========="; // ==========  Entry Settings  ==========
input int MACD_Fast_EMI = 12;
input int MACD_Slow_EMI = 26;
input int MACD_SMA_Line = 9;
input double RSI_Level_Buy = 10.0;
input double RSI_Level_Sell = 90.0;
#define CUSTOM_INDICATOR_PARAMS MACD_Fast_EMI, MACD_Slow_EMI, MACD_SMA_Line, RSI_Level_Buy, RSI_Level_Sell
#define CUSTOM_INDICATOR_PARAMS2 ""
#define CUSTOM_INDICATOR_PARAMS3 ""
MqlTradeResult result = {};
MqlTradeRequest request = {};
MqlTick p = {};
enum posDirection
  {
   booth = 0,           // Open BUY and SELL positions
   buy = 1,             // Open only BUY position
   sell = 2             // Open only SELL position
  };
enum openPosition
  {
   immediately = 0,     // Immediately
   afterClose = 1       // After candle closed
  };
enum closeAllBy
  {
   off = 0,             // Off
   pipss = 1,             // Pip/point (as set in "Pip/Point Mode" setting)
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
   slPricePercent = 7,                       // Percent of price
   slAbsolute = 4,                           // Absolute Value (for buy = value, for sell = value 2)
   slATR = 5,                                // ATR (period = value, multiplicator = value 2)
   slBars = 6                                // Highest /lowest of (value) bars, +/- (value 2) offset pip/point
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
input string ea = "========== EA Settings =========="; // ========== EA Settings ==========
input string inpEAName = EANAME;             // Custom comment / EA name (max. 16 characters)
string EAName = StringSubstr(inpEAName, 0, 15);
input int slp = 30;                          // Slippage in points
input cMode calcMode = 0;                    // Pip/Point mode (for SL, TP, etc.)
input int MagicNumber = 3535;                // Magic number
input bool ecn_broker = false;               // ECN Broker?
input ENUM_ORDER_TYPE_FILLING OrderFill = 1; // Order filling mode (change if "Unsupported filling mode" error)
input bool alertAlgoOff = true;              // Alert when signal but Algo Trading off
input ENUM_TIMEFRAMES TF = 0;                // Trading timeframe
input openPosition whenOpen = 1;             // Open position at:
input int maxPos = 2;                        // Maximum number of sell-buy positions
input int maxBuyPos = 1;                     // Maximum number of buy positions
input int maxSellPos = 1;                    // Maximum number of sell positions
input posDirection posDir = 0;               // Position direction
input  entlogic entryLogic = 0;              // Entry logic
input bool closeAtOpposite = true;          // Close Position at Opposite Signal
input string ps = "========== Position Size Settings =========="; // ========== Position Size Settings ==========
input lMode lotMode = 3;                     // Lot calculation mode
input double Lot = 0.01;                     // Lot value (as set in "Lot calculation mode")
input double maxLot = 1.00;                  // Maximum size of lots (All positions)
input string sltp = "========== SL / TP Settings =========="; // ========== SL / TP Settings  ==========
input slMode SlMode = 3;                     // SL by
input double SlVal = 40;                     // SL value
input double SlVal2 = 1;                     // SL value 2 (if required in the "SL by" setting
input double SlMin = 10;                     // Min SL distance pip/point (as set in "Pip/Point mode")
input tpMode TpMode = 3;                     // TP by
input double TpVal = 40;                     // TP value
input double TpVal2 = 1;                     // TP value 2 (if required in the "TP by" setting)
input double TpMin = 10;                     // Min TP distance pip/point (as set in "Pip/Point mode")
input bool addSpread = true;                 // Add current spread to SL/TP calculation
input string tsl = "========== Trailing Stop =========="; // ========== Trailing Stop ==========
input trailingAndBe trailing_sl = 0;         // Trailing Stop
input double trailing_stop_dist = 40;        // Trailing Stop Loss
input double trailing_stop_step = 5;         // Trailing Stop Loss Step
input string bev = "========== Breakeven =========="; // ========== Breakeven ==========
input trailingAndBe be = 0;                  // Breakeven
input double be_trigger = 10;                // Beakeven trigger
input double be_level = 0;                   // Breakeven target
bool initOK = true;
string symbols[];

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
      iCustom_handle = iCustom(NULL, 0, custom_indicator, CUSTOM_INDICATOR_PARAMS);
      if(iCustom_handle < 0)
        {
         Alert("Please install the: " + custom_indicator + " indicator to the MQL5/Indicators folder");
         initOK = false;
        }
     }
   if(lotMode < 3 && SlMode < 3)
     {
      Alert("Incompatible \"Lot calculation mode\" and \"Stop loss by\" settings. Please check the dependencies.");
      initOK = false;
     }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
      Alert("Automated trading is disabled in the settings.");
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
void OP(string sym, int entrysig = 0, double lot = 0.0, double price = 0.0, double slPrice = 0.0, double tpPrice = 0.0)
  {
   bool succ, succM = true;
   string orderComment = EAName;
   int multi = multi(sym);
   int dig = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   long sLevel = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   double poi = SymbolInfoDouble(sym, SYMBOL_POINT);
   SymbolInfoTick(sym, p);
   double bid = p.bid;
   double ask = p.ask;
   int entrySignal;
   if(entrysig == 0)
      entrySignal = checkEntry(whenOpen, sym);
   else
      entrySignal = entrysig;
   if((entrySignal > 0 && entryLogic == 0) || (entrySignal < 0 && entryLogic == 1))
     {
      if(alertAlgoOff && !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         Alert(EAName + ": Algo Trading turned OFF");
         return;
        }
      if(posDir == 2)
         return;
      if(numberOfPositions(2, sym) > 0 && closeAtOpposite)
        {
         closeAll(2, sym);
        }
      if(numberOfPositions(1, sym) < maxBuyPos && numberOfPositions(0, sym) < maxPos && lastOpenedPosition(1, sym) < iTime(sym, PERIOD_CURRENT, 0))
        {
         if(numberOfPositions(0, "") == 0)
            orderComment += "_fp";
         orderComment += "_ip(" + (string)entrySignal + ")#" + (string)(numberOfPositions(1, sym) + 1);
         ResetLastError();
         slPrice = calcSL(1, sym, Lot);
         tpPrice = calcTP(1, sym, Lot, slPrice);
         lot = calcLot(1, sym, slPrice);
         if(slPrice != 0.0)
            orderComment += "@" + DoubleToString((price - slPrice) / Point(), 0);
         ZeroMemory(result);
         ZeroMemory(request);
         request.action = TRADE_ACTION_DEAL;
         request.symbol = sym;
         request.type = ORDER_TYPE_BUY;
         request.volume = lot;
         request.price = p.ask;
         request.deviation = slp;
         request.type_filling = OrderFill;
         if(!ecn_broker)
           {
            request.sl = slPrice;
            request.tp = tpPrice;
           }
         request.comment = orderComment;
         request.magic = MagicNumber;
         succ = OrderSend(request, result);
         if(!succ)
           {
            Alert(EAName + ": OrderSend BUY on " + sym + " failed with error #", GetLastError(),
                  " lot: " + DoubleToString(lot, 2) +
                  " price: " + DoubleToString(ask, dig) +
                  " sl: " + DoubleToString(slPrice, dig) +
                  " tp: " + DoubleToString(tpPrice, dig));
           }
         if(succ && ecn_broker)
           {
            ZeroMemory(result);
            ZeroMemory(request);
            request.position = result.order;
            request.sl = slPrice;
            request.tp = tpPrice;
            request.action = TRADE_ACTION_SLTP;
            succM = OrderSend(request, result);
            if(!succM)
              {
               Alert(EAName + " (" + PositionGetString(POSITION_SYMBOL) + " SL_MODIFY): OrderSend on " + sym + " failed with error #", result.retcode);
              }
           }
        }
     }
   if((entrySignal < 0 && entryLogic == 0) || (entrySignal > 0 && entryLogic == 1))
     {
      if(posDir == 1)
         return;
      if(numberOfPositions(1, sym) > 0 && closeAtOpposite)
        {
         closeAll(1, sym);
        }
      if(numberOfPositions(2, sym)  < maxSellPos && numberOfPositions(0, sym)  < maxPos && lastOpenedPosition(2, sym) < iTime(sym, PERIOD_CURRENT, 0))
        {
         if(numberOfPositions(0, "") == 0)
            orderComment += "_fp";
         orderComment += "_ip(" + (string)entrySignal + ")#" + (string)(numberOfPositions(2, sym) + 1);
         ResetLastError();
         slPrice = calcSL(2, sym, Lot);
         tpPrice = calcTP(2, sym, Lot, slPrice);
         lot = calcLot(2, sym, slPrice);
         if(slPrice != 0.0)
            orderComment += "@" + DoubleToString((slPrice - price) / Point(), 0);
         ZeroMemory(result);
         ZeroMemory(request);
         request.action = TRADE_ACTION_DEAL;
         request.symbol = sym;
         request.type = ORDER_TYPE_SELL;
         request.volume = lot;
         request.price = p.bid;
         request.deviation = slp;
         request.type_filling = OrderFill;
         if(!ecn_broker)
           {
            request.sl = slPrice;
            request.tp = tpPrice;
           }
         request.comment = orderComment;
         request.magic = MagicNumber;
         succ = OrderSend(request, result);
         if(!succ)
           {
            Alert(EAName + ": OrderSend SELL on " + sym + " failed with error #", GetLastError(),
                  " lot: " + DoubleToString(lot, 2) +
                  " price: " + DoubleToString(bid, dig) +
                  " sl: " + DoubleToString(slPrice, dig) +
                  " tp: " + DoubleToString(tpPrice, dig));
           }
         if(succ && ecn_broker)
           {
            ZeroMemory(result);
            ZeroMemory(request);
            request.position = result.order;
            request.sl = slPrice;
            request.tp = tpPrice;
            request.action = TRADE_ACTION_SLTP;
            succM = OrderSend(request, result);
            if(!succM)
              {
               Alert(EAName + " (" + PositionGetString(POSITION_SYMBOL) + " SL_MODIFY): OrderSend on " + sym + " failed with error #", result.retcode);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!initOK)
      return;
   double slPrice = 0.0, tpPrice = 0.0;
   bool newBar = IsNewBar();
   bool trade = true;
   if(((whenOpen == 1 && newBar) || whenOpen == 0) && trade)
     {
      for(int i = 0; i < ArraySize(symbols); i++)
        {
         string sym = symbols[i];
         OP(sym);
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
   int dig = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   long sLevel = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   double poi = SymbolInfoDouble(sym, SYMBOL_POINT);
   double bid = p.bid;
   double ask = p.ask;
   long spread = SymbolInfoInteger(sym, SYMBOL_SPREAD);
   double tickval = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
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
      val = MathMax(IATR(sym, Period(), (int)SlVal, 1) * SlVal2, (sLevel + spread + slp) * poi);
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
   int dig = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   long sLevel = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   double poi = SymbolInfoDouble(sym, SYMBOL_POINT);
   double bid = p.bid;
   double ask = p.ask;
   long spread = SymbolInfoInteger(sym, SYMBOL_SPREAD);
   double tickval = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
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
      val = MathMax(IATR(sym, Period(), (int)TpVal, 1) * TpVal2, (sLevel + spread + slp) * poi);
      val = MathMax(TpMin * pip(sym), val) + aSpread;
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
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double countPip = 0.0;
   double countCur = 0.0;
   double price,  profit;
   ulong ticket;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         string comment = PositionGetString(POSITION_COMMENT);
         string ordersym = PositionGetString(POSITION_SYMBOL);
         if((ordersym == sym || sym == "") && PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0)
           {
            SymbolInfoTick(ordersym, p);
            price = PositionGetDouble(POSITION_PRICE_OPEN);
            profit = PositionGetDouble(POSITION_PROFIT);
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               if(dir == 1 || dir == 0)
                 {
                  countPip += (p.bid - price) / pip(ordersym);
                  countCur += profit;
                 }
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               if(dir == 2 || dir == 0)
                 {
                  countPip += (price - p.ask) / pip(ordersym);
                  countCur += profit;
                 }
              }
           }
        }
     }
   if(mode == 1)
      return countPip;
   if(mode == 2)
      return countCur;
   if(mode == 3)
      return 1 / (eq * countCur) * 100;
   return countCur;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long findFirstPosDate()
  {
   long firstPos = 0;
   ulong ticket;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         string comment = PositionGetString(POSITION_COMMENT);
         long openTime = PositionGetInteger(POSITION_TIME);
         if(PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0 && StringFind(comment, "_fp", 0) >= 0)
           {
            return openTime;
           }
        }
     }
   HistorySelect(0, TimeCurrent());
   for(int pos = HistoryDealsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = HistoryDealGetTicket(pos)) > 0)
        {
         HistoryDealSelect(ticket);
         string comment = HistoryDealGetString(ticket, DEAL_COMMENT);
         string ordersym = HistoryDealGetString(ticket, DEAL_SYMBOL);
         long openTime = HistoryDealGetInteger(ticket, DEAL_TIME);
         if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == (int)MagicNumber && MagicNumber > 0 && StringFind(comment, "_fp", 0) >= 0)
           {
            if(openTime > firstPos)
               firstPos = openTime;
           }
        }
     }
   return firstPos;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PLOfPositionsHistory(int mode, int dir, string sym, datetime from)
  {
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double countPip = 0.0;
   double countCur = 0.0;
   double price,  profit;
   ulong ticket;
   HistorySelect(from, TimeCurrent());
   for(int pos = HistoryDealsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = HistoryDealGetTicket(pos)) > 0)
        {
         HistoryDealSelect(ticket);
         string comment = HistoryDealGetString(ticket, DEAL_COMMENT);
         string ordersym = HistoryDealGetString(ticket, DEAL_SYMBOL);
         long openTime = HistoryDealGetInteger(ticket, DEAL_TIME);
         if((ordersym == sym || sym == "") && HistoryDealGetInteger(ticket, DEAL_MAGIC) == (int)MagicNumber && MagicNumber > 0)
           {
            SymbolInfoTick(ordersym, p);
            price = HistoryDealGetDouble(ticket, DEAL_PRICE);
            profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
              {
               if(dir == 1 || dir == 0)
                 {
                  countPip += (p.bid - price) / pip(ordersym);
                  countCur += profit;
                 }
              }
            if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_SELL)
              {
               if(dir == 2 || dir == 0)
                 {
                  countPip += (price - p.ask) / pip(ordersym);
                  countCur += profit;
                 }
              }
           }
        }
     }
   if(mode == 1)
      return countPip;
   if(mode == 2)
      return countCur;
   if(mode == 3)
      return 1 / (eq * countCur) * 100;
   return countCur;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lastLossPosAmount(string sym, datetime from, bool consecutive)
  {
   int count = 0;
   ulong ticket;
   HistorySelect(from, TimeCurrent());
   for(int pos = HistoryDealsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = HistoryDealGetTicket(pos)) > 0)
        {
         HistoryDealSelect(ticket);
         string comment = HistoryDealGetString(ticket, DEAL_COMMENT);
         string ordersym = HistoryDealGetString(ticket, DEAL_SYMBOL);
         long openTime = HistoryDealGetInteger(ticket, DEAL_TIME);
         if(openTime < from)
            break;
         double PL = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         if(StringFind(comment, "_gr#", 0) >= 0)
            continue;
         if((ordersym == sym || sym == "") && HistoryDealGetInteger(ticket, DEAL_MAGIC) == (int)MagicNumber && MagicNumber > 0)
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
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong posTicket(int fp)
  {
   ulong ticket;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         string comment = PositionGetString(POSITION_COMMENT);
         if(PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0 && StringFind(comment, "_ip(" + (string)fp + ")", 0) >= 0)
            return ticket;
        }
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pip(string sym)
  {
   sym == "" ? sym = Symbol() : sym = sym;
   double po = SymbolInfoDouble(sym, SYMBOL_POINT);
   int di = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   if(calcMode == 1)
     {
      return po;
     }
   return (di % 2 == 1 ? po * 10 : po);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int multi(string sym)
  {
   sym == "" ? sym = Symbol() :  sym = sym;
   if(calcMode == 1)
     {
      return 1;
     }
   int di = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
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
int numberOfPositions(int dir, string sym, int fp = 0)
  {
   int countPos = 0;
   ulong ticket;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         string comment = PositionGetString(POSITION_COMMENT);
         PositionSelectByTicket(ticket);
         if((PositionGetString(POSITION_SYMBOL) ==  sym || sym == "") && PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0 &&
            (StringFind(comment, "_ip", 0) >= 0 || StringFind(comment, "from", 0) >= 0))
           {
            if(fp == 0 || StringFind(comment, "_ip(" + (string)fp + ")", 0) >= 0)
              {
               if(StringFind(comment, "_gr#", 0) >= 0)
                  continue;
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                  if(dir == 1 || dir == 0)
                     countPos++;
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                  if(dir == 2 || dir == 0)
                     countPos++;
              }
           }
        }
     }
   return countPos;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long lastOpenedPosition(int dir, string sym, bool hist = false)
  {
   long maxTime = 0;
   long openTime = 0;
   ulong ticket;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         if((PositionGetString(POSITION_SYMBOL) == sym || sym == "") &&
            ((PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0) || MagicNumber == 0))
           {
            openTime = PositionGetInteger(POSITION_TIME);
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               if(dir == 1 || dir == 0)
                  maxTime = MathMax(maxTime, openTime);
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               if(dir == 2 || dir == 0)
                  maxTime = MathMax(maxTime, openTime);
              }
           }
        }
     }
   if(hist)
     {
      HistorySelect(0, TimeCurrent() + 10);
      for(int pos = HistoryDealsTotal() - 1; pos >= 0; pos--)
        {
         if((ticket = HistoryDealGetTicket(pos)) > 0)
           {
            if((HistoryDealGetString(ticket, DEAL_SYMBOL) == sym || sym == "") &&
               ((HistoryDealGetInteger(ticket, DEAL_MAGIC) == (int)MagicNumber && MagicNumber > 0) || MagicNumber == 0) &&
               HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_IN)
              {
               openTime = HistoryDealGetInteger(ticket, DEAL_TIME);
               if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
                 {
                  if(dir == 1 || dir == 0)
                     maxTime = MathMax(maxTime, openTime);
                 }
               if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_SELL)
                 {
                  if(dir == 2 || dir == 0)
                     maxTime = MathMax(maxTime, openTime);
                 }
              }
           }
        }
     }
   return maxTime;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lastOpenedPositionPL(int dir, string sym, bool hist = false)
  {
   long maxTime = 0;
   long openTime = 0;
   ulong ticket;
   double pl = 0.0;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         if((PositionGetString(POSITION_SYMBOL) == sym || sym == "") &&
            ((PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0) || MagicNumber == 0))
           {
            openTime = PositionGetInteger(POSITION_TIME);
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               if(dir == 1 || dir == 0)
                 {
                  if(openTime > maxTime)
                    {
                     maxTime = openTime;
                     pl = PositionGetDouble(POSITION_PROFIT);
                    }
                 }
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               if(dir == 2 || dir == 0)
                 {
                  if(openTime > maxTime)
                    {
                     maxTime = openTime;
                     pl = PositionGetDouble(POSITION_PROFIT);
                    }
                 }
              }
           }
        }
     }
   if(hist)
     {
      HistorySelect(0, TimeCurrent() + 10);
      for(int pos = HistoryDealsTotal() - 1; pos >= 0; pos--)
        {
         if((ticket = HistoryDealGetTicket(pos)) > 0)
           {
            if((HistoryDealGetString(ticket, DEAL_SYMBOL) == sym || sym == "") &&
               ((HistoryDealGetInteger(ticket, DEAL_MAGIC) == (int)MagicNumber && MagicNumber > 0) || MagicNumber == 0) &&
               HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_IN)
              {
               openTime = HistoryDealGetInteger(ticket, DEAL_TIME);
               if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
                 {
                  if(dir == 1 || dir == 0)
                    {
                     if(openTime > maxTime)
                       {
                        maxTime = openTime;
                        pl = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                       }
                    }
                 }
               if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_SELL)
                 {
                  if(dir == 2 || dir == 0)
                    {
                     if(openTime > maxTime)
                       {
                        maxTime = openTime;
                        pl = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                       }
                    }
                 }
              }
           }
        }
     }
   return pl;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAll(int dir, string sym)
  {
   bool succ;
   ulong ticket;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         if((PositionGetString(POSITION_SYMBOL) ==  sym || sym == "") && PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0)
           {
            if(dir == 0 || (dir == 1 && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) || (dir == 2 && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL))
              {
               ResetLastError();
               string ordersym = PositionGetString(POSITION_SYMBOL);
               double vol = PositionGetDouble(POSITION_VOLUME);
               ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               ZeroMemory(result);
               ZeroMemory(request);
               request.position = ticket;
               request.action = TRADE_ACTION_DEAL;
               request.symbol   = ordersym;
               request.volume   = vol;
               request.deviation = slp;
               request.type_filling = OrderFill;
               if(type == POSITION_TYPE_BUY)
                 {
                  request.price = SymbolInfoDouble(sym, SYMBOL_BID);
                  request.type = ORDER_TYPE_SELL;
                 }
               else
                 {
                  request.price = SymbolInfoDouble(sym, SYMBOL_ASK);
                  request.type = ORDER_TYPE_BUY;
                 }
               succ = OrderSend(request, result);
               if(!succ)
                 {
                  Alert(EAName + ": OrderClose on " + sym + " failed with error #", result.retcode);
                 }
               else
                 {
                 }
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
   bool succ;
   string sym, comment;
   double buyTrailingStop, sellTrailingStop;
   long sLevel;
   ulong ticket;
   int dig;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         if(PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0)
           {
            if(StringFind(comment, "_gr#", 0) >= 0 && trailing_sl < 2)
               continue;
            sym = PositionGetString(POSITION_SYMBOL);
            comment = PositionGetString(POSITION_COMMENT);
            sLevel = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
            dig = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
            ResetLastError();
            SymbolInfoTick(sym, p);
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               buyTrailingStop = MathMin(p.bid - trailing_stop_dist * pip(sym), p.bid - sLevel * pip(sym));
               buyTrailingStop = NormalizeDouble(buyTrailingStop, dig);
               if(buyTrailingStop - trailing_stop_step * pip(sym) > PositionGetDouble(POSITION_SL) &&
                  p.bid - PositionGetDouble(POSITION_PRICE_OPEN) > trailing_stop_dist * pip(sym))
                 {
                  ZeroMemory(result);
                  ZeroMemory(request);
                  request.position = ticket;
                  request.sl = buyTrailingStop;
                  request.tp = PositionGetDouble(POSITION_TP);
                  request.action = TRADE_ACTION_SLTP;
                  succ = OrderSend(request, result);
                  if(!succ)
                    {
                     Alert(EAName + " (" + PositionGetString(POSITION_SYMBOL) + " SL_MODIFY): OrderSend on " + sym + " failed with error #", result.retcode);
                    }
                 }
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               sellTrailingStop = MathMax(p.ask + trailing_stop_dist * pip(sym), p.ask + sLevel * pip(sym));
               sellTrailingStop = NormalizeDouble(sellTrailingStop, dig);
               if(sellTrailingStop + trailing_stop_step * pip(sym) < (PositionGetDouble(POSITION_SL) == 0 ? PositionGetDouble(POSITION_PRICE_OPEN) + trailing_stop_dist * pip(sym) : PositionGetDouble(POSITION_SL)) &&
                  PositionGetDouble(POSITION_PRICE_OPEN) - p.ask > trailing_stop_dist * pip(sym))
                 {
                  ZeroMemory(result);
                  ZeroMemory(request);
                  request.position = ticket;
                  request.sl = sellTrailingStop;
                  request.tp = PositionGetDouble(POSITION_TP);
                  request.action = TRADE_ACTION_SLTP;
                  succ = OrderSend(request, result);
                  if(!succ)
                    {
                     Alert(EAName + " (" + PositionGetString(POSITION_SYMBOL) + " SL_MODIFY): OrderSend on " + sym + " failed with error #", result.retcode);
                    }
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
   bool succ;
   string sym, comment;
   double buySL, sellSL;
   long sLevel;
   ulong ticket;
   int dig;
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         if(PositionGetInteger(POSITION_MAGIC) == (int)MagicNumber && MagicNumber > 0)
           {
            if(StringFind(comment, "_gr#", 0) >= 0 && trailing_sl < 2)
               continue;
            sym = PositionGetString(POSITION_SYMBOL);
            comment = PositionGetString(POSITION_COMMENT);
            sLevel = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
            dig = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
            ResetLastError();
            SymbolInfoTick(sym, p);
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               buySL = MathMin(PositionGetDouble(POSITION_PRICE_OPEN) + be_level * pip(sym), p.bid - sLevel * pip(sym));
               buySL = NormalizeDouble(buySL, dig);
               if(buySL > PositionGetDouble(POSITION_SL) && p.bid > PositionGetDouble(POSITION_PRICE_OPEN) + be_trigger * pip(sym))
                 {
                  ZeroMemory(result);
                  ZeroMemory(request);
                  request.position = ticket;
                  request.sl = buySL;
                  request.tp = PositionGetDouble(POSITION_TP);
                  request.action = TRADE_ACTION_SLTP;
                  succ = OrderSend(request, result);
                  if(!succ)
                    {
                     Alert(EAName + " (" + PositionGetString(POSITION_SYMBOL) + " Breakeven): OrderSend on " + sym + " failed with error #", result.retcode);
                    }
                 }
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               sellSL = MathMax(PositionGetDouble(POSITION_PRICE_OPEN) - be_level * pip(sym), p.ask + sLevel * pip(sym));
               sellSL = NormalizeDouble(sellSL, dig);
               if(sellSL < PositionGetDouble(POSITION_SL) && p.ask < PositionGetDouble(POSITION_PRICE_OPEN) - be_trigger * pip(sym))
                 {
                  ZeroMemory(result);
                  ZeroMemory(request);
                  request.position = ticket;
                  request.sl = sellSL;
                  request.tp = PositionGetDouble(POSITION_TP);
                  request.action = TRADE_ACTION_SLTP;
                  succ = OrderSend(request, result);
                  if(!succ)
                    {
                     Alert(EAName + " (" + PositionGetString(POSITION_SYMBOL) + " Breakeven): OrderSend on " + sym + " failed with error #", result.retcode);
                    }
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
   double poi = SymbolInfoDouble(sym, SYMBOL_POINT);
   double ask =  SymbolInfoDouble(sym, SYMBOL_ASK);
   double bid =  SymbolInfoDouble(sym, SYMBOL_BID);
   double minlot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double maxlot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double marginReq;
   bool mr = OrderCalcMargin(dir == 1 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, sym, 1.0, dir == 1 ? ask : bid, marginReq);
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
         final_lot =  Lot / marginReq != 0 ? marginReq : 1;
        }
      if(lotMode == 5)
        {
         final_lot = (AccountInfoDouble(ACCOUNT_EQUITY) * Lot / 100) / marginReq != 0 ? marginReq : 1;
        }
     }
   final_lot = MathMin(final_lot, maxLot);
   final_lot = MathMin(final_lot, marginReq != 0 ? (eq / marginReq) * 0.95 : minlot);
   final_lot = MathMax(final_lot, minlot);
   final_lot = MathMin(final_lot, maxlot);
   final_lot = MathRound(final_lot / step) * step;
   return final_lot;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IMA(string symbol, int tf, int period, int ma_shift, int method, int price, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_MA_METHOD ma_method = MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price = PriceMigrate(price);
   int handle = iMA(symbol, timeframe, period, ma_shift,
                    ma_method, applied_price);
   if(handle < 0)
     {
      Print("The iMA object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IATR(string symbol, int tf, int period, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   int handle = iATR(symbol, timeframe, period);
   if(handle < 0)
      return(-1);
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0:
         return(MODE_SMA);
      case 1:
         return(MODE_EMA);
      case 2:
         return(MODE_SMMA);
      case 3:
         return(MODE_LWMA);
      default:
         return(MODE_SMA);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1:
         return(PRICE_CLOSE);
      case 2:
         return(PRICE_OPEN);
      case 3:
         return(PRICE_HIGH);
      case 4:
         return(PRICE_LOW);
      case 5:
         return(PRICE_MEDIAN);
      case 6:
         return(PRICE_TYPICAL);
      case 7:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double custom_indi_calc(int buffer, int shift)
  {
   double value[1];
   int    copy = CopyBuffer(iCustom_handle, buffer, shift, 1, value);
   if(copy > 0)
     {
      return value[0];
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isVal(double v)
  {
   if(v > 0 && v != EMPTY_VALUE)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int checkEntry(int bar, string sym)
  {
   double val = custom_indi_calc(2, bar);
   if(val == 1)
      return 1;
   if(val == -1)
      return -1;
   return 0;
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        RSIMACD_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161157#p161157
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
