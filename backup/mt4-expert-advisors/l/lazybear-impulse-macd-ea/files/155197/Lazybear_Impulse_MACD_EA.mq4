// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74827

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

// NOTE: defines
// ——————————————————————————————————————————————————————————————————
#define TIMEFRAME_SELECTOR
// #define NEWS_FILTER_ON
// #define DAILY_LIMITS
// #define PENDING_ENTRYS
// #define SPREAD_FILTER
#define CONTROL_CUSTOM_INDICATOR_FILE
// #define LICENSE_CONTROL_ON
// #define TIMER_FULL  // full setup sessions
#define TIMER_MINI // one session at day
// #define TIMER_OFF   // don't show timer
// #define GRID_ON
#define NOTIFICATIONS_ON
// #define CLOSE_ALL_ON
#define PARTIAL_CLOSE_ON
#define BREAKEVEN_ON
#define TRAILING_STOP_ON
#define MAX_TRADES_AT_SAME_TIME

// ——————————————————————————————————————————————————————————————————
enum ModeLevels {
    FixPips,           // Fix Pips
    byMoney,           // Money
    PipsFromOpenCandle // Pips from Candle
};
enum TSLMode {
    byPips, // By Pips
    byMA    // By Moving Average
};
enum ModeCalcLots {
    FixLots,       // Fix Lots
    EquityPercent, // by Equity Percent
    // Money,           // by Money
    // AccountPercent,  // by Account Percent
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
// ——————————————————————————————————————————————————————————————————

#ifdef TIMEFRAME_SELECTOR
input string          Ttf = "== TimeFrame Setup =="; // ————————————
input ENUM_TIMEFRAMES utf = PERIOD_CURRENT;          // TF:
#endif

#ifdef CONTROL_CUSTOM_INDICATOR_FILE

string file_custom_indicator = "! Impulse Macd (alerts + btn)";
int    yellowHistogram       = 4;
int    grayLine      = 5;
int    redLine               = 6;

input string Tindi = "== Indicator Setup =="; // ————————————

double Macd(int buffer, int candle)
{
    // TODO: copiar la lista de INPUTS para custom indicator:
    return iCustom(NULL, 0, file_custom_indicator, buffer, candle);
}
#endif

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

input string T0 = "== Trade Setup =="; // ————————————
#ifdef MAX_TRADES_AT_SAME_TIME
input int uMaxTrades = 1; // Max Trades At Same Time:
#endif
input bool         uTradeReverse = false;         // Trade Reverse:
input int          magico        = 2022;          // Magic Number:
input string       Tvolumen      = "= Volumen ="; // ————————————
input ModeCalcLots modeCalcLots  = FixLots;       // Mode to Calc Lots:
input double       userLots      = 0.01;          // Fixed Lots:
input double       userEquityPer = 1;             // Setup Lots by "Equity Percent":
// double             userMoney               = 10;                 // Setup Lots by "Money":
// double             userBalancePer          = 0.1;                // Setup Lots by "Account
input string     T01          = "= Take Profit ="; // ————————————
input bool       takeProfitOn = true;              // Take Profit On:
input ModeLevels modeTP       = FixPips;           // Mode Take Profit:
input int        userTPpips   = 20;                // Pips TP
input double     userTPmoney  = 15;                // Money TP
input string     T02          = "= Stop Loss =";   // ————————————
input bool       stopLossOn   = true;              // Stop Loss On:
input ModeLevels modeSL       = FixPips;           // Mode Stop Loss:
input int        userSLpips   = 20;                // Pips SL
input double     userSLmoney  = 15;                // Money SL

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

input string       TtpOposite              = "== Close Opposite ==";    // ————————————
input bool         closeAllInOpositeSignal = false;                     // Close in opposite signal
#ifdef CLOSE_ALL_ON
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
// bool         closeAllInOpositeSignal = false;                     // CLose All In Oposite Signal
#endif

#ifdef PARTIAL_CLOSE_ON
input string Tpc                     = "== Partial Close =="; // ————————————
input bool   partialCloseOn          = false;                 // Partial Close On:
input double userPartialClosePercent = 50;                    // Partial Close Percent:
double userPartialClosePips    = 20;                    // Partial Close Pips:
input int    uQntPartials            = 2;                     // Partials to take:
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
input int    minutesBetwenNotify   = 1;                     // Minutes Betwen Notifications
int          timeNextNotify        = 0;
#else
string TZ                    = "== Notifications =="; // Notifications
bool   notifications         = false;                 // Notifications On
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications
int    minutesBetwenNotify   = 1;                     // Minutes Betwen Notifications
int    timeNextNotify        = 0;
#endif

string             IemaFast             = "== Moving Average Fast Setup ==";   // ————————————
int                maFastPeriod         = 20;                                  // Period
int                maFastShift          = 0;                                   // MA Shift
ENUM_MA_METHOD     maFastMethod         = MODE_EMA;                            // Method
ENUM_APPLIED_PRICE maFastAppliedPrice   = PRICE_CLOSE;                         // Applied Price
string             IemaSlow             = "== Moving Average Slow Setup ==";   // ————————————
int                maSlowPeriod         = 50;                                  // Period
int                maSlowShift          = 0;                                   // MA Shift
ENUM_MA_METHOD     maSlowMethod         = MODE_EMA;                            // Method
ENUM_APPLIED_PRICE maSlowAppliedPrice   = PRICE_CLOSE;                         // Applied Price
string             IemaFilter           = "== Moving Average Filter Setup =="; // ————————————
bool               maFilterOn           = false;                               // MA Filter On ?
int                maFilterPeriod       = 200;                                 // Period
int                maFilterShift        = 0;                                   // MA Shift
ENUM_MA_METHOD     maFilterMethod       = MODE_EMA;                            // Method
ENUM_APPLIED_PRICE maFilterAppliedPrice = PRICE_CLOSE;                         // Applied Price

string TFilters        = "== Filters Orders =="; // ————————————
bool   filterSymbolsOn = true;                   // Symbols filter On:
string SymbolsList     = "GBPUSD,EURUSD";        // Symbols (separate by comma ","):
bool   filterMagicsOn  = true;                   // Use magic number filter?
string MagicsList      = "2022";                 // Magics numbers (separate by comma ","):

#ifdef NEWS_FILTER_ON

input string    TNEWS                 = "== News Setup ==";              // ————————————
input string    note                  = "http://calendar.fxstreet.com/"; // You Must to allow this URL:
input bool      NEWS_FILTER           = true;                            // News Filter On
input bool      NEWS_IMPOTANCE_LOW    = false;                           // Low
input bool      NEWS_IMPOTANCE_MEDIUM = true;                            // Medium
input bool      NEWS_IMPOTANCE_HIGH   = true;                            // High
input int       STOP_BEFORE_NEWS      = 30;                              // Minutes Stop Before News
input int       START_AFTER_NEWS      = 30;                              // Minutes Stop After News
input string    Currencies_Check      = "USD,EUR,CAD,AUD,NZD,GBP";       // Currencys
bool            Check_Specific_News   = false;
string          Specific_News_Text    = "employment";
input bool      DRAW_NEWS_CHART       = true;     // Show Up comming News
int             X                     = 10;       // Chart X-Axis Position
int             Y                     = 280;      // Chart Y-Axis Position
input string    News_Font             = "Arial";  // Font
input color     Font_Color            = clrBlack; // Font Color
input bool      DRAW_NEWS_LINES       = false;    // Draw Lines News
input color     Line_Color            = clrBlack; // Line Color
ENUM_LINE_STYLE Line_Style            = STYLE_DOT;
int             Line_Width            = 1;
int             Font_Size             = 8;
string          LANG                  = "en-US";

datetime date;
int      TIME_CORRECTION, NEWS_ON = 0;

class News
{

  public:
    News() { ; }
    ~News() { ; }

    bool StopForNews()
    {
        if (NEWS_ON == 1) {
            return true;
        }
        return false;
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
            if (NEWS_FILTER == true && READ_NEWS(NEWS_TABLE) && ArraySize(NEWS_TABLE) > 0)
                DRAW_NEWS(NEWS_TABLE);

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

    void OnTimer()
    {
        if (NEWS_FILTER == false)
            return;

        static int waiting = 0;
        if (waiting <= 0) {
            if (!MQLInfoInteger(MQL_TESTER) || !MQLInfoInteger(MQL_OPTIMIZATION)) {
                if (READ_NEWS(NEWS_TABLE))
                    waiting = 100;
                if (ArraySize(NEWS_TABLE) <= 0)
                    return;
                DRAW_NEWS(NEWS_TABLE);
            }
        } else
            waiting--;
        if (ArraySize(NEWS_TABLE) <= 0)
            return;

        datetime time = TimeCurrent();
        //---
        for (int i = 0; i < ArraySize(NEWS_TABLE); i++) {
            datetime news_time        = NEWS_TABLE[i].dTime + TIME_CORRECTION;
            bool     Importance_Check = false;
            if ((!NEWS_IMPOTANCE_LOW && NEWS_TABLE[i].importance == "*") ||
                (!NEWS_IMPOTANCE_MEDIUM && NEWS_TABLE[i].importance == "* *") ||
                (!NEWS_IMPOTANCE_HIGH && NEWS_TABLE[i].importance == "* * *"))
                Importance_Check = true;
            if (Importance_Check || StringFind(Currencies_Check, NEWS_TABLE[i].currency, 0) == -1 || (Check_Specific_News && (StringFind(NEWS_TABLE[i].news, Specific_News_Text) == -1)))
                continue;
            if ((news_time <= time && (news_time + (datetime)(START_AFTER_NEWS * 60)) >= time) ||
                (news_time >= time && (news_time - (datetime)(STOP_BEFORE_NEWS * 60)) <= time)) {
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

    void OnTick()
    {
        OnTimer();
    }

    void DEL_ROW(sNews& l_a_news[], int row)
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

    bool READ_NEWS(sNews& l_NewsTable[])
    {
        string cookie = NULL, referer = NULL, headers;
        char   post[], result[];
        string tmpStr  = "";
        string st_date = TimeToString(TimeCurrent(), TIME_DATE), end_date = TimeToString((TimeCurrent() + (datetime)(7 * 24 * 60 * 60)), TIME_DATE);
        StringReplace(st_date, ".", "");
        StringReplace(end_date, ".", "");
        string url = "http://calendar.fxstreet.com/EventDateWidget/GetMini?culture=" + LANG + "&view=range&start=" + st_date + "&end=" + end_date + "&timezone=UTC" + "&columns=date%2Ctime%2Ccountry%2Ccountrycurrency%2Cevent%2Cconsensus%2Cprevious%2Cvolatility%2Cactual&showcountryname=false&showcurrencyname=true&isfree=true&_=1455009216444";
        ResetLastError();
        WebRequest("GET", url, cookie, referer, 10000, post, sizeof(post), result, headers);
        if (ArraySize(result) <= 0) {
            int er = GetLastError();
            ResetLastError();
            Print("ERROR_TXT IN WebRequest");
            if (er == 4060)
                MessageBox("YOU MUST ADD THE ADDRESS '" + "http://calendar.fxstreet.com/" + "' IN THE LIST OF ALLOWED URL IN THE TAB 'ADVISERS'", "ERROR_TXT", MB_ICONINFORMATION);
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
            if (StringFind(tmpStr, CharToString(tr), 0) > 0)
                continue;
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

    void DRAW_NEWS(sNews& l_a_news[])
    {
        if (DRAW_NEWS_LINES || DRAW_NEWS_CHART) {
            if (NEWS_FILTER == false)
                return;
            for (int i = ArraySize(l_a_news) - 1; i >= 0; i--) {
                StringReplace(l_a_news[i].currency, " ", "");
                int Currency_check_counter = 0;

                datetime t1 = (l_a_news[i].dTime + (datetime)(START_AFTER_NEWS * 60));
                datetime t2 = ((TimeCurrent() - (datetime)TIME_CORRECTION));

                if (StringFind(Currencies_Check, l_a_news[i].currency) == -1 || t1 < t2 || (Check_Specific_News && (StringFind(l_a_news[i].news, Specific_News_Text) == -1))) {
                    DEL_ROW(l_a_news, i);
                    continue;
                }

                if ((!NEWS_IMPOTANCE_LOW && l_a_news[i].importance == "*") ||
                    (!NEWS_IMPOTANCE_MEDIUM && l_a_news[i].importance == "* *") ||
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
                        if (l_a_news[K].currency != "")
                            break;
                    Z = K + 1;

                    NAME = "PANEL_NEWS_N" + (string)l;
                    if (ObjectFind(0, NAME) < 0)
                        OBJECT_LABEL(0, NAME, 0, X + 110, Y - (int)(18 * (l + 5)), CORNER_LEFT_LOWER, ((TimeToString(l_a_news[K].dTime + TIME_CORRECTION, TIME_DATE | TIME_MINUTES) + " " + l_a_news[K].currency + " " + l_a_news[K].importance + " " + l_a_news[K].news)), News_Font, Font_Size, Font_Color, 0, ANCHOR_LEFT_UPPER, false, false, true, 0);
                }
            }
            return;
        }
    }

    void DEINIT_PANEL()
    {
        ObjectsDeleteAll(0);
    }

    bool OBJECT_LABEL(const long              CHART_ID   = 0,
                      const string            NAME       = "",
                      const int               SUB_WINDOW = 0,
                      const int               X_Axis     = 0,
                      const int               Y_Axis     = 0,
                      const ENUM_BASE_CORNER  CORNER     = CORNER_LEFT_UPPER,
                      const string            TEXT       = "",
                      const string            FONT       = "",
                      const int               FONT_SIZE  = 10,
                      const color             CLR        = color("255,0,0"),
                      const double            ANGLE      = 0.0,
                      const ENUM_ANCHOR_POINT ANCHOR     = ANCHOR_LEFT_UPPER,
                      const bool              BACK       = false,
                      const bool              SELECTION  = false,
                      const bool              HIDDEN     = true,
                      const long              ZORDER     = 0,
                      string                  TOOLTIP    = "\n")
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

News* news;
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

// clang-format off
ConditionLicense license(D'2022.03.30');
// clang-format on
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
MovingAverage* maFast;
MovingAverage* maSlow;
MovingAverage* maFilter;

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
   double         profit()           { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit()+OrderCommission()+OrderSwap(); return -1; }
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
        // if (n > 0) {
        //     double originalLots = _order.lot() / (1 - (NormalizeDouble(_percentToClose / 100, 2) * n));
            
        //     double lotToClose = NormalizeDouble((originalLots * _percentToClose / 100), 2);
        //     if(lotToClose > _order.lot()) return _order.lot();

        //     return lotToClose;
        // }
        Print(__FUNCTION__," _order.lot(): ",_order.lot());

        double lotToClose = NormalizeDouble((_order.lot() * _percentToClose / 100), 2);
        if(lotToClose > _order.lot()) return _order.lot();
        return lotToClose;
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

    // NOTE: Equity Lots
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
        if (lot < _min)
            l = _min;
        if (lot > _max)
            l = _max;
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
ConcurrentConditions conditionsToPartialClose;
ConcurrentConditions conditionsToBreackeven;

class BUYcondition1 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition Buy 1
        // return iClose(NULL, 0, 1) < ma.index(1);
        // return Indi(grayLine, 1) > 0;
        // return Indi(grayLine, 1) != EMPTY_VALUE;

        // yellowHistogram 
        // grayLine        
        // redLine         

        return Macd(yellowHistogram, 1) > 0 && Macd(yellowHistogram, 2) < 0;
        
        // return false;
    }
};
BUYcondition1* buyCondition1;
class BUYcondition2 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition Buy 2
        return false;
    }
};
BUYcondition2* buyCondition2;
class BUYcondition3 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition Buy 3
        return false;
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
        // return iClose(NULL, 0, 1) < ma.index(1);
        // return Indi(grayLine, 1) > 0;
        // return Indi(grayLine, 1) != EMPTY_VALUE;

        // yellowHistogram 
        // grayLine        
        // redLine         

        return Macd(yellowHistogram, 1) < 0 && Macd(yellowHistogram, 2) > 0;

        return false;
    }
};
SELLcondition1* sellCondition1;
class SELLcondition2 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition sell 2
        return false;
    }
};
SELLcondition2* sellCondition2;
class SELLcondition3 : public iConditions
{
  public:
    bool evaluate()
    {
        // TODO: condition sell 3

        return false;
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
        if (closeAllInOpositeSignal)
            if (sellCondition1.evaluate())
                return true;

        if (closeAllControlON)
            if (CloseAllControl())
                return true;

#ifdef DAILY_LIMITS
        if (uDailyProfitOn)
            if (dailyProfitCondition.evaluate())
                return true;

        if (uDailyLossOn)
            if (dailyLossCondition.evaluate())
                return true;
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
        if (closeAllInOpositeSignal)
            if (buyCondition1.evaluate())
                return true;

        if (closeAllControlON)
            if (CloseAllControl())
                return true;

#ifdef DAILY_LIMITS
        if (uDailyProfitOn)
            if (dailyProfitCondition.evaluate())
                return true;

        if (uDailyLossOn)
            if (dailyLossCondition.evaluate())
                return true;
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
// PartialCloseCondition* partialCloseCondition;

class PartialCloseLineCross : public iConditions
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
        // clang-format off
        double mPoints = MarketInfo(_order.symbol(), MODE_POINT);
        double ask     = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid     = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

        int    n = _order.countPartials();

        if (_order.type() == OP_BUY) {
            return 
               (Macd(yellowHistogram, 2) > 0 && Macd(grayLine,2) >0 &&
                Macd(yellowHistogram, 2) >      Macd(grayLine,2) &&
                Macd(yellowHistogram, 1) <=     Macd(grayLine,1))                
                ||
                (Macd(yellowHistogram, 2) > 0 && Macd(redLine,2) >0 &&
                Macd(yellowHistogram, 2) >       Macd(redLine,2) &&
                Macd(yellowHistogram, 1) <=      Macd(redLine,1));
        }
        if (_order.type() == OP_SELL) {
            
            return 
               (Macd(yellowHistogram, 3) < 0 && Macd(grayLine,2) <0 &&
                Macd(yellowHistogram, 3) <      Macd(grayLine,2) &&
                Macd(yellowHistogram, 1) >=     Macd(grayLine,1))
                ||
                (Macd(yellowHistogram, 2) < 0 && Macd(redLine,2) <0 &&
                Macd(yellowHistogram, 1) < 0 &&  Macd(redLine,1) <0 &&
                Macd(yellowHistogram, 2) <       Macd(redLine,2) &&
                Macd(yellowHistogram, 1) >=      Macd(redLine,1));
        }

        return false;
    }
    // clang-format on
};
PartialCloseLineCross* partialCloseCondition;

//////////////////////////////////////////////////////////////////////
// NOTE: OnInit
int OnInit()
{

    HideTestIndicators(true);

#ifdef LICENSE_CONTROL_ON
    if (!license.controlByDate()) {
        return INIT_FAILED;
    }
#endif

#ifdef CONTROL_CUSTOM_INDICATOR_FILE
    double temp = iCustom(NULL, 0, file_custom_indicator, 0, 0);
    if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD) {
        string txt = "THIS EA NEED AN INDICATOR\ninstall the file:\n" + file_custom_indicator + "\ninto the folder:\nMQL4/Indicators.";
        MessageBox(txt, "Important Information", MB_ICONINFORMATION);
        Alert(txt);
        return INIT_FAILED;
    }
#endif

#ifdef TIMEFRAME_SELECTOR
    ChartSetSymbolPeriod(0, _Symbol, utf);
#endif

    newCandle = new CNewCandle();
    tsl       = new TrailingStop(GetPointer(mainOrders), byPips);

    //--- CONDITIONS TO OPEN TRADES:
    //--- buys:
    conditionsToBuy.AddCondition(buyCondition1 = new BUYcondition1());
    // conditionsToBuy.AddCondition(buyCondition2 = new BUYcondition2());
    // conditionsToBuy.AddCondition(buyCondition3 = new BUYcondition3());
    // conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1));
    // availableToTakeSignalBuy = new ConditionSignalLimiter("buy");
    // conditionsToBuy.AddCondition(availableToTakeSignalBuy);

    //--- sell:
    conditionsToSell.AddCondition(sellCondition1 = new SELLcondition1());
    // conditionsToSell.AddCondition(sellCondition2 = new SELLcondition2());
    // conditionsToSell.AddCondition(sellCondition3 = new SELLcondition3());
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
    conditionsToPartialClose.AddCondition(partialCloseCondition = new PartialCloseLineCross());

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
    maFast = new MovingAverage();
    maFast.setSetup(maFastPeriod, maFastShift, maFastMethod, maFastAppliedPrice);
    maSlow = new MovingAverage();
    maSlow.setSetup(maSlowPeriod, maSlowShift, maSlowMethod, maSlowAppliedPrice);
    maFilter = new MovingAverage();
    maFilter.setSetup(maFilterPeriod, maFilterShift, maFilterMethod, maFilterAppliedPrice);


#ifdef NEWS_FILTER_ON
    news = new News();
    news.OnInit();
#endif

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

#ifdef NEWS_FILTER_ON
    news.OnDeinit(reason);
#endif

    delete newCandle;
    delete tsl;
}

// NOTE: OnTick
void OnTick()
{
#ifdef NEWS_FILTER_ON
    news.OnTick();
    if (news.StopForNews())
        return;
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

    if (partialCloseOn)
        doPartialCloseAction();
    
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
        // NOTE: SELL normal
        if (conditionsToSell.EvaluateConditions()) {
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

void OnTimer(void)
{
#ifdef NEWS_FILTER
    news.OnTimer();
#endif
}

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
double SL(string side, double price = 0)
{
    double result = 0;
    if (stopLossOn)
        switch (modeSL) {
        case FixPips:
            levelSL = new Levels(new ByFixPips(_Symbol, side, userSLpips, "SL", price));
            result  = levelSL.calculateLevel();
            break;

        case byMoney:
            levelSL = new Levels(new ByMoney(_Symbol, side, userLots, userSLmoney, "SL"));
            result  = levelSL.calculateLevel();
            break;

        case PipsFromOpenCandle:
            levelSL = new Levels(new ByPipsFromCandle(_Symbol, side, userSLpips, "SL", 0, 1));
            result  = levelSL.calculateLevel();
            break;
        }
    return result;
}
double TP(string side, double price = 0)
{
    double result = 0;
    if (takeProfitOn)
        switch (modeTP) {
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
        // case Money:
        //   lots = lotProvider.LotsByMoney(userMoney, levelSL.pips());
        //   break;

        // case AccountPercent:
        //   lots = lotProvider.LotsByBalancePercent(userBalancePer, levelSL.pips());
        //   break;

    case FixLots:
        lots = userLots;
        break;

    case EquityPercent:
        lots = lotProvider.LotsByEquityPercent(userEquityPer);
        break;
    }
    delete lotProvider;
    return lots;
}

void Notifications(int type)
{
    // time Control
    if (timeNextNotify != 0)
        if (TimeCurrent() < timeNextNotify)
            return;
    timeNextNotify = TimeCurrent() + (minutesBetwenNotify * 60);

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