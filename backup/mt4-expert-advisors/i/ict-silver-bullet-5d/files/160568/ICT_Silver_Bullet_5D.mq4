// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76310&p=160568#p160568
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
#property strict
#property indicator_chart_window
#property indicator_buffers 0

// syminfo.* functions from Pine Script
// v1.2

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
   
   static string Type(string symbol)
   {
      return "forex";
   }
   
   static string Ticker()
   {
      return _Symbol;
   }
   
   static string TickerId()
   {
      return _Symbol;
   }
   
   static string Currency()
   {
      return SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE);
   }
};
// Array v1.6
// Array interface v1.0

// Line array interface v1.2
// Line object v1.6

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
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

   void Redraw()
   {
      if (_y1 == EMPTY_VALUE || _y2 == EMPTY_VALUE)
      {
         return;
      }
      int pos1 = iBars(_Symbol, _timeframe) - _x1 - 1;
      datetime x1 = iTime(_Symbol, _timeframe, pos1);
      int pos2 = iBars(_Symbol, _timeframe) - _x2 - 1;
      datetime x2 = iTime(_Symbol, _timeframe, pos2);
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
// Box array interface v1.1
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


class IBoxArray : public ITArray<Box*>
{
public:
   virtual IBoxArray* Slice(int from, int to) = 0;
   virtual IBoxArray* Clear() = 0;
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
      if (value.Release() == 0)
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

// Collection of boxes v1.3

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

   IBoxArray* Push(Box* value)
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
   static int Includes(IBoxArray* array, Box* value) { if (array == NULL) { return -1; } return array.Includes(value); }
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

// Pivot high stream v2.0

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
   PivotHighStream(TIStream<double> *source, int leftBars, int rightBars)
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

   static bool GetValue(const int period, double &val, TIStream<double>* source, int leftBars, int rightBars)
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
// Pivot low stream v2.0




class PivotLowStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotLowStream(TIStream<double> *source, int leftBars, int rightBars)
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

   static bool GetValue(const int period, double &val, TIStream<double>* source, int leftBars, int rightBars)
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
// Abstract integer stream v1.0

#ifndef TAStream_IMPL
#define TAStream_IMPL


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

// Date/time stream v1.1

#ifndef DateTimeStream_IMP
#define DateTimeStream_IMP

class DateTimeStream : public TAStream<datetime>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   ENUM_TIMEFRAMES _targetTimeframe;
public:
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _targetTimeframe = timeframe;
   }
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe, string targetTimeframe, string session, string timezone)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _targetTimeframe = Timeframe::GetTimeframe(targetTimeframe);
   }
   ~DateTimeStream()
   {
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
      return true;
   }
   
   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
#endif

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


// Implementation of PineScript's plotchar
// v1.2

class PlotChar
{
   string _char;
   string _id;
   string _location;
public:
   PlotChar(string ch, string id, string location)
   {
      _char = ch;
      _id = id;
      _location = location;
   }
   void Set(int pos, bool toTrue, color clr = Blue)
   {
      datetime time = iTime(_Symbol, _Period, pos);
      string id = _id + TimeToString(time);
      if (!toTrue)
      {
         ObjectDelete(id);
         return;
      }
      ResetLastError();
      double price = GetPrice(pos);
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_TEXT, 0, time, price))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, time);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, _char);
   }
private:
   int GetAnchor()
   {
      if (_location == "abovebar")
      {
         return ANCHOR_LOWER;
      }
      if (_location == "belowbar")
      {
         return ANCHOR_UPPER;
      }
      return ANCHOR_CENTER;
   }
   double GetPrice(int pos)
   {
      if (_location == "abovebar")
      {
         return iHigh(_Symbol, _Period, pos);
      }
      if (_location == "belowbar")
      {
         return iLow(_Symbol, _Period, pos);
      }
      return iClose(_Symbol, _Period, pos);
   }
};
input int param1 = 5; // 
input bool param2 = true; // Show SB session
input color param3 = 0xbeb5b2; // �����
enum param4_enum
{
   param4_value_1, // All FVG
   param4_value_2, // Only FVG in the same direction of trend
   param4_value_3, // Strict
   param4_value_4 // Super-Strict
};
input param4_enum param4_e = param4_value_4; // 
string Get_param4()
{
   switch (param4_e)
   {
      case param4_value_1: return "All FVG";
      case param4_value_2: return "Only FVG in the same direction of trend";
      case param4_value_3: return "Strict";
      case param4_value_4: return "Super-Strict";
   }
   return NULL;
}
input color param5 = 0xe1d04d; // 
input color param6 = 0xb1c1ff; // 
input bool param7 = true; // extend
enum param8_enum
{
   param8_value_1, // previous session (any)
   param8_value_2 // previous session (similar)
};
input param8_enum param8_e = param8_value_2; // 
string Get_param8()
{
   switch (param8_e)
   {
      case param8_value_1: return "previous session (any)";
      case param8_value_2: return "previous session (similar)";
   }
   return NULL;
}
input color param9 = 0x3328b2; // 
input color param10 = 0xfa893e; // 
input bool param11 = true; // Keep lines (only in [super-]strict mode)
input bool param12 = false; // MSS ~ session
input bool param13 = false; // Trend
input int bars_limit = 100000; // Bars limit
int left;
int showSB;
uint col_SB;
string choice;
int stricty;
uint cBullFVG;
uint cBearFVG;
int extend;
string opt;
uint cSupLine;
uint cResLine;
int keep;
int showT;
int showZZ;
int n;
int maxSize;
class piv
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   piv(piv* src)
   {
      _refs = 1;
      this.b = src.b;
      this.p = src.p;
      this.br = src.br;
   }
   piv(int b = INT_MIN, double p = EMPTY_VALUE, int br = (-1))
   {
      _refs = 1;
      this.b = b;
      this.p = p;
      this.br = br;
   }
   ~piv()
   {
   }
   int b;
   static int Getb(piv* self) { return self == NULL ? INT_MIN : self.b; }
   static void Setb(piv* self, int val) { if (self == NULL) return; self.Setb(val); } 
   piv* Setb(int val) { this.b = val; return &this; }
   double p;
   static double Getp(piv* self) { return self == NULL ? EMPTY_VALUE : self.p; }
   static void Setp(piv* self, double val) { if (self == NULL) return; self.Setp(val); } 
   piv* Setp(double val) { this.p = val; return &this; }
   int br;
   static int Getbr(piv* self) { return self == NULL ? (-1) : self.br; }
   static void Setbr(piv* self, int val) { if (self == NULL) return; self.Setbr(val); } 
   piv* Setbr(int val) { this.br = val; return &this; }
};
class ZZ
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   ZZ(ZZ* src)
   {
      _refs = 1;
      if (this.d != NULL) this.d.Release();
      this.d = src.d;
      if (this.d != NULL) this.d.AddRef();
      if (this.x != NULL) this.x.Release();
      this.x = src.x;
      if (this.x != NULL) this.x.AddRef();
      if (this.y != NULL) this.y.Release();
      this.y = src.y;
      if (this.y != NULL) this.y.AddRef();
      if (this.l != NULL) this.l.Release();
      this.l = src.l;
      if (this.l != NULL) this.l.AddRef();
   }
   ZZ(ITArray<int>* d = NULL, ITArray<int>* x = NULL, ISimpleTypeArray<double>* y = NULL, ICustomTypeArray<Line*>* l = NULL)
   {
      _refs = 1;
      if (this.d != NULL) this.d.Release();
      this.d = d;
      if (this.d != NULL) this.d.AddRef();
      if (this.x != NULL) this.x.Release();
      this.x = x;
      if (this.x != NULL) this.x.AddRef();
      if (this.y != NULL) this.y.Release();
      this.y = y;
      if (this.y != NULL) this.y.AddRef();
      if (this.l != NULL) this.l.Release();
      this.l = l;
      if (this.l != NULL) this.l.AddRef();
   }
   ~ZZ()
   {
      if (this.d != NULL) this.d.Release();
      if (this.x != NULL) this.x.Release();
      if (this.y != NULL) this.y.Release();
      if (this.l != NULL) this.l.Release();
   }
   ITArray<int>* d;
   static ITArray<int>* Getd(ZZ* self) { return self == NULL ? NULL : self.d; }
   static void Setd(ZZ* self, ITArray<int>* val) { if (self == NULL) return; self.Setd(val); } 
   ZZ* Setd(ITArray<int>* val) { if (this.d != NULL) this.d.Release(); this.d = val; if (this.d != NULL) this.d.AddRef(); return &this; }
   ITArray<int>* x;
   static ITArray<int>* Getx(ZZ* self) { return self == NULL ? NULL : self.x; }
   static void Setx(ZZ* self, ITArray<int>* val) { if (self == NULL) return; self.Setx(val); } 
   ZZ* Setx(ITArray<int>* val) { if (this.x != NULL) this.x.Release(); this.x = val; if (this.x != NULL) this.x.AddRef(); return &this; }
   ISimpleTypeArray<double>* y;
   static ISimpleTypeArray<double>* Gety(ZZ* self) { return self == NULL ? NULL : self.y; }
   static void Sety(ZZ* self, ISimpleTypeArray<double>* val) { if (self == NULL) return; self.Sety(val); } 
   ZZ* Sety(ISimpleTypeArray<double>* val) { if (this.y != NULL) this.y.Release(); this.y = val; if (this.y != NULL) this.y.AddRef(); return &this; }
   ICustomTypeArray<Line*>* l;
   static ICustomTypeArray<Line*>* Getl(ZZ* self) { return self == NULL ? NULL : self.l; }
   static void Setl(ZZ* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.Setl(val); } 
   ZZ* Setl(ICustomTypeArray<Line*>* val) { if (this.l != NULL) this.l.Release(); this.l = val; if (this.l != NULL) this.l.AddRef(); return &this; }
};
class FVG
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   FVG(FVG* src)
   {
      _refs = 1;
      if (this.box != NULL) this.box.Release();
      this.box = src.box;
      if (this.box != NULL) this.box.AddRef();
      this.active = src.active;
      this.current = src.current;
   }
   FVG(Box* box = NULL, int active = (-1), int current = (-1))
   {
      _refs = 1;
      if (this.box != NULL) this.box.Release();
      this.box = box;
      if (this.box != NULL) this.box.AddRef();
      this.active = active;
      this.current = current;
   }
   ~FVG()
   {
      if (this.box != NULL) this.box.Release();
   }
   Box* box;
   static Box* Getbox(FVG* self) { return self == NULL ? NULL : self.box; }
   static void Setbox(FVG* self, Box* val) { if (self == NULL) return; self.Setbox(val); } 
   FVG* Setbox(Box* val) { if (this.box != NULL) this.box.Release(); this.box = val; if (this.box != NULL) this.box.AddRef(); return &this; }
   int active;
   static int Getactive(FVG* self) { return self == NULL ? (-1) : self.active; }
   static void Setactive(FVG* self, int val) { if (self == NULL) return; self.Setactive(val); } 
   FVG* Setactive(int val) { this.active = val; return &this; }
   int current;
   static int Getcurrent(FVG* self) { return self == NULL ? (-1) : self.current; }
   static void Setcurrent(FVG* self, int val) { if (self == NULL) return; self.Setcurrent(val); } 
   FVG* Setcurrent(int val) { this.current = val; return &this; }
};
class actLine
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   actLine(actLine* src)
   {
      _refs = 1;
      if (this.ln != NULL) this.ln.Release();
      this.ln = src.ln;
      if (this.ln != NULL) this.ln.AddRef();
      this.active = src.active;
   }
   actLine(Line* ln = NULL, int active = (-1))
   {
      _refs = 1;
      if (this.ln != NULL) this.ln.Release();
      this.ln = ln;
      if (this.ln != NULL) this.ln.AddRef();
      this.active = active;
   }
   ~actLine()
   {
      if (this.ln != NULL) this.ln.Release();
   }
   Line* ln;
   static Line* Getln(actLine* self) { return self == NULL ? NULL : self.ln; }
   static void Setln(actLine* self, Line* val) { if (self == NULL) return; self.Setln(val); } 
   actLine* Setln(Line* val) { if (this.ln != NULL) this.ln.Release(); this.ln = val; if (this.ln != NULL) this.ln.AddRef(); return &this; }
   int active;
   static int Getactive(actLine* self) { return self == NULL ? (-1) : self.active; }
   static void Setactive(actLine* self, int val) { if (self == NULL) return; self.Setactive(val); } 
   actLine* Setactive(int val) { this.active = val; return &this; }
};
class aPiv
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   aPiv(aPiv* src)
   {
      _refs = 1;
      if (this.GN_swingH != NULL) this.GN_swingH.Release();
      this.GN_swingH = src.GN_swingH;
      if (this.GN_swingH != NULL) this.GN_swingH.AddRef();
      if (this.GN_swingL != NULL) this.GN_swingL.Release();
      this.GN_swingL = src.GN_swingL;
      if (this.GN_swingL != NULL) this.GN_swingL.AddRef();
      this.GN_mnPiv = src.GN_mnPiv;
      this.GN_mxPiv = src.GN_mxPiv;
      if (this.GN_targHi != NULL) this.GN_targHi.Release();
      this.GN_targHi = src.GN_targHi;
      if (this.GN_targHi != NULL) this.GN_targHi.AddRef();
      if (this.GN_targLo != NULL) this.GN_targLo.Release();
      this.GN_targLo = src.GN_targLo;
      if (this.GN_targLo != NULL) this.GN_targLo.AddRef();
      if (this.LN_swingH != NULL) this.LN_swingH.Release();
      this.LN_swingH = src.LN_swingH;
      if (this.LN_swingH != NULL) this.LN_swingH.AddRef();
      if (this.LN_swingL != NULL) this.LN_swingL.Release();
      this.LN_swingL = src.LN_swingL;
      if (this.LN_swingL != NULL) this.LN_swingL.AddRef();
      this.LN_mnPiv = src.LN_mnPiv;
      this.LN_mxPiv = src.LN_mxPiv;
      if (this.LN_targHi != NULL) this.LN_targHi.Release();
      this.LN_targHi = src.LN_targHi;
      if (this.LN_targHi != NULL) this.LN_targHi.AddRef();
      if (this.LN_targLo != NULL) this.LN_targLo.Release();
      this.LN_targLo = src.LN_targLo;
      if (this.LN_targLo != NULL) this.LN_targLo.AddRef();
      if (this.AM_swingH != NULL) this.AM_swingH.Release();
      this.AM_swingH = src.AM_swingH;
      if (this.AM_swingH != NULL) this.AM_swingH.AddRef();
      if (this.AM_swingL != NULL) this.AM_swingL.Release();
      this.AM_swingL = src.AM_swingL;
      if (this.AM_swingL != NULL) this.AM_swingL.AddRef();
      this.AM_mnPiv = src.AM_mnPiv;
      this.AM_mxPiv = src.AM_mxPiv;
      if (this.AM_targHi != NULL) this.AM_targHi.Release();
      this.AM_targHi = src.AM_targHi;
      if (this.AM_targHi != NULL) this.AM_targHi.AddRef();
      if (this.AM_targLo != NULL) this.AM_targLo.Release();
      this.AM_targLo = src.AM_targLo;
      if (this.AM_targLo != NULL) this.AM_targLo.AddRef();
      if (this.PM_swingH != NULL) this.PM_swingH.Release();
      this.PM_swingH = src.PM_swingH;
      if (this.PM_swingH != NULL) this.PM_swingH.AddRef();
      if (this.PM_swingL != NULL) this.PM_swingL.Release();
      this.PM_swingL = src.PM_swingL;
      if (this.PM_swingL != NULL) this.PM_swingL.AddRef();
      this.PM_mnPiv = src.PM_mnPiv;
      this.PM_mxPiv = src.PM_mxPiv;
      if (this.PM_targHi != NULL) this.PM_targHi.Release();
      this.PM_targHi = src.PM_targHi;
      if (this.PM_targHi != NULL) this.PM_targHi.AddRef();
      if (this.PM_targLo != NULL) this.PM_targLo.Release();
      this.PM_targLo = src.PM_targLo;
      if (this.PM_targLo != NULL) this.PM_targLo.AddRef();
   }
   aPiv(ICustomTypeArray<piv*>* GN_swingH = NULL, ICustomTypeArray<piv*>* GN_swingL = NULL, double GN_mnPiv = EMPTY_VALUE, double GN_mxPiv = EMPTY_VALUE, ICustomTypeArray<Line*>* GN_targHi = NULL, ICustomTypeArray<Line*>* GN_targLo = NULL, ICustomTypeArray<piv*>* LN_swingH = NULL, ICustomTypeArray<piv*>* LN_swingL = NULL, double LN_mnPiv = EMPTY_VALUE, double LN_mxPiv = EMPTY_VALUE, ICustomTypeArray<Line*>* LN_targHi = NULL, ICustomTypeArray<Line*>* LN_targLo = NULL, ICustomTypeArray<piv*>* AM_swingH = NULL, ICustomTypeArray<piv*>* AM_swingL = NULL, double AM_mnPiv = EMPTY_VALUE, double AM_mxPiv = EMPTY_VALUE, ICustomTypeArray<Line*>* AM_targHi = NULL, ICustomTypeArray<Line*>* AM_targLo = NULL, ICustomTypeArray<piv*>* PM_swingH = NULL, ICustomTypeArray<piv*>* PM_swingL = NULL, double PM_mnPiv = EMPTY_VALUE, double PM_mxPiv = EMPTY_VALUE, ICustomTypeArray<Line*>* PM_targHi = NULL, ICustomTypeArray<Line*>* PM_targLo = NULL)
   {
      _refs = 1;
      if (this.GN_swingH != NULL) this.GN_swingH.Release();
      this.GN_swingH = GN_swingH;
      if (this.GN_swingH != NULL) this.GN_swingH.AddRef();
      if (this.GN_swingL != NULL) this.GN_swingL.Release();
      this.GN_swingL = GN_swingL;
      if (this.GN_swingL != NULL) this.GN_swingL.AddRef();
      this.GN_mnPiv = GN_mnPiv;
      this.GN_mxPiv = GN_mxPiv;
      if (this.GN_targHi != NULL) this.GN_targHi.Release();
      this.GN_targHi = GN_targHi;
      if (this.GN_targHi != NULL) this.GN_targHi.AddRef();
      if (this.GN_targLo != NULL) this.GN_targLo.Release();
      this.GN_targLo = GN_targLo;
      if (this.GN_targLo != NULL) this.GN_targLo.AddRef();
      if (this.LN_swingH != NULL) this.LN_swingH.Release();
      this.LN_swingH = LN_swingH;
      if (this.LN_swingH != NULL) this.LN_swingH.AddRef();
      if (this.LN_swingL != NULL) this.LN_swingL.Release();
      this.LN_swingL = LN_swingL;
      if (this.LN_swingL != NULL) this.LN_swingL.AddRef();
      this.LN_mnPiv = LN_mnPiv;
      this.LN_mxPiv = LN_mxPiv;
      if (this.LN_targHi != NULL) this.LN_targHi.Release();
      this.LN_targHi = LN_targHi;
      if (this.LN_targHi != NULL) this.LN_targHi.AddRef();
      if (this.LN_targLo != NULL) this.LN_targLo.Release();
      this.LN_targLo = LN_targLo;
      if (this.LN_targLo != NULL) this.LN_targLo.AddRef();
      if (this.AM_swingH != NULL) this.AM_swingH.Release();
      this.AM_swingH = AM_swingH;
      if (this.AM_swingH != NULL) this.AM_swingH.AddRef();
      if (this.AM_swingL != NULL) this.AM_swingL.Release();
      this.AM_swingL = AM_swingL;
      if (this.AM_swingL != NULL) this.AM_swingL.AddRef();
      this.AM_mnPiv = AM_mnPiv;
      this.AM_mxPiv = AM_mxPiv;
      if (this.AM_targHi != NULL) this.AM_targHi.Release();
      this.AM_targHi = AM_targHi;
      if (this.AM_targHi != NULL) this.AM_targHi.AddRef();
      if (this.AM_targLo != NULL) this.AM_targLo.Release();
      this.AM_targLo = AM_targLo;
      if (this.AM_targLo != NULL) this.AM_targLo.AddRef();
      if (this.PM_swingH != NULL) this.PM_swingH.Release();
      this.PM_swingH = PM_swingH;
      if (this.PM_swingH != NULL) this.PM_swingH.AddRef();
      if (this.PM_swingL != NULL) this.PM_swingL.Release();
      this.PM_swingL = PM_swingL;
      if (this.PM_swingL != NULL) this.PM_swingL.AddRef();
      this.PM_mnPiv = PM_mnPiv;
      this.PM_mxPiv = PM_mxPiv;
      if (this.PM_targHi != NULL) this.PM_targHi.Release();
      this.PM_targHi = PM_targHi;
      if (this.PM_targHi != NULL) this.PM_targHi.AddRef();
      if (this.PM_targLo != NULL) this.PM_targLo.Release();
      this.PM_targLo = PM_targLo;
      if (this.PM_targLo != NULL) this.PM_targLo.AddRef();
   }
   ~aPiv()
   {
      if (this.GN_swingH != NULL) this.GN_swingH.Release();
      if (this.GN_swingL != NULL) this.GN_swingL.Release();
      if (this.GN_targHi != NULL) this.GN_targHi.Release();
      if (this.GN_targLo != NULL) this.GN_targLo.Release();
      if (this.LN_swingH != NULL) this.LN_swingH.Release();
      if (this.LN_swingL != NULL) this.LN_swingL.Release();
      if (this.LN_targHi != NULL) this.LN_targHi.Release();
      if (this.LN_targLo != NULL) this.LN_targLo.Release();
      if (this.AM_swingH != NULL) this.AM_swingH.Release();
      if (this.AM_swingL != NULL) this.AM_swingL.Release();
      if (this.AM_targHi != NULL) this.AM_targHi.Release();
      if (this.AM_targLo != NULL) this.AM_targLo.Release();
      if (this.PM_swingH != NULL) this.PM_swingH.Release();
      if (this.PM_swingL != NULL) this.PM_swingL.Release();
      if (this.PM_targHi != NULL) this.PM_targHi.Release();
      if (this.PM_targLo != NULL) this.PM_targLo.Release();
   }
   ICustomTypeArray<piv*>* GN_swingH;
   static ICustomTypeArray<piv*>* GetGN_swingH(aPiv* self) { return self == NULL ? NULL : self.GN_swingH; }
   static void SetGN_swingH(aPiv* self, ICustomTypeArray<piv*>* val) { if (self == NULL) return; self.SetGN_swingH(val); } 
   aPiv* SetGN_swingH(ICustomTypeArray<piv*>* val) { if (this.GN_swingH != NULL) this.GN_swingH.Release(); this.GN_swingH = val; if (this.GN_swingH != NULL) this.GN_swingH.AddRef(); return &this; }
   ICustomTypeArray<piv*>* GN_swingL;
   static ICustomTypeArray<piv*>* GetGN_swingL(aPiv* self) { return self == NULL ? NULL : self.GN_swingL; }
   static void SetGN_swingL(aPiv* self, ICustomTypeArray<piv*>* val) { if (self == NULL) return; self.SetGN_swingL(val); } 
   aPiv* SetGN_swingL(ICustomTypeArray<piv*>* val) { if (this.GN_swingL != NULL) this.GN_swingL.Release(); this.GN_swingL = val; if (this.GN_swingL != NULL) this.GN_swingL.AddRef(); return &this; }
   double GN_mnPiv;
   static double GetGN_mnPiv(aPiv* self) { return self == NULL ? EMPTY_VALUE : self.GN_mnPiv; }
   static void SetGN_mnPiv(aPiv* self, double val) { if (self == NULL) return; self.SetGN_mnPiv(val); } 
   aPiv* SetGN_mnPiv(double val) { this.GN_mnPiv = val; return &this; }
   double GN_mxPiv;
   static double GetGN_mxPiv(aPiv* self) { return self == NULL ? EMPTY_VALUE : self.GN_mxPiv; }
   static void SetGN_mxPiv(aPiv* self, double val) { if (self == NULL) return; self.SetGN_mxPiv(val); } 
   aPiv* SetGN_mxPiv(double val) { this.GN_mxPiv = val; return &this; }
   ICustomTypeArray<Line*>* GN_targHi;
   static ICustomTypeArray<Line*>* GetGN_targHi(aPiv* self) { return self == NULL ? NULL : self.GN_targHi; }
   static void SetGN_targHi(aPiv* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.SetGN_targHi(val); } 
   aPiv* SetGN_targHi(ICustomTypeArray<Line*>* val) { if (this.GN_targHi != NULL) this.GN_targHi.Release(); this.GN_targHi = val; if (this.GN_targHi != NULL) this.GN_targHi.AddRef(); return &this; }
   ICustomTypeArray<Line*>* GN_targLo;
   static ICustomTypeArray<Line*>* GetGN_targLo(aPiv* self) { return self == NULL ? NULL : self.GN_targLo; }
   static void SetGN_targLo(aPiv* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.SetGN_targLo(val); } 
   aPiv* SetGN_targLo(ICustomTypeArray<Line*>* val) { if (this.GN_targLo != NULL) this.GN_targLo.Release(); this.GN_targLo = val; if (this.GN_targLo != NULL) this.GN_targLo.AddRef(); return &this; }
   ICustomTypeArray<piv*>* LN_swingH;
   static ICustomTypeArray<piv*>* GetLN_swingH(aPiv* self) { return self == NULL ? NULL : self.LN_swingH; }
   static void SetLN_swingH(aPiv* self, ICustomTypeArray<piv*>* val) { if (self == NULL) return; self.SetLN_swingH(val); } 
   aPiv* SetLN_swingH(ICustomTypeArray<piv*>* val) { if (this.LN_swingH != NULL) this.LN_swingH.Release(); this.LN_swingH = val; if (this.LN_swingH != NULL) this.LN_swingH.AddRef(); return &this; }
   ICustomTypeArray<piv*>* LN_swingL;
   static ICustomTypeArray<piv*>* GetLN_swingL(aPiv* self) { return self == NULL ? NULL : self.LN_swingL; }
   static void SetLN_swingL(aPiv* self, ICustomTypeArray<piv*>* val) { if (self == NULL) return; self.SetLN_swingL(val); } 
   aPiv* SetLN_swingL(ICustomTypeArray<piv*>* val) { if (this.LN_swingL != NULL) this.LN_swingL.Release(); this.LN_swingL = val; if (this.LN_swingL != NULL) this.LN_swingL.AddRef(); return &this; }
   double LN_mnPiv;
   static double GetLN_mnPiv(aPiv* self) { return self == NULL ? EMPTY_VALUE : self.LN_mnPiv; }
   static void SetLN_mnPiv(aPiv* self, double val) { if (self == NULL) return; self.SetLN_mnPiv(val); } 
   aPiv* SetLN_mnPiv(double val) { this.LN_mnPiv = val; return &this; }
   double LN_mxPiv;
   static double GetLN_mxPiv(aPiv* self) { return self == NULL ? EMPTY_VALUE : self.LN_mxPiv; }
   static void SetLN_mxPiv(aPiv* self, double val) { if (self == NULL) return; self.SetLN_mxPiv(val); } 
   aPiv* SetLN_mxPiv(double val) { this.LN_mxPiv = val; return &this; }
   ICustomTypeArray<Line*>* LN_targHi;
   static ICustomTypeArray<Line*>* GetLN_targHi(aPiv* self) { return self == NULL ? NULL : self.LN_targHi; }
   static void SetLN_targHi(aPiv* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.SetLN_targHi(val); } 
   aPiv* SetLN_targHi(ICustomTypeArray<Line*>* val) { if (this.LN_targHi != NULL) this.LN_targHi.Release(); this.LN_targHi = val; if (this.LN_targHi != NULL) this.LN_targHi.AddRef(); return &this; }
   ICustomTypeArray<Line*>* LN_targLo;
   static ICustomTypeArray<Line*>* GetLN_targLo(aPiv* self) { return self == NULL ? NULL : self.LN_targLo; }
   static void SetLN_targLo(aPiv* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.SetLN_targLo(val); } 
   aPiv* SetLN_targLo(ICustomTypeArray<Line*>* val) { if (this.LN_targLo != NULL) this.LN_targLo.Release(); this.LN_targLo = val; if (this.LN_targLo != NULL) this.LN_targLo.AddRef(); return &this; }
   ICustomTypeArray<piv*>* AM_swingH;
   static ICustomTypeArray<piv*>* GetAM_swingH(aPiv* self) { return self == NULL ? NULL : self.AM_swingH; }
   static void SetAM_swingH(aPiv* self, ICustomTypeArray<piv*>* val) { if (self == NULL) return; self.SetAM_swingH(val); } 
   aPiv* SetAM_swingH(ICustomTypeArray<piv*>* val) { if (this.AM_swingH != NULL) this.AM_swingH.Release(); this.AM_swingH = val; if (this.AM_swingH != NULL) this.AM_swingH.AddRef(); return &this; }
   ICustomTypeArray<piv*>* AM_swingL;
   static ICustomTypeArray<piv*>* GetAM_swingL(aPiv* self) { return self == NULL ? NULL : self.AM_swingL; }
   static void SetAM_swingL(aPiv* self, ICustomTypeArray<piv*>* val) { if (self == NULL) return; self.SetAM_swingL(val); } 
   aPiv* SetAM_swingL(ICustomTypeArray<piv*>* val) { if (this.AM_swingL != NULL) this.AM_swingL.Release(); this.AM_swingL = val; if (this.AM_swingL != NULL) this.AM_swingL.AddRef(); return &this; }
   double AM_mnPiv;
   static double GetAM_mnPiv(aPiv* self) { return self == NULL ? EMPTY_VALUE : self.AM_mnPiv; }
   static void SetAM_mnPiv(aPiv* self, double val) { if (self == NULL) return; self.SetAM_mnPiv(val); } 
   aPiv* SetAM_mnPiv(double val) { this.AM_mnPiv = val; return &this; }
   double AM_mxPiv;
   static double GetAM_mxPiv(aPiv* self) { return self == NULL ? EMPTY_VALUE : self.AM_mxPiv; }
   static void SetAM_mxPiv(aPiv* self, double val) { if (self == NULL) return; self.SetAM_mxPiv(val); } 
   aPiv* SetAM_mxPiv(double val) { this.AM_mxPiv = val; return &this; }
   ICustomTypeArray<Line*>* AM_targHi;
   static ICustomTypeArray<Line*>* GetAM_targHi(aPiv* self) { return self == NULL ? NULL : self.AM_targHi; }
   static void SetAM_targHi(aPiv* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.SetAM_targHi(val); } 
   aPiv* SetAM_targHi(ICustomTypeArray<Line*>* val) { if (this.AM_targHi != NULL) this.AM_targHi.Release(); this.AM_targHi = val; if (this.AM_targHi != NULL) this.AM_targHi.AddRef(); return &this; }
   ICustomTypeArray<Line*>* AM_targLo;
   static ICustomTypeArray<Line*>* GetAM_targLo(aPiv* self) { return self == NULL ? NULL : self.AM_targLo; }
   static void SetAM_targLo(aPiv* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.SetAM_targLo(val); } 
   aPiv* SetAM_targLo(ICustomTypeArray<Line*>* val) { if (this.AM_targLo != NULL) this.AM_targLo.Release(); this.AM_targLo = val; if (this.AM_targLo != NULL) this.AM_targLo.AddRef(); return &this; }
   ICustomTypeArray<piv*>* PM_swingH;
   static ICustomTypeArray<piv*>* GetPM_swingH(aPiv* self) { return self == NULL ? NULL : self.PM_swingH; }
   static void SetPM_swingH(aPiv* self, ICustomTypeArray<piv*>* val) { if (self == NULL) return; self.SetPM_swingH(val); } 
   aPiv* SetPM_swingH(ICustomTypeArray<piv*>* val) { if (this.PM_swingH != NULL) this.PM_swingH.Release(); this.PM_swingH = val; if (this.PM_swingH != NULL) this.PM_swingH.AddRef(); return &this; }
   ICustomTypeArray<piv*>* PM_swingL;
   static ICustomTypeArray<piv*>* GetPM_swingL(aPiv* self) { return self == NULL ? NULL : self.PM_swingL; }
   static void SetPM_swingL(aPiv* self, ICustomTypeArray<piv*>* val) { if (self == NULL) return; self.SetPM_swingL(val); } 
   aPiv* SetPM_swingL(ICustomTypeArray<piv*>* val) { if (this.PM_swingL != NULL) this.PM_swingL.Release(); this.PM_swingL = val; if (this.PM_swingL != NULL) this.PM_swingL.AddRef(); return &this; }
   double PM_mnPiv;
   static double GetPM_mnPiv(aPiv* self) { return self == NULL ? EMPTY_VALUE : self.PM_mnPiv; }
   static void SetPM_mnPiv(aPiv* self, double val) { if (self == NULL) return; self.SetPM_mnPiv(val); } 
   aPiv* SetPM_mnPiv(double val) { this.PM_mnPiv = val; return &this; }
   double PM_mxPiv;
   static double GetPM_mxPiv(aPiv* self) { return self == NULL ? EMPTY_VALUE : self.PM_mxPiv; }
   static void SetPM_mxPiv(aPiv* self, double val) { if (self == NULL) return; self.SetPM_mxPiv(val); } 
   aPiv* SetPM_mxPiv(double val) { this.PM_mxPiv = val; return &this; }
   ICustomTypeArray<Line*>* PM_targHi;
   static ICustomTypeArray<Line*>* GetPM_targHi(aPiv* self) { return self == NULL ? NULL : self.PM_targHi; }
   static void SetPM_targHi(aPiv* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.SetPM_targHi(val); } 
   aPiv* SetPM_targHi(ICustomTypeArray<Line*>* val) { if (this.PM_targHi != NULL) this.PM_targHi.Release(); this.PM_targHi = val; if (this.PM_targHi != NULL) this.PM_targHi.AddRef(); return &this; }
   ICustomTypeArray<Line*>* PM_targLo;
   static ICustomTypeArray<Line*>* GetPM_targLo(aPiv* self) { return self == NULL ? NULL : self.PM_targLo; }
   static void SetPM_targLo(aPiv* self, ICustomTypeArray<Line*>* val) { if (self == NULL) return; self.SetPM_targLo(val); } 
   aPiv* SetPM_targLo(ICustomTypeArray<Line*>* val) { if (this.PM_targLo != NULL) this.PM_targLo.Release(); this.PM_targLo = val; if (this.PM_targLo != NULL) this.PM_targLo.AddRef(); return &this; }
};
aPiv* a;
ZZ* aZZ;
ICustomTypeArray<FVG*>* bFVG_bull;
ICustomTypeArray<FVG*>* bFVG_bear;
double min[];
double min_DEFAULT_VALUE;
double max[];
double max_DEFAULT_VALUE;
ISimpleTypeArray<double>* hilo;
ITArray<int>* aTrend;
ICustomTypeArray<Line*>* l_SB;
ICustomTypeArray<actLine*>* highs;
ICustomTypeArray<actLine*>* lows;
Table* tab;
double ph;
double pl;
class timeSess_s_sStream
{
   string timezone;
   string session;
   DateTimeStream* time1;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   timeSess_s_sStream(string timezone, string session, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.timezone = timezone;
      this.session = session;
      time1 = new DateTimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, Timeframe::Period(), session, timezone);
   }
   ~timeSess_s_sStream()
   {
      time1.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, datetime &__out1)
   {
      if (!_initialized)
      {
         _initialized = true;
      }
      datetime time1Value;
      if (!time1.GetValue(pos, time1Value)) { time1Value = NULL; }
      __out1 = time1Value;
      return true;
   }
};
timeSess_s_sStream* timeSess_s_s1;
timeSess_s_sStream* timeSess_s_s2;
timeSess_s_sStream* timeSess_s_s3;
double is_in_SB[];
double is_in_SB_DEFAULT_VALUE;
double SB_LN_per[];
double SB_LN_per_DEFAULT_VALUE;
double SB_AM_per[];
double SB_AM_per_DEFAULT_VALUE;
double SB_PM_per[];
double SB_PM_per_DEFAULT_VALUE;
class type_sStream
{
   string str;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   type_sStream(string str, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.str = str;
   }
   ~type_sStream()
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
   bool GetValue(const int pos, int &__out1)
   {
      __out1 = (((((((SymInfo::Type(_Symbol) == "stock") && (str == "stock")) || ((SymInfo::Type(_Symbol) == "futures") && (str == "futures"))) || ((SymInfo::Type(_Symbol) == "index") && (str == "index"))) || ((SymInfo::Type(_Symbol) == "forex") && (str == "forex"))) || ((SymInfo::Type(_Symbol) == "crypto") && (str == "crypto"))) || ((SymInfo::Type(_Symbol) == "fund") && (str == "fund")));
      return true;
   }
};
type_sStream* type_s4;
type_sStream* type_s5;
type_sStream* type_s6;
class f_setTrendStream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   f_setTrendStream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~f_setTrendStream()
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
   bool GetValue(const int pos)
   {
      int MSS_dir = Array::Get<int, ITArray<int>*, int>(aTrend, 0, INT_MIN);
      int iH = ((Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), 2, INT_MIN) == 1) ? 2 : 1);
      int iL = ((Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), 2, INT_MIN) == (-1)) ? 2 : 1);
      if (SafeGreater(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), iH, EMPTY_VALUE)) && (Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), iH, INT_MIN) == 1) && SafeLess(MSS_dir, 1))
      {
         Array::Set<ITArray<int>*, int, int>(aTrend, 0, 1);
      }
      else if (SafeLess(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), iL, EMPTY_VALUE)) && (Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), iL, INT_MIN) == (-1)) && SafeGreater(MSS_dir, (-1)))
      {
         Array::Set<ITArray<int>*, int, int>(aTrend, 0, (-1));
      }
      return true;
   }
};
f_setTrendStream* f_setTrend7;
double endSB[];
double endSB_DEFAULT_VALUE;
class in_out__ZZ_i_ic_fc_ic_fcStream
{
   ZZ* aZZ;
   int d;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   in_out__ZZ_i_ic_fc_ic_fcStream(ZZ* aZZ, int d, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.aZZ = aZZ;
      this.d = d;
   }
   ~in_out__ZZ_i_ic_fc_ic_fcStream()
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
   bool GetValue(const int pos, int __x1, double __y1, int __x2, double __y2)
   {
      int x1 = __x1;
      double y1 = __y1;
      int x2 = __x2;
      double y2 = __y2;
      Array::Unshift<ITArray<int>*, int>(ZZ::Getd(aZZ), d);
      Array::Unshift<ITArray<int>*, int>(ZZ::Getx(aZZ), x2);
      Array::Unshift<ISimpleTypeArray<double>*, double>(ZZ::Gety(aZZ), y2);
      Array::Pop<int, ITArray<int>*>(ZZ::Getd(aZZ), INT_MIN);
      Array::Pop<int, ITArray<int>*>(ZZ::Getx(aZZ), INT_MIN);
      Array::Pop<double, ISimpleTypeArray<double>*>(ZZ::Gety(aZZ), EMPTY_VALUE);
      if (showZZ)
      {
         Array::Unshift<ICustomTypeArray<Line*>*, Line*>(ZZ::Getl(aZZ), LinesCollection::Create(IndicatorObjPrefix + "line_3_id", x1, y1, x2, y2, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(AddTransparency(Blue, 50)).SetWidth(1).SetStyle("solid").SetExtend("none"));
         LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(ZZ::Getl(aZZ), NULL));
      }
      return true;
   }
};
class in_out__ZZ_ic_ic_fc_ic_fcStream
{
   ZZ* aZZ;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   in_out__ZZ_ic_ic_fc_ic_fcStream(ZZ* aZZ, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.aZZ = aZZ;
   }
   ~in_out__ZZ_ic_ic_fc_ic_fcStream()
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
   bool GetValue(const int pos, int __d, int __x1, double __y1, int __x2, double __y2)
   {
      int d = __d;
      int x1 = __x1;
      double y1 = __y1;
      int x2 = __x2;
      double y2 = __y2;
      Array::Unshift<ITArray<int>*, int>(ZZ::Getd(aZZ), d);
      Array::Unshift<ITArray<int>*, int>(ZZ::Getx(aZZ), x2);
      Array::Unshift<ISimpleTypeArray<double>*, double>(ZZ::Gety(aZZ), y2);
      Array::Pop<int, ITArray<int>*>(ZZ::Getd(aZZ), INT_MIN);
      Array::Pop<int, ITArray<int>*>(ZZ::Getx(aZZ), INT_MIN);
      Array::Pop<double, ISimpleTypeArray<double>*>(ZZ::Gety(aZZ), EMPTY_VALUE);
      if (showZZ)
      {
         Array::Unshift<ICustomTypeArray<Line*>*, Line*>(ZZ::Getl(aZZ), LinesCollection::Create(IndicatorObjPrefix + "line_4_id", x1, y1, x2, y2, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(AddTransparency(Blue, 50)).SetWidth(1).SetStyle("solid").SetExtend("none"));
         LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(ZZ::Getl(aZZ), NULL));
      }
      return true;
   }
};
class f_swings_bc_bc_s_c_fc_fcStream
{
   string str;
   uint col;
   double MSS_dir[];
   double MSS_dir_DEFAULT_VALUE;
   ZZ* aZZ;
   in_out__ZZ_i_ic_fc_ic_fcStream* in_out__ZZ_i_ic_fc_ic_fc8;
   in_out__ZZ_ic_ic_fc_ic_fcStream* in_out__ZZ_ic_ic_fc_ic_fc9;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   f_swings_bc_bc_s_c_fc_fcStream(string str, uint col, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.str = str;
      this.col = col;
   }
   ~f_swings_bc_bc_s_c_fc_fcStream()
   {
      aZZ.Release();
      delete in_out__ZZ_i_ic_fc_ic_fc8;
      delete in_out__ZZ_ic_ic_fc_ic_fc9;
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, MSS_dir);
      ITArray<int>* __array28 = new IntArray(maxSize, 0);
      ITArray<int>* __array29 = new IntArray(maxSize, 0);
      ISimpleTypeArray<double>* __array30 = new FloatArray(maxSize, EMPTY_VALUE);
      ICustomTypeArray<Line*>* __array31 = new LineArray(maxSize, NULL);
      aZZ = new ZZ(__array28, __array29, __array30, __array31);
      in_out__ZZ_i_ic_fc_ic_fc8 = new in_out__ZZ_i_ic_fc_ic_fcStream(aZZ, 1, IndicatorObjPrefix + "_8");
      id = in_out__ZZ_i_ic_fc_ic_fc8.Init(id);
      in_out__ZZ_ic_ic_fc_ic_fc9 = new in_out__ZZ_ic_ic_fc_ic_fcStream(aZZ, IndicatorObjPrefix + "_9");
      id = in_out__ZZ_ic_ic_fc_ic_fc9.Init(id);
      __array28.Release();
      __array29.Release();
      __array30.Release();
      __array31.Release();
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, int __start, int __end, double __min, double __max)
   {
      if (!_initialized)
      {
         MSS_dir_DEFAULT_VALUE = Array::Get<int, ITArray<int>*, int>(aTrend, 0, INT_MIN);
         ArrayInitialize(MSS_dir, MSS_dir_DEFAULT_VALUE);
         in_out__ZZ_i_ic_fc_ic_fc8.Clear();
         in_out__ZZ_ic_ic_fc_ic_fc9.Clear();
         _initialized = true;
      }
      MSS_dir[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? MSS_dir[pos + 1] : Array::Get<int, ITArray<int>*, int>(aTrend, 0, INT_MIN);
      int start = __start;
      int end = __end;
      SetStream(min, pos, __min, min_DEFAULT_VALUE);
      SetStream(max, pos, __max, max_DEFAULT_VALUE);
      int x2 = n - 1;
      ICustomTypeArray<piv*>* swingH = NULL;
      ICustomTypeArray<piv*>* swingL = NULL;
      double mnPiv = EMPTY_VALUE;
      double mxPiv = EMPTY_VALUE;
      ICustomTypeArray<Line*>* targHi = NULL;
      ICustomTypeArray<Line*>* targLo = NULL;
      int active = (-1);
      ICustomTypeArray<piv*>* switch3Result;
      if ((str == "GN"))
      {
         switch3Result = swingH = aPiv::GetGN_swingH(a);
;
      }
      else if ((str == "LN"))
      {
         switch3Result = swingH = aPiv::GetLN_swingH(a);
;
      }
      else if ((str == "AM"))
      {
         switch3Result = swingH = aPiv::GetAM_swingH(a);
;
      }
      else if ((str == "PM"))
      {
         switch3Result = swingH = aPiv::GetPM_swingH(a);
;
      }
      switch3Result;
      if (start)
      {
         Array::Set<ISimpleTypeArray<double>*, int, double>(hilo, 0, 0);
         Array::Set<ISimpleTypeArray<double>*, int, double>(hilo, 1, 10e6);
         if ((stricty ? !keep : true))
         {
            while (SafeGreater(Array::Size<int, ICustomTypeArray<actLine*>*>(highs, INT_MIN), 0))
            {
               actLine* get = Array::Pop<actLine*, ICustomTypeArray<actLine*>*>(highs, NULL);
               LinesCollection::Delete(actLine::Getln(get));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<actLine*>*>(lows, INT_MIN), 0))
            {
               actLine* get = Array::Pop<actLine*, ICustomTypeArray<actLine*>*>(lows, NULL);
               LinesCollection::Delete(actLine::Getln(get));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(targHi, INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(targHi, NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(targLo, INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(targLo, NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(aPiv::GetGN_targHi(a), INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(aPiv::GetGN_targHi(a), NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(aPiv::GetLN_targHi(a), INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(aPiv::GetLN_targHi(a), NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(aPiv::GetAM_targHi(a), INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(aPiv::GetAM_targHi(a), NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(aPiv::GetPM_targHi(a), INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(aPiv::GetPM_targHi(a), NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(aPiv::GetGN_targLo(a), INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(aPiv::GetGN_targLo(a), NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(aPiv::GetLN_targLo(a), INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(aPiv::GetLN_targLo(a), NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(aPiv::GetAM_targLo(a), INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(aPiv::GetAM_targLo(a), NULL));
            }
            while (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(aPiv::GetPM_targLo(a), INT_MIN), 0))
            {
               LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(aPiv::GetPM_targLo(a), NULL));
            }
         }
      }
      if (active)
      {
         Array::Set<ISimpleTypeArray<double>*, int, double>(hilo, 0, SafeMathMax(Array::Get<double, ISimpleTypeArray<double>*, int>(hilo, 0, EMPTY_VALUE), iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)));
         Array::Set<ISimpleTypeArray<double>*, int, double>(hilo, 1, SafeMathMin(Array::Get<double, ISimpleTypeArray<double>*, int>(hilo, 1, EMPTY_VALUE), iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)));
      }
      if (NumberToBool(ph))
      {
         if (SafeGreater(ph, mxPiv))
         {
            mxPiv = ph;
         }
         if (SafeGreater(Array::Size<int, ICustomTypeArray<piv*>*>(swingH, INT_MIN), 0))
         {
            int for7_from = SafeMinus(Array::Size<int, ICustomTypeArray<piv*>*>(swingH, INT_MIN), 1);
            int for7_to = 0;
            bool for7_forward = for7_from <= for7_to;
            int for7_step = 1 * (for7_forward ? 1 : -1);
            if (for7_from == EMPTY_VALUE || for7_to == EMPTY_VALUE) { return false; }
            for (int i = for7_from; (for7_forward ? i <= for7_to : i >= for7_to); i += for7_step)
            {
               piv* get = Array::Get<piv*, ICustomTypeArray<piv*>*, int>(swingH, i, NULL);
               if (SafeGE(ph, piv::Getp(get)))
               {
                  Array::Remove<piv*, ICustomTypeArray<piv*>*, int>(swingH, i, NULL);
               }
            }
         }
         Array::Unshift<ICustomTypeArray<piv*>*, piv*>(swingH, new piv(n - 1, ph));
         if (((str == "GN") || (str == "LN")))
         {
            int dir = Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), 0, INT_MIN);
            int x1 = Array::Get<int, ITArray<int>*, int>(ZZ::Getx(aZZ), 0, INT_MIN);
            double y1 = Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), 0, EMPTY_VALUE);
            double y2 = Nz(iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1));
            if (SafeLess(dir, 1))
            {
               if (!in_out__ZZ_i_ic_fc_ic_fc8.GetValue(pos, x1, y1, x2, y2)) { }
            }
            else
            {
               if ((dir == 1) && SafeGreater(ph, y1))
               {
                  Array::Set<ITArray<int>*, int, int>(ZZ::Getx(aZZ), 0, x2);
                  Array::Set<ISimpleTypeArray<double>*, int, double>(ZZ::Gety(aZZ), 0, y2);
                  if (showZZ)
                  {
                     Line::SetXY2(Array::Get<Line*, ICustomTypeArray<Line*>*, int>(ZZ::Getl(aZZ), 0, NULL), x2, y2);
                  }
               }
            }
         }
      }
      if (NumberToBool(pl))
      {
         if (SafeLess(pl, mnPiv))
         {
            mnPiv = pl;
         }
         if (SafeGreater(Array::Size<int, ICustomTypeArray<piv*>*>(swingL, INT_MIN), 0))
         {
            int for8_from = SafeMinus(Array::Size<int, ICustomTypeArray<piv*>*>(swingL, INT_MIN), 1);
            int for8_to = 0;
            bool for8_forward = for8_from <= for8_to;
            int for8_step = 1 * (for8_forward ? 1 : -1);
            if (for8_from == EMPTY_VALUE || for8_to == EMPTY_VALUE) { return false; }
            for (int i = for8_from; (for8_forward ? i <= for8_to : i >= for8_to); i += for8_step)
            {
               piv* get = Array::Get<piv*, ICustomTypeArray<piv*>*, int>(swingL, i, NULL);
               if (SafeLE(pl, piv::Getp(get)))
               {
                  Array::Remove<piv*, ICustomTypeArray<piv*>*, int>(swingL, i, NULL);
               }
            }
         }
         Array::Unshift<ICustomTypeArray<piv*>*, piv*>(swingL, new piv(n - 1, pl));
         if (((str == "GN") || (str == "LN")))
         {
            int dir = Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), 0, INT_MIN);
            int x1 = Array::Get<int, ITArray<int>*, int>(ZZ::Getx(aZZ), 0, INT_MIN);
            double y1 = Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), 0, EMPTY_VALUE);
            double y2 = Nz(iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1));
            if (SafeGreater(dir, (-1)))
            {
               if (!in_out__ZZ_ic_ic_fc_ic_fc9.GetValue(pos, (-1), x1, y1, x2, y2)) { }
            }
            else
            {
               if ((dir == (-1)) && SafeLess(pl, y1))
               {
                  Array::Set<ITArray<int>*, int, int>(ZZ::Getx(aZZ), 0, x2);
                  Array::Set<ISimpleTypeArray<double>*, int, double>(ZZ::Gety(aZZ), 0, y2);
                  if (showZZ)
                  {
                     Line::SetXY2(Array::Get<Line*, ICustomTypeArray<Line*>*, int>(ZZ::Getl(aZZ), 0, NULL), x2, y2);
                  }
               }
            }
         }
      }
      int iH = ((Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), 2, INT_MIN) == 1) ? 2 : 1);
      int iL = ((Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), 2, INT_MIN) == (-1)) ? 2 : 1);
      if (SafeGreater(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), iH, EMPTY_VALUE)) && (Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), iH, INT_MIN) == 1) && SafeLess(MSS_dir[pos], 1))
      {
         SetStream(MSS_dir, pos, 1, MSS_dir_DEFAULT_VALUE);
         if (active && showT)
         {
            LinesCollection::Create(IndicatorObjPrefix + "line_5_id", Array::Get<int, ITArray<int>*, int>(ZZ::Getx(aZZ), iH, INT_MIN), Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), iH, EMPTY_VALUE), n, Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), iH, EMPTY_VALUE), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(cResLine).SetWidth(2).SetStyle("solid").SetExtend("none");
         }
      }
      else if (SafeLess(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), iL, EMPTY_VALUE)) && (Array::Get<int, ITArray<int>*, int>(ZZ::Getd(aZZ), iL, INT_MIN) == (-1)) && SafeGreater(MSS_dir[pos], (-1)))
      {
         SetStream(MSS_dir, pos, (-1), MSS_dir_DEFAULT_VALUE);
         if (active && showT)
         {
            LinesCollection::Create(IndicatorObjPrefix + "line_6_id", Array::Get<int, ITArray<int>*, int>(ZZ::Getx(aZZ), iL, INT_MIN), Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), iL, EMPTY_VALUE), n, Array::Get<double, ISimpleTypeArray<double>*, int>(ZZ::Gety(aZZ), iL, EMPTY_VALUE), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(cSupLine).SetWidth(2).SetStyle("solid").SetExtend("none");
         }
      }
      if (end)
      {
         int sz = Array::Size<int, ICustomTypeArray<piv*>*>(swingH, INT_MIN);
         if (SafeGreater(sz, 0))
         {
            int for9_from = 0;
            int for9_to = SafeMinus(sz, 1);
            bool for9_forward = for9_from <= for9_to;
            int for9_step = 1 * (for9_forward ? 1 : -1);
            if (for9_from == EMPTY_VALUE || for9_to == EMPTY_VALUE) { return false; }
            for (int i = for9_from; (for9_forward ? i <= for9_to : i >= for9_to); i += for9_step)
            {
               double y = piv::Getp(Array::Get<piv*, ICustomTypeArray<piv*>*, int>(swingH, i, NULL));
               if (SafeGreater(y, ((stricty ? min[pos] : Array::Get<double, ISimpleTypeArray<double>*, int>(hilo, 0, EMPTY_VALUE)))))
               {
                  Array::Unshift<ICustomTypeArray<Line*>*, Line*>(targHi, LinesCollection::Create(IndicatorObjPrefix + "line_7_id" + "_" + IntegerToString(i), piv::Getb(Array::Get<piv*, ICustomTypeArray<piv*>*, int>(swingH, i, NULL)), y, n, y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(cResLine).SetWidth(1).SetStyle("solid").SetExtend("none"));
                  Array::Unshift<ICustomTypeArray<actLine*>*, actLine*>(highs, new actLine(LinesCollection::Create(IndicatorObjPrefix + "line_8_id" + "_" + IntegerToString(i), n, y, n, y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(cResLine).SetWidth(1).SetStyle("solid").SetExtend("none"), true));
               }
            }
         }
         sz = Array::Size<int, ICustomTypeArray<piv*>*>(swingL, INT_MIN);
         if (SafeGreater(sz, 0))
         {
            int for10_from = 0;
            int for10_to = SafeMinus(sz, 1);
            bool for10_forward = for10_from <= for10_to;
            int for10_step = 1 * (for10_forward ? 1 : -1);
            if (for10_from == EMPTY_VALUE || for10_to == EMPTY_VALUE) { return false; }
            for (int i = for10_from; (for10_forward ? i <= for10_to : i >= for10_to); i += for10_step)
            {
               double y = piv::Getp(Array::Get<piv*, ICustomTypeArray<piv*>*, int>(swingL, i, NULL));
               if (SafeLess(y, ((stricty ? max[pos] : Array::Get<double, ISimpleTypeArray<double>*, int>(hilo, 1, EMPTY_VALUE)))))
               {
                  Array::Unshift<ICustomTypeArray<Line*>*, Line*>(targLo, LinesCollection::Create(IndicatorObjPrefix + "line_9_id" + "_" + IntegerToString(i), piv::Getb(Array::Get<piv*, ICustomTypeArray<piv*>*, int>(swingL, i, NULL)), y, n, y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(cSupLine).SetWidth(1).SetStyle("solid").SetExtend("none"));
                  Array::Unshift<ICustomTypeArray<actLine*>*, actLine*>(lows, new actLine(LinesCollection::Create(IndicatorObjPrefix + "line_10_id" + "_" + IntegerToString(i), n, y, n, y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(cSupLine).SetWidth(1).SetStyle("solid").SetExtend("none"), true));
               }
            }
         }
         Array::Clear<ICustomTypeArray<piv*>*>(swingH);
         Array::Clear<ICustomTypeArray<piv*>*>(swingL);
         mnPiv = 10e6;
         mxPiv = 0;
      }
      if (showZZ)
      {
         if ((NumberToBool(ph) || NumberToBool(pl)))
         {
            Line::SetColor(Array::Get<Line*, ICustomTypeArray<Line*>*, int>(ZZ::Getl(aZZ), 0, NULL), ((MSS_dir[pos] == 1) ? cResLine : cSupLine));
         }
      }
      Array::Set<ITArray<int>*, int, int>(aTrend, 0, MSS_dir[pos]);
      return true;
   }
};
f_swings_bc_bc_s_c_fc_fcStream* f_swings_bc_bc_s_c_fc_fc10;
f_swings_bc_bc_s_c_fc_fcStream* f_swings_bc_bc_s_c_fc_fc11;
f_swings_bc_bc_s_c_fc_fcStream* f_swings_bc_bc_s_c_fc_fc12;
f_swings_bc_bc_s_c_fc_fcStream* f_swings_bc_bc_s_c_fc_fc13;
PlotChar* plotchar1;
PlotChar* plotchar2;
PlotChar* plotchar3;
PlotChar* plotchar4;
PlotChar* plotchar5;

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
   IndicatorBuffers(11);
   left = param1;
   showSB = param2;
   col_SB = param3;
   choice = Get_param4();
   cBullFVG = param5;
   cBearFVG = param6;
   extend = param7;
   opt = Get_param8();
   cSupLine = param9;
   cResLine = param10;
   keep = param11;
   showT = param12;
   showZZ = param13;
   int id = 0;
   BoxesCollection::SetMaxBoxes(500);
   LinesCollection::SetMaxLines(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("LuxAlgo - ICT Silver Bullet");
   IndicatorShortName("ICT Silver Bullet [LuxAlgo]");
   ICustomTypeArray<piv*>* __array1 = new CustomTypeArray<piv*>(1, new piv(NULL, NULL));
   ICustomTypeArray<piv*>* __array2 = new CustomTypeArray<piv*>(1, new piv(NULL, NULL));
   ICustomTypeArray<Line*>* __array3 = new LineArray(0, NULL);
   ICustomTypeArray<Line*>* __array4 = new LineArray(0, NULL);
   ICustomTypeArray<piv*>* __array5 = new CustomTypeArray<piv*>(1, new piv(NULL, NULL));
   ICustomTypeArray<piv*>* __array6 = new CustomTypeArray<piv*>(1, new piv(NULL, NULL));
   ICustomTypeArray<Line*>* __array7 = new LineArray(0, NULL);
   ICustomTypeArray<Line*>* __array8 = new LineArray(0, NULL);
   ICustomTypeArray<piv*>* __array9 = new CustomTypeArray<piv*>(1, new piv(NULL, NULL));
   ICustomTypeArray<piv*>* __array10 = new CustomTypeArray<piv*>(1, new piv(NULL, NULL));
   ICustomTypeArray<Line*>* __array11 = new LineArray(0, NULL);
   ICustomTypeArray<Line*>* __array12 = new LineArray(0, NULL);
   ICustomTypeArray<piv*>* __array13 = new CustomTypeArray<piv*>(1, new piv(NULL, NULL));
   ICustomTypeArray<piv*>* __array14 = new CustomTypeArray<piv*>(1, new piv(NULL, NULL));
   ICustomTypeArray<Line*>* __array15 = new LineArray(0, NULL);
   ICustomTypeArray<Line*>* __array16 = new LineArray(0, NULL);
      a = new aPiv().SetGN_swingH(__array1).SetGN_swingL(__array2).SetGN_mnPiv(10e6).SetGN_mxPiv(0).SetGN_targHi(__array3).SetGN_targLo(__array4).SetLN_swingH(__array5).SetLN_swingL(__array6).SetLN_mnPiv(10e6).SetLN_mxPiv(0).SetLN_targHi(__array7).SetLN_targLo(__array8).SetAM_swingH(__array9).SetAM_swingL(__array10).SetAM_mnPiv(10e6).SetAM_mxPiv(0).SetAM_targHi(__array11).SetAM_targLo(__array12).SetPM_swingH(__array13).SetPM_swingL(__array14).SetPM_mnPiv(10e6).SetPM_mxPiv(0).SetPM_targHi(__array15).SetPM_targLo(__array16);
   ITArray<int>* __array17 = new IntArray(maxSize, 0);
   ITArray<int>* __array18 = new IntArray(maxSize, 0);
   ISimpleTypeArray<double>* __array19 = new FloatArray(maxSize, EMPTY_VALUE);
   ICustomTypeArray<Line*>* __array20 = new LineArray(maxSize, NULL);
      aZZ = new ZZ(__array17, __array18, __array19, __array20);
   SetIndexBuffer(id++, min);
   SetIndexBuffer(id++, max);
   timeSess_s_s1 = new timeSess_s_sStream("America/New_York", "0300-0400", IndicatorObjPrefix + "_1");
   id = timeSess_s_s1.Init(id);
   timeSess_s_s2 = new timeSess_s_sStream("America/New_York", "1000-1100", IndicatorObjPrefix + "_2");
   id = timeSess_s_s2.Init(id);
   timeSess_s_s3 = new timeSess_s_sStream("America/New_York", "1400-1500", IndicatorObjPrefix + "_3");
   id = timeSess_s_s3.Init(id);
   SetIndexBuffer(id++, is_in_SB);
   SetIndexBuffer(id++, SB_LN_per);
   SetIndexBuffer(id++, SB_AM_per);
   SetIndexBuffer(id++, SB_PM_per);
   type_s4 = new type_sStream("forex", IndicatorObjPrefix + "_4");
   id = type_s4.Init(id);
   type_s5 = new type_sStream("index", IndicatorObjPrefix + "_5");
   id = type_s5.Init(id);
   type_s6 = new type_sStream("futures", IndicatorObjPrefix + "_6");
   id = type_s6.Init(id);
   f_setTrend7 = new f_setTrendStream(IndicatorObjPrefix + "_7");
   id = f_setTrend7.Init(id);
   SetIndexBuffer(id++, endSB);
   f_swings_bc_bc_s_c_fc_fc10 = new f_swings_bc_bc_s_c_fc_fcStream("GN", col_SB, IndicatorObjPrefix + "_10");
   id = f_swings_bc_bc_s_c_fc_fc10.Init(id);
   f_swings_bc_bc_s_c_fc_fc11 = new f_swings_bc_bc_s_c_fc_fcStream("LN", col_SB, IndicatorObjPrefix + "_11");
   id = f_swings_bc_bc_s_c_fc_fc11.Init(id);
   f_swings_bc_bc_s_c_fc_fc12 = new f_swings_bc_bc_s_c_fc_fcStream("AM", col_SB, IndicatorObjPrefix + "_12");
   id = f_swings_bc_bc_s_c_fc_fc12.Init(id);
   f_swings_bc_bc_s_c_fc_fc13 = new f_swings_bc_bc_s_c_fc_fcStream("PM", col_SB, IndicatorObjPrefix + "_13");
   id = f_swings_bc_bc_s_c_fc_fc13.Init(id);
   plotchar1 = new PlotChar("*", IndicatorObjPrefix + "plotchar1", "top");
   plotchar2 = new PlotChar("*", IndicatorObjPrefix + "plotchar2", "top");
   plotchar3 = new PlotChar("*", IndicatorObjPrefix + "plotchar3", "top");
   plotchar4 = new PlotChar("�", IndicatorObjPrefix + "plotchar4", "abovebar");
   plotchar5 = new PlotChar("�", IndicatorObjPrefix + "plotchar5", "belowbar");
   __array20.Release();
   __array19.Release();
   __array18.Release();
   __array17.Release();
   __array16.Release();
   __array15.Release();
   __array14.Release();
   __array13.Release();
   __array12.Release();
   __array11.Release();
   __array10.Release();
   __array9.Release();
   __array8.Release();
   __array7.Release();
   __array6.Release();
   __array5.Release();
   __array4.Release();
   __array3.Release();
   __array2.Release();
   __array1.Release();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   a.Release();
   aZZ.Release();
   if (bFVG_bull != NULL) bFVG_bull.Release();
   if (bFVG_bear != NULL) bFVG_bear.Release();
   if (hilo != NULL) hilo.Release();
   if (aTrend != NULL) aTrend.Release();
   if (l_SB != NULL) l_SB.Release();
   if (highs != NULL) highs.Release();
   if (lows != NULL) lows.Release();
   delete timeSess_s_s1;
   delete timeSess_s_s2;
   delete timeSess_s_s3;
   delete type_s4;
   delete type_s5;
   delete type_s6;
   delete f_setTrend7;
   delete f_swings_bc_bc_s_c_fc_fc10;
   delete f_swings_bc_bc_s_c_fc_fc11;
   delete f_swings_bc_bc_s_c_fc_fc12;
   delete f_swings_bc_bc_s_c_fc_fc13;
   delete plotchar1;
   delete plotchar2;
   delete plotchar3;
   delete plotchar4;
   delete plotchar5;
   BoxesCollection::Clear(true);
   TableManager::Clear(true);
   LinesCollection::Clear(true);
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
      TableManager::Clear();
      LinesCollection::Clear();
      ICustomTypeArray<FVG*>* __array21 = new CustomTypeArray<FVG*>(1, new FVG().Setbox(BoxesCollection::Create(IndicatorObjPrefix + "box_1_id", INT_MIN, INT_MIN, INT_MIN, INT_MIN, 0, true)
         .SetBgColor(Blue)
         .SetBorderColor(Blue)
         .SetExtend("none")).Setactive(NULL));
      if (bFVG_bull != NULL) bFVG_bull.Release();
      bFVG_bull = __array21;
      bFVG_bull.AddRef();
      ICustomTypeArray<FVG*>* __array22 = new CustomTypeArray<FVG*>(1, new FVG().Setbox(BoxesCollection::Create(IndicatorObjPrefix + "box_2_id", INT_MIN, INT_MIN, INT_MIN, INT_MIN, 0, true)
         .SetBgColor(Blue)
         .SetBorderColor(Blue)
         .SetExtend("none")).Setactive(NULL));
      if (bFVG_bear != NULL) bFVG_bear.Release();
      bFVG_bear = __array22;
      bFVG_bear.AddRef();
      min_DEFAULT_VALUE = 10e6;
      ArrayInitialize(min, min_DEFAULT_VALUE);
      max_DEFAULT_VALUE = 0.;
      ArrayInitialize(max, max_DEFAULT_VALUE);
      ISimpleTypeArray<double>* __array23 = new FloatArray(0, NULL).Push(0).Push(10e6);
      if (hilo != NULL) hilo.Release();
      hilo = __array23;
      hilo.AddRef();
      ITArray<int>* __array24 = new IntArray(0, NULL).Push(0);
      if (aTrend != NULL) aTrend.Release();
      aTrend = __array24;
      aTrend.AddRef();
      ICustomTypeArray<Line*>* __array25 = new LineArray(0, NULL);
      if (l_SB != NULL) l_SB.Release();
      l_SB = __array25;
      l_SB.AddRef();
      ICustomTypeArray<actLine*>* __array26 = new CustomTypeArray<actLine*>(0, NULL);
      if (highs != NULL) highs.Release();
      highs = __array26;
      highs.AddRef();
      ICustomTypeArray<actLine*>* __array27 = new CustomTypeArray<actLine*>(0, NULL);
      if (lows != NULL) lows.Release();
      lows = __array27;
      lows.AddRef();
      tab = TableManager::Create(IndicatorObjPrefix, "1", "top_right", 1, 1).SetBorderWidth(1).SetBGColor((uint)(INT_MAX)).SetFrameWidth(0);
      timeSess_s_s1.Clear();
      timeSess_s_s2.Clear();
      timeSess_s_s3.Clear();
      is_in_SB_DEFAULT_VALUE = (-1);
      ArrayInitialize(is_in_SB, is_in_SB_DEFAULT_VALUE);
      SB_LN_per_DEFAULT_VALUE = NULL;
      ArrayInitialize(SB_LN_per, SB_LN_per_DEFAULT_VALUE);
      SB_AM_per_DEFAULT_VALUE = NULL;
      ArrayInitialize(SB_AM_per, SB_AM_per_DEFAULT_VALUE);
      SB_PM_per_DEFAULT_VALUE = NULL;
      ArrayInitialize(SB_PM_per, SB_PM_per_DEFAULT_VALUE);
      type_s4.Clear();
      type_s5.Clear();
      type_s6.Clear();
      f_setTrend7.Clear();
      endSB_DEFAULT_VALUE = (-1);
      ArrayInitialize(endSB, endSB_DEFAULT_VALUE);
      f_swings_bc_bc_s_c_fc_fc10.Clear();
      f_swings_bc_bc_s_c_fc_fc11.Clear();
      f_swings_bc_bc_s_c_fc_fc12.Clear();
      f_swings_bc_bc_s_c_fc_fc13.Clear();
      __array27.Release();
      __array26.Release();
      __array25.Release();
      __array24.Release();
      __array23.Release();
      __array22.Release();
      __array21.Release();
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
      min[pos] = pos < (rates_total - 1) ? min[pos + 1] : 10e6;
      max[pos] = pos < (rates_total - 1) ? max[pos + 1] : 0.;
      int superstrict = (choice == "Super-Strict");
      int iTrend = (choice != "All FVG");
      int strict = (choice == "Strict");
      stricty = (superstrict || strict);
      int prev = (opt == "previous session (any)");
      n = ((rates_total - 1) - pos);
      maxSize = 250;
      double minT = SymInfo::Mintick(_Symbol);
      double highestpivot1Value;
      if (!PivotHighStream::GetValue(pos, highestpivot1Value, _Symbol, (ENUM_TIMEFRAMES)_Period, left, 1)) { highestpivot1Value = EMPTY_VALUE; }
      ph = highestpivot1Value;
      double lowestpivot1Value;
      if (!PivotLowStream::GetValue(pos, lowestpivot1Value, _Symbol, (ENUM_TIMEFRAMES)_Period, left, 1)) { lowestpivot1Value = EMPTY_VALUE; }
      pl = lowestpivot1Value;
      datetime timeSess_s_s1Value;
      if (!timeSess_s_s1.GetValue(pos, timeSess_s_s1Value)) { timeSess_s_s1Value = NULL; }
      SetStream(SB_LN_per, pos, timeSess_s_s1Value, SB_LN_per_DEFAULT_VALUE);
      datetime timeSess_s_s2Value;
      if (!timeSess_s_s2.GetValue(pos, timeSess_s_s2Value)) { timeSess_s_s2Value = NULL; }
      SetStream(SB_AM_per, pos, timeSess_s_s2Value, SB_AM_per_DEFAULT_VALUE);
      datetime timeSess_s_s3Value;
      if (!timeSess_s_s3.GetValue(pos, timeSess_s_s3Value)) { timeSess_s_s3Value = NULL; }
      SetStream(SB_PM_per, pos, timeSess_s_s3Value, SB_PM_per_DEFAULT_VALUE);
      SetStream(is_in_SB, pos, ((SB_LN_per[pos] || SB_AM_per[pos]) || SB_PM_per[pos]), is_in_SB_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int strSB = is_in_SB[pos] && !is_in_SB[pos + 1];
      if (pos + 1 > (rates_total - 1)) { continue; }
      int strLN = SB_LN_per[pos] && !SB_LN_per[pos + 1];
      if (pos + 1 > (rates_total - 1)) { continue; }
      int strAM = SB_AM_per[pos] && !SB_AM_per[pos + 1];
      if (pos + 1 > (rates_total - 1)) { continue; }
      int strPM = SB_PM_per[pos] && !SB_PM_per[pos + 1];
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(endSB, pos, !is_in_SB[pos] && is_in_SB[pos + 1], endSB_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int endLN = !SB_LN_per[pos] && SB_LN_per[pos + 1];
      if (pos + 1 > (rates_total - 1)) { continue; }
      int endAM = !SB_AM_per[pos] && SB_AM_per[pos + 1];
      if (pos + 1 > (rates_total - 1)) { continue; }
      int endPM = !SB_PM_per[pos] && SB_PM_per[pos + 1];
      int type_s4Value;
      if (!type_s4.GetValue(pos, type_s4Value)) { type_s4Value = (-1); }
      int type_s5Value;
      if (!type_s5.GetValue(pos, type_s5Value)) { type_s5Value = (-1); }
      int type_s6Value;
      if (!type_s6.GetValue(pos, type_s6Value)) { type_s6Value = (-1); }
      double minimum_trade_framework = (type_s4Value ? SymInfo::Mintick(_Symbol) * 15 * 10 : ((type_s5Value || type_s6Value) ? SymInfo::Mintick(_Symbol) * 40 : 0));
      if (!f_setTrend7.GetValue(pos)) { }
      int trend = Array::Get<int, ITArray<int>*, int>(aTrend, 0, INT_MIN);
      int targetHi = false;
      int targetLo = false;
      int hSz = Array::Size<int, ICustomTypeArray<actLine*>*>(highs, INT_MIN);
      if (SafeGreater(hSz, 200))
      {
         LinesCollection::Delete(actLine::Getln(Array::Pop<actLine*, ICustomTypeArray<actLine*>*>(highs, NULL)));
      }
      hSz = Array::Size<int, ICustomTypeArray<actLine*>*>(highs, INT_MIN);
      if (SafeGreater(hSz, 0))
      {
         int for1_from = 0;
         int for1_to = SafeMinus(hSz, 1);
         bool for1_forward = for1_from <= for1_to;
         int for1_step = 1 * (for1_forward ? 1 : -1);
         if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { continue; }
         for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
         {
            actLine* get = Array::Get<actLine*, ICustomTypeArray<actLine*>*, int>(highs, i, NULL);
            if (actLine::Getactive(get))
            {
               Line::SetX2(actLine::Getln(get), n);
               if (SafeGreater(high[pos], Line::GetY2(actLine::Getln(get))))
               {
                  actLine::Setactive(get, false);
                  targetHi = true;
               }
            }
         }
      }
      int lSz = Array::Size<int, ICustomTypeArray<actLine*>*>(lows, INT_MIN);
      if (SafeGreater(lSz, 200))
      {
         LinesCollection::Delete(actLine::Getln(Array::Pop<actLine*, ICustomTypeArray<actLine*>*>(lows, NULL)));
      }
      lSz = Array::Size<int, ICustomTypeArray<actLine*>*>(lows, INT_MIN);
      if (SafeGreater(lSz, 0))
      {
         int for2_from = 0;
         int for2_to = SafeMinus(lSz, 1);
         bool for2_forward = for2_from <= for2_to;
         int for2_step = 1 * (for2_forward ? 1 : -1);
         if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { continue; }
         for (int i = for2_from; (for2_forward ? i <= for2_to : i >= for2_to); i += for2_step)
         {
            actLine* get = Array::Get<actLine*, ICustomTypeArray<actLine*>*, int>(lows, i, NULL);
            if (actLine::Getactive(get))
            {
               Line::SetX2(actLine::Getln(get), n);
               if (SafeLess(low[pos], Line::GetY2(actLine::Getln(get))))
               {
                  actLine::Setactive(get, false);
                  targetLo = true;
               }
            }
         }
      }
      if (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(l_SB, INT_MIN), 100))
      {
         LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(l_SB, NULL));
      }
      if (strSB)
      {
         SetStream(min, pos, 10e6, min_DEFAULT_VALUE);
         SetStream(max, pos, 0., max_DEFAULT_VALUE);
         if (showSB)
         {
            Array::Unshift<ICustomTypeArray<Line*>*, Line*>(l_SB, LinesCollection::Create(IndicatorObjPrefix + "line_1_id", n, close[pos], n, close[pos] + minT, time[pos]).SetColor(col_SB).SetWidth(1).SetStyle("solid").SetExtend("both"));
         }
         int for3_from = 0;
         int for3_to = SafeMinus(Array::Size<int, ICustomTypeArray<FVG*>*>(bFVG_bull, INT_MIN), 1);
         bool for3_forward = for3_from <= for3_to;
         int for3_step = 1 * (for3_forward ? 1 : -1);
         if (for3_from == EMPTY_VALUE || for3_to == EMPTY_VALUE) { continue; }
         for (int i = for3_from; (for3_forward ? i <= for3_to : i >= for3_to); i += for3_step)
         {
            FVG* get = Array::Get<FVG*, ICustomTypeArray<FVG*>*, int>(bFVG_bull, i, NULL);
            if (SafeGreater(n, SafeMinus(Box::GetRight(FVG::Getbox(get)), 1)))
            {
               if ((FVG::Getcurrent(get) == true))
               {
                  FVG::Setcurrent(get, false);
               }
            }
         }
         int for4_from = 0;
         int for4_to = SafeMinus(Array::Size<int, ICustomTypeArray<FVG*>*>(bFVG_bear, INT_MIN), 1);
         bool for4_forward = for4_from <= for4_to;
         int for4_step = 1 * (for4_forward ? 1 : -1);
         if (for4_from == EMPTY_VALUE || for4_to == EMPTY_VALUE) { continue; }
         for (int i = for4_from; (for4_forward ? i <= for4_to : i >= for4_to); i += for4_step)
         {
            FVG* get = Array::Get<FVG*, ICustomTypeArray<FVG*>*, int>(bFVG_bear, i, NULL);
            if (SafeGreater(n, SafeMinus(Box::GetRight(FVG::Getbox(get)), 1)))
            {
               if ((FVG::Getcurrent(get) == true))
               {
                  FVG::Setcurrent(get, false);
               }
            }
         }
      }
      if (is_in_SB[pos])
      {
         trend = Array::Get<int, ITArray<int>*, int>(aTrend, 0, INT_MIN);
         if (iTrend)
         {
            if ((trend == 1))
            {
               if (pos + 2 > (rates_total - 1)) { continue; }
               if (SafeGreater(low[pos], high[pos + 2]))
               {
                  if (pos + 2 > (rates_total - 1)) { continue; }
                  Array::Unshift<ICustomTypeArray<FVG*>*, FVG*>(bFVG_bull, new FVG().Setbox(BoxesCollection::Create(IndicatorObjPrefix + "box_3_id", n - 2, low[pos], n, high[pos + 2], time[pos])
                     .SetBgColor(cBullFVG)
                     .SetBorderColor((uint)(INT_MAX))
                     .SetExtend("none")).Setactive(false).Setcurrent(true));
               }
            }
            else
            {
               if (pos + 2 > (rates_total - 1)) { continue; }
               if (SafeLess(high[pos], low[pos + 2]))
               {
                  if (pos + 2 > (rates_total - 1)) { continue; }
                  Array::Unshift<ICustomTypeArray<FVG*>*, FVG*>(bFVG_bear, new FVG().Setbox(BoxesCollection::Create(IndicatorObjPrefix + "box_4_id", n - 2, low[pos + 2], n, high[pos], time[pos])
                     .SetBgColor(cBearFVG)
                     .SetBorderColor((uint)(INT_MAX))
                     .SetExtend("none")).Setactive(false).Setcurrent(true));
               }
            }
;
         }
         else
         {
            if (pos + 2 > (rates_total - 1)) { continue; }
            if (SafeGreater(low[pos], high[pos + 2]))
            {
               if (pos + 2 > (rates_total - 1)) { continue; }
               Array::Unshift<ICustomTypeArray<FVG*>*, FVG*>(bFVG_bull, new FVG().Setbox(BoxesCollection::Create(IndicatorObjPrefix + "box_5_id", n, low[pos], n, high[pos + 2], time[pos])
                  .SetBgColor(cBullFVG)
                  .SetBorderColor((uint)(INT_MAX))
                  .SetExtend("none")).Setactive(false).Setcurrent(true));
            }
            if (pos + 2 > (rates_total - 1)) { continue; }
            if (SafeLess(high[pos], low[pos + 2]))
            {
               if (pos + 2 > (rates_total - 1)) { continue; }
               Array::Unshift<ICustomTypeArray<FVG*>*, FVG*>(bFVG_bear, new FVG().Setbox(BoxesCollection::Create(IndicatorObjPrefix + "box_6_id", n, low[pos + 2], n, high[pos], time[pos])
                  .SetBgColor(cBearFVG)
                  .SetBorderColor((uint)(INT_MAX))
                  .SetExtend("none")).Setactive(false).Setcurrent(true));
            }
         }
      }
      if (endSB[pos])
      {
         if (showSB)
         {
            Array::Unshift<ICustomTypeArray<Line*>*, Line*>(l_SB, LinesCollection::Create(IndicatorObjPrefix + "line_2_id", n, close[pos], n, close[pos] + minT, time[pos]).SetColor(col_SB).SetWidth(1).SetStyle("solid").SetExtend("both"));
         }
      }
      if (SafeGreater(Array::Size<int, ICustomTypeArray<FVG*>*>(bFVG_bull, INT_MIN), 0))
      {
         int for5_from = 0;
         int for5_to = SafeMinus(Array::Size<int, ICustomTypeArray<FVG*>*>(bFVG_bull, INT_MIN), 1);
         bool for5_forward = for5_from <= for5_to;
         int for5_step = 1 * (for5_forward ? 1 : -1);
         if (for5_from == EMPTY_VALUE || for5_to == EMPTY_VALUE) { continue; }
         for (int i = for5_from; (for5_forward ? i <= for5_to : i >= for5_to); i += for5_step)
         {
            FVG* get = Array::Get<FVG*, ICustomTypeArray<FVG*>*, int>(bFVG_bull, i, NULL);
            int bLeft = Box::GetLeft(FVG::Getbox(get));
            double bTop = Box::GetTop(FVG::Getbox(get));
            double bBot = Box::GetBottom(FVG::Getbox(get));
            if (SafeLess(SafeMinus(n, bLeft), 1000))
            {
               if (FVG::Getcurrent(get))
               {
                  if (is_in_SB[pos])
                  {
                     if (SafeLess(close[pos], bBot))
                     {
                        if (superstrict)
                        {
                           FVG::Setcurrent(get, false);
                           Box::SetBgColor(FVG::Getbox(get), AddTransparency(Blue, 100));
                           Box::SetRight(FVG::Getbox(get), bLeft);
                        }
                        if ((superstrict || strict))
                        {
                           FVG::Setactive(get, false);
                        }
                     }
                     else
                     {
                        if (extend)
                        {
                           if (FVG::Getactive(get))
                           {
                              Box::SetRight(FVG::Getbox(get), n);
                           }
                        }
                     }
                     if (!FVG::Getactive(get))
                     {
                        if (SafeLess(low[pos], bTop) && SafeGreater(close[pos], bBot))
                        {
                           FVG::Setactive(get, true);
                           if (extend)
                           {
                              Box::SetRight(FVG::Getbox(get), n);
                           }
                        }
                     }
                  }
                  if (endSB[pos])
                  {
                     if (FVG::Getactive(get))
                     {
                        if (strict)
                        {
                           if (SafeLess(close[pos], bBot))
                           {
                              FVG::Setactive(get, false);
                           }
                        }
                        if (superstrict)
                        {
                           if (SafeLess(close[pos], bTop))
                           {
                              FVG::Setactive(get, false);
                           }
                        }
                     }
                     if (!FVG::Getactive(get))
                     {
                        Box::SetBgColor(FVG::Getbox(get), AddTransparency(Blue, 100));
                        Box::SetRight(FVG::Getbox(get), bLeft);
                     }
                     if (FVG::Getactive(get))
                     {
                        SetStream(min, pos, SafeMathMin(min[pos], SafePlus(bBot, minimum_trade_framework)), min_DEFAULT_VALUE);
                        if (extend)
                        {
                           Box::SetRight(FVG::Getbox(get), n);
                        }
                     }
                  }
                  if (pos + 1 > (rates_total - 1)) { continue; }
                  if (endSB[pos + 1])
                  {
                     FVG::Setactive(get, false);
                  }
               }
            }
         }
      }
      if (SafeGreater(Array::Size<int, ICustomTypeArray<FVG*>*>(bFVG_bear, INT_MIN), 0))
      {
         int for6_from = 0;
         int for6_to = SafeMinus(Array::Size<int, ICustomTypeArray<FVG*>*>(bFVG_bear, INT_MIN), 1);
         bool for6_forward = for6_from <= for6_to;
         int for6_step = 1 * (for6_forward ? 1 : -1);
         if (for6_from == EMPTY_VALUE || for6_to == EMPTY_VALUE) { continue; }
         for (int i = for6_from; (for6_forward ? i <= for6_to : i >= for6_to); i += for6_step)
         {
            FVG* get = Array::Get<FVG*, ICustomTypeArray<FVG*>*, int>(bFVG_bear, i, NULL);
            int bLeft = Box::GetLeft(FVG::Getbox(get));
            double bTop = Box::GetTop(FVG::Getbox(get));
            double bBot = Box::GetBottom(FVG::Getbox(get));
            if (SafeLess(SafeMinus(n, bLeft), 1000))
            {
               if (FVG::Getcurrent(get))
               {
                  if (is_in_SB[pos])
                  {
                     if (SafeGreater(close[pos], bTop))
                     {
                        if (superstrict)
                        {
                           FVG::Setcurrent(get, false);
                           Box::SetBgColor(FVG::Getbox(get), AddTransparency(Blue, 100));
                           Box::SetRight(FVG::Getbox(get), bLeft);
                        }
                        if ((superstrict || strict))
                        {
                           FVG::Setactive(get, false);
                        }
                     }
                     else
                     {
                        if (extend)
                        {
                           if (FVG::Getactive(get))
                           {
                              Box::SetRight(FVG::Getbox(get), n);
                           }
                        }
                     }
                     if (!FVG::Getactive(get))
                     {
                        if (SafeGreater(high[pos], bBot) && SafeLess(close[pos], bTop))
                        {
                           FVG::Setactive(get, true);
                           if (extend)
                           {
                              Box::SetRight(FVG::Getbox(get), n);
                           }
                        }
                     }
                  }
                  if (endSB[pos])
                  {
                     if (FVG::Getactive(get))
                     {
                        if (strict)
                        {
                           if (SafeGreater(close[pos], bTop))
                           {
                              FVG::Setactive(get, false);
                           }
                        }
                        if (superstrict)
                        {
                           if (SafeGreater(close[pos], bBot))
                           {
                              FVG::Setactive(get, false);
                           }
                        }
                     }
                     if (!FVG::Getactive(get))
                     {
                        Box::SetBgColor(FVG::Getbox(get), AddTransparency(Blue, 100));
                        Box::SetRight(FVG::Getbox(get), bLeft);
                     }
                     if (FVG::Getactive(get))
                     {
                        SetStream(max, pos, SafeMathMax(max[pos], SafeMinus(bTop, minimum_trade_framework)), max_DEFAULT_VALUE);
                        if (extend)
                        {
                           Box::SetRight(FVG::Getbox(get), n);
                        }
                     }
                  }
                  if (pos + 1 > (rates_total - 1)) { continue; }
                  if (endSB[pos + 1])
                  {
                     FVG::Setactive(get, false);
                  }
               }
            }
         }
      }
      if (prev)
      {
         if (!f_swings_bc_bc_s_c_fc_fc10.GetValue(pos, strSB, endSB[pos], min[pos], max[pos])) { }
      }
      else
      {
         if (!f_swings_bc_bc_s_c_fc_fc11.GetValue(pos, strLN, endLN, min[pos], max[pos])) { }
         if (!f_swings_bc_bc_s_c_fc_fc12.GetValue(pos, strAM, endAM, min[pos], max[pos])) { }
         if (!f_swings_bc_bc_s_c_fc_fc13.GetValue(pos, strPM, endPM, min[pos], max[pos])) { }
      }
      int tfs = SafeDivide((SafeDivide(60, (SafeDivide(Timeframe::InSeconds(Timeframe::Period()), 60)))), 2);
      if (pos + 1 > (rates_total - 1)) { continue; }
      plotchar1.Set(pos, !((SB_LN_per[pos]) == NULL) && ((SB_LN_per[pos + 1]) == NULL) && showSB, (uint)(INT_MAX));
      if (pos + 1 > (rates_total - 1)) { continue; }
      plotchar2.Set(pos, !((SB_AM_per[pos]) == NULL) && ((SB_AM_per[pos + 1]) == NULL) && showSB, (uint)(INT_MAX));
      if (pos + 1 > (rates_total - 1)) { continue; }
      plotchar3.Set(pos, !((SB_PM_per[pos]) == NULL) && ((SB_PM_per[pos + 1]) == NULL) && showSB, (uint)(INT_MAX));
      plotchar4.Set(pos, NumberToBool((targetHi ? high[pos] : EMPTY_VALUE)), cResLine);
      plotchar5.Set(pos, NumberToBool((targetLo ? low[pos] : EMPTY_VALUE)), cSupLine);
      if ((pos == 0))
      {
         if (SafeGreater(Timeframe::InSeconds(Timeframe::Period()), 15 * 60))
         {
            Table::CellText(tab, 0, 0, "Please use a timeframe <= 15 minutes");
            Table::CellTextColor(tab, 0, 0, 0x0000FF);
            Table::CellTextSize(tab, 0, 0, "normal");
            Table::CellTextHAlign(tab, 0, 0, "center");
         }
      }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   BoxesCollection::Redraw();
   TableManager::Redraw();
   LinesCollection::Redraw();
   return rates_total;
}
// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76310&p=160568#p160568
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