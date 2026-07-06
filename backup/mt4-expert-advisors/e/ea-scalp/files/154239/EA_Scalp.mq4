//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74581

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#define NEWS_FILTER_ON
#define TIMER_MINI // one session at day

enum enumDays { sunday,
                monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                EA_OFF };


#include <stderror.mqh>
#include <stdlib.mqh>

#import "kernel32.dll"
int CreateFileW(string Filename, int AccessMode, int ShareMode, int PassAsZero, int CreationMode, int FlagsAndAttributes, int AlsoPassAsZero);
int GetFileSize(int FileHandle, int PassAsZero);
int SetFilePointer(int FileHandle, int Distance, int& PassAsZero[], int FromPosition);
int ReadFile(int FileHandle, uchar& BufferPtr[], int BufferLength, int& BytesRead[], int PassAsZero);
int CloseHandle(int FileHandle);
#import

string Ordercomment = "";
int    Slippage     = 3;
int    Retries      = 10;
bool   AutoTrade    = true;
bool   ecnBroker    = false;
enum OPBySignal {
    ON  = 0,
    OFF = 1,
};
input OPBySignal OP_BySignal   = OFF;
input int        Jarak_OP      = 50;
input double     LotMultiply   = 1;
input bool       Close_Signal  = false;
input int        MagicID       = 12345678;
int              magico        = MagicID;
input double     LOTS          = 0.01;
input int        risk          = 100; // risk: 0-->fixed lots
input int        Max_OP        = 5;
input double     SL            = 500;
input double     TP            = 150;
extern bool      TPLinier      = true;
extern bool      UseTralling   = false;   // UseTralling
extern double    TrallingStart = 10;      // Ts Start in Pips
extern double    LockProfit    = 5;       // Lock Profit in Pips

bool      UseTimeFilter = false;   // TimeFilter
string    Start         = "00:00"; // Start
string    End1          = "15:00"; // Stop

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool jamOP()
{
    bool Oc = false;
    if (UseTimeFilter) {
        string j1 = TimeToStr(TimeCurrent(), TIME_DATE) + " " + Start;
        string j2 = TimeToStr(TimeCurrent(), TIME_DATE) + " " + End1;
        if (TimeCurrent() >= StrToTime(j1) && TimeCurrent() < StrToTime(j2)) {
            return (true);
        }
    } else {
        return (true);
    }
    return (Oc);
}
union Price {
    uchar  buffer[8];
    double close;
};

double data[][2];
int    BytesToRead;
string datapath;
string result;
Price  m_price;
int    StopLoss     = 0;
double SL_BEP_minus = 0;
double g_Point;
int    ticket = 0;
double Buy, lotbuy, lotsbuy, Sell, lotsell, lotssell, SUM, SWAP,
    profitbuy, profitsell, OP, dg,
    sumbuy, sumsell, bepbuy, bepsell, lowlotbuy, lowlotsell, hisell,
    lobuy;

// datetime expDate=D'2029.10.12 02:00';//yyyy.mm.dd
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

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

#ifdef TIMER_MINI
input string T1        = "== Trading Sessions =="; // ————————————
input string timeStart = "00:00:00";               // Time Start GMT
input string timeEnd   = "23:59:59";               // Time End GMT

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
#endif

#define DAILY_LIMITS
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

interface iConditions
{
    bool evaluate();
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

DailyProfitCondition dailyProfitCondition(uDayLimitProfit, magico, uConsiderFloatting, "profit", limitProfitMode);
DailyProfitCondition dailyLossCondition(uDayLimitLoss, magico, uConsiderFloatting, "loss", limitLossMode);

#endif

int OnInit()
{
    if (!IsDllsAllowed()) {
        Alert("Make Sure DLL Import is Allowed");
        ExpertRemove();
        return (INIT_FAILED);
    }
    /// if(TimeCurrent()>expDate)
    {
        ///
        // ExpertRemove();
        /// return(INIT_FAILED);
    }

#ifdef NEWS_FILTER_ON
    news = new News();
    news.OnInit();
#endif
#ifdef TIMER_MINI
    sesionControl.AddSession(timeStart, timeEnd);
#endif
    //------------------------------------------------------
    {
        //---
        g_Point = Point;
        if (Digits == 5 || Digits == 3) {
            g_Point *= 10;
            Slippage *= 10;
        }
        ChartSetInteger(0, 17, 0, 0);
        ChartSetInteger(0, 0, 1);
        string account_server = AccountInfoString(3);
        if (account_server == "") {
            account_server = "default";
        }
        datapath = TerminalInfoString(3) + "\\history\\" + account_server + "\\" + Symbol() + "240" + ".hst";
        ReadFileHst(datapath);
        //---
        return (INIT_SUCCEEDED);
    }
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
#ifdef NEWS_FILTER_ON
    news.OnDeinit(reason);
#endif

    ObjectDelete("L01");
    ObjectDelete("L02");
    ObjectDelete("L03");
    ObjectDelete("L04");
    ObjectDelete("L05");
    ObjectDelete("L06");
    ObjectDelete("L07");
    ObjectDelete("L08");
    ObjectDelete("L09");
    ObjectDelete("L10");
    ObjectDelete("L11");
    ObjectDelete("L12");
    ObjectDelete("L13");
    ObjectDelete("L14");
    ObjectDelete("L15");
    ObjectDelete("L16");
    ObjectDelete("L17");
    ObjectDelete("L18");
    ObjectDelete("L19");
    ObjectDelete("L20");
    ObjectDelete("L21");
    ObjectDelete("L22");
    ObjectDelete("L23");
    ObjectDelete("L24");
    ObjectDelete("L25");
    ObjectDelete("L26");
    ObjectDelete("L27");
    ObjectDelete("L28");
    ObjectDelete("L29");
    ObjectDelete("L30");
    ObjectDelete("L31");
    ObjectDelete("L32");
    ObjectDelete("L33");
    ObjectDelete("L34");
    ObjectDelete("L35");
    ObjectDelete("L36");
    ObjectDelete("L37");
    ObjectDelete("L38");
    ObjectDelete("L39");
    ObjectDelete("L40");
    ObjectDelete("L41");
    ObjectDelete("L42");
    ObjectDelete("L43");
    ObjectDelete("L44");
    ObjectDelete("L45");
    ObjectDelete("L46");
    ObjectDelete("L47");
    ObjectDelete("L48");
    ObjectDelete("L49");
    ObjectDelete("L50");
    ObjectDelete("L51");
    ObjectDelete("L52");
    ObjectDelete("L53");
    ObjectDelete("L54");
    ObjectDelete("L55");
    ObjectDelete("L56");
    ObjectDelete("L57");
    ObjectDelete("L58");
    ObjectDelete("L59");
    ObjectDelete("L60");
    ObjectDelete("L61");
    ObjectDelete("L62");
    ObjectDelete("L63");
    //--------------------------
    ObjectDelete("Average_Price_Line_Bep");
    ObjectDelete("Average_Price_Line_Buy");
    ObjectDelete("Average_Price_Line_Sell");
    ObjectDelete("Information_");
    ObjectDelete("Average_Price_Buy");
    ObjectDelete("Average_Price_Sell");
    ObjectDelete("MENU");
    ObjectDelete("MENU1");
    ObjectsDeleteAll();
    ObjectsDeleteAll();
    ObjectsDeleteAll();
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

    //------------------AKTIVASI DAN EXPIRE-------------------------

    // Lock Account by number

    // if(AccountInfoInteger(ACCOUNT_LOGIN)!= 9128374)
    //{
    //       Alert("Maaf,Akun anda tidak sesuai...!!!!");
    //       Alert("Silahkan hub Telegram @Pencariadena!!!!");

    // return;
    //    }

    // Lock Account by Nama

    // if(AccountInfoInteger(ACCOUNT_NAME)!= 9128374)
    //{
    //       Alert("Sorry,This EA not belong to you!!!!");
    //     Alert("please contact Telegram @Pencariadena!!!!");

    // return;
    //   }

    // BATAS WAKTU EXPIRE
    if (TimeCurrent() >= StringToTime("2025.10.6")) {
        Alert("EA Expired Contact Telegram @PencariAdena.....!!!!");
        return;
    }

    //----------------------------Tampilan EA-----------------------------------------------//

    // clang-format off
    ObjectCreate(0, "MENU", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "MENU", OBJPROP_XSIZE, 275);
    ObjectSetInteger(0, "MENU", OBJPROP_YSIZE, 325);
    ObjectSetInteger(0, "MENU", OBJPROP_COLOR, Silver);
    ObjectSetInteger(0, "MENU", OBJPROP_XDISTANCE, 100);
    ObjectSetInteger(0, "MENU", OBJPROP_YDISTANCE, 10);
    ObjectSetInteger(0, "MENU", OBJPROP_BGCOLOR, C'40,40,40');
    ObjectSetInteger(0, "MENU", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, "MENU", OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, "MENU", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, "MENU", OBJPROP_BACK, False);
    // clang-format on

    // Close All
    ObjectCreate(0, "CL", OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, "CL", OBJPROP_XSIZE, 225);
    ObjectSetInteger(0, "CL", OBJPROP_YSIZE, 25);
    ObjectSetInteger(0, "CL", OBJPROP_BORDER_COLOR, Silver);
    ObjectSetInteger(0, "CL", OBJPROP_XDISTANCE, 123);
    ObjectSetInteger(0, "CL", OBJPROP_YDISTANCE, 300);
    ObjectSetString(0, "CL", OBJPROP_TEXT, "Close ALL");
    ObjectSetInteger(0, "CL", OBJPROP_BGCOLOR, Blue);
    ObjectSetString(0, "CL", OBJPROP_FONT, "Arial Black");
    ObjectSetInteger(0, "CL", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, "CL", OBJPROP_COLOR, White);

    Display_Info();

    double SetPoint = g_Point;
    if (UseTralling && TrallingStart > 0 && LockProfit < TrallingStart) {
        double rtb = rata_price(0), tr = 0;
        for (int iTrade = 0; iTrade < OrdersTotal(); iTrade++) {
            xx = OrderSelect(iTrade, SELECT_BY_POS, MODE_TRADES);
            if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
                if (TPLinier) {
                    tr = rtb;
                } else {
                    tr = OrderOpenPrice();
                }
                if (Bid - tr > TrallingStart * SetPoint) {
                    if (Bid - ((TrallingStart - LockProfit) * SetPoint) > OrderStopLoss()) {
                        xx = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - ((TrallingStart - LockProfit) * SetPoint), OrderTakeProfit(), 0, Green);
                    }
                }
            }
        }

        double rts = rata_price(1);
        for (int iTrade2 = 0; iTrade2 < OrdersTotal(); iTrade2++) {
            xx = OrderSelect(iTrade2, SELECT_BY_POS, MODE_TRADES);
            if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
                if (TPLinier) {
                    tr = rts;
                } else {
                    tr = OrderOpenPrice();
                }
                if (tr - Ask > TrallingStart * SetPoint) {
                    if (Ask + ((TrallingStart - LockProfit) * SetPoint) < OrderStopLoss() || OrderStopLoss() == 0) {
                        xx = OrderModify(OrderTicket(), OrderOpenPrice(), Ask + ((TrallingStart - LockProfit) * SetPoint), OrderTakeProfit(), 0, Gold);
                    }
                }
            }
        }
    }
    static datetime previousBar;
    if (previousBar != Time[0]) {
        previousBar = Time[0];
        ChartRedraw();
    } else {
        return;
    }

    if (iVolume(Symbol(), PERIOD_H4, 0) > iVolume(Symbol(), PERIOD_H4, 1))
        return;
    //**********************************

    if (!BytesToRead > 0)
        return;

    int pos = -1;
    for (int i = 0; i < BytesToRead - 1; i++) {
        if (!(data[i][0] < Time[0]))
            break;
        pos = i + 1;
    }

    //********************************
    HideTestIndicators(true);
    double wpr = iWPR(Symbol(), 0, 4, 0);
    double ao  = iAO(Symbol(), 0, 0);
    HideTestIndicators(false);

    double level = NormalizeDouble(data[pos][1], Digits);
    ObjectDelete("level");
    MakeLine(level);

    if (data[pos][1] > Open[0])
        Comment("BUY - ", data[pos][1]);
    if (data[pos][1] < Open[0])
        Comment("SELL - ", data[pos][1]);

    if (MarketInfo(Symbol(), MODE_SPREAD) > 150)
        return;

    int TB = 0, TS = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        xx = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicID) {
            continue;
        }
        if (OrderType() == 0) {
            TB++;
        }
        if (OrderType() == 1) {
            TS++;
        }
    }

#ifdef NEWS_FILTER_ON

    news.OnTick();
    if (news.StopForNews())
        return;

#endif

#ifdef TIMER_MINI

    if (!sesionControl.doSessionControl()) {
        return;
    }

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

    if (pos > 0) {

        if (CheckMarketBuyOrders() < 70 && CheckMarketSellOrders() < 70) {
            if (data[pos][1] > Open[0] && OP_BySignal == OFF)
                if (IsBuyPinbar() && TB < Max_OP && (jamOP() || TB > 0)) {
                    double BuySL = NormalizeDouble(Ask - SL * g_Point, Digits);
                    double BuyTP = NormalizeDouble(Ask + TP * g_Point, Digits);
                    if (AccountFreeMarginCheck(Symbol(), OP_BUY, GetLots()) > 0) {
                        ticket = OrderSend(Symbol(), OP_BUY, GetLots(), Ask, Slippage, BuySL, BuyTP, "", MagicID, 0, clrGreen);
                        if (TPLinier) {
                            ModifyTP(0, rata_price(0) + TP * g_Point);
                        }
                        CloseSell();
                    }
                }
            if (data[pos][1] < Open[0] && OP_BySignal == OFF)

                if (IsSellPinbar() && TS < Max_OP && (jamOP() || TS > 0)) {
                    double SellSL = NormalizeDouble(Bid + SL * g_Point, Digits);
                    double SellTP = NormalizeDouble(Bid - TP * g_Point, Digits);
                    if (AccountFreeMarginCheck(Symbol(), OP_SELL, GetLots()) > 0) {
                        ticket = OrderSend(Symbol(), OP_SELL, GetLots(), Bid, Slippage, SellSL, SellTP, "", MagicID, 0, clrGreen);
                        if (TPLinier) {
                            ModifyTP(1, rata_price(1) - TP * g_Point);
                        }

                        CloseBuy();
                    }
                }
        }
    }
    //----------------------OP----By Signal-----------------------------------------------------------------
    if (CountTrades() == 0) {
        if (data[pos][1] > Open[0] && OP_BySignal == ON) {
            if (IsBuyPinbar() && CountTrades() < Max_OP) {
                ticket     = OrderSend(Symbol(), OP_BUY, GetLots(), Ask, 10, 0, 0, "", MagicID, clrGreen);
                bool OPbuy = false;
                OPbuy      = OrderModify(ticket, OrderOpenPrice(), Ask - SL * g_Point, Ask + (TP * g_Point), 0, clrGreen);
            }
        }
    }

    if (CountTrades() == 0) {
        if (data[pos][1] < Open[0] && OP_BySignal == ON) {
            if (IsSellPinbar() && CountTrades() < Max_OP) {
                ticket      = OrderSend(Symbol(), OP_SELL, GetLots(), Bid, 10, 0, 0, "", MagicID, clrRed);
                bool OPSell = false;
                OPSell      = OrderModify(ticket, OrderOpenPrice(), Bid + SL * g_Point, Bid - (TP * g_Point), 0, clrRed);
            }
        }
    }

    if (Close_Signal == true) {
        if (data[pos][1] > Open[0] && OP_BySignal == ON) {
            if (IsBuyPinbar() && Sell > 0) {
                CloseSell();
            }
        }

        if (data[pos][1] < Open[0] && OP_BySignal == ON) {
            if (IsSellPinbar() && Buy > 0) {
                CloseBuy();
            }
        }
    }

    //------------------------------Averaging Signal--------------------------------------------
    if (OP_BySignal == ON && CountTradesBuy() >= 1 && CountTradesBuy() < Max_OP && TPLinier == false) {
        myAvg();
    }

    if (OP_BySignal == ON && CountTradesSell() >= 1 && CountTradesSell() < Max_OP && TPLinier == False) {
        myAvg();
    }
    //-------------------------------------------------------------------------------------------
    if (OP_BySignal == ON && CountTradesBuy() >= 1 && CountTradesBuy() < Max_OP && TPLinier == True) {
        myAvg1();
    }

    if (OP_BySignal == ON && CountTradesSell() >= 1 && CountTradesSell() < Max_OP && TPLinier == True) {
        myAvg1();
    }
    //-------------------------------------------------------------------------------------------
    return;
}
int xx = 0;
//+------------------------------------------------------------------+
int CountTrades()
{
    int count = 0;
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
        int resulttrade = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicID)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
                count++;
            }
        }
    }
    return (count);
}

int CountTradesBuy()
{
    int count = 0;
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
        int resulttradebuy = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicID)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
            if (OrderType() == OP_BUY) {
                count++;
            }
        }
    }
    return (count);
}
//----+
int CountTradesSell()
{
    int count = 0;
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
        int resulttradesell = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicID)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
            if (OrderType() == OP_SELL) {
                count++;
            }
        }
    }
    return (count);
}
//------------------------------------------------------------------------
void myAvg()
{
    int    iCount     = 0;
    double LastOP     = 0;
    double LastLots   = 0;
    bool   LastIsBuy  = false;
    int    iTotalBuy  = 0;
    int    iTotalSell = 0;

    double Spread = 0.0;
    Spread        = MarketInfo(Symbol(), MODE_SPREAD);

    int pos = -1;
    for (int i = 0; i < BytesToRead - 1; i++) {
        if (!(data[i][0] < Time[0]))
            break;
        pos = i + 1;
    }

    for (iCount = 0; iCount < OrdersTotal(); iCount++) {
        bool iCount2 = false;
        iCount2      = OrderSelect(iCount, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
            if (LastOP == 0) {
                LastOP = OrderOpenPrice();
            }
            if (LastOP > OrderOpenPrice()) {
                LastOP = OrderOpenPrice();
            }
            if (LastLots < OrderLots()) {
                LastLots = OrderLots();
            }
            LastIsBuy = true;
            iTotalBuy++;
        }

        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
            if (LastOP == 0) {
                LastOP = OrderOpenPrice();
            }
            if (LastOP < OrderOpenPrice()) {
                LastOP = OrderOpenPrice();
            }
            if (LastLots < OrderLots()) {
                LastLots = OrderLots();
            }
            LastIsBuy = false;
            iTotalSell++;
        }
    }

    /* Jika arah Price adalah DOWNTREND...., Periksa nilai Bid (*/
    if (LastIsBuy) {
        if (data[pos][1] > Open[0]) {
            if (IsBuyPinbar() && Bid <= LastOP - (Jarak_OP * Point)) {
                ticket    = OrderSend(Symbol(), OP_BUY, NormalizeDouble((LastLots * LotMultiply), 2), Ask, Slippage, 0, 0, "", MagicID, 0, clrGreen);
                bool LiB2 = false;
                LiB2      = OrderModify(ticket, OrderOpenPrice(), Ask - SL * g_Point, Ask + (TP * g_Point), 0, clrGreen);
                LastIsBuy = false;
                return;
            }
        }
    }
    /* Jika arah Price adalah Sell...., Periksa nilai Ask (*/
    else if (!LastIsBuy) {
        if (data[pos][1] < Open[0]) {
            if (IsSellPinbar() && Ask >= LastOP + (Jarak_OP * Point)) {
                ticket   = OrderSend(Symbol(), OP_SELL, NormalizeDouble((LastLots * LotMultiply), 2), Bid, Slippage, 0, 0, "", MagicID, 0, clrRed);
                bool LiB = false;
                LiB      = OrderModify(ticket, OrderOpenPrice(), Bid + SL * g_Point, Bid - (TP * g_Point), 0, clrRed);
                return;
            }
        }
    }
}
//----------------------------------------------------------------------------------------------
void myAvg1()
{
    int    iCount     = 0;
    double LastOP     = 0;
    double LastLots   = 0;
    bool   LastIsBuy  = false;
    int    iTotalBuy  = 0;
    int    iTotalSell = 0;

    double Spread = 0.0;
    Spread        = MarketInfo(Symbol(), MODE_SPREAD);

    int pos = -1;
    for (int i = 0; i < BytesToRead - 1; i++) {
        if (!(data[i][0] < Time[0]))
            break;
        pos = i + 1;
    }

    for (iCount = 0; iCount < OrdersTotal(); iCount++) {
        bool iCount1 = false;
        iCount1      = OrderSelect(iCount, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
            if (LastOP == 0) {
                LastOP = OrderOpenPrice();
            }
            if (LastOP > OrderOpenPrice()) {
                LastOP = OrderOpenPrice();
            }
            if (LastLots < OrderLots()) {
                LastLots = OrderLots();
            }
            LastIsBuy = true;
            iTotalBuy++;
        }

        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID) {
            if (LastOP == 0) {
                LastOP = OrderOpenPrice();
            }
            if (LastOP < OrderOpenPrice()) {
                LastOP = OrderOpenPrice();
            }
            if (LastLots < OrderLots()) {
                LastLots = OrderLots();
            }
            LastIsBuy = false;
            iTotalSell++;
        }
    }

    /* Jika arah Price adalah DOWNTREND...., Periksa nilai Bid (*/
    if (LastIsBuy) {
        if (data[pos][1] > Open[0]) {
            if (IsBuyPinbar() && Bid <= LastOP - (Jarak_OP * Point)) {
                ticket = OrderSend(Symbol(), OP_BUY, NormalizeDouble((LastLots * LotMultiply), 2), Ask, Slippage, 0, 0, "", MagicID, 0, clrGreen);
                hitung();
                tpsl();
                LastIsBuy = false;
                return;
            }
        }
    }
    /* Jika arah Price adalah Sell...., Periksa nilai Ask (*/
    else if (!LastIsBuy) {
        if (data[pos][1] < Open[0]) {
            if (IsSellPinbar() && Ask >= LastOP + (Jarak_OP * Point)) {
                ticket = OrderSend(Symbol(), OP_SELL, NormalizeDouble((LastLots * LotMultiply), 2), Bid, Slippage, 0, 0, "", MagicID, 0, clrRed);
                hitung();
                tpsl();
                return;
            }
        }
    }
}
//----------------------------------------------------------------------------------------------
void hitung()
{
    Buy        = 0;
    lotbuy     = 0;
    lotsbuy    = 0;
    Sell       = 0;
    lotsell    = 0;
    lotssell   = 0;
    SUM        = 0;
    SWAP       = 0;
    profitbuy  = 0;
    profitsell = 0;
    sumbuy     = 0;
    sumsell    = 0;
    bepbuy     = 0;
    bepsell    = 0;
    lowlotbuy  = 9999;
    lowlotsell = 9999;
    hisell     = 0;
    lobuy      = 999999999;

    for (int i = 0; i < OrdersTotal(); i++) {
        bool hitung1 = false;
        hitung1      = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol()) {
            continue;
        }

        if (OrderType() == OP_BUY) {
            Buy++;
            OP++;
            lotbuy = OrderLots();
            profitbuy += OrderProfit();
            lotsbuy += OrderLots();
            lowlotbuy = MathMin(lowlotbuy, OrderLots());
            sumbuy += OrderLots() * OrderOpenPrice();
            lobuy = MathMin(lobuy, OrderOpenPrice());
        }
        // sell
        if (OrderType() == OP_SELL) {
            Sell++;
            OP++;
            lotsell = OrderLots();
            profitsell += OrderProfit();
            lotssell += OrderLots();
            lowlotsell = MathMin(lowlotsell, OrderLots());
            sumsell += OrderLots() * OrderOpenPrice();
            hisell = MathMax(hisell, OrderOpenPrice());
        }
    }

    if (lotsbuy > 0) {
        bepbuy = sumbuy / lotsbuy;
    }
    if (lotssell > 0) {
        bepsell = sumsell / lotssell;
    }
} // end hitung

double ND(double p)
{
    return (NormalizeDouble(p, Digits));
}

void tpsl()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        bool TPSL1 = false;
        TPSL1      = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol()) {
            continue;
        }

        if (OrderType() == OP_BUY) {
            double oTPB = (bepbuy + TP * Point) * (TP > 0);
            double oSLB = OrderStopLoss();
            if (SL_BEP_minus > 0)
                oSLB = (bepbuy - SL_BEP_minus * Point);
            if (Buy == 1) {
                oTPB = ND(OrderOpenPrice() + TP * Point) * (TP > 0);
                if (StopLoss > 0)
                    oSLB = (OrderOpenPrice() - StopLoss * Point);
            }
            oTPB = ND(oTPB);
            oSLB = ND(oSLB);
            
            bool BEPSL;
            if (Bid >= oTPB && oTPB > 0)
                BEPSL = false;
            BEPSL = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, CLR_NONE);
            
            bool OPbuyTPSL;
            if (Bid <= oSLB)
                OPbuyTPSL = false;
            OPbuyTPSL = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, CLR_NONE);

            if (ND(OrderTakeProfit()) != oTPB || ND(OrderStopLoss()) != oSLB) {
                if (!OrderModify(OrderTicket(), OrderOpenPrice(), oSLB, oTPB, OrderExpiration())) {
                    Print(OrderTicket() + " MODIFY TP  @ " + DoubleToStr(oTPB, Digits) + " SL @ " + DoubleToStr(oSLB, Digits) + " ");
                }
            }
            {
                Print("OrderSend() error - ", ErrorDescription(GetLastError()));
            }
        }

        if (OrderType() == OP_SELL) {
            double oTPS = (bepsell - TP * Point) * (TP > 0);
            double oSLS = OrderStopLoss();
            if (SL_BEP_minus > 0)
                oSLS = (bepsell + SL_BEP_minus * Point);
            if (Sell == 1) {
                oTPS = (OrderOpenPrice() - TP * Point) * (TP > 0);
                if (StopLoss > 0)
                    oSLS = (OrderOpenPrice() + StopLoss * Point);
            }
            oTPS = ND(oTPS);
            oSLS = ND(oSLS);
            
            bool BTPSL;
            if (Ask <= oTPS)
                BTPSL = false;
            BTPSL = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, CLR_NONE);
            
            bool OPsellTPSL;
            if (Ask >= oSLS && oSLS > 0)
                OPsellTPSL = false;
            OPsellTPSL = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, CLR_NONE);

            if (ND(OrderTakeProfit()) != oTPS || ND(OrderStopLoss()) != oSLS) {
                if (!OrderModify(OrderTicket(), OrderOpenPrice(), oSLS, oTPS, OrderExpiration())) {
                    Print(OrderTicket() + "MODIFY TP  @ " + DoubleToStr(oTPS, Digits) + " SL @ " + DoubleToStr(oSLS, Digits) + " ");
                }
            }
            {
                Print("OrderSend() error - ", ErrorDescription(GetLastError()));
            }
        }
    }
}

//-----------------------------------------------------------------------------------------------

void ReadFileHst(string FileName)
{
    int j = 0;
    ;
    string strFileContents;
    int    Handle;
    int    LogFileSize;
    int    movehigh[1] = {0};
    uchar  buffer[];
    int    nNumberOfBytesToRead;
    int    read[1] = {0};
    int    i;
    double mm;
    //----- -----
    strFileContents = "";
    Handle          = CreateFileW(FileName, (int)0x80000000, 3, 0, 3, 0, 0);
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    if (Handle == -1) {
        Comment("");
        return;
    }
    LogFileSize = GetFileSize(Handle, 0);
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    if (LogFileSize <= 0) {
        return;
    }
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    if ((LogFileSize - 148) / 60 == BytesToRead) {
        return;
    }
    SetFilePointer(Handle, 148, movehigh, 0);
    BytesToRead = (LogFileSize - 148) / 60;
    ArrayResize(data, BytesToRead, 0);
    nNumberOfBytesToRead = 60;
    ArrayResize(buffer, 60, 0);
    for (i = 0; i < BytesToRead; i = i + 1)
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    {
        ReadFile(Handle, buffer, nNumberOfBytesToRead, read, NULL);
        if (read[0] == nNumberOfBytesToRead) {
            result = StringFormat("0x%02x%02x%02x%02x%02x%02x%02x%02x", buffer[7], buffer[6], buffer[5], buffer[4], buffer[3], buffer[2], buffer[1], buffer[0]);

            m_price.buffer[0] = buffer[32];
            m_price.buffer[1] = buffer[33];
            m_price.buffer[2] = buffer[34];
            m_price.buffer[3] = buffer[35];
            m_price.buffer[4] = buffer[36];
            m_price.buffer[5] = buffer[37];
            m_price.buffer[6] = buffer[38];
            m_price.buffer[7] = buffer[39];
            mm                = m_price.close;
            data[j][0]        = StringToDouble(result);
            data[j][1]        = mm;
            j                 = j + 1;
            strFileContents   = TimeToString(StringToTime(result), 3) + " " + DoubleToString(mm, 8);
        } else {
            CloseHandle(Handle);
            return;
        }
    }
    CloseHandle(Handle);
    strFileContents = DoubleToString(data[j - 1][0], 3) + " " + DoubleToString(data[j - 1][1], 8) + " " + DoubleToString(data[j - 2][1], 3) + " " + DoubleToString(data[j - 2][1], 8);
    result          = strFileContents;
}
// ReadFileHst <<==--------   --------
int fnGetLotDigit()
{
    double l_LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    if (l_LotStep == 1)
        return (0);
    if (l_LotStep == 0.1)
        return (1);
    if (l_LotStep == 0.01)
        return (2);
    if (l_LotStep == 0.001)
        return (3);
    if (l_LotStep == 0.0001)
        return (4);
    return (1);
}
//+------------------------------------------------------------------+
int CheckBuyOrders(int magic)
{
    int op = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    {
        int status = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magic)
            continue;
        if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
                op++;
                break;
            }
        }
    }
    return (op);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckSellOrders(int magic)
{
    int op = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    {
        int status = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magic)
            continue;
        if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_SELL) {
                op++;
                break;
            }
        }
    }
    return (op);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckTotalBuyOrders(int magic)
{
    int op = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    {
        int status = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magic)
            continue;
        if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
                op++;
            }
        }
    }
    return (op);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckTotalSellOrders(int magic)
{
    int op = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    {
        int status = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magic)
            continue;
        if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_SELL) {
                op++;
            }
        }
    }
    return (op);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketSellOrders()
{
    int op = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    {
        int status = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != MagicID)
            continue;
        if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_SELL) {
                op++;
            }
        }
    }
    return (op);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketBuyOrders()
{
    int op = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    {
        int status = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != MagicID)
            continue;
        if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
                op++;
            }
        }
    }
    return (op);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MainOrders(int a_cmd_0, double price_24, double price_TP, double price_SL)
{
    color color_8 = Black;
    int   bClosed;
    int   nAttemptsLeft = Retries;
    int   cmd           = 0;

    if (a_cmd_0 == OP_BUY || a_cmd_0 == OP_BUYSTOP)
        cmd = 0;
    if (a_cmd_0 == OP_SELL || a_cmd_0 == OP_SELLSTOP)
        cmd = 1;
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    if (a_cmd_0 == OP_BUYLIMIT || a_cmd_0 == OP_BUY) {
        color_8 = Blue;
    } else {
        //+------------------------------------------------------------------+
        //|                                                                  |
        //+------------------------------------------------------------------+
        if (a_cmd_0 == OP_SELLLIMIT || a_cmd_0 == OP_SELL) {
            color_8 = Red;
        }
    }

    double lots_32 = NormalizeDouble(LOTS, fnGetLotDigit());

    if (lots_32 == 0.0)
        return (false);

    double gd_532 = MarketInfo(Symbol(), MODE_MAXLOT);
    double gd_540 = MarketInfo(Symbol(), MODE_MINLOT);

    if (lots_32 > gd_532)
        lots_32 = gd_532;
    if (lots_32 < gd_540)
        lots_32 = gd_540;

    bClosed = false;
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    while ((bClosed == false) && (nAttemptsLeft >= 0)) {
        nAttemptsLeft--;
        RefreshRates();

        if (!ecnBroker)
            bClosed = OrderSend(Symbol(), a_cmd_0, lots_32, price_24, Slippage, price_SL, price_TP, Ordercomment, MagicID, 0, color_8);
        else
            bClosed = OrderSend(Symbol(), a_cmd_0, lots_32, price_24, Slippage, 0, 0, Ordercomment, MagicID, 0, color_8);

        if (bClosed <= 0) {
            int nErrResult = GetLastError();

            if (a_cmd_0 == 0) {
                Print("FX EA Open New Buy FAILED : Error " + IntegerToString(nErrResult) + " [" + ErrorDescription(nErrResult) + ".]");
                Print(IntegerToString(a_cmd_0) + " " + DoubleToString(lots_32, 2) + " " + DoubleToString(price_24, Digits));
            } else {
                if (a_cmd_0 == 1) {
                    Print("FX EA Open New Sell FAILED : Error " + IntegerToString(nErrResult) + " [" + ErrorDescription(nErrResult) + ".]");
                    Print(IntegerToString(a_cmd_0) + " " + DoubleToString(lots_32, 2) + " " + DoubleToString(price_24, Digits));
                }
            }

            if (nErrResult == ERR_TRADE_CONTEXT_BUSY ||
                nErrResult == ERR_NO_CONNECTION) {
                Sleep(50);
                continue;
            }
        }

        ticket = bClosed;

        bClosed = true;
    }

    return (true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy()
{
    bool clo;
    while (CheckMarketBuyOrders() > 0) {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID)
                    if (OrderType() == OP_BUY)
                        clo = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, clrAqua);
        }
    }
}
//+------------------------------------------------------------------+
void CloseSell()
{
    bool clo;
    while (CheckMarketSellOrders() > 0) {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID)
                    if (OrderType() == OP_SELL)
                        clo = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, clrAqua);
        }
    }
}
//+------------------------------------------------------------------+
double GetLots()
{
    double lot;
    double minlot = MarketInfo(Symbol(), MODE_MINLOT);
    double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
    if (risk != 0) {
        lot = NormalizeDouble(AccountBalance() * risk / 100 / 10000, 2);
        if (lot < minlot)
            lot = minlot;
        if (lot > maxlot)
            lot = maxlot;
    } else
        lot = LOTS;
    return (lot);
}
//+------------------------------------------------------------------+
int signal(int mode)
{
    int res = 0;

    double var1 = 0;
    double var2 = 0;
    double var3 = 0;
    double var4 = 0;
    double var5 = 0;
    double var6 = 0;

    if (Close[2] > Open[2] && Close[1] > Open[1] && Low[2] < Low[1]) {
        if (mode == 2) {
            var5 = Low[2];
            var6 = Low[1];
            if (Open[0] < var6 - (var5 - var6)) {
                var1 = High[0];
            }
            if (Open[2] < Open[1]) {
                var5 = Open[2];
                var6 = Open[1];
            } else {
                var5 = 0.0;
                var6 = 0.0;
            }
            if (Open[0] < var6 - (var5 - var6)) {
                var3 = High[0];
            }
        } else {
            if (mode == 0) {
                if (Open[2] < Open[1]) {
                    var5 = Open[2];
                    var6 = Open[1];
                } else {
                    var5 = 0.0;
                    var6 = 0.0;
                }
            } else {
                var5 = Low[2];
                var6 = Low[1];
            }
            if (Open[0] < var6 - (var5 - var6)) {
                var3 = High[0];
            }
        }
    }
    if (Open[2] > Close[2] && Open[1] > Close[1] && High[2] > High[1]) {
        if (mode == 2) {
            var5 = High[2];
            var6 = High[1];
            if (Open[0] > var6 - (var5 - var6)) {
                var2 = Low[0];
            }
            if (Open[2] > Open[1]) {
                var5 = Open[2];
                var6 = Open[1];
            } else {
                var5 = 0.0;
                var6 = 0.0;
            }
            if (Open[0] > var6 - (var5 - var6)) {
                var4 = Low[0];
            }
        } else {
            if (mode == 0) {
                if (Open[2] > Open[1]) {
                    var5 = Open[2];
                    var6 = Open[1];
                } else {
                    var5 = 0.0;
                    var6 = 0.0;
                }
            } else {
                var5 = High[2];
                var6 = High[1];
            }
            if (Open[0] > var6 - (var5 - var6)) {
                var4 = Low[0];
            }
        }
    }
    if ((var1 > 0.0 || var3 > 0.0)) {
        res = +1;
    } else {
        if ((var2 > 0.0 || var4 > 0.0)) {
            res = -1;
        }
    }

    return res;
}
//+------------------------------------------------------------------+
string CandleStick_Analyzer()
{
    RefreshRates();
    string CandleStick, Comment1 = "", Comment2 = "", Comment3 = "", Comment4 = "", Comment5 = "", Comment6 = "", Comment7 = "", Comment8 = "", Comment9 = "";

    if (BullishEngulfingExists())
        Comment1 = " Bullish Engulfing ";
    if (BullishHaramiExists())
        Comment2 = " Bullish Harami ";
    if (LongUpCandleExists())
        Comment3 = " Bullish LongUp ";
    if (DojiAtBottomExists())
        Comment4 = " MorningStar Doji ";

    if (DojiAtTopExists())
        Comment5 = " EveningStar Doji ";
    if (BearishHaramiExists())
        Comment6 = " Bearish Harami ";
    if (BearishEngulfingExists())
        Comment7 = " Bearish Engulfing ";
    if (LongDownCandleExists())
        Comment8 = " Bearish LongDown ";

    /*if(SpinningTopExists())
       Comment9 =" Spinning Top ";*/

    CandleStick = Comment1 + Comment2 + Comment3 + Comment4 + Comment5 + Comment6 + Comment7 + Comment8 + Comment9;
    return (CandleStick);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishEngulfingExists()
{
    if (Open[1] <= Close[2] && Close[1] >= Open[2] && Open[2] - Close[2] >= 10 * Point && Close[1] - Open[1] >= 10 * Point)
        return (true);
    return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishHaramiExists()
{
    if (Close[2] < Open[2] && Open[1] < Close[1] && Open[2] - Close[2] > iATR(NULL, 0, 14, 2) && Open[2] - Close[2] > 4 * (Close[1] - Open[1]))
        return (true);
    return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DojiAtBottomExists()
{
    if (Open[3] - Close[3] >= 8 * Point && MathAbs(Close[2] - Open[2]) <= 1 * Point && Close[1] - Open[1] >= 8 * Point)
        return (true);
    return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DojiAtTopExists()
{
    if (Close[3] - Open[3] >= 8 * Point && MathAbs(Close[2] - Open[2]) <= 1 * Point && Open[1] - Close[1] >= 8 * Point)
        return (true);
    return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishHaramiExists()
{
    if (Close[2] > Close[1] && Open[2] < Open[1] && Close[2] > Open[2] && Open[1] > Close[1] && Close[2] - Open[2] > iATR(NULL, 0, 14, 2) && Close[2] - Open[2] > 4 * (Open[1] - Close[1]))
        return (true);
    return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongUpCandleExists()
{
    if (Open[2] < Close[2] && High[2] - Low[2] >= 40 * Point && High[2] - Low[2] > 2.5 * iATR(NULL, 0, 14, 2) && Close[1] < Open[1] && Open[1] - Close[1] > 10 * Point)
        return (true);
    return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongDownCandleExists()
{
    if (Open[1] > Close[1] && High[1] - Low[1] >= 40 * Point && High[1] - Low[1] > 2.5 * iATR(NULL, 0, 14, 1))
        return (true);
    return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishEngulfingExists()
{
    if (Open[1] >= Close[2] && Close[1] <= Open[2] && Open[2] - Close[2] >= 10 * Point && Close[1] - Open[1] >= 10 * Point)
        return (true);
    return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*bool SpinningTopExists()
  {
   HideTestIndicators(true);
   if(High[1] - Low[1] > 1.5*iATR(NULL, 0, 14, 1))
      Print("ST Condition 1 Met");
   if(MathAbs(Open[1] - Close[1])*5 < High[1] - Low[1])
      Print("ST Condition 2 Met");
   if(High[1] - Low[1] > 1.5*iATR(NULL, 0, 14, 1) && (High[1] - Low[1] > 30*Point) && MathAbs(Open[1] - Close[1])*5 < High[1]- Low[1])
      return (true);
   HideTestIndicators(false);
   return (false);
  }*/
//+------------------------------------------------------------------+
void MakeLine(double price)
{
    string name = "level";

    if (price > iOpen(Symbol(), PERIOD_M5, 0))
        Comment("BUY = " + DoubleToStr(price, Digits));
    if (price < iOpen(Symbol(), PERIOD_M5, 0))
        Comment("SELL= " + DoubleToStr(price, Digits));

    if (ObjectFind(name) != -1) {
        ObjectMove(name, 0, iTime(Symbol(), PERIOD_M1, 0), price);
        return;
    }
    ObjectCreate(name, OBJ_HLINE, 0, 0, price);
    ObjectSet(name, OBJPROP_COLOR, clrAqua);
    ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(name, OBJPROP_WIDTH, 2);
    ObjectSet(name, OBJPROP_BACK, TRUE);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| User function IsPinbar                                           |
//+------------------------------------------------------------------+
bool IsBuyPinbar()
{
    // start of declarations
    double actOp, actCl, actHi, actLo, preHi, preLo, preCl, preOp, actRange, preRange, actHigherPart, actHigherPart1;
    actOp = Open[1];
    actCl = Close[1];
    actHi = High[0];
    actLo = Low[1];
    preOp = Open[2];
    preCl = Close[2];
    preHi = High[2];
    preLo = Low[2];
    // SetProxy(preHi,preLo,preOp,preCl);//Check proxy
    actRange       = actHi - actLo;
    preRange       = preHi - preLo;
    actHigherPart  = actHi - actRange * 0.4; // helping variable to not have too much counting in IF part
    actHigherPart1 = actHi - actRange * 0.4; // helping variable to not have too much counting in IF part
    // end of declaratins
    // start function body
    double dayRange = AveRange4();
    if ((actCl > actHigherPart1 && actOp > actHigherPart) && // Close&Open of PB is in higher 1/3 of PB
        (actRange > dayRange * 0.5) &&                       // PB is not too small
        //(actHi<(preHi-preRange*0.3))&& //High of PB is NOT higher than 1/2 of previous Bar
        (actLo + actRange * 0.25 < preLo)) // Nose of the PB is at least 1/3 lower than previous bar
    {

        if (Low[ArrayMinimum(Low, 3, 3)] > Low[1])
            return (true);
    }
    return (false);

} //------------END FUNCTION-------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSellPinbar()
{
    // start of declarations
    double actOp, actCl, actHi, actLo, preHi, preLo, preCl, preOp, actRange, preRange, actLowerPart, actLowerPart1;
    actOp = Open[1];
    actCl = Close[1];
    actHi = High[1];
    actLo = Low[1];
    preOp = Open[2];
    preCl = Close[2];
    preHi = High[2];
    preLo = Low[2];
    // SetProxy(preHi,preLo,preOp,preCl);//Check proxy
    actRange      = actHi - actLo;
    preRange      = preHi - preLo;
    actLowerPart  = actLo + actRange * 0.4; // helping variable to not have too much counting in IF part
    actLowerPart1 = actLo + actRange * 0.4; // helping variable to not have too much counting in IF part
    // end of declaratins

    // start function body

    double dayRange = AveRange4();
    if ((actCl < actLowerPart1 && actOp < actLowerPart) && // Close&Open of PB is in higher 1/3 of PB
        (actRange > dayRange * 0.5) &&                     // PB is not too small
        //(actLo>(preLo+preRange/3.0))&& //Low of PB is NOT lower than 1/2 of previous Bar
        (actHi - actRange * 0.25 > preHi)) // Nose of the PB is at least 1/3 lower than previous bar

    {
        if (High[ArrayMaximum(High, 3, 3)] < High[1])
            return (true);
    }
    return false;
} //------------END FUNCTION-------------
//+------------------------------------------------------------------+
//| User function AveRange4                                          |
//+------------------------------------------------------------------+
double AveRange4()
{
    double sum = 0;
    double rangeSerie[4];

    int i         = 0;
    int ind       = 1;
    int startYear = 1995;

    while (i < 4) {
        // datetime pok=Time[pos+ind];
        if (TimeDayOfWeek(Time[ind]) != 0) {
            sum += High[ind] - Low[ind]; // make summation
            i++;
        }
        ind++;
        // i++;
    }
    // Comment(sum/4.0);
    return (sum / 4.0); // make average, don't count min and max, this is why I divide by 4 and not by 6
}

//+------------------------------------------------------------------+

void ModifyTP(int tipe, double TP_5) // TP disini diambil dari OrderTakeProfit() dari OP terakhir
{
    for (int cnt = OrdersTotal(); cnt >= 0; cnt--) {
        xx = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID && OrderType() == tipe) {
            if (NormalizeDouble(OrderTakeProfit(), Digits) != NormalizeDouble(TP_5, Digits)) {
                xx = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(TP_5, Digits), 0, CLR_NONE);
            }
        }
    }
}

double rata_price(int tipe)
{
    double total_lot  = 0;
    double total_kali = 0;
    double rata_price = 0;
    for (int cnt = 0; cnt < OrdersTotal(); cnt++) {
        xx = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicID && (OrderType() == tipe)) {
            total_lot  = total_lot + OrderLots();
            total_kali = total_kali + (OrderLots() * OrderOpenPrice());
        }
    }
    if (total_lot != 0) {
        rata_price = total_kali / total_lot;
    } else {
        rata_price = 0;
    }
    return (rata_price);
}

void closeOP(int tipe)
{
    int ts      = 3, Oc;
    int totalOP = OrdersTotal();
    for (int cnt = totalOP - 1; cnt >= 0; cnt--) {
        int Os = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if (IsTesting()) {
            ts = (int)OrderLots() * 1000;
        }
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && tipe == OP_BUY && OrderMagicNumber() == MagicID) {
            Oc = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), ts, CLR_NONE);
        }
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && tipe == OP_SELL && OrderMagicNumber() == MagicID) {
            Oc = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), ts, CLR_NONE);
        }
    }
}

void Display_Info()
{
    Buy        = 0;
    lotbuy     = 0;
    lotsbuy    = 0;
    Sell       = 0;
    lotsell    = 0;
    lotssell   = 0;
    SUM        = 0;
    SWAP       = 0;
    profitbuy  = 0;
    profitsell = 0;
    sumbuy     = 0;
    sumsell    = 0;
    bepbuy     = 0;
    bepsell    = 0;
    lowlotbuy  = 9999;
    lowlotsell = 9999;
    hisell     = 0;
    lobuy      = 999999999;

    for (int i = 0; i < OrdersTotal(); i++) {
        bool Dis = false;
        Dis      = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol()) {
            continue;
        }

        if (OrderType() == OP_BUY) {
            Buy++;
            OP++;
            lotbuy = OrderLots();
            profitbuy += OrderProfit();
            lotsbuy += OrderLots();
            lowlotbuy = MathMin(lowlotbuy, OrderLots());
            sumbuy += OrderLots() * OrderOpenPrice();
            lobuy = MathMin(lobuy, OrderOpenPrice());
        }
        // sell
        if (OrderType() == OP_SELL) {
            Sell++;
            OP++;
            lotsell = OrderLots();
            profitsell += OrderProfit();
            lotssell += OrderLots();
            lowlotsell = MathMin(lowlotsell, OrderLots());
            sumsell += OrderLots() * OrderOpenPrice();
            hisell = MathMax(hisell, OrderOpenPrice());
        }
    }

    if (lotsbuy > 0) {
        bepbuy = sumbuy / lotsbuy;
    }
    if (lotssell > 0) {
        bepsell = sumsell / lotssell;
    }

    int m, s;

    m          = Time[0] + Period() * 60 - CurTime();
    s          = m % 60;
    m          = (m - s) / 60;
    int spread = MarketInfo(Symbol(), MODE_SPREAD);

    string _sp = "", _m = "", _s = "";
    if (spread < 10)
        _sp = "..";
    else if (spread < 100)
        _sp = ".";
    if (m < 10)
        _m = "0";
    if (s < 10)
        _s = "0";
    //--------------------------------------------

    //-----------------------------------------------
    int li_0;
    int li_4 = 65280;
    if (AccountEquity() - AccountBalance() < 0.0)
        li_4 = 255;
    if (Seconds() >= 0 && Seconds() < 10)
        li_0 = 255;
    if (Seconds() >= 10 && Seconds() < 20)
        li_0 = 15631086;
    if (Seconds() >= 20 && Seconds() < 30)
        li_0 = 42495;
    if (Seconds() >= 30 && Seconds() < 40)
        li_0 = 16711680;
    if (Seconds() >= 40 && Seconds() < 50)
        li_0 = 65535;
    if (Seconds() >= 50 && Seconds() <= 59)
        li_0 = 16776960;
    string ls_8 = "-------------------------------------------------------------------------------------------------------";
    LABEL("L01", "Arial", 9, 110, 13, White, 0, ls_8);
    LABEL("L02", "Berlin Sans FB Demi", 18, 110, 23, Red, 0, "EA - Smart Neural V1");
    LABEL("L03", "Mistral", 13, 150, 48, Gold, 0, "Smart Trading System");
    LABEL("L04", "Arial ", 9, 110, 60, White, 0, ls_8);

    LABEL("L09", "Arial Black", 9, 120, 80, Yellow, 0, "Lot Buy");
    LABEL("L10", "Arial Black", 9, 120, 95, Yellow, 0, "Lot Sell");
    //----------------------------------------------------------------------------------------------------
    LABEL("L12", "Arial Black", 9, 120, 110, Yellow, 0, "OP Buy");
    LABEL("L13", "Arial Black", 9, 120, 125, Yellow, 0, "OP Sell");
    LABEL("L14", "Arial ", 9, 110, 140, White, 0, ls_8);
    LABEL("L15", "Arial Black", 9, 120, 155, Lime, 0, "Time Candle");
    LABEL("L16", "Arial ", 9, 110, 205, White, 0, ls_8);
    LABEL("L17", "Arial Black", 9, 120, 170, Gold, 0, "Balance");
    LABEL("L18", "Arial Black", 9, 120, 185, OrangeRed, 0, "Equity");
    LABEL("L19", "Arial ", 9, 110, 280, White, 0, ls_8);
    LABEL("L20", "Arial Black", 12, 120, 220, Yellow, 0, "Profit / Floating  :");
    //--------------------------------------------------------------------------
    LABEL("L33", "Arial Black", 9, 220, 80, White, 0, ":  " + DoubleToStr(lotsbuy, 2));
    LABEL("L34", "Arial Black", 9, 220, 95, White, 0, ":  " + DoubleToStr(lotssell, 2));
    LABEL("L38", "Arial Black", 9, 220, 110, White, 0, ":  " + DoubleToStr(Buy, 0));
    LABEL("L39", "Arial Black", 9, 220, 125, White, 0, ":  " + DoubleToStr(Sell, 0));
    LABEL("L40", "Arial Black", 9, 220, 155, White, 0, ":  " + _m + DoubleToStr(m, 0) + ":" + _s + DoubleToStr(s, 0));
    LABEL("L41", "Arial Black", 9, 220, 170, White, 0, ":  " + DoubleToStr(AccountBalance(), 2));
    LABEL("L42", "Arial Black", 9, 220, 185, White, 0, ":  " + DoubleToStr(AccountEquity(), 2));
    LABEL("L21", "Arial Black", 25, 120, 240, Lime, 0, "" + DoubleToStr(AccountEquity() - AccountBalance(), 2));
}

void LABEL(string a_name_0, string a_fontname_8, int a_fontsize_16, int a_x_20, int a_y_24, color a_color_28, int a_corner_32, string a_text_36)
{
    if (ObjectFind(a_name_0) < 0)
        ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(a_name_0, a_text_36, a_fontsize_16, a_fontname_8, a_color_28);
    ObjectSet(a_name_0, OBJPROP_CORNER, a_corner_32);
    ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_20);
    ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_24);
}

//+------------------------------------------------------------------+
//| OnChart event handler                                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    if (ObjectGetInteger(0, "CLOSE ALL1", OBJPROP_STATE) != 0) {
        ObjectSetInteger(0, "CLOSE ALL1", OBJPROP_STATE, 0);
        PlaySound("alert2.wav");

        int total = OrdersTotal();
        for (int cnt = total - 1; cnt >= 0; cnt--) {
            bool MOT = false;
            MOT      = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

            if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
                switch (OrderType()) {
                case OP_BUY: {
                    if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 10, Violet))
                        return;
                } break;
                case OP_SELL: {
                    if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 10, Violet))
                        return;
                } break;
                }

                if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                    if (!OrderDelete(OrderTicket())) {
                        Print("Error deleting " + OrderType() + " order : ", GetLastError());
                        return;
                    }
            }
        }
        return;
    }

    // FUNGSI CLOSE ALL

    if (ObjectGetInteger(0, "CLOSE ALL", OBJPROP_STATE) != 0) {
        ObjectSetInteger(0, "CLOSE ALL", OBJPROP_STATE, 0);
        
        bool ClsAll;
        bool ClsAll2;
        bool ClsAll3;

        for (int li_0 = OrdersTotal() - 1; li_0 >= 0; li_0--) {
                ClsAll = false;
            ClsAll      = OrderSelect(li_0, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol()) {
                if (OrderSymbol() == Symbol()) {
                    if (OrderType() == OP_BUY)
                        ClsAll2 = false;
                    ClsAll2 = OrderClose(OrderTicket(), OrderLots(), Bid, MagicID);
                    if (OrderType() == OP_SELL)
                        ClsAll3 = false;
                    ClsAll3 = OrderClose(OrderTicket(), OrderLots(), Ask, MagicID);
                }
                Sleep(1000);
            }
        }
    }
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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