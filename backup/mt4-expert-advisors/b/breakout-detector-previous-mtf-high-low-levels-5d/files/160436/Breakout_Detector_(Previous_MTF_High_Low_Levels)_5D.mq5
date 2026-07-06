//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76287&sid=9a32304108d7353936a0d115fd152021

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 30
#property indicator_plots 4
#property indicator_type1 DRAW_NONE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_NONE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_NONE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_type4 DRAW_NONE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

// PineScript timeframe.* functions
// v1.2

class Timeframe
{
public:
   static string Period()
   {
      if (_Period == PERIOD_M1) { return "1"; }
      if (_Period == PERIOD_M5) { return "5"; }
      if (_Period == PERIOD_M15) { return "15"; }
      if (_Period == PERIOD_M30) { return "30"; }
      if (_Period == PERIOD_H1) { return "60"; }
      if (_Period == PERIOD_H4) { return "240"; }
      if (_Period == PERIOD_D1) { return "D"; }
      if (_Period == PERIOD_W1) { return "W"; }
      if (_Period == PERIOD_MN1) { return "M"; }
      return "1";
   }
   
   static bool IsDaily()
   {
      return _Period == PERIOD_D1;
   }
   
   static bool IsWeekly()
   {
      return _Period == PERIOD_W1;
   }
   
   static bool IsMonthly()
   {
      return _Period == PERIOD_MN1;
   }
   
   static int InSeconds(string resolution)
   {
      return (int)GetTimeframe(resolution);
   }
   
   static int Multiplier()
   {
      if (_Period == PERIOD_M1) { return 1; }
      if (_Period == PERIOD_M5) { return 5; }
      if (_Period == PERIOD_M15) { return 15; }
      if (_Period == PERIOD_M30) { return 30; }
      if (_Period == PERIOD_H1) { return 1; }
      if (_Period == PERIOD_H4) { return 4; }
      if (_Period == PERIOD_D1) { return 1; }
      if (_Period == PERIOD_W1) { return 1; }
      if (_Period == PERIOD_MN1) { return 1; }
      return 1;
   }
   
   static bool Change(string timeframe, int pos)
   {
      int bars = iBars(_Symbol, _Period);
      if (bars <= pos + 1)
      {
         return true;
      }
      datetime currentBar = iTime(_Symbol, _Period, pos);
      datetime prevBar = iTime(_Symbol, _Period, pos + 1);
      ENUM_TIMEFRAMES tf = GetTimeframe(timeframe);
      return iBarShift(_Symbol, tf, currentBar) != iBarShift(_Symbol, tf, prevBar);
   }
   
   static bool IsDWM()
   {
      switch (_Period)
      {
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return true;
      }
      return false;
   }

   static int Interval()
   {
      switch (_Period)
      {
         case PERIOD_M1:
         case PERIOD_H1:
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return 1;
         case PERIOD_M5:
            return 5;
         case PERIOD_M15:
            return 15;
         case PERIOD_M30:
            return 30;
         case PERIOD_H4:
            return 4;
      }
      return INT_MIN;
   }

   static bool IsIntraday()
   {
      return ~IsDWM();
   }
   
   static string ToString(ENUM_TIMEFRAMES resolution)
   {
      switch (resolution)
      {
         case PERIOD_M1:
            return "1";
         case PERIOD_M5:
            return "5";
         case PERIOD_M15:
            return "15";
         case PERIOD_M30:
            return "30";
         case PERIOD_H1:
            return "60";
         case PERIOD_H4:
            return "240";
         case PERIOD_D1:
            return "D";
         case PERIOD_W1:
            return "W";
         case PERIOD_MN1:
            return "M";
         
      }
      return "";
   }
   
   static ENUM_TIMEFRAMES GetTimeframe(string resolution)
   {
      if (resolution == "1") { return PERIOD_M1; }
      if (resolution == "5") { return PERIOD_M5; }
      if (resolution == "15") { return PERIOD_M15; }
      if (resolution == "30") { return PERIOD_M30; }
      if (resolution == "60" || resolution == "1H") { return PERIOD_H1; }
      if (resolution == "240") { return PERIOD_H4; }
      if (resolution == "D") { return PERIOD_D1; }
      if (resolution == "W") { return PERIOD_W1; }
      if (resolution == "M") { return PERIOD_MN1; }
      return PERIOD_CURRENT;
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
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return (int)MathCeil(value);
}
double SafeMod(int val1, int val2)
{
   if (val1 == INT_MIN || val2 == INT_MIN)
   {
      return EMPTY_VALUE;
   }
   return val1 % val2;
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
#ifndef FixnanStream_IMP
#define FixnanStream_IMP
// Fix NAN stream v1.0



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

class FixnanStream : public AOnStream
{
   int _maxLookback;
public:
   FixnanStream(TIStream<double>* source)
      :AOnStream(source)
   {
      _maxLookback = 1000;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      for (int i = 0; i < _maxLookback; ++i)
      {
         double v[1];
         if (_source.GetSeriesValues(period + i, 1, v))
         {
            val = v[0];
            return true;
         }
      }

      return false;
   }

};

class FixnanStreamFactory
{
public:
   static TIStream<double>* Create(TIStream<double>* source)
   {
      return new FixnanStream(source);
   }
};
#endif
// Pivot high stream v2.0


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

// Simple price stream v1.0
class SimplePriceStream : public AStream
{
   PriceType _price;
   double _pipSize;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PriceClose:
               val[i] = iClose(_symbol, _timeframe, period + i);
               break;
            case PriceOpen:
               val[i] = iOpen(_symbol, _timeframe, period + i);
               break;
            case PriceHigh:
               val[i] = iHigh(_symbol, _timeframe, period + i);
               break;
            case PriceLow:
               val[i] = iLow(_symbol, _timeframe, period + i);
               break;
            case PriceMedian:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i)) / 2.0;
               break;
            case PriceTypical:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i)) / 3.0;
               break;
            case PriceWeighted:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
               break;
            case PriceMedianBody:
               val[i] = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
               break;
            case PriceAverage:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
               break;
            case PriceTrendBiased:
               {
                  double close = iClose(_symbol, _timeframe, period);
                  if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                     val[i] = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
                  else
                     val[i] = (iLow(_symbol, _timeframe, period) + close) / 2.0;
               }
               break;
            case PriceVolume:
               val[i] = (double)iVolume(_symbol, _timeframe, period);
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};


class PivotHighStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotHighStream(TIStream<double> *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceHigh);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }
   
      
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], TIStream<double>* source, int leftBars, int rightBars)
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, source, leftBars, rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int leftBars, int rightBars)
   {
      double center[1];
      if (!source.GetValues(period - rightBars, 1, center))
      {
         return false;
      }
      double value[1];
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValues(period - i, 1, value))
         {
            return false;
         }
         if (center[0] < value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValues(period - ii - rightBars, 1, value))
         {
            return false;
         }
         if (center[0] < value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center[0];
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, _source, _leftBars, _rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
};
// Pivot low stream v2.0





class PivotLowStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotLowStream(TIStream<double> *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceLow);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }
   
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], TIStream<double>* source, int leftBars, int rightBars)
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, source, leftBars, rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int leftBars, int rightBars)
   {
      double center[1];
      if (!source.GetValues(period - rightBars, 1, center))
      {
         return false;
      }
      double value[1];
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValues(period - i, 1, value))
         {
            return false;
         }
         if (center[0] > value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValues(period - ii - rightBars, 1, value))
         {
            return false;
         }
         if (center[0] > value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center[0];
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, _source, _leftBars, _rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
};


//True range stream v1.1

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      if ((_handleNa && period + count > size) || (!_handleNa && period + count + 1 > size))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         if ((period + i + 1 == size) && _handleNa)
         {
            double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
            double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));
            double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));

            val[i] = MathMax(lc, MathMax(hl, hc));
            continue;
         }
         double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
         double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));
         double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));

         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
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

// Average true range stream v4.0

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

   bool GetValues(const int period, const int count, double &val[])
   {
      return _avg.GetValues(period, count, val);
   }
   
   bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int oldPos = Size() - period - 1;
      return GetValues(oldPos, count, val);
   }

};
#endif


// Cumulative on stream v2.0

#ifndef CumOnStream_IMP
#define CumOnStream_IMP

class CumOnStream : public AOnStream
{
   double _buffer[];
public:
   CumOnStream(TIStream<double> *source)
      :AOnStream(source)
   {
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      int bufferIndex = totalBars - 1 - period;
      double current[1];
      if (!_source.GetValues(bufferIndex, 1, current))
         return false;
      
      if (bufferIndex > 0 && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + current[0];
      }
      else 
      {
         _buffer[bufferIndex] = current[0];
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
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
      string valueStr = value == EMPTY_VALUE ? "" : DoubleToString(value);
      if (format != "")
      {
         StringReplace(format, "#.#", valueStr);
         return format;
      }
      return valueStr;
   }
   static string ToString(double value)
   {
      return DoubleToString(value);
   }
   static string ToString(int value)
   {
      return IntegerToString(value);
   }
   static string ReplaceAll(string source, string target, string replaceWith)
   {
      StringReplace(source, target, replaceWith);
      return source;
   }
   static bool Contains(string str1, string str2)
   {
      return StringFind(str1, str2) != -1;
   }
   static double ToNumber(string str)
   {
      return StringToDouble(str);
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
// Line object v1.6

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
   string _extend;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
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
   ~Line()
   {
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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
   static int GetX1(Line* line) { if (line == NULL) { return INT_MIN; } return line.GetX1(); }
   int GetX2() { return _x2; }
   static int GetX2(Line* line) { if (line == NULL) { return INT_MIN; } return line.GetX2(); }
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
      int totalBars = iBars(_Symbol, _timeframe);
      datetime x1 = GetTime(_x1, totalBars);
      datetime x2 = GetTime(_x2, totalBars);
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
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 0, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 1, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 0, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 1, x2);
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
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _timeframe, 0) + MathAbs(pos) * PeriodSeconds(_timeframe) : iTime(_Symbol, _timeframe, pos);
   }
};
// Collection of lines v1.3

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL



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
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string lineId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, ChartWindowOnDropped(), global);
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
#ifndef PolylineArray_IMPL
#define PolylineArray_IMPL
// Polyline array v1.0
#ifndef CustomTypeArray_IMPL
#define CustomTypeArray_IMPL
// Template for array interface v1.0

template <typename CLASS_TYPE>
interface ITArray
{
public:
   virtual void AddRef() = 0;
   virtual int Release() = 0;
   virtual void Unshift(CLASS_TYPE value) = 0;
   virtual int Size() = 0;
   virtual void Push(CLASS_TYPE value) = 0;
   virtual CLASS_TYPE Pop() = 0;
   virtual CLASS_TYPE Get(int index) = 0;
   virtual void Set(int index, CLASS_TYPE value) = 0;
   virtual CLASS_TYPE Shift() = 0;
   virtual CLASS_TYPE Remove(int index) = 0;
   virtual int Includes(CLASS_TYPE value) = 0;
   virtual CLASS_TYPE First() = 0;
   virtual CLASS_TYPE Last() = 0;
};
template <typename CLASS_TYPE>
interface ICustomTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ICustomTypeArray<CLASS_TYPE>* Clear() = 0;
};

template <typename CLASS_TYPE>
class CustomTypeArraySlice : public ICustomTypeArray<CLASS_TYPE>
{
   ITArray<CLASS_TYPE>* array;
   int from;
   int to;
   int _refs;
public:
   CustomTypeArraySlice(ITArray<CLASS_TYPE>* array, int from, int to)
   {
      _refs = 1;
      this.array = array;
      this.from = from;
      this.to = to;
   }
   
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(CLASS_TYPE value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(CLASS_TYPE value)
   {
      //do nothing
   }
   virtual CLASS_TYPE Pop()
   {
      return NULL;
   }
   virtual CLASS_TYPE Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, CLASS_TYPE value)
   {
      //do nothing
   }
   virtual ITArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return NULL;
   }
   virtual ICustomTypeArray<CLASS_TYPE>* Clear()
   {
      return NULL;
   }
   virtual CLASS_TYPE Shift()
   {
      return NULL;
   }
   virtual CLASS_TYPE Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
   int Includes(CLASS_TYPE value)
   {
      int size = Size();
      for (int i = 0; i < size; ++i)
      {
         if (Get(i) == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE First()
   {
      if (Size() == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = Get(0);
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
   CLASS_TYPE Last()
   {
      int size = Size();
      if (size == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = Get(size - 1);
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
};

template <typename CLASS_TYPE>
class CustomTypeArray : public ICustomTypeArray<CLASS_TYPE>
{
   CLASS_TYPE _array[];
   int _defaultSize;
   CLASS_TYPE _defaultValue;
   int _refs;
public:
   CustomTypeArray(int size, CLASS_TYPE defaultValue)
   {
      _refs = 1;
      _defaultValue = defaultValue;
      if (_defaultValue != NULL)
      {
         _defaultValue.AddRef();
      }
      _defaultSize = size;
      Clear();
   }

   ~CustomTypeArray()
   {
      Clear();
      if (_defaultValue != NULL)
      {
         _defaultValue.Release();
      }
   }
   
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   ICustomTypeArray<CLASS_TYPE>* Clear()
   {
     int size = ArraySize(_array);
      int i;
      for (i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            DeleteItem(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (i = 0; i < _defaultSize; ++i)
      {
         _array[i] = Clone(_defaultValue, i);
      }
      return &this;
   }

   void Unshift(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   CLASS_TYPE Pop()
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value != NULL && value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   CLASS_TYPE Shift()
   {
      return Remove(0);
   }

   CLASS_TYPE Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, CLASS_TYPE value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      _array[index] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }
      
   ICustomTypeArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return new CustomTypeArraySlice<CLASS_TYPE>(&this, from, to);
   }
   
   CLASS_TYPE Remove(int index)
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
   
   int Includes(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE First()
   {
      if (ArraySize(_array) == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = _array[0];
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
   CLASS_TYPE Last()
   {
      int size = ArraySize(_array);
      if (size == 0)
      {
         return NULL;
      }
      CLASS_TYPE value = _array[size - 1];
      if (value != NULL)
      {
         value.AddRef();
      }
      return value;
   }
protected:
   virtual CLASS_TYPE Clone(CLASS_TYPE item, int index)
   {
      return NULL;
   }
   virtual void DeleteItem(CLASS_TYPE item)
   {
   }
};
#endif
// Collection of polylines v1.0

#ifndef PolyLinesCollection_IMPL
#define PolyLinesCollection_IMPL

#ifndef POLYLINE_IMPL
#define POLYLINE_IMPL
// PolyLine object v1.0

#ifndef ChartPoint_IMPL
#define ChartPoint_IMPL

// Chart point object v1.1

class ChartPoint
{
   int _refs;
   int _index;
   double _price;
public:
   ChartPoint(int index, double price)
   {
      _refs = 1;
      _index = index;
      _price = price;
   }
   ~ChartPoint()
   {
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
   
   static ChartPoint* Create()
   {
      return new ChartPoint(0, 0);
   }
   
   static ChartPoint* FromIndex(int index, double price)
   {
      return new ChartPoint(index, price);
   }

   void CopyTo(ChartPoint* other)
   {
      other._index = _index;
      other._price = _price;
   }
   
   int GetIndex() { return _index; }
   double GetPrice() { return _price; }
private:
};

#endif

class Polyline
{
   string _id;
   int _refs;
   string _collectionId;
   int _window;
   uint _lineColor;
   uint _fillColor;
   int _lineWidth;
   bool _curved;
   bool _closed;
   bool _forceOverlay;
   ICustomTypeArray<ChartPoint*>* _points;
public:
   Polyline(ICustomTypeArray<ChartPoint*>* points, string id, string collectionId, int window)
   {
      _refs = 1;
      _id = id;
      _window = window;
      _lineWidth = 1;
      _collectionId = collectionId;
      _points = points;
      if (_points != NULL)
      {
         _points.AddRef();
      }
   }
   ~Polyline()
   {
      if (_points != NULL)
      {
         _points.Release();
      }
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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
   
   void CopyTo(Polyline* line)
   {
      line._window = _window;
      line._points = _points;
      line._lineColor = _lineColor;
      line._fillColor = _fillColor;
      line._lineWidth = _lineWidth;
      line._curved = _curved;
      line._closed = _closed;
      line._forceOverlay = _forceOverlay;
      line._points = _points;
      if (line._points != NULL)
      {
         line._points.AddRef();
      }
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   void Redraw()
   {
      if (_points == NULL)
      {
         return;
      }
      int size = _points.Size();
      if (size == 0)
      {
         return;
      }
      int totalBars = iBars(_Symbol, _Period);
      
      ChartPoint* prev = _points.Get(0);
      for (int i = 1; i < size; ++i)
      {
         ChartPoint* point = _points.Get(i);
         datetime x1 = GetTime(prev.GetIndex(), totalBars);
         datetime x2 = GetTime(point.GetIndex(), totalBars);
         string lineId = _id + i;
         if (ObjectFind(0, lineId) == -1 && ObjectCreate(0, lineId, OBJ_TREND, 0, x1, prev.GetPrice(), x2, point.GetPrice()))
         {
            ObjectSetInteger(0, lineId, OBJPROP_COLOR, _lineColor);
            ObjectSetInteger(0, lineId, OBJPROP_WIDTH, _lineWidth);
         }
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 0, prev.GetPrice());
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 1, point.GetPrice());
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 0, x1);
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 1, x2);
         prev = point;
      }
      
   }
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _Period, 0) + MathAbs(pos) * PeriodSeconds(_Period) : iTime(_Symbol, _Period, pos);
   }
   
   Polyline* SetLineColor(uint clr)
   {
      _lineColor = clr;
      return &this;
   }
   Polyline* SetFillColor(uint clr)
   {
      _fillColor = clr;
      return &this;
   }
   Polyline* SetLineWidth(int width)
   {
      _lineWidth = width;
      return &this;
   }
   Polyline* SetCurved(bool val)
   {
      _curved = val;
      return &this;
   }
   Polyline* SetClosed(bool val)
   {
      _closed = val;
      return &this;
   }
   Polyline* SetForceOverlay(bool val)
   {
      _forceOverlay = val;
      return &this;
   }
};
#endif



class PolyLinesCollection
{
   string _id;
   ICustomTypeArray<Polyline*>* _array;
   static PolyLinesCollection* _collections[];
   static PolyLinesCollection* _all;
   static int _max;
   static uint _nextId;
public:
   static Polyline* Get(Polyline* PolyLine, int index)
   {
      if (PolyLine == NULL)
      {
         return NULL;
      }
      PolyLinesCollection* collection = FindCollection(PolyLine.GetCollectionId());
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
            _all = new PolyLinesCollection("");
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

   static void Delete(Polyline* PolyLine)
   {
      if (PolyLine == NULL)
      {
         return;
      }
      if (!_all.DeleteItem(PolyLine))
      {
         return;
      }
      PolyLinesCollection* collection = FindCollection(PolyLine.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(PolyLine);
   }

   static Polyline* Create(string id, ICustomTypeArray<ChartPoint*>* points, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - 1);
      MqlDateTime date;
      TimeToStruct(dateId, date);
      uint currentId = _nextId;
      _nextId += 1;
      string polyLineId = id + "_" + IntegerToString(currentId);
      
      Polyline* polyLine = new Polyline(points, polyLineId, id, ChartWindowOnDropped());
      PolyLinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new PolyLinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(polyLine);
      _all.Add(polyLine);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
      }
      polyLine.Release();
      return polyLine;
   }

   static void SetMaxLines(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawPolyLines();
      }
   }
   
   static ICustomTypeArray<Polyline*>* GetArray()
   {
      return _all._array;
   }
private:
   PolyLinesCollection(string id)
   {
      _id = id;
      _array = new CustomTypeArray<Polyline*>(0, NULL);
   }

   ~PolyLinesCollection()
   {
      ClearItems();
   }
   
   string GetId()
   {
      return _id;
   }
   
   void ClearItems()
   {
      delete _array;
      _array = new CustomTypeArray<Polyline*>(0, NULL);
   }
   
   int Count()
   {
      return _array.Size();
   }

   Polyline* GetFirst()
   {
      return _array.First();
   }

   Polyline* Get(int index)
   {
      int size = _array.Size();
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array.Get(index);
   }
   Polyline* GetByIndex(int index)
   {
      int size = _array.Size();
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array.Get(size - 1 - index);
   }
   
   int FindIndex(Polyline* polyline)
   {
      for (int i = 0; i < _array.Size(); ++i)
      {
         if (_array.Get(i) == polyline)
         {
            return i;
         }
      }
      return -1;
   }

   bool DeleteItem(Polyline* polyline)
   {
      int index = FindIndex(polyline);
      if (index == -1)
      {
         return false;
      }
      _array.Remove(index);
      return true;
   }
   
   void Add(Polyline* polyline)
   {
      _array.Push(polyline);
   }

   void RedrawPolyLines()
   {
      for (int i = 0; i < _array.Size(); ++i)
      {
         _array.Get(i).Redraw();
      }
   }
   
   static void AddCollection(PolyLinesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static PolyLinesCollection* FindCollection(string id)
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
PolyLinesCollection* PolyLinesCollection::_collections[];
PolyLinesCollection* PolyLinesCollection::_all;
int PolyLinesCollection::_max = 50;
uint PolyLinesCollection::_nextId = 0;
#endif

class PolylineArray : public CustomTypeArray<Polyline*>
{
public:
   PolylineArray(int size, Polyline* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Polyline* Clone(Polyline* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Polyline* clone = PolyLinesCollection::Create(item.GetId(), NULL, 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Polyline* item)
   {
      PolyLinesCollection::Delete(item);
   }
};

#endif
#ifndef POLYLINE_IMPL
#define POLYLINE_IMPL
// PolyLine object v1.0



class Polyline
{
   string _id;
   int _refs;
   string _collectionId;
   int _window;
   uint _lineColor;
   uint _fillColor;
   int _lineWidth;
   bool _curved;
   bool _closed;
   bool _forceOverlay;
   ICustomTypeArray<ChartPoint*>* _points;
public:
   Polyline(ICustomTypeArray<ChartPoint*>* points, string id, string collectionId, int window)
   {
      _refs = 1;
      _id = id;
      _window = window;
      _lineWidth = 1;
      _collectionId = collectionId;
      _points = points;
      if (_points != NULL)
      {
         _points.AddRef();
      }
   }
   ~Polyline()
   {
      if (_points != NULL)
      {
         _points.Release();
      }
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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
   
   void CopyTo(Polyline* line)
   {
      line._window = _window;
      line._points = _points;
      line._lineColor = _lineColor;
      line._fillColor = _fillColor;
      line._lineWidth = _lineWidth;
      line._curved = _curved;
      line._closed = _closed;
      line._forceOverlay = _forceOverlay;
      line._points = _points;
      if (line._points != NULL)
      {
         line._points.AddRef();
      }
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   void Redraw()
   {
      if (_points == NULL)
      {
         return;
      }
      int size = _points.Size();
      if (size == 0)
      {
         return;
      }
      int totalBars = iBars(_Symbol, _Period);
      
      ChartPoint* prev = _points.Get(0);
      for (int i = 1; i < size; ++i)
      {
         ChartPoint* point = _points.Get(i);
         datetime x1 = GetTime(prev.GetIndex(), totalBars);
         datetime x2 = GetTime(point.GetIndex(), totalBars);
         string lineId = _id + i;
         if (ObjectFind(0, lineId) == -1 && ObjectCreate(0, lineId, OBJ_TREND, 0, x1, prev.GetPrice(), x2, point.GetPrice()))
         {
            ObjectSetInteger(0, lineId, OBJPROP_COLOR, _lineColor);
            ObjectSetInteger(0, lineId, OBJPROP_WIDTH, _lineWidth);
         }
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 0, prev.GetPrice());
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 1, point.GetPrice());
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 0, x1);
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 1, x2);
         prev = point;
      }
      
   }
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _Period, 0) + MathAbs(pos) * PeriodSeconds(_Period) : iTime(_Symbol, _Period, pos);
   }
   
   Polyline* SetLineColor(uint clr)
   {
      _lineColor = clr;
      return &this;
   }
   Polyline* SetFillColor(uint clr)
   {
      _fillColor = clr;
      return &this;
   }
   Polyline* SetLineWidth(int width)
   {
      _lineWidth = width;
      return &this;
   }
   Polyline* SetCurved(bool val)
   {
      _curved = val;
      return &this;
   }
   Polyline* SetClosed(bool val)
   {
      _closed = val;
      return &this;
   }
   Polyline* SetForceOverlay(bool val)
   {
      _forceOverlay = val;
      return &this;
   }
};
#endif
// Collection of labels v1.2

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.3

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   uint _color;
   uint _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   string _textAlign;
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
   void SetXY(int x, double y)
   {
      SetX(x);
      SetY(y);
   }
   static void SetXY(Label* label, int x, double y)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetXY(x, y);
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
         ObjectSetString(0, _labelId, OBJPROP_FONT, _font);
         ObjectSetInteger(0, _labelId, OBJPROP_FONTSIZE, getFontSize());
         ObjectSetInteger(0, _labelId, OBJPROP_COLOR, _textColor);
         ObjectSetInteger(0, _labelId, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE, 1, y);
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
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string labelId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      Label* label = new Label(x, y, labelId, id, ChartWindowOnDropped(), globalLabel);
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
#ifndef ChartPointArray_IMPL
#define ChartPointArray_IMPL
// ChartPoint array v1.0



class ChartPointArray : public CustomTypeArray<ChartPoint*>
{
public:
   ChartPointArray(int size, ChartPoint* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual ChartPoint* Clone(ChartPoint* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      ChartPoint* clone = ChartPoint::Create();
      item.CopyTo(clone);
      return clone;
   }
};

#endif
// Array v1.5
// Array interface v1.0

// Box array interface v1.1
#ifndef Box_IMPL
#define Box_IMPL



// Box object v1.3

class Box
{
   string _id;
   string _collectionId;
   int _left;
   double _top;
   int _right;
   double _bottom;
   int _window;
   uint _bgcolor;
   uint _borderColor;
   ENUM_TIMEFRAMES _timeframe;
   string _extend;

   string _text;
   string _textHAlign;
   string _textVAlign;
   string _textSize;
   color _textColor;
   bool global;

   int _refs;
public:
   Box(int left, double top, int right, double bottom, string id, string collectionId, int window, bool global = false)
   {
      _refs = 1;
      _textColor = White;
      _left = left;
      _right = right;
      _top = top;
      _bottom = bottom;
      _id = id;
      _collectionId = collectionId;
      _window = window;
      _extend = "none";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      this.global = global;
   }
   ~Box()
   {
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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

   static Box* Copy(Box* box) { if (box == NULL) { return NULL; } return box.Copy(); }
   Box* Copy()
   {
      Box* copy = new Box(_left, _top, _right, _bottom, _id, _collectionId, _window);
      copy.SetBgColor(_bgcolor);
      copy.SetBorderColor(_borderColor);
      copy.SetExtend(_extend);
      copy.SetText(_text);
      copy.SetTextHAlign(_textHAlign);
      copy.SetTextVAlign(_textVAlign);
      copy.SetTextSize(_textSize);
      copy.SetTextColor(_textColor);
      return copy;
   }

   static double GetTop(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetTop(); }
   double GetTop() { return _top; }
   static double GetBottom(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetBottom(); }
   double GetBottom() { return _bottom; }
   static int GetLeft(Box* box) { if (box == NULL) { return INT_MIN; } return box.GetLeft(); }
   int GetLeft() { return _left; }
   static int GetRight(Box* box) { if (box == NULL) { return INT_MIN; } return box.GetRight(); }
   int GetRight() { return _right; }

   static void SetTop(Box* box, double value) { if (box == NULL) { return; } box.SetTop(value); }
   void SetTop(double value) { _top = value; }
   static void SetBottom(Box* box, double value) { if (box == NULL) { return; } box.SetBottom(value); }
   void SetBottom(double value) { _bottom = value; }
   static void SetLeft(Box* box, int value) { if (box == NULL) { return; } box.SetLeft(value); }
   void SetLeft(int value) { _left = value; }
   static void SetRight(Box* box, int value) { if (box == NULL) { return; } box.SetRight(value); }
   void SetRight(int value) { _right = value; }
   static void SetLeftTop(Box* box, double top, int left) { if (box == NULL) { return; } box.SetTop(top); box.SetLeft(left); }
   static void SetRightBottom(Box* box, double bottom, int right) { if (box == NULL) { return; } box.SetRight(right); box.SetBottom(bottom); }

   static void SetBgColor(Box* box, uint clr) { if (box == NULL) { return; } box.SetBgColor(clr); }
   Box* SetBgColor(uint clr) { _bgcolor = clr; return &this; }
   static void SetBorderColor(Box* box, uint clr) { if (box == NULL) { return; } box.SetBorderColor(clr); }
   Box* SetBorderColor(uint clr) { _borderColor = clr; return &this; }
   static void SetExtend(Box* box, string extend) { if (box == NULL) { return; } box.SetExtend(extend); }
   Box* SetExtend(string extend) { _extend = extend; return &this; }

   static void SetText(Box* box, string text) { if (box == NULL) { return; } box.SetText(text); }
   Box* SetText(string text) { _text = text; return &this; }
   static void SetTextHAlign(Box* box, string halign) { if (box == NULL) { return; } box.SetTextHAlign(halign); }
   Box* SetTextHAlign(string halign) { _textHAlign = halign; return &this; }
   static void SetTextVAlign(Box* box, string valign) { if (box == NULL) { return; } box.SetTextVAlign(valign); }
   Box* SetTextVAlign(string valign) { _textVAlign = valign; return &this; }
   static void SetTextSize(Box* box, string size) { if (box == NULL) { return; } box.SetTextSize(size); }
   Box* SetTextSize(string size) { _textSize = size; return &this; }
   static void SetTextColor(Box* box, uint clr) { if (box == NULL) { return; } box.SetTextColor(clr); }
   Box* SetTextColor(uint clr) { _textColor = clr; return &this; }

   void Redraw()
   {
      int totalBars = iBars(_Symbol, _timeframe);
      datetime left;
      if (_extend == "left" || _extend == "both")
      {
         left = iTime(_Symbol, _timeframe, iBars(_Symbol, _timeframe) - 1);
      }
      else
      {
         left = GetTime(_left, totalBars);
      }
      datetime right;
      if (_extend == "right" || _extend == "both")
      {
         right = iTime(_Symbol, _timeframe, 0);
      }
      else
      {
         right = GetTime(_right, totalBars);
      }
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_RECTANGLE, _window, left, _top, right, _bottom))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, GetColorOnly(_bgcolor));
         ObjectSetInteger(0, _id, OBJPROP_BGCOLOR, GetColorOnly(_bgcolor));
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, 1);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 0, _top);
      ObjectSetDouble(0, _id, OBJPROP_PRICE, 1, _bottom);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 0, left);
      ObjectSetInteger(0, _id, OBJPROP_TIME, 1, right);
   }
private:
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _timeframe, 0) + MathAbs(pos) * PeriodSeconds(_timeframe) : iTime(_Symbol, _timeframe, pos);
   }
};

#endif

class IBoxArray
{
public:
   virtual void Unshift(Box* value) = 0;
   virtual int Size() = 0;
   virtual void Push(Box* value) = 0;
   virtual Box* Pop() = 0;
   virtual Box* Get(int index) = 0;
   virtual void Set(int index, Box* value) = 0;
   virtual IBoxArray* Slice(int from, int to) = 0;
   virtual IBoxArray* Clear() = 0;
   virtual Box* Shift() = 0;
   virtual Box* Remove(int index) = 0;
   virtual void Sort(bool ascending) = 0;
};
// float array interface v1.2

class IFloatArray
{
public:
   virtual void Unshift(double value) = 0;
   virtual int Size() = 0;
   virtual void Push(double value) = 0;
   virtual double Pop() = 0;
   virtual double Get(int index) = 0;
   virtual void Set(int index, double value) = 0;
   virtual IFloatArray* Slice(int from, int to) = 0;
   virtual IFloatArray* Clear() = 0;
   virtual double Shift() = 0;
   virtual double Remove(int index) = 0;
   virtual void Sort(bool ascending) = 0;
};
// Int array interface v1.2

class IIntArray
{
public:
   virtual void Unshift(int value) = 0;
   virtual int Size() = 0;
   virtual void Push(int value) = 0;
   virtual int Pop() = 0;
   virtual int Get(int index) = 0;
   virtual void Set(int index, int value) = 0;
   virtual IIntArray* Slice(int from, int to) = 0;
   virtual IIntArray* Clear() = 0;
   virtual int Shift() = 0;
   virtual int Remove(int index) = 0;
   virtual void Sort(bool ascending) = 0;
};
#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v2.0



class LineArray : public CustomTypeArray<Line*>
{
public:
   LineArray(int size, Line* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Line* Clone(Line* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Line* clone = LinesCollection::Create(item.GetId() + index, item.GetX1(), item.GetY1(), item.GetX2(), item.GetY2(), 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Line* item)
   {
      LinesCollection::Delete(item);
   }
};

#endif
// Int array v1.5


class IntArraySlice : public IIntArray
{
   IIntArray* array;
   int from;
   int to;
public:
   IntArraySlice(IIntArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(int value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(int value)
   {
      //do nothing
   }
   virtual int Pop()
   {
      return NULL;
   }
   virtual int Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, int value)
   {
      //do nothing
   }
   virtual IIntArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual IIntArray* Clear()
   {
      return NULL;
   }
   virtual int Shift()
   {
      return NULL;
   }
   virtual int Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class IntArray : public IIntArray
{
   int _array[];
   int _defaultSize;
   int _defaultValue;
   IntArraySlice* slices[];
public:
   IntArray(int size, int defaultValue)
   {
      _defaultSize = size;
      _defaultValue = defaultValue;
      Clear();
   }
   ~IntArray()
   {
      Clear();
   }

   IIntArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      int size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
      return &this;
   }

   void Unshift(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   int Pop()
   {
      int size = ArraySize(_array);
      int value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   int Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return INT_MIN;
      }
      return _array[index];
   }
   
   void Set(int index, int value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }

   int Shift()
   {
      return Remove(0);
   }
   
   IIntArray* Slice(int from, int to)
   {
      int size = ArraySize(slices);
      for (int i = 0; i < size; ++i)
      {
         if (slices[i].GetFrom() == from && slices[i].GetTo() == to)
         {
            return slices[i];
         }
      }
      ArrayResize(slices, size + 1);
      slices[size] = new IntArraySlice(&this, from, to);
      return slices[size];
   }
   
   void Sort(bool ascending)
   {
      ArraySort(_array);
      if (!ascending)
      {
         ArrayReverse(_array);
      }
   }

   int Remove(int index)
   {
      int size = ArraySize(_array);
      int value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
};
// Float array v1.4


class FloatArraySlice : public IFloatArray
{
   IFloatArray* array;
   int from;
   int to;
public:
   FloatArraySlice(IFloatArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(double value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(double value)
   {
      //do nothing
   }
   virtual double Pop()
   {
      return NULL;
   }
   virtual double Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, double value)
   {
      //do nothing
   }
   virtual IFloatArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual IFloatArray* Clear()
   {
      return NULL;
   }
   virtual double Shift()
   {
      return NULL;
   }
   virtual double Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class FloatArray : public IFloatArray
{
   double _array[];
   int _defaultSize;
   double _defaultValue;
   FloatArraySlice* slices[];
public:
   FloatArray(int size, double defaultValue)
   {
      _defaultSize = size;
      _defaultValue = defaultValue;
      Clear();
   }
   ~FloatArray()
   {
      Clear();
   }

   IFloatArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      int size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
      return &this;
   }

   void Unshift(double value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(double value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   double Pop()
   {
      int size = ArraySize(_array);
      double value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   double Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, double value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }

   double Shift()
   {
      return Remove(0);
   }
   
   IFloatArray* Slice(int from, int to)
   {
      int size = ArraySize(slices);
      for (int i = 0; i < size; ++i)
      {
         if (slices[i].GetFrom() == from && slices[i].GetTo() == to)
         {
            return slices[i];
         }
      }
      ArrayResize(slices, size + 1);
      slices[size] = new FloatArraySlice(&this, from, to);
      return slices[size];
   }
   
   void Sort(bool ascending)
   {
      ArraySort(_array);
      if (!ascending)
      {
         ArrayReverse(_array);
      }
   }

   double Remove(int index)
   {
      int size = ArraySize(_array);
      double value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
};
#ifndef BoxArray_IMPL
#define BoxArray_IMPL
// Box array v1.5

// Collection of boxes v1.1

#ifndef BoxesCollection_IMPL
#define BoxesCollection_IMPL



class BoxesCollection
{
   string _id;
   Box* _array[];
   static BoxesCollection* _collections[];
   static BoxesCollection* _all;
   static int _max;
public:
   BoxesCollection(string id)
   {
      _id = id;
   }

   ~BoxesCollection()
   {
      ClearItems();
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
   
   string GetId()
   {
      return _id;
   }

   int Count()
   {
      return ArraySize(_array);
   }

   Box* GetFirst()
   {
      return _array[0];
   }

   Box* Get(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[index];
   }
   Box* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }

   static Box* Get(Box* box, int index)
   {
      if (box == NULL)
      {
         return NULL;
      }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
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
         _all = new BoxesCollection("");
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
   }

   static void Delete(Box* box)
   {
      if (box == NULL)
      {
         return;
      }
      _all.DeleteItem(box);
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(box);
   }

   static Box* Create(string id, int left, double top, int right, double bottom, datetime dateId, bool global = false)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - left - 1);
      MqlDateTime date;
      TimeToStruct(dateId, date);
      string boxId = id + "_" 
         + IntegerToString(date.day) + "_"
         + IntegerToString(date.mon) + "_"
         + IntegerToString(date.year) + "_"
         + IntegerToString(date.hour) + "_"
         + IntegerToString(date.min) + "_"
         + IntegerToString(date.sec);
      
      Box* box = new Box(left, top, right, bottom, boxId, id, ChartWindowOnDropped(), global);
      BoxesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new BoxesCollection(id);
         AddCollection(collection);
      }
      collection.Add(box);
      _all.Add(box);
      box.Release();
      int allCount = _all.Count();
      if (allCount > _max)
      {
         for (int i = 0; i < allCount; ++i)
         {
            Box* toDelete = _all.Get(i);
            if (!toDelete.IsGlobal() && toDelete != box)
            {
               Delete(toDelete);
               break;
            }
         }
      }
      return box;
   }
   
   static void SetMaxBoxes(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawBoxs();
      }
   }
private:
   int FindIndex(Box* box)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == box)
         {
            return i;
         }
      }
      return -1;
   }

   void DeleteItem(Box* box)
   {
      int index = FindIndex(box);
      if (index == -1)
      {
         return;
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      box.Release();
   }
   
   void Add(Box* box)
   {
      int index = FindIndex(box);
      
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = box;
      box.AddRef();
   }

   void RedrawBoxs()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(BoxesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static BoxesCollection* FindCollection(string id)
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
BoxesCollection* BoxesCollection::_collections[];
BoxesCollection* BoxesCollection::_all;
int BoxesCollection::_max = 50;
#endif

class BoxArraySlice : public IBoxArray
{
   IBoxArray* array;
   int from;
   int to;
public:
   BoxArraySlice(IBoxArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(Box* value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(Box* value)
   {
      //do nothing
   }
   virtual Box* Pop()
   {
      return NULL;
   }
   virtual Box* Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, Box* value)
   {
      //do nothing
   }
   virtual IBoxArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual IBoxArray* Clear()
   {
      return NULL;
   }
   virtual Box* Shift()
   {
      return NULL;
   }
   virtual Box* Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class BoxArray : public IBoxArray
{
   Box* _array[];
   int _defaultSize;
   Box* _defaultValue;
   BoxArraySlice* slices[];
public:
   BoxArray(int size, Box* defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   ~BoxArray()
   {
      Clear();
   }

   IBoxArray* Clear()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            BoxesCollection::Delete(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
      return &this;
   }

   void Unshift(Box* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   void Push(Box* value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   Box* Pop()
   {
      int size = ArraySize(_array);
      Box* value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value != NULL && value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   Box* Shift()
   {
      return Remove(0);
   }

   Box* Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, Box* value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      _array[index] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }
   
   IBoxArray* Slice(int from, int to)
   {
      int size = ArraySize(slices);
      for (int i = 0; i < size; ++i)
      {
         if (slices[i].GetFrom() == from && slices[i].GetTo() == to)
         {
            return slices[i];
         }
      }
      ArrayResize(slices, size + 1);
      slices[size] = new BoxArraySlice(&this, from, to);
      return slices[size];
   }

   Box* Remove(int index)
   {
      int size = ArraySize(_array);
      Box* value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
};
#endif
#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v2.0



class LineArray : public CustomTypeArray<Line*>
{
public:
   LineArray(int size, Line* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Line* Clone(Line* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Line* clone = LinesCollection::Create(item.GetId() + index, item.GetX1(), item.GetY1(), item.GetX2(), item.GetY2(), 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Line* item)
   {
      LinesCollection::Delete(item);
   }
};

#endif


class Array
{
public:
   template <typename ARRAY_TYPE>
   static void Clear(ARRAY_TYPE array) { if (array == NULL) { return; } array.Clear(); }
   
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE First(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.First(); }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Last(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Last(); }
   
   static IIntArray* Slice(IIntArray* array, int from, int to) { if (array == NULL) { return NULL; } return array.Slice(from, to); }
   static IFloatArray* Slice(IFloatArray* array, int from, int to) { if (array == NULL) { return NULL; } return array.Slice(from, to); }
   static IBoxArray* Slice(IBoxArray* array, int from, int to) { if (array == NULL) { return NULL; } return array.Slice(from, to); }
   
   static void Sort(IIntArray* array, string order) { if (array == NULL) { return; } array.Sort(order == "ascending"); }
   static void Sort(IFloatArray* array, string order) { if (array == NULL) { return; } array.Sort(order == "ascending"); }
   
   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Unshift(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Unshift(value); }
   
   template <typename DUMMY_TYPE, typename ARRAY_TYPE>
   static int Size(ARRAY_TYPE array, int defaultValue) { if (array == NULL) { return INT_MIN;} return array.Size(); }

   static int Shift(IIntArray* array) { if (array == NULL) { return INT_MIN; } return array.Shift(); }
   static double Shift(IFloatArray* array) { if (array == NULL) { return EMPTY_VALUE; } return array.Shift(); }
   static Box* Shift(IBoxArray* array) { if (array == NULL) { return NULL; } return array.Shift(); }

   static void Push(IIntArray* array, int value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IFloatArray* array, double value) { if (array == NULL) { return; } array.Push(value); }
   static void Push(IBoxArray* array, Box* value) { if (array == NULL) { return; } array.Push(value); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Pop(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Pop(); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE, typename dummy>
   static VALUE_TYPE Get(ARRAY_TYPE array, int index, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Get(index); }
   
   static void Set(IIntArray* array, int index, int value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IFloatArray* array, int index, double value) { if (array == NULL) { return; } array.Set(index, value); }
   static void Set(IBoxArray* array, int index, Box* value) { if (array == NULL) { return; } array.Set(index, value); }

   static int Remove(IIntArray* array, int index) { if (array == NULL) { return INT_MIN; } return array.Remove(index); }
   static double Remove(IFloatArray* array, int index) { if (array == NULL) { return EMPTY_VALUE; } return array.Remove(index); }
   static Box* Remove(IBoxArray* array, int index) { if (array == NULL) { return NULL; } return array.Remove(index); }

   static double PercentRank(IIntArray* array, int index)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return INT_MIN; }
      int target = array.Get(index);
      if (target == INT_MIN)
      {
         return INT_MIN;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         int current = array.Get(i);
         if (current != INT_MIN && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }
   static double PercentRank(IFloatArray* array, int index)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return EMPTY_VALUE; }
      double target = array.Get(index);
      if (target == EMPTY_VALUE)
      {
         return EMPTY_VALUE;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         double current = array.Get(i);
         if (current != EMPTY_VALUE && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }

   static int Max(IIntArray* array)
   {
      if (array == NULL || array.Size() == 0) { return INT_MIN; }
      int max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (max == INT_MIN || (current != INT_MIN && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   static double Max(IFloatArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      double max = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double current = array.Get(i);
         if (max == EMPTY_VALUE || (current != EMPTY_VALUE && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   static int Min(IIntArray* array)
   {
      if (array == NULL || array.Size() == 0) { return INT_MIN; }
      int min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int current = array.Get(i);
         if (min == INT_MIN || (current != INT_MIN && min > current))
         {
            min = current;
         }
      }
      return min;
   }
   static double Min(IFloatArray* array)
   {
      if (array == NULL || array.Size() == 0) { return EMPTY_VALUE; }
      double min = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double current = array.Get(i);
         if (min == EMPTY_VALUE || (current != EMPTY_VALUE && min > current))
         {
            min = current;
         }
      }
      return min;
   }

   static int Sum(IIntArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      int sum = 0;
      for (int i = 0; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   static double Sum(IFloatArray* array)
   {
      if (array == NULL)
      {
         return 0;
      }
      double sum = 0;
      for (int i = 0; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   
   static double Avg(IIntArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      return Sum(array) / array.Size();
   }
   static double Avg(IFloatArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      return Sum(array) / array.Size();
   }
   
   static double Covariance(IIntArray* array1, IIntArray* array2)
   {
      if (array1 == NULL || array2 == NULL || array1.Size() != array2.Size())
      {
         return 0;
      }
      double avg1 = Avg(array1);
      double avg2 = Avg(array2);
      double sum = 0;
      for (int i = 0; i < array1.Size(); ++i)
      {
         sum = sum + (array1.Get(i) - avg1) * (array2.Get(i) - avg2);
      }
      return sum / array1.Size();
   }
   static double Covariance(IFloatArray* array1, IFloatArray* array2)
   {
      if (array1 == NULL || array2 == NULL || array1.Size() != array2.Size())
      {
         return 0;
      }
      double avg1 = Avg(array1);
      double avg2 = Avg(array2);
      double sum = 0;
      for (int i = 0; i < array1.Size(); ++i)
      {
         sum = sum + (array1.Get(i) - avg1) * (array2.Get(i) - avg2);
      }
      return sum / array1.Size();
   }
   static double Covariance(IIntArray* array1, IFloatArray* array2)
   {
      if (array1 == NULL || array2 == NULL || array1.Size() != array2.Size())
      {
         return 0;
      }
      double avg1 = Avg(array1);
      double avg2 = Avg(array2);
      double sum = 0;
      for (int i = 0; i < array1.Size(); ++i)
      {
         sum = sum + (array1.Get(i) - avg1) * (array2.Get(i) - avg2);
      }
      return sum / array1.Size();
   }
   static double Covariance(IFloatArray* array1, IIntArray* array2)
   {
      if (array1 == NULL || array2 == NULL || array1.Size() != array2.Size())
      {
         return 0;
      }
      double avg1 = Avg(array1);
      double avg2 = Avg(array2);
      double sum = 0;
      for (int i = 0; i < array1.Size(); ++i)
      {
         sum = sum + (array1.Get(i) - avg1) * (array2.Get(i) - avg2);
      }
      return sum / array1.Size();
   }
   
   static double Stdev(IIntArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      double sum = 0;
      double ssum = 0;
      int size = array.Size();
      for (int i = 0; i < size; i++)
      {
         sum += array.Get(i);
         ssum += MathPow(size, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
   static double Stdev(IFloatArray* array)
   {
      if (array == NULL)
      {
         return EMPTY_VALUE;
      }
      double sum = 0;
      double ssum = 0;
      int size = array.Size();
      for (int i = 0; i < size; i++)
      {
         sum += array.Get(i);
         ssum += MathPow(size, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
   
   static double Variance(IIntArray* array, bool biased)
   {
      if (array == NULL || !biased)
      {
         return EMPTY_VALUE;
      }
      double avg = Avg(array);
      double sum = 0;
      int size = array.Size();
      for (int i = 0; i < size; i++)
      {
         sum += MathPow(array.Get(i) - avg, 2);
      }
      return sum / size;
   }
   static double Variance(IFloatArray* array, bool biased)
   {
      if (array == NULL || !biased)
      {
         return EMPTY_VALUE;
      }
      double avg = Avg(array);
      double sum = 0;
      int size = array.Size();
      for (int i = 0; i < size; i++)
      {
         sum += MathPow(array.Get(i) - avg, 2);
      }
      return sum / size;
   }
};





// Table v1.3
// Interface for a cell v4.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw(int x, int y, int width) = 0;
   virtual void HandleButtonClicks() = 0;
   virtual void Measure(uint& width, uint& height) = 0;
};

#endif
//Row size v1.0

class RowSize
{
   int _widths[];
   int _maxHeight;
public:
   void Add(int index, int width, int height)
   {
      int size = ArraySize(_widths);
      if (size <= index)
      {
         ArrayResize(_widths, index + 1);
         for (int i = size; i < index + 1; ++i)
         {
            _widths[i] = 0;
         }
      }
      _maxHeight = MathMax(_maxHeight, height);
      _widths[index] = MathMax(_widths[index], width);
   }

   int GetWidth(int index)
   {
      return _widths[index];
   }

   int GetMaxHeight()
   {
      return _maxHeight;
   }
};

// Row v2.2

#ifndef Row_IMP
#define Row_IMP

class Row
{
   ICell *_cells[];
public:
   ~Row() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         delete _cells[i]; 
      } 
   }

   void Measure(RowSize* rowSizes)
   {
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         uint w, h;
         _cells[i].Measure(w, h);
         rowSizes.Add(i, w + 5, h + 5);
      } 
   }
   
   int GetColumnsCount()
   {
      return ArraySize(_cells);
   }

   void Draw(int x, int y, RowSize* rowSizes) 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         int width = rowSizes.GetWidth(i);
         _cells[i].Draw(x, y, width);
         x += width;
      } 
   }

   void HandleButtonClicks() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].HandleButtonClicks(); 
      } 
   }
   
   ICell* GetCell(int index)
   {
      if (index < 0)
      {
         return NULL;
      }
      int count = ArraySize(_cells);
      if (index >= count)
      {
         return NULL;
      }
      return _cells[index];
   }

   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};


#endif


// Grid v2.1

#ifndef Grid_IMP
#define Grid_IMP

class Grid
{
   Row *_rows[];
public:
   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   Row *AddRow()
   {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
   }
   
   Row *GetRow(const int index)
   {
      if (index == INT_MIN)
      {
         return NULL;
      }
      return _rows[index];
   }
   
   int GetRowsCount()
   {
      return ArraySize(_rows);
   }
   
   void Draw(int x, int y)
   {
      RowSize* widths = MeasureColumns();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         int w, h;
         _rows[i].Draw(x, y, widths);
         y += widths.GetMaxHeight();
      }
      delete widths;
   }

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
      }
   }
private:
   RowSize* MeasureColumns()
   {
      RowSize* widths = new RowSize();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Measure(widths);
      }
      return widths;
   }
};

#endif


// ACell v1.1

class ACell : public ICell
{
protected:
   void Measure(string text, string font, int fontSize, uint& width, uint& height)
   {
      TextSetFont(font, -fontSize * 10);
      TextGetSize(text, width, height);
   }
   void ObjectMakeLabel(string nm, int xoff, int yoff, string text, color LabelColor, int LabelCorner, int Window, string Font, int FSize)
   { 
      ObjectDelete(0, nm); 
      ObjectCreate(0, nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSetInteger(0, nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSetInteger(0, nm, OBJPROP_BACK, false); 
      ObjectSetString(0, nm, OBJPROP_TEXT, text);
      ObjectSetString(0, nm, OBJPROP_FONT, Font);
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, FSize);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, LabelColor);
   }
};


// Label cell v5.0

#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ACell
{
   string _id;
   string _text; 
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   uint _color;
   int _windowNumber;
   string _textHAlign;
   bool _withBackground;
   uint _bgColor;
   int _width;
   int _height;
   int _linesHeights[];
   int _linesWidths[];
public:
   LabelCell(const string id, const string text, ENUM_BASE_CORNER corner, int fontSize, uint clr, int windowNumber)
   { 
      _withBackground = false;
      _textHAlign = "cental";
      _corner = corner;
      _id = id; 
      _text = text;
      _fontSize = fontSize;
      _color = GetColorOnly(clr);
      _windowNumber = windowNumber;
   }

   virtual void Measure(uint& width, uint& height)
   {
      _width = 0;
      _height = 0;
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      ArrayResize(_linesHeights, linesCount);
      ArrayResize(_linesWidths, linesCount);
      for (int i = 0; i < linesCount; ++i)
      {
         uint w, h;
         ACell::Measure(lines[i], "Arial", _fontSize, w, h);
         _height += h;
         _width = MathMax(_width, w);
         _linesHeights[i] = h;
         _linesWidths[i] = w;
      }
      width = _width;
      height = _height;
   }

   virtual void Draw(int x, int y, int width)
   {
      if (_withBackground)
      {
         if (ObjectFind(0, _id + "rect") == -1 && !ObjectCreate(0, _id + "rect", OBJ_RECTANGLE_LABEL, 0, 0, 0))
         {
            return;
         }
         ObjectSetInteger(0, _id + "rect", OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YDISTANCE, y);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BGCOLOR, _bgColor);
         ObjectSetInteger(0, _id + "rect", OBJPROP_XSIZE, width);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YSIZE, _height);
         ObjectSetInteger(0, _id + "rect", OBJPROP_COLOR, _color);
         ObjectSetInteger(0, _id + "rect", OBJPROP_CORNER, _corner);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BACK, true);
      }
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      for (int i = 0; i < linesCount; ++i)
      {
         int lineX = x;
         if (_textHAlign == "center")
         {
            lineX += (width - _linesWidths[i]) / 2;
         }
         else if (_textHAlign == "right")
         {
            lineX += width - _linesWidths[i];
         }
         ObjectMakeLabel(_id + "line" + i, lineX, y, lines[i], _color, _corner, _windowNumber, "Arial", _fontSize); 
         y += _linesHeights[i];
      }
   }
   
   bool SetBgColor(uint clr)
   {
      clr = GetColorOnly(clr);
      if (_bgColor == clr)
      {
         return false;
      }
      _bgColor = clr;
      _withBackground = true;
      return true;
   }

   virtual void HandleButtonClicks()
   {
      
   }
   
   bool SetColor(uint clr)
   {
      clr = GetColorOnly(clr);
      if (_color == clr)
      {
         return false;
      }
      _color = clr;
      return true;
   }
   
   bool SetText(string text)
   {
      if (_text == text)
      {
         return false;
      }
      _text = text;
      return true;
   }
   
   bool SetFontSize(int fontSize)
   {
      if (_fontSize == fontSize)
      {
         return false;
      }
      _fontSize = fontSize;
      return true;
   }
   
   bool SetTextHAlign(string textHAlign)
   {
      if (_textHAlign == textHAlign)
      {
         return false;
      }
      _textHAlign = textHAlign;
      return true;
   }
};

#endif

class Table;
class TableManager
{
   static Table* tables[];
public:
   static void Clear(bool forced = false);
   static void Add(Table* table);
   static void Redraw();
   static Table* Create(string prefix, string tableIndex, string position, int columns, int rows);
};

Table* TableManager::Create(string prefix, string tableIndex, string position, int columns, int rows)
{
   string id = prefix + "_" + tableIndex;
   int tablesCount = ArraySize(tables);
   for (int i = 0; i < tablesCount; ++i)
   {
      if (tables[i].GetId() == id)
      {
         return tables[i];
      }
   }
   return new Table(id, position, columns, rows);
}

Table* TableManager::tables[];
void TableManager::Clear(bool forced = false)
{
   int movedIndex = 0;
   for (int i = 0; i < ArraySize(TableManager::tables); ++i)
   {
      if (!tables[i].IsLocked())
      {
         delete tables[i];
      }
      else
      {
         tables[movedIndex] = tables[i];
         ++movedIndex;
      }
   }
   ArrayResize(tables, movedIndex);
}

void TableManager::Add(Table* table)
{
   int size = ArraySize(tables);
   ArrayResize(tables, size + 1);
   tables[size] = table;
}

void TableManager::Redraw()
{
   for (int i = 0; i < ArraySize(tables); ++i)
   {
      tables[i].Redraw();
   }
}

enum TablePosition
{
   TablePositionTopLeft,
   TablePositionTopCenter,
   TablePositionTopRight,
   TablePositionMiddleLeft,
   TablePositionMiddleCenter,
   TablePositionMiddleRight,
   TablePositionBottomLeft,
   TablePositionBottomCenter,
   TablePositionBottomRight
};

TablePosition TablePositionFromString(string value)
{
   if (value == "top_left") return TablePositionTopLeft;
   if (value == "top_center") return TablePositionTopCenter;
   if (value == "top_right") return TablePositionTopRight;
   if (value == "middle_left") return TablePositionMiddleLeft;
   if (value == "middle_center") return TablePositionMiddleCenter;
   if (value == "middle_right") return TablePositionMiddleRight;
   if (value == "bottom_left") return TablePositionBottomLeft;
   if (value == "bottom_center") return TablePositionBottomCenter;
   if (value == "bottom_right") return TablePositionBottomRight;
   return TablePositionMiddleCenter;
}

class Table
{
   string _prefix;
   TablePosition _position;
   int _columns;
   int _rows;

   int _borderWidth;
   uint _borderColor;
   
   int _frameWidth;
   uint _frameColor;
   Grid* _grid;
   bool locked;
public:
   Table(string prefix, string position, int columns, int rows)
   {
      locked = false;
      if (columns == EMPTY_VALUE)
      {
         columns = 0;
      }
      if (rows == EMPTY_VALUE)
      {
         rows = 0;
      }
      _prefix = prefix;
      _position = TablePositionFromString(position);
      _columns = columns;
      _rows = rows;
      _borderWidth = 0;
      _frameWidth = 0;
      _grid = new Grid();
      for (int i = 0; i < rows; ++i)
      {
         Row* row = _grid.AddRow();
         for (int j = 0; j < columns; ++j)
         {
            string id = _prefix + "_cell_" + IntegerToString(i) + "_" + IntegerToString(j);
            row.Add(new LabelCell(id, "", CORNER_LEFT_UPPER, 10, Red, 0));
         }
      }
      Redraw();
      TableManager::Add(&this);
   }
   ~Table()
   {
      delete _grid;
   }
   
   void Lock()
   {
      locked = true;
   }
   void Unlock()
   {
      locked = false;
   }
   bool IsLocked()
   {
      return locked;
   }
   
   string GetId()
   {
      return _prefix;
   }

   Table* SetBorderColor(uint clr)
   {
      _borderColor = clr;
      return &this;
   }
   Table* SetBorderWidth(int borderWidth)
   {
      _borderWidth = borderWidth;
      return &this;
   }
   Table* SetBGColor(uint clr)
   {
      for (int row = 0; row < _grid.GetRowsCount(); ++row)
      {
         Row* gridRow = _grid.GetRow(row);
         for (int column = 0; column < gridRow.GetColumnsCount(); ++column)
         {
            LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
            cell.SetBgColor(clr);
         }
      }
      return &this;
   }
   
   Table* SetFrameColor(uint clr)
   {
      _frameColor = clr;
      return &this;
   }
   Table* SetFrameWidth(int frameWidth)
   {
      _frameWidth = frameWidth;
      return &this;
   }
   static void CellText(Table* table, int column, int row, string text)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellText(column, row, text);
   }
   void CellText(int column, int row, string text)
   {
      Row* gridRow = _grid.GetRow(row);
      if (gridRow == NULL)
      {
         return;
      }
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetText(text))
      {
         Redraw();
      }
   }
   static void CellTextColor(Table* table, int column, int row, uint clr)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextColor(column, row, clr);
   }
   void CellTextColor(int column, int row, uint clr)
   {
      Row* gridRow = _grid.GetRow(row);
      if (gridRow == NULL)
      {
         return;
      }
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetColor(clr))
      {
      }
   }
   static void CellTextSize(Table* table, int column, int row, string size)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextSize(column, row, size);
   }
   void CellTextSize(int column, int row, string size)
   {
      Row* gridRow = _grid.GetRow(row);
      if (gridRow == NULL)
      {
         return;
      }
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetFontSize(GetFontSize(size)))
      {
      }
   }
   
   static void CellTextHAlign(Table* table, int column, int row, string halign)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextHAlign(column, row, halign);
   }
   void CellTextHAlign(int column, int row, string halign)
   {
      Row* gridRow = _grid.GetRow(row);
      if (gridRow == NULL)
      {
         return;
      }
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetTextHAlign(halign))
      {
      }
   }
   
   static void CellBGColor(Table* table, int column, int row, uint clr)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellBGColor(column, row, clr);
   }
   void CellBGColor(int column, int row, uint clr)
   {
      Row* gridRow = _grid.GetRow(row);
      if (gridRow == NULL)
      {
         return;
      }
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      cell.SetBgColor(clr);
   }
   
   void Redraw()
   {
      int x = 0;
      int y = 0;
      switch (_position)
      {
         case TablePositionTopLeft:
            break;
         case TablePositionTopCenter:
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionTopRight:
            x = GetScreenWidth() - GetGridWidth();
            break;
         case TablePositionMiddleLeft:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            break;
         case TablePositionMiddleCenter:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionMiddleRight:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            x = GetScreenWidth() - GetGridWidth();
            break;
         case TablePositionBottomLeft:
            y = GetScreenHeight() - GetGridHeight();
            break;
         case TablePositionBottomCenter:
            y = GetScreenHeight() - GetGridHeight();
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionBottomRight:
            y = GetScreenHeight() - GetGridHeight();
            x = GetScreenWidth() - GetGridWidth();
            break;
      }
      _grid.Draw(x, y);
   }
   
   static void MergeCells(Table* table, int startColumn, int startRow, int endColumn, int endRow)
   {
      //TODO: implement
   }
private:
   int GetFontSize(string size)
   {
      if (size == "auto" || size == "normal")
      {
         return 10;
      }
      if (size == "tiny")
      {
         return 6;
      }
      if (size == "small")
      {
         return 8;
      }
      if (size == "large")
      {
         return 12;
      }
      if (size == "huge")
      {
         return 14;
      }
      return 10;
   }
   int GetScreenWidth()
   {
      return ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   }
   int GetGridWidth()
   {
      int width = 0;
      for (int i = 0; i < _rows; ++i)
      {
         RowSize* rowSizes = new RowSize();
         _grid.GetRow(i).Measure(rowSizes);
         int rowWidth = 0;
         for (int ii = 0; ii < _columns; ++ii)
         {
            rowWidth += rowSizes.GetWidth(ii);
         }
         delete rowSizes;
         width = MathMax(width, rowWidth);
      }
      return width;
   }
   int GetScreenHeight()
   {
      return ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   }
   int GetGridHeight()
   {
      int height = 0;
      for (int i = 0; i < _rows; ++i)
      {
         RowSize* rowSizes = new RowSize();
         _grid.GetRow(i).Measure(rowSizes);
         height = MathMax(height, rowSizes.GetMaxHeight());
         delete rowSizes;
      }
      return height;
   }
};

//Signaler v5.1
#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import
#endif

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
   bool startProgram;
   string startProgramPath;
   bool popup_alert;
   bool email_alert;
   bool play_sound;
   string sound_file;
   bool notification_alert;
   bool advanced_alert;
   string advanced_key;
   string advanced_server;
public:
   Signaler(string frequency)
   {
      startProgram = false;
      popup_alert = true;
      email_alert = false;
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

   void EnablePopupAlert(bool enable)
   {
      popup_alert = enable;
   }
   void EnableEmailAlert(bool enable)
   {
      email_alert = enable;
   }
   void SetStartProgram(bool start, string path)
   {
      startProgram = start;
      startProgramPath = path;
   }
   void EnableSound(bool enabled, string soundFile)
   {
      play_sound = enabled;
      sound_file = soundFile;
   }
   void EnableNotificationAlert(bool enabled)
   {
      notification_alert = enabled;
   }
   void EnableAdvanced(bool enabled, string key, string server)
   {
      advanced_alert = enabled;
      advanced_key = key;
      advanced_server = server;
   }
   
   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void ShowAlert(string message, int position, datetime time)
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

#ifdef ADVANCED_ALERTS
      if (startProgram)
         ShellExecuteW(0, "open", startProgramPath, "", "", 1);
#endif
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (advanced_alert && advanced_key != "")
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
#endif
   }
};

enum param1_enum
{
   param1_value_1, // HTF
   param1_value_2 // Mult
};
input param1_enum param1_e = param1_value_1; // "Option:  " + s10
string Get_param1()
{
   switch (param1_e)
   {
      case param1_value_1: return "HTF";
      case param1_value_2: return "Mult";
   }
   return NULL;
}
input ENUM_TIMEFRAMES param2 = PERIOD_D1; // "� HTF" + s10 + s5
input int param3 = 3; // "� Mult" + s10 + s5
enum param4_enum
{
   param4_value_1, // W : L
   param4_value_2 // W% : L%
};
input param4_enum param4_e = param4_value_1; // SL / TP   
string Get_param4()
{
   switch (param4_e)
   {
      case param4_value_1: return "W : L";
      case param4_value_2: return "W% : L%";
   }
   return NULL;
}
input int param5 = 2; // "W : L" + s7
input int param6 = 1; // :
input double param7 = 5; // W% : L%
input double param8 = 2; // :
enum param9_enum
{
   param9_value_1, // RCM
   param9_value_2, // ATR
   param9_value_3 // Last Swing
};
input param9_enum param9_e = param9_value_1; // "Base:" + s7 + s10
string Get_param9()
{
   switch (param9_e)
   {
      case param9_value_1: return "RCM";
      case param9_value_2: return "ATR";
      case param9_value_3: return "Last Swing";
   }
   return NULL;
}
input int param10 = 3; // "� Multiple" + s10
input int param11 = 10; // � Swing Length
input color param12 = 0xf35721; // TP
input color param13 = 0x005dff; // SL
enum param14_enum
{
   param14_value_1, // "solid"
   param14_value_2, // "dashed"
   param14_value_3 // "dotted"
};
input param14_enum param14_e = param14_value_3; // Borders
string Get_param14()
{
   switch (param14_e)
   {
      case param14_value_1: return "solid";
      case param14_value_2: return "dashed";
      case param14_value_3: return "dotted";
   }
   return NULL;
}
input bool param15 = true; // Show Timeframe Change
input bool param16 = true; // Detect False Breakout
input color param17 = AddTransparency(Fuchsia, 80); // 
input bool param18 = false; // Cancel TP/SL at end of HTF
input bool param19 = true; // Show Dashboard
enum param20_enum
{
   param20_value_1, // Top Right
   param20_value_2, // Bottom Right
   param20_value_3 // Bottom Left
};
input param20_enum param20_e = param20_value_1; // Location
string Get_param20()
{
   switch (param20_e)
   {
      case param20_value_1: return "Top Right";
      case param20_value_2: return "Bottom Right";
      case param20_value_3: return "Bottom Left";
   }
   return NULL;
}
enum param21_enum
{
   param21_value_1, // Tiny
   param21_value_2, // Small
   param21_value_3 // Normal
};
input param21_enum param21_e = param21_value_2; // Size
string Get_param21()
{
   switch (param21_e)
   {
      case param21_value_1: return "Tiny";
      case param21_value_2: return "Small";
      case param21_value_3: return "Normal";
   }
   return NULL;
}
enum param22_enum
{
   param22_value_1, // Top Right
   param22_value_2, // Bottom Right
   param22_value_3 // Bottom Left
};
input param22_enum param22_e = param22_value_1; // Location
string Get_param22()
{
   switch (param22_e)
   {
      case param22_value_1: return "Top Right";
      case param22_value_2: return "Bottom Right";
      case param22_value_3: return "Bottom Left";
   }
   return NULL;
}
enum param23_enum
{
   param23_value_1, // Tiny
   param23_value_2, // Small
   param23_value_3 // Normal
};
input param23_enum param23_e = param23_value_2; // Size
string Get_param23()
{
   switch (param23_e)
   {
      case param23_value_1: return "Tiny";
      case param23_value_2: return "Small";
      case param23_value_3: return "Normal";
   }
   return NULL;
}
input bool param24 = true; // Detect False Breakout
input int bars_limit = 1000; // Bars limit
StrFormat* strFormat2;
StrFormat* strFormat3;
StrFormat* strFormat1;
Signaler* _signaler;
string s5;
string s7;
string s10;
string opt;
string res;
int mlt;
string iTP;
int w;
int l;
string loss;
int RcmAtrM;
int len;
uint INV;
uint cTP;
uint cSL;
string border;
int bcol;
int falseOutBreak;
uint cFail;
int stopAtEndHTF;
int showDash;
string dashLoc;
string textSize;
int n;
FloatStream* fixnan1X;
TIStream<double>* fixnan1;
FloatStream* fixnan2X;
TIStream<double>* fixnan2;
ATRStream* atr1;
FloatStream* cum1X;
CumOnStream* cum1;
class Tbreak
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   Tbreak(Tbreak* src)
   {
      _refs = 1;
      this.act = src.act;
      this.idx = src.idx;
      this.prc = src.prc;
      this.stp = src.stp;
      this.fail = src.fail;
      this.tp = src.tp;
      this.prof = src.prof;
   }
   Tbreak(int act = (-1), int idx = INT_MIN, double prc = EMPTY_VALUE, double stp = EMPTY_VALUE, int fail = (-1), double tp = EMPTY_VALUE, int prof = (-1))
   {
      _refs = 1;
      this.act = act;
      this.idx = idx;
      this.prc = prc;
      this.stp = stp;
      this.fail = fail;
      this.tp = tp;
      this.prof = prof;
   }
   ~Tbreak()
   {
   }
   int act;
   static int Getact(Tbreak* self) { return self == NULL ? (-1) : self.act; }
   static void Setact(Tbreak* self, int val) { if (self == NULL) return; self.act = val; }
   int idx;
   static int Getidx(Tbreak* self) { return self == NULL ? INT_MIN : self.idx; }
   static void Setidx(Tbreak* self, int val) { if (self == NULL) return; self.idx = val; }
   double prc;
   static double Getprc(Tbreak* self) { return self == NULL ? EMPTY_VALUE : self.prc; }
   static void Setprc(Tbreak* self, double val) { if (self == NULL) return; self.prc = val; }
   double stp;
   static double Getstp(Tbreak* self) { return self == NULL ? EMPTY_VALUE : self.stp; }
   static void Setstp(Tbreak* self, double val) { if (self == NULL) return; self.stp = val; }
   int fail;
   static int Getfail(Tbreak* self) { return self == NULL ? (-1) : self.fail; }
   static void Setfail(Tbreak* self, int val) { if (self == NULL) return; self.fail = val; }
   double tp;
   static double Gettp(Tbreak* self) { return self == NULL ? EMPTY_VALUE : self.tp; }
   static void Settp(Tbreak* self, double val) { if (self == NULL) return; self.tp = val; }
   int prof;
   static int Getprof(Tbreak* self) { return self == NULL ? (-1) : self.prof; }
   static void Setprof(Tbreak* self, int val) { if (self == NULL) return; self.prof = val; }
};
class resStream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   resStream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~resStream()
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
   bool GetValue(const int pos, const int oldPos, string &__out1)
   {
      int M = Timeframe::Multiplier() * mlt;
      string strM = Str::ToString(M);
      __out1 = ((opt == "HTF") ? (SafeGE(Timeframe::InSeconds(Timeframe::Period()), Timeframe::InSeconds(res)) ? "" : res) : (Timeframe::IsDaily() ? SafePlus(strM, "D") : (Timeframe::IsWeekly() ? SafePlus(strM, "W") : (Timeframe::IsMonthly() ? SafePlus(strM, "M") : ((M >= 1440) ? SafePlus(Str::ToString(SafeMathRound(SafeDivide(M, 1440))), "D") : strM)))));
      return true;
   }
};
resStream* res1;
Line* prevh;
double crossph[];
double crossph_DEFAULT_VALUE;
double max[];
double max_DEFAULT_VALUE;
double max_x1[];
double max_x1_DEFAULT_VALUE;
Line* prevl;
double crosspl[];
double crosspl_DEFAULT_VALUE;
double min[];
double min_DEFAULT_VALUE;
double min_x1[];
double min_x1_DEFAULT_VALUE;
double countBrOut_TT[];
double countBrOut_TT_DEFAULT_VALUE;
double count_F_BrOut_TT[];
double count_F_BrOut_TT_DEFAULT_VALUE;
double countTP_TT[];
double countTP_TT_DEFAULT_VALUE;
double countSL_TT[];
double countSL_TT_DEFAULT_VALUE;
double countWn_TT[];
double countWn_TT_DEFAULT_VALUE;
double countLs_TT[];
double countLs_TT_DEFAULT_VALUE;
double countBrOut_Bl[];
double countBrOut_Bl_DEFAULT_VALUE;
double count_F_BrOut_Bl[];
double count_F_BrOut_Bl_DEFAULT_VALUE;
double countTP_Bl[];
double countTP_Bl_DEFAULT_VALUE;
double countSL_Bl[];
double countSL_Bl_DEFAULT_VALUE;
double countWn_Bl[];
double countWn_Bl_DEFAULT_VALUE;
double countLs_Bl[];
double countLs_Bl_DEFAULT_VALUE;
double countBrOut_Br[];
double countBrOut_Br_DEFAULT_VALUE;
double count_F_BrOut_Br[];
double count_F_BrOut_Br_DEFAULT_VALUE;
double countTP_Br[];
double countTP_Br_DEFAULT_VALUE;
double countSL_Br[];
double countSL_Br_DEFAULT_VALUE;
double countWn_Br[];
double countWn_Br_DEFAULT_VALUE;
double countLs_Br[];
double countLs_Br_DEFAULT_VALUE;
Tbreak* bxTopBreak;
Tbreak* bxBtmBreak;
class lab_s_s_c_cStream
{
   string s;
   string _pos;
   uint col;
   uint txtcol;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   lab_s_s_c_cStream(string s, string _pos, uint col, uint txtcol, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.s = s;
      this._pos = _pos;
      this.col = col;
      this.txtcol = txtcol;
   }
   ~lab_s_s_c_cStream()
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
   bool GetValue(const int pos, const int oldPos, Label* &__out1)
   {
      __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", n, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetColor(col).SetText(s).SetTextColor(txtcol).SetStyle(((_pos == "top") ? "down" : "up")).SetSize("small").SetYLoc(((_pos == "top") ? "abovebar" : "belowbar")).SetTextAlign("center");
      return true;
   }
};
lab_s_s_c_cStream* lab_s_s_c_c2;
class update__Tbreakc_b_ic_fc_fc_b_fc_bStream
{
   int a;
   int f;
   int w;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   update__Tbreakc_b_ic_fc_fc_b_fc_bStream(int a, int f, int w, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.a = a;
      this.f = f;
      this.w = w;
   }
   ~update__Tbreakc_b_ic_fc_fc_b_fc_bStream()
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
   bool GetValue(const int pos, const int oldPos, Tbreak* __br, int __i, double __p, double __s, double __t, int &__out1)
   {
      Tbreak* br = __br;
      int i = __i;
      double p = __p;
      double s = __s;
      double t = __t;
      Tbreak::Setact(br, a);
      Tbreak::Setidx(br, i);
      Tbreak::Setprc(br, p);
      Tbreak::Setstp(br, s);
      Tbreak::Setfail(br, f);
      Tbreak::Settp(br, t);
      Tbreak::Setprof(br, w);
      __out1 = Tbreak::Getprof(br);
      return true;
   }
};
update__Tbreakc_b_ic_fc_fc_b_fc_bStream* update__Tbreakc_b_ic_fc_fc_b_fc_b3;
class poly__TbreakcStream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   poly__TbreakcStream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~poly__TbreakcStream()
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
   bool GetValue(const int pos, const int oldPos, Tbreak* __T, Polyline* &__out1)
   {
      Tbreak* T = __T;
      ICustomTypeArray<ChartPoint*>* __array1 = new ChartPointArray(0, NULL);
      ICustomTypeArray<ChartPoint*>* p = __array1;
      Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(p, ChartPoint::FromIndex(n, Tbreak::Getprc(T)));
      Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(p, ChartPoint::FromIndex(n, Tbreak::Gettp(T)));
      Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(p, ChartPoint::FromIndex(Tbreak::Getidx(T), Tbreak::Gettp(T)));
      Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(p, ChartPoint::FromIndex(Tbreak::Getidx(T), Tbreak::Getprc(T)));
      PolyLinesCollection::Create(IndicatorObjPrefix + "polyline_1_id", p, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetLineColor(INV).SetFillColor(AddTransparency(Green, 75)).SetLineWidth(1).SetCurved(false).SetClosed(false).SetForceOverlay(false);
      ICustomTypeArray<ChartPoint*>* __array2 = new ChartPointArray(0, NULL);
      p = __array2;
      Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(p, ChartPoint::FromIndex(n, Tbreak::Getstp(T)));
      Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(p, ChartPoint::FromIndex(Tbreak::Getidx(T), Tbreak::Getstp(T)));
      Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(p, ChartPoint::FromIndex(Tbreak::Getidx(T), Tbreak::Getprc(T)));
      Array::Unshift<ICustomTypeArray<ChartPoint*>*, ChartPoint*>(p, ChartPoint::FromIndex(n, Tbreak::Getprc(T)));
      __out1 = PolyLinesCollection::Create(IndicatorObjPrefix + "polyline_2_id", p, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos)).SetLineColor(INV).SetFillColor(AddTransparency(Red, 75)).SetLineWidth(1).SetCurved(false).SetClosed(false).SetForceOverlay(false);
      __array2.Release();
      __array1.Release();
      return true;
   }
};
poly__TbreakcStream* poly__Tbreakc4;
class box__custom_s__TbreakcStream
{
   string s;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   box__custom_s__TbreakcStream(string s, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.s = s;
   }
   ~box__custom_s__TbreakcStream()
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
   bool GetValue(const int pos, const int oldPos, Tbreak* __obj, Box* &__out1)
   {
      Tbreak* obj = __obj;
      BoxesCollection::Create(IndicatorObjPrefix + "box_1_id", Tbreak::Getidx(obj), Tbreak::Getprc(obj), n, Tbreak::Gettp(obj), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos))
         .SetBgColor(AddTransparency(cTP, 85))
         .SetBorderColor(((s == "fail") ? INV : ((((s == "prof") || ((Tbreak::Getprc(obj) > Tbreak::Getstp(obj)) && (iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos) > Tbreak::Getprc(obj)))) || ((Tbreak::Getprc(obj) < Tbreak::Getstp(obj)) && (iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos) < Tbreak::Getprc(obj)))) ? cTP : INV)))
         .SetExtend("none");
      __out1 = BoxesCollection::Create(IndicatorObjPrefix + "box_2_id", Tbreak::Getidx(obj), Tbreak::Getprc(obj), n, Tbreak::Getstp(obj), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos))
         .SetBgColor(AddTransparency(cSL, 85))
         .SetBorderColor(((s == "prof") ? INV : ((((s == "fail") || ((Tbreak::Getprc(obj) > Tbreak::Getstp(obj)) && (iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos) < Tbreak::Getprc(obj)))) || ((Tbreak::Getprc(obj) < Tbreak::Getstp(obj)) && (iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos) > Tbreak::Getprc(obj)))) ? cSL : INV)))
         .SetExtend("none");
      return true;
   }
};
box__custom_s__TbreakcStream* box__custom_s__Tbreakc5;
lab_s_s_c_cStream* lab_s_s_c_c6;
class update__Tbreakc_b_i_f_f_b_f_bStream
{
   int a;
   int i;
   double p;
   double s;
   int f;
   double t;
   int w;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   update__Tbreakc_b_i_f_f_b_f_bStream(int a, int i, double p, double s, int f, double t, int w, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.a = a;
      this.i = i;
      this.p = p;
      this.s = s;
      this.f = f;
      this.t = t;
      this.w = w;
   }
   ~update__Tbreakc_b_i_f_f_b_f_bStream()
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
   bool GetValue(const int pos, const int oldPos, Tbreak* __br, int &__out1)
   {
      Tbreak* br = __br;
      Tbreak::Setact(br, a);
      Tbreak::Setidx(br, i);
      Tbreak::Setprc(br, p);
      Tbreak::Setstp(br, s);
      Tbreak::Setfail(br, f);
      Tbreak::Settp(br, t);
      Tbreak::Setprof(br, w);
      __out1 = Tbreak::Getprof(br);
      return true;
   }
};
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b7;
box__custom_s__TbreakcStream* box__custom_s__Tbreakc8;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b9;
box__custom_s__TbreakcStream* box__custom_s__Tbreakc10;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b11;
poly__TbreakcStream* poly__Tbreakc12;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b13;
lab_s_s_c_cStream* lab_s_s_c_c14;
update__Tbreakc_b_ic_fc_fc_b_fc_bStream* update__Tbreakc_b_ic_fc_fc_b_fc_b15;
poly__TbreakcStream* poly__Tbreakc16;
box__custom_s__TbreakcStream* box__custom_s__Tbreakc17;
lab_s_s_c_cStream* lab_s_s_c_c18;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b19;
box__custom_s__TbreakcStream* box__custom_s__Tbreakc20;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b21;
box__custom_s__TbreakcStream* box__custom_s__Tbreakc22;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b23;
poly__TbreakcStream* poly__Tbreakc24;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b25;
double breakTop[];
double breakTop_DEFAULT_VALUE;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b26;
double breakBtm[];
double breakBtm_DEFAULT_VALUE;
update__Tbreakc_b_i_f_f_b_f_bStream* update__Tbreakc_b_i_f_f_b_f_b27;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
string table_position;
string table_size;
Table* tb;
FirstBarState* isFirst1;
class formatRes_scStream
{
   string res;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   formatRes_scStream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~formatRes_scStream()
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
   bool GetValue(const int pos, const int oldPos, string __res, string &__out1)
   {
      res = __res;
      string out = res;
      if (!Str::Contains(res, "D") && !Str::Contains(res, "W") && !Str::Contains(res, "M"))
      {
         double nRes = Str::ToNumber(res);
         if ((SafeMod(nRes, 60) == 0))
         {
            out = strFormat2.Add(SafeDivide(nRes, 60)).Add("h").Format();
         }
         else
         {
            out = strFormat3.Add(nRes).Add("min").Format();
         }
      }
      __out1 = out;
      return true;
   }
};
formatRes_scStream* formatRes_sc28;

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

string GenerateIndicatorPrefix(string target)
{
   if (StringLen(target) > 20)
   {
      target = StringSubstr(target, 0, 20);
   }
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
   opt = Get_param1();
   mlt = param3;
   iTP = Get_param4();
   w = param5;
   l = param6;
   loss = Get_param9();
   RcmAtrM = param10;
   len = param11;
   cTP = param12;
   cSL = param13;
   border = Get_param14();
   bcol = param15;
   falseOutBreak = param16;
   cFail = param17;
   stopAtEndHTF = param18;
   showDash = param19;
   dashLoc = Get_param20();
   textSize = Get_param21();
   fixnan1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan1 = FixnanStreamFactory::Create(fixnan1X);
   fixnan2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan2 = FixnanStreamFactory::Create(fixnan2X);
   atr1 = new ATRStream(200);
   cum1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cum1 = new CumOnStream(cum1X);
   int id = 0;
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, AddTransparency(cTP, 50));
   ++id;
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, AddTransparency(cTP, 50));
   ++id;
   SetIndexBuffer(id, plot3, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, AddTransparency(cSL, 50));
   ++id;
   SetIndexBuffer(id, plot4, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, AddTransparency(cSL, 50));
   ++id;
   dashLoc = Get_param22();
   textSize = Get_param23();
   falseOutBreak = param24;
   LinesCollection::SetMaxLines(500);
   LabelsCollection::SetMaxLabels(500);
   PolyLinesCollection::SetMaxLines(500);
   BoxesCollection::SetMaxBoxes(500);
   strFormat2 = new StrFormat("{0}{1}");
   strFormat3 = new StrFormat("{0}{1}");
   strFormat1 = new StrFormat("HTF = {0}");
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("LABDPMTFHLW");
   IndicatorSetString(INDICATOR_SHORTNAME, "Breakout Detector (Previous MTF High Low Levels) [LuxAlgo]");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   res1 = new resStream(IndicatorObjPrefix + "_1");
   id = res1.Init(id);
   SetIndexBuffer(id++, crossph, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, max, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, max_x1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, crosspl, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, min, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, min_x1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countBrOut_TT, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, count_F_BrOut_TT, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countTP_TT, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countSL_TT, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countWn_TT, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countLs_TT, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countBrOut_Bl, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, count_F_BrOut_Bl, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countTP_Bl, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countSL_Bl, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countWn_Bl, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countLs_Bl, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countBrOut_Br, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, count_F_BrOut_Br, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countTP_Br, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countSL_Br, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countWn_Br, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, countLs_Br, INDICATOR_CALCULATIONS);
      bxTopBreak = new Tbreak(false, NULL, NULL, NULL, NULL, NULL, NULL);
      bxBtmBreak = new Tbreak(false, NULL, NULL, NULL, NULL, NULL, NULL);
   lab_s_s_c_c2 = new lab_s_s_c_cStream("^", "btm", (uint)(INT_MAX), 0x819908, IndicatorObjPrefix + "_2");
   id = lab_s_s_c_c2.Init(id);
   update__Tbreakc_b_ic_fc_fc_b_fc_b3 = new update__Tbreakc_b_ic_fc_fc_b_fc_bStream(true, false, false, IndicatorObjPrefix + "_3");
   id = update__Tbreakc_b_ic_fc_fc_b_fc_b3.Init(id);
   poly__Tbreakc4 = new poly__TbreakcStream(IndicatorObjPrefix + "_4");
   id = poly__Tbreakc4.Init(id);
   box__custom_s__Tbreakc5 = new box__custom_s__TbreakcStream("none", IndicatorObjPrefix + "_5");
   id = box__custom_s__Tbreakc5.Init(id);
   lab_s_s_c_c6 = new lab_s_s_c_cStream("F", "top", cFail, White, IndicatorObjPrefix + "_6");
   id = lab_s_s_c_c6.Init(id);
   update__Tbreakc_b_i_f_f_b_f_b7 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, NULL, NULL, NULL, IndicatorObjPrefix + "_7");
   id = update__Tbreakc_b_i_f_f_b_f_b7.Init(id);
   box__custom_s__Tbreakc8 = new box__custom_s__TbreakcStream("prof", IndicatorObjPrefix + "_8");
   id = box__custom_s__Tbreakc8.Init(id);
   update__Tbreakc_b_i_f_f_b_f_b9 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, NULL, NULL, NULL, IndicatorObjPrefix + "_9");
   id = update__Tbreakc_b_i_f_f_b_f_b9.Init(id);
   box__custom_s__Tbreakc10 = new box__custom_s__TbreakcStream("fail", IndicatorObjPrefix + "_10");
   id = box__custom_s__Tbreakc10.Init(id);
   update__Tbreakc_b_i_f_f_b_f_b11 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, NULL, NULL, NULL, IndicatorObjPrefix + "_11");
   id = update__Tbreakc_b_i_f_f_b_f_b11.Init(id);
   poly__Tbreakc12 = new poly__TbreakcStream(IndicatorObjPrefix + "_12");
   id = poly__Tbreakc12.Init(id);
   update__Tbreakc_b_i_f_f_b_f_b13 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, NULL, NULL, NULL, IndicatorObjPrefix + "_13");
   id = update__Tbreakc_b_i_f_f_b_f_b13.Init(id);
   lab_s_s_c_c14 = new lab_s_s_c_cStream("�", "top", (uint)(INT_MAX), 0x4536f2, IndicatorObjPrefix + "_14");
   id = lab_s_s_c_c14.Init(id);
   update__Tbreakc_b_ic_fc_fc_b_fc_b15 = new update__Tbreakc_b_ic_fc_fc_b_fc_bStream(true, false, false, IndicatorObjPrefix + "_15");
   id = update__Tbreakc_b_ic_fc_fc_b_fc_b15.Init(id);
   poly__Tbreakc16 = new poly__TbreakcStream(IndicatorObjPrefix + "_16");
   id = poly__Tbreakc16.Init(id);
   box__custom_s__Tbreakc17 = new box__custom_s__TbreakcStream("none", IndicatorObjPrefix + "_17");
   id = box__custom_s__Tbreakc17.Init(id);
   lab_s_s_c_c18 = new lab_s_s_c_cStream("F", "btm", cFail, White, IndicatorObjPrefix + "_18");
   id = lab_s_s_c_c18.Init(id);
   update__Tbreakc_b_i_f_f_b_f_b19 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, NULL, NULL, NULL, IndicatorObjPrefix + "_19");
   id = update__Tbreakc_b_i_f_f_b_f_b19.Init(id);
   box__custom_s__Tbreakc20 = new box__custom_s__TbreakcStream("prof", IndicatorObjPrefix + "_20");
   id = box__custom_s__Tbreakc20.Init(id);
   update__Tbreakc_b_i_f_f_b_f_b21 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, NULL, NULL, NULL, IndicatorObjPrefix + "_21");
   id = update__Tbreakc_b_i_f_f_b_f_b21.Init(id);
   box__custom_s__Tbreakc22 = new box__custom_s__TbreakcStream("fail", IndicatorObjPrefix + "_22");
   id = box__custom_s__Tbreakc22.Init(id);
   update__Tbreakc_b_i_f_f_b_f_b23 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, NULL, NULL, NULL, IndicatorObjPrefix + "_23");
   id = update__Tbreakc_b_i_f_f_b_f_b23.Init(id);
   poly__Tbreakc24 = new poly__TbreakcStream(IndicatorObjPrefix + "_24");
   id = poly__Tbreakc24.Init(id);
   update__Tbreakc_b_i_f_f_b_f_b25 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, NULL, NULL, NULL, IndicatorObjPrefix + "_25");
   id = update__Tbreakc_b_i_f_f_b_f_b25.Init(id);
   SetIndexBuffer(id++, breakTop, INDICATOR_CALCULATIONS);
   update__Tbreakc_b_i_f_f_b_f_b26 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, false, NULL, NULL, IndicatorObjPrefix + "_26");
   id = update__Tbreakc_b_i_f_f_b_f_b26.Init(id);
   SetIndexBuffer(id++, breakBtm, INDICATOR_CALCULATIONS);
   update__Tbreakc_b_i_f_f_b_f_b27 = new update__Tbreakc_b_i_f_f_b_f_bStream(false, NULL, NULL, NULL, false, NULL, NULL, IndicatorObjPrefix + "_27");
   id = update__Tbreakc_b_i_f_f_b_f_b27.Init(id);
   isFirst1 = new FirstBarState();
   formatRes_sc28 = new formatRes_scStream(IndicatorObjPrefix + "_28");
   id = formatRes_sc28.Init(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   fixnan1X.Release();
   fixnan1.Release();
   fixnan2X.Release();
   fixnan2.Release();
   atr1.Release();
   cum1X.Release();
   cum1.Release();
   delete res1;
   bxTopBreak.Release();
   bxBtmBreak.Release();
   delete lab_s_s_c_c2;
   delete update__Tbreakc_b_ic_fc_fc_b_fc_b3;
   delete poly__Tbreakc4;
   delete box__custom_s__Tbreakc5;
   delete lab_s_s_c_c6;
   delete update__Tbreakc_b_i_f_f_b_f_b7;
   delete box__custom_s__Tbreakc8;
   delete update__Tbreakc_b_i_f_f_b_f_b9;
   delete box__custom_s__Tbreakc10;
   delete update__Tbreakc_b_i_f_f_b_f_b11;
   delete poly__Tbreakc12;
   delete update__Tbreakc_b_i_f_f_b_f_b13;
   delete lab_s_s_c_c14;
   delete update__Tbreakc_b_ic_fc_fc_b_fc_b15;
   delete poly__Tbreakc16;
   delete box__custom_s__Tbreakc17;
   delete lab_s_s_c_c18;
   delete update__Tbreakc_b_i_f_f_b_f_b19;
   delete box__custom_s__Tbreakc20;
   delete update__Tbreakc_b_i_f_f_b_f_b21;
   delete box__custom_s__Tbreakc22;
   delete update__Tbreakc_b_i_f_f_b_f_b23;
   delete poly__Tbreakc24;
   delete update__Tbreakc_b_i_f_f_b_f_b25;
   delete update__Tbreakc_b_i_f_f_b_f_b26;
   delete update__Tbreakc_b_i_f_f_b_f_b27;
   delete isFirst1;
   delete formatRes_sc28;
   LinesCollection::Clear(true);
   LabelsCollection::Clear(true);
   PolyLinesCollection::Clear(true);
   BoxesCollection::Clear(true);
   TableManager::Clear(true);
   delete strFormat2;
   delete strFormat3;
   delete strFormat1;
   delete _signaler;
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
      LinesCollection::Clear();
      LabelsCollection::Clear();
      PolyLinesCollection::Clear();
      BoxesCollection::Clear();
      TableManager::Clear();
      fixnan1X.Init();
      fixnan2X.Init();
      cum1X.Init();
      res1.Clear();
      prevh = NULL;
      crossph_DEFAULT_VALUE = false;
      ArrayInitialize(crossph, crossph_DEFAULT_VALUE);
      max_DEFAULT_VALUE = high[0];
      ArrayInitialize(max, max_DEFAULT_VALUE);
      max_x1_DEFAULT_VALUE = 0;
      ArrayInitialize(max_x1, max_x1_DEFAULT_VALUE);
      prevl = NULL;
      crosspl_DEFAULT_VALUE = false;
      ArrayInitialize(crosspl, crosspl_DEFAULT_VALUE);
      min_DEFAULT_VALUE = low[0];
      ArrayInitialize(min, min_DEFAULT_VALUE);
      min_x1_DEFAULT_VALUE = 0;
      ArrayInitialize(min_x1, min_x1_DEFAULT_VALUE);
      countBrOut_TT_DEFAULT_VALUE = 0;
      ArrayInitialize(countBrOut_TT, countBrOut_TT_DEFAULT_VALUE);
      count_F_BrOut_TT_DEFAULT_VALUE = 0;
      ArrayInitialize(count_F_BrOut_TT, count_F_BrOut_TT_DEFAULT_VALUE);
      countTP_TT_DEFAULT_VALUE = 0;
      ArrayInitialize(countTP_TT, countTP_TT_DEFAULT_VALUE);
      countSL_TT_DEFAULT_VALUE = 0;
      ArrayInitialize(countSL_TT, countSL_TT_DEFAULT_VALUE);
      countWn_TT_DEFAULT_VALUE = 0;
      ArrayInitialize(countWn_TT, countWn_TT_DEFAULT_VALUE);
      countLs_TT_DEFAULT_VALUE = 0;
      ArrayInitialize(countLs_TT, countLs_TT_DEFAULT_VALUE);
      countBrOut_Bl_DEFAULT_VALUE = 0;
      ArrayInitialize(countBrOut_Bl, countBrOut_Bl_DEFAULT_VALUE);
      count_F_BrOut_Bl_DEFAULT_VALUE = 0;
      ArrayInitialize(count_F_BrOut_Bl, count_F_BrOut_Bl_DEFAULT_VALUE);
      countTP_Bl_DEFAULT_VALUE = 0;
      ArrayInitialize(countTP_Bl, countTP_Bl_DEFAULT_VALUE);
      countSL_Bl_DEFAULT_VALUE = 0;
      ArrayInitialize(countSL_Bl, countSL_Bl_DEFAULT_VALUE);
      countWn_Bl_DEFAULT_VALUE = 0;
      ArrayInitialize(countWn_Bl, countWn_Bl_DEFAULT_VALUE);
      countLs_Bl_DEFAULT_VALUE = 0;
      ArrayInitialize(countLs_Bl, countLs_Bl_DEFAULT_VALUE);
      countBrOut_Br_DEFAULT_VALUE = 0;
      ArrayInitialize(countBrOut_Br, countBrOut_Br_DEFAULT_VALUE);
      count_F_BrOut_Br_DEFAULT_VALUE = 0;
      ArrayInitialize(count_F_BrOut_Br, count_F_BrOut_Br_DEFAULT_VALUE);
      countTP_Br_DEFAULT_VALUE = 0;
      ArrayInitialize(countTP_Br, countTP_Br_DEFAULT_VALUE);
      countSL_Br_DEFAULT_VALUE = 0;
      ArrayInitialize(countSL_Br, countSL_Br_DEFAULT_VALUE);
      countWn_Br_DEFAULT_VALUE = 0;
      ArrayInitialize(countWn_Br, countWn_Br_DEFAULT_VALUE);
      countLs_Br_DEFAULT_VALUE = 0;
      ArrayInitialize(countLs_Br, countLs_Br_DEFAULT_VALUE);
      lab_s_s_c_c2.Clear();
      update__Tbreakc_b_ic_fc_fc_b_fc_b3.Clear();
      poly__Tbreakc4.Clear();
      box__custom_s__Tbreakc5.Clear();
      lab_s_s_c_c6.Clear();
      update__Tbreakc_b_i_f_f_b_f_b7.Clear();
      box__custom_s__Tbreakc8.Clear();
      update__Tbreakc_b_i_f_f_b_f_b9.Clear();
      box__custom_s__Tbreakc10.Clear();
      update__Tbreakc_b_i_f_f_b_f_b11.Clear();
      poly__Tbreakc12.Clear();
      update__Tbreakc_b_i_f_f_b_f_b13.Clear();
      lab_s_s_c_c14.Clear();
      update__Tbreakc_b_ic_fc_fc_b_fc_b15.Clear();
      poly__Tbreakc16.Clear();
      box__custom_s__Tbreakc17.Clear();
      lab_s_s_c_c18.Clear();
      update__Tbreakc_b_i_f_f_b_f_b19.Clear();
      box__custom_s__Tbreakc20.Clear();
      update__Tbreakc_b_i_f_f_b_f_b21.Clear();
      box__custom_s__Tbreakc22.Clear();
      update__Tbreakc_b_i_f_f_b_f_b23.Clear();
      poly__Tbreakc24.Clear();
      update__Tbreakc_b_i_f_f_b_f_b25.Clear();
      breakTop_DEFAULT_VALUE = (-1);
      ArrayInitialize(breakTop, breakTop_DEFAULT_VALUE);
      update__Tbreakc_b_i_f_f_b_f_b26.Clear();
      breakBtm_DEFAULT_VALUE = (-1);
      ArrayInitialize(breakBtm, breakBtm_DEFAULT_VALUE);
      update__Tbreakc_b_i_f_f_b_f_b27.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      table_position = ((dashLoc == "Bottom Left") ? "bottom_left" : ((dashLoc == "Top Right") ? "top_right" : "bottom_right"));
      table_size = ((textSize == "Tiny") ? "tiny" : ((textSize == "Small") ? "small" : "normal"));
      tb = TableManager::Create(IndicatorObjPrefix, "1", table_position, (falseOutBreak ? 7 : 6), 5).SetBorderWidth(1).SetBGColor(0x2d221e).SetBorderColor(0x463a37).SetFrameColor(0x463a37).SetFrameWidth(1);
      isFirst1.Clear();
      formatRes_sc28.Clear();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      crossph[pos] = pos > 0 ? crossph[pos - 1] : false;
      max[pos] = pos > 0 ? max[pos - 1] : high[pos];
      max_x1[pos] = pos > 0 ? max_x1[pos - 1] : 0;
      crosspl[pos] = pos > 0 ? crosspl[pos - 1] : false;
      min[pos] = pos > 0 ? min[pos - 1] : low[pos];
      min_x1[pos] = pos > 0 ? min_x1[pos - 1] : 0;
      countBrOut_TT[pos] = pos > 0 ? countBrOut_TT[pos - 1] : 0;
      count_F_BrOut_TT[pos] = pos > 0 ? count_F_BrOut_TT[pos - 1] : 0;
      countTP_TT[pos] = pos > 0 ? countTP_TT[pos - 1] : 0;
      countSL_TT[pos] = pos > 0 ? countSL_TT[pos - 1] : 0;
      countWn_TT[pos] = pos > 0 ? countWn_TT[pos - 1] : 0;
      countLs_TT[pos] = pos > 0 ? countLs_TT[pos - 1] : 0;
      countBrOut_Bl[pos] = pos > 0 ? countBrOut_Bl[pos - 1] : 0;
      count_F_BrOut_Bl[pos] = pos > 0 ? count_F_BrOut_Bl[pos - 1] : 0;
      countTP_Bl[pos] = pos > 0 ? countTP_Bl[pos - 1] : 0;
      countSL_Bl[pos] = pos > 0 ? countSL_Bl[pos - 1] : 0;
      countWn_Bl[pos] = pos > 0 ? countWn_Bl[pos - 1] : 0;
      countLs_Bl[pos] = pos > 0 ? countLs_Bl[pos - 1] : 0;
      countBrOut_Br[pos] = pos > 0 ? countBrOut_Br[pos - 1] : 0;
      count_F_BrOut_Br[pos] = pos > 0 ? count_F_BrOut_Br[pos - 1] : 0;
      countTP_Br[pos] = pos > 0 ? countTP_Br[pos - 1] : 0;
      countSL_Br[pos] = pos > 0 ? countSL_Br[pos - 1] : 0;
      countWn_Br[pos] = pos > 0 ? countWn_Br[pos - 1] : 0;
      countLs_Br[pos] = pos > 0 ? countLs_Br[pos - 1] : 0;
      s5 = "     ";
      s7 = "       ";
      s10 = "          ";
      res = Timeframe::ToString(param2);
      double percW = SafeDivide(param7, 100);
      double percL = SafeDivide(param8, 100);
      INV = AddTransparency(Blue, 100);
      int x = (falseOutBreak ? 2 : 0);
      n = pos;
      double highestpivot1Value[1];
      if (!PivotHighStream::GetValues(pos, 1, highestpivot1Value, _Symbol, (ENUM_TIMEFRAMES)_Period, len, 1)) { highestpivot1Value[0] = EMPTY_VALUE; }
      fixnan1X.SetValue(pos, highestpivot1Value[0]);
      double fixnan1Value[1];
      if (!fixnan1.GetValues(pos, 1, fixnan1Value)) { fixnan1Value[0] = EMPTY_VALUE; }
      double ph = fixnan1Value[0];
      double lowestpivot1Value[1];
      if (!PivotLowStream::GetValues(pos, 1, lowestpivot1Value, _Symbol, (ENUM_TIMEFRAMES)_Period, len, 1)) { lowestpivot1Value[0] = EMPTY_VALUE; }
      fixnan2X.SetValue(pos, lowestpivot1Value[0]);
      double fixnan2Value[1];
      if (!fixnan2.GetValues(pos, 1, fixnan2Value)) { fixnan2Value[0] = EMPTY_VALUE; }
      double pl = fixnan2Value[0];
      double atr1Value[1];
      if (!atr1.GetValues(pos, 1, atr1Value)) { atr1Value[0] = EMPTY_VALUE; }
      double atr = atr1Value[0];
      cum1X.SetValue(pos, high[pos] - low[pos]);
      double cum1Value[1];
      if (!cum1.GetValues(pos, 1, cum1Value)) { cum1Value[0] = EMPTY_VALUE; }
      double rcm = SafeDivide(cum1Value[0], (n + 1));
      string res1Value;
      if (!res1.GetValue(pos, oldPos, res1Value)) { res1Value = NULL; }
      string fres = res1Value;
      int tfCh = Timeframe::Change(fres, pos);
      int brOutBl = false;
      int falseBl = false;
      int prof_Bl = false;
      int fail_Bl = false;
      int brOutBr = false;
      int falseBr = false;
      int prof_Br = false;
      int fail_Br = false;
      if (tfCh)
      {
         if (!crossph[pos])
         {
            Line::SetX2(prevh, max_x1[pos]);
         }
         if (!crosspl[pos])
         {
            Line::SetX2(prevl, min_x1[pos]);
         }
         prevh = LinesCollection::Create(IndicatorObjPrefix + "line_1_id", max_x1[pos], max[pos], n, max[pos], time[pos]).SetColor(0x4536f2).SetWidth(1).SetStyle("solid").SetExtend("none");
         prevl = LinesCollection::Create(IndicatorObjPrefix + "line_2_id", min_x1[pos], min[pos], n, min[pos], time[pos]).SetColor(0x819908).SetWidth(1).SetStyle("solid").SetExtend("none");
         SetStream(max, pos, high[pos], max_DEFAULT_VALUE);
         SetStream(max_x1, pos, n, max_x1_DEFAULT_VALUE);
         SetStream(crossph, pos, false, crossph_DEFAULT_VALUE);
         SetStream(min, pos, low[pos], min_DEFAULT_VALUE);
         SetStream(min_x1, pos, n, min_x1_DEFAULT_VALUE);
         SetStream(crosspl, pos, false, crosspl_DEFAULT_VALUE);
      }
      else
      {
         SetStream(max, pos, MathMax(high[pos], max[pos]), max_DEFAULT_VALUE);
         SetStream(max_x1, pos, ((max[pos] == high[pos]) ? n : max_x1[pos]), max_x1_DEFAULT_VALUE);
         SetStream(min, pos, MathMin(low[pos], min[pos]), min_DEFAULT_VALUE);
         SetStream(min_x1, pos, ((min[pos] == low[pos]) ? n : min_x1[pos]), min_x1_DEFAULT_VALUE);
      }
      if (!crossph[pos])
      {
         Line::SetX2(prevh, n);
      }
      if (SafeGreater(close[pos], Line::GetY2(prevh)))
      {
         SetStream(crossph, pos, true, crossph_DEFAULT_VALUE);
      }
      if (!crosspl[pos])
      {
         Line::SetX2(prevl, n);
      }
      if (SafeLess(close[pos], Line::GetY2(prevl)))
      {
         SetStream(crosspl, pos, true, crosspl_DEFAULT_VALUE);
      }
      int ATRok = ((iTP == "W : L") && (loss == "ATR") ? (n > 200) : true);
      double top = Line::GetY2(prevh);
      if (pos - 1 < 0) { continue; }
      SetStream(breakTop, pos, crossph[pos] && !crossph[pos - 1] && ATRok && !Tbreak::Getact(bxTopBreak), breakTop_DEFAULT_VALUE);
      double btm = Line::GetY2(prevl);
      if (pos - 1 < 0) { continue; }
      SetStream(breakBtm, pos, crosspl[pos] && !crosspl[pos - 1] && ATRok && !Tbreak::Getact(bxBtmBreak), breakBtm_DEFAULT_VALUE);
      ICustomTypeArray<Polyline*>* foreach1_items = PolyLinesCollection::GetArray();
      for (int foreach1_index = 0; foreach1_index < Array::Size<int, ICustomTypeArray<Polyline*>*>(foreach1_items, INT_MIN); ++foreach1_index)
      {
         Polyline* poly = Array::Get<Polyline*, ICustomTypeArray<Polyline*>*, int>(foreach1_items, foreach1_index, NULL);
         PolyLinesCollection::Delete(poly);
      }
      if (breakTop[pos])
      {
         brOutBl = true;
         SetStream(countBrOut_TT, pos, countBrOut_TT[pos] + 1, countBrOut_TT_DEFAULT_VALUE);
         SetStream(countBrOut_Bl, pos, countBrOut_Bl[pos] + 1, countBrOut_Bl_DEFAULT_VALUE);
         Label* lab_s_s_c_c2Value;
         if (!lab_s_s_c_c2.GetValue(pos, oldPos, lab_s_s_c_c2Value)) { lab_s_s_c_c2Value = NULL; }
         lab_s_s_c_c2Value;
         double ls = ((iTP == "W% : L%") ? SafeMultiply(close[pos], (SafeMinus(1, percL))) : ((loss == "ATR") ? SafeMinus(close[pos], (SafeMultiply(atr, RcmAtrM))) : ((loss == "RCM") ? SafeMinus(close[pos], (SafeMultiply(rcm, RcmAtrM))) : pl)));
         double pf = ((iTP == "W% : L%") ? SafeMultiply(close[pos], (SafePlus(1, percW))) : ((loss == "ATR") ? SafePlus(close[pos], (SafeMultiply((SafeMultiply(atr, RcmAtrM)), (SafeDivide(w, l))))) : ((loss == "RCM") ? SafePlus(close[pos], (SafeMultiply((SafeMultiply(rcm, RcmAtrM)), (SafeDivide(w, l))))) : SafePlus(close[pos], SafeMultiply((SafeMinus(close[pos], pl)), (SafeDivide(w, l)))))));
         int update__Tbreakc_b_ic_fc_fc_b_fc_b3Value;
         if (!update__Tbreakc_b_ic_fc_fc_b_fc_b3.GetValue(pos, oldPos, bxTopBreak, n, close[pos], ls, pf, update__Tbreakc_b_ic_fc_fc_b_fc_b3Value)) { update__Tbreakc_b_ic_fc_fc_b_fc_b3Value = (-1); }
         update__Tbreakc_b_ic_fc_fc_b_fc_b3Value;
         Polyline* poly__Tbreakc4Value;
         if (!poly__Tbreakc4.GetValue(pos, oldPos, bxTopBreak, poly__Tbreakc4Value)) { poly__Tbreakc4Value = NULL; }
         poly__Tbreakc4Value;
      }
      else if (Tbreak::Getact(bxTopBreak))
      {
         if ((breakBtm[pos] || (stopAtEndHTF && tfCh)))
         {
            if ((close[pos] >= Tbreak::Getprc(bxTopBreak)))
            {
               if ((close[pos] < Tbreak::Gettp(bxTopBreak)))
               {
                  SetStream(countWn_TT, pos, countWn_TT[pos] + 1, countWn_TT_DEFAULT_VALUE);
                  SetStream(countWn_Bl, pos, countWn_Bl[pos] + 1, countWn_Bl_DEFAULT_VALUE);
               }
               else
               {
                  SetStream(countWn_TT, pos, countWn_TT[pos] + 1, countWn_TT_DEFAULT_VALUE);
                  SetStream(countWn_Bl, pos, countWn_Bl[pos] + 1, countWn_Bl_DEFAULT_VALUE);
                  SetStream(countTP_TT, pos, countTP_TT[pos] + 1, countTP_TT_DEFAULT_VALUE);
                  SetStream(countTP_Bl, pos, countTP_Bl[pos] + 1, countTP_Bl_DEFAULT_VALUE);
               }
            }
            else
            {
               if ((close[pos] > Tbreak::Getstp(bxTopBreak)))
               {
                  SetStream(countLs_TT, pos, countLs_TT[pos] + 1, countLs_TT_DEFAULT_VALUE);
                  SetStream(countLs_Bl, pos, countLs_Bl[pos] + 1, countLs_Bl_DEFAULT_VALUE);
               }
               else
               {
                  SetStream(countLs_TT, pos, countLs_TT[pos] + 1, countLs_TT_DEFAULT_VALUE);
                  SetStream(countLs_Bl, pos, countLs_Bl[pos] + 1, countLs_Bl_DEFAULT_VALUE);
                  SetStream(countSL_TT, pos, countSL_TT[pos] + 1, countSL_TT_DEFAULT_VALUE);
                  SetStream(countSL_Bl, pos, countSL_Bl[pos] + 1, countSL_Bl_DEFAULT_VALUE);
               }
            }
            Tbreak::Setact(bxTopBreak, false);
            Box* box__custom_s__Tbreakc5Value;
            if (!box__custom_s__Tbreakc5.GetValue(pos, oldPos, bxTopBreak, box__custom_s__Tbreakc5Value)) { box__custom_s__Tbreakc5Value = NULL; }
            box__custom_s__Tbreakc5Value;
         }
         else if (((n - Tbreak::Getidx(bxTopBreak) < x) && SafeLess(close[pos], top)))
         {
            falseBl = true;
            Label* lab_s_s_c_c6Value;
            if (!lab_s_s_c_c6.GetValue(pos, oldPos, lab_s_s_c_c6Value)) { lab_s_s_c_c6Value = NULL; }
            lab_s_s_c_c6Value;
            SetStream(count_F_BrOut_TT, pos, count_F_BrOut_TT[pos] + 1, count_F_BrOut_TT_DEFAULT_VALUE);
            SetStream(count_F_BrOut_Bl, pos, count_F_BrOut_Bl[pos] + 1, count_F_BrOut_Bl_DEFAULT_VALUE);
            int update__Tbreakc_b_i_f_f_b_f_b7Value;
            if (!update__Tbreakc_b_i_f_f_b_f_b7.GetValue(pos, oldPos, bxTopBreak, update__Tbreakc_b_i_f_f_b_f_b7Value)) { update__Tbreakc_b_i_f_f_b_f_b7Value = (-1); }
            update__Tbreakc_b_i_f_f_b_f_b7Value;
         }
         else if ((high[pos] > Tbreak::Gettp(bxTopBreak)) && !Tbreak::Getprof(bxTopBreak))
         {
            Tbreak::Setprof(bxTopBreak, true);
            prof_Bl = true;
            Box* box__custom_s__Tbreakc8Value;
            if (!box__custom_s__Tbreakc8.GetValue(pos, oldPos, bxTopBreak, box__custom_s__Tbreakc8Value)) { box__custom_s__Tbreakc8Value = NULL; }
            box__custom_s__Tbreakc8Value;
            SetStream(countWn_TT, pos, countWn_TT[pos] + 1, countWn_TT_DEFAULT_VALUE);
            SetStream(countWn_Bl, pos, countWn_Bl[pos] + 1, countWn_Bl_DEFAULT_VALUE);
            SetStream(countTP_TT, pos, countTP_TT[pos] + 1, countTP_TT_DEFAULT_VALUE);
            SetStream(countTP_Bl, pos, countTP_Bl[pos] + 1, countTP_Bl_DEFAULT_VALUE);
            int update__Tbreakc_b_i_f_f_b_f_b9Value;
            if (!update__Tbreakc_b_i_f_f_b_f_b9.GetValue(pos, oldPos, bxTopBreak, update__Tbreakc_b_i_f_f_b_f_b9Value)) { update__Tbreakc_b_i_f_f_b_f_b9Value = (-1); }
            update__Tbreakc_b_i_f_f_b_f_b9Value;
         }
         else if ((close[pos] < Tbreak::Getstp(bxTopBreak)) && !Tbreak::Getfail(bxTopBreak))
         {
            Tbreak::Setfail(bxTopBreak, true);
            fail_Bl = true;
            Box* box__custom_s__Tbreakc10Value;
            if (!box__custom_s__Tbreakc10.GetValue(pos, oldPos, bxTopBreak, box__custom_s__Tbreakc10Value)) { box__custom_s__Tbreakc10Value = NULL; }
            box__custom_s__Tbreakc10Value;
            SetStream(countLs_TT, pos, countLs_TT[pos] + 1, countLs_TT_DEFAULT_VALUE);
            SetStream(countLs_Bl, pos, countLs_Bl[pos] + 1, countLs_Bl_DEFAULT_VALUE);
            SetStream(countSL_TT, pos, countSL_TT[pos] + 1, countSL_TT_DEFAULT_VALUE);
            SetStream(countSL_Bl, pos, countSL_Bl[pos] + 1, countSL_Bl_DEFAULT_VALUE);
            int update__Tbreakc_b_i_f_f_b_f_b11Value;
            if (!update__Tbreakc_b_i_f_f_b_f_b11.GetValue(pos, oldPos, bxTopBreak, update__Tbreakc_b_i_f_f_b_f_b11Value)) { update__Tbreakc_b_i_f_f_b_f_b11Value = (-1); }
            update__Tbreakc_b_i_f_f_b_f_b11Value;
         }
         Polyline* poly__Tbreakc12Value;
         if (!poly__Tbreakc12.GetValue(pos, oldPos, bxTopBreak, poly__Tbreakc12Value)) { poly__Tbreakc12Value = NULL; }
         poly__Tbreakc12Value;
      }
      else if (((Tbreak::Getfail(bxTopBreak) || Tbreak::Getprof(bxTopBreak))))
      {
         int update__Tbreakc_b_i_f_f_b_f_b13Value;
         if (!update__Tbreakc_b_i_f_f_b_f_b13.GetValue(pos, oldPos, bxTopBreak, update__Tbreakc_b_i_f_f_b_f_b13Value)) { update__Tbreakc_b_i_f_f_b_f_b13Value = (-1); }
         update__Tbreakc_b_i_f_f_b_f_b13Value;
      }
      if (breakBtm[pos])
      {
         brOutBr = true;
         SetStream(countBrOut_TT, pos, countBrOut_TT[pos] + 1, countBrOut_TT_DEFAULT_VALUE);
         SetStream(countBrOut_Br, pos, countBrOut_Br[pos] + 1, countBrOut_Br_DEFAULT_VALUE);
         Label* lab_s_s_c_c14Value;
         if (!lab_s_s_c_c14.GetValue(pos, oldPos, lab_s_s_c_c14Value)) { lab_s_s_c_c14Value = NULL; }
         lab_s_s_c_c14Value;
         double ls = ((iTP == "W% : L%") ? SafeMultiply(close[pos], (SafePlus(1, percL))) : ((loss == "ATR") ? SafePlus(close[pos], (SafeMultiply(atr, RcmAtrM))) : ((loss == "RCM") ? SafePlus(close[pos], (SafeMultiply(rcm, RcmAtrM))) : ph)));
         double pf = ((iTP == "W% : L%") ? SafeMultiply(close[pos], (SafeMinus(1, percW))) : ((loss == "ATR") ? SafeMinus(close[pos], (SafeMultiply((SafeMultiply(atr, RcmAtrM)), (SafeDivide(w, l))))) : ((loss == "RCM") ? SafeMinus(close[pos], (SafeMultiply((SafeMultiply(rcm, RcmAtrM)), (SafeDivide(w, l))))) : SafeMinus(close[pos], SafeMultiply((SafeMinus(ph, close[pos])), (SafeDivide(w, l)))))));
         int update__Tbreakc_b_ic_fc_fc_b_fc_b15Value;
         if (!update__Tbreakc_b_ic_fc_fc_b_fc_b15.GetValue(pos, oldPos, bxBtmBreak, n, close[pos], ls, pf, update__Tbreakc_b_ic_fc_fc_b_fc_b15Value)) { update__Tbreakc_b_ic_fc_fc_b_fc_b15Value = (-1); }
         update__Tbreakc_b_ic_fc_fc_b_fc_b15Value;
         Polyline* poly__Tbreakc16Value;
         if (!poly__Tbreakc16.GetValue(pos, oldPos, bxBtmBreak, poly__Tbreakc16Value)) { poly__Tbreakc16Value = NULL; }
         poly__Tbreakc16Value;
      }
      else if (Tbreak::Getact(bxBtmBreak))
      {
         if ((breakTop[pos] || (stopAtEndHTF && tfCh)))
         {
            if ((close[pos] <= Tbreak::Getprc(bxBtmBreak)))
            {
               if ((close[pos] > Tbreak::Gettp(bxBtmBreak)))
               {
                  SetStream(countWn_TT, pos, countWn_TT[pos] + 1, countWn_TT_DEFAULT_VALUE);
                  SetStream(countWn_Br, pos, countWn_Br[pos] + 1, countWn_Br_DEFAULT_VALUE);
               }
               else
               {
                  SetStream(countWn_TT, pos, countWn_TT[pos] + 1, countWn_TT_DEFAULT_VALUE);
                  SetStream(countWn_Br, pos, countWn_Br[pos] + 1, countWn_Br_DEFAULT_VALUE);
                  SetStream(countTP_TT, pos, countTP_TT[pos] + 1, countTP_TT_DEFAULT_VALUE);
                  SetStream(countTP_Br, pos, countTP_Br[pos] + 1, countTP_Br_DEFAULT_VALUE);
               }
            }
            else
            {
               if ((close[pos] < Tbreak::Getstp(bxBtmBreak)))
               {
                  SetStream(countLs_TT, pos, countLs_TT[pos] + 1, countLs_TT_DEFAULT_VALUE);
                  SetStream(countLs_Br, pos, countLs_Br[pos] + 1, countLs_Br_DEFAULT_VALUE);
               }
               else
               {
                  SetStream(countLs_TT, pos, countLs_TT[pos] + 1, countLs_TT_DEFAULT_VALUE);
                  SetStream(countLs_Br, pos, countLs_Br[pos] + 1, countLs_Br_DEFAULT_VALUE);
                  SetStream(countSL_TT, pos, countSL_TT[pos] + 1, countSL_TT_DEFAULT_VALUE);
                  SetStream(countSL_Br, pos, countSL_Br[pos] + 1, countSL_Br_DEFAULT_VALUE);
               }
            }
            Tbreak::Setact(bxBtmBreak, false);
            Box* box__custom_s__Tbreakc17Value;
            if (!box__custom_s__Tbreakc17.GetValue(pos, oldPos, bxBtmBreak, box__custom_s__Tbreakc17Value)) { box__custom_s__Tbreakc17Value = NULL; }
            box__custom_s__Tbreakc17Value;
         }
         else if (((n - Tbreak::Getidx(bxBtmBreak) < x) && SafeGreater(close[pos], btm)))
         {
            falseBr = true;
            Label* lab_s_s_c_c18Value;
            if (!lab_s_s_c_c18.GetValue(pos, oldPos, lab_s_s_c_c18Value)) { lab_s_s_c_c18Value = NULL; }
            lab_s_s_c_c18Value;
            SetStream(count_F_BrOut_TT, pos, count_F_BrOut_TT[pos] + 1, count_F_BrOut_TT_DEFAULT_VALUE);
            SetStream(count_F_BrOut_Br, pos, count_F_BrOut_Br[pos] + 1, count_F_BrOut_Br_DEFAULT_VALUE);
            int update__Tbreakc_b_i_f_f_b_f_b19Value;
            if (!update__Tbreakc_b_i_f_f_b_f_b19.GetValue(pos, oldPos, bxBtmBreak, update__Tbreakc_b_i_f_f_b_f_b19Value)) { update__Tbreakc_b_i_f_f_b_f_b19Value = (-1); }
            update__Tbreakc_b_i_f_f_b_f_b19Value;
         }
         else if ((low[pos] < Tbreak::Gettp(bxBtmBreak)) && !Tbreak::Getprof(bxBtmBreak))
         {
            Tbreak::Setprof(bxBtmBreak, true);
            prof_Br = true;
            Box* box__custom_s__Tbreakc20Value;
            if (!box__custom_s__Tbreakc20.GetValue(pos, oldPos, bxBtmBreak, box__custom_s__Tbreakc20Value)) { box__custom_s__Tbreakc20Value = NULL; }
            box__custom_s__Tbreakc20Value;
            SetStream(countWn_TT, pos, countWn_TT[pos] + 1, countWn_TT_DEFAULT_VALUE);
            SetStream(countWn_Br, pos, countWn_Br[pos] + 1, countWn_Br_DEFAULT_VALUE);
            SetStream(countTP_TT, pos, countTP_TT[pos] + 1, countTP_TT_DEFAULT_VALUE);
            SetStream(countTP_Br, pos, countTP_Br[pos] + 1, countTP_Br_DEFAULT_VALUE);
            int update__Tbreakc_b_i_f_f_b_f_b21Value;
            if (!update__Tbreakc_b_i_f_f_b_f_b21.GetValue(pos, oldPos, bxBtmBreak, update__Tbreakc_b_i_f_f_b_f_b21Value)) { update__Tbreakc_b_i_f_f_b_f_b21Value = (-1); }
            update__Tbreakc_b_i_f_f_b_f_b21Value;
         }
         else if ((close[pos] > Tbreak::Getstp(bxBtmBreak)) && !Tbreak::Getfail(bxBtmBreak))
         {
            Tbreak::Setfail(bxBtmBreak, true);
            fail_Br = true;
            Box* box__custom_s__Tbreakc22Value;
            if (!box__custom_s__Tbreakc22.GetValue(pos, oldPos, bxBtmBreak, box__custom_s__Tbreakc22Value)) { box__custom_s__Tbreakc22Value = NULL; }
            box__custom_s__Tbreakc22Value;
            SetStream(countLs_TT, pos, countLs_TT[pos] + 1, countLs_TT_DEFAULT_VALUE);
            SetStream(countLs_Br, pos, countLs_Br[pos] + 1, countLs_Br_DEFAULT_VALUE);
            SetStream(countSL_TT, pos, countSL_TT[pos] + 1, countSL_TT_DEFAULT_VALUE);
            SetStream(countSL_Br, pos, countSL_Br[pos] + 1, countSL_Br_DEFAULT_VALUE);
            int update__Tbreakc_b_i_f_f_b_f_b23Value;
            if (!update__Tbreakc_b_i_f_f_b_f_b23.GetValue(pos, oldPos, bxBtmBreak, update__Tbreakc_b_i_f_f_b_f_b23Value)) { update__Tbreakc_b_i_f_f_b_f_b23Value = (-1); }
            update__Tbreakc_b_i_f_f_b_f_b23Value;
         }
         Polyline* poly__Tbreakc24Value;
         if (!poly__Tbreakc24.GetValue(pos, oldPos, bxBtmBreak, poly__Tbreakc24Value)) { poly__Tbreakc24Value = NULL; }
         poly__Tbreakc24Value;
      }
      else if (((Tbreak::Getfail(bxBtmBreak) || Tbreak::Getprof(bxBtmBreak))))
      {
         int update__Tbreakc_b_i_f_f_b_f_b25Value;
         if (!update__Tbreakc_b_i_f_f_b_f_b25.GetValue(pos, oldPos, bxBtmBreak, update__Tbreakc_b_i_f_f_b_f_b25Value)) { update__Tbreakc_b_i_f_f_b_f_b25Value = (-1); }
         update__Tbreakc_b_i_f_f_b_f_b25Value;
      }
      if (pos - 1 < 0) { continue; }
      if (breakTop[pos - 1])
      {
         int update__Tbreakc_b_i_f_f_b_f_b26Value;
         if (!update__Tbreakc_b_i_f_f_b_f_b26.GetValue(pos, oldPos, bxBtmBreak, update__Tbreakc_b_i_f_f_b_f_b26Value)) { update__Tbreakc_b_i_f_f_b_f_b26Value = (-1); }
         update__Tbreakc_b_i_f_f_b_f_b26Value;
      }
      if (pos - 1 < 0) { continue; }
      if (breakBtm[pos - 1])
      {
         int update__Tbreakc_b_i_f_f_b_f_b27Value;
         if (!update__Tbreakc_b_i_f_f_b_f_b27.GetValue(pos, oldPos, bxTopBreak, update__Tbreakc_b_i_f_f_b_f_b27Value)) { update__Tbreakc_b_i_f_f_b_f_b27Value = (-1); }
         update__Tbreakc_b_i_f_f_b_f_b27Value;
      }
      uint plot1_color = AddTransparency(cTP, 50);
      if (plot1_color != INT_MAX) { plot1[pos] = Tbreak::Getprc(bxTopBreak); }
      else { plot1[pos] = EMPTY_VALUE; }
      double t1 = plot1[pos];
      uint plot2_color = AddTransparency(cTP, 50);
      if (plot2_color != INT_MAX) { plot2[pos] = Tbreak::Getstp(bxTopBreak); }
      else { plot2[pos] = EMPTY_VALUE; }
      double t2 = plot2[pos];
      uint plot3_color = AddTransparency(cSL, 50);
      if (plot3_color != INT_MAX) { plot3[pos] = Tbreak::Getprc(bxBtmBreak); }
      else { plot3[pos] = EMPTY_VALUE; }
      double b1 = plot3[pos];
      uint plot4_color = AddTransparency(cSL, 50);
      if (plot4_color != INT_MAX) { plot4[pos] = Tbreak::Getstp(bxBtmBreak); }
      else { plot4[pos] = EMPTY_VALUE; }
      double b2 = plot4[pos];
      if (showDash)
      {
         if (isFirst1.IsFirst())
         {
            Table::CellText(tb, 0, 0, "");
            Table::CellTextColor(tb, 0, 0, White);
            Table::CellTextSize(tb, 0, 0, table_size);
            Table::CellTextHAlign(tb, 0, 0, "center");
            Table::CellText(tb, 0, 1, "");
            Table::CellTextColor(tb, 0, 1, White);
            Table::CellTextSize(tb, 0, 1, table_size);
            Table::CellTextHAlign(tb, 0, 1, "center");
            Table::CellText(tb, 1, 1, "Breakouts");
            Table::CellTextColor(tb, 1, 1, White);
            Table::CellTextSize(tb, 1, 1, table_size);
            Table::CellTextHAlign(tb, 1, 1, "center");
            Table::CellText(tb, 2, 1, "Wins");
            Table::CellTextColor(tb, 2, 1, White);
            Table::CellTextSize(tb, 2, 1, table_size);
            Table::CellTextHAlign(tb, 2, 1, "center");
            Table::CellText(tb, 3, 1, "-> TP hit");
            Table::CellTextColor(tb, 3, 1, White);
            Table::CellTextSize(tb, 3, 1, table_size);
            Table::CellTextHAlign(tb, 3, 1, "center");
            Table::CellText(tb, 4, 1, "Losses");
            Table::CellTextColor(tb, 4, 1, White);
            Table::CellTextSize(tb, 4, 1, table_size);
            Table::CellTextHAlign(tb, 4, 1, "center");
            Table::CellText(tb, 5, 1, "-> SL hit");
            Table::CellTextColor(tb, 5, 1, White);
            Table::CellTextSize(tb, 5, 1, table_size);
            Table::CellTextHAlign(tb, 5, 1, "center");
            if (falseOutBreak)
            {
               Table::CellText(tb, 6, 1, "False\nBreakouts");
               Table::CellTextColor(tb, 6, 1, White);
               Table::CellTextSize(tb, 6, 1, table_size);
               Table::CellTextHAlign(tb, 6, 1, "center");
            }
            Table::CellText(tb, 0, 2, "Bullish");
            Table::CellTextColor(tb, 0, 2, White);
            Table::CellTextSize(tb, 0, 2, table_size);
            Table::CellTextHAlign(tb, 0, 2, "center");
            Table::CellText(tb, 0, 3, "Bearish");
            Table::CellTextColor(tb, 0, 3, White);
            Table::CellTextSize(tb, 0, 3, table_size);
            Table::CellTextHAlign(tb, 0, 3, "center");
            Table::CellText(tb, 0, 4, "Total");
            Table::CellTextColor(tb, 0, 4, White);
            Table::CellTextSize(tb, 0, 4, table_size);
            Table::CellTextHAlign(tb, 0, 4, "center");
            Table::MergeCells(tb, 0, 0, (falseOutBreak ? 6 : 5), 0);
         }
         if ((pos == rates_total - 1))
         {
            string formatRes_sc28Value;
            if (!formatRes_sc28.GetValue(pos, oldPos, fres, formatRes_sc28Value)) { formatRes_sc28Value = NULL; }
            Table::CellText(tb, 0, 0, strFormat1.Add(formatRes_sc28Value).Format());
            Table::CellTextColor(tb, 0, 0, White);
            Table::CellTextSize(tb, 0, 0, table_size);
            Table::CellTextHAlign(tb, 0, 0, "center");
            Table::CellText(tb, 1, 2, Str::ToString(countBrOut_Bl[pos]));
            Table::CellTextColor(tb, 1, 2, White);
            Table::CellTextSize(tb, 1, 2, table_size);
            Table::CellTextHAlign(tb, 1, 2, "center");
            Table::CellText(tb, 1, 3, Str::ToString(countBrOut_Br[pos]));
            Table::CellTextColor(tb, 1, 3, White);
            Table::CellTextSize(tb, 1, 3, table_size);
            Table::CellTextHAlign(tb, 1, 3, "center");
            Table::CellText(tb, 1, 4, Str::ToString(countBrOut_TT[pos]));
            Table::CellTextColor(tb, 1, 4, White);
            Table::CellTextSize(tb, 1, 4, table_size);
            Table::CellTextHAlign(tb, 1, 4, "center");
            Table::CellText(tb, 2, 2, Str::ToString(countWn_Bl[pos]));
            Table::CellTextColor(tb, 2, 2, White);
            Table::CellTextSize(tb, 2, 2, table_size);
            Table::CellTextHAlign(tb, 2, 2, "center");
            Table::CellText(tb, 2, 3, Str::ToString(countWn_Br[pos]));
            Table::CellTextColor(tb, 2, 3, White);
            Table::CellTextSize(tb, 2, 3, table_size);
            Table::CellTextHAlign(tb, 2, 3, "center");
            Table::CellText(tb, 2, 4, Str::ToString(countWn_TT[pos]));
            Table::CellTextColor(tb, 2, 4, White);
            Table::CellTextSize(tb, 2, 4, table_size);
            Table::CellTextHAlign(tb, 2, 4, "center");
            Table::CellText(tb, 3, 2, Str::ToString(countTP_Bl[pos]));
            Table::CellTextColor(tb, 3, 2, White);
            Table::CellTextSize(tb, 3, 2, table_size);
            Table::CellTextHAlign(tb, 3, 2, "center");
            Table::CellText(tb, 3, 3, Str::ToString(countTP_Br[pos]));
            Table::CellTextColor(tb, 3, 3, White);
            Table::CellTextSize(tb, 3, 3, table_size);
            Table::CellTextHAlign(tb, 3, 3, "center");
            Table::CellText(tb, 3, 4, Str::ToString(countTP_TT[pos]));
            Table::CellTextColor(tb, 3, 4, White);
            Table::CellTextSize(tb, 3, 4, table_size);
            Table::CellTextHAlign(tb, 3, 4, "center");
            Table::CellText(tb, 4, 2, Str::ToString(countLs_Bl[pos]));
            Table::CellTextColor(tb, 4, 2, White);
            Table::CellTextSize(tb, 4, 2, table_size);
            Table::CellTextHAlign(tb, 4, 2, "center");
            Table::CellText(tb, 4, 3, Str::ToString(countLs_Br[pos]));
            Table::CellTextColor(tb, 4, 3, White);
            Table::CellTextSize(tb, 4, 3, table_size);
            Table::CellTextHAlign(tb, 4, 3, "center");
            Table::CellText(tb, 4, 4, Str::ToString(countLs_TT[pos]));
            Table::CellTextColor(tb, 4, 4, White);
            Table::CellTextSize(tb, 4, 4, table_size);
            Table::CellTextHAlign(tb, 4, 4, "center");
            Table::CellText(tb, 5, 2, Str::ToString(countSL_Bl[pos]));
            Table::CellTextColor(tb, 5, 2, White);
            Table::CellTextSize(tb, 5, 2, table_size);
            Table::CellTextHAlign(tb, 5, 2, "center");
            Table::CellText(tb, 5, 3, Str::ToString(countSL_Br[pos]));
            Table::CellTextColor(tb, 5, 3, White);
            Table::CellTextSize(tb, 5, 3, table_size);
            Table::CellTextHAlign(tb, 5, 3, "center");
            Table::CellText(tb, 5, 4, Str::ToString(countSL_TT[pos]));
            Table::CellTextColor(tb, 5, 4, White);
            Table::CellTextSize(tb, 5, 4, table_size);
            Table::CellTextHAlign(tb, 5, 4, "center");
            if (falseOutBreak)
            {
               Table::CellText(tb, 6, 2, Str::ToString(count_F_BrOut_Bl[pos]));
               Table::CellTextColor(tb, 6, 2, White);
               Table::CellTextSize(tb, 6, 2, table_size);
               Table::CellTextHAlign(tb, 6, 2, "center");
               Table::CellText(tb, 6, 3, Str::ToString(count_F_BrOut_Br[pos]));
               Table::CellTextColor(tb, 6, 3, White);
               Table::CellTextSize(tb, 6, 3, table_size);
               Table::CellTextHAlign(tb, 6, 3, "center");
               Table::CellText(tb, 6, 4, Str::ToString(count_F_BrOut_TT[pos]));
               Table::CellTextColor(tb, 6, 4, White);
               Table::CellTextSize(tb, 6, 4, table_size);
               Table::CellTextHAlign(tb, 6, 4, "center");
            }
         }
      }
      if (brOutBl) { _signaler.SendNotifications("       Bullish Breakout", "Bullish Breakout"); }
      if (falseBl) { _signaler.SendNotifications("      Bullish False Breakout", "Bullish False Breakout"); }
      if (prof_Bl) { _signaler.SendNotifications("     Bullish TP", "Bullish TP"); }
      if (fail_Bl) { _signaler.SendNotifications("    Bullish Fail", "Bullish Fail"); }
      if (brOutBr) { _signaler.SendNotifications("   Bearish Breakout", "Bearish Breakout"); }
      if (falseBr) { _signaler.SendNotifications("  Bearish False Breakout", "Bearish False Breakout"); }
      if (prof_Br) { _signaler.SendNotifications(" Bearish TP", "Bearish TP"); }
      if (fail_Br) { _signaler.SendNotifications("Bearish Fail", "Bearish Fail"); }
   }
   LinesCollection::Redraw();
   LabelsCollection::Redraw();
   PolyLinesCollection::Redraw();
   BoxesCollection::Redraw();
   TableManager::Redraw();
   return rates_total;
}

//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76287&sid=9a32304108d7353936a0d115fd152021

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+