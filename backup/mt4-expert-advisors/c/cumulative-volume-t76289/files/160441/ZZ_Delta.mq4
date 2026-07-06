//Available @  https://fxcodebase.com/code/viewtopic.php?f=17&p=160322#p160322

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
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
input int InpDepth     = 12; // Depth
input int InpDeviation = 5;  // Deviation
input int InpBackstep  = 3;  // Backstep
//---- indicator buffers
double ExtZigzagBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];

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
    IndicatorBuffers(4);
    //---- drawing settings
    SetIndexStyle(0, DRAW_SECTION);
    //---- indicator buffers
    SetIndexBuffer(0, ExtZigzagBuffer);
    SetIndexBuffer(1, ExtHighBuffer);
    SetIndexBuffer(2, ExtLowBuffer);
    SetIndexEmptyValue(0, 0.0);

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

    for(int i = 0; i < Bars; i++) 
    {
        if(ExtZigzagBuffer[i] != 0.0)
        {
            int idx = ArraySize(zzIdxs);
            ArrayResize(zzIdxs, idx + 1);
            zzIdxs[idx] = i;
        }
    }

    // Calcula la distancia entre cada punto y el segundo siguiente
    for(int j = 0; j < ArraySize(zzIdxs) - 2; j++)
    {
        int idxActual = zzIdxs[j];
        int idxSalteado = zzIdxs[j + 2];

        double distPips = (ExtZigzagBuffer[idxActual] - ExtZigzagBuffer[idxSalteado]) / Point / 10.0;
        string labelName = "ZZ_Label_" + IntegerToString(j);

        double labelPrice = ExtZigzagBuffer[idxActual];
        // Si el punto coincide con ExtHighBuffer, corre la etiqueta 10 pips hacia arriba
        if(ExtHighBuffer[idxActual] == ExtZigzagBuffer[idxActual])
            labelPrice += 120 * Point;
            else
            labelPrice -= 20 * Point;

        ObjectCreate(0, labelName, OBJ_TEXT, 0, Time[idxActual], labelPrice);
        ObjectSetText(labelName, DoubleToString(distPips, 1), 10, "Arial", Black);
    }
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=17&p=160322#p160322

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