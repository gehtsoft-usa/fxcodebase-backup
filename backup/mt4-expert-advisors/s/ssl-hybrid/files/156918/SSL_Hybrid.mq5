//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75266

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

#property indicator_chart_window
#property indicator_buffers 149
#property indicator_plots 21
#property indicator_label1 "Candle Size > 1xATR"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Exit Arrows"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Exit Arrows"
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "MA Baseline"
#property indicator_type4 DRAW_COLOR_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "MA Baseline"
#property indicator_type5 DRAW_COLOR_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "SSL1"
#property indicator_type6 DRAW_COLOR_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "SSL1"
#property indicator_type7 DRAW_COLOR_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_type8 DRAW_COLOR_CANDLES
#property indicator_label9 "Baseline Upper Channel"
#property indicator_type9 DRAW_COLOR_LINE
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Baseline Upper Channel"
#property indicator_type10 DRAW_COLOR_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "Basiline Lower Channel"
#property indicator_type11 DRAW_COLOR_LINE
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_label12 "Basiline Lower Channel"
#property indicator_type12 DRAW_COLOR_LINE
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_type13 DRAW_FILLING
#property indicator_width13 1
#property indicator_label14 "SSL2"
#property indicator_type14 DRAW_ARROW
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_label15 "SSL2"
#property indicator_type15 DRAW_ARROW
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_label16 "SSL2"
#property indicator_type16 DRAW_ARROW
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1
#property indicator_label17 "SSL2"
#property indicator_type17 DRAW_ARROW
#property indicator_style17 STYLE_SOLID
#property indicator_width17 1
#property indicator_label18 "SSL2"
#property indicator_type18 DRAW_ARROW
#property indicator_style18 STYLE_SOLID
#property indicator_width18 1
#property indicator_label19 "SSL2"
#property indicator_type19 DRAW_ARROW
#property indicator_style19 STYLE_SOLID
#property indicator_width19 1
#property indicator_label20 "+ATR"
#property indicator_type20 DRAW_LINE
#property indicator_color20 White
#property indicator_style20 STYLE_SOLID
#property indicator_width20 1
#property indicator_label21 "-ATR"
#property indicator_type21 DRAW_LINE
#property indicator_color21 White
#property indicator_style21 STYLE_SOLID
#property indicator_width21 1

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

color FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
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
      return bottomValue;
   }
   if (rate < 0)
   {
      return topValue;
   }
   int bottomR = ColorR(bottomColor);
   int bottomG = ColorG(bottomColor);
   int bottomB = ColorB(bottomColor);
   int topR = ColorR(topColor);
   int topG = ColorG(topColor);
   int topB = ColorB(topColor);
   return ColorRGB(bottomR + int(rate * (topR - bottomR)), bottomG + int(rate * (topG - bottomG)), bottomB + int(rate * (topB - bottomB)), 0);
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

//LinearRegressionOnStream v1.4

class LinearRegressionOnStream : public AOnStream
{
   int _length;
   double _buffer[];
   int _offset;
public:
   LinearRegressionOnStream(IStream *source, const int length, int offset = 0)
      :AOnStream(source)
   {
      _offset = offset;
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period - _offset < 0)
      {
         return false;
      }
      int size = Size();
      int index = size - 1 - period;
      int range = ArrayRange(_buffer, 0);
      if (range < size)
      {
         ArrayResize(_buffer, size);
         for (int i = range; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double price[1];
      if (!_source.GetSeriesValues(period - _offset, 1, price))
      {
         return false;
      }
      if (index < _length || _buffer[index + 1 - _length] == 0)
      {
         _buffer[index] = price[0];
         return false;
      }

      double lwmw = _length;
      double lwma = lwmw * price[0];
      double sma  = price[0];
      for (int i = 1; i < _length; ++i)
      {
         if (_buffer[index - i] == EMPTY_VALUE)
         {
            _buffer[index] = price[0];
            return false;
         }
         double weight = _length - i;
         lwmw += weight;
         lwma += weight * _buffer[index - i];  
         sma += _buffer[index - i];
      }
      _buffer[index] = (3.0 * lwma / lwmw - 2.0 * sma / _length);
      val = _buffer[index];
      return true;
   }
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

#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL
// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
// Boolean Stream v.1.1

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
   virtual bool GetValues(const int period, const int count, int &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
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
   virtual bool GetValues(const int period, const int count, int &val[])
   {
      bool values[];
      ArrayResize(values, count);
      if (!GetValues(period, count, values))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = values[i];
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, int &val[])
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
   
   double Set(int pos, double value, uint clr)
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
         return EMPTY_VALUE;
      }
      int prevValueIndex = FindPrevValueIndex(pos);
      if (prevValueIndex == -1)
      {
         return EMPTY_VALUE;
      }
      int length = pos - prevValueIndex + 1;
      if (colors[pos] == -1)
      {
         for (int i = 1; i < length; ++i)
         {
            values[prevValueIndex + i] = EMPTY_VALUE;
            colors[prevValueIndex + i] = EMPTY_VALUE;
         }
         return EMPTY_VALUE;
      }
      double diff = buffer[pos] - buffer[prevValueIndex];
      double step = diff / (length - 1);
      for (int i = 0; i < length; ++i)
      {
         values[prevValueIndex + i] = buffer[prevValueIndex] + step * i;
         colors[prevValueIndex + i] = colors[pos];
      }
      return value;
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

input bool param1 = true; // Show Baseline
input bool param2 = false; // Show SSL1
input bool param3 = true; // Show ATR bands
input int param4 = 14; // ATR Period
input int param5 = 1; // ATR Multi
input string param6 = "WMA"; // ATR Smoothing
input string param7 = "HMA"; // SSL1 / Baseline Type
input int param8 = 60; // SSL1 / Baseline Length
input string param9 = "JMA"; // SSL2 / Continuation Type
input int param10 = 5; // SSL 2 Length
input string param11 = "HMA"; // EXIT Type
input int param12 = 15; // EXIT Length
input PriceType param13 = PriceClose; // Source
input int param14 = 1; // Kijun MOD Divider
input int param15 = 3; // * Jurik (JMA) Only - Phase
input int param16 = 1; // * Jurik (JMA) Only - Power
input int param17 = 10; // * Volatility Adjusted (VAMA) Only - Volatility lookback length
input double param18 = 0.8; // Modular Filter, General Filter Only - Beta
input bool param19 = false; // Modular Filter Only - Feedback
input double param20 = 0.5; // Modular Filter Only - Feedback Weighting
input int param21 = 20; // EDSMA - Super Smoother Filter Length
input int param22 = 2; // EDSMA - Super Smoother Filter Poles
input int param23 = 10; // * Volatility Adjusted (VAMA) Only - Volatility lookback length
input int param24 = 20; // EDSMA - Super Smoother Filter Length
input bool param25 = true;
input double param26 = 0.2; // Base Channel Multiplier
input bool param27 = true; // Color Bars
input double param28 = 0.9; // Continuation ATR Criteria
input int bars_limit = 1000; // Bars limit
Signaler* _signaler;
int show_Baseline;
int show_SSL1;
int show_atr;
int atrlen;
double mult;
string smoothing;
class ma_function_fS_iStream
{
   IStream* source;
   int atrlen;
   FloatStream* rma1Source;
   RmaOnStream* rma1;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* wma1Source;
   WMAOnStream* wma1;
   bool _initialized;
public:
   ma_function_fS_iStream(IStream* source, int atrlen)
   {
      _initialized = false;
      this.source = source;
      source.AddRef();
      this.atrlen = atrlen;
      rma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      rma1 = new RmaOnStream(rma1Source, atrlen);
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, atrlen);
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, atrlen);
      wma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma1 = new WMAOnStream(wma1Source, atrlen);
   }
   ~ma_function_fS_iStream()
   {
      source.Release();
      rma1Source.Release();
      rma1.Release();
      sma1Source.Release();
      sma1.Release();
      ema1Source.Release();
      ema1.Release();
      wma1Source.Release();
      wma1.Release();
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
         rma1Source.Init();
         sma1Source.Init();
         ema1Source.Init();
         wma1Source.Init();
         _initialized = true;
      }
      if ((smoothing == "RMA"))
      {
         double sourceValue[1];
         if (!source.GetValues(pos, 1, sourceValue)) { sourceValue[0] = EMPTY_VALUE; }
         rma1Source.SetValue(pos, sourceValue[0]);
         double rma1Value[1];
         if (!rma1.GetValues(pos, 1, rma1Value)) { rma1Value[0] = EMPTY_VALUE; }
         __out1 = rma1Value[0];
      }
      else
      {
         if ((smoothing == "SMA"))
         {
            double sourceValue[1];
            if (!source.GetValues(pos, 1, sourceValue)) { sourceValue[0] = EMPTY_VALUE; }
            sma1Source.SetValue(pos, sourceValue[0]);
            double sma1Value[1];
            if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
            __out1 = sma1Value[0];
         }
         else
         {
            if ((smoothing == "EMA"))
            {
               double sourceValue[1];
               if (!source.GetValues(pos, 1, sourceValue)) { sourceValue[0] = EMPTY_VALUE; }
               ema1Source.SetValue(pos, sourceValue[0]);
               double ema1Value[1];
               if (!ema1.GetValues(pos, 1, ema1Value)) { ema1Value[0] = EMPTY_VALUE; }
               __out1 = ema1Value[0];
            }
            else
            {
               double sourceValue[1];
               if (!source.GetValues(pos, 1, sourceValue)) { sourceValue[0] = EMPTY_VALUE; }
               wma1Source.SetValue(pos, sourceValue[0]);
               double wma1Value[1];
               if (!wma1.GetValues(pos, 1, wma1Value)) { wma1Value[0] = EMPTY_VALUE; }
               __out1 = wma1Value[0];
            }
         }
      }
      return true;
   }
};
TrueRangeStream* trs1;
FloatStream* ma_function_fS_i1_param1;
ma_function_fS_iStream* ma_function_fS_i1;
string maType;
int len;
string SSL2Type;
int len2;
string SSL3Type;
int len3;
IStream* param13Stream;
IStream* src;
int kidiv;
int jurik_phase;
int jurik_power;
int volatility_lookback;
double beta;
int feedback;
double z;
int ssfLength;
int ssfPoles;
class get2PoleSSF_fS_iStream
{
   IStream* src;
   int length;
   double ssf[];
   double ssf_DEFAULT_VALUE;
   bool _initialized;
public:
   get2PoleSSF_fS_iStream(IStream* src, int length)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
   }
   ~get2PoleSSF_fS_iStream()
   {
      src.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, ssf, INDICATOR_CALCULATIONS);
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
         ssf_DEFAULT_VALUE = 0.0;
         ArrayInitialize(ssf, ssf_DEFAULT_VALUE);
         _initialized = true;
      }
      double PI = SafeMultiply(2, MathArcsin(1));
      double arg = SafeDivide(SafeMultiply(MathSqrt(2), PI), length);
      double a1 = MathExp(InvertSign(arg));
      double b1 = SafeMultiply(SafeMultiply(2, a1), SafeCos(arg));
      double c2 = b1;
      double c3 = InvertSign(SafeMathPow(a1, 2));
      double c1 = SafeMinus(SafeMinus(1, c2), c3);
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      if (pos - 1 < 0) { return false; }
      if (pos - 2 < 0) { return false; }
      SetStream(ssf, pos, SafePlus(SafePlus(SafeMultiply(c1, srcValue[0]), SafeMultiply(c2, Nz(ssf[pos - 1]))), SafeMultiply(c3, Nz(ssf[pos - 2]))), ssf_DEFAULT_VALUE);
      __out1 = ssf[pos];
      return true;
   }
};
class get3PoleSSF_fS_iStream
{
   IStream* src;
   int length;
   double ssf[];
   double ssf_DEFAULT_VALUE;
   bool _initialized;
public:
   get3PoleSSF_fS_iStream(IStream* src, int length)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
   }
   ~get3PoleSSF_fS_iStream()
   {
      src.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, ssf, INDICATOR_CALCULATIONS);
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
         ssf_DEFAULT_VALUE = 0.0;
         ArrayInitialize(ssf, ssf_DEFAULT_VALUE);
         _initialized = true;
      }
      double PI = SafeMultiply(2, MathArcsin(1));
      double arg = SafeDivide(PI, length);
      double a1 = MathExp(InvertSign(arg));
      double b1 = SafeMultiply(SafeMultiply(2, a1), SafeCos(SafeMultiply(1.738, arg)));
      double c1 = SafeMathPow(a1, 2);
      double coef2 = SafePlus(b1, c1);
      double coef3 = InvertSign((SafePlus(c1, SafeMultiply(b1, c1))));
      double coef4 = SafeMathPow(c1, 2);
      double coef1 = SafeMinus(SafeMinus(SafeMinus(1, coef2), coef3), coef4);
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      if (pos - 1 < 0) { return false; }
      if (pos - 2 < 0) { return false; }
      if (pos - 3 < 0) { return false; }
      SetStream(ssf, pos, SafePlus(SafePlus(SafeMultiply(coef1, srcValue[0]), SafePlus(SafeMultiply(coef2, Nz(ssf[pos - 1])), SafeMultiply(coef3, Nz(ssf[pos - 2])))), SafeMultiply(coef4, Nz(ssf[pos - 3]))), ssf_DEFAULT_VALUE);
      __out1 = ssf[pos];
      return true;
   }
};
class ma_s_fS_iStream
{
   string type;
   IStream* src;
   int len;
   FloatStream* sma2Source;
   SmaOnStream* sma2;
   FloatStream* sma3Source;
   SmaOnStream* sma3;
   double ts[];
   double ts_DEFAULT_VALUE;
   double b[];
   double b_DEFAULT_VALUE;
   double c[];
   double c_DEFAULT_VALUE;
   double os[];
   double os_DEFAULT_VALUE;
   FloatStream* linreg1Source;
   LinearRegressionOnStream* linreg1;
   FloatStream* sma4Source;
   SmaOnStream* sma4;
   FloatStream* ema2Source;
   EMAOnStream* ema2;
   FloatStream* ema3Source;
   EMAOnStream* ema3;
   FloatStream* ema4Source;
   EMAOnStream* ema4;
   FloatStream* ema5Source;
   EMAOnStream* ema5;
   FloatStream* ema6Source;
   EMAOnStream* ema6;
   FloatStream* ema7Source;
   EMAOnStream* ema7;
   FloatStream* ema8Source;
   EMAOnStream* ema8;
   FloatStream* wma2Source;
   WMAOnStream* wma2;
   FloatStream* ema9Source;
   EMAOnStream* ema9;
   FloatStream* highest1Source;
   FloatStream* lowest1Source;
   FloatStream* wma3Source;
   WMAOnStream* wma3;
   FloatStream* wma4Source;
   WMAOnStream* wma4;
   FloatStream* wma5Source;
   WMAOnStream* wma5;
   double e0[];
   double e0_DEFAULT_VALUE;
   double e1[];
   double e1_DEFAULT_VALUE;
   double jma[];
   double jma_DEFAULT_VALUE;
   double e2[];
   double e2_DEFAULT_VALUE;
   LowestLowStream* lowest2;
   HighestHighStream* highest2;
   LowestLowStream* lowest3;
   HighestHighStream* highest3;
   double mg[];
   double mg_DEFAULT_VALUE;
   FloatStream* ema10Source;
   EMAOnStream* ema10;
   double zeros[];
   double zeros_DEFAULT_VALUE;
   FloatStream* get2PoleSSF_fS_i2_param1;
   get2PoleSSF_fS_iStream* get2PoleSSF_fS_i2;
   FloatStream* get3PoleSSF_fS_i3_param1;
   get3PoleSSF_fS_iStream* get3PoleSSF_fS_i3;
   FloatStream* stdev1Source;
   StDevStream* stdev1;
   double edsma[];
   double edsma_DEFAULT_VALUE;
   bool _initialized;
public:
   ma_s_fS_iStream(string type, IStream* src, int len)
   {
      _initialized = false;
      this.type = type;
      this.src = src;
      src.AddRef();
      this.len = len;
      sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma3 = new SmaOnStream(sma3Source, MathCeil(SafeDivide(len, 2)));
      sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma2 = new SmaOnStream(sma2Source, SafePlus(MathFloor(SafeDivide(len, 2)), 1));
      linreg1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      linreg1 = new LinearRegressionOnStream(linreg1Source, len, 0);
      sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma4 = new SmaOnStream(sma4Source, len);
      ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema2 = new EMAOnStream(ema2Source, len);
      ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema3 = new EMAOnStream(ema3Source, len);
      ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema4 = new EMAOnStream(ema4Source, len);
      ema5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema5 = new EMAOnStream(ema5Source, len);
      ema6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema6 = new EMAOnStream(ema6Source, len);
      ema8Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema8 = new EMAOnStream(ema8Source, len);
      ema7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema7 = new EMAOnStream(ema7Source, len);
      wma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma2 = new WMAOnStream(wma2Source, len);
      ema9Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema9 = new EMAOnStream(ema9Source, len);
      volatility_lookback = param23;
      highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma4 = new WMAOnStream(wma4Source, SafeDivide(len, 2));
      wma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma5 = new WMAOnStream(wma5Source, len);
      wma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma3 = new WMAOnStream(wma3Source, SafeMathRound(MathSqrt(len)));
      lowest2 = new LowestLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, len);
      highest2 = new HighestHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, len);
      lowest3 = new LowestLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, SafeDivide(len, kidiv));
      highest3 = new HighestHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, SafeDivide(len, kidiv));
      ema10Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema10 = new EMAOnStream(ema10Source, len);
      ssfLength = param24;
      stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      stdev1 = new StDevStream(stdev1Source, len);
   }
   ~ma_s_fS_iStream()
   {
      src.Release();
      sma2Source.Release();
      sma2.Release();
      sma3Source.Release();
      sma3.Release();
      linreg1Source.Release();
      linreg1.Release();
      sma4Source.Release();
      sma4.Release();
      ema2Source.Release();
      ema2.Release();
      ema3Source.Release();
      ema3.Release();
      ema4Source.Release();
      ema4.Release();
      ema5Source.Release();
      ema5.Release();
      ema6Source.Release();
      ema6.Release();
      ema7Source.Release();
      ema7.Release();
      ema8Source.Release();
      ema8.Release();
      wma2Source.Release();
      wma2.Release();
      ema9Source.Release();
      ema9.Release();
      highest1Source.Release();
      lowest1Source.Release();
      wma3Source.Release();
      wma3.Release();
      wma4Source.Release();
      wma4.Release();
      wma5Source.Release();
      wma5.Release();
      lowest2.Release();
      highest2.Release();
      lowest3.Release();
      highest3.Release();
      ema10Source.Release();
      ema10.Release();
      get2PoleSSF_fS_i2_param1.Release();
      delete get2PoleSSF_fS_i2;
      get3PoleSSF_fS_i3_param1.Release();
      delete get3PoleSSF_fS_i3;
      stdev1Source.Release();
      stdev1.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, ts, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, b, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, c, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, os, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, e0, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, e1, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, jma, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, e2, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, mg, INDICATOR_CALCULATIONS);
      SetIndexBuffer(id++, zeros, INDICATOR_CALCULATIONS);
      get2PoleSSF_fS_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      get2PoleSSF_fS_i2 = new get2PoleSSF_fS_iStream(get2PoleSSF_fS_i2_param1, ssfLength);
      id = get2PoleSSF_fS_i2.Init(id);
      get3PoleSSF_fS_i3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      get3PoleSSF_fS_i3 = new get3PoleSSF_fS_iStream(get3PoleSSF_fS_i3_param1, ssfLength);
      id = get3PoleSSF_fS_i3.Init(id);
      SetIndexBuffer(id++, edsma, INDICATOR_CALCULATIONS);
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
         sma3Source.Init();
         sma2Source.Init();
         ts_DEFAULT_VALUE = 0.;
         ArrayInitialize(ts, ts_DEFAULT_VALUE);
         b_DEFAULT_VALUE = 0.;
         ArrayInitialize(b, b_DEFAULT_VALUE);
         c_DEFAULT_VALUE = 0.;
         ArrayInitialize(c, c_DEFAULT_VALUE);
         os_DEFAULT_VALUE = 0.;
         ArrayInitialize(os, os_DEFAULT_VALUE);
         linreg1Source.Init();
         sma4Source.Init();
         ema2Source.Init();
         ema3Source.Init();
         ema4Source.Init();
         ema5Source.Init();
         ema6Source.Init();
         ema8Source.Init();
         ema7Source.Init();
         wma2Source.Init();
         ema9Source.Init();
         highest1Source.Init();
         lowest1Source.Init();
         wma4Source.Init();
         wma5Source.Init();
         wma3Source.Init();
         e0_DEFAULT_VALUE = 0.0;
         ArrayInitialize(e0, e0_DEFAULT_VALUE);
         e1_DEFAULT_VALUE = 0.0;
         ArrayInitialize(e1, e1_DEFAULT_VALUE);
         jma_DEFAULT_VALUE = 0.0;
         ArrayInitialize(jma, jma_DEFAULT_VALUE);
         e2_DEFAULT_VALUE = 0.0;
         ArrayInitialize(e2, e2_DEFAULT_VALUE);
         mg_DEFAULT_VALUE = 0.0;
         ArrayInitialize(mg, mg_DEFAULT_VALUE);
         ema10Source.Init();
         zeros_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(zeros, zeros_DEFAULT_VALUE);
         get2PoleSSF_fS_i2_param1.Init();
         get2PoleSSF_fS_i2.Clear();
         get3PoleSSF_fS_i3_param1.Init();
         get3PoleSSF_fS_i3.Clear();
         stdev1Source.Init();
         edsma_DEFAULT_VALUE = 0.0;
         ArrayInitialize(edsma, edsma_DEFAULT_VALUE);
         _initialized = true;
      }
      double result = 0;
      if ((type == "TMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         sma3Source.SetValue(pos, srcValue[0]);
         double sma3Value[1];
         if (!sma3.GetValues(pos, 1, sma3Value)) { sma3Value[0] = EMPTY_VALUE; }
         sma2Source.SetValue(pos, sma3Value[0]);
         double sma2Value[1];
         if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
         result = sma2Value[0];
      }
      if ((type == "MF"))
      {
         int alpha = SafeDivide(2, (len + 1));
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         if (pos - 1 < 0) { return false; }
         double a = (feedback ? SafePlus(z * srcValue[0], SafeMultiply((1 - z), Nz(ts[pos - 1], srcValue[0]))) : srcValue[0]);
         if (pos - 1 < 0) { return false; }
         if (pos - 1 < 0) { return false; }
         SetStream(b, pos, (SafeGreater(a, SafePlus(SafeMultiply(alpha, a), SafeMultiply((1 - alpha), Nz(b[pos - 1], a)))) ? a : SafePlus(SafeMultiply(alpha, a), SafeMultiply((1 - alpha), Nz(b[pos - 1], a)))), b_DEFAULT_VALUE);
         if (pos - 1 < 0) { return false; }
         if (pos - 1 < 0) { return false; }
         SetStream(c, pos, (SafeLess(a, SafePlus(SafeMultiply(alpha, a), SafeMultiply((1 - alpha), Nz(c[pos - 1], a)))) ? a : SafePlus(SafeMultiply(alpha, a), SafeMultiply((1 - alpha), Nz(c[pos - 1], a)))), c_DEFAULT_VALUE);
         if (pos - 1 < 0) { return false; }
         SetStream(os, pos, ((a == b[pos]) ? 1 : ((a == c[pos]) ? 0 : os[pos - 1])), os_DEFAULT_VALUE);
         double upper = beta * b[pos] + (1 - beta) * c[pos];
         double lower = beta * c[pos] + (1 - beta) * b[pos];
         SetStream(ts, pos, os[pos] * upper + (1 - os[pos]) * lower, ts_DEFAULT_VALUE);
         result = ts[pos];
      }
      if ((type == "LSMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         linreg1Source.SetValue(pos, srcValue[0]);
         double linreg1Value[1];
         if (!linreg1.GetValues(pos, 1, linreg1Value)) { linreg1Value[0] = EMPTY_VALUE; }
         result = linreg1Value[0];
      }
      if ((type == "SMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         sma4Source.SetValue(pos, srcValue[0]);
         double sma4Value[1];
         if (!sma4.GetValues(pos, 1, sma4Value)) { sma4Value[0] = EMPTY_VALUE; }
         result = sma4Value[0];
      }
      if ((type == "EMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         ema2Source.SetValue(pos, srcValue[0]);
         double ema2Value[1];
         if (!ema2.GetValues(pos, 1, ema2Value)) { ema2Value[0] = EMPTY_VALUE; }
         result = ema2Value[0];
      }
      if ((type == "DEMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         ema3Source.SetValue(pos, srcValue[0]);
         double ema3Value[1];
         if (!ema3.GetValues(pos, 1, ema3Value)) { ema3Value[0] = EMPTY_VALUE; }
         double e = ema3Value[0];
         ema4Source.SetValue(pos, e);
         double ema4Value[1];
         if (!ema4.GetValues(pos, 1, ema4Value)) { ema4Value[0] = EMPTY_VALUE; }
         result = SafeMinus(SafeMultiply(2, e), ema4Value[0]);
      }
      if ((type == "TEMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         ema5Source.SetValue(pos, srcValue[0]);
         double ema5Value[1];
         if (!ema5.GetValues(pos, 1, ema5Value)) { ema5Value[0] = EMPTY_VALUE; }
         double e = ema5Value[0];
         ema6Source.SetValue(pos, e);
         double ema6Value[1];
         if (!ema6.GetValues(pos, 1, ema6Value)) { ema6Value[0] = EMPTY_VALUE; }
         ema8Source.SetValue(pos, e);
         double ema8Value[1];
         if (!ema8.GetValues(pos, 1, ema8Value)) { ema8Value[0] = EMPTY_VALUE; }
         ema7Source.SetValue(pos, ema8Value[0]);
         double ema7Value[1];
         if (!ema7.GetValues(pos, 1, ema7Value)) { ema7Value[0] = EMPTY_VALUE; }
         result = SafePlus(SafeMultiply(3, (SafeMinus(e, ema6Value[0]))), ema7Value[0]);
      }
      if ((type == "WMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         wma2Source.SetValue(pos, srcValue[0]);
         double wma2Value[1];
         if (!wma2.GetValues(pos, 1, wma2Value)) { wma2Value[0] = EMPTY_VALUE; }
         result = wma2Value[0];
      }
      if ((type == "VAMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         ema9Source.SetValue(pos, srcValue[0]);
         double ema9Value[1];
         if (!ema9.GetValues(pos, 1, ema9Value)) { ema9Value[0] = EMPTY_VALUE; }
         double mid = ema9Value[0];
         double dev = SafeMinus(srcValue[0], mid);
         highest1Source.SetValue(pos, dev);
         double highest1Value[1];
         if (!HighestHighStream::GetValues(pos, 1, highest1Value, highest1Source, volatility_lookback)) { highest1Value[0] = EMPTY_VALUE; }
         double vol_up = highest1Value[0];
         lowest1Source.SetValue(pos, dev);
         double lowest1Value[1];
         if (!LowestLowStream::GetValues(pos, 1, lowest1Value, lowest1Source, volatility_lookback)) { lowest1Value[0] = EMPTY_VALUE; }
         double vol_down = lowest1Value[0];
         result = SafePlus(mid, SafeDivide((SafePlus(vol_up, vol_down)), 2));
      }
      if ((type == "HMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         wma4Source.SetValue(pos, srcValue[0]);
         double wma4Value[1];
         if (!wma4.GetValues(pos, 1, wma4Value)) { wma4Value[0] = EMPTY_VALUE; }
         wma5Source.SetValue(pos, srcValue[0]);
         double wma5Value[1];
         if (!wma5.GetValues(pos, 1, wma5Value)) { wma5Value[0] = EMPTY_VALUE; }
         wma3Source.SetValue(pos, SafeMinus(SafeMultiply(2, wma4Value[0]), wma5Value[0]));
         double wma3Value[1];
         if (!wma3.GetValues(pos, 1, wma3Value)) { wma3Value[0] = EMPTY_VALUE; }
         result = wma3Value[0];
      }
      if ((type == "JMA"))
      {
         double phaseRatio = ((jurik_phase < (-100)) ? 0.5 : ((jurik_phase > 100) ? 2.5 : SafeDivide(jurik_phase, 100) + 1.5));
         beta = SafeDivide(0.45 * (len - 1), (0.45 * (len - 1) + 2));
         double alpha = MathPow(beta, jurik_power);
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         if (pos - 1 < 0) { return false; }
         SetStream(e0, pos, SafePlus(SafeMultiply((SafeMinus(1, alpha)), srcValue[0]), SafeMultiply(alpha, Nz(e0[pos - 1]))), e0_DEFAULT_VALUE);
         if (pos - 1 < 0) { return false; }
         SetStream(e1, pos, SafePlus((srcValue[0] - e0[pos]) * (1 - beta), SafeMultiply(beta, Nz(e1[pos - 1]))), e1_DEFAULT_VALUE);
         if (pos - 1 < 0) { return false; }
         if (pos - 1 < 0) { return false; }
         SetStream(e2, pos, SafePlus(SafeMultiply((SafeMinus(e0[pos] + phaseRatio * e1[pos], Nz(jma[pos - 1]))), SafeMathPow(SafeMinus(1, alpha), 2)), SafeMultiply(SafeMathPow(alpha, 2), Nz(e2[pos - 1]))), e2_DEFAULT_VALUE);
         if (pos - 1 < 0) { return false; }
         SetStream(jma, pos, SafePlus(e2[pos], Nz(jma[pos - 1])), jma_DEFAULT_VALUE);
         result = jma[pos];
      }
      if ((type == "Kijun v2"))
      {
         double lowest2Value[1];
         if (!lowest2.GetValues(pos, 1, lowest2Value)) { lowest2Value[0] = EMPTY_VALUE; }
         double highest2Value[1];
         if (!highest2.GetValues(pos, 1, highest2Value)) { highest2Value[0] = EMPTY_VALUE; }
         double kijun = SafeDivide((SafePlus(lowest2Value[0], highest2Value[0])), 2);
         double lowest3Value[1];
         if (!lowest3.GetValues(pos, 1, lowest3Value)) { lowest3Value[0] = EMPTY_VALUE; }
         double highest3Value[1];
         if (!highest3.GetValues(pos, 1, highest3Value)) { highest3Value[0] = EMPTY_VALUE; }
         double conversionLine = SafeDivide((SafePlus(lowest3Value[0], highest3Value[0])), 2);
         double delta = SafeDivide((SafePlus(kijun, conversionLine)), 2);
         result = delta;
      }
      if ((type == "McGinley"))
      {
         if (pos - 1 < 0) { return false; }
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         ema10Source.SetValue(pos, srcValue[0]);
         double ema10Value[1];
         if (!ema10.GetValues(pos, 1, ema10Value)) { ema10Value[0] = EMPTY_VALUE; }
         if (pos - 1 < 0) { return false; }
         if (pos - 1 < 0) { return false; }
         if (pos - 1 < 0) { return false; }
         SetStream(mg, pos, (((mg[pos - 1]) == EMPTY_VALUE) ? ema10Value[0] : SafePlus(mg[pos - 1], SafeDivide((SafeMinus(srcValue[0], mg[pos - 1])), (SafeMultiply(len, SafeMathPow(SafeDivide(srcValue[0], mg[pos - 1]), 4)))))), mg_DEFAULT_VALUE);
         result = mg[pos];
      }
      if ((type == "EDSMA"))
      {
         double srcValue[1];
         if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
         double srcValue_2[1];
         if (!src.GetValues(pos - 2, 1, srcValue_2)) { srcValue_2[0] = EMPTY_VALUE; }
         SetStream(zeros, pos, SafeMinus(srcValue[0], Nz(srcValue_2[0])), zeros_DEFAULT_VALUE);
         if (pos - 1 < 0) { return false; }
         double avgZeros = SafeDivide((SafePlus(zeros[pos], zeros[pos - 1])), 2);
         get2PoleSSF_fS_i2_param1.SetValue(pos, avgZeros);
         double get2PoleSSF_fS_i2Value;
         if (!get2PoleSSF_fS_i2.GetValue(pos, oldPos, get2PoleSSF_fS_i2Value)) { get2PoleSSF_fS_i2Value = EMPTY_VALUE; }
         get3PoleSSF_fS_i3_param1.SetValue(pos, avgZeros);
         double get3PoleSSF_fS_i3Value;
         if (!get3PoleSSF_fS_i3.GetValue(pos, oldPos, get3PoleSSF_fS_i3Value)) { get3PoleSSF_fS_i3Value = EMPTY_VALUE; }
         double ssf = ((ssfPoles == 2) ? get2PoleSSF_fS_i2Value : get3PoleSSF_fS_i3Value);
         stdev1Source.SetValue(pos, ssf);
         double stdev1Value[1];
         if (!stdev1.GetValues(pos, 1, stdev1Value)) { stdev1Value[0] = EMPTY_VALUE; }
         double stdev = stdev1Value[0];
         double scaledFilter = ((stdev != 0) ? SafeDivide(ssf, stdev) : 0);
         double alpha = SafeDivide(SafeMultiply(5, SafeMathAbs(scaledFilter)), len);
         if (pos - 1 < 0) { return false; }
         SetStream(edsma, pos, SafePlus(SafeMultiply(alpha, srcValue[0]), SafeMultiply((SafeMinus(1, alpha)), Nz(edsma[pos - 1]))), edsma_DEFAULT_VALUE);
         result = edsma[pos];
      }
      __out1 = result;
      return true;
   }
};
FloatStream* ma_s_fS_i4_param2;
ma_s_fS_iStream* ma_s_fS_i4;
FloatStream* ma_s_fS_i5_param2;
ma_s_fS_iStream* ma_s_fS_i5;
FloatStream* ma_s_fS_i6_param2;
ma_s_fS_iStream* ma_s_fS_i6;
FloatStream* ma_s_fS_i7_param2;
ma_s_fS_iStream* ma_s_fS_i7;
FloatStream* ma_s_fS_i8_param2;
ma_s_fS_iStream* ma_s_fS_i8;
FloatStream* ma_s_fS_i9_param2;
ma_s_fS_iStream* ma_s_fS_i9;
FloatStream* ma_s_fS_i10_param2;
ma_s_fS_iStream* ma_s_fS_i10;
int useTrueRange;
double multy;
FloatStream* ma_s_fS_i11_param2;
ma_s_fS_iStream* ma_s_fS_i11;
IStream* tr1;
FloatStream* ema11Source;
EMAOnStream* ema11;
double plot1[];
double Hlv[];
double Hlv_DEFAULT_VALUE;
double Hlv2[];
double Hlv2_DEFAULT_VALUE;
double Hlv3[];
double Hlv3_DEFAULT_VALUE;
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* crossover2X;
FloatStream* crossover2Y;
IBoolStream* crossover2;
int show_color_bar;
double plot2_upclr1[];
double plot2_dnclr1[];
double Setplot2(int pos, bool condition, double value, uint upclr, uint dnclr)
{
   if (!condition) { return EMPTY_VALUE; }
   if (value >= 0)
   {
      if (upclr == 0xffc300) { plot2_upclr1[pos] = value; return plot2_upclr1[pos]; }
   }
   else
   {
      if (dnclr == 0x6200ff) { plot2_dnclr1[pos] = value; return plot2_dnclr1[pos]; }
   }
   return EMPTY_VALUE;
}
ColoredPlot* plot4;
ColoredPlot* plot5;
ColoredPlot* plot6;
ColoredPlot* plot7;
CandleStreams* barcolor1;
ColoredPlot* plot9;
ColoredPlot* plot10;
ColoredPlot* plot11;
ColoredPlot* plot12;
ColoredFill* fill13;
double atr_crit;
double plot14_clr1[];
double plot14_clr2[];
double plot14_clr3[];
double Setplot14(int pos, double value, color clr)
{
   if (clr == Green) { plot14_clr1[pos] = value; return plot14_clr1[pos]; }
   else if (clr == Purple) { plot14_clr2[pos] = value; return plot14_clr2[pos]; }
   else if (clr == White) { plot14_clr3[pos] = value; return plot14_clr3[pos]; }
   return EMPTY_VALUE;
}
double plot17_clr1[];
double plot17_clr2[];
double plot17_clr3[];
double Setplot17(int pos, double value, color clr)
{
   if (clr == Green) { plot17_clr1[pos] = value; return plot17_clr1[pos]; }
   else if (clr == Purple) { plot17_clr2[pos] = value; return plot17_clr2[pos]; }
   else if (clr == White) { plot17_clr3[pos] = value; return plot17_clr3[pos]; }
   return EMPTY_VALUE;
}
double plot20[];
double plot21[];
FloatStream* crossover3X;
FloatStream* crossover3Y;
IBoolStream* crossover3;
FloatStream* crossover4X;
FloatStream* crossover4Y;
IBoolStream* crossover4;
FloatStream* crossover5X;
FloatStream* crossover5Y;
IBoolStream* crossover5;
FloatStream* crossover6X;
FloatStream* crossover6Y;
IBoolStream* crossover6;
FloatStream* crossover7X;
FloatStream* crossover7Y;
IBoolStream* crossover7;
FloatStream* crossover8X;
FloatStream* crossover8Y;
IBoolStream* crossover8;

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
   show_Baseline = param1;
   show_SSL1 = param2;
   show_atr = param3;
   atrlen = param4;
   mult = param5;
   smoothing = param6;
   trs1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
   maType = param7;
   len = param8;
   SSL2Type = param9;
   len2 = param10;
   SSL3Type = param11;
   len3 = param12;
   param13Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param13);
   src = param13Stream;
   kidiv = param14;
   jurik_phase = param15;
   jurik_power = param16;
   volatility_lookback = param17;
   beta = param18;
   feedback = param19;
   z = param20;
   ssfLength = param21;
   ssfPoles = param22;
   useTrueRange = param25;
   multy = param26;
   ema11Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema11 = new EMAOnStream(ema11Source, len);
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, White);
   PlotIndexSetInteger(1, PLOT_ARROW, 116);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 5);
   ++id;
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   crossover2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = CrossStreamFactory::CreateCrossover(crossover2X, crossover2Y);
   show_color_bar = param27;
   SetIndexBuffer(id, plot2_upclr1, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 0xffc300);
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot2_dnclr1, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, 0x6200ff);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 5);
   ++id;
   plot4 = new ColoredPlot(3);
   plot4.AddColor(0xffc300);
   plot4.AddColor(0x6200ff);
   plot4.AddColor(Gray);
   plot4.SetOffset(0);
   id = plot4.RegisterStreams(id);
   plot5 = new ColoredPlot(4);
   plot5.AddColor(0xffc300);
   plot5.AddColor(0x6200ff);
   plot5.AddColor(Gray);
   plot5.SetOffset(0);
   id = plot5.RegisterStreams(id);
   plot6 = new ColoredPlot(5);
   plot6.AddColor(0xffc300);
   plot6.AddColor(0x6200ff);
   plot6.AddColor(EMPTY_VALUE);
   plot6.SetOffset(0);
   id = plot6.RegisterStreams(id);
   plot7 = new ColoredPlot(6);
   plot7.AddColor(0xffc300);
   plot7.AddColor(0x6200ff);
   plot7.AddColor(EMPTY_VALUE);
   plot7.SetOffset(0);
   id = plot7.RegisterStreams(id);
   barcolor1 = new CandleStreams(7);
   barcolor1.AddColor(0xffc300);
   barcolor1.AddColor(0x6200ff);
   barcolor1.AddColor(Gray);
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id);
   plot9 = new ColoredPlot(8);
   plot9.AddColor(0xffc300);
   plot9.AddColor(0x6200ff);
   plot9.AddColor(Gray);
   plot9.SetOffset(0);
   id = plot9.RegisterStreams(id);
   plot10 = new ColoredPlot(9);
   plot10.AddColor(0xffc300);
   plot10.AddColor(0x6200ff);
   plot10.AddColor(Gray);
   plot10.SetOffset(0);
   id = plot10.RegisterStreams(id);
   plot11 = new ColoredPlot(10);
   plot11.AddColor(0xffc300);
   plot11.AddColor(0x6200ff);
   plot11.AddColor(Gray);
   plot11.SetOffset(0);
   id = plot11.RegisterStreams(id);
   plot12 = new ColoredPlot(11);
   plot12.AddColor(0xffc300);
   plot12.AddColor(0x6200ff);
   plot12.AddColor(Gray);
   plot12.SetOffset(0);
   id = plot12.RegisterStreams(id);
   fill13 = new ColoredFill(12);
   fill13.AddColor(0xffc300);
   fill13.AddColor(0x6200ff);
   fill13.AddColor(Gray);
   id = fill13.RegisterStreams(id);
   atr_crit = param28;
   SetIndexBuffer(id, plot14_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(14, PLOT_LINE_COLOR, Green);
   PlotIndexSetInteger(14, PLOT_ARROW, 161);
   PlotIndexSetInteger(14, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot14_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(15, PLOT_LINE_COLOR, Purple);
   PlotIndexSetInteger(15, PLOT_ARROW, 161);
   PlotIndexSetInteger(15, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot14_clr3, INDICATOR_DATA);
   PlotIndexSetInteger(16, PLOT_LINE_COLOR, White);
   PlotIndexSetInteger(16, PLOT_ARROW, 161);
   PlotIndexSetInteger(16, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot17_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(17, PLOT_LINE_COLOR, Green);
   PlotIndexSetInteger(17, PLOT_ARROW, 161);
   PlotIndexSetInteger(17, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot17_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(18, PLOT_LINE_COLOR, Purple);
   PlotIndexSetInteger(18, PLOT_ARROW, 161);
   PlotIndexSetInteger(18, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot17_clr3, INDICATOR_DATA);
   PlotIndexSetInteger(19, PLOT_LINE_COLOR, White);
   PlotIndexSetInteger(19, PLOT_ARROW, 161);
   PlotIndexSetInteger(19, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id++, plot20, INDICATOR_DATA);
   SetIndexBuffer(id++, plot21, INDICATOR_DATA);
   crossover3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3 = CrossStreamFactory::CreateCrossover(crossover3X, crossover3Y);
   crossover4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover4Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover4 = CrossStreamFactory::CreateCrossover(crossover4X, crossover4Y);
   crossover5X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover5Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover5 = CrossStreamFactory::CreateCrossover(crossover5X, crossover5Y);
   crossover6X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover6Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover6 = CrossStreamFactory::CreateCrossover(crossover6X, crossover6Y);
   crossover7X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover7Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover7 = CrossStreamFactory::CreateCrossover(crossover7X, crossover7Y);
   crossover8X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover8Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover8 = CrossStreamFactory::CreateCrossover(crossover8X, crossover8Y);
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "SSL Hybrid");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   ma_function_fS_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_function_fS_i1 = new ma_function_fS_iStream(ma_function_fS_i1_param1, atrlen);
   id = ma_function_fS_i1.Init(id);
   ma_s_fS_i4_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_s_fS_i4 = new ma_s_fS_iStream(maType, ma_s_fS_i4_param2, len);
   id = ma_s_fS_i4.Init(id);
   ma_s_fS_i5_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_s_fS_i5 = new ma_s_fS_iStream(maType, ma_s_fS_i5_param2, len);
   id = ma_s_fS_i5.Init(id);
   ma_s_fS_i6_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_s_fS_i6 = new ma_s_fS_iStream(SSL2Type, ma_s_fS_i6_param2, len2);
   id = ma_s_fS_i6.Init(id);
   ma_s_fS_i7_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_s_fS_i7 = new ma_s_fS_iStream(SSL2Type, ma_s_fS_i7_param2, len2);
   id = ma_s_fS_i7.Init(id);
   ma_s_fS_i8_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_s_fS_i8 = new ma_s_fS_iStream(SSL3Type, ma_s_fS_i8_param2, len3);
   id = ma_s_fS_i8.Init(id);
   ma_s_fS_i9_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_s_fS_i9 = new ma_s_fS_iStream(SSL3Type, ma_s_fS_i9_param2, len3);
   id = ma_s_fS_i9.Init(id);
   ma_s_fS_i10_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_s_fS_i10 = new ma_s_fS_iStream(maType, ma_s_fS_i10_param2, len);
   id = ma_s_fS_i10.Init(id);
   ma_s_fS_i11_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_s_fS_i11 = new ma_s_fS_iStream(maType, ma_s_fS_i11_param2, len);
   id = ma_s_fS_i11.Init(id);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(id++, Hlv, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Hlv2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Hlv3, INDICATOR_CALCULATIONS);
   id = plot4.RegisterInternalStreams(id);
   id = plot5.RegisterInternalStreams(id);
   id = plot6.RegisterInternalStreams(id);
   id = plot7.RegisterInternalStreams(id);
   id = plot9.RegisterInternalStreams(id);
   id = plot10.RegisterInternalStreams(id);
   id = plot11.RegisterInternalStreams(id);
   id = plot12.RegisterInternalStreams(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   trs1.Release();
   ma_function_fS_i1_param1.Release();
   delete ma_function_fS_i1;
   param13Stream.Release();
   ma_s_fS_i4_param2.Release();
   delete ma_s_fS_i4;
   ma_s_fS_i5_param2.Release();
   delete ma_s_fS_i5;
   ma_s_fS_i6_param2.Release();
   delete ma_s_fS_i6;
   ma_s_fS_i7_param2.Release();
   delete ma_s_fS_i7;
   ma_s_fS_i8_param2.Release();
   delete ma_s_fS_i8;
   ma_s_fS_i9_param2.Release();
   delete ma_s_fS_i9;
   ma_s_fS_i10_param2.Release();
   delete ma_s_fS_i10;
   ma_s_fS_i11_param2.Release();
   delete ma_s_fS_i11;
   tr1.Release();
   ema11Source.Release();
   ema11.Release();
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   delete plot4;
   delete plot5;
   delete plot6;
   delete plot7;
   delete barcolor1;
   delete plot9;
   delete plot10;
   delete plot11;
   delete plot12;
   delete fill13;
   crossover3X.Release();
   crossover3Y.Release();
   crossover3.Release();
   crossover4X.Release();
   crossover4Y.Release();
   crossover4.Release();
   crossover5X.Release();
   crossover5Y.Release();
   crossover5.Release();
   crossover6X.Release();
   crossover6Y.Release();
   crossover6.Release();
   crossover7X.Release();
   crossover7Y.Release();
   crossover7.Release();
   crossover8X.Release();
   crossover8Y.Release();
   crossover8.Release();
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
      ma_function_fS_i1_param1.Init();
      ma_function_fS_i1.Clear();
      ma_s_fS_i4_param2.Init();
      ma_s_fS_i4.Clear();
      ma_s_fS_i5_param2.Init();
      ma_s_fS_i5.Clear();
      ma_s_fS_i6_param2.Init();
      ma_s_fS_i6.Clear();
      ma_s_fS_i7_param2.Init();
      ma_s_fS_i7.Clear();
      ma_s_fS_i8_param2.Init();
      ma_s_fS_i8.Clear();
      ma_s_fS_i9_param2.Init();
      ma_s_fS_i9.Clear();
      ma_s_fS_i10_param2.Init();
      ma_s_fS_i10.Clear();
      ma_s_fS_i11_param2.Init();
      ma_s_fS_i11.Clear();
      ema11Source.Init();
      ArrayInitialize(plot1, EMPTY_VALUE);
      Hlv_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(Hlv, Hlv_DEFAULT_VALUE);
      Hlv2_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(Hlv2, Hlv2_DEFAULT_VALUE);
      Hlv3_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(Hlv3, Hlv3_DEFAULT_VALUE);
      crossover1X.Init();
      crossover1Y.Init();
      crossover2X.Init();
      crossover2Y.Init();
      ArrayInitialize(plot2_upclr1, EMPTY_VALUE);
      ArrayInitialize(plot2_dnclr1, EMPTY_VALUE);
      plot4.Init();
      plot5.Init();
      plot6.Init();
      plot7.Init();
      barcolor1.Init();
      plot9.Init();
      plot10.Init();
      plot11.Init();
      plot12.Init();
      fill13.Init();
      ArrayInitialize(plot14_clr1, EMPTY_VALUE);
      ArrayInitialize(plot14_clr2, EMPTY_VALUE);
      ArrayInitialize(plot14_clr3, EMPTY_VALUE);
      ArrayInitialize(plot17_clr1, EMPTY_VALUE);
      ArrayInitialize(plot17_clr2, EMPTY_VALUE);
      ArrayInitialize(plot17_clr3, EMPTY_VALUE);
      ArrayInitialize(plot20, EMPTY_VALUE);
      ArrayInitialize(plot21, EMPTY_VALUE);
      crossover3X.Init();
      crossover3Y.Init();
      crossover4X.Init();
      crossover4Y.Init();
      crossover5X.Init();
      crossover5Y.Init();
      crossover6X.Init();
      crossover6Y.Init();
      crossover7X.Init();
      crossover7Y.Init();
      crossover8X.Init();
      crossover8Y.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double trs1Value[1];
      if (!trs1.GetValues(pos, 1, trs1Value)) { trs1Value[0] = EMPTY_VALUE; }
      ma_function_fS_i1_param1.SetValue(pos, trs1Value[0]);
      double ma_function_fS_i1Value;
      if (!ma_function_fS_i1.GetValue(pos, oldPos, ma_function_fS_i1Value)) { ma_function_fS_i1Value = EMPTY_VALUE; }
      double atr_slen = ma_function_fS_i1Value;
      double upper_band = SafePlus(SafeMultiply(atr_slen, mult), close[pos]);
      double lower_band = SafeMinus(close[pos], SafeMultiply(atr_slen, mult));
      ma_s_fS_i4_param2.SetValue(pos, high[pos]);
      double ma_s_fS_i4Value;
      if (!ma_s_fS_i4.GetValue(pos, oldPos, ma_s_fS_i4Value)) { ma_s_fS_i4Value = EMPTY_VALUE; }
      double emaHigh = ma_s_fS_i4Value;
      ma_s_fS_i5_param2.SetValue(pos, low[pos]);
      double ma_s_fS_i5Value;
      if (!ma_s_fS_i5.GetValue(pos, oldPos, ma_s_fS_i5Value)) { ma_s_fS_i5Value = EMPTY_VALUE; }
      double emaLow = ma_s_fS_i5Value;
      ma_s_fS_i6_param2.SetValue(pos, high[pos]);
      double ma_s_fS_i6Value;
      if (!ma_s_fS_i6.GetValue(pos, oldPos, ma_s_fS_i6Value)) { ma_s_fS_i6Value = EMPTY_VALUE; }
      double maHigh = ma_s_fS_i6Value;
      ma_s_fS_i7_param2.SetValue(pos, low[pos]);
      double ma_s_fS_i7Value;
      if (!ma_s_fS_i7.GetValue(pos, oldPos, ma_s_fS_i7Value)) { ma_s_fS_i7Value = EMPTY_VALUE; }
      double maLow = ma_s_fS_i7Value;
      ma_s_fS_i8_param2.SetValue(pos, high[pos]);
      double ma_s_fS_i8Value;
      if (!ma_s_fS_i8.GetValue(pos, oldPos, ma_s_fS_i8Value)) { ma_s_fS_i8Value = EMPTY_VALUE; }
      double ExitHigh = ma_s_fS_i8Value;
      ma_s_fS_i9_param2.SetValue(pos, low[pos]);
      double ma_s_fS_i9Value;
      if (!ma_s_fS_i9.GetValue(pos, oldPos, ma_s_fS_i9Value)) { ma_s_fS_i9Value = EMPTY_VALUE; }
      double ExitLow = ma_s_fS_i9Value;
      ma_s_fS_i10_param2.SetValue(pos, close[pos]);
      double ma_s_fS_i10Value;
      if (!ma_s_fS_i10.GetValue(pos, oldPos, ma_s_fS_i10Value)) { ma_s_fS_i10Value = EMPTY_VALUE; }
      double BBMC = ma_s_fS_i10Value;
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      ma_s_fS_i11_param2.SetValue(pos, srcValue[0]);
      double ma_s_fS_i11Value;
      if (!ma_s_fS_i11.GetValue(pos, oldPos, ma_s_fS_i11Value)) { ma_s_fS_i11Value = EMPTY_VALUE; }
      double Keltma = ma_s_fS_i11Value;
      double tr1Value[1];
      if (!tr1.GetValues(pos, 1, tr1Value)) { tr1Value[0] = EMPTY_VALUE; }
      double range = (useTrueRange ? tr1Value[0] : high[pos] - low[pos]);
      ema11Source.SetValue(pos, range);
      double ema11Value[1];
      if (!ema11.GetValues(pos, 1, ema11Value)) { ema11Value[0] = EMPTY_VALUE; }
      double rangema = ema11Value[0];
      double upperk = SafePlus(Keltma, SafeMultiply(rangema, multy));
      double lowerk = SafeMinus(Keltma, SafeMultiply(rangema, multy));
      double open_pos = open[pos] * 1;
      double close_pos = close[pos] * 1;
      double difference = MathAbs(close_pos - open_pos);
      int atr_violation = SafeGreater(difference, atr_slen);
      int InRange = SafeGreater(upper_band, BBMC) && SafeLess(lower_band, BBMC);
      int candlesize_violation = atr_violation && InRange;
      int plotshape1_condition = candlesize_violation;
      if (plotshape1_condition == true) { plot1[pos] = high[pos]; }
      SetStream(Hlv, pos, (int)(NULL), Hlv_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(Hlv, pos, (SafeGreater(close[pos], emaHigh) ? 1 : (SafeLess(close[pos], emaLow) ? (-1) : Hlv[pos - 1])), Hlv_DEFAULT_VALUE);
      double sslDown = (SafeLess(Hlv[pos], 0) ? emaHigh : emaLow);
      SetStream(Hlv2, pos, (int)(NULL), Hlv2_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(Hlv2, pos, (SafeGreater(close[pos], maHigh) ? 1 : (SafeLess(close[pos], maLow) ? (-1) : Hlv2[pos - 1])), Hlv2_DEFAULT_VALUE);
      double sslDown2 = (SafeLess(Hlv2[pos], 0) ? maHigh : maLow);
      SetStream(Hlv3, pos, (int)(NULL), Hlv3_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(Hlv3, pos, (SafeGreater(close[pos], ExitHigh) ? 1 : (SafeLess(close[pos], ExitLow) ? (-1) : Hlv3[pos - 1])), Hlv3_DEFAULT_VALUE);
      double sslExit = (SafeLess(Hlv3[pos], 0) ? ExitHigh : ExitLow);
      crossover1X.SetValue(pos, close[pos]);
      crossover1Y.SetValue(pos, sslExit);
      int crossover1Value[1];
      if (!crossover1.GetValues(pos, 1, crossover1Value)) { crossover1Value[0] = (-1); }
      int base_cross_Long = crossover1Value[0];
      crossover2X.SetValue(pos, sslExit);
      crossover2Y.SetValue(pos, close[pos]);
      int crossover2Value[1];
      if (!crossover2.GetValues(pos, 1, crossover2Value)) { crossover2Value[0] = (-1); }
      int base_cross_Short = crossover2Value[0];
      int codiff = (base_cross_Long ? 1 : (base_cross_Short ? (-1) : EMPTY_VALUE));
      uint color_bar = (SafeGreater(close[pos], upperk) ? 0xffc300 : (SafeLess(close[pos], lowerk) ? 0x6200ff : Gray));
      uint color_ssl1 = (SafeGreater(close[pos], sslDown) ? 0xffc300 : (SafeLess(close[pos], sslDown) ? 0x6200ff : EMPTY_VALUE));
      Setplot2(pos, NumberToBool(codiff), codiff, 0xffc300, 0x6200ff);
plot4.Set(pos, (show_Baseline ? BBMC : EMPTY_VALUE), color_bar);
      double p1 = plot5.Set(pos, (show_Baseline ? BBMC : EMPTY_VALUE), color_bar);
;
plot6.Set(pos, (show_SSL1 ? sslDown : EMPTY_VALUE), color_ssl1);
      double DownPlot = plot7.Set(pos, (show_SSL1 ? sslDown : EMPTY_VALUE), color_ssl1);
;
      barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], (show_color_bar ? color_bar : EMPTY_VALUE));
plot9.Set(pos, (show_Baseline ? upperk : EMPTY_VALUE), color_bar);
      double up_channel = plot10.Set(pos, (show_Baseline ? upperk : EMPTY_VALUE), color_bar);
;
plot11.Set(pos, (show_Baseline ? lowerk : EMPTY_VALUE), color_bar);
      double low_channel = plot12.Set(pos, (show_Baseline ? lowerk : EMPTY_VALUE), color_bar);
;
      fill13.Set(pos, up_channel, low_channel, color_bar);
      double upper_half = SafePlus(SafeMultiply(atr_slen, atr_crit), close[pos]);
      double lower_half = SafeMinus(close[pos], SafeMultiply(atr_slen, atr_crit));
      int buy_inatr = SafeLess(lower_half, sslDown2);
      int sell_inatr = SafeGreater(upper_half, sslDown2);
      int sell_cont = SafeLess(close[pos], BBMC) && SafeLess(close[pos], sslDown2);
      int buy_cont = SafeGreater(close[pos], BBMC) && SafeGreater(close[pos], sslDown2);
      int sell_atr = sell_inatr && sell_cont;
      int buy_atr = buy_inatr && buy_cont;
      uint atr_fill = (buy_atr ? Green : (sell_atr ? Purple : White));
Setplot14(pos, sslDown2, atr_fill);
      double LongPlot = Setplot17(pos, sslDown2, atr_fill);
;
      plot20[pos] = (show_atr ? upper_band : EMPTY_VALUE);
      double u = plot20[pos];
      plot21[pos] = (show_atr ? lower_band : EMPTY_VALUE);
      double l = plot21[pos];
      crossover3X.SetValue(pos, close[pos]);
      crossover3Y.SetValue(pos, sslDown);
      int crossover3Value[1];
      if (!crossover3.GetValues(pos, 1, crossover3Value)) { crossover3Value[0] = (-1); }
      if (crossover3Value[0]) { _signaler.SendNotifications("SSL Cross Alert", "SSL1 has crossed."); }
      crossover4X.SetValue(pos, close[pos]);
      crossover4Y.SetValue(pos, sslDown2);
      int crossover4Value[1];
      if (!crossover4.GetValues(pos, 1, crossover4Value)) { crossover4Value[0] = (-1); }
      if (crossover4Value[0]) { _signaler.SendNotifications("SSL2 Cross Alert", "SSL2 has crossed."); }
      if (sell_atr) { _signaler.SendNotifications("Sell Continuation", "Sell Continuation."); }
      if (buy_atr) { _signaler.SendNotifications("Buy Continuation", "Buy Continuation."); }
      crossover5X.SetValue(pos, close[pos]);
      crossover5Y.SetValue(pos, sslExit);
      int crossover5Value[1];
      if (!crossover5.GetValues(pos, 1, crossover5Value)) { crossover5Value[0] = (-1); }
      if (crossover5Value[0]) { _signaler.SendNotifications("Exit Sell", "Exit Sell Alert."); }
      crossover6X.SetValue(pos, sslExit);
      crossover6Y.SetValue(pos, close[pos]);
      int crossover6Value[1];
      if (!crossover6.GetValues(pos, 1, crossover6Value)) { crossover6Value[0] = (-1); }
      if (crossover6Value[0]) { _signaler.SendNotifications("Exit Buy", "Exit Buy Alert."); }
      crossover7X.SetValue(pos, close[pos]);
      crossover7Y.SetValue(pos, upperk);
      int crossover7Value[1];
      if (!crossover7.GetValues(pos, 1, crossover7Value)) { crossover7Value[0] = (-1); }
      if (crossover7Value[0]) { _signaler.SendNotifications("Baseline Buy Entry", "Base Buy Alert."); }
      crossover8X.SetValue(pos, lowerk);
      crossover8Y.SetValue(pos, close[pos]);
      int crossover8Value[1];
      if (!crossover8.GetValues(pos, 1, crossover8Value)) { crossover8Value[0] = (-1); }
      if (crossover8Value[0]) { _signaler.SendNotifications("Baseline Sell Entry", "Base Sell Alert."); }
   }
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