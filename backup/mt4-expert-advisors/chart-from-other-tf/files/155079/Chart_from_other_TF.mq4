// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74798

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 15
#property indicator_plots 15
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_style3 STYLE_SOLID
#property indicator_type4  DRAW_HISTOGRAM
#property indicator_style4 STYLE_SOLID
#property indicator_type5  DRAW_HISTOGRAM
#property indicator_style5 STYLE_SOLID
#property indicator_type6  DRAW_HISTOGRAM
#property indicator_style6 STYLE_SOLID

#property indicator_type7  DRAW_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_type8  DRAW_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_type9  DRAW_LINE
#property indicator_style9 STYLE_DOT

//--- indicator buffers
double _up_BodyHigh[];
double _up_BodyLow[];
double _up_high[];
double _up_basehigh[];
double _up_low[];
double _up_baselow[];

double _dn_BodyHigh[];
double _dn_BodyLow[];
double _dn_high[];
double _dn_basehigh[];
double _dn_low[];
double _dn_baselow[];

double emaFast[], emaMedium[], emaSlow[];

// To Show in Data Window
double _open[];
double _high[];
double _low[];
double _close[];

// ------------------------------------------------------------------
input ENUM_TIMEFRAMES uTimeFrame  = PERIOD_M15; // Timeframe
input int             candlesBack = 100;        // Candles Back

input string             maFast_title          = "== EMA Fast Setup ==";   // == Moving Average Setup ==
input bool               emaFastON             = true;                     // Show Ema Fast?
input int                maFast_Period         = 13;                       // Period
int                      maFast_Shift          = 0;                        // Ma Shift
input ENUM_MA_METHOD     maFast_Method         = MODE_EMA;                 // Method
input ENUM_APPLIED_PRICE maFast_AppliedPrice   = PRICE_CLOSE;              // Applied Price
input string             maMedium_title        = "== EMA Medium Setup =="; // == Moving Average Setup ==
input bool               emaMediumON           = true;                     // Show Ema Medium?
input int                maMedium_Period       = 34;                       // Period
int                      maMedium_Shift        = 0;                        // Ma Shift
input ENUM_MA_METHOD     maMedium_Method       = MODE_EMA;                 // Method
input ENUM_APPLIED_PRICE maMedium_AppliedPrice = PRICE_CLOSE;              // Applied Price
input string             maSlow_title          = "== EMA Slow Setup ==";   // == Moving Average Setup ==
input bool               emaSlowON             = true;                     // Show Ema Slow?
input int                maSlow_Period         = 136;                      // Period
int                      maSlow_Shift          = 0;                        // Ma Shift
input ENUM_MA_METHOD     maSlow_Method         = MODE_EMA;                 // Method
input ENUM_APPLIED_PRICE maSlow_AppliedPrice   = PRICE_CLOSE;              // Applied Price

input string T2          = "== Set Colors =="; // ————————————
input color  CandleUpClr = clrBlue;            // Candle Up Color:
input color  CandleDnClr = clrRed;             // Candle Down Color:

string T1                    = "== Notifications =="; // ————————————
bool   notifications         = false;                 // Notifications On?
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications
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

// ------------------------------------------------------------------
int OnInit()
{
    // tomar el color de background del chart
    color backColor = ChartGetInteger(0, CHART_COLOR_BACKGROUND);
    IndicatorShortName("MultiTimeframe Chart | TF: " + GetTimeFrame(uTimeFrame) +" | Candles: "+(string)candlesBack);

    //--- indicator buffers mapping

    // Up Candles:
    SetIndexBuffer(0, _up_high, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 1, CandleUpClr);
    SetIndexBuffer(1, _up_basehigh, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 1, backColor);
    SetIndexBuffer(2, _up_BodyHigh, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, 3, CandleUpClr);
    SetIndexBuffer(3, _up_BodyLow, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, 3, backColor);
    SetIndexBuffer(4, _up_low, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_HISTOGRAM, EMPTY, 1, CandleUpClr);
    SetIndexBuffer(5, _up_baselow, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_HISTOGRAM, EMPTY, 1, backColor);

    // Down Candles:
    SetIndexBuffer(6, _dn_high, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_HISTOGRAM, EMPTY, 1, CandleDnClr);
    SetIndexBuffer(7, _dn_basehigh, INDICATOR_DATA);
    SetIndexStyle(7, DRAW_HISTOGRAM, EMPTY, 1, backColor);
    SetIndexBuffer(8, _dn_BodyHigh, INDICATOR_DATA);
    SetIndexStyle(8, DRAW_HISTOGRAM, EMPTY, 3, CandleDnClr);
    SetIndexBuffer(9, _dn_BodyLow, INDICATOR_DATA);
    SetIndexStyle(9, DRAW_HISTOGRAM, EMPTY, 3, backColor);
    SetIndexBuffer(10, _dn_low, INDICATOR_DATA);
    SetIndexStyle(10, DRAW_HISTOGRAM, EMPTY, 1, CandleDnClr);
    SetIndexBuffer(11, _dn_baselow, INDICATOR_DATA);
    SetIndexStyle(11, DRAW_HISTOGRAM, EMPTY, 1, backColor);

    SetIndexLabel(0, NULL);
    SetIndexLabel(1, NULL);
    SetIndexLabel(2, NULL);
    SetIndexLabel(3, NULL);
    SetIndexLabel(4, NULL);
    SetIndexLabel(5, NULL);
    SetIndexLabel(6, NULL);
    SetIndexLabel(7, NULL);
    SetIndexLabel(8, NULL);
    SetIndexLabel(9, NULL);
    SetIndexLabel(10, NULL);
    SetIndexLabel(11, NULL);

    SetIndexBuffer(12, emaFast, INDICATOR_DATA);
    SetIndexStyle(12, DRAW_LINE, STYLE_SOLID, 1, Crimson);
    SetIndexBuffer(13, emaMedium, INDICATOR_DATA);
    SetIndexStyle(13, DRAW_LINE, STYLE_SOLID, 1, RoyalBlue);
    SetIndexBuffer(14, emaSlow, INDICATOR_DATA);
    SetIndexStyle(14, DRAW_LINE, STYLE_DOT , 1, Navy);

    if(!emaFastON)SetIndexStyle(12, DRAW_NONE);
    if(!emaMediumON)SetIndexStyle(13, DRAW_NONE);
    if(!emaSlowON)SetIndexStyle(14, DRAW_NONE);


    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = candlesBack;
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = start; i >= 0; i--) {
        double op = iOpen(Symbol(), uTimeFrame, i);
        double hi = iHigh(Symbol(), uTimeFrame, i);
        double lo = iLow(Symbol(), uTimeFrame, i);
        double cl = iClose(Symbol(), uTimeFrame, i);

        // Up Candle
        if (op < cl) {
            _up_BodyHigh[i] = cl;
            _up_BodyLow[i]  = op;

            _up_high[i] = hi;
            _up_low[i]  = op;

            _up_basehigh[i] = cl;
            _up_baselow[i]  = lo;
        }

        // Down Candle
        if (op > cl) {
            _dn_BodyHigh[i] = op;
            _dn_BodyLow[i]  = cl;

            _dn_high[i] = hi;
            _dn_low[i]  = cl;

            _dn_basehigh[i] = op;
            _dn_baselow[i]  = lo;
        }

        // NOTE: emas
        emaFast[i]   = iMA(NULL, uTimeFrame, maFast_Period, maFast_Shift, maFast_Method, maFast_AppliedPrice, i);
        emaMedium[i] = iMA(NULL, uTimeFrame, maMedium_Period, maMedium_Shift, maMedium_Method, maMedium_AppliedPrice, i);
        emaSlow[i]   = iMA(NULL, uTimeFrame, maSlow_Period, maSlow_Shift, maSlow_Method, maSlow_AppliedPrice, i);
    }
    return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    // TODO: signal up
    return iOpen(NULL, 0, i) > iClose(NULL, 0, i + 1);
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    return iOpen(NULL, 0, i) < iClose(NULL, 0, i + 1);
}

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if (!notifications)
        return;
    if (desktop_notifications)
        Alert(text);
    if (push_notifications)
        SendNotification(text);
    if (email_notifications)
        SendMail("MetaTrader Notification", text);
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