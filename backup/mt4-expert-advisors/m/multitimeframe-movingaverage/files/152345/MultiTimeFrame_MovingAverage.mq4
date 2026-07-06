// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74112

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
#property indicator_buffers 4
#property indicator_plots 4
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
double LineMa1 [];
double LineMa2 [];

double ArrowUp [];
double ArrowDn [];

// ------------------------------------------------------------------
input string             Iema1 = "== Moving Average 1 Setup ==";  // == Moving Average 1 Setup ==
input ENUM_TIMEFRAMES    ma1TF = PERIOD_H1;              // Time Frame:
input int                ma1Period = 20;                            // Period
input int                ma1Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma1Method = MODE_EMA;                      // Method
input ENUM_APPLIED_PRICE ma1AppliedPrice = PRICE_CLOSE;                   // Applied Price
input string             Iema2 = "== Moving Average 2 Setup ==";  // == Moving Average 2 Setup ==
input ENUM_TIMEFRAMES    ma2TF = PERIOD_H4;              // Time Frame:
input int                ma2Period = 50;                            // Period
input int                ma2Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma2Method = MODE_EMA;                      // Method
input ENUM_APPLIED_PRICE ma2AppliedPrice = PRICE_CLOSE;                   // Applied Price
input string    Tsignals = "== Signals ==";  // ————————————
input bool PullBack = true;// Pullback On:
input bool Cross = true;// Cross Up and Down On:

// ENUM_TIMEFRAMES TFSup = PERIOD_H4;              // Superior Time Frame:
// input int       periods = 10;                     // Periods:
input string    T1 = "== Notifications ==";  // ————————————
input bool      notifications = false;                  // Notifications On?
input bool      desktop_notifications = false;                  // Desktop MT4 Notifications
input bool      email_notifications = false;                  // Email Notifications
input bool      push_notifications = false;                  // Push Mobile Notifications
input string    T2 = "== Set Lines ==";      // ————————————
input bool      LinesOn = true;                   // Line On?
input color     LineUpClr = clrBlue;                // Line Up Color:
input color     LineDnClr = clrRed;                 // Line Down Color:
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
ENUM_TIMEFRAMES tf;

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

// ------------------------------------------------------------------
int OnInit()
{
    // tf = TFSup <= Period() ? Period() : TFSup;
    // tf =  <= Period() ? Period() : TFSup;

    //--- indicator buffers mapping
    SetIndexBuffer(0, LineMa1, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_LINE, EMPTY, 1, LineUpClr);
    SetIndexBuffer(1, LineMa2, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineDnClr);
    SetIndexArrow(1, 234);
    if(!LinesOn)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(2, 233);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, Green);
    SetIndexLabel(2, "Arrow Up");

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, Crimson);
    SetIndexArrow(3, 234);
    SetIndexLabel(3, "Arrow Dn");

    ma1 = new MovingAverage(_Symbol, ma1TF);
    ma1.setSetup(ma1Period, ma1Shift, ma1Method, ma1AppliedPrice);
    ma2 = new MovingAverage(_Symbol, ma2TF);
    ma2.setSetup(ma2Period, ma2Shift, ma2Method, ma2AppliedPrice);

    //---
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}
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
    int start, i, isup;
    if(prev_calculated == 0) { start = rates_total - 500; }
    else { start = rates_total - (prev_calculated - 1); }

    for(i = start; i >= 0; i--)
    {
        int ima1 = iBarShift(NULL, ma1TF, time[i], false);
        LineMa1[i] = ma1.index(ima1);

        int ima2 = iBarShift(NULL, ma2TF, time[i], false);
        LineMa2[i] = ma2.index(ima2);


        if(haveSignalUp(i))
        {
            ArrowUp[i+1] = Low[i+1];
            if(newCandle.IsNewCandle()) { Notifications(0); }
        }

        if(haveSignalDown(i))
        {
            ArrowDn[i+1] = High[i+1];
            if(newCandle.IsNewCandle()) { Notifications(1); }
        }


    }
    return (rates_total);
}

// ------------------------------------------------------------------
bool haveSignalUp(int i)
{
    // TODO: signal up
    if (PullBack)
    {
        return
            iOpen(NULL, 0, i + 2) > iClose(NULL,0,i+2) &&
            iLow(NULL, 0, i + 1) < LineMa1[i + 1] &&
            iClose(NULL, 0, i + 1) > LineMa1[i + 1];
    }
    if (Cross)
    {
        return iOpen(NULL, 0, i + 1) < LineMa1[i+1] && iClose(NULL, 0, i + 1) > LineMa1[i+1];
        
    }

    return false;
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    if (PullBack)
    {
        return
            (iOpen(NULL, 0, i + 2) < iClose(NULL, 0, i + 2) &&
            iHigh(NULL, 0, i + 1) > LineMa1[i + 1] &&
            iClose(NULL, 0, i + 1) < LineMa1[i + 1]) ||
            (iOpen(NULL, 0, i + 2) < iClose(NULL, 0, i + 2) &&
            iHigh(NULL, 0, i + 1) > LineMa2[i + 1] &&
            iClose(NULL, 0, i + 1) < LineMa2[i + 1]);
    }

    if (Cross)
    {
        return
            (iOpen(NULL, 0, i + 1) > LineMa1[i] && iClose(NULL, 0, i + 1) < LineMa1[i]) ||
            (iOpen(NULL, 0, i + 1) > LineMa2[i] && iClose(NULL, 0, i + 1) < LineMa2[i]);
    }
    
    return false;
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
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
//|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+