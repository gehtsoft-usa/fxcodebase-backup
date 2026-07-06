//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160833#p160833
License:     GNU
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
#property indicator_buffers 0

#property indicator_label1 "Arrow Up"
#property  indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property  indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

double ArrowUp[];
double ArrowDn[];
input bool   ArrowsOn              = true;                   // Arrows On?

// Array v1.1
// Array interface v1.0

// int array interface v1.1

class IIntArray
{
public:
   virtual void Unshift(int value) = 0;
   virtual int Size() = 0;
   virtual void Push(int value) = 0;
   virtual int Pop() = 0;
   virtual int Get(int index) = 0;
   virtual IIntArray* Slice(int from, int to) = 0;
   virtual IIntArray* Clear() = 0;
   virtual int Shift() = 0;
   virtual int Remove(int index) = 0;
};
// Line array interface v1.1
// Line object v1.2

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
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window)
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
   virtual ILineArray* Slice(int from, int to) = 0;
   virtual ILineArray* Clear() = 0;
   virtual Line* Shift() = 0;
   virtual Line* Remove(int index) = 0;
};
// float array interface v1.1

class IFloatArray
{
public:
   virtual void Unshift(double value) = 0;
   virtual int Size() = 0;
   virtual void Push(double value) = 0;
   virtual double Pop() = 0;
   virtual double Get(int index) = 0;
   virtual IFloatArray* Slice(int from, int to) = 0;
   virtual IFloatArray* Clear() = 0;
   virtual double Shift() = 0;
   virtual double Remove(int index) = 0;
};


#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v1.2

// Collection of lines v1.1

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

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId)
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
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, WindowOnDropped());
      LinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(line);
      _all.Add(line);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
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
      return _array[index];
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
};
#endif
// Int array v1.2


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
      return _array[index];
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
};
// Float array v1.2


class FloatArray : public IFloatArray
{
   double _array[];
   int _defaultSize;
   double _defaultValue;
public:
   FloatArray(int size, double defaultValue)
   {
      _defaultSize = size;
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
      return _array[index];
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
};
#ifndef BoxArray_IMPL
#define BoxArray_IMPL
// Box array v1.2
// Box array interface v1.0
#ifndef Box_IMPL
#define Box_IMPL

// Box object v1.2

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
   int _refs;
public:
   Box(int left, double top, int right, double bottom, string id, string collectionId, int window)
   {
      _refs = 1;
      _left = left;
      _right = right;
      _top = top;
      _bottom = bottom;
      _id = id;
      _collectionId = collectionId;
      _window = window;
      _extend = "none";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
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

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
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

   static void SetBgColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBgColor(clr); }
   Box* SetBgColor(color clr) { _bgcolor = clr; return &this; }
   static void SetBorderColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBorderColor(clr); }
   Box* SetBorderColor(color clr) { _borderColor = clr; return &this; }
   static void SetExtend(Box* box, string extend) { if (box == NULL) { return; } box.SetExtend(extend); }
   Box* SetExtend(string extend) { _extend = extend; return &this; }

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
   virtual IBoxArray* Slice(int from, int to) = 0;
   virtual IBoxArray* Clear() = 0;
   virtual Box* Shift() = 0;
   virtual Box* Remove(int index) = 0;
};
// Collection of boxes v1.1

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
      if (!_all.RemoveItem(box))
      {
         return;
      }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(box);
   }

   static Box* Create(string id, int left, double top, int right, double bottom, datetime dateId)
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
      
      Box* box = new Box(left, top, right, bottom, boxId, id, WindowOnDropped());
      BoxesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new BoxesCollection(id);
         AddCollection(collection);
      }
      collection.Add(box);
      _all.Add(box);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
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

   bool RemoveItem(Box* box)
   {
      int index = FindIndex(box);
      if (index == -1)
      {
         return false;
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      return true;
   }
   void DeleteItem(Box* box)
   {
      if (RemoveItem(box))
      {
         box.Release();
      }
   }
   
   void Add(Box* box)
   {
      int index = FindIndex(box);
      
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = box;
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
      if (value.Release() == 0)
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
      return _array[index];
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
};
#endif

class Array
{
public:
   static void Unshift(IIntArray* array, int value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IFloatArray* array, double value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Unshift(value); }
   
   static int Size(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(ILineArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IBoxArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }

   static int Shift(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static double Shift(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static Line* Shift(ILineArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static Box* Shift(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }

   static void Push(IIntArray* array, int value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IFloatArray* array, double value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Push(value); }

   static int Pop(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static double Pop(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static Line* Pop(ILineArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static Box* Pop(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }

   static int Get(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static double Get(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static Line* Get(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   static Box* Get(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }

   static int Remove(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static double Remove(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static Line* Remove(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }
   static Box* Remove(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }

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
};


// Pine-script like safe operations
// v.1.0

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
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
      return (bool)EMPTY_VALUE;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return (bool)EMPTY_VALUE;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return (bool)EMPTY_VALUE;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return (bool)EMPTY_VALUE;
   }
   return left <= right;
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


// Highest high stream v1.5

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _loopback = loopback;
      _source.Release();
   }
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      if (!source.GetValue(period, val))
         return false;

      for (int i = 1; i < loopback; ++i)
      {
         double value;
         if (!source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
      }
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return HighestHighStream::GetValue(period, val, _source, _loopback);
   }
};




// Lowest low stream v1.5

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _loopback = loopback;
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      if (!source.GetValue(period, val))
         return false;

      for (int i = 1; i < loopback; ++i)
      {
         double value;
         if (!source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
      }
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return LowestLowStream::GetValue(period, val, _source, _loopback);
   }
};
// Custom boolean stream v1.0

#ifndef BoolStream_IMPL
#define BoolStream_IMPL

// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
// Boolean Stream v.1.0

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, bool &val) = 0;
};

#endif

class ABoolStream : public IBoolStream
{
   int _refs;   
public:
   ABoolStream()
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

class BoolStream : public ABoolStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   bool _stream[];
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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

   void SetValue(const int period, bool value)
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

   bool GetValue(const int period, bool &val)
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
#ifndef BarsSinceStreamV2_IMPL
#define BarsSinceStreamV2_IMPL

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


// Counts number of bars since last condition.
// v1.01

class BarsSinceStreamV2 : public AIntStream
{
   IBoolStream* _condition;
   int _bars[];
public:
   BarsSinceStreamV2(IBoolStream* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~BarsSinceStreamV2()
   {
      _condition.Release();
   }

   int Size()
   {
      return _condition.Size();
   }

   virtual bool GetValue(const int period, int &val)
   {
      int size = Size();
      if (period >= size)
      {
         return false;
      }
      if (ArraySize(_bars) < size)
      {
         ArrayResize(_bars, size);
      }
      int index = size - period - 1;
      if (_bars[index] == 0)
      {
         FillHistory(period);
      }
      val = _bars[index];
      return true;
   }
private:
   void FillHistory(int period)
   {
      int size = Size();
      for (int periodIndex = period; periodIndex < size; ++periodIndex)
      {
         int index = size - periodIndex - 1;
         bool val;
         if (!_condition.GetValue(periodIndex, val) || !val)
         {
            if (_bars[index] == 0)
            {
               continue;
            }
         }
         else
         {
            _bars[index] = 0;
         }
         for (int ii = index + 1; ii <= size - period - 1; ++ii)
         {
            _bars[ii] = _bars[ii - 1] + 1;
         }
         return;
      }
   }
};
#endif
// Custom integer stream v1.1

#ifndef IntStream_IMPL
#define IntStream_IMPL



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

// Value when stream (condition as a parameter) v1.0


// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

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
// Collection of labels v1.1

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.2

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   color _color;
   color _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   int _window;
public:
   Label(int x, double y, string labelId, string collectionId, int window)
   {
      _refs = 1;
      _window = window;
      _textColor = Yellow;
      _x = x;
      _y = y;
      _labelId = labelId;
      _collectionId = collectionId;
      _font = "Arial";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
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
   void SetX(int x)
   {
      _x = x;
   }
   static void SetX(Label* label, int x)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetX(x);
   }
   void SetY(double y)
   {
      _y = y;
   }
   static void SetY(Label* label, double y)
   {
      if (label == NULL)
      {
         return;
      }
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

   static Label* Create(string id, int x, double y, datetime dateId)
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
      Label* label = new Label(x, y, labelId, id, WindowOnDropped());
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      _all.Add(label);
      if (_all.Count() > _maxLabels)
      {
         Delete(_all.GetFirst());
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

input int param1 = 9; // ZigZag Length
input bool param2 = true; // Show Zigzag
input double param3 = 0.33; // Fib Factor for breakout confirmation
input string param4 = "tiny"; // Text Size
input color param5 = Green; // Color
input color param6 = Green; // Border Color
input color param7 = Green; // Text Color
input color param8 = Red; // Color
input color param9 = Red; // Border Color
input color param10 = Red; // Text Color
input color param11 = Green; // Color
input color param12 = Green; // Border Color
input color param13 = Green; // Text Color
input color param14 = Red; // Color
input color param15 = Red; // Border Color
input color param16 = Red; // Text Color
input int bars_limit = 100000; // Bars limit
int zigzag_len;
bool show_zigzag;
double fib_factor;
string text_size;
color bu_ob_color;
color bu_ob_border_color;
color bu_ob_text_color;
color be_ob_color;
color be_ob_border_color;
color be_ob_text_color;
color bu_bb_color;
color bu_bb_border_color;
color bu_bb_text_color;
color be_bb_color;
color be_bb_border_color;
color be_bb_text_color;
IFloatArray* high_points_arr;
IFloatArray* __array1;
IIntArray* high_index_arr;
IIntArray* __array2;
IFloatArray* low_points_arr;
IFloatArray* __array3;
IIntArray* low_index_arr;
IIntArray* __array4;
IBoxArray* bu_ob_boxes;
IBoxArray* __array5;
IBoxArray* be_ob_boxes;
IBoxArray* __array6;
IBoxArray* bu_bb_boxes;
IBoxArray* __array7;
IBoxArray* be_bb_boxes;
IBoxArray* __array8;
HighestHighStream* highest1;
LowestLowStream* lowest1;
double trend[];
int last_trend_up_since;
BoolStream* barssince1Condition;
BarsSinceStreamV2* barssince1;
double to_up[];
LowestLowStream* lowest2;
BoolStream* barssince2Condition;
BarsSinceStreamV2* barssince2;
int last_trend_down_since;
BoolStream* barssince3Condition;
BarsSinceStreamV2* barssince3;
double to_down[];
HighestHighStream* highest2;
BoolStream* barssince4Condition;
BarsSinceStreamV2* barssince4;
IntStream* change1Source;
ChangeStream* change1;
class f_get_high_iStream
{
   int ind;
   bool _initialized;
public:
   f_get_high_iStream(int ind)
   {
      _initialized = false;
      this.ind = ind;
   }
   ~f_get_high_iStream()
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
   bool GetValue(const int pos, double &__out1, int &__out2)
   {
      __out1 = Array::Get(high_points_arr, SafeMinus(SafeMinus(Array::Size(high_points_arr), 1), ind));
      __out2 = Array::Get(high_index_arr, SafeMinus(SafeMinus(Array::Size(high_index_arr), 1), ind));
      return true;
   }
};
f_get_high_iStream* f_get_high_i1;
f_get_high_iStream* f_get_high_i2;
class f_get_low_iStream
{
   int ind;
   bool _initialized;
public:
   f_get_low_iStream(int ind)
   {
      _initialized = false;
      this.ind = ind;
   }
   ~f_get_low_iStream()
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
   bool GetValue(const int pos, double &__out1, int &__out2)
   {
      __out1 = Array::Get(low_points_arr, SafeMinus(SafeMinus(Array::Size(low_points_arr), 1), ind));
      __out2 = Array::Get(low_index_arr, SafeMinus(SafeMinus(Array::Size(low_index_arr), 1), ind));
      return true;
   }
};
f_get_low_iStream* f_get_low_i3;
f_get_low_iStream* f_get_low_i4;
IntStream* change2Source;
ChangeStream* change2;
double market[];
IntStream* change3Source;
ChangeStream* change3;
ValueWhenSimpleStream* valuewhen1;
IntStream* change4Source;
ChangeStream* change4;
ValueWhenSimpleStream* valuewhen2;
double bu_ob_index[];
double l0i[];
double be_ob_index[];
double h0i[];
double be_bb_index[];
double bu_bb_index[];
IntStream* change5Source;
ChangeStream* change5;
Signaler* _signaler;
IntStream* change6Source;
ChangeStream* change6;

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

// Mark: init
int init()
{
   IndicatorBuffers(14);
   int id = 0;

   // -------------
   int id_up =id++; 
   int id_dn =id++; 
   SetIndexBuffer(id_up, ArrowUp, INDICATOR_DATA); 
   SetIndexArrow(id_up, 233);
   SetIndexStyle(id_up, DRAW_ARROW, EMPTY, 1, Blue);
   SetIndexBuffer(id_dn, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(id_dn, DRAW_ARROW, EMPTY, 1, Crimson);
   SetIndexArrow(id_dn, 234);
   if (!ArrowsOn)
   {
      SetIndexStyle(id_up, DRAW_NONE);
      SetIndexStyle(id_dn, DRAW_NONE);
   }

   // -------------



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
   highest1 = new HighestHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, zigzag_len);
   lowest1 = new LowestLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, zigzag_len);
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
   LabelsCollection::SetMaxLabels(50);
   BoxesCollection::SetMaxBoxes(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("MSB-OB");
   IndicatorShortName("Market Structure Break & Order Block");
   __array1 = new FloatArray(5, NULL);
   __array2 = new IntArray(5, NULL);
   __array3 = new FloatArray(5, NULL);
   __array4 = new IntArray(5, NULL);
   __array5 = new BoxArray(5, NULL);
   __array6 = new BoxArray(5, NULL);
   __array7 = new BoxArray(5, NULL);
   __array8 = new BoxArray(5, NULL);
   SetIndexBuffer(id++, trend);
   SetIndexBuffer(id++, to_up);
   SetIndexBuffer(id++, to_down);
   f_get_high_i1 = new f_get_high_iStream(0);
   id = f_get_high_i1.Init(id);
   f_get_high_i2 = new f_get_high_iStream(1);
   id = f_get_high_i2.Init(id);
   f_get_low_i3 = new f_get_low_iStream(0);
   id = f_get_low_i3.Init(id);
   f_get_low_i4 = new f_get_low_iStream(1);
   id = f_get_low_i4.Init(id);
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

   

   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete __array1;
   delete __array2;
   delete __array3;
   delete __array4;
   delete __array5;
   delete __array6;
   delete __array7;
   delete __array8;
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
   delete f_get_high_i1;
   delete f_get_high_i2;
   delete f_get_low_i3;
   delete f_get_low_i4;
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

// Mark: OnCalc
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
      LinesCollection::Clear();
      LabelsCollection::Clear();
      BoxesCollection::Clear();
      high_points_arr = __array1.Clear();
      high_index_arr = __array2.Clear();
      low_points_arr = __array3.Clear();
      low_index_arr = __array4.Clear();
      bu_ob_boxes = __array5.Clear();
      be_ob_boxes = __array6.Clear();
      bu_bb_boxes = __array7.Clear();
      be_bb_boxes = __array8.Clear();
      ArrayInitialize(trend, 1);
      ArrayInitialize(to_up, EMPTY_VALUE);
      barssince1Condition.Init();
      barssince2Condition.Init();
      ArrayInitialize(to_down, EMPTY_VALUE);
      barssince3Condition.Init();
      barssince4Condition.Init();
      change1Source.Init();
      f_get_high_i1.Clear();
      f_get_high_i2.Clear();
      f_get_low_i3.Clear();
      f_get_low_i4.Clear();
      change2Source.Init();
      ArrayInitialize(market, 1);
      change3Source.Init();
      change4Source.Init();
      ArrayInitialize(bu_ob_index, EMPTY_VALUE);
      ArrayInitialize(l0i, EMPTY_VALUE);
      ArrayInitialize(be_ob_index, EMPTY_VALUE);
      ArrayInitialize(h0i, EMPTY_VALUE);
      ArrayInitialize(be_bb_index, EMPTY_VALUE);
      ArrayInitialize(bu_bb_index, EMPTY_VALUE);
      change5Source.Init();
      change6Source.Init();

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

      if (!highest1.GetValue(pos, highest1Value)) { highest1Value = EMPTY_VALUE; }
      to_up[pos] = SafeGE(high[pos], highest1Value);
      double lowest1Value;
      if (!lowest1.GetValue(pos, lowest1Value)) { lowest1Value = EMPTY_VALUE; }
      to_down[pos] = SafeLE(low[pos], lowest1Value);
      if (pos + 1 > (rates_total - 1)) { continue; }
      trend[pos] = Nz(trend[pos + 1], 1);
      trend[pos] = ((trend[pos] == 1) && to_down[pos] ? (-1) : ((trend[pos] == (-1)) && to_up[pos] ? 1 : trend[pos]));
      if (pos + 1 > (rates_total - 1)) { continue; }
      barssince1Condition.SetValue(pos, to_up[pos + 1]);
      int barssince1Value;
      if (!barssince1.GetValue(pos, barssince1Value)) { barssince1Value = EMPTY_VALUE; }
      last_trend_up_since = barssince1Value;
      double lowest2Value;
      if (!lowest2.GetValue(pos, lowest2Value)) { lowest2Value = EMPTY_VALUE; }
      double low_val = lowest2Value;
      barssince2Condition.SetValue(pos, (low_val == low[pos]));
      int barssince2Value;
      if (!barssince2.GetValue(pos, barssince2Value)) { barssince2Value = EMPTY_VALUE; }
      int low_index = SafeMinus(((rates_total - 1) - pos), barssince2Value);
      if (pos + 1 > (rates_total - 1)) { continue; }
      barssince3Condition.SetValue(pos, to_down[pos + 1]);
      int barssince3Value;
      if (!barssince3.GetValue(pos, barssince3Value)) { barssince3Value = EMPTY_VALUE; }
      last_trend_down_since = barssince3Value;
      double highest2Value;
      if (!highest2.GetValue(pos, highest2Value)) { highest2Value = EMPTY_VALUE; }
      double high_val = highest2Value;
      barssince4Condition.SetValue(pos, (high_val == high[pos]));
      int barssince4Value;
      if (!barssince4.GetValue(pos, barssince4Value)) { barssince4Value = EMPTY_VALUE; }
      int high_index = SafeMinus(((rates_total - 1) - pos), barssince4Value);
      change1Source.SetValue(pos, trend[pos]);
      double change1Value;

      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }

      if ((change1Value != 0))
      {
         if ((trend[pos] == 1))
         {
            Array::Push(low_points_arr, low_val);
            Array::Push(low_index_arr, low_index);  
         }
         if ((trend[pos] == (-1)))
         {
            Array::Push(high_points_arr, high_val);
            Array::Push(high_index_arr, high_index);
         }
         
      }
      double f_get_high_i1Value1;
      int f_get_high_i1Value2;
      if (!f_get_high_i1.GetValue(pos, f_get_high_i1Value1, f_get_high_i1Value2)) { f_get_high_i1Value1 = EMPTY_VALUE; f_get_high_i1Value2 = EMPTY_VALUE; }
      double h0 = f_get_high_i1Value1;
      h0i[pos] = f_get_high_i1Value2;
      double f_get_high_i2Value1;
      int f_get_high_i2Value2;
      if (!f_get_high_i2.GetValue(pos, f_get_high_i2Value1, f_get_high_i2Value2)) { f_get_high_i2Value1 = EMPTY_VALUE; f_get_high_i2Value2 = EMPTY_VALUE; }
      double h1 = f_get_high_i2Value1;
      int h1i = f_get_high_i2Value2;
      double f_get_low_i3Value1;
      int f_get_low_i3Value2;
      if (!f_get_low_i3.GetValue(pos, f_get_low_i3Value1, f_get_low_i3Value2)) { f_get_low_i3Value1 = EMPTY_VALUE; f_get_low_i3Value2 = EMPTY_VALUE; }
      double l0 = f_get_low_i3Value1;
      l0i[pos] = f_get_low_i3Value2;
      double f_get_low_i4Value1;
      int f_get_low_i4Value2;
      if (!f_get_low_i4.GetValue(pos, f_get_low_i4Value1, f_get_low_i4Value2)) { f_get_low_i4Value1 = EMPTY_VALUE; f_get_low_i4Value2 = EMPTY_VALUE; }
      double l1 = f_get_low_i4Value1;
      int l1i = f_get_low_i4Value2;
      change2Source.SetValue(pos, trend[pos]);
      double change2Value;
      if (!change2.GetValue(pos, change2Value)) { change2Value = EMPTY_VALUE; }
      if ((change2Value != 0) && show_zigzag)
      {
         if ((trend[pos] == 1))
         {
            LinesCollection::Create(IndicatorObjPrefix + "line_1_id", h0i[pos], h0, l0i[pos], l0, time[pos]).SetWidth(1).SetStyle("solid");
         }
         if ((trend[pos] == (-1)))
         {
            LinesCollection::Create(IndicatorObjPrefix + "line_2_id", l0i[pos], l0, h0i[pos], h0, time[pos]).SetWidth(1).SetStyle("solid");
         }
      }
      
      
      if (pos + 1 > (rates_total - 1)) { continue; }
      
      
      market[pos] = Nz(market[pos + 1], 1);
      change3Source.SetValue(pos, market[pos]);
      double change3Value;
      if (!change3.GetValue(pos, change3Value)) { change3Value = EMPTY_VALUE; }
      double last_l0 = valuewhen1.Update(pos, time[pos], (change3Value != 0), l0);
      change4Source.SetValue(pos, market[pos]);
      double change4Value;
      if (!change4.GetValue(pos, change4Value)) { change4Value = EMPTY_VALUE; }
      double last_h0 = valuewhen2.Update(pos, time[pos], (change4Value != 0), h0);
      market[pos] = (((last_l0 == l0) || (last_h0 == h0)) ? market[pos] : ((market[pos] == 1) && SafeLess(l0, l1) && SafeLess(l0, SafeMinus(l1, SafeMultiply(SafeMathAbs(SafeMinus(h0, l1)), fib_factor))) ? (-1) : ((market[pos] == (-1)) && SafeGreater(h0, h1) && SafeGreater(h0, SafePlus(h1, SafeMultiply(SafeMathAbs(SafeMinus(h1, l0)), fib_factor))) ? 1 : market[pos])));
      bu_ob_index[pos] = ((rates_total - 1) - pos);
      if (pos + 1 > (rates_total - 1)) { continue; }
      bu_ob_index[pos] = Nz(bu_ob_index[pos + 1], ((rates_total - 1) - pos));
      if (pos + zigzag_len > (rates_total - 1)) { continue; }
      int for1_from = h1i;
      int for1_to = l0i[pos + zigzag_len];
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { continue; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         int index = ((rates_total - 1) - pos) - i;
         if (pos + index > (rates_total - 1)) { continue; }
         if (pos + index > (rates_total - 1)) { continue; }
         if ((open[pos + index] > close[pos + index]))
         {
            bu_ob_index[pos] = ((rates_total - 1) - pos);         
         }
      }
      int bu_ob_since = ((rates_total - 1) - pos) - bu_ob_index[pos];
      be_ob_index[pos] = ((rates_total - 1) - pos);
      if (pos + 1 > (rates_total - 1)) { continue; }
      be_ob_index[pos] = Nz(be_ob_index[pos + 1], ((rates_total - 1) - pos));
      if (pos + zigzag_len > (rates_total - 1)) { continue; }
      int for2_from = l1i;
      int for2_to = h0i[pos + zigzag_len];
      bool for2_forward = for2_from <= for2_to;
      int for2_step = 1 * (for2_forward ? 1 : -1);
      if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { continue; }
      for (int i = for2_from; (for2_forward ? i <= for2_to : i >= for2_to); i += for2_step)
      {
         int index = ((rates_total - 1) - pos) - i;
         if (pos + index > (rates_total - 1)) { continue; }
         if (pos + index > (rates_total - 1)) { continue; }
         if ((open[pos + index] < close[pos + index]))
         {
            be_ob_index[pos] = ((rates_total - 1) - pos);
         }
      }
      int be_ob_since = ((rates_total - 1) - pos) - be_ob_index[pos];
      be_bb_index[pos] = ((rates_total - 1) - pos);
      if (pos + 1 > (rates_total - 1)) { continue; }
      be_bb_index[pos] = Nz(be_bb_index[pos + 1], ((rates_total - 1) - pos));
      int for3_from = SafeMinus(h1i, zigzag_len);
      int for3_to = l1i;
      bool for3_forward = for3_from <= for3_to;
      int for3_step = 1 * (for3_forward ? 1 : -1);
      if (for3_from == EMPTY_VALUE || for3_to == EMPTY_VALUE) { continue; }
      for (int i = for3_from; (for3_forward ? i <= for3_to : i >= for3_to); i += for3_step)
      {
         int index = ((rates_total - 1) - pos) - i;
         if (pos + index > (rates_total - 1)) { continue; }
         if (pos + index > (rates_total - 1)) { continue; }
         if ((open[pos + index] > close[pos + index]))
         {
            be_bb_index[pos] = ((rates_total - 1) - pos);
         }
      }
      int be_bb_since = ((rates_total - 1) - pos) - be_bb_index[pos];
      bu_bb_index[pos] = ((rates_total - 1) - pos);
      if (pos + 1 > (rates_total - 1)) { continue; }
      bu_bb_index[pos] = Nz(bu_bb_index[pos + 1], ((rates_total - 1) - pos));
      int for4_from = SafeMinus(l1i, zigzag_len);
      int for4_to = h1i;
      bool for4_forward = for4_from <= for4_to;
      int for4_step = 1 * (for4_forward ? 1 : -1);
      if (for4_from == EMPTY_VALUE || for4_to == EMPTY_VALUE) { continue; }
      for (int i = for4_from; (for4_forward ? i <= for4_to : i >= for4_to); i += for4_step)
      {
         int index = ((rates_total - 1) - pos) - i;
         if (pos + index > (rates_total - 1)) { continue; }
         if (pos + index > (rates_total - 1)) { continue; }
         if ((open[pos + index] < close[pos + index]))
         {
            bu_bb_index[pos] = ((rates_total - 1) - pos);
         }
      }
      int bu_bb_since = ((rates_total - 1) - pos) - bu_bb_index[pos];
      change5Source.SetValue(pos, market[pos]);
      double change5Value;
      if (!change5.GetValue(pos, change5Value)) { change5Value = EMPTY_VALUE; }
      


      if ((change5Value != 0))
      {
         if ((market[pos] == 1))
         {
            LinesCollection::Create(IndicatorObjPrefix + "line_3_id", h1i, h1, h0i[pos], h1, time[pos]).SetColor(Green).SetWidth(2).SetStyle("solid");
            LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", (int)(SafeDivide((SafePlus(h1i, l0i[pos])), 2)), h1, time[pos]).SetColor(Black).SetText("MSB").SetTextColor(Green).SetStyle("down").SetSize("small").SetYLoc("price");
            if (pos + bu_ob_since > (rates_total - 1)) { continue; }
            if (pos + bu_ob_since > (rates_total - 1)) { continue; }
            Box* bu_ob = BoxesCollection::Create(IndicatorObjPrefix + "box_1_id", bu_ob_index[pos], high[pos + bu_ob_since], ((rates_total - 1) - pos) + 10, low[pos + bu_ob_since], time[pos]).SetBgColor(bu_ob_color).SetBorderColor(bu_ob_border_color).SetExtend("none");
            if (pos + bu_bb_since > (rates_total - 1)) { continue; }
            if (pos + bu_bb_since > (rates_total - 1)) { continue; }
            Box* bu_bb = BoxesCollection::Create(IndicatorObjPrefix + "box_2_id", bu_bb_index[pos], high[pos + bu_bb_since], ((rates_total - 1) - pos) + 10, low[pos + bu_bb_since], time[pos]).SetBgColor(bu_bb_color).SetBorderColor(bu_bb_border_color).SetExtend("none");
            Array::Push(bu_ob_boxes, bu_ob);
            Array::Push(bu_bb_boxes, bu_bb);           

         }
         if ((market[pos] == (-1)))
         {
            LinesCollection::Create(IndicatorObjPrefix + "line_4_id", l1i, l1, l0i[pos], l1, time[pos]).SetColor(Red).SetWidth(2).SetStyle("solid");
            LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", (int)(SafeDivide((SafePlus(l1i, h0i[pos])), 2)), l1, time[pos]).SetColor(Black).SetText("MSB").SetTextColor(Red).SetStyle("up").SetSize("small").SetYLoc("price");
            if (pos + be_ob_since > (rates_total - 1)) { continue; }
            if (pos + be_ob_since > (rates_total - 1)) { continue; }
            Box* be_ob = BoxesCollection::Create(IndicatorObjPrefix + "box_3_id", be_ob_index[pos], high[pos + be_ob_since], ((rates_total - 1) - pos) + 10, low[pos + be_ob_since], time[pos]).SetBgColor(be_ob_color).SetBorderColor(be_ob_border_color).SetExtend("none");
            if (pos + be_bb_since > (rates_total - 1)) { continue; }
            if (pos + be_bb_since > (rates_total - 1)) { continue; }
            Box* be_bb = BoxesCollection::Create(IndicatorObjPrefix + "box_4_id", be_bb_index[pos], high[pos + be_bb_since], ((rates_total - 1) - pos) + 10, low[pos + be_bb_since], time[pos]).SetBgColor(be_bb_color).SetBorderColor(be_bb_border_color).SetExtend("none");
            Array::Push(be_ob_boxes, be_ob);
            Array::Push(be_bb_boxes, be_bb);
            
         }
      }
      IBoxArray* foreach1_items = bu_ob_boxes;
      for (int foreach1_index = 0; foreach1_index < Array::Size(foreach1_items); ++foreach1_index)
      {
         Box* bull_ob = Array::Get(foreach1_items, foreach1_index);
         double bottom = Box::GetBottom(bull_ob);
         if (SafeLess(close[pos], bottom))
         {
            BoxesCollection::Delete(bull_ob);
         }
         else if ((Array::Size(bu_ob_boxes) == 5))
         {
            BoxesCollection::Delete(Array::Shift(bu_ob_boxes));
         }
         else
         {
            Box::SetRight(bull_ob, ((rates_total - 1) - pos) + 10);
         }
      }
      IBoxArray* foreach2_items = be_ob_boxes;
      for (int foreach2_index = 0; foreach2_index < Array::Size(foreach2_items); ++foreach2_index)
      {
         Box* bear_ob = Array::Get(foreach2_items, foreach2_index);
         double top = Box::GetTop(bear_ob);
         if (SafeGreater(close[pos], top))
         {
            BoxesCollection::Delete(bear_ob);
         }
         else if ((Array::Size(be_ob_boxes) == 5))
         {
            BoxesCollection::Delete(Array::Shift(be_ob_boxes));
         }
         else
         {
            Box::SetRight(bear_ob, ((rates_total - 1) - pos) + 10);
         }
      }
      IBoxArray* foreach3_items = be_bb_boxes;
      for (int foreach3_index = 0; foreach3_index < Array::Size(foreach3_items); ++foreach3_index)
      {
         Box* bear_bb = Array::Get(foreach3_items, foreach3_index);
         double top = Box::GetTop(bear_bb);
         if (SafeGreater(close[pos], top))
         {
            BoxesCollection::Delete(bear_bb);
         }
         else if ((Array::Size(be_bb_boxes) == 5))
         {
            BoxesCollection::Delete(Array::Shift(be_bb_boxes));
         }
         else
         {
            Box::SetRight(bear_bb, ((rates_total - 1) - pos) + 10);
         }
      }
      IBoxArray* foreach4_items = bu_bb_boxes;
      for (int foreach4_index = 0; foreach4_index < Array::Size(foreach4_items); ++foreach4_index)
      {
         Box* bull_bb = Array::Get(foreach4_items, foreach4_index);
         double bottom = Box::GetBottom(bull_bb);
         if (SafeLess(close[pos], bottom))
         {
            BoxesCollection::Delete(bull_bb);
         }
         else if ((Array::Size(bu_bb_boxes) == 5))
         {
            BoxesCollection::Delete(Array::Shift(bu_bb_boxes));
         }
         else
         {
            Box::SetRight(bull_bb, ((rates_total - 1) - pos) + 10);
         }
      }
      change6Source.SetValue(pos, market[pos]);
      double change6Value;
      if (!change6.GetValue(pos, change6Value)) { change6Value = EMPTY_VALUE; }
      if ((change6Value != 0)) { _signaler.SendNotifications("MSB", "MSB"); }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LinesCollection::Redraw();
   LabelsCollection::Redraw();
   BoxesCollection::Redraw();

   MarkTrendChanges();

   return rates_total;
}

void MarkTrendChanges()
{
    for(int i = 100; i >= 1; i--)
    {
        if(trend[i] == 1 && trend[i+1] == -1)
            ArrowUp[i] =  iLow(NULL, 0, i);

            if(trend[i] == -1 && trend[i+1] == 1)
            ArrowDn[i] = iHigh(NULL, 0, i);
    }
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160833#p160833
License:     GNU
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