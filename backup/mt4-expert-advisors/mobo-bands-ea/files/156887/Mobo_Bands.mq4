// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75262

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots 5

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double LineUp[];
double LineDn[];
double LineMidle[];
double price[];
double dpo[];
int lastSignal = 0;

// ------------------------------------------------------------------
input int    periods               = 13;                    // Periods
input int    moboLength            = 10;                    // Mobo Length :
input double nStd                  = 1;                     //  Standard Deviation Bands:
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
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, Gray);
    SetIndexLabel(0, "Line Up");

    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, Gray);
    SetIndexLabel(1, "Line Dn");

    SetIndexBuffer(2, LineMidle, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, Blue);
    SetIndexLabel(2, "Line Dn");

    SetIndexBuffer(3, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(3, 233);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(3, "Arrow Up");

    SetIndexBuffer(4, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(4, 234);
    SetIndexLabel(4, "Arrow Dn");

    SetIndexBuffer(5, dpo, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, Gold);

    SetIndexBuffer(6, price, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_NONE);

    return (INIT_SUCCEEDED);
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - periods + 1;
    } else {
        start = rates_total - (prev_calculated - periods-1);
    }

    for (i = start; i >= 0; i--) {
        price[i] = (high[i] + low[i]) / 2;
    }

    for (i = start-periods; i >= 0; i--) {
        double sumPrice = 0;

        for (int n = 1; n <= periods; n++)
            sumPrice += price[i + n];
        double xsma = sumPrice / periods;
        dpo[i]      = price[i] - xsma;

        double sumDpo = 0;
        for (int n = 1; n <= moboLength; n++)
            sumDpo += dpo[i + n];
        LineMidle[i] = sumDpo / moboLength;

        double midle[];
        ArrayResize(midle, moboLength);
        for (int n = 0; n < moboLength; n++)
            midle[n] = LineMidle[i + n];

        double std = MathStandardDeviation(midle);
        LineUp[i]  = LineMidle[i] + (std * nStd);
        LineDn[i]  = LineMidle[i] - (std * nStd);

        if (dpo[i+1] > LineUp[i+1] && dpo[i+2] <= LineUp[i+2] && (lastSignal == -1 || lastSignal ==0) ) {
            ArrowUp[i+1] = LineDn[i+1];
            notify(0);
            lastSignal = 1;
        }

        if (dpo[i+1] < LineDn[i+1] && dpo[i+2] >= LineDn[i+2] && (lastSignal == 1 || lastSignal ==0)) {
            ArrowDn[i+1] = LineUp[i+1];
            notify(1);
            lastSignal = -1;
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

double MathStandardDeviation(const double &array[])
{
    int size = ArraySize(array);
    // if (size <= 1) return ();
    //--- calculate mean
    double mean = 0.0;
    for (int i = 0; i < size; i++)
        mean += array[i];
    //--- average mean
    mean = mean / size;
    //--- calculate standard deviation
    double sdev = 0;
    for (int i = 0; i < size; i++)
        sdev += MathPow(array[i] - mean, 2);
    //--- return standard deviation
    return MathSqrt(sdev / (size - 1));
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