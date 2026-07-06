// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65457
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
#property version "1.1"

#property strict
#property indicator_chart_window
#property indicator_buffers 15
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
#property indicator_color13 Purple
#property indicator_color14 Purple
#property indicator_color15 Purple

input bool NY_S = true;          // Show New York session
input int NY_Shift = 8;          // New York session Shift
input bool NY_draw_label = true; // Draw label for New York
input bool LO_S = true;          // Show London session (3:00 am - 12:00 pm EST/EDT)
input int LO_Shift = 3;          // London session Shift
input bool LO_draw_label = true; // Draw label for London
input bool TO_S = true;          // Show Tokyo session
input int TO_Shift = -5;         // Tokyo session Shift
input bool TO_draw_label = true; // Draw label for Tokyo
input bool SY_S = true;          // Show Sydney session
input int SY_Shift = -7;         // Sydney session Shift
input bool SY_draw_label = true; // Draw label for Sydney
input bool F_S = true;           // Show Frankfurt session
input int F_Shift = 4;           // Frankfurt session Shift
input bool F_draw_label = true;  // Draw label for Frankfurt

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
   double top[];
   double middle[];
   double bottom[];
   string _id;
   string _label;
   color _color;
   bool _drawLabel;
public:
   TimezoneCalculator(const int startHour, const int endHour, string id, string label, color clr, bool drawLabel)
   {
      _drawLabel = drawLabel;
      _color = clr;
      _id = id;
      _label = label;
      _initialized = false;
      _startHour = startHour;
      _endHour = endHour;
   }

   int RegisterStreams(int id)
   {
      SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 2, _color);
      SetIndexBuffer(id, top);
      SetIndexStyle(id + 1, DRAW_LINE, STYLE_SOLID, 2, _color);
      SetIndexBuffer(id + 1, middle);
      SetIndexStyle(id + 2, DRAW_LINE, STYLE_SOLID, 2, _color);
      SetIndexBuffer(id + 2, bottom);

      return id + 3;
   }

   void Reset()
   {
      _initialized = false;
   }

   void Update(const datetime dt)
   {
      if (!SetDate(dt))
      {
         return;
      }
      for (int ii = _startIndex; ii >= _endIndex; --ii)
      {
         top[ii] = _max;
         if (S_SM)
         {
            middle[ii] = (_max + _min) / 2;
         }
         bottom[ii] = _min;
      }
      if (S_SE)
      {
         string id = IndicatorObjPrefix + _id + TimeToString(Time[_startIndex]) + "SE";
         if (ObjectFind(id) == -1)
         {
            ObjectCreate(id, OBJ_TREND, 0, Time[_startIndex], Open[_startIndex], Time[_endIndex], Close[_endIndex]);
            ObjectSetInteger(0, id, OBJPROP_COLOR, _color);
            ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
         }
      }
      if (S_TR)
      {
         DrawTriangulation(_id + TimeToString(Time[_startIndex]), _color, _startIndex, _maxIndex, _minIndex, _endIndex);
      }
      if (_drawLabel)
      {
         CreateLabel(_label, _max, _min, Open[_startIndex], Time[_startIndex], _color);
      }
   }

private:
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
      {
         return false;
      }
      if (dt >= _dtStart && dt <= _dtEnd)
      {
         if (_endIndex == 0)
         {
            if (!UpdateIndexes())
            {
               return false;
            }
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
      {
         return false;
      }
      UpdateHighLow();
      return true;
   }

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
      return _startIndex != _endIndex;
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
      if (_startHour > _endHour)
      {
         _dtStart -= 86400;
      }
      if (!UpdateIndexes())
         return false;
      UpdateHighLow();
      return dt >= _dtStart && dt <= _dtEnd;
   }
};

TimezoneCalculator* timezones[];
int Window;

int init()
{
   if (NY_S)
   {
      int size = ArraySize(timezones);
      ArrayResize(timezones, size + 1);
      timezones[size] = new TimezoneCalculator(NY_Shift, NY_Shift + 9, "ny", "New York", Red, NY_draw_label);
   }
   if (LO_S)
   {
      int size = ArraySize(timezones);
      ArrayResize(timezones, size + 1);
      timezones[size] = new TimezoneCalculator(LO_Shift, LO_Shift + 9, "lo", "London", Green, LO_draw_label);
   }
   if (TO_S)
   {
      int size = ArraySize(timezones);
      ArrayResize(timezones, size + 1);
      timezones[size] = new TimezoneCalculator(TO_Shift, TO_Shift + 9, "to", "Tokyo", Blue, TO_draw_label);
   }
   if (SY_S)
   {
      int size = ArraySize(timezones);
      ArrayResize(timezones, size + 1);
      timezones[size] = new TimezoneCalculator(SY_Shift, SY_Shift + 9, "sy", "Sydney", Yellow, SY_draw_label);
   }
   if (F_S)
   {
      int size = ArraySize(timezones);
      ArrayResize(timezones, size + 1);
      timezones[size] = new TimezoneCalculator(F_Shift, F_Shift + 9, "fr", "Frankfurt", Yellow, F_draw_label);
   }

   
   IndicatorName = GenerateIndicatorName("TRADESESSIONS");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   Window = WindowFind(IndicatorName);
   IndicatorDigits(Digits);

   int id = 0;
   for (int i = 0; i < ArraySize(timezones); ++i)
   {
      TimezoneCalculator* item = timezones[i];
      id = item.RegisterStreams(id);
   }

   return 0;
}

int deinit()
{
   for (int i = 0; i < ArraySize(timezones); ++i)
   {
      delete timezones[i];
   }
   ArrayResize(timezones, 0);
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
   {
      return -1;
   }

   if (lastBars != Bars)
   {
      ExtCountedBars = 0;
      lastBars = Bars;
      for (int i = 0; i < ArraySize(timezones); ++i)
      {
         timezones[i].Reset();
      }
      ObjectsDeleteAll(0, OBJ_TEXT);
      ObjectsDeleteAll(0, OBJ_TREND);
   }

   int limit = Bars - 2;
   if (ExtCountedBars > 2)
   {
      limit = Bars - ExtCountedBars - 1;
   }
   for (int i = limit; i >= 0; --i)
   {
      datetime dt = Time[i];
      for (int i = 0; i < ArraySize(timezones); ++i)
      {
         TimezoneCalculator* item = timezones[i];
         item.Update(dt);
      }
   }
   return limit;
}
