//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75503

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
#property indicator_buffers 20
#property indicator_label1 "Range High"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Range Low"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Premium"
#property indicator_type3 DRAW_NONE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Premium"
#property indicator_type4 DRAW_NONE
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Discount"
#property indicator_type5 DRAW_NONE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Discount"
#property indicator_type6 DRAW_NONE
#property indicator_color6 Blue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Equilibrium"
#property indicator_type7 DRAW_NONE
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Equilibrium"
#property indicator_type8 DRAW_NONE
#property indicator_color8 Blue
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

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
// Pivot high stream v1.3



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


class PivotHighStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotHighStream(IStream *source, int leftBars, int rightBars)
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

   static bool GetValue(const int period, double &val, string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValue(period, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center;
      if (!source.GetValue(period + rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValue(period + i, value))
         {
            return false;
         }
         if (center < value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValue(period + ii + rightBars, value))
         {
            return false;
         }
         if (center < value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center;
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return GetValue(period, val, _source, _leftBars, _rightBars);
   }
};
// Pivot low stream v1.3



class PivotLowStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotLowStream(IStream *source, int leftBars, int rightBars)
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

   
   static bool GetValue(const int period, double &val, string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValue(period, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center;
      if (!source.GetValue(period + rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValue(period + i, value))
         {
            return false;
         }
         if (center > value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValue(period + ii + rightBars, value))
         {
            return false;
         }
         if (center > value)
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center;
      return true;
   }

   bool GetValue(const int period, double &val)
   {
      return GetValue(period, val, _source, _leftBars, _rightBars);
   }
};
// Collection of labels v1.2

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.5

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   color _color;
   color _textColor;
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
   static void SetXY(Label* label, int x, double y) { if (label == NULL) { return; } label.SetX(x); label.SetY(y); }

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
   
   Label* SetColor(color clr)
   {
      _color = clr;
      return &this;
   }
   
   Label* SetTextColor(color clr)
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
         delete _labels[i];
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
            Label* labelToDelete = _all.GetByIndex(i);
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
   }
   void DeleteLabel(Label* label)
   {
      RemoveLabel(label);
      delete label;
   }
   void Add(Label* label)
   {
      int index = FindIndex(label);
      
      int size = ArraySize(_labels);
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
LabelsCollection* LabelsCollection::_all;
int LabelsCollection::_maxLabels = 50;
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
// Collection of lines v1.2

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL

// Line object v1.3

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   color _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window, bool global)
   {
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

   Line* SetStyle(string style)
   {
      _style = style;
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

   Line* SetColor(color clr)
   {
      _clr = clr;
      return &this;
   }

   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }

   void Redraw()
   {
      int pos1 = iBars(_Symbol, _timeframe) - _x1 - 1;
      datetime x1 = iTime(_Symbol, _timeframe, pos1);
      int pos2 = iBars(_Symbol, _timeframe) - _x2 - 1;
      datetime x2 = iTime(_Symbol, _timeframe, pos2);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, x2);
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
            Line* lineToDelete = _all.GetByIndex(i);
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
      int index = FindIndex(line);
      
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




// Highest high stream v1.5

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




// Lowest low stream v1.5

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
input int param1 = 20; // Structure Period
input bool param2 = true; // Structure Response??
input int param3 = 7; // 
input bool param4 = true; // Bullish Structure?????
input color param5 = ColorRGB(8, 236, 126, 0); // 
input color param6 = ColorRGB(8, 236, 126, 0); // 
input bool param7 = true; // Bearish Structure????
input color param8 = ColorRGB(255, 34, 34, 0); // 
input color param9 = ColorRGB(255, 34, 34, 0); // 
input bool param10 = true; // Premium & Discount
input color param11 = AddTransparency(ColorRGB(255, 34, 34, 0), 80); // 
input color param12 = AddTransparency(ColorRGB(8, 236, 126, 0), 80); // 
input bool param13 = false; // Donchian Channel
input bool param14 = true; // Structure Candles
input int param15 = 40; // Structure Response
input int bars_limit = 100000; // Bars limit
int prd;
int s1;
int resp;
int bull;
uint bull2;
uint bull3;
int bear;
uint bear2;
uint bear3;
int showPD;
uint prem;
uint disc;
int don;
int Candle;
int length;
int b;
double Up[];
double Up_DEFAULT_VALUE;
double Dn[];
double Dn_DEFAULT_VALUE;
double iUp[];
double iUp_DEFAULT_VALUE;
double iDn[];
double iDn_DEFAULT_VALUE;
FloatStream* highestpivot1Source;
FloatStream* lowestpivot1Source;
double _pos[];
double _pos_DEFAULT_VALUE;
class CreateLabel_iS_fS_s_c_bStream
{
   IIntStream* x;
   IStream* y;
   string txt;
   uint col;
   int z;
   bool _initialized;
public:
   CreateLabel_iS_fS_s_c_bStream(IIntStream* x, IStream* y, string txt, uint col, int z)
   {
      _initialized = false;
      this.x = x;
      x.AddRef();
      this.y = y;
      y.AddRef();
      this.txt = txt;
      this.col = col;
      this.z = z;
   }
   ~CreateLabel_iS_fS_s_c_bStream()
   {
      x.Release();
      y.Release();
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
      int xValue;
      if (!x.GetValue(pos, xValue)) { xValue = INT_MIN; }
      double yValue;
      if (!y.GetValue(pos, yValue)) { yValue = EMPTY_VALUE; }
      __out1 = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", xValue, yValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor((uint)(INT_MIN)).SetText(txt).SetTextColor(col).SetStyle((z ? "down" : "up")).SetSize("normal").SetYLoc("price").SetTextAlign("center");
      return true;
   }
};
IntStream* CreateLabel_iS_fS_s_c_b1_param1;
FloatStream* CreateLabel_iS_fS_s_c_b1_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b1;
class CreateLine_iS_fS_fS_cStream
{
   IIntStream* x1;
   IStream* x2;
   IStream* y;
   uint col;
   bool _initialized;
public:
   CreateLine_iS_fS_fS_cStream(IIntStream* x1, IStream* x2, IStream* y, uint col)
   {
      _initialized = false;
      this.x1 = x1;
      x1.AddRef();
      this.x2 = x2;
      x2.AddRef();
      this.y = y;
      y.AddRef();
      this.col = col;
   }
   ~CreateLine_iS_fS_fS_cStream()
   {
      x1.Release();
      x2.Release();
      y.Release();
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
      int x1Value;
      if (!x1.GetValue(pos, x1Value)) { x1Value = INT_MIN; }
      double x2Value;
      if (!x2.GetValue(pos, x2Value)) { x2Value = EMPTY_VALUE; }
      double yValue;
      if (!y.GetValue(pos, yValue)) { yValue = EMPTY_VALUE; }
      __out1 = LinesCollection::Create(IndicatorObjPrefix + "line_1_id", x1Value, x2Value, b, yValue, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(col).SetWidth(1).SetStyle("solid");
      return true;
   }
};
IntStream* CreateLine_iS_fS_fS_c2_param1;
FloatStream* CreateLine_iS_fS_fS_c2_param2;
FloatStream* CreateLine_iS_fS_fS_c2_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c2;
IntStream* CreateLabel_iS_fS_s_c_b3_param1;
FloatStream* CreateLabel_iS_fS_s_c_b3_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b3;
IntStream* CreateLine_iS_fS_fS_c4_param1;
FloatStream* CreateLine_iS_fS_fS_c4_param2;
FloatStream* CreateLine_iS_fS_fS_c4_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c4;
IntStream* CreateLabel_iS_fS_s_c_b5_param1;
FloatStream* CreateLabel_iS_fS_s_c_b5_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b5;
IntStream* CreateLine_iS_fS_fS_c6_param1;
FloatStream* CreateLine_iS_fS_fS_c6_param2;
FloatStream* CreateLine_iS_fS_fS_c6_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c6;
IntStream* CreateLabel_iS_fS_s_c_b7_param1;
FloatStream* CreateLabel_iS_fS_s_c_b7_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b7;
IntStream* CreateLine_iS_fS_fS_c8_param1;
FloatStream* CreateLine_iS_fS_fS_c8_param2;
FloatStream* CreateLine_iS_fS_fS_c8_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c8;
IntStream* CreateLabel_iS_fS_s_c_b9_param1;
FloatStream* CreateLabel_iS_fS_s_c_b9_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b9;
IntStream* CreateLine_iS_fS_fS_c10_param1;
FloatStream* CreateLine_iS_fS_fS_c10_param2;
FloatStream* CreateLine_iS_fS_fS_c10_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c10;
IntStream* CreateLabel_iS_fS_s_c_b11_param1;
FloatStream* CreateLabel_iS_fS_s_c_b11_param2;
CreateLabel_iS_fS_s_c_bStream* CreateLabel_iS_fS_s_c_b11;
IntStream* CreateLine_iS_fS_fS_c12_param1;
FloatStream* CreateLine_iS_fS_fS_c12_param2;
FloatStream* CreateLine_iS_fS_fS_c12_param3;
CreateLine_iS_fS_fS_cStream* CreateLine_iS_fS_fS_c12;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
double plot8[];
class DonCandles_fS_fS_fS_fS_b_b_iStream
{
   IStream* high_;
   IStream* low_;
   IStream* close_;
   IStream* src_;
   int factor_;
   int candle_;
   int length_;
   FloatStream* highest1Source;
   FloatStream* lowest1Source;
   double initial[];
   double initial_DEFAULT_VALUE;
   bool _initialized;
public:
   DonCandles_fS_fS_fS_fS_b_b_iStream(IStream* high_, IStream* low_, IStream* close_, IStream* src_, int factor_, int candle_, int length_)
   {
      _initialized = false;
      this.high_ = high_;
      high_.AddRef();
      this.low_ = low_;
      low_.AddRef();
      this.close_ = close_;
      close_.AddRef();
      this.src_ = src_;
      src_.AddRef();
      this.factor_ = factor_;
      this.candle_ = candle_;
      this.length_ = length_;
      highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~DonCandles_fS_fS_fS_fS_b_b_iStream()
   {
      high_.Release();
      low_.Release();
      close_.Release();
      src_.Release();
      highest1Source.Release();
      lowest1Source.Release();
   }
   int Init(int id)
   {
      SetIndexBuffer(id++, initial);
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
         highest1Source.Init();
         lowest1Source.Init();
         initial_DEFAULT_VALUE = 0.0;
         ArrayInitialize(initial, initial_DEFAULT_VALUE);
         _initialized = true;
      }
      double high_Value;
      if (!high_.GetValue(pos, high_Value)) { high_Value = EMPTY_VALUE; }
      highest1Source.SetValue(pos, high_Value);
      double highest1Value;
      if (!HighestHighStream::GetValue(pos, highest1Value, highest1Source, length_)) { highest1Value = EMPTY_VALUE; }
      double Don_High = highest1Value;
      double low_Value;
      if (!low_.GetValue(pos, low_Value)) { low_Value = EMPTY_VALUE; }
      lowest1Source.SetValue(pos, low_Value);
      double lowest1Value;
      if (!LowestLowStream::GetValue(pos, lowest1Value, lowest1Source, length_)) { lowest1Value = EMPTY_VALUE; }
      double Don_Low = lowest1Value;
      double close_Value;
      if (!close_.GetValue(pos, close_Value)) { close_Value = EMPTY_VALUE; }
      double Norm = (SafeDivide((SafeMinus(close_Value, Don_Low)), (SafeMinus(Don_High, Don_Low))));
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      SetStream(initial, pos, (candle_ ? (SafePlus(SafeMultiply(Norm, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)), SafeMultiply(((SafeMinus(1, Norm))), Nz(initial[pos + 1], iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos))))) : (SafePlus(SafeMultiply(Norm, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)), SafeMultiply(((SafeMinus(1, SafeMultiply(Norm, 2)))), Nz(initial[pos + 1], iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)))))), initial_DEFAULT_VALUE);
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double src_Value;
      if (!src_.GetValue(pos, src_Value)) { src_Value = EMPTY_VALUE; }
      if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
      double Factor = (candle_ ? SafeMultiply((SafeMinus(1, Norm)), Nz(initial[pos + 1], src_Value)) : SafeMultiply(((factor_ ? (SafeMinus(1, SafeMultiply(Norm, 2))) : (SafeMinus(1, SafeDivide(Norm, 2))))), Nz(initial[pos + 1], src_Value)));
      double output = SafePlus((SafeMultiply(Norm, src_Value)), Factor);
      __out1 = output;
      return true;
   }
};
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i13_param1;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i13_param2;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i13_param3;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i13_param4;
DonCandles_fS_fS_fS_fS_b_b_iStream* DonCandles_fS_fS_fS_fS_b_b_i13;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i14_param1;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i14_param2;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i14_param3;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i14_param4;
DonCandles_fS_fS_fS_fS_b_b_iStream* DonCandles_fS_fS_fS_fS_b_b_i14;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i15_param1;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i15_param2;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i15_param3;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i15_param4;
DonCandles_fS_fS_fS_fS_b_b_iStream* DonCandles_fS_fS_fS_fS_b_b_i15;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i16_param1;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i16_param2;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i16_param3;
FloatStream* DonCandles_fS_fS_fS_fS_b_b_i16_param4;
DonCandles_fS_fS_fS_fS_b_b_iStream* DonCandles_fS_fS_fS_fS_b_b_i16;
class pricewick_fS_fSStream
{
   IStream* h_;
   IStream* a;
   bool _initialized;
public:
   pricewick_fS_fSStream(IStream* h_, IStream* a)
   {
      _initialized = false;
      this.h_ = h_;
      h_.AddRef();
      this.a = a;
      a.AddRef();
   }
   ~pricewick_fS_fSStream()
   {
      h_.Release();
      a.Release();
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
      double h_Value;
      if (!h_.GetValue(pos, h_Value)) { h_Value = EMPTY_VALUE; }
      double aValue;
      if (!a.GetValue(pos, aValue)) { aValue = EMPTY_VALUE; }
      int cond = (h_Value > aValue);
      __out1 = cond;
      return true;
   }
};
FloatStream* pricewick_fS_fS17_param1;
FloatStream* pricewick_fS_fS17_param2;
pricewick_fS_fSStream* pricewick_fS_fS17;
FloatStream* pricewick_fS_fS18_param1;
FloatStream* pricewick_fS_fS18_param2;
pricewick_fS_fSStream* pricewick_fS_fS18;
FloatStream* pricewick_fS_fS19_param1;
FloatStream* pricewick_fS_fS19_param2;
pricewick_fS_fSStream* pricewick_fS_fS19;
FloatStream* pricewick_fS_fS20_param1;
FloatStream* pricewick_fS_fS20_param2;
pricewick_fS_fSStream* pricewick_fS_fS20;
CandleStreams* plotcandle1;

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
   IndicatorBuffers(29);
   int id = 0;
   prd = param1;
   s1 = param2;
   resp = param3;
   bull = param4;
   bull2 = param5;
   bull3 = param6;
   bear = param7;
   bear2 = param8;
   bear3 = param9;
   showPD = param10;
   prem = param11;
   disc = param12;
   don = param13;
   Candle = param14;
   length = param15;
   highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, bear2);
   SetIndexBuffer(id, plot2);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, bull2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   plotcandle1 = new CandleStreams();
   id = plotcandle1.RegisterStreams(id, Lime);
   id = plotcandle1.RegisterStreams(id, Red);
   id = plotcandle1.RegisterStreams(id, INT_MIN);
   LabelsCollection::SetMaxLabels(500);
   LinesCollection::SetMaxLines(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("ICT Donchian Smart Money Structure");
   SetIndexBuffer(id++, Up);
   SetIndexBuffer(id++, Dn);
   SetIndexBuffer(id++, iUp);
   SetIndexBuffer(id++, iDn);
   SetIndexBuffer(id++, _pos);
   CreateLabel_iS_fS_s_c_b1_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b1_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b1 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b1_param1, CreateLabel_iS_fS_s_c_b1_param2, "CHoCH", bull3, true);
   id = CreateLabel_iS_fS_s_c_b1.Init(id);
   CreateLine_iS_fS_fS_c2_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c2 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c2_param1, CreateLine_iS_fS_fS_c2_param2, CreateLine_iS_fS_fS_c2_param3, bull2);
   id = CreateLine_iS_fS_fS_c2.Init(id);
   CreateLabel_iS_fS_s_c_b3_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b3_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b3 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b3_param1, CreateLabel_iS_fS_s_c_b3_param2, "SMS", bull3, true);
   id = CreateLabel_iS_fS_s_c_b3.Init(id);
   CreateLine_iS_fS_fS_c4_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c4 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c4_param1, CreateLine_iS_fS_fS_c4_param2, CreateLine_iS_fS_fS_c4_param3, bull2);
   id = CreateLine_iS_fS_fS_c4.Init(id);
   CreateLabel_iS_fS_s_c_b5_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b5_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b5 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b5_param1, CreateLabel_iS_fS_s_c_b5_param2, "BMS", bull3, true);
   id = CreateLabel_iS_fS_s_c_b5.Init(id);
   CreateLine_iS_fS_fS_c6_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c6 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c6_param1, CreateLine_iS_fS_fS_c6_param2, CreateLine_iS_fS_fS_c6_param3, bull2);
   id = CreateLine_iS_fS_fS_c6.Init(id);
   CreateLabel_iS_fS_s_c_b7_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b7_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b7 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b7_param1, CreateLabel_iS_fS_s_c_b7_param2, "CHoCH", bear3, false);
   id = CreateLabel_iS_fS_s_c_b7.Init(id);
   CreateLine_iS_fS_fS_c8_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c8 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c8_param1, CreateLine_iS_fS_fS_c8_param2, CreateLine_iS_fS_fS_c8_param3, bear2);
   id = CreateLine_iS_fS_fS_c8.Init(id);
   CreateLabel_iS_fS_s_c_b9_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b9_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b9 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b9_param1, CreateLabel_iS_fS_s_c_b9_param2, "SMS", bear3, false);
   id = CreateLabel_iS_fS_s_c_b9.Init(id);
   CreateLine_iS_fS_fS_c10_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c10 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c10_param1, CreateLine_iS_fS_fS_c10_param2, CreateLine_iS_fS_fS_c10_param3, bear2);
   id = CreateLine_iS_fS_fS_c10.Init(id);
   CreateLabel_iS_fS_s_c_b11_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b11_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLabel_iS_fS_s_c_b11 = new CreateLabel_iS_fS_s_c_bStream(CreateLabel_iS_fS_s_c_b11_param1, CreateLabel_iS_fS_s_c_b11_param2, "BMS", bear3, false);
   id = CreateLabel_iS_fS_s_c_b11.Init(id);
   CreateLine_iS_fS_fS_c12_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   CreateLine_iS_fS_fS_c12 = new CreateLine_iS_fS_fS_cStream(CreateLine_iS_fS_fS_c12_param1, CreateLine_iS_fS_fS_c12_param2, CreateLine_iS_fS_fS_c12_param3, bear2);
   id = CreateLine_iS_fS_fS_c12.Init(id);
   DonCandles_fS_fS_fS_fS_b_b_i13_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i13_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i13_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i13_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i13 = new DonCandles_fS_fS_fS_fS_b_b_iStream(DonCandles_fS_fS_fS_fS_b_b_i13_param1, DonCandles_fS_fS_fS_fS_b_b_i13_param2, DonCandles_fS_fS_fS_fS_b_b_i13_param3, DonCandles_fS_fS_fS_fS_b_b_i13_param4, true, false, length);
   id = DonCandles_fS_fS_fS_fS_b_b_i13.Init(id);
   DonCandles_fS_fS_fS_fS_b_b_i14_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i14_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i14_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i14_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i14 = new DonCandles_fS_fS_fS_fS_b_b_iStream(DonCandles_fS_fS_fS_fS_b_b_i14_param1, DonCandles_fS_fS_fS_fS_b_b_i14_param2, DonCandles_fS_fS_fS_fS_b_b_i14_param3, DonCandles_fS_fS_fS_fS_b_b_i14_param4, false, false, length);
   id = DonCandles_fS_fS_fS_fS_b_b_i14.Init(id);
   DonCandles_fS_fS_fS_fS_b_b_i15_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i15_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i15_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i15_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i15 = new DonCandles_fS_fS_fS_fS_b_b_iStream(DonCandles_fS_fS_fS_fS_b_b_i15_param1, DonCandles_fS_fS_fS_fS_b_b_i15_param2, DonCandles_fS_fS_fS_fS_b_b_i15_param3, DonCandles_fS_fS_fS_fS_b_b_i15_param4, false, false, length);
   id = DonCandles_fS_fS_fS_fS_b_b_i15.Init(id);
   DonCandles_fS_fS_fS_fS_b_b_i16_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i16_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i16_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i16_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   DonCandles_fS_fS_fS_fS_b_b_i16 = new DonCandles_fS_fS_fS_fS_b_b_iStream(DonCandles_fS_fS_fS_fS_b_b_i16_param1, DonCandles_fS_fS_fS_fS_b_b_i16_param2, DonCandles_fS_fS_fS_fS_b_b_i16_param3, DonCandles_fS_fS_fS_fS_b_b_i16_param4, true, false, length);
   id = DonCandles_fS_fS_fS_fS_b_b_i16.Init(id);
   pricewick_fS_fS17_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS17_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS17 = new pricewick_fS_fSStream(pricewick_fS_fS17_param1, pricewick_fS_fS17_param2);
   id = pricewick_fS_fS17.Init(id);
   pricewick_fS_fS18_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS18_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS18 = new pricewick_fS_fSStream(pricewick_fS_fS18_param1, pricewick_fS_fS18_param2);
   id = pricewick_fS_fS18.Init(id);
   pricewick_fS_fS19_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS19_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS19 = new pricewick_fS_fSStream(pricewick_fS_fS19_param1, pricewick_fS_fS19_param2);
   id = pricewick_fS_fS19.Init(id);
   pricewick_fS_fS20_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS20_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pricewick_fS_fS20 = new pricewick_fS_fSStream(pricewick_fS_fS20_param1, pricewick_fS_fS20_param2);
   id = pricewick_fS_fS20.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   highestpivot1Source.Release();
   lowestpivot1Source.Release();
   CreateLabel_iS_fS_s_c_b1_param1.Release();
   CreateLabel_iS_fS_s_c_b1_param2.Release();
   delete CreateLabel_iS_fS_s_c_b1;
   CreateLine_iS_fS_fS_c2_param1.Release();
   CreateLine_iS_fS_fS_c2_param2.Release();
   CreateLine_iS_fS_fS_c2_param3.Release();
   delete CreateLine_iS_fS_fS_c2;
   CreateLabel_iS_fS_s_c_b3_param1.Release();
   CreateLabel_iS_fS_s_c_b3_param2.Release();
   delete CreateLabel_iS_fS_s_c_b3;
   CreateLine_iS_fS_fS_c4_param1.Release();
   CreateLine_iS_fS_fS_c4_param2.Release();
   CreateLine_iS_fS_fS_c4_param3.Release();
   delete CreateLine_iS_fS_fS_c4;
   CreateLabel_iS_fS_s_c_b5_param1.Release();
   CreateLabel_iS_fS_s_c_b5_param2.Release();
   delete CreateLabel_iS_fS_s_c_b5;
   CreateLine_iS_fS_fS_c6_param1.Release();
   CreateLine_iS_fS_fS_c6_param2.Release();
   CreateLine_iS_fS_fS_c6_param3.Release();
   delete CreateLine_iS_fS_fS_c6;
   CreateLabel_iS_fS_s_c_b7_param1.Release();
   CreateLabel_iS_fS_s_c_b7_param2.Release();
   delete CreateLabel_iS_fS_s_c_b7;
   CreateLine_iS_fS_fS_c8_param1.Release();
   CreateLine_iS_fS_fS_c8_param2.Release();
   CreateLine_iS_fS_fS_c8_param3.Release();
   delete CreateLine_iS_fS_fS_c8;
   CreateLabel_iS_fS_s_c_b9_param1.Release();
   CreateLabel_iS_fS_s_c_b9_param2.Release();
   delete CreateLabel_iS_fS_s_c_b9;
   CreateLine_iS_fS_fS_c10_param1.Release();
   CreateLine_iS_fS_fS_c10_param2.Release();
   CreateLine_iS_fS_fS_c10_param3.Release();
   delete CreateLine_iS_fS_fS_c10;
   CreateLabel_iS_fS_s_c_b11_param1.Release();
   CreateLabel_iS_fS_s_c_b11_param2.Release();
   delete CreateLabel_iS_fS_s_c_b11;
   CreateLine_iS_fS_fS_c12_param1.Release();
   CreateLine_iS_fS_fS_c12_param2.Release();
   CreateLine_iS_fS_fS_c12_param3.Release();
   delete CreateLine_iS_fS_fS_c12;
   DonCandles_fS_fS_fS_fS_b_b_i13_param1.Release();
   DonCandles_fS_fS_fS_fS_b_b_i13_param2.Release();
   DonCandles_fS_fS_fS_fS_b_b_i13_param3.Release();
   DonCandles_fS_fS_fS_fS_b_b_i13_param4.Release();
   delete DonCandles_fS_fS_fS_fS_b_b_i13;
   DonCandles_fS_fS_fS_fS_b_b_i14_param1.Release();
   DonCandles_fS_fS_fS_fS_b_b_i14_param2.Release();
   DonCandles_fS_fS_fS_fS_b_b_i14_param3.Release();
   DonCandles_fS_fS_fS_fS_b_b_i14_param4.Release();
   delete DonCandles_fS_fS_fS_fS_b_b_i14;
   DonCandles_fS_fS_fS_fS_b_b_i15_param1.Release();
   DonCandles_fS_fS_fS_fS_b_b_i15_param2.Release();
   DonCandles_fS_fS_fS_fS_b_b_i15_param3.Release();
   DonCandles_fS_fS_fS_fS_b_b_i15_param4.Release();
   delete DonCandles_fS_fS_fS_fS_b_b_i15;
   DonCandles_fS_fS_fS_fS_b_b_i16_param1.Release();
   DonCandles_fS_fS_fS_fS_b_b_i16_param2.Release();
   DonCandles_fS_fS_fS_fS_b_b_i16_param3.Release();
   DonCandles_fS_fS_fS_fS_b_b_i16_param4.Release();
   delete DonCandles_fS_fS_fS_fS_b_b_i16;
   pricewick_fS_fS17_param1.Release();
   pricewick_fS_fS17_param2.Release();
   delete pricewick_fS_fS17;
   pricewick_fS_fS18_param1.Release();
   pricewick_fS_fS18_param2.Release();
   delete pricewick_fS_fS18;
   pricewick_fS_fS19_param1.Release();
   pricewick_fS_fS19_param2.Release();
   delete pricewick_fS_fS19;
   pricewick_fS_fS20_param1.Release();
   pricewick_fS_fS20_param2.Release();
   delete pricewick_fS_fS20;
   delete plotcandle1;
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
      Up_DEFAULT_VALUE = (double)(NULL);
      ArrayInitialize(Up, Up_DEFAULT_VALUE);
      Dn_DEFAULT_VALUE = (double)(NULL);
      ArrayInitialize(Dn, Dn_DEFAULT_VALUE);
      iUp_DEFAULT_VALUE = (int)(NULL);
      ArrayInitialize(iUp, iUp_DEFAULT_VALUE);
      iDn_DEFAULT_VALUE = (int)(NULL);
      ArrayInitialize(iDn, iDn_DEFAULT_VALUE);
      highestpivot1Source.Init();
      lowestpivot1Source.Init();
      _pos_DEFAULT_VALUE = 0;
      ArrayInitialize(_pos, _pos_DEFAULT_VALUE);
      CreateLabel_iS_fS_s_c_b1_param1.Init();
      CreateLabel_iS_fS_s_c_b1_param2.Init();
      CreateLabel_iS_fS_s_c_b1.Clear();
      CreateLine_iS_fS_fS_c2_param1.Init();
      CreateLine_iS_fS_fS_c2_param2.Init();
      CreateLine_iS_fS_fS_c2_param3.Init();
      CreateLine_iS_fS_fS_c2.Clear();
      CreateLabel_iS_fS_s_c_b3_param1.Init();
      CreateLabel_iS_fS_s_c_b3_param2.Init();
      CreateLabel_iS_fS_s_c_b3.Clear();
      CreateLine_iS_fS_fS_c4_param1.Init();
      CreateLine_iS_fS_fS_c4_param2.Init();
      CreateLine_iS_fS_fS_c4_param3.Init();
      CreateLine_iS_fS_fS_c4.Clear();
      CreateLabel_iS_fS_s_c_b5_param1.Init();
      CreateLabel_iS_fS_s_c_b5_param2.Init();
      CreateLabel_iS_fS_s_c_b5.Clear();
      CreateLine_iS_fS_fS_c6_param1.Init();
      CreateLine_iS_fS_fS_c6_param2.Init();
      CreateLine_iS_fS_fS_c6_param3.Init();
      CreateLine_iS_fS_fS_c6.Clear();
      CreateLabel_iS_fS_s_c_b7_param1.Init();
      CreateLabel_iS_fS_s_c_b7_param2.Init();
      CreateLabel_iS_fS_s_c_b7.Clear();
      CreateLine_iS_fS_fS_c8_param1.Init();
      CreateLine_iS_fS_fS_c8_param2.Init();
      CreateLine_iS_fS_fS_c8_param3.Init();
      CreateLine_iS_fS_fS_c8.Clear();
      CreateLabel_iS_fS_s_c_b9_param1.Init();
      CreateLabel_iS_fS_s_c_b9_param2.Init();
      CreateLabel_iS_fS_s_c_b9.Clear();
      CreateLine_iS_fS_fS_c10_param1.Init();
      CreateLine_iS_fS_fS_c10_param2.Init();
      CreateLine_iS_fS_fS_c10_param3.Init();
      CreateLine_iS_fS_fS_c10.Clear();
      CreateLabel_iS_fS_s_c_b11_param1.Init();
      CreateLabel_iS_fS_s_c_b11_param2.Init();
      CreateLabel_iS_fS_s_c_b11.Clear();
      CreateLine_iS_fS_fS_c12_param1.Init();
      CreateLine_iS_fS_fS_c12_param2.Init();
      CreateLine_iS_fS_fS_c12_param3.Init();
      CreateLine_iS_fS_fS_c12.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      DonCandles_fS_fS_fS_fS_b_b_i13_param1.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13_param2.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13_param3.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13_param4.Init();
      DonCandles_fS_fS_fS_fS_b_b_i13.Clear();
      DonCandles_fS_fS_fS_fS_b_b_i14_param1.Init();
      DonCandles_fS_fS_fS_fS_b_b_i14_param2.Init();
      DonCandles_fS_fS_fS_fS_b_b_i14_param3.Init();
      DonCandles_fS_fS_fS_fS_b_b_i14_param4.Init();
      DonCandles_fS_fS_fS_fS_b_b_i14.Clear();
      DonCandles_fS_fS_fS_fS_b_b_i15_param1.Init();
      DonCandles_fS_fS_fS_fS_b_b_i15_param2.Init();
      DonCandles_fS_fS_fS_fS_b_b_i15_param3.Init();
      DonCandles_fS_fS_fS_fS_b_b_i15_param4.Init();
      DonCandles_fS_fS_fS_fS_b_b_i15.Clear();
      DonCandles_fS_fS_fS_fS_b_b_i16_param1.Init();
      DonCandles_fS_fS_fS_fS_b_b_i16_param2.Init();
      DonCandles_fS_fS_fS_fS_b_b_i16_param3.Init();
      DonCandles_fS_fS_fS_fS_b_b_i16_param4.Init();
      DonCandles_fS_fS_fS_fS_b_b_i16.Clear();
      pricewick_fS_fS17_param1.Init();
      pricewick_fS_fS17_param2.Init();
      pricewick_fS_fS17.Clear();
      pricewick_fS_fS18_param1.Init();
      pricewick_fS_fS18_param2.Init();
      pricewick_fS_fS18.Clear();
      pricewick_fS_fS19_param1.Init();
      pricewick_fS_fS19_param2.Init();
      pricewick_fS_fS19.Clear();
      pricewick_fS_fS20_param1.Init();
      pricewick_fS_fS20_param2.Init();
      pricewick_fS_fS20.Clear();
      plotcandle1.Init();
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
      Up[pos] = pos < (rates_total - 1) ? Up[pos + 1] : (double)(NULL);
      Dn[pos] = pos < (rates_total - 1) ? Dn[pos + 1] : (double)(NULL);
      iUp[pos] = pos < (rates_total - 1) ? iUp[pos + 1] : (int)(NULL);
      iDn[pos] = pos < (rates_total - 1) ? iDn[pos + 1] : (int)(NULL);
      _pos[pos] = pos < (rates_total - 1) ? _pos[pos + 1] : 0;
      string t1 = "Set the pivot period";
      string t2 = "Set the response period. A low value returns a short-term structure and a high value returns a long-term structure. If you disable this option the pivot length above will be used.";
      string t3 = "Enable the Donchian Channel.";
      string t4 = "A high value returns the long-term structure and a low value returns the short-term structure.";
      b = ((rates_total - 1) - pos);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(Up, pos, SafeMathMax(Up[pos + 1], high[pos]), Up_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(Dn, pos, SafeMathMin(Dn[pos + 1], low[pos]), Dn_DEFAULT_VALUE);
      highestpivot1Source.SetValue(pos, high[pos]);
      double highestpivot1Value;
      if (!PivotHighStream::GetValue(pos, highestpivot1Value, highestpivot1Source, prd, prd)) { highestpivot1Value = EMPTY_VALUE; }
      double pvtHi = highestpivot1Value;
      lowestpivot1Source.SetValue(pos, low[pos]);
      double lowestpivot1Value;
      if (!PivotLowStream::GetValue(pos, lowestpivot1Value, lowestpivot1Source, prd, prd)) { lowestpivot1Value = EMPTY_VALUE; }
      double pvtLo = lowestpivot1Value;
      if (NumberToBool(pvtHi))
      {
         SetStream(Up, pos, pvtHi, Up_DEFAULT_VALUE);
      }
      if (NumberToBool(pvtLo))
      {
         SetStream(Dn, pos, pvtLo, Dn_DEFAULT_VALUE);
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (SafeGreater(Up[pos], Up[pos + 1]))
      {
         SetStream(iUp, pos, b, iUp_DEFAULT_VALUE);
         if (pos + 1 > (rates_total - 1)) { continue; }
         int centerBull = SafeMathRound(SafeDivide((SafePlus(iUp[pos + 1], b)), 2));
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + (s1 ? resp : prd) > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + (s1 ? resp : prd) > (rates_total - 1)) { continue; }
         if ((_pos[pos] <= 0))
         {
            if (bull)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b1_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b1_param2.SetValue(pos, Up[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b1Value;
               if (!CreateLabel_iS_fS_s_c_b1.GetValue(pos, CreateLabel_iS_fS_s_c_b1Value)) { CreateLabel_iS_fS_s_c_b1Value = NULL; }
               CreateLabel_iS_fS_s_c_b1Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c2_param1.SetValue(pos, iUp[pos + 1]);
               CreateLine_iS_fS_fS_c2_param2.SetValue(pos, Up[pos + 1]);
               CreateLine_iS_fS_fS_c2_param3.SetValue(pos, Up[pos + 1]);
               Line* CreateLine_iS_fS_fS_c2Value;
               if (!CreateLine_iS_fS_fS_c2.GetValue(pos, CreateLine_iS_fS_fS_c2Value)) { CreateLine_iS_fS_fS_c2Value = NULL; }
               CreateLine_iS_fS_fS_c2Value;
            }
            SetStream(_pos, pos, 1, _pos_DEFAULT_VALUE);
         }
         else if ((_pos[pos] == 1) && SafeGreater(Up[pos], Up[pos + 1]) && (Up[pos + 1] == Up[pos + (s1 ? resp : prd)]))
         {
            if (bull)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b3_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b3_param2.SetValue(pos, Up[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b3Value;
               if (!CreateLabel_iS_fS_s_c_b3.GetValue(pos, CreateLabel_iS_fS_s_c_b3Value)) { CreateLabel_iS_fS_s_c_b3Value = NULL; }
               CreateLabel_iS_fS_s_c_b3Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c4_param1.SetValue(pos, iUp[pos + 1]);
               CreateLine_iS_fS_fS_c4_param2.SetValue(pos, Up[pos + 1]);
               CreateLine_iS_fS_fS_c4_param3.SetValue(pos, Up[pos + 1]);
               Line* CreateLine_iS_fS_fS_c4Value;
               if (!CreateLine_iS_fS_fS_c4.GetValue(pos, CreateLine_iS_fS_fS_c4Value)) { CreateLine_iS_fS_fS_c4Value = NULL; }
               CreateLine_iS_fS_fS_c4Value;
            }
            SetStream(_pos, pos, 2, _pos_DEFAULT_VALUE);
         }
         else if ((_pos[pos] > 1) && SafeGreater(Up[pos], Up[pos + 1]) && (Up[pos + 1] == Up[pos + (s1 ? resp : prd)]))
         {
            if (bull)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b5_param1.SetValue(pos, centerBull);
               CreateLabel_iS_fS_s_c_b5_param2.SetValue(pos, Up[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b5Value;
               if (!CreateLabel_iS_fS_s_c_b5.GetValue(pos, CreateLabel_iS_fS_s_c_b5Value)) { CreateLabel_iS_fS_s_c_b5Value = NULL; }
               CreateLabel_iS_fS_s_c_b5Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c6_param1.SetValue(pos, iUp[pos + 1]);
               CreateLine_iS_fS_fS_c6_param2.SetValue(pos, Up[pos + 1]);
               CreateLine_iS_fS_fS_c6_param3.SetValue(pos, Up[pos + 1]);
               Line* CreateLine_iS_fS_fS_c6Value;
               if (!CreateLine_iS_fS_fS_c6.GetValue(pos, CreateLine_iS_fS_fS_c6Value)) { CreateLine_iS_fS_fS_c6Value = NULL; }
               CreateLine_iS_fS_fS_c6Value;
            }
            SetStream(_pos, pos, _pos[pos] + 1, _pos_DEFAULT_VALUE);
         }
      }
      else if (SafeLess(Up[pos], Up[pos + 1]))
      {
         SetStream(iUp, pos, b - prd, iUp_DEFAULT_VALUE);
      }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (SafeLess(Dn[pos], Dn[pos + 1]))
      {
         SetStream(iDn, pos, b, iDn_DEFAULT_VALUE);
         if (pos + 1 > (rates_total - 1)) { continue; }
         int centerBear = SafeMathRound(SafeDivide((SafePlus(iDn[pos + 1], b)), 2));
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + (s1 ? resp : prd) > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + (s1 ? resp : prd) > (rates_total - 1)) { continue; }
         if ((_pos[pos] >= 0))
         {
            if (bear)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b7_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b7_param2.SetValue(pos, Dn[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b7Value;
               if (!CreateLabel_iS_fS_s_c_b7.GetValue(pos, CreateLabel_iS_fS_s_c_b7Value)) { CreateLabel_iS_fS_s_c_b7Value = NULL; }
               CreateLabel_iS_fS_s_c_b7Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c8_param1.SetValue(pos, iDn[pos + 1]);
               CreateLine_iS_fS_fS_c8_param2.SetValue(pos, Dn[pos + 1]);
               CreateLine_iS_fS_fS_c8_param3.SetValue(pos, Dn[pos + 1]);
               Line* CreateLine_iS_fS_fS_c8Value;
               if (!CreateLine_iS_fS_fS_c8.GetValue(pos, CreateLine_iS_fS_fS_c8Value)) { CreateLine_iS_fS_fS_c8Value = NULL; }
               CreateLine_iS_fS_fS_c8Value;
            }
            SetStream(_pos, pos, (-1), _pos_DEFAULT_VALUE);
         }
         else if ((_pos[pos] == (-1)) && SafeLess(Dn[pos], Dn[pos + 1]) && (Dn[pos + 1] == Dn[pos + (s1 ? resp : prd)]))
         {
            if (bear)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b9_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b9_param2.SetValue(pos, Dn[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b9Value;
               if (!CreateLabel_iS_fS_s_c_b9.GetValue(pos, CreateLabel_iS_fS_s_c_b9Value)) { CreateLabel_iS_fS_s_c_b9Value = NULL; }
               CreateLabel_iS_fS_s_c_b9Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c10_param1.SetValue(pos, iDn[pos + 1]);
               CreateLine_iS_fS_fS_c10_param2.SetValue(pos, Dn[pos + 1]);
               CreateLine_iS_fS_fS_c10_param3.SetValue(pos, Dn[pos + 1]);
               Line* CreateLine_iS_fS_fS_c10Value;
               if (!CreateLine_iS_fS_fS_c10.GetValue(pos, CreateLine_iS_fS_fS_c10Value)) { CreateLine_iS_fS_fS_c10Value = NULL; }
               CreateLine_iS_fS_fS_c10Value;
            }
            SetStream(_pos, pos, (-2), _pos_DEFAULT_VALUE);
         }
         else if ((_pos[pos] < (-1)) && SafeLess(Dn[pos], Dn[pos + 1]) && (Dn[pos + 1] == Dn[pos + (s1 ? resp : prd)]))
         {
            if (bear)
            {
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLabel_iS_fS_s_c_b11_param1.SetValue(pos, centerBear);
               CreateLabel_iS_fS_s_c_b11_param2.SetValue(pos, Dn[pos + 1]);
               Label* CreateLabel_iS_fS_s_c_b11Value;
               if (!CreateLabel_iS_fS_s_c_b11.GetValue(pos, CreateLabel_iS_fS_s_c_b11Value)) { CreateLabel_iS_fS_s_c_b11Value = NULL; }
               CreateLabel_iS_fS_s_c_b11Value;
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               if (pos + 1 > (rates_total - 1)) { continue; }
               CreateLine_iS_fS_fS_c12_param1.SetValue(pos, iDn[pos + 1]);
               CreateLine_iS_fS_fS_c12_param2.SetValue(pos, Dn[pos + 1]);
               CreateLine_iS_fS_fS_c12_param3.SetValue(pos, Dn[pos + 1]);
               Line* CreateLine_iS_fS_fS_c12Value;
               if (!CreateLine_iS_fS_fS_c12.GetValue(pos, CreateLine_iS_fS_fS_c12Value)) { CreateLine_iS_fS_fS_c12Value = NULL; }
               CreateLine_iS_fS_fS_c12Value;
            }
            SetStream(_pos, pos, _pos[pos] - 1, _pos_DEFAULT_VALUE);
         }
      }
      else if (SafeGreater(Dn[pos], Dn[pos + 1]))
      {
         SetStream(iDn, pos, b - prd, iDn_DEFAULT_VALUE);
      }
      double PremiumTop = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .1));
      double PremiumBot = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .25));
      double DiscountTop = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .25));
      double DiscountBot = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .1));
      double MidTop = SafeMinus(Up[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .45));
      double MidBot = SafePlus(Dn[pos], SafeMultiply((SafeMinus(Up[pos], Dn[pos])), .45));
      color plot1_color = bear2;
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = (don ? Up[pos] : EMPTY_VALUE); }
      else { plot1[pos] = EMPTY_VALUE; }
      double r1 = plot1[pos];
      color plot2_color = bull2;
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = (don ? Dn[pos] : EMPTY_VALUE); }
      else { plot2[pos] = EMPTY_VALUE; }
      double r2 = plot2[pos];
      plot3[pos] = (showPD ? PremiumTop : EMPTY_VALUE);
      double p1 = plot3[pos];
      plot4[pos] = (showPD ? PremiumBot : EMPTY_VALUE);
      double p2 = plot4[pos];
      plot5[pos] = (showPD ? DiscountTop : EMPTY_VALUE);
      double d1 = plot5[pos];
      plot6[pos] = (showPD ? DiscountBot : EMPTY_VALUE);
      double d2 = plot6[pos];
      plot7[pos] = (showPD ? MidTop : EMPTY_VALUE);
      double m1 = plot7[pos];
      plot8[pos] = (showPD ? MidBot : EMPTY_VALUE);
      double m2 = plot8[pos];
      DonCandles_fS_fS_fS_fS_b_b_i13_param1.SetValue(pos, Up[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i13_param2.SetValue(pos, Dn[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i13_param3.SetValue(pos, close[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i13_param4.SetValue(pos, open[pos]);
      double DonCandles_fS_fS_fS_fS_b_b_i13Value;
      if (!DonCandles_fS_fS_fS_fS_b_b_i13.GetValue(pos, DonCandles_fS_fS_fS_fS_b_b_i13Value)) { DonCandles_fS_fS_fS_fS_b_b_i13Value = EMPTY_VALUE; }
      double O = (Candle ? DonCandles_fS_fS_fS_fS_b_b_i13Value : EMPTY_VALUE);
      DonCandles_fS_fS_fS_fS_b_b_i14_param1.SetValue(pos, Up[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i14_param2.SetValue(pos, Dn[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i14_param3.SetValue(pos, close[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i14_param4.SetValue(pos, high[pos]);
      double DonCandles_fS_fS_fS_fS_b_b_i14Value;
      if (!DonCandles_fS_fS_fS_fS_b_b_i14.GetValue(pos, DonCandles_fS_fS_fS_fS_b_b_i14Value)) { DonCandles_fS_fS_fS_fS_b_b_i14Value = EMPTY_VALUE; }
      double H = (Candle ? DonCandles_fS_fS_fS_fS_b_b_i14Value : EMPTY_VALUE);
      DonCandles_fS_fS_fS_fS_b_b_i15_param1.SetValue(pos, Up[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i15_param2.SetValue(pos, Dn[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i15_param3.SetValue(pos, close[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i15_param4.SetValue(pos, low[pos]);
      double DonCandles_fS_fS_fS_fS_b_b_i15Value;
      if (!DonCandles_fS_fS_fS_fS_b_b_i15.GetValue(pos, DonCandles_fS_fS_fS_fS_b_b_i15Value)) { DonCandles_fS_fS_fS_fS_b_b_i15Value = EMPTY_VALUE; }
      double L = (Candle ? DonCandles_fS_fS_fS_fS_b_b_i15Value : EMPTY_VALUE);
      DonCandles_fS_fS_fS_fS_b_b_i16_param1.SetValue(pos, Up[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i16_param2.SetValue(pos, Dn[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i16_param3.SetValue(pos, close[pos]);
      DonCandles_fS_fS_fS_fS_b_b_i16_param4.SetValue(pos, close[pos]);
      double DonCandles_fS_fS_fS_fS_b_b_i16Value;
      if (!DonCandles_fS_fS_fS_fS_b_b_i16.GetValue(pos, DonCandles_fS_fS_fS_fS_b_b_i16Value)) { DonCandles_fS_fS_fS_fS_b_b_i16Value = EMPTY_VALUE; }
      double C = (Candle ? DonCandles_fS_fS_fS_fS_b_b_i16Value : EMPTY_VALUE);
      pricewick_fS_fS17_param1.SetValue(pos, H);
      pricewick_fS_fS17_param2.SetValue(pos, open[pos]);
      int pricewick_fS_fS17Value;
      if (!pricewick_fS_fS17.GetValue(pos, pricewick_fS_fS17Value)) { pricewick_fS_fS17Value = (-1); }
      int cond_open = pricewick_fS_fS17Value;
      pricewick_fS_fS18_param1.SetValue(pos, H);
      pricewick_fS_fS18_param2.SetValue(pos, high[pos]);
      int pricewick_fS_fS18Value;
      if (!pricewick_fS_fS18.GetValue(pos, pricewick_fS_fS18Value)) { pricewick_fS_fS18Value = (-1); }
      int cond_high = pricewick_fS_fS18Value;
      pricewick_fS_fS19_param1.SetValue(pos, H);
      pricewick_fS_fS19_param2.SetValue(pos, low[pos]);
      int pricewick_fS_fS19Value;
      if (!pricewick_fS_fS19.GetValue(pos, pricewick_fS_fS19Value)) { pricewick_fS_fS19Value = (-1); }
      int cond_low = pricewick_fS_fS19Value;
      pricewick_fS_fS20_param1.SetValue(pos, H);
      pricewick_fS_fS20_param2.SetValue(pos, close[pos]);
      int pricewick_fS_fS20Value;
      if (!pricewick_fS_fS20.GetValue(pos, pricewick_fS_fS20Value)) { pricewick_fS_fS20Value = (-1); }
      int cond_close = pricewick_fS_fS20Value;
      uint sign = (((((cond_open || cond_high) || cond_low) || cond_close)) ? Lime : Red);
      double plotcandle1_open = open[pos];
      double plotcandle1_close = close[pos];
      color plotcandle1_color = (Candle ? sign : INT_MIN);
      if (plotcandle1_color != EMPTY_VALUE)
      {
         plotcandle1.Set(pos, plotcandle1_open, high[pos], low[pos], plotcandle1_close, plotcandle1_color);
      }
      else
      {
         plotcandle1.Clear(pos);
      }
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75503

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