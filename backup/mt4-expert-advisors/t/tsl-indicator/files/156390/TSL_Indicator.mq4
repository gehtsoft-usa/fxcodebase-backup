// Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75126

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
#property indicator_buffers 7
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double DnBand[];
double UpBand[];
double Draw_DnBand[];
double Draw_UpBand[];
double Trend[];

// ------------------------------------------------------------------
input double upips = 50; // Pips from highest / lowest:
int    periods               = 20; // Min 3 candles back
input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
string       T2                    = "== Set Lines ==";     // === Set  Lines ===
bool         LinesOn               = false;                 // Line On?
color        LineUpClr             = clrGray;               // Line Up Color:
color        LineDnClr             = clrGray;                // Line Down Color:
input string T3                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = clrBlue;               // Arrow Up Color:
color        ArrowDnClr            = clrRed;                // Arrow Down Color:
// ------------------------------------------------------------------

// Mark: Oninit
int OnInit()
{
    SetIndexBuffer(0, Draw_DnBand, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 1, LineUpClr);
    SetIndexLabel(0, "Line Up");

    SetIndexBuffer(1, Draw_UpBand, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 1, LineDnClr);
    SetIndexLabel(1, "Line Dn");
    SetIndexEmptyValue(0, 0.0); 

    SetIndexBuffer(2, DnBand, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexBuffer(3, UpBand, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_NONE);

    SetIndexBuffer(4, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(4, 108);
    SetIndexStyle(4, DRAW_NONE, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(4, "Arrow Up");

    SetIndexBuffer(5, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_NONE, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(5, 108);
    SetIndexLabel(5, "Arrow Dn");

    if (!ArrowsOn) {
        SetIndexStyle(4, DRAW_NONE);
        SetIndexStyle(5, DRAW_NONE);
    }

    SetIndexBuffer(6, Trend, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_NONE);

    return (INIT_SUCCEEDED);
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) { start = rates_total - periods; } else { start = rates_total - (prev_calculated - 1); }

    for (i = start; i >= 0; i--) {

        double distance = upips * 10 * _Point;
        UpBand[i]      = iLow(NULL, 0, i)+distance;
        DnBand[i]      = iHigh(NULL, 0, i)-distance;
        
        Draw_DnBand[i] = 0;
        Draw_UpBand[i] = EMPTY_VALUE;
        ArrowUp[i]     = EMPTY_VALUE;
        ArrowDn[i]     = EMPTY_VALUE;
        Trend[i]       = Trend[i + 1] == EMPTY_VALUE ? 0 : Trend[i + 1];

        // determinar tendencia
        if (high[i] > Draw_UpBand[i + 1] && Trend[i + 1] == 0) {
            Trend[i] = 1;
        }
        if (low[i] < Draw_DnBand[i + 1] && Trend[i + 1] == 1) {
            Trend[i] = 0;
        }

        // Up trend:
        if (Trend[i] == 1) {
            // if(Draw_DnBand[i + 1]==0) Draw_DnBand[i + 1] = DnBand[i + 2];            
            Draw_DnBand[i] = MathMax(Draw_DnBand[i + 1], DnBand[i + 1]);
            if (Trend[i + 1] == 0) {
                // Draw_DnBand[i + 1] = Draw_UpBand[i + 1];
                ArrowUp[i]         = Draw_DnBand[i];
                if (IsNewCandle()) notify(0);
            }
        }

        // Down Trend
        if (Trend[i] == 0) {
            // if(Draw_UpBand[i + 1]==0)Draw_UpBand[i + 1] = UpBand[i + 2];
            
            Draw_UpBand[i] = MathMin(Draw_UpBand[i + 1] ,UpBand[i + 2]);
            if (Trend[i + 1] == 1) {
                // Draw_UpBand[i + 1] = Draw_DnBand[i + 1];
                ArrowDn[i]         = Draw_UpBand[i];
                if (IsNewCandle()) notify(1);
            }
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