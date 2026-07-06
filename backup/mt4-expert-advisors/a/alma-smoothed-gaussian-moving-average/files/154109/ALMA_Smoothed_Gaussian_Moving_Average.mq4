//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74551

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
#property indicator_buffers 12
#property indicator_label1 "Gaussian Moving Average"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3
#property indicator_label2 "Gaussian Moving Average"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 3
#property indicator_label3 "Buy Signal"
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Sell Signal"
#property indicator_type4 DRAW_ARROW
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

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


// ALMA on stream v1.1

#ifndef AlmaOnStream_IMP
#define AlmaOnStream_IMP

class ALMAOnStream : public AOnStream
{
   int _length;
   double _m;
   double _s;
   bool _floorValue;
public:
   ALMAOnStream(IStream *source, const int length, double offset, double sigma, bool floorValue = false)
      :AOnStream(source)
   {
      _length = length;
      _m = MathFloor(offset * (_length - 1));
      _s = _length / sigma;
      _floorValue = floorValue;
   }

   bool GetValue(const int period, double &val)
   {
      double sum = 0, wsum = 0;
      for (int i = 0; i < _length; i++)
      {
         double w = MathExp(-((i - _m) * (i - _m)) / (2 * _s * _s));
         wsum += w;
         double price;
         if (!_source.GetValue(period + (_length - 1 - i), price))
            return false;
         sum += price * w;
      }

      if (wsum != 0)
         val = sum / wsum;

      return true;
   }
};

#endif



// RSI stream v1.0

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSIStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSIStream(IStream* stream, int period)
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


// Simple price stream v1.2



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
#define ColorRGB(red, green, blue, transp) red + (green << 8) + (blue << 16)
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
   
   void SetByColor(double value, int period, color clr)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Color == clr)
         {
            Set(value, period, i);
            return;
         }
      }
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

//AOnStream v1.0

class ConditionStream : public AStreamBase
{
protected:
   ICondition* _condition;
public:
   ConditionStream(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~ConditionStream()
   {
      _condition.Release();
   }

   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   bool GetValue(const int period, double &val)
   {
      val = _condition.IsPass(period, 0) ? 1 : 0;
      return true;
   }
};
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


//AOnStream v1.0

class CrossoverStream : public ConditionStream
{
public:
   CrossoverStream(IStream *left, IStream* right)
      :ConditionStream(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""))
   {
      _condition.Release();
   }
};




//AOnStream v1.0

class CrossunderStream : public ConditionStream
{
public:
   CrossunderStream(IStream *left, IStream* right)
      :ConditionStream(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", ""))
   {
      _condition.Release();
   }
};
input PriceType param1 = PriceClose; // Source
input int param2 = 1; // Smoothing
input int param3 = 25; // Lookback
input int param4 = 14; // Length
input bool param5 = true; // Adaptive Parameters
input int param6 = 20; // Volatility Period
input double param7 = 1.0; // Standard Deviation
input int bars_limit = 100000; // Bars limit
IStream* param1Stream;
IStream* src;
int smooth;
int length1;
CustomStream* change1Source;
ChangeStream* change1;
CustomStream* alma1Source;
ALMAOnStream* alma1;
CustomStream* rsi1X;
RSIStream* rsi1;
double rsi[];
CustomStream* change2Source;
ChangeStream* change2;
class f1_SStream
{
   IStream* m;
public:
   f1_SStream(IStream* m)
   {
      this.m = m;
      m.AddRef();
   }
   ~f1_SStream()
   {
      m.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double mValue;
      if (!m.GetValue(period, mValue)) { return false; }
      __out1 = ((mValue >= 0.0) ? mValue : 0.0);
      return true;
   }
};
CustomStream* f1_S1_param1;
f1_SStream* f1_S1;
class f2_SStream
{
   IStream* m;
public:
   f2_SStream(IStream* m)
   {
      this.m = m;
      m.AddRef();
   }
   ~f2_SStream()
   {
      m.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double mValue;
      if (!m.GetValue(period, mValue)) { return false; }
      __out1 = ((mValue >= 0.0) ? 0.0 : (-mValue));
      return true;
   }
};
CustomStream* f2_S2_param1;
f2_SStream* f2_S2;
CustomStream* sum1Source;
SumOnStream* sum1;
CustomStream* sum2Source;
SumOnStream* sum2;
class percent_S_SStream
{
   IStream* nom;
   IStream* div;
public:
   percent_S_SStream(IStream* nom, IStream* div)
   {
      this.nom = nom;
      nom.AddRef();
      this.div = div;
      div.AddRef();
   }
   ~percent_S_SStream()
   {
      nom.Release();
      div.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double nomValue;
      if (!nom.GetValue(period, nomValue)) { return false; }
      double divValue;
      if (!div.GetValue(period, divValue)) { return false; }
      __out1 = SafeDivide(100 * nomValue, divValue);
      return true;
   }
};
CustomStream* percent_S_S3_param1;
CustomStream* percent_S_S3_param2;
percent_S_SStream* percent_S_S3;
double chandeMO[];
int length;
bool adaptive;
int volatilityPeriod;
CustomStream* stdev1Source;
StDevStream* stdev1;
CustomStream* highest1Source;
CustomStream* lowest1Source;
CustomStream* ema1Source;
EMAOnStream* ema1;
double currentSignal[];
double barColor[];
CandleStreams* barcolor1;
CandleStreams* plotcandle1;
CustomStream* ema2Source;
EMAOnStream* ema2;
ColoredStream* plot1;
double plot3[];
CustomStream* crossover1X;
CustomStream* crossover1Y;
CrossoverStream* crossover1;
double plot4[];
CustomStream* crossunder1X;
CustomStream* crossunder1Y;
CrossunderStream* crossunder1;
CandleStreams* barcolor2;
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
CustomStream* crossover2X;
CustomStream* crossover2Y;
CrossoverStream* crossover2;
CustomStream* crossunder2X;
CustomStream* crossunder2Y;
CrossunderStream* crossunder2;

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
   param1Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param1);
   src = param1Stream;
   smooth = param2;
   length1 = param3;
   change1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, smooth);
   double offset = 0.85;
   int sigma1 = 7;
   alma1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   alma1 = new ALMAOnStream(alma1Source, length1, offset, sigma1, false);
   rsi1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, 14);
   change2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change2 = new ChangeStream(change2Source, 1);
   int length11 = 9;
   sum1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sum1 = new SumOnStream(sum1Source, length11);
   sum2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sum2 = new SumOnStream(sum2Source, length11);
   length = param4;
   adaptive = param5;
   volatilityPeriod = param6;
   stdev1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev1 = new StDevStream(stdev1Source, volatilityPeriod);
   highest1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, 7);
   barcolor1 = new CandleStreams();
   barcolor1.SetOffset(0);
   plotcandle1 = new CandleStreams();
   ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, 7);
   plot1 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot1.RegisterStream(id, ColorRGB(0, 161, 5, 0));
   id = plot1.RegisterStream(id, ColorRGB(215, 0, 0, 0));
   SetIndexBuffer(id, plot3);
   SetIndexShift(id, (-1));
   SetIndexArrow(id, 241);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, ColorRGB(0, 161, 5, 0));
   crossover1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = new CrossoverStream(crossover1X, crossover1Y);
   SetIndexBuffer(id, plot4);
   SetIndexShift(id, (-1));
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, ColorRGB(215, 0, 0, 0));
   crossunder1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = new CrossunderStream(crossunder1X, crossunder1Y);
   barcolor2 = new CandleStreams();
   barcolor2.SetOffset(0);
   id = barcolor2.RegisterStreams(id, ColorRGB(0, 161, 5, 0));
   id = barcolor2.RegisterStreams(id, ColorRGB(215, 0, 0, 0));
   crossover2X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = new CrossoverStream(crossover2X, crossover2Y);
   crossunder2X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2 = new CrossunderStream(crossunder2X, crossunder2Y);
   IndicatorObjPrefix = GenerateIndicatorPrefix("ASGMA");
   IndicatorShortName("ALMA Smoothed Gaussian Moving Average");
   SetIndexBuffer(id++, rsi);
   f1_S1_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f1_S1 = new f1_SStream(f1_S1_param1);
   f2_S2_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   f2_S2 = new f2_SStream(f2_S2_param1);
   percent_S_S3_param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   percent_S_S3_param2 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   percent_S_S3 = new percent_S_SStream(percent_S_S3_param1, percent_S_S3_param2);
   SetIndexBuffer(id++, chandeMO);
   SetIndexBuffer(id++, currentSignal);
   SetIndexBuffer(id++, barColor);
   id = plot1.RegisterInternalStream(id);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   param1Stream.Release();
   change1Source.Release();
   change1.Release();
   alma1Source.Release();
   alma1.Release();
   rsi1X.Release();
   rsi1.Release();
   change2Source.Release();
   change2.Release();
   f1_S1_param1.Release();
   delete f1_S1;
   f2_S2_param1.Release();
   delete f2_S2;
   sum1Source.Release();
   sum1.Release();
   sum2Source.Release();
   sum2.Release();
   percent_S_S3_param1.Release();
   percent_S_S3_param2.Release();
   delete percent_S_S3;
   stdev1Source.Release();
   stdev1.Release();
   highest1Source.Release();
   lowest1Source.Release();
   ema1Source.Release();
   ema1.Release();
   delete barcolor1;
   delete plotcandle1;
   ema2Source.Release();
   ema2.Release();
   delete plot1;
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   delete barcolor2;
   delete _signaler;
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   crossunder2X.Release();
   crossunder2Y.Release();
   crossunder2.Release();
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
      change1Source.Init();
      alma1Source.Init();
      rsi1X.Init();
      ArrayInitialize(rsi, EMPTY_VALUE);
      change2Source.Init();
      f1_S1_param1.Init();
      f2_S2_param1.Init();
      sum1Source.Init();
      sum2Source.Init();
      percent_S_S3_param1.Init();
      percent_S_S3_param2.Init();
      ArrayInitialize(chandeMO, EMPTY_VALUE);
      stdev1Source.Init();
      highest1Source.Init();
      lowest1Source.Init();
      ema1Source.Init();
      ArrayInitialize(currentSignal, 0);
      ArrayInitialize(barColor, NULL);
      barcolor1.Init();
      plotcandle1.Init();
      ema2Source.Init();
      plot1.Init(EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      crossover1X.Init();
      crossover1Y.Init();
      ArrayInitialize(plot4, EMPTY_VALUE);
      crossunder1X.Init();
      crossunder1Y.Init();
      barcolor2.Init();
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
      currentSignal[pos] = pos < rates_total - 1 ? currentSignal[pos + 1] : 0;
      barColor[pos] = pos < rates_total - 1 ? barColor[pos + 1] : NULL;
      double offset = 0.85;
      int sigma1 = 7;
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { continue; }
      change1Source.SetValue(pos, srcValue);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { continue; }
      double pchange = SafeMultiply(SafeDivide(change1Value, srcValue), 100);
      alma1Source.SetValue(pos, pchange);
      double alma1Value;
      if (!alma1.GetValue(pos, alma1Value)) { continue; }
      double avpchange = alma1Value;
      rsi1X.SetValue(pos, close[pos]);
      double rsi1Value;
      if (!rsi1.GetValue(pos, rsi1Value)) { continue; }
      rsi[pos] = rsi1Value;
      if (pos + 1 > rates_total - 1) { continue; }
      bool rsiL = SafeGreater(rsi[pos], rsi[pos + 1]);
      if (pos + 1 > rates_total - 1) { continue; }
      bool rsiS = SafeLess(rsi[pos], rsi[pos + 1]);
      int length11 = 9;
      double src1 = close[pos];
      change2Source.SetValue(pos, src1);
      double change2Value;
      if (!change2.GetValue(pos, change2Value)) { continue; }
      double momm = change2Value;
      f1_S1_param1.SetValue(pos, momm);
      double f1_S1Value;
      if (!f1_S1.GetValue(pos, f1_S1Value)) { continue; }
      double m1 = f1_S1Value;
      f2_S2_param1.SetValue(pos, momm);
      double f2_S2Value;
      if (!f2_S2.GetValue(pos, f2_S2Value)) { continue; }
      double m2 = f2_S2Value;
      sum1Source.SetValue(pos, m1);
      double sum1Value;
      if (!sum1.GetValue(pos, sum1Value)) { continue; }
      double sm1 = sum1Value;
      sum2Source.SetValue(pos, m2);
      double sum2Value;
      if (!sum2.GetValue(pos, sum2Value)) { continue; }
      double sm2 = sum2Value;
      percent_S_S3_param1.SetValue(pos, SafeMinus(sm1, sm2));
      percent_S_S3_param2.SetValue(pos, SafePlus(sm1, sm2));
      double percent_S_S3Value;
      if (!percent_S_S3.GetValue(pos, percent_S_S3Value)) { continue; }
      chandeMO[pos] = percent_S_S3Value;
      if (pos + 1 > rates_total - 1) { continue; }
      bool cL = SafeGreater(chandeMO[pos], chandeMO[pos + 1]);
      if (pos + 1 > rates_total - 1) { continue; }
      bool cS = SafeLess(chandeMO[pos], chandeMO[pos + 1]);
      double gma = 0.0;
      double sumOfWeights = 0.0;
      stdev1Source.SetValue(pos, close[pos]);
      double stdev1Value;
      if (!stdev1.GetValue(pos, stdev1Value)) { continue; }
      double sigma = (adaptive ? stdev1Value : param7);
      int for1_from = 0;
      int for1_to = length - 1;
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { continue; }
      for (int i = for1_from; i <= for1_to; i += 1)
      {
         double weight = MathExp(SafeDivide((-SafeMathPow((SafeDivide((i - (length - 1)), (SafeMultiply(2, sigma)))), 2)), 2));
         highest1Source.SetValue(pos, avpchange);
         double highest1Value;
         if (!HighestHighStream::GetValue(pos, highest1Value, highest1Source, i + 1)) { continue; }
         lowest1Source.SetValue(pos, avpchange);
         double lowest1Value;
         if (!LowestLowStream::GetValue(pos, lowest1Value, lowest1Source, i + 1)) { continue; }
         double value = SafePlus(highest1Value, lowest1Value);
         gma = SafePlus(gma, (SafeMultiply(value, weight)));
         sumOfWeights = SafePlus(sumOfWeights, weight);
      }
      gma = SafeDivide((SafeDivide(gma, sumOfWeights)), 2);
      ema1Source.SetValue(pos, gma);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { continue; }
      gma = ema1Value;
      color gmaColor = (SafeGE(avpchange, gma) ? ColorRGB(0, 161, 5, 0) : ColorRGB(215, 0, 0, 0));
      currentSignal[pos] = (SafeGE(avpchange, gma) ? 1 : (-1));
      if ((currentSignal[pos] == 1))
      {
         barColor[pos] = ColorRGB(0, 186, 6, 0);
      }
      else if ((currentSignal[pos] == (-1)))
      {
         barColor[pos] = ColorRGB(176, 0, 0, 0);
      }
      color barcolor1_color = barColor[pos];
      if (barcolor1_color != EMPTY_VALUE)
      {
         barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor1_color);
      }
      else
      {
         barcolor1.Clear(pos);
      }
      double plotcandle1_open = open[pos];
      double plotcandle1_close = close[pos];
      color plotcandle1_color = barColor[pos];
      if (plotcandle1_color != EMPTY_VALUE)
      {
         plotcandle1.Set(pos, plotcandle1_open, high[pos], low[pos], plotcandle1_close, plotcandle1_color);
      }
      else
      {
         plotcandle1.Clear(pos);
      }
      ema2Source.SetValue(pos, close[pos]);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { continue; }
      double ema = ema2Value;
      plot1.SetByColor(ema, pos, gmaColor);
      crossover1X.SetValue(pos, avpchange);
      crossover1Y.SetValue(pos, gma);
      double crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { continue; }
      if (crossover1Value && (pos > 0)) { if (pos + 1 > rates_total - 1) { continue; } plot3[pos] = low[pos + 1]; }
      crossunder1X.SetValue(pos, avpchange);
      crossunder1Y.SetValue(pos, gma);
      double crossunder1Value;
      if (!crossunder1.GetValue(pos, crossunder1Value)) { continue; }
      if (crossunder1Value && (pos > 0)) { if (pos + 1 > rates_total - 1) { continue; } plot4[pos] = high[pos + 1]; }
      color barcolor2_color = gmaColor;
      if (barcolor2_color != EMPTY_VALUE)
      {
         barcolor2.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor2_color);
      }
      else
      {
         barcolor2.Clear(pos);
      }
      crossover2X.SetValue(pos, avpchange);
      crossover2Y.SetValue(pos, gma);
      double crossover2Value;
      if (!crossover2.GetValue(pos, crossover2Value)) { continue; }
      if (crossover2Value && (pos > 0)) { _signaler.SendNotifications("Buy Signal", "Go Long! {{exchange}}:{{ticker}}"); }
      crossunder2X.SetValue(pos, avpchange);
      crossunder2Y.SetValue(pos, gma);
      double crossunder2Value;
      if (!crossunder2.GetValue(pos, crossunder2Value)) { continue; }
      if (crossunder2Value && (pos > 0)) { _signaler.SendNotifications("Sell Signal", "Go Short! {{exchange}}:{{ticker}}"); }
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