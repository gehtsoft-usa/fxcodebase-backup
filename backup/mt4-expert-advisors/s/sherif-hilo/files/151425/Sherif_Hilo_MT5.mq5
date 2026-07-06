//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=152415#p152415

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

#property indicator_buffers 5
#property indicator_plots 2
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
#property indicator_type3  DRAW_NONE
#property indicator_label4 "Arrow Down"
#property indicator_type4  DRAW_NONE

// NOTE: Inputs
// ------------------------------------------------------------------
input int period_high = 100; // HHV:
input int period_lows = 100; // LLV:
int    Period = 1;                     // Indicator Periods

// ------------------------------------------------------------------
string T1 = "== Notifications ==";  // Notifications
bool   notifications = false;                  // Notifications On?
bool   desktop_notifications = false;                  // Desktop MT4 Notifications
bool   email_notifications = false;                  // Email Notifications
bool   push_notifications = false;                  // Push Mobile Notifications
// ------------------------------------------------------------------

// NOTE: Buffers
//--- indicator buffers
double LineUp [];
double LineDn [];
double Max [];
double Min [];
double Data [];

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

    Period = period_lows > period_high ? period_lows : period_high;

    //--- indicator short name
    string short_name = "Line Indicator";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    SetIndexBuffer(0, LineUp);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Period);
    SetIndexBuffer(1, LineDn);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Period);

    SetIndexBuffer(2, Max, INDICATOR_CALCULATIONS);
    //   PlotIndexSetInteger(2, PLOT_ARROW, 233);
    //   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
    //   PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(3, Min, INDICATOR_CALCULATIONS);
    SetIndexBuffer(4, Data, INDICATOR_CALCULATIONS);
    //   PlotIndexSetInteger(3, PLOT_ARROW, 234);
    //   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -10);
    //   PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);

    //   if (!ArrowsOn) {    
            // PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
        // PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
    //   }
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

    for(int i = start; i < rates_total && !IsStopped(); i++)
    {
        double min = 0;
        double max = 0;

        for(int j = 1; j < period_lows; j++)
        {
            if(min == 0 || low[i - j] < min)
                min = low[i - j];
        }

        for(int j = 1; j < period_high; j++)
        {
            if(max == 0 || high[i - j] > max)
                max = high[i - j];
        }

        Data[i] = Data[i - 1];
        Max[i] = max;
        Min[i] = min;

        // if(ArraySize(Data) >= 1){

        if(close[i] > Data[i - 1])
        {
            if(LineUp[i - 1] != EMPTY_VALUE)
                LineUp[i] = Min[i] >= LineUp[i - 1] ? Min[i] : LineUp[i - 1];
            else
                LineUp[i] = Min[i];
                
            Data[i] = LineUp[i];
            LineDn[i] = EMPTY_VALUE;

        }


        if(close[i] < Data[i - 1])
        {
            if(LineDn[i - 1] != EMPTY_VALUE)
                LineDn[i] = Max[i] <= LineDn[i - 1] ? Max[i] : LineDn[i - 1];
            else
                LineDn[i] = Max[i];
            
            Data[i] = LineDn[i];
            LineUp[i] = EMPTY_VALUE;

        }
        // }

    }
    return (rates_total);
}
// ------------------------------------------------------------------

bool isGoingUp(int i)
{
    return iClose(NULL, 0, i) > Data[i - 1];
}

bool isGoingDown(int i)
{
    return iClose(NULL, 0, i) < Data[i - 1];
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