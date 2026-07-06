// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73475

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
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

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

string custom_indi_Volume = "Normalized Volume.ex4";
string custom_indi_Trend  = "TOPTREND.ex4";
string custom_indi_Vortex = "vortex-indicator.ex4";

// NOTE: defines
// ——————————————————————————————————————————————————————————————————
// #define NEWS_FILTER
// #define DAILY_LIMITS
// #define PENDING_ENTRYS
#define SPREAD_FILTER
#define CONTROL_CUSTOM_INDICATOR_FILE
// #define LICENSE_CONTROL_ON
// #define TIMER_FULL  // full setup sessions
#define TIMER_MINI // one session at day
// #define TIMER_OFF   // don't show timer
// #define GRID_ON
#define NOTIFICATIONS_ON
#define CLOSE_ALL_ON
// #define PARTIAL_CLOSE_ON
#define BREAKEVEN_ON
#define TRAILING_STOP_ON
#define MAX_TRADES_AT_SAME_TIME

// ——————————————————————————————————————————————————————————————————
enum ModeLevels {
    TP_ByRatioRR,      // by Risk Reward Ratio
    FixPips,           // Fix Pips
    byMoney,           // Money
    PipsFromOpenCandle // Pips from Candle
};
enum ModeLevelsSL {
    byATR,      // by ATR
    sl_FixPips, // Fix Pips
};
enum TSLMode {
    byPips, // By Pips
    byMA    // By Moving Average
};
enum ModeCalcLots {
    FixLots,        // Fix Lots
    Money,          // by Money
    AccountPercent, // by Account Percent
};
enum CloseAllMode {
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
                EA_OFF };
enum ModeEntry { Market,
                 PendingStop,
                 PendingLimit };

// ------------------------------------------------------------------
enum cMode {
    pips   = 0, // Pips
    points = 1  // Points
};

// ——————————————————————————————————————————————————————————————————
#ifdef PENDING_ENTRYS
input string    Tpom              = "== Pending or Market Setup =="; // ————————————
input ModeEntry modeEntry         = Market;                          // Mode Entry:
input double    uEntryDistance    = 10;                              // Pips distance for pending orders:
input bool      uDeletePendingsOn = true;                            // Delete pendings when close all:
#else
ModeEntry modeEntry         = Market; // Mode Entry:
double    uEntryDistance    = 0;      // Pips distance for pending orders:
bool      uDeletePendingsOn = false;  // Delete pendings when close all:
#endif

input string TVolumenIndi     = "== Volume Inicator Setup =="; // ————————————
input bool   indi_vol_on      = true;                          // On:
input int    indi_vol_periods = 14;                            // Periods:
input string TtrendIndi       = "== Top Trend Setup ==";       // ————————————
input bool   indi_trend_on    = true;                          // On:
input int    Length           = 20;                            // Length
input int    Desviation       = 2;                             // Desviation
input double MoneyRisk        = 1;                             // MoneyRisk
input string TVortex          = "== Vortex Setup ==";          // ————————————
input bool   vortex_on        = true;                          // On:
input int    vi_length        = 14;                            // VI Length

input string T0 = "== Trade Setup =="; // ————————————
#ifdef MAX_TRADES_AT_SAME_TIME
int uMaxTrades = 1; // Max Trades At Same Time:
#endif
bool         uTradeReverse  = false;             // Trade Reverse Signal:
input int    magico         = 2022;              // Magic Number:
input int    slp            = 30;                // Slippage in points
input cMode  calcMode       = 0;                 // Pip/Point mode (for SL, TP, etc.)
string       Tvolumen       = "= Volumen =";     // ————————————
ModeCalcLots modeCalcLots   = FixLots;           // Mode to Calc Lots:
double       userLots       = 0.01;              // Setup Lots by "Fix Lots":
double       userMoney      = 10;                // Setup Lots by "Money":
double       userBalancePer = 0.1;               // Setup Lots by "Account Percent":
string       T01            = "= Take Profit ="; // ————————————
bool         takeProfitOn   = false;             // Take Profit On:
ModeLevels   modeTP         = TP_ByRatioRR;      // Mode Take Profit:
double       uRatioTP       = 2;                 // Risk Reward Ratio
int          userTPpips     = 20;                // Pips TP
double       userTPmoney    = 15;                // Money TP
string       T02            = "= Stop Loss =";   // ————————————
bool         stopLossOn     = false;             // Stop Loss On:
ModeLevelsSL modeSL         = byATR;             // Mode Stop Loss:
double       atr_m          = 3;                 // ATR multiplier
int          userSLpips     = 20;                // Pips SL
double       userSLmoney    = 15;                // Money SL

//
enum lMode {
    lotMoney          = 0, // Money (depends on exact SL value)
    lotAccountPercent = 1, // Percent of equity (depends on exact SL value)
    lotAccountBalance = 2, // Percent of balance (depends on exact SL value)
    lotFixLots        = 3, // Fixed lots
    lotMoneyMargin    = 4, // Money / margin requirement
    lotPercentMargin  = 5  // Percent / margin requirement
};
enum slMode {
    slOff            = 0, // Don't use (depends on fixed or margin determined lots)
    slMoney          = 1, // Money (depends on fixed or margin determined lots)
    slAccountPercent = 2, // Percent of equity (depends on fixed or margin determined lots)
    slFix            = 3, // Pip/point (as set in "Pip/Point Mode" setting)
    slAbsolute       = 4, // Absolute Value (for buy = value, for sell = value 2)
    slATR            = 5, // ATR (period = value, multiplicator = value 2)
    slBars           = 6, // Highest/lowest of (value) bars, +/- (value 2) offset pip/point
    slPricePercent   = 7  // Percent of price
};
enum tpMode {
    tpOff            = 0,  // Don't use (depends on fixed or margin determined lots)
    tpMoney          = 1,  // Money (depends on fixed or margin determined lots)
    tpAccountPercent = 2,  // Percent of equity (depends on fixed or margin determined lots)
    tpFix            = 3,  // Pip/point (as set in "Pip/Point Mode")
    tpPricePercent   = 7,  // Percent of price
    tpAbsolute       = 4,  // Absolute Value (for buy = value, for sell = value 2)
    tpATR            = 5,  // ATR (period = value, multiplicator = value 2)
    tpBars           = 6,  // Highest /lowest of (value) bars, +/- (value 2) offset pip/point
    tpSlRatio        = 100 // Stop loss distance ratio (R:R)
};

input string ps      = "==========  Position Size Settings  =========="; // ==========  Position Size Settings  ==========
input lMode  lotMode = 2;                                                // Lot calculation mode
input double Lot     = 1.0;                                              // Lot value (as set in "Lot calculation mode")
input double maxLot  = 1.00;                                             // Maximum size of lots (All positions)
//
input string sltp      = "==========  SL / TP Settings  =========="; // ==========  SL / TP Settings  ==========
input slMode SlMode    = 5;                                          // SL by
input double SlVal     = 30;                                         // SL value
input double SlVal2    = 2;                                          // SL value 2 (if required in the "SL by" setting
input double SlMin     = 10;                                         // Min SL distance pip/point (as set in "Pip/Point mode")
input tpMode TpMode    = 100;                                        // TP by
input double TpVal     = 2;                                          // TP value
input double TpVal2    = 1;                                          // TP value 2 (if required in the "TP by" setting)
input double TpMin     = 10;                                         // Min TP distance pip/point (as set in "Pip/Point mode")
input bool   addSpread = true;                                       // Add current spread to SL/TP calculation
//

#ifdef SPREAD_FILTER
input string Tspread        = "== Spread Filter =="; // ————————————
input bool   SpreadFilterOn = false;                 // Spread Filter On:
input double uSpreadMax     = 100;                   // Max Spread points:
#endif

#ifdef DAILY_LIMITS
enum DayLimitsMode {
    LimitsByAmount,        // by Amount
    LimitsByAccountPercent // by Account %
};
input string        Tlimits            = "== Daily Limits Setup =="; // ————————————
input bool          uDailyProfitOn     = false;                      // Control Daily Profit On:
input DayLimitsMode limitProfitMode    = LimitsByAmount;             // Mode to control daily profit:
input double        uDayLimitProfit    = 2000;                       // Max Daily Profit ($ or %):
input bool          uDailyLossOn       = false;                      // Control Daily Loss On:
input DayLimitsMode limitLossMode      = LimitsByAmount;             // Mode to control daily loss:
input double        uDayLimitLoss      = -1000;                      // Max Daily Loss ($ or %):
input bool          uConsiderFloatting = false;                      // Consider Floating:
#else
enum DayLimitsMode {
    LimitsByAmount,        // by Amount
    LimitsByAccountPercent // by Account %
};
bool          uDailyProfitOn     = false;          // Control Daily Profit On:
DayLimitsMode limitProfitMode    = LimitsByAmount; // Mode to control daily profit:
double        uDayLimitProfit    = 2000;           // Max Daily Profit ($ or %):
bool          uDailyLossOn       = false;          // Control Daily Loss On:
DayLimitsMode limitLossMode      = LimitsByAmount; // Mode to control daily loss:
double        uDayLimitLoss      = -1000;          // Max Daily Loss ($ or %):
bool          uConsiderFloatting = false;          // Consider Floating:
#endif

#ifdef CLOSE_ALL_ON
input string       TtpOposite              = "== Close Opposite ==";    // ————————————
input bool         closeAllInOpositeSignal = false;                     // Close all in opposite signal
input string       TtpOptions              = "== Close All Options =="; // ————————————
input bool         closeAllControlON       = false;                     // Close All Control On:
input CloseAllMode closeBy                 = CloseByMoney;              // Close All Mode:
input double       closeAllMoney           = 100;                       // Close by Money $:
input double       closeAllMoneyLoss       = -100;                      // Close by Money Lossing $:
input double       accountPerWin           = 1;                         // Account Percent Win:
input double       accountPerLos           = -1;                        // Account Percent Loss:
input double       closeByPipsWin          = 10;                        // Close Pips Win:
input double       closeByPipsLoss         = 10;                        // Close Pips Loss:
#else
string       TtpOptions              = "== Close All Options =="; // == Close All Options ==
bool         closeAllControlON       = false;                     // Close All Control ON:
CloseAllMode closeBy                 = CloseByMoney;              // Close All Mode:
double       closeAllMoney           = 100;                       // Close by Money $:
double       closeAllMoneyLoss       = -100;                      // Close by Money Lossing $:
double       accountPerWin           = 1;                         // Account Percent Win:
double       accountPerLos           = -1;                        // Account Percent Loss:
double       closeByPipsWin          = 10;                        // Close Pips Win:
double       closeByPipsLoss         = 10;                        // Close Pips Loss:
bool         closeAllInOpositeSignal = false;                     // CLose All In Oposite Signal
#endif

#ifdef PARTIAL_CLOSE_ON
input string Tpc                     = "== Partial Close =="; // ————————————
input bool   partialCloseOn          = false;                 // Partial Close On:
input double userPartialClosePercent = 50;                    // Partial Close Percent:
input double userPartialClosePips    = 20;                    // Partial Close Pips:
input int    uQntPartials            = 1;                     // Partials to take:
#else
string Tpc                     = "== Partial Close =="; // ————————————
bool   partialCloseOn          = false;                 // Partial Close On:
double userPartialClosePercent = 50;                    // Partial Close Percent:
double userPartialClosePips    = 20;                    // Partial Close Pips:
int    uQntPartials            = 1;                     // Partials to take:
#endif
#ifdef BREAKEVEN_ON
input string Tbk         = "== Breakeven Setup =="; // ————————————
input bool   breakevenOn = false;                   // Breakeven On:
input double userBkvPips = 10;                      // Breakeven Pips
input double userBkvStep = 3;                       // Breakeven Step
#else
string Tbk         = "== Breakeven Setup =="; // == Breakeven Setup ==
bool   breakevenOn = false;                   // Use Breakeven?
double userBkvPips = 10;                      // Breakeven Pips
double userBkvStep = 3;                       // Breakeven Step
#endif
#ifdef TRAILING_STOP_ON
input string tTailingStop       = "== TrailingStop Setup =="; // ————————————
input bool   TslON              = false;                      // TSL ON:
TSLMode      userTslMode        = byPips;                     // TSL Mode:
input int    userTslInitialStep = 1;                          // TSL Initial Step:
input int    userTslStep        = 1;                          // TSL Step:
input int    userTslDistance    = 20;                         // TSL Distance:
#else
string  tTailingStop       = "== TailingStop Setup =="; // == TailingStop Setup ==
bool    TslON              = false;                     // TSL ON:
TSLMode userTslMode        = byPips;                    // TSL Mode:
int     userTslInitialStep = 1;                         // TSL Initial Step:
int     userTslStep        = 1;                         // TSL Step:
int     userTslDistance    = 20;                        // TSL Distance:
#endif
#ifdef GRID_ON
input string tGrid               = "== Grid Setup =="; // ————————————
input bool   GridON              = false;              // Grid On:
input int    GridUser_maxCount   = 5;                  // Max attempts:
input double GridUser_maxLot     = 10;                 // Max lot value:
input double GridUser_multiplier = 1.5;                // Multiplier:
input int    GridUser_gap        = 30;                 // Gap betwen orders (pips):
input bool   closeGridOn         = true;               // Use Close Grid?
input double closeGridTP         = 100;                // Take Profit Grid $
input double closeGridSL         = -100;               // Stop Loss Grid -$
#else
string tGrid               = "== Grid Setup =="; // == Grid Setup ==
bool   GridON              = false;              // Use Grid:
int    GridUser_maxCount   = 5;                  // Max attempts:
double GridUser_maxLot     = 10;                 // Max lot value:
double GridUser_multiplier = 1.5;                // Multiplier:
int    GridUser_gap        = 30;                 // Gap betwen orders (pips):
bool   closeGridOn         = true;               // Use Close Grid?
double closeGridTP         = 100;                // Take Profit Grid $
double closeGridSL         = -100;               // Stop Loss Grid -$
#endif
#ifdef TIMER_FULL
input string   T1         = "== Trading Sessions  =="; // ————————————
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
#ifdef TIMER_MINI
input string T1        = "== Trading Sessions =="; // ————————————
input string timeStart = "00:00:00";               // Time Start GMT
input string timeEnd   = "23:59:59";               // Time End GMT
#endif
#ifdef TIMER_OFF
string T1        = "== Trading Sessions =="; // ————————————
string timeStart = "00:00:00";               // Time Start GMT
string timeEnd   = "23:59:59";               // Time End GMT
#endif
#ifdef NOTIFICATIONS_ON
input string TZ                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
#else
string TZ                    = "== Notifications =="; // Notifications
bool   notifications         = false;                 // Notifications On
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications
#endif

string             Iema           = "== Moving Average Setup =="; // ————————————
int                maPeriod       = 20;                           // Period
int                maShift        = 0;                            // Ma Shift
ENUM_MA_METHOD     maMethod       = MODE_EMA;                     // Method
ENUM_APPLIED_PRICE maAppliedPrice = PRICE_CLOSE;                  // Applied Price

string TFilters        = "== Filters Orders =="; // ————————————
bool   filterSymbolsOn = true;                   // Symbols filter On:
string SymbolsList     = "GBPUSD,EURUSD";        // Symbols (separate by comma ","):
bool   filterMagicsOn  = true;                   // Use magic number filter?
string MagicsList      = "2022";                 // Magics numbers (separate by comma ","):

#ifdef NEWS_FILTER
input string TNewsFilter     = "== News =="; // ————————————
input bool   newsOn          = false;        // News Filter On:
int input    Turn_OFF_Before = 30;           // Turn OFF before (min.)
int input    Turn_ON_After   = 30;           // Turn ON after (min.)

enum SourceNews { Manual,
                  Auto,
                  None };

SourceNews News_Fuente = Auto; // News Source:

int          AfterNewsStop  = 5;                                 // Indent after News, minuts
int          BeforeNewsStop = 5;                                 // Indent before News, minut
input bool   NewsLight      = false;                             // Enable light news
input bool   NewsMedium     = false;                             // Enable medium news
input bool   NewsHard       = true;                              // Enable hard news
input int    offset         = 0;                                 // Your Time Zone, GMT (for news)
input string NewsSymb       = "USD,EUR,GBP,CHF,CAD,AUD,NZD,JPY"; // Currency to display the news (empty - only the current currencies)
input bool   DrawLines      = true;                              // Draw lines on the chart
input bool   Next           = false;                             // Draw only the future of news line
bool         Signal         = true;                              // Signals on the upcoming news

color highc   = clrRed;     // Colour important news
color mediumc = clrOrange;  // Colour medium news
color lowc    = clrSkyBlue; // The color of weak news
int   Style   = 2;          // Line style
int   Upd     = 86400;      // Period news updates in seconds

bool Vhigh     = false;
bool Vmedium   = false;
bool Vlow      = false;
int  MinBefore = 10; // MINUTOS DE AVISO ANTES DE UNA NOTICIA
int  MinAfter  = 10; // MINUTOS DE AVISO DESPUES DE UNA NOTICIA

int      NomNews = 0;
string   NewsArr[4][1000];
int      Now = 0;
datetime LastUpd;
string   str1;

#endif

// Gobal Variables
// ——————————————————————————————————————————————————————————————————

// NOTE: License
#ifdef LICENSE_CONTROL_ON
class ConditionLicense
{
  private:
    string   _names[];
    datetime _date;
    // long   _acounts[];

  public:
    ConditionLicense(const string name) { addName(name); }
    ConditionLicense(datetime date) { _date = date; }
    ~ConditionLicense() {}

    bool addName(string name)
    {
        int t = ArraySize(_names);
        if (ArrayResize(_names, t + 1)) {
            _names[t] = name;
            return true;
        }
        return false;
    }

    bool controlByName()
    {
        for (int i = 0; i < ArraySize(_names); i++) {
            string name        = _names[i];
            string accountName = AccountInfoString(ACCOUNT_NAME);

            if (StringToUpper(name) && StringToUpper(accountName)) {
                if (name == accountName) {
                    return true;
                }
            }

            // busca si coincide una parte de name dentro de accountName:
            if (StringFind(accountName, name, 0) != -1) {
                return true;
            }
        }

        Alert("Account Without Licences. Info: tradingxbots@gmail.com");
        return false;
    }

    bool controlByDate()
    {
        datetime today = TimeCurrent();
        if (today >= _date) {
            Alert("Licences Expire. Info: tradingxbots@gmail.com");
            return false;
        }
        return true;
    }
};
ConditionLicense license(D '2022.03.30');
#endif

class MovingAverage
{
    string _symbol;
    int    _tf;

    struct MovingAverageParameters {
        int setup0; //  Period
        int setup1; //  Ma Shift
        int setup2; //  Method
        int setup3; //  Applied Price
    };
    MovingAverageParameters _setup;

  public:
    MovingAverage()
    {
        _symbol = _Symbol;
        _tf     = Period();
    }
    MovingAverage(string Symbol, int TimeFrame)
    {
        _symbol = Symbol;
        _tf     = TimeFrame;
    }
    MovingAverage(string Symbol, int TimeFrame, int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
    {
        _symbol = Symbol;
        _tf     = TimeFrame;
        setSetup(period, shift, method, appliedPrice);
    }
    ~MovingAverage() { ; }

    void setSetup(
        int set0,
        int set1,
        int set2,
        int set3)
    {
        _setup.setup0 = set0;
        _setup.setup1 = set1;
        _setup.setup2 = set2;
        _setup.setup3 = set3;
    }

    double calculate(int buffer, int shift)
    {
        return iMA(_symbol, _tf,
                   _setup.setup0,
                   _setup.setup1,
                   _setup.setup2,
                   _setup.setup3,
                   shift);
    }

    double index(int shift)
    {
        return calculate(0, shift);
    }
};
MovingAverage* ma;

interface iIndicators
{
    double calculate(int bufferNumber, int shift);
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
    double   _tslNext;
    bool     _bkvWasDoIt;
    int      _countPartials;

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
        double   profit,
        double   bkvWasDoIt,
        int      countPartials) : _id(id),
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
                             _profit(profit),
                             _bkvWasDoIt(bkvWasDoIt),
                             _countPartials(countPartials) {}

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
	Order* expireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* signalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* profit(double profit){_profit=profit; return &this;}
	Order* strategy(string strategy){_strategy=strategy; return &this;}
	Order* tslNext(double tslNext){_tslNext=tslNext; return &this;}
	Order* breakevenWasDoIt(bool bkvWasDoIt){_bkvWasDoIt=bkvWasDoIt; return &this;}
	Order* countPartials(int count){_countPartials=_countPartials + count; return &this;}

   int            id()               { return _id; }
   string         symbol()           { return _symbol; }
   double         price()            { return _price; }
   double         sl()               { return _sl; }
   double         tp()               { return _tp; }
   double         lot()              { return _lot; }
   int            type()             { return _type; }
   int            magic()            { return _magic; }
   string         comment()          { return _comment; }
   string         strategy()         { return _strategy; }
   datetime       expireTime()       { return _expireTime; }
   datetime       signalTime()       { return _signalTime; }
   double         profit()           { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit(); return -1; }
   double         tslNext()          { return _tslNext; }
   double         breakevenWasDoIt() { return _bkvWasDoIt; }
   int            countPartials()    { return _countPartials; }
};
class FilterBySymbols
{
   string _symbols[];

  public:
   FilterBySymbols(string userSymbols) { getSymbols(userSymbols); }
   ~FilterBySymbols() { ; }

   void getSymbols(string userSymbols)
   {
      string Simbolos[];
      string sep = ",";
      ushort u_sep;
      u_sep = StringGetCharacter(sep, 0);
      int k = StringSplit(userSymbols, u_sep, Simbolos);
      ArrayResize(_symbols, ArrayRange(Simbolos, 0), 0);
      for (int i = 0; i < ArrayRange(Simbolos, 0); i++)
      {
         _symbols[i] = Simbolos[i];
      }
      printSymbols();
   }

   bool control(const string symbolToControl)
   {
      if (ArraySize(_symbols) > 0)
      {
         for (int i = 0; i < ArraySize(_symbols); i++)
         {
            if (_symbols[i] == symbolToControl)
            {
               return true;
            }
         }
      }

      return false;
   }

   void printSymbols()
   {
      for (int i = 0; i < ArraySize(_symbols); i++)
      {
         Print(_symbols[i]);
      }
   }

   //---
};
class FilterByMagics
{
   int _magics[];

  public:
   FilterByMagics(string userMagics) { getMagics(userMagics); }
   ~FilterByMagics() { ; }

   void getMagics(string userMagics)
   {
      string Magicos[];
      string sep = ",";
      ushort u_sep;
      u_sep = StringGetCharacter(sep, 0);
      int k = StringSplit(userMagics, u_sep, Magicos);
      ArrayResize(_magics, ArrayRange(Magicos, 0), 0);
      for (int i = 0; i < ArrayRange(Magicos, 0); i++)
      {
         _magics[i] = (int)Magicos[i];
      }
      if (ArrayRange(_magics, 0) > 0)
      {
         ArraySort(_magics, WHOLE_ARRAY, 0, MODE_ASCEND);
      }
      printMagics();
   }

   bool control(const int magicToControl)
   {
      if (ArraySize(_magics) > 0)
      {			
         int p = ArrayBsearch(_magics, magicToControl, WHOLE_ARRAY, 0, MODE_ASCEND);
			if (_magics[p] == magicToControl)
         {
            return true;
         }
      }

      return false;
   }

   void printMagics()
   {
      for (int i = 0; i < ArraySize(_magics); i++)
      {
         Print(_magics[i]);
      }
   }
  
  
   //---
};
class OrdersList
{
   Order*          orders[];
   bool            _filterByMagicOn;
   bool            _filterBySymbolsOn;
   FilterByMagics* _magics;
   FilterBySymbols* _symbols;

  public:
  OrdersList(){;}
   OrdersList(bool uFilterByMagicOn, string uMagics, bool uFilterBySymbolsOn, string uSymbols)
   {
		_filterByMagicOn = uFilterByMagicOn;
		_filterBySymbolsOn = uFilterBySymbolsOn;
      _magics = new FilterByMagics(uMagics);
      _symbols = new FilterBySymbols(uSymbols);

      Print("New OrderList Created");
   }
   ~OrdersList() 
	{ 
		delete _magics;
		delete _symbols;
		clearList(); 
	}

   // ——————————————————————————————————————————————————————————————————

void setOrdersList(bool magicOn, string magics, bool symbolsOn, string symbols)
{
		_filterByMagicOn = magicOn;
		_filterBySymbolsOn = symbolsOn;
      _magics = new FilterByMagics(magics);
      _symbols = new FilterBySymbols(symbols);

}

   bool AddOrder(Order* order)
   {
      int t = ArraySize(orders);
      if (ArrayResize(orders, t + 1))
      {
         orders[t] = order;
         return true;
      }

      return false;
   }

   // recorrer las ordenes de mercado y agregar las que no estén en el array
   // ——————————————————————————————————————————————————————————————————
   void GetMarketOrders()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (_filterByMagicOn) if (!_magics.control(OrderMagicNumber())) { continue; }
            if (_filterBySymbolsOn) if (!_symbols.control(OrderSymbol())) { continue; }

            if (exist(OrderTicket()) == true) { continue; }

            Order* newOrder = new Order();
            newOrder
                .id(OrderTicket())
                .symbol(OrderSymbol())
                .price(OrderOpenPrice())
                .sl(OrderStopLoss())
                .tp(OrderTakeProfit())
                .lot(OrderLots())
                .type(OrderType())
                .magic(OrderMagicNumber())
                .comment(OrderComment())
                .expireTime(OrderExpiration())
                .profit(OrderProfit())
                .breakevenWasDoIt(false)
                .countPartials(0);

            if (AddOrder(newOrder))
            {
               PrintOrder(i);
            }
         }
      }
   }

   // agrega la última orden si no está en el array
   // ——————————————————————————————————————————————————————————————————
   bool GetLastMarketOrder()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (_filterByMagicOn) if(!_magics.control(OrderMagicNumber())) { continue; }
            if (_filterBySymbolsOn) if (!_symbols.control(OrderSymbol())) { continue; }
            if (exist(OrderTicket()) == true) { continue; }

            Order* newOrder = new Order();
            newOrder
                .id(OrderTicket())
                .symbol(OrderSymbol())
                .price(OrderOpenPrice())
                .sl(OrderStopLoss())
                .tp(OrderTakeProfit())
                .lot(OrderLots())
                .type(OrderType())
                .magic(OrderMagicNumber())
                .comment(OrderComment())
                .expireTime(OrderExpiration())
                .profit(OrderProfit())
                .breakevenWasDoIt(false)
                .countPartials(0);

            if (AddOrder(newOrder))
            {
                  Print(__FUNCTION__," ","* Nueva Orden De Mercado * ",id(i), "magic: ",magic(i));
                  // PrintOrder(i);
                  return true;
            }
         }
         return false;
      }
      return false;
   }

   // controlar si el id ya está adentro del array
   // ——————————————————————————————————————————————————————————————————
   bool exist(int id)
   {
      for (int i = qnt() - 1; i >= 0; i--)
      {
         if (id(i) == id)
         {
            return true;
         }
      }
      return false;
   }

   // borra una orden en la posición indicada y acomoda el array
   // ——————————————————————————————————————————————————————————————————
   bool deleteOrder(int index)
   {
      if (notOverFlow(index))
      {
         delete orders[index];
      }

      if (qnt() > index)
      {
         for (int i = index; i < qnt() - 1; i++)
         {
            orders[i] = orders[i + 1];
         }
         ArrayResize(orders, qnt() - 1);
         return true;
      }

      return false;
   }

   // borra todos los elementos de la lista
   // ——————————————————————————————————————————————————————————————————
   void clearList()
   {
      for (int i = 0; i < qnt(); i++)
      {
         if (CheckPointer(orders[i]) != POINTER_INVALID)
         {
            deleteOrder(i);
         }
      }
   }

   // devuelve el puntero a la última orden
   Order* last()
   {
      int lastIndex = ArraySize(orders) - 1;
      if (lastIndex == -1)
      {
         return NULL;
      }
      return GetPointer(orders[lastIndex]);
   }

   Order* index(int in)
   {
      return GetPointer(orders[in]);
   }

   int lastId()
   {
      int lastIndex = ArraySize(orders) - 1;
      return orders[lastIndex].id();
   }

   // ——————————————————————————————————————————————————————————————————
   bool notOverFlow(int index)
   {
      if (index > ArraySize(orders) - 1) return false;
      if (index < 0) return false;
      if (CheckPointer(orders[index]) == POINTER_INVALID) return false;

      return true;
   }

   // cantidad de ordenes guardadas
   // ——————————————————————————————————————————————————————————————————
   int qnt()
   {
      return ArraySize(orders);
   }

   // clang-format off
   // Metodos para acceder a información de cada trade mediante su index:
   // ——————————————————————————————————————————————————————————————————
   int id(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].id();
      }
      return -1;
   }
   string symbol(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].symbol();
      }
      return "";
   }
   double price(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].price();
      }
      return -1;
   }
   double sl(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].sl();
      }
      return -1;
   }
   double tp(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].tp();
      }
      return -1;
   }
   double lot(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].lot();
      }
      return -1;
   }
   int magic(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].magic();
      }
      return -1;
   }
   datetime expire(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].expireTime();
      }
      return -1;
   }
   datetime signalTime(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].signalTime();
      }
      return -1;
   }
   string comment(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].comment();
      }
      return "";
   }
   ENUM_ORDER_TYPE type(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].type();
      }
      return -1;
   }
   double profit(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].profit();
      }
      return -1;
   }

    // clang-format on

    // comprueba si la orden está cerrada
    // ——————————————————————————————————————————————————————————————————
    bool isClose(int index)
    {
        if (notOverFlow(index)) {
            if (OrderSelect(id(index), SELECT_BY_TICKET)) {
                if (OrderCloseTime() != 0)
                    return true;
            }
        }
        return false;
    }

    // borra de la lista los trades cerrados
    // ——————————————————————————————————————————————————————————————————
    void cleanCloseOrders()
    {
        if (qnt() == 0) {
            return;
        }

        for (int i = 0; i < qnt(); i++) {
            if (isClose(i)) {
                deleteOrder(i);
            }
        }
    }

    // cierra todas las ordenes en la lista y la limpia, te retorna la cantidad de errores
    int closeAllInList()
    {
        cleanCloseOrders();
        int errors = 0;

        for (int i = 0; i < ArraySize(orders); i++) {
            int tk;
            if (isClose(i)) {
                continue;
            }
            if (CheckPointer(orders[i]) != POINTER_INVALID) {
                tk = orders[i].id();
            } else {
                continue;
            }
            if (OrderSelect(tk, SELECT_BY_TICKET)) {
                double ask        = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
                double bid        = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
                double closePrice = OrderType() == OP_BUY ? bid : ask;
                if (!OrderClose(OrderTicket(), OrderLots(), closePrice, 1000, clrNONE)) {
                    Print(__FUNCTION__, " ", "Error in close order ", orders[i].id(), ": ", GetLastError());
                    errors++;
                }
            }
        }

        cleanCloseOrders();

        return errors;
    }

    // ——————————————————————————————————————————————————————————————————
    void PrintOrder(const int index)
    {
        if (!notOverFlow(index)) {
            return;
        }
        if (CheckPointer(orders[index]) == POINTER_INVALID) {
            return;
        }
        // clang-format off
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
      Print("Order ", index, " countPartials: ", orders[index].countPartials());
        // clang-format on
    }
    // ——————————————————————————————————————————————————————————————————
    void PrintList()
    {
        for (int i = 0; i < qnt(); i++) {
            PrintOrder(i);
        }
    }
};
OrdersList mainOrders(filterMagicsOn, (string)magico, filterSymbolsOn, _Symbol);

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

    // ——————————————————————————————————————————————————————————————————
    void releaseConditions()
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            delete _conditions[i];
        }
        ArrayFree(_conditions);
    }
    // ——————————————————————————————————————————————————————————————————
    void AddCondition(iConditions* condition)
    {
        int t = ArraySize(_conditions);
        ArrayResize(_conditions, t + 1);
        _conditions[t] = condition;
    }

    // ——————————————————————————————————————————————————————————————————
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
class ConditionMatchPrice : public iConditions
{
    string _symbol;
    string _side;
    double _price;
    int    _mode; // 0: Ask>=Price & Bid <=Price , 1: Ask <= Price && Bid >= Price

  public:
    ConditionMatchPrice(string Symbol, string Side, double Price, int Mode)
    {
        _symbol = Symbol;
        _side   = Side;
        _price  = Price;
        _mode   = Mode;
    }
    ~ConditionMatchPrice() { ; }

    void   side(string inpside) { _side = inpside; }
    string side(void) { return _side; }
    void   symbol(string inpsymbol) { _symbol = inpsymbol; }
    string symbol(void) { return _symbol; }
    void   price(double inpprice) { _price = inpprice; }
    double price(void) { return _price; }
    void   mode(int inpmode) { _mode = inpmode; }
    int    mode(void) { return _mode; }

    bool evaluate()
    {
        double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);

        if (_mode == 0) {
            if (_side == "buy") {
                if (ask >= _price) {
                    return true;
                }
                return false;
            }
            if (_side == "sell") {
                if (bid <= _price) {
                    return true;
                }
                return false;
            }
        }

        if (_mode == 1) {
            if (_side == "buy") {
                if (ask <= _price) {
                    return true;
                }
                return false;
            }
            if (_side == "sell") {
                if (bid >= _price) {
                    return true;
                }
                return false;
            }
        }
        return false;
    }
};
class ConditionMaxLot : public iConditions
{
    double _maxLot;
    double _lot;

  public:
    ConditionMaxLot(double MaxLot, double Lot)
    {
        _maxLot = MaxLot;
        _lot    = Lot;
    }
    ~ConditionMaxLot() { ; }
    void lot(double inplot) { _lot = inplot; }

    bool evaluate()
    {
        if (_maxLot >= _lot) {
            return true;
        }
        return false;
    }
};
class ConditionOrderCount : public iConditions
{
    OrdersList* _orders;
    int         _maxQnt;

  public:
    ConditionOrderCount(OrdersList* Orders, int MaxQnt)
    {
        _orders = Orders;
        _maxQnt = MaxQnt;
    }
    ~ConditionOrderCount() { ; }

    bool evaluate()
    {
        if (_orders.qnt() < _maxQnt) {
            return true;
        }
        return false;
    }
};

class DailyProfitCondition : public iConditions
{
    int           _magic;
    double        _limit;
    bool          _considerOpen; // Considera el flotante profit flotante
    string        _mode;         // loss or profit
    DayLimitsMode _limitMode;    // Amount or AccountPer
  public:
    DailyProfitCondition(double limit, int mag, bool considerOpen, string mode, DayLimitsMode limitMode) : _limit(limit), _magic(mag), _considerOpen(considerOpen), _mode(mode), _limitMode(limitMode) { ; }
    ~DailyProfitCondition() { ; }

    bool evaluate()
    {
        if (_mode == "profit") {
            if (TodayProfit() >= Limit()) {
                Print("DAILY PROFIT REACHED: ", TodayProfit());
                return true;
            }
        }
        if (_mode == "loss") {
            if (TodayProfit() <= Limit()) {
                Print("DAILY LOSS REACHED: ", TodayProfit());
                return true;
            }
        }
        return false;
    }

    double Limit()
    {
        if (_limitMode == LimitsByAmount) {
            return _limit;
        }
        if (_limitMode == LimitsByAccountPercent) {
            return _limit / 100 * AccountInfoDouble(ACCOUNT_BALANCE);
        }
        return 0;
    }

    double TodayProfit()
    {
        datetime iniDay = iTime(NULL, PERIOD_D1, 0);

        double profit = 0;
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic) {
                if (OrderCloseTime() >= iniDay) {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }

        if (_considerOpen) {
            for (int i = OrdersTotal() - 1; i >= 0; i--) {
                if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic) {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }

        return profit;
    }
};
#ifdef DAILY_LIMITS
DailyProfitCondition dailyProfitCondition(uDayLimitProfit, magico, uConsiderFloatting, "profit", limitProfitMode);
DailyProfitCondition dailyLossCondition(uDayLimitLoss, magico, uConsiderFloatting, "loss", limitLossMode);
#endif

interface iActions
{
    bool doAction();
};
class MoveSL : public iActions
{
    Order* _order;
    double _newSL;

  public:
    MoveSL() { ; }
    ~MoveSL() { ; }

    MoveSL* order(Order* or)
    {
        _order = or ;
        return &this;
    }
    MoveSL* newSL(double newSL)
    {
        _newSL = newSL;
        return &this;
    }

    bool controlPointer(Order* or)
    {
        if (CheckPointer(or)) {
            return true;
        } else {
            Print("Order Pointer Invalid");
            return false;
        }
    }

    bool doAction()
    {
        if (!controlPointer(_order)) {
            Print(__FUNCTION__, " ", "Can't Move Stop Loss");
            return false;
        }
        if (OrderSelect(_order.id(), SELECT_BY_TICKET)) {
            if (OrderCloseTime() > 0) {
                Print(__FUNCTION__, " ", "Order are closed ", _order.id());
                return false;
            }

            if (OrderModify(_order.id(), OrderOpenPrice(), _newSL, OrderTakeProfit(), OrderExpiration(), clrNONE)) {
                _order.sl(_newSL);
                _order.breakevenWasDoIt(true);
                Print(__FUNCTION__, " ", _order.id(), " Modify: new SL: ", _newSL);
                return true;
            }

        } else {
            Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
        }

        return false;
    }
};
MoveSL* breackevenAction;

class PartialClose : public iActions
{
    Order* _order;
    double _percentToClose;

  public:
    PartialClose() { ; }
    ~PartialClose() { ; }

    PartialClose* order(Order* or)
    {
        _order = or ;
        return &this;
    }
    PartialClose* percent(double percentToClose)
    {
        _percentToClose = percentToClose;
        return &this;
    }

    bool controlPointer(Order* or)
    {
        if (CheckPointer(or)) {
            return true;
        } else {
            Print("Order Pointer Invalid");
            return false;
        }
    }

    double lots()
    {
        // hay que ajustar el lotaje para volverlo al original
        int n = _order.countPartials();
        if (n > 0) {
            double originalLots = _order.lot() / (1 - (NormalizeDouble(_percentToClose / 100, 2) * n));
            return NormalizeDouble((originalLots * _percentToClose / 100), 2);
        }

        return NormalizeDouble((_order.lot() * _percentToClose / 100), 2);
    }

    double price()
    {
        double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

        if (_order.type() == OP_BUY) {
            return bid;
        }
        if (_order.type() == OP_SELL) {
            return ask;
        }
        return 0;
    }

    bool doAction()
    {
        if (!controlPointer(_order)) {
            Print(__FUNCTION__, " ", "Can't Take Partial");
            return false;
        }
        if (OrderSelect(_order.id(), SELECT_BY_TICKET)) {
            if (OrderCloseTime() > 0) {
                Print(__FUNCTION__, " ", "Order are closed ", _order.id());
                return false;
            }

            if (OrderClose(_order.id(), lots(), price(), 10000, clrNONE)) {
                // aumenta el contador de parciales
                _order.countPartials(1);

                // remplazar el tk por el nuevo tk
                changeTk(_order.id());

                Print(__FUNCTION__, " ", _order.id(), " Partial TP taked ");
                return true;
            }

        } else {
            Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
        }

        return false;
    }

    void changeTk(int tk)
    {
        if (OrderSelect(tk, SELECT_BY_TICKET)) {
            datetime dt     = OrderCloseTime();
            string   coment = OrderComment();
            int      pos    = StringFind(coment, "#") + 1;
            string   newId  = StringSubstr(coment, pos, StringLen(coment));
            _order.id((int)newId);
        }
    }
};
PartialClose* partialCloseAction;

class SendNewOrder : public iActions
{
  private:
    Order* newOrder;

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

        newOrder = new Order();

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

    Order* lastOrder()
    {
        return GetPointer(newOrder);
    }
};
SendNewOrder* actionSendOrder;

// GRID
// ——————————————————————————————————————————————————————————————————
class Grid
{
    ConcurrentConditions conditionsToOpenNewTrade;
    ConcurrentConditions conditionsToCloseGrid;
    ConditionMatchPrice* cdMatchPrice;
    ConditionOrderCount* cdMaxOrders;
    ConditionMaxLot*     cdMaxLot;
    SendNewOrder*        openTrade;
    // ActionCloseOrdersByType* actionCloseGrid;
    string     _symbol;
    string     _side;
    double     _nextPrice;
    double     _lastPrice;
    double     _gap;
    double     _multiplier;
    int        _maxQnt;
    double     _maxLot;
    double     _initialLot;
    double     _nextLot;
    int        _qnt;
    bool       _active;
    int        _magico;
    OrdersList gridOrders;

  public:
    Grid(string Symbol, string Side, double LastPrice, double Gap, double Multiplier, int MaxQnt, double MaxLot, double InitialLot, int magic, bool simbolFilterOn = true, bool magicFilterOn = true)
    {
        _symbol     = Symbol;
        _side       = Side;
        _lastPrice  = LastPrice;
        _gap        = Gap;
        _nextPrice  = nextPrice(LastPrice);
        _multiplier = Multiplier;
        _maxQnt     = MaxQnt + 1;
        _maxLot     = MaxLot;
        _initialLot = InitialLot;
        _nextLot    = nextLot();
        _magico     = magic;

        Print(_symbol);
        Print(_side);
        Print(_lastPrice);
        Print(_nextPrice);
        Print(_gap);
        Print(_multiplier);
        Print(_maxQnt);
        Print(_maxLot);
        Print(_initialLot);
        Print(_nextLot);

        gridOrders.setOrdersList(magicFilterOn, IntegerToString(_magico), simbolFilterOn, _symbol);
        gridOrders.GetLastMarketOrder();

        // Set Conditions:
        cdMatchPrice = new ConditionMatchPrice(_symbol, _side, _nextPrice, 1);
        cdMaxOrders  = new ConditionOrderCount(GetPointer(gridOrders), _maxQnt);
        cdMaxLot     = new ConditionMaxLot(_maxLot, _nextLot);

        cdMaxLot.lot(_nextLot);
        cdMatchPrice.price(_nextPrice);

        conditionsToOpenNewTrade.AddCondition(cdMatchPrice);
        conditionsToOpenNewTrade.AddCondition(cdMaxOrders);
        conditionsToOpenNewTrade.AddCondition(cdMaxLot);
    }
    ~Grid()
    {
        delete cdMatchPrice;
        delete cdMaxOrders;
        delete cdMaxLot;
        delete openTrade;
    }

    void lastPrice(int inplastPrice) { _lastPrice = inplastPrice; }
    bool active(void)
    {
        // si la primer orden está en perdidas:
        if (gridOrders.profit(0) < 0) {
            _active = true;
        } else {
            _active = false;
        }
        return _active;
    }
    double nextPrice(double inpLastPrice)
    {
        double mPoint = MarketInfo(_symbol, MODE_POINT);

        if (_side == "buy")
            _nextPrice = inpLastPrice - (_gap * mPoint * 10);
        if (_side == "sell")
            _nextPrice = inpLastPrice + (_gap * mPoint * 10);

        return _nextPrice;
    }
    void   gap(double inpGap) { _gap = inpGap; }
    void   multiplier(double inpmultiplier) { _multiplier = inpmultiplier; }
    void   maxQnt(int inpmaxQnt) { _maxQnt = inpmaxQnt; }
    void   maxLot(double inpmaxLot) { _maxLot = inpmaxLot; }
    double maxLot() { return _maxLot; }
    void   side(string inpside) { _side = inpside; }
    void   symbol(string inpsymbol) { _symbol = inpsymbol; }
    int    qnt()
    {
        return gridOrders.qnt();
    }
    double nextLot(void)
    {
        return NormalizeDouble(_initialLot * pow(_multiplier, qnt()), 2);
    };

    double profit()
    {
        double gridResult = 0;
        Print(__FUNCTION__, " ", "qnt()", " ", qnt());

        for (int i = 0; i < qnt(); i++) {
            if (CheckPointer(gridOrders.index(i)) != POINTER_INVALID)
                gridResult += gridOrders.profit(i);

            Print(__FUNCTION__, " ", "gridResult", " ", gridResult);
        }
        return gridResult;
    }

    void doGrid()
    {
        if (conditionsToOpenNewTrade.EvaluateConditions()) {
            if (_side == "buy") {
                openTrade = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), _magico);
                if (openTrade.doAction()) {
                    Print("pointer de la ultima orden: ", openTrade.lastOrder());
                    // if (gridOrders.AddOrder(openTrade.lastOrder()))
                    if (gridOrders.GetLastMarketOrder())
                        setNextTrade();
                }
                delete openTrade;
            }

            if (_side == "sell") {
                openTrade = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), _magico);
                if (openTrade.doAction()) {
                    // Print("pointer de la ultima orden: ", openTrade.lastOrder());
                    // if (gridOrders.AddOrder(openTrade.lastOrder()))
                    if (gridOrders.GetLastMarketOrder())
                        setNextTrade();
                }
                delete openTrade;
            }
        }
    }

    void setNextTrade()
    {
        nextPrice(gridOrders.last().price());
        // Print(__FUNCTION__, " ", "nextPrice: ", " ", _nextPrice);
        cdMaxLot.lot(nextLot());
        // Print(__FUNCTION__, " ", "nextLot()", " ", nextLot());
        cdMatchPrice.price(_nextPrice);
    }

    double Lots()
    {
        return nextLot();
    }

    double SL(string side)
    {
        return 0;
    }
    double TP(string side)
    {
        return 0;
    }

    void closeGrid()
    {
        gridOrders.cleanCloseOrders();
        if (qnt() == 0) {
            return;
        }

        int attempts = 0;
        while (gridOrders.closeAllInList() != 0 || attempts < 10) {
            attempts++;
        }
    }
};
Grid* gridBuy;
Grid* gridSell;

class ConditionSignalLimiter : public iConditions
{
    string _side;
    string _lastSide;

  public:
    ConditionSignalLimiter(string Side)
    {
        _side = Side;
    }
    ~ConditionSignalLimiter() { ; }

    void lastSide(string lastSignal)
    {
        _lastSide = lastSignal;
    }

    bool evaluate()
    {
        if (_side != _lastSide) {
            return true;
        }

        return false;
    }
};
ConditionSignalLimiter* availableToTakeSignalBuy;
ConditionSignalLimiter* availableToTakeSignalSell;

class ConditionGridActive : public iConditions
{
    Grid* _grid;

  public:
    ConditionGridActive(Grid* grid)
    {
        _grid = grid;
    }
    ~ConditionGridActive() { delete _grid; }

    bool evaluate()
    {
        if (CheckPointer(_grid) != POINTER_INVALID) {
            if (_grid.active()) {
                return false;
            }
        }
        return true;
    }
};
ConditionGridActive* gridActiveCondition;

class ConditionsModeOneTrue
{
  protected:
    iConditions* _conditions[];

  public:
    ConditionsModeOneTrue(void) {}
    ~ConditionsModeOneTrue(void) { releaseConditions(); }

    // ——————————————————————————————————————————————————————————————————
    void releaseConditions()
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            delete _conditions[i];
        }
        ArrayFree(_conditions);
    }
    // ——————————————————————————————————————————————————————————————————
    void AddCondition(iConditions* condition)
    {
        int t = ArraySize(_conditions);
        ArrayResize(_conditions, t + 1);
        _conditions[t] = condition;
    }

    // ——————————————————————————————————————————————————————————————————
    bool EvaluateConditions(void)
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            if (_conditions[i].evaluate()) {
                return true;
            }
        }
        return false;
    }
};

interface iLevels
{
    double calculateLevel();
    double pips();
};
class ByFixPips : public iLevels
{
    string _symbol;
    string _side;
    int    _pips;
    string _mode; // TP SL
    double _price;

  public:
    ByFixPips(string inpSymbol, string inpSide, int inpPips, string inpMode, double Price = 0)
    {
        _pips   = inpPips;
        _symbol = inpSymbol;
        _side   = inpSide;
        _mode   = inpMode;
        _price  = Price;
    }
    ~ByFixPips() { ; }

    double pips() { return _pips; }

    double calculateLevel()
    {
        double mPoint   = MarketInfo(_symbol, MODE_POINT);
        double distance = _pips * 10 * mPoint;

        if (_pips == 0) {
            return 0;
        }

        if (_mode == "SL") {
            distance *= -1;
        }

        if (_side == "buy") {
            double ask        = SymbolInfoDouble(_symbol, SYMBOL_ASK);
            double entryPrice = _price == 0 ? ask : _price;
            return entryPrice + distance;
        }

        if (_side == "sell") {
            double bid        = SymbolInfoDouble(_symbol, SYMBOL_BID);
            double entryPrice = _price == 0 ? bid : _price;
            return entryPrice - distance;
        }

        return -1;
    }
};
class ByMoney : public iLevels
{
    string _symbol;
    string _side;
    int    _pips;
    double _money;
    string _mode; // TP SL
    double _lot;

  public:
    ByMoney(string Symbol, string Side, double Lot, double Money, string Mode)
    {
        _lot    = Lot;
        _symbol = Symbol;
        _side   = Side;
        _mode   = Mode;
        _money  = Money;
    }
    ~ByMoney() { ; }

    double pips()
    {
        double _tickValue    = MarketInfo(_symbol, MODE_TICKVALUE);
        double _modeCalc     = MarketInfo(_symbol, MODE_PROFITCALCMODE);
        double _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        double _step         = MarketInfo(_symbol, MODE_LOTSTEP);
        double _points       = MarketInfo(_symbol, MODE_POINT);
        double _digits       = MarketInfo(_symbol, MODE_DIGITS);

        // FOREX
        if (_modeCalc == 0) {
            // lot = return NormalizeDouble(_money / distance / _tickValue, 2);
            return NormalizeDouble(_money / (_lot * _tickValue), 2);
        }

        // FUTUROS
        if (_modeCalc == 1 && _step != 1.0) {
            double c = _contractSize * _step;
            // return NormalizeDouble(_money / (distance * c), 2);
            // lot = _money / (distance * c)
            return NormalizeDouble((_money / c / _lot), 2);
        }

        // FUTUROS SIN DECIMALES
        if (_modeCalc == 1 && _step == 1.0) {
            double c = _contractSize * _step;
            // return MathFloor(_money / (distance * c) * 100);
            return MathFloor((_money / c / _lot) / 100);
        }

        return 0;
    }

    double calculateLevel()
    {
        _pips         = (int)pips();
        double mPoint = MarketInfo(_symbol, MODE_POINT);
        // double distance = _pips * 10 * mPoint;
        double distance = _pips * mPoint;
        double result   = 0;
        double ask      = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double bid      = SymbolInfoDouble(_symbol, SYMBOL_BID);

        if (_pips == 0) {
            return 0;
        }
        if (_mode == "SL") {
            distance *= -1;
        }
        if (_side == "buy") {
            return ask + distance;
        }
        if (_side == "sell") {
            return bid - distance;
        }
        return -1;
    }
};
class ByPipsFromCandle : public iLevels
{
    string _symbol;
    string _side;
    int    _pips;
    string _mode; // TP SL
    int    _tfCandle;
    int    _shiftCandle;

  public:
    ByPipsFromCandle(string inpSymbol, string inpSide, int inpPips, string inpMode, int timeFrameCandle, int shiftCandle)
    {
        _pips        = inpPips;
        _symbol      = inpSymbol;
        _side        = inpSide;
        _mode        = inpMode;
        _tfCandle    = timeFrameCandle;
        _shiftCandle = shiftCandle;
    }
    ~ByPipsFromCandle() { ; }
    double pips()
    {
        return _pips;
    }

    double calculateLevel()
    {
        double mPoint   = MarketInfo(_symbol, MODE_POINT);
        double distance = _pips * 10 * mPoint;
        double result   = 0;
        double high     = iHigh(_symbol, _tfCandle, _shiftCandle);
        double low      = iLow(_symbol, _tfCandle, _shiftCandle);

        if (_pips == 0) {
            return 0;
        }

        if (_side == "buy") {
            if (_mode == "TP")
                return high + distance;
            if (_mode == "SL")
                return low - distance;
        }
        if (_side == "sell") {
            if (_mode == "TP")
                return low - distance;
            if (_mode == "SL")
                return high + distance;
        }
        return -1;
    }
};
class ByATR : public iLevels
{
    string          _symbol;
    string          _side;
    double          _pips;
    string          _mode; // TP SL
    ENUM_TIMEFRAMES _tf;
    int             _period;
    int             _shift;
    double          _m;

  public:
    ByATR(string inpSymbol, string inpSide, string inpMode, ENUM_TIMEFRAMES inpATRTf, int inpATRPeriod, int inpATRShift, double inpATRmultiplier)
    {
        _symbol = inpSymbol;
        _side   = inpSide;
        _mode   = inpMode;
        _tf     = inpATRTf;
        _period = inpATRPeriod;
        _shift  = inpATRShift;
        _m      = inpATRmultiplier;
    }
    ~ByATR() { ; }

    double atr()
    {
        double digits = SymbolInfoInteger(_symbol, SYMBOL_DIGITS);
        double atr    = NormalizeDouble(iATR(_symbol, _tf, _period, _shift), digits);
        return atr;
    }

    double calculateLevel()
    {
        double mPoint   = MarketInfo(_symbol, MODE_POINT);
        double ask      = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double bid      = SymbolInfoDouble(_symbol, SYMBOL_BID);
        double spread   = ask - bid;
        double distance = (atr() * _m) + spread;
        Print(__FUNCTION__, " ", "distance", " ", distance);
        _pips         = distance / mPoint / 10;
        double result = 0;

        if (_pips == 0) {
            return 0;
        }

        if (_mode == "SL") {
            distance *= -1;
        }

        if (_side == "buy") {
            return ask + distance;
        }
        if (_side == "sell") {
            return bid - distance;
        }
        return -1;
    }

    double pips()
    {
        calculateLevel();
        return _pips;
    }

    void setSide(string inpSide)
    {
        _side = inpSide;
    }
};
class ByRatio : public iLevels
{
    string   _symbol;
    string   _side;
    int      _pips;
    string   _mode; // TP SL
    double   _ratio;
    double   _priceSL;
    iLevels* _sl;

  public:
    ByRatio(string inpSymbol, string inpSide, double inpPriceSL, double inpRatio, string inpMode, iLevels* sl)
    {
        _symbol  = inpSymbol;
        _side    = inpSide;
        _mode    = inpMode;
        _ratio   = inpRatio;
        _priceSL = inpPriceSL;
        _sl      = sl;
    }
    ~ByRatio() { ; }

    void setSide(string inpSide)
    {
        _side = inpSide;
    }

    double calculateLevel()
    {
        setPips();
        if (_pips == 0) {
            return 0;
        }

        double mPoint   = MarketInfo(_symbol, MODE_POINT);
        double distance = _pips * 10 * mPoint;
        double result   = 0;
        double ask      = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double bid      = SymbolInfoDouble(_symbol, SYMBOL_BID);

        if (_mode == "SL") {
            distance *= -1;
        }
        if (_side == "buy") {
            return ask + distance;
        }
        if (_side == "sell") {
            return bid - distance;
        }

        return -1;
    }

    void setPips()
    {
        _pips = _sl.pips() * _ratio;
    }

    double pips()
    {
        setPips();
        return _pips;
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
    iLevels* level()
    {
        return _level;
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
Levels* levelSL;

class ActionCloseOrdersByType : public iActions
{
    ENUM_ORDER_TYPE _type;
    string          _symbol;
    int             _magic;
    int             _slippage;
    double          _price;

  public:
    ActionCloseOrdersByType(string side, int magic = 0, string symbol = "", int slippage = 10000)
    {
        if (side == "buy")
            _type = OP_BUY;
        if (side == "sell")
            _type = OP_SELL;
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
        if (_type == OP_BUY) {
            _price = SymbolInfoDouble(_symbol, SYMBOL_BID);
        }
        if (_type == OP_SELL) {
            _price = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        }
    }

    bool doAction()
    {
        setPrice();
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic && OrderType() == _type) {
                if (!OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE)) {
                    Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
                    return false;
                }
            }
        }
        return true;
    }
};
ActionCloseOrdersByType* actionCloseSells;
ActionCloseOrdersByType* actionCloseBuys;

class ActionDeletePendings : public iActions
{
    string _symbol;
    int    _magic;
    string _side;

  public:
    ActionDeletePendings(string side, int magic = 0, string symbol = "")
    {
        _side   = side;
        _symbol = symbol == "" ? Symbol() : symbol;
        _magic  = magic != 0 ? magic : 0;
    }
    ~ActionDeletePendings() {}

    bool doAction()
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic) {
                if (_side == "buy" && (OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT)) {
                    OrderDelete(OrderTicket());
                }
                if (_side == "sell" && (OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT)) {
                    OrderDelete(OrderTicket());
                }
            }
        }
        return true;
    }
};
ActionDeletePendings* actionDeletePendingsBuys;
ActionDeletePendings* actionDeletePendingsSells;

interface iTSL
{
    void   setInitialStep(Order * order);
    void   setNextStep(Order * order);
    double newSL(Order * order);
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
        double mPoint       = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _InitialStep * mPoint;
        if (order.type() == OP_SELL) {
            pointsToMove *= -1;
        }
        order.tslNext(order.price() + pointsToMove);

        Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
        Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
    }

    void setNextStep(Order* order)
    {
        double mPoint       = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _TslStep * mPoint;
        if (order.type() == OP_SELL) {
            pointsToMove *= -1;
        }
        order.tslNext(order.tslNext() + pointsToMove);

        Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
        Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
    }

    double newSL(Order* order)
    {
        double mPoint       = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _Distance * mPoint;
        if (order.type() == OP_SELL) {
            pointsToMove *= -1;
        }

        double newSl = order.tslNext() - pointsToMove;
        Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        Print(__FUNCTION__, " ", "TSL New SL: ", " ", newSl);

        return newSl;
    }
};

class TrailingStop
{
    OrdersList* _orders;
    iTSL*       _TslMode;

  public:
    TrailingStop(OrdersList* uOrders, TSLMode mode)
    {
        _orders = uOrders;

        switch (mode) {
        case byPips:
            _TslMode = new TslByPips(userTslInitialStep, userTslStep, userTslDistance);
            break;
            // case byMA:
            // _TslMode = new TslByMA(userTslMaTf, tslMaPeriod, tslMaShift, tslMaMethod, tslMaAppliedPrice);
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
        if (order.type() == OP_BUY) {
            if (bid >= order.tslNext()) {
                return true;
            }
        }
        if (order.type() == OP_SELL) {
            if (ask <= order.tslNext()) {
                return true;
            }
        }
        return false;
    }

    void moveSL(int tk, double newSl)
    {
        if (OrderSelect(tk, SELECT_BY_TICKET)) {
            if (!OrderModify(tk, OrderOpenPrice(), newSl, OrderTakeProfit(), 0)) {
                Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " ", GetLastError());
            } else {
                Print(__FUNCTION__, " trailing stop in tk: ", tk);
            }
        }
    }
};
TrailingStop* tsl;

bool CloseCandleMode = true; // meter en la clase CloseCandle
class LotCalculator
{
    double _tickValue;
    double _modeCalc;
    double _contractSize;
    double _step;
    string _symbol;
    double _points;
    double _digits;

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
    }

    double LotsByBalancePercent(double BalancePercent, double Distance)
    {
        double risk = AccountBalance() * BalancePercent / 100;
        return CalculateLots(risk, Distance);
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
class ScheduleController
{
    Session* schedules[];
    int      _actualIndex;
    Session* _actualSession;
    int      _currentDay;
    double   _timeZone; // modificador para ajustar GMT

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
        _currentDay = TimeDay(TimeGMT() + _timeZone); // return the day of the month 1-31
    }

    bool isNewDay()
    {
        if (TimeDay(TimeGMT() + _timeZone) != _currentDay) {
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

    bool AddSession(string ini, string end, int day = 0)
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

    bool doSessionControl() // control day and hours for every session
    {
        Comment("Daily Control - EA OFF");

        int actual = (TimeHour(TimeGMT() + _timeZone) * 3600) + (TimeMinute(TimeGMT() + _timeZone) * 60);

        for (int i = 0; i < qnt(); i++) {
            if (schedules[i].dayNumber() == EA_OFF) {
                continue;
            }

            if (schedules[i].dayNumber() != 0) {
                if (schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT() + _timeZone)) {
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

        //---
        setActualSession(-1);
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
    int    velasInicio;
    string m_symbol;
    int    m_tf;

  public:
    CNewCandle();
    CNewCandle(string symbol, int tf) : m_symbol(symbol), m_tf(tf), velasInicio(iBars(symbol, tf)) {}
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

ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;
// ConditionsModeOneTrue    conditionsToCloseBuy;
ConcurrentConditions conditionsToCloseBuy;
// ConditionsModeOneTrue    conditionsToCloseSell;
ConcurrentConditions conditionsToCloseSell;
ConcurrentConditions conditionsToBreackeven;
ConcurrentConditions conditionsToPartialClose;

class BUYcondition1 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition Buy
        return iCustom(NULL, 0, custom_indi_Volume, indi_vol_periods, 0, 1) != EMPTY_VALUE;
    }
};
BUYcondition1* buyCondition1;
class BUYcondition2 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition Buy 2
        return iCustom(NULL, 0, custom_indi_Trend, Length, Desviation, MoneyRisk, 2, 1) != -1;
    }
};
BUYcondition2* buyCondition2;
class BUYcondition3 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition Buy 3
        return iCustom(NULL, 0, custom_indi_Vortex, vi_length, 0, 1) > iCustom(NULL, 0, custom_indi_Vortex, vi_length, 1, 1);
    }
};
BUYcondition3* buyCondition3;
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
class ConditionCountTrades : public iConditions
{
    int _max;

  public:
    ConditionCountTrades(int maxTrades)
    {
        _max = maxTrades;
    }
    ~ConditionCountTrades() { ; }

    bool evaluate()
    {
        int count = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
                count += 1;

                if (count == _max) {
                    return false;
                }
            }
        }
        return true;
    }
};
ConditionCountTrades* countTrades;

class SELLcondition1 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition sell 1
        return iCustom(NULL, 0, custom_indi_Volume, indi_vol_periods, 0, 1) != EMPTY_VALUE;
    }
};
SELLcondition1* sellCondition1;
class SELLcondition2 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition sell 2
        return iCustom(NULL, 0, custom_indi_Trend, Length, Desviation, MoneyRisk, 3, 1) != -1;
    }
};
SELLcondition2* sellCondition2;
class SELLcondition3 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition sell 3
        return iCustom(NULL, 0, custom_indi_Vortex, vi_length, 0, 1) < iCustom(NULL, 0, custom_indi_Vortex, vi_length, 1, 1);
    }
};
SELLcondition3* sellCondition3;
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

// TODO: close Conditions
class ConditionToCloseBuy : public iConditions
{
  public:
    bool evaluate()
    {
        if (closeAllInOpositeSignal) {
            // return conditionsToSell.EvaluateConditions();
            return sellCondition1.evaluate() && sellCondition2.evaluate() && sellCondition3.evaluate();
        }
        if (closeAllControlON) {
            return CloseAllControl();
        }

#ifdef DAILY_LIMITS
        if (uDailyProfitOn) {
            if (dailyProfitCondition.evaluate())
                return true;
        }
        if (uDailyLossOn) {
            if (dailyLossCondition.evaluate())
                return true;
        }
#endif

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
            // return conditionsToBuy.EvaluateConditions();
            return buyCondition1.evaluate() && buyCondition2.evaluate() && buyCondition3.evaluate();
        }
        if (closeAllControlON) {
            return CloseAllControl();
        }

#ifdef DAILY_LIMITS
        if (uDailyProfitOn) {
            if (dailyProfitCondition.evaluate())
                return true;
        }
        if (uDailyLossOn) {
            if (dailyLossCondition.evaluate())
                return true;
        }
#endif

        return false;
    }
};
ConditionToCloseSell* conditionCloseSell;

class BreackevenCondition : public iConditions
{
    // TODO: bk condition
    Order* _order;

  public:
    void setOrder(Order* or)
    {
        _order = or ;
    }

    bool evaluate()
    {
        // si el precio actual coindide con el momento de hacer bk ret true
        double mPoints = MarketInfo(_order.symbol(), MODE_POINT);
        double ask     = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid     = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);
        double dist    = userBkvPips * mPoints * 10;

        if (_order.type() == OP_BUY) {
            if (bid >= _order.price() + dist) {
                return true;
            }
        }
        if (_order.type() == OP_SELL) {
            if (ask <= _order.price() - dist) {
                return true;
            }
        }

        return false;
    }
};
BreackevenCondition* breackevenCondition;

class PartialCloseCondition : public iConditions
{
    // TODO: PC condition
    Order* _order;

  public:
    void setOrder(Order* or)
    {
        _order = or ;
    }

    bool evaluate()
    {
        double mPoints = MarketInfo(_order.symbol(), MODE_POINT);
        double ask     = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid     = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

        int    n = _order.countPartials();
        double dist;
        if (n == 0)
            dist = userPartialClosePips * mPoints * 10;
        if (n > 0)
            dist = userPartialClosePips * mPoints * 10 * (n + 1);

        if (_order.type() == OP_BUY) {
            if (bid >= _order.price() + dist) {
                Print(__FUNCTION__, " ", "_order.price()", " ", _order.price());
                Print(__FUNCTION__, " ", "bid", " ", bid);
                return true;
            }
        }
        if (_order.type() == OP_SELL) {
            if (ask <= _order.price() - dist) {
                return true;
            }
        }

        return false;
    }
};
PartialCloseCondition* partialCloseCondition;

//////////////////////////////////////////////////////////////////////
// NOTE: OnInit
int OnInit()
{
#ifdef LICENSE_CONTROL_ON
    if (!license.controlByDate()) {
        return INIT_FAILED;
    }
#endif

#ifdef CONTROL_CUSTOM_INDICATOR_FILE
    double temp = iCustom(NULL, 0, custom_indi_Volume, 0, 0);
    if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD) {
        Alert("Please, install the: " + custom_indi_Volume + " indicator, in folder MQL4/Indicators");
        return INIT_FAILED;
    }
    double temp2 = iCustom(NULL, 0, custom_indi_Trend, 0, 0);
    if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD) {
        Alert("Please, install the: " + custom_indi_Trend + " indicator, in folder MQL4/Indicators");
        return INIT_FAILED;
    }
    double temp3 = iCustom(NULL, 0, custom_indi_Vortex, 0, 0);
    if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD) {
        Alert("Please, install the: " + custom_indi_Vortex + " indicator, in folder MQL4/Indicators");
        return INIT_FAILED;
    }
#endif

    newCandle = new CNewCandle();
    tsl       = new TrailingStop(GetPointer(mainOrders), byPips);

    //--- CONDITIONS TO OPEN TRADES:
    //--- buys:
    if (indi_vol_on)
        conditionsToBuy.AddCondition(buyCondition1 = new BUYcondition1());
    if (indi_trend_on)
        conditionsToBuy.AddCondition(buyCondition2 = new BUYcondition2());
    if (vortex_on)
        conditionsToBuy.AddCondition(buyCondition3 = new BUYcondition3());
    // conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1));
    // availableToTakeSignalBuy = new ConditionSignalLimiter("buy");
    // conditionsToBuy.AddCondition(availableToTakeSignalBuy);

    //--- sell:
    if (indi_vol_on)
        conditionsToSell.AddCondition(sellCondition1 = new SELLcondition1());
    if (indi_trend_on)
        conditionsToSell.AddCondition(sellCondition2 = new SELLcondition2());
    if (vortex_on)
        conditionsToSell.AddCondition(sellCondition3 = new SELLcondition3());
        // conditionsToSell.AddCondition(countSells = new ConditionCountSells(1));
        // availableToTakeSignalSell = new ConditionSignalLimiter("sell");
        // conditionsToSell.AddCondition(availableToTakeSignalSell);

#ifdef MAX_TRADES_AT_SAME_TIME
    conditionsToBuy.AddCondition(countTrades = new ConditionCountTrades(uMaxTrades));
    conditionsToSell.AddCondition(countTrades = new ConditionCountTrades(uMaxTrades));
#endif

    //--- CONDITIONS TO CLOSE TRADES:
    conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());
    conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());

    //--- CONDITIONS TO BREAKEVEN:
    conditionsToBreackeven.AddCondition(breackevenCondition = new BreackevenCondition());

    //--- CONDITIONS TO PARTIAL CLOSE:
    conditionsToPartialClose.AddCondition(partialCloseCondition = new PartialCloseCondition());

//--- SESSIONS CONTROL:
#ifdef TIMER_FULL
    sesionControl.setTimeZone(uTimeZone);
    if (day1_On)
        sesionControl.AddSession(day1_Start, day1_End, day1);
    if (day2_On)
        sesionControl.AddSession(day2_Start, day2_End, day2);
    if (day3_On)
        sesionControl.AddSession(day3_Start, day3_End, day3);
    if (day4_On)
        sesionControl.AddSession(day4_Start, day4_End, day4);
    if (day5_On)
        sesionControl.AddSession(day5_Start, day5_End, day5);
#endif
#ifdef TIMER_MINI
    sesionControl.AddSession(timeStart, timeEnd);
#endif

    // EventSetTimer(1);

    // Note: Indicators
    // Example: indicator.setSetup(set0, set1... setn);
    //--- INDICATORS SETUPS:
    // pfe = new PFE(_Symbol, Period());
    ma = new MovingAverage();
    ma.setSetup(maPeriod, maShift, maMethod, maAppliedPrice);

#ifdef NEWS_FILTER
    if (StringLen(NewsSymb) > 1)
        str1 = NewsSymb;
    else
        str1 = Symbol();

    Vhigh   = NewsHard;
    Vmedium = NewsMedium;
    Vlow    = NewsLight;

    MinBefore = BeforeNewsStop;
    MinAfter  = AfterNewsStop;

    LastUpd = 0;
#endif

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    delete newCandle;
    delete tsl;
}

// NOTE: OnTick
void OnTick()
{
#ifdef NEWS_FILTER
    if (newsOn) {
        News_Automatic();
        if (ControlNewsTime()) {
            return;
        }
    }
#endif

    mainOrders.cleanCloseOrders();
    mainOrders.GetMarketOrders();

    CheckearOrdernesyGenerarGrids();
    // Breackeven Conditions & action
    // ——————————————————————————————————————————————————————————————————
    if (breakevenOn)
        doBreackevenAction();
    if (TslON)
        tsl.doTSL();

    // Partial Close:
    // ——————————————————————————————————————————————————————————————————
    if (partialCloseOn)
        doPartialCloseAction();

    if (GridON == true && CheckPointer(gridSell) != POINTER_INVALID) {
        gridSell.doGrid();
        mainOrders.GetMarketOrders();
    }
    if (GridON == true && CheckPointer(gridBuy) != POINTER_INVALID) {
        gridBuy.doGrid();
        mainOrders.GetMarketOrders();
    }
    if (GridON == true && closeGridOn == true) {
        doCloseGridControl();
    }

    if (!sesionControl.doSessionControl()) {
        return;
    }

    // ——————————————————————————————————————————————————————————————————
    if (!uTradeReverse) {
        if (conditionsToCloseBuy.EvaluateConditions()) {
            closeAll("buy");
        }
        if (conditionsToCloseSell.EvaluateConditions()) {
            closeAll("sell");
        }
    }
    if (uTradeReverse) {
        if (conditionsToCloseSell.EvaluateConditions()) {
            closeAll("buy");
        }
        if (conditionsToCloseBuy.EvaluateConditions()) {
            closeAll("sell");
        }
    }
    // ——————————————————————————————————————————————————————————————————

    //--- CANDLE CLOSE:
    if (CloseCandleMode)
        if (!newCandle.IsNewCandle()) {
            return;
        }

        // ——————————————————————————————————————————————————————————————————
#ifdef SPREAD_FILTER
    if (SpreadFilterOn)
        if (!spreadFilter())
            return;
#endif

#ifdef DAILY_LIMITS
    if (uDailyProfitOn) {
        if (dailyProfitCondition.evaluate())
            return;
    }
    if (uDailyLossOn) {
        if (dailyLossCondition.evaluate())
            return;
    }
#endif

    // ——————————————————————————————————————————————————————————————————

    // NOTE: BUY normal
    if (!uTradeReverse) {
        if (conditionsToBuy.EvaluateConditions()) {
            if (modeEntry == Market) {
                // double lot      = Lots();
                double sl       = SL("buy");
                double lot = calcLot(1, _Symbol, sl);
                double tp       = TP("buy", 0, sl, lot);
                actionSendOrder = new SendNewOrder("buy", lot, "", 0, sl, tp, magico);
                // actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);

            } else {
                double pr       = Price("buy", uEntryDistance, _Symbol);
                actionSendOrder = new SendNewOrder("buy", Lots(), "", pr, SL("buy", pr), TP("buy", pr), magico);
            }

            if (actionSendOrder.doAction()) {
                mainOrders.GetMarketOrders();

                if (GridON == true && CheckPointer(gridBuy) == POINTER_INVALID) {
                    gridBuy = new Grid(_Symbol, "buy", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
                    conditionsToBuy.AddCondition(gridActiveCondition = new ConditionGridActive(gridBuy));
                }

                // availableToTakeSignalBuy.lastSide("buy");
                // availableToTakeSignalSell.lastSide("buy");
                Notifications(0);
            }

            delete actionSendOrder;
            delete levelTP;
            delete levelSL;
        }
        // NOTE: SELL normal
        if (conditionsToSell.EvaluateConditions()) {
            if (modeEntry == Market) {
                // double lot      = Lots();
                double sl       = SL("sell");
                double lot      = calcLot(2, _Symbol, sl);
                double tp       = TP("sell", 0, sl, lot);
                actionSendOrder = new SendNewOrder("sell", lot, "", 0, sl, tp, magico);
            } else {
                double pr       = Price("sell", uEntryDistance, _Symbol);
                actionSendOrder = new SendNewOrder("sell", Lots(), "", pr, SL("sell", pr), TP("sell", pr), magico);
            }
            if (actionSendOrder.doAction()) {
                mainOrders.GetMarketOrders();

                if (GridON == true && CheckPointer(gridSell) == POINTER_INVALID) {
                    Print(__FUNCTION__, " ", "Voy a setear la gridSell");
                    gridSell = new Grid(_Symbol, "sell", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
                    Print(__FUNCTION__, " ", "pointer de la grid", GetPointer(gridSell));
                    conditionsToSell.AddCondition(gridActiveCondition = new ConditionGridActive(gridSell));
                }

                // availableToTakeSignalBuy.lastSide("sell");
                // availableToTakeSignalSell.lastSide("sell");
                Notifications(1);
            }
            delete actionSendOrder;
            delete levelTP;
            delete levelSL;
        }
    }

    if (uTradeReverse) {
        // NOTE: BUY reverse
        if (conditionsToSell.EvaluateConditions()) {
            if (modeEntry == Market) {
                actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
            } else {
                double pr       = Price("buy", uEntryDistance, _Symbol);
                actionSendOrder = new SendNewOrder("buy", Lots(), "", pr, SL("buy", pr), TP("buy", pr), magico);
            }

            if (actionSendOrder.doAction()) {
                mainOrders.GetMarketOrders();

                if (GridON == true && CheckPointer(gridBuy) == POINTER_INVALID) {
                    gridBuy = new Grid(_Symbol, "buy", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
                    conditionsToBuy.AddCondition(gridActiveCondition = new ConditionGridActive(gridBuy));
                }

                // availableToTakeSignalBuy.lastSide("buy");
                // availableToTakeSignalSell.lastSide("buy");
                Notifications(0);
            }

            delete actionSendOrder;
            delete levelTP;
            delete levelSL;
        }
        // NOTE: SELL reverse
        if (conditionsToBuy.EvaluateConditions()) {
            if (modeEntry == Market) {
                actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
            } else {
                double pr       = Price("sell", uEntryDistance, _Symbol);
                actionSendOrder = new SendNewOrder("sell", Lots(), "", pr, SL("sell", pr), TP("sell", pr), magico);
            }
            if (actionSendOrder.doAction()) {
                mainOrders.GetMarketOrders();

                if (GridON == true && CheckPointer(gridSell) == POINTER_INVALID) {
                    Print(__FUNCTION__, " ", "Voy a setear la gridSell");
                    gridSell = new Grid(_Symbol, "sell", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
                    Print(__FUNCTION__, " ", "pointer de la grid", GetPointer(gridSell));
                    conditionsToSell.AddCondition(gridActiveCondition = new ConditionGridActive(gridSell));
                }

                // availableToTakeSignalBuy.lastSide("sell");
                // availableToTakeSignalSell.lastSide("sell");
                Notifications(1);
            }
            delete actionSendOrder;
            delete levelTP;
            delete levelSL;
        }
    }
}

void OnTimer(void) {}

//////////////////////////////////////////////////////////////////////

double Price(string direction, int pips = 0, string _symbol = "")
{
    string symbol   = _symbol == "" ? Symbol() : _symbol;
    double points   = MarketInfo(symbol, MODE_POINT);
    double distance = pips * 10 * points;
    int    digits   = MarketInfo(symbol, MODE_DIGITS);

    if (direction == "buy") {
        double ask   = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double price = distance == 0 ? ask : ask + distance;

        if (modeEntry == PendingStop) {
            double cl = iClose(symbol, 0, 1);
            double op = iOpen(symbol, 0, 1);
            if (cl > op) {
                price = cl + distance;
            } else {
                price = op + distance;
            }
        }
        if (modeEntry == PendingLimit) {
            double cl = iClose(symbol, 0, 1);
            double op = iOpen(symbol, 0, 1);
            if (cl > op) {
                price = op - distance;
            } else {
                price = cl - distance;
            }
        }

        return NormalizeDouble(price, digits);
    }

    if (direction == "sell") {
        double bid   = SymbolInfoDouble(_symbol, SYMBOL_BID);
        double price = distance == 0 ? bid : bid + distance;

        if (modeEntry == PendingStop) {
            double cl = iClose(symbol, 0, 1);
            double op = iOpen(symbol, 0, 1);
            if (cl > op) {
                price = op - distance;
            } else {
                price = cl - distance;
            }
        }
        if (modeEntry == PendingLimit) {
            double cl = iClose(symbol, 0, 1);
            double op = iOpen(symbol, 0, 1);
            if (cl > op) {
                price = cl + distance;
            } else {
                price = op + distance;
            }
        }

        return NormalizeDouble(price, digits);
    }

    return -1;
}

// NOTE: SL
double SL(string side, double price = 0, double lot = 0)
{
    int dir = side == "sell" ? 2 : 1;
    return calcSL(dir, _Symbol, lot);

    double result = 0;
    if (stopLossOn)
        switch (modeSL) {
        case byATR:
            levelSL = new Levels(new ByATR(_Symbol, side, "SL", PERIOD_CURRENT, 14, 0, atr_m));
            result  = levelSL.calculateLevel();
            break;
        case sl_FixPips:
            levelSL = new Levels(new ByFixPips(_Symbol, side, userSLpips, "SL", price));
            result  = levelSL.calculateLevel();
            break;

            // case byMoney:
            //   levelSL = new Levels(new ByMoney(_Symbol, side, userLots, userSLmoney, "SL"));
            //   result  = levelSL.calculateLevel();
            //   break;
            // case PipsFromOpenCandle:
            //   levelSL = new Levels(new ByPipsFromCandle(_Symbol, side, userSLpips, "SL", 0, 1));
            //   result  = levelSL.calculateLevel();
        }
    return result;
}

// NOTE: TP
double TP(string side, double price = 0, double price_sl = 0, double lot = 0)
{
    // int dir, string sym, double lot, double slprice
    int dir = side == "sell" ? 2 : 1;
    return calcTP(dir, _Symbol, lot, price_sl);

    double result = 0;
    double pips   = 0;
    if (takeProfitOn)
        switch (modeTP) {
        case TP_ByRatioRR:
            if (SL(side) == 0)
                break;
            pips   = side == "buy" ? fabs(Ask - SL(side)) * uRatioTP : fabs(Bid - SL(side)) * uRatioTP;
            result = side == "buy" ? NormalizeDouble(Ask + pips, _Digits) : NormalizeDouble(Bid - pips, _Digits);
            break;
        case FixPips:
            levelTP = new Levels(new ByFixPips(_Symbol, side, userTPpips, "TP", price));
            result  = levelTP.calculateLevel();
            break;
        case byMoney:
            levelTP = new Levels(new ByMoney(_Symbol, side, userLots, userTPmoney, "TP"));
            result  = levelTP.calculateLevel();
            break;
        case PipsFromOpenCandle:
            levelSL = new Levels(new ByPipsFromCandle(_Symbol, side, userSLpips, "TP", 0, 1));
            result  = levelSL.calculateLevel();
        }
    return result;
}
double Lots()
{
    lotProvider = new LotCalculator();
    double lots = -1;
    switch (modeCalcLots) {
    case Money:
        lots = lotProvider.LotsByMoney(userMoney, levelSL.pips());
        break;

    case AccountPercent:
        lots = lotProvider.LotsByBalancePercent(userBalancePer, levelSL.pips());
        break;

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

int Distancia(double precioA, double precioB, string par, string mode = "pips")
{
    double mPoint = MarketInfo(par, MODE_POINT);
    double dist   = fabs(precioA - precioB);
    if (mode == "points")
        return (int)(dist / mPoint);
    if (mode == "pips")
        return (int)((dist / mPoint) / 10);
    return 0;
}

double floatingEA()
{
    double profit = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
            profit += OrderProfit();
        }
    }

    return profit;
}

double openVolume()
{
    double volume = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
            volume += OrderLots();
        }
    }

    return volume;
}

void CheckearOrdernesyGenerarGrids()
{
    if (mainOrders.qnt() == 1) {
        if (mainOrders.last().type() == OP_BUY && CheckPointer(gridBuy) == POINTER_INVALID) {
            gridBuy = new Grid(_Symbol, "buy", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
        }
        if (mainOrders.last().type() == OP_SELL && CheckPointer(gridSell) == POINTER_INVALID) {
            gridSell = new Grid(_Symbol, "sell", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
        }
    }
    if (mainOrders.qnt() == 0) {
        deleteGrid();
    }
}

void deleteGrid()
{
    if (CheckPointer(gridSell) != POINTER_INVALID) {
        delete gridSell;
    }
    if (CheckPointer(gridBuy) != POINTER_INVALID) {
        delete gridBuy;
    }
}

// clang-format off
bool CloseAllControl()
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
      case CloseByPips: 
      {
         double moneyLimitWin = openVolume()*closeByPipsWin*10;
         double moneyLimitLoss = -openVolume()*closeByPipsLoss*10;
         if (floatingEA() >=moneyLimitWin) {return true; }
         if (floatingEA() < moneyLimitLoss) { return true; }
         break;
      }
   }
	return false;
}
// clang-format on

void closeAll(string side = "")
{
    if (side == "buy" || side == "") {
        actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
        actionCloseBuys.doAction();
        if (GridON && CheckPointer(gridBuy) != POINTER_INVALID) {
            gridBuy.closeGrid();
            delete gridBuy;
        }
        delete actionCloseBuys;

        if (uDeletePendingsOn) {
            actionDeletePendingsBuys = new ActionDeletePendings("buy", magico);
            actionDeletePendingsBuys.doAction();
            delete actionDeletePendingsBuys;
        }
    }
    if (side == "sell" || side == "") {
        actionCloseSells = new ActionCloseOrdersByType("sell", magico);
        actionCloseSells.doAction();
        if (GridON && CheckPointer(gridSell) != POINTER_INVALID) {
            gridSell.closeGrid();
            delete gridSell;
        }

        if (uDeletePendingsOn) {
            actionDeletePendingsSells = new ActionDeletePendings("sell", magico);
            actionDeletePendingsSells.doAction();
            delete actionDeletePendingsSells;
        }

        delete actionCloseSells;
    }
}

void doBreackevenAction()
{
    for (int i = mainOrders.qnt() - 1; i >= 0; i--) {
        if (!mainOrders.index(i).breakevenWasDoIt()) {
            breackevenCondition.setOrder(mainOrders.index(i));
            if (conditionsToBreackeven.EvaluateConditions()) {
                breackevenAction = new MoveSL();

                double buySl  = mainOrders.index(i).price() + userBkvStep * 10 * Point;
                double sellSl = mainOrders.index(i).price() - userBkvStep * 10 * Point;
                double newSl  = mainOrders.index(i).type() == OP_BUY ? buySl : sellSl;
                breackevenAction.order(mainOrders.index(i)).newSL(newSl);
                breackevenAction.doAction();
                delete breackevenAction;
            }
        }
    }
}

void doPartialCloseAction()
{
    for (int i = mainOrders.qnt() - 1; i >= 0; i--) {
        if (mainOrders.index(i).countPartials() < uQntPartials) {
            partialCloseCondition.setOrder(mainOrders.index(i));
            if (conditionsToPartialClose.EvaluateConditions()) {
                partialCloseAction = new PartialClose();
                partialCloseAction.order(mainOrders.index(i)).percent(userPartialClosePercent);
                partialCloseAction.doAction();
                delete partialCloseAction;
            }
        }
    }
}

// clang-format off
void doCloseGridControl()
{   
   if(closeGridTP>0)
   {
      if(CheckPointer(gridBuy) != POINTER_INVALID)
      if(gridBuy.profit() >= closeGridTP) {gridBuy.closeGrid(); delete gridBuy; }
      if(CheckPointer(gridSell) != POINTER_INVALID)
      if(gridSell.profit() >= closeGridTP) {gridSell.closeGrid(); delete gridSell; }
   }

   if(closeGridSL<0)
   {
      if(CheckPointer(gridBuy) != POINTER_INVALID)
      if(gridBuy.profit() <= closeGridSL) {gridBuy.closeGrid(); delete gridBuy; }
      if(CheckPointer(gridSell) != POINTER_INVALID)
      if(gridSell.profit() <= closeGridSL) {gridSell.closeGrid(); delete gridSell; }
   }
}
// clang-format on

#ifdef SPREAD_FILTER
bool spreadFilter()
{
    // tomar el spread actual
    int spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);

    // comparar ocn max
    return spread < uSpreadMax;
}
#endif

#ifdef NEWS_FILTER
void News_Automatic()
{
    if (News_Fuente == Auto) {
        double CheckNews = 0;
        if (AfterNewsStop > 0) {
            if (TimeCurrent() - LastUpd >= Upd) {
                Comment("News Loading...");
                Print("News Loading...");
                UpdateNews();
                LastUpd = TimeCurrent();
                Comment("");
            }
            WindowRedraw();
            //---Draw a line on the chart news--------------------------------------------
            if (DrawLines) {
                for (int i = 0; i < NomNews; i++) {
                    string Name = StringSubstr(TimeToStr(TimeNewsFunck(i), TIME_MINUTES) + "_" + NewsArr[1][i] + "_" + NewsArr[3][i], 0, 63);
                    if (NewsArr[3][i] != "")
                        if (ObjectFind(Name) == 0)
                            continue;
                    if (StringFind(str1, NewsArr[1][i]) < 0)
                        continue;
                    if (TimeNewsFunck(i) < TimeCurrent() && Next)
                        continue;

                    color clrf = clrNONE;
                    if (Vhigh && StringFind(NewsArr[2][i], "High") >= 0)
                        clrf = highc;
                    if (Vmedium && StringFind(NewsArr[2][i], "Moderate") >= 0)
                        clrf = mediumc;
                    if (Vlow && StringFind(NewsArr[2][i], "Low") >= 0)
                        clrf = lowc;

                    if (clrf == clrNONE)
                        continue;

                    if (NewsArr[3][i] != "") {
                        ObjectCreate(Name, 0, OBJ_VLINE, TimeNewsFunck(i), 0);
                        ObjectSet(Name, OBJPROP_COLOR, clrf);
                        ObjectSet(Name, OBJPROP_STYLE, Style);
                        ObjectSetInteger(0, Name, OBJPROP_BACK, true);
                    }

                    Print(NewsArr[0, i]); // tiene la fecha y hora
                    Print(NewsArr[1, i]); // tiene el Par
                    Print(NewsArr[2, i]); // tiene el Impacto (low med hi)
                    Print(NewsArr[3, i]); // tiene el texto de la noticia
                }
            }
            //---------------event Processing------------------------------------
            int i;
            CheckNews = 0;
            for (i = 0; i < NomNews; i++) {
                int power = 0;
                if (Vhigh && StringFind(NewsArr[2][i], "High") >= 0)
                    power = 1;
                if (Vmedium && StringFind(NewsArr[2][i], "Moderate") >= 0)
                    power = 2;
                if (Vlow && StringFind(NewsArr[2][i], "Low") >= 0)
                    power = 3;
                if (power == 0)
                    continue;
                if (TimeCurrent() + MinBefore * 60 > TimeNewsFunck(i) && TimeCurrent() - MinAfter * 60 < TimeNewsFunck(i) && StringFind(str1, NewsArr[1][i]) >= 0) {
                    CheckNews = 1;
                    break;
                } else
                    CheckNews = 0;
            }
            if (CheckNews == 1 && i != Now && Signal) {
                Alert("In ", (int)(TimeNewsFunck(i) - TimeCurrent()) / 60, " minutes released news ", NewsArr[1][i], "_", NewsArr[3][i]);
                Now = i;
            }
            /***  ***/
        }

        if (CheckNews > 0) {
            /////  We are doing here if we are in the framework of the news
            Comment("News time");

        } else {
            // We are out of scope of the news release (No News)
            // Comment("No news");
        }
    }
}

// ——————————————————————————————————————————————————————————————————

//////////////////////////////////////////////////////////////////////////////////
// Download CBOE page source code in a text variable
// And returns the result
//////////////////////////////////////////////////////////////////////////////////

string ReadCBOE()
{
    string cookie = NULL, headers;
    char   post[], result[];
    string TXT = "";
    int    res;
    //--- to work with the server, you must add the URL "https://www.google.com/finance"
    //--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"):
    string google_url = "http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
    //---
    ResetLastError();
    //--- download html-pages
    int timeout = 5000; //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
    res         = WebRequest("GET", google_url, cookie, NULL, timeout, post, 0, result, headers);
    //--- error checking
    if (res == -1) {
        Print("WebRequest error, err.code  =", GetLastError());
        MessageBox("You must add the address ' " + google_url + "' in the list of allowed URL tab 'Advisors' ", " Error ", MB_ICONINFORMATION);
        //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
    } else {
        //--- successful download
        PrintFormat("File successfully downloaded, the file size in bytes  =%d.", ArraySize(result));
        //--- save the data in the file
        int filehandle = FileOpen("news-log.html", FILE_WRITE | FILE_BIN);
        //--- проверка ошибки
        if (filehandle != INVALID_HANDLE) {
            //---save the contents of the array result [] in file
            FileWriteArray(filehandle, result, 0, ArraySize(result));
            //--- close file
            FileClose(filehandle);

            int filehandle2 = FileOpen("news-log.html", FILE_READ | FILE_BIN);
            TXT             = FileReadString(filehandle2, ArraySize(result));
            FileClose(filehandle2);
        } else {
            Print("Error in FileOpen. Error code =", GetLastError());
        }
    }

    return (TXT);
}
// ——————————————————————————————————————————————————————————————————
datetime TimeNewsFunck(int nomf)
{
    string s    = NewsArr[0][nomf];
    string time = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
    return ((datetime)(StringToTime(time) + offset * 3600));
}
// ——————————————————————————————————————————————————————————————————
void UpdateNews()
{
    string TEXT = ReadCBOE();
    int    sh   = StringFind(TEXT, "pageStartAt>") + 12;
    int    sh2  = StringFind(TEXT, "</tbody>");
    TEXT        = StringSubstr(TEXT, sh, sh2 - sh);

    sh = 0;
    while (!IsStopped()) {
        sh  = StringFind(TEXT, "event_timestamp", sh) + 17;
        sh2 = StringFind(TEXT, "onclick", sh) - 2;
        if (sh < 17 || sh2 < 0)
            break;
        NewsArr[0][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);

        sh  = StringFind(TEXT, "flagCur", sh) + 10;
        sh2 = sh + 3;
        if (sh < 10 || sh2 < 3)
            break;
        NewsArr[1][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
        if (StringFind(str1, NewsArr[1][NomNews]) < 0)
            continue;

        sh  = StringFind(TEXT, "title", sh) + 7;
        sh2 = StringFind(TEXT, "Volatility", sh) - 1;
        if (sh < 7 || sh2 < 0)
            break;
        NewsArr[2][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
        if (StringFind(NewsArr[2][NomNews], "High") >= 0 && !Vhigh)
            continue;
        if (StringFind(NewsArr[2][NomNews], "Moderate") >= 0 && !Vmedium)
            continue;
        if (StringFind(NewsArr[2][NomNews], "Low") >= 0 && !Vlow)
            continue;

        sh      = StringFind(TEXT, "left event", sh) + 12;
        int sh1 = StringFind(TEXT, "Speaks", sh);
        sh2     = StringFind(TEXT, "<", sh);
        if (sh < 12 || sh2 < 0)
            break;
        if (sh1 < 0 || sh1 > sh2)
            NewsArr[3][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
        else

            NomNews++;
        if (NomNews == 300)
            break;
    }
}

bool ControlNewsTime()
{
    if (News_Fuente != Auto) {
        return false;
    }
    bool   TieneNewsProxHora = false;
    string symNews;
    string SymPanel = Symbol();
    int    ahora    = TimeGMT(); // hora actual

    int t = ArrayRange(NewsArr, 1);
    // parte1 = StringSubstr(SymPanel, 0, 3);  // saca la primera parte del simbolo (EUR por ej para EURUSD)
    // parte2 = StringSubstr(SymPanel, 3, 6);  // saca la segunda (USD por ej para EURUSD)

    for (int j = 0; j < t; j++) {
        symNews         = NewsArr[1, j]; // tiene el Par / tomas el par j del array de news
        string s        = NewsArr[0][j];
        string time     = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
        int    NewsHora = ((datetime)(StringToTime(time))); // hora de la noticia guardada en el array de news

        // Si la noticia está dentro del rango de minutos en adelante "Turn_Off_Before"
        if (ahora + Turn_OFF_Before * 60 >= NewsHora && NewsHora > ahora) {
            Comment("||------ EA OFF for futures News ------||");
            return true;
        } else {
            int UltimaNewsPasada = 0;

            // recorre todas las noticias buscando la mayor hora del pasado
            for (int j = 0; j < t; j++) {
                string s        = NewsArr[0][j];
                string time     = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
                int    NewsHora = ((datetime)(StringToTime(time))); // hora de la noticia guardada en el array de news

                if (NewsHora < ahora && NewsHora > UltimaNewsPasada) {
                    UltimaNewsPasada = NewsHora;
                }
            }

            if (UltimaNewsPasada >= ahora - Turn_ON_After * 60) {
                Comment("||------ EA OFF for pass News ------||");
                return true;
            }
        }
    }

    return false;
}

#endif

// ------------------------------------------------------------------
int multi(string sy)
{
    sy == "" ? sy = Symbol() : ;
    if (calcMode == 1) {
        return 1;
    }
    int di = (int)MarketInfo(sy, MODE_DIGITS);
    return (di % 2 == 1 ? 10 : 1);
}
double pip(string sy)
{
    sy == "" ? sy = Symbol() : ;
    double po = MarketInfo(sy, MODE_POINT);
    int    di = (int)MarketInfo(sy, MODE_DIGITS);
    if (calcMode == 1) {
        return po;
    }
    return (di % 2 == 1 ? po * 10 : po);
}

double calcSL(int dir, string sym, double lot)
{
    int    dig     = (int)MarketInfo(sym, MODE_DIGITS);
    double sLevel  = MarketInfo(sym, MODE_STOPLEVEL);
    double poi     = MarketInfo(sym, MODE_POINT);
    double bid     = MarketInfo(sym, MODE_BID);
    double ask     = MarketInfo(sym, MODE_ASK);
    double spread  = MarketInfo(sym, MODE_SPREAD);
    double tickval = MarketInfo(sym, MODE_TICKVALUE);
    double eq      = AccountInfoDouble(ACCOUNT_EQUITY);
    double val     = 0.0;
    int    bar     = 0;
    double aSpread = 0.0;
    if (addSpread) {
        if (dir == 1)
            aSpread = (spread * poi);
        if (dir == 2)
            aSpread = (spread * poi);
    }
    if (SlMode == 1) {
        val = MathMax(((SlVal * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
        val = MathMax(SlMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask - val, dig);
        if (dir == 2)
            return NormalizeDouble(bid + val, dig);
    }
    if (SlMode == 2) {
        val = MathMax((((eq * SlVal * 0.01) * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
        val = MathMax(SlMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask - val, dig);
        if (dir == 2)
            return NormalizeDouble(bid + val, dig);
    }
    if (SlMode == 3) {
        val = MathMax(SlVal * multi(sym), sLevel + spread + slp) * poi;
        val = MathMax(SlMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask - val, dig);
        if (dir == 2)
            return NormalizeDouble(bid + val, dig);
    }
    if (SlMode == 4) {
        val = SlMin * pip(sym);
        if (dir == 1)
            return NormalizeDouble(MathMin(SlVal, ask - val), dig);
        if (dir == 2)
            return NormalizeDouble(MathMax(SlVal, bid + val), dig);
    }
    if (SlMode == 5) {
        val = MathMax(iATR(sym, Period(), (int)SlVal, 1) * SlVal2, (sLevel + spread + slp) * poi);
        val = MathMax(SlMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask - val, dig);
        if (dir == 2)
            return NormalizeDouble(bid + val, dig);
    }
    if (SlMode == 6) {
        if (dir == 1) {
            bar = iLowest(sym, Period(), MODE_LOW, (int)SlVal, 0);
            val = MathMin(ask - MathMax((sLevel + spread + slp) * poi, SlMin * pip(sym)), (iLow(sym, Period(), bar) + aSpread) - SlVal2 * pip(sym) - spread * poi);
            return NormalizeDouble(val, dig);
        }
        if (dir == 2) {
            bar = iHighest(sym, Period(), MODE_HIGH, (int)SlVal, 0);
            val = MathMax(bid + MathMax((sLevel + spread + slp) * poi, SlMin * pip(sym)), (iHigh(sym, Period(), bar) + aSpread) + SlVal2 * pip(sym) + spread * poi);
            return NormalizeDouble(val, dig);
        }
    }
    if (SlMode == 7) {
        val = MathMax((bid * (SlVal / 100)) * pip(sym), sLevel + spread + slp) * poi;
        val = MathMax(SlMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask - val, dig);
        if (dir == 2)
            return NormalizeDouble(bid + val, dig);
    }
    return 0;
}

double calcTP(int dir, string sym, double lot, double slprice)
{
    int    dig     = (int)MarketInfo(sym, MODE_DIGITS);
    double sLevel  = MarketInfo(sym, MODE_STOPLEVEL);
    double poi     = MarketInfo(sym, MODE_POINT);
    double bid     = MarketInfo(sym, MODE_BID);
    double ask     = MarketInfo(sym, MODE_ASK);
    double spread  = MarketInfo(sym, MODE_SPREAD);
    double tickval = MarketInfo(sym, MODE_TICKVALUE);
    double eq      = AccountInfoDouble(ACCOUNT_EQUITY);
    double val     = 0.0;
    double aSpread = 0.0;
    if (addSpread) {
        if (dir == 1)
            aSpread = (spread * poi);
        if (dir == 2)
            aSpread = (spread * poi);
    }
    int bar = 0;
    if (TpMode == 1) {
        val = MathMax(((TpVal * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
        val = MathMax(TpMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask + val, dig);
        if (dir == 2)
            return NormalizeDouble(bid - val, dig);
    }
    if (TpMode == 2) {
        val = MathMax((((eq * TpVal * 0.01) * pip(sym)) / (tickval * Lot)), (sLevel + spread + slp) * poi);
        val = MathMax(TpMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask + val, dig);
        if (dir == 2)
            return NormalizeDouble(bid - val, dig);
    }
    if (TpMode == 3) {
        val = MathMax(TpVal * multi(sym), sLevel + spread + slp) * poi;
        val = MathMax(TpMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask + val, dig);
        if (dir == 2)
            return NormalizeDouble(bid - val, dig);
    }
    if (TpMode == 4) {
        val = TpMin * pip(sym);
        if (dir == 1)
            return NormalizeDouble(TpVal, dig);
        if (dir == 2)
            return NormalizeDouble(TpVal2, dig);
    }
    if (TpMode == 5) {
        val = MathMax(iATR(sym, Period(), (int)TpVal, 1) * TpVal2, (sLevel + spread + slp) * poi);
        val = MathMax(TpMin * pip(sym), val + aSpread);
        if (dir == 1)
            return NormalizeDouble(ask + val, dig);
        if (dir == 2)
            return NormalizeDouble(bid - val, dig);
    }
    if (TpMode == 6) {
        if (dir == 1) {
            bar = iHighest(sym, Period(), MODE_HIGH, (int)TpVal, 0);
            val = MathMax(ask + MathMax((sLevel + spread + slp) * poi, TpMin * pip(sym)), (iHigh(sym, Period(), bar) + aSpread) + TpVal2 * pip(sym) + spread * poi);
            return NormalizeDouble(val, dig);
        }
        if (dir == 2) {
            bar = iLowest(sym, Period(), MODE_LOW, (int)TpVal, 0);
            val = MathMin(bid - MathMax((sLevel + spread + slp) * poi, TpMin * pip(sym)), (iLow(sym, Period(), bar) + aSpread) - TpVal2 * pip(sym) - spread * poi);
            return NormalizeDouble(val, dig);
        }
    }
    if (TpMode == 7) {
        val = MathMax((bid * (TpVal / 100)) * pip(sym), sLevel + spread + slp) * poi;
        val = MathMax(TpMin * pip(sym), val) + aSpread;
        if (dir == 1)
            return NormalizeDouble(ask + val, dig);
        if (dir == 2)
            return NormalizeDouble(bid - val, dig);
    }
    if (TpMode == 100 && slprice > 0.0) {
        if (dir == 1) {
            return NormalizeDouble(ask + (ask - slprice) * TpVal, dig);
        }
        if (dir == 2) {
            return NormalizeDouble(bid - (slprice - bid) * TpVal, dig);
        }
    }
    return 0;
}

double calcLot(int dir, string sym, double priceLotVal)
{
    double tickValue    = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
    double step         = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
    double poi          = MarketInfo(sym, MODE_POINT);
    double ask          = SymbolInfoDouble(sym, SYMBOL_ASK);
    double bid          = SymbolInfoDouble(sym, SYMBOL_BID);
    double minlot       = MarketInfo(sym, MODE_MINLOT);
    double maxlot       = MarketInfo(sym, MODE_MAXLOT);
    double marginReq    = MarketInfo(sym, MODE_MARGINREQUIRED);
    double maxlotMargin = (AccountEquity() / marginReq) * 0.95;
    double final_lot    = minlot;
    double distance = 0.0, risk = 0.0, val = 0.0;
    //
    if (dir == 0) {
        final_lot = priceLotVal;
    }
    if (dir == 1 || dir == 2) {
        if (dir == 1)
            distance = (ask - priceLotVal) / poi;
        if (dir == 2)
            distance = (priceLotVal - bid) / poi;
        if (lotMode == 0) {
            risk      = fabs(Lot);
            final_lot = risk / distance / tickValue;
        }
        if (lotMode == 1) {
            risk      = AccountInfoDouble(ACCOUNT_EQUITY) * Lot / 100;
            final_lot = risk / distance / tickValue;
        }
        if (lotMode == 2) {
            risk      = AccountInfoDouble(ACCOUNT_BALANCE) * Lot / 100;
            final_lot = risk / distance / tickValue;
        }
        if (lotMode == 3) {
            final_lot = Lot;
        }
        if (lotMode == 4) {
            final_lot = Lot / marginReq;
        }
        if (lotMode == 5) {
            final_lot = (AccountInfoDouble(ACCOUNT_EQUITY) * Lot / 100) / marginReq;
        }
    }
    final_lot = MathMin(final_lot, maxLot);
    final_lot = MathMin(final_lot, maxlotMargin);
    final_lot = MathMax(final_lot, minlot);
    final_lot = MathMin(final_lot, maxlot);
    final_lot = MathRound(final_lot / step) * step;
    return final_lot;
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