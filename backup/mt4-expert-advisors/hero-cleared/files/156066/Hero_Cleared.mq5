//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75045

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window

#property indicator_buffers 4
#property indicator_plots 4
#property indicator_label1 "Line1"
#property indicator_type1  DRAW_LINE
#property indicator_color1 LimeGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line2"
#property indicator_type2  DRAW_LINE
#property indicator_color2 LimeGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_label3 "Arrow Up"
#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 0
#property indicator_label4 "Arrow Down"
#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 0

// NOTE: Inputs
// ------------------------------------------------------------------
int Tenkan_per = 5;  // Tekan
int Kijun_per  = 34; // Kijun

// ------------------------------------------------------------------
int          Period                = 10;                    // Indicator Periods
input string T0                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = DodgerBlue;            // Arrow Up Color:
color        ArrowDnClr            = Red;                   // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double tenkan_line[];
double kijun_line[];
double ArrowUp[];
double ArrowDn[];

int h_ichi;
int h_ichi1;
int h_ichi2;
int h_SMA_M;
int h_SMA_1;
int h_MACD_Now2;
int h_SMA_Ma;
int h_SMA_C;
int h_MACD_M;
int h_MACD_S;
int h_STD0;
int h_STD1;
int h_wpr;

// ------------------------------------------------------------------
void OnInit()
{
    //--- indicator short name
    string short_name = "Line Indicator";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    SetIndexBuffer(0, tenkan_line);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Period);
    SetIndexBuffer(1, kijun_line);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Period);

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_ARROW, 233);
    PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(3, PLOT_ARROW, 234);
    PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);

    h_ichi      = iIchimoku(NULL, 0, Tenkan_per, Kijun_per, 1);
    h_ichi1     = iIchimoku(NULL, 0, 9, 1, 52);
    h_ichi2     = iIchimoku(NULL, 0, 9, 1, 52);
    h_SMA_M     = iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_MEDIAN);
    h_SMA_1     = iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE);
    h_SMA_Ma    = iMA(NULL, 0, 8, 7, MODE_SMA, PRICE_MEDIAN);
    h_SMA_C     = iMA(NULL, 0, 6, 2, MODE_SMA, PRICE_CLOSE);
    h_MACD_Now2 = iMACD(NULL, 0, 1, 4, 1, PRICE_CLOSE);
    h_MACD_M    = iMACD(NULL, 0, 15, 220, 80, PRICE_CLOSE);
    h_MACD_S    = iMACD(NULL, 0, 15, 220, 80, PRICE_MEDIAN);
    h_STD0      = iStdDev(NULL, 0, 4, 15, MODE_SMA, PRICE_MEDIAN);
    h_STD1      = iStdDev(NULL, 0, 4, 1, MODE_SMA, PRICE_MEDIAN);
    h_wpr       = iWPR(NULL, 0, 2);
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

        tenkan_line[i] = tenkan(i);
        kijun_line[i]  = kijun(i);
        ArrowUp[i]     = EMPTY_VALUE;
        ArrowDn[i]     = EMPTY_VALUE;

        if (haveSignalUp(i)) {
            ArrowUp[i] = tenkan(i);
        }

        if (haveSignalDown(i)) {
            ArrowDn[i] = tenkan(i);
        }
    }

    return (rates_total);
}
// ------------------------------------------------------------------

double tenkan(int i)
{
    int    shift = Bars(NULL, 0) - (i + 1);
    double value[1];
    int    copy = CopyBuffer(h_ichi, 0, shift, 1, value);
    if (copy > 0) {
        return value[0];
    }
    return -1;
}
double kijun(int i)
{
    int    shift = Bars(NULL, 0) - (i + 1);
    double value[1];
    int    copy = CopyBuffer(h_ichi, 1, shift, 1, value);
    if (copy > 0) {
        return value[0];
    }
    return -1;
}

double indi(int handle, int bu, int i)
{
    int    shift = Bars(NULL, 0) - (i + 1);
    double value[1];
    int    copy = CopyBuffer(handle, bu, shift, 1, value);
    if (copy > 0) {
        return value[0];
    }
    return -1;
}

bool haveSignalUp(int i)
{
    i++;
    double ichi2     = indi(h_ichi2, CHIKOUSPAN_LINE, i - 4);
    double ichi1     = indi(h_ichi2, CHIKOUSPAN_LINE, i - 3);
    double SMA_M     = indi(h_SMA_M, 0, i - 1);
    double SMA_1     = indi(h_SMA_1, 0, i - 2);
    double MACD_Now2 = indi(h_MACD_Now2, SIGNAL_LINE, i - 3); // creo que le falta el bufer
    double SMA_Ma    = indi(h_SMA_Ma, 0, i - 1);
    double SMA_C     = indi(h_SMA_C, 0, i - 1);
    double MACD_M    = indi(h_MACD_M, MAIN_LINE, i - 1);
    double MACD_S    = indi(h_MACD_S, SIGNAL_LINE, i - 1);
    double STD0      = indi(h_STD0, 0, i - 1);
    double STD1      = indi(h_STD1, 0, i - 2);
    double wpr       = indi(h_wpr, 0, i - 1);

    if (ichi2 < ichi1 && SMA_1 < SMA_M && MACD_Now2 > 0 && SMA_C > SMA_Ma && wpr > -50) {
        return true;
    }

    return false;
}

bool haveSignalDown(int i)
{
    i++;
    double ichi2     = indi(h_ichi2, CHIKOUSPAN_LINE, i - 4);
    double ichi1     = indi(h_ichi2, CHIKOUSPAN_LINE, i - 3);
    double SMA_M     = indi(h_SMA_M, 0, i - 1);
    double SMA_1     = indi(h_SMA_1, 0, i - 2);
    double MACD_Now2 = indi(h_MACD_Now2, SIGNAL_LINE, i - 3); // creo que le falta el bufer
    double SMA_Ma    = indi(h_SMA_Ma, 0, i - 1);
    double SMA_C     = indi(h_SMA_C, 0, i - 1);
    double MACD_M    = indi(h_MACD_M, MAIN_LINE, i - 1);
    double MACD_S    = indi(h_MACD_S, SIGNAL_LINE, i - 1);
    double STD0      = indi(h_STD0, 0, i - 1);
    double STD1      = indi(h_STD1, 0, i - 2);
    double wpr       = indi(h_wpr, 0, i - 1);

    if (ichi2 > ichi1 && SMA_1 > SMA_M && MACD_Now2 < 0 && SMA_C < SMA_Ma && wpr < -50) {
        return true;
    }

    return false;
}

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