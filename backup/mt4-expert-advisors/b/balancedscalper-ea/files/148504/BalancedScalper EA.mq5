More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72990

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict

string file_custom_indicator = "";

// Includes
#include <trade\trade.mqh>
COrderInfo orderInfo;
CTrade     trade;

// NOTE: Defines
// ------------------------------------------------------------------
// #define MAX_TRADES_AT_SAME_TIME
// #define CONTROL_CUSTOM_INDICATOR_FILE
#define MOVING_AVERAGE_ON
#define RSI_ON
// #define ADX_ON

float    positions[][2];
datetime dateStart;

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

enum TSLMode { byPips,
               byATR };

// NOTE: input parameters
// ------------------------------------------------------------------
#ifdef MOVING_AVERAGE_ON
input string             Iema1               = "== Moving Average Setup ==";  // ————————————
input int                maFast_Period       = 10;                            // Period
int                      maFast_Shift        = 0;                             // Ma Shift
input ENUM_MA_METHOD     maFast_Method       = MODE_EMA;                      // Method
input ENUM_APPLIED_PRICE maFast_AppliedPrice = PRICE_CLOSE;                   // Applied Price

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
MovingAverage* ema;
#endif

#ifdef ADX_ON
input string             tADX            = "== ADX Setup ==";  // == ADX Setup ==
input int                AdxPeriod       = 14;                 // Period
input ENUM_APPLIED_PRICE AdxAppliedPrice = PRICE_CLOSE;        // Applied Price
input double             AdxLevelMain    = 25;                 // Main Level
input double             AdxLevelBuy     = 15;                 // Level to Buy
input double             AdxLevelSell    = 15;                 // Level to Sell

class ADX
{
  string _symbol;
  int    _tf;
  double _levelMain;
  double _levelPlus;
  double _levelMinus;
  int    _handle;

  struct ADXParameters {
    int setup0;  // Period
    int setup1;  // AppliedPrice
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
    setSetup(AdxPeriod, AdxAppliedPrice);
  }
  ADX(string Symbol, int TimeFrame)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
    setSetup(AdxPeriod, AdxAppliedPrice);
  }
  ~ADX() { ; }

  void setSetup(int set0, int set1)
  {
    _setup.setup0 = set0;
    _setup.setup1 = set1;
  }

  void setHandle()
  {
    _handle = iADX(_symbol, _tf, _setup.setup0, _setup.setup1);
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
#endif

#ifdef RSI_ON
input string             Irsi            = "== RSI Setup ==";  // ————————————
input bool               rsiFilterEntry  = true;               // Use RSI Filter for Entry
input bool               rsiFilterExit   = true;               // Use RSI Filter for Exit
input int                rsiCandle       = 0;                  // Check RSI
input int                rsiPeriod       = 4;                  // Period
input ENUM_APPLIED_PRICE rsiAppliedPrice = PRICE_CLOSE;        // Applied Price
double                   rsiLevelUp      = 70;                 // RSI Level Over Bougth
double                   rsiLevelDn      = 30;                 // RSI Level Over Sold

input double rsiEntryBuyUpper  = 75;  // RSI Buy Entry Upper Value
input double rsiEntryBuyLower  = 65;  // RSI Buy Entry Lower Value
input double rsiExitBuyUpper   = 90;  // RSI Buy Exit Upper Value
input double rsiExitBuyLower   = 85;  // RSI Buy Exit Lower Value
input double rsiEntrySellUpper = 35;  // RSI Sell Entry Upper Value
input double rsiEntrySellLower = 25;  // RSI Sell Entry Lower Value
input double rsiExitSellUpper  = 15;  // RSI Sell Exit Upper Value
input double rsiExitSellLower  = 10;  // RSI Sell Exit Lower Value

class RSI
{
  double _levelUp;
  double _levelDn;
  int    _handle;

 public:
  RSI(string Symbol = NULL, ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT, int Period = 14, ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE, double LevelUp = 70, double LevelDn = 30)
  {
    Setup(Symbol, TimeFrame, Period, AppliedPrice, LevelUp, LevelDn);
  }
  ~RSI() { ; }

  void Setup(string Symbol = NULL, ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT, int Period = 14, ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE, double LevelUp = 70, double LevelDn = 30)
  {
    _handle  = iRSI(Symbol, TimeFrame, Period, AppliedPrice);
    _levelUp = LevelUp;
    _levelDn = LevelDn;
  }

  double calculate(int buffer, int shift)
  {
    double value[1];
    int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
    if (copy > 0) { return value[0]; }
    //---
    return -1;
  }
  double index(int shift)
  {
    return calculate(0, shift);
  }
  double CrossLevelUp(int shift)
  {
    if (index(shift) > _levelUp && index(shift + 1) <= _levelUp) return true;

    return false;
  }
  double CrossLevelDn(int shift)
  {
    if (index(shift) < _levelDn && index(shift + 1) >= _levelDn) return true;

    return false;
  }
};
RSI rsi(NULL, 0, rsiPeriod, rsiAppliedPrice, rsiLevelUp, rsiLevelDn);
#endif

#ifdef MAX_TRADES_AT_SAME_TIME
input int uMaxTrades = 1;  // Max Trades At Same Time:
#endif
input string       T0                      = "== Trade Setup ==";        // ————————————
input ModeCalcLots modeCalcLots            = FixLots;                    // Mode to Calc Lots:
input double       userMoney               = 10;                         // Setup Lots by "Money":
input double       userBalancePer          = 0.1;                        // Setup Lots by "Account Percent":
input double       userLots                = 0.01;                       // Setup Lots by "Fix Lots":
input double       MaxLots                 = 1;                          // Maximum Lots:
input int          nTradesForIncrementLot  = 2;                          // Consecutive Trades For Increment Lot:
input double       uLotMultiplier          = 1.5;                        // Lot Multiplier:
input string       T01                     = "- Take Profit -";          // ————————————
input bool         takeProfitOn            = true;                       // Take Profit On:
input int          userTPpips              = 40;                         // Pips TP
input double       minTP                   = 5;                          // Min TP in pips:
input double       takeProfitReduction     = 10;                         // Take profit Reduction%:
input int          nTradesToStartReduction = 1;                          // Winners Trades to Start Reduction of TP:
input string       T02                     = "- Stop Loss -";            // ————————————
input bool         stopLossOn              = false;                      // Stop Loss On:
input int          userSLpips              = 0;                          // Pips SL
input string       tTailingStop            = "== TailingStop Setup ==";  // ————————————
input bool         TslON                   = false;                      // TSL ON:
TSLMode            userTslMode             = byPips;                     // TSL Mode:
input int          userTslInitialStep      = 25;                         // TSL Initial Step:
input int          userTslStep             = 1;                          // TSL Step:
input int          userTslDistance         = 14;                         // TSL Distance:
string             TtpOptions              = "== Close All Options ==";  // ————————————
bool               closeAllControlON       = false;                      // Close All Control ON:
CloseAllMode       closeBy                 = CloseByMoney;               // Close All Mode:
double             closeAllMoney           = 100;                        // Close by Money Winning $(+)
double             closeAllMoneyLoss       = -100;                       // Close by Money Lossing $(-)
double             accountPerWin           = 1;                          // Account Percent Win (+)
double             accountPerLos           = -1;                         // Account Percent Loss(-)
bool               closeAllInOpositeSignal = false;                      // CLose All In Oposite Signal
string             T1                      = "== Timer ==";              // ————————————
string             timeStart               = "00:00:00";                 // Time Start GMT
string             timeEnd                 = "23:59:59";                 // Time End GMT
string             TZ                      = "== Notifications ==";      // ————————————
bool               notifications           = false;                      // Notifications
bool               desktop_notifications   = false;                      // Desktop MT4 Notifications
bool               email_notifications     = false;                      // Email Notifications
bool               push_notifications      = false;                      // Push Mobile Notifications
input int          magico                  = 2211;                       // Magic Number:

// ------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////
// Global Variables:
//////////////////////////////////////////////////////////////////////

class InRowCounter
{
  int   _wins;
  int   _loss;
  int   _last;
  ulong _lastTk;

 public:
  InRowCounter()
  {
    _wins   = 0;
    _loss   = 0;
    _last   = 0;
    _lastTk = 0;
  }
  ~InRowCounter() { ; }

  int   losses() { return _loss; }
  int   winners() { return _wins; }
  ulong lastTk() { return _lastTk; }

  void setLastTk(ulong tk)
  {
    _lastTk = tk;
  }

  void addWin(ulong tk)
  {
    if (lastWasWin()) {
      _wins += 1;
      _last = 1;
    }
    if (!lastWasWin()) {
      _wins = 1;
      _last = 1;
      _loss = 0;
    }
    setLastTk(tk);
  }

  void addLoss(ulong tk)
  {
    if (lastWasLoss()) {
      _loss += 1;
      _last = -1;
    }
    if (!lastWasLoss()) {
      _loss = 1;
      _last = -1;
      _wins = 0;
    }
    setLastTk(tk);
  }

  bool lastWasWin()
  {
    if (_last == 1 || _last == 0) {
      return true;
    }
    return false;
  }

  bool lastWasLoss()
  {
    if (_last == -1 || _last == 0) {
      return true;
    }
    return false;
  }
};
InRowCounter counter();

class Counter
{
  int _n;

 public:
  Counter() { ; }
  ~Counter() { ; }

  void sum() { _n += 1; }
  void sum(int i) { _n += i; }
  void subtract()
  {
    if (_n > 0) {
      _n -= 1;
    }
  }
  void subtract(int i)
  {
    if (_n > 0) {
      _n -= i;
    }
    if (_n < 0) {
      _n = 0;
    }
  }

  void reset()
  {
    _n = 0;
  }

  void set(int value)
  {
    _n = value;
  }

  int current()
  {
    return _n;
  }
};
Counter countWinners;

interface iLevels
{
  double calculateLevel();
  double pips();
  void   setSide(string);
};
class ByFixPips : public iLevels
{
  string _symbol;
  string _side;
  int    _pips;
  string _mode;  // TP SL
  double _price;

 public:
  ByFixPips(string inpSymbol, string inpSide, int inpPips, string inpMode, double price = 0)
  {
    _pips   = inpPips;
    _symbol = inpSymbol;
    _side   = inpSide;
    _mode   = inpMode;
    _price  = price;
  }
  ~ByFixPips() { ; }

  void setSide(string direction)
  {
    _side = direction;
  }

  double pips()
  {
    return _pips;
  }

  double calculateLevel()
  {
    double mPoint   = SymbolInfoDouble(_symbol, SYMBOL_POINT);
    double distance = _pips * 10 * mPoint;
    double result   = 0;
    double ask      = SymbolInfoDouble(_symbol, SYMBOL_ASK);
    double bid      = SymbolInfoDouble(_symbol, SYMBOL_BID);

    if (_pips == 0) {
      return 0;
    }

    if (_mode == "SL") { distance *= -1; }

    if (_side == "buy") {
      if (_price == 0) _price = ask;

      return _price + distance;
    }

    if (_side == "sell") {
      if (_price == 0) _price = bid;

      return _price - distance;
    }
    return -1;
  }
};
class Levels
{
  iLevels* _level;

 public:
  Levels(iLevels* inpLevel)
  {
    _level = inpLevel;
  }
  ~Levels()
  {
    if (CheckPointer(_level) == 1)
      delete _level;
  }

  double calculateLevel()
  {
    return _level.calculateLevel();
  }
  double pips()
  {
    return _level.pips();
  }
};
Levels* levelTP;

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
ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;
ConcurrentConditions conditionsToCloseBuy;
ConcurrentConditions conditionsToCloseSell;

interface iActions
{
  bool doAction();
};

interface IOrders
{
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

class OrdersList
{
  Order* orders[];

 public:
  OrdersList() { ; }
  ~OrdersList()
  {
    clearList();
  }

  bool AddOrder(Order* order)
  {
    int t = ArraySize(orders);
    if (ArrayResize(orders, t + 1)) {
      orders[t] = order;
      return true;
    }

    return false;
  }

  int qnt()
  {
    return ArraySize(orders);
  }

  bool deleteOrder(int index)
  {
    if (notOverFlow(index)) { delete orders[index]; }

    if (qnt() > index) {
      for (int i = index; i < qnt() - 1; i++) {
        orders[i] = orders[i + 1];
      }
      ArrayResize(orders, qnt() - 1);
      return true;
    }

    return false;
  }

  void clearList()
  {
    for (int i = 0; i < qnt(); i++) {
      if (CheckPointer(orders[i]) != POINTER_INVALID) {
        deleteOrder(i);
      }
    }
  }

	Order* last()
   {
      int lastIndex = ArraySize(orders) - 1;
      if (lastIndex == -1) { return NULL; }
      
		return GetPointer(orders[lastIndex]);
   }

  bool notOverFlow(int index)
  {
    if (index > ArraySize(orders) - 1) return false;
    if (index < 0) return false;
    if (CheckPointer(orders[index]) == POINTER_INVALID) return false;

    return true;
  }
  
  void PrintOrder(const int index)
  {
    // clang-format off
      if (!notOverFlow(index)) { return; }
      if (CheckPointer(orders[index]) == POINTER_INVALID) { return; }
		
      Print("Order ", index, " id: ",          orders[index].id());
      Print("Order ", index, " symbol: ",      orders[index].symbol());
      Print("Order ", index, " type: ",        orders[index].type());
      Print("Order ", index, " lot: ",         orders[index].lot());
      Print("Order ", index, " price: ",       orders[index].price());
      Print("Order ", index, " sl: ",          orders[index].sl());
      Print("Order ", index, " tp: ",          orders[index].tp());
      Print("Order ", index, " magic: ",       orders[index].magic());
      Print("Order ", index, " comment: ",     orders[index].comment());
      Print("Order ", index, " strategy: ",    orders[index].strategy());
      Print("Order ", index, " expire time: ", orders[index].expireTime());
      Print("Order ", index, " signal time: ", orders[index].signalTime());
      Print("Order ", index, " profit: ",      orders[index].profit());
      Print("Order ", index, " tslNext: ",     orders[index].tslNext());
    // clang-format on
  }

  void PrintList()
  {
    for (int i = 0; i < qnt(); i++) {
      PrintOrder(i);
    }
  }

  Order* index(int in)
  {
    return GetPointer(orders[in]);
  }
};
interface iTSL
{
  void   setInitialStep(Order* order);
  void   setNextStep(Order* order);
  double newSL(Order* order);
};

class TslByPips : public iTSL
{
  int    _InitialStep;
  int    _TslStep;
  double _Distance;

 public:
  TslByPips(int InitialStep, int TslStep, double Distance)
  {
    _InitialStep = InitialStep * 10;
    _TslStep     = TslStep * 10;
    _Distance    = Distance * 10;
  }
  ~TslByPips() { ; }

  void setInitialStep(Order* order)
  {
    double mPoint       = SymbolInfoDouble(order.symbol(), SYMBOL_POINT);
    double pointsToMove = _InitialStep * mPoint;
    if (order.type() == ORDER_TYPE_SELL) { pointsToMove *= -1; }

    order.tslNext(order.price() + pointsToMove);
  }

  void setNextStep(Order* order)
  {
    double mPoint       = SymbolInfoDouble(order.symbol(), SYMBOL_POINT);
    double pointsToMove = _TslStep * mPoint;

    if (order.type() == ORDER_TYPE_SELL) { pointsToMove *= -1; }

    order.tslNext(order.tslNext() + pointsToMove);
  }

  double newSL(Order* order)
  {
    double mPoint       = SymbolInfoDouble(order.symbol(), SYMBOL_POINT);
    double pointsToMove = _Distance * mPoint;
    double newSl        = order.sl();

    if (order.type() == ORDER_TYPE_BUY) {
      if (order.tslNext() - pointsToMove > order.sl()) {
        newSl = order.tslNext() - pointsToMove;
      }
    }

    if (order.type() == ORDER_TYPE_SELL) {
      double sl = order.sl() == 0 ? order.price() : order.sl();
      if (order.tslNext() + pointsToMove < sl) {
        newSl = order.tslNext() + pointsToMove;
      }
    }

    return newSl;
  }
};

class TrailingStop
{
  OrdersList* _orders;
  iTSL*       _TslMode;
  CTrade      trade;

 public:
  TrailingStop(OrdersList* ordersList, TSLMode mode)
  {
    _orders = ordersList;

    switch (mode) {
      case byPips:
        _TslMode = new TslByPips(userTslInitialStep, userTslStep, userTslDistance);
        break;
        // case byMA:
        // _TslMode = new TslByMA(userTslMaTf, tslMaPeriod, tslMaShift, tslMaMethod, tslMaAppliedPrice);
        // break;
        // case byATR:
        // _TslMode = new TslByATR(uTslATRTf, uTslATRPeriod, uTslATRShift, uATRmultiplier);
        // break;
    }
  }
  ~TrailingStop()
  {
    // delete _orders;
    delete _TslMode;
  }

  void doTSL()
  {
    for (int i = 0; i < _orders.qnt(); i++) {
      if (CheckPointer(_orders.index(i)) == POINTER_INVALID) {
        Print(__FUNCTION__, " ", "Pointer invalid i= ", i);
        continue;
      }

      // seteo Initial:
      if (_orders.index(i).tslNext() == 0) {
        _TslMode.setInitialStep(_orders.index(i));
      }

      if (MatchNextTsl(_orders.index(i))) {
        double newSl = _TslMode.newSL(_orders.index(i));
        moveSL(_orders.index(i).id(), newSl);
        _TslMode.setNextStep(_orders.index(i));
      }
    }
  }

  bool MatchNextTsl(Order* order)
  {
    double ask = SymbolInfoDouble(order.symbol(), SYMBOL_ASK);
    double bid = SymbolInfoDouble(order.symbol(), SYMBOL_BID);
    if (order.type() == ORDER_TYPE_BUY) {
      if (bid >= order.tslNext()) {
        return true;
      }
    }
    if (order.type() == ORDER_TYPE_SELL) {
      if (ask <= order.tslNext()) {
        return true;
      }
    }
    return false;
  }

  void moveSL(int tk, double newSl)
  {
    // if (OrderSelect(tk, SELECT_BY_TICKET))
    // if(PositionSelectByTicket(tk))

    // {
    // if (!OrderModify(tk, OrderOpenPrice(), newSl, OrderTakeProfit(), 0))
    if (!trade.PositionModify(tk, newSl, 0)) {
      Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " error:", GetLastError());
    } else {
      Print(__FUNCTION__, " trailing stop in tk: ", tk);
    }
    // }
  }
};
TrailingStop* tsl;

OrdersList MainOrders();

class SendNewOrder : public iActions
{
 private:
  Order* newOrder;
  CTrade trade;

 public:
  SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
  {
    string          _symbol = setSymbol(symbol);
    double          _price  = setPrice(side, price, _symbol);
    ENUM_ORDER_TYPE _type   = SetType(side, price, _symbol);
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
    //  delete newOrder;
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

class Reduction
{
  Counter _nextCountToReduction;
  Counter _countReductions;
  int     _iniCountToReduction;
  double  _percent;
  double  _iniPercent;
  int     _mode;
  double  _lastValue;

 public:
  Reduction(int inpCount, double inpPercent, int inpMode)
  {
    _iniCountToReduction = inpCount;
    _nextCountToReduction.set(_iniCountToReduction);
    _iniPercent = inpPercent / 100;
    _percent    = _iniPercent;
    _mode       = inpMode;
    _lastValue  = 1;
  }
  ~Reduction() { ; }

  void reset()
  {
    _countReductions.reset();
    _nextCountToReduction.set(_iniCountToReduction);
    _percent   = _iniPercent;
    _lastValue = 1;
  }

  double value()
  {
    if (openTrades() == 1) { reset(); }

    string side = lastWinDirection() == "buy" ? "sell" : "buy";
    
		if (openTrades(side) >= _nextCountToReduction.current()) 
		{
      _countReductions.sum();
      _nextCountToReduction.sum(_iniCountToReduction);
      _lastValue = NormalizeDouble((1 - (_percent * _countReductions.current())), 2);
      if (_mode == 0) {
        return _lastValue;
      }
      if (_mode == 1) return _percent;
    }
    return _lastValue;
  }
};
Reduction reductor(nTradesToStartReduction, takeProfitReduction, 0);

class IncrementerLots
{
  Counter _nextCount;
  Counter _count;
  int     _iniCount;
  double  _percent;
  double  _iniPercent;
  double  _lastValue;
  string  _side;

 public:
  IncrementerLots(int inpCount, double inpPercent, string side)
  {
    _iniCount = inpCount;
    _nextCount.set(_iniCount);
    _iniPercent = inpPercent;
    _percent    = _iniPercent;
    _lastValue  = 1;
    _side       = side;
  }
  ~IncrementerLots() { ; }

  void reset()
  {
    _count.reset();
    _nextCount.set(_iniCount);
    _percent   = _iniPercent;
    _lastValue = 1;
  }

  double value()
  {
    if (openTrades(_side) >= _nextCount.current()) {
      _count.sum();
      _nextCount.sum(_iniCount);
      _lastValue = MathPow(_percent, _count.current());
      return _lastValue;

    } else if (openTrades(_side) == 0) {
      reset();
    }

    // si no incrementa, tiene que devolver el último valor
    return _lastValue;
  }
};
IncrementerLots* incrementorBuy;
IncrementerLots* incrementorSell;

// ------------------------------------------------------------------
// NOTE: BUY conditions
class BUYcondition1 : public iConditions
{
 public:
  bool evaluate()
  {
    // TODO: condition Buy 1
    if (rsiFilterEntry) {
      return Bid() > ema.index(0) && rsi.index(rsiCandle) > rsiEntryBuyLower && rsi.index(rsiCandle) < rsiEntryBuyUpper;
    } else {
      return Bid() > ema.index(0);
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

    return false;
  }
};
BUYcondition3* buyCondition3;
class ConditionCountBuys : public iConditions
{
  CTrade          trade;
  int             _maxBuys;
  int             _magic;
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
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
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
    if (rsiFilterEntry) {
      return Bid() < ema.index(0) && rsi.index(rsiCandle) > rsiEntrySellLower && rsi.index(rsiCandle) < rsiEntrySellUpper;
    } else {
      return Bid() < ema.index(0);
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

    return false;
  }
};
SELLcondition3* sellCondition3;
class ConditionCountSells : public iConditions
{
  CTrade          trade;
  int             _maxSells;
  int             _magic;
  ENUM_ORDER_TYPE _type;

 public:
  ConditionCountSells(int maxSells, int magico, ENUM_ORDER_TYPE type)
  {
    _maxSells = maxSells;
    _magic    = magico;
    _type     = type;
  }
  ~ConditionCountSells() { ; }

  bool evaluate()
  {
    int count = 0;
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
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

class ConditionCountOrders : public iConditions
{
  CTrade trade;
  int    _maxOrders;
  int    _magic;

 public:
  ConditionCountOrders(int MaxOrders, int Magic)
  {
    _maxOrders = MaxOrders;
    _magic     = Magic;
  }
  ~ConditionCountOrders() { ; }

  bool evaluate()
  {
    int count = 0;
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong tk = PositionGetTicket(i);
      if (PositionGetInteger(POSITION_MAGIC) == _magic) { count += 1; }
    }
    if (count == _maxOrders) { return false; }

    return true;
  }
};
ConditionCountOrders* countOrders;

// NOTE: OnInit
int OnInit()
{
#ifdef CONTROL_CUSTOM_INDICATOR_FILE
  double temp = iCustom(NULL, 0, file_custom_indicator);
  if (GetLastError() == ERR_INDICATOR_CANNOT_CREATE) {
    Alert("Please, install the: " + file_custom_indicator + " indicator");
    return INIT_FAILED;
  }
#endif

  dateStart       = TimeCurrent() - 10 * (24 * 60 * 60);
  incrementorBuy  = new IncrementerLots(nTradesForIncrementLot, uLotMultiplier, "buy");
  incrementorSell = new IncrementerLots(nTradesForIncrementLot, uLotMultiplier, "sell");

  newCandle = new CNewCandle();
  tsl       = new TrailingStop(GetPointer(MainOrders), byPips);
  //   maFast    = iMA(NULL, 0, Fast_Period, 0, Fast_Method, Fast_AppliedPrice);
  //   maSlow    = iMA(NULL, 0, Slow_Period, 0, Slow_Method, Slow_AppliedPrice);

  //--- CONDITIONS TO OPEN TRADES:
  //--- buys:
  conditionsToBuy.AddCondition(buyCondition1 = new BUYcondition1());
  // conditionsToBuy.AddCondition(buyCondition2 = new BUYcondition2());
  // conditionsToBuy.AddCondition(buyCondition3 = new BUYcondition3());
  // conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1, magico, ORDER_TYPE_BUY));
  // availableToTakeSignalBuy = new ConditionSignalLimiter("buy");
  // conditionsToBuy.AddCondition(availableToTakeSignalBuy);

  //--- sell:
  conditionsToSell.AddCondition(sellCondition1 = new SELLcondition1());
  // conditionsToSell.AddCondition(sellCondition2 = new SELLcondition2());
  // conditionsToSell.AddCondition(sellCondition3 = new SELLcondition3());
  // conditionsToSell.AddCondition(countSells = new ConditionCountSells(1, magico, ORDER_TYPE_SELL));
  // availableToTakeSignalSell = new ConditionSignalLimiter("sell");
  // conditionsToSell.AddCondition(availableToTakeSignalSell);

#ifdef MAX_TRADES_AT_SAME_TIME
  conditionsToBuy.AddCondition(countOrders = new ConditionCountOrders(uMaxTrades, magico));
  conditionsToSell.AddCondition(countOrders = new ConditionCountOrders(uMaxTrades, magico));
#endif

  conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());
  conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());

#ifdef MOVING_AVERAGE_ON
  ema = new MovingAverage(_Symbol, Period());
  ema.setSetup(maFast_Period, maFast_Shift, maFast_Method, maFast_AppliedPrice);
#endif

#ifdef ADX_ON
  adx = new ADX(_Symbol, Period());
  adx.setSetup(AdxPeriod, AdxAppliedPrice);
#endif

  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
#ifdef MOVING_AVERAGE_ON
  delete ema;
#endif

#ifdef ADX_ON
  delete adx;
#endif
}

// NOTE: OnTick
void OnTick()
{
  // BuyAveragePrice();
  // SellAveragePrice();
  RefreshCounter();

  HandleTP();

  if (TslON) tsl.doTSL();

  // NOTE: tst rsi;
  // Comment(rsi.index(1));

  //--- CANDLE CLOSE:
  if (CloseCandleMode)
    if (!newCandle.IsNewCandle()) {
      return;
    }

  // ------------------------------------------------------------------
  if (conditionsToCloseBuy.EvaluateConditions()) {
    closeAll("buy");
  }
  if (conditionsToCloseSell.EvaluateConditions()) {
    closeAll("sell");
  }

  // ------------------------------------------------------------------
  // NOTE: BUY
  if (conditionsToBuy.EvaluateConditions()) {
    double lotsBuy = Lots();
    if (lastWinDirection() == "sell") {
      lotsBuy *= incrementorBuy.value();
      if (lotsBuy >= MaxLots) {
        lotsBuy = MaxLots;
      }
    }

    lotsBuy         = NormalizeDouble(lotsBuy, 2);
    actionSendOrder = new SendNewOrder("buy", lotsBuy, "", 0, SL("buy"), TP("buy"), magico);

    if (actionSendOrder.doAction()) {
      // NOTE: addOrder
      MainOrders.AddOrder(actionSendOrder.lastOrder());
      long id = PositionGetTicket(PositionsTotal() - 1);
      MainOrders.last().id(id);
      MainOrders.PrintList();
      Notifications(0);
    }
    delete actionSendOrder;
  }

  // NOTE: SELL
  if (conditionsToSell.EvaluateConditions()) {
    double lotsSell = Lots();

    if (lastWinDirection() == "buy") {
      lotsSell *= incrementorSell.value();
      if (lotsSell >= MaxLots) {
        lotsSell = MaxLots;
      }
    }
    lotsSell        = NormalizeDouble(lotsSell, 2);
    actionSendOrder = new SendNewOrder("sell", lotsSell, "", 0, SL("sell"), TP("sell"), magico);

    if (actionSendOrder.doAction()) {
      MainOrders.AddOrder(actionSendOrder.lastOrder());
      long id = PositionGetTicket(PositionsTotal() - 1);
      MainOrders.last().id(id);
      MainOrders.PrintList();
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
double SL(string direction)
{
  if (!stopLossOn) return 0;
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

double TP(string direction, double price = 0)
{
  if (!takeProfitOn) return 0;

  double result = 0;
  double pips   = userTPpips;

  if (userTPpips == 0) { return 0; }

  if (direction != lastWinDirection() && lastWinDirection() != "") {
    
		double redu = reductor.value();
		Print(__FUNCTION__," reductor: ",redu);
		
		pips *= reductor.value();

    if (pips < minTP) {
      pips = minTP;
    }
  }

  levelTP = new Levels(new ByFixPips(_Symbol, direction, pips, "TP", price));
  result  = levelTP.calculateLevel();
  delete levelTP;

  return NormalizeDouble(result, _Digits);
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
  switch (closeBy) {
    case CloseByMoney:

      if (floatingEA() >= closeAllMoney && closeAllMoney > 0) { return true; }
      if (floatingEA() < closeAllMoneyLoss && closeAllMoneyLoss < 0) { return true; }
      break;

    case CloseByAccountPercent: {
      double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
      double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;

      if (floatingEA() >= moneyByAccountPerWin && moneyByAccountPerWin > 0) { return true; }
      if (floatingEA() < moneyByAccountPerLos && moneyByAccountPerLos < 0) { return true; }
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

// NOTE: HANDLE TP
void HandleTP()
{
  // NOTE: NEW TP depende del reductor de distancia
  double newTPbuy = TP("buy", BuyAveragePrice());
  Print("newTPbuy: ", newTPbuy);

  double newTPsell = TP("sell", SellAveragePrice());
  Print("newTPsell: ", newTPsell);

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong tk = PositionGetTicket(i);
    Print(__FUNCTION__, " tk:", tk);

    int _id = MainOrders.index(i).id();

    if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magico) {
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
        if (trade.PositionModify(tk, PositionGetDouble(POSITION_SL), newTPbuy)) MainOrders.index(i).tp(newTPbuy);
      }
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
        if (trade.PositionModify(tk, PositionGetDouble(POSITION_SL), newTPsell)) MainOrders.index(i).tp(newTPsell);
      }
    }
  }
}

double BuyAveragePrice()
{
  double PipAdjust = 0;

  if (_Digits == 5 || _Digits == 3)
    PipAdjust = 10;
  else if (_Digits == 4 || _Digits == 2)
    PipAdjust = 1;

  double point     = Point() * PipAdjust;
  double Pip_Value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double Pip_Size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

  //---

  int    Total_Buy_Trades = 0;
  double Total_Buy_Size   = 0;
  double Total_Buy_Price  = 0;
  double Buy_Profit       = 0;

  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magico && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
      Total_Buy_Trades++;
      Total_Buy_Price += PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
      Total_Buy_Size += PositionGetDouble(POSITION_VOLUME);
      Buy_Profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
    }
  }

  if (Total_Buy_Trades == 0) return 0;
  if (Total_Buy_Price > 0) { Total_Buy_Price /= Total_Buy_Size; }

  // NOTE: buy average
  double distance = (Buy_Profit / (MathAbs(Total_Buy_Size * Pip_Value)) * Pip_Size);

  double bid           = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  double Average_Price = bid - distance;

  string _name = "Average_Price_Line_Buy_" + Symbol();
  ObjectDelete(0, _name);
  ObjectCreate(0, _name, OBJ_HLINE, 0, 0, Average_Price);
  ObjectSetInteger(0, _name, OBJPROP_WIDTH, 2);
  //---
  color cl = Green;
  if (Buy_Profit < 0) cl = Red;
  if (Buy_Profit == 0) cl = White;
  //---
  ObjectSetInteger(0, _name, OBJPROP_COLOR, cl);

  return NormalizeDouble(Average_Price, _Digits);
}

// NOTE: Sell Average
double SellAveragePrice()
{
  double PipAdjust = 0;
  if (_Digits == 5 || _Digits == 3)
    PipAdjust = 10;
  else if (_Digits == 4 || _Digits == 2)
    PipAdjust = 1;
  double point = Point() * PipAdjust;

  double Pip_Value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double Pip_Size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

  // NOTE: sell average price
  int    Total_Trades = 0;
  double Total_Size   = 0;
  double Total_Price  = 0;
  double Profit       = 0;

  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magico && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
      Total_Trades++;
      Total_Price += PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
      Total_Size += PositionGetDouble(POSITION_VOLUME);
      Profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
    }
  }

  if (Total_Trades == 0) return 0;
  if (Total_Price > 0) { Total_Price /= Total_Size; }

  double distance = (Profit / (MathAbs(Total_Size * Pip_Value)) * Pip_Size);

  double ask           = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double Average_Price = ask + distance;

  string _name = "Average_Price_Line_Sell_" + Symbol();
  ObjectDelete(0, _name);
  ObjectCreate(0, _name, OBJ_HLINE, 0, 0, Average_Price);
  ObjectSetInteger(0, _name, OBJPROP_WIDTH, 2);
  //---
  color cl = Green;
  if (Profit < 0) cl = Red;
  if (Profit == 0) cl = White;
  //---
  ObjectSetInteger(0, _name, OBJPROP_COLOR, cl);

  return NormalizeDouble(Average_Price, _Digits);
}

string lastWinDirection()
{
  struct History {
    ulong          tk;
    long           id;
    long           profit;
    ENUM_DEAL_TYPE type;
  };
  History history[];

  datetime dateFin = TimeCurrent();
  datetime dateIni = dateStart;
  HistorySelect(dateIni, dateFin);
  int total = HistoryDealsTotal();

  if (total == 0) return "";
  int tipo;

  for (int i = total - 1; i >= 0; i--) {
    ulong          tk     = HistoryDealGetTicket(i);
    long           id     = HistoryDealGetInteger(tk, DEAL_POSITION_ID);
    double         profit = HistoryDealGetDouble(tk, DEAL_PROFIT);
    ENUM_DEAL_TYPE type   = HistoryDealGetInteger(tk, DEAL_TYPE);
    long           magic  = HistoryDealGetInteger(tk, DEAL_MAGIC);
    
    if (profit <= 0) continue;
	  if (magic != magico) continue;
   
	  int t = ArraySize(history);
    if (ArrayResize(history, t + 1)) {
      history[t].tk     = tk;
      history[t].id     = tk;
      history[t].profit = profit;
      history[t].type   = type;
      tipo              = (int)type;
      break;
    }
  }

  if (tipo == 0) {
    Print("la ultima ganadora fue SELL");  // devuelvo el valor contrario, por que me toma el type de la que cierra la operacion
    return "sell";
  }
  if (tipo == 1) {
    Print("la ultima ganadora fue BUY");
    return "buy";
  }

  return "";
}

void RefreshCounter()
{
  setPositions(dateStart);
  EliminarDuplicadas();
  int total = ArrayRange(positions, 0) - 1;
  if (total == -1) return;
  ulong tk     = (ulong)positions[total, 0];
  float profit = positions[total, 1];

  if (tk != counter.lastTk()) {
    if (profit > 0.0) { counter.addWin(tk); }
    if (profit < 0.0) { counter.addLoss(tk); }
  }
}

void setPositions(datetime dateIni, datetime dateFin = 0)
{
  if (dateFin == 0) { dateFin = TimeCurrent(); }
  HistorySelect(dateIni, dateFin);
  int total = HistoryDealsTotal();

  for (int i = 0; i < total; i++) {
    ulong tk     = HistoryDealGetTicket(i);
    long  id     = HistoryDealGetInteger(tk, DEAL_POSITION_ID);
    float profit = (float)HistoryDealGetDouble(tk, DEAL_PROFIT);
    ArrayResize(positions, total);
    positions[i, 0] = (float)id;
    positions[i, 1] = profit;
  }
  ArraySort(positions);
  EliminarDuplicadas();
}

void EliminarDuplicadas()
{
  int total = ArrayRange(positions, 0);
  for (int i = 0; i < total; i++) {
    if (i + 1 == total) { break; }
    float id         = positions[i, 0];
    float encontrado = positions[i + 1, 0];
    while (id == encontrado) {
      positions[i, 1] += positions[i + 1, 1];  // suma el profit antes de borrar la duplicada
      ArrayRemove(positions, i + 1, 1);
      total = ArrayRange(positions, 0);
      if (i + 1 == total) { break; }
      encontrado = positions[i + 1, 0];
    }
  }
}

int openTrades(string side = "all")
{
  int count = 0;

  for (int i = PositionsTotal(); i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magico) {
      if (side == "buy" && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
        count++;
      }
      if (side == "sell" && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
        count++;
      }
      if (side == "all") {
        count++;
      }
    }
  }

  return count;
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