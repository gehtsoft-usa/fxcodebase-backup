//Available @  https://fxcodebase.com/code/posting.php?mode=reply&f=38&t=73941

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

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1
//---- plot Zigzag
#property indicator_label1 "Zigzag"
#property indicator_type1  DRAW_SECTION
#property indicator_color1 WhiteSmoke
#property indicator_style1 STYLE_DOT
#property indicator_width1 1

// #property indicator_label2 "Arrow Up"
// #property indicator_type2  DRAW_ARROW
// #property indicator_color2 Blue
// #property indicator_width2 1

// #property indicator_label3 "Arrow Dn"
// #property indicator_type3  DRAW_ARROW
// #property indicator_color3 Crimson
// #property indicator_width3 1

input double angle_up        = 22.5;
input double angle_dn        = 22.5;
input int    Width           = 0;
input int    Style           = 2;
input int    qnt_lev         = 8;
input color  ResistanceColor = clrBrown;
input color  SupportColor    = clrGreen;
input color  Level_0         = clrGray;
input bool   lev_V           = true;
input color  Level_V         = clrGray;
input int    Complect        = 0;

//--- input parameters
input int ExtDepth     = 21;
input int ExtDeviation = 5;
input int ExtBackstep  = 3;
//--- indicator buffers
double ZigzagBuffer[];  // main buffer
double HighMapBuffer[]; // highs
double LowMapBuffer[];  // lows
int    level = 3;       // recounting depth
double deviation;       // deviation in points

double ArrowUpBuffer[];
double ArrowDnBuffer[];

double FirstResistance;
double FirstSoport;
color  color_level;

int  timeFirstBar = 0;
int  flag;
bool work = true;

double LastHigh    = -1;
int    LastHighPos = -1;
double LastLow     = -1;
int    LastLowPos  = -1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ZigzagBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, HighMapBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(2, LowMapBuffer, INDICATOR_CALCULATIONS);

    // SetIndexBuffer(3, ArrowUpBuffer, INDICATOR_DATA);
    // SetIndexBuffer(4, ArrowDnBuffer, INDICATOR_DATA);

    // PlotIndexSetInteger(3, PLOT_ARROW, 233);
    // PlotIndexSetInteger(4, PLOT_ARROW, 234);

    //--- set short name and digits
    PlotIndexSetString(0, PLOT_LABEL, "ZigZag(" + (string)ExtDepth + "," + (string)ExtDeviation + "," + (string)ExtBackstep + ")");
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    //--- set empty value
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
    //--- to use in cycle
    deviation = ExtDeviation * _Point;
    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(const double &array[], int depth, int startPos)
{
    int index = startPos;
    //--- start index validation
    if (startPos < 0) {
        Print("Invalid parameter in the function iHighest, startPos =", startPos);
        return 0;
    }
    int size = ArraySize(array);
    //--- depth correction if need
    if (startPos - depth < 0) depth = startPos;
    double max = array[startPos];
    //--- start searching
    for (int i = startPos; i > startPos - depth; i--) {
        if (array[i] > max) {
            index = i;
            max   = array[i];
        }
    }
    //--- return index of the highest bar
    return (index);
}
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(const double &array[], int depth, int startPos)
{
    int index = startPos;
    //--- start index validation
    if (startPos < 0) {
        Print("Invalid parameter in the function iLowest, startPos =", startPos);
        return 0;
    }
    int size = ArraySize(array);
    //--- depth correction if need
    if (startPos - depth < 0) depth = startPos;
    double min = array[startPos];
    //--- start searching
    for (int i = startPos; i > startPos - depth; i--) {
        if (array[i] < min) {
            index = i;
            min   = array[i];
        }
    }
    //--- return index of the lowest bar
    return (index);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int    i     = 0;
    int    limit = 0, counterZ = 0, whatlookfor = 0;
    int    shift = 0, back = 0, lasthighpos = 0, lastlowpos = 0;
    double val = 0, res = 0;
    double curlow = 0, curhigh = 0, lasthigh = 0, lastlow = 0;
    //--- auxiliary enumeration
    enum looling_for {
        Pike = 1, // searching for next high
        Sill = -1 // searching for next low
    };
    //--- initializing
    if (prev_calculated == 0) {
        ArrayInitialize(ZigzagBuffer, 0.0);
        ArrayInitialize(HighMapBuffer, 0.0);
        ArrayInitialize(LowMapBuffer, 0.0);
    }
    //---
    if (rates_total < 100) return (0);
    //--- set start position for calculations
    if (prev_calculated == 0) limit = ExtDepth;

    //--- ZigZag was already counted before
    if (prev_calculated > 0) {
        i = rates_total - 1;

        int      count = 0;
        datetime tm[4];
        double   prices[4];
        for (int n = i; n >= 0 && count < 4; n--) {
            if (ZigzagBuffer[n] != 0.0 && ZigzagBuffer[n] != EMPTY_VALUE) {
                string vline_name = "ZZ_VLine_" + IntegerToString(count);
                DeleteObject(vline_name);
                DrawVLine(vline_name, time[n]);
                tm[count]     = time[n];
                prices[count] = ZigzagBuffer[n];
                count++;
            }
        }

        // print todos los prices
        for (int pos = 0; pos < count; pos++) {
            Print("Price pos: ", pos, " ", prices[pos]);
        }

        // - dibujar las lineas horizontales entre los puntos encontrados
        for (int j = 0; j < 3; j++) {
            string hline_name = "ZZ_HLine_" + IntegerToString(j);
            DeleteObject(hline_name);
            DrawHorizontalTrendLine(hline_name, tm[j + 1], tm[j], prices[j + 1], clrBlack, 1, STYLE_SOLID);

            if (prices[j + 1] < prices[j]) {
                for (int k = 0; k < qnt_lev; k++) {
                    string l_name = "gann_up_" + IntegerToString(k) + "__" + IntegerToString(j);
                    ObjectDelete(0, l_name);
                    // DrawHorizontalTrendLine(l_name, tm[j + 1], tm[j],prices[j + 1] + (100 * _Point * (k + 1)), clrGreen, 1, STYLE_DOT);
                    DrawHorizontalTrendLine(l_name, tm[j + 1], tm[j], GannPrice(prices[j + 1], (k + 1), 1), clrGreen, 1, STYLE_DOT);
                }
            }
            if (prices[j + 1] > prices[j]) {
                for (int k = 0; k < qnt_lev; k++) {
                    string l_name = "gann_dn_" + IntegerToString(k) + "__" + IntegerToString(j);
                    ObjectDelete(0, l_name);
                    DrawHorizontalTrendLine(l_name, tm[j + 1], tm[j], GannPrice(prices[j + 1], (k + 1), -1), clrRed, 1, STYLE_DOT);
                }
            }
        }

        //--- searching third extremum from the last uncompleted bar
        while (counterZ < level && i > rates_total - 100) {
            res = ZigzagBuffer[i];
            if (res != 0) counterZ++;
            i--;
        }
        i++;
        limit = i;

        //--- what type of exremum we are going to find
        if (LowMapBuffer[i] != 0) {
            curlow      = LowMapBuffer[i];
            whatlookfor = Pike;
        } else {
            curhigh     = HighMapBuffer[i];
            whatlookfor = Sill;
        }
        //--- chipping
        for (i = limit + 1; i < rates_total && !IsStopped(); i++) {
            ZigzagBuffer[i]  = 0.0;
            LowMapBuffer[i]  = 0.0;
            HighMapBuffer[i] = 0.0;
        }
    }

    //--- searching High and Low
    for (shift = limit; shift < rates_total && !IsStopped(); shift++) {
        val = low[iLowest(low, ExtDepth, shift)];
        if (val == lastlow)
            val = 0.0;
        else {
            lastlow = val;
            if ((low[shift] - val) > deviation)
                val = 0.0;
            else {
                for (back = 1; back <= ExtBackstep; back++) {
                    res = LowMapBuffer[shift - back];
                    if ((res != 0) && (res > val)) LowMapBuffer[shift - back] = 0.0;
                }
            }
        }
        if (low[shift] == val)
            LowMapBuffer[shift] = val;
        else
            LowMapBuffer[shift] = 0.0;
        //--- high
        val = high[iHighest(high, ExtDepth, shift)];
        if (val == lasthigh)
            val = 0.0;
        else {
            lasthigh = val;
            if ((val - high[shift]) > deviation)
                val = 0.0;
            else {
                for (back = 1; back <= ExtBackstep; back++) {
                    res = HighMapBuffer[shift - back];
                    if ((res != 0) && (res < val)) HighMapBuffer[shift - back] = 0.0;
                }
            }
        }
        if (high[shift] == val)
            HighMapBuffer[shift] = val;
        else
            HighMapBuffer[shift] = 0.0;
    }

    //--- last preparation
    if (whatlookfor == 0) // uncertain quantity
    {
        lastlow  = 0;
        lasthigh = 0;
    } else {
        lastlow  = curlow;
        lasthigh = curhigh;
    }

    //--- final rejection
    for (shift = limit; shift < rates_total && !IsStopped(); shift++) {
        res = 0.0;
        switch (whatlookfor) {
        case 0: // search for peak or lawn
            if (lastlow == 0 && lasthigh == 0) {
                if (HighMapBuffer[shift] != 0) {
                    lasthigh            = high[shift];
                    lasthighpos         = shift;
                    whatlookfor         = Sill;
                    ZigzagBuffer[shift] = lasthigh;
                    res                 = 1;
                }
                if (LowMapBuffer[shift] != 0) {
                    lastlow             = low[shift];
                    lastlowpos          = shift;
                    whatlookfor         = Pike;
                    ZigzagBuffer[shift] = lastlow;
                    res                 = 1;
                }
            }
            break;
        case Pike: // search for peak
            if (LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < lastlow && HighMapBuffer[shift] == 0.0) {
                ZigzagBuffer[lastlowpos] = 0.0;
                lastlowpos               = shift;
                lastlow                  = LowMapBuffer[shift];
                ZigzagBuffer[shift]      = lastlow;
                res                      = 1;
            }
            if (HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0) {
                lasthigh            = HighMapBuffer[shift];
                lasthighpos         = shift;
                ZigzagBuffer[shift] = lasthigh;
                whatlookfor         = Sill;
                res                 = 1;
            }
            break;
        case Sill: // search for lawn
            if (HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > lasthigh && LowMapBuffer[shift] == 0.0) {
                ZigzagBuffer[lasthighpos] = 0.0;
                lasthighpos               = shift;
                lasthigh                  = HighMapBuffer[shift];
                ZigzagBuffer[shift]       = lasthigh;
            }
            if (LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0) {
                lastlow             = LowMapBuffer[shift];
                lastlowpos          = shift;
                ZigzagBuffer[shift] = lastlow;
                whatlookfor         = Pike;
            }
            break;
        default:
            return (rates_total);
        }
    }

    //---+ Fin ZZ BÁSICO +---------------------------------------------------------------------+

    //--- return value of prev_calculated for next call
    return (rates_total);
}

//---+ Funciones de Gann +---------------------------------------------------------------------+

void DrawLine(string name, int index1, double price1, int index2, double price2, color clr, int width = 1, int style = STYLE_SOLID)
{
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_TREND, 0, 0, 0);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
    ObjectSetInteger(0, name, OBJPROP_STYLE, style);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);

    datetime time1 = iTime(_Symbol, _Period, index1);
    datetime time2 = iTime(_Symbol, _Period, index2);

    ObjectMove(0, name, 0, time1, price1);
    ObjectMove(0, name, 1, time2, price2);
}

void DrawHLine(string name, double price, color clr, int width = 1, int style = STYLE_SOLID)
{
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
    ObjectSetInteger(0, name, OBJPROP_STYLE, style);
    ObjectSetDouble(0, name, OBJPROP_PRICE, price);
}

void DeleteObject(string name)
{
    if (ObjectFind(0, name) != -1) {
        ObjectDelete(0, name);
    }
}

void DrawVLine(string name, datetime time, color clr = Black, int width = 1, int style = STYLE_SOLID)
{

    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_VLINE, 0, time, 0);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
    ObjectSetInteger(0, name, OBJPROP_STYLE, style);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
}

void DrawHorizontalTrendLine(string name, datetime time1, datetime time2, double price, color clr = Black, int width = 1, int style = STYLE_DASH)
{
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_TREND, 0, time1, price, time2, price);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
    ObjectSetInteger(0, name, OBJPROP_STYLE, style);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);

    ObjectMove(0, name, 0, time1, price);
    ObjectMove(0, name, 1, time2, price);
}

double GannPrice(double price, double n, double side)
{
    double gann = 0;
    double gr   = side == 1 ? n * angle_up / 180.0 : n * angle_dn / 180.0;
    gann        = side == 1 ? MathSqrt(price / _Point) + gr : MathSqrt(price / _Point) - gr;
    gann        = MathPow(gann, 2) * _Point;

    return gann;
}
//Available @  https://fxcodebase.com/code/posting.php?mode=reply&f=38&t=73941

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