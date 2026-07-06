// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70958

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\PositionInfo.mqh>

// Includes
#include <trade\trade.mqh>
COrderInfo orderInfo;
CTrade     trade; 

#define DAILY_LIMITS

// NOTE: enums
// ------------------------------------------------------------------
enum CloseAllMode {
  CloseByMoney,
  CloseByAccountPercent
};
enum TSLMode { byPips,
               byATR }; 

input string EA_Name = "EA HOKKYDJONG";
input string Use_TradeAgai2n = "If => true,EA will trade again,If => false => EA will Off";
input bool TradeAgain = true;
input string Use_Loop = "Example = 10,EA will trader for 10 Laps";
input int Loop = 10000;
int trade_number;
input int StartTrade = 0;
input int EndTrade = 24;
input string Use_DbLots = "If = 1-> Use Multiplier Lot, If = 2-> Use Fixed Lot";
input int DbLots = 1;
input double Lots = 0.01;
input double SL = 0.0;
input double TP = 4.0;
input double Distance = 3.0;
input double Multiplier = 1.6;
input int MaxLevel = 20;
double Gd_176 = 3.0;
input double LotsDecimal = 2.0;
input int MagicNumber = 163991;
input bool OrderFilling = true;             // Order filling (enable if get "Unsupported filling mode" error)
input ENUM_ORDER_TYPE_FILLING OrderFillingMode = 0; // Order filling mode
input string EA_Comment = "ea_hokkydjong";
double net_take_profit;
double average_open_price;
double last_buy_price;
double last_sell_price;
datetime G_time_264 = 0;
int last_trades_count = 0;
double lot_size;
int i = 0;
int trades_count;
bool open_new = false;
bool open_buy = false;
bool open_sell = false;
ulong order_ticket;
bool move_net_take_profit = false;
int Gi_324 = 65535;
int Gi_328 = 65535;
int Gi_332 = 16776960;
double Gd_336;
input double MoneyPerLot = 1.7;

string IndicatorObjPrefix;

// NOTE: inputs
// ------------------------------------------------------------------

input string       tTailingStop            = "== TailingStop Setup ==";  // == TailingStop Setup ==
input bool         TslON                   = false;                       // TSL ON:
TSLMode            userTslMode             = byPips;                     // TSL Mode:
input int          userTslInitialStep      = 25;                         // TSL Initial Step:
input int          userTslStep             = 1;                          // TSL Step:
input int          userTslDistance         = 14;                         // TSL Distance:

// #ifdef DAILY_LIMITS

#define NEWS_FILTER_ON

#ifdef NEWS_FILTER_ON

input string TNEWS = "== News Setup ==";  // ————————————
input string note = "http://calendar.fxstreet.com/"; // You Must to allow this URL:
input bool               NEWS_FILTER = true;                      // News Filter On
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
            if(NEWS_FILTER == true && READ_NEWS(NEWS_TABLE) && ArraySize(NEWS_TABLE) > 0)
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
        if(NEWS_FILTER == false) return;

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
            if(NEWS_FILTER == false)
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
News news;
#endif


input string    Tlimits = "== Daily Limits Setup ==";  // == Daily Limits Setup ==
input bool      winLimitOn         = true;                        // Win Limit by Amount On:
input double    winLimit           = 1000;                        // Win Limit Amount:
input bool      winLimitPercentOn  = true;                        // Win Limit by account percent On:
input double    winLimitPercent    = 1;                           // Win Limit Percent:
input bool      lossLimitOn        = true;                        // Loss Limit On:
input double    lossLimit          = -100;                        // Loss Limit Amount:
input bool      lossLimitPercentOn = true;                        // Loss Limit by account percent On:
input double    lossLimitPercent   = -1;                          // Loss Limit Percent:

class Flag
{
   bool _state;
	
  public:
   Flag(bool iniState=true) { _state = iniState; }
   ~Flag() { ;}

	void SwitchToOpposite() { _state = !_state; }
	void Set(bool state) { _state = state; }
	void On() { _state = true; }
	void Off() { _state = false; }
	bool Now() { return _state; }
	
   bool isOn() { 
      if(_state == true) return true;
		return false;
   }
	bool isOff()
	{
	   if(_state == false) return true;
	
		return false;
   }

};
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

class LimitsProtector
{
  Stats  _stats;
  Flag   _botState;
  double _lossLimitAmount;
  double _winLimitAmount;
  double _lossLimitPercent;
  double _winLimitPercent;
  bool   _ctrlLoss;
  bool   _ctrlWin;
  bool   _ctrlLossPercent;
  bool   _ctrlWinPercent;

 public:
  // LimitsProtector(double LossLimit, double WinLimit, bool CtrlLosses = true, bool CtrlWin = true)
  LimitsProtector(double LossLimit, double WinLimit, double LossPercent, double WinPercent, bool CtrlLosses = true, bool CtrlWin = true, bool CtrlLossesPercent = true, bool CtrlWinPercent = true)
  {
    _lossLimitAmount  = LossLimit;
    _winLimitAmount   = WinLimit;
    _lossLimitPercent = LossPercent;
    _winLimitPercent  = WinPercent;
    _ctrlLoss         = CtrlLosses;
    _ctrlWin          = CtrlWin;
    _ctrlLossPercent  = CtrlLossesPercent;
    _ctrlWinPercent   = CtrlWinPercent;
    _stats.setDiasBack(10);
  }
  ~LimitsProtector() { ; }

  bool doControls()
  {
    if (_ctrlLoss == true && _lossLimitAmount < 0) { lossControl(); }
    if (_ctrlWin == true && _winLimitAmount > 0) { winControl(); }
    if (_ctrlLossPercent == true && _lossLimitPercent < 0) { lossControlPercent(); }
    if (_ctrlWinPercent == true && _winLimitPercent > 0) { winControlPercent(); }

    return _botState.Now();
  }

  bool lossControl()
  {
    _botState.On();
    double todayProfit = _stats.TodayProfit();
    if (todayProfit <= _lossLimitAmount) {
      Print("Loss Limit reached: ", todayProfit);
      _botState.Off();
    }
    return _botState.Now();
  }
  bool winControl()
  {
    _botState.On();
    double todayProfit = _stats.TodayProfit();
    if (todayProfit >= _winLimitAmount) {
      Print("Win Limit reached: ", todayProfit);
      _botState.Off();
    }
    return _botState.Now();
  }
  bool lossControlPercent()
  {
    _botState.On();

    double todayProfit = _stats.Today();
    if (todayProfit <= _lossLimitPercent) {
      Print("Loss Limit Percent reached: ", todayProfit, " %");
      _botState.Off();
    }
    return _botState.Now();
  }
  bool winControlPercent()
  {
    _botState.On();
    double todayProfit = _stats.Today();
    if (todayProfit >= _winLimitPercent) {
      Print("Win Limit Percent reached: ", todayProfit, " %");
      _botState.Off();
    }
    return _botState.Now();
  }
};
LimitsProtector limitsProtector(lossLimit, winLimit, lossLimitPercent, winLimitPercent, lossLimitOn, winLimitOn, lossLimitPercentOn, winLimitPercentOn);

// #endif

bool               closeAllInOpositeSignal = false;                      // CLose All In Oposite Signal
input string             TtpOptions              = "== Close All Options ==";  // == Close All Options ==
input bool               closeAllControlON       = false;                      // Close All Control ON:
input CloseAllMode       closeBy                 = CloseByMoney;               // Close All Mode:
input double             closeAllMoney           = 100;                        // Close by Money Winning $(+)
input double             closeAllMoneyLoss       = -100;                       // Close by Money Lossing $(-)
input double             accountPerWin           = 1;                          // Account Percent Win (+)
input double             accountPerLos           = -1;                         // Account Percent Loss(-)
input double             closeByPipsWin = 10;                         // Close Pips Win:
input double             closeByPipsLoss = 10;                         // Close Pips Loss:

#define BREAKEVEN_ON

#ifdef BREAKEVEN_ON
input string Tbk         = "== Breakeven Setup ==";  // ————————————
input bool   breakevenOn = false;                    // Breakeven On:
input double userBkvPips = 10;                        // Breakeven Pips
double userBkvStep = 3;                        // Breakeven Step
#else
string        Tbk                     = "== Breakeven Setup ==";    // == Breakeven Setup ==
bool          breakevenOn             = false;                      // Use Breakeven?
double        userBkvPips             = 10;                        // Breakeven Pips
double        userBkvStep             = 3;                        // Breakeven Step
#endif

// ------------------------------------------------------------------
string TFilters        = "== Filters Orders ==";  // ————————————
bool   filterSymbolsOn = true;                    // Symbols filter On:
string SymbolsList     = "GBPUSD,EURUSD";         // Symbols (separate by comma ","):
bool   filterMagicsOn  = true;                    // Use magic number filter?
string MagicsList      = "0";                     // Magics numbers (separate by comma ","):
int    magico          = MagicNumber;

// ------------------------------------------------------------------




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NamesCollision(const string name)
  {
   for(int k = ObjectsTotal(0); k >= 0; k--)
     {
      if(StringFind(ObjectName(0, k), name) == 0)
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorPrefix(const string target)
  {
   for(int i = 0; i < 1000; ++i)
     {
      string prefix = target + "_" + IntegerToString(i);
      if(!NamesCollision(prefix))
        {
         return prefix;
        }
     }
   return target;
  }

// clases
// ------------------------------------------------------------------
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
ConcurrentConditions conditionsToCloseBuy;
ConcurrentConditions conditionsToCloseSell;
ConcurrentConditions conditionsToBreackeven;

interface iActions
{
  bool doAction();
};
interface IOrders
{
    public:
    virtual void Add() = 0;
    virtual void Release() = 0;

    virtual bool AddOrder() = 0;
    virtual bool DeleteOrder() = 0;
    virtual bool Select() = 0;
};
class Order
{
    long            _id;
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
    bool     _bkvWasDoIt;
    int      _countPartials;

    public:
    Order(
        long            id,
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
        double          profit,
        bool            bkvWasDoIt,
        int             countPartials) : _id(id),
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
        _countPartials(countPartials)
    {}

    Order() {}
    ~Order() {}

    // clang-format off
    Order* id(long id) { _id = id; return &this; }
    Order* symbol(string symbol) { _symbol = symbol; return &this; }
    Order* price(double price) { _price = price; return &this; }
    Order* sl(double sl) { _sl = sl; return &this; }
    Order* tp(double tp) { _tp = tp; return &this; }
    Order* lot(double lot) { _lot = lot; return &this; }
    Order* type(ENUM_ORDER_TYPE type) { _type = type; return &this; }
    Order* type(long type) { _type = type; return &this; }
    Order* magic(int magic) { _magic = magic; return &this; }
    Order* comment(string comment) { _comment = comment; return &this; }
    Order* expireTime(datetime expireTm) { _expireTime = expireTm; return &this; }
    Order* signalTime(datetime signalTm) { _signalTime = signalTm; return &this; }
    Order* profit(double profit) { _profit = profit; return &this; }
    Order* strategy(string strategy) { _strategy = strategy; return &this; }
    Order* tslNext(double tslNext) { _tslNext = tslNext; return &this; }
    Order* breakevenWasDoIt(bool bkvWasDoIt) { _bkvWasDoIt = bkvWasDoIt; return &this; }
    Order* countPartials(int count) { _countPartials = _countPartials + count; return &this; }

    long           id() { return _id; }
    string         symbol() { return _symbol; }
    double         price() { return _price; }
    double         sl() { return _sl; }
    double         tp() { return _tp; }
    double         lot() { return _lot; }
    ENUM_ORDER_TYPE type() { return _type; }
    int            magic() { return _magic; }
    string         comment() { return _comment; }
    string         strategy() { return _strategy; }
    datetime       expireTime() { return _expireTime; }
    datetime       signalTime() { return _signalTime; }
    double         tslNext() { return _tslNext; }

    bool           breakevenWasDoIt() { return _bkvWasDoIt; }
    int            countPartials() { return _countPartials; }

    double         profit()
    {
        if(PositionSelectByTicket(_id))
            return PositionGetDouble(POSITION_PROFIT);
        return 0;
    }


};

// NOTE: class list
class OrdersList
{
    Order* orders [];
    bool    _filterByMagicOn;
    bool    _filterBySymbolsOn;
    long    _magics;
    string  _symbols;

    // FilterBySymbols* _symbols;
    // FilterByMagics*  _magics;

    public:
    OrdersList() { ; }
    OrdersList(bool FilterByMagicOn, long Magics, bool FilterBySymbolsOn, string Symbols)
    {
        _filterByMagicOn = FilterByMagicOn;
        _filterBySymbolsOn = FilterBySymbolsOn;
        _magics = Magics;
        _symbols = Symbols;
    }
    ~OrdersList()
    {
        clearList();
    }

    void setOrdersList(bool magicOn, string magics, bool symbolsOn, string symbols)
    {
        _filterByMagicOn = magicOn;
        _filterBySymbolsOn = symbolsOn;
        // _magics = new FilterByMagics(magics);
        // _symbols = new FilterBySymbols(symbols);
        _symbols = symbols;
        _magics = StringToInteger(magics);

    }

    // recorrer las ordenes de mercado y agregar las que no estén en el array
    //+------------------------------------------------------------------+
    void GetMarketOrders()
    {

        for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
            ulong  tk = PositionGetTicket(i);
            long   type = PositionGetInteger(POSITION_TYPE);
            string sym = PositionGetString(POSITION_SYMBOL);
            long   magic = PositionGetInteger(POSITION_MAGIC);

            // if (_filterByMagicOn) if (!_magics.control(magic)) { continue; }
            // if (_filterBySymbolsOn) if (!_symbols.control(sym)) { continue; }

                    // NOTE: uso por ahora este control para un solo magico y un solo symbolo:        
            if(_filterByMagicOn) if(_magics != magic) { continue; }
            if(_filterBySymbolsOn) if(sym != _symbols) { continue; }
            if(exist(tk) == true) { continue; }

            Order* newOrder = new Order();
            newOrder
                .id(tk)
                .symbol(sym)
                .price(PositionGetDouble(POSITION_PRICE_OPEN))
                .sl(PositionGetDouble(POSITION_SL))
                .tp(PositionGetDouble(POSITION_TP))
                .lot(PositionGetDouble(POSITION_VOLUME))
                .type(PositionGetInteger(POSITION_TYPE))
                .magic(magic)
                .comment(PositionGetString(POSITION_COMMENT))
                .expireTime(0)
                .signalTime(PositionGetInteger(POSITION_TIME))
                .breakevenWasDoIt(false)
                .countPartials(0);

            if(AddOrder(newOrder))
            {
                PrintOrder(i);
            }
        }
    }

    bool GetLastMarketOrder()
    {
        for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
            ulong  tk = PositionGetTicket(i);
            long   type = PositionGetInteger(POSITION_TYPE);
            string sym = PositionGetString(POSITION_SYMBOL);
            long   magic = PositionGetInteger(POSITION_MAGIC);

            // if (_filterByMagicOn) if (!_magics.control(magic)) { continue; }
            // if (_filterBySymbolsOn) if (!_symbols.control(sym)) { continue; }

                    // NOTE: uso por ahora este control para un solo magico y un solo symbolo:        
            if(_filterByMagicOn) if(_magics != magic) { continue; }
            if(_filterBySymbolsOn) if(sym != _symbols) { continue; }
            if(exist(tk) == true) { continue; }

            Order* newOrder = new Order();
            newOrder
                .id(tk)
                .symbol(sym)
                .price(PositionGetDouble(POSITION_PRICE_OPEN))
                .sl(PositionGetDouble(POSITION_SL))
                .tp(PositionGetDouble(POSITION_TP))
                .lot(PositionGetDouble(POSITION_VOLUME))
                .type(PositionGetInteger(POSITION_TYPE))
                .magic(magic)
                .comment(PositionGetString(POSITION_COMMENT))
                .expireTime(0)
                .signalTime(PositionGetInteger(POSITION_TIME))
                .breakevenWasDoIt(false)
                .countPartials(0);

            if(AddOrder(newOrder))
            {
                PrintOrder(i);
                return true;
            }
        }
        return false;
    }

    int qnt()
    {
        return ArraySize(orders);
    }

    long id(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].id();
        }
        return -1;
    }

    double profit(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].profit();
        }
        return -1;
    }

    bool exist(long id)
    {
        for(int i = qnt() - 1; i >= 0; i--)
        {
            // if (id(i) == id)
            if(orders[i].id() == id)
            {
                return true;
            }
        }
        return false;
    }

    bool AddOrder(Order* order)
    {
        int t = ArraySize(orders);
        if(ArrayResize(orders, t + 1)) {
            orders[t] = order;
            return true;
        }

        return false;
    }

    bool deleteOrder(int index)
    {
        if(notOverFlow(index)) { delete orders[index]; }

        if(qnt() > index) {
            for(int i = index; i < qnt() - 1; i++) {
                orders[i] = orders[i + 1];
            }
            ArrayResize(orders, qnt() - 1);
            return true;
        }

        return false;
    }

    void clearList()
    {
        for(int i = 0; i < qnt(); i++) {
            if(CheckPointer(orders[i]) != POINTER_INVALID) {
                deleteOrder(i);
            }
        }
    }

    Order* last()
    {
        int lastIndex = ArraySize(orders) - 1;
        if(lastIndex == -1) { return NULL; }

        return GetPointer(orders[lastIndex]);
    }

    bool notOverFlow(int index)
    {
        if(index > ArraySize(orders) - 1) return false;
        if(index < 0) return false;
        if(CheckPointer(orders[index]) == POINTER_INVALID) return false;

        return true;
    }

    void PrintOrder(const int index)
    {
        // clang-format off
        if(!notOverFlow(index)) { return; }
        if(CheckPointer(orders[index]) == POINTER_INVALID) { return; }

        Print("Order ", index, " id: ", orders[index].id());
        Print("Order ", index, " symbol: ", orders[index].symbol());
        Print("Order ", index, " type: ", orders[index].type());
        Print("Order ", index, " lot: ", orders[index].lot());
        Print("Order ", index, " price: ", orders[index].price());
        Print("Order ", index, " sl: ", orders[index].sl());
        Print("Order ", index, " tp: ", orders[index].tp());
        Print("Order ", index, " magic: ", orders[index].magic());
        Print("Order ", index, " comment: ", orders[index].comment());
        Print("Order ", index, " strategy: ", orders[index].strategy());
        Print("Order ", index, " expire time: ", orders[index].expireTime());
        Print("Order ", index, " signal time: ", orders[index].signalTime());
        Print("Order ", index, " profit: ", orders[index].profit());
        Print("Order ", index, " tslNext: ", orders[index].tslNext());
        // clang-format on
    }

    void PrintList()
    {
        for(int i = 0; i < qnt(); i++) {
            PrintOrder(i);
        }
    }

    // borra de la lista los trades cerrados
  // ——————————————————————————————————————————————————————————————————
  // void cleanCloseOrders()
  // {
  //   if (qnt() == 0) return;

  //   for (int i = 0; i < qnt(); i++)
  //   {
  //     if (isClose(i))
  //     {
  //       deleteOrder(i);
  //     }
  //   }
  // }

// comprueba si la orden está cerrada
  // ——————————————————————————————————————————————————————————————————
  // bool isClose(int index)
  // {
  //   if (notOverFlow(index))
  //   {
  //     if (OrderSelect(id(index))
  //     {
  //       if (OrderCloseTime() != 0) return true;
  //     }
  //   }
  //   return false;
  // }

    Order* index(int in)
    {
        return GetPointer(orders[in]);
    }

    void closeAllInList()
    {
        for(int x = PositionsTotal(); x >= 0; x--) {
            int tk = PositionGetTicket(x);
            trade.PositionClose(tk, 10);
        }
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
    double tp = 0;
    if (PositionSelectByTicket(tk)) tp = PositionGetDouble(POSITION_TP);

    if (!trade.PositionModify(tk, newSl, tp)) {
      Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " error:", GetLastError());
      } else {
        Print(__FUNCTION__, " trailing stop in tk: ", tk);
      }
    // }
  }
};
TrailingStop* tsl;

OrdersList MainOrders(filterMagicsOn, magico, filterSymbolsOn, Symbol());

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

class MoveSL : public iActions
{
    Order* _order;
    double _newSL;
    CTrade trade;

    public:
    MoveSL() { ; }
    ~MoveSL() { ; }

    MoveSL* order(Order* or )
    {
        _order = or ;
        return &this;
    }
    MoveSL* newSL(double newSL)
    {
        _newSL = newSL;
        return &this;
    }
    bool controlPointer(Order* or )
    {
        if(CheckPointer(or ))
        {
            return true;
        }
        else
        {
            Print("Order Pointer Invalid");
            return false;
        }
    }

    bool doAction()
    {
        if(!controlPointer(_order))
        {
            Print(__FUNCTION__, " ", "Can't Move Stop Loss");
            return false;
        }

        if(moveSL(_order.id(), _newSL))
        {
            return true;
        }

        return false;
    }

    bool moveSL(int tk, double newSl)
    {
        if(!trade.PositionModify(tk, newSl, 0))
        {

            Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " error:", GetLastError());
            return false;
        }
        else
        {
            _order.sl(_newSL);
            _order.breakevenWasDoIt(true);
            Print(__FUNCTION__, " ", _order.id(), " Modify: new SL: ", _newSL);
            return true;
        }

        return false;
    }
};
MoveSL* breackevenAction;

// NOTE: close Conditions
class ConditionToCloseBuy : public iConditions
{
 public:
  bool evaluate()
  {
    // if (closeAllInOpositeSignal) {
      // return conditionsToSell.EvaluateConditions();
    // }

		bool result=false;
    // TODO: armar CloseALlControl, ver equityProtection
    if (closeAllControlON) { result= CloseALlControl(); }
    
		if (!limitsProtector.doControls()) { result= true; }

		return result;
  }
};
ConditionToCloseBuy* conditionCloseBuy;

class ConditionToCloseSell : public iConditions
{
 public:
  bool evaluate()
  {
    // if (closeAllInOpositeSignal) {
      // return conditionsToBuy.EvaluateConditions();
    // }
    bool result=false;
    if (closeAllControlON) {
      result = CloseALlControl();
    }
		
		if (!limitsProtector.doControls()) { result = true; }
    
		return result;
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
    if (count >= _maxOrders) { return false; }

    return true;
  }
};
ConditionCountOrders* countOrders;

class BreackevenCondition : public iConditions
{
   Order* _order;

  public:
   void setOrder(Order* or)
   {
      _order = or ;
   }

   bool evaluate()
   {
      // si el precio actual coindide con el momento de hacer bk ret true
      double mPoints = SymbolInfoDouble(_order.symbol(), SYMBOL_POINT);
      double ask     = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
      double bid     = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);
      double dist    = userBkvPips * mPoints * 10;

      if (_order.type() == POSITION_TYPE_BUY)
      {
         if (bid >= _order.price() + dist)
         {
            return true;
         }
      }
      if (_order.type() == POSITION_TYPE_SELL)
      {
         if (ask <= _order.price() - dist)
         {
            return true;
         }
      }

      return false;
   }
};
BreackevenCondition* breackevenCondition;

// ------------------------------------------------------------------

// Market order builder v1.6
// Order side v1.1

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
  {
   BuySide,
   SellSide
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderSide GetOppositeSide(OrderSide side)
  {
   return side == BuySide ? SellSide : BuySide;
  }

#endif
// Action on condition logic v2.0

// Action on condition v3.0

// ICondition v3.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
  {
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
  };
#endif
// Action v2.0

#ifndef IAction_IMP

interface IAction
  {
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool DoAction(const int period, const datetime date) = 0;
  };
#define IAction_IMP
#endif

#ifndef ActionOnConditionController_IMP
#define ActionOnConditionController_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ActionOnConditionController
  {
   bool              _finished;
   ICondition        *_condition;
   IAction*          _action;
public:
                     ActionOnConditionController()
     {
      _action = NULL;
      _condition = NULL;
      _finished = true;
     }

                    ~ActionOnConditionController()
     {
      if(_action != NULL)
         _action.Release();
      if(_condition != NULL)
         _condition.Release();
     }

   bool              Set(IAction* action, ICondition *condition)
     {
      if(!_finished || action == NULL)
         return false;
      if(_action != NULL)
         _action.Release();
      _action = action;
      _action.AddRef();
      _finished = false;
      if(_condition != NULL)
         _condition.Release();
      _condition = condition;
      _condition.AddRef();
      return true;
     }

   void              DoLogic(const int period, const datetime date)
     {
      if(_finished)
         return;
      if(_condition.IsPass(period, date))
        {
         if(_action.DoAction(period, date))
            _finished = true;
        }
     }
  };

#endif

#ifndef ActionOnConditionLogic_IMP
#define ActionOnConditionLogic_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ActionOnConditionLogic
  {
   ActionOnConditionController* _controllers[];
public:
                    ~ActionOnConditionLogic()
     {
      int count = ArraySize(_controllers);
      for(int i = 0; i < count; ++i)
        {
         delete _controllers[i];
        }
     }

   void              DoLogic(const int period, const datetime date)
     {
      int count = ArraySize(_controllers);
      for(int i = 0; i < count; ++i)
        {
         _controllers[i].DoLogic(period, date);
        }
     }

   bool              AddActionOnCondition(IAction* action, ICondition* condition)
     {
      int count = ArraySize(_controllers);
      for(int i = 0; i < count; ++i)
        {
         if(_controllers[i].Set(action, condition))
            return true;
        }
      ArrayResize(_controllers, count + 1);
      _controllers[count] = new ActionOnConditionController();
      return _controllers[count].Set(action, condition);
     }
  };

#endif

#ifndef MarketOrderBuilder_IMP
#define MarketOrderBuilder_IMP
class MarketOrderBuilder
  {
   OrderSide         _orderSide;
   string            _instrument;
   double            _amount;
   double            _rate;
   int               _slippage;
   double            _stop;
   double            _limit;
   int               _magicNumber;
   string            _comment;
   bool              _ecnBroker;
   ActionOnConditionLogic* _actions;
public:
                     MarketOrderBuilder(ActionOnConditionLogic* actions)
     {
      _ecnBroker = false;
      _actions = actions;
      _amount = 0;
      _rate = 0;
      _slippage = 0;
      _stop = 0;
      _limit = 0;
      _magicNumber = 0;
     }

   // Sets ECN broker flag
   MarketOrderBuilder* SetECNBroker(bool isEcn) { _ecnBroker = isEcn; return &this; }
   MarketOrderBuilder* SetComment(const string comment) { _comment = comment; return &this; }
   MarketOrderBuilder* SetSide(const OrderSide orderSide) { _orderSide = orderSide; return &this; }
   MarketOrderBuilder* SetInstrument(const string instrument) { _instrument = instrument; return &this; }
   MarketOrderBuilder* SetAmount(const double amount) { _amount = amount; return &this; }
   MarketOrderBuilder* SetSlippage(const int slippage) { _slippage = slippage; return &this; }
   MarketOrderBuilder* SetStopLoss(const double stop) { _stop = stop; return &this; }
   MarketOrderBuilder* SetTakeProfit(const double limit) { _limit = limit; return &this; }
   MarketOrderBuilder* SetMagicNumber(const int magicNumber) { _magicNumber = magicNumber; return &this; }

   ulong             Execute(string &error)
     {
      int tradeMode = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_MODE);
      switch(tradeMode)
        {
         case SYMBOL_TRADE_MODE_DISABLED:
            error = "Trading is disbled";
            return 0;
         case SYMBOL_TRADE_MODE_CLOSEONLY:
            error = "Only close is allowed";
            return 0;
         case SYMBOL_TRADE_MODE_SHORTONLY:
            if(_orderSide == BuySide)
              {
               error = "Only short are allowed";
               return 0;
              }
            break;
         case SYMBOL_TRADE_MODE_LONGONLY:
            if(_orderSide == SellSide)
              {
               error = "Only long are allowed";
               return 0;
              }
            break;
        }
      ENUM_ORDER_TYPE orderType = _orderSide == BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      int digits = (int)SymbolInfoInteger(_instrument, SYMBOL_DIGITS);
      double rate = _orderSide == BuySide ? SymbolInfoDouble(_instrument, SYMBOL_ASK) : SymbolInfoDouble(_instrument, SYMBOL_BID);
      double ticksize = SymbolInfoDouble(_instrument, SYMBOL_TRADE_TICK_SIZE);
      MqlTradeRequest request;
      ZeroMemory(request);
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _instrument;
      request.type = orderType;
      request.volume = _amount;
      request.price = MathRound(rate / ticksize) * ticksize;
      request.deviation = _slippage;
      request.sl = MathRound(_stop / ticksize) * ticksize;
      request.tp = MathRound(_limit / ticksize) * ticksize;
      request.magic = _magicNumber;
      if(_comment != "")
         request.comment = _comment;
       if(OrderFilling)
           request.type_filling = OrderFillingMode;
      MqlTradeResult result;
      ZeroMemory(result);
      bool res = OrderSend(request, result);
      switch(result.retcode)
        {
         case TRADE_RETCODE_INVALID_FILL:
            error = "Invalid order filling type";
            return 0;
         case TRADE_RETCODE_LONG_ONLY:
            error = "Only long trades are allowed for " + _instrument;
            return 0;
         case TRADE_RETCODE_INVALID_VOLUME:
           {
            double minVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MIN);
            error = "Invalid volume in the request. Min volume is: " + DoubleToString(minVolume);
           }
         return 0;
         case TRADE_RETCODE_INVALID_PRICE:
            error = "Invalid price in the request";
            return 0;
         case TRADE_RETCODE_INVALID_STOPS:
           {
            int filling = (int)SymbolInfoInteger(_instrument, SYMBOL_ORDER_MODE);
            if((filling & SYMBOL_ORDER_SL) != SYMBOL_ORDER_SL)
              {
               error = "Stop loss in now allowed for " + _instrument;
               return 0;
              }
            int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
            double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
            double price = request.stoplimit > 0.0 ? request.stoplimit : request.price;
            if(MathRound(MathAbs(price - request.sl) / point) < minStopDistancePoints)
              {
               error = "Your stop level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
              }
            else
              {
               error = "Invalid stops in the request";
              }
           }
         return 0;
         case TRADE_RETCODE_DONE:
            break;
         default:
            error = "Unknown error: " + IntegerToString(result.retcode);
            return 0;
        }
      return result.order;
     }
  };
#endif
// Trading calculator v.1.3

// Position size type

#ifndef PositionSizeType_IMP
#define PositionSizeType_IMP

enum PositionSizeType
  {
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
   PositionSizeMoneyPerPip, // $ per pip
   PositionSizeRiskCurrency // Risk in $
  };

#endif
// Stop/limit type v1.0

#ifndef StopLimitType_IMP
#define StopLimitType_IMP

enum StopLimitType
  {
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $,
   StopLimitRiskReward, // Set in % of stop loss (take profit only)
   StopLimitAbsolute // Set in absolite value (rate)
  };

#endif

// Symbol info v1.3

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class InstrumentInfo
  {
   string            _symbol;
   double            _mult;
   double            _point;
   double            _pipSize;
   int               _digit;
   double            _ticksize;
public:
                     InstrumentInfo(const string symbol)
     {
      _symbol = symbol;
      _point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      _digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _ticksize = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), _digit);
     }

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int               CompareLots(double lot1, double lot2)
     {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if(lotStep == 0)
        {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
        }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
     }

   static double     GetPipSize(const string symbol)
     {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double mult = digit == 3 || digit == 5 ? 10 : 1;
      return point * mult;
     }
   double            GetPointSize() { return _point; }
   double            GetPipSize() { return _pipSize; }
   int               GetDigits() { return _digit; }
   string            GetSymbol() { return _symbol; }
   static double     GetBid(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_BID); }
   static double     GetAsk(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
   double            GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double            GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double            GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double            RoundRate(const double rate)
     {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
     }

   double            RoundLots(const double lots)
     {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if(lotStep == 0)
        {
         return 0.0;
        }
      return floor(lots / lotStep) * lotStep;
     }

   double            LimitLots(const double lots)
     {
      double minVolume = GetMinLots();
      if(minVolume > lots)
        {
         return 0.0;
        }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if(maxVolume < lots)
        {
         return maxVolume;
        }
      return lots;
     }

   double            NormalizeLots(const double lots)
     {
      return LimitLots(RoundLots(lots));
     }
  };

#endif
// Trades iterator v 1.3

// Compare type v1.0

#ifndef CompareType_IMP
#define CompareType_IMP

enum CompareType
  {
   CompareLessThan
  };

#endif

#ifndef TradesIterator_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradesIterator
  {
   bool              _useMagicNumber;
   int               _magicNumber;
   int               _orderType;
   bool              _useSide;
   bool              _isBuySide;
   int               _lastIndex;
   bool              _useSymbol;
   string            _symbol;
   bool              _useProfit;
   double            _profit;
   CompareType       _profitCompare;
   string            _comment;
public:
                     TradesIterator()
     {
      _comment = NULL;
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useProfit = false;
     }

   TradesIterator*   WhenComment(string comment)
     {
      _comment = comment;
      return &this;
     }

   void              WhenSymbol(const string symbol)
     {
      _useSymbol = true;
      _symbol = symbol;
     }

   void              WhenProfit(const double profit, const CompareType compare)
     {
      _useProfit = true;
      _profit = profit;
      _profitCompare = compare;
     }

   void              WhenSide(const bool isBuy)
     {
      _useSide = true;
      _isBuySide = isBuy;
     }

   void              WhenMagicNumber(const int magicNumber)
     {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
     }

   ulong             GetTicket() { return PositionGetTicket(_lastIndex); }
   double            GetLots() { return PositionGetDouble(POSITION_VOLUME); }
   double            GetSwap() { return PositionGetDouble(POSITION_SWAP); }
   double            GetProfit() { return PositionGetDouble(POSITION_PROFIT); }
   double            GetOpenPrice() { return PositionGetDouble(POSITION_PRICE_OPEN); }
   double            GetStopLoss() { return PositionGetDouble(POSITION_SL); }
   double            GetTakeProfit() { return PositionGetDouble(POSITION_TP); }
   ENUM_POSITION_TYPE GetPositionType() { return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); }
   bool              IsBuyOrder() { return GetPositionType() == POSITION_TYPE_BUY; }
   string            GetSymbol() { return PositionGetSymbol(_lastIndex); }

   int               Count()
     {
      int count = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PassFilter(i))
           {
            count++;
           }
        }
      return count;
     }

   bool              Next()
     {
      if(_lastIndex == INT_MIN)
        {
         _lastIndex = PositionsTotal() - 1;
        }
      else
         _lastIndex = _lastIndex - 1;
      while(_lastIndex >= 0)
        {
         ulong ticket = PositionGetTicket(_lastIndex);
         if(PositionSelectByTicket(ticket) && PassFilter(_lastIndex))
            return true;
         _lastIndex = _lastIndex - 1;
        }
      return false;
     }

   bool              Any()
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PassFilter(i))
           {
            return true;
           }
        }
      return false;
     }

   ulong             First()
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PassFilter(i))
           {
            return ticket;
           }
        }
      return 0;
     }

private:
   bool              PassFilter(const int index)
     {
      if(_useMagicNumber && PositionGetInteger(POSITION_MAGIC) != _magicNumber)
         return false;
      if(_useSymbol && PositionGetSymbol(index) != _symbol)
         return false;
      if(_useProfit)
        {
         switch(_profitCompare)
           {
            case CompareLessThan:
               if(PositionGetDouble(POSITION_PROFIT) >= _profit)
                  return false;
               break;
           }
        }
      if(_useSide)
        {
         ENUM_POSITION_TYPE positionType = GetPositionType();
         if(_isBuySide && positionType != POSITION_TYPE_BUY)
            return false;
         if(!_isBuySide && positionType != POSITION_TYPE_SELL)
            return false;
        }
      if(_comment != NULL)
        {
         if(_comment != PositionGetString(POSITION_COMMENT))
            return false;
        }
      return true;
     }
  };
#define TradesIterator_IMP
#endif

#ifndef TradingCalculator_IMP
#define TradingCalculator_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradingCalculator
  {
   InstrumentInfo    *_symbolInfo;
public:
   static TradingCalculator* Create(string symbol)
     {
      return new TradingCalculator(symbol);
     }

                     TradingCalculator(const string symbol)
     {
      _symbolInfo = new InstrumentInfo(symbol);
     }

                    ~TradingCalculator()
     {
      delete _symbolInfo;
     }

   InstrumentInfo    *GetSymbolInfo()
     {
      return _symbolInfo;
     }

   double            GetBreakevenPrice(const bool isBuy, const int magicNumber)
     {
      string symbol = _symbolInfo.GetSymbol();
      double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      double price = isBuy ? _symbolInfo.GetBid() : _symbolInfo.GetAsk();
      double totalPL = 0;
      double totalAmount = 0;
      TradesIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(symbol);
      it1.WhenSide(isBuy);
      while(it1.Next())
        {
         double orderLots = PositionGetDouble(POSITION_VOLUME);
         totalAmount += orderLots / lotStep;
         double openPrice = it1.GetOpenPrice();
         if(isBuy)
            totalPL += (price - openPrice) * (orderLots / lotStep);
         else
            totalPL += (openPrice - price) * (orderLots / lotStep);
        }
      if(totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return isBuy ? price + shift : price - shift;
     }

   double            CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
     {
      int direction = isBuy ? 1 : -1;
      switch(takeProfitType)
        {
         case StopLimitPercent:
            return basePrice + basePrice * takeProfit / 100.0 * direction;
         case StopLimitPips:
            return basePrice + takeProfit * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice + CalculateSLShift(amount, takeProfit) * direction;
        }
      return 0.0;
     }

   double            CalculateStopLoss(const bool isBuy, const double stopLoss, const StopLimitType stopLossType, const double amount, double basePrice)
     {
      int direction = isBuy ? 1 : -1;
      switch(stopLossType)
        {
         case StopLimitPercent:
            return basePrice - basePrice * stopLoss / 100.0 * direction;
         case StopLimitPips:
            return basePrice - stopLoss * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice - CalculateSLShift(amount, stopLoss) * direction;
        }
      return 0.0;
     }

   double            GetLots(PositionSizeType lotsType, double lotsValue, const OrderSide orderSide, const double price, double stopDistance)
     {
      switch(lotsType)
        {
         case PositionSizeMoneyPerPip:
           {
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double mult = _symbolInfo.GetPipSize() / _symbolInfo.GetPointSize();
            double lots = RoundLots(lotsValue / (unitCost * mult));
            return LimitLots(lots);
           }
         case PositionSizeAmount:
            return GetLotsForMoney(orderSide, price, lotsValue);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(orderSide, price, AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0);
         case PositionSizeRisk:
           {
            double affordableLoss = AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0;
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
            double possibleLoss = unitCost * stopDistance / tickSize;
            if(possibleLoss <= 0.01)
               return 0;
            return LimitLots(RoundLots(affordableLoss / possibleLoss));
           }
        }
      return lotsValue;
     }

   bool              IsLotsValid(const double lots, PositionSizeType lotsType, string &error)
     {
      switch(lotsType)
        {
         case PositionSizeContract:
            return IsContractLotsValid(lots, error);
        }
      return true;
     }

   double            NormilizeLots(double lots)
     {
      return LimitLots(RoundLots(lots));
     }

private:
   bool              IsContractLotsValid(const double lots, string &error)
     {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if(minVolume > lots)
        {
         error = "Min. allowed lot size is " + DoubleToString(minVolume);
         return false;
        }
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if(maxVolume < lots)
        {
         error = "Max. allowed lot size is " + DoubleToString(maxVolume);
         return false;
        }
      return true;
     }

   double            GetLotsForMoney(const OrderSide orderSide, const double price, const double money)
     {
      ENUM_ORDER_TYPE orderType = orderSide != BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      string symbol = _symbolInfo.GetSymbol();
      double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double marginRequired;
      if(!OrderCalcMargin(orderType, symbol, minVolume, price, marginRequired))
        {
         return 0.0;
        }
      if(marginRequired <= 0.0)
        {
         Print("Margin is 0. Server misconfiguration?");
         return 0.0;
        }
      double lots = RoundLots(money / marginRequired);
      return LimitLots(lots);
     }

   double            RoundLots(const double lots)
     {
      double lotStep = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_STEP);
      if(lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
     }

   double            LimitLots(const double lots)
     {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if(minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if(maxVolume < lots)
         return maxVolume;
      return lots;
     }

   double            CalculateSLShift(const double amount, const double money)
     {
      double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
      return (money / (unitCost / tickSize)) / amount;
     }
  };

#endif
// Trading commands v.2.0





// Orders iterator v1.9

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrdersIterator
  {
   bool              _useMagicNumber;
   int               _magicNumber;
   bool              _useOrderType;
   ENUM_ORDER_TYPE   _orderType;
   bool              _useSide;
   bool              _isBuySide;
   int               _lastIndex;
   bool              _useSymbol;
   string            _symbol;
   bool              _usePendingOrder;
   bool              _pendingOrder;
   bool              _useComment;
   string            _comment;
   CompareType       _profitCompare;
public:
                     OrdersIterator()
     {
      _useOrderType = false;
      _useMagicNumber = false;
      _usePendingOrder = false;
      _pendingOrder = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useComment = false;
     }

   OrdersIterator    *WhenPendingOrder()
     {
      _usePendingOrder = true;
      _pendingOrder = true;
      return &this;
     }

   OrdersIterator    *WhenSymbol(const string symbol)
     {
      _useSymbol = true;
      _symbol = symbol;
      return &this;
     }

   OrdersIterator    *WhenSide(const OrderSide side)
     {
      _useSide = true;
      _isBuySide = side == BuySide;
      return &this;
     }

   OrdersIterator    *WhenOrderType(const ENUM_ORDER_TYPE orderType)
     {
      _useOrderType = true;
      _orderType = orderType;
      return &this;
     }

   OrdersIterator    *WhenMagicNumber(const int magicNumber)
     {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
      return &this;
     }

   OrdersIterator    *WhenComment(const string comment)
     {
      _useComment = true;
      _comment = comment;
      return &this;
     }

   long              GetMagicNumger() { return OrderGetInteger(ORDER_MAGIC); }
   ENUM_ORDER_TYPE   GetType() { return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); }
   string            GetSymbol() { return OrderGetString(ORDER_SYMBOL); }
   string            GetComment() { return OrderGetString(ORDER_COMMENT); }
   ulong             GetTicket() { return OrderGetTicket(_lastIndex); }
   double            GetOpenPrice() { return OrderGetDouble(ORDER_PRICE_OPEN); }
   double            GetStopLoss() { return OrderGetDouble(ORDER_SL); }
   double            GetTakeProfit() { return OrderGetDouble(ORDER_TP); }

   int               Count()
     {
      int count = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && PassFilter())
            count++;
        }
      return count;
     }

   bool              Next()
     {
      if(_lastIndex == INT_MIN)
         _lastIndex = OrdersTotal() - 1;
      else
         _lastIndex = _lastIndex - 1;
      while(_lastIndex >= 0)
        {
         ulong ticket = OrderGetTicket(_lastIndex);
         if(OrderSelect(ticket) && PassFilter())
            return true;
         _lastIndex = _lastIndex - 1;
        }
      return false;
     }

   bool              Any()
     {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && PassFilter())
            return true;
        }
      return false;
     }

   ulong             First()
     {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && PassFilter())
            return ticket;
        }
      return -1;
     }

private:
   bool              PassFilter()
     {
      if(_useMagicNumber && GetMagicNumger() != _magicNumber)
         return false;
      if(_useOrderType && GetType() != _orderType)
         return false;
      if(_useSymbol && OrderGetString(ORDER_SYMBOL) != _symbol)
         return false;
      if(_usePendingOrder && !IsPendingOrder())
         return false;
      if(_useComment && OrderGetString(ORDER_COMMENT) != _comment)
         return false;
      return true;
     }

   bool              IsPendingOrder()
     {
      switch(GetType())
        {
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_STOP_LIMIT:
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
         case ORDER_TYPE_SELL_STOP_LIMIT:
            return true;
        }
      return false;
     }
  };
#endif

#ifndef tradeManager_INSTANCE
#define tradeManager_INSTANCE
// #include <Trade\Trade.mqh>
CTrade tradeManager;
#endif

#ifndef TradingCommands_IMP
#define TradingCommands_IMP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradingCommands
  {
public:
   static bool       MoveSLTP(const ulong ticket, const double stopLoss, double takeProfit, string &error)
     {
      if(!PositionSelectByTicket(ticket))
        {
         error = "Invalid ticket";
         return false;
        }
      return tradeManager.PositionModify(ticket, stopLoss, takeProfit);
     }

   static bool       MoveSL(const ulong ticket, const double stopLoss, string &error)
     {
      if(!PositionSelectByTicket(ticket))
        {
         error = "Invalid ticket";
         return false;
        }
      return tradeManager.PositionModify(ticket, stopLoss, PositionGetDouble(POSITION_TP));
     }

   static bool       MoveTP(const ulong ticket, const double takeProfit, string &error)
     {
      if(!PositionSelectByTicket(ticket))
        {
         error = "Invalid ticket";
         return false;
        }
      return tradeManager.PositionModify(ticket, PositionGetDouble(POSITION_SL), takeProfit);
     }

   static void       DeleteOrders(const int magicNumber, const string symbol)
     {
      OrdersIterator it();
      it.WhenMagicNumber(magicNumber);
      it.WhenSymbol(symbol);
      while(it.Next())
        {
         tradeManager.OrderDelete(it.GetTicket());
        }
     }

   static bool       CloseTrade(ulong ticket, string error)
     {
      if(!tradeManager.PositionClose(ticket))
        {
         error = IntegerToString(GetLastError());
         return false;
        }
      return true;
     }

   static int        CloseTrades(TradesIterator &it)
     {
      int close = 0;
      while(it.Next())
        {
         string error;
         if(!CloseTrade(it.GetTicket(), error))
            Print("LastError = ", error);
         else
            ++close;
        }
      return close;
     }
  };

#endif
// Closed trades iterator v 1.2
#ifndef ClosedTradesIterator_IMP
class ClosedTradesIterator
  {
   int               _lastIndex;
   int               _total;
   ulong             _currentTicket;
   string            _symbol;
   int               _magicNumber;
public:
                     ClosedTradesIterator()
     {
      _lastIndex = INT_MIN;
      _magicNumber = 0;
     }

   void              WhenSymbol(string symbol)
     {
      _symbol = symbol;
     }

   void              WhenMagicNumber(int magicNumber)
     {
      _magicNumber = magicNumber;
     }

   ulong             GetTicket() { return _currentTicket; }
   ENUM_DEAL_TYPE    GetPositionType() { return (ENUM_DEAL_TYPE)HistoryDealGetInteger(_currentTicket, DEAL_TYPE); }
   string            GetSymbol() { return HistoryDealGetString(_currentTicket, DEAL_SYMBOL); }
   datetime          GetCloseTime() { return (datetime)HistoryDealGetInteger(_currentTicket, DEAL_TIME); }
   int               GetMagicNumber() { return HistoryDealGetInteger(_currentTicket, DEAL_MAGIC); }
   double            GetProfit() { return HistoryDealGetDouble(_currentTicket, DEAL_PROFIT); }
   double            GetLots() { return HistoryDealGetDouble(_currentTicket, DEAL_VOLUME); }

   int               Count()
     {
      int count = 0;
      for(int i = 0; i < Total(); i--)
        {
         _currentTicket = HistoryDealGetTicket(i);
         if(PassFilter(i))
           {
            count++;
           }
        }
      return count;
     }

   bool              Next()
     {
      _total = Total();
      if(_lastIndex == INT_MIN)
         _lastIndex = 0;
      else
         ++_lastIndex;
      while(_lastIndex != _total)
        {
         _total = Total();
         _currentTicket = HistoryDealGetTicket(_lastIndex);
         if(PassFilter(_lastIndex))
            return true;
         ++_lastIndex;
        }
      return false;
     }

   bool              Any()
     {
      for(int i = 0; i < Total(); i++)
        {
         _currentTicket = HistoryDealGetTicket(i);
         if(PassFilter(i))
           {
            return true;
           }
        }
      return false;
     }

private:
   int               Total()
     {
      bool res = HistorySelect(0, TimeCurrent());
      return HistoryDealsTotal();
     }

   bool              PassFilter(const int index)
     {
      long entry = HistoryDealGetInteger(_currentTicket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT)
        {
         return false;
        }
      if(_symbol != NULL && GetSymbol() != _symbol)
        {
         return false;
        }
      if(_magicNumber != 0 && GetMagicNumber() != _magicNumber)
        {
         return false;
        }
      return true;
     }
  };
#define ClosedTradesIterator_IMP
#endif


InstrumentInfo* instrument;
ActionOnConditionLogic* actions;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {

#ifdef NEWS_FILTER_ON
    news.OnInit();
#endif

   IndicatorObjPrefix = GenerateIndicatorPrefix("EA_Price_Action");
   actions = new ActionOnConditionLogic();
   instrument = new InstrumentInfo(_Symbol);

	 tsl = new TrailingStop(GetPointer(MainOrders), byPips);
	 conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());
	 conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());

     //--- CONDITIONS TO BREAKEVEN:
  conditionsToBreackeven.AddCondition(breackevenCondition = new BreackevenCondition());

   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   delete actions;
   delete instrument;
   #ifdef NEWS_FILTER_ON
    news.OnDeinit(reason);
    #endif
}

void OnTimer(void)
{
    #ifdef NEWS_FILTER_ON
        news.OnTimer();
#endif
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Hour()
  {
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.hour;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Seconds()
  {
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.sec;
  }

// NOTE: tick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{

    #ifdef NEWS_FILTER_ON
        news.OnTick();
        if(news.StopForNews()) return;
    #endif
    
    if(TslON) tsl.doTSL();
    if (breakevenOn) doBreackevenAction();

    MainOrders.GetMarketOrders();

	  if (conditionsToCloseBuy.EvaluateConditions()) { closeAll("buy"); }
	  if (conditionsToCloseSell.EvaluateConditions()) { closeAll("sell"); }

		if (!limitsProtector.doControls()) { return; }

   double close_2;
   double close_1;
   double total_lots;
   DrawDashboard();
   if(G_time_264 == iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0))
      return;
   G_time_264 = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   TradesIterator trades;
   trades.WhenSymbol(_Symbol);
   trades.WhenMagicNumber(MagicNumber);
   while(trades.Next())
     {
      if(trades.IsBuyOrder())
        {
         open_buy = true;
         open_sell = false;
         break;
        }
      else
        {
         open_buy = false;
         open_sell = true;
         break;
        }
     }
   if(trades_count > 0 && trades_count <= MaxLevel)
     {
      last_buy_price = LastBuyPrice();
      last_sell_price = LastSellPrice();
      if(open_buy && last_buy_price - instrument.GetAsk() >= Distance * instrument.GetPipSize())
         open_new = true;
      if(open_sell && instrument.GetBid() - last_sell_price >= Distance * instrument.GetPipSize())
         open_new = true;
     }
   if(trades_count < 1)
     {
      open_sell = false;
      open_buy = false;
      open_new = true;
     }
   if(open_new)
     {
      last_buy_price = LastBuyPrice();
      last_sell_price = LastSellPrice();
      if(open_sell)
        {
         lot_size = CalcLot();
         last_trades_count = trades_count;
         if(lot_size > 0.0)
           {
            order_ticket = OpenOrder(false, lot_size, Gd_176, 0, EA_Comment + "-" + last_trades_count, MagicNumber);
            if(order_ticket < 0)
              {
               return;
              }
            last_sell_price = LastSellPrice();
            open_new = false;
            move_net_take_profit = true;
           }
        }
      else
        {
         if(open_buy)
           {
            lot_size = CalcLot();
            last_trades_count = trades_count;
            if(lot_size > 0.0)
              {
               order_ticket = OpenOrder(true, lot_size, Gd_176, 0, EA_Comment + "-" + last_trades_count, MagicNumber);
               if(order_ticket < 0)
                 {
                  return;
                 }
               last_buy_price = LastBuyPrice();
               open_new = false;
               move_net_take_profit = true;
              }
           }
        }
     }
   if(Hour() >= StartTrade && Hour() < EndTrade)
     {
      if(trade_number < Loop && TradeAgain)
        {
         if(open_new && trades_count < 1)
           {
            close_2 = iClose(Symbol(), 0, 2);
            close_1 = iClose(Symbol(), 0, 1);
            if((!open_sell) && (!open_buy))
              {
               last_trades_count = trades_count;
               if(close_2 > close_1)
                 {
                  lot_size = CalcLot();
                  if(lot_size > 0.0)
                    {
                     order_ticket = OpenOrder(false, lot_size, Gd_176, 0, EA_Comment + "-" + last_trades_count, MagicNumber);
                     trade_number++;
                     if(order_ticket == 0)
                       {
                        return;
                       }
                     last_buy_price = LastBuyPrice();
                     move_net_take_profit = true;
                    }
                 }
               else
                 {
                  lot_size = CalcLot();
                  if(lot_size > 0.0)
                    {
                     order_ticket = OpenOrder(true, lot_size, Gd_176, 0, EA_Comment + "-" + last_trades_count, MagicNumber);
                     trade_number++;
                     if(order_ticket == 0)
                       {
                        return;
                       }
                     last_sell_price = LastSellPrice();
                     move_net_take_profit = true;
                    }
                 }
              }
           }
        }
     }
   if(move_net_take_profit)
     {
      average_open_price = 0;
      total_lots = 0;
      TradesIterator trades2;
      trades2.WhenSymbol(_Symbol);
      trades2.WhenMagicNumber(MagicNumber);
      while(trades2.Next())
        {
         average_open_price += trades2.GetOpenPrice() * trades2.GetLots();
         total_lots += trades2.GetLots();
         if(trades2.IsBuyOrder())
           {
            net_take_profit = average_open_price + TP * instrument.GetPipSize();
           }
         else
           {
            net_take_profit = average_open_price - TP * instrument.GetPipSize();
           }
        }
      InstrumentInfo instrument(_Symbol);
      if(total_lots > 0)
         average_open_price = instrument.RoundRate(average_open_price / total_lots);
      TradesIterator trades3;
      trades3.WhenSymbol(_Symbol);
      trades3.WhenMagicNumber(MagicNumber);
      while(trades3.Next())
        {
         string error;
         if(!TradingCommands::MoveTP(trades3.GetTicket(), net_take_profit, error))
           {
            Print(error);
           }
         move_net_take_profit = false;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcLot()
  {
   double lots_4;
   int datetime_12;
   switch(DbLots)
     {
      case 0:
         lots_4 = Lots;
         break;
      case 1:
         lots_4 = NormalizeDouble(Lots * MathPow(Multiplier, last_trades_count), LotsDecimal);
         break;
      case 2:
        {
         datetime_12 = 0;
         lots_4 = Lots;
         ClosedTradesIterator it();
         it.WhenSymbol(_Symbol);
         it.WhenMagicNumber(MagicNumber);
         while(it.Next())
           {
            if(datetime_12 < it.GetCloseTime())
              {
               datetime_12 = it.GetCloseTime();
               if(it.GetProfit() < 0.0)
                 {
                  lots_4 = NormalizeDouble(it.GetLots() * Multiplier, LotsDecimal);
                  continue;
                 }
               lots_4 = Lots;
              }
           }
        }
     }
   return (lots_4);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int count_0 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)
         && PositionGetString(POSITION_SYMBOL) == _Symbol
         && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
        {
         count_0++;
        }
     }
   return count_0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong OpenOrder(bool isBuy, double A_lots_4, int A_slippage_20, int Ai_36, string A_comment_40, int A_magic_48)
  {
   MarketOrderBuilder* builder = new MarketOrderBuilder(actions);
   builder.SetSide(isBuy ? BuySide : SellSide);
   builder.SetInstrument(_Symbol);
   builder.SetAmount(A_lots_4);
   builder.SetSlippage(A_slippage_20);
   TradingCalculator* calc = TradingCalculator::Create(_Symbol);
   if(SL > 0)
     {
      builder.SetStopLoss(calc.CalculateStopLoss(isBuy, SL, StopLimitPips, A_lots_4, isBuy ? instrument.GetAsk() : instrument.GetBid()));
     }
   builder.SetTakeProfit(calc.CalculateTakeProfit(isBuy, Ai_36, StopLimitPips,  A_lots_4, isBuy ? instrument.GetAsk() : instrument.GetBid()));
   delete calc;
   builder.SetMagicNumber(A_magic_48);
   builder.SetComment(A_comment_40);
   string error;
   ulong ticket = builder.Execute(error);
   if(ticket == 0)
     {
      Print(error);
     }
   return ticket;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastBuyPrice()
  {
   double order_open_price_0;
   ulong ticket_8;
   ulong ticket_20 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)
         && PositionGetString(POSITION_SYMBOL) == _Symbol
         && PositionGetInteger(POSITION_MAGIC) == MagicNumber
         && PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY)
        {
         if(ticket > ticket_20)
           {
            order_open_price_0 = PositionGetDouble(POSITION_PRICE_OPEN);
            ticket_20 = ticket;
           }
        }
     }
   return order_open_price_0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastSellPrice()
  {
   double order_open_price_0;
   ulong ticket_8;
   ulong ticket_20 = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)
         && PositionGetString(POSITION_SYMBOL) == _Symbol
         && PositionGetInteger(POSITION_MAGIC) == MagicNumber
         && PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL)
        {
         if(ticket > ticket_20)
           {
            order_open_price_0 = PositionGetDouble(POSITION_PRICE_OPEN);
            ticket_20 = ticket;
           }
        }
     }
   return order_open_price_0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetCurrentProfit()
  {
   Gd_336 = 0;
   double Ld_ret_0 = 0;
   bool res = HistorySelect(0, TimeCurrent());
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY)
        {
         Gd_336 += HistoryDealGetDouble(ticket, DEAL_VOLUME);
        }
     }
   Ld_ret_0 = Gd_336 * MoneyPerLot;
   return (Ld_ret_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDashboard()
  {
   color color_0;
   int Li_4 = 65280;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(equity - balance < 0.0)
      Li_4 = 255;
   if(Seconds() >= 0 && Seconds() < 10)
      color_0 = Red;
   if(Seconds() >= 10 && Seconds() < 20)
      color_0 = Violet;
   if(Seconds() >= 20 && Seconds() < 30)
      color_0 = Orange;
   if(Seconds() >= 30 && Seconds() < 40)
      color_0 = Blue;
   if(Seconds() >= 40 && Seconds() < 50)
      color_0 = Yellow;
   if(Seconds() >= 50 && Seconds() <= 59)
      color_0 = Aqua;
   string Ls_8 = "-------------------------------------------";
   f0_6("L01", "Arial", 9, 10, 10, Gi_328, 1, Ls_8);
   f0_6("L02", "Verdana", 15, 10, 25, color_0, 1, "EA HOKKYDJONG");
   f0_6("L0i", "Mistral", 12, 10, 45, Gi_324, 1, "Price Action Scalping Style");
   f0_6("L03", "Arial", 9, 10, 60, Gi_328, 1, Ls_8);
   f0_6("L04", "Arial", 9, 10, 75, Gi_332, 1, ">> Account Company : " + AccountInfoString(ACCOUNT_COMPANY));
   f0_6("L05", "Arial", 9, 10, 90, Gi_332, 1, ">> Name Server  : " + AccountInfoString(ACCOUNT_SERVER));
   f0_6("L06", "Arial", 9, 10, 105, Gi_332, 1, ">> Account Name  : " + AccountInfoString(ACCOUNT_NAME));
   f0_6("L07", "Arial", 9, 10, 120, Gi_332, 1, ">> Name Number  : " + AccountInfoInteger(ACCOUNT_LOGIN));
   f0_6("L08", "Arial", 9, 10, 135, Gi_332, 1, ">> Account Leverage  : 1 " + AccountInfoInteger(ACCOUNT_LEVERAGE));
   f0_6("L09", "Arial", 9, 10, 150, Gi_332, 1, ">> Time Server  : " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   f0_6("L10", "Arial", 9, 10, 165, Gi_332, 1, ">> Spread  : " + DoubleToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), 0));
   f0_6("L11", "Arial", 9, 10, 180, Gi_332, 1, ">> Account Balance  : $ " + DoubleToString(balance, 2));
   f0_6("L12", "Arial", 9, 10, 195, Gi_332, 1, ">> Account Equity  : $ " + DoubleToString(equity, 2));
   f0_6("L13", "Arial", 9, 10, 210, Gi_332, 1, ">> Order Total  : " + DoubleToString(OrdersTotal(), 0));
   f0_6("L14", "Arial", 9, 10, 390, Li_4, 1, ">> Profit / Loss  : $ " + DoubleToString(equity - balance, 2));
   f0_6("L15", "Arial", 15, 10, 425, Li_4, 1, " Rebate  : $ " + DoubleToString(GetCurrentProfit(), 2));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectSetText(string id, string text, int fontSize, string font, color clr)
  {
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_6(string A_name_0, string A_fontname_8, int A_fontsize_16, int A_x_20, int A_y_24, color A_color_28, int A_corner_32, string A_text_36)
  {
   if(ObjectFind(0, IndicatorObjPrefix + A_name_0) < 0)
      ObjectCreate(0, IndicatorObjPrefix + A_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(IndicatorObjPrefix + A_name_0, A_text_36, A_fontsize_16, A_fontname_8, A_color_28);
   ObjectSetInteger(0, IndicatorObjPrefix + A_name_0, OBJPROP_CORNER, A_corner_32);
   ObjectSetInteger(0, IndicatorObjPrefix + A_name_0, OBJPROP_XDISTANCE, A_x_20);
   ObjectSetInteger(0, IndicatorObjPrefix + A_name_0, OBJPROP_YDISTANCE, A_y_24);
  }
//+------------------------------------------------------------------+


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

void doBreackevenAction()
{
  for (int i = MainOrders.qnt() - 1; i >= 0; i--)
  {
    if (!MainOrders.index(i).breakevenWasDoIt())
    {
      breackevenCondition.setOrder(MainOrders.index(i));
      if (conditionsToBreackeven.EvaluateConditions())
      {
        breackevenAction = new MoveSL();

        double buySl = MainOrders.index(i).price() + userBkvStep * 10 * Point();
        double sellSl = MainOrders.index(i).price() - userBkvStep * 10 * Point();
        double newSl  = MainOrders.index(i).type() == POSITION_TYPE_BUY ? buySl : sellSl;
        breackevenAction.order(MainOrders.index(i)).newSL(newSl);
        breackevenAction.doAction();
        delete breackevenAction;
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
//| USDT Donations                                                                                 |
//+------------------------------------------------+-----------------------------------------------+
//| Network                                        |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+