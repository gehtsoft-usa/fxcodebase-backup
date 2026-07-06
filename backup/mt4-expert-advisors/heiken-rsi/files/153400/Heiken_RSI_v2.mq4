// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74367

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
#property strict
#property indicator_separate_window
#property indicator_buffers 23
#property indicator_plots 13
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

input int RSIPeriods = 5; // RSI Periods
input bool smoothRSI_ON = true; // Smooth RSI:
input int haPeriod = 14; // HA Periods:
input int smoothPeriods = 1; // HA Smooth Periods:

double smoothedRSI [];
double Positive [];

double rsi [];
double rsi_high [];
double rsi_low [];
double rsi_close [];
double rsi_open [];

//--- indicator buffers
double _up_BodyHigh [];
double _up_BodyLow [];
double _up_high [];
double _up_basehigh [];
double _up_low [];
double _up_baselow [];

double _dn_BodyHigh [];
double _dn_BodyLow [];
double _dn_high [];
double _dn_basehigh [];
double _dn_low [];
double _dn_baselow [];

// To Show in Data Window
double _open [];
double _high [];
double _low [];
double _close [];

// ------------------------------------------------------------------
input string T2 = "== Set Colors ==";  // ————————————
input color  CandleUpClr = LimeGreen;             // Candle Up Color:
input color  CandleDnClr = Crimson;              // Candle Down Color:

string T1 = "== Notifications ==";  // ————————————
bool   notifications = false;                  // Notifications On?
bool   desktop_notifications = false;                  // Desktop MT4 Notifications
bool   email_notifications = false;                  // Email Notifications
bool   push_notifications = false;                  // Push Mobile Notifications
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
        _symbol = Symbol();
        _tf = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if(_currentCandles > _initialCandles)
        {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

// ------------------------------------------------------------------
// NOTE: oninit
int OnInit()
{

    // tomar el color de background del chart
    color backColor = ChartGetInteger(0, CHART_COLOR_BACKGROUND);

    //--- indicator buffers mapping

    int n = 0;

    // Up Candles:
    SetIndexBuffer(n, _up_high, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _up_basehigh, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _up_BodyHigh, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _up_BodyLow, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _up_low, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _up_baselow, INDICATOR_DATA);n++;

    // Down Candles:
    SetIndexBuffer(n, _dn_high, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _dn_basehigh, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _dn_BodyHigh, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _dn_BodyLow, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _dn_low, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _dn_baselow, INDICATOR_DATA);n++;

    SetIndexBuffer(n, _open, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _high, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _low, INDICATOR_DATA);n++;
    SetIndexBuffer(n, _close, INDICATOR_DATA);n++;

    SetIndexBuffer(n, rsi, INDICATOR_DATA); n++;

    SetIndexBuffer(n, Positive, INDICATOR_DATA); n++;
    SetIndexBuffer(n, smoothedRSI, INDICATOR_DATA); n++;

    SetIndexBuffer(n, rsi_low, INDICATOR_DATA); n++;
    SetIndexBuffer(n, rsi_high, INDICATOR_DATA); n++;
    SetIndexBuffer(n, rsi_open, INDICATOR_DATA); n++;
    SetIndexBuffer(n, rsi_close, INDICATOR_DATA); n++;

    n = 0;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 1, CandleUpClr);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 1, backColor);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 3, CandleUpClr);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 3, backColor);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 1, CandleUpClr);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 1, backColor);n++;

    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 1, CandleDnClr);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 1, backColor);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 3, CandleDnClr);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 3, backColor);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 1, CandleDnClr);n++;
    SetIndexStyle(n, DRAW_HISTOGRAM, EMPTY, 1, backColor);n++;

    SetIndexStyle(n, DRAW_NONE);n++;
    SetIndexStyle(n, DRAW_NONE);n++;
    SetIndexStyle(n, DRAW_NONE);n++;
    SetIndexStyle(n, DRAW_NONE);n++;

    SetIndexStyle(n, DRAW_LINE, EMPTY, 2, RoyalBlue);n++; // RSI

    SetIndexStyle(n, DRAW_NONE);n++;
    SetIndexStyle(n, DRAW_NONE);n++;
    SetIndexStyle(n, DRAW_NONE);n++;
    SetIndexStyle(n, DRAW_NONE);n++;
    SetIndexStyle(n, DRAW_NONE);n++;
    SetIndexStyle(n, DRAW_NONE);n++;

    n = 0;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, NULL);n++;
    SetIndexLabel(n, "Open");n++;
    SetIndexLabel(n, "High");n++;
    SetIndexLabel(n, "Low");n++;
    SetIndexLabel(n, "Close");n++;


    SetLevelValue(0, 0);
    SetLevelValue(1, 20);
    SetLevelValue(2, 30);
    SetLevelValue(3, -20);
    SetLevelValue(4, -30);
    SetLevelValue(5, -50);
    SetLevelStyle(STYLE_DOT, 1, C'50,50,50');


    IndicatorDigits(_Digits);
    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
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
    int start, i;
    if(prev_calculated == 0) { start = rates_total - 100; }
    else { start = rates_total - (prev_calculated - 1); }

    for(i = start; i >= 0; i--)
    {

        // RSI
        double _rsi = iRSI(NULL, 0, RSIPeriods, PRICE_CLOSE, i) - 50;
        smoothedRSI[i] = smoothedRSI[i + 1] == EMPTY_VALUE ? _rsi : (_rsi + smoothedRSI[i + 1]) / 2;

        if(smoothRSI_ON) {
            rsi[i] = smoothedRSI[i];
        }
        else{
            rsi[i] = iRSI(NULL, 0, RSIPeriods, PRICE_CLOSE, i) - 50;
        }

        rsi_high[i] = iRSI(NULL, 0, haPeriod, PRICE_CLOSE, i);
        rsi_low[i] = iRSI(NULL, 0, haPeriod, PRICE_CLOSE, i);
        rsi_close[i] = iRSI(NULL, 0, haPeriod, PRICE_CLOSE, i);
        rsi_open[i] = iRSI(NULL, 0, haPeriod, PRICE_CLOSE, i);

        // Candles values
        double __high = fmax(rsi_high[i] - 50, rsi_low[i] - 50);
        double __low = fmin(rsi_high[i] - 50, rsi_low[i] - 50);

        _close[i] = (rsi_close[i + 1] - 50 + __high + __low + rsi_close[i] - 50) / 4;
        int smoother = smoothPeriods <= 0 ? 1 : smoothPeriods;
        _open[i] = (_open[i + 1] * smoother + _close[i + 1]) / (smoother + 1);

        _high[i] = MathMax(__high, MathMax(_open[i], _close[i]));
        _low[i] = MathMin(__low, MathMin(_open[i], _close[i]));


        //--- DRAW CANDLES
        // Up Candle
        if(_close[i] > 0)
            if(_open[i] < _close[i])
            {
                _up_BodyHigh[i] = _close[i];
                _up_BodyLow[i] = _open[i];
            }
        if(_close[i] <= 0)
            if(_open[i] < _close[i])
            {
                _up_BodyHigh[i] = _open[i];
                _up_BodyLow[i] = _close[i];
            }

        // Down Candle
        if(_close[i] > 0)
            if(_open[i] > _close[i])
            {
                _dn_BodyHigh[i] = _open[i];
                _dn_BodyLow[i] = _close[i];
            }
        if(_close[i] <= 0)
            if(_open[i] > _close[i])
            {
                _dn_BodyHigh[i] = _close[i];
                _dn_BodyLow[i] = _open[i];
            }


    }
    return (rates_total);
}

// ------------------------------------------------------------------


void Notifications(int type)
{
    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

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
    switch(lPeriod)
    {
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