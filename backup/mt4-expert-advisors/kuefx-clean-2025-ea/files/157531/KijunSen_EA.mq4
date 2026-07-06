//Available @  https://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                                       https://mario-jemic.com/ | 
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency |  Network             |  Address                                              |
//+------------------------------------------------+-----------------------------------------------+
//|  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
//|  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
//|  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
//|  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//|  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//|  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//+------------------------------------------------+-----------------------------------------------+ 


#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description "Expert Advisor"
#property strict

// MARK: defines
// ------------------------------------------------------------------

#define Section_Custom_Indicator
#define Section_Basic_Strategy
// #define Section_Close
#define Section_Close_Opposite
#define Section_breakeven
#define Section_Traling_Stop
// #define Section_timer
#define Section_Trades_Counters
// #define Section_News

// ------------------------------------------------------------------

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

#define Section_Basic_Conditions
#ifdef Section_Basic_Conditions

class ConditionOncePerCandle : public iConditions
{
  public:
    bool evaluate()
    {
        static datetime last;
        datetime        current = iTime(NULL, 0, 1);
        if (last != current) {
            last = current;
            return true;
        }
        return false;
    }
};
ConditionOncePerCandle conditionOncePerCandle;

void oninit_basic_conditions() { Trader.filters.add(&conditionOncePerCandle); }

#endif

#define Section_Actions_over_orders
#ifdef Section_Actions_over_orders
// MARK: Actions over orders

class ActionCloseBuy : public iActions
{
  public:
    bool execute()
    {
        if (OrderType() == OP_SELL) return false;
        double bid = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
        if (!OrderClose(OrderTicket(), OrderLots(), bid, 0, Black)) {
            Print("Error when try to close order ", GetLastError());
        }
        return true;
    }
};
ActionCloseBuy acCloseBuy;

class ActionCloseSell : public iActions
{
  public:
    bool execute()
    {
        if (OrderType() == OP_BUY) return false;
        double ask = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
        if (!OrderClose(OrderTicket(), OrderLots(), ask, 0, Black)) {
            Print("Error when try to close order ", GetLastError());
        }
        return true;
    }
};
ActionCloseSell acCloseSell;

#endif

#define Section_Entry
#ifdef Section_Entry
// MARK: Section Entry

enum ModeEntry {
    Market, // Market
#ifdef pending_orders_on
    PendingStop, // Pending Stop
    PendingLimit // Pending Limit
#endif
};

input string    TmodeEntry = "== Entry Setup =="; // ————————————————————————
input ModeEntry modeEntry  = Market;              // Mode Entry:
input int       magico     = 1982;                // Magic Number:

#ifdef pending_orders_on
input double uEntryDistance = 10; // Pips distance for pending orders:
#endif

// MARK: funcion Price
double Price(string side, double pips = 0, string _symbol = "")
{
    string symbol = _symbol == "" ? Symbol() : _symbol;
    int    digits = (int)MarketInfo(symbol, MODE_DIGITS);

    MqlTick data;
    SymbolInfoTick(symbol, data);
    double price = side == "buy" ? data.ask : data.bid;

    Print(__FUNCTION__, " ", side, " price: ", price);

#ifdef pending_orders_on
    double points   = MarketInfo(symbol, MODE_POINT);
    double distance = pips * 10 * points;

    if (side == "buy") {
        switch (modeEntry) {
        case PendingStop:
            price += distance;
            break;
        case PendingLimit:
            price -= distance;
            break;
        }
    }

    if (side == "sell") {
        switch (modeEntry) {
        case PendingStop:
            price -= distance;
            break;
        case PendingLimit:
            price += distance;
            break;
        }
    }
#endif

    return NormalizeDouble(price, digits);
}

#endif

#define Section_Lots
#ifdef Section_Lots
// MARK: Section Lots

#define lot_fix_on
#define lot_equity_percent_on
// #define lot_money_on
// #define lot_account_percent_on
// #define lot_range_on
// ------------------------------------------------------------------

enum enum_lot_mode {

#ifdef lot_fix_on
    lot_fix, // Fix Lot
#endif

#ifdef lot_money_on
    lot_money, // Money (require SL)
#endif

#ifdef lot_account_percent_on
    lot_account_percent, // Account Percent (require SL)
#endif

#ifdef lot_equity_percent_on
    lot_equity_percent, // Equity Percent
#endif

#ifdef lot_range_on
    lot_range, // Range
#endif

};

// ------------------------------------------------------------------
input string        tvolumen   = "== Volumen Calculation =="; // ————————————————————————
input enum_lot_mode lot_mode   = lot_fix;                     // Lot Calculation Mode
input double        uLotsValue = 0.01;                        // value to calculate Lots:

#ifdef lot_range_on
input double uRange = 100000; // In Range Mode: 1.0 lot every $
#endif

// MARK: funcion LotsCalculation
double LotsCalculation()
{
    double lots = 0;

    switch (lot_mode) {

#ifdef lot_money_on
    case lot_money:
        Print("el lotaje va por lot_money");
        break;
#endif

#ifdef lot_account_percent_on
    case lot_account_percent:
        Print("el lotaje va por lot_account_percent");
        break;
#endif

#ifdef lot_equity_percent_on
    case lot_equity_percent:
        lots = lotsProvider.LotsByEquityPercent(uLotsValue);
        break;
#endif

#ifdef lot_range_on
    case lot_range:
        Print("el lotaje va por lot_range");
        break;
#endif

#ifdef lot_fix_on
    case lot_fix:
        lots = uLotsValue;
        break;
#endif
    }
    //
    return lots;
}

class LotCalculator
{
    double _tickValue;
    double _modeCalc;
    double _contractSize;
    double _step;
    string _symbol;
    double _points;
    double _digits;
    double _min;
    double _max;

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
        _tickValue    = MarketInfo(_symbol, MODE_TICKVALUE);
        _modeCalc     = MarketInfo(_symbol, MODE_PROFITCALCMODE);
        _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        _step         = MarketInfo(_symbol, MODE_LOTSTEP);
        _points       = MarketInfo(_symbol, MODE_POINT);
        _digits       = MarketInfo(_symbol, MODE_DIGITS);
        _min          = MarketInfo(_symbol, MODE_MINLOT);
        _max          = MarketInfo(_symbol, MODE_MAXLOT);
    }

    double LotsByBalancePercent(double BalancePercent, double Distance)
    {
        double risk = AccountBalance() * BalancePercent / 100;
        return CalculateLots(risk, Distance);
    }

    double LotsByEquityPercent(double Percent)
    {
        double lot             = 1;
        double marginConsumido = AccountFreeMargin() - AccountFreeMarginCheck(Symbol(), OP_BUY, lot);
        double mcPercent       = (marginConsumido / AccountFreeMargin()) * 100;
        double lotsCalc        = NormalizeDouble(Percent / mcPercent, 2);

        return CheckLimits(lotsCalc);
    }

    double CheckLimits(double lot)
    {
        double l = lot;
        if (lot < _min) l = _min;
        if (lot > _max) l = _max;
        return l;
    }

    double LotsByMoney(double Money, double Distance)
    {
        double risk = fabs(Money);
        return CalculateLots(risk, Distance);
    }

    double CalculateLots(double risk, double distance)
    {
        distance *= 10;
        if (distance == 0) {
            // Print(__FUNCTION__, " ", "Set Distance");
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
LotCalculator lotsProvider;

#endif

#define Section_StopLoss
#ifdef Section_StopLoss
// MARK: Section StopLoss

// Opciones:
// #define sl_money_on
#define sl_candles_on

enum stop_loss_mode {
    sl_null,     // Off
    sl_fix_pips, //  Fix Pips

#ifdef sl_money_on
    sl_money, // By Money
#endif
#ifdef sl_candles_on
    sl_candles, // By Candles
#endif
};

double StopLoss(const double price, const string side, const string symbol, const double lot)
{

    switch (sl_mode) {

    case sl_null:
        return 0.00;
    case sl_fix_pips:
        return StopLossByPips(price, side, symbol);

#ifdef sl_money_on
    case sl_money:
        return StopLossByMoney(price, side, symbol, lot);
#endif

#ifdef sl_candles_on
    case sl_candles:
        return StopLossByCandles(side, symbol);
#endif
    }

    return 0.00;
}

// ------------------------------------------------------------------
input string         tstop          = "== Stop Loss =="; // ————————————————————————
input stop_loss_mode sl_mode        = sl_fix_pips;       // SL Mode:
input double         uStopLossValue = 50;                // SL value:

// ------------------------------------------------------------------

double StopLossSafety(string side, string symbol, double value)
{
    double r = 0;
    if (side == "buy") {
        r = MarketInfo(symbol, MODE_BID) - MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT);
        r = MathMin(value, r);
    }
    if (side == "sell") {
        r = MarketInfo(symbol, MODE_ASK) + MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT);
        r = MathMax(value, r);
    }

    return r;
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

double StopLossByMoney(const double price, const string side, const string symbol, const double lot)
{
    double _tickValue    = MarketInfo(symbol, MODE_TICKVALUE);
    double _modeCalc     = MarketInfo(symbol, MODE_PROFITCALCMODE);
    double _contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    double _step         = MarketInfo(symbol, MODE_LOTSTEP);
    double _points       = MarketInfo(symbol, MODE_POINT);
    double _digits       = MarketInfo(symbol, MODE_DIGITS);
    double _pips         = 0;

    // FOREX
    if (_modeCalc == 0) {
        _pips = NormalizeDouble(uStopLossValue / (lot * _tickValue), 2);
    }

    // FUTUROS
    if (_modeCalc == 1 && _step != 1.0) {
        double c = _contractSize * _step;
        _pips    = NormalizeDouble((uStopLossValue / c / lot), 2);
    }

    // FUTUROS SIN DECIMALES
    if (_modeCalc == 1 && _step == 1.0) {
        double c = _contractSize * _step;
        _pips    = MathFloor((uStopLossValue / c / lot) / 100);
    }

    double distance = _pips * _points;
    double result   = 0;

    if (_pips == 0) {
        return 0;
    }
    if (side == "buy") {
        result = price - distance;
    }
    if (side == "sell") {
        result = price + distance;
    }

    return NormalizeDouble(result, (int)_digits);
}

#ifdef sl_candles_on

input int    sl_candles_shift    = 2; // Candles Shift (high/low)
input double sl_pips_from_candle = 5; // Pips From High Low

double StopLossByCandles(const string side, const string symbol, ENUM_TIMEFRAMES tf = 0)
{
    double r = 0;
    if (side == "buy") {
        r = iLow(symbol, tf, iLowest(symbol, tf, MODE_LOW, sl_candles_shift, 1));
        r -= sl_pips_from_candle * 10 * MarketInfo(symbol, MODE_POINT);
        r = StopLossSafety("buy", symbol, r);
    }
    if (side == "sell") {
        r = iHigh(symbol, tf, iHighest(symbol, tf, MODE_HIGH, sl_candles_shift, 1));
        r += sl_pips_from_candle * 10 * MarketInfo(symbol, MODE_POINT);
        r = StopLossSafety("sell", symbol, r);
    }

    return NormalizeDouble(r, (int)MarketInfo(symbol, MODE_DIGITS));
}

#endif

#endif

#define Section_TakeProfit
#ifdef Section_TakeProfit
// MARK: Section TakeProfit

// Opciones:
// #define tp_money_on
#define tp_ratio_on

enum take_profit_mode {
    tp_null,     // Off
    tp_fix_pips, //  Fix Pips

#ifdef tp_money_on
    tp_money, // By Money
#endif

#ifdef tp_ratio_on
    tp_by_ratio, // By Risk Reguard ratio
#endif
};

double TakeProfit(const double price, const string side, const string symbol, const double lot)
{

    switch (tp_mode) {
    case tp_null:
        return 0.00;
    case tp_fix_pips:
        return TakeProfitByPips(price, side, symbol);

#ifdef tp_money_on
    case tp_money:
        return TakeProfitByMoney(price, side, symbol, lot);
#endif

#ifdef tp_ratio_on
    case tp_by_ratio:
        return TakeProfitByRatio(price, side, symbol);
#endif
    }

    return 0.00;
}

double tpSafety(string side, string symbol, double value)
{
    double r = 0;
    if (side == "buy") {
        r = MarketInfo(symbol, MODE_ASK) + MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT);
        r = MathMax(value, r);
    }
    if (side == "sell") {
        r = MarketInfo(symbol, MODE_BID) - MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT);
        r = MathMin(value, r);
    }

    return r;
}

// ------------------------------------------------------------------
input string           ttakeprofit      = "== Take Profit =="; // ————————————————————————
input take_profit_mode tp_mode          = tp_by_ratio;         // TP Mode
input double           uTakeProfitValue = 2;                   // TP value

// ------------------------------------------------------------------

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

double TakeProfitByMoney(const double price, const string side, const string symbol, const double lot)
{
    double _tickValue    = MarketInfo(symbol, MODE_TICKVALUE);
    double _modeCalc     = MarketInfo(symbol, MODE_PROFITCALCMODE);
    double _contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    double _step         = MarketInfo(symbol, MODE_LOTSTEP);
    double _points       = MarketInfo(symbol, MODE_POINT);
    double _digits       = MarketInfo(symbol, MODE_DIGITS);
    double _pips         = 0;

    // FOREX
    if (_modeCalc == 0) {
        _pips = NormalizeDouble(uTakeProfitValue / (lot * _tickValue), 2);
    }

    // FUTUROS
    if (_modeCalc == 1 && _step != 1.0) {
        double c = _contractSize * _step;
        _pips    = NormalizeDouble((uTakeProfitValue / c / lot), 2);
    }

    // FUTUROS SIN DECIMALES
    if (_modeCalc == 1 && _step == 1.0) {
        double c = _contractSize * _step;
        _pips    = MathFloor((uTakeProfitValue / c / lot) / 100);
    }

    double distance = _pips * _points;
    double result   = 0;

    if (_pips == 0) {
        return 0;
    }
    if (side == "buy") {
        result = price + distance;
    }
    if (side == "sell") {
        result = price - distance;
    }

    return NormalizeDouble(result, (int)_digits);
}

double TakeProfitByRatio(const double price, const string side, const string symbol)
{
    double sl = StopLoss(price, side, symbol, 1);
    if (sl == 0) return 0;
    double gap = fabs(sl - price);
    gap *= uTakeProfitValue;

    double r = price;
    if (side == "buy") {
        r += gap;
        r = tpSafety(side, symbol, r);
    }
    if (side == "sell") {
        r -= gap;
        r = tpSafety(side, symbol, r);
    }

    return NormalizeDouble(r, (int)MarketInfo(symbol, MODE_DIGITS));
}

#endif

#ifdef Section_Close
// Mark: strategy close

input string TclosePositions      = "== Close Positions =="; // ————————————————————————
input bool   close_by_strategy_on = false;                   // Close positions:

class ConditionCloseBuy : public iConditions
{
  public:
    bool evaluate()
    {
        bool r = false;
        if (OrderType() == OP_BUY) {
            // TODO: condición close buy
        }
        return r;
    }
};
ConditionCloseBuy cdCloseBuy;

class ConditionCloseSell : public iConditions
{
  public:
    bool evaluate()
    {
        bool r = false;
        if (OrderType() == OP_SELL) {
            // TODO: condición close sell
        }
        return r;
    }
};
ConditionCloseSell cdCloseSell;

Strategy stCloseBuy;
Strategy stCloseSell;

void oninit_close_strategy()
{
    stCloseBuy.set(&cdCloseBuy, &acCloseBuy);
    stCloseSell.set(&cdCloseSell, &acCloseSell);
    if (close_by_strategy_on) {
        Trader.management.add(&stCloseBuy);
        Trader.management.add(&stCloseSell);
    }
}

#endif

#ifdef Section_breakeven
// MARK: Section breakeven

input string Tbk         = "== Breakeven Setup =="; // ————————————————————————
input bool   breakevenOn = false;                   // Breakeven On:
input double userBkvPips = 10;                      // Breakeven Pips
input double userBkvStep = 3;                       // Breakeven Step

class ConditionBreackeven : public iConditions
{
  public:
    bool evaluate()
    {
        double mPoints = MarketInfo(OrderSymbol(), MODE_POINT);
        double ask     = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
        double bid     = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
        double dist    = userBkvPips * mPoints * 10;

        if (OrderProfit() < 0) return false;

        if (OrderType() == OP_BUY) {
            return (((OrderStopLoss() < OrderOpenPrice()) || (OrderStopLoss() == 0)) && (bid >= OrderOpenPrice() + dist));
        }
        if (OrderType() == OP_SELL) {
            return (((OrderStopLoss() > OrderOpenPrice()) || (OrderStopLoss() == 0)) && (ask <= OrderOpenPrice() - dist));
        }
        return false;
    }
};
ConditionBreackeven conditionBreackeven;

class ActionBreakeven : public iActions
{
  public:
    bool execute()
    {
        int    digi    = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
        double mPoints = MarketInfo(OrderSymbol(), MODE_POINT);
        bool   r       = false;

        if (OrderType() == OP_BUY) {
            double buySl = NormalizeDouble(OrderOpenPrice() + userBkvStep * 10 * Point, digi);
            r            = OrderModify(OrderTicket(), OrderOpenPrice(), buySl, OrderTakeProfit(), OrderExpiration(), clrNONE);
        }
        if (OrderType() == OP_SELL) {
            double sellSl = NormalizeDouble(OrderOpenPrice() - userBkvStep * 10 * Point, digi);
            r             = OrderModify(OrderTicket(), OrderOpenPrice(), sellSl, OrderTakeProfit(), OrderExpiration(), clrNONE);
        }
        return r;
    }
};
ActionBreakeven actionBreakeven;

Strategy Breakeven;
void     Initiate_Breakeven()
{
    Breakeven.addCondition(&conditionBreackeven);
    Breakeven.addAction(&actionBreakeven);
    Trader.management.add(&Breakeven);
}

#endif

#ifdef Section_Traling_Stop

input string       ttsl         = "== TrailingStop Setup =="; // ————————————————————————
input const bool   tsl_on       = false;                      // TSL ON:
input const double tsl_start    = 10;                         // TSL Start:
input const double tsl_step     = 10;                         // TSL Step:
input const double tsl_distance = 20;                         // TSL Distance:

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

void     Initiate_TSL()
{
    TSL.addCondition(&conditionTSL);
    TSL.addAction(&actionTSL);
    Trader.management.add(&TSL);
}

#endif

#ifdef Section_timer

#define timer_mini
// #define timer_full

enum enumDays { sunday, monday, tuesday, wednesday, thursday, friday, saturday, EA_OFF };

#ifdef timer_full
input string   T1         = "== Trading Sessions  =="; // ————————————————————————
input double   uTimeZone  = -6;                        // Set your GMT zone:
input bool     day1_On    = true;                      // Session On:
input enumDays day1       = monday;                    // Day
input string   day1_Start = "00:00:00";                // Time Start GMT
input string   day1_End   = "23:59:59";                // Time End GMT
input bool     day2_On    = true;                      // Session On:
input enumDays day2       = tuesday;                   // Day
input string   day2_Start = "00:00:00";                // Time Start GMT
input string   day2_End   = "23:59:59";                // Time End GMT
input bool     day3_On    = true;                      // Session On:
input enumDays day3       = wednesday;                 // Day
input string   day3_Start = "00:00:00";                // Time Start GMT
input string   day3_End   = "23:59:59";                // Time End GMT
input bool     day4_On    = true;                      // Session On:
input enumDays day4       = thursday;                  // Day
input string   day4_Start = "00:00:00";                // Time Start GMT
input string   day4_End   = "23:59:59";                // Time End GMT
input bool     day5_On    = true;                      // Session On:
input enumDays day5       = friday;                    // Day
input string   day5_Start = "00:00:00";                // Time Start GMT
input string   day5_End   = "23:59:59";                // Time End GMT
#endif
#ifdef timer_mini
input string T1             = "== Trading Sessions =="; // ————————————————————————
input bool   sessioncontrol = false;                    // Timer On:
input string timeStart      = "00:00:00";               // Time Start GMT
input string timeEnd        = "23:59:59";               // Time End GMT
#endif
class Session
{
    int _iniTime; // second from 00:00 hr of the day
    int _endTime;
    int _dayNumber;

  public:
    // receive time in format 00:00
    Session(string iniTime, string endTime, int dayNumber = 0)
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

        return (hh * 3600) + (mm * 60);
    }
};
class ScheduleController : public iConditions
{
    Session *schedules[];
    Session *_actualSession;
    int      _actualIndex;
    int      _currentDay;
    double   _timeZone; // modificador para ajustar GMT

  public:
    ScheduleController() { setCurrentDay(); };
    ~ScheduleController() { ClearShchedules(); }

    Session *at() { return _actualSession; }

    void setTimeZone(double hs) { _timeZone = hs * 60 * 60; }

    void setCurrentDay()
    {
        _currentDay = TimeDay(TimeGMT() + (int)_timeZone); // return the day of the month 1-31
    }

    bool isNewDay()
    {
        if (TimeDay(TimeGMT() + (int)_timeZone) != _currentDay) {
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

    int qnt() { return ArraySize(schedules); }

    bool AddSession(string ini, string end, int day = 0)
    {
        Session *sc = new Session(ini, end, day);
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

    bool evaluate() // control day and hours for every session
    {
        if (!sessioncontrol) {
            Comment("Timer Control - EA ON");
            return true;
        }

        Comment("Timer Control - EA OFF");

        int actual = (TimeHour(TimeGMT() + (int)_timeZone) * 3600) + (TimeMinute(TimeGMT() + (int)_timeZone) * 60);

        for (int i = 0; i < qnt(); i++) {
            if (schedules[i].dayNumber() == EA_OFF) {
                continue;
            }

            if (schedules[i].dayNumber() != 0) {
                if (schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT() + (int)_timeZone)) {
                    if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime()) {
                        setActualSession(i);
                        Comment("Daily Control - EA ON");
                        return true;
                    }
                }
            }

            if (schedules[i].dayNumber() == 0) {
                if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime()) {
                    setActualSession(i);
                    Comment("Daily Control - EA ON");
                    return true;
                }
            }
        }

        setActualSession(-1);
        return false;
    }
};
ScheduleController sesionControl;

void oninitTimer()
{
    if(!sessioncontrol) return;
    
#ifdef timer_full
    sesionControl.setTimeZone(uTimeZone);
    if (day1_On) sesionControl.AddSession(day1_Start, day1_End, day1);
    if (day2_On) sesionControl.AddSession(day2_Start, day2_End, day2);
    if (day3_On) sesionControl.AddSession(day3_Start, day3_End, day3);
    if (day4_On) sesionControl.AddSession(day4_Start, day4_End, day4);
    if (day5_On) sesionControl.AddSession(day5_Start, day5_End, day5);
#endif

#ifdef timer_mini
    sesionControl.AddSession(timeStart, timeEnd);
#endif

    // StopExpert.addCondition(&sesionControl);
    Trader.filters.add(&sesionControl);
}

#endif

#ifdef Section_News

input string    TNEWS                 = "== News Setup ==";              // ————————————————————————
input string    note                  = "http://calendar.fxstreet.com/"; // You Must to allow this URL:
input bool      NEWS_FILTER           = false;                           // News Filter On
input bool      NEWS_IMPOTANCE_LOW    = false;                           // Low
input bool      NEWS_IMPOTANCE_MEDIUM = true;                            // Medium
input bool      NEWS_IMPOTANCE_HIGH   = true;                            // High
input int       STOP_BEFORE_NEWS      = 30;                              // Minutes Stop Before News
input int       START_AFTER_NEWS      = 30;                              // Minutes Stop After News
input string    Currencies_Check      = "USD,EUR,CAD,AUD,NZD,GBP";       // Currencys
bool            Check_Specific_News   = false;
string          Specific_News_Text    = "employment";
input bool      DRAW_NEWS_CHART       = true;      // Show Up comming News
int             X                     = 10;        // Chart X-Axis Position
int             Y                     = 280;       // Chart Y-Axis Position
string          News_Font             = "Calibri"; // Font
color           Font_Color            = clrBlack;  // Font Color
input bool      DRAW_NEWS_LINES       = false;     // Draw Lines News
color           Line_Color            = clrBlack;  // Line Color
ENUM_LINE_STYLE Line_Style            = STYLE_DOT;
int             Line_Width            = 1;
int             Font_Size             = 8;
string          LANG                  = "en-US";
datetime        date;
int             TIME_CORRECTION, NEWS_ON = 0;

class News : public iConditions
{

  public:
    News() { ; }
    ~News() { ; }

    bool evaluate()
    {
        if (!NEWS_FILTER) return true; // off
        ReadNews();
        if (NEWS_ON == 1) {
            return false;
        } // news comming soon

        return true;
    }

    struct sNews {
        datetime dTime;
        string   time;
        string   currency;
        string   importance;
        string   news;
        string   Actual;
        string   forecast;
        string   previus;
    };
    sNews NEWS_TABLE[], HEADS;

    int OnInit()
    {
        if (!MQLInfoInteger(MQL_TESTER) || !MQLInfoInteger(MQL_OPTIMIZATION)) {
            if (NEWS_FILTER == true && READ_NEWS(NEWS_TABLE) && ArraySize(NEWS_TABLE) > 0) DRAW_NEWS(NEWS_TABLE);

            TIME_CORRECTION = (-TimeGMTOffset());
        }
        EventSetTimer(1);

        return (INIT_SUCCEEDED);
    }

    void OnDeinit(const int reason)
    {
        DEINIT_PANEL();
        EventKillTimer();
    }

    void ReadNews()
    {
        if (NEWS_FILTER == false) return;

        static int waiting = 0;
        if (waiting <= 0) {
            if (!MQLInfoInteger(MQL_TESTER) || !MQLInfoInteger(MQL_OPTIMIZATION)) {
                if (READ_NEWS(NEWS_TABLE)) waiting = 100;
                if (ArraySize(NEWS_TABLE) <= 0) return;
                DRAW_NEWS(NEWS_TABLE);
            }
        } else
            waiting--;
        if (ArraySize(NEWS_TABLE) <= 0) return;

        datetime time = TimeCurrent();
        //---
        for (int i = 0; i < ArraySize(NEWS_TABLE); i++) {
            datetime news_time        = NEWS_TABLE[i].dTime + TIME_CORRECTION;
            bool     Importance_Check = false;
            if ((!NEWS_IMPOTANCE_LOW && NEWS_TABLE[i].importance == "*") || (!NEWS_IMPOTANCE_MEDIUM && NEWS_TABLE[i].importance == "* *") ||
                (!NEWS_IMPOTANCE_HIGH && NEWS_TABLE[i].importance == "* * *"))
                Importance_Check = true;
            if (Importance_Check || StringFind(Currencies_Check, NEWS_TABLE[i].currency, 0) == -1 || (Check_Specific_News && (StringFind(NEWS_TABLE[i].news, Specific_News_Text) == -1))) continue;
            if ((news_time <= time && (news_time + (datetime)(START_AFTER_NEWS * 60)) >= time) || (news_time >= time && (news_time - (datetime)(STOP_BEFORE_NEWS * 60)) <= time)) {
                NEWS_ON = 1;
                Comment("News Time...");
                break;
            } else {
                NEWS_ON = 0;
                Comment("No News");
            }
        }
        return;
    }

    void DEL_ROW(sNews &l_a_news[], int row)
    {
        int size = ArraySize(l_a_news) - 1;
        for (int i = row; i < size; i++) {
            l_a_news[i].Actual     = l_a_news[i + 1].Actual;
            l_a_news[i].currency   = l_a_news[i + 1].currency;
            l_a_news[i].dTime      = l_a_news[i + 1].dTime;
            l_a_news[i].forecast   = l_a_news[i + 1].forecast;
            l_a_news[i].importance = l_a_news[i + 1].importance;
            l_a_news[i].news       = l_a_news[i + 1].news;
            l_a_news[i].previus    = l_a_news[i + 1].previus;
            l_a_news[i].time       = l_a_news[i + 1].time;
        }
        ArrayResize(l_a_news, size);
    }

    bool READ_NEWS(sNews &l_NewsTable[])
    {
        string cookie = NULL, referer = NULL, headers;
        char   post[], result[];
        string tmpStr  = "";
        string st_date = TimeToString(TimeCurrent(), TIME_DATE), end_date = TimeToString((TimeCurrent() + (datetime)(7 * 24 * 60 * 60)), TIME_DATE);
        StringReplace(st_date, ".", "");
        StringReplace(end_date, ".", "");
        string url = "http://calendar.fxstreet.com/EventDateWidget/GetMini?culture=" + LANG + "&view=range&start=" + st_date + "&end=" + end_date + "&timezone=UTC" +
                     "&columns=date%2Ctime%2Ccountry%2Ccountrycurrency%2Cevent%2Cconsensus%2Cprevious%2Cvolatility%2Cactual&showcountryname=false&showcurrencyname=true&isfree=true&_=1455009216444";
        ResetLastError();
        WebRequest("GET", url, cookie, referer, 10000, post, sizeof(post), result, headers);
        if (ArraySize(result) <= 0) {
            int er = GetLastError();
            ResetLastError();
            // Print("ERROR_TXT IN WebRequest");
            if (er == 4060) MessageBox("YOU MUST ADD THE ADDRESS '" + "http://calendar.fxstreet.com/" + "' IN THE LIST OF ALLOWED URL IN THE TAB 'ADVISERS'", "ERROR_TXT", MB_ICONINFORMATION);
            return false;
        }

        tmpStr    = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
        int handl = FileOpen("News.txt", FILE_WRITE | FILE_TXT);
        FileWrite(handl, tmpStr);
        FileFlush(handl);
        FileClose(handl);
        StringReplace(tmpStr, "&#39;", "'");
        StringReplace(tmpStr, "&#163;", "");
        StringReplace(tmpStr, "&#165;", "");
        StringReplace(tmpStr, "&amp;", "&");

        int st           = StringFind(tmpStr, "fxst-thevent", 0);
        st               = StringFind(tmpStr, ">", st) + 1;
        int end          = StringFind(tmpStr, "</th>", st);
        HEADS.news       = (st < end ? StringSubstr(tmpStr, st, end - st) : "");
        st               = StringFind(tmpStr, "fxst-thvolatility", 0);
        st               = StringFind(tmpStr, ">", st) + 1;
        end              = StringFind(tmpStr, "</th>", st);
        HEADS.importance = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
        st               = StringFind(tmpStr, "fxst-thactual", 0);
        st               = StringFind(tmpStr, ">", st) + 1;
        end              = StringFind(tmpStr, "</th>", st);
        HEADS.Actual     = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
        st               = StringFind(tmpStr, "fxst-thconsensus", 0);
        st               = StringFind(tmpStr, ">", st) + 1;
        end              = StringFind(tmpStr, "</th>", st);
        HEADS.forecast   = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
        st               = StringFind(tmpStr, "fxst-thprevious", 0);
        st               = StringFind(tmpStr, ">", st) + 1;
        end              = StringFind(tmpStr, "</th>", st);
        HEADS.previus    = (st < end ? StringSubstr(tmpStr, st, end - st) : "");
        HEADS.currency   = "";
        HEADS.dTime      = 0;
        HEADS.time       = "";
        int startLoad    = StringFind(tmpStr, "<tbody>", 0) + 7;
        int endLoad      = StringFind(tmpStr, "</tbody>", startLoad);
        if (startLoad >= 0 && endLoad > startLoad) {
            tmpStr = StringSubstr(tmpStr, startLoad, endLoad - startLoad);
            while (StringReplace(tmpStr, "  ", " "))
                ;
        } else
            return false;
        int begin = -1;
        do {
            begin = StringFind(tmpStr, "<span", 0);
            if (begin >= 0) {
                end    = StringFind(tmpStr, "</span>", begin) + 7;
                tmpStr = StringSubstr(tmpStr, 0, begin) + StringSubstr(tmpStr, end);
            }
        } while (begin >= 0);
        StringReplace(tmpStr, "<strong>", NULL);
        StringReplace(tmpStr, "</strong>", NULL);
        int    BackShift = 0;
        string arNews[];
        for (uchar tr = 1; tr < 255; tr++) {
            if (StringFind(tmpStr, CharToString(tr), 0) > 0) continue;
            int K = StringReplace(tmpStr, "</tr>", CharToString(tr));
            // ArrayResize(arNews,StringReplace(tmpStr,"</tr>",CharToString(tr)));
            K = StringSplit(tmpStr, tr, arNews);
            ArrayResize(l_NewsTable, K);
            for (int td = 0; td < ArraySize(arNews); td++) {
                st = StringFind(arNews[td], "fxst-td-date", 0);
                if (st > 0) {
                    st            = StringFind(arNews[td], ">", st) + 1;
                    end           = StringFind(arNews[td], "</td>", st) - 1;
                    int         d = (int)StringToInteger(StringSubstr(arNews[td], end - 4, end - st));
                    MqlDateTime time;
                    TimeCurrent(time);
                    if (d < (time.day - 5)) {
                        if (time.mon == 12) {
                            time.mon = 1;
                            time.year++;
                        } else {
                            time.mon++;
                        }
                    }
                    time.day  = d;
                    time.min  = 0;
                    time.hour = 0;
                    time.sec  = 0;
                    date      = StructToTime(time);
                    BackShift++;
                    continue;
                }
                st = StringFind(arNews[td], "fxst-evenRow", 0);
                if (st < 0) {
                    BackShift++;
                    continue;
                }
                int st1                          = StringFind(arNews[td], "fxst-td-time", st);
                st1                              = StringFind(arNews[td], ">", st1) + 1;
                end                              = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].time = StringSubstr(arNews[td], st1, end - st1);
                if (StringFind(l_NewsTable[td - BackShift].time, ":") > 0) {
                    l_NewsTable[td - BackShift].dTime = StringToTime(TimeToString(date, TIME_DATE) + " " + StringSubstr(arNews[td], st1, end - st1));
                } else {
                    l_NewsTable[td - BackShift].dTime = date;
                }
                st1                                  = StringFind(arNews[td], "fxst-td-currency", st);
                st1                                  = StringFind(arNews[td], ">", st1) + 1;
                end                                  = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].currency = (st1 < end ? StringSubstr(arNews[td], st1, end - st1) : "");
                st1                                  = StringFind(arNews[td], "fxst-i-vol", st);
                st1                                  = StringFind(arNews[td], ">", st1) + 1;
                end                                  = StringFind(arNews[td], "</td>", st1);
                StringInit(l_NewsTable[td - BackShift].importance, (int)StringToInteger(StringSubstr(arNews[td], st1, end - st1)), '*');
                st1                                  = StringFind(arNews[td], "fxst-td-event", st);
                int st2                              = StringFind(arNews[td], "fxst-eventurl", st1);
                st1                                  = StringFind(arNews[td], ">", fmax(st1, st2)) + 1;
                end                                  = StringFind(arNews[td], "</td>", st1);
                int end1                             = StringFind(arNews[td], "</a>", st1);
                l_NewsTable[td - BackShift].news     = StringSubstr(arNews[td], st1, (end1 > 0 ? fmin(end, end1) : end) - st1);
                st1                                  = StringFind(arNews[td], "fxst-td-act", st);
                st1                                  = StringFind(arNews[td], ">", st1) + 1;
                end                                  = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].Actual   = (end > st1 ? StringSubstr(arNews[td], st1, end - st1) : "");
                st1                                  = StringFind(arNews[td], "fxst-td-cons", st);
                st1                                  = StringFind(arNews[td], ">", st1) + 1;
                end                                  = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].forecast = (end > st1 ? StringSubstr(arNews[td], st1, end - st1) : "");
                st1                                  = StringFind(arNews[td], "fxst-td-prev", st);
                st1                                  = StringFind(arNews[td], ">", st1) + 1;
                end                                  = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].previus  = (end > st1 ? StringSubstr(arNews[td], st1, end - st1) : "");
            }
            break;
        }
        ArrayResize(l_NewsTable, (ArraySize(l_NewsTable) - BackShift));
        return (true);
    }

    void DRAW_NEWS(sNews &l_a_news[])
    {
        if (DRAW_NEWS_LINES || DRAW_NEWS_CHART) {
            if (NEWS_FILTER == false) return;
            for (int i = ArraySize(l_a_news) - 1; i >= 0; i--) {
                StringReplace(l_a_news[i].currency, " ", "");
                int Currency_check_counter = 0;

                datetime t1 = (l_a_news[i].dTime + (datetime)(START_AFTER_NEWS * 60));
                datetime t2 = ((TimeCurrent() - (datetime)TIME_CORRECTION));

                if (StringFind(Currencies_Check, l_a_news[i].currency) == -1 || t1 < t2 || (Check_Specific_News && (StringFind(l_a_news[i].news, Specific_News_Text) == -1))) {
                    DEL_ROW(l_a_news, i);
                    continue;
                }

                if ((!NEWS_IMPOTANCE_LOW && l_a_news[i].importance == "*") || (!NEWS_IMPOTANCE_MEDIUM && l_a_news[i].importance == "* *") ||
                    (!NEWS_IMPOTANCE_HIGH && l_a_news[i].importance == "* * *")) {
                    DEL_ROW(l_a_news, i);
                    continue;
                }
                string NAME = (" " + l_a_news[i].currency + " " + l_a_news[i].importance + " " + l_a_news[i].news);
                if (DRAW_NEWS_LINES) {
                    if (ObjectFind(0, NAME) < 0) {
                        ObjectCreate(0, NAME, OBJ_VLINE, 0, l_a_news[i].dTime + TIME_CORRECTION, 0);
                        ObjectSetInteger(0, NAME, OBJPROP_SELECTABLE, false);
                        ObjectSetInteger(0, NAME, OBJPROP_SELECTED, false);
                        ObjectSetInteger(0, NAME, OBJPROP_HIDDEN, true);
                        ObjectSetInteger(0, NAME, OBJPROP_BACK, false);
                        ObjectSetInteger(0, NAME, OBJPROP_COLOR, Line_Color);
                        ObjectSetInteger(0, NAME, OBJPROP_STYLE, Line_Style);
                        ObjectSetInteger(0, NAME, OBJPROP_WIDTH, Line_Width);
                    }
                }
            }
            string NAME;
            int    K = 0, Z = 0;
            if (DRAW_NEWS_CHART) {
                for (int l = 1; l <= 9 && Z < ArraySize(l_a_news); l++) {
                    for (K = Z; K < ArraySize(l_a_news); K++)
                        if (l_a_news[K].currency != "") break;
                    Z = K + 1;

                    NAME = "PANEL_NEWS_N" + (string)l;
                    if (ObjectFind(0, NAME) < 0)
                        OBJECT_LABEL(
                            0, NAME, 0, X + 110, Y - (int)(18 * (l + 5)), CORNER_LEFT_LOWER,
                            ((TimeToString(l_a_news[K].dTime + TIME_CORRECTION, TIME_DATE | TIME_MINUTES) + " " + l_a_news[K].currency + " " + l_a_news[K].importance + " " + l_a_news[K].news)),
                            News_Font, Font_Size, Font_Color, 0, ANCHOR_LEFT_UPPER, false, false, true, 0);
                }
            }
            return;
        }
    }

    void DEINIT_PANEL() { ObjectsDeleteAll(0); }

    bool OBJECT_LABEL(const long CHART_ID = 0, const string NAME = "", const int SUB_WINDOW = 0, const int X_Axis = 0, const int Y_Axis = 0, const ENUM_BASE_CORNER CORNER = CORNER_LEFT_UPPER,
                      const string TEXT = "", const string FONT = "", const int FONT_SIZE = 10, const color CLR = color("255,0,0"), const double ANGLE = 0.0,
                      const ENUM_ANCHOR_POINT ANCHOR = ANCHOR_LEFT_UPPER, const bool BACK = false, const bool SELECTION = false, const bool HIDDEN = true, const long ZORDER = 0, string TOOLTIP = "\n")
    {
        ResetLastError();
        if (ObjectFind(0, NAME) < 0) {
            ObjectCreate(CHART_ID, NAME, OBJ_LABEL, SUB_WINDOW, 0, 0);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_XDISTANCE, X_Axis);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_YDISTANCE, Y_Axis);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_CORNER, CORNER);
            ObjectSetString(CHART_ID, NAME, OBJPROP_TEXT, TEXT);
            ObjectSetString(CHART_ID, NAME, OBJPROP_FONT, FONT);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_FONTSIZE, FONT_SIZE);
            ObjectSetDouble(CHART_ID, NAME, OBJPROP_ANGLE, ANGLE);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_ANCHOR, ANCHOR);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR, CLR);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_BACK, BACK);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_SELECTABLE, SELECTION);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_SELECTED, SELECTION);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_HIDDEN, HIDDEN);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_ZORDER, ZORDER);
            ObjectSetString(CHART_ID, NAME, OBJPROP_TOOLTIP, TOOLTIP);
        } else {
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR, CLR);
            ObjectSetString(CHART_ID, NAME, OBJPROP_TEXT, TEXT);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_XDISTANCE, X);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_YDISTANCE, Y);
        }
        return (true);
        ChartRedraw();
    }
};
News news;

void oninitNews()
{
    news.OnInit();
    Trader.filters.add(&news);
}

#endif

#define Section_Create_Orders
#ifdef Section_Create_Orders
// MARK: Section Create Orders

class OrderCreator : public iActions
{
    string          _symbol;
    string          _side;
    double          _price;
    double          _lots;
    double          _sl;
    double          _tp;
    ENUM_ORDER_TYPE _cmd;
    int             _magic;

  public:
    OrderCreator(const string Symbol, const string Side, const int Magic)
    {
        _symbol = Symbol;
        _side   = Side;
        _magic  = Magic;
    }
    ~OrderCreator() { ; }

    void setPrice() { _price = ::Price(_side); }

    void setLots() { _lots = ::LotsCalculation(); }

    void setStopLoss() { _sl = ::StopLoss(_price, _side, _symbol, _lots); }

    void setTakeProfit() { _tp = ::TakeProfit(_price, _side, _symbol, _lots); }

    bool setType()
    {
        // clang-format off
        double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);

        if (modeEntry == Market) {
            if (_side == "buy")  { _cmd = OP_BUY; return true;  }
            if (_side == "sell") { _cmd = OP_SELL; return true; }
        }
        if (_side == "buy") {
            if (_price > ask)    { _cmd = OP_BUYSTOP; return true;  }
            if (_price < ask)    { _cmd = OP_BUYLIMIT; return true; }
        }
        if (_side == "sell") {
            if (_price > bid)    { _cmd = OP_SELLLIMIT; return true; }
            if (_price < bid)    { _cmd = OP_SELLSTOP; return true;  }
        }
    return false;
        // clang-format on
    }

    bool execute()
    {
        setPrice();
        setLots();
        setStopLoss();
        setTakeProfit();
        setType();
        int _slippage = 10000;

        int result = OrderSend(_symbol, _cmd, _lots, _price, _slippage, _sl, _tp, "", _magic, 0, clrNONE);

        return result > 0;
    }
};

OrderCreator buy(_Symbol, "buy", magico);
OrderCreator sell(_Symbol, "sell", magico);

#endif

#ifdef Section_Basic_Strategy
// MARK: Section Basic Strategy

class BUYcondition1 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition Buy 1
        return true;
    }
};
BUYcondition1 conditionBuy;

class SELLcondition1 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition sell 1
        return true;
    }
};
SELLcondition1 conditionSell;

class ConditionCloseBuy : public iConditions
{
  public:
    bool evaluate() { return false; }
};
ConditionCloseBuy conditionCloseBuy;

class ConditionCloseSell : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition closesell
        return false;
    }
};
ConditionCloseSell conditionCloseSell;

Strategy LongStrategy;
Strategy ShortStrategy;
Strategy StrategyToCloseBuy;
Strategy StrategyToCloseSell;

void BasicStrategy_Iniciate()
{
    LongStrategy.set(&conditionBuy, &buy);
    ShortStrategy.set(&conditionSell, &sell);
    StrategyToCloseBuy.set(&conditionCloseBuy, &acCloseBuy);
    StrategyToCloseSell.set(&conditionCloseSell, &acCloseSell);

    Trader.strategys.add(&LongStrategy);
    Trader.strategys.add(&ShortStrategy);
    Trader.management.add(&StrategyToCloseBuy);
    Trader.management.add(&StrategyToCloseSell);
}

#endif

#ifdef Section_Custom_Indicator
// MARK: Custom Indicator

// ------------------------------------------------------------------
#property description "--- IMPORTANT ---"
#property description "This EA request to have installed the indicator file"
#property description "in the folder: MQL4/Indicators"
// ------------------------------------------------------------------

input string       Tcustom        = "==== Indicator Setup ===="; // ————————————————————————
input const string indicator_file = "KijunSen";                          // Indicator File:
//---
int  bufferToBuy              = 2;
int  bufferToSell             = 3;
bool indicator_init           = true;
int  candles_back_for_signals = 1;
//---
double Indi(int buffer, int candle = 1) { return iCustom(NULL, 0, indicator_file, buffer, candle); }

class ConditionIndicatorBuy : public iConditions
{
    double lastSignal;

  public:
    bool evaluate()
    {
        for (int i = 1; i <= candles_back_for_signals; i++) {
            double indi = Indi(bufferToBuy, i);
            if (indi > 0 && indi != EMPTY_VALUE && indi != lastSignal) {
                lastSignal = indi;
                return true;
            }
        }
        return false;
    }
};
ConditionIndicatorBuy conditionIndicatorBuy;

class ConditionIndicatorSell : public iConditions
{
    double lastSignal;

  public:
    bool evaluate()
    {
        for (int i = 1; i <= candles_back_for_signals; i++) {
            double indi = Indi(bufferToSell, i);
            if (indi > 0 && indi != EMPTY_VALUE && indi != lastSignal) {
                lastSignal = indi;
                return true;
            }
        }
        return false;
    }
};
ConditionIndicatorSell conditionIndicatorSell;

bool OnInit_CustomIndicator()
{
    double temp = iCustom(NULL, 0, indicator_file, 0, 0);
    if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD) {
        MessageBox("THIS EA NEED AN INDICATOR\n install the file:\n" + indicator_file + "\ninto the folder:\nMQL4/Indicators.", "Important Information", MB_ICONINFORMATION);
        Alert("THIS EA NEED AN INDICATOR, install the file: " + indicator_file + " into the folder: MQL4/Indicators.");
        indicator_init = false;
    }

    if (!indicator_init) return false;

    ShortStrategy.addCondition(&conditionIndicatorSell);
    LongStrategy.addCondition(&conditionIndicatorBuy);

    return true;
}

#endif

#define Section_Close_Opposite
#ifdef Section_Close_Opposite
input string Tcloseopposite       = "==== Close On Opposite ===="; // ————————————————————————
input bool   close_on_opposite_on = false;                         // Close On Opposite Signal:

ConditionIndicatorBuy  cdCloseOnOppositeSell;
ConditionIndicatorSell cdCloseOnOppositeBuy;

Strategy stCloseOppositeBuy;
Strategy stCloseOppositeSell;

void oninit_close_on_opposite()
{
    stCloseOppositeBuy.set(&cdCloseOnOppositeBuy, &acCloseBuy);
    stCloseOppositeSell.set(&cdCloseOnOppositeSell, &acCloseSell);

    if (close_on_opposite_on) {
        Trader.management.add(&stCloseOppositeBuy);
        Trader.management.add(&stCloseOppositeSell);
    }
}

#endif

#ifdef Section_Trades_Counters

input string tcountfilter        = "== Count Trades Filter =="; // ————————————————————————
input int    count_max_positions = 1;                           // # Total positions:
input int    count_max_buys      = 1;                           // # Buys limit:
input int    count_max_sells     = 1;                           // # Sells limit:

class ConditionCountBuys : public iConditions
{
  public:
    bool evaluate()
    {
        int count = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico && OrderType() == OP_BUY) {
                count += 1;
            }
        }
        return count < count_max_buys;
    }
};
ConditionCountBuys cCountBuys;

class ConditionCountSells : public iConditions
{
  public:
    bool evaluate()
    {
        int count = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico && OrderType() == OP_SELL) {
                count += 1;
            }
        }
        return count < count_max_sells;
    }
};
ConditionCountSells cCountSells;

class ConditionCountPositions : public iConditions
{
  public:
    bool evaluate()
    {
        int count = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
                count += 1;
            }
        }
        return count < count_max_positions;
    }
};
ConditionCountPositions cCountPositions;

void oninit_counters_filters()
{
    Trader.filters.add(&cCountPositions);
    ShortStrategy.addCondition(&cCountPositions);
    LongStrategy.addCondition(&cCountPositions);
    
    ShortStrategy.addCondition(&cCountSells);
    LongStrategy.addCondition(&cCountBuys);
}

#endif

#define Metatrader_Functions
#ifdef Metatrader_Functions

// MARK: funcion OnInit
int OnInit()
{

    Trader.management.set(_Symbol, magico);

#ifdef Section_Basic_Conditions
    oninit_basic_conditions();
#endif

#ifdef Section_Basic_Strategy
    BasicStrategy_Iniciate();
#endif

#ifdef Section_Custom_Indicator
    if (!OnInit_CustomIndicator()) {
        return INIT_FAILED;
    }
#endif

#ifdef Section_News
    oninitNews();
#endif

#ifdef Section_timer
    oninitTimer();
#endif

#ifdef Section_breakeven
    if (breakevenOn) {
        Initiate_Breakeven();
    }
#endif

#ifdef Section_Traling_Stop
    if (tsl_on) Initiate_TSL();
#endif

#ifdef Section_Close
    oninit_close_strategy();
#endif

#ifdef Section_Close_Opposite
    oninit_close_on_opposite();
#endif

#ifdef Section_Trades_Counters
    oninit_counters_filters();
#endif

    return (INIT_SUCCEEDED);
}

// MARK: funcion OnDeinit
void OnDeinit(const int reason) {}

// MARK: funcion OnTimer
void OnTimer(void) {}

// MARK: funcion OnChartEvent
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {}

// MARK: funcion OnTick
void OnTick() { Trader.doTrading(); }

#endif


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                                       https://mario-jemic.com/ | 
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency |  Network             |  Address                                              |
//+------------------------------------------------+-----------------------------------------------+
//|  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
//|  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
//|  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
//|  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//|  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//|  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//+------------------------------------------------+-----------------------------------------------+ 