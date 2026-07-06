// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74430

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
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "Cross Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Cross Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "State"
#property  indicator_type3  DRAW_NONE
#property indicator_width3 1
//--- indicator buffers
double CrossUp [];
double CrossDn [];
double State [];

// NOTE: Inputs
// ------------------------------------------------------------------
input string             Iema = "== Moving Average Setup ==";  // == Moving Average Setup ==
input int                maPerFast = 4;                            // Period Fast
input int                maPerSlow = 5;                            // Period Slow
int                      maShift = 0;                             // Ma Shift
input ENUM_MA_METHOD     maMethod = MODE_EMA;                     // Method
input ENUM_APPLIED_PRICE maAppliedPrice = PRICE_CLOSE;                   // Applied Price
// ------------------------------------------------------------------
input string T1 = "== Notifications ==";  // Notifications
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications

// NOTE: Objects
// ------------------------------------------------------------------
class CNewCandle
{
    private:
    int             _initialCandles;
    string          _symbol;
    ENUM_TIMEFRAMES _tf;

    public:
    CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
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
        if(_currentCandles > _initialCandles) {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();



class MovingAverage
{
    string          _symbol;
    ENUM_TIMEFRAMES _tf;
    int             _handle;

    struct MovingAverageParameters {
        int                setup0;  //  Period
        int                setup1;  //  Ma Shift
        ENUM_MA_METHOD     setup2;  //  Method
        ENUM_APPLIED_PRICE setup3;  //  Applied Price
    };
    MovingAverageParameters _setup;

    public:
    MovingAverage()
    {
        _symbol = _Symbol;
        _tf = Period();
    }
    MovingAverage(string Symbol, ENUM_TIMEFRAMES TimeFrame)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
    }
    ~MovingAverage() { ; }

    void setHandle()
    {
        _handle = iMA(_symbol, _tf,
            _setup.setup0,
            _setup.setup1,
            _setup.setup2,
            _setup.setup3);
    }
    void setSetup(int set0, int set1, ENUM_MA_METHOD set2, ENUM_APPLIED_PRICE set3)
    {
        _setup.setup0 = set0;
        _setup.setup1 = set1;
        _setup.setup2 = set2;
        _setup.setup3 = set3;
        setHandle();
    }
    double calculate(int buffer, int shift)
    {
        double value[1];
        int b = iBars(NULL, 0);
        int sh = b - shift;
        // int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
        int    copy = CopyBuffer(_handle, buffer, sh, 1, value);
        if(copy > 0) {
            return value[0];
        }
        return -1;
    }
    double index(int shift)
    {
        return calculate(0, shift);
    }
};

MovingAverage* maFast;
MovingAverage* maSlow;



// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
    SetIndexBuffer(0, CrossUp, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_ARROW, 233);
    PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, Blue);

    SetIndexBuffer(1, CrossDn, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 234);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, Red);

    SetIndexBuffer(2, State, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);

    //--- 
    maFast = new MovingAverage();
    maFast.setSetup(maPerFast, maShift, maMethod, maAppliedPrice);
    maSlow = new MovingAverage();
    maSlow.setSetup(maPerSlow, maShift, maMethod, maAppliedPrice);


    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    delete maFast;
    delete maSlow;
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

    // NOTE: OnCalculate

    int i, start;

    start = maPerSlow + 1;
    if(prev_calculated > 1) start = prev_calculated - 1;

    for(i = start; i < rates_total && !IsStopped(); i++)
    {
        CrossUp[i] = EMPTY_VALUE;
        CrossDn[i] = EMPTY_VALUE;
        State[i] = State[i - 1];


        if(maFast.index(i) > maSlow.index(i)) { State[i] = 1; }
        if(maFast.index(i) < maSlow.index(i)) { State[i] = -1; }

        if(State[i] != State[i - 1])
        {
            if(State[i] == 1) {
                CrossUp[i-1] = low[i-1];
                if(newCandle.IsNewCandle()) { Notifications(0); }
            }
            if(State[i] == -1){
                CrossDn[i-1] = high[i-1];
                if(newCandle.IsNewCandle()) { Notifications(1); }
            }
        }
    }

    return (rates_total);
}
//+------------------------------------------------------------------+

void Notifications(int type)
{
    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

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
    switch(lPeriod) {
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