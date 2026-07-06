//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74578

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
#property indicator_separate_window
#property indicator_buffers 18
#property indicator_label1 "Volume"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Volume"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Enough and Large Volume"
#property indicator_type3 DRAW_HISTOGRAM
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Enough and Large Volume"
#property indicator_type4 DRAW_HISTOGRAM
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Enough and Large Volume"
#property indicator_type5 DRAW_HISTOGRAM
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Enough and Large Volume"
#property indicator_type6 DRAW_HISTOGRAM
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Enough and Large Volume"
#property indicator_type7 DRAW_HISTOGRAM
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Enough and Large Volume"
#property indicator_type8 DRAW_HISTOGRAM
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Enough and Large Volume"
#property indicator_type9 DRAW_HISTOGRAM
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Enough and Large Volume"
#property indicator_type10 DRAW_HISTOGRAM
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "Enough and Large Volume"
#property indicator_type11 DRAW_HISTOGRAM
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_label12 "Enough and Large Volume"
#property indicator_type12 DRAW_HISTOGRAM
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_label13 "VolumeMA"
#property indicator_type13 DRAW_LINE
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_label14 "Volume Flow"
#property indicator_type14 DRAW_HISTOGRAM
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_label15 "Volume Flow"
#property indicator_type15 DRAW_HISTOGRAM
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_label16 "Volume Flow"
#property indicator_type16 DRAW_HISTOGRAM
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1
#property indicator_label17 "Volume Flow"
#property indicator_type17 DRAW_HISTOGRAM
#property indicator_style17 STYLE_SOLID
#property indicator_width17 1
#property indicator_label18 "Scale Adjustment"
#property indicator_type18 DRAW_LINE
#property indicator_style18 STYLE_SOLID
#property indicator_width18 1

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
// Array v1.0
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
   virtual void Shift() = 0;
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

   void SetX1(int x)
   {
      _x1 = x;
   }
   static void SetX1(Line* line, int x)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetX1(x);
   }
   void SetX2(int x)
   {
      _x2 = x;
   }
   static void SetX2(Line* line, int x)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetX2(x);
   }
   void SetY1(double y)
   {
      _y1 = y;
   }
   static void SetY1(Line* line, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetY1(y);
   }
   void SetY2(double y)
   {
      _y2 = y;
   }
   static void SetY2(Line* line, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetY2(y);
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
   virtual void Shift() = 0;
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
   virtual void Shift() = 0;
};


// Line array v1.0

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
      for (int i = 0; i < size; ++i)
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

   void Shift()
   {
      int size = ArraySize(array);
      for (int i = 0; i < size - 1; ++i)
      {
         array[i] = array[i + 1];
      }
      ArrayResize(array, size - 1);
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
// Int array v1.0


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
      for (int i = 0; i < size; ++i)
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

   void Shift()
   {
      int size = ArraySize(array);
      for (int i = 0; i < size - 1; ++i)
      {
         array[i] = array[i + 1];
      }
      ArrayResize(array, size - 1);
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
// Float array v1.0


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
      for (int i = 0; i < size; ++i)
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

   void Shift()
   {
      int size = ArraySize(array);
      for (int i = 0; i < size - 1; ++i)
      {
         array[i] = array[i + 1];
      }
      ArrayResize(array, size - 1);
   }
   
   IFloatArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }
};

class Array
{
public:
   static void Unshift(IIntArray* array, int value)
   {
      if (array == NULL)
      {
         return;
      }
      array.Unshift(value);
   }
   
   static int Size(ILineArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IIntArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }
   static int Size(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE;} return array.Size(); }

   static void Shift(ILineArray* array) { if (array == NULL) { return; } array.Shift(); }
   static void Shift(IIntArray* array) { if (array == NULL) { return; } array.Shift(); }
   static void Shift(IFloatArray* array) { if (array == NULL) { return; } array.Shift(); }

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

   static void Push(ILineArray* array, Line* value)
   {
      if (array == NULL)
      {
         return;
      }
      array.Push(value);
   }
   static void Push(IIntArray* array, int value)
   {
      if (array == NULL)
      {
         return;
      }
      array.Push(value);
   }
   static void Push(IFloatArray* array, double value)
   {
      if (array == NULL)
      {
         return;
      }
      array.Push(value);
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

   static int Pop(IIntArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      return array.Pop();
   }

   static int Get(IIntArray* array, int index)
   {
      if (array == NULL)
      {
         return 0;
      }
      return array.Get(index);
   }
   static double Get(IFloatArray* array, int index)
   {
      if (array == NULL)
      {
         return 0;
      }
      return array.Get(index);
   }
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
// Custom stream v2.3

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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

// Stream returns rising flag. Similar to ta.rising in PineScript v1.0


class RisingStream
{
   IStream* _source;
   int _length;
   int _refs;
public:
   RisingStream(IStream* source, int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _refs = 1;
   }
   ~RisingStream()
   {
      _source.Release();
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

   bool GetValue(const int period, bool &val)
   {
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double prev;
      if (!_source.GetValue(period + _length, prev))
      {
         return false;
      }
      val = prev < current;
      return true;
   }
};


// EMA on stream v1.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(IStream *source, const int length)
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

// SMA on stream v1.0

#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
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

// Colored stream v3.4

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
public:
   LineColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, 
      int lineType, ENUM_LINE_STYLE lineStyle, int width)
   {
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
      _stream[period] = value;
      if (period + 1 < iBars(_symbol, _timeframe) && _stream[period + 1] == EMPTY_VALUE)
         _stream[period + 1] = prevValue;
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
};

class HistogramColoredStreamData : public IColoredStreamData
{
   LineColoredStreamData* _up;
   LineColoredStreamData* _down;
public:
   HistogramColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, int width)
   {
      _up = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width);
      _down = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width);
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
   double _data[];
public:

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   ~ColoredStream()
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         delete _streams[i];
      }
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         _streams[i].Init(defaultValue);
      }
      ArrayInitialize(_data, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _data);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }
   
   int RegisterArrowStream(int id, color clr, int arrow)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new ArrowColoredStreamData(arrow, clr);
      return _streams[size].Register(id);
   }
   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new LineColoredStreamData(_symbol, _timeframe, clr, label, lineType, lineStyle, width);
      return _streams[size].Register(id);
   }
   int RegisterHistogramStream(int id, color clr, string label = "", int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new HistogramColoredStreamData(_symbol, _timeframe, clr, label, width);
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
   
   double SetByColor(double value, int period, color clr)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].GetColor() == clr)
         {
            Set(value, period, i);
            return value;
         }
      }
      return value;
   }
   
   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      double prevValue = period + 1 >= iBars(_symbol, _timeframe) ? EMPTY_VALUE : _data[period + 1];
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
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

#endif

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

//AOnStream v1.0

class ConditionStream : public AStreamBase
{
protected:
   ICondition* _condition;
public:
   ConditionStream(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~ConditionStream()
   {
      _condition.Release();
   }

   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   bool GetValue(const int period, double &val)
   {
      val = _condition.IsPass(period, 0) ? 1 : 0;
      return true;
   }
};
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


//AOnStream v1.0

class CrossoverStream : public ConditionStream
{
public:
   CrossoverStream(IStream *left, IStream* right)
      :ConditionStream(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""))
   {
      _condition.Release();
   }

   bool GetValue(int pos, bool &val)
   {
      double value;
      if (!GetValue(pos, value))
      {
         return false;
      }
      val = value == 1;
      return true;
   }
};
// Implementation of PineScript's plotchar
// v1.1

class PlotChar
{
   string _char;
   string _id;
public:
   PlotChar(string ch, string id)
   {
      _char = ch;
      _id = id;
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
      double price = iHigh(_Symbol, _Period, pos);
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
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LOWER);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, time);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, _char);
   }
};
#define ColorRGB(red, green, blue, transp) red + (green << 8) + (blue << 16)

bool NumberToBool(double number)
{
   return number != EMPTY_VALUE;
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
input color param1 = 0x000000; // Hollow Candle (Decreasing Volume)
input color param2 = 0x00FF00; // Up Candle (Increasing Volume + Over VolumeMA)
input color param3 = 0x0000FF; // Dn Candle (Increasing Volume + Over VolumeMA)
input int param4 = 20; // VolumeMA length
input bool param5 = true; // Use EMA
input color param6 = Blue; //   
input double param7 = 1.4; // Factor for Volume Density 
input double param8 = 5; // Factor for Volume Spike 
input int bars_limit = 100000; // Bars limit
color decvol;
color hivolup;
color hivoldn;
int length;
bool useEma;
color vMAclr;
double f;
IFloatArray* __array1;
IFloatArray* scaleMax;
CustomStream* rising1Source;
RisingStream* rising1;
CustomStream* ema1Source;
EMAOnStream* ema1;
CustomStream* sma1Source;
SmaOnStream* sma1;
CustomStream* ema2Source;
EMAOnStream* ema2;
CustomStream* sma2Source;
SmaOnStream* sma2;
ColoredStream* plot1;
ColoredStream* plot3;
double plot13[];
double x;
CustomStream* ema3Source;
EMAOnStream* ema3;
CustomStream* sma3Source;
SmaOnStream* sma3;
CustomStream* ema4Source;
EMAOnStream* ema4;
CustomStream* sma4Source;
SmaOnStream* sma4;
CustomStream* crossover1X;
CustomStream* crossover1Y;
CrossoverStream* crossover1;
CustomStream* crossover2X;
CustomStream* crossover2Y;
CrossoverStream* crossover2;
ColoredStream* plot14;
PlotChar* plotchar1;
PlotChar* plotchar2;
PlotChar* plotchar3;
PlotChar* plotchar4;
double plot18[];

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
   IndicatorBuffers(21);
   int id = 0;
   decvol = param1;
   hivolup = param2;
   hivoldn = param3;
   length = param4;
   useEma = param5;
   vMAclr = param6;
   f = param7;
   rising1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rising1 = new RisingStream(rising1Source, 1);
   ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, length);
   sma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, length);
   ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, length);
   sma2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, length);
   plot1 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot1.RegisterStream(id, hivolup);
   id = plot1.RegisterStream(id, hivoldn);
   plot3 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot3.RegisterHistogramStream(id, (color)(EMPTY_VALUE));
   id = plot3.RegisterHistogramStream(id, hivolup);
   id = plot3.RegisterHistogramStream(id, hivolup);
   id = plot3.RegisterHistogramStream(id, hivoldn);
   id = plot3.RegisterHistogramStream(id, hivoldn);
   SetIndexBuffer(id, plot13);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, vMAclr);
   x = param8;
   ema3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, length);
   sma3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, length);
   ema4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema4 = new EMAOnStream(ema4Source, length);
   sma4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma4 = new SmaOnStream(sma4Source, length);
   crossover1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = new CrossoverStream(crossover1X, crossover1Y);
   crossover2X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = new CrossoverStream(crossover2X, crossover2Y);
   plot14 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot14.RegisterHistogramStream(id, hivolup);
   id = plot14.RegisterHistogramStream(id, hivoldn);
   SetIndexBuffer(id, plot18);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, (color)(EMPTY_VALUE));
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Vol (Wyckoff)");
   __array1 = new FloatArray(0, NULL);
   id = plot1.RegisterInternalStream(id);
   id = plot3.RegisterInternalStream(id);
   id = plot14.RegisterInternalStream(id);
   plotchar1 = new PlotChar("I", IndicatorObjPrefix + "plotchar1");
   plotchar2 = new PlotChar("I", IndicatorObjPrefix + "plotchar2");
   plotchar3 = new PlotChar("O", IndicatorObjPrefix + "plotchar3");
   plotchar4 = new PlotChar("O", IndicatorObjPrefix + "plotchar4");
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete __array1;
   rising1Source.Release();
   rising1.Release();
   ema1Source.Release();
   ema1.Release();
   sma1Source.Release();
   sma1.Release();
   ema2Source.Release();
   ema2.Release();
   sma2Source.Release();
   sma2.Release();
   delete plot1;
   delete plot3;
   ema3Source.Release();
   ema3.Release();
   sma3Source.Release();
   sma3.Release();
   ema4Source.Release();
   ema4.Release();
   sma4Source.Release();
   sma4.Release();
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   delete plot14;
   delete plotchar1;
   delete plotchar2;
   delete plotchar3;
   delete plotchar4;
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
      scaleMax = __array1.Clear();
      rising1Source.Init();
      ema1Source.Init();
      sma1Source.Init();
      ema2Source.Init();
      sma2Source.Init();
      plot1.Init(EMPTY_VALUE);
      plot3.Init(EMPTY_VALUE);
      ArrayInitialize(plot13, EMPTY_VALUE);
      ema3Source.Init();
      sma3Source.Init();
      ema4Source.Init();
      sma4Source.Init();
      crossover1X.Init();
      crossover1Y.Init();
      crossover2X.Init();
      crossover2Y.Init();
      plot14.Init(EMPTY_VALUE);
      ArrayInitialize(plot18, EMPTY_VALUE);
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
      color vpclr = White;
      double vol = tick_volume[pos];
      double hl = high[pos] - low[pos];
      double vp = SafeDivide(vol, hl);
      rising1Source.SetValue(pos, vol);
      bool rising1Value;
      if (!rising1.GetValue(pos, rising1Value)) { rising1Value = EMPTY_VALUE; }
      bool upVol = rising1Value;
      bool upBar = (close[pos] > open[pos]);
      ema1Source.SetValue(pos, vol);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      sma1Source.SetValue(pos, vol);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double vMA = (useEma ? ema1Value : sma1Value);
      bool volOverMa = SafeGreater(vol, vMA);
      bool hollowBgdBlack = !upVol;
      bool upVolUpMaUpBar = upVol && volOverMa && upBar;
      bool upVolUpMaDnBar = upVol && volOverMa && !upBar;
      color chollowBgdBlack = (hollowBgdBlack ? decvol : EMPTY_VALUE);
      color cUpVolUpMaUpBar = (upVolUpMaUpBar ? hivolup : EMPTY_VALUE);
      color cUpVolUpMaDnBar = (upVolUpMaDnBar ? hivoldn : EMPTY_VALUE);
      color volumeclr = (hollowBgdBlack ? (color)(EMPTY_VALUE) : (upBar ? (upVolUpMaUpBar ? hivolup : hivolup) : (upVolUpMaDnBar ? hivoldn : hivoldn)));
      ema2Source.SetValue(pos, vp);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      sma2Source.SetValue(pos, vp);
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
      double vpMA = (useEma ? ema2Value : sma2Value);
      double vpS = (SafeGreater(vp, SafeMultiply(vpMA, f)) && SafeLE(vp, SafeMultiply(SafeMultiply(vpMA, f), f)) ? vol : EMPTY_VALUE);
      double vpL = (SafeGreater(vp, SafeMultiply(SafeMultiply(vpMA, f), f)) ? vol : EMPTY_VALUE);
      Array::Push(scaleMax, vol);
      if (SafeGreater(Array::Size(scaleMax), length * 4))
      {
         Array::Shift(scaleMax);
      }
      double scalebase = Array::Max(scaleMax);
      double upperline = SafeMultiply(scalebase, 4);
      plot1.SetByColor(vol, pos, ((close[pos] > open[pos]) ? hivolup : hivoldn));
      plot3.SetByColor(vol, pos, volumeclr);
      color plot13_color = vMAclr;
      if (plot13_color != EMPTY_VALUE) { plot13[pos] = vMA; }
      else { plot13[pos] = EMPTY_VALUE; }
      double bull = (upVol && upBar ? vol : 0);
      double bear = (upVol && !upBar ? vol : 0);
      ema3Source.SetValue(pos, bull);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
      sma3Source.SetValue(pos, bull);
      double sma3Value;
      if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
      double bullma = (useEma ? ema3Value : sma3Value);
      ema4Source.SetValue(pos, bear);
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
      sma4Source.SetValue(pos, bear);
      double sma4Value;
      if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
      double bearma = (useEma ? ema4Value : sma4Value);
      double vf_dif = SafeMinus(bullma, bearma);
      double vf_absolute = (SafeGreater(vf_dif, 0) ? vf_dif : SafeMultiply(vf_dif, ((-1))));
      crossover1X.SetValue(pos, bull);
      crossover1Y.SetValue(pos, SafeMultiply(bullma, x));
      bool crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { crossover1Value = EMPTY_VALUE; }
      double gsig = (crossover1Value ? vol : EMPTY_VALUE);
      crossover2X.SetValue(pos, bear);
      crossover2Y.SetValue(pos, SafeMultiply(bearma, x));
      bool crossover2Value;
      if (!crossover2.GetValue(pos, crossover2Value)) { crossover2Value = EMPTY_VALUE; }
      double rsig = (crossover2Value ? vol : EMPTY_VALUE);
      color vdClr = (SafeGreater(vf_dif, 0) ? hivolup : hivoldn);
      plot14.SetByColor(vf_absolute, pos, vdClr);
      plotchar1.Set(pos, NumberToBool(gsig), hivolup);
      plotchar2.Set(pos, NumberToBool(rsig), hivoldn);
      plotchar3.Set(pos, NumberToBool(vpS), vpclr);
      plotchar4.Set(pos, NumberToBool(vpL), vpclr);
      color plot18_color = (color)(EMPTY_VALUE);
      if (plot18_color != EMPTY_VALUE) { plot18[pos] = upperline; }
      else { plot18[pos] = EMPTY_VALUE; }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
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