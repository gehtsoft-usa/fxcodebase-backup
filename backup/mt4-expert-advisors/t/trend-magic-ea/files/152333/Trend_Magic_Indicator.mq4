// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 4

//--- indicator buffers
double ArrowUp [];
double ArrowDn [];
double LineUp [];
double LineDn [];
double Value [];
double Trend [];

// ------------------------------------------------------------------
input string T0 = "== Settings ==";  // === Settings ===
input int CCIPer = 20; // CCI Periods:
input int ATRPer = 5; // ATR Periods:
input int ATRMulti = 1; // ATR Multiplier;
input string T1 = "== Notifications ==";  // === Notifications ===
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
input string T2 = "== Set Lines ==";      // === Set  Lines ===
input bool   LinesOn = true;                   // Line On?
input color  LineUpClr = clrBlue;                // Line Up Color:
input color  LineDnClr = clrRed;                 // Line Down Color:
input string T3 = "== Set Arrows ==";     // Set Arrows
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

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, LineUpClr);
    SetIndexLabel(0, "Line Up");

    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, LineDnClr);
    SetIndexLabel(1, "Line Dn");

    if(!LinesOn)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(2, 159);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(2, "Arrow Up");

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(3, 159);
    SetIndexLabel(3, "Arrow Dn");

    if(!ArrowsOn)
    {
        SetIndexStyle(2, DRAW_NONE);
        SetIndexStyle(3, DRAW_NONE);
    }

    SetIndexBuffer(4, Trend);
    SetIndexStyle(4, DRAW_NONE);

    //---
    return (INIT_SUCCEEDED);
}

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
    if(prev_calculated == 0) { start = rates_total - CCIPer; } else { start = rates_total - (prev_calculated - 1); }

    for(i = start; i >= 0; i--)
    {
        ArrowUp[i] = EMPTY_VALUE;
        ArrowDn[i] = EMPTY_VALUE;
        
        if(ConditionsToLineUp(i))
        {
            LineUp[i] = valueLineUp(i);
        }

        if(haveSignalUp(i))
        {
            ArrowUp[i] = Low[i] - iATR(NULL, 0, ATRPer, i) / 2;
            notify(0);
        }

        if(ConditionsToLineDn(i))
        {
            LineDn[i] = valueLineDn(i);
        }

        if(haveSignalDown(i))
        {
            ArrowDn[i] = High[i] + iATR(NULL, 0, ATRPer, i) / 2;
            notify(1);
        }
    }
    return (rates_total);
}

// ------------------------------------------------------------------

double valueLineUp(int i)
{
    double value = iLow(NULL, 0, i) - iATR(NULL, 0, ATRPer, i) * ATRMulti;
    double prev = LineUp[i + 1];
    double r = value;

    r = value > prev ? value : prev;

    if(Trend[i + 1] == 0)
    {
        r = LineDn[i + 1];
        LineUp[i + 1] = r;
    }

    return r;
}

double valueLineDn(int i)
{
    double value = iHigh(NULL, 0, i) + iATR(NULL, 0, ATRPer, i) * ATRMulti;
    double prev = LineDn[i + 1];
    double r = value;

    r = value < prev ? value : prev;

    if(Trend[i + 1] == 1)
    {
        r = LineUp[i + 1];
        LineDn[i + 1] = r;
    }

    return r;
}

bool ConditionsToLineUp(int i)
{
    if(iCCI(NULL, 0, CCIPer, PRICE_CLOSE, i) >= 0)
    {
        Trend[i] = 1;
        return true;
    }
    return false;
}

bool ConditionsToLineDn(int i)
{
    if(iCCI(NULL, 0, CCIPer, PRICE_CLOSE, i) < 0)
    {
        Trend[i] = 0;
        return true;
    }
    return false;
}

bool haveSignalUp(int i)
{
    // TODO: signal up
    if(Trend[i + 1] == 1 && Trend[i + 2] == 0) return true;

    return false;
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    if(Trend[i + 1] == 0 && Trend[i + 2] == 1) return true;

    return false;
}

void notify(int type)
{
    if(newCandle.IsNewCandle())
    {
        Notifications(type);
    }
}

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
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |   
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
//|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+