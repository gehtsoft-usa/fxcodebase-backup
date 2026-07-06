// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65458

//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 clrRed
#property indicator_color2 clrGreen

extern int period = 10;
extern double multiplier = 4;

double nrst_up[];
double nrst_dn[];
double up[];
double dn[];
double trend[];

int init()
{
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(0, nrst_up);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(1, nrst_dn);
    
    SetIndexBuffer(2, up);
    SetIndexBuffer(3, dn);
    SetIndexBuffer(4, trend);
    
    IndicatorShortName("NRST");
    
    return 0;
}

int deinit()
{
    return 0;
}

double GetTrend(const int i)
{
    if (i >= Bars - 1)
    {
        return 0;
    }
    if (Close[i] > up[i + 1])
    {
        return 1;
    }
    else if (Close[i] < dn[i + 1])
    {
        return -1;
    }
    return trend[i + 1];
}

int start()
{
    int countedBars = IndicatorCounted();
    int limit = Bars - countedBars - 1;

    for (int i = limit; i >= 0;--i)
    {
        double medianPrice = (High[i] + Low[i]) / 2;
        double atr = iATR(Symbol(), Period(), period, i);
        up[i] = medianPrice + multiplier * atr;
        dn[i] = medianPrice - multiplier * atr;
        trend[i] = GetTrend(i);
        if (trend[i] == 1 && dn[i] < dn[i + 1])
        {
            dn[i] = dn[i + 1];
        }
        if (trend[i] == -1 && up[i] > up[i + 1])
        {
            up[i] = up[i + 1];
        }
        if (trend[i] == 1)
        {
            nrst_dn[i] = dn[i];
        }
        else
        {
            nrst_up[i] = up[i];
        }
    }
    return limit;
}