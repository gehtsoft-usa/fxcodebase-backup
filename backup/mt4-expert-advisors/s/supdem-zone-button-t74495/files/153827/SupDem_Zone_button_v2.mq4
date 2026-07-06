// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74495

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0" 

#property indicator_chart_window
#property indicator_buffers 2
extern int forced_tf = 0;
extern bool use_narrow_bands = false;
extern bool kill_retouch = true;
extern color TopColor = Yellow;
extern color BotColor = Aqua;
extern color Price_mark = CLR_NONE;
extern int Price_Width = 1;

#define _btn
#ifdef _btn
extern string             button_note1 = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner = CORNER_RIGHT_UPPER; // chart btn_corner for anchoring
extern string             btn_text = "OB1";
extern string             btn_Font = "Arial";
extern int                btn_FontSize = 8;                             //btn__font size
extern color              btn_text_color = clrWhite;
extern color              btn_background_color = clrDimGray;
extern color              btn_border_color = clrBlack;
extern int                button_x = 70;                                     //btn__x
extern int                button_y = 40;                                     //btn__y
extern int                btn_Width = 60;                                 //btn__width
extern int                btn_Height = 20;                                //btn__height
extern string             button_note2 = "------------------------------";

bool                      show_data = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1
double BuferUp [];
double BuferDn [];
double iPeriod = 13;
int Dev = 8;
int Step = 5;
datetime t1, t2;
double p1, p2;
string pair;
double point;
int digits;
int tf;
string TAG;

double up_cur, dn_cur;
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target) //don't change anything here
{
    string name = target;
    int try = 2;
    while(WindowFind(name) != -1)
    {
        name = target + " #" + IntegerToString(try++);
    }
    return name;
}
//+------------------------------------------------------------------+
string buttonId;

#endif

#define NOTIFICATIONS_ON 
#ifdef NOTIFICATIONS_ON

input string TZ = "== Notifications ==";  // ————————————
input bool   notifications = true;                  // Notifications On
input bool   desktop_notifications = true;          // Desktop MT4 Notifications
input bool   email_notifications = false;           // Email Notifications
input bool   push_notifications = false;            // Push Mobile Notifications
input int    minutesBetwenNotify = 5;               // Minutes Betwen Notifications
int    timeNextNotify = 0;


// NOTE: notifi
void Notifications(int type)
{
    // time Control
    if(timeNextNotify != 0) if(TimeCurrent() < timeNextNotify) return;
    timeNextNotify = TimeCurrent() + (minutesBetwenNotify * 60);

    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " New TOP Order Block ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " New Botton Order Block ";

    text += " ";

    if(!notifications) return;
    if(desktop_notifications) Alert(text);
    if(push_notifications) SendNotification(text);
    if(email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
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

#endif



#define HLINES
#ifdef HLINES

class HLine
{
    string          _name;
    datetime        _iniTm;
    double          _price;
    color           _clr;
    string          _txt;
    ENUM_LINE_STYLE _style;
    bool            _selectable;

    public:
    HLine(string inpName, datetime inpIniTm = 0, double inpPrice = 0, color inpClr = clrBlack, string inpLabelTxt = "", ENUM_LINE_STYLE inpStyle = 0, bool selectable = false)
    {
        _name = inpName;
        _iniTm = inpIniTm;
        _price = inpPrice;
        _clr = inpClr;
        _txt = inpLabelTxt;
        _style = inpStyle;
        _selectable = selectable;
    }
    ~HLine() { erase(); }

    // clang-format off

    string name() { return _name; }
    double price() { return _price; }
    HLine* price(double inpPrice) { _price = inpPrice; return &this; }
    HLine* txt(string inpTxt) { _txt = inpTxt; return &this; }
    HLine* fromCandle(int candle) { _iniTm = iTime(Symbol(), Period(), candle); return &this; }
    HLine* style(ENUM_LINE_STYLE inpStyle) { _style = inpStyle; return &this; }
    HLine* clr(color clr) { _clr = clr; return &this; }
    HLine* redraw() { erase(); draw(); return &this; }
    double linePrice() { return ObjectGetDouble(0, _name, OBJPROP_PRICE); }
    bool isSelected() { return ObjectGetInteger(0, _name, OBJPROP_SELECTED); }

    void move() { ObjectMove(0, _name, 0, 0, _price); }
    void erase() { ObjectDelete(0, _name); ObjectDelete(0, _name + "Label"); }
    void changeColor(color clr) { erase(); _clr = clr; draw(); }

    void draw()
    {
        // draw line
        ObjectCreate(0, _name, OBJ_HLINE, 0, _iniTm, _price, TimeCurrent(), _price);
        ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);
        ObjectSetInteger(0, _name, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, _name, OBJPROP_STYLE, _style);

        // draw label
        if(_txt != "")
        {
            //  Period() * 2 * 60
            ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, TimeCurrent() + 60 * _Period, _price);
            ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
            ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
            ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
            ObjectSetInteger(0, _name + "Label", OBJPROP_BGCOLOR, clrBlack);
            ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
        }
    }
};

HLine topline("topline");
HLine botline("botline");

#endif


//+------------------------------------------------------------------+
int init()
{
    IndicatorName = GenerateIndicatorName(btn_text);
    IndicatorObjPrefix = "__" + IndicatorName + "__";
    IndicatorShortName(IndicatorName);
    IndicatorDigits(Digits);

    double val;
    if(GlobalVariableGet(IndicatorName + "_visibility", val))
        show_data = val != 0;

    // put init() here
    SetIndexBuffer(1, BuferUp);
    SetIndexEmptyValue(1, 0.0);
    SetIndexStyle(1, DRAW_NONE);
    SetIndexBuffer(0, BuferDn);
    SetIndexEmptyValue(0, 0.0);
    SetIndexStyle(0, DRAW_NONE);
    if(forced_tf != 0) tf = forced_tf;
    else tf = Period();
    point = Point;
    digits = Digits;
    if(digits == 3 || digits == 5) point *= 10;
    TAG = "II_SupDem" + tf;

    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
    buttonId = IndicatorObjPrefix + "CloseButton";
    createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
    ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
    ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);



    return 0;
}
//+------------------------------------------------------------------+
//don't change anything here
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
{
    ObjectDelete(0, buttonID);
    ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
    ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
    ObjectSetString(0, buttonID, OBJPROP_FONT, font);
    ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
    ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
    ObjectSetInteger(0, buttonID, OBJPROP_CORNER, btn_corner);
    ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
    ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
    ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
}
//+------------------------------------------------------------------+
int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    ObDeleteObjectsByPrefix(TAG);

    Comment("");

    return 0;
}
//+------------------------------------------------------------------+
//don't change anything here
bool recalc = true;

void handleButtonClicks()
{
    if(ObjectGetInteger(0, buttonId, OBJPROP_STATE))
    {
        ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
        show_data = !show_data;
        GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
        recalc = true;
        start();
    }
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long& lparam,
                  const double& dparam,
                  const string& sparam)
{
    handleButtonClicks();
}
//+------------------------------------------------------------------+
int start()
{
    handleButtonClicks();
    recalc = false;
    if(NewBar() == true) {
        CountZZ(BuferUp, BuferDn, iPeriod, Dev, Step);
        GetValid();
        Draw();
    }

    if(show_data) {
        CountZZ(BuferUp, BuferDn, iPeriod, Dev, Step);
        GetValid();
        Draw();
    }
    else {
        ObDeleteAll();
        Comment("");
    }



    double lasttop = 0;
    int i = 0;
    while(lasttop == 0 || i ==500)
    {
        lasttop = BuferDn[i];
        i++;
    }
    double lastbot = 0;
    i = 0;
    while(lastbot == 0 || i ==500)
    {
        lastbot = BuferUp[i];
        i++;
    }
    
    topline.price(lasttop).clr(TopColor).redraw();
    botline.price(lastbot).clr(BotColor).redraw();

    
    // notifications:
    if(BuferUp[0] != EMPTY_VALUE && BuferUp[0] != 0) { Notifications(1); }
    if(BuferUp[1]!=EMPTY_VALUE && BuferUp[1]!=0) { Notifications(0); }


    return 0;
}
//+------------------------------------------------------------------+
void Draw()
{
    int i;
    string s;

    ObDeleteAll(); //this function replaces the line below
    //       ObDeleteObjectsByPrefix(TAG);
    for(i = 0;i < iBars(pair, tf);i++)
    {
        if(BuferDn[i] > 0.0)
        {
            t1 = iTime(pair, tf, i);
            t2 = Time[0];
            if(use_narrow_bands) p2 = MathMax(iClose(pair, tf, i), iOpen(pair, tf, i));
            else p2 = MathMin(iClose(pair, tf, i), iOpen(pair, tf, i));
            p2 = MathMax(p2, MathMax(iLow(pair, tf, i - 1), iLow(pair, tf, i + 1)));


            s = TAG + "UPAR" + tf + i;
            ObjectCreate(s, OBJ_ARROW, 0, 0, 0);
            ObjectSet(s, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
            ObjectSet(s, OBJPROP_TIME1, t2);
            ObjectSet(s, OBJPROP_PRICE1, p2);
            ObjectSet(s, OBJPROP_COLOR, Price_mark);
            ObjectSet(s, OBJPROP_WIDTH, Price_Width);

            s = TAG + "UPFILL" + tf + i;
            ObjectCreate(s, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
            ObjectSet(s, OBJPROP_TIME1, t1);
            ObjectSet(s, OBJPROP_PRICE1, BuferDn[i]);
            ObjectSet(s, OBJPROP_TIME2, t2);
            ObjectSet(s, OBJPROP_PRICE2, p2);
            ObjectSet(s, OBJPROP_COLOR, TopColor);




        }

        if(BuferUp[i] > 0.0)
        {
            t1 = iTime(pair, tf, i);
            t2 = Time[0];
            if(use_narrow_bands) p2 = MathMin(iClose(pair, tf, i), iOpen(pair, tf, i));
            else p2 = MathMax(iClose(pair, tf, i), iOpen(pair, tf, i));
            if(i > 0) p2 = MathMin(p2, MathMin(iHigh(pair, tf, i + 1), iHigh(pair, tf, i - 1)));
            s = TAG + "DNAR" + tf + i;
            ObjectCreate(s, OBJ_ARROW, 0, 0, 0);
            ObjectSet(s, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
            ObjectSet(s, OBJPROP_TIME1, t2);
            ObjectSet(s, OBJPROP_PRICE1, p2);
            ObjectSet(s, OBJPROP_COLOR, Price_mark);
            ObjectSet(s, OBJPROP_WIDTH, Price_Width);

            s = TAG + "DNFILL" + tf + i;
            ObjectCreate(s, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
            ObjectSet(s, OBJPROP_TIME1, t1);
            ObjectSet(s, OBJPROP_PRICE1, p2);
            ObjectSet(s, OBJPROP_TIME2, t2);
            ObjectSet(s, OBJPROP_PRICE2, BuferUp[i]);
            ObjectSet(s, OBJPROP_COLOR, BotColor);

            //           Alert ("BUY OB ");




        }
    }

}
//+------------------------------------------------------------------+
bool NewBar()
{
    static datetime LastTime = 0;
    if(iTime(pair, tf, 0) != LastTime) {
        LastTime = iTime(pair, tf, 0);
        return (true);
    }
    else
        return (false);
}
//+------------------------------------------------------------------+
void ObDeleteAll()
{
    //       int L = StringLen(Prefix);
    int i = 0;
    while(i < ObjectsTotal())
    {
        string ObjName = ObjectName(i);
        if(StringSubstr(ObjName, 0, 9) != "II_SupDem")
        {

            i++;
            continue;
        }
        ObjectDelete(ObjName);
        //          Alert ("OBJECT DELETED");              


    }
}
//+------------------------------------------------------------------+
void ObDeleteObjectsByPrefix(string Prefix)
{
    int L = StringLen(Prefix);
    int i = 0;
    while(i < ObjectsTotal())
    {
        string ObjName = ObjectName(i);
        if(StringSubstr(ObjName, 0, L) != Prefix)
        {
            i++;
            continue;
        }
        ObjectDelete(ObjName);
        //          Alert ("OBJECT DELETED BY PREFIX"); 



    }
}
//+------------------------------------------------------------------+
int CountZZ(double& ExtMapBuffer [], double& ExtMapBuffer2 [], int ExtDepth, int ExtDeviation, int ExtBackstep)
{
    int    shift, back, lasthighpos, lastlowpos;
    double val, res;
    double curlow, curhigh, lasthigh, lastlow;
    int count = iBars(pair, tf) - ExtDepth;

    for(shift = count; shift >= 0; shift--)
    {
        val = iLow(pair, tf, iLowest(pair, tf, MODE_LOW, ExtDepth, shift));
        if(val == lastlow) val = 0.0;
        else
        {
            lastlow = val;
            if((iLow(pair, tf, shift) - val) > (ExtDeviation * Point)) val = 0.0;
            else
            {
                for(back = 1; back <= ExtBackstep; back++)
                {
                    res = ExtMapBuffer[shift + back];
                    if((res != 0) && (res > val)) ExtMapBuffer[shift + back] = 0.0;
                }
            }
        }

        ExtMapBuffer[shift] = val;
        //--- high
        val = iHigh(pair, tf, iHighest(pair, tf, MODE_HIGH, ExtDepth, shift));

        if(val == lasthigh) val = 0.0;
        else
        {
            lasthigh = val;
            if((val - iHigh(pair, tf, shift)) > (ExtDeviation * Point)) val = 0.0;
            else
            {
                for(back = 1; back <= ExtBackstep; back++)
                {
                    res = ExtMapBuffer2[shift + back];
                    if((res != 0) && (res < val)) ExtMapBuffer2[shift + back] = 0.0;
                }
            }
        }
        ExtMapBuffer2[shift] = val;
    }
    // final cutting
    lasthigh = -1; lasthighpos = -1;
    lastlow = -1;  lastlowpos = -1;

    for(shift = count; shift >= 0; shift--)
    {
        curlow = ExtMapBuffer[shift];
        curhigh = ExtMapBuffer2[shift];
        if((curlow == 0) && (curhigh == 0)) continue;
        //---
        if(curhigh != 0)
        {
            if(lasthigh > 0)
            {
                if(lasthigh < curhigh) ExtMapBuffer2[lasthighpos] = 0;
                else ExtMapBuffer2[shift] = 0;
            }
            //---
            if(lasthigh < curhigh || lasthigh < 0)
            {
                lasthigh = curhigh;
                lasthighpos = shift;
            }
            lastlow = -1;
        }
        //----
        if(curlow != 0)
        {
            if(lastlow > 0)
            {
                if(lastlow > curlow) ExtMapBuffer[lastlowpos] = 0;
                else ExtMapBuffer[shift] = 0;
            }
            //---
            if((curlow < lastlow) || (lastlow < 0))
            {
                lastlow = curlow;
                lastlowpos = shift;
            }
            lasthigh = -1;
        }
    }

    for(shift = iBars(pair, tf) - 1; shift >= 0; shift--)
    {
        if(shift >= count) ExtMapBuffer[shift] = 0.0;
        else
        {
            res = ExtMapBuffer2[shift];
            if(res != 0.0) ExtMapBuffer2[shift] = res;
        }
    }
    return(0);
}
//+------------------------------------------------------------------+
void GetValid()
{
    up_cur = 0;
    int upbar = 0;
    dn_cur = 0;
    int dnbar = 0;
    double cur_hi = 0;
    double cur_lo = 0;
    double last_up = 0;
    double last_dn = 0;
    double low_dn = 0;
    double hi_up = 0;
    int i;
    for(i = 0;i < iBars(pair, tf);i++)
    {
        if(BuferUp[i] > 0)
        {
            up_cur = BuferUp[i];
            cur_lo = BuferUp[i];
            last_up = cur_lo;
            break;
        }
    }
    for(i = 0;i < iBars(pair, tf);i++)
    {
        if(BuferDn[i] > 0)
        {
            dn_cur = BuferDn[i];
            cur_hi = BuferDn[i];
            last_dn = cur_hi;
            break;
        }
    }

    for(i = 0;i < iBars(pair, tf);i++) // remove higher lows and lower highs
    {
        if(BuferDn[i] >= last_dn)
        {
            last_dn = BuferDn[i];
            dnbar = i;
        }
        else BuferDn[i] = 0.0;

        if(BuferDn[i] <= dn_cur && BuferUp[i] > 0.0) BuferDn[i] = 0.0;

        if(BuferUp[i] <= last_up && BuferUp[i] > 0)
        {
            last_up = BuferUp[i];
            upbar = i;
        }
        else BuferUp[i] = 0.0;

        if(BuferUp[i] > up_cur) BuferUp[i] = 0.0;

    }

    if(kill_retouch)
    {
        if(use_narrow_bands)
        {
            low_dn = MathMax(iOpen(pair, tf, dnbar), iClose(pair, tf, dnbar));
            hi_up = MathMin(iOpen(pair, tf, upbar), iClose(pair, tf, upbar));
        }
        else
        {
            low_dn = MathMin(iOpen(pair, tf, dnbar), iClose(pair, tf, dnbar));
            hi_up = MathMax(iOpen(pair, tf, upbar), iClose(pair, tf, upbar));
        }

        for(i = MathMax(upbar, dnbar);i >= 0;i--) // work back to zero and remove reentries into s/d
        {
            if(BuferDn[i] > low_dn && BuferDn[i] != last_dn) BuferDn[i] = 0.0;
            else if(use_narrow_bands && BuferDn[i] > 0)
            {
                low_dn = MathMax(iOpen(pair, tf, i), iClose(pair, tf, i));
                last_dn = BuferDn[i];
            }
            else if(BuferDn[i] > 0)
            {
                low_dn = MathMin(iOpen(pair, tf, i), iClose(pair, tf, i));
                last_dn = BuferDn[i];
            }

            if(BuferUp[i] <= hi_up && BuferUp[i] > 0 && BuferUp[i] != last_up) BuferUp[i] = 0.0;
            else if(use_narrow_bands && BuferUp[i] > 0)
            {
                hi_up = MathMin(iOpen(pair, tf, i), iClose(pair, tf, i));
                last_up = BuferUp[i];
            }
            else if(BuferUp[i] > 0)
            {
                hi_up = MathMax(iOpen(pair, tf, i), iClose(pair, tf, i));
                last_up = BuferUp[i];
            }
        }
    }

}
//+------------------------------------------------------------------+

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