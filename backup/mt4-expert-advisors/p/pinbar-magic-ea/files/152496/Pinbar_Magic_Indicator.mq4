// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74143

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
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 5

//--- indicator buffers
double SignalUp [];
double SignalDn [];
double PinbarUp [];
double PinbarDn [];
double LineMa1 [];
double LineMa2 [];
double LineMa3 [];

// ------------------------------------------------------------------
// input int    periods = 10;

input string       ma1title = "== Moving Average Fast ==";  // == Moving Average Setup ==
input int          ma1Period = 6;                            // Period
int                ma1Shift = 0;                             // Ma Shift
ENUM_MA_METHOD     ma1Method = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE ma1AppliedPrice = PRICE_CLOSE;                   // Applied Price
input string       ma2title = "== Moving Average Medium ==";  // == Moving Average Setup ==
input int          ma2Period = 18;                            // Period
int                ma2Shift = 0;                             // Ma Shift
ENUM_MA_METHOD     ma2Method = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE ma2AppliedPrice = PRICE_CLOSE;                   // Applied Price
input string       ma3title = "== Moving Average Slow ==";  // == Moving Average Setup ==
input int          ma3Period = 50;                            // Period
int                ma3Shift = 0;                             // Ma Shift
ENUM_MA_METHOD     ma3Method = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE ma3AppliedPrice = PRICE_CLOSE;                   // Applied Price

input string T1 = "== Notifications ==";  // === Notifications ===
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
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
        _symbol = Symbol();
        _tf = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
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

    void 	Set_Symbol_TF(string Symbol, int TimeFrame = 0)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
    }

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

MovingAverage* ma1;
MovingAverage* ma2;
MovingAverage* ma3;

class Pinbar
{
    string          _symbol;  // symbol
    ENUM_TIMEFRAMES _tf;      // timeframe

    public:
    Pinbar(string Symbol, ENUM_TIMEFRAMES TF)
    {
        _symbol = Symbol;
        _tf = TF;
    }
    ~Pinbar() { ; }

    double AverageSizeCandles(int pos)
    {
        double SumSize = 0;
        int length = 100;
        for(int i = pos; i < pos + length; i++)
        {
            double hi, lo, cl, op;
            hi = iHigh(_symbol, _tf, i);
            lo = iLow(_symbol, _tf, i);

            SumSize += fabs(hi - lo);
        }
        return SumSize / length;
    }

    string FindPattern(int pos)
    {

        string direction;
        string candle;

        for(int i = pos + 1; i <= pos + 1; i++)
        {
            bool   havePinbar = false;
            double hi, lo, cl, op;

            hi = iHigh(_symbol, _tf, i);
            lo = iLow(_symbol, _tf, i);
            op = iOpen(_symbol, _tf, i);
            cl = iClose(_symbol, _tf, i);

            // check patrón alcista:
            double body = fabs(op - cl);
            double size = fabs(hi - lo);
            double ratio = 0;

            if(size > 0) ratio = body / size;
            Print(__FUNCTION__, " ratio: ", ratio);

            // Tengo ratio
            if(ratio < 0.30)
            {
                double position = 0; //(op - lo) / size;
                if(size > 0)
                {
                    position = (op - lo) / size;
                    Print(__FUNCTION__, " position: ", position);
                }


                if(size > AverageSizeCandles(pos))
                {
                    if(position < 0.30) { direction = "q";havePinbar = true; }
                    if(position > 0.60) { direction = "p";havePinbar = true; }
                }
            }

            if(havePinbar)
            {
                candle = i < 10 ? "0" + (string) i : (string) i;
                return direction;
                // return candle + direction;
            }
        }

        return "000";
    }
};
Pinbar* pinbar;

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineMa1, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, Crimson);
    SetIndexLabel(0, "Ma Fast");

    SetIndexBuffer(1, LineMa2, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, Blue);
    SetIndexLabel(1, "Ma Medium");

    SetIndexBuffer(2, LineMa3, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, Green);
    SetIndexLabel(2, "Ma Slow");


    SetIndexBuffer(3, SignalUp, INDICATOR_DATA);
    SetIndexArrow(3, 233);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, Blue);
    SetIndexLabel(3, "Signal Up");

    SetIndexBuffer(4, SignalDn, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, Red);
    SetIndexArrow(4, 234);
    SetIndexLabel(4, "Signal Dn");

    SetIndexBuffer(5, PinbarUp, INDICATOR_DATA);
    SetIndexArrow(5, 159);
    SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, Blue);
    SetIndexLabel(5, "Pinbar Up");

    SetIndexBuffer(6, PinbarDn, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, Red);
    SetIndexArrow(6, 159);
    SetIndexLabel(6, "Pinbar Dn");


    ma1 = new MovingAverage(Symbol(), 0, ma1Period, ma1Shift, ma1Method, ma1AppliedPrice);
    ma2 = new MovingAverage(Symbol(), 0, ma2Period, ma2Shift, ma2Method, ma2AppliedPrice);
    ma3 = new MovingAverage(Symbol(), 0, ma3Period, ma3Shift, ma3Method, ma3AppliedPrice);

    pinbar = new Pinbar(Symbol(), PERIOD_CURRENT);
    //---
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

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
    int start, i;
    if(prev_calculated == 0)
    {
        start = rates_total - ma3Period;
    }
    else
    {
        start = rates_total - (prev_calculated - 1);
    }

    for(i = start; i >= 0; i--)
    {
        LineMa1[i] = ma1.index(i);
        LineMa2[i] = ma2.index(i);
        LineMa3[i] = ma3.index(i);

        if(havePinbarUp(i))
        {

            if(LineMa1[i+1] > LineMa2[i+1] && LineMa2[i+1] > LineMa3[i+1])
            {
                SignalUp[i + 1] = Low[i + 1] - 20 * _Point;
                notify(0);
            }

            if(SignalUp[i + 1] == EMPTY_VALUE)
                PinbarUp[i + 1] = Low[i + 1] - 20 * _Point;
        }

            
        if(havePinbarDown(i))
        {
            if(LineMa1[i+1] < LineMa2[i+1] && LineMa2[i+1] < LineMa3[i+1])
            {
                SignalDn[i + 1] = High[i + 1] + 20 * _Point;
                notify(1);
            }

            if(SignalDn[i + 1] == EMPTY_VALUE)
                PinbarDn[i + 1] = High[i + 1] + 20 * _Point;
        }
    }
    return (rates_total);
}

// ------------------------------------------------------------------


bool havePinbarUp(int i)
{
    // TODO: signal up
    return pinbar.FindPattern(i) == "p";

}

bool havePinbarDown(int i)
{
    // TODO: signal down
    return pinbar.FindPattern(i) == "q";
}

bool haveSignalUp(int i)
{
    for(int n=i+1; n < i+4; n++)
    {
        if(LineMa1[n] > LineMa2[n] > LineMa3[n])
        {
            if(PinbarUp[n] != EMPTY_VALUE && iClose(NULL,0,i) > PinbarUp[n])
            {
                return true;
            }
        }
    }
    return false;
}
bool haveSignalDn(int i)
{
return false;
}


void notify(int type)
{
    if(newCandle.IsNewCandle())
    {
        Notifications(type);
    }
}

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
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    | 
//+------------------------------------------------------------------------------------------------+