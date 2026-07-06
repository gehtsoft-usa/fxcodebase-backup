//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76386
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
#property indicator_buffers 14
#property indicator_plots 4
#property indicator_label1 "MHULL"
#property indicator_type1 DRAW_COLOR_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "SHULL"
#property indicator_type2 DRAW_COLOR_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_FILLING
#property indicator_width3 1
#property indicator_type4 DRAW_COLOR_CANDLES

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

// price stream factory v2.0

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
// IBarStream v2.0



#ifndef IBarStream_IMP
#define IBarStream_IMP

interface IBarStream : public TIStream<double>
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


// Price stream v3.1

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
      int pos = Size() - 1 - period;
      return GetValues(pos, count, values);
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
// Bar stream v2.1



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
      if (size <= oldPos || oldPos < 0)
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
      if (size <= oldPos || oldPos < 0)
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
      if (size <= oldPos || oldPos < 0)
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
      if (size <= oldPos || oldPos < 0)
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
      if (size <= oldPos || oldPos < 0)
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
      if (size <= oldPos || oldPos < 0)
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
      if (size <= oldPos || oldPos < 0)
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
      if (size <= oldPos || oldPos < 0)
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
      if (size <= oldPos + count - 1 || oldPos < 0)
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
      if (size <= oldPos + count - 1 || oldPos < 0)
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
   static TIStream<double>* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      TIStream<double>* stream = new PriceStream(source, price);
      source.Release();
      return stream;
   }
};
#endif
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v2.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL


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
// WMA on stream v2.0



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
   WMAOnStream(TIStream<double> *source, const int length)
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


// EMA on stream v2.0

class EMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   EMAOnStream(TIStream<double> *source, const int length)
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
// Colored fill v2.1



#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredTopBottomFill
{
   double p1[];
   double p2[];
   int colorsCount;
   uint topColor;
   uint bottomColor;
   int streamIndex;
   double top;
   double bottom;
public:
   ColoredTopBottomFill(int streamIndex, double top, double bottom, uint topColor, uint bottomColor)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      this.top = top;
      this.bottom = bottom;
      this.topColor = topColor;
      this.bottomColor = bottomColor;
   }
   ~ColoredTopBottomFill()
   {
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }

   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, GetColorOnly(topColor));
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, GetColorOnly(topColor));
      return id + 2;
   }
   
   void Set(int period, double value1, double value2)
   {
      if (value1 == EMPTY_VALUE || value2 == EMPTY_VALUE)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      double sum = value1 + value2;
      double avgValue = sum == 0 ? 0 : sum / 2;
      if (avgValue > top || avgValue < bottom)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
};
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   uint upColor;
   uint dnColor;
   uint topColor;
   uint bottomColor;
   int streamIndex;
   TIStream<double>* top;
   TIStream<double>* bottom;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      top = NULL;
      bottom = NULL;
   }
   ~ColoredFill()
   {
      if (top != NULL)
      {
         top.Release();
      }
      if (bottom != NULL)
      {
         bottom.Release();
      }
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void SetTopBottom(TIStream<double>* top, TIStream<double>* bottom, int topColor, int bottomColor)
   {
      this.top = top;
      top.AddRef();
      this.bottom = bottom;
      bottom.AddRef();
      this.topColor = topColor;
      this.bottomColor = bottomColor;
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
   
   void Set(int period, double value1, double value2, uint clr = INT_MAX)
   {
      int transp = GetTranparency(clr);
      if (clr == INT_MAX || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE || transp == 100)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      value1 = LimitValue(period, value1);
      value2 = LimitValue(period, value2);
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
   double LimitValue(int pos, double value)
   {
      if (top == NULL || bottom == NULL)
      {
         return value;
      }
      double topValue[1];
      if (!top.GetValues(pos, 1, topValue))
      {
         return value;
      }
      double bottomValue[1];
      if (!bottom.GetValues(pos, 1, bottomValue))
      {
         return value;
      }
      if (value > topValue[0])
      {
         return topValue[0];
      }
      if (value < bottomValue[0])
      {
         return bottomValue[0];
      }
      return value;
   }   
};
#endif
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
input PriceType param1 = PriceClose; // Source
enum param2_enum
{
   param2_value_1, // Hma
   param2_value_2, // Thma
   param2_value_3 // Ehma
};
input param2_enum param2_e = param2_value_1; // Hull Variation
string Get_param2()
{
   switch (param2_e)
   {
      case param2_value_1: return "Hma";
      case param2_value_2: return "Thma";
      case param2_value_3: return "Ehma";
   }
   return NULL;
}
input int param3 = 55; // Length(180-200 for floating S/R , 55 for swing entry)
input bool param4 = true; // Color Hull according to trend?
input bool param5 = false; // Color candles based on Hull's Trend?
input bool param6 = true; // Show as a Band?
input int param7 = 1; // Line Thickness
input int param8 = 40; // Band Transparency
input int bars_limit = 1000; // Bars limit
TIStream<double>* param1Stream;
TIStream<double>* src;
string modeSwitch;
int length;
int switchColor;
int candleCol;
int visualSwitch;
int thicknesSwitch;
int transpSwitch;
class HMA_1Stream
{
   int _length;
   FloatStream* wma1Source;
   WMAOnStream* wma1;
   FloatStream* wma2Source;
   WMAOnStream* wma2;
   FloatStream* wma3Source;
   WMAOnStream* wma3;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   HMA_1Stream(int _length, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._length = _length;
      wma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma2 = new WMAOnStream(wma2Source, SafeDivide(_length, 2));
      wma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma3 = new WMAOnStream(wma3Source, _length);
      wma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma1 = new WMAOnStream(wma1Source, SafeMathRound(MathSqrt(_length)));
   }
   ~HMA_1Stream()
   {
      wma1Source.Release();
      wma1.Release();
      wma2Source.Release();
      wma2.Release();
      wma3Source.Release();
      wma3.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double ___src, double &__out1)
   {
      if (!_initialized)
      {
         wma2Source.Init();
         wma3Source.Init();
         wma1Source.Init();
         _initialized = true;
      }
      double _src = ___src;
      wma2Source.SetValue(pos, _src);
      double wma2Value[1];
      if (!wma2.GetValues(pos, 1, wma2Value)) { wma2Value[0] = EMPTY_VALUE; }
      wma3Source.SetValue(pos, _src);
      double wma3Value[1];
      if (!wma3.GetValues(pos, 1, wma3Value)) { wma3Value[0] = EMPTY_VALUE; }
      wma1Source.SetValue(pos, SafeMinus(SafeMultiply(2, wma2Value[0]), wma3Value[0]));
      double wma1Value[1];
      if (!wma1.GetValues(pos, 1, wma1Value)) { wma1Value[0] = EMPTY_VALUE; }
      __out1 = wma1Value[0];
      return true;
   }
};
class EHMA_1Stream
{
   int _length;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* ema2Source;
   EMAOnStream* ema2;
   FloatStream* ema3Source;
   EMAOnStream* ema3;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   EHMA_1Stream(int _length, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._length = _length;
      ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema2 = new EMAOnStream(ema2Source, SafeDivide(_length, 2));
      ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema3 = new EMAOnStream(ema3Source, _length);
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, SafeMathRound(MathSqrt(_length)));
   }
   ~EHMA_1Stream()
   {
      ema1Source.Release();
      ema1.Release();
      ema2Source.Release();
      ema2.Release();
      ema3Source.Release();
      ema3.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double ___src, double &__out1)
   {
      if (!_initialized)
      {
         ema2Source.Init();
         ema3Source.Init();
         ema1Source.Init();
         _initialized = true;
      }
      double _src = ___src;
      ema2Source.SetValue(pos, _src);
      double ema2Value[1];
      if (!ema2.GetValues(pos, 1, ema2Value)) { ema2Value[0] = EMPTY_VALUE; }
      ema3Source.SetValue(pos, _src);
      double ema3Value[1];
      if (!ema3.GetValues(pos, 1, ema3Value)) { ema3Value[0] = EMPTY_VALUE; }
      ema1Source.SetValue(pos, SafeMinus(SafeMultiply(2, ema2Value[0]), ema3Value[0]));
      double ema1Value[1];
      if (!ema1.GetValues(pos, 1, ema1Value)) { ema1Value[0] = EMPTY_VALUE; }
      __out1 = ema1Value[0];
      return true;
   }
};
class THMA_1Stream
{
   int _length;
   FloatStream* wma4Source;
   WMAOnStream* wma4;
   FloatStream* wma5Source;
   WMAOnStream* wma5;
   FloatStream* wma6Source;
   WMAOnStream* wma6;
   FloatStream* wma7Source;
   WMAOnStream* wma7;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   THMA_1Stream(int _length, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._length = _length;
      wma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma5 = new WMAOnStream(wma5Source, SafeDivide(_length, 3));
      wma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma6 = new WMAOnStream(wma6Source, SafeDivide(_length, 2));
      wma7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma7 = new WMAOnStream(wma7Source, _length);
      wma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma4 = new WMAOnStream(wma4Source, _length);
   }
   ~THMA_1Stream()
   {
      wma4Source.Release();
      wma4.Release();
      wma5Source.Release();
      wma5.Release();
      wma6Source.Release();
      wma6.Release();
      wma7Source.Release();
      wma7.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double ___src, double &__out1)
   {
      if (!_initialized)
      {
         wma5Source.Init();
         wma6Source.Init();
         wma7Source.Init();
         wma4Source.Init();
         _initialized = true;
      }
      double _src = ___src;
      wma5Source.SetValue(pos, _src);
      double wma5Value[1];
      if (!wma5.GetValues(pos, 1, wma5Value)) { wma5Value[0] = EMPTY_VALUE; }
      wma6Source.SetValue(pos, _src);
      double wma6Value[1];
      if (!wma6.GetValues(pos, 1, wma6Value)) { wma6Value[0] = EMPTY_VALUE; }
      wma7Source.SetValue(pos, _src);
      double wma7Value[1];
      if (!wma7.GetValues(pos, 1, wma7Value)) { wma7Value[0] = EMPTY_VALUE; }
      wma4Source.SetValue(pos, SafeMinus(SafeMinus(SafeMultiply(wma5Value[0], 3), wma6Value[0]), wma7Value[0]));
      double wma4Value[1];
      if (!wma4.GetValues(pos, 1, wma4Value)) { wma4Value[0] = EMPTY_VALUE; }
      __out1 = wma4Value[0];
      return true;
   }
};
class Mode_1Stream
{
   string modeSwitch;
   int len;
   HMA_1Stream* HMA_11;
   EHMA_1Stream* EHMA_12;
   THMA_1Stream* THMA_13;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   Mode_1Stream(string modeSwitch, int len, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.modeSwitch = modeSwitch;
      this.len = len;
   }
   ~Mode_1Stream()
   {
      delete HMA_11;
      delete EHMA_12;
      delete THMA_13;
   }
   int Init(int id)
   {
      HMA_11 = new HMA_1Stream(len, IndicatorObjPrefix + "_1");
      id = HMA_11.Init(id);
      EHMA_12 = new EHMA_1Stream(len, IndicatorObjPrefix + "_2");
      id = EHMA_12.Init(id);
      THMA_13 = new THMA_1Stream(SafeDivide(len, 2), IndicatorObjPrefix + "_3");
      id = THMA_13.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double __src, double &__out1)
   {
      if (!_initialized)
      {
         HMA_11.Clear();
         EHMA_12.Clear();
         THMA_13.Clear();
         _initialized = true;
      }
      double src = __src;
      double HMA_11Value;
      if (!HMA_11.GetValue(pos, oldPos, src, HMA_11Value)) { HMA_11Value = EMPTY_VALUE; }
      double EHMA_12Value;
      if (!EHMA_12.GetValue(pos, oldPos, src, EHMA_12Value)) { EHMA_12Value = EMPTY_VALUE; }
      double THMA_13Value;
      if (!THMA_13.GetValue(pos, oldPos, src, THMA_13Value)) { THMA_13Value = EMPTY_VALUE; }
      __out1 = ((modeSwitch == "Hma") ? HMA_11Value : ((modeSwitch == "Ehma") ? EHMA_12Value : ((modeSwitch == "Thma") ? THMA_13Value : EMPTY_VALUE)));
      return true;
   }
};
Mode_1Stream* Mode_14;
double HULL[];
double HULL_DEFAULT_VALUE;
ColoredPlot* plot1;
ColoredPlot* plot2;
ColoredFill* fill3;
CandleStreams* barcolor1;

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
   param1Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param1);
   src = param1Stream;
   modeSwitch = Get_param2();
   length = param3;
   switchColor = param4;
   candleCol = param5;
   visualSwitch = param6;
   thicknesSwitch = param7;
   transpSwitch = param8;
   int id = 0;
   plot1 = new ColoredPlot(0);
   plot1.AddColor(0x00ff00);
   plot1.AddColor(0x0000ff);
   plot1.AddColor(0x0098ff);
   plot1.SetOffset(0);
   id = plot1.RegisterStreams(id);
   plot2 = new ColoredPlot(1);
   plot2.AddColor(0x00ff00);
   plot2.AddColor(0x0000ff);
   plot2.AddColor(0x0098ff);
   plot2.SetOffset(0);
   id = plot2.RegisterStreams(id);
   fill3 = new ColoredFill(2);
   fill3.AddColor(0x00ff00);
   fill3.AddColor(0x0000ff);
   fill3.AddColor(0x0098ff);
   id = fill3.RegisterStreams(id);
   barcolor1 = new CandleStreams(3);
   barcolor1.AddColor(0x00ff00);
   barcolor1.AddColor(0x0000ff);
   barcolor1.AddColor(0x0098ff);
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "Belkhayate Iceberg 2.0");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   Mode_14 = new Mode_1Stream(modeSwitch, length, IndicatorObjPrefix + "_4");
   id = Mode_14.Init(id);
   SetIndexBuffer(id++, HULL, INDICATOR_CALCULATIONS);
   id = plot1.RegisterInternalStreams(id);
   id = plot2.RegisterInternalStreams(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   param1Stream.Release();
   delete Mode_14;
   delete plot1;
   delete plot2;
   delete fill3;
   delete barcolor1;
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
      Mode_14.Clear();
      HULL_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(HULL, HULL_DEFAULT_VALUE);
      plot1.Init();
      plot2.Init();
      fill3.Init();
      barcolor1.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      double Mode_14Value;
      if (!Mode_14.GetValue(pos, oldPos, srcValue[0], Mode_14Value)) { Mode_14Value = EMPTY_VALUE; }
      SetStream(HULL, pos, Mode_14Value, HULL_DEFAULT_VALUE);
      if (pos - 0 < 0) { continue; }
      double MHULL = HULL[pos - 0];
      if (pos - 2 < 0) { continue; }
      double SHULL = HULL[pos - 2];
      if (pos - 2 < 0) { continue; }
      uint hullColor = (switchColor ? ((SafeGreater(HULL[pos], HULL[pos - 2]) ? 0x00ff00 : 0x0000ff)) : 0x0098ff);
      double plot1Value = plot1.Set(pos, MHULL, hullColor);
      double Fi1 = plot1Value;
      double plot2Value = plot2.Set(pos, (visualSwitch ? SHULL : EMPTY_VALUE), hullColor);
      double Fi2 = plot2Value;
      double fill3_val1 = Fi1;
      double fill3_val2 = Fi2;
      fill3.Set(pos, fill3_val1, fill3_val2, hullColor);
      barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], (candleCol ? ((switchColor ? hullColor : INT_MAX)) : INT_MAX));
   }
   return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76386
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