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
double LineUp[];
double LineDn[];

// BB Bands
// ------------------------------------------------------------------
extern string TimeFrame         = "current time frame";
extern int    BandsLength       = 20;
extern double BandsDeviation    = 2.0; 
extern int    AppliedPrice      = 2;
extern int    BandsMaMode       = 1; 
// ------------------------------------------------------------------

string indicator_file = "Bollinger bands alerts & arrows 2"; // Indicator File:
double BBArrowUp(int candle = 1) { return iCustom(NULL, 0, indicator_file, TimeFrame, BandsLength, BandsDeviation, AppliedPrice, BandsMaMode, 3, candle); }
double BBArrowDn(int candle = 1) { return iCustom(NULL, 0, indicator_file, TimeFrame, BandsLength, BandsDeviation, AppliedPrice, BandsMaMode, 4, candle); }

// stoch
// ------------------------------------------------------------------
string stoch_file = "Color Stochastic v1[1].04"; // Indicator File:

extern string    note1 = "Chart Time Frame",
                 note2 = "0=current time frame",
                 note3 = "1=M1, 5=M5, 15=M15, 30=M30",
                 note4 = "60=H1, 240=H4, 1440=D1",
                 note5 = "10080=W1, 43200=MN1";
extern int	     timeFrame	= 0;		// {1=M1, 5=M5, 15=M15, ..., 1440=D1, 10080=W1, 43200=MN1}
extern string    note6 = "Stochastic settings";
extern int       KPeriod       =   10,
                 DPeriod       =   3,
                 Slowing       =   3;
extern string    note7 = "0=sma, 1=ema, 2=smma, 3=lwma";
extern int       MAMethod      =   3;
extern string    note8 = "0=high/low, 1=close/close";
extern int       PriceField    =   1;
extern string    note9 = "OverSold/OverBought Level";
extern int       overSold      =  80,
                 overBought    =  20;
extern string    note11 = "Directional: true/false";
extern bool      Directional   = true,
                 showBars      = false,
                 showArrows    = false,
                 alertsOn      = true,
                 alertsMessage = true,
                 alertsSound   = true,
                 alertsEmail   = false;

//  signal < stoch 
bool stoch_is_green(int i)
{
    return (signal(i) < stoch(i) && signal(i) != EMPTY_VALUE && stoch(i) != EMPTY_VALUE);
}
bool stoch_is_red(int i)
{
    return (signal(i) > stoch(i) && signal(i) != EMPTY_VALUE && stoch(i) != EMPTY_VALUE);
}

double signal(int candle = 1) { return iCustom(NULL, 0, stoch_file, 
note1, note2, note3, note4, note5, timeFrame, note6, KPeriod, DPeriod, Slowing, note7, MAMethod, note8, PriceField, note9, overSold, overBought, note11, Directional, showBars, showArrows, alertsOn, alertsMessage, alertsSound, alertsEmail,
    0, candle); }
double stoch(int candle = 1) { return iCustom(NULL, 0, stoch_file, 
    note1, note2, note3, note4, note5, timeFrame, note6, KPeriod, DPeriod, Slowing, note7, MAMethod, note8, PriceField, note9, overSold, overBought, note11, Directional, showBars, showArrows, alertsOn, alertsMessage, alertsSound, alertsEmail,
    1, candle); }



// 



// ------------------------------------------------------------------

input int    periods               = 10;
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
string       T2                    = "== Set Lines ==";     // === Set  Lines ===
bool         LinesOn               = true;                  // Line On?
color        LineUpClr             = clrBlue;               // Line Up Color:
color        LineDnClr             = clrRed;                // Line Down Color:
string       T3                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = clrBlue;               // Arrow Up Color:
color        ArrowDnClr            = clrRed;                // Arrow Down Color:
// ------------------------------------------------------------------

// Mark: Oninit
int OnInit()
{
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexLabel(0, "Line Up");

    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexLabel(1, "Line Dn");

    if (!LinesOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(2, 233);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(2, "Arrow Up");

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(3, 234);
    SetIndexLabel(3, "Arrow Dn");

    if (!ArrowsOn) {
        SetIndexStyle(2, DRAW_NONE);
        SetIndexStyle(3, DRAW_NONE);
    }
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

    for (i = start; i >= 0; i--) {

        // if (ConditionsToLineUp(i)) { LineUp[i] = valueLineUp(i); }

        if (BBArrowUp(i) > 0 && BBArrowUp(i) != EMPTY_VALUE) {
            if(stoch_is_green(i))
            {
                ArrowUp[i] = Low[i];
                notify(0);
            }
        }

        // if (ConditionsToLineDn(i)) { LineDn[i] = valueLineDn(i); }

        if (BBArrowDn(i) > 0 && BBArrowDn(i) != EMPTY_VALUE) {
            if(stoch_is_red(i))
            {
                ArrowDn[i] = High[i];
                notify(1);
            }
        }
    }
    return (rates_total);
}

double valueLineUp(int i)
{
    double sum = 0;
    for (int j = 0; j < periods; j++) {
        sum += iLow(NULL, 0, i + j);
    }
    return sum / periods;
}

double valueLineDn(int i)
{
    double sum = 0;
    for (int j = 0; j < periods; j++) {
        sum += iHigh(NULL, 0, i + j);
    }
    return sum / periods;
}

bool ConditionsToLineUp(int i) { return true; }

bool ConditionsToLineDn(int i) { return true; }

bool haveSignalUp(int i)
{
    // TODO: signal up
    return BBArrowUp(i) > 0;
    // return (iClose(NULL, 0, i + 2) > iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) > iOpen(NULL, 0, i + 1));
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    return BBArrowDn(i) > 0;
    // return (iClose(NULL, 0, i + 2) < iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) < iOpen(NULL, 0, i + 1));
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