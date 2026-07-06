//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76077

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
#property indicator_buffers 6
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double supUp[];
double supDn[];
double resUp[];
double resDn[];

// ------------------------------------------------------------------
input int    Qualified             = 1;                     // Minimum touches to qualify as support/resistance
input int    Tolerance             = 5;                     // Tolerance for Breackouts
input int    candlesBack           = 1000;                  // Periods
input double size                  = 10;                    // Pips Size of the zone
string       T1                    = "== Notifications =="; // === Notifications ===
bool         notifications         = false;                 // Notifications On?
bool         desktop_notifications = false;                 // Desktop MT4 Notifications
bool         email_notifications   = false;                 // Email Notifications
bool         push_notifications    = false;                 // Push Mobile Notifications
string       T2                    = "== Set Lines ==";     // === Set  Lines ===
bool         LinesOn               = true;                  // Line On?
color        LineUpClr             = clrBlue;               // Line Up Color:
color        LineDnClr             = clrRed;                // Line Down Color:
string       T3                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = clrGreen;              // Arrow Up Color:
color        ArrowDnClr            = clrCrimson;            // Arrow Down Color:
// ------------------------------------------------------------------

int nrZones = 20;

// clang-format off
// Mark: Oninit
int OnInit()
{
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 159);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(0, "Arrow Up");

   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 159);
    SetIndexLabel(1, "Arrow Dn");

   SetIndexBuffer(2, supUp, INDICATOR_DATA);
    // SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexLabel(2, "Support Up");

   SetIndexBuffer(3, supDn, INDICATOR_DATA);
    // SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexStyle(3, DRAW_NONE);
    SetIndexLabel(3, "Support Dn");

   SetIndexBuffer(4, resUp, INDICATOR_DATA);
    // SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexStyle(4, DRAW_NONE);
    SetIndexLabel(4, "Resistance Up");

   SetIndexBuffer(5, resDn, INDICATOR_DATA);
    // SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexStyle(5, DRAW_NONE);
    SetIndexLabel(5, "Resistance Dn");

    return (INIT_SUCCEEDED);
    // clang-format on
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    start = 1000;

    ArrowUp[i] = EMPTY_VALUE;
    ArrowDn[i] = EMPTY_VALUE;

    for (i = start; i >= 0; i--) {
        if (haveSupport(i)) {
            double lv = Low[i + 2];
            if (TouchesInZone("support", i, lv))
                if (Breackouts(i, lv)) {
                    ArrowUp[i + 2] = Low[i + 2];
                } else {
                    ArrowUp[i + 2] = EMPTY_VALUE;
                }
        }

        if (haveResistance(i)) {
            double lv = High[i + 2];
            if (TouchesInZone("resistance", i, lv))
                if (Breackouts(i, lv)) {
                    ArrowDn[i + 2] = High[i + 2];
                } else {
                    ArrowDn[i + 2] = EMPTY_VALUE;
                }
        }
    }

    ObjectsDeleteAll(0, "ob");
    for(int n = 1; n < candlesBack; n++ ) {
        if (ArrowUp[n] != EMPTY_VALUE ) {
            drawRectangle(n, ArrowUp[n]);
        } else if(ArrowDn[n] != EMPTY_VALUE)  {
            drawRectangle(n, ArrowDn[n]);
        }
    }

    RemoveOverlappingRectangles();
    return (rates_total);
}
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "ob"); }

bool haveSupport(int i)
{

    // TODO: signal up
    double op3 = iOpen(NULL, 0, i + 3);
    double hi3 = iHigh(NULL, 0, i + 3);
    double lo3 = iLow(NULL, 0, i + 3);
    double cl3 = iClose(NULL, 0, i + 3);
    double op2 = iOpen(NULL, 0, i + 2);
    double hi2 = iHigh(NULL, 0, i + 2);
    double lo2 = iLow(NULL, 0, i + 2);
    double cl2 = iClose(NULL, 0, i + 2);
    double op1 = iOpen(NULL, 0, i + 1);
    double hi1 = iHigh(NULL, 0, i + 1);
    double lo1 = iLow(NULL, 0, i + 1);
    double cl1 = iClose(NULL, 0, i + 1);
    double lo4 = iLow(NULL, 0, i + 4);

    return lo2 < lo1 && lo2 < lo3;
}

bool haveResistance(int i)
{
    // TODO: signal down
    double op3 = iOpen(NULL, 0, i + 3);
    double hi3 = iHigh(NULL, 0, i + 3);
    double lo3 = iLow(NULL, 0, i + 3);
    double cl3 = iClose(NULL, 0, i + 3);
    double op2 = iOpen(NULL, 0, i + 2);
    double hi2 = iHigh(NULL, 0, i + 2);
    double lo2 = iLow(NULL, 0, i + 2);
    double cl2 = iClose(NULL, 0, i + 2);
    double op1 = iOpen(NULL, 0, i + 1);
    double hi1 = iHigh(NULL, 0, i + 1);
    double lo1 = iLow(NULL, 0, i + 1);
    double cl1 = iClose(NULL, 0, i + 1);
    double hi4 = iHigh(NULL, 0, i + 4);

    return hi2 > hi1 && hi2 > hi3;
}

// Mark: Filters
bool TouchesInZone(string side, int i, double level)
{
    int    touches  = 0;
    double margin   = size * 10 * Point;
    double zone_max = level + margin;
    double zone_min = level - margin;

    for (int j = i - 1; j > 0; j--) {
        double op = iOpen(NULL, 0, j);
        double hi = iHigh(NULL, 0, j);
        double lo = iLow(NULL, 0, j);
        double cl = iClose(NULL, 0, j);

        if (side == "support") {
            if ((lo <= zone_max && lo >= zone_min) || (cl <= zone_max && cl >= zone_min)) touches++;
        }
        if (side == "resistance") {
            if ((hi <= zone_max && hi >= zone_min) || (cl <= zone_max && cl >= zone_min)) touches++;
        }
    }
    return touches >= Qualified;
}

bool Breackouts(int i, double level)
{
    int    T        = 0;
    double margin   = size * 10 * Point;
    double zone_max = level + margin;
    double zone_min = level - margin;

    for (int j = i - 1; j > 0; j--) {
        double op = iOpen(NULL, 0, j);
        double hi = iHigh(NULL, 0, j);
        double lo = iLow(NULL, 0, j);
        double cl = iClose(NULL, 0, j);

        if ((op <= zone_max && op >= zone_min) || (cl > zone_max && cl < zone_min)) T++;
        if ((op > zone_max && cl < zone_min)) T++;
        if ((op < zone_min && cl > zone_max)) T++;
    }
    return T <= Tolerance;
}

void drawRectangles()
{
    ObjectsDeleteAll(0, "ob");
    int i     = 1;
    int count = 0;
    while (count < nrZones && i < candlesBack) {
        if (resUp[i] != EMPTY_VALUE) {
            drawRectangle(i, 0);
            count++;
        }
        if (supUp[i] != EMPTY_VALUE) {
            drawRectangle(i, 1);
            count++;
        }
        i++;
    }
}

bool drawRectangle(int shift, double level)
{
    color  clr  = C'80,80,80';
    string name = "ob" + (string)shift;

    datetime time1  = iTime(NULL, 0, shift);
    datetime time2  = iTime(NULL, 0, 0);
    double margin   = size * 10 * Point;
    double price1   = level + margin;
    double price2   = level - margin;

    if (!ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2)) {
        Print(__FUNCTION__, ": failed to create a rectangle! Error code = ", GetLastError());
        return (false);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    return true;
}

void RemoveOverlappingRectangles()
{
    for (int i = 1; i < candlesBack; i++)
    {
        string name_i = "ob" + (string)i;
        if (ObjectFind(0, name_i) < 0) continue;

        double price1_i = ObjectGetDouble(0, name_i, OBJPROP_PRICE1);
        double price2_i = ObjectGetDouble(0, name_i, OBJPROP_PRICE2);

        double top_i = MathMax(price1_i, price2_i);
        double bot_i = MathMin(price1_i, price2_i);

        for (int j = i + 1; j < candlesBack; j++)
        {
            string name_j = "ob" + (string)j;
            if (ObjectFind(0, name_j) < 0) continue;

            double price1_j = ObjectGetDouble(0, name_j, OBJPROP_PRICE1);
            double price2_j = ObjectGetDouble(0, name_j, OBJPROP_PRICE2);

            double top_j = MathMax(price1_j, price2_j);
            double bot_j = MathMin(price1_j, price2_j);

            bool overlap = 
                (price1_i <= top_j && price1_i >= bot_j) ||
                (price2_i <= top_j && price2_i >= bot_j) ||
                (price1_j <= top_i && price1_j >= bot_i) ||
                (price2_j <= top_i && price2_j >= bot_i);

            if (overlap)
            {
                if (i < j)
                    ObjectDelete(0, name_i);
                else
                    ObjectDelete(0, name_j);
                break;
            }
        }
    }
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76077

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
