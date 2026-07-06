// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66190
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
//|                                 Patreon : https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


string IndicatorName = "Unusual Volume Price Movement";
//2. Implement int GetDirection(
//3. place your parameters here

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"

extern int Average_Period = 25; // Volume Average Period
extern double Volume_Multiplier = 2; // Volume Multiplier

enum Method
{
    Pips,
    Percentage
};
extern Method method = Pips; // Pip/Percentage
extern int Price_Period = 25; // Price Period
extern double Value = 0; // Value

double buy[], sell[];

int init()
{
    IndicatorShortName(IndicatorName);
    IndicatorDigits(Digits);
    SetIndexStyle(0, DRAW_ARROW, 0, 2);
    SetIndexArrow(0, 217);
    SetIndexBuffer(0, buy);
    SetIndexStyle(1, DRAW_ARROW, 0, 2);
    SetIndexArrow(1, 218);
    SetIndexBuffer(1, sell);
    
    return (0);
}

int deinit()
{
    return (0);
}

int GetDirection(const int period)
{
    if (Bars < period + Average_Period + 2 || Bars < period + Price_Period + 2)
        return 0;
    double total_volume = 0;
    for (int i = period + Average_Period + 1; i > period; --i)
    {
        total_volume += Volume[i];
    }
    double Average_Volume = total_volume / Average_Period;
    if (Volume[period] < Average_Volume * Volume_Multiplier)
        return 0;

    double Bottom = Low[period + 1];
    double Top = High[period + 1];
    for (i = period + Price_Period + 1; i > period; --i)
    {
        if (Bottom > Low[i])
            Bottom = Low[i];
        if (Top < High[i])
            Top = High[i];
    }
    int mult = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
    double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * mult;
    if (method == Pips)
    {
        Top = Top + pipSize * Value;
        Bottom = Bottom - pipSize * Value;
    }
    else
    {
        Top = Top + (Top / 100) * Value;
        Bottom = Bottom - (Bottom / 100) * Value;
    }

    if (Close[period] > Top)
        return 1;
    else if (Close[period] < Bottom)
        return -1;
    return 0;
}

string GetTimeframe()
{
    switch (_Period)
    {
        case PERIOD_M1: return "M1";
        case PERIOD_M5: return "M5";
        case PERIOD_D1: return "D1";
        case PERIOD_H1: return "H1";
        case PERIOD_H4: return "H4";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_MN1: return "MN1";
        case PERIOD_W1: return "W1";
    }
    return "M1";
}

int start()
{
    if (Bars <= 1) return(0);
    int ExtCountedBars = IndicatorCounted();
    if (ExtCountedBars < 0) return(-1);
    int limit = Bars - 1;
    if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
    int pos = limit;
    while (pos >= 0)
    {
        int direction = GetDirection(pos);
        switch (direction)
        {
            case 1:
                buy[pos] = Low[pos];
                sell[pos] = EMPTY_VALUE;
                break;
            case -1:
                buy[pos] = EMPTY_VALUE;
                sell[pos] = High[pos];
                break;
        }
        pos--;
    } 
    return(0);
}

