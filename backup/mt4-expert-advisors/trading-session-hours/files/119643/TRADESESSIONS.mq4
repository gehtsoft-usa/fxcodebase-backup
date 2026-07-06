// Id: 21590
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65457
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

#property copyright "Copyright � 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property strict
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Green
#property indicator_color6 Green
#property indicator_color7 Blue
#property indicator_color8 Blue
#property indicator_color9 Blue
#property indicator_color10 Yellow
#property indicator_color11 Yellow
#property indicator_color12 Yellow

double ny_top[];
double ny_middle[];
double ny_bottom[];
double london_top[];
double london_middle[];
double london_bottom[];
double tokyo_top[];
double tokyo_middle[];
double tokyo_bottom[];
double sydney_top[];
double sydney_middle[];
double sydney_bottom[];

extern bool NY_S = true; // Show New York session
extern bool NY_L = true; // Show New York session labels
extern int NY_Shift = 8; // New York session Shift
extern bool NY_draw_label = true; // Draw label for New York
extern bool LO_S = true; // Show London session (3:00 am - 12:00 pm EST/EDT)
extern bool LO_L = true; // Show London session labels
extern int LO_Shift = 3; // London session Shift
extern bool LO_draw_label = true; // Draw label for London
extern bool TO_S = true; // Show Tokyo session
extern bool TO_L = true; // Show Tokyo session labels
extern int TO_Shift = -5; // Tokyo session Shift
extern bool TO_draw_label = true; // Draw label for Tokyo
extern bool SY_S = true; // Show Sydney session
extern bool SY_L = true; // Show Sydney session labels
extern int SY_Shift = -7; // Sydney session Shift
extern bool SY_draw_label = true; // Draw label for Sydney

extern bool S_N = true; // Show session name
extern bool S_H = true; // Show session high
extern bool S_L = true; // Show session low
extern bool S_OD = true; // Show distance to open
extern bool S_OH = true; // Show distance between high/low
extern bool S_SM = false; // Show mid line
extern bool S_SE = false; // Show start/end line
extern bool S_TR = false; // Show triangulation
extern int FS = 6; // Font Size

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


class TimezoneCalculator
{
    int _startHour;
    int _endHour;
    datetime _dtStart;
    datetime _dtEnd;
    int _startIndex;
    int _endIndex;
    double _max;
    double _min;
    int _maxIndex;
    int _minIndex;
    bool _initialized;
public:
    TimezoneCalculator(const int startHour, const int endHour)
    {
        _initialized = false;
        _startHour = startHour;
        _endHour = endHour;
    }

    void Reset()
    {
        _initialized = false;
    }

    bool SetDate(const datetime dt)
    {
        if (!_initialized)
        {
            _initialized = true;
            _max = -DBL_MAX;
            _min = DBL_MAX;
            return UpdateDatesRange(dt);
        }
        if (dt < _dtStart)
            return false;
        if (dt >= _dtStart && dt <= _dtEnd)
        {
            if (_endIndex == 0)
            {
                if (!UpdateIndexes())
                    return false;
                UpdateHighLow();
                return true;
            }
            return false;
        }
        while (dt > _dtEnd)
        {
            _dtEnd += 86400;
            _dtStart += 86400;
        }
        _max = -DBL_MAX;
        _min = DBL_MAX;
        if (!UpdateIndexes())
            return false;
        UpdateHighLow();
        return true;
    }

    int GetStartIndex()
    {
        return _startIndex;
    }

    int GetEndIndex()
    {
        return _endIndex;
    }

    double GetHigh()
    {
        return _max;
    }

    int GetHighIndex()
    {
        return _maxIndex;
    }
    
    double GetLow()
    {
        return _min;
    }

    int GetLowIndex()
    {
        return _minIndex;
    }
private:
    void UpdateHighLow()
    {
        for (int i = _startIndex; i >= _endIndex; --i)
        {
            double high = High[i];
            double low = Low[i];
            if (_max < high)
            {
                _max = high;
                _maxIndex = i;
            }
            if (_min > low)
            {
                _min = low;
                _minIndex = i;
            }
        }
    }
    bool UpdateIndexes()
    {
        _startIndex = iBarShift(Symbol(), Period(), _dtStart, false);
        if (_startIndex < 0 || Time[_startIndex] > _dtEnd)
            return false;
        _endIndex = iBarShift(Symbol(), Period(), _dtEnd, false);
        return true;
    }
    bool UpdateDatesRange(const datetime dt)
    {
        MqlDateTime start;
        TimeToStruct(dt, start);
        start.sec = 0;
        start.min = 0;
        start.hour = 0;
        _dtStart = StructToTime(start) + _startHour * 3600;

        MqlDateTime end;
        TimeToStruct(dt, end);
        end.sec = 0;
        end.min = 0;
        end.hour = 0;
        _dtEnd = StructToTime(end) + _endHour * 3600;
        if (!UpdateIndexes())
            return false;
        UpdateHighLow();
        return dt >= _dtStart && dt <= _dtEnd;
    }
};

TimezoneCalculator *ny;
TimezoneCalculator *london;
TimezoneCalculator *tokyo;
TimezoneCalculator *sydney;
int Window;

int init()
{
    ny = new TimezoneCalculator(NY_Shift, NY_Shift + 9);
    london = new TimezoneCalculator(LO_Shift, LO_Shift + 9);
    tokyo = new TimezoneCalculator(TO_Shift, TO_Shift + 9);
    sydney = new TimezoneCalculator(SY_Shift, SY_Shift + 9);
    
    IndicatorName = GenerateIndicatorName("TRADESESSIONS");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    Window = WindowFind(IndicatorName);
    IndicatorDigits(Digits);

    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(0, ny_top);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(1, ny_middle);
    SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(2, ny_bottom);
    SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(3, london_top);
    SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(4, london_middle);
    SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(5, london_bottom);
    SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(6, tokyo_top);
    SetIndexStyle(7, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(7, tokyo_middle);
    SetIndexStyle(8, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(8, tokyo_bottom);
    SetIndexStyle(9, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(9, sydney_top);
    SetIndexStyle(10, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(10, sydney_middle);
    SetIndexStyle(11, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(11, sydney_bottom);
    
    return 0;
}

int deinit()
{
    delete ny;
    delete london;
    delete tokyo;
    delete sydney;
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return 0;
}

void CreateLabel(const string name, const double high, const double low, const double open, const datetime date, const color clr)
{
    double pipSize = Digits % 2 == 1 ? Point * 10 : Point;
    string labelH = "";
    if (S_N)
    {
        labelH = name;
    }
    if (S_H)
    {
        if (labelH != "")
            labelH = labelH + ", ";
        labelH = labelH + "H:" + DoubleToStr(high, Digits);
    }
    string labelL = "";
    if (S_L)
    {
        labelL = "L:" + DoubleToStr(low, Digits);
    }
    if (S_OD)
    {
        if (labelH != "")
            labelH = labelH + ", ";
        labelH = labelH + "ODH:" + DoubleToString((high - open) / pipSize, 1);
        if (labelL != "")
            labelL = labelL + ", ";
        labelL = labelL + "ODL:" + DoubleToString((low - open) / pipSize, 1);
    }
    if (S_OH)
    {
        if (labelH != "")
            labelH = labelH + ", ";
        labelH = labelH + "HL:" + DoubleToString((high - low) / pipSize, 1);
    }
    string idL = name + TimeToString(date) + "L";
    string idH = name + TimeToString(date) + "H";
    if (labelH != "" && ObjectFind(IndicatorObjPrefix + idH) == -1)
    {
        ObjectCreate(IndicatorObjPrefix + idH, OBJ_TEXT, 0, date, high);
        ObjectSetText(IndicatorObjPrefix + idH, labelH, FS, "Arial", clr);
    }
    if (labelL != "" && ObjectFind(IndicatorObjPrefix + idL) == -1)
    {
        ObjectCreate(IndicatorObjPrefix + idL, OBJ_TEXT, 0, date, low);
        ObjectSetText(IndicatorObjPrefix + idL, labelL, FS, "Arial", clr);
    }
}

void DrawTriangulation(const string id, const color clr, const int open, const int high, const int low, const int close)
{
    string id1 = IndicatorObjPrefix + id + "T1";
    if (ObjectFind(id1) == -1)
    {
        ObjectCreate(id1, OBJ_TREND, 0, Time[open], Open[open], Time[high], High[high]);
        ObjectSetInteger(0, id1, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, id1, OBJPROP_RAY_RIGHT, false);
    }
    string id2 = IndicatorObjPrefix + id + "T2";
    if (ObjectFind(id2) == -1)
    {
        ObjectCreate(id2, OBJ_TREND, 0, Time[open], Open[open], Time[low], Low[low]);
        ObjectSetInteger(0, id2, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, id2, OBJPROP_RAY_RIGHT, false);
    }
    string id3 = IndicatorObjPrefix + id + "T3";
    if (ObjectFind(id3) == -1)
    {
        ObjectCreate(id3, OBJ_TREND, 0, Time[high], High[high], Time[low], Low[low]);
        ObjectSetInteger(0, id3, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, id3, OBJPROP_RAY_RIGHT, false);
    }
    string id4 = IndicatorObjPrefix + id + "T4";
    if (ObjectFind(id4) == -1)
    {
        ObjectCreate(id4, OBJ_TREND, 0, Time[high], High[high], Time[close], Close[close]);
        ObjectSetInteger(0, id4, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, id4, OBJPROP_RAY_RIGHT, false);
    }
    string id5 = IndicatorObjPrefix + id + "T5";
    if (ObjectFind(id5) == -1)
    {
        ObjectCreate(id5, OBJ_TREND, 0, Time[low], Low[low], Time[close], Close[close]);
        ObjectSetInteger(0, id5, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, id5, OBJPROP_RAY_RIGHT, false);
    }
}

void UpdateNY(const datetime dt)
{
    if (NY_S)
    {
        if (ny.SetDate(dt))
        {
            double high = ny.GetHigh();
            double low = ny.GetLow();
            int start = ny.GetStartIndex();
            int end = ny.GetEndIndex();
            for (int ii = start; ii >= end; --ii)
            {
                ny_top[ii] = high;
                if (S_SM)
                    ny_middle[ii] = (high + low) / 2;
                ny_bottom[ii] = low;
            }
            if (S_SE)
            {
                string id = IndicatorObjPrefix + "ny" + TimeToString(Time[start]) + "SE";
                if (ObjectFind(id) == -1)
                {
                    ObjectCreate(id, OBJ_TREND, 0, Time[start], Open[start], Time[end], Close[end]);
                    ObjectSetInteger(0, id, OBJPROP_COLOR, Red);
                    ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
                }
            }
            if (S_TR)
            {
                DrawTriangulation("ny" + TimeToString(Time[start]), Red, start, ny.GetHighIndex(), ny.GetLowIndex(), end);
            }
            if (NY_draw_label)
            {
                CreateLabel("New York", high, low, Open[start], Time[start], Red);
            }
        }
    }
}

void UpdateLondon(const datetime dt)
{
    if (LO_S)
    {
        if (london.SetDate(dt))
        {
            double high = london.GetHigh();
            double low = london.GetLow();
            int start = london.GetStartIndex();
            int end = london.GetEndIndex();
            for (int ii = start; ii >= end; --ii)
            {
                london_top[ii] = high;
                if (S_SM)
                    london_middle[ii] = (high + low) / 2;
                london_bottom[ii] = low;
            }
            if (S_SE)
            {
                string id = IndicatorObjPrefix + "london" + TimeToString(Time[start]) + "SE";
                if (ObjectFind(id) == -1)
                {
                    ObjectCreate(id, OBJ_TREND, 0, Time[start], Open[start], Time[end], Close[end]);
                    ObjectSetInteger(0, id, OBJPROP_COLOR, Green);
                    ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
                }
            }
            if (S_TR)
            {
                DrawTriangulation("london" + TimeToString(Time[start]), Green, start, london.GetHighIndex(), london.GetLowIndex(), end);
            }
            if (LO_draw_label)
            {
                CreateLabel("London", high, low, Open[start], Time[start], Green);
            }
        }
    }
}

void UpdateTokyo(const datetime dt)
{
    if (TO_S)
    {
        if (tokyo.SetDate(dt))
        {
            double high = tokyo.GetHigh();
            double low = tokyo.GetLow();
            int start = tokyo.GetStartIndex();
            int end = tokyo.GetEndIndex();
            for (int ii = start; ii >= end; --ii)
            {
                tokyo_top[ii] = high;
                if (S_SM)
                    tokyo_middle[ii] = (high + low) / 2;
                tokyo_bottom[ii] = low;
            }
            if (S_SE)
            {
                string id = IndicatorObjPrefix + "tokyo" + TimeToString(Time[start]) + "SE";
                if (ObjectFind(id) == -1)
                {
                    ObjectCreate(id, OBJ_TREND, 0, Time[start], Open[start], Time[end], Close[end]);
                    ObjectSetInteger(0, id, OBJPROP_COLOR, Blue);
                    ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
                }
            }
            if (S_TR)
            {
                DrawTriangulation("tokyo" + TimeToString(Time[start]), Red, start, tokyo.GetHighIndex(), tokyo.GetLowIndex(), end);
            }
            if (TO_draw_label)
            {
                CreateLabel("Tokyo", high, low, Open[start], Time[start], Blue);
            }
        }
    }
}

void UpdateSydney(const datetime dt)
{
    if (SY_S)
    {
        if (sydney.SetDate(dt))
        {
            double high = sydney.GetHigh();
            double low = sydney.GetLow();
            int start = sydney.GetStartIndex();
            int end = sydney.GetEndIndex();
            for (int ii = start; ii >= end; --ii)
            {
                sydney_top[ii] = high;
                if (S_SM)
                    sydney_middle[ii] = (high + low) / 2;
                sydney_bottom[ii] = low;
            }
            if (S_SE)
            {
                string id = IndicatorObjPrefix + "sydney" + TimeToString(Time[start]) + "SE";
                if (ObjectFind(id) == -1)
                {
                    ObjectCreate(id, OBJ_TREND, 0, Time[start], Open[start], Time[end], Close[end]);
                    ObjectSetInteger(0, id, OBJPROP_COLOR, Yellow);
                    ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
                }
            }
            if (S_TR)
            {
                DrawTriangulation("sydney" + TimeToString(Time[start]), Red, start, sydney.GetHighIndex(), sydney.GetLowIndex(), end);
            }
            if (SY_draw_label)
            {
                CreateLabel("Sydney", high, low, Open[start], Time[start], Yellow);
            }
        }
    }
}

int lastBars = 0;

int start()
{
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars < 0)
        return -1;

    if (lastBars != Bars)
    {
        ExtCountedBars = 0;
        lastBars = Bars;
        ny.Reset();
        london.Reset();
        tokyo.Reset();
        sydney.Reset();
        ObjectsDeleteAll(0, OBJ_TEXT);
        ObjectsDeleteAll(0, OBJ_TREND);
    }

    int limit = Bars - 2;
    if (ExtCountedBars > 2)
        limit = Bars - ExtCountedBars - 1;
    for (int i = limit; i >= 0; --i)
    {
        datetime dt = Time[i];
        UpdateNY(dt);
        UpdateSydney(dt);
        UpdateLondon(dt);
        UpdateTokyo(dt);
    }
    return limit;
}

