//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76183

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
#property indicator_buffers 5
//---- indicator parameters
input int InpDepth     = 12; // Depth
input int InpDeviation = 5;  // Deviation
input int InpBackstep  = 3;  // Backstep
//---- indicator buffers
double zz[];
double HighBuffer[];
double LowBuffer[];

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

//--- globals
int ExtLevel = 3; // recounting's depth of extremums

double lastzz;
double nextzz;
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
    SetIndexStyle(0, DRAW_SECTION, EMPTY, 1, RoyalBlue);
    //---- indicator buffers
    SetIndexBuffer(0, zz);
    SetIndexBuffer(1, HighBuffer);
    SetIndexBuffer(2, LowBuffer);
    
   SetIndexBuffer(3, ArrowUp, INDICATOR_DATA); 
   SetIndexArrow(3, 233);
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, Blue);
   SetIndexBuffer(4, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, Crimson);
   SetIndexArrow(4, 234);

    SetIndexEmptyValue(0, 0.0);

    SetIndexStyle(1, DRAW_NONE);
    SetIndexStyle(2, DRAW_NONE);

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
            if (zz[i] != 0.0) counterZ++;
            i++;
        }
        //--- no extremum found - recounting all from begin
        if (counterZ == 0)
            limit = InitializeAll();
        else {
            //--- set start position to found extremum position
            limit = i - 1;
            //--- what kind of extremum?
            if (LowBuffer[i] != 0.0) {
                //--- low extremum
                curlow = LowBuffer[i];
                //--- will look for the next high extremum
                whatlookfor = 1;
            } else {
                //--- high extremum
                curhigh = HighBuffer[i];
                //--- will look for the next low extremum
                whatlookfor = -1;
            }
            //--- clear the rest data
            for (i = limit - 1; i >= 0; i--) {
                zz[i]         = 0.0;
                LowBuffer[i]  = 0.0;
                HighBuffer[i] = 0.0;
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
                    if (LowBuffer[pos] != 0 && LowBuffer[pos] > extremum) LowBuffer[pos] = 0.0;
                }
            }
        }
        //--- found extremum is current low
        if (low[i] == extremum)
            LowBuffer[i] = extremum;
        else
            LowBuffer[i] = 0.0;
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
                    if (HighBuffer[pos] != 0 && HighBuffer[pos] < extremum) HighBuffer[pos] = 0.0;
                }
            }
        }
        //--- found extremum is current high
        if (high[i] == extremum)
            HighBuffer[i] = extremum;
        else
            HighBuffer[i] = 0.0;
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
                if (HighBuffer[i] != 0.0) {
                    lasthigh    = High[i];
                    lasthighpos = i;
                    whatlookfor = -1;
                    zz[i]       = lasthigh;
                }
                if (LowBuffer[i] != 0.0) {
                    lastlow     = Low[i];
                    lastlowpos  = i;
                    whatlookfor = 1;
                    zz[i]       = lastlow;
                }
            }
            break;
        case 1: // look for peak
            if (LowBuffer[i] != 0.0 && LowBuffer[i] < lastlow && HighBuffer[i] == 0.0) {
                zz[lastlowpos]      = 0.0;
                lastlowpos          = i;
                lastlow             = LowBuffer[i];
                zz[i]               = lastlow;
            }
            if (HighBuffer[i] != 0.0 && LowBuffer[i] == 0.0) {
                lasthigh    = HighBuffer[i];
                lasthighpos = i;
                zz[i]       = lasthigh;
                whatlookfor = -1;
            }
            break;
        case -1: // look for lawn
            if (HighBuffer[i] != 0.0 && HighBuffer[i] > lasthigh && LowBuffer[i] == 0.0) {
                zz[lasthighpos]      = 0.0;
                lasthighpos          = i;
                lasthigh             = HighBuffer[i];
                zz[i]                = lasthigh;
            }
            if (LowBuffer[i] != 0.0 && HighBuffer[i] == 0.0) {
                lastlow     = LowBuffer[i];
                lastlowpos  = i;
                zz[i]       = lastlow;
                whatlookfor = 1;
            }
            break;
        }
    }
    

    for (i = 500; i >= 0; i--) {     
        // Breackout
        // buscar los dos ultimos valores del zz
        int j = i + 1;
        int k; 
        while (zz[j] == 0 || zz[j] == EMPTY_VALUE)
        {
            j++;
            if (j >= rates_total) break;
            if(zz[j] != 0)
            {
                k = j + 1;
                while (zz[k] == 0 || zz[k] == EMPTY_VALUE)
                {
                    k++;
                    if (k >= rates_total) break;
                }
            }
        }
        
        
        // nextzz = zz[k];
        
        if ( zz[j] > zz[k] && lastzz !=  zz[j])
        {
            if (close[i+1] < zz[k])
            {
                ArrowDn[i+1] = High[i+1];
                lastzz = zz[j];
            }
        }
        else if (zz[j] < zz[k] && lastzz !=  zz[j])
        {
            if (close[i+1] > zz[k])
            {
                ArrowUp[i+1] = Low[i+1];
                lastzz = zz[j];
            }
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
    ArrayInitialize(zz, 0.0);
    ArrayInitialize(HighBuffer, 0.0);
    ArrayInitialize(LowBuffer, 0.0);
    //--- first counting position
    return (Bars - InpDepth);
}
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76183

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