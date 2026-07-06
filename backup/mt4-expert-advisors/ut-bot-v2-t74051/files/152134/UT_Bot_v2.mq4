// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74051

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
#property link "http://fxcodebase.com"
#property version "1.1"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 8
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

#property indicator_label3 "Entry Level"
#property  indicator_type3  DRAW_LINE
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_DOT
#property indicator_width3 1

#property indicator_label4 "Stop Loss"
#property  indicator_type4  DRAW_LINE
#property indicator_color4 clrRed
#property indicator_style4 STYLE_DOT
#property indicator_width4 1

#property indicator_label5 "TP 1"
#property  indicator_type5  DRAW_LINE
#property indicator_color5 clrLime
#property indicator_style5 STYLE_DOT
#property indicator_width5 1
#property indicator_label6 "TP 2"
#property  indicator_type6  DRAW_LINE
#property indicator_color6 clrLime
#property indicator_style6 STYLE_DOT
#property indicator_width6 1
#property indicator_label7 "TP 3"
#property  indicator_type7  DRAW_LINE
#property indicator_color7 clrLime
#property indicator_style7 STYLE_DOT
#property indicator_width7 1



//--- indicator buffers
double ArrowUp [];
double ArrowDn [];
double xATRTrailingStop [];

double Entry [];
double SL [];
double TP1 [];
double TP2 [];
double TP3 [];

//--- variables
double nLoss, xATR;
//
enum candle
{
    curr = -1,  // Current candle
    prev = 0    // Previous closed candle
};
// ------------------------------------------------------------------
input double m = 2;      // Key value:
input double atrPeriods = 14;     // ATR periods:
input bool   h = false;  // Signals From Heinken Ashi Candles
input candle s = curr;       // Show arrows on:
input int p = 30;             // Arrow position in Points
input int b = 5000;               // Lookback bars

input string T0 = "== Draw Trade ==";  // ————————————
input bool drawTradeON = true; // Draw Trade On?
input double userSL = 20; // Pips SL
input double userTP1 = 50; // Pips TP1
input double userTP2 = 75; // Pips TP2
input double userTP3 = 100; // Pips TP3


input string T1 = "== Notifications ==";  // ————————————
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
input string T2 = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrNavy;                // Arrow Up Color:
input color  ArrowDnClr = clrCrimson;                 // Arrow Down Color:
// ------------------------------------------------------------------
class CCandle
{
    int               _timeFrame;
    string            _symbol;
    double            _open;
    double            _high;
    double            _low;
    double            _close;
    float             _size;
    string            _type;
    string            _direction;
    float             _bodySize;
    float             _shadowSup;
    float             _shadowInf;

    public:
    CCandle() { ; }
    CCandle(string sym, int tf) : _symbol(sym), _timeFrame(tf) {}
    ~CCandle() { ; }

    // Getters
    float             Size(void) { return _size; }
    string            Type(void) { return _type; }
    double            Open(void) { return _open; }
    double            High(void) { return _high; }
    double            Low(void) { return _low; }
    double            Close(void) { return _close; }
    string            Direction(void) { return _direction; }
    float             BodySize(void) { return _bodySize; }
    float             ShadowSup(void) { return _shadowSup; }
    float             ShadowInf(void) { return _shadowInf; }

    void              setCandle(int shift = 1)
    {
        _open = iOpen(_symbol, _timeFrame, shift);
        _high = iHigh(_symbol, _timeFrame, shift);
        _low = iLow(_symbol, _timeFrame, shift);
        _close = iClose(_symbol, _timeFrame, shift);
        setDirection();
        setSize();
        setBodySize();
        setShadows();
    }
    void              setSize()
    {
        _size = 1;
        if(Distance(_high, _low, _symbol) > 0)
        {
            _size = Distance(_high, _low, _symbol);
        }
    }
    void              setBodySize()
    {
        _bodySize = 1;
        if(Distance(_open, _close, _symbol) > 0)
        {
            _bodySize = Distance(_open, _close, _symbol);
        }
    }
    void              setDirection()
    {
        if(_open < _close)
        {
            _direction = "up";
        }
        if(_open > _close)
        {
            _direction = "down";
        }
        if(_open == _close)
        {
            _direction = "null";
        }
    }
    void              PrintCandle()
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
    void              setShadows()
    {
        if(Direction() == "up")
        {
            _shadowInf = Distance(_open, _low, _symbol);
            _shadowSup = Distance(_close, _high, _symbol);
        }
        if(Direction() == "down")
        {
            _shadowInf = Distance(_close, _low, _symbol);
            _shadowSup = Distance(_open, _high, _symbol);
        }
        if(Direction() == "null")
        {
            _shadowInf = Distance(_close, _low, _symbol);
            _shadowSup = Distance(_open, _high, _symbol);
        }
    }
    float             Distance(double precioA, double precioB, string par)
    {
        double mPoint = MarketInfo(par, MODE_POINT);
        double dist = fabs(precioA - precioB);
        double distReturn = 0;
        if(mPoint > 0)
            distReturn = dist / mPoint;
        return distReturn;
    }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCandle candle1();
CCandle candle2();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNewCandle
{
    private:
    int               _initialCandles;
    string            _symbol;
    int               _tf;

    public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
    CNewCandle()
    {
        // toma los valores del chart actual
        _initialCandles = iBars(Symbol(), Period());
        _symbol = Symbol();
        _tf = Period();
    }
    ~CNewCandle() { ; }

    bool              IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if(_currentCandles > _initialCandles)
        {
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
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexArrow(1, 234);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);


    SetIndexBuffer(2, Entry, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, EMPTY, 1, clrBlue);
    SetIndexBuffer(3, SL, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_LINE, EMPTY, 1, clrRed);
    SetIndexBuffer(4, TP1, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_LINE, EMPTY, 1, clrLime);
    SetIndexBuffer(5, TP2, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_LINE, EMPTY, 1, clrLime);
    SetIndexBuffer(6, TP3, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_LINE, EMPTY, 1, clrLime);

    SetIndexBuffer(7, xATRTrailingStop);
    SetIndexStyle(7, DRAW_NONE);

    if(!ArrowsOn)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    if(!drawTradeON)
    {
        SetIndexStyle(2, DRAW_NONE);
        SetIndexStyle(3, DRAW_NONE);
        SetIndexStyle(4, DRAW_NONE);
        SetIndexStyle(5, DRAW_NONE);
        SetIndexStyle(6, DRAW_NONE);
    }
    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{
    int i = iBars(NULL, 0) / 2;
    if(i >= rates_total) i = rates_total - 1;
    i = MathMin(i, b);

    for(; i > 0; i--)
    {
        xATR = iATR(NULL, 0, atrPeriods, i);
        nLoss = m * xATR;
        double cl = close[i];
        double cl1 = close[i + 1];
        xATRTrailingStop[i] = cl > xATRTrailingStop[i + 1] && cl1 > xATRTrailingStop[i + 1] ? fmax(xATRTrailingStop[i + 1], cl - nLoss) :
            cl < xATRTrailingStop[i + 1] && cl1 < xATRTrailingStop[i + 1] ? fmin(xATRTrailingStop[i + 1], cl + nLoss) :
            cl > xATRTrailingStop[i + 1] ? cl - nLoss : cl + nLoss;
        bool crossUp = cl > xATRTrailingStop[i] && cl1 < xATRTrailingStop[i + 1];
        bool crossDn = cl < xATRTrailingStop[i] && cl1 > xATRTrailingStop[i + 1];

        if(cl > xATRTrailingStop[i] && crossUp == true)
        {
            ArrowUp[i + s] = low[i + s] - p * Point;

            // NOTE: draw Trade buy
            // ------------------------------------------------------------------
            for(int j = i - 2; j < i + 5;j++)
            {
                Entry[j] = Close[i + s];
                SL[j] = Close[i + s] - userSL * Point * 10;
                TP1[j] = Close[i + s] + userTP1 * Point * 10;
                TP2[j] = Close[i + s] + userTP2 * Point * 10;
                TP3[j] = Close[i + s] + userTP3 * Point * 10;

                if(ArrowDn[j+1]!= EMPTY_VALUE)
                {
                    Entry[j + 1] = EMPTY_VALUE;
                    SL[j + 1] = EMPTY_VALUE;
                    TP1[j + 1] = EMPTY_VALUE;
                    TP2[j + 1] = EMPTY_VALUE;
                    TP3[j + 1] = EMPTY_VALUE;
                    break;
                }
            }

        }
        if(cl < xATRTrailingStop[i] && crossDn == true)
        {
            ArrowDn[i + s] = high[i + s] + p * Point;

            // NOTE: draw Trade sell
            // ------------------------------------------------------------------
            for(int j = i - 1; j < i + 5;j++)
            {
                Entry[j] = Close[i + s];
                SL[j] = Close[i + s] + userSL * Point * 10;
                TP1[j] = Close[i + s] - userTP1 * Point * 10;
                TP2[j] = Close[i + s] - userTP2 * Point * 10;
                TP3[j] = Close[i + s] - userTP3 * Point * 10;

                if(ArrowUp[j+1]!= EMPTY_VALUE)
                {
                    Entry[j + 1] = EMPTY_VALUE;
                    SL[j + 1] = EMPTY_VALUE;
                    TP1[j + 1] = EMPTY_VALUE;
                    TP2[j + 1] = EMPTY_VALUE;
                    TP3[j + 1] = EMPTY_VALUE;
                    break;
                }
            }
        }
    }
    if(ArrowUp[1 + s] != EMPTY_VALUE && newCandle.IsNewCandle())
    {
        Notifications(0);
    }
    if(ArrowDn[1 + s] != EMPTY_VALUE && newCandle.IsNewCandle())
    {
        Notifications(1);
    }

    return (rates_total);
}

// ------------------------------------------------------------------
void setCandles(int i, int shift)
{
    candle1.setCandle(i + shift);
    candle2.setCandle(i);
}

// clang-format off
bool haveSignalUp(int i)
{
    // TODO: signal up
    // double cl =  iClose(NULL,0,i);
    // if(cl > xATRTrailingStop[i] )
    // {
    //   return true;
    // }
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool haveSignalDown(int i)
{
    // TODO: signal down
    // double cl =  iClose(NULL,0,i);
    // if(cl  < xATRTrailingStop[i] )
    // {
    //   return true;
    // }
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type)
{
    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";
    text += " ";
    if(!notifications)
        return;
    if(desktop_notifications)
        Alert(text);
    if(push_notifications)
        SendNotification(text);
    if(email_notifications)
        SendMail("MetaTrader Notification", text);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
