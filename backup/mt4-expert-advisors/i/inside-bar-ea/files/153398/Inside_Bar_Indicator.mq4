// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74366

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
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "Signal Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Signal Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Inside Bar"
#property  indicator_type3  DRAW_ARROW
#property indicator_color3 clrRoyalBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
//--- indicator buffers
double ArrowUp [];
double ArrowDn [];
double SignalBar [];

// ------------------------------------------------------------------

string T1 = "== Notifications ==";  // ————————————
bool   notifications = false;                  // Notifications On?
bool   desktop_notifications = false;                  // Desktop MT4 Notifications
bool   email_notifications = false;                  // Email Notifications
bool   push_notifications = false;                  // Push Mobile Notifications
string T2 = "== Set Arrows ==";     // ————————————
color  ArrowUpClr = clrBlue;                // Arrow Up Color:
color  ArrowDnClr = clrRed;                 // Arrow Down Color:

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
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    SetIndexBuffer(2, SignalBar, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, RoyalBlue);
    SetIndexArrow(2, 159);
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
    int i = rates_total - prev_calculated + 1;
    if(i >= rates_total) i = rates_total - 5;
    for(; i >= 0; i--)
    {
        if(high[i+1] < high[i + 2] && low[i+1] > low[i + 2])
        {
            SignalBar[i+2] = Low[i+2];           
        }


        // si no hay ninguna señal 
        // si el precio actual cruza arriba a la SignalBar, pone compra
        // o si el precio actual abajao de la Inside, pone venta
        // esto tiene que ser durante 3 velas y que no haya ninguna señal dentro de esas 3 velas
        
        if(SignalBar[i] == EMPTY_VALUE && ArrowUp[i] == EMPTY_VALUE && ArrowDn[i] == EMPTY_VALUE)
        {
            for(int j = i + 1; j <= i + 3; j++)
            {
                if(ArrowUp[j] != EMPTY_VALUE) break;
                if(ArrowDn[j] != EMPTY_VALUE) break;

                if(SignalBar[j] != EMPTY_VALUE){
                    if(high[i] > high[j])
                    {
                        ArrowUp[i] = low[i];
                        break;
                    }
                    if(low[i] < low[j])
                    {
                        ArrowDn[i] = high[i];
                        break;
                    }
                }
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