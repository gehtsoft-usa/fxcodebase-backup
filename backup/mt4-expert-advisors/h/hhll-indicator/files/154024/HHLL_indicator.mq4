// Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74512

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
#property indicator_buffers 8
#property indicator_plots 8
#property indicator_color1 Red

//--- input parameters
input string T0                    = "== ZigZag Setup ==";  // ZigZag Setup
input bool   zzOn                  = false;                 // Draw ZigZag Line?
input int    InpDepth              = 10;                    // Depth
input int    InpDeviation          = 5;                     // Deviation
input int    InpBackstep           = 3;                     // Backstep
input color  zzClr                 = Navy;                  // ZigZag Color
string       T1                    = "== Set Arrows ==";    // Set Arrows
bool         ArrowsOn              = false;                 // Arrows On?
color        ArrowUpClr            = clrBlue;               // Arrow Up Color:
color        ArrowDnClr            = clrRed;                // Arrow Down Color:
input string T2                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

//---- indicator buffers
double ExtZigzagBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double BMSup[];
double BMSdn[];
double Center[];
double CenterUp[];
double CenterDn[];

//--- globals
int    ExtLevel          = 3; // recounting's depth of extremums
string ObjPrefix         = "ZigZag";
color  Text_color_Top    = LimeGreen;
color  Text_color_Bottom = Red;
double vShift            = 5; // Vertical Label shift

struct zzPoint {
    double price;
    int    candle;
};
zzPoint points[];
int     Notification_last_candle;
// ------------------------------------------------------------------
class CNewCandle
{
  private:
    int    _initialCandles;
    string _symbol;
    int    _tf;

  public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
    CNewCandle()
    {
        // toma los valores del chart actual
        _initialCandles = iBars(Symbol(), Period());
        _symbol         = Symbol();
        _tf             = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if (_currentCandles > _initialCandles) {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
// NOTE: OnInit
int OnInit()
{

    //  IndicatorBuffers(5);

    if (InpBackstep >= InpDepth) {
        Print("Backstep cannot be greater or equal to Depth");
        return (INIT_FAILED);
    }
    //--- 2 additional buffers
    IndicatorBuffers(8);
    //---- drawing settings
    SetIndexStyle(0, DRAW_SECTION, EMPTY, 2, zzClr);
    if (!zzOn) {
        SetIndexStyle(0, DRAW_NONE);
    }
    //---- indicator buffers
    SetIndexBuffer(0, ExtZigzagBuffer);
    SetIndexBuffer(1, ExtHighBuffer);
    SetIndexBuffer(2, ExtLowBuffer);
    SetIndexEmptyValue(0, 0.0);
    //---- indicator short name
    IndicatorShortName("ZigZag(" + string(InpDepth) + "," + string(InpDeviation) + "," + string(InpBackstep) + ")");

    //---
    SetIndexBuffer(3, BMSup, INDICATOR_DATA);
    SetIndexArrow(3, 233);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(4, BMSdn, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(4, 234);
    if (!ArrowsOn) {
        SetIndexStyle(3, DRAW_NONE);
        SetIndexStyle(4, DRAW_NONE);
    }
    SetIndexBuffer(5, Center, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_LINE, EMPTY, 1, Black);
    SetIndexBuffer(6, CenterUp, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_LINE, EMPTY, 2, Green);
    SetIndexBuffer(7, CenterDn, INDICATOR_DATA);
    SetIndexStyle(7, DRAW_LINE, EMPTY, 2, Crimson);

    //---- initialization done
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0, ObjPrefix);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
    int    i, limit, counterZ, whatlookfor = 0;
    int    back, pos, lasthighpos = 0, lastlowpos = 0;
    double extremum;
    double curlow = 0.0, curhigh = 0.0, lasthigh = 0.0, lastlow = 0.0;

    //--- check for history and inputs
    if (rates_total < InpDepth || InpBackstep >= InpDepth)
        return (0);

    //--- first calculations
    if (prev_calculated == 0)
        limit = InitializeAll();
    else {
        //--- find first extremum in the depth ExtLevel or 100 last bars
        i = counterZ = 0;
        while (counterZ < ExtLevel && i < 100) {
            if (ExtZigzagBuffer[i] != 0.0)
                counterZ++;
            i++;
        }
        //--- no extremum found - recounting all from begin
        if (counterZ == 0)
            limit = InitializeAll();
        else {
            //--- set start position to found extremum position
            limit = i - 1;
            //--- what kind of extremum?
            if (ExtLowBuffer[i] != 0.0) {
                //--- low extremum
                curlow = ExtLowBuffer[i];
                //--- will look for the next high extremum
                whatlookfor = 1;
            } else {
                //--- high extremum
                curhigh = ExtHighBuffer[i];
                //--- will look for the next low extremum
                whatlookfor = -1;
            }
            //--- clear the rest data
            for (i = limit - 1; i >= 0; i--) {
                ExtZigzagBuffer[i] = 0.0;
                ExtLowBuffer[i]    = 0.0;
                ExtHighBuffer[i]   = 0.0;
            }
        }
    }

    //--- main loop
    for (i = limit; i >= 0; i--) {
        //--- find lowest low in depth of bars
        extremum = low[iLowest(NULL, 0, MODE_LOW, InpDepth, i)];
        //--- this lowest has been found previously
        if (extremum == lastlow)
            extremum = 0.0;
        else {
            //--- new last low
            lastlow = extremum;
            //--- discard extremum if current low is too high
            if (low[i] - extremum > InpDeviation * Point)
                extremum = 0.0;
            else {
                //--- clear previous extremums in backstep bars
                for (back = 1; back <= InpBackstep; back++) {
                    pos = i + back;
                    if (ExtLowBuffer[pos] != 0 && ExtLowBuffer[pos] > extremum)
                        ExtLowBuffer[pos] = 0.0;
                }
            }
        }
        //--- found extremum is current low
        if (low[i] == extremum)
            ExtLowBuffer[i] = extremum;
        else
            ExtLowBuffer[i] = 0.0;
        //--- find highest high in depth of bars
        extremum = high[iHighest(NULL, 0, MODE_HIGH, InpDepth, i)];
        //--- this highest has been found previously
        if (extremum == lasthigh)
            extremum = 0.0;
        else {
            //--- new last high
            lasthigh = extremum;
            //--- discard extremum if current high is too low
            if (extremum - high[i] > InpDeviation * Point)
                extremum = 0.0;
            else {
                //--- clear previous extremums in backstep bars
                for (back = 1; back <= InpBackstep; back++) {
                    pos = i + back;
                    if (ExtHighBuffer[pos] != 0 && ExtHighBuffer[pos] < extremum)
                        ExtHighBuffer[pos] = 0.0;
                }
            }
        }
        //--- found extremum is current high
        if (high[i] == extremum)
            ExtHighBuffer[i] = extremum;
        else
            ExtHighBuffer[i] = 0.0;
    }
    //--- final cutting
    if (whatlookfor == 0) {
        lastlow  = 0.0;
        lasthigh = 0.0;
    } else {
        lastlow  = curlow;
        lasthigh = curhigh;
    }
    for (i = limit; i >= 0; i--) {
        switch (whatlookfor) {
        case 0: // look for peak or lawn
            if (lastlow == 0.0 && lasthigh == 0.0) {
                if (ExtHighBuffer[i] != 0.0) {
                    lasthigh           = High[i];
                    lasthighpos        = i;
                    whatlookfor        = -1;
                    ExtZigzagBuffer[i] = lasthigh;
                }
                if (ExtLowBuffer[i] != 0.0) {
                    lastlow            = Low[i];
                    lastlowpos         = i;
                    whatlookfor        = 1;
                    ExtZigzagBuffer[i] = lastlow;
                }
            }
            break;
        case 1: // look for peak
            if (ExtLowBuffer[i] != 0.0 && ExtLowBuffer[i] < lastlow && ExtHighBuffer[i] == 0.0) {
                ExtZigzagBuffer[lastlowpos] = 0.0;
                lastlowpos                  = i;
                lastlow                     = ExtLowBuffer[i];
                ExtZigzagBuffer[i]          = lastlow;
            }
            if (ExtHighBuffer[i] != 0.0 && ExtLowBuffer[i] == 0.0) {
                lasthigh           = ExtHighBuffer[i];
                lasthighpos        = i;
                ExtZigzagBuffer[i] = lasthigh;
                whatlookfor        = -1;
            }
            break;
        case -1: // look for lawn
            if (ExtHighBuffer[i] != 0.0 && ExtHighBuffer[i] > lasthigh && ExtLowBuffer[i] == 0.0) {
                ExtZigzagBuffer[lasthighpos] = 0.0;
                lasthighpos                  = i;
                lasthigh                     = ExtHighBuffer[i];
                ExtZigzagBuffer[i]           = lasthigh;
            }
            if (ExtLowBuffer[i] != 0.0 && ExtHighBuffer[i] == 0.0) {
                lastlow            = ExtLowBuffer[i];
                lastlowpos         = i;
                ExtZigzagBuffer[i] = lastlow;
                whatlookfor        = 1;
            }
            break;
        }
    }

    int start;
    if (prev_calculated == 0) {
        start = rates_total - InpDepth;
    } else {
        start = 50;
    }

    // al iniciar y en new candle
    for (i = start; i > 0; i--) {
        LoadPoints(i, 5);
        LabelLastPoint();

        double average = (price(1) + price(2) + price(0)) / 3;
        Center[i]      = average;
        if (close[i] > average) {
            CenterUp[i] = average;
            if (CenterUp[i + 1] == EMPTY_VALUE)
                CenterUp[i + 1] = Center[i + 1];
        } else {
            CenterDn[i] = EMPTY_VALUE;
        }
        if (close[i] < average) {
            CenterDn[i] = average;
            if (CenterDn[i + 1] == EMPTY_VALUE)
                CenterDn[i + 1] = Center[i + 1];
        } else {
            CenterDn[i] = EMPTY_VALUE;
        }
    }

    //--- done
    return (rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitializeAll()
{
    ArrayInitialize(ExtZigzagBuffer, 0.0);
    ArrayInitialize(ExtHighBuffer, 0.0);
    ArrayInitialize(ExtLowBuffer, 0.0);
    //--- first counting position
    return (Bars - InpDepth);
}

//+------------------------------------------------------------------+

// NOTE: AT
// ------------------------------------------------------------------
// return specific point of zz
double Value(int i, int shift, bool candle = false)
{
    int    count = -1;
    double value = 0;
    int    bars  = Bars(NULL, 0);

    while (count != shift) {
        if (i + 1 >= ArraySize(ExtZigzagBuffer))
            break;

        value = ExtZigzagBuffer[i];
        i++;
        if (value != EMPTY_VALUE && value > 0)
            count++;
    }

    if (candle) {
        return bars - i + 1;
    }

    return value;
}

void LoadPoints(int index, int qnt)
{
    ArrayFree(points);
    ArrayResize(points, 0);

    for (int i = 0; i < qnt; i++) {
        double ValueToAdd = Value(index, i);
        int    candle     = (int)Value(index, i, true);
        int    t          = ArraySize(points);
        if (ArrayResize(points, t + 1)) {
            points[t].price  = ValueToAdd;
            points[t].candle = candle;
        }
    }
}

void PrintPoints()
{
    for (int i = 0; i < ArraySize(points); i++) {
        Print("Array points, value: ", i, " price:", points[i].price);
        Print("Array points, value: ", i, " candle:", points[i].candle);
    }
}

double price(int i) { return points[i].price; }
int    candle(int i) { return points[i].candle; }

void DrawLabel(int index, string side, string txt)
{
    int      bars  = Bars(NULL, 0);
    string   id    = ObjPrefix + (string)candle(index);
    double   price = price(index) + (vShift * _Point);
    datetime time  = iTime(_Symbol, _Period, bars - candle(index));
    color    clr   = side == "up" ? Text_color_Top : Text_color_Bottom;

    if (ObjectCreate(0, id, OBJ_TEXT, 0, time, price)) {
        ObjectSetString(0, id, OBJPROP_FONT, "Calibri");
        ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 9);
        ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    }
    ObjectSetString(0, id, OBJPROP_TEXT, txt);
}

void LabelLastPoint()
{
    if (price(1) > price(2) && price(1) > price(3)) {
        DrawLabel(1, "up", "HH");
    }
    if (price(1) < price(2) && price(1) > price(3)) {
        DrawLabel(1, "up", "HL");
    }
    if (price(1) < price(2) && price(1) < price(3)) {
        DrawLabel(1, "dn", "LL");
    }
    if (price(1) > price(2) && price(1) < price(3)) {
        DrawLabel(1, "dn", "LH");
    }
}

void FindBMS(int i)
{
    // if have Bull Struct:
    if (price(2) > price(4) && price(3) > price(5) && price(3) < price(4)) {
        if (price(1) < price(2) && price(1) < price(3)) {
            DrawLabel(1, "dn", "BMS");
            int _bar    = points[1].candle;
            BMSdn[_bar] = points[1].price;
            Notifications(1, _bar);
        }
    }

    // if have Bull Struct:
    if (price(2) < price(4) && price(3) < price(5) && price(3) > price(4)) {
        if (price(1) > price(2) && price(1) > price(3)) {
            DrawLabel(1, "up", "BMS");
            int _bar    = points[1].candle;
            BMSup[_bar] = points[1].price;
            Notifications(0, _bar);
        }
    }
}

// ------------------------------------------------------------------
void Notifications(int type, int candle)
{
    if (candle == Notification_last_candle) {
        return;
    }
    Notification_last_candle = candle;

    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BMS UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " BMS DOWN ";

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
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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