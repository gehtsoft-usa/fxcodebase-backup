//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76153

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

#import "mmlib.dll"
bool sgemm(uint flags, matrix<float> &C, const matrix<float> &A, const matrix<float> &B, ulong M, ulong N, ulong K, float alpha, float beta);
#import

#property indicator_separate_window

#property indicator_buffers 9
#property indicator_plots 9

#property indicator_label8 "LineColor"
#property  indicator_type8 DRAW_COLOR_LINE
#property indicator_color8 Crimson, Green
#property indicator_style8 STYLE_SOLID

// #property indicator_color3 Blue
// #property indicator_color4 FireBrick
// #property indicator_color5 Green
// #property indicator_color6 Black
// #property indicator_color7 Black
// #property indicator_color8 Black
// #property indicator_color9 Maroon
// #property indicator_color10 DarkGreen

#property indicator_level1 80.0
#property indicator_level2 90.0
#property indicator_level3 50.0
#property indicator_level4 20.0
#property indicator_level5 10.0
#property indicator_levelstyle 2
#property indicator_levelcolor Black

// NOTE: Inputs
// ------------------------------------------------------------------
string T1                    = "== Notifications =="; // Notifications
bool   notifications         = false;                 // Notifications On?
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications

input string trsi           = "== RSI Setup =="; // ————————————————————————
input int    rsi_period     = 14;                // Period
input int    rsi_level_buy  = 30;                // Level Buy
input int    rsi_level_sell = 70;                // Level Sell

int    handle_rsi = 0;
void   setHandleRSI() { handle_rsi = iRSI(NULL, 0, rsi_period, PRICE_CLOSE); }
double RSI(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle - 1;
    // int    shift = candle;
    int copy = CopyBuffer(handle_rsi, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

// Note: Desviacion
input int    uHalfLength = 12;
int          HalfLength;
input int    DevPeriod    = 100;
input double DeviationInt = 1;
input double DeviationExt = 1.5;
input double Level        = 30;

vector vds(DevPeriod);

// NOTE: Buffers
//--- indicator buffers

double rsi[];
double ds[];
double lineColor[];

double histoGreen[];
double histoRed[];

double band_ext_up[];
double band_ext_dn[];
double band_int_up[];
double band_int_dn[];

// Note: oninit
// ------------------------------------------------------------------
void OnInit()
{
    setHandleRSI();
    HalfLength = MathMax(uHalfLength, 1);

    int n = 0;
    
    SetIndexBuffer(n, histoGreen, INDICATOR_DATA);
    PlotIndexSetInteger(n, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
    PlotIndexSetDouble(n, PLOT_EMPTY_VALUE, 0);
    PlotIndexSetInteger(n,PLOT_LINE_WIDTH,3); PlotIndexSetInteger(n,PLOT_LINE_STYLE,STYLE_SOLID); PlotIndexSetInteger(n,PLOT_LINE_COLOR,Green); 
    
    n++;
    SetIndexBuffer(n, histoRed, INDICATOR_DATA);
    PlotIndexSetInteger(n, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
    PlotIndexSetDouble(n, PLOT_EMPTY_VALUE, 0);
    PlotIndexSetInteger(n,PLOT_LINE_WIDTH,3); PlotIndexSetInteger(n,PLOT_LINE_STYLE,STYLE_SOLID); PlotIndexSetInteger(n,PLOT_LINE_COLOR,FireBrick); 
    
    n++;
    SetIndexBuffer(n, rsi, INDICATOR_DATA); 
    PlotIndexSetInteger(n, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(n,PLOT_LINE_WIDTH,2); PlotIndexSetInteger(n,PLOT_LINE_STYLE,STYLE_SOLID); PlotIndexSetInteger(n,PLOT_LINE_COLOR,Blue); 
    
    n++;
    SetIndexBuffer(n, band_ext_up, INDICATOR_DATA); 
    PlotIndexSetInteger(n, PLOT_DRAW_TYPE, DRAW_LINE);PlotIndexSetInteger(n,PLOT_LINE_WIDTH,1); PlotIndexSetInteger(n,PLOT_LINE_STYLE,STYLE_SOLID); PlotIndexSetInteger(n,PLOT_LINE_COLOR,Black); 
    n++;
    SetIndexBuffer(n, band_ext_dn, INDICATOR_DATA); 
    PlotIndexSetInteger(n, PLOT_DRAW_TYPE, DRAW_LINE);PlotIndexSetInteger(n,PLOT_LINE_WIDTH,1); PlotIndexSetInteger(n,PLOT_LINE_STYLE,STYLE_SOLID); PlotIndexSetInteger(n,PLOT_LINE_COLOR,Black);
    
    n++;
    SetIndexBuffer(n, band_int_up, INDICATOR_DATA); 
    PlotIndexSetInteger(n, PLOT_DRAW_TYPE, DRAW_LINE);PlotIndexSetInteger(n,PLOT_LINE_WIDTH,1); PlotIndexSetInteger(n,PLOT_LINE_STYLE,STYLE_DOT); PlotIndexSetInteger(n,PLOT_LINE_COLOR,FireBrick);
    n++;
    SetIndexBuffer(n, band_int_dn, INDICATOR_DATA); 
    PlotIndexSetInteger(n, PLOT_DRAW_TYPE, DRAW_LINE);PlotIndexSetInteger(n,PLOT_LINE_WIDTH,1); PlotIndexSetInteger(n,PLOT_LINE_STYLE,STYLE_DOT); PlotIndexSetInteger(n,PLOT_LINE_COLOR,Green);
    
    
    n++;
    SetIndexBuffer(n, ds, INDICATOR_DATA); 
    PlotIndexSetInteger(n, PLOT_DRAW_TYPE, DRAW_COLOR_LINE);PlotIndexSetInteger(n,PLOT_LINE_WIDTH,2); PlotIndexSetInteger(n,PLOT_LINE_STYLE,STYLE_SOLID);
    n++;
    SetIndexBuffer(n, lineColor);


    ArrayInitialize(histoGreen, 0);
    ArrayInitialize(histoRed, 0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int j, k;
    // clang-format off
    int start;
    if (prev_calculated > 1) start = prev_calculated - 1; else { start = Bars(_Symbol, _Period) - 500; }
    // clang-format on


    // Note: main loop
    for (int i = start; i < rates_total && !IsStopped(); i++) {
        rsi[i] = RSI(i);

        // Note: calculo la desviacion
        for (int n = 0; n < vds.Size(); n++) {
            vds[n] = rsi[i - n];
        }
        double dev = vds.Std(); // comprobar que sea igual al que esta calculando en mt4;

        // Note: linea del medio
        double sum  = (HalfLength + 1) * rsi[i];
        double sumw = (HalfLength + 1);

        for (j = 1, k = HalfLength; j <= HalfLength; j++, k--) {
            sum += k * rsi[i - j];
            sumw += k;

            int    bars = Bars(NULL, 0);
            if (j <= bars-i) {
                sum += k * rsi[i - j];
                sumw += k;
            }
        }

        ds[i] = sum / sumw;

        double ds0 = ds[i];
        double ds1 = ds[i - 1];
        double ds2 = ds[i - 2];

        lineColor[i] = (ds0 > ds1 && ds1 > ds2) ? 1 : 0;

        band_ext_up[i] = ds[i] + dev * DeviationExt;
        band_ext_dn[i] = ds[i] - dev * DeviationExt;

        band_int_up[i] = ds[i] + dev * DeviationInt;
        band_int_dn[i] = ds[i] - dev * DeviationInt;

        histoGreen[i] = 0;
        histoRed[i]   = 0;

        if (band_ext_up[i] >= (100 - Level)) {
            histoGreen[i] = band_ext_up[i];
        } else
        if (band_ext_dn[i] <= (0 + Level)) {
            histoRed[i] = band_ext_dn[i];
        }
    }

    return (rates_total);
}
// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    int shift = iBars(_Symbol, Period()) - i;
    if (iOpen(_Symbol, Period(), shift) < iClose(_Symbol, Period(), shift)) {
        return true;
    }

    return false;
}
bool haveSignalDown(int i)
{
    int shift = iBars(_Symbol, Period()) - i;
    if (iOpen(_Symbol, Period(), shift) > iClose(_Symbol, Period(), shift)) {
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76153

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