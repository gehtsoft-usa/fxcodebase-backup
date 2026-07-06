//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74822

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description "Expert Advisor"
#property strict

input string T0         = "== Trade Setup =="; // == Trade Setup ==
input double userLots   = 0.01;                // Setup Lots by "User Lots":
input int    userTPpips = 20;                  // Pips TP
input int    userSLpips = 20;                  // Pips SL

input string Ttrade     = "== Trade en Tester =="; // ————————————
input double testerLots = 0.01;                    // Tester Lots:
input double pipsTP     = 20;                      // Pips TP:

int    magico = 0;
int    _lastTk;
double _lastProfit;
double _lastLot;

// Gobal Variables
//////////////////////////////////////////////////////////////////////

class Order
{
    int      _id;
    string   _symbol;
    double   _price;
    double   _sl;
    double   _tp;
    double   _lot;
    int      _type;
    int      _magic;
    string   _comment;
    string   _strategy;
    datetime _expireTime;
    datetime _signalTime;
    double   _profit;

  public:
    Order(
        int      id,
        string   symbol,
        double   price,
        double   sl,
        double   tp,
        double   lot,
        int      type,
        int      magic,
        string   comment,
        string   strategy,
        datetime expireTime,
        datetime signalTime,
        double   profit) : _id(id),
                         _symbol(symbol),
                         _price(price),
                         _sl(sl),
                         _tp(tp),
                         _lot(lot),
                         _type(type),
                         _magic(magic),
                         _comment(comment),
                         _strategy(strategy),
                         _expireTime(expireTime),
                         _signalTime(signalTime),
                         _profit(profit) {}

    Order() {}
    ~Order() {}
    // clang-format off
	Order* id(int id){_id=id; return &this;}
	Order* symbol(string symbol){_symbol=symbol; return &this;}
	Order* price(double price){_price=price; return &this;}
	Order* sl(double sl){_sl=sl; return &this;}
	Order* tp(double tp){_tp=tp; return &this;}
	Order* lot(double lot){_lot=lot; return &this;}
	Order* type(int type){_type=type; return &this;}
	Order* magic(int magic){_magic=magic; return &this;}
	Order* comment(string comment){_comment=comment; return &this;}
	Order* strategy(string strategy){_strategy=strategy; return &this;}
	Order* expireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* signalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* profit(double profit){_profit=profit; return &this;}

   int            id()         { return _id; }
   string         symbol()     { return _symbol; }
   double         price()      { return _price; }
   double         sl()         { return _sl; }
   double         tp()         { return _tp; }
   double         lot()        { return _lot; }
   int            type()       { return _type; }
   int            magic()      { return _magic; }
   string         comment()    { return _comment; }
   string         strategy()   { return _strategy; }
   datetime       expireTime() { return _expireTime; }
   datetime       signalTime() { return _signalTime; }
   double         profit()     { return _profit; }
    // clang-format on
};

interface iConditions
{
    bool evaluate();
};
class ConcurrentConditions
{
  protected:
    iConditions* _conditions[];

  public:
    ConcurrentConditions(void) {}
    ~ConcurrentConditions(void) { releaseConditions(); }

    //+------------------------------------------------------------------+
    void releaseConditions()
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            delete _conditions[i];
        }
        ArrayFree(_conditions);
    }
    //+------------------------------------------------------------------+
    void AddCondition(iConditions* condition)
    {
        int t = ArraySize(_conditions);
        ArrayResize(_conditions, t + 1);
        _conditions[t] = condition;
    }

    //+------------------------------------------------------------------+
    bool EvaluateConditions(void)
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            if (!_conditions[i].evaluate()) {
                return false;
            }
        }
        return true;
    }
};

interface iActions
{
    bool doAction();
};
class SendNewOrder : public iActions
{
  private:
    Order newOrder;

  public:
    SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
    {
        string _symbol = setSymbol(symbol);
        double _price  = setPrice(side, price, _symbol);
        int    _type   = SetType(side, price, _symbol);
        if (_type == -1) {
            Print(__FUNCTION__, " ", "Imposible to set OrderType");
            return;
        }

        newOrder
            .id(OrderTicket())
            .symbol(_symbol)
            .type(_type)
            .price(_price)
            .sl(sl)
            .tp(tp)
            .lot(lots)
            .magic(magic)
            .comment(coment)
            .expireTime(expire)
            .profit(0);
    }

    ~SendNewOrder() {}

    string setSymbol(string sim)
    {
        if (sim == "") {
            return Symbol();
        }
        return sim;
    }

    double setPrice(string side, double pr, string sym)
    {
        if (pr == 0) {
            if (side == "buy") {
                return SymbolInfoDouble(sym, SYMBOL_ASK);
            }
            if (side == "sell") {
                return SymbolInfoDouble(sym, SYMBOL_BID);
            }
        }

        return pr;
    }

    int SetType(string side, double priceClient, string sym)
    {
        double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
        double bid = SymbolInfoDouble(sym, SYMBOL_BID);

        if (priceClient == 0) {
            if (side == "buy") {
                return (int)OP_BUY;
            }
            if (side == "sell") {
                return (int)OP_SELL;
            }
        } else {
            if (side == "buy") {
                if (priceClient > ask) {
                    return (int)OP_BUYSTOP;
                }
                if (priceClient < ask) {
                    return (int)OP_BUYLIMIT;
                }
            }
            if (side == "sell") {
                if (priceClient > bid) {
                    return (int)OP_SELLLIMIT;
                }
                if (priceClient < bid) {
                    return (int)OP_SELLSTOP;
                }
            }
        }

        return -1;
    }

    bool doAction()
    {
        int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, newOrder.sl(), newOrder.tp(), newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);

        if (tk < 0) {
            Print(__FUNCTION__, " ", "Connot Send Order, error: ", GetLastError());
            return false;
        }

        return true;
    }
};
SendNewOrder* actionSendOrder;

ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;

// NOTE: buy sell conditions
class CustomConditionBUY : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: dev condition
        return LastTradeWasSL(OP_BUY);
    }
};
CustomConditionBUY* entryBuy;

class ConditionCountBuys : public iConditions
{
    int _maxBuys;

  public:
    ConditionCountBuys(int maxBuys)
    {
        _maxBuys = maxBuys;
    }
    ~ConditionCountBuys() { ; }

    bool evaluate()
    {
        int count = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
                if (OrderType() == OP_BUY) {
                    count += 1;
                }

                if (count == _maxBuys) {
                    return false;
                }
            }
        }
        return true;
    }
};
ConditionCountBuys* countBuys;

class CustomConditionSELL : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: dev condition
        return LastTradeWasSL(OP_SELL);
        return false;
    }
};
CustomConditionSELL* entrySell;

class ConditionCountSells : public iConditions
{
    int _maxSells;

  public:
    ConditionCountSells(int maxSells)
    {
        _maxSells = maxSells;
    }
    ~ConditionCountSells() { ; }

    bool evaluate()
    {
        int count = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
                if (OrderType() == OP_SELL) {
                    count += 1;
                }

                if (count == _maxSells) {
                    return false;
                }
            }
        }
        return true;
    }
};
ConditionCountSells* countSells;

//////////////////////////////////////////////////////////////////////

int OnInit()
{

    //--- CONDITIONS TO OPEN TRADES:
    conditionsToBuy.AddCondition(entryBuy = new CustomConditionBUY());
    conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1));
    conditionsToSell.AddCondition(entrySell = new CustomConditionSELL());
    conditionsToSell.AddCondition(countSells = new ConditionCountSells(1));

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { ; }

// NOTE: ontick
void OnTick()
{

    if (conditionsToBuy.EvaluateConditions()) {
        actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
        actionSendOrder.doAction();
        delete actionSendOrder;
    }

    if (conditionsToSell.EvaluateConditions()) {
        actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
        actionSendOrder.doAction();
        delete actionSendOrder;
    }
    testerOpenTrade();
}
void OnTimer(void) {}

//////////////////////////////////////////////////////////////////////

double Price(string direction)
{
    double result = 0;
    if (direction == "buy") {
        result = Ask;
        return result;
    }

    if (direction == "sell") {
        result = Bid;
        return result;
    }

    return -1;
}

// NOTE: SL
double SL(string direction)
{
    double result = 0;
    if (userSLpips == 0) {
        return 0;
    }
    if (direction == "buy") {
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        result     = ask - userSLpips * 10 * _Point;
        return result;
    }

    if (direction == "sell") {
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        result     = bid + userSLpips * 10 * _Point;
        return result;
    }

    return -1;
}

// NOTE: TP
double TP(string direction)
{
    double result = 0;
    if (userTPpips == 0) {
        return 0;
    }
    if (direction == "buy") {
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        result     = ask + userTPpips * 10 * _Point;
        return result;
    }

    if (direction == "sell") {
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        result     = bid - userTPpips * 10 * _Point;
        return result;
    }

    return -1;
}

// NOTE: lots
double Lots()
{
    double lots = userLots;
    if (_lastLot != 0)
        lots = _lastLot;
    return lots;
}

bool LastTradeWasSL(ENUM_ORDER_TYPE side)
{
    int i = OrdersHistoryTotal() - 1;
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderTicket() != _lastTk) {
        if (OrderProfit() < 0) {
            if (OrderType() == side) {
                _lastTk     = OrderTicket();
                _lastProfit = OrderProfit() + OrderCommission() + OrderSwap();
                _lastLot    = OrderLots();
                return true;
            }
        }
    }
    return false;
}


string nextSide="buy";

void testerOpenTrade()
{
    if(!IsTesting())return;

    if (currentCountOrders() == 0) {
        double ma = iMA(_Symbol, 0, 20, 0, MODE_EMA, PRICE_CLOSE, 1);
        if (nextSide == "buy" && iClose(NULL, 0, 1) > ma) {
            if(OrderSend(_Symbol, OP_BUY, testerLots, Price("buy"), 0, SL("buy"), TP("buy"), "test", magico, 0, clrNONE)){
            nextSide = "sell";
            return;
            }
        }

        if (nextSide == "sell" && iClose(NULL, 0, 1) < ma) {
            if(OrderSend(_Symbol, OP_SELL, testerLots, Price("sell"), 0, SL("sell"), TP("sell"), "test", magico, 0, clrNONE)){
            nextSide = "buy";
            return;
            }
        }
    }
}

int currentCountOrders()
{
    int qntTradesNow = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
            qntTradesNow += 1;
        }
    }
    return qntTradesNow;
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 