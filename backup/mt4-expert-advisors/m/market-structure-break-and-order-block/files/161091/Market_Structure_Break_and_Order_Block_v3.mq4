/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Market_Structure_Break_and_Order_Block_v3
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160983#p160983
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"

#property strict
#property indicator_chart_window
#property indicator_buffers 4

#define ColorRGB(red, green, blue, transp) (uint)(red + (green << 8) + (blue << 16) + ((uint)(transp * 2.55) << 24))

#define GetColorOnly(clr) (clr & 0xFFFFFF)

#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)

#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NumberToBool(double number)
  {
   return number != EMPTY_VALUE && number != 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FirstBarState
  {
   bool              _first;
public:

                     FirstBarState()
     {
      _first = true;
     }

   void              Clear()
     {
      _first = true;
     }

   bool              IsFirst()
     {
      bool first = _first;
      _first = false;
      return first;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class NewBarState
  {
   datetime          _last;
public:

                     NewBarState()
     {
      _last = 0;
     }

   void              Clear()
     {
      _last = 0;
     }

   bool              IsNew(datetime date)
     {
      bool isnew = _last != date;
      _last = date;
      return isnew;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
  {
   if(value == EMPTY_VALUE || topValue == EMPTY_VALUE)
     {
      return bottomColor;
     }
   if(bottomValue == EMPTY_VALUE)
     {
      return topColor;
     }
   return value - bottomValue < topValue - value
          ? bottomColor
          : topColor;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SetStream(double &stream[], int pos, double value, double defaultValue)
  {
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Runtime
  {
public:
   static void       Error(string message)
     {
      Print(message);
      ExpertRemove();
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Line
  {
   string            _id;
   int               _x1;
   double            _y1;
   int               _x2;
   double            _y2;
   string            _xloc;
   uint              _clr;
   int               _width;
   ENUM_TIMEFRAMES   _timeframe;
   string            _style;
   int               _refs;
   string            _collectionId;
   int               _window;
   bool              global;
   string            _extend;
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

   void              AddRef()
     {
      _refs++;
     }

   int               Release()
     {
      int refs = --_refs;
      if(refs == 0)
        {
         delete &this;
        }
      return refs;
     }

   void              CopyTo(Line* line)
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

   bool              IsGlobal()
     {
      return global;
     }

   string            GetId()
     {
      return _id;
     }

   string            GetCollectionId()
     {
      return _collectionId;
     }
   static void       SetStyle(Line* line, string style)
     {
      if(line == NULL)
        {
         return;
        }
      line.SetStyle(style);
     }

   Line*             SetStyle(string style)
     {
      _style = style;
      return &this;
     }
   static void       SetExtend(Line* line, string extend)
     {
      if(line == NULL)
        {
         return;
        }
      line.SetExtend(extend);
     }

   Line*             SetExtend(string extend)
     {
      _extend = extend;
      return &this;
     }

   void              SetXY1(int x, double y)
     {
      _x1 = x;
      _y1 = y;
     }
   static void       SetXY1(Line* line, int x, double y)
     {
      if(line == NULL)
        {
         return;
        }
      line.SetXY1(x, y);
     }

   void              SetXY2(int x, double y)
     {
      _x2 = x;
      _y2 = y;
     }
   static void       SetXY2(Line* line, int x, double y)
     {
      if(line == NULL)
        {
         return;
        }
      line.SetXY2(x, y);
     }

   void              SetX1(int x) { _x1 = x; }
   static void       SetX1(Line* line, int x) { if(line == NULL) { return; } line.SetX1(x); }

   void              SetX2(int x) { _x2 = x; }
   static void       SetX2(Line* line, int x) { if(line == NULL) { return; } line.SetX2(x); }

   void              SetY1(double y) { _y1 = y; }
   static void       SetY1(Line* line, double y) { if(line == NULL) { return; } line.SetY1(y); }

   void              SetY2(double y) { _y2 = y; }
   static void       SetY2(Line* line, double y) { if(line == NULL) { return; } line.SetY2(y); }

   int               GetX1() { return _x1; }
   static int        GetX1(Line* line) { if(line == NULL) { return EMPTY_VALUE; } return line.GetX1(); }

   int               GetX2() { return _x2; }
   static int        GetX2(Line* line) { if(line == NULL) { return EMPTY_VALUE; } return line.GetX2(); }

   double            GetY1() { return _y1; }
   static double     GetY1(Line* line) { if(line == NULL) { return EMPTY_VALUE; } return line.GetY1(); }

   double            GetY2() { return _y2; }
   static double     GetY2(Line* line) { if(line == NULL) { return EMPTY_VALUE; } return line.GetY2(); }

   Line*             SetColor(uint clr)
     {
      _clr = clr;
      return &this;
     }
   static void       SetColor(Line* line, uint clr)
     {
      if(line == NULL)
        {
         return;
        }
      line.SetColor(clr);
     }
   static void       SetWidth(Line* line, int width)
     {
      if(line == NULL)
        {
         return;
        }
      line.SetWidth(width);
     }

   Line*             SetWidth(int width)
     {
      _width = width;
      return &this;
     }
   static void       SetXLoc(Line* line, string xloc)
     {
      if(line == NULL)
        {
         return;
        }
      line.SetXLoc(xloc);
     }

   Line*             SetXLoc(string xloc)
     {
      _xloc = xloc;
      return &this;
     }

   void              Redraw()
     {
      if(_y1 == EMPTY_VALUE || _y2 == EMPTY_VALUE)
        {
         return;
        }
      int pos1 = iBars(_Symbol, _timeframe) - _x1 - 1;
      datetime x1 = iTime(_Symbol, _timeframe, pos1);
      int pos2 = iBars(_Symbol, _timeframe) - _x2 - 1;
      datetime x2 = iTime(_Symbol, _timeframe, pos2);
      if(ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
        {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, GetStyleMQL());
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         if(_extend == "right")
           {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
           }
         else
            if(_extend == "left")
              {
               ObjectSetInteger(0, _id, OBJPROP_RAY, true);
               ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
              }
            else
               if(_extend == "both")
                 {
                  ObjectSetInteger(0, _id, OBJPROP_RAY, true);
                  ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
                  ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
                 }
               else
                  if(_extend == "none")
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

   int               GetStyleMQL()
     {
      if(_style == "dashed")
        {
         return STYLE_DASH;
        }
      if(_style == "solid")
        {
         return STYLE_SOLID;
        }
      return STYLE_SOLID;
     }
  };
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IBoolArray
  {
public:

   virtual void      Unshift(int value) = 0;

   virtual int       Size() = 0;

   virtual IBoolArray* Push(int value) = 0;

   virtual int       Pop() = 0;

   virtual int       Get(int index) = 0;

   virtual void      Set(int index, int value) = 0;

   virtual IBoolArray* Slice(int from, int to) = 0;

   virtual IBoolArray* Clear() = 0;

   virtual int       Shift() = 0;

   virtual int       Remove(int index) = 0;

   virtual int       Includes(int value) = 0;
  };
template <typename CLASS_TYPE>
interface ISimpleTypeArray : public ITArray<CLASS_TYPE>
  {
public:

   virtual ISimpleTypeArray<CLASS_TYPE>* Clear() = 0;
  };
template <typename CLASS_TYPE>
class SimpleTypeArray : public ISimpleTypeArray<CLASS_TYPE>
  {
   CLASS_TYPE        _array[];
   int               _defaultSize;
   CLASS_TYPE        _defaultValue;
   CLASS_TYPE        _emptyValue;
   int               _refs;
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

   void              AddRef() { _refs++; }

   int               Release() { int refs = --_refs; if(refs == 0) { delete &this; } return refs; }

   ISimpleTypeArray<CLASS_TYPE>* Clear()
     {
      int size = ArraySize(_array);
      ArrayResize(_array, _defaultSize);
      for(int i = 0; i < _defaultSize; ++i)
        {
         _array[i] = _defaultValue;
        }
      return &this;
     }

   void              Unshift(CLASS_TYPE value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for(int i = size - 1; i >= 0; --i)
        {
         _array[i + 1] = _array[i];
        }
      _array[0] = value;
     }

   int               Size()
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

   CLASS_TYPE        Pop()
     {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
     }

   CLASS_TYPE        Shift()
     {
      return Remove(0);
     }

   CLASS_TYPE        Get(int index)
     {
      if(index >= Size())
        {
         return _emptyValue;
        }
      if(index < 0)
        {
         index = Size() + index;
        }
      return _array[index];
     }

   void              Set(int index, CLASS_TYPE value)
     {
      if(index < 0 || index >= Size())
        {
         return;
        }
      _array[index] = value;
     }

   CLASS_TYPE        Remove(int index)
     {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[index];
      for(int i = index; i < size - 1; ++i)
        {
         _array[i] = _array[i + 1];
        }
      ArrayResize(_array, size - 1);
      return value;
     }

   int               Includes(CLASS_TYPE value)
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         if(_array[i] == value)
           {
            return true;
           }
        }
      return false;
     }

   CLASS_TYPE        PercentRank(int index)
     {
      int arraySize = Size();
      if(arraySize == 0 || arraySize <= index)
        {
         return _emptyValue;
        }
      CLASS_TYPE target = Get(index);
      if(target == _emptyValue)
        {
         return _emptyValue;
        }
      int count = 0;
      for(int i = 0; i < arraySize; ++i)
        {
         CLASS_TYPE current = Get(i);
         if(current != _emptyValue && target >= current)
           {
            count++;
           }
        }
      return (count * 100.0) / arraySize;
     }

   CLASS_TYPE        Max()
     {
      if(Size() == 0)
        {
         return _emptyValue;
        }
      CLASS_TYPE max = Get(0);
      for(int i = 1; i < Size(); ++i)
        {
         CLASS_TYPE current = Get(i);
         if(max == _emptyValue || (current != _emptyValue && max < current))
           {
            max = current;
           }
        }
      return max;
     }

   CLASS_TYPE        Min()
     {
      if(Size() == 0)
        {
         return _emptyValue;
        }
      CLASS_TYPE min = Get(0);
      for(int i = 1; i < Size(); ++i)
        {
         CLASS_TYPE current = Get(i);
         if(min == _emptyValue || (current != _emptyValue && min > current))
           {
            min = current;
           }
        }
      return min;
     }

   CLASS_TYPE        Sum()
     {
      CLASS_TYPE sum = 0;
      for(int i = 0; i < Size(); ++i)
        {
         sum += Get(i);
        }
      return sum;
     }

   double            Stdev()
     {
      double sum = 0;
      double ssum = 0;
      int size = Size();
      if(size < 2)
        {
         return 0;
        }
      for(int i = 0; i < size; i++)
        {
         CLASS_TYPE value = Get(i);
         sum += value;
         ssum += MathPow(value, 2);
        }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
     }
  };
template <typename CLASS_TYPE>
interface ICustomTypeArray : public ITArray<CLASS_TYPE>
  {
public:

   virtual ICustomTypeArray<CLASS_TYPE>* Clear() = 0;
  };
template <typename CLASS_TYPE>
class CustomTypeArray : public ICustomTypeArray<CLASS_TYPE>
  {
   CLASS_TYPE        _array[];
   int               _defaultSize;
   CLASS_TYPE        _defaultValue;
   int               _refs;
public:

                     CustomTypeArray(int size, CLASS_TYPE defaultValue)
     {
      _refs = 1;
      _defaultValue = defaultValue;
      if(_defaultValue != NULL)
        {
         _defaultValue.AddRef();
        }
      _defaultSize = size;
      Clear();
     }

                    ~CustomTypeArray()
     {
      Clear();
      if(_defaultValue != NULL)
        {
         _defaultValue.Release();
        }
     }

   void              AddRef() { _refs++; }

   int               Release() { int refs = --_refs; if(refs == 0) { delete &this; } return refs; }

   ICustomTypeArray<CLASS_TYPE>* Clear()
     {
      int size = ArraySize(_array);
      int i;
      for(i = 0; i < size; i++)
        {
         if(_array[i] != NULL)
           {
            DeleteItem(_array[i]);
            _array[i].Release();
           }
        }
      ArrayResize(_array, _defaultSize);
      for(i = 0; i < _defaultSize; ++i)
        {
         _array[i] = Clone(_defaultValue, i);
        }
      return &this;
     }

   void              Unshift(CLASS_TYPE value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for(int i = size - 1; i >= 0; --i)
        {
         _array[i + 1] = _array[i];
        }
      _array[0] = value;
      if(value != NULL)
        {
         value.AddRef();
        }
     }

   int               Size()
     {
      return ArraySize(_array);
     }

   ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if(value != NULL)
        {
         value.AddRef();
        }
      return &this;
     }

   CLASS_TYPE        Pop()
     {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if(value != NULL && value.Release() == 0)
        {
         return NULL;
        }
      return value;
     }

   CLASS_TYPE        Shift()
     {
      return Remove(0);
     }

   CLASS_TYPE        Get(int index)
     {
      if(index < 0 || index >= Size())
        {
         return NULL;
        }
      return _array[index];
     }

   void              Set(int index, CLASS_TYPE value)
     {
      if(index < 0 || index >= Size())
        {
         return;
        }
      if(_array[index] != NULL)
        {
         _array[index].Release();
        }
      _array[index] = value;
      if(value != NULL)
        {
         value.AddRef();
        }
     }

   CLASS_TYPE        Remove(int index)
     {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[index];
      for(int i = index; i < size - 1; ++i)
        {
         _array[i] = _array[i + 1];
        }
      ArrayResize(_array, size - 1);
      if(value == NULL || value.Release() == 0)
        {
         return NULL;
        }
      return value;
     }

   int               Includes(CLASS_TYPE value)
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         if(_array[i] == value)
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

   virtual void      DeleteItem(CLASS_TYPE item)
     {
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LinesCollection
  {
   string            _id;
   Line*             _array[];
   static LinesCollection* _collections[];
   static LinesCollection* _all;
   static int        _max;
public:
   static Line*      Get(Line* line, int index)
     {
      if(line == NULL)
        {
         return NULL;
        }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if(collection == NULL)
        {
         return NULL;
        }
      return collection.GetByIndex(index);
     }
   static void       Clear(bool full = false)
     {
      if(_all == NULL)
        {
         if(!full)
           {
            _all = new LinesCollection("");
           }
        }
      else
        {
         _all.ClearItems();
         if(full)
           {
            delete _all;
            _all = NULL;
           }
        }
      for(int i = 0; i < ArraySize(_collections); ++i)
        {
         delete _collections[i];
        }
      ArrayResize(_collections, 0);
     }
   static void       Delete(Line* line)
     {
      if(line == NULL)
        {
         return;
        }
      if(!_all.DeleteItem(line))
        {
         return;
        }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if(collection == NULL)
        {
         return;
        }
      collection.DeleteItem(line);
     }
   static Line*      Create(string id, int x1, double y1, int x2, double y2, datetime dateId, bool global = false)
     {
      if(_all == NULL)
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
      if(collection == NULL)
        {
         collection = new LinesCollection(id);
         AddCollection(collection);
        }
      collection.Add(line);
      _all.Add(line);
      int allLinesCount = _all.Count();
      if(allLinesCount > _max)
        {
         for(int i = 0; i < allLinesCount; ++i)
           {
            Line* lineToDelete = _all.Get(i);
            if(!lineToDelete.IsGlobal() && lineToDelete != line)
              {
               Delete(lineToDelete);
               break;
              }
           }
        }
      line.Release();
      return line;
     }
   static void       SetMaxLines(int max)
     {
      _max = max;
     }
   static void       Redraw()
     {
      for(int i = 0; i < ArraySize(_collections); ++i)
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

   string            GetId()
     {
      return _id;
     }

   void              ClearItems()
     {
      for(int i = 0; i < ArraySize(_array); ++i)
        {
         if(_array[i] != NULL)
           {
            _array[i].Release();
           }
        }
      ArrayResize(_array, 0);
     }

   int               Count()
     {
      return ArraySize(_array);
     }

   Line*             GetFirst()
     {
      return _array[0];
     }

   Line*             Get(int index)
     {
      int size = ArraySize(_array);
      if(index < 0 || index >= size)
        {
         return NULL;
        }
      return _array[index];
     }

   Line*             GetByIndex(int index)
     {
      int size = ArraySize(_array);
      if(index < 0 || index >= size)
        {
         return NULL;
        }
      return _array[size - 1 - index];
     }

   int               FindIndex(Line* line)
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         if(_array[i] == line)
           {
            return i;
           }
        }
      return -1;
     }

   bool              DeleteItem(Line* line)
     {
      int index = FindIndex(line);
      if(index == -1)
        {
         return false;
        }
      if(_array[index] != NULL)
        {
         _array[index].Release();
        }
      int size = ArraySize(_array);
      for(int i = index + 1; i < size; ++i)
        {
         _array[i - 1] = _array[i];
        }
      ArrayResize(_array, size - 1);
      return true;
     }

   void              Add(Line* line)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = line;
      if(line != NULL)
        {
         line.AddRef();
        }
     }

   void              RedrawLines()
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         _array[i].Redraw();
        }
     }
   static void       AddCollection(LinesCollection* collection)
     {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
     }
   static LinesCollection* FindCollection(string id)
     {
      for(int i = 0; i < ArraySize(_collections); ++i)
        {
         if(_collections[i].GetId() == id)
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
class LineArray : public CustomTypeArray<Line*>
  {
public:

                     LineArray(int size, Line* defaultValue)

      :              CustomTypeArray(size, defaultValue)
     {
     }
protected:

   virtual Line*     Clone(Line* item, int index)
     {
      if(item == NULL)
        {
         return NULL;
        }
      Line* clone = LinesCollection::Create(item.GetId() + index, item.GetX1(), item.GetY1(), item.GetX2(), item.GetY2(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
     }

   virtual void      DeleteItem(Line* item)
     {
      LinesCollection::Delete(item);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Label
  {
   uint              _color;
   uint              _textColor;
   string            _text;
   string            _labelId;
   string            _collectionId;
   string            _textAlign;
   int               _x;
   double            _y;
   string            _font;
   string            _style;
   string            _size;
   string            _yloc;
   ENUM_TIMEFRAMES   _timeframe;
   int               _refs;
   int               _window;
   bool              globalLabel;
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

   void              AddRef()
     {
      _refs++;
     }

   int               Release()
     {
      int refs = --_refs;
      if(refs == 0)
        {
         delete &this;
        }
      return refs;
     }

   void              CopyTo(Label* label)
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

   bool              IsGlobal()
     {
      return globalLabel;
     }

   string            GetId()
     {
      return _labelId;
     }

   string            GetCollectionId()
     {
      return _collectionId;
     }

   int               GetX()
     {
      return _x;
     }
   static int        GetX(Label* label)
     {
      if(label == NULL)
        {
         return 0;
        }
      return label.GetX();
     }

   double            GetY()
     {
      return _y;
     }
   static double     GetY(Label* label)
     {
      if(label == NULL)
        {
         return 0;
        }
      return label.GetY();
     }

   void              SetX(int x) { _x = x; }
   static void       SetX(Label* label, int x) { if(label == NULL) { return; } label.SetX(x); }

   void              SetY(double y) { _y = y; }
   static void       SetY(Label* label, double y) { if(label == NULL) { return; } label.SetY(y); }
   static void       SetXY(Label* label, int x, double y)
     {
      if(label == NULL)
        {
         return;
        }
      label.SetX(x);
      label.SetY(y);
     }

   Label*            SetSize(string size)
     {
      _size = size;
      return &this;
     }
   static void       SetSize(Label* label, string size)
     {
      if(label == NULL)
        {
         return;
        }
      label.SetSize(size);
     }

   Label*            SetYLoc(string yloc)
     {
      _yloc = yloc;
      return &this;
     }
   static void       SetYLoc(Label* label, string yloc)
     {
      if(label == NULL)
        {
         return;
        }
      label.SetYLoc(yloc);
     }
   static void       SetColor(Label* label, uint clr)
     {
      if(label == NULL)
        {
         return;
        }
      label.SetColor(clr);
     }

   Label*            SetColor(uint clr)
     {
      _color = clr;
      return &this;
     }
   static void       SetTextColor(Label* label, uint clr)
     {
      if(label == NULL)
        {
         return;
        }
      label.SetTextColor(clr);
     }

   Label*            SetTextColor(uint clr)
     {
      _textColor = clr;
      return &this;
     }
   static void       SetStyle(Label* label, string style)
     {
      if(label == NULL)
        {
         return;
        }
      label.SetStyle(style);
     }

   Label*            SetStyle(string style)
     {
      _style = style;
      return &this;
     }
   static void       SetText(Label* label, string text)
     {
      if(label == NULL)
        {
         return;
        }
      label.SetText(text);
     }

   Label*            SetText(string text)
     {
      _text = text;
      StringReplace(_text, "\n", " ");
      if(_text == "")
        {
         _font = "Wingdings";
        }
      else
        {
         _font = "Arial";
        }
      return &this;
     }
   static void       SetTextAlign(Label* label, string textAlign)
     {
      if(label == NULL)
        {
         return;
        }
      label.SetTextAlign(textAlign);
     }

   Label*            SetTextAlign(string textAlign)
     {
      _textAlign = textAlign;
      return &this;
     }

   void              Redraw()
     {
      string usedText = _text;
      if(usedText == "")
        {
         if(_style == "up")
           {
            usedText = "\217";
           }
         else
            if(_style == "down")
              {
               usedText = "\218";
              }
            else
               if(_style == "diamond")
                 {
                  usedText = "\116";
                 }
        }
      ResetLastError();
      int pos = iBars(_Symbol, _timeframe) - _x - 1;
      datetime x = iTime(_Symbol, _timeframe, pos);
      double y = getY(pos);
      if(ObjectFind(0, _labelId) == -1
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

   int               GetAnchor()
     {
      if(_yloc == "abovebar")
        {
         return ANCHOR_LOWER;
        }
      if(_yloc == "belowbar")
        {
         return ANCHOR_UPPER;
        }
      return ANCHOR_CENTER;
     }

   int               getFontSize()
     {
      if(_size == "tiny")
        {
         return 8;
        }
      if(_size == "small")
        {
         return 10;
        }
      if(_size == "large")
        {
         return 14;
        }
      if(_size == "huge")
        {
         return 16;
        }
      return 12;
     }

   double            getY(int pos)
     {
      if(_yloc == "abovebar")
        {
         return iHigh(_Symbol, _timeframe, pos);
        }
      if(_yloc == "belowbar")
        {
         return iLow(_Symbol, _timeframe, pos);
        }
      return _y;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LabelsCollection
  {
   string            _id;
   Label*            _labels[];
   static LabelsCollection* _collections[];
   static LabelsCollection* _all;
   static int        _maxLabels;
public:

                     LabelsCollection(string id)
     {
      _id = id;
     }

                    ~LabelsCollection()
     {
      ClearLabels();
     }

   void              ClearLabels()
     {
      for(int i = 0; i < ArraySize(_labels); ++i)
        {
         if(_labels[i] != NULL)
           {
            _labels[i].Release();
           }
        }
      ArrayResize(_labels, 0);
     }

   string            GetId()
     {
      return _id;
     }

   int               Count()
     {
      return ArraySize(_labels);
     }

   Label*            GetFirst()
     {
      return _labels[0];
     }

   Label*            Get(int index)
     {
      int size = ArraySize(_labels);
      if(index < 0 || index >= size)
        {
         return NULL;
        }
      return _labels[index];
     }

   Label*            GetByIndex(int index)
     {
      int size = ArraySize(_labels);
      if(index < 0 || index >= size)
        {
         return NULL;
        }
      return _labels[size - 1 - index];
     }
   static Label*     Get(Label* label, int index)
     {
      if(label == NULL)
        {
         return NULL;
        }
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if(collection == NULL)
        {
         return NULL;
        }
      return collection.GetByIndex(index);
     }
   static void       Clear(bool full = false)
     {
      for(int i = 0; i < ArraySize(_collections); ++i)
        {
         delete _collections[i];
        }
      ArrayResize(_collections, 0);
      if(_all == NULL && !full)
        {
         _all = new LabelsCollection("");
        }
      else
        {
         _all.ClearLabels();
         if(full)
           {
            delete _all;
            _all = NULL;
           }
        }
     }
   static void       Delete(Label* label)
     {
      if(label == NULL)
        {
         return;
        }
      _all.RemoveLabel(label);
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if(collection == NULL)
        {
         return;
        }
      collection.DeleteLabel(label);
     }
   static Label*     Create(string id, int x, double y, datetime dateId, bool globalLabel = false)
     {
      if(_all == NULL)
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
      if(collection == NULL)
        {
         collection = new LabelsCollection(id);
         AddCollection(collection);
        }
      collection.Add(label);
      _all.Add(label);
      int allLabelsCount = _all.Count();
      if(allLabelsCount > _maxLabels)
        {
         for(int i = 0; i < allLabelsCount; ++i)
           {
            Label* labelToDelete = _all.Get(i);
            if(!labelToDelete.IsGlobal() && labelToDelete != label)
              {
               Delete(labelToDelete);
               break;
              }
           }
        }
      return label;
     }
   static void       SetMaxLabels(int max)
     {
      _maxLabels = max;
     }
   static void       Redraw()
     {
      for(int i = 0; i < ArraySize(_collections); ++i)
        {
         _collections[i].RedrawLabels();
        }
     }
private:

   int               FindIndex(Label* label)
     {
      int size = ArraySize(_labels);
      for(int i = 0; i < size; ++i)
        {
         if(_labels[i] == label)
           {
            return i;
           }
        }
      return -1;
     }

   void              RemoveLabel(Label* label)
     {
      int index = FindIndex(label);
      if(index == -1)
        {
         return;
        }
      int size = ArraySize(_labels);
      for(int i = index + 1; i < size; ++i)
        {
         _labels[i - 1] = _labels[i];
        }
      ArrayResize(_labels, size - 1);
      label.Release();
     }

   void              DeleteLabel(Label* label)
     {
      RemoveLabel(label);
      label.Release();
     }

   void              Add(Label* label)
     {
      int index = FindIndex(label);
      int size = ArraySize(_labels);
      ArrayResize(_labels, size + 1);
      _labels[size] = label;
      if(label != NULL)
        {
         label.AddRef();
        }
     }

   void              RedrawLabels()
     {
      int size = ArraySize(_labels);
      for(int i = 0; i < size; ++i)
        {
         _labels[i].Redraw();
        }
     }
   static void       AddCollection(LabelsCollection* collection)
     {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
     }
   static LabelsCollection* FindCollection(string id)
     {
      for(int i = 0; i < ArraySize(_collections); ++i)
        {
         if(_collections[i].GetId() == id)
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
class LabelArray : public CustomTypeArray<Label*>
  {
public:

                     LabelArray(int size, Label* defaultValue) : CustomTypeArray(size, defaultValue)
     {
     }
protected:

   virtual Label*    Clone(Label* item, int index)
     {
      if(item == NULL)
        {
         return NULL;
        }
      Label* clone = LabelsCollection::Create(item.GetId() + index, item.GetX(), item.GetY(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
     }

   virtual void      DeleteItem(Label* item)
     {
      LabelsCollection::Delete(item);
     }
  };
class IntArray : public SimpleTypeArray<int>
  {
public:

                     IntArray(int size, double defaultValue)

      :              SimpleTypeArray(size, defaultValue, INT_MIN)
     {
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BoolArray : public IBoolArray
  {
   int               _array[];
   int               _defaultSize;
   int               _defaultValue;
public:

                     BoolArray(int size, int defaultValue)
     {
      _defaultSize = size;
      Clear();
     }

   IBoolArray*       Clear()
     {
      ArrayResize(_array, _defaultSize);
      for(int i = 0; i < _defaultSize; ++i)
        {
         _array[i] = _defaultValue;
        }
      return &this;
     }

   void              Unshift(int value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for(int i = size - 1; i >= 0; --i)
        {
         _array[i + 1] = _array[i];
        }
      _array[0] = value;
     }

   int               Size()
     {
      return ArraySize(_array);
     }

   IBoolArray*       Push(int value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
     }

   int               Pop()
     {
      int size = ArraySize(_array);
      int value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
     }

   int               Shift()
     {
      return Remove(0);
     }

   int               Get(int index)
     {
      if(index < 0 || index >= Size())
        {
         return EMPTY_VALUE;
        }
      return _array[index];
     }

   void              Set(int index, int value)
     {
      if(index < 0 || index >= Size())
        {
         return;
        }
      _array[index] = value;
     }

   IBoolArray*       Slice(int from, int to)
     {
      return NULL;
     }

   int               Remove(int index)
     {
      int size = ArraySize(_array);
      int value = _array[index];
      for(int i = index; i < size - 1; ++i)
        {
         _array[i] = _array[i + 1];
        }
      ArrayResize(_array, size - 1);
      return value;
     }

   int               Includes(int value)
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         if(_array[i] == value)
           {
            return true;
           }
        }
      return false;
     }
  };
class FloatArray : public SimpleTypeArray<double>
  {
public:

                     FloatArray(int size, double defaultValue)

      :              SimpleTypeArray(size, defaultValue, EMPTY_VALUE)
     {
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Box
  {
   string            _id;
   string            _collectionId;
   int               _left;
   double            _top;
   int               _right;
   double            _bottom;
   int               _window;
   color             _bgcolor;
   color             _borderColor;
   ENUM_TIMEFRAMES   _timeframe;
   string            _extend;
   string            _text;
   string            _textHAlign;
   string            _textVAlign;
   string            _textSize;
   color             _textColor;
   bool              global;
   int               _refs;
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

   void              AddRef()
     {
      _refs++;
     }

   int               Release()
     {
      int refs = --_refs;
      if(refs == 0)
        {
         delete &this;
        }
      return refs;
     }

   void              CopyTo(Box* target)
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

   bool              IsGlobal()
     {
      return global;
     }

   string            GetId()
     {
      return _id;
     }

   string            GetCollectionId()
     {
      return _collectionId;
     }
   static Box*       Copy(Box* box) { if(box == NULL) { return NULL; } return box.Copy(); }

   Box*              Copy()
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
   static double     GetTop(Box* box) { if(box == NULL) { return EMPTY_VALUE; } return box.GetTop(); }

   double            GetTop() { return _top; }
   static double     GetBottom(Box* box) { if(box == NULL) { return EMPTY_VALUE; } return box.GetBottom(); }

   double            GetBottom() { return _bottom; }
   static int        GetLeft(Box* box) { if(box == NULL) { return INT_MIN; } return box.GetLeft(); }

   int               GetLeft() { return _left; }
   static int        GetRight(Box* box) { if(box == NULL) { return INT_MIN; } return box.GetRight(); }

   int               GetRight() { return _right; }
   static void       SetTop(Box* box, double value) { if(box == NULL) { return; } box.SetTop(value); }

   void              SetTop(double value) { _top = value; }
   static void       SetBottom(Box* box, double value) { if(box == NULL) { return; } box.SetBottom(value); }

   void              SetBottom(double value) { _bottom = value; }
   static void       SetLeft(Box* box, int value) { if(box == NULL) { return; } box.SetLeft(value); }

   void              SetLeft(int value) { _left = value; }
   static void       SetRight(Box* box, int value) { if(box == NULL) { return; } box.SetRight(value); }

   void              SetRight(int value) { _right = value; }
   static void       SetLeftTop(Box* box, double top, int left) { if(box == NULL) { return; } box.SetTop(top); box.SetLeft(left); }
   static void       SetRightBottom(Box* box, double bottom, int right) { if(box == NULL) { return; } box.SetRight(right); box.SetBottom(bottom); }
   static void       SetBgColor(Box* box, color clr) { if(box == NULL) { return; } box.SetBgColor(clr); }

   Box*              SetBgColor(color clr) { _bgcolor = clr; return &this; }
   static void       SetBorderColor(Box* box, color clr) { if(box == NULL) { return; } box.SetBorderColor(clr); }

   Box*              SetBorderColor(color clr) { _borderColor = clr; return &this; }
   static void       SetExtend(Box* box, string extend) { if(box == NULL) { return; } box.SetExtend(extend); }

   Box*              SetExtend(string extend) { _extend = extend; return &this; }
   static void       SetText(Box* box, string text) { if(box == NULL) { return; } box.SetText(text); }

   Box*              SetText(string text) { _text = text; return &this; }
   static void       SetTextHAlign(Box* box, string halign) { if(box == NULL) { return; } box.SetTextHAlign(halign); }

   Box*              SetTextHAlign(string halign) { _textHAlign = halign; return &this; }
   static void       SetTextVAlign(Box* box, string valign) { if(box == NULL) { return; } box.SetTextVAlign(valign); }

   Box*              SetTextVAlign(string valign) { _textVAlign = valign; return &this; }
   static void       SetTextSize(Box* box, string size) { if(box == NULL) { return; } box.SetTextSize(size); }

   Box*              SetTextSize(string size) { _textSize = size; return &this; }
   static void       SetTextColor(Box* box, color clr) { if(box == NULL) { return; } box.SetTextColor(clr); }

   Box*              SetTextColor(color clr) { _textColor = clr; return &this; }

   void              Redraw()
     {
      int pos1 = 0;
      if(_extend == "left" || _extend == "both")
        {
         pos1 = iBars(_Symbol, _timeframe) - 1;
        }
      else
        {
         pos1 = iBars(_Symbol, _timeframe) - _left - 1;
        }
      datetime left = iTime(_Symbol, _timeframe, MathMax(0, pos1));
      int pos2 = 0;
      if(_extend == "right" || _extend == "both")
        {
         pos2 = 0;
        }
      else
        {
         pos2 = iBars(_Symbol, _timeframe) - _right - 1;
        }
      datetime right = iTime(_Symbol, _timeframe, MathMax(0, pos2));
      if(ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_RECTANGLE, _window, left, _top, right, _bottom))
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BoxesCollection
  {
   string            _id;
   Box*              _array[];
   static BoxesCollection* _collections[];
   static BoxesCollection* _all;
   static int        _max;
public:

                     BoxesCollection(string id)
     {
      _id = id;
     }

                    ~BoxesCollection()
     {
      ClearItems();
     }

   void              ClearItems()
     {
      for(int i = 0; i < ArraySize(_array); ++i)
        {
         if(_array[i] != NULL)
           {
            _array[i].Release();
           }
        }
      ArrayResize(_array, 0);
     }

   string            GetId()
     {
      return _id;
     }

   int               Count()
     {
      return ArraySize(_array);
     }

   Box*              GetFirst()
     {
      return _array[0];
     }

   Box*              Get(int index)
     {
      int size = ArraySize(_array);
      if(index < 0 || index >= size)
        {
         return NULL;
        }
      return _array[index];
     }

   Box*              GetByIndex(int index)
     {
      int size = ArraySize(_array);
      if(index < 0 || index >= size)
        {
         return NULL;
        }
      return _array[size - 1 - index];
     }
   static Box*       Get(Box* box, int index)
     {
      if(box == NULL)
        {
         return NULL;
        }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if(collection == NULL)
        {
         return NULL;
        }
      return collection.GetByIndex(index);
     }
   static void       Clear(bool full = false)
     {
      for(int i = 0; i < ArraySize(_collections); ++i)
        {
         delete _collections[i];
        }
      ArrayResize(_collections, 0);
      if(_all == NULL && !full)
        {
         _all = new BoxesCollection("");
        }
      else
        {
         _all.ClearItems();
         if(full)
           {
            delete _all;
            _all = NULL;
           }
        }
     }
   static void       Delete(Box* box)
     {
      if(box == NULL)
        {
         return;
        }
      _all.DeleteItem(box);
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if(collection == NULL)
        {
         return;
        }
      collection.DeleteItem(box);
     }
   static Box*       Create(string id, int left, double top, int right, double bottom, datetime dateId, bool global = false)
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
      if(collection == NULL)
        {
         collection = new BoxesCollection(id);
         AddCollection(collection);
        }
      collection.Add(box);
      _all.Add(box);
      box.Release();
      int allCount = _all.Count();
      if(allCount > _max)
        {
         for(int i = 0; i < allCount; ++i)
           {
            Box* toDelete = _all.Get(i);
            if(!toDelete.IsGlobal() && toDelete != box)
              {
               Delete(toDelete);
               break;
              }
           }
        }
      return box;
     }
   static void       SetMaxBoxes(int max)
     {
      _max = max;
     }
   static void       Redraw()
     {
      for(int i = 0; i < ArraySize(_collections); ++i)
        {
         _collections[i].RedrawBoxs();
        }
     }
private:

   int               FindIndex(Box* box)
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         if(_array[i] == box)
           {
            return i;
           }
        }
      return -1;
     }

   void              DeleteItem(Box* box)
     {
      int index = FindIndex(box);
      if(index == -1)
        {
         return;
        }
      int size = ArraySize(_array);
      for(int i = index + 1; i < size; ++i)
        {
         _array[i - 1] = _array[i];
        }
      ArrayResize(_array, size - 1);
      box.Release();
     }

   void              Add(Box* box)
     {
      int index = FindIndex(box);
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = box;
      box.AddRef();
     }

   void              RedrawBoxs()
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         _array[i].Redraw();
        }
     }
   static void       AddCollection(BoxesCollection* collection)
     {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
     }
   static BoxesCollection* FindCollection(string id)
     {
      for(int i = 0; i < ArraySize(_collections); ++i)
        {
         if(_collections[i].GetId() == id)
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
class BoxArray : public CustomTypeArray<Box*>
  {
public:

                     BoxArray(int size, Box* defaultValue) : CustomTypeArray(size, defaultValue)
     {
     }
protected:

   virtual Box*      Clone(Box* item, int index)
     {
      if(item == NULL)
        {
         return NULL;
        }
      Box* clone = BoxesCollection::Create(item.GetId() + index, item.GetLeft(), item.GetTop(), item.GetRight(), item.GetBottom(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
     }

   virtual void      DeleteItem(Box* item)
     {
      BoxesCollection::Delete(item);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IStringArray
  {
public:

   virtual void      Unshift(string value) = 0;

   virtual int       Size() = 0;

   virtual IStringArray* Push(string value) = 0;

   virtual string    Pop() = 0;

   virtual string    Get(int index) = 0;

   virtual void      Set(int index, string value) = 0;

   virtual IStringArray* Slice(int from, int to) = 0;

   virtual IStringArray* Clear() = 0;

   virtual string    Shift() = 0;

   virtual string    Remove(int index) = 0;

   virtual int       Includes(string value) = 0;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StringArray : public IStringArray
  {
   string            _array[];
   int               _defaultSize;
   string            _defaultValue;
public:

                     StringArray(int size, string defaultValue)
     {
      _defaultSize = size;
      Clear();
     }

   IStringArray*     Clear()
     {
      ArrayResize(_array, _defaultSize);
      for(int i = 0; i < _defaultSize; ++i)
        {
         _array[i] = _defaultValue;
        }
      return &this;
     }

   void              Unshift(string value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for(int i = size - 1; i >= 0; --i)
        {
         _array[i + 1] = _array[i];
        }
      _array[0] = value;
     }

   int               Size()
     {
      return ArraySize(_array);
     }

   IStringArray*     Push(string value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
     }

   string            Pop()
     {
      int size = ArraySize(_array);
      string value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
     }

   string            Shift()
     {
      return Remove(0);
     }

   string            Get(int index)
     {
      if(index < 0 || index >= Size())
        {
         return NULL;
        }
      return _array[index];
     }

   void              Set(int index, string value)
     {
      if(index < 0 || index >= Size())
        {
         return;
        }
      _array[index] = value;
     }

   IStringArray*     Slice(int from, int to)
     {
      return NULL;
     }

   string            Remove(int index)
     {
      int size = ArraySize(_array);
      string value = _array[index];
      for(int i = index; i < size - 1; ++i)
        {
         _array[i] = _array[i + 1];
        }
      ArrayResize(_array, size - 1);
      return value;
     }

   int               Includes(string value)
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         if(_array[i] == value)
           {
            return true;
           }
        }
      return false;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IColorArray
  {
public:

   virtual void      Unshift(uint value) = 0;

   virtual int       Size() = 0;

   virtual IColorArray* Push(uint value) = 0;

   virtual uint      Pop() = 0;

   virtual uint      Get(int index) = 0;

   virtual void      Set(int index, uint value) = 0;

   virtual IColorArray* Slice(int from, int to) = 0;

   virtual IColorArray* Clear() = 0;

   virtual uint      Shift() = 0;

   virtual uint      Remove(int index) = 0;

   virtual int       Includes(uint value) = 0;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ColorArray : public IColorArray
  {
   uint              _array[];
   int               _defaultSize;
   uint              _defaultValue;
public:

                     ColorArray(int size, uint defaultValue)
     {
      _defaultSize = size;
      Clear();
     }

   IColorArray*      Clear()
     {
      ArrayResize(_array, _defaultSize);
      for(int i = 0; i < _defaultSize; ++i)
        {
         _array[i] = _defaultValue;
        }
      return &this;
     }

   void              Unshift(uint value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for(int i = size - 1; i >= 0; --i)
        {
         _array[i + 1] = _array[i];
        }
      _array[0] = value;
     }

   int               Size()
     {
      return ArraySize(_array);
     }

   IColorArray*      Push(uint value)
     {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
     }

   uint              Pop()
     {
      int size = ArraySize(_array);
      uint value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
     }

   uint              Shift()
     {
      return Remove(0);
     }

   uint              Get(int index)
     {
      if(index < 0 || index >= Size())
        {
         return EMPTY_VALUE;
        }
      return _array[index];
     }

   void              Set(int index, uint value)
     {
      if(index < 0 || index >= Size())
        {
         return;
        }
      _array[index] = value;
     }

   IColorArray*      Slice(int from, int to)
     {
      return NULL;
     }

   uint              Remove(int index)
     {
      int size = ArraySize(_array);
      uint value = _array[index];
      for(int i = index; i < size - 1; ++i)
        {
         _array[i] = _array[i + 1];
        }
      ArrayResize(_array, size - 1);
      return value;
     }

   int               Includes(uint value)
     {
      int size = ArraySize(_array);
      for(int i = 0; i < size; ++i)
        {
         if(_array[i] == value)
           {
            return true;
           }
        }
      return false;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Array
  {
public:
   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void       Unshift(ARRAY_TYPE array, VALUE_TYPE value) { if(array == NULL) { return; } array.Unshift(value); }
   static double     Avg(ISimpleTypeArray<double>* array)
     {
      if(array == NULL || array.Size() == 0)
        {
         return EMPTY_VALUE;
        }
      return Sum(array) / array.Size();
     }
   static double     Avg(ISimpleTypeArray<int>* array)
     {
      if(array == NULL || array.Size() == 0)
        {
         return EMPTY_VALUE;
        }
      return Sum(array) / array.Size();
     }
   static double     Sum(ISimpleTypeArray<double>* array)
     {
      if(array == NULL || array.Size() == 0)
        {
         return EMPTY_VALUE;
        }
      double sum = array.Get(0);
      for(int i = 1; i < array.Size(); ++i)
        {
         sum += array.Get(i);
        }
      return sum;
     }
   static int        Sum(ISimpleTypeArray<int>* array)
     {
      if(array == NULL || array.Size() == 0)
        {
         return INT_MIN;
        }
      int sum = array.Get(0);
      for(int i = 1; i < array.Size(); ++i)
        {
         sum += array.Get(i);
        }
      return sum;
     }
   static double     Min(ISimpleTypeArray<double>* array, int nth)
     {
      if(array == NULL || array.Size() == 0 || nth != 0)
        {
         return EMPTY_VALUE;
        }
      double minVal = array.Get(0);
      for(int i = 1; i < array.Size(); ++i)
        {
         double val = array.Get(i);
         if(minVal > val)
           {
            minVal = val;
           }
        }
      return minVal;
     }
   static int        Min(ISimpleTypeArray<int>* array, int nth)
     {
      if(array == NULL || array.Size() == 0 || nth != 0)
        {
         return INT_MIN;
        }
      int minVal = array.Get(0);
      for(int i = 1; i < array.Size(); ++i)
        {
         int val = array.Get(i);
         if(minVal > val)
           {
            minVal = val;
           }
        }
      return minVal;
     }
   static double     Max(ISimpleTypeArray<double>* array, int nth)
     {
      if(array == NULL || array.Size() == 0 || nth != 0)
        {
         return EMPTY_VALUE;
        }
      double maxVal = array.Get(0);
      for(int i = 1; i < array.Size(); ++i)
        {
         double val = array.Get(i);
         if(maxVal < val)
           {
            maxVal = val;
           }
        }
      return maxVal;
     }
   static int        Max(ISimpleTypeArray<int>* array, int nth)
     {
      if(array == NULL || array.Size() == 0 || nth != 0)
        {
         return INT_MIN;
        }
      int maxVal = array.Get(0);
      for(int i = 1; i < array.Size(); ++i)
        {
         int val = array.Get(i);
         if(maxVal < val)
           {
            maxVal = val;
           }
        }
      return maxVal;
     }
   template <typename DUMMY_TYPE, typename ARRAY_TYPE>
   static int        Size(ARRAY_TYPE array, int defaultValue) { if(array == NULL) { return INT_MIN;} return array.Size(); }
   template <typename ARRAY_TYPE>
   static void       Clear(ARRAY_TYPE array) { if(array == NULL) { return;} array.Clear(); }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Shift(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if(array == NULL) { return emptyValue; } return array.Shift(); }
   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void       Push(ARRAY_TYPE array, VALUE_TYPE value) { if(array == NULL) { return; } array.Push(value); }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE First(ARRAY_TYPE array, VALUE_TYPE defaultValue)
     {
      if(array == NULL || array.Size() == 0)
        {
         return defaultValue;
        }
      return array.Get(0);
     }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Last(ARRAY_TYPE array, VALUE_TYPE defaultValue)
     {
      if(array == NULL || array.Size() == 0)
        {
         return defaultValue;
        }
      return array.Get(array.Size() - 1);
     }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Pop(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if(array == NULL) { return emptyValue; } return array.Pop(); }
   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Get(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if(array == NULL) { return emptyValue; } return array.Get(index); }
   template <typename ARRAY_TYPE, typename DUMMY_TYPE, typename VALUE_TYPE>
   static void       Set(ARRAY_TYPE array, int index, VALUE_TYPE value) { if(array == NULL) { return; } array.Set(index, value); }
   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Remove(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if(array == NULL) { return emptyValue; } return array.Remove(index); }
   static int        Includes(ITArray<int>* array, int value) { if(array == NULL) { return -1; } return array.Includes(value); }
   static int        Includes(ILineArray* array, Line* value) { if(array == NULL) { return -1; } return array.Includes(value); }
   static int        Includes(ITArray<Box*>* array, Box* value) { if(array == NULL) { return -1; } return array.Includes(value); }
   static int        Includes(IStringArray* array, string value) { if(array == NULL) { return -1; } return array.Includes(value); }
   static int        Includes(IBoolArray* array, int value) { if(array == NULL) { return -1; } return array.Includes(value); }
   static int        Includes(IColorArray* array, uint value) { if(array == NULL) { return -1; } return array.Includes(value); }
   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static ARRAY_TYPE PercentRank(ISimpleTypeArray<ARRAY_TYPE>* array) { if(array == NULL) { return -1; } return array.PercentRank(index); }
   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static ARRAY_TYPE Stdev(ISimpleTypeArray<ARRAY_TYPE>* array) { if(array == NULL) { return -1; } return array.Stdev(); }
   static string     Join(IStringArray* array, string concat)
     {
      string res = "";
      for(int i = 0; i < array.Size(); ++i)
        {
         string val = array.Get(i);
         if(val == NULL)
           {
            continue;
           }
         if(i > 0)
           {
            res += concat;
           }
         res += array.Get(i);
        }
      return res;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Nz(double val, double defaultValue = 0)
  {
   return val == EMPTY_VALUE ? defaultValue : val;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafePlus(int left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return left + right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafePlus(double left, int right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return left + right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafePlus(int left, int right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return left + right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafePlus(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return left + right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SafePlus(string left, string right)
  {
   if(left == NULL || right == NULL)
     {
      return NULL;
     }
   return left + right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMinus(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return left - right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeDivide(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0)
     {
      return EMPTY_VALUE;
     }
   return left / right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMultiply(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return left * right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SafeGreater(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return false;
     }
   return left > right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SafeGE(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return false;
     }
   return left >= right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SafeLess(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return false;
     }
   return left < right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SafeLE(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return false;
     }
   return left <= right;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathExp(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathExp(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathMax(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathMax(left, right);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathMin(double left, double right)
  {
   if(left == EMPTY_VALUE || right == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathMin(left, right);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathPow(double value, double power)
  {
   if(value == EMPTY_VALUE || power == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathPow(value, power);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathAbs(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathAbs(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathRound(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathRound(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathRound(double value, int precision)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return NormalizeDouble(value, precision);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathSqrt(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathSqrt(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeSign(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   if(value == 0)
     {
      return 0;
     }
   return value > 0 ? 1 : -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeLog(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathLog(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeLog10(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathLog10(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeCos(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathCos(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeArccos(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathArccos(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeSin(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathSin(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeArcsin(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathArcsin(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeTan(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathTan(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeArctan(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathArctan(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double InvertSign(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return -value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SafeMathFloor(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return EMPTY_VALUE;
     }
   return MathFloor(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SafeMathCeil(double value)
  {
   if(value == EMPTY_VALUE)
     {
      return INT_MIN;
     }
   return MathCeil(value);
  }
template <typename T>
interface TIStream
  {
public:

   virtual void AddRef() = 0;

   virtual void Release() = 0;

   virtual int Size() = 0;

   virtual bool GetValue(const int period, T &val) = 0;
  };
class AOnStream : public TIStream<double>
  {
protected:
   TIStream<double>  *_source;
   int               _references;
public:

                     AOnStream(TIStream<double> *source)
     {
      _references = 1;
      _source = source;
      if(_source != NULL)
        {
         _source.AddRef();
        }
     }

                    ~AOnStream()
     {
      _source.Release();
     }

   void              AddRef()
     {
      ++_references;
     }

   void              Release()
     {
      --_references;
      if(_references == 0)
         delete &this;
     }

   virtual int       Size()
     {
      return _source.Size();
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class InstrumentInfo
  {
   string            _symbol;
   double            _mult;
   double            _point;
   double            _pipSize;
   int               _digits;
   double            _tickSize;
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

   int               CompareLots(double lot1, double lot2)
     {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if(lotStep == 0)
        {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
        }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
     }
   static double     GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }

   double            GetBid() { return GetBid(_symbol); }
   static double     GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }

   double            GetAsk() { return GetAsk(_symbol); }
   static double     GetPipSize(const string symbol)
     {
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS);
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
     }

   double            GetPipSize() { return _pipSize; }

   double            GetPointSize() { return _point; }

   string            GetSymbol() { return _symbol; }

   double            GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }

   int               GetDigits() { return _digits; }

   double            GetTickSize() { return _tickSize; }

   double            GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double            AddPips(const double rate, const double pips)
     {
      return RoundRate(rate + pips * _pipSize);
     }

   double            RoundRate(const double rate)
     {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
     }

   double            RoundLots(const double lots)
     {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if(lotStep == 0)
        {
         return 0.0;
        }
      return floor(lots / lotStep) * lotStep;
     }

   double            LimitLots(const double lots)
     {
      double minVolume = GetMinLots();
      if(minVolume > lots)
        {
         return 0.0;
        }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if(maxVolume < lots)
        {
         return maxVolume;
        }
      return lots;
     }

   double            NormalizeLots(const double lots)
     {
      return LimitLots(RoundLots(lots));
     }
  };
class AStream : public TIStream<double>
  {
protected:
   string            _symbol;
   ENUM_TIMEFRAMES   _timeframe;
   double            _shift;
   InstrumentInfo    *_instrument;
   int               _references;

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

   void              SetShift(const double shift)
     {
      _shift = shift;
     }

   void              AddRef()
     {
      ++_references;
     }

   void              Release()
     {
      --_references;
      if(_references == 0)
         delete &this;
     }

   int               Size()
     {
      return iBars(_symbol, _timeframe);
     }
  };
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SimplePriceStream : public AStream
  {
   PriceType         _price;
   int               _periodShift;
public:

                     SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price, int periodShift = 0)

      :              AStream(symbol, timeframe)
     {
      _price = __price;
      _periodShift = periodShift;
     }

   bool              GetValue(const int period, double &val)
     {
      ResetLastError();
      switch(_price)
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
            if(iOpen(_symbol, _timeframe, period + _periodShift) > iClose(_symbol, _timeframe, period + _periodShift))
               val = (iHigh(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
            else
               val = (iLow(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
           }
         break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period + _periodShift);
            break;
        }
      if(GetLastError() != ERR_NO_ERROR)
        {
         return false;
        }
      val += _shift * _instrument.GetPipSize();
      return true;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HighestHighStream : public AOnStream
  {
   int               _loopback;
public:

                     HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)

      :              AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
     {
      _loopback = loopback;
      _source.Release();
     }

                     HighestHighStream(TIStream<double>* source, int loopback)

      :              AOnStream(source)
     {
      _loopback = loopback;
     }
   static bool       GetValue(const int period, double &val, TIStream<double>* source, int loopback)
     {
      if(!source.GetValue(period, val))
         return false;
      for(int i = 1; i < loopback; ++i)
        {
         double value;
         if(!source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
        }
      return true;
     }

   bool              GetValue(const int period, double &val)
     {
      return HighestHighStream::GetValue(period, val, _source, _loopback);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LowestLowStream : public AOnStream
  {
   int               _loopback;
public:

                     LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)

      :              AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
     {
      _loopback = loopback;
      _source.Release();
     }

                     LowestLowStream(TIStream<double>* source, int loopback)

      :              AOnStream(source)
     {
      _loopback = loopback;
     }
   static bool       GetValue(const int period, double &val, TIStream<double>* source, int loopback)
     {
      if(!source.GetValue(period, val))
         return false;
      for(int i = 1; i < loopback; ++i)
        {
         double value;
         if(!source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
        }
      return true;
     }

   bool              GetValue(const int period, double &val)
     {
      return LowestLowStream::GetValue(period, val, _source, _loopback);
     }
  };
template <typename T>
class TAStream : public TIStream<T>
  {
   int               _refs;
public:

                     TAStream()
     {
      _refs = 1;
     }

   void              AddRef()
     {
      _refs++;
     }

   void              Release()
     {
      if(--_refs == 0)
        {
         delete &this;
        }
     }
  };
class BoolStream : public TAStream<int>
  {
   string            _symbol;
   ENUM_TIMEFRAMES   _timeframe;
   bool              _stream[];
   int               _emptyValue;
public:

                     BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int emptyValue = -1)
     {
      _emptyValue = emptyValue;
      _symbol = symbol;
      _timeframe = timeframe;
     }

   void              Init()
     {
      ArrayInitialize(_stream, _emptyValue);
     }

   virtual int       Size()
     {
      return iBars(_symbol, _timeframe);
     }

   void              SetValue(const int period, bool value)
     {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if(index < 0 || totalBars <= index)
        {
         return;
        }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
     }

   bool              GetValue(const int period, bool &val)
     {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if(index < 0 || totalBars <= index)
        {
         return false;
        }
      EnsureStreamHasProperSize(totalBars);
      val = _stream[index];
      return _stream[index] != _emptyValue;
     }

   bool              GetValue(const int period, int &val)
     {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if(index < 0 || totalBars <= index)
        {
         return false;
        }
      EnsureStreamHasProperSize(totalBars);
      val = _stream[index];
      return _stream[index] != _emptyValue;
     }
private:

   void              EnsureStreamHasProperSize(int size)
     {
      int currentSize = ArrayRange(_stream, 0);
      if(currentSize != size)
        {
         ArrayResize(_stream, size);
         for(int i = currentSize; i < size; ++i)
           {
            _stream[i] = _emptyValue;
           }
        }
     }
  };
class BarsSinceStreamV2 : public TAStream<int>
  {
   TIStream<int>*    _condition;
   int               _bars[];
public:

                     BarsSinceStreamV2(TIStream<int>* condition)
     {
      _condition = condition;
      _condition.AddRef();
     }

                    ~BarsSinceStreamV2()
     {
      _condition.Release();
     }

   int               Size()
     {
      return _condition.Size();
     }

   virtual bool      GetValue(const int period, int &val)
     {
      int size = Size();
      if(period >= size)
        {
         return false;
        }
      if(ArraySize(_bars) < size)
        {
         ArrayResize(_bars, size);
        }
      int index = size - period - 1;
      if(_bars[index] == 0)
        {
         FillHistory(period);
        }
      val = _bars[index];
      return val != INT_MIN;
     }
private:

   void              FillHistory(int period)
     {
      int size = Size();
      for(int periodIndex = period; periodIndex < size; ++periodIndex)
        {
         int index = size - periodIndex - 1;
         int val;
         if(!_condition.GetValue(periodIndex, val) || val == INT_MIN)
           {
            if(_bars[index] == 0)
              {
               continue;
              }
           }
         else
           {
            _bars[index] = 0;
           }
         for(int ii = index + 1; ii <= size - period - 1; ++ii)
           {
            _bars[ii] = _bars[ii - 1] + 1;
           }
         return;
        }
     }
  };
class IntStream : public TAStream<int>
  {
   string            _symbol;
   ENUM_TIMEFRAMES   _timeframe;
   int               _stream[];
   int               _emptyValue;
public:

                     IntStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int emptyValue = INT_MIN)
     {
      _symbol = symbol;
      _timeframe = timeframe;
      _emptyValue = emptyValue;
     }

   void              Init()
     {
      ArrayInitialize(_stream, _emptyValue);
     }

   virtual int       Size()
     {
      return iBars(_symbol, _timeframe);
     }

   void              SetValue(const int period, int value)
     {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if(index < 0 || totalBars <= index)
        {
         return;
        }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
     }

   bool              GetValue(const int period, int &val)
     {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if(index < 0 || totalBars <= index)
        {
         return false;
        }
      EnsureStreamHasProperSize(totalBars);
      val = _stream[index];
      return _stream[index] != _emptyValue;
     }
private:

   void              EnsureStreamHasProperSize(int size)
     {
      int currentSize = ArrayRange(_stream, 0);
      if(currentSize != size)
        {
         ArrayResize(_stream, size);
         for(int i = currentSize; i < size; ++i)
           {
            _stream[i] = _emptyValue;
           }
        }
     }
  };
class IntToFloatStreamWrapper : public TAStream<double>
  {
   TIStream<int>*    _source;
public:

                     IntToFloatStreamWrapper(TIStream<int>* source)
     {
      _source = source;
      _source.AddRef();
     }

                    ~IntToFloatStreamWrapper()
     {
      _source.Release();
     }

   int               Size()
     {
      return _source.Size();
     }

   bool              GetValue(const int period, double &val)
     {
      int intVal;
      if(!_source.GetValue(period, intVal))
        {
         return false;
        }
      val = intVal;
      return true;
     }
  };
interface IBoolStream
  {
public:

   virtual void AddRef() = 0;

   virtual void Release() = 0;

   virtual int Size() = 0;

   virtual bool GetValue(const int period, bool &val) = 0;

   virtual bool GetValue(const int period, int &val) = 0;
  };
class BoolToFloatStreamWrapper : public TAStream<double>
  {
   IBoolStream*      _source;
public:

                     BoolToFloatStreamWrapper(IBoolStream* source)
     {
      _source = source;
      _source.AddRef();
     }

                    ~BoolToFloatStreamWrapper()
     {
      _source.Release();
     }

   int               Size()
     {
      return _source.Size();
     }

   bool              GetValue(const int period, double &val)
     {
      int intVal;
      if(!_source.GetValue(period, intVal))
        {
         return false;
        }
      val = intVal;
      return true;
     }
  };
class DateTimeToFloatStreamWrapper : public TAStream<double>
  {
   TIStream<datetime>* _source;
public:

                     DateTimeToFloatStreamWrapper(TIStream<datetime>* source)
     {
      _source = source;
      _source.AddRef();
     }

                    ~DateTimeToFloatStreamWrapper()
     {
      _source.Release();
     }

   int               Size()
     {
      return _source.Size();
     }

   bool              GetValue(const int period, double &val)
     {
      datetime intVal;
      if(!_source.GetValue(period, intVal))
        {
         return false;
        }
      val = intVal;
      return true;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ChangeStream : public AOnStream
  {
   int               _period;
public:

                     ChangeStream(TIStream<double>* stream, int period = 1)

      :              AOnStream(stream)
     {
      _period = period;
     }

                     ChangeStream(TIStream<int>* stream, int period = 1)

      :              AOnStream(new IntToFloatStreamWrapper(stream))
     {
      _source.Release();
      _period = period;
     }

                     ChangeStream(IBoolStream* stream, int period = 1)

      :              AOnStream(new BoolToFloatStreamWrapper(stream))
     {
      _source.Release();
      _period = period;
     }

                     ChangeStream(TIStream<datetime>* stream, int period = 1)

      :              AOnStream(new DateTimeToFloatStreamWrapper(stream))
     {
      _source.Release();
      _period = period;
     }

   virtual bool      GetValue(const int period, double &val)
     {
      double src1, src2;
      if(!_source.GetValue(period, src1) || !_source.GetValue(period + _period, src2))
        {
         return false;
        }
      val = src1 - src2;
      return true;
     }
  };
interface ICondition
  {
public:

   virtual void AddRef() = 0;

   virtual void Release() = 0;

   virtual bool IsPass(const int period, const datetime date) = 0;

   virtual string GetLogMessage(const int period, const datetime date) = 0;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ValueWhenSimpleStream : public AStream
  {
   datetime          _periods[];
   double            _values[];
   int               _shift;
public:
   double            _stream[];

                     ValueWhenSimpleStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int shift)

      :              AStream(symbol, timeframe)
     {
      _shift = shift;
     }

   int               RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
     {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
     }

   int               RegisterInternalStream(int id)
     {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
     }

   double            Update(const int period, datetime date, bool condition, double val)
     {
      if(condition)
        {
         int size = ArraySize(_periods);
         if(size == 0 || _periods[size - 1] != date)
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
         if(size > _shift)
           {
            _stream[period] = _values[size - 1 - _shift];
           }
        }
      else
         if(iBars(_symbol, _timeframe) - 1 > period)
           {
            _stream[period] = _stream[period + 1];
           }
      return _stream[period];
     }

   bool              GetValue(const int period, double &val)
     {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
     }
  };
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
#import "AdvancedNotificationsLib.dll"

void AdvancedAlert(string key, string text, string instrument, string timeframe);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ShellExecuteW(int hwnd, string Operation, string File, string Parameters, string Directory, int ShowCmd);
#import
enum SignalerFrequency
  {
   SignalsAll,
   SignalsOncePerBarClose,
   SignalsOncePerBar
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Signaler
  {
   string            _prefix;
   SignalerFrequency _frequency;
   datetime          _lastSignal;
public:

                     Signaler(string frequency)
     {
      if(frequency == "all")
        {
         _frequency = SignalsAll;
        }
      else
         if(frequency == "once_per_bar_close")
           {
            _frequency = SignalsOncePerBarClose;
           }
         else
            if(frequency == "once_per_bar")
              {
               _frequency = SignalsOncePerBar;
              }
      _lastSignal = 0;
     }

                     Signaler()
     {
      _lastSignal = 0;
     }

   void              SetMessagePrefix(string prefix)
     {
      _prefix = prefix;
     }

   void              ShowAlert(string message, int position, datetime time)
     {
      if(position != 0)
        {
         return;
        }
      if(_frequency != SignalsAll)
        {
         if(_lastSignal == time)
           {
            return;
           }
        }
      _lastSignal = time;
      SendNotifications("", message);
     }

   void              SendNotifications(const string subject, string message = NULL)
     {
      if(message == NULL)
         message = subject;
      if(_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if(start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if(popup_alert)
         Alert(message);
      if(email_alert)
         SendMail(subject, message);
      if(play_sound)
         PlaySound(sound_file);
      if(notification_alert)
         SendNotification(message);
      if(advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
     }
  };
input int param1 = 9; // ZigZag Length
input bool param2 = true; // Show Zigzag
input double param3 = 0.33; // Fib Factor for breakout confirmation
input string param4 = "tiny"; // Text Size
input color param5 = AddTransparency(Green, 70); // Color
input color param6 = Green; // Border Color
input color param7 = Green; // Text Color
input color param8 = AddTransparency(Red, 70); // Color
input color param9 = Red; // Border Color
input color param10 = Red; // Text Color
input color param11 = AddTransparency(Green, 70); // Color
input color param12 = Green; // Border Color
input color param13 = Green; // Text Color
input color param14 = AddTransparency(Red, 70); // Color
input color param15 = Red; // Border Color
input color param16 = Red; // Text Color
input int bars_limit = 100000; // Bars limit
input bool ShowZoneBreakArrows = true; // Show Zone Break Arrows
input int ZoneBreakArrowUpCode = 233; // Zone Break Arrow Up Code
input int ZoneBreakArrowDownCode = 234; // Zone Break Arrow Down Code
input color ZoneBreakArrowUpColor = clrLime; // Zone Break Arrow Up Color
input color ZoneBreakArrowDownColor = clrRed; // Zone Break Arrow Down Color
input int ZoneBreakArrowOffset = 10; // Zone Break Arrow Offset (points)
input int ZoneBreakArrowSize = 3; // Zone Break Arrow Size
input bool ShowTrendBreakArrows = true; // Show Trend Break Arrows
input int TrendBreakArrowUpCode = 233; // Trend Break Arrow Up Code
input int TrendBreakArrowDownCode = 234; // Trend Break Arrow Down Code
input color TrendBreakArrowUpColor = clrAqua; // Trend Break Arrow Up Color
input color TrendBreakArrowDownColor = clrMagenta; // Trend Break Arrow Down Color
input int TrendBreakArrowOffset = 10; // Trend Break Arrow Offset (points)
input int TrendBreakArrowSize = 3; // Trend Break Arrow Size
input int ArrowAlertLookbackBars = 10; // Arrow Alert Lookback Bars (0 = disabled, recommended: 5-10)
Signaler* _signaler;
double ZoneBreakArrowUpBuffer[];
double ZoneBreakArrowDownBuffer[];
double TrendBreakArrowUpBuffer[];
double TrendBreakArrowDownBuffer[];
int zigzag_len;
int show_zigzag;
double fib_factor;
string text_size;
uint bu_ob_color;
uint bu_ob_border_color;
uint bu_ob_text_color;
uint be_ob_color;
uint be_ob_border_color;
uint be_ob_text_color;
uint bu_bb_color;
uint bu_bb_border_color;
uint bu_bb_text_color;
uint be_bb_color;
uint be_bb_border_color;
uint be_bb_text_color;
ISimpleTypeArray<double>* high_points_arr;
ITArray<int>* high_index_arr;
ISimpleTypeArray<double>* low_points_arr;
ITArray<int>* low_index_arr;
ICustomTypeArray<Box*>* bu_ob_boxes;
ICustomTypeArray<Box*>* be_ob_boxes;
ICustomTypeArray<Box*>* bu_bb_boxes;
ICustomTypeArray<Box*>* be_bb_boxes;
HighestHighStream* highest1;
LowestLowStream* lowest1;
double trend[];
double trend_DEFAULT_VALUE;
int last_trend_up_since;
BoolStream* barssince1Condition;
BarsSinceStreamV2* barssince1;
double to_up[];
double to_up_DEFAULT_VALUE;
LowestLowStream* lowest2;
BoolStream* barssince2Condition;
BarsSinceStreamV2* barssince2;
int last_trend_down_since;
BoolStream* barssince3Condition;
BarsSinceStreamV2* barssince3;
double to_down[];
double to_down_DEFAULT_VALUE;
HighestHighStream* highest2;
BoolStream* barssince4Condition;
BarsSinceStreamV2* barssince4;
IntStream* change1Source;
ChangeStream* change1;
class f_get_high_1Stream
  {
   int               ind;
   bool              _initialized;
   string            IndicatorObjPrefix;
public:

                     f_get_high_1Stream(int ind, string indicatorObjPrefix)
     {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.ind = ind;
     }

                    ~f_get_high_1Stream()
     {
     }

   int               Init(int id)
     {
      return id;
     }

   void              Clear()
     {
      _initialized = false;
     }

   bool              GetValue(const int pos, double &__out1, int &__out2)
     {
      __out1 = Array::Get<double, ISimpleTypeArray<double>*, int>(high_points_arr, SafeMinus(SafeMinus(Array::Size<int, ISimpleTypeArray<double>*>(high_points_arr, INT_MIN), 1), ind), EMPTY_VALUE);
      __out2 = Array::Get<int, ITArray<int>*, int>(high_index_arr, SafeMinus(SafeMinus(Array::Size<int, ITArray<int>*>(high_index_arr, INT_MIN), 1), ind), INT_MIN);
      return true;
     }
  };
f_get_high_1Stream* f_get_high_11;
f_get_high_1Stream* f_get_high_12;
class f_get_low_1Stream
  {
   int               ind;
   bool              _initialized;
   string            IndicatorObjPrefix;
public:

                     f_get_low_1Stream(int ind, string indicatorObjPrefix)
     {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.ind = ind;
     }

                    ~f_get_low_1Stream()
     {
     }

   int               Init(int id)
     {
      return id;
     }

   void              Clear()
     {
      _initialized = false;
     }

   bool              GetValue(const int pos, double &__out1, int &__out2)
     {
      __out1 = Array::Get<double, ISimpleTypeArray<double>*, int>(low_points_arr, SafeMinus(SafeMinus(Array::Size<int, ISimpleTypeArray<double>*>(low_points_arr, INT_MIN), 1), ind), EMPTY_VALUE);
      __out2 = Array::Get<int, ITArray<int>*, int>(low_index_arr, SafeMinus(SafeMinus(Array::Size<int, ITArray<int>*>(low_index_arr, INT_MIN), 1), ind), INT_MIN);
      return true;
     }
  };
f_get_low_1Stream* f_get_low_13;
f_get_low_1Stream* f_get_low_14;
IntStream* change2Source;
ChangeStream* change2;
double market[];
double market_DEFAULT_VALUE;
IntStream* change3Source;
ChangeStream* change3;
ValueWhenSimpleStream* valuewhen1;
IntStream* change4Source;
ChangeStream* change4;
ValueWhenSimpleStream* valuewhen2;
double bu_ob_index[];
double bu_ob_index_DEFAULT_VALUE;
double l0i[];
double l0i_DEFAULT_VALUE;
double be_ob_index[];
double be_ob_index_DEFAULT_VALUE;
double h0i[];
double h0i_DEFAULT_VALUE;
double be_bb_index[];
double be_bb_index_DEFAULT_VALUE;
double bu_bb_index[];
double bu_bb_index_DEFAULT_VALUE;
IntStream* change5Source;
ChangeStream* change5;
IntStream* change6Source;
ChangeStream* change6;
string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NamesCollision(const string name)
  {
   for(int k = ObjectsTotal(); k >= 0; k--)
     {
      if(StringFind(ObjectName(0, k), name) == 0)
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorPrefix(string target)
  {
   if(StringLen(target) > 20)
     {
      target = StringSubstr(target, 0, 20);
     }
   for(int i = 0; i < 1000; ++i)
     {
      string prefix = target + "_" + IntegerToString(i);
      if(!NamesCollision(prefix))
        {
         return prefix;
        }
     }
   return target;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(16);
   zigzag_len = param1;
   show_zigzag = param2;
   fib_factor = param3;
   text_size = param4;
   bu_ob_color = param5;
   bu_ob_border_color = param6;
   bu_ob_text_color = param7;
   be_ob_color = param8;
   be_ob_border_color = param9;
   be_ob_text_color = param10;
   bu_bb_color = param11;
   bu_bb_border_color = param12;
   bu_bb_text_color = param13;
   be_bb_color = param14;
   be_bb_border_color = param15;
   be_bb_text_color = param16;
   SetIndexBuffer(0, ZoneBreakArrowUpBuffer);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, ZoneBreakArrowSize, ZoneBreakArrowUpColor);
   SetIndexArrow(0, ZoneBreakArrowUpCode);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexLabel(0, "Zone Break Up");
   SetIndexBuffer(1, ZoneBreakArrowDownBuffer);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, ZoneBreakArrowSize, ZoneBreakArrowDownColor);
   SetIndexArrow(1, ZoneBreakArrowDownCode);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexLabel(1, "Zone Break Down");
   SetIndexBuffer(2, TrendBreakArrowUpBuffer);
   SetIndexStyle(2, DRAW_ARROW, EMPTY, TrendBreakArrowSize, TrendBreakArrowUpColor);
   SetIndexArrow(2, TrendBreakArrowUpCode);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexLabel(2, "Trend Break Up");
   SetIndexBuffer(3, TrendBreakArrowDownBuffer);
   SetIndexStyle(3, DRAW_ARROW, EMPTY, TrendBreakArrowSize, TrendBreakArrowDownColor);
   SetIndexArrow(3, TrendBreakArrowDownCode);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexLabel(3, "Trend Break Down");
   highest1 = new HighestHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, zigzag_len);
   lowest1 = new LowestLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, zigzag_len);
   int id = 4;
   barssince1Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince1 = new BarsSinceStreamV2(barssince1Condition);
   lowest2 = new LowestLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, Nz((SafeGreater(last_trend_up_since, 0) ? last_trend_up_since : 1), 1));
   barssince2Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince2 = new BarsSinceStreamV2(barssince2Condition);
   barssince3Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince3 = new BarsSinceStreamV2(barssince3Condition);
   highest2 = new HighestHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, Nz((SafeGreater(last_trend_down_since, 0) ? last_trend_down_since : 1), 1));
   barssince4Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince4 = new BarsSinceStreamV2(barssince4Condition);
   change1Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   change2Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change2 = new ChangeStream(change2Source, 1);
   change3Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change3 = new ChangeStream(change3Source, 1);
   change4Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change4 = new ChangeStream(change4Source, 1);
   change5Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change5 = new ChangeStream(change5Source, 1);
   change6Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change6 = new ChangeStream(change6Source, 1);
   LinesCollection::SetMaxLines(500);
   LabelsCollection::SetMaxLabels(50);
   BoxesCollection::SetMaxBoxes(500);
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("MSB-OB");
   IndicatorShortName("Market Structure Break & Order Block");
   SetIndexBuffer(id++, trend);
   SetIndexBuffer(id++, to_up);
   SetIndexBuffer(id++, to_down);
   f_get_high_11 = new f_get_high_1Stream(0, IndicatorObjPrefix + "_1");
   id = f_get_high_11.Init(id);
   f_get_high_12 = new f_get_high_1Stream(1, IndicatorObjPrefix + "_2");
   id = f_get_high_12.Init(id);
   f_get_low_13 = new f_get_low_1Stream(0, IndicatorObjPrefix + "_3");
   id = f_get_low_13.Init(id);
   f_get_low_14 = new f_get_low_1Stream(1, IndicatorObjPrefix + "_4");
   id = f_get_low_14.Init(id);
   SetIndexBuffer(id++, market);
   valuewhen1 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen1.RegisterInternalStream(id);
   valuewhen2 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen2.RegisterInternalStream(id);
   SetIndexBuffer(id++, bu_ob_index);
   SetIndexBuffer(id++, l0i);
   SetIndexBuffer(id++, be_ob_index);
   SetIndexBuffer(id++, h0i);
   SetIndexBuffer(id++, be_bb_index);
   SetIndexBuffer(id++, bu_bb_index);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   if(high_points_arr != NULL)
      high_points_arr.Release();
   if(high_index_arr != NULL)
      high_index_arr.Release();
   if(low_points_arr != NULL)
      low_points_arr.Release();
   if(low_index_arr != NULL)
      low_index_arr.Release();
   if(bu_ob_boxes != NULL)
      bu_ob_boxes.Release();
   if(be_ob_boxes != NULL)
      be_ob_boxes.Release();
   if(bu_bb_boxes != NULL)
      bu_bb_boxes.Release();
   if(be_bb_boxes != NULL)
      be_bb_boxes.Release();
   highest1.Release();
   lowest1.Release();
   barssince1Condition.Release();
   barssince1.Release();
   lowest2.Release();
   barssince2Condition.Release();
   barssince2.Release();
   barssince3Condition.Release();
   barssince3.Release();
   highest2.Release();
   barssince4Condition.Release();
   barssince4.Release();
   change1Source.Release();
   change1.Release();
   delete f_get_high_11;
   delete f_get_high_12;
   delete f_get_low_13;
   delete f_get_low_14;
   change2Source.Release();
   change2.Release();
   change3Source.Release();
   change3.Release();
   valuewhen1.Release();
   change4Source.Release();
   change4.Release();
   valuewhen2.Release();
   change5Source.Release();
   change5.Release();
   change6Source.Release();
   change6.Release();
   LinesCollection::Clear(true);
   LabelsCollection::Clear(true);
   BoxesCollection::Clear(true);
   delete _signaler;
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   if(prev_calculated <= 0 || prev_calculated > rates_total)
     {
      LinesCollection::Clear();
      LabelsCollection::Clear();
      BoxesCollection::Clear();
      ISimpleTypeArray<double>* __array1 = new FloatArray(5, EMPTY_VALUE);
      if(high_points_arr != NULL)
         high_points_arr.Release();
      high_points_arr = __array1;
      high_points_arr.AddRef();
      ITArray<int>* __array2 = new IntArray(5, INT_MIN);
      if(high_index_arr != NULL)
         high_index_arr.Release();
      high_index_arr = __array2;
      high_index_arr.AddRef();
      ISimpleTypeArray<double>* __array3 = new FloatArray(5, EMPTY_VALUE);
      if(low_points_arr != NULL)
         low_points_arr.Release();
      low_points_arr = __array3;
      low_points_arr.AddRef();
      ITArray<int>* __array4 = new IntArray(5, INT_MIN);
      if(low_index_arr != NULL)
         low_index_arr.Release();
      low_index_arr = __array4;
      low_index_arr.AddRef();
      ICustomTypeArray<Box*>* __array5 = new BoxArray(5, NULL);
      if(bu_ob_boxes != NULL)
         bu_ob_boxes.Release();
      bu_ob_boxes = __array5;
      bu_ob_boxes.AddRef();
      ICustomTypeArray<Box*>* __array6 = new BoxArray(5, NULL);
      if(be_ob_boxes != NULL)
         be_ob_boxes.Release();
      be_ob_boxes = __array6;
      be_ob_boxes.AddRef();
      ICustomTypeArray<Box*>* __array7 = new BoxArray(5, NULL);
      if(bu_bb_boxes != NULL)
         bu_bb_boxes.Release();
      bu_bb_boxes = __array7;
      bu_bb_boxes.AddRef();
      ICustomTypeArray<Box*>* __array8 = new BoxArray(5, NULL);
      if(be_bb_boxes != NULL)
         be_bb_boxes.Release();
      be_bb_boxes = __array8;
      be_bb_boxes.AddRef();
      trend_DEFAULT_VALUE = 1;
      ArrayInitialize(trend, trend_DEFAULT_VALUE);
      to_up_DEFAULT_VALUE = (-1);
      ArrayInitialize(to_up, to_up_DEFAULT_VALUE);
      barssince1Condition.Init();
      barssince2Condition.Init();
      to_down_DEFAULT_VALUE = (-1);
      ArrayInitialize(to_down, to_down_DEFAULT_VALUE);
      barssince3Condition.Init();
      barssince4Condition.Init();
      change1Source.Init();
      f_get_high_11.Clear();
      f_get_high_12.Clear();
      f_get_low_13.Clear();
      f_get_low_14.Clear();
      change2Source.Init();
      market_DEFAULT_VALUE = 1;
      ArrayInitialize(market, market_DEFAULT_VALUE);
      change3Source.Init();
      change4Source.Init();
      bu_ob_index_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(bu_ob_index, bu_ob_index_DEFAULT_VALUE);
      l0i_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(l0i, l0i_DEFAULT_VALUE);
      be_ob_index_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(be_ob_index, be_ob_index_DEFAULT_VALUE);
      h0i_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(h0i, h0i_DEFAULT_VALUE);
      be_bb_index_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(be_bb_index, be_bb_index_DEFAULT_VALUE);
      bu_bb_index_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(bu_bb_index, bu_bb_index_DEFAULT_VALUE);
      change5Source.Init();
      change6Source.Init();
      __array8.Release();
      __array7.Release();
      __array6.Release();
      __array5.Release();
      __array4.Release();
      __array3.Release();
      __array2.Release();
      __array1.Release();
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
   for(int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
     {
      string settings = "Settings";
      string bu_ob_inline_color = "Bu-OB Colors";
      string be_ob_inline_color = "Be-OB Colors";
      string bu_bb_inline_color = "Bu-BB Colors";
      string be_bb_inline_color = "Be-BB Colors";
      string bu_ob_display_settings = "Bu-OB Display Settings";
      string be_ob_display_settings = "Be-OB Display Settings";
      string bu_bb_display_settings = "Bu-BB & Bu-MB Display Settings";
      string be_bb_display_settings = "Be-BB & Be-MB Display Settings";
      double highest1Value;
      if(!highest1.GetValue(pos, highest1Value))
        {
         highest1Value = EMPTY_VALUE;
        }
      SetStream(to_up, pos, SafeGE(high[pos], highest1Value), to_up_DEFAULT_VALUE);
      double lowest1Value;
      if(!lowest1.GetValue(pos, lowest1Value))
        {
         lowest1Value = EMPTY_VALUE;
        }
      SetStream(to_down, pos, SafeLE(low[pos], lowest1Value), to_down_DEFAULT_VALUE);
      SetStream(trend, pos, 1, trend_DEFAULT_VALUE);
      if(pos + 1 > (rates_total - 1))
        {
         continue;
        }
      SetStream(trend, pos, Nz(trend[pos + 1], 1), trend_DEFAULT_VALUE);
      SetStream(trend, pos, ((trend[pos] == 1) && to_down[pos] ? (-1) : ((trend[pos] == (-1)) && to_up[pos] ? 1 : trend[pos])), trend_DEFAULT_VALUE);
      if(pos + 1 > (rates_total - 1))
        {
         continue;
        }
      barssince1Condition.SetValue(pos, to_up[pos + 1]);
      int barssince1Value;
      if(!barssince1.GetValue(pos, barssince1Value))
        {
         barssince1Value = INT_MIN;
        }
      last_trend_up_since = barssince1Value;
      double lowest2Value;
      if(!lowest2.GetValue(pos, lowest2Value))
        {
         lowest2Value = EMPTY_VALUE;
        }
      double low_val = lowest2Value;
      barssince2Condition.SetValue(pos, (low_val == low[pos]));
      int barssince2Value;
      if(!barssince2.GetValue(pos, barssince2Value))
        {
         barssince2Value = INT_MIN;
        }
      int low_index = SafeMinus(((rates_total - 1) - pos), barssince2Value);
      if(pos + 1 > (rates_total - 1))
        {
         continue;
        }
      barssince3Condition.SetValue(pos, to_down[pos + 1]);
      int barssince3Value;
      if(!barssince3.GetValue(pos, barssince3Value))
        {
         barssince3Value = INT_MIN;
        }
      last_trend_down_since = barssince3Value;
      double highest2Value;
      if(!highest2.GetValue(pos, highest2Value))
        {
         highest2Value = EMPTY_VALUE;
        }
      double high_val = highest2Value;
      barssince4Condition.SetValue(pos, (high_val == high[pos]));
      int barssince4Value;
      if(!barssince4.GetValue(pos, barssince4Value))
        {
         barssince4Value = INT_MIN;
        }
      int high_index = SafeMinus(((rates_total - 1) - pos), barssince4Value);
      change1Source.SetValue(pos, trend[pos]);
      double change1Value;
      if(!change1.GetValue(pos, change1Value))
        {
         change1Value = EMPTY_VALUE;
        }
      if((change1Value != 0))
        {
         if((trend[pos] == 1))
           {
            Array::Push<ISimpleTypeArray<double>*, double>(low_points_arr, low_val);
            Array::Push<ITArray<int>*, int>(low_index_arr, low_index);
           }
         if((trend[pos] == (-1)))
           {
            Array::Push<ISimpleTypeArray<double>*, double>(high_points_arr, high_val);
            Array::Push<ITArray<int>*, int>(high_index_arr, high_index);
           }
        }
      double f_get_high_11Value1;
      int f_get_high_11Value2;
      if(!f_get_high_11.GetValue(pos, f_get_high_11Value1, f_get_high_11Value2))
        {
         f_get_high_11Value1 = EMPTY_VALUE;
         f_get_high_11Value2 = INT_MIN;
        }
      double h0 = f_get_high_11Value1;
      SetStream(h0i, pos, f_get_high_11Value2, h0i_DEFAULT_VALUE);
      double f_get_high_12Value1;
      int f_get_high_12Value2;
      if(!f_get_high_12.GetValue(pos, f_get_high_12Value1, f_get_high_12Value2))
        {
         f_get_high_12Value1 = EMPTY_VALUE;
         f_get_high_12Value2 = INT_MIN;
        }
      double h1 = f_get_high_12Value1;
      int h1i = f_get_high_12Value2;
      double f_get_low_13Value1;
      int f_get_low_13Value2;
      if(!f_get_low_13.GetValue(pos, f_get_low_13Value1, f_get_low_13Value2))
        {
         f_get_low_13Value1 = EMPTY_VALUE;
         f_get_low_13Value2 = INT_MIN;
        }
      double l0 = f_get_low_13Value1;
      SetStream(l0i, pos, f_get_low_13Value2, l0i_DEFAULT_VALUE);
      double f_get_low_14Value1;
      int f_get_low_14Value2;
      if(!f_get_low_14.GetValue(pos, f_get_low_14Value1, f_get_low_14Value2))
        {
         f_get_low_14Value1 = EMPTY_VALUE;
         f_get_low_14Value2 = INT_MIN;
        }
      double l1 = f_get_low_14Value1;
      int l1i = f_get_low_14Value2;
      change2Source.SetValue(pos, trend[pos]);
      double change2Value;
      if(!change2.GetValue(pos, change2Value))
        {
         change2Value = EMPTY_VALUE;
        }
      if((change2Value != 0) && show_zigzag)
        {
         if((trend[pos] == 1))
           {
            LinesCollection::Create(IndicatorObjPrefix + "line_1_id", h0i[pos], h0, l0i[pos], l0, time[pos]).SetWidth(1).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
           }
         if((trend[pos] == (-1)))
           {
            LinesCollection::Create(IndicatorObjPrefix + "line_2_id", l0i[pos], l0, h0i[pos], h0, time[pos]).SetWidth(1).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
           }
        }
      SetStream(market, pos, 1, market_DEFAULT_VALUE);
      if(pos + 1 > (rates_total - 1))
        {
         continue;
        }
      SetStream(market, pos, Nz(market[pos + 1], 1), market_DEFAULT_VALUE);
      change3Source.SetValue(pos, market[pos]);
      double change3Value;
      if(!change3.GetValue(pos, change3Value))
        {
         change3Value = EMPTY_VALUE;
        }
      double last_l0 = valuewhen1.Update(pos, time[pos], (change3Value != 0), l0);
      change4Source.SetValue(pos, market[pos]);
      double change4Value;
      if(!change4.GetValue(pos, change4Value))
        {
         change4Value = EMPTY_VALUE;
        }
      double last_h0 = valuewhen2.Update(pos, time[pos], (change4Value != 0), h0);
      SetStream(market, pos, (((last_l0 == l0) || (last_h0 == h0)) ? market[pos] : ((market[pos] == 1) && SafeLess(l0, l1) && SafeLess(l0, SafeMinus(l1, SafeMultiply(SafeMathAbs(SafeMinus(h0, l1)), fib_factor))) ? (-1) : ((market[pos] == (-1)) && SafeGreater(h0, h1) && SafeGreater(h0, SafePlus(h1, SafeMultiply(SafeMathAbs(SafeMinus(h1, l0)), fib_factor))) ? 1 : market[pos]))), market_DEFAULT_VALUE);
      SetStream(bu_ob_index, pos, ((rates_total - 1) - pos), bu_ob_index_DEFAULT_VALUE);
      if(pos + 1 > (rates_total - 1))
        {
         continue;
        }
      SetStream(bu_ob_index, pos, Nz(bu_ob_index[pos + 1], ((rates_total - 1) - pos)), bu_ob_index_DEFAULT_VALUE);
      if(pos + zigzag_len > (rates_total - 1))
        {
         continue;
        }
      int for1_from = h1i;
      int for1_to = l0i[pos + zigzag_len];
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if(for1_from == INT_MIN || for1_to == INT_MIN)
        {
         continue;
        }
      for(int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
        {
         int index = ((rates_total - 1) - pos) - i;
         if(pos + index > (rates_total - 1))
           {
            continue;
           }
         if(pos + index > (rates_total - 1))
           {
            continue;
           }
         if(SafeGreater(open[pos + index], close[pos + index]))
           {
            SetStream(bu_ob_index, pos, ((rates_total - 1) - index - pos), bu_ob_index_DEFAULT_VALUE);
           }
        }
      int bu_ob_since = ((rates_total - 1) - pos) - bu_ob_index[pos];
      SetStream(be_ob_index, pos, ((rates_total - 1) - pos), be_ob_index_DEFAULT_VALUE);
      if(pos + 1 > (rates_total - 1))
        {
         continue;
        }
      SetStream(be_ob_index, pos, Nz(be_ob_index[pos + 1], ((rates_total - 1) - pos)), be_ob_index_DEFAULT_VALUE);
      if(pos + zigzag_len > (rates_total - 1))
        {
         continue;
        }
      int for2_from = l1i;
      int for2_to = h0i[pos + zigzag_len];
      bool for2_forward = for2_from <= for2_to;
      int for2_step = 1 * (for2_forward ? 1 : -1);
      if(for2_from == INT_MIN || for2_to == INT_MIN)
        {
         continue;
        }
      for(int i = for2_from; (for2_forward ? i <= for2_to : i >= for2_to); i += for2_step)
        {
         int index = ((rates_total - 1) - pos) - i;
         if(pos + index > (rates_total - 1))
           {
            continue;
           }
         if(SafeLess(open[pos], close[pos + index]))
           {
            SetStream(be_ob_index, pos, ((rates_total - 1) - index - pos), be_ob_index_DEFAULT_VALUE);
           }
        }
      int be_ob_since = ((rates_total - 1) - pos) - be_ob_index[pos];
      SetStream(be_bb_index, pos, ((rates_total - 1) - pos), be_bb_index_DEFAULT_VALUE);
      if(pos + 1 > (rates_total - 1))
        {
         continue;
        }
      SetStream(be_bb_index, pos, Nz(be_bb_index[pos + 1], ((rates_total - 1) - pos)), be_bb_index_DEFAULT_VALUE);
      int for3_from = SafeMinus(h1i, zigzag_len);
      int for3_to = l1i;
      bool for3_forward = for3_from <= for3_to;
      int for3_step = 1 * (for3_forward ? 1 : -1);
      if(for3_from == INT_MIN || for3_to == INT_MIN)
        {
         continue;
        }
      for(int i = for3_from; (for3_forward ? i <= for3_to : i >= for3_to); i += for3_step)
        {
         int index = ((rates_total - 1) - pos) - i;
         if(pos + index > (rates_total - 1))
           {
            continue;
           }
         if(pos + index > (rates_total - 1))
           {
            continue;
           }
         if(SafeGreater(open[pos + index], close[pos + index]))
           {
            SetStream(be_bb_index, pos, ((rates_total - 1) - index - pos), be_bb_index_DEFAULT_VALUE);
           }
        }
      int be_bb_since = ((rates_total - 1) - pos) - be_bb_index[pos];
      SetStream(bu_bb_index, pos, ((rates_total - 1) - pos), bu_bb_index_DEFAULT_VALUE);
      if(pos + 1 > (rates_total - 1))
        {
         continue;
        }
      SetStream(bu_bb_index, pos, Nz(bu_bb_index[pos + 1], ((rates_total - 1) - pos)), bu_bb_index_DEFAULT_VALUE);
      int for4_from = SafeMinus(l1i, zigzag_len);
      int for4_to = h1i;
      bool for4_forward = for4_from <= for4_to;
      int for4_step = 1 * (for4_forward ? 1 : -1);
      if(for4_from == INT_MIN || for4_to == INT_MIN)
        {
         continue;
        }
      for(int i = for4_from; (for4_forward ? i <= for4_to : i >= for4_to); i += for4_step)
        {
         int index = ((rates_total - 1) - pos) - i;
         if(pos + index > (rates_total - 1))
           {
            continue;
           }
         if(SafeLess(open[pos], close[pos + index]))
           {
            SetStream(bu_bb_index, pos, ((rates_total - 1) - index - pos), bu_bb_index_DEFAULT_VALUE);
           }
        }
      int bu_bb_since = ((rates_total - 1) - pos) - bu_bb_index[pos];
      change5Source.SetValue(pos, market[pos]);
      double change5Value;
      if(!change5.GetValue(pos, change5Value))
        {
         change5Value = EMPTY_VALUE;
        }
      if((change5Value != 0))
        {
         if((market[pos] == 1))
           {
            LinesCollection::Create(IndicatorObjPrefix + "line_3_id", h1i, h1, h0i[pos], h1, time[pos]).SetColor(Green).SetWidth(2).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
            LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", (int)(SafeDivide((SafePlus(h1i, l0i[pos])), 2)), h1, time[pos]).SetColor(AddTransparency(Black, 100)).SetText("MSB").SetTextColor(Green).SetStyle("down").SetSize("small").SetYLoc("price").SetTextAlign("center");
            if(pos + bu_ob_since > (rates_total - 1) || pos + bu_ob_since < 0 || bu_ob_since < 0)
              {
               continue;
              }
            Box* bu_ob = BoxesCollection::Create(IndicatorObjPrefix + "box_1_id", bu_ob_index[pos], high[pos + bu_ob_since], ((rates_total - 1) - pos) + 10, low[pos + bu_ob_since], time[pos])
                         .SetBgColor(bu_ob_color)
                         .SetBorderColor(bu_ob_border_color)
                         .SetExtend("none")
                         .SetText("Bu-OB")
                         .SetTextColor(bu_ob_text_color)
                         .SetTextHAlign("right")
                         .SetTextVAlign("center")
                         .SetTextSize(text_size);
            if(pos + bu_bb_since > (rates_total - 1) || pos + bu_bb_since < 0 || bu_bb_since < 0)
              {
               continue;
              }
            Box* bu_bb = BoxesCollection::Create(IndicatorObjPrefix + "box_2_id", bu_bb_index[pos], high[pos + bu_bb_since], ((rates_total - 1) - pos) + 10, low[pos + bu_bb_since], time[pos])
                         .SetBgColor(bu_bb_color)
                         .SetBorderColor(bu_bb_border_color)
                         .SetExtend("none")
                         .SetText((SafeLess(l0, l1) ? "Bu-BB" : "Bu-MB"))
                         .SetTextColor(bu_bb_text_color)
                         .SetTextHAlign("right")
                         .SetTextVAlign("center")
                         .SetTextSize(text_size);
            Array::Push<ICustomTypeArray<Box*>*, Box*>(bu_ob_boxes, bu_ob);
            Array::Push<ICustomTypeArray<Box*>*, Box*>(bu_bb_boxes, bu_bb);
           }
         if((market[pos] == (-1)))
           {
            LinesCollection::Create(IndicatorObjPrefix + "line_4_id", l1i, l1, l0i[pos], l1, time[pos]).SetColor(Red).SetWidth(2).SetStyle("solid").SetExtend("none").SetXLoc("bar_index");
            LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", (int)(SafeDivide((SafePlus(l1i, h0i[pos])), 2)), l1, time[pos]).SetColor(AddTransparency(Black, 100)).SetText("MSB").SetTextColor(Red).SetStyle("up").SetSize("small").SetYLoc("price").SetTextAlign("center");
            if(pos + be_ob_since > (rates_total - 1) || pos + be_ob_since < 0 || be_ob_since < 0)
              {
               continue;
              }
            Box* be_ob = BoxesCollection::Create(IndicatorObjPrefix + "box_3_id", be_ob_index[pos], high[pos + be_ob_since], ((rates_total - 1) - pos) + 10, low[pos + be_ob_since], time[pos])
                         .SetBgColor(be_ob_color)
                         .SetBorderColor(be_ob_border_color)
                         .SetExtend("none")
                         .SetText("Be-OB")
                         .SetTextColor(be_ob_text_color)
                         .SetTextHAlign("right")
                         .SetTextVAlign("center")
                         .SetTextSize(text_size);
            if(pos + be_bb_since > (rates_total - 1) || pos + be_bb_since < 0 || be_bb_since < 0)
              {
               continue;
              }
            Box* be_bb = BoxesCollection::Create(IndicatorObjPrefix + "box_4_id", be_bb_index[pos], high[pos + be_bb_since], ((rates_total - 1) - pos) + 10, low[pos + be_bb_since], time[pos])
                         .SetBgColor(be_bb_color)
                         .SetBorderColor(be_bb_border_color)
                         .SetExtend("none")
                         .SetText((SafeGreater(h0, h1) ? "Be-BB" : "Be-MB"))
                         .SetTextColor(be_bb_text_color)
                         .SetTextHAlign("right")
                         .SetTextVAlign("center")
                         .SetTextSize(text_size);
            Array::Push<ICustomTypeArray<Box*>*, Box*>(be_ob_boxes, be_ob);
            Array::Push<ICustomTypeArray<Box*>*, Box*>(be_bb_boxes, be_bb);
           }
        }
      ICustomTypeArray<Box*>* foreach1_items = bu_ob_boxes;
      for(int foreach1_index = 0; foreach1_index < Array::Size<int, ICustomTypeArray<Box*>*>(foreach1_items, INT_MIN); ++foreach1_index)
        {
         Box* bull_ob = Array::Get<Box*, ICustomTypeArray<Box*>*, int>(foreach1_items, foreach1_index, NULL);
         double bottom = Box::GetBottom(bull_ob);
         if(SafeLess(close[pos], bottom))
           {
            BoxesCollection::Delete(bull_ob);
           }
         else
            if((Array::Size<int, ICustomTypeArray<Box*>*>(bu_ob_boxes, INT_MIN) == 5))
              {
               BoxesCollection::Delete(Array::Shift<Box*, ICustomTypeArray<Box*>*>(bu_ob_boxes, NULL));
              }
            else
              {
               Box::SetRight(bull_ob, ((rates_total - 1) - pos) + 10);
              }
        }
      ICustomTypeArray<Box*>* foreach2_items = be_ob_boxes;
      for(int foreach2_index = 0; foreach2_index < Array::Size<int, ICustomTypeArray<Box*>*>(foreach2_items, INT_MIN); ++foreach2_index)
        {
         Box* bear_ob = Array::Get<Box*, ICustomTypeArray<Box*>*, int>(foreach2_items, foreach2_index, NULL);
         double top = Box::GetTop(bear_ob);
         if(SafeGreater(close[pos], top))
           {
            BoxesCollection::Delete(bear_ob);
           }
         else
            if((Array::Size<int, ICustomTypeArray<Box*>*>(be_ob_boxes, INT_MIN) == 5))
              {
               BoxesCollection::Delete(Array::Shift<Box*, ICustomTypeArray<Box*>*>(be_ob_boxes, NULL));
              }
            else
              {
               Box::SetRight(bear_ob, ((rates_total - 1) - pos) + 10);
              }
        }
      ICustomTypeArray<Box*>* foreach3_items = be_bb_boxes;
      for(int foreach3_index = 0; foreach3_index < Array::Size<int, ICustomTypeArray<Box*>*>(foreach3_items, INT_MIN); ++foreach3_index)
        {
         Box* bear_bb = Array::Get<Box*, ICustomTypeArray<Box*>*, int>(foreach3_items, foreach3_index, NULL);
         double top = Box::GetTop(bear_bb);
         if(SafeGreater(close[pos], top))
           {
            BoxesCollection::Delete(bear_bb);
           }
         else
            if((Array::Size<int, ICustomTypeArray<Box*>*>(be_bb_boxes, INT_MIN) == 5))
              {
               BoxesCollection::Delete(Array::Shift<Box*, ICustomTypeArray<Box*>*>(be_bb_boxes, NULL));
              }
            else
              {
               Box::SetRight(bear_bb, ((rates_total - 1) - pos) + 10);
              }
        }
      ICustomTypeArray<Box*>* foreach4_items = bu_bb_boxes;
      for(int foreach4_index = 0; foreach4_index < Array::Size<int, ICustomTypeArray<Box*>*>(foreach4_items, INT_MIN); ++foreach4_index)
        {
         Box* bull_bb = Array::Get<Box*, ICustomTypeArray<Box*>*, int>(foreach4_items, foreach4_index, NULL);
         double bottom = Box::GetBottom(bull_bb);
         if(SafeLess(close[pos], bottom))
           {
            BoxesCollection::Delete(bull_bb);
           }
         else
            if((Array::Size<int, ICustomTypeArray<Box*>*>(bu_bb_boxes, INT_MIN) == 5))
              {
               BoxesCollection::Delete(Array::Shift<Box*, ICustomTypeArray<Box*>*>(bu_bb_boxes, NULL));
              }
            else
              {
               Box::SetRight(bull_bb, ((rates_total - 1) - pos) + 10);
              }
        }
      change6Source.SetValue(pos, market[pos]);
      double change6Value;
      if(!change6.GetValue(pos, change6Value))
        {
         change6Value = EMPTY_VALUE;
        }
     }
   if(ShowZoneBreakArrows)
      DetectZoneBreakouts(rates_total, time, open, high, low, close);
   if(ShowTrendBreakArrows)
      DetectTrendBreakouts(rates_total, time, open, high, low, close);
   CheckArrowAlerts(rates_total, time, close);
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LinesCollection::Redraw();
   LabelsCollection::Redraw();
   BoxesCollection::Redraw();
   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectZoneBreakouts(int rates_total, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
  {
   if(!ShowZoneBreakArrows)
      return;
   bool timeSeries = ArrayGetAsSeries(time);
   bool openSeries = ArrayGetAsSeries(open);
   bool highSeries = ArrayGetAsSeries(high);
   bool lowSeries = ArrayGetAsSeries(low);
   bool closeSeries = ArrayGetAsSeries(close);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   int clear_limit = MathMin(100, rates_total);
   for(int i = 0; i < clear_limit; i++)
     {
      ZoneBreakArrowUpBuffer[i] = EMPTY_VALUE;
      ZoneBreakArrowDownBuffer[i] = EMPTY_VALUE;
     }
   double offset_price = ZoneBreakArrowOffset * Point();
   int max_bars_check = MathMin(500, rates_total);
   for(int obj = ObjectsTotal() - 1; obj >= 0; obj--)
     {
      string obj_name = ObjectName(obj);
      if(StringFind(obj_name, "MSB-OB_") != 0)
         continue;
      if(ObjectType(obj_name) != OBJ_RECTANGLE)
         continue;
      datetime time1 = (datetime)ObjectGet(obj_name, OBJPROP_TIME1);
      double price1 = ObjectGet(obj_name, OBJPROP_PRICE1);
      datetime time2 = (datetime)ObjectGet(obj_name, OBJPROP_TIME2);
      double price2 = ObjectGet(obj_name, OBJPROP_PRICE2);
      if(time1 == 0)
         continue;
      double zone_high = MathMax(price1, price2);
      double zone_low = MathMin(price1, price2);
      int start_bar = iBarShift(NULL, 0, time1);
      if(start_bar <= 1 || start_bar > max_bars_check)
         continue;
      for(int bar = start_bar; bar >= 1; bar--)
        {
         if(ZoneBreakArrowUpBuffer[bar] != EMPTY_VALUE || ZoneBreakArrowDownBuffer[bar] != EMPTY_VALUE)
            break;
         if(close[bar] > zone_high && close[bar] > open[bar] &&
            (open[bar] < zone_high || close[bar + 1] < zone_high))
           {
            ZoneBreakArrowUpBuffer[bar] = low[bar] - offset_price;
            break;
           }
         if(close[bar] < zone_low && close[bar] < open[bar] &&
            (open[bar] > zone_low || close[bar + 1] > zone_low))
           {
            ZoneBreakArrowDownBuffer[bar] = high[bar] + offset_price;
            break;
           }
        }
     }
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetectTrendBreakouts(int rates_total, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
  {
   if(!ShowTrendBreakArrows)
      return;
   bool timeSeries = ArrayGetAsSeries(time);
   bool openSeries = ArrayGetAsSeries(open);
   bool highSeries = ArrayGetAsSeries(high);
   bool lowSeries = ArrayGetAsSeries(low);
   bool closeSeries = ArrayGetAsSeries(close);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   int clear_limit = MathMin(100, rates_total);
   for(int i = 0; i < clear_limit; i++)
     {
      TrendBreakArrowUpBuffer[i] = EMPTY_VALUE;
      TrendBreakArrowDownBuffer[i] = EMPTY_VALUE;
     }
   double offset_price = TrendBreakArrowOffset * Point();
   int max_bars_check = MathMin(500, rates_total);
   for(int obj = ObjectsTotal() - 1; obj >= 0; obj--)
     {
      string obj_name = ObjectName(obj);
      if(StringFind(obj_name, IndicatorObjPrefix) != 0)
         continue;
      if(StringFind(obj_name, "MSB-OB_0line_3") < 0 && StringFind(obj_name, "MSB-OB_0line_4") < 0)
         continue;
      if(ObjectType(obj_name) == OBJ_TREND)
        {
         datetime time1 = (datetime)ObjectGet(obj_name, OBJPROP_TIME1);
         double price1 = ObjectGet(obj_name, OBJPROP_PRICE1);
         datetime time2 = (datetime)ObjectGet(obj_name, OBJPROP_TIME2);
         double price2 = ObjectGet(obj_name, OBJPROP_PRICE2);
         if(time1 == 0 || time2 == 0)
            continue;
         datetime earliest_time = (time1 < time2) ? time1 : time2;
         datetime latest_time = (time1 > time2) ? time1 : time2;
         int start_bar = iBarShift(NULL, 0, earliest_time);
         int end_bar = iBarShift(NULL, 0, latest_time);
         if(start_bar <= 1 || start_bar > max_bars_check)
            continue;
         double time_diff = (double)(time2 - time1);
         if(time_diff == 0)
            continue;
         double price_diff = price2 - price1;
         for(int bar = start_bar; bar >= end_bar && bar >= 1; bar--)
           {
            if(TrendBreakArrowUpBuffer[bar] != EMPTY_VALUE || TrendBreakArrowDownBuffer[bar] != EMPTY_VALUE)
               break;
            datetime bar_time = time[bar];
            if(bar_time < earliest_time || bar_time > latest_time)
               continue;
            double bar_time_diff = (double)(bar_time - time1);
            double trend_price = price1 + (price_diff / time_diff) * bar_time_diff;
            if(close[bar] > trend_price && close[bar] > open[bar] &&
               (open[bar] < trend_price || close[bar + 1] < trend_price))
              {
               TrendBreakArrowUpBuffer[bar] = low[bar] - offset_price;
               break;
              }
            if(close[bar] < trend_price && close[bar] < open[bar] &&
               (open[bar] > trend_price || close[bar + 1] > trend_price))
              {
               TrendBreakArrowDownBuffer[bar] = high[bar] + offset_price;
               break;
              }
           }
        }
     }
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckArrowAlerts(int rates_total, const datetime &time[], const double &close[])
  {
   if(ArrowAlertLookbackBars <= 0 || _signaler == NULL)
      return;
   bool timeSeries = ArrayGetAsSeries(time);
   bool closeSeries = ArrayGetAsSeries(close);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(close, true);
   static datetime last_alert_time = 0;
   static datetime alerted_arrows[];
   if(time[0] == last_alert_time)
     {
      ArraySetAsSeries(time, timeSeries);
      ArraySetAsSeries(close, closeSeries);
      return;
     }
   int lookback_limit = MathMin(ArrowAlertLookbackBars, rates_total - 1);
   for(int bar = 1; bar <= lookback_limit; bar++)
     {
      datetime bar_time = time[bar];
      bool already_alerted = false;
      for(int i = 0; i < ArraySize(alerted_arrows); i++)
        {
         if(alerted_arrows[i] == bar_time)
           {
            already_alerted = true;
            break;
           }
        }
      if(already_alerted)
         continue;
      if(ShowZoneBreakArrows)
        {
         if(ZoneBreakArrowUpBuffer[bar] != EMPTY_VALUE)
           {
            _signaler.SendNotifications("Arrow Alert", "ZONE BREAK UP - Price: " + DoubleToString(close[bar], _Digits));
            int size = ArraySize(alerted_arrows);
            ArrayResize(alerted_arrows, size + 1);
            alerted_arrows[size] = bar_time;
            last_alert_time = time[0];
            ArraySetAsSeries(time, timeSeries);
            ArraySetAsSeries(close, closeSeries);
            return;
           }
         if(ZoneBreakArrowDownBuffer[bar] != EMPTY_VALUE)
           {
            _signaler.SendNotifications("Arrow Alert", "ZONE BREAK DOWN - Price: " + DoubleToString(close[bar], _Digits));
            int size = ArraySize(alerted_arrows);
            ArrayResize(alerted_arrows, size + 1);
            alerted_arrows[size] = bar_time;
            last_alert_time = time[0];
            ArraySetAsSeries(time, timeSeries);
            ArraySetAsSeries(close, closeSeries);
            return;
           }
        }
      if(ShowTrendBreakArrows)
        {
         if(TrendBreakArrowUpBuffer[bar] != EMPTY_VALUE)
           {
            _signaler.SendNotifications("Arrow Alert", "TREND BREAK UP - Price: " + DoubleToString(close[bar], _Digits));
            int size = ArraySize(alerted_arrows);
            ArrayResize(alerted_arrows, size + 1);
            alerted_arrows[size] = bar_time;
            last_alert_time = time[0];
            ArraySetAsSeries(time, timeSeries);
            ArraySetAsSeries(close, closeSeries);
            return;
           }
         if(TrendBreakArrowDownBuffer[bar] != EMPTY_VALUE)
           {
            _signaler.SendNotifications("Arrow Alert", "TREND BREAK DOWN - Price: " + DoubleToString(close[bar], _Digits));
            int size = ArraySize(alerted_arrows);
            ArrayResize(alerted_arrows, size + 1);
            alerted_arrows[size] = bar_time;
            last_alert_time = time[0];
            ArraySetAsSeries(time, timeSeries);
            ArraySetAsSeries(close, closeSeries);
            return;
           }
        }
     }
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(close, closeSeries);
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Market_Structure_Break_and_Order_Block_v3
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160983#p160983
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
