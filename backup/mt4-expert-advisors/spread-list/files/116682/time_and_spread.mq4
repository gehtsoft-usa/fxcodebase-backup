// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65492
// Id: 

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                   Paypal: https://goo.gl/9Rj74e  |
//|                    Patreon : https://www.patreon.com/mariojemic  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "Time and spread"
#property indicator_chart_window

string   WindowName;
int      WindowNumber;

int init()
{
    WindowName = "Time and spread";
    IndicatorShortName(WindowName);

    return(0);
}

int deinit()
{
    ObjectsDeleteAll();
    return(0);
}

int start()
{
    WindowNumber = 0;
    double mult = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
    double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * mult;
    double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / mult;
    
    datetime bar_start_time = Time[0];
    datetime bar_end_time = bar_start_time + PeriodSeconds();
    int seconds_remaining = bar_end_time - TimeCurrent();
    
    int hours = (int)(seconds_remaining / 3600);
    seconds_remaining = seconds_remaining - hours * 3600;
    int minutes = (int)(seconds_remaining / 60);
    seconds_remaining = seconds_remaining - minutes * 60;
    int seconds = seconds_remaining;

    string str = "Time Local: " + TimeToString(TimeLocal()) + "\n";
    str = str + "Time Server: " + TimeToString(TimeCurrent()) + "\n";
    str = str + "Time GMT: " + TimeToString(TimeGMT()) + "\n";
    str = str + "Bar ends in: " + IntegerToString(hours) + "h " + IntegerToString(minutes) + "m " + IntegerToString(seconds) + "s\n";
    str = str + "Spread pips: " + DoubleToStr(spread, 2);

    Comment(str);
    return(0);
}
