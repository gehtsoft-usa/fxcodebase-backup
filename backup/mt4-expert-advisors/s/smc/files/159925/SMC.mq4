// Available https://fxcodebase.com/code/viewtopic.php?f=38&t=76154
 
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
#property indicator_buffers 7
// #property indicator_plots 3
#property indicator_color1 Red

#property indicator_label2 "FVG Up"
#property  indicator_type2  DRAW_ARROW
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "FVG Down"
#property  indicator_type3  DRAW_ARROW
#property indicator_color3 clrRed
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

//--- input parameters
input string T0                    = "== MS Setup ==";      // MS Setup
bool         zzOn                  = false;                 // Draw MS Line?
int          InpDepth              = 10;                    // Depth
int          InpDeviation          = 5;                     // Deviation
int          InpBackstep           = 3;                     // Backstep
input color  zzClr                 = Navy;                  // ZigZag Color
input string T1                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:
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

//--- globals
int    ExtLevel          = 3; // recounting's depth of extremums
string ObjPrefix         = "ICT_MS_";
color  Text_color_Top    = LimeGreen;
color  Text_color_Bottom = Red;
double vShift            = 5; // Vertical Label shift

double fvg[10];

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

    IndicatorBuffers(7);

    if (InpBackstep >= InpDepth) {
        Print("Backstep cannot be greater or equal to Depth");
        return (INIT_FAILED);
    }
    //--- 2 additional buffers
    IndicatorBuffers(5);
    //---- drawing settings
    SetIndexStyle(0, DRAW_SECTION, EMPTY, 2, zzClr);
    if (!zzOn) {
        SetIndexStyle(0, DRAW_NONE);
    }
    //---- indicator buffers
    SetIndexBuffer(0, ExtZigzagBuffer);
    SetIndexBuffer(1, ExtHighBuffer);
    SetIndexStyle(1, DRAW_NONE);
    SetIndexBuffer(2, ExtLowBuffer);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexEmptyValue(0, 0.0);
    //---- indicator short name
    IndicatorShortName("ZigZag(" + string(InpDepth) + "," + string(InpDeviation) + "," + string(InpBackstep) + ")");

    //---
    SetIndexBuffer(3, BMSup, INDICATOR_DATA);
    SetIndexArrow(3, 233);
    SetIndexStyle(3, DRAW_NONE, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(4, BMSdn, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_NONE, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(4, 234);
    
    if (!ArrowsOn) {
        SetIndexStyle(3, DRAW_NONE);
        SetIndexStyle(4, DRAW_NONE);
    }

    SetIndexBuffer(5, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(5, 167);
    SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(6, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(6, 167);

    //---- initialization done
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { 
    ObjectsDeleteAll(0, ObjPrefix); 
    ObjectsDeleteAll(0, "line"); 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int    i, limit, counterZ, whatlookfor = 0;
    int    back, pos, lasthighpos = 0, lastlowpos = 0;
    double extremum;
    double curlow = 0.0, curhigh = 0.0, lasthigh = 0.0, lastlow = 0.0;
    
    //--- check for history and inputs
    if (rates_total < InpDepth || InpBackstep >= InpDepth) return (0);
    //--- first calculations
    if (prev_calculated == 0)
        limit = InitializeAll();
    else {
        //--- find first extremum in the depth ExtLevel or 100 last bars
        i = counterZ = 0;
        while (counterZ < ExtLevel && i < 100) {
            if (ExtZigzagBuffer[i] != 0.0) counterZ++;
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
                    if (ExtLowBuffer[pos] != 0 && ExtLowBuffer[pos] > extremum) ExtLowBuffer[pos] = 0.0;
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
                    if (ExtHighBuffer[pos] != 0 && ExtHighBuffer[pos] < extremum) ExtHighBuffer[pos] = 0.0;
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

    // al iniciar y en new candle
    if (prev_calculated == 0)
        for (i = 100; i > 0 && !IsStopped(); i--) {
            LoadPoints(i, 5);
            LabelLastPoint();
            FindBMS(i);
        }

    if (newCandle.IsNewCandle()) {
        for (i = 100; i > 0 && !IsStopped(); i--) {
            LoadPoints(i, 5);
            LabelLastPoint();
            FindBMS(i);
        }
    }

    // FindFVG(i);
    for (i = 1000; i > 0; i--) {
        int found = 0;

        // FVG alcista: Low[s] > High[s-2]
        double op = iOpen(NULL, 0, i);
        double hi = iHigh(NULL, 0, i);
        double lo = iLow(NULL, 0, i);
        double cl = iClose(NULL, 0, i);

        double op2 = iOpen(NULL, 0, i + 1);
        double hi2 = iHigh(NULL, 0, i + 1);
        double lo2 = iLow(NULL, 0, i + 1);
        double cl2 = iClose(NULL, 0, i + 1);

        double op3 = iOpen(NULL, 0, i + 2);
        double hi3 = iHigh(NULL, 0, i + 2);
        double lo3 = iLow(NULL, 0, i + 2);
        double cl3 = iClose(NULL, 0, i + 2);

        if (lo > hi3 && cl > op && cl2 > op2 && cl3 > op3) {
            ArrowUp[i + 1] = Low[i + 1];
        }
        
        if (hi < lo3 && cl < op && cl2 < op2 && cl3 < op3) {
            ArrowDn[i + 1] = High[i + 1];
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
        value = ExtZigzagBuffer[i];
        i++;
        if (value != EMPTY_VALUE && value > 0) count++;
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

    for (int i = 0; i < qnt + 1; i++) {
        double ValueToAdd = Value(index, i);
        int    candle     = Value(index, i, true);
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
    string   id    = ObjPrefix + candle(index);
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
        DrawLabel(1, "up", "BOS");
    }
    if (price(1) < price(2) && price(1) > price(3)) {
        DrawLabel(1, "up", "");
    }
    if (price(1) < price(2) && price(1) < price(3)) {
        DrawLabel(1, "dn", "BOS");
    }
    if (price(1) > price(2) && price(1) < price(3)) {
        DrawLabel(1, "dn", "");
    }
}

void FindBMS(int i)
{
    // if have Bull Struct:
    // if (price(2) > price(4) && price(3) > price(5) && price(3) < price(4)) {
    if (price(2) > price(3) && price(3) < price(4) && price(4) > price(5) & price(4) < price(2)) {
        if (price(1) < price(3) && price(2) > price(3)) {
            DrawLabel(1, "dn", "CHoCH");
            int _bar    = points[1].candle;
            BMSdn[_bar] = points[1].price;
            Notifications(1, _bar);
            drawLine(price(3), candle(3), _bar, Crimson);
        }
    }

    // if have Bull Struct:
    if (price(2) < price(3) && price(3) > price(4) && price(4) < price(5) & price(4) > price(2)) {
        if (price(1) > price(3) && price(2) < price(3)) {
            DrawLabel(1, "up", "CHoCH");
            int _bar    = points[1].candle;
            BMSup[_bar] = points[1].price;
            Notifications(0, _bar);
            drawLine(price(3), candle(3), _bar, Green);
        }
    }
}

void FindFVG(int i)
{
    ArrayInitialize(fvg, -1); // Limpia el array fvg
    int found = 0;

    for (int s = i+1; s < 1000 && found < 10; s++) {
        // FVG alcista: Low[s] > High[s-2]
        double op = iOpen(NULL,0,i);
        double hi = iHigh(NULL,0,i);
        double lo = iLow(NULL,0,i);        
        double cl = iClose(NULL,0,i);
        
        double op2 = iOpen(NULL,0,i +1);
        double hi2 = iHigh(NULL,0,i +1);
        double lo2 = iLow(NULL,0,i  +1);        
        double cl2 = iClose(NULL,0,i+1);
        
        double op3 = iOpen(NULL,0,i +2);
        double hi3 = iHigh(NULL,0,i +2);
        double lo3 = iLow(NULL,0,i  +2);        
        double cl3 = iClose(NULL,0,i+2);

        // if (low[s] > high[s - 2] && cl > op && cl2 > op2 && cl3 > op3) {
        if (lo > hi3 && cl > op && cl2 > op2 && cl3 > op3) {
            fvg[found] = s+1;
            found++;
            continue;
        }
        // FVG bajista: High[s] < Low[s-2]
        if (hi < lo3 && cl < op && cl2 < op2 && cl3 < op3) {
            fvg[found] = s+1;
            found++;
            continue;
        }
    }
    
    for (int p = 0; p < ArraySize(fvg); p++) {
        Print("FVG[", p, "] = ", fvg[p]);
        // Si el FVG está definido, dibuja la línea
        // y asigna el color según la posición en el array
        if (fvg[p] != -1) {
            string name = "FVG_" + IntegerToString(p);
            if (ObjectFind(0, name) < 0) {
                int    n     = fvg[p];
                double price = fabs(iOpen(NULL, 0, n) + iClose(NULL, 0, n)) / 2;
                line(price, n, 1);
            }
        }
    }
}


// Busca hacia atrás hasta encontrar 5 FVG y guarda el shift de la vela en el array fvg[]
// void FindFVG(const double &high[], const double &low[],  const double &open[],  const double &close[], int bars)
// {
//     ArrayInitialize(fvg, -1); // Limpia el array fvg
//     int found = 0;
//     for (int s = 2; s < bars - 1 && found < 5; s++) {
//         // FVG alcista: Low[s] > High[s-2]
//         double op  = open[s];
//         double cl  = close[s];
//         double op2 = open[s-1];
//         double cl2 = close[s-1];
//         double op3 = open[s-2];
//         double cl3 = close[s-2];

//         // if (low[s] > high[s - 2] && cl > op && cl2 > op2 && cl3 > op3) {
//         if (low[s] > high[s - 2] && cl > op ) {
//             fvg[found] = s;
//             found++;
//             continue;
//         }
//         // FVG bajista: High[s] < Low[s-2]
//         if (high[s] < low[s - 2] && cl < op) {
//             fvg[found] = s;
//             found++;
//             continue;
//         }
//     }
//     for (int p = 0; p < ArraySize(fvg); p++) {
//         Print("FVG[", p, "] = ", fvg[p]);
//         // Si el FVG está definido, dibuja la línea
//         // y asigna el color según la posición en el array
//         if (fvg[p] != -1) {
//             string name = "FVG_" + IntegerToString(p);
//             if (ObjectFind(0, name) < 0) {
//                 int    n     = fvg[p];
//                 double price = (high[n] + low[n]) / 2;
//                 line(price, n, 1);
//             }
//         }
//     }
// }

void drawLine(double price, int iniPos, int endPos, color clr)
{
    int    bars = Bars(NULL, 0);
    int    ini  = bars - iniPos;
    int    end  = bars - endPos;
    string name = "line" + (string)iTime(NULL, 0, ini);
    // ObjectCreate(0, name, OBJ_TREND, 0, iTime(NULL, 0, iniPos), price, iTime(NULL, 0, endPos), price);
    ObjectCreate(0, name, OBJ_TREND, 0, iTime(NULL, 0, ini), price, iTime(NULL, 0, end), price);
    ObjectSet(name, OBJPROP_RAY, false);
    ObjectSet(name, OBJPROP_COLOR, clr);
}

void line(double price, int iniPos, int endPos)
{
    string name = "fvg" + (string)iTime(NULL, 0, iniPos);
    ObjectCreate(0, name, OBJ_TREND, 0, iTime(NULL, 0, iniPos), price, iTime(NULL, 0, endPos), price);
    ObjectSet(name, OBJPROP_RAY, false);
    ObjectSet(name, OBJPROP_COLOR, Black);
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
        text += _Symbol + " " + GetTimeFrame(_Period) + " BOS UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " BOS DOWN ";

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

// Available https://fxcodebase.com/code/viewtopic.php?f=38&t=76154
 
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
