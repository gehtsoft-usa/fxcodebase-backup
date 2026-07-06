//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74429

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
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 2
#property indicator_label1 "Signal Up"
#property indicator_label2 "Signal Down"
#property indicator_label3 "QQE Up"
#property indicator_label4 "QQE Down"
#property indicator_label5 "SSL Up"
#property indicator_label6 "SLL Down"
//--- 

//--- indicator buffers
double signalUp [];
double signalDn [];
double qqeUp [];
double qqeDn [];
double sslUp [];
double sslDn [];


// ------------------------------------------------------------------
#define _QQE
#ifdef _QQE


input string TQQE = "== QQE Setup ==";    // ————————————
input int sf = 5;// SF

string qqefile = "QQE.ex4";
input int qqeFastBuffer = 0;
input int qqeSlowBuffer = 1;

double qqeFast(int i)
{
    return iCustom(Symbol(), 0, qqefile, sf, qqeFastBuffer, i);
}
double qqeSlow(int i)
{
    return iCustom(Symbol(), 0, qqefile, sf, qqeSlowBuffer, i);
}
double qqeFastPrev(int i)
{
    return iCustom(Symbol(), 0, qqefile, sf, qqeFastBuffer, i + 1);
}
double qqeSlowPrev(int i)
{
    return iCustom(Symbol(), 0, qqefile, sf, qqeSlowBuffer, i + 1);
}

bool qqeCrossUp(int i)
{
    if(qqeFast(i) > qqeSlow(i) && qqeFastPrev(i) <= qqeSlowPrev(i))
    {
        return true;
    }
    return false;
}
bool qqeCrossDn(int i)
{
    if(qqeFast(i) < qqeSlow(i) && qqeFastPrev(i) >= qqeSlowPrev(i))
    {
        return true;
    }
    return false;
}


#endif


// ------------------------------------------------------------------
#define _SSL
#ifdef _SSL


input string TSSL = "== SSL Setup ==";    // ————————————
string sslfile = "SSL.ex4";
input int  Lb  =10;
int sslFastBuffer = 1;
int sslSlowBuffer = 0;

double sslFast(int i)
{
    return iCustom(Symbol(), 0, sslfile, Lb, sslFastBuffer, i);
}
double sslSlow(int i)
{
    return iCustom(Symbol(), 0, sslfile, Lb, sslSlowBuffer, i);
}
double sslFastPrev(int i)
{
    return iCustom(Symbol(), 0, sslfile, Lb, sslFastBuffer, i + 1);
}
double sslSlowPrev(int i)
{
    return iCustom(Symbol(), 0, sslfile, Lb, sslSlowBuffer, i + 1);
}

bool sslCrossUp(int i)
{
    if(sslFast(i) > sslSlow(i) && sslFastPrev(i) <= sslSlowPrev(i))
    {
        return true;
    }
    return false;
}
bool sslCrossDn(int i)
{
    if(sslFast(i) < sslSlow(i) && sslFastPrev(i) >= sslSlowPrev(i))
    {
        return true;
    }
    return false;
}


#endif

// ------------------------------------------------------------------
#define _KAMA
#ifdef _KAMA

input string Tkama = "== KAMA Setup ==";    // ————————————
input int       kama_period = 10;
input double    fast_ma_period = 2.0;
input double    slow_ma_period = 30.0;

double kama(int i)
{
    return iCustom(Symbol(),0,"KAMA.ex4",kama_period,fast_ma_period,slow_ma_period,0,i);
}

#endif



// ------------------------------------------------------------------
input string T1 = "== Notifications ==";  // ————————————
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications


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
int OnInit()
{
    //--- indicator buffers mapping
    int n = 0;
    SetIndexBuffer(n, signalUp, INDICATOR_DATA);
    SetIndexArrow(n, 233);
    SetIndexStyle(n, DRAW_ARROW, EMPTY, 1, Blue);
    n++;
    SetIndexBuffer(n, signalDn, INDICATOR_DATA);
    SetIndexStyle(n, DRAW_ARROW, EMPTY, 1, Red);
    SetIndexArrow(n, 234);
    n++;
    SetIndexBuffer(n, qqeUp, INDICATOR_DATA);
    SetIndexArrow(n, 233);
    SetIndexStyle(n, DRAW_NONE, EMPTY, 1, RoyalBlue);
    n++;
    SetIndexBuffer(n, qqeDn, INDICATOR_DATA);
    SetIndexStyle(n, DRAW_NONE, EMPTY, 1, Yellow);
    SetIndexArrow(n, 234);
    n++;
    SetIndexBuffer(n, sslUp, INDICATOR_DATA);
    SetIndexArrow(n, 233);
    SetIndexStyle(n, DRAW_NONE, EMPTY, 1, Green);
    n++;
    SetIndexBuffer(n, sslDn, INDICATOR_DATA);
    SetIndexStyle(n, DRAW_NONE, EMPTY, 1, Orange);
    SetIndexArrow(n, 234);

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
    if(prev_calculated == 0) start = 500;
    else start = rates_total - (prev_calculated - 1);

    
    for(i = start; i >= 0; i--)
    {
        if(qqeCrossUp(i)) qqeUp[i] = Low[i];
        if(qqeCrossDn(i)) qqeDn[i] = High[i];
        if(sslCrossUp(i)) sslUp[i] = Low[i];
        if(sslCrossDn(i)) sslDn[i] = High[i];

        if ((qqeUp[i]!=EMPTY_VALUE||qqeUp[i+1]!=EMPTY_VALUE)&&(sslUp[i]!=EMPTY_VALUE||sslUp[i+1]!=EMPTY_VALUE))
        {
           if (Close[i] > kama(i) && signalUp[i+1]==EMPTY_VALUE && signalUp[i+2]==EMPTY_VALUE)
           {
               signalUp[i] = Low[i];
               if(newCandle.IsNewCandle()) Notifications(0);

           }
        }
        if ((qqeDn[i]!=EMPTY_VALUE||qqeDn[i+1]!=EMPTY_VALUE)&&(sslDn[i]!=EMPTY_VALUE||sslDn[i+1]!=EMPTY_VALUE))
        {
            if (Close[i] < kama(i)&& signalDn[i+1]==EMPTY_VALUE && signalDn[i+2]==EMPTY_VALUE)
            {
                signalDn[i] = High[i];
                if(newCandle.IsNewCandle()) Notifications(1);
            }
            
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