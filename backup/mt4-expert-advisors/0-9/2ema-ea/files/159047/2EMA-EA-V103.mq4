//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75863

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
/*
Four Inputs: 1 [Magic], 2 [Trade Comment], 3 [Lot size], 4 [Maximum Buy Sell].

1) Open Order
a) First Check: TradeCount [Maximum Buy Sell Input value] has not been exceeded.
b) all orders must be Distance from last Order of minimum [5 x (Spread + Broker Commission)]. If 0 orders, ignore above check and open Order immediately
c) Second Check: if 5EMA is above 20EMA, open Buy order; if 5EMA is below 20EMA, open Sell order.
d) use Lot Input value, Magic Input value, Trade Comment Input value.

2) Close Order
a) Closes buy orders when 5EMA crosses below 20EMA AND loss exceeds threshold
b) Closes sell orders when 5EMA crosses above 20EMA AND loss exceeds threshold
c) Add minimum loss threshold calculation: MinLossThreshold = 10 * (Spread + BrokerCommission)
*/

// best test on XAUUSD, H1, 5 trades, 5/10 EMA, 0.01 lot, dist_mult 5, PRICE_WEIGHTED
 
#property strict


#define Section_Arquitecture
#ifdef Section_Arquitecture
// MARK: arquitecture

interface iActions { bool execute(); };
interface iConditions { bool evaluate(); };

class Conditions
{
  protected:
    iConditions *_conditions[];

  public:
    Conditions(void) {}
    ~Conditions(void) { releaseConditions(); }

    void releaseConditions()
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            delete _conditions[i];
        }
        ArrayFree(_conditions);
    }

    void add(iConditions *condition)
    {
        int t = ArraySize(_conditions);
        ArrayResize(_conditions, t + 1);
        _conditions[t] = condition;
    }

    bool evaluate(void)
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            if (!_conditions[i].evaluate()) {
                return false;
            }
        }
        return true;
    }
};
class Actions
{
  protected:
    iActions *_actions[];

  public:
    Actions(void) {}
    ~Actions(void) { release(); }

    void release()
    {
        for (int i = 0; i < ArraySize(_actions); i++) {
            delete _actions[i];
        }
        ArrayFree(_actions);
    }

    void add(iActions *action)
    {
        int t = ArraySize(_actions);
        ArrayResize(_actions, t + 1);
        _actions[t] = action;
    }

    bool execute(void)
    {
        for (int i = 0; i < ArraySize(_actions); i++) {
            if (!_actions[i].execute()) {
                return false;
            }
        }
        return true;
    }
};
class Strategy
{
    Conditions conditions;
    Actions    actions;
    bool       _mode;

  public:
    Strategy(bool mode = true) { _mode = mode; }

    Strategy(iConditions *condition, iActions *action, bool mode = true)
    {
        addCondition(condition);
        addAction(action);
        _mode = mode;
    }
    ~Strategy() { ; }

    void set(iConditions *condition, iActions *action)
    {
        addCondition(condition);
        addAction(action);
    }
    void addCondition(iConditions *aCondition) { conditions.add(aCondition); }
    void addAction(iActions *Action) { actions.add(Action); }

    bool execute()
    {
        bool result = false;

        if (_mode == true)
            if (conditions.evaluate()) {
                result = actions.execute();
            }

        if (_mode == false)
            if (!conditions.evaluate()) {
                result = actions.execute();
            }
        return result;
    }
};
class Strategys
{
    Strategy *_strategys[];

  public:
    Strategys() {}
    ~Strategys() { release(); }

    void release()
    {
        for (int i = 0; i < ArraySize(_strategys); i++) {
            delete _strategys[i];
        }
        ArrayFree(_strategys);
    }

    void add(Strategy *newStrategy)
    {
        int t = ArraySize(_strategys);
        ArrayResize(_strategys, t + 1);
        _strategys[t] = newStrategy;
    }

    bool execute()
    {
        for (int i = 0; i < ArraySize(_strategys); i++) {
            _strategys[i].execute();
        }
        return true;
    }
};
class PositionsMannagement
{
    Strategy *_strategys[];
    string    _symbol;
    int       _magic;

  public:
    PositionsMannagement() { ; }
    ~PositionsMannagement() { release(); }

    void set(string sym, int magi)
    {
        _symbol = sym;
        _magic  = magi;
    }
    void release()
    {
        for (int i = 0; i < ArraySize(_strategys); i++) {
            delete _strategys[i];
        }
        ArrayFree(_strategys);
    }

    void add(Strategy *newStrategy)
    {
        int t = ArraySize(_strategys);
        ArrayResize(_strategys, t + 1);
        _strategys[t] = newStrategy;
    }

    bool execute()
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic) {
                for (int n = 0; n < ArraySize(_strategys); n++) {
                    _strategys[n].execute();
                    int c = OrderSelect(i, SELECT_BY_POS); // si alguna estrategia cambia la selección vuelvo a la que está seleccionada
                }
            }
        }

        return true;
    }
};
class Trading
{
  public:
    Trading() { ; }
    ~Trading() { ; }

    Conditions           filters;
    Strategys            strategys;
    PositionsMannagement management;

    void doTrading()
    {
        management.execute();
        if (filters.evaluate()) {
            strategys.execute();
        }
    }
};
Trading Trader();

#endif


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+
sinput string    EAHeader; // *** EA Settings ***
input int        MaxTrades = 5; // Max Trades (0 for unlimited)
input double     LotSize = 0.01; // Fixed Lot Size per trade
input int        distanceMultiplier = 5; // Distance multiplier (2-10)
input bool       TradeOnlyBetterPrices = false; // Trade only better prices
input double     KeepFreeMargin = 20.0; // Min free margin to keep [% from the acc balance]
input int        Magic  = 12345; // Magic number
input string     TradeCommentBuy  = "2EMA-Buy"; // Trade comment Buy
input string     TradeCommentSell  = "2EMA-Sell"; // Trade comment Sell


input string         tstop          = "== Stop Loss =="; // ————————————————————————
input double         uStopLossValue = 30;                // SL:
input string         ttakeprofit      = "== Take Profit =="; // ————————————————————————
input double         uTakeProfitValue = 10;                   // TP:

input string       ttsl         = "== TrailingStop Setup =="; // ————————————————————————
input const bool   tsl_on       = false;                      // TSL ON:
input const double tsl_start    = 10;                         // TSL Start:
input const double tsl_step     = 10;                         // TSL Step:
input const double tsl_distance = 20;                         // TSL Distance:

// input double     SL = 3000;
// input double     TP = 150;
// bool      TPLinier        = true;
// bool      UseTralling     = true;   // UseTralling
// double    TrallingStart   = 120;    // Ts Start in Pips
// double    LockProfit      = 5;      // Lock Profit in Pips
// bool      UseTimeFilter   = false;  // TimeFilter
// string    Start           = "14.00";// Start
// string    End1            = "12.00";// Stop
sinput string    EMAHeader; // *** EMA Settings ***
input int        EMA_FAST_PERIOD = 5; // EMA Fast Period
input int        EMA_SLOW_PERIOD = 10; // EMA Slow Period
input ENUM_TIMEFRAMES EMA_TIMEFRAME = PERIOD_H1; // EMA TimeFrame
input ENUM_APPLIED_PRICE EMA_PRICE_TYPE = PRICE_WEIGHTED; // EMA Price Type


//+------------------------------------------------------------------+
//| Global variable                                                  |
//+------------------------------------------------------------------+
datetime newtime;
double spreadDistance;
int lastBuyTicket;
int lastSellTicket;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   newtime = 0;
   lastBuyTicket = LastOpenOrderTicket(OP_BUY);
   lastSellTicket = LastOpenOrderTicket(OP_SELL);
   
   // ---------------------------------------------------------------------
   Trader.management.set(_Symbol, Magic);
   Initiate_TSL();
   
   // ---------------------------------------------------------------------
   
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Shutdown function                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   Trader.doTrading();


   if(newtime == 0) {
      newtime = Time[0];
   } else {
      if(newtime != Time[0]) {
         newtime = Time[0];

         // at every new bar open (current timeframe):
         spreadDistance = MarketInfo(Symbol(), MODE_SPREAD) * MarketInfo(Symbol(), MODE_POINT);
         int orders_count = CountOrders();
         int buy_orders_count = CountOrdersByType(OP_BUY);
         int sell_orders_count = CountOrdersByType(OP_SELL);
         double lastBuyPrice = OrderPrice(lastBuyTicket);
         double lastSellPrice = OrderPrice(lastSellTicket);
         bool enoughDistanceForNewBuy = false;
         bool enoughDistanceForNewSell = false;
         if(TradeOnlyBetterPrices) {
            // buy/sell only if the current price is better than the price of the last trade
            enoughDistanceForNewBuy = (lastBuyPrice>0) && (Ask < (lastBuyPrice - spreadDistance * distanceMultiplier));
            enoughDistanceForNewSell = (lastSellPrice>0) && (Bid > (lastBuyPrice + spreadDistance * distanceMultiplier));         
         } else {
            // buy/sell if the current price is in any direction at required distance from the price of the last trade
            enoughDistanceForNewBuy = (lastBuyPrice>0) && (MathAbs(lastBuyPrice - Ask) >= spreadDistance * distanceMultiplier);
            enoughDistanceForNewSell = (lastSellPrice>0) && (MathAbs(lastSellPrice - Bid) >= spreadDistance * distanceMultiplier);         
         }
         double emaFast = iMA(Symbol(), EMA_TIMEFRAME, EMA_FAST_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 1);
         double emaSlow = iMA(Symbol(), EMA_TIMEFRAME, EMA_SLOW_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 1);
         double emaFastPrev = iMA(Symbol(), EMA_TIMEFRAME, EMA_FAST_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 2);
         double emaSlowPrev = iMA(Symbol(), EMA_TIMEFRAME, EMA_SLOW_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 2);
         bool emaCrossDn = emaFast < emaSlow && emaFastPrev >= emaSlowPrev;
         bool emaCrossUp = emaFast > emaSlow && emaFastPrev <= emaSlowPrev;
         double MinLossThreshold = 10 * spreadDistance; // ??? how to use it ???
         // check for open new order conditions:
         if(MaxTrades == 0 || (MaxTrades != 0 && orders_count < MaxTrades)) {
            if((emaFast > emaSlow) && (orders_count == 0 || enoughDistanceForNewBuy)) {
               // open buy order
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, LotSize) < AccountBalance()*KeepFreeMargin*0.01) {
                  // Not enough money to open the trade
                  Print("ERROR: Insufficient funds to open a trade with this lot size!"); 
               } else {
                  // All is good, proceed with opening the trade
                  int t = OpenOrder(OP_BUY, Ask, LotSize, TradeCommentBuy);
                  if(t > 0) lastBuyTicket = t;
               }
            } else {
               if((emaFast < emaSlow) && (orders_count == 0 || enoughDistanceForNewSell)) {
                  // open sell order
                  if (AccountFreeMarginCheck(Symbol(), OP_SELL, LotSize) < AccountBalance()*KeepFreeMargin*0.01) {
                     // Not enough money to open the trade
                     Print("ERROR: Insufficient funds to open a trade with this lot size!"); 
                  } else {
                     // All is good, proceed with opening the trade
                     int t = OpenOrder(OP_SELL, Bid, LotSize, TradeCommentSell);
                     if(t > 0) lastSellTicket = t;
                  }
               }
            }
         }
         // check for the closing conditions:
         if(emaCrossDn && buy_orders_count > 0) {
            // check the condition to close all buy orders (need to use also MinLossThreshold ???)
            CloseOrdersByType(OP_BUY);
            lastBuyTicket = LastOpenOrderTicket(OP_BUY);
         }
         if(emaCrossUp && sell_orders_count > 0) {
            // check the condition to close all sell orders (need to use also MinLossThreshold ???)
            CloseOrdersByType(OP_SELL);
            lastSellTicket = LastOpenOrderTicket(OP_SELL);
         }
      }
   }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderPrice(int ticket) {
   double price = 0;
   if(ticket <= 0) return price;
   if(OrderSelect(ticket, SELECT_BY_TICKET)) {
      price =  OrderOpenPrice();
   }
   return price;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOrders() {
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOrdersByType(int type) {
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckVolume(string pSymbol, double pVolume) {
   double minVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MIN);
   double maxVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MAX);
   double stepVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_STEP);
   double tradeSize;
   if(pVolume < minVolume) {
      tradeSize = minVolume;
   } else if(pVolume > maxVolume) {
      tradeSize = maxVolume;
   } else tradeSize = MathRound(pVolume / stepVolume) * stepVolume;
   if(stepVolume >= 0.1) tradeSize = NormalizeDouble(tradeSize, 1);
   else tradeSize = NormalizeDouble(tradeSize, 2);
   return(tradeSize);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrder(int type, double price, double lots, string comment) {
   double priceN =  NormalizeDouble(price, _Digits);
   double lotsN = CheckVolume(Symbol(), lots);
   

   double sl = 0, tp = 0;
   if(uStopLossValue >0) sl = StopLossByPips(priceN, (type == OP_BUY) ? "buy" : "sell", Symbol());
   if(uTakeProfitValue >0) tp = TakeProfitByPips(priceN, (type == OP_BUY) ? "buy" : "sell", Symbol());

   int ticket = OrderSend(Symbol(), type, lotsN, priceN, 0, sl, tp, comment, Magic, 0, (type == OP_BUY) ? clrGreen : clrRed);
   if (ticket < 0) {
      Print("Order open error: ", GetLastError());
   }
   return ticket;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrdersByType(int type) {
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
            bool result = false;
            if (type == OP_BUY)
               result = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrBlue);
            else if (type == OP_SELL)
               result = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
            if (!result)
               Print("Error closing order: ", GetLastError());
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LastOpenOrderTicket(int type = -1) {
   int ticket = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      bool ok = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(ok) {
         if (OrderSymbol() != Symbol() || (OrderMagicNumber() != Magic)) {
            continue;
         }
         if (OrderType() == OP_BUY && (type == OP_BUY || type == -1)) {
            ticket = OrderTicket();
            return ticket;
         }
         if (OrderType() == OP_SELL && (type == OP_SELL || type == -1)) {
            ticket = OrderTicket();
            return ticket;
         }
      }
   }
   return ticket;
}




double StopLossByPips(const double price, const string side, const string symbol)
{
    double mPoint   = MarketInfo(symbol, MODE_POINT);
    double digits   = MarketInfo(symbol, MODE_DIGITS);
    double distance = uStopLossValue * 10 * mPoint;
    double result   = 0;

    // clang-format off
    if (side == "buy")  { result = price - distance; }
    if (side == "sell") { result = price + distance; }
    // clang-format on

    return NormalizeDouble(result, (int)digits);
}

double TakeProfitByPips(const double price, const string side, const string symbol)
{
    double mPoint   = MarketInfo(symbol, MODE_POINT);
    double digits   = MarketInfo(symbol, MODE_DIGITS);
    double distance = uTakeProfitValue * 10 * mPoint;
    double result   = 0;

    // clang-format off
    if (side == "buy")  { result = price + distance; }
    if (side == "sell") { result = price - distance; }
    // clang-format on

    return NormalizeDouble(result, (int)digits);
}





#define Section_Traling_Stop
#ifdef Section_Traling_Stop



class ConditionTSL : public iConditions
{
  public:
    bool evaluate()
    {

        if (OrderProfit() < 0) return false;
        return true;
    }
};
ConditionTSL conditionTSL;

class ActionTSL : public iActions
{
  public:
    bool execute()
    {
        double mPoints   = MarketInfo(OrderSymbol(), MODE_POINT);
        double ask       = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
        double bid       = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
        int    digi      = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
        double step      = tsl_step * mPoints * 10;
        double distance  = tsl_distance * mPoints * 10;
        double currentsl = OrderStopLoss();
        double allowed   = MarketInfo(OrderSymbol(), MODE_STOPLEVEL) * mPoints;
        double newsl     = 0;

        if (OrderType() == OP_BUY) {
            double last_step = OrderOpenPrice() + tsl_start * mPoints * 10;
            if (bid < last_step) return false;
            double n = 1;
            while (last_step < ask) {
                last_step = OrderOpenPrice() + (step * n);
                n++;
            }
            allowed = bid - allowed;
            newsl   = MathMin(NormalizeDouble(last_step - distance, digi), allowed);
            if (currentsl < newsl || currentsl == 0) {
                return OrderModify(OrderTicket(), OrderOpenPrice(), newsl, OrderTakeProfit(), OrderExpiration(), clrNONE);
            }
        }

        if (OrderType() == OP_SELL) {
            double last_step = OrderOpenPrice() - tsl_start * mPoints * 10;
            if (ask > last_step) return false;
            int n = 1;
            while (last_step >= ask) {
                last_step = OrderOpenPrice() - (step * n);
                n++;
            }
            allowed = ask + allowed;
            newsl   = MathMax(NormalizeDouble(last_step + distance, digi), allowed);
            if (currentsl > newsl || currentsl == 0) {
                return OrderModify(OrderTicket(), OrderOpenPrice(), newsl, OrderTakeProfit(), OrderExpiration(), clrNONE);
            }
        }
        return true;
    }
};
ActionTSL actionTSL;

Strategy TSL;

void  Initiate_TSL()
{
    TSL.addCondition(&conditionTSL);
    TSL.addAction(&actionTSL);
    Trader.management.add(&TSL);
}

#endif
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75863

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 