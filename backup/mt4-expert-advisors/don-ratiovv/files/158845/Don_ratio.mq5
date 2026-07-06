//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75782 

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
#property indicator_buffers 35
#property indicator_plots 16
#property indicator_label1 "high channel"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "low channel"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "buy alert"
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "sell alert"
#property indicator_type4 DRAW_ARROW
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Take Profit Long"
#property indicator_type5 DRAW_ARROW
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Take Profit Short"
#property indicator_type6 DRAW_ARROW
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_type7 DRAW_ARROW
#property indicator_color7 White
#property indicator_style7 STYLE_SOLID
#property indicator_width7 3
#property indicator_type8 DRAW_ARROW
#property indicator_color8 White
#property indicator_style8 STYLE_SOLID
#property indicator_width8 3
#property indicator_label9 "Stop Loss Long"
#property indicator_type9 DRAW_ARROW
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Stop Loss Short"
#property indicator_type10 DRAW_ARROW
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_type11 DRAW_ARROW
#property indicator_color11 White
#property indicator_style11 STYLE_SOLID
#property indicator_width11 3
#property indicator_type12 DRAW_ARROW
#property indicator_color12 White
#property indicator_style12 STYLE_SOLID
#property indicator_width12 3
#property indicator_label13 "Buy again"
#property indicator_type13 DRAW_ARROW
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_label14 "Sell again"
#property indicator_type14 DRAW_ARROW
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_label15 "Take Profit Long1"
#property indicator_type15 DRAW_ARROW
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_label16 "Take Profit Short1"
#property indicator_type16 DRAW_ARROW
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1

// PineScript timeframe.* functions
// v1.0

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
   
   static ENUM_TIMEFRAMES GetTimeframe(string resolution)
   {
      if (resolution == "1") { return PERIOD_M1; }
      if (resolution == "5") { return PERIOD_M5; }
      if (resolution == "15") { return PERIOD_M15; }
      if (resolution == "30") { return PERIOD_M30; }
      if (resolution == "60") { return PERIOD_H1; }
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
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL
// IStream v.2.0
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

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
// Float stream v2.0

class FloatStream : public AFloatStream
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
         if (val[i] == EMPTY_VALUE)
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
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif


//AOnStream v2.0
class AStreamBase : public IStream
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

//AOnStream v2.0
class AOnStream : public AStreamBase
{
protected:
   IStream *_source;
public:
   AOnStream(IStream *source)
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


// Highest high stream v1.6

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
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      double values[];
      ArrayResize(values, loopback);
      if (!source.GetValues(period, loopback, values))
      {
         return false;
      }
      val = values[0];

      for (int i = 1; i < loopback; ++i)
      {
         val = MathMax(val, values[i]);
      }
      return true;
   }
   
   static bool GetValues(const int period, int count, double &val[], IStream* source, int loopback)
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period - i, v, source, loopback))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int oldPos = Size() - period - 1;
      return HighestHighStream::GetValue(oldPos, val, _source, _loopback);
   }
};




// Lowest low stream v1.6

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _loopback = loopback;
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      double values[];
      ArrayResize(values, loopback);
      if (!source.GetValues(period, loopback, values))
      {
         return false;
      }
      val = values[0];

      for (int i = 1; i < loopback; ++i)
      {
         val = MathMin(val, values[i]);
      }
      return true;
   }
   
   static bool GetValues(const int period, int count, double &val[], IStream* source, int loopback)
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period - i, v, source, loopback))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int oldPos = Size() - period - 1;
      return LowestLowStream::GetValue(oldPos, val, _source, _loopback);
   }
};
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
#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL
// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
// Boolean Stream v.1.1

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, bool &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, bool &val[]) = 0;
   virtual bool GetValues(const int period, const int count, int &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
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
// ICondition v3.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};
#endif

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
   virtual bool GetValues(const int period, const int count, bool &val[])
   {
      if (Size() <= period || period - count + 1 < 0)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = _condition.IsPass(period - i, 0);
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, bool &val[])
   {
      int pos = Size() - period - 1;
      return GetValues(pos, count, val);
   }
   virtual bool GetValues(const int period, const int count, int &val[])
   {
      bool values[];
      ArrayResize(values, count);
      if (!GetValues(period, count, values))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = values[i];
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      int pos = Size() - period - 1;
      return GetValues(pos, count, val);
   }
};
#endif


// Condition base v2.1

#ifndef ACondition_IMP
#define ACondition_IMP

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
// Symbol info v1.3

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digit;
   double _ticksize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      _digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _ticksize = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), _digit);
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

   static double GetPipSize(const string symbol)
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      double mult = digit == 3 || digit == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPointSize() { return _point; }
   double GetPipSize() { return _pipSize; }
   int GetDigits() { return _digit; }
   string GetSymbol() { return _symbol; }
   static double GetBid(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_BID); }
   static double GetAsk(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
   double GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
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

// Base condition v1.1

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

class ACondition : public AConditionBase
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo* _instrument;
   string _symbol;
public:
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe, string name = NULL)
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

// IBarStream v1.0



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

   virtual int Size() = 0;

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
   FirstCrossUnderSecond
};

#endif

// Stream-stream condition v2.0

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
      double value1[2];
      if (!_stream1.GetValues(period - _periodShift1, 2, value1))
      {
         return false;
      }
      double value2[2];
      if (!_stream2.GetValues(period - _periodShift2, 2, value2))
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return value1[0] > value2[0];
         case FirstBelowSecond:
            return value1[0] < value2[0];
         case FirstCrossOverSecond:
            return value1[0] >= value2[0] && value1[1] < value2[1];
         case FirstCrossUnderSecond:
            return value1[0] <= value2[0] && value1[1] > value2[1];
      }
      return value1[0] >= value2[0] && value1[1] < value2[1];
   }
};
#endif

// Or condition v1.0

// Returns true when at least one of the conditions returns true.

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
      {
         condition.AddRef();
      }
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

// v1.0
// Wraps IIntStream and provides IStream

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

   virtual bool GetValues(const int period, const int count, int &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
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
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int intVal[];
      ArrayResize(intVal, count);
      if (!_source.GetValues(period, count, intVal))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = intVal[i];
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
};
#endif

//CrossStreamV2 v1.0

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

#ifndef BoolStream_IMPL
#define BoolStream_IMPL


// Bool stream v2.1

class BoolStream : public ABoolStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, bool value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, bool &val[])
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
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, bool &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, int &val[])
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
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, int &val[])
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
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif
input int param1 = 450;
input bool param2 = false; // HIGH
input bool param3 = false; // LOW
input bool param4 = true; // Show Bullish/Bearish Zones
input bool param5 = true; // Take Profit Long
input bool param6 = true; // Take Profit Short
input int param7 = 2; // Take Profit %
input bool param8 = false; // Stop Loss Long
input bool param9 = false; // Stop Loss Short
input int param10 = 3; // Stop Loss %
input bool param11 = true; // Take Profit Long1
input bool param12 = true; // Take Profit Short1
input int param13 = 2; // Take Profit %
input bool param14 = false; // buy again
input bool param15 = false; // sell again
input int bars_limit = 10000; // Bars limit
Signaler* _signaler;
int tf;
FloatStream* highest1Source;
FloatStream* lowest1Source;
double _High[];
double _High_DEFAULT_VALUE;
double _Low[];
double _Low_DEFAULT_VALUE;
int HIGH;
int LOW;
double plot1[];
double plot2[];
int showZones;
double ruleState[];
double ruleState_DEFAULT_VALUE;
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
IBoolStream* crossunder1;
double sectionLongs[];
double sectionLongs_DEFAULT_VALUE;
double sectionShorts[];
double sectionShorts_DEFAULT_VALUE;
double last_open_longCondition[];
double last_open_longCondition_DEFAULT_VALUE;
double last_open_shortCondition[];
double last_open_shortCondition_DEFAULT_VALUE;
double last_longCondition[];
double last_longCondition_DEFAULT_VALUE;
double last_shortCondition[];
double last_shortCondition_DEFAULT_VALUE;
int isTPl;
int isTPs;
int tp;
FloatStream* crossover2X;
FloatStream* crossover2Y;
IBoolStream* crossover2;
FloatStream* crossunder2X;
FloatStream* crossunder2Y;
IBoolStream* crossunder2;
int isSLl;
int isSLs;
FloatStream* crossunder3X;
FloatStream* crossunder3Y;
IBoolStream* crossunder3;
FloatStream* crossover3X;
FloatStream* crossover3Y;
IBoolStream* crossover3;
double last_long_close[];
double last_long_close_DEFAULT_VALUE;
double last_short_close[];
double last_short_close_DEFAULT_VALUE;
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
double plot8[];
double plot9[];
double plot10[];
double plot11[];
double plot12[];
class bton_bSStream
{
   IBoolStream* b;
   bool _initialized;
public:
   bton_bSStream(IBoolStream* b)
   {
      _initialized = false;
      this.b = b;
      b.AddRef();
   }
   ~bton_bSStream()
   {
      b.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, int &__out1)
   {
      int bValue[1];
      if (!b.GetValues(pos, 1, bValue)) { bValue[0] = (-1); }
      __out1 = (bValue[0] ? 1 : 0);
      return true;
   }
};
BoolStream* bton_bS1_param1;
bton_bSStream* bton_bS1;
BoolStream* bton_bS2_param1;
bton_bSStream* bton_bS2;
BoolStream* bton_bS3_param1;
bton_bSStream* bton_bS3;
BoolStream* bton_bS4_param1;
bton_bSStream* bton_bS4;
BoolStream* bton_bS5_param1;
bton_bSStream* bton_bS5;
BoolStream* bton_bS6_param1;
bton_bSStream* bton_bS6;
FloatStream* crossover4X;
FloatStream* crossover4Y;
IBoolStream* crossover4;
FloatStream* crossunder4X;
FloatStream* crossunder4Y;
IBoolStream* crossunder4;
double sectionLongs1[];
double sectionLongs1_DEFAULT_VALUE;
double sectionShorts1[];
double sectionShorts1_DEFAULT_VALUE;
double last_open_longCondition1[];
double last_open_longCondition1_DEFAULT_VALUE;
double last_open_shortCondition1[];
double last_open_shortCondition1_DEFAULT_VALUE;
double last_longCondition1[];
double last_longCondition1_DEFAULT_VALUE;
double last_shortCondition1[];
double last_shortCondition1_DEFAULT_VALUE;
int isTPl1;
int isTPs1;
int tp1;
FloatStream* crossover5X;
FloatStream* crossover5Y;
IBoolStream* crossover5;
FloatStream* crossunder5X;
FloatStream* crossunder5Y;
IBoolStream* crossunder5;
double last_long_close1[];
double last_long_close1_DEFAULT_VALUE;
double last_short_close1[];
double last_short_close1_DEFAULT_VALUE;
int buy1;
int sell1;
double plot13[];
double plot14[];
double plot15[];
double plot16[];
class bton1_bSStream
{
   IBoolStream* b1;
   bool _initialized;
public:
   bton1_bSStream(IBoolStream* b1)
   {
      _initialized = false;
      this.b1 = b1;
      b1.AddRef();
   }
   ~bton1_bSStream()
   {
      b1.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, int &__out1)
   {
      int b1Value[1];
      if (!b1.GetValues(pos, 1, b1Value)) { b1Value[0] = (-1); }
      __out1 = (b1Value[0] ? 1 : 0);
      return true;
   }
};
BoolStream* bton1_bS7_param1;
bton1_bSStream* bton1_bS7;
BoolStream* bton1_bS8_param1;
bton1_bSStream* bton1_bS8;
BoolStream* bton1_bS9_param1;
bton1_bSStream* bton1_bS9;
BoolStream* bton1_bS10_param1;
bton1_bSStream* bton1_bS10;

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
   int id = 0;
   tf = param1;
   int lookBack = (Timeframe::IsIntraday() && (Timeframe::Interval() >= 1) ? SafeDivide(tf, Timeframe::Interval()) * 7 : (Timeframe::IsIntraday() && (Timeframe::Interval() < 60) ? SafeDivide(60, Timeframe::Interval()) * 24 * 7 : 7));
   highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   HIGH = param2;
   LOW = param3;
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, Black);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, Black);
   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 5);
   ++id;
   showZones = param4;
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   isTPl = param5;
   isTPs = param6;
   tp = param7;
   crossover2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = CrossStreamFactory::CreateCrossover(crossover2X, crossover2Y);
   crossunder2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2 = CrossStreamFactory::CreateCrossunder(crossunder2X, crossunder2Y);
   isSLl = param8;
   isSLs = param9;
   crossunder3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder3 = CrossStreamFactory::CreateCrossunder(crossunder3X, crossunder3Y);
   crossover3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3 = CrossStreamFactory::CreateCrossover(crossover3X, crossover3Y);
   SetIndexBuffer(id, plot3, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, Green);
   PlotIndexSetInteger(2, PLOT_ARROW, 217);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot4, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(3, PLOT_ARROW, 218);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot5, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(4, PLOT_ARROW, 218);
   PlotIndexSetInteger(4, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot6, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, Lime);
   PlotIndexSetInteger(5, PLOT_ARROW, 217);
   PlotIndexSetInteger(5, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot7, INDICATOR_DATA);
   PlotIndexSetInteger(6, PLOT_ARROW, 253);
   PlotIndexSetInteger(6, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot8, INDICATOR_DATA);
   PlotIndexSetInteger(7, PLOT_ARROW, 253);
   PlotIndexSetInteger(7, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot9, INDICATOR_DATA);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(8, PLOT_ARROW, 218);
   PlotIndexSetInteger(8, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot10, INDICATOR_DATA);
   PlotIndexSetInteger(9, PLOT_LINE_COLOR, Lime);
   PlotIndexSetInteger(9, PLOT_ARROW, 217);
   PlotIndexSetInteger(9, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot11, INDICATOR_DATA);
   PlotIndexSetInteger(10, PLOT_ARROW, 253);
   PlotIndexSetInteger(10, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot12, INDICATOR_DATA);
   PlotIndexSetInteger(11, PLOT_ARROW, 253);
   PlotIndexSetInteger(11, PLOT_ARROW_SHIFT, 5);
   ++id;
   crossover4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover4Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover4 = CrossStreamFactory::CreateCrossover(crossover4X, crossover4Y);
   crossunder4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder4Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder4 = CrossStreamFactory::CreateCrossunder(crossunder4X, crossunder4Y);
   isTPl1 = param11;
   isTPs1 = param12;
   tp1 = param13;
   crossover5X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover5Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover5 = CrossStreamFactory::CreateCrossover(crossover5X, crossover5Y);
   crossunder5X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder5Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder5 = CrossStreamFactory::CreateCrossunder(crossunder5X, crossunder5Y);
   buy1 = param14;
   sell1 = param15;
   SetIndexBuffer(id, plot13, INDICATOR_DATA);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(12, PLOT_ARROW, 217);
   PlotIndexSetInteger(12, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot14, INDICATOR_DATA);
   PlotIndexSetInteger(13, PLOT_LINE_COLOR, Black);
   PlotIndexSetInteger(13, PLOT_ARROW, 218);
   PlotIndexSetInteger(13, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot15, INDICATOR_DATA);
   PlotIndexSetInteger(14, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(14, PLOT_ARROW, 218);
   PlotIndexSetInteger(14, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot16, INDICATOR_DATA);
   PlotIndexSetInteger(15, PLOT_LINE_COLOR, Lime);
   PlotIndexSetInteger(15, PLOT_ARROW, 217);
   PlotIndexSetInteger(15, PLOT_ARROW_SHIFT, 5);
   ++id;
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("Don ratio");
   IndicatorSetString(INDICATOR_SHORTNAME, "Don ratio");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, _High, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, _Low, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, ruleState, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, sectionLongs, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, sectionShorts, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_open_longCondition, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_open_shortCondition, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_longCondition, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_shortCondition, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_long_close, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_short_close, INDICATOR_CALCULATIONS);
   bton_bS1_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton_bS1 = new bton_bSStream(bton_bS1_param1);
   id = bton_bS1.Init(id);
   bton_bS2_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton_bS2 = new bton_bSStream(bton_bS2_param1);
   id = bton_bS2.Init(id);
   bton_bS3_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton_bS3 = new bton_bSStream(bton_bS3_param1);
   id = bton_bS3.Init(id);
   bton_bS4_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton_bS4 = new bton_bSStream(bton_bS4_param1);
   id = bton_bS4.Init(id);
   bton_bS5_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton_bS5 = new bton_bSStream(bton_bS5_param1);
   id = bton_bS5.Init(id);
   bton_bS6_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton_bS6 = new bton_bSStream(bton_bS6_param1);
   id = bton_bS6.Init(id);
   SetIndexBuffer(id++, sectionLongs1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, sectionShorts1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_open_longCondition1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_open_shortCondition1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_longCondition1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_shortCondition1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_long_close1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, last_short_close1, INDICATOR_CALCULATIONS);
   bton1_bS7_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton1_bS7 = new bton1_bSStream(bton1_bS7_param1);
   id = bton1_bS7.Init(id);
   bton1_bS8_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton1_bS8 = new bton1_bSStream(bton1_bS8_param1);
   id = bton1_bS8.Init(id);
   bton1_bS9_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton1_bS9 = new bton1_bSStream(bton1_bS9_param1);
   id = bton1_bS9.Init(id);
   bton1_bS10_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   bton1_bS10 = new bton1_bSStream(bton1_bS10_param1);
   id = bton1_bS10.Init(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   highest1Source.Release();
   lowest1Source.Release();
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   crossunder2X.Release();
   crossunder2Y.Release();
   crossunder2.Release();
   crossunder3X.Release();
   crossunder3Y.Release();
   crossunder3.Release();
   crossover3X.Release();
   crossover3Y.Release();
   crossover3.Release();
   bton_bS1_param1.Release();
   delete bton_bS1;
   bton_bS2_param1.Release();
   delete bton_bS2;
   bton_bS3_param1.Release();
   delete bton_bS3;
   bton_bS4_param1.Release();
   delete bton_bS4;
   bton_bS5_param1.Release();
   delete bton_bS5;
   bton_bS6_param1.Release();
   delete bton_bS6;
   crossover4X.Release();
   crossover4Y.Release();
   crossover4.Release();
   crossunder4X.Release();
   crossunder4Y.Release();
   crossunder4.Release();
   crossover5X.Release();
   crossover5Y.Release();
   crossover5.Release();
   crossunder5X.Release();
   crossunder5Y.Release();
   crossunder5.Release();
   bton1_bS7_param1.Release();
   delete bton1_bS7;
   bton1_bS8_param1.Release();
   delete bton1_bS8;
   bton1_bS9_param1.Release();
   delete bton1_bS9;
   bton1_bS10_param1.Release();
   delete bton1_bS10;
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
      highest1Source.Init();
      lowest1Source.Init();
      _High_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(_High, _High_DEFAULT_VALUE);
      _Low_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(_Low, _Low_DEFAULT_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ruleState_DEFAULT_VALUE = 0;
      ArrayInitialize(ruleState, ruleState_DEFAULT_VALUE);
      crossover1X.Init();
      crossover1Y.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      sectionLongs_DEFAULT_VALUE = 0;
      ArrayInitialize(sectionLongs, sectionLongs_DEFAULT_VALUE);
      sectionShorts_DEFAULT_VALUE = 0;
      ArrayInitialize(sectionShorts, sectionShorts_DEFAULT_VALUE);
      last_open_longCondition_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_open_longCondition, last_open_longCondition_DEFAULT_VALUE);
      last_open_shortCondition_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_open_shortCondition, last_open_shortCondition_DEFAULT_VALUE);
      last_longCondition_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_longCondition, last_longCondition_DEFAULT_VALUE);
      last_shortCondition_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_shortCondition, last_shortCondition_DEFAULT_VALUE);
      crossover2X.Init();
      crossover2Y.Init();
      crossunder2X.Init();
      crossunder2Y.Init();
      crossunder3X.Init();
      crossunder3Y.Init();
      crossover3X.Init();
      crossover3Y.Init();
      last_long_close_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_long_close, last_long_close_DEFAULT_VALUE);
      last_short_close_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_short_close, last_short_close_DEFAULT_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(plot11, EMPTY_VALUE);
      ArrayInitialize(plot12, EMPTY_VALUE);
      bton_bS1_param1.Init();
      bton_bS1.Clear();
      bton_bS2_param1.Init();
      bton_bS2.Clear();
      bton_bS3_param1.Init();
      bton_bS3.Clear();
      bton_bS4_param1.Init();
      bton_bS4.Clear();
      bton_bS5_param1.Init();
      bton_bS5.Clear();
      bton_bS6_param1.Init();
      bton_bS6.Clear();
      crossover4X.Init();
      crossover4Y.Init();
      crossunder4X.Init();
      crossunder4Y.Init();
      sectionLongs1_DEFAULT_VALUE = 0;
      ArrayInitialize(sectionLongs1, sectionLongs1_DEFAULT_VALUE);
      sectionShorts1_DEFAULT_VALUE = 0;
      ArrayInitialize(sectionShorts1, sectionShorts1_DEFAULT_VALUE);
      last_open_longCondition1_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_open_longCondition1, last_open_longCondition1_DEFAULT_VALUE);
      last_open_shortCondition1_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_open_shortCondition1, last_open_shortCondition1_DEFAULT_VALUE);
      last_longCondition1_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_longCondition1, last_longCondition1_DEFAULT_VALUE);
      last_shortCondition1_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_shortCondition1, last_shortCondition1_DEFAULT_VALUE);
      crossover5X.Init();
      crossover5Y.Init();
      crossunder5X.Init();
      crossunder5Y.Init();
      last_long_close1_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_long_close1, last_long_close1_DEFAULT_VALUE);
      last_short_close1_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(last_short_close1, last_short_close1_DEFAULT_VALUE);
      ArrayInitialize(plot13, EMPTY_VALUE);
      ArrayInitialize(plot14, EMPTY_VALUE);
      ArrayInitialize(plot15, EMPTY_VALUE);
      ArrayInitialize(plot16, EMPTY_VALUE);
      bton1_bS7_param1.Init();
      bton1_bS7.Clear();
      bton1_bS8_param1.Init();
      bton1_bS8.Clear();
      bton1_bS9_param1.Init();
      bton1_bS9.Clear();
      bton1_bS10_param1.Init();
      bton1_bS10.Clear();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      int lookBack = (Timeframe::IsIntraday() && (Timeframe::Interval() >= 1) ? SafeDivide(tf, Timeframe::Interval()) * 7 : (Timeframe::IsIntraday() && (Timeframe::Interval() < 60) ? SafeDivide(60, Timeframe::Interval()) * 24 * 7 : 7));
      highest1Source.SetValue(pos, high[pos]);
      double highest1Value[1];
      if (!HighestHighStream::GetValues(pos, 1, highest1Value, highest1Source, lookBack)) { highest1Value[0] = EMPTY_VALUE; }
      SetStream(_High, pos, highest1Value[0], _High_DEFAULT_VALUE);
      lowest1Source.SetValue(pos, low[pos]);
      double lowest1Value[1];
      if (!LowestLowStream::GetValues(pos, 1, lowest1Value, lowest1Source, lookBack)) { lowest1Value[0] = EMPTY_VALUE; }
      SetStream(_Low, pos, lowest1Value[0], _Low_DEFAULT_VALUE);
      double highRatio = SafeMultiply((SafeDivide((SafeMinus(close[pos], _Low[pos])), (SafeMinus(_High[pos], _Low[pos])))), 500);
      double lowRatio = InvertSign((SafeDivide((SafeMinus(_High[pos], close[pos])), (SafeMinus(_High[pos], _Low[pos]))))) * 500;
      if (pos - 1 < 0) { continue; }
      uint highColor = (SafeGreater(_High[pos], _High[pos - 1]) ? 0x006400 : 0x90EE90);
      if (pos - 1 < 0) { continue; }
      uint lowRatio1 = (SafeLess(_Low[pos], _Low[pos - 1]) ? 0x00008B : 0xAFAFED);
      if (pos - 1 < 0) { continue; }
      int h = SafeGreater(_High[pos], _High[pos - 1]);
      if (pos - 1 < 0) { continue; }
      int l = SafeLess(_Low[pos], _Low[pos - 1]);
      int plotshape1_condition = HIGH && h;
      if (plotshape1_condition == true) { plot1[pos] = high[pos]; }
      int plotshape2_condition = LOW && l;
      if (plotshape2_condition == true) { plot2[pos] = low[pos]; }
      double z = SafePlus(highRatio, lowRatio);
      int bullishRule = SafeGE(z, 100);
      int bearishRule = SafeLE(z, (-100));
      if (pos - 1 < 0) { continue; }
      SetStream(ruleState, pos, (bullishRule ? 1 : (bearishRule ? (-1) : Nz(ruleState[pos - 1]))), ruleState_DEFAULT_VALUE);
      int longCond = (-1);
      int shortCond = (-1);
      crossover1X.SetValue(pos, z);
      crossover1Y.SetValue(pos, 100);
      int crossover1Value[1];
      if (!crossover1.GetValues(pos, 1, crossover1Value)) { crossover1Value[0] = (-1); }
      longCond = crossover1Value[0];
      crossunder1X.SetValue(pos, z);
      crossunder1Y.SetValue(pos, (-100));
      int crossunder1Value[1];
      if (!crossunder1.GetValues(pos, 1, crossunder1Value)) { crossunder1Value[0] = (-1); }
      shortCond = crossunder1Value[0];
      if (pos - 1 < 0) { continue; }
      SetStream(sectionLongs, pos, Nz(sectionLongs[pos - 1]), sectionLongs_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(sectionShorts, pos, Nz(sectionShorts[pos - 1]), sectionShorts_DEFAULT_VALUE);
      if (longCond)
      {
         SetStream(sectionLongs, pos, sectionLongs[pos] + 1, sectionLongs_DEFAULT_VALUE);
         SetStream(sectionShorts, pos, 0, sectionShorts_DEFAULT_VALUE);
      }
      if (shortCond)
      {
         SetStream(sectionLongs, pos, 0, sectionLongs_DEFAULT_VALUE);
         SetStream(sectionShorts, pos, sectionShorts[pos] + 1, sectionShorts_DEFAULT_VALUE);
      }
      int pyrl = 1;
      int longCondition = longCond && (sectionLongs[pos] <= pyrl);
      int shortCondition = shortCond && (sectionShorts[pos] <= pyrl);
      if (pos - 1 < 0) { continue; }
      SetStream(last_open_longCondition, pos, (longCondition ? open[pos] : Nz(last_open_longCondition[pos - 1])), last_open_longCondition_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(last_open_shortCondition, pos, (shortCondition ? open[pos] : Nz(last_open_shortCondition[pos - 1])), last_open_shortCondition_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(last_longCondition, pos, (longCondition ? time[pos] : Nz(last_longCondition[pos - 1])), last_longCondition_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(last_shortCondition, pos, (shortCondition ? time[pos] : Nz(last_shortCondition[pos - 1])), last_shortCondition_DEFAULT_VALUE);
      int in_longCondition = SafeGreater(last_longCondition[pos], last_shortCondition[pos]);
      int in_shortCondition = SafeGreater(last_shortCondition[pos], last_longCondition[pos]);
      crossover2X.SetValue(pos, high[pos]);
      crossover2Y.SetValue(pos, SafeMultiply((1 + (SafeDivide(tp, 100))), last_open_longCondition[pos]));
      int crossover2Value[1];
      if (!crossover2.GetValues(pos, 1, crossover2Value)) { crossover2Value[0] = (-1); }
      int long_tp = isTPl && crossover2Value[0] && (longCondition == 0) && (in_longCondition == 1);
      crossunder2X.SetValue(pos, low[pos]);
      crossunder2Y.SetValue(pos, SafeMultiply((1 - (SafeDivide(tp, 100))), last_open_shortCondition[pos]));
      int crossunder2Value[1];
      if (!crossunder2.GetValues(pos, 1, crossunder2Value)) { crossunder2Value[0] = (-1); }
      int short_tp = isTPs && crossunder2Value[0] && (shortCondition == 0) && (in_shortCondition == 1);
      double sl = 0.0;
      sl = param10;
      crossunder3X.SetValue(pos, low[pos]);
      crossunder3Y.SetValue(pos, SafeMultiply((1 - (SafeDivide(sl, 100))), last_open_longCondition[pos]));
      int crossunder3Value[1];
      if (!crossunder3.GetValues(pos, 1, crossunder3Value)) { crossunder3Value[0] = (-1); }
      int long_sl = isSLl && crossunder3Value[0] && (longCondition == 0) && (in_longCondition == 1);
      crossover3X.SetValue(pos, high[pos]);
      crossover3Y.SetValue(pos, SafeMultiply((1 + (SafeDivide(sl, 100))), last_open_shortCondition[pos]));
      int crossover3Value[1];
      if (!crossover3.GetValues(pos, 1, crossover3Value)) { crossover3Value[0] = (-1); }
      int short_sl = isSLs && crossover3Value[0] && (shortCondition == 0) && (in_shortCondition == 1);
      int long_close = ((long_tp || long_sl) ? 1 : 0);
      int short_close = ((short_tp || short_sl) ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      SetStream(last_long_close, pos, (NumberToBool(long_close) ? time[pos] : Nz(last_long_close[pos - 1])), last_long_close_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(last_short_close, pos, (NumberToBool(short_close) ? time[pos] : Nz(last_short_close[pos - 1])), last_short_close_DEFAULT_VALUE);
      int plotshape3_condition = longCondition;
      if (plotshape3_condition == true) { plot3[pos] = low[pos]; }
      int plotshape4_condition = shortCondition;
      if (plotshape4_condition == true) { plot4[pos] = high[pos]; }
      if (pos - 1 < 0) { continue; }
      int plotshape5_condition = long_tp && SafeGreater(last_longCondition[pos], Nz(last_long_close[pos - 1]));
      if (plotshape5_condition == true) { plot5[pos] = high[pos]; }
      if (pos - 1 < 0) { continue; }
      int plotshape6_condition = short_tp && SafeGreater(last_shortCondition[pos], Nz(last_short_close[pos - 1]));
      if (plotshape6_condition == true) { plot6[pos] = low[pos]; }
      if (pos - 1 < 0) { continue; }
      double ltp = (long_tp && SafeGreater(last_longCondition[pos], Nz(last_long_close[pos - 1])) ? SafeMultiply((1 + (SafeDivide(tp, 100))), last_open_longCondition[pos]) : EMPTY_VALUE);
      plot7[pos] = ltp;
      if (pos - 1 < 0) { continue; }
      double stp = (short_tp && SafeGreater(last_shortCondition[pos], Nz(last_short_close[pos - 1])) ? SafeMultiply((1 - (SafeDivide(tp, 100))), last_open_shortCondition[pos]) : EMPTY_VALUE);
      plot8[pos] = stp;
      if (pos - 1 < 0) { continue; }
      int plotshape9_condition = long_sl && SafeGreater(last_longCondition[pos], Nz(last_long_close[pos - 1]));
      if (plotshape9_condition == true) { plot9[pos] = high[pos]; }
      if (pos - 1 < 0) { continue; }
      int plotshape10_condition = short_sl && SafeGreater(last_shortCondition[pos], Nz(last_short_close[pos - 1]));
      if (plotshape10_condition == true) { plot10[pos] = low[pos]; }
      if (pos - 1 < 0) { continue; }
      double lsl = (long_sl && SafeGreater(last_longCondition[pos], Nz(last_long_close[pos - 1])) ? SafeMultiply((1 - (SafeDivide(sl, 100))), last_open_longCondition[pos]) : EMPTY_VALUE);
      plot11[pos] = lsl;
      if (pos - 1 < 0) { continue; }
      double ssl = (short_sl && SafeGreater(last_shortCondition[pos], Nz(last_short_close[pos - 1])) ? SafeMultiply((1 + (SafeDivide(sl, 100))), last_open_shortCondition[pos]) : EMPTY_VALUE);
      plot12[pos] = ssl;
      bton_bS1_param1.SetValue(pos, longCondition);
      int bton_bS1Value;
      if (!bton_bS1.GetValue(pos, oldPos, bton_bS1Value)) { bton_bS1Value = INT_MIN; }
      if (bton_bS1Value) { _signaler.SendNotifications("Buy Alert", ""); }
      bton_bS2_param1.SetValue(pos, shortCondition);
      int bton_bS2Value;
      if (!bton_bS2.GetValue(pos, oldPos, bton_bS2Value)) { bton_bS2Value = INT_MIN; }
      if (bton_bS2Value) { _signaler.SendNotifications("Sell Alert", ""); }
      if (pos - 1 < 0) { continue; }
      bton_bS3_param1.SetValue(pos, long_tp && SafeGreater(last_longCondition[pos], Nz(last_long_close[pos - 1])));
      int bton_bS3Value;
      if (!bton_bS3.GetValue(pos, oldPos, bton_bS3Value)) { bton_bS3Value = INT_MIN; }
      if (bton_bS3Value) { _signaler.SendNotifications("Take Profit Long", ""); }
      if (pos - 1 < 0) { continue; }
      bton_bS4_param1.SetValue(pos, short_tp && SafeGreater(last_shortCondition[pos], Nz(last_short_close[pos - 1])));
      int bton_bS4Value;
      if (!bton_bS4.GetValue(pos, oldPos, bton_bS4Value)) { bton_bS4Value = INT_MIN; }
      if (bton_bS4Value) { _signaler.SendNotifications("Take Profit Short", ""); }
      if (pos - 1 < 0) { continue; }
      bton_bS5_param1.SetValue(pos, long_sl && SafeGreater(last_longCondition[pos], Nz(last_long_close[pos - 1])));
      int bton_bS5Value;
      if (!bton_bS5.GetValue(pos, oldPos, bton_bS5Value)) { bton_bS5Value = INT_MIN; }
      if (bton_bS5Value) { _signaler.SendNotifications("Stop Loss Long", ""); }
      if (pos - 1 < 0) { continue; }
      bton_bS6_param1.SetValue(pos, short_sl && SafeGreater(last_shortCondition[pos], Nz(last_short_close[pos - 1])));
      int bton_bS6Value;
      if (!bton_bS6.GetValue(pos, oldPos, bton_bS6Value)) { bton_bS6Value = INT_MIN; }
      if (bton_bS6Value) { _signaler.SendNotifications("Stop Loss Short", ""); }
      int longCond1 = (-1);
      int shortCond1 = (-1);
      crossover4X.SetValue(pos, high[pos]);
      crossover4Y.SetValue(pos, SafeMultiply((1 + (SafeDivide(tp, 100))), last_open_longCondition[pos]));
      int crossover4Value[1];
      if (!crossover4.GetValues(pos, 1, crossover4Value)) { crossover4Value[0] = (-1); }
      longCond1 = isTPl && crossover4Value[0] && (longCondition == 0) && (in_longCondition == 1);
      crossunder4X.SetValue(pos, low[pos]);
      crossunder4Y.SetValue(pos, SafeMultiply((1 - (SafeDivide(tp, 100))), last_open_shortCondition[pos]));
      int crossunder4Value[1];
      if (!crossunder4.GetValues(pos, 1, crossunder4Value)) { crossunder4Value[0] = (-1); }
      shortCond1 = isTPs && crossunder4Value[0] && (shortCondition == 0) && (in_shortCondition == 1);
      if (pos - 1 < 0) { continue; }
      SetStream(sectionLongs1, pos, Nz(sectionLongs1[pos - 1]), sectionLongs1_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(sectionShorts1, pos, Nz(sectionShorts1[pos - 1]), sectionShorts1_DEFAULT_VALUE);
      if (longCond1)
      {
         SetStream(sectionLongs1, pos, sectionLongs1[pos] + 1, sectionLongs1_DEFAULT_VALUE);
         SetStream(sectionShorts1, pos, 0, sectionShorts1_DEFAULT_VALUE);
      }
      if (shortCond1)
      {
         SetStream(sectionLongs1, pos, 0, sectionLongs1_DEFAULT_VALUE);
         SetStream(sectionShorts1, pos, sectionShorts1[pos] + 1, sectionShorts1_DEFAULT_VALUE);
      }
      int pyrl1 = 1;
      int longCondition1 = longCond1 && (sectionLongs1[pos] <= pyrl1);
      int shortCondition1 = shortCond1 && (sectionShorts1[pos] <= pyrl1);
      if (pos - 1 < 0) { continue; }
      SetStream(last_open_longCondition1, pos, (longCondition1 ? open[pos] : Nz(last_open_longCondition1[pos - 1])), last_open_longCondition1_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(last_open_shortCondition1, pos, (shortCondition1 ? open[pos] : Nz(last_open_shortCondition1[pos - 1])), last_open_shortCondition1_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(last_longCondition1, pos, (longCondition1 ? time[pos] : Nz(last_longCondition1[pos - 1])), last_longCondition1_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(last_shortCondition1, pos, (shortCondition1 ? time[pos] : Nz(last_shortCondition1[pos - 1])), last_shortCondition1_DEFAULT_VALUE);
      int in_longCondition1 = SafeGreater(last_longCondition1[pos], last_shortCondition1[pos]);
      int in_shortCondition1 = SafeGreater(last_shortCondition1[pos], last_longCondition1[pos]);
      crossover5X.SetValue(pos, high[pos]);
      crossover5Y.SetValue(pos, SafeMultiply((1 + (SafeDivide(tp, 100))), last_open_longCondition1[pos]));
      int crossover5Value[1];
      if (!crossover5.GetValues(pos, 1, crossover5Value)) { crossover5Value[0] = (-1); }
      int long_tp1 = isTPl1 && crossover5Value[0] && (longCondition1 == 0) && (in_longCondition1 == 1);
      crossunder5X.SetValue(pos, low[pos]);
      crossunder5Y.SetValue(pos, SafeMultiply((1 - (SafeDivide(tp, 100))), last_open_shortCondition1[pos]));
      int crossunder5Value[1];
      if (!crossunder5.GetValues(pos, 1, crossunder5Value)) { crossunder5Value[0] = (-1); }
      int short_tp1 = isTPs1 && crossunder5Value[0] && (shortCondition1 == 0) && (in_shortCondition1 == 1);
      int long_close1 = (long_tp1 ? 1 : 0);
      int short_close1 = (short_tp1 ? 1 : 0);
      if (pos - 1 < 0) { continue; }
      SetStream(last_long_close1, pos, (NumberToBool(long_close1) ? time[pos] : Nz(last_long_close1[pos - 1])), last_long_close1_DEFAULT_VALUE);
      if (pos - 1 < 0) { continue; }
      SetStream(last_short_close1, pos, (NumberToBool(short_close1) ? time[pos] : Nz(last_short_close1[pos - 1])), last_short_close1_DEFAULT_VALUE);
      int plotshape13_condition = buy1 && longCondition1;
      if (plotshape13_condition == true) { plot13[pos] = low[pos]; }
      int plotshape14_condition = sell1 && shortCondition1;
      if (plotshape14_condition == true) { plot14[pos] = high[pos]; }
      if (pos - 1 < 0) { continue; }
      int plotshape15_condition = long_tp1 && SafeGreater(last_longCondition1[pos], Nz(last_long_close1[pos - 1]));
      if (plotshape15_condition == true) { plot15[pos] = high[pos]; }
      if (pos - 1 < 0) { continue; }
      int plotshape16_condition = short_tp1 && SafeGreater(last_shortCondition1[pos], Nz(last_short_close1[pos - 1]));
      if (plotshape16_condition == true) { plot16[pos] = low[pos]; }
      bton1_bS7_param1.SetValue(pos, longCondition1);
      int bton1_bS7Value;
      if (!bton1_bS7.GetValue(pos, oldPos, bton1_bS7Value)) { bton1_bS7Value = INT_MIN; }
      if (bton1_bS7Value) { _signaler.SendNotifications("Buy Again", ""); }
      bton1_bS8_param1.SetValue(pos, shortCondition1);
      int bton1_bS8Value;
      if (!bton1_bS8.GetValue(pos, oldPos, bton1_bS8Value)) { bton1_bS8Value = INT_MIN; }
      if (bton1_bS8Value) { _signaler.SendNotifications("Sell Aagin", ""); }
      if (pos - 1 < 0) { continue; }
      bton1_bS9_param1.SetValue(pos, long_tp1 && SafeGreater(last_longCondition1[pos], Nz(last_long_close1[pos - 1])));
      int bton1_bS9Value;
      if (!bton1_bS9.GetValue(pos, oldPos, bton1_bS9Value)) { bton1_bS9Value = INT_MIN; }
      if (bton1_bS9Value) { _signaler.SendNotifications("Take Profit Long1", ""); }
      if (pos - 1 < 0) { continue; }
      bton1_bS10_param1.SetValue(pos, short_tp1 && SafeGreater(last_shortCondition1[pos], Nz(last_short_close1[pos - 1])));
      int bton1_bS10Value;
      if (!bton1_bS10.GetValue(pos, oldPos, bton1_bS10Value)) { bton1_bS10Value = INT_MIN; }
      if (bton1_bS10Value) { _signaler.SendNotifications("Take Profit Short1", ""); }
   }
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75782 

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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