// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74077

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
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

// NOTE: defines
// ——————————————————————————————————————————————————————————————————
// #define NEWS_FILTER
// #define DAILY_LIMITS
// #define PENDING_ENTRYS
// #define SPREAD_FILTER
// #define CONTROL_CUSTOM_INDICATOR_FILE
// #define LICENSE_CONTROL_ON
// #define TIMER_FULL  // full setup sessions
#define TIMER_MINI  // one session at day
// #define TIMER_OFF   // don't show timer
// #define GRID_ON
#define NOTIFICATIONS_ON
// #define CLOSE_ALL_ON
// #define PARTIAL_CLOSE_ON
// #define BREAKEVEN_ON
// #define TRAILING_STOP_ON
#define MAX_TRADES_AT_SAME_TIME

#define TELEGRAM
#ifdef TELEGRAM

#include <Canvas/Canvas.mqh>
#include <Arrays/List.mqh>

//---
#define EVENT_NO_EVENTS 0
#define EVENT_MOVE      1
#define EVENT_CHANGE    2
//+------------------------------------------------------------------+
//|   TComment                                                       |
//+------------------------------------------------------------------+
class TComment : public CObject
{
    public:
    string            text;
    color             colour;
};
//+------------------------------------------------------------------+
//|   CComment                                                       |
//+------------------------------------------------------------------+
class CComment
{
    private:
    CPoint            m_temp;
    CCanvas           m_comment;
    CPoint            m_pos;
    CList             m_list;
    CSize             m_size;
    //---   
    string            m_name;
    string            m_font_name;
    int               m_font_size;
    bool              m_font_bold;
    double            m_font_interval;
    color             m_border_color;
    color             m_back_color;
    uchar             m_back_alpha;
    bool              m_graph_mode;
    bool              m_auto_colors;
    color             m_auto_back_color;
    color             m_auto_text_color;
    color             m_auto_border_color;
    color             m_chart_back_color;
    //+------------------------------------------------------------------+
    color Color2Gray(const color value)
    {
        int gray = (int) round(0.3 * GETRGBR(value) + 0.59 * GETRGBG(value) + 0.11 * GETRGBB(value));
        if(gray > 255) gray = 255;
        return((color) ARGB(0, gray, gray, gray));
    }
    //+------------------------------------------------------------------+
    uchar GrayChannel(const color value)
    {
        int gray = (int) round(0.3 * GETRGBR(value) + 0.59 * GETRGBG(value) + 0.11 * GETRGBB(value));
        if(gray > 255) gray = 255;
        return((uchar) gray);
    }
    //+------------------------------------------------------------------+
    color Bright(const color value, const int percent)
    {
        int r, g, b;
        //---   
        r = GETRGBR(value);
        g = GETRGBG(value);
        b = GETRGBB(value);
        //---
        if(percent >= 0)
        {
            r += (255 - r) * percent / 100;
            if(r > 255)r = 255;

            g += (255 - g) * percent / 100;
            if(g > 255)g = 255;

            b += (255 - b) * percent / 100;
            if(b > 255)b = 255;
        }
        else
        {
            r += r * percent / 100;
            if(r < 0)r = 0;

            g += g * percent / 100;
            if(g < 0)g = 0;

            b += b * percent / 100;
            if(b < 0)b = 0;
        }
        //---
        return(ARGB(0, r, g, b));
    }
    //+------------------------------------------------------------------+
    void  CalcColors()
    {
        m_auto_back_color = (color) ChartGetInteger(0, CHART_COLOR_BACKGROUND);
        color m_back_gray = Color2Gray(m_auto_back_color);
        uchar channel = GrayChannel(m_back_gray);
        //---
        if(channel > 120)
        {
            if(m_back_color == clrNONE)
                m_auto_border_color = clrNONE;
            else
                m_auto_border_color = Bright(m_back_gray, -30);

            m_auto_text_color = Bright(m_back_gray, -80);
        }
        else
        {
            if(m_back_color == clrNONE)
                m_auto_border_color = clrNONE;
            else
                m_auto_border_color = Bright(m_back_gray, 30);

            m_auto_text_color = Bright(m_back_gray, 80);
        }
    }
    public:
    //+------------------------------------------------------------------+
    void  CComment(void)
    {
        m_name = NULL;
        m_font_name = "Calibri Ligth";
        m_font_size = 12;
        m_font_bold = false;
        m_font_interval = 1.7;
        m_border_color = clrNONE;
        m_back_color = clrBlack;
        m_back_alpha = 255;
        m_graph_mode = true;
        m_auto_colors = false;
        m_chart_back_color = (color) ChartGetInteger(0, CHART_COLOR_BACKGROUND);
        m_auto_back_color = clrBlack;
        m_auto_border_color = clrNONE;
        //---
        ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
    };

    //+------------------------------------------------------------------+
    void  Create(const string name, const uint x, const uint y)
    {
        m_name = name;
        m_pos.x = (int) x;
        m_pos.y = (int) y;
    };

    //+------------------------------------------------------------------+
    int   CoordY() { return(m_pos.y); }

    //+------------------------------------------------------------------+
    int   CoordX() { return(m_pos.x); }

    //+------------------------------------------------------------------+
    void  Move(const uint x, const uint y)
    {
        m_pos.x = (int) x;
        m_pos.y = (int) y;

        if(ObjectGetInteger(0, m_name, OBJPROP_XDISTANCE) != m_pos.x)
            ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, m_pos.x);

        if(ObjectGetInteger(0, m_name, OBJPROP_YDISTANCE) != m_pos.y)
            ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, m_pos.y);
    };

    //+------------------------------------------------------------------+
    void SetAutoColors(const bool value)
    {
        m_auto_colors = value;
        if(value)
            CalcColors();
    }

    //+------------------------------------------------------------------+
    void  SetGraphMode(const bool value)
    {
        m_graph_mode = value;
    };

    //+------------------------------------------------------------------+
    void  SetText(const int row, const string text, const color colour)
    {
        if(row < 0)
            return;

        //---
        int total = m_list.Total();

        if(row < total)
        {
            TComment* item = m_list.GetNodeAtIndex(row);
            item.text = text;
            item.colour = colour;
        }
        else
        {
            //--- create new one string
            for(int i = total; i <= row; i++)
            {
                m_list.Add(new TComment);
                TComment* item = m_list.GetLastNode();
                if(row == i)
                {
                    item.text = text;
                    item.colour = colour;
                }
                else
                {
                    item.text = "";
                    item.colour = clrNONE;
                }
            }
        }
    }
    //+------------------------------------------------------------------+
    void  SetFont(const string font_name, const int font_size, const bool bold, const double font_interval)
    {
        m_font_name = font_name;
        m_font_size = font_size;
        m_font_bold = bold;
        m_font_interval = font_interval;
    }
    //+------------------------------------------------------------------+
    void  SetColor(const color border, const color back, const uchar alpha)
    {
        m_border_color = border;
        m_back_color = back;
        m_back_alpha = alpha;
    }
    //+------------------------------------------------------------------+
    void  Destroy()
    {
        //if(!m_graph_mode)
        Comment("");
        m_comment.Destroy();
        m_name = NULL;
    };
    //+------------------------------------------------------------------+
    void  Clear()
    {
        m_list.Clear();
    };
    //+------------------------------------------------------------------+
    int   OnChartEvent(const int id, const long lparam, const double dparam, const string sparam)
    {
        //--- mouse position
        CPoint p;
        p.x = (int) lparam;
        p.y = (int) dparam;

        //---
        if(id == CHARTEVENT_MOUSE_MOVE)
        {
            //--- panel size
            CSize psize;
            psize.cx = (int) ObjectGetInteger(0, m_name, OBJPROP_XSIZE);
            psize.cy = (int) ObjectGetInteger(0, m_name, OBJPROP_YSIZE);

            //--- panel position
            CPoint pan;
            pan.x = (int) ObjectGetInteger(0, m_name, OBJPROP_XDISTANCE);
            pan.y = (int) ObjectGetInteger(0, m_name, OBJPROP_YDISTANCE);

            //--- chart size
            CSize screen;
            screen.cx = (int) ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
            screen.cy = (int) ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

            if(sparam == "1")
            {
                //---
                if(m_temp.x == -1 &&
                   p.x >= pan.x && p.x < pan.x + psize.cx &&
                   p.y >= pan.y && p.y < pan.y + psize.cy)
                {
                    m_temp.x = p.x - pan.x;
                }
                //---
                if(m_temp.y == -1 &&
                   p.x >= pan.x && p.x < pan.x + psize.cx &&
                   p.y >= pan.y && p.y < pan.y + psize.cy)
                {
                    m_temp.y = p.y - pan.y;
                }
                //---
                if(m_temp.x >= 0 && m_temp.y >= 0)
                {
                    int new_x = p.x - m_temp.x;
                    if(new_x > screen.cx - psize.cx)new_x = screen.cx - psize.cx;
                    if(new_x < 0)new_x = 0;

                    int new_y = p.y - m_temp.y;
                    if(new_y > screen.cy - psize.cy)new_y = screen.cy - psize.cy;
                    if(new_y < 0)new_y = 0;
                    //---
                    ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, new_x);
                    m_pos.x = new_x;
                    ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, new_y);
                    m_pos.y = new_y;
                    ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
#ifdef __MQL5__
                    ChartRedraw();
#endif
                    return(EVENT_MOVE);
                }
            }
            else
            {
                m_temp.x = -1;
                m_temp.y = -1;
                ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
            }
        }
        //---  
        if(m_auto_colors && id == CHARTEVENT_CHART_CHANGE)
        {
            //--- changing background color event
            if(m_chart_back_color != (color) ChartGetInteger(0, CHART_COLOR_BACKGROUND))
            {
                CalcColors();
                m_chart_back_color = (color) ChartGetInteger(0, CHART_COLOR_BACKGROUND);
                return(EVENT_CHANGE);
            }
        }
        //---
        return(EVENT_NO_EVENTS);
    }
    //+------------------------------------------------------------------+
    void  Show()
    {
        int rows = m_list.Total();

        //--- text mode
        if(!m_graph_mode)
        {
            string text;
            for(int i = 0; i < rows; i++)
            {
                TComment* item = m_list.GetNodeAtIndex(i);
                text += "\n" + item.text;
            }
            Comment(text);
            return;
        }

        m_comment.FontSet(m_font_name, m_font_size, m_font_bold ? FW_BOLD : 0);
        int text_height = m_comment.TextHeight(" ");
        int max_height = (rows) * (int) round(text_height * m_font_interval) + text_height;

        //--- calc max width
        int max_width = 0;
        for(int i = 0; i < rows; i++)
        {
            TComment* item = m_list.GetNodeAtIndex(i);
            int width = m_comment.TextWidth(item.text);
            if(width > max_width) max_width = width;
        }
        max_width += text_height * 2;

        //--- create panel
        if(ObjectFind(0, m_name) == -1)
        {
            m_comment.CreateBitmapLabel(0, 0, m_name, m_pos.x, m_pos.y, max_width, max_height, COLOR_FORMAT_ARGB_NORMALIZE);
            ObjectSetString(0, m_name, OBJPROP_TOOLTIP, "\n");
        }
        else
        {
            //--- resize panel
            if(m_comment.Height() != max_height ||
               m_comment.Width() != max_width)
            {
                if(!m_comment.Resize(max_width, max_height))
                {
                    ObjectDelete(0, m_name);
                    ChartRedraw();
                }
            }

        }
        //--- 
        m_comment.Erase(ColorToARGB(m_auto_colors ? m_auto_back_color : m_back_color, m_back_alpha));
        m_comment.Rectangle(0, 0, max_width - 1, max_height - 1, ColorToARGB(m_auto_colors ? m_auto_border_color : m_border_color));
        //---
        int h = text_height;
        for(int i = 0; i < rows; i++)
        {
            TComment* item = m_list.GetNodeAtIndex(i);
            m_comment.TextOut(text_height, h, item.text, ColorToARGB(m_auto_colors ? m_auto_text_color : item.colour));
            h += (int) round(text_height * m_font_interval);
        }
        //---
        m_comment.Update();
    }
};
//+------------------------------------------------------------------+

// Common
// ------------------------------------------------------------------
//+------------------------------------------------------------------+
//|   Define                                                         |
//+------------------------------------------------------------------+
#define CUSTOM_ERROR_FIRST          ERR_USER_ERROR_FIRST
#define ERR_JSON_PARSING            ERR_USER_ERROR_FIRST+1
#define ERR_JSON_NOT_OK             ERR_USER_ERROR_FIRST+2
#define ERR_TOKEN_ISEMPTY           ERR_USER_ERROR_FIRST+3
#define ERR_RUN_LIMITATION          ERR_USER_ERROR_FIRST+4
//---
#define ERR_NOT_ACTIVE              ERR_USER_ERROR_FIRST+100
#define ERR_NOT_CONNECTED           ERR_USER_ERROR_FIRST+101
#define ERR_ORDER_SELECT            ERR_USER_ERROR_FIRST+102
#define ERR_INVALID_ORDER_TYPE      ERR_USER_ERROR_FIRST+103
#define ERR_INVALID_SYMBOL_NAME     ERR_USER_ERROR_FIRST+104
#define ERR_INVALID_EXPIRATION_TIME ERR_USER_ERROR_FIRST+105
#define ERR_HTTP_ERROR_FIRST        ERR_USER_ERROR_FIRST+1000 //+511
//+------------------------------------------------------------------+
//|   ENUM_LANGUAGE                                                  |
//+------------------------------------------------------------------+
enum ENUM_LANGUAGE
{
    LANGUAGE_EN,// English
    LANGUAGE_RU // Russian
};
//+------------------------------------------------------------------+
//|   ENUM_ERROR_LEVEL                                               |
//+------------------------------------------------------------------+
enum ENUM_ERROR_LEVEL
{
    ERROR_LEVEL_INFO,      // Info
    ERROR_LEVEL_WARNING,   // Warning
    ERROR_LEVEL_ERROR,     // Error
    ERROR_LEVEL_CRITICAL   // Critical
};
//+------------------------------------------------------------------+
//|   CErrInfo                                                       |
//+------------------------------------------------------------------+
struct CErrInfo //error information
{
    string            text1;
    string            text2;
    color             colour;
    ENUM_ERROR_LEVEL  level;
};
//+------------------------------------------------------------------+
//|   ENUM_UPDATE_MODE                                               |
//+------------------------------------------------------------------+
enum ENUM_UPDATE_MODE
{
    UPDATE_FAST,   //Fast
    UPDATE_NORMAL, //Normal
    UPDATE_SLOW,   //Slow
};
//+------------------------------------------------------------------+
//|   ENUM_RUN_MODE                                                  |
//+------------------------------------------------------------------+
enum ENUM_RUN_MODE
{
    RUN_OPTIMIZATION,
    RUN_VISUAL,
    RUN_TESTER,
    RUN_LIVE
};
//+------------------------------------------------------------------+
//|   GetRunMode                                                     |
//+------------------------------------------------------------------+
ENUM_RUN_MODE GetRunMode(void)
{
    if(MQLInfoInteger(MQL_OPTIMIZATION))
        return(RUN_OPTIMIZATION);
    if(MQLInfoInteger(MQL_VISUAL_MODE))
        return(RUN_VISUAL);
    if(MQLInfoInteger(MQL_TESTER))
        return(RUN_TESTER);
    return(RUN_LIVE);
}
//+------------------------------------------------------------------+
//|   CustomInfo                                                     |
//+------------------------------------------------------------------+
struct TCustomInfo
{
    string            text1;
    string            text2;
    color             colour;
    ENUM_ERROR_LEVEL  level;
};
//+------------------------------------------------------------------+
//|   ErrorInfo                                                      |
//+------------------------------------------------------------------+
struct TErrorInfo
{
    int               code;
    string            desc;
    ENUM_ERROR_LEVEL  level;
    ENUM_LANGUAGE     lang;
};
//+------------------------------------------------------------------+
//|   GetErrorInfo                                                   |
//+------------------------------------------------------------------+
bool GetErrorInfo(TErrorInfo& info)
{
    info.level = ERROR_LEVEL_INFO;
    if(info.lang == LANGUAGE_EN)
    {
        switch(info.code)
        {
            case ERR_NOT_CONNECTED:                info.desc = "No connection with server"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_JSON_PARSING:                 info.desc = "JSON parsing error";  info.level = ERROR_LEVEL_ERROR; break;
            case ERR_JSON_NOT_OK:                  info.desc = "JSON parsing not OK"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_TOKEN_ISEMPTY:                info.desc = "Token is empty"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_RUN_LIMITATION:               info.desc = "The bot does not run in tester mode"; info.level = ERROR_LEVEL_ERROR; break;

            case ERR_WEBREQUEST_INVALID_ADDRESS:   info.desc = "Invalid URL"; break;
            case ERR_WEBREQUEST_CONNECT_FAILED:    info.desc = "Failed to connect to specified URL"; break;
            case ERR_WEBREQUEST_TIMEOUT:           info.desc = "Timeout exceeded"; break;
            case ERR_WEBREQUEST_REQUEST_FAILED:    info.desc = "HTTP request failed"; break;

#ifdef __MQL4__
            case ERR_FUNCTION_NOT_CONFIRMED:       info.desc = "URL does not allowed for WebRequest"; break;
#endif

#ifdef __MQL5__
            case ERR_FUNCTION_NOT_ALLOWED:
                if(MQLInfoInteger(MQL_TESTER))
                    info.desc = "WebRequest() cannot be executed in the Strategy Tester.";
                else
                    info.desc = "URL does not allowed for WebRequest";
                break;
            case ERR_FILE_NOT_EXIST:               info.desc = "File is not exists"; break;
            case ERR_CHART_NOT_FOUND:              info.desc = "Chart not found"; break;
            case ERR_SUCCESS:                      info.desc = "The operation completed successfully"; break;
#endif         
                //---
            case ERR_HTTP_ERROR_FIRST + 100:         info.desc = "Continue"; break;
            case ERR_HTTP_ERROR_FIRST + 101:         info.desc = "Switching Protocols"; break;
            case ERR_HTTP_ERROR_FIRST + 102:         info.desc = "Processing"; break;

            case ERR_HTTP_ERROR_FIRST + 200:         info.desc = "OK"; break;
            case ERR_HTTP_ERROR_FIRST + 201:         info.desc = "Created"; break;
            case ERR_HTTP_ERROR_FIRST + 202:         info.desc = "Accepted"; break;
            case ERR_HTTP_ERROR_FIRST + 203:         info.desc = "Non-Authoritative Information"; break;
            case ERR_HTTP_ERROR_FIRST + 204:         info.desc = "No Content"; break;
            case ERR_HTTP_ERROR_FIRST + 205:         info.desc = "Reset Content"; break;
            case ERR_HTTP_ERROR_FIRST + 206:         info.desc = "Partial Content"; break;

            case ERR_HTTP_ERROR_FIRST + 300:         info.desc = "Multiple Choices"; break;
            case ERR_HTTP_ERROR_FIRST + 301:         info.desc = "Moved Permanently"; break;
            case ERR_HTTP_ERROR_FIRST + 302:         info.desc = "Found"; break;
            case ERR_HTTP_ERROR_FIRST + 303:         info.desc = "See Other"; break;
            case ERR_HTTP_ERROR_FIRST + 304:         info.desc = "Not Modified"; break;
            case ERR_HTTP_ERROR_FIRST + 305:         info.desc = "Use Proxy"; break;
            case ERR_HTTP_ERROR_FIRST + 307:         info.desc = "Temporary Redirect"; break;
            case ERR_HTTP_ERROR_FIRST + 308:         info.desc = "Resume Incomplete"; break;

            case ERR_HTTP_ERROR_FIRST + 400:         info.desc = "Bad Request"; break;
            case ERR_HTTP_ERROR_FIRST + 401:         info.desc = "Unauthorized"; break;
            case ERR_HTTP_ERROR_FIRST + 402:         info.desc = "Payment Required"; break;
            case ERR_HTTP_ERROR_FIRST + 403:         info.desc = "Forbidden"; break;
            case ERR_HTTP_ERROR_FIRST + 404:         info.desc = "Not Found"; break;
            case ERR_HTTP_ERROR_FIRST + 405:         info.desc = "Method Not Allowed"; break;
            case ERR_HTTP_ERROR_FIRST + 406:         info.desc = "Not Acceptable"; break;
            case ERR_HTTP_ERROR_FIRST + 407:         info.desc = "Proxy Authentication Required"; break;
            case ERR_HTTP_ERROR_FIRST + 408:         info.desc = "Request Timeout"; break;
            case ERR_HTTP_ERROR_FIRST + 409:         info.desc = "Conflict"; break;
            case ERR_HTTP_ERROR_FIRST + 410:         info.desc = "Gone"; break;
            case ERR_HTTP_ERROR_FIRST + 411:         info.desc = "Length Required"; break;
            case ERR_HTTP_ERROR_FIRST + 412:         info.desc = "Precondition Failed"; break;
            case ERR_HTTP_ERROR_FIRST + 413:         info.desc = "Request Entity Too Large"; break;
            case ERR_HTTP_ERROR_FIRST + 414:         info.desc = "Request-URI Too Long"; break;
            case ERR_HTTP_ERROR_FIRST + 415:         info.desc = "Unsupported Media Type"; break;
            case ERR_HTTP_ERROR_FIRST + 416:         info.desc = "Requested Range Not Satisfiable"; break;
            case ERR_HTTP_ERROR_FIRST + 417:         info.desc = "Expectation Failed"; break;

            case ERR_HTTP_ERROR_FIRST + 500:         info.desc = "Internal Server Error"; break;
            case ERR_HTTP_ERROR_FIRST + 501:         info.desc = "Not Implemented"; break;
            case ERR_HTTP_ERROR_FIRST + 502:         info.desc = "Bad Gateway"; break;
            case ERR_HTTP_ERROR_FIRST + 503:         info.desc = "Service Unavailable"; break;
            case ERR_HTTP_ERROR_FIRST + 504:         info.desc = "Gateway Timeout"; break;
            case ERR_HTTP_ERROR_FIRST + 505:         info.desc = "HTTP Version Not Supported"; break;
            case ERR_HTTP_ERROR_FIRST + 511:         info.desc = "Network Authentication Required"; break;
            case ERR_HTTP_ERROR_FIRST + 520:         info.desc = "Unknown Error"; break;
            case ERR_HTTP_ERROR_FIRST + 521:         info.desc = "Web Server Is Down"; break;
            case ERR_HTTP_ERROR_FIRST + 522:         info.desc = "Connection Timed Out"; break;
            case ERR_HTTP_ERROR_FIRST + 523:         info.desc = "Origin Is Unreachable"; break;
            case ERR_HTTP_ERROR_FIRST + 524:         info.desc = "A Timeout Occurred"; break;
            case ERR_HTTP_ERROR_FIRST + 525:         info.desc = "SSL Handshake Failed"; break;
            case ERR_HTTP_ERROR_FIRST + 526:         info.desc = "Invalid SSL Certificate"; break;



                //--- The error codes returned by trade server:
#ifdef __MQL4__         
            case ERR_NO_ERROR:                     info.desc = "No error"; break;
            case ERR_NO_RESULT:                    info.desc = "No error returned, but the result is unknown"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_COMMON_ERROR:                 info.desc = "Common error."; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_INVALID_TRADE_PARAMETERS:     info.desc = "Invalid trade parameters"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_SERVER_BUSY:                  info.desc = "Trade server is busy"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_OLD_VERSION:                  info.desc = "Old version of the client terminal"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_NO_CONNECTION:                info.desc = "No connection with trade server"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_NOT_ENOUGH_RIGHTS:            info.desc = "Not enough rights"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TOO_FREQUENT_REQUESTS:        info.desc = "Too frequent requests"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_MALFUNCTIONAL_TRADE:          info.desc = "Malfunctional trade operation"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_ACCOUNT_DISABLED:             info.desc = "Account disabled"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_INVALID_ACCOUNT:              info.desc = "Invalid account"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_TIMEOUT:                info.desc = "Trade timeout"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_INVALID_PRICE:                info.desc = "Invalid price"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_INVALID_STOPS:                info.desc = "Invalid stops"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_INVALID_TRADE_VOLUME:         info.desc = "Invalid trade volume"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_MARKET_CLOSED:                info.desc = "Market is closed"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_TRADE_DISABLED:               info.desc = "Trade is disabled"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_NOT_ENOUGH_MONEY:             info.desc = "Not enough money"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_PRICE_CHANGED:                info.desc = "Price changed"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_OFF_QUOTES:                   info.desc = "Off quotes"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_BROKER_BUSY:                  info.desc = "Broker is busy"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_REQUOTE:                      info.desc = "Requote"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_ORDER_LOCKED:                 info.desc = "Order is locked"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_LONG_POSITIONS_ONLY_ALLOWED:  info.desc = "Long positions only allowed"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TOO_MANY_REQUESTS:            info.desc = "Too many requests"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_MODIFY_DENIED:          info.desc = "Modification denied because order too close to market"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_CONTEXT_BUSY:           info.desc = "Trade context is busy"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_EXPIRATION_DENIED:      info.desc = "Expirations are denied by broker"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_TOO_MANY_ORDERS:        info.desc = "The amount of open and pending orders has reached the limit set by the broker"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_TRADE_HEDGE_PROHIBITED:       info.desc = "An attempt to open a position opposite to the existing one when hedging is disabled"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_TRADE_PROHIBITED_BY_FIFO:     info.desc = "An attempt to close a position contravening the FIFO rule"; info.level = ERROR_LEVEL_WARNING; break;
                //--- MQL4 run time error codes
            case ERR_TRADE_NOT_ALLOWED:            info.desc = "Trade is not allowed. Enable checkbox (Allow live trading) in the expert properties"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_LONGS_NOT_ALLOWED:            info.desc = "Longs are not allowed. Check the expert properties"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_SHORTS_NOT_ALLOWED:           info.desc = "Shorts are not allowed. Check the expert properties"; info.level = ERROR_LEVEL_ERROR; break;
#endif

                //---
            case ERR_INVALID_ORDER_TYPE:           info.desc = "Invalid order type"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_INVALID_SYMBOL_NAME:          info.desc = "Invalid symbol name"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_INVALID_EXPIRATION_TIME:      info.desc = "Invalid expiration time"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_ORDER_SELECT:                 info.desc = "Error function OrderSelect()"; info.level = ERROR_LEVEL_ERROR; break;
                //---

            default:
                info.desc = "Unknown error " + IntegerToString(info.code);
                return(false);

        }
    }

    //---
    if(info.lang == LANGUAGE_RU)
    {
        switch(info.code)
        {
            case ERR_NOT_ACTIVE:                   info.desc = "Нет лицензии"; break;
            case ERR_NOT_CONNECTED:                info.desc = "Нет соединения с торговым сервером"; break;

            case ERR_JSON_PARSING:                 info.desc = "Ошибка JSON структуры ответа";info.level = ERROR_LEVEL_ERROR; break;
            case ERR_JSON_NOT_OK:                  info.desc = "Парсинг JSON завершен с ошибкой";info.level = ERROR_LEVEL_ERROR; break;
            case ERR_TOKEN_ISEMPTY:                info.desc = "Токен-пустая строка"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_RUN_LIMITATION:               info.desc = "Бот не работает в тестере стратегий"; info.level = ERROR_LEVEL_ERROR; break;

                //---
            case ERR_WEBREQUEST_INVALID_ADDRESS:   info.desc = "URL не прошел проверку"; break;
            case ERR_WEBREQUEST_CONNECT_FAILED:    info.desc = "Не удалось подключиться к указанному URL"; break;
            case ERR_WEBREQUEST_TIMEOUT:           info.desc = "Превышен таймаут получения данных"; break;
            case ERR_WEBREQUEST_REQUEST_FAILED:    info.desc = "Ошибка в результате выполнения HTTP запроса"; break;

#ifdef __MQL4__         
            case ERR_FUNCTION_NOT_CONFIRMED:       info.desc = "URL нет в списке для WebRequest"; break;
#endif         

#ifdef __MQL5__
            case ERR_FUNCTION_NOT_ALLOWED:         info.desc = "URL нет в списке для WebRequest"; break;
            case ERR_FILE_NOT_EXIST:               info.desc = "Файла не существует"; break;
            case ERR_CHART_NOT_FOUND:              info.desc = "График не найден"; break;
            case ERR_SUCCESS:                      info.desc = "Операция выполнена успешно"; break;
#endif
                //---
            case ERR_HTTP_ERROR_FIRST + 100:         info.desc = "Продолжай"; break;
            case ERR_HTTP_ERROR_FIRST + 101:         info.desc = "Переключение протоколов"; break;
            case ERR_HTTP_ERROR_FIRST + 102:         info.desc = "Идёт обработка";

            case ERR_HTTP_ERROR_FIRST + 200:         info.desc = "Хорошо"; break;
            case ERR_HTTP_ERROR_FIRST + 201:         info.desc = "Создано"; break;
            case ERR_HTTP_ERROR_FIRST + 202:         info.desc = "Принято"; break;
            case ERR_HTTP_ERROR_FIRST + 203:         info.desc = "Информация не авторитетна"; break;
            case ERR_HTTP_ERROR_FIRST + 204:         info.desc = "Нет содержимого"; break;
            case ERR_HTTP_ERROR_FIRST + 205:         info.desc = "Сбросить содержимое"; break;
            case ERR_HTTP_ERROR_FIRST + 206:         info.desc = "Частичное содержимое"; break;

            case ERR_HTTP_ERROR_FIRST + 300:         info.desc = "Множество выборов"; break;
            case ERR_HTTP_ERROR_FIRST + 301:         info.desc = "Перемещено навсегда"; break;
            case ERR_HTTP_ERROR_FIRST + 302:         info.desc = "Перемещено временно/найдено"; break;
            case ERR_HTTP_ERROR_FIRST + 303:         info.desc = "Смотреть другое"; break;
            case ERR_HTTP_ERROR_FIRST + 304:         info.desc = "Не изменялось"; break;
            case ERR_HTTP_ERROR_FIRST + 305:         info.desc = "Использовать прокси"; break;
            case ERR_HTTP_ERROR_FIRST + 307:         info.desc = "Временное перенаправление"; break;
            case ERR_HTTP_ERROR_FIRST + 308:         info.desc = "Постоянное перенаправление"; break;

            case ERR_HTTP_ERROR_FIRST + 400:         info.desc = "Плохой, неверный запрос"; break;
            case ERR_HTTP_ERROR_FIRST + 401:         info.desc = "Не авторизован"; break;
            case ERR_HTTP_ERROR_FIRST + 402:         info.desc = "Необходима оплата"; break;
            case ERR_HTTP_ERROR_FIRST + 403:         info.desc = "Запрещено"; break;
            case ERR_HTTP_ERROR_FIRST + 404:         info.desc = "Не найдено"; break;
            case ERR_HTTP_ERROR_FIRST + 405:         info.desc = "Метод не поддерживается"; break;
            case ERR_HTTP_ERROR_FIRST + 406:         info.desc = "Неприемлемо"; break;
            case ERR_HTTP_ERROR_FIRST + 407:         info.desc = "Необходима аутентификация прокси"; break;
            case ERR_HTTP_ERROR_FIRST + 408:         info.desc = "Истекло время ожидания"; break;
            case ERR_HTTP_ERROR_FIRST + 409:         info.desc = "Конфликт"; break;
            case ERR_HTTP_ERROR_FIRST + 410:         info.desc = "Удалён"; break;
            case ERR_HTTP_ERROR_FIRST + 411:         info.desc = "Необходима длина"; break;
            case ERR_HTTP_ERROR_FIRST + 412:         info.desc = "Условие ложно"; break;
            case ERR_HTTP_ERROR_FIRST + 413:         info.desc = "Полезная нагрузка слишком велика"; break;
            case ERR_HTTP_ERROR_FIRST + 414:         info.desc = "URI слишком длинный"; break;
            case ERR_HTTP_ERROR_FIRST + 415:         info.desc = "Неподдерживаемый тип данных"; break;
            case ERR_HTTP_ERROR_FIRST + 416:         info.desc = "Диапазон не достижим"; break;
            case ERR_HTTP_ERROR_FIRST + 417:         info.desc = "Ожидание не удалось"; break;

            case ERR_HTTP_ERROR_FIRST + 500:         info.desc = "Внутренняя ошибка сервера"; break;
            case ERR_HTTP_ERROR_FIRST + 501:         info.desc = "Не реализовано"; break;
            case ERR_HTTP_ERROR_FIRST + 502:         info.desc = "Плохой, ошибочный шлюз"; break;
            case ERR_HTTP_ERROR_FIRST + 503:         info.desc = "Сервис недоступен"; break;
            case ERR_HTTP_ERROR_FIRST + 504:         info.desc = "Шлюз не отвечает"; break;
            case ERR_HTTP_ERROR_FIRST + 505:         info.desc = "Версия HTTP не поддерживается"; break;
            case ERR_HTTP_ERROR_FIRST + 511:         info.desc = "Требуется сетевая аутентификация"; break;
            case ERR_HTTP_ERROR_FIRST + 520:         info.desc = "Неизвестная ошибка"; break;
            case ERR_HTTP_ERROR_FIRST + 521:         info.desc = "Веб-сервер не работает"; break;
            case ERR_HTTP_ERROR_FIRST + 522:         info.desc = "Соединение не отвечает"; break;
            case ERR_HTTP_ERROR_FIRST + 523:         info.desc = "Источник недоступен"; break;
            case ERR_HTTP_ERROR_FIRST + 524:         info.desc = "Время ожидания истекло"; break;
            case ERR_HTTP_ERROR_FIRST + 525:         info.desc = "Квитирование SSL не удалось"; break;
            case ERR_HTTP_ERROR_FIRST + 526:         info.desc = "Недействительный сертификат SSL"; break;
                //---
#ifdef __MQL4__         
            case ERR_NO_ERROR:                     info.desc = "Нет ошибки"; break;
            case ERR_NO_RESULT:                    info.desc = "Нет ошибки, но результат неизвестен"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_COMMON_ERROR:                 info.desc = "Общая ошибка"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_INVALID_TRADE_PARAMETERS:     info.desc = "Неправильные параметры"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_SERVER_BUSY:                  info.desc = "Торговый сервер занят"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_OLD_VERSION:                  info.desc = "Старая версия клиентского терминала"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_NO_CONNECTION:                info.desc = "Нет связи с торговым сервером"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_NOT_ENOUGH_RIGHTS:            info.desc = "Недостаточно прав"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TOO_FREQUENT_REQUESTS:        info.desc = "Слишком частые запросы"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_MALFUNCTIONAL_TRADE:          info.desc = "Недопустимая операция нарушающая функционирование сервера"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_ACCOUNT_DISABLED:             info.desc = "Счет заблокирован"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_INVALID_ACCOUNT:              info.desc = "Неправильный номер счета"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_TIMEOUT:                info.desc = "Истек срок ожидания совершения сделки"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_INVALID_PRICE:                info.desc = "Неправильная цена"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_INVALID_STOPS:                info.desc = "Неправильные стопы"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_INVALID_TRADE_VOLUME:         info.desc = "Неправильный объем"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_MARKET_CLOSED:                info.desc = "Рынок закрыт"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_TRADE_DISABLED:               info.desc = "Торговля запрещена"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_NOT_ENOUGH_MONEY:             info.desc = "Недостаточно денег для совершения операции"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_PRICE_CHANGED:                info.desc = "Цена изменилась"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_OFF_QUOTES:                   info.desc = "Нет цен"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_BROKER_BUSY:                  info.desc = "Брокер занят"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_REQUOTE:                      info.desc = "Новые цены"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_ORDER_LOCKED:                 info.desc = "Ордер заблокирован и уже обрабатывается"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_LONG_POSITIONS_ONLY_ALLOWED:  info.desc = "Разрешена только покупка"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TOO_MANY_REQUESTS:            info.desc = "Слишком много запросов"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_MODIFY_DENIED:          info.desc = "Модификация запрещена, так как ордер слишком близок к рынку"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_CONTEXT_BUSY:           info.desc = "Подсистема торговли занята"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_EXPIRATION_DENIED:      info.desc = "Использование даты истечения ордера запрещено брокером"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_TRADE_TOO_MANY_ORDERS:        info.desc = "Количество открытых и отложенных ордеров достигло предела, установленного брокером."; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_TRADE_HEDGE_PROHIBITED:       info.desc = "Попытка открыть противоположную позицию к уже существующей в случае, если хеджирование запрещено"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_TRADE_PROHIBITED_BY_FIFO:     info.desc = "Попытка закрыть позицию по инструменту в противоречии с правилом FIFO"; info.level = ERROR_LEVEL_WARNING; break;
                //--- MQL4 run time error codes
            case ERR_TRADE_NOT_ALLOWED:            info.desc = "Торговля не разрешена. Необходимо включить опцию `Разрешить советнику торговать` в свойствах эксперта"; info.level = ERROR_LEVEL_WARNING; break;
            case ERR_LONGS_NOT_ALLOWED:            info.desc = "Ордера на покупку не разрешены. Необходимо проверить свойства эксперта"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_SHORTS_NOT_ALLOWED:           info.desc = "Ордера на продажу не разрешены. Необходимо проверить свойства эксперта"; info.level = ERROR_LEVEL_ERROR; break;
#endif
                //---  торговые 
            case ERR_INVALID_ORDER_TYPE:           info.desc = "Неправильный тип ордера"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_INVALID_SYMBOL_NAME:          info.desc = "Неправильное имя инструмента"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_INVALID_EXPIRATION_TIME:      info.desc = "Неправильное время экспирации"; info.level = ERROR_LEVEL_ERROR; break;
            case ERR_ORDER_SELECT:                 info.desc = "Ошибка функции OrderSelect()"; info.level = ERROR_LEVEL_ERROR; break;

                //---
            default:
                info.desc = "Неизвестная ошибка " + IntegerToString(info.code);
                return(false);
        }
    }
    return(true);
}
//+------------------------------------------------------------------+
string GetErrorDescription(const int _error_code,
                           const ENUM_LANGUAGE _language = LANGUAGE_EN)
{
    TErrorInfo info;
    info.code = _error_code;
    info.lang = _language;

    GetErrorInfo(info);

    return(info.desc);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_ERROR_LEVEL GetErrorLevel(const int _error_code)
{
    TErrorInfo info;
    info.code = _error_code;
    info.lang = LANGUAGE_EN;

    GetErrorInfo(info);
    return(info.level);
}
//+------------------------------------------------------------------+
//|   PrintError                                                     |
//+------------------------------------------------------------------+
ENUM_ERROR_LEVEL PrintError(int _error_code, const ENUM_LANGUAGE _lang = LANGUAGE_EN)
{
    TErrorInfo info;
    info.code = _error_code;
    info.lang = _lang;
    //---
    GetErrorInfo(info);
    //---
    if(_lang == LANGUAGE_RU)
        printf("Ошибка: %s", info.desc);
    else
        printf("Error: %s", info.desc);
    //---
    return(info.level);
}
//+------------------------------------------------------------------+
string GetOrderComment(const string _name,
                       const string _version,
                       const int _magic)
{
    return(StringSubstr(StringFormat("%s v.%s mn:%d", _name, _version, _magic), 0, 31));
}
//+------------------------------------------------------------------+
/*
ENUM_ORDER_TYPE_FILLING GetTypeFilling(const string _symbol)
  {
   ENUM_ORDER_TYPE_FILLING result=ORDER_FILLING_RETURN;
   uint filling=(uint)SymbolInfoInteger(_symbol,SYMBOL_FILLING_MODE);
   if((filling&SYMBOL_FILLING_IOC)!=0)
      result=ORDER_FILLING_IOC;
   if((filling&SYMBOL_FILLING_FOK)!=0)
      result=ORDER_FILLING_FOK;
   return(result);
  }
*/
//+------------------------------------------------------------------+
bool StringToTime(const string str, int& hours, int& minutes)
{
    string str_time = str;

#ifdef __MQL4__   
    str_time = StringTrimLeft(str_time);
    str_time = StringTrimRight(str_time);
#endif   

#ifdef __MQL5__   
    StringTrimLeft(str_time);
    StringTrimRight(str_time);
#endif

    if(StringLen(str_time) == 0)
        return(false);
    //---
    int index = StringFind(str_time, ":");
    if(index == -1)//00800,0800,800,80
    {
        int len = StringLen(str_time);
        switch(len)
        {
            case 1: hours = (int) StringToInteger(str_time); minutes = 0; break;
            case 2: hours = (int) StringToInteger(StringSubstr(str_time, 0, 2)); minutes = 0; break;
            case 3: hours = (int) StringToInteger(StringSubstr(str_time, 0, 1)); minutes = (int) StringToInteger(StringSubstr(str_time, 1, 2)); break;
            case 4: hours = (int) StringToInteger(StringSubstr(str_time, 0, 2)); minutes = (int) StringToInteger(StringSubstr(str_time, 2, 2)); break;
            case 5: hours = (int) StringToInteger(StringSubstr(str_time, 0, 3)); minutes = (int) StringToInteger(StringSubstr(str_time, 3, 2)); break;
        }
    }
    else//08:00
    {
        //---
        string temp = StringSubstr(str_time, 0, index);
        hours = (int) StringToInteger(temp);
        //---
        temp = StringSubstr(str_time, index + 1);
        minutes = (int) StringToInteger(temp);
    }
    //---
    if(hours < 0)hours = 0;
    if(hours > 23)hours = 23;

    if(minutes < 0)minutes = 0;
    if(minutes > 59)minutes = 59;

    return(true);
}
//+------------------------------------------------------------------+
string DoubleToStringEx(const double number)
{
    string str = DoubleToString(number, 8);
    int len = StringLen(str);
    if(len == 0)
        return("");
    //---
    for(int pos = len - 1; pos >= 0; pos--)
    {
        ushort ch = StringGetCharacter(str, pos);
        if(ch == '0')
        {
            StringSetCharacter(str, pos, 0);
        }
        else if(ch == '.')
        {
            StringSetCharacter(str, pos, 0);
            break;
        }
        else
            break;
    }
    //---
    return(str);
}
//+------------------------------------------------------------------+
string BoolToString(const bool _value)
{
    if(_value)
        return("да");
    return("нет");
}
//+------------------------------------------------------------------+
template<typename T>
T MinMax(const T min,
         const T max,
         const T value)
{
    int result = value;

    if(result < min)
        result = min;

    if(result > max)
        result = max;
    //---   
    return(result);
}
//+------------------------------------------------------------------+
bool IsMarketOpen()
{
#ifdef __MQL5__   
    datetime from, to;
    MqlDateTime mqltime;
    TimeToStruct(TimeTradeServer(), mqltime);
    return(SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK) mqltime.day_of_week, 0, from, to));
#endif
    return true;
}
//+------------------------------------------------------------------+

// JASON
// ------------------------------------------------------------------
#define DEBUG_PRINT false
//------------------------------------------------------------------	enum enJAType
enum enJAType { jtUNDEF, jtNULL, jtBOOL, jtINT, jtDBL, jtSTR, jtARRAY, jtOBJ };
//------------------------------------------------------------------	class CJAVal
class CJAVal
{
    public:
    virtual void Clear() { m_parent = NULL; m_key = ""; m_type = jtUNDEF; m_bv = false; m_iv = 0; m_dv = 0; m_sv = ""; ArrayResize(m_e, 0); }
    virtual bool Copy(const CJAVal& a) { m_key = a.m_key; CopyData(a); return true; }
    virtual void CopyData(const CJAVal& a) { m_type = a.m_type; m_bv = a.m_bv; m_iv = a.m_iv; m_dv = a.m_dv; m_sv = a.m_sv; CopyArr(a); }
    virtual void CopyArr(const CJAVal& a) { int n = ArrayResize(m_e, ArraySize(a.m_e)); for(int i = 0; i < n; i++) { m_e[i] = a.m_e[i]; m_e[i].m_parent = GetPointer(this); } }

    public:
    CJAVal            m_e [];
    string            m_key;
    string            m_lkey;
    CJAVal* m_parent;
    enJAType          m_type;
    bool              m_bv;
    long              m_iv;
    double            m_dv;
    string            m_sv;
    static int        code_page;

    public:
    CJAVal() { Clear(); }
    CJAVal(CJAVal* aparent, enJAType atype) { Clear(); m_type = atype; m_parent = aparent; }
    CJAVal(enJAType t, string a) { Clear(); FromStr(t, a); }
    CJAVal(const int a) { Clear(); m_type = jtINT; m_iv = a; m_dv = (double) m_iv; m_sv = IntegerToString(m_iv); m_bv = m_iv != 0; }
    CJAVal(const long a) { Clear(); m_type = jtINT; m_iv = a; m_dv = (double) m_iv; m_sv = IntegerToString(m_iv); m_bv = m_iv != 0; }
    CJAVal(const double a) { Clear(); m_type = jtDBL; m_dv = a; m_iv = (long) m_dv; m_sv = DoubleToString(m_dv); m_bv = m_iv != 0; }
    CJAVal(const bool a) { Clear(); m_type = jtBOOL; m_bv = a; m_iv = m_bv; m_dv = m_bv; m_sv = IntegerToString(m_iv); }
    CJAVal(const CJAVal& a) { Clear(); Copy(a); }
    ~CJAVal() { Clear(); }

    public:
    virtual bool IsNumeric() { return m_type == jtDBL || m_type == jtINT; }
    virtual CJAVal* FindKey(string akey) { for(int i = ArraySize(m_e) - 1; i >= 0; --i) if(m_e[i].m_key == akey) return GetPointer(m_e[i]); return NULL; }
    virtual CJAVal* HasKey(string akey, enJAType atype = jtUNDEF);
    virtual CJAVal* operator[](string akey);
    virtual CJAVal* operator[](int i);
    void operator=(const CJAVal& a) { Copy(a); }
    void operator=(const int a) { m_type = jtINT; m_iv = a; m_dv = (double) m_iv; m_bv = m_iv != 0; }
    void operator=(const long a) { m_type = jtINT; m_iv = a; m_dv = (double) m_iv; m_bv = m_iv != 0; }
    void operator=(const double a) { m_type = jtDBL; m_dv = a; m_iv = (long) m_dv; m_bv = m_iv != 0; }
    void operator=(const bool a) { m_type = jtBOOL; m_bv = a; m_iv = (long) m_bv; m_dv = (double) m_bv; }
    void operator=(string a) { m_type = (a != NULL) ? jtSTR : jtNULL; m_sv = a; m_iv = StringToInteger(m_sv); m_dv = StringToDouble(m_sv); m_bv = a != NULL; }

    bool operator==(const int a) { return m_iv == a; }
    bool operator==(const long a) { return m_iv == a; }
    bool operator==(const double a) { return m_dv == a; }
    bool operator==(const bool a) { return m_bv == a; }
    bool operator==(string a) { return m_sv == a; }

    bool operator!=(const int a) { return m_iv != a; }
    bool operator!=(const long a) { return m_iv != a; }
    bool operator!=(const double a) { return m_dv != a; }
    bool operator!=(const bool a) { return m_bv != a; }
    bool operator!=(string a) { return m_sv != a; }

    long ToInt() const { return m_iv; }
    double ToDbl() const { return m_dv; }
    bool ToBool() const { return m_bv; }
    string ToStr() { return m_sv; }

    virtual void FromStr(enJAType t, string a)
    {
        m_type = t;
        switch(m_type)
        {
            case jtBOOL: m_bv = (StringToInteger(a) != 0); m_iv = (long) m_bv; m_dv = (double) m_bv; m_sv = a; break;
            case jtINT: m_iv = StringToInteger(a); m_dv = (double) m_iv; m_sv = a; m_bv = m_iv != 0; break;
            case jtDBL: m_dv = StringToDouble(a); m_iv = (long) m_dv; m_sv = a; m_bv = m_iv != 0; break;
            case jtSTR: m_sv = Unescape(a); m_type = (m_sv != NULL) ? jtSTR : jtNULL; m_iv = StringToInteger(m_sv); m_dv = StringToDouble(m_sv); m_bv = m_sv != NULL; break;
        }
    }
    virtual string GetStr(char& js [], int i, int slen)
    {
#ifdef __MQL4__
        if(slen <= 0) return "";
#endif
        char cc [];
        ArrayCopy(cc, js, 0, i, slen);
        return CharArrayToString(cc, 0, WHOLE_ARRAY, CJAVal::code_page);
    }

    virtual void Set(const CJAVal& a) { if(m_type == jtUNDEF) m_type = jtOBJ; CopyData(a); }
    virtual void      Set(const CJAVal& list []);
    virtual CJAVal* Add(const CJAVal& item) { if(m_type == jtUNDEF) m_type = jtARRAY; /*ASSERT(m_type==jtOBJ || m_type==jtARRAY);*/ return AddBase(item); } // добавление
    virtual CJAVal* Add(const int a) { CJAVal item(a); return Add(item); }
    virtual CJAVal* Add(const long a) { CJAVal item(a); return Add(item); }
    virtual CJAVal* Add(const double a) { CJAVal item(a); return Add(item); }
    virtual CJAVal* Add(const bool a) { CJAVal item(a); return Add(item); }
    virtual CJAVal* Add(string a) { CJAVal item(jtSTR, a); return Add(item); }
    virtual CJAVal* AddBase(const CJAVal& item) { int c = ArraySize(m_e); ArrayResize(m_e, c + 1); m_e[c] = item; m_e[c].m_parent = GetPointer(this); return GetPointer(m_e[c]); } // добавление
    virtual CJAVal* New() { if(m_type == jtUNDEF) m_type = jtARRAY; /*ASSERT(m_type==jtOBJ || m_type==jtARRAY);*/ return NewBase(); } // добавление
    virtual CJAVal* NewBase() { int c = ArraySize(m_e); ArrayResize(m_e, c + 1); return GetPointer(m_e[c]); } // добавление

    virtual string    Escape(string a);
    virtual string    Unescape(string a);
    public:
    virtual void      Serialize(string& js, bool bf = false, bool bcoma = false);
    virtual string Serialize() { string js; Serialize(js); return js; }
    virtual bool      Deserialize(char& js [], int slen, int& i);
    virtual bool      ExtrStr(char& js [], int slen, int& i);
    virtual bool Deserialize(string js, int acp = CP_ACP) { int i = 0; Clear(); CJAVal::code_page = acp; char arr []; int slen = StringToCharArray(js, arr, 0, WHOLE_ARRAY, CJAVal::code_page); return Deserialize(arr, slen, i); }
    virtual bool Deserialize(char& js [], int acp = CP_ACP) { int i = 0; Clear(); CJAVal::code_page = acp; return Deserialize(js, ArraySize(js), i); }
};

int CJAVal::code_page = CP_ACP;

//------------------------------------------------------------------	HasKey
CJAVal* CJAVal::HasKey(string akey, enJAType atype/*=jtUNDEF*/) { for(int i = 0; i < ArraySize(m_e); i++) if(m_e[i].m_key == akey) { if(atype == jtUNDEF || atype == m_e[i].m_type) return GetPointer(m_e[i]); break; } return NULL; }
//------------------------------------------------------------------	operator[]
CJAVal* CJAVal::operator[](string akey) { if(m_type == jtUNDEF) m_type = jtOBJ; CJAVal* v = FindKey(akey); if(v) return v; CJAVal b(GetPointer(this), jtUNDEF); b.m_key = akey; v = Add(b); return v; }
//------------------------------------------------------------------	operator[]
CJAVal* CJAVal::operator[](int i)
{
    if(m_type == jtUNDEF) m_type = jtARRAY;
    while(i >= ArraySize(m_e)) { CJAVal b(GetPointer(this), jtUNDEF); if(CheckPointer(Add(b)) == POINTER_INVALID) return NULL; }
    return GetPointer(m_e[i]);
}
//------------------------------------------------------------------	Set
void CJAVal::Set(const CJAVal& list [])
{
    if(m_type == jtUNDEF) m_type = jtARRAY;
    int n = ArrayResize(m_e, ArraySize(list)); for(int i = 0; i < n;++i) { m_e[i] = list[i]; m_e[i].m_parent = GetPointer(this); }
}
//------------------------------------------------------------------	Serialize
void CJAVal::Serialize(string& js, bool bkey/*=false*/, bool coma/*=false*/)
{
    if(m_type == jtUNDEF) return;
    if(coma) js += ",";
    if(bkey) js += StringFormat("\"%s\":", m_key);
    int _n = ArraySize(m_e);
    switch(m_type)
    {
        case jtNULL: js += "null"; break;
        case jtBOOL: js += (m_bv ? "true" : "false"); break;
        case jtINT: js += IntegerToString(m_iv); break;
        case jtDBL: js += DoubleToString(m_dv); break;
        case jtSTR: { string ss = Escape(m_sv); if(StringLen(ss) > 0) js += StringFormat("\"%s\"", ss); else js += "null"; } break;
        case jtARRAY: js += "["; for(int i = 0; i < _n; i++) m_e[i].Serialize(js, false, i > 0); js += "]"; break;
        case jtOBJ: js += "{"; for(int i = 0; i < _n; i++) m_e[i].Serialize(js, true, i > 0); js += "}"; break;
    }
}
//------------------------------------------------------------------	Deserialize
bool CJAVal::Deserialize(char& js [], int slen, int& i)
{
    string num = "0123456789+-.eE";
    int i0 = i;
    for(; i < slen; i++)
    {
        char c = js[i]; if(c == 0) break;
        switch(c)
        {
            case '\t': case '\r': case '\n': case ' ': // пропускаем из имени пробелы
                i0 = i + 1; break;

            case '[': // начало массива. создаём объекты и забираем из js
            {
                i0 = i + 1;
                if(m_type != jtUNDEF) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; } // если значение уже имеет тип, то это ошибка
                m_type = jtARRAY; // задали тип значения
                i++; CJAVal val(GetPointer(this), jtUNDEF);
                while(val.Deserialize(js, slen, i))
                {
                    if(val.m_type != jtUNDEF) Add(val);
                    if(val.m_type == jtINT || val.m_type == jtDBL || val.m_type == jtARRAY) i++;
                    val.Clear(); val.m_parent = GetPointer(this);
                    if(js[i] == ']') break;
                    i++; if(i >= slen) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; }
                }
                return js[i] == ']' || js[i] == 0;
            }
            break;
            case ']': if(!m_parent) return false; return m_parent.m_type == jtARRAY; // конец массива, текущее значение должны быть массивом

            case ':':
            {
                if(m_lkey == "") { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; }
                CJAVal val(GetPointer(this), jtUNDEF);
                CJAVal* oc = Add(val); // тип объекта пока не определён
                oc.m_key = m_lkey; m_lkey = ""; // задали имя ключа
                i++; if(!oc.Deserialize(js, slen, i)) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; }
                break;
            }
            case ',': // разделитель значений // тип значения уже должен быть определён
                i0 = i + 1;
                if(!m_parent && m_type != jtOBJ) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; }
                else if(m_parent)
                {
                    if(m_parent.m_type != jtARRAY && m_parent.m_type != jtOBJ) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; }
                    if(m_parent.m_type == jtARRAY && m_type == jtUNDEF) return true;
                }
                break;

                // примитивы могут быть ТОЛЬКО в массиве / либо самостоятельно
            case '{': // начало объекта. создаем объект и забираем его из js
                i0 = i + 1;
                if(m_type != jtUNDEF) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; }// ошибка типа
                m_type = jtOBJ; // задали тип значения
                i++; if(!Deserialize(js, slen, i)) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; } // вытягиваем его
                return js[i] == '}' || js[i] == 0;
                break;
            case '}': return m_type == jtOBJ; // конец объекта, текущее значение должно быть объектом

            case 't': case 'T': // начало true
            case 'f': case 'F': // начало false
                if(m_type != jtUNDEF) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; } // ошибка типа
                m_type = jtBOOL; // задали тип значения
                if(i + 3 < slen) { if(StringCompare(GetStr(js, i, 4), "true", false) == 0) { m_bv = true; i += 3; return true; } }
                if(i + 4 < slen) { if(StringCompare(GetStr(js, i, 5), "false", false) == 0) { m_bv = false; i += 4; return true; } }
                if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; // не тот тип или конец строки
                break;
            case 'n': case 'N': // начало null
                if(m_type != jtUNDEF) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; } // ошибка типа
                m_type = jtNULL; // задали тип значения
                if(i + 3 < slen) if(StringCompare(GetStr(js, i, 4), "null", false) == 0) { i += 3; return true; }
                if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; // не NULL или конец строки
                break;

            case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '-': case '+': case '.': // начало числа
            {
                if(m_type != jtUNDEF) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; } // ошибка типа
                bool dbl = false;// задали тип значения
                int is = i; while(js[i] != 0 && i < slen) { i++; if(StringFind(num, GetStr(js, i, 1)) < 0) break; if(!dbl) dbl = (js[i] == '.' || js[i] == 'e' || js[i] == 'E'); }
                m_sv = GetStr(js, is, i - is);
                if(dbl) { m_type = jtDBL; m_dv = StringToDouble(m_sv); m_iv = (long) m_dv; m_bv = m_iv != 0; }
                else { m_type = jtINT; m_iv = StringToInteger(m_sv); m_dv = (double) m_iv; m_bv = m_iv != 0; } // уточнии тип значения
                i--; return true; // отодвинулись на 1 символ назад и вышли
                break;
            }
            case '\"': // начало или конец строки
                if(m_type == jtOBJ) // если тип еще неопределён и ключ не задан
                {
                    i++; int is = i; if(!ExtrStr(js, slen, i)) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; } // это ключ, идём до конца строки
                    m_lkey = GetStr(js, is, i - is);
                }
                else
                {
                    if(m_type != jtUNDEF) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; } // ошибка типа
                    m_type = jtSTR; // задали тип значения
                    i++; int is = i;
                    if(!ExtrStr(js, slen, i)) { if(DEBUG_PRINT)Print(m_key + " " + string(__LINE__)); return false; }
                    FromStr(jtSTR, GetStr(js, is, i - is));
                    return true;
                }
                break;
        }
    }
    return true;
}
//------------------------------------------------------------------	ExtrStr
bool CJAVal::ExtrStr(char& js [], int slen, int& i)
{
    for(; js[i] != 0 && i < slen; i++)
    {
        char c = js[i];
        if(c == '\"') break; // конец строки
        if(c == '\\' && i + 1 < slen)
        {
            i++; c = js[i];
            switch(c)
            {
                case '/': case '\\': case '\"': case 'b': case 'f': case 'r': case 'n': case 't': break; // это разрешенные
                case 'u': // \uXXXX
                {
                    i++;
                    for(int j = 0; j < 4 && i < slen && js[i] != 0; j++, i++)
                    {
                        if(!((js[i] >= '0' && js[i] <= '9') || (js[i] >= 'A' && js[i] <= 'F') || (js[i] >= 'a' && js[i] <= 'f'))) { if(DEBUG_PRINT)Print(m_key + " " + CharToString(js[i]) + " " + string(__LINE__)); return false; } // не hex
                    }
                    i--;
                    break;
                }
                default: break; /*{ return false; } // неразрешенный символ с экранированием */
            }
        }
    }
    return true;
}
//------------------------------------------------------------------	Escape
string CJAVal::Escape(string a)
{
    ushort as [], s []; int n = StringToShortArray(a, as); if(ArrayResize(s, 2 * n) != 2 * n) return NULL;
    int j = 0;
    for(int i = 0; i < n; i++)
    {
        switch(as[i])
        {
            case '\\': s[j] = '\\'; j++; s[j] = '\\'; j++; break;
            case '"': s[j] = '\\'; j++; s[j] = '"'; j++; break;
            case '/': s[j] = '\\'; j++; s[j] = '/'; j++; break;
            case 8: s[j] = '\\'; j++; s[j] = 'b'; j++; break;
            case 12: s[j] = '\\'; j++; s[j] = 'f'; j++; break;
            case '\n': s[j] = '\\'; j++; s[j] = 'n'; j++; break;
            case '\r': s[j] = '\\'; j++; s[j] = 'r'; j++; break;
            case '\t': s[j] = '\\'; j++; s[j] = 't'; j++; break;
            default: s[j] = as[i]; j++; break;
        }
    }
    a = ShortArrayToString(s, 0, j);
    return a;
}
//------------------------------------------------------------------	Unescape
string CJAVal::Unescape(string a)
{
    ushort as [], s []; int n = StringToShortArray(a, as); if(ArrayResize(s, n) != n) return NULL;
    int j = 0, i = 0;
    while(i < n)
    {
        ushort c = as[i];
        if(c == '\\' && i < n - 1)
        {
            switch(as[i + 1])
            {
                case '\\': c = '\\'; i++; break;
                case '"': c = '"'; i++; break;
                case '/': c = '/'; i++; break;
                case 'b': c = 8; /*08='\b'*/; i++; break;
                case 'f': c = 12;/*0c=\f*/ i++; break;
                case 'n': c = '\n'; i++; break;
                case 'r': c = '\r'; i++; break;
                case 't': c = '\t'; i++; break;
                    /*
                    case 'u': // \uXXXX
                      {
                       i+=2; ushort k=0;
                       for(int jj=0; jj<4 && i<n; jj++,i++)
                         {
                          c=as[i]; ushort h=0;
                          if(c>='0' && c<='9') h=c-'0';
                          else if(c>='A' && c<='F') h=c-'A'+10;
                          else if(c>='a' && c<='f') h=c-'a'+10;
                          else break; // не hex
                          k+=h*(ushort)pow(16,(3-jj));
                         }
                       i--;
                       c=k;
                       break;
                      }
                      */
            }
        }
        s[j] = c; j++; i++;
    }
    a = ShortArrayToString(s, 0, j);
    return a;
}
//+------------------------------------------------------------------+

// Telegram.mqh
// ------------------------------------------------------------------
//+------------------------------------------------------------------+
//|   Include                                                        |
//+------------------------------------------------------------------+
#include <Arrays/ArrayString.mqh>
#include <Arrays/List.mqh>
// #include <Telegram/Common.mqh>
// #include <Telegram/Jason.mqh>

//+------------------------------------------------------------------+
//|   Defines                                                        |
//+------------------------------------------------------------------+
#define TELEGRAM_BASE_URL "https://api.telegram.org"
#define WEB_TIMEOUT 5000
//+------------------------------------------------------------------+
//|   ENUM_CHAT_ACTION                                               |
//+------------------------------------------------------------------+
enum ENUM_CHAT_ACTION {
    ACTION_FIND_LOCATION,    //picking location...
    ACTION_RECORD_AUDIO,     //recording audio...
    ACTION_RECORD_VIDEO,     //recording video...
    ACTION_TYPING,           //typing...
    ACTION_UPLOAD_AUDIO,     //sending audio...
    ACTION_UPLOAD_DOCUMENT,  //sending file...
    ACTION_UPLOAD_PHOTO,     //sending photo...
    ACTION_UPLOAD_VIDEO      //sending video...
};
//+------------------------------------------------------------------+
//|   ChatActionToString                                             |
//+------------------------------------------------------------------+
string ChatActionToString(const ENUM_CHAT_ACTION _action)
{
    string result = EnumToString(_action);
    result = StringSubstr(result, 7);
    StringToLower(result);
    return (result);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CHAT_TYPE {
    CHAT_UNKNOWN,    // unknown
    CHAT_CHANNEL,    // channel
    CHAT_GROUP,      // group
    CHAT_PRIVATE,    // private
    CHAT_SUPERGROUP  // supergroup
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_CHAT_TYPE StringToChatType(const string text)
{
    if(text == "channel")
        return CHAT_CHANNEL;

    if(text == "group")
        return CHAT_GROUP;

    if(text == "private")
        return CHAT_PRIVATE;

    if(text == "supergroup")
        return CHAT_SUPERGROUP;
    //---
    return CHAT_UNKNOWN;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TChatInfo {
    bool           valid;  // existing/nonexistent
    long           id;
    ENUM_CHAT_TYPE type;
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCustomMessage : public CObject {
    public:
    bool done;
    long update_id;
    long message_id;
    //---
    long   from_id;
    string from_first_name;
    string from_last_name;
    string from_username;
    //---
    long   chat_id;
    string chat_first_name;
    string chat_last_name;
    string chat_username;
    string chat_type;
    //---
    datetime message_date;
    string   message_text;

    CCustomMessage()
    {
        done = false;
        update_id = 0;
        message_id = 0;
        from_id = 0;
        from_first_name = NULL;
        from_last_name = NULL;
        from_username = NULL;
        chat_id = 0;
        chat_first_name = NULL;
        chat_last_name = NULL;
        chat_username = NULL;
        chat_type = NULL;
        message_date = 0;
        message_text = NULL;
        from_id = 0;
        from_first_name = NULL;
        from_last_name = NULL;
        from_username = NULL;
        chat_id = 0;
        chat_first_name = NULL;
        chat_last_name = NULL;
        chat_username = NULL;
        chat_type = NULL;
        message_date = 0;
        message_text = NULL;
    }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCustomChat : public CObject {
    public:
    long           m_id;
    CCustomMessage m_last;
    CCustomMessage m_new_one;
    int            m_state;
    datetime       m_time;
};
//+------------------------------------------------------------------+
//|   CCustomBot                                                     |
//+------------------------------------------------------------------+
class CCustomBot {
    private:
    //+------------------------------------------------------------------+
    void ArrayAdd(uchar& dest [], const uchar& src [])
    {
        int src_size = ArraySize(src);
        if(src_size == 0)
            return;

        int dest_size = ArraySize(dest);
        ArrayResize(dest, dest_size + src_size, 500);
        ArrayCopy(dest, src, dest_size, 0, src_size);
    }

    //+------------------------------------------------------------------+
    void ArrayAdd(char& dest [], const string text)
    {
        int len = StringLen(text);
        if(len > 0) {
            uchar src [];
            for(int i = 0; i < len; i++) {
                ushort ch = StringGetCharacter(text, i);

                uchar array [];
                int   total = ShortToUtf8(ch, array);

                int size = ArraySize(src);
                ArrayResize(src, size + total);
                ArrayCopy(src, array, size, 0, total);
            }
            ArrayAdd(dest, src);
        }
    }

    //+------------------------------------------------------------------+
    int SaveToFile(const string filename,
                   const char& text [])
    {
        ResetLastError();

        int handle = FileOpen(filename, FILE_BIN | FILE_ANSI | FILE_WRITE);
        if(handle == INVALID_HANDLE) {
            return (_LastError);
        }
        FileWriteArray(handle, text);
        FileClose(handle);
        return (0);
    }

    //+------------------------------------------------------------------+
    string UrlEncode(const string text)
    {
        string result = NULL;
        int    length = StringLen(text);
        for(int i = 0; i < length; i++) {
            ushort ch = StringGetCharacter(text, i);

            if((ch >= 48 && ch <= 57) ||   // 0-9
                (ch >= 65 && ch <= 90) ||   // A-Z
                (ch >= 97 && ch <= 122) ||  // a-z
                (ch == '!') || (ch == '\'') || (ch == '(') ||
                (ch == ')') || (ch == '*') || (ch == '-') ||
                (ch == '.') || (ch == '_') || (ch == '~')) {
                result += ShortToString(ch);
            }
            else {
                if(ch == ' ')
                    result += ShortToString('+');
                else {
                    uchar array [];
                    int   total = ShortToUtf8(ch, array);
                    for(int k = 0; k < total; k++)
                        result += StringFormat("%%%02X", array[k]);
                }
            }
        }
        return result;
    }

    protected:
    CList m_chats;

    private:
    string       m_token;
    string       m_name;
    long         m_update_id;
    CArrayString m_users_filter;
    bool         m_first_remove;

    //---
    TErrorInfo m_error;

    //+------------------------------------------------------------------+
    int PostRequest(string& out,
                    const string url,
                    const string params,
                    const int    timeout = 5000)
    {
        char data [];
        int  data_size = StringLen(params);
        StringToCharArray(params, data, 0, data_size);

        uchar  result [];
        string result_headers;

        //--- application/x-www-form-urlencoded
        int res = WebRequest("POST", url, NULL, NULL, timeout, data, data_size, result, result_headers);
        //Print("WebRequest ",res," ",CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8),"/",ArraySize(result));
        if(res == 200)  //OK
        {
            //--- delete BOM
            int start_index = 0;
            int size = ArraySize(result);
            for(int i = 0; i < fmin(size, 8); i++) {
                if(result[i] == 0xef || result[i] == 0xbb || result[i] == 0xbf)
                    start_index = i + 1;
                else
                    break;
            }
            //---
            out = CharArrayToString(result, start_index, WHOLE_ARRAY, CP_UTF8);
            return (0);
        }
        else {
            if(res == -1) {
                return (_LastError);
            }
            else {
                //--- HTTP errors
                if(res >= 100 && res <= 511) {
                    out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                    return (ERR_HTTP_ERROR_FIRST + res);
                }
                return (res);
            }
        }

        return (0);
    }

    //+------------------------------------------------------------------+
    int ShortToUtf8(const ushort _ch, uchar& out [])
    {
        //---
        if(_ch < 0x80) {
            ArrayResize(out, 1);
            out[0] = (uchar) _ch;
            return (1);
        }
        //---
        if(_ch < 0x800) {
            ArrayResize(out, 2);
            out[0] = (uchar) ((_ch >> 6) | 0xC0);
            out[1] = (uchar) ((_ch & 0x3F) | 0x80);
            return (2);
        }
        //---
        if(_ch < 0xFFFF) {
            if(_ch >= 0xD800 && _ch <= 0xDFFF)  //Ill-formed
            {
                ArrayResize(out, 1);
                out[0] = ' ';
                return (1);
            }
            else if(_ch >= 0xE000 && _ch <= 0xF8FF)  //Emoji
            {
                int ch = 0x10000 | _ch;
                ArrayResize(out, 4);
                out[0] = (uchar) (0xF0 | (ch >> 18));
                out[1] = (uchar) (0x80 | ((ch >> 12) & 0x3F));
                out[2] = (uchar) (0x80 | ((ch >> 6) & 0x3F));
                out[3] = (uchar) (0x80 | ((ch & 0x3F)));
                return (4);
            }
            else {
                ArrayResize(out, 3);
                out[0] = (uchar) ((_ch >> 12) | 0xE0);
                out[1] = (uchar) (((_ch >> 6) & 0x3F) | 0x80);
                out[2] = (uchar) ((_ch & 0x3F) | 0x80);
                return (3);
            }
        }
        ArrayResize(out, 3);
        out[0] = 0xEF;
        out[1] = 0xBF;
        out[2] = 0xBD;
        return (3);
    }

    //+------------------------------------------------------------------+
    string StringDecode(string text)
    {
        //--- replace \n
        StringReplace(text, "\n", ShortToString(0x0A));

        //--- replace \u0000
        int haut = 0;
        int pos = StringFind(text, "\\u");
        while(pos != -1) {
            string strcode = StringSubstr(text, pos, 6);
            string strhex = StringSubstr(text, pos + 2, 4);

            StringToUpper(strhex);

            int total = StringLen(strhex);
            int result = 0;
            for(int i = 0, k = total - 1; i < total; i++, k--) {
                int    coef = (int) pow(2, 4 * k);
                ushort ch = StringGetCharacter(strhex, i);
                if(ch >= '0' && ch <= '9')
                    result += (ch - '0') * coef;
                if(ch >= 'A' && ch <= 'F')
                    result += (ch - 'A' + 10) * coef;
            }

            if(haut != 0) {
                if(result >= 0xDC00 && result <= 0xDFFF) {
                    int dec = ((haut - 0xD800) << 10) + (result - 0xDC00);  //+0x10000;
                    StringReplace(text, pos, 6, ShortToString((ushort) dec));
                    haut = 0;
                }
                else {
                    //--- error: Second byte out of range
                    haut = 0;
                }
            }
            else {
                if(result >= 0xD800 && result <= 0xDBFF) {
                    haut = result;
                    StringReplace(text, pos, 6, "");
                }
                else {
                    StringReplace(text, pos, 6, ShortToString((ushort) result));
                }
            }

            pos = StringFind(text, "\\u", pos);
        }
        return (text);
    }

    //+------------------------------------------------------------------+
    int StringReplace(string& string_var,
                      const int    start_pos,
                      const int    length,
                      const string replacement)
    {
        string temp = (start_pos == 0) ? "" : StringSubstr(string_var, 0, start_pos);
        temp += replacement;
        temp += StringSubstr(string_var, start_pos + length);
        string_var = temp;
        return (StringLen(replacement));
    }

    //+------------------------------------------------------------------+
    string BoolToString(const bool _value)
    {
        if(_value) return ("true");
        return ("false");
    }

    protected:
    //+------------------------------------------------------------------+
    string StringTrim(string text)
    {
#ifdef __MQL4__
        text = StringTrimLeft(text);
        text = StringTrimRight(text);
#endif
#ifdef __MQL5__
        StringTrimLeft(text);
        StringTrimRight(text);
#endif
        return (text);
    }

    public:
    //+------------------------------------------------------------------+
    void CCustomBot()
    {
        m_token = NULL;
        m_name = NULL;
        m_update_id = 0;
        m_first_remove = true;
        m_chats.Clear();
        m_users_filter.Clear();
    }

    //+------------------------------------------------------------------+
    int ChatsTotal()
    {
        return (m_chats.Total());
    }

    //+------------------------------------------------------------------+
    int Token(const string _token)
    {
        string token = StringTrim(_token);
        if(token == "")
            return (ERR_TOKEN_ISEMPTY);
        //---
        m_token = token;
        return (0);
    }

    //+------------------------------------------------------------------+
    void UserNameFilter(const string username_list)
    {
        m_users_filter.Clear();

        //--- parsing
        string text = StringTrim(username_list);
        if(text == "")
            return;

        //---
        while(StringReplace(text, "  ", " ") > 0)
            ;
        StringReplace(text, ";", " ");
        StringReplace(text, ",", " ");

        //---
        string array [];
        int    amount = StringSplit(text, ' ', array);
        for(int i = 0; i < amount; i++) {
            string username = StringTrim(array[i]);
            if(username != "") {
                //--- remove first @
                if(StringGetCharacter(username, 0) == '@')
                    username = StringSubstr(username, 1);

                m_users_filter.Add(username);
            }
        }
    }
    //+------------------------------------------------------------------+
    string Name() { return (m_name); }

    //+------------------------------------------------------------------+
    string GetErrorDescription(const ENUM_LANGUAGE _lang = LANGUAGE_EN)
    {
        return GetErrorDescription(m_error.code, _lang);
    }

    //+------------------------------------------------------------------+
    int GetErrorCode() { return m_error.code; }

    //+------------------------------------------------------------------+
    int GetMe()
    {
        m_error.code = 0;

        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }
        //---
        string out;
        string url = StringFormat("%s/bot%s/getMe", TELEGRAM_BASE_URL, m_token);
        string params = "";
        m_error.code = PostRequest(out, url, params, WEB_TIMEOUT);
        if(m_error.code == 0) {
            CJAVal js(NULL, jtUNDEF);
            //---
            bool done = js.Deserialize(out);
            if(!done) {
                m_error.code = ERR_JSON_PARSING;
                return m_error.code;
            }
            //---
            bool ok = js["ok"].ToBool();
            if(!ok) {
                m_error.code = ERR_JSON_NOT_OK;
                return m_error.code;
            }
            //---
            if(m_name == NULL)
                m_name = js["result"]["username"].ToStr();
        }
        //---
        return (m_error.code);
    }
    //+------------------------------------------------------------------+
    int GetUpdates()
    {
        m_error.code = 0;

        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }

        string out;
        string url = StringFormat("%s/bot%s/getUpdates", TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("offset=%d", m_update_id);
        //---
        m_error.code = PostRequest(out, url, params, WEB_TIMEOUT);
        if(m_error.code == 0) {
            //Print(out);
            //--- parse result
            CJAVal js(NULL, jtUNDEF);
            bool   done = js.Deserialize(out);
            if(!done) {
                m_error.code = ERR_JSON_PARSING;
                return m_error.code;
            }
            //---
            bool ok = js["ok"].ToBool();
            if(!ok) {
                m_error.code = ERR_JSON_NOT_OK;
                return m_error.code;
            }

            CCustomMessage msg;

            int total = ArraySize(js["result"].m_e);
            for(int i = 0; i < total; i++) {
                CJAVal item = js["result"].m_e[i];
                //---
                msg.update_id = item["update_id"].ToInt();
                //---
                msg.message_id = item["message"]["message_id"].ToInt();
                msg.message_date = (datetime) item["message"]["date"].ToInt();
                //---
                msg.message_text = item["message"]["text"].ToStr();
                msg.message_text = StringDecode(msg.message_text);
                //---
                msg.from_id = item["message"]["from"]["id"].ToInt();

                msg.from_first_name = item["message"]["from"]["first_name"].ToStr();
                msg.from_first_name = StringDecode(msg.from_first_name);

                msg.from_last_name = item["message"]["from"]["last_name"].ToStr();
                msg.from_last_name = StringDecode(msg.from_last_name);

                msg.from_username = item["message"]["from"]["username"].ToStr();
                msg.from_username = StringDecode(msg.from_username);
                //---
                msg.chat_id = item["message"]["chat"]["id"].ToInt();

                msg.chat_first_name = item["message"]["chat"]["first_name"].ToStr();
                msg.chat_first_name = StringDecode(msg.chat_first_name);

                msg.chat_last_name = item["message"]["chat"]["last_name"].ToStr();
                msg.chat_last_name = StringDecode(msg.chat_last_name);

                msg.chat_username = item["message"]["chat"]["username"].ToStr();
                msg.chat_username = StringDecode(msg.chat_username);

                msg.chat_type = item["message"]["chat"]["type"].ToStr();

                m_update_id = msg.update_id + 1;

                if(m_first_remove)
                    continue;

                //--- filter
                if(m_users_filter.Total() == 0 || (m_users_filter.Total() > 0 && m_users_filter.SearchLinear(msg.from_username) >= 0)) {
                    //--- find the chat
                    int index = -1;
                    for(int j = 0; j < m_chats.Total(); j++) {
                        CCustomChat* chat = m_chats.GetNodeAtIndex(j);
                        if(chat.m_id == msg.chat_id) {
                            index = j;
                            break;
                        }
                    }

                    //--- add new one to the chat list
                    if(index == -1) {
                        m_chats.Add(new CCustomChat);
                        CCustomChat* chat = m_chats.GetLastNode();
                        chat.m_id = msg.chat_id;
                        chat.m_time = TimeLocal();
                        chat.m_state = 0;
                        chat.m_new_one.message_text = msg.message_text;
                        chat.m_new_one.done = false;
                        Print(msg.chat_id);

                    }
                    //--- update chat message
                    else {
                        CCustomChat* chat = m_chats.GetNodeAtIndex(index);
                        chat.m_time = TimeLocal();
                        chat.m_new_one.message_text = msg.message_text;
                        chat.m_new_one.done = false;
                    }
                }
            }
            m_first_remove = false;
        }
        //---
        return (m_error.code);
    }

    //+------------------------------------------------------------------+
    int SendChatAction(const long             _chat_id,
                       const ENUM_CHAT_ACTION _action)
    {
        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }
        string out;
        string url = StringFormat("%s/bot%s/sendChatAction", TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("chat_id=%lld&action=%s", _chat_id, ChatActionToString(_action));

        m_error.code = PostRequest(out, url, params, WEB_TIMEOUT);
        return (m_error.code);
    }

    //+------------------------------------------------------------------+
    int SendPhoto(const long   _chat_id,
                  const string _photo_id,
                  const string _caption = NULL)
    {
        m_error.code = 0;

        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }

        string out;
        string url = StringFormat("%s/bot%s/sendPhoto", TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("chat_id=%lld&photo=%s", _chat_id, _photo_id);
        if(_caption != NULL)
            params += "&caption=" + UrlEncode(_caption);

        m_error.code = PostRequest(out, url, params, WEB_TIMEOUT);
        if(m_error.code != 0) {
            //--- parse result
            CJAVal js(NULL, jtUNDEF);
            bool   done = js.Deserialize(out);
            if(!done)
                return (ERR_JSON_PARSING);

            //--- get error description
            bool   ok = js["ok"].ToBool();
            long   err_code = js["error_code"].ToInt();
            string err_desc = js["description"].ToStr();
        }
        //--- done
        return (m_error.code);
    }

    //+------------------------------------------------------------------+
    int SendPhoto(string& _photo_id,
                  const string _channel_name,
                  const string _local_path,
                  const string _caption = NULL,
                  const bool   _common_flag = false,
                  const int    _timeout = 10000)
    {
        m_error.code = 0;
        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }

        string name = StringTrim(_channel_name);
        if(StringGetCharacter(name, 0) != '@')
            name = "@" + name;

        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }

        ResetLastError();
        //--- copy file to memory buffer
        if(!FileIsExist(_local_path, _common_flag))
            return (ERR_FILE_NOT_EXIST);

        //---
        int flags = FILE_READ | FILE_BIN | FILE_SHARE_WRITE | FILE_SHARE_READ;
        if(_common_flag)
            flags |= FILE_COMMON;

        //---
        int file = FileOpen(_local_path, flags);
        if(file < 0) {
            m_error.code = _LastError;
            return m_error.code;
        }

        //---
        int   file_size = (int) FileSize(file);
        uchar photo [];
        ArrayResize(photo, file_size);
        FileReadArray(file, photo, 0, file_size);
        FileClose(file);

        //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
        uchar base64 [];
        uchar key [];
        CryptEncode(CRYPT_BASE64, photo, key, base64);
        //---
        uchar temp[1024] = { 0 };
        ArrayCopy(temp, base64, 0, 0, 1024);
        //---
        uchar md5 [];
        CryptEncode(CRYPT_HASH_MD5, temp, key, md5);
        //---
        string hash = NULL;
        int    total = ArraySize(md5);
        for(int i = 0; i < total; i++)
            hash += StringFormat("%02X", md5[i]);
        hash = StringSubstr(hash, 0, 16);

        //--- WebRequest
        uchar  result [];
        string result_headers;

        string url = StringFormat("%s/bot%s/sendPhoto", TELEGRAM_BASE_URL, m_token);

        //--- 1
        uchar data [];

        //--- add chart_id
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, "--" + hash + "\r\n");
        ArrayAdd(data, "Content-Disposition: form-data; name=\"chat_id\"\r\n");
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, name);
        ArrayAdd(data, "\r\n");

        if(StringLen(_caption) > 0) {
            ArrayAdd(data, "--" + hash + "\r\n");
            ArrayAdd(data, "Content-Disposition: form-data; name=\"caption\"\r\n");
            ArrayAdd(data, "\r\n");
            ArrayAdd(data, _caption);
            ArrayAdd(data, "\r\n");
        }

        ArrayAdd(data, "--" + hash + "\r\n");
        ArrayAdd(data, "Content-Disposition: form-data; name=\"photo\"; filename=\"lampash.gif\"\r\n");
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, photo);
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, "--" + hash + "--\r\n");

        // SaveToFile("debug.txt",data);

        //---
        string headers = "Content-Type: multipart/form-data; boundary=" + hash + "\r\n";
        int    res = WebRequest("POST", url, headers, _timeout, data, result, result_headers);
        if(res == 200)  //OK
        {
            //--- delete BOM
            int start_index = 0;
            int size = ArraySize(result);
            for(int i = 0; i < fmin(size, 8); i++) {
                if(result[i] == 0xef || result[i] == 0xbb || result[i] == 0xbf)
                    start_index = i + 1;
                else
                    break;
            }

            //---
            string out = CharArrayToString(result, start_index, WHOLE_ARRAY, CP_UTF8);

            //--- parse result
            CJAVal js(NULL, jtUNDEF);
            bool   done = js.Deserialize(out);
            if(!done)
                return (ERR_JSON_PARSING);

            //--- get error description
            bool ok = js["ok"].ToBool();
            if(!ok)
                return (ERR_JSON_NOT_OK);

            total = ArraySize(js["result"]["photo"].m_e);
            for(int i = 0; i < total; i++) {
                CJAVal image = js["result"]["photo"].m_e[i];

                long image_size = image["file_size"].ToInt();
                if(image_size <= file_size)
                    _photo_id = image["file_id"].ToStr();
            }

            return (0);
        }
        else {
            if(res == -1) {
                string out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                //Print(out);
                return (_LastError);
            }
            else {
                if(res >= 100 && res <= 511) {
                    string out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                    //Print(out);
                    return (ERR_HTTP_ERROR_FIRST + res);
                }
                return (res);
            }
        }
        //---
        return (0);
    }

    //+------------------------------------------------------------------+
    int SendPhoto(string& _photo_id,
                  const long   _chat_id,
                  const string _local_path,
                  const string _caption = NULL,
                  const bool   _common_flag = false,
                  const int    _timeout = 10000)
    {
        m_error.code = 0;
        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }

        ResetLastError();
        //--- copy file to memory buffer
        if(!FileIsExist(_local_path, _common_flag))
            return (ERR_FILE_NOT_EXIST);

        //---
        int flags = FILE_READ | FILE_BIN | FILE_SHARE_WRITE | FILE_SHARE_READ;
        if(_common_flag)
            flags |= FILE_COMMON;

        //---
        int file = FileOpen(_local_path, flags);
        if(file < 0) {
            m_error.code = _LastError;
            return m_error.code;
        }

        //---
        int   file_size = (int) FileSize(file);
        uchar photo [];
        ArrayResize(photo, file_size);
        FileReadArray(file, photo, 0, file_size);
        FileClose(file);

        //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
        uchar base64 [];
        uchar key [];
        CryptEncode(CRYPT_BASE64, photo, key, base64);
        //---
        uchar temp[1024] = { 0 };
        ArrayCopy(temp, base64, 0, 0, 1024);
        //---
        uchar md5 [];
        CryptEncode(CRYPT_HASH_MD5, temp, key, md5);
        //---
        string hash = NULL;
        int    total = ArraySize(md5);
        for(int i = 0; i < total; i++)
            hash += StringFormat("%02X", md5[i]);
        hash = StringSubstr(hash, 0, 16);

        //--- WebRequest
        uchar  result [];
        string result_headers;

        string url = StringFormat("%s/bot%s/sendPhoto", TELEGRAM_BASE_URL, m_token);

        //--- 1
        uchar data [];

        //--- add chart_id
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, "--" + hash + "\r\n");
        ArrayAdd(data, "Content-Disposition: form-data; name=\"chat_id\"\r\n");
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, IntegerToString(_chat_id));
        ArrayAdd(data, "\r\n");

        if(StringLen(_caption) > 0) {
            ArrayAdd(data, "--" + hash + "\r\n");
            ArrayAdd(data, "Content-Disposition: form-data; name=\"caption\"\r\n");
            ArrayAdd(data, "\r\n");
            ArrayAdd(data, _caption);
            ArrayAdd(data, "\r\n");
        }

        ArrayAdd(data, "--" + hash + "\r\n");
        ArrayAdd(data, "Content-Disposition: form-data; name=\"photo\"; filename=\"lampash.gif\"\r\n");
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, photo);
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, "--" + hash + "--\r\n");

        // SaveToFile("debug.txt",data);

        //---
        string headers = "Content-Type: multipart/form-data; boundary=" + hash + "\r\n";
        int    res = WebRequest("POST", url, headers, _timeout, data, result, result_headers);
        if(res == 200)  //OK
        {
            //--- delete BOM
            int start_index = 0;
            int size = ArraySize(result);
            for(int i = 0; i < fmin(size, 8); i++) {
                if(result[i] == 0xef || result[i] == 0xbb || result[i] == 0xbf)
                    start_index = i + 1;
                else
                    break;
            }

            //---
            string out = CharArrayToString(result, start_index, WHOLE_ARRAY, CP_UTF8);

            //--- parse result
            CJAVal js(NULL, jtUNDEF);
            bool   done = js.Deserialize(out);
            if(!done)
                return (ERR_JSON_PARSING);

            //--- get error description
            bool ok = js["ok"].ToBool();
            if(!ok)
                return (ERR_JSON_NOT_OK);

            total = ArraySize(js["result"]["photo"].m_e);
            for(int i = 0; i < total; i++) {
                CJAVal image = js["result"]["photo"].m_e[i];

                long image_size = image["file_size"].ToInt();
                if(image_size <= file_size)
                    _photo_id = image["file_id"].ToStr();
            }

            return (0);
        }
        else {
            if(res == -1) {
                string out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                //Print(out);
                return (_LastError);
            }
            else {
                if(res >= 100 && res <= 511) {
                    string out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                    //Print(out);
                    return (ERR_HTTP_ERROR_FIRST + res);
                }
                return (res);
            }
        }
        //---
        return (0);
    }
    //+------------------------------------------------------------------+
    virtual void ProcessMessages(void);

    //+------------------------------------------------------------------+
    int SendMessage(const long   _chat_id,
                    const string _text,
                    const string _reply_markup = NULL,
                    const bool   _as_HTML = false,
                    const bool   _silently = false)
    {
        m_error.code = 0;
        //--- check token
        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }

        string out;
        string url = StringFormat("%s/bot%s/sendMessage", TELEGRAM_BASE_URL, m_token);

        string params = StringFormat("chat_id=%lld&text=%s", _chat_id, UrlEncode(_text));
        if(_reply_markup != NULL)
            params += "&reply_markup=" + _reply_markup;
        if(_as_HTML)
            params += "&parse_mode=HTML";
        if(_silently)
            params += "&disable_notification=true";

        m_error.code = PostRequest(out, url, params, WEB_TIMEOUT);
        return (m_error.code);
    }

    //+------------------------------------------------------------------+
    int SendMessage(const string _channel_name,
                    const string _text,
                    const bool   _as_HTML = false,
                    const bool   _silently = false)
    {
        m_error.code = 0;
        //--- check token
        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }

        string name = StringTrim(_channel_name);
        if(StringGetCharacter(name, 0) != '@')
            name = "@" + name;

        string out;
        string url = StringFormat("%s/bot%s/sendMessage", TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("chat_id=%s&text=%s", name, UrlEncode(_text));
        if(_as_HTML)
            params += "&parse_mode=HTML";
        if(_silently)
            params += "&disable_notification=true";

        m_error.code = PostRequest(out, url, params, WEB_TIMEOUT);
        return (m_error.code);
    }

    //+------------------------------------------------------------------+
    int GetChat(TChatInfo& chat_info, const string _channel_name)
    {
        ZeroMemory(chat_info);

        //--- check token
        if(m_token == NULL) {
            m_error.code = ERR_TOKEN_ISEMPTY;
            return m_error.code;
        }

        //--- check channel name
        string name = StringTrim(_channel_name);
        if(StringGetCharacter(name, 0) != '@')
            name = "@" + name;

        string out;
        string url = StringFormat("%s/bot%s/getChat", TELEGRAM_BASE_URL, m_token);
        string params = "chat_id=" + name;
        int    res = PostRequest(out, url, params, WEB_TIMEOUT);

        //--- parse result
        CJAVal js(NULL, jtUNDEF);
        bool   done = js.Deserialize(out);
        if(!done)
            return (ERR_JSON_PARSING);

        //--- get error description
        bool ok = js["ok"].ToBool();

        //{"ok":true,"result":{"id":-1001034068244,"title":"ForexSignalChannel","username":"forexsignalchannel","type":"channel","photo":{"small_file_id":"AQADAgAT8NqCKgAEeijjaWcwHww1oQEAAQI","big_file_id":"AQADAgAT8NqCKgAE4584GxtOaDM3oQEAAQI"}}}
        //{"ok":false,"error_code":400,"description":"Bad Request: chat not found"}
        if(ok) {
            chat_info.valid = true;
            chat_info.id = js["result"]["id"].ToInt();
            chat_info.type = StringToChatType(js["result"]["type"].ToStr());
        }
        else {
            chat_info.valid = false;
            int    error_code = (int) js["error_code"].ToInt();
            string error_desc = js["description"].ToStr();
        }
        //---
        return (res);
    }
    //+------------------------------------------------------------------+
    string ReplyKeyboardMarkup(const string keyboard,
                               const bool   resize,
                               const bool   one_time)
    {
        string result = StringFormat("{\"keyboard\": %s, \"one_time_keyboard\": %s, \"resize_keyboard\": %s, \"selective\": false}", UrlEncode(keyboard), BoolToString(resize), BoolToString(one_time));
        return (result);
    }

    //+------------------------------------------------------------------+
    string ReplyKeyboardHide()
    {
        return ("{\"hide_keyboard\": true}");
    }

    //+------------------------------------------------------------------+
    string ForceReply()
    {
        return ("{\"force_reply\": true}");
    }
};
//+------------------------------------------------------------------+



/*
*************************************************************************************************************
*************************************************************************************************************
*************************************************************************************************************
*************************************************************************************************************
*************************************************************************************************************
*/
//+------------------------------------------------------------------+
//|   CMyBot                                                         |
//+------------------------------------------------------------------+
class CMyBot : public CCustomBot
{
    private:
    ENUM_LANGUAGE   m_lang;
    string          m_symbol;
    ENUM_TIMEFRAMES m_period;
    string          m_template;
    CArrayString    m_templates;

    public:
    void Language(const ENUM_LANGUAGE _lang)
    {
        m_lang = _lang;
    }

    //+------------------------------------------------------------------+
    int Templates(const string _list)
    {
        m_templates.Clear();
        //--- parsing
        string text = StringTrim(_list);
        if(text == "")
            return (0);

        //---
        while(StringReplace(text, "  ", " ") > 0)
            ;
        StringReplace(text, ";", " ");
        StringReplace(text, ",", " ");

        //---
        string array [];
        int    amount = StringSplit(text, ' ', array);
        amount = fmin(amount, 5);

        for(int i = 0; i < amount; i++) {
            array[i] = StringTrim(array[i]);
            if(array[i] != "")
                m_templates.Add(array[i]);
        }

        return (amount);
    }

    //+------------------------------------------------------------------+
    int SendScreenShot(const long            _chat_id,
                       const string          _symbol,
                       const ENUM_TIMEFRAMES _period,
                       const string          _template = NULL)
    {
        int result = 0;

        long chart_id = ChartOpen(_symbol, _period);
        if(chart_id == 0)
            return (ERR_CHART_NOT_FOUND);

        ChartSetInteger(ChartID(), CHART_BRING_TO_TOP, true);

        //--- updates chart
        int wait = 60;
#ifdef __MQL5__

        while(--wait > 0) {
            if(SeriesInfoInteger(_symbol, _period, SERIES_SYNCHRONIZED))
                break;
            Sleep(500);
        }
#endif

        if(_template != NULL)
            if(!ChartApplyTemplate(chart_id, _template))
                PrintError(_LastError, InpLanguage);

        ChartRedraw(chart_id);
        Sleep(500);

        ChartSetInteger(chart_id, CHART_SHOW_GRID, false);
        ChartSetInteger(chart_id, CHART_MODE, CHART_CANDLES);
        ChartSetInteger(chart_id, CHART_SHOW_PERIOD_SEP, false);

        string filename = StringFormat("%s%d.gif", _symbol, _period);

        if(FileIsExist(filename))
            FileDelete(filename);
        ChartRedraw(chart_id);

        Sleep(100);

        if(ChartScreenShot(chart_id, filename, 800, 600, ALIGN_RIGHT)) {
            Sleep(100);

            bot.SendChatAction(_chat_id, ACTION_UPLOAD_PHOTO);

            //--- waitng 30 sec for save screenshot
            wait = 60;
            while(!FileIsExist(filename) && --wait > 0)
                Sleep(500);

            //---
            if(FileIsExist(filename)) {
                string screen_id;
                result = bot.SendPhoto(screen_id, _chat_id, filename, _symbol + " " + StringSubstr(EnumToString(_period), 7));
            }
            else {
                string mask = m_lang == LANGUAGE_EN ? "Screenshot file '%s' not created." : "Файл скриншота '%s' не создан.";
                PrintFormat(mask, filename);
            }
        }

        ChartClose(chart_id);
        return (result);
    }
};

// Definiciones de Telegram:
#define EXPERT_NAME "Telegram conection"
#define EXPERT_VERSION "2.00"
#property version EXPERT_VERSION
#define CAPTION_COLOR clrWhite
#define LOSS_COLOR clrOrangeRed
//+------------------------------------------------------------------+
//|   TELEGRAM Input parameters                                      |
//+------------------------------------------------------------------+
ENUM_LANGUAGE    InpLanguage = LANGUAGE_EN;                                       //Language:
ENUM_UPDATE_MODE InpUpdateMode = UPDATE_NORMAL;                                     //Update Mode:
input bool TelegramOn = true; // Telegram On:
input string     InpToken = "5522964431:AAGisI-heJUa7uyPPQu1zbFj4CNiIZXyzw8";  //Token:
input string     InpChannelName = "ttrPruebas_bot";
input long       InpChannelNro = -1001779335873;  //Channel Nro:
string           InpUserNameFilter = "";              //Whitelist Usernames:
input string     InpTemplates = "Clean";      //Template to telegram pic:
//---

CComment            comment;
CMyBot              bot;

const ENUM_RUN_MODE run_mode = GetRunMode();
datetime time_check;
int      web_error;
int      init_error;
string   photo_id = NULL;
//


#endif 


// ——————————————————————————————————————————————————————————————————
enum ModeLevels {
    FixPips,            // Fix Pips
    byMoney,            // Money
    PipsFromOpenCandle  // Pips from Candle
};
enum TSLMode {
    byPips,  // By Pips
    byMA     // By Moving Average
};
enum ModeCalcLots {
    FixLots,         // Fix Lots
    EquityPercent,  // by Equity Percent
    // Money,           // by Money
    // AccountPercent,  // by Account Percent
};

enum CloseAllMode {
    CloseByMoney,           // by Money
    CloseByAccountPercent,  // by Account Percent
    CloseByPips             // By Pips
};
enum enumDays {
    sunday,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    EA_OFF
};
enum ModeEntry {
    Market,
    PendingStop,
    PendingLimit
};

bool CloseCandleMode = false;  // meter en la clase CloseCandle
// ——————————————————————————————————————————————————————————————————

#ifdef CONTROL_CUSTOM_INDICATOR_FILE

string file_custom_indicator = "";
int bufferToBuy = ;
int bufferToSell = ;

input string Tindi = "== Indicator Setup ==";  // ————————————

#endif

#ifdef PENDING_ENTRYS
input string    Tpom = "== Pending or Market Setup ==";  // ————————————
input ModeEntry modeEntry = Market;                           // Mode Entry:
input double    uEntryDistance = 10;                               // Pips distance for pending orders:
input bool      uDeletePendingsOn = true;                             // Delete pendings when close all:
#else
ModeEntry modeEntry = Market;  // Mode Entry:
double    uEntryDistance = 0;       // Pips distance for pending orders:
bool      uDeletePendingsOn = false;   // Delete pendings when close all:
#endif

input string T0 = "== Trade Setup ==";  // ————————————
#ifdef MAX_TRADES_AT_SAME_TIME
input int uMaxTrades = 1;  // Max Trades At Same Time:
#endif
input bool         uTradeReverse = false;              // Trade Reverse:
input int          magico = 2022;               // Magic Number:
input string       Tvolumen = "= Volumen =";      // ————————————
input ModeCalcLots modeCalcLots = FixLots;            // Mode to Calc Lots:
input double       userLots = 0.01;               // Fixed Lots:
input double       userEquityPer = 1;                  // Setup Lots by "Equity Percent":
// double             userMoney               = 10;                 // Setup Lots by "Money":
// double             userBalancePer          = 0.1;                // Setup Lots by "Account 
input string       T01 = "= Take Profit =";           // ————————————
input bool         takeProfitOn = true;                        // Take Profit On:
input ModeLevels   modeTP = PipsFromOpenCandle;          // Mode Take Profit:
input int          userTPpips = 1;                           // Pips TP
input double       userTPmoney = 15;                          // Money TP
input string       T02 = "= Stop Loss =";             // ————————————
input bool         stopLossOn = true;                        // Stop Loss On:
input ModeLevels   modeSL = PipsFromOpenCandle;          // Mode Stop Loss:
input int          userSLpips = 1;                           // Pips SL
input double       userSLmoney = 15;                          // Money SL

#ifdef SPREAD_FILTER
input string Tspread = "== Spread Filter ==";  // ————————————
input bool   SpreadFilterOn = false;                   // Spread Filter On:
input double uSpreadMax = 100;                    // Max Spread points:
#endif

#ifdef DAILY_LIMITS
enum DayLimitsMode {
    LimitsByAmount,         // by Amount
    LimitsByAccountPercent  // by Account %
};
input string        Tlimits = "== Daily Limits Setup ==";  // ————————————
input bool          uDailyProfitOn = false;                       // Control Daily Profit On:
input DayLimitsMode limitProfitMode = LimitsByAmount;              // Mode to control daily profit:
input double        uDayLimitProfit = 2000;                        // Max Daily Profit ($ or %):
input bool          uDailyLossOn = false;                       // Control Daily Loss On:
input DayLimitsMode limitLossMode = LimitsByAmount;              // Mode to control daily loss:
input double        uDayLimitLoss = -1000;                       // Max Daily Loss ($ or %):
input bool          uConsiderFloatting = false;                       // Consider Floating:
#else
enum DayLimitsMode {
    LimitsByAmount,         // by Amount
    LimitsByAccountPercent  // by Account %
};
bool          uDailyProfitOn = false;                      // Control Daily Profit On:
DayLimitsMode limitProfitMode = LimitsByAmount;             // Mode to control daily profit:
double        uDayLimitProfit = 2000;                       // Max Daily Profit ($ or %):
bool          uDailyLossOn = false;                      // Control Daily Loss On:
DayLimitsMode limitLossMode = LimitsByAmount;             // Mode to control daily loss:
double        uDayLimitLoss = -1000;                      // Max Daily Loss ($ or %):
bool          uConsiderFloatting = false;                      // Consider Floating:
#endif

#ifdef CLOSE_ALL_ON
input string       TtpOposite = "== Close Opposite ==";     // ————————————
input bool         closeAllInOpositeSignal = false;                       // Close all in opposite signal
input string       TtpOptions = "== Close All Options ==";  // ————————————
input bool         closeAllControlON = false;                      // Close All Control On:
input CloseAllMode closeBy = CloseByMoney;               // Close All Mode:
input double       closeAllMoney = 100;                        // Close by Money $:
input double       closeAllMoneyLoss = -100;                       // Close by Money Lossing $:
input double       accountPerWin = 1;                          // Account Percent Win:
input double       accountPerLos = -1;                         // Account Percent Loss:
input double       closeByPipsWin = 10;                         // Close Pips Win:
input double       closeByPipsLoss = 10;                         // Close Pips Loss:
#else
string        TtpOptions = "== Close All Options ==";  // == Close All Options ==
bool          closeAllControlON = false;                      // Close All Control ON:
CloseAllMode  closeBy = CloseByMoney;               // Close All Mode:
double        closeAllMoney = 100;                        // Close by Money $:
double        closeAllMoneyLoss = -100;                       // Close by Money Lossing $:
double        accountPerWin = 1;                          // Account Percent Win:
double        accountPerLos = -1;                         // Account Percent Loss:
double        closeByPipsWin = 10;                         // Close Pips Win:
double        closeByPipsLoss = 10;                         // Close Pips Loss:
bool          closeAllInOpositeSignal = false;                      // CLose All In Oposite Signal
#endif

#ifdef PARTIAL_CLOSE_ON
input string Tpc = "== Partial Close ==";  // ————————————
input bool   partialCloseOn = false;                  // Partial Close On:
input double userPartialClosePercent = 50;                     // Partial Close Percent:
input double userPartialClosePips = 20;                     // Partial Close Pips:
input int    uQntPartials = 1;                      // Partials to take:
#else
string        Tpc = "== Partial Close ==";      // ————————————
bool          partialCloseOn = false;                      // Partial Close On:
double        userPartialClosePercent = 50;                         // Partial Close Percent:
double        userPartialClosePips = 20;                         // Partial Close Pips:
int           uQntPartials = 1;                          // Partials to take:
#endif
#ifdef BREAKEVEN_ON
input string Tbk = "== Breakeven Setup ==";  // ————————————
input bool   breakevenOn = false;                    // Breakeven On:
input double userBkvPips = 10;                        // Breakeven Pips
input double userBkvStep = 3;                        // Breakeven Step
#else
string        Tbk = "== Breakeven Setup ==";    // == Breakeven Setup ==
bool          breakevenOn = false;                      // Use Breakeven?
double        userBkvPips = 10;                        // Breakeven Pips
double        userBkvStep = 3;                        // Breakeven Step
#endif
#ifdef TRAILING_STOP_ON
input string tTailingStop = "== TrailingStop Setup ==";  // ————————————
input bool   TslON = false;                       // TSL ON:
TSLMode      userTslMode = byPips;                      // TSL Mode:
input int    userTslInitialStep = 1;                           // TSL Initial Step:
input int    userTslStep = 1;                           // TSL Step:
input int    userTslDistance = 20;                          // TSL Distance:
#else
string        tTailingStop = "== TailingStop Setup ==";  // == TailingStop Setup ==
bool          TslON = false;                      // TSL ON:
TSLMode       userTslMode = byPips;                     // TSL Mode:
int           userTslInitialStep = 1;                          // TSL Initial Step:
int           userTslStep = 1;                          // TSL Step:
int           userTslDistance = 20;                         // TSL Distance:
#endif
#ifdef GRID_ON
input string tGrid = "== Grid Setup ==";  // ————————————
input bool   GridON = false;               // Grid On:
input int    GridUser_maxCount = 5;                   // Max attempts:
input double GridUser_maxLot = 10;                  // Max lot value:
input double GridUser_multiplier = 1.5;                 // Multiplier:
input int    GridUser_gap = 30;                  // Gap betwen orders (pips):
input bool   closeGridOn = true;                // Use Close Grid?
input double closeGridTP = 100;                 // Take Profit Grid $
input double closeGridSL = -100;                // Stop Loss Grid -$
#else
string        tGrid = "== Grid Setup ==";         // == Grid Setup ==
bool          GridON = false;                      // Use Grid:
int           GridUser_maxCount = 5;                          // Max attempts:
double        GridUser_maxLot = 10;                         // Max lot value:
double        GridUser_multiplier = 1.5;                        // Multiplier:
int           GridUser_gap = 30;                         // Gap betwen orders (pips):
bool          closeGridOn = true;                       // Use Close Grid?
double        closeGridTP = 100;                        // Take Profit Grid $
double        closeGridSL = -100;                       // Stop Loss Grid -$
#endif
#ifdef TIMER_FULL
input string   T1 = "== Trading Sessions  ==";  // ————————————
input double   uTimeZone = -6;                         // Set your GMT zone:
input bool     day1_On = true;                       // Session On:
input enumDays day1 = monday;                     // Day
input string   day1_Start = "00:00:00";                 // Time Start GMT
input string   day1_End = "23:59:59";                 // Time End GMT
input bool     day2_On = true;                       // Session On:
input enumDays day2 = tuesday;                    // Day
input string   day2_Start = "00:00:00";                 // Time Start GMT
input string   day2_End = "23:59:59";                 // Time End GMT
input bool     day3_On = true;                       // Session On:
input enumDays day3 = wednesday;                  // Day
input string   day3_Start = "00:00:00";                 // Time Start GMT
input string   day3_End = "23:59:59";                 // Time End GMT
input bool     day4_On = true;                       // Session On:
input enumDays day4 = thursday;                   // Day
input string   day4_Start = "00:00:00";                 // Time Start GMT
input string   day4_End = "23:59:59";                 // Time End GMT
input bool     day5_On = true;                       // Session On:
input enumDays day5 = friday;                     // Day
input string   day5_Start = "00:00:00";                 // Time Start GMT
input string   day5_End = "23:59:59";                 // Time End GMT
#endif
#ifdef TIMER_MINI
input string T1 = "== Trading Sessions ==";  // ————————————
input string timeStart = "00:00:00";                // Time Start GMT
input string timeEnd = "23:59:59";                // Time End GMT
#endif
#ifdef TIMER_OFF
string T1 = "== Trading Sessions ==";  // ————————————
string timeStart = "00:00:00";                // Time Start GMT
string timeEnd = "23:59:59";                // Time End GMT
#endif
#ifdef NOTIFICATIONS_ON
input string TZ = "== Notifications ==";  // ————————————
input bool   notifications = false;                  // Notifications On
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
#else
string        TZ = "== Notifications ==";      // Notifications
bool          notifications = false;                      // Notifications On
bool          desktop_notifications = false;                      // Desktop MT4 Notifications
bool          email_notifications = false;                      // Email Notifications
bool          push_notifications = false;                      // Push Mobile Notifications
#endif

string             Iema = "== Moving Average Setup ==";  // ————————————
int                maPeriod = 20;                            // Period
int                maShift = 0;                             // Ma Shift
ENUM_MA_METHOD     maMethod = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE maAppliedPrice = PRICE_CLOSE;                   // Applied Price

string TFilters = "== Filters Orders ==";  // ————————————
bool   filterSymbolsOn = true;                    // Symbols filter On:
string SymbolsList = "GBPUSD,EURUSD";         // Symbols (separate by comma ","):
bool   filterMagicsOn = true;                    // Use magic number filter?
string MagicsList = "2022";                  // Magics numbers (separate by comma ","):

#ifdef NEWS_FILTER
input string TNewsFilter = "== News ==";  // ————————————
input bool   newsOn = false;         // News Filter On:
int input    Turn_OFF_Before = 30;            // Turn OFF before (min.)
int input    Turn_ON_After = 30;            // Turn ON after (min.)

enum SourceNews {
    Manual,
    Auto,
    None
};

SourceNews News_Fuente = Auto;  // News Source:

int          AfterNewsStop = 5;                                  // Indent after News, minuts
int          BeforeNewsStop = 5;                                  // Indent before News, minut
input bool   NewsLight = false;                              // Enable light news
input bool   NewsMedium = false;                              // Enable medium news
input bool   NewsHard = true;                               // Enable hard news
input int    offset = 0;                                  // Your Time Zone, GMT (for news)
input string NewsSymb = "USD,EUR,GBP,CHF,CAD,AUD,NZD,JPY";  // Currency to display the news (empty - only the current currencies)
input bool   DrawLines = true;                               // Draw lines on the chart
input bool   Next = false;                              // Draw only the future of news line
bool         Signal = true;                               // Signals on the upcoming news

color highc = clrRed;      // Colour important news
color mediumc = clrOrange;   // Colour medium news
color lowc = clrSkyBlue;  // The color of weak news
int   Style = 2;           // Line style
int   Upd = 86400;       // Period news updates in seconds

bool Vhigh = false;
bool Vmedium = false;
bool Vlow = false;
int  MinBefore = 10;  // MINUTOS DE AVISO ANTES DE UNA NOTICIA
int  MinAfter = 10;  // MINUTOS DE AVISO DESPUES DE UNA NOTICIA

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
    string   _names [];
    datetime _date;
    // long   _acounts[];

    public:
    ConditionLicense(const string name) { addName(name); }
    ConditionLicense(datetime date) { _date = date; }
    ~ConditionLicense() {}

    bool addName(string name)
    {
        int t = ArraySize(_names);
        if(ArrayResize(_names, t + 1))
        {
            _names[t] = name;
            return true;
        }
        return false;
    }

    bool controlByName()
    {
        for(int i = 0; i < ArraySize(_names); i++)
        {
            string name = _names[i];
            string accountName = AccountInfoString(ACCOUNT_NAME);

            if(StringToUpper(name) && StringToUpper(accountName))
            {
                if(name == accountName)
                {
                    return true;
                }
            }

            // busca si coincide una parte de name dentro de accountName:
            if(StringFind(accountName, name, 0) != -1)
            {
                return true;
            }
        }

        Alert("Account Without Licences. Info: tradingxbots@gmail.com");
        return false;
    }

    bool controlByDate()
    {
        datetime today = TimeCurrent();
        if(today >= _date)
        {
            Alert("Licences Expire. Info: tradingxbots@gmail.com");
            return false;
        }
        return true;
    }
};
ConditionLicense license(D'2022.03.30');
#endif


class MovingAverage
{
    string _symbol;
    int    _tf;

    struct MovingAverageParameters
    {
        int setup0;  //  Period
        int setup1;  //  Ma Shift
        int setup2;  //  Method
        int setup3;  //  Applied Price
    };
    MovingAverageParameters _setup;

    public:
    MovingAverage()
    {
        _symbol = _Symbol;
        _tf = Period();
    }
    MovingAverage(string Symbol, int TimeFrame)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
    }
    MovingAverage(string Symbol, int TimeFrame, int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
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
    virtual void Add() = 0;
    virtual void Release() = 0;

    virtual bool AddOrder() = 0;
    virtual bool DeleteOrder() = 0;
    virtual bool Select() = 0;
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
        _countPartials(countPartials)
    {}

    Order() {}
    ~Order() {}

    // clang-format off
    Order* id(int id) { _id = id; return &this; }
    Order* symbol(string symbol) { _symbol = symbol; return &this; }
    Order* price(double price) { _price = price; return &this; }
    Order* sl(double sl) { _sl = sl; return &this; }
    Order* tp(double tp) { _tp = tp; return &this; }
    Order* lot(double lot) { _lot = lot; return &this; }
    Order* type(int type) { _type = type; return &this; }
    Order* magic(int magic) { _magic = magic; return &this; }
    Order* comment(string comment) { _comment = comment; return &this; }
    Order* expireTime(datetime expireTm) { _expireTime = expireTm; return &this; }
    Order* signalTime(datetime signalTm) { _signalTime = signalTm; return &this; }
    Order* profit(double profit) { _profit = profit; return &this; }
    Order* strategy(string strategy) { _strategy = strategy; return &this; }
    Order* tslNext(double tslNext) { _tslNext = tslNext; return &this; }
    Order* breakevenWasDoIt(bool bkvWasDoIt) { _bkvWasDoIt = bkvWasDoIt; return &this; }
    Order* countPartials(int count) { _countPartials = _countPartials + count; return &this; }

    int            id() { return _id; }
    string         symbol() { return _symbol; }
    double         price() { return _price; }
    double         sl() { return _sl; }
    double         tp() { return _tp; }
    double         lot() { return _lot; }
    int            type() { return _type; }
    int            magic() { return _magic; }
    string         comment() { return _comment; }
    string         strategy() { return _strategy; }
    datetime       expireTime() { return _expireTime; }
    datetime       signalTime() { return _signalTime; }
    double         profit() { if(OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit() + OrderCommission() + OrderSwap(); return -1; }
    double         tslNext() { return _tslNext; }
    double         breakevenWasDoIt() { return _bkvWasDoIt; }
    int            countPartials() { return _countPartials; }
};

class FilterBySymbols
{
    string _symbols [];

    public:
    FilterBySymbols(string userSymbols) { getSymbols(userSymbols); }
    ~FilterBySymbols() { ; }

    void getSymbols(string userSymbols)
    {
        string Simbolos [];
        string sep = ",";
        ushort u_sep;
        u_sep = StringGetCharacter(sep, 0);
        int k = StringSplit(userSymbols, u_sep, Simbolos);
        ArrayResize(_symbols, ArrayRange(Simbolos, 0), 0);
        for(int i = 0; i < ArrayRange(Simbolos, 0); i++)
        {
            _symbols[i] = Simbolos[i];
        }
        printSymbols();
    }

    bool control(const string symbolToControl)
    {
        if(ArraySize(_symbols) > 0)
        {
            for(int i = 0; i < ArraySize(_symbols); i++)
            {
                if(_symbols[i] == symbolToControl)
                {
                    return true;
                }
            }
        }

        return false;
    }

    void printSymbols()
    {
        for(int i = 0; i < ArraySize(_symbols); i++)
        {
            Print(_symbols[i]);
        }
    }

    //---
};
class FilterByMagics
{
    int _magics [];

    public:
    FilterByMagics(string userMagics) { getMagics(userMagics); }
    ~FilterByMagics() { ; }

    void getMagics(string userMagics)
    {
        string Magicos [];
        string sep = ",";
        ushort u_sep;
        u_sep = StringGetCharacter(sep, 0);
        int k = StringSplit(userMagics, u_sep, Magicos);
        ArrayResize(_magics, ArrayRange(Magicos, 0), 0);
        for(int i = 0; i < ArrayRange(Magicos, 0); i++)
        {
            _magics[i] = (int) Magicos[i];
        }
        if(ArrayRange(_magics, 0) > 0)
        {
            ArraySort(_magics, WHOLE_ARRAY, 0, MODE_ASCEND);
        }
        printMagics();
    }

    bool control(const int magicToControl)
    {
        if(ArraySize(_magics) > 0)
        {
            int p = ArrayBsearch(_magics, magicToControl, WHOLE_ARRAY, 0, MODE_ASCEND);
            if(_magics[p] == magicToControl)
            {
                return true;
            }
        }

        return false;
    }

    void printMagics()
    {
        for(int i = 0; i < ArraySize(_magics); i++)
        {
            Print(_magics[i]);
        }
    }


    //---
};
class OrdersList
{
    Order* orders [];
    bool            _filterByMagicOn;
    bool            _filterBySymbolsOn;
    FilterByMagics* _magics;
    FilterBySymbols* _symbols;

    public:
    OrdersList() { ; }
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
        if(ArrayResize(orders, t + 1))
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
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if(_filterByMagicOn) if(!_magics.control(OrderMagicNumber())) { continue; }
                if(_filterBySymbolsOn) if(!_symbols.control(OrderSymbol())) { continue; }

                if(exist(OrderTicket()) == true) { continue; }

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

                if(AddOrder(newOrder))
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
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if(_filterByMagicOn) if(!_magics.control(OrderMagicNumber())) { continue; }
                if(_filterBySymbolsOn) if(!_symbols.control(OrderSymbol())) { continue; }
                if(exist(OrderTicket()) == true) { continue; }

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

                if(AddOrder(newOrder))
                {
                    Print(__FUNCTION__, " ", "* Nueva Orden De Mercado * ", id(i), "magic: ", magic(i));
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
        for(int i = qnt() - 1; i >= 0; i--)
        {
            if(id(i) == id)
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
        if(notOverFlow(index))
        {
            delete orders[index];
        }

        if(qnt() > index)
        {
            for(int i = index; i < qnt() - 1; i++)
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
        for(int i = 0; i < qnt(); i++)
        {
            if(CheckPointer(orders[i]) != POINTER_INVALID)
            {
                deleteOrder(i);
            }
        }
    }

    // devuelve el puntero a la última orden
    Order* last()
    {
        int lastIndex = ArraySize(orders) - 1;
        if(lastIndex == -1)
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
        if(index > ArraySize(orders) - 1) return false;
        if(index < 0) return false;
        if(CheckPointer(orders[index]) == POINTER_INVALID) return false;

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
        if(notOverFlow(index))
        {
            return orders[index].id();
        }
        return -1;
    }
    string symbol(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].symbol();
        }
        return "";
    }
    double price(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].price();
        }
        return -1;
    }
    double sl(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].sl();
        }
        return -1;
    }
    double tp(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].tp();
        }
        return -1;
    }
    double lot(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].lot();
        }
        return -1;
    }
    int magic(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].magic();
        }
        return -1;
    }
    datetime expire(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].expireTime();
        }
        return -1;
    }
    datetime signalTime(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].signalTime();
        }
        return -1;
    }
    string comment(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].comment();
        }
        return "";
    }
    ENUM_ORDER_TYPE type(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].type();
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

    // clang-format on

    // comprueba si la orden está cerrada
    // ——————————————————————————————————————————————————————————————————
    bool isClose(int index)
    {
        if(notOverFlow(index))
        {
            if(OrderSelect(id(index), SELECT_BY_TICKET))
            {
                if(OrderCloseTime() != 0) return true;
            }
        }
        return false;
    }

    // borra de la lista los trades cerrados
    // ——————————————————————————————————————————————————————————————————
    void cleanCloseOrders()
    {
        if(qnt() == 0)
        {
            return;
        }

        for(int i = 0; i < qnt(); i++)
        {
            if(isClose(i))
            {
                deleteOrder(i);
            }
        }
    }

    // cierra todas las ordenes en la lista y la limpia, te retorna la cantidad de errores
    int closeAllInList()
    {
        cleanCloseOrders();
        int errors = 0;

        for(int i = 0; i < ArraySize(orders); i++)
        {
            int tk;
            if(isClose(i))
            {
                continue;
            }
            if(CheckPointer(orders[i]) != POINTER_INVALID)
            {
                tk = orders[i].id();
            }
            else
            {
                continue;
            }
            if(OrderSelect(tk, SELECT_BY_TICKET))
            {
                double ask = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
                double bid = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
                double closePrice = OrderType() == OP_BUY ? bid : ask;
                if(!OrderClose(OrderTicket(), OrderLots(), closePrice, 1000, clrNONE))
                {
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
        if(!notOverFlow(index))
        {
            return;
        }
        if(CheckPointer(orders[index]) == POINTER_INVALID)
        {
            return;
        }
        // clang-format off
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
        Print("Order ", index, " countPartials: ", orders[index].countPartials());
        // clang-format on
    }
    // ——————————————————————————————————————————————————————————————————
    void PrintList()
    {
        for(int i = 0; i < qnt(); i++)
        {
            PrintOrder(i);
        }
    }
};
OrdersList mainOrders(filterMagicsOn, (string) magico, filterSymbolsOn, _Symbol);

interface iConditions
{
    bool evaluate();
};
class ConcurrentConditions
{
    protected:
    iConditions* _conditions [];

    public:
    ConcurrentConditions(void) {}
    ~ConcurrentConditions(void) { releaseConditions(); }

    // ——————————————————————————————————————————————————————————————————
    void releaseConditions()
    {
        for(int i = 0; i < ArraySize(_conditions); i++)
        {
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
        for(int i = 0; i < ArraySize(_conditions); i++)
        {
            if(!_conditions[i].evaluate())
            {
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
    int    _mode;  // 0: Ask>=Price & Bid <=Price , 1: Ask <= Price && Bid >= Price

    public:
    ConditionMatchPrice(string Symbol, string Side, double Price, int Mode)
    {
        _symbol = Symbol;
        _side = Side;
        _price = Price;
        _mode = Mode;
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

        if(_mode == 0)
        {
            if(_side == "buy")
            {
                if(ask >= _price)
                {
                    return true;
                }
                return false;
            }
            if(_side == "sell")
            {
                if(bid <= _price)
                {
                    return true;
                }
                return false;
            }
        }

        if(_mode == 1)
        {
            if(_side == "buy")
            {
                if(ask <= _price)
                {
                    return true;
                }
                return false;
            }
            if(_side == "sell")
            {
                if(bid >= _price)
                {
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
        _lot = Lot;
    }
    ~ConditionMaxLot() { ; }
    void lot(double inplot) { _lot = inplot; }

    bool evaluate()
    {
        if(_maxLot >= _lot)
        {
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
        if(_orders.qnt() < _maxQnt)
        {
            return true;
        }
        return false;
    }
};

class DailyProfitCondition : public iConditions
{
    int           _magic;
    double        _limit;
    bool          _considerOpen;  // Considera el flotante profit flotante
    string        _mode;          // loss or profit
    DayLimitsMode _limitMode;     // Amount or AccountPer
    public:
    DailyProfitCondition(double limit, int mag, bool considerOpen, string mode, DayLimitsMode limitMode) : _limit(limit), _magic(mag), _considerOpen(considerOpen), _mode(mode), _limitMode(limitMode) { ; }
    ~DailyProfitCondition() { ; }

    bool evaluate()
    {
        if(_mode == "profit")
        {
            if(TodayProfit() >= Limit())
            {
                Print("DAILY PROFIT REACHED: ", TodayProfit());
                return true;
            }
        }
        if(_mode == "loss")
        {
            if(TodayProfit() <= Limit())
            {
                Print("DAILY LOSS REACHED: ", TodayProfit());
                return true;
            }
        }
        return false;
    }

    double Limit()
    {
        if(_limitMode == LimitsByAmount)
        {
            return _limit;
        }
        if(_limitMode == LimitsByAccountPercent)
        {
            return _limit / 100 * AccountInfoDouble(ACCOUNT_BALANCE);
        }
        return 0;
    }

    double TodayProfit()
    {
        datetime iniDay = iTime(NULL, PERIOD_D1, 0);

        double profit = 0;
        for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
            {
                if(OrderCloseTime() >= iniDay)
                {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }

        if(_considerOpen)
        {
            for(int i = OrdersTotal() - 1; i >= 0; i--)
            {
                if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
                {
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
        if(OrderSelect(_order.id(), SELECT_BY_TICKET))
        {
            if(OrderCloseTime() > 0)
            {
                Print(__FUNCTION__, " ", "Order are closed ", _order.id());
                return false;
            }

            if(OrderModify(_order.id(), OrderOpenPrice(), _newSL, OrderTakeProfit(), OrderExpiration(), clrNONE))
            {
                _order.sl(_newSL);
                _order.breakevenWasDoIt(true);
                Print(__FUNCTION__, " ", _order.id(), " Modify: new SL: ", _newSL);
                return true;
            }

        }
        else
        {
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

    PartialClose* order(Order* or )
    {
        _order = or ;
        return &this;
    }
    PartialClose* percent(double percentToClose)
    {
        _percentToClose = percentToClose;
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

    double lots()
    {
        // hay que ajustar el lotaje para volverlo al original
        int n = _order.countPartials();
        if(n > 0)
        {
            double originalLots = _order.lot() / (1 - (NormalizeDouble(_percentToClose / 100, 2) * n));
            return NormalizeDouble((originalLots * _percentToClose / 100), 2);
        }

        return NormalizeDouble((_order.lot() * _percentToClose / 100), 2);
    }

    double price()
    {
        double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

        if(_order.type() == OP_BUY)
        {
            return bid;
        }
        if(_order.type() == OP_SELL)
        {
            return ask;
        }
        return 0;
    }

    bool doAction()
    {
        if(!controlPointer(_order))
        {
            Print(__FUNCTION__, " ", "Can't Take Partial");
            return false;
        }
        if(OrderSelect(_order.id(), SELECT_BY_TICKET))
        {
            if(OrderCloseTime() > 0)
            {
                Print(__FUNCTION__, " ", "Order are closed ", _order.id());
                return false;
            }

            if(OrderClose(_order.id(), lots(), price(), 10000, clrNONE))
            {
                // aumenta el contador de parciales
                _order.countPartials(1);

                // remplazar el tk por el nuevo tk
                changeTk(_order.id());

                Print(__FUNCTION__, " ", _order.id(), " Partial TP taked ");
                return true;
            }

        }
        else
        {
            Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
        }

        return false;
    }

    void changeTk(int tk)
    {
        if(OrderSelect(tk, SELECT_BY_TICKET))
        {
            datetime dt = OrderCloseTime();
            string   coment = OrderComment();
            int      pos = StringFind(coment, "#") + 1;
            string   newId = StringSubstr(coment, pos, StringLen(coment));
            _order.id((int) newId);
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
        double _price = setPrice(side, price, _symbol);
        int    _type = SetType(side, price, _symbol);
        if(_type == -1)
        {
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
        if(sim == "")
        {
            return Symbol();
        }
        return sim;
    }

    double setPrice(string side, double pr, string sym)
    {
        if(pr == 0)
        {
            if(side == "buy")
            {
                return SymbolInfoDouble(sym, SYMBOL_ASK);
            }
            if(side == "sell")
            {
                return SymbolInfoDouble(sym, SYMBOL_BID);
            }
        }

        return pr;
    }

    int SetType(string side, double priceClient, string sym)
    {
        double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
        double bid = SymbolInfoDouble(sym, SYMBOL_BID);

        if(priceClient == 0)
        {
            if(side == "buy")
            {
                return (int) OP_BUY;
            }
            if(side == "sell")
            {
                return (int) OP_SELL;
            }
        }
        else
        {
            if(side == "buy")
            {
                if(priceClient > ask)
                {
                    return (int) OP_BUYSTOP;
                }
                if(priceClient < ask)
                {
                    return (int) OP_BUYLIMIT;
                }
            }
            if(side == "sell")
            {
                if(priceClient > bid)
                {
                    return (int) OP_SELLLIMIT;
                }
                if(priceClient < bid)
                {
                    return (int) OP_SELLSTOP;
                }
            }
        }

        return -1;
    }

    bool doAction()
    {
        int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, newOrder.sl(), newOrder.tp(), newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);

        if(tk < 0)
        {
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
    ConditionMaxLot* cdMaxLot;
    SendNewOrder* openTrade;
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
        _symbol = Symbol;
        _side = Side;
        _lastPrice = LastPrice;
        _gap = Gap;
        _nextPrice = nextPrice(LastPrice);
        _multiplier = Multiplier;
        _maxQnt = MaxQnt + 1;
        _maxLot = MaxLot;
        _initialLot = InitialLot;
        _nextLot = nextLot();
        _magico = magic;

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
        cdMaxOrders = new ConditionOrderCount(GetPointer(gridOrders), _maxQnt);
        cdMaxLot = new ConditionMaxLot(_maxLot, _nextLot);

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
        if(gridOrders.profit(0) < 0)
        {
            _active = true;
        }
        else
        {
            _active = false;
        }
        return _active;
    }
    double nextPrice(double inpLastPrice)
    {
        double mPoint = MarketInfo(_symbol, MODE_POINT);

        if(_side == "buy") _nextPrice = inpLastPrice - (_gap * mPoint * 10);
        if(_side == "sell") _nextPrice = inpLastPrice + (_gap * mPoint * 10);

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

        for(int i = 0; i < qnt(); i++)
        {
            if(CheckPointer(gridOrders.index(i)) != POINTER_INVALID)
                gridResult += gridOrders.profit(i);

            Print(__FUNCTION__, " ", "gridResult", " ", gridResult);
        }
        return gridResult;
    }

    void doGrid()
    {
        if(conditionsToOpenNewTrade.EvaluateConditions())
        {
            if(_side == "buy")
            {
                openTrade = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), _magico);
                if(openTrade.doAction())
                {
                    Print("pointer de la ultima orden: ", openTrade.lastOrder());
                    // if (gridOrders.AddOrder(openTrade.lastOrder()))
                    if(gridOrders.GetLastMarketOrder())
                        setNextTrade();
                }
                delete openTrade;
            }

            if(_side == "sell")
            {
                openTrade = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), _magico);
                if(openTrade.doAction())
                {
                    // Print("pointer de la ultima orden: ", openTrade.lastOrder());
                    // if (gridOrders.AddOrder(openTrade.lastOrder()))
                    if(gridOrders.GetLastMarketOrder())
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
        if(qnt() == 0)
        {
            return;
        }

        int attempts = 0;
        while(gridOrders.closeAllInList() != 0 || attempts < 10)
        {
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
        if(_side != _lastSide)
        {
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
        if(CheckPointer(_grid) != POINTER_INVALID)
        {
            if(_grid.active())
            {
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
    iConditions* _conditions [];

    public:
    ConditionsModeOneTrue(void) {}
    ~ConditionsModeOneTrue(void) { releaseConditions(); }

    // ——————————————————————————————————————————————————————————————————
    void releaseConditions()
    {
        for(int i = 0; i < ArraySize(_conditions); i++)
        {
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
        for(int i = 0; i < ArraySize(_conditions); i++)
        {
            if(_conditions[i].evaluate())
            {
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
    string _mode;  // TP SL
    double _price;

    public:
    ByFixPips(string inpSymbol, string inpSide, int inpPips, string inpMode, double Price = 0)
    {
        _pips = inpPips;
        _symbol = inpSymbol;
        _side = inpSide;
        _mode = inpMode;
        _price = Price;
    }
    ~ByFixPips() { ; }

    double pips() { return _pips; }

    double calculateLevel()
    {
        double mPoint = MarketInfo(_symbol, MODE_POINT);
        double distance = _pips * 10 * mPoint;

        if(_pips == 0)
        {
            return 0;
        }

        if(_mode == "SL")
        {
            distance *= -1;
        }

        if(_side == "buy")
        {
            double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
            double entryPrice = _price == 0 ? ask : _price;
            return entryPrice + distance;
        }

        if(_side == "sell")
        {
            double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);
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
    string _mode;  // TP SL
    double _lot;

    public:
    ByMoney(string Symbol, string Side, double Lot, double Money, string Mode)
    {
        _lot = Lot;
        _symbol = Symbol;
        _side = Side;
        _mode = Mode;
        _money = Money;
    }
    ~ByMoney() { ; }

    double pips()
    {
        double _tickValue = MarketInfo(_symbol, MODE_TICKVALUE);
        double _modeCalc = MarketInfo(_symbol, MODE_PROFITCALCMODE);
        double _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        double _step = MarketInfo(_symbol, MODE_LOTSTEP);
        double _points = MarketInfo(_symbol, MODE_POINT);
        double _digits = MarketInfo(_symbol, MODE_DIGITS);

        // FOREX
        if(_modeCalc == 0)
        {
            // lot = return NormalizeDouble(_money / distance / _tickValue, 2);
            return NormalizeDouble(_money / (_lot * _tickValue), 2);
        }

        // FUTUROS
        if(_modeCalc == 1 && _step != 1.0)
        {
            double c = _contractSize * _step;
            // return NormalizeDouble(_money / (distance * c), 2);
            // lot = _money / (distance * c)
            return NormalizeDouble((_money / c / _lot), 2);
        }

        // FUTUROS SIN DECIMALES
        if(_modeCalc == 1 && _step == 1.0)
        {
            double c = _contractSize * _step;
            // return MathFloor(_money / (distance * c) * 100);
            return MathFloor((_money / c / _lot) / 100);
        }

        return 0;
    }

    double calculateLevel()
    {
        _pips = (int) pips();
        double mPoint = MarketInfo(_symbol, MODE_POINT);
        // double distance = _pips * 10 * mPoint;
        double distance = _pips * mPoint;
        double result = 0;
        double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);

        if(_pips == 0)
        {
            return 0;
        }
        if(_mode == "SL")
        {
            distance *= -1;
        }
        if(_side == "buy")
        {
            return ask + distance;
        }
        if(_side == "sell")
        {
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
    string _mode;  // TP SL
    int    _tfCandle;
    int    _shiftCandle;

    public:
    ByPipsFromCandle(string inpSymbol, string inpSide, int inpPips, string inpMode, int timeFrameCandle, int shiftCandle)
    {
        _pips = inpPips;
        _symbol = inpSymbol;
        _side = inpSide;
        _mode = inpMode;
        _tfCandle = timeFrameCandle;
        _shiftCandle = shiftCandle;
    }
    ~ByPipsFromCandle() { ; }
    double pips()
    {
        return _pips;
    }

    double calculateLevel()
    {
        double mPoint = MarketInfo(_symbol, MODE_POINT);
        double distance = _pips * 10 * mPoint;
        double result = 0;
        double high = iHigh(_symbol, _tfCandle, _shiftCandle);
        double low = iLow(_symbol, _tfCandle, _shiftCandle);

        if(_pips == 0)
        {
            return 0;
        }

        if(_side == "buy")
        {
            if(_mode == "TP") return high + distance;
            if(_mode == "SL") return low - distance;
        }
        if(_side == "sell")
        {
            if(_mode == "TP") return low - distance;
            if(_mode == "SL") return high + distance;
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
        if(CheckPointer(_level) == 1)
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
        if(side == "buy") _type = OP_BUY;
        if(side == "sell") _type = OP_SELL;
        if(symbol == "")
        {
            _symbol = Symbol();
        }
        else
        {
            _symbol = symbol;
        }
        if(magic != 0)
        {
            _magic = magic;
        }
        if(slippage != 10000)
        {
            _slippage = slippage;
        }
    }
    ~ActionCloseOrdersByType() {}

    void setPrice()
    {
        if(_type == OP_BUY)
        {
            _price = SymbolInfoDouble(_symbol, SYMBOL_BID);
        }
        if(_type == OP_SELL)
        {
            _price = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        }
    }

    bool doAction()
    {
        setPrice();
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic && OrderType() == _type)
            {
                if(!OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE))
                {
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
        _side = side;
        _symbol = symbol == "" ? Symbol() : symbol;
        _magic = magic != 0 ? magic : 0;
    }
    ~ActionDeletePendings() {}

    bool doAction()
    {
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic)
            {
                if(_side == "buy" && (OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT))
                {
                    OrderDelete(OrderTicket());
                }
                if(_side == "sell" && (OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT))
                {
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
        _TslStep = TslStep * 10;
        _Distance = Distance * 10;
    }
    ~TslByPips() { ; }

    void setInitialStep(Order* order)
    {
        double mPoint = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _InitialStep * mPoint;
        if(order.type() == OP_SELL)
        {
            pointsToMove *= -1;
        }
        order.tslNext(order.price() + pointsToMove);

        Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
        Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
    }

    void setNextStep(Order* order)
    {
        double mPoint = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _TslStep * mPoint;
        if(order.type() == OP_SELL)
        {
            pointsToMove *= -1;
        }
        order.tslNext(order.tslNext() + pointsToMove);

        Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
        Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
    }

    double newSL(Order* order)
    {
        double mPoint = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _Distance * mPoint;
        if(order.type() == OP_SELL)
        {
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
    iTSL* _TslMode;

    public:
    TrailingStop(OrdersList* uOrders, TSLMode mode)
    {
        _orders = uOrders;

        switch(mode)
        {
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
        for(int i = 0; i < _orders.qnt(); i++)
        {
            if(CheckPointer(_orders.index(i)) == POINTER_INVALID)
            {
                Print(__FUNCTION__, " ", "Pointer invalid i= ", i);
                continue;
            }

            // seteo Initial:
            if(_orders.index(i).tslNext() == 0)
            {
                _TslMode.setInitialStep(_orders.index(i));
            }

            if(MatchNextTsl(_orders.index(i)))
            {
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
        if(order.type() == OP_BUY)
        {
            if(bid >= order.tslNext())
            {
                return true;
            }
        }
        if(order.type() == OP_SELL)
        {
            if(ask <= order.tslNext())
            {
                return true;
            }
        }
        return false;
    }

    void moveSL(int tk, double newSl)
    {
        if(OrderSelect(tk, SELECT_BY_TICKET))
        {
            if(!OrderModify(tk, OrderOpenPrice(), newSl, OrderTakeProfit(), 0))
            {
                Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " ", GetLastError());
            }
            else
            {
                Print(__FUNCTION__, " trailing stop in tk: ", tk);
            }
        }
    }
};
TrailingStop* tsl;



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
        if(sym == "")
        {
            _symbol = Symbol();
        }
        else
        {
            _symbol = sym;
        }
        _tickValue = MarketInfo(_symbol, MODE_TICKVALUE);
        _modeCalc = MarketInfo(_symbol, MODE_PROFITCALCMODE);
        _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        _step = MarketInfo(_symbol, MODE_LOTSTEP);
        _points = MarketInfo(_symbol, MODE_POINT);
        _digits = MarketInfo(_symbol, MODE_DIGITS);
        _min = MarketInfo(_symbol, MODE_MINLOT);
        _max = MarketInfo(_symbol, MODE_MAXLOT);

    }


    double LotsByBalancePercent(double BalancePercent, double Distance)
    {
        double risk = AccountBalance() * BalancePercent / 100;
        return CalculateLots(risk, Distance);
    }

    // NOTE: Equity Lots
    double LotsByEquityPercent(double Percent)
    {
        double lot = 1;
        double marginConsumido = AccountFreeMargin() - AccountFreeMarginCheck(Symbol(), OP_BUY, lot);
        double mcPercent = (marginConsumido / AccountFreeMargin()) * 100;
        double lotsCalc = NormalizeDouble(Percent / mcPercent, 2);

        return CheckLimits(lotsCalc);
    }

    double CheckLimits(double lot)
    {
        double l = lot;
        if(lot < _min) l = _min;
        if(lot > _max) l = _max;
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
        if(distance == 0)
        {
            Print(__FUNCTION__, " ", "Set Distance");
            return 0;
        }

        // FOREX
        if(_modeCalc == 0)
        {
            return NormalizeDouble(risk / distance / _tickValue, 2);
        }

        // FUTUROS
        if(_modeCalc == 1 && _step != 1.0)
        {
            double c = _contractSize * _step;
            return NormalizeDouble(risk / (distance * c), 2);
        }

        // FUTUROS SIN DECIMALES
        if(_modeCalc == 1 && _step == 1.0)
        {
            double c = _contractSize * _step;
            return MathFloor(risk / (distance * c) * 100);
        }

        return 0;
    }
};
LotCalculator* lotProvider;

class Session
{
    int _iniTime;  // second from 00:00 hr of the day
    int _endTime;
    int _dayNumber;

    public:
    // receive time in format 00:00
    Session(string iniTime, string endTime, int dayNumber = 0)
    {
        _iniTime = secondsFromZeroHour(iniTime);
        _endTime = secondsFromZeroHour(endTime);
        _dayNumber = dayNumber;
    };

    ~Session() {}

    int iniTime() { return _iniTime; }
    int endTime() { return _endTime; }
    int dayNumber() { return _dayNumber; }

    int secondsFromZeroHour(string time)
    {
        int hh = (int) StringSubstr(time, 0, 2);
        int mm = (int) StringSubstr(time, 3, 2);

        return (hh * 3600) + (mm * 60);
    }
};
class ScheduleController
{
    Session* schedules [];
    int      _actualIndex;
    Session* _actualSession;
    int      _currentDay;
    double   _timeZone;  // modificador para ajustar GMT

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
        _currentDay = TimeDay(TimeGMT() + _timeZone);  // return the day of the month 1-31
    }

    bool isNewDay()
    {
        if(TimeDay(TimeGMT() + _timeZone) != _currentDay)
        {
            setCurrentDay();
            return true;
        }

        return false;
    }

    void setActualSession(int index)
    {
        _actualIndex = index;

        if(index > -1)
        {
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
        int      t = qnt();
        if(ArrayResize(schedules, t + 1))
        {
            schedules[t] = sc;
            return true;
        }

        return false;
    }

    bool ClearShchedules()
    {
        for(int i = 0; i < qnt(); i++)
        {
            delete schedules[i];
        }
        ArrayFree(schedules);

        return true;
    }

    bool doSessionControl()  // control day and hours for every session
    {
        Comment("Daily Control - EA OFF");

        int actual = (TimeHour(TimeGMT() + _timeZone) * 3600) + (TimeMinute(TimeGMT() + _timeZone) * 60);

        for(int i = 0; i < qnt(); i++)
        {
            if(schedules[i].dayNumber() == EA_OFF)
            {
                continue;
            }

            if(schedules[i].dayNumber() != 0)
            {
                if(schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT() + _timeZone))
                {
                    if((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
                    {
                        setActualSession(i);
                        Comment("Daily Control - EA ON");
                        return true;
                    }
                }
            }

            if(schedules[i].dayNumber() == 0)
            {
                if((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
                {
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
        for(int i = 0; i < qnt(); i++)
        {
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
    m_symbol = Symbol();
    m_tf = Period();
}
CNewCandle::~CNewCandle() {}
bool CNewCandle::IsNewCandle()
{
    int velasActuales = iBars(m_symbol, m_tf);
    if(velasActuales > velasInicio)
    {
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
        // TODO: condition Buy 1
        //   return iClose(NULL, 0, 1) > ma.index(1);
        return Ask > iHigh(NULL, 0, 1);

        //   return Indi(bufferToBuy, 1) > 0;
      //   return false;
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
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
            {
                if(OrderType() == OP_BUY)
                {
                    count += 1;
                }

                if(count == _maxBuys)
                {
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
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
            {
                count += 1;

                if(count == _max)
                {
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
        return Bid < iLow(NULL, 0, 1);

        // return Indi(bufferToSell, 1) > 0;
        // return false;
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
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
            {
                if(OrderType() == OP_SELL)
                {
                    count += 1;
                }

                if(count == _maxSells)
                {
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
        if(closeAllInOpositeSignal)
            if(sellCondition1.evaluate() && sellCondition2.evaluate()) return true;

        if(closeAllControlON)
            if(CloseAllControl())return true;

#ifdef DAILY_LIMITS
        if(uDailyProfitOn)
            if(dailyProfitCondition.evaluate()) return true;

        if(uDailyLossOn)
            if(dailyLossCondition.evaluate()) return true;
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
        if(closeAllInOpositeSignal)
            if(buyCondition1.evaluate() && buyCondition2.evaluate())return true;

        if(closeAllControlON)
            if(CloseAllControl())return true;

#ifdef DAILY_LIMITS
        if(uDailyProfitOn)
            if(dailyProfitCondition.evaluate()) return true;

        if(uDailyLossOn)
            if(dailyLossCondition.evaluate()) return true;
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
    void setOrder(Order* or )
    {
        _order = or ;
    }

    bool evaluate()
    {
        // si el precio actual coindide con el momento de hacer bk ret true
        double mPoints = MarketInfo(_order.symbol(), MODE_POINT);
        double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);
        double dist = userBkvPips * mPoints * 10;

        if(_order.type() == OP_BUY)
        {
            if(bid >= _order.price() + dist)
            {
                return true;
            }
        }
        if(_order.type() == OP_SELL)
        {
            if(ask <= _order.price() - dist)
            {
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
    void setOrder(Order* or )
    {
        _order = or ;
    }

    bool evaluate()
    {
        double mPoints = MarketInfo(_order.symbol(), MODE_POINT);
        double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

        int    n = _order.countPartials();
        double dist;
        if(n == 0) dist = userPartialClosePips * mPoints * 10;
        if(n > 0) dist = userPartialClosePips * mPoints * 10 * (n + 1);

        if(_order.type() == OP_BUY)
        {
            if(bid >= _order.price() + dist)
            {
                Print(__FUNCTION__, " ", "_order.price()", " ", _order.price());
                Print(__FUNCTION__, " ", "bid", " ", bid);
                return true;
            }
        }
        if(_order.type() == OP_SELL)
        {
            if(ask <= _order.price() - dist)
            {
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
    HideTestIndicators(true);

#ifdef LICENSE_CONTROL_ON
    if(!license.controlByDate())
    {
        return INIT_FAILED;
    }
#endif

#ifdef CONTROL_CUSTOM_INDICATOR_FILE
    double temp = iCustom(NULL, 0, file_custom_indicator, 0, 0);
    if(GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
    {
        string txt = "THIS EA NEED AN INDICATOR\ninstall the file:\n" + file_custom_indicator + "\ninto the folder:\nMQL4/Indicators.";
        MessageBox(txt, "Important Information", MB_ICONINFORMATION);
        Alert(txt);
        return INIT_FAILED;
    }
#endif

    newCandle = new CNewCandle();
    tsl = new TrailingStop(GetPointer(mainOrders), byPips);

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
    conditionsToPartialClose.AddCondition(partialCloseCondition = new PartialCloseCondition());

    //--- SESSIONS CONTROL:
#ifdef TIMER_FULL
    sesionControl.setTimeZone(uTimeZone);
    if(day1_On) sesionControl.AddSession(day1_Start, day1_End, day1);
    if(day2_On) sesionControl.AddSession(day2_Start, day2_End, day2);
    if(day3_On) sesionControl.AddSession(day3_Start, day3_End, day3);
    if(day4_On) sesionControl.AddSession(day4_Start, day4_End, day4);
    if(day5_On) sesionControl.AddSession(day5_Start, day5_End, day5);
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
    if(StringLen(NewsSymb) > 1)
        str1 = NewsSymb;
    else
        str1 = Symbol();

    Vhigh = NewsHard;
    Vmedium = NewsMedium;
    Vlow = NewsLight;

    MinBefore = BeforeNewsStop;
    MinAfter = AfterNewsStop;

    LastUpd = 0;
#endif




#ifdef TELEGRAM
    // *******TELEGRAM INI ********************
    int y = 40;
    if(ChartGetInteger(0, CHART_SHOW_ONE_CLICK))
        y = 500;
    comment.Create("myPanel", 900, 420);
    comment.SetColor(clrDimGray, clrBlack, 200);

    //--- set language
    bot.Language(InpLanguage);

    //--- set token
    init_error = bot.Token(InpToken);

    //--- set filter
    bot.UserNameFilter(InpUserNameFilter);

    //--- set templates
    bot.Templates(InpTemplates);

    //--- set timer
    int timer_ms = 3000;
    switch(InpUpdateMode)
    {
        case UPDATE_FAST: timer_ms = 1000; break;
        case UPDATE_NORMAL: timer_ms = 2000; break;
        case UPDATE_SLOW: timer_ms = 3000; break;
        default: timer_ms = 3000; break;
    };

    Telegram();
#endif
    
    return (INIT_SUCCEEDED);
}

#ifdef TELEGRAM
void Telegram()
{
    //--- show init error
    if(init_error != 0) {
        //--- show error on display
        TCustomInfo info;
        GetCustomInfo(info, init_error, InpLanguage);

        //---
        comment.Clear();
        comment.SetText(0, StringFormat("%s v.%s", EXPERT_NAME, EXPERT_VERSION), CAPTION_COLOR);
        comment.SetText(1, info.text1, LOSS_COLOR);
        if(info.text2 != "")
            comment.SetText(2, info.text2, LOSS_COLOR);
        comment.Show();

        return;
    }

    //--- show web error
    if(run_mode == RUN_LIVE) {
        //--- check bot registration
        if(time_check < TimeLocal() - PeriodSeconds(PERIOD_H1)) {
            time_check = TimeLocal();
            if(TerminalInfoInteger(TERMINAL_CONNECTED)) {
                //---
                web_error = bot.GetMe();
                if(web_error != 0) {
                    //---
                    if(web_error == ERR_NOT_ACTIVE) {
                        time_check = TimeCurrent() - PeriodSeconds(PERIOD_H1) + 300;
                    }
                    //---
                    else {
                        time_check = TimeCurrent() - PeriodSeconds(PERIOD_H1) + 5;
                    }
                }
            }
            else {
                web_error = ERR_NOT_CONNECTED;
                time_check = 0;
            }
        }

        //--- show error
        if(web_error != 0) {
            comment.Clear();
            comment.SetText(0, StringFormat("%s v.%s", EXPERT_NAME, EXPERT_VERSION), CAPTION_COLOR);

            if(
#ifdef __MQL4__ web_error == ERR_FUNCTION_NOT_CONFIRMED #endif
#ifdef __MQL5__ web_error == ERR_FUNCTION_NOT_ALLOWED #endif
            ) {
                time_check = 0;

                TCustomInfo info = { 0 };
                GetCustomInfo(info, web_error, InpLanguage);
                comment.SetText(1, info.text1, LOSS_COLOR);
                comment.SetText(2, info.text2, LOSS_COLOR);
            }
            else
                comment.SetText(1, GetErrorDescription(web_error, InpLanguage), LOSS_COLOR);

            comment.Show();
            return;
        }
    }

    //---
    int res = bot.GetUpdates();
    if(res != 0) {
        time_check = 0;
        return;
    }
    //---
    if(run_mode == RUN_LIVE) {
        comment.Clear();
        comment.SetText(0, StringFormat("%s v.%s", EXPERT_NAME, EXPERT_VERSION), CAPTION_COLOR);
        comment.SetText(1, StringFormat("%s: %s", (InpLanguage == LANGUAGE_EN) ? "Bot Name" : "Имя Бота", bot.Name()), CAPTION_COLOR);
        comment.SetText(2, StringFormat("%s %d", (InpLanguage == LANGUAGE_EN) ? "Estate " : " "), CAPTION_COLOR);
        comment.Show();
    }

}

//+------------------------------------------------------------------+
//|   GetCustomInfo                                                  |
//+------------------------------------------------------------------+
void GetCustomInfo(TCustomInfo& info,
                   const int           _error_code,
                   const ENUM_LANGUAGE _lang)
{
    //--- функция для сообещний пользователей
    switch(_error_code) {
#ifdef __MQL5__
        case ERR_FUNCTION_NOT_ALLOWED:
            info.text1 = (_lang == LANGUAGE_EN) ? "The URL does not allowed for WebRequest" : "Этого URL нет в списке для WebRequest.";
            info.text2 = TELEGRAM_BASE_URL;
            break;
#endif
#ifdef __MQL4__
        case ERR_FUNCTION_NOT_CONFIRMED:
            info.text1 = (_lang == LANGUAGE_EN) ? "The URL does not allowed for WebRequest" : "Этого URL нет в списке для WebRequest.";
            info.text2 = TELEGRAM_BASE_URL;
            break;
#endif

        case ERR_TOKEN_ISEMPTY:
            info.text1 = (_lang == LANGUAGE_EN) ? "The 'Token' parameter is empty." : "Параметр 'Token' пуст.";
            info.text2 = (_lang == LANGUAGE_EN) ? "Please fill this parameter." : "Пожалуйста задайте значение для этого параметра.";
            break;
    }
}

#endif



void OnDeinit(const int reason)
{
    delete newCandle;
    delete tsl;
}

// NOTE: OnTick
void OnTick()
{
#ifdef NEWS_FILTER
    if(newsOn)
    {
        News_Automatic();
        if(ControlNewsTime())
        {
            return;
        }
    }
#endif

    mainOrders.cleanCloseOrders();
    mainOrders.GetMarketOrders();

    CheckearOrdernesyGenerarGrids();
    // Breackeven Conditions & action
    // ——————————————————————————————————————————————————————————————————
    if(breakevenOn) doBreackevenAction();
    if(TslON) tsl.doTSL();

    // Partial Close:
    // ——————————————————————————————————————————————————————————————————
    if(partialCloseOn) doPartialCloseAction();

    if(GridON == true && CheckPointer(gridSell) != POINTER_INVALID)
    {
        gridSell.doGrid();
        mainOrders.GetMarketOrders();
    }
    if(GridON == true && CheckPointer(gridBuy) != POINTER_INVALID)
    {
        gridBuy.doGrid();
        mainOrders.GetMarketOrders();
    }
    if(GridON == true && closeGridOn == true)
    {
        doCloseGridControl();
    }

    if(!sesionControl.doSessionControl())
    {
        return;
    }

    // ——————————————————————————————————————————————————————————————————
    if(!uTradeReverse)
    {
        if(conditionsToCloseBuy.EvaluateConditions())
        {
            closeAll("buy");
        }
        if(conditionsToCloseSell.EvaluateConditions())
        {
            closeAll("sell");
        }
    }
    if(uTradeReverse)
    {
        if(conditionsToCloseSell.EvaluateConditions())
        {
            closeAll("buy");
        }
        if(conditionsToCloseBuy.EvaluateConditions())
        {
            closeAll("sell");
        }
    }
    // ——————————————————————————————————————————————————————————————————

    //--- CANDLE CLOSE:
    if(CloseCandleMode)
        if(!newCandle.IsNewCandle())
        {
            return;
        }

    // ——————————————————————————————————————————————————————————————————
#ifdef SPREAD_FILTER
    if(SpreadFilterOn)
        if(!spreadFilter()) return;
#endif

#ifdef DAILY_LIMITS
    if(uDailyProfitOn)
    {
        if(dailyProfitCondition.evaluate()) return;
    }
    if(uDailyLossOn)
    {
        if(dailyLossCondition.evaluate()) return;
    }
#endif

    // ——————————————————————————————————————————————————————————————————

    // NOTE: BUY normal
    if(!uTradeReverse)
    {
        if(conditionsToBuy.EvaluateConditions())
        {
            if(modeEntry == Market)
            {
                actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
            }
            else
            {
                double pr = Price("buy", uEntryDistance, _Symbol);
                actionSendOrder = new SendNewOrder("buy", Lots(), "", pr, SL("buy", pr), TP("buy", pr), magico);
            }

            if(actionSendOrder.doAction())
            {
                mainOrders.GetMarketOrders();

                if(GridON == true && CheckPointer(gridBuy) == POINTER_INVALID)
                {
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
        if(conditionsToSell.EvaluateConditions())
        {
            if(modeEntry == Market)
            {
                actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
            }
            else
            {
                double pr = Price("sell", uEntryDistance, _Symbol);
                actionSendOrder = new SendNewOrder("sell", Lots(), "", pr, SL("sell", pr), TP("sell", pr), magico);
            }
            if(actionSendOrder.doAction())
            {
                mainOrders.GetMarketOrders();

                if(GridON == true && CheckPointer(gridSell) == POINTER_INVALID)
                {
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

    if(uTradeReverse)
    {
        // NOTE: BUY reverse
        if(conditionsToSell.EvaluateConditions())
        {
            if(modeEntry == Market)
            {
                actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
            }
            else
            {
                double pr = Price("buy", uEntryDistance, _Symbol);
                actionSendOrder = new SendNewOrder("buy", Lots(), "", pr, SL("buy", pr), TP("buy", pr), magico);
            }

            if(actionSendOrder.doAction())
            {
                mainOrders.GetMarketOrders();

                if(GridON == true && CheckPointer(gridBuy) == POINTER_INVALID)
                {
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
        if(conditionsToBuy.EvaluateConditions())
        {
            if(modeEntry == Market)
            {
                actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
            }
            else
            {
                double pr = Price("sell", uEntryDistance, _Symbol);
                actionSendOrder = new SendNewOrder("sell", Lots(), "", pr, SL("sell", pr), TP("sell", pr), magico);
            }
            if(actionSendOrder.doAction())
            {
                mainOrders.GetMarketOrders();

                if(GridON == true && CheckPointer(gridSell) == POINTER_INVALID)
                {
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
    string symbol = _symbol == "" ? Symbol() : _symbol;
    double points = MarketInfo(symbol, MODE_POINT);
    double distance = pips * 10 * points;
    int    digits = MarketInfo(symbol, MODE_DIGITS);

    if(direction == "buy")
    {
        double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double price = distance == 0 ? ask : ask + distance;

        if(modeEntry == PendingStop)
        {
            double cl = iClose(symbol, 0, 1);
            double op = iOpen(symbol, 0, 1);
            if(cl > op)
            {
                price = cl + distance;
            }
            else
            {
                price = op + distance;
            }
        }
        if(modeEntry == PendingLimit)
        {
            double cl = iClose(symbol, 0, 1);
            double op = iOpen(symbol, 0, 1);
            if(cl > op)
            {
                price = op - distance;
            }
            else
            {
                price = cl - distance;
            }
        }

        return NormalizeDouble(price, digits);
    }

    if(direction == "sell")
    {
        double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);
        double price = distance == 0 ? bid : bid + distance;

        if(modeEntry == PendingStop)
        {
            double cl = iClose(symbol, 0, 1);
            double op = iOpen(symbol, 0, 1);
            if(cl > op)
            {
                price = op - distance;
            }
            else
            {
                price = cl - distance;
            }
        }
        if(modeEntry == PendingLimit)
        {
            double cl = iClose(symbol, 0, 1);
            double op = iOpen(symbol, 0, 1);
            if(cl > op)
            {
                price = cl + distance;
            }
            else
            {
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
    if(stopLossOn)
        switch(modeSL)
        {
            case FixPips:
                levelSL = new Levels(new ByFixPips(_Symbol, side, userSLpips, "SL", price));
                result = levelSL.calculateLevel();
                break;

            case byMoney:
                levelSL = new Levels(new ByMoney(_Symbol, side, userLots, userSLmoney, "SL"));
                result = levelSL.calculateLevel();
                break;
            case PipsFromOpenCandle:
                levelSL = new Levels(new ByPipsFromCandle(_Symbol, side, userSLpips, "SL", 0, 1));
                result = levelSL.calculateLevel();
        }
    return result;
}
double TP(string side, double price = 0)
{
    double result = 0;
    if(takeProfitOn)
        switch(modeTP)
        {
            case FixPips:
                levelTP = new Levels(new ByFixPips(_Symbol, side, userTPpips, "TP", price));
                result = levelTP.calculateLevel();
                break;

            case byMoney:
                levelTP = new Levels(new ByMoney(_Symbol, side, userLots, userTPmoney, "TP"));
                result = levelTP.calculateLevel();
                break;
            case PipsFromOpenCandle:
                levelSL = new Levels(new ByPipsFromCandle(_Symbol, side, userSLpips, "TP", 0, 1));
                result = levelSL.calculateLevel();
        }
    return result;
}
double Lots()
{
    lotProvider = new LotCalculator();
    double lots = -1;
    switch(modeCalcLots)
    {
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
    string text = "";
    if(type == 0) text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";


    // telegram notifications:
    // ------------------------------------------------------------------
    if(TelegramOn)
    {

        bot.SendMessage(InpChannelNro, text);
        bot.SendScreenShot(InpChannelNro, Symbol(), PERIOD_CURRENT);
    }



    // ------------------------------------------------------------------

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

int Distancia(double precioA, double precioB, string par, string mode = "pips")
{
    double mPoint = MarketInfo(par, MODE_POINT);
    double dist = fabs(precioA - precioB);
    if(mode == "points") return (int) (dist / mPoint);
    if(mode == "pips") return (int) ((dist / mPoint) / 10);
    return 0;
}

double floatingEA()
{
    double profit = 0;
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
        {
            profit += OrderProfit();
        }
    }

    return profit;
}

double openVolume()
{
    double volume = 0;
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
        {
            volume += OrderLots();
        }
    }

    return volume;
}

void CheckearOrdernesyGenerarGrids()
{
    if(mainOrders.qnt() == 1)
    {
        if(mainOrders.last().type() == OP_BUY && CheckPointer(gridBuy) == POINTER_INVALID)
        {
            gridBuy = new Grid(_Symbol, "buy", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
        }
        if(mainOrders.last().type() == OP_SELL && CheckPointer(gridSell) == POINTER_INVALID)
        {
            gridSell = new Grid(_Symbol, "sell", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
        }
    }
    if(mainOrders.qnt() == 0)
    {
        deleteGrid();
    }
}

void deleteGrid()
{
    if(CheckPointer(gridSell) != POINTER_INVALID)
    {
        delete gridSell;
    }
    if(CheckPointer(gridBuy) != POINTER_INVALID)
    {
        delete gridBuy;
    }
}

// clang-format off
bool CloseAllControl()
{
    switch(closeBy)
    {
        case CloseByMoney:
            if(floatingEA() >= closeAllMoney && closeAllMoney > 0) { return true; }
            if(floatingEA() < closeAllMoneyLoss && closeAllMoneyLoss < 0) { return true; }
            break;

        case CloseByAccountPercent:
        {
            double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
            double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;

            if(floatingEA() >= moneyByAccountPerWin && moneyByAccountPerWin > 0) { return true; }
            if(floatingEA() < moneyByAccountPerLos && moneyByAccountPerLos < 0) { return true; }
            break;
        }
        case CloseByPips:
        {
            double moneyLimitWin = openVolume() * closeByPipsWin * 10;
            double moneyLimitLoss = -openVolume() * closeByPipsLoss * 10;
            if(floatingEA() >= moneyLimitWin) { return true; }
            if(floatingEA() < moneyLimitLoss) { return true; }
            break;
        }
    }
    return false;
}
// clang-format on

void closeAll(string side = "")
{
    if(side == "buy" || side == "")
    {
        actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
        actionCloseBuys.doAction();
        if(GridON && CheckPointer(gridBuy) != POINTER_INVALID)
        {
            gridBuy.closeGrid();
            delete gridBuy;
        }
        delete actionCloseBuys;

        if(uDeletePendingsOn)
        {
            actionDeletePendingsBuys = new ActionDeletePendings("buy", magico);
            actionDeletePendingsBuys.doAction();
            delete actionDeletePendingsBuys;
        }
    }
    if(side == "sell" || side == "")
    {
        actionCloseSells = new ActionCloseOrdersByType("sell", magico);
        actionCloseSells.doAction();
        if(GridON && CheckPointer(gridSell) != POINTER_INVALID)
        {
            gridSell.closeGrid();
            delete gridSell;
        }

        if(uDeletePendingsOn)
        {
            actionDeletePendingsSells = new ActionDeletePendings("sell", magico);
            actionDeletePendingsSells.doAction();
            delete actionDeletePendingsSells;
        }

        delete actionCloseSells;
    }
}

void doBreackevenAction()
{
    for(int i = mainOrders.qnt() - 1; i >= 0; i--)
    {
        if(!mainOrders.index(i).breakevenWasDoIt())
        {
            breackevenCondition.setOrder(mainOrders.index(i));
            if(conditionsToBreackeven.EvaluateConditions())
            {
                breackevenAction = new MoveSL();

                double buySl = mainOrders.index(i).price() + userBkvStep * 10 * Point;
                double sellSl = mainOrders.index(i).price() - userBkvStep * 10 * Point;
                double newSl = mainOrders.index(i).type() == OP_BUY ? buySl : sellSl;
                breackevenAction.order(mainOrders.index(i)).newSL(newSl);
                breackevenAction.doAction();
                delete breackevenAction;
            }
        }
    }
}

void doPartialCloseAction()
{
    for(int i = mainOrders.qnt() - 1; i >= 0; i--)
    {
        if(mainOrders.index(i).countPartials() < uQntPartials)
        {
            partialCloseCondition.setOrder(mainOrders.index(i));
            if(conditionsToPartialClose.EvaluateConditions())
            {
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
    if(closeGridTP > 0)
    {
        if(CheckPointer(gridBuy) != POINTER_INVALID)
            if(gridBuy.profit() >= closeGridTP) { gridBuy.closeGrid(); delete gridBuy; }
        if(CheckPointer(gridSell) != POINTER_INVALID)
            if(gridSell.profit() >= closeGridTP) { gridSell.closeGrid(); delete gridSell; }
    }

    if(closeGridSL < 0)
    {
        if(CheckPointer(gridBuy) != POINTER_INVALID)
            if(gridBuy.profit() <= closeGridSL) { gridBuy.closeGrid(); delete gridBuy; }
        if(CheckPointer(gridSell) != POINTER_INVALID)
            if(gridSell.profit() <= closeGridSL) { gridSell.closeGrid(); delete gridSell; }
    }
}
// clang-format on

#ifdef CONTROL_CUSTOM_INDICATOR_FILE

double Indi(int buffer, int candle)
{
    // TODO: copiar la lista de INPUTS para custom indicator:    
    return iCustom(NULL, 0, file_custom_indicator,
    Inputs,
    buffer, candle);
}

#endif

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
    if(News_Fuente == Auto)
    {
        double CheckNews = 0;
        if(AfterNewsStop > 0)
        {
            if(TimeCurrent() - LastUpd >= Upd)
            {
                Comment("News Loading...");
                Print("News Loading...");
                UpdateNews();
                LastUpd = TimeCurrent();
                Comment("");
            }
            WindowRedraw();
            //---Draw a line on the chart news--------------------------------------------
            if(DrawLines)
            {
                for(int i = 0; i < NomNews; i++)
                {
                    string Name = StringSubstr(TimeToStr(TimeNewsFunck(i), TIME_MINUTES) + "_" + NewsArr[1][i] + "_" + NewsArr[3][i], 0, 63);
                    if(NewsArr[3][i] != "")
                        if(ObjectFind(Name) == 0) continue;
                    if(StringFind(str1, NewsArr[1][i]) < 0) continue;
                    if(TimeNewsFunck(i) < TimeCurrent() && Next) continue;

                    color clrf = clrNONE;
                    if(Vhigh && StringFind(NewsArr[2][i], "High") >= 0) clrf = highc;
                    if(Vmedium && StringFind(NewsArr[2][i], "Moderate") >= 0) clrf = mediumc;
                    if(Vlow && StringFind(NewsArr[2][i], "Low") >= 0) clrf = lowc;

                    if(clrf == clrNONE) continue;

                    if(NewsArr[3][i] != "")
                    {
                        ObjectCreate(Name, 0, OBJ_VLINE, TimeNewsFunck(i), 0);
                        ObjectSet(Name, OBJPROP_COLOR, clrf);
                        ObjectSet(Name, OBJPROP_STYLE, Style);
                        ObjectSetInteger(0, Name, OBJPROP_BACK, true);
                    }

                    Print(NewsArr[0, i]);  // tiene la fecha y hora
                    Print(NewsArr[1, i]);  // tiene el Par
                    Print(NewsArr[2, i]);  // tiene el Impacto (low med hi)
                    Print(NewsArr[3, i]);  // tiene el texto de la noticia
                }
            }
            //---------------event Processing------------------------------------
            int i;
            CheckNews = 0;
            for(i = 0; i < NomNews; i++)
            {
                int power = 0;
                if(Vhigh && StringFind(NewsArr[2][i], "High") >= 0) power = 1;
                if(Vmedium && StringFind(NewsArr[2][i], "Moderate") >= 0) power = 2;
                if(Vlow && StringFind(NewsArr[2][i], "Low") >= 0) power = 3;
                if(power == 0) continue;
                if(TimeCurrent() + MinBefore * 60 > TimeNewsFunck(i) && TimeCurrent() - MinAfter * 60 < TimeNewsFunck(i) && StringFind(str1, NewsArr[1][i]) >= 0)
                {
                    CheckNews = 1;
                    break;
                }
                else
                    CheckNews = 0;
            }
            if(CheckNews == 1 && i != Now && Signal)
            {
                Alert("In ", (int) (TimeNewsFunck(i) - TimeCurrent()) / 60, " minutes released news ", NewsArr[1][i], "_", NewsArr[3][i]);
                Now = i;
            }
            /***  ***/
        }

        if(CheckNews > 0)
        {
            /////  We are doing here if we are in the framework of the news
            Comment("News time");

        }
        else
        {
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
    char   post [], result [];
    string TXT = "";
    int    res;
    //--- to work with the server, you must add the URL "https://www.google.com/finance"
    //--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"):
    string google_url = "http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
    //---
    ResetLastError();
    //--- download html-pages
    int timeout = 5000;  //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
    res = WebRequest("GET", google_url, cookie, NULL, timeout, post, 0, result, headers);
    //--- error checking
    if(res == -1)
    {
        Print("WebRequest error, err.code  =", GetLastError());
        MessageBox("You must add the address ' " + google_url + "' in the list of allowed URL tab 'Advisors' ", " Error ", MB_ICONINFORMATION);
        //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
    }
    else
    {
        //--- successful download
        PrintFormat("File successfully downloaded, the file size in bytes  =%d.", ArraySize(result));
        //--- save the data in the file
        int filehandle = FileOpen("news-log.html", FILE_WRITE | FILE_BIN);
        //--- проверка ошибки
        if(filehandle != INVALID_HANDLE)
        {
            //---save the contents of the array result [] in file
            FileWriteArray(filehandle, result, 0, ArraySize(result));
            //--- close file
            FileClose(filehandle);

            int filehandle2 = FileOpen("news-log.html", FILE_READ | FILE_BIN);
            TXT = FileReadString(filehandle2, ArraySize(result));
            FileClose(filehandle2);
        }
        else
        {
            Print("Error in FileOpen. Error code =", GetLastError());
        }
    }

    return (TXT);
}
// ——————————————————————————————————————————————————————————————————
datetime TimeNewsFunck(int nomf)
{
    string s = NewsArr[0][nomf];
    string time = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
    return ((datetime) (StringToTime(time) + offset * 3600));
}
// ——————————————————————————————————————————————————————————————————
void UpdateNews()
{
    string TEXT = ReadCBOE();
    int    sh = StringFind(TEXT, "pageStartAt>") + 12;
    int    sh2 = StringFind(TEXT, "</tbody>");
    TEXT = StringSubstr(TEXT, sh, sh2 - sh);

    sh = 0;
    while(!IsStopped())
    {
        sh = StringFind(TEXT, "event_timestamp", sh) + 17;
        sh2 = StringFind(TEXT, "onclick", sh) - 2;
        if(sh < 17 || sh2 < 0) break;
        NewsArr[0][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);

        sh = StringFind(TEXT, "flagCur", sh) + 10;
        sh2 = sh + 3;
        if(sh < 10 || sh2 < 3) break;
        NewsArr[1][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
        if(StringFind(str1, NewsArr[1][NomNews]) < 0) continue;

        sh = StringFind(TEXT, "title", sh) + 7;
        sh2 = StringFind(TEXT, "Volatility", sh) - 1;
        if(sh < 7 || sh2 < 0) break;
        NewsArr[2][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
        if(StringFind(NewsArr[2][NomNews], "High") >= 0 && !Vhigh) continue;
        if(StringFind(NewsArr[2][NomNews], "Moderate") >= 0 && !Vmedium) continue;
        if(StringFind(NewsArr[2][NomNews], "Low") >= 0 && !Vlow) continue;

        sh = StringFind(TEXT, "left event", sh) + 12;
        int sh1 = StringFind(TEXT, "Speaks", sh);
        sh2 = StringFind(TEXT, "<", sh);
        if(sh < 12 || sh2 < 0) break;
        if(sh1 < 0 || sh1 > sh2)
            NewsArr[3][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
        else

            NomNews++;
        if(NomNews == 300) break;
    }
}

bool ControlNewsTime()
{
    if(News_Fuente != Auto)
    {
        return false;
    }
    bool   TieneNewsProxHora = false;
    string symNews;
    string SymPanel = Symbol();
    int    ahora = TimeGMT();  // hora actual

    int t = ArrayRange(NewsArr, 1);
    // parte1 = StringSubstr(SymPanel, 0, 3);  // saca la primera parte del simbolo (EUR por ej para EURUSD)
    // parte2 = StringSubstr(SymPanel, 3, 6);  // saca la segunda (USD por ej para EURUSD)

    for(int j = 0; j < t; j++)
    {
        symNews = NewsArr[1, j];  // tiene el Par / tomas el par j del array de news
        string s = NewsArr[0][j];
        string time = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
        int    NewsHora = ((datetime) (StringToTime(time)));  // hora de la noticia guardada en el array de news

        // Si la noticia está dentro del rango de minutos en adelante "Turn_Off_Before"
        if(ahora + Turn_OFF_Before * 60 >= NewsHora && NewsHora > ahora)
        {
            Comment("||------ EA OFF for futures News ------||");
            return true;
        }
        else
        {
            int UltimaNewsPasada = 0;

            // recorre todas las noticias buscando la mayor hora del pasado
            for(int j = 0; j < t; j++)
            {
                string s = NewsArr[0][j];
                string time = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
                int    NewsHora = ((datetime) (StringToTime(time)));  // hora de la noticia guardada en el array de news

                if(NewsHora < ahora && NewsHora > UltimaNewsPasada)
                {
                    UltimaNewsPasada = NewsHora;
                }
            }

            if(UltimaNewsPasada >= ahora - Turn_ON_After * 60)
            {
                Comment("||------ EA OFF for pass News ------||");
                return true;
            }
        }
    }

    return false;
}

#endif

// ------------------------------------------------------------------
// void OnChartEvent(const int EventID,
//                   const long& lparam,
//                   const double& dparam,
//                   const string& sparam)

// {
//     if(EventID == CHARTEVENT_KEYDOWN)
//     {
//         short Tecla = TranslateKey((int) lparam);  //Convirtir la tecla presionada en el lparam
//         Print(ShortToString(Tecla));

//         if(ShortToString(Tecla) == "a")
//         {
//             bot.SendMessage(InpChannelNro, "es compra");
//             bot.SendScreenShot(InpChannelNro, Symbol(), PERIOD_CURRENT);
//         }
//     }
// }


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


