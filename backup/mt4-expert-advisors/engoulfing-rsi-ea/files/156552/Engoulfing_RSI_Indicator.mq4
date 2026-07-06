// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75173

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
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

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------

input string T0                    = "== Break Setup ==";   // Break Setup
input int    nCandles              = 2;                     // Maximum candle to break previous:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
// ------------------------------------------------------------------
class CCandle
{
    int    _timeFrame;
    string _symbol;
    double _open;
    double _high;
    double _low;
    double _close;
    float  _size;
    string _type;
    string _direction;
    float  _bodySize;
    float  _shadowSup;
    float  _shadowInf;

  public:
    CCandle() { ; }
    CCandle(string sym, int tf) : _symbol(sym), _timeFrame(tf) {}
    ~CCandle() { ; }

    // Getters
    float  Size(void) { return _size; }
    string Type(void) { return _type; }
    double Open(void) { return _open; }
    double High(void) { return _high; }
    double Low(void) { return _low; }
    double Close(void) { return _close; }
    string Direction(void) { return _direction; }
    float  BodySize(void) { return _bodySize; }
    float  ShadowSup(void) { return _shadowSup; }
    float  ShadowInf(void) { return _shadowInf; }

    void setCandle(int shift = 1)
    {
        _open  = iOpen(_symbol, _timeFrame, shift);
        _high  = iHigh(_symbol, _timeFrame, shift);
        _low   = iLow(_symbol, _timeFrame, shift);
        _close = iClose(_symbol, _timeFrame, shift);

        setDirection();
        setSize();
        setBodySize();
        setShadows();
    }
    void setSize()
    {
        _size = 1;
        if (Distance(_high, _low, _symbol) > 0) {
            _size = Distance(_high, _low, _symbol);
        }
    }
    void setBodySize()
    {
        _bodySize = 1;
        if (Distance(_open, _close, _symbol) > 0) {
            _bodySize = Distance(_open, _close, _symbol);
        }
    }
    void setDirection()
    {
        if (_open < _close) {
            _direction = "up";
        }
        if (_open > _close) {
            _direction = "down";
        }
        if (_open == _close) {
            _direction = "null";
        }
    }
    void PrintCandle()
    {
        Print(__FUNCTION__, " ", "symbol", " ", _symbol);
        Print(__FUNCTION__, " ", "open", " ", _open);
        Print(__FUNCTION__, " ", "high", " ", _high);
        Print(__FUNCTION__, " ", "low", " ", _low);
        Print(__FUNCTION__, " ", "close", " ", _close);
        Print(__FUNCTION__, " ", "_size;", " ", _size);
        Print(__FUNCTION__, " ", "_type;", " ", _type);
        Print(__FUNCTION__, " ", "_direction;", " ", _direction);
        Print(__FUNCTION__, " ", "_bodySize;", " ", _bodySize);
        Print(__FUNCTION__, " ", "_shadowSup;", " ", _shadowSup);
        Print(__FUNCTION__, " ", "_shadowInf;", " ", _shadowInf);
    }
    void setShadows()
    {
        if (Direction() == "up") {
            _shadowInf = Distance(_open, _low, _symbol);
            _shadowSup = Distance(_close, _high, _symbol);
        }
        if (Direction() == "down") {
            _shadowInf = Distance(_close, _low, _symbol);
            _shadowSup = Distance(_open, _high, _symbol);
        }
        if (Direction() == "null") {
            _shadowInf = Distance(_close, _low, _symbol);
            _shadowSup = Distance(_open, _high, _symbol);
        }
    }
    float Distance(double precioA, double precioB, string par)
    {
        double mPoint     = MarketInfo(par, MODE_POINT);
        double dist       = fabs(precioA - precioB);
        double distReturn = 0;
        if (mPoint > 0) distReturn = dist / mPoint;
        return distReturn;
    }
};
CCandle candle1();
CCandle candle2();

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

input string trsi        = "== RSI Setup =="; // ————————————————————————
input int    rsi_periods = 14;                // RSI periods:
input double ob_level    = 65;                // Overbougth:
input double os_level    = 35;                // Oversold:

class ConditionRsiOverbougth
{
  public:
    bool evaluate() { return iRSI(NULL, 0, rsi_periods, PRICE_CLOSE, 1) > ob_level; }
};
ConditionRsiOverbougth cdRsiOverbougth;

class ConditionRsiOversold
{
  public:
    bool evaluate() { return iRSI(NULL, 0, rsi_periods, PRICE_CLOSE, 1) < os_level; }
};
ConditionRsiOversold cdRsiOversold;

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    //---
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int i = rates_total - prev_calculated + 1;
    if (i >= rates_total) i = rates_total - 1;
    for (; i > 0; i--) {
        //  setCandles(i, j);
        if (iRSI(NULL, 0, rsi_periods, PRICE_CLOSE, i) < os_level) {
            if (EngoulfingUp(i)) {
                ArrowUp[i] = Low[i];
                if (newCandle.IsNewCandle()) {
                    Notifications(0);
                }
            }
        }

        if (iRSI(NULL, 0, rsi_periods, PRICE_CLOSE, i) > ob_level) {
            if (EngoulfingDown(i)) {
                ArrowDn[i] = High[i];
                if (newCandle.IsNewCandle()) {
                    Notifications(1);
                }
            }
        }
    }

    return (rates_total);
}

// ------------------------------------------------------------------
void setCandles(int i, int shift)
{
    candle1.setCandle(i + shift);
    candle2.setCandle(i);
}

bool EngoulfingUp(int i)
{
    // double sum = 0;
    // for (int j = 0; j < 15; j++) {
    //     sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    // }
    // double avSize = sum / 15;

    // TODO: signal up
    double op2 = iOpen(NULL, 0, i + 2);
    double hi2 = iHigh(NULL, 0, i + 2);
    double lo2 = iLow(NULL, 0, i + 2);
    double cl2 = iClose(NULL, 0, i + 2);
    double op1 = iOpen(NULL, 0, i + 1);
    double hi1 = iHigh(NULL, 0, i + 1);
    double lo1 = iLow(NULL, 0, i + 1);
    double cl1 = iClose(NULL, 0, i + 1);

    // if (fabs(cl1 - op1) < avSize) return false;

    double size2 = fabs(op2 - cl2);
    double size1 = fabs(op1 - cl1);

    // if (size2 == 0) return false;
    // double proportion = size1 / size2;
    // if (proportion < 0.7 || proportion > 2) return false;

    // return (cl3 < op3 && cl2 < op3 && cl1 > op1 && cl1 > op2 && op1 > lo2 && lo2 < cl3 && cl1 > ( cl3 + size3 * 0.80));
    return (cl2 < op2 && cl1 > op1 && op1 > lo2 && cl1 > (cl2 + size2 * 0.80));
}

bool EngoulfingDown(int i)
{
    // TODO: signal down
    // double sum = 0;
    // for (int j = 0; j < 15; j++) {
    //     sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    // }
    // double avSize = sum / 15;

    double op2 = iOpen(NULL, 0, i + 2);
    double hi2 = iHigh(NULL, 0, i + 2);
    double lo2 = iLow(NULL, 0, i + 2);
    double cl2 = iClose(NULL, 0, i + 2);
    double op1 = iOpen(NULL, 0, i + 1);
    double hi1 = iHigh(NULL, 0, i + 1);
    double lo1 = iLow(NULL, 0, i + 1);
    double cl1 = iClose(NULL, 0, i + 1);

    // if (fabs(cl1 - op1) < avSize) return false;

    double size2 = fabs(cl2 - op2);
    double size1 = fabs(op1 - cl1);

    // if (size2 == 0) return false;
    // double proportion = size1 / size2;
    // if (proportion < 0.7 || proportion > 2) return false;

    // return (cl3 > op3 && cl2 > op3 && cl1 < op1 && cl1 < op2 && op1 < hi2 && hi2 > cl3 && cl1 < (cl3- size3 * 0.70));
    return (cl2 > op2 && cl1 < op1 && op1 < hi2 && cl1 < (cl2 - (size2 * 0.80)));
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
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
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