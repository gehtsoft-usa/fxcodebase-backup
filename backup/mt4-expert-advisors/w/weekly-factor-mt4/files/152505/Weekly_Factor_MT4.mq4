// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74146

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
#property indicator_buffers 2
#property indicator_plots 2
// #property indicator_label1 "Line Up"
// #property indicator_type1  DRAW_ARROW
// #property indicator_color1 clrDimGray
// #property indicator_style1 STYLE_SOLID
// #property indicator_width1 1
// #property indicator_label2 "Line Down"
// #property indicator_type2  DRAW_ARROW
// #property indicator_color2 clrGold
// #property indicator_style2 STYLE_SOLID
// #property indicator_width2 1
// #property indicator_label3 "Line Up Super"
// #property indicator_type3  DRAW_ARROW
// #property indicator_color3 clrBlue
// #property indicator_style3 STYLE_SOLID
// #property indicator_width3 1
// #property indicator_label4 "Line Down Super"
// #property indicator_type4  DRAW_ARROW
// #property indicator_color4 clrRed
// #property indicator_style4 STYLE_SOLID
// #property indicator_width4 1

//--- indicator buffers
double LineUp [];
double LineDn [];

// ------------------------------------------------------------------
input int      inp_range_filter     = 50;       // Range Percentage Factor (min val: 1, max val: 100)
int            range_filter;
input color  LineUpClr = clrDimGray;                // Not Trend Color:
input color  LineDnClr = clrGold;              // Trend Color:
input int    dotSize = 1;                      // Dot Size:

input string       T1 = "== Notifications ==";  // ————————————
input bool         notifications = false;                  // Notifications On?
input bool         desktop_notifications = false;                  // Desktop MT4 Notifications
input bool         email_notifications = false;                  // Email Notifications
input bool         push_notifications = false;                  // Push Mobile Notifications

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
    //--- check input parameters
    range_filter = inp_range_filter < 1 ? 1 : inp_range_filter > 100 ? 100 : inp_range_filter;
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, dotSize, LineUpClr);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, dotSize, LineDnClr);

    SetIndexArrow(0, 159);
    SetIndexArrow(1, 159);

    IndicatorSetDouble(INDICATOR_MINIMUM, 0);
    IndicatorSetDouble(INDICATOR_MAXIMUM, 2);
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
    if(prev_calculated == 0) { start = rates_total - 10; } else { start = rates_total - (prev_calculated - 1); }

    for(i = start; i >= 0; i--)
    {

        double value =
            fabs(open[i + 5] - close[i + 1]) < (double(range_filter) / 100.0) *
            (fmax(high[i + 1], fmax(high[i + 2], fmax(high[i + 3], fmax(high[i + 4], high[i + 5]))))
            - fmin(low[i + 1], fmin(low[i + 2], fmin(low[i + 3], fmin(low[i + 4], low[i + 5])))))
            ? 0.0 : 1.0;

        if(value == 0.0)
        {
            LineUp[i] = 1;

            if(newCandle.IsNewCandle()) { Notifications(0); }
        }

        if(value == 1.0)
        {
            LineDn[i] = 1; 

            if(newCandle.IsNewCandle()) { Notifications(1); }
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
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    | 
//+------------------------------------------------------------------------------------------------+