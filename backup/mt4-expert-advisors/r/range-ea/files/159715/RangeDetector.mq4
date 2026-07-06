//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76078

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
double range[];
double boxUp[];
double boxDn[];
double resDn[];

// ------------------------------------------------------------------
input int    RangeLength  = 20;  // Candles
input double ATR_Mult     = 1.0; // Multiplier
input int    ATR_Length   = 500; // ATR Length
input color  ColorRange   = clrSilver;
input color  ColorBreakUp = clrLimeGreen;
input color  ColorBreakDn = clrRed;

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
color        ArrowUpClr            = clrGreen;              // Arrow Up Color:
color        ArrowDnClr            = clrCrimson;            // Arrow Down Color:
// ------------------------------------------------------------------

int nrZones     = 20;
int candlesBack = 1000;

double RangeTop;
double RangeBot;

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

   SetIndexBuffer(2, range, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1, Gray);
    // SetIndexStyle(2, DRAW_NONE);
    SetIndexLabel(2, "range");



   SetIndexBuffer(3, boxUp, INDICATOR_DATA);
    // SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexStyle(3, DRAW_NONE);
    SetIndexLabel(3, "boxup");

   SetIndexBuffer(4, boxDn, INDICATOR_DATA);
    // SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexStyle(4, DRAW_NONE);
    SetIndexLabel(4, "boxdn");

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
    if (prev_calculated == 0) {
        start = rates_total - RangeLength - ATR_Length - 1; // Start from the end minus the range length and ATR length
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = start; i > 0; i--) {

        // 1. Calcular SMA central y ATR
        double ma  = iMA(NULL, 0, RangeLength, 0, MODE_SMA, PRICE_CLOSE, i);
        double atr = iATR(NULL, 0, ATR_Length, i) * ATR_Mult;

        RangeTop   = ma + atr;
        RangeBot   = ma - atr;
        double avg = (RangeTop + RangeBot) / 2;

        // 2. Verificar si las siguientes RangeLength barras están dentro del rango
        int count = 0;
        for (int n = 1; n <= RangeLength; n++) {
            if (fabs(iClose(NULL, 0, n + i) - ma) > atr) {
                count = 1;
            }
        }
        // traigo un rango y la ultima vela cierra adentro, hay que continuar
        if(count == 1 ) {
            if (range[i+1] != EMPTY_VALUE && close[i+1] < RangeTop && close[i+1] > RangeBot) {
                count = 0;
            }
        }


        // si count es 0, significa que todas las barras están dentro del rango
        if (count == 0) {
            int n = 0;
            while (fabs(iClose(NULL, 0, n + i) - ma) < atr) {
                range[i + n] = avg;
                boxUp[i + n] = RangeTop;
                boxDn[i + n] = RangeBot;
                n++;
            }
        }

        // Breackout
        if (close[i] > RangeTop && range[i + 1] != EMPTY_VALUE && range[i] == EMPTY_VALUE) {
            ArrowUp[i] = RangeTop;
            range[i]   = EMPTY_VALUE;
            boxUp[i]   = EMPTY_VALUE;
            boxDn[i]   = EMPTY_VALUE;
            notify(0);
        }
        if (close[i] < RangeBot && range[i + 1] != EMPTY_VALUE && range[i] == EMPTY_VALUE) {
            ArrowDn[i] = RangeBot;
            range[i]   = EMPTY_VALUE;
            boxUp[i]   = EMPTY_VALUE;
            boxDn[i]   = EMPTY_VALUE;
            notify(1);
        }
    }

    ObjectsDeleteAll(0, "range");
    for (int n = 1000; n > 0; n--) {
        int    count = 0;
        int    ini   = 0;
        int    end   = 0;
        double top   = 0;
        double bot   = 0;

        if (boxUp[n] != EMPTY_VALUE) {
            ini = n;
            top = boxUp[n];
            bot = boxDn[n];
            while (range[n] == range[n - 1] && n > 1) {
                n--;
            }
            end = n - 1;
            // n--;

            string side = "none";
            if (ArrowUp[n - 1] != EMPTY_VALUE) {
                side = "up";
            } else if (ArrowDn[n - 1] != EMPTY_VALUE) {
                side = "down";
            }
            drawRectangle(side, ini, end, top, bot);
        }
    }

    // drawRectangles();
    return (rates_total);
}
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "range"); }

// void drawRectangles()
// {
//     ObjectsDeleteAll(0, "range");
//     int    i     = 1;
//     int    count = 0;
//     int    ini   = 0;
//     int    end   = 0;
//     double top   = 0;
//     double bot   = 0;
//     while (count < nrZones && i < candlesBack) {
//         ini = 0;
//         end = 0;
//         top = 0;
//         bot = 0;
//         if (ArrowUp[i] != EMPTY_VALUE && ArrowUp[i] != 0) {
//             ini = i;
//             top = boxUp[i];
//             bot = boxDn[i];
//             while (range[i] != EMPTY_VALUE && i < candlesBack) {
//                 i++;
//             }
//             end = i - 1;
//             drawRectangle("up", ini, end, top, bot);
//             count++;
//             i++;
//             continue;
//         }
//         if (ArrowDn[i] != EMPTY_VALUE && ArrowDn[i] != 0) {
//             ini = i;
//             top = boxUp[i];
//             bot = boxDn[i];
//             while (range[i] != EMPTY_VALUE && i < candlesBack) {
//                 i++;
//             }
//             end = i - 1;
//             drawRectangle("down", ini, end, top, bot);
//             count++;
//             i++;
//             continue;
//         }
//         i++;
//     }
// }

bool drawRectangle(string side, int ini, int end, double top, double bot)
{
    color clr;
    if (side == "none") clr = ColorRange;
    if (side == "up") clr = ColorBreakUp;
    if (side == "down") clr = ColorBreakDn;

    string name = "range_" + (string)ini;

    datetime time1 = iTime(NULL, 0, end);
    // double   price1 = iHigh(NULL, 0, ini);

    datetime time2 = iTime(NULL, 0, ini);
    // double   price2 = iLow(NULL, 0, ini);

    if (!ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, top, time2, bot)) {
        Print(__FUNCTION__, ": failed to create a rectangle! Error code = ", GetLastError());
        return (false);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    return true;
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
//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76078

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