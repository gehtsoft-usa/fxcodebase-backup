//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76090

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 0

#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract integer stream v1.0

#ifndef TAStream_IMPL
#define TAStream_IMPL
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

   virtual bool GetValue(const int period, T &val) = 0;
};

#endif

template <typename T>
class TAStream : public TIStream<T>
{
   int _refs;   
public:
   TAStream()
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
// Float stream v3.0

class FloatStream : public TAStream<double>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
   double _emptyValue;
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe, double emptyValue = EMPTY_VALUE)
   {
      _emptyValue = emptyValue;
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, _emptyValue);
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
      return _stream[index] != _emptyValue;
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


//Base implementation of stream based on another stream 
//v2.0

class AOnStream : public TIStream<double>
{
protected:
   TIStream<double> *_source;
   int _references;
public:
   AOnStream(TIStream<double> *source)
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


// Abstract stream v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

class AStream : public TIStream<double>
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
#ifndef PriceType_IMPL
#define PriceType_IMPL
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
#endif

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


// Highest high stream v2.0

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _loopback = loopback;
      _source.Release();
   }
   HighestHighStream(TIStream<double>* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int loopback)
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


// SMA on stream v2.0
#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   SmaOnStream(TIStream<double> *source, const int length)
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


// Average true range stream v3.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   TIStream<double>* _avg;
public:
   ATRStream(int length)
      :AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
   {
      TIStream<double>* tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      TIStream<double>* tr = new TrueRangeStream(symbol, timeframe, true);
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
#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL

// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ICondition_DEF
#define ICondition_DEF

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};
#endif

//ConditionStreamV2 v2.0

class ConditionStreamV2 : public TAStream<int>
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

// IBarStream v3.0



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

// Stream-stream condition v2.0

#ifndef StreamStreamCondition_IMP
#define StreamStreamCondition_IMP

class StreamStreamCondition : public ACondition
{
   TIStream<double>* _stream1;
   TIStream<double>* _stream2;
   int _periodShift1;
   int _periodShift2;
   string _name1;
   string _name2;
   TwoStreamsConditionType _condition;
public:
   StreamStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      TwoStreamsConditionType condition,
      TIStream<double>* stream1,
      TIStream<double>* stream2,
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
// Wraps IIntStream and provides TIStream<double>

#ifndef IntToFloatStreamWrapper_IMPL
#define IntToFloatStreamWrapper_IMPL

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

class IntToFloatStreamWrapper : public TAStream<double>
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

//CrossStreamV2 v2.0

class CrossStreamFactory
{
public:
   static TIStream<int>* CreateCross(TIStream<double> *left, TIStream<double>* right)
   {
      OrCondition* or = new OrCondition();
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""), false);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, right, left, "", ""), false);
      ConditionStreamV2* result = new ConditionStreamV2(or);
      or.Release();
      return result;
   }

   static TIStream<int>* CreateCrossunder(TIStream<double> *left, TIStream<double>* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
   static TIStream<int>* CreateCrossunder(TIStream<double> *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      TIStream<int>* condition = CreateCrossunder(left, rightWrapper);
      rightWrapper.Release();
      return condition;
   }

   static TIStream<int>* CreateCrossover(TIStream<double> *left, TIStream<double>* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
   static TIStream<int>* CreateCrossover(IIntStream *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* leftWrapper = new IntToFloatStreamWrapper(left);
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      TIStream<int>* condition = CreateCrossover(leftWrapper, rightWrapper);
      leftWrapper.Release();
      rightWrapper.Release();
      return condition;
   }
   static TIStream<int>* CreateCrossover(TIStream<double> *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      TIStream<int>* condition = CreateCrossover(left, rightWrapper);
      rightWrapper.Release();
      return condition;
   }
};
#endif
// Label v1.6

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   uint _color;
   uint _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   string _textAlign;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   int _window;
   bool globalLabel;
public:
   Label(int x, double y, string labelId, string collectionId, int window, bool globalLabel)
   {
      _refs = 1;
      _window = window;
      _textColor = Yellow;
      _x = x;
      _y = y;
      _labelId = labelId;
      _collectionId = collectionId;
      _font = "Arial";
      _textAlign = "";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      this.globalLabel = globalLabel;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   
   void CopyTo(Label* label)
   {
      label._color = _color;
      label._textColor = _textColor;
      label._text = _text;
      label._textAlign = _textAlign;
      label._x = _x;
      label._y = _y;
      label._font = _font;
      label._style = _style;
      label._size = _size;
      label._yloc = _yloc;
      label._timeframe = _timeframe;
      label._window = _window;
   }
   
   bool IsGlobal()
   {
      return globalLabel;
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
   void SetX(int x) { _x = x; }
   static void SetX(Label* label, int x) { if (label == NULL) { return; } label.SetX(x); }
   void SetY(double y) { _y = y; }
   static void SetY(Label* label, double y) { if (label == NULL) { return; } label.SetY(y); }
   static void SetXY(Label* label, int x, double y)
   {
      if (label == NULL) { return; }
      label.SetX(x);
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
   
   static void SetColor(Label* label, uint clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetColor(clr);
   }
   
   Label* SetColor(uint clr)
   {
      _color = clr;
      return &this;
   }
   
   static void SetTextColor(Label* label, uint clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextColor(clr);
   }
   Label* SetTextColor(uint clr)
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
      StringReplace(_text, "\n", " ");
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
   
   static void SetTextAlign(Label* label, string textAlign)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextAlign(textAlign);
   }
   Label* SetTextAlign(string textAlign)
   {
      _textAlign = textAlign;
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
         else if (_style == "diamond")
         {
            usedText = "\116";
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
         ObjectSetInteger(0, _labelId, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE1, y);
      ObjectSetString(0, _labelId, OBJPROP_TEXT, usedText);
   }
private:
   int GetAnchor()
   {
      if (_yloc == "abovebar")
      {
         return ANCHOR_LOWER;
      }
      if (_yloc == "belowbar")
      {
         return ANCHOR_UPPER;
      }
      return ANCHOR_CENTER;
   }
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
// Collection of labels v1.3

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL



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
         if (_labels[i] != NULL)
         {
            _labels[i].Release();
         }
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
   
   Label* Get(int index)
   {
      int size = ArraySize(_labels);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _labels[index];
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
   
   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new LabelsCollection("");
      }
      else
      {
         _all.ClearLabels();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
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

   static Label* Create(string id, int x, double y, datetime dateId, bool globalLabel = false)
   {
      if (_all == NULL)
      {
         Clear();
      }
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x - 1);
      string labelId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      Label* label = new Label(x, y, labelId, id, WindowOnDropped(), globalLabel);
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      _all.Add(label);
      int allLabelsCount = _all.Count();
      if (allLabelsCount > _maxLabels)
      {
         for (int i = 0; i < allLabelsCount; ++i)
         {
            Label* labelToDelete = _all.Get(i);
            if (!labelToDelete.IsGlobal() && labelToDelete != label)
            {
               Delete(labelToDelete);
               break;
            }
         }
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
      label.Release();
   }
   void DeleteLabel(Label* label)
   {
      RemoveLabel(label);
      label.Release();
   }
   void Add(Label* label)
   {
      int index = FindIndex(label);
      
      int size = ArraySize(_labels);
      ArrayResize(_labels, size + 1);
      _labels[size] = label;
      if (label != NULL)
      {
         label.AddRef();
      }
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
// Collection of lines v1.3

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL

// Line object v1.5

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   uint _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
   string _extend;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window, bool global)
   {
      _extend = "none";
      _refs = 1;
      _x1 = x1;
      _x2 = x2;
      _y1 = y1;
      _y2 = y2;
      _id = id;
      _clr = Blue;
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      _window = window;
      _collectionId = collectionId;
      this.global = global;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   
   void CopyTo(Line* line)
   {
      line._x1 = _x1;
      line._y1 = _y1;
      line._x2 = _x2;
      line._y2 = _y2;
      line._clr = _clr;
      line._width = _width;
      line._timeframe = _timeframe;
      line._style = _style;
      line._window = _window;
      line._extend = _extend;
   }
   
   bool IsGlobal()
   {
      return global;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   static void SetStyle(Line* line, string style)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetStyle(style);
   }
   
   Line* SetStyle(string style)
   {
      _style = style;
      return &this;
   }
   
   static void SetExtend(Line* line, string extend)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetExtend(extend);
   }
   
   Line* SetExtend(string extend)
   {
      _extend = extend;
      return &this;
   }

   void SetXY1(int x, double y)
   {
      _x1 = x;
      _y1 = y;
   }
   static void SetXY1(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY1(x, y);
   }
   
   void SetXY2(int x, double y)
   {
      _x2 = x;
      _y2 = y;
   }
   static void SetXY2(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY2(x, y);
   }

   void SetX1(int x) { _x1 = x; }
   static void SetX1(Line* line, int x) { if (line == NULL) { return; } line.SetX1(x); }
   void SetX2(int x) { _x2 = x; }
   static void SetX2(Line* line, int x) { if (line == NULL) { return; } line.SetX2(x); }
   void SetY1(double y) { _y1 = y; }
   static void SetY1(Line* line, double y) { if (line == NULL) { return; } line.SetY1(y); }
   void SetY2(double y) { _y2 = y; }
   static void SetY2(Line* line, double y) { if (line == NULL) { return; } line.SetY2(y); }

   int GetX1() { return _x1; }
   static int GetX1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX1(); }
   int GetX2() { return _x2; }
   static int GetX2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX2(); }
   double GetY1() { return _y1; }
   static double GetY1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY1(); }
   double GetY2() { return _y2; }
   static double GetY2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY2(); }

   Line* SetColor(uint clr)
   {
      _clr = clr;
      return &this;
   }
   static void SetColor(Line* line, uint clr)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetColor(clr);
   }

   static void SetWidth(Line* line, int width)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetWidth(width);
   }

   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }

   void Redraw()
   {
      if (_y1 == EMPTY_VALUE || _y2 == EMPTY_VALUE)
      {
         return;
      }
      int pos1 = iBars(_Symbol, _timeframe) - _x1 - 1;
      datetime x1 = iTime(_Symbol, _timeframe, pos1);
      int pos2 = iBars(_Symbol, _timeframe) - _x2 - 1;
      datetime x2 = iTime(_Symbol, _timeframe, pos2);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, GetStyleMQL());
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         if (_extend == "right")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
         }
         else if (_extend == "left")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
         }
         else if (_extend == "both")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
         }
         else if (_extend == "none")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, false);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, false);
         }
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, x2);
   }
private:
   int GetStyleMQL()
   {
      if (_style == "dashed")
      {
         return STYLE_DASH;
      }
      if (_style == "solid")
      {
         return STYLE_SOLID;
      }
      return STYLE_SOLID;
   }
};

class LinesCollection
{
   string _id;
   Line* _array[];
   static LinesCollection* _collections[];
   static LinesCollection* _all;
   static int _max;
public:
   static Line* Get(Line* line, int index)
   {
      if (line == NULL)
      {
         return NULL;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      if (_all == NULL)
      {
         if (!full)
         {
            _all = new LinesCollection("");
         }
      }
      else
      {
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
   }

   static void Delete(Line* line)
   {
      if (line == NULL)
      {
         return;
      }
      if (!_all.DeleteItem(line))
      {
         return;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(line);
   }

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId, bool global = false)
   {
      if (_all == NULL)
      {
         Clear();
      }
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x1 - 1);
      string lineId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, WindowOnDropped(), global);
      LinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(line);
      _all.Add(line);
      int allLinesCount = _all.Count();
      if (allLinesCount > _max)
      {
         for (int i = 0; i < allLinesCount; ++i)
         {
            Line* lineToDelete = _all.Get(i);
            if (!lineToDelete.IsGlobal() && lineToDelete != line)
            {
               Delete(lineToDelete);
               break;
            }
         }
      }
      line.Release();
      return line;
   }

   static void SetMaxLines(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLines();
      }
   }
private:
   LinesCollection(string id)
   {
      _id = id;
   }

   ~LinesCollection()
   {
      ClearItems();
   }
   
   string GetId()
   {
      return _id;
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   int Count()
   {
      return ArraySize(_array);
   }

   Line* GetFirst()
   {
      return _array[0];
   }

   Line* Get(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[index];
   }
   Line* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }
   
   int FindIndex(Line* line)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == line)
         {
            return i;
         }
      }
      return -1;
   }

   bool DeleteItem(Line* line)
   {
      int index = FindIndex(line);
      if (index == -1)
      {
         return false;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      return true;
   }
   
   void Add(Line* line)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = line;
      if (line != NULL)
      {
         line.AddRef();
      }
   }

   void RedrawLines()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(LinesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LinesCollection* FindCollection(string id)
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
LinesCollection* LinesCollection::_collections[];
LinesCollection* LinesCollection::_all;
int LinesCollection::_max = 50;
#endif
// str.* functions from Pine Script
// v1.0

class Str
{
public:
   static string ToString(int value, string format)
   {
      if (format == "percent")
      {
         return IntegerToString(value, 2) + "%";
      }
      return IntegerToString(value);
   }
   static string ToString(double value, string format)
   {
      if (format == "percent")
      {
         return DoubleToString(value, 2) + "%";
      }
      return DoubleToString(value);
   }
   static string ToString(double value)
   {
      return DoubleToString(value);
   }
   static string ToString(int value)
   {
      return IntegerToString(value);
   }
   static string ToString(string value)
   {
      return value;
   }
   static string ReplaceAll(string source, string target, string replaceWith)
   {
      StringReplace(source, target, replaceWith);
      return source;
   }
   static bool Contains(string source, string str)
   {
      return StringFind(source, str) >= 0;
   }
};

enum StrFormatValueType
{
   String,
   Integer,
   Float
};
interface IStrFormatValue
{
public:
   virtual StrFormatValueType GetType() = 0;
};
class StrFormatStringValue : public IStrFormatValue
{
   string value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::String;
   }
   
   void SetValue(string val)
   {
      value = val;
   }
   string GetValue()
   {
      return value;
   }
};
class StrFormatIntValue : public IStrFormatValue
{
   int value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Integer;
   }
   
   void SetValue(int val)
   {
      value = val;
   }
   int GetValue()
   {
      return value;
   }
};
class StrFormatDoubleValue : public IStrFormatValue
{
   double value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Float;
   }
   
   void SetValue(double val)
   {
      value = val;
   }
   double GetValue()
   {
      return value;
   }
};
class StrFormat
{
   string format;
   IStrFormatValue* values[];
   int nextValueIndex;
public:
   StrFormat(string format)
   {
      this.format = format;
      nextValueIndex = 0;
   }
   ~StrFormat()
   {
      int size = ArraySize(values);
      for (int i = 0; i < size; ++i)
      {
         delete values[i];
      }
   }
   
   StrFormat* Add(string value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatStringValue();
      }
      ((StrFormatStringValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(int value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatIntValue();
      }
      ((StrFormatIntValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(double value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatDoubleValue();
      }
      ((StrFormatDoubleValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   
   string Format()
   {
      int size = ArraySize(values);
      string res = format;
      for (int i = 0; i < size; ++i)
      {
         int pos = StringFind(res, "{" + IntegerToString(i));
         if (pos < 0)
         {
            continue;
         }
         int end = StringFind(res, "}", pos + 1);
         if (end < 0)
         {
            continue;
         }
         switch (values[i].GetType())
         {
         case StrFormatValueType::String:
            {
               string strValue = ((StrFormatStringValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + strValue + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Integer:
            {
               int intValue = ((StrFormatIntValue*)values[i]).GetValue();
               string numberFormat = StringSubstr(res, pos + 1, end - pos - 1);
               
               res = StringSubstr(res, 0, pos) + FormatIntValue(intValue, numberFormat) + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Float:
            {
               double doubleValue = ((StrFormatDoubleValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + DoubleToString(doubleValue) + StringSubstr(res, end + 1);
            }
            break;
         }
      }
      nextValueIndex = 0;
      return res;
   }
private:
   string FormatIntValue(int intValue, string numberFormat)
   {
      string tokens[];
      int count = StringSplit(numberFormat, ',', tokens);
      if (count == 1 || tokens[1] != "number")
      {
          return IntegerToString(intValue);
      }
      int precision = GetPrecision(tokens[2]);
      if (precision == 0)
      {
         return IntegerToString(intValue);
      }
      return DoubleToString(intValue, precision);
   }
   
   int GetPrecision(string format)
   {
      int pointPos = StringFind(format, ".");
      if (pointPos < 0)
      {
         return -1;
      }
      return StringLen(format) - pointPos;
   }
};
// Custom integer stream v1.2

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
   int _emptyValue;
public:
   IntStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int emptyValue = INT_MIN)
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
      return _stream[index] != _emptyValue;
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
// Linefill object
// v1.0

class LineFill
{
public:
};
// Line stream v1.1

#ifndef LineStream_IMPL
#define LineStream_IMPL


// Template for custom stream v1.0

#ifndef TStream_IMPL
#define TStream_IMPL



template <typename T>
class TStream : public TAStream<T>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   T _stream[];
   T _emptyValue;
public:
   TStream(const string symbol, const ENUM_TIMEFRAMES timeframe, T emptyValue)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _emptyValue = emptyValue;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = _emptyValue;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, T value)
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

   bool GetValue(const int period, T &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != _emptyValue;
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

class LineStream : public TStream<Line*>
{
public:
   LineStream(const string symbol, const ENUM_TIMEFRAMES timeframe, Line* emptyValue = NULL)
      : TStream(symbol, timeframe, emptyValue)
   {
   }
};
#endif
// Label stream v1.1

#ifndef LabelStream_IMPL
#define LabelStream_IMPL




class LabelStream : public TStream<Label*>
{
public:
   LabelStream(const string symbol, const ENUM_TIMEFRAMES timeframe, Label* emptyValue = NULL)
      : TStream<Label*>(symbol, timeframe, emptyValue)
   {
   }
};
#endif
// Custom boolean stream v2.0

#ifndef BoolStream_IMPL
#define BoolStream_IMPL



class BoolStream : public TAStream<int>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   bool _stream[];
   int _emptyValue;
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int emptyValue = -1)
   {
      _emptyValue = emptyValue;
      _symbol = symbol;
      _timeframe = timeframe;
   }
   void Init()
   {
      ArrayInitialize(_stream, _emptyValue);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, bool value)
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

   bool GetValue(const int period, bool &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != _emptyValue;
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
      return _stream[index] != _emptyValue;
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
input int param1 = 100; // Trend Length
input double param2 = 3; // Channel Width
input int param3 = 50; // Index of future price
input color param4 = 0x97d816; // Up
input color param5 = 0x3f85da; // Dn
input color param6 = 0x97d816; // Up
input color param7 = 0x3f85da; // Dn
input int bars_limit = 100000; // Bars limit
int length;
double multi;
int extend;
uint color_up;
uint color_dn;
double atr;
FloatStream* highest1Source;
ATRStream* atr1;
class channel
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   channel(channel* src)
   {
      _refs = 1;
      this.line_mid1 = src.line_mid1;
      this.line_mid2 = src.line_mid2;
      this.line_top1 = src.line_top1;
      this.line_top2 = src.line_top2;
      this.line_low1 = src.line_low1;
      this.line_low2 = src.line_low2;
   }
   channel(Line* line_mid1 = NULL, Line* line_mid2 = NULL, Line* line_top1 = NULL, Line* line_top2 = NULL, Line* line_low1 = NULL, Line* line_low2 = NULL)
   {
      _refs = 1;
      this.line_mid1 = line_mid1;
      this.line_mid2 = line_mid2;
      this.line_top1 = line_top1;
      this.line_top2 = line_top2;
      this.line_low1 = line_low1;
      this.line_low2 = line_low2;
   }
   ~channel()
   {
   }
   Line* line_mid1;
   static Line* Getline_mid1(channel* self) { return self == NULL ? NULL : self.line_mid1; }
   static void Setline_mid1(channel* self, Line* val) { if (self == NULL) return; self.line_mid1 = val; }
   Line* line_mid2;
   static Line* Getline_mid2(channel* self) { return self == NULL ? NULL : self.line_mid2; }
   static void Setline_mid2(channel* self, Line* val) { if (self == NULL) return; self.line_mid2 = val; }
   Line* line_top1;
   static Line* Getline_top1(channel* self) { return self == NULL ? NULL : self.line_top1; }
   static void Setline_top1(channel* self, Line* val) { if (self == NULL) return; self.line_top1 = val; }
   Line* line_top2;
   static Line* Getline_top2(channel* self) { return self == NULL ? NULL : self.line_top2; }
   static void Setline_top2(channel* self, Line* val) { if (self == NULL) return; self.line_top2 = val; }
   Line* line_low1;
   static Line* Getline_low1(channel* self) { return self == NULL ? NULL : self.line_low1; }
   static void Setline_low1(channel* self, Line* val) { if (self == NULL) return; self.line_low1 = val; }
   Line* line_low2;
   static Line* Getline_low2(channel* self) { return self == NULL ? NULL : self.line_low2; }
   static void Setline_low2(channel* self, Line* val) { if (self == NULL) return; self.line_low2 = val; }
};
channel* c;
class trend_iStream
{
   int length;
   double trend[];
   double trend_DEFAULT_VALUE;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   FloatStream* crossover1X;
   FloatStream* crossover1Y;
   TIStream<int>* crossover1;
   FloatStream* crossunder1X;
   FloatStream* crossunder1Y;
   TIStream<int>* crossunder1;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   trend_iStream(int length, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.length = length;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, length);
      crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
      crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   }
   ~trend_iStream()
   {
      sma1Source.Release();
      sma1.Release();
      crossover1X.Release();
      crossover1Y.Release();
      crossover1.Release();
      crossunder1X.Release();
      crossunder1Y.Release();
      crossunder1.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, trend);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, int &__out1)
   {
      if (!_initialized)
      {
         trend_DEFAULT_VALUE = NumberToBool(NULL);
         ArrayInitialize(trend, trend_DEFAULT_VALUE);
         sma1Source.Init();
         crossover1X.Init();
         crossover1Y.Init();
         crossunder1X.Init();
         crossunder1Y.Init();
         _initialized = true;
      }
      trend[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? trend[pos + 1] : NumberToBool(NULL);
      sma1Source.SetValue(pos, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double sma = sma1Value;
      double upper = SafePlus(sma, atr);
      double lower = SafeMinus(sma, atr);
      crossover1X.SetValue(pos, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      crossover1Y.SetValue(pos, upper);
      int crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { crossover1Value = (-1); }
      int signal_up = crossover1Value;
      crossunder1X.SetValue(pos, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      crossunder1Y.SetValue(pos, lower);
      int crossunder1Value;
      if (!crossunder1.GetValue(pos, crossunder1Value)) { crossunder1Value = (-1); }
      int signal_dn = crossunder1Value;
      if (signal_up)
      {
         SetStream(trend, pos, true, trend_DEFAULT_VALUE);
      }
      if (signal_dn)
      {
         SetStream(trend, pos, false, trend_DEFAULT_VALUE);
      }
      __out1 = trend[pos];
      return true;
   }
};
trend_iStream* trend_i1;
class future_price_iS_iS_fS_fS_iSStream
{
   IIntStream* x1;
   IIntStream* x2;
   TIStream<double>* y1;
   TIStream<double>* y2;
   IIntStream* index;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   future_price_iS_iS_fS_fS_iSStream(IIntStream* x1, IIntStream* x2, TIStream<double>* y1, TIStream<double>* y2, IIntStream* index, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.x1 = x1;
      x1.AddRef();
      this.x2 = x2;
      x2.AddRef();
      this.y1 = y1;
      y1.AddRef();
      this.y2 = y2;
      y2.AddRef();
      this.index = index;
      index.AddRef();
   }
   ~future_price_iS_iS_fS_fS_iSStream()
   {
      x1.Release();
      x2.Release();
      y1.Release();
      y2.Release();
      index.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Label* &__out1)
   {
      double y2Value;
      if (!y2.GetValue(pos, y2Value)) { y2Value = EMPTY_VALUE; }
      double y1Value;
      if (!y1.GetValue(pos, y1Value)) { y1Value = EMPTY_VALUE; }
      int x2Value;
      if (!x2.GetValue(pos, x2Value)) { x2Value = INT_MIN; }
      int x1Value;
      if (!x1.GetValue(pos, x1Value)) { x1Value = INT_MIN; }
      double slope = SafeDivide((y2Value - y1Value), (x2Value - x1Value));
      int indexValue;
      if (!index.GetValue(pos, indexValue)) { indexValue = INT_MIN; }
      double future_price = SafePlus(y1Value, SafeMultiply(slope, (indexValue - x1Value)));
      string switch1Value1 = NULL;
      if ((y1Value > y2Value))
      {
         switch1Value1 = "lower_left";
      }
      else
      {
         switch1Value1 = "upper_left";
      }
      string style = switch1Value1;
      __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", indexValue, future_price, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(AddTransparency(ChartGetInteger(0, CHART_COLOR_FOREGROUND), 80)).SetText(Str::ToString(future_price, "Future Price: \n #.#")).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle(style).SetSize("normal").SetYLoc("price").SetTextAlign("center");
      return true;
   }
};
class color_lines_lnS_lnS_lnS_c_lbSStream
{
   TIStream<Line*>* line_m;
   TIStream<Line*>* line_t;
   TIStream<Line*>* line_l;
   uint _color;
   TIStream<Label*>* label;
   double color_lines[];
   double color_lines_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   color_lines_lnS_lnS_lnS_c_lbSStream(TIStream<Line*>* line_m, TIStream<Line*>* line_t, TIStream<Line*>* line_l, uint _color, TIStream<Label*>* label, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.line_m = line_m;
      line_m.AddRef();
      this.line_t = line_t;
      line_t.AddRef();
      this.line_l = line_l;
      line_l.AddRef();
      this._color = _color;
      this.label = label;
      label.AddRef();
   }
   ~color_lines_lnS_lnS_lnS_c_lbSStream()
   {
      line_m.Release();
      line_t.Release();
      line_l.Release();
      label.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, color_lines);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, LineFill* &__out1)
   {
      if (!_initialized)
      {
         color_lines_DEFAULT_VALUE = _color;
         ArrayInitialize(color_lines, color_lines_DEFAULT_VALUE);
         _initialized = true;
      }
      color_lines[pos] = pos < (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) ? color_lines[pos + 1] : _color;
      Line* line_mValue;
      if (!line_m.GetValue(pos, line_mValue)) { line_mValue = NULL; }
      if (((_color == color_up) ? SafeLE(Line::GetY1(line_mValue), Line::GetY2(line_mValue)) : SafeGE(Line::GetY1(line_mValue), Line::GetY2(line_mValue))))
      {
         SetStream(color_lines, pos, _color, color_lines_DEFAULT_VALUE);
         Line::SetColor(line_mValue, color_lines[pos]);
         Line* line_lValue;
         if (!line_l.GetValue(pos, line_lValue)) { line_lValue = NULL; }
         Line::SetColor(line_lValue, color_lines[pos]);
         Line* line_tValue;
         if (!line_t.GetValue(pos, line_tValue)) { line_tValue = NULL; }
         Line::SetColor(line_tValue, color_lines[pos]);
         Line::SetStyle(line_mValue, "solid");
         Line::SetStyle(line_tValue, "solid");
         Line::SetStyle(line_lValue, "solid");
         Label* labelValue;
         if (!label.GetValue(pos, labelValue)) { labelValue = NULL; }
         Label::SetColor(labelValue, color_lines[pos]);
      }
      if (((_color == color_up) ? SafeGE(Line::GetY1(line_mValue), Line::GetY2(line_mValue)) : SafeLE(Line::GetY1(line_mValue), Line::GetY2(line_mValue))))
      {
         SetStream(color_lines, pos, ChartGetInteger(0, CHART_COLOR_FOREGROUND), color_lines_DEFAULT_VALUE);
         Line::SetColor(line_mValue, color_lines[pos]);
         Line* line_tValue;
         if (!line_t.GetValue(pos, line_tValue)) { line_tValue = NULL; }
         Line::SetColor(line_tValue, color_lines[pos]);
         Line* line_lValue;
         if (!line_l.GetValue(pos, line_lValue)) { line_lValue = NULL; }
         Line::SetColor(line_lValue, color_lines[pos]);
         Line::SetStyle(line_mValue, "dashed");
         Line::SetStyle(line_tValue, "dashed");
         Line::SetStyle(line_lValue, "dashed");
         Label* labelValue;
         if (!label.GetValue(pos, labelValue)) { labelValue = NULL; }
         Label::SetColor(labelValue, AddTransparency(color_lines[pos], 100));
      }
      Label* labelValue;
      if (!label.GetValue(pos, labelValue)) { labelValue = NULL; }
      Label::SetSize(labelValue, "tiny");
      __out1 = NULL;
      return true;
   }
};
class remove_lines_bSStream
{
   TIStream<int>* trend;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   remove_lines_bSStream(TIStream<int>* trend, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.trend = trend;
      trend.AddRef();
   }
   ~remove_lines_bSStream()
   {
      trend.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Line* &__out1)
   {
      int trendValue;
      if (!trend.GetValue(pos, trendValue)) { trendValue = (-1); }
      int trendValue_1;
      if (!trend.GetValue(pos + 1, trendValue_1)) { trendValue_1 = (-1); }
      if (trendValue && !trendValue_1)
      {
         channel::Setline_mid2(c, (Line*)(NULL));
         channel::Setline_top2(c, (Line*)(NULL));
         channel::Setline_low2(c, (Line*)(NULL));
      }
      if (!trendValue && trendValue_1)
      {
         channel::Setline_mid1(c, (Line*)(NULL));
         channel::Setline_top1(c, (Line*)(NULL));
         channel::Setline_low1(c, (Line*)(NULL));
         __out1 = channel::Getline_low1(c);
      }
      return true;
   }
};
class draw_channel_bSStream
{
   TIStream<int>* trend;
   Label* label_up;
   Label* label_dn;
   Label* label_m;
   FloatStream* sma2Source;
   SmaOnStream* sma2;
   FloatStream* sma3Source;
   SmaOnStream* sma3;
   FloatStream* sma4Source;
   SmaOnStream* sma4;
   IntStream* future_price_iS_iS_fS_fS_iS2_param1;
   IntStream* future_price_iS_iS_fS_fS_iS2_param2;
   FloatStream* future_price_iS_iS_fS_fS_iS2_param3;
   FloatStream* future_price_iS_iS_fS_fS_iS2_param4;
   IntStream* future_price_iS_iS_fS_fS_iS2_param5;
   future_price_iS_iS_fS_fS_iSStream* future_price_iS_iS_fS_fS_iS2;
   FloatStream* sma5Source;
   SmaOnStream* sma5;
   FloatStream* sma6Source;
   SmaOnStream* sma6;
   FloatStream* sma7Source;
   SmaOnStream* sma7;
   IntStream* future_price_iS_iS_fS_fS_iS3_param1;
   IntStream* future_price_iS_iS_fS_fS_iS3_param2;
   FloatStream* future_price_iS_iS_fS_fS_iS3_param3;
   FloatStream* future_price_iS_iS_fS_fS_iS3_param4;
   IntStream* future_price_iS_iS_fS_fS_iS3_param5;
   future_price_iS_iS_fS_fS_iSStream* future_price_iS_iS_fS_fS_iS3;
   LineStream* color_lines_lnS_lnS_lnS_c_lbS4_param1;
   LineStream* color_lines_lnS_lnS_lnS_c_lbS4_param2;
   LineStream* color_lines_lnS_lnS_lnS_c_lbS4_param3;
   LabelStream* color_lines_lnS_lnS_lnS_c_lbS4_param5;
   color_lines_lnS_lnS_lnS_c_lbSStream* color_lines_lnS_lnS_lnS_c_lbS4;
   LineStream* color_lines_lnS_lnS_lnS_c_lbS5_param1;
   LineStream* color_lines_lnS_lnS_lnS_c_lbS5_param2;
   LineStream* color_lines_lnS_lnS_lnS_c_lbS5_param3;
   LabelStream* color_lines_lnS_lnS_lnS_c_lbS5_param5;
   color_lines_lnS_lnS_lnS_c_lbSStream* color_lines_lnS_lnS_lnS_c_lbS5;
   BoolStream* remove_lines_bS6_param1;
   remove_lines_bSStream* remove_lines_bS6;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   draw_channel_bSStream(TIStream<int>* trend, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.trend = trend;
      trend.AddRef();
      sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma2 = new SmaOnStream(sma2Source, 20);
      sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma3 = new SmaOnStream(sma3Source, 20);
      sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma4 = new SmaOnStream(sma4Source, 20);
      sma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma5 = new SmaOnStream(sma5Source, 20);
      sma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma6 = new SmaOnStream(sma6Source, 20);
      sma7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma7 = new SmaOnStream(sma7Source, 20);
      color_up = param6;
      color_dn = param7;
   }
   ~draw_channel_bSStream()
   {
      trend.Release();
      sma2Source.Release();
      sma2.Release();
      sma3Source.Release();
      sma3.Release();
      sma4Source.Release();
      sma4.Release();
      future_price_iS_iS_fS_fS_iS2_param1.Release();
      future_price_iS_iS_fS_fS_iS2_param2.Release();
      future_price_iS_iS_fS_fS_iS2_param3.Release();
      future_price_iS_iS_fS_fS_iS2_param4.Release();
      future_price_iS_iS_fS_fS_iS2_param5.Release();
      delete future_price_iS_iS_fS_fS_iS2;
      sma5Source.Release();
      sma5.Release();
      sma6Source.Release();
      sma6.Release();
      sma7Source.Release();
      sma7.Release();
      future_price_iS_iS_fS_fS_iS3_param1.Release();
      future_price_iS_iS_fS_fS_iS3_param2.Release();
      future_price_iS_iS_fS_fS_iS3_param3.Release();
      future_price_iS_iS_fS_fS_iS3_param4.Release();
      future_price_iS_iS_fS_fS_iS3_param5.Release();
      delete future_price_iS_iS_fS_fS_iS3;
      color_lines_lnS_lnS_lnS_c_lbS4_param1.Release();
      color_lines_lnS_lnS_lnS_c_lbS4_param2.Release();
      color_lines_lnS_lnS_lnS_c_lbS4_param3.Release();
      color_lines_lnS_lnS_lnS_c_lbS4_param5.Release();
      delete color_lines_lnS_lnS_lnS_c_lbS4;
      color_lines_lnS_lnS_lnS_c_lbS5_param1.Release();
      color_lines_lnS_lnS_lnS_c_lbS5_param2.Release();
      color_lines_lnS_lnS_lnS_c_lbS5_param3.Release();
      color_lines_lnS_lnS_lnS_c_lbS5_param5.Release();
      delete color_lines_lnS_lnS_lnS_c_lbS5;
      remove_lines_bS6_param1.Release();
      delete remove_lines_bS6;
   }
   int Init(int id)
   {
      future_price_iS_iS_fS_fS_iS2_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period, INT_MIN);
      future_price_iS_iS_fS_fS_iS2_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period, INT_MIN);
      future_price_iS_iS_fS_fS_iS2_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
      future_price_iS_iS_fS_fS_iS2_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
      future_price_iS_iS_fS_fS_iS2_param5 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period, INT_MIN);
      future_price_iS_iS_fS_fS_iS2 = new future_price_iS_iS_fS_fS_iSStream(future_price_iS_iS_fS_fS_iS2_param1, future_price_iS_iS_fS_fS_iS2_param2, future_price_iS_iS_fS_fS_iS2_param3, future_price_iS_iS_fS_fS_iS2_param4, future_price_iS_iS_fS_fS_iS2_param5, IndicatorObjPrefix + "_2");
      id = future_price_iS_iS_fS_fS_iS2.Init(id);
      future_price_iS_iS_fS_fS_iS3_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period, INT_MIN);
      future_price_iS_iS_fS_fS_iS3_param2 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period, INT_MIN);
      future_price_iS_iS_fS_fS_iS3_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
      future_price_iS_iS_fS_fS_iS3_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
      future_price_iS_iS_fS_fS_iS3_param5 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period, INT_MIN);
      future_price_iS_iS_fS_fS_iS3 = new future_price_iS_iS_fS_fS_iSStream(future_price_iS_iS_fS_fS_iS3_param1, future_price_iS_iS_fS_fS_iS3_param2, future_price_iS_iS_fS_fS_iS3_param3, future_price_iS_iS_fS_fS_iS3_param4, future_price_iS_iS_fS_fS_iS3_param5, IndicatorObjPrefix + "_3");
      id = future_price_iS_iS_fS_fS_iS3.Init(id);
      color_lines_lnS_lnS_lnS_c_lbS4_param1 = new LineStream(_Symbol, (ENUM_TIMEFRAMES)_Period, NULL);
      color_lines_lnS_lnS_lnS_c_lbS4_param2 = new LineStream(_Symbol, (ENUM_TIMEFRAMES)_Period, NULL);
      color_lines_lnS_lnS_lnS_c_lbS4_param3 = new LineStream(_Symbol, (ENUM_TIMEFRAMES)_Period, NULL);
      color_lines_lnS_lnS_lnS_c_lbS4_param5 = new LabelStream(_Symbol, (ENUM_TIMEFRAMES)_Period, NULL);
      color_lines_lnS_lnS_lnS_c_lbS4 = new color_lines_lnS_lnS_lnS_c_lbSStream(color_lines_lnS_lnS_lnS_c_lbS4_param1, color_lines_lnS_lnS_lnS_c_lbS4_param2, color_lines_lnS_lnS_lnS_c_lbS4_param3, color_up, color_lines_lnS_lnS_lnS_c_lbS4_param5, IndicatorObjPrefix + "_4");
      id = color_lines_lnS_lnS_lnS_c_lbS4.Init(id);
      color_lines_lnS_lnS_lnS_c_lbS5_param1 = new LineStream(_Symbol, (ENUM_TIMEFRAMES)_Period, NULL);
      color_lines_lnS_lnS_lnS_c_lbS5_param2 = new LineStream(_Symbol, (ENUM_TIMEFRAMES)_Period, NULL);
      color_lines_lnS_lnS_lnS_c_lbS5_param3 = new LineStream(_Symbol, (ENUM_TIMEFRAMES)_Period, NULL);
      color_lines_lnS_lnS_lnS_c_lbS5_param5 = new LabelStream(_Symbol, (ENUM_TIMEFRAMES)_Period, NULL);
      color_lines_lnS_lnS_lnS_c_lbS5 = new color_lines_lnS_lnS_lnS_c_lbSStream(color_lines_lnS_lnS_lnS_c_lbS5_param1, color_lines_lnS_lnS_lnS_c_lbS5_param2, color_lines_lnS_lnS_lnS_c_lbS5_param3, color_dn, color_lines_lnS_lnS_lnS_c_lbS5_param5, IndicatorObjPrefix + "_5");
      id = color_lines_lnS_lnS_lnS_c_lbS5.Init(id);
      remove_lines_bS6_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period, (-1));
      remove_lines_bS6 = new remove_lines_bSStream(remove_lines_bS6_param1, IndicatorObjPrefix + "_6");
      id = remove_lines_bS6.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, Line* &__out1)
   {
      if (!_initialized)
      {
         label_up = (Label*)(NULL);
         label_dn = (Label*)(NULL);
         label_m = (Label*)(NULL);
         sma2Source.Init();
         sma3Source.Init();
         sma4Source.Init();
         future_price_iS_iS_fS_fS_iS2_param1.Init();
         future_price_iS_iS_fS_fS_iS2_param2.Init();
         future_price_iS_iS_fS_fS_iS2_param3.Init();
         future_price_iS_iS_fS_fS_iS2_param4.Init();
         future_price_iS_iS_fS_fS_iS2_param5.Init();
         future_price_iS_iS_fS_fS_iS2.Clear();
         sma5Source.Init();
         sma6Source.Init();
         sma7Source.Init();
         future_price_iS_iS_fS_fS_iS3_param1.Init();
         future_price_iS_iS_fS_fS_iS3_param2.Init();
         future_price_iS_iS_fS_fS_iS3_param3.Init();
         future_price_iS_iS_fS_fS_iS3_param4.Init();
         future_price_iS_iS_fS_fS_iS3_param5.Init();
         future_price_iS_iS_fS_fS_iS3.Clear();
         color_lines_lnS_lnS_lnS_c_lbS4_param1.Init();
         color_lines_lnS_lnS_lnS_c_lbS4_param2.Init();
         color_lines_lnS_lnS_lnS_c_lbS4_param3.Init();
         color_lines_lnS_lnS_lnS_c_lbS4_param5.Init();
         color_lines_lnS_lnS_lnS_c_lbS4.Clear();
         color_lines_lnS_lnS_lnS_c_lbS5_param1.Init();
         color_lines_lnS_lnS_lnS_c_lbS5_param2.Init();
         color_lines_lnS_lnS_lnS_c_lbS5_param3.Init();
         color_lines_lnS_lnS_lnS_c_lbS5_param5.Init();
         color_lines_lnS_lnS_lnS_c_lbS5.Clear();
         remove_lines_bS6_param1.Init();
         remove_lines_bS6.Clear();
         _initialized = true;
      }
      double src = SafeDivide((iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)), 2);
      double low_src = SafeMinus(src, SafeMultiply(atr, multi));
      double high_src = SafePlus(src, SafeMultiply(atr, multi));
      int trendValue;
      if (!trend.GetValue(pos, trendValue)) { trendValue = (-1); }
      int trendValue_1;
      if (!trend.GetValue(pos + 1, trendValue_1)) { trendValue_1 = (-1); }
      if (trendValue && !trendValue_1)
      {
         label_up = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), low_src, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetText("").SetStyle("diamond").SetSize("normal").SetYLoc("price").SetTextAlign("center");
         channel::Setline_mid1(c, LinesCollection::Create(IndicatorObjPrefix + "line_1_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), src, ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), src, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetWidth(1).SetStyle("solid").SetExtend("none"));
         channel::Setline_top1(c, LinesCollection::Create(IndicatorObjPrefix + "line_2_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), high_src, ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), high_src, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetWidth(1).SetStyle("solid").SetExtend("none"));
         channel::Setline_low1(c, LinesCollection::Create(IndicatorObjPrefix + "line_3_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), low_src, ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), low_src, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetWidth(1).SetStyle("solid").SetExtend("none"));
         Line::SetXY2(channel::Getline_mid2(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), src);
         Line::SetXY2(channel::Getline_top2(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), high_src);
         Line::SetXY2(channel::Getline_low2(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), low_src);
      }
      if (!trendValue && trendValue_1)
      {
         label_dn = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), high_src, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetText("").SetStyle("diamond").SetSize("normal").SetYLoc("price").SetTextAlign("center");
         channel::Setline_mid2(c, LinesCollection::Create(IndicatorObjPrefix + "line_4_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), src, ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos) + 2, src, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetWidth(1).SetStyle("solid").SetExtend("none"));
         channel::Setline_top2(c, LinesCollection::Create(IndicatorObjPrefix + "line_5_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), high_src, ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), high_src, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetWidth(1).SetStyle("solid").SetExtend("none"));
         channel::Setline_low2(c, LinesCollection::Create(IndicatorObjPrefix + "line_6_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), low_src, ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), low_src, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetWidth(1).SetStyle("solid").SetExtend("none"));
         Line::SetXY2(channel::Getline_mid1(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), src);
         Line::SetXY2(channel::Getline_top1(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), high_src);
         Line::SetXY2(channel::Getline_low1(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), low_src);
      }
      if (trendValue)
      {
         LabelsCollection::Delete(label_m);
         Line::SetExtend(channel::Getline_mid2(c), "none");
         Line::SetExtend(channel::Getline_top2(c), "none");
         Line::SetExtend(channel::Getline_low2(c), "none");
         Line::SetExtend(channel::Getline_mid1(c), "right");
         Line::SetExtend(channel::Getline_top1(c), "right");
         Line::SetExtend(channel::Getline_low1(c), "right");
         sma2Source.SetValue(pos, src);
         double sma2Value;
         if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
         Line::SetXY2(channel::Getline_mid1(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), sma2Value);
         sma3Source.SetValue(pos, high_src);
         double sma3Value;
         if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
         Line::SetXY2(channel::Getline_top1(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), sma3Value);
         sma4Source.SetValue(pos, low_src);
         double sma4Value;
         if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
         Line::SetXY2(channel::Getline_low1(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), sma4Value);
         future_price_iS_iS_fS_fS_iS2_param1.SetValue(pos, Line::GetX1(channel::Getline_mid1(c)));
         future_price_iS_iS_fS_fS_iS2_param2.SetValue(pos, Line::GetX2(channel::Getline_mid1(c)));
         future_price_iS_iS_fS_fS_iS2_param3.SetValue(pos, Line::GetY1(channel::Getline_mid1(c)));
         future_price_iS_iS_fS_fS_iS2_param4.SetValue(pos, Line::GetY2(channel::Getline_mid1(c)));
         future_price_iS_iS_fS_fS_iS2_param5.SetValue(pos, ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos) + extend);
         Label* future_price_iS_iS_fS_fS_iS2Value;
         if (!future_price_iS_iS_fS_fS_iS2.GetValue(pos, future_price_iS_iS_fS_fS_iS2Value)) { future_price_iS_iS_fS_fS_iS2Value = NULL; }
         label_m = future_price_iS_iS_fS_fS_iS2Value;
      }
      if (!trendValue)
      {
         LabelsCollection::Delete(label_m);
         Line::SetExtend(channel::Getline_mid1(c), "none");
         Line::SetExtend(channel::Getline_top1(c), "none");
         Line::SetExtend(channel::Getline_low1(c), "none");
         Line::SetExtend(channel::Getline_mid2(c), "right");
         Line::SetExtend(channel::Getline_top2(c), "right");
         Line::SetExtend(channel::Getline_low2(c), "right");
         sma5Source.SetValue(pos, src);
         double sma5Value;
         if (!sma5.GetValue(pos, sma5Value)) { sma5Value = EMPTY_VALUE; }
         Line::SetXY2(channel::Getline_mid2(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), sma5Value);
         sma6Source.SetValue(pos, high_src);
         double sma6Value;
         if (!sma6.GetValue(pos, sma6Value)) { sma6Value = EMPTY_VALUE; }
         Line::SetXY2(channel::Getline_top2(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), sma6Value);
         sma7Source.SetValue(pos, low_src);
         double sma7Value;
         if (!sma7.GetValue(pos, sma7Value)) { sma7Value = EMPTY_VALUE; }
         Line::SetXY2(channel::Getline_low2(c), ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), sma7Value);
         future_price_iS_iS_fS_fS_iS3_param1.SetValue(pos, Line::GetX1(channel::Getline_mid2(c)));
         future_price_iS_iS_fS_fS_iS3_param2.SetValue(pos, Line::GetX2(channel::Getline_mid2(c)));
         future_price_iS_iS_fS_fS_iS3_param3.SetValue(pos, Line::GetY1(channel::Getline_mid2(c)));
         future_price_iS_iS_fS_fS_iS3_param4.SetValue(pos, Line::GetY2(channel::Getline_mid2(c)));
         future_price_iS_iS_fS_fS_iS3_param5.SetValue(pos, ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos) + extend);
         Label* future_price_iS_iS_fS_fS_iS3Value;
         if (!future_price_iS_iS_fS_fS_iS3.GetValue(pos, future_price_iS_iS_fS_fS_iS3Value)) { future_price_iS_iS_fS_fS_iS3Value = NULL; }
         label_m = future_price_iS_iS_fS_fS_iS3Value;
      }
      color_lines_lnS_lnS_lnS_c_lbS4_param1.SetValue(pos, channel::Getline_mid1(c));
      color_lines_lnS_lnS_lnS_c_lbS4_param2.SetValue(pos, channel::Getline_top1(c));
      color_lines_lnS_lnS_lnS_c_lbS4_param3.SetValue(pos, channel::Getline_low1(c));
      color_lines_lnS_lnS_lnS_c_lbS4_param5.SetValue(pos, label_up);
      LineFill* color_lines_lnS_lnS_lnS_c_lbS4Value;
      if (!color_lines_lnS_lnS_lnS_c_lbS4.GetValue(pos, color_lines_lnS_lnS_lnS_c_lbS4Value)) { color_lines_lnS_lnS_lnS_c_lbS4Value = NULL; }
      color_lines_lnS_lnS_lnS_c_lbS4Value;
      color_lines_lnS_lnS_lnS_c_lbS5_param1.SetValue(pos, channel::Getline_mid2(c));
      color_lines_lnS_lnS_lnS_c_lbS5_param2.SetValue(pos, channel::Getline_top2(c));
      color_lines_lnS_lnS_lnS_c_lbS5_param3.SetValue(pos, channel::Getline_low2(c));
      color_lines_lnS_lnS_lnS_c_lbS5_param5.SetValue(pos, label_dn);
      LineFill* color_lines_lnS_lnS_lnS_c_lbS5Value;
      if (!color_lines_lnS_lnS_lnS_c_lbS5.GetValue(pos, color_lines_lnS_lnS_lnS_c_lbS5Value)) { color_lines_lnS_lnS_lnS_c_lbS5Value = NULL; }
      color_lines_lnS_lnS_lnS_c_lbS5Value;
      remove_lines_bS6_param1.SetValue(pos, trendValue);
      Line* remove_lines_bS6Value;
      if (!remove_lines_bS6.GetValue(pos, remove_lines_bS6Value)) { remove_lines_bS6Value = NULL; }
      __out1 = remove_lines_bS6Value;
      return true;
   }
};
BoolStream* draw_channel_bS7_param1;
draw_channel_bSStream* draw_channel_bS7;

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
   IndicatorBuffers(3);
   length = param1;
   multi = param2;
   extend = param3;
   color_up = param4;
   color_dn = param5;
   atr1 = new ATRStream(200);
   highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   int id = 0;
   LabelsCollection::SetMaxLabels(50);
   LinesCollection::SetMaxLines(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Future Trend Channel [ChartPrime]");
      c = new channel((Line*)(NULL), (Line*)(NULL), (Line*)(NULL), (Line*)(NULL), (Line*)(NULL), (Line*)(NULL));
   trend_i1 = new trend_iStream(length, IndicatorObjPrefix + "_1");
   id = trend_i1.Init(id);
   draw_channel_bS7_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period, (-1));
   draw_channel_bS7 = new draw_channel_bSStream(draw_channel_bS7_param1, IndicatorObjPrefix + "_7");
   id = draw_channel_bS7.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   highest1Source.Release();
   atr1.Release();
   c.Release();
   delete trend_i1;
   draw_channel_bS7_param1.Release();
   delete draw_channel_bS7;
   LabelsCollection::Clear(true);
   LinesCollection::Clear(true);
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
      LinesCollection::Clear();
      highest1Source.Init();
      trend_i1.Clear();
      draw_channel_bS7_param1.Init();
      draw_channel_bS7.Clear();
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
      highest1Source.SetValue(pos, atr1Value);
      double highest1Value;
      if (!HighestHighStream::GetValue(pos, highest1Value, highest1Source, 100)) { highest1Value = EMPTY_VALUE; }
      atr = highest1Value;
      int trend_i1Value;
      if (!trend_i1.GetValue(pos, trend_i1Value)) { trend_i1Value = (-1); }
      int trend = trend_i1Value;
      draw_channel_bS7_param1.SetValue(pos, trend);
      Line* draw_channel_bS7Value;
      if (!draw_channel_bS7.GetValue(pos, draw_channel_bS7Value)) { draw_channel_bS7Value = NULL; }
      draw_channel_bS7Value;
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LabelsCollection::Redraw();
   LinesCollection::Redraw();
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76090

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 