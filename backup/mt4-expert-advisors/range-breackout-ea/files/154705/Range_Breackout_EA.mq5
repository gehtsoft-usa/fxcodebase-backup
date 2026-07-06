/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Range_Breackout_EA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=154783#p154783
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

#property description "Expert Advisor"
#include <Trade/Trade.mqh>
CTrade trade;
enum ModeLevels
  {
   FixPips,           // Fix Pips
   byMoney,           // Money
   PipsFromOpenCandle // Pips from Candle
  };
enum TSLMode
  {
   byPips, // By Pips
   byMA    // By Moving Average
  };
enum ModeCalcLots
  {
   FixLots,       // Fix Lots
   EquityPercent, // by Equity Percent
  };
enum CloseAllMode
  {
   CloseByMoney,          // by Money
   CloseByAccountPercent, // by Account Percent
   CloseByPips            // By Pips
  };
enum enumDays { sunday,
                monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                EA_OFF
              };
enum ModeEntry { Market,
                 PendingStop,
                 PendingLimit
               };
input string    Tpom              = "== Pending or Market Setup =="; // ————————————
input ModeEntry modeEntry         = PendingStop;                     // Mode Entry:
double          uEntryDistance    = 10;
bool            uDeletePendingsOn = true;
input string TBox         = "== Box Setup =="; // ————————————
input string hrIni        = "00:00";           // Time Start Box:
input string hrFin        = "04:00";           // Time End Box:
input color  clrCaja      = clrBlue;           // Box Color:
int          grosorCaja   = 1;
bool         rellenoCaja  = true;
color        clrLineas    = clrRoyalBlue;
int          grosorLineas = 1;
datetime     HoraInicio;
datetime     HoraFin;
double       HigherPrice    = 0;
double       LowerPrice     = 0;
bool         ActualizarCaja = true;
datetime     diaActual;
bool         habilitado = false;
input string T0 = "== Trade Setup =="; // ————————————
input int uMaxTrades = 1; // Max Trades At Same Time:
input bool         uTradeReverse = false;             // Trade Reverse:
input int          magico        = 2022;              // Magic Number:
input ENUM_ORDER_TYPE_FILLING OrderFill = ORDER_FILLING_FOK; // Order filling mode (change if "Unsupported filling mode" error)
input string       Tvolumen      = "= Volumen =";     // ————————————
input ModeCalcLots modeCalcLots  = FixLots;           // Mode to Calc Lots:
input double       userLots      = 0.01;              // Fixed Lots:
input double       userEquityPer = 1;                 // Setup Lots by "Equity Percent":
input string       T01           = "= Take Profit ="; // ————————————
input bool         takeProfitOn  = true;              // Take Profit On:
input ModeLevels   modeTP        = FixPips;           // Mode Take Profit:
input int          userTPpips    = 20;                // Pips TP
input double       userTPmoney   = 15;                // Money TP
input string       T02           = "= Stop Loss =";   // ————————————
input bool         stopLossOn    = true;              // Stop Loss On:
input ModeLevels   modeSL        = FixPips;           // Mode Stop Loss:
input int          userSLpips    = 20;                // Pips SL
input double       userSLmoney   = 15;                // Money SL
enum DayLimitsMode
  {
   LimitsByAmount,        // by Amount
   LimitsByAccountPercent // by Account %
  };
bool          uDailyProfitOn     = false;
DayLimitsMode limitProfitMode    = LimitsByAmount;
double        uDayLimitProfit    = 2000;
bool          uDailyLossOn       = false;
DayLimitsMode limitLossMode      = LimitsByAmount;
double        uDayLimitLoss      = -1000;
bool          uConsiderFloatting = false;
string       TtpOptions              = "== Close All Options ==";
bool         closeAllControlON       = false;
CloseAllMode closeBy                 = CloseByMoney;
double       closeAllMoney           = 100;
double       closeAllMoneyLoss       = -100;
double       accountPerWin           = 1;
double       accountPerLos           = -1;
double       closeByPipsWin          = 10;
double       closeByPipsLoss         = 10;
bool         closeAllInOpositeSignal = false;
string Tpc                     = "== Partial Close ==";
bool   partialCloseOn          = false;
double userPartialClosePercent = 50;
double userPartialClosePips    = 20;
int    uQntPartials            = 1;
string Tbk         = "== Breakeven Setup ==";
bool   breakevenOn = false;
double userBkvPips = 10;
double userBkvStep = 3;
input string tTailingStop       = "== TrailingStop Setup =="; // ————————————
input bool   TslON              = false;                      // TSL ON:
TSLMode      userTslMode        = byPips;
input int    userTslInitialStep = 1;                          // TSL Initial Step:
input int    userTslStep        = 1;                          // TSL Step:
input int    userTslDistance    = 20;                         // TSL Distance:
string tGrid               = "== Grid Setup ==";
bool   GridON              = false;
int    GridUser_maxCount   = 5;
double GridUser_maxLot     = 10;
double GridUser_multiplier = 1.5;
int    GridUser_gap        = 30;
bool   closeGridOn         = true;
double closeGridTP         = 100;
double closeGridSL         = -100;
input string TZ                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On
input bool   desktop_notifications = false;                 // Desktop MT5 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input int    minutesBetwenNotify   = 1;                     // Minutes Betwen Notifications
int          timeNextNotify        = 0;
string                   IemaFast             = "== Moving Average Fast Setup ==";
int                      maFastPeriod         = 20;
int                      maFastShift          = 0;
ENUM_MA_METHOD           maFastMethod         = MODE_EMA;
ENUM_APPLIED_PRICE       maFastAppliedPrice   = PRICE_CLOSE;
string                   IemaSlow             = "== Moving Average Slow Setup ==";
int                      maSlowPeriod         = 50;
int                      maSlowShift          = 0;
ENUM_MA_METHOD           maSlowMethod         = MODE_EMA;
ENUM_APPLIED_PRICE       maSlowAppliedPrice   = PRICE_CLOSE;
input string             IemaFilter           = "== Moving Average Filter Setup =="; // ————————————
input bool               maFilterOn           = true;                                // MA Filter On ?
input int                maFilterPeriod       = 200;                                 // Period
input int                maFilterShift        = 0;                                   // MA Shift
input ENUM_MA_METHOD     maFilterMethod       = MODE_EMA;                            // Method
input ENUM_APPLIED_PRICE maFilterAppliedPrice = PRICE_CLOSE;                         // Applied Price
string TFilters        = "== Filters Orders ==";
bool   filterSymbolsOn = true;
string SymbolsList     = "GBPUSD,EURUSD";
bool   filterMagicsOn  = true;
string MagicsList      = "2022";
int maFastHandle, maSlowHandle, maFilterHandle;
bool CloseCandleMode = true;
datetime lastBarTime = 0;

bool IsNewCandle();

double GetMA(int handle, int shift);

void RegistrarMaxMin();

void Reiniciar();

bool Habilitado();

void setHabilitado(bool active);

bool hizoOperacionesHoy();

void getHoras();

void resetearCaja();

void DrawBox();

void CleanChart();

double Price(string direction, int pips = 0, string _symbol = "");

double SL(string side, double price = 0);

double TP(string side, double price = 0);

double Lots();

void Notifications(int type);

string GetTimeFrame(ENUM_TIMEFRAMES lPeriod);

int Distancia(double precioA, double precioB, string par, string mode = "pips");

double floatingEA();

bool CloseAllControl();

void closeAll(string side = "");

void deletePendings();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SessionControl();
struct OrderInfo
  {
   ulong             ticket;
   double            price;
   double            sl;
   double            tp;
   double            lot;
   ENUM_ORDER_TYPE   type;
   double            tslNext;
   bool              bkvWasDoIt;
   int               countPartials;
  };
OrderInfo mainOrders[];

bool BuyCondition1();

bool SellCondition1();

bool ConditionCountTrades(int max);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(magico);
   trade.SetDeviationInPoints(100);
   trade.SetTypeFilling(OrderFill);
   maFastHandle = iMA(_Symbol, PERIOD_CURRENT, maFastPeriod, maFastShift, maFastMethod, maFastAppliedPrice);
   maSlowHandle = iMA(_Symbol, PERIOD_CURRENT, maSlowPeriod, maSlowShift, maSlowMethod, maSlowAppliedPrice);
   maFilterHandle = iMA(_Symbol, PERIOD_CURRENT, maFilterPeriod, maFilterShift, maFilterMethod, maFilterAppliedPrice);
   if(maFastHandle == INVALID_HANDLE || maSlowHandle == INVALID_HANDLE || maFilterHandle == INVALID_HANDLE)
     {
      Print("Error creating MA indicators");
      return INIT_FAILED;
     }
   getHoras();
   diaActual = iTime(_Symbol, PERIOD_D1, 0);
   ArrayResize(mainOrders, 0);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   CleanChart();
   if(maFastHandle != INVALID_HANDLE)
      IndicatorRelease(maFastHandle);
   if(maSlowHandle != INVALID_HANDLE)
      IndicatorRelease(maSlowHandle);
   if(maFilterHandle != INVALID_HANDLE)
      IndicatorRelease(maFilterHandle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   RegistrarMaxMin();
   Reiniciar();
   if(!SessionControl())
     {
      return;
     }
   if(closeAllControlON)
     {
      if(CloseAllControl())
        {
         closeAll();
        }
     }
   if(CloseCandleMode)
      if(!IsNewCandle())
        {
         return;
        }
   if(!uTradeReverse)
     {
      if(BuyCondition1() && ConditionCountTrades(uMaxTrades))
        {
         double sl = SL("buy");
         double tp = TP("buy");
         double lots = Lots();
         double price = 0;
         if(modeEntry == Market)
           {
            if(trade.Buy(lots, _Symbol, 0, sl, tp, ""))
              {
               Notifications(0);
              }
           }
         else
           {
            price = Price("buy", (int)uEntryDistance, _Symbol);
            if(modeEntry == PendingStop)
              {
               if(trade.BuyStop(lots, price, _Symbol, SL("buy", price), TP("buy", price), ORDER_TIME_GTC, 0, ""))
                 {
                  Notifications(0);
                 }
              }
            else
               if(modeEntry == PendingLimit)
                 {
                  if(trade.BuyLimit(lots, price, _Symbol, SL("buy", price), TP("buy", price), ORDER_TIME_GTC, 0, ""))
                    {
                     Notifications(0);
                    }
                 }
           }
        }
      if(SellCondition1() && ConditionCountTrades(uMaxTrades))
        {
         double sl = SL("sell");
         double tp = TP("sell");
         double lots = Lots();
         double price = 0;
         if(modeEntry == Market)
           {
            if(trade.Sell(lots, _Symbol, 0, sl, tp, ""))
              {
               Notifications(1);
              }
           }
         else
           {
            price = Price("sell", (int)uEntryDistance, _Symbol);
            if(modeEntry == PendingStop)
              {
               if(trade.SellStop(lots, price, _Symbol, SL("sell", price), TP("sell", price), ORDER_TIME_GTC, 0, ""))
                 {
                  Notifications(1);
                 }
              }
            else
               if(modeEntry == PendingLimit)
                 {
                  if(trade.SellLimit(lots, price, _Symbol, SL("sell", price), TP("sell", price), ORDER_TIME_GTC, 0, ""))
                    {
                     Notifications(1);
                    }
                 }
           }
        }
     }
   if(uTradeReverse)
     {
      if(SellCondition1() && ConditionCountTrades(uMaxTrades))
        {
         double sl = SL("buy");
         double tp = TP("buy");
         double lots = Lots();
         double price = 0;
         if(modeEntry == Market)
           {
            if(trade.Buy(lots, _Symbol, 0, sl, tp, ""))
              {
               Notifications(0);
              }
           }
         else
           {
            price = Price("buy", (int)uEntryDistance, _Symbol);
            if(modeEntry == PendingStop)
              {
               if(trade.BuyStop(lots, price, _Symbol, SL("buy", price), TP("buy", price), ORDER_TIME_GTC, 0, ""))
                 {
                  Notifications(0);
                 }
              }
            else
               if(modeEntry == PendingLimit)
                 {
                  if(trade.BuyLimit(lots, price, _Symbol, SL("buy", price), TP("buy", price), ORDER_TIME_GTC, 0, ""))
                    {
                     Notifications(0);
                    }
                 }
           }
        }
      if(BuyCondition1() && ConditionCountTrades(uMaxTrades))
        {
         double sl = SL("sell");
         double tp = TP("sell");
         double lots = Lots();
         double price = 0;
         if(modeEntry == Market)
           {
            if(trade.Sell(lots, _Symbol, 0, sl, tp, ""))
              {
               Notifications(1);
              }
           }
         else
           {
            price = Price("sell", (int)uEntryDistance, _Symbol);
            if(modeEntry == PendingStop)
              {
               if(trade.SellStop(lots, price, _Symbol, SL("sell", price), TP("sell", price), ORDER_TIME_GTC, 0, ""))
                 {
                  Notifications(1);
                 }
              }
            else
               if(modeEntry == PendingLimit)
                 {
                  if(trade.SellLimit(lots, price, _Symbol, SL("sell", price), TP("sell", price), ORDER_TIME_GTC, 0, ""))
                    {
                     Notifications(1);
                    }
                 }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle()
  {
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBarTime != lastBarTime)
     {
      lastBarTime = currentBarTime;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetMA(int handle, int shift)
  {
   double ma[];
   ArraySetAsSeries(ma, true);
   if(CopyBuffer(handle, 0, shift, 1, ma) > 0)
     {
      return ma[0];
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuyCondition1()
  {
   if(hizoOperacionesHoy())
      return false;
   if(!Habilitado())
      return false;
   bool filter, time;
   double closePrice = iClose(_Symbol, PERIOD_CURRENT, 1);
   double maFilterValue = GetMA(maFilterHandle, 1);
   filter = maFilterOn == true ? closePrice > maFilterValue : true;
   time = TimeGMT() > HoraFin;
   return filter && time;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellCondition1()
  {
   if(hizoOperacionesHoy())
      return false;
   if(!Habilitado())
      return false;
   bool filter, time;
   double closePrice = iClose(_Symbol, PERIOD_CURRENT, 1);
   double maFilterValue = GetMA(maFilterHandle, 1);
   filter = maFilterOn == true ? closePrice < maFilterValue : true;
   time = TimeGMT() > HoraFin;
   return filter && time;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ConditionCountTrades(int max)
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magico)
           {
            count++;
            if(count >= max)
              {
               return false;
              }
           }
        }
     }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
            OrderGetInteger(ORDER_MAGIC) == magico)
           {
            count++;
            if(count >= max)
              {
               return false;
              }
           }
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Price(string direction, int pips = 0, string _symbol = "")
  {
   string symbol = _symbol == "" ? _Symbol : _symbol;
   double points = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double distance = pips * 10 * points;
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   MqlTick tick;
   SymbolInfoTick(symbol, tick);
   if(direction == "buy")
     {
      double price = distance == 0 ? tick.ask : tick.ask + distance;
      if(modeEntry == PendingStop)
        {
         price = HigherPrice;
        }
      if(modeEntry == PendingLimit)
        {
         price = LowerPrice;
        }
      return NormalizeDouble(price, digits);
     }
   if(direction == "sell")
     {
      double price = distance == 0 ? tick.bid : tick.bid - distance;
      if(modeEntry == PendingStop)
        {
         price = LowerPrice;
        }
      if(modeEntry == PendingLimit)
        {
         price = HigherPrice;
        }
      return NormalizeDouble(price, digits);
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SL(string side, double price = 0)
  {
   double result = 0;
   if(stopLossOn)
     {
      double mPoint = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double distance = userSLpips * 10 * mPoint;
      if(userSLpips == 0)
        {
         return 0;
        }
      MqlTick tick;
      SymbolInfoTick(_Symbol, tick);
      if(side == "buy")
        {
         double entryPrice = price == 0 ? tick.ask : price;
         result = entryPrice - distance;
        }
      if(side == "sell")
        {
         double entryPrice = price == 0 ? tick.bid : price;
         result = entryPrice + distance;
        }
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TP(string side, double price = 0)
  {
   double result = 0;
   if(takeProfitOn)
     {
      double mPoint = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double distance = userTPpips * 10 * mPoint;
      if(userTPpips == 0)
        {
         return 0;
        }
      MqlTick tick;
      SymbolInfoTick(_Symbol, tick);
      if(side == "buy")
        {
         double entryPrice = price == 0 ? tick.ask : price;
         result = entryPrice + distance;
        }
      if(side == "sell")
        {
         double entryPrice = price == 0 ? tick.bid : price;
         result = entryPrice - distance;
        }
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lots()
  {
   double lots = -1;
   switch(modeCalcLots)
     {
      case FixLots:
        {
         lots = userLots;
         break;
        }
      case EquityPercent:
        {
         double margin = 0;
         if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1.0, SymbolInfoDouble(_Symbol, SYMBOL_ASK), margin))
           {
            if(margin > 0)
              {
               lots = NormalizeDouble((AccountInfoDouble(ACCOUNT_EQUITY) * userEquityPer / 100) / margin, 2);
              }
           }
         break;
        }
     }
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(lots < minLot)
      lots = minLot;
   if(lots > maxLot)
      lots = maxLot;
   return lots;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type)
  {
   if(timeNextNotify != 0)
      if(TimeCurrent() < timeNextNotify)
         return;
   timeNextNotify = (int)TimeCurrent() + (minutesBetwenNotify * 60);
   string text = "";
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(PERIOD_CURRENT) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(PERIOD_CURRENT) + " SELL ";
   text += " ";
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
string GetTimeFrame(ENUM_TIMEFRAMES lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return("M1");
      case PERIOD_M5:
         return("M5");
      case PERIOD_M15:
         return("M15");
      case PERIOD_M30:
         return("M30");
      case PERIOD_H1:
         return("H1");
      case PERIOD_H4:
         return("H4");
      case PERIOD_D1:
         return("D1");
      case PERIOD_W1:
         return("W1");
      case PERIOD_MN1:
         return("MN1");
     }
   return IntegerToString(lPeriod);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Distancia(double precioA, double precioB, string par, string mode = "pips")
  {
   double mPoint = SymbolInfoDouble(par, SYMBOL_POINT);
   double dist = fabs(precioA - precioB);
   if(mode == "points")
      return (int)(dist / mPoint);
   if(mode == "pips")
      return (int)((dist / mPoint) / 10);
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double floatingEA()
  {
   double profit = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magico)
           {
            profit += PositionGetDouble(POSITION_PROFIT);
           }
        }
     }
   return profit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseAllControl()
  {
   switch(closeBy)
     {
      case CloseByMoney:
         if(floatingEA() >= closeAllMoney && closeAllMoney > 0)
           {
            return true;
           }
         if(floatingEA() < closeAllMoneyLoss && closeAllMoneyLoss < 0)
           {
            return true;
           }
         break;
      case CloseByAccountPercent:
        {
         double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
         double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;
         if(floatingEA() >= moneyByAccountPerWin && moneyByAccountPerWin > 0)
           {
            return true;
           }
         if(floatingEA() < moneyByAccountPerLos && moneyByAccountPerLos < 0)
           {
            return true;
           }
         break;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAll(string side = "")
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magico)
           {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(side == "" ||
               (side == "buy" && posType == POSITION_TYPE_BUY) ||
               (side == "sell" && posType == POSITION_TYPE_SELL))
              {
               trade.PositionClose(ticket);
              }
           }
        }
     }
   if(uDeletePendingsOn)
     {
      deletePendings();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deletePendings()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
            OrderGetInteger(ORDER_MAGIC) == magico)
           {
            trade.OrderDelete(ticket);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getHoras()
  {
   HoraInicio = StringToTime(hrIni);
   HoraFin = StringToTime(hrFin);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RegistrarMaxMin()
  {
   double ctrlMax = HigherPrice;
   if(TimeGMT() > HoraFin && ActualizarCaja == true)
     {
      int minutos = (int)((HoraFin - HoraInicio) / 60);
      int barIni = iBarShift(_Symbol, PERIOD_M1, HoraFin);
      for(int i = barIni; i < barIni + minutos; i++)
        {
         double high = iHigh(_Symbol, PERIOD_M1, i);
         double low = iLow(_Symbol, PERIOD_M1, i);
         if(HigherPrice == 0 || high > HigherPrice)
           {
            HigherPrice = high;
           }
         if(LowerPrice == 0 || low < LowerPrice)
           {
            LowerPrice = low;
           }
        }
      ActualizarCaja = false;
      DrawBox();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void resetearCaja()
  {
   HigherPrice = 0;
   LowerPrice = 0;
   ActualizarCaja = true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBox()
  {
   ObjectDelete(0, "Box");
   ObjectCreate(0, "Box", OBJ_RECTANGLE, 0, HoraInicio, HigherPrice, HoraFin, LowerPrice);
   ObjectSetInteger(0, "Box", OBJPROP_COLOR, clrCaja);
   ObjectSetInteger(0, "Box", OBJPROP_WIDTH, grosorCaja);
   ObjectSetInteger(0, "Box", OBJPROP_FILL, rellenoCaja);
   ObjectSetInteger(0, "Box", OBJPROP_BACK, false);
   ObjectCreate(0, "Max", OBJ_HLINE, 0, 0, HigherPrice);
   ObjectCreate(0, "Min", OBJ_HLINE, 0, 0, LowerPrice);
   ObjectSetInteger(0, "Max", OBJPROP_COLOR, clrLineas);
   ObjectSetInteger(0, "Max", OBJPROP_WIDTH, grosorLineas);
   ObjectSetInteger(0, "Min", OBJPROP_COLOR, clrLineas);
   ObjectSetInteger(0, "Min", OBJPROP_WIDTH, grosorLineas);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Reiniciar()
  {
   datetime nuevoDia = iTime(_Symbol, PERIOD_D1, 0);
   if(diaActual != nuevoDia)
     {
      setHabilitado(true);
      CleanChart();
      resetearCaja();
      diaActual = nuevoDia;
      getHoras();
      deletePendings();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setHabilitado(bool active)
  {
   habilitado = active;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Habilitado()
  {
   return habilitado;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanChart()
  {
   ObjectDelete(0, "Box");
   ObjectDelete(0, "Max");
   ObjectDelete(0, "Min");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool hizoOperacionesHoy()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == magico)
           {
            datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
            MqlDateTime dt1, dt2;
            TimeToStruct(openTime, dt1);
            TimeToStruct(diaActual, dt2);
            if(dt1.day == dt2.day && dt1.mon == dt2.mon && dt1.year == dt2.year)
              {
               return true;
              }
           }
        }
     }
   HistorySelect(diaActual, TimeCurrent());
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket > 0)
        {
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol &&
            HistoryDealGetInteger(ticket, DEAL_MAGIC) == magico &&
            HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_IN)
           {
            datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
            MqlDateTime dt1, dt2;
            TimeToStruct(dealTime, dt1);
            TimeToStruct(diaActual, dt2);
            if(dt1.day == dt2.day && dt1.mon == dt2.mon && dt1.year == dt2.year)
              {
               return true;
              }
           }
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SessionControl()
  {
   Comment("Session Control - EA ON");
   return true;
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Range_Breackout_EA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=154783#p154783
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
