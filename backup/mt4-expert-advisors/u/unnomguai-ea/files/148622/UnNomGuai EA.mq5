// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=73028

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

#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\PositionInfo.mqh>

string file_custom_indicator = "";

// Includes
#include <trade\trade.mqh>
COrderInfo orderInfo;
CTrade     trade;

// NOTE: Defines
// ------------------------------------------------------------------
#define MAX_TRADES_AT_SAME_TIME
// #define CONTROL_CUSTOM_INDICATOR_FILE
#define MOVING_AVERAGE_ON
// #define RSI_ON
// #define ADX_ON

// NOTE: enums
// ------------------------------------------------------------------
enum ModeMartingale {
  byMultiplier,  // by Multiplier
  byLots,        // by Section Lots
};
enum EntryStrategys {
  bySmaPsar,  // SMA PSAR
  byCCI       // CCI
};
enum CloseAllMode {
  CloseByMoney,
  CloseByAccountPercent, 
	CloseBySide
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
input string             Iema1               = "== Moving Average Setup ==";  // **********
input int                maFast_Period       = 7;                             // Period
int                      maFast_Shift        = 0;                             // Ma Shift
input ENUM_MA_METHOD     maFast_Method       = MODE_LWMA;                     // Method
input ENUM_APPLIED_PRICE maFast_AppliedPrice = PRICE_WEIGHTED;                // Applied Price

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

input string         Tcci           = "== CCI Setup ==";    // ————————————
input int            cciperiod      = 10;                   // CCI period:
input double         ccimax         = 100;                  // CCI MAX:
input double         ccimin         = -100;                 // CCI MIN:
input string         T0             = "== Trade Setup ==";  // ————————————
input EntryStrategys entryStrat     = bySmaPsar;            // Entry Strategy
input ModeCalcLots   modeCalcLots   = FixLots;              // Mode to Calc Lots:
input double         userMoney      = 10;                   // Setup Lots by "Money":
input double         userBalancePer = 0.1;                  // Setup Lots by "Account Percent":
input double         userLots       = 0.01;                 // Setup Lots by "Fix Lots":
input string         T01            = "- Take Profit -";    // ————————————
input bool           takeProfitOn   = true;                 // Take Profit On:
input int            userTPpips     = 0;                    // Pips TP
input string         T02            = "- Stop Loss -";      // ————————————
input bool           stopLossOn     = true;                 // Stop Loss On:
input int            userSLpips     = 0;                    // Pips SL

// NOTE: grid inputs
input string         tGrid                   = "== Gid Setup ==";          // ————————————
input ModeMartingale mode_martingale         = byMultiplier;               // Martingale Mode:
input double         uMultiplier             = 1.5;                        // Multiplier:
input double         MaxLots                 = 1;                          // Maximum Lots:
input double         section0_Pips           = 10;                         // Section 0 Pips:
input int            section0_Orders         = 5;                          // Section 0 Orders:
input double         section0_Lots           = 0.03;                       // Section 0 Lots:
input double         section1_Pips           = 50;                         // Section 1 Pips:
input int            section1_Orders         = 1;                          // Section 1 Orders:
input double         section1_Lots           = 0.05;                       // Section 1 Lots:
input double         section2_Pips           = 100;                        // Section 2 Pips:
input int            section2_Orders         = 1;                          // Section 2 Orders:
input double         section2_Lots           = 0.07;                       // Section 2 Lots:
input double         section3_Pips           = 200;                        // Section 3 Pips:
input int            section3_Orders         = 99;                         // Section 3 Orders:
input double         section3_Lots           = 0.09;                       // Section 3 Lots:
input string         tTailingStop            = "== TailingStop Setup ==";  // ————————————
input bool           TslON                   = true;                       // TSL ON:
TSLMode              userTslMode             = byPips;                     // TSL Mode:
input string         tTslBypips              = "-- TSL By Pips Setup --";  // ————————————
input int            userTslInitialStep      = 25;                         // TSL Initial Step:
input int            userTslStep             = 1;                          // TSL Step:
input int            userTslDistance         = 14;                         // TSL Distance:
input string         TtpOptions              = "== Close Options ==";      // ————————————
input bool           closeAllControlON       = false;                      // Close All Control ON:
input CloseAllMode   closeBy                 = CloseByMoney;               // Close All Mode:
input double         closeAllMoney           = 100;                        // Close by Money Winning $(+)
input double         closeAllMoneyLoss       = -100;                       // Close by Money Lossing $(-)
input double         accountPerWin           = 1;                          // Account Percent Win (+)
input double         accountPerLos           = -1;                         // Account Percent Loss(-)
bool                 closeAllInOpositeSignal = false;                      // CLose All In Oposite Signal
input string         Tlimits                 = "== Limits ==";             // ————————————
input int            maxTradesToday          = 99;                         // Maximum Trades Today:
input string         T1                      = "== Timer ==";              // ————————————
input string         timeStart               = "00:00:00";                 // Time Start GMT
input string         timeEnd                 = "23:59:59";                 // Time End GMT
input string         TZ                      = "== Notifications ==";      // ————————————
bool                 notifications           = false;                      // Notifications
bool                 desktop_notifications   = false;                      // Desktop MT4 Notifications
bool                 email_notifications     = false;                      // Email Notifications
bool                 push_notifications      = false;                      // Push Mobile Notifications
input int            magico                  = 2204;                       // Magic Number:

int isar;
int cci;
// ------------------------------------------------------------------

// clang-format off
//////////////////////////////////////////////////////////////////////
// Note: Objetos
//////////////////////////////////////////////////////////////////////

class Stats
{
  CPositionInfo     PositionInfo;
  CHistoryOrderInfo HistoryInfo;
  CDealInfo         DealInfo;
  // Trades            trades;

  long _magic;
  int   diasBack;
  // Balances:
  float balanceToday;
  float balanceWeek;
  float balanceMonth;
  // Valores Actuales
  float floating;
  float exposicion;  // si todos los trades abiertos se fueran a perdida
  // Lots:
  float lotsOpen;
  float lotsFree;
  //  winners:
  float winQnt;
  float winTotal;
  float winAverage;
  float winAvPercent;
  //  losses:
  float lossQnt;
  float lossTotal;
  float lossAverage;
  float lossAvPercent;
  // Acumulados:
  float today;
  float todayPercent;
  float week;
  float weekPercent;
  // Ratios:
  float br;     // beneficio/Riesgo en $
  float brQnt;  // Ganadoras/Perdedoras en cantidad
  float esperanza;
  // Array de Posiciones
  float positions[][2];

 public:
  Stats(long Magic=0):_magic(Magic) { ;}
  ~Stats() { ;}

  // setups
  void setDiasBack(int days) { diasBack = days; }
  
	// getters:
  float Br(void) { return br; }
  float BrQnt(void) { return brQnt; }
  float Esperanza(void) { return esperanza; }
	long  Magic(void) { return _magic; }
  
	// void   setBalances(void);
  // double Balance(datetime date);
  // void   setPositions(datetime dateIni, datetime dateFin = 0);
  // void   EliminarDuplicadas(void);
  // float  ProfitsFrom(datetime date,datetime date=0);
  // float  Exposition();
  // float  Floating();
  // double Lot(string symbol, double openPrice, double sl, double risk);
  // double RPT(string symbol);
  // float  Today();
  // float  Week();
  // float  Month();
  // void   Averages();

  // Genera el Array de Posiciones entre fecha determinadas eliminado duplicadas
  //+------------------------------------------------------------------+
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
  //+------------------------------------------------------------------+
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
  //+------------------------------------------------------------------+
  float ProfitsFrom(datetime dateIni, datetime dateFin = 0)
  {
    if (dateFin == 0) { dateFin = TimeCurrent(); }
    HistorySelect(dateIni, dateFin);
    int   total  = HistoryDealsTotal();
    float profit = 0;

    for (int i = 0; i < total; i++) 
		{
      ulong tk         = HistoryDealGetTicket(i);
      long  deal_type  = HistoryDealGetInteger(tk, DEAL_TYPE);
      long  deal_magic = HistoryDealGetInteger(tk, DEAL_MAGIC);
      
			if(deal_type==2) { continue; }             // avoid deposits in account
			if(!ControlMagic(deal_magic)){ continue; } // filter by magic

      profit += (float)HistoryDealGetDouble(tk, DEAL_PROFIT);
    }
    return profit;
  }

// cuenta los trades de hoy
// ------------------------------------------------------------------
int TradesToday()
{
		datetime dateIni = iTime(NULL, PERIOD_D1, 0);
    datetime dateFin = TimeCurrent();
    HistorySelect(dateIni, dateFin);
    int   total  = HistoryDealsTotal();
    int   qnt    = 0;

    for (int i = 0; i < total; i++) 
		{
      ulong tk         = HistoryDealGetTicket(i);
      long  deal_type  = HistoryDealGetInteger(tk, DEAL_TYPE);
      long  deal_magic = HistoryDealGetInteger(tk, DEAL_MAGIC);
      
			if(deal_type==2) { continue; }             // avoid deposits in account
			if(!ControlMagic(deal_magic)){ continue; } // filter by magic

      qnt += 1;
    }
    return qnt;
}

bool ControlMagic(long tk_magic)
{
	if(_magic == 0) return true;
  
	return tk_magic == _magic;
}

  // Le pasas una fecha y te devuelve el balance de la cuenta al inicio de ese día
  //+------------------------------------------------------------------+
  double Balance(datetime date)
  {
    float balanceActual = (float)AccountInfoDouble(ACCOUNT_BALANCE);
    float profits       = ProfitsFrom(date);
    return balanceActual - profits;
  }
  // setBalances: te setea balanceToday, balanceWeek, balanceMonth
  //+------------------------------------------------------------------+
  void setBalances(void)
  {
    datetime iniWeek  = iTime(_Symbol, PERIOD_W1, 0);
    datetime iniDay   = iTime(_Symbol, PERIOD_D1, 0);
    datetime iniMonth = iTime(_Symbol, PERIOD_MN1, 0);

    balanceToday = (float)Balance(iniDay);
    balanceWeek  = (float)Balance(iniWeek);
    balanceMonth = (float)Balance(iniMonth);
  }
  // Today: Devuelve el resultado de hoy en % de balance de hoy
  //+------------------------------------------------------------------+
  float Today()
  {
    setBalances();
    datetime iniDay = iTime(_Symbol, PERIOD_D1, 0);
    float    today_ = (float)NormalizeDouble(ProfitsFrom(iniDay) / Balance(iniDay) * 100, 2);
    return today_;
  }
  // TodayProfit: Devuelve el resultado de hoy
  //+------------------------------------------------------------------+
  float TodayProfit()
  {
    setBalances();
    datetime iniDay       = iTime(_Symbol, PERIOD_D1, 0);
    float    _todayProfit = (float)NormalizeDouble(ProfitsFrom(iniDay), 2);
    return _todayProfit;
  }
  float YesterdayProfit()
  {
    setBalances();
    datetime iniDay       = iTime(_Symbol, PERIOD_D1, 1);
    float    _fromYesterdayProfit = (float)NormalizeDouble(ProfitsFrom(iniDay), 2);

    return _fromYesterdayProfit - TodayProfit();
  }
  float HistoricProfit(int days)
  {
    setBalances();
    datetime iniDay       = iTime(_Symbol, PERIOD_D1, days);
    float    _historicProfit = (float)NormalizeDouble(ProfitsFrom(iniDay), 2);

    return _historicProfit;
  }
  // Week: Devuelve el resultado de la semana en % de balance
  //+------------------------------------------------------------------+
  float Week()
  {
    datetime iniDay = iTime(_Symbol, PERIOD_W1, 0);
    float    week_  = (float)NormalizeDouble(ProfitsFrom(iniDay) / Balance(iniDay) * 100, 2);
    return week_;
  }
  // Month: Devuelve el resultado del mes en % de balance
  //+------------------------------------------------------------------+
  float Month()
  {
    datetime iniDay = iTime(_Symbol, PERIOD_MN1, 0);
    float    month_ = (float)NormalizeDouble(ProfitsFrom(iniDay) / Balance(iniDay) * 100, 2);
    return month_;
  }
  // Calcula la perdida de todas las operaciones sobre balance actual
  //+------------------------------------------------------------------+
  float Exposition()
  {
    int    total  = PositionsTotal();
    double riesgo = 0;
    for (int i = 0; i < total; i++) {
      ulong tk = PositionGetTicket(i);
      PositionSelectByTicket(tk);
      string sym = PositionGetString(POSITION_SYMBOL);
      riesgo += RPT(sym);
    }
    return (float)riesgo;
  }
  // Floating: te devuelve el flotante como % del balance actual
  //+------------------------------------------------------------------+
  float Floating()
  {
    float flota         = (float)AccountInfoDouble(ACCOUNT_PROFIT);
    float balanceActual = (float)AccountInfoDouble(ACCOUNT_BALANCE);
    return (float)NormalizeDouble((flota / balanceActual) * 100, 2);
  }
  // Lot: te devuelve el lotaje a usar para un riesgo determinado
  //+------------------------------------------------------------------+
  double Lot(string sym, double openPrice, double sl, double risk)
  {
    ENUM_ORDER_TYPE tipo;
    if (openPrice > sl) {
      tipo = ORDER_TYPE_BUY;
    } else {
      tipo = ORDER_TYPE_SELL;
    }
    double balanceActual = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskUSD       = (balanceActual * risk / 100);

    double riesgo;
    bool   ok = OrderCalcProfit(tipo, sym, 1, openPrice, sl, riesgo);

    double vol = fabs(NormalizeDouble((riskUSD / riesgo), 2));
    return vol;
  }
  // RPT: Risk Per Trade, te devuelve el % de perdida sobre balance actual de una posicion abierta
  //+------------------------------------------------------------------+
  double RPT(string sym)
  {
    PositionSelect(sym);
    ulong           tk        = PositionGetInteger(POSITION_TICKET);
    ENUM_ORDER_TYPE tipo      = (ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE);
    double          vol       = PositionGetDouble(POSITION_VOLUME);
    double          openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double          stop      = PositionGetDouble(POSITION_SL);
    if (stop == 0) { return 0; }
    double riesgo;
    bool   ok            = OrderCalcProfit(tipo, sym, vol, openPrice, stop, riesgo);
    float  balanceActual = (float)AccountInfoDouble(ACCOUNT_BALANCE);
    double riskActual    = NormalizeDouble((riesgo / balanceActual * 100), 2);
    return riskActual;
  }
  // Average Win / Average loss
  //+------------------------------------------------------------------+
  void Averages()
  {
    if (diasBack == 0) { diasBack = 60; }
    datetime fechaini = TimeCurrent() - (diasBack * 24 * 60 * 60);  // 60 días para atrás
    setPositions(fechaini);
    int total = ArrayRange(positions, 0);
    winQnt    = 0;
    lossQnt   = 0;

    for (int i = 0; i < total; i++) {
      float profit = positions[i, 1];
      if (profit > 0) {
        winQnt += 1;
        winTotal += profit;
      }
      if (profit < 0) {
        lossQnt += 1;
        lossTotal += profit;
      }
    }

    if (winQnt > 0) { winAverage = (float)NormalizeDouble(winTotal / winQnt, 2); }
    if (lossQnt > 0) { lossAverage = (float)NormalizeDouble(lossTotal / lossQnt, 2); }
    float balanceIni = (float)Balance(fechaini);
    if (balanceIni > 0) { winAvPercent = (float)NormalizeDouble(winAverage / balanceIni * 100, 2); }
    if (balanceIni > 0) { lossAvPercent = (float)NormalizeDouble(lossAverage / balanceIni * 100, 2); }
    if (lossAverage != 0) { br = (float)NormalizeDouble((winAverage / fabs(lossAverage)) - 1, 2); }  // beneficio/Riesgo en $
    if (lossQnt > 0) { brQnt = (float)NormalizeDouble(winQnt / lossQnt - 1, 2); }                    // Ganadoras/Perdedoras en cantidad
    esperanza = (float)NormalizeDouble((((br + 1) * (brQnt + 1)) - 1), 2);
    ArrayFree(positions);
  }
};
Stats stats(magico);

class Counter
{
  int  count;
  bool _allowNegative; // permitir que la cuenta baje a negativo
 
 public:
  Counter(bool AllowNegative=false) { _allowNegative=AllowNegative;}
  ~Counter() { ; }

  void add()               { count += 1;                                                          }
  void add(int value)      { count += value;                                                      }
  void subtract()          { count -= 1;     if (count < 0 && _allowNegative==false) count = 0; }
  void subtract(int value) { count -= value; if (count < 0 && _allowNegative==false) count = 0; }
  void reset()             { count = 0;                                                           }
  void set(int value)      { count = value;                                                       }
  int  current()           { return count;                                                        }
};
// ------------------------------------------------------------------
class TradesCounter
{
  long magic;

 public:
  TradesCounter(long Magic=0) { magic = Magic; }
  ~TradesCounter() { ; }

	void setMagic(long Magic) {  magic = Magic; }
  
	int openTrades(string side = "all")
  {
    int count = 0;

    for (int i = PositionsTotal(); i >= 0; i--) {
      ulong tk = PositionGetTicket(i);
      if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magic) {
        if (side == "buy" && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { count++; }
        if (side == "sell" && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { count++; }
        if (side == "all") { count++; }
      }
    }

    return count;
	}

	int buys()
	{
		return openTrades("buy");
	}
	int sells()
	{
		return openTrades("sell");
	}
};
TradesCounter tradesCounter(magico);

// ------------------------------------------------------------------

// NOTE: IncrementerLotsBySections class
class IncrementerLotsBySections
{
  // Counter count;
  // double  lastValue;
	
	Counter section;              // cuenta en que section vas (seccion actual)
  Counter TradesForNextSection; // nro de trades abiertos para comenzar la siguiente sección
	int     section_qntTrades[];  // cantidad de trades por seccion
	double  section_lots[];       // lotes por seccion
  double  multiplier;           // Multiplicador de lotes
  string  side;                 // Para distinguir si la grilla es de buy o sell
  string  mode;                 // "byMultiplier", "byLots". Identifica si incrementas por multiplier o usando los lots de cada section
	TradesCounter tradesCounter;  // Objeto que cuenta las posiciones abiertas (para buy, sell, u all)
	double fixlots;               // Lots seteados por el usuario para multiplicar. Es fijo 

 public:
  IncrementerLotsBySections(double Multiplier, string Side, string Mode, double FixLots, long Magic)
  {
    multiplier = Multiplier;
    side       = Side;
		mode       = Mode;
		fixlots    = FixLots;
		tradesCounter.setMagic(Magic);
		
    // lastValue  = 1;
		
  }
  ~IncrementerLotsBySections() { ; }

	// tenés que agregar las secciones antes de usarlo
	void addSection(int qntTrades, double lots)
	{
		int t = ArraySize(section_qntTrades);
		if (ArrayResize(section_qntTrades, t + 1)) { section_qntTrades[t] = qntTrades; }
		if (ArrayResize(section_lots, t + 1))      { section_lots[t] = lots; }
		TradesForNextSection.set(section_qntTrades[0]);
	}

  void reset()
  {
    // count.reset();
    // lastValue  = 1;
		section.set(0);      // empiezo de la seccion 0
		TradesForNextSection.set(section_qntTrades[0]); // seteo la cantidad de trades de la primer section
  }

  double value()
  {
    double result=0;
		
		if (tradesCounter.openTrades(side) <= 1) { reset();}  // si solo está el trade original reseteo

		if( mode == "byMultiplier" )
		{ 
			// result = MathPow(multiplier, count.current()); // calcula el nuevo lotaje por multiplier
			result = fixlots * MathPow(multiplier, tradesCounter.openTrades(side));   // lotaje por multiplier. Incrementa en cada trade (no por tramo)
		}
	
		if( mode == "byLots")
		{
			// si corresponde avanzo de seccion:
			if (tradesCounter.openTrades(side) > TradesForNextSection.current()) 
			{
				section.add();                                                  // avanzo a la siguiente seccion
				TradesForNextSection.add(section_qntTrades[section.current()]); // Seteo el próximo cambio de sección
			}			
			result = section_lots[section.current()];                         // retorno los lotes de esta sección   
  	}
	
		return NormalizeDouble(result,2);
  }
};
IncrementerLotsBySections* incrementorBuy;
IncrementerLotsBySections* incrementorSell;


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

  int iniTime() { return _iniTime; }
  int endTime() { return _endTime; }
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
    int current = (tm.hour * 3600) + (tm.min * 60) + tm.sec;  // ok

    for (int i = 0; i < qnt(); i++) {
      if (!dayControl(i, tm.day_of_week)) { continue; }
      if ((current >= schedules[i].iniTime()) && current < schedules[i].endTime()) {
        setActualSession(i);
        Comment(StructToTime(tm) + " Timer Control - EA ON");
        return true;
      }
    }

    //---
    setActualSession(-1);
    Comment(StructToTime(tm) + " Timer Control - EA OFF");
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

bool CloseCandleMode = false;

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

// ------------------------------------------------------------------
// NOTE: BUY conditions
class BUYcondition1 : public iConditions
{
 public:
  bool evaluate()
  {
    // TODO: condition Buy 1
		if(tradesCounter.buys()>0) return true;

    return ema.index(1) < index(isar, 0, 1);
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
		if(tradesCounter.buys()>0) return true;

    return index(cci, 0, 1) > ccimax;
    // return false;
  }
};
BUYcondition2* buyCondition2;
class BUYcondition3 : public iConditions
{
 public:
  bool evaluate()
  {
    // NOTE: condition Buy 3
    if (tradesCounter.openTrades("buy") >= 1) return Ask() < BuyLimitPrice();

    return true;
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
    if(tradesCounter.sells()>0) return true;
		return ema.index(1) > index(isar, 0, 1);
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
		if(tradesCounter.sells()>0) return true;
    return index(cci, 0, 1) < ccimin;
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
    if (tradesCounter.openTrades("sell") >= 1) return Bid() > SellLimitPrice();

    return true;
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
  // double ima  = iMA(NULL, 0, 7, 0, MODE_LWMA, PRICE_WEIGHTED, 0);
  isar = iSAR(NULL, 0, 0.25, 0.2);
  cci  = iCCI(NULL, 0, cciperiod, PRICE_TYPICAL);

  newCandle = new CNewCandle();
  tsl       = new TrailingStop(GetPointer(MainOrders), byPips);
  //   maFast    = iMA(NULL, 0, Fast_Period, 0, Fast_Method, Fast_AppliedPrice);
  //   maSlow    = iMA(NULL, 0, Slow_Period, 0, Slow_Method, Slow_AppliedPrice);

  //--- CONDITIONS TO OPEN TRADES:
  //--- buys:
  if (entryStrat == bySmaPsar) conditionsToBuy.AddCondition(buyCondition1 = new BUYcondition1());
  if (entryStrat == byCCI) conditionsToBuy.AddCondition(buyCondition2 = new BUYcondition2());
  conditionsToBuy.AddCondition(buyCondition3 = new BUYcondition3());
  //   conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1,magico,ORDER_TYPE_BUY));
  // availableToTakeSignalBuy = new ConditionSignalLimiter("buy");
  // conditionsToBuy.AddCondition(availableToTakeSignalBuy);

  //--- sell:
  if (entryStrat == bySmaPsar) conditionsToSell.AddCondition(sellCondition1 = new SELLcondition1());
  if (entryStrat == byCCI) conditionsToSell.AddCondition(sellCondition2 = new SELLcondition2());
  conditionsToSell.AddCondition(sellCondition3 = new SELLcondition3());
  //   conditionsToSell.AddCondition(countSells = new ConditionCountSells(1,magico,ORDER_TYPE_SELL));
  //   availableToTakeSignalSell = new ConditionSignalLimiter("sell");
  //   conditionsToSell.AddCondition(availableToTakeSignalSell);

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

  sesionControl.AddSession(timeStart, timeEnd);

  // NOTE: GRID Incrementer lots OnInit
  // ------------------------------------------------------------------
  if (mode_martingale == byMultiplier) {
    incrementorBuy  = new IncrementerLotsBySections(uMultiplier, "buy", "byMultiplier", userLots, magico);
    incrementorSell = new IncrementerLotsBySections(uMultiplier, "sell", "byMultiplier", userLots, magico);
  }
  if (mode_martingale == byLots) {
    incrementorBuy  = new IncrementerLotsBySections(uMultiplier, "buy", "byLots", userLots, magico);
    incrementorSell = new IncrementerLotsBySections(uMultiplier, "sell", "byLots", userLots, magico);
  }
  incrementorBuy.addSection(section0_Orders, section0_Lots);
  incrementorBuy.addSection(section1_Orders, section1_Lots);
  incrementorBuy.addSection(section2_Orders, section2_Lots);
  incrementorBuy.addSection(section3_Orders, section3_Lots);
  incrementorSell.addSection(section0_Orders, section0_Lots);
  incrementorSell.addSection(section1_Orders, section1_Lots);
  incrementorSell.addSection(section2_Orders, section2_Lots);
  incrementorSell.addSection(section3_Orders, section3_Lots);

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
  if (TslON) tsl.doTSL();

  //--- CANDLE CLOSE:
  if (CloseCandleMode)
    if (!newCandle.IsNewCandle()) {
      return;
    }

  if (!sesionControl.doSessionControl()) { return; }

  // ------------------------------------------------------------------
  if (conditionsToCloseBuy.EvaluateConditions())  { closeAll("buy"); }
  if (conditionsToCloseSell.EvaluateConditions()) { closeAll("sell"); }


 if(maxTradesToday>0 && stats.TradesToday() >= maxTradesToday) { return; }

  // NOTE: BUY ontick
  // ------------------------------------------------------------------
  if (conditionsToBuy.EvaluateConditions()) {
    double lots = Lots();
    if (tradesCounter.openTrades("buy") >= 1) lots = incrementorBuy.value();
    if (lots >= MaxLots) { lots = MaxLots; }

    actionSendOrder = new SendNewOrder("buy", lots, "", 0, SL("buy"), TP("buy"), magico);
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

  // NOTE: SELL ontick
  if (conditionsToSell.EvaluateConditions()) {
    double lots = Lots();
    if (tradesCounter.openTrades("sell") >= 1) lots = incrementorSell.value();
    if (lots >= MaxLots) { lots = MaxLots; }
    actionSendOrder = new SendNewOrder("sell", lots, "", 0, SL("sell"), TP("sell"), magico);

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
  switch (closeBy) 
	{
    case CloseByMoney:
      if (floatingEA() >= closeAllMoney && closeAllMoney > 0)        { return true; }
      if (floatingEA() < closeAllMoneyLoss && closeAllMoneyLoss < 0) { return true; }
      break;

		case CloseByAccountPercent:
		{
      double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
      double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;

      if (floatingEA() >= moneyByAccountPerWin && moneyByAccountPerWin > 0) { return true; }
      if (floatingEA() < moneyByAccountPerLos && moneyByAccountPerLos < 0)  { return true; }
      break;
		}
		
		case CloseBySide:
      if (floatingEA("sell") >= closeAllMoney && closeAllMoney > 0)        { closeAll("sell"); return false; }
      if (floatingEA("buy") >= closeAllMoney && closeAllMoney > 0)         { closeAll("buy");  return false; }
      if (floatingEA("sell") < closeAllMoneyLoss && closeAllMoneyLoss < 0) { closeAll("sell"); return false; }
      if (floatingEA("buy") < closeAllMoneyLoss && closeAllMoneyLoss < 0)  { closeAll("buy");  return false; }
      break;		
	}
  
	return false;
}
// clang-format on

void closeAll(string side)
{

  if (side == "buy") {
    actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
    actionCloseBuys.doAction();
    delete actionCloseBuys;
  }

  if (side == "sell") {
    actionCloseSells = new ActionCloseOrdersByType("sell", magico);
    actionCloseSells.doAction();
    delete actionCloseSells;
  }
}

double floatingEA(string side="all")
{
  double sell_profit = 0;
  double buy_profit = 0;
  double profit = 0;
  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magico) 
		{
			double positionProfit = PositionGetDouble(POSITION_PROFIT);                        
      if( PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL ) { sell_profit += positionProfit; }
      if( PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY ) { buy_profit += positionProfit; }

      profit += positionProfit;

    }
  }
  
	if (side == "sell") return sell_profit;
  if (side == "buy") return buy_profit;
  
	return profit;
}

double BuyLimitPrice()
{
  double minPrice = 0;

  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magico && PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY) {
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      if (minPrice == 0 || openPrice < minPrice) {
        minPrice = openPrice;
      }
    }
  }

  // determino el precio minimo pero considerando las secciones
  int qnt = tradesCounter.openTrades("buy");

  int limit1 = section0_Orders;
  int limit2 = section0_Orders + section1_Orders;
  int limit3 = section0_Orders + section1_Orders + section2_Orders;

  int pips;
  if (qnt > limit3) return minPrice - section3_Pips * 10 *_Point;
  if (qnt > limit2) return minPrice - section2_Pips * 10 *_Point;
  if (qnt > limit1) return minPrice - section1_Pips * 10 *_Point;
  // return minPrice - section0_Pips * _Point;

  return minPrice - section0_Pips * 10 *_Point;
}

double SellLimitPrice()
{
  double maxPrice = 0;

  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magico && PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL) {
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      if (maxPrice == 0 || openPrice > maxPrice) {
        maxPrice = openPrice;
      }
    }
  }

  // determino el precio minimo pero considerando las secciones
  int qnt = tradesCounter.openTrades("sell");

  int limit1 = section0_Orders;
  int limit2 = section0_Orders + section1_Orders;
  int limit3 = section0_Orders + section1_Orders + section2_Orders;

  int pips;
  if (qnt > limit3) return maxPrice + section3_Pips * 10 *_Point;
  if (qnt > limit2) return maxPrice + section2_Pips * 10 *_Point;
  if (qnt > limit1) return maxPrice + section1_Pips * 10 *_Point;
  // return maxPrice - section0_Pips * _Point;

  return maxPrice + section0_Pips * 10 *_Point;
  // return maxPrice;
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