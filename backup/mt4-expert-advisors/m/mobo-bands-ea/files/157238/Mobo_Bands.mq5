// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=157070#p157070



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

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots 6

#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 Gray
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line Dn"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Gray
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Line Midle"
#property  indicator_type3  DRAW_LINE
#property indicator_color3 RoyalBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

#property indicator_label4 "Arrow Up"
#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrBlue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Arrow Down"
#property indicator_type5  DRAW_ARROW
#property indicator_color5 clrRed
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1

#property indicator_label6 "Line3"
#property  indicator_type6  DRAW_LINE
#property indicator_color6 Gold
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

// Mark: buffers
double LineUp[];
double LineDn[];
double LineMidle[];
double ArrowUp[];
double ArrowDn[];
double price[];
double dpo[];
int    lastSignal = 0;

// NOTE: Inputs
// ------------------------------------------------------------------
input int    periods               = 13;                    // Periods
input int    moboLength            = 10;                    // Mobo Length :
input double nStd                  = 1;                     //  Standard Deviation Bands:
input string T0                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

// ------------------------------------------------------------------
void OnInit()
{
    //--- indicator short name
    SetIndexBuffer(0, LineUp);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, periods);
    SetIndexBuffer(1, LineDn);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, periods);
    SetIndexBuffer(2, LineMidle);
    PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, periods);

    SetIndexBuffer(3, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(3, PLOT_ARROW, 233);
    PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 10);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowUpClr);

    SetIndexBuffer(4, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(4, PLOT_ARROW, 234);
    PlotIndexSetInteger(4, PLOT_ARROW_SHIFT, -10);
    PlotIndexSetInteger(4, PLOT_LINE_COLOR, ArrowDnClr);

    SetIndexBuffer(5, dpo, INDICATOR_DATA);
    PlotIndexSetInteger(5, PLOT_LINE_COLOR, Gold);

    SetIndexBuffer(6, price, INDICATOR_CALCULATIONS);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (rates_total < periods) return (0);

    int start, i;
    if (prev_calculated > 1)
        start = prev_calculated - 1;
    else {
        start = periods + 1;
    }

    for (i = start; i < rates_total; i++) {
        price[i] = (high[i] + low[i]) / 2;
    }

    for (i = start; i < rates_total; i++) {
    
        double sumPrice = 0;
        ArrowUp[i] = EMPTY_VALUE;
        ArrowDn[i] = EMPTY_VALUE;
    
        for (int n = 1; n <= periods; n++)
            sumPrice += price[i - n];
        double xsma = sumPrice / periods;
        dpo[i]      = price[i] - xsma;

        double sumDpo = 0;
        for (int n = 1; n <= moboLength; n++)
            sumDpo += dpo[i - n];
        LineMidle[i] = sumDpo / moboLength;

        double midle[];
        ArrayResize(midle, moboLength);
        for (int n = 0; n < moboLength; n++)
            midle[n] = LineMidle[i - n];

        double std = MathStandardDeviation(midle);
        LineUp[i]  = LineMidle[i] + (std * nStd);
        LineDn[i]  = LineMidle[i] - (std * nStd);

        if (dpo[i - 1] > LineUp[i - 1] && dpo[i - 2] <= LineUp[i - 2] && (lastSignal == -1 || lastSignal == 0)) {
            ArrowUp[i - 1] = LineDn[i - 1];
            notify(0);
            lastSignal = 1;
        }

        if (dpo[i - 1] < LineDn[i - 1] && dpo[i - 2] >= LineDn[i - 2] && (lastSignal == 1 || lastSignal == 0)) {
            ArrowDn[i - 1] = LineUp[i - 1];
            notify(1);
            lastSignal = -1;
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

void notify(int type)
{
    if (newCandle.IsNewCandle()) {
        Notifications(type);
    }
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

double MathStandardDeviation(const double &array[])
{
    int size = ArraySize(array);
    // if (size <= 1) return ();
    //--- calculate mean
    double mean = 0.0;
    for (int i = 0; i < size; i++)
        mean += array[i];
    //--- average mean
    mean = mean / size;
    //--- calculate standard deviation
    double sdev = 0;
    for (int i = 0; i < size; i++)
        sdev += MathPow(array[i] - mean, 2);
    //--- return standard deviation
    return MathSqrt(sdev / (size - 1));
}
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