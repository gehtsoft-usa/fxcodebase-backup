// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=60029

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=5;
extern double Coeff=3.5;

double WTS[], WTSDn[], up_signal[], down_signal[];
extern ENUM_TIMEFRAMES TimeFrame   = PERIOD_CURRENT;  // Time frame

int init()
{
    IndicatorShortName("Wilders Trailing Stop indicator");
    IndicatorDigits(Digits);
    SetIndexStyle(0,DRAW_LINE);
    SetIndexBuffer(0,WTS);
    SetIndexStyle(1,DRAW_LINE);
    SetIndexBuffer(1,WTSDn);
    SetIndexStyle(2, DRAW_LINE);
    SetIndexBuffer(2, up_signal);
    SetIndexStyle(3, DRAW_LINE);
    SetIndexBuffer(3, down_signal);

    return(0);
}

int start()
{
    if(Bars<=Length) return(0);
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0) return(-1);
    int limit=Bars-2;
    if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
    int pos = limit;
    double loss;
    while(pos>=0)
    {
        int mtf_pos = iBarShift(NULL, TimeFrame, Time[pos]);
        datetime time = iTime(NULL, TimeFrame, mtf_pos + 1);
        int pos_1 = iBarShift(NULL, Period(), time);
        
        loss = iATR(NULL, TimeFrame, Length, mtf_pos) * Coeff;
        if (iClose(NULL, TimeFrame, mtf_pos) > WTS[pos_1] && iClose(NULL, TimeFrame, mtf_pos + 1) > WTS[pos_1])
        {
            WTS[pos] = MathMax(WTS[pos_1], iClose(NULL, TimeFrame, mtf_pos) - loss);
            WTSDn[pos] = WTS[pos];
            WTSDn[pos_1] = WTS[pos_1];
        }
        else
        {
            if (iClose(NULL, TimeFrame, mtf_pos) < WTS[pos_1] && iClose(NULL, TimeFrame, mtf_pos + 1) < WTS[pos_1])
            {
                WTS[pos] = MathMin(WTS[pos_1], iClose(NULL, TimeFrame, mtf_pos) + loss);
            }
            else
            {
                if (iClose(NULL, TimeFrame, mtf_pos) > WTS[pos_1])
                {
                    WTS[pos] = iClose(NULL, TimeFrame, mtf_pos) - loss;
                    WTSDn[pos] = WTS[pos];
                    WTSDn[pos_1] = WTS[pos_1];
                }
                else
                {
                    WTS[pos] = iClose(NULL, TimeFrame, mtf_pos) + loss;
                }
            }
        }
        if (WTSDn[pos] != EMPTY_VALUE && WTSDn[pos + 2] == EMPTY_VALUE)
        {
            down_signal[pos] = -1;
        }
        if (WTSDn[pos] == EMPTY_VALUE && WTSDn[pos + 1] != EMPTY_VALUE)
        {
            up_signal[pos] = 1;
        }
        pos--;
    } 
    return(0);
}
