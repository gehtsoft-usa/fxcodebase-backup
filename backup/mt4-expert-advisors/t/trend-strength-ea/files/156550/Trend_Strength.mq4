// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75172

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
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 9

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double upper[];
double lower[];
double upper1[];
double lower1[];
double trend[];
double tpbuy[];
double tpsell[];

// ------------------------------------------------------------------
input int    periods               = 20;                    // Periods
input double multi                 = 2.5;                   // Multiplier
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Lines ==";     // === Set  Lines ===
input color  LineUpClr             = clrBlue;               // Line Up Color:
input color  LineDnClr             = clrRed;                // Line Down Color:
input string T3                    = "== Set Arrows ==";    // Set Arrows
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
input color  tpclr                 = Magenta;               // TP Color:
// ------------------------------------------------------------------

// Mark: Oninit
int OnInit()
{
    SetIndexBuffer(0, upper, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexLabel(0, "Line Up");

    SetIndexBuffer(1, lower, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexLabel(1, "Line Dn");

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(2, 233);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(2, "Arrow Up");

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(3, 234);
    SetIndexLabel(3, "Arrow Dn");

    SetIndexBuffer(4, upper1, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_NONE, STYLE_SOLID, 1, LineUpClr);
    SetIndexLabel(4, "Line Up");

    SetIndexBuffer(5, lower1, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_NONE, STYLE_SOLID, 1, LineDnClr);
    SetIndexLabel(5, "Line Dn");

    SetIndexBuffer(6, trend, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_NONE);

    SetIndexBuffer(7, tpbuy, INDICATOR_DATA);
    SetIndexArrow(7, 159);
    SetIndexStyle(7, DRAW_ARROW, EMPTY, 1, tpclr);
    SetIndexLabel(7, "TP BUY");

    SetIndexBuffer(8, tpsell, INDICATOR_DATA);
    SetIndexStyle(8, DRAW_ARROW, EMPTY, 1, tpclr);
    SetIndexArrow(8, 159);
    SetIndexLabel(8, "TP SELL");

    return (INIT_SUCCEEDED);
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - periods - 1;
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = start; i >= 0; i--) {

        double basic = iMA(NULL, 0, periods, 0, MODE_SMA, PRICE_CLOSE, i);
        double closes[];
        ArrayResize(closes, periods, 0);
        for (int j = 0; j < periods; j++) {
            closes[j] = iClose(NULL, 0, j + i);
        }
        double desv = MathStandardDeviation(closes);
        upper[i]    = basic + desv;
        lower[i]    = basic - desv;
        upper1[i]   = basic + desv * multi;
        lower1[i]   = basic - desv * multi;

        trend[i] = trend[i + 1];
        if (close[i] > basic && close[i] > upper[i] && trend[i] !=1) trend[i] = 1;
        if (close[i] < basic && close[i] < lower[i] && trend[i] !=-1) trend[i] = -1;

        ArrowUp[i] = EMPTY_VALUE;
        ArrowDn[i] = EMPTY_VALUE;

        if (trend[i] > 0 && trend[i + 1] < 0) {
            ArrowUp[i] = low[i];
            notify(0);
        }
        if (trend[i] < 0 && trend[i + 1] > 0) {
            ArrowDn[i] = high[i];
            notify(1);
        }

        if (trend[i] == 1 && close[i] > upper1[i]) {
            tpbuy[i] = high[i] + 20 * _Point;
        }
        if (trend[i] == -1 && close[i] < lower1[i]) {
            tpsell[i] = low[i] - 20 * _Point;
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
    if (size <= 1) return (0);
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