// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70118

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
#property link "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 36

input double level_1 = 50;
input double level_2 = 100;
input double level_3 = 150;
input bool NY_S = true;          // Show New York session
input bool NY_L = true;          // Show New York session labels
input int NY_Shift = 8;          // New York session Shift
input bool NY_draw_label = true; // Draw label for New York
input bool LO_S = true;          // Show London session (3:00 am - 12:00 pm EST/EDT)
input bool LO_L = true;          // Show London session labels
input int LO_Shift = 3;          // London session Shift
input bool LO_draw_label = true; // Draw label for London
input bool TO_S = true;          // Show Tokyo session
input bool TO_L = true;          // Show Tokyo session labels
input int TO_Shift = -5;         // Tokyo session Shift
input bool TO_draw_label = true; // Draw label for Tokyo
input bool SY_S = true;          // Show Sydney session
input bool SY_L = true;          // Show Sydney session labels
input int SY_Shift = -7;         // Sydney session Shift
input bool SY_draw_label = true; // Draw label for Sydney

input bool S_N = true;   // Show session name
input bool S_H = true;   // Show session high
input bool S_L = true;   // Show session low
input bool S_OD = true;  // Show distance to open
input bool S_OH = true;  // Show distance between high/low
input bool S_SM = false; // Show mid line
input bool S_SE = false; // Show start/end line
input bool S_TR = false; // Show triangulation
input int FS = 6;        // Font Size

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int
   try
      = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try ++);
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

   double top_1[];
   double top_2[];
   double top_3[];
   double top[];
   double middle[];
   double bottom[];
   double bottom_1[];
   double bottom_2[];
   double bottom_3[];
   string _id;
   string name;
   color clr;
   bool draw_label;

   void Update()
   {
      double high = GetHigh();
      double low = GetLow();
      int start = GetStartIndex();
      int end = GetEndIndex();
      for (int ii = start; ii >= end; --ii)
      {
         top[ii] = high;
         top_1[ii] = high + (high - low) * level_1 / 100;
         top_2[ii] = high + (high - low) * level_2 / 100;
         top_3[ii] = high + (high - low) * level_3 / 100;
         if (S_SM)
            middle[ii] = (high + low) / 2;
         bottom[ii] = low;
         bottom_1[ii] = low - (high - low) * level_1 / 100;
         bottom_2[ii] = low - (high - low) * level_2 / 100;
         bottom_3[ii] = low - (high - low) * level_3 / 100;
      }
      if (S_SE)
      {
         string id = IndicatorObjPrefix + _id + TimeToString(Time[start]) + "SE";
         if (ObjectFind(id) == -1)
         {
            ObjectCreate(id, OBJ_TREND, 0, Time[start], Open[start], Time[end], Close[end]);
            ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
            ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
         }
      }
      if (S_TR)
      {
         DrawTriangulation(_id + TimeToString(Time[start]), clr, start, GetHighIndex(), GetLowIndex(), end);
      }
      if (draw_label)
      {
         CreateLabel(name, high, low, Open[start], Time[start], clr);
      }
   }

   int RegisterStreams(int id, color streamColor)
   {
      clr = streamColor;
      SetIndexStyle(id + 0, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 0, top);
      SetIndexStyle(id + 1, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 1, middle);
      SetIndexStyle(id + 2, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 2, bottom);
      SetIndexStyle(id + 3, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 3, top_1);
      SetIndexStyle(id + 4, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 4, top_2);
      SetIndexStyle(id + 5, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 5, top_3);
      SetIndexStyle(id + 6, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 6, bottom_1);
      SetIndexStyle(id + 7, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 7, bottom_2);
      SetIndexStyle(id + 8, DRAW_LINE, STYLE_SOLID, 2, clr);
      SetIndexBuffer(id + 8, bottom_3);
      return id + 9;
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

TimezoneCalculator* tz[];
int Window;

int init()
{
   int id = 0;
   if (NY_S)
   {
      int size = ArraySize(tz);
      ArrayResize(tz, size + 1);
      tz[size] = new TimezoneCalculator(NY_Shift, NY_Shift + 9);
      tz[size].name = "New York";
      tz[size]._id = "ny";
      tz[size].draw_label = NY_draw_label;
      id = tz[size].RegisterStreams(id, Red);
   }
   if (LO_S)
   {
      int size = ArraySize(tz);
      ArrayResize(tz, size + 1);
      tz[size] = new TimezoneCalculator(LO_Shift, LO_Shift + 9);
      tz[size].name = "London";
      tz[size]._id = "lo";
      tz[size].draw_label = LO_draw_label;
      id = tz[size].RegisterStreams(id, Green);
   }
   if (TO_S)
   {
      int size = ArraySize(tz);
      ArrayResize(tz, size + 1);
      tz[size] = new TimezoneCalculator(TO_Shift, TO_Shift + 9);
      tz[size].name = "Tokyo";
      tz[size]._id = "to";
      tz[size].draw_label = TO_draw_label;
      id = tz[size].RegisterStreams(id, Blue);
   }
   if (SY_S)
   {
      int size = ArraySize(tz);
      ArrayResize(tz, size + 1);
      tz[size] = new TimezoneCalculator(SY_Shift, SY_Shift + 9);
      tz[size].name = "Sydney";
      tz[size]._id = "sy";
      tz[size].draw_label = SY_draw_label;
      id = tz[size].RegisterStreams(id, Yellow);
   }

   IndicatorName = GenerateIndicatorName("TRADESESSIONS");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   Window = WindowFind(IndicatorName);
   IndicatorDigits(Digits);

   return 0;
}

int deinit()
{
   for (int i = 0; i < ArraySize(tz); ++i)
   {
      delete tz[i];
   }
   ArrayResize(tz, 0);
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

int lastBars = 0;

int start()
{
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return -1;

   if (lastBars != Bars)
   {
      ExtCountedBars = 0;
      lastBars = Bars;
      for (int i = 0; i < ArraySize(tz); ++i)
      {
         tz[i].Reset();
      }
      ObjectsDeleteAll(0, OBJ_TEXT);
      ObjectsDeleteAll(0, OBJ_TREND);
   }

   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   for (int i = limit; i >= 0; --i)
   {
      datetime dt = Time[i];
      for (int ii = 0; ii < ArraySize(tz); ++ii)
      {
         if (tz[ii].SetDate(Time[i]))
         {
            tz[ii].Update();
         }
      }
   }
   return limit;
}
