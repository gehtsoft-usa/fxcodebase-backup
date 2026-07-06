//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75214

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
#property indicator_buffers 73
#property indicator_label1 "Renko Open"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Gray
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Renko Close"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Gray
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label59 "Renko breakout"
#property indicator_type59 DRAW_LINE
#property indicator_color59 Lime
#property indicator_style59 STYLE_SOLID
#property indicator_width59 3
#property indicator_label60 "Renko breakout"
#property indicator_type60 DRAW_LINE
#property indicator_color60 Red
#property indicator_style60 STYLE_SOLID
#property indicator_width60 3
#property indicator_label61 "Renko breakout"
#property indicator_type61 DRAW_LINE
#property indicator_style61 STYLE_SOLID
#property indicator_width61 3
#property indicator_type62 DRAW_LINE
#property indicator_color62 Green
#property indicator_style62 STYLE_SOLID
#property indicator_width62 3
#property indicator_type63 DRAW_LINE
#property indicator_color63 Silver
#property indicator_style63 STYLE_SOLID
#property indicator_width63 3
#property indicator_type64 DRAW_LINE
#property indicator_color64 Red
#property indicator_style64 STYLE_SOLID
#property indicator_width64 3
#property indicator_type65 DRAW_LINE
#property indicator_style65 STYLE_SOLID
#property indicator_width65 3
#property indicator_type66 DRAW_LINE
#property indicator_color66 Green
#property indicator_style66 STYLE_SOLID
#property indicator_width66 3
#property indicator_type67 DRAW_LINE
#property indicator_color67 Silver
#property indicator_style67 STYLE_SOLID
#property indicator_width67 3
#property indicator_type68 DRAW_LINE
#property indicator_color68 Red
#property indicator_style68 STYLE_SOLID
#property indicator_width68 3
#property indicator_type69 DRAW_LINE
#property indicator_style69 STYLE_SOLID
#property indicator_width69 3
#property indicator_type70 DRAW_NONE
#property indicator_style70 STYLE_SOLID
#property indicator_width70 1
#property indicator_type71 DRAW_ARROW
#property indicator_color71 Maroon
#property indicator_style71 STYLE_SOLID
#property indicator_width71 1
#property indicator_type72 DRAW_ARROW
#property indicator_color72 Green
#property indicator_style72 STYLE_SOLID
#property indicator_width72 6
#property indicator_type73 DRAW_ARROW
#property indicator_color73 Red
#property indicator_style73 STYLE_SOLID
#property indicator_width73 6

double SyminfoMintick(string symbol)
{
    double point = MarketInfo(symbol, MODE_POINT);
    int digits = (int)MarketInfo(symbol, MODE_DIGITS);
    int mult = digits == 3 || digits == 5 ? 10 : 1;
    return point * mult;
}
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
double InvertSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return -value;
}
double SafeMathFloor(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathFloor(value);
}
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

// SMA on stream v1.1
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

class NewBarState
{
   datetime _last;
public:
   NewBarState()
   {
      _last = 0;
   }
   void Clear()
   {
      _last = 0;
   }
   bool IsNew(datetime date)
   {
      bool isnew = _last != date;
      _last = date;
      return isnew;
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
// Custom integer stream v1.1

#ifndef IntStream_IMPL
#define IntStream_IMPL

// Abstract integer stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL


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

   void SetValue(const int period, int value)
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
   
   int RegisterArrowStream(int id, uint clr, int arrow)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new ArrowColoredStreamData(arrow, GetColorOnly(clr));
      return _streams[size].Register(id);
   }
   int RegisterStream(int id, uint clr, int transparency)
   {
      return RegisterStream(id, GetColorOnly(clr), "", transparency == 100 ? DRAW_NONE : DRAW_LINE, STYLE_SOLID, 1);
   }
   int RegisterStream(int id, uint clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new LineColoredStreamData(_symbol, _timeframe, GetColorOnly(clr), label, lineType, lineStyle, width, _internal);
      return _streams[size].Register(id);
   }
   int RegisterHistogramStream(int id, uint clr, string label = "", int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new HistogramColoredStreamData(_symbol, _timeframe, GetColorOnly(clr), label, width, _internal);
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
   
   double SetByColor(double value, int period, uint clr)
   {
      clr = GetColorOnly(clr);
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

input string param1 = "ATR"; // Method
input int param2 = 14; // [ATR] Atr Period
input double param3 = 10.0; // [Traditional] Brick Size
input string param4 = "hl"; // Source
input string param5 = "Area"; // Chart Style As
input string param6 = "Blue/Red"; // Color Theme
input bool param7 = true; // Change Bar Colors
input int param8 = 1; // Length for Breakout
input bool param9 = true; // Show Breakout Trend
input bool param10 = true; // Show Trend
input bool param11 = true; // Show Threshold
input int param12 = 34; // Trend EMA Length
input int param13 = 3; // Wait # Bars for Reversal
input double param14 = 3.0; // Trend Threshold
input double param15 = 1.5; // Trend Threshold for Reversal
input int bars_limit = 100000; // Bars limit
string mode;
int modevalue;
double boxsize;
string source;
string showstyle;
string breakoutcolor;
int changebarcol;
class conv_atr_fSStream
{
   IStream* valu;
   bool _initialized;
public:
   conv_atr_fSStream(IStream* valu)
   {
      _initialized = false;
      this.valu = valu;
      valu.AddRef();
   }
   ~conv_atr_fSStream()
   {
      valu.Release();
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
      int a = 0;
      double num = SyminfoMintick(_Symbol);
      double valuValue;
      if (!valu.GetValue(pos, valuValue)) { valuValue = EMPTY_VALUE; }
      double s = valuValue;
      if (((s) == EMPTY_VALUE))
      {
         s = SyminfoMintick(_Symbol);
      }
      if ((num < 1))
      {
         int for1_from = 1;
         int for1_to = 20;
         bool for1_forward = for1_from <= for1_to;
         int for1_step = 1 * (for1_forward ? 1 : -1);
         if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { return false; }
         for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
         {
            num = num * 10;
            if ((num > 1))
            {
               break;
            }
            a = a + 1;
         }
      }
      int for2_from = 1;
      int for2_to = a;
      bool for2_forward = for2_from <= for2_to;
      int for2_step = 1 * (for2_forward ? 1 : -1);
      if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { return false; }
      for (int x = for2_from; (for2_forward ? x <= for2_to : x >= for2_to); x += for2_step)
      {
         s = s * 10;
      }
      s = MathRound(s);
      int for3_from = 1;
      int for3_to = a;
      bool for3_forward = for3_from <= for3_to;
      int for3_step = 1 * (for3_forward ? 1 : -1);
      if (for3_from == EMPTY_VALUE || for3_to == EMPTY_VALUE) { return false; }
      for (int x = for3_from; (for3_forward ? x <= for3_to : x >= for3_to); x += for3_step)
      {
         s = SafeDivide(s, 10);
      }
      s = ((s < SyminfoMintick(_Symbol)) ? SyminfoMintick(_Symbol) : s);
      __out1 = s;
      return true;
   }
};
ATRStream* atr1;
FloatStream* conv_atr_fS1_param1;
conv_atr_fSStream* conv_atr_fS1;
double box[];
double box_DEFAULT_VALUE;
int reversal;
FirstBarState* isFirst1;
double trend[];
double trend_DEFAULT_VALUE;
FirstBarState* isFirst2;
double beginprice[];
double beginprice_DEFAULT_VALUE;
double iopenprice[];
double iopenprice_DEFAULT_VALUE;
double icloseprice[];
double icloseprice_DEFAULT_VALUE;
FloatStream* change1Source;
ChangeStream* change1;
double plot1[];
double oprice[];
double oprice_DEFAULT_VALUE;
double plot2[];
CandleStreams* plotcandle1;
CandleStreams* barcolor1;
FloatStream* change2Source;
ChangeStream* change2;
double lasticloseprice[];
double lasticloseprice_DEFAULT_VALUE;
IntStream* change3Source;
ChangeStream* change3;
IntStream* change4Source;
ChangeStream* change4;
IntStream* change5Source;
ChangeStream* change5;
int Length;
int showbreakout;
class f_BrickhighStream
{
   bool _initialized;
public:
   f_BrickhighStream()
   {
      _initialized = false;
   }
   ~f_BrickhighStream()
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
   bool GetValue(const int pos, int &__out1)
   {
      int _ret = false;
      if ((trend[pos] == 1))
      {
         int _l = SafeMinus(SafeMathFloor(SafeDivide((icloseprice[pos] - iopenprice[pos]), box[pos])), 1);
         _ret = true;
         if (SafeLess(_l, Length))
         {
            int for4_from = 0;
            int for4_to = 3000;
            bool for4_forward = for4_from <= for4_to;
            int for4_step = 1 * (for4_forward ? 1 : -1);
            if (for4_from == EMPTY_VALUE || for4_to == EMPTY_VALUE) { return false; }
            for (int x = for4_from; (for4_forward ? x <= for4_to : x >= for4_to); x += for4_step)
            {
               if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
               if (((trend[pos + x + 1]) == EMPTY_VALUE))
               {
                  _ret = false;
                  break;
               }
               if (pos + x > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
               if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
               if ((trend[pos + x] != trend[pos + x + 1]))
               {
                  if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                  if ((trend[pos + x + 1] == 1))
                  {
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (SafeGE(icloseprice[pos + x + 1], icloseprice[pos]))
                     {
                        _ret = false;
                        break;
                     }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     _l = SafePlus(_l, (SafeMathFloor(SafeDivide((SafeMinus(icloseprice[pos + x + 1], iopenprice[pos + x + 1])), box[pos + x + 1]))));
                  }
                  if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                  if ((trend[pos + x + 1] == (-1)))
                  {
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     double start = SafePlus(icloseprice[pos + x + 1], box[pos + x + 1]);
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     int forlen = SafeMinus(SafeMathFloor(SafeDivide((SafeMinus(iopenprice[pos + x + 1], icloseprice[pos + x + 1])), box[pos])), 1);
                     int for5_from = 0;
                     int for5_to = forlen;
                     bool for5_forward = for5_from <= for5_to;
                     int for5_step = 1 * (for5_forward ? 1 : -1);
                     if (for5_from == EMPTY_VALUE || for5_to == EMPTY_VALUE) { return false; }
                     for (int i = for5_from; (for5_forward ? i <= for5_to : i >= for5_to); i += for5_step)
                     {
                        if (SafeLess(start, icloseprice[pos]))
                        {
                           _l = SafePlus(_l, 1);
                        }
                        if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                        start = SafePlus(start, box[pos + x + 1]);
                     }
                  }
                  if (SafeGE(_l, Length))
                  {
                     _ret = true;
                     break;
                  }
               }
            }
         }
      }
      __out1 = _ret;
      return true;
   }
};
f_BrickhighStream* f_Brickhigh2;
class f_BricklowStream
{
   bool _initialized;
public:
   f_BricklowStream()
   {
      _initialized = false;
   }
   ~f_BricklowStream()
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
   bool GetValue(const int pos, int &__out1)
   {
      int _ret = false;
      if ((trend[pos] == (-1)))
      {
         int _l = SafeMinus(SafeMathFloor(SafeDivide((iopenprice[pos] - icloseprice[pos]), box[pos])), 1);
         _ret = true;
         if (SafeLess(_l, Length))
         {
            int for6_from = 0;
            int for6_to = 3000;
            bool for6_forward = for6_from <= for6_to;
            int for6_step = 1 * (for6_forward ? 1 : -1);
            if (for6_from == EMPTY_VALUE || for6_to == EMPTY_VALUE) { return false; }
            for (int x = for6_from; (for6_forward ? x <= for6_to : x >= for6_to); x += for6_step)
            {
               if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
               if (((trend[pos + x + 1]) == EMPTY_VALUE))
               {
                  _ret = false;
                  break;
               }
               if (pos + x > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
               if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
               if ((trend[pos + x] != trend[pos + x + 1]))
               {
                  if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                  if ((trend[pos + x + 1] == (-1)))
                  {
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (SafeLE(icloseprice[pos + x + 1], icloseprice[pos]))
                     {
                        _ret = false;
                        break;
                     }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     _l = SafePlus(_l, (SafeMathFloor(SafeDivide((SafeMinus(iopenprice[pos + x + 1], icloseprice[pos + x + 1])), box[pos + x + 1]))));
                  }
                  if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                  if ((trend[pos + x + 1] == 1))
                  {
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     double start = SafeMinus(icloseprice[pos + x + 1], box[pos + x + 1]);
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                     int forlen = SafeMinus(SafeMathFloor(SafeDivide((SafeMinus(icloseprice[pos + x + 1], iopenprice[pos + x + 1])), box[pos])), 1);
                     int for7_from = 0;
                     int for7_to = forlen;
                     bool for7_forward = for7_from <= for7_to;
                     int for7_step = 1 * (for7_forward ? 1 : -1);
                     if (for7_from == EMPTY_VALUE || for7_to == EMPTY_VALUE) { return false; }
                     for (int i = for7_from; (for7_forward ? i <= for7_to : i >= for7_to); i += for7_step)
                     {
                        if (SafeGreater(start, icloseprice[pos]))
                        {
                           _l = SafePlus(_l, 1);
                        }
                        if (pos + x + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
                        start = SafeMinus(start, box[pos + x + 1]);
                     }
                  }
                  if (SafeGE(_l, Length))
                  {
                     _ret = true;
                     break;
                  }
               }
            }
         }
      }
      __out1 = _ret;
      return true;
   }
};
f_BricklowStream* f_Bricklow3;
double _switch[];
double _switch_DEFAULT_VALUE;
double botrend[];
double botrend_DEFAULT_VALUE;
ColoredStream* plot59;
Signaler* _signaler;
int showtrend;
int showtrhold;
int tremalen;
int barcountwhip;
double thsreversal;
double thsreversal2;
FloatStream* change6Source;
ChangeStream* change6;
double trcnt1[];
double trcnt1_DEFAULT_VALUE;
FloatStream* change7Source;
ChangeStream* change7;
double countch[];
double countch_DEFAULT_VALUE;
int trch;
IntStream* change8Source;
ChangeStream* change8;
FloatStream* change9Source;
ChangeStream* change9;
IntStream* change10Source;
ChangeStream* change10;
FloatStream* change11Source;
ChangeStream* change11;
FloatStream* change12Source;
ChangeStream* change12;
double obox[];
double obox_DEFAULT_VALUE;
class mysma_fS_iStream
{
   IStream* ser;
   int len;
   bool _initialized;
public:
   mysma_fS_iStream(IStream* ser, int len)
   {
      _initialized = false;
      this.ser = ser;
      ser.AddRef();
      this.len = len;
   }
   ~mysma_fS_iStream()
   {
      ser.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, int &__out1)
   {
      double serValue;
      if (!ser.GetValue(pos, serValue)) { serValue = EMPTY_VALUE; }
      double sum = serValue;
      int nn = 1;
      if ((len > 1))
      {
         int for8_from = 0;
         int for8_to = 4000;
         bool for8_forward = for8_from <= for8_to;
         int for8_step = 1 * (for8_forward ? 1 : -1);
         if (for8_from == EMPTY_VALUE || for8_to == EMPTY_VALUE) { return false; }
         for (int i = for8_from; (for8_forward ? i <= for8_to : i >= for8_to); i += for8_step)
         {
            double serValue_i;
            if (!ser.GetValue(pos + i, serValue_i)) { serValue_i = EMPTY_VALUE; }
            double serValue_i_1;
            if (!ser.GetValue(pos + i + 1, serValue_i_1)) { serValue_i_1 = EMPTY_VALUE; }
            if (((Nz(serValue_i) == 0) || (Nz(serValue_i_1) == 0)))
            {
               break;
            }
            if ((serValue_i != Nz(serValue_i_1)))
            {
               nn = nn + 1;
               sum = SafePlus(sum, Nz(serValue_i_1));
               if ((nn == len))
               {
                  break;
               }
            }
         }
      }
      int _ret = ((nn == len) ? SafeDivide(sum, len) : EMPTY_VALUE);
      __out1 = _ret;
      return true;
   }
};
class myema_fS_i_iS_fSStream
{
   IStream* ser;
   int len;
   IIntStream* trcnt;
   IStream* obox;
   FloatStream* mysma_fS_i4_param1;
   mysma_fS_iStream* mysma_fS_i4;
   double em[];
   double em_DEFAULT_VALUE;
   bool _initialized;
public:
   myema_fS_i_iS_fSStream(IStream* ser, int len, IIntStream* trcnt, IStream* obox)
   {
      _initialized = false;
      this.ser = ser;
      ser.AddRef();
      this.len = len;
      this.trcnt = trcnt;
      trcnt.AddRef();
      this.obox = obox;
      obox.AddRef();
   }
   ~myema_fS_i_iS_fSStream()
   {
      ser.Release();
      trcnt.Release();
      obox.Release();
      mysma_fS_i4_param1.Release();
      delete mysma_fS_i4;
   }
   int Init(int id)
   {
      mysma_fS_i4_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      mysma_fS_i4 = new mysma_fS_iStream(mysma_fS_i4_param1, len);
      id = mysma_fS_i4.Init(id);
      SetIndexBuffer(id++, em);
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
         mysma_fS_i4_param1.Init();
         mysma_fS_i4.Clear();
         em_DEFAULT_VALUE = NULL;
         ArrayInitialize(em, em_DEFAULT_VALUE);
         _initialized = true;
      }
      if ((countch[pos] <= len))
      {
         double serValue;
         if (!ser.GetValue(pos, serValue)) { serValue = EMPTY_VALUE; }
         mysma_fS_i4_param1.SetValue(pos, serValue);
         int mysma_fS_i4Value;
         if (!mysma_fS_i4.GetValue(pos, mysma_fS_i4Value)) { mysma_fS_i4Value = (-1); }
         SetStream(em, pos, mysma_fS_i4Value, em_DEFAULT_VALUE);
      }
      int trcntValue;
      if (!trcnt.GetValue(pos, trcntValue)) { trcntValue = EMPTY_VALUE; }
      double serValue_trcnt;
      if (!ser.GetValue(pos + trcntValue, serValue_trcnt)) { serValue_trcnt = EMPTY_VALUE; }
      double serValue;
      if (!ser.GetValue(pos, serValue)) { serValue = EMPTY_VALUE; }
      if ((countch[pos] > len) && !((serValue_trcnt) == EMPTY_VALUE) && (serValue != Nz(serValue_trcnt)))
      {
         int alpha = SafeDivide(2, (len + 1));
         int bb = (SafeGreater(serValue, Nz(serValue_trcnt)) ? 1 : (-1));
         int kats = (trch ? reversal : 1);
         double oboxValue;
         if (!obox.GetValue(pos, oboxValue)) { oboxValue = EMPTY_VALUE; }
         double st = SafePlus(Nz(serValue_trcnt), SafeMultiply(SafeMultiply(bb, oboxValue), kats));
         if (pos + trcntValue > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
         SetStream(em, pos, SafePlus(SafeMultiply(alpha, st), SafeMultiply((1 - alpha), Nz(em[pos + trcntValue]))), em_DEFAULT_VALUE);
         st = SafePlus(st, SafeMultiply(bb, oboxValue));
         int for9_from = 0;
         int for9_to = 4000;
         bool for9_forward = for9_from <= for9_to;
         int for9_step = 1 * (for9_forward ? 1 : -1);
         if (for9_from == EMPTY_VALUE || for9_to == EMPTY_VALUE) { return false; }
         for (int x = for9_from; (for9_forward ? x <= for9_to : x >= for9_to); x += for9_step)
         {
            if ((SafeGreater(st, serValue) && (bb > 0) || SafeLess(st, serValue) && (bb < 0)))
            {
               break;
            }
            SetStream(em, pos, SafePlus(SafeMultiply(alpha, st), SafeMultiply((1 - alpha), Nz(em[pos]))), em_DEFAULT_VALUE);
            st = SafePlus(st, SafeMultiply(bb, oboxValue));
         }
      }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(em, pos, (((em[pos]) == EMPTY_VALUE) ? em[pos + 1] : em[pos]), em_DEFAULT_VALUE);
      __out1 = em[pos];
      return true;
   }
};
FloatStream* myema_fS_i_iS_fS5_param1;
IntStream* myema_fS_i_iS_fS5_param3;
FloatStream* myema_fS_i_iS_fS5_param4;
myema_fS_i_iS_fSStream* myema_fS_i_iS_fS5;
double waitit[];
double waitit_DEFAULT_VALUE;
double mtrend[];
double mtrend_DEFAULT_VALUE;
FloatStream* change13Source;
ChangeStream* change13;
double TrendUp[];
double TrendUp_DEFAULT_VALUE;
FloatStream* change14Source;
ChangeStream* change14;
FloatStream* change15Source;
ChangeStream* change15;
double TrendDown[];
double TrendDown_DEFAULT_VALUE;
FloatStream* change16Source;
ChangeStream* change16;
IntStream* change17Source;
ChangeStream* change17;
double Tsl[];
double Tsl_DEFAULT_VALUE;
ColoredStream* plot62;
ColoredStream* plot66;
double plot70[];
double plot71[];
IntStream* change18Source;
ChangeStream* change18;
IntStream* change19Source;
ChangeStream* change19;
IntStream* change20Source;
ChangeStream* change20;
ColoredStream* plot72;
IntStream* change21Source;
ChangeStream* change21;
IntStream* change22Source;
ChangeStream* change22;
IntStream* change23Source;
ChangeStream* change23;
IntStream* change24Source;
ChangeStream* change24;

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
   IndicatorBuffers(95);
   int id = 0;
   mode = param1;
   modevalue = param2;
   boxsize = param3;
   source = param4;
   showstyle = param5;
   breakoutcolor = param6;
   changebarcol = param7;
   atr1 = new ATRStream(modevalue);
   change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Gray);
   SetIndexBuffer(id, plot2);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Gray);
   plotcandle1 = new CandleStreams();
   id = plotcandle1.RegisterStreams(id, Green);
   id = plotcandle1.RegisterStreams(id, White);
   id = plotcandle1.RegisterStreams(id, Lime);
   id = plotcandle1.RegisterStreams(id, Blue);
   id = plotcandle1.RegisterStreams(id, Yellow);
   id = plotcandle1.RegisterStreams(id, Orange);
   id = plotcandle1.RegisterStreams(id, Red);
   barcolor1 = new CandleStreams();
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id, Green);
   id = barcolor1.RegisterStreams(id, White);
   id = barcolor1.RegisterStreams(id, Lime);
   id = barcolor1.RegisterStreams(id, Blue);
   id = barcolor1.RegisterStreams(id, Yellow);
   id = barcolor1.RegisterStreams(id, Orange);
   id = barcolor1.RegisterStreams(id, Red);
   change2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change2 = new ChangeStream(change2Source, 1);
   change3Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change3 = new ChangeStream(change3Source, 1);
   change4Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change4 = new ChangeStream(change4Source, 1);
   change5Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change5 = new ChangeStream(change5Source, 1);
   Length = param8;
   showbreakout = param9;
   plot59 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot59.RegisterStream(id, Lime);
   id = plot59.RegisterStream(id, Red);
   id = plot59.RegisterStream(id, EMPTY_VALUE);
   showtrend = param10;
   showtrhold = param11;
   tremalen = param12;
   barcountwhip = param13;
   thsreversal = param14;
   thsreversal2 = param15;
   change6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change6 = new ChangeStream(change6Source, 1);
   change7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change7 = new ChangeStream(change7Source, 1);
   change8Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change8 = new ChangeStream(change8Source, 1);
   change9Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change9 = new ChangeStream(change9Source, 1);
   change10Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change10 = new ChangeStream(change10Source, 1);
   change11Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change11 = new ChangeStream(change11Source, 1);
   change12Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change12 = new ChangeStream(change12Source, 1);
   change13Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change13 = new ChangeStream(change13Source, 1);
   change14Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change14 = new ChangeStream(change14Source, 1);
   change15Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change15 = new ChangeStream(change15Source, 1);
   change16Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change16 = new ChangeStream(change16Source, 1);
   change17Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change17 = new ChangeStream(change17Source, 1);
   plot62 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot62.RegisterStream(id, Green);
   id = plot62.RegisterStream(id, Silver);
   id = plot62.RegisterStream(id, Red);
   id = plot62.RegisterStream(id, EMPTY_VALUE);
   plot66 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot66.RegisterStream(id, Green);
   id = plot66.RegisterStream(id, Silver);
   id = plot66.RegisterStream(id, Red);
   id = plot66.RegisterStream(id, EMPTY_VALUE);
   SetIndexBuffer(id++, plot70);
   SetIndexBuffer(id, plot71);
   SetIndexArrow(id, 161);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, Maroon);
   change18Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change18 = new ChangeStream(change18Source, 1);
   change19Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change19 = new ChangeStream(change19Source, 1);
   change20Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change20 = new ChangeStream(change20Source, 1);
   plot72 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot72.RegisterArrowStream(id, Green, 161);
   id = plot72.RegisterArrowStream(id, Red, 161);
   change21Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change21 = new ChangeStream(change21Source, 1);
   change22Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change22 = new ChangeStream(change22Source, 1);
   change23Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change23 = new ChangeStream(change23Source, 1);
   change24Source = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change24 = new ChangeStream(change24Source, 1);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Renko Chart");
   conv_atr_fS1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   conv_atr_fS1 = new conv_atr_fSStream(conv_atr_fS1_param1);
   id = conv_atr_fS1.Init(id);
   SetIndexBuffer(id++, box);
   isFirst1 = new FirstBarState();
   SetIndexBuffer(id++, trend);
   isFirst2 = new FirstBarState();
   SetIndexBuffer(id++, beginprice);
   SetIndexBuffer(id++, iopenprice);
   SetIndexBuffer(id++, icloseprice);
   SetIndexBuffer(id++, oprice);
   SetIndexBuffer(id++, lasticloseprice);
   f_Brickhigh2 = new f_BrickhighStream();
   id = f_Brickhigh2.Init(id);
   f_Bricklow3 = new f_BricklowStream();
   id = f_Bricklow3.Init(id);
   SetIndexBuffer(id++, _switch);
   SetIndexBuffer(id++, botrend);
   id = plot59.RegisterInternalStream(id);
   _signaler = new Signaler();
   SetIndexBuffer(id++, trcnt1);
   SetIndexBuffer(id++, countch);
   SetIndexBuffer(id++, obox);
   myema_fS_i_iS_fS5_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   myema_fS_i_iS_fS5_param3 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   myema_fS_i_iS_fS5_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   myema_fS_i_iS_fS5 = new myema_fS_i_iS_fSStream(myema_fS_i_iS_fS5_param1, tremalen, myema_fS_i_iS_fS5_param3, myema_fS_i_iS_fS5_param4);
   id = myema_fS_i_iS_fS5.Init(id);
   SetIndexBuffer(id++, waitit);
   SetIndexBuffer(id++, mtrend);
   SetIndexBuffer(id++, TrendUp);
   SetIndexBuffer(id++, TrendDown);
   SetIndexBuffer(id++, Tsl);
   id = plot62.RegisterInternalStream(id);
   id = plot66.RegisterInternalStream(id);
   id = plot72.RegisterInternalStream(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   atr1.Release();
   conv_atr_fS1_param1.Release();
   delete conv_atr_fS1;
   delete isFirst1;
   delete isFirst2;
   change1Source.Release();
   change1.Release();
   delete plotcandle1;
   delete barcolor1;
   change2Source.Release();
   change2.Release();
   change3Source.Release();
   change3.Release();
   change4Source.Release();
   change4.Release();
   change5Source.Release();
   change5.Release();
   delete f_Brickhigh2;
   delete f_Bricklow3;
   delete plot59;
   change6Source.Release();
   change6.Release();
   change7Source.Release();
   change7.Release();
   change8Source.Release();
   change8.Release();
   change9Source.Release();
   change9.Release();
   change10Source.Release();
   change10.Release();
   change11Source.Release();
   change11.Release();
   change12Source.Release();
   change12.Release();
   myema_fS_i_iS_fS5_param1.Release();
   myema_fS_i_iS_fS5_param3.Release();
   myema_fS_i_iS_fS5_param4.Release();
   delete myema_fS_i_iS_fS5;
   change13Source.Release();
   change13.Release();
   change14Source.Release();
   change14.Release();
   change15Source.Release();
   change15.Release();
   change16Source.Release();
   change16.Release();
   change17Source.Release();
   change17.Release();
   delete plot62;
   delete plot66;
   change18Source.Release();
   change18.Release();
   change19Source.Release();
   change19.Release();
   change20Source.Release();
   change20.Release();
   delete plot72;
   change21Source.Release();
   change21.Release();
   change22Source.Release();
   change22.Release();
   change23Source.Release();
   change23.Release();
   change24Source.Release();
   change24.Release();
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
      conv_atr_fS1_param1.Init();
      conv_atr_fS1.Clear();
      box_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(box, box_DEFAULT_VALUE);
      isFirst1.Clear();
      trend_DEFAULT_VALUE = 0;
      ArrayInitialize(trend, trend_DEFAULT_VALUE);
      isFirst2.Clear();
      beginprice_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(beginprice, beginprice_DEFAULT_VALUE);
      iopenprice_DEFAULT_VALUE = 0.0;
      ArrayInitialize(iopenprice, iopenprice_DEFAULT_VALUE);
      icloseprice_DEFAULT_VALUE = 0.0;
      ArrayInitialize(icloseprice, icloseprice_DEFAULT_VALUE);
      change1Source.Init();
      ArrayInitialize(plot1, EMPTY_VALUE);
      oprice_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(oprice, oprice_DEFAULT_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      plotcandle1.Init();
      barcolor1.Init();
      change2Source.Init();
      lasticloseprice_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(lasticloseprice, lasticloseprice_DEFAULT_VALUE);
      change3Source.Init();
      change4Source.Init();
      change5Source.Init();
      f_Brickhigh2.Clear();
      f_Bricklow3.Clear();
      _switch_DEFAULT_VALUE = 0;
      ArrayInitialize(_switch, _switch_DEFAULT_VALUE);
      botrend_DEFAULT_VALUE = 0;
      ArrayInitialize(botrend, botrend_DEFAULT_VALUE);
      plot59.Init(EMPTY_VALUE);
      change6Source.Init();
      trcnt1_DEFAULT_VALUE = 0;
      ArrayInitialize(trcnt1, trcnt1_DEFAULT_VALUE);
      change7Source.Init();
      countch_DEFAULT_VALUE = 0;
      ArrayInitialize(countch, countch_DEFAULT_VALUE);
      change8Source.Init();
      change9Source.Init();
      change10Source.Init();
      change11Source.Init();
      change12Source.Init();
      obox_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(obox, obox_DEFAULT_VALUE);
      myema_fS_i_iS_fS5_param1.Init();
      myema_fS_i_iS_fS5_param3.Init();
      myema_fS_i_iS_fS5_param4.Init();
      myema_fS_i_iS_fS5.Clear();
      waitit_DEFAULT_VALUE = 0;
      ArrayInitialize(waitit, waitit_DEFAULT_VALUE);
      mtrend_DEFAULT_VALUE = 0;
      ArrayInitialize(mtrend, mtrend_DEFAULT_VALUE);
      change13Source.Init();
      TrendUp_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(TrendUp, TrendUp_DEFAULT_VALUE);
      change14Source.Init();
      change15Source.Init();
      TrendDown_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(TrendDown, TrendDown_DEFAULT_VALUE);
      change16Source.Init();
      change17Source.Init();
      Tsl_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(Tsl, Tsl_DEFAULT_VALUE);
      plot62.Init(EMPTY_VALUE);
      plot66.Init(EMPTY_VALUE);
      ArrayInitialize(plot70, EMPTY_VALUE);
      ArrayInitialize(plot71, EMPTY_VALUE);
      change18Source.Init();
      change19Source.Init();
      change20Source.Init();
      plot72.Init(EMPTY_VALUE);
      change21Source.Init();
      change22Source.Init();
      change23Source.Init();
      change24Source.Init();
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
      double atr1Value;
      if (!atr1.GetValue(pos, atr1Value)) { atr1Value = EMPTY_VALUE; }
      conv_atr_fS1_param1.SetValue(pos, atr1Value);
      double conv_atr_fS1Value;
      if (!conv_atr_fS1.GetValue(pos, conv_atr_fS1Value)) { conv_atr_fS1Value = EMPTY_VALUE; }
      double atrboxsize = conv_atr_fS1Value;
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(box, pos, (((box[pos + 1]) == EMPTY_VALUE) ? ((mode == "ATR") ? atrboxsize : boxsize) : box[pos + 1]), box_DEFAULT_VALUE);
      reversal = 2;
      double top = 0.0;
      double bottom = 0.0;
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(trend, pos, (isFirst1.IsFirst() ? 0 : Nz(trend[pos + 1])), trend_DEFAULT_VALUE);
      double currentprice = 0.0;
      currentprice = ((source == "close") ? close[pos] : ((trend[pos] == 1) ? high[pos] : low[pos]));
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(beginprice, pos, (isFirst2.IsFirst() ? SafeMultiply(SafeMathFloor(SafeDivide(open[pos], box[pos])), box[pos]) : Nz(beginprice[pos + 1])), beginprice_DEFAULT_VALUE);
      if ((trend[pos] == 0) && SafeLE(SafeMultiply(box[pos], reversal), SafeMathAbs(SafeMinus(beginprice[pos], currentprice))))
      {
         if (SafeGreater(beginprice[pos], currentprice))
         {
            int numcell = SafeMathFloor(SafeDivide(SafeMathAbs(SafeMinus(beginprice[pos], currentprice)), box[pos]));
            SetStream(iopenprice, pos, beginprice[pos], iopenprice_DEFAULT_VALUE);
            SetStream(icloseprice, pos, SafeMinus(beginprice[pos], SafeMultiply(numcell, box[pos])), icloseprice_DEFAULT_VALUE);
            SetStream(trend, pos, (-1), trend_DEFAULT_VALUE);
         }
         if (SafeLess(beginprice[pos], currentprice))
         {
            int numcell = SafeMathFloor(SafeDivide(SafeMathAbs(SafeMinus(beginprice[pos], currentprice)), box[pos]));
            SetStream(iopenprice, pos, beginprice[pos], iopenprice_DEFAULT_VALUE);
            SetStream(icloseprice, pos, SafePlus(beginprice[pos], SafeMultiply(numcell, box[pos])), icloseprice_DEFAULT_VALUE);
            SetStream(trend, pos, 1, trend_DEFAULT_VALUE);
         }
      }
      if ((trend[pos] == (-1)))
      {
         int nok = true;
         if (SafeGreater(beginprice[pos], currentprice) && SafeLE(box[pos], SafeMathAbs(SafeMinus(beginprice[pos], currentprice))))
         {
            int numcell = SafeMathFloor(SafeDivide(SafeMathAbs(SafeMinus(beginprice[pos], currentprice)), box[pos]));
            SetStream(icloseprice, pos, SafeMinus(beginprice[pos], SafeMultiply(numcell, box[pos])), icloseprice_DEFAULT_VALUE);
            SetStream(trend, pos, (-1), trend_DEFAULT_VALUE);
            SetStream(beginprice, pos, icloseprice[pos], beginprice_DEFAULT_VALUE);
            nok = false;
         }
         else
         {
            if (pos + 1 > (rates_total - 1)) { continue; }
            SetStream(iopenprice, pos, ((iopenprice[pos] == 0) ? Nz(iopenprice[pos + 1]) : iopenprice[pos]), iopenprice_DEFAULT_VALUE);
            if (pos + 1 > (rates_total - 1)) { continue; }
            SetStream(icloseprice, pos, ((icloseprice[pos] == 0) ? Nz(icloseprice[pos + 1]) : icloseprice[pos]), icloseprice_DEFAULT_VALUE);
         }
         double tempcurrentprice = ((source == "close") ? close[pos] : high[pos]);
         if (SafeLess(beginprice[pos], tempcurrentprice) && SafeLE(SafeMultiply(box[pos], reversal), SafeMathAbs(SafeMinus(beginprice[pos], tempcurrentprice))) && nok)
         {
            int numcell = SafeMathFloor(SafeDivide(SafeMathAbs(SafeMinus(beginprice[pos], tempcurrentprice)), box[pos]));
            SetStream(iopenprice, pos, SafePlus(beginprice[pos], box[pos]), iopenprice_DEFAULT_VALUE);
            SetStream(icloseprice, pos, SafePlus(beginprice[pos], SafeMultiply(numcell, box[pos])), icloseprice_DEFAULT_VALUE);
            SetStream(trend, pos, 1, trend_DEFAULT_VALUE);
            SetStream(beginprice, pos, icloseprice[pos], beginprice_DEFAULT_VALUE);
         }
         else
         {
            if (pos + 1 > (rates_total - 1)) { continue; }
            SetStream(iopenprice, pos, ((iopenprice[pos] == 0) ? Nz(iopenprice[pos + 1]) : iopenprice[pos]), iopenprice_DEFAULT_VALUE);
            if (pos + 1 > (rates_total - 1)) { continue; }
            SetStream(icloseprice, pos, ((icloseprice[pos] == 0) ? Nz(icloseprice[pos + 1]) : icloseprice[pos]), icloseprice_DEFAULT_VALUE);
         }
      }
      else
      {
         if ((trend[pos] == 1))
         {
            int nok = true;
            if (SafeLess(beginprice[pos], currentprice) && SafeLE(box[pos], SafeMathAbs(SafeMinus(beginprice[pos], currentprice))))
            {
               int numcell = SafeMathFloor(SafeDivide(SafeMathAbs(SafeMinus(beginprice[pos], currentprice)), box[pos]));
               SetStream(icloseprice, pos, SafePlus(beginprice[pos], SafeMultiply(numcell, box[pos])), icloseprice_DEFAULT_VALUE);
               SetStream(trend, pos, 1, trend_DEFAULT_VALUE);
               SetStream(beginprice, pos, icloseprice[pos], beginprice_DEFAULT_VALUE);
               nok = false;
            }
            else
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               SetStream(iopenprice, pos, ((iopenprice[pos] == 0) ? Nz(iopenprice[pos + 1]) : iopenprice[pos]), iopenprice_DEFAULT_VALUE);
               if (pos + 1 > (rates_total - 1)) { continue; }
               SetStream(icloseprice, pos, ((icloseprice[pos] == 0) ? Nz(icloseprice[pos + 1]) : icloseprice[pos]), icloseprice_DEFAULT_VALUE);
            }
            double tempcurrentprice = ((source == "close") ? close[pos] : low[pos]);
            if (SafeGreater(beginprice[pos], tempcurrentprice) && SafeLE(SafeMultiply(box[pos], reversal), SafeMathAbs(SafeMinus(beginprice[pos], tempcurrentprice))) && nok)
            {
               int numcell = SafeMathFloor(SafeDivide(SafeMathAbs(SafeMinus(beginprice[pos], tempcurrentprice)), box[pos]));
               SetStream(iopenprice, pos, SafeMinus(beginprice[pos], box[pos]), iopenprice_DEFAULT_VALUE);
               SetStream(icloseprice, pos, SafeMinus(beginprice[pos], SafeMultiply(numcell, box[pos])), icloseprice_DEFAULT_VALUE);
               SetStream(trend, pos, (-1), trend_DEFAULT_VALUE);
               SetStream(beginprice, pos, icloseprice[pos], beginprice_DEFAULT_VALUE);
            }
            else
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               SetStream(iopenprice, pos, ((iopenprice[pos] == 0) ? Nz(iopenprice[pos + 1]) : iopenprice[pos]), iopenprice_DEFAULT_VALUE);
               if (pos + 1 > (rates_total - 1)) { continue; }
               SetStream(icloseprice, pos, ((icloseprice[pos] == 0) ? Nz(icloseprice[pos + 1]) : icloseprice[pos]), icloseprice_DEFAULT_VALUE);
            }
         }
      }
      change1Source.SetValue(pos, icloseprice[pos]);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      SetStream(box, pos, (NumberToBool(change1Value) ? ((mode == "ATR") ? atrboxsize : boxsize) : box[pos]), box_DEFAULT_VALUE);
      uint upcolor = ((breakoutcolor == "Green/Red") ? Green : ((breakoutcolor == "White/Yellow") ? White : ((breakoutcolor == "Lime/Red") ? Lime : ((breakoutcolor == "Blue/Red") ? Blue : ((breakoutcolor == "Yellow/Blue") ? Yellow : Orange)))));
      uint downcolor = (((breakoutcolor == "Yellow/Blue") || (breakoutcolor == "Orange/Blue")) ? Blue : ((((breakoutcolor == "Green/Red") || (breakoutcolor == "Lime/Red")) || (breakoutcolor == "Blue/Red")) ? Red : Yellow));
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(oprice, pos, ((trend[pos] == 1) ? ((Nz(trend[pos + 1]) == 1) ? SafeMinus(Nz(icloseprice[pos + 1]), Nz(box[pos + 1])) : SafePlus(Nz(icloseprice[pos + 1]), Nz(box[pos + 1]))) : ((trend[pos] == (-1)) ? ((Nz(trend[pos + 1]) == (-1)) ? SafePlus(Nz(icloseprice[pos + 1]), Nz(box[pos + 1])) : SafeMinus(Nz(icloseprice[pos + 1]), Nz(box[pos + 1]))) : Nz(icloseprice[pos + 1]))), oprice_DEFAULT_VALUE);
      SetStream(oprice, pos, (SafeLess(oprice[pos], 0) ? 0 : oprice[pos]), oprice_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      color plot1_color = ((SafeLess(oprice[pos], 0) || SafeLess(oprice[pos + 1], 0)) ? EMPTY_VALUE : Gray);
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = ((showstyle == "Area") && SafeGreater(oprice[pos], 0) ? oprice[pos] : EMPTY_VALUE); }
      else { plot1[pos] = EMPTY_VALUE; }
      double openline = plot1[pos];
      if (pos + 1 > (rates_total - 1)) { continue; }
      color plot2_color = (((icloseprice[pos] <= 0) || SafeLE(icloseprice[pos + 1], 0)) ? EMPTY_VALUE : Gray);
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = ((showstyle == "Area") && (icloseprice[pos] > 0) ? icloseprice[pos] : EMPTY_VALUE); }
      else { plot2[pos] = EMPTY_VALUE; }
      double closeline = plot2[pos];
      double plotcandle1_open = ((showstyle == "Candle") ? oprice[pos] : EMPTY_VALUE);
      double plotcandle1_close = ((showstyle == "Candle") ? icloseprice[pos] : EMPTY_VALUE);
      color plotcandle1_color = ((trend[pos] == 1) ? upcolor : downcolor);
      if (plotcandle1_color != EMPTY_VALUE)
      {
         plotcandle1.Set(pos, plotcandle1_open, ((showstyle == "Candle") ? SafeMathMax(oprice[pos], icloseprice[pos]) : EMPTY_VALUE), ((showstyle == "Candle") ? SafeMathMin(oprice[pos], icloseprice[pos]) : EMPTY_VALUE), plotcandle1_close, plotcandle1_color);
      }
      else
      {
         plotcandle1.Clear(pos);
      }
      color barcolor1_color = (changebarcol ? ((trend[pos] == 1) ? upcolor : downcolor) : EMPTY_VALUE);
      if (barcolor1_color != EMPTY_VALUE)
      {
         barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor1_color);
      }
      else
      {
         barcolor1.Clear(pos);
      }
      change2Source.SetValue(pos, icloseprice[pos]);
      double change2Value;
      if (!change2.GetValue(pos, change2Value)) { change2Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(lasticloseprice, pos, (NumberToBool(change2Value) ? icloseprice[pos + 1] : Nz(lasticloseprice[pos + 1])), lasticloseprice_DEFAULT_VALUE);
      double chigh = EMPTY_VALUE;
      double clow = EMPTY_VALUE;
      int ctrend = 0;
      change3Source.SetValue(pos, trend[pos]);
      double change3Value;
      if (!change3.GetValue(pos, change3Value)) { change3Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      chigh = (NumberToBool(change3Value) ? SafeMathMax(iopenprice[pos + 1], icloseprice[pos + 1]) : EMPTY_VALUE);
      change4Source.SetValue(pos, trend[pos]);
      double change4Value;
      if (!change4.GetValue(pos, change4Value)) { change4Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      clow = (NumberToBool(change4Value) ? SafeMathMin(iopenprice[pos + 1], icloseprice[pos + 1]) : EMPTY_VALUE);
      change5Source.SetValue(pos, trend[pos]);
      double change5Value;
      if (!change5.GetValue(pos, change5Value)) { change5Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      ctrend = (NumberToBool(change5Value) ? trend[pos + 1] : EMPTY_VALUE);
      int f_Brickhigh2Value;
      if (!f_Brickhigh2.GetValue(pos, f_Brickhigh2Value)) { f_Brickhigh2Value = (-1); }
      int Brickhigh = f_Brickhigh2Value;
      int f_Bricklow3Value;
      if (!f_Bricklow3.GetValue(pos, f_Bricklow3Value)) { f_Bricklow3Value = (-1); }
      int Bricklow = f_Bricklow3Value;
      SetStream(_switch, pos, 0, _switch_DEFAULT_VALUE);
      int setA = 0;
      int setB = 0;
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (Brickhigh && (_switch[pos + 1] == 0))
      {
         SetStream(_switch, pos, 1, _switch_DEFAULT_VALUE);
         setA = 1;
         setB = 0;
         setB;
      }
      else
      {
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (Bricklow && (_switch[pos + 1] == 1))
         {
            SetStream(_switch, pos, 0, _switch_DEFAULT_VALUE);
            setA = 0;
            setB = 1;
            setB;
         }
         else
         {
            if (pos + 1 > (rates_total - 1)) { continue; }
            SetStream(_switch, pos, Nz(_switch[pos + 1], 0), _switch_DEFAULT_VALUE);
            setA = 0;
            setB = 0;
            setB;
         }
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(botrend, pos, ((setA == 1) ? 1 : ((setB == 1) ? (-1) : Nz(botrend[pos + 1]))), botrend_DEFAULT_VALUE);
      double boline = (showbreakout ? ((botrend[pos] == 1) ? ((trend[pos] == 1) ? icloseprice[pos] : oprice[pos]) : ((trend[pos] == 1) ? oprice[pos] : icloseprice[pos])) : EMPTY_VALUE);
      plot59.SetByColor(boline, pos, (showbreakout ? ((botrend[pos] == 1) ? Lime : ((botrend[pos] == (-1)) ? Red : EMPTY_VALUE)) : EMPTY_VALUE));
      if ((setA == 1)) { _signaler.SendNotifications("Breakout Uptrend started", "Breakout Uptrend started"); }
      if ((setB == 1)) { _signaler.SendNotifications("Breakout Downtrend started", "Breakout Downtrend started"); }
      change6Source.SetValue(pos, icloseprice[pos]);
      double change6Value;
      if (!change6.GetValue(pos, change6Value)) { change6Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(trcnt1, pos, (NumberToBool(change6Value) ? 1 : SafePlus(Nz(trcnt1[pos + 1]), 1)), trcnt1_DEFAULT_VALUE);
      SetStream(trcnt1, pos, ((trcnt1[pos] > 4000) ? 4000 : trcnt1[pos]), trcnt1_DEFAULT_VALUE);
      change7Source.SetValue(pos, icloseprice[pos]);
      double change7Value;
      if (!change7.GetValue(pos, change7Value)) { change7Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(countch, pos, (NumberToBool(change7Value) ? SafePlus(Nz(countch[pos + 1]), 1) : Nz(countch[pos + 1])), countch_DEFAULT_VALUE);
      trch = false;
      change8Source.SetValue(pos, trend[pos]);
      double change8Value;
      if (!change8.GetValue(pos, change8Value)) { change8Value = EMPTY_VALUE; }
      change9Source.SetValue(pos, icloseprice[pos]);
      double change9Value;
      if (!change9.GetValue(pos, change9Value)) { change9Value = EMPTY_VALUE; }
      change10Source.SetValue(pos, trend[pos]);
      double change10Value;
      if (!change10.GetValue(pos, change10Value)) { change10Value = EMPTY_VALUE; }
      change11Source.SetValue(pos, icloseprice[pos]);
      double change11Value;
      if (!change11.GetValue(pos, change11Value)) { change11Value = EMPTY_VALUE; }
      trch = (NumberToBool(change8Value) && NumberToBool(change9Value) ? true : ((change10Value == 0) && NumberToBool(change11Value) ? false : Nz(trch, false)));
      double tema = EMPTY_VALUE;
      change12Source.SetValue(pos, icloseprice[pos]);
      double change12Value;
      if (!change12.GetValue(pos, change12Value)) { change12Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(obox, pos, ((change12Value != 0) ? Nz(box[pos + 1]) : Nz(obox[pos + 1])), obox_DEFAULT_VALUE);
      myema_fS_i_iS_fS5_param1.SetValue(pos, icloseprice[pos]);
      myema_fS_i_iS_fS5_param3.SetValue(pos, trcnt1[pos]);
      myema_fS_i_iS_fS5_param4.SetValue(pos, obox[pos]);
      double myema_fS_i_iS_fS5Value;
      if (!myema_fS_i_iS_fS5.GetValue(pos, myema_fS_i_iS_fS5Value)) { myema_fS_i_iS_fS5Value = EMPTY_VALUE; }
      double tmp = myema_fS_i_iS_fS5Value;
      tema = SafeMinus(icloseprice[pos], SafeMultiply(SafeMathFloor(SafeDivide((SafeMinus(icloseprice[pos], tmp)), obox[pos])), obox[pos]));
      double Upt = SafeMinus(tema, SafeMultiply(thsreversal, box[pos]));
      Upt = (SafeGreater(Upt, SafeMinus(icloseprice[pos], SafeMultiply(reversal, box[pos]))) ? SafeMinus(icloseprice[pos], SafeMultiply(reversal, box[pos])) : Upt);
      double Dnt = SafePlus(tema, SafeMultiply(thsreversal, box[pos]));
      Dnt = (SafeLess(Dnt, SafePlus(icloseprice[pos], SafeMultiply(reversal, box[pos]))) ? SafePlus(icloseprice[pos], SafeMultiply(reversal, box[pos])) : Dnt);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(waitit, pos, Nz(waitit[pos + 1]), waitit_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(mtrend, pos, Nz(mtrend[pos + 1], 1), mtrend_DEFAULT_VALUE);
      change13Source.SetValue(pos, icloseprice[pos]);
      double change13Value;
      if (!change13.GetValue(pos, change13Value)) { change13Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(TrendUp, pos, (NumberToBool(change13Value) && (waitit[pos] == 0) ? (SafeGreater(icloseprice[pos + 1], TrendUp[pos + 1]) ? SafeMathMax(Upt, TrendUp[pos + 1]) : Upt) : Nz(TrendUp[pos + 1])), TrendUp_DEFAULT_VALUE);
      change14Source.SetValue(pos, TrendUp[pos]);
      double change14Value;
      if (!change14.GetValue(pos, change14Value)) { change14Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(TrendUp, pos, ((mtrend[pos] == 1) && SafeLess(change14Value, 0) ? Nz(TrendUp[pos + 1]) : TrendUp[pos]), TrendUp_DEFAULT_VALUE);
      change15Source.SetValue(pos, icloseprice[pos]);
      double change15Value;
      if (!change15.GetValue(pos, change15Value)) { change15Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(TrendDown, pos, (NumberToBool(change15Value) && (waitit[pos] == 0) ? (SafeLess(icloseprice[pos + 1], TrendDown[pos + 1]) ? SafeMathMin(Dnt, TrendDown[pos + 1]) : Dnt) : TrendDown[pos + 1]), TrendDown_DEFAULT_VALUE);
      change16Source.SetValue(pos, TrendDown[pos]);
      double change16Value;
      if (!change16.GetValue(pos, change16Value)) { change16Value = EMPTY_VALUE; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(TrendDown, pos, ((mtrend[pos] == (-1)) && SafeGreater(change16Value, 0) ? Nz(TrendDown[pos + 1]) : TrendDown[pos]), TrendDown_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(mtrend, pos, ((waitit[pos] == 0) ? (SafeGreater(icloseprice[pos], TrendDown[pos + 1]) ? 1 : (SafeLess(icloseprice[pos], TrendUp[pos + 1]) ? (-1) : mtrend[pos])) : mtrend[pos]), mtrend_DEFAULT_VALUE);
      change17Source.SetValue(pos, mtrend[pos]);
      double change17Value;
      if (!change17.GetValue(pos, change17Value)) { change17Value = EMPTY_VALUE; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if ((change17Value != 0) && (waitit[pos] == 0) && (Nz(waitit[pos + 2]) == 0))
      {
         SetStream(waitit, pos, 1, waitit_DEFAULT_VALUE);
      }
      else
      {
         SetStream(waitit, pos, ((waitit[pos] != 0) ? waitit[pos] + 1 : waitit[pos]), waitit_DEFAULT_VALUE);
      }
      if ((waitit[pos] > 0))
      {
         if (pos + 1 > (rates_total - 1)) { continue; }
         SetStream(mtrend, pos, Nz(mtrend[pos + 1]), mtrend_DEFAULT_VALUE);
      }
      if ((waitit[pos] > barcountwhip))
      {
         if ((mtrend[pos] == 1))
         {
            if (SafeGE(icloseprice[pos], SafePlus(TrendUp[pos], SafeMultiply(thsreversal2, box[pos]))))
            {
               SetStream(waitit, pos, 0, waitit_DEFAULT_VALUE);
            }
            if (SafeLE(icloseprice[pos], SafeMinus(TrendUp[pos], SafeMultiply(thsreversal2, box[pos]))))
            {
               SetStream(waitit, pos, 0, waitit_DEFAULT_VALUE);
               SetStream(mtrend, pos, (-1), mtrend_DEFAULT_VALUE);
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               SetStream(TrendDown, pos, (SafeLess(icloseprice[pos + 1], TrendDown[pos + 1]) ? SafeMathMin(Dnt, TrendDown[pos + 1]) : Dnt), TrendDown_DEFAULT_VALUE);
            }
         }
         else
         {
            if (SafeLE(icloseprice[pos], SafeMinus(TrendDown[pos], SafeMultiply(thsreversal2, box[pos]))))
            {
               SetStream(waitit, pos, 0, waitit_DEFAULT_VALUE);
            }
            if (SafeGE(icloseprice[pos], SafePlus(TrendDown[pos], SafeMultiply(thsreversal2, box[pos]))))
            {
               SetStream(waitit, pos, 0, waitit_DEFAULT_VALUE);
               SetStream(mtrend, pos, 1, mtrend_DEFAULT_VALUE);
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               SetStream(TrendUp, pos, (SafeGreater(icloseprice[pos + 1], TrendUp[pos + 1]) ? SafeMathMax(Upt, TrendUp[pos + 1]) : Upt), TrendUp_DEFAULT_VALUE);
            }
         }
      }
      SetStream(Tsl, pos, ((mtrend[pos] == 1) ? TrendUp[pos] : TrendDown[pos]), Tsl_DEFAULT_VALUE);
      double Tsl2 = ((mtrend[pos] == 1) ? SafePlus(TrendUp[pos], SafeMultiply(thsreversal, box[pos])) : SafeMinus(TrendDown[pos], SafeMultiply(thsreversal, box[pos])));
      Tsl2 = ((((mtrend[pos] == 1) && SafeGreater(Tsl2, icloseprice[pos])) || ((mtrend[pos] == (-1)) && SafeLess(Tsl2, icloseprice[pos]))) ? icloseprice[pos] : Tsl2);
      Tsl2 = (SafeLess(Tsl2, 0) ? 0 : Tsl2);
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      uint trendcol = ((mtrend[pos] == 1) && (Nz(mtrend[pos + 1]) == 1) ? ((waitit[pos] == 0) ? Green : Silver) : ((mtrend[pos] == (-1)) && (Nz(mtrend[pos + 1]) == (-1)) ? ((waitit[pos] == 0) ? Red : Silver) : EMPTY_VALUE));
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
plot62.SetByColor(Tsl[pos], pos, (showtrend && (Tsl[pos] != 0) && (Nz(Tsl[pos + 1]) != 0) ? trendcol : EMPTY_VALUE));
      double trendline = plot66.SetByColor(Tsl[pos], pos, (showtrend && (Tsl[pos] != 0) && (Nz(Tsl[pos + 1]) != 0) ? trendcol : EMPTY_VALUE));
;
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      uint trcol = (showtrend && showtrhold && (mtrend[pos] == Nz(mtrend[pos + 1])) && (Tsl[pos] != 0) && (Nz(Tsl[pos + 1]) != 0) ? ((waitit[pos] == 0) ? ((mtrend[pos] == 1) ? AddTransparency(Lime, 80) : AddTransparency(Red, 80)) : AddTransparency(Yellow, 80)) : AddTransparency(White, 100));
      if (pos + 1 > (rates_total - 1)) { continue; }
      uint trcol1 = (showtrend && showtrhold && (Tsl[pos] != 0) && (Nz(Tsl[pos + 1]) != 0) ? AddTransparency(Gray, 30) : AddTransparency(White, 100));
      plot70[pos] = Tsl2;
      double trline = plot70[pos];
      color plot71_color = ((waitit[pos] > barcountwhip) ? Maroon : EMPTY_VALUE);
      if (plot71_color != EMPTY_VALUE) { plot71[pos] = ((waitit[pos] > barcountwhip) ? ((mtrend[pos] == 1) ? SafeMinus(TrendUp[pos], SafeMultiply(thsreversal2, box[pos])) : SafePlus(TrendDown[pos], SafeMultiply(thsreversal2, box[pos]))) : EMPTY_VALUE); }
      else { plot71[pos] = EMPTY_VALUE; }
      change18Source.SetValue(pos, mtrend[pos]);
      double change18Value;
      if (!change18.GetValue(pos, change18Value)) { change18Value = EMPTY_VALUE; }
      change19Source.SetValue(pos, mtrend[pos]);
      double change19Value;
      if (!change19.GetValue(pos, change19Value)) { change19Value = EMPTY_VALUE; }
      change20Source.SetValue(pos, mtrend[pos]);
      double change20Value;
      if (!change20.GetValue(pos, change20Value)) { change20Value = EMPTY_VALUE; }
      plot72.SetByColor(((SafeGreater(change18Value, 0) && showtrend || SafeLess(change19Value, 0) && showtrend) ? Tsl[pos] : EMPTY_VALUE), pos, (SafeGreater(change20Value, 0) && showtrend ? Green : Red));
      change21Source.SetValue(pos, mtrend[pos]);
      double change21Value;
      if (!change21.GetValue(pos, change21Value)) { change21Value = EMPTY_VALUE; }
      if (SafeGreater(change21Value, 0)) { _signaler.SendNotifications("Main Trend is Up", "Main Trend is Up"); }
      change22Source.SetValue(pos, mtrend[pos]);
      double change22Value;
      if (!change22.GetValue(pos, change22Value)) { change22Value = EMPTY_VALUE; }
      if (SafeLess(change22Value, 0)) { _signaler.SendNotifications("Main Trend is Down", "Main Trend is Down"); }
      change23Source.SetValue(pos, trend[pos]);
      double change23Value;
      if (!change23.GetValue(pos, change23Value)) { change23Value = EMPTY_VALUE; }
      if (SafeGreater(change23Value, 0)) { _signaler.SendNotifications("Renko Trend is Up", "Renko Trend is Up"); }
      change24Source.SetValue(pos, trend[pos]);
      double change24Value;
      if (!change24.GetValue(pos, change24Value)) { change24Value = EMPTY_VALUE; }
      if (SafeLess(change24Value, 0)) { _signaler.SendNotifications("Renko Trend is Down", "Renko Trend is Down"); }
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