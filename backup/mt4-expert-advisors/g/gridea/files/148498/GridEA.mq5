// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72987

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
// #define MOVING_AVERAGE_ON
// #define RSI_ON
// #define ADX_ON

enum WorkMode {
  CloseCandle,  // Close Candle
  Live          // Live
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

enum TSLMode { byPips,
               byATR };

// NOTE: input parameters
// ------------------------------------------------------------------
#ifdef MOVING_AVERAGE_ON
input string             Iema1                 = "== Moving Average Fast Setup ==";    // == Moving Average Setup ==
input int                maFast_Period         = 10;                                   // Period
int                      maFast_Shift          = 0;                                    // Ma Shift
input ENUM_MA_METHOD     maFast_Method         = MODE_EMA;                             // Method
input ENUM_APPLIED_PRICE maFast_AppliedPrice   = PRICE_CLOSE;                          // Applied Price
input string             Iema2                 = "== Moving Average Medium Setup ==";  // == Moving Average Setup ==
input int                maMedium_Period       = 50;                                   // Period
int                      maMedium_Shift        = 0;                                    // Ma Shift
input ENUM_MA_METHOD     maMedium_Method       = MODE_EMA;                             // Method
input ENUM_APPLIED_PRICE maMedium_AppliedPrice = PRICE_CLOSE;                          // Applied Price
input string             Iema3                 = "== Moving Average Slow Setup ==";    // == Moving Average Setup ==
input int                maSlow_Period         = 50;                                   // Period
int                      maSlow_Shift          = 0;                                    // Ma Shift
input ENUM_MA_METHOD     maSlow_Method         = MODE_EMA;                             // Method
input ENUM_APPLIED_PRICE maSlow_AppliedPrice   = PRICE_CLOSE;                          // Applied Price

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
MovingAverage* emaMedium;
MovingAverage* emaSlow;
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
input string             Irsi            = "== RSI Setup ==";  // == RSI Setup ==
input int                rsiPeriod       = 10;                 // Period
input ENUM_APPLIED_PRICE rsiAppliedPrice = PRICE_CLOSE;        // Applied Price
input double             rsiLevelUp      = 70;                 // RSI Level Over Bougth
input double             rsiLevelDn      = 30;                 // RSI Level Over Sold

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

// NOTE: VARIABLES GLOBALES
double   openPrice_Short, openPrice_Long;
WorkMode workMode = Live;
int      GridCount;
string   EA_Name        = "GridEA";
int      PipsDifference = 16;  // Pips Diference:

input string TGrid                   = "== Grid Setup ==";         // ————————————
input bool   gridActive              = true;                       // Grid On:
input int    GridSize                = 10;                         // Distance Between Orders:
input int    GridSteps               = 10;                         // Orders in Grid:
input bool   ExtendGrid              = true;                       // Extend Grid:
input bool   suspendGrid             = false;                      // Suspend Grid:
input bool   shutdownGrid            = false;                      // Shutdown Grid:
input string TTrend                  = "== Trend Setup ==";        // ————————————
input int    LSMAShortPeriod         = 7;                          // Short Period:
input int    LSMALongPeriod          = 16;                         // Long Period:
input string T0                      = "== Trade Setup ==";        // ————————————
ModeCalcLots modeCalcLots            = FixLots;                    // Mode to Calc Lots:
double       userMoney               = 10;                         // Setup Lots by "Money":
double       userBalancePer          = 0.1;                        // Setup Lots by "Account Percent":
input double userLots                = 0.01;                       // Setup Lots by "Fix Lots":
input string T01                     = "- Take Profit -";          // ————————————
input bool   takeProfitOn            = true;                       // Take Profit On:
input int    userTPpips              = 0;                          // Pips TP
input string T02                     = "- Stop Loss -";            // ————————————
input bool   stopLossOn              = true;                       // Stop Loss On:
input int    userSLpips              = 0;                          // Pips SL
input string tTailingStop            = "== TailingStop Setup ==";  // ————————————
input bool   TslON                   = true;                       // TSL ON:
TSLMode      userTslMode             = byPips;                     // TSL Mode:
input string tTslBypips              = "-- TSL By Pips Setup --";  // ————————————
input int    userTslInitialStep      = 25;                         // TSL Initial Step:
input int    userTslStep             = 1;                          // TSL Step:
input int    userTslDistance         = 14;                         // TSL Distance:
input string Tchart                  = "== Chart Setup ==";        // ————————————
bool         eaComment2              = true;                       // Show Comments:
input bool   CloseOnlyManualTrades   = false;                      // Close Only Manual trades:
input bool   DeletePendingOrders     = true;                       // Delete Pending Orders:
string       TtpOptions              = "== Close All Options ==";  // ————————————
bool         closeAllControlON       = false;                      // Close All Control ON:
CloseAllMode closeBy                 = CloseByMoney;               // Close All Mode:
double       closeAllMoney           = 100;                        // Close by Money Winning $(+)
double       closeAllMoneyLoss       = -100;                       // Close by Money Lossing $(-)
double       accountPerWin           = 1;                          // Account Percent Win (+)
double       accountPerLos           = -1;                         // Account Percent Loss(-)
bool         closeAllInOpositeSignal = false;                      // CLose All In Oposite Signal
string       T1                      = "== Timer ==";              // ————————————
string       timeStart               = "00:00:00";                 // Time Start GMT
string       timeEnd                 = "23:59:59";                 // Time End GMT
string       TZ                      = "== Notifications ==";      // ————————————
bool         notifications           = false;                      // Notifications
bool         desktop_notifications   = false;                      // Desktop MT4 Notifications
bool         email_notifications     = false;                      // Email Notifications
bool         push_notifications      = false;                      // Push Mobile Notifications
input int    magico                  = 221129;                     // Magic Number:

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

// NOTE: Order
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
	Order* type(long Type){_type=Type; return &this;}
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
   ENUM_ORDER_TYPE type()       { return _type; }
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
	bool             _filterByMagicOn;
  bool             _filterBySymbolsOn;
  // FilterByMagics*  _magics;
  long  _magics;
  // FilterBySymbols* _symbols;
  string _symbols;

 public:
  OrdersList(bool FilterByMagicOn, long Magics, bool FilterBySymbolsOn, string Symbols ) 
	{ 
		_filterByMagicOn   = FilterByMagicOn;
    _filterBySymbolsOn = FilterBySymbolsOn;
    _magics            = Magics;
    _symbols           = Symbols;
	}
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

	// recorrer las ordenes de mercado y agregar las que no estén en el array
  //+------------------------------------------------------------------+
    void GetMarketOrders()
  {
    for (int i = OrdersTotal() - 1; i >= 0; i--) 
		{
    ulong  tk    = OrderGetTicket(i);
    // ENUM_ORDER_TYPE   Type  = OrderGetInteger(ORDER_TYPE);
    string sym   = OrderGetString(ORDER_SYMBOL);
    long   magic = OrderGetInteger(ORDER_MAGIC);
      
        // if (_filterByMagicOn) if (!_magics.control(magic)) { continue; }
        // if (_filterBySymbolsOn) if (!_symbols.control(sym)) { continue; }
				
				// NOTE: uso por ahora este control para un solo magico y un solo symbolo:        
				if (_filterByMagicOn) if (_magics != magic) { continue; }
        if (_filterBySymbolsOn) if (sym != _symbols) { continue; }
        if (exist(tk) == true) { continue; }

        Order* newOrder = new Order();
        newOrder
            .id(tk)
            .symbol(sym)
            .price(OrderGetDouble(ORDER_PRICE_OPEN))
            .sl(OrderGetDouble(ORDER_SL))
            .tp(OrderGetDouble(ORDER_TP))
            .lot(OrderGetDouble(ORDER_VOLUME_CURRENT))
            .type(OrderGetInteger(ORDER_TYPE))
            .magic(magic)
            .comment(OrderGetString(ORDER_COMMENT))
            .expireTime(0)
            .signalTime(OrderGetInteger(ORDER_TIME_DONE))
            .profit(0);

        if (AddOrder(newOrder))
        {
          PrintOrder(i);
        }
      }
    }

	// ------------------------------------------------------------------

  int qnt()
  {
    return ArraySize(orders);
  }

//+------------------------------------------------------------------+
  
	bool exist(long id_)
  {
    for (int i = qnt() - 1; i >= 0; i--)
    {
      if (id(i) == id_)
      {
        return true;
      }
    }
    return false;
  }

// ------------------------------------------------------------------
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

  int id(int index)
  {
    if (notOverFlow(index)) {
      return orders[index].id();
    }
    return -1;
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
    // if (order.type() == ORDER_TYPE_SELL) { pointsToMove *= -1; }
    if (order.type() == 5) { pointsToMove *= -1; }

    order.tslNext(order.price() + pointsToMove);
  }

  void setNextStep(Order* order)
  {
    double mPoint       = SymbolInfoDouble(order.symbol(), SYMBOL_POINT);
    double pointsToMove = _TslStep * mPoint;

    // if (order.type() == ORDER_TYPE_SELL) { pointsToMove *= -1; }
    if (order.type() == 5) { pointsToMove *= -1; }

    order.tslNext(order.tslNext() + pointsToMove);
  }

  double newSL(Order* order)
  {
    double mPoint       = SymbolInfoDouble(order.symbol(), SYMBOL_POINT);
    double pointsToMove = _Distance * mPoint;
    double newSl        = order.sl();

    // if (order.type() == ORDER_TYPE_BUY) {
    if (order.type() == 4) {
      if (order.tslNext() - pointsToMove > order.sl()) {
        newSl = order.tslNext() - pointsToMove;
      }
    }

    // if (order.type() == ORDER_TYPE_SELL) {
    if (order.type() == 5) {
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
        
				if( moveSL(_orders.index(i).id(), newSl) )
				{
	        _TslMode.setNextStep(_orders.index(i));
				}
      }
    }
  }

  bool MatchNextTsl(Order* order)
  {
    double ask = SymbolInfoDouble(order.symbol(), SYMBOL_ASK);
    double bid = SymbolInfoDouble(order.symbol(), SYMBOL_BID);

		// Print("ask: ", ask, " order.tslNext(): ",order.tslNext(), " order tk: ", order.id(), " type: ", order.type());

    // if (order.type() == ORDER_TYPE_BUY) {
    if (order.type() == 4) {
      if (bid >= order.tslNext()) {
        return true;
      }
    }
    // if (order.type() == ORDER_TYPE_SELL) {
    if (order.type() == 5) {
      if (ask <= order.tslNext()) {				
        return true;
      }
    }
    return false;
  }

  bool moveSL(int tk, double newSl)
  {
    // if (OrderSelect(tk, SELECT_BY_TICKET))
    // if(PositionSelectByTicket(tk))

    // {
    // if (!OrderModify(tk, OrderOpenPrice(), newSl, OrderTakeProfit(), 0))
		
		
		
		// Print(__FUNCTION__," TK		: ",	tk	);
    // PositionSelectByTicket(tk);
    // double orderTP = PositionGetDouble(POSITION_TP);
    
		if (!trade.PositionModify(tk, newSl, 0)) {
      // Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " error:", GetLastError());
			return false;
    } else {
      Print(__FUNCTION__, " trailing stop in tk: ", tk);
			return true;
    }

		return false;
    // }
  }
};
TrailingStop* tsl;

OrdersList MainOrders(true, magico, true, _Symbol);

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

// ------------------------------------------------------------------
// NOTE: BUY conditions
class BUYcondition1 : public iConditions
{
 public:
  bool evaluate()
  {
    // TODO: condition Buy 1
    return LSMA(LSMAShortPeriod, 1) > LSMA(LSMALongPeriod, 1);
    // return false;
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
  ConditionCountBuys(int maxBuys, int Magico, ENUM_ORDER_TYPE type)
  {
    _maxBuys = maxBuys;
    _magic   = Magico;
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
    return LSMA(LSMAShortPeriod, 1) < LSMA(LSMALongPeriod, 1);
    // return false;
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
  ConditionCountSells(int maxSells, int Magico, ENUM_ORDER_TYPE type)
  {
    _maxSells = maxSells;
    _magic    = Magico;
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

//////////////////////////////////////////////////////////////////////
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

  crateButton();
  trade.SetExpertMagicNumber(magico);
  newCandle = new CNewCandle();
  tsl       = new TrailingStop(GetPointer(MainOrders), byPips);

  //   maFast    = iMA(NULL, 0, Fast_Period, 0, Fast_Method, Fast_AppliedPrice);
  //   maSlow    = iMA(NULL, 0, Slow_Period, 0, Slow_Method, Slow_AppliedPrice);

  //--- CONDITIONS TO OPEN TRADES:
  //--- buys:
  conditionsToBuy.AddCondition(buyCondition1 = new BUYcondition1());
  //   conditionsToBuy.AddCondition(buyCondition2 = new BUYcondition2());
  //   conditionsToBuy.AddCondition(buyCondition3 = new BUYcondition3());
  //   conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1,magico,ORDER_TYPE_BUY));
  // availableToTakeSignalBuy = new ConditionSignalLimiter("buy");
  // conditionsToBuy.AddCondition(availableToTakeSignalBuy);

  //--- sell:
  conditionsToSell.AddCondition(sellCondition1 = new SELLcondition1());
  //   conditionsToSell.AddCondition(sellCondition2 = new SELLcondition2());
  //   conditionsToSell.AddCondition(sellCondition3 = new SELLcondition3());
  //   conditionsToSell.AddCondition(countSells = new ConditionCountSells(1,magico,ORDER_TYPE_SELL));
  // availableToTakeSignalSell = new ConditionSignalLimiter("sell");
  // conditionsToSell.AddCondition(availableToTakeSignalSell);

#ifdef MAX_TRADES_AT_SAME_TIME
  conditionsToBuy.AddCondition(countOrders = new ConditionCountOrders(uMaxTrades, magico));
  conditionsToSell.AddCondition(countOrders = new ConditionCountOrders(uMaxTrades, magico));
#endif

  conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());
  conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());

#ifdef MOVING_AVERAGE_ON
  emaFast   = new MovingAverage(_Symbol, Period());
  emaMedium = new MovingAverage(_Symbol, Period());
  emaSlow   = new MovingAverage(_Symbol, Period());
  emaFast.setSetup(maFast_Period, maFast_Shift, maFast_Method, maFast_AppliedPrice);
  emaMedium.setSetup(maMedium_Period, maMedium_Shift, maMedium_Method, maMedium_AppliedPrice);
  emaSlow.setSetup(maSlow_Period, maSlow_Shift, maSlow_Method, maSlow_AppliedPrice);
#endif

#ifdef ADX_ON
  adx = new ADX(_Symbol, Period());
  adx.setSetup(AdxPeriod, AdxAppliedPrice);
#endif

  return (INIT_SUCCEEDED);
}

void OnChartEvent(const int     id,
                  const long&   lparam,
                  const double& dparam,
                  const string& sparam)
{
  if (sparam == "CloseButton") {
    if (CloseOnlyManualTrades == true) CloseAllOrdersV01(DeletePendingOrders, 1);
    if (CloseOnlyManualTrades == false) CloseAllOrdersV02(DeletePendingOrders, 1);
  }
}

void OnDeinit(const int reason)
{
#ifdef MOVING_AVERAGE_ON
  delete emaFast;
  delete emaMedium;
  delete emaSlow;
#endif

#ifdef ADX_ON
  delete adx;
#endif
}

// NOTE: OnTick
void OnTick()
{
  if (TslON) tsl.doTSL();

  //--- CANDLE CLOSE:
  if (workMode == CloseCandle)
    if (!newCandle.IsNewCandle()) {
      return;
    }

  // NOTE: MAIN LOGIC
  if (gridActive == false) { return; }

  //---- test if we want to shutdown or suspend
  if (suspendGrid == true) {  // close unfilled orders and then test if profit target
    ClosePendingOrdersAndPositions(false, "BUY");
    ClosePendingOrdersAndPositions(false, "SELL");
    return;
  }
  if (shutdownGrid == true) {  // close all positions and orders. then exit.. there is nothing more to do
    ClosePendingOrdersAndPositions(true, "BUY");
    ClosePendingOrdersAndPositions(false, "SELL");
    return;
  }

  // ------------------------------------------------------------------
  //---- setup parameters
  int  currentOpen   = 0;
  bool haveLongGrid  = false;
  bool haveShortGrid = false;
  bool myWantLongs   = true;
  bool myWantShorts  = true;

  // ------------------------------------------------------------------
  // if (conditionsToCloseBuy.EvaluateConditions()) {
  //   closeAll("buy");
  // }
  // if (conditionsToCloseSell.EvaluateConditions()) {
  // closeAll("sell");
  // }

  // Check if open positions need to be closed because of change in trend
  if (CheckExitCondition("BUY")) {
    ClosePendingOrdersAndPositions(true, "BUY");
    haveLongGrid = false;
    GridCount    = 0;
    myWantLongs  = false;
    myWantShorts = true;
  }
  if (CheckExitCondition("SELL")) {
    ClosePendingOrdersAndPositions(true, "SELL");
    haveShortGrid = false;
    GridCount     = 0;
    myWantLongs   = true;
    myWantShorts  = false;
  }

  // ------------------------------------------------------------------
  // NOTE: BUY

  currentOpen = openPositions();
  GridCount   = openGrids();

  if (myWantLongs && CheckEntryCondition("BUY")) {
    if (GridCount == 0 && currentOpen != GridSteps) {
      NewLongGrid();
      haveLongGrid = true;
    } else {
      if (GridCount != GridSteps && ExtendGrid) AddToLongGrid();
    }
  }
  if (myWantShorts && CheckEntryCondition("SELL")) {
    if (GridCount == 0 && currentOpen != GridSteps) {
      NewShortGrid();
      haveShortGrid = true;
    } else {
      if (GridCount != GridSteps && ExtendGrid) AddToShortGrid();
    }
  }

  if (eaComment2 == true) f0_3();

  if (currentOpen > 0) {
    // MainOrders.AddOrder(actionSendOrder.lastOrder());
    MainOrders.GetMarketOrders();
    // long id = PositionGetTicket(PositionsTotal() - 1);
  }

  // if (conditionsToBuy.EvaluateConditions()) {
  //   actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
  //   if (actionSendOrder.doAction()) {
  //     // NOTE: addOrder
  //     MainOrders.AddOrder(actionSendOrder.lastOrder());
  //     long id = PositionGetTicket(PositionsTotal() - 1);
  //     MainOrders.last().id(id);
  //     MainOrders.PrintList();
  //     Notifications(0);
  //   }
  //   delete actionSendOrder;
  // }

  // // NOTE: SELL
  // if (conditionsToSell.EvaluateConditions()) {
  //   actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
  //   if (actionSendOrder.doAction()) {
  //     MainOrders.AddOrder(actionSendOrder.lastOrder());
  //     long id = PositionGetTicket(PositionsTotal() - 1);
  //     MainOrders.last().id(id);
  //     MainOrders.PrintList();
  //     Notifications(1);
  //   }
  //   delete actionSendOrder;
  // }
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
double SL(string direction, double iPrice = 0)
{
  if (!stopLossOn) return 0;
  double result = 0;
  double price  = 0;
  if (userSLpips == 0) { return 0; }

  if (direction == "buy") {
    price  = iPrice == 0 ? Ask() : iPrice;
    result = price - userSLpips * 10 * _Point;
  }

  if (direction == "sell") {
    price  = iPrice == 0 ? Bid() : iPrice;
    result = price + userSLpips * 10 * _Point;
  }

  return result;
}
double TP(string direction, double iPrice = 0)
{
  if (!takeProfitOn) return 0;
  if (userTPpips == 0) { return 0; }

  double result = 0;
  double price  = 0;

  if (direction == "buy") {
    price  = iPrice == 0 ? Ask() : iPrice;
    result = price + userTPpips * 10 * _Point;
  }

  if (direction == "sell") {
    price  = iPrice == 0 ? Bid() : iPrice;
    result = price - userTPpips * 10 * _Point;
  }

  return result;
}
double Lots()
{
  double MyLots, AB;
  // AB     = AccountBalance();

  MyLots = userLots;
  AB     = AccountInfoDouble(ACCOUNT_BALANCE);
  if (AB > 20000) MyLots = 0.2;
  if (AB > 40000) MyLots = 0.3;
  if (AB > 60000) MyLots = 0.4;
  if (AB > 80000) MyLots = 0.5;
  if (AB > 100000) MyLots = 1;

  return (MyLots);

  // lotProvider = new LotCalculator();
  // double lots = -1;
  // switch (modeCalcLots) {
  //   case Money:
  //     lots = lotProvider.LotsByMoney(userMoney, userTPpips);
  //     break;
  //     //
  //   case AccountPercent:
  //     lots = lotProvider.LotsByBalancePercent(userBalancePer, userTPpips);
  //     break;
  //     //
  //   case FixLots:
  //     lots = userLots;
  //     break;
  // }
  // delete lotProvider;
  // return lots;
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

double LSMADaily(int Rperiod, int shift)
{
  int    i;
  double sum;
  int    length;
  double lengthvar;
  double tmp;
  double wt;

  length = Rperiod;

  sum = 0;
  for (i = length; i >= 1; i--) {
    lengthvar = length + 1;
    lengthvar /= 3;
    tmp = 0;
    tmp = (i - lengthvar) * iClose(NULL, PERIOD_D1, length - i + shift);
    sum += tmp;
  }
  wt = sum * 6 / (length * (length + 1));

  return (wt);
}

double LSMA(int Rperiod, int shift)
{
  int    i;
  double sum;
  int    length;
  double lengthvar;
  double tmp;
  double wt;

  length = Rperiod;

  sum = 0;
  for (i = length; i >= 1; i--) {
    lengthvar = length + 1;
    lengthvar /= 3;
    tmp = 0;
    // tmp = (i - lengthvar) * Close[length - i + shift];
    tmp = (i - lengthvar) * iClose(NULL, 0, length - i + shift);
    sum += tmp;
  }
  wt = sum * 6 / (length * (length + 1));

  return (wt);
}

//+------------------------------------------------------------------+
//| CheckDailyDirection                                              |
//| Check daily direction for trade                                  |
//| return 1 for up, -1 for down, 0 for flat                         |
//+------------------------------------------------------------------+
int CheckDailyDirection()
{
  double Dif;

  Dif = LSMADaily(LSMAShortPeriod, 1) - LSMADaily(LSMALongPeriod, 1);

  if (Dif > 0) return (1);
  if (Dif < 0) return (-1);
  return (0);
}

bool CheckExitCondition(string TradeType)
{
  bool   YesClose;
  double Dif;

  YesClose = false;
  Dif      = LSMA(LSMAShortPeriod, 1) - LSMA(LSMALongPeriod, 1);
  if (TradeType == "BUY" && Dif < 0) YesClose = true;
  if (TradeType == "SELL" && Dif > 0) YesClose = true;

  return (YesClose);
}

bool CheckEntryCondition(string TradeType)
{
  bool   YesTrade;
  double Dif;

  YesTrade = false;

  Dif = LSMA(LSMAShortPeriod, 1) - LSMA(LSMALongPeriod, 1);

  if (TradeType == "BUY" && Dif > 0) YesTrade = true;
  if (TradeType == "SELL" && Dif < 0) YesTrade = true;

  return (YesTrade);
}

void ClosePendingOrdersAndPositions(bool CloseOpenPos, string type)
{
  if (CloseOpenPos) {
    if (type == "BUY") {
      actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
      actionCloseBuys.doAction();
      delete actionCloseBuys;
    }
    if (type == "SELL") {
      actionCloseSells = new ActionCloseOrdersByType("sell", magico);
      actionCloseSells.doAction();
      delete actionCloseSells;
    }
  }

  // Close pending orders
  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    ulong tk = OrderGetTicket(i);
    if (OrderGetString(ORDER_SYMBOL) != _Symbol) { continue; }
    if (OrderGetInteger(ORDER_MAGIC) != magico) { continue; }

    if (OrderSelect(tk)) {
      long orderType = OrderGetInteger(ORDER_TYPE);

      if (type == "BUY" && orderType == ORDER_TYPE_BUY_STOP) {
        trade.OrderDelete(tk);
      }
      if (type == "SELL" && orderType == ORDER_TYPE_SELL_STOP) {
        trade.OrderDelete(tk);
      }
    }
  }
}

void NewLongGrid()
{
  double mPoints = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  openPrice_Long = Ask();

  for (int i = 1; i <= GridSteps; i++) {
    openPrice_Long = openPrice_Long + mPoints * GridSize;

    // ticket = OrderSend(Symbol(), OP_BUYSTOP, Lots, openPrice_Long, 0, sl, tp, GridName, uniqueGridMagic, 0, Green);
    trade.OrderOpen(Symbol(), ORDER_TYPE_BUY_STOP, Lots(), 0, openPrice_Long, SL("buy", openPrice_Long), TP("buy", openPrice_Long));
  }
  GridCount = GridSteps;
}
void AddToLongGrid()
{
  double mPoints = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  int    Num2Add = GridSteps - GridCount;

  for (int i = 1; i <= Num2Add; i++) {
    openPrice_Long = openPrice_Long + mPoints * GridSize;

    // ticket = OrderSend(Symbol(), OP_BUYSTOP, Lots, openPrice_Long, 0, sl, tp, GridName, uniqueGridMagic, 0, Green);
    trade.OrderOpen(Symbol(), ORDER_TYPE_BUY_STOP, Lots(), 0, openPrice_Long, SL("buy", openPrice_Long), TP("buy", openPrice_Long));
  }
  GridCount = GridSteps;
}
void NewShortGrid()
{
  double mPoints  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  openPrice_Short = Bid();

  for (int i = 1; i <= GridSteps; i++) {
    openPrice_Short = openPrice_Short - mPoints * GridSize;

    trade.OrderOpen(Symbol(), ORDER_TYPE_SELL_STOP, Lots(), 0, openPrice_Short, SL("sell", openPrice_Short), TP("sell", openPrice_Short));
  }
  GridCount = GridSteps;
}
void AddToShortGrid()
{
  double mPoints = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  int    Num2Add = GridSteps - GridCount;

  for (int i = 1; i <= Num2Add; i++) {
    openPrice_Short = openPrice_Short - mPoints * GridSize;

    trade.OrderOpen(Symbol(), ORDER_TYPE_SELL_STOP, Lots(), 0, openPrice_Short, SL("sell", openPrice_Short), TP("sell", openPrice_Short));
  }
  GridCount = GridSteps;
}

int openGrids()
{
  int count = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    ulong  tk    = OrderGetTicket(i);
    long   type  = OrderGetInteger(ORDER_TYPE);
    string sym   = OrderGetString(ORDER_SYMBOL);
    long   magic = OrderGetInteger(ORDER_MAGIC);

    if ((type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP) && magic == magico) {
      count += 1;
    }
  }
  return count;
}
int openPositions()
{
  int count = 0;
  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong  tk    = PositionGetTicket(i);
    long   type  = PositionGetInteger(POSITION_TYPE);
    string sym   = PositionGetString(POSITION_SYMBOL);
    long   magic = PositionGetInteger(POSITION_MAGIC);
    if (sym == _Symbol && magic == magico) {
      count += 1;
    }
  }
  return count;
}

void f0_3()
{
  color  fontColor = clrGold;
  int    fontSize  = 20;
  string font      = "-JS Angsumalin";

  for (int i = 0; i < 8; i++) {
    string _name = EA_Name + (string)(i);
    if (ObjectFind(0, _name) == -1) {
      ObjectCreate(0, _name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_RIGHT);
      ObjectSetInteger(0, _name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, _name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, 100 + (i * 40));
      ObjectSetInteger(0, _name, OBJPROP_COLOR, fontColor);
      ObjectSetInteger(0, _name, OBJPROP_FONTSIZE, fontSize);
      ObjectSetString(0, _name, OBJPROP_FONT, font);
    }
  }

  ObjectSetString(0, EA_Name + "0", OBJPROP_TEXT, "Balance : " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
  ObjectSetString(0, EA_Name + "1", OBJPROP_TEXT, "Equity : " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
  ObjectSetString(0, EA_Name + "2", OBJPROP_TEXT, "Profit : " + DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT), 2));
  ObjectSetString(0, EA_Name + "3", OBJPROP_TEXT, "Orders Total : " + DoubleToString(PositionsTotal(), 0));
  ObjectSetString(0, EA_Name + "4", OBJPROP_TEXT, "Time Server : " + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES));
  ObjectSetString(0, EA_Name + "5", OBJPROP_TEXT, "Spread : " + Symbol() + " " + DoubleToString(SymbolInfoInteger(Symbol(), SYMBOL_SPREAD), 0));
  ObjectSetString(0, EA_Name + "6", OBJPROP_TEXT, "Lots : " + DoubleToString(Lots(), 2));
  ObjectSetString(0, EA_Name + "7", OBJPROP_TEXT, "RHA-V0.1 " + "(" + Symbol() + ")");
  ObjectSetInteger(0, EA_Name + "7", OBJPROP_FONTSIZE, 30);
}

void crateButton()
{
  ObjectCreate(0, "CloseButton", OBJ_BUTTON, 0, 0, 0);
  ObjectSetInteger(0, "CloseButton", OBJPROP_XDISTANCE, 500);
  ObjectSetInteger(0, "CloseButton", OBJPROP_YDISTANCE, 25);
  ObjectSetInteger(0, "CloseButton", OBJPROP_XSIZE, 100);
  ObjectSetInteger(0, "CloseButton", OBJPROP_YSIZE, 50);
  ObjectSetString(0, "CloseButton", OBJPROP_TEXT, "Close All");

  ObjectSetInteger(0, "CloseButton", OBJPROP_COLOR, White);
  ObjectSetInteger(0, "CloseButton", OBJPROP_BGCOLOR, Green);
  ObjectSetInteger(0, "CloseButton", OBJPROP_BORDER_COLOR, White);
  ObjectSetInteger(0, "CloseButton", OBJPROP_BORDER_TYPE, BORDER_FLAT);
  ObjectSetInteger(0, "CloseButton", OBJPROP_BACK, false);
  ObjectSetInteger(0, "CloseButton", OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, "CloseButton", OBJPROP_STATE, false);
  ObjectSetInteger(0, "CloseButton", OBJPROP_FONTSIZE, 12);
}

void CloseAllOrdersV01(bool closePendings, int sleeppage)
{
  actionCloseBuys = new ActionCloseOrdersByType("buy", 0);
  actionCloseBuys.doAction();
  delete actionCloseBuys;
  actionCloseSells = new ActionCloseOrdersByType("sell", 0);
  actionCloseSells.doAction();
  delete actionCloseSells;

  if (closePendings)
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
      ulong tk = OrderGetTicket(i);
      if (OrderGetString(ORDER_SYMBOL) != _Symbol) { continue; }
      if (OrderGetInteger(ORDER_MAGIC) != magico) { continue; }

      if (OrderSelect(tk)) {
        long orderType = OrderGetInteger(ORDER_TYPE);
        if (orderType == ORDER_TYPE_BUY_STOP || orderType == ORDER_TYPE_SELL_STOP) {
          trade.OrderDelete(tk);
        }
      }
    }
}
void CloseAllOrdersV02(bool closePendings, int sleeppage)
{
  actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
  actionCloseBuys.doAction();
  delete actionCloseBuys;
  actionCloseSells = new ActionCloseOrdersByType("sell", magico);
  actionCloseSells.doAction();
  delete actionCloseSells;

  if (closePendings)
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
      ulong tk = OrderGetTicket(i);
      if (OrderGetString(ORDER_SYMBOL) != _Symbol) { continue; }
      if (OrderGetInteger(ORDER_MAGIC) != magico) { continue; }

      if (OrderSelect(tk)) {
        long orderType = OrderGetInteger(ORDER_TYPE);
        if (orderType == ORDER_TYPE_BUY_STOP || orderType == ORDER_TYPE_SELL_STOP) {
          trade.OrderDelete(tk);
        }
      }
    }
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