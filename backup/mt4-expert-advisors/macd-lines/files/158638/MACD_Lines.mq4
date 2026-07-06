//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75722

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
#property indicator_buffers 4
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double LineUp[];
double LineDn[];

// ------------------------------------------------------------------
int    periods               = 10;
input int InpFastEMA=12;   // Fast EMA Period
input int InpSlowEMA=26;   // Slow EMA Period
input int InpSignalSMA=9;  // Signal SMA Period
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

// Variables para almacenar los índices de los cruces
int goldenCrossIndex = -1;
int deathCrossIndex = -1;

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
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - periods;
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = start; i >= 0; i--) {

        if (IsGoldenCross(i)) {
            ArrowUp[i] = Low[i];
            goldenCrossIndex = i;
            if (deathCrossIndex != -1) {
                double maxPrice = FindMaxPrice(goldenCrossIndex, deathCrossIndex);
                for (int j = deathCrossIndex; j >= goldenCrossIndex; j--) {
                    LineDn[j] = maxPrice;
                }
            }
        }

        if (IsDeathCross(i)) {
            ArrowDn[i] = High[i];
            deathCrossIndex = i;
            if (goldenCrossIndex != -1) {
                double minPrice = FindMinPrice(deathCrossIndex, goldenCrossIndex);
                for (int j = goldenCrossIndex; j >= deathCrossIndex; j--) {
                    LineUp[j] = minPrice;
                }
            }
        }

        // Continuar actualizando las líneas después del último cruce
        // if (goldenCrossIndex != -1 && goldenCrossIndex > deathCrossIndex) {
        //     LineUp[i] = FindMinPrice(goldenCrossIndex, i);
        // }
    
        // if (deathCrossIndex != -1 && deathCrossIndex > goldenCrossIndex) {
        //     LineDn[i] = FindMaxPrice(deathCrossIndex, i);
        // }
    }
    return (rates_total);
}


bool IsGoldenCross(int i)
{
    double macdCurrent = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, PRICE_CLOSE, MODE_MAIN, i);
    double signalCurrent = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
    double macdPrevious = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, PRICE_CLOSE, MODE_MAIN, i + 1);
    double signalPrevious = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, PRICE_CLOSE, MODE_SIGNAL, i + 1);

    return (macdPrevious < signalPrevious && macdCurrent > signalCurrent);
}

bool IsDeathCross(int i)
{
    double macdCurrent = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, PRICE_CLOSE, MODE_MAIN, i);
    double signalCurrent = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
    double macdPrevious = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, PRICE_CLOSE, MODE_MAIN, i + 1);
    double signalPrevious = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, PRICE_CLOSE, MODE_SIGNAL, i + 1);

    return (macdPrevious > signalPrevious && macdCurrent < signalCurrent);
}

double FindMinPrice(int startIndex, int endIndex)
{
    double minPrice = iLow(NULL, 0, startIndex);
    for (int i = startIndex + 1; i <= endIndex; i++) {
        if (iLow(NULL, 0, i) < minPrice) {
            minPrice = iLow(NULL, 0, i);
        }
    }
    return minPrice;
}

double FindMaxPrice(int startIndex, int endIndex)
{
    double maxPrice = iHigh(NULL, 0, startIndex);
    for (int i = startIndex + 1; i <= endIndex; i++) {
        if (iHigh(NULL, 0, i) > maxPrice) {
            maxPrice = iHigh(NULL, 0, i);
        }
    }
    return maxPrice;
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75722

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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