// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=156676#p156676

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
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

input int NumBars = 500;
double    ArrowUp[];
double    ArrowDn[];
double    mySpread;

input string TZ                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input int    minutesBetwenNotify   = 1;                     // Minutes Betwen Notifications
int          timeNextNotify        = 0;

// ------------------------------------------------------------------
int OnInit()
{
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexBuffer(0, ArrowUp);
    SetIndexArrow(0, 233);
    SetIndexStyle(1, DRAW_ARROW);
    SetIndexBuffer(1, ArrowDn);
    SetIndexArrow(1, 234);
    mySpread = MarketInfo(Symbol(), MODE_SPREAD) * Point;

    //---
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}



int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
    //---
    double CandleSize[100];

    int    counted        = IndicatorCounted();
    int    back           = 7;
    double multiplier     = 7.0;
    double percent        = 0.7;
    int    limit          = 0;
    int    i              = 0;
    bool   lastCloseMinor = true;
    int    count          = 0;
    int    j              = 0;
    double sill           = 0;
    int    trend          = 0;
    double atr_multiplier = 2;

    if (Bars < NumBars)
        limit = Bars;
    else
        limit = NumBars;

    if (close[limit - 2] > close[limit - 1])
        lastCloseMinor = true;
    else
        lastCloseMinor = false;

    double close2 = close[limit - 2];


    for (i = limit - 3; i >= 0; i--) {
    
       double size = mySpread + high[i] - low[i];
        if (MathAbs(mySpread + high[i] - (close[i + 1])) > size)
            size = MathAbs(mySpread + high[i] - (close[i + 1]));
        if (MathAbs(low[i] - (close[i + 1])) > size)
            size = MathAbs(low[i] - (close[i + 1]));

        if (i == limit - 3)
            for (j = 0; i <= back - 1; j++)
                CandleSize[j] = size;
        CandleSize[count] = size;
        double sum        = 0;
        int pos           = back;
        int p             = count;

        for (j = 0; j <= back - 1; j++) {
            sum += CandleSize[p] * pos;
            pos -= 1.0;
            p--;
            if (p == -1) {
                p = back - 1;
            }
        }

        sum = 2.0 * sum / (multiplier * (multiplier + 1.0));
        count++;
        if (count == back)
            count = 0;
        double AverageSize = percent * sum;

        if (lastCloseMinor && low[i] < close2 - AverageSize) {
            lastCloseMinor = false;
            close2         = mySpread + high[i];
        }

        if (!lastCloseMinor && mySpread + high[i] > close2 + AverageSize) {
            lastCloseMinor = true;
            close2         = low[i];
        }

        if (lastCloseMinor && low[i] > close2)
            close2 = low[i];

        if (!lastCloseMinor && mySpread + high[i] < close2)
            close2 = mySpread + high[i];

        double atr = iATR(NULL, 0, 10, i);
        double up  = 0;
        double dn  = 0;

        if (lastCloseMinor) {
            if (trend != 1)
                sill = low[i] - atr * atr_multiplier / 3.0;
            if (trend == 1)
                sill = -1.0;
            if (sill > 0.0) {
                up = sill;
                dn = 0;
            } else {
                up = 0;
                dn = 0;
            }
            ArrowUp[i] = up;
            trend      = 1;
            Notifications(0);
        } else {
            if (trend != 2)
                sill = mySpread + high[i] + atr * atr_multiplier / 3.0;
            if (trend == 2)
                sill = -1.0;
            if (sill > 0.0) {
                up = 0;
                dn = sill;
            } else {
                up = 0;
                dn = 0;
            }
            ArrowDn[i] = dn;
            trend      = 2;
            Notifications(1);        
        }
    }

    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+

void Notifications(int type)
{
    // time Control
    if (timeNextNotify != 0)
        if (TimeCurrent() < timeNextNotify)
            return;
    timeNextNotify = TimeCurrent() + (minutesBetwenNotify * 60);

    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if (!notifications)
        return;
    if (desktop_notifications)
        Alert(text);
    if (push_notifications)
        SendNotification(text);
    if (email_notifications)
        SendMail("MetaTrader Notification", text);
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