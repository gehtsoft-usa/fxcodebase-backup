// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75064

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
// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 1
#property indicator_label1 "Color_Histogram"
#property indicator_type1  DRAW_COLOR_HISTOGRAM
#property indicator_color1 clrRed, clrGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 4

double buValue[];
double buColor[];

// ------------------------------------------------------------------
string TZ                    = "== Notifications =="; // ————————————
bool   notifications         = false;                 // Notifications On
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications

// ------------------------------------------------------------------

double Linea1Buffer[];

int OnInit()
{
    SetIndexBuffer(0, buValue, INDICATOR_DATA);
    SetIndexBuffer(1, buColor, INDICATOR_COLOR_INDEX);

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int i, start;

    start = iBars(NULL, 0) - 500;
    if (prev_calculated > 1) start = prev_calculated - 1;

    for (i = start; i < rates_total && !IsStopped(); i++) {

        buValue[i] = 0;

        datetime tm;
        datetime initm = time[i - 1];
        datetime endtm = time[i];

        int sh = iBarShift(_Symbol, PERIOD_M1, initm);

        for (tm = initm; tm < endtm; tm += 60) {
            if (iClose(NULL, PERIOD_M1, sh + 1) > iClose(NULL, PERIOD_M1, sh))
                buValue[i] += 1;
            if (iClose(NULL, PERIOD_M1, sh + 1) < iClose(NULL, PERIOD_M1, sh)) 
                buValue[i] -= 1;
            
            sh++;
        }

        buColor[i] = buValue[i] < 0 ? 0 : 1;
    }

    return (rates_total);
}

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

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