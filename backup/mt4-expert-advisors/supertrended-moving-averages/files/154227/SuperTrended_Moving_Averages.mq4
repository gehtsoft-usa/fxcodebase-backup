//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74577

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
#property indicator_buffers 7
#property indicator_label1 "Up Trend"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 0
#property indicator_label2 "UpTrend Begins"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Buy"
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Down Trend"
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 0
#property indicator_label5 "DownTrend Begins"
#property indicator_type5 DRAW_ARROW
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Sell"
#property indicator_type6 DRAW_ARROW
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 ""
#property indicator_type7 DRAW_ARROW
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 0

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


// Price stream v2.0

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

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            if (!_source.GetClose(period, val))
            {
               return false;
            }
            break;
         case PriceOpen:
            if (!_source.GetOpen(period, val))
            {
               return false;
            }
            break;
         case PriceHigh:
            if (!_source.GetHigh(period, val))
            {
               return false;
            }
            break;
         case PriceLow:
            if (!_source.GetLow(period, val))
            {
               return false;
            }
            break;
         case PriceMedian:
            {
               double high, low;
               if (!_source.GetHighLow(period, high, low))
               {
                  return false;
               }
               val = (high + low) / 2.0;
            }
            break;
         case PriceTypical:
            {
               double open1, high1, low1, close1;
               if (!_source.GetValues(period, open1, high1, low1, close1))
               {
                  return false;
               }
               val = (high1 + low1 + close1) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open2, high2, low2, close2;
               if (!_source.GetValues(period, open2, high2, low2, close2))
               {
                  return false;
               }
               val = (high2 + low2 + close2 * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         // case PriceVolume:
         //    if (!_source.GetVolume(period, val))
         //    {
         //       return false;
         //    }
         //    break;
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
      period = iBarShift(_symbol, _timeframe, date);
      return true;
   }

   virtual bool GetValue(const int period, double &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      val = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      dt = iTime(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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
input PriceType param1 = PriceClose; // Source
input string param2 = "EMA"; // Moving Average Type
input int param3 = 100; // Moving Average Length
input int param4 = 10; // ATR Period
input double param5 = 0.5; // ATR Multiplier
input bool param6 = true; // Change ATR Calculation Method ?
input bool param7 = false; // Show Buy/Sell Signals ?
input bool param8 = true; // Highlighter On/Off ?
input double param9 = 0.7; // TILLSON T3 Volume Factor
input color param10 = Green; // ColorU
input color param11 = Red; // ColorD
input int bars_limit = 100000; // Bars limit
IStream* param1Stream;
IStream* src;
string mav;
int length;
int Periods;
double Multiplier;
bool changeATR;
bool showsignals;
bool highlighting;
double T3a1;
double VAR;
class Var_Func_S_iStream
{
   IStream* src;
   int length;
   CustomStream* sum1Source;
   SumOnStream* sum1;
   CustomStream* sum2Source;
   SumOnStream* sum2;
   double VAR[];
   bool _initialized;
public:
   Var_Func_S_iStream(IStream* src, int length)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
      sum1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sum1 = new SumOnStream(sum1Source, 9);
      sum2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sum2 = new SumOnStream(sum2Source, 9);
   }
   ~Var_Func_S_iStream()
   {
      src.Release();
      sum1Source.Release();
      sum1.Release();
      sum2Source.Release();
      sum2.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, VAR);
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
         ArrayInitialize(VAR, 0.0);
         _initialized = true;
      }
      int valpha = SafeDivide(2, (length + 1));
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      double srcValue_1;
      if (!src.GetValue(pos + 1, srcValue_1)) { srcValue_1 = EMPTY_VALUE; }
      double vud1 = ((srcValue > srcValue_1) ? srcValue - srcValue_1 : 0);
      double vdd1 = ((srcValue < srcValue_1) ? srcValue_1 - srcValue : 0);
      sum1Source.SetValue(pos, vud1);
      double sum1Value;
      if (!sum1.GetValue(pos, sum1Value)) { sum1Value = EMPTY_VALUE; }
      double vUD = sum1Value;
      sum2Source.SetValue(pos, vdd1);
      double sum2Value;
      if (!sum2.GetValue(pos, sum2Value)) { sum2Value = EMPTY_VALUE; }
      double vDD = sum2Value;
      double vCMO = Nz(SafeDivide((SafeMinus(vUD, vDD)), (SafePlus(vUD, vDD))));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      VAR[pos] = SafePlus(Nz(SafeMultiply(SafeMultiply(valpha, SafeMathAbs(vCMO)), srcValue)), SafeMultiply((SafeMinus(1, SafeMultiply(valpha, SafeMathAbs(vCMO)))), Nz(VAR[pos + 1])));
      __out1 = VAR[pos];
      return true;
   }
};
CustomStream* Var_Func_S_i1_param1;
Var_Func_S_iStream* Var_Func_S_i1;
double DEMA;
CustomStream* ema1Source;
EMAOnStream* ema1;
CustomStream* ema2Source;
EMAOnStream* ema2;
CustomStream* ema3Source;
EMAOnStream* ema3;
double WWMA;
class Wwma_Func_S_iStream
{
   IStream* src;
   int length;
   double WWMA[];
   bool _initialized;
public:
   Wwma_Func_S_iStream(IStream* src, int length)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
   }
   ~Wwma_Func_S_iStream()
   {
      src.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, WWMA);
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
         ArrayInitialize(WWMA, 0.0);
         _initialized = true;
      }
      int wwalpha = SafeDivide(1, length);
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      WWMA[pos] = SafePlus(wwalpha * srcValue, SafeMultiply((1 - wwalpha), Nz(WWMA[pos + 1])));
      __out1 = WWMA[pos];
      return true;
   }
};
CustomStream* Wwma_Func_S_i2_param1;
Wwma_Func_S_iStream* Wwma_Func_S_i2;
double ZLEMA;
class Zlema_Func_S_iStream
{
   IStream* src;
   int length;
   CustomStream* ema4Source;
   EMAOnStream* ema4;
   bool _initialized;
public:
   Zlema_Func_S_iStream(IStream* src, int length)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
      ema4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema4 = new EMAOnStream(ema4Source, length);
   }
   ~Zlema_Func_S_iStream()
   {
      src.Release();
      ema4Source.Release();
      ema4.Release();
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
         _initialized = true;
      }
      int zxLag = ((SafeDivide(length, 2) == MathRound(SafeDivide(length, 2))) ? SafeDivide(length, 2) : SafeDivide((length - 1), 2));
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      double srcValue_zxLag;
      if (!src.GetValue(pos + zxLag, srcValue_zxLag)) { srcValue_zxLag = EMPTY_VALUE; }
      double zxEMAData = srcValue + srcValue - srcValue_zxLag;
      ema4Source.SetValue(pos, zxEMAData);
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
      ZLEMA = ema4Value;
      __out1 = ZLEMA;
      return true;
   }
};
CustomStream* Zlema_Func_S_i3_param1;
Zlema_Func_S_iStream* Zlema_Func_S_i3;
double TSF;
class Tsf_Func_S_iStream
{
   IStream* src;
   int length;
   CustomStream* linreg1Source;
   LinearRegressionOnStream* linreg1;
   CustomStream* linreg2Source;
   LinearRegressionOnStream* linreg2;
   CustomStream* linreg3Source;
   LinearRegressionOnStream* linreg3;
   bool _initialized;
public:
   Tsf_Func_S_iStream(IStream* src, int length)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
      linreg1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      linreg1 = new LinearRegressionOnStream(linreg1Source, length, 0);
      linreg2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      linreg2 = new LinearRegressionOnStream(linreg2Source, length, 1);
      linreg3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      linreg3 = new LinearRegressionOnStream(linreg3Source, length, 0);
   }
   ~Tsf_Func_S_iStream()
   {
      src.Release();
      linreg1Source.Release();
      linreg1.Release();
      linreg2Source.Release();
      linreg2.Release();
      linreg3Source.Release();
      linreg3.Release();
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
         linreg1Source.Init();
         linreg2Source.Init();
         linreg3Source.Init();
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      linreg1Source.SetValue(pos, srcValue);
      double linreg1Value;
      if (!linreg1.GetValue(pos, linreg1Value)) { linreg1Value = EMPTY_VALUE; }
      double lrc = linreg1Value;
      linreg2Source.SetValue(pos, srcValue);
      double linreg2Value;
      if (!linreg2.GetValue(pos, linreg2Value)) { linreg2Value = EMPTY_VALUE; }
      double lrc1 = linreg2Value;
      double lrs = SafeMinus(lrc, lrc1);
      linreg3Source.SetValue(pos, srcValue);
      double linreg3Value;
      if (!linreg3.GetValue(pos, linreg3Value)) { linreg3Value = EMPTY_VALUE; }
      TSF = SafePlus(linreg3Value, lrs);
      __out1 = TSF;
      return true;
   }
};
CustomStream* Tsf_Func_S_i4_param1;
Tsf_Func_S_iStream* Tsf_Func_S_i4;
double HMA;
CustomStream* wma1Source;
WMAOnStream* wma1;
CustomStream* wma2Source;
WMAOnStream* wma2;
CustomStream* wma3Source;
WMAOnStream* wma3;
CustomStream* ema5Source;
EMAOnStream* ema5;
CustomStream* ema6Source;
EMAOnStream* ema6;
CustomStream* ema7Source;
EMAOnStream* ema7;
CustomStream* ema8Source;
EMAOnStream* ema8;
CustomStream* ema9Source;
EMAOnStream* ema9;
CustomStream* ema10Source;
EMAOnStream* ema10;
double T3;
class getMA_S_iStream
{
   IStream* src;
   int length;
   CustomStream* sma1Source;
   SmaOnStream* sma1;
   CustomStream* ema11Source;
   EMAOnStream* ema11;
   CustomStream* wma4Source;
   WMAOnStream* wma4;
   CustomStream* sma2Source;
   SmaOnStream* sma2;
   CustomStream* sma3Source;
   SmaOnStream* sma3;
   bool _initialized;
public:
   getMA_S_iStream(IStream* src, int length)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
      sma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, length);
      ema11Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema11 = new EMAOnStream(ema11Source, length);
      wma4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      wma4 = new WMAOnStream(wma4Source, length);
      sma3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma3 = new SmaOnStream(sma3Source, MathCeil(SafeDivide(length, 2)));
      sma2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma2 = new SmaOnStream(sma2Source, SafePlus(MathFloor(SafeDivide(length, 2)), 1));
   }
   ~getMA_S_iStream()
   {
      src.Release();
      sma1Source.Release();
      sma1.Release();
      ema11Source.Release();
      ema11.Release();
      wma4Source.Release();
      wma4.Release();
      sma2Source.Release();
      sma2.Release();
      sma3Source.Release();
      sma3.Release();
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
         ema11Source.Init();
         wma4Source.Init();
         sma3Source.Init();
         sma2Source.Init();
         _initialized = true;
      }
      double ma = 0.0;
      if ((mav == "SMA"))
      {
         double srcValue;
         if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
         sma1Source.SetValue(pos, srcValue);
         double sma1Value;
         if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
         ma = sma1Value;
         ma;
      }
      if ((mav == "EMA"))
      {
         double srcValue;
         if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
         ema11Source.SetValue(pos, srcValue);
         double ema11Value;
         if (!ema11.GetValue(pos, ema11Value)) { ema11Value = EMPTY_VALUE; }
         ma = ema11Value;
         ma;
      }
      if ((mav == "WMA"))
      {
         double srcValue;
         if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
         wma4Source.SetValue(pos, srcValue);
         double wma4Value;
         if (!wma4.GetValue(pos, wma4Value)) { wma4Value = EMPTY_VALUE; }
         ma = wma4Value;
         ma;
      }
      if ((mav == "DEMA"))
      {
         ma = DEMA;
         ma;
      }
      if ((mav == "TMA"))
      {
         double srcValue;
         if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
         sma3Source.SetValue(pos, srcValue);
         double sma3Value;
         if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
         sma2Source.SetValue(pos, sma3Value);
         double sma2Value;
         if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
         ma = sma2Value;
         ma;
      }
      if ((mav == "VAR"))
      {
         ma = VAR;
         ma;
      }
      if ((mav == "WWMA"))
      {
         ma = WWMA;
         ma;
      }
      if ((mav == "ZLEMA"))
      {
         ma = ZLEMA;
         ma;
      }
      if ((mav == "TSF"))
      {
         ma = TSF;
         ma;
      }
      if ((mav == "HULL"))
      {
         ma = HMA;
         ma;
      }
      if ((mav == "TILL"))
      {
         ma = T3;
         ma;
      }
      __out1 = ma;
      return true;
   }
};
CustomStream* getMA_S_i5_param1;
getMA_S_iStream* getMA_S_i5;
CustomStream* sma4Source;
SmaOnStream* sma4;
IStream* tr1;
ATRStream* atr1;
double up[];
double dn[];
double trend[];
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
color colorup;
color colordown;
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
   IndicatorBuffers(12);
   int id = 0;
   param1Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param1);
   src = param1Stream;
   mav = param2;
   length = param3;
   Periods = param4;
   Multiplier = param5;
   changeATR = param6;
   showsignals = param7;
   highlighting = param8;
   T3a1 = param9;
   ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, length);
   ema3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, length);
   ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, length);
   wma2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma2 = new WMAOnStream(wma2Source, SafeDivide(length, 2));
   wma3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma3 = new WMAOnStream(wma3Source, length);
   wma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma1 = new WMAOnStream(wma1Source, SafeMathRound(MathSqrt(length)));
   ema5Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema5 = new EMAOnStream(ema5Source, length);
   ema6Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema6 = new EMAOnStream(ema6Source, length);
   ema7Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema7 = new EMAOnStream(ema7Source, length);
   ema8Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema8 = new EMAOnStream(ema8Source, length);
   ema9Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema9 = new EMAOnStream(ema9Source, length);
   ema10Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema10 = new EMAOnStream(ema10Source, length);
   sma4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma4 = new SmaOnStream(sma4Source, Periods);
   atr1 = new ATRStream(Periods);
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 0, Green);
   SetIndexBuffer(id, plot2);
   SetIndexArrow(id, 161);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, Green);
   SetIndexBuffer(id, plot3);
   SetIndexArrow(id, 241);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, Green);
   SetIndexBuffer(id, plot4);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 0, Red);
   SetIndexBuffer(id, plot5);
   SetIndexArrow(id, 161);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, Red);
   SetIndexBuffer(id, plot6);
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, Red);
   SetIndexBuffer(id, plot7);
   SetIndexArrow(id++, 161);
   colorup = param10;
   colordown = param11;
   IndicatorObjPrefix = GenerateIndicatorPrefix("ST MA");
   IndicatorShortName("SuperTrended Moving Averages");
   Var_Func_S_i1_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Var_Func_S_i1 = new Var_Func_S_iStream(Var_Func_S_i1_param1, length);
   id = Var_Func_S_i1.Init(id);
   Wwma_Func_S_i2_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Wwma_Func_S_i2 = new Wwma_Func_S_iStream(Wwma_Func_S_i2_param1, length);
   id = Wwma_Func_S_i2.Init(id);
   Zlema_Func_S_i3_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Zlema_Func_S_i3 = new Zlema_Func_S_iStream(Zlema_Func_S_i3_param1, length);
   id = Zlema_Func_S_i3.Init(id);
   Tsf_Func_S_i4_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Tsf_Func_S_i4 = new Tsf_Func_S_iStream(Tsf_Func_S_i4_param1, length);
   id = Tsf_Func_S_i4.Init(id);
   getMA_S_i5_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getMA_S_i5 = new getMA_S_iStream(getMA_S_i5_param1, length);
   id = getMA_S_i5.Init(id);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(id++, up);
   SetIndexBuffer(id++, dn);
   SetIndexBuffer(id++, trend);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   param1Stream.Release();
   Var_Func_S_i1_param1.Release();
   delete Var_Func_S_i1;
   ema1Source.Release();
   ema1.Release();
   ema2Source.Release();
   ema2.Release();
   ema3Source.Release();
   ema3.Release();
   Wwma_Func_S_i2_param1.Release();
   delete Wwma_Func_S_i2;
   Zlema_Func_S_i3_param1.Release();
   delete Zlema_Func_S_i3;
   Tsf_Func_S_i4_param1.Release();
   delete Tsf_Func_S_i4;
   wma1Source.Release();
   wma1.Release();
   wma2Source.Release();
   wma2.Release();
   wma3Source.Release();
   wma3.Release();
   ema5Source.Release();
   ema5.Release();
   ema6Source.Release();
   ema6.Release();
   ema7Source.Release();
   ema7.Release();
   ema8Source.Release();
   ema8.Release();
   ema9Source.Release();
   ema9.Release();
   ema10Source.Release();
   ema10.Release();
   getMA_S_i5_param1.Release();
   delete getMA_S_i5;
   sma4Source.Release();
   sma4.Release();
   tr1.Release();
   atr1.Release();
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
      Var_Func_S_i1_param1.Init();
      Var_Func_S_i1.Clear();
      ema1Source.Init();
      ema3Source.Init();
      ema2Source.Init();
      Wwma_Func_S_i2_param1.Init();
      Wwma_Func_S_i2.Clear();
      Zlema_Func_S_i3_param1.Init();
      Zlema_Func_S_i3.Clear();
      Tsf_Func_S_i4_param1.Init();
      Tsf_Func_S_i4.Clear();
      wma2Source.Init();
      wma3Source.Init();
      wma1Source.Init();
      ema5Source.Init();
      ema6Source.Init();
      ema7Source.Init();
      ema8Source.Init();
      ema9Source.Init();
      ema10Source.Init();
      getMA_S_i5_param1.Init();
      getMA_S_i5.Clear();
      sma4Source.Init();
      ArrayInitialize(up, EMPTY_VALUE);
      ArrayInitialize(dn, EMPTY_VALUE);
      ArrayInitialize(trend, 1);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
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
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      Var_Func_S_i1_param1.SetValue(pos, srcValue);
      double Var_Func_S_i1Value;
      if (!Var_Func_S_i1.GetValue(pos, Var_Func_S_i1Value)) { Var_Func_S_i1Value = EMPTY_VALUE; }
      VAR = Var_Func_S_i1Value;
      ema1Source.SetValue(pos, srcValue);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      ema3Source.SetValue(pos, srcValue);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
      ema2Source.SetValue(pos, ema3Value);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      DEMA = SafeMinus(SafeMultiply(2, ema1Value), ema2Value);
      Wwma_Func_S_i2_param1.SetValue(pos, srcValue);
      double Wwma_Func_S_i2Value;
      if (!Wwma_Func_S_i2.GetValue(pos, Wwma_Func_S_i2Value)) { Wwma_Func_S_i2Value = EMPTY_VALUE; }
      WWMA = Wwma_Func_S_i2Value;
      Zlema_Func_S_i3_param1.SetValue(pos, srcValue);
      double Zlema_Func_S_i3Value;
      if (!Zlema_Func_S_i3.GetValue(pos, Zlema_Func_S_i3Value)) { Zlema_Func_S_i3Value = EMPTY_VALUE; }
      ZLEMA = Zlema_Func_S_i3Value;
      Tsf_Func_S_i4_param1.SetValue(pos, srcValue);
      double Tsf_Func_S_i4Value;
      if (!Tsf_Func_S_i4.GetValue(pos, Tsf_Func_S_i4Value)) { Tsf_Func_S_i4Value = EMPTY_VALUE; }
      TSF = Tsf_Func_S_i4Value;
      wma2Source.SetValue(pos, srcValue);
      double wma2Value;
      if (!wma2.GetValue(pos, wma2Value)) { wma2Value = EMPTY_VALUE; }
      wma3Source.SetValue(pos, srcValue);
      double wma3Value;
      if (!wma3.GetValue(pos, wma3Value)) { wma3Value = EMPTY_VALUE; }
      wma1Source.SetValue(pos, SafeMinus(SafeMultiply(2, wma2Value), wma3Value));
      double wma1Value;
      if (!wma1.GetValue(pos, wma1Value)) { wma1Value = EMPTY_VALUE; }
      HMA = wma1Value;
      ema5Source.SetValue(pos, srcValue);
      double ema5Value;
      if (!ema5.GetValue(pos, ema5Value)) { ema5Value = EMPTY_VALUE; }
      double T3e1 = ema5Value;
      ema6Source.SetValue(pos, T3e1);
      double ema6Value;
      if (!ema6.GetValue(pos, ema6Value)) { ema6Value = EMPTY_VALUE; }
      double T3e2 = ema6Value;
      ema7Source.SetValue(pos, T3e2);
      double ema7Value;
      if (!ema7.GetValue(pos, ema7Value)) { ema7Value = EMPTY_VALUE; }
      double T3e3 = ema7Value;
      ema8Source.SetValue(pos, T3e3);
      double ema8Value;
      if (!ema8.GetValue(pos, ema8Value)) { ema8Value = EMPTY_VALUE; }
      double T3e4 = ema8Value;
      ema9Source.SetValue(pos, T3e4);
      double ema9Value;
      if (!ema9.GetValue(pos, ema9Value)) { ema9Value = EMPTY_VALUE; }
      double T3e5 = ema9Value;
      ema10Source.SetValue(pos, T3e5);
      double ema10Value;
      if (!ema10.GetValue(pos, ema10Value)) { ema10Value = EMPTY_VALUE; }
      double T3e6 = ema10Value;
      double T3c1 = (-T3a1) * T3a1 * T3a1;
      double T3c2 = 3 * T3a1 * T3a1 + 3 * T3a1 * T3a1 * T3a1;
      double T3c3 = (-6) * T3a1 * T3a1 - 3 * T3a1 - 3 * T3a1 * T3a1 * T3a1;
      double T3c4 = 1 + 3 * T3a1 + T3a1 * T3a1 * T3a1 + 3 * T3a1 * T3a1;
      T3 = SafePlus(SafePlus(SafeMultiply(T3c1, T3e6), SafePlus(SafeMultiply(T3c2, T3e5), SafeMultiply(T3c3, T3e4))), SafeMultiply(T3c4, T3e3));
      getMA_S_i5_param1.SetValue(pos, srcValue);
      double getMA_S_i5Value;
      if (!getMA_S_i5.GetValue(pos, getMA_S_i5Value)) { getMA_S_i5Value = EMPTY_VALUE; }
      double MA = getMA_S_i5Value;
      double tr1Value;
      if (!tr1.GetValue(pos, tr1Value)) { tr1Value = EMPTY_VALUE; }
      sma4Source.SetValue(pos, tr1Value);
      double sma4Value;
      if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
      double atr2 = sma4Value;
      double atr1Value;
      if (!atr1.GetValue(pos, atr1Value)) { atr1Value = EMPTY_VALUE; }
      double atr = (changeATR ? atr1Value : atr2);
      up[pos] = SafeMinus(MA, SafeMultiply(Multiplier, atr));
      if (pos + 1 > (rates_total - 1)) { continue; }
      double up1 = Nz(up[pos + 1], up[pos]);
      if (pos + 1 > (rates_total - 1)) { continue; }
      up[pos] = (SafeGreater(close[pos + 1], up1) ? SafeMathMax(up[pos], up1) : up[pos]);
      dn[pos] = SafePlus(MA, SafeMultiply(Multiplier, atr));
      if (pos + 1 > (rates_total - 1)) { continue; }
      double dn1 = Nz(dn[pos + 1], dn[pos]);
      if (pos + 1 > (rates_total - 1)) { continue; }
      dn[pos] = (SafeLess(close[pos + 1], dn1) ? SafeMathMin(dn[pos], dn1) : dn[pos]);
      if (pos + 1 > (rates_total - 1)) { continue; }
      trend[pos] = Nz(trend[pos + 1], trend[pos]);
      trend[pos] = ((trend[pos] == (-1)) && SafeGreater(close[pos], dn1) ? 1 : ((trend[pos] == 1) && SafeLess(close[pos], up1) ? (-1) : trend[pos]));
      color plot1_color = Green;
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = ((trend[pos] == 1) ? up[pos] : EMPTY_VALUE); }
      else { plot1[pos] = EMPTY_VALUE; }
      double upPlot = plot1[pos];
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool buySignal = (trend[pos] == 1) && (trend[pos + 1] == (-1));
      plot2[pos] = (buySignal ? up[pos] : EMPTY_VALUE);
      plot3[pos] = (buySignal && showsignals ? up[pos] : EMPTY_VALUE);
      color plot4_color = Red;
      if (plot4_color != EMPTY_VALUE) { plot4[pos] = ((trend[pos] == 1) ? EMPTY_VALUE : dn[pos]); }
      else { plot4[pos] = EMPTY_VALUE; }
      double dnPlot = plot4[pos];
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool sellSignal = (trend[pos] == (-1)) && (trend[pos + 1] == 1);
      plot5[pos] = (sellSignal ? dn[pos] : EMPTY_VALUE);
      plot6[pos] = (sellSignal && showsignals ? dn[pos] : EMPTY_VALUE);
      plot7[pos] = SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4);
      double mPlot = plot7[pos];
      color longFillColor = (highlighting ? ((trend[pos] == 1) ? colorup : White) : White);
      color shortFillColor = (highlighting ? ((trend[pos] == (-1)) ? colordown : White) : White);
      if (buySignal) { _signaler.SendNotifications("SuperTrend Buy", "SuperTrend Buy!"); }
      if (sellSignal) { _signaler.SendNotifications("SuperTrend Sell", "SuperTrend Sell!"); }
      if (pos + 1 > (rates_total - 1)) { continue; }
      bool changeCond = (trend[pos] != trend[pos + 1]);
      if (changeCond) { _signaler.SendNotifications("SuperTrend Direction Change", "SuperTrend has changed direction!"); }
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