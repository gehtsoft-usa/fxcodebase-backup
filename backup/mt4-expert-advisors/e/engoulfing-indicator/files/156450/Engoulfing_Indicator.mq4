//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75146

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
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
input int    periods               = 10;
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
string       T3                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = clrBlue;              // Arrow Up Color:
color        ArrowDnClr            = clrRed;            // Arrow Down Color:
// ------------------------------------------------------------------

int nrZones = 20;
int candlesBack = 1000;

// clang-format off
// Mark: Oninit
int OnInit()
{
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(0, "Arrow Up");

   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    SetIndexLabel(1, "Arrow Dn");


    return (INIT_SUCCEEDED);
    // clang-format on
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - periods;
    } else {
        start = rates_total - (prev_calculated - 1);
    }


    double gap = iATR(NULL, 0, 10, 0)*0.25;

    for (i = start; i >= 0; i--) {
        if (haveSignalUp(i)) {
            ArrowUp[i + 1] = Low[i + 1] - gap;
            notify(0);
        }

        if (haveSignalDown(i)) {
            ArrowDn[i + 1] = High[i + 1] + gap;
            notify(1);
        }
    }

    return (rates_total);
}
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "ob"); }

bool haveSignalUp(int i)
{
    double sum = 0;
    for (int j = 0; j < 15; j++) {
        sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    }
    double avSize = sum / 15;

    // TODO: signal up
    double op2 = iOpen(NULL, 0, i + 2);
    double hi2 = iHigh(NULL, 0, i + 2);
    double lo2 = iLow(NULL, 0, i + 2);
    double cl2 = iClose(NULL, 0, i + 2);
    double op1 = iOpen(NULL, 0, i + 1);
    double hi1 = iHigh(NULL, 0, i + 1);
    double lo1 = iLow(NULL, 0, i + 1);
    double cl1 = iClose(NULL, 0, i + 1);

    if (fabs(cl1 - op1) < avSize) return false;

    double size2 = fabs(op2-cl2);
    double size1 = fabs(op1-cl1);
    
    if(size2 == 0) return false;
    double proportion = size1/size2;
    if(proportion <0.7 || proportion >2) return false;

    // return (cl3 < op3 && cl2 < op3 && cl1 > op1 && cl1 > op2 && op1 > lo2 && lo2 < cl3 && cl1 > ( cl3 + size3 * 0.80));
    return (cl2 < op2 && cl1 > op1 && op1 > lo2 && cl1 > ( cl2 + size2 * 0.65));
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    double sum = 0;
    for (int j = 0; j < 15; j++) {
        sum += fabs(iOpen(NULL, 0, i + j) - iClose(NULL, 0, i + j));
    }
    double avSize = sum / 15;

    double op2 = iOpen(NULL, 0, i + 2);
    double hi2 = iHigh(NULL, 0, i + 2);
    double lo2 = iLow(NULL, 0, i + 2);
    double cl2 = iClose(NULL, 0, i + 2);
    double op1 = iOpen(NULL, 0, i + 1);
    double hi1 = iHigh(NULL, 0, i + 1);
    double lo1 = iLow(NULL, 0, i + 1);
    double cl1 = iClose(NULL, 0, i + 1);

    if (fabs(cl1 - op1) < avSize) return false;
    
    double size2 = fabs(cl2-op2);
    double size1 = fabs(op1-cl1);

    if(size2 == 0) return false;
    double proportion = size1/size2;
    if(proportion <0.7 || proportion >2) return false;

    // return (cl3 > op3 && cl2 > op3 && cl1 < op1 && cl1 < op2 && op1 < hi2 && hi2 > cl3 && cl1 < (cl3- size3 * 0.70));
    return (cl2 > op2 && cl1 < op1 && op1 < hi2 && cl1 < ( cl2 -(size2 * 0.5)));
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