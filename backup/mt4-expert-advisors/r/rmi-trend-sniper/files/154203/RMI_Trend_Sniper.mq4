//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74566

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
#property indicator_buffers 28
#property indicator_label1 "RRTH"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "RRTH"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "RRTH"
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "RRTH"
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "RRTH"
#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 2
#property indicator_label6 "RRTH"
#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 2
#property indicator_label7 "RRTH"
#property indicator_type7 DRAW_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 3
#property indicator_label8 "RRTH"
#property indicator_type8 DRAW_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 3
#property indicator_label9 "RRTH"
#property indicator_type9 DRAW_LINE
#property indicator_style9 STYLE_SOLID
#property indicator_width9 4
#property indicator_label10 "RRTH"
#property indicator_type10 DRAW_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_width10 4
#property indicator_label11 "RRTH"
#property indicator_type11 DRAW_LINE
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_label12 "RRTH"
#property indicator_type12 DRAW_LINE
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1

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

//RmaOnStream v1.0

#ifndef RmaOnStream_IMP
#define RmaOnStream_IMP

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

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
         return false;

      int currentSize = ArrayRange(_buffer, 0);
      if (currentSize < size)
      {
         ArrayResize(_buffer, size);
         for (int i = currentSize; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double alpha = 1.0 / _length;
      int index = size - 1 - period;
      if (index == 0 || _buffer[index - 1] == EMPTY_VALUE)
      {
         _buffer[index] = price;
      }
      else
      {
         _buffer[index] =  alpha * price + (1 - alpha) * _buffer[index - 1];
      }
      val = _buffer[index];
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

   bool GetValue(const int period, double &val)
   {
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double upper = 0;
      double lower = 0;
      for (int i = 0; i < _length; i++)
      {
         double prev;
         if (!_source.GetValue(period + i + 1, prev))
         {
            continue;
         }
         if (prev - current >= 0)
         {
            upper += current * iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, period + i);
         }
         else
         {
            lower += current * iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, period + i);
         }
         current = prev;
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

// True range stream v2.2

#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   bool GetValue(const int period, double &val)
   {
      int pos = Size() - period - 1;
      if (pos < 1)
      {
         if (_handleNa)
         {
            val = CalcFirst(pos);
            return true;
         }
         return false;
      }
      double h = iHigh(_symbol, _timeframe, period);
      double l = iLow(_symbol, _timeframe, period);
      double c1 = iClose(_symbol, _timeframe, period + 1);
      double hl = MathAbs(h - l);
      double hc = MathAbs(h - c1);
      double lc = MathAbs(l - c1);

      val = MathMax(lc, MathMax(hl, hc));
      return true;
   }
private:
   double CalcFirst(int pos)
   {
      double hl = MathAbs(iHigh(_symbol, _timeframe, pos) - iLow(_symbol, _timeframe, pos));
      double hc = MathAbs(iHigh(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));
      double lc = MathAbs(iLow(_symbol, _timeframe, pos) - iOpen(_symbol, _timeframe, pos));

      return MathMax(lc, MathMax(hl, hc));
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

// Average true range stream v2.1

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(int length)
      :AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
   {
      IStream* tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      IStream* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ~ATRStream()
   {
      _avg.Release();
   }

   bool GetValue(const int period, double &val)
   {
      return _avg.GetValue(period, val);
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


// Colored stream v3.3

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class ColoredStreamData
{
public:
   double Stream[];
   color Color;
};

class ColoredStream : public AStream
{
   bool _arrowsMode;
public:
   ColoredStreamData _streams[];
   double _data[];

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
      _arrowsMode = false;
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         ArrayInitialize(_streams[i].Stream, defaultValue);
      }
      ArrayInitialize(_data, defaultValue);
   }
   
   int RegisterArrowStream(int id, color clr, int arrow)
   {
      _arrowsMode = true;
      AddStream(id, clr);
      
      SetIndexEmptyValue(id, EMPTY_VALUE);
      SetIndexArrow(id, arrow);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data);
      SetIndexStyle(id + 0, DRAW_NONE);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      AddStream(id, clr);
      
      SetIndexStyle(id, lineType, lineStyle, width, clr);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      if (label != "")
         SetIndexLabel(id, label);
      return id + 1;
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Stream[period] != EMPTY_VALUE)
            return i;
      }
      return -1;
   }
   
   double SetByColor(double value, int period, color clr)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Color == clr)
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
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (!_arrowsMode && period + 1 < iBars(_symbol, _timeframe) && _streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
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
private:
   void AddStream(int id, color clr)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size].Color = clr;
      SetIndexBuffer(id, _streams[size].Stream);
   }
};

#endif
// Collection of labels v1.0

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.0

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   color _color;
   string _text;
   string _labelId;
   datetime _x;
   double _y;
   string _font;
   string _style;
public:
   Label(datetime x, double y, string labelId)
   {
      _x = x;
      _y = y;
      _labelId = labelId;
      _font = "Arial";
   }
   
   string GetId()
   {
      return _labelId;
   }
   
   Label* SetColor(color clr)
   {
      _color = clr;
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
      if (ObjectFind(0, _labelId) == -1 && ObjectCreate(0, _labelId, OBJ_TEXT, 0, _x, _y))
      {
         ObjectSetString(0, _labelId, OBJPROP_FONT, _font);
         ObjectSetInteger(0, _labelId, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, _labelId, OBJPROP_COLOR, _color);
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, _x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE1, _y);
      ObjectSetString(0, _labelId, OBJPROP_TEXT, usedText);
   }
};
#endif

class LabelsCollection
{
   string _id;
   Label* _labels[];
   static LabelsCollection* _collections[];
public:
   LabelsCollection(string id)
   {
      _id = id;
   }
   
   ~LabelsCollection()
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
   
   static void Clear()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
   }

   void Delete(int index)
   {
      //ObjectDelete();
   }

   static Label* Create(string id, datetime x, double y, datetime dateId)
   {
      ResetLastError();
      string labelId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      Label* label = new Label(x, y, labelId);
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      return label;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLabels();
      }
   }
private:
   
   void Add(Label* label)
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         if (_labels[i].GetId() == label.GetId())
         {
            delete _labels[i];
            _labels[i] = label;
            return;
         }
      }
      
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
#endif
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
input int param1 = 14; // RMI Length 
input int param2 = 66; //  Positive above
input int param3 = 30; // Negative below
input bool param4 = true; // Show Range MA 
input color param5 = 0xd4bc00; // 
input color param6 = 0x5252ff; // 
input int bars_limit = 100000; // Bars limit
double positive[];
double negative[];
int Length;
int pmom;
int nmom;
bool filleshow;
color bull;
color bear;
CustomStream* rma1Source;
RmaOnStream* rma1;
CustomStream* change1Source;
ChangeStream* change1;
CustomStream* rma2Source;
RmaOnStream* rma2;
CustomStream* change2Source;
ChangeStream* change2;
CustomStream* mfi1Series;
MfiOnStream* mfi1;
double rsi_mfi[];
CustomStream* change3Source;
ChangeStream* change3;
CustomStream* ema1Source;
EMAOnStream* ema1;
CustomStream* change4Source;
ChangeStream* change4;
CustomStream* ema2Source;
EMAOnStream* ema2;
class _Band_iStream
{
   int len;
   ATRStream* atr1;
   double methodReturnedValue1[];
   bool _initialized;
public:
   _Band_iStream(int len)
   {
      _initialized = false;
      this.len = len;
      atr1 = new ATRStream(len);
   }
   ~_Band_iStream()
   {
      atr1.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, methodReturnedValue1);
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
         ArrayInitialize(methodReturnedValue1, EMPTY_VALUE);
         _initialized = true;
      }
      double atr1Value;
      if (!atr1.GetValue(pos, atr1Value)) { return false; }
      methodReturnedValue1[pos] = SafeMathMin(SafeMultiply(atr1Value, 0.3), iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) * (SafeDivide(0.3, 100)));
      if (pos + 20 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      __out1 = SafeMultiply(SafeDivide(methodReturnedValue1[pos + 20], 2), 8);
      return true;
   }
};
_Band_iStream* _Band_i1;
class rangeMA_S_iStream
{
   IStream* Range;
   int Prd;
   CustomStream* sum1Source;
   SumOnStream* sum1;
   CustomStream* sum2Source;
   SumOnStream* sum2;
   CustomStream* sum3Source;
   SumOnStream* sum3;
   bool _initialized;
public:
   rangeMA_S_iStream(IStream* Range, int Prd)
   {
      _initialized = false;
      this.Range = Range;
      Range.AddRef();
      this.Prd = Prd;
      sum1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sum1 = new SumOnStream(sum1Source, Prd);
      sum2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sum2 = new SumOnStream(sum2Source, Prd);
      sum3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sum3 = new SumOnStream(sum3Source, Prd);
   }
   ~rangeMA_S_iStream()
   {
      Range.Release();
      sum1Source.Release();
      sum1.Release();
      sum2Source.Release();
      sum2.Release();
      sum3Source.Release();
      sum3.Release();
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
         sum1Source.Init();
         sum2Source.Init();
         sum3Source.Init();
         _initialized = true;
      }
      double RangeValue;
      if (!Range.GetValue(pos, RangeValue)) { return false; }
      sum1Source.SetValue(pos, RangeValue);
      double sum1Value;
      if (!sum1.GetValue(pos, sum1Value)) { return false; }
      double weight = SafeDivide(RangeValue, sum1Value);
      sum2Source.SetValue(pos, SafeMultiply(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), weight));
      double sum2Value;
      if (!sum2.GetValue(pos, sum2Value)) { return false; }
      double sum = sum2Value;
      sum3Source.SetValue(pos, weight);
      double sum3Value;
      if (!sum3.GetValue(pos, sum3Value)) { return false; }
      double tw = sum3Value;
      __out1 = SafeDivide(sum, tw);
      return true;
   }
};
CustomStream* rangeMA_S_i2_param1;
rangeMA_S_iStream* rangeMA_S_i2;
ColoredStream* plot1;
ColoredStream* plot3;
ColoredStream* plot5;
ColoredStream* plot7;
ColoredStream* plot9;
double plot11[];
double plot12[];
CandleStreams* plotcandle1;
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
   IndicatorBuffers(37);
   int id = 0;
   Length = param1;
   pmom = param2;
   nmom = param3;
   filleshow = param4;
   bull = param5;
   bear = param6;
   change1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   rma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma1 = new RmaOnStream(rma1Source, Length);
   change2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change2 = new ChangeStream(change2Source, 1);
   rma2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma2 = new RmaOnStream(rma2Source, Length);
   mfi1Series = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mfi1 = new MfiOnStream(mfi1Series, Length);
   ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, 5);
   change3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change3 = new ChangeStream(change3Source, 1);
   ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, 5);
   change4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change4 = new ChangeStream(change4Source, 1);
   plot1 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot1.RegisterStream(id, bull);
   id = plot1.RegisterStream(id, bear);
   plot3 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot3.RegisterStream(id, bull);
   id = plot3.RegisterStream(id, bear);
   plot5 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot5.RegisterStream(id, bull);
   id = plot5.RegisterStream(id, bear);
   plot7 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot7.RegisterStream(id, bull);
   id = plot7.RegisterStream(id, bear);
   plot9 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot9.RegisterStream(id, bull);
   id = plot9.RegisterStream(id, bear);
   color alpha = Black;
   SetIndexBuffer(id, plot11);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, alpha);
   SetIndexBuffer(id, plot12);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, alpha);
   plotcandle1 = new CandleStreams();
   id = plotcandle1.RegisterStreams(id, Green);
   id = plotcandle1.RegisterStreams(id, Red);
   barcolor1 = new CandleStreams();
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id, Green);
   id = barcolor1.RegisterStreams(id, Red);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("RMI Trend Sniper");
   SetIndexBuffer(id++, positive);
   SetIndexBuffer(id++, negative);
   SetIndexBuffer(id++, rsi_mfi);
   _Band_i1 = new _Band_iStream(30);
   id = _Band_i1.Init(id);
   rangeMA_S_i2_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rangeMA_S_i2 = new rangeMA_S_iStream(rangeMA_S_i2_param1, 20);
   id = rangeMA_S_i2.Init(id);
   id = plot1.RegisterInternalStream(id);
   id = plot3.RegisterInternalStream(id);
   id = plot5.RegisterInternalStream(id);
   id = plot7.RegisterInternalStream(id);
   id = plot9.RegisterInternalStream(id);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   rma1Source.Release();
   rma1.Release();
   change1Source.Release();
   change1.Release();
   rma2Source.Release();
   rma2.Release();
   change2Source.Release();
   change2.Release();
   mfi1Series.Release();
   mfi1.Release();
   change3Source.Release();
   change3.Release();
   ema1Source.Release();
   ema1.Release();
   change4Source.Release();
   change4.Release();
   ema2Source.Release();
   ema2.Release();
   delete _Band_i1;
   rangeMA_S_i2_param1.Release();
   delete rangeMA_S_i2;
   delete plot1;
   delete plot3;
   delete plot5;
   delete plot7;
   delete plot9;
   LabelsCollection::Clear();
   delete plotcandle1;
   delete barcolor1;
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
      ArrayInitialize(positive, false);
      ArrayInitialize(negative, false);
      change1Source.Init();
      rma1Source.Init();
      change2Source.Init();
      rma2Source.Init();
      mfi1Series.Init();
      ArrayInitialize(rsi_mfi, EMPTY_VALUE);
      ema1Source.Init();
      change3Source.Init();
      ema2Source.Init();
      change4Source.Init();
      _Band_i1.Clear();
      rangeMA_S_i2_param1.Init();
      rangeMA_S_i2.Clear();
      plot1.Init(EMPTY_VALUE);
      plot3.Init(EMPTY_VALUE);
      plot5.Init(EMPTY_VALUE);
      plot7.Init(EMPTY_VALUE);
      plot9.Init(EMPTY_VALUE);
      ArrayInitialize(plot11, EMPTY_VALUE);
      ArrayInitialize(plot12, EMPTY_VALUE);
      LabelsCollection::Clear();
      plotcandle1.Init();
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
      positive[pos] = pos < (rates_total - 1) ? positive[pos + 1] : false;
      negative[pos] = pos < (rates_total - 1) ? negative[pos + 1] : false;
      string RSI_group = "RMI Settings";
      string mom_group = "Range Vales";
      string visual = "Visuals";
      double BarRange = high[pos] - low[pos];
      change1Source.SetValue(pos, close[pos]);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { continue; }
      rma1Source.SetValue(pos, SafeMathMax(change1Value, 0));
      double rma1Value;
      if (!rma1.GetValue(pos, rma1Value)) { continue; }
      double up = rma1Value;
      change2Source.SetValue(pos, close[pos]);
      double change2Value;
      if (!change2.GetValue(pos, change2Value)) { continue; }
      rma2Source.SetValue(pos, (-SafeMathMin(change2Value, 0)));
      double rma2Value;
      if (!rma2.GetValue(pos, rma2Value)) { continue; }
      double down = rma2Value;
      double rsi = ((down == 0) ? 100 : ((up == 0) ? 0 : SafeMinus(100, (SafeDivide(100, (SafePlus(1, SafeDivide(up, down))))))));
      mfi1Series.SetValue(pos, SafeDivide((high[pos] + low[pos] + close[pos]), 3));
      double mfi1Value;
      if (!mfi1.GetValue(pos, mfi1Value)) { continue; }
      double mf = mfi1Value;
      rsi_mfi[pos] = SafeDivide((SafePlus(rsi, mf)), 2);
      if (pos + 1 > (rates_total - 1)) { continue; }
      ema1Source.SetValue(pos, close[pos]);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { continue; }
      change3Source.SetValue(pos, ema1Value);
      double change3Value;
      if (!change3.GetValue(pos, change3Value)) { continue; }
      bool p_mom = SafeLess(rsi_mfi[pos + 1], pmom) && SafeGreater(rsi_mfi[pos], pmom) && SafeGreater(rsi_mfi[pos], nmom) && SafeGreater(change3Value, 0);
      ema2Source.SetValue(pos, close[pos]);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { continue; }
      change4Source.SetValue(pos, ema2Value);
      double change4Value;
      if (!change4.GetValue(pos, change4Value)) { continue; }
      bool n_mom = SafeLess(rsi_mfi[pos], nmom) && SafeLess(change4Value, 0);
      if (p_mom)
      {
         positive[pos] = true;
         negative[pos] = false;
      }
      if (n_mom)
      {
         positive[pos] = false;
         negative[pos] = true;
      }
      double _Band_i1Value;
      if (!_Band_i1.GetValue(pos, _Band_i1Value)) { continue; }
      double Band = _Band_i1Value;
      rangeMA_S_i2_param1.SetValue(pos, BarRange);
      double rangeMA_S_i2Value;
      if (!rangeMA_S_i2.GetValue(pos, rangeMA_S_i2Value)) { continue; }
      double rwma = rangeMA_S_i2Value;
      color colour = (positive[pos] ? bull : bear);
      double RWMA = (positive[pos] ? SafeMinus(rwma, Band) : (negative[pos] ? SafePlus(rwma, Band) : EMPTY_VALUE));
      color alpha = Black;
plot1.SetByColor((filleshow ? RWMA : EMPTY_VALUE), pos, colour);
      double center = plot3.SetByColor((filleshow ? RWMA : EMPTY_VALUE), pos, colour);
;
      plot5.SetByColor((filleshow ? RWMA : EMPTY_VALUE), pos, colour);
      plot7.SetByColor((filleshow ? RWMA : EMPTY_VALUE), pos, colour);
      plot9.SetByColor((filleshow ? RWMA : EMPTY_VALUE), pos, colour);
      double max = SafePlus(RWMA, Band);
      double min = SafeMinus(RWMA, Band);
      plot11[pos] = (filleshow ? max : EMPTY_VALUE);
      double top = plot11[pos];
      plot12[pos] = (filleshow ? min : EMPTY_VALUE);
      double bottom = plot12[pos];
      color Barcol = (positive[pos] ? Green : Red);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (negative[pos] && !negative[pos + 1])
      {
         LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", time[(rates_total - 1) - ((rates_total - 1) - pos)], SafePlus(max, (SafeDivide(Band, 2))), time[pos]).SetColor(Red).SetText("").SetStyle("down");
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (positive[pos] && !positive[pos + 1])
      {
         LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", time[(rates_total - 1) - ((rates_total - 1) - pos)], SafeMinus(min, (SafeDivide(Band, 2))), time[pos]).SetColor(Green).SetText("").SetStyle("up");
      }
      double plotcandle1_open = open[pos];
      double plotcandle1_close = close[pos];
      color plotcandle1_color = Barcol;
      if (plotcandle1_color != EMPTY_VALUE)
      {
         plotcandle1.Set(pos, plotcandle1_open, high[pos], low[pos], plotcandle1_close, plotcandle1_color);
      }
      else
      {
         plotcandle1.Clear(pos);
      }
      color barcolor1_color = Barcol;
      if (barcolor1_color != EMPTY_VALUE)
      {
         barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor1_color);
      }
      else
      {
         barcolor1.Clear(pos);
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (positive[pos] && !positive[pos + 1]) { _signaler.SendNotifications("BUY", ""); }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (negative[pos] && !negative[pos + 1]) { _signaler.SendNotifications("SELL", ""); }
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