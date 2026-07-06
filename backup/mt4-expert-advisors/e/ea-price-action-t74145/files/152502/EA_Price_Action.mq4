// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74145
//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright c 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright c 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

extern string EA_Name = "EA HOKKYDJONG";
extern string Use_TradeAgain = "If => TRUE,EA will trade again,If => FALSE => EA will Off";
extern bool TradeAgain = TRUE;
extern string Use_Loop = "Example = 10,EA will trader for 10 Laps";
extern int Loop = 10000;
int Gi_108;
extern int StartTrade = 0;
extern int EndTrade = 24;
extern string Use_DbLots = "If = 1-> Use Multiplier Lot, If = 2-> Use Fixed Lot";
extern int DbLots = 1;
extern double Lots = 0.01;
extern double SL = 0.0;
extern double TP = 4.0;
extern double Distance = 3.0;
extern double Multiplier = 1.6;
extern int MaxLevel = 20;
double Gd_176 = 3.0;
extern double LotsDecimal = 2.0;
extern int MagicNumber = 163991;
extern string EA_Comment = "ea_hokkydjong";
double Gd_unused_204 = 0.0;
double G_price_212;
double G_price_220;
double G_bid_228;
double G_ask_236;
double Gd_244;
double Gd_252;
bool Gi_260;
datetime G_time_264 = 0;
int Gi_268 = 0;
double Gd_272;
int G_pos_280 = 0;
int Gi_284;
double Gd_288 = 0.0;
bool Gi_296 = FALSE;
bool Gi_300 = FALSE;
bool Gi_304 = FALSE;
int Gi_308;
bool Gi_312 = FALSE;
double Gd_316;
int Gi_324 = 65535;
int Gi_328 = 65535;
int Gi_332 = 16776960;
double Gd_336;
extern double MoneyPerLot = 1.7;

#define NEWS_FILTER
#ifdef NEWS_FILTER

input string TNEWS = "== News Setup ==";  // ————————————
input string note = "http://calendar.fxstreet.com/"; // You Must to allow this URL:
input bool               NEWS_FILTER_ON = true;                      // News Filter On
input bool               NEWS_IMPOTANCE_LOW = false;                     // Low
input bool               NEWS_IMPOTANCE_MEDIUM = true;                      // Medium
input bool               NEWS_IMPOTANCE_HIGH = true;                      // High 
input int                STOP_BEFORE_NEWS = 30;                        // Minutes Stop Before News
input int                START_AFTER_NEWS = 30;                        // Minutes Stop After News
input string             Currencies_Check = "USD,EUR,CAD,AUD,NZD,GBP"; // Currencys
bool               Check_Specific_News = false;
string             Specific_News_Text = "employment";
input bool               DRAW_NEWS_CHART = true; // Show Up comming News
int                X = 10;//Chart X-Axis Position
int                Y = 280;//Chart Y-Axis Position
input string             News_Font = "Arial"; // Font
input color              Font_Color = clrBlack; // Font Color
input bool               DRAW_NEWS_LINES = false; // Draw Lines News
input color              Line_Color = clrBlack; // Line Color
ENUM_LINE_STYLE    Line_Style = STYLE_DOT;
int                Line_Width = 1;
int Font_Size = 8;
string LANG = "en-US";

datetime date;
int TIME_CORRECTION, NEWS_ON = 0;

class News
{

    public:
    News() { ; }
    ~News() { ; }

    bool StopForNews() { if(NEWS_ON==1) {return true;} return false; }
    

    struct sNews
    {
        datetime          dTime;
        string            time;
        string            currency;
        string            importance;
        string            news;
        string            Actual;
        string            forecast;
        string            previus;
    };
    sNews NEWS_TABLE [], HEADS;

    int OnInit()
    {
        if(!MQLInfoInteger(MQL_TESTER) || !MQLInfoInteger(MQL_OPTIMIZATION))
        {
            if(NEWS_FILTER_ON == true && READ_NEWS(NEWS_TABLE) && ArraySize(NEWS_TABLE) > 0)
                DRAW_NEWS(NEWS_TABLE);
            
            TIME_CORRECTION = (-TimeGMTOffset());
        }
        EventSetTimer(1);

        return(INIT_SUCCEEDED);
    }
    
    void OnDeinit(const int reason)
    {
        DEINIT_PANEL();
        EventKillTimer();
    }

    void OnTimer()
    {
        OnTick();
        if(NEWS_FILTER_ON == false) return;

        static int waiting = 0;
        if(waiting <= 0)
        {
            if(!MQLInfoInteger(MQL_TESTER) || !MQLInfoInteger(MQL_OPTIMIZATION))
            {
                if(READ_NEWS(NEWS_TABLE))
                    waiting = 100;
                if(ArraySize(NEWS_TABLE) <= 0)
                    return;
                DRAW_NEWS(NEWS_TABLE);
            }
        }
        else
            waiting--;
        if(ArraySize(NEWS_TABLE) <= 0)
            return;

        datetime time = TimeCurrent();
        //---
        for(int i = 0; i < ArraySize(NEWS_TABLE); i++)
        {
            datetime news_time = NEWS_TABLE[i].dTime + TIME_CORRECTION;
            bool Importance_Check = false;
            if((!NEWS_IMPOTANCE_LOW && NEWS_TABLE[i].importance == "*") ||
               (!NEWS_IMPOTANCE_MEDIUM && NEWS_TABLE[i].importance == "* *") ||
               (!NEWS_IMPOTANCE_HIGH && NEWS_TABLE[i].importance == "* * *"))
                Importance_Check = true;
            if(Importance_Check || StringFind(Currencies_Check, NEWS_TABLE[i].currency, 0) == -1 || (Check_Specific_News && (StringFind(NEWS_TABLE[i].news, Specific_News_Text) == -1)))
                continue;
            if((news_time <= time && (news_time + (datetime) (START_AFTER_NEWS * 60)) >= time) ||
               (news_time >= time && (news_time - (datetime) (STOP_BEFORE_NEWS * 60)) <= time))
            {
                NEWS_ON = 1;
                Comment("News Time...");
                break;
            }
            else
            {
                NEWS_ON = 0;
                Comment("No News");
            }
        }
        return;
    }

    void OnTick()
    {
        //---

    }

    void DEL_ROW(sNews& l_a_news [], int row)
    {
        int size = ArraySize(l_a_news) - 1;
        for(int i = row; i < size; i++)
        {
            l_a_news[i].Actual = l_a_news[i + 1].Actual;
            l_a_news[i].currency = l_a_news[i + 1].currency;
            l_a_news[i].dTime = l_a_news[i + 1].dTime;
            l_a_news[i].forecast = l_a_news[i + 1].forecast;
            l_a_news[i].importance = l_a_news[i + 1].importance;
            l_a_news[i].news = l_a_news[i + 1].news;
            l_a_news[i].previus = l_a_news[i + 1].previus;
            l_a_news[i].time = l_a_news[i + 1].time;
        }
        ArrayResize(l_a_news, size);
    }

    bool READ_NEWS(sNews& l_NewsTable [])
    {
        string cookie = NULL, referer = NULL, headers;
        char post [], result [];
        string tmpStr = "";
        string st_date = TimeToString(TimeCurrent(), TIME_DATE), end_date = TimeToString((TimeCurrent() + (datetime) (7 * 24 * 60 * 60)), TIME_DATE);
        StringReplace(st_date, ".", "");
        StringReplace(end_date, ".", "");
        string url = "http://calendar.fxstreet.com/EventDateWidget/GetMini?culture=" + LANG + "&view=range&start=" + st_date + "&end=" + end_date + "&timezone=UTC" + "&columns=date%2Ctime%2Ccountry%2Ccountrycurrency%2Cevent%2Cconsensus%2Cprevious%2Cvolatility%2Cactual&showcountryname=false&showcurrencyname=true&isfree=true&_=1455009216444";
        ResetLastError();
        WebRequest("GET", url, cookie, referer, 10000, post, sizeof(post), result, headers);
        if(ArraySize(result) <= 0)
        {
            int er = GetLastError();
            ResetLastError();
            Print("ERROR_TXT IN WebRequest");
            if(er == 4060)
                MessageBox("YOU MUST ADD THE ADDRESS '" + "http://calendar.fxstreet.com/" + "' IN THE LIST OF ALLOWED URL IN THE TAB 'ADVISERS'", "ERROR_TXT", MB_ICONINFORMATION);
            return false;
        }

        tmpStr = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
        int handl = FileOpen("News.txt", FILE_WRITE | FILE_TXT);
        FileWrite(handl, tmpStr);
        FileFlush(handl);
        FileClose(handl);
        StringReplace(tmpStr, "&#39;", "'");
        StringReplace(tmpStr, "&#163;", "");
        StringReplace(tmpStr, "&#165;", "");
        StringReplace(tmpStr, "&amp;", "&");

        int st = StringFind(tmpStr, "fxst-thevent", 0);
        st = StringFind(tmpStr, ">", st) + 1;
        int end = StringFind(tmpStr, "</th>", st);
        HEADS.news = (st < end ? StringSubstr(tmpStr, st, end - st) : "");
        st = StringFind(tmpStr, "fxst-thvolatility", 0);
        st = StringFind(tmpStr, ">", st) + 1;
        end = StringFind(tmpStr, "</th>", st);
        HEADS.importance = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
        st = StringFind(tmpStr, "fxst-thactual", 0);
        st = StringFind(tmpStr, ">", st) + 1;
        end = StringFind(tmpStr, "</th>", st);
        HEADS.Actual = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
        st = StringFind(tmpStr, "fxst-thconsensus", 0);
        st = StringFind(tmpStr, ">", st) + 1;
        end = StringFind(tmpStr, "</th>", st);
        HEADS.forecast = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
        st = StringFind(tmpStr, "fxst-thprevious", 0);
        st = StringFind(tmpStr, ">", st) + 1;
        end = StringFind(tmpStr, "</th>", st);
        HEADS.previus = (st < end ? StringSubstr(tmpStr, st, end - st) : "");
        HEADS.currency = "";
        HEADS.dTime = 0;
        HEADS.time = "";
        int startLoad = StringFind(tmpStr, "<tbody>", 0) + 7;
        int endLoad = StringFind(tmpStr, "</tbody>", startLoad);
        if(startLoad >= 0 && endLoad > startLoad)
        {
            tmpStr = StringSubstr(tmpStr, startLoad, endLoad - startLoad);
            while(StringReplace(tmpStr, "  ", " "));
        }
        else
            return false;
        int begin = -1;
        do
        {
            begin = StringFind(tmpStr, "<span", 0);
            if(begin >= 0)
            {
                end = StringFind(tmpStr, "</span>", begin) + 7;
                tmpStr = StringSubstr(tmpStr, 0, begin) + StringSubstr(tmpStr, end);
            }
        } while(begin >= 0);
        StringReplace(tmpStr, "<strong>", NULL);
        StringReplace(tmpStr, "</strong>", NULL);
        int BackShift = 0;
        string arNews [];
        for(uchar tr = 1; tr < 255; tr++)
        {
            if(StringFind(tmpStr, CharToString(tr), 0) > 0)
                continue;
            int K = StringReplace(tmpStr, "</tr>", CharToString(tr));
            //ArrayResize(arNews,StringReplace(tmpStr,"</tr>",CharToString(tr)));
            K = StringSplit(tmpStr, tr, arNews);
            ArrayResize(l_NewsTable, K);
            for(int td = 0; td < ArraySize(arNews); td++)
            {
                st = StringFind(arNews[td], "fxst-td-date", 0);
                if(st > 0)
                {
                    st = StringFind(arNews[td], ">", st) + 1;
                    end = StringFind(arNews[td], "</td>", st) - 1;
                    int d = (int) StringToInteger(StringSubstr(arNews[td], end - 4, end - st));
                    MqlDateTime time;
                    TimeCurrent(time);
                    if(d < (time.day - 5))
                    {
                        if(time.mon == 12)
                        {
                            time.mon = 1;
                            time.year++;
                        }
                        else
                        {
                            time.mon++;
                        }
                    }
                    time.day = d;
                    time.min = 0;
                    time.hour = 0;
                    time.sec = 0;
                    date = StructToTime(time);
                    BackShift++;
                    continue;
                }
                st = StringFind(arNews[td], "fxst-evenRow", 0);
                if(st < 0)
                {
                    BackShift++;
                    continue;
                }
                int st1 = StringFind(arNews[td], "fxst-td-time", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].time = StringSubstr(arNews[td], st1, end - st1);
                if(StringFind(l_NewsTable[td - BackShift].time, ":") > 0)
                {
                    l_NewsTable[td - BackShift].dTime = StringToTime(TimeToString(date, TIME_DATE) + " " + StringSubstr(arNews[td], st1, end - st1));
                }
                else
                {
                    l_NewsTable[td - BackShift].dTime = date;
                }
                st1 = StringFind(arNews[td], "fxst-td-currency", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].currency = (st1 < end ? StringSubstr(arNews[td], st1, end - st1) : "");
                st1 = StringFind(arNews[td], "fxst-i-vol", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                StringInit(l_NewsTable[td - BackShift].importance, (int) StringToInteger(StringSubstr(arNews[td], st1, end - st1)), '*');
                st1 = StringFind(arNews[td], "fxst-td-event", st);
                int st2 = StringFind(arNews[td], "fxst-eventurl", st1);
                st1 = StringFind(arNews[td], ">", fmax(st1, st2)) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                int end1 = StringFind(arNews[td], "</a>", st1);
                l_NewsTable[td - BackShift].news = StringSubstr(arNews[td], st1, (end1 > 0 ? fmin(end, end1) : end) - st1);
                st1 = StringFind(arNews[td], "fxst-td-act", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].Actual = (end > st1 ? StringSubstr(arNews[td], st1, end - st1) : "");
                st1 = StringFind(arNews[td], "fxst-td-cons", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].forecast = (end > st1 ? StringSubstr(arNews[td], st1, end - st1) : "");
                st1 = StringFind(arNews[td], "fxst-td-prev", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].previus = (end > st1 ? StringSubstr(arNews[td], st1, end - st1) : "");
            }
            break;
        }
        ArrayResize(l_NewsTable, (ArraySize(l_NewsTable) - BackShift));
        return(true);
    }

    void DRAW_NEWS(sNews& l_a_news [])
    {
        if(DRAW_NEWS_LINES || DRAW_NEWS_CHART)
        {
            if(NEWS_FILTER_ON == false)
                return;
            for(int i = ArraySize(l_a_news) - 1; i >= 0; i--)
            {
                StringReplace(l_a_news[i].currency, " ", "");
                int Currency_check_counter = 0;

                datetime t1 = (l_a_news[i].dTime + (datetime) (START_AFTER_NEWS * 60));
                datetime t2 = ((TimeCurrent() - (datetime) TIME_CORRECTION));

                if(StringFind(Currencies_Check, l_a_news[i].currency) == -1 || t1 < t2 || (Check_Specific_News && (StringFind(l_a_news[i].news, Specific_News_Text) == -1)))
                {
                    DEL_ROW(l_a_news, i);
                    continue;
                }

                if((!NEWS_IMPOTANCE_LOW && l_a_news[i].importance == "*") ||
                   (!NEWS_IMPOTANCE_MEDIUM && l_a_news[i].importance == "* *") ||
                   (!NEWS_IMPOTANCE_HIGH && l_a_news[i].importance == "* * *"))
                {
                    DEL_ROW(l_a_news, i);
                    continue;
                }
                string NAME = (" " + l_a_news[i].currency + " " + l_a_news[i].importance + " " + l_a_news[i].news);
                if(DRAW_NEWS_LINES)
                {
                    if(ObjectFind(0, NAME) < 0)
                    {
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
            int K = 0, Z = 0;
            if(DRAW_NEWS_CHART)
            {
                for(int l = 1; l <= 9 && Z < ArraySize(l_a_news); l++)
                {
                    for(K = Z; K < ArraySize(l_a_news); K++)
                        if(l_a_news[K].currency != "")
                            break;
                    Z = K + 1;


                    NAME = "PANEL_NEWS_N" + (string) l;
                    if(ObjectFind(0, NAME) < 0)
                        OBJECT_LABEL(0, NAME, 0, X + 110, Y - (int) (18 * (l + 5)), CORNER_LEFT_LOWER, ((TimeToString(l_a_news[K].dTime + TIME_CORRECTION, TIME_DATE | TIME_MINUTES) + " " + l_a_news[K].currency + " " + l_a_news[K].importance + " " + l_a_news[K].news)), News_Font, Font_Size, Font_Color, 0, ANCHOR_LEFT_UPPER, false, false, true, 0);

                }
            }
            return;
        }
    }

    void DEINIT_PANEL()
    {
        ObjectsDeleteAll(0);
    }

    bool OBJECT_LABEL(const long              CHART_ID = 0,
                      const string            NAME = "",
                      const int               SUB_WINDOW = 0,
                      const int               X_Axis = 0,
                      const int               Y_Axis = 0,
                      const ENUM_BASE_CORNER  CORNER = CORNER_LEFT_UPPER,
                      const string            TEXT = "",
                      const string            FONT = "",
                      const int               FONT_SIZE = 10,
                      const color             CLR = color("255,0,0"),
                      const double            ANGLE = 0.0,
                      const ENUM_ANCHOR_POINT ANCHOR = ANCHOR_LEFT_UPPER,
                      const bool              BACK = false,
                      const bool              SELECTION = false,
                      const bool              HIDDEN = true,
                      const long              ZORDER = 0,
                      string                  TOOLTIP = "\n")
    {
        ResetLastError();
        if(ObjectFind(0, NAME) < 0)
        {
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
        }
        else
        {
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR, CLR);
            ObjectSetString(CHART_ID, NAME, OBJPROP_TEXT, TEXT);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_XDISTANCE, X);
            ObjectSetInteger(CHART_ID, NAME, OBJPROP_YDISTANCE, Y);
        }
        return(true);
        ChartRedraw();
    }

};

News news();
#endif


int init()
{
   if (Digits == 3 || Digits == 5) Gd_316 = 10.0 * Point;
   else Gd_316 = Point;

#ifdef NEWS_FILTER
   news.OnInit();
#endif
   
   return (0);
}

void OnDeinit(const int reason)
{
    ObjectsDeleteAll();
    #ifdef NEWS_FILTER
        news.OnDeinit(reason);
    #endif
}

int start()
{
    #ifdef NEWS_FILTER
        news.OnTick();
        if(news.StopForNews()) return 0;
    #endif
        
        double order_lots_0;
   double order_lots_8;
   double iclose_16;
   double iclose_24;
   double Ld_32;
   f0_8();
   f0_9();
   f0_0();
   if (f0_10()) {
      if (G_time_264 == Time[0]) return (0);
      G_time_264 = Time[0];
      Gi_284 = f0_12();
      if (Gi_284 == 0) Gi_260 = FALSE;
      for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--) {
         if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               Gi_300 = TRUE;
               Gi_304 = FALSE;
               order_lots_0 = OrderLots();
               break;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_SELL) {
               Gi_300 = FALSE;
               Gi_304 = TRUE;
               order_lots_8 = OrderLots();
               break;
            }
         }
      }
      if (Gi_284 > 0 && Gi_284 <= MaxLevel) {
         RefreshRates();
         Gd_244 = f0_11();
         Gd_252 = f0_3();
         if (Gi_300 && Gd_244 - Ask >= Distance * Gd_316) Gi_296 = TRUE;
         if (Gi_304 && Bid - Gd_252 >= Distance * Gd_316) Gi_296 = TRUE;
      }
      if (Gi_284 < 1) {
         Gi_304 = FALSE;
         Gi_300 = FALSE;
         Gi_296 = TRUE;
      }
      if (Gi_296) {
         Gd_244 = f0_11();
         Gd_252 = f0_3();
         if (Gi_304) {
            Gd_272 = f0_4(OP_SELL);
            Gi_268 = Gi_284;
            if (Gd_272 > 0.0) {
               RefreshRates();
               Gi_308 = f0_5(1, Gd_272, Bid, Gd_176, Ask, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
               if (Gi_308 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               Gd_252 = f0_3();
               Gi_296 = FALSE;
               Gi_312 = TRUE;
            }
         } else {
            if (Gi_300) {
               Gd_272 = f0_4(OP_BUY);
               Gi_268 = Gi_284;
               if (Gd_272 > 0.0) {
                  Gi_308 = f0_5(0, Gd_272, Ask, Gd_176, Bid, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
                  if (Gi_308 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  Gd_244 = f0_11();
                  Gi_296 = FALSE;
                  Gi_312 = TRUE;
               }
            }
         }
      }
      if (Hour() >= StartTrade && Hour() < EndTrade) {
         if (Gi_108 < Loop && TradeAgain) {
            if (Gi_296 && Gi_284 < 1) {
               iclose_16 = iClose(Symbol(), 0, 2);
               iclose_24 = iClose(Symbol(), 0, 1);
               G_bid_228 = Bid;
               G_ask_236 = Ask;
               if ((!Gi_304) && (!Gi_300)) {
                  Gi_268 = Gi_284;
                  if (iclose_16 > iclose_24) {
                     Gd_272 = f0_4(OP_SELL);
                     if (Gd_272 > 0.0) {
                        Gi_308 = f0_5(1, Gd_272, G_bid_228, Gd_176, G_bid_228, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
                        Gi_108++;
                        if (Gi_308 < 0) {
                           Print(Gd_272, "Error: ", GetLastError());
                           return (0);
                        }
                        Gd_244 = f0_11();
                        Gi_312 = TRUE;
                     }
                  } else {
                     Gd_272 = f0_4(OP_BUY);
                     if (Gd_272 > 0.0) {
                        Gi_308 = f0_5(0, Gd_272, G_ask_236, Gd_176, G_ask_236, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
                        Gi_108++;
                        if (Gi_308 < 0) {
                           Print(Gd_272, "Error: ", GetLastError());
                           return (0);
                        }
                        Gd_252 = f0_3();
                        Gi_312 = TRUE;
                     }
                  }
               }
            }
         }
      }
      Gi_284 = f0_12();
      G_price_220 = 0;
      Ld_32 = 0;
      for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--) {
         if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               G_price_220 += OrderOpenPrice() * OrderLots();
               Ld_32 += OrderLots();
            }
         }
      }
      if (Gi_284 > 0) G_price_220 = NormalizeDouble(G_price_220 / Ld_32, Digits);
      if (Gi_312) {
         for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--) {
            if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_BUY) {
                  G_price_212 = G_price_220 + TP * Gd_316;
                  Gd_288 = G_price_220 - SL * Gd_316;
                  Gi_260 = TRUE;
               }
            }
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_SELL) {
                  G_price_212 = G_price_220 - TP * Gd_316;
                  Gd_288 = G_price_220 + SL * Gd_316;
                  Gi_260 = TRUE;
               }
            }
         }
      }
      if (!Gi_312) return (0);
      if (Gi_260 != TRUE) return (0);
      for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--) {
         if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) if (OrderModify(OrderTicket(), G_price_220, OrderStopLoss(), G_price_212, 0, White))
         Gi_312 = FALSE;
      }
   }
   return (0);
}

void OnTimer(void)
{

    #ifdef NEWS_FILTER
        news.OnTimer();
    #endif
}

double f0_4(int A_cmd_0)
{
   double lots_4;
   int datetime_12;
   switch (DbLots) {
   case 0:
      lots_4 = Lots;
      break;
   case 1:
      lots_4 = NormalizeDouble(Lots * MathPow(Multiplier, Gi_268), LotsDecimal);
      break;
   case 2:
      datetime_12 = 0;
      lots_4 = Lots;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               if (datetime_12 < OrderCloseTime()) {
                  datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) {
                     lots_4 = NormalizeDouble(OrderLots() * Multiplier, LotsDecimal);
                     continue;
                  }
                  lots_4 = Lots;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), A_cmd_0, lots_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (lots_4);
}

int f0_12() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

int f0_5(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_unused_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch (Ai_0) {
   case 2:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, SL), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, SL), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         RefreshRates();
         ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_14(Bid, SL), f0_1(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_7(Ad_24, SL), f0_2(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_7(Ad_24, SL), f0_2(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_7(Ask, SL), f0_2(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}

double f0_14(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Gd_316);
}

double f0_7(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Gd_316);
}

double f0_1(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Gd_316);
}

double f0_2(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Gd_316);
}

double f0_11() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

double f0_3() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

void f0_0() {
   if (iClose(Symbol(), PERIOD_H1, 0) > iClose(Symbol(), PERIOD_H1, 2)) {
      if (iClose(Symbol(), PERIOD_H1, 0) < iClose(Symbol(), PERIOD_H1, 2)) {
         if (iClose(Symbol(), PERIOD_H1, 0) > iClose(Symbol(), PERIOD_H1, 1)) {
            if (iClose(Symbol(), PERIOD_H1, 0) < iClose(Symbol(), PERIOD_H1, 1)) {
               if (iOpen(Symbol(), 0, 0) > iOpen(Symbol(), 0, 1)) {
                  if (iOpen(Symbol(), 0, 0) < iOpen(Symbol(), 0, 1)) {
                     if (iClose(Symbol(), 0, 0) > iClose(Symbol(), 0, 1)) {
                        if (iClose(Symbol(), 0, 0) >= iClose(Symbol(), 0, 1)) {
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

double f0_13() {
   Gd_336 = 0;
   double Ld_ret_0 = 0;
   for (int pos_8 = 0; pos_8 < OrdersHistoryTotal(); pos_8++) {
      if (OrderSelect(pos_8, SELECT_BY_POS, MODE_HISTORY))
      if (OrderType() == OP_BUY && 1) Gd_336 += OrderLots();
   }
   Ld_ret_0 = Gd_336 * MoneyPerLot;
   return (Ld_ret_0);
}

void f0_8() {
   ObjectCreate("Original", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Original", " ", 10, "Arial Bold", Red);
   ObjectSet("Original", OBJPROP_CORNER, 2);
   ObjectSet("Original", OBJPROP_XDISTANCE, 200);
   ObjectSet("Original", OBJPROP_YDISTANCE, 10);
}

void f0_9() {
   color color_0;
   int Li_4 = 65280;
   if (AccountEquity() - AccountBalance() < 0.0) Li_4 = 255;
   if (Seconds() >= 0 && Seconds() < 10) color_0 = Red;
   if (Seconds() >= 10 && Seconds() < 20) color_0 = Violet;
   if (Seconds() >= 20 && Seconds() < 30) color_0 = Orange;
   if (Seconds() >= 30 && Seconds() < 40) color_0 = Blue;
   if (Seconds() >= 40 && Seconds() < 50) color_0 = Yellow;
   if (Seconds() >= 50 && Seconds() <= 59) color_0 = Aqua;
   string Ls_8 = "-------------------------------------------";
   f0_6("L01", "Arial", 9, 10, 10, Gi_328, 1, Ls_8);
   f0_6("L02", "Verdana", 15, 10, 25, color_0, 1, "EA HOKKYDJONG");
   f0_6("L0i", "Mistral", 12, 10, 45, Gi_324, 1, "Price Action Scalping Style");
   f0_6("L03", "Arial", 9, 10, 60, Gi_328, 1, Ls_8);
   f0_6("L04", "Arial", 9, 10, 75, Gi_332, 1, ">> Account Company : " + AccountCompany());
   f0_6("L05", "Arial", 9, 10, 90, Gi_332, 1, ">> Name Server  : " + AccountServer());
   f0_6("L06", "Arial", 9, 10, 105, Gi_332, 1, ">> Account Name  : " + AccountName());
   f0_6("L07", "Arial", 9, 10, 120, Gi_332, 1, ">> Name Number  : " + AccountNumber());
   f0_6("L08", "Arial", 9, 10, 135, Gi_332, 1, ">> Account Leverage  : 1 " + AccountLeverage());
   f0_6("L09", "Arial", 9, 10, 150, Gi_332, 1, ">> Time Server  : " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS));
   f0_6("L10", "Arial", 9, 10, 165, Gi_332, 1, ">> Spread  : " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0));
   f0_6("L11", "Arial", 9, 10, 180, Gi_332, 1, ">> Account Balance  : $ " + DoubleToStr(AccountBalance(), 2));
   f0_6("L12", "Arial", 9, 10, 195, Gi_332, 1, ">> Account Equity  : $ " + DoubleToStr(AccountEquity(), 2));
   f0_6("L13", "Arial", 9, 10, 210, Gi_332, 1, ">> Order Total  : " + DoubleToStr(OrdersTotal(), 0));
   f0_6("L14", "Arial", 9, 10, 390, Li_4, 1, ">> Profit / Loss  : $ " + DoubleToStr(AccountEquity() - AccountBalance(), 2));
   f0_6("L15", "Arial", 15, 10, 425, Li_4, 1, " Rebate  : $ " + DoubleToStr(f0_13(), 2));
   ObjectCreate("j", OBJ_LABEL, 0, 0, 0);
   ObjectSet("j", OBJPROP_CORNER, 3);
   ObjectSet("j", OBJPROP_XDISTANCE, 10);
   ObjectSet("j", OBJPROP_YDISTANCE, 10);
   ObjectSetText("j", "© 2014 || DJONG LIONG FOI ", 15, "Mistral", color_0);
}

void f0_6(string A_name_0, string A_fontname_8, int A_fontsize_16, int A_x_20, int A_y_24, color A_color_28, int A_corner_32, string A_text_36) {
   if (ObjectFind(A_name_0) < 0) ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(A_name_0, A_text_36, A_fontsize_16, A_fontname_8, A_color_28);
   ObjectSet(A_name_0, OBJPROP_CORNER, A_corner_32);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_20);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_24);
}

int f0_10() {
   if (IsTesting()) return (1);
   if (IsTradeAllowed()) return (1);
   return (0);
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    | 
//+------------------------------------------------------------------------------------------------+