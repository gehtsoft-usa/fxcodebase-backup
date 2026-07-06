//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74598

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
#property indicator_label1 "Zero Line"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Sentiment"
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_color2 0x205e1b
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Sentiment"
#property indicator_type3 DRAW_HISTOGRAM
#property indicator_color3 0x205e1b
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Sentiment"
#property indicator_type4 DRAW_HISTOGRAM
#property indicator_color4 0x6abb66
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Sentiment"
#property indicator_type5 DRAW_HISTOGRAM
#property indicator_color5 0x6abb66
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Sentiment"
#property indicator_type6 DRAW_HISTOGRAM
#property indicator_color6 0x4a4cdc
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Sentiment"
#property indicator_type7 DRAW_HISTOGRAM
#property indicator_color7 0x4a4cdc
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Sentiment"
#property indicator_type8 DRAW_HISTOGRAM
#property indicator_color8 0x988eef
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Sentiment"
#property indicator_type9 DRAW_HISTOGRAM
#property indicator_color9 0x988eef
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Supply Energy"
#property indicator_type10 DRAW_ARROW
#property indicator_style10 STYLE_SOLID
#property indicator_width10 2
#property indicator_label11 "Demand Energy"
#property indicator_type11 DRAW_ARROW
#property indicator_style11 STYLE_SOLID
#property indicator_width11 2
#property indicator_label12 "VADER"
#property indicator_type12 DRAW_NONE
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_label13 "Signal"
#property indicator_type13 DRAW_LINE
#property indicator_style13 STYLE_SOLID
#property indicator_width13 4
#property indicator_label14 "Signal"
#property indicator_type14 DRAW_LINE
#property indicator_style14 STYLE_SOLID
#property indicator_width14 4

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
// Simple price stream v1.2

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

class SimplePriceStream : public AStream
{
   PriceType _price;
   int _periodShift;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price, int periodShift = 0)
      :AStream(symbol, timeframe)
   {
      _price = __price;
      _periodShift = periodShift;
   }

   bool GetValue(const int period, double &val)
   {
      ResetLastError();
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period + _periodShift);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period + _periodShift) + iLow(_symbol, _timeframe, period + _periodShift) + iClose(_symbol, _timeframe, period + _periodShift) + iOpen(_symbol, _timeframe, period + _periodShift)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period + _periodShift);
               if (iOpen(_symbol, _timeframe, period + _periodShift) > iClose(_symbol, _timeframe, period + _periodShift))
                  val = (iHigh(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period + _periodShift) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period + _periodShift);
            break;
      }
      if (GetLastError() != ERR_NO_ERROR)
      {
         return false;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};


// Highest high stream v1.4

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _source.Release();
   }
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      if (!source.GetValue(period, val))
         return false;

      for (int i = 1; i < loopback; ++i)
      {
         double value;
         if (!source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
      }
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return HighestHighStream::GetValue(period, val, _source, _loopback);
   }
};




// Lowest low stream v1.4

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      if (!source.GetValue(period, val))
         return false;

      for (int i = 1; i < loopback; ++i)
      {
         double value;
         if (!source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
      }
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return LowestLowStream::GetValue(period, val, _source, _loopback);
   }
};

// Stochastics on stream v1.0

class StochOnStream : public AStreamBase
{
   IStream* _closeStream;
   HighestHighStream* _highest;
   LowestLowStream* _lowest;
   int _period;
public:
   StochOnStream(IStream* closeStream, IStream* highStream, IStream* lowStream, int period)
      :AStreamBase()
   {
      _period = period;
      _closeStream = closeStream;
      _closeStream.AddRef();
      _highest = new HighestHighStream(highStream, period);
      _lowest = new LowestLowStream(lowStream, period);
   }

   ~StochOnStream()
   {
      _closeStream.Release();
      _highest.Release();
      _lowest.Release();
   }
   
   virtual int Size()
   {
      return _closeStream.Size();
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double close;
      if (!_closeStream.GetValue(period, close))
      {
         return false;
      }
      double lowest;
      if (!_lowest.GetValue(period, lowest))
      {
         return false;
      }
      double highest;
      if (!_highest.GetValue(period, highest))
      {
         return false;
      }
      double diff = (highest - lowest);
      val = diff == 0 ? 0 : 100 * (close - lowest) / diff;
      return true;
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
#ifndef FixnanStream_IMP
#define FixnanStream_IMP
// Fix NAN stream v1.0



class FixnanStream : public AOnStream
{
   int _maxLookback;
public:
   FixnanStream(IStream *source)
      :AOnStream(source)
   {
      _maxLookback = 1000;
   }

   bool GetValue(const int period, double &val)
   {
      for (int i = 0; i < _maxLookback; ++i)
      {
         if (_source.GetValue(period + i, val))
         {
            return true;
         }
      }

      return false;
   }
};

class FixnanStreamFactory
{
public:
   static IStream* Create(IStream* source)
   {
      return new FixnanStream(source);
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
// Custom integer stream v1.1

#ifndef IntStream_IMPL
#define IntStream_IMPL

// Abstract integer stream v1.0

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

   virtual bool GetValue(const int period, int &val) = 0;
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
input int param1 = 10;
input int param2 = 5; // Average
input string param3 = "WMA"; // DER MA type
input int param4 = 3; // Smooth
input bool param5 = false; // Sentiment
input int param6 = 20; // Length
input string param7 = "Relative"; // Calculation
input int param8 = 20; // Lookback (for Relative)
input int bars_limit = 100000; // Bars limit
int length;
int DER_avg;
string MA_Type;
int smooth;
bool show_senti;
int senti;
string v_calc;
int vlookbk;
FloatStream* stoch1Source;
FloatStream* stoch1High;
FloatStream* stoch1Low;
StochOnStream* stoch1;
HighestHighStream* highest1;
LowestLowStream* lowest1;
FloatStream* change1Source;
ChangeStream* change1;
FloatStream* fixnan1X;
IStream* fixnan1;
class f_derma_fS_i_sStream
{
   IStream* _data;
   int _len;
   string MAOption;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* wma1Source;
   WMAOnStream* wma1;
   bool _initialized;
public:
   f_derma_fS_i_sStream(IStream* _data, int _len, string MAOption)
   {
      _initialized = false;
      this._data = _data;
      _data.AddRef();
      this._len = _len;
      this.MAOption = MAOption;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, _len);
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, _len);
      wma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma1 = new WMAOnStream(wma1Source, _len);
   }
   ~f_derma_fS_i_sStream()
   {
      _data.Release();
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
   bool GetValue(const int pos, double &__out1)
   {
      if (!_initialized)
      {
         sma1Source.Init();
         ema1Source.Init();
         wma1Source.Init();
         _initialized = true;
      }
      double _dataValue;
      if (!_data.GetValue(pos, _dataValue)) { _dataValue = EMPTY_VALUE; }
      sma1Source.SetValue(pos, _dataValue);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      ema1Source.SetValue(pos, _dataValue);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      wma1Source.SetValue(pos, _dataValue);
      double wma1Value;
      if (!wma1.GetValue(pos, wma1Value)) { wma1Value = EMPTY_VALUE; }
      double value = ((MAOption == "SMA") ? sma1Value : ((MAOption == "EMA") ? ema1Value : wma1Value));
      __out1 = value;
      return true;
   }
};
FloatStream* f_derma_fS_i_s1_param1;
f_derma_fS_i_sStream* f_derma_fS_i_s1;
FloatStream* f_derma_fS_i_s2_param1;
f_derma_fS_i_sStream* f_derma_fS_i_s2;
FloatStream* f_derma_fS_i_s3_param1;
f_derma_fS_i_sStream* f_derma_fS_i_s3;
FloatStream* wma2Source;
WMAOnStream* wma2;
FloatStream* wma3Source;
WMAOnStream* wma3;
FloatStream* wma4Source;
WMAOnStream* wma4;
FloatStream* wma5Source;
WMAOnStream* wma5;
FloatStream* wma6Source;
WMAOnStream* wma6;
FloatStream* wma7Source;
WMAOnStream* wma7;
color c_zero;
double plot1[];
double V_senti[];
ColoredStream* plot2;
double plot10[];
double plot11[];
double plot12[];
ColoredStream* plot13;
FloatStream* crossover1X;
IntStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* crossunder1X;
IntStream* crossunder1Y;
IBoolStream* crossunder1;
FloatStream* cross1X;
FloatStream* cross1Y;
IBoolStream* cross1;
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
FloatStream* crossover2X;
FloatStream* crossover2Y;
IBoolStream* crossover2;
FloatStream* crossunder2X;
FloatStream* crossunder2Y;
IBoolStream* crossunder2;

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
   IndicatorBuffers(17);
   int id = 0;
   length = param1;
   DER_avg = param2;
   MA_Type = param3;
   smooth = param4;
   show_senti = param5;
   senti = param6;
   v_calc = param7;
   vlookbk = param8;
   stoch1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch1High = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch1Low = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch1 = new StochOnStream(stoch1Source, stoch1High, stoch1Low, vlookbk);
   highest1 = new HighestHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 2);
   lowest1 = new LowestLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 2);
   change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   fixnan1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan1 = FixnanStreamFactory::Create(fixnan1X);
   wma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma2 = new WMAOnStream(wma2Source, DER_avg);
   wma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma3 = new WMAOnStream(wma3Source, DER_avg);
   wma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma4 = new WMAOnStream(wma4Source, smooth);
   wma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma5 = new WMAOnStream(wma5Source, senti);
   wma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma6 = new WMAOnStream(wma6Source, senti);
   wma7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma7 = new WMAOnStream(wma7Source, smooth);
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, c_zero);
   plot2 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot2.RegisterHistogramStream(id, 0x205e1b);
   id = plot2.RegisterHistogramStream(id, 0x6abb66);
   id = plot2.RegisterHistogramStream(id, 0x4a4cdc);
   id = plot2.RegisterHistogramStream(id, 0x988eef);
   SetIndexBuffer(id, plot10);
   SetIndexArrow(id, 161);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 2, Orange);
   SetIndexBuffer(id, plot11);
   SetIndexArrow(id, 253);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 2, Aqua);
   SetIndexBuffer(id, plot12);
   SetIndexStyle(id++, DRAW_NONE, STYLE_SOLID, 1, Gray);
   plot13 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot13.RegisterStream(id, 0xfc9b35);
   id = plot13.RegisterStream(id, 0x177ff5);
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   cross1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1 = CrossStreamFactory::CreateCross(cross1X, cross1Y);
   crossover2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = CrossStreamFactory::CreateCrossover(crossover2X, crossover2Y);
   crossunder2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2 = CrossStreamFactory::CreateCrossunder(crossunder2X, crossunder2Y);
   IndicatorObjPrefix = GenerateIndicatorPrefix("RedK VADER v4.0");
   IndicatorShortName("RedK Volume-Accelerated Directional Energy Ratio");
   f_derma_fS_i_s1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_derma_fS_i_s1 = new f_derma_fS_i_sStream(f_derma_fS_i_s1_param1, length, MA_Type);
   id = f_derma_fS_i_s1.Init(id);
   f_derma_fS_i_s2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_derma_fS_i_s2 = new f_derma_fS_i_sStream(f_derma_fS_i_s2_param1, length, MA_Type);
   id = f_derma_fS_i_s2.Init(id);
   f_derma_fS_i_s3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f_derma_fS_i_s3 = new f_derma_fS_i_sStream(f_derma_fS_i_s3_param1, length, MA_Type);
   id = f_derma_fS_i_s3.Init(id);
   SetIndexBuffer(id++, V_senti);
   id = plot2.RegisterInternalStream(id);
   id = plot13.RegisterInternalStream(id);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   stoch1Source.Release();
   stoch1High.Release();
   stoch1Low.Release();
   stoch1.Release();
   highest1.Release();
   lowest1.Release();
   change1Source.Release();
   change1.Release();
   fixnan1X.Release();
   fixnan1.Release();
   f_derma_fS_i_s1_param1.Release();
   delete f_derma_fS_i_s1;
   f_derma_fS_i_s2_param1.Release();
   delete f_derma_fS_i_s2;
   f_derma_fS_i_s3_param1.Release();
   delete f_derma_fS_i_s3;
   wma2Source.Release();
   wma2.Release();
   wma3Source.Release();
   wma3.Release();
   wma4Source.Release();
   wma4.Release();
   wma5Source.Release();
   wma5.Release();
   wma6Source.Release();
   wma6.Release();
   wma7Source.Release();
   wma7.Release();
   delete plot2;
   delete plot13;
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   cross1X.Release();
   cross1Y.Release();
   cross1.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   crossunder2X.Release();
   crossunder2Y.Release();
   crossunder2.Release();
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
      stoch1Source.Init();
      stoch1High.Init();
      stoch1Low.Init();
      change1Source.Init();
      fixnan1X.Init();
      f_derma_fS_i_s1_param1.Init();
      f_derma_fS_i_s1.Clear();
      f_derma_fS_i_s2_param1.Init();
      f_derma_fS_i_s2.Clear();
      f_derma_fS_i_s3_param1.Init();
      f_derma_fS_i_s3.Clear();
      wma2Source.Init();
      wma3Source.Init();
      wma4Source.Init();
      wma5Source.Init();
      wma6Source.Init();
      wma7Source.Init();
      ArrayInitialize(plot1, 0);
      ArrayInitialize(V_senti, EMPTY_VALUE);
      plot2.Init(EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(plot11, EMPTY_VALUE);
      ArrayInitialize(plot12, EMPTY_VALUE);
      plot13.Init(EMPTY_VALUE);
      crossover1X.Init();
      crossover1Y.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      cross1X.Init();
      cross1Y.Init();
      crossover2X.Init();
      crossover2Y.Init();
      crossunder2X.Init();
      crossunder2Y.Init();
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
      double price = close[pos];
      double v = tick_volume[pos];
      stoch1Source.SetValue(pos, v);
      stoch1High.SetValue(pos, v);
      stoch1Low.SetValue(pos, v);
      double stoch1Value;
      if (!stoch1.GetValue(pos, stoch1Value)) { stoch1Value = EMPTY_VALUE; }
      double vola = (((v_calc == "None") || (tick_volume[pos]) == EMPTY_VALUE) ? 1 : ((v_calc == "Relative") ? SafeDivide(stoch1Value, 100) : v));
      double highest1Value;
      if (!highest1.GetValue(pos, highest1Value)) { highest1Value = EMPTY_VALUE; }
      double lowest1Value;
      if (!lowest1.GetValue(pos, lowest1Value)) { lowest1Value = EMPTY_VALUE; }
      double R = SafeDivide((SafeMinus(highest1Value, lowest1Value)), 2);
      change1Source.SetValue(pos, price);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      double sr = SafeDivide(change1Value, R);
      double rsr = SafeMathMax(SafeMathMin(sr, 1), (-1));
      fixnan1X.SetValue(pos, SafeMultiply(rsr, vola));
      double fixnan1Value;
      if (!fixnan1.GetValue(pos, fixnan1Value)) { fixnan1Value = EMPTY_VALUE; }
      double c = fixnan1Value;
      double c_plus = SafeMathMax(c, 0);
      double c_minus = (-SafeMathMin(c, 0));
      f_derma_fS_i_s1_param1.SetValue(pos, vola);
      double f_derma_fS_i_s1Value;
      if (!f_derma_fS_i_s1.GetValue(pos, f_derma_fS_i_s1Value)) { f_derma_fS_i_s1Value = EMPTY_VALUE; }
      double avg_vola = f_derma_fS_i_s1Value;
      f_derma_fS_i_s2_param1.SetValue(pos, c_plus);
      double f_derma_fS_i_s2Value;
      if (!f_derma_fS_i_s2.GetValue(pos, f_derma_fS_i_s2Value)) { f_derma_fS_i_s2Value = EMPTY_VALUE; }
      double dem = SafeDivide(f_derma_fS_i_s2Value, avg_vola);
      f_derma_fS_i_s3_param1.SetValue(pos, c_minus);
      double f_derma_fS_i_s3Value;
      if (!f_derma_fS_i_s3.GetValue(pos, f_derma_fS_i_s3Value)) { f_derma_fS_i_s3Value = EMPTY_VALUE; }
      double sup = SafeDivide(f_derma_fS_i_s3Value, avg_vola);
      wma2Source.SetValue(pos, dem);
      double wma2Value;
      if (!wma2.GetValue(pos, wma2Value)) { wma2Value = EMPTY_VALUE; }
      double adp = SafeMultiply(100, wma2Value);
      wma3Source.SetValue(pos, sup);
      double wma3Value;
      if (!wma3.GetValue(pos, wma3Value)) { wma3Value = EMPTY_VALUE; }
      double asp = SafeMultiply(100, wma3Value);
      double anp = SafeMinus(adp, asp);
      wma4Source.SetValue(pos, anp);
      double wma4Value;
      if (!wma4.GetValue(pos, wma4Value)) { wma4Value = EMPTY_VALUE; }
      double anp_s = wma4Value;
      wma5Source.SetValue(pos, dem);
      double wma5Value;
      if (!wma5.GetValue(pos, wma5Value)) { wma5Value = EMPTY_VALUE; }
      double s_adp = SafeMultiply(100, wma5Value);
      wma6Source.SetValue(pos, sup);
      double wma6Value;
      if (!wma6.GetValue(pos, wma6Value)) { wma6Value = EMPTY_VALUE; }
      double s_asp = SafeMultiply(100, wma6Value);
      wma7Source.SetValue(pos, SafeMinus(s_adp, s_asp));
      double wma7Value;
      if (!wma7.GetValue(pos, wma7Value)) { wma7Value = EMPTY_VALUE; }
      V_senti[pos] = wma7Value;
      color c_adp = Aqua;
      color c_asp = Orange;
      color c_fd = Green;
      color c_fs = Red;
      c_zero = 0x00eeff;
      color c_up = 0xfc9b35;
      color c_dn = 0x177ff5;
      color c_sup = 0x00ff33;
      color c_sdn = 0x1111ff;
      bool up = SafeGE(anp_s, 0);
      bool s_up = SafeGE(V_senti[pos], 0);
      color c_grow_above = 0x205e1b;
      color c_grow_below = 0x4a4cdc;
      color c_fall_above = 0x6abb66;
      color c_fall_below = 0x988eef;
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool sflag_up = SafeGE(SafeMathAbs(V_senti[pos]), SafeMathAbs(V_senti[pos + 1]));
      plot2.SetByColor((show_senti ? V_senti[pos] : EMPTY_VALUE), pos, (s_up ? ((sflag_up ? c_grow_above : c_fall_above)) : (sflag_up ? c_grow_below : c_fall_below)));
      color plot10_color = c_asp;
      if (plot10_color != EMPTY_VALUE) { plot10[pos] = asp; }
      else { plot10[pos] = EMPTY_VALUE; }
      double s = plot10[pos];
      color plot11_color = c_adp;
      if (plot11_color != EMPTY_VALUE) { plot11[pos] = adp; }
      else { plot11[pos] = EMPTY_VALUE; }
      double d = plot11[pos];
      color plot12_color = Gray;
      if (plot12_color != EMPTY_VALUE) { plot12[pos] = anp; }
      else { plot12[pos] = EMPTY_VALUE; }
      plot13.SetByColor(anp_s, pos, (up ? c_up : c_dn));
      crossover1X.SetValue(pos, anp_s);
      crossover1Y.SetValue(pos, 0);
      bool crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { crossover1Value = EMPTY_VALUE; }
      bool Alert_up = crossover1Value;
      crossunder1X.SetValue(pos, anp_s);
      crossunder1Y.SetValue(pos, 0);
      bool crossunder1Value;
      if (!crossunder1.GetValue(pos, crossunder1Value)) { crossunder1Value = EMPTY_VALUE; }
      bool Alert_dn = crossunder1Value;
      cross1X.SetValue(pos, anp_s);
      cross1Y.SetValue(pos, 0);
      bool cross1Value;
      if (!cross1.GetValue(pos, cross1Value)) { cross1Value = EMPTY_VALUE; }
      bool Alert_swing = cross1Value;
      if (Alert_up) { _signaler.SendNotifications(".   VADER Crossing 0 Up", "VADER Up - Buying Energy Detected!"); }
      if (Alert_dn) { _signaler.SendNotifications("..  VADER Crossing 0 Down", "VADER Down - Selling Energy Detected!"); }
      if (Alert_swing) { _signaler.SendNotifications("... VADER Crossing 0", "VADER Swing - Possible Reversal"); }
      crossover2X.SetValue(pos, anp_s);
      crossover2Y.SetValue(pos, V_senti[pos]);
      bool crossover2Value;
      if (!crossover2.GetValue(pos, crossover2Value)) { crossover2Value = EMPTY_VALUE; }
      bool v_speedup = crossover2Value;
      crossunder2X.SetValue(pos, anp_s);
      crossunder2Y.SetValue(pos, V_senti[pos]);
      bool crossunder2Value;
      if (!crossunder2.GetValue(pos, crossunder2Value)) { crossunder2Value = EMPTY_VALUE; }
      bool v_slowdn = crossunder2Value;
      if (v_speedup) { _signaler.SendNotifications("*  VADER Speeding Up", "VADER Speeding Up!"); }
      if (v_slowdn) { _signaler.SendNotifications("** VADER Slowing Down", "VADER Slowing Down!"); }
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