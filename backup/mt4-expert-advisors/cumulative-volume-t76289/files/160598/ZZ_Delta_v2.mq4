/* HEADER:BEGIN */
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
/* HEADER:END */

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Red

//---- indicator parameters
input int    InpDepth      = 12;                 // Depth
input int    InpDeviation  = 5;                  // Deviation
input int    InpBackstep   = 3;                  // Backstep
input string       T2            = "== Set Labels =="; // Set Arrows
input color  positiveColor = clrBlue;            // Color for positive
input color  negativeColor = clrRed;             // Color for negative
input double distPositive  = 120;                // Distance for Higher Label
input double distNegative  = 80;                 // Distance for Lower Label
input string       T3            = "== Set Arrows =="; // Set Arrows
input bool         ArrowsOn      = true;               // Arrows On?
input color        ArrowUpClr    = clrBlue;            // Arrow Up Color:
input color        ArrowDnClr    = clrRed;             // Arrow Down Color:

//---- indicator buffers
double ExtZigzagBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ArrowUp[];
double ArrowDn[];

double highDistance[];
double lowDistance[];

//--- globals
int ExtLevel = 3; // recounting's depth of extremums

void OnDeinit(const int reason) { ObjectsDeleteAll(0, "ZZ_Label"); }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    if (InpBackstep >= InpDepth) {
        Print("Backstep cannot be greater or equal to Depth");
        return (INIT_FAILED);
    }
    //--- 2 additional buffers
    IndicatorBuffers(5);
    //---- drawing settings
    SetIndexStyle(0, DRAW_SECTION);
    
    //---- indicator buffers
    SetIndexBuffer(0, ExtZigzagBuffer);
    SetIndexBuffer(1, ExtHighBuffer);
    SetIndexStyle(1, DRAW_NONE);
    SetIndexBuffer(2, ExtLowBuffer);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexEmptyValue(0, 0.0);

    SetIndexBuffer(3, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(3, 233);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(3, "Arrow Up");
    
    SetIndexBuffer(4, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(4, 234);
    SetIndexLabel(4, "Arrow Dn");
    
    if (!ArrowsOn) {
        SetIndexStyle(3, DRAW_NONE);
        SetIndexStyle(4, DRAW_NONE);
    }
    
    SetIndexBuffer(5, highDistance, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_NONE);
    SetIndexLabel(5, "High Delta");
    SetIndexBuffer(6, lowDistance, INDICATOR_DATA);
    SetIndexStyle(6, DRAW_NONE);
    SetIndexLabel(6, "Low Delta");

    //---- indicator short name
    IndicatorShortName("ZigZag(" + string(InpDepth) + "," + string(InpDeviation) + "," + string(InpBackstep) + ")");
    //---- initialization done
    return (INIT_SUCCEEDED);
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

    if (prev_calculated > 0 && ArrowsOn == true) {
        int    countLows  = 0;
        int    countHighs = 0;
        double lows[3];
        double highs[3];
        int posArrowLow;
        int posArrowHigh;
        for (int n = 0; n <= 500 && countLows < 3; n++) {
            if (ExtLowBuffer[n] != 0.0 && ExtZigzagBuffer[n] != 0) {
                lows[countLows] = ExtLowBuffer[n];
                if(countLows == 0) posArrowLow = n;                
                // Print("LOW: count: ", count, " value: ", lows[count]);
                countLows++;
            }
            if (countLows == 3 && lows[0] > lows[1] && lows[1] > lows[2]) {
                ArrowUp[posArrowLow] = Low[posArrowLow]- (distNegative * 2 * Point);
            }
        }
        for (int n = 0; n <= 500 && countHighs < 3; n++) {
            if (ExtHighBuffer[n] != 0.0 && ExtZigzagBuffer[n] != 0) {
                highs[countHighs] = ExtHighBuffer[n];
                if(countHighs == 0)
                    posArrowHigh = n;
                    // Print("HIGH: count: ", countHighs, " value: ", highs[countHighs]);
                    countHighs++;
                }
                if (countHighs == 3 && highs[0] < highs[1] && highs[1] < highs[2]) {
                    ArrowDn[posArrowHigh] = High[posArrowHigh] + (distPositive *1.5 * Point);
                }
            }
            
            // Delete fake arrows
            for (int n = 0; n <= 100; n++) {
                if(ArrowUp[n] != 0 && (ExtZigzagBuffer[n] == 0 || ExtZigzagBuffer[n] == EMPTY_VALUE)) 
                ArrowUp[n] = 0;
            }
                for (int n = 0; n <= 100; n++) {
                if(ArrowDn[n] != 0 && (ExtZigzagBuffer[n] == 0 || ExtZigzagBuffer[n] == EMPTY_VALUE)) 
                    ArrowDn[n] = 0;
            }

    }

    LabelZigZagDistances();

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

void LabelZigZagDistances()
{
    ObjectsDeleteAll(0, "ZZ_Label");

    // Guarda los índices de los puntos ZigZag
    int zzIdxs[];
    ArrayResize(zzIdxs, 0);

    for (int i = 0; i < Bars; i++) {
        if (ExtZigzagBuffer[i] != 0.0) {
            int idx = ArraySize(zzIdxs);
            ArrayResize(zzIdxs, idx + 1);
            zzIdxs[idx] = i;
        }
    }

    // Calcula la distancia entre cada punto y el segundo siguiente
    for (int j = 0; j < ArraySize(zzIdxs) - 2; j++) {
        int idxActual   = zzIdxs[j];
        int idxSalteado = zzIdxs[j + 2];

        double distPips  = (ExtZigzagBuffer[idxActual] - ExtZigzagBuffer[idxSalteado]) / Point / 10.0;
        string labelName = "ZZ_Label_" + IntegerToString(j);

        double labelPrice = ExtZigzagBuffer[idxActual];
        // Si el punto coincide con ExtHighBuffer, corre la etiqueta 10 pips hacia arriba
        if (ExtHighBuffer[idxActual] == ExtZigzagBuffer[idxActual])
        {
            labelPrice += distPositive * Point;
            highDistance[idxActual] = distPips;
        }
        else
        {
            labelPrice -= distNegative * Point;
            lowDistance[idxActual] = distPips;

        }

        ObjectCreate(0, labelName, OBJ_TEXT, 0, Time[idxActual], labelPrice);
        ObjectSetText(labelName, DoubleToString(distPips, 1), 10, "Arial", ((distPips > 0) ? positiveColor : negativeColor));
    }
}

/* FOOTER:BEGIN */
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+
/* FOOTER:END */