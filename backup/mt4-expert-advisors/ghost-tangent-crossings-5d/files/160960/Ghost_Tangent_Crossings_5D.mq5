//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76385&p=160960#p160960
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
#property indicator_buffers 13
#property indicator_plots 0

// Array v1.8
// Array interface v1.0

// Box array interface v1.1
#ifndef Box_IMPL
#define Box_IMPL

#define ColorRGB(red, green, blue, transp) (uint)((red) + ((green) << 8) + ((blue) << 16) + ((uint)(transp * 2.55) << 24))
#define ColorR(clr) ((clr & 0x00FF0000) >> 16)
#define ColorG(clr) ((clr & 0x0000FF00) >> 8)
#define ColorB(clr) (clr & 0x000000FF)
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
   double range = topValue - bottomValue;
   double rate = (value - bottomValue) / range;
   if (rate > 1)
   {
      return bottomColor;
   }
   if (rate < 0)
   {
      return topColor;
   }
   uint bottomR = ColorR(bottomColor);
   uint bottomG = ColorG(bottomColor);
   uint bottomB = ColorB(bottomColor);
   uint topR = ColorR(topColor);
   uint topG = ColorG(topColor);
   uint topB = ColorB(topColor);
   return ColorRGB(bottomR + int(rate * (topR - bottomR)), bottomG + int(rate * (topG - bottomG)), bottomB + int(rate * (topB - bottomB)), 0);
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

class PineScriptTime
{
public:
   static int Day(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.day;
   }
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

// Box object v1.3

class Box
{
   string _id;
   string _collectionId;
   int _left;
   double _top;
   int _right;
   double _bottom;
   int _window;
   uint _bgcolor;
   uint _borderColor;
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
   ~Box()
   {
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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

   static void SetBgColor(Box* box, uint clr) { if (box == NULL) { return; } box.SetBgColor(clr); }
   Box* SetBgColor(uint clr) { _bgcolor = clr; return &this; }
   static void SetBorderColor(Box* box, uint clr) { if (box == NULL) { return; } box.SetBorderColor(clr); }
   Box* SetBorderColor(uint clr) { _borderColor = clr; return &this; }
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
   static void SetTextColor(Box* box, uint clr) { if (box == NULL) { return; } box.SetTextColor(clr); }
   Box* SetTextColor(uint clr) { _textColor = clr; return &this; }

   void Redraw()
   {
      int totalBars = iBars(_Symbol, _timeframe);
      datetime left;
      if (_extend == "left" || _extend == "both")
      {
         left = iTime(_Symbol, _timeframe, iBars(_Symbol, _timeframe) - 1);
      }
      else
      {
         left = GetTime(_left, totalBars);
      }
      datetime right;
      if (_extend == "right" || _extend == "both")
      {
         right = iTime(_Symbol, _timeframe, 0);
      }
      else
      {
         right = GetTime(_right, totalBars);
      }
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_RECTANGLE, _window, left, _top, right, _bottom))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, GetColorOnly(_bgcolor));
         ObjectSetInteger(0, _id, OBJPROP_BGCOLOR, GetColorOnly(_bgcolor));
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, 1);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 0, _top);
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 1, _bottom);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 0, left);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 1, right);
   }
private:
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _timeframe, 0) + MathAbs(pos) * PeriodSeconds(_timeframe) : iTime(_Symbol, _timeframe, pos);
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
   virtual void Sort(bool ascending) = 0;
};
// float array interface v2.0
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
   virtual void Sort(bool ascending) = 0;
};

class IFloatArray : public ITArray<double>
{
public:
   virtual IFloatArray* Slice(int from, int to) = 0;
   virtual IFloatArray* Clear() = 0;
};
// Int array interface v1.2

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
   virtual void Sort(bool ascending) = 0;
};
#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v2.0
#ifndef CustomTypeArray_IMPL
#define CustomTypeArray_IMPL

template <typename CLASS_TYPE>
interface ICustomTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ICustomTypeArray<CLASS_TYPE>* Clear() = 0;
};

template <typename CLASS_TYPE>
class CustomTypeArraySlice : public ICustomTypeArray<CLASS_TYPE>
{
   ITArray<CLASS_TYPE>* array;
   int from;
   int to;
   int _refs;
public:
   CustomTypeArraySlice(ITArray<CLASS_TYPE>* array, int from, int to)
   {
      _refs = 1;
      this.array = array;
      this.from = from;
      this.to = to;
   }
   
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(CLASS_TYPE value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      //do nothing
      return &this;
   }
   virtual CLASS_TYPE Pop()
   {
      return NULL;
   }
   virtual CLASS_TYPE Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, CLASS_TYPE value)
   {
      //do nothing
   }
   virtual ITArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return NULL;
   }
   virtual ICustomTypeArray<CLASS_TYPE>* Clear()
   {
      return NULL;
   }
   virtual CLASS_TYPE Shift()
   {
      return NULL;
   }
   virtual CLASS_TYPE Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
   int Includes(CLASS_TYPE value)
   {
      int size = Size();
      for (int i = 0; i < size; ++i)
      {
         if (Get(i) == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE First()
   {
      if (Size() == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = Get(0);
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
   CLASS_TYPE Last()
   {
      int size = Size();
      if (size == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = Get(size - 1);
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
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
   
   void Sort(bool ascending)
   {
      //do nothing
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
      
   ICustomTypeArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return new CustomTypeArraySlice<CLASS_TYPE>(&this, from, to);
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
   
   CLASS_TYPE First()
   {
      if (ArraySize(_array) == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = _array[0];
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
   CLASS_TYPE Last()
   {
      int size = ArraySize(_array);
      if (size == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = _array[size - 1];
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
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

// Line object v1.7

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   string _xLoc;
   uint _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   string _extend;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window, bool global)
   {
      _xLoc = "bar_index";
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
   ~Line()
   {
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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
   static int GetX1(Line* line) { if (line == NULL) { return INT_MIN; } return line.GetX1(); }
   int GetX2() { return _x2; }
   static int GetX2(Line* line) { if (line == NULL) { return INT_MIN; } return line.GetX2(); }
   double GetY1() { return _y1; }
   static double GetY1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY1(); }
   double GetY2() { return _y2; }
   static double GetY2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY2(); }
   
   static void SetXLoc(Line* line, string val)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXLoc(val);
   }
   Line* SetXLoc(string val)
   {
      _xLoc = val;
      return &this;
   }

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
      int totalBars = iBars(_Symbol, _timeframe);
      datetime x1 = GetTime(_x1, totalBars);
      datetime x2 = GetTime(_x2, totalBars);
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
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 0, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 1, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 0, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 1, x2);
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
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _timeframe, 0) + MathAbs(pos) * PeriodSeconds(_timeframe) : iTime(_Symbol, _timeframe, pos);
   }
};

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
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string lineId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, ChartWindowOnDropped(), global);
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
      Line* clone = LinesCollection::Create(item.GetId() + index, item.GetX1(), item.GetY1(), item.GetX2(), item.GetY2(), 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Line* item)
   {
      LinesCollection::Delete(item);
   }
};

#endif
// Int array v2.0
// Simple type array v1.2

#ifndef SimpleTypeArray_IMPL
#define SimpleTypeArray_IMPL

template <typename CLASS_TYPE>
interface ISimpleTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ISimpleTypeArray<CLASS_TYPE>* Clear() = 0;
   virtual ISimpleTypeArray<CLASS_TYPE>* Copy() = 0;
   virtual ISimpleTypeArray<CLASS_TYPE>* Slice(int from, int to) = 0;
};

template <typename CLASS_TYPE>
class SimpleTypeArraySlice : public ISimpleTypeArray<CLASS_TYPE>
{
   ITArray<CLASS_TYPE>* array;
   int from;
   int to;
   int _refs;
   CLASS_TYPE emptyValue;
public:
   SimpleTypeArraySlice(ITArray<CLASS_TYPE>* array, int from, int to, CLASS_TYPE emptyValue)
   {
      _refs = 1;
      this.array = array;
      this.from = from;
      this.to = to;
      this.emptyValue = emptyValue;
   }
   
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(CLASS_TYPE value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      //do nothing
      return &this;
   }
   virtual CLASS_TYPE Pop()
   {
      return emptyValue;
   }
   virtual CLASS_TYPE Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, CLASS_TYPE value)
   {
      //do nothing
   }
   virtual ISimpleTypeArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return NULL;
   }
   virtual ISimpleTypeArray<CLASS_TYPE>* Clear()
   {
      return NULL;
   }
   virtual ISimpleTypeArray<CLASS_TYPE>* Copy()
   {
      return NULL;
   }
   virtual CLASS_TYPE Shift()
   {
      return emptyValue;
   }
   virtual CLASS_TYPE Remove(int index)
   {
      return emptyValue;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
   int Includes(CLASS_TYPE value)
   {
      int size = Size();
      for (int i = 0; i < size; ++i)
      {
         if (Get(i) == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE First()
   {
      if (Size() == 0)
      {
         return emptyValue;
      }
      return Get(0);
   }
   CLASS_TYPE Last()
   {
      int size = Size();
      if (size == 0)
      {
         return emptyValue;
      }
      return Get(size - 1);
   }
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
   
   ISimpleTypeArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return new SimpleTypeArraySlice<CLASS_TYPE>(&this, from, to, _emptyValue);
   }
   
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
   ISimpleTypeArray<CLASS_TYPE>* Copy()
   {
      SimpleTypeArray* clone = new SimpleTypeArray(_defaultSize, _defaultValue, _emptyValue);
      for (int i = 0; i < Size(); ++i)
      {
         clone.Push(Get(i));
      }
      return clone;
   }
   
   void Sort(bool ascending)
   {
      ArraySort(_array);
      if (!ascending)
      {
         ArrayReverse(_array);
      }
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

class IntArray : public SimpleTypeArray<int>
{
public:
   IntArray(int size, int defaultValue)
      :SimpleTypeArray(size, defaultValue, INT_MIN)
   {
   }
};
// Float array v2.0


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
// Box array v1.5

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
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string boxId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      
      Box* box = new Box(left, top, right, bottom, boxId, id, ChartWindowOnDropped(), global);
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

class BoxArraySlice : public IBoxArray
{
   IBoxArray* array;
   int from;
   int to;
public:
   BoxArraySlice(IBoxArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(Box* value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(Box* value)
   {
      //do nothing
   }
   virtual Box* Pop()
   {
      return NULL;
   }
   virtual Box* Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, Box* value)
   {
      //do nothing
   }
   virtual IBoxArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual IBoxArray* Clear()
   {
      return NULL;
   }
   virtual Box* Shift()
   {
      return NULL;
   }
   virtual Box* Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class BoxArray : public IBoxArray
{
   Box* _array[];
   int _defaultSize;
   Box* _defaultValue;
   BoxArraySlice* slices[];
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
      for (int i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            BoxesCollection::Delete(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
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
      int size = ArraySize(slices);
      for (int i = 0; i < size; ++i)
      {
         if (slices[i].GetFrom() == from && slices[i].GetTo() == to)
         {
            return slices[i];
         }
      }
      ArrayResize(slices, size + 1);
      slices[size] = new BoxArraySlice(&this, from, to);
      return slices[size];
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
#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v2.0
#ifndef CustomTypeArray_IMPL
#define CustomTypeArray_IMPL

template <typename CLASS_TYPE>
interface ICustomTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ICustomTypeArray<CLASS_TYPE>* Clear() = 0;
};

template <typename CLASS_TYPE>
class CustomTypeArraySlice : public ICustomTypeArray<CLASS_TYPE>
{
   ITArray<CLASS_TYPE>* array;
   int from;
   int to;
   int _refs;
public:
   CustomTypeArraySlice(ITArray<CLASS_TYPE>* array, int from, int to)
   {
      _refs = 1;
      this.array = array;
      this.from = from;
      this.to = to;
   }
   
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(CLASS_TYPE value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      //do nothing
      return &this;
   }
   virtual CLASS_TYPE Pop()
   {
      return NULL;
   }
   virtual CLASS_TYPE Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, CLASS_TYPE value)
   {
      //do nothing
   }
   virtual ITArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return NULL;
   }
   virtual ICustomTypeArray<CLASS_TYPE>* Clear()
   {
      return NULL;
   }
   virtual CLASS_TYPE Shift()
   {
      return NULL;
   }
   virtual CLASS_TYPE Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
   int Includes(CLASS_TYPE value)
   {
      int size = Size();
      for (int i = 0; i < size; ++i)
      {
         if (Get(i) == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE First()
   {
      if (Size() == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = Get(0);
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
   CLASS_TYPE Last()
   {
      int size = Size();
      if (size == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = Get(size - 1);
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
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
   
   void Sort(bool ascending)
   {
      //do nothing
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
      
   ICustomTypeArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return new CustomTypeArraySlice<CLASS_TYPE>(&this, from, to);
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
   
   CLASS_TYPE First()
   {
      if (ArraySize(_array) == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = _array[0];
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
   CLASS_TYPE Last()
   {
      int size = ArraySize(_array);
      if (size == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = _array[size - 1];
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
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

// Line object v1.7

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   string _xLoc;
   uint _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   string _extend;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window, bool global)
   {
      _xLoc = "bar_index";
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
   ~Line()
   {
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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
   static int GetX1(Line* line) { if (line == NULL) { return INT_MIN; } return line.GetX1(); }
   int GetX2() { return _x2; }
   static int GetX2(Line* line) { if (line == NULL) { return INT_MIN; } return line.GetX2(); }
   double GetY1() { return _y1; }
   static double GetY1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY1(); }
   double GetY2() { return _y2; }
   static double GetY2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY2(); }
   
   static void SetXLoc(Line* line, string val)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXLoc(val);
   }
   Line* SetXLoc(string val)
   {
      _xLoc = val;
      return &this;
   }

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
      int totalBars = iBars(_Symbol, _timeframe);
      datetime x1 = GetTime(_x1, totalBars);
      datetime x2 = GetTime(_x2, totalBars);
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
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 0, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 1, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 0, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 1, x2);
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
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _timeframe, 0) + MathAbs(pos) * PeriodSeconds(_timeframe) : iTime(_Symbol, _timeframe, pos);
   }
};

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
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string lineId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, ChartWindowOnDropped(), global);
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
      Line* clone = LinesCollection::Create(item.GetId() + index, item.GetX1(), item.GetY1(), item.GetX2(), item.GetY2(), 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Line* item)
   {
      LinesCollection::Delete(item);
   }
};

#endif


class Array
{
public:
   template <typename ARRAY_TYPE>
   static void Clear(ARRAY_TYPE array) { if (array == NULL) { return; } array.Clear(); }
   
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
   static int IndexOf(ARRAY_TYPE array, VALUE_TYPE value)
   {
      if (array == NULL)
      {
         return -1;
      }
      for (int i = 0; i < array.Size(); ++i)
      {
         if (value == array.Get(i))
         {
            return i;
         }
      }
      return -1;
   }
   
   template <typename ARRAY_TYPE, typename DUMMY_TYPE1, typename DUMMY_TYPE2, typename DUMMY_TYPE3>
   static ARRAY_TYPE Slice(ARRAY_TYPE array, int from, int to, ARRAY_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Slice(from, to); }
   
   static void Sort(IIntArray* array, string order) { if (array == NULL) { return; } array.Sort(order == "ascending"); }
   static void Sort(IFloatArray* array, string order) { if (array == NULL) { return; } array.Sort(order == "ascending"); }
   
   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Unshift(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Unshift(value); }
   
   template <typename DUMMY_TYPE, typename ARRAY_TYPE>
   static int Size(ARRAY_TYPE array, int defaultValue) { if (array == NULL) { return INT_MIN;} return array.Size(); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Shift(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Shift(); }

   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Push(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Push(value); }
  
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Pop(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Pop(); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE, typename dummy>
   static VALUE_TYPE Get(ARRAY_TYPE array, int index, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Get(index); }
   
   template <typename ARRAY_TYPE, typename DUMMY_TYPE, typename VALUE_TYPE>
   static void Set(ARRAY_TYPE array, int index, VALUE_TYPE value) { if (array == NULL) { return; } array.Set(index, value); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Remove(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Remove(index); }

   template <typename ARRAY_TYPE, typename DUMMY_TYPE>
   static ARRAY_TYPE Copy(ARRAY_TYPE array, ARRAY_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Copy(); }

   template<typename TYPE>
   static double PercentRank(ISimpleTypeArray<TYPE>* array, int index, TYPE emptyValue)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return emptyValue; }
      int target = array.Get(index);
      if (target == emptyValue)
      {
         return emptyValue;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         int current = array.Get(i);
         if (current != emptyValue && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }
   static double PercentRank(ISimpleTypeArray<int>* array, int index) { return PercentRank<int>(array, index, INT_MIN); }
   static double PercentRank(ISimpleTypeArray<double>* array, int index) { return PercentRank<double>(array, index, EMPTY_VALUE); }
   
   template<typename TYPE>
   static TYPE Max(ISimpleTypeArray<TYPE>* array, int nth, TYPE emptyValue)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return emptyValue;
      }
      TYPE maxVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         TYPE val = array.Get(i);
         if (maxVal < val)
         {
            maxVal = val;
         }
      }
      return maxVal;
   }
   static double Max(ISimpleTypeArray<double>* array, int nth) { return Max<double>(array, nth, EMPTY_VALUE); }
   static int Max(ISimpleTypeArray<int>* array, int nth) { return Max<int>(array, nth, INT_MIN); }
   
   template<typename TYPE>
   static TYPE Min(ISimpleTypeArray<TYPE>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return EMPTY_VALUE;
      }
      TYPE minVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         TYPE val = array.Get(i);
         if (minVal > val)
         {
            minVal = val;
         }
      }
      return minVal;
   }
   static double Min(ISimpleTypeArray<double>* array, int nth) { return Min<double>(array, nth); }
   static int Min(ISimpleTypeArray<int>* array, int nth) { return Min<int>(array, nth); }

   template<typename TYPE>
   static TYPE Sum(ISimpleTypeArray<TYPE>* array, TYPE emptyValue)
   {
      if (array == NULL || array.Size() == 0)
      {
         return emptyValue;
      }
      TYPE sum = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   static double Sum(ISimpleTypeArray<double>* array) { return Sum<double>(array, EMPTY_VALUE); }
   static int Sum(ISimpleTypeArray<int>* array) { return Sum<int>(array, INT_MIN); }
   
   template<typename TYPE>
   static double Avg(ISimpleTypeArray<TYPE>* array, TYPE emptyValue)
   {
      if (array == NULL || array.Size() == 0)
      {
         return emptyValue;
      }
      return Sum(array) / array.Size();
   }
   static double Avg(ISimpleTypeArray<double>* array) { return Avg<double>(array, EMPTY_VALUE); }
   static double Avg(ISimpleTypeArray<int>* array) { return Avg<int>(array, INT_MIN); }
   
   template<typename T1, typename T2>
   static double Covariance(ISimpleTypeArray<T1>* array1, ISimpleTypeArray<T2>* array2)
   {
      if (array1 == NULL || array2 == NULL || array1.Size() != array2.Size())
      {
         return 0;
      }
      double avg1 = Avg(array1);
      double avg2 = Avg(array2);
      double sum = 0;
      for (int i = 0; i < array1.Size(); ++i)
      {
         sum = sum + (array1.Get(i) - avg1) * (array2.Get(i) - avg2);
      }
      return sum / array1.Size();
   }
   static double Covariance(ISimpleTypeArray<int>* array1, ISimpleTypeArray<int>* array2) { return Covariance<int, int>(array1, array2); }
   static double Covariance(ISimpleTypeArray<double>* array1, ISimpleTypeArray<double>* array2) { return Covariance<double, double>(array1, array2); }
   static double Covariance(ISimpleTypeArray<int>* array1, ISimpleTypeArray<double>* array2) { return Covariance<int, double>(array1, array2); }
   static double Covariance(ISimpleTypeArray<double>* array1, ISimpleTypeArray<int>* array2) { return Covariance<double, int>(array1, array2); }
   
   template<typename TYPE>
   static double Stdev(ISimpleTypeArray<TYPE>* array, TYPE emptyValue)
   {
      if (array == NULL)
      {
         return emptyValue;
      }
      double sum = 0;
      double ssum = 0;
      int size = array.Size();
      for (int i = 0; i < size; i++)
      {
         sum += array.Get(i);
         ssum += MathPow(size, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
   static double Stdev(ISimpleTypeArray<int>* array) { return Stdev<int>(array, INT_MIN); }
   static double Stdev(ISimpleTypeArray<double>* array) { return Stdev<double>(array, EMPTY_VALUE); }
   
   template<typename TYPE>
   static double Variance(ISimpleTypeArray<TYPE>* array, bool biased, TYPE emptyValue)
   {
      if (array == NULL || !biased)
      {
         return emptyValue;
      }
      double avg = Avg(array);
      double sum = 0;
      int size = array.Size();
      for (int i = 0; i < size; i++)
      {
         sum += MathPow(array.Get(i) - avg, 2);
      }
      return sum / size;
   }
   static double Variance(ISimpleTypeArray<int>* array, bool biased) { return Variance<int>(array, biased, INT_MIN); }
   static double Variance(ISimpleTypeArray<double>* array, bool biased) { return Variance<double>(array, biased, EMPTY_VALUE); }
};


#ifndef PolylineArray_IMPL
#define PolylineArray_IMPL
// Polyline array v1.0

// Collection of polylines v1.0

#ifndef PolyLinesCollection_IMPL
#define PolyLinesCollection_IMPL

// PolyLine object v1.2
#ifndef POLYLINE_IMPL
#define POLYLINE_IMPL

#ifndef ChartPoint_IMPL
#define ChartPoint_IMPL

// Chart point object v2.1

class ChartPoint
{
   int _refs;
   int _index;
   double _price;
public:
   ChartPoint(int index, double price)
   {
      _refs = 1;
      _index = index;
      _price = price;
   }
   ~ChartPoint()
   {
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
   
   static double Getprice(ChartPoint* chartPoint)
   {
      if (chartPoint == NULL)
      {
         return EMPTY_VALUE;
      }
      return chartPoint.GetPrice();
   }
   
   static int Getindex(ChartPoint* chartPoint)
   {
      if (chartPoint == NULL)
      {
         return INT_MIN;
      }
      return chartPoint.GetIndex();
   }
   
   static ChartPoint* Create(int time, int index, double price)
   {
      if (time != INT_MIN)
      {
         return NULL;//not supported yet
      }
      return new ChartPoint(index, price);
   }
   
   static ChartPoint* FromIndex(int index, double price)
   {
      return new ChartPoint(index, price);
   }

   void CopyTo(ChartPoint* other)
   {
      other._index = _index;
      other._price = _price;
   }
   
   int GetIndex() { return _index; }
   double GetPrice() { return _price; }
private:
};

#endif

class Polyline
{
   string _id;
   int _refs;
   string _collectionId;
   int _window;
   uint _lineColor;
   uint _fillColor;
   int _lineWidth;
   bool _curved;
   bool _closed;
   bool _forceOverlay;
   string _xLoc;
   ICustomTypeArray<ChartPoint*>* _points;
public:
   Polyline(ICustomTypeArray<ChartPoint*>* points, string id, string collectionId, int window)
   {
      _xLoc = "bar_index";
      _refs = 1;
      _id = id;
      _window = window;
      _lineWidth = 1;
      _collectionId = collectionId;
      _points = points;
      if (_points != NULL)
      {
         _points.AddRef();
      }
   }
   ~Polyline()
   {
      if (_points != NULL)
      {
         _points.Release();
      }
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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
   
   void CopyTo(Polyline* line)
   {
      line._window = _window;
      line._points = _points;
      line._lineColor = _lineColor;
      line._fillColor = _fillColor;
      line._lineWidth = _lineWidth;
      line._curved = _curved;
      line._closed = _closed;
      line._forceOverlay = _forceOverlay;
      line._points = _points;
      if (line._points != NULL)
      {
         line._points.AddRef();
      }
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   void Redraw()
   {
      if (_points == NULL)
      {
         return;
      }
      int size = _points.Size();
      if (size == 0)
      {
         return;
      }
      int totalBars = iBars(_Symbol, _Period);
      
      ChartPoint* prev = _points.Get(0);
      for (int i = 1; i < size; ++i)
      {
         ChartPoint* point = _points.Get(i);
         int pointIndex = point.GetIndex();
         if (pointIndex == INT_MIN)
         {
            continue;
         }
         int prevIndex = prev.GetIndex();
         if (prevIndex == INT_MIN)
         {
            prev = point;
            continue;
         }
         datetime x1 = GetTime(prevIndex, totalBars);
         
         datetime x2 = GetTime(pointIndex, totalBars);
         string lineId = _id + IntegerToString(i);
         if (ObjectFind(0, lineId) == -1 && ObjectCreate(0, lineId, OBJ_TREND, 0, x1, prev.GetPrice(), x2, point.GetPrice()))
         {
            ObjectSetInteger(0, lineId, OBJPROP_COLOR, _lineColor);
            ObjectSetInteger(0, lineId, OBJPROP_WIDTH, _lineWidth);
         }
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 0, prev.GetPrice());
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 1, point.GetPrice());
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 0, x1);
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 1, x2);
         prev = point;
      }
      
   }
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _Period, 0) + MathAbs(pos) * PeriodSeconds(_Period) : iTime(_Symbol, _Period, pos);
   }
   
   Polyline* SetLineColor(uint clr)
   {
      _lineColor = clr;
      return &this;
   }
   Polyline* SetFillColor(uint clr)
   {
      _fillColor = clr;
      return &this;
   }
   Polyline* SetLineWidth(int width)
   {
      _lineWidth = width;
      return &this;
   }
   Polyline* SetCurved(bool val)
   {
      _curved = val;
      return &this;
   }
   Polyline* SetClosed(bool val)
   {
      _closed = val;
      return &this;
   }
   Polyline* SetForceOverlay(bool val)
   {
      _forceOverlay = val;
      return &this;
   }
   Polyline* SetXLoc(string val)
   {
      _xLoc = val;
      return &this;
   }
};
#endif




class PolyLinesCollection
{
   string _id;
   ICustomTypeArray<Polyline*>* _array;
   static PolyLinesCollection* _collections[];
   static PolyLinesCollection* _all;
   static int _max;
   static uint _nextId;
public:
   static Polyline* Get(Polyline* PolyLine, int index)
   {
      if (PolyLine == NULL)
      {
         return NULL;
      }
      PolyLinesCollection* collection = FindCollection(PolyLine.GetCollectionId());
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
            _all = new PolyLinesCollection("");
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

   static void Delete(Polyline* PolyLine)
   {
      if (PolyLine == NULL)
      {
         return;
      }
      if (!_all.DeleteItem(PolyLine))
      {
         return;
      }
      PolyLinesCollection* collection = FindCollection(PolyLine.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(PolyLine);
   }

   static Polyline* Create(string id, ICustomTypeArray<ChartPoint*>* points, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - 1);
      MqlDateTime date;
      TimeToStruct(dateId, date);
      uint currentId = _nextId;
      _nextId += 1;
      string polyLineId = id + "_" + IntegerToString(currentId);
      
      Polyline* polyLine = new Polyline(points, polyLineId, id, ChartWindowOnDropped());
      PolyLinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new PolyLinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(polyLine);
      _all.Add(polyLine);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
      }
      polyLine.Release();
      return polyLine;
   }

   static void SetMaxLines(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawPolyLines();
      }
   }
   
   static ICustomTypeArray<Polyline*>* GetArray()
   {
      return _all._array;
   }
private:
   PolyLinesCollection(string id)
   {
      _id = id;
      _array = new CustomTypeArray<Polyline*>(0, NULL);
   }

   ~PolyLinesCollection()
   {
      ClearItems();
   }
   
   string GetId()
   {
      return _id;
   }
   
   void ClearItems()
   {
      delete _array;
      _array = new CustomTypeArray<Polyline*>(0, NULL);
   }
   
   int Count()
   {
      return _array.Size();
   }

   Polyline* GetFirst()
   {
      return Array::First<Polyline*, ITArray<Polyline*>*>(_array, NULL);
   }

   Polyline* Get(int index)
   {
      int size = _array.Size();
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array.Get(index);
   }
   Polyline* GetByIndex(int index)
   {
      int size = _array.Size();
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array.Get(size - 1 - index);
   }
   
   int FindIndex(Polyline* polyline)
   {
      for (int i = 0; i < _array.Size(); ++i)
      {
         if (_array.Get(i) == polyline)
         {
            return i;
         }
      }
      return -1;
   }

   bool DeleteItem(Polyline* polyline)
   {
      int index = FindIndex(polyline);
      if (index == -1)
      {
         return false;
      }
      _array.Remove(index);
      return true;
   }
   
   void Add(Polyline* polyline)
   {
      _array.Push(polyline);
   }

   void RedrawPolyLines()
   {
      for (int i = 0; i < _array.Size(); ++i)
      {
         _array.Get(i).Redraw();
      }
   }
   
   static void AddCollection(PolyLinesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static PolyLinesCollection* FindCollection(string id)
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
PolyLinesCollection* PolyLinesCollection::_collections[];
PolyLinesCollection* PolyLinesCollection::_all;
int PolyLinesCollection::_max = 50;
uint PolyLinesCollection::_nextId = 0;
#endif

class PolylineArray : public CustomTypeArray<Polyline*>
{
public:
   PolylineArray(int size, Polyline* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Polyline* Clone(Polyline* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Polyline* clone = PolyLinesCollection::Create(item.GetId(), NULL, 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Polyline* item)
   {
      PolyLinesCollection::Delete(item);
   }
};

#endif
#ifndef LabelArray_IMPL
#define LabelArray_IMPL
// Label array v1.0

// Collection of labels v1.2

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.3

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   uint _color;
   uint _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   string _textAlign;
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
   void SetXY(int x, double y)
   {
      SetX(x);
      SetY(y);
   }
   static void SetXY(Label* label, int x, double y)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetXY(x, y);
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
      _text = text == NULL ? " " : text;
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
         ObjectSetString(0, _labelId, OBJPROP_FONT, _font);
         ObjectSetInteger(0, _labelId, OBJPROP_FONTSIZE, getFontSize());
         ObjectSetInteger(0, _labelId, OBJPROP_COLOR, _textColor);
         ObjectSetInteger(0, _labelId, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE, 1, y);
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
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string labelId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      Label* label = new Label(x, y, labelId, id, ChartWindowOnDropped(), globalLabel);
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
   LabelArray(int size, Label* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Label* Clone(Label* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Label* clone = LabelsCollection::Create(item.GetId() + index, item.GetX(), item.GetY(), 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Label* item)
   {
      LabelsCollection::Delete(item);
   }
};

#endif


#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v2.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL
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

   virtual bool GetValues(const int period, const int count, T &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, T &val[]) = 0;
};

#endif

class AFloatStream : public TIStream<double>
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
// Float stream v2.1

class FloatStream : public AFloatStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
   double _emptyValue;
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe, double emptyValue = EMPTY_VALUE)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _emptyValue = emptyValue;
   }

   void Init()
   {
      ArrayInitialize(_stream, _emptyValue);
   }

   virtual int Size()
   {
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == _emptyValue)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
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
// Pivot high stream v2.0



//AOnStream v3.0
class AStreamBase : public TIStream<double>
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
   }

   ~AStreamBase()
   {
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

//AOnStream v3.0
class AOnStream : public AStreamBase
{
protected:
   TIStream<double> *_source;
public:
   AOnStream(TIStream<double> *source)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
   {
      _source.Release();
   }
   
   virtual bool GetSeriesValue(const int period, double &val) = 0;

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};
// AStream v1.1

class AStream : public AStreamBase
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   AStream(string symbol, ENUM_TIMEFRAMES timeframe)
      :AStreamBase()
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   ~AStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
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

// Simple price stream v1.0
class SimplePriceStream : public AStream
{
   PriceType _price;
   double _pipSize;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PriceClose:
               val[i] = iClose(_symbol, _timeframe, period + i);
               break;
            case PriceOpen:
               val[i] = iOpen(_symbol, _timeframe, period + i);
               break;
            case PriceHigh:
               val[i] = iHigh(_symbol, _timeframe, period + i);
               break;
            case PriceLow:
               val[i] = iLow(_symbol, _timeframe, period + i);
               break;
            case PriceMedian:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i)) / 2.0;
               break;
            case PriceTypical:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i)) / 3.0;
               break;
            case PriceWeighted:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
               break;
            case PriceMedianBody:
               val[i] = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
               break;
            case PriceAverage:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
               break;
            case PriceTrendBiased:
               {
                  double close = iClose(_symbol, _timeframe, period);
                  if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                     val[i] = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
                  else
                     val[i] = (iLow(_symbol, _timeframe, period) + close) / 2.0;
               }
               break;
            case PriceVolume:
               val[i] = (double)iVolume(_symbol, _timeframe, period);
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
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
   
      
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], TIStream<double>* source, int leftBars, int rightBars)
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, source, leftBars, rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int leftBars, int rightBars)
   {
      double center[1];
      if (!source.GetValues(period - rightBars, 1, center))
      {
         return false;
      }
      double value[1];
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValues(period - i, 1, value))
         {
            return false;
         }
         if (center[0] < value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValues(period - ii - rightBars, 1, value))
         {
            return false;
         }
         if (center[0] < value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center[0];
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, _source, _leftBars, _rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
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
   
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], TIStream<double>* source, int leftBars, int rightBars)
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, source, leftBars, rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int leftBars, int rightBars)
   {
      double center[1];
      if (!source.GetValues(period - rightBars, 1, center))
      {
         return false;
      }
      double value[1];
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValues(period - i, 1, value))
         {
            return false;
         }
         if (center[0] > value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValues(period - ii - rightBars, 1, value))
         {
            return false;
         }
         if (center[0] > value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center[0];
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, _source, _leftBars, _rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
};
// Pine-script like safe operations
// v1.3

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
bool ParameterDefined(double p) { return p != EMPTY_VALUE; }
bool ParameterDefined(int p) { return p != INT_MIN; }
bool ParameterDefined(string p) { return p != NULL; }
template <typename T1, typename T2>
bool BothParametersDefined(T1 left, T2 right) { return ParameterDefined(left) && ParameterDefined(right); }

template <typename T1, typename T2>
double SafePlus(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return left + right;
}

template <typename T1, typename T2>
double SafeMinus(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return left - right;
}
int SafeMinus(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return left - right;
}

template <typename T1, typename T2>
double SafeDivide(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right) || right == 0) { return EMPTY_VALUE; }
   return left / right;
}

template <typename T1, typename T2>
double SafeMultiply(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return left * right;
}
int SafeMultiply(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return left * right;
}

template <typename T1, typename T2>
bool SafeGreater(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return false; }
   return left > right;
}

template <typename T1, typename T2>
bool SafeGE(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return false; }
   return left >= right;
}

template <typename T1, typename T2>
bool SafeLess(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return false; }
   return left < right;
}

template <typename T1, typename T2>
bool SafeLE(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return false; }
   return left <= right;
}

template <typename T>
double SafeMathExp(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathExp(value);
}

template <typename T1, typename T2>
double SafeMathMax(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return MathMax(left, right);
}
int SafeMathMax(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return MathMax(left, right);
}

template <typename T1, typename T2, typename T3>
double SafeMathMax(T1 param1, T2 param2, T3 param3)
{
   if (!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
   {
      return EMPTY_VALUE;
   }
   return MathMax(MathMax(param1, param2), param3);
}
int SafeMathMax(int param1, int param2, int param3)
{
   if (!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
   {
      return INT_MIN;
   }
   return MathMax(MathMax(param1, param2), param3);
}

template <typename T1, typename T2>
double SafeMathMin(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return MathMin(left, right);
}
int SafeMathMin(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return MathMin(left, right);
}

template <typename T1, typename T2, typename T3>
double SafeMathMin(T1 param1, T2 param2, T3 param3)
{
   if (!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
   {
      return EMPTY_VALUE;
   }
   return MathMin(MathMin(param1, param2), param3);
}
int SafeMathMin(int param1, int param2, int param3)
{
   if (!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
   {
      return INT_MIN;
   }
   return MathMin(MathMin(param1, param2), param3);
}

template <typename T1, typename T2>
double SafeMathPow(T1 value, T2 power)
{
   if (!BothParametersDefined(value, power)) { return EMPTY_VALUE; }
   return MathPow(value, power);
}

template <typename T>
double SafeMathAbs(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathAbs(value);
}

template <typename T>
double SafeMathRound(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathRound(value);
}

template <typename T>
double SafeMathRound(T value, int precision)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return NormalizeDouble(value, precision);
}

template <typename T>
double SafeMathSqrt(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathSqrt(value);
}

template <typename T>
int SafeSign(T value)
{
   if (!ParameterDefined(value)) { return INT_MIN; }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

template <typename T>
double SafeLog(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathLog(value);
}
template <typename T>
double SafeLog10(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathLog10(value);
}
template <typename T>
double SafeCos(T value) 
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathCos(value);
}
template <typename T>
double SafeArccos(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathArccos(value);
}
template <typename T>
double SafeSin(T value) 
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathSin(value);
}
template <typename T>
double SafeArcsin(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathArcsin(value);
}
template <typename T>
double SafeTan(T value) 
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathTan(value);
}
template <typename T>
double SafeArctan(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathArctan(value);
}
template <typename T>
double InvertSign(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return -value;
}
template <typename T>
int SafeMathCeil(T value)
{
   if (!ParameterDefined(value)) { return INT_MIN; }
   return (int)MathCeil(value);
}
double SafeMod(int val1, int val2)
{
   if (val1 == INT_MIN || val2 == INT_MIN)
   {
      return EMPTY_VALUE;
   }
   return val1 % val2;
}
// PolyLine object v1.2
#ifndef POLYLINE_IMPL
#define POLYLINE_IMPL



class Polyline
{
   string _id;
   int _refs;
   string _collectionId;
   int _window;
   uint _lineColor;
   uint _fillColor;
   int _lineWidth;
   bool _curved;
   bool _closed;
   bool _forceOverlay;
   string _xLoc;
   ICustomTypeArray<ChartPoint*>* _points;
public:
   Polyline(ICustomTypeArray<ChartPoint*>* points, string id, string collectionId, int window)
   {
      _xLoc = "bar_index";
      _refs = 1;
      _id = id;
      _window = window;
      _lineWidth = 1;
      _collectionId = collectionId;
      _points = points;
      if (_points != NULL)
      {
         _points.AddRef();
      }
   }
   ~Polyline()
   {
      if (_points != NULL)
      {
         _points.Release();
      }
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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
   
   void CopyTo(Polyline* line)
   {
      line._window = _window;
      line._points = _points;
      line._lineColor = _lineColor;
      line._fillColor = _fillColor;
      line._lineWidth = _lineWidth;
      line._curved = _curved;
      line._closed = _closed;
      line._forceOverlay = _forceOverlay;
      line._points = _points;
      if (line._points != NULL)
      {
         line._points.AddRef();
      }
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   void Redraw()
   {
      if (_points == NULL)
      {
         return;
      }
      int size = _points.Size();
      if (size == 0)
      {
         return;
      }
      int totalBars = iBars(_Symbol, _Period);
      
      ChartPoint* prev = _points.Get(0);
      for (int i = 1; i < size; ++i)
      {
         ChartPoint* point = _points.Get(i);
         int pointIndex = point.GetIndex();
         if (pointIndex == INT_MIN)
         {
            continue;
         }
         int prevIndex = prev.GetIndex();
         if (prevIndex == INT_MIN)
         {
            prev = point;
            continue;
         }
         datetime x1 = GetTime(prevIndex, totalBars);
         
         datetime x2 = GetTime(pointIndex, totalBars);
         string lineId = _id + IntegerToString(i);
         if (ObjectFind(0, lineId) == -1 && ObjectCreate(0, lineId, OBJ_TREND, 0, x1, prev.GetPrice(), x2, point.GetPrice()))
         {
            ObjectSetInteger(0, lineId, OBJPROP_COLOR, _lineColor);
            ObjectSetInteger(0, lineId, OBJPROP_WIDTH, _lineWidth);
         }
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 0, prev.GetPrice());
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 1, point.GetPrice());
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 0, x1);
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 1, x2);
         prev = point;
      }
      
   }
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _Period, 0) + MathAbs(pos) * PeriodSeconds(_Period) : iTime(_Symbol, _Period, pos);
   }
   
   Polyline* SetLineColor(uint clr)
   {
      _lineColor = clr;
      return &this;
   }
   Polyline* SetFillColor(uint clr)
   {
      _fillColor = clr;
      return &this;
   }
   Polyline* SetLineWidth(int width)
   {
      _lineWidth = width;
      return &this;
   }
   Polyline* SetCurved(bool val)
   {
      _curved = val;
      return &this;
   }
   Polyline* SetClosed(bool val)
   {
      _closed = val;
      return &this;
   }
   Polyline* SetForceOverlay(bool val)
   {
      _forceOverlay = val;
      return &this;
   }
   Polyline* SetXLoc(string val)
   {
      _xLoc = val;
      return &this;
   }
};
#endif


#ifndef ChartPointArray_IMPL
#define ChartPointArray_IMPL
// ChartPoint array v1.1



class ChartPointArray : public CustomTypeArray<ChartPoint*>
{
public:
   ChartPointArray(int size, ChartPoint* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual ChartPoint* Clone(ChartPoint* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      ChartPoint* clone = ChartPoint::Create(INT_MIN, item.GetIndex(), item.GetPrice());
      item.CopyTo(clone);
      return clone;
   }
};

#endif
// MathEx v1.0
#ifndef MathEx_IMPL
#define MathEx_IMPL

class MathEx
{
public:
   static double ToRadians(double degreess)
   {
      if (degreess == EMPTY_VALUE)
      {
         return EMPTY_VALUE;
      }
      return degreess * (3.14 / 180);
   }
};

#endif




#ifndef BoolStream_IMPL
#define BoolStream_IMPL

#ifndef TStream_IMPL
#define TStream_IMPL

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
// Templated stream v1.0

template <typename T>
class TStream : public TAStream<T>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   T _stream[];
   T _emptyValue;
public:
   TStream(const string symbol, const ENUM_TIMEFRAMES timeframe, T emptyValue)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _emptyValue = emptyValue;
   }

   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = _emptyValue;
      }
   }

   virtual int Size()
   {
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, T value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, T &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == _emptyValue)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, T &val[])
   {
      return GetValues(Size() - period - 1, count, val);
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
// Bool stream v3.0

class BoolStream : public TStream<int>
{
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int emptyValue = -1)
      : TStream<int>(symbol, timeframe, emptyValue)
   {
   }
};

#endif
#ifndef BarsSinceStreamV2_IMPL
#define BarsSinceStreamV2_IMPL




// Counts number of bars since last condition.
// v3.0

class BarsSinceStreamV2 : public TAStream<int>
{
   TIStream<int>* _condition;
   int _bars[];
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

   int Size()
   {
      return _condition.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   virtual bool GetValues(const int period, const int count, int &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         int value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   virtual bool GetValue(const int period, int &val)
   {
      int size = Size();
      if (period >= size)
      {
         return false;
      }
      int currentBufferSize = ArrayRange(_bars, 0);
      if (currentBufferSize != size) 
      {
         ArrayResize(_bars, size);
         for (int i = currentBufferSize; i < size; ++i)
         {
            _bars[i] = (int)EMPTY_VALUE;
         }
      }
      if (_bars[period] == (int)EMPTY_VALUE)
      {
         FillHistory(period);
      }
      val = _bars[period];
      return true;
   }
private:
   void FillHistory(int period)
   {
      int size = Size();
      for (int periodIndex = period; periodIndex > 0; --periodIndex)
      {
         int val[1];
         if (_condition.GetValues(periodIndex, 1, val) && val[0] == true)
         {
            _bars[periodIndex] = 0;
            for (int ii = periodIndex + 1; ii <= period; ++ii)
            {
               _bars[ii] = _bars[ii - 1] + 1;
            }
            return;
         }
      }
   }
};
#endif
input string param1 = "Wick"; // Pivot Style
input int param2 = 25; // Pivot Lookforward
input bool param3 = true; // Show Elliptical Zig-Zag
input bool param4 = true; // Show Ghost Elliptical Zig-Zag
input bool param5 = true; // Show Break
input int param6 = 10; // Max Zig-Zags
input string param7 = "Directional"; // Equipoint Style
input bool param8 = false; // Extend Lines
input color param9 = 0x66cf1b; // Up Color
input color param10 = 0x2d2dee; // Down Color
input color param11 = 0x66cf1b; // Ghost Up Color
input color param12 = 0x2d2dee; // Ghost Down Color
input color param13 = 0xEEEEEE; // Text Color
input int param14 = 25; // Pivot Lookforward
input int param15 = 25; // Pivot Lookforward
input int bars_limit = 1000; // Bars limit
class pivot
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   pivot(pivot* src)
   {
      _refs = 1;
      this.current = src.current;
      this.current_idx = src.current_idx;
      this.previous = src.previous;
      this.previous_idx = src.previous_idx;
   }
   pivot(double current = NULL, int current_idx = NULL, double previous = NULL, int previous_idx = NULL)
   {
      _refs = 1;
      this.current = current;
      this.current_idx = current_idx;
      this.previous = previous;
      this.previous_idx = previous_idx;
   }
   ~pivot()
   {
   }
   double current;
   static double Getcurrent(pivot* self) { return self == NULL ? NULL : self.current; }
   static void Setcurrent(pivot* self, double val) { if (self == NULL) return; self.Setcurrent(val); } 
   pivot* Setcurrent(double val) { this.current = val; return &this; }
   int current_idx;
   static int Getcurrent_idx(pivot* self) { return self == NULL ? NULL : self.current_idx; }
   static void Setcurrent_idx(pivot* self, int val) { if (self == NULL) return; self.Setcurrent_idx(val); } 
   pivot* Setcurrent_idx(int val) { this.current_idx = val; return &this; }
   double previous;
   static double Getprevious(pivot* self) { return self == NULL ? NULL : self.previous; }
   static void Setprevious(pivot* self, double val) { if (self == NULL) return; self.Setprevious(val); } 
   pivot* Setprevious(double val) { this.previous = val; return &this; }
   int previous_idx;
   static int Getprevious_idx(pivot* self) { return self == NULL ? NULL : self.previous_idx; }
   static void Setprevious_idx(pivot* self, int val) { if (self == NULL) return; self.Setprevious_idx(val); } 
   pivot* Setprevious_idx(int val) { this.previous_idx = val; return &this; }
};
string pivot_type;
int pivot_forward;
int show_elliptical_zig;
int show_ghosts;
int show_break;
int max_zig;
string equipoint_style;
int extend_line;
uint up_color;
uint down_color;
uint ghost_up_color;
uint ghost_down_color;
uint text_color;
ICustomTypeArray<Polyline*>* zig_zags;
ICustomTypeArray<Label*>* zig_zag_points;
ICustomTypeArray<Line*>* equipoints;
ICustomTypeArray<Label*>* break_labels;
ICustomTypeArray<Polyline*>* ghost_zig_zags;
ICustomTypeArray<Label*>* ghost_zig_zag_points;
ICustomTypeArray<Line*>* ghost_equipoints;
double ph_back[];
double ph_back_DEFAULT_VALUE;
double pl_back[];
double pl_back_DEFAULT_VALUE;
class pivothigh__custom_1Stream
{
   int forward;
   pivot* pivot_high;
   FloatStream* highestpivot1Source;
   double source[];
   double source_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   pivothigh__custom_1Stream(int forward, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.forward = forward;
      highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~pivothigh__custom_1Stream()
   {
      pivot_high.Release();
      highestpivot1Source.Release();
      pivot_high.Release();
   }
   int Init(int id)
   {
      pivot_high = new pivot(NULL, NULL, NULL, NULL);
      SetIndexBuffer(id++, source, INDICATOR_CALCULATIONS);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double __source, int __back, pivot* &__out1, int &__out2)
   {
      if (!_initialized)
      {
         highestpivot1Source.Init();
         source_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(source, source_DEFAULT_VALUE);
         _initialized = true;
      }
      SetStream(source, pos, __source, source_DEFAULT_VALUE);
      int back = __back;
      highestpivot1Source.SetValue(pos, source[pos]);
      double highestpivot1Value[1];
      if (!PivotHighStream::GetValues(pos, 1, highestpivot1Value, highestpivot1Source, back, forward)) { highestpivot1Value[0] = EMPTY_VALUE; }
      int ph = !((highestpivot1Value[0]) == EMPTY_VALUE);
      if (ph)
      {
         if (pos - forward < 0) { return false; }
         pivot_high = new pivot(source[pos - forward], pos - forward, pivot::Getcurrent(pivot_high), pivot::Getcurrent_idx(pivot_high));
      }
      __out1 = pivot_high;
      if (__out1 != NULL) __out1.AddRef();
      __out2 = ph;
      return true;
   }
};
pivothigh__custom_1Stream* pivothigh__custom_11;
class pivotlow__custom_1Stream
{
   int forward;
   pivot* pivot_low;
   FloatStream* lowestpivot1Source;
   double source[];
   double source_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   pivotlow__custom_1Stream(int forward, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.forward = forward;
      lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~pivotlow__custom_1Stream()
   {
      pivot_low.Release();
      lowestpivot1Source.Release();
      pivot_low.Release();
   }
   int Init(int id)
   {
      pivot_low = new pivot(NULL, NULL, NULL, NULL);
      SetIndexBuffer(id++, source, INDICATOR_CALCULATIONS);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double __source, int __back, pivot* &__out1, int &__out2)
   {
      if (!_initialized)
      {
         lowestpivot1Source.Init();
         source_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(source, source_DEFAULT_VALUE);
         _initialized = true;
      }
      SetStream(source, pos, __source, source_DEFAULT_VALUE);
      int back = __back;
      lowestpivot1Source.SetValue(pos, source[pos]);
      double lowestpivot1Value[1];
      if (!PivotLowStream::GetValues(pos, 1, lowestpivot1Value, lowestpivot1Source, back, forward)) { lowestpivot1Value[0] = EMPTY_VALUE; }
      int pl = !((lowestpivot1Value[0]) == EMPTY_VALUE);
      if (pl)
      {
         if (pos - forward < 0) { return false; }
         pivot_low = new pivot(source[pos - forward], pos - forward, pivot::Getcurrent(pivot_low), pivot::Getcurrent_idx(pivot_low));
      }
      __out1 = pivot_low;
      if (__out1 != NULL) __out1.AddRef();
      __out2 = pl;
      return true;
   }
};
pivotlow__custom_1Stream* pivotlow__custom_12;
double last_up_start[];
double last_up_start_DEFAULT_VALUE;
double last_up_end[];
double last_up_end_DEFAULT_VALUE;
double last_down_start[];
double last_down_start_DEFAULT_VALUE;
double last_down_end[];
double last_down_end_DEFAULT_VALUE;
double last_high[];
double last_high_DEFAULT_VALUE;
double last_low[];
double last_low_DEFAULT_VALUE;
double polarity[];
double polarity_DEFAULT_VALUE;
class dump_ghost_1Stream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   dump_ghost_1Stream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~dump_ghost_1Stream()
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
   bool GetValue(const int pos, const int oldPos, ICustomTypeArray<Polyline*>* __ghost_zig_zags, ICustomTypeArray<Label*>* __ghost_zig_zag_points, ICustomTypeArray<Line*>* __ghost_equipoints)
   {
      ICustomTypeArray<Polyline*>* ghost_zig_zags;
      ICustomTypeArray<Label*>* ghost_zig_zag_points;
      ICustomTypeArray<Line*>* ghost_equipoints;
      ghost_zig_zags = __ghost_zig_zags;
      ghost_zig_zag_points = __ghost_zig_zag_points;
      ghost_equipoints = __ghost_equipoints;
      if (SafeGreater(Array::Size<int, ICustomTypeArray<Polyline*>*>(ghost_zig_zags, INT_MIN), 0))
      {
         int for1_from = SafeMinus(Array::Size<int, ICustomTypeArray<Polyline*>*>(ghost_zig_zags, INT_MIN), 1);
         int for1_to = 0;
         bool for1_forward = for1_from <= for1_to;
         int for1_step = 1 * (for1_forward ? 1 : -1);
         if (for1_from == INT_MIN || for1_to == INT_MIN) { return false; }
         for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
         {
            PolyLinesCollection::Delete(Array::Pop<Polyline*, ICustomTypeArray<Polyline*>*>(ghost_zig_zags, NULL));
         }
      }
      if (SafeGreater(Array::Size<int, ICustomTypeArray<Label*>*>(ghost_zig_zag_points, INT_MIN), 0))
      {
         int for2_from = SafeMinus(Array::Size<int, ICustomTypeArray<Label*>*>(ghost_zig_zag_points, INT_MIN), 1);
         int for2_to = 0;
         bool for2_forward = for2_from <= for2_to;
         int for2_step = 1 * (for2_forward ? 1 : -1);
         if (for2_from == INT_MIN || for2_to == INT_MIN) { return false; }
         for (int i = for2_from; (for2_forward ? i <= for2_to : i >= for2_to); i += for2_step)
         {
            LabelsCollection::Delete(Array::Pop<Label*, ICustomTypeArray<Label*>*>(ghost_zig_zag_points, NULL));
         }
      }
      if (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(ghost_equipoints, INT_MIN), 0))
      {
         int for3_from = SafeMinus(Array::Size<int, ICustomTypeArray<Line*>*>(ghost_equipoints, INT_MIN), 1);
         int for3_to = 0;
         bool for3_forward = for3_from <= for3_to;
         int for3_step = 1 * (for3_forward ? 1 : -1);
         if (for3_from == INT_MIN || for3_to == INT_MIN) { return false; }
         for (int i = for3_from; (for3_forward ? i <= for3_to : i >= for3_to); i += for3_step)
         {
            LinesCollection::Delete(Array::Pop<Line*, ICustomTypeArray<Line*>*>(ghost_equipoints, NULL));
         }
      }
      return true;
   }
};
dump_ghost_1Stream* dump_ghost_13;
class generate_ellipse_1Stream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   generate_ellipse_1Stream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~generate_ellipse_1Stream()
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
   bool GetValue(const int pos, const int oldPos, int __start_x, int __end_x, double __start_y, double __end_y, ICustomTypeArray<ChartPoint*>* &__out1)
   {
      int start_x = __start_x;
      int end_x = __end_x;
      double start_y = __start_y;
      double end_y = __end_y;
      ICustomTypeArray<ChartPoint*>* __array8 = new ChartPointArray(0, NULL);
      ICustomTypeArray<ChartPoint*>* points = __array8;
      double a = SafeMinus(end_x, start_x);
      double b = SafeMinus(end_y, start_y);
      int x = INT_MIN;
      if (SafeGreater(a, 1))
      {
         int for4_from = 0;
         int for4_to = 90;
         bool for4_forward = for4_from <= for4_to;
         int for4_step = 1 * (for4_forward ? 1 : -1);
         if (for4_from == INT_MIN || for4_to == INT_MIN) { return false; }
         for (int i = for4_from; (for4_forward ? i <= for4_to : i >= for4_to); i += for4_step)
         {
            int new_x = (int)(SafeMultiply(a, SafeCos(MathEx::ToRadians(i))));
            double y = SafeMultiply(b, SafeSin(MathEx::ToRadians(i)));
            if ((x != new_x))
            {
               Array::Push<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(points, ChartPoint::Create(INT_MIN, SafePlus(start_x, x), SafePlus(start_y, y)));
            }
            x = new_x;
         }
         Array::Push<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(points, ChartPoint::Create(INT_MIN, start_x, end_y));
      }
      else
      {
         Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(points, ChartPoint::Create(INT_MIN, end_x, start_y));
         Array::Push<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(points, ChartPoint::Create(INT_MIN, start_x, end_y));
      }
      __out1 = points;
      if (__out1 != NULL) __out1.AddRef();
      __array8.Release();
      return true;
   }
};
class ellipse_slope_1Stream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   ellipse_slope_1Stream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~ellipse_slope_1Stream()
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
   bool GetValue(const int pos, const int oldPos, int __start_x, int __end_x, double __start_y, double __end_y, ICustomTypeArray<ChartPoint*>* __ellipse_points, ChartPoint* &__out1_1, double &__out1_2)
   {
      int start_x = __start_x;
      int end_x = __end_x;
      double start_y = __start_y;
      double end_y = __end_y;
      ICustomTypeArray<ChartPoint*>* ellipse_points = __ellipse_points;
      if (SafeGreater(Array::Size<int, ICustomTypeArray<ChartPoint*>*>(ellipse_points, INT_MIN), 2))
      {
         ISimpleTypeArray<double>* __array9 = new FloatArray(0, EMPTY_VALUE);
         ISimpleTypeArray<double>* dy = __array9;
         ISimpleTypeArray<double>* __array10 = new FloatArray(0, EMPTY_VALUE);
         ISimpleTypeArray<double>* centers = __array10;
         ITArray<int>* __array11 = new IntArray(0, INT_MIN);
         ITArray<int>* idx = __array11;
         int for5_from = 0;
         int for5_to = SafeMinus(Array::Size<int, ICustomTypeArray<ChartPoint*>*>(ellipse_points, INT_MIN), 2);
         bool for5_forward = for5_from <= for5_to;
         int for5_step = 1 * (for5_forward ? 1 : -1);
         if (for5_from == INT_MIN || for5_to == INT_MIN) { return false; }
         for (int i = for5_from; (for5_forward ? i <= for5_to : i >= for5_to); i += for5_step)
         {
            double delta = MathAbs(ChartPoint::Getprice(Array::Get<ChartPoint*, ICustomTypeArray<ChartPoint*>*, int>(ellipse_points, i + 1, NULL)) - ChartPoint::Getprice(Array::Get<ChartPoint*, ICustomTypeArray<ChartPoint*>*, int>(ellipse_points, i, NULL)));
            Array::Push<ISimpleTypeArray<double>*, double>(dy, delta);
         }
         int for6_from = 1;
         int for6_to = SafeMinus(Array::Size<int, ISimpleTypeArray<double>*>(dy, INT_MIN), 1);
         bool for6_forward = for6_from <= for6_to;
         int for6_step = 1 * (for6_forward ? 1 : -1);
         if (for6_from == INT_MIN || for6_to == INT_MIN) { return false; }
         for (int i = for6_from; (for6_forward ? i <= for6_to : i >= for6_to); i += for6_step)
         {
            Array::Push<ITArray<int>*, int>(idx, i);
            double left = Array::Sum(Array::Slice<ISimpleTypeArray<double>*, ISimpleTypeArray<double>*, int, int>(Array::Copy<ISimpleTypeArray<double>*, ISimpleTypeArray<double>*>(dy, NULL), 0, i + 1, NULL));
            double right = Array::Sum(Array::Slice<ISimpleTypeArray<double>*, ISimpleTypeArray<double>*, int, int>(Array::Copy<ISimpleTypeArray<double>*, ISimpleTypeArray<double>*>(dy, NULL), i - 1, Array::Size<int, ISimpleTypeArray<double>*>(dy, INT_MIN), NULL));
            Array::Push<ISimpleTypeArray<double>*, double>(centers, SafeMathAbs(SafeMinus(left, right)));
         }
         int mid = Array::Get<int, ITArray<int>*, int>(idx, Array::IndexOf(centers, Array::Min(centers, 0)), INT_MIN);
         ChartPoint* tangent = Array::Get<ChartPoint*, ICustomTypeArray<ChartPoint*>*, int>(ellipse_points, mid, NULL);
         double a = SafeMinus(end_x, start_x);
         double b = SafeMinus(end_y, start_y);
         double x = SafeMinus(ChartPoint::Getindex(tangent), start_x);
         double y = ChartPoint::Getprice(tangent) - start_y;
         double slope = SafeDivide(InvertSign((SafeMultiply(SafeMathPow(b, 2), x))), (SafeMultiply(SafeMathPow(a, 2), y)));
         __out1_1 = tangent;
         __out1_2 = slope;
         __array11.Release();
         __array10.Release();
         __array9.Release();
      }
      else
      {
         __out1_1 = Array::First<ChartPoint*, ICustomTypeArray<ChartPoint*>*>(ellipse_points, NULL);
         __out1_2 = (-(ChartPoint::Getprice(Array::Last<ChartPoint*, ICustomTypeArray<ChartPoint*>*>(ellipse_points, NULL)) - ChartPoint::Getprice(Array::First<ChartPoint*, ICustomTypeArray<ChartPoint*>*>(ellipse_points, NULL))));
      }
      if (__out1_1 != NULL) __out1_1.AddRef();
      return true;
   }
};
class check_b_1Stream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   check_b_1Stream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~check_b_1Stream()
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
   bool GetValue(const int pos, const int oldPos, int __start_x, double __start_y, int __forward_length, double __slope, int __polarity, int &__out1_1, double &__out1_2, int &__out1_3)
   {
      int start_x = __start_x;
      double start_y = __start_y;
      int forward_length = __forward_length;
      double slope = __slope;
      int polarity = __polarity;
      int i = SafeMinus(forward_length, 1);
      int found = false;
      int start_idx = SafeMinus(pos, start_x);
      int current_idx = start_idx;
      double end_price = EMPTY_VALUE;
      while (!found && SafeGE(current_idx, 0))
      {
         i = SafePlus(i, 1);
         double check_price = SafePlus(start_y, SafeMultiply(slope, i));
         current_idx = SafeMinus(start_idx, i);
         if (SafeLess(current_idx, 0))
         {
         }
         if (polarity)
         {
            end_price = iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + current_idx);
            if (SafeLess(end_price, check_price))
            {
               found = true;
            }
         }
         else
         {
            end_price = iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + current_idx);
            if (SafeGreater(end_price, check_price))
            {
               found = true;
            }
         }
      }
      if (found)
      {
         __out1_1 = found;
         __out1_2 = end_price;
         __out1_3 = SafeMinus(pos, current_idx);
      }
      else
      {
         __out1_1 = found;
         __out1_2 = (double)(EMPTY_VALUE);
         __out1_3 = (int)(INT_MIN);
      }
      return true;
   }
};
class generate_zig_zag_1Stream
{
   int show_elliptical_zig;
   string equipoint_style;
   int show_break;
   int extend_line;
   uint up_color;
   uint down_color;
   uint text_color;
   int polarity;
   int ghost;
   generate_ellipse_1Stream* generate_ellipse_14;
   ellipse_slope_1Stream* ellipse_slope_15;
   check_b_1Stream* check_b_16;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   generate_zig_zag_1Stream(int show_elliptical_zig, string equipoint_style, int show_break, int extend_line, uint up_color, uint down_color, uint text_color, int polarity, int ghost, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.show_elliptical_zig = show_elliptical_zig;
      this.equipoint_style = equipoint_style;
      this.show_break = show_break;
      this.extend_line = extend_line;
      this.up_color = up_color;
      this.down_color = down_color;
      this.text_color = text_color;
      this.polarity = polarity;
      this.ghost = ghost;
   }
   ~generate_zig_zag_1Stream()
   {
      delete generate_ellipse_14;
      delete ellipse_slope_15;
      delete check_b_16;
   }
   int Init(int id)
   {
      generate_ellipse_14 = new generate_ellipse_1Stream(IndicatorObjPrefix + "_4");
      id = generate_ellipse_14.Init(id);
      ellipse_slope_15 = new ellipse_slope_1Stream(IndicatorObjPrefix + "_5");
      id = ellipse_slope_15.Init(id);
      check_b_16 = new check_b_1Stream(IndicatorObjPrefix + "_6");
      id = check_b_16.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, int __start_x, int __end_x, double __start_y, double __end_y, ICustomTypeArray<Label*>* __zig_zag_points, ICustomTypeArray<Polyline*>* __zig_zags, ICustomTypeArray<Line*>* __equipoints, ICustomTypeArray<Label*>* __break_labels)
   {
      if (!_initialized)
      {
         generate_ellipse_14.Clear();
         ellipse_slope_15.Clear();
         check_b_16.Clear();
         _initialized = true;
      }
      ICustomTypeArray<Label*>* zig_zag_points;
      ICustomTypeArray<Polyline*>* zig_zags;
      ICustomTypeArray<Line*>* equipoints;
      ICustomTypeArray<Label*>* break_labels;
      int start_x = __start_x;
      int end_x = __end_x;
      double start_y = __start_y;
      double end_y = __end_y;
      zig_zag_points = __zig_zag_points;
      zig_zags = __zig_zags;
      equipoints = __equipoints;
      break_labels = __break_labels;
      uint bullish_color = (polarity ? up_color : down_color);
      uint bearish_color = (polarity ? down_color : up_color);
      ICustomTypeArray<ChartPoint*>* generate_ellipse_14Value;
      if (!generate_ellipse_14.GetValue(pos, oldPos, start_x, end_x, start_y, end_y, generate_ellipse_14Value)) { generate_ellipse_14Value = NULL; }
      ICustomTypeArray<ChartPoint*>* ellipse_points = generate_ellipse_14Value;
      ChartPoint* ellipse_slope_15Value1;
      double ellipse_slope_15Value2;
      if (!ellipse_slope_15.GetValue(pos, oldPos, start_x, end_x, start_y, end_y, ellipse_points, ellipse_slope_15Value1, ellipse_slope_15Value2)) { ellipse_slope_15Value1 = NULL; ellipse_slope_15Value2 = EMPTY_VALUE; }
      ChartPoint* tangent = ellipse_slope_15Value1;
      double slope = ellipse_slope_15Value2;
      int length = SafeMinus(end_x, start_x);
      int back_length = SafeMinus(ChartPoint::Getindex(tangent), start_x);
      int forward_length = SafeMinus(length, back_length);
      if (show_elliptical_zig)
      {
         ChartPoint* label1_point = Array::Last<ChartPoint*, ICustomTypeArray<ChartPoint*>*>(ellipse_points, NULL);
         Array::Push<ICustomTypeArray<Label*>*, Label*>(zig_zag_points, LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", label1_point.GetIndex(), label1_point.GetPrice(), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetColor(bullish_color).SetText(NULL).SetStyle("circle").SetSize("auto").SetYLoc("price").SetTextAlign("center"));
         Array::Push<ICustomTypeArray<Polyline*>*, Polyline*>(zig_zags, PolyLinesCollection::Create(IndicatorObjPrefix + "polyline_1_id", ellipse_points, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetLineColor(bullish_color).SetLineWidth(2).SetCurved(false).SetClosed(false).SetForceOverlay(false).SetXLoc("bar_index"));
      }
      if ((equipoint_style == "Directional"))
      {
         if (extend_line)
         {
            Array::Push<ICustomTypeArray<Line*>*, Line*>(equipoints, LinesCollection::Create(IndicatorObjPrefix + "line_1_id", ChartPoint::Getindex(tangent), ChartPoint::Getprice(tangent), ChartPoint::Getindex(tangent) + 1, SafePlus(ChartPoint::Getprice(tangent), slope), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetColor(bullish_color).SetWidth(1).SetStyle("dashed").SetExtend("both").SetXLoc("bar_index"));
         }
         else
         {
            Array::Push<ICustomTypeArray<Line*>*, Line*>(equipoints, LinesCollection::Create(IndicatorObjPrefix + "line_2_id", SafeMinus(ChartPoint::Getindex(tangent), back_length), SafeMinus(ChartPoint::Getprice(tangent), SafeMultiply(slope, back_length)), SafePlus(ChartPoint::Getindex(tangent), back_length), SafePlus(ChartPoint::Getprice(tangent), SafeMultiply(slope, back_length)), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetColor(bullish_color).SetWidth(1).SetStyle("dashed").SetExtend("none").SetXLoc("bar_index"));
         }
      }
      if ((equipoint_style == "Horizontal"))
      {
         if (extend_line)
         {
            Array::Push<ICustomTypeArray<Line*>*, Line*>(equipoints, LinesCollection::Create(IndicatorObjPrefix + "line_3_id", ChartPoint::Getindex(tangent), ChartPoint::Getprice(tangent), ChartPoint::Getindex(tangent) + 1, ChartPoint::Getprice(tangent), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetColor(bullish_color).SetWidth(1).SetStyle("dashed").SetExtend("right").SetXLoc("bar_index"));
         }
         else
         {
            Array::Push<ICustomTypeArray<Line*>*, Line*>(equipoints, LinesCollection::Create(IndicatorObjPrefix + "line_4_id", ChartPoint::Getindex(tangent), ChartPoint::Getprice(tangent), SafePlus(ChartPoint::Getindex(tangent), SafeMultiply(length, 2)), ChartPoint::Getprice(tangent), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetColor(bullish_color).SetWidth(1).SetStyle("dashed").SetExtend("none").SetXLoc("bar_index"));
         }
      }
      if (show_break && !ghost)
      {
         int check_b_16Value1;
         double check_b_16Value2;
         int check_b_16Value3;
         if (!check_b_16.GetValue(pos, oldPos, ChartPoint::Getindex(tangent), ChartPoint::Getprice(tangent), forward_length, slope, polarity, check_b_16Value1, check_b_16Value2, check_b_16Value3)) { check_b_16Value1 = (-1); check_b_16Value2 = EMPTY_VALUE; check_b_16Value3 = INT_MIN; }
         int found = check_b_16Value1;
         double found_price = check_b_16Value2;
         int found_idx = check_b_16Value3;
         if (found)
         {
            Array::Push<ICustomTypeArray<Label*>*, Label*>(break_labels, LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", found_idx, found_price, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetColor((polarity ? down_color : up_color)).SetText("B").SetTextColor(text_color).SetStyle((polarity ? "down" : "up")).SetSize("normal").SetYLoc((polarity ? "abovebar" : "belowbar")).SetTextAlign("center"));
         }
         else
         {
            Array::Push<ICustomTypeArray<Label*>*, Label*>(break_labels, LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", INT_MIN, EMPTY_VALUE, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetText(NULL).SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center"));
         }
      }
      if (ellipse_slope_15Value1 != NULL) ellipse_slope_15Value1.Release();
      if (generate_ellipse_14Value != NULL) generate_ellipse_14Value.Release();
      return true;
   }
};
generate_zig_zag_1Stream* generate_zig_zag_17;
dump_ghost_1Stream* dump_ghost_18;
generate_zig_zag_1Stream* generate_zig_zag_19;
BoolStream* barssince1Condition;
BarsSinceStreamV2* barssince1;
double high_source[];
double high_source_DEFAULT_VALUE;
dump_ghost_1Stream* dump_ghost_110;
generate_zig_zag_1Stream* generate_zig_zag_111;
BoolStream* barssince2Condition;
BarsSinceStreamV2* barssince2;
double low_source[];
double low_source_DEFAULT_VALUE;
dump_ghost_1Stream* dump_ghost_112;
generate_zig_zag_1Stream* generate_zig_zag_113;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
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

void OnInit()
{
   pivot_type = param1;
   pivot_forward = param2;
   show_elliptical_zig = param3;
   show_ghosts = param4;
   show_break = param5;
   max_zig = param6;
   equipoint_style = param7;
   extend_line = param8;
   up_color = param9;
   down_color = param10;
   ghost_up_color = param11;
   ghost_down_color = param12;
   text_color = param13;
   int id = 0;
   barssince1Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince1 = new BarsSinceStreamV2(barssince1Condition);
   barssince2Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince2 = new BarsSinceStreamV2(barssince2Condition);
   LabelsCollection::SetMaxLabels(500);
   PolyLinesCollection::SetMaxLines(100);
   LinesCollection::SetMaxLines(100);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "Ghost Tangent Crossings [ChartPrime]");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, ph_back, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, pl_back, INDICATOR_CALCULATIONS);
   pivothigh__custom_11 = new pivothigh__custom_1Stream(pivot_forward, IndicatorObjPrefix + "_1");
   id = pivothigh__custom_11.Init(id);
   pivotlow__custom_12 = new pivotlow__custom_1Stream(pivot_forward, IndicatorObjPrefix + "_2");
   id = pivotlow__custom_12.Init(id);
   SetIndexBuffer(id++, last_up_start, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_up_end, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_down_start, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_down_end, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_high, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_low, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, polarity, INDICATOR_CALCULATIONS);
   dump_ghost_13 = new dump_ghost_1Stream(IndicatorObjPrefix + "_3");
   id = dump_ghost_13.Init(id);
   generate_zig_zag_17 = new generate_zig_zag_1Stream(show_elliptical_zig, equipoint_style, show_break, extend_line, up_color, down_color, text_color, true, false, IndicatorObjPrefix + "_7");
   id = generate_zig_zag_17.Init(id);
   dump_ghost_18 = new dump_ghost_1Stream(IndicatorObjPrefix + "_8");
   id = dump_ghost_18.Init(id);
   generate_zig_zag_19 = new generate_zig_zag_1Stream(show_elliptical_zig, equipoint_style, show_break, extend_line, up_color, down_color, text_color, false, false, IndicatorObjPrefix + "_9");
   id = generate_zig_zag_19.Init(id);
   SetIndexBuffer(id++, high_source, INDICATOR_CALCULATIONS);
   dump_ghost_110 = new dump_ghost_1Stream(IndicatorObjPrefix + "_10");
   id = dump_ghost_110.Init(id);
   generate_zig_zag_111 = new generate_zig_zag_1Stream(show_elliptical_zig, equipoint_style, show_break, extend_line, ghost_up_color, ghost_down_color, text_color, true, true, IndicatorObjPrefix + "_11");
   id = generate_zig_zag_111.Init(id);
   SetIndexBuffer(id++, low_source, INDICATOR_CALCULATIONS);
   dump_ghost_112 = new dump_ghost_1Stream(IndicatorObjPrefix + "_12");
   id = dump_ghost_112.Init(id);
   generate_zig_zag_113 = new generate_zig_zag_1Stream(show_elliptical_zig, equipoint_style, show_break, extend_line, ghost_up_color, ghost_down_color, text_color, false, true, IndicatorObjPrefix + "_13");
   id = generate_zig_zag_113.Init(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   if (zig_zags != NULL) zig_zags.Release();
   if (zig_zag_points != NULL) zig_zag_points.Release();
   if (equipoints != NULL) equipoints.Release();
   if (break_labels != NULL) break_labels.Release();
   if (ghost_zig_zags != NULL) ghost_zig_zags.Release();
   if (ghost_zig_zag_points != NULL) ghost_zig_zag_points.Release();
   if (ghost_equipoints != NULL) ghost_equipoints.Release();
   delete pivothigh__custom_11;
   delete pivotlow__custom_12;
   delete dump_ghost_13;
   delete generate_zig_zag_17;
   delete dump_ghost_18;
   delete generate_zig_zag_19;
   barssince1Condition.Release();
   barssince1.Release();
   delete dump_ghost_110;
   delete generate_zig_zag_111;
   barssince2Condition.Release();
   barssince2.Release();
   delete dump_ghost_112;
   delete generate_zig_zag_113;
   LabelsCollection::Clear(true);
   PolyLinesCollection::Clear(true);
   LinesCollection::Clear(true);
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
      LabelsCollection::Clear();
      PolyLinesCollection::Clear();
      LinesCollection::Clear();
      ICustomTypeArray<Polyline*>* __array1 = new PolylineArray(0, NULL);
      if (zig_zags != NULL) zig_zags.Release();
      zig_zags = __array1;
      zig_zags.AddRef();
      ICustomTypeArray<Label*>* __array2 = new LabelArray(0, NULL);
      if (zig_zag_points != NULL) zig_zag_points.Release();
      zig_zag_points = __array2;
      zig_zag_points.AddRef();
      ICustomTypeArray<Line*>* __array3 = new LineArray(0, NULL);
      if (equipoints != NULL) equipoints.Release();
      equipoints = __array3;
      equipoints.AddRef();
      ICustomTypeArray<Label*>* __array4 = new LabelArray(0, NULL);
      if (break_labels != NULL) break_labels.Release();
      break_labels = __array4;
      break_labels.AddRef();
      ICustomTypeArray<Polyline*>* __array5 = new PolylineArray(0, NULL);
      if (ghost_zig_zags != NULL) ghost_zig_zags.Release();
      ghost_zig_zags = __array5;
      ghost_zig_zags.AddRef();
      ICustomTypeArray<Label*>* __array6 = new LabelArray(0, NULL);
      if (ghost_zig_zag_points != NULL) ghost_zig_zag_points.Release();
      ghost_zig_zag_points = __array6;
      ghost_zig_zag_points.AddRef();
      ICustomTypeArray<Line*>* __array7 = new LineArray(0, NULL);
      if (ghost_equipoints != NULL) ghost_equipoints.Release();
      ghost_equipoints = __array7;
      ghost_equipoints.AddRef();
      ph_back_DEFAULT_VALUE = param14;
      ArrayInitialize(ph_back, ph_back_DEFAULT_VALUE);
      pl_back_DEFAULT_VALUE = param15;
      ArrayInitialize(pl_back, pl_back_DEFAULT_VALUE);
      pivothigh__custom_11.Clear();
      pivotlow__custom_12.Clear();
      last_up_start_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(last_up_start, last_up_start_DEFAULT_VALUE);
      last_up_end_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(last_up_end, last_up_end_DEFAULT_VALUE);
      last_down_start_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(last_down_start, last_down_start_DEFAULT_VALUE);
      last_down_end_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(last_down_end, last_down_end_DEFAULT_VALUE);
      last_high_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_high, last_high_DEFAULT_VALUE);
      last_low_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_low, last_low_DEFAULT_VALUE);
      polarity_DEFAULT_VALUE = (-1);
      ArrayInitialize(polarity, polarity_DEFAULT_VALUE);
      dump_ghost_13.Clear();
      generate_zig_zag_17.Clear();
      dump_ghost_18.Clear();
      generate_zig_zag_19.Clear();
      barssince1Condition.Init();
      high_source_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(high_source, high_source_DEFAULT_VALUE);
      dump_ghost_110.Clear();
      generate_zig_zag_111.Clear();
      barssince2Condition.Init();
      low_source_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(low_source, low_source_DEFAULT_VALUE);
      dump_ghost_112.Clear();
      generate_zig_zag_113.Clear();
      __array7.Release();
      __array6.Release();
      __array5.Release();
      __array4.Release();
      __array3.Release();
      __array2.Release();
      __array1.Release();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      ph_back[pos] = pos > 0 ? ph_back[pos - 1] : pivot_forward;
      pl_back[pos] = pos > 0 ? pl_back[pos - 1] : pivot_forward;
      last_up_start[pos] = pos > 0 ? last_up_start[pos - 1] : INT_MIN;
      last_up_end[pos] = pos > 0 ? last_up_end[pos - 1] : INT_MIN;
      last_down_start[pos] = pos > 0 ? last_down_start[pos - 1] : INT_MIN;
      last_down_end[pos] = pos > 0 ? last_down_end[pos - 1] : INT_MIN;
      last_high[pos] = pos > 0 ? last_high[pos - 1] : EMPTY_VALUE;
      last_low[pos] = pos > 0 ? last_low[pos - 1] : EMPTY_VALUE;
      polarity[pos] = pos > 0 ? polarity[pos - 1] : (-1);
      string settings = "Settings";
      string visual = "Visuals";
      SetStream(high_source, pos, ((pivot_type == "Wick") ? high[pos] : MathMax(open[pos], close[pos])), high_source_DEFAULT_VALUE);
      SetStream(low_source, pos, ((pivot_type == "Wick") ? low[pos] : MathMin(open[pos], close[pos])), low_source_DEFAULT_VALUE);
      pivot* pivothigh__custom_11Value1;
      int pivothigh__custom_11Value2;
      if (!pivothigh__custom_11.GetValue(pos, oldPos, high_source[pos], ph_back[pos], pivothigh__custom_11Value1, pivothigh__custom_11Value2)) { pivothigh__custom_11Value1 = NULL; pivothigh__custom_11Value2 = (-1); }
      pivot* ph = pivothigh__custom_11Value1;
      int new_ph = pivothigh__custom_11Value2;
      pivot* pivotlow__custom_12Value1;
      int pivotlow__custom_12Value2;
      if (!pivotlow__custom_12.GetValue(pos, oldPos, low_source[pos], pl_back[pos], pivotlow__custom_12Value1, pivotlow__custom_12Value2)) { pivotlow__custom_12Value1 = NULL; pivotlow__custom_12Value2 = (-1); }
      pivot* pl = pivotlow__custom_12Value1;
      int new_pl = pivotlow__custom_12Value2;
      int polarity_up = (pivot::Getcurrent_idx(ph) > pivot::Getcurrent_idx(pl));
      int polarity_down = (pivot::Getcurrent_idx(ph) < pivot::Getcurrent_idx(pl));
      int up_wait = !polarity[pos];
      int down_wait = polarity[pos];
      if (new_ph && polarity_up && ((SafeLess(last_up_start[pos], pivot::Getcurrent_idx(pl)) || ((last_up_start[pos]) == INT_MIN))) && up_wait && (pos < rates_total - 1))
      {
         if (!dump_ghost_13.GetValue(pos, oldPos, ghost_zig_zags, ghost_zig_zag_points, ghost_equipoints)) { }
         int connect = (!((last_down_end[pos]) == INT_MIN) ? (pivot::Getcurrent_idx(pl) == last_down_end[pos]) : true);
         int start_x = (connect ? pivot::Getcurrent_idx(pl) : last_down_end[pos]);
         int end_x = pivot::Getcurrent_idx(ph);
         double start_y = pivot::Getcurrent(ph);
         double end_y = (connect ? pivot::Getcurrent(pl) : last_low[pos]);
         SetStream(last_up_start, pos, start_x, last_up_start_DEFAULT_VALUE);
         SetStream(last_up_end, pos, end_x, last_up_end_DEFAULT_VALUE);
         SetStream(last_high, pos, start_y, last_high_DEFAULT_VALUE);
         SetStream(polarity, pos, true, polarity_DEFAULT_VALUE);
         if (!generate_zig_zag_17.GetValue(pos, oldPos, start_x, end_x, start_y, end_y, zig_zag_points, zig_zags, equipoints, break_labels)) { }
      }
      if (new_pl && polarity_down && ((SafeLess(last_down_start[pos], pivot::Getcurrent_idx(ph)) || ((last_down_start[pos]) == INT_MIN))) && down_wait && (pos < rates_total - 1))
      {
         if (!dump_ghost_18.GetValue(pos, oldPos, ghost_zig_zags, ghost_zig_zag_points, ghost_equipoints)) { }
         int connect = (!((last_up_end[pos]) == INT_MIN) ? (pivot::Getcurrent_idx(ph) == last_up_end[pos]) : true);
         int start_x = (connect ? pivot::Getcurrent_idx(ph) : last_up_end[pos]);
         int end_x = pivot::Getcurrent_idx(pl);
         double start_y = pivot::Getcurrent(pl);
         double end_y = (connect ? pivot::Getcurrent(ph) : last_high[pos]);
         SetStream(last_down_start, pos, start_x, last_down_start_DEFAULT_VALUE);
         SetStream(last_down_end, pos, end_x, last_down_end_DEFAULT_VALUE);
         SetStream(last_low, pos, start_y, last_low_DEFAULT_VALUE);
         SetStream(polarity, pos, false, polarity_DEFAULT_VALUE);
         if (!generate_zig_zag_19.GetValue(pos, oldPos, start_x, end_x, start_y, end_y, zig_zag_points, zig_zags, equipoints, break_labels)) { }
      }
      int ghost_up_connect = (!((last_down_end[pos]) == INT_MIN) ? (pivot::Getcurrent_idx(pl) == last_down_end[pos]) : true);
      int ghost_up_start_x = (ghost_up_connect ? pivot::Getcurrent_idx(pl) : last_down_end[pos]);
      barssince1Condition.SetValue(pos, new_pl);
      int barssince1Value[1];
      if (!barssince1.GetValues(pos, 1, barssince1Value)) { barssince1Value[0] = INT_MIN; }
      int since_pl = barssince1Value[0];
      int ghost_up_range = SafeMinus(pos, ghost_up_start_x);
      ISimpleTypeArray<double>* __array12 = new FloatArray(0, EMPTY_VALUE);
      ISimpleTypeArray<double>* ghost_max = __array12;
      if (SafeGE(ghost_up_range, 0))
      {
         int for7_from = 0;
         int for7_to = SafeMinus(ghost_up_range, since_pl);
         bool for7_forward = for7_from <= for7_to;
         int for7_step = 1 * (for7_forward ? 1 : -1);
         if (for7_from == INT_MIN || for7_to == INT_MIN) { continue; }
         for (int i = for7_from; (for7_forward ? i <= for7_to : i >= for7_to); i += for7_step)
         {
            if (pos - i < 0) { continue; }
            Array::Push<ISimpleTypeArray<double>*, double>(ghost_max, high_source[pos - i]);
         }
      }
      double ghost_up_start_y = Array::Max(ghost_max, 0);
      double ghost_up_end_y = (ghost_up_connect ? pivot::Getcurrent(pl) : last_low[pos]);
      int ghost_up_since = (SafeGreater(Array::Size<int, ISimpleTypeArray<double>*>(ghost_max, INT_MIN), 0) ? Array::IndexOf(ghost_max, ghost_up_start_y) : 0);
      int ghost_up_end_x = SafeMinus(pos, ghost_up_since);
      if (up_wait && !new_ph && show_ghosts)
      {
         if (!dump_ghost_110.GetValue(pos, oldPos, ghost_zig_zags, ghost_zig_zag_points, ghost_equipoints)) { }
         if (!generate_zig_zag_111.GetValue(pos, oldPos, ghost_up_start_x, ghost_up_end_x, ghost_up_start_y, ghost_up_end_y, ghost_zig_zag_points, ghost_zig_zags, ghost_equipoints, break_labels)) { }
      }
      int ghost_down_connect = (!((last_up_end[pos]) == INT_MIN) ? (pivot::Getcurrent_idx(ph) == last_up_end[pos]) : true);
      int ghost_down_start_x = (ghost_down_connect ? pivot::Getcurrent_idx(ph) : last_up_end[pos]);
      barssince2Condition.SetValue(pos, new_ph);
      int barssince2Value[1];
      if (!barssince2.GetValues(pos, 1, barssince2Value)) { barssince2Value[0] = INT_MIN; }
      int since_ph = barssince2Value[0];
      int ghost_down_range = SafeMinus(pos, ghost_down_start_x);
      ISimpleTypeArray<double>* __array13 = new FloatArray(0, EMPTY_VALUE);
      ISimpleTypeArray<double>* ghost_min = __array13;
      if (SafeGE(ghost_down_range, 0))
      {
         int for8_from = 0;
         int for8_to = SafeMinus(ghost_down_range, since_ph);
         bool for8_forward = for8_from <= for8_to;
         int for8_step = 1 * (for8_forward ? 1 : -1);
         if (for8_from == INT_MIN || for8_to == INT_MIN) { continue; }
         for (int i = for8_from; (for8_forward ? i <= for8_to : i >= for8_to); i += for8_step)
         {
            if (pos - i < 0) { continue; }
            Array::Push<ISimpleTypeArray<double>*, double>(ghost_min, low_source[pos - i]);
         }
      }
      double ghost_down_start_y = Array::Min(ghost_min, 0);
      double ghost_down_end_y = (ghost_down_connect ? pivot::Getcurrent(ph) : last_high[pos]);
      int ghost_down_since = (SafeGreater(Array::Size<int, ISimpleTypeArray<double>*>(ghost_min, INT_MIN), 0) ? Array::IndexOf(ghost_min, ghost_down_start_y) : 0);
      int ghost_down_end_x = SafeMinus(pos, ghost_down_since);
      if (down_wait && !new_pl && show_ghosts)
      {
         if (!dump_ghost_112.GetValue(pos, oldPos, ghost_zig_zags, ghost_zig_zag_points, ghost_equipoints)) { }
         if (!generate_zig_zag_113.GetValue(pos, oldPos, ghost_down_start_x, ghost_down_end_x, ghost_down_start_y, ghost_down_end_y, ghost_zig_zag_points, ghost_zig_zags, ghost_equipoints, break_labels)) { }
      }
      if (SafeGreater(Array::Size<int, ICustomTypeArray<Polyline*>*>(zig_zags, INT_MIN), max_zig))
      {
         PolyLinesCollection::Delete(Array::Shift<Polyline*, ICustomTypeArray<Polyline*>*>(zig_zags, NULL));
         LabelsCollection::Delete(Array::Shift<Label*, ICustomTypeArray<Label*>*>(zig_zag_points, NULL));
      }
      if (SafeGreater(Array::Size<int, ICustomTypeArray<Line*>*>(equipoints, INT_MIN), max_zig))
      {
         LinesCollection::Delete(Array::Shift<Line*, ICustomTypeArray<Line*>*>(equipoints, NULL));
      }
      if (SafeGreater(Array::Size<int, ICustomTypeArray<Label*>*>(break_labels, INT_MIN), max_zig))
      {
         LabelsCollection::Delete(Array::Shift<Label*, ICustomTypeArray<Label*>*>(break_labels, NULL));
      }
      SetStream(ph_back, pos, SafeMathMin(SafeMathMax(Nz(SafePlus(SafeMinus(SafeMinus(pos, last_down_end[pos]), pl_back[pos]), 1), 5), 0), 500), ph_back_DEFAULT_VALUE);
      SetStream(pl_back, pos, SafeMathMin(SafeMathMax(Nz(SafePlus(SafeMinus(SafeMinus(pos, last_up_end[pos]), ph_back[pos]), 1), 5), 0), 500), pl_back_DEFAULT_VALUE);
      __array13.Release();
      __array12.Release();
      if (pivotlow__custom_12Value1 != NULL) pivotlow__custom_12Value1.Release();
      if (pivothigh__custom_11Value1 != NULL) pivothigh__custom_11Value1.Release();
   }
   LabelsCollection::Redraw();
   PolyLinesCollection::Redraw();
   LinesCollection::Redraw();
   return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76385&p=160960#p160960
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