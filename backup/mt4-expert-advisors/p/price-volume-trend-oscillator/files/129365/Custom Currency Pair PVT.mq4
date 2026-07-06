// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

input string symbol = "EURUSD"; // Symbol
double PVT[];

int init()
{
    IndicatorShortName("Price volume trend");
    IndicatorDigits(Digits);
    SetIndexStyle(0,DRAW_LINE);
    SetIndexBuffer(0,PVT);

    return(0);
}

int deinit()
{
    return(0);
}

int start()
{
    if (Bars <= 3) 
        return 0;
    int ExtCountedBars = IndicatorCounted();
    if (ExtCountedBars < 0) 
        return(-1);
    int limit = Bars - 2;
    if (ExtCountedBars > 2)
        limit = Bars - ExtCountedBars - 1;
    int bars = iBars(symbol, _Period);
    for (int pos = limit; pos >= 0; --pos)
    {
        int index = iBarShift(symbol, _Period, Time[pos]);
        if (index < 0)
            continue;
        double prev = PVT[pos + 1] == EMPTY_VALUE ? 0 : PVT[pos + 1];
        double prevClose = iClose(symbol, _Period, index + 1);
        PVT[pos] = (iClose(symbol, _Period, index) - prevClose) * iVolume(symbol, _Period, pos) / prevClose + prev;
    } 
    return(0);
}

