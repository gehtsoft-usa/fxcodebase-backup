// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75290

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
#property indicator_buffers 16
#property indicator_label9 "Close Series"
#property indicator_type9 DRAW_LINE
#property indicator_color9 Green
#property indicator_style9 STYLE_SOLID
#property indicator_width9 2
#property indicator_label10 "Close Series"
#property indicator_type10 DRAW_LINE
#property indicator_color10 Red
#property indicator_style10 STYLE_SOLID
#property indicator_width10 2
#property indicator_label11 "Close Series"
#property indicator_type11 DRAW_LINE
#property indicator_color11 Green
#property indicator_style11 STYLE_SOLID
#property indicator_width11 2
#property indicator_label12 "Close Series"
#property indicator_type12 DRAW_LINE
#property indicator_color12 Red
#property indicator_style12 STYLE_SOLID
#property indicator_width12 2
#property indicator_label13 "Open Series"
#property indicator_type13 DRAW_LINE
#property indicator_color13 Green
#property indicator_style13 STYLE_SOLID
#property indicator_width13 2
#property indicator_label14 "Open Series"
#property indicator_type14 DRAW_LINE
#property indicator_color14 Red
#property indicator_style14 STYLE_SOLID
#property indicator_width14 2
#property indicator_label15 "Open Series"
#property indicator_type15 DRAW_LINE
#property indicator_color15 Green
#property indicator_style15 STYLE_SOLID
#property indicator_width15 2
#property indicator_label16 "Open Series"
#property indicator_type16 DRAW_LINE
#property indicator_color16 Red
#property indicator_style16 STYLE_SOLID
#property indicator_width16 2

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

// WMA on stream v1.2

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

      _buffer[bufferIndex] = (current - last) * _k + last;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
// VWMA on stream v1.2


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

#ifndef VwmaOnStream_IMP
#define VwmaOnStream_IMP

class VwmaOnStream : public AOnStream
{
   int _length;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   VwmaOnStream(string symbol, ENUM_TIMEFRAMES timeframe, IStream *source, const int length)
      :AOnStream(source)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = iBars(_symbol, _timeframe);
      if (period > totalBars - _length)
         return false;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      long sumw = iVolume(_symbol, _timeframe, period);
      double sum = sumw * price;
      for (int k = 1; k < _length; k++)
      {
         long weight = Volume[period + k];
         sumw += weight;
         if (!_source.GetValue(period + k, price))
            return false;
         sum += weight * price;  
      }
      val = sum / sumw;
      return true;
   }
};

class VwmaWithVolumeStreamOnStream : public AOnStream
{
   int _length;
   IIntStream* _volume;
public:
   VwmaWithVolumeStreamOnStream(IStream *source, IIntStream* volume, const int length)
      :AOnStream(source)
   {
      _volume = volume;
      _volume.AddRef();
      _length = length;
   }
   
   ~VwmaWithVolumeStreamOnStream()
   {
      _volume.Release();
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _volume.Size();
      if (period > totalBars - _length)
         return false;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      int sumw;
      if (!_volume.GetValue(period, sumw))
      {
         return false;
      }
      double sum = sumw * price;
      for (int k = 1; k < _length; k++)
      {
         int weight;
         if (!_volume.GetValue(period + k, weight))
         {
            return false;
         }
         sumw += weight;
         if (!_source.GetValue(period + k, price))
            return false;
         sum += weight * price;  
      }
      val = sum / sumw;
      return true;
   }
};

class VwmaOnStreamFactory
{
public:
   static IStream* Create(string symbol, ENUM_TIMEFRAMES timeframe, IStream *source, const int length)
   {
      return new VwmaOnStream(symbol, timeframe, source, length);
   }
   
   static IStream* Create(IStream *source, IIntStream *volume, const int length)
   {
      return new VwmaWithVolumeStreamOnStream(source, volume, length);
   }
};

#endif


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

datetime Timestamp(int year, int month, int day, int hour, int minute, int second)
{
   MqlDateTime time;
   time.year = year;
   time.mon = month;
   time.day = day;
   time.hour = hour;
   time.min = minute;
   time.sec = second;
   return StructToTime(time);
}

class PineScriptTime
{
public:
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

class Runtime
{
public:
   static void Error(string message)
   {
      Print(message);
      ExpertRemove();
   }
};
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
   virtual bool GetValue(const int period, int &val) = 0;
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
   bool GetValue(const int period, int &val)
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

// Pine-script like strategy functions
// v1.0

#ifndef PineStrategy_IMPL
#define PineStrategy_IMPL



class PineStrategy
{
public:
   static void Entry(Signaler* signaler, string id, bool longDirection)
   {
      signaler.SendNotifications(id);
   }
   
   static void Exit(Signaler* signaler, string id, string comment)
   {
      string message = id;
      if (comment != NULL)
      {
         message = message + ": " + comment;
      }
      signaler.SendNotifications(message);
   }
   
   static double GetPositionSize()
   {
      return 0;
   }
   
   static void Close(Signaler* signaler, string id, bool when)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static void Cancel(Signaler* signaler, string id, bool when)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static void CloseAll(Signaler* signaler, bool when, string id)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static double Equity()
   {
      return 0;
   }
};

#endif 
input bool param1 = true; // Use Alternate Resolution?
input int param2 = 6; // Multiplier for Alernate Resolution
input string param3 = "ZEMA"; // MA Type: 
input int param4 = 8; // MA Period
input bool param5 = false; // Show coloured Bars to indicate Trend?
input string param6 = "BOTH"; // What trades should be taken : 
input int param7 = 0; // Initial Stop Loss Points (zero to disable)
input int param8 = 0; // Initial Target Profit Points (zero for disable)
input int param9 = 2018; // Backtest Start Year
input int param10 = 1; // Backtest Start Month
input int param11 = 1; // Backtest Start Day
input int param12 = 9999; // Backtest Stop Year
input int param13 = 12; // Backtest Stop Month
input int param14 = 31; // Backtest Stop Day
input int bars_limit = 100000; // Bars limit
Signaler* _signaler;
int useRes;
int intRs_;
string basisType;
int basisLen;
int scolor;
string tradeType;
class variant_smoothed_fS_iStream
{
   IStream* src;
   int len;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   double v5[];
   double v5_DEFAULT_VALUE;
   bool _initialized;
public:
   variant_smoothed_fS_iStream(IStream* src, int len)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.len = len;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, len);
   }
   ~variant_smoothed_fS_iStream()
   {
      src.Release();
      sma1Source.Release();
      sma1.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, v5);
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
         v5_DEFAULT_VALUE = 0.0;
         ArrayInitialize(v5, v5_DEFAULT_VALUE);
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      sma1Source.SetValue(pos, srcValue);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double sma_1 = sma1Value;
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(v5, pos, (((v5[pos + 1]) == EMPTY_VALUE) ? sma_1 : SafeDivide((SafePlus(SafeMultiply(v5[pos + 1], (len - 1)), srcValue)), len)), v5_DEFAULT_VALUE);
      __out1 = v5[pos];
      return true;
   }
};
class variant_doubleema_fS_iStream
{
   IStream* src;
   int len;
   FloatStream* ema2Source;
   EMAOnStream* ema2;
   FloatStream* ema3Source;
   EMAOnStream* ema3;
   bool _initialized;
public:
   variant_doubleema_fS_iStream(IStream* src, int len)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.len = len;
      ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema2 = new EMAOnStream(ema2Source, len);
      ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema3 = new EMAOnStream(ema3Source, len);
   }
   ~variant_doubleema_fS_iStream()
   {
      src.Release();
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
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         ema2Source.Init();
         ema3Source.Init();
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      ema2Source.SetValue(pos, srcValue);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      double v2 = ema2Value;
      ema3Source.SetValue(pos, v2);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
      double v6 = SafeMinus(SafeMultiply(2, v2), ema3Value);
      __out1 = v6;
      return true;
   }
};
class variant_tripleema_fS_iStream
{
   IStream* src;
   int len;
   FloatStream* ema4Source;
   EMAOnStream* ema4;
   FloatStream* ema5Source;
   EMAOnStream* ema5;
   FloatStream* ema6Source;
   EMAOnStream* ema6;
   FloatStream* ema7Source;
   EMAOnStream* ema7;
   bool _initialized;
public:
   variant_tripleema_fS_iStream(IStream* src, int len)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.len = len;
      ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema4 = new EMAOnStream(ema4Source, len);
      ema5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema5 = new EMAOnStream(ema5Source, len);
      ema7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema7 = new EMAOnStream(ema7Source, len);
      ema6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema6 = new EMAOnStream(ema6Source, len);
   }
   ~variant_tripleema_fS_iStream()
   {
      src.Release();
      ema4Source.Release();
      ema4.Release();
      ema5Source.Release();
      ema5.Release();
      ema6Source.Release();
      ema6.Release();
      ema7Source.Release();
      ema7.Release();
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
         ema4Source.Init();
         ema5Source.Init();
         ema7Source.Init();
         ema6Source.Init();
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      ema4Source.SetValue(pos, srcValue);
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
      double v2 = ema4Value;
      ema5Source.SetValue(pos, v2);
      double ema5Value;
      if (!ema5.GetValue(pos, ema5Value)) { ema5Value = EMPTY_VALUE; }
      ema7Source.SetValue(pos, v2);
      double ema7Value;
      if (!ema7.GetValue(pos, ema7Value)) { ema7Value = EMPTY_VALUE; }
      ema6Source.SetValue(pos, ema7Value);
      double ema6Value;
      if (!ema6.GetValue(pos, ema6Value)) { ema6Value = EMPTY_VALUE; }
      double v7 = SafePlus(SafeMultiply(3, (SafeMinus(v2, ema5Value))), ema6Value);
      __out1 = v7;
      return true;
   }
};
class variant_supersmoother_fS_iStream
{
   IStream* src;
   int len;
   double v9[];
   double v9_DEFAULT_VALUE;
   bool _initialized;
public:
   variant_supersmoother_fS_iStream(IStream* src, int len)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.len = len;
   }
   ~variant_supersmoother_fS_iStream()
   {
      src.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, v9);
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
         v9_DEFAULT_VALUE = 0.0;
         ArrayInitialize(v9, v9_DEFAULT_VALUE);
         _initialized = true;
      }
      double a1 = MathExp(SafeDivide((-1.414) * 3.14159, len));
      double b1 = SafeMultiply(SafeMultiply(2, a1), MathCos(SafeDivide(1.414 * 3.14159, len)));
      double c2 = b1;
      double c3 = SafeMultiply(InvertSign(a1), a1);
      double c1 = SafeMinus(SafeMinus(1, c2), c3);
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      double srcValue_1;
      if (!src.GetValue(pos + 1, srcValue_1)) { srcValue_1 = EMPTY_VALUE; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 2 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(v9, pos, SafePlus(SafeDivide(SafeMultiply(c1, (SafePlus(srcValue, Nz(srcValue_1)))), 2), SafePlus(SafeMultiply(c2, Nz(v9[pos + 1])), SafeMultiply(c3, Nz(v9[pos + 2])))), v9_DEFAULT_VALUE);
      __out1 = v9[pos];
      return true;
   }
};
class variant_zerolagema_fS_iStream
{
   IStream* src;
   int len;
   FloatStream* ema8Source;
   EMAOnStream* ema8;
   bool _initialized;
public:
   variant_zerolagema_fS_iStream(IStream* src, int len)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.len = len;
      ema8Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema8 = new EMAOnStream(ema8Source, len);
   }
   ~variant_zerolagema_fS_iStream()
   {
      src.Release();
      ema8Source.Release();
      ema8.Release();
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
         ema8Source.Init();
         _initialized = true;
      }
      int lag = SafeDivide((len - 1), 2);
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      double srcValue_lag;
      if (!src.GetValue(pos + lag, srcValue_lag)) { srcValue_lag = EMPTY_VALUE; }
      double emaSrc = SafeMinus(srcValue + srcValue, srcValue_lag);
      ema8Source.SetValue(pos, emaSrc);
      double ema8Value;
      if (!ema8.GetValue(pos, ema8Value)) { ema8Value = EMPTY_VALUE; }
      double v10 = ema8Value;
      __out1 = v10;
      return true;
   }
};
class variant_s_fS_iStream
{
   string type;
   IStream* src;
   int len;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* wma1Source;
   WMAOnStream* wma1;
   FloatStream* vwma1Source;
   VwmaOnStream* vwma1;
   FloatStream* variant_smoothed_fS_i1_param1;
   variant_smoothed_fS_iStream* variant_smoothed_fS_i1;
   FloatStream* variant_doubleema_fS_i2_param1;
   variant_doubleema_fS_iStream* variant_doubleema_fS_i2;
   FloatStream* variant_tripleema_fS_i3_param1;
   variant_tripleema_fS_iStream* variant_tripleema_fS_i3;
   FloatStream* wma2Source;
   WMAOnStream* wma2;
   FloatStream* wma3Source;
   WMAOnStream* wma3;
   FloatStream* wma4Source;
   WMAOnStream* wma4;
   FloatStream* variant_supersmoother_fS_i4_param1;
   variant_supersmoother_fS_iStream* variant_supersmoother_fS_i4;
   FloatStream* variant_zerolagema_fS_i5_param1;
   variant_zerolagema_fS_iStream* variant_zerolagema_fS_i5;
   FloatStream* sma2Source;
   SmaOnStream* sma2;
   FloatStream* sma3Source;
   SmaOnStream* sma3;
   FloatStream* sma4Source;
   SmaOnStream* sma4;
   bool _initialized;
public:
   variant_s_fS_iStream(string type, IStream* src, int len)
   {
      _initialized = false;
      this.type = type;
      this.src = src;
      src.AddRef();
      this.len = len;
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, len);
      wma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma1 = new WMAOnStream(wma1Source, len);
      vwma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      vwma1 = new VwmaOnStream(_Symbol, (ENUM_TIMEFRAMES)_Period, vwma1Source, len);
      wma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma2 = new WMAOnStream(wma2Source, SafeDivide(len, 2));
      wma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma3 = new WMAOnStream(wma3Source, len);
      wma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma4 = new WMAOnStream(wma4Source, SafeMathRound(MathSqrt(len)));
      sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma2 = new SmaOnStream(sma2Source, len);
      sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma3 = new SmaOnStream(sma3Source, len);
      sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma4 = new SmaOnStream(sma4Source, len);
   }
   ~variant_s_fS_iStream()
   {
      src.Release();
      ema1Source.Release();
      ema1.Release();
      wma1Source.Release();
      wma1.Release();
      vwma1Source.Release();
      vwma1.Release();
      variant_smoothed_fS_i1_param1.Release();
      delete variant_smoothed_fS_i1;
      variant_doubleema_fS_i2_param1.Release();
      delete variant_doubleema_fS_i2;
      variant_tripleema_fS_i3_param1.Release();
      delete variant_tripleema_fS_i3;
      wma2Source.Release();
      wma2.Release();
      wma3Source.Release();
      wma3.Release();
      wma4Source.Release();
      wma4.Release();
      variant_supersmoother_fS_i4_param1.Release();
      delete variant_supersmoother_fS_i4;
      variant_zerolagema_fS_i5_param1.Release();
      delete variant_zerolagema_fS_i5;
      sma2Source.Release();
      sma2.Release();
      sma3Source.Release();
      sma3.Release();
      sma4Source.Release();
      sma4.Release();
   }
   int Init(int id)
   {
      variant_smoothed_fS_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      variant_smoothed_fS_i1 = new variant_smoothed_fS_iStream(variant_smoothed_fS_i1_param1, len);
      id = variant_smoothed_fS_i1.Init(id);
      variant_doubleema_fS_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      variant_doubleema_fS_i2 = new variant_doubleema_fS_iStream(variant_doubleema_fS_i2_param1, len);
      id = variant_doubleema_fS_i2.Init(id);
      variant_tripleema_fS_i3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      variant_tripleema_fS_i3 = new variant_tripleema_fS_iStream(variant_tripleema_fS_i3_param1, len);
      id = variant_tripleema_fS_i3.Init(id);
      variant_supersmoother_fS_i4_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      variant_supersmoother_fS_i4 = new variant_supersmoother_fS_iStream(variant_supersmoother_fS_i4_param1, len);
      id = variant_supersmoother_fS_i4.Init(id);
      variant_zerolagema_fS_i5_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      variant_zerolagema_fS_i5 = new variant_zerolagema_fS_iStream(variant_zerolagema_fS_i5_param1, len);
      id = variant_zerolagema_fS_i5.Init(id);
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
         ema1Source.Init();
         wma1Source.Init();
         vwma1Source.Init();
         variant_smoothed_fS_i1_param1.Init();
         variant_smoothed_fS_i1.Clear();
         variant_doubleema_fS_i2_param1.Init();
         variant_doubleema_fS_i2.Clear();
         variant_tripleema_fS_i3_param1.Init();
         variant_tripleema_fS_i3.Clear();
         wma2Source.Init();
         wma3Source.Init();
         wma4Source.Init();
         variant_supersmoother_fS_i4_param1.Init();
         variant_supersmoother_fS_i4.Clear();
         variant_zerolagema_fS_i5_param1.Init();
         variant_zerolagema_fS_i5.Clear();
         sma2Source.Init();
         sma3Source.Init();
         sma4Source.Init();
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      ema1Source.SetValue(pos, srcValue);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      double ema_1 = ema1Value;
      wma1Source.SetValue(pos, srcValue);
      double wma1Value;
      if (!wma1.GetValue(pos, wma1Value)) { wma1Value = EMPTY_VALUE; }
      double wma_1 = wma1Value;
      vwma1Source.SetValue(pos, srcValue);
      double vwma1Value;
      if (!vwma1.GetValue(pos, vwma1Value)) { vwma1Value = EMPTY_VALUE; }
      double vwma_1 = vwma1Value;
      variant_smoothed_fS_i1_param1.SetValue(pos, srcValue);
      double variant_smoothed_fS_i1Value;
      if (!variant_smoothed_fS_i1.GetValue(pos, variant_smoothed_fS_i1Value)) { variant_smoothed_fS_i1Value = EMPTY_VALUE; }
      double variant_smoothed__1 = variant_smoothed_fS_i1Value;
      variant_doubleema_fS_i2_param1.SetValue(pos, srcValue);
      double variant_doubleema_fS_i2Value;
      if (!variant_doubleema_fS_i2.GetValue(pos, variant_doubleema_fS_i2Value)) { variant_doubleema_fS_i2Value = EMPTY_VALUE; }
      double variant_doubleema__1 = variant_doubleema_fS_i2Value;
      variant_tripleema_fS_i3_param1.SetValue(pos, srcValue);
      double variant_tripleema_fS_i3Value;
      if (!variant_tripleema_fS_i3.GetValue(pos, variant_tripleema_fS_i3Value)) { variant_tripleema_fS_i3Value = EMPTY_VALUE; }
      double variant_tripleema__1 = variant_tripleema_fS_i3Value;
      wma2Source.SetValue(pos, srcValue);
      double wma2Value;
      if (!wma2.GetValue(pos, wma2Value)) { wma2Value = EMPTY_VALUE; }
      double wma_2 = wma2Value;
      wma3Source.SetValue(pos, srcValue);
      double wma3Value;
      if (!wma3.GetValue(pos, wma3Value)) { wma3Value = EMPTY_VALUE; }
      double wma_3 = wma3Value;
      wma4Source.SetValue(pos, SafeMinus(SafeMultiply(2, wma_2), wma_3));
      double wma4Value;
      if (!wma4.GetValue(pos, wma4Value)) { wma4Value = EMPTY_VALUE; }
      double wma_4 = wma4Value;
      variant_supersmoother_fS_i4_param1.SetValue(pos, srcValue);
      double variant_supersmoother_fS_i4Value;
      if (!variant_supersmoother_fS_i4.GetValue(pos, variant_supersmoother_fS_i4Value)) { variant_supersmoother_fS_i4Value = EMPTY_VALUE; }
      double variant_supersmoother__1 = variant_supersmoother_fS_i4Value;
      variant_zerolagema_fS_i5_param1.SetValue(pos, srcValue);
      double variant_zerolagema_fS_i5Value;
      if (!variant_zerolagema_fS_i5.GetValue(pos, variant_zerolagema_fS_i5Value)) { variant_zerolagema_fS_i5Value = EMPTY_VALUE; }
      double variant_zerolagema__1 = variant_zerolagema_fS_i5Value;
      sma2Source.SetValue(pos, srcValue);
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
      double sma_1 = sma2Value;
      sma3Source.SetValue(pos, sma_1);
      double sma3Value;
      if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
      double sma_2 = sma3Value;
      sma4Source.SetValue(pos, srcValue);
      double sma4Value;
      if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
      double sma_3 = sma4Value;
      __out1 = ((type == "EMA") ? ema_1 : ((type == "WMA") ? wma_1 : ((type == "VWMA") ? vwma_1 : ((type == "SMMA") ? variant_smoothed__1 : ((type == "DEMA") ? variant_doubleema__1 : ((type == "TEMA") ? variant_tripleema__1 : ((type == "HullMA") ? wma_4 : ((type == "SSMA") ? variant_supersmoother__1 : ((type == "ZEMA") ? variant_zerolagema__1 : ((type == "TMA") ? sma_2 : sma_3))))))))));
      return true;
   }
};
FloatStream* variant_s_fS_i6_param2;
variant_s_fS_iStream* variant_s_fS_i6;
FloatStream* variant_s_fS_i7_param2;
variant_s_fS_iStream* variant_s_fS_i7;
FloatStream* variant_s_fS_i8_param2;
variant_s_fS_iStream* variant_s_fS_i8;
FloatStream* variant_s_fS_i9_param2;
variant_s_fS_iStream* variant_s_fS_i9;
CandleStreams* barcolor1;
ColoredStream* plot9;
ColoredStream* plot11;
ColoredStream* plot13;
ColoredStream* plot15;
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
IBoolStream* crossunder1;
int slPoints;
int tpPoints;
int testStartYear;
int testStartMonth;
int testStartDay;
datetime testPeriodStart;
int testStopYear;
int testStopMonth;
int testStopDay;
datetime testPeriodStop;
class testPeriodStream
{
   bool _initialized;
public:
   testPeriodStream()
   {
      _initialized = false;
   }
   ~testPeriodStream()
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
      __out1 = (SafeGE(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), testPeriodStart) && SafeLE(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), testPeriodStop) ? true : false);
      return true;
   }
};
testPeriodStream* testPeriod10;

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
   IndicatorBuffers(28);
   int id = 0;
   useRes = param1;
   intRs_ = param2;
   basisType = param3;
   basisLen = param4;
   scolor = param5;
   tradeType = param6;
   barcolor1 = new CandleStreams();
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id, 0x00FF00);
   id = barcolor1.RegisterStreams(id, 0x0000FF);
   plot9 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot9.RegisterStream(id, Green);
   id = plot9.RegisterStream(id, Red);
   plot11 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot11.RegisterStream(id, Green);
   id = plot11.RegisterStream(id, Red);
   plot13 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot13.RegisterStream(id, Green);
   id = plot13.RegisterStream(id, Red);
   plot15 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot15.RegisterStream(id, Green);
   id = plot15.RegisterStream(id, Red);
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   slPoints = param7;
   tpPoints = param8;
   testStartYear = param9;
   testStartMonth = param10;
   testStartDay = param11;
   testStopYear = param12;
   testStopMonth = param13;
   testStopDay = param14;
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("OCC Strategy NRP");
   IndicatorShortName("Open Close Cross Strategy NoRepaint Version by JustUncleL");
   variant_s_fS_i6_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   variant_s_fS_i6 = new variant_s_fS_iStream(basisType, variant_s_fS_i6_param2, basisLen);
   id = variant_s_fS_i6.Init(id);
   variant_s_fS_i7_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   variant_s_fS_i7 = new variant_s_fS_iStream(basisType, variant_s_fS_i7_param2, basisLen);
   id = variant_s_fS_i7.Init(id);
   variant_s_fS_i8_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   int intRes = (useRes ? intRs_ : 1);
   variant_s_fS_i8 = new variant_s_fS_iStream(basisType, variant_s_fS_i8_param2, basisLen * intRes);
   id = variant_s_fS_i8.Init(id);
   variant_s_fS_i9_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   variant_s_fS_i9 = new variant_s_fS_iStream(basisType, variant_s_fS_i9_param2, basisLen * intRes);
   id = variant_s_fS_i9.Init(id);
   id = plot9.RegisterInternalStream(id);
   id = plot11.RegisterInternalStream(id);
   id = plot13.RegisterInternalStream(id);
   id = plot15.RegisterInternalStream(id);
   testPeriod10 = new testPeriodStream();
   id = testPeriod10.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   variant_s_fS_i6_param2.Release();
   delete variant_s_fS_i6;
   variant_s_fS_i7_param2.Release();
   delete variant_s_fS_i7;
   variant_s_fS_i8_param2.Release();
   delete variant_s_fS_i8;
   variant_s_fS_i9_param2.Release();
   delete variant_s_fS_i9;
   delete barcolor1;
   delete plot9;
   delete plot11;
   delete plot13;
   delete plot15;
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   delete testPeriod10;
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
      variant_s_fS_i6_param2.Init();
      variant_s_fS_i6.Clear();
      variant_s_fS_i7_param2.Init();
      variant_s_fS_i7.Clear();
      variant_s_fS_i8_param2.Init();
      variant_s_fS_i8.Clear();
      variant_s_fS_i9_param2.Init();
      variant_s_fS_i9.Clear();
      barcolor1.Init();
      plot9.Init(EMPTY_VALUE);
      plot11.Init(EMPTY_VALUE);
      plot13.Init(EMPTY_VALUE);
      plot15.Init(EMPTY_VALUE);
      crossover1X.Init();
      crossover1Y.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      testPeriod10.Clear();
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
      int intRes = (useRes ? intRs_ : 1);
      uint green100 = 0x008000;
      uint lime100 = 0x00FF00;
      uint red100 = 0x0000FF;
      uint blue100 = 0xFF0000;
      uint aqua100 = 0xFFFF00;
      uint darkred100 = 0x00008B;
      uint gray100 = 0x808080;
      variant_s_fS_i6_param2.SetValue(pos, close[pos]);
      double variant_s_fS_i6Value;
      if (!variant_s_fS_i6.GetValue(pos, variant_s_fS_i6Value)) { variant_s_fS_i6Value = EMPTY_VALUE; }
      double closeSeries = variant_s_fS_i6Value;
      variant_s_fS_i7_param2.SetValue(pos, open[pos]);
      double variant_s_fS_i7Value;
      if (!variant_s_fS_i7.GetValue(pos, variant_s_fS_i7Value)) { variant_s_fS_i7Value = EMPTY_VALUE; }
      double openSeries = variant_s_fS_i7Value;
      variant_s_fS_i8_param2.SetValue(pos, close[pos]);
      double variant_s_fS_i8Value;
      if (!variant_s_fS_i8.GetValue(pos, variant_s_fS_i8Value)) { variant_s_fS_i8Value = EMPTY_VALUE; }
      double closeSeriesAlt = variant_s_fS_i8Value;
      variant_s_fS_i9_param2.SetValue(pos, open[pos]);
      double variant_s_fS_i9Value;
      if (!variant_s_fS_i9.GetValue(pos, variant_s_fS_i9Value)) { variant_s_fS_i9Value = EMPTY_VALUE; }
      double openSeriesAlt = variant_s_fS_i9Value;
      uint trendColour = (SafeGreater(closeSeriesAlt, openSeriesAlt) ? Green : Red);
      uint bcolour = (SafeGreater(closeSeries, openSeriesAlt) ? lime100 : red100);
      color barcolor1_color = (scolor ? bcolour : EMPTY_VALUE);
      if (barcolor1_color != EMPTY_VALUE)
      {
         barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor1_color);
      }
      else
      {
         barcolor1.Clear(pos);
      }
plot9.SetByColor(closeSeriesAlt, pos, trendColour);
      double closeP = plot11.SetByColor(closeSeriesAlt, pos, trendColour);
;
plot13.SetByColor(openSeriesAlt, pos, trendColour);
      double openP = plot15.SetByColor(openSeriesAlt, pos, trendColour);
;
      crossover1X.SetValue(pos, closeSeriesAlt);
      crossover1Y.SetValue(pos, openSeriesAlt);
      int crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { crossover1Value = (-1); }
      int xlong = crossover1Value;
      crossunder1X.SetValue(pos, closeSeriesAlt);
      crossunder1Y.SetValue(pos, openSeriesAlt);
      int crossunder1Value;
      if (!crossunder1.GetValue(pos, crossunder1Value)) { crossunder1Value = (-1); }
      int xshort = crossunder1Value;
      int longCond = xlong;
      int shortCond = xshort;
      testPeriodStart = Timestamp(testStartYear, testStartMonth, testStartDay, 0, 0, 0);
      testPeriodStop = Timestamp(testStopYear, testStopMonth, testStopDay, 0, 0, 0);
      int TP = ((tpPoints > 0) ? tpPoints : EMPTY_VALUE);
      int SL = ((slPoints > 0) ? slPoints : EMPTY_VALUE);
      int testPeriod10Value;
      if (!testPeriod10.GetValue(pos, testPeriod10Value)) { testPeriod10Value = (-1); }
      if (testPeriod10Value && (tradeType != "NONE"))
      {
         PineStrategy::Entry(_signaler, "long", true);
         PineStrategy::Entry(_signaler, "short", false);
         PineStrategy::Close(_signaler, "long", (shortCond == true) && (tradeType == "LONG"));
         PineStrategy::Close(_signaler, "short", (longCond == true) && (tradeType == "SHORT"));
         PineStrategy::Exit(_signaler, "XL", NULL);
         PineStrategy::Exit(_signaler, "XS", NULL);
      }
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