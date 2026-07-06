// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66240
// Id: 

//+------------------------------------------------------------------+
//|                               Copyright � 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright � 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict

#property indicator_chart_window
#property indicator_buffers 20
extern color Top_color = Green; // Top 1/4 Color
extern color Mid1_color = Green; // Top Third Color
extern color Mid2_color = Orange; // Mid Third Color
extern color Mid3_color = Red; // Bottom Third Color
extern color Bottom_color = Red; // Bottom 1/4 color

class CandleStreams
{
public:
    double OpenStream[];
    double CloseStream[];
    double HighStream[];
    double LowStream[];

    void Clear(const int index)
    {
        OpenStream[index] = EMPTY_VALUE;
        CloseStream[index] = EMPTY_VALUE;
        HighStream[index] = EMPTY_VALUE;
        LowStream[index] = EMPTY_VALUE;
    }

    int RegisterStreams(const int id, const color clr)
    {
        SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
        SetIndexBuffer(id + 0, OpenStream);
        SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
        SetIndexBuffer(id + 1, CloseStream);
        SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
        SetIndexBuffer(id + 2, HighStream);
        SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
        SetIndexBuffer(id + 3, LowStream);
        return id + 4;
    }

    void Set(const int index, const double open, const double high, const double low, const double close)
    {
        OpenStream[index] = open;
        HighStream[index] = high;
        LowStream[index] = low;
        CloseStream[index] = close;
    }
};


CandleStreams Top;
CandleStreams Mid1;
CandleStreams Mid2;
CandleStreams Mid3;
CandleStreams Bottom;

int init()
{
    IndicatorShortName("Bull Bear Barr");
    IndicatorDigits(Digits);

    int id = Top.RegisterStreams(0, Top_color);
    id = Mid1.RegisterStreams(id, Mid1_color);
    id = Mid2.RegisterStreams(id, Mid2_color);
    id = Mid3.RegisterStreams(id, Mid3_color);
    id = Bottom.RegisterStreams(id, Bottom_color);
    
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

    int pos = limit;
    while (pos >= 0)
    {
        Top.Clear(pos);
        Mid1.Clear(pos);
        Mid2.Clear(pos);
        Mid3.Clear(pos);
        Bottom.Clear(pos);

        double Percentage = (High[pos] - Low[pos]) / 100;
        double Position = Percentage != 0 ? MathAbs(Close[pos] - Low[pos]) / Percentage : 0;
        
        if (Position >= 75)
        {
            Top.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
        }
        else if (Position <= 25)
        {
            Bottom.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
        }
        else if (Position >= 66)
        {
            Mid1.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
        }
        else if (Position <= 33)
        {
            Mid3.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
        }
        else
        {
            Mid2.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
        }
    
        pos--;
    }
    return(0);
}

