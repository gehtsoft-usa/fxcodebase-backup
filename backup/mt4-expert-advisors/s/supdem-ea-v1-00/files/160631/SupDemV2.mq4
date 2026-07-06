//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76323
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
//HEADER:END

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
 

#property indicator_chart_window
#property indicator_buffers 2
extern int forced_tf = 0;
extern bool use_narrow_bands = false;
extern bool kill_retouch = true;
extern color TopColor = DarkSlateGray;
extern color BotColor = DarkSlateGray;
extern color Price_mark = Black;
extern int Price_Width = 1;

extern string             button_note1 = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text = "SupDem Z";
extern string             btn_Font = "Arial";
extern int                btn_FontSize = 8;                             //btn__font size
extern color              btn_text_color = clrWhite;
extern color              btn_background_color = clrDimGray;
extern color              btn_border_color = clrBlack;
extern int                button_x = 20;                                 //btn__x
extern int                button_y = 13;                                 //btn__y
extern int                btn_Width = 60;                                 //btn__width
extern int                btn_Height = 20;                                //btn__height
extern string             button_note2 = "------------------------------";


int lastCount;
double supportPrice; double lastSupport;
double resistencePrice; double lastResistence;

// ------------------------------------------------------------------
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

// Global variable to track the last bar time
datetime lastBarTime = 0;
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

//+------------------------------------------------------------------+

//-----------------------------------------------------------------------------------------------------------------------------------------


int init()
{
    lastCount = 0;

    pair = Symbol();
    recalc = true;
    lastBarTime = 0;

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
    ArraySetAsSeries(BuferUp, true);
    ArraySetAsSeries(BuferDn, true);
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

    //put deinit() here
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

    pair = Symbol();

    if(!show_data)
    {
        if(recalc)
        {
            ObDeleteAll();
            Comment("");
            recalc = false;
        }
        return 0;
    }

    int bars = iBars(pair, tf);
    if(bars <= 0)
        return 0;

    int minBarsRequired = (int)iPeriod;
    if(bars <= minBarsRequired)
    {
        if(recalc)
        {
            ObDeleteAll();
            Comment("");
            recalc = false;
        }
        return 0;
    }

    bool isNewBar = NewBar();
    if(!isNewBar && !recalc)
        return 0;

    CountZZ(BuferUp, BuferDn, iPeriod, Dev, Step);
    GetValid();
    Draw();

    recalc = false;
    return 0;
}
//+------------------------------------------------------------------+






void Draw()
{
    const int bars = iBars(pair, tf);
    if(bars < 3)
        return;

    const datetime currentTime = Time[0];

    ObDeleteAll();

    for(int i = 1; i < bars - 1; i++)
    {
        if(BuferDn[i] > 0.0)
        {
            t1 = iTime(pair, tf, i);
            t2 = currentTime;

            if(use_narrow_bands)
                p2 = MathMax(iClose(pair, tf, i), iOpen(pair, tf, i));
            else
                p2 = MathMin(iClose(pair, tf, i), iOpen(pair, tf, i));

            p2 = MathMax(p2, MathMax(iLow(pair, tf, i - 1), iLow(pair, tf, i + 1)));

            string arrowNameUp = StringFormat("%sUPAR%d_%d", TAG, tf, i);
            ObjectCreate(arrowNameUp, OBJ_ARROW, 0, 0, 0);
            ObjectSet(arrowNameUp, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
            ObjectSet(arrowNameUp, OBJPROP_TIME1, t2);
            ObjectSet(arrowNameUp, OBJPROP_PRICE1, p2);
            ObjectSet(arrowNameUp, OBJPROP_COLOR, Price_mark);
            ObjectSet(arrowNameUp, OBJPROP_WIDTH, Price_Width);

            string rectangleNameUp = StringFormat("%sUPFILL%d_%d", TAG, tf, i);
            ObjectCreate(rectangleNameUp, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
            ObjectSet(rectangleNameUp, OBJPROP_TIME1, t1);
            ObjectSet(rectangleNameUp, OBJPROP_PRICE1, BuferDn[i]);
            ObjectSet(rectangleNameUp, OBJPROP_TIME2, t2);
            ObjectSet(rectangleNameUp, OBJPROP_PRICE2, p2);
            ObjectSet(rectangleNameUp, OBJPROP_COLOR, TopColor);
        }

        if(BuferUp[i] > 0.0)
        {
            t1 = iTime(pair, tf, i);
            t2 = currentTime;

            if(use_narrow_bands)
                p2 = MathMin(iClose(pair, tf, i), iOpen(pair, tf, i));
            else
                p2 = MathMax(iClose(pair, tf, i), iOpen(pair, tf, i));

            p2 = MathMin(p2, MathMin(iHigh(pair, tf, i + 1), iHigh(pair, tf, i - 1)));

            string arrowNameDn = StringFormat("%sDNAR%d_%d", TAG, tf, i);
            ObjectCreate(arrowNameDn, OBJ_ARROW, 0, 0, 0);
            ObjectSet(arrowNameDn, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
            ObjectSet(arrowNameDn, OBJPROP_TIME1, t2);
            ObjectSet(arrowNameDn, OBJPROP_PRICE1, p2);
            ObjectSet(arrowNameDn, OBJPROP_COLOR, Price_mark);
            ObjectSet(arrowNameDn, OBJPROP_WIDTH, Price_Width);

            string rectangleNameDn = StringFormat("%sDNFILL%d_%d", TAG, tf, i);
            ObjectCreate(rectangleNameDn, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
            ObjectSet(rectangleNameDn, OBJPROP_TIME1, t1);
            ObjectSet(rectangleNameDn, OBJPROP_PRICE1, p2);
            ObjectSet(rectangleNameDn, OBJPROP_TIME2, t2);
            ObjectSet(rectangleNameDn, OBJPROP_PRICE2, BuferUp[i]);
            ObjectSet(rectangleNameDn, OBJPROP_COLOR, BotColor);
        }
    }
}


//-----------------------------------------------------------------------------------------------------------------------------------------------------


//+------------------------------------------------------------------+
bool NewBar()
{
    int bars = iBars(pair, tf);
    if(bars <= 0)
        return(false);

    datetime currentTime = iTime(pair, tf, 0);
    if(currentTime <= 0)
        return(false);

    if(currentTime != lastBarTime)
    {
        lastBarTime = currentTime;
        return(true);
    }

    return(false);
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

        
        
                        ObjectDelete(0, "distance1");
          


    }
}
//+------------------------------------------------------------------+
int CountZZ(double& ExtMapBuffer [], double& ExtMapBuffer2 [], int ExtDepth, int ExtDeviation, int ExtBackstep)
{
    int    shift, back, lasthighpos, lastlowpos;
    double val, res;
    double curlow, curhigh, lasthigh, lastlow;
    int totalBars = iBars(pair, tf);
    if(totalBars <= 0)
        return(0);

    int count = totalBars - ExtDepth;
    if(count < 0)
        count = 0;

    for(shift = count; shift >= 0; shift--)
    {
        int lowestIndex = iLowest(pair, tf, MODE_LOW, ExtDepth, shift);
        if(lowestIndex < 0)
            break;
        val = iLow(pair, tf, lowestIndex);
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
        int highestIndex = iHighest(pair, tf, MODE_HIGH, ExtDepth, shift);
        if(highestIndex < 0)
            break;
        val = iHigh(pair, tf, highestIndex);

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

    for(shift = totalBars - 1; shift >= 0; shift--)
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
    int totalBars = iBars(pair, tf);
    if(totalBars <= 0)
        return;

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
    for(i = 0;i < totalBars;i++)
    {
        if(BuferUp[i] > 0)
        {
            up_cur = BuferUp[i];
            cur_lo = BuferUp[i];
            last_up = cur_lo;
            break;
        }
    }
    for(i = 0;i < totalBars;i++)
    {
        if(BuferDn[i] > 0)
        {
            dn_cur = BuferDn[i];
            cur_hi = BuferDn[i];
            last_dn = cur_hi;
            break;
        }
    }
    for(i = 0;i < totalBars;i++) // remove higher lows and lower high=0s
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
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76323
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
//FOOTER:END