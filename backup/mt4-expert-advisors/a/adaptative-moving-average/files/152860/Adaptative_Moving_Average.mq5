//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74231

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
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

bool hide = false;
#include <Controls/Button.mqh>
CButton bt1;
#define BUTTON1_NAME "On/Off"

//--- indicator buffers
double ma1Line [];
double ma2Line [];
double ma3Line [];
double ma4Line [];

// ------------------------------------------------------------------
input int    periods = 1000;

input string             ma1Title = "== Moving Average Setup ==";  // == Moving Average Setup ==
input bool               ma1on = true; // Ma 1 ON ?
input color ma1clr = Green; // Color:
input int                ma1Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma1Method = MODE_SMA;                      // Method
input ENUM_APPLIED_PRICE ma1AppliedPrice = PRICE_CLOSE;                   // Applied Price

input int ma1Period_M1 = 5; // Periods to M1:
input int ma1Period_M5 = 10; // Periods to M5:
input int ma1Period_M15 = 15; // Periods to M15:
input int ma1Period_M30 = 20; // Periods to M30:
input int ma1Period_H1 = 30; // Periods to H1:
input int ma1Period_H4 = 50; // Periods to H4:
input int ma1Period_D1 = 100; // Periods to D1:
input int ma1Period_W1 = 200; // Periods to W1:
input int ma1Period_MN = 300; // Periods to MN:

input string             ma2Title = "== Moving Average Setup ==";  // == Moving Average Setup ==
input bool               ma2on = true; // Ma 2 ON ?
input color ma2clr = Pink; // Color:
input int                ma2Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma2Method = MODE_EMA;                      // Method
input ENUM_APPLIED_PRICE ma2AppliedPrice = PRICE_CLOSE;                   // Applied Price

input int ma2Period_M1 = 5; // Periods to M1:
input int ma2Period_M5 = 10; // Periods to M5:
input int ma2Period_M15 = 15; // Periods to M15:
input int ma2Period_M30 = 20; // Periods to M30:
input int ma2Period_H1 = 30; // Periods to H1:
input int ma2Period_H4 = 50; // Periods to H4:
input int ma2Period_D1 = 100; // Periods to D1:
input int ma2Period_W1 = 200; // Periods to W1:
input int ma2Period_MN = 300; // Periods to MN:

input string             ma3Title = "== Moving Average Setup ==";  // == Moving Average Setup ==
input bool               ma3on = true; // Ma 3 ON ?
input color ma3clr = Blue; // Color:
input int                ma3Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma3Method = MODE_SMMA;                      // Method
input ENUM_APPLIED_PRICE ma3AppliedPrice = PRICE_CLOSE;                   // Applied Price

input int ma3Period_M1 = 5; // Periods to M1:
input int ma3Period_M5 = 10; // Periods to M5:
input int ma3Period_M15 = 15; // Periods to M15:
input int ma3Period_M30 = 20; // Periods to M30:
input int ma3Period_H1 = 30; // Periods to H1:
input int ma3Period_H4 = 50; // Periods to H4:
input int ma3Period_D1 = 100; // Periods to D1:
input int ma3Period_W1 = 200; // Periods to W1:
input int ma3Period_MN = 300; // Periods to MN:

input string             ma4Title = "== Moving Average Setup ==";  // == Moving Average Setup ==
input bool               ma4on = true; // Ma 4 ON ?
input color ma4clr = Crimson; // Color:
input int                ma4Shift = 0;                             // Ma Shift
input ENUM_MA_METHOD     ma4Method = MODE_LWMA;                      // Method
input ENUM_APPLIED_PRICE ma4AppliedPrice = PRICE_CLOSE;                   // Applied Price

input int ma4Period_M1 = 5; // Periods to M1:
input int ma4Period_M5 = 10; // Periods to M5:
input int ma4Period_M15 = 15; // Periods to M15:
input int ma4Period_M30 = 20; // Periods to M30:
input int ma4Period_H1 = 30; // Periods to H1:
input int ma4Period_H4 = 50; // Periods to H4:
input int ma4Period_D1 = 100; // Periods to D1:
input int ma4Period_W1 = 200; // Periods to W1:
input int ma4Period_MN = 300; // Periods to MN:

input string T1 = "== Notifications ==";  // Notifications
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications

input string Tbtn = "== Button  ==";  // ————————————
input color on_color = SpringGreen; // ON Color:
input color off_color = Gray; // OFF Color:

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
    MovingAverage(string Symbol, ENUM_TIMEFRAMES TimeFrame, int set0, int set1, ENUM_MA_METHOD set2, ENUM_APPLIED_PRICE set3)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
        setSetup(set0, set1, set2, set3);
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
        int sh = iBars(Symbol(), 0) - shift;
        int    copy = CopyBuffer(_handle, buffer, sh, 1, value);
        if(copy > 0) { return value[0]; }
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

int ma1Period;
int ma2Period;
int ma3Period;
int ma4Period;


// NOTE: oninit
// ------------------------------------------------------------------
void OnInit()
{
    OnInitButtons();
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    SetIndexBuffer(0, ma1Line, INDICATOR_DATA);
    SetIndexBuffer(1, ma2Line, INDICATOR_DATA);
    SetIndexBuffer(2, ma3Line, INDICATOR_DATA);
    SetIndexBuffer(3, ma4Line, INDICATOR_DATA);

    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);

    PlotIndexSetInteger(0, PLOT_LINE_COLOR, ma1clr);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, ma2clr);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, ma3clr);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, ma4clr);

    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
    PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);
    PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 2);

    if(!ma1on)PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
    if(!ma2on)PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
    if(!ma3on)PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    if(!ma4on)PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);

    // NOTE: set moving averages
    SetMaPeriods();
    ma1 = new MovingAverage(NULL, 0, ma1Period, ma1Shift, ma1Method, ma1AppliedPrice);
    ma2 = new MovingAverage(NULL, 0, ma2Period, ma2Shift, ma2Method, ma2AppliedPrice);
    ma3 = new MovingAverage(NULL, 0, ma3Period, ma3Shift, ma3Method, ma3AppliedPrice);
    ma4 = new MovingAverage(NULL, 0, ma4Period, ma4Shift, ma4Method, ma4AppliedPrice);
}

// NOTE: deinit
void OnDeinit(const int reason)
{
    delete ma1;
    delete ma2;
    delete ma3;
    delete ma4;
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
  OnChartEventButtons(id, lparam, dparam, sparam);
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
    if(rates_total < periods) return (0);

    int start;
    if(prev_calculated > 1)
        start = prev_calculated - 1;
    else {
        start = periods + 1;
    }

    for(int i = start; i < rates_total && !IsStopped(); i++) {

        ma1Line[i] = ma1.index(i);
        ma2Line[i] = ma2.index(i);
        ma3Line[i] = ma3.index(i);
        ma4Line[i] = ma4.index(i);

        // if(newCandle.IsNewCandle()) { Notifications(0); }
    }

    return (rates_total);
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


void SetMaPeriods()
{
    switch(_Period)
    {
        case PERIOD_M1:
            ma1Period = ma1Period_M1;
            ma2Period = ma2Period_M1;
            ma3Period = ma3Period_M1;
            ma4Period = ma4Period_M1;
            break;
        case PERIOD_M5:
            ma1Period = ma1Period_M5;
            ma2Period = ma2Period_M5;
            ma3Period = ma3Period_M5;
            ma4Period = ma4Period_M5;
            break;
        case PERIOD_M15:
            ma1Period = ma1Period_M15;
            ma2Period = ma2Period_M15;
            ma3Period = ma3Period_M15;
            ma4Period = ma4Period_M15;
            break;
        case PERIOD_M30:
            ma1Period = ma1Period_M30;
            ma2Period = ma2Period_M30;
            ma3Period = ma3Period_M30;
            ma4Period = ma4Period_M30;
            break;
        case PERIOD_H1:
            ma1Period = ma1Period_H1;
            ma2Period = ma2Period_H1;
            ma3Period = ma3Period_H1;
            ma4Period = ma4Period_H1;
            break;
        case PERIOD_H4:
            ma1Period = ma1Period_H4;
            ma2Period = ma2Period_H4;
            ma3Period = ma3Period_H4;
            ma4Period = ma4Period_H4;
            break;
        case PERIOD_D1:
            ma1Period = ma1Period_D1;
            ma2Period = ma2Period_D1;
            ma3Period = ma3Period_D1;
            ma4Period = ma4Period_D1;
            break;
        case PERIOD_W1:
            ma1Period = ma1Period_W1;
            ma2Period = ma2Period_W1;
            ma3Period = ma3Period_W1;
            ma4Period = ma4Period_W1;
            break;
        case PERIOD_MN1:
            ma1Period = ma1Period_MN;
            ma2Period = ma2Period_MN;
            ma3Period = ma3Period_MN;
            ma4Period = ma4Period_MN;
            break;
    }
}


// NOTE: Buton
// ------------------------------------------------------------------
int OnInitButtons()
{

	if (!Create_button(BUTTON1_NAME, 10, 100, 17, 100, bt1)) return (INIT_FAILED);

  return true;
}

bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton& bt)
{
  int x2 = x1 + width;
  int y2 = y1 + high;

  bt.Create(0, name, 0, x1, y1, x2, y2);
  bt.Text("ON");
  bt.Font("Calibri");
  bt.FontSize(8);
  bt.ColorBackground(on_color);
  return true;
}

// NOTE: Events
void OnChartEventButtons(const int id, const long& lparam, const double& dparam, const string& sparam)
{
  if (id == CHARTEVENT_OBJECT_CLICK && sparam == BUTTON1_NAME)
  {
		// TODO: event del button 1   
    ActionBt1();
  }
}

void ActionBt1()
{
 // hacer que los indicadores NO se vean o SI se vean
  hide = hide == true ? false : true;


    // PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
    // PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
    // PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
    // PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);

    // PlotIndexSetInteger(0, PLOT_LINE_COLOR, ma1clr);
    // PlotIndexSetInteger(1, PLOT_LINE_COLOR, ma2clr);
    // PlotIndexSetInteger(2, PLOT_LINE_COLOR, ma3clr);
    // PlotIndexSetInteger(3, PLOT_LINE_COLOR, ma4clr);

    // PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
    // PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
    // PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);
    // PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 2);

    // if(!ma1on)PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
    // if(!ma2on)PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
    // if(!ma3on)PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    // if(!ma4on)PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
  

    
    if(hide)
	{
		PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
        bt1.ColorBackground(off_color);
        bt1.Text("OFF");
    }
    else
	{
		PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
        PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
        PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
        PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
        bt1.ColorBackground(on_color);
        bt1.Text("ON");
    }
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//| USDT Donations                                                                                 |
//+------------------------------------------------+-----------------------------------------------+
//| Network                                        |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+