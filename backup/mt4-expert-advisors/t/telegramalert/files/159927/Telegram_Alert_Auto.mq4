// Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159871#p159871

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
#property link "http://fxcodebase.com"
#property version "1.0"
#property description "Expert Advisor"
#property strict

// #include "PanelGUI.mqh"//

//--- input parameters
enum SEND_MODE {
    byName, // Channel Name
    byId,   // Chat Id
};
// --------------------------------------------------------------------------------------------
input SEND_MODE sendMode       = byId;           // Send Mode:
input string    InpChannelName = "@...";         // Channel Name
input long      chat_id        = -1001779335873; // Chat Id:
// input string InpToken       = "... ask to bothfather your token"; // Token
input string InpToken    = "5522964431:AAGisI-heJUa7uyPPQu1zbFj4CNiIZXyzw8"; // Token
input string mySigalname = "... your signal name";
input string _template   = ""; // TemplateName e.g ADX
input string uMsg        = ""; // Custom Message:

input bool            AlertonTelegram         = true;
input bool            UseFormat_forCopier     = false;
input bool            SendScreenShot          = true;
input ENUM_TIMEFRAMES ScreenShotTimeFrame     = PERIOD_CURRENT;
input bool            MobileNotification      = false;
input bool            EmailNotification       = false;
uint                  ServerDelayMilliseconds = 300;
string                AllowSymbols            = ""; // Allow Trading Symbols (Ex: EURUSDq,EURUSDx,EURUSDa)

// --------------------------------------------------------------------------------------------
input string Tautonoti    = "==== Automatic Notifications ===="; // ————————————————————————
input bool   auto_noti_on = false;                               // Send Automatic Notifications?
input int    minutes      = 5;                                   // Minutes between notifications

input string TIndiNoti                = "==== Notifications based on Indicator ===="; // ————————————————————————
input bool   indi_noti_on             = false;                                        // Indicator Notifications On?
input string indicator_file           = "indicator file";                             // Indicator File Name:
input int    bufferToSell             = 0; // Buffer Sell:
input int    bufferToBuy              = 1; // Buffer Buy:
input int    candles_back_for_signals = 1; // Candles Back For Signals
bool         indicator_init           = true;
//---
double Indi(int buffer, int candle = 1) { return iCustom(NULL, 0, indicator_file, buffer, candle); }

class ConditionIndicatorBuy
{
    double lastSignal;

  public:
    bool evaluate()
    {
        for (int i = 0; i <= candles_back_for_signals; i++) {
            double indi = Indi(bufferToBuy, i);
            if (indi > 0 && indi != EMPTY_VALUE && indi != lastSignal) {
                lastSignal = indi;
                return true;
            }
        }
        return false;
    }
};
ConditionIndicatorBuy conditionIndicatorBuy;

class ConditionIndicatorSell
{
    double lastSignal;

  public:
    bool evaluate()
    {
        for (int i = 0; i <= candles_back_for_signals; i++) {
            double indi = Indi(bufferToSell, i);
            if (indi > 0 && indi != EMPTY_VALUE && indi != lastSignal) {
                lastSignal = indi;
                return true;
            }
        }
        return false;
    }
};
ConditionIndicatorSell conditionIndicatorSell;

bool OnInit_CustomIndicator()
{
    double temp = iCustom(NULL, 0, indicator_file, 0, 0);
    if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD) {
        MessageBox("THIS EA NEED AN INDICATOR\n install the file:\n" + indicator_file + "\ninto the folder:\nMQL4/Indicators.", "Important Information", MB_ICONINFORMATION);
        Alert("THIS EA NEED AN INDICATOR, install the file: " + indicator_file + " into the folder: MQL4/Indicators.");
        // indicator_init = false;
    }

    if (!indicator_init) return false;

    // ShortStrategy.addCondition(&conditionIndicatorSell);
    // LongStrategy.addCondition(&conditionIndicatorBuy);

    return true;
}

bool CheckIndicatorSignals()
{

    if (!indi_noti_on) return false;

    double temp = iCustom(NULL, 0, indicator_file, 0, 0);
    if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD) {
        // Alert("THIS EA NEED AN INDICATOR, install the file: " + indicator_file + " into the folder: MQL4/Indicators.");
        return false;
    }

    if (conditionIndicatorSell.evaluate()) {
        // Send Telegram Alert for Sell Signal
        string message = " Sell Signal: " + mySigalname;
        PushToSubscriber(Symbol(), message);
        return true;
    }
    if (conditionIndicatorBuy.evaluate()) {
        // Send Telegram Alert for Buy Signal
        string message = " Buy Signal: " + mySigalname;
        PushToSubscriber(Symbol(), message);
        return true;
    }
    return false;
}

// --------------------------------------------------------------------------------------------

#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>

// NOTE: GUI
// ------------------------------------------------------------------
#define GUI_ON
#ifdef GUI_ON

bool OnInit_GUI()
{
    bool res = true;
    if (gui.reason() != REASON_CHARTCHANGE && gui.reason() != REASON_TEMPLATE && gui.reason() != REASON_PARAMETERS) {
        int rows      = 4;
        int altoPanel = (rows + 1) * 18;
        res           = gui.Create(0, "Telegram Sender", 0, 0, 0, 185, altoPanel);
        if (res) gui.Run();
    }
    return res;
}

void OnDeinit_GUI(int reason)
{
    gui.reason(reason);
    if (gui.reason() != REASON_CHARTCHANGE && gui.reason() != REASON_PARAMETERS) {
        gui.Destroy(reason);
    }
}

// clang-format off
class GUI : public CAppDialog
{

    int _magic;
    int _high, _width, _widthFull;
    int _x, _y;
    int _gapV, _gapH;
    int _reason; // la voy a usar para cuando se resetea el EA

    public:
    GUI(int magic = 0)
    {
        _high = 18;
        _width = 75;
        _x = 10;
        _y = 10;
        _gapV = 3;
        _gapH = 5;
        _magic = magic;
        _widthFull = _width * 2 + _gapH;
    }
    ~GUI() {}


    // CLabel  lbLots, lbSl, lbTp, lbCandles, lbRB, lbRisk;
    // CButton btBuy, btSell, btCloseAll, btClosePartialPair, btClosePair, btReverse, btHedge, btBreackeven, btSendTelegram,btBuyEma, btSellEma;
    // CEdit   eCandles, edit2, eLots, eSl, eTp, eRisk, eRB, eBuyEma, eSellEma;
    CButton btSendTelegram;

    void reason(int inpreason) { _reason = inpreason; }
    int  reason(void) { return _reason; }

    // NOTE: Create Pannel:
    // ------------------------------------------------------------------
    int Row(int r) { return _x + (r * _high) + r * _gapV; }
    int Col(int c) { return _y + (c * _width) + c * _gapH; }

    bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
    {
        if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;
        if(!Create_button("Send Telegram",    Col(0), Row(0), _high, _widthFull, btSendTelegram)) return false;

        return true;
    }

    virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);

    void HoverEvents(const int id, const long& lparam, const double& dparam, const string& sparam)
    {
        if(btSendTelegram.IsActive()) btSendTelegram.ColorBackground(PaleGreen); else btSendTelegram.ColorBackground(CONTROLS_BUTTON_COLOR_BG);        
    }

    protected:
    bool Create_label(string name, int x1, int y1, int high, int width, CLabel& label)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        label.Create(m_chart_id, name, 0, x1, y1, x2, y2);
        label.Text(name);
        label.Font("Calibri");
        label.Color(C'121, 125, 127');
        label.FontSize(10);
        Add(label);
        return true;
    }
    bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton& bt)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        bt.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        bt.Text(name);
        bt.Font("Calibri");
        bt.FontSize(10);

        Add(bt);
        return true;
    }
    bool Create_Edit(string name, const int x1, const int y1, const int high, const int width, CEdit& ed)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        ed.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        ed.Text("");
        ed.Font("Calibri");
        ed.FontSize(10);

        Add(ed);
        return true;
    }

};


//Mapa de eventos (MACRO substituciones)

EVENT_MAP_BEGIN(GUI)
ON_EVENT(ON_CLICK, btSendTelegram, OnClickSendTelegram)
EVENT_MAP_END(CAppDialog)

GUI    gui();

#endif




#define include_common
#ifdef include_common
//+------------------------------------------------------------------+
//|                                                     Telegram.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
// #property copyright "Copyright 2014, MetaQuotes Software Corp."

//+------------------------------------------------------------------+
//|   Include                                                        |
//+------------------------------------------------------------------+
#include <Arrays\ArrayString.mqh>
#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//|   Define                                                         |
//+------------------------------------------------------------------+
#define CUSTOM_ERROR_FIRST ERR_USER_ERROR_FIRST
#define ERR_JSON_PARSING ERR_USER_ERROR_FIRST + 1
#define ERR_JSON_NOT_OK ERR_USER_ERROR_FIRST + 2
#define ERR_TOKEN_ISEMPTY ERR_USER_ERROR_FIRST + 3
#define ERR_RUN_LIMITATION ERR_USER_ERROR_FIRST + 4
//---
#define ERR_NOT_ACTIVE ERR_USER_ERROR_FIRST + 100
#define ERR_NOT_CONNECTED ERR_USER_ERROR_FIRST + 101
#define ERR_ORDER_SELECT ERR_USER_ERROR_FIRST + 102
#define ERR_INVALID_ORDER_TYPE ERR_USER_ERROR_FIRST + 103
#define ERR_INVALID_SYMBOL_NAME ERR_USER_ERROR_FIRST + 104
#define ERR_INVALID_EXPIRATION_TIME ERR_USER_ERROR_FIRST + 105
#define ERR_HTTP_ERROR_FIRST ERR_USER_ERROR_FIRST + 1000 //+511
//+------------------------------------------------------------------+
//|   ENUM_LANGUAGES                                                 |
//+------------------------------------------------------------------+
enum ENUM_LANGUAGES {
    LANGUAGE_EN, // English
    LANGUAGE_RU  // Russian
};
//+------------------------------------------------------------------+
//|   ENUM_UPDATE_MODE                                               |
//+------------------------------------------------------------------+
enum ENUM_UPDATE_MODE {
    UPDATE_FAST,   // Fast
    UPDATE_NORMAL, // Normal
    UPDATE_SLOW,   // Slow
};
//+------------------------------------------------------------------+
//|   ENUM_RUN_MODE                                                  |
//+------------------------------------------------------------------+
enum ENUM_RUN_MODE { RUN_OPTIMIZATION, RUN_VISUAL, RUN_TESTER, RUN_LIVE };
//+------------------------------------------------------------------+
//|   GetRunMode                                                     |
//+------------------------------------------------------------------+
ENUM_RUN_MODE GetRunMode(void)
{
    if (MQLInfoInteger(MQL_OPTIMIZATION)) return (RUN_OPTIMIZATION);
    if (MQLInfoInteger(MQL_VISUAL_MODE)) return (RUN_VISUAL);
    if (MQLInfoInteger(MQL_TESTER)) return (RUN_TESTER);
    return (RUN_LIVE);
}
//+------------------------------------------------------------------+
//|   ENUM_ERROR_LEVEL                                               |
//+------------------------------------------------------------------+
enum ENUM_ERROR_LEVEL { LEVEL_INFO, LEVEL_WARNING, LEVEL_ERROR, LEVEL_CRITICAL };
//+------------------------------------------------------------------+
//|   CustomInfo                                                     |
//+------------------------------------------------------------------+
struct CustomInfo {
    string           text1;
    string           text2;
    color            colour;
    ENUM_ERROR_LEVEL level;
};
//+------------------------------------------------------------------+
//|   ErrorInfo                                                      |
//+------------------------------------------------------------------+
struct ErrorInfo {
    int              code;
    string           desc;
    ENUM_ERROR_LEVEL level;
    ENUM_LANGUAGES   lang;
};
//+------------------------------------------------------------------+
//|   GetErrorInfo                                                   |
//+------------------------------------------------------------------+
bool GetErrorInfo(ErrorInfo &info)
{

    info.level = LEVEL_INFO;

    if (info.lang == LANGUAGE_EN) {

        switch (info.code) {
        case ERR_NOT_CONNECTED:
            info.desc  = "No connection with server";
            info.level = LEVEL_ERROR;
            break;
        case ERR_JSON_PARSING:
            info.desc  = "JSON parsing error";
            info.level = LEVEL_ERROR;
            break;
        case ERR_JSON_NOT_OK:
            info.desc  = "JSON parsing not OK";
            info.level = LEVEL_ERROR;
            break;
        case ERR_TOKEN_ISEMPTY:
            info.desc  = "Token is empty";
            info.level = LEVEL_ERROR;
            break;
        case ERR_RUN_LIMITATION:
            info.desc  = "The bot does not run in tester mode";
            info.level = LEVEL_ERROR;
            break;

        case ERR_WEBREQUEST_INVALID_ADDRESS:
            info.desc = "Invalid URL";
            break;
        case ERR_WEBREQUEST_CONNECT_FAILED:
            info.desc = "Failed to connect to specified URL";
            break;
        case ERR_WEBREQUEST_TIMEOUT:
            info.desc = "Timeout exceeded";
            break;
        case ERR_WEBREQUEST_REQUEST_FAILED:
            info.desc = "HTTP request failed";
            break;

#ifdef __MQL4__
        case ERR_FUNCTION_NOT_CONFIRMED:
            info.desc = "URL does not allowed for WebRequest";
            break;
#endif

#ifdef __MQL5__
        case ERR_FUNCTION_NOT_ALLOWED:
            info.desc = "URL does not allowed for WebRequest";
            break;
        case ERR_FILE_NOT_EXIST:
            info.desc = "File is not exists";
            break;
        case ERR_CHART_NOT_FOUND:
            info.desc = "Chart not found";
            break;
        case ERR_SUCCESS:
            info.desc = "The operation completed successfully";
            break;
#endif
        //---
        case ERR_HTTP_ERROR_FIRST + 100:
            info.desc = "Continue";
            break;
        case ERR_HTTP_ERROR_FIRST + 101:
            info.desc = "Switching Protocols";
            break;
        case ERR_HTTP_ERROR_FIRST + 103:
            info.desc = "Checkpoint";
            break;
        case ERR_HTTP_ERROR_FIRST + 200:
            info.desc = "OK";
            break;
        case ERR_HTTP_ERROR_FIRST + 201:
            info.desc = "Created";
            break;
        case ERR_HTTP_ERROR_FIRST + 202:
            info.desc = "Accepted";
            break;
        case ERR_HTTP_ERROR_FIRST + 203:
            info.desc = "Non-Authoritative Information";
            break;
        case ERR_HTTP_ERROR_FIRST + 204:
            info.desc = "No Content";
            break;
        case ERR_HTTP_ERROR_FIRST + 205:
            info.desc = "Reset Content";
            break;
        case ERR_HTTP_ERROR_FIRST + 206:
            info.desc = "Partial Content";
            break;
        case ERR_HTTP_ERROR_FIRST + 300:
            info.desc = "Multiple Choices";
            break;
        case ERR_HTTP_ERROR_FIRST + 301:
            info.desc = "Moved Permanently";
            break;
        case ERR_HTTP_ERROR_FIRST + 302:
            info.desc = "Found";
            break;
        case ERR_HTTP_ERROR_FIRST + 303:
            info.desc = "See Other";
            break;
        case ERR_HTTP_ERROR_FIRST + 304:
            info.desc = "Not Modified";
            break;
        case ERR_HTTP_ERROR_FIRST + 306:
            info.desc = "Switch Proxy";
            break;
        case ERR_HTTP_ERROR_FIRST + 307:
            info.desc = "Temporary Redirect";
            break;
        case ERR_HTTP_ERROR_FIRST + 308:
            info.desc = "Resume Incomplete";
            break;
        case ERR_HTTP_ERROR_FIRST + 400:
            info.desc = "Bad Request";
            break;
        case ERR_HTTP_ERROR_FIRST + 401:
            info.desc = "Unauthorized";
            break;
        case ERR_HTTP_ERROR_FIRST + 402:
            info.desc = "Payment Required";
            break;
        case ERR_HTTP_ERROR_FIRST + 403:
            info.desc = "Forbidden";
            break;
        case ERR_HTTP_ERROR_FIRST + 404:
            info.desc = "Not Found";
            break;
        case ERR_HTTP_ERROR_FIRST + 405:
            info.desc = "Method Not Allowed";
            break;
        case ERR_HTTP_ERROR_FIRST + 406:
            info.desc = "Not Acceptable";
            break;
        case ERR_HTTP_ERROR_FIRST + 407:
            info.desc = "Proxy Authentication Required";
            break;
        case ERR_HTTP_ERROR_FIRST + 408:
            info.desc = "Request Timeout";
            break;
        case ERR_HTTP_ERROR_FIRST + 409:
            info.desc = "Conflict";
            break;
        case ERR_HTTP_ERROR_FIRST + 410:
            info.desc = "Gone";
            break;
        case ERR_HTTP_ERROR_FIRST + 411:
            info.desc = "Length Required";
            break;
        case ERR_HTTP_ERROR_FIRST + 412:
            info.desc = "Precondition Failed";
            break;
        case ERR_HTTP_ERROR_FIRST + 413:
            info.desc = "Request Entity Too Large";
            break;
        case ERR_HTTP_ERROR_FIRST + 414:
            info.desc = "Request-URI Too Long";
            break;
        case ERR_HTTP_ERROR_FIRST + 415:
            info.desc = "Unsupported Media Type";
            break;
        case ERR_HTTP_ERROR_FIRST + 416:
            info.desc = "Requested Range Not Satisfiable";
            break;
        case ERR_HTTP_ERROR_FIRST + 417:
            info.desc = "Expectation Failed";
            break;
        case ERR_HTTP_ERROR_FIRST + 500:
            info.desc = "Internal Server Error";
            break;
        case ERR_HTTP_ERROR_FIRST + 501:
            info.desc = "Not Implemented";
            break;
        case ERR_HTTP_ERROR_FIRST + 502:
            info.desc = "Bad Gateway";
            break;
        case ERR_HTTP_ERROR_FIRST + 503:
            info.desc = "Service Unavailable";
            break;
        case ERR_HTTP_ERROR_FIRST + 504:
            info.desc = "Gateway Timeout";
            break;
        case ERR_HTTP_ERROR_FIRST + 505:
            info.desc = "HTTP Version Not Supported";
            break;
        case ERR_HTTP_ERROR_FIRST + 511:
            info.desc = "Network Authentication Required";
            break;

            //--- The error codes returned by trade server:
#ifdef __MQL4__
        case ERR_NO_ERROR:
            info.desc = "No error";
            break;
        case ERR_NO_RESULT:
            info.desc  = "No error returned, but the result is unknown";
            info.level = LEVEL_WARNING;
            break;
        case ERR_COMMON_ERROR:
            info.desc  = "Common error.";
            info.level = LEVEL_WARNING;
            break;
        case ERR_INVALID_TRADE_PARAMETERS:
            info.desc  = "Invalid trade parameters";
            info.level = LEVEL_WARNING;
            break;
        case ERR_SERVER_BUSY:
            info.desc  = "Trade server is busy";
            info.level = LEVEL_WARNING;
            break;
        case ERR_OLD_VERSION:
            info.desc  = "Old version of the client terminal";
            info.level = LEVEL_WARNING;
            break;
        case ERR_NO_CONNECTION:
            info.desc  = "No connection with trade server";
            info.level = LEVEL_WARNING;
            break;
        case ERR_NOT_ENOUGH_RIGHTS:
            info.desc  = "Not enough rights";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TOO_FREQUENT_REQUESTS:
            info.desc  = "Too frequent requests";
            info.level = LEVEL_WARNING;
            break;
        case ERR_MALFUNCTIONAL_TRADE:
            info.desc  = "Malfunctional trade operation";
            info.level = LEVEL_WARNING;
            break;
        case ERR_ACCOUNT_DISABLED:
            info.desc  = "Account disabled";
            info.level = LEVEL_ERROR;
            break;
        case ERR_INVALID_ACCOUNT:
            info.desc  = "Invalid account";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_TIMEOUT:
            info.desc  = "Trade timeout";
            info.level = LEVEL_WARNING;
            break;
        case ERR_INVALID_PRICE:
            info.desc  = "Invalid price";
            info.level = LEVEL_WARNING;
            break;
        case ERR_INVALID_STOPS:
            info.desc  = "Invalid stops";
            info.level = LEVEL_WARNING;
            break;
        case ERR_INVALID_TRADE_VOLUME:
            info.desc  = "Invalid trade volume";
            info.level = LEVEL_WARNING;
            break;
        case ERR_MARKET_CLOSED:
            info.desc  = "Market is closed";
            info.level = LEVEL_ERROR;
            break;
        case ERR_TRADE_DISABLED:
            info.desc  = "Trade is disabled";
            info.level = LEVEL_ERROR;
            break;
        case ERR_NOT_ENOUGH_MONEY:
            info.desc  = "Not enough money";
            info.level = LEVEL_ERROR;
            break;
        case ERR_PRICE_CHANGED:
            info.desc  = "Price changed";
            info.level = LEVEL_WARNING;
            break;
        case ERR_OFF_QUOTES:
            info.desc  = "Off quotes";
            info.level = LEVEL_WARNING;
            break;
        case ERR_BROKER_BUSY:
            info.desc  = "Broker is busy";
            info.level = LEVEL_WARNING;
            break;
        case ERR_REQUOTE:
            info.desc  = "Requote";
            info.level = LEVEL_WARNING;
            break;
        case ERR_ORDER_LOCKED:
            info.desc  = "Order is locked";
            info.level = LEVEL_WARNING;
            break;
        case ERR_LONG_POSITIONS_ONLY_ALLOWED:
            info.desc  = "Long positions only allowed";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TOO_MANY_REQUESTS:
            info.desc  = "Too many requests";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_MODIFY_DENIED:
            info.desc  = "Modification denied because order too close to market";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_CONTEXT_BUSY:
            info.desc  = "Trade context is busy";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_EXPIRATION_DENIED:
            info.desc  = "Expirations are denied by broker";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_TOO_MANY_ORDERS:
            info.desc  = "The amount of open and pending orders has reached the limit set by the broker";
            info.level = LEVEL_ERROR;
            break;
        case ERR_TRADE_HEDGE_PROHIBITED:
            info.desc  = "An attempt to open a position opposite to the existing one when hedging is disabled";
            info.level = LEVEL_ERROR;
            break;
        case ERR_TRADE_PROHIBITED_BY_FIFO:
            info.desc  = "An attempt to close a position contravening the FIFO rule";
            info.level = LEVEL_WARNING;
            break;
        //--- MQL4 run time error codes
        case ERR_TRADE_NOT_ALLOWED:
            info.desc  = "Trade is not allowed. Enable checkbox (Allow live trading) in the expert properties";
            info.level = LEVEL_WARNING;
            break;
        case ERR_LONGS_NOT_ALLOWED:
            info.desc  = "Longs are not allowed. Check the expert properties";
            info.level = LEVEL_ERROR;
            break;
        case ERR_SHORTS_NOT_ALLOWED:
            info.desc  = "Shorts are not allowed. Check the expert properties";
            info.level = LEVEL_ERROR;
            break;
#endif

        //---
        case ERR_INVALID_ORDER_TYPE:
            info.desc  = "Invalid order type";
            info.level = LEVEL_ERROR;
            break;
        case ERR_INVALID_SYMBOL_NAME:
            info.desc  = "Invalid symbol name";
            info.level = LEVEL_ERROR;
            break;
        case ERR_INVALID_EXPIRATION_TIME:
            info.desc  = "Invalid expiration time";
            info.level = LEVEL_ERROR;
            break;
        case ERR_ORDER_SELECT:
            info.desc  = "Error function OrderSelect()";
            info.level = LEVEL_ERROR;
            break;
            //---

        default:
            info.desc = "Unknown error " + IntegerToString(info.code);
            return (false);
        }
    }

    //---
    if (info.lang == LANGUAGE_RU) {
        switch (info.code) {
        case ERR_NOT_ACTIVE:
            info.desc = "Нет лицензии";
            break;
        case ERR_NOT_CONNECTED:
            info.desc = "Нет соединения с торговым сервером";
            break;

        case ERR_JSON_PARSING:
            info.desc  = "Ошибка JSON структуры ответа";
            info.level = LEVEL_ERROR;
            break;
        case ERR_JSON_NOT_OK:
            info.desc  = "Парсинг JSON завершен с ошибкой";
            info.level = LEVEL_ERROR;
            break;
        case ERR_TOKEN_ISEMPTY:
            info.desc  = "Токен-пустая строка";
            info.level = LEVEL_ERROR;
            break;
        case ERR_RUN_LIMITATION:
            info.desc  = "Бот не работает в тестере стратегий";
            info.level = LEVEL_ERROR;
            break;

        //---
        case ERR_WEBREQUEST_INVALID_ADDRESS:
            info.desc = "URL не прошел проверку";
            break;
        case ERR_WEBREQUEST_CONNECT_FAILED:
            info.desc = "Не удалось подключиться к указанному URL";
            break;
        case ERR_WEBREQUEST_TIMEOUT:
            info.desc = "Превышен таймаут получения данных";
            break;
        case ERR_WEBREQUEST_REQUEST_FAILED:
            info.desc = "Ошибка в результате выполнения HTTP запроса";
            break;

#ifdef __MQL4__
        case ERR_FUNCTION_NOT_CONFIRMED:
            info.desc = "URL нет в списке для WebRequest";
            break;
#endif

#ifdef __MQL5__
        case ERR_FUNCTION_NOT_ALLOWED:
            info.desc = "URL нет в списке для WebRequest";
            break;
        case ERR_FILE_NOT_EXIST:
            info.desc = "Файла не существует";
            break;
        case ERR_CHART_NOT_FOUND:
            info.desc = "График не найден";
            break;
        case ERR_SUCCESS:
            info.desc = "Операция выполнена успешно";
            break;
#endif
        //---
        case ERR_HTTP_ERROR_FIRST + 100:
            info.desc = "Continue";
            break;
        case ERR_HTTP_ERROR_FIRST + 101:
            info.desc = "Switching Protocols";
            break;
        case ERR_HTTP_ERROR_FIRST + 103:
            info.desc = "Checkpoint";
            break;
        case ERR_HTTP_ERROR_FIRST + 200:
            info.desc = "OK";
            break;
        case ERR_HTTP_ERROR_FIRST + 201:
            info.desc = "Created";
            break;
        case ERR_HTTP_ERROR_FIRST + 202:
            info.desc = "Accepted";
            break;
        case ERR_HTTP_ERROR_FIRST + 203:
            info.desc = "Non-Authoritative Information";
            break;
        case ERR_HTTP_ERROR_FIRST + 204:
            info.desc = "No Content";
            break;
        case ERR_HTTP_ERROR_FIRST + 205:
            info.desc = "Reset Content";
            break;
        case ERR_HTTP_ERROR_FIRST + 206:
            info.desc = "Partial Content";
            break;
        case ERR_HTTP_ERROR_FIRST + 300:
            info.desc = "Multiple Choices";
            break;
        case ERR_HTTP_ERROR_FIRST + 301:
            info.desc = "Moved Permanently";
            break;
        case ERR_HTTP_ERROR_FIRST + 302:
            info.desc = "Found";
            break;
        case ERR_HTTP_ERROR_FIRST + 303:
            info.desc = "See Other";
            break;
        case ERR_HTTP_ERROR_FIRST + 304:
            info.desc = "Not Modified";
            break;
        case ERR_HTTP_ERROR_FIRST + 306:
            info.desc = "Switch Proxy";
            break;
        case ERR_HTTP_ERROR_FIRST + 307:
            info.desc = "Temporary Redirect";
            break;
        case ERR_HTTP_ERROR_FIRST + 308:
            info.desc = "Resume Incomplete";
            break;
        case ERR_HTTP_ERROR_FIRST + 400:
            info.desc = "Bad Request";
            break;
        case ERR_HTTP_ERROR_FIRST + 401:
            info.desc = "Unauthorized";
            break;
        case ERR_HTTP_ERROR_FIRST + 402:
            info.desc = "Payment Required";
            break;
        case ERR_HTTP_ERROR_FIRST + 403:
            info.desc = "Forbidden";
            break;
        case ERR_HTTP_ERROR_FIRST + 404:
            info.desc = "Not Found";
            break;
        case ERR_HTTP_ERROR_FIRST + 405:
            info.desc = "Method Not Allowed";
            break;
        case ERR_HTTP_ERROR_FIRST + 406:
            info.desc = "Not Acceptable";
            break;
        case ERR_HTTP_ERROR_FIRST + 407:
            info.desc = "Proxy Authentication Required";
            break;
        case ERR_HTTP_ERROR_FIRST + 408:
            info.desc = "Request Timeout";
            break;
        case ERR_HTTP_ERROR_FIRST + 409:
            info.desc = "Conflict";
            break;
        case ERR_HTTP_ERROR_FIRST + 410:
            info.desc = "Gone";
            break;
        case ERR_HTTP_ERROR_FIRST + 411:
            info.desc = "Length Required";
            break;
        case ERR_HTTP_ERROR_FIRST + 412:
            info.desc = "Precondition Failed";
            break;
        case ERR_HTTP_ERROR_FIRST + 413:
            info.desc = "Request Entity Too Large";
            break;
        case ERR_HTTP_ERROR_FIRST + 414:
            info.desc = "Request-URI Too Long";
            break;
        case ERR_HTTP_ERROR_FIRST + 415:
            info.desc = "Unsupported Media Type";
            break;
        case ERR_HTTP_ERROR_FIRST + 416:
            info.desc = "Requested Range Not Satisfiable";
            break;
        case ERR_HTTP_ERROR_FIRST + 417:
            info.desc = "Expectation Failed";
            break;
        case ERR_HTTP_ERROR_FIRST + 500:
            info.desc = "Internal Server Error";
            break;
        case ERR_HTTP_ERROR_FIRST + 501:
            info.desc = "Not Implemented";
            break;
        case ERR_HTTP_ERROR_FIRST + 502:
            info.desc = "Bad Gateway";
            break;
        case ERR_HTTP_ERROR_FIRST + 503:
            info.desc = "Service Unavailable";
            break;
        case ERR_HTTP_ERROR_FIRST + 504:
            info.desc = "Gateway Timeout";
            break;
        case ERR_HTTP_ERROR_FIRST + 505:
            info.desc = "HTTP Version Not Supported";
            break;
        case ERR_HTTP_ERROR_FIRST + 511:
            info.desc = "Network Authentication Required";
            break;

            //---
#ifdef __MQL4__
        case ERR_NO_ERROR:
            info.desc = "Нет ошибки";
            break;
        case ERR_NO_RESULT:
            info.desc  = "Нет ошибки, но результат неизвестен";
            info.level = LEVEL_WARNING;
            break;
        case ERR_COMMON_ERROR:
            info.desc  = "Общая ошибка";
            info.level = LEVEL_WARNING;
            break;
        case ERR_INVALID_TRADE_PARAMETERS:
            info.desc  = "Неправильные параметры";
            info.level = LEVEL_WARNING;
            break;
        case ERR_SERVER_BUSY:
            info.desc  = "Торговый сервер занят";
            info.level = LEVEL_WARNING;
            break;
        case ERR_OLD_VERSION:
            info.desc  = "Старая версия клиентского терминала";
            info.level = LEVEL_WARNING;
            break;
        case ERR_NO_CONNECTION:
            info.desc  = "Нет связи с торговым сервером";
            info.level = LEVEL_WARNING;
            break;
        case ERR_NOT_ENOUGH_RIGHTS:
            info.desc  = "Недостаточно прав";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TOO_FREQUENT_REQUESTS:
            info.desc  = "Слишком частые запросы";
            info.level = LEVEL_WARNING;
            break;
        case ERR_MALFUNCTIONAL_TRADE:
            info.desc  = "Недопустимая операция нарушающая функционирование сервера";
            info.level = LEVEL_WARNING;
            break;
        case ERR_ACCOUNT_DISABLED:
            info.desc  = "Счет заблокирован";
            info.level = LEVEL_ERROR;
            break;
        case ERR_INVALID_ACCOUNT:
            info.desc  = "Неправильный номер счета";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_TIMEOUT:
            info.desc  = "Истек срок ожидания совершения сделки";
            info.level = LEVEL_WARNING;
            break;
        case ERR_INVALID_PRICE:
            info.desc  = "Неправильная цена";
            info.level = LEVEL_WARNING;
            break;
        case ERR_INVALID_STOPS:
            info.desc  = "Неправильные стопы";
            info.level = LEVEL_WARNING;
            break;
        case ERR_INVALID_TRADE_VOLUME:
            info.desc  = "Неправильный объем";
            info.level = LEVEL_WARNING;
            break;
        case ERR_MARKET_CLOSED:
            info.desc  = "Рынок закрыт";
            info.level = LEVEL_ERROR;
            break;
        case ERR_TRADE_DISABLED:
            info.desc  = "Торговля запрещена";
            info.level = LEVEL_ERROR;
            break;
        case ERR_NOT_ENOUGH_MONEY:
            info.desc  = "Недостаточно денег для совершения операции";
            info.level = LEVEL_ERROR;
            break;
        case ERR_PRICE_CHANGED:
            info.desc  = "Цена изменилась";
            info.level = LEVEL_WARNING;
            break;
        case ERR_OFF_QUOTES:
            info.desc  = "Нет цен";
            info.level = LEVEL_WARNING;
            break;
        case ERR_BROKER_BUSY:
            info.desc  = "Брокер занят";
            info.level = LEVEL_WARNING;
            break;
        case ERR_REQUOTE:
            info.desc  = "Новые цены";
            info.level = LEVEL_WARNING;
            break;
        case ERR_ORDER_LOCKED:
            info.desc  = "Ордер заблокирован и уже обрабатывается";
            info.level = LEVEL_WARNING;
            break;
        case ERR_LONG_POSITIONS_ONLY_ALLOWED:
            info.desc  = "Разрешена только покупка";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TOO_MANY_REQUESTS:
            info.desc  = "Слишком много запросов";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_MODIFY_DENIED:
            info.desc  = "Модификация запрещена, так как ордер слишком близок к рынку";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_CONTEXT_BUSY:
            info.desc  = "Подсистема торговли занята";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_EXPIRATION_DENIED:
            info.desc  = "Использование даты истечения ордера запрещено брокером";
            info.level = LEVEL_WARNING;
            break;
        case ERR_TRADE_TOO_MANY_ORDERS:
            info.desc  = "Количество открытых и отложенных ордеров достигло предела, установленного брокером.";
            info.level = LEVEL_ERROR;
            break;
        case ERR_TRADE_HEDGE_PROHIBITED:
            info.desc = "Попытка открыть противоположную позицию к уже существующей в случае, если хеджирование запрещено";
            info.level = LEVEL_ERROR;
            break;
        case ERR_TRADE_PROHIBITED_BY_FIFO:
            info.desc  = "Попытка закрыть позицию по инструменту в противоречии с правилом FIFO";
            info.level = LEVEL_WARNING;
            break;
        //--- MQL4 run time error codes
        case ERR_TRADE_NOT_ALLOWED:
            info.desc = "Торговля не разрешена. Необходимо включить опцию `Разрешить советнику торговать` в свойствах эксперта";
            info.level = LEVEL_WARNING;
            break;
        case ERR_LONGS_NOT_ALLOWED:
            info.desc  = "Ордера на покупку не разрешены. Необходимо проверить свойства эксперта";
            info.level = LEVEL_ERROR;
            break;
        case ERR_SHORTS_NOT_ALLOWED:
            info.desc  = "Ордера на продажу не разрешены. Необходимо проверить свойства эксперта";
            info.level = LEVEL_ERROR;
            break;
#endif
        //---  торговые
        case ERR_INVALID_ORDER_TYPE:
            info.desc  = "Неправильный тип ордера";
            info.level = LEVEL_ERROR;
            break;
        case ERR_INVALID_SYMBOL_NAME:
            info.desc  = "Неправильное имя инструмента";
            info.level = LEVEL_ERROR;
            break;
        case ERR_INVALID_EXPIRATION_TIME:
            info.desc  = "Неправильное время экспирации";
            info.level = LEVEL_ERROR;
            break;
        case ERR_ORDER_SELECT:
            info.desc  = "Ошибка функции OrderSelect()";
            info.level = LEVEL_ERROR;
            break;

        //---
        default:
            info.desc = "Неизвестная ошибка " + IntegerToString(info.code);
            return (false);
        }
    }
    return (true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetErrorDescription(const int _error_code, const ENUM_LANGUAGES _language = LANGUAGE_EN)
{
    ErrorInfo info;
    info.code = _error_code;
    info.lang = _language;

    GetErrorInfo(info);

    return (info.desc);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_ERROR_LEVEL GetErrorLevel(const int _error_code)
{
    ErrorInfo info;
    info.code = _error_code;
    info.lang = LANGUAGE_EN;

    GetErrorInfo(info);
    return (info.level);
}
//+------------------------------------------------------------------+
//|   PrintError                                                     |
//+------------------------------------------------------------------+
ENUM_ERROR_LEVEL PrintError(int _error_code, const ENUM_LANGUAGES _lang = LANGUAGE_EN)
{
    ErrorInfo info;
    info.code = _error_code;
    info.lang = _lang;
    //---
    GetErrorInfo(info);
    //---
    if (_lang == LANGUAGE_RU)
        printf("Ошибка: %s", info.desc);
    else
        printf("Error: %s", info.desc);
    //---
    return (info.level);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

#endif

#define jason
#ifdef jason
//+------------------------------------------------------------------ß
//|                                                            JAson |
//|    This software is licensed under the MIT https://goo.gl/eyJgHe |
//+------------------------------------------------------------------+
// #property copyright "Copyright © 2006-2017"
// #property version "1.08"
// #property strict
#define DEBUG_PRINT false
//------------------------------------------------------------------	enum enJAType
enum enJAType { jtUNDEF, jtNULL, jtBOOL, jtINT, jtDBL, jtSTR, jtARRAY, jtOBJ };
//------------------------------------------------------------------	class CJAVal
class CJAVal
{
  public:
    virtual void Clear()
    {
        m_parent = NULL;
        m_key    = "";
        m_type   = jtUNDEF;
        m_bv     = false;
        m_iv     = 0;
        m_dv     = 0;
        m_sv     = "";
        ArrayResize(m_e, 0);
    }
    virtual bool Copy(const CJAVal &a)
    {
        m_key = a.m_key;
        CopyData(a);
        return true;
    }
    virtual void CopyData(const CJAVal &a)
    {
        m_type = a.m_type;
        m_bv   = a.m_bv;
        m_iv   = a.m_iv;
        m_dv   = a.m_dv;
        m_sv   = a.m_sv;
        CopyArr(a);
    }
    virtual void CopyArr(const CJAVal &a)
    {
        int n = ArrayResize(m_e, ArraySize(a.m_e));
        for (int i = 0; i < n; i++) {
            m_e[i]          = a.m_e[i];
            m_e[i].m_parent = GetPointer(this);
        }
    }

  public:
    CJAVal     m_e[];
    string     m_key;
    string     m_lkey;
    CJAVal *   m_parent;
    enJAType   m_type;
    bool       m_bv;
    long       m_iv;
    double     m_dv;
    string     m_sv;
    static int code_page;

  public:
    CJAVal() { Clear(); }
    CJAVal(CJAVal *aparent, enJAType atype)
    {
        Clear();
        m_type   = atype;
        m_parent = aparent;
    }
    CJAVal(enJAType t, string a)
    {
        Clear();
        FromStr(t, a);
    }
    CJAVal(const int a)
    {
        Clear();
        m_type = jtINT;
        m_iv   = a;
        m_dv   = (double)m_iv;
        m_sv   = IntegerToString(m_iv);
        m_bv   = m_iv != 0;
    }
    CJAVal(const long a)
    {
        Clear();
        m_type = jtINT;
        m_iv   = a;
        m_dv   = (double)m_iv;
        m_sv   = IntegerToString(m_iv);
        m_bv   = m_iv != 0;
    }
    CJAVal(const double a)
    {
        Clear();
        m_type = jtDBL;
        m_dv   = a;
        m_iv   = (long)m_dv;
        m_sv   = DoubleToString(m_dv);
        m_bv   = m_iv != 0;
    }
    CJAVal(const bool a)
    {
        Clear();
        m_type = jtBOOL;
        m_bv   = a;
        m_iv   = m_bv;
        m_dv   = m_bv;
        m_sv   = IntegerToString(m_iv);
    }
    CJAVal(const CJAVal &a)
    {
        Clear();
        Copy(a);
    }
    ~CJAVal() { Clear(); }

  public:
    virtual bool    IsNumeric() { return m_type == jtDBL || m_type == jtINT; }
    virtual CJAVal *FindKey(string akey)
    {
        for (int i = ArraySize(m_e) - 1; i >= 0; --i)
            if (m_e[i].m_key == akey) return GetPointer(m_e[i]);
        return NULL;
    }
    virtual CJAVal *HasKey(string akey, enJAType atype = jtUNDEF);
    virtual CJAVal *operator[](string akey);
    virtual CJAVal *operator[](int i);
    void            operator=(const CJAVal &a) { Copy(a); }
    void            operator=(const int a)
    {
        m_type = jtINT;
        m_iv   = a;
        m_dv   = (double)m_iv;
        m_bv   = m_iv != 0;
    }
    void operator=(const long a)
    {
        m_type = jtINT;
        m_iv   = a;
        m_dv   = (double)m_iv;
        m_bv   = m_iv != 0;
    }
    void operator=(const double a)
    {
        m_type = jtDBL;
        m_dv   = a;
        m_iv   = (long)m_dv;
        m_bv   = m_iv != 0;
    }
    void operator=(const bool a)
    {
        m_type = jtBOOL;
        m_bv   = a;
        m_iv   = (long)m_bv;
        m_dv   = (double)m_bv;
    }
    void operator=(string a)
    {
        m_type = (a != NULL) ? jtSTR : jtNULL;
        m_sv   = a;
        m_iv   = StringToInteger(m_sv);
        m_dv   = StringToDouble(m_sv);
        m_bv   = a != NULL;
    }

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

    long   ToInt() const { return m_iv; }
    double ToDbl() const { return m_dv; }
    bool   ToBool() const { return m_bv; }
    string ToStr() { return m_sv; }

    virtual void FromStr(enJAType t, string a)
    {
        m_type = t;
        switch (m_type) {
        case jtBOOL:
            m_bv = (StringToInteger(a) != 0);
            m_iv = (long)m_bv;
            m_dv = (double)m_bv;
            m_sv = a;
            break;
        case jtINT:
            m_iv = StringToInteger(a);
            m_dv = (double)m_iv;
            m_sv = a;
            m_bv = m_iv != 0;
            break;
        case jtDBL:
            m_dv = StringToDouble(a);
            m_iv = (long)m_dv;
            m_sv = a;
            m_bv = m_iv != 0;
            break;
        case jtSTR:
            m_sv   = Unescape(a);
            m_type = (m_sv != NULL) ? jtSTR : jtNULL;
            m_iv   = StringToInteger(m_sv);
            m_dv   = StringToDouble(m_sv);
            m_bv   = m_sv != NULL;
            break;
        }
    }
    virtual string GetStr(char &js[], int i, int slen)
    {
#ifdef __MQL4__
        if (slen <= 0) return "";
#endif
        char cc[];
        ArrayCopy(cc, js, 0, i, slen);
        return CharArrayToString(cc, 0, WHOLE_ARRAY, CJAVal::code_page);
    }

    virtual void Set(const CJAVal &a)
    {
        if (m_type == jtUNDEF) m_type = jtOBJ;
        CopyData(a);
    }
    virtual void    Set(const CJAVal &list[]);
    virtual CJAVal *Add(const CJAVal &item)
    {
        if (m_type == jtUNDEF) m_type = jtARRAY; /*ASSERT(m_type==jtOBJ || m_type==jtARRAY);*/
        return AddBase(item);
    } // добавление
    virtual CJAVal *Add(const int a)
    {
        CJAVal item(a);
        return Add(item);
    }
    virtual CJAVal *Add(const long a)
    {
        CJAVal item(a);
        return Add(item);
    }
    virtual CJAVal *Add(const double a)
    {
        CJAVal item(a);
        return Add(item);
    }
    virtual CJAVal *Add(const bool a)
    {
        CJAVal item(a);
        return Add(item);
    }
    virtual CJAVal *Add(string a)
    {
        CJAVal item(jtSTR, a);
        return Add(item);
    }
    virtual CJAVal *AddBase(const CJAVal &item)
    {
        int c = ArraySize(m_e);
        ArrayResize(m_e, c + 1);
        m_e[c]          = item;
        m_e[c].m_parent = GetPointer(this);
        return GetPointer(m_e[c]);
    } // добавление
    virtual CJAVal *New()
    {
        if (m_type == jtUNDEF) m_type = jtARRAY; /*ASSERT(m_type==jtOBJ || m_type==jtARRAY);*/
        return NewBase();
    } // добавление
    virtual CJAVal *NewBase()
    {
        int c = ArraySize(m_e);
        ArrayResize(m_e, c + 1);
        return GetPointer(m_e[c]);
    } // добавление

    virtual string Escape(string a);
    virtual string Unescape(string a);

  public:
    virtual void   Serialize(string &js, bool bf = false, bool bcoma = false);
    virtual string Serialize()
    {
        string js;
        Serialize(js);
        return js;
    }
    virtual bool Deserialize(char &js[], int slen, int &i);
    virtual bool ExtrStr(char &js[], int slen, int &i);
    virtual bool Deserialize(string js, int acp = CP_ACP)
    {
        int i = 0;
        Clear();
        CJAVal::code_page = acp;
        char arr[];
        int  slen = StringToCharArray(js, arr, 0, WHOLE_ARRAY, CJAVal::code_page);
        return Deserialize(arr, slen, i);
    }
    virtual bool Deserialize(char &js[], int acp = CP_ACP)
    {
        int i = 0;
        Clear();
        CJAVal::code_page = acp;
        return Deserialize(js, ArraySize(js), i);
    }
};

int CJAVal::code_page = CP_ACP;

//------------------------------------------------------------------	HasKey
CJAVal *CJAVal::HasKey(string akey, enJAType atype /*=jtUNDEF*/)
{
    for (int i = 0; i < ArraySize(m_e); i++)
        if (m_e[i].m_key == akey) {
            if (atype == jtUNDEF || atype == m_e[i].m_type) return GetPointer(m_e[i]);
            break;
        }
    return NULL;
}
//------------------------------------------------------------------	operator[]
CJAVal *CJAVal::operator[](string akey)
{
    if (m_type == jtUNDEF) m_type = jtOBJ;
    CJAVal *v = FindKey(akey);
    if (v) return v;
    CJAVal b(GetPointer(this), jtUNDEF);
    b.m_key = akey;
    v       = Add(b);
    return v;
}
//------------------------------------------------------------------	operator[]
CJAVal *CJAVal::operator[](int i)
{
    if (m_type == jtUNDEF) m_type = jtARRAY;
    while (i >= ArraySize(m_e)) {
        CJAVal b(GetPointer(this), jtUNDEF);
        if (CheckPointer(Add(b)) == POINTER_INVALID) return NULL;
    }
    return GetPointer(m_e[i]);
}
//------------------------------------------------------------------	Set
void CJAVal::Set(const CJAVal &list[])
{
    if (m_type == jtUNDEF) m_type = jtARRAY;
    int n = ArrayResize(m_e, ArraySize(list));
    for (int i = 0; i < n; ++i) {
        m_e[i]          = list[i];
        m_e[i].m_parent = GetPointer(this);
    }
}
//------------------------------------------------------------------	Serialize
void CJAVal::Serialize(string &js, bool bkey /*=false*/, bool coma /*=false*/)
{
    if (m_type == jtUNDEF) return;
    if (coma) js += ",";
    if (bkey) js += StringFormat("\"%s\":", m_key);
    int _n = ArraySize(m_e);
    switch (m_type) {
    case jtNULL:
        js += "null";
        break;
    case jtBOOL:
        js += (m_bv ? "true" : "false");
        break;
    case jtINT:
        js += IntegerToString(m_iv);
        break;
    case jtDBL:
        js += DoubleToString(m_dv);
        break;
    case jtSTR: {
        string ss = Escape(m_sv);
        if (StringLen(ss) > 0)
            js += StringFormat("\"%s\"", ss);
        else
            js += "null";
    } break;
    case jtARRAY:
        js += "[";
        for (int i = 0; i < _n; i++)
            m_e[i].Serialize(js, false, i > 0);
        js += "]";
        break;
    case jtOBJ:
        js += "{";
        for (int i = 0; i < _n; i++)
            m_e[i].Serialize(js, true, i > 0);
        js += "}";
        break;
    }
}
//------------------------------------------------------------------	Deserialize
bool CJAVal::Deserialize(char &js[], int slen, int &i)
{
    string num = "0123456789+-.eE";
    int    i0  = i;
    for (; i < slen; i++) {
        char c = js[i];
        if (c == 0) break;
        switch (c) {
        case '\t':
        case '\r':
        case '\n':
        case ' ': // пропускаем из имени пробелы
            i0 = i + 1;
            break;

        case '[': // начало массива. создаём объекты и забираем из js
        {
            i0 = i + 1;
            if (m_type != jtUNDEF) {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            }                 // если значение уже имеет тип, то это ошибка
            m_type = jtARRAY; // задали тип значения
            i++;
            CJAVal val(GetPointer(this), jtUNDEF);
            while (val.Deserialize(js, slen, i)) {
                if (val.m_type != jtUNDEF) Add(val);
                if (val.m_type == jtINT || val.m_type == jtDBL || val.m_type == jtARRAY) i++;
                val.Clear();
                val.m_parent = GetPointer(this);
                if (js[i] == ']') break;
                i++;
                if (i >= slen) {
                    if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                    return false;
                }
            }
            return js[i] == ']' || js[i] == 0;
        } break;
        case ']':
            if (!m_parent) return false;
            return m_parent.m_type == jtARRAY; // конец массива, текущее значение должны быть массивом

        case ':': {
            if (m_lkey == "") {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            }
            CJAVal  val(GetPointer(this), jtUNDEF);
            CJAVal *oc = Add(val); // тип объекта пока не определён
            oc.m_key   = m_lkey;
            m_lkey     = ""; // задали имя ключа
            i++;
            if (!oc.Deserialize(js, slen, i)) {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            }
            break;
        }
        case ',': // разделитель значений // тип значения уже должен быть определён
            i0 = i + 1;
            if (!m_parent && m_type != jtOBJ) {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            } else if (m_parent) {
                if (m_parent.m_type != jtARRAY && m_parent.m_type != jtOBJ) {
                    if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                    return false;
                }
                if (m_parent.m_type == jtARRAY && m_type == jtUNDEF) return true;
            }
            break;

            // примитивы могут быть ТОЛЬКО в массиве / либо самостоятельно
        case '{': // начало объекта. создаем объект и забираем его из js
            i0 = i + 1;
            if (m_type != jtUNDEF) {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            }               // ошибка типа
            m_type = jtOBJ; // задали тип значения
            i++;
            if (!Deserialize(js, slen, i)) {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            } // вытягиваем его
            return js[i] == '}' || js[i] == 0;
            break;
        case '}':
            return m_type == jtOBJ; // конец объекта, текущее значение должно быть объектом

        case 't':
        case 'T': // начало true
        case 'f':
        case 'F': // начало false
            if (m_type != jtUNDEF) {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            }                // ошибка типа
            m_type = jtBOOL; // задали тип значения
            if (i + 3 < slen) {
                if (StringCompare(GetStr(js, i, 4), "true", false) == 0) {
                    m_bv = true;
                    i += 3;
                    return true;
                }
            }
            if (i + 4 < slen) {
                if (StringCompare(GetStr(js, i, 5), "false", false) == 0) {
                    m_bv = false;
                    i += 4;
                    return true;
                }
            }
            if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
            return false; // не тот тип или конец строки
            break;
        case 'n':
        case 'N': // начало null
            if (m_type != jtUNDEF) {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            }                // ошибка типа
            m_type = jtNULL; // задали тип значения
            if (i + 3 < slen)
                if (StringCompare(GetStr(js, i, 4), "null", false) == 0) {
                    i += 3;
                    return true;
                }
            if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
            return false; // не NULL или конец строки
            break;

        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case '-':
        case '+':
        case '.': // начало числа
        {
            if (m_type != jtUNDEF) {
                if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                return false;
            }                 // ошибка типа
            bool dbl = false; // задали тип значения
            int  is  = i;
            while (js[i] != 0 && i < slen) {
                i++;
                if (StringFind(num, GetStr(js, i, 1)) < 0) break;
                if (!dbl) dbl = (js[i] == '.' || js[i] == 'e' || js[i] == 'E');
            }
            m_sv = GetStr(js, is, i - is);
            if (dbl) {
                m_type = jtDBL;
                m_dv   = StringToDouble(m_sv);
                m_iv   = (long)m_dv;
                m_bv   = m_iv != 0;
            } else {
                m_type = jtINT;
                m_iv   = StringToInteger(m_sv);
                m_dv   = (double)m_iv;
                m_bv   = m_iv != 0;
            } // уточнии тип значения
            i--;
            return true; // отодвинулись на 1 символ назад и вышли
            break;
        }
        case '\"':               // начало или конец строки
            if (m_type == jtOBJ) // если тип еще неопределён и ключ не задан
            {
                i++;
                int is = i;
                if (!ExtrStr(js, slen, i)) {
                    if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                    return false;
                } // это ключ, идём до конца строки
                m_lkey = GetStr(js, is, i - is);
            } else {
                if (m_type != jtUNDEF) {
                    if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                    return false;
                }               // ошибка типа
                m_type = jtSTR; // задали тип значения
                i++;
                int is = i;
                if (!ExtrStr(js, slen, i)) {
                    if (DEBUG_PRINT) Print(m_key + " " + string(__LINE__));
                    return false;
                }
                FromStr(jtSTR, GetStr(js, is, i - is));
                return true;
            }
            break;
        }
    }
    return true;
}
//------------------------------------------------------------------	ExtrStr
bool CJAVal::ExtrStr(char &js[], int slen, int &i)
{
    for (; js[i] != 0 && i < slen; i++) {
        char c = js[i];
        if (c == '\"') break; // конец строки
        if (c == '\\' && i + 1 < slen) {
            i++;
            c = js[i];
            switch (c) {
            case '/':
            case '\\':
            case '\"':
            case 'b':
            case 'f':
            case 'r':
            case 'n':
            case 't':
                break; // это разрешенные
            case 'u':  // \uXXXX
            {
                i++;
                for (int j = 0; j < 4 && i < slen && js[i] != 0; j++, i++) {
                    if (!((js[i] >= '0' && js[i] <= '9') || (js[i] >= 'A' && js[i] <= 'F') || (js[i] >= 'a' && js[i] <= 'f'))) {
                        if (DEBUG_PRINT) Print(m_key + " " + CharToString(js[i]) + " " + string(__LINE__));
                        return false;
                    } // не hex
                }
                i--;
                break;
            }
            default:
                break; /*{ return false; } // неразрешенный символ с экранированием */
            }
        }
    }
    return true;
}
//------------------------------------------------------------------	Escape
string CJAVal::Escape(string a)
{
    ushort as[], s[];
    int    n = StringToShortArray(a, as);
    if (ArrayResize(s, 2 * n) != 2 * n) return NULL;
    int j = 0;
    for (int i = 0; i < n; i++) {
        switch (as[i]) {
        case '\\':
            s[j] = '\\';
            j++;
            s[j] = '\\';
            j++;
            break;
        case '"':
            s[j] = '\\';
            j++;
            s[j] = '"';
            j++;
            break;
        case '/':
            s[j] = '\\';
            j++;
            s[j] = '/';
            j++;
            break;
        case 8:
            s[j] = '\\';
            j++;
            s[j] = 'b';
            j++;
            break;
        case 12:
            s[j] = '\\';
            j++;
            s[j] = 'f';
            j++;
            break;
        case '\n':
            s[j] = '\\';
            j++;
            s[j] = 'n';
            j++;
            break;
        case '\r':
            s[j] = '\\';
            j++;
            s[j] = 'r';
            j++;
            break;
        case '\t':
            s[j] = '\\';
            j++;
            s[j] = 't';
            j++;
            break;
        default:
            s[j] = as[i];
            j++;
            break;
        }
    }
    a = ShortArrayToString(s, 0, j);
    return a;
}
//------------------------------------------------------------------	Unescape
string CJAVal::Unescape(string a)
{
    ushort as[], s[];
    int    n = StringToShortArray(a, as);
    if (ArrayResize(s, n) != n) return NULL;
    int j = 0, i = 0;
    while (i < n) {
        ushort c = as[i];
        if (c == '\\' && i < n - 1) {
            switch (as[i + 1]) {
            case '\\':
                c = '\\';
                i++;
                break;
            case '"':
                c = '"';
                i++;
                break;
            case '/':
                c = '/';
                i++;
                break;
            case 'b':
                c = 8; /*08='\b'*/
                ;
                i++;
                break;
            case 'f':
                c = 12; /*0c=\f*/
                i++;
                break;
            case 'n':
                c = '\n';
                i++;
                break;
            case 'r':
                c = '\r';
                i++;
                break;
            case 't':
                c = '\t';
                i++;
                break;
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
        s[j] = c;
        j++;
        i++;
    }
    a = ShortArrayToString(s, 0, j);
    return a;
}
//+------------------------------------------------------------------+

#endif

#define include_telegram
#ifdef include_telegram

//+------------------------------------------------------------------+
//|   Defines                                                        |
//+------------------------------------------------------------------+
#define TELEGRAM_BASE_URL "https://api.telegram.org"
#define WEB_TIMEOUT 5000
//+------------------------------------------------------------------+
//|   ENUM_CHAT_ACTION                                               |
//+------------------------------------------------------------------+
enum ENUM_CHAT_ACTION {
    ACTION_FIND_LOCATION,   // picking location...
    ACTION_RECORD_AUDIO,    // recording audio...
    ACTION_RECORD_VIDEO,    // recording video...
    ACTION_TYPING,          // typing...
    ACTION_UPLOAD_AUDIO,    // sending audio...
    ACTION_UPLOAD_DOCUMENT, // sending file...
    ACTION_UPLOAD_PHOTO,    // sending photo...
    ACTION_UPLOAD_VIDEO     // sending video...
};
//+------------------------------------------------------------------+
//|   ChatActionToString                                             |
//+------------------------------------------------------------------+
string ChatActionToString(const ENUM_CHAT_ACTION _action)
{
    string result = EnumToString(_action);
    result        = StringSubstr(result, 7);
    StringToLower(result);
    return (result);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCustomMessage : public CObject
{
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
        done            = false;
        update_id       = 0;
        message_id      = 0;
        from_id         = 0;
        from_first_name = NULL;
        from_last_name  = NULL;
        from_username   = NULL;
        chat_id         = 0;
        chat_first_name = NULL;
        chat_last_name  = NULL;
        chat_username   = NULL;
        chat_type       = NULL;
        message_date    = 0;
        message_text    = NULL;
        from_id         = 0;
        from_first_name = NULL;
        from_last_name  = NULL;
        from_username   = NULL;
        chat_id         = 0;
        chat_first_name = NULL;
        chat_last_name  = NULL;
        chat_username   = NULL;
        chat_type       = NULL;
        message_date    = 0;
        message_text    = NULL;
    }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCustomChat : public CObject
{
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
class CCustomBot
{
  private:
    //+------------------------------------------------------------------+
    void ArrayAdd(uchar &dest[], const uchar &src[])
    {
        int src_size = ArraySize(src);
        if (src_size == 0) return;

        int dest_size = ArraySize(dest);
        ArrayResize(dest, dest_size + src_size, 500);
        ArrayCopy(dest, src, dest_size, 0, src_size);
    }

    //+------------------------------------------------------------------+
    void ArrayAdd(char &dest[], const string text)
    {
        int len = StringLen(text);
        if (len > 0) {
            uchar src[];
            for (int i = 0; i < len; i++) {
                ushort ch = StringGetCharacter(text, i);

                uchar array[];
                int   total = ShortToUtf8(ch, array);

                int size = ArraySize(src);
                ArrayResize(src, size + total);
                ArrayCopy(src, array, size, 0, total);
            }
            ArrayAdd(dest, src);
        }
    }

    //+------------------------------------------------------------------+
    int SaveToFile(const string filename, const char &text[])
    {
        ResetLastError();

        int handle = FileOpen(filename, FILE_BIN | FILE_ANSI | FILE_WRITE);
        if (handle == INVALID_HANDLE) {
            return (GetLastError());
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
        for (int i = 0; i < length; i++) {
            ushort ch = StringGetCharacter(text, i);

            if ((ch >= 48 && ch <= 57) ||  // 0-9
                (ch >= 65 && ch <= 90) ||  // A-Z
                (ch >= 97 && ch <= 122) || // a-z
                (ch == '!') || (ch == '\'') || (ch == '(') || (ch == ')') || (ch == '*') || (ch == '-') || (ch == '.') || (ch == '_') || (ch == '~')) {
                result += ShortToString(ch);
            } else {
                if (ch == ' ')
                    result += ShortToString('+');
                else {
                    uchar array[];
                    int   total = ShortToUtf8(ch, array);
                    for (int k = 0; k < total; k++)
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

    //+------------------------------------------------------------------+
    int PostRequest(string &out, const string url, const string params, const int timeout = 5000)
    {
        char data[];
        int  data_size = StringLen(params);
        StringToCharArray(params, data, 0, data_size);

        uchar  result[];
        string result_headers;

        //--- application/x-www-form-urlencoded
        int res = WebRequest("POST", url, NULL, NULL, timeout, data, data_size, result, result_headers);
        if (res == 200) // OK
        {
            //--- delete BOM
            int start_index = 0;
            int size        = ArraySize(result);
            for (int i = 0; i < fmin(size, 8); i++) {
                if (result[i] == 0xef || result[i] == 0xbb || result[i] == 0xbf)
                    start_index = i + 1;
                else
                    break;
            }
            //---
            out = CharArrayToString(result, start_index, WHOLE_ARRAY, CP_UTF8);
            return (0);
        } else {
            if (res == -1) {
                return (_LastError);
            } else {
                //--- HTTP errors
                if (res >= 100 && res <= 511) {
                    out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                    Print(out);
                    return (ERR_HTTP_ERROR_FIRST + res);
                }
                return (res);
            }
        }

        return (0);
    }

    //+------------------------------------------------------------------+
    int ShortToUtf8(const ushort _ch, uchar &out[])
    {
        //---
        if (_ch < 0x80) {
            ArrayResize(out, 1);
            out[0] = (uchar)_ch;
            return (1);
        }
        //---
        if (_ch < 0x800) {
            ArrayResize(out, 2);
            out[0] = (uchar)((_ch >> 6) | 0xC0);
            out[1] = (uchar)((_ch & 0x3F) | 0x80);
            return (2);
        }
        //---
        if (_ch < 0xFFFF) {
            if (_ch >= 0xD800 && _ch <= 0xDFFF) // Ill-formed
            {
                ArrayResize(out, 1);
                out[0] = ' ';
                return (1);
            } else if (_ch >= 0xE000 && _ch <= 0xF8FF) // Emoji
            {
                int ch = 0x10000 | _ch;
                ArrayResize(out, 4);
                out[0] = (uchar)(0xF0 | (ch >> 18));
                out[1] = (uchar)(0x80 | ((ch >> 12) & 0x3F));
                out[2] = (uchar)(0x80 | ((ch >> 6) & 0x3F));
                out[3] = (uchar)(0x80 | ((ch & 0x3F)));
                return (4);
            } else {
                ArrayResize(out, 3);
                out[0] = (uchar)((_ch >> 12) | 0xE0);
                out[1] = (uchar)(((_ch >> 6) & 0x3F) | 0x80);
                out[2] = (uchar)((_ch & 0x3F) | 0x80);
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
        ::StringReplace(text, "\n", ShortToString(0x0A));

        //--- replace \u0000
        int haut = 0;
        int pos  = StringFind(text, "\\u");
        while (pos != -1) {
            string strcode = StringSubstr(text, pos, 6);
            string strhex  = StringSubstr(text, pos + 2, 4);

            StringToUpper(strhex);

            int total  = StringLen(strhex);
            int result = 0;
            for (int i = 0, k = total - 1; i < total; i++, k--) {
                int    coef = (int)pow(2, 4 * k);
                ushort ch   = StringGetCharacter(strhex, i);
                if (ch >= '0' && ch <= '9') result += (ch - '0') * coef;
                if (ch >= 'A' && ch <= 'F') result += (ch - 'A' + 10) * coef;
            }

            if (haut != 0) {
                if (result >= 0xDC00 && result <= 0xDFFF) {
                    int dec = ((haut - 0xD800) << 10) + (result - 0xDC00); //+0x10000;
                    StringReplace(text, pos, 6, ShortToString((ushort)dec));
                    haut = 0;
                } else {
                    //--- error: Second byte out of range
                    haut = 0;
                }
            } else {
                if (result >= 0xD800 && result <= 0xDBFF) {
                    haut = result;
                    StringReplace(text, pos, 6, "");
                } else {
                    StringReplace(text, pos, 6, ShortToString((ushort)result));
                }
            }

            pos = StringFind(text, "\\u", pos);
        }
        return (text);
    }

    //+------------------------------------------------------------------+
    int StringReplace(string &string_var, const int start_pos, const int length, const string replacement)
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
        if (_value) return ("true");
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
        m_token        = NULL;
        m_name         = NULL;
        m_update_id    = 0;
        m_first_remove = true;
        m_chats.Clear();
        m_users_filter.Clear();
    }

    //+------------------------------------------------------------------+
    int ChatsTotal() { return (m_chats.Total()); }

    //+------------------------------------------------------------------+
    int Token(const string _token)
    {
        string token = StringTrim(_token);
        if (token == "") return (ERR_TOKEN_ISEMPTY);
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
        if (text == "") return;

        //---
        while (::StringReplace(text, "  ", " ") > 0)
            ;
        ::StringReplace(text, ";", " ");
        ::StringReplace(text, ",", " ");

        //---
        string array[];
        int    amount = StringSplit(text, ' ', array);
        for (int i = 0; i < amount; i++) {
            string username = StringTrim(array[i]);
            if (username != "") {
                //--- remove first @
                if (StringGetCharacter(username, 0) == '@') username = StringSubstr(username, 1);

                m_users_filter.Add(username);
            }
        }
    }
    //+------------------------------------------------------------------+
    string Name() { return (m_name); }

    //+------------------------------------------------------------------+
    int GetMe()
    {
        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);
        //---
        string out;
        string url    = StringFormat("%s/bot%s/getMe", TELEGRAM_BASE_URL, m_token);
        string params = "";
        int    res    = PostRequest(out, url, params, WEB_TIMEOUT);
        if (res == 0) {
            CJAVal js(NULL, jtUNDEF);
            //---
            bool done = js.Deserialize(out);
            if (!done) return (ERR_JSON_PARSING);

            //---
            bool ok = js["ok"].ToBool();
            if (!ok) return (ERR_JSON_NOT_OK);

            //---
            if (m_name == NULL) m_name = js["result"]["username"].ToStr();
        }
        //---
        return (res);
    }
    //+------------------------------------------------------------------+
    int GetUpdates()
    {
        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);

        string out;
        string url    = StringFormat("%s/bot%s/getUpdates", TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("offset=%d", m_update_id);
        //---
        int res = PostRequest(out, url, params, WEB_TIMEOUT);
        if (res == 0) {
            // Print(out);
            //--- parse result
            CJAVal js(NULL, jtUNDEF);
            bool   done = js.Deserialize(out);
            if (!done) return (ERR_JSON_PARSING);

            bool ok = js["ok"].ToBool();
            if (!ok) return (ERR_JSON_NOT_OK);

            CCustomMessage msg;

            int total = ArraySize(js["result"].m_e);
            for (int i = 0; i < total; i++) {
                CJAVal item = js["result"].m_e[i];
                //---
                msg.update_id = item["update_id"].ToInt();
                //---
                msg.message_id   = item["message"]["message_id"].ToInt();
                msg.message_date = (datetime)item["message"]["date"].ToInt();
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

                if (m_first_remove) continue;

                //--- filter
                if (m_users_filter.Total() == 0 || (m_users_filter.Total() > 0 && m_users_filter.SearchLinear(msg.from_username) >= 0)) {

                    //--- find the chat
                    int index = -1;
                    for (int j = 0; j < m_chats.Total(); j++) {
                        CCustomChat *chat = m_chats.GetNodeAtIndex(j);
                        if (chat.m_id == msg.chat_id) {
                            index = j;
                            break;
                        }
                    }

                    //--- add new one to the chat list
                    if (index == -1) {
                        m_chats.Add(new CCustomChat);
                        CCustomChat *chat           = m_chats.GetLastNode();
                        chat.m_id                   = msg.chat_id;
                        chat.m_time                 = TimeLocal();
                        chat.m_state                = 0;
                        chat.m_new_one.message_text = msg.message_text;
                        chat.m_new_one.done         = false;
                    }
                    //--- update chat message
                    else {
                        CCustomChat *chat           = m_chats.GetNodeAtIndex(index);
                        chat.m_time                 = TimeLocal();
                        chat.m_new_one.message_text = msg.message_text;
                        chat.m_new_one.done         = false;
                    }
                }
            }
            m_first_remove = false;
        }
        //---
        return (res);
    }

    //+------------------------------------------------------------------+
    int SendChatAction(const long _chat_id, const ENUM_CHAT_ACTION _action)
    {
        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);
        string out;
        string url    = StringFormat("%s/bot%s/sendChatAction", TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("chat_id=%lld&action=%s", _chat_id, ChatActionToString(_action));
        int    res    = PostRequest(out, url, params, WEB_TIMEOUT);
        return (res);
    }

    //+------------------------------------------------------------------+
    int SendPhoto(const long _chat_id, const string _photo_id, const string _caption = NULL)
    {
        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);

        string out;
        string url    = StringFormat("%s/bot%s/sendPhoto", TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("chat_id=%lld&photo=%s", _chat_id, _photo_id);
        if (_caption != NULL) params += "&caption=" + UrlEncode(_caption);

        int res = PostRequest(out, url, params, WEB_TIMEOUT);
        if (res != 0) {
            //--- parse result
            CJAVal js(NULL, jtUNDEF);
            bool   done = js.Deserialize(out);
            if (!done) return (ERR_JSON_PARSING);

            //--- get error description
            bool   ok       = js["ok"].ToBool();
            long   err_code = js["error_code"].ToInt();
            string err_desc = js["description"].ToStr();
        }
        //--- done
        return (res);
    }

    //+------------------------------------------------------------------+
    int SendPhoto(string &_photo_id, const string _channel_name, const string _local_path, const string _caption = NULL, const bool _common_flag = false, const int _timeout = 10000)
    {
        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);

        string name = StringTrim(_channel_name);
        if (StringGetCharacter(name, 0) != '@') name = "@" + name;

        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);

        ResetLastError();
        //--- copy file to memory buffer
        if (!FileIsExist(_local_path, _common_flag)) return (ERR_FILE_NOT_EXIST);

        //---
        int flags = FILE_READ | FILE_BIN | FILE_SHARE_WRITE | FILE_SHARE_READ;
        if (_common_flag) flags |= FILE_COMMON;

        //---
        int file = FileOpen(_local_path, flags);
        if (file < 0) return (_LastError);

        //---
        int   file_size = (int)FileSize(file);
        uchar photo[];
        ArrayResize(photo, file_size);
        FileReadArray(file, photo, 0, file_size);
        FileClose(file);

        //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
        uchar base64[];
        uchar key[];
        CryptEncode(CRYPT_BASE64, photo, key, base64);
        //---
        uchar temp[1024] = {0};
        ArrayCopy(temp, base64, 0, 0, 1024);
        //---
        uchar md5[];
        CryptEncode(CRYPT_HASH_MD5, temp, key, md5);
        //---
        string hash  = NULL;
        int    total = ArraySize(md5);
        for (int i = 0; i < total; i++)
            hash += StringFormat("%02X", md5[i]);
        hash = StringSubstr(hash, 0, 16);

        //--- WebRequest
        uchar  result[];
        string result_headers;

        string url = StringFormat("%s/bot%s/sendPhoto", TELEGRAM_BASE_URL, m_token);

        //--- 1
        uchar data[];

        //--- add chart_id
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, "--" + hash + "\r\n");
        ArrayAdd(data, "Content-Disposition: form-data; name=\"chat_id\"\r\n");
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, name);
        ArrayAdd(data, "\r\n");

        if (StringLen(_caption) > 0) {
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
        int    res     = WebRequest("POST", url, headers, _timeout, data, result, result_headers);
        if (res == 200) // OK
        {
            //--- delete BOM
            int start_index = 0;
            int size        = ArraySize(result);
            for (int i = 0; i < fmin(size, 8); i++) {
                if (result[i] == 0xef || result[i] == 0xbb || result[i] == 0xbf)
                    start_index = i + 1;
                else
                    break;
            }

            //---
            string out = CharArrayToString(result, start_index, WHOLE_ARRAY, CP_UTF8);

            //--- parse result
            CJAVal js(NULL, jtUNDEF);
            bool   done = js.Deserialize(out);
            if (!done) return (ERR_JSON_PARSING);

            //--- get error description
            bool ok = js["ok"].ToBool();
            if (!ok) return (ERR_JSON_NOT_OK);

            total = ArraySize(js["result"]["photo"].m_e);
            for (int i = 0; i < total; i++) {
                CJAVal image = js["result"]["photo"].m_e[i];

                long image_size = image["file_size"].ToInt();
                if (image_size <= file_size) _photo_id = image["file_id"].ToStr();
            }

            return (0);
        } else {
            if (res == -1) {
                string out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                // Print(out);
                return (_LastError);
            } else {
                if (res >= 100 && res <= 511) {
                    string out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                    // Print(out);
                    return (ERR_HTTP_ERROR_FIRST + res);
                }
                return (res);
            }
        }
        //---
        return (0);
    }

    //+------------------------------------------------------------------+
    int SendPhoto(string &_photo_id, const long _chat_id, const string _local_path, const string _caption = NULL, const bool _common_flag = false, const int _timeout = 10000)
    {
        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);

        ResetLastError();
        //--- copy file to memory buffer
        if (!FileIsExist(_local_path, _common_flag)) return (ERR_FILE_NOT_EXIST);

        //---
        int flags = FILE_READ | FILE_BIN | FILE_SHARE_WRITE | FILE_SHARE_READ;
        if (_common_flag) flags |= FILE_COMMON;

        //---
        int file = FileOpen(_local_path, flags);
        if (file < 0) return (_LastError);

        //---
        int   file_size = (int)FileSize(file);
        uchar photo[];
        ArrayResize(photo, file_size);
        FileReadArray(file, photo, 0, file_size);
        FileClose(file);

        //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
        uchar base64[];
        uchar key[];
        CryptEncode(CRYPT_BASE64, photo, key, base64);
        //---
        uchar temp[1024] = {0};
        ArrayCopy(temp, base64, 0, 0, 1024);
        //---
        uchar md5[];
        CryptEncode(CRYPT_HASH_MD5, temp, key, md5);
        //---
        string hash  = NULL;
        int    total = ArraySize(md5);
        for (int i = 0; i < total; i++)
            hash += StringFormat("%02X", md5[i]);
        hash = StringSubstr(hash, 0, 16);

        //--- WebRequest
        uchar  result[];
        string result_headers;

        string url = StringFormat("%s/bot%s/sendPhoto", TELEGRAM_BASE_URL, m_token);

        //--- 1
        uchar data[];

        //--- add chart_id
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, "--" + hash + "\r\n");
        ArrayAdd(data, "Content-Disposition: form-data; name=\"chat_id\"\r\n");
        ArrayAdd(data, "\r\n");
        ArrayAdd(data, IntegerToString(_chat_id));
        ArrayAdd(data, "\r\n");

        if (StringLen(_caption) > 0) {
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
        int    res     = WebRequest("POST", url, headers, _timeout, data, result, result_headers);
        if (res == 200) // OK
        {
            //--- delete BOM
            int start_index = 0;
            int size        = ArraySize(result);
            for (int i = 0; i < fmin(size, 8); i++) {
                if (result[i] == 0xef || result[i] == 0xbb || result[i] == 0xbf)
                    start_index = i + 1;
                else
                    break;
            }

            //---
            string out = CharArrayToString(result, start_index, WHOLE_ARRAY, CP_UTF8);

            //--- parse result
            CJAVal js(NULL, jtUNDEF);
            bool   done = js.Deserialize(out);
            if (!done) return (ERR_JSON_PARSING);

            //--- get error description
            bool ok = js["ok"].ToBool();
            if (!ok) return (ERR_JSON_NOT_OK);

            total = ArraySize(js["result"]["photo"].m_e);
            for (int i = 0; i < total; i++) {
                CJAVal image = js["result"]["photo"].m_e[i];

                long image_size = image["file_size"].ToInt();
                if (image_size <= file_size) _photo_id = image["file_id"].ToStr();
            }

            return (0);
        } else {
            if (res == -1) {
                string out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                // Print(out);
                return (_LastError);
            } else {
                if (res >= 100 && res <= 511) {
                    string out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                    // Print(out);
                    return (ERR_HTTP_ERROR_FIRST + res);
                }
                return (res);
            }
        }
        //---
        return (0);
    }
    //+------------------------------------------------------------------+
    virtual void ProcessMessages(void){};

    //+------------------------------------------------------------------+
    int SendMessage(const long _chat_id, const string _text, const string _reply_markup = NULL, const bool _as_HTML = false, const bool _silently = false)
    {
        //--- check token
        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);

        string out;
        string url = StringFormat("%s/bot%s/sendMessage", TELEGRAM_BASE_URL, m_token);

        string params = StringFormat("chat_id=%lld&text=%s", _chat_id, UrlEncode(_text));
        if (_reply_markup != NULL) params += "&reply_markup=" + _reply_markup;
        if (_as_HTML) params += "&parse_mode=HTML";
        if (_silently) params += "&disable_notification=true";

        int res = PostRequest(out, url, params, WEB_TIMEOUT);
        return (res);
    }

    //+------------------------------------------------------------------+
    int SendMessage(const string _channel_name, const string _text, const bool _as_HTML = false, const bool _silently = false)
    {
        //--- check token
        if (m_token == NULL) return (ERR_TOKEN_ISEMPTY);

        string name = StringTrim(_channel_name);
        if (StringGetCharacter(name, 0) != '@') name = "@" + name;

        string out;
        string url    = StringFormat("%s/bot%s/sendMessage", TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("chat_id=%s&text=%s", name, UrlEncode(_text));
        if (_as_HTML) params += "&parse_mode=HTML";
        if (_silently) params += "&disable_notification=true";
        //      Print(params);
        int res = PostRequest(out, url, params, WEB_TIMEOUT);
        return (res);
    }

    //+------------------------------------------------------------------+
    string ReplyKeyboardMarkup(const string keyboard, const bool resize, const bool one_time)
    {
        string result = StringFormat("{\"keyboard\": %s, \"one_time_keyboard\": %s, \"resize_keyboard\": %s, \"selective\": false}", UrlEncode(keyboard), BoolToString(resize), BoolToString(one_time));
        return (result);
    }

    //+------------------------------------------------------------------+
    string ReplyKeyboardHide() { return ("{\"hide_keyboard\": true}"); }

    //+------------------------------------------------------------------+
    string ForceReply() { return ("{\"force_reply\": true}"); }
};
//+------------------------------------------------------------------+

#endif

CCustomBot bot;
bool       checked;
uint       pushdelay              = 0;
bool       telegram_runningstatus = false;

int    ordersize = 0;
int    orderids[];
double orderopenprice[];
double orderlot[];
double ordersl[];
double ordertp[];
bool   orderchanged           = false;
bool   orderpartiallyclosed   = false;
int    orderpartiallyclosedid = -1;

int prev_ordersize = 0;

//--- Globales File
string local_symbolallow[];
int    symbolallow_size = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
    // ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE, true); 
    
    // OnInit_CustomIndicator();

    if (!OnInit_GUI()) {
        return INIT_FAILED;
    }

    // if (DetectEnvironment() == false) {
    //     Alert("Error: The property is fail, please check and try again.");
    //     return INIT_FAILED;
    // }

    // StartTelegramServer();
    EventSetMillisecondTimer(250);
    
    GetCurrentOrdersOnStart();
    
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { 
    OnDeinit_GUI(reason); 
    StopTelegramServer(); 
}

bool copmod = false;
//+------------------------------------------------------------------+
//| Expert program start function                                    |
//+------------------------------------------------------------------+

void OnTick()  
{
    CheckIndicatorSignals();
    // if (DetectEnvironment() == false) {
    //     Alert("Error: The property is fail, please check and try again.");
    //     return;
    // }
    // StartTelegramServer();

}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    gui.ChartEvent(id, lparam, dparam, sparam);
    gui.HoverEvents(id, lparam, dparam, sparam);


    // if (id == CHARTEVENT_KEYDOWN && lparam == 'Q') {
    // bot.SendMessage(InpChannelName, "ee\nAt:100\nDDDD");
    // bot.SendMessage(chat_id, "ee\nAt:100\nDDDD");
    // }

}

void OnTimer(void) {
    if (DetectEnvironment() == false) {
        Alert("Error: The property is fail, please check and try again.");
        return;
    }
    StartTelegramServer();

    if(auto_noti_on) SendAutomaticNotifications();
}

//+------------------------------------------------------------------+
static datetime initial_tm;
datetime nextNotification;
void SendAutomaticNotifications()
{
    initial_tm = TimeCurrent();
    Print("line: ",__LINE__," initial_tm: ",initial_tm);
    
    if (TimeCurrent() > nextNotification)
    {
        OnClickSendTelegram();
        nextNotification = TimeCurrent() + (60 * minutes);
        Print("line: ",__LINE__," nextNotification: ",nextNotification);
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DetectEnvironment()
{

    pushdelay              = (ServerDelayMilliseconds > 0) ? ServerDelayMilliseconds : 10;
    telegram_runningstatus = false;

    // Load the Symbol allow map
    if (AllowSymbols != "") {
        string symboldata[];
        int    symbolsize  = StringSplit(AllowSymbols, ',', symboldata);
        int    symbolindex = 0;

        ArrayResize(local_symbolallow, symbolsize);

        for (symbolindex = 0; symbolindex < symbolsize; symbolindex++) {
            if (symboldata[symbolindex] == "") continue;

            local_symbolallow[symbolindex] = symboldata[symbolindex];
        }

        symbolallow_size = symbolsize;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Start the Telegram server                                        |
//+------------------------------------------------------------------+
int StartTelegramServer()
{

    bot.Token(InpToken);
    if (!checked) {
        if (StringLen(InpChannelName) == 0) {
            Print("Error: Channel name is empty");
            Sleep(2000);
            return (0);
        }

        int result = bot.GetMe();
        if (result == 0) {
            Print("Bot name: ", bot.Name());
            checked = true;
        } else {
            Print("Error: ", GetErrorDescription(result));
            Sleep(2000);
            return (0);
        }
    }

    // GetCurrentOrdersOnStart();

    int  changed     = 0;
    uint delay       = pushdelay;
    uint ticketstart = 0;
    uint tickcount   = 0;

    telegram_runningstatus = true;
    
    // while(!IsStopped()) {
        ticketstart = GetTickCount();
        changed     = GetCurrentOrdersOnTicket();

        if (changed > 0) UpdateCurrentOrdersOnTicket();

        tickcount = GetTickCount() - ticketstart;
    // }
        if (delay > tickcount) Sleep(delay - tickcount - 2);

    return (0);
}

//+------------------------------------------------------------------+
//| Stop the Telegram server                                         |
//+------------------------------------------------------------------+
void StopTelegramServer()
{

    ArrayFree(orderids);
    ArrayFree(orderopenprice);
    ArrayFree(orderlot);
    ArrayFree(ordersl);
    ArrayFree(ordertp);
    ArrayFree(local_symbolallow);

    telegram_runningstatus = false;
}

//+------------------------------------------------------------------+
//| Get all of the orders                                            |
//+------------------------------------------------------------------+
void GetCurrentOrdersOnStart()
{
    prev_ordersize = 0;
    ordersize      = OrdersTotal();

    if (ordersize == prev_ordersize) return;

    if (ordersize > 0) {
        ArrayResize(orderids, ordersize);
        ArrayResize(orderopenprice, ordersize);
        ArrayResize(orderlot, ordersize);
        ArrayResize(ordersl, ordersize);
        ArrayResize(ordertp, ordersize);
    }

    prev_ordersize = ordersize;

    int orderindex = 0;

    // Save the orders to cache
    for (orderindex = 0; orderindex < ordersize; orderindex++) {
        if (OrderSelect(orderindex, SELECT_BY_POS, MODE_TRADES) == false) continue;

        orderids[orderindex]       = OrderTicket();
        orderopenprice[orderindex] = OrderOpenPrice();
        orderlot[orderindex]       = OrderLots();
        ordersl[orderindex]        = OrderStopLoss();
        ordertp[orderindex]        = OrderTakeProfit();
    }
}

//+------------------------------------------------------------------+
//| Get all of the orders                                            |
//+------------------------------------------------------------------+
int GetCurrentOrdersOnTicket()
{
    ordersize = OrdersTotal();

    int changed = 0;

    if (ordersize > prev_ordersize) {
        // Trade has been added
        changed = PushOrderOpen();
    } else if (ordersize < prev_ordersize) {
        // Trade has been closed
        changed = PushOrderClosed();
    } else if (ordersize == prev_ordersize) {
        // Trade has been modify
        changed = PushOrderModify();
    }

    return changed;
}

//+------------------------------------------------------------------+
//| Update all of the orders status                                  |
//+------------------------------------------------------------------+
void UpdateCurrentOrdersOnTicket()
{
    if (ordersize > 0) {
        ArrayResize(orderids, ordersize);
        ArrayResize(orderopenprice, ordersize);
        ArrayResize(orderlot, ordersize);
        ArrayResize(ordersl, ordersize);
        ArrayResize(ordertp, ordersize);
    }

    int orderindex = 0;

    // Save the orders to cache
    for (orderindex = 0; orderindex < ordersize; orderindex++) {
        if (OrderSelect(orderindex, SELECT_BY_POS, MODE_TRADES) == false) continue;

        orderids[orderindex]       = OrderTicket();
        orderopenprice[orderindex] = OrderOpenPrice();
        orderlot[orderindex]       = OrderLots();
        ordersl[orderindex]        = OrderStopLoss();
        ordertp[orderindex]        = OrderTakeProfit();
    }

    // Changed the old orders count as current orders count
    prev_ordersize = ordersize;
}

//+------------------------------------------------------------------+
//| Push the open order to all of the subscriber                     |
//+------------------------------------------------------------------+
int PushOrderOpen()
{
    int    changed    = 0;
    int    orderindex = 0;
    string message    = "";
    for (orderindex = 0; orderindex < ordersize; orderindex++) {
        if (OrderSelect(orderindex, SELECT_BY_POS, MODE_TRADES) == false) continue;

        if (FindOrderInPrevPool(OrderTicket()) == false) {
            if (GetOrderSymbolAllowed(OrderSymbol()) == false) continue;

            Print("Order Added:", OrderSymbol(), ", Size:", ArraySize(orderids), ", OrderId:", OrderTicket());
            if (UseFormat_forCopier == false) {
                message = StringFormat("Name: %s\nSymbol: %s\nType: %s\nAction: %s\nPrice: %s\nTime: %s\nLots: %s\nTakeProfit: %s\nStopLoss: %s", mySigalname, OrderSymbol(), TypeMnem(OrderType()),
                                       "OPEN", DoubleToString(OrderOpenPrice(), MarketInfo(OrderSymbol(), MODE_DIGITS)), TimeToString(OrderOpenTime()), DoubleToString(OrderLots(), 2),
                                       DoubleToString(OrderTakeProfit(), MarketInfo(OrderSymbol(), MODE_DIGITS)), DoubleToString(OrderStopLoss(), MarketInfo(OrderSymbol(), MODE_DIGITS)));
            }

            if (UseFormat_forCopier == true) {
                message = StringFormat(" \nAssetname: %s\nType: %s\nStopLoss: %s\nTakeProfit: %s\nLots: %s\nComment: %s", OrderSymbol(), TypeMnem(OrderType()),
                                       DoubleToString(OrderStopLoss(), MarketInfo(OrderSymbol(), MODE_DIGITS)), DoubleToString(OrderTakeProfit(), MarketInfo(OrderSymbol(), MODE_DIGITS)),
                                       DoubleToString(OrderLots(), 2), mySigalname

                );
            }

            PushToSubscriber(OrderSymbol(), message);

            changed++;
        }
    }

    return changed;
}

//+------------------------------------------------------------------+
//| Push the close order to all of the subscriber                    |
//+------------------------------------------------------------------+
int PushOrderClosed()
{
    int      changed    = 0;
    int      orderindex = 0;
    datetime ctm;
    string   message;

    for (orderindex = 0; orderindex < prev_ordersize; orderindex++) {
        if (OrderSelect(orderids[orderindex], SELECT_BY_TICKET, MODE_TRADES) == false) continue;

        ctm = OrderCloseTime();

        if (ctm > 0) {
            if (GetOrderSymbolAllowed(OrderSymbol()) == false) continue;

            Print("Order Closed:", OrderSymbol(), ", Size:", ArraySize(orderids), ", OrderId:", OrderTicket());
            message = StringFormat("Name: %s\nSymbol: %s\nType: %s\nAction: %s\nPrice: %s\nTime: %s\nLots: %s\nTakeProfit: %s\nStopLoss: %s", mySigalname, OrderSymbol(), TypeMnem(OrderType()),
                                   "CLOSED", DoubleToString(OrderClosePrice(), MarketInfo(OrderSymbol(), MODE_DIGITS)), TimeToString(OrderCloseTime()), DoubleToString(OrderLots(), 2),
                                   DoubleToString(OrderTakeProfit(), MarketInfo(OrderSymbol(), MODE_DIGITS)), DoubleToString(OrderStopLoss(), MarketInfo(OrderSymbol(), MODE_DIGITS)));
            PushToSubscriber(OrderSymbol(), message);

            changed++;
        }
    }

    return changed;
}

//+------------------------------------------------------------------+
//| Push the modify order to all of the subscriber                   |
//+------------------------------------------------------------------+
int PushOrderModify()
{
    int    changed    = 0;
    int    orderindex = 0;
    string message;
    for (orderindex = 0; orderindex < ordersize; orderindex++) {
        orderchanged           = false;
        orderpartiallyclosed   = false;
        orderpartiallyclosedid = -1;

        if (OrderSelect(orderindex, SELECT_BY_POS, MODE_TRADES) == false) continue;

        if (GetOrderSymbolAllowed(OrderSymbol()) == false) continue;

        if (orderlot[orderindex] != OrderLots()) {
            orderchanged = true;

            string ordercomment = OrderComment();
            int    orderid      = 0;

            // Partially closed a trade
            // Partially closed is a different lots from trade
            if (StringFind(ordercomment, "from #", 0) >= 0) {
                if (StringReplace(ordercomment, "from #", "") >= 0) {
                    orderpartiallyclosed   = true;
                    orderpartiallyclosedid = StringToInteger(ordercomment);
                }
            }
        }

        if (ordersl[orderindex] != OrderStopLoss()) orderchanged = true;

        if (ordertp[orderindex] != OrderTakeProfit()) orderchanged = true;

        // Temporarily method for recognize modify order or part-closed order
        // Part-close order will close order by a litte lots and re-generate an new order with new order id
        if (orderchanged == true) {
            if (orderpartiallyclosed == true) {
                Print("Partially Closed:", OrderSymbol(), ", Size:", ArraySize(orderids), ", OrderId:", OrderTicket(), ", Before OrderId: ", orderpartiallyclosedid);
                message = StringFormat("Name: %s\nSymbol: %s\nType: %s\nAction: %s\nPrice: %s\nTime: %s\nLots: %s\nTakeProfit: %s\nStopLoss: %s", mySigalname, OrderSymbol(), TypeMnem(OrderType()),
                                       "Partially Closed", DoubleToString(OrderOpenPrice(), MarketInfo(OrderSymbol(), MODE_DIGITS)), TimeToString(TimeCurrent()), DoubleToString(OrderLots(), 2),
                                       DoubleToString(OrderTakeProfit(), MarketInfo(OrderSymbol(), MODE_DIGITS)), DoubleToString(OrderStopLoss(), MarketInfo(OrderSymbol(), MODE_DIGITS)));
                PushToSubscriber(OrderSymbol(), message);
            } else {
                Print("Order Modify:", OrderSymbol(), ", Size:", ArraySize(orderids), ", OrderId:", OrderTicket());
                message = StringFormat("Name: %s\nSymbol: %s\nType: %s\nAction: %s\nPrice: %s\nTime: %s\nLots: %s\nTakeProfit: %s\nStopLoss: %s", mySigalname, OrderSymbol(), TypeMnem(OrderType()),
                                       "Order Modified", DoubleToString(OrderOpenPrice(), MarketInfo(OrderSymbol(), MODE_DIGITS)), TimeToString(TimeCurrent()), DoubleToString(OrderLots(), 2),
                                       DoubleToString(OrderTakeProfit(), MarketInfo(OrderSymbol(), MODE_DIGITS)), DoubleToString(OrderStopLoss(), MarketInfo(OrderSymbol(), MODE_DIGITS)));
                PushToSubscriber(OrderSymbol(), message);
            }

            changed++;
        }
    }

    return changed;
}

//+------------------------------------------------------------------+
//| Push the message                                                  |
//+------------------------------------------------------------------+
void PushToSubscriber(const string symbl, string message)
{
    if (message == "") return;
    
    if(uMsg!="")
    {
        message += "\n"+uMsg;
    }

    if (MobileNotification) {
        SendNotification(message);
    }
    if (EmailNotification) {
        SendMail("Order Notification", message);
    }
    if (AlertonTelegram) {
        //  bot.SendMessage(InpChannelName,message);
    }

    if (SendScreenShot) {
        if (StringFind(symbl, "null") != -1) return;
        sendSnapShots(symbl, ScreenShotTimeFrame, message);
    }

    if (SendScreenShot == false) {
        if (sendMode == byName) {
            bot.SendMessage(InpChannelName, message);
        } else if (sendMode == byId) {
            bot.SendMessage(chat_id, message);
        }
    }
}

//+------------------------------------------------------------------+
//| Get the symbol allowd on trading                                 |
//+------------------------------------------------------------------+
bool GetOrderSymbolAllowed(const string symbol)
{
    bool result = true;

    if (symbolallow_size == 0) return result;

    // Change result as FALSE when allow list is not empty
    result = false;

    int symbolindex = 0;

    for (symbolindex = 0; symbolindex < symbolallow_size; symbolindex++) {
        if (local_symbolallow[symbolindex] == "") continue;

        if (symbol == local_symbolallow[symbolindex]) {
            result = true;

            break;
        }
    }

    return result;
}

//+------------------------------------------------------------------+
//| Find a order by ticket id                                        |
//+------------------------------------------------------------------+
bool FindOrderInPrevPool(const int order_ticketid)
{
    int orderfound = 0;
    int orderindex = 0;

    if (prev_ordersize == 0) return false;

    for (orderindex = 0; orderindex < prev_ordersize; orderindex++) {
        if (order_ticketid == orderids[orderindex]) orderfound++;
    }

    return (orderfound > 0) ? true : false;
}

int sendSnapShots(string thesymbol, ENUM_TIMEFRAMES _period, string message)
{

    int  result   = 0;
    long chart_id = ChartOpen(thesymbol, _period);
    // if(chart_id==0)
    //    return(ERR_CHART_NOT_FOUND);

    ChartSetInteger(ChartID(), CHART_BRING_TO_TOP, true);

    //--- updates chart
    // int wait = 5;
    // while (--wait > 0) {
    //     if (SeriesInfoInteger(thesymbol, _period, SERIES_SYNCHRONIZED)) break;
    //     Sleep(500);
    // }

    if (_template != "") {
        ChartApplyTemplate(chart_id, _template);
        //    PrintError(_LastError,InpLanguage);
        //  ChartApplyTemplate(chart_id,_template);
    }
    ChartRedraw(chart_id);
    Sleep(500);

    ChartSetInteger(chart_id, CHART_SHOW_GRID, false);

    ChartSetInteger(chart_id, CHART_SHOW_PERIOD_SEP, false);

    // string filename = StringFormat("%s%d.gif", thesymbol, _period);
    string filename = StringFormat("%s%d.png", thesymbol, _period);

    if (FileIsExist(filename)) FileDelete(filename);
    ChartRedraw(chart_id);

    Sleep(100);

    if (ChartScreenShot(chart_id, filename, 800, 600, ALIGN_RIGHT)) {
        Sleep(500);

        //--- waitng 30 sec for save screenshot
        int wait = 5;
        while (!FileIsExist(filename) && --wait > 0)
            Sleep(500);

        //---
        if (FileIsExist(filename)) {
            string screen_id;

            // Mark: send
            if (sendMode == byName) {
                result = bot.SendPhoto(screen_id, InpChannelName, filename, thesymbol + message);
            } else if (sendMode == byId) {
                result = bot.SendPhoto(screen_id, chat_id, filename, thesymbol + message);
            }
        }
    }

    ChartClose(chart_id);

    return result;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TypeMnem(int type)
{
    switch (type) {
    case OP_BUY:
        return ("buy");
    case OP_SELL:
        return ("sell");
    case OP_BUYLIMIT:
        return ("buy limit");
    case OP_SELLLIMIT:
        return ("sell limit");
    case OP_BUYSTOP:
        return ("buy stop");
    case OP_SELLSTOP:
        return ("sell stop");
    default:
        return ("???");
    }
}


void OnClickSendTelegram()
{
    string ms = uMsg == "" ? "\n " : uMsg;
    PushToSubscriber(Symbol(), ms);
}

// Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159871#p159871

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