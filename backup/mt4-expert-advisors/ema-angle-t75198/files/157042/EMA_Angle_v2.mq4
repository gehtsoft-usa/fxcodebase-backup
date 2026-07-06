// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75198

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
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrRed
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

//--- indicator buffers
double LineUp[];
double LineDn[];
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
input string             ma_title          = "== Moving Average Setup =="; // ————————————————————————
input int                ma1_period        = 50;                           // Periods:
input ENUM_MA_METHOD     ma1_method        = MODE_EMA;                     // Method:
input ENUM_APPLIED_PRICE ma1_applied_price = PRICE_MEDIAN;                  // Applied Price:
input int                ma1_shift         = 5;                            // Shift:
input double             treshold          = 0.3;                          // Treshold
input int                qntCandles        = 3;                            // Candles in a row to Arrow:

double ma(int shift) { return iMA(NULL, 0, ma1_period, 0, ma1_method, ma1_applied_price, shift); }

string       T1                    = "== Notifications =="; // ————————————
bool         notifications         = false;                 // Notifications On?
bool         desktop_notifications = false;                 // Desktop MT4 Notifications
bool         email_notifications   = false;                 // Email Notifications
bool         push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Colors ==";    // ————————————
input color  clr_up                = clrBlue;               // Up Color:
input color  clr_down              = clrRed;                // Down Color:
input color  clr_flat              = clrYellow;             // Flat Color:
input bool   ArrowsOn              = true;                  // Arrows On?
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
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 1, clr_up);
    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 1, clr_down);

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(2, 233);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, Blue);
    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, Red);
    SetIndexArrow(3, 234);

    if (!ArrowsOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    //---
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

// clang-format off
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) { start = rates_total - ma1_period - ma1_shift; } else { start = rates_total - (prev_calculated - 1); } // clang-format on

    for (i = start; i >= 0; i--) {

        double ema   = ma(i);
        double emap  = ma(i + ma1_shift);
        double angle = ((ema - emap) / Point) ;

        if (angle > 0) {
            LineUp[i] = angle;

            if (newCandle.IsNewCandle()) {
                Notifications(0);
            }
        }

        if (angle < 0) {
            LineDn[i] = angle;

            if (newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }

        int static lastarrow = 0;
        bool up = true;
        bool dn = true;
        
        for (int n = 1; n <= qntCandles; n++)
        {
            if (angle > 0) {
                if(LineUp[i+n] < LineUp[i+n+1] || LineUp[i+n+1] == EMPTY_VALUE) {up=false;}
                if(LineUp[i+n] > LineUp[i+n+1] || LineUp[i+n+1] == EMPTY_VALUE) {dn=false;}
            }    
            if (angle < 0) {
                if(LineDn[i+n] < LineDn[i+n+1]|| LineDn[i+n+1] == EMPTY_VALUE) {up=false;}
                if(LineDn[i+n] > LineDn[i+n+1]|| LineDn[i+n+1] == EMPTY_VALUE) {dn=false;}
            }
        }

            if (angle > 0) {
                if (up == true && (lastarrow == 0 || lastarrow == -1))
                {
                    ArrowUp[i] = LineUp[i];
                    lastarrow = 1;
                }
                if (dn == true && (lastarrow == 0 || lastarrow == 1))
                {
                    ArrowDn[i] = LineUp[i];
                    lastarrow = -1;
                }
            }
                

            if (angle < 0) {
                if (up == true && (lastarrow == 0 || lastarrow == -1))
                {
                    ArrowUp[i] = LineDn[i];
                    lastarrow = 1;
                }
                if (dn == true && (lastarrow == 0 || lastarrow == 1))
                {
                    ArrowDn[i] = LineDn[i];
                    lastarrow = -1;
                }
            }
        
        




    }
    return (rates_total);
}

// ------------------------------------------------------------------

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

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