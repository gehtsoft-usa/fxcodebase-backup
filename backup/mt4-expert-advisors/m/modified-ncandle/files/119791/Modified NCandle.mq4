// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66241
// Id: 

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Yellow
extern int N = 10;
extern bool IncludeCurrentBar = true;
extern bool Ignore = false;
extern color Up_Color = Green;
extern color Dn_Color = Red;


double Up_o[], Dn_o[], Up_c[], Dn_c[], HighLine[], LowLine[];

int init()
{
    IndicatorShortName("NCandle indicator");
    IndicatorDigits(Digits);
    int id = 0;
    SetIndexBuffer(id, HighLine);
    SetIndexStyle(id++, DRAW_LINE);
    SetIndexBuffer(id, LowLine);
    SetIndexStyle(id++, DRAW_LINE);
    
    SetIndexStyle(id, DRAW_HISTOGRAM, STYLE_SOLID, 3, Up_Color);
    SetIndexBuffer(id++, Up_o);
    
    SetIndexBuffer(id, Up_c);
    SetIndexStyle(id++, DRAW_HISTOGRAM, STYLE_SOLID, 3, Up_Color);
    
    SetIndexStyle(id, DRAW_HISTOGRAM, STYLE_SOLID, 3, Dn_Color);
    SetIndexBuffer(id++, Dn_o);

    SetIndexBuffer(id, Dn_c);
    SetIndexStyle(id++, DRAW_HISTOGRAM, STYLE_SOLID, 3, Dn_Color);

    return(0);
}

int deinit()
{
    return(0);
}

int start()
{
    if(Bars<=3) return(0);
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0) return(-1);
    int limit=Bars-2;
    if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;

    double Max = -DBL_MAX;
    double Min = DBL_MAX;
    int Count = 0;
    int LastP = -1;

    int pos = 0;
    while (pos < limit)
    {
        if (High[pos] > Max)
        {
            Max = High[pos];
        }
        if (Low[pos] < Min)
        {
            Min = Low[pos];
        }
        if (!Ignore || (High[pos] > High[pos + 1] && Low[pos] < Low[pos + 1]))
        {
            Count++;
        }
        LastP = pos;
        if (Count >= N)
        {
            break;
        }
    
        pos++;
    }
    if (LastP == -1 || LastP >= limit)
    {
        return 0;
    }

    for (int i = 0; i <= LastP; ++i)
    {
        HighLine[i] = Max;
        LowLine[i] = Min;
        if (Open[LastP] <= Close[0])
        {
            Up_o[i] = Open[LastP];
            Up_c[i] = Close[0];
        }
        else
        {
            Dn_o[i] = Open[LastP];
            Dn_c[i] = Close[0];
        }
    }
    for (i = LastP + i; i < limit; ++i)
    {
        HighLine[i] = EMPTY_VALUE;
        LowLine[i] = EMPTY_VALUE;
        Up_o[i] = EMPTY_VALUE;
        Up_c[i] = EMPTY_VALUE;
        Dn_o[i] = EMPTY_VALUE;
        Dn_c[i] = EMPTY_VALUE;
    }
    return(0);
}

