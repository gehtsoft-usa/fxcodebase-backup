//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74591

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
#property indicator_buffers 14
#property indicator_label1 "Volume, normilized to fit the Scale"
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 Red
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Volume, normilized to fit the Scale"
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_color2 Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Volume, normilized to fit the Scale"
#property indicator_type3 DRAW_HISTOGRAM
#property indicator_color3 Green
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Volume, normilized to fit the Scale"
#property indicator_type4 DRAW_HISTOGRAM
#property indicator_color4 Green
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Volume MA/OCS"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Teal
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "2nd Overbought Higher Theshold Level"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Red
#property indicator_style6 STYLE_DOT
#property indicator_width6 1
#property indicator_label7 "2nd Overbought Lower Theshold Level"
#property indicator_type7 DRAW_LINE
#property indicator_color7 Red
#property indicator_style7 STYLE_DOT
#property indicator_width7 1
#property indicator_label8 "Overbought Higher Theshold Level"
#property indicator_type8 DRAW_LINE
#property indicator_color8 Teal
#property indicator_style8 STYLE_DOT
#property indicator_width8 1
#property indicator_label9 "Overbought Lower Theshold Level"
#property indicator_type9 DRAW_LINE
#property indicator_color9 Teal
#property indicator_style9 STYLE_DOT
#property indicator_width9 1
#property indicator_label10 "Middle Line (Bull/Bear Border Line)"
#property indicator_type10 DRAW_LINE
#property indicator_color10 Gray
#property indicator_style10 STYLE_DOT
#property indicator_width10 2
#property indicator_label11 "Oversold Higher Theshold Level"
#property indicator_type11 DRAW_LINE
#property indicator_color11 Blue
#property indicator_style11 STYLE_DOT
#property indicator_width11 1
#property indicator_label12 "Oversold Lower Theshold Level"
#property indicator_type12 DRAW_LINE
#property indicator_color12 Blue
#property indicator_style12 STYLE_DOT
#property indicator_width12 1
#property indicator_label13 "Relative Strength of Price"
#property indicator_type13 DRAW_LINE
#property indicator_color13 Black
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_label14 "Relative Strength of Volume X"
#property indicator_type14 DRAW_LINE
#property indicator_color14 Blue
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1

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

//LinearRegressionOnStream v1.2

class LinearRegressionOnStream : public AOnStream
{
   double _length;
   double _buffer[];
   int _offset;
public:
   LinearRegressionOnStream(IStream *source, const int length, int offset = 0)
      :AOnStream(source)
   {
      _offset = offset;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      int range = ArrayRange(_buffer, 0);
      if (range < size)
      {
         ArrayResize(_buffer, size);
         for (int i = range; i < Bars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double price;
      if (!_source.GetValue(period + _offset, price))
      {
         return false;
      }
      int index = size - 1 - period - _offset;
      if (index < _length)
      {
         if (index >= 0)
         {
            _buffer[index] = price;
         }
         return false;
      }

      double lwmw = _length;
      double lwma = lwmw * price;
      double sma  = price;
      for (int i = 1; i < _length; ++i)
      {
         if (_buffer[index - i] == EMPTY_VALUE)
         {
            _buffer[index] = price;
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


// Cumulative on stream v1.0

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

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);

      double current;
      if (!_source.GetValue(period, current))
         return false;
      
      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - 1 && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + current;
      }
      else 
      {
         _buffer[bufferIndex] = current;
      }
      val = _buffer[bufferIndex];
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



// Sum on stream v1.2


class SumOnStream : public AOnStream
{
   double _buffer[];
   int _length;
public:
   SumOnStream(IStream *source, int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      //period is an index for time series (0 = latest)
      int totalBars = Bars;
      int range = ArrayRange(_buffer, 0);
      if (range != totalBars)
      {
         ArrayResize(_buffer, totalBars);
         for (int i = range; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }
         
      int bufferIndex = totalBars - 1 - period;
      if (bufferIndex > 0 && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         if (GetValueBuffered(period, val, bufferIndex))
         {
            _buffer[bufferIndex] = val;
            return true;
         }
         return false;
      }

      double sum = 0;
      for (int i = 0; i < _length; ++i)
      {
         double current;
         if (!_source.GetValue(period + i, current))
         {
            return false;
         }
         sum += current;
      }
      _buffer[bufferIndex] = sum;
      val = _buffer[bufferIndex];
      return true;
   }
   
private:
   bool GetValueBuffered(const int period, double &val, int bufferIndex)
   {
      double toSubstruct;
      if (!_source.GetValue(period + _length, toSubstruct))
      {
         return false;
      }
      double toAdd;
      if (!_source.GetValue(period, toAdd))
      {
         return false;
      }
      
      val = _buffer[bufferIndex - 1] + toAdd - toSubstruct;
      return true;
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
// Candles stream v.1.4
class CandleStreamsData
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];
   color Color;

   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      Color = clr;
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexLabel(id + 0, "Open");
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexLabel(id + 1, "Close");
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexLabel(id + 2, "High");
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 3, LowStream);
      SetIndexLabel(id + 3, "Low");
      return id + 4;
   }

   void AddTick(const int index, const double val)
   {
      if (OpenStream[index] == EMPTY_VALUE)
      {
         Set(index, val, val, val, val);
         return;
      }
      HighStream[index] = MathMax(HighStream[index], val);
      LowStream[index] = MathMin(LowStream[index], val);
      CloseStream[index] = val;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

class CandleStreams
{
   int _offset;
public:
   CandleStreamsData* candles[];
   CandleStreams()
   {
      _offset = 0;
   }

   ~CandleStreams()
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         delete candles[i];
      }
   }
   
   void SetOffset(int offset)
   {
      _offset = offset;
   }

   void Init()
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         item.Init();
      }
   }

   void Clear(const int index)
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         item.Clear(index + _offset);
      }
   }

   int RegisterStreams(const int id, const color clr)
   {
      int size = ArraySize(candles);
      ArrayResize(candles, size + 1);
      candles[size] = new CandleStreamsData();
      return candles[size].RegisterStreams(id, clr);
   }

   void Set(const int index, const double open, const double high, const double low, const double close, const color clr)
   {
      for (int i = 0; i < ArraySize(candles); ++i)
      {
         CandleStreamsData* item = candles[i];
         if (item.Color == clr)
         {
            item.Set(index + _offset, open, high, low, close);
         }
         else
         {
            item.Clear(index + _offset);
         }
      }
   }
};
// Conversion to string v1.0

string ToString(double value, string format)
{
   return DoubleToStr(value);
}
// Collection of labels v1.1

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.2

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
   ENUM_TIMEFRAMES _timeframe;
   int _window;
public:
   Label(int x, double y, string labelId, string collectionId, int window)
   {
      _window = window;
      _textColor = Yellow;
      _x = x;
      _y = y;
      _labelId = labelId;
      _collectionId = collectionId;
      _font = "Arial";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
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
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE1, y);
      ObjectSetString(0, _labelId, OBJPROP_TEXT, usedText);
   }
private:
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
   
   static void Clear()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL)
      {
         _all = new LabelsCollection("");
      }
      _all.ClearLabels();
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
      string labelId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      Label* label = new Label(x, y, labelId, id, 1);
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
input int param1 = 13; // Length
input string param2 = "On Balance Volume"; // ► Relative Strength of
input int param3 = 2; // Smooth RSI, with Least Squares Method
input string param4 = "Moving Average"; // ► Volume Histogram, and
input int param5 = 10; // Change Plotting Size of Volume Histogram
input bool param6 = true; // ► Volume Based Colored Bars
input bool param7 = false; // Display Labels (RSI & Volume)
input int bars_limit = 100000; // Bars limit
int length;
string addRsiX;
int smooth;
string volHist;
int size;
bool vbcb;
bool lables;
FloatStream* rsi1X;
RSIStream* rsi1;
FloatStream* linreg1Source;
LinearRegressionOnStream* linreg1;
FloatStream* rsi2X;
RSIStream* rsi2;
FloatStream* cum1X;
CumOnStream* cum1;
FloatStream* rsi3X;
RSIStream* rsi3;
FloatStream* ema1Source;
EMAOnStream* ema1;
FloatStream* change1Source;
ChangeStream* change1;
FloatStream* rsi4X;
FloatStream* rsi4Y;
RSIStream* rsi4;
FloatStream* sum1Source;
SumOnStream* sum1;
FloatStream* change2Source;
ChangeStream* change2;
FloatStream* sum2Source;
SumOnStream* sum2;
FloatStream* change3Source;
ChangeStream* change3;
FloatStream* rsi5X;
RSIStream* rsi5;
FloatStream* cum2X;
CumOnStream* cum2;
FloatStream* change4Source;
ChangeStream* change4;
FloatStream* rsi6X;
RSIStream* rsi6;
FloatStream* cum3X;
CumOnStream* cum3;
FloatStream* change5Source;
ChangeStream* change5;
FloatStream* linreg2Source;
LinearRegressionOnStream* linreg2;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* sma2Source;
SmaOnStream* sma2;
FloatStream* ema2Source;
EMAOnStream* ema2;
FloatStream* ema3Source;
EMAOnStream* ema3;
FloatStream* ema4Source;
EMAOnStream* ema4;
ColoredStream* plot1;
double plot5[];
double plot6[];
double plot7[];
double plot8[];
double plot9[];
double plot10[];
double plot11[];
double plot12[];
double plot13[];
double plot14[];
CandleStreams* barcolor1;
//Signaler v2.1
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

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
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

Signaler* _signaler;

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
   IndicatorBuffers(15);
   int id = 0;
   length = param1;
   addRsiX = param2;
   smooth = param3;
   volHist = param4;
   size = param5;
   vbcb = param6;
   lables = param7;
   rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, length);
   linreg1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   linreg1 = new LinearRegressionOnStream(linreg1Source, smooth, 0);
   cum1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cum1 = new CumOnStream(cum1X);
   rsi2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi2 = new RSIStream(rsi2X, length);
   change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, length);
   rsi3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi3 = new RSIStream(rsi3X, length);
   change2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change2 = new ChangeStream(change2Source, 1);
   sum1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sum1 = new SumOnStream(sum1Source, length);
   change3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change3 = new ChangeStream(change3Source, 1);
   sum2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sum2 = new SumOnStream(sum2Source, length);
   rsi4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi4Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi4 = new RSIStream(rsi4X, rsi4Y);
   change4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change4 = new ChangeStream(change4Source, 1);
   cum2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cum2 = new CumOnStream(cum2X);
   rsi5X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi5 = new RSIStream(rsi5X, length);
   change5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change5 = new ChangeStream(change5Source, 1);
   cum3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cum3 = new CumOnStream(cum3X);
   rsi6X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi6 = new RSIStream(rsi6X, length);
   linreg2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   linreg2 = new LinearRegressionOnStream(linreg2Source, smooth, 0);
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, length);
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, length);
   ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, 5);
   ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, 10);
   ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema4 = new EMAOnStream(ema4Source, 10);
   plot1 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot1.RegisterHistogramStream(id, Red);
   id = plot1.RegisterHistogramStream(id, Green);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   SetIndexBuffer(id++, plot9);
   SetIndexBuffer(id++, plot10);
   SetIndexBuffer(id++, plot11);
   SetIndexBuffer(id++, plot12);
   SetIndexBuffer(id++, plot13);
   SetIndexBuffer(id++, plot14);
   barcolor1 = new CandleStreams();
   barcolor1.SetOffset(0);
   LabelsCollection::SetMaxLabels(50);
   IndicatorObjPrefix = GenerateIndicatorPrefix("RSI(VOLX) by DGT");
   IndicatorShortName("RSI VOLX by DGT");
   id = plot1.RegisterInternalStream(id);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   rsi1X.Release();
   rsi1.Release();
   linreg1Source.Release();
   linreg1.Release();
   rsi2X.Release();
   rsi2.Release();
   cum1X.Release();
   cum1.Release();
   rsi3X.Release();
   rsi3.Release();
   ema1Source.Release();
   ema1.Release();
   change1Source.Release();
   change1.Release();
   rsi4X.Release();
   rsi4Y.Release();
   rsi4.Release();
   sum1Source.Release();
   sum1.Release();
   change2Source.Release();
   change2.Release();
   sum2Source.Release();
   sum2.Release();
   change3Source.Release();
   change3.Release();
   rsi5X.Release();
   rsi5.Release();
   cum2X.Release();
   cum2.Release();
   change4Source.Release();
   change4.Release();
   rsi6X.Release();
   rsi6.Release();
   cum3X.Release();
   cum3.Release();
   change5Source.Release();
   change5.Release();
   linreg2Source.Release();
   linreg2.Release();
   sma1Source.Release();
   sma1.Release();
   sma2Source.Release();
   sma2.Release();
   ema2Source.Release();
   ema2.Release();
   ema3Source.Release();
   ema3.Release();
   ema4Source.Release();
   ema4.Release();
   delete plot1;
   delete barcolor1;
   LabelsCollection::Clear();
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
      LabelsCollection::Clear();
      rsi1X.Init();
      linreg1Source.Init();
      cum1X.Init();
      rsi2X.Init();
      change1Source.Init();
      ema1Source.Init();
      rsi3X.Init();
      change2Source.Init();
      sum1Source.Init();
      change3Source.Init();
      sum2Source.Init();
      rsi4X.Init();
      rsi4Y.Init();
      change4Source.Init();
      cum2X.Init();
      rsi5X.Init();
      change5Source.Init();
      cum3X.Init();
      rsi6X.Init();
      linreg2Source.Init();
      sma1Source.Init();
      sma2Source.Init();
      ema2Source.Init();
      ema3Source.Init();
      ema4Source.Init();
      plot1.Init(EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, 85);
      ArrayInitialize(plot7, 75);
      ArrayInitialize(plot8, 60);
      ArrayInitialize(plot9, 40);
      ArrayInitialize(plot10, 50);
      ArrayInitialize(plot11, 30);
      ArrayInitialize(plot12, 20);
      ArrayInitialize(plot13, EMPTY_VALUE);
      ArrayInitialize(plot14, EMPTY_VALUE);
      barcolor1.Init();
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
      double rsi = rsi1Value;
      linreg1Source.SetValue(pos, rsi);
      double linreg1Value;
      if (!linreg1.GetValue(pos, linreg1Value)) { linreg1Value = EMPTY_VALUE; }
      double srsi = linreg1Value;
      string rsiText = "";
      double rsix;
      if ((addRsiX == "Accumulation/Distribution"))
      {
         rsiText = "rsi(ad,";
         cum1X.SetValue(pos, (((close[pos] == high[pos]) && (close[pos] == low[pos]) || (high[pos] == low[pos])) ? 0 : (SafeDivide((2 * close[pos] - low[pos] - high[pos]), (high[pos] - low[pos]))) * tick_volume[pos]));
         double cum1Value;
         if (!cum1.GetValue(pos, cum1Value)) { cum1Value = EMPTY_VALUE; }
         rsi2X.SetValue(pos, cum1Value);
         double rsi2Value;
         if (!rsi2.GetValue(pos, rsi2Value)) { rsi2Value = EMPTY_VALUE; }
         rsix = rsi2Value;
      }
      else if ((addRsiX == "Elders Force Index"))
      {
         rsiText = "rsi(efi,";
         change1Source.SetValue(pos, close[pos]);
         double change1Value;
         if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
         ema1Source.SetValue(pos, SafeMultiply(change1Value, tick_volume[pos]));
         double ema1Value;
         if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
         rsi3X.SetValue(pos, ema1Value);
         double rsi3Value;
         if (!rsi3.GetValue(pos, rsi3Value)) { rsi3Value = EMPTY_VALUE; }
         rsix = rsi3Value;
      }
      else if ((addRsiX == "Money Flow Index"))
      {
         rsiText = "mfi(close,";
         change2Source.SetValue(pos, close[pos]);
         double change2Value;
         if (!change2.GetValue(pos, change2Value)) { change2Value = EMPTY_VALUE; }
         sum1Source.SetValue(pos, tick_volume[pos] * ((SafeLE(change2Value, 0) ? 0 : close[pos])));
         double sum1Value;
         if (!sum1.GetValue(pos, sum1Value)) { sum1Value = EMPTY_VALUE; }
         change3Source.SetValue(pos, close[pos]);
         double change3Value;
         if (!change3.GetValue(pos, change3Value)) { change3Value = EMPTY_VALUE; }
         sum2Source.SetValue(pos, tick_volume[pos] * ((SafeGE(change3Value, 0) ? 0 : close[pos])));
         double sum2Value;
         if (!sum2.GetValue(pos, sum2Value)) { sum2Value = EMPTY_VALUE; }
         rsi4X.SetValue(pos, sum1Value);
         rsi4Y.SetValue(pos, sum2Value);
         double rsi4Value;
         if (!rsi4.GetValue(pos, rsi4Value)) { rsi4Value = EMPTY_VALUE; }
         rsix = rsi4Value;
      }
      else if ((addRsiX == "On Balance Volume"))
      {
         rsiText = "rsi(obv,";
         change4Source.SetValue(pos, close[pos]);
         double change4Value;
         if (!change4.GetValue(pos, change4Value)) { change4Value = EMPTY_VALUE; }
         cum2X.SetValue(pos, SafeMultiply(SafeSign(change4Value), tick_volume[pos]));
         double cum2Value;
         if (!cum2.GetValue(pos, cum2Value)) { cum2Value = EMPTY_VALUE; }
         rsi5X.SetValue(pos, cum2Value);
         double rsi5Value;
         if (!rsi5.GetValue(pos, rsi5Value)) { rsi5Value = EMPTY_VALUE; }
         rsix = rsi5Value;
      }
      else if ((addRsiX == "Price Volume Trend"))
      {
         rsiText = "rsi(pvt,";
         change5Source.SetValue(pos, close[pos]);
         double change5Value;
         if (!change5.GetValue(pos, change5Value)) { change5Value = EMPTY_VALUE; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         cum3X.SetValue(pos, SafeMultiply(SafeDivide(change5Value, close[pos + 1]), tick_volume[pos]));
         double cum3Value;
         if (!cum3.GetValue(pos, cum3Value)) { cum3Value = EMPTY_VALUE; }
         rsi6X.SetValue(pos, cum3Value);
         double rsi6Value;
         if (!rsi6.GetValue(pos, rsi6Value)) { rsi6Value = EMPTY_VALUE; }
         rsix = rsi6Value;
      }
      linreg2Source.SetValue(pos, rsix);
      double linreg2Value;
      if (!linreg2.GetValue(pos, linreg2Value)) { linreg2Value = EMPTY_VALUE; }
      double srsix = linreg2Value;
      sma1Source.SetValue(pos, tick_volume[pos]);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double mean = sma1Value;
      double volx;
      if ((volHist == "Moving Average"))
      {
         sma2Source.SetValue(pos, SafeMultiply(SafeDivide(tick_volume[pos], mean), size));
         double sma2Value;
         if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
         volx = sma2Value;
      }
      else if ((volHist == "Volume Oscillator"))
      {
         ema2Source.SetValue(pos, tick_volume[pos]);
         double ema2Value;
         if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
         ema3Source.SetValue(pos, tick_volume[pos]);
         double ema3Value;
         if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
         ema4Source.SetValue(pos, tick_volume[pos]);
         double ema4Value;
         if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
         volx = SafeMultiply(SafeDivide((SafeMinus(ema2Value, ema3Value)), ema4Value), 100);
      }
      color vbcbColor;
      if ((close[pos] < open[pos]))
      {
         if (SafeGreater(tick_volume[pos], SafeMultiply(mean, 1.5)))
         {
            vbcbColor = 0x000091;
         }
         else if (SafeGE(tick_volume[pos], SafeMultiply(mean, 0.5)) && SafeLE(tick_volume[pos], SafeMultiply(mean, 1.5)))
         {
            vbcbColor = Red;
         }
         else
         {
            vbcbColor = Orange;
         }
      }
      else
      {
         if (SafeGreater(tick_volume[pos], SafeMultiply(mean, 1.5)))
         {
            vbcbColor = 0x006400;
         }
         else if (SafeGE(tick_volume[pos], SafeMultiply(mean, 0.5)) && SafeLE(tick_volume[pos], SafeMultiply(mean, 1.5)))
         {
            vbcbColor = Green;
         }
         else
         {
            vbcbColor = 0xD4FF7F;
         }
      }
      plot1.SetByColor((NumberToBool(Nz(tick_volume[pos])) && (volHist != "Remove Both") ? SafeMultiply(SafeDivide(tick_volume[pos], mean), size) : EMPTY_VALUE), pos, ((open[pos] > close[pos]) ? Red : Green));
      plot5[pos] = (NumberToBool(Nz(tick_volume[pos])) ? volx : EMPTY_VALUE);
      double p1 = plot6[pos];
      double p2 = plot7[pos];
      double p3 = plot8[pos];
      double p4 = plot9[pos];
      double p5 = plot11[pos];
      double p6 = plot12[pos];
      plot13[pos] = srsi;
      plot14[pos] = (NumberToBool(Nz(tick_volume[pos])) ? srsix : EMPTY_VALUE);
      color barcolor1_color = (NumberToBool(Nz(tick_volume[pos])) && vbcb ? vbcbColor : EMPTY_VALUE);
      if (barcolor1_color != EMPTY_VALUE)
      {
         barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor1_color);
      }
      else
      {
         barcolor1.Clear(pos);
      }
      string volval;
      if ((tick_volume[pos] > 1000000))
      {
         volval = SafePlus(ToString(SafeDivide(tick_volume[pos], 1000000), "#.##"), "M");
      }
      else if ((tick_volume[pos] > 1000))
      {
         volval = SafePlus(ToString(SafeDivide(tick_volume[pos], 1000), "#.##"), "K");
      }
      bool VolAlert = ((tick_volume[pos] > 50));
      if (lables)
      {
         Label* rsiLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", ((rates_total - 1) - pos), 65, time[pos]).SetColor(Black).SetText("Relative Strength Index").SetTextColor(White).SetStyle("left").SetSize("normal").SetYLoc("price");
         LabelsCollection::Delete(LabelsCollection::Get(rsiLabel, 1));
         if (NumberToBool(Nz(tick_volume[pos])))
         {
            Label* rsixLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", ((rates_total - 1) - pos), 35, time[pos]).SetColor(Blue).SetText(addRsiX).SetTextColor(White).SetStyle("left").SetSize("normal").SetYLoc("price");
            LabelsCollection::Delete(LabelsCollection::Get(rsixLabel, 1));
            if ((volHist != "Remove Both"))
            {
               Label* volLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", ((rates_total - 1) - pos), 10, time[pos]).SetColor(Orange).SetText("Volume, source " + "" + " exchange").SetTextColor(White).SetStyle("left").SetSize("normal").SetYLoc("price");
               LabelsCollection::Delete(LabelsCollection::Get(volLabel, 1));
            }
         }
      }
      if (VolAlert) { _signaler.SendNotifications("Volume Alert", "Volume Greater Than 50"); }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LabelsCollection::Redraw();
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