//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75215

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

#property indicator_separate_window
#property indicator_buffers 58
#property indicator_plots 27
#property indicator_label1 "Regular Bullish"
#property indicator_type1 DRAW_COLOR_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Regular Bullish Label"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Hidden Bullish"
#property indicator_type3 DRAW_COLOR_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Hidden Bullish Label"
#property indicator_type4 DRAW_ARROW
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Regular Bearish"
#property indicator_type5 DRAW_COLOR_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Regular Bearish Label"
#property indicator_type6 DRAW_ARROW
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Hidden Bearish"
#property indicator_type7 DRAW_COLOR_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Hidden Bearish Label"
#property indicator_type8 DRAW_ARROW
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Sell Zone"
#property indicator_type9 DRAW_LINE
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Buy Zone"
#property indicator_type10 DRAW_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "Absolute Max"
#property indicator_type11 DRAW_LINE
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_label12 "Absolute Min"
#property indicator_type12 DRAW_LINE
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_type13 DRAW_FILLING
#property indicator_width13 1
#property indicator_type14 DRAW_FILLING
#property indicator_width14 1
#property indicator_label15 "Kumo Implied Historical Volatility"
#property indicator_type15 DRAW_COLOR_HISTOGRAM
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_label16 "TSI Line"
#property indicator_type16 DRAW_LINE
#property indicator_style16 STYLE_SOLID
#property indicator_width16 2
#property indicator_label17 "TSI Signal Line"
#property indicator_type17 DRAW_LINE
#property indicator_style17 STYLE_SOLID
#property indicator_width17 2
#property indicator_label18 "Zero"
#property indicator_type18 DRAW_LINE
#property indicator_style18 STYLE_SOLID
#property indicator_width18 1
#property indicator_label19 "Zero"
#property indicator_type19 DRAW_LINE
#property indicator_style19 STYLE_DASH
#property indicator_width19 1
#property indicator_label20 "Overbought"
#property indicator_type20 DRAW_LINE
#property indicator_style20 STYLE_DASH
#property indicator_width20 1
#property indicator_label21 "Oversold"
#property indicator_type21 DRAW_LINE
#property indicator_style21 STYLE_DASH
#property indicator_width21 1
#property indicator_label22 "TSI Pivot High"
#property indicator_type22 DRAW_ARROW
#property indicator_style22 STYLE_SOLID
#property indicator_width22 1
#property indicator_label23 "TSI Pivot Low"
#property indicator_type23 DRAW_ARROW
#property indicator_style23 STYLE_SOLID
#property indicator_width23 1
#property indicator_label24 "WT Pivot High"
#property indicator_type24 DRAW_ARROW
#property indicator_style24 STYLE_SOLID
#property indicator_width24 1
#property indicator_label25 "WT Pivot High"
#property indicator_type25 DRAW_ARROW
#property indicator_style25 STYLE_SOLID
#property indicator_width25 1
#property indicator_label26 "WT Pivot Low"
#property indicator_type26 DRAW_ARROW
#property indicator_style26 STYLE_SOLID
#property indicator_width26 1
#property indicator_label27 "WT Pivot Low"
#property indicator_type27 DRAW_ARROW
#property indicator_style27 STYLE_SOLID
#property indicator_width27 1

// Pine-script like safe operations
// v1.1

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
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL
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
#ifndef ChangeStream_IMPL
#define ChangeStream_IMPL



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
// Boolean Stream v.1.0

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, bool &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, bool &val[]) = 0;
};

#endif
#ifndef BoolToFloatStream_IMPL
#define BoolToFloatStream_IMPL



// Bool to float stream v1.0

class BoolToFloatStream : public AFloatStream
{
   IBoolStream* stream;
public:
   BoolToFloatStream(IBoolStream* stream)
   {
      this.stream = stream;
      stream.AddRef();
   }
   ~BoolToFloatStream()
   {
      stream.Release();
   }

   void Init()
   {
   }

   virtual int Size()
   {
      return stream.Size();
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      bool values[];
      ArrayResize(values, count);
      if (!stream.GetValues(period, count, values))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = values[i] ? 1 : 0;
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
};

#endif

//ChangeStream v1.2
class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period >= Size() - 2)
      {
         return false;
      }
      int size = Size();
      double src1[1], src2[1];
      if (!_source.GetSeriesValues(period, 1, src1) || !_source.GetSeriesValues(period + _period, 1, src2))
      {
         return false;
      }
      val = src1[0] - src2[0];
      return true;
   }
};

class ChangeStreamFactory
{
public:
   static IStream* Create(IStream* stream, int period = 1)
   {
      return new ChangeStream(stream, period);
   }
   
   static IStream* Create(IBoolStream* stream, int period = 1)
   {
      BoolToFloatStream* wrapper = new BoolToFloatStream(stream);
      ChangeStream* change = new ChangeStream(wrapper, period);
      wrapper.Release();
      return change;
   }
};

#endif 


// EMA on stream v1.1

class EMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   EMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 2.0 / (_length + 1.0);
   }

   bool GetSeriesValue(const int period, double &val)
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
      double current[1];
      if (!_source.GetSeriesValues(period, 1, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current[0];
      _buffer[bufferIndex] = (1 - _k) * last + _k * current[0];
      val = _buffer[bufferIndex];
      return true;
   }
};
// WMA on stream v1.2


class StreamBuffer
{
public:
   double _data[];

   void EnsureSize(int size)
   {
      int currentSize = ArrayRange(_data, 0);
      if (currentSize != size) 
      {
         ArrayResize(_data, size);
         for (int i = currentSize; i < size; ++i)
         {
            _data[i] = EMPTY_VALUE;
         }
      }
   }
};

class WMAOnStream : public AOnStream
{
   int _length;
   double _k;
   StreamBuffer _buffer;
public:
   WMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 1.0 / (_length);
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      _buffer.EnsureSize(totalBars);
      int bufferIndex = totalBars - 1 - period;
      if (bufferIndex < 0)
      {
         return false;
      }

      double current[1];
      if (!_source.GetSeriesValues(period, 1, current))
      {
         return false;
      }
      
      double last = _buffer._data[bufferIndex - 1] != EMPTY_VALUE ? _buffer._data[bufferIndex - 1] : current[0];

      _buffer._data[bufferIndex] = (current[0] - last) * _k + last;
      val = _buffer._data[bufferIndex];
      return true;
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


//RmaOnStream v2.4
class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
         return false;

      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != size) 
      {
         ArrayResize(_buffer, size);
         for (int i = currentBufferSize; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double alpha = 1.0 / _length;
      int index = size - 1 - period;
      if (index == 0 || _buffer[index - 1] == EMPTY_VALUE)
      {
         _buffer[index] = price[0];
      }
      else
      {
         _buffer[index] = alpha * price[0] + (1 - alpha) * _buffer[index - 1];
      }
      val = _buffer[index];
      return true;
   }
};

// Pivot low stream v1.0


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
// Pivot high stream v1.0





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
// Value when stream (condition as a parameter) v1.0


// ICondition v3.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};
#endif

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

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream, INDICATOR_CALCULATIONS);
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
         if (size - 1 - _shift >= 0)
         {
            _stream[period] = _values[size - 1 - _shift];
         }
         else
         {
            _stream[period] = EMPTY_VALUE;
         }
      }
      else if (period > 0)
      {
         _stream[period] = _stream[period - 1];
      }
      return _stream[period];
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; i++)
      {
         if (_stream[period - i] == EMPTY_VALUE)
         {
            return false;
         }
         val[i] = _stream[period - i];
      }
      return true;
   }
};
#ifndef BoolStream_IMPL
#define BoolStream_IMPL

// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL


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
// Bool stream v2.0

class BoolStream : public ABoolStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
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
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, bool value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, bool &val[])
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
   
   virtual bool GetSeriesValues(const int period, const int count, bool &val[])
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
#ifndef BarsSinceStreamV2_IMPL
#define BarsSinceStreamV2_IMPL

// Abstract Int stream v1.0

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

   virtual bool GetValues(const int period, const int count, int &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
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
// v1.0

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
         bool val[1];
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
// Colored plor v1.0


class ColoredPlot
{
   int plotIndex;
   double values[];
   double colors[];
   double buffer[];
   
   uint initColors[];
   int offset;
public:
   ColoredPlot(int plotIndex)
   {
      this.plotIndex = plotIndex;
      offset = INT_MIN;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      int colorsCount = ArraySize(initColors);
      ArrayResize(initColors, colorsCount + 1);
      initColors[colorsCount] = GetColorOnly(clr);
   }
   
   void SetOffset(int offset)
   {
      this.offset = offset;
   }
   
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, values, INDICATOR_DATA);
      int colorsCount = ArraySize(initColors);
      PlotIndexSetInteger(plotIndex, PLOT_COLOR_INDEXES, colorsCount);
      for (int i = 0; i < colorsCount; ++i)
      {
         PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, i, initColors[i]);
      }
      if (offset != INT_MIN)
      {
         PlotIndexSetInteger(plotIndex, PLOT_SHIFT, offset);
      }
      id += 1;
      SetIndexBuffer(id++, colors, INDICATOR_COLOR_INDEX);
      return id;
   }
   int RegisterInternalStreams(int id)
   {
      SetIndexBuffer(id++, buffer, INDICATOR_CALCULATIONS);
      return id;
   }
   
   void Init()
   {
      ArrayInitialize(values, EMPTY_VALUE);
      ArrayInitialize(colors, EMPTY_VALUE);
      ArrayInitialize(buffer, EMPTY_VALUE);
   }
   
   void Set(int pos, double value, uint clr)
   {
      int transp = GetTranparency(clr);
      buffer[pos] = value;
      values[pos] = value;
      colors[pos] = FindColorIndex(clr);
      if (value == EMPTY_VALUE)
      {
         values[pos] = EMPTY_VALUE;
         colors[pos] = EMPTY_VALUE;
         buffer[pos] = EMPTY_VALUE;
         return;
      }
      int prevValueIndex = FindPrevValueIndex(pos);
      if (prevValueIndex == -1)
      {
         return;
      }
      int length = pos - prevValueIndex + 1;
      if (colors[pos] == -1)
      {
         for (int i = 1; i < length; ++i)
         {
            values[prevValueIndex + i] = EMPTY_VALUE;
            colors[prevValueIndex + i] = EMPTY_VALUE;
         }
         return;
      }
      double diff = buffer[pos] - buffer[prevValueIndex];
      double step = diff / (length - 1);
      for (int i = 0; i < length; ++i)
      {
         values[prevValueIndex + i] = buffer[prevValueIndex] + step * i;
         colors[prevValueIndex + i] = colors[pos];
      }
   }
private:
   int FindPrevValueIndex(int pos)
   {
      for (int i = pos - 1; i >= 0; --i)
      {
         if (buffer[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return -1;
   }
   int FindColorIndex(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return -1;
      }
      color searchingColor = GetColorOnly(clr);
      int colorsCount = ArraySize(initColors);
      for (int i = 0; i < colorsCount; ++i)
      {
         if (initColors[i] == searchingColor)
         {
            return i;
         }
      }
      return -1;
   }
};




// Highest high stream v1.6

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
      double values[];
      ArrayResize(values, loopback);
      if (!source.GetValues(period, loopback, values))
      {
         return false;
      }
      val = values[0];

      for (int i = 1; i < loopback; ++i)
      {
         val = MathMax(val, values[i]);
      }
      return true;
   }
   
   static bool GetValues(const int period, int count, double &val[], IStream* source, int loopback)
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period - i, v, source, loopback))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int oldPos = Size() - period - 1;
      return HighestHighStream::GetValue(oldPos, val, _source, _loopback);
   }
};




// Lowest low stream v1.6

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
      double values[];
      ArrayResize(values, loopback);
      if (!source.GetValues(period, loopback, values))
      {
         return false;
      }
      val = values[0];

      for (int i = 1; i < loopback; ++i)
      {
         val = MathMin(val, values[i]);
      }
      return true;
   }
   
   static bool GetValues(const int period, int count, double &val[], IStream* source, int loopback)
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period - i, v, source, loopback))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int oldPos = Size() - period - 1;
      return LowestLowStream::GetValue(oldPos, val, _source, _loopback);
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


// StDev stream v1.2

class StDevStream : public AOnStream
{
   int _period;
public:
   StDevStream(IStream* __source, int period)
      :AOnStream(__source)
   {
      _period = period;
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      double sum = 0;
      double ssum = 0;
      double __data[];
      ArrayResize(__data, _period);
      if (!_source.GetSeriesValues(period, _period, __data))
      {
         return false;
      }
      for (int i = 0; i < _period; i++)
      {
         sum += __data[i];
         ssum += MathPow(__data[i], 2);
      }
      val = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
      return true;
   }
};

// MFI on stream v1.0

#ifndef MfiOnStream_IMP
#define MfiOnStream_IMP


class MfiOnStream : public AOnStream
{
   int _length;
public:
   MfiOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      return GetValue(Size() - period - 1, val);
   }
private:
   bool GetValue(const int period, double &val)
   {
      double current[1];
      if (!_source.GetValues(period, 1, current))
      {
         return false;
      }
      int oldPos = Size() - period - 1;
      double upper = 0;
      double lower = 0;
      for (int i = 0; i < _length; i++)
      {
         double prev[1];
         if (!_source.GetValues(period - i - 1, 1, prev))
         {
            continue;
         }
         if (prev[0] - current[0] >= 0)
         {
            upper += current[0] * iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + i);
         }
         else
         {
            lower += current[0] * iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + i);
         }
         current[0] = prev[0];
      }
      if (lower == 0)
      {
         val = 100.0;
         return true;
      }
      val = 100.0 - (100.0 / (1.0 + upper / lower));
      return true;
   }
};

#endif

#ifndef PriceStreamFactory_IMPL
#define PriceStreamFactory_IMPL

// price stream factory v1.0



// IBarStream v1.0



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

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};
#endif


// Price stream v3.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

class PriceStream : public AStreamBase
{
   PriceType _price;
   IBarStream* _source;
public:
   PriceStream(IBarStream* source, const PriceType __price)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
      _price = __price;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &values[])
   {
      return false;
   }

   virtual bool GetValues(const int period, const int count, double &values[])
   {
      for (int i = 0; i < count; ++i)
      {
         double val;
         switch (_price)
         {
            case PriceClose:
               if (!_source.GetClose(period - i, val))
               {
                  return false;
               }
               break;
            case PriceOpen:
               if (!_source.GetOpen(period - i, val))
               {
                  return false;
               }
               break;
            case PriceHigh:
               if (!_source.GetHigh(period - i, val))
               {
                  return false;
               }
               break;
            case PriceLow:
               if (!_source.GetLow(period - i, val))
               {
                  return false;
               }
               break;
            case PriceMedian:
               {
                  double high, low;
                  if (!_source.GetHighLow(period - i, high, low))
                  {
                     return false;
                  }
                  val = (high + low) / 2.0;
               }
               break;
            case PriceTypical:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close) / 3.0;
               }
               break;
            case PriceWeighted:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close * 2) / 4.0;
               }
               break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period - i, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period - i, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period - i, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         }
         values[i] = val;
      }
      return true;
   }
};

#endif
// Bar stream v2.0



#ifndef BarStream_IMP
#define BarStream_IMP

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _referenceCount;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _referenceCount = 1;
      _symbol = symbol;
      _timeframe = timeframe;
   }
   virtual void AddRef()
   {
      ++_referenceCount;
   }
   virtual void Release()
   {
      --_referenceCount;
      if (_referenceCount == 0)
         delete &this;
   }
   
   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = Size() - iBarShift(_symbol, _timeframe, date) + 1;
      return true;
   }
   
   virtual bool GetDate(const int period, datetime &dt)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      dt = iTime(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos + count - 1)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int oldPos, const int count, double &val[])
   {
      int size = Size();
      if (size <= oldPos + count - 1)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual void Refresh() { }
};

#endif

class PriceStreamFactory
{
public:
   static IStream* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      IStream* stream = new PriceStream(source, price);
      source.Release();
      return stream;
   }
};
#endif
// Percent rank v1.0

#ifndef PercentRank_IMP
#define PercentRank_IMP



class PercentRank : public AOnStream
{
   int length;
public:
   PercentRank(IStream* stream, int length)
      :AOnStream(stream)
   {
      this.length = length;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      return false;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (totalBars == 0)
      {
         return false;
      }
      
      double target[];
      ArrayResize(target, length + 1);
      if (!_source.GetValues(period, length + 1, target))
      {
         return false;
      }
      int count = 0;
      for (int i = 1; i < length; ++i)
      {
         int current = target[i];
         if (current != EMPTY_VALUE && target[0] >= current)
         {
            count++;
         }
      }
      val = (count * 100.0) / length;
      return true;
   }
};


#endif


// Boilinger Band Width v1.0

#ifndef BBW_IMP
#define BBW_IMP



class BBW : public AStreamBase
{
   StDevStream *stdev;
   double mult;
public:
   BBW(IStream* stream, int length, double mult)
   {
      stdev = new StDevStream(stream, length);
      this.mult = mult;
   }
   ~BBW()
   {
      stdev.Release();
   }
   
   virtual int Size()
   {
      return stdev.Size();
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      if (!stdev.GetValues(period, count, val))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = val[i] * mult * 2;
      }
      return true;
   }
};

#endif





// VwmaOnStream v2.1
class VwmaOnStream : public AOnStream
{
   IStream *_volumeSource;
   int _length;
public:
   VwmaOnStream(IStream *source, IStream *volumeSource, const int length)
      :AOnStream(source)
   {
      _volumeSource = volumeSource;
      _volumeSource.AddRef();
      _length = length;
   }

   VwmaOnStream(string symbol, ENUM_TIMEFRAMES timeframe, IStream *source, const int length)
      :AOnStream(source)
   {
      _volumeSource = new SimplePriceStream(symbol, timeframe, PriceVolume);
      _length = length;
   }

   ~VwmaOnStream()
   {
      _volumeSource.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double price[1];
      double volume[1];
      double sumw = 0;
      double sum = 0;
      for (int k = 0; k < _length; k++)
      {
         if (!_source.GetSeriesValues(period + k, 1, price) || !_volumeSource.GetSeriesValues(period + k, 1, volume))
            return false;
         sumw += volume[0];
         sum += volume[0] * price[0];
      }
      val = sum / sumw;
      return true;
   }
};
// Collection of labels v1.1

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
// Conversion to string v1.1

string ToString(double value, string format)
{
   return DoubleToString(value);
}
string ToString(double value)
{
   return DoubleToString(value);
}
#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL



//ConditionStreamV2 v1.0

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
   virtual bool GetValues(const int period, const int count, bool &val[])
   {
      if (Size() <= period || period - count + 1 < 0)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = _condition.IsPass(period - i, 0);
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, bool &val[])
   {
      int pos = Size() - period - 1;
      return GetValues(pos, count, val);
   }
};
#endif


// Condition base v2.1

#ifndef ACondition_IMP
#define ACondition_IMP

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
// Symbol info v1.3

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digit;
   double _ticksize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      _digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _ticksize = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), _digit);
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

   static double GetPipSize(const string symbol)
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      double mult = digit == 3 || digit == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPointSize() { return _point; }
   double GetPipSize() { return _pipSize; }
   int GetDigits() { return _digit; }
   string GetSymbol() { return _symbol; }
   static double GetBid(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_BID); }
   static double GetAsk(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
   double GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
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

// Base condition v1.1

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

class ACondition : public AConditionBase
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo* _instrument;
   string _symbol;
public:
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe, string name = NULL)
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


#ifndef TwoStreamsConditionType_IMP
#define TwoStreamsConditionType_IMP

enum TwoStreamsConditionType
{
   FirstAboveSecond,
   FirstBelowSecond,
   FirstCrossOverSecond,
   FirstCrossUnderSecond
};

#endif

// Stream-stream condition v2.0

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
      double value1[2];
      if (!_stream1.GetValues(period - _periodShift1, 2, value1))
      {
         return false;
      }
      double value2[2];
      if (!_stream2.GetValues(period - _periodShift2, 2, value2))
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return value1[0] > value2[0];
         case FirstBelowSecond:
            return value1[0] < value2[0];
         case FirstCrossOverSecond:
            return value1[0] >= value2[0] && value1[1] < value2[1];
         case FirstCrossUnderSecond:
            return value1[0] <= value2[0] && value1[1] > value2[1];
      }
      return value1[0] >= value2[0] && value1[1] < value2[1];
   }
};
#endif

// Or condition v1.0

// Returns true when at least one of the conditions returns true.

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
      {
         condition.AddRef();
      }
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

// v1.0
// Wraps IIntStream and provides IStream

#ifndef IntToFloatStreamWrapper_IMPL
#define IntToFloatStreamWrapper_IMPL



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
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int intVal[];
      ArrayResize(intVal, count);
      if (!_source.GetValues(period, count, intVal))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = intVal[i];
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
};
#endif

//CrossStreamV2 v1.0

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
// Colored fill v1.1


#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   color upColor;
   color dnColor;
   int streamIndex;
   double top;
   double bottom;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      top = EMPTY_VALUE;
      bottom = EMPTY_VALUE;
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void SetTopBottom(double top, double bottom)
   {
      this.top = top;
      this.bottom = bottom;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      clr = GetColorOnly(clr);
      dnColor = colorsCount == 0 ? clr : upColor;
      upColor = clr;
      colorsCount++;
   }
   void AddColor(double clr)
   {
      if (clr == EMPTY_VALUE)
      {
         return;
      }
      AddColor((uint)clr);
   }
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, upColor); 
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, dnColor);
      return id + 2;
   }
   
   void Set(int period, double value1, double value2, uint clr)
   {
      int transp = GetTranparency(clr);
      if (clr == EMPTY_VALUE || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE || transp == 100)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      value1 = LimitValue(value1);
      value2 = LimitValue(value2);
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
private:
   double LimitValue(double value)
   {
      if (top == EMPTY_VALUE || bottom == EMPTY_VALUE)
      {
         return value;
      }
      if (value > top)
      {
         return top;
      }
      if (value < bottom)
      {
         return bottom;
      }
      return value;
   }   
};
#endif
//Signaler v5.0
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

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import
#endif

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

#ifdef ADVANCED_ALERTS
      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
#endif
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
#endif
   }
};

input int param1 = 5; // TSI Long Length
input int param2 = 12; // TSI Short Length
input int param3 = 10; // TSI Signal Length
input int param4 = 30; // TSI Crossover treshold
input int param5 = 5; // TSI Long Length
input int param6 = 12; // TSI Short Length
input int param7 = 70; // Lookback Bars
input double param8 = 0.12; // Start Buy Probability
input double param9 = 0.12; // Start Sell Probability
input int param10 = 1; // TSI Pivot Lookback Right
input int param11 = 20; // TSI Pivot Lookback Left
input int param12 = 1; // Divergence Pivot Lookback Right
input int param13 = 5; // Divergence Pivot Lookback Left
input int param14 = 100; // Max of Lookback Range
input int param15 = 2; // Min of Lookback Range
input bool param16 = true; // Plot Bullish
input bool param17 = false; // Plot Hidden Bullish
input bool param18 = true; // Plot Bearish
input bool param19 = false; // Plot Hidden Bearish
input int param20 = 14; // Money Flow Index Length
input int param21 = 20; // Bollinger Bands Lengh
input PriceType param22 = PriceClose; // Bollinger Bands Source
input double param23 = 2.0; // Bollinger Bands StdDev
input PriceType param24 = PriceClose; // BB Price Source
input int param25 = 13; // BB Length
input int param26 = 252; // ?????Lookback
input bool param27 = true; // 
input string param28 = "SMA"; // BBWP MA Type
input int param29 = 5; // BB Length
input int param30 = 20; // Where to Draw the Label 1
input int param31 = 50; // Where to Draw the Label 2
input int param32 = 50; // Where to Draw the Label 3
input int bars_limit = 1000; // Bars limit
int _long;
int _short;
int signal;
int treshold;
FloatStream* change1Source;
IStream* change1;
class double_smooth_fS_i_iStream
{
   IStream* src2;
   int _long;
   int _short;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* ema2Source;
   EMAOnStream* ema2;
   bool _initialized;
public:
   double_smooth_fS_i_iStream(IStream* src2, int _long, int _short)
   {
      _initialized = false;
      this.src2 = src2;
      src2.AddRef();
      this._long = _long;
      this._short = _short;
      _long = param5;
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, _long);
      _short = param6;
      ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema2 = new EMAOnStream(ema2Source, _short);
   }
   ~double_smooth_fS_i_iStream()
   {
      src2.Release();
      ema1Source.Release();
      ema1.Release();
      ema2Source.Release();
      ema2.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double &__out1)
   {
      if (!_initialized)
      {
         ema1Source.Init();
         ema2Source.Init();
         _initialized = true;
      }
      double src2Value[1];
      if (!src2.GetValues(pos, 1, src2Value)) { src2Value[0] = EMPTY_VALUE; }
      ema1Source.SetValue(pos, src2Value[0]);
      double ema1Value[1];
      if (!ema1.GetValues(pos, 1, ema1Value)) { ema1Value[0] = EMPTY_VALUE; }
      double fist_smooth = ema1Value[0];
      ema2Source.SetValue(pos, fist_smooth);
      double ema2Value[1];
      if (!ema2.GetValues(pos, 1, ema2Value)) { ema2Value[0] = EMPTY_VALUE; }
      __out1 = ema2Value[0];
      return true;
   }
};
FloatStream* double_smooth_fS_i_i1_param1;
double_smooth_fS_i_iStream* double_smooth_fS_i_i1;
FloatStream* double_smooth_fS_i_i2_param1;
double_smooth_fS_i_iStream* double_smooth_fS_i_i2;
FloatStream* wma1Source;
WMAOnStream* wma1;
int input_lookbackbars;
double input_startbuyprobability;
double input_startsellprobability;
class dzsell_fS_f_iStream
{
   IStream* src;
   double initvalue;
   int lookbackbars;
   bool _initialized;
public:
   dzsell_fS_f_iStream(IStream* src, double initvalue, int lookbackbars)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.initvalue = initvalue;
      this.lookbackbars = lookbackbars;
   }
   ~dzsell_fS_f_iStream()
   {
      src.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double &__out1, double &__out2, int &__out3)
   {
      double left = (-10000.0);
      double right = 10000.0;
      double eps = 0.001;
      double yval = SafeDivide((left + right), 2.0);
      double delta = yval - left;
      int maxsteps = 0;
      int for1_from = 0;
      int for1_to = 99999;
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { return false; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         if (!((delta > 0.005) && (maxsteps < 50)))
         {
            break;
         }
         maxsteps = maxsteps + 1;
         int count = 0;
         int for2_from = 0;
         int for2_to = lookbackbars - 1;
         bool for2_forward = for2_from <= for2_to;
         int for2_step = 1 * (for2_forward ? 1 : -1);
         if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { return false; }
         for (int k = for2_from; (for2_forward ? k <= for2_to : k >= for2_to); k += for2_step)
         {
            double srcValue_k[1];
            if (!src.GetValues(pos - k, 1, srcValue_k)) { srcValue_k[0] = EMPTY_VALUE; }
            if (SafeGreater(srcValue_k[0], yval))
            {
               count = count + 1;
               count;
            }
         }
         int prob = SafeDivide(count, lookbackbars);
         if ((prob > initvalue + eps))
         {
            left = yval;
            yval = SafeDivide((yval + right), 2.0);
            yval;
         }
         if ((prob < initvalue - eps))
         {
            right = yval;
            yval = SafeDivide((yval + left), 2.0);
            yval;
         }
         if ((prob < initvalue + eps) && (prob > initvalue - eps))
         {
            left = yval;
            yval = SafeDivide((yval + right), 2.0);
            yval;
         }
         delta = yval - left;
         delta;
      }
      __out1 = yval;
      __out2 = delta;
      __out3 = maxsteps;
      return true;
   }
};
FloatStream* dzsell_fS_f_i3_param1;
dzsell_fS_f_iStream* dzsell_fS_f_i3;
class dzbuy_fS_f_iStream
{
   IStream* src;
   double initvalue;
   int lookbackbars;
   bool _initialized;
public:
   dzbuy_fS_f_iStream(IStream* src, double initvalue, int lookbackbars)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.initvalue = initvalue;
      this.lookbackbars = lookbackbars;
   }
   ~dzbuy_fS_f_iStream()
   {
      src.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double &__out1, double &__out2, int &__out3)
   {
      double left = (-10000.0);
      double right = 10000.0;
      double eps = 0.001;
      double yval = SafeDivide((left + right), 2.0);
      double delta = yval - left;
      int maxsteps = 0;
      int for3_from = 0;
      int for3_to = 99999;
      bool for3_forward = for3_from <= for3_to;
      int for3_step = 1 * (for3_forward ? 1 : -1);
      if (for3_from == EMPTY_VALUE || for3_to == EMPTY_VALUE) { return false; }
      for (int i = for3_from; (for3_forward ? i <= for3_to : i >= for3_to); i += for3_step)
      {
         if (!((delta > 0.005) && (maxsteps < 50)))
         {
            break;
         }
         maxsteps = maxsteps + 1;
         int count = 0;
         int for4_from = 0;
         int for4_to = lookbackbars - 1;
         bool for4_forward = for4_from <= for4_to;
         int for4_step = 1 * (for4_forward ? 1 : -1);
         if (for4_from == EMPTY_VALUE || for4_to == EMPTY_VALUE) { return false; }
         for (int k = for4_from; (for4_forward ? k <= for4_to : k >= for4_to); k += for4_step)
         {
            double srcValue_k[1];
            if (!src.GetValues(pos - k, 1, srcValue_k)) { srcValue_k[0] = EMPTY_VALUE; }
            if (SafeLess(srcValue_k[0], yval))
            {
               count = count + 1;
               count;
            }
         }
         int prob = SafeDivide(count, lookbackbars);
         if ((prob > initvalue + eps))
         {
            right = yval;
            yval = SafeDivide((yval + left), 2.0);
            yval;
         }
         if ((prob < initvalue - eps))
         {
            left = yval;
            yval = SafeDivide((yval + right), 2.0);
            yval;
         }
         if ((prob < initvalue + eps) && (prob > initvalue - eps))
         {
            right = yval;
            yval = SafeDivide((yval + left), 2.0);
            yval;
         }
         delta = yval - left;
         delta;
      }
      __out1 = yval;
      __out2 = delta;
      __out3 = maxsteps;
      return true;
   }
};
FloatStream* dzbuy_fS_f_i4_param1;
dzbuy_fS_f_iStream* dzbuy_fS_f_i4;
int pivR;
int pivL;
FloatStream* rma1Source;
RmaOnStream* rma1;
FloatStream* change2Source;
IStream* change2;
FloatStream* rma2Source;
RmaOnStream* rma2;
FloatStream* change3Source;
IStream* change3;
int lbR;
int lbL;
int rangeUpper;
int rangeLower;
bool plotBull;
bool plotHiddenBull;
bool plotBear;
bool plotHiddenBear;
FloatStream* lowestpivot1Source;
FloatStream* highestpivot1Source;
double osc[];
double osc_DEFAULT_VALUE;
ValueWhenSimpleStream* valuewhen1;
class _inRange_bSStream
{
   IBoolStream* cond;
   BoolStream* barssince1Condition;
   BarsSinceStreamV2* barssince1;
   bool _initialized;
public:
   _inRange_bSStream(IBoolStream* cond)
   {
      _initialized = false;
      this.cond = cond;
      cond.AddRef();
      barssince1Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      barssince1 = new BarsSinceStreamV2(barssince1Condition);
   }
   ~_inRange_bSStream()
   {
      cond.Release();
      barssince1Condition.Release();
      barssince1.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, bool &__out1)
   {
      if (!_initialized)
      {
         barssince1Condition.Init();
         _initialized = true;
      }
      bool condValue[1];
      if (!cond.GetValues(pos, 1, condValue)) { condValue[0] = EMPTY_VALUE; }
      barssince1Condition.SetValue(pos, (condValue[0] == true));
      int barssince1Value[1];
      if (!barssince1.GetValues(pos, 1, barssince1Value)) { barssince1Value[0] = EMPTY_VALUE; }
      int bars = barssince1Value[0];
      __out1 = SafeLE(rangeLower, bars) && SafeLE(bars, rangeUpper);
      return true;
   }
};
double plFound[];
double plFound_DEFAULT_VALUE;
BoolStream* _inRange_bS5_param1;
_inRange_bSStream* _inRange_bS5;
ValueWhenSimpleStream* valuewhen2;
ColoredPlot* plot1;
double plot2[];
ValueWhenSimpleStream* valuewhen3;
BoolStream* _inRange_bS6_param1;
_inRange_bSStream* _inRange_bS6;
ValueWhenSimpleStream* valuewhen4;
ColoredPlot* plot3;
double plot4[];
ValueWhenSimpleStream* valuewhen5;
double phFound[];
double phFound_DEFAULT_VALUE;
BoolStream* _inRange_bS7_param1;
_inRange_bSStream* _inRange_bS7;
ValueWhenSimpleStream* valuewhen6;
ColoredPlot* plot5;
double plot6[];
ValueWhenSimpleStream* valuewhen7;
BoolStream* _inRange_bS8_param1;
_inRange_bSStream* _inRange_bS8;
ValueWhenSimpleStream* valuewhen8;
ColoredPlot* plot7;
double plot8[];
FloatStream* highest1Source;
FloatStream* lowest1Source;
FloatStream* highest2Source;
FloatStream* lowest2Source;
FloatStream* highest3Source;
FloatStream* lowest3Source;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* stdev1Source;
StDevStream* stdev1;
int lengthMFI;
FloatStream* mfi1Series;
MfiOnStream* mfi1;
int lengthBB;
IStream* param22Stream;
IStream* srcBB;
double multBB;
FloatStream* sma2Source;
SmaOnStream* sma2;
FloatStream* stdev2Source;
StDevStream* stdev2;
IStream* param24Stream;
IStream* i_priceSrc;
int i_bbwpLen;
int i_bbwpLkbk;
bool i_ma1On;
string i_ma1Type;
int i_ma1Len;
FloatStream* percentrank1Source;
PercentRank* percentrank1;
FloatStream* bbw1Series;
BBW* bbw1;
FloatStream* vwma1Source;
VwmaOnStream* vwma1;
FloatStream* ema3Source;
EMAOnStream* ema3;
FloatStream* sma3Source;
SmaOnStream* sma3;
int labelwhere;
int labelwhere2;
int labelwhere3;
Label* lbl;
Label* lbl2;
Label* lbl3;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
IBoolStream* crossunder1;
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* crossunder2X;
FloatStream* crossunder2Y;
IBoolStream* crossunder2;
ValueWhenSimpleStream* valuewhen9;
FloatStream* crossover2X;
FloatStream* crossover2Y;
IBoolStream* crossover2;
ValueWhenSimpleStream* valuewhen10;
ValueWhenSimpleStream* valuewhen11;
ValueWhenSimpleStream* valuewhen12;
BoolStream* change4Source;
IStream* change4;
double crossvwph[];
double crossvwph_DEFAULT_VALUE;
double crosscounterph[];
double crosscounterph_DEFAULT_VALUE;
BoolStream* change5Source;
IStream* change5;
double crossvwpl[];
double crossvwpl_DEFAULT_VALUE;
double crosscounterpl[];
double crosscounterpl_DEFAULT_VALUE;
double plot9[];
double plot10[];
double plot11[];
double plot12[];
ColoredFill* fill13;
ColoredFill* fill14;
ColoredPlot* plot15;
double plot16[];
double plot17[];
double plot18[];
double plot19[];
double plot20[];
double plot21[];
FloatStream* highestpivot2Source;
FloatStream* lowestpivot2Source;
double plot22[];
double plot23[];
double plot24_clr1[];
double plot24_clr2[];
double Setplot24(int pos, bool condition, double value, color clr)
{
   if (!condition) { return EMPTY_VALUE; }
   if (clr == AddTransparency(Orange, 00)) { plot24_clr1[pos] = value; return plot24_clr1[pos]; }
   else if (clr == EMPTY_VALUE) { plot24_clr2[pos] = value; return plot24_clr2[pos]; }
   return EMPTY_VALUE;
}
double plot26_clr1[];
double plot26_clr2[];
double Setplot26(int pos, bool condition, double value, color clr)
{
   if (!condition) { return EMPTY_VALUE; }
   if (clr == AddTransparency(Aqua, 00)) { plot26_clr1[pos] = value; return plot26_clr1[pos]; }
   else if (clr == EMPTY_VALUE) { plot26_clr2[pos] = value; return plot26_clr2[pos]; }
   return EMPTY_VALUE;
}
Signaler* _signaler;

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
   _long = param1;
   _short = param2;
   signal = param3;
   treshold = param4;
   change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = ChangeStreamFactory::Create(change1Source, 1);
   wma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma1 = new WMAOnStream(wma1Source, signal);
   input_lookbackbars = param7;
   input_startbuyprobability = param8;
   input_startsellprobability = param9;
   pivR = param10;
   pivL = param11;
   change2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change2 = ChangeStreamFactory::Create(change2Source, 1);
   rma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma1 = new RmaOnStream(rma1Source, _short);
   change3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change3 = ChangeStreamFactory::Create(change3Source, 1);
   rma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma2 = new RmaOnStream(rma2Source, _short);
   lbR = param12;
   lbL = param13;
   rangeUpper = param14;
   rangeLower = param15;
   plotBull = param16;
   plotHiddenBull = param17;
   plotBear = param18;
   plotHiddenBear = param19;
   lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   plot1 = new ColoredPlot(0);
   plot1.AddColor(AddTransparency(Green, 0));
   plot1.AddColor(AddTransparency(White, 100));
   plot1.SetOffset((-lbR));
   id = plot1.RegisterStreams(id);
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_SHIFT, (-lbR));
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(Green, 0));
   PlotIndexSetInteger(id, PLOT_ARROW, 241);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   plot3 = new ColoredPlot(2);
   plot3.AddColor(AddTransparency(Aqua, 0));
   plot3.AddColor(AddTransparency(White, 100));
   plot3.SetOffset((-lbR));
   id = plot3.RegisterStreams(id);
   SetIndexBuffer(id, plot4, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_SHIFT, (-lbR));
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(Aqua, 0));
   PlotIndexSetInteger(id, PLOT_ARROW, 241);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   plot5 = new ColoredPlot(4);
   plot5.AddColor(AddTransparency(Red, 0));
   plot5.AddColor(AddTransparency(White, 100));
   plot5.SetOffset((-lbR));
   id = plot5.RegisterStreams(id);
   SetIndexBuffer(id, plot6, INDICATOR_DATA);
   PlotIndexSetInteger(6, PLOT_SHIFT, (-lbR));
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(Red, 0));
   PlotIndexSetInteger(id, PLOT_ARROW, 242);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   plot7 = new ColoredPlot(6);
   plot7.AddColor(AddTransparency(Orange, 0));
   plot7.AddColor(AddTransparency(White, 100));
   plot7.SetOffset((-lbR));
   id = plot7.RegisterStreams(id);
   SetIndexBuffer(id, plot8, INDICATOR_DATA);
   PlotIndexSetInteger(8, PLOT_SHIFT, (-lbR));
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(Orange, 0));
   PlotIndexSetInteger(id, PLOT_ARROW, 242);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highest2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highest3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, 200);
   stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev1 = new StDevStream(stdev1Source, 200);
   lengthMFI = param20;
   mfi1Series = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mfi1 = new MfiOnStream(mfi1Series, lengthMFI);
   lengthBB = param21;
   param22Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param22);
   srcBB = param22Stream;
   multBB = param23;
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, lengthBB);
   stdev2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev2 = new StDevStream(stdev2Source, lengthBB);
   param24Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param24);
   i_priceSrc = param24Stream;
   i_bbwpLen = param25;
   i_bbwpLkbk = param26;
   i_ma1On = param27;
   i_ma1Type = param28;
   i_ma1Len = param29;
   bbw1Series = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bbw1 = new BBW(bbw1Series, i_bbwpLen, 1);
   percentrank1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   percentrank1 = new PercentRank(percentrank1Source, i_bbwpLkbk);
   vwma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   vwma1 = new VwmaOnStream(_Symbol, (ENUM_TIMEFRAMES)_Period, vwma1Source, i_ma1Len);
   ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, i_ma1Len);
   sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, i_ma1Len);
   labelwhere = param30;
   labelwhere2 = param31;
   labelwhere3 = param32;
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   crossunder2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2 = CrossStreamFactory::CreateCrossunder(crossunder2X, crossunder2Y);
   crossover2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = CrossStreamFactory::CreateCrossover(crossover2X, crossover2Y);
   change4Source = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change4 = ChangeStreamFactory::Create(change4Source, 1);
   change5Source = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change5 = ChangeStreamFactory::Create(change5Source, 1);
   SetIndexBuffer(id, plot9, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, AddTransparency(White, 100));
   SetIndexBuffer(id, plot10, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, AddTransparency(White, 100));
   SetIndexBuffer(id, plot11, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, AddTransparency(White, 100));
   SetIndexBuffer(id, plot12, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, AddTransparency(White, 100));
   fill13 = new ColoredFill(12);
   fill13.AddColor(AddTransparency(Aqua, 90));
   id = fill13.RegisterStreams(id);
   fill14 = new ColoredFill(13);
   fill14.AddColor(AddTransparency(Orange, 90));
   id = fill14.RegisterStreams(id);
   plot15 = new ColoredPlot(14);
   plot15.AddColor(AddTransparency(0x00008d, 70));
   plot15.AddColor(AddTransparency(Red, 70));
   plot15.AddColor(AddTransparency(Orange, 70));
   plot15.AddColor(AddTransparency(Yellow, 70));
   plot15.AddColor(AddTransparency(Aqua, 70));
   plot15.AddColor(AddTransparency(Silver, 70));
   plot15.AddColor(AddTransparency(White, 70));
   plot15.SetOffset(0);
   id = plot15.RegisterStreams(id);
   SetIndexBuffer(id, plot16, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, AddTransparency(Aqua, 0));
   SetIndexBuffer(id, plot17, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, AddTransparency(Orange, 0));
   SetIndexBuffer(id, plot18, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, AddTransparency(White, 100));
   SetIndexBuffer(id, plot19, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(White, 80));
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(id++, PLOT_LINE_STYLE, STYLE_DASH);
   SetIndexBuffer(id, plot20, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(Orange, 80));
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(id++, PLOT_LINE_STYLE, STYLE_DASH);
   SetIndexBuffer(id, plot21, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(Aqua, 80));
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(id++, PLOT_LINE_STYLE, STYLE_DASH);
   highestpivot2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowestpivot2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(id, plot22, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(White, 00));
   PlotIndexSetInteger(id, PLOT_ARROW, 218);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot23, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(White, 00));
   PlotIndexSetInteger(id, PLOT_ARROW, 217);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot24_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(Orange, 00));
   PlotIndexSetInteger(id, PLOT_ARROW, 242);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot24_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, EMPTY_VALUE);
   PlotIndexSetInteger(id, PLOT_ARROW, 242);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot26_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, AddTransparency(Aqua, 00));
   PlotIndexSetInteger(id, PLOT_ARROW, 241);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot26_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, EMPTY_VALUE);
   PlotIndexSetInteger(id, PLOT_ARROW, 241);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   LabelsCollection::SetMaxLabels(50);
   IndicatorObjPrefix = GenerateIndicatorPrefix("TSI");
   IndicatorSetString(INDICATOR_SHORTNAME, "TSI in Dynamic Zones with Divergence");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   double_smooth_fS_i_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   double_smooth_fS_i_i1 = new double_smooth_fS_i_iStream(double_smooth_fS_i_i1_param1, _long, _short);
   id = double_smooth_fS_i_i1.Init(id);
   double_smooth_fS_i_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   double_smooth_fS_i_i2 = new double_smooth_fS_i_iStream(double_smooth_fS_i_i2_param1, _long, _short);
   id = double_smooth_fS_i_i2.Init(id);
   dzsell_fS_f_i3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   dzsell_fS_f_i3 = new dzsell_fS_f_iStream(dzsell_fS_f_i3_param1, input_startsellprobability, input_lookbackbars);
   id = dzsell_fS_f_i3.Init(id);
   dzbuy_fS_f_i4_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   dzbuy_fS_f_i4 = new dzbuy_fS_f_iStream(dzbuy_fS_f_i4_param1, input_startbuyprobability, input_lookbackbars);
   id = dzbuy_fS_f_i4.Init(id);
   SetIndexBuffer(id++, osc, INDICATOR_CALCULATIONS);
   valuewhen1 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen1.RegisterInternalStream(id);
   SetIndexBuffer(id++, plFound, INDICATOR_CALCULATIONS);
   _inRange_bS5_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS5 = new _inRange_bSStream(_inRange_bS5_param1);
   id = _inRange_bS5.Init(id);
   valuewhen2 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen2.RegisterInternalStream(id);
   id = plot1.RegisterInternalStreams(id);
   valuewhen3 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen3.RegisterInternalStream(id);
   _inRange_bS6_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS6 = new _inRange_bSStream(_inRange_bS6_param1);
   id = _inRange_bS6.Init(id);
   valuewhen4 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen4.RegisterInternalStream(id);
   id = plot3.RegisterInternalStreams(id);
   valuewhen5 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen5.RegisterInternalStream(id);
   SetIndexBuffer(id++, phFound, INDICATOR_CALCULATIONS);
   _inRange_bS7_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS7 = new _inRange_bSStream(_inRange_bS7_param1);
   id = _inRange_bS7.Init(id);
   valuewhen6 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen6.RegisterInternalStream(id);
   id = plot5.RegisterInternalStreams(id);
   valuewhen7 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen7.RegisterInternalStream(id);
   _inRange_bS8_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS8 = new _inRange_bSStream(_inRange_bS8_param1);
   id = _inRange_bS8.Init(id);
   valuewhen8 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen8.RegisterInternalStream(id);
   id = plot7.RegisterInternalStreams(id);
   valuewhen9 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen9.RegisterInternalStream(id);
   valuewhen10 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen10.RegisterInternalStream(id);
   valuewhen11 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen11.RegisterInternalStream(id);
   valuewhen12 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen12.RegisterInternalStream(id);
   SetIndexBuffer(id++, crossvwph, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, crosscounterph, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, crossvwpl, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, crosscounterpl, INDICATOR_CALCULATIONS);
   id = plot15.RegisterInternalStreams(id);
   _signaler = new Signaler();
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   change1Source.Release();
   change1.Release();
   double_smooth_fS_i_i1_param1.Release();
   delete double_smooth_fS_i_i1;
   double_smooth_fS_i_i2_param1.Release();
   delete double_smooth_fS_i_i2;
   wma1Source.Release();
   wma1.Release();
   dzsell_fS_f_i3_param1.Release();
   delete dzsell_fS_f_i3;
   dzbuy_fS_f_i4_param1.Release();
   delete dzbuy_fS_f_i4;
   rma1Source.Release();
   rma1.Release();
   change2Source.Release();
   change2.Release();
   rma2Source.Release();
   rma2.Release();
   change3Source.Release();
   change3.Release();
   lowestpivot1Source.Release();
   highestpivot1Source.Release();
   valuewhen1.Release();
   _inRange_bS5_param1.Release();
   delete _inRange_bS5;
   valuewhen2.Release();
   delete plot1;
   valuewhen3.Release();
   _inRange_bS6_param1.Release();
   delete _inRange_bS6;
   valuewhen4.Release();
   delete plot3;
   valuewhen5.Release();
   _inRange_bS7_param1.Release();
   delete _inRange_bS7;
   valuewhen6.Release();
   delete plot5;
   valuewhen7.Release();
   _inRange_bS8_param1.Release();
   delete _inRange_bS8;
   valuewhen8.Release();
   delete plot7;
   highest1Source.Release();
   lowest1Source.Release();
   highest2Source.Release();
   lowest2Source.Release();
   highest3Source.Release();
   lowest3Source.Release();
   sma1Source.Release();
   sma1.Release();
   stdev1Source.Release();
   stdev1.Release();
   mfi1Series.Release();
   mfi1.Release();
   param22Stream.Release();
   sma2Source.Release();
   sma2.Release();
   stdev2Source.Release();
   stdev2.Release();
   param24Stream.Release();
   percentrank1Source.Release();
   percentrank1.Release();
   bbw1Series.Release();
   bbw1.Release();
   vwma1Source.Release();
   vwma1.Release();
   ema3Source.Release();
   ema3.Release();
   sma3Source.Release();
   sma3.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossunder2X.Release();
   crossunder2Y.Release();
   crossunder2.Release();
   valuewhen9.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   valuewhen10.Release();
   valuewhen11.Release();
   valuewhen12.Release();
   change4Source.Release();
   change4.Release();
   change5Source.Release();
   change5.Release();
   delete fill13;
   delete fill14;
   delete plot15;
   highestpivot2Source.Release();
   lowestpivot2Source.Release();
   LabelsCollection::Clear(true);
   delete _signaler;
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
      change1Source.Init();
      double_smooth_fS_i_i1_param1.Init();
      double_smooth_fS_i_i1.Clear();
      double_smooth_fS_i_i2_param1.Init();
      double_smooth_fS_i_i2.Clear();
      wma1Source.Init();
      dzsell_fS_f_i3_param1.Init();
      dzsell_fS_f_i3.Clear();
      dzbuy_fS_f_i4_param1.Init();
      dzbuy_fS_f_i4.Clear();
      change2Source.Init();
      rma1Source.Init();
      change3Source.Init();
      rma2Source.Init();
      lowestpivot1Source.Init();
      highestpivot1Source.Init();
      osc_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(osc, osc_DEFAULT_VALUE);
      plFound_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(plFound, plFound_DEFAULT_VALUE);
      _inRange_bS5_param1.Init();
      _inRange_bS5.Clear();
      plot1.Init();
      ArrayInitialize(plot2, EMPTY_VALUE);
      _inRange_bS6_param1.Init();
      _inRange_bS6.Clear();
      plot3.Init();
      ArrayInitialize(plot4, EMPTY_VALUE);
      phFound_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(phFound, phFound_DEFAULT_VALUE);
      _inRange_bS7_param1.Init();
      _inRange_bS7.Clear();
      plot5.Init();
      ArrayInitialize(plot6, EMPTY_VALUE);
      _inRange_bS8_param1.Init();
      _inRange_bS8.Clear();
      plot7.Init();
      ArrayInitialize(plot8, EMPTY_VALUE);
      highest1Source.Init();
      lowest1Source.Init();
      highest2Source.Init();
      lowest2Source.Init();
      highest3Source.Init();
      lowest3Source.Init();
      sma1Source.Init();
      stdev1Source.Init();
      mfi1Series.Init();
      sma2Source.Init();
      stdev2Source.Init();
      bbw1Series.Init();
      percentrank1Source.Init();
      vwma1Source.Init();
      ema3Source.Init();
      sma3Source.Init();
      lbl = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", EMPTY_VALUE, EMPTY_VALUE, time[0]).SetText("").SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      lbl2 = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", EMPTY_VALUE, EMPTY_VALUE, time[0]).SetText("").SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      lbl3 = LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", EMPTY_VALUE, EMPTY_VALUE, time[0]).SetText("").SetStyle("down").SetSize("normal").SetYLoc("price").SetTextAlign("center");
      crossunder1X.Init();
      crossunder1Y.Init();
      crossover1X.Init();
      crossover1Y.Init();
      crossunder2X.Init();
      crossunder2Y.Init();
      crossover2X.Init();
      crossover2Y.Init();
      crossvwph_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(crossvwph, crossvwph_DEFAULT_VALUE);
      change4Source.Init();
      crosscounterph_DEFAULT_VALUE = 0;
      ArrayInitialize(crosscounterph, crosscounterph_DEFAULT_VALUE);
      crossvwpl_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(crossvwpl, crossvwpl_DEFAULT_VALUE);
      change5Source.Init();
      crosscounterpl_DEFAULT_VALUE = 0;
      ArrayInitialize(crosscounterpl, crosscounterpl_DEFAULT_VALUE);
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(plot11, EMPTY_VALUE);
      ArrayInitialize(plot12, EMPTY_VALUE);
      fill13.Init();
      fill14.Init();
      plot15.Init();
      ArrayInitialize(plot16, EMPTY_VALUE);
      ArrayInitialize(plot17, EMPTY_VALUE);
      ArrayInitialize(plot18, EMPTY_VALUE);
      ArrayInitialize(plot19, 0);
      ArrayInitialize(plot20, 75);
      ArrayInitialize(plot21, (-75));
      highestpivot2Source.Init();
      lowestpivot2Source.Init();
      ArrayInitialize(plot22, EMPTY_VALUE);
      ArrayInitialize(plot23, EMPTY_VALUE);
      ArrayInitialize(plot24_clr1, EMPTY_VALUE);
      ArrayInitialize(plot24_clr2, EMPTY_VALUE);
      ArrayInitialize(plot26_clr1, EMPTY_VALUE);
      ArrayInitialize(plot26_clr2, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double price = SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4);
      double src2 = SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4);
      double src = SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4);
      change1Source.SetValue(pos, price);
      double change1Value[1];
      if (!change1.GetValues(pos, 1, change1Value)) { change1Value[0] = EMPTY_VALUE; }
      double pc = change1Value[0];
      double_smooth_fS_i_i1_param1.SetValue(pos, pc);
      double double_smooth_fS_i_i1Value;
      if (!double_smooth_fS_i_i1.GetValue(pos, oldPos, double_smooth_fS_i_i1Value)) { double_smooth_fS_i_i1Value = EMPTY_VALUE; }
      double double_smoothed_pc = double_smooth_fS_i_i1Value;
      double_smooth_fS_i_i2_param1.SetValue(pos, SafeMathAbs(pc));
      double double_smooth_fS_i_i2Value;
      if (!double_smooth_fS_i_i2.GetValue(pos, oldPos, double_smooth_fS_i_i2Value)) { double_smooth_fS_i_i2Value = EMPTY_VALUE; }
      double double_smoothed_abs_pc = double_smooth_fS_i_i2Value;
      double tsi_value = SafeMultiply(100, (SafeDivide(double_smoothed_pc, double_smoothed_abs_pc)));
      double tsi1 = tsi_value;
      wma1Source.SetValue(pos, tsi_value);
      double wma1Value[1];
      if (!wma1.GetValues(pos, 1, wma1Value)) { wma1Value[0] = EMPTY_VALUE; }
      double tsi2 = wma1Value[0];
      double input_src = tsi1;
      dzsell_fS_f_i3_param1.SetValue(pos, input_src);
      double dzsell_fS_f_i3Value1;
      double dzsell_fS_f_i3Value2;
      int dzsell_fS_f_i3Value3;
      if (!dzsell_fS_f_i3.GetValue(pos, oldPos, dzsell_fS_f_i3Value1, dzsell_fS_f_i3Value2, dzsell_fS_f_i3Value3)) { dzsell_fS_f_i3Value1 = EMPTY_VALUE; dzsell_fS_f_i3Value2 = EMPTY_VALUE; dzsell_fS_f_i3Value3 = EMPTY_VALUE; }
      double sell_zone = dzsell_fS_f_i3Value1;
      double sell_delta = dzsell_fS_f_i3Value2;
      int sell_maxsteps = dzsell_fS_f_i3Value3;
      dzbuy_fS_f_i4_param1.SetValue(pos, input_src);
      double dzbuy_fS_f_i4Value1;
      double dzbuy_fS_f_i4Value2;
      int dzbuy_fS_f_i4Value3;
      if (!dzbuy_fS_f_i4.GetValue(pos, oldPos, dzbuy_fS_f_i4Value1, dzbuy_fS_f_i4Value2, dzbuy_fS_f_i4Value3)) { dzbuy_fS_f_i4Value1 = EMPTY_VALUE; dzbuy_fS_f_i4Value2 = EMPTY_VALUE; dzbuy_fS_f_i4Value3 = EMPTY_VALUE; }
      double buy_zone = dzbuy_fS_f_i4Value1;
      double buy_delta = dzbuy_fS_f_i4Value2;
      int buy_maxsteps = dzbuy_fS_f_i4Value3;
      double obvOsc = tsi1;
      uint obvColor = (SafeGreater(obvOsc, 0) ? AddTransparency(Aqua, 60) : AddTransparency(Orange, 60));
      change2Source.SetValue(pos, src);
      double change2Value[1];
      if (!change2.GetValues(pos, 1, change2Value)) { change2Value[0] = EMPTY_VALUE; }
      rma1Source.SetValue(pos, SafeMathMax(change2Value[0], 0));
      double rma1Value[1];
      if (!rma1.GetValues(pos, 1, rma1Value)) { rma1Value[0] = EMPTY_VALUE; }
      double up = rma1Value[0];
      change3Source.SetValue(pos, src);
      double change3Value[1];
      if (!change3.GetValues(pos, 1, change3Value)) { change3Value[0] = EMPTY_VALUE; }
      rma2Source.SetValue(pos, InvertSign(SafeMathMin(change3Value[0], 0)));
      double rma2Value[1];
      if (!rma2.GetValues(pos, 1, rma2Value)) { rma2Value[0] = EMPTY_VALUE; }
      double down = rma2Value[0];
      uint bearColor = AddTransparency(Red, 0);
      uint bullColor = AddTransparency(Green, 0);
      uint hiddenBullColor = AddTransparency(Aqua, 0);
      uint hiddenBearColor = AddTransparency(Orange, 0);
      uint textColor = AddTransparency(White, 0);
      uint noneColor = AddTransparency(White, 100);
      SetStream(osc, pos, tsi1, osc_DEFAULT_VALUE);
      lowestpivot1Source.SetValue(pos, osc[pos]);
      double lowestpivot1Value[1];
      if (!PivotLowStream::GetValues(pos, 1, lowestpivot1Value, lowestpivot1Source, lbL, lbR)) { lowestpivot1Value[0] = EMPTY_VALUE; }
      SetStream(plFound, pos, (((lowestpivot1Value[0]) == EMPTY_VALUE) ? false : true), plFound_DEFAULT_VALUE);
      highestpivot1Source.SetValue(pos, osc[pos]);
      double highestpivot1Value[1];
      if (!PivotHighStream::GetValues(pos, 1, highestpivot1Value, highestpivot1Source, lbL, lbR)) { highestpivot1Value[0] = EMPTY_VALUE; }
      SetStream(phFound, pos, (((highestpivot1Value[0]) == EMPTY_VALUE) ? false : true), phFound_DEFAULT_VALUE);
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      _inRange_bS5_param1.SetValue(pos, plFound[pos - 1]);
      bool _inRange_bS5Value;
      if (!_inRange_bS5.GetValue(pos, oldPos, _inRange_bS5Value)) { _inRange_bS5Value = EMPTY_VALUE; }
      bool oscHL = SafeGreater(osc[pos - lbR], valuewhen1.Update(pos, time[pos], plFound[pos], osc[pos - lbR])) && _inRange_bS5Value;
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      bool priceLL = SafeLess(low[pos - lbR], valuewhen2.Update(pos, time[pos], plFound[pos], low[pos - lbR]));
      bool bullCond = plotBull && priceLL && oscHL && plFound[pos];
      if (pos - lbR < 0) { continue; }
      plot1.Set(pos, (plFound[pos] ? osc[pos - lbR] : EMPTY_VALUE), (bullCond ? bullColor : noneColor));
      if (pos - lbR < 0) { continue; }
      plot2[pos] = (bullCond ? osc[pos - lbR] : EMPTY_VALUE);
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      _inRange_bS6_param1.SetValue(pos, plFound[pos - 1]);
      bool _inRange_bS6Value;
      if (!_inRange_bS6.GetValue(pos, oldPos, _inRange_bS6Value)) { _inRange_bS6Value = EMPTY_VALUE; }
      bool oscLL = SafeLess(osc[pos - lbR], valuewhen3.Update(pos, time[pos], plFound[pos], osc[pos - lbR])) && _inRange_bS6Value;
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      bool priceHL = SafeGreater(low[pos - lbR], valuewhen4.Update(pos, time[pos], plFound[pos], low[pos - lbR]));
      bool hiddenBullCond = plotHiddenBull && priceHL && oscLL && plFound[pos];
      if (pos - lbR < 0) { continue; }
      plot3.Set(pos, (plFound[pos] ? osc[pos - lbR] : EMPTY_VALUE), (hiddenBullCond ? hiddenBullColor : noneColor));
      if (pos - lbR < 0) { continue; }
      plot4[pos] = (hiddenBullCond ? osc[pos - lbR] : EMPTY_VALUE);
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      _inRange_bS7_param1.SetValue(pos, phFound[pos - 1]);
      bool _inRange_bS7Value;
      if (!_inRange_bS7.GetValue(pos, oldPos, _inRange_bS7Value)) { _inRange_bS7Value = EMPTY_VALUE; }
      bool oscLH = SafeLess(osc[pos - lbR], valuewhen5.Update(pos, time[pos], phFound[pos], osc[pos - lbR])) && _inRange_bS7Value;
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      bool priceHH = SafeGreater(high[pos - lbR], valuewhen6.Update(pos, time[pos], phFound[pos], high[pos - lbR]));
      bool bearCond = plotBear && priceHH && oscLH && phFound[pos];
      if (pos - lbR < 0) { continue; }
      plot5.Set(pos, (phFound[pos] ? osc[pos - lbR] : EMPTY_VALUE), (bearCond ? bearColor : noneColor));
      if (pos - lbR < 0) { continue; }
      plot6[pos] = (bearCond ? osc[pos - lbR] : EMPTY_VALUE);
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      _inRange_bS8_param1.SetValue(pos, phFound[pos - 1]);
      bool _inRange_bS8Value;
      if (!_inRange_bS8.GetValue(pos, oldPos, _inRange_bS8Value)) { _inRange_bS8Value = EMPTY_VALUE; }
      bool oscHH = SafeGreater(osc[pos - lbR], valuewhen7.Update(pos, time[pos], phFound[pos], osc[pos - lbR])) && _inRange_bS8Value;
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      bool priceLH = SafeLess(high[pos - lbR], valuewhen8.Update(pos, time[pos], phFound[pos], high[pos - lbR]));
      bool hiddenBearCond = plotHiddenBear && priceLH && oscHH && phFound[pos];
      if (pos - lbR < 0) { continue; }
      plot7.Set(pos, (phFound[pos] ? osc[pos - lbR] : EMPTY_VALUE), (hiddenBearCond ? hiddenBearColor : noneColor));
      if (pos - lbR < 0) { continue; }
      plot8[pos] = (hiddenBearCond ? osc[pos - lbR] : EMPTY_VALUE);
      highest1Source.SetValue(pos, high[pos]);
      double highest1Value[1];
      if (!HighestHighStream::GetValues(pos, 1, highest1Value, highest1Source, 9)) { highest1Value[0] = EMPTY_VALUE; }
      lowest1Source.SetValue(pos, low[pos]);
      double lowest1Value[1];
      if (!LowestLowStream::GetValues(pos, 1, lowest1Value, lowest1Source, 9)) { lowest1Value[0] = EMPTY_VALUE; }
      double Tenkansen = SafeDivide((SafePlus(highest1Value[0], lowest1Value[0])), 2);
      highest2Source.SetValue(pos, high[pos]);
      double highest2Value[1];
      if (!HighestHighStream::GetValues(pos, 1, highest2Value, highest2Source, 26)) { highest2Value[0] = EMPTY_VALUE; }
      lowest2Source.SetValue(pos, low[pos]);
      double lowest2Value[1];
      if (!LowestLowStream::GetValues(pos, 1, lowest2Value, lowest2Source, 26)) { lowest2Value[0] = EMPTY_VALUE; }
      double Kijunsen = SafeDivide((SafePlus(highest2Value[0], lowest2Value[0])), 2);
      double FutureSpanA = SafeDivide((SafePlus(Tenkansen, Kijunsen)), 2);
      highest3Source.SetValue(pos, high[pos]);
      double highest3Value[1];
      if (!HighestHighStream::GetValues(pos, 1, highest3Value, highest3Source, 52)) { highest3Value[0] = EMPTY_VALUE; }
      lowest3Source.SetValue(pos, low[pos]);
      double lowest3Value[1];
      if (!LowestLowStream::GetValues(pos, 1, lowest3Value, lowest3Source, 52)) { lowest3Value[0] = EMPTY_VALUE; }
      double FutureSpanB = SafeDivide((SafePlus(highest3Value[0], lowest3Value[0])), 2);
      double Kumodepth = SafeMathAbs(SafeMinus(FutureSpanA, FutureSpanB));
      double Indicator = Kumodepth;
      sma1Source.SetValue(pos, Indicator);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
      double AverageIndicator = sma1Value[0];
      stdev1Source.SetValue(pos, Indicator);
      double stdev1Value[1];
      if (!stdev1.GetValues(pos, 1, stdev1Value)) { stdev1Value[0] = EMPTY_VALUE; }
      double StandardDeviation = stdev1Value[0];
      double UpperBand = SafePlus(AverageIndicator, SafeMultiply(2, StandardDeviation));
      double LowerBand = SafeMinus(AverageIndicator, SafeMultiply(2, StandardDeviation));
      double NormalizedIndicator = SafeMultiply(SafeDivide((SafeMinus(Indicator, LowerBand)), (SafeMinus(UpperBand, LowerBand))), 100);
      double srcMFI = SafeDivide((high[pos] + low[pos] + close[pos]), 3);
      mfi1Series.SetValue(pos, srcMFI);
      double mfi1Value[1];
      if (!mfi1.GetValues(pos, 1, mfi1Value)) { mfi1Value[0] = EMPTY_VALUE; }
      double mfMFI = mfi1Value[0];
      double srcBBValue[1];
      if (!srcBB.GetValues(pos, 1, srcBBValue)) { srcBBValue[0] = EMPTY_VALUE; }
      sma2Source.SetValue(pos, srcBBValue[0]);
      double sma2Value[1];
      if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
      double basisBB = sma2Value[0];
      stdev2Source.SetValue(pos, srcBBValue[0]);
      double stdev2Value[1];
      if (!stdev2.GetValues(pos, 1, stdev2Value)) { stdev2Value[0] = EMPTY_VALUE; }
      double devBB = SafeMultiply(multBB, stdev2Value[0]);
      double upperBB = SafePlus(basisBB, devBB);
      double lowerBB = SafeMinus(basisBB, devBB);
      double bbrBB = SafeDivide((SafeMinus(srcBBValue[0], lowerBB)), (SafeMinus(upperBB, lowerBB)));
      double Perc1 = bbrBB;
      double i_priceSrcValue[1];
      if (!i_priceSrc.GetValues(pos, 1, i_priceSrcValue)) { i_priceSrcValue[0] = EMPTY_VALUE; }
      bbw1Series.SetValue(pos, i_priceSrcValue[0]);
      double bbw1Value[1];
      if (!bbw1.GetValues(pos, 1, bbw1Value)) { bbw1Value[0] = EMPTY_VALUE; }
      percentrank1Source.SetValue(pos, bbw1Value[0]);
      double percentrank1Value[1];
      if (!percentrank1.GetValues(pos, 1, percentrank1Value)) { percentrank1Value[0] = EMPTY_VALUE; }
      double bbwp = percentrank1Value[0];
      uint c_bbwp = (SafeGE(bbwp, 50) ? FromGradient(bbwp, 50, 100, 0x00FF0A, 0x0029FF) : FromGradient(bbwp, 0, 49, 0xFF0000, 0x00FF0A));
      vwma1Source.SetValue(pos, bbwp);
      double vwma1Value[1];
      if (!vwma1.GetValues(pos, 1, vwma1Value)) { vwma1Value[0] = EMPTY_VALUE; }
      ema3Source.SetValue(pos, bbwp);
      double ema3Value[1];
      if (!ema3.GetValues(pos, 1, ema3Value)) { ema3Value[0] = EMPTY_VALUE; }
      sma3Source.SetValue(pos, bbwp);
      double sma3Value[1];
      if (!sma3.GetValues(pos, 1, sma3Value)) { sma3Value[0] = EMPTY_VALUE; }
      double bbwpMA1 = (i_ma1On ? ((i_ma1Type == "VWMA") ? vwma1Value[0] : ((i_ma1Type == "EMA") ? ema3Value[0] : sma3Value[0])) : EMPTY_VALUE);
      uint perccolor = (SafeLess(bbrBB, 0.5) && SafeGreater(bbrBB, 0) ? AddTransparency(Aqua, 50) : (SafeLess(bbrBB, 0) ? AddTransparency(Green, 50) : (SafeGreater(bbrBB, 1) ? AddTransparency(Red, 50) : AddTransparency(Orange, 50))));
      string pertext = (SafeGreater(bbrBB, 1) ? "Bollinger Bands Overbought" : (SafeLess(bbrBB, 0) ? "Bollinger Bands Oversold" : "BB"));
      uint perccolorMFI = (SafeGreater(mfMFI, 80) ? AddTransparency(Red, 50) : (SafeLess(mfMFI, 20) ? AddTransparency(Green, 50) : (SafeGreater(mfMFI, 50) ? AddTransparency(Aqua, 50) : AddTransparency(Orange, 50))));
      string pertextMFI = (SafeGreater(mfMFI, 80) ? "MoneyFlow Overbought" : (SafeLess(mfMFI, 20) ? "MoneyFlow Oversold" : "Money Flow"));
      uint perccolorBBW = (SafeLess(bbwp, 7) ? AddTransparency(Red, 50) : AddTransparency(Aqua, 50));
      string pertextBBW = (SafeLess(bbwp, 7) ? "BB Width Squeeze" : "BB Width");
      if ((pos == rates_total - 1))
      {
         Label::SetXY(lbl, pos + labelwhere, input_src);
         Label::SetTextAlign(lbl, "right");
         Label::SetText(lbl, SafePlus(SafePlus(ToString(Perc1, "mintick"), " "), (pertext)));
         Label::SetTextColor(lbl, perccolor);
         Label::SetStyle(lbl, "none");
      }
      if ((pos == rates_total - 1))
      {
         Label::SetXY(lbl2, pos + labelwhere2, 55);
         Label::SetTextAlign(lbl2, "right");
         Label::SetText(lbl2, SafePlus(SafePlus(SafePlus(SafePlus(ToString(bbwp, "mintick"), " "), "%"), " "), (pertextBBW)));
         Label::SetTextColor(lbl2, perccolorBBW);
         Label::SetStyle(lbl2, "none");
      }
      if ((pos == rates_total - 1))
      {
         Label::SetXY(lbl3, pos + labelwhere3, (-85));
         Label::SetTextAlign(lbl3, "right");
         Label::SetText(lbl3, SafePlus(SafePlus(ToString(mfMFI, "mintick"), " "), (pertextMFI)));
         Label::SetTextColor(lbl3, perccolorMFI);
         Label::SetStyle(lbl3, "none");
      }
      crossunder1X.SetValue(pos, obvOsc);
      crossunder1Y.SetValue(pos, 0);
      bool crossunder1Value[1];
      if (!crossunder1.GetValues(pos, 1, crossunder1Value)) { crossunder1Value[0] = EMPTY_VALUE; }
      bool crossoverCond1 = crossunder1Value[0];
      crossover1X.SetValue(pos, obvOsc);
      crossover1Y.SetValue(pos, 0);
      bool crossover1Value[1];
      if (!crossover1.GetValues(pos, 1, crossover1Value)) { crossover1Value[0] = EMPTY_VALUE; }
      bool crossoverCond2 = crossover1Value[0];
      crossunder2X.SetValue(pos, input_src);
      crossunder2Y.SetValue(pos, tsi2);
      bool crossunder2Value[1];
      if (!crossunder2.GetValues(pos, 1, crossunder2Value)) { crossunder2Value[0] = EMPTY_VALUE; }
      double crossPHCond = (SafeLess(input_src, 0) && crossunder2Value[0] ? valuewhen9.Update(pos, time[pos], input_src, tsi2) : EMPTY_VALUE);
      crossover2X.SetValue(pos, input_src);
      crossover2Y.SetValue(pos, tsi2);
      bool crossover2Value[1];
      if (!crossover2.GetValues(pos, 1, crossover2Value)) { crossover2Value[0] = EMPTY_VALUE; }
      double crossPLCond = (SafeGreater(input_src, 0) && crossover2Value[0] ? valuewhen10.Update(pos, time[pos], input_src, tsi2) : EMPTY_VALUE);
      SetStream(crossvwph, pos, valuewhen11.Update(pos, time[pos], crossPHCond, crossPHCond), crossvwph_DEFAULT_VALUE);
      SetStream(crossvwpl, pos, valuewhen12.Update(pos, time[pos], crossPLCond, crossPLCond), crossvwpl_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      change4Source.SetValue(pos, SafeLess(crossvwph[pos], crossvwph[pos - 1]));
      double change4Value[1];
      if (!change4.GetValues(pos, 1, change4Value)) { change4Value[0] = EMPTY_VALUE; }
      if (pos - 1 < 0) { continue; }
      SetStream(crosscounterph, pos, (NumberToBool(change4Value[0]) ? SafePlus(Nz(crosscounterph[pos - 1]), 1) : 0), crosscounterph_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      change5Source.SetValue(pos, SafeGreater(crossvwpl[pos], crossvwpl[pos - 1]));
      double change5Value[1];
      if (!change5.GetValues(pos, 1, change5Value)) { change5Value[0] = EMPTY_VALUE; }
      if (pos - 1 < 0) { continue; }
      SetStream(crosscounterpl, pos, (NumberToBool(change5Value[0]) ? SafePlus(Nz(crosscounterpl[pos - 1]), 1) : 0), crosscounterpl_DEFAULT_VALUE);
      uint crosssellmaybe = ((crosscounterph[pos] == 1) ? AddTransparency(Orange, 00) : EMPTY_VALUE);
      uint crossbuymaybe = ((crosscounterpl[pos] == 1) ? AddTransparency(Aqua, 00) : EMPTY_VALUE);
      color plot9_color = AddTransparency(White, 100);
      if (plot9_color != EMPTY_VALUE) { plot9[pos] = sell_zone; }
      else { plot9[pos] = EMPTY_VALUE; }
      double upper_band = plot9[pos];
      color plot10_color = AddTransparency(White, 100);
      if (plot10_color != EMPTY_VALUE) { plot10[pos] = buy_zone; }
      else { plot10[pos] = EMPTY_VALUE; }
      double lower_band = plot10[pos];
      color plot11_color = AddTransparency(White, 100);
      if (plot11_color != EMPTY_VALUE) { plot11[pos] = 100; }
      else { plot11[pos] = EMPTY_VALUE; }
      double zero1 = plot11[pos];
      color plot12_color = AddTransparency(White, 100);
      if (plot12_color != EMPTY_VALUE) { plot12[pos] = (-100); }
      else { plot12[pos] = EMPTY_VALUE; }
      double zero2 = plot12[pos];
      fill13.Set(pos, lower_band, zero2, AddTransparency(Aqua, 90));
      fill14.Set(pos, upper_band, zero1, AddTransparency(Orange, 90));
      plot15.Set(pos, input_src, (SafeGE(NormalizedIndicator, 105) ? AddTransparency(0x00008d, 70) : (SafeGE(NormalizedIndicator, 90) ? AddTransparency(Red, 70) : (SafeGE(NormalizedIndicator, 70) ? AddTransparency(Orange, 70) : (SafeGE(NormalizedIndicator, 50) ? AddTransparency(Yellow, 70) : (SafeGE(NormalizedIndicator, 20) ? AddTransparency(Aqua, 70) : (SafeGE(NormalizedIndicator, 5) ? AddTransparency(Silver, 70) : AddTransparency(White, 70))))))));
      color plot16_color = AddTransparency(Aqua, 0);
      if (plot16_color != EMPTY_VALUE) { plot16[pos] = input_src; }
      else { plot16[pos] = EMPTY_VALUE; }
      double filltype = plot16[pos];
      color plot17_color = AddTransparency(Orange, 0);
      if (plot17_color != EMPTY_VALUE) { plot17[pos] = tsi2; }
      else { plot17[pos] = EMPTY_VALUE; }
      color plot18_color = AddTransparency(White, 100);
      if (plot18_color != EMPTY_VALUE) { plot18[pos] = 0; }
      else { plot18[pos] = EMPTY_VALUE; }
      double zeromarker = plot18[pos];
      highestpivot2Source.SetValue(pos, obvOsc);
      double highestpivot2Value[1];
      if (!PivotHighStream::GetValues(pos, 1, highestpivot2Value, highestpivot2Source, pivL, pivR)) { highestpivot2Value[0] = EMPTY_VALUE; }
      double PHCond = (SafeGreater(obvOsc, 50) ? highestpivot2Value[0] : EMPTY_VALUE);
      lowestpivot2Source.SetValue(pos, obvOsc);
      double lowestpivot2Value[1];
      if (!PivotLowStream::GetValues(pos, 1, lowestpivot2Value, lowestpivot2Source, pivL, pivR)) { lowestpivot2Value[0] = EMPTY_VALUE; }
      double PLCond = (SafeLess(obvOsc, 50) ? lowestpivot2Value[0] : EMPTY_VALUE);
      plot22[pos] = PHCond;
      plot23[pos] = PLCond;
      Setplot24(pos, NumberToBool(input_src), high[pos], crosssellmaybe);
      Setplot26(pos, NumberToBool(input_src), low[pos], crossbuymaybe);
      if (PHCond) { _signaler.SendNotifications("Pivot High", "Pivot High {{ticker}}"); }
      if (PLCond) { _signaler.SendNotifications("Pivot Low", "Pivot Low {{ticker}}"); }
      if (crossoverCond1) { _signaler.SendNotifications("TSI Crossed Up", "TSI Cross Up {{ticker}}"); }
      if (crossoverCond2) { _signaler.SendNotifications("TSI Crossed Down", "TSI Cross Down {{ticker}}"); }
      if (bullCond) { _signaler.SendNotifications("Bull Diversion", "TSI Regular Bull Div {{ticker}}"); }
      if (bearCond) { _signaler.SendNotifications("Bear Diversion", "TSI Regular Bear Div {{ticker}}"); }
      if (hiddenBullCond) { _signaler.SendNotifications("Hidden Bull Diversion", "TSI Hidden Bull Div {{ticker}}"); }
      if (hiddenBearCond) { _signaler.SendNotifications("Hidden Bear Diversion", "TSI Hidden Bear Div {{ticker}}"); }
   }
   LabelsCollection::Redraw();
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