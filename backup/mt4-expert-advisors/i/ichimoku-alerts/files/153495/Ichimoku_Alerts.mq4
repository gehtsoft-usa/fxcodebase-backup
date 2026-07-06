//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74389

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
#property indicator_buffers 1
#property indicator_plots   1
#property strict

double         Linea1Buffer [];

// Gobal Variables
enum Mode {
    ByTick,
    ByTimer
};

string file = "Ichimoku ALL.ex4";  // Nombre del Archivo:
Mode   mode = ByTick;
int    shift = 0;

input string       T1 = "== Notifications ==";  // ————————————
input bool         notifications = false;                  // Notifications On?
input bool         desktop_notifications = false;                  // Desktop MT4 Notifications
input bool         email_notifications = false;                  // Email Notifications
input bool         push_notifications = false;                  // Push Mobile Notifications

input int k = 12; // kijun buffer
input int kn = 13; // kijun -26 buffer


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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    SetIndexBuffer(0, Linea1Buffer, INDICATOR_DATA);

    EventSetTimer(1);

    //---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
const int prev_calculated,
const datetime& time [],
const double& open [],
const double& high [],
const double& low [],
const double& close [],
const long& tick_volume [],
const long& volume [],
const int& spread [])
{
    if(mode == ByTimer)
    {
        return 0;
    }

    double kijun_up[2];
    double kijun_dn[2];

    ArrayInitialize(kijun_up, 0);
    ArrayInitialize(kijun_dn, 0);

    int i = 0;
    double kijun = 0;
    do
    {
        kijun = iCustom(Symbol(), _Period, file, kn, i);
        i++;

        if(kijun != 0){
            kijun_dn[0] = kijun;
            kijun_dn[1] = iCustom(Symbol(), _Period, file, kn, i + 1);
            // Print(__FUNCTION__, " kijun: dn ", kijun);

            kijun_up[0] = iCustom(Symbol(), _Period, file, k, i);
            kijun_up[1] = iCustom(Symbol(), _Period, file, k, i + 1);
            // Print(__FUNCTION__, " kijun: up ", kijun_up[0]);
        }

    } while(kijun == 0);


    if(kijun_up[1] <= kijun_dn[1] && kijun_up[0] > kijun_dn[0])
    {

        // Print(__FUNCTION__,"   TENGO CRUCE ARRIBA!  : " );
        if(newCandle.IsNewCandle())
            Notifications(0);
    }
    if(kijun_up[1] >= kijun_dn[1] && kijun_up[0] < kijun_dn[0])
    {
        // Print(__FUNCTION__,"   TENGO CRUCE ABAJO!  : " );
        if(newCandle.IsNewCandle())
            Notifications(1);
    }


    return(rates_total);
}



void Notifications(int type)
{
    if(!notifications) return;

    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Cross Up ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Cross Down ";

    text += " ";


    if(desktop_notifications) Alert(text);
    if(push_notifications)   SendNotification(text);
    if(email_notifications)  SendMail("MetaTrader Notification", text);
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