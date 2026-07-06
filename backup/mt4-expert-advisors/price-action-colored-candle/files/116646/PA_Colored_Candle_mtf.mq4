// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65487

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "Bullish Change: Current Close > Previous Low"
#property description "Bearish Change: Current Close < Previous High"
#property indicator_chart_window

extern ENUM_TIMEFRAMES TimeFrame   = PERIOD_CURRENT;  // Time frame

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init(){
    IndicatorName = GenerateIndicatorName("Price Action Colored Candle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
    return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void GetHighLow(const int from, const int to, double& high, double &low)
{
    high = iHigh(NULL, TimeFrame, from);
    low = iLow(NULL, TimeFrame, from);
    for (int j = from - 1; j >= to + 1; j--)
    {
        if (iHigh(NULL, TimeFrame, j) > high)
            high = iHigh(NULL, TimeFrame, j);
        if (iLow(NULL, TimeFrame, j) < low)
            low  = iLow(NULL, TimeFrame, j);
    }
}

bool IsBullishChange(const int i)
{
    return iClose(NULL, TimeFrame, i) > iLow(NULL, TimeFrame, i + 1) 
        && iClose(NULL, TimeFrame, i + 1) <= iLow(NULL, TimeFrame, i + 2);
}

bool IsBearishChange(const int i)
{
    return iClose(NULL, TimeFrame, i) < iHigh(NULL, TimeFrame, i + 1) 
        && iClose(NULL, TimeFrame, i + 1) >= iHigh(NULL, TimeFrame, i + 2);
}

int start(){
    WindowRedraw();

    int limit, i;
    int counted_bars=IndicatorCounted();
    if(counted_bars<0)
        return -1;
    if(counted_bars>0)
        counted_bars--;
    limit=Bars-counted_bars - 1;

    for(i=limit; i>=0; i--)
    {
        if (ObjectFind(IndicatorObjPrefix + "Bearish_"+i)==0) ObjectDelete(IndicatorObjPrefix + "Bearish_"+i);
        if (ObjectFind(IndicatorObjPrefix + "Bullish_"+i)==0) ObjectDelete(IndicatorObjPrefix + "Bullish_"+i);
    }

    int previous_change = 0;
    int last_change = 0;
    int last_mtf_i = 0;
    double high, low;
    int start;
    int end;
    if (TimeFrame != PERIOD_CURRENT)
    {
        int mtf_limit = iBarShift(NULL, TimeFrame, Time[limit - 2]);
        for(i = mtf_limit - 2; i >= 0; i--)
        {
           if (IsBullishChange(i))
            {
                if (previous_change > 0)
                {
                    GetHighLow(previous_change, i, high, low);
                    start = iBarShift(NULL, 0, iTime(NULL, TimeFrame, previous_change));
                    end = iBarShift(NULL, 0, iTime(NULL, TimeFrame, i)) + 1;
                    Zone_Area("Bearish_" + previous_change, Time[start], high, Time[end], low, clrRed, false);
                }
                previous_change = i;
            }
            if (IsBearishChange(i))
            {
                if (previous_change > 0)
                {
                    GetHighLow(previous_change, i, high, low);
                    start = iBarShift(NULL, 0, iTime(NULL, TimeFrame, previous_change));
                    end = iBarShift(NULL, 0, iTime(NULL, TimeFrame, i)) + 1;
                    Zone_Area("Bullish_" + previous_change, Time[start], low, Time[end], high, clrLime, false);
                }
                previous_change = i;
            }
        }
    }
    else
    {
        for(i = limit - 2; i >= 0; i--)
        {
            if (IsBullishChange(i))
            {
                if (previous_change > 0)
                {
                    GetHighLow(previous_change, i, high, low);
                    Zone_Area("Bearish_" + previous_change, iTime(NULL, TimeFrame, previous_change), high, iTime(NULL, TimeFrame, i + 1), low, clrRed, false);
                }
                previous_change = i;
            }
            if (IsBearishChange(i))
            {
                if (previous_change > 0)
                {
                    GetHighLow(previous_change, i, high, low);
                    Zone_Area("Bullish_" + previous_change, iTime(NULL, TimeFrame, previous_change), low, iTime(NULL, TimeFrame, i + 1), high, clrLime, false);
                }
                previous_change = i;
            }
        }
    }
    
    return 0;
}

void Zone_Area(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, double precio2, color zcolor, bool backobj = true){
    ObjectDelete(IndicatorObjPrefix + Nombre);
    ObjectCreate(IndicatorObjPrefix + Nombre,OBJ_RECTANGLE,0,tiempo1,precio1,tiempo2,precio2);
    ObjectSet(IndicatorObjPrefix + Nombre,OBJPROP_COLOR,zcolor);
    ObjectSet(IndicatorObjPrefix + Nombre,OBJPROP_BACK,backobj);
}