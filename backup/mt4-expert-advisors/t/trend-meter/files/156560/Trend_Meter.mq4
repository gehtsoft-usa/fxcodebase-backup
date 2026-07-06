//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75175

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
#property indicator_buffers 31
#property indicator_label1 "Wave Trend - Positive Pressure"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Wave Trend - Negative Pressure"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "All 3 Trend Meters Now Align"
#property indicator_type3 DRAW_ARROW
#property indicator_color3 0x758a28
#property indicator_style3 STYLE_SOLID
#property indicator_width3 3
#property indicator_label4 "All 3 Trend Meters Now Align"
#property indicator_type4 DRAW_ARROW
#property indicator_color4 Red
#property indicator_style4 STYLE_SOLID
#property indicator_width4 3
#property indicator_label5 "All 3 Trend Meters Now Align"
#property indicator_type5 DRAW_ARROW
#property indicator_style5 STYLE_SOLID
#property indicator_width5 3
#property indicator_label6 "Wave Trend X & All 3 Trend Meters Now Align"
#property indicator_type6 DRAW_ARROW
#property indicator_color6 0x758a28
#property indicator_style6 STYLE_SOLID
#property indicator_width6 4
#property indicator_label7 "Wave Trend X & All 3 Trend Meters Now Align"
#property indicator_type7 DRAW_ARROW
#property indicator_color7 Red
#property indicator_style7 STYLE_SOLID
#property indicator_width7 4
#property indicator_label8 "Wave Trend X & All 3 Trend Meters Now Align"
#property indicator_type8 DRAW_ARROW
#property indicator_style8 STYLE_SOLID
#property indicator_width8 4
#property indicator_label9 "Trend Meter 1"
#property indicator_type9 DRAW_ARROW
#property indicator_style9 STYLE_SOLID
#property indicator_width9 2
#property indicator_label10 "Trend Meter 1"
#property indicator_type10 DRAW_ARROW
#property indicator_color10 0x758a28
#property indicator_style10 STYLE_SOLID
#property indicator_width10 2
#property indicator_label11 "Trend Meter 1"
#property indicator_type11 DRAW_ARROW
#property indicator_color11 Red
#property indicator_style11 STYLE_SOLID
#property indicator_width11 2
#property indicator_label12 "Trend Meter 2"
#property indicator_type12 DRAW_ARROW
#property indicator_style12 STYLE_SOLID
#property indicator_width12 2
#property indicator_label13 "Trend Meter 2"
#property indicator_type13 DRAW_ARROW
#property indicator_color13 0x758a28
#property indicator_style13 STYLE_SOLID
#property indicator_width13 2
#property indicator_label14 "Trend Meter 2"
#property indicator_type14 DRAW_ARROW
#property indicator_color14 Red
#property indicator_style14 STYLE_SOLID
#property indicator_width14 2
#property indicator_label15 "Trend Meter 3"
#property indicator_type15 DRAW_ARROW
#property indicator_style15 STYLE_SOLID
#property indicator_width15 2
#property indicator_label16 "Trend Meter 3"
#property indicator_type16 DRAW_ARROW
#property indicator_color16 0x758a28
#property indicator_style16 STYLE_SOLID
#property indicator_width16 2
#property indicator_label17 "Trend Meter 3"
#property indicator_type17 DRAW_ARROW
#property indicator_color17 Red
#property indicator_style17 STYLE_SOLID
#property indicator_width17 2
#property indicator_label18 "Trend Bar 1 - Thin Line"
#property indicator_type18 DRAW_LINE
#property indicator_style18 STYLE_SOLID
#property indicator_width18 4
#property indicator_label19 "Trend Bar 1 - Thin Line"
#property indicator_type19 DRAW_LINE
#property indicator_style19 STYLE_SOLID
#property indicator_width19 4
#property indicator_label20 "Trend Bar 1 - Thin Line"
#property indicator_type20 DRAW_LINE
#property indicator_style20 STYLE_SOLID
#property indicator_width20 4
#property indicator_label21 "Trend Bar 1 - Thick Line"
#property indicator_type21 DRAW_LINE
#property indicator_style21 STYLE_SOLID
#property indicator_width21 9
#property indicator_label22 "Trend Bar 1 - Thick Line"
#property indicator_type22 DRAW_LINE
#property indicator_style22 STYLE_SOLID
#property indicator_width22 9
#property indicator_label23 "Trend Bar 1 - Thick Line"
#property indicator_type23 DRAW_LINE
#property indicator_style23 STYLE_SOLID
#property indicator_width23 9
#property indicator_label24 "Trend Bar 2 - Thin Line"
#property indicator_type24 DRAW_LINE
#property indicator_style24 STYLE_SOLID
#property indicator_width24 6
#property indicator_label25 "Trend Bar 2 - Thin Line"
#property indicator_type25 DRAW_LINE
#property indicator_style25 STYLE_SOLID
#property indicator_width25 6
#property indicator_label26 "Trend Bar 2 - Thin Line"
#property indicator_type26 DRAW_LINE
#property indicator_style26 STYLE_SOLID
#property indicator_width26 6
#property indicator_label27 "Trend Bar 2 - Thick Line"
#property indicator_type27 DRAW_LINE
#property indicator_style27 STYLE_SOLID
#property indicator_width27 9
#property indicator_label28 "Trend Bar 2 - Thick Line"
#property indicator_type28 DRAW_LINE
#property indicator_style28 STYLE_SOLID
#property indicator_width28 9
#property indicator_label29 "Trend Bar 2 - Thick Line"
#property indicator_type29 DRAW_LINE
#property indicator_style29 STYLE_SOLID
#property indicator_width29 9
#property indicator_type30 DRAW_LINE
#property indicator_style30 STYLE_SOLID
#property indicator_width30 1
#property indicator_type31 DRAW_LINE
#property indicator_style31 STYLE_SOLID
#property indicator_width31 1

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

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

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
   
   bool GetValue(const int period, double &val)
   {
      double sum = 0;
      double ssum = 0;
      for (int i = 0; i < _period; i++)
      {
         double __data;
         if (!_source.GetValue(period + i, __data))
            return false;
         sum += __data;
         ssum += MathPow(__data, 2);
      }
      val = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
      return true;
   }
};

#ifndef CorrelationStream_IMP
#define CorrelationStream_IMP
// Correlation stream v1.0




class CorrelationStream : public AOnStream
{
   SmaOnStream *xx_ma;
   SmaOnStream *yy_ma;
   IStream *_source2;
   int _length;
public:
   CorrelationStream(IStream *source1, IStream *source2, int length)
      :AOnStream(source1)
   {
      xx_ma = new SmaOnStream(source1, length);
      yy_ma = new SmaOnStream(source2, length);
      _length = length;
      _source2 = source2;
      _source2.AddRef();
   }
   
   ~CorrelationStream()
   {
      _source2.Release();
      xx_ma.Release();
      yy_ma.Release();
   }

   bool GetValue(const int period, double &val)
   {
      double xx_ma_val;
      if (!xx_ma.GetValue(period, xx_ma_val))
      {
         return false;
      }
      double yy_ma_val;
      if (!yy_ma.GetValue(period, yy_ma_val))
      {
         return false;
      }
      double xx = 0;
      double yy = 0;
      double xy = 0;
      for (int i = 0; i < _length; ++i)
      {
         double value1;
         if (!_source.GetValue(period + i, value1))
         {
            continue;
         }
         double value2;
         if (!_source2.GetValue(period + i, value2))
         {
            continue;
         }
         xx += MathPow(value1 - xx_ma_val, 2);
         yy += MathPow(value2 - yy_ma_val, 2);
         xy += (value1 - xx_ma_val) * (value2 - yy_ma_val);
      }
      double xx_yy_sqrt = MathSqrt(xx * yy);
      if (xx_yy_sqrt == 0)
      {
         return 0;
      }
      val = xy / xx_yy_sqrt;

      return true;
   }
};

#endif
//Signaler v2.2
// More templates and snippets on https://github.com/sibvic/mq4-templates
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

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

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

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
   }
};




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

// Colored stream v4.1

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

class InternalStream
{
public:
   double _stream[];
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
   InternalStream* _internalStream;
public:
   LineColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, 
      int lineType, ENUM_LINE_STYLE lineStyle, int width, InternalStream* internalStream)
   {
      _internalStream = internalStream;
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
      if (value == EMPTY_VALUE)
      {
         _stream[period] = EMPTY_VALUE;
         return;
      }
      int size = iBars(_symbol, _timeframe);
      int nextNonEmpty = FindNextNonempty(period, size);
      int count = nextNonEmpty - period + 1;
      double startPoint = _internalStream._stream[nextNonEmpty];
      double diff = startPoint - value;
      for (int i = nextNonEmpty; i >= period; --i)
      {
         _stream[i] = value - double(period - i) / count * diff;
      }
   }

   void Clear(int period)
   {
      _stream[period] = EMPTY_VALUE;
   }
private:
   int FindNextNonempty(int period, int size)
   {
      for (int i = period + 1; i < size; ++i)
      {
         if (_internalStream._stream[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return period;
   }
};

class HistogramColoredStreamData : public IColoredStreamData
{
   LineColoredStreamData* _up;
   LineColoredStreamData* _down;
public:
   HistogramColoredStreamData(const string symbol, const ENUM_TIMEFRAMES timeframe, color clr, string label, int width, InternalStream* internalStream)
   {
      _up = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width, internalStream);
      _down = new LineColoredStreamData(symbol, timeframe, clr, label, DRAW_HISTOGRAM, STYLE_SOLID, width, internalStream);
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
   InternalStream* _internal;
public:
   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
      _internal = new InternalStream();
   }

   ~ColoredStream()
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         delete _streams[i];
      }
      delete _internal;
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         _streams[i].Init(defaultValue);
      }
      ArrayInitialize(_internal._stream, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _internal._stream);
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
   int RegisterStream(int id, color clr, int transparency)
   {
      return RegisterStream(id, clr, "", transparency == 100 ? DRAW_NONE : DRAW_LINE, STYLE_SOLID, 1);
   }
   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new LineColoredStreamData(_symbol, _timeframe, clr, label, lineType, lineStyle, width, _internal);
      return _streams[size].Register(id);
   }
   int RegisterHistogramStream(int id, color clr, string label = "", int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new HistogramColoredStreamData(_symbol, _timeframe, clr, label, width, _internal);
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
      _internal._stream[period] = value;
      return value;
   }
   
   void Set(double value, int period, int colorIndex)
   {
      _internal._stream[period] = value;
      double prevValue = period + 1 >= iBars(_symbol, _timeframe) ? EMPTY_VALUE : _internal._stream[period + 1];
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
      val = _internal._stream[period];
      return _internal._stream[period] != EMPTY_VALUE;
   }
};

#endif
input bool param1 = true; // Pos / Neg Pressure
input bool param2 = true; // Trend Meter Signal
input bool param3 = true; // Wave Trend Cross Aligns with Trend Meter Signal
input string param4 = "MACD Crossover - Fast - 8, 21, 5"; // Trend Meter 1
input string param5 = "RSI 13: > or < 50"; // Trend Meter 2
input string param6 = "RSI 5: > or < 50"; // Trend Meter 3
input bool param7 = true; // Trend Bar 1
input bool param8 = true; // Trend Bar 2
input string param9 = "MA Crossover"; // 
input string param10 = "MA Crossover"; // 
input int param11 = 5; // Fast MA
input string param12 = "EMA"; // 
input int param13 = 11; // Slow MA
input string param14 = "EMA"; // 
input int param15 = 13; // Fast MA
input string param16 = "EMA"; // 
input int param17 = 36; // Slow MA
input string param18 = "SMA"; // 
input int bars_limit = 100000; // Bars limit
bool PosNegPressure;
bool TMSetups;
bool TMSetupsANDWT;
string TrendBar1;
string TrendBar2;
string TrendBar3;
FloatStream* rsi1X;
RSIStream* rsi1;
FloatStream* ema1Source;
EMAOnStream* ema1;
FloatStream* ema2Source;
EMAOnStream* ema2;
FloatStream* ema3Source;
EMAOnStream* ema3;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* cross1X;
FloatStream* cross1Y;
IBoolStream* cross1;
bool ShowTrendBar1;
bool ShowTrendBar2;
string TrendBar4;
string TrendBar5;
int MA1_Length;
string MA1_Type;
int MA2_Length;
string MA2_Type;
int MA3_Length;
string MA3_Type;
int MA4_Length;
string MA4_Type;
FloatStream* sma2Source;
SmaOnStream* sma2;
FloatStream* ema4Source;
EMAOnStream* ema4;
FloatStream* sma3Source;
SmaOnStream* sma3;
FloatStream* ema5Source;
EMAOnStream* ema5;
FloatStream* sma4Source;
SmaOnStream* sma4;
FloatStream* ema6Source;
EMAOnStream* ema6;
FloatStream* sma5Source;
SmaOnStream* sma5;
FloatStream* ema7Source;
EMAOnStream* ema7;
double MA1[];
double MA2[];
double MA3[];
double MA4[];
double MA1Direction[];
double MA2Direction[];
double MA3Direction[];
double MA4Direction[];
FloatStream* ema8Source;
EMAOnStream* ema8;
FloatStream* ema9Source;
EMAOnStream* ema9;
FloatStream* ema10Source;
EMAOnStream* ema10;
FloatStream* ema11Source;
EMAOnStream* ema11;
FloatStream* ema12Source;
EMAOnStream* ema12;
FloatStream* ema13Source;
EMAOnStream* ema13;
FloatStream* ema14Source;
EMAOnStream* ema14;
FloatStream* ema15Source;
EMAOnStream* ema15;
FloatStream* ema16Source;
EMAOnStream* ema16;
double TopDogDad[];
double haopen[];
double haclose[];
double ccolor[];
FloatStream* rsi2X;
RSIStream* rsi2;
FloatStream* rsi3X;
RSIStream* rsi3;
FloatStream* sma6Source;
SmaOnStream* sma6;
FloatStream* sma7Source;
SmaOnStream* sma7;
FloatStream* stdev1Source;
StDevStream* stdev1;
FloatStream* stdev2Source;
StDevStream* stdev2;
FloatStream* correlation1Source1;
FloatStream* correlation1Source2;
CorrelationStream* correlation1;
double LinReg1[];
double TrendBars3Positive[];
double TrendBars3Negative[];
double YellowWave[];
FloatStream* rsi4X;
RSIStream* rsi4;
double RSI14OB[];
double RSI14OS[];
double plot1[];
double plot2[];
Signaler* _signaler;
ColoredStream* plot3;
ColoredStream* plot6;
ColoredStream* plot9;
ColoredStream* plot12;
ColoredStream* plot15;
ColoredStream* plot18;
ColoredStream* plot21;
ColoredStream* plot24;
ColoredStream* plot27;
double plot30[];
double plot31[];
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* ema17Source;
EMAOnStream* ema17;
FloatStream* ema18Source;
EMAOnStream* ema18;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
IBoolStream* crossunder1;
FloatStream* ema19Source;
EMAOnStream* ema19;
FloatStream* ema20Source;
EMAOnStream* ema20;
FloatStream* crossover2X;
FloatStream* crossover2Y;
IBoolStream* crossover2;
FloatStream* crossunder2X;
FloatStream* crossunder2Y;
IBoolStream* crossunder2;
FloatStream* crossover3X;
FloatStream* crossover3Y;
IBoolStream* crossover3;
FloatStream* crossunder3X;
FloatStream* crossunder3Y;
IBoolStream* crossunder3;

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
   IndicatorBuffers(58);
   int id = 0;
   PosNegPressure = param1;
   TMSetups = param2;
   TMSetupsANDWT = param3;
   TrendBar1 = param4;
   TrendBar2 = param5;
   TrendBar3 = param6;
   rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, 14);
   int n1 = 9;
   ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, n1);
   ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, n1);
   int n2 = 12;
   ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, n2);
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, 3);
   cross1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1 = CrossStreamFactory::CreateCross(cross1X, cross1Y);
   ShowTrendBar1 = param7;
   ShowTrendBar2 = param8;
   TrendBar4 = param9;
   TrendBar5 = param10;
   MA1_Length = param11;
   MA1_Type = param12;
   MA2_Length = param13;
   MA2_Type = param14;
   MA3_Length = param15;
   MA3_Type = param16;
   MA4_Length = param17;
   MA4_Type = param18;
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, MA1_Length);
   ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema4 = new EMAOnStream(ema4Source, MA1_Length);
   sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, MA2_Length);
   ema5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema5 = new EMAOnStream(ema5Source, MA2_Length);
   sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma4 = new SmaOnStream(sma4Source, MA3_Length);
   ema6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema6 = new EMAOnStream(ema6Source, MA3_Length);
   sma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma5 = new SmaOnStream(sma5Source, MA4_Length);
   ema7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema7 = new EMAOnStream(ema7Source, MA4_Length);
   int MACDfastMA = 12;
   ema8Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema8 = new EMAOnStream(ema8Source, MACDfastMA);
   int MACDslowMA = 26;
   ema9Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema9 = new EMAOnStream(ema9Source, MACDslowMA);
   int MACDsignalSmooth = 9;
   ema10Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema10 = new EMAOnStream(ema10Source, MACDsignalSmooth);
   int FastMACDfastMA = 8;
   ema11Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema11 = new EMAOnStream(ema11Source, FastMACDfastMA);
   int FastMACDslowMA = 21;
   ema12Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema12 = new EMAOnStream(ema12Source, FastMACDslowMA);
   int FastMACDsignalSmooth = 5;
   ema13Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema13 = new EMAOnStream(ema13Source, FastMACDsignalSmooth);
   int TopDog_Fast_MA = 5;
   ema14Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema14 = new EMAOnStream(ema14Source, TopDog_Fast_MA);
   int TopDog_Slow_MA = 20;
   ema15Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema15 = new EMAOnStream(ema15Source, TopDog_Slow_MA);
   int TopDog_Sig = 30;
   ema16Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema16 = new EMAOnStream(ema16Source, TopDog_Sig);
   rsi2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi2 = new RSIStream(rsi2X, 5);
   rsi3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi3 = new RSIStream(rsi3X, 13);
   int SignalLineLength1 = 21;
   sma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma6 = new SmaOnStream(sma6Source, SignalLineLength1);
   sma7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma7 = new SmaOnStream(sma7Source, SignalLineLength1);
   stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev1 = new StDevStream(stdev1Source, SignalLineLength1);
   stdev2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev2 = new StDevStream(stdev2Source, SignalLineLength1);
   correlation1Source1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   correlation1Source2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   correlation1 = new CorrelationStream(correlation1Source1, correlation1Source2, SignalLineLength1);
   rsi4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi4 = new RSIStream(rsi4X, 14);
   SetIndexBuffer(id, plot1);
   SetIndexArrow(id, 161);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, 0x758a28);
   SetIndexBuffer(id, plot2);
   SetIndexArrow(id, 161);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, 0x3C14DC);
   plot3 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot3.RegisterArrowStream(id, 0x758a28, 161);
   id = plot3.RegisterArrowStream(id, Red, 161);
   id = plot3.RegisterArrowStream(id, EMPTY_VALUE, 161);
   plot6 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot6.RegisterArrowStream(id, 0x758a28, 253);
   id = plot6.RegisterArrowStream(id, Red, 253);
   id = plot6.RegisterArrowStream(id, EMPTY_VALUE, 253);
   plot9 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot9.RegisterArrowStream(id, EMPTY_VALUE, 161);
   id = plot9.RegisterArrowStream(id, 0x758a28, 161);
   id = plot9.RegisterArrowStream(id, Red, 161);
   plot12 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot12.RegisterArrowStream(id, EMPTY_VALUE, 161);
   id = plot12.RegisterArrowStream(id, 0x758a28, 161);
   id = plot12.RegisterArrowStream(id, Red, 161);
   plot15 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot15.RegisterArrowStream(id, EMPTY_VALUE, 161);
   id = plot15.RegisterArrowStream(id, 0x758a28, 161);
   id = plot15.RegisterArrowStream(id, Red, 161);
   plot18 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot18.RegisterStream(id, EMPTY_VALUE);
   id = plot18.RegisterStream(id, Green);
   id = plot18.RegisterStream(id, Red);
   plot21 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot21.RegisterStream(id, EMPTY_VALUE);
   id = plot21.RegisterStream(id, Green);
   id = plot21.RegisterStream(id, Red);
   plot24 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot24.RegisterStream(id, EMPTY_VALUE);
   id = plot24.RegisterStream(id, Green);
   id = plot24.RegisterStream(id, Red);
   plot27 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot27.RegisterStream(id, EMPTY_VALUE);
   id = plot27.RegisterStream(id, Green);
   id = plot27.RegisterStream(id, Red);
   SetIndexBuffer(id, plot30);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, White);
   SetIndexBuffer(id, plot31);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, White);
   ema17Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema17 = new EMAOnStream(ema17Source, 5);
   ema18Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema18 = new EMAOnStream(ema18Source, 11);
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   ema19Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema19 = new EMAOnStream(ema19Source, 5);
   ema20Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema20 = new EMAOnStream(ema20Source, 11);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   crossover2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = CrossStreamFactory::CreateCrossover(crossover2X, crossover2Y);
   crossunder2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2 = CrossStreamFactory::CreateCrossunder(crossunder2X, crossunder2Y);
   crossover3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3 = CrossStreamFactory::CreateCrossover(crossover3X, crossover3Y);
   crossunder3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder3 = CrossStreamFactory::CreateCrossunder(crossunder3X, crossunder3Y);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Trend Meter");
   SetIndexBuffer(id++, MA1);
   SetIndexBuffer(id++, MA2);
   SetIndexBuffer(id++, MA3);
   SetIndexBuffer(id++, MA4);
   SetIndexBuffer(id++, MA1Direction);
   SetIndexBuffer(id++, MA2Direction);
   SetIndexBuffer(id++, MA3Direction);
   SetIndexBuffer(id++, MA4Direction);
   SetIndexBuffer(id++, TopDogDad);
   SetIndexBuffer(id++, haopen);
   SetIndexBuffer(id++, haclose);
   SetIndexBuffer(id++, ccolor);
   SetIndexBuffer(id++, LinReg1);
   SetIndexBuffer(id++, TrendBars3Positive);
   SetIndexBuffer(id++, TrendBars3Negative);
   SetIndexBuffer(id++, YellowWave);
   SetIndexBuffer(id++, RSI14OB);
   SetIndexBuffer(id++, RSI14OS);
   _signaler = new Signaler();
   id = plot3.RegisterInternalStream(id);
   id = plot6.RegisterInternalStream(id);
   id = plot9.RegisterInternalStream(id);
   id = plot12.RegisterInternalStream(id);
   id = plot15.RegisterInternalStream(id);
   id = plot18.RegisterInternalStream(id);
   id = plot21.RegisterInternalStream(id);
   id = plot24.RegisterInternalStream(id);
   id = plot27.RegisterInternalStream(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   rsi1X.Release();
   rsi1.Release();
   ema1Source.Release();
   ema1.Release();
   ema2Source.Release();
   ema2.Release();
   ema3Source.Release();
   ema3.Release();
   sma1Source.Release();
   sma1.Release();
   cross1X.Release();
   cross1Y.Release();
   cross1.Release();
   sma2Source.Release();
   sma2.Release();
   ema4Source.Release();
   ema4.Release();
   sma3Source.Release();
   sma3.Release();
   ema5Source.Release();
   ema5.Release();
   sma4Source.Release();
   sma4.Release();
   ema6Source.Release();
   ema6.Release();
   sma5Source.Release();
   sma5.Release();
   ema7Source.Release();
   ema7.Release();
   ema8Source.Release();
   ema8.Release();
   ema9Source.Release();
   ema9.Release();
   ema10Source.Release();
   ema10.Release();
   ema11Source.Release();
   ema11.Release();
   ema12Source.Release();
   ema12.Release();
   ema13Source.Release();
   ema13.Release();
   ema14Source.Release();
   ema14.Release();
   ema15Source.Release();
   ema15.Release();
   ema16Source.Release();
   ema16.Release();
   rsi2X.Release();
   rsi2.Release();
   rsi3X.Release();
   rsi3.Release();
   sma6Source.Release();
   sma6.Release();
   sma7Source.Release();
   sma7.Release();
   stdev1Source.Release();
   stdev1.Release();
   stdev2Source.Release();
   stdev2.Release();
   correlation1Source1.Release();
   correlation1Source2.Release();
   correlation1.Release();
   rsi4X.Release();
   rsi4.Release();
   delete plot3;
   delete plot6;
   delete plot9;
   delete plot12;
   delete plot15;
   delete plot18;
   delete plot21;
   delete plot24;
   delete plot27;
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   ema17Source.Release();
   ema17.Release();
   ema18Source.Release();
   ema18.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   ema19Source.Release();
   ema19.Release();
   ema20Source.Release();
   ema20.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   crossunder2X.Release();
   crossunder2Y.Release();
   crossunder2.Release();
   crossover3X.Release();
   crossover3Y.Release();
   crossover3.Release();
   crossunder3X.Release();
   crossunder3Y.Release();
   crossunder3.Release();
   delete _signaler;
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
      ema1Source.Init();
      ema2Source.Init();
      ema3Source.Init();
      sma1Source.Init();
      cross1X.Init();
      cross1Y.Init();
      sma2Source.Init();
      ema4Source.Init();
      sma3Source.Init();
      ema5Source.Init();
      sma4Source.Init();
      ema6Source.Init();
      sma5Source.Init();
      ema7Source.Init();
      ArrayInitialize(MA1, EMPTY_VALUE);
      ArrayInitialize(MA2, EMPTY_VALUE);
      ArrayInitialize(MA3, EMPTY_VALUE);
      ArrayInitialize(MA4, EMPTY_VALUE);
      ArrayInitialize(MA1Direction, EMPTY_VALUE);
      ArrayInitialize(MA2Direction, EMPTY_VALUE);
      ArrayInitialize(MA3Direction, EMPTY_VALUE);
      ArrayInitialize(MA4Direction, EMPTY_VALUE);
      ema8Source.Init();
      ema9Source.Init();
      ema10Source.Init();
      ema11Source.Init();
      ema12Source.Init();
      ema13Source.Init();
      ema14Source.Init();
      ema15Source.Init();
      ema16Source.Init();
      ArrayInitialize(TopDogDad, EMPTY_VALUE);
      ArrayInitialize(haopen, 0.0);
      ArrayInitialize(haclose, EMPTY_VALUE);
      ArrayInitialize(ccolor, EMPTY_VALUE);
      rsi2X.Init();
      rsi3X.Init();
      sma6Source.Init();
      sma7Source.Init();
      stdev1Source.Init();
      stdev2Source.Init();
      correlation1Source1.Init();
      correlation1Source2.Init();
      ArrayInitialize(LinReg1, EMPTY_VALUE);
      ArrayInitialize(TrendBars3Positive, EMPTY_VALUE);
      ArrayInitialize(TrendBars3Negative, EMPTY_VALUE);
      ArrayInitialize(YellowWave, EMPTY_VALUE);
      rsi4X.Init();
      ArrayInitialize(RSI14OB, EMPTY_VALUE);
      ArrayInitialize(RSI14OS, EMPTY_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      plot3.Init(EMPTY_VALUE);
      plot6.Init(EMPTY_VALUE);
      plot9.Init(EMPTY_VALUE);
      plot12.Init(EMPTY_VALUE);
      plot15.Init(EMPTY_VALUE);
      plot18.Init(EMPTY_VALUE);
      plot21.Init(EMPTY_VALUE);
      plot24.Init(EMPTY_VALUE);
      plot27.Init(EMPTY_VALUE);
      ArrayInitialize(plot30, 113.7);
      ArrayInitialize(plot31, 131.3);
      ema17Source.Init();
      ema18Source.Init();
      crossover1X.Init();
      crossover1Y.Init();
      ema19Source.Init();
      ema20Source.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      crossover2X.Init();
      crossover2Y.Init();
      crossunder2X.Init();
      crossunder2Y.Init();
      crossover3X.Init();
      crossover3Y.Init();
      crossunder3X.Init();
      crossunder3Y.Init();
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
      double RSIMC = rsi1Value;
      double ap = SafeDivide((high[pos] + low[pos] + close[pos]), 3);
      int n1 = 9;
      int n2 = 12;
      ema1Source.SetValue(pos, ap);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      double esa = ema1Value;
      ema2Source.SetValue(pos, SafeMathAbs(SafeMinus(ap, esa)));
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      double de = ema2Value;
      double ci = SafeDivide((SafeMinus(ap, esa)), (SafeMultiply(0.015, de)));
      ema3Source.SetValue(pos, ci);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
      double tci = ema3Value;
      double wt1 = tci;
      sma1Source.SetValue(pos, wt1);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double wt2 = sma1Value;
      YellowWave[pos] = SafeMinus(wt1, wt2);
      int obLevel2 = 60;
      int obLevel = 50;
      int osLevel = (-50);
      int osLevel2 = (-60);
      cross1X.SetValue(pos, wt1);
      cross1Y.SetValue(pos, wt2);
      bool cross1Value;
      if (!cross1.GetValue(pos, cross1Value)) { cross1Value = EMPTY_VALUE; }
      bool WTCross = cross1Value;
      bool WTCrossUp = SafeLE(SafeMinus(wt2, wt1), 0);
      bool WTCrossDown = SafeGE(SafeMinus(wt2, wt1), 0);
      bool WTOverSold = SafeLE(wt2, osLevel2);
      bool WTOverBought = SafeGE(wt2, obLevel2);
      double Close = close[pos];
      if ((MA1_Type == "SMA"))
      {
         sma2Source.SetValue(pos, Close);
         double sma2Value;
         if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
         MA1[pos] = sma2Value;
      }
      else
      {
         ema4Source.SetValue(pos, Close);
         double ema4Value;
         if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
         MA1[pos] = ema4Value;
      }
      if ((MA2_Type == "SMA"))
      {
         sma3Source.SetValue(pos, Close);
         double sma3Value;
         if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
         MA2[pos] = sma3Value;
      }
      else
      {
         ema5Source.SetValue(pos, Close);
         double ema5Value;
         if (!ema5.GetValue(pos, ema5Value)) { ema5Value = EMPTY_VALUE; }
         MA2[pos] = ema5Value;
      }
      if ((MA3_Type == "SMA"))
      {
         sma4Source.SetValue(pos, Close);
         double sma4Value;
         if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
         MA3[pos] = sma4Value;
      }
      else
      {
         ema6Source.SetValue(pos, Close);
         double ema6Value;
         if (!ema6.GetValue(pos, ema6Value)) { ema6Value = EMPTY_VALUE; }
         MA3[pos] = ema6Value;
      }
      if ((MA4_Type == "SMA"))
      {
         sma5Source.SetValue(pos, Close);
         double sma5Value;
         if (!sma5.GetValue(pos, sma5Value)) { sma5Value = EMPTY_VALUE; }
         MA4[pos] = sma5Value;
      }
      else
      {
         ema7Source.SetValue(pos, Close);
         double ema7Value;
         if (!ema7.GetValue(pos, ema7Value)) { ema7Value = EMPTY_VALUE; }
         MA4[pos] = ema7Value;
      }
      int MACrossover1 = (SafeGreater(MA1[pos], MA2[pos]) ? 1 : 0);
      int MACrossover2 = (SafeGreater(MA3[pos], MA4[pos]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      MA1Direction[pos] = (SafeGreater(MA1[pos], MA1[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      MA2Direction[pos] = (SafeGreater(MA2[pos], MA2[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      MA3Direction[pos] = (SafeGreater(MA3[pos], MA3[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      MA4Direction[pos] = (SafeGreater(MA4[pos], MA4[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int MA1PositiveDirectionChange = (NumberToBool(MA1Direction[pos]) && !NumberToBool(MA1Direction[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int MA2PositiveDirectionChange = (NumberToBool(MA2Direction[pos]) && !NumberToBool(MA2Direction[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int MA3PositiveDirectionChange = (NumberToBool(MA3Direction[pos]) && !NumberToBool(MA3Direction[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int MA4PositiveDirectionChange = (NumberToBool(MA4Direction[pos]) && !NumberToBool(MA4Direction[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int MA1NegativeDirectionChange = (!NumberToBool(MA1Direction[pos]) && NumberToBool(MA1Direction[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int MA2NegativeDirectionChange = (!NumberToBool(MA2Direction[pos]) && NumberToBool(MA2Direction[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int MA3NegativeDirectionChange = (!NumberToBool(MA3Direction[pos]) && NumberToBool(MA3Direction[pos + 1]) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int MA4NegativeDirectionChange = (!NumberToBool(MA4Direction[pos]) && NumberToBool(MA4Direction[pos + 1]) ? 1 : 0);
      int MACDfastMA = 12;
      int MACDslowMA = 26;
      int MACDsignalSmooth = 9;
      ema8Source.SetValue(pos, close[pos]);
      double ema8Value;
      if (!ema8.GetValue(pos, ema8Value)) { ema8Value = EMPTY_VALUE; }
      ema9Source.SetValue(pos, close[pos]);
      double ema9Value;
      if (!ema9.GetValue(pos, ema9Value)) { ema9Value = EMPTY_VALUE; }
      double MACDLine = SafeMinus(ema8Value, ema9Value);
      ema10Source.SetValue(pos, MACDLine);
      double ema10Value;
      if (!ema10.GetValue(pos, ema10Value)) { ema10Value = EMPTY_VALUE; }
      double SignalLine = ema10Value;
      double MACDHistogram = SafeMinus(MACDLine, SignalLine);
      int MACDHistogramCross = (SafeGreater(MACDHistogram, 0) ? 1 : 0);
      int MACDLineOverZero = (SafeGreater(MACDLine, 0) ? 1 : 0);
      int MACDLineOverZeroandHistogramCross = (NumberToBool(MACDHistogramCross) && NumberToBool(MACDLineOverZero) ? 1 : 0);
      int MACDLineUnderZeroandHistogramCross = (!NumberToBool(MACDHistogramCross) && !NumberToBool(MACDLineOverZero) ? 1 : 0);
      int FastMACDfastMA = 8;
      int FastMACDslowMA = 21;
      int FastMACDsignalSmooth = 5;
      ema11Source.SetValue(pos, close[pos]);
      double ema11Value;
      if (!ema11.GetValue(pos, ema11Value)) { ema11Value = EMPTY_VALUE; }
      ema12Source.SetValue(pos, close[pos]);
      double ema12Value;
      if (!ema12.GetValue(pos, ema12Value)) { ema12Value = EMPTY_VALUE; }
      double FastMACDLine = SafeMinus(ema11Value, ema12Value);
      ema13Source.SetValue(pos, FastMACDLine);
      double ema13Value;
      if (!ema13.GetValue(pos, ema13Value)) { ema13Value = EMPTY_VALUE; }
      double FastSignalLine = ema13Value;
      double FastMACDHistogram = SafeMinus(FastMACDLine, FastSignalLine);
      int FastMACDHistogramCross = (SafeGreater(FastMACDHistogram, 0) ? 1 : 0);
      int FastMACDLineOverZero = (SafeGreater(FastMACDLine, 0) ? 1 : 0);
      int FastMACDLineOverZeroandHistogramCross = (NumberToBool(FastMACDHistogramCross) && NumberToBool(FastMACDLineOverZero) ? 1 : 0);
      int FastMACDLineUnderZeroandHistogramCross = (!NumberToBool(FastMACDHistogramCross) && !NumberToBool(FastMACDLineOverZero) ? 1 : 0);
      int TopDog_Fast_MA = 5;
      int TopDog_Slow_MA = 20;
      int TopDog_Sig = 30;
      ema14Source.SetValue(pos, close[pos]);
      double ema14Value;
      if (!ema14.GetValue(pos, ema14Value)) { ema14Value = EMPTY_VALUE; }
      ema15Source.SetValue(pos, close[pos]);
      double ema15Value;
      if (!ema15.GetValue(pos, ema15Value)) { ema15Value = EMPTY_VALUE; }
      double TopDogMom = SafeMinus(ema14Value, ema15Value);
      ema16Source.SetValue(pos, TopDogMom);
      double ema16Value;
      if (!ema16.GetValue(pos, ema16Value)) { ema16Value = EMPTY_VALUE; }
      TopDogDad[pos] = ema16Value;
      if (pos + 1 > (rates_total - 1)) { continue; }
      int TopDogDadDirection = (SafeGreater(TopDogDad[pos], TopDogDad[pos + 1]) ? 1 : 0);
      int TopDogMomOverDad = (SafeGreater(TopDogMom, TopDogDad[pos]) ? 1 : 0);
      int TopDogMomOverZero = (SafeGreater(TopDogMom, 0) ? 1 : 0);
      int TopDogDadDirectandMomOverZero = (NumberToBool(TopDogDadDirection) && NumberToBool(TopDogMomOverZero) ? 1 : 0);
      int TopDogDadDirectandMomUnderZero = (!NumberToBool(TopDogDadDirection) && !NumberToBool(TopDogMomOverZero) ? 1 : 0);
      haclose[pos] = SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      haopen[pos] = (((haopen[pos + 1]) == EMPTY_VALUE) ? SafeDivide((open[pos] + close[pos]), 2) : SafeDivide((haopen[pos + 1] + haclose[pos + 1]), 2));
      ccolor[pos] = ((haclose[pos] - haopen[pos] > 0) ? 1 : 0);
      if (pos + 6 > (rates_total - 1)) { continue; }
      if (pos + 6 > (rates_total - 1)) { continue; }
      if (pos + 6 > (rates_total - 1)) { continue; }
      if (pos + 6 > (rates_total - 1)) { continue; }
      if (pos + 6 > (rates_total - 1)) { continue; }
      if (pos + 6 > (rates_total - 1)) { continue; }
      if (pos + 6 > (rates_total - 1)) { continue; }
      if (pos + 6 > (rates_total - 1)) { continue; }
      int inside6 = (SafeLE(haopen[pos], MathMax(haopen[pos + 6], haclose[pos + 6])) && SafeGE(haopen[pos], MathMin(haopen[pos + 6], haclose[pos + 6])) && SafeLE(haclose[pos], MathMax(haopen[pos + 6], haclose[pos + 6])) && SafeGE(haclose[pos], MathMin(haopen[pos + 6], haclose[pos + 6])) ? 1 : 0);
      if (pos + 5 > (rates_total - 1)) { continue; }
      if (pos + 5 > (rates_total - 1)) { continue; }
      if (pos + 5 > (rates_total - 1)) { continue; }
      if (pos + 5 > (rates_total - 1)) { continue; }
      if (pos + 5 > (rates_total - 1)) { continue; }
      if (pos + 5 > (rates_total - 1)) { continue; }
      if (pos + 5 > (rates_total - 1)) { continue; }
      if (pos + 5 > (rates_total - 1)) { continue; }
      int inside5 = (SafeLE(haopen[pos], MathMax(haopen[pos + 5], haclose[pos + 5])) && SafeGE(haopen[pos], MathMin(haopen[pos + 5], haclose[pos + 5])) && SafeLE(haclose[pos], MathMax(haopen[pos + 5], haclose[pos + 5])) && SafeGE(haclose[pos], MathMin(haopen[pos + 5], haclose[pos + 5])) ? 1 : 0);
      if (pos + 4 > (rates_total - 1)) { continue; }
      if (pos + 4 > (rates_total - 1)) { continue; }
      if (pos + 4 > (rates_total - 1)) { continue; }
      if (pos + 4 > (rates_total - 1)) { continue; }
      if (pos + 4 > (rates_total - 1)) { continue; }
      if (pos + 4 > (rates_total - 1)) { continue; }
      if (pos + 4 > (rates_total - 1)) { continue; }
      if (pos + 4 > (rates_total - 1)) { continue; }
      int inside4 = (SafeLE(haopen[pos], MathMax(haopen[pos + 4], haclose[pos + 4])) && SafeGE(haopen[pos], MathMin(haopen[pos + 4], haclose[pos + 4])) && SafeLE(haclose[pos], MathMax(haopen[pos + 4], haclose[pos + 4])) && SafeGE(haclose[pos], MathMin(haopen[pos + 4], haclose[pos + 4])) ? 1 : 0);
      if (pos + 3 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      int inside3 = (SafeLE(haopen[pos], MathMax(haopen[pos + 3], haclose[pos + 3])) && SafeGE(haopen[pos], MathMin(haopen[pos + 3], haclose[pos + 3])) && SafeLE(haclose[pos], MathMax(haopen[pos + 3], haclose[pos + 3])) && SafeGE(haclose[pos], MathMin(haopen[pos + 3], haclose[pos + 3])) ? 1 : 0);
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      int inside2 = (SafeLE(haopen[pos], MathMax(haopen[pos + 2], haclose[pos + 2])) && SafeGE(haopen[pos], MathMin(haopen[pos + 2], haclose[pos + 2])) && SafeLE(haclose[pos], MathMax(haopen[pos + 2], haclose[pos + 2])) && SafeGE(haclose[pos], MathMin(haopen[pos + 2], haclose[pos + 2])) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      int inside1 = (SafeLE(haopen[pos], MathMax(haopen[pos + 1], haclose[pos + 1])) && SafeGE(haopen[pos], MathMin(haopen[pos + 1], haclose[pos + 1])) && SafeLE(haclose[pos], MathMax(haopen[pos + 1], haclose[pos + 1])) && SafeGE(haclose[pos], MathMin(haopen[pos + 1], haclose[pos + 1])) ? 1 : 0);
      if (pos + 6 > (rates_total - 1)) { continue; }
      if (pos + 5 > (rates_total - 1)) { continue; }
      if (pos + 4 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      int colorvalue = (NumberToBool(inside6) ? ccolor[pos + 6] : (NumberToBool(inside5) ? ccolor[pos + 5] : (NumberToBool(inside4) ? ccolor[pos + 4] : (NumberToBool(inside3) ? ccolor[pos + 3] : (NumberToBool(inside2) ? ccolor[pos + 2] : (NumberToBool(inside1) ? ccolor[pos + 1] : ccolor[pos]))))));
      color TrendBarTrend_Candle_Color = (NumberToBool(colorvalue) ? 0x758a28 : Red);
      int TrendBarTrend_Candle = (NumberToBool(colorvalue) ? 1 : 0);
      rsi2X.SetValue(pos, close[pos]);
      double rsi2Value;
      if (!rsi2.GetValue(pos, rsi2Value)) { rsi2Value = EMPTY_VALUE; }
      double RSI5 = rsi2Value;
      int RSI5Above50 = (SafeGreater(RSI5, 50) ? 1 : 0);
      color RSI5Color = (NumberToBool(RSI5Above50) ? 0x758a28 : Red);
      color TrendBarRSI5Color = (NumberToBool(RSI5Above50) ? 0x758a28 : Red);
      rsi3X.SetValue(pos, close[pos]);
      double rsi3Value;
      if (!rsi3.GetValue(pos, rsi3Value)) { rsi3Value = EMPTY_VALUE; }
      double RSI13 = rsi3Value;
      int SignalLineLength1 = 21;
      int x = ((rates_total - 1) - pos);
      double y = RSI13;
      sma6Source.SetValue(pos, x);
      double sma6Value;
      if (!sma6.GetValue(pos, sma6Value)) { sma6Value = EMPTY_VALUE; }
      double x_ = sma6Value;
      sma7Source.SetValue(pos, y);
      double sma7Value;
      if (!sma7.GetValue(pos, sma7Value)) { sma7Value = EMPTY_VALUE; }
      double y_ = sma7Value;
      stdev1Source.SetValue(pos, x);
      double stdev1Value;
      if (!stdev1.GetValue(pos, stdev1Value)) { stdev1Value = EMPTY_VALUE; }
      double mx = stdev1Value;
      stdev2Source.SetValue(pos, y);
      double stdev2Value;
      if (!stdev2.GetValue(pos, stdev2Value)) { stdev2Value = EMPTY_VALUE; }
      double my = stdev2Value;
      correlation1Source1.SetValue(pos, x);
      correlation1Source2.SetValue(pos, y);
      double correlation1Value;
      if (!correlation1.GetValue(pos, correlation1Value)) { correlation1Value = EMPTY_VALUE; }
      double c = correlation1Value;
      double slope = SafeMultiply(c, (SafeDivide(my, mx)));
      double inter = SafeMinus(y_, SafeMultiply(slope, x_));
      LinReg1[pos] = SafePlus(SafeMultiply(x, slope), inter);
      if (pos + 1 > (rates_total - 1)) { continue; }
      int RSISigDirection = (SafeGreater(LinReg1[pos], LinReg1[pos + 1]) ? 1 : 0);
      int RSISigCross = (SafeGreater(RSI13, LinReg1[pos]) ? 1 : 0);
      int RSI13Above50 = (SafeGreater(RSI13, 50) ? 1 : 0);
      color RSI13Color = (NumberToBool(RSI13Above50) ? 0x758a28 : Red);
      color TrendBarRSI13Color = (NumberToBool(RSI13Above50) ? 0x758a28 : Red);
      color TrendBarRSISigCrossColor = (NumberToBool(RSISigCross) ? 0x758a28 : Red);
      color TrendBarMACDColor = (NumberToBool(MACDHistogramCross) ? 0x758a28 : Red);
      color TrendBarFastMACDColor = (NumberToBool(FastMACDHistogramCross) ? 0x758a28 : Red);
      color TrendBarMACrossColor = (NumberToBool(MACrossover1) ? 0x758a28 : Red);
      color TrendBarMomOverDadColor = (NumberToBool(TopDogMomOverDad) ? 0x758a28 : Red);
      color TrendBarDadDirectionColor = (NumberToBool(TopDogDadDirection) ? 0x758a28 : Red);
      int TrendBar1Result = ((TrendBar1 == "MA Crossover") ? MACrossover1 : ((TrendBar1 == "MACD Crossover - 12, 26, 9") ? MACDHistogramCross : ((TrendBar1 == "MACD Crossover - Fast - 8, 21, 5") ? FastMACDHistogramCross : ((TrendBar1 == "Mom Dad Cross (Top Dog Trading)") ? TopDogMomOverDad : ((TrendBar1 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar1 == "RSI Signal Line Cross - RSI 13, Sig 21") ? RSISigCross : ((TrendBar1 == "RSI 5: > or < 50") ? RSI5Above50 : ((TrendBar1 == "RSI 13: > or < 50") ? RSI13Above50 : ((TrendBar1 == "Trend Candles") ? TrendBarTrend_Candle : EMPTY_VALUE)))))))));
      int TrendBar2Result = ((TrendBar2 == "MA Crossover") ? MACrossover1 : ((TrendBar2 == "MACD Crossover - 12, 26, 9") ? MACDHistogramCross : ((TrendBar2 == "MACD Crossover - Fast - 8, 21, 5") ? FastMACDHistogramCross : ((TrendBar2 == "Mom Dad Cross (Top Dog Trading)") ? TopDogMomOverDad : ((TrendBar2 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar2 == "RSI Signal Line Cross - RSI 13, Sig 21") ? RSISigCross : ((TrendBar2 == "RSI 5: > or < 50") ? RSI5Above50 : ((TrendBar2 == "RSI 13: > or < 50") ? RSI13Above50 : ((TrendBar2 == "Trend Candles") ? TrendBarTrend_Candle : EMPTY_VALUE)))))))));
      int TrendBar3Result = ((TrendBar3 == "MA Crossover") ? MACrossover1 : ((TrendBar3 == "MACD Crossover - 12, 26, 9") ? MACDHistogramCross : ((TrendBar3 == "MACD Crossover - Fast - 8, 21, 5") ? FastMACDHistogramCross : ((TrendBar3 == "Mom Dad Cross (Top Dog Trading)") ? TopDogMomOverDad : ((TrendBar3 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar3 == "RSI Signal Line Cross - RSI 13, Sig 21") ? RSISigCross : ((TrendBar3 == "RSI 5: > or < 50") ? RSI5Above50 : ((TrendBar3 == "RSI 13: > or < 50") ? RSI13Above50 : ((TrendBar3 == "Trend Candles") ? TrendBarTrend_Candle : EMPTY_VALUE)))))))));
      int TrendBars2Positive = (((NumberToBool(TrendBar1Result) && NumberToBool(TrendBar2Result) || NumberToBool(TrendBar1Result) && NumberToBool(TrendBar3Result)) || NumberToBool(TrendBar2Result) && NumberToBool(TrendBar3Result)) ? 1 : 0);
      int TrendBars2Negative = (((!NumberToBool(TrendBar1Result) && !NumberToBool(TrendBar2Result) || !NumberToBool(TrendBar1Result) && !NumberToBool(TrendBar3Result)) || !NumberToBool(TrendBar2Result) && !NumberToBool(TrendBar3Result)) ? 1 : 0);
      TrendBars3Positive[pos] = (NumberToBool(TrendBar1Result) && NumberToBool(TrendBar2Result) && NumberToBool(TrendBar3Result) ? 1 : 0);
      TrendBars3Negative[pos] = (!NumberToBool(TrendBar1Result) && !NumberToBool(TrendBar2Result) && !NumberToBool(TrendBar3Result) ? 1 : 0);
      bool PositiveWaveTrendCross = WTCross && WTCrossUp;
      bool NegativeWaveTrendCross = WTCross && WTCrossDown;
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool BackgroundColorChangePositive = NumberToBool(TrendBars3Positive[pos]) && !NumberToBool(TrendBars3Positive[pos + 1]);
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool BackgroundColorChangeNegative = NumberToBool(TrendBars3Negative[pos]) && !NumberToBool(TrendBars3Negative[pos + 1]);
      color MSBar2Color = (BackgroundColorChangePositive ? 0x758a28 : (BackgroundColorChangeNegative ? Red : EMPTY_VALUE));
      color TrendBar1Color = ((TrendBar1 == "N/A") ? EMPTY_VALUE : ((TrendBar1 == "MACD Crossover - 12, 26, 9") ? TrendBarMACDColor : ((TrendBar1 == "MACD Crossover - Fast - 8, 21, 5") ? TrendBarFastMACDColor : ((TrendBar1 == "Mom Dad Cross (Top Dog Trading)") ? TrendBarMomOverDadColor : ((TrendBar1 == "DAD Direction (Top Dog Trading)") ? TrendBarDadDirectionColor : ((TrendBar1 == "RSI Signal Line Cross - RSI 13, Sig 21") ? TrendBarRSISigCrossColor : ((TrendBar1 == "RSI 5: > or < 50") ? TrendBarRSI5Color : ((TrendBar1 == "RSI 13: > or < 50") ? TrendBarRSI13Color : ((TrendBar1 == "Trend Candles") ? TrendBarTrend_Candle_Color : ((TrendBar1 == "MA Crossover") ? TrendBarMACrossColor : EMPTY_VALUE))))))))));
      color TrendBar2Color = ((TrendBar2 == "N/A") ? EMPTY_VALUE : ((TrendBar2 == "MACD Crossover - 12, 26, 9") ? TrendBarMACDColor : ((TrendBar2 == "MACD Crossover - Fast - 8, 21, 5") ? TrendBarFastMACDColor : ((TrendBar2 == "Mom Dad Cross (Top Dog Trading)") ? TrendBarMomOverDadColor : ((TrendBar2 == "DAD Direction (Top Dog Trading)") ? TrendBarDadDirectionColor : ((TrendBar2 == "RSI Signal Line Cross - RSI 13, Sig 21") ? TrendBarRSISigCrossColor : ((TrendBar2 == "RSI 5: > or < 50") ? TrendBarRSI5Color : ((TrendBar2 == "RSI 13: > or < 50") ? TrendBarRSI13Color : ((TrendBar2 == "Trend Candles") ? TrendBarTrend_Candle_Color : ((TrendBar2 == "MA Crossover") ? TrendBarMACrossColor : EMPTY_VALUE))))))))));
      color TrendBar3Color = ((TrendBar3 == "N/A") ? EMPTY_VALUE : ((TrendBar3 == "MACD Crossover - 12, 26, 9") ? TrendBarMACDColor : ((TrendBar3 == "MACD Crossover - Fast - 8, 21, 5") ? TrendBarFastMACDColor : ((TrendBar3 == "Mom Dad Cross (Top Dog Trading)") ? TrendBarMomOverDadColor : ((TrendBar3 == "DAD Direction (Top Dog Trading)") ? TrendBarDadDirectionColor : ((TrendBar3 == "RSI Signal Line Cross - RSI 13, Sig 21") ? TrendBarRSISigCrossColor : ((TrendBar3 == "RSI 5: > or < 50") ? TrendBarRSI5Color : ((TrendBar3 == "RSI 13: > or < 50") ? TrendBarRSI13Color : ((TrendBar3 == "Trend Candles") ? TrendBarTrend_Candle_Color : ((TrendBar3 == "MA Crossover") ? TrendBarMACrossColor : EMPTY_VALUE))))))))));
      int CrossoverType2 = ((TrendBar4 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar4 == "MACD Crossover") ? MACDHistogramCross : ((TrendBar4 == "MA Direction - Fast MA - TB1") ? MA1Direction[pos] : ((TrendBar4 == "MA Direction - Slow MA - TB1") ? MA2Direction[pos] : MACrossover1))));
      color color_1 = Green;
      color color_2 = Red;
      color TrendBar4Color1 = ((TrendBar4 == "N/A") ? EMPTY_VALUE : (NumberToBool(CrossoverType2) ? color_1 : color_2));
      int CrossoverType3 = ((TrendBar5 == "DAD Direction (Top Dog Trading)") ? TopDogDadDirection : ((TrendBar5 == "MACD Crossover") ? MACDHistogramCross : ((TrendBar5 == "MA Direction - Fast MA - TB2") ? MA3Direction[pos] : ((TrendBar5 == "MA Direction - Slow MA - TB2") ? MA4Direction[pos] : MACrossover2))));
      color color_3 = Green;
      color color_4 = Red;
      color TrendBar5Color1 = ((TrendBar5 == "N/A") ? EMPTY_VALUE : (NumberToBool(CrossoverType3) ? color_3 : color_4));
      bool WTVOB = SafeGreater(wt1, 60);
      bool WTVOS = SafeLess(wt1, (-60));
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool YellowWavePointingUp = SafeGreater(YellowWave[pos], YellowWave[pos + 1]);
      rsi4X.SetValue(pos, close[pos]);
      double rsi4Value;
      if (!rsi4.GetValue(pos, rsi4Value)) { rsi4Value = EMPTY_VALUE; }
      double RSI14 = rsi4Value;
      RSI14OB[pos] = (SafeGreater(RSI14, 70) ? 1 : 0);
      RSI14OS[pos] = (SafeLess(RSI14, 30) ? 1 : 0);
      int RSI14OBOS = ((NumberToBool(RSI14OB[pos]) || NumberToBool(RSI14OS[pos])) ? 1 : 0);
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool OBIndicatorsYellowPointingDown = ((NumberToBool(RSI14OB[pos]) || NumberToBool(RSI14OB[pos + 1]))) && WTVOB && !YellowWavePointingUp;
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool OSIndicatorsYellowPointingUp = ((NumberToBool(RSI14OS[pos]) || NumberToBool(RSI14OS[pos + 1]))) && WTVOS && YellowWavePointingUp;
      color plot1_color = 0x758a28;
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = (PosNegPressure && OSIndicatorsYellowPointingUp ? 138.5 : EMPTY_VALUE); }
      else { plot1[pos] = EMPTY_VALUE; }
      color plot2_color = 0x3C14DC;
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = (PosNegPressure && OBIndicatorsYellowPointingDown ? 138.5 : EMPTY_VALUE); }
      else { plot2[pos] = EMPTY_VALUE; }
      if ((OBIndicatorsYellowPointingDown || OSIndicatorsYellowPointingUp)) { _signaler.SendNotifications(" -   Pos / Neg Pressure", "Pos / Neg Pressure - Trend Meter"); }
      plot3.SetByColor((TMSetups ? 134.5 : EMPTY_VALUE), pos, MSBar2Color);
      plot6.SetByColor((TMSetupsANDWT && (((PositiveWaveTrendCross && NumberToBool(TrendBars3Positive[pos])) || (NegativeWaveTrendCross && NumberToBool(TrendBars3Negative[pos])))) ? 134.5 : EMPTY_VALUE), pos, MSBar2Color);
      plot9.SetByColor(128.5, pos, TrendBar1Color);
      plot12.SetByColor(122.5, pos, TrendBar2Color);
      plot15.SetByColor(116.5, pos, TrendBar3Color);
      plot18.SetByColor((ShowTrendBar1 && ShowTrendBar2 ? 110 : EMPTY_VALUE), pos, TrendBar4Color1);
      plot21.SetByColor((ShowTrendBar1 && !ShowTrendBar2 ? 110 : EMPTY_VALUE), pos, TrendBar4Color1);
      plot24.SetByColor((ShowTrendBar2 && ShowTrendBar1 ? 104.5 : EMPTY_VALUE), pos, TrendBar5Color1);
      plot27.SetByColor((ShowTrendBar2 && !ShowTrendBar1 ? 110 : EMPTY_VALUE), pos, TrendBar5Color1);
      color TrendBar3BarsSame = (NumberToBool(TrendBars3Positive[pos]) ? Green : (NumberToBool(TrendBars3Negative[pos]) ? Red : EMPTY_VALUE));
      double TMa = plot30[pos];
      double TMb = plot31[pos];
      if (BackgroundColorChangePositive) { _signaler.SendNotifications(" --  3 TMs Turn Green", "All 3 Trend Meters Turn  Green - Trend Meter"); }
      if (BackgroundColorChangeNegative) { _signaler.SendNotifications(" --  3 TMs Turn Red", "All 3 Trend Meters Turn  Red - Trend Meter"); }
      if ((BackgroundColorChangePositive || BackgroundColorChangeNegative)) { _signaler.SendNotifications(" -- 3 TMs Change to Same Color", "All 3 Trend Meters Change to Same Color - Trend Meter"); }
      if (PositiveWaveTrendCross && NumberToBool(TrendBars3Positive[pos])) { _signaler.SendNotifications("--- 3 TMs Turn Green & WaveTrend X", "Green - Wave Trend Signal - Aligns with 3 Trend Meters - Trend Meter"); }
      if (NegativeWaveTrendCross && NumberToBool(TrendBars3Negative[pos])) { _signaler.SendNotifications("--- 3 TMs Turn Red & WaveTrend X", "Red - Wave Trend Signal - Aligns with 3 Trend Meters - Trend Meter"); }
      if (((PositiveWaveTrendCross && NumberToBool(TrendBars3Positive[pos])) || (NegativeWaveTrendCross && NumberToBool(TrendBars3Negative[pos])))) { _signaler.SendNotifications("--- 3 TMs Change to Same Color & WT X", "Red / Green - Wave Trend Signal - Aligns with 3 Trend Meters - Trend Meter"); }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool TrendMetersNoLongerAlign = ((((!NumberToBool(TrendBars3Positive[pos]) || !NumberToBool(TrendBars3Negative[pos]))) && NumberToBool(TrendBars3Positive[pos + 1])) || (((!NumberToBool(TrendBars3Positive[pos]) || !NumberToBool(TrendBars3Negative[pos]))) && NumberToBool(TrendBars3Negative[pos + 1])));
      if (TrendMetersNoLongerAlign) { _signaler.SendNotifications("---- 3 Trend Meters No Longer Align", "3 Trend Meters No Longer Align - Trend Meter"); }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      bool RapidColorChangePositive = NumberToBool(TrendBars3Positive[pos]) && ((NumberToBool(TrendBars3Negative[pos + 1]) || NumberToBool(TrendBars3Negative[pos + 2])));
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      bool RapidColorChangeNegative = NumberToBool(TrendBars3Negative[pos]) && ((NumberToBool(TrendBars3Positive[pos + 1]) || NumberToBool(TrendBars3Positive[pos + 2])));
      if (RapidColorChangePositive) { _signaler.SendNotifications("All 3 TMs Rapid Change Red to Green", "All 3 Trend Meters Rapid Change Red to Green - Trend Meter"); }
      if (RapidColorChangeNegative) { _signaler.SendNotifications("All 3 TMs Rapid Change Green to Red", "All 3 Trend Meters Rapid Change Green to Red - Trend Meter"); }
      if ((RapidColorChangePositive || RapidColorChangeNegative)) { _signaler.SendNotifications("All 3 TMs Rapid Change to Same Color", "All 3 Trend Meters Rapid Change to Same Color - Trend Meter"); }
      ema17Source.SetValue(pos, Close);
      double ema17Value;
      if (!ema17.GetValue(pos, ema17Value)) { ema17Value = EMPTY_VALUE; }
      ema18Source.SetValue(pos, Close);
      double ema18Value;
      if (!ema18.GetValue(pos, ema18Value)) { ema18Value = EMPTY_VALUE; }
      crossover1X.SetValue(pos, ema17Value);
      crossover1Y.SetValue(pos, ema18Value);
      bool crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { crossover1Value = EMPTY_VALUE; }
      bool MaxValueMACrossUp = crossover1Value;
      ema19Source.SetValue(pos, Close);
      double ema19Value;
      if (!ema19.GetValue(pos, ema19Value)) { ema19Value = EMPTY_VALUE; }
      ema20Source.SetValue(pos, Close);
      double ema20Value;
      if (!ema20.GetValue(pos, ema20Value)) { ema20Value = EMPTY_VALUE; }
      crossunder1X.SetValue(pos, ema19Value);
      crossunder1Y.SetValue(pos, ema20Value);
      bool crossunder1Value;
      if (!crossunder1.GetValue(pos, crossunder1Value)) { crossunder1Value = EMPTY_VALUE; }
      bool MaxValueMACrossDown = crossunder1Value;
      crossover2X.SetValue(pos, MA1[pos]);
      crossover2Y.SetValue(pos, MA2[pos]);
      bool crossover2Value;
      if (!crossover2.GetValue(pos, crossover2Value)) { crossover2Value = EMPTY_VALUE; }
      bool TB1MACrossUp = crossover2Value;
      crossunder2X.SetValue(pos, MA1[pos]);
      crossunder2Y.SetValue(pos, MA2[pos]);
      bool crossunder2Value;
      if (!crossunder2.GetValue(pos, crossunder2Value)) { crossunder2Value = EMPTY_VALUE; }
      bool TB1MACrossDown = crossunder2Value;
      if (TB1MACrossUp) { _signaler.SendNotifications("TB 1 Turns Green", "Trend Bar 1 - Turns Green - Trend Meter"); }
      if (TB1MACrossDown) { _signaler.SendNotifications("TB 1 Turns Red", "Trend Bar 1 - Turns Red - Trend Meter"); }
      if ((TB1MACrossUp || TB1MACrossDown)) { _signaler.SendNotifications("TB 1 Color Change", "Trend Bar 1 - Color Change - Trend Meter"); }
      crossover3X.SetValue(pos, MA3[pos]);
      crossover3Y.SetValue(pos, MA4[pos]);
      bool crossover3Value;
      if (!crossover3.GetValue(pos, crossover3Value)) { crossover3Value = EMPTY_VALUE; }
      bool TB2MACrossUp = crossover3Value;
      crossunder3X.SetValue(pos, MA3[pos]);
      crossunder3Y.SetValue(pos, MA4[pos]);
      bool crossunder3Value;
      if (!crossunder3.GetValue(pos, crossunder3Value)) { crossunder3Value = EMPTY_VALUE; }
      bool TB2MACrossDown = crossunder3Value;
      if (TB2MACrossUp) { _signaler.SendNotifications("TB 2 Turns Green", "Trend Bar 2 - Turns Green - Trend Meter"); }
      if (TB2MACrossDown) { _signaler.SendNotifications("TB 2 Turns Red", "Trend Bar 2 - Turns Red - Trend Meter"); }
      if ((TB2MACrossUp || TB2MACrossDown)) { _signaler.SendNotifications("TB 2 Color Change", "Trend Bar 2 - Color Change - Trend Meter"); }
      bool TB1Green = SafeGreater(MA1[pos], MA2[pos]);
      bool TB1Red = SafeLess(MA1[pos], MA2[pos]);
      bool TB2Green = SafeGreater(MA3[pos], MA4[pos]);
      bool TB2Red = SafeLess(MA3[pos], MA4[pos]);
      bool TB12Green = TB1Green && TB2Green && ((TB1MACrossUp || TB2MACrossUp));
      bool TB12Red = TB1Red && TB2Red && ((TB1MACrossDown || TB2MACrossDown));
      if (TB12Green) { _signaler.SendNotifications("TBs 1+2 Turn Green", "Trend Bars 1+2 - Turn Green - Trend Meter"); }
      if (TB12Red) { _signaler.SendNotifications("TBs 1+2 Turn Red", "Trend Bars 1+2 - Turn Red - Trend Meter"); }
      if ((TB12Green || TB12Red)) { _signaler.SendNotifications("TBs 1+2 Change to Same Color", "Trend Bars 1+2 - Change to Same Color - MAs Crossing - Trend Meter"); }
      if (TB12Green && NumberToBool(TrendBars3Positive[pos])) { _signaler.SendNotifications("TBs 1+2 Turn Green with 3 TMs", "Trend Bars 1+2 - Turn Green with 3 TMs - Trend Meter"); }
      if (TB12Red && NumberToBool(TrendBars3Negative[pos])) { _signaler.SendNotifications("TBs 1+2 Turn Red with 3 TMs", "Trend Bars 1+2 - Turn Red with 3 TMs- Trend Meter"); }
      if (((TB12Green && NumberToBool(TrendBars3Positive[pos])) || (TB12Red && NumberToBool(TrendBars3Negative[pos])))) { _signaler.SendNotifications("TBs 1+2 Change to Same Color with 3 TMs", "Trend Bars 1+2 - Change to Same Color with 3 TMs - Trend Meter"); }
      if (TB1Green && NumberToBool(TrendBars3Positive[pos])) { _signaler.SendNotifications("TB 1 Turns Green with 3 TMs", "Trend Bar 1 - Turn Green with 3 TMs - Trend Meter"); }
      if (TB1Red && NumberToBool(TrendBars3Negative[pos])) { _signaler.SendNotifications("TB 1 Turns Red with 3 TMs", "Trend Bar 1 - Turn Red with 3 TMs- Trend Meter"); }
      if (((TB1Green && NumberToBool(TrendBars3Positive[pos])) || (TB1Red && NumberToBool(TrendBars3Negative[pos])))) { _signaler.SendNotifications("TB 1 Change to Same Color with 3 TMs", "Trend Bar 1 - Change to Same Color with 3 TMs - Trend Meter"); }
      if (TB2Green && NumberToBool(TrendBars3Positive[pos])) { _signaler.SendNotifications("TB 2 Turns Green with 3 TMs", "Trend Bar 2 - Turn Green with 3 TMs - Trend Meter"); }
      if (TB2Red && NumberToBool(TrendBars3Negative[pos])) { _signaler.SendNotifications("TB 2 Turns Red with 3 TMs", "Trend Bar 2 - Turn Red with 3 TMs- Trend Meter"); }
      if (((TB2Green && NumberToBool(TrendBars3Positive[pos])) || (TB2Red && NumberToBool(TrendBars3Negative[pos])))) { _signaler.SendNotifications("TB 2 Change to Same Color with 3 TMs", "Trend Bar 2 - Change to Same Color with 3 TMs - Trend Meter"); }
      if (BackgroundColorChangePositive && TB1Green) { _signaler.SendNotifications("3 TMs Turn Green with TB 1", "All 3 Trend Meters Turn  Green with TB 1 - Trend Meter"); }
      if (BackgroundColorChangeNegative && TB1Red) { _signaler.SendNotifications("3 TMs Turn Red with TB 1", "All 3 Trend Meters Turn  Red with TB 1 - Trend Meter"); }
      if (((BackgroundColorChangePositive && TB1Green) || (BackgroundColorChangeNegative && TB1Red))) { _signaler.SendNotifications("3 TMs Change Color with TB 1", "All 3 Trend Meters Change Color with TB 1 - Trend Meter"); }
      if (BackgroundColorChangePositive && TB2Green) { _signaler.SendNotifications("3 TMs Turn Green with TB 2", "All 3 Trend Meters Turn  Green with TB 2 - Trend Meter"); }
      if (BackgroundColorChangeNegative && TB2Red) { _signaler.SendNotifications("3 TMs Turn Red with TB 2", "All 3 Trend Meters Turn  Red with TB 2 - Trend Meter"); }
      if (((BackgroundColorChangePositive && TB2Green) || (BackgroundColorChangeNegative && TB2Red))) { _signaler.SendNotifications("3 TMs Change Color with TB 2", "All 3 Trend Meters Change Color with TB 2 - Trend Meter"); }
      if (BackgroundColorChangePositive && TB1Green && TB2Green) { _signaler.SendNotifications("3 TMs Turn Green with TBs 1+2", "All 3 Trend Meters Turn  Green with Trend Bar 1+2 - Trend Meter"); }
      if (BackgroundColorChangeNegative && TB1Red && TB2Red) { _signaler.SendNotifications("3 TMs Turn Red with TBs 1+2", "All 3 Trend Meters Turn  Red with Trend Bar 1+2 - Trend Meter"); }
      if (((BackgroundColorChangePositive && TB1Green && TB2Green) || (BackgroundColorChangeNegative && TB1Red && TB2Red))) { _signaler.SendNotifications("3 TMs Change Color with TBs 1+2", "All 3 Trend Meters Change Color with Trend Bar 1+2 - Trend Meter"); }
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