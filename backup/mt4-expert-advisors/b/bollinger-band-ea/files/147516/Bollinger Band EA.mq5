// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72735

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

class BBands
{
  int _handle;

 public:
  // iBands(string Symbol, ENUM_TIMEFRAMES timeframe, int periods, int bands_shift, double deviation, int applied_price);

  BBands(string Symbol = NULL, ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT, int Periods = 20, int Desviation = 2, ENUM_APPLIED_PRICE Applied_price = PRICE_CLOSE)
  {
    Setup(Symbol, TimeFrame, Periods, Desviation, Applied_price);
  }
  ~BBands() { ; }

  void Setup(string Symbol = NULL, ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT, int Periods = 20, int Desviation = 2, ENUM_APPLIED_PRICE Applied_price = PRICE_CLOSE)
  {
    _handle = iBands(Symbol, TimeFrame, Periods, 0, Desviation, Applied_price);
  }

  double calculate(int buffer, int shift)
  {
    double value[1];
    int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
    if (copy > 0) { return value[0]; }
    //---
    return -1;
  }

	double UpperBand(int shift)
  {
    return calculate(1, shift);
  }
	
	double LowerBand(int shift)
  {
    return calculate(2, shift);
  }
	
	double MidleBand(int shift)
  {
    return calculate(0, shift);
  }
};
BBands bands();

// NOTE: Defines
// #define MOVING_AVERAGE_ON
// #define RSI_ON
// #define ADX_ON

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

enum enumDays { sunday,
                monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                EA_OFF };

enum TSLMode { byPips,
               byATR };

// NOTE: input parameters
// ------------------------------------------------------------------
#ifdef MOVING_AVERAGE_ON
input string             Iema1               = "== Moving Average Fast Setup ==";  // == Moving Average Setup ==
input int                maFast_Period       = 10;                                 // Period
int                      maFast_Shift        = 0;                                  // Ma Shift
input ENUM_MA_METHOD     maFast_Method       = MODE_EMA;                           // Method
input ENUM_APPLIED_PRICE maFast_AppliedPrice = PRICE_CLOSE;                        // Applied Price
input string             Iema2               = "== Moving Average Medium Setup ==";  // == Moving Average Setup ==
input int                maMedium_Period       = 50;                                 // Period
int                      maMedium_Shift        = 0;                                  // Ma Shift
input ENUM_MA_METHOD     maMedium_Method       = MODE_EMA;                           // Method
input ENUM_APPLIED_PRICE maMedium_AppliedPrice = PRICE_CLOSE;                        // Applied Price
input string             Iema3               = "== Moving Average Slow Setup ==";  // == Moving Average Setup ==
input int                maSlow_Period       = 50;                                 // Period
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
  ~RSI() { ;}

  void Setup(string Symbol = NULL, ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT, int Period = 14, ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE, double LevelUp = 70, double LevelDn = 30)
  {
    _handle       = iRSI(Symbol, TimeFrame, Period, AppliedPrice);
    _levelUp      = LevelUp;
    _levelDn      = LevelDn;
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

input string             tbb           = "== BBands Setup ==";  // == BBands Setup ==
input int                bbPeriods     = 15;                    // Periods:
input int                bbDesviation  = 2;                     // Desviation:
input ENUM_APPLIED_PRICE bbApliedPrice = PRICE_CLOSE;           // Applied price:
input string       T0                      = "== Trade Setup ==";        // == Trade Setup ==
ModeCalcLots modeCalcLots                  = FixLots;                    // Mode to Calc Lots:
double       userMoney                     = 10;                         // Setup Lots by "Money":
double       userBalancePer                = 0.1;                        // Setup Lots by "Account Percent":
input double       userLots                = 0.01;                       // Setup Lots by "Fix Lots":
input string       T01                     = "- Take Profit -";          // Setup Take Profit
input bool         takeProfitOn            = false;                      // Take Profit On:
input int          userTPpips              = 0;                          // Pips TP
input string       T02                     = "- Stop Loss -";            // Setup Stop Loss
input bool         stopLossOn              = true;                      // Stop Loss On:
input int          userSLpips              = 20;                         // Pips SL
input string       tTrailingStop           = "== TrailingStop Setup ==";  // == TailingStop Setup ==
input bool         TslON                   = true;                       // TSL ON:
TSLMode            userTslMode             = byPips;                     // TSL Mode:
input string       tTslBypips              = "-- TSL By Pips Setup --";  // -- TSL By Pips Setup --
input int          userTslInitialStep      = 20;                         // TSL Initial Step:
input int          userTslDistance         = 20;                         // TSL Distance:
input int          userTslStep             = 20;                         // TSL Step:
string             TtpOptions              = "== Close All Options ==";  // == Close All Options ==
bool               closeAllControlON       = false;                      // Close All Control ON:
CloseAllMode       closeBy                 = CloseByMoney;               // Close All Mode:
double             closeAllMoney           = 100;                        // Close by Money Winning $(+)
double             closeAllMoneyLoss       = -100;                       // Close by Money Lossing $(-)
double             accountPerWin           = 1;                          // Account Percent Win (+)
double             accountPerLos           = -1;                         // Account Percent Loss(-)
bool               closeAllInOpositeSignal = false;                      // CLose All In Oposite Signal

input string             T1                      = "== Timer ==";                      // Timer
input double             uTimeZone               = -6;                                 // Set your GMT zone:
input bool               day1_On                 = true;                               // Session On:
input enumDays           day1                    = monday;                             // Day
input string             day1_Start              = "00:00:00";                         // Time Start GMT
input string             day1_End                = "23:59:59";                         // Time End GMT
input bool               day2_On                 = true;                               // Session On:
input enumDays           day2                    = tuesday;                            // Day
input string             day2_Start              = "00:00:00";                         // Time Start GMT
input string             day2_End                = "23:59:59";                         // Time End GMT
input bool               day3_On                 = true;                               // Session On:
input enumDays           day3                    = wednesday;                          // Day
input string             day3_Start              = "00:00:00";                         // Time Start GMT
input string             day3_End                = "23:59:59";                         // Time End GMT
input bool               day4_On                 = true;                               // Session On:
input enumDays           day4                    = thursday;                           // Day
input string             day4_Start              = "00:00:00";                         // Time Start GMT
input string             day4_End                = "23:59:59";                         // Time End GMT
input bool               day5_On                 = true;                               // Session On:
input enumDays           day5                    = friday;                             // Day
input string             day5_Start              = "00:00:00";                         // Time Start GMT
input string             day5_End                = "23:59:59";                         // Time End GMT

string             TZ                      = "== Notifications ==";      // Notifications
bool               notifications           = false;                      // Notifications
bool               desktop_notifications   = false;                      // Desktop MT4 Notifications
bool               email_notifications     = false;                      // Email Notifications
bool               push_notifications      = false;                      // Push Mobile Notifications
input int          magico                  = 2204;                       // Magic Number:

// ------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////
// Global Variables:
//////////////////////////////////////////////////////////////////////

class Session
{
   int _iniTime;  // second from 00:00:00 hr of the day
   int _endTime;
   int _dayNumber;

  public:
   // receive time in format 00:00:00
   Session(string iniTime, string endTime, int dayNumber = -1)
   {
      _iniTime   = secondsFromZeroHour(iniTime);
      _endTime   = secondsFromZeroHour(endTime);
      _dayNumber = dayNumber;
   };

   ~Session() {}

   int iniTime()   { return _iniTime; }
   int endTime()   { return _endTime; }
   int dayNumber() { return _dayNumber; }

   int secondsFromZeroHour(string time)
   {
      int hh = (int)StringSubstr(time, 0, 2);
      int mm = (int)StringSubstr(time, 3, 2);
      int ss = (int)StringSubstr(time, 6, 2);

      return (hh * 3600) + (mm * 60) + (ss);
   }
};
class ScheduleController
{
  Session*    schedules[];
  int         _actualIndex;
  Session*    _actualSession;
  int         _currentDay;
  double      _timeZone;  // modificador para ajustar GMT
  MqlDateTime tm;

 public:
  ScheduleController()
  {
    setCurrentDay();
  };
  ~ScheduleController()
  {
    ClearShchedules();
  }

  Session* at() { return _actualSession; }

  void setTimeZone(double hs)
  {
    _timeZone = hs * 60 * 60;
  }

  void setCurrentDay()
  {
    TimeToStruct((TimeGMT() + _timeZone), tm);
    _currentDay = tm.day;  // return the day of the month 1-31

    Print(__FUNCTION__, " ", "_currentDay", " ", _currentDay);
  }

  bool isNewDay()
  {
    TimeToStruct((TimeGMT() + _timeZone), tm);

    if (tm.day != _currentDay) {
      setCurrentDay();
      return true;
    }

    return false;
  }

  void setActualSession(int index)
  {
    _actualIndex = index;

    if (index > -1) {
      _actualSession = schedules[index];
    }
  }

  int qnt()
  {
    return ArraySize(schedules);
  }

  bool AddSession(string ini, string end, int day = -1)
  {
    Session* sc = new Session(ini, end, day);
    int      t  = qnt();
    if (ArrayResize(schedules, t + 1)) {
      schedules[t] = sc;
      return true;
    }

    return false;
  }

  bool ClearShchedules()
  {
    for (int i = 0; i < qnt(); i++) {
      delete schedules[i];
    }
    ArrayFree(schedules);

    return true;
  }

  bool doSessionControl()  // control day and hours for every session
  {
    TimeToStruct((TimeGMT() + _timeZone), tm);
    int current = (tm.hour * 3600) + (tm.min * 60) + tm.sec; // ok

    for (int i = 0; i < qnt(); i++) {
      if (!dayControl(i, tm.day_of_week)) { continue; }
      if ((current >= schedules[i].iniTime()) && current < schedules[i].endTime()) {
        setActualSession(i);
        Comment(StructToTime(tm)+" Timer Control - EA ON");
        return true;
      }
    }

    //---
    setActualSession(-1);
    Comment(StructToTime(tm)+" Timer Control - EA OFF");
    return false;
  }

  bool dayControl(int i, int dayCurrent)
  {
    if (schedules[i].dayNumber() == -1) { return true; }  // para cuando es 
    if (schedules[i].dayNumber() == dayCurrent) { return true; }

    return false;
  }

  void PrintDays()
  {
    for (int i = 0; i < qnt(); i++) {
      PrintDay(i);
    }
  }

  void PrintDay(int i)
  {
    Print("Day Nr: ", schedules[i].dayNumber());
    Print("Day Ini Time: ", schedules[i].iniTime());
    Print("Day End Time: ", schedules[i].endTime());
  }
};
ScheduleController sesionControl;

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
interface iTSL {
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

// ------------------------------------------------------------------
// NOTE: BUY conditions
class BUYcondition1 : public iConditions
{
 public:
  bool evaluate()
  {
    // TODO: condition Buy 1
   double upper = bands.UpperBand(1);
	 
	 Print("upper: ",upper);
  //  Print("low: ", iLow(NULL, 0, 0));

   if (iLow(NULL, 0, 0) < upper && Bid() >= upper) { return true; }
   
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
   double lower = bands.LowerBand(1);
	 Print("lower",lower);

   if(iHigh(NULL, 0, 0) > lower && Bid() <= lower) { return true; }
	 
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

// NOTE: OnInit
int OnInit()
{
  EventSetTimer(1);

  newCandle = new CNewCandle();
  tsl       = new TrailingStop(GetPointer(MainOrders), byPips);
  //   maFast    = iMA(NULL, 0, Fast_Period, 0, Fast_Method, Fast_AppliedPrice);
  //   maSlow    = iMA(NULL, 0, Slow_Period, 0, Slow_Method, Slow_AppliedPrice);

  //--- CONDITIONS TO OPEN TRADES:
  //--- buys:
  conditionsToBuy.AddCondition(buyCondition1 = new BUYcondition1());
  //   conditionsToBuy.AddCondition(buyCondition2 = new BUYcondition2());
  //   conditionsToBuy.AddCondition(buyCondition3 = new BUYcondition3());
  conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1,magico,ORDER_TYPE_BUY));
  // availableToTakeSignalBuy = new ConditionSignalLimiter("buy");
  // conditionsToBuy.AddCondition(availableToTakeSignalBuy);

  //--- sell:
  conditionsToSell.AddCondition(sellCondition1 = new SELLcondition1());
  //   conditionsToSell.AddCondition(sellCondition2 = new SELLcondition2());
  //   conditionsToSell.AddCondition(sellCondition3 = new SELLcondition3());
  conditionsToSell.AddCondition(countSells = new ConditionCountSells(1,magico,ORDER_TYPE_SELL));
  // availableToTakeSignalSell = new ConditionSignalLimiter("sell");
  // conditionsToSell.AddCondition(availableToTakeSignalSell);

  conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());
  conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());


	bands.Setup(NULL, PERIOD_CURRENT, bbPeriods, bbDesviation, bbApliedPrice);

	sesionControl.setTimeZone(uTimeZone);
  if (day1_On) sesionControl.AddSession(day1_Start, day1_End, day1);
  if (day2_On) sesionControl.AddSession(day2_Start, day2_End, day2);
  if (day3_On) sesionControl.AddSession(day3_Start, day3_End, day3);
  if (day4_On) sesionControl.AddSession(day4_Start, day4_End, day4);
  if (day5_On) sesionControl.AddSession(day5_Start, day5_End, day5);

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

  delete newCandle;
  delete tsl;
  // delete trade;

}

void OnTimer()
{
	// Print(bands.UpperBand(0));
  // Print(bands.LowerBand(0));
  // Print(bands.MidleBand(0));
}

// NOTE: OnTick
void OnTick()
{
  if (TslON) tsl.doTSL();

  // NOTE: tst rsi;
  // Comment(rsi.index(1));

  //--- CANDLE CLOSE:
  // if (CloseCandleMode) if (!newCandle.IsNewCandle()) { return; }

  // ------------------------------------------------------------------
  
	if (conditionsToCloseBuy.EvaluateConditions()) { closeAll("buy"); }
  if (conditionsToCloseSell.EvaluateConditions()) { closeAll("sell"); }

	if (!sesionControl.doSessionControl()) { return; }

  // ------------------------------------------------------------------
  if (conditionsToBuy.EvaluateConditions()) 
	{
    actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
    
		if (actionSendOrder.doAction()) {
      // NOTE: addOrder
      MainOrders.AddOrder(actionSendOrder.lastOrder());
      ulong id = PositionGetTicket(PositionsTotal() - 1);
      MainOrders.last().id(id);
      MainOrders.PrintList();
      Notifications(0);
    }
    delete actionSendOrder;
  }

  if (conditionsToSell.EvaluateConditions()) 
	{
    actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
    if (actionSendOrder.doAction()) {
      MainOrders.AddOrder(actionSendOrder.lastOrder());
      ulong id = PositionGetTicket(PositionsTotal() - 1);
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
double TP(string direction)
{
  if (!takeProfitOn) return 0;
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
