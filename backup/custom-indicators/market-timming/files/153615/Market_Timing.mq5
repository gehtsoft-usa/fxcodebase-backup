//Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74425

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots 3
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 5
#property indicator_label1 "Up"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 Crimson
#property indicator_style2 STYLE_SOLID
#property indicator_width2 5
#property indicator_label2 "Dn"
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_color3 Crimson
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
#property indicator_label3 "Hour"

//--- indicator buffers
double LineUp [];
double LineDn [];
double Hour [];

input int daysCalc = 100; // Days Back to make stadistic:
// input bool   SepOn = true;       // Separators On?
input color clrSep = clrDimGray; // Separator Linea color

// ------------------------------------------------------------------

class CNewCandle
{
    private:
    int             velasInicio;
    string          m_symbol;
    ENUM_TIMEFRAMES m_tf;

    public:
    CNewCandle();
    CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : m_symbol(symbol), m_tf(tf), velasInicio(iBars(symbol, tf)) {}
    ~CNewCandle();

    bool IsNewCandle();
};
CNewCandle::CNewCandle()
{
    // toma los valores del chart actual
    velasInicio = iBars(Symbol(), Period());
    m_symbol = Symbol();
    m_tf = Period();
}
CNewCandle::~CNewCandle() {}
bool CNewCandle::IsNewCandle()
{
    int velasActuales = iBars(m_symbol, m_tf);
    if(velasActuales > velasInicio) {
        velasInicio = velasActuales;
        return true;
    }

    //---
    return false;
}
CNewCandle* newCandle;




// ------------------------------------------------------------------
void OnInit()
{
    newCandle = new CNewCandle();

    //--- indicator short name
    string short_name = "Market Timming";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    //--- Buffers 
    SetIndexBuffer(0, LineUp);
    SetIndexBuffer(1, LineDn);
    SetIndexBuffer(2, Hour);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, clrSep);

    // if(!SepOn)
    //     PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    
    RefreshData();
}
void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0, "lbl");
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{



    int n = 0;
    double maxValue = fmax(countMaxByHour[ArrayMaximum(countMaxByHour)], countMinByHour[ArrayMaximum(countMinByHour)]) * 1.10;
    IndicatorSetDouble(INDICATOR_MAXIMUM, maxValue);
    IndicatorSetDouble(INDICATOR_MINIMUM, -2);

    int start = iBars(NULL, 0) - 72;


    for(int i = start; i < rates_total && !IsStopped(); i += 3)
    {
        Hour[i-2] = maxValue;
        // CreateLabel("lbl" + fabs(n - 23), iTime(NULL, 0, i-2), -1, fabs(n - 23), clrSep);
        CreateLabel("lbl" + (string)n, time[i], -1, (string)n, clrSep);

        LineUp[i - 1] = countMaxByHour[n];
        LineDn[i] = countMinByHour[n];
        n++;
    }


    if(newCandle.IsNewCandle()) RefreshData();


    return (rates_total);
}
//+------------------------------------------------------------------+


int hoursBack = daysCalc * 24;
double countMaxByHour[24];
double countMinByHour[24];

int shiftDays [];
int maxHourPositions [];
int minHourPositions [];

void RefreshData()
{

    ArrayResize(shiftDays, daysCalc);
    ArrayResize(maxHourPositions, daysCalc);
    ArrayResize(minHourPositions, daysCalc);
    MqlDateTime dt;

    int days = 0;
    int n = 0;
    while(days < daysCalc)
    {
        TimeToStruct(iTime(NULL, PERIOD_H1, n), dt);
        if(dt.hour == 0)
        {
            // Print(__FUNCTION__, " dt.hour: ", dt.hour);
            // Print(__FUNCTION__, " date: ", dt.day, "-", dt.mon, "-", dt.year);
            // Print(__FUNCTION__, " SHIFT: ", i);
            shiftDays[days] = n;
            days++;
        }
        n++;
    }

    for(int i = 0; i < ArraySize(shiftDays); i++)
    {

        MqlDateTime horaMax;
        MqlDateTime horaMin;
        TimeToStruct(iTime(NULL, PERIOD_H1, MaxPosDay(shiftDays[i])), horaMax);
        TimeToStruct(iTime(NULL, PERIOD_H1, MinPosDay(shiftDays[i])), horaMin);
        Print(__FUNCTION__, " hora Max: ", horaMax.day, "-", horaMax.mon, "-", horaMax.year, "// hora: ", horaMax.hour);
        Print(__FUNCTION__, " hora Min: ", horaMin.day, "-", horaMin.mon, "-", horaMin.year, "// hora: ", horaMin.hour);

        maxHourPositions[i] = horaMax.hour;
        minHourPositions[i] = horaMin.hour;
    }

    for(int i = 0; i < ArraySize(countMaxByHour); i++)
    {

        double countmax = 0;
        double countmin = 0;

        for(int p = 0; p < ArraySize(maxHourPositions); p++) {
            if(maxHourPositions[p] == i)
                countmax++;
        }
        for(int p = 0; p < ArraySize(minHourPositions); p++) {
            if(minHourPositions[p] == i)
                countmin++;
        }
        countMaxByHour[i] = countmax;
        countMinByHour[i] = countmin;
    }

    for(int i = 0; i < ArraySize(countMaxByHour); i++) {

        countMaxByHour[i] *= 100;
        countMinByHour[i] *= 100;
        countMaxByHour[i] /= daysCalc;
        countMinByHour[i] /= daysCalc;

    }



}

int MaxPosDay(int iniPos)
{
    return iHighest(Symbol(), PERIOD_H1, MODE_HIGH, 24, iniPos);
}
int MinPosDay(int iniPos)
{
    return iLowest(Symbol(), PERIOD_H1, MODE_LOW, 24, iniPos);
}

void CreateLabel(string nm, datetime tm, double pr, string tx, color cl)
{
    ObjectCreate(0, nm, OBJ_TEXT, 1, tm, pr);
    ObjectSetString(0, nm, OBJPROP_TEXT, tx);
    // ObjectSetString(0, nm, OBJPROP_FONT, "Arial Black");
    ObjectSetString(0, nm, OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, nm, OBJPROP_COLOR, cl);

    // ENUM_ANCHOR_POINT anchor = cl == Green ? ANCHOR_LOWER : ANCHOR_UPPER;
    ENUM_ANCHOR_POINT anchor = ANCHOR_RIGHT;
    ObjectSetInteger(0, nm, OBJPROP_ANCHOR, anchor);

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