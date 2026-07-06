//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74592

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_label1 "ZigzagMA"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "ZigzagHighMA"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "BBUpperMa"
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "BBUpperHighMa"
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "ZigzagLowMA"
#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "BBLowerMa"
#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "BBLowerLowMa"
#property indicator_type7 DRAW_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1

// Array v1.1
// Array interface v1.0

// int array interface v1.0

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
};
// Line array interface v1.0
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
public:
   Line(int x1, double y1, int x2, double y2, string id)
   {
      _x1 = x1;
      _x2 = x2;
      _y1 = y1;
      _y2 = y2;
      _id = id;
      _clr = Blue;
      _timeframe = (ENUM_TIMEFRAMES)_Period;
   }

   string GetId()
   {
      return _id;
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

   static void Delete(Line* line)
   {
      if (line == NULL)
      {
         return;
      }
   }

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
};
// float array interface v1.0

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
};


// Line array v1.1

class LineArray : public ILineArray
{
   Line* array[];
   int _defaultSize;
   Line* _defaultValue;
public:
   LineArray(int size, Line* defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ILineArray* Clear()
   {
      ArrayResize(array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(Line* value)
   {
      int size = ArraySize(array);
      ArrayResize(array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         array[i + 1] = array[i];
      }
      array[0] = value;
   }

   int Size()
   {
      return ArraySize(array);
   }

   void Push(Line* value)
   {
      int size = ArraySize(array);
      ArrayResize(array, size + 1);
      array[size] = value;
   }

   Line* Pop()
   {
      int size = ArraySize(array);
      Line* value = array[size - 1];
      ArrayResize(array, size - 1);
      return value;
   }

   Line* Shift()
   {
      int size = ArraySize(array);
      Line* value = array[0];
      for (int i = 0; i < size - 1; ++i)
      {
         array[i] = array[i + 1];
      }
      ArrayResize(array, size - 1);
      return value;
   }

   Line* Get(int index)
   {
      return array[index];
   }
   
   ILineArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }
};
// Int array v1.1


class IntArray : public IIntArray
{
   int array[];
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
      ArrayResize(array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(int value)
   {
      int size = ArraySize(array);
      ArrayResize(array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         array[i + 1] = array[i];
      }
      array[0] = value;
   }

   int Size()
   {
      return ArraySize(array);
   }

   void Push(int value)
   {
      int size = ArraySize(array);
      ArrayResize(array, size + 1);
      array[size] = value;
   }

   int Pop()
   {
      int size = ArraySize(array);
      int value = array[size - 1];
      ArrayResize(array, size - 1);
      return value;
   }

   int Shift()
   {
      int size = ArraySize(array);
      int value = array[0];
      for (int i = 0; i < size - 1; ++i)
      {
         array[i] = array[i + 1];
      }
      ArrayResize(array, size - 1);
      return value;
   }

   int Get(int index)
   {
      return array[index];
   }
   
   IIntArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }
};
// Float array v1.1


class FloatArray : public IFloatArray
{
   double array[];
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
      ArrayResize(array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(double value)
   {
      int size = ArraySize(array);
      ArrayResize(array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         array[i + 1] = array[i];
      }
      array[0] = value;
   }

   int Size()
   {
      return ArraySize(array);
   }

   void Push(double value)
   {
      int size = ArraySize(array);
      ArrayResize(array, size + 1);
      array[size] = value;
   }

   double Pop()
   {
      int size = ArraySize(array);
      double value = array[size - 1];
      ArrayResize(array, size - 1);
      return value;
   }

   double Get(int index)
   {
      return array[index];
   }

   double Shift()
   {
      int size = ArraySize(array);
      double value = array[0];
      for (int i = 0; i < size - 1; ++i)
      {
         array[i] = array[i + 1];
      }
      ArrayResize(array, size - 1);
      return value;
   }
   
   IFloatArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }
};

class Array
{
public:
   static void Unshift(IIntArray* array, int value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Unshift(value); }
   static void Unshift(IFloatArray* array, double value) { if (array == NULL) { return; } array.Unshift(value); }
   
   static int Size(ILineArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }

   static Line* Shift(ILineArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }
   static int Shift(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static double Shift(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }

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

   static void Push(ILineArray* array, Line* value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IIntArray* array, int value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IFloatArray* array, double value) { if (array == NULL) { return; } array.Push(value); }

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

   static int Pop(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static double Pop(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Pop(); }
   static Line* Pop(ILineArray* array) { if (array == NULL) { return NULL; } return array.Pop(); }

   static int Get(IIntArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static double Get(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Get(index); }
   static Line* Get(ILineArray* array, int index) { if (array == NULL) { return NULL; } return array.Get(index); }
};


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


// Highest bars stream v1.0

class HighestBarsStream : public AOnStream
{
   int _loopback;
public:
   HighestBarsStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _source.Release();
      _loopback = loopback;
   }
   HighestBarsStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, int &val)
   {
      double current;
      if (!_source.GetValue(period, current))
         return false;
      int index = 0;
      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         if (current < value)
         {
            current = value;
            index = i;
         }
      }
      val = index;
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      int value;
      if (!GetValue(period, value))
      {
         return false;
      }
      val = value;
      return true;
   }
};




// Lowest bars stream v1.0

class LowestBarsStream : public AOnStream
{
   int _loopback;
public:
   LowestBarsStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _source.Release();
      _loopback = loopback;
   }
   LowestBarsStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, int &val)
   {
      double current;
      if (!_source.GetValue(period, current))
         return false;
      int index = 0;
      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         if (current > value)
         {
            current = value;
            index = i;
         }
      }
      val = index;
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      int value;
      if (!GetValue(period, value))
      {
         return false;
      }
      val = value;
      return true;
   }
};
#define ColorRGB(red, green, blue, transp) red + (green << 8) + (blue << 16)

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


// Change stream v1.0

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
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

double SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left > right;
}

double SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left >= right;
}

double SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left < right;
}

double SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
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
// Custom integer stream v1.0

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
// Float array stream v1.0

#ifndef FloatArrayStream_IMPL
#define FloatArrayStream_IMPL

// Abstract implementation for IFloatArrayStream v1.0

#ifndef AFloatArrayStream_IMPL
#define AFloatArrayStream_IMPL

// Float array stream v1.0


interface IFloatArrayStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, IFloatArray* &val) = 0;
};

class AFloatArrayStream : public IFloatArrayStream
{
   int _refs;   
public:
   AFloatArrayStream()
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


class FloatArrayStream : public AFloatArrayStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   IFloatArray* _stream[];
public:
   FloatArrayStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = NULL;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, IFloatArray* value)
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

   bool GetValue(const int period, IFloatArray* &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != NULL;
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
            _stream[i] = NULL;
         }
      }
   }
};
#endif
// Integer array stream v1.0

#ifndef IntArrayStream_IMPL
#define IntArrayStream_IMPL

// Abstract implementation for IIntArrayStream v1.0

#ifndef IIntArrayStream_IMPL
#define IIntArrayStream_IMPL

// Float array stream v1.0


interface IIntArrayStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, IIntArray* &val) = 0;
};

class AIntArrayStream : public IIntArrayStream
{
   int _refs;   
public:
   AIntArrayStream()
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


class IntArrayStream : public AIntArrayStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   IIntArray* _stream[];
public:
   IntArrayStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = NULL;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, IIntArray* value)
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

   bool GetValue(const int period, IIntArray* &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != NULL;
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
            _stream[i] = NULL;
         }
      }
   }
};
#endif
// Collection of lines v1.1

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL



class LinesCollection
{
   string _id;
   Line* _lines[];
   static LinesCollection* _collections[];
public:
   LinesCollection(string id)
   {
      _id = id;
   }

   ~LinesCollection()
   {
      for (int i = 0; i < ArraySize(_lines); ++i)
      {
         delete _lines[i];
      }
      ArrayResize(_lines, 0);
   }
   
   string GetId()
   {
      return _id;
   }

   static void Clear()
   {
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
      LinesCollection* collection = FindCollection(line.GetId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteLine(line);
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
      
      Line* line = new Line(x1, y1, x2, y2, lineId);
      LinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(line);
      return line;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLines();
      }
   }
private:
   int FindIndex(Line* line)
   {
      int size = ArraySize(_lines);
      for (int i = 0; i < size; ++i)
      {
         if (_lines[i].GetId() == line.GetId())
         {
            return i;
         }
      }
      return -1;
   }

   void DeleteLine(Line* line)
   {
      int index = FindIndex(line);
      if (index != -1)
      {
         return;
      }
      delete _lines[index];
      int size = ArraySize(_lines);
      for (int i = index + 1; i < size; ++i)
      {
         _lines[i - 1] = _lines[i];
      }
      ArrayResize(_lines, size - 1);
   }
   
   void Add(Line* line)
   {
      int index = FindIndex(line);
      if (index != -1)
      {
         delete _lines[index];
         _lines[index] = line;
         return;
      }
      int size = ArraySize(_lines);
      ArrayResize(_lines, size + 1);
      _lines[size] = line;
   }

   void RedrawLines()
   {
      int size = ArraySize(_lines);
      for (int i = 0; i < size; ++i)
      {
         _lines[i].Redraw();
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
#endif
// Line array stream v1.0

#ifndef LineArrayStream_IMPL
#define LineArrayStream_IMPL

// Abstract implementation for ILineArrayStream v1.0

#ifndef ALineArrayStream_IMPL
#define ALineArrayStream_IMPL

// Line array stream v1.0


interface ILineArrayStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, ILineArray* &val) = 0;
};

class ALineArrayStream : public ILineArrayStream
{
   int _refs;   
public:
   ALineArrayStream()
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


class LineArrayStream : public ALineArrayStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   ILineArray* _stream[];
public:
   LineArrayStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = NULL;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, ILineArray* value)
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

   bool GetValue(const int period, ILineArray* &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != NULL;
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
            _stream[i] = NULL;
         }
      }
   }
};
#endif
input int param1 = 20;
input double param2 = 2;
input bool param3 = false;
input int param4 = 5;
input color param5 = Teal;
input int param6 = 90;
input int bars_limit = 100000; // Bars limit
int MALength;
double Mult;
bool showZigZag;
int zigzagLength;
color zigzagColor;
int zigzagWidth;
string zigzagStyle;
int cloudTransparency;
int max_array_size;
IFloatArray* zigzagpivots;
IFloatArray* __array1;
IIntArray* zigzagpivotbars;
IIntArray* __array2;
IIntArray* zigzagpivotdirs;
IIntArray* __array3;
ILineArray* zigzaglines;
ILineArray* __array4;
class pivots_iStream
{
   int length;
   FloatStream* highestbars1Source;
   HighestBarsStream* highestbars1;
   FloatStream* lowestbars1Source;
   LowestBarsStream* lowestbars1;
   double dir[];
   bool _initialized;
public:
   pivots_iStream(int length)
   {
      _initialized = false;
      this.length = length;
      highestbars1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      highestbars1 = new HighestBarsStream(highestbars1Source, length);
      lowestbars1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      lowestbars1 = new LowestBarsStream(lowestbars1Source, length);
   }
   ~pivots_iStream()
   {
      highestbars1Source.Release();
      highestbars1.Release();
      lowestbars1Source.Release();
      lowestbars1.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, dir);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, int &__out1, double &__out2, double &__out3, int &__out4, int &__out5)
   {
      if (!_initialized)
      {
         highestbars1Source.Init();
         lowestbars1Source.Init();
         ArrayInitialize(dir, 0);
         _initialized = true;
      }
      highestbars1Source.SetValue(pos, iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      int highestbars1Value;
      if (!highestbars1.GetValue(pos, highestbars1Value)) { highestbars1Value = EMPTY_VALUE; }
      double phigh = ((highestbars1Value == 0) ? iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) : EMPTY_VALUE);
      lowestbars1Source.SetValue(pos, iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      int lowestbars1Value;
      if (!lowestbars1.GetValue(pos, lowestbars1Value)) { lowestbars1Value = EMPTY_VALUE; }
      double plow = ((lowestbars1Value == 0) ? iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) : EMPTY_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      int iff_1 = (NumberToBool(plow) && (phigh) == EMPTY_VALUE ? (-1) : dir[pos + 1]);
      dir[pos] = (NumberToBool(phigh) && (plow) == EMPTY_VALUE ? 1 : iff_1);
      __out1 = dir[pos];
      __out2 = phigh;
      __out3 = plow;
      __out4 = ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos);
      __out5 = ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos);
      return true;
   }
};
class zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaSStream
{
   IIntStream* dir;
   IStream* phigh;
   IStream* plow;
   IIntStream* phighbar;
   IIntStream* plowbar;
   IFloatArrayStream* zigzagpivots;
   IIntArrayStream* zigzagpivotbars;
   IIntArrayStream* zigzagpivotdirs;
   FloatStream* change1Source;
   ChangeStream* change1;
   bool _initialized;
public:
   zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaSStream(IIntStream* dir, IStream* phigh, IStream* plow, IIntStream* phighbar, IIntStream* plowbar, IFloatArrayStream* zigzagpivots, IIntArrayStream* zigzagpivotbars, IIntArrayStream* zigzagpivotdirs)
   {
      _initialized = false;
      this.dir = dir;
      dir.AddRef();
      this.phigh = phigh;
      phigh.AddRef();
      this.plow = plow;
      plow.AddRef();
      this.phighbar = phighbar;
      phighbar.AddRef();
      this.plowbar = plowbar;
      plowbar.AddRef();
      this.zigzagpivots = zigzagpivots;
      zigzagpivots.AddRef();
      this.zigzagpivotbars = zigzagpivotbars;
      zigzagpivotbars.AddRef();
      this.zigzagpivotdirs = zigzagpivotdirs;
      zigzagpivotdirs.AddRef();
      change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      change1 = new ChangeStream(change1Source, 1);
   }
   ~zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaSStream()
   {
      dir.Release();
      phigh.Release();
      plow.Release();
      phighbar.Release();
      plowbar.Release();
      zigzagpivots.Release();
      zigzagpivotbars.Release();
      zigzagpivotdirs.Release();
      change1Source.Release();
      change1.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, bool &__out1)
   {
      if (!_initialized)
      {
         change1Source.Init();
         _initialized = true;
      }
      int dirValue;
      if (!dir.GetValue(pos, dirValue)) { dirValue = EMPTY_VALUE; }
      change1Source.SetValue(pos, dirValue);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      double dirchanged = change1Value;
      bool newZG = false;
      double phighValue;
      if (!phigh.GetValue(pos, phighValue)) { phighValue = EMPTY_VALUE; }
      double plowValue;
      if (!plow.GetValue(pos, plowValue)) { plowValue = EMPTY_VALUE; }
      if ((NumberToBool(phighValue) || NumberToBool(plowValue)))
      {
         double value = ((dirValue == 1) ? phighValue : plowValue);
         int phighbarValue;
         if (!phighbar.GetValue(pos, phighbarValue)) { phighbarValue = EMPTY_VALUE; }
         int plowbarValue;
         if (!plowbar.GetValue(pos, plowbarValue)) { plowbarValue = EMPTY_VALUE; }
         int bar = (NumberToBool(phighValue) ? phighbarValue : plowbarValue);
         int newDir = dirValue;
         IFloatArray* zigzagpivotsValue;
         if (!zigzagpivots.GetValue(pos, zigzagpivotsValue)) { zigzagpivotsValue = NULL; }
         if (!NumberToBool(dirchanged) && SafeGE(Array::Size(zigzagpivotsValue), 1))
         {
            double pivot = Array::Shift(zigzagpivotsValue);
            IIntArray* zigzagpivotbarsValue;
            if (!zigzagpivotbars.GetValue(pos, zigzagpivotbarsValue)) { zigzagpivotbarsValue = NULL; }
            int pivotbar = Array::Shift(zigzagpivotbarsValue);
            IIntArray* zigzagpivotdirsValue;
            if (!zigzagpivotdirs.GetValue(pos, zigzagpivotdirsValue)) { zigzagpivotdirsValue = NULL; }
            int pivotdir = Array::Shift(zigzagpivotdirsValue);
            bool useNewValues = SafeLess(SafeMultiply(value, pivotdir), SafeMultiply(pivot, pivotdir));
            value = (useNewValues ? pivot : value);
            bar = (useNewValues ? pivotbar : bar);
            bar;
         }
         if (SafeGE(Array::Size(zigzagpivotsValue), 2))
         {
            double LastPoint = Array::Get(zigzagpivotsValue, 1);
            newDir = (SafeGreater(SafeMultiply(dirValue, value), SafeMultiply(dirValue, LastPoint)) ? SafeMultiply(dirValue, 2) : dirValue);
            newDir;
         }
         Array::Unshift(zigzagpivotsValue, value);
         IIntArray* zigzagpivotbarsValue;
         if (!zigzagpivotbars.GetValue(pos, zigzagpivotbarsValue)) { zigzagpivotbarsValue = NULL; }
         Array::Unshift(zigzagpivotbarsValue, bar);
         IIntArray* zigzagpivotdirsValue;
         if (!zigzagpivotdirs.GetValue(pos, zigzagpivotdirsValue)) { zigzagpivotdirsValue = NULL; }
         Array::Unshift(zigzagpivotdirsValue, newDir);
         newZG = true;
         if (SafeGreater(Array::Size(zigzagpivotsValue), max_array_size))
         {
            Array::Pop(zigzagpivotsValue);
            Array::Pop(zigzagpivotbarsValue);
            Array::Pop(zigzagpivotdirsValue);
         }
      }
      __out1 = newZG;
      return true;
   }
};
class zigzag_i_faS_iaS_iaSStream
{
   int length;
   IFloatArrayStream* zigzagpivots;
   IIntArrayStream* zigzagpivotbars;
   IIntArrayStream* zigzagpivotdirs;
   pivots_iStream* pivots_i1;
   IntStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param1;
   FloatStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param2;
   FloatStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param3;
   IntStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param4;
   IntStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param5;
   FloatArrayStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param6;
   IntArrayStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param7;
   IntArrayStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param8;
   zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaSStream* zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2;
   bool _initialized;
public:
   zigzag_i_faS_iaS_iaSStream(int length, IFloatArrayStream* zigzagpivots, IIntArrayStream* zigzagpivotbars, IIntArrayStream* zigzagpivotdirs)
   {
      _initialized = false;
      this.length = length;
      this.zigzagpivots = zigzagpivots;
      zigzagpivots.AddRef();
      this.zigzagpivotbars = zigzagpivotbars;
      zigzagpivotbars.AddRef();
      this.zigzagpivotdirs = zigzagpivotdirs;
      zigzagpivotdirs.AddRef();
   }
   ~zigzag_i_faS_iaS_iaSStream()
   {
      zigzagpivots.Release();
      zigzagpivotbars.Release();
      zigzagpivotdirs.Release();
      delete pivots_i1;
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param1.Release();
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param2.Release();
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param3.Release();
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param4.Release();
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param5.Release();
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param6.Release();
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param7.Release();
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param8.Release();
      delete zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2;
   }
   int Init(int id)
   {
      pivots_i1 = new pivots_iStream(length);
      id = pivots_i1.Init(id);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param4 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param5 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param6 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param7 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param8 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2 = new zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaSStream(zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param1, zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param2, zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param3, zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param4, zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param5, zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param6, zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param7, zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param8);
      id = zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, bool &__out1)
   {
      if (!_initialized)
      {
         pivots_i1.Clear();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param1.Init();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param2.Init();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param3.Init();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param4.Init();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param5.Init();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param6.Init();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param7.Init();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param8.Init();
         zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2.Clear();
         _initialized = true;
      }
      int pivots_i1Value1;
      double pivots_i1Value2;
      double pivots_i1Value3;
      int pivots_i1Value4;
      int pivots_i1Value5;
      if (!pivots_i1.GetValue(pos, pivots_i1Value1, pivots_i1Value2, pivots_i1Value3, pivots_i1Value4, pivots_i1Value5)) { pivots_i1Value1 = EMPTY_VALUE; pivots_i1Value2 = EMPTY_VALUE; pivots_i1Value3 = EMPTY_VALUE; pivots_i1Value4 = EMPTY_VALUE; pivots_i1Value5 = EMPTY_VALUE; }
      int dir = pivots_i1Value1;
      double phigh = pivots_i1Value2;
      double plow = pivots_i1Value3;
      int phighbar = pivots_i1Value4;
      int plowbar = pivots_i1Value5;
      IFloatArray* zigzagpivotsValue;
      if (!zigzagpivots.GetValue(pos, zigzagpivotsValue)) { zigzagpivotsValue = NULL; }
      IIntArray* zigzagpivotbarsValue;
      if (!zigzagpivotbars.GetValue(pos, zigzagpivotbarsValue)) { zigzagpivotbarsValue = NULL; }
      IIntArray* zigzagpivotdirsValue;
      if (!zigzagpivotdirs.GetValue(pos, zigzagpivotdirsValue)) { zigzagpivotdirsValue = NULL; }
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param1.SetValue(pos, dir);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param2.SetValue(pos, phigh);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param3.SetValue(pos, plow);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param4.SetValue(pos, phighbar);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param5.SetValue(pos, plowbar);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param6.SetValue(pos, zigzagpivotsValue);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param7.SetValue(pos, zigzagpivotbarsValue);
      zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2_param8.SetValue(pos, zigzagpivotdirsValue);
      bool zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2Value;
      if (!zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2.GetValue(pos, zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2Value)) { zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2Value = EMPTY_VALUE; }
      __out1 = zigzagcore_iS_fS_fS_iS_iS_faS_iaS_iaS2Value;
      return true;
   }
};
FloatArrayStream* zigzag_i_faS_iaS_iaS3_param2;
IntArrayStream* zigzag_i_faS_iaS_iaS3_param3;
IntArrayStream* zigzag_i_faS_iaS_iaS3_param4;
zigzag_i_faS_iaS_iaSStream* zigzag_i_faS_iaS_iaS3;
class draw_zigzag_lnaS_faS_iaS_c_i_s_bStream
{
   ILineArrayStream* zigzaglines;
   IFloatArrayStream* zigzagpivots;
   IIntArrayStream* zigzagpivotbars;
   color zigzagcolor;
   int zigzagwidth;
   string zigzagstyle;
   bool showZigZag;
   bool _initialized;
public:
   draw_zigzag_lnaS_faS_iaS_c_i_s_bStream(ILineArrayStream* zigzaglines, IFloatArrayStream* zigzagpivots, IIntArrayStream* zigzagpivotbars, color zigzagcolor, int zigzagwidth, string zigzagstyle, bool showZigZag)
   {
      _initialized = false;
      this.zigzaglines = zigzaglines;
      zigzaglines.AddRef();
      this.zigzagpivots = zigzagpivots;
      zigzagpivots.AddRef();
      this.zigzagpivotbars = zigzagpivotbars;
      zigzagpivotbars.AddRef();
      this.zigzagcolor = zigzagcolor;
      this.zigzagwidth = zigzagwidth;
      this.zigzagstyle = zigzagstyle;
      this.showZigZag = showZigZag;
   }
   ~draw_zigzag_lnaS_faS_iaS_c_i_s_bStream()
   {
      zigzaglines.Release();
      zigzagpivots.Release();
      zigzagpivotbars.Release();
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
      IFloatArray* zigzagpivotsValue;
      if (!zigzagpivots.GetValue(pos, zigzagpivotsValue)) { zigzagpivotsValue = NULL; }
      if (SafeGE(Array::Size(zigzagpivotsValue), 2) && showZigZag)
      {
         double y1 = Array::Get(zigzagpivotsValue, 0);
         double y2 = Array::Get(zigzagpivotsValue, 1);
         IIntArray* zigzagpivotbarsValue;
         if (!zigzagpivotbars.GetValue(pos, zigzagpivotbarsValue)) { zigzagpivotbarsValue = NULL; }
         int x1 = Array::Get(zigzagpivotbarsValue, 0);
         int x2 = Array::Get(zigzagpivotbarsValue, 1);
         Line* zline = LinesCollection::Create(IndicatorObjPrefix + "line_1_id", x1, y1, x2, y2, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(zigzagcolor).SetWidth(zigzagwidth).SetStyle(zigzagstyle);
         ILineArray* zigzaglinesValue;
         if (!zigzaglines.GetValue(pos, zigzaglinesValue)) { zigzaglinesValue = NULL; }
         if (SafeGE(Array::Size(zigzaglinesValue), 1))
         {
            Line* lastLine = Array::Get(zigzaglinesValue, 0);
            if ((x2 == Line::GetX2(lastLine)) && (y2 == Line::GetY2(lastLine)))
            {
               LinesCollection::Delete(lastLine);
            }
         }
         Array::Unshift(zigzaglinesValue, zline);
      }
      return true;
   }
};
LineArrayStream* draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param1;
FloatArrayStream* draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param2;
IntArrayStream* draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param3;
draw_zigzag_lnaS_faS_iaS_c_i_s_bStream* draw_zigzag_lnaS_faS_iaS_c_i_s_b4;
class std_dev_faS_fS_iSStream
{
   IFloatArrayStream* zigzagpivots;
   IStream* ma;
   IIntStream* Length;
   bool _initialized;
public:
   std_dev_faS_fS_iSStream(IFloatArrayStream* zigzagpivots, IStream* ma, IIntStream* Length)
   {
      _initialized = false;
      this.zigzagpivots = zigzagpivots;
      zigzagpivots.AddRef();
      this.ma = ma;
      ma.AddRef();
      this.Length = Length;
      Length.AddRef();
   }
   ~std_dev_faS_fS_iSStream()
   {
      zigzagpivots.Release();
      ma.Release();
      Length.Release();
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
      double devsq = 0.0;
      int LengthValue;
      if (!Length.GetValue(pos, LengthValue)) { LengthValue = EMPTY_VALUE; }
      if ((LengthValue != 0))
      {
         int for2_from = 0;
         int for2_to = SafeMinus(LengthValue, 1);
         if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { return false; }
         for (int i = for2_from; i <= for2_to; i += 1)
         {
            IFloatArray* zigzagpivotsValue;
            if (!zigzagpivots.GetValue(pos, zigzagpivotsValue)) { zigzagpivotsValue = NULL; }
            double pivot = Array::Get(zigzagpivotsValue, i);
            double maValue;
            if (!ma.GetValue(pos, maValue)) { maValue = EMPTY_VALUE; }
            devsq = SafePlus(devsq, SafeMultiply((SafeMinus(pivot, maValue)), (SafeMinus(pivot, maValue))));
            devsq;
         }
      }
      __out1 = SafeMathSqrt(SafeDivide(devsq, LengthValue));
      return true;
   }
};
class get_zigzag_ma_faS_iaS_iStream
{
   IFloatArrayStream* zigzagpivots;
   IIntArrayStream* zigzagpivotdirs;
   int MALength;
   FloatArrayStream* std_dev_faS_fS_iS5_param1;
   FloatStream* std_dev_faS_fS_iS5_param2;
   IntStream* std_dev_faS_fS_iS5_param3;
   std_dev_faS_fS_iSStream* std_dev_faS_fS_iS5;
   bool _initialized;
public:
   get_zigzag_ma_faS_iaS_iStream(IFloatArrayStream* zigzagpivots, IIntArrayStream* zigzagpivotdirs, int MALength)
   {
      _initialized = false;
      this.zigzagpivots = zigzagpivots;
      zigzagpivots.AddRef();
      this.zigzagpivotdirs = zigzagpivotdirs;
      zigzagpivotdirs.AddRef();
      this.MALength = MALength;
   }
   ~get_zigzag_ma_faS_iaS_iStream()
   {
      zigzagpivots.Release();
      zigzagpivotdirs.Release();
      std_dev_faS_fS_iS5_param1.Release();
      std_dev_faS_fS_iS5_param2.Release();
      std_dev_faS_fS_iS5_param3.Release();
      delete std_dev_faS_fS_iS5;
   }
   int Init(int id)
   {
      std_dev_faS_fS_iS5_param1 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      std_dev_faS_fS_iS5_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      std_dev_faS_fS_iS5_param3 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      std_dev_faS_fS_iS5 = new std_dev_faS_fS_iSStream(std_dev_faS_fS_iS5_param1, std_dev_faS_fS_iS5_param2, std_dev_faS_fS_iS5_param3);
      id = std_dev_faS_fS_iS5.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1, double &__out2, double &__out3, double &__out4)
   {
      if (!_initialized)
      {
         std_dev_faS_fS_iS5_param1.Init();
         std_dev_faS_fS_iS5_param2.Init();
         std_dev_faS_fS_iS5_param3.Init();
         std_dev_faS_fS_iS5.Clear();
         _initialized = true;
      }
      IFloatArray* zigzagpivotsValue;
      if (!zigzagpivots.GetValue(pos, zigzagpivotsValue)) { zigzagpivotsValue = NULL; }
      int Length = SafeMathMin(MALength, Array::Size(zigzagpivotsValue));
      double maHigh = 0.0;
      double maLow = 0.0;
      double ma = 0.0;
      if ((Length != 0))
      {
         int for1_from = 0;
         int for1_to = SafeMinus(Length, 1);
         if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { return false; }
         for (int i = for1_from; i <= for1_to; i += 1)
         {
            double pivot = Array::Get(zigzagpivotsValue, i);
            IIntArray* zigzagpivotdirsValue;
            if (!zigzagpivotdirs.GetValue(pos, zigzagpivotdirsValue)) { zigzagpivotdirsValue = NULL; }
            int dir = Array::Get(zigzagpivotdirsValue, i);
            ma = SafePlus(ma, pivot);
            maHigh = SafePlus(maHigh, ((SafeGreater(dir, 0) ? pivot : 0)));
            maLow = SafePlus(maLow, ((SafeLess(dir, 0) ? pivot : 0)));
            maLow;
         }
      }
      maHigh = SafeDivide(SafeMultiply(maHigh, 2), Length);
      maLow = SafeDivide(SafeMultiply(maLow, 2), Length);
      ma = SafeDivide(ma, Length);
      std_dev_faS_fS_iS5_param1.SetValue(pos, zigzagpivotsValue);
      std_dev_faS_fS_iS5_param2.SetValue(pos, ma);
      std_dev_faS_fS_iS5_param3.SetValue(pos, Length);
      double std_dev_faS_fS_iS5Value;
      if (!std_dev_faS_fS_iS5.GetValue(pos, std_dev_faS_fS_iS5Value)) { std_dev_faS_fS_iS5Value = EMPTY_VALUE; }
      double stddev = std_dev_faS_fS_iS5Value;
      __out1 = ma;
      __out2 = maHigh;
      __out3 = maLow;
      __out4 = stddev;
      return true;
   }
};
FloatArrayStream* get_zigzag_ma_faS_iaS_i6_param1;
IntArrayStream* get_zigzag_ma_faS_iaS_i6_param2;
get_zigzag_ma_faS_iaS_iStream* get_zigzag_ma_faS_iaS_i6;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];

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
   IndicatorBuffers(8);
   int id = 0;
   MALength = param1;
   Mult = param2;
   showZigZag = param3;
   zigzagLength = param4;
   zigzagColor = param5;
   cloudTransparency = param6;
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Blue);
   SetIndexBuffer(id, plot2);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Lime);
   SetIndexBuffer(id, plot3);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Green);
   SetIndexBuffer(id, plot4);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Teal);
   SetIndexBuffer(id, plot5);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Orange);
   SetIndexBuffer(id, plot6);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Red);
   SetIndexBuffer(id, plot7);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Maroon);
   IndicatorObjPrefix = GenerateIndicatorPrefix("ZigZag Cloud");
   IndicatorShortName("Zigzag Cloud");
   __array1 = new FloatArray(0, NULL);
   __array2 = new IntArray(0, NULL);
   __array3 = new IntArray(0, NULL);
   __array4 = new LineArray(0, NULL);
   zigzag_i_faS_iaS_iaS3_param2 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   zigzag_i_faS_iaS_iaS3_param3 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   zigzag_i_faS_iaS_iaS3_param4 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   zigzag_i_faS_iaS_iaS3 = new zigzag_i_faS_iaS_iaSStream(zigzagLength, zigzag_i_faS_iaS_iaS3_param2, zigzag_i_faS_iaS_iaS3_param3, zigzag_i_faS_iaS_iaS3_param4);
   id = zigzag_i_faS_iaS_iaS3.Init(id);
   draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param1 = new LineArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param2 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param3 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   draw_zigzag_lnaS_faS_iaS_c_i_s_b4 = new draw_zigzag_lnaS_faS_iaS_c_i_s_bStream(draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param1, draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param2, draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param3, zigzagColor, zigzagWidth, zigzagStyle, showZigZag);
   id = draw_zigzag_lnaS_faS_iaS_c_i_s_b4.Init(id);
   get_zigzag_ma_faS_iaS_i6_param1 = new FloatArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   get_zigzag_ma_faS_iaS_i6_param2 = new IntArrayStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   get_zigzag_ma_faS_iaS_i6 = new get_zigzag_ma_faS_iaS_iStream(get_zigzag_ma_faS_iaS_i6_param1, get_zigzag_ma_faS_iaS_i6_param2, MALength);
   id = get_zigzag_ma_faS_iaS_i6.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete __array1;
   delete __array2;
   delete __array3;
   delete __array4;
   zigzag_i_faS_iaS_iaS3_param2.Release();
   zigzag_i_faS_iaS_iaS3_param3.Release();
   zigzag_i_faS_iaS_iaS3_param4.Release();
   delete zigzag_i_faS_iaS_iaS3;
   draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param1.Release();
   draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param2.Release();
   draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param3.Release();
   delete draw_zigzag_lnaS_faS_iaS_c_i_s_b4;
   get_zigzag_ma_faS_iaS_i6_param1.Release();
   get_zigzag_ma_faS_iaS_i6_param2.Release();
   delete get_zigzag_ma_faS_iaS_i6;
   LinesCollection::Clear();
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
      zigzagpivots = __array1.Clear();
      zigzagpivotbars = __array2.Clear();
      zigzagpivotdirs = __array3.Clear();
      zigzaglines = __array4.Clear();
      zigzag_i_faS_iaS_iaS3_param2.Init();
      zigzag_i_faS_iaS_iaS3_param3.Init();
      zigzag_i_faS_iaS_iaS3_param4.Init();
      zigzag_i_faS_iaS_iaS3.Clear();
      draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param1.Init();
      draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param2.Init();
      draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param3.Init();
      draw_zigzag_lnaS_faS_iaS_c_i_s_b4.Clear();
      get_zigzag_ma_faS_iaS_i6_param1.Init();
      get_zigzag_ma_faS_iaS_i6_param2.Init();
      get_zigzag_ma_faS_iaS_i6.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
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
      zigzagWidth = 1;
      zigzagStyle = "solid";
      max_array_size = MALength + 10;
      zigzag_i_faS_iaS_iaS3_param2.SetValue(pos, zigzagpivots);
      zigzag_i_faS_iaS_iaS3_param3.SetValue(pos, zigzagpivotbars);
      zigzag_i_faS_iaS_iaS3_param4.SetValue(pos, zigzagpivotdirs);
      bool zigzag_i_faS_iaS_iaS3Value;
      if (!zigzag_i_faS_iaS_iaS3.GetValue(pos, zigzag_i_faS_iaS_iaS3Value)) { zigzag_i_faS_iaS_iaS3Value = EMPTY_VALUE; }
      bool ZG = zigzag_i_faS_iaS_iaS3Value;
      if (ZG)
      {
         draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param1.SetValue(pos, zigzaglines);
         draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param2.SetValue(pos, zigzagpivots);
         draw_zigzag_lnaS_faS_iaS_c_i_s_b4_param3.SetValue(pos, zigzagpivotbars);
         if (!draw_zigzag_lnaS_faS_iaS_c_i_s_b4.GetValue(pos)) { }
      }
      get_zigzag_ma_faS_iaS_i6_param1.SetValue(pos, zigzagpivots);
      get_zigzag_ma_faS_iaS_i6_param2.SetValue(pos, zigzagpivotdirs);
      double get_zigzag_ma_faS_iaS_i6Value1;
      double get_zigzag_ma_faS_iaS_i6Value2;
      double get_zigzag_ma_faS_iaS_i6Value3;
      double get_zigzag_ma_faS_iaS_i6Value4;
      if (!get_zigzag_ma_faS_iaS_i6.GetValue(pos, get_zigzag_ma_faS_iaS_i6Value1, get_zigzag_ma_faS_iaS_i6Value2, get_zigzag_ma_faS_iaS_i6Value3, get_zigzag_ma_faS_iaS_i6Value4)) { get_zigzag_ma_faS_iaS_i6Value1 = EMPTY_VALUE; get_zigzag_ma_faS_iaS_i6Value2 = EMPTY_VALUE; get_zigzag_ma_faS_iaS_i6Value3 = EMPTY_VALUE; get_zigzag_ma_faS_iaS_i6Value4 = EMPTY_VALUE; }
      double ma = get_zigzag_ma_faS_iaS_i6Value1;
      double maHigh = get_zigzag_ma_faS_iaS_i6Value2;
      double maLow = get_zigzag_ma_faS_iaS_i6Value3;
      double stddev = get_zigzag_ma_faS_iaS_i6Value4;
      color plot1_color = Blue;
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = ma; }
      else { plot1[pos] = EMPTY_VALUE; }
      double MA = plot1[pos];
      color plot2_color = Lime;
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = maHigh; }
      else { plot2[pos] = EMPTY_VALUE; }
      double HighMA = plot2[pos];
      color plot3_color = Green;
      if (plot3_color != EMPTY_VALUE) { plot3[pos] = SafePlus(ma, SafeMultiply(stddev, Mult)); }
      else { plot3[pos] = EMPTY_VALUE; }
      double BBUMa = plot3[pos];
      color plot4_color = Teal;
      if (plot4_color != EMPTY_VALUE) { plot4[pos] = SafePlus(maHigh, SafeMultiply(stddev, Mult)); }
      else { plot4[pos] = EMPTY_VALUE; }
      double BBUHigh = plot4[pos];
      color plot5_color = Orange;
      if (plot5_color != EMPTY_VALUE) { plot5[pos] = maLow; }
      else { plot5[pos] = EMPTY_VALUE; }
      double LowMA = plot5[pos];
      color plot6_color = Red;
      if (plot6_color != EMPTY_VALUE) { plot6[pos] = SafeMinus(ma, SafeMultiply(stddev, Mult)); }
      else { plot6[pos] = EMPTY_VALUE; }
      double BBLMa = plot6[pos];
      color plot7_color = Maroon;
      if (plot7_color != EMPTY_VALUE) { plot7[pos] = SafeMinus(maLow, SafeMultiply(stddev, Mult)); }
      else { plot7[pos] = EMPTY_VALUE; }
      double BBLLow = plot7[pos];
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LinesCollection::Redraw();
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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