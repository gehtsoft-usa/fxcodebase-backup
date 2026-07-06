//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75721

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
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T3                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:

// Inputs from Arrow nrp
input string Tarrowsinput       = "== Set Arrows nrp indicator ==";    // Set Arrows
input double Sensitivity = 15.0;
input int TrendStrength = 5;
input int SignalMode = 2;


// Inputs from coronforex FILTER
input string Tcoronforex       = "== Set coronforex indicator ==";    
input int    Length          = 7;
input int    Price           = PRICE_TYPICAL;
input double levelOs         = 20;
input double levelOb         = 80;

// Variables para los indicadores externos
double ArrowNrpBuffer[];
double CoronforexFilterBuffer[];

int    periods               = 10;
// ------------------------------------------------------------------

// Mark: Oninit
int OnInit()
{
    IndicatorShortName("Arrow nrp and Coronforex");

    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(0, "Arrow Up");
    
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    SetIndexLabel(1, "Arrow Dn");
    
    SetIndexBuffer(2, ArrowNrpBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, CoronforexFilterBuffer, INDICATOR_DATA);

    return (INIT_SUCCEEDED);
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - periods;
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    // Obtener los valores de los indicadores externos
    for (i = start; i >= 0; i--) {
        double buy_arrow = iCustom(NULL, 0, "Arrow nrp", Sensitivity, TrendStrength, SignalMode, 3, i);
        double sell_arrow = iCustom(NULL, 0, "Arrow nrp", Sensitivity, TrendStrength, SignalMode, 4, i);
        
        ArrowNrpBuffer[i] = 0;
        if (GreaterZeroNotEmty(buy_arrow)) { ArrowNrpBuffer[i] = 1;}
        if (GreaterZeroNotEmty(sell_arrow)) { ArrowNrpBuffer[i] = -1;}

        CoronforexFilterBuffer[i] = iCustom(NULL, 0, "coronforex FILTER", Length, Price, levelOs, levelOb, 4, i) == EMPTY_VALUE ? 1 : -1;
    }

    for (i = start; i >= 0; i--) {

        if (ArrowNrpBuffer[i] == 1 && CoronforexFilterBuffer[i] == 1) {
            ArrowUp[i] = Low[i];
            notify(0);
        }
        
        if (ArrowNrpBuffer[i] == -1 && CoronforexFilterBuffer[i] == -1) {
            ArrowDn[i] = High[i];
            notify(1);
        }
    }
    return (rates_total);
}

void notify(int type)
{
    if (IsNewCandle()) {
        Notifications(type);
    }
}

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

bool IsNewCandle()
{
    static datetime last;
    datetime        current = iTime(NULL, 0, 1);
    if (last != current) {
        last = current;
        return true;
    }
    return false;
}

bool GreaterZeroNotEmty(double value)
{
    return value > 0 && value != EMPTY_VALUE;
}
//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75721

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