
/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Donchian_and_ZZ_Breakout_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75032&p=161099#p161099
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

#property strict
#define EANAME "DON+ZZ_EA"
string custom_indicator1 = "Donchian";
string custom_indicator2 = "ZigZag_breakout";
enum ENUM_PRICE
  {
   close,               // Close
   median,              // Median
   typical,             // Typical
   weightedClose,       // Weighted Close
   heikenAshiClose,     // Heiken Ashi Close
   heikenAshiMedian,    // Heiken Ashi Median
   heikenAshiTypical,   // Heiken Ashi Typical
   heikenAshiWeighted   // Heiken Ashi Weighted Close
  };
input string is = "==========  Donchian Settings  =========="; // ==========  Donchian Settings  ==========
input string      UniqueName           = "DonchianBrk";
input ENUM_PRICE  Price                = heikenAshiClose;
input int         ChannelPeriod        =        5;
input int         MaxChannelPeriod     =       30;
input double      Margin               =        0;
input double      MinChannelWidth      =       10;
input color       UpTrendColor         = clrDodgerBlue;
input color       DnTrendColor         = clrLightCoral;
input bool        ShowFilledBoxes      =     false;
input bool        ShowChannel          =     true;
input string      AnalysisSets         = "=== Trade Analysis ===";
input bool        ShowAnalysis         =     false;
input bool        ShowStatsComment     =     false;
input bool        ShowArrows           =     true;
input bool        ShowProfit           =     false;
input bool        ShowExits            =     false;
input color       WinColor             = clrLimeGreen;
input color       LossColor            = clrTomato;
input string is2 = "==========  ZZ Settings  =========="; // ==========  ZZ Settings  ==========
input int         ExtDepth            =        12;
input int         ExtDeviation        =        5;
input int         ExtBackstep         =        3;
input bool        SetTPByZZ           =     true; // Set TP by ZZ levels if possible else use TP settings
#define CUSTOM_INDICATOR_PARAMS1 UniqueName, Price, ChannelPeriod, MaxChannelPeriod, Margin, MinChannelWidth, UpTrendColor, DnTrendColor, ShowFilledBoxes, ShowChannel
#define CUSTOM_INDICATOR_PARAMS2 ExtDepth, ExtDeviation, ExtBackstep
#define CUSTOM_INDICATOR_PARAMS3 ""
#define CUSTOM_INDICATOR_PARAMS4 ""
enum cOpposite
  {
   oppc0 = 0,           // false
   oppc1 = 1            // true
  };
enum eOpposite
  {
   oppe0 = 0,           // false
   oppe1 = 1            // true
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
enum partialClose
  {
   disabledPC = 0,                             // Off
   normalPC = 1                                // On
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
enum ModeEntry
  {
   Market,
   Pending
  };
enum pendingEntryPrice
  {
   prevCandle,                               // Previous candle High/Low
   bidAsk,                                   // Current Bid/Ask
   indicator                                 // From indicator
  };
enum PendingExpiry
  {
   peOff,                                    // Off
   candles,                                  // By candles
   minutes,                                  // By minutes
   dayEnd                                    // End of the day
  };
input string ea = "==========  EA Settings  =========="; // ==========  EA Settings  ==========
input string inpEAName = EANAME;             // Custom comment / EA name (max. 10 characters)
string EAName = StringSubstr(inpEAName, 0, 9);
input int slp = 30;                          // Slippage in points
input cMode calcMode = 0;                    // Pip/Point mode (for SL, TP, etc.)
input int MagicNumber = 3535;                // Magic number
input bool ecn_broker = false;               // ECN Broker?
input bool alertAlgoOff = true;              // Alert when signal but Auto Trading off
int whenOpen = 1;
int posDir = 0;
input cOpposite closeAtOpposite = true;           // Close position at opposite signal
input string pm = "==========  Pending / Market Setup  =========="; // ==========  Pending / Market Setup  ==========
input ModeEntry modeEntry = Market;          // Entry mode
input pendingEntryPrice entryPrice = bidAsk; // Entry distance from
input double entryDistance = 10;             // Distance (as set in "Pip/Point mode") for pending orders
input PendingExpiry pendingExpiry = minutes; // Pending order expiry
input int expiryVal = 60;                    // Pending order expiry value (candles or minutes)
input bool deletePendingOnCloseAll = true;   // Delete pendings when close all
int maxPos = 2;
int maxSellPos = 1;
int maxBuyPos = 1;
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
input string gc = "==========  Global Close  =========="; // ==========  Global Close  ==========
input globalPL globalCalcMode = 2;           // Global Close calculate with the following positions
input closeAllBy profit_target_mode = 0;     // Use Global Take Profit by
input double profit_target =   50.0;         // Target of global Take Profit
input closeAllBy dd_target_mode = 0;         // Use Global Stop Loss by
input double dd_target =   50.0;             // Target of global Stop Loss
input string mg1 = "==========  Martingale on Closed Positions  =========="; // ==========  Martingale on Closed Positions  ==========
input bool martinOnC = false;                 // Use Martingale on closed positions
input bool dailyResetC = false;               // Daily reset
input int martinMaxC = 5;                     // Max attempts
input double martinLotMultipleC = 2.0;        // Multiple
input double martinMaxlotC = 10;              // Max lot per symbol
input string mg2 = "==========  Martingale on Running Positions  =========="; // ==========  Martingale on Running Positions  ==========
input bool martinOnR = false;                 // Use Martingale on running positions
input bool martinDir = true;                  // Separate lot calculation for each directions
input int martinMaxR = 5;                     // Max attempts
input double martinLotMultipleR = 2.0;        // Multiple
input double martinMaxlotR = 10;              // Max lot per symbol
input string al = "==========  Alert Settings  =========="; // "==========  Alert Settings  ==========
input bool notifications         = false;    // Notifications On
input bool desktop_notifications = false;    // Desktop MT4 Notifications
input bool email_notifications   = false;    // Email Notifications
input bool push_notifications    = false;    // Push Mobile Notifications
bool initOK = true;
string symbols[];
#define MT4_WMCMD_EXPERTS 33020

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
      Alert("Automated trading is disabled in the settings.");
   EAName = StringSubstr(inpEAName, 0, 16);
   ArrayResize(symbols, 1);
   symbols[0] = Symbol();
   ResetLastError();
   if(custom_indicator1 != "")
     {
      double temp = iCustom(NULL, 0, custom_indicator1, CUSTOM_INDICATOR_PARAMS1, 0, 0);
      if(GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
        {
         Alert("Please install the: " + custom_indicator1 + " indicator to the MQL4/Indicators folder");
         initOK = false;
        }
     }
   ResetLastError();
   if(custom_indicator2 != "")
     {
      double temp = iCustom(NULL, 0, custom_indicator2, CUSTOM_INDICATOR_PARAMS2, 0, 0);
      if(GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
        {
         Alert("Please install the: " + custom_indicator2 + " indicator to the MQL4/Indicators folder");
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
void OP(string sym, int entrysig = 0, double lot = 0.0, double price = 0.0, double slPrice = 0.0, double tpPrice = 0.0)
  {
   if(!trade)
      return;
   int logic = 0;
   long expDate = 0;
   if(pendingExpiry == minutes)
      expDate = TimeCurrent() + expiryVal * 60;
   if(pendingExpiry == candles)
      expDate = TimeCurrent() + expiryVal * PeriodSeconds();
   if(pendingExpiry == dayEnd)
      expDate = iTime(Symbol(), PERIOD_D1, 0) + 1439 * 60;
   int ticket = 0;
   string orderComment = EAName;
   int multi = multi(sym);
   int dig = (int)MarketInfo(sym, MODE_DIGITS);
   double sLevel = MarketInfo(sym, MODE_STOPLEVEL);
   double poi = MarketInfo(sym, MODE_POINT);
   double bid = MarketInfo(sym, MODE_BID);
   double ask = MarketInfo(sym, MODE_ASK);
   double spread = MarketInfo(sym, MODE_SPREAD);
   int entrySignal;
   if(entrysig == 0)
      entrySignal = checkEntry(whenOpen, sym);
   else
      entrySignal = entrysig;
   if((entrySignal > 0 && logic == 0) || (entrySignal < 0 && logic == 1))
     {
      if(alertAlgoOff && !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
         Alert(EAName + ": Auto Trading turned OFF");
      if(posDir == 2)
         return;
      if(numberOfPositions(2, sym, entrySignal * (-1)) > 0 && closeAtOpposite == 2)
         closeAll(2, sym, entrysig * (-1));
      if(closeAtOpposite == 1)
         closeAll(2, sym);
      if((numberOfPositions(1, sym) < maxBuyPos || maxBuyPos == 0) &&
         (numberOfPositions(0, sym) < maxPos || maxPos == 0)  && lastOpenedPosition(1, sym) < Time[0])
        {
         if(numberOfPositions(0, "") == 0)
            orderComment += "_fp";
         orderComment += "_ip(" + (string)entrySignal + ")#" + (string)(numberOfPositions(1, sym) + 1);
         ResetLastError();
         RefreshRates();
         if(modeEntry == Market)
            price = ask;
         if(modeEntry == Pending && entryPrice == prevCandle)
            price = MathMax(High[1] + entryDistance * pip(sym), ask + sLevel * poi);
         if(modeEntry == Pending && entryPrice == bidAsk)
            price = MathMax(ask + entryDistance * pip(sym), ask + sLevel * poi);
         if(modeEntry == Pending && entryPrice == indicator)
            price = price > ask - sLevel * poi && price < ask + sLevel * poi ? ask + sLevel * poi : price;
         if(slPrice == 0.0)
            slPrice = calcSL(1, price, sym, Lot);
         else
            slPrice = NormalizeDouble(MathMin(slPrice, ask - sLevel * poi), Digits());
         if(tpPrice == 0.0)
            tpPrice = calcTP(1, price, sym, Lot, slPrice);
         else
            tpPrice = NormalizeDouble(MathMax(tpPrice, ask + sLevel * poi), Digits());
         if(lot == 0.0)
            lot = calcLot(1, sym, slPrice);
         else
            lot = calcLot(0, sym, lot);
         price = NormalizeDouble(price, Digits());
         if(slPrice != 0.0)
            orderComment += "@" + DoubleToString((price - slPrice) / Point(), 0);
         if(modeEntry == Market)
           {
            if(ecn_broker)
              {
               ticket = OrderSend(sym, OP_BUY, lot, price, slp, 0, 0, orderComment, MagicNumber, 0, clrGreen);
               ticket = OrderModify(ticket, OrderOpenPrice(), slPrice, tpPrice, 0, 0);
              }
            else
              {
               ticket = OrderSend(sym, OP_BUY, lot, price, slp, slPrice, tpPrice, orderComment, MagicNumber, 0, clrGreen);
              }
           }
         if(modeEntry == Pending && price != 0)
           {
            ticket = OrderSend(sym, Ask > price ? OP_BUYLIMIT : OP_BUYSTOP, lot, price, slp, slPrice, tpPrice,
                               orderComment, MagicNumber, expDate, clrGreen);
           }
         if(ticket < 0)
           {
            Alert(EAName + ":OrderSend PENDING BUY on " + sym + " failed with error #", GetLastError(),
                  " lot: " + DoubleToString(lot, 2) +
                  " price: " + DoubleToString(ask, dig) +
                  " sl: " + DoubleToString(slPrice, dig) +
                  " tp: " + DoubleToString(tpPrice, dig));
           }
         else
           {
            Notifications(1, sym, ask, slPrice, tpPrice, orderComment);
           }
        }
     }
   if((entrySignal < 0 && logic == 0) || (entrySignal > 0 && logic == 1))
     {
      if(posDir == 1)
         return;
      if(numberOfPositions(1, sym, entrySignal * (-1)) > 0 && closeAtOpposite == 2)
         closeAll(1, sym, entrysig * (-1));
      if(closeAtOpposite == 1)
         closeAll(1, sym);
      if((numberOfPositions(2, sym)  < maxSellPos || maxSellPos == 0) &&
         (numberOfPositions(0, sym) < maxPos || maxPos == 0) && lastOpenedPosition(2, sym) < Time[0])
        {
         if(numberOfPositions(0, "") == 0)
            orderComment += "_fp";
         orderComment += "_ip(" + (string)entrySignal + ")#" + (string)(numberOfPositions(2, sym) + 1);
         ResetLastError();
         RefreshRates();
         if(modeEntry == Market)
            price = bid;
         if(modeEntry == Pending && entryPrice == prevCandle)
            price = MathMin(Low[1] - entryDistance * pip(sym), bid - sLevel * poi);
         if(modeEntry == Pending && entryPrice == bidAsk)
            price = MathMin(bid - entryDistance * pip(sym), bid - sLevel * poi);
         if(modeEntry == Pending && entryPrice == indicator)
            price = price > bid - sLevel * poi && price < bid + sLevel * poi ? bid - sLevel * poi : price;
         if(slPrice == 0.0)
            slPrice = calcSL(2, price, sym, Lot);
         else
            slPrice = NormalizeDouble(MathMax(slPrice, bid + sLevel * poi), Digits());
         if(tpPrice == 0.0)
            tpPrice = calcTP(2, price, sym, Lot, slPrice);
         else
            tpPrice = NormalizeDouble(MathMin(tpPrice, bid - sLevel * poi), Digits());
         if(lot == 0.0)
            lot = calcLot(2, sym, slPrice);
         else
            lot = calcLot(0, sym, lot);
         price = NormalizeDouble(price, Digits());
         if(slPrice != 0.0)
            orderComment += "@" + DoubleToString((slPrice - price) / Point(), 0);
         if(modeEntry == Market)
           {
            if(ecn_broker)
              {
               ticket = OrderSend(sym, OP_SELL, lot, price, slp, 0, 0, orderComment, MagicNumber, 0, clrRed);
               ticket = OrderModify(ticket, OrderOpenPrice(), slPrice, tpPrice, 0, 0);
              }
            else
              {
               ticket = OrderSend(sym, OP_SELL, lot, price, slp, slPrice, tpPrice, orderComment, MagicNumber, 0, clrRed);
              }
           }
         if(modeEntry == Pending && price != 0)
           {
            ticket = OrderSend(sym, Bid < price ? OP_SELLLIMIT : OP_SELLSTOP, lot, price, slp, slPrice, tpPrice,
                               orderComment, MagicNumber, expDate, clrRed);
           }
         if(ticket < 0)
           {
            Alert(EAName + ": OrderSend SELL on " + sym + " failed with error #", GetLastError(),
                  " lot: " + DoubleToString(lot, 2) +
                  " price: " + DoubleToString(bid, dig) +
                  " sl: " + DoubleToString(slPrice, dig) +
                  " tp: " + DoubleToString(tpPrice, dig));
           }
         else
           {
            Notifications(2, sym, bid, slPrice, tpPrice, orderComment);
           }
        }
     }
  }
bool trade = true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!initOK)
      return;
   bool newBar = IsNewBar();
   int whenClose = 1;
   if((whenOpen > 0 && newBar) || (whenOpen == 0))
     {
      for(int i = 0; i < ArraySize(symbols); i++)
        {
         string sym = symbols[i];
         if(posLastOpened(sym) < Time[0])
            OP(sym);
        }
     }
   if(trailing_sl > 0)
      SetTrailingStop();
   if(be > 0)
      SetBreakeven();
   if(profit_target_mode > 0)
     {
      double global_tp = PLOfPositions(profit_target_mode, 0, "");
      if(globalCalcMode > 1)
         global_tp += PLOfPositionsHistory(profit_target_mode, 0, "", findFirstPosDate());
      if(global_tp > profit_target)
         closeAll(0, "");
     }
   if(dd_target_mode > 0)
     {
      double global_dd = PLOfPositions(dd_target_mode, 0, "");
      if(globalCalcMode > 1)
         global_dd += PLOfPositionsHistory(dd_target_mode, 0, "", findFirstPosDate());
      if(global_dd < dd_target * (-1))
         closeAll(0, "");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcSL(int dir, double p, string sym, double lot)
  {
   int dig = (int)MarketInfo(sym, MODE_DIGITS);
   double sLevel = MarketInfo(sym, MODE_STOPLEVEL);
   double poi = MarketInfo(sym, MODE_POINT);
   double spread = MarketInfo(sym, MODE_SPREAD);
   double tickval = MarketInfo(sym, MODE_TICKVALUE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double val = 0.0;
   int bar = 0;
   double aSpread = 0.0;
   if(addSpread)
      aSpread = (spread * poi);
   if(SlMode == 1)
     {
      val = MathMax(((SlVal * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p - val, dig);
      if(dir == 2)
         return NormalizeDouble(p + val, dig);
     }
   if(SlMode == 2)
     {
      val = MathMax((((eq * SlVal * 0.01) * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p - val, dig);
      if(dir == 2)
         return NormalizeDouble(p + val, dig);
     }
   if(SlMode == 3)
     {
      val = MathMax(SlVal * multi(sym), sLevel + spread + slp) * poi;
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p - val, dig);
      if(dir == 2)
         return NormalizeDouble(p + val, dig);
     }
   if(SlMode == 4)
     {
      val = SlMin * pip(sym);
      if(dir == 1)
         return NormalizeDouble(MathMin(SlVal, p - val), dig);
      if(dir == 2)
         return NormalizeDouble(MathMax(SlVal, p + val), dig);
     }
   if(SlMode == 5)
     {
      val = MathMax(iATR(sym, Period(), (int)SlVal, 1) * SlVal2, (sLevel + spread + slp) * poi);
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p - val, dig);
      if(dir == 2)
         return NormalizeDouble(p + val, dig);
     }
   if(SlMode == 6)
     {
      if(dir == 1)
        {
         bar = iLowest(sym, Period(), MODE_LOW, (int)SlVal, 0);
         val = MathMin(p - MathMax((sLevel + spread + slp) * poi, SlMin * pip(sym)), (iLow(sym, Period(), bar) + aSpread) - SlVal2 * pip(sym) - spread * poi);
         return NormalizeDouble(val, dig);
        }
      if(dir == 2)
        {
         bar = iHighest(sym, Period(), MODE_HIGH, (int)SlVal, 0);
         val = MathMax(p + MathMax((sLevel + spread + slp) * poi, SlMin * pip(sym)), (iHigh(sym, Period(), bar) + aSpread) + SlVal2 * pip(sym) + spread * poi);
         return NormalizeDouble(val, dig);
        }
     }
   if(SlMode == 7)
     {
      val = MathMax((p * (SlVal / 100)) * pip(sym), sLevel + spread + slp) * poi;
      val = MathMax(SlMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p - val, dig);
      if(dir == 2)
         return NormalizeDouble(p + val, dig);
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcTP(int dir, double p, string sym, double lot, double slprice)
  {
   int dig = (int)MarketInfo(sym, MODE_DIGITS);
   double sLevel = MarketInfo(sym, MODE_STOPLEVEL);
   double poi = MarketInfo(sym, MODE_POINT);
   double spread = MarketInfo(sym, MODE_SPREAD);
   double tickval = MarketInfo(sym, MODE_TICKVALUE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double val = 0.0;
   double aSpread = 0.0;
   if(addSpread)
      aSpread = (spread * poi);
   int bar = 0;
   if(TpMode == 1)
     {
      val = MathMax(((TpVal * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
      val = MathMax(TpMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p + val, dig);
      if(dir == 2)
         return NormalizeDouble(p - val, dig);
     }
   if(TpMode == 2)
     {
      val = MathMax((((eq * TpVal * 0.01) * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
      val = MathMax(TpMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p + val, dig);
      if(dir == 2)
         return NormalizeDouble(p - val, dig);
     }
   if(TpMode == 3)
     {
      val = MathMax(TpVal * multi(sym), sLevel + spread + slp) * poi;
      val = MathMax(TpMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p + val, dig);
      if(dir == 2)
         return NormalizeDouble(p - val, dig);
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
         return NormalizeDouble(p + val, dig);
      if(dir == 2)
         return NormalizeDouble(p - val, dig);
     }
   if(TpMode == 6)
     {
      if(dir == 1)
        {
         bar = iHighest(sym, Period(), MODE_HIGH, (int)TpVal, 0);
         val = MathMax(p + MathMax((sLevel + spread + slp) * poi, TpMin * pip(sym)), (iHigh(sym, Period(), bar) + aSpread) + TpVal2 * pip(sym) + spread * poi);
         return NormalizeDouble(val, dig);
        }
      if(dir == 2)
        {
         bar = iLowest(sym, Period(), MODE_LOW, (int)TpVal, 0);
         val = MathMin(p - MathMax((sLevel + spread + slp) * poi, TpMin * pip(sym)), (iLow(sym, Period(), bar) + aSpread) - TpVal2 * pip(sym) - spread * poi);
         return NormalizeDouble(val, dig);
        }
     }
   if(TpMode == 7)
     {
      val = MathMax((p * (TpVal / 100)) * pip(sym), sLevel + spread + slp) * poi;
      val = MathMax(TpMin * pip(sym), val) + aSpread;
      if(dir == 1)
         return NormalizeDouble(p + val, dig);
      if(dir == 2)
         return NormalizeDouble(p - val, dig);
     }
   if(TpMode == 100 && slprice > 0.0)
     {
      if(dir == 1)
        {
         return NormalizeDouble(p + (p - slprice) * TpVal, dig);
        }
      if(dir == 2)
        {
         return NormalizeDouble(p - (slprice - p) * TpVal, dig);
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
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      string comment = OrderComment();
      datetime openTime = OrderOpenTime();
      if(OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && StringFind(comment, "_fp", 0) >= 0)
        {
         return openTime;
        }
     }
   for(int pos = OrdersHistoryTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
      string comment = OrderComment();
      datetime openTime = OrderOpenTime();
      if(OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && StringFind(comment, "_fp", 0) >= 0)
        {
         if(openTime > firstPos)
            firstPos = openTime;
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
bool IsNewDay()
  {
   static datetime lastday;
   datetime curday = (datetime)iTime(Symbol(), PERIOD_D1, 0);
   if(lastday != curday)
     {
      lastday = curday;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void alertMessage(string msg)
  {
   if(msg == "")
     {
      ObjectDelete(0, EAName + "_message");
      return;
     }
   ObjectCreate(0, EAName + "_message", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, EAName + "_message", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, EAName + "_message", OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0, EAName + "_message", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, EAName + "_message", OBJPROP_YDISTANCE, 20);
   ObjectSetInteger(0, EAName + "_message", OBJPROP_BACK, false);
   ObjectSetString(0, EAName + "_message", OBJPROP_TEXT, msg);
   ObjectSetString(0, EAName + "_message", OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, EAName + "_message", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, EAName + "_message", OBJPROP_FONTSIZE, 20);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime posLastOpened(string sym, int fp = 0, int dir = 0)
  {
   datetime maxDate = 0;
   datetime openDate = 0;
   for(int pos = OrdersTotal() - 1; pos >= 0; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      ulong ticket = OrderTicket();
      string comment = OrderComment();
      openDate = OrderOpenTime();
      if(OrderSymbol() == sym && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && StringFind(comment, "_ip(", 0) >= 0)
        {
         if(dir == 0 || (dir == 1 && OrderType() == OP_BUY) || (dir == 2 && OrderType() == OP_SELL))
            if(fp == 0 || StringFind(comment, "_ip(" + (string)fp + ")", 0) >= 0)
               maxDate = MathMax(maxDate, openDate);
        }
     }
   for(int pos = OrdersHistoryTotal() - 1; pos >= 0; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
      ulong ticket = OrderTicket();
      string comment = OrderComment();
      openDate = OrderOpenTime();
      if(dir == 0 || (dir == 1 && OrderType() == OP_BUY) || (dir == 2 && OrderType() == OP_SELL))
         if(fp == 0 || StringFind(comment, "_ip(" + (string)fp + ")", 0) >= 0)
            maxDate = MathMax(maxDate, openDate);
     }
   return maxDate;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int numberOfPositions(int dir, string sym, int fp = 0, bool pending = false)
  {
   int countPos = 0;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      string comment = OrderComment();
      if((OrderSymbol() == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && (StringFind(comment, "_ip", 0) >= 0 || StringFind(comment, "from", 0) >= 0))
        {
         if(StringFind(comment, "_gr#", 0) >= 0)
            continue;
         if(fp == 0 || StringFind(comment, "_ip(" + (string)fp + ")", 0) >= 0)
           {
            if(OrderType() == OP_BUY)
               if(dir == 1 || dir == 0)
                  countPos++;
            if(OrderType() == OP_SELL)
               if(dir == 2 || dir == 0)
                  countPos++;
            if(pending)
              {
               if(OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)
                  if(dir == 1 || dir == 0)
                     countPos++;
               if(OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
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
double lastOpenedPositionPL(int dir, string sym, bool hist = false)
  {
   datetime maxDate  = 0;
   datetime openDate = 0;
   double   pl       = 0.0;
   bool s;
   for(int pos = OrdersTotal() - 1; pos >= 0; pos--)
     {
      s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      if((OrderSymbol() == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         openDate = OrderOpenTime();
         if(OrderType() == OP_BUY)
           {
            if(dir == 1 || dir == 0)
              {
               if(openDate > maxDate)
                 {
                  maxDate = openDate;
                  pl      = OrderProfit();
                 }
              }
           }
         if(OrderType() == OP_SELL)
           {
            if(dir == 2 || dir == 0)
              {
               if(openDate > maxDate)
                 {
                  maxDate = openDate;
                  pl      = OrderProfit();
                 }
              }
           }
        }
     }
   if(hist)
     {
      for(int pos = OrdersHistoryTotal() - 1; pos >= 0; pos--)
        {
         s = OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
         if((OrderSymbol() == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
           {
            openDate = OrderOpenTime();
            if(OrderType() == OP_BUY)
              {
               if(dir == 1 || dir == 0)
                 {
                  if(openDate > maxDate)
                    {
                     maxDate = openDate;
                     pl      = OrderProfit();
                    }
                 }
              }
            if(OrderType() == OP_SELL)
              {
               if(dir == 2 || dir == 0)
                 {
                  if(openDate > maxDate)
                    {
                     maxDate = openDate;
                     pl      = OrderProfit();
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
datetime lastOpenedPosition(int dir, string sym, bool hist = false)
  {
   datetime maxDate  = 0;
   datetime openDate = 0;
   bool s;
   for(int pos = OrdersTotal() - 1; pos >= 0; pos--)
     {
      s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
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
   if(hist)
     {
      for(int pos = OrdersHistoryTotal() - 1; pos >= 0; pos--)
        {
         s = OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY);
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
void closeAll(int dir, string sym, int fp = 0)
  {
   int succ;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      string symbol = OrderSymbol();
      string comment = OrderComment();
      RefreshRates();
      ResetLastError();
      if((symbol == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(dir == 0 || (dir == 1 && OrderType() == OP_BUY) || (dir == 2 && OrderType() == OP_SELL))
           {
            if(fp == 0 || StringFind(comment, "_ip(" + (string)fp + ")", 0) >= 0)
              {
               succ = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slp, 0);
               if(succ < 0)
                 {
                  Alert(EAName + ": OrderClose on " + sym + " failed with error #", GetLastError());
                 }
               else
                 {
                  Notifications(3, sym, OrderClosePrice(), OrderStopLoss(), OrderTakeProfit(), OrderComment());
                 }
              }
           }
        }
      if(deletePendingOnCloseAll)
         closeAllPending(dir, sym);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllPending(int dir, string sym, int fp = 0)
  {
   int succ;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      string symbol = OrderSymbol();
      string comment = OrderComment();
      RefreshRates();
      ResetLastError();
      if((symbol == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(dir == 0 ||
            (dir == 1 && (OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)) ||
            (dir == 2 && (OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT)))
           {
            if(fp == 0 || StringFind(comment, "_ip(" + (string)fp + ")", 0) >= 0)
              {
               succ = OrderDelete(OrderTicket(), 0);
               if(succ < 0)
                 {
                  Alert(EAName + ": OrderDelete on " + sym + " failed with error #", GetLastError());
                 }
               else
                 {
                  Notifications(4, sym, OrderClosePrice(), OrderStopLoss(), OrderTakeProfit(), OrderComment());
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
            if(sellTrailingStop + trailing_stop_step * pip(sym) < (OrderStopLoss() == 0 ? OrderOpenPrice() + trailing_stop_dist * pip(sym) : OrderStopLoss()) &&
               OrderOpenPrice() - MarketInfo(sym, MODE_ASK) > trailing_stop_start * pip(sym))
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
void Notifications(int type, string sym, double price, double stoploss, double takeprofit, string comment)
  {
   string text = EAName + ": ";
   if(type == 1)
      text += sym + " " + GetTimeFrame(_Period) + " BUY (price: " + (string)price + " sl: " + (string)stoploss + " tp: " + (string)takeprofit + " comment: " + comment + ")";
   if(type == 2)
      text += sym + " " + GetTimeFrame(_Period) + " SELL (price: " + (string)price + " sl: " + (string)stoploss + " tp: " + (string)takeprofit + " comment: " + comment + ")";
   if(type == 3)
      text += sym + " " + GetTimeFrame(_Period) + " CLOSE (price: " + (string)price + " sl: " + (string)stoploss + " tp: " + (string)takeprofit + " comment: " + comment + ")";
   if(type == 4)
      text += sym + " " + GetTimeFrame(_Period) + " DELETE (price: " + (string)price + " sl: " + (string)stoploss + " tp: " + (string)takeprofit + " comment: " + comment + ")";
   if(!notifications)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
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
   double marginReq = MathMax(MarketInfo(sym, MODE_MARGINREQUIRED), 0.001);
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
   if(martinOnC)
     {
      double mc = lastLossPosAmount(sym, dailyResetC ? iTime(sym, PERIOD_D1, 0) : 0, true);
      final_lot = MathMin(final_lot * MathPow(martinLotMultipleC, MathMin(mc, martinMaxC)), martinMaxlotC);
     }
   if(martinOnR)
     {
      double mr = numberOfPositions(martinDir ? dir : 0, sym);
      final_lot = MathMin(final_lot * MathPow(martinLotMultipleR, MathMin(mr, martinMaxR)), martinMaxlotR);
     }
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
      if((ordersym == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && OrderType() < 2)
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
      if((ordersym == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && OrderType() < 2)
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
bool posOpenPrice(int fp, string sym, double p)
  {
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      double oprice = OrderOpenPrice();
      string comment = OrderComment();
      if(OrderSymbol() == sym && p == oprice && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0 && (StringFind(comment, "_ip(" + (string)fp + ")", 0) >= 0 || fp == 0))
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int checkEntry(int bar, string sym)
  {
   double upZZ = 0.0, dnZZ = 0.0;
   double arrUp = iCustom(sym, Period(), custom_indicator1, CUSTOM_INDICATOR_PARAMS1, 0, bar);
   double arrDn = iCustom(sym, Period(), custom_indicator1, CUSTOM_INDICATOR_PARAMS1, 1, bar);
   if(SetTPByZZ)
     {
      upZZ = iCustom(sym, Period(), custom_indicator2, CUSTOM_INDICATOR_PARAMS2, 0, bar);
      dnZZ = iCustom(sym, Period(), custom_indicator2, CUSTOM_INDICATOR_PARAMS2, 1, bar);
     }
   ChartRedraw();
   if(SetTPByZZ)
     {
      if(arrUp > 0 && arrUp != EMPTY_VALUE && numberOfPositions(1, sym) < maxBuyPos && maxBuyPos != 0 && numberOfPositions(0, sym) < maxPos && maxPos != 0)
        {
         if(upZZ > Close[bar])
            OP(sym, 1, 0, 0, 0, upZZ);
         else
            OP(sym, 1);
        }
      if(arrDn > 0 && arrDn != EMPTY_VALUE && numberOfPositions(2, sym) < maxSellPos && maxSellPos != 0 && numberOfPositions(0, sym) < maxPos && maxPos != 0)
        {
         if(dnZZ < Close[bar])
            OP(sym, -1, 0, 0, 0, dnZZ);
         else
            OP(sym, -1);
        }
     }
   else
     {
      if(arrUp > 0 && arrUp != EMPTY_VALUE && numberOfPositions(1, sym) < maxBuyPos && maxBuyPos != 0 && numberOfPositions(0, sym) < maxPos && maxPos != 0)
         OP(sym, 1);
      if(arrDn > 0 && arrDn != EMPTY_VALUE && numberOfPositions(2, sym) < maxSellPos && maxSellPos != 0 && numberOfPositions(0, sym) < maxPos && maxPos != 0)
         OP(sym, -1);
     }
   return 0;
  }

/*

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Donchian_and_ZZ_Breakout_EA_v1.00
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75032&p=161099#p161099
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
