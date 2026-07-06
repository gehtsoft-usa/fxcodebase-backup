// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74070

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 3

//--- indicator buffers
double LineUp [];
double LineDn [];
double Histo [];
input string             IATR = "== ATR Setup ==";         // == ATR Setup ==
input int atr_periods = 14; // ATR Periods
input string             IMACD = "== MACD Setup ==";         // == MACD Setup ==
input int                fast_ema_period = 12;              // fast ema period:
input int                slow_ema_period = 26;              // slow ema period:
input int                signal_period = 9;               // signal period:
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;     // applied price:

class MACD
{
    string             _symbol;
    int                _tf;
    int                _fast_ema;
    int                _slow_ema;
    int                _signal;
    ENUM_APPLIED_PRICE _applied_price;

    public:
    MACD()
    {
        _symbol = _Symbol;
        _tf = Period();
        _fast_ema = 12;
        _slow_ema = 26;
        _signal = 9;
        _applied_price = PRICE_CLOSE;
    }

    MACD(string Symbol, int TimeFrame, int Fast_ema, int Slow_ema, int Signal, ENUM_APPLIED_PRICE Applied_price)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
        _fast_ema = Fast_ema;
        _slow_ema = Slow_ema;
        _signal = Signal;
        _applied_price = Applied_price;
    }
    ~MACD() { ; }

    double calculate(int buffer, int shift)
    {
        return iMACD(_symbol, _tf, _fast_ema, _slow_ema, _signal, _applied_price, buffer, shift);
    }

    double macd_line(int shift) { return calculate(0, shift); }

    double signal_line(int shift) { return calculate(1, shift); }
};
MACD* macd;

// ------------------------------------------------------------------
string       T1 = "== Notifications ==";  // ————————————
bool         notifications = false;                  // Notifications On?
bool         desktop_notifications = false;                  // Desktop MT4 Notifications
bool         email_notifications = false;                  // Email Notifications
bool         push_notifications = false;                  // Push Mobile Notifications

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
    SetIndexBuffer(0, Histo, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2, clrBlue);
    SetIndexLabel(0, "Histogram");
    SetIndexBuffer(1, LineUp, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, EMPTY, 1, clrGreen);
    SetIndexLabel(1, "MACD");
    SetIndexBuffer(2, LineDn, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, EMPTY, 1, clrRed);
    SetIndexLabel(1, "Signal");


    macd = new MACD(_Symbol, Period(), fast_ema_period, slow_ema_period, signal_period, applied_price);
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
    if(prev_calculated == 0)
    {
        start = rates_total - atr_periods;
    }
    else
    {
        start = rates_total - (prev_calculated - 1);
    }

    for(i = start; i >= 0; i--)
    {
        LineUp[i] = (macd.macd_line(i) / iATR(NULL, 0, atr_periods, i)) * 100;

        if(newCandle.IsNewCandle())
        {
            Notifications(0);
        }

        LineDn[i] = (macd.signal_line(i) / iATR(NULL, 0, atr_periods, i)) * 100;

        if(newCandle.IsNewCandle())
        {
            Notifications(1);
        }

        Histo[i] = LineUp[i] - LineDn[i];
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
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if(!notifications) return;
    if(desktop_notifications) Alert(text);
    if(push_notifications) SendNotification(text);
    if(email_notifications) SendMail("MetaTrader Notification", text);
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
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+