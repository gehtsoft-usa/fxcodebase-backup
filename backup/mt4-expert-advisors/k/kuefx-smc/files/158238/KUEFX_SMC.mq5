//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75600

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
#property indicator_buffers 33
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_CANDLES

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
// Candles stream v.1.0
class CandleStreams
{
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];
   double ColorIndex[];
   color colors[];
   int streamIndex;
public:
   CandleStreams(int streamIndex)
   {
      this.streamIndex = streamIndex;
   }
   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
      ArrayInitialize(ColorIndex, 0);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
      ColorIndex[index] = 0;
   }
   
   void AddColor(color clr)
   {
      int size = ArraySize(colors);
      ArrayResize(colors, size + 1);
      colors[size] = clr;
   }

   int RegisterStreams(const int id)
   {
      SetIndexBuffer(id, OpenStream, INDICATOR_DATA);
      SetIndexBuffer(id + 1, HighStream, INDICATOR_DATA);
      SetIndexBuffer(id + 2, LowStream, INDICATOR_DATA);
      SetIndexBuffer(id + 3, CloseStream, INDICATOR_DATA);
      SetIndexBuffer(id + 4, ColorIndex, INDICATOR_COLOR_INDEX);
      int size = ArraySize(colors);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, size);
      for (int i = 0; i < size; ++i)
      {
         PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, i, colors[i]);
      }
      return id + 5;
   }
   
   void Set(const int index, const double open, const double high, const double low, const double close, color clr)
   {
      if (clr == (color)EMPTY_VALUE)
      {
         return;
      }
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
      ColorIndex[index] = FindColor(clr);
   }
   
   void SetOffset(int offset)
   {
   }
private:
   int FindColor(color clr)
   {
      int size = ArraySize(colors);
      for (int i = 0; i < size; ++i)
      {
         if (colors[i] == clr)
         {
            return i;
         }
      }
      return 0;
   }
};
// Collection of lines v1.2

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL

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
// Collection of labels v1.2

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

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
         ObjectSetString(0, _labelId, OBJPROP_FONT, "Arial");
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
input bool param1 = 0; // Use equal H/L
input bool param2 = 1; // Mark H/L
input color param3 = ColorRGB(0, 0, 0, 0); // H/L color
input bool param4 = 0; // Mark out internal structure
input color param5 = ColorRGB(255, 82, 82, 0); // High pivots
input color param6 = Green; // Low pivots
input bool param7 = 1; // Mark BoS/ChoCH
input color param8 = Green; // Bull color
input color param9 = Red; // Bear color
input bool param10 = 0; // Bar color
input bool param11 = 1; // Show SCOB pattern
input color param12 = Aqua; // Bullish SCOB
input color param13 = Fuchsia; // Bearish SCOB
input bool param14 = 1; // Mark previous IDM
input bool param15 = 1; // Mark live IDM
input color param16 = ColorRGB(21, 6, 230, 0); // IDM color
input bool param17 = 1; // Show H/L sweeping lines
input bool param18 = 1; // Mark "X"
input color param19 = White; // Sweeping line color
input int bars_limit = 1000; // Bars limit
double mnUp[];
double mnUp_DEFAULT_VALUE;
double mnDn[];
double mnDn_DEFAULT_VALUE;
double top[];
double top_DEFAULT_VALUE;
double bot[];
double bot_DEFAULT_VALUE;
double puUp[];
double puUp_DEFAULT_VALUE;
double puDn[];
double puDn_DEFAULT_VALUE;
double L[];
double L_DEFAULT_VALUE;
double H[];
double H_DEFAULT_VALUE;
double idmB[];
double idmB_DEFAULT_VALUE;
double idmS[];
double idmS_DEFAULT_VALUE;
double lastH[];
double lastH_DEFAULT_VALUE;
double lastL[];
double lastL_DEFAULT_VALUE;
double lastHH[];
double lastHH_DEFAULT_VALUE;
double lastLL[];
double lastLL_DEFAULT_VALUE;
double puUpbar[];
double puUpbar_DEFAULT_VALUE;
double puDnbar[];
double puDnbar_DEFAULT_VALUE;
double idmB_bar[];
double idmB_bar_DEFAULT_VALUE;
double idmS_bar[];
double idmS_bar_DEFAULT_VALUE;
double Hbar[];
double Hbar_DEFAULT_VALUE;
double Lbar[];
double Lbar_DEFAULT_VALUE;
double lastHbar[];
double lastHbar_DEFAULT_VALUE;
double lastLbar[];
double lastLbar_DEFAULT_VALUE;
double lastHHbar[];
double lastHHbar_DEFAULT_VALUE;
double lastLLbar[];
double lastLLbar_DEFAULT_VALUE;
double isBosUp[];
double isBosUp_DEFAULT_VALUE;
double isBosDn[];
double isBosDn_DEFAULT_VALUE;
double isCocUp[];
double isCocUp_DEFAULT_VALUE;
double isCocDn[];
double isCocDn_DEFAULT_VALUE;
uint transp;
int equalHL;
int showHL;
uint HLcolor;
int showMn;
uint puUpco;
uint puDnco;
int showBC;
uint bull;
uint bear;
int showbarcolor;
int showSCOB;
uint scobUp;
uint scobDn;
int showIDM;
int showliveIDM;
uint idmColor;
Label* lv_lbl;
Line* lv_line;
int showSw;
int markX;
uint swColor;
int maxlen;
CandleStreams* barcolor1;
class IDM_iStream
{
   int BS;
   bool _initialized;
public:
   IDM_iStream(int BS)
   {
      _initialized = false;
      this.BS = BS;
   }
   ~IDM_iStream()
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
      int IDMid = (NumberToBool(BS) ? idmB_bar[pos] : idmS_bar[pos]);
      double idmprc = (NumberToBool(BS) ? idmB[pos] : idmS[pos]);
      string idmStyle = (NumberToBool(BS) ? "up" : "down");
      IDMid = (SafeLess(IDMid, maxlen) ? maxlen : IDMid);
      if (showIDM)
      {
         LinesCollection::Create(IndicatorObjPrefix + "line_1_id", IDMid, idmprc, pos, idmprc, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(idmColor).SetWidth(1).SetStyle("dotted");
         __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", (int)(SafeDivide((SafePlus(pos, IDMid)), 2)), idmprc, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(transp).SetText("IDM").SetTextColor(idmColor).SetStyle(idmStyle).SetSize("small").SetYLoc("price").SetTextAlign("center");
      }
      return true;
   }
};
IDM_iStream* IDM_i1;
class cfHL_iStream
{
   int ifHL;
   bool _initialized;
public:
   cfHL_iStream(int ifHL)
   {
      _initialized = false;
      this.ifHL = ifHL;
   }
   ~cfHL_iStream()
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
      int switch1Value1 = INT_MIN;
      double switch1Value2 = EMPTY_VALUE;
      if (NumberToBool(ifHL))
      {
         if ((iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos) > H[pos]))
         {
            switch1Value1 = pos;
            switch1Value2 = iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos);
         }
         else
         {
            switch1Value1 = Hbar[pos];
            switch1Value2 = H[pos];
         }
      }
      else
      {
         if ((iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos) < L[pos]))
         {
            switch1Value1 = pos;
            switch1Value2 = iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos);
         }
         else
         {
            switch1Value1 = Lbar[pos];
            switch1Value2 = L[pos];
         }
      }
      int ifHLbarid = switch1Value1;
      double HLprc = switch1Value2;
      string ifHL_txt = NULL;
      if (NumberToBool(ifHL))
      {
         if ((H[pos] == lastHH[pos]))
         {
            ifHL_txt = "HH";
         }
         else
         {
            ifHL_txt = "LH";
         }
      }
      else
      {
         if ((L[pos] == lastLL[pos]))
         {
            ifHL_txt = "LL";
         }
         else
         {
            ifHL_txt = "HL";
         }
      }
      string cfHLStyle = (NumberToBool(ifHL) ? "down" : "up");
      if (showHL)
      {
         __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", ifHLbarid, HLprc, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(transp).SetText(ifHL_txt).SetTextColor(HLcolor).SetStyle(cfHLStyle).SetSize("normal").SetYLoc("price").SetTextAlign("center");
      }
      return true;
   }
};
cfHL_iStream* cfHL_i2;
cfHL_iStream* cfHL_i3;
class BoS_ChoCh_i_iStream
{
   int B_C;
   int UpDn;
   bool _initialized;
public:
   BoS_ChoCh_i_iStream(int B_C, int UpDn)
   {
      _initialized = false;
      this.B_C = B_C;
      this.UpDn = UpDn;
   }
   ~BoS_ChoCh_i_iStream()
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
      int switch2Value1 = INT_MIN;
      double switch2Value2 = EMPTY_VALUE;
      uint switch2Value3 = INT_MAX;
      string switch2Value4 = NULL;
      string switch2Value5 = NULL;
      if ((B_C == 1) && (UpDn == 1))
      {
         switch2Value1 = lastHHbar[pos];
         switch2Value2 = lastHH[pos];
         switch2Value3 = bull;
         switch2Value4 = "BoS";
         switch2Value5 = "down";
      }
      else if ((B_C == 0) && (UpDn == 1))
      {
         switch2Value1 = lastHbar[pos];
         switch2Value2 = lastH[pos];
         switch2Value3 = bull;
         switch2Value4 = "ChoCh";
         switch2Value5 = "down";
      }
      else if ((B_C == 0) && (UpDn == 0))
      {
         switch2Value1 = lastLbar[pos];
         switch2Value2 = lastL[pos];
         switch2Value3 = bear;
         switch2Value4 = "ChoCh";
         switch2Value5 = "up";
      }
      else if ((B_C == 1) && (UpDn == 0))
      {
         switch2Value1 = lastLLbar[pos];
         switch2Value2 = lastLL[pos];
         switch2Value3 = bear;
         switch2Value4 = "BoS";
         switch2Value5 = "up";
      }
      int HLbarid = switch2Value1;
      double BCprc = switch2Value2;
      uint BCcolor = switch2Value3;
      string BCtxt = switch2Value4;
      string BCstyle = switch2Value5;
      if (showBC)
      {
         LinesCollection::Create(IndicatorObjPrefix + "line_2_id", HLbarid, BCprc, pos, BCprc, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(BCcolor).SetWidth(1).SetStyle("dashed");
         __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", (int)(SafeDivide((pos + HLbarid), 2)), BCprc, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(transp).SetText(BCtxt).SetTextColor(BCcolor).SetStyle(BCstyle).SetSize("normal").SetYLoc("price").SetTextAlign("center");
      }
      return true;
   }
};
BoS_ChoCh_i_iStream* BoS_ChoCh_i_i4;
class sweep_i_iStream
{
   int swHL;
   int swHrLr;
   bool _initialized;
public:
   sweep_i_iStream(int swHL, int swHrLr)
   {
      _initialized = false;
      this.swHL = swHL;
      this.swHrLr = swHrLr;
   }
   ~sweep_i_iStream()
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
      string swStyle = (NumberToBool(swHL) ? "down" : "up");
      int switch3Value1 = INT_MIN;
      double switch3Value2 = EMPTY_VALUE;
      string switch3Value3 = NULL;
      if ((swHL == 1) && (swHrLr == 1))
      {
         switch3Value1 = lastHHbar[pos];
         switch3Value2 = lastHH[pos];
         switch3Value3 = "HH";
      }
      else if ((swHL == 1) && (swHrLr == 0))
      {
         switch3Value1 = lastHbar[pos];
         switch3Value2 = lastH[pos];
         switch3Value3 = "LH";
      }
      else if ((swHL == 0) && (swHrLr == 1))
      {
         switch3Value1 = lastLbar[pos];
         switch3Value2 = lastL[pos];
         switch3Value3 = "HL";
      }
      else if ((swHL == 0) && (swHrLr == 0))
      {
         switch3Value1 = lastLLbar[pos];
         switch3Value2 = lastLL[pos];
         switch3Value3 = "LL";
      }
      int swHLbarid = switch3Value1;
      double swprc = switch3Value2;
      string swHL_txt = switch3Value3;
      if (showSw)
      {
         LinesCollection::Create(IndicatorObjPrefix + "line_3_id", swHLbarid, swprc, pos, swprc, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(swColor).SetWidth(1).SetStyle("dotted");
         if (markX)
         {
            __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_4_id", (int)(SafeDivide((pos + swHLbarid), 2)), swprc, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(transp).SetText("X").SetTextColor(swColor).SetStyle(swStyle).SetSize("small").SetYLoc("price").SetTextAlign("center");
         }
      }
      return true;
   }
};
sweep_i_iStream* sweep_i_i5;
IDM_iStream* IDM_i6;
cfHL_iStream* cfHL_i7;
BoS_ChoCh_i_iStream* BoS_ChoCh_i_i8;
cfHL_iStream* cfHL_i9;
sweep_i_iStream* sweep_i_i10;
BoS_ChoCh_i_iStream* BoS_ChoCh_i_i11;
cfHL_iStream* cfHL_i12;
sweep_i_iStream* sweep_i_i13;
BoS_ChoCh_i_iStream* BoS_ChoCh_i_i14;
cfHL_iStream* cfHL_i15;
sweep_i_iStream* sweep_i_i16;
class mnMark_iStream
{
   int UD;
   bool _initialized;
public:
   mnMark_iStream(int UD)
   {
      _initialized = false;
      this.UD = UD;
   }
   ~mnMark_iStream()
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
      if (showMn)
      {
         __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_5_id", (NumberToBool(UD) ? puUpbar[pos] : puDnbar[pos]), (NumberToBool(UD) ? puUp[pos] : puDn[pos]), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor((NumberToBool(UD) ? puUpco : puDnco)).SetText("").SetStyle((NumberToBool(UD) ? "arrowdown" : "arrowup")).SetSize("tiny").SetYLoc((NumberToBool(UD) ? "abovebar" : "belowbar")).SetTextAlign("center");
      }
      return true;
   }
};
mnMark_iStream* mnMark_i17;
mnMark_iStream* mnMark_i18;
mnMark_iStream* mnMark_i19;
mnMark_iStream* mnMark_i20;

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
   int id = 0;
   equalHL = param1;
   showHL = param2;
   HLcolor = param3;
   showMn = param4;
   puUpco = param5;
   puDnco = param6;
   showBC = param7;
   bull = param8;
   bear = param9;
   showbarcolor = param10;
   showSCOB = param11;
   scobUp = param12;
   scobDn = param13;
   showIDM = param14;
   showliveIDM = param15;
   idmColor = param16;
   showSw = param17;
   markX = param18;
   swColor = param19;
   barcolor1 = new CandleStreams(0);
   barcolor1.AddColor(scobUp);
   barcolor1.AddColor(scobDn);
   barcolor1.AddColor(bull);
   barcolor1.AddColor(bear);
   barcolor1.SetOffset((-1));
   id = barcolor1.RegisterStreams(id);
   LinesCollection::SetMaxLines(500);
   LabelsCollection::SetMaxLabels(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("KUEFX SMC");
   IndicatorSetString(INDICATOR_SHORTNAME, "stracturre.x");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, mnUp, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, mnDn, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, top, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, bot, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, puUp, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, puDn, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, L, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, H, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, idmB, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, idmS, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, lastH, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, lastL, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, lastHH, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, lastLL, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, puUpbar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, puDnbar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, idmB_bar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, idmS_bar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Hbar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Lbar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, lastHbar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, lastLbar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, lastHHbar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, lastLLbar, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, isBosUp, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, isBosDn, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, isCocUp, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, isCocDn, INDICATOR_CALCULATIONS);
   IDM_i1 = new IDM_iStream(1);
   id = IDM_i1.Init(id);
   cfHL_i2 = new cfHL_iStream(1);
   id = cfHL_i2.Init(id);
   cfHL_i3 = new cfHL_iStream(0);
   id = cfHL_i3.Init(id);
   BoS_ChoCh_i_i4 = new BoS_ChoCh_i_iStream(0, 1);
   id = BoS_ChoCh_i_i4.Init(id);
   sweep_i_i5 = new sweep_i_iStream(1, 0);
   id = sweep_i_i5.Init(id);
   IDM_i6 = new IDM_iStream(0);
   id = IDM_i6.Init(id);
   cfHL_i7 = new cfHL_iStream(0);
   id = cfHL_i7.Init(id);
   BoS_ChoCh_i_i8 = new BoS_ChoCh_i_iStream(0, 0);
   id = BoS_ChoCh_i_i8.Init(id);
   cfHL_i9 = new cfHL_iStream(1);
   id = cfHL_i9.Init(id);
   sweep_i_i10 = new sweep_i_iStream(0, 1);
   id = sweep_i_i10.Init(id);
   BoS_ChoCh_i_i11 = new BoS_ChoCh_i_iStream(1, 1);
   id = BoS_ChoCh_i_i11.Init(id);
   cfHL_i12 = new cfHL_iStream(0);
   id = cfHL_i12.Init(id);
   sweep_i_i13 = new sweep_i_iStream(1, 1);
   id = sweep_i_i13.Init(id);
   BoS_ChoCh_i_i14 = new BoS_ChoCh_i_iStream(1, 0);
   id = BoS_ChoCh_i_i14.Init(id);
   cfHL_i15 = new cfHL_iStream(1);
   id = cfHL_i15.Init(id);
   sweep_i_i16 = new sweep_i_iStream(0, 0);
   id = sweep_i_i16.Init(id);
   mnMark_i17 = new mnMark_iStream(1);
   id = mnMark_i17.Init(id);
   mnMark_i18 = new mnMark_iStream(0);
   id = mnMark_i18.Init(id);
   mnMark_i19 = new mnMark_iStream(1);
   id = mnMark_i19.Init(id);
   mnMark_i20 = new mnMark_iStream(0);
   id = mnMark_i20.Init(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   delete barcolor1;
   delete IDM_i1;
   delete cfHL_i2;
   delete cfHL_i3;
   delete BoS_ChoCh_i_i4;
   delete sweep_i_i5;
   delete IDM_i6;
   delete cfHL_i7;
   delete BoS_ChoCh_i_i8;
   delete cfHL_i9;
   delete sweep_i_i10;
   delete BoS_ChoCh_i_i11;
   delete cfHL_i12;
   delete sweep_i_i13;
   delete BoS_ChoCh_i_i14;
   delete cfHL_i15;
   delete sweep_i_i16;
   delete mnMark_i17;
   delete mnMark_i18;
   delete mnMark_i19;
   delete mnMark_i20;
   LinesCollection::Clear(true);
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
      LinesCollection::Clear();
      LabelsCollection::Clear();
      mnUp_DEFAULT_VALUE = (-1);
      ArrayInitialize(mnUp, mnUp_DEFAULT_VALUE);
      mnDn_DEFAULT_VALUE = (-1);
      ArrayInitialize(mnDn, mnDn_DEFAULT_VALUE);
      top_DEFAULT_VALUE = high[0];
      ArrayInitialize(top, top_DEFAULT_VALUE);
      bot_DEFAULT_VALUE = low[0];
      ArrayInitialize(bot, bot_DEFAULT_VALUE);
      puUp_DEFAULT_VALUE = high[0];
      ArrayInitialize(puUp, puUp_DEFAULT_VALUE);
      puDn_DEFAULT_VALUE = low[0];
      ArrayInitialize(puDn, puDn_DEFAULT_VALUE);
      L_DEFAULT_VALUE = low[0];
      ArrayInitialize(L, L_DEFAULT_VALUE);
      H_DEFAULT_VALUE = high[0];
      ArrayInitialize(H, H_DEFAULT_VALUE);
      idmB_DEFAULT_VALUE = low[0];
      ArrayInitialize(idmB, idmB_DEFAULT_VALUE);
      idmS_DEFAULT_VALUE = high[0];
      ArrayInitialize(idmS, idmS_DEFAULT_VALUE);
      lastH_DEFAULT_VALUE = high[0];
      ArrayInitialize(lastH, lastH_DEFAULT_VALUE);
      lastL_DEFAULT_VALUE = low[0];
      ArrayInitialize(lastL, lastL_DEFAULT_VALUE);
      lastHH_DEFAULT_VALUE = high[0];
      ArrayInitialize(lastHH, lastHH_DEFAULT_VALUE);
      lastLL_DEFAULT_VALUE = low[0];
      ArrayInitialize(lastLL, lastLL_DEFAULT_VALUE);
      puUpbar_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(puUpbar, puUpbar_DEFAULT_VALUE);
      puDnbar_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(puDnbar, puDnbar_DEFAULT_VALUE);
      idmB_bar_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(idmB_bar, idmB_bar_DEFAULT_VALUE);
      idmS_bar_DEFAULT_VALUE = INT_MIN;
      ArrayInitialize(idmS_bar, idmS_bar_DEFAULT_VALUE);
      Hbar_DEFAULT_VALUE = 0;
      ArrayInitialize(Hbar, Hbar_DEFAULT_VALUE);
      Lbar_DEFAULT_VALUE = 0;
      ArrayInitialize(Lbar, Lbar_DEFAULT_VALUE);
      lastHbar_DEFAULT_VALUE = 0;
      ArrayInitialize(lastHbar, lastHbar_DEFAULT_VALUE);
      lastLbar_DEFAULT_VALUE = 0;
      ArrayInitialize(lastLbar, lastLbar_DEFAULT_VALUE);
      lastHHbar_DEFAULT_VALUE = 0;
      ArrayInitialize(lastHHbar, lastHHbar_DEFAULT_VALUE);
      lastLLbar_DEFAULT_VALUE = 0;
      ArrayInitialize(lastLLbar, lastLLbar_DEFAULT_VALUE);
      isBosUp_DEFAULT_VALUE = 0;
      ArrayInitialize(isBosUp, isBosUp_DEFAULT_VALUE);
      isBosDn_DEFAULT_VALUE = 0;
      ArrayInitialize(isBosDn, isBosDn_DEFAULT_VALUE);
      isCocUp_DEFAULT_VALUE = 1;
      ArrayInitialize(isCocUp, isCocUp_DEFAULT_VALUE);
      isCocDn_DEFAULT_VALUE = 1;
      ArrayInitialize(isCocDn, isCocDn_DEFAULT_VALUE);
      lv_lbl = NULL;
      lv_line = NULL;
      barcolor1.Init();
      IDM_i1.Clear();
      cfHL_i2.Clear();
      cfHL_i3.Clear();
      BoS_ChoCh_i_i4.Clear();
      sweep_i_i5.Clear();
      IDM_i6.Clear();
      cfHL_i7.Clear();
      BoS_ChoCh_i_i8.Clear();
      cfHL_i9.Clear();
      sweep_i_i10.Clear();
      BoS_ChoCh_i_i11.Clear();
      cfHL_i12.Clear();
      sweep_i_i13.Clear();
      BoS_ChoCh_i_i14.Clear();
      cfHL_i15.Clear();
      sweep_i_i16.Clear();
      mnMark_i17.Clear();
      mnMark_i18.Clear();
      mnMark_i19.Clear();
      mnMark_i20.Clear();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      mnUp[pos] = pos > 0 ? mnUp[pos - 1] : (-1);
      mnDn[pos] = pos > 0 ? mnDn[pos - 1] : (-1);
      top[pos] = pos > 0 ? top[pos - 1] : high[pos];
      bot[pos] = pos > 0 ? bot[pos - 1] : low[pos];
      puUp[pos] = pos > 0 ? puUp[pos - 1] : high[pos];
      puDn[pos] = pos > 0 ? puDn[pos - 1] : low[pos];
      L[pos] = pos > 0 ? L[pos - 1] : low[pos];
      H[pos] = pos > 0 ? H[pos - 1] : high[pos];
      idmB[pos] = pos > 0 ? idmB[pos - 1] : low[pos];
      idmS[pos] = pos > 0 ? idmS[pos - 1] : high[pos];
      lastH[pos] = pos > 0 ? lastH[pos - 1] : high[pos];
      lastL[pos] = pos > 0 ? lastL[pos - 1] : low[pos];
      lastHH[pos] = pos > 0 ? lastHH[pos - 1] : high[pos];
      lastLL[pos] = pos > 0 ? lastLL[pos - 1] : low[pos];
      puUpbar[pos] = pos > 0 ? puUpbar[pos - 1] : INT_MIN;
      puDnbar[pos] = pos > 0 ? puDnbar[pos - 1] : INT_MIN;
      idmB_bar[pos] = pos > 0 ? idmB_bar[pos - 1] : INT_MIN;
      idmS_bar[pos] = pos > 0 ? idmS_bar[pos - 1] : INT_MIN;
      Hbar[pos] = pos > 0 ? Hbar[pos - 1] : pos;
      Lbar[pos] = pos > 0 ? Lbar[pos - 1] : pos;
      lastHbar[pos] = pos > 0 ? lastHbar[pos - 1] : pos;
      lastLbar[pos] = pos > 0 ? lastLbar[pos - 1] : pos;
      lastHHbar[pos] = pos > 0 ? lastHHbar[pos - 1] : pos;
      lastLLbar[pos] = pos > 0 ? lastLLbar[pos - 1] : pos;
      isBosUp[pos] = pos > 0 ? isBosUp[pos - 1] : 0;
      isBosDn[pos] = pos > 0 ? isBosDn[pos - 1] : 0;
      isCocUp[pos] = pos > 0 ? isCocUp[pos - 1] : 1;
      isCocDn[pos] = pos > 0 ? isCocDn[pos - 1] : 1;
      double mnStrc = EMPTY_VALUE;
      int lastHL = MathMax(Hbar[pos], Lbar[pos]);
      transp = AddTransparency(0x62ff59, 5);
      maxlen = pos - 500;
      uint ba_color = INT_MAX;
      if (showSCOB)
      {
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 2 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 1 < 0) { continue; }
         if (pos - 2 < 0) { continue; }
         if ((low[pos - 1] == puDn[pos]) && SafeGE(low[pos], low[pos - 1]) && SafeGreater(close[pos], high[pos - 1]) && SafeGreater(close[pos - 1], low[pos - 2]))
         {
            ba_color = scobUp;
         }
         else if ((high[pos - 1] == puUp[pos]) && SafeLE(high[pos], high[pos - 1]) && SafeLess(close[pos], low[pos - 1]) && SafeLess(close[pos - 1], high[pos - 2]))
         {
            ba_color = scobDn;
         }
         else if (showbarcolor)
         {
            ba_color = (isCocUp[pos] ? bull : bear);
         }
         else
         {
            ba_color = INT_MAX;
         }
      }
      barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], ba_color);
      if ((((high[pos] > H[pos]) || ((high[pos] == H[pos]) && equalHL))) && (low[pos] > idmB[pos]))
      {
         if ((low[pos] <= puDn[pos]))
         {
            SetStream(idmB, pos, low[pos], idmB_DEFAULT_VALUE);
            SetStream(idmB_bar, pos, pos, idmB_bar_DEFAULT_VALUE);
         }
         else
         {
            SetStream(idmB, pos, puDn[pos], idmB_DEFAULT_VALUE);
            SetStream(idmB_bar, pos, puDnbar[pos], idmB_bar_DEFAULT_VALUE);
         }
      }
      if ((((low[pos] < L[pos]) || ((low[pos] == L[pos]) && equalHL))) && (high[pos] < idmS[pos]))
      {
         if ((high[pos] >= puUp[pos]))
         {
            SetStream(idmS, pos, high[pos], idmS_DEFAULT_VALUE);
            SetStream(idmS_bar, pos, pos, idmS_bar_DEFAULT_VALUE);
         }
         else
         {
            SetStream(idmS, pos, puUp[pos], idmS_DEFAULT_VALUE);
            SetStream(idmS_bar, pos, puUpbar[pos], idmS_bar_DEFAULT_VALUE);
         }
      }
      if (isCocUp[pos] && (lastHL != Lbar[pos]))
      {
         if ((low[pos] < idmB[pos]))
         {
            if ((idmB[pos] != lastL[pos]))
            {
               Label* IDM_i1Value;
               if (!IDM_i1.GetValue(pos, oldPos, IDM_i1Value)) { IDM_i1Value = NULL; }
               IDM_i1Value;
            }
            SetStream(isBosUp, pos, 0, isBosUp_DEFAULT_VALUE);
            SetStream(lastH, pos, H[pos], lastH_DEFAULT_VALUE);
            SetStream(lastHbar, pos, Hbar[pos], lastHbar_DEFAULT_VALUE);
            SetStream(lastHH, pos, H[pos], lastHH_DEFAULT_VALUE);
            SetStream(lastHHbar, pos, Hbar[pos], lastHHbar_DEFAULT_VALUE);
            Label* cfHL_i2Value;
            if (!cfHL_i2.GetValue(pos, oldPos, cfHL_i2Value)) { cfHL_i2Value = NULL; }
            cfHL_i2Value;
            SetStream(L, pos, low[pos], L_DEFAULT_VALUE);
            SetStream(Lbar, pos, pos, Lbar_DEFAULT_VALUE);
         }
      }
      else if ((lastH[pos] != lastHH[pos]) && (high[pos] > lastH[pos]))
      {
         Label* cfHL_i3Value;
         if (!cfHL_i3.GetValue(pos, oldPos, cfHL_i3Value)) { cfHL_i3Value = NULL; }
         cfHL_i3Value;
         SetStream(isCocDn, pos, 0, isCocDn_DEFAULT_VALUE);
         SetStream(isBosDn, pos, 0, isBosDn_DEFAULT_VALUE);
         if ((close[pos] > lastH[pos]))
         {
            Label* BoS_ChoCh_i_i4Value;
            if (!BoS_ChoCh_i_i4.GetValue(pos, oldPos, BoS_ChoCh_i_i4Value)) { BoS_ChoCh_i_i4Value = NULL; }
            BoS_ChoCh_i_i4Value;
            SetStream(isCocUp, pos, 1, isCocUp_DEFAULT_VALUE);
         }
         else
         {
            Label* sweep_i_i5Value;
            if (!sweep_i_i5.GetValue(pos, oldPos, sweep_i_i5Value)) { sweep_i_i5Value = NULL; }
            sweep_i_i5Value;
         }
      }
      if (isCocDn[pos] && (lastHL != Hbar[pos]))
      {
         if ((high[pos] > idmS[pos]))
         {
            if ((idmS[pos] != lastH[pos]))
            {
               Label* IDM_i6Value;
               if (!IDM_i6.GetValue(pos, oldPos, IDM_i6Value)) { IDM_i6Value = NULL; }
               IDM_i6Value;
            }
            SetStream(isBosDn, pos, 0, isBosDn_DEFAULT_VALUE);
            SetStream(lastL, pos, L[pos], lastL_DEFAULT_VALUE);
            SetStream(lastLbar, pos, Lbar[pos], lastLbar_DEFAULT_VALUE);
            SetStream(lastLL, pos, L[pos], lastLL_DEFAULT_VALUE);
            SetStream(lastLLbar, pos, Lbar[pos], lastLLbar_DEFAULT_VALUE);
            Label* cfHL_i7Value;
            if (!cfHL_i7.GetValue(pos, oldPos, cfHL_i7Value)) { cfHL_i7Value = NULL; }
            cfHL_i7Value;
            SetStream(H, pos, high[pos], H_DEFAULT_VALUE);
            SetStream(Hbar, pos, pos, Hbar_DEFAULT_VALUE);
         }
      }
      else if ((low[pos] < lastL[pos]) && (lastL[pos] != lastLL[pos]))
      {
         if ((close[pos] < lastL[pos]))
         {
            Label* BoS_ChoCh_i_i8Value;
            if (!BoS_ChoCh_i_i8.GetValue(pos, oldPos, BoS_ChoCh_i_i8Value)) { BoS_ChoCh_i_i8Value = NULL; }
            BoS_ChoCh_i_i8Value;
            Label* cfHL_i9Value;
            if (!cfHL_i9.GetValue(pos, oldPos, cfHL_i9Value)) { cfHL_i9Value = NULL; }
            cfHL_i9Value;
            SetStream(isCocDn, pos, 1, isCocDn_DEFAULT_VALUE);
            SetStream(isCocUp, pos, 0, isCocUp_DEFAULT_VALUE);
            SetStream(isBosUp, pos, 0, isBosUp_DEFAULT_VALUE);
         }
         else
         {
            Label* sweep_i_i10Value;
            if (!sweep_i_i10.GetValue(pos, oldPos, sweep_i_i10Value)) { sweep_i_i10Value = NULL; }
            sweep_i_i10Value;
         }
      }
      if ((isBosUp[pos] == 0))
      {
         if ((high[pos] > lastHH[pos]))
         {
            if ((close[pos] > lastHH[pos]))
            {
               Label* BoS_ChoCh_i_i11Value;
               if (!BoS_ChoCh_i_i11.GetValue(pos, oldPos, BoS_ChoCh_i_i11Value)) { BoS_ChoCh_i_i11Value = NULL; }
               BoS_ChoCh_i_i11Value;
               Label* cfHL_i12Value;
               if (!cfHL_i12.GetValue(pos, oldPos, cfHL_i12Value)) { cfHL_i12Value = NULL; }
               cfHL_i12Value;
               SetStream(lastL, pos, L[pos], lastL_DEFAULT_VALUE);
               SetStream(lastLbar, pos, Lbar[pos], lastLbar_DEFAULT_VALUE);
               SetStream(isCocUp, pos, 1, isCocUp_DEFAULT_VALUE);
               SetStream(isBosUp, pos, 1, isBosUp_DEFAULT_VALUE);
               SetStream(isCocDn, pos, 0, isCocDn_DEFAULT_VALUE);
               SetStream(isBosDn, pos, 0, isBosDn_DEFAULT_VALUE);
            }
            else
            {
               Label* sweep_i_i13Value;
               if (!sweep_i_i13.GetValue(pos, oldPos, sweep_i_i13Value)) { sweep_i_i13Value = NULL; }
               sweep_i_i13Value;
            }
         }
      }
      if ((isBosDn[pos] == 0))
      {
         if ((low[pos] < lastLL[pos]))
         {
            if ((close[pos] < lastLL[pos]))
            {
               Label* BoS_ChoCh_i_i14Value;
               if (!BoS_ChoCh_i_i14.GetValue(pos, oldPos, BoS_ChoCh_i_i14Value)) { BoS_ChoCh_i_i14Value = NULL; }
               BoS_ChoCh_i_i14Value;
               Label* cfHL_i15Value;
               if (!cfHL_i15.GetValue(pos, oldPos, cfHL_i15Value)) { cfHL_i15Value = NULL; }
               cfHL_i15Value;
               SetStream(lastH, pos, H[pos], lastH_DEFAULT_VALUE);
               SetStream(lastHbar, pos, Hbar[pos], lastHbar_DEFAULT_VALUE);
               SetStream(isCocUp, pos, 0, isCocUp_DEFAULT_VALUE);
               SetStream(isBosUp, pos, 0, isBosUp_DEFAULT_VALUE);
               SetStream(isCocDn, pos, 1, isCocDn_DEFAULT_VALUE);
               SetStream(isBosDn, pos, 1, isBosDn_DEFAULT_VALUE);
            }
            else
            {
               Label* sweep_i_i16Value;
               if (!sweep_i_i16.GetValue(pos, oldPos, sweep_i_i16Value)) { sweep_i_i16Value = NULL; }
               sweep_i_i16Value;
            }
         }
      }
      if (equalHL)
      {
         if ((high[pos] >= top[pos]))
         {
            if ((low[pos] > bot[pos]))
            {
               SetStream(mnDn, pos, 0, mnDn_DEFAULT_VALUE);
            }
            SetStream(mnUp, pos, 1, mnUp_DEFAULT_VALUE);
         }
         if ((low[pos] <= bot[pos]))
         {
            if ((high[pos] < top[pos]))
            {
               SetStream(mnUp, pos, 0, mnUp_DEFAULT_VALUE);
            }
            SetStream(mnDn, pos, 1, mnDn_DEFAULT_VALUE);
         }
         if (pos - 1 < 0) { continue; }
         if (mnUp[pos - 1] && !mnUp[pos])
         {
            Label* mnMark_i17Value;
            if (!mnMark_i17.GetValue(pos, oldPos, mnMark_i17Value)) { mnMark_i17Value = NULL; }
            mnMark_i17Value;
         }
         if (pos - 1 < 0) { continue; }
         if (mnDn[pos - 1] && !mnDn[pos])
         {
            Label* mnMark_i18Value;
            if (!mnMark_i18.GetValue(pos, oldPos, mnMark_i18Value)) { mnMark_i18Value = NULL; }
            mnMark_i18Value;
         }
      }
      else
      {
         if ((high[pos] > top[pos]))
         {
            if ((low[pos] > bot[pos]))
            {
               SetStream(mnDn, pos, 0, mnDn_DEFAULT_VALUE);
            }
            SetStream(mnUp, pos, 1, mnUp_DEFAULT_VALUE);
         }
         if ((low[pos] < bot[pos]))
         {
            if ((high[pos] < top[pos]))
            {
               SetStream(mnUp, pos, 0, mnUp_DEFAULT_VALUE);
            }
            SetStream(mnDn, pos, 1, mnDn_DEFAULT_VALUE);
         }
         if (pos - 1 < 0) { continue; }
         if (mnUp[pos - 1] && !mnUp[pos])
         {
            Label* mnMark_i19Value;
            if (!mnMark_i19.GetValue(pos, oldPos, mnMark_i19Value)) { mnMark_i19Value = NULL; }
            mnMark_i19Value;
         }
         if (pos - 1 < 0) { continue; }
         if (mnDn[pos - 1] && !mnDn[pos])
         {
            Label* mnMark_i20Value;
            if (!mnMark_i20.GetValue(pos, oldPos, mnMark_i20Value)) { mnMark_i20Value = NULL; }
            mnMark_i20Value;
         }
      }
      if (equalHL)
      {
         if ((high[pos] >= top[pos]))
         {
            SetStream(puUp, pos, high[pos], puUp_DEFAULT_VALUE);
            SetStream(puUpbar, pos, pos, puUpbar_DEFAULT_VALUE);
         }
         if ((low[pos] <= bot[pos]))
         {
            SetStream(puDn, pos, low[pos], puDn_DEFAULT_VALUE);
            SetStream(puDnbar, pos, pos, puDnbar_DEFAULT_VALUE);
            SetStream(top, pos, high[pos], top_DEFAULT_VALUE);
            SetStream(bot, pos, low[pos], bot_DEFAULT_VALUE);
         }
         if ((high[pos] >= top[pos]))
         {
            SetStream(top, pos, high[pos], top_DEFAULT_VALUE);
            SetStream(bot, pos, low[pos], bot_DEFAULT_VALUE);
         }
      }
      else
      {
         if ((high[pos] > top[pos]))
         {
            SetStream(puUp, pos, high[pos], puUp_DEFAULT_VALUE);
            SetStream(puUpbar, pos, pos, puUpbar_DEFAULT_VALUE);
         }
         if ((low[pos] < bot[pos]))
         {
            SetStream(puDn, pos, low[pos], puDn_DEFAULT_VALUE);
            SetStream(puDnbar, pos, pos, puDnbar_DEFAULT_VALUE);
            SetStream(top, pos, high[pos], top_DEFAULT_VALUE);
            SetStream(bot, pos, low[pos], bot_DEFAULT_VALUE);
         }
         if ((high[pos] > top[pos]))
         {
            SetStream(top, pos, high[pos], top_DEFAULT_VALUE);
            SetStream(bot, pos, low[pos], bot_DEFAULT_VALUE);
         }
      }
      if (((high[pos] > H[pos]) || ((high[pos] == H[pos]) && equalHL)))
      {
         SetStream(H, pos, high[pos], H_DEFAULT_VALUE);
         SetStream(Hbar, pos, pos, Hbar_DEFAULT_VALUE);
      }
      if ((high[pos] > idmS[pos]))
      {
         SetStream(idmS, pos, high[pos], idmS_DEFAULT_VALUE);
         SetStream(idmS_bar, pos, pos, idmS_bar_DEFAULT_VALUE);
      }
      if (((high[pos] > lastH[pos]) || ((high[pos] == lastH[pos]) && equalHL)))
      {
         SetStream(lastH, pos, high[pos], lastH_DEFAULT_VALUE);
         SetStream(lastHbar, pos, pos, lastHbar_DEFAULT_VALUE);
      }
      if (((high[pos] > lastHH[pos]) || ((high[pos] == lastHH[pos]) && equalHL)))
      {
         SetStream(lastHH, pos, high[pos], lastHH_DEFAULT_VALUE);
         SetStream(lastHHbar, pos, pos, lastHHbar_DEFAULT_VALUE);
      }
      if (((low[pos] < L[pos]) || ((low[pos] == L[pos]) && equalHL)))
      {
         SetStream(L, pos, low[pos], L_DEFAULT_VALUE);
         SetStream(Lbar, pos, pos, Lbar_DEFAULT_VALUE);
      }
      if ((low[pos] < idmB[pos]))
      {
         SetStream(idmB, pos, low[pos], idmB_DEFAULT_VALUE);
         SetStream(idmB_bar, pos, pos, idmB_bar_DEFAULT_VALUE);
      }
      if (((low[pos] < lastL[pos]) || ((low[pos] == lastL[pos]) && equalHL)))
      {
         SetStream(lastL, pos, low[pos], lastL_DEFAULT_VALUE);
         SetStream(lastLbar, pos, pos, lastLbar_DEFAULT_VALUE);
      }
      if (((low[pos] < lastLL[pos]) || ((low[pos] == lastLL[pos]) && equalHL)))
      {
         SetStream(lastLL, pos, low[pos], lastLL_DEFAULT_VALUE);
         SetStream(lastLLbar, pos, pos, lastLLbar_DEFAULT_VALUE);
      }
      if (showliveIDM && (pos == rates_total - 1))
      {
         double liveIDM = EMPTY_VALUE;
         int liveIDMbar = INT_MIN;
         if (isCocUp[pos] && (lastHL == Hbar[pos]))
         {
            liveIDM = idmB[pos];
            liveIDMbar = idmB_bar[pos];
         }
         else if (isCocDn[pos] && (lastHL == Lbar[pos]))
         {
            liveIDM = idmS[pos];
            liveIDMbar = idmS_bar[pos];
         }
         lv_line = LinesCollection::Create(IndicatorObjPrefix + "line_4_id", liveIDMbar, liveIDM, pos + 20, liveIDM, time[pos]).SetColor(idmColor).SetWidth(1).SetStyle("dotted");
         lv_lbl = LabelsCollection::Create(IndicatorObjPrefix + "label_6_id", pos + 20, liveIDM, time[pos]).SetColor(transp).SetText("IDM").SetTextColor(idmColor).SetStyle((isCocUp[pos] ? "down" : "up")).SetSize("small").SetYLoc("price").SetTextAlign("center");
      }
      else
      {
         lv_line = NULL;
         lv_lbl = NULL;
      }
      LinesCollection::Delete(LinesCollection::Get(lv_line, 1));
      LabelsCollection::Delete(LabelsCollection::Get(lv_lbl, 1));
   }
   LinesCollection::Redraw();
   LabelsCollection::Redraw();
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75600

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