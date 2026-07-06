//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75910

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

// Array v1.4
// Array interface v1.0

// Box array interface v1.1
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

   string _text;
   string _textHAlign;
   string _textVAlign;
   string _textSize;
   color _textColor;

   int _refs;
public:
   Box(int left, double top, int right, double bottom, string id, string collectionId, int window)
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
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _bgcolor);
         ObjectSetInteger(0, _id, OBJPROP_BGCOLOR, _bgcolor);
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
// Line array interface v1.1
// Line object v1.6

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

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
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

   static Line* SetColor(Line* line, color clr) { if (line == NULL) { return NULL; } return line.SetColor(clr); }
   Line* SetColor(color clr)
   {
      _clr = clr;
      return &this;
   }

   static Line* SetStyle(Line* line, string style) { if (line == NULL) { return NULL; } return line.SetStyle(style); }
   Line* SetStyle(string style)
   {
      _style = style;
      return &this;
   }

   static Line* SetWidth(Line* line, int width) { if (line == NULL) { return NULL; } return line.SetWidth(width); }
   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }

   void Redraw()
   {
      int totalBars = iBars(_Symbol, _timeframe);
      datetime x1 = GetTime(_x1, totalBars);
      datetime x2 = GetTime(_x2, totalBars);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 0, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 1, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 0, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 1, x2);
   }
private:
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _timeframe, 0) + MathAbs(pos) * PeriodSeconds(_timeframe) : iTime(_Symbol, _timeframe, pos);
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
   virtual void Sort(bool ascending) = 0;
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
// Line array v1.4

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

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId)
   {
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
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, ChartWindowOnDropped());
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

class LineArraySlice : public ILineArray
{
   ILineArray* array;
   int from;
   int to;
public:
   LineArraySlice(ILineArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(Line* value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(Line* value)
   {
      //do nothing
   }
   virtual Line* Pop()
   {
      return NULL;
   }
   virtual Line* Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, Line* value)
   {
      //do nothing
   }
   virtual ILineArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual ILineArray* Clear()
   {
      return NULL;
   }
   virtual Line* Shift()
   {
      return NULL;
   }
   virtual Line* Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class LineArray : public ILineArray
{
   Line* _array[];
   int _defaultSize;
   Line* _defaultValue;
   LineArraySlice* slices[];
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
      size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
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
      int size = ArraySize(slices);
      for (int i = 0; i < size; ++i)
      {
         if (slices[i].GetFrom() == from && slices[i].GetTo() == to)
         {
            return slices[i];
         }
      }
      ArrayResize(slices, size + 1);
      slices[size] = new LineArraySlice(&this, from, to);
      return slices[size];
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
// Int array v1.5


class IntArraySlice : public IIntArray
{
   IIntArray* array;
   int from;
   int to;
public:
   IntArraySlice(IIntArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(int value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(int value)
   {
      //do nothing
   }
   virtual int Pop()
   {
      return NULL;
   }
   virtual int Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, int value)
   {
      //do nothing
   }
   virtual IIntArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual IIntArray* Clear()
   {
      return NULL;
   }
   virtual int Shift()
   {
      return NULL;
   }
   virtual int Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class IntArray : public IIntArray
{
   int _array[];
   int _defaultSize;
   int _defaultValue;
   IntArraySlice* slices[];
public:
   IntArray(int size, int defaultValue)
   {
      _defaultSize = size;
      _defaultValue = defaultValue;
      Clear();
   }
   ~IntArray()
   {
      Clear();
   }

   IIntArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      int size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
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

   int Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return INT_MIN;
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

   int Shift()
   {
      return Remove(0);
   }
   
   IIntArray* Slice(int from, int to)
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
      slices[size] = new IntArraySlice(&this, from, to);
      return slices[size];
   }
   
   void Sort(bool ascending)
   {
      ArraySort(_array);
      if (!ascending)
      {
         ArrayReverse(_array);
      }
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
// Float array v1.4


class FloatArraySlice : public IFloatArray
{
   IFloatArray* array;
   int from;
   int to;
public:
   FloatArraySlice(IFloatArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(double value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(double value)
   {
      //do nothing
   }
   virtual double Pop()
   {
      return NULL;
   }
   virtual double Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, double value)
   {
      //do nothing
   }
   virtual IFloatArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual IFloatArray* Clear()
   {
      return NULL;
   }
   virtual double Shift()
   {
      return NULL;
   }
   virtual double Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class FloatArray : public IFloatArray
{
   double _array[];
   int _defaultSize;
   double _defaultValue;
   FloatArraySlice* slices[];
public:
   FloatArray(int size, double defaultValue)
   {
      _defaultSize = size;
      _defaultValue = defaultValue;
      Clear();
   }
   ~FloatArray()
   {
      Clear();
   }

   IFloatArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      int size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
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
      int size = ArraySize(slices);
      for (int i = 0; i < size; ++i)
      {
         if (slices[i].GetFrom() == from && slices[i].GetTo() == to)
         {
            return slices[i];
         }
      }
      ArrayResize(slices, size + 1);
      slices[size] = new FloatArraySlice(&this, from, to);
      return slices[size];
   }
   
   void Sort(bool ascending)
   {
      ArraySort(_array);
      if (!ascending)
      {
         ArrayReverse(_array);
      }
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

   static Box* Create(string id, int left, double top, int right, double bottom, datetime dateId)
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
      Box* box = new Box(left, top, right, bottom, boxId, id, ChartWindowOnDropped());
      BoxesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new BoxesCollection(id);
         AddCollection(collection);
      }
      collection.Add(box);
      _all.Add(box);
      box.Release();
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
// Line array v1.4

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

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId)
   {
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
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, ChartWindowOnDropped());
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

class LineArraySlice : public ILineArray
{
   ILineArray* array;
   int from;
   int to;
public:
   LineArraySlice(ILineArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(Line* value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(Line* value)
   {
      //do nothing
   }
   virtual Line* Pop()
   {
      return NULL;
   }
   virtual Line* Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, Line* value)
   {
      //do nothing
   }
   virtual ILineArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual ILineArray* Clear()
   {
      return NULL;
   }
   virtual Line* Shift()
   {
      return NULL;
   }
   virtual Line* Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class LineArray : public ILineArray
{
   Line* _array[];
   int _defaultSize;
   Line* _defaultValue;
   LineArraySlice* slices[];
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
      size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
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
      int size = ArraySize(slices);
      for (int i = 0; i < size; ++i)
      {
         if (slices[i].GetFrom() == from && slices[i].GetTo() == to)
         {
            return slices[i];
         }
      }
      ArrayResize(slices, size + 1);
      slices[size] = new LineArraySlice(&this, from, to);
      return slices[size];
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
#ifndef CustomTypeArray_IMPL
#define CustomTypeArray_IMPL
// Template for array interface v1.0

template <typename CLASS_TYPE>
interface ITArray
{
public:
   virtual void AddRef() = 0;
   virtual int Release() = 0;
   virtual void Unshift(CLASS_TYPE value) = 0;
   virtual int Size() = 0;
   virtual void Push(CLASS_TYPE value) = 0;
   virtual CLASS_TYPE Pop() = 0;
   virtual CLASS_TYPE Get(int index) = 0;
   virtual void Set(int index, CLASS_TYPE value) = 0;
   virtual CLASS_TYPE Shift() = 0;
   virtual CLASS_TYPE Remove(int index) = 0;
   virtual int Includes(CLASS_TYPE value) = 0;
   virtual CLASS_TYPE First() = 0;
   virtual CLASS_TYPE Last() = 0;
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
   CLASS_TYPE _array[];
   int _defaultSize;
   CLASS_TYPE _defaultValue;
   int _refs;
public:
   CustomTypeArray(int size, CLASS_TYPE defaultValue)
   {
      _refs = 1;
      _defaultSize = size;
      Clear();
   }

   ~CustomTypeArray()
   {
      Clear();
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
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
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
   virtual void DeleteItem(CLASS_TYPE item)
   {
   }
};
#endif

class Array
{
public:
   template <typename ARRAY_TYPE>
   static void Clear(ARRAY_TYPE array) { if (array == NULL) { return; } array.Clear(); }
   
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE First(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.First(); }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Last(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Last(); }
   
   static IIntArray* Slice(IIntArray* array, int from, int to) { if (array == NULL) { return NULL; } return array.Slice(from, to); }
   static IFloatArray* Slice(IFloatArray* array, int from, int to) { if (array == NULL) { return NULL; } return array.Slice(from, to); }
   static ILineArray* Slice(ILineArray* array, int from, int to) { if (array == NULL) { return NULL; } return array.Slice(from, to); }
   static IBoxArray* Slice(IBoxArray* array, int from, int to) { if (array == NULL) { return NULL; } return array.Slice(from, to); }
   
   static void Sort(IIntArray* array, string order) { if (array == NULL) { return; } array.Sort(order == "ascending"); }
   static void Sort(IFloatArray* array, string order) { if (array == NULL) { return; } array.Sort(order == "ascending"); }
   
   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Unshift(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Unshift(value); }
   
   template <typename DUMMY_TYPE, typename ARRAY_TYPE>
   static int Size(ARRAY_TYPE array, int defaultValue) { if (array == NULL) { return INT_MIN;} return array.Size(); }

   static int Shift(IIntArray* array) { if (array == NULL) { return INT_MIN; } return array.Shift(); }
   static double Shift(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static Line* Shift(ILineArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static Box* Shift(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }

   static void Push(IIntArray* array, int value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IFloatArray* array, double value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Push(value); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Pop(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Pop(); }

   static int Get(IIntArray* array, int index) { if (array == NULL) { return INT_MIN; } return array.Get(index); }
   static double Get(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static Line* Get(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   static Box* Get(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
   
   static void Set(IIntArray* array, int index, int value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IFloatArray* array, int index, double value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(ILineArray* array, int index, Line* value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IBoxArray* array, int index, Box* value) { if (array == NULL) { return; } array.Set(index, value); }

   static int Remove(IIntArray* array, int index) { if (array == NULL) { return INT_MIN; } return array.Remove(index); }
   static double Remove(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static Line* Remove(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }
   static Box* Remove(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }

   static double PercentRank(IIntArray* array, int index)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return INT_MIN; }
      int target = array.Get(index);
      if (target == INT_MIN)
      {
         return INT_MIN;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         int current = array.Get(i);
         if (current != INT_MIN && target >= current)
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
      if (array == NULL || array.Size() == 0) { return INT_MIN; }
      int max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (max == INT_MIN || (current != INT_MIN && max < current))
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
      if (array == NULL || array.Size() == 0) { return INT_MIN; }
      int min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (min == INT_MIN || (current != INT_MIN && min > current))
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
   
   static double Avg(IIntArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      return Sum(array) / array.Size();
   }
   static double Avg(IFloatArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      return Sum(array) / array.Size();
   }
   
   static double Covariance(IIntArray* array1, IIntArray* array2)
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
   static double Covariance(IFloatArray* array1, IFloatArray* array2)
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
   static double Covariance(IIntArray* array1, IFloatArray* array2)
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
   static double Covariance(IFloatArray* array1, IIntArray* array2)
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
   
   static double Stdev(IIntArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
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
   static double Stdev(IFloatArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
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
   
   static double Variance(IIntArray* array, bool biased)
   {
      if (array == NULL || !biased)
      {
         return EMPTY_VALUE;
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
   static double Variance(IFloatArray* array, bool biased)
   {
      if (array == NULL || !biased)
      {
         return EMPTY_VALUE;
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
};


// Pine-script like safe operations
// v1.2

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
      return INT_MIN;
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

double SafeMathMax(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(MathMax(param1, param2), param3);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathMin(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(MathMin(param1, param2), param3);
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
      return INT_MIN;
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
// AStream v1.1
// IStream v.2.0
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

//AOnStream v2.0
class AStreamBase : public IStream
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

//True range stream v1.1

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      if ((_handleNa && period + count > size) || (!_handleNa && period + count + 1 > size))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         if ((period + i + 1 == size) && _handleNa)
         {
            double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
            double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));
            double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));

            val[i] = MathMax(lc, MathMax(hl, hc));
            continue;
         }
         double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
         double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));
         double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));

         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
   }
};


//AOnStream v2.0
class AOnStream : public AStreamBase
{
protected:
   IStream *_source;
public:
   AOnStream(IStream *source)
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
//SMAOnStream v4.0

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double summ = 0;
      for (int i = 0; i < _length; ++i)
      {
         double price[1];
         if (!_source.GetSeriesValues(period + i, 1, price))
            return false;
         summ += price[0];
      }
      val = summ / _length;
      return true;
   }
};

// Average true range stream v3.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(int length)
      :AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
   {
      IStream* tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      IStream* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ~ATRStream()
   {
      _avg.Release();
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      return _avg.GetValues(period, count, val);
   }
   
   bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int oldPos = Size() - period - 1;
      return GetValues(oldPos, count, val);
   }

};
#endif
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

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
// Float stream v2.0

class FloatStream : public AFloatStream
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
         if (val[i] == EMPTY_VALUE)
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
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif


// Cumulative on stream v1.2

#ifndef CumOnStream_IMP
#define CumOnStream_IMP

class CumOnStream : public AOnStream
{
   double _buffer[];
public:
   CumOnStream(IStream *source)
      :AOnStream(source)
   {
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      int bufferIndex = totalBars - 1 - period;
      double current[1];
      if (!_source.GetValues(bufferIndex, 1, current))
         return false;
      
      if (bufferIndex > 0 && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + current[0];
      }
      else 
      {
         _buffer[bufferIndex] = current[0];
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
// Pivot high stream v1.0



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
   
      
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], IStream* source, int leftBars, int rightBars)
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

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
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
// Pivot low stream v1.0





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
   
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], IStream* source, int leftBars, int rightBars)
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

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
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

// Label array stream v1.0

#ifndef LabelArrayStream_IMPL
#define LabelArrayStream_IMPL

#ifndef TStream_IMPL
#define TStream_IMPL

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

   virtual bool GetValues(const int period, const int count, T &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, T &val[]) = 0;
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

// Label v1.3

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
   string _textAlign;
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
      _textAlign = "";
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
   
   Label* SetColor(color clr)
   {
      _color = clr;
      return &this;
   }
   
   static void SetTextColor(Label* label, color clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextColor(clr);
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

class LabelArrayStream : public TStream<ICustomTypeArray<Label*>*>
{
public:
   LabelArrayStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      : TStream<ICustomTypeArray<Label*>*>(symbol, timeframe, NULL)
   {
   }
};
#endif
// Label stream v1.0

#ifndef LabelStream_IMPL
#define LabelStream_IMPL




class LabelStream : public TStream<Label*>
{
public:
   LabelStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      : TStream<Label*>(symbol, timeframe, NULL)
   {
   }
};
#endif
// Collection of labels v1.2

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL



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

   static Label* Create(string id, int x, double y, datetime dateId)
   {
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
      Label* label = new Label(x, y, labelId, id, ChartWindowOnDropped());
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
enum param1_enum
{
   param1_value_1, // Bullish OR Bearish
   param1_value_2, // Bullish AND Bearish
   param1_value_3, // Bearish
   param1_value_4 // Bullish
};
input param1_enum param1_e = param1_value_2; // Display
string Get_param1()
{
   switch (param1_e)
   {
      case param1_value_1: return "Bullish OR Bearish";
      case param1_value_2: return "Bullish AND Bearish";
      case param1_value_3: return "Bearish";
      case param1_value_4: return "Bullish";
   }
   return NULL;
}
input double param2 = 1; // Width
input int param3 = 500; // Maximum Bars
enum param4_enum
{
   param4_value_1, // All
   param4_value_2 // Last
};
input param4_enum param4_e = param4_value_1; // Display Test/Retest Labels
string Get_param4()
{
   switch (param4_e)
   {
      case param4_value_1: return "All";
      case param4_value_2: return "Last";
   }
   return NULL;
}
input int param5 = 0; // Minimum Bars
input bool param6 = true; // Set Back To Last Retest
input int param7 = 10; // Left
input int param8 = 1; // Right
input color param9 = 0x819908; // Bullish?
input color param10 = 0x4536f2; // 
input color param11 = 0x4536f2; // Bearish
input color param12 = 0x819908; // 
enum param13_enum
{
   param13_value_1, // "tiny"
   param13_value_2, // "small"
   param13_value_3, // "normal"
   param13_value_4 // "large"
};
input param13_enum param13_e = param13_value_2; // Label Size
string Get_param13()
{
   switch (param13_e)
   {
      case param13_value_1: return "tiny";
      case param13_value_2: return "small";
      case param13_value_3: return "normal";
      case param13_value_4: return "large";
   }
   return NULL;
}
input int bars_limit = 1000; // Bars limit
string display;
double mult;
int maxBars;
string showReTest;
int minBars;
int setBack;
int left;
int right;
uint bull1_color;
uint bull2_color;
uint bear1_color;
uint bear2_color;
string labSize;
class bin
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   bin(bin* src)
   {
      _refs = 1;
      if (this.bx != NULL) this.bx.Release();
      this.bx = src.bx;
      if (this.bx != NULL) this.bx.AddRef();
      this.state = src.state;
      this.price = src.price;
      if (this.lab1 != NULL) this.lab1.Release();
      this.lab1 = src.lab1;
      if (this.lab1 != NULL) this.lab1.AddRef();
      if (this.lab2 != NULL) this.lab2.Release();
      this.lab2 = src.lab2;
      if (this.lab2 != NULL) this.lab2.AddRef();
   }
   bin(Box* bx = NULL, int state = INT_MIN, double price = EMPTY_VALUE, ICustomTypeArray<Label*>* lab1 = NULL, ICustomTypeArray<Label*>* lab2 = NULL)
   {
      _refs = 1;
      if (this.bx != NULL) this.bx.Release();
      this.bx = bx;
      if (this.bx != NULL) this.bx.AddRef();
      this.state = state;
      this.price = price;
      if (this.lab1 != NULL) this.lab1.Release();
      this.lab1 = lab1;
      if (this.lab1 != NULL) this.lab1.AddRef();
      if (this.lab2 != NULL) this.lab2.Release();
      this.lab2 = lab2;
      if (this.lab2 != NULL) this.lab2.AddRef();
   }
   ~bin()
   {
      if (this.bx != NULL) this.bx.Release();
      if (this.lab1 != NULL) this.lab1.Release();
      if (this.lab2 != NULL) this.lab2.Release();
   }
   Box* bx;
   static Box* Getbx(bin* self) { return self == NULL ? NULL : self.bx; }
   static void Setbx(bin* self, Box* val) { if (self == NULL) return; if (self.bx != NULL) self.bx.Release(); self.bx = val; if (self.bx != NULL) self.bx.AddRef(); }
   int state;
   static int Getstate(bin* self) { return self == NULL ? INT_MIN : self.state; }
   static void Setstate(bin* self, int val) { if (self == NULL) return; self.state = val; }
   double price;
   static double Getprice(bin* self) { return self == NULL ? EMPTY_VALUE : self.price; }
   static void Setprice(bin* self, double val) { if (self == NULL) return; self.price = val; }
   ICustomTypeArray<Label*>* lab1;
   static ICustomTypeArray<Label*>* Getlab1(bin* self) { return self == NULL ? NULL : self.lab1; }
   static void Setlab1(bin* self, ICustomTypeArray<Label*>* val) { if (self == NULL) return; if (self.lab1 != NULL) self.lab1.Release(); self.lab1 = val; if (self.lab1 != NULL) self.lab1.AddRef(); }
   ICustomTypeArray<Label*>* lab2;
   static ICustomTypeArray<Label*>* Getlab2(bin* self) { return self == NULL ? NULL : self.lab2; }
   static void Setlab2(bin* self, ICustomTypeArray<Label*>* val) { if (self == NULL) return; if (self.lab2 != NULL) self.lab2.Release(); self.lab2 = val; if (self.lab2 != NULL) self.lab2.AddRef(); }
};
int n;
ICustomTypeArray<Label*>* __array1;
ICustomTypeArray<Label*>* __array2;
bin* bull;
ICustomTypeArray<Label*>* __array3;
ICustomTypeArray<Label*>* __array4;
bin* bear;
ATRStream* atr1;
FloatStream* cum1X;
CumOnStream* cum1;
class mayAdd_lbaSStream
{
   TStream<ICustomTypeArray<Label*>*>* aLab;
   bool _initialized;
public:
   mayAdd_lbaSStream(TStream<ICustomTypeArray<Label*>*>* aLab)
   {
      _initialized = false;
      this.aLab = aLab;
      aLab.AddRef();
   }
   ~mayAdd_lbaSStream()
   {
      aLab.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, int &__out1)
   {
      ICustomTypeArray<Label*>* aLabValue[1];
      if (!aLab.GetValues(pos, 1, aLabValue)) { aLabValue[0] = NULL; }
      __out1 = (((Array::Size<int, ICustomTypeArray<Label*>*>(aLabValue[0], INT_MIN) == 0) || (showReTest == "Last")) ? true : (showReTest == "All") && SafeGreater(SafeMinus(n, Label::GetX(Array::First<Label*, ICustomTypeArray<Label*>*>(aLabValue[0], NULL))), minBars));
      return true;
   }
};
LabelArrayStream* mayAdd_lbaS1_param1;
mayAdd_lbaSStream* mayAdd_lbaS1;
class addLabel_lbaS_lbSStream
{
   TStream<ICustomTypeArray<Label*>*>* aLab;
   TIStream<Label*>* lab;
   bool _initialized;
public:
   addLabel_lbaS_lbSStream(TStream<ICustomTypeArray<Label*>*>* aLab, TIStream<Label*>* lab)
   {
      _initialized = false;
      this.aLab = aLab;
      aLab.AddRef();
      this.lab = lab;
      lab.AddRef();
   }
   ~addLabel_lbaS_lbSStream()
   {
      aLab.Release();
      lab.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, Label* &__out1)
   {
      ICustomTypeArray<Label*>* aLabValue[1];
      if (!aLab.GetValues(pos, 1, aLabValue)) { aLabValue[0] = NULL; }
      Label* labValue[1];
      if (!lab.GetValues(pos, 1, labValue)) { labValue[0] = NULL; }
      Array::Unshift<ICustomTypeArray<Label*>*, Label*>(aLabValue[0], labValue[0]);
      if ((showReTest == "Last") && SafeGreater(Array::Size<int, ICustomTypeArray<Label*>*>(aLabValue[0], INT_MIN), 1))
      {
         __out1 = Array::Pop<Label*, ICustomTypeArray<Label*>*>(aLabValue[0], NULL);
      }
      return true;
   }
};
class label__custom_s_i_fStream
{
   string dir;
   int state;
   double y;
   bool _initialized;
public:
   label__custom_s_i_fStream(string dir, int state, double y)
   {
      _initialized = false;
      this.dir = dir;
      this.state = state;
      this.y = y;
   }
   ~label__custom_s_i_fStream()
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
   bool GetValue(const int pos, const int oldPos, Label* &__out1)
   {
      Label* lab = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", n, y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetColor((uint)(INT_MAX)).SetText("").SetStyle("down").SetSize(labSize).SetYLoc("price").SetTextAlign("center");
      if ((dir == "bull"))
      {
         if ((state == 1))
         {
            Label::SetStyle(lab, "up");
         }
         else if ((state == 2))
         {
            Label::SetStyle(lab, "down");
         }
;
      }
      else if ((dir == "bear"))
      {
         if ((state == 1))
         {
            Label::SetStyle(lab, "down");
         }
         else if ((state == 2))
         {
            Label::SetStyle(lab, "up");
         }
;
      }
;
      __out1 = lab;
      return true;
   }
};
label__custom_s_i_fStream* label__custom_s_i_f3;
LabelArrayStream* addLabel_lbaS_lbS2_param1;
LabelStream* addLabel_lbaS_lbS2_param2;
addLabel_lbaS_lbSStream* addLabel_lbaS_lbS2;
LabelArrayStream* mayAdd_lbaS4_param1;
mayAdd_lbaSStream* mayAdd_lbaS4;
label__custom_s_i_fStream* label__custom_s_i_f6;
LabelArrayStream* addLabel_lbaS_lbS5_param1;
LabelStream* addLabel_lbaS_lbS5_param2;
addLabel_lbaS_lbSStream* addLabel_lbaS_lbS5;
LabelArrayStream* mayAdd_lbaS7_param1;
mayAdd_lbaSStream* mayAdd_lbaS7;
label__custom_s_i_fStream* label__custom_s_i_f9;
LabelArrayStream* addLabel_lbaS_lbS8_param1;
LabelStream* addLabel_lbaS_lbS8_param2;
addLabel_lbaS_lbSStream* addLabel_lbaS_lbS8;
LabelArrayStream* mayAdd_lbaS10_param1;
mayAdd_lbaSStream* mayAdd_lbaS10;
label__custom_s_i_fStream* label__custom_s_i_f12;
LabelArrayStream* addLabel_lbaS_lbS11_param1;
LabelStream* addLabel_lbaS_lbS11_param2;
addLabel_lbaS_lbSStream* addLabel_lbaS_lbS11;

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

void OnInit()
{
   display = Get_param1();
   mult = param2;
   maxBars = param3;
   showReTest = Get_param4();
   minBars = param5;
   setBack = param6;
   left = param7;
   right = param8;
   bull1_color = param9;
   bull2_color = param10;
   bear1_color = param11;
   bear2_color = param12;
   labSize = Get_param13();
   atr1 = new ATRStream(200);
   cum1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cum1 = new CumOnStream(cum1X);
   BoxesCollection::SetMaxBoxes(500);
   LabelsCollection::SetMaxLabels(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("LuxAlgo - Swing Breakouts Tests & Retests");
   IndicatorSetString(INDICATOR_SHORTNAME, "Swing Breakouts Tests & Retests [LuxAlgo]");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   __array1 = new CustomTypeArray<Label*>(0, NULL);
   __array2 = new CustomTypeArray<Label*>(0, NULL);
      bull = new bin((Box*)(NULL), 0, NULL, __array1.Clear(), __array2.Clear());
   __array3 = new CustomTypeArray<Label*>(0, NULL);
   __array4 = new CustomTypeArray<Label*>(0, NULL);
      bear = new bin((Box*)(NULL), 0, NULL, __array3.Clear(), __array4.Clear());
   mayAdd_lbaS1_param1 = new LabelArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mayAdd_lbaS1 = new mayAdd_lbaSStream(mayAdd_lbaS1_param1);
   int id = 0;
   id = mayAdd_lbaS1.Init(id);
   label__custom_s_i_f3 = new label__custom_s_i_fStream("bull", 1, bin::Getprice(bull));
   id = label__custom_s_i_f3.Init(id);
   addLabel_lbaS_lbS2_param1 = new LabelArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   addLabel_lbaS_lbS2_param2 = new LabelStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   addLabel_lbaS_lbS2 = new addLabel_lbaS_lbSStream(addLabel_lbaS_lbS2_param1, addLabel_lbaS_lbS2_param2);
   id = addLabel_lbaS_lbS2.Init(id);
   mayAdd_lbaS4_param1 = new LabelArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mayAdd_lbaS4 = new mayAdd_lbaSStream(mayAdd_lbaS4_param1);
   id = mayAdd_lbaS4.Init(id);
   label__custom_s_i_f6 = new label__custom_s_i_fStream("bull", 2, bin::Getprice(bull));
   id = label__custom_s_i_f6.Init(id);
   addLabel_lbaS_lbS5_param1 = new LabelArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   addLabel_lbaS_lbS5_param2 = new LabelStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   addLabel_lbaS_lbS5 = new addLabel_lbaS_lbSStream(addLabel_lbaS_lbS5_param1, addLabel_lbaS_lbS5_param2);
   id = addLabel_lbaS_lbS5.Init(id);
   mayAdd_lbaS7_param1 = new LabelArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mayAdd_lbaS7 = new mayAdd_lbaSStream(mayAdd_lbaS7_param1);
   id = mayAdd_lbaS7.Init(id);
   label__custom_s_i_f9 = new label__custom_s_i_fStream("bear", 1, bin::Getprice(bear));
   id = label__custom_s_i_f9.Init(id);
   addLabel_lbaS_lbS8_param1 = new LabelArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   addLabel_lbaS_lbS8_param2 = new LabelStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   addLabel_lbaS_lbS8 = new addLabel_lbaS_lbSStream(addLabel_lbaS_lbS8_param1, addLabel_lbaS_lbS8_param2);
   id = addLabel_lbaS_lbS8.Init(id);
   mayAdd_lbaS10_param1 = new LabelArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mayAdd_lbaS10 = new mayAdd_lbaSStream(mayAdd_lbaS10_param1);
   id = mayAdd_lbaS10.Init(id);
   label__custom_s_i_f12 = new label__custom_s_i_fStream("bear", 2, bin::Getprice(bear));
   id = label__custom_s_i_f12.Init(id);
   addLabel_lbaS_lbS11_param1 = new LabelArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   addLabel_lbaS_lbS11_param2 = new LabelStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   addLabel_lbaS_lbS11 = new addLabel_lbaS_lbSStream(addLabel_lbaS_lbS11_param1, addLabel_lbaS_lbS11_param2);
   id = addLabel_lbaS_lbS11.Init(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   __array1.Release();
   __array2.Release();
   bull.Release();
   __array3.Release();
   __array4.Release();
   bear.Release();
   atr1.Release();
   cum1X.Release();
   cum1.Release();
   mayAdd_lbaS1_param1.Release();
   delete mayAdd_lbaS1;
   delete label__custom_s_i_f3;
   addLabel_lbaS_lbS2_param1.Release();
   addLabel_lbaS_lbS2_param2.Release();
   delete addLabel_lbaS_lbS2;
   mayAdd_lbaS4_param1.Release();
   delete mayAdd_lbaS4;
   delete label__custom_s_i_f6;
   addLabel_lbaS_lbS5_param1.Release();
   addLabel_lbaS_lbS5_param2.Release();
   delete addLabel_lbaS_lbS5;
   mayAdd_lbaS7_param1.Release();
   delete mayAdd_lbaS7;
   delete label__custom_s_i_f9;
   addLabel_lbaS_lbS8_param1.Release();
   addLabel_lbaS_lbS8_param2.Release();
   delete addLabel_lbaS_lbS8;
   mayAdd_lbaS10_param1.Release();
   delete mayAdd_lbaS10;
   delete label__custom_s_i_f12;
   addLabel_lbaS_lbS11_param1.Release();
   addLabel_lbaS_lbS11_param2.Release();
   delete addLabel_lbaS_lbS11;
   BoxesCollection::Clear(true);
   LabelsCollection::Clear(true);
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
      cum1X.Init();
      mayAdd_lbaS1_param1.Init();
      mayAdd_lbaS1.Clear();
      label__custom_s_i_f3.Clear();
      addLabel_lbaS_lbS2_param1.Init();
      addLabel_lbaS_lbS2_param2.Init();
      addLabel_lbaS_lbS2.Clear();
      mayAdd_lbaS4_param1.Init();
      mayAdd_lbaS4.Clear();
      label__custom_s_i_f6.Clear();
      addLabel_lbaS_lbS5_param1.Init();
      addLabel_lbaS_lbS5_param2.Init();
      addLabel_lbaS_lbS5.Clear();
      mayAdd_lbaS7_param1.Init();
      mayAdd_lbaS7.Clear();
      label__custom_s_i_f9.Clear();
      addLabel_lbaS_lbS8_param1.Init();
      addLabel_lbaS_lbS8_param2.Init();
      addLabel_lbaS_lbS8.Clear();
      mayAdd_lbaS10_param1.Init();
      mayAdd_lbaS10.Clear();
      label__custom_s_i_f12.Clear();
      addLabel_lbaS_lbS11_param1.Init();
      addLabel_lbaS_lbS11_param2.Init();
      addLabel_lbaS_lbS11.Clear();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      n = pos;
      double atr1Value[1];
      if (!atr1.GetValues(pos, 1, atr1Value)) { atr1Value[0] = EMPTY_VALUE; }
      cum1X.SetValue(pos, high[pos] - low[pos]);
      double cum1Value[1];
      if (!cum1.GetValues(pos, 1, cum1Value)) { cum1Value[0] = EMPTY_VALUE; }
      double atr = SafeMultiply(Nz(atr1Value[0], SafeDivide(cum1Value[0], (n + 1))), mult);
      double highestpivot1Value[1];
      if (!PivotHighStream::GetValues(pos, 1, highestpivot1Value, _Symbol, (ENUM_TIMEFRAMES)_Period, left, right)) { highestpivot1Value[0] = EMPTY_VALUE; }
      double ph = highestpivot1Value[0];
      double lowestpivot1Value[1];
      if (!PivotLowStream::GetValues(pos, 1, lowestpivot1Value, _Symbol, (ENUM_TIMEFRAMES)_Period, left, right)) { lowestpivot1Value[0] = EMPTY_VALUE; }
      double pl = lowestpivot1Value[0];
      int box_bull_left = Box::GetLeft(bin::Getbx(bull));
      int box_bull_right = Box::GetRight(bin::Getbx(bull));
      double box_bull_top = Box::GetTop(bin::Getbx(bull));
      double box_bull_bottom = Box::GetBottom(bin::Getbx(bull));
      int box_bear_left = Box::GetLeft(bin::Getbx(bear));
      int box_bear_right = Box::GetRight(bin::Getbx(bear));
      double box_bear_top = Box::GetTop(bin::Getbx(bear));
      double box_bear_bottom = Box::GetBottom(bin::Getbx(bear));
      if ((((display == "Bullish") || (display == "Bullish AND Bearish")) || ((display == "Bullish OR Bearish") && (bin::Getstate(bear) == 0))))
      {
         if ((bin::Getstate(bull) == 0))
         {
            if (!((pl) == EMPTY_VALUE))
            {
               bin::Setbx(bull, BoxesCollection::Create(IndicatorObjPrefix + "box_1_id", n - right, SafePlus(pl, atr), n, pl, time[pos])
                  .SetBgColor(bull1_color)
                  .SetBorderColor((uint)(INT_MAX))
                  .SetExtend("none"));
               bin::Setstate(bull, 1);
               Array::Clear(bin::Getlab1(bull));
               Array::Clear(bin::Getlab2(bull));
               bin::Setprice(bull, pl);
            }
         }
         else if ((bin::Getstate(bull) == 1))
         {
            if (SafeGE(SafeMinus(box_bull_right, box_bull_left), maxBars))
            {
               if ((Array::Size<int, ICustomTypeArray<Label*>*>(bin::Getlab1(bull), INT_MIN) == 0))
               {
                  BoxesCollection::Delete(bin::Getbx(bull));
               }
               else
               {
                  if (setBack)
                  {
                     Box::SetRight(bin::Getbx(bull), Label::GetX(Array::First<Label*, ICustomTypeArray<Label*>*>(bin::Getlab1(bull), NULL)));
                  }
                  bin::Setstate(bull, 0);
               }
            }
            else
            {
               Box::SetRight(bin::Getbx(bull), n);
               if (SafeLess(close[pos], box_bull_bottom))
               {
                  bin::Setbx(bull, BoxesCollection::Create(IndicatorObjPrefix + "box_2_id", n, box_bull_top, n, box_bull_bottom, time[pos])
                     .SetBgColor(bull2_color)
                     .SetBorderColor((uint)(INT_MAX))
                     .SetExtend("none"));
                  bin::Setstate(bull, 2);
                  bin::Setprice(bull, box_bull_top);
               }
               mayAdd_lbaS1_param1.SetValue(pos, bin::Getlab1(bull));
               int mayAdd_lbaS1Value;
               if (!mayAdd_lbaS1.GetValue(pos, oldPos, mayAdd_lbaS1Value)) { mayAdd_lbaS1Value = (-1); }
               if (SafeGreater(close[pos], box_bull_top) && SafeLess(open[pos], box_bull_top) && mayAdd_lbaS1Value)
               {
                  Label* label__custom_s_i_f3Value;
                  if (!label__custom_s_i_f3.GetValue(pos, oldPos, label__custom_s_i_f3Value)) { label__custom_s_i_f3Value = NULL; }
                  addLabel_lbaS_lbS2_param1.SetValue(pos, bin::Getlab1(bull));
                  addLabel_lbaS_lbS2_param2.SetValue(pos, label__custom_s_i_f3Value);
                  Label* addLabel_lbaS_lbS2Value;
                  if (!addLabel_lbaS_lbS2.GetValue(pos, oldPos, addLabel_lbaS_lbS2Value)) { addLabel_lbaS_lbS2Value = NULL; }
                  LabelsCollection::Delete(addLabel_lbaS_lbS2Value);
               }
               (bin::Getstate(bull) == 2);
            }
         }
         else
         {
            if (SafeGE(SafeMinus(box_bull_right, box_bull_left), maxBars))
            {
               if ((Array::Size<int, ICustomTypeArray<Label*>*>(bin::Getlab2(bull), INT_MIN) == 0))
               {
                  BoxesCollection::Delete(bin::Getbx(bull));
               }
               else
               {
                  if (setBack)
                  {
                     Box::SetRight(bin::Getbx(bull), Label::GetX(Array::First<Label*, ICustomTypeArray<Label*>*>(bin::Getlab2(bull), NULL)));
                  }
                  bin::Setstate(bull, 0);
               }
            }
            else
            {
               Box::SetRight(bin::Getbx(bull), n);
               if (SafeGreater(close[pos], box_bull_top))
               {
                  bin::Setstate(bull, 0);
               }
               mayAdd_lbaS4_param1.SetValue(pos, bin::Getlab2(bull));
               int mayAdd_lbaS4Value;
               if (!mayAdd_lbaS4.GetValue(pos, oldPos, mayAdd_lbaS4Value)) { mayAdd_lbaS4Value = (-1); }
               if (SafeLess(close[pos], box_bull_bottom) && SafeGreater(open[pos], box_bull_bottom) && mayAdd_lbaS4Value)
               {
                  Label* label__custom_s_i_f6Value;
                  if (!label__custom_s_i_f6.GetValue(pos, oldPos, label__custom_s_i_f6Value)) { label__custom_s_i_f6Value = NULL; }
                  addLabel_lbaS_lbS5_param1.SetValue(pos, bin::Getlab2(bull));
                  addLabel_lbaS_lbS5_param2.SetValue(pos, label__custom_s_i_f6Value);
                  Label* addLabel_lbaS_lbS5Value;
                  if (!addLabel_lbaS_lbS5.GetValue(pos, oldPos, addLabel_lbaS_lbS5Value)) { addLabel_lbaS_lbS5Value = NULL; }
                  LabelsCollection::Delete(addLabel_lbaS_lbS5Value);
               }
            }
         }
      }
      if ((((display == "Bearish") || (display == "Bullish AND Bearish")) || ((display == "Bullish OR Bearish") && (bin::Getstate(bull) == 0))))
      {
         if ((bin::Getstate(bear) == 0))
         {
            if (!((ph) == EMPTY_VALUE))
            {
               bin::Setbx(bear, BoxesCollection::Create(IndicatorObjPrefix + "box_3_id", n - right, ph, n, SafeMinus(ph, atr), time[pos])
                  .SetBgColor(bear1_color)
                  .SetBorderColor((uint)(INT_MAX))
                  .SetExtend("none"));
               bin::Setstate(bear, 1);
               Array::Clear(bin::Getlab1(bear));
               Array::Clear(bin::Getlab2(bear));
               bin::Setprice(bear, ph);
            }
         }
         else if ((bin::Getstate(bear) == 1))
         {
            if (SafeGE(SafeMinus(box_bear_right, box_bear_left), maxBars))
            {
               if ((Array::Size<int, ICustomTypeArray<Label*>*>(bin::Getlab1(bear), INT_MIN) == 0))
               {
                  BoxesCollection::Delete(bin::Getbx(bear));
               }
               else
               {
                  if (setBack)
                  {
                     Box::SetRight(bin::Getbx(bear), Label::GetX(Array::First<Label*, ICustomTypeArray<Label*>*>(bin::Getlab1(bear), NULL)));
                  }
                  bin::Setstate(bear, 0);
               }
            }
            else
            {
               Box::SetRight(bin::Getbx(bear), n);
               if (SafeGreater(close[pos], box_bear_top))
               {
                  bin::Setbx(bear, BoxesCollection::Create(IndicatorObjPrefix + "box_4_id", n, box_bear_top, n, box_bear_bottom, time[pos])
                     .SetBgColor(bear2_color)
                     .SetBorderColor((uint)(INT_MAX))
                     .SetExtend("none"));
                  bin::Setstate(bear, 2);
                  bin::Setprice(bear, box_bear_bottom);
               }
               mayAdd_lbaS7_param1.SetValue(pos, bin::Getlab1(bear));
               int mayAdd_lbaS7Value;
               if (!mayAdd_lbaS7.GetValue(pos, oldPos, mayAdd_lbaS7Value)) { mayAdd_lbaS7Value = (-1); }
               if (SafeLess(close[pos], box_bear_bottom) && SafeGreater(open[pos], box_bear_bottom) && mayAdd_lbaS7Value)
               {
                  Label* label__custom_s_i_f9Value;
                  if (!label__custom_s_i_f9.GetValue(pos, oldPos, label__custom_s_i_f9Value)) { label__custom_s_i_f9Value = NULL; }
                  addLabel_lbaS_lbS8_param1.SetValue(pos, bin::Getlab1(bear));
                  addLabel_lbaS_lbS8_param2.SetValue(pos, label__custom_s_i_f9Value);
                  Label* addLabel_lbaS_lbS8Value;
                  if (!addLabel_lbaS_lbS8.GetValue(pos, oldPos, addLabel_lbaS_lbS8Value)) { addLabel_lbaS_lbS8Value = NULL; }
                  LabelsCollection::Delete(addLabel_lbaS_lbS8Value);
               }
               (bin::Getstate(bear) == 2);
            }
         }
         else
         {
            if (SafeGE(SafeMinus(box_bear_right, box_bear_left), maxBars))
            {
               if ((Array::Size<int, ICustomTypeArray<Label*>*>(bin::Getlab2(bear), INT_MIN) == 0))
               {
                  BoxesCollection::Delete(bin::Getbx(bear));
               }
               else
               {
                  if (setBack)
                  {
                     Box::SetRight(bin::Getbx(bear), Label::GetX(Array::First<Label*, ICustomTypeArray<Label*>*>(bin::Getlab2(bear), NULL)));
                  }
                  bin::Setstate(bear, 0);
               }
            }
            else
            {
               Box::SetRight(bin::Getbx(bear), n);
               if (SafeLess(close[pos], box_bear_bottom))
               {
                  bin::Setstate(bear, 0);
               }
               mayAdd_lbaS10_param1.SetValue(pos, bin::Getlab2(bear));
               int mayAdd_lbaS10Value;
               if (!mayAdd_lbaS10.GetValue(pos, oldPos, mayAdd_lbaS10Value)) { mayAdd_lbaS10Value = (-1); }
               if (SafeGreater(close[pos], box_bear_top) && SafeLess(open[pos], box_bear_top) && mayAdd_lbaS10Value)
               {
                  Label* label__custom_s_i_f12Value;
                  if (!label__custom_s_i_f12.GetValue(pos, oldPos, label__custom_s_i_f12Value)) { label__custom_s_i_f12Value = NULL; }
                  addLabel_lbaS_lbS11_param1.SetValue(pos, bin::Getlab2(bear));
                  addLabel_lbaS_lbS11_param2.SetValue(pos, label__custom_s_i_f12Value);
                  Label* addLabel_lbaS_lbS11Value;
                  if (!addLabel_lbaS_lbS11.GetValue(pos, oldPos, addLabel_lbaS_lbS11Value)) { addLabel_lbaS_lbS11Value = NULL; }
                  LabelsCollection::Delete(addLabel_lbaS_lbS11Value);
               }
            }
         }
      }
   }
   BoxesCollection::Redraw();
   LabelsCollection::Redraw();
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75910

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 