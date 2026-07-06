// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74515

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window

#property indicator_buffers 4
#property indicator_plots 4
#property indicator_label1 "LineOpen"
#property indicator_type1  DRAW_LINE
#property indicator_color1 RoyalBlue
#property indicator_style1 STYLE_DOT
#property indicator_width1 1
#property indicator_label2 "LineClose"
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
input int    avPeriod = 3;                      // Indicator Periods
input string T0 = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:
input string T1 = "== Notifications ==";  // Notifications
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double lineOpen [];
double lineClose [];
double ArrowUp [];
double ArrowDn [];

double alpha;

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
    //--- indicator short name
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    SetIndexBuffer(0, lineOpen);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, avPeriod);
    SetIndexBuffer(1, lineClose);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, avPeriod);

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_ARROW, 233);
    PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(3, PLOT_ARROW, 234);
    PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);

    alpha = 2.0 / (avPeriod + 1);

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
    int start;
    start = prev_calculated < 1 ? 0 : prev_calculated - 1;

    for(int i = start; i < rates_total && !IsStopped(); i++) {

        // Heiken Ashi Calc:
        double openPrev = i - 1 >= 0 ? lineOpen[i - 1] : open[i];
        double closePrev = i - 1 >= 0 ? lineClose[i - 1] : close[i];

        lineOpen[i] = openPrev + (closePrev - openPrev) * alpha;
        lineClose[i] = (open[i] + close[i] + high[i] + low[i]) * 0.25;

        
        // Signals:
        if(i > 2) {
            if(lineClose[i-1] > lineOpen[i-1] && lineClose[i - 2] <= lineOpen[i - 2]) {
                ArrowUp[i-1] = low[i-1];
                if(newCandle.IsNewCandle()) { Notifications(0); }
            }
            if(lineClose[i-1] < lineOpen[i-1] && lineClose[i - 2] >= lineOpen[i - 2]) {
                ArrowDn[i-1] = high[i-1];
                if(newCandle.IsNewCandle()) { Notifications(1); }
            }
        }
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