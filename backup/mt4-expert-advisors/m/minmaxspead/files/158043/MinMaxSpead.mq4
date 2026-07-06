//Available @  https://fxcodebase.com/code/viewtopic.php?f=27&p=157689#p157689

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
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

//--- indicator buffers
double LineUp[];
double LineDn[];
double maxSpreadToday[];
double minSpreadToday[];
// ------------------------------------------------------------------
int    periods               = 10;
string T1                    = "== Notifications =="; // === Notifications ===
bool   notifications         = false;                 // Notifications On?
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications
string T2                    = "== Set Lines ==";     // === Set  Lines ===
bool   LinesOn               = true;                  // Line On?
color  LineUpClr             = clrBlue;               // Line Up Color:
color  LineDnClr             = clrRed;                // Line Down Color:
// ------------------------------------------------------------------

class CNewCandle
{
  private:
    int    _initialCandles;
    string _symbol;
    int    _tf;

  public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
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

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_LINE, EMPTY, 1, LineUpClr);
    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineDnClr);
    SetIndexArrow(1, 234);

    SetIndexBuffer(2, maxSpreadToday, INDICATOR_CALCULATIONS);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexBuffer(3, minSpreadToday, INDICATOR_CALCULATIONS);
    SetIndexStyle(3, DRAW_NONE);

    if (!LinesOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    //---
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

double max = 0;
double min = 0;

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{

    int _spread = (int)MarketInfo(_Symbol, MODE_SPREAD);
    
    datetime tm = iTime(NULL, 0, 0);
    
    if (_spread > max) {
        max = _spread;
        DrawMax(Ask, tm);
    }
    if (_spread < min || min == 0) {
        min = _spread;
        DrawMin(Bid, tm);
    }

    return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    // TODO: signal up

    return true;
}

bool haveSignalDown(int i)
{
    // TODO: signal down

    return true;
}

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

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

bool DrawMax(double price, datetime time1)
{
    datetime time2 = iTime(NULL, PERIOD_D1, 0)+24*60*60;
    string name = "Max_Spread_"+time2;

    ObjectDelete(name);

    if (!ObjectCreate(0, name, OBJ_TREND, 0, time1, price, time2, price)) {
        Print(__FUNCTION__, ": failed to create a trend line! Error code = ", GetLastError());
        return (false);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, Blue);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
    
    return (true);
}
bool DrawMin(double price, datetime time1)
{
    datetime time2 = iTime(NULL, PERIOD_D1, 0)+24*60*60;
    string name = "Min_Spread_"+time2;
    
    ObjectDelete(name);

    if (!ObjectCreate(0, name, OBJ_TREND, 0, time1, price, time2, price)) {
        Print(__FUNCTION__, ": failed to create a trend line! Error code = ", GetLastError());
        return (false);
    }
    
    ObjectSetInteger(0, name, OBJPROP_COLOR, Red);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
    
    return (true);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=27&p=157689#p157689

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