// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76202
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

#property indicator_buffers 1
#property indicator_chart_window

input int   bars            = 2; // Bars of max/min
input color GannSwing_Color = clrYellow;

double GannSwing[];
double us[];
double ds[];

extern color  TopColorHH    = clrBlue;
extern color  TopColorLH    = clrGray;
extern color  BotColorHL    = clrGray;
extern color  BotColorLL    = clrRed;
extern double Labeldistance = 0;
extern int    ATRPeriod     = 0;
extern int    TxtSize1      = 11;
extern int    TxtSize2      = 8;
extern string Fonts         = "Arial Black";

int init()
{
    IndicatorShortName("GannSwing");

    IndicatorBuffers(3);

    SetIndexStyle(0, DRAW_SECTION, STYLE_SOLID, 2, clrYellow);
    SetIndexBuffer(0, GannSwing);
    SetIndexLabel(0, "Gann Swing");

    SetIndexStyle(1, DRAW_NONE);
    SetIndexBuffer(1, us);

    SetIndexStyle(2, DRAW_NONE);
    SetIndexBuffer(2, ds);

    return (0);
}

int deinit()
{
    ObjectsDeleteAll();
    return (0);
}

int start()
{
    int i;
    int counted_bars = IndicatorCounted();
    int limit        = Bars - counted_bars - 1;

    for (i = limit; i > 0; i--) {
        ResetBuffers(i);
    }

    for (i = limit; i > 0; i--) {
        ds[i]   = 1;
        us[i]   = 1;
        bool hh = true;
        bool ll = true;
        for (int ii = 0; ii < bars; ++ii) {
            if (High[i + ii] <= High[i + ii + 1]) // si alguna de las velas desde 0 hasta bar cumple el pattern, le pone a us[i]=0
            {
                us[i] = 0;
                us[i] = 0;
            }
            if (Low[i + ii] >= Low[i + ii + 1]) {
                ds[i] = 0;
            }
        }

        // 4.If the next bar has a higher high and a higher low (or the same low) when
        // compared to the previous bar, then the swing line goes up connecting the high of the next bar
        if (us[i] == 0 && High[i] > High[i + 1] && Low[i] >= Low[i + 1]) {
            us[i] = 1; // Up
        }

        // 5. If the next bar has a lower high (or same high) and a
        // lower low when compared to the previous bar, then the swing line goes down connecting the low of the next bar
        if (ds[i] == 0 && High[i] <= High[i + 1] && Low[i] < Low[i + 1]) {
            ds[i] = 1; // Up
        }
    }

    int swingDir = 0;
    for (i = limit; i > 0; i--) {
        if (us[i] == 1) {
            if (swingDir == 1) {
                GannSwing[i] = High[i];
            } else if (swingDir == -1) {
                GannSwing[i] = High[i];
                swingDir     = 1;
            } else {
                swingDir     = 1;
                GannSwing[i] = High[i];
            }
        } else if (ds[i] == 1) {
            if (swingDir == -1) {
                GannSwing[i] = Low[i];
            } else if (swingDir == 1) {
                GannSwing[i] = Low[i];
                swingDir     = -1;
            } else {
                swingDir     = -1;
                GannSwing[i] = Low[i];
            }
        } else {
            if (High[i + 1] > High[i + 2] && Low[i + 1] < Low[i + 3]) {
                if (High[i] > High[i + 1] && Low[i] >= Low[i + 1]) {
                    if (swingDir == -1) {
                        GannSwing[i] = Low[i];
                    } else if (swingDir == 1) {
                        GannSwing[i] = Low[i];
                        swingDir     = -1;
                    }
                } else if (High[i] <= High[i + 1] && Low[i] < Low[i + 1]) {
                    if (swingDir == 1) {
                        GannSwing[i] = High[i];
                    } else if (swingDir == -1) {
                        GannSwing[i] = High[i];
                        swingDir     = 1;
                    }
                }
            }
        }
    }
    

    int Last      = 0;
    int LastIndex = 0;
    for (i = limit; i > 0; i--) {
        if (GannSwing[i] == High[i]) {
            if (Last == 1) {
                GannSwing[LastIndex] = EMPTY_VALUE;
            }
            Last      = 1;
            LastIndex = i;
        }

        if (GannSwing[i] == Low[i]) {
            if (Last == -1) {
                GannSwing[LastIndex] = EMPTY_VALUE;
            }
            Last      = -1;
            LastIndex = i;
        }
    }

    //-----------------

    for (int m = 1000; m > 0; m--) {
        if (GannSwing[m] == High[m])
            DrawHighLabel(m);
        if (GannSwing[m] == Low[m])
            DrawLowLabel(m);        
    }
    

    return (0);
}

void ResetBuffers(int shift)
{
    GannSwing[shift] = EMPTY_VALUE;
    us[shift]        = EMPTY_VALUE;
    ds[shift]        = EMPTY_VALUE;
    return;
}

// --------------------------------------------------------------------------------

void DrawHighLabel(int shift)
{
    string status      = "HH";
    double currentHigh = GannSwing[shift];
    double prev1;
    double prev2;

    for (int n = shift + 1; n < shift + 1000; n++) {
        if (GannSwing[n] != 0 ) {
            prev1 = GannSwing[n];
            for (int j = n + 1; j < n + 1000; j++) {
                if (GannSwing[j] != 0)
                    prev2 = GannSwing[j];
                break;
            }
        }
    }

    double position = GannSwing[shift] + (iATR(NULL, 0, 10, shift) * Labeldistance);

    if (currentHigh > prev1 && currentHigh > prev2) status = "HH  ";
    if (currentHigh < prev1 && currentHigh > prev2) status = "LH  ";

    ObjectCreate("statusLabel" + Time[shift], OBJ_TEXT, 0, Time[shift], position);
    ObjectSetText("statusLabel" + Time[shift], status, 10, "Arial Black", TopColorHH);
}

void DrawLowLabel(int shift)
{
    string status     = "LL";
    double currentLow = GannSwing[shift];
    double prev1;
    double prev2;

    for (int n = shift + 1; n < shift + 1000; n++) {
        if (GannSwing[n] != 0) {
            prev1 = GannSwing[n];
            for (int j = n + 1; j < n + 1000; j++) {
                if (GannSwing[j] != 0 )
                    prev2 = GannSwing[j];
                break;
            }
        }
    }
    double position = GannSwing[shift] - (iATR(NULL, 0, 10, shift) * Labeldistance);

    if (currentLow < prev1 && currentLow < prev2) status = "LL  ";
    if (currentLow > prev1 && currentLow < prev2) status = "HL  ";

    ObjectCreate("statusLabel" + Time[shift], OBJ_TEXT, 0, Time[shift], position);
    ObjectSetText("statusLabel" + Time[shift], status, 10, "Arial Black", BotColorLL);
}

void RemoveLabel(int shift) { ObjectDelete("statusLabel" + Time[shift]); }

void del_objF()
{
    int k = 0;
    while (k < ObjectsTotal()) {
        string ObjName = ObjectName(k);
        if (StringSubstr(ObjName, 0, StringLen("statusLabel")) == "statusLabel")
            ObjectDelete(ObjName);
        else
            k++;
    }
    return;
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76202
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