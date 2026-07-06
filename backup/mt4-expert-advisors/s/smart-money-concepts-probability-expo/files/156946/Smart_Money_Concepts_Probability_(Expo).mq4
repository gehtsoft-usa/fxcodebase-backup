//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75271

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property strict
#property indicator_chart_window
#property indicator_buffers 0

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

color FromGradient(double value, double bottomValue, double topValue, color bottomColor, color topColor)
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

class PineScriptTime
{
public:
   static int Hour(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.hour;
   }
   static int Year(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.year;
   }
   static int DayOfWeek(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.day_of_week;
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
};

class Runtime
{
public:
   static void Error(string message)
   {
      Print(message);
      ExpertRemove();
   }
};
// Array v1.3
// Array interface v1.0

// int array interface v1.2

class IIntArray
{
public:
   virtual void Unshift(int value) = 0;
   virtual int Size() = 0;
   virtual void Push(int value) = 0;
   virtual int Pop() = 0;
   virtual int Get(int index) = 0;
   virtual void Set(int index, int value) = 0;
   virtual IIntArray* Slice(int from, int to) = 0;
   virtual IIntArray* Clear() = 0;
   virtual int Shift() = 0;
   virtual int Remove(int index) = 0;
   virtual int Includes(int value) = 0;
};
// Line array interface v1.2
// Line object v1.3

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   color _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window, bool global)
   {
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

   Line* SetStyle(string style)
   {
      _style = style;
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

   Line* SetColor(color clr)
   {
      _clr = clr;
      return &this;
   }

   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }

   void Redraw()
   {
      int pos1 = iBars(_Symbol, _timeframe) - _x1 - 1;
      datetime x1 = iTime(_Symbol, _timeframe, pos1);
      int pos2 = iBars(_Symbol, _timeframe) - _x2 - 1;
      datetime x2 = iTime(_Symbol, _timeframe, pos2);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, x2);
   }
};

class ILineArray
{
public:
   virtual void Unshift(Line* value) = 0;
   virtual int Size() = 0;
   virtual void Push(Line* value) = 0;
   virtual Line* Pop() = 0;
   virtual Line* Get(int index) = 0;
   virtual void Set(int index, Line* value) = 0;
   virtual ILineArray* Slice(int from, int to) = 0;
   virtual ILineArray* Clear() = 0;
   virtual Line* Shift() = 0;
   virtual Line* Remove(int index) = 0;
   virtual int Includes(Line* value) = 0;
};
// float array interface v1.2

class IFloatArray
{
public:
   virtual void Unshift(double value) = 0;
   virtual int Size() = 0;
   virtual void Push(double value) = 0;
   virtual double Pop() = 0;
   virtual double Get(int index) = 0;
   virtual void Set(int index, double value) = 0;
   virtual IFloatArray* Slice(int from, int to) = 0;
   virtual IFloatArray* Clear() = 0;
   virtual double Shift() = 0;
   virtual double Remove(int index) = 0;
   virtual int Includes(double value) = 0;
};


#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v1.3

// Collection of lines v1.2

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
            Line* lineToDelete = _all.GetByIndex(i);
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
      int index = FindIndex(line);
      
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

class LineArray : public ILineArray
{
   Line* _array[];
   int _defaultSize;
   Line* _defaultValue;
public:
   LineArray(int size, Line* defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ~LineArray()
   {
      Clear();
   }

   ILineArray* Clear()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            LinesCollection::Delete(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(Line* value)
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

   void Push(Line* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   Line* Pop()
   {
      int size = ArraySize(_array);
      Line* value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   Line* Shift()
   {
      return Remove(0);
   }

   Line* Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, Line* value)
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
   
   ILineArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   Line* Remove(int index)
   {
      int size = ArraySize(_array);
      Line* value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
   
   int Includes(Line* value)
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
#endif
// Int array v1.3


class IntArray : public IIntArray
{
   int _array[];
   int _defaultSize;
   int _defaultValue;
public:
   IntArray(int size, int defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IIntArray* Clear()
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

   void Push(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
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
   
   IIntArray* Slice(int from, int to)
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
// Bool array v1.0
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


class FloatArray : public IFloatArray
{
   double _array[];
   int _defaultSize;
   double _defaultValue;
public:
   FloatArray(int size, double defaultValue)
   {
      _defaultSize = size;
      _defaultValue = defaultValue;
      Clear();
   }

   IFloatArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(double value)
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

   void Push(double value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   double Pop()
   {
      int size = ArraySize(_array);
      double value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   double Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, double value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }

   double Shift()
   {
      return Remove(0);
   }
   
   IFloatArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   double Remove(int index)
   {
      int size = ArraySize(_array);
      double value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(double value)
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
#ifndef BoxArray_IMPL
#define BoxArray_IMPL
// Box array v1.4
// Box array interface v1.1
#ifndef Box_IMPL
#define Box_IMPL

// Box object v1.5

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
   static int GetLeft(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetLeft(); }
   int GetLeft() { return _left; }
   static int GetRight(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetRight(); }
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

class IBoxArray
{
public:
   virtual void Unshift(Box* value) = 0;
   virtual int Size() = 0;
   virtual void Push(Box* value) = 0;
   virtual Box* Pop() = 0;
   virtual Box* Get(int index) = 0;
   virtual void Set(int index, Box* value) = 0;
   virtual IBoxArray* Slice(int from, int to) = 0;
   virtual IBoxArray* Clear() = 0;
   virtual Box* Shift() = 0;
   virtual Box* Remove(int index) = 0;
   virtual int Includes(Box* value) = 0;
};
// Collection of boxes v1.2

#ifndef BoxesCollection_IMPL
#define BoxesCollection_IMPL



class BoxesCollection
{
   string _id;
   Box* _array[];
   static BoxesCollection* _collections[];
   static BoxesCollection* _all;
   static int _max;
public:
   BoxesCollection(string id)
   {
      _id = id;
   }

   ~BoxesCollection()
   {
      ClearItems();
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
            Box* toDelete = _all.GetByIndex(i);
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
int BoxesCollection::_max = 50;
#endif

class BoxArray : public IBoxArray
{
   Box* _array[];
   int _defaultSize;
   Box* _defaultValue;
public:
   BoxArray(int size, Box* defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ~BoxArray()
   {
      Clear();
   }

   IBoxArray* Clear()
   {
      int size = ArraySize(_array);
      int i;
      for (i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            BoxesCollection::Delete(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(Box* value)
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

   void Push(Box* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   Box* Pop()
   {
      int size = ArraySize(_array);
      Box* value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value != NULL && value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   Box* Shift()
   {
      return Remove(0);
   }

   Box* Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, Box* value)
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
   
   IBoxArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   Box* Remove(int index)
   {
      int size = ArraySize(_array);
      Box* value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
   
   int Includes(Box* value)
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
   static void Unshift(IIntArray* array, int value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IFloatArray* array, double value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IStringArray* array, string value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IBoolArray* array, int value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IColorArray* array, uint value) { if (array == NULL) { return; } array.Unshift(value); }
   
   static int Size(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(ILineArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IBoxArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IStringArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IBoolArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IColorArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }

   static int Shift(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static double Shift(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static Line* Shift(ILineArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static Box* Shift(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static string Shift(IStringArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static int Shift(IBoolArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static uint Shift(IColorArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }

   static void Push(IIntArray* array, int value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IFloatArray* array, double value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IStringArray* array, string value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IBoolArray* array, int value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IColorArray* array, uint value) { if (array == NULL) { return; } array.Push(value); }

   static int Pop(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static double Pop(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static Line* Pop(ILineArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static Box* Pop(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static string Pop(IStringArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static int Pop(IBoolArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static uint Pop(IColorArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }

   static int Get(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static double Get(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static Line* Get(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   static Box* Get(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   static string Get(IStringArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   static int Get(IBoolArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static uint Get(IColorArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   
   static void Set(IIntArray* array, int index, int value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IFloatArray* array, int index, double value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(ILineArray* array, int index, Line* value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IBoxArray* array, int index, Box* value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IStringArray* array, int index, string value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IBoolArray* array, int index, int value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IColorArray* array, int index, uint value) { if (array == NULL) { return; } array.Set(index, value); }

   static int Remove(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static double Remove(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static Line* Remove(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }
   static Box* Remove(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }
   static string Remove(IStringArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }
   static int Remove(IBoolArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static uint Remove(IColorArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   
   static int Includes(IIntArray* array, int value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IFloatArray* array, double value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(ILineArray* array, Line* value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IBoxArray* array, Box* value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IStringArray* array, string value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IBoolArray* array, int value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IColorArray* array, uint value) { if (array == NULL) { return -1; } return array.Includes(value); }

   static int PercentRank(IIntArray* array, int index)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return EMPTY_VALUE; }
      int target = array.Get(index);
      if (target == EMPTY_VALUE)
      {
         return EMPTY_VALUE;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         int current = array.Get(i);
         if (current != EMPTY_VALUE && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }
   static double PercentRank(IFloatArray* array, int index)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return EMPTY_VALUE; }
      double target = array.Get(index);
      if (target == EMPTY_VALUE)
      {
         return EMPTY_VALUE;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         double current = array.Get(i);
         if (current != EMPTY_VALUE && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }

   static int Max(IIntArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      int max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (max == EMPTY_VALUE || (current != EMPTY_VALUE && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   static double Max(IFloatArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      double max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double current = array.Get(i);
         if (max == EMPTY_VALUE || (current != EMPTY_VALUE && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   static int Min(IIntArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      int min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (min == EMPTY_VALUE || (current != EMPTY_VALUE && min > current))
         {
            min = current;
         }
      }
      return min;
   }
   static double Min(IFloatArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      double min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double current = array.Get(i);
         if (min == EMPTY_VALUE || (current != EMPTY_VALUE && min > current))
         {
            min = current;
         }
      }
      return min;
   }

   static int Sum(IIntArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      int sum = 0;
      for (int i = 0; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   static double Sum(IFloatArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      double sum = 0;
      for (int i = 0; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   
   static double Stdev(IIntArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      double sum = 0;
      double ssum = 0;
      int size = array.Size();
      if (size < 2)
      {
         return 0;
      }
      for (int i = 0; i < size; i++)
      {
         int value = array.Get(i);
         sum += value;
         ssum += MathPow(value, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
   static double Stdev(IFloatArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      double sum = 0;
      double ssum = 0;
      int size = array.Size();
      if (size < 2)
      {
         return 0;
      }
      for (int i = 0; i < size; i++)
      {
         double value = array.Get(i);
         sum += value;
         ssum += MathPow(value, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
   
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


// Matrix
// v1.0

// Float matrix
// v1.0
// Float martix interface
// v1.0

interface IFloatMatrix
{
public:
   virtual IFloatMatrix* Clear() = 0;
   virtual double Get(int row, int col) = 0;
   virtual void Set(int row, int col, double val) = 0;
};

class FloatMatrix : public IFloatMatrix
{
   int rows;
   int columns;
   double initialValue;
   double values[];
public:
   FloatMatrix(int rows, int columns, double initialValue)
   {
      this.rows = rows;
      this.columns = columns;
      this.initialValue = initialValue;
      Clear();
   }
   
   IFloatMatrix* Clear()
   {
      ArrayResize(values, rows * columns);
      for (int row = 0; row < rows; ++row)
      {
         for (int column = 0; column < columns; ++column)
         {
            values[row * columns + column] = initialValue;
         }
      }
      return &this;
   }
   
   double Get(int row, int col)
   {
      return values[row * columns + col];
   }
   
   void Set(int row, int col, double val)
   {
      values[row * columns + col] = val;
   }
};
// Table matrix
// v1.1
// Table martix interface
// v1.0
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


interface ITableMatrix
{
public:
   virtual ITableMatrix* Clear() = 0;
   virtual Table* Get(int row, int col) = 0;
   virtual void Set(int row, int col, Table* val) = 0;
};


class TableMatrix : public ITableMatrix
{
   int rows;
   int columns;
   Table* initialValue;
   Table* values[];
public:
   TableMatrix(int rows, int columns, Table* initialValue)
   {
      this.rows = rows;
      this.columns = columns;
      this.initialValue = initialValue;
      initialValue.Lock();
      Clear();
   }
   
   ~TableMatrix()
   {
      initialValue.Unlock();
   }
   
   ITableMatrix* Clear()
   {
      ArrayResize(values, rows * columns);
      for (int row = 0; row < rows; ++row)
      {
         for (int column = 0; column < columns; ++column)
         {
            values[row * columns + column] = initialValue;
         }
      }
      return &this;
   }
   
   Table* Get(int row, int col)
   {
      return values[row * columns + col];
   }
   
   void Set(int row, int col, Table* val)
   {
      values[row * columns + col] = val;
   }
};

class Matrix
{
public:
   static double Get(IFloatMatrix* matrix, int row, int col) { if (matrix == NULL) { return EMPTY_VALUE; } return matrix.Get(row, col); }
   static Table* Get(ITableMatrix* matrix, int row, int col) { if (matrix == NULL) { return NULL; } return matrix.Get(row, col); }
   
   static void Set(IFloatMatrix* matrix, int row, int col, double val) { if (matrix == NULL) { return; } matrix.Set(row, col, val); }
   static void Set(ITableMatrix* matrix, int row, int col, Table* val) { if (matrix == NULL) { return; } matrix.Set(row, col, val); }
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
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Stream base v1.0

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public IStream
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
// Float stream v2.3

class FloatStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
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
      return _stream[index] != EMPTY_VALUE;
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
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif
// Pivot high stream v1.3



//Base implementation of stream based on another stream 
//v1.1

class AOnStream : public IStream
{
protected:
   IStream *_source;
   int _references;
public:
   AOnStream(IStream *source)
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
// Simple price stream v1.2

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

// Abstract stream v1.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

class AStream : public IStream
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

class SimplePriceStream : public AStream
{
   PriceType _price;
   int _periodShift;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price, int periodShift = 0)
      :AStream(symbol, timeframe)
   {
      _price = __price;
      _periodShift = periodShift;
   }

   bool GetValue(const int period, double &val)
   {
      ResetLastError();
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift) + iOpen(_symbol, _timeframe, period + _periodShift)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period + _periodShift);
               if (iOpen(_symbol, _timeframe, period + _periodShift) > iClose(_symbol, _timeframe, period + _periodShift))
                  val = (iHigh(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period + _periodShift);
            break;
      }
      if (GetLastError() != ERR_NO_ERROR)
      {
         return false;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};


class PivotHighStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotHighStream(IStream *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceHigh);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   static bool GetValue(const int period, double &val, string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValue(period, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center;
      if (!source.GetValue(period + rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValue(period + i, value))
         {
            return false;
         }
         if (center < value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValue(period + ii + rightBars, value))
         {
            return false;
         }
         if (center < value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center;
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return GetValue(period, val, _source, _leftBars, _rightBars);
   }
};
// Pivot low stream v1.3



class PivotLowStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotLowStream(IStream *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceLow);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   
   static bool GetValue(const int period, double &val, string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValue(period, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center;
      if (!source.GetValue(period + rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValue(period + i, value))
         {
            return false;
         }
         if (center > value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValue(period + ii + rightBars, value))
         {
            return false;
         }
         if (center > value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center;
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return GetValue(period, val, _source, _leftBars, _rightBars);
   }
};
// Collection of labels v1.2

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.5

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   color _color;
   color _textColor;
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
   static void SetXY(Label* label, int x, double y) { if (label == NULL) { return; } label.SetX(x); label.SetY(y); }

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
   
   Label* SetColor(color clr)
   {
      _color = clr;
      return &this;
   }
   
   Label* SetTextColor(color clr)
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
         delete _labels[i];
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
            Label* labelToDelete = _all.GetByIndex(i);
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
   }
   void DeleteLabel(Label* label)
   {
      RemoveLabel(label);
      delete label;
   }
   void Add(Label* label)
   {
      int index = FindIndex(label);
      
      int size = ArraySize(_labels);
      ArrayResize(_labels, size + 1);
      _labels[size] = label;
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
// Custom integer stream v1.1

#ifndef IntStream_IMPL
#define IntStream_IMPL

// Abstract integer stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL
// Integer Stream v.1.0

#ifndef IIntStream_IMPL
#define IIntStream_IMPL

interface IIntStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, int &val) = 0;
};

#endif

class AIntStream : public IIntStream
{
   int _refs;   
public:
   AIntStream()
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

class IntStream : public AIntStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _stream[];
public:
   IntStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, int value)
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

   bool GetValue(const int period, int &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
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
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};
#endif

// Change stream v1.1

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

// v1.0
// Wraps IIntStream and provides IStream

#ifndef IntToFloatStreamWrapper_IMPL
#define IntToFloatStreamWrapper_IMPL
// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL


class AFloatStream : public IStream
{
   int _refs;   
public:
   AFloatStream()
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


class IntToFloatStreamWrapper : public AFloatStream
{
   IIntStream* _source;
public:
   IntToFloatStreamWrapper(IIntStream* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~IntToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   bool GetValue(const int period, double &val)
   {
      int intVal;
      if (!_source.GetValue(period, intVal))
      {
         return false;
      }
      val = intVal;
      return true;
   }
};
#endif

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   ChangeStream(IIntStream* stream, int period = 1)
      :AOnStream(new IntToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double src1, src2;
      if (!_source.GetValue(period, src1) || !_source.GetValue(period + _period, src2))
      {
         return false;
      }
      val = src1 - src2;
      return true;
   }
};

#endif
// str.* functions from Pine Script
// v1.0

class Str
{
public:
   static string ToString(int value, string format)
   {
      if (format == "percent")
      {
         return IntegerToString(value, 2) + "%";
      }
      return IntegerToString(value);
   }
   static string ToString(double value, string format)
   {
      if (format == "percent")
      {
         return DoubleToString(value, 2) + "%";
      }
      return DoubleToString(value);
   }
   static string ToString(double value)
   {
      return DoubleToString(value);
   }
   static string ToString(int value)
   {
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
// syminfo.* functions from Pine Script
// v1.0

class SymInfo
{
public:
   static double Mintick(string symbol)
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   
   static string Ticker()
   {
      return _Symbol;
   }
};
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
};
//Signaler v2.2
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

   void Alert(string message, int position, datetime time)
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

// Linefill object
// v1.0

class LineFill
{
public:
};

input int param1 = 20; // Structure Period
input bool param2 = true; // Structure Response??
input int param3 = 7; // 
input bool param4 = true; // Bullish Structure?????
input color param5 = ColorRGB(8, 236, 126, 0); // 
input color param6 = ColorRGB(8, 236, 126, 0); // 
input bool param7 = true; // Bearish Structure????
input color param8 = ColorRGB(255, 34, 34, 0); // 
input color param9 = ColorRGB(255, 34, 34, 0); // 
input bool param10 = true; // Premium & Discount
input color param11 = AddTransparency(ColorRGB(255, 34, 34, 0), 80); // 
input color param12 = AddTransparency(ColorRGB(8, 236, 126, 0), 80); // 
input string param13 = "Right"; // 
input bool param14 = true; // Ticker ID
input bool param15 = true; // Timeframe
input bool param16 = true; // Probability Percentage
input color param17 = ColorRGB(255, 34, 34, 0); // 
input color param18 = ColorRGB(8, 236, 126, 0); // 
input color param19 = AddTransparency(ColorRGB(255, 34, 34, 0), 80); // 
input color param20 = AddTransparency(ColorRGB(8, 236, 126, 0), 80); // 
input int bars_limit = 100000; // Bars limit
int prd;
int s1;
int resp;
int bull;
uint bull2;
uint bull3;
int bear;
uint bear2;
uint bear3;
int showPD;
uint prem;
uint disc;
string hlloc;
IBoolArray* alert_bool;
IBoolArray* __array1;
int b;
double Up[];
double Up_DEFAULT_VALUE;
double Dn[];
double Dn_DEFAULT_VALUE;
double iUp[];
double iUp_DEFAULT_VALUE;
double iDn[];
double iDn_DEFAULT_VALUE;
IFloatMatrix* vals;
IFloatMatrix* __matrix2;
IStringArray* txt;
IStringArray* __array3;
ITableMatrix* tbl;
ITableMatrix* __matrix4;
FloatStream* highestpivot1Source;
FloatStream* lowestpivot1Source;
double _pos[];
double _pos_DEFAULT_VALUE;
class CreateLabel_iS_fS_s_c_bStream
{
   IIntStream* x;
   IStream* y;
   string txt;
   uint col;
   int z;
   bool _initialized;
public:
   CreateLabel_iS_fS_s_c_bStream(IIntStream* x, IStream* y, string txt, uint col, int z)
   {
      _initialized = false;
      this.x = x;
      x.AddRef();
      this.y = y;
      y.AddRef();
      this.txt = txt;
      this.col = col;
      this.z = z;
   }
   ~CreateLabel_iS_fS_s_c_bStream()
   {
      x.Release();
      y.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Label* &__out1)
   {
      int xValue;
      if (!x.GetValue(pos, xValue)) { xValue = EMPTY_VALUE; }
      double yValue;
      if (!y.GetValue(pos, yValue)) { yValue = EMPTY_VALUE; }
      __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", xValue, yValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor((uint)(EMPTY_VALUE)).SetText(txt).SetTextColor(col).SetStyle((z ? "down" : "up")).SetSize("normal").SetYLoc("price").SetTextAlign("center");
      return true;
   }
};
IntStream* CreateLabel_iS_fS_s_c_b1_param1;
FloatStream* CreateLabel_iS_fS_s_c_b1_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b1;
class CreateLine_iS_fS_fS_cStream
{
   IIntStream* x1;
   IStream* x2;
   IStream* y;
   uint col;
   bool _initialized;
public:
   CreateLine_iS_fS_fS_cStream(IIntStream* x1, IStream* x2, IStream* y, uint col)
   {
      _initialized = false;
      this.x1 = x1;
      x1.AddRef();
      this.x2 = x2;
      x2.AddRef();
      this.y = y;
      y.AddRef();
      this.col = col;
   }
   ~CreateLine_iS_fS_fS_cStream()
   {
      x1.Release();
      x2.Release();
      y.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Line* &__out1)
   {
      int x1Value;
      if (!x1.GetValue(pos, x1Value)) { x1Value = EMPTY_VALUE; }
      double x2Value;
      if (!x2.GetValue(pos, x2Value)) { x2Value = EMPTY_VALUE; }
      double yValue;
      if (!y.GetValue(pos, yValue)) { yValue = EMPTY_VALUE; }
      __out1 = LinesCollection::Create(IndicatorObjPrefix + "line_1_id", x1Value, x2Value, b, yValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(col).SetWidth(1).SetStyle("solid");
      return true;
   }
};
IntStream* CreateLine_iS_fS_fS_c2_param1;
FloatStream* CreateLine_iS_fS_fS_c2_param2;
FloatStream* CreateLine_iS_fS_fS_c2_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c2;
IntStream* CreateLabel_iS_fS_s_c_b3_param1;
FloatStream* CreateLabel_iS_fS_s_c_b3_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b3;
IntStream* CreateLine_iS_fS_fS_c4_param1;
FloatStream* CreateLine_iS_fS_fS_c4_param2;
FloatStream* CreateLine_iS_fS_fS_c4_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c4;
IntStream* CreateLabel_iS_fS_s_c_b5_param1;
FloatStream* CreateLabel_iS_fS_s_c_b5_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b5;
IntStream* CreateLine_iS_fS_fS_c6_param1;
FloatStream* CreateLine_iS_fS_fS_c6_param2;
FloatStream* CreateLine_iS_fS_fS_c6_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c6;
IntStream* CreateLabel_iS_fS_s_c_b7_param1;
FloatStream* CreateLabel_iS_fS_s_c_b7_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b7;
IntStream* CreateLine_iS_fS_fS_c8_param1;
FloatStream* CreateLine_iS_fS_fS_c8_param2;
FloatStream* CreateLine_iS_fS_fS_c8_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c8;
IntStream* CreateLabel_iS_fS_s_c_b9_param1;
FloatStream* CreateLabel_iS_fS_s_c_b9_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b9;
IntStream* CreateLine_iS_fS_fS_c10_param1;
FloatStream* CreateLine_iS_fS_fS_c10_param2;
FloatStream* CreateLine_iS_fS_fS_c10_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c10;
IntStream* CreateLabel_iS_fS_s_c_b11_param1;
FloatStream* CreateLabel_iS_fS_s_c_b11_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b11;
IntStream* CreateLine_iS_fS_fS_c12_param1;
FloatStream* CreateLine_iS_fS_fS_c12_param2;
FloatStream* CreateLine_iS_fS_fS_c12_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c12;
IntStream* change1Source;
ChangeStream* change1;
class Current_iSStream
{
   IIntStream* v;
   bool _initialized;
public:
   Current_iSStream(IIntStream* v)
   {
      _initialized = false;
      this.v = v;
      v.AddRef();
   }
   ~Current_iSStream()
   {
      v.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, string &__out1, double &__out2, double &__out3)
   {
      string str = "";
      double val1 = (double)(NULL);
      double val2 = (double)(NULL);
      int vValue;
      if (!v.GetValue(pos, vValue)) { vValue = EMPTY_VALUE; }
      if ((vValue >= 0))
      {
         if ((vValue == 1))
         {
            str = "SMS: ";
            val1 = Matrix::Get(vals, 0, 1);
            val2 = Matrix::Get(vals, 0, 3);
         }
         else if ((vValue == 2))
         {
            str = "BMS: ";
            val1 = Matrix::Get(vals, 1, 1);
            val2 = Matrix::Get(vals, 1, 3);
         }
         else if ((vValue > 2))
         {
            str = "BMS: ";
            val1 = Matrix::Get(vals, 2, 1);
            val2 = Matrix::Get(vals, 2, 3);
         }
      }
      else if ((vValue <= 0))
      {
         if ((vValue == (-1)))
         {
            str = "SMS: ";
            val1 = Matrix::Get(vals, 3, 1);
            val2 = Matrix::Get(vals, 3, 3);
         }
         else if ((vValue == (-2)))
         {
            str = "BMS: ";
            val1 = Matrix::Get(vals, 4, 1);
            val2 = Matrix::Get(vals, 4, 3);
         }
         else if ((vValue < (-2)))
         {
            str = "BMS: ";
            val1 = Matrix::Get(vals, 5, 1);
            val2 = Matrix::Get(vals, 5, 3);
         }
      }
      __out1 = str;
      __out2 = val1;
      __out3 = val2;
      return true;
   }
};
IntStream* Current_iS13_param1;
Current_iSStream* Current_iS13;
IStringArray* __array5;
IStringArray* __array6;
Signaler* _signaler1;
Line* hi;
Line* lo;
LineFill* fill;
Box* premium;
Box* discount;
Box* mid;
Label* prob1;
Label* prob2;
IStringArray* __array7;
IColorArray* __array8;

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

string GenerateIndicatorPrefix(const string target)
{
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
   IndicatorBuffers(5);
   int id = 0;
   prd = param1;
   s1 = param2;
   resp = param3;
   bull = param4;
   bull2 = param5;
   bull3 = param6;
   bear = param7;
   bear2 = param8;
   bear3 = param9;
   showPD = param10;
   prem = param11;
   disc = param12;
   hlloc = param13;
   highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   bear2 = param17;
   bull2 = param18;
   prem = param19;
   disc = param20;
   LabelsCollection::SetMaxLabels(500);
   LinesCollection::SetMaxLines(500);
   BoxesCollection::SetMaxBoxes(50);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Smart Money Concepts Probability (Expo)");
   __array1 = new BoolArray(0, NULL);
   SetIndexBuffer(id++, Up);
   SetIndexBuffer(id++, Dn);
   SetIndexBuffer(id++, iUp);
   SetIndexBuffer(id++, iDn);
   __matrix2 = new FloatMatrix(9, 4, 0.0);
   __array3 = new StringArray(2, "");
   __matrix4 = new TableMatrix(1, 1, TableManager::Create(IndicatorObjPrefix, "1", "top_right", 2, 3).SetBorderWidth((-2)).SetBorderColor(ChartGetInteger(0, CHART_COLOR_BACKGROUND)).SetFrameColor(AddTransparency(Gray, 50)).SetFrameWidth(3));
   SetIndexBuffer(id++, _pos);
   CreateLabel_iS_fS_s_c_b1_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b1_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b1 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b1_param1, CreateLabel_iS_fS_s_c_b1_param2, "CHoCH", bull3, true);
   id = CreateLabel_iS_fS_s_c_b1.Init(id);
   CreateLine_iS_fS_fS_c2_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c2_param1, CreateLine_iS_fS_fS_c2_param2, CreateLine_iS_fS_fS_c2_param3, bull2);
   id = CreateLine_iS_fS_fS_c2.Init(id);
   CreateLabel_iS_fS_s_c_b3_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b3_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b3 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b3_param1, CreateLabel_iS_fS_s_c_b3_param2, "SMS", bull3, true);
   id = CreateLabel_iS_fS_s_c_b3.Init(id);
   CreateLine_iS_fS_fS_c4_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c4_param1, CreateLine_iS_fS_fS_c4_param2, CreateLine_iS_fS_fS_c4_param3, bull2);
   id = CreateLine_iS_fS_fS_c4.Init(id);
   CreateLabel_iS_fS_s_c_b5_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b5_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b5 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b5_param1, CreateLabel_iS_fS_s_c_b5_param2, "BMS", bull3, true);
   id = CreateLabel_iS_fS_s_c_b5.Init(id);
   CreateLine_iS_fS_fS_c6_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c6_param1, CreateLine_iS_fS_fS_c6_param2, CreateLine_iS_fS_fS_c6_param3, bull2);
   id = CreateLine_iS_fS_fS_c6.Init(id);
   CreateLabel_iS_fS_s_c_b7_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b7_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b7 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b7_param1, CreateLabel_iS_fS_s_c_b7_param2, "CHoCH", bear3, false);
   id = CreateLabel_iS_fS_s_c_b7.Init(id);
   CreateLine_iS_fS_fS_c8_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c8_param1, CreateLine_iS_fS_fS_c8_param2, CreateLine_iS_fS_fS_c8_param3, bear2);
   id = CreateLine_iS_fS_fS_c8.Init(id);
   CreateLabel_iS_fS_s_c_b9_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b9_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b9 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b9_param1, CreateLabel_iS_fS_s_c_b9_param2, "SMS", bear3, false);
   id = CreateLabel_iS_fS_s_c_b9.Init(id);
   CreateLine_iS_fS_fS_c10_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c10_param1, CreateLine_iS_fS_fS_c10_param2, CreateLine_iS_fS_fS_c10_param3, bear2);
   id = CreateLine_iS_fS_fS_c10.Init(id);
   CreateLabel_iS_fS_s_c_b11_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b11_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b11 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b11_param1, CreateLabel_iS_fS_s_c_b11_param2, "BMS", bear3, false);
   id = CreateLabel_iS_fS_s_c_b11.Init(id);
   CreateLine_iS_fS_fS_c12_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c12_param1, CreateLine_iS_fS_fS_c12_param2, CreateLine_iS_fS_fS_c12_param3, bear2);
   id = CreateLine_iS_fS_fS_c12.Init(id);
   Current_iS13_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Current_iS13 = new Current_iSStream(Current_iS13_param1);
   id = Current_iS13.Init(id);
   __array5 = new StringArray(0, NULL);
   __array6 = new StringArray(0, NULL);
   _signaler1 = new Signaler("once_per_bar_close");
   __array7 = new StringArray(0, NULL);
   __array8 = new ColorArray(0, NULL);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete __array1;
   delete __matrix2;
   delete __array3;
   delete __matrix4;
   highestpivot1Source.Release();
   lowestpivot1Source.Release();
   CreateLabel_iS_fS_s_c_b1_param1.Release();
   CreateLabel_iS_fS_s_c_b1_param2.Release();
   delete CreateLabel_iS_fS_s_c_b1;
   CreateLine_iS_fS_fS_c2_param1.Release();
   CreateLine_iS_fS_fS_c2_param2.Release();
   CreateLine_iS_fS_fS_c2_param3.Release();
   delete CreateLine_iS_fS_fS_c2;
   CreateLabel_iS_fS_s_c_b3_param1.Release();
   CreateLabel_iS_fS_s_c_b3_param2.Release();
   delete CreateLabel_iS_fS_s_c_b3;
   CreateLine_iS_fS_fS_c4_param1.Release();
   CreateLine_iS_fS_fS_c4_param2.Release();
   CreateLine_iS_fS_fS_c4_param3.Release();
   delete CreateLine_iS_fS_fS_c4;
   CreateLabel_iS_fS_s_c_b5_param1.Release();
   CreateLabel_iS_fS_s_c_b5_param2.Release();
   delete CreateLabel_iS_fS_s_c_b5;
   CreateLine_iS_fS_fS_c6_param1.Release();
   CreateLine_iS_fS_fS_c6_param2.Release();
   CreateLine_iS_fS_fS_c6_param3.Release();
   delete CreateLine_iS_fS_fS_c6;
   CreateLabel_iS_fS_s_c_b7_param1.Release();
   CreateLabel_iS_fS_s_c_b7_param2.Release();
   delete CreateLabel_iS_fS_s_c_b7;
   CreateLine_iS_fS_fS_c8_param1.Release();
   CreateLine_iS_fS_fS_c8_param2.Release();
   CreateLine_iS_fS_fS_c8_param3.Release();
   delete CreateLine_iS_fS_fS_c8;
   CreateLabel_iS_fS_s_c_b9_param1.Release();
   CreateLabel_iS_fS_s_c_b9_param2.Release();
   delete CreateLabel_iS_fS_s_c_b9;
   CreateLine_iS_fS_fS_c10_param1.Release();
   CreateLine_iS_fS_fS_c10_param2.Release();
   CreateLine_iS_fS_fS_c10_param3.Release();
   delete CreateLine_iS_fS_fS_c10;
   CreateLabel_iS_fS_s_c_b11_param1.Release();
   CreateLabel_iS_fS_s_c_b11_param2.Release();
   delete CreateLabel_iS_fS_s_c_b11;
   CreateLine_iS_fS_fS_c12_param1.Release();
   CreateLine_iS_fS_fS_c12_param2.Release();
   CreateLine_iS_fS_fS_c12_param3.Release();
   delete CreateLine_iS_fS_fS_c12;
   change1Source.Release();
   change1.Release();
   Current_iS13_param1.Release();
   delete Current_iS13;
   delete __array5;
   delete __array6;
   delete __array7;
   delete __array8;
   TableManager::Clear(true);
   LabelsCollection::Clear(true);
   LinesCollection::Clear(true);
   delete _signaler1;
   BoxesCollection::Clear(true);
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
      TableManager::Clear();
      LabelsCollection::Clear();
      LinesCollection::Clear();
      BoxesCollection::Clear();
      alert_bool = __array1.Clear().Push(param14).Push(param15).Push(param16);
      Up_DEFAULT_VALUE = (double)(NULL);
      ArrayInitialize(Up, Up_DEFAULT_VALUE);
      Dn_DEFAULT_VALUE = (double)(NULL);
      ArrayInitialize(Dn, Dn_DEFAULT_VALUE);
      iUp_DEFAULT_VALUE = (int)(NULL);
      ArrayInitialize(iUp, iUp_DEFAULT_VALUE);
      iDn_DEFAULT_VALUE = (int)(NULL);
      ArrayInitialize(iDn, iDn_DEFAULT_VALUE);
      vals = __matrix2.Clear();
      txt = __array3.Clear();
      tbl = __matrix4.Clear();
      highestpivot1Source.Init();
      lowestpivot1Source.Init();
      _pos_DEFAULT_VALUE = 0;
      ArrayInitialize(_pos, _pos_DEFAULT_VALUE);
      CreateLabel_iS_fS_s_c_b1_param1.Init();
      CreateLabel_iS_fS_s_c_b1_param2.Init();
      CreateLabel_iS_fS_s_c_b1.Clear();
      CreateLine_iS_fS_fS_c2_param1.Init();
      CreateLine_iS_fS_fS_c2_param2.Init();
      CreateLine_iS_fS_fS_c2_param3.Init();
      CreateLine_iS_fS_fS_c2.Clear();
      CreateLabel_iS_fS_s_c_b3_param1.Init();
      CreateLabel_iS_fS_s_c_b3_param2.Init();
      CreateLabel_iS_fS_s_c_b3.Clear();
      CreateLine_iS_fS_fS_c4_param1.Init();
      CreateLine_iS_fS_fS_c4_param2.Init();
      CreateLine_iS_fS_fS_c4_param3.Init();
      CreateLine_iS_fS_fS_c4.Clear();
      CreateLabel_iS_fS_s_c_b5_param1.Init();
      CreateLabel_iS_fS_s_c_b5_param2.Init();
      CreateLabel_iS_fS_s_c_b5.Clear();
      CreateLine_iS_fS_fS_c6_param1.Init();
      CreateLine_iS_fS_fS_c6_param2.Init();
      CreateLine_iS_fS_fS_c6_param3.Init();
      CreateLine_iS_fS_fS_c6.Clear();
      CreateLabel_iS_fS_s_c_b7_param1.Init();
      CreateLabel_iS_fS_s_c_b7_param2.Init();
      CreateLabel_iS_fS_s_c_b7.Clear();
      CreateLine_iS_fS_fS_c8_param1.Init();
      CreateLine_iS_fS_fS_c8_param2.Init();
      CreateLine_iS_fS_fS_c8_param3.Init();
      CreateLine_iS_fS_fS_c8.Clear();
      CreateLabel_iS_fS_s_c_b9_param1.Init();
      CreateLabel_iS_fS_s_c_b9_param2.Init();
      CreateLabel_iS_fS_s_c_b9.Clear();
      CreateLine_iS_fS_fS_c10_param1.Init();
      CreateLine_iS_fS_fS_c10_param2.Init();
      CreateLine_iS_fS_fS_c10_param3.Init();
      CreateLine_iS_fS_fS_c10.Clear();
      CreateLabel_iS_fS_s_c_b11_param1.Init();
      CreateLabel_iS_fS_s_c_b11_param2.Init();
      CreateLabel_iS_fS_s_c_b11.Clear();
      CreateLine_iS_fS_fS_c12_param1.Init();
      CreateLine_iS_fS_fS_c12_param2.Init();
      CreateLine_iS_fS_fS_c12_param3.Init();
      CreateLine_iS_fS_fS_c12.Clear();
      change1Source.Init();
      Current_iS13_param1.Init();
      Current_iS13.Clear();
      hi = LinesCollection::Create(IndicatorObjPrefix + "line_2_id", EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, 0, true).SetColor(bear2).SetWidth(1).SetStyle("solid");
      lo = LinesCollection::Create(IndicatorObjPrefix + "line_3_id", EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, 0, true).SetColor(bull2).SetWidth(1).SetStyle("solid");
      fill = NULL;
      premium = BoxesCollection::Create(IndicatorObjPrefix + "box_1_id", EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, 0, true)
         .SetBgColor(prem)
         .SetBorderColor(EMPTY_VALUE)
         .SetExtend("none");
      discount = BoxesCollection::Create(IndicatorObjPrefix + "box_2_id", EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, 0, true)
         .SetBgColor(disc)
         .SetBorderColor(EMPTY_VALUE)
         .SetExtend("none");
      mid = BoxesCollection::Create(IndicatorObjPrefix + "box_3_id", EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, EMPTY_VALUE, 0, true)
         .SetBgColor(AddTransparency(Gray, 80))
         .SetBorderColor(EMPTY_VALUE)
         .SetExtend("none");
      prob1 = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", EMPTY_VALUE, EMPTY_VALUE, time[0], true).SetColor((uint)(EMPTY_VALUE)).SetText(NULL).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle("left").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      prob2 = LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", EMPTY_VALUE, EMPTY_VALUE, time[0], true).SetColor((uint)(EMPTY_VALUE)).SetText(NULL).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle("left").SetSize("normal").SetYLoc("price").SetTextAlign("center");
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
      Up[pos] = pos < (rates_total - 1) ? Up[pos + 1] : (double)(NULL);
      Dn[pos] = pos < (rates_total - 1) ? Dn[pos + 1] : (double)(NULL);
      iUp[pos] = pos < (rates_total - 1) ? iUp[pos + 1] : (int)(NULL);
      iDn[pos] = pos < (rates_total - 1) ? iDn[pos + 1] : (int)(NULL);
      _pos[pos] = pos < (rates_total - 1) ? _pos[pos + 1] : 0;
      string t1 = "Set the pivot period";
      string t2 = "Set the response period. A low value returns a short-term structure and a high value returns a long-term structure. If you disable this option the pivot length above will be used.";
      b = ((rates_total - 1) - pos);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(Up, pos, SafeMathMax(Up[pos + 1], high[pos]), Up_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(Dn, pos, SafeMathMin(Dn[pos + 1], low[pos]), Dn_DEFAULT_VALUE);
      highestpivot1Source.SetValue(pos, high[pos]);
      double highestpivot1Value;
      if (!PivotHighStream::GetValue(pos, highestpivot1Value, highestpivot1Source, prd, prd)) { highestpivot1Value = EMPTY_VALUE; }
      double pvtHi = highestpivot1Value;
      lowestpivot1Source.SetValue(pos, low[pos]);
      double lowestpivot1Value;
      if (!PivotLowStream::GetValue(pos, lowestpivot1Value, lowestpivot1Source, prd, prd)) { lowestpivot1Value = EMPTY_VALUE; }
      double pvtLo = lowestpivot1Value;
      if (NumberToBool(pvtHi))
      {
         SetStream(Up, pos, pvtHi, Up_DEFAULT_VALUE);
      }
      if (NumberToBool(pvtLo))
      {
         SetStream(Dn, pos, pvtLo, Dn_DEFAULT_VALUE);
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (SafeGreater(Up[pos], Up[pos + 1]))
      {
         SetStream(iUp, pos, b, iUp_DEFAULT_VALUE);
         if (pos + 1 > (rates_total - 1)) { continue; }
         int centerBull = SafeMathRound(SafeDivide((SafePlus(iUp[pos + 1], b)), 2));
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + (s1 ? resp : prd) > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + (s1 ? resp : prd) > (rates_total - 1)) { continue; }
         if ((_pos[pos] <= 0))
         {
            if (bull)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b1_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b1_param2.SetValue(pos, Up[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b1Value;
               if (!CreateLabel_iS_fS_s_c_b1.GetValue(pos, CreateLabel_iS_fS_s_c_b1Value)) { CreateLabel_iS_fS_s_c_b1Value = NULL; }
               CreateLabel_iS_fS_s_c_b1Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c2_param1.SetValue(pos, iUp[pos + 1]);
               CreateLine_iS_fS_fS_c2_param2.SetValue(pos, Up[pos + 1]);
               CreateLine_iS_fS_fS_c2_param3.SetValue(pos, Up[pos + 1]);
               Line* CreateLine_iS_fS_fS_c2Value;
               if (!CreateLine_iS_fS_fS_c2.GetValue(pos, CreateLine_iS_fS_fS_c2Value)) { CreateLine_iS_fS_fS_c2Value = NULL; }
               CreateLine_iS_fS_fS_c2Value;
            }
            SetStream(_pos, pos, 1, _pos_DEFAULT_VALUE);
            Matrix::Set(vals, 6, 0, SafePlus(Matrix::Get(vals, 6, 0), 1));
         }
         else if ((_pos[pos] == 1) && SafeGreater(Up[pos], Up[pos + 1]) && (Up[pos + 1] == Up[pos + (s1 ? resp : prd)]))
         {
            if (bull)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b3_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b3_param2.SetValue(pos, Up[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b3Value;
               if (!CreateLabel_iS_fS_s_c_b3.GetValue(pos, CreateLabel_iS_fS_s_c_b3Value)) { CreateLabel_iS_fS_s_c_b3Value = NULL; }
               CreateLabel_iS_fS_s_c_b3Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c4_param1.SetValue(pos, iUp[pos + 1]);
               CreateLine_iS_fS_fS_c4_param2.SetValue(pos, Up[pos + 1]);
               CreateLine_iS_fS_fS_c4_param3.SetValue(pos, Up[pos + 1]);
               Line* CreateLine_iS_fS_fS_c4Value;
               if (!CreateLine_iS_fS_fS_c4.GetValue(pos, CreateLine_iS_fS_fS_c4Value)) { CreateLine_iS_fS_fS_c4Value = NULL; }
               CreateLine_iS_fS_fS_c4Value;
            }
            SetStream(_pos, pos, 2, _pos_DEFAULT_VALUE);
            Matrix::Set(vals, 6, 1, SafePlus(Matrix::Get(vals, 6, 1), 1));
         }
         else if ((_pos[pos] > 1) && SafeGreater(Up[pos], Up[pos + 1]) && (Up[pos + 1] == Up[pos + (s1 ? resp : prd)]))
         {
            if (bull)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b5_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b5_param2.SetValue(pos, Up[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b5Value;
               if (!CreateLabel_iS_fS_s_c_b5.GetValue(pos, CreateLabel_iS_fS_s_c_b5Value)) { CreateLabel_iS_fS_s_c_b5Value = NULL; }
               CreateLabel_iS_fS_s_c_b5Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c6_param1.SetValue(pos, iUp[pos + 1]);
               CreateLine_iS_fS_fS_c6_param2.SetValue(pos, Up[pos + 1]);
               CreateLine_iS_fS_fS_c6_param3.SetValue(pos, Up[pos + 1]);
               Line* CreateLine_iS_fS_fS_c6Value;
               if (!CreateLine_iS_fS_fS_c6.GetValue(pos, CreateLine_iS_fS_fS_c6Value)) { CreateLine_iS_fS_fS_c6Value = NULL; }
               CreateLine_iS_fS_fS_c6Value;
            }
            SetStream(_pos, pos, _pos[pos] + 1, _pos_DEFAULT_VALUE);
            Matrix::Set(vals, 6, 2, SafePlus(Matrix::Get(vals, 6, 2), 1));
         }
      }
      else if (SafeLess(Up[pos], Up[pos + 1]))
      {
         SetStream(iUp, pos, b - prd, iUp_DEFAULT_VALUE);
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (SafeLess(Dn[pos], Dn[pos + 1]))
      {
         SetStream(iDn, pos, b, iDn_DEFAULT_VALUE);
         if (pos + 1 > (rates_total - 1)) { continue; }
         int centerBear = SafeMathRound(SafeDivide((SafePlus(iDn[pos + 1], b)), 2));
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + (s1 ? resp : prd) > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + (s1 ? resp : prd) > (rates_total - 1)) { continue; }
         if ((_pos[pos] >= 0))
         {
            if (bear)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b7_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b7_param2.SetValue(pos, Dn[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b7Value;
               if (!CreateLabel_iS_fS_s_c_b7.GetValue(pos, CreateLabel_iS_fS_s_c_b7Value)) { CreateLabel_iS_fS_s_c_b7Value = NULL; }
               CreateLabel_iS_fS_s_c_b7Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c8_param1.SetValue(pos, iDn[pos + 1]);
               CreateLine_iS_fS_fS_c8_param2.SetValue(pos, Dn[pos + 1]);
               CreateLine_iS_fS_fS_c8_param3.SetValue(pos, Dn[pos + 1]);
               Line* CreateLine_iS_fS_fS_c8Value;
               if (!CreateLine_iS_fS_fS_c8.GetValue(pos, CreateLine_iS_fS_fS_c8Value)) { CreateLine_iS_fS_fS_c8Value = NULL; }
               CreateLine_iS_fS_fS_c8Value;
            }
            SetStream(_pos, pos, (-1), _pos_DEFAULT_VALUE);
            Matrix::Set(vals, 7, 0, SafePlus(Matrix::Get(vals, 7, 0), 1));
         }
         else if ((_pos[pos] == (-1)) && SafeLess(Dn[pos], Dn[pos + 1]) && (Dn[pos + 1] == Dn[pos + (s1 ? resp : prd)]))
         {
            if (bear)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b9_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b9_param2.SetValue(pos, Dn[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b9Value;
               if (!CreateLabel_iS_fS_s_c_b9.GetValue(pos, CreateLabel_iS_fS_s_c_b9Value)) { CreateLabel_iS_fS_s_c_b9Value = NULL; }
               CreateLabel_iS_fS_s_c_b9Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c10_param1.SetValue(pos, iDn[pos + 1]);
               CreateLine_iS_fS_fS_c10_param2.SetValue(pos, Dn[pos + 1]);
               CreateLine_iS_fS_fS_c10_param3.SetValue(pos, Dn[pos + 1]);
               Line* CreateLine_iS_fS_fS_c10Value;
               if (!CreateLine_iS_fS_fS_c10.GetValue(pos, CreateLine_iS_fS_fS_c10Value)) { CreateLine_iS_fS_fS_c10Value = NULL; }
               CreateLine_iS_fS_fS_c10Value;
            }
            SetStream(_pos, pos, (-2), _pos_DEFAULT_VALUE);
            Matrix::Set(vals, 7, 1, SafePlus(Matrix::Get(vals, 7, 1), 1));
         }
         else if ((_pos[pos] < (-1)) && SafeLess(Dn[pos], Dn[pos + 1]) && (Dn[pos + 1] == Dn[pos + (s1 ? resp : prd)]))
         {
            if (bear)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b11_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b11_param2.SetValue(pos, Dn[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b11Value;
               if (!CreateLabel_iS_fS_s_c_b11.GetValue(pos, CreateLabel_iS_fS_s_c_b11Value)) { CreateLabel_iS_fS_s_c_b11Value = NULL; }
               CreateLabel_iS_fS_s_c_b11Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c12_param1.SetValue(pos, iDn[pos + 1]);
               CreateLine_iS_fS_fS_c12_param2.SetValue(pos, Dn[pos + 1]);
               CreateLine_iS_fS_fS_c12_param3.SetValue(pos, Dn[pos + 1]);
               Line* CreateLine_iS_fS_fS_c12Value;
               if (!CreateLine_iS_fS_fS_c12.GetValue(pos, CreateLine_iS_fS_fS_c12Value)) { CreateLine_iS_fS_fS_c12Value = NULL; }
               CreateLine_iS_fS_fS_c12Value;
            }
            SetStream(_pos, pos, _pos[pos] - 1, _pos_DEFAULT_VALUE);
            Matrix::Set(vals, 7, 2, SafePlus(Matrix::Get(vals, 7, 2), 1));
         }
      }
      else if (SafeGreater(Dn[pos], Dn[pos + 1]))
      {
         SetStream(iDn, pos, b - prd, iDn_DEFAULT_VALUE);
      }
      change1Source.SetValue(pos, _pos[pos]);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      if (NumberToBool(change1Value))
      {
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (((_pos[pos] > 0) && SafeGreater(_pos[pos + 1], 0) || (_pos[pos] < 0) && SafeLess(_pos[pos + 1], 0)))
         {
            if (SafeLess(Matrix::Get(vals, 8, 0), Matrix::Get(vals, 8, 1)))
            {
               Matrix::Set(vals, 8, 2, SafePlus(Matrix::Get(vals, 8, 2), 1));
            }
            else
            {
               Matrix::Set(vals, 8, 3, SafePlus(Matrix::Get(vals, 8, 3), 1));
            }
         }
         else
         {
            if (SafeGreater(Matrix::Get(vals, 8, 0), Matrix::Get(vals, 8, 1)))
            {
               Matrix::Set(vals, 8, 2, SafePlus(Matrix::Get(vals, 8, 2), 1));
            }
            else
            {
               Matrix::Set(vals, 8, 3, SafePlus(Matrix::Get(vals, 8, 3), 1));
            }
         }
         double buC0 = Matrix::Get(vals, 0, 0);
         double buC1 = Matrix::Get(vals, 0, 2);
         double buS0 = Matrix::Get(vals, 1, 0);
         double buS1 = Matrix::Get(vals, 1, 2);
         double buB0 = Matrix::Get(vals, 2, 0);
         double buB1 = Matrix::Get(vals, 2, 2);
         double beC0 = Matrix::Get(vals, 3, 0);
         double beC1 = Matrix::Get(vals, 3, 2);
         double beS0 = Matrix::Get(vals, 4, 0);
         double beS1 = Matrix::Get(vals, 4, 2);
         double beB0 = Matrix::Get(vals, 5, 0);
         double beB1 = Matrix::Get(vals, 5, 2);
         double tbuC = Matrix::Get(vals, 6, 0);
         double tbuS = Matrix::Get(vals, 6, 1);
         double tbuB = Matrix::Get(vals, 6, 2);
         double tbeC = Matrix::Get(vals, 7, 0);
         double tbeS = Matrix::Get(vals, 7, 1);
         double tbeB = Matrix::Get(vals, 7, 2);
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((((_pos[pos + 1] == 1) || (_pos[pos + 1] == 0))) && (_pos[pos] < 0))
         {
            Matrix::Set(vals, 0, 0, SafePlus(buC0, 1));
            Matrix::Set(vals, 0, 1, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(buC0, 1)), tbuC)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((((_pos[pos + 1] == 1) || (_pos[pos + 1] == 0))) && (_pos[pos] == 2))
         {
            Matrix::Set(vals, 0, 2, SafePlus(buC1, 1));
            Matrix::Set(vals, 0, 3, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(buC1, 1)), tbuC)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((_pos[pos + 1] == 2) && (_pos[pos] < 0))
         {
            Matrix::Set(vals, 1, 0, SafePlus(buS0, 1));
            Matrix::Set(vals, 1, 1, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(buS0, 1)), tbuS)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((_pos[pos + 1] == 2) && (_pos[pos] > 2))
         {
            Matrix::Set(vals, 1, 2, SafePlus(buS1, 1));
            Matrix::Set(vals, 1, 3, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(buS1, 1)), tbuS)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (SafeGreater(_pos[pos + 1], 2) && (_pos[pos] < 0))
         {
            Matrix::Set(vals, 2, 0, SafePlus(buB0, 1));
            Matrix::Set(vals, 2, 1, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(buB0, 1)), tbuB)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (SafeGreater(_pos[pos + 1], 2) && SafeGreater(_pos[pos], _pos[pos + 1]))
         {
            Matrix::Set(vals, 2, 2, SafePlus(buB1, 1));
            Matrix::Set(vals, 2, 3, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(buB1, 1)), tbuB)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((((_pos[pos + 1] == (-1)) || (_pos[pos + 1] == 0))) && (_pos[pos] > 0))
         {
            Matrix::Set(vals, 3, 0, SafePlus(beC0, 1));
            Matrix::Set(vals, 3, 1, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(beC0, 1)), tbeC)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((((_pos[pos + 1] == (-1)) || (_pos[pos + 1] == 0))) && (_pos[pos] == (-2)))
         {
            Matrix::Set(vals, 3, 2, SafePlus(beC1, 1));
            Matrix::Set(vals, 3, 3, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(beC1, 1)), tbeC)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((_pos[pos + 1] == (-2)) && (_pos[pos] > 0))
         {
            Matrix::Set(vals, 4, 0, SafePlus(beS0, 1));
            Matrix::Set(vals, 4, 1, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(beS0, 1)), tbeS)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((_pos[pos + 1] == (-2)) && (_pos[pos] < (-2)))
         {
            Matrix::Set(vals, 4, 2, SafePlus(beS1, 1));
            Matrix::Set(vals, 4, 3, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(beS1, 1)), tbeS)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (SafeLess(_pos[pos + 1], (-2)) && (_pos[pos] > 0))
         {
            Matrix::Set(vals, 5, 0, SafePlus(beB0, 1));
            Matrix::Set(vals, 5, 1, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(beB0, 1)), tbeB)), 100), 2));
         }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (SafeLess(_pos[pos + 1], (-2)) && SafeLess(_pos[pos], _pos[pos + 1]))
         {
            Matrix::Set(vals, 5, 2, SafePlus(beB1, 1));
            Matrix::Set(vals, 5, 3, SafeMathRound(SafeMultiply((SafeDivide((SafePlus(beB1, 1)), tbeB)), 100), 2));
         }
         Current_iS13_param1.SetValue(pos, _pos[pos]);
         string Current_iS13Value1;
         double Current_iS13Value2;
         double Current_iS13Value3;
         if (!Current_iS13.GetValue(pos, Current_iS13Value1, Current_iS13Value2, Current_iS13Value3)) { Current_iS13Value1 = NULL; Current_iS13Value2 = EMPTY_VALUE; Current_iS13Value3 = EMPTY_VALUE; }
         string str = Current_iS13Value1;
         double val1 = Current_iS13Value2;
         double val2 = Current_iS13Value3;
         Array::Set(txt, 0, SafePlus("CHoCH: ", Str::ToString(val1, "percent")));
         Array::Set(txt, 1, SafePlus(str, Str::ToString(val2, "percent")));
         Matrix::Set(vals, 8, 0, val1);
         Matrix::Set(vals, 8, 1, val2);
         if (Array::Includes(alert_bool, true))
         {
            string st1 = SymInfo::Ticker();
            string st2 = Timeframe::Period();
            string st3 = Str::ToString(Array::Join(txt, "\n"));
            IStringArray* str_vals = __array5.Clear().Push(st1).Push(st2).Push(st3);
            IStringArray* output = __array6.Clear();
            int for1_from = 0;
            int for1_to = SafeMinus(Array::Size(alert_bool), 1);
            bool for1_forward = for1_from <= for1_to;
            int for1_step = 1 * (for1_forward ? 1 : -1);
            if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { continue; }
            for (int x = for1_from; (for1_forward ? x <= for1_to : x >= for1_to); x += for1_step)
            {
               if (Array::Get(alert_bool, x))
               {
                  Array::Push(output, Array::Get(str_vals, x));
               }
            }
            _signaler1.Alert(Array::Join(output, "\n"), pos, time[pos]);
         }
      }
      double PremiumTop = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .1));
      double PremiumBot = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .25));
      double DiscountTop = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .25));
      double DiscountBot = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .1));
      double MidTop = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .45));
      double MidBot = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .45));
      if ((pos == 0) && showPD)
      {
         int loc = ((hlloc == "Left") ? SafeMathMin(iUp[pos], iDn[pos]) : SafeMathMax(iUp[pos], iDn[pos]));
         Line::SetXY1(hi, loc, Up[pos]);
         Line::SetXY2(hi, b, Up[pos]);
         Line::SetXY1(lo, loc, Dn[pos]);
         Line::SetXY2(lo, b, Dn[pos]);
         Box::SetLeftTop(premium, loc, PremiumTop);
         Box::SetRightBottom(premium, b, PremiumBot);
         Box::SetLeftTop(discount, loc, DiscountTop);
         Box::SetRightBottom(discount, b, DiscountBot);
         Box::SetLeftTop(mid, loc, MidTop);
         Box::SetRightBottom(mid, b, MidBot);
      }
      if ((pos == 0))
      {
         string str1 = ((_pos[pos] < 0) ? Array::Get(txt, 0) : Array::Get(txt, 1));
         string str2 = ((_pos[pos] > 0) ? Array::Get(txt, 0) : Array::Get(txt, 1));
         Label::SetXY(prob1, b, Up[pos]);
         Label::SetText(prob1, str1);
         Label::SetXY(prob2, b, Dn[pos]);
         Label::SetText(prob2, str2);
      }
      if ((pos == 0))
      {
         double W = Matrix::Get(vals, 8, 2);
         double L = Matrix::Get(vals, 8, 3);
         double WR = SafeMathRound(SafeMultiply(SafeDivide(W, (SafePlus(W, L))), 100), 2);
         IStringArray* tbl_vals = __array7.Clear().Push(SafePlus("WIN: ", Str::ToString(W))).Push(SafePlus("LOSS: ", Str::ToString(L))).Push(SafePlus("Profitability: ", Str::ToString(WR, "percent")));
         IColorArray* tbl_col = __array8.Clear().Push(Green).Push(Red).Push(ChartGetInteger(0, CHART_COLOR_FOREGROUND));
         int for2_from = 0;
         int for2_to = 2;
         bool for2_forward = for2_from <= for2_to;
         int for2_step = 1 * (for2_forward ? 1 : -1);
         if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { continue; }
         for (int i = for2_from; (for2_forward ? i <= for2_to : i >= for2_to); i += for2_step)
         {
            Table::CellText(Matrix::Get(tbl, 0, 0), 0, i, Array::Get(tbl_vals, i));
            Table::CellTextColor(Matrix::Get(tbl, 0, 0), 0, i, Array::Get(tbl_col, i));
            Table::CellTextSize(Matrix::Get(tbl, 0, 0), 0, i, "auto");
            Table::CellTextHAlign(Matrix::Get(tbl, 0, 0), 0, i, "center");
            Table::CellBGColor(Matrix::Get(tbl, 0, 0), 0, i, ChartGetInteger(0, CHART_COLOR_BACKGROUND));
         }
      }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   TableManager::Redraw();
   LabelsCollection::Redraw();
   LinesCollection::Redraw();
   BoxesCollection::Redraw();
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 