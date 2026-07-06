//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76003

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

#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots 4
#property indicator_label1 "USI"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0xb87e37
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Zero Line"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Silver
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_FILLING
#property indicator_width3 1
#property indicator_type4 DRAW_FILLING
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

// price stream factory v2.0

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

   virtual bool GetValues(const int period, const int count, T &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, T &val[]) = 0;
};

#endif

//AOnStream v3.0
class AStreamBase : public TIStream<double>
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
   }

   ~AStreamBase()
   {
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
// AStream v1.1

class AStream : public AStreamBase
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   AStream(string symbol, ENUM_TIMEFRAMES timeframe)
      :AStreamBase()
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   ~AStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};
// IBarStream v2.0



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

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};
#endif


// Price stream v3.1

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

   virtual bool GetSeriesValues(const int period, const int count, double &values[])
   {
      int pos = Size() - 1 - period;
      return GetValues(pos, count, values);
   }

   virtual bool GetValues(const int period, const int count, double &values[])
   {
      for (int i = 0; i < count; ++i)
      {
         double val;
         switch (_price)
         {
            case PriceClose:
               if (!_source.GetClose(period - i, val))
               {
                  return false;
               }
               break;
            case PriceOpen:
               if (!_source.GetOpen(period - i, val))
               {
                  return false;
               }
               break;
            case PriceHigh:
               if (!_source.GetHigh(period - i, val))
               {
                  return false;
               }
               break;
            case PriceLow:
               if (!_source.GetLow(period - i, val))
               {
                  return false;
               }
               break;
            case PriceMedian:
               {
                  double high, low;
                  if (!_source.GetHighLow(period - i, high, low))
                  {
                     return false;
                  }
                  val = (high + low) / 2.0;
               }
               break;
            case PriceTypical:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close) / 3.0;
               }
               break;
            case PriceWeighted:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close * 2) / 4.0;
               }
               break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period - i, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period - i, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period - i, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         }
         values[i] = val;
      }
      return true;
   }
};

#endif
// Bar stream v2.0



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
      period = Size() - iBarShift(_symbol, _timeframe, date) + 1;
      return true;
   }
   
   virtual bool GetDate(const int period, datetime &dt)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      dt = iTime(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos + count - 1)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int oldPos, const int count, double &val[])
   {
      int size = Size();
      if (size <= oldPos + count - 1)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual void Refresh() { }
};

#endif

class PriceStreamFactory
{
public:
   static TIStream<double>* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      TIStream<double>* stream = new PriceStream(source, price);
      source.Release();
      return stream;
   }
};
#endif
// syminfo.* functions from Pine Script
// v1.0

class SymInfo
{
public:
   static double Mintick(string symbol)
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   
   static string Ticker()
   {
      return _Symbol;
   }
};
// Pine-script like safe operations
// v1.2

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
      return INT_MIN;
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

double SafeMathMax(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(MathMax(param1, param2), param3);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathMin(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(MathMin(param1, param2), param3);
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
      return INT_MIN;
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
#define ColorRGB(red, green, blue, transp) (uint)((red) + ((green) << 8) + ((blue) << 16) + ((uint)(transp * 2.55) << 24))
#define ColorR(clr) ((clr & 0x00FF0000) >> 16)
#define ColorG(clr) ((clr & 0x0000FF00) >> 8)
#define ColorB(clr) (clr & 0x000000FF)
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
   double range = topValue - bottomValue;
   double rate = (value - bottomValue) / range;
   if (rate > 1)
   {
      return bottomColor;
   }
   if (rate < 0)
   {
      return topColor;
   }
   uint bottomR = ColorR(bottomColor);
   uint bottomG = ColorG(bottomColor);
   uint bottomB = ColorB(bottomColor);
   uint topR = ColorR(topColor);
   uint topG = ColorG(topColor);
   uint topB = ColorB(topColor);
   return ColorRGB(bottomR + int(rate * (topR - bottomR)), bottomG + int(rate * (topG - bottomG)), bottomB + int(rate * (topB - bottomB)), 0);
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

class PineScriptTime
{
public:
   static int Day(datetime dt)
   {
      MqlDateTime date;
      TimeToStruct(dt, date);
      return date.day;
   }
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
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v2.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL


class AFloatStream : public TIStream<double>
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
// Float stream v2.1

class FloatStream : public AFloatStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
   double _emptyValue;
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe, double emptyValue = EMPTY_VALUE)
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
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == _emptyValue)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
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


//AOnStream v3.0
class AOnStream : public AStreamBase
{
protected:
   TIStream<double> *_source;
public:
   AOnStream(TIStream<double> *source)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
   {
      _source.Release();
   }
   
   virtual bool GetSeriesValue(const int period, double &val) = 0;

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};
//SMAOnStream v5.0

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double summ = 0;
      for (int i = 0; i < _length; ++i)
      {
         double price[1];
         if (!_source.GetSeriesValues(period + i, 1, price))
            return false;
         summ += price[0];
      }
      val = summ / _length;
      return true;
   }
};
// Colored fill v2.1



#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredTopBottomFill
{
   double p1[];
   double p2[];
   int colorsCount;
   uint topColor;
   uint bottomColor;
   int streamIndex;
   double top;
   double bottom;
public:
   ColoredTopBottomFill(int streamIndex, double top, double bottom, uint topColor, uint bottomColor)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      this.top = top;
      this.bottom = bottom;
      this.topColor = topColor;
      this.bottomColor = bottomColor;
   }
   ~ColoredTopBottomFill()
   {
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }

   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, GetColorOnly(topColor));
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, GetColorOnly(topColor));
      return id + 2;
   }
   
   void Set(int period, double value1, double value2)
   {
      if (value1 == EMPTY_VALUE || value2 == EMPTY_VALUE)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      double sum = value1 + value2;
      double avgValue = sum == 0 ? 0 : sum / 2;
      if (avgValue > top || avgValue < bottom)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
};
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   uint upColor;
   uint dnColor;
   uint topColor;
   uint bottomColor;
   int streamIndex;
   TIStream<double>* top;
   TIStream<double>* bottom;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      top = NULL;
      bottom = NULL;
   }
   ~ColoredFill()
   {
      if (top != NULL)
      {
         top.Release();
      }
      if (bottom != NULL)
      {
         bottom.Release();
      }
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void SetTopBottom(TIStream<double>* top, TIStream<double>* bottom, int topColor, int bottomColor)
   {
      this.top = top;
      top.AddRef();
      this.bottom = bottom;
      bottom.AddRef();
      this.topColor = topColor;
      this.bottomColor = bottomColor;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      clr = GetColorOnly(clr);
      dnColor = colorsCount == 0 ? clr : upColor;
      upColor = clr;
      colorsCount++;
   }
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, upColor); 
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, dnColor);
      return id + 2;
   }
   
   void Set(int period, double value1, double value2, uint clr = INT_MAX)
   {
      int transp = GetTranparency(clr);
      if (clr == INT_MAX || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE || transp == 100)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      value1 = LimitValue(period, value1);
      value2 = LimitValue(period, value2);
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
private:
   double LimitValue(int pos, double value)
   {
      if (top == NULL || bottom == NULL)
      {
         return value;
      }
      double topValue[1];
      if (!top.GetValues(pos, 1, topValue))
      {
         return value;
      }
      double bottomValue[1];
      if (!bottom.GetValues(pos, 1, bottomValue))
      {
         return value;
      }
      if (value > topValue[0])
      {
         return topValue[0];
      }
      if (value < bottomValue[0])
      {
         return bottomValue[0];
      }
      return value;
   }   
};
#endif
input int param1 = 28; // USI Length:
input PriceType param2 = PriceClose; // Source
input int bars_limit = 1000; // Bars limit
string title;
string stitle;
int length1;
TIStream<double>* param2Stream;
class UltimateSmoother_fS_iStream
{
   TIStream<double>* src;
   int period;
   double us[];
   double us_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   UltimateSmoother_fS_iStream(TIStream<double>* src, int period, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.src = src;
      src.AddRef();
      this.period = period;
   }
   ~UltimateSmoother_fS_iStream()
   {
      src.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, us, INDICATOR_CALCULATIONS);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double &__out1)
   {
      if (!_initialized)
      {
         us_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(us, us_DEFAULT_VALUE);
         _initialized = true;
      }
      double a1 = SafeMathExp(SafeDivide((-1.414) * 3.1415926535897932, period));
      double c2 = SafeMultiply(SafeMultiply(2.0, a1), SafeCos(SafeDivide(1.414 * 3.1415926535897932, period)));
      double c3 = SafeMultiply(InvertSign(a1), a1);
      double c1 = SafeDivide((SafeMinus(SafePlus(1.0, c2), c3)), 4.0);
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      SetStream(us, pos, srcValue[0], us_DEFAULT_VALUE);
      if ((pos >= 4))
      {
         double srcValue_1[1];
         if (!src.GetValues(pos - 1, 1, srcValue_1)) { srcValue_1[0] = EMPTY_VALUE; }
         double srcValue_2[1];
         if (!src.GetValues(pos - 2, 1, srcValue_2)) { srcValue_2[0] = EMPTY_VALUE; }
         if (pos - 1 < 0) { return false; }
         if (pos - 2 < 0) { return false; }
         SetStream(us, pos, SafePlus(SafeMultiply((SafeMinus(1.0, c1)), srcValue[0]), SafePlus(SafeMinus(SafeMultiply((SafeMinus(SafeMultiply(2.0, c1), c2)), srcValue_1[0]), SafeMultiply((SafePlus(c1, c3)), srcValue_2[0])), SafePlus(SafeMultiply(c2, Nz(us[pos - 1])), SafeMultiply(c3, Nz(us[pos - 2]))))), us_DEFAULT_VALUE);
      }
      __out1 = us[pos];
      return true;
   }
};
class UltimateStrengthIndex_fS_i_iStream
{
   TIStream<double>* src;
   int l1;
   int l2;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   FloatStream* UltimateSmoother_fS_i1_param1;
   UltimateSmoother_fS_iStream* UltimateSmoother_fS_i1;
   FloatStream* sma2Source;
   SmaOnStream* sma2;
   FloatStream* UltimateSmoother_fS_i2_param1;
   UltimateSmoother_fS_iStream* UltimateSmoother_fS_i2;
   double USI[];
   double USI_DEFAULT_VALUE;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   UltimateStrengthIndex_fS_i_iStream(TIStream<double>* src, int l1, int l2, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.src = src;
      src.AddRef();
      this.l1 = l1;
      this.l2 = l2;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, l2);
      sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma2 = new SmaOnStream(sma2Source, l2);
   }
   ~UltimateStrengthIndex_fS_i_iStream()
   {
      src.Release();
      sma1Source.Release();
      sma1.Release();
      UltimateSmoother_fS_i1_param1.Release();
      delete UltimateSmoother_fS_i1;
      sma2Source.Release();
      sma2.Release();
      UltimateSmoother_fS_i2_param1.Release();
      delete UltimateSmoother_fS_i2;
   }
   int Init(int id)
   {
      UltimateSmoother_fS_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
      UltimateSmoother_fS_i1 = new UltimateSmoother_fS_iStream(UltimateSmoother_fS_i1_param1, l1, IndicatorObjPrefix + "_1");
      id = UltimateSmoother_fS_i1.Init(id);
      UltimateSmoother_fS_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
      UltimateSmoother_fS_i2 = new UltimateSmoother_fS_iStream(UltimateSmoother_fS_i2_param1, l1, IndicatorObjPrefix + "_2");
      id = UltimateSmoother_fS_i2.Init(id);
      SetIndexBuffer(id++, USI, INDICATOR_CALCULATIONS);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double &__out1)
   {
      if (!_initialized)
      {
         sma1Source.Init();
         UltimateSmoother_fS_i1_param1.Init();
         UltimateSmoother_fS_i1.Clear();
         sma2Source.Init();
         UltimateSmoother_fS_i2_param1.Init();
         UltimateSmoother_fS_i2.Clear();
         USI_DEFAULT_VALUE = 0.0;
         ArrayInitialize(USI, USI_DEFAULT_VALUE);
         _initialized = true;
      }
      double eps = SymInfo::Mintick(_Symbol);
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      double srcValue_1[1];
      if (!src.GetValues(pos - 1, 1, srcValue_1)) { srcValue_1[0] = EMPTY_VALUE; }
      double diff = SafeMinus(srcValue[0], srcValue_1[0]);
      double SU = (SafeGreater(diff, 0.0) ? diff : 0.0);
      double SD = (SafeLess(diff, 0.0) ? InvertSign(diff) : 0.0);
      sma1Source.SetValue(pos, SU);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
      UltimateSmoother_fS_i1_param1.SetValue(pos, sma1Value[0]);
      double UltimateSmoother_fS_i1Value;
      if (!UltimateSmoother_fS_i1.GetValue(pos, oldPos, UltimateSmoother_fS_i1Value)) { UltimateSmoother_fS_i1Value = EMPTY_VALUE; }
      double USU = UltimateSmoother_fS_i1Value;
      sma2Source.SetValue(pos, SD);
      double sma2Value[1];
      if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
      UltimateSmoother_fS_i2_param1.SetValue(pos, sma2Value[0]);
      double UltimateSmoother_fS_i2Value;
      if (!UltimateSmoother_fS_i2.GetValue(pos, oldPos, UltimateSmoother_fS_i2Value)) { UltimateSmoother_fS_i2Value = EMPTY_VALUE; }
      double USD = UltimateSmoother_fS_i2Value;
      if (pos - 1 < 0) { return false; }
      SetStream(USI, pos, Nz(USI[pos - 1]), USI_DEFAULT_VALUE);
      if ((SafePlus(USU, USD) != 0) && SafeGreater(USU, eps) && SafeGreater(USD, eps))
      {
         SetStream(USI, pos, SafeDivide((SafeMinus(USU, USD)), (SafePlus(USU, USD))), USI_DEFAULT_VALUE);
      }
      __out1 = USI[pos];
      return true;
   }
};
FloatStream* UltimateStrengthIndex_fS_i_i3_param1;
UltimateStrengthIndex_fS_i_iStream* UltimateStrengthIndex_fS_i_i3;
double plot1[];
double plot2[];
ColoredFill* fill3;
FloatStream* fill3Top;
FloatStream* fill3Bottom;
ColoredFill* fill4;
FloatStream* fill4Top;
FloatStream* fill4Bottom;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
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

void OnInit()
{
   length1 = param1;
   param2Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param2);
   int id = 0;
   SetIndexBuffer(id++, plot1, INDICATOR_DATA);
   SetIndexBuffer(id++, plot2, INDICATOR_DATA);
   fill3 = new ColoredFill(2);
   fill3Top = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fill3Bottom = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fill3.SetTopBottom(fill3Top, fill3Bottom, AddTransparency(0x4aaf4d, 50), AddTransparency(0x4aaf4d, 100));
   id = fill3.RegisterStreams(id);
   fill4 = new ColoredFill(3);
   fill4Top = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fill4Bottom = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fill4.SetTopBottom(fill4Top, fill4Bottom, AddTransparency(0x1c1ae4, 100), AddTransparency(0x1c1ae4, 50));
   id = fill4.RegisterStreams(id);
   IndicatorObjPrefix = GenerateIndicatorPrefix(stitle);
   IndicatorSetString(INDICATOR_SHORTNAME, title);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   UltimateStrengthIndex_fS_i_i3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
   UltimateStrengthIndex_fS_i_i3 = new UltimateStrengthIndex_fS_i_iStream(UltimateStrengthIndex_fS_i_i3_param1, length1, 4, IndicatorObjPrefix + "_3");
   id = UltimateStrengthIndex_fS_i_i3.Init(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   param2Stream.Release();
   UltimateStrengthIndex_fS_i_i3_param1.Release();
   delete UltimateStrengthIndex_fS_i_i3;
   fill3Top.Release();
   fill3Bottom.Release();
   delete fill3;
   fill4Top.Release();
   fill4Bottom.Release();
   delete fill4;
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
      UltimateStrengthIndex_fS_i_i3_param1.Init();
      UltimateStrengthIndex_fS_i_i3.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      fill3.Init();
      fill4.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      title = "TASC 2024.11 Ultimate Strength Index";
      stitle = "USI";
      double param2StreamValue[1];
      if (!param2Stream.GetValues(pos, 1, param2StreamValue)) { param2StreamValue[0] = EMPTY_VALUE; }
      double src = param2StreamValue[0];
      UltimateStrengthIndex_fS_i_i3_param1.SetValue(pos, src);
      double UltimateStrengthIndex_fS_i_i3Value;
      if (!UltimateStrengthIndex_fS_i_i3.GetValue(pos, oldPos, UltimateStrengthIndex_fS_i_i3Value)) { UltimateStrengthIndex_fS_i_i3Value = EMPTY_VALUE; }
      double usi = UltimateStrengthIndex_fS_i_i3Value;
      plot1[pos] = usi;
      double usiLine = plot1[pos];
      plot2[pos] = 0;
      double midLine = plot2[pos];
      fill3Top.SetValue(pos, 1);
      fill3Bottom.SetValue(pos, 0);
      double fill3_val1 = usiLine;
      double fill3_val2 = midLine;
      fill3.Set(pos, fill3_val1, fill3_val2);
      fill4Top.SetValue(pos, 0);
      fill4Bottom.SetValue(pos, (-1));
      double fill4_val1 = usiLine;
      double fill4_val2 = midLine;
      fill4.Set(pos, fill4_val1, fill4_val2);
   }
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76003

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