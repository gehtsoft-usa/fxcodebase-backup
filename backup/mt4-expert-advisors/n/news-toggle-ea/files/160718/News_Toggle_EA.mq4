//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76342
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
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property strict

//--- Input parameters
input string TNEWS = "== News Setup ==";              // ————————————
input string note = "http://calendar.fxstreet.com/";  // You Must to allow this URL
input string NewsFilter = "USD,EUR,GBP";              // Currencies to monitor for news
input int NewsImpactLevel = 3;                        // Minimum impact level (1-5)
input int NewsBufferMinutes = 30;                     // Minutes before news to close trades
input bool EnableAutoClose = true;                    // Auto close trades before news
input bool EnableAutoTradingControl = true;          // Auto disable/enable AutoTrading
input bool NEWS_FILTER = true;                        // News Filter On
input bool NEWS_IMPOTANCE_LOW = false;                // Low
input bool NEWS_IMPOTANCE_MEDIUM = true;              // Medium
input bool NEWS_IMPOTANCE_HIGH = true;                // High
input int STOP_BEFORE_NEWS = 30;                      // Minutes Stop Before News
input int START_AFTER_NEWS = 30;                      // Minutes Stop After News
input bool AUTO_OFF_NEWS_FILTER_MODE = false;               // Auto off news filter mode after news
input int AUTO_OFF_DELAY = 60;                       // Minutes to wait before auto off

//--- Global variables
bool g_NewsMode = false;
bool g_AutoTradingWasEnabled = false;
datetime g_LastNewsCheck = 0;
datetime g_NewsModeStartTime = 0;
string g_ButtonName = "NewsToggleButton";

// News structure
struct sNews {
    datetime dTime;
    string time;
    string currency;
    string news;
    string importance;
    string Actual;
    string forecast;
    string previus;
};

sNews NEWS_TABLE[];
string Currencies_Check = "USD,EUR,GBP";

int OnInit()
{
    CreateToggleButton();
    
    g_NewsMode = false;
    g_AutoTradingWasEnabled = IsAutoTradingEnabled();
    
    Print("News Toggle EA initialized. AutoTrading status: ", g_AutoTradingWasEnabled);
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    ObjectDelete(g_ButtonName);
    
    if(g_AutoTradingWasEnabled && !IsAutoTradingEnabled())
    {
        EnableAutoTrading();
        Print("AutoTrading restored on EA removal");
    }
}

void OnTick()
{
    if(TimeCurrent() - g_LastNewsCheck >= 60)
    {
        CheckForNews();
        g_LastNewsCheck = TimeCurrent();
    }
    
    UpdateButtonAppearance();
    
    if(g_NewsMode && AUTO_OFF_NEWS_FILTER_MODE)
    {
        CheckAutoOffNewsFilterMode();
    }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if(id == CHARTEVENT_OBJECT_CLICK)
    {
        if(sparam == g_ButtonName)
        {
            ToggleNewsMode();
        }
    }
}

void CreateToggleButton()
{
    ObjectDelete(g_ButtonName);
    
    if(!ObjectCreate(g_ButtonName, OBJ_BUTTON, 0, 0, 0))
    {
        Print("Failed to create button: ", GetLastError());
        return;
    }
    
    ObjectSetInteger(0, g_ButtonName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, g_ButtonName, OBJPROP_XDISTANCE, 20);
    ObjectSetInteger(0, g_ButtonName, OBJPROP_YDISTANCE, 50);
    ObjectSetInteger(0, g_ButtonName, OBJPROP_XSIZE, 170);
    ObjectSetInteger(0, g_ButtonName, OBJPROP_YSIZE, 30);
    ObjectSetInteger(0, g_ButtonName, OBJPROP_BGCOLOR, clrRed);
    ObjectSetInteger(0, g_ButtonName, OBJPROP_BORDER_COLOR, clrWhite);
    ObjectSetInteger(0, g_ButtonName, OBJPROP_FONTSIZE, 9);
    ObjectSetString(0, g_ButtonName, OBJPROP_FONT, "Arial Bold");
    ObjectSetString(0, g_ButtonName, OBJPROP_TEXT, "NEWS FILTER MODE: OFF");
    
    ChartRedraw();
}

void UpdateButtonAppearance()
{
    if(g_NewsMode)
    {
        ObjectSetInteger(0, g_ButtonName, OBJPROP_BGCOLOR, clrLime);
        ObjectSetString(0, g_ButtonName, OBJPROP_TEXT, "NEWS FILTER MODE: ON");
    }
    else
    {
        ObjectSetInteger(0, g_ButtonName, OBJPROP_BGCOLOR, clrRed);
        ObjectSetString(0, g_ButtonName, OBJPROP_TEXT, "NEWS FILTER MODE: OFF");
    }
    ChartRedraw();
}

void ToggleNewsMode()
{
    g_NewsMode = !g_NewsMode;
    
    if(g_NewsMode)
    {
        g_NewsModeStartTime = TimeCurrent();
        Print("Entering NEWS FILTER MODE - Closing all trades and disabling AutoTrading");
        
        if(EnableAutoClose)
        {
            CloseAllTrades();
        }
        
        if(EnableAutoTradingControl)
        {
            DisableAutoTrading();
        }
        
        Alert("NEWS FILTER MODE ACTIVATED - All trades closed, AutoTrading disabled");
    }
    else
    {
        Print("Exiting NEWS FILTER MODE - Re-enabling AutoTrading");
        
        if(EnableAutoTradingControl)
        {
            EnableAutoTrading();
        }
        
        Alert("NEWS FILTER MODE DEACTIVATED - AutoTrading re-enabled");
    }
    
    UpdateButtonAppearance();
}

void CheckForNews()
{
    if(NEWS_FILTER == false) return;
    
    if(READ_NEWS(NEWS_TABLE) && ArraySize(NEWS_TABLE) > 0)
    {
        CheckNewsTime();
    }
}

bool READ_NEWS(sNews& l_NewsTable[])
{
    string cookie = NULL, referer = NULL, headers;
    char   post[], result[];
    string tmpStr  = "";
    string st_date = TimeToString(TimeCurrent(), TIME_DATE), end_date = TimeToString((TimeCurrent() + (datetime)(7 * 24 * 60 * 60)), TIME_DATE);
    StringReplace(st_date, ".", "");
    StringReplace(end_date, ".", "");
    string LANG = "en";
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
    string HEADS_news = (st < end ? StringSubstr(tmpStr, st, end - st) : "");
    
    st = StringFind(tmpStr, "fxst-thvolatility", 0);
    st = StringFind(tmpStr, ">", st) + 1;
    end = StringFind(tmpStr, "</th>", st);
    string HEADS_importance = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
    
    st = StringFind(tmpStr, "fxst-thactual", 0);
    st = StringFind(tmpStr, ">", st) + 1;
    end = StringFind(tmpStr, "</th>", st);
    string HEADS_Actual = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
    
    st = StringFind(tmpStr, "fxst-thconsensus", 0);
    st = StringFind(tmpStr, ">", st) + 1;
    end = StringFind(tmpStr, "</th>", st);
    string HEADS_forecast = (st < end ? StringSubstr(tmpStr, st, fmin(end - st, 8)) : "");
    
    st = StringFind(tmpStr, "fxst-thprevious", 0);
    st = StringFind(tmpStr, ">", st) + 1;
    end = StringFind(tmpStr, "</th>", st);
    string HEADS_previus = (st < end ? StringSubstr(tmpStr, st, end - st) : "");
    
    int startLoad = StringFind(tmpStr, "<tbody>", 0) + 7;
    int endLoad = StringFind(tmpStr, "</tbody>", startLoad);
    if (startLoad >= 0 && endLoad > startLoad) {
        tmpStr = StringSubstr(tmpStr, startLoad, endLoad - startLoad);
        while (StringReplace(tmpStr, "  ", " "));
    } else
        return false;
        
    int begin = -1;
    do {
        begin = StringFind(tmpStr, "<span", 0);
        if (begin >= 0) {
            end = StringFind(tmpStr, "</span>", begin) + 7;
            tmpStr = StringSubstr(tmpStr, 0, begin) + StringSubstr(tmpStr, end);
        }
    } while (begin >= 0);
    
    StringReplace(tmpStr, "<strong>", NULL);
    StringReplace(tmpStr, "</strong>", NULL);
    
    int BackShift = 0;
    string arNews[];
    for (uchar tr = 1; tr < 255; tr++) {
        if (StringFind(tmpStr, CharToString(tr), 0) > 0)
            continue;
        int K = StringReplace(tmpStr, "</tr>", CharToString(tr));
        K = StringSplit(tmpStr, tr, arNews);
        ArrayResize(l_NewsTable, K);
        
        for (int td = 0; td < ArraySize(arNews); td++) {
            st = StringFind(arNews[td], "fxst-td-date", 0);
            if (st > 0) {
                st = StringFind(arNews[td], ">", st) + 1;
                end = StringFind(arNews[td], "</td>", st) - 1;
                int d = (int)StringToInteger(StringSubstr(arNews[td], end - 4, end - st));
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
                time.day = d;
                datetime date = StructToTime(time);
                
                st = StringFind(arNews[td], "fxst-evenRow", 0);
                if (st < 0) continue;
                
                int st1 = StringFind(arNews[td], "fxst-td-time", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].time = StringSubstr(arNews[td], st1, end - st1);
                if (StringFind(l_NewsTable[td - BackShift].time, ":") > 0) {
                    l_NewsTable[td - BackShift].dTime = StringToTime(TimeToString(date, TIME_DATE) + " " + StringSubstr(arNews[td], st1, end - st1));
                } else {
                    l_NewsTable[td - BackShift].dTime = date;
                }
                
                st1 = StringFind(arNews[td], "fxst-td-currency", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                l_NewsTable[td - BackShift].currency = (st1 < end ? StringSubstr(arNews[td], st1, end - st1) : "");
                
                st1 = StringFind(arNews[td], "fxst-i-vol", st);
                st1 = StringFind(arNews[td], ">", st1) + 1;
                end = StringFind(arNews[td], "</td>", st1);
                StringInit(l_NewsTable[td - BackShift].importance, (int)StringToInteger(StringSubstr(arNews[td], st1, end - st1)), '*');
                
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
            } else {
                BackShift++;
            }
        }
        break;
    }
    
    ArrayResize(l_NewsTable, (ArraySize(l_NewsTable) - BackShift));
    return true;
}

void CheckNewsTime()
{
    datetime currentTime = TimeCurrent();
    bool isNewsTime = false;
    
    for(int i = 0; i < ArraySize(NEWS_TABLE); i++)
    {
        datetime news_time = NEWS_TABLE[i].dTime;
        
        bool Importance_Check = false;
        if((!NEWS_IMPOTANCE_LOW && NEWS_TABLE[i].importance == "*") ||
           (!NEWS_IMPOTANCE_MEDIUM && NEWS_TABLE[i].importance == "* *") ||
           (!NEWS_IMPOTANCE_HIGH && NEWS_TABLE[i].importance == "* * *"))
            continue;
            
        if(StringFind(Currencies_Check, NEWS_TABLE[i].currency, 0) == -1)
            continue;
            
        if((news_time <= currentTime && (news_time + (datetime)(START_AFTER_NEWS * 60)) >= currentTime) ||
           (news_time >= currentTime && (news_time - (datetime)(STOP_BEFORE_NEWS * 60)) <= currentTime))
    {
        isNewsTime = true;
            Print("News detected: ", NEWS_TABLE[i].currency, " - ", NEWS_TABLE[i].news, " at ", TimeToString(news_time));
            break;
        }
    }
    
    if(isNewsTime && !g_NewsMode)
    {
        Print("Auto-activating NEWS FILTER MODE due to upcoming news");
        ToggleNewsMode();
    }
}

void CloseAllTrades()
{
    int totalTrades = OrdersTotal();
    int closedTrades = 0;
    
    for(int i = totalTrades - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderSymbol() == Symbol())
            {
                double price = (OrderType() == OP_BUY) ? Bid : Ask;
                bool result = OrderClose(OrderTicket(), OrderLots(), price, 3, clrRed);
                
                if(result)
                {
                    closedTrades++;
                    Print("Closed trade #", OrderTicket(), " Profit: ", OrderProfit());
                }
                else
                {
                    Print("Failed to close trade #", OrderTicket(), " Error: ", GetLastError());
                }
            }
        }
    }
    
    Print("Closed ", closedTrades, " trades before news");
}

void DisableAutoTrading()
{
    if(IsAutoTradingEnabled())
    {
        g_AutoTradingWasEnabled = true;
        // Note: Cannot directly disable AutoTrading in MQL4
        // This would require manual intervention or external tool
        Print("AutoTrading should be manually disabled - EA cannot control it directly");
        Alert("Please manually disable AutoTrading button in MT4!");
    }
}

void EnableAutoTrading()
{
    if(!IsAutoTradingEnabled())
    {
        Print("AutoTrading should be manually enabled - EA cannot control it directly");
        Alert("Please manually enable AutoTrading button in MT4!");
    }
}

bool IsAutoTradingEnabled()
{
    return IsTradeAllowed();
}

void CheckAutoOffNewsFilterMode()
{
    if(g_NewsMode && AUTO_OFF_NEWS_FILTER_MODE)
    {
        datetime currentTime = TimeCurrent();
        int minutesInNewsMode = (int)((currentTime - g_NewsModeStartTime) / 60);
        
        if(minutesInNewsMode >= AUTO_OFF_DELAY)
        {
            Print("Auto-off NEWS FILTER MODE after ", minutesInNewsMode, " minutes");
            ToggleNewsMode();
            Alert("NEWS FILTER MODE AUTO-OFF after ", minutesInNewsMode, " minutes");
        }
    }
}

void OnTimer()
{
    CheckForNews();
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76342
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