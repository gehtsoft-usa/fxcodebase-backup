//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75125

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
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 5
#property indicator_label1 "Line1"
#property indicator_type1  DRAW_NONE
#property indicator_color1 RoyalBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line2"
#property indicator_type2  DRAW_NONE
#property indicator_color2 Tomato
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Up Signal"
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_style3 STYLE_SOLID
#property indicator_width3 5
#property indicator_label4 "Down Signal"
#property indicator_type4  DRAW_HISTOGRAM
#property indicator_style4 STYLE_SOLID
#property indicator_width4 5

#property indicator_minimum 0.0
#property indicator_maximum 100.0

// NOTE: Inputs
// ------------------------------------------------------------------
input int            Period      = 14; // Indicator Periods
input int            KPeriod     = 21;
input int            DPeriod     = 12;
input int            Slowing     = 3;
input ENUM_MA_METHOD method      = MODE_SMA;
ENUM_STO_PRICE       price_field = STO_LOWHIGH;
input double         ZoneHighPer = 70.0;
input double         ZoneLowPer  = 30.0;
input bool           modeone     = true;

input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double sto_K[];
double sto_D[];
double bu_Buy[];
double bu_Sell[];

datetime tm_last_signal_buy  = 0;
datetime tm_last_signal_sell = 0;
int      trend               = 0;

int handleStoch = 0;

#define Section_Stoch
#ifdef Section_Stoch

int handle_stoch = 0;
void setHandle() { handle_stoch = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, method, price_field); }

double stoch_k(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle - 1;
    int    copy  = CopyBuffer(handle_stoch, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}
double stoch_d(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle - 1;
    int    copy  = CopyBuffer(handle_stoch, 1, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

#endif

// ------------------------------------------------------------------
void OnInit()
{
    SetIndexBuffer(0, sto_K);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Period);
    SetIndexBuffer(1, sto_D);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Period);
    
    SetIndexBuffer(2, bu_Buy, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, Aqua);
    SetIndexBuffer(3, bu_Sell, INDICATOR_DATA);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, Magenta);

    IndicatorSetInteger(INDICATOR_LEVELS, 2);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, ZoneLowPer);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, ZoneHighPer);
    IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, Gray);
    IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_DOT);
    IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1, Gray);
    IndicatorSetInteger(INDICATOR_LEVELSTYLE, 1, STYLE_DOT);

    setHandle();
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (rates_total < Period) return (0);

    int start;
    if (prev_calculated > 1)
        start = prev_calculated - 1;
    else {
        start = Period + 1;
    }

    for (int i = start; i < rates_total && !IsStopped(); i++) {

        sto_K[i] = stoch_k(i);
        sto_D[i] = stoch_d(i);

        double d0 = sto_D[i];
        double d1 = sto_D[i - 1];
        double k0 = sto_K[i];
        double k1 = sto_K[i - 1];

        bu_Buy[i]  = 0;
        bu_Sell[i] = 0;

        if (k0 > d0 && k1 < d1 && k1 < ZoneLowPer && d1 < ZoneLowPer) {
            bu_Buy[i] = 100;
            int n = i - 1;
            while (bu_Buy[n] == 0) n--;
            if (modeone && trend == 1) bu_Buy[n] = 0;
            trend = 1;

            if (newCandle.IsNewCandle()) Notifications(0);
        }

        if (k0 < d0 && k1 > d1 && k1 > ZoneHighPer && d1 > ZoneHighPer) {
            bu_Sell[i] = 100;
            int n = i - 1;
            while (bu_Sell[n] == 0) n--;
            if (modeone && trend == -1) bu_Sell[n] = 0;
            trend = -1;

            if (newCandle.IsNewCandle()) Notifications(1);        
        }
    }

    return (rates_total);
}
// ------------------------------------------------------------------


void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

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