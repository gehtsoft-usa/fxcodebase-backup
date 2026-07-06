// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=150704

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
// Includes
#include <trade\trade.mqh>
COrderInfo orderInfo;
CTrade     trade;

int _handle_heinkin;
// NOTE: Defines
#define MOVING_AVERAGE_ON
#define ADX_ON

enum sl_modes {
    sl_by_pips, // by Pips
    sl_by_atr   // by ATR
};
enum tp_modes {
    tp_by_pips,      // by Pips
    tp_by_multiplier // by SL Multiplier
};
enum CloseAllMode {
  CloseByMoney,
  CloseByAccountPercent
};
enum ModeCalcLots { Money,
                    AccountPercent,
                    FixLots };
class LotCalculator
{
  double _tickValue;
  long   _modeCalc;
  double _contractSize;
  double _step;
  string _symbol;
  double _points;
  long   _digits;

 public:
  LotCalculator(string inpSymbol = "") { setSymbol(inpSymbol); };
  ~LotCalculator() { ; }

  void setSymbol(string sym)
  {
    if (sym == "") {
      _symbol = Symbol();
    } else {
      _symbol = sym;
    }
    _modeCalc     = SymbolInfoInteger(_symbol, SYMBOL_TRADE_CALC_MODE);
    _digits       = SymbolInfoInteger(_symbol, SYMBOL_DIGITS);
    _tickValue    = SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE);
    _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    _step         = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
    _points       = SymbolInfoDouble(_symbol, SYMBOL_POINT);
  }

  double LotsByBalancePercent(double BalancePercent, double Distance)
  {
    double risk = AccountInfoDouble(ACCOUNT_BALANCE) * BalancePercent / 100;
    return CalculateLots(risk, Distance);
  }

  double LotsByMoney(double Money, double Distance)
  {
    double risk = fabs(Money);
    return CalculateLots(risk, Distance);
  }

  double CalculateLots(double risk, double distance)  // distance in pips
  {
    distance *= 10;
    if (distance == 0) {
      Print(__FUNCTION__, " ", "Set Distance");
      return 0;
    }

    // FOREX
    if (_modeCalc == 0) {
      return NormalizeDouble(risk / distance / _tickValue, 2);
    }

    // FUTUROS
    if (_modeCalc == 1 && _step != 1.0) {
      double c = _contractSize * _step;
      return NormalizeDouble(risk / (distance * c), 2);
    }

    // FUTUROS SIN DECIMALES
    if (_modeCalc == 1 && _step == 1.0) {
      double c = _contractSize * _step;
      return MathFloor(risk / (distance * c) * 100);
    }

    return 0;
  }
};
LotCalculator* lotProvider;

// NOTE: input parameters
// ------------------------------------------------------------------
#ifdef MOVING_AVERAGE_ON
input string             Iema1               = "== Moving Average Fast Setup ==";  // == Moving Average Setup ==
input int                maFast_Period       = 50;                                 // Period
int                      maFast_Shift        = 0;                                  // Ma Shift
input ENUM_MA_METHOD     maFast_Method       = MODE_EMA;                           // Method
input ENUM_APPLIED_PRICE maFast_AppliedPrice = PRICE_CLOSE;                        // Applied Price
input string             Iema2               = "== Moving Average Slow Setup ==";  // == Moving Average Setup ==
input int                maSlow_Period       = 200;                                // Period
int                      maSlow_Shift        = 0;                                  // Ma Shift
input ENUM_MA_METHOD     maSlow_Method       = MODE_EMA;                           // Method
input ENUM_APPLIED_PRICE maSlow_AppliedPrice = PRICE_CLOSE;                        // Applied Price

class MovingAverage
{
  string          _symbol;
  ENUM_TIMEFRAMES _tf;
  int             _handle;

  struct MovingAverageParameters {
    int                setup0;  //  Period
    int                setup1;  //  Ma Shift
    ENUM_MA_METHOD     setup2;  //  Method
    ENUM_APPLIED_PRICE setup3;  //  Applied Price
  };
  MovingAverageParameters _setup;

 public:
  MovingAverage()
  {
    _symbol = _Symbol;
    _tf     = Period();
  }
  MovingAverage(string Symbol, ENUM_TIMEFRAMES TimeFrame)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
  }
  ~MovingAverage() { ; }

  void setHandle()
  {
    _handle = iMA(_symbol, _tf,
                  _setup.setup0,
                  _setup.setup1,
                  _setup.setup2,
                  _setup.setup3);
  }
  void setSetup(int set0, int set1, ENUM_MA_METHOD set2, ENUM_APPLIED_PRICE set3)
  {
    _setup.setup0 = set0;
    _setup.setup1 = set1;
    _setup.setup2 = set2;
    _setup.setup3 = set3;
    setHandle();
  }
  double calculate(int buffer, int shift)
  {
    double value[1];
    int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
    if (copy > 0) {
      return value[0];
    }
    return -1;
  }
  double index(int shift)
  {
    return calculate(0, shift);
  }
};
MovingAverage* emaFast;
MovingAverage* emaSlow;
#endif

input string             tADX            = "== ADX Setup ==";  // == ADX Setup ==
input bool               AdxOn           = true; // ADX ON:
input int                AdxPeriod       = 14;                 // Period
input double             AdxLevelMain    = 25;                 // Main Level to trade
double             AdxLevelBuy     = 15;                 // Level to Buy
double             AdxLevelSell    = 15;                 // Level to Sell

class ADX
{
  string _symbol;
  ENUM_TIMEFRAMES    _tf;
  double _levelMain;
  double _levelPlus;
  double _levelMinus;
  int    _handle;

  struct ADXParameters {
    int setup0;  // Period
  };
  ADXParameters _setup;

 public:
  ADX()
  {
    _symbol     = _Symbol;
    _tf         = _Period;
    _levelMain  = AdxLevelMain;
    _levelPlus  = AdxLevelBuy;
    _levelMinus = AdxLevelSell;
    setSetup(AdxPeriod);
    setHandle();
  }
  ADX(string Symbol, ENUM_TIMEFRAMES TimeFrame)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
    setSetup(AdxPeriod);
    setHandle();
  }
  ~ADX() { ;}

  void setSetup(int set0)
  {
    _setup.setup0 = set0;
    
  }

  void setHandle()
  {
    _handle = iADX(_symbol, _tf, _setup.setup0);
    Print(__FUNCTION__," ","_handle ADX"," ",_handle);
  }

  double calculate(int buffer, int shift)
  {
    double value[1];
    int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
    if (copy > 0) {
      return value[0];
    }
    return -1;
  }

  // LINES:
  double Main(int shift)
  {
    return calculate(0, shift);
  }
  double PlusDi(int shift)
  {
    return calculate(1, shift);
  }
  double MinusDi(int shift)
  {
    return calculate(2, shift);
  }

  // DIRECTIONS:
  bool bull(int shift)
  {
    if (PlusDi(shift) > MinusDi(shift)) {
      return true;
    }
    return false;
  }
  bool bear(int shift)
  {
    if (PlusDi(shift) < MinusDi(shift)) {
      return true;
    }
    return false;
  }

  // LEVEL CROSSES
  bool MainCrossLevel(int shift)
  {
    double actual = calculate(0, shift);
    double before = calculate(0, shift + 1);
    if ((actual > _levelMain) && (before <= _levelMain)) {
      return true;
    }
    return false;
  }
  bool PlusDiCrossLevel(int shift)
  {
    double actual = calculate(1, shift);
    double before = calculate(1, shift + 1);
    if ((actual > _levelPlus) && (before <= _levelPlus)) {
      return true;
    }
    return false;
  }
  bool MinusDiCrossLevel(int shift)
  {
    double actual = calculate(2, shift);
    double before = calculate(2, shift + 1);
    if ((actual > _levelMinus) && (before <= _levelMinus)) {
      return true;
    }
    return false;
  }
};
ADX* adx;

input string       T0                      = "== Trade Setup ==";        // == Trade Setup ==
input ModeCalcLots modeCalcLots            = FixLots;                    // Mode to Calc Lots:
input double       userMoney               = 10;                         // Setup Lots by "Money":
input double       userBalancePer          = 0.1;                        // Setup Lots by "Account Percent":
input double       userLots                = 0.01;                       // Setup Lots by "Fix Lots":
input string       Tsl                     = "== Stop Loss Setup ==";    // == Stop Loss Setup ==
input sl_modes     sl_mode                 = sl_by_atr;                  // Sl Mode:
input int          sl_atr_multiplier       = 2;                          // ATR multiplier:
input int          userSLpips              = 20;                         // Pips SL
input string       Ttp                     = "== Take Profit Setup ==";  // == Take Profit Setup ==
input tp_modes     tp_mode                 = tp_by_multiplier;           // TP Mode:
input int          tp_multiplier           = 2;                          // SL multiplier:
input int          userTPpips              = 20;                         // Pips TP
input string       TtpOptions              = "== Close All Options ==";  // == Close All Options ==
input bool         closeAllControlON       = false;                      // Close All Control ON:
input CloseAllMode closeBy                 = CloseByMoney;               // Close All Mode:
input double       closeAllMoney           = 100;                        // Close by Money Winning $(+)
input double       closeAllMoneyLoss       = -100;                       // Close by Money Lossing $(-)
input double       accountPerWin           = 1;                          // Account Percent Win (+)
input double       accountPerLos           = -1;                         // Account Percent Loss(-)
input bool         closeAllInOpositeSignal = false;                      // CLose All In Oposite Signal
input string       T1                      = "== Timer ==";              // Timer
input string       timeStart               = "00:00:00";                 // Time Start GMT
input string       timeEnd                 = "23:59:59";                 // Time End GMT
input string       TZ                      = "== Notifications ==";      // Notifications
input bool         notifications           = false;                      // Notifications
input bool         desktop_notifications   = false;                      // Desktop MT4 Notifications
input bool         email_notifications     = false;                      // Email Notifications
input bool         push_notifications      = false;                      // Push Mobile Notifications
input int          magico                  = 38;                         // Magic Number:

// ------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////
// Global Variables:
//////////////////////////////////////////////////////////////////////

class CNewCandle
{
 private:
  int             velasInicio;
  string          m_symbol;
  ENUM_TIMEFRAMES m_tf;

 public:
  CNewCandle();
  CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : m_symbol(symbol), m_tf(tf), velasInicio(iBars(symbol, tf)) {}
  ~CNewCandle();

  bool IsNewCandle();
};
CNewCandle::CNewCandle()
{
  // toma los valores del chart actual
  velasInicio = iBars(Symbol(), Period());
  m_symbol    = Symbol();
  m_tf        = Period();
}
CNewCandle::~CNewCandle() {}
bool CNewCandle::IsNewCandle()
{
  int velasActuales = iBars(m_symbol, m_tf);
  if (velasActuales > velasInicio) {
    velasInicio = velasActuales;
    return true;
  }

  //---
  return false;
}
CNewCandle* newCandle;

bool CloseCandleMode = true;

class ByATR
{
    string _symbol;
    string _side;
    string _mode;  // TP SL
    int    _periods;
    double m;
    int    _handle;

    public:
    ByATR(string inpSymbol, string inpSide, string inpMode, int periods, double multiplier)
    {
        _symbol  = inpSymbol;
        _side    = inpSide;
        _mode    = inpMode;
        _periods = periods;
        m        = multiplier;
        setHandle();
    }
    ~ByATR() { ;}

    void setHandle()
    {
        _handle = iATR(_symbol, PERIOD_CURRENT, _periods);
    }

    double atr(int shift)
    {
        double value[1];
        int    copy = CopyBuffer(_handle, 0, shift, 1, value);
        if (copy > 0) { return value[0]; }
        return -1;
    }

    double calculateLevel()
    {
        double result = 0;
        double mPoint = SymbolInfoDouble(_symbol, SYMBOL_POINT);
        double distance = atr(0) * m;
        double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK); // ok
        double bid = SymbolInfoDouble(_symbol, SYMBOL_BID); // ok

        if (_mode == "SL")   { distance *= -1; }
        if (_side == "buy")  { result = NormalizeDouble(ask + distance, _Digits); }
        if (_side == "sell") { result = NormalizeDouble(bid - distance, _Digits); }
        
        return result;
    }

    double pips()
    {
        return atr(0) * m;
    }
};
ByATR* sl_atr_buy;
ByATR* sl_atr_sell;

interface iConditions {
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
ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;
ConcurrentConditions conditionsToCloseBuy;
ConcurrentConditions conditionsToCloseSell;

interface iActions {
  bool doAction();
};
interface IOrders {
 public:
  virtual void Add()     = 0;
  virtual void Release() = 0;

  virtual bool AddOrder()    = 0;
  virtual bool DeleteOrder() = 0;
  virtual bool Select()      = 0;
};
class Order
{
  int             _id;
  string          _symbol;
  double          _price;
  double          _sl;
  double          _tp;
  double          _lot;
  ENUM_ORDER_TYPE _type;
  int             _magic;
  string          _comment;
  string          _strategy;
  datetime        _expireTime;
  datetime        _signalTime;
  double          _profit;
  double          _tslNext;

 public:
  Order(
      int             id,
      string          symbol,
      double          price,
      double          sl,
      double          tp,
      double          lot,
      ENUM_ORDER_TYPE type,
      int             magic,
      string          comment,
      string          strategy,
      datetime        expireTime,
      datetime        signalTime,
      double          profit) : _id(id),
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
	Order* type(ENUM_ORDER_TYPE type){_type=type; return &this;}
	Order* magic(int magic){_magic=magic; return &this;}
	Order* comment(string comment){_comment=comment; return &this;}
	Order* expireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* signalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* profit(double profit){_profit=profit; return &this;}
	Order* strategy(string strategy){_strategy=strategy; return &this;}
	Order* tslNext(double tslNext){_tslNext=tslNext; return &this;}

   int            id()         { return _id; }
   string         symbol()     { return _symbol; }
   double         price()      { return _price; }
   double         sl()         { return _sl; }
   double         tp()         { return _tp; }
   double         lot()        { return _lot; }
   ENUM_ORDER_TYPE type()      { return _type; }
   int            magic()      { return _magic; }
   string         comment()    { return _comment; }
   string         strategy()   { return _strategy; }
   datetime       expireTime() { return _expireTime; }
   datetime       signalTime() { return _signalTime; }
   // double         profit()     { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit(); return -1; }
   double         profit()     { return _profit; }
   double         tslNext()    { return _tslNext; }
};
class SendNewOrder : public iActions
{
 private:
  Order* newOrder;
  CTrade  trade;

 public:
  SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
  {
    string _symbol = setSymbol(symbol);
    double _price  = setPrice(side, price, _symbol);
    ENUM_ORDER_TYPE _type = SetType(side, price, _symbol);
    trade.SetExpertMagicNumber(magic);

    if (_type == -1) {
      Print(__FUNCTION__, " ", "Imposible to set OrderType");
      return;
    }

    newOrder = new Order();

    newOrder
        .id(0)
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

  ~SendNewOrder()
  {
    delete newOrder;
  }

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

  ENUM_ORDER_TYPE SetType(string side, double priceClient, string sym)
  {
    double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
    double bid = SymbolInfoDouble(sym, SYMBOL_BID);

    if (priceClient == 0) {
      if (side == "buy") {
        return ORDER_TYPE_BUY;
      }
      if (side == "sell") {
        return ORDER_TYPE_SELL;
      }
    } else {
      if (side == "buy") {
        if (priceClient > ask) {
          return ORDER_TYPE_BUY_STOP;
        }
        if (priceClient < ask) {
          return ORDER_TYPE_BUY_LIMIT;
        }
      }
      if (side == "sell") {
        if (priceClient > bid) {
          return ORDER_TYPE_SELL_LIMIT;
        }
        if (priceClient < bid) {
          return ORDER_TYPE_SELL_STOP;
        }
      }
    }

    return -1;
  }

  bool doAction()
  {
    if (!trade.PositionOpen(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), newOrder.sl(), newOrder.tp(), newOrder.comment())) {
      Print(__FUNCTION__, " ", "Cannot Send Order, error: ", GetLastError());
      return false;
    }
    return true;
  }

  Order* lastOrder() 
  {
    return GetPointer(newOrder);
  }

};
SendNewOrder* actionSendOrder;

class ActionCloseOrdersByType : public iActions
{
  CTrade             trade;
  COrderInfo         orderInfo;
  ENUM_POSITION_TYPE _type;
  string             _symbol;
  int                _magic;
  int                _slippage;
  double             _price;

 public:
  ActionCloseOrdersByType(string side, int magic = 0, string symbol = "", int slippage = 10000)
  {
    if (side == "buy") _type = POSITION_TYPE_BUY;
    if (side == "sell") _type = POSITION_TYPE_SELL;
    if (symbol == "") {
      _symbol = Symbol();
    } else {
      _symbol = symbol;
    }
    if (magic != 0) {
      _magic = magic;
    }
    if (slippage != 10000) {
      _slippage = slippage;
    }
  }
  ~ActionCloseOrdersByType() {}

  void setPrice()
  {
    if (_type == POSITION_TYPE_BUY) {
      _price = SymbolInfoDouble(_symbol, SYMBOL_BID);
    }
    if (_type == POSITION_TYPE_SELL) {
      _price = SymbolInfoDouble(_symbol, SYMBOL_ASK);
    }
  }

  bool doAction()
  {
    for (int i = PositionsTotal(); i >= 0; i--) {
      ulong tk = PositionGetTicket(i);
      if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_TYPE) == _type && PositionGetInteger(POSITION_MAGIC) == _magic) {
        trade.PositionClose(tk, 100);
      }
    }
    return true;
  }
};
ActionCloseOrdersByType* actionCloseSells;
ActionCloseOrdersByType* actionCloseBuys;

// ------------------------------------------------------------------
// NOTE: BUY conditions
class BUYcondition1 : public iConditions
{
 public:
  bool evaluate()
  {
    // TODO: condition Buy 1 
if(HeinkinAshi_Open(1) < HeinkinAshi_Close(1))
{
  return true;
}
    return false;
  }
};
BUYcondition1* buyCondition1;
class BUYcondition2 : public iConditions
{
 public:
  bool evaluate()
  {
    // TODO: condition Buy2 
  if(emaFast.index(1) > emaSlow.index(1))
  {
    return true;
  }
    return false;
  }
};
BUYcondition2* buyCondition2;
class BUYcondition3 : public iConditions
{
 public:
  bool evaluate()
  {
    // NOTE: condition Buy 3 
    double volPrev = iVolume(NULL, 0, 2);
    double volCurrent = iVolume(NULL, 0, 1);
    if(volPrev < volCurrent)
    {
      return true;
    }

    return false;
  }
};
BUYcondition3* buyCondition3;
class ConditionCountBuys : public iConditions
{
  CTrade trade;
  int _maxBuys;
  int _magic;
  ENUM_ORDER_TYPE _type;

 public:
  ConditionCountBuys(int maxBuys, int magico, ENUM_ORDER_TYPE type)
  {
    _maxBuys = maxBuys;
    _magic   = magico;
    _type    = type;
  }
  ~ConditionCountBuys() { ; }

  bool evaluate()
  {
    int count = 0;
    for (int i = PositionsTotal()-1; i >= 0; i--) {
      ulong tk = PositionGetTicket(i);
      if (PositionGetInteger(POSITION_TYPE) == _type && PositionGetInteger(POSITION_MAGIC) == _magic) {
        count += 1;
      }
    }
    if (count == _maxBuys) {
      return false;
    }
    return true;
  }
};
ConditionCountBuys* countBuys;

// NOTE: SELL CONDITIONS
class SELLcondition1 : public iConditions
{
 public:
  bool evaluate()
  {
    // NOTE: condition sell 1
if(HeinkinAshi_Open(1) > HeinkinAshi_Close(1))
{
  return true;
}

    return false;
  }
};
SELLcondition1* sellCondition1;
class SELLcondition2 : public iConditions
{
 public:
  bool evaluate()
  {
    // NOTE: condition sell 2
  if(emaFast.index(1) < emaSlow.index(1))
  {
    return true;
  }
    return false;
  }
};
SELLcondition2* sellCondition2;
class SELLcondition3 : public iConditions
{
 public:
  bool evaluate()
  {
    // NOTE: condition sell 3 
    double volPrev = iVolume(NULL, 0, 2);
    double volCurrent = iVolume(NULL, 0, 1);
    if(volPrev < volCurrent)
    {
      return true;
    }

    return false;
  }
};
SELLcondition3* sellCondition3;

class ConditionADX : public iConditions
{
 public:
  bool evaluate()
  {
    // NOTE: condition ADX
    Print(__FUNCTION__," ","adx.Main(1)"," ",adx.Main(1));
    if(adx.Main(1) > AdxLevelMain )
    {
      return true;
    }

    return false;
  }
};
ConditionADX* conditionADX;

class ConditionCountSells : public iConditions
{
  CTrade trade;
  int _maxSells;
  int _magic;
  ENUM_ORDER_TYPE _type;

 public:
  ConditionCountSells(int maxSells, int magico, ENUM_ORDER_TYPE type)
  {
    _maxSells = maxSells;
    _magic   = magico;
    _type    = type;
  }
  ~ConditionCountSells() { ; }

  bool evaluate()
  {
    int count = 0;
    for (int i = PositionsTotal()-1; i >= 0; i--) {
      ulong tk = PositionGetTicket(i);
      if (PositionGetInteger(POSITION_TYPE) == _type && PositionGetInteger(POSITION_MAGIC) == _magic) {
        count += 1;
      }
    }
    if (count == _maxSells) {
      return false;
    }
    return true;
  }
};
ConditionCountSells* countSells;

// NOTE: close Conditions
class ConditionToCloseBuy : public iConditions
{
 public:
  bool evaluate()
  {
    if (closeAllInOpositeSignal) {
      return conditionsToSell.EvaluateConditions();
    }

    // TODO: armar CloseALlControl, ver equityProtection
    if (closeAllControlON) {
      return CloseALlControl();
    }
    return false;
  }
};
ConditionToCloseBuy* conditionCloseBuy;

class ConditionToCloseSell : public iConditions
{
 public:
  bool evaluate()
  {
    if (closeAllInOpositeSignal) {
      return conditionsToBuy.EvaluateConditions();
    }
    if (closeAllControlON) {
      return CloseALlControl();
    }
    return false;
  }
};
ConditionToCloseSell* conditionCloseSell;

// NOTE: OnInit
int OnInit()
{
    sl_atr_buy = new ByATR(_Symbol, "buy", "SL", 14, sl_atr_multiplier);
    sl_atr_sell = new ByATR(_Symbol, "sell", "SL", 14, sl_atr_multiplier);

    newCandle = new CNewCandle();

_handle_heinkin = iCustom(NULL,PERIOD_CURRENT,"Examples\\Heiken_Ashi");
#ifdef MOVING_AVERAGE_ON
emaFast = new MovingAverage(_Symbol, Period());
emaSlow = new MovingAverage(_Symbol, Period());
emaFast.setSetup( maFast_Period, maFast_Shift, maFast_Method, maFast_AppliedPrice );
emaSlow.setSetup( maSlow_Period, maSlow_Shift, maSlow_Method, maSlow_AppliedPrice );
#endif

#ifdef ADX_ON
adx = new ADX(_Symbol, Period());
adx.setSetup(AdxPeriod);
#endif


  //--- CONDITIONS TO OPEN TRADES:
  //--- buys:
  conditionsToBuy.AddCondition(buyCondition1 = new BUYcondition1());
  conditionsToBuy.AddCondition(buyCondition2 = new BUYcondition2());
  conditionsToBuy.AddCondition(buyCondition3 = new BUYcondition3());
  if(AdxOn)conditionsToBuy.AddCondition(conditionADX = new ConditionADX());
  conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1,magico,ORDER_TYPE_BUY));
  // availableToTakeSignalBuy = new ConditionSignalLimiter("buy");
  // conditionsToBuy.AddCondition(availableToTakeSignalBuy);

  //--- sell:
  conditionsToSell.AddCondition(sellCondition1 = new SELLcondition1());
  conditionsToSell.AddCondition(sellCondition2 = new SELLcondition2());
  conditionsToSell.AddCondition(sellCondition3 = new SELLcondition3());
  if(AdxOn)conditionsToSell.AddCondition(conditionADX = new ConditionADX());
  conditionsToSell.AddCondition(countSells = new ConditionCountSells(1,magico,ORDER_TYPE_SELL));
  // availableToTakeSignalSell = new ConditionSignalLimiter("sell");
  // conditionsToSell.AddCondition(availableToTakeSignalSell);

  conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());
  conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());




  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) 
{
  #ifdef MOVING_AVERAGE_ON
  delete emaFast;
  delete emaSlow;
  #endif
  
  #ifdef ADX_ON
  delete adx;
#endif

  delete sl_atr_buy;
  delete sl_atr_sell;
}

// NOTE: OnTick
void OnTick()
{
  //--- CANDLE CLOSE:
  if (CloseCandleMode)
    if (!newCandle.IsNewCandle()) {
      return;
    }
  
  // ------------------------------------------------------------------
   if (conditionsToCloseBuy.EvaluateConditions())
   {
      closeAll("buy");
   }
   if (conditionsToCloseSell.EvaluateConditions())
   {
      closeAll("sell");
   }

  // ------------------------------------------------------------------
  if (conditionsToBuy.EvaluateConditions()) {
    actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
    if (actionSendOrder.doAction()) {
      Notifications(0);
    }
    delete actionSendOrder;
  }
  if (conditionsToSell.EvaluateConditions()) {
    actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
    if (actionSendOrder.doAction()) {
      Notifications(1);
    }
    delete actionSendOrder;
  }

}

//////////////////////////////////////////////////////////////////////

double Bid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
double Ask() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }

double index(int handle, int buffer, int shift)
{
  double value[1];
  int    qnt = CopyBuffer(handle, buffer, shift, 1, value);

  if (qnt > 0) { return value[0]; }
  return -1;
}

double Price(string direction)
{
  double result = 0;
  if (direction == "buy") {
    result = Ask();
    return result;
  }

  if (direction == "sell") {
    result = Bid();
    return result;
  }

  return -1;
}

// NOTE: sl
double SL(string direction)
{
  double result = 0;
  
  if (sl_mode == sl_by_atr)
  {
      if (direction == "buy") { result = sl_atr_buy.calculateLevel(); }
      if (direction == "sell") { result = sl_atr_sell.calculateLevel(); }
  }
  else
  {
      if (direction == "buy") {
          double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          result = ask - userSLpips * 10 * _Point;
        }
      if (direction == "sell") {
          double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
          result = bid + userSLpips * 10 * _Point;
      }      
  }      

  return result;
}

// NOTE: tp
double TP(string direction)
{
  double result = 0;

  if (tp_mode == tp_by_multiplier)
  {
      if (direction == "buy")
      {
          double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          result = ask + (sl_atr_buy.pips() * tp_multiplier);
      }
      if (direction == "sell")
      {
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        result = bid - (sl_atr_sell.pips() * tp_multiplier);
      }
  }
  else
  {
    if (direction == "buy") {
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        result = ask + userTPpips * 10 * _Point;
      }

    if (direction == "sell") {
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        result = bid - userTPpips * 10 * _Point;
      }    
  }
  

  return result;
}
double Lots()
{

  lotProvider = new LotCalculator();
  double lots = -1;
  switch (modeCalcLots) {
    case Money:
      lots = lotProvider.LotsByMoney(userMoney, userTPpips);
      break;
// 
    case AccountPercent:
      lots = lotProvider.LotsByBalancePercent(userBalancePer, userTPpips);
      break;
// 
    case FixLots:
      lots = userLots;
      break;
  }
  delete lotProvider;
  return lots;
}
void Notifications(int type)
{
  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

  text += " ";

  if (!notifications)
    return;
  if (desktop_notifications)
    Alert(text);
  if (push_notifications)
    SendNotification(text);
  if (email_notifications)
    SendMail("MetaTrader Notification", text);
}
string GetTimeFrame(int lPeriod)
{
  switch (lPeriod) {
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

bool CloseALlControl()
{
   switch (closeBy)
   {
      case CloseByMoney:

         if (floatingEA() >= closeAllMoney && closeAllMoney>0) { return true; }
         if (floatingEA() < closeAllMoneyLoss && closeAllMoneyLoss<0) { return true; }
         break;

      case CloseByAccountPercent: 
		{
         double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
         double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;

         if (floatingEA() >= moneyByAccountPerWin && moneyByAccountPerWin>0) { return true; }
         if (floatingEA() < moneyByAccountPerLos && moneyByAccountPerLos<0) { return true; }
         break;
      }
   }
	return false;
}
// clang-format on

void closeAll(string side)
{
  if (side == "buy") {
    actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
    actionCloseBuys.doAction();
    // if (GridON && CheckPointer(gridBuy) != POINTER_INVALID)
    // {
    //    gridBuy.closeGrid();
    //    delete gridBuy;
    // }
    delete actionCloseBuys;
  }
  if (side == "sell") {
    actionCloseSells = new ActionCloseOrdersByType("sell", magico);
    actionCloseSells.doAction();
    // if (GridON && CheckPointer(gridSell) != POINTER_INVALID)
    // {
    //    gridSell.closeGrid();
    //    delete gridSell;
    // }
    delete actionCloseSells;
  }
}

double floatingEA()
{
  double profit = 0;
  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magico) {
      profit += PositionGetDouble(POSITION_PROFIT);
    }
  }

  return profit;
}

double HeinkinAshi_Open(int shift)
{
  double value[1];
  int    copy = CopyBuffer(_handle_heinkin, 0, shift, 1, value);
  if (copy > 0) { return value[0]; }
  return -1;
}
double HeinkinAshi_Close(int shift)
{
  double value[1];
  int    copy = CopyBuffer(_handle_heinkin, 3, shift, 1, value);
  if (copy > 0) { return value[0]; }
  return -1;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+