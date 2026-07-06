//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76393
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
 
#property strict
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_label1 "Up"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 0x08ff00
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Down"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 0x0000ff
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

// Simple type variable v1.0

// Object destructor interface v1.0

#ifndef IObjectDestructor_IMPL
#define IObjectDestructor_IMPL
template<typename T>
class IObjectDestructor
{
public:
   virtual void Free(T obj) = 0;
};
#endif

#ifndef SimpleTypeVariable_IMPL
#define SimpleTypeVariable_IMPL

template<typename T>
class SimpleTypeVariable
{
   T _value;
   T _deafultValue;
   bool _isInitialized;
public:
   SimpleTypeVariable(T deafultValue, IObjectDestructor<T>* destructor)
   {
      //ignore destructor
      _value = deafultValue;
      _deafultValue = deafultValue;
      _isInitialized = false;
   }
   void Clear()
   {
      _value = _deafultValue;
      _isInitialized = false;
   }
   bool IsInitialized()
   {
      return _isInitialized;
   }
   T Get()
   {
      return _value;
   }
   void Set(T value)
   {
      _isInitialized = true;
      _value = value;
   }
};
#endif

#define ColorRGB(red, green, blue, transp) (uint)(red + (green << 8) + (blue << 16) + ((uint)(transp * 2.55) << 24))
#define GetColorOnly(clr) (clr & 0xFFFFFF)
#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)
#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

bool NumberToBool(double number)
{
   return number != EMPTY_VALUE && number != 0;
}

class FirstBarState
{
   bool _first;
public:
   FirstBarState()
   {
      _first = true;
   }
   void Clear()
   {
      _first = true;
   }
   bool IsFirst()
   {
      bool first = _first;
      _first = false;
      return first;
   }
};

class NewBarState
{
   datetime _last;
public:
   NewBarState()
   {
      _last = 0;
   }
   void Clear()
   {
      _last = 0;
   }
   bool IsNew(datetime date)
   {
      bool isnew = _last != date;
      _last = date;
      return isnew;
   }
};

uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   return value - bottomValue < topValue - value 
      ? bottomColor
      : topColor;
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

datetime Timestamp(int year, int month, int day, int hour, int minute, int second)
{
   MqlDateTime time;
   time.year = year;
   time.mon = month;
   time.day = day;
   time.hour = hour;
   time.min = minute;
   time.sec = second;
   return StructToTime(time);
}

class Runtime
{
public:
   static void Error(string message)
   {
      Print(message);
      ExpertRemove();
   }
};
// Abstract integer stream v1.0

#ifndef TAStream_IMPL
#define TAStream_IMPL
// Date/time Stream v.1.0

#ifndef TIStream_IMPL
#define TIStream_IMPL

template <typename T>
interface TIStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, T &val) = 0;
};

#endif

template <typename T>
class TAStream : public TIStream<T>
{
   int _refs;   
public:
   TAStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif
// PineScript timeframe.* functions
// v1.0

class Timeframe
{
public:
   static string Period()
   {
      if (_Period == PERIOD_M1) { return "1"; }
      if (_Period == PERIOD_M5) { return "5"; }
      if (_Period == PERIOD_M15) { return "15"; }
      if (_Period == PERIOD_M30) { return "30"; }
      if (_Period == PERIOD_H1) { return "60"; }
      if (_Period == PERIOD_H4) { return "240"; }
      if (_Period == PERIOD_D1) { return "D"; }
      if (_Period == PERIOD_W1) { return "W"; }
      if (_Period == PERIOD_MN1) { return "M"; }
      return "1";
   }
   
   static int InSeconds(string resolution)
   {
      return (int)GetTimeframe(resolution);
   }
   
   static bool Change(string timeframe, int pos)
   {
      int bars = iBars(_Symbol, _Period);
      if (bars <= pos + 1)
      {
         return true;
      }
      datetime currentBar = iTime(_Symbol, _Period, pos);
      datetime prevBar = iTime(_Symbol, _Period, pos + 1);
      ENUM_TIMEFRAMES tf = GetTimeframe(timeframe);
      return iBarShift(_Symbol, tf, currentBar) != iBarShift(_Symbol, tf, prevBar);
   }
   
   static bool IsDWM()
   {
      switch (_Period)
      {
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return true;
      }
      return false;
   }
   
   static ENUM_TIMEFRAMES GetTimeframe(string resolution)
   {
      if (resolution == "1") { return PERIOD_M1; }
      if (resolution == "5") { return PERIOD_M5; }
      if (resolution == "15") { return PERIOD_M15; }
      if (resolution == "30") { return PERIOD_M30; }
      if (resolution == "60") { return PERIOD_H1; }
      if (resolution == "240") { return PERIOD_H4; }
      if (resolution == "D") { return PERIOD_D1; }
      if (resolution == "W") { return PERIOD_W1; }
      if (resolution == "M") { return PERIOD_MN1; }
      return PERIOD_CURRENT;
   }

   static bool IsIntraday()
   {
      return ~IsDWM();
   }

   static int Interval()
   {
      switch (_Period)
      {
         case PERIOD_M1:
         case PERIOD_H1:
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return 1;
         case PERIOD_M5:
            return 5;
         case PERIOD_M15:
            return 15;
         case PERIOD_M30:
            return 30;
         case PERIOD_H4:
            return 4;
      }
      return INT_MIN;
   }
};
// Time-related functions from Pine Script
// v1.2

class PineScriptTime
{
public:
   static int Now()
   {
      return TimeCurrent() * 1000;
   }
   static int ToMS(datetime time)
   {
      return time * 1000;
   }
   static int Year(datetime time)
   {
      return TimeYear(time);
   }
   static int Year(datetime time, string timezone)
   {
      return TimeYear(time);
   }
   static int Month(datetime time)
   {
      return TimeMonth(time);
   }
   static int Month(datetime time, string timezone)
   {
      return TimeMonth(time);
   }
   static int DayOfMonth(datetime time)
   {
      return TimeDay(time);
   }
   static int DayOfMonth(datetime time, string timezone)
   {
      return TimeDay(time);
   }
   static int DayOfWeek(datetime time)
   {
      return TimeDayOfWeek(time);
   }
   static int DayOfWeek(datetime time, string timezone)
   {
      return TimeDayOfWeek(time);
   }
   static int Hour(datetime time)
   {
      return TimeHour(time);
   }
   static int Hour(datetime time, string timezone)
   {
      return TimeHour(time);
   }
   static int Minute(datetime time)
   {
      return TimeMinute(time);
   }
   static int Minute(datetime time, string timezone)
   {
      return TimeMinute(time);
   }
   static int Second(datetime time)
   {
      return TimeSeconds(time);
   }
   static int Second(datetime time, string timezone)
   {
      return TimeSeconds(time);
   }
   static int Sunday()
   {
      return 0;
   }
   static int Monday()
   {
      return 1;
   }
   static int Tuesday()
   {
      return 2;
   }
   static int Wednesday()
   {
      return 3;
   }
   static int Thursday()
   {
      return 4;
   }
   static int Friday()
   {
      return 5;
   }
   static int Saturday()
   {
      return 6;
   }
   static bool IsIntradayTradingTime(const MqlDateTime &current_time, int startTime, int endTime)
   {
      if (startTime == endTime)
      {
         return true;
      }
      int current_t = TimeToInt(current_time);
      if (startTime > endTime)
      {
         return current_t >= startTime || current_t <= endTime;
      }
      return current_t >= startTime && current_t <= endTime;
   }
   static int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }
   
   static int ParseTime(const string time, string &error)
   {
      string items[];
      StringSplit(time, ':', items);
      int hours;
      int minutes;
      int seconds;
      if (ArraySize(items) > 1)
      {
         if (ArraySize(items) != 3)
         {
            error = "Bad format for " + time;
            return -1;
         }
         //hh:mm:ss
         seconds = (int)StringToInteger(items[2]);
         minutes = (int)StringToInteger(items[1]);
         hours = (int)StringToInteger(items[0]);
      }
      else if (StringLen(time) == 6)
      {
         //hhmmss
         int time_parsed = (int)StringToInteger(time);
         seconds = time_parsed % 100;
         
         time_parsed /= 100;
         minutes = time_parsed % 100;
         time_parsed /= 100;
         hours = time_parsed % 100;
      }
      else if (StringLen(time) == 4)
      {
         //hhmm
         int time_parsed = (int)StringToInteger(time);
         seconds = 0;
         minutes = time_parsed % 100;
         time_parsed /= 100;
         hours = time_parsed % 100;
      }
      else
      {
         error = "Unknown format: " + time;
         return -1;
      }
      if (hours > 24)
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }
      if (seconds > 59)
      {
         error = "Incorrect number of seconds in " + time;
         return -1;
      }
      if (hours == 24 && (minutes != 0 || seconds != 0))
      {
         error = "Incorrect date";
         return -1;
      }
      return (hours * 60 + minutes) * 60 + seconds;
   }
};
// Time filter condition v1.0

// Abstract condition v1.1

// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ICondition_DEF
#define ICondition_DEF

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};
#endif

#ifndef AConditionBase_IMP
#define AConditionBase_IMP

class AConditionBase : public ICondition
{
   int _references;
   string _conditionName;
public:
   AConditionBase(string name = "")
   {
      _conditionName = name;
      _references = 1;
   }

   virtual void AddRef()
   {
      ++_references;
   }

   virtual void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      if (_conditionName == "" || _conditionName == NULL)
      {
         return "";
      }
      return _conditionName + ": " + (IsPass(period, date) ? "true" : "false");
   }
};

#endif


#ifndef TimeFilterCondition_IMP
#define TimeFilterCondition_IMP

class TimeFilterCondition : public AConditionBase
{
   int _startTime;
   int _endTime;
public:
   TimeFilterCondition(int startTime, int endTime)
      :AConditionBase("Trading Time")
   {
      _startTime = startTime;
      _endTime = endTime;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
      {
         return false;
      }
      return PineScriptTime::IsIntradayTradingTime(current_time, _startTime, _endTime);
   }
};

#endif

// Date/time stream v1.2

#ifndef DateTimeStream_IMP
#define DateTimeStream_IMP

TimeFilterCondition* CreateTimeFilter(string session)
{
   string items[];
   StringSplit(session, '-', items);
   if (ArraySize(items) != 2)
   {
      return NULL;
   }
   string error;
   int startTime = PineScriptTime::ParseTime(items[0], error);
   if (startTime == -1)
   {
      Print(error);
      return NULL;
   }
   int endTime = PineScriptTime::ParseTime(items[1], error);
   if (endTime == -1)
   {
      Print(error);
      return NULL;
   }
   return new TimeFilterCondition(startTime, endTime);
}

class DateTimeStream : public TAStream<datetime>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   ENUM_TIMEFRAMES _targetTimeframe;
   ICondition* _timeFilter;
public:
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _timeFilter = NULL;
      _symbol = symbol;
      _timeframe = timeframe;
      _targetTimeframe = timeframe;
   }
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe, string targetTimeframe, string session, string timezone)
   {
      _timeFilter = CreateTimeFilter(session);
      _symbol = symbol;
      _timeframe = timeframe;
      _targetTimeframe = Timeframe::GetTimeframe(targetTimeframe);
   }
   ~DateTimeStream()
   {
      if (_timeFilter != NULL)
      {
         delete _timeFilter;
      }
   }

   bool GetValue(const int period, datetime &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
      {
         return false;
      }
      int shift = iBarShift(_symbol, _targetTimeframe, iTime(_symbol, _timeframe, period));
      if (shift < 0)
      {
         return false;
      }
      val = iTime(_symbol, _targetTimeframe, shift);
      if (!_timeFilter.IsPass(period, val))
      {
         return false;
      }
      return true;
   }
   
   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
#endif

// Custom type variable v1.0

#ifndef CustomTypeVariable_IMPL
#define CustomTypeVariable_IMPL


template<typename T>
class CustomTypeVariable
{
   T* _value;
   IObjectDestructor<T*>* _destructor;
   bool _isInitialized;
public:
   CustomTypeVariable(T* deafultValue, IObjectDestructor<T*>* destructor)
   {
      _destructor = destructor;
      _value = deafultValue;
      _isInitialized = false;
   }
   ~CustomTypeVariable()
   {
      if (_value != NULL)
      {
         _destructor.Free(_value);
         _value.Release();
      }
   }
   void Clear()
   {
      if (_value != NULL)
      {
         _destructor.Free(_value);
         _value.Release();
         _value = NULL;
      }
      _isInitialized = false;
   }
   bool IsInitialized()
   {
      return _isInitialized;
   }
   T* Get()
   {
      return _value;
   }
   void Set(T* value)
   {
      _isInitialized = true;
      if (_value != NULL)
      {
         _destructor.Free(_value);
         _value.Release();
      }
      _value = value;
      if (_value != NULL)
      {
         _value.AddRef();
      }
   }
};
#endif

// Array v1.7
// Array interface v1.0

// Line array interface v1.2
// Line object v1.7

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   string _xloc;
   uint _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
   string _extend;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window, bool global)
   {
      _extend = "none";
      _refs = 1;
      _x1 = x1;
      _x2 = x2;
      _y1 = y1;
      _y2 = y2;
      _id = id;
      _clr = Blue;
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      _window = window;
      _collectionId = collectionId;
      this.global = global;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   
   void CopyTo(Line* line)
   {
      line._x1 = _x1;
      line._y1 = _y1;
      line._x2 = _x2;
      line._y2 = _y2;
      line._clr = _clr;
      line._width = _width;
      line._timeframe = _timeframe;
      line._style = _style;
      line._window = _window;
      line._extend = _extend;
   }
   
   bool IsGlobal()
   {
      return global;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   static void SetStyle(Line* line, string style)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetStyle(style);
   }
   
   Line* SetStyle(string style)
   {
      _style = style;
      return &this;
   }
   
   static void SetExtend(Line* line, string extend)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetExtend(extend);
   }
   
   Line* SetExtend(string extend)
   {
      _extend = extend;
      return &this;
   }

   void SetXY1(int x, double y)
   {
      _x1 = x;
      _y1 = y;
   }
   static void SetXY1(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY1(x, y);
   }
   
   void SetXY2(int x, double y)
   {
      _x2 = x;
      _y2 = y;
   }
   static void SetXY2(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY2(x, y);
   }

   void SetX1(int x) { _x1 = x; }
   static void SetX1(Line* line, int x) { if (line == NULL) { return; } line.SetX1(x); }
   void SetX2(int x) { _x2 = x; }
   static void SetX2(Line* line, int x) { if (line == NULL) { return; } line.SetX2(x); }
   void SetY1(double y) { _y1 = y; }
   static void SetY1(Line* line, double y) { if (line == NULL) { return; } line.SetY1(y); }
   void SetY2(double y) { _y2 = y; }
   static void SetY2(Line* line, double y) { if (line == NULL) { return; } line.SetY2(y); }

   int GetX1() { return _x1; }
   static int GetX1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX1(); }
   int GetX2() { return _x2; }
   static int GetX2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX2(); }
   double GetY1() { return _y1; }
   static double GetY1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY1(); }
   double GetY2() { return _y2; }
   static double GetY2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY2(); }

   Line* SetColor(uint clr)
   {
      _clr = clr;
      return &this;
   }
   static void SetColor(Line* line, uint clr)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetColor(clr);
   }

   static void SetWidth(Line* line, int width)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetWidth(width);
   }

   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }
   
   static void SetXLoc(Line* line, string xloc)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXLoc(xloc);
   }
   Line* SetXLoc(string xloc)
   {
      _xloc = xloc;
      return &this;
   }

   void Redraw()
   {
      if (_y1 == EMPTY_VALUE || _y2 == EMPTY_VALUE)
      {
         return;
      }
      datetime x1 = GetX(_x1);
      datetime x2 = GetX(_x2);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, GetStyleMQL());
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         if (_extend == "right")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
         }
         else if (_extend == "left")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
         }
         else if (_extend == "both")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
         }
         else if (_extend == "none")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, false);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, false);
         }
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, x2);
   }
private:
   datetime GetX(int x)
   {
      if (_xloc == "bar_time")
      {
         return x;
      }
      int pos1 = iBars(_Symbol, _timeframe) - x - 1;
      return iTime(_Symbol, _timeframe, pos1);
   }
   int GetStyleMQL()
   {
      if (_style == "dashed")
      {
         return STYLE_DASH;
      }
      if (_style == "solid")
      {
         return STYLE_SOLID;
      }
      return STYLE_SOLID;
   }
};
// Template for array interface v2.0

template <typename CLASS_TYPE>
interface ITArray
{
public:
   virtual void AddRef() = 0;
   virtual int Release() = 0;
   virtual void Unshift(CLASS_TYPE value) = 0;
   virtual int Size() = 0;
   virtual ITArray<CLASS_TYPE>* Push(CLASS_TYPE value) = 0;
   virtual CLASS_TYPE Pop() = 0;
   virtual CLASS_TYPE Get(int index) = 0;
   virtual void Set(int index, CLASS_TYPE value) = 0;
   virtual CLASS_TYPE Shift() = 0;
   virtual CLASS_TYPE Remove(int index) = 0;
   virtual int Includes(CLASS_TYPE value) = 0;
};

class ILineArray : public ITArray<Line*>
{
public:
   virtual ILineArray* Slice(int from, int to) = 0;
   virtual ILineArray* Clear() = 0;
};
// bool array interface v1.0

class IBoolArray
{
public:
   virtual void Unshift(int value) = 0;
   virtual int Size() = 0;
   virtual IBoolArray* Push(int value) = 0;
   virtual int Pop() = 0;
   virtual int Get(int index) = 0;
   virtual void Set(int index, int value) = 0;
   virtual IBoolArray* Slice(int from, int to) = 0;
   virtual IBoolArray* Clear() = 0;
   virtual int Shift() = 0;
   virtual int Remove(int index) = 0;
   virtual int Includes(int value) = 0;
};
#ifndef SimpleTypeArray_IMPL
#define SimpleTypeArray_IMPL

template <typename CLASS_TYPE>
interface ISimpleTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ISimpleTypeArray<CLASS_TYPE>* Clear() = 0;
};
template <typename CLASS_TYPE>
class SimpleTypeArray : public ISimpleTypeArray<CLASS_TYPE>
{
   CLASS_TYPE _array[];
   int _defaultSize;
   CLASS_TYPE _defaultValue;
   CLASS_TYPE _emptyValue;
   int _refs;
public:
   SimpleTypeArray(int size, CLASS_TYPE defaultValue, CLASS_TYPE emptyValue)
   {
      _refs = 1;
      _defaultSize = size;
      _defaultValue = defaultValue;
      _emptyValue = emptyValue;
      Clear();
   }

   ~SimpleTypeArray()
   {
      Clear();
   }

   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   ISimpleTypeArray<CLASS_TYPE>* Clear()
   {
      int size = ArraySize(_array);
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   CLASS_TYPE Pop()
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   CLASS_TYPE Shift()
   {
      return Remove(0);
   }

   CLASS_TYPE Get(int index)
   {
      if (index >= Size())
      {
         return _emptyValue;
      }
      if (index < 0)
      {
         index = Size() + index;
      }
      return _array[index];
   }
   
   void Set(int index, CLASS_TYPE value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   CLASS_TYPE Remove(int index)
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE PercentRank(int index)
   {
      int arraySize = Size();
      if (arraySize == 0 || arraySize <= index) { return _emptyValue; }
      CLASS_TYPE target = Get(index);
      if (target == _emptyValue)
      {
         return _emptyValue;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         CLASS_TYPE current = Get(i);
         if (current != _emptyValue && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }
   
   CLASS_TYPE Max()
   {
      if (Size() == 0) { return _emptyValue; }
      CLASS_TYPE max = Get(0);
      for (int i = 1; i < Size(); ++i)
      {
         CLASS_TYPE current = Get(i);
         if (max == _emptyValue || (current != _emptyValue && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   CLASS_TYPE Min()
   {
      if (Size() == 0) { return _emptyValue; }
      CLASS_TYPE min = Get(0);
      for (int i = 1; i < Size(); ++i)
      {
         CLASS_TYPE current = Get(i);
         if (min == _emptyValue || (current != _emptyValue && min > current))
         {
            min = current;
         }
      }
      return min;
   }
   
   CLASS_TYPE Sum()
   {
      CLASS_TYPE sum = 0;
      for (int i = 0; i < Size(); ++i)
      {
         sum += Get(i);
      }
      return sum;
   }
   double Stdev()
   {
      double sum = 0;
      double ssum = 0;
      int size = Size();
      if (size < 2)
      {
         return 0;
      }
      for (int i = 0; i < size; i++)
      {
         CLASS_TYPE value = Get(i);
         sum += value;
         ssum += MathPow(value, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
};
#endif


#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v1.3
#ifndef CustomTypeArray_IMPL
#define CustomTypeArray_IMPL

template <typename CLASS_TYPE>
interface ICustomTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ICustomTypeArray<CLASS_TYPE>* Clear() = 0;
};
template <typename CLASS_TYPE>
class CustomTypeArray : public ICustomTypeArray<CLASS_TYPE>
{
   CLASS_TYPE _array[];
   int _defaultSize;
   CLASS_TYPE _defaultValue;
   int _refs;
public:
   CustomTypeArray(int size, CLASS_TYPE defaultValue)
   {
      _refs = 1;
      _defaultValue = defaultValue;
      if (_defaultValue != NULL)
      {
         _defaultValue.AddRef();
      }
      _defaultSize = size;
      Clear();
   }

   ~CustomTypeArray()
   {
      Clear();
      if (_defaultValue != NULL)
      {
         _defaultValue.Release();
      }
   }

   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   ICustomTypeArray<CLASS_TYPE>* Clear()
   {
      int size = ArraySize(_array);
      int i;
      for (i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            DeleteItem(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (i = 0; i < _defaultSize; ++i)
      {
         _array[i] = Clone(_defaultValue, i);
      }
      return &this;
   }

   void Unshift(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
      return &this;
   }

   CLASS_TYPE Pop()
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value != NULL && value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   CLASS_TYPE Shift()
   {
      return Remove(0);
   }

   CLASS_TYPE Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, CLASS_TYPE value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      _array[index] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }
   
   CLASS_TYPE Remove(int index)
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value == NULL || value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
   
   int Includes(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
protected:
   virtual CLASS_TYPE Clone(CLASS_TYPE item, int index)
   {
      return NULL;
   }
   virtual void DeleteItem(CLASS_TYPE item)
   {
   }
};
#endif
// Collection of lines v1.3

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL



class LinesCollection
{
   string _id;
   Line* _array[];
   static LinesCollection* _collections[];
   static LinesCollection* _all;
   static int _max;
public:
   static Line* Get(Line* line, int index)
   {
      if (line == NULL)
      {
         return NULL;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      if (_all == NULL)
      {
         if (!full)
         {
            _all = new LinesCollection("");
         }
      }
      else
      {
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
   }

   static void Delete(Line* line)
   {
      if (line == NULL)
      {
         return;
      }
      if (!_all.DeleteItem(line))
      {
         return;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(line);
   }

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId, bool global = false)
   {
      if (_all == NULL)
      {
         Clear();
      }
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x1 - 1);
      string lineId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, WindowOnDropped(), global);
      LinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(line);
      _all.Add(line);
      int allLinesCount = _all.Count();
      if (allLinesCount > _max)
      {
         for (int i = 0; i < allLinesCount; ++i)
         {
            Line* lineToDelete = _all.Get(i);
            if (!lineToDelete.IsGlobal() && lineToDelete != line)
            {
               Delete(lineToDelete);
               break;
            }
         }
      }
      line.Release();
      return line;
   }

   static void SetMaxLines(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLines();
      }
   }
private:
   LinesCollection(string id)
   {
      _id = id;
   }

   ~LinesCollection()
   {
      ClearItems();
   }
   
   string GetId()
   {
      return _id;
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   int Count()
   {
      return ArraySize(_array);
   }

   Line* GetFirst()
   {
      return _array[0];
   }

   Line* Get(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[index];
   }
   Line* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }
   
   int FindIndex(Line* line)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == line)
         {
            return i;
         }
      }
      return -1;
   }

   bool DeleteItem(Line* line)
   {
      int index = FindIndex(line);
      if (index == -1)
      {
         return false;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      return true;
   }
   
   void Add(Line* line)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = line;
      if (line != NULL)
      {
         line.AddRef();
      }
   }

   void RedrawLines()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(LinesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LinesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
LinesCollection* LinesCollection::_collections[];
LinesCollection* LinesCollection::_all;
int LinesCollection::_max = 50;
#endif

class LineArray : public CustomTypeArray<Line*>
{
public:
   LineArray(int size, Line* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Line* Clone(Line* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Line* clone = LinesCollection::Create(item.GetId() + index, item.GetX1(), item.GetY1(), item.GetX2(), item.GetY2(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Line* item)
   {
      LinesCollection::Delete(item);
   }
};
#endif
#ifndef LabelArray_IMPL
#define LabelArray_IMPL
// Label array v1.0

// Collection of labels v1.3

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.6

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   uint _color;
   uint _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   string _textAlign;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   int _window;
   bool globalLabel;
public:
   Label(int x, double y, string labelId, string collectionId, int window, bool globalLabel)
   {
      _refs = 1;
      _window = window;
      _textColor = Yellow;
      _x = x;
      _y = y;
      _labelId = labelId;
      _collectionId = collectionId;
      _font = "Arial";
      _textAlign = "";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      this.globalLabel = globalLabel;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   
   void CopyTo(Label* label)
   {
      label._color = _color;
      label._textColor = _textColor;
      label._text = _text;
      label._textAlign = _textAlign;
      label._x = _x;
      label._y = _y;
      label._font = _font;
      label._style = _style;
      label._size = _size;
      label._yloc = _yloc;
      label._timeframe = _timeframe;
      label._window = _window;
   }
   
   bool IsGlobal()
   {
      return globalLabel;
   }
   
   string GetId()
   {
      return _labelId;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   int GetX()
   {
      return _x;
   }
   static int GetX(Label* label)
   {
      if (label == NULL)
      {
         return 0;
      }
      return label.GetX();
   }

   double GetY()
   {
      return _y;
   }
   static double GetY(Label* label)
   {
      if (label == NULL)
      {
         return 0;
      }
      return label.GetY();
   }
   void SetX(int x) { _x = x; }
   static void SetX(Label* label, int x) { if (label == NULL) { return; } label.SetX(x); }
   void SetY(double y) { _y = y; }
   static void SetY(Label* label, double y) { if (label == NULL) { return; } label.SetY(y); }
   static void SetXY(Label* label, int x, double y)
   {
      if (label == NULL) { return; }
      label.SetX(x);
      label.SetY(y);
  }

   Label* SetSize(string size)
   {
      _size = size;
      return &this;
   }
   static void SetSize(Label* label, string size)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetSize(size);
   }

   Label* SetYLoc(string yloc)
   {
      _yloc = yloc;
      return &this;
   }
   static void SetYLoc(Label* label, string yloc)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetYLoc(yloc);
   }
   
   static void SetColor(Label* label, uint clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetColor(clr);
   }
   
   Label* SetColor(uint clr)
   {
      _color = clr;
      return &this;
   }
   
   static void SetTextColor(Label* label, uint clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextColor(clr);
   }
   Label* SetTextColor(uint clr)
   {
      _textColor = clr;
      return &this;
   }
   
   static void SetStyle(Label* label, string style)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetStyle(style);
   }
   Label* SetStyle(string style)
   {
      _style = style;
      return &this;
   }
   
   static void SetText(Label* label, string text)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetText(text);
   }
   Label* SetText(string text)
   {
      _text = text;
      StringReplace(_text, "\n", " ");
      if (_text == "")
      {
         _font = "Wingdings";
      }
      else
      {
         _font = "Arial";
      }
      return &this;
   }
   
   static void SetTextAlign(Label* label, string textAlign)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextAlign(textAlign);
   }
   Label* SetTextAlign(string textAlign)
   {
      _textAlign = textAlign;
      return &this;
   }

   void Redraw()
   {
      string usedText = _text;
      if (usedText == "")
      {
         if (_style == "up")
         {
            usedText = "\217";
         }
         else if (_style == "down")
         {
            usedText = "\218";
         }
         else if (_style == "diamond")
         {
            usedText = "\116";
         }
      }
      ResetLastError();
      int pos = iBars(_Symbol, _timeframe) - _x - 1;
      datetime x = iTime(_Symbol, _timeframe, pos);
      double y = getY(pos);
      
      if (ObjectFind(0, _labelId) == -1 
         && ObjectCreate(0, _labelId, OBJ_TEXT, _window, x, y))
      {
         ObjectSetString(0, _labelId, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, _labelId, OBJPROP_FONTSIZE, getFontSize());
         ObjectSetInteger(0, _labelId, OBJPROP_COLOR, _textColor);
         ObjectSetInteger(0, _labelId, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE1, y);
      ObjectSetString(0, _labelId, OBJPROP_TEXT, usedText);
   }
private:
   int GetAnchor()
   {
      if (_yloc == "abovebar")
      {
         return ANCHOR_LOWER;
      }
      if (_yloc == "belowbar")
      {
         return ANCHOR_UPPER;
      }
      return ANCHOR_CENTER;
   }
   int getFontSize()
   {
      if (_size == "tiny")
      {
         return 8;
      }
      if (_size == "small")
      {
         return 10;
      }
      if (_size == "large")
      {
         return 14;
      }
      if (_size == "huge")
      {
         return 16;
      }
      return 12;
   }
   double getY(int pos)
   {
      if (_yloc == "abovebar")
      {
         return iHigh(_Symbol, _timeframe, pos);
      }
      if (_yloc == "belowbar")
      {
         return iLow(_Symbol, _timeframe, pos);
      }
      return _y;
   }
};
#endif

class LabelsCollection
{
   string _id;
   Label* _labels[];
   static LabelsCollection* _collections[];
   static LabelsCollection* _all;
   static int _maxLabels;
public:
   LabelsCollection(string id)
   {
      _id = id;
   }
   
   ~LabelsCollection()
   {
      ClearLabels();
   }
   
   void ClearLabels()
   {
      for (int i = 0; i < ArraySize(_labels); ++i)
      {
         if (_labels[i] != NULL)
         {
            _labels[i].Release();
         }
      }
      ArrayResize(_labels, 0);
   }
   
   string GetId()
   {
      return _id;
   }
   
   int Count()
   {
      return ArraySize(_labels);
   }
   
   Label* GetFirst()
   {
      return _labels[0];
   }
   
   Label* Get(int index)
   {
      int size = ArraySize(_labels);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _labels[index];
   }
   Label* GetByIndex(int index)
   {
      int size = ArraySize(_labels);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _labels[size - 1 - index];
   }

   static Label* Get(Label* label, int index)
   {
      if (label == NULL)
      {
         return NULL;
      }
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }
   
   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new LabelsCollection("");
      }
      else
      {
         _all.ClearLabels();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(Label* label)
   {
      if (label == NULL)
      {
         return;
      }
      _all.RemoveLabel(label);
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteLabel(label);
   }

   static Label* Create(string id, int x, double y, datetime dateId, bool globalLabel = false)
   {
      if (_all == NULL)
      {
         Clear();
      }
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x - 1);
      string labelId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      Label* label = new Label(x, y, labelId, id, WindowOnDropped(), globalLabel);
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      _all.Add(label);
      int allLabelsCount = _all.Count();
      if (allLabelsCount > _maxLabels)
      {
         for (int i = 0; i < allLabelsCount; ++i)
         {
            Label* labelToDelete = _all.Get(i);
            if (!labelToDelete.IsGlobal() && labelToDelete != label)
            {
               Delete(labelToDelete);
               break;
            }
         }
      }
      return label;
   }

   static void SetMaxLabels(int max)
   {
      _maxLabels = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLabels();
      }
   }
private:
   int FindIndex(Label* label)
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         if (_labels[i] == label)
         {
            return i;
         }
      }
      return -1;
   }
   void RemoveLabel(Label* label)
   {
      int index = FindIndex(label);
      if (index == -1)
      {
         return;
      }
      int size = ArraySize(_labels);
      for (int i = index + 1; i < size; ++i)
      {
         _labels[i - 1] = _labels[i];
      }
      ArrayResize(_labels, size - 1);
      label.Release();
   }
   void DeleteLabel(Label* label)
   {
      RemoveLabel(label);
      label.Release();
   }
   void Add(Label* label)
   {
      int index = FindIndex(label);
      
      int size = ArraySize(_labels);
      ArrayResize(_labels, size + 1);
      _labels[size] = label;
      if (label != NULL)
      {
         label.AddRef();
      }
   }

   void RedrawLabels()
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         _labels[i].Redraw();
      }
   }

   static void AddCollection(LabelsCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LabelsCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
LabelsCollection* LabelsCollection::_collections[];
LabelsCollection* LabelsCollection::_all;
int LabelsCollection::_maxLabels = 50;
#endif

class LabelArray : public CustomTypeArray<Label*>
{
public:
   LabelArray(int size, Label* defaultValue) : CustomTypeArray(size, defaultValue)
   {
   }

protected:
   virtual Label* Clone(Label* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Label* clone = LabelsCollection::Create(item.GetId() + index, item.GetX(), item.GetY(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Label* item)
   {
      LabelsCollection::Delete(item);
   }
};
#endif
// Int array v2.0


class IntArray : public SimpleTypeArray<int>
{
public:
   IntArray(int size, double defaultValue)
      :SimpleTypeArray(size, defaultValue, INT_MIN)
   {
   }
};
// Bool array v1.0


class BoolArray : public IBoolArray
{
   int _array[];
   int _defaultSize;
   int _defaultValue;
public:
   BoolArray(int size, int defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IBoolArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   IBoolArray* Push(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   int Pop()
   {
      int size = ArraySize(_array);
      int value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   int Shift()
   {
      return Remove(0);
   }

   int Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, int value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   IBoolArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   int Remove(int index)
   {
      int size = ArraySize(_array);
      int value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(int value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
};
// Float array v1.3


class FloatArray : public SimpleTypeArray<double>
{
public:
   FloatArray(int size, double defaultValue)
      :SimpleTypeArray(size, defaultValue, EMPTY_VALUE)
   {
   }
};
#ifndef BoxArray_IMPL
#define BoxArray_IMPL
// Box array v2.0

// Collection of boxes v1.4

#ifndef BoxesCollection_IMPL
#define BoxesCollection_IMPL

#ifndef Box_IMPL
#define Box_IMPL

// Box object v1.6

class Box
{
   string _id;
   string _collectionId;
   int _left;
   double _top;
   int _right;
   double _bottom;
   int _window;
   color _bgcolor;
   color _borderColor;
   ENUM_TIMEFRAMES _timeframe;
   string _extend;

   string _text;
   string _textHAlign;
   string _textVAlign;
   string _textSize;
   color _textColor;
   bool global;

   int _refs;
public:
   Box(int left, double top, int right, double bottom, string id, string collectionId, int window, bool global = false)
   {
      _refs = 1;
      _textColor = White;
      _left = left;
      _right = right;
      _top = top;
      _bottom = bottom;
      _id = id;
      _collectionId = collectionId;
      _window = window;
      _extend = "none";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      this.global = global;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   void CopyTo(Box* target)
   {
      target.SetLeft(_left);
      target.SetTop(_top);
      target.SetRight(_right);
      target.SetBottom(_bottom);
      target.SetBgColor(_bgcolor);
      target.SetBorderColor(_borderColor);
      target.SetExtend(_extend);
      target.SetText(_text);
      target.SetTextHAlign(_textHAlign);
      target.SetTextVAlign(_textVAlign);
      target.SetTextSize(_textSize);
      target.SetTextColor(_textColor);
   }
   bool IsGlobal()
   {
      return global;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   static Box* Copy(Box* box) { if (box == NULL) { return NULL; } return box.Copy(); }
   Box* Copy()
   {
      Box* copy = new Box(_left, _top, _right, _bottom, _id, _collectionId, _window);
      copy.SetBgColor(_bgcolor);
      copy.SetBorderColor(_borderColor);
      copy.SetExtend(_extend);
      copy.SetText(_text);
      copy.SetTextHAlign(_textHAlign);
      copy.SetTextVAlign(_textVAlign);
      copy.SetTextSize(_textSize);
      copy.SetTextColor(_textColor);
      return copy;
   }

   static double GetTop(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetTop(); }
   double GetTop() { return _top; }
   static double GetBottom(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetBottom(); }
   double GetBottom() { return _bottom; }
   static int GetLeft(Box* box) { if (box == NULL) { return INT_MIN; } return box.GetLeft(); }
   int GetLeft() { return _left; }
   static int GetRight(Box* box) { if (box == NULL) { return INT_MIN; } return box.GetRight(); }
   int GetRight() { return _right; }

   static void SetTop(Box* box, double value) { if (box == NULL) { return; } box.SetTop(value); }
   void SetTop(double value) { _top = value; }
   static void SetBottom(Box* box, double value) { if (box == NULL) { return; } box.SetBottom(value); }
   void SetBottom(double value) { _bottom = value; }
   static void SetLeft(Box* box, int value) { if (box == NULL) { return; } box.SetLeft(value); }
   void SetLeft(int value) { _left = value; }
   static void SetRight(Box* box, int value) { if (box == NULL) { return; } box.SetRight(value); }
   void SetRight(int value) { _right = value; }
   static void SetLeftTop(Box* box, double top, int left) { if (box == NULL) { return; } box.SetTop(top); box.SetLeft(left); }
   static void SetRightBottom(Box* box, double bottom, int right) { if (box == NULL) { return; } box.SetRight(right); box.SetBottom(bottom); }

   static void SetBgColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBgColor(clr); }
   Box* SetBgColor(color clr) { _bgcolor = clr; return &this; }
   static void SetBorderColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBorderColor(clr); }
   Box* SetBorderColor(color clr) { _borderColor = clr; return &this; }
   static void SetExtend(Box* box, string extend) { if (box == NULL) { return; } box.SetExtend(extend); }
   Box* SetExtend(string extend) { _extend = extend; return &this; }

   static void SetText(Box* box, string text) { if (box == NULL) { return; } box.SetText(text); }
   Box* SetText(string text) { _text = text; return &this; }
   static void SetTextHAlign(Box* box, string halign) { if (box == NULL) { return; } box.SetTextHAlign(halign); }
   Box* SetTextHAlign(string halign) { _textHAlign = halign; return &this; }
   static void SetTextVAlign(Box* box, string valign) { if (box == NULL) { return; } box.SetTextVAlign(valign); }
   Box* SetTextVAlign(string valign) { _textVAlign = valign; return &this; }
   static void SetTextSize(Box* box, string size) { if (box == NULL) { return; } box.SetTextSize(size); }
   Box* SetTextSize(string size) { _textSize = size; return &this; }
   static void SetTextColor(Box* box, color clr) { if (box == NULL) { return; } box.SetTextColor(clr); }
   Box* SetTextColor(color clr) { _textColor = clr; return &this; }

   void Redraw()
   {
      int pos1 = 0;
      if (_extend == "left" || _extend == "both")
      {
         pos1 = iBars(_Symbol, _timeframe) - 1;
      }
      else
      {
         pos1 = iBars(_Symbol, _timeframe) - _left - 1;
      }
      datetime left = iTime(_Symbol, _timeframe, MathMax(0, pos1));
      int pos2 = 0;
      if (_extend == "right" || _extend == "both")
      {
         pos2 = 0;
      }
      else
      {
         pos2 = iBars(_Symbol, _timeframe) - _right - 1;
      }
      datetime right = iTime(_Symbol, _timeframe, MathMax(0, pos2));
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_RECTANGLE, _window, left, _top, right, _bottom))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _bgcolor);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, 1);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _top);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _bottom);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, left);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, right);
   }
};

#endif


class BoxObjectDestructor : public IObjectDestructor<Box*>
{
public:
   virtual void Free(Box* obj)
   {
      BoxesCollection::Delete(obj);
   }
};

class BoxesCollection
{
   string _id;
   Box* _array[];
   static BoxesCollection* _collections[];
   static BoxesCollection* _all;
   static int _max;
   static IObjectDestructor<Box*>* _destructor;
public:
   BoxesCollection(string id)
   {
      _id = id;
   }

   ~BoxesCollection()
   {
      ClearItems();
   }
   
   static IObjectDestructor<Box*>* GetDestructor()
   {
      return _destructor;
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   string GetId()
   {
      return _id;
   }

   int Count()
   {
      return ArraySize(_array);
   }

   Box* GetFirst()
   {
      return _array[0];
   }

   Box* Get(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[index];
   }
   Box* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }

   static Box* Get(Box* box, int index)
   {
      if (box == NULL)
      {
         return NULL;
      }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new BoxesCollection("");
      }
      else
      {
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(Box* box)
   {
      if (box == NULL)
      {
         return;
      }
      _all.DeleteItem(box);
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(box);
   }

   static Box* Create(string id, int left, double top, int right, double bottom, datetime dateId, bool global = false)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - left - 1);
      string boxId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Box* box = new Box(left, top, right, bottom, boxId, id, WindowOnDropped(), global);
      BoxesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new BoxesCollection(id);
         AddCollection(collection);
      }
      collection.Add(box);
      _all.Add(box);
      box.Release();
      int allCount = _all.Count();
      if (allCount > _max)
      {
         for (int i = 0; i < allCount; ++i)
         {
            Box* toDelete = _all.Get(i);
            if (!toDelete.IsGlobal() && toDelete != box)
            {
               Delete(toDelete);
               break;
            }
         }
      }
      return box;
   }
   
   static void SetMaxBoxes(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawBoxs();
      }
   }
private:
   int FindIndex(Box* box)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == box)
         {
            return i;
         }
      }
      return -1;
   }

   void DeleteItem(Box* box)
   {
      int index = FindIndex(box);
      if (index == -1)
      {
         return;
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      box.Release();
   }
   
   void Add(Box* box)
   {
      int index = FindIndex(box);
      
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = box;
      box.AddRef();
   }

   void RedrawBoxs()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(BoxesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static BoxesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
BoxesCollection* BoxesCollection::_collections[];
BoxesCollection* BoxesCollection::_all;
IObjectDestructor<Box*>* BoxesCollection::_destructor = new BoxObjectDestructor();
int BoxesCollection::_max = 50;
#endif

class BoxArray : public CustomTypeArray<Box*>
{
public:
   BoxArray(int size, Box* defaultValue) : CustomTypeArray(size, defaultValue)
   {
   }

protected:
   virtual Box* Clone(Box* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Box* clone = BoxesCollection::Create(item.GetId() + index, item.GetLeft(), item.GetTop(), item.GetRight(), item.GetBottom(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Box* item)
   {
      BoxesCollection::Delete(item);
   }
};
#endif
// String array v1.0
// string array interface v1.0

class IStringArray
{
public:
   virtual void Unshift(string value) = 0;
   virtual int Size() = 0;
   virtual IStringArray* Push(string value) = 0;
   virtual string Pop() = 0;
   virtual string Get(int index) = 0;
   virtual void Set(int index, string value) = 0;
   virtual IStringArray* Slice(int from, int to) = 0;
   virtual IStringArray* Clear() = 0;
   virtual string Shift() = 0;
   virtual string Remove(int index) = 0;
   virtual int Includes(string value) = 0;
};

class StringArray : public IStringArray
{
   string _array[];
   int _defaultSize;
   string _defaultValue;
public:
   StringArray(int size, string defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IStringArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(string value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   IStringArray* Push(string value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   string Pop()
   {
      int size = ArraySize(_array);
      string value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   string Shift()
   {
      return Remove(0);
   }

   string Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, string value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   IStringArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   string Remove(int index)
   {
      int size = ArraySize(_array);
      string value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(string value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
};
// Color array v1.0
// Color array interface v1.0

class IColorArray
{
public:
   virtual void Unshift(uint value) = 0;
   virtual int Size() = 0;
   virtual IColorArray* Push(uint value) = 0;
   virtual uint Pop() = 0;
   virtual uint Get(int index) = 0;
   virtual void Set(int index, uint value) = 0;
   virtual IColorArray* Slice(int from, int to) = 0;
   virtual IColorArray* Clear() = 0;
   virtual uint Shift() = 0;
   virtual uint Remove(int index) = 0;
   virtual int Includes(uint value) = 0;
};

class ColorArray : public IColorArray
{
   uint _array[];
   int _defaultSize;
   uint _defaultValue;
public:
   ColorArray(int size, uint defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IColorArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(uint value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   IColorArray* Push(uint value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   uint Pop()
   {
      int size = ArraySize(_array);
      uint value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   uint Shift()
   {
      return Remove(0);
   }

   uint Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, uint value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   IColorArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   uint Remove(int index)
   {
      int size = ArraySize(_array);
      uint value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(uint value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
};



class Array
{
public:
   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Unshift(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Unshift(value); }
   
   static double Avg(ISimpleTypeArray<double>* array)
   {
      if (array == NULL || array.Size() == 0)
      {
         return EMPTY_VALUE;
      }
      return Sum(array) / array.Size();
   }
   static double Avg(ISimpleTypeArray<int>* array)
   {
      if (array == NULL || array.Size() == 0)
      {
         return EMPTY_VALUE;
      }
      return Sum(array) / array.Size();
   }
   static double Sum(ISimpleTypeArray<double>* array)
   {
      if (array == NULL || array.Size() == 0)
      {
         return EMPTY_VALUE;
      }
      double sum = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   static int Sum(ISimpleTypeArray<int>* array)
   {
      if (array == NULL || array.Size() == 0)
      {
         return INT_MIN;
      }
      int sum = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   
   static double Min(ISimpleTypeArray<double>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return EMPTY_VALUE;
      }
      double minVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double val = array.Get(i);
         if (minVal > val)
         {
            minVal = val;
         }
      }
      return minVal;
   }
   static int Min(ISimpleTypeArray<int>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return INT_MIN;
      }
      int minVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int val = array.Get(i);
         if (minVal > val)
         {
            minVal = val;
         }
      }
      return minVal;
   }
   static double Max(ISimpleTypeArray<double>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return EMPTY_VALUE;
      }
      double maxVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double val = array.Get(i);
         if (maxVal < val)
         {
            maxVal = val;
         }
      }
      return maxVal;
   }
   static int Max(ISimpleTypeArray<int>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return INT_MIN;
      }
      int maxVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int val = array.Get(i);
         if (maxVal < val)
         {
            maxVal = val;
         }
      }
      return maxVal;
   }
   template <typename DUMMY_TYPE, typename ARRAY_TYPE>
   static int Size(ARRAY_TYPE array, int defaultValue) { if (array == NULL) { return INT_MIN;} return array.Size(); }

   template <typename ARRAY_TYPE>
   static void Clear(ARRAY_TYPE array) { if (array == NULL) { return;} array.Clear(); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Shift(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Shift(); }

   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Push(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Push(value); }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE First(ARRAY_TYPE array, VALUE_TYPE defaultValue)
   {
      if (array == NULL || array.Size() == 0) { return defaultValue; } 
      return array.Get(0);
   }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Last(ARRAY_TYPE array, VALUE_TYPE defaultValue)
   {
      if (array == NULL || array.Size() == 0) { return defaultValue; } 
      return array.Get(array.Size() - 1);
   }
   
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Pop(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Pop(); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Get(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Get(index); }
   
   template <typename ARRAY_TYPE, typename DUMMY_TYPE, typename VALUE_TYPE>
   static void Set(ARRAY_TYPE array, int index, VALUE_TYPE value) { if (array == NULL) { return; } array.Set(index, value); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Remove(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Remove(index); }
   
   static int Includes(ITArray<int>* array, int value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(ILineArray* array, Line* value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(ITArray<Box*>* array, Box* value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IStringArray* array, string value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IBoolArray* array, int value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IColorArray* array, uint value) { if (array == NULL) { return -1; } return array.Includes(value); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static ARRAY_TYPE PercentRank(ISimpleTypeArray<ARRAY_TYPE>* array) { if (array == NULL) { return -1; } return array.PercentRank(index); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static ARRAY_TYPE Stdev(ISimpleTypeArray<ARRAY_TYPE>* array) { if (array == NULL) { return -1; } return array.Stdev(); }
   
   static string Join(IStringArray* array, string concat)
   {
      string res = "";
      for (int i = 0; i < array.Size(); ++i)
      {
         string val = array.Get(i);
         if (val == NULL)
         {
            continue;
         }
         if (i > 0)
         {
            res += concat;
         }
         res += array.Get(i);
      }
      return res;
   }
};



// Pine-script like safe operations
// v.1.2

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
double SafePlus(int left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
string SafePlus(string left, string right)
{
   if (left == NULL || right == NULL)
   {
      return NULL;
   }
   return left + right;
}

double SafeMinus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left - right;
}

double SafeDivide(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0)
   {
      return EMPTY_VALUE;
   }
   return left / right;
}

double SafeMultiply(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left * right;
}

bool SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left <= right;
}

double SafeMathExp(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathExp(value);
}

double SafeMathMax(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(left, right);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathPow(double value, double power)
{
   if (value == EMPTY_VALUE || power == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathPow(value, power);
}

double SafeMathAbs(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathAbs(value);
}

double SafeMathRound(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathRound(value);
}

double SafeMathRound(double value, int precision)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return NormalizeDouble(value, precision);
}

double SafeMathSqrt(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSqrt(value);
}

int SafeSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

double SafeLog(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog(value);
}
double SafeLog10(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog10(value);
}
double SafeCos(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathCos(value);
}
double SafeArccos(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArccos(value);
}
double SafeSin(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSin(value);
}
double SafeArcsin(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArcsin(value);
}
double SafeTan(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathTan(value);
}
double SafeArctan(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArctan(value);
}
double InvertSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return -value;
}
double SafeMathFloor(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathFloor(value);
}
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return MathCeil(value);
}

// Table v1.1
// Interface for a cell v2.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw(int x, int y) = 0;
   virtual void HandleButtonClicks() = 0;
   virtual void Measure(int& width, int& height) = 0;
};

#endif
//Row size v1.0

class RowSize
{
   int _widths[];
   int _maxHeight;
public:
   void Add(int index, int width, int height)
   {
      int size = ArraySize(_widths);
      if (size <= index)
      {
         ArrayResize(_widths, index + 1);
      }
      _maxHeight = MathMax(_maxHeight, height);
      _widths[index] = MathMax(_widths[index], width);
   }

   int GetWidth(int index)
   {
      return _widths[index];
   }

   int GetMaxHeight()
   {
      return _maxHeight;
   }
};

// Row v2.2

#ifndef Row_IMP
#define Row_IMP

class Row
{
   ICell *_cells[];
public:
   ~Row() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         delete _cells[i]; 
      } 
   }

   void Measure(RowSize* rowSizes)
   {
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         int w, h;
         _cells[i].Measure(w, h);
         rowSizes.Add(i, w + 5, h + 5);
      } 
   }
   
   int GetColumnsCount()
   {
      return ArraySize(_cells);
   }

   void Draw(int x, int y, RowSize* rowSizes) 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].Draw(x, y);
         x += rowSizes.GetWidth(i);
      } 
   }

   void HandleButtonClicks() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].HandleButtonClicks(); 
      } 
   }
   
   ICell* GetCell(int index)
   {
      if (index < 0)
      {
         return NULL;
      }
      int count = ArraySize(_cells);
      if (index >= count)
      {
         return NULL;
      }
      return _cells[index];
   }

   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};


#endif


// Grid v2.1

#ifndef Grid_IMP
#define Grid_IMP

class Grid
{
   Row *_rows[];
public:
   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   Row *AddRow()
   {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
   }
   
   Row *GetRow(const int index)
   {
      return _rows[index];
   }
   
   int GetRowsCount()
   {
      return ArraySize(_rows);
   }
   
   void Draw(int x, int y)
   {
      RowSize* widths = MeasureColumns();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         int w, h;
         _rows[i].Draw(x, y, widths);
         y += widths.GetMaxHeight();
      }
      delete widths;
   }

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
      }
   }
private:
   RowSize* MeasureColumns()
   {
      RowSize* widths = new RowSize();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Measure(widths);
      }
      return widths;
   }
};

#endif


// ACell v1.1

class ACell : public ICell
{
protected:
   void Measure(string text, string font, int fontSize, int& width, int& height)
   {
      TextSetFont(font, -fontSize * 10);
      TextGetSize(text, width, height);
   }
   void ObjectMakeLabel(string nm, int xoff, int yoff, string text, color LabelColor, int LabelCorner, int Window, string Font, int FSize)
   { 
      ObjectDelete(nm); 
      ObjectCreate(nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSet(nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSet(nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSet(nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSet(nm, OBJPROP_BACK, false); 
      ObjectSetText(nm, text, FSize, Font, LabelColor);
   }
};

// Label cell v4.0

#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ACell
{
   string _id;
   string _text; 
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   uint _color;
   int _windowNumber;
   string _textHAlign;
   bool _withBackground;
   uint _bgColor;
   int _width;
   int _height;
   int _linesHeights[];
   int _linesWidths[];
public:
   LabelCell(const string id, const string text, ENUM_BASE_CORNER corner, int fontSize, uint clr, int windowNumber)
   { 
      _withBackground = false;
      _textHAlign = "cental";
      _corner = corner;
      _id = id; 
      _text = text;
      _fontSize = fontSize;
      _color = clr;
      _windowNumber = windowNumber;
   }

   virtual void Measure(int& width, int& height)
   {
      _width = 0;
      _height = 0;
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      ArrayResize(_linesHeights, linesCount);
      ArrayResize(_linesWidths, linesCount);
      for (int i = 0; i < linesCount; ++i)
      {
         int w, h;
         Measure(lines[i], "Arial", _fontSize, w, h);
         _height += h;
         _width = MathMax(_width, w);
         _linesHeights[i] = h;
         _linesWidths[i] = w;
      }
      width = _width;
      height = _height;
   }

   virtual void Draw(int x, int y) 
   {
      if (_withBackground)
      {
         ObjectCreate(_id + "rect", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, _id + "rect", OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YDISTANCE, y);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BGCOLOR, _bgColor); 
         ObjectSetInteger(0, _id + "rect", OBJPROP_XSIZE, _width);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YSIZE, _height);
         ObjectSetInteger(0, _id + "rect", OBJPROP_COLOR, _color);
         ObjectSetInteger(0, _id + "rect", OBJPROP_CORNER, _corner);
      }
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      for (int i = 0; i < linesCount; ++i)
      {
         int lineX = x;
         if (_textHAlign == "center")
         {
            lineX += (_width - _linesWidths[i]) / 2;
         }
         else if (_textHAlign == "right")
         {
            lineX += _width - _linesWidths[i];
         }
         ObjectMakeLabel(_id + "line" + i, lineX, y, lines[i], _color, _corner, _windowNumber, "Arial", _fontSize); 
         y += _linesHeights[i];
      }
   }
   
   bool SetBgColor(uint clr)
   {
      if (_bgColor == clr)
      {
         return false;
      }
      _bgColor = clr;
      _withBackground = true;
      return true;
   }

   virtual void HandleButtonClicks()
   {
      
   }
   
   bool SetColor(uint clr)
   {
      if (_color == clr)
      {
         return false;
      }
      _color = clr;
      return true;
   }
   
   bool SetText(string text)
   {
      if (_text == text)
      {
         return false;
      }
      _text = text;
      return true;
   }
   
   bool SetFontSize(int fontSize)
   {
      if (_fontSize == fontSize)
      {
         return false;
      }
      _fontSize = fontSize;
      return true;
   }
   
   bool SetTextHAlign(string textHAlign)
   {
      if (_textHAlign == textHAlign)
      {
         return false;
      }
      _textHAlign = textHAlign;
      return true;
   }
};

#endif

class Table;
class TableManager
{
   static Table* tables[];
public:
   static void Clear(bool forced = false);
   static void Add(Table* table);
   static void Redraw();
   static Table* Create(string prefix, string tableIndex, string position, int columns, int rows);
};

Table* TableManager::Create(string prefix, string tableIndex, string position, int columns, int rows)
{
   string id = prefix + "_" + tableIndex;
   int tablesCount = ArraySize(tables);
   for (int i = 0; i < tablesCount; ++i)
   {
      if (tables[i].GetId() == id)
      {
         return tables[i];
      }
   }
   return new Table(id, position, columns, rows);
}

Table* TableManager::tables[];
void TableManager::Clear(bool forced = false)
{
   int movedIndex = 0;
   for (int i = 0; i < ArraySize(TableManager::tables); ++i)
   {
      if (!tables[i].IsLocked())
      {
         delete tables[i];
      }
      else
      {
         tables[movedIndex] = tables[i];
         ++movedIndex;
      }
   }
   ArrayResize(tables, movedIndex);
}

void TableManager::Add(Table* table)
{
   int size = ArraySize(tables);
   ArrayResize(tables, size + 1);
   tables[size] = table;
}

void TableManager::Redraw()
{
   for (int i = 0; i < ArraySize(tables); ++i)
   {
      tables[i].Redraw();
   }
}

enum TablePosition
{
   TablePositionTopLeft,
   TablePositionTopCenter,
   TablePositionTopRight,
   TablePositionMiddleLeft,
   TablePositionMiddleCenter,
   TablePositionMiddleRight,
   TablePositionBottomLeft,
   TablePositionBottomCenter,
   TablePositionBottomRight
};

TablePosition TablePositionFromString(string value)
{
   if (value == "top_left") return TablePositionTopLeft;
   if (value == "top_center") return TablePositionTopCenter;
   if (value == "top_right") return TablePositionTopRight;
   if (value == "middle_left") return TablePositionMiddleLeft;
   if (value == "middle_center") return TablePositionMiddleCenter;
   if (value == "middle_right") return TablePositionMiddleRight;
   if (value == "bottom_left") return TablePositionBottomLeft;
   if (value == "bottom_center") return TablePositionBottomCenter;
   if (value == "bottom_right") return TablePositionBottomRight;
   return TablePositionMiddleCenter;
}

class Table
{
   string _prefix;
   TablePosition _position;
   int _columns;
   int _rows;

   int _borderWidth;
   uint _borderColor;
   
   int _frameWidth;
   uint _frameColor;
   Grid* _grid;
   bool locked;
public:
   Table(string prefix, string position, int columns, int rows)
   {
      locked = false;
      if (columns == EMPTY_VALUE)
      {
         columns = 0;
      }
      if (rows == EMPTY_VALUE)
      {
         rows = 0;
      }
      _prefix = prefix;
      _position = TablePositionFromString(position);
      _columns = columns;
      _rows = rows;
      _borderWidth = 0;
      _frameWidth = 0;
      _grid = new Grid();
      for (int i = 0; i < rows; ++i)
      {
         Row* row = _grid.AddRow();
         for (int j = 0; j < columns; ++j)
         {
            string id = _prefix + "_cell_" + IntegerToString(i) + "_" + IntegerToString(j);
            row.Add(new LabelCell(id, "", CORNER_LEFT_UPPER, 10, Red, 0));
         }
      }
      Redraw();
      TableManager::Add(&this);
   }
   ~Table()
   {
      delete _grid;
   }
   
   void Lock()
   {
      locked = true;
   }
   void Unlock()
   {
      locked = false;
   }
   bool IsLocked()
   {
      return locked;
   }
   
   string GetId()
   {
      return _prefix;
   }

   Table* SetBorderColor(uint clr)
   {
      _borderColor = clr;
      return &this;
   }
   Table* SetBorderWidth(int borderWidth)
   {
      _borderWidth = borderWidth;
      return &this;
   }
   Table* SetBGColor(uint clr)
   {
      for (int row = 0; row < _grid.GetRowsCount(); ++row)
      {
         Row* gridRow = _grid.GetRow(row);
         for (int column = 0; column < gridRow.GetColumnsCount(); ++column)
         {
            LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
            cell.SetBgColor(clr);
         }
      }
      return &this;
   }
   
   Table* SetFrameColor(uint clr)
   {
      _frameColor = clr;
      return &this;
   }
   Table* SetFrameWidth(int frameWidth)
   {
      _frameWidth = frameWidth;
      return &this;
   }
   static void CellText(Table* table, int column, int row, string text)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellText(column, row, text);
   }
   void CellText(int column, int row, string text)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetText(text))
      {
         Redraw();
      }
   }
   static void CellTextColor(Table* table, int column, int row, uint clr)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextColor(column, row, clr);
   }
   void CellTextColor(int column, int row, uint clr)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetColor(clr))
      {
      }
   }
   static void CellTextSize(Table* table, int column, int row, string size)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextSize(column, row, size);
   }
   void CellTextSize(int column, int row, string size)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetFontSize(GetFontSize(size)))
      {
      }
   }
   
   static void CellBGColor(Table* table, int column, int row, uint clr)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellBGColor(column, row, clr);
   }
   void CellBGColor(int column, int row, uint clr)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      cell.SetBgColor(clr);
   }
   
   static void CellTextHAlign(Table* table, int column, int row, string halign)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextHAlign(column, row, halign);
   }
   void CellTextHAlign(int column, int row, string halign)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetTextHAlign(halign))
      {
      }
   }
   
   void Redraw()
   {
      int x = 0;
      int y = 0;
      switch (_position)
      {
         case TablePositionTopLeft:
            break;
         case TablePositionTopCenter:
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionTopRight:
            x = GetScreenWidth() - GetGridWidth();
            break;
         case TablePositionMiddleLeft:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            break;
         case TablePositionMiddleCenter:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionMiddleRight:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            x = GetScreenWidth() - GetGridWidth();
            break;
         case TablePositionBottomLeft:
            y = GetScreenHeight() - GetGridHeight();
            break;
         case TablePositionBottomCenter:
            y = GetScreenHeight() - GetGridHeight();
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionBottomRight:
            y = GetScreenHeight() - GetGridHeight();
            x = GetScreenWidth() - GetGridWidth();
            break;
      }
      _grid.Draw(x, y);
   }
private:
   int GetFontSize(string size)
   {
      if (size == "auto" || size == "normal")
      {
         return 10;
      }
      if (size == "tiny")
      {
         return 6;
      }
      if (size == "small")
      {
         return 8;
      }
      if (size == "large")
      {
         return 12;
      }
      if (size == "huge")
      {
         return 14;
      }
      return 10;
   }
   int GetScreenWidth()
   {
      return ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   }
   int GetGridWidth()
   {
      int width = 0;
      for (int i = 0; i < _rows; ++i)
      {
         RowSize* rowSizes = new RowSize();
         _grid.GetRow(i).Measure(rowSizes);
         int rowWidth = 0;
         for (int ii = 0; ii < _columns; ++ii)
         {
            rowWidth += rowSizes.GetWidth(ii);
         }
         delete rowSizes;
         width = MathMax(width, rowWidth);
      }
      return width;
   }
   int GetScreenHeight()
   {
      return ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   }
   int GetGridHeight()
   {
      int height = 0;
      for (int i = 0; i < _rows; ++i)
      {
         RowSize* rowSizes = new RowSize();
         _grid.GetRow(i).Measure(rowSizes);
         height = MathMax(height, rowSizes.GetMaxHeight());
         delete rowSizes;
      }
      return height;
   }
};

// str.* functions from Pine Script
// v1.1

class Str
{
public:
   static string ToString(int value, string format)
   {
      if (value == INT_MIN)
      {
         return "NaN";
      }
      if (format == "percent")
      {
         return IntegerToString(value, 2) + "%";
      }
      return IntegerToString(value);
   }
   static string ToString(double value, string format)
   {
      if (value == EMPTY_VALUE)
      {
         return "NaN";
      }
      if (format == "percent")
      {
         return DoubleToString(value, 2) + "%";
      }
      return DoubleToString(value);
   }
   static string ToString(double value)
   {
      if (value == EMPTY_VALUE)
      {
         return "NaN";
      }
      return DoubleToString(value);
   }
   static string ToString(int value)
   {
      if (value == INT_MIN)
      {
         return "NaN";
      }
      return IntegerToString(value);
   }
   static string ToString(string value)
   {
      return value;
   }
   static string ReplaceAll(string source, string target, string replaceWith)
   {
      StringReplace(source, target, replaceWith);
      return source;
   }
   static bool Contains(string source, string str)
   {
      return StringFind(source, str) >= 0;
   }
   static int Length(string str)
   {
      return StringLen(str);
   }
};

enum StrFormatValueType
{
   String,
   Integer,
   Float
};
interface IStrFormatValue
{
public:
   virtual StrFormatValueType GetType() = 0;
};
class StrFormatStringValue : public IStrFormatValue
{
   string value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::String;
   }
   
   void SetValue(string val)
   {
      value = val;
   }
   string GetValue()
   {
      return value;
   }
};
class StrFormatIntValue : public IStrFormatValue
{
   int value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Integer;
   }
   
   void SetValue(int val)
   {
      value = val;
   }
   int GetValue()
   {
      return value;
   }
};
class StrFormatDoubleValue : public IStrFormatValue
{
   double value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Float;
   }
   
   void SetValue(double val)
   {
      value = val;
   }
   double GetValue()
   {
      return value;
   }
};
class StrFormat
{
   string format;
   IStrFormatValue* values[];
   int nextValueIndex;
public:
   StrFormat(string format)
   {
      this.format = format;
      nextValueIndex = 0;
   }
   ~StrFormat()
   {
      int size = ArraySize(values);
      for (int i = 0; i < size; ++i)
      {
         delete values[i];
      }
   }
   
   StrFormat* Add(string value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatStringValue();
      }
      ((StrFormatStringValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(int value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatIntValue();
      }
      ((StrFormatIntValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(double value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatDoubleValue();
      }
      ((StrFormatDoubleValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   
   string Format()
   {
      int size = ArraySize(values);
      string res = format;
      for (int i = 0; i < size; ++i)
      {
         int pos = StringFind(res, "{" + IntegerToString(i));
         if (pos < 0)
         {
            continue;
         }
         int end = StringFind(res, "}", pos + 1);
         if (end < 0)
         {
            continue;
         }
         switch (values[i].GetType())
         {
         case StrFormatValueType::String:
            {
               string strValue = ((StrFormatStringValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + strValue + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Integer:
            {
               int intValue = ((StrFormatIntValue*)values[i]).GetValue();
               string numberFormat = StringSubstr(res, pos + 1, end - pos - 1);
               
               res = StringSubstr(res, 0, pos) + FormatIntValue(intValue, numberFormat) + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Float:
            {
               double doubleValue = ((StrFormatDoubleValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + DoubleToString(doubleValue) + StringSubstr(res, end + 1);
            }
            break;
         }
      }
      nextValueIndex = 0;
      return res;
   }
private:
   string FormatIntValue(int intValue, string numberFormat)
   {
      string tokens[];
      int count = StringSplit(numberFormat, ',', tokens);
      if (count == 1 || tokens[1] != "number")
      {
          return IntegerToString(intValue);
      }
      int precision = GetPrecision(tokens[2]);
      if (precision == 0)
      {
         return IntegerToString(intValue);
      }
      return DoubleToString(intValue, precision);
   }
   
   int GetPrecision(string format)
   {
      int pointPos = StringFind(format, ".");
      if (pointPos < 0)
      {
         return -1;
      }
      return StringLen(format) - pointPos;
   }
};
#ifndef PriceType_IMPL
#define PriceType_IMPL
enum PriceType
{
   PriceClose = PRICE_CLOSE, // Close
   PriceOpen = PRICE_OPEN, // Open
   PriceHigh = PRICE_HIGH, // High
   PriceLow = PRICE_LOW, // Low
   PriceMedian = PRICE_MEDIAN, // Median
   PriceTypical = PRICE_TYPICAL, // Typical
   PriceWeighted = PRICE_WEIGHTED, // Weighted
   PriceMedianBody, // Median (body)
   PriceAverage, // Average
   PriceTrendBiased, // Trend biased
   PriceVolume, // Volume
};
#endif
#ifndef PriceStreamFactory_IMPL
#define PriceStreamFactory_IMPL

// price stream factory v2.0

// Stream base v2.0



#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public TIStream<double>
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }
};
#endif
// Instrument info v.1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int CompareLots(double lot1, double lot2)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
      }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   static double GetPipSize(const string symbol)
   { 
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double AddPips(const double rate, const double pips)
   {
      return RoundRate(rate + pips * _pipSize);
   }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return 0.0;
      }
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = GetMinLots();
      if (minVolume > lots)
      {
         return 0.0;
      }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         return maxVolume;
      }
      return lots;
   }

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }
};

#endif


// Abstract stream v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

class AStream : public TIStream<double>
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
   InstrumentInfo *_instrument;
   int _references;

   AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _references = 1;
      _shift = 0.0;
      _symbol = symbol;
      _timeframe = timeframe;
      _instrument = new InstrumentInfo(_symbol);
   }

   ~AStream()
   {
      delete _instrument;
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
#define AStream_IMP
#endif
// IBarStream v3.0



#ifndef IBarStream_IMP
#define IBarStream_IMP

interface IBarStream : public TIStream<double>
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual bool FindDatePeriod(const datetime date, int& period) = 0;

   virtual bool GetOpen(const int period, double &open) = 0;
   virtual bool GetHigh(const int period, double &high) = 0;
   virtual bool GetLow(const int period, double &low) = 0;
   virtual bool GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;
   virtual bool GetOpenClose(const int period, double &open, double &close) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual void Refresh() = 0;
};
#endif


// Price stream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

class PriceStream : public AStreamBase
{
   PriceType _price;
   IBarStream* _source;
public:
   PriceStream(IBarStream* source, const PriceType __price)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
      _price = __price;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            if (!_source.GetClose(period, val))
            {
               return false;
            }
            break;
         case PriceOpen:
            if (!_source.GetOpen(period, val))
            {
               return false;
            }
            break;
         case PriceHigh:
            if (!_source.GetHigh(period, val))
            {
               return false;
            }
            break;
         case PriceLow:
            if (!_source.GetLow(period, val))
            {
               return false;
            }
            break;
         case PriceMedian:
            {
               double high, low;
               if (!_source.GetHighLow(period, high, low))
               {
                  return false;
               }
               val = (high + low) / 2.0;
            }
            break;
         case PriceTypical:
            {
               double open1, high1, low1, close1;
               if (!_source.GetValues(period, open1, high1, low1, close1))
               {
                  return false;
               }
               val = (high1 + low1 + close1) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open2, high2, low2, close2;
               if (!_source.GetValues(period, open2, high2, low2, close2))
               {
                  return false;
               }
               val = (high2 + low2 + close2 * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         // case PriceVolume:
         //    if (!_source.GetVolume(period, val))
         //    {
         //       return false;
         //    }
         //    break;
      }
      return true;
   }
};


#endif
// Bar stream v2.1



#ifndef BarStream_IMP
#define BarStream_IMP

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _referenceCount;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _referenceCount = 1;
      _symbol = symbol;
      _timeframe = timeframe;
   }
   virtual void AddRef()
   {
      ++_referenceCount;
   }
   virtual void Release()
   {
      --_referenceCount;
      if (_referenceCount == 0)
         delete &this;
   }

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = iBarShift(_symbol, _timeframe, date);
      return true;
   }

   virtual bool GetValue(const int period, double &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      val = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      dt = iTime(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void Refresh() { }
};

#endif


class PriceStreamFactory
{
public:
   static TIStream<double>* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      TIStream<double>* stream = new PriceStream(source, price);
      source.Release();
      return stream;
   }
};
#endif
#ifndef FloatStream_IMPL
#define FloatStream_IMPL


// Float stream v3.0

class FloatStream : public TAStream<double>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
   double _emptyValue;
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe, double emptyValue = EMPTY_VALUE)
   {
      _emptyValue = emptyValue;
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, _emptyValue);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != _emptyValue;
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      int currentSize = ArrayRange(_stream, 0);
      if (currentSize != size) 
      {
         ArrayResize(_stream, size);
         for (int i = currentSize; i < size; ++i)
         {
            _stream[i] = _emptyValue;
         }
      }
   }
};

#endif


//Base implementation of stream based on another stream 
//v2.0

class AOnStream : public TIStream<double>
{
protected:
   TIStream<double> *_source;
   int _references;
public:
   AOnStream(TIStream<double> *source)
   {
      _references = 1;
      _source = source;
      if (_source != NULL)
      {
         _source.AddRef();
      }
   }

   ~AOnStream()
   {
      _source.Release();
   }
   
   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};

// SMA on stream v2.0
#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   SmaOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }
      
      if (period > totalBars - _length)
         return false;

      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - _length && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         double current;
         double last;
         if (!_source.GetValue(period, current) || !_source.GetValue(period + _length, last))
            return false;
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + (current - last) / _length;
      }
      else 
      {
         _buffer[bufferIndex] = EMPTY_VALUE; 
         double summ = 0;
         for(int i = 0; i < _length; i++) 
         {
            double current_;
            if (!_source.GetValue(period + i, current_))
               return false;

           summ += current_;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif


// True range stream v2.2

#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   bool GetValue(const int period, double &val)
   {
      int pos = Size() - period - 1;
      if (pos < 1)
      {
         if (_handleNa)
         {
            val = CalcFirst(pos);
            return true;
         }
         return false;
      }
      double h = iHigh(_symbol, _timeframe, period);
      double l = iLow(_symbol, _timeframe, period);
      double c1 = iClose(_symbol, _timeframe, period + 1);
      double hl = MathAbs(h - l);
      double hc = MathAbs(h - c1);
      double lc = MathAbs(l - c1);

      val = MathMax(lc, MathMax(hl, hc));
      return true;
   }
private:
   double CalcFirst(int pos)
   {
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));

      return MathMax(lc, MathMax(hl, hc));
   }
};
#endif




// Average true range stream v3.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   TIStream<double>* _avg;
public:
   ATRStream(int length)
      :AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
   {
      TIStream<double>* tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      TIStream<double>* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ~ATRStream()
   {
      _avg.Release();
   }

   bool GetValue(const int period, double &val)
   {
      return _avg.GetValue(period, val);
   }
};
#endif
// Value when stream (condition as a parameter) v1.0




class ValueWhenSimpleStream : public AStream
{
   datetime _periods[];
   double _values[];
   int _shift;
public:
   double _stream[];

   ValueWhenSimpleStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int shift)
      :AStream(symbol, timeframe)
   {
      _shift = shift;
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }

   double Update(const int period, datetime date, bool condition, double val)
   {
      if (condition)
      {
         int size = ArraySize(_periods);
         if (size == 0 || _periods[size - 1] != date)
         {
            ArrayResize(_periods, size + 1);
            ArrayResize(_values, size + 1);
            _values[size] = val;
            _periods[size] = date;
            ++size;
         }
         else
         {
            _values[size - 1] = val;
         }
         if (size > _shift)
         {
            _stream[period] = _values[size - 1 - _shift];
         }
      }
      else if (iBars(_symbol, _timeframe) - 1 > period)
      {
         _stream[period] = _stream[period + 1];
      }
      return _stream[period];
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};
// PlotShape v1.3
#ifndef PlotShape_IMPL
#define PlotShape_IMPL

class PlotShape
{
private:
   static void SetNA(double& plot[], int period)
   {
      plot[period] = EMPTY_VALUE;
   }
   
   static void SetValue(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift)
   {
      if (location == "abovebar" || location == "top")
      {
         plot[period] = high[period + shift];
         return;
      }
      if (location == "belowbar" || location == "bottom")
      {
         plot[period] = low[period + shift];
         return;
      }
      plot[period] = seriesValue;
   }
public:
   static void Set(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == EMPTY_VALUE || clr == INT_MAX)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void Set(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == INT_MIN || clr == INT_MAX)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void SetBool(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == -1 || seriesValue == 0 || clr == INT_MAX)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
};

#endif
//Signaler v3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   advanced_server          = "https://profitrobots.com"; // Advanced alert server url
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

enum SignalerFrequency
{
   SignalsAll,
   SignalsOncePerBarClose,
   SignalsOncePerBar
};

class Signaler
{
   string _prefix;
   SignalerFrequency _frequency;
   datetime _lastSignal;
public:
   Signaler(string frequency)
   {
      if (frequency == "all")
      {
         _frequency = SignalsAll;
      }
      else if (frequency == "once_per_bar_close")
      {
         _frequency = SignalsOncePerBarClose;
      }
      else if (frequency == "once_per_bar")
      {
         _frequency = SignalsOncePerBar;
      }
      _lastSignal = 0;
   }
   Signaler()
   {
      _lastSignal = 0;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void ShowAlert(string message, int position, datetime time)
   {
      if (position != 0)
      {
         return;
      }
      if (_frequency != SignalsAll)
      {
         if (_lastSignal == time)
         {
            return;
         }
      }
      _lastSignal = time;
      SendNotifications("", message);
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
   }
};



// EMA on stream v3.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public TIStream<double>
{
   TIStream<double>* _source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(TIStream<double>* source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
      _k = 2.0 / (_length + 1.0);
   }

   ~EMAOnStream()
   {
      _source.Release();
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
      {
         delete &this;
      }
   }
   
   virtual int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }
      
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current;
      _buffer[bufferIndex] = (1 - _k) * last + _k * current;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif



// Colored stream v4.1

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class IColoredStreamData
{
public:
   virtual void Init(double defaultValue) = 0;
   virtual int Register(int id) = 0;
   virtual double GetValue(int pos) = 0;
   virtual color GetColor() = 0;
   virtual void Set(int period, double value, double prevValue) = 0;
   virtual void Clear(int period) = 0;
};

class InternalStream
{
public:
   double _stream[];
};

class LineColoredStreamData : public IColoredStreamData
{
   double _stream[];
   color _color;
   string _label;
   int _lineType;
   ENUM_LINE_STYLE _lineStyle;
   int _width;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   InternalStream* _internalStream;
public:
   LineColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, 
      int lineType, ENUM_LINE_STYLE lineStyle, int width, InternalStream* internalStream)
   {
      _internalStream = internalStream;
      _symbol = symbol;
      _timeframe = timeframe;
      _color = clr;
      _label = label;
      _lineType = lineType;
      _lineStyle = lineStyle;
      _width = width;
   }
   void Init(double defaultValue)
   {
      ArrayInitialize(_stream, defaultValue);
   }

   int Register(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      SetIndexStyle(id, _lineType, _lineStyle, _width, _color);
      if (_label != "")
         SetIndexLabel(id, _label);
      return id + 1;
   }

   double GetValue(int pos)
   {
      return _stream[pos];
   }

   color GetColor()
   {
      return _color;
   }

   void Set(int period, double value, double prevValue)
   {
      if (value == EMPTY_VALUE)
      {
         _stream[period] = EMPTY_VALUE;
         return;
      }
      int size = iBars(_symbol, _timeframe);
      int nextNonEmpty = FindNextNonempty(period, size);
      int count = nextNonEmpty - period + 1;
      double startPoint = _internalStream._stream[nextNonEmpty];
      double diff = startPoint - value;
      for (int i = nextNonEmpty; i >= period; --i)
      {
         _stream[i] = value - double(period - i) / count * diff;
      }
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
private:
   int FindNextNonempty(int period, int size)
   {
      for (int i = period + 1; i < size; ++i)
      {
         if (_internalStream._stream[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return period;
   }
};

class HistogramColoredStreamData : public IColoredStreamData
{
   LineColoredStreamData* _up;
   LineColoredStreamData* _down;
public:
   HistogramColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, int width, InternalStream* internalStream)
   {
      _up = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width, internalStream);
      _down = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width, internalStream);
   }
   ~HistogramColoredStreamData()
   {
      delete _up;
      delete _down;
   }
   void Init(double defaultValue)
   {
      _up.Init(defaultValue);
      _down.Init(defaultValue);
   }

   int Register(int id)
   {
      id = _up.Register(id);
      return _down.Register(id);
   }

   double GetValue(int pos)
   {
      return _up.GetValue(pos);
   }

   color GetColor()
   {
      return _up.GetColor();
   }

   void Set(int period, double value, double prevValue)
   {
      _up.Set(period, value, prevValue);
      _down.Set(period, 0, 0);
   }

   void Clear(int period)
   {
      _up.Clear(period);
      _down.Clear(period);
   }
};

class ArrowColoredStreamData : public IColoredStreamData
{
   double _stream[];
   color _color;
   int _arrow;
public:
   ArrowColoredStreamData(int arrow, color clr)
   {
      _arrow = arrow;
      _color = clr;
   }
   void Init(double defaultValue)
   {
      ArrayInitialize(_stream, defaultValue);
   }

   int Register(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      SetIndexArrow(id, _arrow);
      return id + 1;
   }

   double GetValue(int pos)
   {
      return _stream[pos];
   }

   color GetColor()
   {
      return _color;
   }

   void Set(int period, double value, double prevValue)
   {
      _stream[period] = value;
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
};

class ColoredStream : public AStream
{
   IColoredStreamData* _streams[];
   InternalStream* _internal;
public:
   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
      _internal = new InternalStream();
   }

   ~ColoredStream()
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         delete _streams[i];
      }
      delete _internal;
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         _streams[i].Init(defaultValue);
      }
      ArrayInitialize(_internal._stream, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _internal._stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }
   
   int RegisterArrowStream(int id, uint clr, int arrow)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new ArrowColoredStreamData(arrow, GetColorOnly(clr));
      return _streams[size].Register(id);
   }
   int RegisterStream(int id, uint clr, int transparency)
   {
      return RegisterStream(id, GetColorOnly(clr), "", transparency == 100 ? DRAW_NONE : DRAW_LINE, STYLE_SOLID, 1);
   }
   int RegisterStream(int id, uint clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new LineColoredStreamData(_symbol, _timeframe, GetColorOnly(clr), label, lineType, lineStyle, width, _internal);
      return _streams[size].Register(id);
   }
   int RegisterHistogramStream(int id, uint clr, string label = "", int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new HistogramColoredStreamData(_symbol, _timeframe, GetColorOnly(clr), label, width, _internal);
      return _streams[size].Register(id);
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].GetValue(period) != EMPTY_VALUE)
            return i;
      }
      return -1;
   }
   
   double SetByColor(double value, int period, uint clr)
   {
      clr = GetColorOnly(clr);
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].GetColor() == clr)
         {
            Set(value, period, i);
            return value;
         }
      }
      _internal._stream[period] = value;
      return value;
   }
   
   void Set(double value, int period, int colorIndex)
   {
      _internal._stream[period] = value;
      double prevValue = period + 1 >= iBars(_symbol, _timeframe) ? EMPTY_VALUE : _internal._stream[period + 1];
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Set(period, value, prevValue);
         }
         else
         {
            _streams[i].Clear(period);
         }
      }
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= iBars(_symbol, _timeframe))
      {
         return false;
      }
      val = _internal._stream[period];
      return _internal._stream[period] != EMPTY_VALUE;
   }
};

#endif
// Candles stream v.1.5
class CandleStreamsData
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];
   color Color;

   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
   }

   void Clear(const int index)
   {
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      Color = clr;
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexLabel(id + 0, "Open");
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexLabel(id + 1, "Close");
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexLabel(id + 2, "High");
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 3, LowStream);
      SetIndexLabel(id + 3, "Low");
      return id + 4;
   }

   void AddTick(const int index, const double val)
   {
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
      if (OpenStream[index] == EMPTY_VALUE)
      {
         Set(index, val, val, val, val);
         return;
      }
      HighStream[index] = MathMax(HighStream[index], val);
      LowStream[index] = MathMin(LowStream[index], val);
      CloseStream[index] = val;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

class CandleStreams
{
   int _offset;
public:
   CandleStreamsData* candles[];
   CandleStreams()
   {
      _offset = 0;
   }

   ~CandleStreams()
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         delete candles[i];
      }
   }
   
   void SetOffset(int offset)
   {
      _offset = offset;
   }

   void Init()
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         item.Init();
      }
   }

   void Clear(const int index)
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         item.Clear(index + _offset);
      }
   }

   int RegisterStreams(const int id, const color clr)
   {
      int size = ArraySize(candles);
      ArrayResize(candles, size + 1);
      candles[size] = new CandleStreamsData();
      return candles[size].RegisterStreams(id, clr);
   }

   void Set(const int index, const double open, const double high, const double low, const double close, const color clr)
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         if (item.Color == clr)
         {
            item.Set(index + _offset, open, high, low, close);
         }
         else
         {
            item.Clear(index + _offset);
         }
      }
   }
};
input string param1 = "2000-0300"; // Asia
input color param2 = AddTransparency(Blue, 80); // 
input string param3 = "0300-0830"; // London
input color param4 = AddTransparency(Yellow, 80); // 
input string param5 = "0830-1600"; // New York
input color param6 = AddTransparency(Green, 80); // 
input bool param7 = true; // NY Stays Within London Range
input bool param8 = true; // NY Exceeds London High & Low
input bool param9 = true; // NY Closes Within London Range
input bool param10 = true; // NY Range Too Small
input double param11 = 1.0; // 
input bool param12 = true; // Potential S&D Day
input color param13 = 0x4536f2; // 
input bool param14 = true; // Successful S&D Day
input color param15 = 0x819908; // 
input bool param16 = true; // Show Warning
input string param17 = "Potential S&D Day"; // Warning Message
input color param18 = White; // Text Color
input color param19 = 0x4536f2; // Table Background
input bool param20 = true; // Show Statistics Table
enum param21_enum
{
   param21_value_1, // Bottom Center
   param21_value_2, // Bottom Left
   param21_value_3, // Bottom Right
   param21_value_4, // Middle Center
   param21_value_5, // Middle Left
   param21_value_6, // Middle Right
   param21_value_7, // Top Center
   param21_value_8, // Top Left
   param21_value_9 // Top Right
};
input param21_enum param21_e = param21_value_9; // Table Position
string Get_param21()
{
   switch (param21_e)
   {
      case param21_value_1: return "Bottom Center";
      case param21_value_2: return "Bottom Left";
      case param21_value_3: return "Bottom Right";
      case param21_value_4: return "Middle Center";
      case param21_value_5: return "Middle Left";
      case param21_value_6: return "Middle Right";
      case param21_value_7: return "Top Center";
      case param21_value_8: return "Top Left";
      case param21_value_9: return "Top Right";
   }
   return NULL;
}
enum param22_enum
{
   param22_value_1, // Auto
   param22_value_2, // Tiny
   param22_value_3, // Small
   param22_value_4, // Normal
   param22_value_5, // Large
   param22_value_6 // Huge
};
input param22_enum param22_e = param22_value_1; // Text Size
string Get_param22()
{
   switch (param22_e)
   {
      case param22_value_1: return "Auto";
      case param22_value_2: return "Tiny";
      case param22_value_3: return "Small";
      case param22_value_4: return "Normal";
      case param22_value_5: return "Large";
      case param22_value_6: return "Huge";
   }
   return NULL;
}
input color param23 = Black; // Text
input color param24 = White; // Table Background
input color param25 = Black; // Table Frame
input color param26 = Black; // Table Border
input int param27 = 1; // Table Border Width
input int param28 = 2; // Table Frame Width
input string param29 = "0830-1600"; // New York
input string param30 = "0300-0830"; // London
input string param31 = "2000-0300"; // Asia
enum param32_enum
{
   param32_value_1, // Bottom Center
   param32_value_2, // Bottom Left
   param32_value_3, // Bottom Right
   param32_value_4, // Middle Center
   param32_value_5, // Middle Left
   param32_value_6, // Middle Right
   param32_value_7, // Top Center
   param32_value_8, // Top Left
   param32_value_9 // Top Right
};
input param32_enum param32_e = param32_value_9; // Table Position
string Get_param32()
{
   switch (param32_e)
   {
      case param32_value_1: return "Bottom Center";
      case param32_value_2: return "Bottom Left";
      case param32_value_3: return "Bottom Right";
      case param32_value_4: return "Middle Center";
      case param32_value_5: return "Middle Left";
      case param32_value_6: return "Middle Right";
      case param32_value_7: return "Top Center";
      case param32_value_8: return "Top Left";
      case param32_value_9: return "Top Right";
   }
   return NULL;
}
input color param33 = White; // Table Background
input color param34 = Black; // Table Frame
input color param35 = Black; // Table Border
input int param36 = 2; // Table Frame Width
input int param37 = 1; // Table Border Width
input PriceType param38 = PriceClose; // Source
input int param39 = 5; // ATR Period
input double param40 = 1.5; // ATR Multiplier
input bool param41 = true; // Calculation Method
input bool param42 = true; // Buy/Sell Signals
input bool param43 = true; // Highlighter
input int param44 = 9; // Length
input PriceType param45 = PriceClose; // Source
input int bars_limit = 100000; // Bars limit
SimpleTypeVariable<string>* g_KZS;
uint askz_color;
uint ldkz_color;
uint nykz_color;
SimpleTypeVariable<string>* g_CRT;
int crt_inside_day;
int crt_outside_day;
int crt_close_in_lo;
int crt_sd_limit;
double sd_limit;
SimpleTypeVariable<string>* g_SND;
int show_snd_pre;
uint snd_pre_color;
int show_snd_day;
uint snd_day_color;
SimpleTypeVariable<string>* g_WRN;
int show_wrn_table;
string wrn_msg;
uint wrn_text;
uint wrn_bg;
SimpleTypeVariable<string>* g_STY;
int show_stat_table;
string table_position;
string table_size;
uint table_text;
uint table_bg;
uint table_frame;
uint table_border;
int table_border_width;
int table_frame_width;
DateTimeStream* time1;
DateTimeStream* time2;
DateTimeStream* time3;
double sessions[];
double sessions_DEFAULT_VALUE;
double last_snd_pre[];
double last_snd_pre_DEFAULT_VALUE;
double last_snd_day[];
double last_snd_day_DEFAULT_VALUE;
double total_snd_wrn[];
double total_snd_wrn_DEFAULT_VALUE;
double total_snd_day[];
double total_snd_day_DEFAULT_VALUE;
CustomTypeVariable<Box>* nykz_box;
CustomTypeVariable<Box>* lokz_box;
CustomTypeVariable<Box>* askz_box;
double last_new_ny[];
double last_new_ny_DEFAULT_VALUE;
double last_ny_high[];
double last_ny_high_DEFAULT_VALUE;
double last_ny_low[];
double last_ny_low_DEFAULT_VALUE;
double last_ny_close[];
double last_ny_close_DEFAULT_VALUE;
double last_new_lo[];
double last_new_lo_DEFAULT_VALUE;
double last_lo_high[];
double last_lo_high_DEFAULT_VALUE;
double last_lo_low[];
double last_lo_low_DEFAULT_VALUE;
double last_lo_close[];
double last_lo_close_DEFAULT_VALUE;
double last_new_as[];
double last_new_as_DEFAULT_VALUE;
double last_as_high[];
double last_as_high_DEFAULT_VALUE;
double last_as_low[];
double last_as_low_DEFAULT_VALUE;
double last_as_close[];
double last_as_close_DEFAULT_VALUE;
CustomTypeVariable<ISimpleTypeArray<double>>* ny_range;
double nykz[];
double nykz_DEFAULT_VALUE;
double lokz[];
double lokz_DEFAULT_VALUE;
double askz[];
double askz_DEFAULT_VALUE;
class manual_stdev_1Stream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   manual_stdev_1Stream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~manual_stdev_1Stream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      double mean = Array::Avg(ny_range.Get());
      double accum = 0.0;
      int size = Array::Size<int, ISimpleTypeArray<double>*>(ny_range.Get(), INT_MIN);
      if (SafeGreater(size, 0))
      {
         int for1_from = 0;
         int for1_to = SafeMinus(size, 1);
         bool for1_forward = for1_from <= for1_to;
         int for1_step = 1 * (for1_forward ? 1 : -1);
         if (for1_from == INT_MIN || for1_to == INT_MIN) { return false; }
         for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
         {
            accum = SafePlus(accum, SafeMathPow((SafeMinus(Array::Get<double, ISimpleTypeArray<double>*, int>(ny_range.Get(), i, EMPTY_VALUE), mean)), 2));
         }
      }
      double sd = SafeMathSqrt(SafeDivide(accum, size));
      __out1 = sd;
      return true;
   }
};
manual_stdev_1Stream* manual_stdev_11;
class get_table_position_1Stream
{
   string _pos;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   get_table_position_1Stream(string _pos, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._pos = _pos;
   }
   ~get_table_position_1Stream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, string &__out1)
   {
      string switch1Value1 = NULL;
      if ((_pos == "Bottom Center"))
      {
         switch1Value1 = "bottom_center";
      }
      else if ((_pos == "Bottom Left"))
      {
         switch1Value1 = "bottom_left";
      }
      else if ((_pos == "Bottom Right"))
      {
         switch1Value1 = "bottom_right";
      }
      else if ((_pos == "Middle Center"))
      {
         switch1Value1 = "middle_center";
      }
      else if ((_pos == "Middle Left"))
      {
         switch1Value1 = "middle_left";
      }
      else if ((_pos == "Middle Right"))
      {
         switch1Value1 = "middle_right";
      }
      else if ((_pos == "Top Center"))
      {
         switch1Value1 = "top_center";
      }
      else if ((_pos == "Top Left"))
      {
         switch1Value1 = "top_left";
      }
      else if ((_pos == "Top Right"))
      {
         switch1Value1 = "top_right";
      }
      string result = switch1Value1;
      __out1 = result;
      return true;
   }
};
get_table_position_1Stream* get_table_position_12;
SimpleTypeVariable<Table*>* stats;
class get_text_size_1Stream
{
   string size;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   get_text_size_1Stream(string size, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.size = size;
   }
   ~get_text_size_1Stream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, string &__out1)
   {
      string switch2Value1 = NULL;
      if ((size == "Auto"))
      {
         switch2Value1 = "auto";
      }
      else if ((size == "Tiny"))
      {
         switch2Value1 = "tiny";
      }
      else if ((size == "Small"))
      {
         switch2Value1 = "small";
      }
      else if ((size == "Normal"))
      {
         switch2Value1 = "normal";
      }
      else if ((size == "Large"))
      {
         switch2Value1 = "large";
      }
      else if ((size == "Huge"))
      {
         switch2Value1 = "huge";
      }
      string result = switch2Value1;
      __out1 = result;
      return true;
   }
};
get_text_size_1Stream* get_text_size_13;
TIStream<double>* param38Stream;
TIStream<double>* source;
int Periods;
double Multiplier;
int changeATR;
int showsignals;
int highlighting;
double haOpen[];
double haOpen_DEFAULT_VALUE;
double haClose[];
double haClose_DEFAULT_VALUE;
FloatStream* sma1Source;
SmaOnStream* sma1;
TIStream<double>* tr1;
ATRStream* atr1;
double up[];
double up_DEFAULT_VALUE;
ValueWhenSimpleStream* valuewhen1;
double dn[];
double dn_DEFAULT_VALUE;
ValueWhenSimpleStream* valuewhen2;
double trend[];
double trend_DEFAULT_VALUE;
double plot1[];
double plot2[];
Signaler* _signaler;
int emaLength;
TIStream<double>* param45Stream;
TIStream<double>* emaSource;
FloatStream* ema1Source;
EMAOnStream* ema1;
ColoredStream* plot3;
CandleStreams* barcolor1;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(string target)
{
   if (StringLen(target) > 20)
   {
      target = StringSubstr(target, 0, 20);
   }
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

int init()
{
   IndicatorBuffers(40);
   askz_color = param2;
   ldkz_color = param4;
   nykz_color = param6;
   crt_inside_day = param7;
   crt_outside_day = param8;
   crt_close_in_lo = param9;
   crt_sd_limit = param10;
   sd_limit = param11;
   show_snd_pre = param12;
   snd_pre_color = param13;
   show_snd_day = param14;
   snd_day_color = param15;
   show_wrn_table = param16;
   wrn_msg = param17;
   wrn_text = param18;
   wrn_bg = param19;
   show_stat_table = param20;
   table_position = Get_param21();
   table_size = Get_param22();
   table_text = param23;
   table_bg = param24;
   table_frame = param25;
   table_border = param26;
   table_border_width = param27;
   table_frame_width = param28;
   string ny_am = param29;
   time1 = new DateTimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, Timeframe::Period(), ny_am, "America/New_York");
   string lo_am = param30;
   time2 = new DateTimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, Timeframe::Period(), lo_am, "America/New_York");
   string as_am = param31;
   time3 = new DateTimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, Timeframe::Period(), as_am, "America/New_York");
   int id = 0;
   table_position = Get_param32();
   table_bg = param33;
   table_frame = param34;
   table_border = param35;
   table_frame_width = param36;
   table_border_width = param37;
   param38Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param38);
   source = param38Stream;
   Periods = param39;
   Multiplier = param40;
   changeATR = param41;
   showsignals = param42;
   highlighting = param43;
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, Periods);
   atr1 = new ATRStream(Periods);
   SetIndexBuffer(id, plot1);
   SetIndexShift(id, (-1));
   SetIndexArrow(id++, 241);
   SetIndexBuffer(id, plot2);
   SetIndexShift(id, (-1));
   SetIndexArrow(id++, 242);
   emaLength = param44;
   param45Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param45);
   emaSource = param45Stream;
   ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, emaLength);
   plot3 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot3.RegisterStream(id, 0x08ff00, "", DRAW_LINE, STYLE_SOLID, 2);
   id = plot3.RegisterStream(id, 0x0000ff, "", DRAW_LINE, STYLE_SOLID, 2);
   barcolor1 = new CandleStreams();
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id, 0x08ff00);
   id = barcolor1.RegisterStreams(id, 0x0000ff);
   BoxesCollection::SetMaxBoxes(500);
   LabelsCollection::SetMaxLabels(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("S&D Profile [TFO]");
   IndicatorShortName("Bay and selly Ssssion ");
   g_KZS = new SimpleTypeVariable<string>(NULL, NULL);
   g_CRT = new SimpleTypeVariable<string>(NULL, NULL);
   g_SND = new SimpleTypeVariable<string>(NULL, NULL);
   g_WRN = new SimpleTypeVariable<string>(NULL, NULL);
   g_STY = new SimpleTypeVariable<string>(NULL, NULL);
   SetIndexBuffer(id++, sessions);
   SetIndexBuffer(id++, last_snd_pre);
   SetIndexBuffer(id++, last_snd_day);
   SetIndexBuffer(id++, total_snd_wrn);
   SetIndexBuffer(id++, total_snd_day);
   nykz_box = new CustomTypeVariable<Box>(NULL, BoxesCollection::GetDestructor());
   lokz_box = new CustomTypeVariable<Box>(NULL, BoxesCollection::GetDestructor());
   askz_box = new CustomTypeVariable<Box>(NULL, BoxesCollection::GetDestructor());
   SetIndexBuffer(id++, last_new_ny);
   SetIndexBuffer(id++, last_ny_high);
   SetIndexBuffer(id++, last_ny_low);
   SetIndexBuffer(id++, last_ny_close);
   SetIndexBuffer(id++, last_new_lo);
   SetIndexBuffer(id++, last_lo_high);
   SetIndexBuffer(id++, last_lo_low);
   SetIndexBuffer(id++, last_lo_close);
   SetIndexBuffer(id++, last_new_as);
   SetIndexBuffer(id++, last_as_high);
   SetIndexBuffer(id++, last_as_low);
   SetIndexBuffer(id++, last_as_close);
   ny_range = new CustomTypeVariable<ISimpleTypeArray<double>>(NULL, NULL);
   SetIndexBuffer(id++, nykz);
   SetIndexBuffer(id++, lokz);
   SetIndexBuffer(id++, askz);
   manual_stdev_11 = new manual_stdev_1Stream(IndicatorObjPrefix + "_1");
   id = manual_stdev_11.Init(id);
   get_table_position_12 = new get_table_position_1Stream(table_position, IndicatorObjPrefix + "_2");
   id = get_table_position_12.Init(id);
   stats = new SimpleTypeVariable<Table*>(NULL, NULL);
   get_text_size_13 = new get_text_size_1Stream(table_size, IndicatorObjPrefix + "_3");
   id = get_text_size_13.Init(id);
   SetIndexBuffer(id++, haOpen);
   SetIndexBuffer(id++, haClose);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(id++, up);
   valuewhen1 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen1.RegisterInternalStream(id);
   SetIndexBuffer(id++, dn);
   valuewhen2 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen2.RegisterInternalStream(id);
   SetIndexBuffer(id++, trend);
   _signaler = new Signaler();
   id = plot3.RegisterInternalStream(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete g_KZS;
   delete g_CRT;
   delete g_SND;
   delete g_WRN;
   delete g_STY;
   time1.Release();
   time2.Release();
   time3.Release();
   delete nykz_box;
   delete lokz_box;
   delete askz_box;
   delete ny_range;
   delete manual_stdev_11;
   delete get_table_position_12;
   delete stats;
   delete get_text_size_13;
   param38Stream.Release();
   sma1Source.Release();
   sma1.Release();
   tr1.Release();
   atr1.Release();
   valuewhen1.Release();
   valuewhen2.Release();
   delete _signaler;
   param45Stream.Release();
   ema1Source.Release();
   ema1.Release();
   delete plot3;
   delete barcolor1;
   BoxesCollection::Clear(true);
   LabelsCollection::Clear(true);
   TableManager::Clear(true);
   return 0;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      BoxesCollection::Clear();
      LabelsCollection::Clear();
      TableManager::Clear();
      g_KZS.Clear();
      g_CRT.Clear();
      g_SND.Clear();
      g_WRN.Clear();
      g_STY.Clear();
      sessions_DEFAULT_VALUE = 0;
      ArrayInitialize(sessions, sessions_DEFAULT_VALUE);
      last_snd_pre_DEFAULT_VALUE = 0;
      ArrayInitialize(last_snd_pre, last_snd_pre_DEFAULT_VALUE);
      last_snd_day_DEFAULT_VALUE = 0;
      ArrayInitialize(last_snd_day, last_snd_day_DEFAULT_VALUE);
      total_snd_wrn_DEFAULT_VALUE = 0;
      ArrayInitialize(total_snd_wrn, total_snd_wrn_DEFAULT_VALUE);
      total_snd_day_DEFAULT_VALUE = 0;
      ArrayInitialize(total_snd_day, total_snd_day_DEFAULT_VALUE);
      nykz_box.Clear();
      lokz_box.Clear();
      askz_box.Clear();
      last_new_ny_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(last_new_ny, last_new_ny_DEFAULT_VALUE);
      last_ny_high_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_ny_high, last_ny_high_DEFAULT_VALUE);
      last_ny_low_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_ny_low, last_ny_low_DEFAULT_VALUE);
      last_ny_close_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_ny_close, last_ny_close_DEFAULT_VALUE);
      last_new_lo_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(last_new_lo, last_new_lo_DEFAULT_VALUE);
      last_lo_high_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_lo_high, last_lo_high_DEFAULT_VALUE);
      last_lo_low_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_lo_low, last_lo_low_DEFAULT_VALUE);
      last_lo_close_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_lo_close, last_lo_close_DEFAULT_VALUE);
      last_new_as_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(last_new_as, last_new_as_DEFAULT_VALUE);
      last_as_high_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_as_high, last_as_high_DEFAULT_VALUE);
      last_as_low_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_as_low, last_as_low_DEFAULT_VALUE);
      last_as_close_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_as_close, last_as_close_DEFAULT_VALUE);
      ny_range.Clear();
      nykz_DEFAULT_VALUE = (-1);
      ArrayInitialize(nykz, nykz_DEFAULT_VALUE);
      lokz_DEFAULT_VALUE = (-1);
      ArrayInitialize(lokz, lokz_DEFAULT_VALUE);
      askz_DEFAULT_VALUE = (-1);
      ArrayInitialize(askz, askz_DEFAULT_VALUE);
      manual_stdev_11.Clear();
      get_table_position_12.Clear();
      stats.Clear();
      get_text_size_13.Clear();
      haOpen_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(haOpen, haOpen_DEFAULT_VALUE);
      haClose_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(haClose, haClose_DEFAULT_VALUE);
      sma1Source.Init();
      up_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(up, up_DEFAULT_VALUE);
      dn_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(dn, dn_DEFAULT_VALUE);
      trend_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(trend, trend_DEFAULT_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ema1Source.Init();
      plot3.Init(EMPTY_VALUE);
      barcolor1.Init();
   }
   bool timeSeries = ArrayGetAsSeries(time);
   bool openSeries = ArrayGetAsSeries(open);
   bool highSeries = ArrayGetAsSeries(high);
   bool lowSeries = ArrayGetAsSeries(low);
   bool closeSeries = ArrayGetAsSeries(close);
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      sessions[pos] = pos < (rates_total - 1) ? sessions[pos + 1] : 0;
      last_snd_pre[pos] = pos < (rates_total - 1) ? last_snd_pre[pos + 1] : 0;
      last_snd_day[pos] = pos < (rates_total - 1) ? last_snd_day[pos + 1] : 0;
      total_snd_wrn[pos] = pos < (rates_total - 1) ? total_snd_wrn[pos + 1] : 0;
      total_snd_day[pos] = pos < (rates_total - 1) ? total_snd_day[pos + 1] : 0;
      last_new_ny[pos] = pos < (rates_total - 1) ? last_new_ny[pos + 1] : INT_MIN;
      last_ny_high[pos] = pos < (rates_total - 1) ? last_ny_high[pos + 1] : EMPTY_VALUE;
      last_ny_low[pos] = pos < (rates_total - 1) ? last_ny_low[pos + 1] : EMPTY_VALUE;
      last_ny_close[pos] = pos < (rates_total - 1) ? last_ny_close[pos + 1] : EMPTY_VALUE;
      last_new_lo[pos] = pos < (rates_total - 1) ? last_new_lo[pos + 1] : INT_MIN;
      last_lo_high[pos] = pos < (rates_total - 1) ? last_lo_high[pos + 1] : EMPTY_VALUE;
      last_lo_low[pos] = pos < (rates_total - 1) ? last_lo_low[pos + 1] : EMPTY_VALUE;
      last_lo_close[pos] = pos < (rates_total - 1) ? last_lo_close[pos + 1] : EMPTY_VALUE;
      last_new_as[pos] = pos < (rates_total - 1) ? last_new_as[pos + 1] : INT_MIN;
      last_as_high[pos] = pos < (rates_total - 1) ? last_as_high[pos + 1] : EMPTY_VALUE;
      last_as_low[pos] = pos < (rates_total - 1) ? last_as_low[pos + 1] : EMPTY_VALUE;
      last_as_close[pos] = pos < (rates_total - 1) ? last_as_close[pos + 1] : EMPTY_VALUE;
      haOpen[pos] = pos < (rates_total - 1) ? haOpen[pos + 1] : EMPTY_VALUE;
      trend[pos] = pos < (rates_total - 1) ? trend[pos + 1] : INT_MIN;
      if (!g_KZS.IsInitialized())
      {
         g_KZS.Set("Killzones");
      }
      string as_am = param1;
      string lo_am = param3;
      string ny_am = param5;
      if (!g_CRT.IsInitialized())
      {
         g_CRT.Set("Success Criteria");
      }
      if (!g_SND.IsInitialized())
      {
         g_SND.Set("Labels");
      }
      if (!g_WRN.IsInitialized())
      {
         g_WRN.Set("Warning");
      }
      if (!g_STY.IsInitialized())
      {
         g_STY.Set("Statistics");
      }
      datetime time1Value;
      if (!time1.GetValue(pos, time1Value)) { time1Value = NULL; }
      SetStream(nykz, pos, !((time1Value) == NULL), nykz_DEFAULT_VALUE);
      datetime time2Value;
      if (!time2.GetValue(pos, time2Value)) { time2Value = NULL; }
      SetStream(lokz, pos, !((time2Value) == NULL), lokz_DEFAULT_VALUE);
      datetime time3Value;
      if (!time3.GetValue(pos, time3Value)) { time3Value = NULL; }
      SetStream(askz, pos, !((time3Value) == NULL), askz_DEFAULT_VALUE);
      if (!nykz_box.IsInitialized())
      {
         nykz_box.Set(NULL);
      }
      if (!lokz_box.IsInitialized())
      {
         lokz_box.Set(NULL);
      }
      if (!askz_box.IsInitialized())
      {
         askz_box.Set(NULL);
      }
      if (!ny_range.IsInitialized())
      {
         ISimpleTypeArray<double>* __array1 = new FloatArray(0, EMPTY_VALUE);
         ny_range.Set(__array1);
         __array1.Release();
      }
      if (nykz[pos])
      {
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (!nykz[pos + 1])
         {
      nykz_box.Set(BoxesCollection::Create(IndicatorObjPrefix + "box_1_id", ((rates_total - 1) - pos), high[pos], ((rates_total - 1) - pos), low[pos], time[pos])
               .SetBgColor(nykz_color)
               .SetBorderColor(nykz_color)
               .SetExtend("none")
               .SetText("New York")
               .SetTextColor(nykz_color)
               .SetTextHAlign("center")
               .SetTextVAlign("center")
               .SetTextSize("auto"));
            SetStream(sessions, pos, sessions[pos] + 1, sessions_DEFAULT_VALUE);
         }
         else
         {
            double top = Box::GetTop(nykz_box.Get());
            double bot = Box::GetBottom(nykz_box.Get());
            if (SafeGreater(high[pos], top))
            {
               top = high[pos];
            }
            if (SafeLess(low[pos], bot))
            {
               bot = low[pos];
            }
            Box::SetRightBottom(nykz_box.Get(), ((rates_total - 1) - pos), bot);
            Box::SetTop(nykz_box.Get(), top);
         }
      }
      if (lokz[pos])
      {
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (!lokz[pos + 1])
         {
      lokz_box.Set(BoxesCollection::Create(IndicatorObjPrefix + "box_2_id", ((rates_total - 1) - pos), high[pos], ((rates_total - 1) - pos), low[pos], time[pos])
               .SetBgColor(ldkz_color)
               .SetBorderColor(ldkz_color)
               .SetExtend("none")
               .SetText("London")
               .SetTextColor(ldkz_color)
               .SetTextHAlign("center")
               .SetTextVAlign("center")
               .SetTextSize("auto"));
         }
         else
         {
            double top = Box::GetTop(lokz_box.Get());
            double bot = Box::GetBottom(lokz_box.Get());
            if (SafeGreater(high[pos], top))
            {
               top = high[pos];
            }
            if (SafeLess(low[pos], bot))
            {
               bot = low[pos];
            }
            Box::SetRightBottom(lokz_box.Get(), ((rates_total - 1) - pos), bot);
            Box::SetTop(lokz_box.Get(), top);
         }
      }
      if (askz[pos])
      {
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (!askz[pos + 1])
         {
      askz_box.Set(BoxesCollection::Create(IndicatorObjPrefix + "box_3_id", ((rates_total - 1) - pos), high[pos], ((rates_total - 1) - pos), low[pos], time[pos])
               .SetBgColor(askz_color)
               .SetBorderColor(askz_color)
               .SetExtend("none")
               .SetText("Asia")
               .SetTextColor(askz_color)
               .SetTextHAlign("center")
               .SetTextVAlign("center")
               .SetTextSize("auto"));
         }
         else
         {
            double top = Box::GetTop(askz_box.Get());
            double bot = Box::GetBottom(askz_box.Get());
            if (SafeGreater(high[pos], top))
            {
               top = high[pos];
            }
            if (SafeLess(low[pos], bot))
            {
               bot = low[pos];
            }
            Box::SetRightBottom(askz_box.Get(), ((rates_total - 1) - pos), bot);
            Box::SetTop(askz_box.Get(), top);
         }
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (!nykz[pos] && nykz[pos + 1])
      {
         SetStream(last_ny_high, pos, Box::GetTop(nykz_box.Get()), last_ny_high_DEFAULT_VALUE);
         SetStream(last_ny_low, pos, Box::GetBottom(nykz_box.Get()), last_ny_low_DEFAULT_VALUE);
         if (pos + 1 > (rates_total - 1)) { continue; }
         SetStream(last_ny_close, pos, close[pos + 1], last_ny_close_DEFAULT_VALUE);
         SetStream(last_new_ny, pos, ((rates_total - 1) - pos), last_new_ny_DEFAULT_VALUE);
         Array::Push<ISimpleTypeArray<double>*, double>(ny_range.Get(), SafeMinus(last_ny_high[pos], last_ny_low[pos]));
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (!lokz[pos] && lokz[pos + 1])
      {
         SetStream(last_lo_high, pos, Box::GetTop(lokz_box.Get()), last_lo_high_DEFAULT_VALUE);
         SetStream(last_lo_low, pos, Box::GetBottom(lokz_box.Get()), last_lo_low_DEFAULT_VALUE);
         if (pos + 1 > (rates_total - 1)) { continue; }
         SetStream(last_lo_close, pos, close[pos + 1], last_lo_close_DEFAULT_VALUE);
         SetStream(last_new_lo, pos, ((rates_total - 1) - pos), last_new_lo_DEFAULT_VALUE);
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (!askz[pos] && askz[pos + 1])
      {
         SetStream(last_as_high, pos, Box::GetTop(askz_box.Get()), last_as_high_DEFAULT_VALUE);
         SetStream(last_as_low, pos, Box::GetBottom(askz_box.Get()), last_as_low_DEFAULT_VALUE);
         if (pos + 1 > (rates_total - 1)) { continue; }
         SetStream(last_as_close, pos, close[pos + 1], last_as_close_DEFAULT_VALUE);
         SetStream(last_new_as, pos, ((rates_total - 1) - pos), last_new_as_DEFAULT_VALUE);
      }
      int snd_day_wrn = false;
      if (SafeGreater(last_new_lo[pos], last_new_as[pos]) && SafeGreater(last_lo_high[pos], last_as_high[pos]) && SafeLess(last_lo_low[pos], last_as_low[pos]) && SafeLess(last_snd_pre[pos], last_new_lo[pos]))
      {
         snd_day_wrn = true;
         SetStream(last_snd_pre, pos, ((rates_total - 1) - pos), last_snd_pre_DEFAULT_VALUE);
         SetStream(total_snd_wrn, pos, total_snd_wrn[pos] + 1, total_snd_wrn_DEFAULT_VALUE);
      }
      int snd_day_valid = false;
      if (SafeGreater(last_new_ny[pos], last_new_lo[pos]) && SafeGreater(last_snd_pre[pos], last_new_as[pos]) && SafeLess(last_snd_day[pos], last_new_ny[pos]))
      {
         int outside_day = (crt_outside_day ? SafeGE(last_ny_high[pos], last_lo_high[pos]) && SafeLE(last_ny_low[pos], last_lo_low[pos]) : false);
         int inside_day = (crt_inside_day ? SafeLess(last_ny_high[pos], last_lo_high[pos]) && SafeGreater(last_ny_low[pos], last_lo_low[pos]) : false);
         int close_inside_lo = (crt_close_in_lo ? SafeLess(last_ny_close[pos], last_lo_high[pos]) && SafeGreater(last_ny_close[pos], last_lo_low[pos]) : false);
         double manual_stdev_11Value;
         if (!manual_stdev_11.GetValue(pos, manual_stdev_11Value)) { manual_stdev_11Value = EMPTY_VALUE; }
         int stdev = (crt_sd_limit ? SafeLE(SafeMinus(last_ny_high[pos], last_ny_low[pos]), SafeMultiply(manual_stdev_11Value, sd_limit)) : false);
         if ((((outside_day || inside_day) || close_inside_lo) || stdev))
         {
            snd_day_valid = true;
            SetStream(last_snd_day, pos, ((rates_total - 1) - pos), last_snd_day_DEFAULT_VALUE);
            SetStream(total_snd_day, pos, total_snd_day[pos] + 1, total_snd_day_DEFAULT_VALUE);
         }
      }
      if (show_snd_pre && snd_day_wrn)
      {
         LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", ((rates_total - 1) - pos), last_lo_high[pos], time[pos]).SetColor(snd_pre_color).SetText("Potential S&D Day").SetTextColor(wrn_text).SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      }
      if (show_snd_day && snd_day_valid)
      {
         LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", ((rates_total - 1) - pos), last_ny_high[pos], time[pos]).SetColor(snd_day_color).SetText("Valid S&D Day").SetTextColor(wrn_text).SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      }
      if (!stats.IsInitialized())
      {
         string get_table_position_12Value;
         if (!get_table_position_12.GetValue(pos, get_table_position_12Value)) { get_table_position_12Value = NULL; }
         stats.Set(TableManager::Create(IndicatorObjPrefix, "1", get_table_position_12Value, 10, 10).SetBorderWidth(table_border_width).SetBGColor(table_bg).SetBorderColor(table_border).SetFrameColor(table_frame).SetFrameWidth(table_frame_width));
      }
      string get_text_size_13Value;
      if (!get_text_size_13.GetValue(pos, get_text_size_13Value)) { get_text_size_13Value = NULL; }
      string table_text_size = get_text_size_13Value;
      if ((pos == 0))
      {
         if (show_stat_table)
         {
            Table::CellText(stats.Get(), 0, 1, "Seek & Destroy Profile");
            Table::CellTextColor(stats.Get(), 0, 1, table_text);
            Table::CellTextSize(stats.Get(), 0, 1, table_text_size);
            Table::CellTextHAlign(stats.Get(), 0, 1, "center");
            Table::CellText(stats.Get(), 0, 2, "Total Sessions");
            Table::CellTextColor(stats.Get(), 0, 2, table_text);
            Table::CellTextSize(stats.Get(), 0, 2, table_text_size);
            Table::CellTextHAlign(stats.Get(), 0, 2, "center");
            Table::CellText(stats.Get(), 1, 2, Str::ToString(sessions[pos]));
            Table::CellTextColor(stats.Get(), 1, 2, table_text);
            Table::CellTextSize(stats.Get(), 1, 2, table_text_size);
            Table::CellTextHAlign(stats.Get(), 1, 2, "center");
            Table::CellText(stats.Get(), 0, 3, "Warnings Given");
            Table::CellTextColor(stats.Get(), 0, 3, table_text);
            Table::CellTextSize(stats.Get(), 0, 3, table_text_size);
            Table::CellTextHAlign(stats.Get(), 0, 3, "center");
            Table::CellText(stats.Get(), 1, 3, Str::ToString(total_snd_wrn[pos]));
            Table::CellTextColor(stats.Get(), 1, 3, table_text);
            Table::CellTextSize(stats.Get(), 1, 3, table_text_size);
            Table::CellTextHAlign(stats.Get(), 1, 3, "center");
            Table::CellText(stats.Get(), 0, 4, "Warning Success");
            Table::CellTextColor(stats.Get(), 0, 4, table_text);
            Table::CellTextSize(stats.Get(), 0, 4, table_text_size);
            Table::CellTextHAlign(stats.Get(), 0, 4, "center");
            Table::CellText(stats.Get(), 1, 4, Str::ToString(total_snd_day[pos]));
            Table::CellTextColor(stats.Get(), 1, 4, table_text);
            Table::CellTextSize(stats.Get(), 1, 4, table_text_size);
            Table::CellTextHAlign(stats.Get(), 1, 4, "center");
            Table::CellText(stats.Get(), 0, 5, "Warning Success Rate");
            Table::CellTextColor(stats.Get(), 0, 5, table_text);
            Table::CellTextSize(stats.Get(), 0, 5, table_text_size);
            Table::CellTextHAlign(stats.Get(), 0, 5, "center");
            Table::CellText(stats.Get(), 1, 5, SafePlus(Str::ToString(SafeMathRound(SafeMultiply(SafeDivide(total_snd_day[pos], total_snd_wrn[pos]), 100))), "%"));
            Table::CellTextColor(stats.Get(), 1, 5, table_text);
            Table::CellTextSize(stats.Get(), 1, 5, table_text_size);
            Table::CellTextHAlign(stats.Get(), 1, 5, "center");
         }
         if (show_wrn_table)
         {
            if (SafeGreater(last_snd_pre[pos], last_new_ny[pos]))
            {
               Table::CellText(stats.Get(), 0, 1, wrn_msg);
               Table::CellTextColor(stats.Get(), 0, 1, wrn_text);
               Table::CellTextSize(stats.Get(), 0, 1, table_text_size);
               Table::CellTextHAlign(stats.Get(), 0, 1, "center");
               Table::CellBGColor(stats.Get(), 0, 1, wrn_bg);
            }
         }
      }
      double sourceValue;
      if (!source.GetValue(pos, sourceValue)) { sourceValue = EMPTY_VALUE; }
      SetStream(haClose, pos, SafeDivide((open[pos] + high[pos] + low[pos] + sourceValue), 4), haClose_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(haOpen, pos, (((haOpen[pos + 1]) == EMPTY_VALUE) ? SafeDivide((open[pos] + sourceValue), 2) : SafeDivide((SafePlus(haOpen[pos + 1], haClose[pos + 1])), 2)), haOpen_DEFAULT_VALUE);
      double haHigh = SafeMathMax(high[pos], SafeMathMax(haClose[pos], haOpen[pos]));
      double haLow = SafeMathMin(low[pos], SafeMathMin(haClose[pos], haOpen[pos]));
      double tr1Value;
      if (!tr1.GetValue(pos, tr1Value)) { tr1Value = EMPTY_VALUE; }
      sma1Source.SetValue(pos, tr1Value);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double atr2 = sma1Value;
      double atr1Value;
      if (!atr1.GetValue(pos, atr1Value)) { atr1Value = EMPTY_VALUE; }
      double atr = (changeATR ? atr1Value : atr2);
      SetStream(up, pos, SafeMinus(haClose[pos], (SafeMultiply(Multiplier, atr))), up_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      double up1 = valuewhen1.Update(pos, time[pos], SafeGreater(haClose[pos + 1], up[pos + 1]), up[pos + 1]);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(up, pos, (SafeGreater(haClose[pos + 1], up1) ? SafeMathMax(up[pos], up1) : up[pos]), up_DEFAULT_VALUE);
      SetStream(dn, pos, SafePlus(haClose[pos], (SafeMultiply(Multiplier, atr))), dn_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      double dn1 = valuewhen2.Update(pos, time[pos], SafeLess(haClose[pos], dn[pos + 1]), dn[pos + 1]);
      SetStream(dn, pos, (SafeLess(haClose[pos], dn1) ? SafeMathMin(dn[pos], dn1) : dn[pos]), dn_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(trend, pos, (((trend[pos + 1]) == INT_MIN) ? 1 : trend[pos]), trend_DEFAULT_VALUE);
      SetStream(trend, pos, ((trend[pos] == (-1)) && SafeGreater(haClose[pos], dn1) ? 1 : ((trend[pos] == 1) && SafeLess(haClose[pos], up1) ? (-1) : trend[pos])), trend_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int buySignal = (trend[pos] == 1) && (trend[pos + 1] == (-1));
      PlotShape::Set(plot1, pos, "belowbar", (buySignal ? up[pos] : EMPTY_VALUE), high, low, 1);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int sellSignal = (trend[pos] == (-1)) && (trend[pos + 1] == 1);
      PlotShape::Set(plot2, pos, "abovebar", (sellSignal ? dn[pos] : EMPTY_VALUE), high, low, 1);
      if (buySignal) { _signaler.SendNotifications("Buy", "Buy!"); }
      if (sellSignal) { _signaler.SendNotifications("Sell", "Sell!"); }
      if (pos + 1 > (rates_total - 1)) { continue; }
      int changeCond = (trend[pos] != trend[pos + 1]);
      if (changeCond) { _signaler.SendNotifications("Direction Change", "changed direction!"); }
      double emaSourceValue;
      if (!emaSource.GetValue(pos, emaSourceValue)) { emaSourceValue = EMPTY_VALUE; }
      ema1Source.SetValue(pos, emaSourceValue);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      double ema = ema1Value;
      if (pos + 1 > (rates_total - 1)) { continue; }
      double plot3Value = plot3.SetByColor(ema, pos, (SafeGreater(close[pos + 1], ema) && SafeGreater(close[pos], ema) ? 0x08ff00 : 0x0000ff));
      uint barcolor1_color = (SafeGreater(close[pos], ema) ? 0x08ff00 : 0x0000ff);
      if (barcolor1_color != INT_MAX)
      {
         barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor1_color);
      }
      else
      {
         barcolor1.Clear(pos);
      }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   BoxesCollection::Redraw();
   LabelsCollection::Redraw();
   TableManager::Redraw();
   return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76393
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 