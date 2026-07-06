// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74055 

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
double ArrowUp [];
double ArrowDn [];

// NOTE: Inputs
// ------------------------------------------------------------------
input string             Iema1 = "== Moving Average 1 Setup ==";  // == Moving Average Setup ==
input int                ma1_Period = 5;                            // Period
input int                ma1_Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma1_Method = MODE_EMA;                     // Method
input ENUM_APPLIED_PRICE ma1_AppliedPrice = PRICE_CLOSE;                   // Applied Price
input string             Iema2 = "== Moving Average 2 Setup ==";  // == Moving Average Setup ==
input int                ma2_Period = 10;                            // Period
input int                ma2_Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma2_Method = MODE_EMA;                     // Method
input ENUM_APPLIED_PRICE ma2_AppliedPrice = PRICE_CLOSE;                   // Applied Price
input string             Iema3 = "== Moving Average 3 Setup ==";  // == Moving Average Setup ==
input int                ma3_Period = 20;                            // Period
input int                ma3_Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma3_Method = MODE_EMA;                     // Method
input ENUM_APPLIED_PRICE ma3_AppliedPrice = PRICE_CLOSE;                   // Applied Price
input string             Iema4 = "== Moving Average 4 Setup ==";  // == Moving Average Setup ==
input int                ma4_Period = 50;                            // Period
input int                ma4_Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma4_Method = MODE_EMA;                     // Method
input ENUM_APPLIED_PRICE ma4_AppliedPrice = PRICE_CLOSE;                   // Applied Price

input string T0 = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:
input string T1 = "== Notifications ==";  // Notifications
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications






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
        int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
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
MovingAverage* ma1;
MovingAverage* ma2;
MovingAverage* ma3;
MovingAverage* ma4;



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

// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_ARROW, 233);
    PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 234);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);

    if(!ArrowsOn) {
        PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
    }
    ma1 = new MovingAverage(NULL, 0); ma1.setSetup(ma1_Period, ma1_Shift, ma1_Method, ma1_AppliedPrice);
    ma2 = new MovingAverage(NULL, 0); ma2.setSetup(ma2_Period, ma2_Shift, ma2_Method, ma2_AppliedPrice);
    ma3 = new MovingAverage(NULL, 0); ma3.setSetup(ma3_Period, ma3_Shift, ma3_Method, ma3_AppliedPrice);
    ma4 = new MovingAverage(NULL, 0); ma4.setSetup(ma4_Period, ma4_Shift, ma4_Method, ma4_AppliedPrice);

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    delete ma1;
    delete ma2;
    delete ma3;
    delete ma4;
}
// NOTE: OnCalculate
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
    int i, start;

    start = 100;
    if(prev_calculated > 1) start = prev_calculated - 1;

    for(i = start; i < rates_total && !IsStopped(); i++)
    {
        if(haveSignalUp(i)) {
            ArrowUp[i] = low[i];
            if(newCandle.IsNewCandle()) { Notifications(0); }
        }

        if(haveSignalDown(i)) {
            ArrowDn[i] = high[i];
            
            if(newCandle.IsNewCandle()) { Notifications(1); }
        }
    }

    return (rates_total);
}
//+------------------------------------------------------------------+

bool haveSignalUp(int _i)
{
    // TODO: signal up
    int i = Bars(_Symbol, 0)-_i;
    return  ma1.index(i) > ma4.index(i) && ma2.index(i) > ma4.index(i) && ma3.index(i) > ma4.index(i) && ma3.index(i + 1) < ma4.index(i + 1);
    return false;
}

bool haveSignalDown(int _i)
{
    // TODO: signal down
    int i = Bars(_Symbol, 0)-_i;
    return  ma1.index(i) < ma4.index(i) && ma2.index(i) < ma4.index(i) && ma3.index(i) < ma4.index(i) && ma3.index(i + 1) > ma4.index(i+1);
    return false;
}

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