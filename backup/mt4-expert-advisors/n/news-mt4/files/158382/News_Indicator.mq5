//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=158016#p158016

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1


#define Section_News
#ifdef Section_News

input string    TNEWS                  = "== News Setup ==";              // ————————————————————————
input string    note                   = "http://calendar.fxstreet.com/"; // You Must to allow this URL:
input bool      NEWS_FILTER            = true;                           // News Filter On
input bool      NEWS_IMPORTANCE_LOW    = true;                           // Low
input bool      NEWS_IMPORTANCE_MEDIUM = true;                            // Medium
input bool      NEWS_IMPORTANCE_HIGH   = true;                            // High
int       STOP_BEFORE_NEWS       = 30;                              // Minutes Stop Before News
int       START_AFTER_NEWS       = 30;                              // Minutes Stop After News
input string    Currencies_Check       = "USD,EUR,CAD,AUD,NZD,GBP";       // Currencys
bool            Check_Specific_News    = false;
string          Specific_News_Text     = "employment";
bool            DRAW_NEWS_CHART        = false;      // Show Up comming News
int             X                      = 10;        // Chart X-Axis Position
int             Y                      = 280;       // Chart Y-Axis Position
string          News_Font              = "Calibri"; // Font
color           Font_Color             = clrBlack;  // Font Color
input bool      DRAW_NEWS_LINES        = false;     // Draw Lines News
color           Line_Color             = clrBlack;  // Line Color
ENUM_LINE_STYLE Line_Style             = STYLE_DOT;
int             Line_Width             = 1;
int             Font_Size              = 8;
string          LANG                   = "en-US";
datetime        date;
int             TIME_CORRECTION, NEWS_ON = 0;

class News
{

  public:
    News() { ; }
    ~News() { ; }

    bool evaluate()
    {

        ReadNews();
        Print("line: ",__LINE__,"         Reading News: ");

        // if (NEWS_ON == 1) { return false; } // news comming soon  
        
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
        // if (NEWS_FILTER == false) return;

        // static int waiting = 0;
        // if (waiting <= 0) {
        //     if (!MQLInfoInteger(MQL_TESTER) || !MQLInfoInteger(MQL_OPTIMIZATION)) {
        //         if (READ_NEWS(NEWS_TABLE)) waiting = 100;
        //         if (ArraySize(NEWS_TABLE) <= 0) return;
        //         DRAW_NEWS(NEWS_TABLE);
        //     }
        // } else
        //     waiting--;
        // if (ArraySize(NEWS_TABLE) <= 0) return;

        datetime time = TimeCurrent();
        //---
        for (int i = 0; i < ArraySize(NEWS_TABLE); i++) {
            
            datetime news_time        = NEWS_TABLE[i].dTime + TIME_CORRECTION;
            Print("line: ",__LINE__," news_time: ",news_time);

            bool     Importance_Check = false;
            
            if ((!NEWS_IMPORTANCE_LOW && NEWS_TABLE[i].importance == "*") || (!NEWS_IMPORTANCE_MEDIUM && NEWS_TABLE[i].importance == "* *") ||
                (!NEWS_IMPORTANCE_HIGH && NEWS_TABLE[i].importance == "* * *"))
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

                if ((!NEWS_IMPORTANCE_LOW && l_a_news[i].importance == "*") || (!NEWS_IMPORTANCE_MEDIUM && l_a_news[i].importance == "* *") ||
                    (!NEWS_IMPORTANCE_HIGH && l_a_news[i].importance == "* * *")) {
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
}

#endif




// NOTE: Inputs
// ------------------------------------------------------------------
input int    Period                = 10;                    // Indicator Periods
string T0                    = "== Set Arrows ==";    // Set Arrows
bool   ArrowsOn              = false;                  // Arrows On?
color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
color  ArrowDnClr            = clrRed;                // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double lineTop[];
double lineBottom[];
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
void OnTimer(void) {
    news.evaluate();
}

void OnInit()
{
    oninitNews();

    //--- indicator short name
    string short_name = "Line Indicator";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_ARROW, 233);
    PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 234);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);

    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);

}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (rates_total < Period) return (0);

    int start;
    if (prev_calculated > 1)
        start = prev_calculated - 1;
    else {
        start = Period + 1;
    }

    for (int i = start; i < rates_total && !IsStopped(); i++) {
        

        if (haveSignalUp(i)) {
            // ArrowUp[i - 1] = low[i - 1];
            if (newCandle.IsNewCandle()) {
                Notifications(0);
            }
        }

        if (haveSignalDown(i)) {
            // ArrowDn[i - 1] = high[i - 1];
            if (newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }
    }

    return (rates_total);
}
// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    int shift = iBars(_Symbol, Period()) - i;
    if (iOpen(_Symbol, Period(), shift) < iClose(_Symbol, Period(), shift)) {
        return true;
    }

    return false;
}
bool haveSignalDown(int i)
{
    int shift = iBars(_Symbol, Period()) - i;
    if (iOpen(_Symbol, Period(), shift) > iClose(_Symbol, Period(), shift)) {
        return true;
    }

    return false;
}

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

    text += " ";

    if (!notifications) return;
    if (desktop_notifications) Alert(text);
    if (push_notifications) SendNotification(text);
    if (email_notifications) SendMail("MetaTrader Notification", text);
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

class CNewCandle
{
 private:
  int             _initialCandles;
  string          _symbol;
  ENUM_TIMEFRAMES _tf;

 public:
  CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = iBars(Symbol(), Period());
    _symbol         = Symbol();
    _tf             = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = iBars(_symbol, _tf);
    if (_currentCandles > _initialCandles) {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=158016#p158016

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 