//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75162
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
#property indicator_buffers 7
#property indicator_label1 "Combined RSI-Volume Oscillator"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "MA 1"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Orange
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_label3 "MA 2"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Purple
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "MA 3"
#property indicator_type4 DRAW_LINE
#property indicator_color4 Green
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Zero Line"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Gray
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Overbought"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Red
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Oversold"
#property indicator_type7 DRAW_LINE
#property indicator_color7 Green
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1

#ifndef FloatStream_IMPL
#define FloatStream_IMPL

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
// Change stream v1.1

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

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

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   ChangeStream(IIntStream* stream, int period = 1)
      :AOnStream(new IntToFloatStreamWrapper(stream))
   {
      _source.Release();
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


// RSI stream v1.1

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSISimpleStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSISimpleStream(IStream* stream, int period)
      :AOnStream(new ChangeStream(stream))
   {
      _source.Release();
      _period = period;
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_pos, 0) != totalBars) 
      {
         ArrayResize(_pos, totalBars);
         ArrayResize(_neg, totalBars);
      }
      double sump = 0;
      double sumn = 0;
      double positive;
      double negative;
      double diff;
      if (period == totalBars - 1 || _pos[period + 1])
      {
         for (int i = 0; i < _period; ++i)
         {
            if (!_source.GetValue(period + i, diff))
            {
               return false;
            }
            if (diff >= 0)
            {
               sump = sump + diff;
            }
            else
            {
               sumn = sumn - diff;
            }
         }
         positive = sump / _period;
         negative = sumn / _period;
      }
      else
      {
         if (!_source.GetValue(period, diff))
         {
            return false;
         }
         if (diff > 0)
         {
            sump = diff;
         }
         else
         {
            sumn = -diff;
         }
         positive = (_pos[period + 1] * (_period - 1) + sump) / _period;
         negative = (_neg[period + 1] * (_period - 1) + sumn) / _period;
      }
      _pos[period] = positive;
      _neg[period] = negative;
      val = negative == 0 ? 0 : 100 - (100 / (1 + positive / negative));
      return true;
   }
};

class PineScriptRSIUpDownStream : public AStreamBase
{
   IStream* _up;
   IStream* _down;
public:
   PineScriptRSIUpDownStream(IStream* up, IStream* down)
   {
      _up = up;
      _up.AddRef();
      _down = down;
      _down.AddRef();
   }
   ~PineScriptRSIUpDownStream()
   {
      _up.Release();
      _down.Release();
   }
   
   virtual int Size()
   {
      return _up.Size();
   }

   virtual bool GetValue(const int period, double &val)
   {
      double up;
      double down;
      if (!_up.GetValue(period, up) || !_down.GetValue(period, down))
      {
         return false;
      }
      if (down == 0)
      {
         val = 0;
         return true;
      }
      double rs = up / down;
      val = 100 - 100.0 / (1.0 + rs);
      return true;
   }
};

class RSIStream : public AStreamBase
{
   IStream* _impl;
public:
   RSIStream(IStream* stream, int period)
   {
      _impl = new RSISimpleStream(stream, period);
   }

   RSIStream(IStream* up, IStream* down)
   {
      _impl = new PineScriptRSIUpDownStream(up, down);
   }

   ~RSIStream()
   {
      _impl.Release();
   }
   
   virtual int Size()
   {
      return _impl.Size();
   }

   virtual bool GetValue(const int period, double &val)
   {
      return _impl.GetValue(period, val);
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
// HMA on stream v1.1

#ifndef HMAOnStream_IMP
#define HMAOnStream_IMP


// WMA on stream v1.1

#ifndef WMAOnStream_IMP
#define WMAOnStream_IMP

class WMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   WMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 1.0 / (_length);
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_buffer, 0) != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
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

      _buffer[bufferIndex] = (current - last) * _k + last;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif



class HMAOnStream : public AOnStream
{
   int _length;
   WMAOnStream* wmaHalf;
   WMAOnStream* wma;
   WMAOnStream* wmaOnDiff;
   FloatStream* diff;
public:
   HMAOnStream(IStream *source, const int length)
      : AOnStream(source)
   {
      _length = length;
      wmaHalf = new WMAOnStream(source, MathFloor(length / 2 + 0.5));
      wma = new WMAOnStream(source, length);
      diff = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wmaOnDiff = new WMAOnStream(diff, MathFloor(MathSqrt(length) + 0.5));
   }

   ~HMAOnStream()
   {
      wmaHalf.Release();
      wma.Release();
      diff.Release();
      wmaOnDiff.Release();
   }

   bool GetValue(const int period, double &val)
   {
      double n2ma;
      if (!wmaHalf.GetValue(period, n2ma))
      {
         return false;
      }
      n2ma *= 2;
      double nma;
      if (!wma.GetValue(period, nma))
      {
         return false;
      }
      diff.SetValue(period, n2ma - nma);

      return wmaOnDiff.GetValue(period, val);
   }
};
#endif


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
input int param1 = 14; // RSI Length
input int param2 = 10; // Volume Oscillator Length
input string param3 = "SMA"; // Moving Average Type
input int param4 = 10; // SMA 1 Length
input int param5 = 20; // SMA 2 Length
input int param6 = 50; // SMA 3 Length
input int bars_limit = 100000; // Bars limit
int length;
int volumeLength;
string maType;
FloatStream* rsi1X;
RSIStream* rsi1;
FloatStream* hma1Source;
HMAOnStream* hma1;
FloatStream* hma2Source;
HMAOnStream* hma2;
class getMovingAverage_fS_i_sStream
{
   IStream* source;
   int length;
   string type;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* hma3Source;
   HMAOnStream* hma3;
   bool _initialized;
public:
   getMovingAverage_fS_i_sStream(IStream* source, int length, string type)
   {
      _initialized = false;
      this.source = source;
      source.AddRef();
      this.length = length;
      this.type = type;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, length);
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, length);
      hma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      hma3 = new HMAOnStream(hma3Source, length);
   }
   ~getMovingAverage_fS_i_sStream()
   {
      source.Release();
      sma1Source.Release();
      sma1.Release();
      ema1Source.Release();
      ema1.Release();
      hma3Source.Release();
      hma3.Release();
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
      if (!_initialized)
      {
         sma1Source.Init();
         ema1Source.Init();
         hma3Source.Init();
         _initialized = true;
      }
      if ((type == "SMA"))
      {
         double sourceValue;
         if (!source.GetValue(pos, sourceValue)) { sourceValue = EMPTY_VALUE; }
         sma1Source.SetValue(pos, sourceValue);
         double sma1Value;
         if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
         __out1 = sma1Value;
      }
      else if ((type == "EMA"))
      {
         double sourceValue;
         if (!source.GetValue(pos, sourceValue)) { sourceValue = EMPTY_VALUE; }
         ema1Source.SetValue(pos, sourceValue);
         double ema1Value;
         if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
         __out1 = ema1Value;
      }
      else if ((type == "HMA"))
      {
         double sourceValue;
         if (!source.GetValue(pos, sourceValue)) { sourceValue = EMPTY_VALUE; }
         hma3Source.SetValue(pos, sourceValue);
         double hma3Value;
         if (!hma3.GetValue(pos, hma3Value)) { hma3Value = EMPTY_VALUE; }
         __out1 = hma3Value;
      }
      else
      {
         __out1 = EMPTY_VALUE;
      }
      return true;
   }
};
FloatStream* getMovingAverage_fS_i_s1_param1;
getMovingAverage_fS_i_sStream* getMovingAverage_fS_i_s1;
FloatStream* getMovingAverage_fS_i_s2_param1;
getMovingAverage_fS_i_sStream* getMovingAverage_fS_i_s2;
FloatStream* getMovingAverage_fS_i_s3_param1;
getMovingAverage_fS_i_sStream* getMovingAverage_fS_i_s3;
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
   IndicatorBuffers(7);
   int id = 0;
   length = param1;
   volumeLength = param2;
   maType = param3;
   rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, length);
   hma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   hma1 = new HMAOnStream(hma1Source, volumeLength);
   hma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   hma2 = new HMAOnStream(hma2Source, volumeLength);
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("RSI-Volume Oscillator Quick Scalping");
   getMovingAverage_fS_i_s1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getMovingAverage_fS_i_s1 = new getMovingAverage_fS_i_sStream(getMovingAverage_fS_i_s1_param1, param4, maType);
   id = getMovingAverage_fS_i_s1.Init(id);
   getMovingAverage_fS_i_s2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getMovingAverage_fS_i_s2 = new getMovingAverage_fS_i_sStream(getMovingAverage_fS_i_s2_param1, param5, maType);
   id = getMovingAverage_fS_i_s2.Init(id);
   getMovingAverage_fS_i_s3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getMovingAverage_fS_i_s3 = new getMovingAverage_fS_i_sStream(getMovingAverage_fS_i_s3_param1, param6, maType);
   id = getMovingAverage_fS_i_s3.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   rsi1X.Release();
   rsi1.Release();
   hma1Source.Release();
   hma1.Release();
   hma2Source.Release();
   hma2.Release();
   getMovingAverage_fS_i_s1_param1.Release();
   delete getMovingAverage_fS_i_s1;
   getMovingAverage_fS_i_s2_param1.Release();
   delete getMovingAverage_fS_i_s2;
   getMovingAverage_fS_i_s3_param1.Release();
   delete getMovingAverage_fS_i_s3;
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
      rsi1X.Init();
      hma1Source.Init();
      hma2Source.Init();
      getMovingAverage_fS_i_s1_param1.Init();
      getMovingAverage_fS_i_s1.Clear();
      getMovingAverage_fS_i_s2_param1.Init();
      getMovingAverage_fS_i_s2.Clear();
      getMovingAverage_fS_i_s3_param1.Init();
      getMovingAverage_fS_i_s3.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, 0);
      ArrayInitialize(plot6, 70);
      ArrayInitialize(plot7, 30);
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
      rsi1X.SetValue(pos, close[pos]);
      double rsi1Value;
      if (!rsi1.GetValue(pos, rsi1Value)) { rsi1Value = EMPTY_VALUE; }
      double rsiValue = rsi1Value;
      hma1Source.SetValue(pos, tick_volume[pos]);
      double hma1Value;
      if (!hma1.GetValue(pos, hma1Value)) { hma1Value = EMPTY_VALUE; }
      hma2Source.SetValue(pos, tick_volume[pos]);
      double hma2Value;
      if (!hma2.GetValue(pos, hma2Value)) { hma2Value = EMPTY_VALUE; }
      double volumeOscillator = SafeDivide((SafeMinus(tick_volume[pos], hma1Value)), hma2Value);
      double combinedOscillator = SafeMinus(rsiValue, volumeOscillator);
      getMovingAverage_fS_i_s1_param1.SetValue(pos, combinedOscillator);
      double getMovingAverage_fS_i_s1Value;
      if (!getMovingAverage_fS_i_s1.GetValue(pos, getMovingAverage_fS_i_s1Value)) { getMovingAverage_fS_i_s1Value = EMPTY_VALUE; }
      double sma1 = getMovingAverage_fS_i_s1Value;
      getMovingAverage_fS_i_s2_param1.SetValue(pos, combinedOscillator);
      double getMovingAverage_fS_i_s2Value;
      if (!getMovingAverage_fS_i_s2.GetValue(pos, getMovingAverage_fS_i_s2Value)) { getMovingAverage_fS_i_s2Value = EMPTY_VALUE; }
      double sma2 = getMovingAverage_fS_i_s2Value;
      getMovingAverage_fS_i_s3_param1.SetValue(pos, combinedOscillator);
      double getMovingAverage_fS_i_s3Value;
      if (!getMovingAverage_fS_i_s3.GetValue(pos, getMovingAverage_fS_i_s3Value)) { getMovingAverage_fS_i_s3Value = EMPTY_VALUE; }
      double sma3 = getMovingAverage_fS_i_s3Value;
      plot1[pos] = combinedOscillator;
      plot2[pos] = sma1;
      plot3[pos] = sma2;
      plot4[pos] = sma3;
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