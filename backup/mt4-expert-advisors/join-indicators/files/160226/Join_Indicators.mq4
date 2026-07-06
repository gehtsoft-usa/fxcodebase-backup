//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76236&p=160226#p160226

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


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

// levantar el indi1

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
color        ArrowUpClr            = clrGreen;               // Arrow Up Color:
color        ArrowDnClr            = clrCrimson;                // Arrow Down Color:
// ------------------------------------------------------------------


// ----------------------------------------------------------------
input string       Tcustom = "==== Indicator Setup ===="; // ————————————————————————
input const string indi1_file   = "1.ex4";                     // Indicator File:

double Indi1(int buffer, int candle = 1) { return iCustom(NULL, 0, indi1_file, buffer, candle); }

class Indicator1_Trend
{
    int lastSignal;

  public:
    int Trend(int i)
    {
        double trendBuy  = Indi1(0, i + 1);
        double trendSell = Indi1(1, i + 1);
        if (trendBuy > 0 && trendBuy != EMPTY_VALUE && trendSell < 0) {
            lastSignal = 1;
        }
        if (trendSell > 0 && trendSell != EMPTY_VALUE && trendBuy < 0) {
            lastSignal = -1;
        }
        return lastSignal;
    }
};
Indicator1_Trend indi1;

// ----------------------------------------------------------------
input string       Tcustom2 = "==== Indicator Setup ===="; // ————————————————————————
input const string indi2_file   = "2.ex4";                     // Indicator 2 File:
input double       set1    = 3;                           // Set 1
input int          set2    = 2;                           // Set 2
input int          set3    = 8;                           // Set 3

double Indi2(int buffer, int candle = 1) { 
    return iCustom(NULL, 0, indi2_file, set1, set2, set3, buffer, candle); 
}

class Indicator2_Trend
{
    int lastSignal;

  public:
    int Trend(int i)
    {
        double trendBuy  = Indi2(0, i + 1);
        double trendSell = Indi2(1, i + 1);
        lastSignal = 0; // Reset lastSignal

        if (trendBuy > 0 && trendBuy != EMPTY_VALUE && trendSell == EMPTY_VALUE) {
            lastSignal = 1;
        }
        if (trendSell > 0 && trendSell != EMPTY_VALUE && trendBuy  == EMPTY_VALUE) {
            lastSignal = -1;
        }
        return lastSignal;
    }
};
Indicator2_Trend indi2;


// ----------------------------------------------------------------

input string       Tcustom3 = "==== Indicator Setup ===="; // ————————————————————————
input const string indi3_file   = "3.ex4";                 // Indicator 3 File:


class Indicator3_Trend
{
    int lastSignal;
    
    public:
    int Trend(int i)
    {
        double trendBuy  = Indi(0, i + 1);
        double trendSell = Indi(1, i + 1);
        if (trendBuy > 0 && trendBuy != EMPTY_VALUE && trendSell == 0) {
            lastSignal = 1;
        }
        if (trendSell < 0 && trendSell != EMPTY_VALUE && trendBuy  == 0) {
            lastSignal = -1;
        }
        return lastSignal;
    }
    
    double Indi(int buffer, int candle = 1) { 
        return iCustom(NULL, 0, indi3_file, buffer, candle); 
    }
};
Indicator3_Trend indi3;



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

        if (ConditionsToLineUp(i)) {
            LineUp[i] = valueLineUp(i);
        }

        if (haveSignalUp(i)) {
            ArrowUp[i+1] = Low[i+1];
            notify(0);
        }

        if (ConditionsToLineDn(i)) {
            LineDn[i] = valueLineDn(i);
        }

        if (haveSignalDown(i)) {
            ArrowDn[i+1] = High[i+1];
            notify(1);
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

bool ConditionsToLineUp(int i) { return (indi1.Trend(i) == 1); }

bool ConditionsToLineDn(int i) { return (indi1.Trend(i) == -1); }

bool haveSignalUp(int i)
{
    // TODO: signal up
    return (indi1.Trend(i) == 1 && indi2.Trend(i) == 1 && indi3.Trend(i) == 1);

    // return (indi3.Trend(i) == 1); 
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    return (indi1.Trend(i) == -1 && indi2.Trend(i) == -1 && indi3.Trend(i) == -1);
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76236&p=160226#p160226

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+