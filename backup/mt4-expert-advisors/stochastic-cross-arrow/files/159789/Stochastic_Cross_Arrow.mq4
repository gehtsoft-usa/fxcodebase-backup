//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159666#p159666

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 

#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

// Mark: buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
input int            StoKPeriod    = 14;       // Period %K
input int            StoDPeriod    = 3;        // Period %D
input int            StoSlowing    = 1;        // Slowing
input ENUM_MA_METHOD StoMethod     = MODE_SMA; // MODE: (MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA)
input int            StoPriceField = 0;        // Price Field (Low/High or Close/Close)

input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
string       T3                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = Black;                 // Arrow Up Color:
color        ArrowDnClr            = Black;                 // Arrow Down Color:
// ------------------------------------------------------------------

// Mark: Oninit
int OnInit()
{
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(0, "Arrow Up");

    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexLabel(1, "Arrow Dn");

    SetIndexArrow(0, 108); // Arrow Up 108 - 159 - 46
    SetIndexArrow(1, 108); // Arrow Down 108 - 159 - 46
    return (INIT_SUCCEEDED);
}

int lastSignal = 0;

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{

    int start, i;
    if (prev_calculated == 0) {
        // start = rates_total - StoKPeriod;
        start = 200;
    } else {
        start = rates_total - (prev_calculated - 2);
    }

    if (!IsNewCandle()) {
        return (rates_total);
    }

    for (i = start; i > 0; i--) {
        double sto = stoch(i);
        if (sto > 60) {
            lastSignal = -1; // 1 = up
        } else if (sto < 40) {
            lastSignal = 1; // -1 = down
        }

        if (sto > 40 && sto < 60) {

            if (lastSignal == -1) {
                double minVal = low[i] - 20 * _Point;
                int    minIdx = i;
                int    j      = i;
                double sto_j  = sto;

                while (sto_j < 60) {
                    if (ArrowUp[j] != 0) {
                        ArrowUp[j] = 0;
                    }
                    if (low[j] < minVal) {
                        minVal = low[j] - 20 * _Point;
                        minIdx = j;
                    }
                    j++;
                    if (j > rates_total) break; // Prevent out of bounds access
                    sto_j = stoch(j);
                }
                ArrowUp[minIdx] = minVal;
            }

            if (lastSignal == 1) {

                double maxVal = high[i] + 20 * _Point;
                int    maxIdx = i;
                int    j      = i;
                double sto_j  = sto;

                while (sto_j > 40) {
                    if (ArrowDn[j] != 0) {
                        ArrowDn[j] = 0;
                    }
                    if (high[j] > maxVal) {
                        maxVal = high[j] + 20 * _Point;
                        maxIdx = j;
                    }
                    j++;
                    if (j > rates_total) break; // Prevent out of bounds access
                    sto_j = stoch(j);
                }
                ArrowDn[maxIdx] = maxVal;
            }
        }


        if (sto < 40) {
            int u = i+1;
            int d = i+1;
            while (u < 1000 && u < rates_total-1) { if (ArrowUp[u] != 0 && ArrowUp[u] != EMPTY_VALUE) break; u++; }
            while (d < 1000 && d < rates_total-1) { if (ArrowDn[d] != 0 && ArrowDn[d] != EMPTY_VALUE) break; d++; }
            if(u < d) { ArrowUp[u] = 0; }

            // busca min
            double minVal = low[i] - 20 * _Point;
            int    minIdx = i;
            int    j      = i;
            double sto_j  = sto;

            while (sto_j < 40) {
                if (ArrowUp[j] != 0) {
                    ArrowUp[j] = 0;
                }
                if (low[j] < minVal) {
                    minVal = low[j] - 20 * _Point;
                    minIdx = j;
                }
                j++;
                if (j > rates_total) break; // Prevent out of bounds access
                sto_j = stoch(j);
            }
            ArrowUp[minIdx] = minVal;
        }

        if (sto > 60) {
            int u = i + 1;
            int d = i + 1;
            while (u < 1000 && u < rates_total-1) { if (ArrowUp[u] != 0 && ArrowUp[u] != EMPTY_VALUE) break; u++; }
            while (d < 1000 && d < rates_total-1) { if (ArrowDn[d] != 0 && ArrowDn[d] != EMPTY_VALUE) break; d++; }
            if(d < u) { ArrowDn[d] = 0; }


            // busca max
            double maxVal = high[i] + 20 * _Point;
            int    maxIdx = i;
            int    j      = i;
            double sto_j  = sto;

            while (sto_j > 60) {
                if (ArrowDn[j] != 0) {
                    ArrowDn[j] = 0;
                }
                if (high[j] > maxVal) {
                    maxVal = high[j] + 20 * _Point;
                    maxIdx = j;
                }
                j++;
                if (j > rates_total) break; // Prevent out of bounds access
                sto_j = stoch(j);
            }
            ArrowDn[maxIdx] = maxVal;
        }

        // if(sto > 40 && sto < 60)
        // {
        //     int u = 1;
        //     int d = 1;
        //     while (u < 1000 && u + i < rates_total-1) { if (ArrowUp[u + i] != 0) break; u++; }
        //     while (d < 1000 && d + i < rates_total-1) { if (ArrowDn[d + i] != 0) break; d++; }
        //     int lastSignal = u < d ? 1 : -1; // 1 = up, -1 = down

        //     if(lastSignal == 1)
        //     {
        //         // buscar max

        //     }
        //     else if(lastSignal == -1)
        //     {
        //         // buscar min
        //     }

        // }
    }
    return (rates_total);
}

double stoch(int i) { return iStochastic(NULL, 0, StoKPeriod, StoDPeriod, StoSlowing, StoMethod, StoPriceField, MODE_MAIN, i); }

bool haveSignalUp(int i)
{
    // TODO: signal up

    return (iClose(NULL, 0, i + 2) > iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) > iOpen(NULL, 0, i + 1));
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    return (iClose(NULL, 0, i + 2) < iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) < iOpen(NULL, 0, i + 1));
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159666#p159666

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 