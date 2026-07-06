// Id: 21775
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66415
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

#property description "ZigZag-Integer"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrRed
#property indicator_color2 clrLime

string indi_name = "ZigZagColored";

extern int Depth     = 12;
extern int Deviation = 5;
extern int Backstep  = 3;
extern int HistoryLimit = 500;
extern bool Label = true;

double Zig[];
double Zag[];
double LowMap[];
double HighMap[];
double pipSize;

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


int init()
{
    int mult = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
    pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * mult;
    IndicatorName = GenerateIndicatorName("ZigZag (" + Depth + "," + Deviation + "," + Backstep + ")");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    IndicatorBuffers(6);
    
    SetIndexStyle(0, DRAW_LINE);
    SetIndexBuffer(0, Zig);
    SetIndexLabel(0, "Down Swing");
    
    SetIndexStyle(1, DRAW_LINE);
    SetIndexBuffer(1, Zag);
    SetIndexLabel(1, "Up Swing");
    
    SetIndexStyle(2, DRAW_NONE);
    SetIndexBuffer(2, LowMap);
    SetIndexLabel(2, "Low Map");
    
    SetIndexStyle(3, DRAW_NONE);
    SetIndexBuffer(3, HighMap);
    SetIndexLabel(3, "High Map");

    SetIndexBuffer(4, SearchMode);
    SetIndexLabel(4, "Search mode");
    SetIndexStyle(5, DRAW_NONE);
    SetIndexBuffer(5, Peak);
    SetIndexLabel(5, "Peak");
    
    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}


int searchBoth = 0;
int searchPeak = 1;
int searchLawn = -1;
int peak_count = 0;

double SearchMode[];
double Peak[];
double dummy[];

void RegisterPeak(const int period, const double mode, const double peak)
{
    peak_count = peak_count + 1;
    if (ArraySize(dummy) < peak_count)
        ArrayResize(dummy, peak_count);
    dummy[peak_count - 1] = period;
    SearchMode[period] = mode;
    Peak[period] = peak;
}

void ReplaceLastPeak(const int period, const double mode, const double peak)
{
    dummy[peak_count - 1] = period;
    SearchMode[period] = mode;
    Peak[period] = peak;
}

int GetPeak(const int offset)
{
    int peak = peak_count + offset;
    if (peak < 3)
        return -1;
    
    peak = dummy[peak];
    if (peak < 0)
        return -1;
    return peak;
}

int lastperiod = -1;
double lastlow = 0.0;
double lasthigh = 0.0;
int TEMP;

int GetLastZag(const int period)
{
    int last = -1;
    int from = period;
    for (; from < Bars; ++from)
    {
        if (Zag[from] != EMPTY_VALUE)
        {
            if (from == Bars || Zag[from + 1] != EMPTY_VALUE)
                return from;
            last = from;
        }
    }
    return last;
}

int GetLastZig(const int period)
{
    int last = -1;
    int from = period;
    for (; from < Bars; ++from)
    {
        if (Zig[from] != EMPTY_VALUE)
        {
            if (from == Bars || Zig[from + 1] != EMPTY_VALUE)
                return from;
            last = from;
        }
    }
    return last;
}

void SetZig(const int to, const double val_to)
{
    int from = GetLastZag(to);
    if (from == -1 || from == to)
    {
        Zig[to] = val_to;
        return;
    }
        
    double increment = (val_to - Zag[from]) / (double)(from - to);
    for (int i = from; i >= to; --i)
    {
        Zig[i] = Zag[from] + increment * (from - i);
        if (i != from)
            Zag[i] = EMPTY_VALUE;
    }
}

void SetZag(const int to, const double val_to)
{
    int from = GetLastZig(to);
    if (from == -1 || from == to)
    {
        Zag[to] = val_to;
        return;
    }
    double increment = (val_to - Zig[from]) / (double)(from - to);
    for (int i = from; i >= to; --i)
    {
        Zag[i] = Zig[from] + increment * (from - i);
        if (i != from)
            Zig[i] = EMPTY_VALUE;
    }
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
    if (rates_total < Depth || Backstep >= Depth)
        return(0);
                    
    int limit = MathMin(HistoryLimit, Bars - Depth);
    for (int period = limit; period >= 0; period--)
    {
        // calculate zigzag for the completed candle ONLY
        if (period == lastperiod)
            continue;
        if (period > lastperiod)
        {
            lastlow = EMPTY_VALUE;
            lasthigh = EMPTY_VALUE;
            peak_count = 0;
        }
        lastperiod = period;
        if (limit < period + Depth)
            continue;
            
        UpdateLowMap(period);
        UpdateHighMap(period);

        int peak_3 = GetPeak(-3);
        if (peak_3 == -1)
        {
            DoSearch(period, period + Depth, searchBoth,  EMPTY_VALUE);
        }
        else
        {
            DoSearch(period, peak_3, SearchMode[peak_3], Peak[peak_3]);
        }
    }
    DRAW();
    return rates_total;
}

double GetZigZagVal(const int period)
{
    if (Zig[period] != EMPTY_VALUE)
        return Zig[period];
    return Zag[period];
}

void DRAW()
{
    if (!Label)
        return;

    int peak_id = 0;
    double prev_peak = DBL_MAX;
    for (int i = MathMin(Bars + 2, HistoryLimit); i >= 1; --i)
    {
        if (Zag[i] != EMPTY_VALUE && Zag[i - 1] == EMPTY_VALUE)
        {
            double value = Zag[i];
            if (prev_peak == DBL_MAX)
            {
                prev_peak = value;
                continue;
            }
            double number = MathAbs(prev_peak - value);
            CreateLabel(indi_name + IntegerToString(peak_id++), Time[i], value + number / 10, IntegerToString(number / pipSize), clrGray, 10);
            prev_peak = value;
        }
        if (Zig[i] != EMPTY_VALUE && Zig[i - 1] == EMPTY_VALUE)
        {
            value = Zig[i];
            if (prev_peak == DBL_MAX)
            {
                prev_peak = value;
                continue;
            }
            number = MathAbs(prev_peak - value);
            CreateLabel(indi_name + IntegerToString(peak_id++), Time[i], value - number / 10, IntegerToString(number / pipSize), clrGray, 10);
            prev_peak = value;
        }
    }
}

void CreateLabel(string name, datetime time, double price, string text, color col, int fontSize)
{
    ObjectCreate(0, IndicatorObjPrefix + name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, IndicatorObjPrefix + name, OBJPROP_TEXT, text); 
    ObjectSetString(0, IndicatorObjPrefix + name, OBJPROP_FONT, "Arial"); 
    ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_FONTSIZE, fontSize); 
    ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_COLOR, col); 
}

double CoreMin(const int period, const int count)
{
    double min = DBL_MAX;
    for (int i = period; i <= period + count; ++i)
    {
        if (Low[i] < min)
        {
            min = Low[i];
        }
    }
    return min;
}

double CoreMax(const int period, const int count)
{
    double max = -DBL_MAX;
    for (int i = period; i <= period + count; ++i)
    {
        if (High[i] > max)
        {
            max = High[i];
        }
    }
    return max;
}

void UpdateLowMap(const int period)
{
    double val = CoreMin(period, Depth);
    if (val == lastlow)
        return;

    lastlow = val;
    // if current low is higher for more than Deviation pips, ignore
    if ((Low[period] - val) <= (pipSize * Deviation))
    {
        // check for the previous backstep lows
        for (int i = period + 1; i < period + Backstep - 1; i++)
        {
            if (LowMap[i] != EMPTY_VALUE && LowMap[i] > val)
                LowMap[i] = EMPTY_VALUE;
        }
        LowMap[period] = Low[period] == val ? val : EMPTY_VALUE;
    }
}

void UpdateHighMap(const int period)
{
    double val = CoreMax(period, Depth);
    if (val == lasthigh)
        return;

    lasthigh = val;
    // if current low is higher for more than Deviation pips, ignore
    if ((val - High[period]) <= (pipSize * Deviation))
    {
        // check for the previous backstep lows
        for (int i = period + 1; i < period + Backstep - 1; i++)
        {
            if (HighMap[i] != EMPTY_VALUE && HighMap[i] < val)
                HighMap[i] = EMPTY_VALUE;
        }
        HighMap[period] = High[period] == val ? val : EMPTY_VALUE;
    }
}

void DoSearch(const int period, const int start, int searchMode, double last_peak)
{
    for (int i = start; i > period; --i)
    {
        if (searchMode == searchBoth)
        {
            if (HighMap[i] != EMPTY_VALUE)
            {
                last_peak = HighMap[i];
                searchMode = searchLawn;
                RegisterPeak(i, searchMode, HighMap[i]);
            }
            else if (LowMap[i] != EMPTY_VALUE)
            {
                last_peak = LowMap[i];
                searchMode = searchPeak;
                RegisterPeak(i, searchMode, LowMap[i]);
            }
        }
        else if (searchMode == searchPeak)
        {
            if (LowMap[i] != EMPTY_VALUE && (last_peak == EMPTY_VALUE || LowMap[i] < last_peak))
            {
                last_peak = LowMap[i];
                SetZig(i, LowMap[i]);
                TEMP = i;
                ReplaceLastPeak(i, searchMode, last_peak);
            }
            if (HighMap[i] != EMPTY_VALUE && LowMap[i] == EMPTY_VALUE)
            {
                SetZag(i, HighMap[i]);
                TEMP = i;
                last_peak = HighMap[i];
                searchMode = searchLawn;
                RegisterPeak(i, searchMode, HighMap[i]);
            }
        }
        else if (searchMode == searchLawn)
        {
            if ((HighMap[i] != EMPTY_VALUE && (last_peak == EMPTY_VALUE || HighMap[i] > last_peak)))
            {
                last_peak = HighMap[i];
                SetZag(i, HighMap[i]);
                TEMP = i;
                ReplaceLastPeak(i, searchMode, HighMap[i]);
            }
            if (LowMap[i] != EMPTY_VALUE && HighMap[i] == EMPTY_VALUE)
            {
                SetZig(i, LowMap[i]);
                TEMP = i;
                last_peak = LowMap[i];
                searchMode = searchPeak;
                RegisterPeak(i, searchMode, LowMap[i]);
            }
        }
    }
}
