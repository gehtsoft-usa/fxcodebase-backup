//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73849

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
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
double ArrowUp [];
double ArrowDn [];

// ------------------------------------------------------------------

string file = "angle of oma alerts arrows mtf.ex4"; // Indicator File:
int buyBuffer = 3; // Buy Buffer:
int sellBuffer = 4; // Sell Buffer:

input string TimeFrame = "Current time frame";
input double Oma_Period = 32;
input double Oma_Speed = 3;
input bool   Oma_Adaptive = true;
input int    Oma_Price = PRICE_CLOSE;
input double AngleLevel = 5;
input int    AngleBars = 6;
input bool   alertsOn = false;
input bool   alertsOnCurrent = false;
input bool   alertsMessage = true;
input bool   alertsSound = false;
input bool   alertsEmail = false;
input bool   alertsNotification = false;
input bool   arrowsVisible = true;
input string arrowsIdentifier = "CorSsa Arrows1";
input double arrowsDisplacement = 1.0;
input color  arrowsUpColor = Green;
input color  arrowsDnColor = Red;
input int    arrowsUpCode = 241;
input int    arrowsDnCode = 242;
input bool   Interpolate = true;


input string T1 = "== Notifications ==";  // ————————————
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
input string T2 = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:
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

datetime lastSignalTm;
string lastSignalType = "";
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
    if(!ArrowsOn)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    double temp = Indicator(0, 0);
    if(GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
    {
        string txt = "THIS EA NEED AN INDICATOR\ninstall the file:\n" + file + "\ninto the folder:\nMQL4/Indicators.";
        MessageBox(txt, "Important Information", MB_ICONINFORMATION);
        Alert(txt);
        return INIT_FAILED;
    }
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
    if(i >= rates_total) i = rates_total - 1;
    for(; i >= 0; i--)
    {
        if(lastSignalTm > Time[0]) continue;

        if(haveSignalUp(i))
        {
            // ArrowUp[i] = Low[i];
            if(newCandle.IsNewCandle()) Notifications(0);
        }
        if(haveSignalDown(i))
        {
            // ArrowDn[i] = High[i];            
            if(newCandle.IsNewCandle()) Notifications(1);
        }
    }

    return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    if(lastSignalType == "buy")return false;

    // TODO: signal up
    double indicator_buy_buffer = Indicator(buyBuffer, 1);
    double indicator_sell_buffer = Indicator(sellBuffer, 1);
    double indicator_sell_buffer_prev = Indicator(sellBuffer, 2);

    if(indicator_buy_buffer != EMPTY_VALUE && indicator_sell_buffer == EMPTY_VALUE && indicator_sell_buffer_prev != EMPTY_VALUE)
    {
        Print("Buy Signal at: ", indicator_buy_buffer);

        lastSignalTm = TimeCurrent();
        lastSignalType = "buy";
        return true;
    }

    return false;
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    if(lastSignalType == "sell")return false;

    double indicator_sell_buffer = Indicator(sellBuffer, 1);
    double indicator_sell_buffer_prev = Indicator(sellBuffer, 2);

    if(indicator_sell_buffer != EMPTY_VALUE && indicator_sell_buffer_prev == EMPTY_VALUE)
    {
        Print("Sell Signal at: ", indicator_sell_buffer);
        lastSignalTm = TimeCurrent();
        lastSignalType = "sell";

        return true;
    }

    return false;
}

double Indicator(int buffer, int candle)
{
    // TODO: copiar la lista de INPUTS para custom indicator:    
    return iCustom(NULL, 0, file,
    TimeFrame,
    Oma_Period,
    Oma_Speed,
    Oma_Adaptive,
    Oma_Price,
    AngleLevel,
    AngleBars,
    alertsOn,
    alertsOnCurrent,
    alertsMessage,
    alertsSound,
    alertsEmail,
    alertsNotification,
    arrowsVisible,
    arrowsIdentifier,
    arrowsDisplacement,
    arrowsUpColor,
    arrowsDnColor,
    arrowsUpCode,
    arrowsDnCode,
    Interpolate,
    buffer, candle);
}

void Notifications(int type)
{
    if(!notifications) return;

    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY NOW";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL NOW";

    text += " ";


    if(desktop_notifications) Alert(text);
    if(push_notifications)    SendNotification(text);
    if(email_notifications)   SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
        case PERIOD_M1: return ("M1");
        case PERIOD_M5: return ("M5");
        case PERIOD_M15: return ("M15");
        case PERIOD_M30: return ("M30");
        case PERIOD_H1: return ("H1");
        case PERIOD_H4: return ("H4");
        case PERIOD_D1: return ("D1");
        case PERIOD_W1: return ("W1");
        case PERIOD_MN1: return ("MN1");
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