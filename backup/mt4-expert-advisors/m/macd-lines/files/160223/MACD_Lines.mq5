//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75722

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window

#property indicator_buffers 6
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
int periods = 100;

#define Section_MACD
#ifdef Section_MACD

input string tmacd   = "== MACD Setup =="; // ————————————————————————
input int    _fast   = 12;                 // Fast
input int    _slow   = 26;                 // Slow
input int    _signal = 9;                  // Signal
input int    maxBar  = 300;                // Max bars

int  handle_macd = 0;
void setHandleMACD() { handle_macd = iMACD(NULL, 0, _fast, _slow, _signal, PRICE_CLOSE); }

double macd_main(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int    shift = candle;
    int copy = CopyBuffer(handle_macd, MAIN_LINE, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

double macd_signal(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int    shift = candle;
    int copy = CopyBuffer(handle_macd, SIGNAL_LINE, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

#endif

// -------------------------------------------------------------

input string T0                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

int macd_;

// NOTE: Buffers
//--- indicator buffers
double LineUp[];
double LineDn[];
double ArrowUp[];
double ArrowDn[];
double Gcross[];
double Dcross[];
// ------------------------------------------------------------------
void OnInit()
{
    //--- indicator short name
    string short_name = "Line Indicator";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    SetIndexBuffer(0, LineUp);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, periods);
    SetIndexBuffer(1, LineDn);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, periods);

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_ARROW, 233);
    PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(3, PLOT_ARROW, 234);
    PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);

    if (!ArrowsOn) {
        PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
        PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
    }
    SetIndexBuffer(4, Gcross, INDICATOR_DATA);
    PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
    SetIndexBuffer(5, Dcross, INDICATOR_DATA);
    PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);

    setHandleMACD();
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (rates_total < periods) return (0);

    int st, i, a, b;
    int start;
    if (prev_calculated > 1) start = prev_calculated - 1; else { start = rates_total-100; }


    for (int i = start; i < rates_total && !IsStopped(); i++) {
        IsGoldenCross(i) ? Gcross[i] = 1 : Gcross[i] = EMPTY_VALUE;
        IsDeathCross(i) ? Dcross[i] = 1 : Dcross[i] = EMPTY_VALUE;
        LineUp[i] = EMPTY_VALUE;
        LineDn[i] = EMPTY_VALUE;
    }

    for (int i = start; i < rates_total && !IsStopped(); i++) {

    // for (i = st - 1; i >= 0; i--) {
        if (Gcross[i] == 1) {
            ArrowUp[i] = low[i];
            a          = i;
            b          = i;
            for (int j = i; j >= 0; j--) {
                if (Dcross[j] == 1 || j == 0) {
                    b = j;
                    break;
                }
            }
            double minPrice = FindMinPrice(a, b);
            for (int j = a; j >= b; j--) {
                LineDn[j] = minPrice;
            }
        }
        
        if (Dcross[i] == 1) {
            ArrowDn[i] = high[i];
            a          = i;
            b          = i;
            for (int j = i; j >= 0; j--) {
                if (Gcross[j] == 1 || j == 0) {
                    b = j;
                    break;
                }
            }
            double maxPrice = FindMaxPrice(a, b);
            for (int j = a; j >= b; j--) {
                LineUp[j] = maxPrice;
            }
        }


        // if (haveSignalUp(i)) {
            // ArrowUp[i - 1] = low[i - 1];
            
            // if (newCandle.IsNewCandle()) {
            //     Notifications(0);
            // }
        // }

        // if (haveSignalDown(i)) {
            // ArrowDn[i - 1] = high[i - 1];
            
            // if (newCandle.IsNewCandle()) {
                // Notifications(1);
            // }
        // }
    }

    return (rates_total);
}
// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    return IsGoldenCross(i);
}
bool haveSignalDown(int i)
{
    return IsDeathCross(i);
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsGoldenCross(int i)
{
    double macdCurrent    = macd_main(i);
    double signalCurrent  = macd_signal(i);
    double macdPrevious   = macd_main(i-1);
    double signalPrevious = macd_signal(i-1);
    return (macdPrevious < signalPrevious && macdCurrent > signalCurrent);

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDeathCross(int i)
{
    double macdCurrent    = macd_main(i);
    double signalCurrent  = macd_signal(i);
    double macdPrevious   = macd_main(i-1);
    double signalPrevious = macd_signal(i-1);
    return (macdPrevious > signalPrevious && macdCurrent < signalCurrent);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindMinPrice(int startIndex, int endIndex)
{
    int start = iBars(NULL, 0) - startIndex;
    int end   = iBars(NULL, 0) - endIndex;
    double minPrice = iLow(NULL, 0, start);
    for (int i = start; i <= end; i++) {
        if (iLow(NULL, 0, i) < minPrice) {
            minPrice = iLow(NULL, 0, i);
        }
    }
    return minPrice;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindMaxPrice(int startIndex, int endIndex)
{
    int start = iBars(NULL, 0) - startIndex;
    int end   = iBars(NULL, 0) - endIndex;
    double maxPrice = iHigh(NULL, 0, start);
    // for (int i = startIndex; i >= endIndex && i >= 0; i--) {
    for (int i = start; i <= end; i++) {
        if (iHigh(NULL, 0, i) > maxPrice) {
            maxPrice = iHigh(NULL, 0, i);
        }
    }
    return maxPrice;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75722

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+
