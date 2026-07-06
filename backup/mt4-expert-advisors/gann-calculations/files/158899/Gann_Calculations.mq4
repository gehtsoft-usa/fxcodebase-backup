//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75810

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
#property indicator_buffers 4
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_type4 DRAW_ARROW
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

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
// Collection of lines v1.3

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL

// Line object v1.4

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

   Line* SetColor(color clr)
   {
      _clr = clr;
      return &this;
   }
   
   static void SetColor(Line* line, color clr)
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
// Array v1.5
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

// Template for array interface v1.0

template <typename CLASS_TYPE>
interface ITArray
{
public:
   virtual void Unshift(CLASS_TYPE value) = 0;
   virtual int Size() = 0;
   virtual void Push(CLASS_TYPE value) = 0;
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
// Label array interface v1.0
// Label v1.6

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
   
   static void SetColor(Label* label, color clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetColor(clr);
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


class ILabelArray : public ITArray<Label*>
{
public:
   virtual ILabelArray* Slice(int from, int to) = 0;
   virtual ILabelArray* Clear() = 0;
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
#ifndef LabelArray_IMPL
#define LabelArray_IMPL
// Label array v1.0
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
public:
   CustomTypeArray(int size, CLASS_TYPE defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ~CustomTypeArray()
   {
      Clear();
   }
   
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
protected:
   virtual void DeleteItem(CLASS_TYPE item)
   {
   }
};
#endif
// Collection of labels v1.3

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
   virtual void DeleteItem(Label* item)
   {
      LabelsCollection::Delete(item);
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
   
   template <typename DUMMY_TYPE, typename ARRAY_TYPE>
   static int Size(ARRAY_TYPE array, int defaultValue) { if (array == NULL) { return INT_MIN;} return array.Size(); }

   static int Shift(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static double Shift(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static Line* Shift(ILineArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static Box* Shift(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static string Shift(IStringArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static int Shift(IBoolArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static uint Shift(IColorArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }

   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Push(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Push(value); }
   
   static int Pop(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static double Pop(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static Line* Pop(ILineArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static Box* Pop(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static string Pop(IStringArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }
   static int Pop(IBoolArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static uint Pop(IColorArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Get(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Get(index); }
   
   template <typename ARRAY_TYPE, typename DUMMY_TYPE, typename VALUE_TYPE>
   static void Set(ARRAY_TYPE array, int index, VALUE_TYPE value) { if (array == NULL) { return; } array.Set(index, value); }

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
// PlotShape v1.1
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
   static void Set(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift)
   {
      if (seriesValue == EMPTY_VALUE)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void Set(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift)
   {
      if (seriesValue == INT_MIN)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void SetBool(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift)
   {
      if (seriesValue == -1)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
};

#endif
// Time-related functions from Pine Script
// v1.1

class PineScriptTime
{
public:
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
};
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Stream base v1.0

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
#ifndef IStream_IMPL
#define IStream_IMPL

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};
#endif

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
#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL
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
   virtual bool GetValue(const int period, int &val) = 0;
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

//ConditionStreamV2 v1.1

class ConditionStreamV2 : public ABoolStream
{
protected:
   ICondition* _condition;
public:
   ConditionStreamV2(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~ConditionStreamV2()
   {
      _condition.Release();
   }

   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   bool GetValue(const int period, bool &val)
   {
      val = _condition.IsPass(period, 0);
      return true;
   }
   bool GetValue(const int period, int &val)
   {
      val = _condition.IsPass(period, 0);
      return true;
   }
};
#endif
// ACondition v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ACondition_IMP
#define ACondition_IMP
// Abstract condition v1.1



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

class ACondition : public AConditionBase
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   string _symbol;
public:
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe, string name = "")
      :AConditionBase(name)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ACondition()
   {
      delete _instrument;
   }
};
#endif

// IBarStream v2.1



#ifndef IBarStream_IMP
#define IBarStream_IMP

interface IBarStream : public IStream
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
#ifndef TwoStreamsConditionType_IMP
#define TwoStreamsConditionType_IMP

enum TwoStreamsConditionType
{
   FirstAboveSecond,
   FirstBelowSecond,
   FirstCrossOverSecond,
   FirstCrossUnderSecond,
   FirstEqualsSecond
};

#endif

// Stream-stream condition v1.0

#ifndef StreamStreamCondition_IMP
#define StreamStreamCondition_IMP

class StreamStreamCondition : public ACondition
{
   IStream* _stream1;
   IStream* _stream2;
   int _periodShift1;
   int _periodShift2;
   string _name1;
   string _name2;
   TwoStreamsConditionType _condition;
public:
   StreamStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      TwoStreamsConditionType condition,
      IStream* stream1,
      IStream* stream2,
      string name1,
      string name2,
      int streamPeriodShift1 = 0,
      int streamPeriodShift2 = 0)
      :ACondition(symbol, timeframe)
   {
      _name1 = name1;
      _name2 = name2;
      _stream1 = stream1;
      _stream1.AddRef();
      _stream2 = stream2;
      _stream2.AddRef();
      _condition = condition;
      _periodShift1 = streamPeriodShift1;
      _periodShift2 = streamPeriodShift2;
   }

   ~StreamStreamCondition()
   {
      _stream1.Release();
      _stream2.Release();
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      switch (_condition)
      {
         case FirstAboveSecond:
            return _name1 + " > " + _name2 + ": " + (result ? "true" : "false");
         case FirstBelowSecond:
            return _name1 + " < " + _name2 + ": " + (result ? "true" : "false");
         case FirstCrossOverSecond:
            return _name1 + " co " + _name2 + ": " + (result ? "true" : "false");
         case FirstCrossUnderSecond:
            return _name1 + " cu " + _name2 + ": " + (result ? "true" : "false");
      }
      return _name1 + "-" + _name2 + ": " + (result ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value10, value11;
      if (!_stream1.GetValue(period + _periodShift1, value10) || !_stream1.GetValue(period + _periodShift1 + 1, value11))
      {
         return false;
      }
      double value20, value21;
      if (!_stream2.GetValue(period + _periodShift2, value20) || !_stream2.GetValue(period + _periodShift2 + 1, value21))
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return value10 > value20;
         case FirstBelowSecond:
            return value10 < value20;
         case FirstCrossOverSecond:
            return value10 >= value20 && value11 < value21;
         case FirstCrossUnderSecond:
            return value10 <= value20 && value11 > value21;
      }
      return value10 >= value20 && value11 < value21;
   }
};
#endif
// Or condition v4.1



#ifndef OrCondition_IMP
#define OrCondition_IMP

class OrCondition : public AConditionBase
{
   ICondition *_conditions[];
public:
   ~OrCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         _conditions[i].Release();
      }
   }

   void Add(ICondition *condition, bool addRef)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
      if (addRef)
         condition.AddRef();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (_conditions[i].IsPass(period, date))
            return true;
      }
      return false;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      string messages = "";
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         string logMessage = _conditions[i].GetLogMessage(period, date);
         if (messages != "")
            messages = messages + " or (" + logMessage + ")";
         else
            messages = "(" + logMessage + ")";
      }
      return messages + (IsPass(period, date) ? "=true" : "=false");
   }
};
#endif

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

//CrossStreamV2 v1.1

class CrossStreamFactory
{
public:
   static IBoolStream* CreateCross(IStream *left, IStream* right)
   {
      OrCondition* or = new OrCondition();
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""), false);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, right, left, "", ""), false);
      ConditionStreamV2* result = new ConditionStreamV2(or);
      or.Release();
      return result;
   }

   static IBoolStream* CreateCrossunder(IStream *left, IStream* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
   static IBoolStream* CreateCrossunder(IStream *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      IBoolStream* condition = CreateCrossunder(left, rightWrapper);
      rightWrapper.Release();
      return condition;
   }

   static IBoolStream* CreateCrossover(IStream *left, IStream* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
   static IBoolStream* CreateCrossover(IIntStream *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* leftWrapper = new IntToFloatStreamWrapper(left);
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      IBoolStream* condition = CreateCrossover(leftWrapper, rightWrapper);
      leftWrapper.Release();
      rightWrapper.Release();
      return condition;
   }
   static IBoolStream* CreateCrossover(IStream *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      IBoolStream* condition = CreateCrossover(left, rightWrapper);
      rightWrapper.Release();
      return condition;
   }
};
#endif
// Custom integer stream v1.1

#ifndef IntStream_IMPL
#define IntStream_IMPL

// Abstract integer stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL


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
// Custom datetime stream v1.0

#ifndef DatetimeStream_IMPL
#define DatetimeStream_IMPL

// Template for custom stream v1.0

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
      ArrayInitialize(_stream, _emptyValue);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, T value)
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

   bool GetValue(const int period, T &val)
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

class DatetimeStream : public TStream<datetime>
{
public:
   DatetimeStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      : TStream<datetime>(symbol, timeframe, INT_MIN)
   {
   }
};
#endif
input bool param1 = true; // Buy
input bool param2 = true; // Sell
input bool param3 = true; // Support
input bool param4 = true; // Resistance
input bool param5 = false; // Buy Label
input bool param6 = false; // Sell Label
input bool param7 = false; // Support Label
input bool param8 = false; // Resistance Label
input bool param9 = false; // Signal Buy
input bool param10 = false; // Signal Sell
input bool param11 = true; // Show Daily Open
input bool param12 = false; // Start Hour
input bool param13 = false; // End Hour
input int param14 = 15; // Start Hour
input int param15 = 0; // Minute
input int param16 = 23; // End Hour
input int param17 = 00; // Minute
input bool param18 = false; // Squares lines
input bool param19 = false; // Diagonals Type 1 lines
input bool param20 = false; // Diagonals Type 2 lines
input bool param21 = false; // Mid Lines Type 1 lines
input bool param22 = false; // Mid Lines Type 2 lines
input bool param23 = false; // Inside Square Type 1 lines
input bool param24 = false; // Inside Square Type 2 lines
input bool param25 = false; // 1/4 lines
input bool param26 = false; // 1/6 lines
input bool param27 = false; // 1/8 lines
input color param28 = AddTransparency(White, 30); // Frame Lines Color
input color param29 = AddTransparency(White, 50); // Inside Lines Color
input int param30 = 1; // Width
input bool param31 = false; // Start Hour
input bool param32 = false; // End Hour
input int param33 = 0; // Start Hour
input int param34 = 0; // Minute
input int param35 = 24; // End Hour
input int param36 = 00; // Minute
input int param37 = 1; // Start Calculation in Days
input int bars_limit = 100000; // Bars limit
int show_Buy;
int show_Sell;
int show_Sup;
int show_Res;
int show_Buy_lb;
int show_Sell_lb;
int show_Sup_lb;
int show_Res_lb;
int show_Signal_Buy;
int show_Signal_Sell;
int show_DO;
Line* open_price_line;
Line* buyLine;
Line* sellLine;
Label* buyLabel;
Label* sellLabel;
IFloatArray* x;
IFloatArray* __array1;
IFloatArray* sqr_x;
IFloatArray* __array2;
IFloatArray* sqr_x_rounded;
IFloatArray* __array3;
IFloatArray* sqr_x_rounded_root;
IFloatArray* __array4;
double buy_above[];
double buy_above_DEFAULT_VALUE;
double sell_below[];
double sell_below_DEFAULT_VALUE;
Label* buySignalLabel;
Label* sellSignalLabel;
int show_startHour;
int show_endHour;
int targetHour;
int targetMinute;
double plot1[];
class isTargetTimeStream
{
   bool _initialized;
public:
   isTargetTimeStream()
   {
      _initialized = false;
   }
   ~isTargetTimeStream()
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
      datetime targetTimestamp = Timestamp(PineScriptTime::Year(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), PineScriptTime::Month(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), PineScriptTime::DayOfMonth(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), targetHour, targetMinute, 0);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      __out1 = SafeLess(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1), targetTimestamp) && SafeGE(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), targetTimestamp);
      return true;
   }
};
isTargetTimeStream* isTargetTime1;
int targetHour1;
int targetMinute1;
double plot2[];
class isTargetTime1Stream
{
   bool _initialized;
public:
   isTargetTime1Stream()
   {
      _initialized = false;
   }
   ~isTargetTime1Stream()
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
      datetime targetTimestamp1 = Timestamp(PineScriptTime::Year(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), PineScriptTime::Month(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), PineScriptTime::DayOfMonth(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), targetHour1, targetMinute1, 0);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      __out1 = SafeLess(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1), targetTimestamp1) && SafeGE(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), targetTimestamp1);
      return true;
   }
};
isTargetTime1Stream* isTargetTime12;
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
IBoolStream* crossunder1;
Line* supportLine;
Line* resistanceLine;
Label* supportLabel;
Label* resistanceLabel;
int show_squares;
int show_diagonals1;
int show_diagonals2;
int show_midlines_type1;
int show_midlines_type2;
int show_insquare_type1;
int show_insquare_type2;
int quarter;
int sixth;
int eighth;
uint outsiteLines;
uint insideLines;
int widthLines;
int show_startHour_S;
int show_endHour_S;
int targetHour_S;
int targetMinute_S;
double plot3[];
class isTargetTime_SStream
{
   bool _initialized;
public:
   isTargetTime_SStream()
   {
      _initialized = false;
   }
   ~isTargetTime_SStream()
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
      datetime targetTimestamp = Timestamp(PineScriptTime::Year(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), PineScriptTime::Month(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), PineScriptTime::DayOfMonth(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), targetHour_S, targetMinute_S, 0);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      __out1 = SafeLess(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1), targetTimestamp) && SafeGE(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), targetTimestamp);
      return true;
   }
};
isTargetTime_SStream* isTargetTime_S3;
int targetHour_S1;
int targetMinute_S1;
double plot4[];
class isTargetTime_S1Stream
{
   bool _initialized;
public:
   isTargetTime_S1Stream()
   {
      _initialized = false;
   }
   ~isTargetTime_S1Stream()
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
      datetime targetTimestamp1 = Timestamp(PineScriptTime::Year(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), PineScriptTime::Month(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), PineScriptTime::DayOfMonth(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), ""), targetHour_S1, targetMinute_S1, 0);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      __out1 = SafeLess(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1), targetTimestamp1) && SafeGE(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), targetTimestamp1);
      return true;
   }
};
isTargetTime_S1Stream* isTargetTime_S14;
int calculations_day_back;
ILineArray* lines;
ILineArray* __array5;
class getHighestValue_iS_iSStream
{
   IIntStream* lookback;
   IIntStream* beginning;
   double higher[];
   double higher_DEFAULT_VALUE;
   bool _initialized;
public:
   getHighestValue_iS_iSStream(IIntStream* lookback, IIntStream* beginning)
   {
      _initialized = false;
      this.lookback = lookback;
      lookback.AddRef();
      this.beginning = beginning;
      beginning.AddRef();
   }
   ~getHighestValue_iS_iSStream()
   {
      lookback.Release();
      beginning.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, higher);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         higher_DEFAULT_VALUE = 0.0;
         ArrayInitialize(higher, higher_DEFAULT_VALUE);
         _initialized = true;
      }
      int lookbackValue;
      if (!lookback.GetValue(pos, lookbackValue)) { lookbackValue = INT_MIN; }
      int for3_from = 0;
      int for3_to = lookbackValue - 1;
      bool for3_forward = for3_from <= for3_to;
      int for3_step = 1 * (for3_forward ? 1 : -1);
      if (for3_from == EMPTY_VALUE || for3_to == EMPTY_VALUE) { return false; }
      for (int i = for3_from; (for3_forward ? i <= for3_to : i >= for3_to); i += for3_step)
      {
         int beginningValue;
         if (!beginning.GetValue(pos, beginningValue)) { beginningValue = INT_MIN; }
         if (pos + beginningValue - i > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
         if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
         double value = Nz(iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + beginningValue - i), higher[pos + 1]);
         if (SafeGreater(value, higher[pos]))
         {
            SetStream(higher, pos, value, higher_DEFAULT_VALUE);
         }
      }
      __out1 = higher[pos];
      return true;
   }
};
IntStream* getHighestValue_iS_iS5_param1;
IntStream* getHighestValue_iS_iS5_param2;
getHighestValue_iS_iSStream* getHighestValue_iS_iS5;
class getLowestValue_iS_iSStream
{
   IIntStream* lookback;
   IIntStream* beginning;
   double lowest[];
   double lowest_DEFAULT_VALUE;
   bool _initialized;
public:
   getLowestValue_iS_iSStream(IIntStream* lookback, IIntStream* beginning)
   {
      _initialized = false;
      this.lookback = lookback;
      lookback.AddRef();
      this.beginning = beginning;
      beginning.AddRef();
   }
   ~getLowestValue_iS_iSStream()
   {
      lookback.Release();
      beginning.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, lowest);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         lowest_DEFAULT_VALUE = 10000000000000;
         ArrayInitialize(lowest, lowest_DEFAULT_VALUE);
         _initialized = true;
      }
      int lookbackValue;
      if (!lookback.GetValue(pos, lookbackValue)) { lookbackValue = INT_MIN; }
      int for4_from = 0;
      int for4_to = lookbackValue - 1;
      bool for4_forward = for4_from <= for4_to;
      int for4_step = 1 * (for4_forward ? 1 : -1);
      if (for4_from == EMPTY_VALUE || for4_to == EMPTY_VALUE) { return false; }
      for (int i = for4_from; (for4_forward ? i <= for4_to : i >= for4_to); i += for4_step)
      {
         int beginningValue;
         if (!beginning.GetValue(pos, beginningValue)) { beginningValue = INT_MIN; }
         if (pos + beginningValue - i > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
         if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
         double value = Nz(iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + beginningValue - i), lowest[pos + 1]);
         if (SafeLess(value, lowest[pos]))
         {
            SetStream(lowest, pos, value, lowest_DEFAULT_VALUE);
         }
      }
      __out1 = lowest[pos];
      return true;
   }
};
IntStream* getLowestValue_iS_iS6_param1;
IntStream* getLowestValue_iS_iS6_param2;
getLowestValue_iS_iSStream* getLowestValue_iS_iS6;
class drawSquares__datetimeS__datetimeS_fS_fS_fSStream
{
   TIStream<datetime>* startTime;
   TIStream<datetime>* endTime;
   IStream* highValue;
   IStream* lowValue;
   IStream* midValue;
   double upperY[];
   double upperY_DEFAULT_VALUE;
   double lowerY[];
   double lowerY_DEFAULT_VALUE;
   double upperY1[];
   double upperY1_DEFAULT_VALUE;
   double lowerY1[];
   double lowerY1_DEFAULT_VALUE;
   double upperX[];
   double upperX_DEFAULT_VALUE;
   double lowerX[];
   double lowerX_DEFAULT_VALUE;
   double upperX1[];
   double upperX1_DEFAULT_VALUE;
   double lowerX1[];
   double lowerX1_DEFAULT_VALUE;
   Line* diagonal_line;
   bool _initialized;
public:
   drawSquares__datetimeS__datetimeS_fS_fS_fSStream(TIStream<datetime>* startTime, TIStream<datetime>* endTime, IStream* highValue, IStream* lowValue, IStream* midValue)
   {
      _initialized = false;
      this.startTime = startTime;
      startTime.AddRef();
      this.endTime = endTime;
      endTime.AddRef();
      this.highValue = highValue;
      highValue.AddRef();
      this.lowValue = lowValue;
      lowValue.AddRef();
      this.midValue = midValue;
      midValue.AddRef();
   }
   ~drawSquares__datetimeS__datetimeS_fS_fS_fSStream()
   {
      startTime.Release();
      endTime.Release();
      highValue.Release();
      lowValue.Release();
      midValue.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, upperY);
      SetIndexBuffer(id++, lowerY);
      SetIndexBuffer(id++, upperY1);
      SetIndexBuffer(id++, lowerY1);
      SetIndexBuffer(id++, upperX);
      SetIndexBuffer(id++, lowerX);
      SetIndexBuffer(id++, upperX1);
      SetIndexBuffer(id++, lowerX1);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos)
   {
      if (!_initialized)
      {
         upperY_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(upperY, upperY_DEFAULT_VALUE);
         lowerY_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(lowerY, lowerY_DEFAULT_VALUE);
         upperY1_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(upperY1, upperY1_DEFAULT_VALUE);
         lowerY1_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(lowerY1, lowerY1_DEFAULT_VALUE);
         upperX_DEFAULT_VALUE = INT_MIN;
         ArrayInitialize(upperX, upperX_DEFAULT_VALUE);
         lowerX_DEFAULT_VALUE = INT_MIN;
         ArrayInitialize(lowerX, lowerX_DEFAULT_VALUE);
         upperX1_DEFAULT_VALUE = INT_MIN;
         ArrayInitialize(upperX1, upperX1_DEFAULT_VALUE);
         lowerX1_DEFAULT_VALUE = INT_MIN;
         ArrayInitialize(lowerX1, lowerX1_DEFAULT_VALUE);
         diagonal_line = NULL;
         _initialized = true;
      }
      upperY[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? upperY[pos + 1] : EMPTY_VALUE;
      lowerY[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? lowerY[pos + 1] : EMPTY_VALUE;
      upperY1[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? upperY1[pos + 1] : EMPTY_VALUE;
      lowerY1[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? lowerY1[pos + 1] : EMPTY_VALUE;
      upperX[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? upperX[pos + 1] : INT_MIN;
      lowerX[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? lowerX[pos + 1] : INT_MIN;
      upperX1[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? upperX1[pos + 1] : INT_MIN;
      lowerX1[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? lowerX1[pos + 1] : INT_MIN;
      if (show_squares)
      {
         datetime startTimeValue;
         if (!startTime.GetValue(pos, startTimeValue)) { startTimeValue = NULL; }
         double highValueValue;
         if (!highValue.GetValue(pos, highValueValue)) { highValueValue = EMPTY_VALUE; }
         datetime endTimeValue;
         if (!endTime.GetValue(pos, endTimeValue)) { endTimeValue = NULL; }
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_6_id", startTimeValue, highValueValue, endTimeValue, highValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(outsiteLines).SetWidth(widthLines).SetStyle("solid").SetExtend("none"));
         double lowValueValue;
         if (!lowValue.GetValue(pos, lowValueValue)) { lowValueValue = EMPTY_VALUE; }
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_7_id", startTimeValue, lowValueValue, endTimeValue, lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(outsiteLines).SetWidth(widthLines).SetStyle("solid").SetExtend("none"));
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_8_id", startTimeValue, highValueValue, startTimeValue, lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(outsiteLines).SetWidth(widthLines).SetStyle("solid").SetExtend("none"));
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_9_id", endTimeValue, highValueValue, endTimeValue, lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(outsiteLines).SetWidth(widthLines).SetStyle("solid").SetExtend("none"));
      }
      if (show_insquare_type1)
      {
         datetime startTimeValue;
         if (!startTime.GetValue(pos, startTimeValue)) { startTimeValue = NULL; }
         double lowValueValue;
         if (!lowValue.GetValue(pos, lowValueValue)) { lowValueValue = EMPTY_VALUE; }
         datetime endTimeValue;
         if (!endTime.GetValue(pos, endTimeValue)) { endTimeValue = NULL; }
         double highValueValue;
         if (!highValue.GetValue(pos, highValueValue)) { highValueValue = EMPTY_VALUE; }
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_10_id", startTimeValue, lowValueValue, endTimeValue, highValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
      }
      if (show_insquare_type2)
      {
         datetime startTimeValue;
         if (!startTime.GetValue(pos, startTimeValue)) { startTimeValue = NULL; }
         double highValueValue;
         if (!highValue.GetValue(pos, highValueValue)) { highValueValue = EMPTY_VALUE; }
         datetime endTimeValue;
         if (!endTime.GetValue(pos, endTimeValue)) { endTimeValue = NULL; }
         double lowValueValue;
         if (!lowValue.GetValue(pos, lowValueValue)) { lowValueValue = EMPTY_VALUE; }
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_11_id", startTimeValue, highValueValue, endTimeValue, lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
      }
      if (show_diagonals1)
      {
         datetime startTimeValue;
         if (!startTime.GetValue(pos, startTimeValue)) { startTimeValue = NULL; }
         double midValueValue;
         if (!midValue.GetValue(pos, midValueValue)) { midValueValue = EMPTY_VALUE; }
         datetime endTimeValue;
         if (!endTime.GetValue(pos, endTimeValue)) { endTimeValue = NULL; }
         double highValueValue;
         if (!highValue.GetValue(pos, highValueValue)) { highValueValue = EMPTY_VALUE; }
         Line* upperDiagonalLine = LinesCollection::Create(IndicatorObjPrefix + "line_12_id", startTimeValue, midValueValue, endTimeValue, highValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none");
         double lowValueValue;
         if (!lowValue.GetValue(pos, lowValueValue)) { lowValueValue = EMPTY_VALUE; }
         Line* lowerDiagonalLine = LinesCollection::Create(IndicatorObjPrefix + "line_13_id", startTimeValue, midValueValue, endTimeValue, lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none");
         SetStream(upperY, pos, Line::GetY1(upperDiagonalLine), upperY_DEFAULT_VALUE);
         SetStream(lowerY, pos, Line::GetY1(lowerDiagonalLine), lowerY_DEFAULT_VALUE);
         SetStream(upperY1, pos, Line::GetY2(upperDiagonalLine), upperY1_DEFAULT_VALUE);
         SetStream(lowerY1, pos, Line::GetX2(lowerDiagonalLine), lowerY1_DEFAULT_VALUE);
         SetStream(upperX, pos, Line::GetX1(upperDiagonalLine), upperX_DEFAULT_VALUE);
         SetStream(lowerX, pos, Line::GetX1(lowerDiagonalLine), lowerX_DEFAULT_VALUE);
         SetStream(upperX1, pos, Line::GetX2(upperDiagonalLine), upperX1_DEFAULT_VALUE);
         SetStream(lowerX1, pos, Line::GetX2(lowerDiagonalLine), lowerX1_DEFAULT_VALUE);
      }
      if (show_diagonals2)
      {
         datetime endTimeValue;
         if (!endTime.GetValue(pos, endTimeValue)) { endTimeValue = NULL; }
         double midValueValue;
         if (!midValue.GetValue(pos, midValueValue)) { midValueValue = EMPTY_VALUE; }
         datetime startTimeValue;
         if (!startTime.GetValue(pos, startTimeValue)) { startTimeValue = NULL; }
         double highValueValue;
         if (!highValue.GetValue(pos, highValueValue)) { highValueValue = EMPTY_VALUE; }
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_14_id", endTimeValue, midValueValue, startTimeValue, highValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
         double lowValueValue;
         if (!lowValue.GetValue(pos, lowValueValue)) { lowValueValue = EMPTY_VALUE; }
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_15_id", endTimeValue, midValueValue, startTimeValue, lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
      }
      if (show_midlines_type1)
      {
         datetime startTimeValue;
         if (!startTime.GetValue(pos, startTimeValue)) { startTimeValue = NULL; }
         datetime endTimeValue;
         if (!endTime.GetValue(pos, endTimeValue)) { endTimeValue = NULL; }
         double lowValueValue;
         if (!lowValue.GetValue(pos, lowValueValue)) { lowValueValue = EMPTY_VALUE; }
         double highValueValue;
         if (!highValue.GetValue(pos, highValueValue)) { highValueValue = EMPTY_VALUE; }
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_16_id", (startTimeValue + (SafeDivide((endTimeValue - startTimeValue), 2))), lowValueValue, endTimeValue, highValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_17_id", (startTimeValue + (SafeDivide((endTimeValue - startTimeValue), 2))), lowValueValue, startTimeValue, highValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
      }
      if (show_midlines_type2)
      {
         datetime startTimeValue;
         if (!startTime.GetValue(pos, startTimeValue)) { startTimeValue = NULL; }
         datetime endTimeValue;
         if (!endTime.GetValue(pos, endTimeValue)) { endTimeValue = NULL; }
         double highValueValue;
         if (!highValue.GetValue(pos, highValueValue)) { highValueValue = EMPTY_VALUE; }
         double lowValueValue;
         if (!lowValue.GetValue(pos, lowValueValue)) { lowValueValue = EMPTY_VALUE; }
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_18_id", (startTimeValue + (SafeDivide((endTimeValue - startTimeValue), 2))), highValueValue, endTimeValue, lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
         Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_19_id", (startTimeValue + (SafeDivide((endTimeValue - startTimeValue), 2))), highValueValue, startTimeValue, lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
      }
      if (quarter)
      {
         double highValueValue;
         if (!highValue.GetValue(pos, highValueValue)) { highValueValue = EMPTY_VALUE; }
         double lowValueValue;
         if (!lowValue.GetValue(pos, lowValueValue)) { lowValueValue = EMPTY_VALUE; }
         double sectionPriceInterval = (SafeDivide((highValueValue - lowValueValue), 4));
         datetime endTimeValue;
         if (!endTime.GetValue(pos, endTimeValue)) { endTimeValue = NULL; }
         datetime startTimeValue;
         if (!startTime.GetValue(pos, startTimeValue)) { startTimeValue = NULL; }
         double sectionTimeInterval = (SafeDivide((endTimeValue - startTimeValue), 4));
         int for5_from = 1;
         int for5_to = 3;
         bool for5_forward = for5_from <= for5_to;
         int for5_step = 1 * (for5_forward ? 1 : -1);
         if (for5_from == EMPTY_VALUE || for5_to == EMPTY_VALUE) { return false; }
         for (int i = for5_from; (for5_forward ? i <= for5_to : i >= for5_to); i += for5_step)
         {
            Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_20_id" + "_" + IntegerToString(i), startTimeValue, (lowValueValue + (sectionPriceInterval * i)), endTimeValue, (lowValueValue + (sectionPriceInterval * i)), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
            Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_21_id" + "_" + IntegerToString(i), (startTimeValue + (sectionTimeInterval * i)), highValueValue, (startTimeValue + (sectionTimeInterval * i)), lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
         }
         if (sixth)
         {
            sectionPriceInterval = (SafeDivide((highValueValue - lowValueValue), 6));
            sectionTimeInterval = (SafeDivide((endTimeValue - startTimeValue), 6));
            int for6_from = 1;
            int for6_to = 5;
            bool for6_forward = for6_from <= for6_to;
            int for6_step = 1 * (for6_forward ? 1 : -1);
            if (for6_from == EMPTY_VALUE || for6_to == EMPTY_VALUE) { return false; }
            for (int i = for6_from; (for6_forward ? i <= for6_to : i >= for6_to); i += for6_step)
            {
               Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_22_id" + "_" + IntegerToString(i), startTimeValue, (lowValueValue + (sectionPriceInterval * i)), endTimeValue, (lowValueValue + (sectionPriceInterval * i)), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
               Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_23_id" + "_" + IntegerToString(i), (startTimeValue + (sectionTimeInterval * i)), highValueValue, (startTimeValue + (sectionTimeInterval * i)), lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
            }
            if (eighth)
            {
               sectionPriceInterval = (SafeDivide((highValueValue - lowValueValue), 8));
               sectionTimeInterval = (SafeDivide((endTimeValue - startTimeValue), 8));
               int for7_from = 1;
               int for7_to = 7;
               bool for7_forward = for7_from <= for7_to;
               int for7_step = 1 * (for7_forward ? 1 : -1);
               if (for7_from == EMPTY_VALUE || for7_to == EMPTY_VALUE) { return false; }
               for (int i = for7_from; (for7_forward ? i <= for7_to : i >= for7_to); i += for7_step)
               {
                  Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_24_id" + "_" + IntegerToString(i), startTimeValue, (lowValueValue + (sectionPriceInterval * i)), endTimeValue, (lowValueValue + (sectionPriceInterval * i)), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
                  Array::Push<ILineArray*, Line*>(lines, LinesCollection::Create(IndicatorObjPrefix + "line_25_id" + "_" + IntegerToString(i), (startTimeValue + (sectionTimeInterval * i)), highValueValue, (startTimeValue + (sectionTimeInterval * i)), lowValueValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(insideLines).SetWidth(widthLines).SetStyle("dashed").SetExtend("none"));
               }
            }
         }
      }
      return true;
   }
};
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS7_param1;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS7_param2;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS7_param3;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS7_param4;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS7_param5;
drawSquares__datetimeS__datetimeS_fS_fS_fSStream* drawSquares__datetimeS__datetimeS_fS_fS_fS7;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS8_param1;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS8_param2;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS8_param3;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS8_param4;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS8_param5;
drawSquares__datetimeS__datetimeS_fS_fS_fSStream* drawSquares__datetimeS__datetimeS_fS_fS_fS8;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS9_param1;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS9_param2;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS9_param3;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS9_param4;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS9_param5;
drawSquares__datetimeS__datetimeS_fS_fS_fSStream* drawSquares__datetimeS__datetimeS_fS_fS_fS9;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS10_param1;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS10_param2;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS10_param3;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS10_param4;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS10_param5;
drawSquares__datetimeS__datetimeS_fS_fS_fSStream* drawSquares__datetimeS__datetimeS_fS_fS_fS10;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS11_param1;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS11_param2;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS11_param3;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS11_param4;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS11_param5;
drawSquares__datetimeS__datetimeS_fS_fS_fSStream* drawSquares__datetimeS__datetimeS_fS_fS_fS11;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS12_param1;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS12_param2;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS12_param3;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS12_param4;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS12_param5;
drawSquares__datetimeS__datetimeS_fS_fS_fSStream* drawSquares__datetimeS__datetimeS_fS_fS_fS12;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS13_param1;
DatetimeStream* drawSquares__datetimeS__datetimeS_fS_fS_fS13_param2;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS13_param3;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS13_param4;
FloatStream* drawSquares__datetimeS__datetimeS_fS_fS_fS13_param5;
drawSquares__datetimeS__datetimeS_fS_fS_fSStream* drawSquares__datetimeS__datetimeS_fS_fS_fS13;

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
   IndicatorBuffers(64);
   int id = 0;
   show_Buy = param1;
   show_Sell = param2;
   show_Sup = param3;
   show_Res = param4;
   show_Buy_lb = param5;
   show_Sell_lb = param6;
   show_Sup_lb = param7;
   show_Res_lb = param8;
   show_Signal_Buy = param9;
   show_Signal_Sell = param10;
   show_DO = param11;
   show_startHour = param12;
   show_endHour = param13;
   targetHour = param14;
   targetMinute = param15;
   SetIndexBuffer(id, plot1);
   SetIndexArrow(id, 217);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Gray, 0));
   targetHour1 = param16;
   targetMinute1 = param17;
   SetIndexBuffer(id, plot2);
   SetIndexArrow(id, 218);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Gray, 0));
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   show_squares = param18;
   show_diagonals1 = param19;
   show_diagonals2 = param20;
   show_midlines_type1 = param21;
   show_midlines_type2 = param22;
   show_insquare_type1 = param23;
   show_insquare_type2 = param24;
   quarter = param25;
   sixth = param26;
   eighth = param27;
   outsiteLines = param28;
   insideLines = param29;
   widthLines = param30;
   show_startHour_S = param31;
   show_endHour_S = param32;
   targetHour_S = param33;
   targetMinute_S = param34;
   SetIndexBuffer(id, plot3);
   SetIndexArrow(id, 217);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Gray, 0));
   targetHour_S1 = param35;
   targetMinute_S1 = param36;
   SetIndexBuffer(id, plot4);
   SetIndexArrow(id, 218);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Gray, 0));
   calculations_day_back = param37;
   LinesCollection::SetMaxLines(500);
   LabelsCollection::SetMaxLabels(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Gann Calculations");
   __array1 = new FloatArray(24, EMPTY_VALUE);
   __array2 = new FloatArray(24, EMPTY_VALUE);
   __array3 = new FloatArray(24, EMPTY_VALUE);
   __array4 = new FloatArray(24, EMPTY_VALUE);
   SetIndexBuffer(id++, buy_above);
   SetIndexBuffer(id++, sell_below);
   isTargetTime1 = new isTargetTimeStream();
   id = isTargetTime1.Init(id);
   isTargetTime12 = new isTargetTime1Stream();
   id = isTargetTime12.Init(id);
   isTargetTime_S3 = new isTargetTime_SStream();
   id = isTargetTime_S3.Init(id);
   isTargetTime_S14 = new isTargetTime_S1Stream();
   id = isTargetTime_S14.Init(id);
   __array5 = new LineArray(0, NULL);
   getHighestValue_iS_iS5_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getHighestValue_iS_iS5_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getHighestValue_iS_iS5 = new getHighestValue_iS_iSStream(getHighestValue_iS_iS5_param1, getHighestValue_iS_iS5_param2);
   id = getHighestValue_iS_iS5.Init(id);
   getLowestValue_iS_iS6_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getLowestValue_iS_iS6_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getLowestValue_iS_iS6 = new getLowestValue_iS_iSStream(getLowestValue_iS_iS6_param1, getLowestValue_iS_iS6_param2);
   id = getLowestValue_iS_iS6.Init(id);
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param1 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param2 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param5 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS7 = new drawSquares__datetimeS__datetimeS_fS_fS_fSStream(drawSquares__datetimeS__datetimeS_fS_fS_fS7_param1, drawSquares__datetimeS__datetimeS_fS_fS_fS7_param2, drawSquares__datetimeS__datetimeS_fS_fS_fS7_param3, drawSquares__datetimeS__datetimeS_fS_fS_fS7_param4, drawSquares__datetimeS__datetimeS_fS_fS_fS7_param5);
   id = drawSquares__datetimeS__datetimeS_fS_fS_fS7.Init(id);
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param1 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param2 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param5 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS8 = new drawSquares__datetimeS__datetimeS_fS_fS_fSStream(drawSquares__datetimeS__datetimeS_fS_fS_fS8_param1, drawSquares__datetimeS__datetimeS_fS_fS_fS8_param2, drawSquares__datetimeS__datetimeS_fS_fS_fS8_param3, drawSquares__datetimeS__datetimeS_fS_fS_fS8_param4, drawSquares__datetimeS__datetimeS_fS_fS_fS8_param5);
   id = drawSquares__datetimeS__datetimeS_fS_fS_fS8.Init(id);
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param1 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param2 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param5 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS9 = new drawSquares__datetimeS__datetimeS_fS_fS_fSStream(drawSquares__datetimeS__datetimeS_fS_fS_fS9_param1, drawSquares__datetimeS__datetimeS_fS_fS_fS9_param2, drawSquares__datetimeS__datetimeS_fS_fS_fS9_param3, drawSquares__datetimeS__datetimeS_fS_fS_fS9_param4, drawSquares__datetimeS__datetimeS_fS_fS_fS9_param5);
   id = drawSquares__datetimeS__datetimeS_fS_fS_fS9.Init(id);
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param1 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param2 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param5 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS10 = new drawSquares__datetimeS__datetimeS_fS_fS_fSStream(drawSquares__datetimeS__datetimeS_fS_fS_fS10_param1, drawSquares__datetimeS__datetimeS_fS_fS_fS10_param2, drawSquares__datetimeS__datetimeS_fS_fS_fS10_param3, drawSquares__datetimeS__datetimeS_fS_fS_fS10_param4, drawSquares__datetimeS__datetimeS_fS_fS_fS10_param5);
   id = drawSquares__datetimeS__datetimeS_fS_fS_fS10.Init(id);
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param1 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param2 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param5 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS11 = new drawSquares__datetimeS__datetimeS_fS_fS_fSStream(drawSquares__datetimeS__datetimeS_fS_fS_fS11_param1, drawSquares__datetimeS__datetimeS_fS_fS_fS11_param2, drawSquares__datetimeS__datetimeS_fS_fS_fS11_param3, drawSquares__datetimeS__datetimeS_fS_fS_fS11_param4, drawSquares__datetimeS__datetimeS_fS_fS_fS11_param5);
   id = drawSquares__datetimeS__datetimeS_fS_fS_fS11.Init(id);
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param1 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param2 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param5 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS12 = new drawSquares__datetimeS__datetimeS_fS_fS_fSStream(drawSquares__datetimeS__datetimeS_fS_fS_fS12_param1, drawSquares__datetimeS__datetimeS_fS_fS_fS12_param2, drawSquares__datetimeS__datetimeS_fS_fS_fS12_param3, drawSquares__datetimeS__datetimeS_fS_fS_fS12_param4, drawSquares__datetimeS__datetimeS_fS_fS_fS12_param5);
   id = drawSquares__datetimeS__datetimeS_fS_fS_fS12.Init(id);
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param1 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param2 = new DatetimeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param5 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   drawSquares__datetimeS__datetimeS_fS_fS_fS13 = new drawSquares__datetimeS__datetimeS_fS_fS_fSStream(drawSquares__datetimeS__datetimeS_fS_fS_fS13_param1, drawSquares__datetimeS__datetimeS_fS_fS_fS13_param2, drawSquares__datetimeS__datetimeS_fS_fS_fS13_param3, drawSquares__datetimeS__datetimeS_fS_fS_fS13_param4, drawSquares__datetimeS__datetimeS_fS_fS_fS13_param5);
   id = drawSquares__datetimeS__datetimeS_fS_fS_fS13.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete __array1;
   delete __array2;
   delete __array3;
   delete __array4;
   delete isTargetTime1;
   delete isTargetTime12;
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   delete isTargetTime_S3;
   delete isTargetTime_S14;
   delete __array5;
   getHighestValue_iS_iS5_param1.Release();
   getHighestValue_iS_iS5_param2.Release();
   delete getHighestValue_iS_iS5;
   getLowestValue_iS_iS6_param1.Release();
   getLowestValue_iS_iS6_param2.Release();
   delete getLowestValue_iS_iS6;
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param1.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param2.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param3.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param4.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS7_param5.Release();
   delete drawSquares__datetimeS__datetimeS_fS_fS_fS7;
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param1.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param2.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param3.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param4.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS8_param5.Release();
   delete drawSquares__datetimeS__datetimeS_fS_fS_fS8;
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param1.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param2.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param3.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param4.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS9_param5.Release();
   delete drawSquares__datetimeS__datetimeS_fS_fS_fS9;
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param1.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param2.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param3.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param4.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS10_param5.Release();
   delete drawSquares__datetimeS__datetimeS_fS_fS_fS10;
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param1.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param2.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param3.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param4.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS11_param5.Release();
   delete drawSquares__datetimeS__datetimeS_fS_fS_fS11;
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param1.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param2.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param3.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param4.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS12_param5.Release();
   delete drawSquares__datetimeS__datetimeS_fS_fS_fS12;
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param1.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param2.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param3.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param4.Release();
   drawSquares__datetimeS__datetimeS_fS_fS_fS13_param5.Release();
   delete drawSquares__datetimeS__datetimeS_fS_fS_fS13;
   LinesCollection::Clear(true);
   LabelsCollection::Clear(true);
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
      LinesCollection::Clear();
      LabelsCollection::Clear();
      open_price_line = NULL;
      buyLine = NULL;
      sellLine = NULL;
      buyLabel = NULL;
      sellLabel = NULL;
      x = __array1.Clear();
      sqr_x = __array2.Clear();
      sqr_x_rounded = __array3.Clear();
      sqr_x_rounded_root = __array4.Clear();
      buy_above_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(buy_above, buy_above_DEFAULT_VALUE);
      sell_below_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(sell_below, sell_below_DEFAULT_VALUE);
      buySignalLabel = NULL;
      sellSignalLabel = NULL;
      ArrayInitialize(plot1, EMPTY_VALUE);
      isTargetTime1.Clear();
      ArrayInitialize(plot2, EMPTY_VALUE);
      isTargetTime12.Clear();
      crossover1X.Init();
      crossover1Y.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      supportLine = NULL;
      resistanceLine = NULL;
      supportLabel = NULL;
      resistanceLabel = NULL;
      ArrayInitialize(plot3, EMPTY_VALUE);
      isTargetTime_S3.Clear();
      ArrayInitialize(plot4, EMPTY_VALUE);
      isTargetTime_S14.Clear();
      lines = __array5.Clear();
      getHighestValue_iS_iS5_param1.Init();
      getHighestValue_iS_iS5_param2.Init();
      getHighestValue_iS_iS5.Clear();
      getLowestValue_iS_iS6_param1.Init();
      getLowestValue_iS_iS6_param2.Init();
      getLowestValue_iS_iS6.Clear();
      drawSquares__datetimeS__datetimeS_fS_fS_fS7_param1.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS7_param2.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS7_param3.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS7_param4.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS7_param5.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS7.Clear();
      drawSquares__datetimeS__datetimeS_fS_fS_fS8_param1.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS8_param2.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS8_param3.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS8_param4.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS8_param5.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS8.Clear();
      drawSquares__datetimeS__datetimeS_fS_fS_fS9_param1.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS9_param2.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS9_param3.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS9_param4.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS9_param5.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS9.Clear();
      drawSquares__datetimeS__datetimeS_fS_fS_fS10_param1.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS10_param2.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS10_param3.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS10_param4.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS10_param5.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS10.Clear();
      drawSquares__datetimeS__datetimeS_fS_fS_fS11_param1.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS11_param2.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS11_param3.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS11_param4.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS11_param5.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS11.Clear();
      drawSquares__datetimeS__datetimeS_fS_fS_fS12_param1.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS12_param2.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS12_param3.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS12_param4.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS12_param5.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS12.Clear();
      drawSquares__datetimeS__datetimeS_fS_fS_fS13_param1.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS13_param2.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS13_param3.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS13_param4.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS13_param5.Init();
      drawSquares__datetimeS__datetimeS_fS_fS_fS13.Clear();
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
      buy_above[pos] = pos < (rates_total - 1) ? buy_above[pos + 1] : EMPTY_VALUE;
      sell_below[pos] = pos < (rates_total - 1) ? sell_below[pos + 1] : EMPTY_VALUE;
      int is_new_day = Timeframe::Change("D", pos);
      if ((is_new_day))
      {
         LinesCollection::Delete(open_price_line);
         LinesCollection::Delete(buyLine);
         LinesCollection::Delete(sellLine);
         open_price_line = LinesCollection::Create(IndicatorObjPrefix + "line_1_id", INT_MIN, INT_MIN, INT_MIN, INT_MIN, time[pos]).SetColor(White).SetWidth(1).SetStyle("dashed").SetExtend("none");
         Line::SetXY1(open_price_line, ((rates_total - 1) - pos), open[pos]);
         Line::SetXY2(open_price_line, ((rates_total - 1) - pos) + 1, open[pos]);
      }
      else
      {
         if (show_DO)
         {
            Line::SetX2(open_price_line, ((rates_total - 1) - pos));
         }
      }
      double num = Line::GetY1(open_price_line);
      double root = SafeMathSqrt(num);
      double minus_two = SafeMinus(root, 2);
      int rounded = SafeMathRound(minus_two);
      double result = SafeMathPow(rounded, 2);
      int for1_from = 0;
      int for1_to = 23;
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { continue; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         Array::Set<IFloatArray*, int, double>(x, i, SafePlus(rounded, 0.125 * (i + 1)));
         Array::Set<IFloatArray*, int, double>(sqr_x, i, SafeMultiply(Array::Get<double, IFloatArray*, int>(x, i, EMPTY_VALUE), Array::Get<double, IFloatArray*, int>(x, i, EMPTY_VALUE)));
         Array::Set<IFloatArray*, int, double>(sqr_x_rounded, i, SafeDivide(SafeMathRound(SafeMultiply(Array::Get<double, IFloatArray*, int>(sqr_x, i, EMPTY_VALUE), 100)), 100));
         Array::Set<IFloatArray*, int, double>(sqr_x_rounded_root, i, SafeDivide(SafeMathRound(SafeMultiply((SafeMinus(num, Array::Get<double, IFloatArray*, int>(sqr_x_rounded, i, EMPTY_VALUE))), 100)), 100));
      }
      int min_positive_index = (-1);
      int for2_from = 0;
      int for2_to = 23;
      bool for2_forward = for2_from <= for2_to;
      int for2_step = 1 * (for2_forward ? 1 : -1);
      if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { continue; }
      for (int i = for2_from; (for2_forward ? i <= for2_to : i >= for2_to); i += for2_step)
      {
         if (SafeLess(Array::Get<double, IFloatArray*, int>(sqr_x_rounded_root, i, EMPTY_VALUE), 0))
         {
            min_positive_index = i;
            break;
         }
      }
      if ((min_positive_index >= 0))
      {
         SetStream(buy_above, pos, Array::Get<double, IFloatArray*, int>(sqr_x_rounded, min_positive_index, EMPTY_VALUE), buy_above_DEFAULT_VALUE);
         SetStream(sell_below, pos, Array::Get<double, IFloatArray*, int>(sqr_x_rounded, min_positive_index - 1, EMPTY_VALUE), sell_below_DEFAULT_VALUE);
      }
      LinesCollection::Delete(buyLine);
      LinesCollection::Delete(sellLine);
      if ((min_positive_index >= 0) && show_Buy)
      {
         buyLine = LinesCollection::Create(IndicatorObjPrefix + "line_2_id", INT_MIN, INT_MIN, INT_MIN, INT_MIN, time[pos]).SetColor(Aqua).SetWidth(1).SetStyle("solid").SetExtend("none");
         Line::SetXY1(buyLine, ((rates_total - 1) - pos), buy_above[pos]);
         Line::SetXY2(buyLine, Line::GetX1(open_price_line), buy_above[pos]);
      }
      if ((min_positive_index >= 0) && show_Sell)
      {
         sellLine = LinesCollection::Create(IndicatorObjPrefix + "line_3_id", INT_MIN, INT_MIN, INT_MIN, INT_MIN, time[pos]).SetColor(Yellow).SetWidth(1).SetStyle("solid").SetExtend("none");
         Line::SetXY1(sellLine, ((rates_total - 1) - pos), sell_below[pos]);
         Line::SetXY2(sellLine, Line::GetX1(open_price_line), sell_below[pos]);
      }
      LabelsCollection::Delete(buyLabel);
      LabelsCollection::Delete(sellLabel);
      buyLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", INT_MIN, EMPTY_VALUE, time[pos]).SetText("").SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      sellLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", INT_MIN, EMPTY_VALUE, time[pos]).SetText("").SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      double buyLineValues = Line::GetY1(buyLine);
      double sellLineValues = Line::GetY1(sellLine);
      if (show_Buy_lb)
      {
         Label::SetText(buyLabel, SafePlus("BUY: ", Str::ToString(buyLineValues)));
         Label::SetTextColor(buyLabel, Black);
         Label::SetColor(buyLabel, AddTransparency(Aqua, 0));
         Label::SetXY(buyLabel, SafeMinus(Line::GetX1(open_price_line), 1), Line::GetY1(buyLine));
         Label::SetStyle(buyLabel, "right");
      }
      if (show_Sell_lb)
      {
         Label::SetText(sellLabel, SafePlus("SELL: ", Str::ToString(sellLineValues)));
         Label::SetTextColor(sellLabel, Black);
         Label::SetColor(sellLabel, AddTransparency(Yellow, 0));
         Label::SetXY(sellLabel, SafeMinus(Line::GetX1(open_price_line), 1), Line::GetY1(sellLine));
         Label::SetStyle(sellLabel, "right");
      }
      int isTargetTime1Value;
      if (!isTargetTime1.GetValue(pos, isTargetTime1Value)) { isTargetTime1Value = (-1); }
      PlotShape::SetBool(plot1, pos, "bottom", (isTargetTime1Value ? show_startHour : (-1)), high, low, 0);
      int isTargetTime12Value;
      if (!isTargetTime12.GetValue(pos, isTargetTime12Value)) { isTargetTime12Value = (-1); }
      PlotShape::SetBool(plot2, pos, "bottom", (isTargetTime12Value ? show_endHour : (-1)), high, low, 0);
      int isWithinTimeRange = (PineScriptTime::Hour(time[pos]) >= targetHour) && (PineScriptTime::Hour(time[pos]) <= targetHour1);
      crossover1X.SetValue(pos, close[pos]);
      crossover1Y.SetValue(pos, buy_above[pos]);
      int crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { crossover1Value = (-1); }
      if (show_Signal_Buy && crossover1Value && (SafeGreater(close[pos], buy_above[pos])) && isWithinTimeRange)
      {
         buySignalLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", ((rates_total - 1) - pos), close[pos], time[pos]).SetColor(Aqua).SetText("").SetTextColor(White).SetStyle("down").SetSize("tiny").SetYLoc("price").SetTextAlign("center");
      }
      crossunder1X.SetValue(pos, close[pos]);
      crossunder1Y.SetValue(pos, sell_below[pos]);
      int crossunder1Value;
      if (!crossunder1.GetValue(pos, crossunder1Value)) { crossunder1Value = (-1); }
      if (show_Signal_Sell && crossunder1Value && (SafeLess(close[pos], sell_below[pos])) && isWithinTimeRange)
      {
         sellSignalLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_4_id", ((rates_total - 1) - pos), close[pos], time[pos]).SetColor(Yellow).SetText("").SetTextColor(White).SetStyle("up").SetSize("tiny").SetYLoc("price").SetTextAlign("center");
      }
      LinesCollection::Delete(supportLine);
      LinesCollection::Delete(resistanceLine);
      if ((min_positive_index >= 0) && show_Sup)
      {
         double firstSupport = Array::Get<double, IFloatArray*, int>(sqr_x_rounded, min_positive_index - 2, EMPTY_VALUE);
         supportLine = LinesCollection::Create(IndicatorObjPrefix + "line_4_id", INT_MIN, INT_MIN, INT_MIN, INT_MIN, time[pos]).SetColor(Yellow).SetWidth(1).SetStyle("solid").SetExtend("none");
         Line::SetXY1(supportLine, ((rates_total - 1) - pos), firstSupport);
         Line::SetXY2(supportLine, Line::GetX1(open_price_line), firstSupport);
      }
      if ((min_positive_index >= 0) && show_Res)
      {
         double firstResistance = Array::Get<double, IFloatArray*, int>(sqr_x_rounded, min_positive_index + 1, EMPTY_VALUE);
         resistanceLine = LinesCollection::Create(IndicatorObjPrefix + "line_5_id", INT_MIN, INT_MIN, INT_MIN, INT_MIN, time[pos]).SetColor(Aqua).SetWidth(1).SetStyle("solid").SetExtend("none");
         Line::SetXY1(resistanceLine, ((rates_total - 1) - pos), firstResistance);
         Line::SetXY2(resistanceLine, Line::GetX1(open_price_line), firstResistance);
      }
      LabelsCollection::Delete(supportLabel);
      LabelsCollection::Delete(resistanceLabel);
      supportLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_5_id", INT_MIN, EMPTY_VALUE, time[pos]).SetText("").SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      resistanceLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_6_id", INT_MIN, EMPTY_VALUE, time[pos]).SetText("").SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      double supportLineValues = Line::GetY1(supportLine);
      double resistanceLineValues = Line::GetY1(resistanceLine);
      if (show_Sup_lb)
      {
         Label::SetText(supportLabel, SafePlus("S: ", Str::ToString(supportLineValues)));
         Label::SetTextColor(supportLabel, Black);
         Label::SetColor(supportLabel, AddTransparency(Yellow, 0));
         Label::SetXY(supportLabel, SafeMinus(Line::GetX1(open_price_line), 1), Line::GetY1(supportLine));
         Label::SetStyle(supportLabel, "right");
      }
      if (show_Res_lb)
      {
         Label::SetText(resistanceLabel, SafePlus("R: ", Str::ToString(resistanceLineValues)));
         Label::SetTextColor(resistanceLabel, Black);
         Label::SetColor(resistanceLabel, AddTransparency(Aqua, 0));
         Label::SetXY(resistanceLabel, SafeMinus(Line::GetX1(open_price_line), 1), Line::GetY1(resistanceLine));
         Label::SetStyle(resistanceLabel, "right");
      }
      int isTargetTime_S3Value;
      if (!isTargetTime_S3.GetValue(pos, isTargetTime_S3Value)) { isTargetTime_S3Value = (-1); }
      PlotShape::SetBool(plot3, pos, "bottom", (isTargetTime_S3Value ? show_startHour_S : (-1)), high, low, 0);
      int isTargetTime_S14Value;
      if (!isTargetTime_S14.GetValue(pos, isTargetTime_S14Value)) { isTargetTime_S14Value = (-1); }
      PlotShape::SetBool(plot4, pos, "bottom", (isTargetTime_S14Value ? show_endHour_S : (-1)), high, low, 0);
      datetime start = Timestamp(PineScriptTime::Year(time[pos]), PineScriptTime::Month(time[pos]), PineScriptTime::DayOfMonth(time[pos]) - calculations_day_back, targetHour_S, targetMinute_S, 0);
      datetime end = Timestamp(PineScriptTime::Year(time[pos]), PineScriptTime::Month(time[pos]), PineScriptTime::DayOfMonth(time[pos]) - calculations_day_back, targetHour_S1, targetMinute_S1, 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int barsFromStart = SafeDivide((SafeMinus(time[pos], start)), (SafeMinus(time[pos], time[pos + 1])));
      if (pos + 1 > (rates_total - 1)) { continue; }
      int barsFromEnd = SafeDivide((SafeMinus(time[pos], end)), (SafeMinus(time[pos], time[pos + 1])));
      int bars = SafeMinus(barsFromStart, barsFromEnd);
      if ((pos == 0))
      {
         getHighestValue_iS_iS5_param1.SetValue(pos, bars);
         getHighestValue_iS_iS5_param2.SetValue(pos, barsFromStart);
         double getHighestValue_iS_iS5Value;
         if (!getHighestValue_iS_iS5.GetValue(pos, getHighestValue_iS_iS5Value)) { getHighestValue_iS_iS5Value = EMPTY_VALUE; }
         double highestValuePrincipal = getHighestValue_iS_iS5Value;
         getLowestValue_iS_iS6_param1.SetValue(pos, bars);
         getLowestValue_iS_iS6_param2.SetValue(pos, barsFromStart);
         double getLowestValue_iS_iS6Value;
         if (!getLowestValue_iS_iS6.GetValue(pos, getLowestValue_iS_iS6Value)) { getLowestValue_iS_iS6Value = EMPTY_VALUE; }
         double lowestValuePrincipal = getLowestValue_iS_iS6Value;
         double midValuePrincipal = SafePlus(lowestValuePrincipal, (SafeDivide((SafeMinus(highestValuePrincipal, lowestValuePrincipal)), 2)));
         datetime intervalTime = SafeMinus(end, start);
         drawSquares__datetimeS__datetimeS_fS_fS_fS7_param1.SetValue(pos, start);
         drawSquares__datetimeS__datetimeS_fS_fS_fS7_param2.SetValue(pos, end);
         drawSquares__datetimeS__datetimeS_fS_fS_fS7_param3.SetValue(pos, highestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS7_param4.SetValue(pos, lowestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS7_param5.SetValue(pos, midValuePrincipal);
         if (!drawSquares__datetimeS__datetimeS_fS_fS_fS7.GetValue(pos)) { }
         drawSquares__datetimeS__datetimeS_fS_fS_fS8_param1.SetValue(pos, end);
         drawSquares__datetimeS__datetimeS_fS_fS_fS8_param2.SetValue(pos, (SafePlus(end, intervalTime)));
         drawSquares__datetimeS__datetimeS_fS_fS_fS8_param3.SetValue(pos, highestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS8_param4.SetValue(pos, lowestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS8_param5.SetValue(pos, midValuePrincipal);
         if (!drawSquares__datetimeS__datetimeS_fS_fS_fS8.GetValue(pos)) { }
         drawSquares__datetimeS__datetimeS_fS_fS_fS9_param1.SetValue(pos, end);
         drawSquares__datetimeS__datetimeS_fS_fS_fS9_param2.SetValue(pos, (SafePlus(end, intervalTime)));
         drawSquares__datetimeS__datetimeS_fS_fS_fS9_param3.SetValue(pos, (SafePlus(highestValuePrincipal, (SafeMinus(highestValuePrincipal, lowestValuePrincipal)))));
         drawSquares__datetimeS__datetimeS_fS_fS_fS9_param4.SetValue(pos, highestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS9_param5.SetValue(pos, (SafePlus(midValuePrincipal, (SafeMinus(highestValuePrincipal, lowestValuePrincipal)))));
         if (!drawSquares__datetimeS__datetimeS_fS_fS_fS9.GetValue(pos)) { }
         drawSquares__datetimeS__datetimeS_fS_fS_fS10_param1.SetValue(pos, end);
         drawSquares__datetimeS__datetimeS_fS_fS_fS10_param2.SetValue(pos, (SafePlus(end, intervalTime)));
         drawSquares__datetimeS__datetimeS_fS_fS_fS10_param3.SetValue(pos, lowestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS10_param4.SetValue(pos, SafeMinus(lowestValuePrincipal, (SafeMinus(highestValuePrincipal, lowestValuePrincipal))));
         drawSquares__datetimeS__datetimeS_fS_fS_fS10_param5.SetValue(pos, (SafeMinus(midValuePrincipal, (SafeMinus(highestValuePrincipal, lowestValuePrincipal)))));
         if (!drawSquares__datetimeS__datetimeS_fS_fS_fS10.GetValue(pos)) { }
         drawSquares__datetimeS__datetimeS_fS_fS_fS11_param1.SetValue(pos, (SafePlus(end, intervalTime)));
         drawSquares__datetimeS__datetimeS_fS_fS_fS11_param2.SetValue(pos, (SafePlus(end, (SafeMultiply(intervalTime, 2)))));
         drawSquares__datetimeS__datetimeS_fS_fS_fS11_param3.SetValue(pos, highestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS11_param4.SetValue(pos, lowestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS11_param5.SetValue(pos, midValuePrincipal);
         if (!drawSquares__datetimeS__datetimeS_fS_fS_fS11.GetValue(pos)) { }
         drawSquares__datetimeS__datetimeS_fS_fS_fS12_param1.SetValue(pos, (SafePlus(end, intervalTime)));
         drawSquares__datetimeS__datetimeS_fS_fS_fS12_param2.SetValue(pos, (SafePlus(end, (SafeMultiply(intervalTime, 2)))));
         drawSquares__datetimeS__datetimeS_fS_fS_fS12_param3.SetValue(pos, (SafePlus(highestValuePrincipal, (SafeMinus(highestValuePrincipal, lowestValuePrincipal)))));
         drawSquares__datetimeS__datetimeS_fS_fS_fS12_param4.SetValue(pos, highestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS12_param5.SetValue(pos, (SafePlus(midValuePrincipal, (SafeMinus(highestValuePrincipal, lowestValuePrincipal)))));
         if (!drawSquares__datetimeS__datetimeS_fS_fS_fS12.GetValue(pos)) { }
         drawSquares__datetimeS__datetimeS_fS_fS_fS13_param1.SetValue(pos, (SafePlus(end, intervalTime)));
         drawSquares__datetimeS__datetimeS_fS_fS_fS13_param2.SetValue(pos, (SafePlus(end, (SafeMultiply(intervalTime, 2)))));
         drawSquares__datetimeS__datetimeS_fS_fS_fS13_param3.SetValue(pos, lowestValuePrincipal);
         drawSquares__datetimeS__datetimeS_fS_fS_fS13_param4.SetValue(pos, SafeMinus(lowestValuePrincipal, (SafeMinus(highestValuePrincipal, lowestValuePrincipal))));
         drawSquares__datetimeS__datetimeS_fS_fS_fS13_param5.SetValue(pos, (SafeMinus(midValuePrincipal, (SafeMinus(highestValuePrincipal, lowestValuePrincipal)))));
         if (!drawSquares__datetimeS__datetimeS_fS_fS_fS13.GetValue(pos)) { }
      }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LinesCollection::Redraw();
   LabelsCollection::Redraw();
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75810

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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