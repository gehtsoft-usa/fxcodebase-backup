//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74227

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
#property indicator_label1 "Line1"
#property indicator_type1  DRAW_LINE
#property indicator_color1 RoyalBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line2"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Tomato
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Arrow Up"
#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Arrow Down"
#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

// NOTE: Inputs
// ------------------------------------------------------------------
input string ICustom = "== Ichimoku Setup ==";  // == Ichimoku Setup ==
input int    uTenkan_sen = 9;                       // period of Tenkan-sen line
input int    uKijun_sen = 26;                      // period of Kijun-sen line
input int    uSenkou_span_b = 52;                      // period of Senkou Span B line

input int    Period = 10;                     // Indicator Periods

input string T0 = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:
input string T1 = "== Notifications ==";  // Notifications
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
input int    minutesBetwenNotify = 1;                      // Minutes Betwen Notifications
int          timeNextNotify = 0;

// NOTE: Buffers
//--- indicator buffers
double lineTenkan [];
double lineRed [];
double ArrowUp [];
double ArrowDn [];


class Ichimoku
{
    string          _symbol;         // symbol
    ENUM_TIMEFRAMES _tf;             // timeframe
    int             _tenkan_sen;     // period of Tenkan-sen line
    int             _kijun_sen;      // period of Kijun-sen line
    int             _senkou_span_b;  // period of Senkou Span B line
    int             _handle;

    public:
    Ichimoku()
    {
        _symbol = _Symbol;
        _tf = Period();
    }
    Ichimoku(string Symbol, ENUM_TIMEFRAMES TimeFrame)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
    }
    ~Ichimoku() { ; }

    void setHandle()
    {
        _handle = iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b);
    }
    void set(int inpTenkan_sen, int inpKijun_sen, int inpSenkou_span_b)
    {
        _tenkan_sen = inpTenkan_sen;
        _kijun_sen = inpKijun_sen;
        _senkou_span_b = inpSenkou_span_b;
        setHandle();
    }

    // clang-format off
    double calculate(int shift, int buffer = 0)
    {
        double value[1];
        int copy = CopyBuffer(_handle, buffer, shift, 1, value);
        if(copy > 0) { return value[0]; }
        return -1;
    }

    double Tenkansen(int shift) { return calculate(shift, 0); }
    double Kijunsen(int shift) { return calculate(shift, 1); }
    double SenkouSpanA(int shift) { return calculate(shift, 2); }
    double SenkouSpanB(int shift) { return calculate(shift, 3); }
    double ChikouSpan(int shift) { return calculate(shift, 4); }
};
Ichimoku ichimoku();

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

// ------------------------------------------------------------------
void OnInit()
{

    ichimoku.set(uTenkan_sen, uKijun_sen, uSenkou_span_b);

    //--- indicator short name
    string short_name = "Line Indicator";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    SetIndexBuffer(0, lineTenkan);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Period);
    SetIndexBuffer(1, lineRed);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Period);

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_ARROW, 233);
    PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(3, PLOT_ARROW, 234);
    PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);

    if(!ArrowsOn) {
        PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
    }
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
    if(rates_total < Period) return (0);

    int start;
    if(prev_calculated > 1) start = prev_calculated - 1; else { start = Period + 1; }

    for(int i = start; i < rates_total && !IsStopped(); i++) {

        int sh = iBars(Symbol(), 0) - i;
        lineTenkan[i] = ichimoku.Tenkansen(sh);

        // lineRed[i]  = AddLows / Period;

        if(open[i - 1] < lineTenkan[i - 1] && close[i - 1] > lineTenkan[i - 1]) {
            ArrowUp[i - 1] = low[i - 1];
            if(newCandle.IsNewCandle()) { Notifications(0); }
        }

        if(open[i - 1] > lineTenkan[i - 1] && close[i - 1] < lineTenkan[i - 1]) {
            ArrowDn[i - 1] = high[i - 1];
            if(newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }
    }

    return (rates_total);
}
// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    int shift = iBars(_Symbol, Period()) - i;
    if(iOpen(_Symbol, Period(), shift) < iClose(_Symbol, Period(), shift)
        && iClose(_Symbol, Period(), shift) > lineTenkan[shift]
        && iOpen(_Symbol, Period(), shift) < lineTenkan[shift])
    {
        return true;
    }

    return false;
}
bool haveSignalDown(int i)
{
    int shift = iBars(_Symbol, Period()) - i;
    if(iOpen(_Symbol, Period(), shift) > iClose(_Symbol, Period(), shift)
    && iClose(_Symbol, Period(), shift) < lineTenkan[shift]
    && iOpen(_Symbol, Period(), shift) > lineTenkan[shift])
    {
        return true;
    }

    return false;
}

void Notifications(int type)
{
    // time Control
    if(timeNextNotify != 0) if(TimeCurrent() < timeNextNotify) return;
    timeNextNotify = TimeCurrent() + (minutesBetwenNotify * 60);

    string text = "";
    if(type == 0) text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

    text += " ";

    if(!notifications)
        return;
    if(desktop_notifications) Alert(text);
    if(push_notifications) SendNotification(text);
    if(email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod) {
        case PERIOD_M1: return ("M1");
        case PERIOD_M5: return ("M5");
        case PERIOD_M15: return ("M15");
        case PERIOD_M30: return ("M30");
        case PERIOD_H1: return ("H1");
        case PERIOD_H4: return ("H4");
        case PERIOD_D1: return ("D1");
        case PERIOD_W1: return ("W1");
        case PERIOD_MN1: return ("MN1");
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