//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75525
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
#property indicator_buffers 4
#property indicator_type1 DRAW_LINE
#property indicator_color1 Green
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_color2 Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_type4 DRAW_LINE
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Stream base v1.0

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
#ifndef IStream_IMPL
#define IStream_IMPL

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};
#endif

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

input int param1 = 20; // Period
input double param2 = 2.0; // Deviation
input int bars_limit = 100000; // Bars limit
int PERIOD;
double Deviation;
FloatStream* linreg1Source;
LinearRegressionOnStream* linreg1;
FloatStream* sum1Source;
SumOnStream* sum1;
double lrl[];
double lrl_DEFAULT_VALUE;
ColoredStream* plot1;
double plot3[];
double plot4[];

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
   IndicatorBuffers(6);
   int id = 0;
   PERIOD = param1;
   Deviation = param2;
   linreg1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   linreg1 = new LinearRegressionOnStream(linreg1Source, PERIOD, 0);
   sum1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sum1 = new SumOnStream(sum1Source, PERIOD);
   plot1 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot1.RegisterStream(id, Green);
   id = plot1.RegisterStream(id, Red);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Linear Regression Line with Band Deviation");
   SetIndexBuffer(id++, lrl);
   id = plot1.RegisterInternalStream(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   linreg1Source.Release();
   linreg1.Release();
   sum1Source.Release();
   sum1.Release();
   delete plot1;
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
      linreg1Source.Init();
      sum1Source.Init();
      lrl_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(lrl, lrl_DEFAULT_VALUE);
      plot1.Init(EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
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
      linreg1Source.SetValue(pos, close[pos]);
      double linreg1Value;
      if (!linreg1.GetValue(pos, linreg1Value)) { linreg1Value = EMPTY_VALUE; }
      SetStream(lrl, pos, linreg1Value, lrl_DEFAULT_VALUE);
      double diff = SafeMathPow(SafeMinus(close[pos], lrl[pos]), 2);
      sum1Source.SetValue(pos, diff);
      double sum1Value;
      if (!sum1.GetValue(pos, sum1Value)) { sum1Value = EMPTY_VALUE; }
      double sum = sum1Value;
      double variance = SafeMathSqrt(SafeDivide(sum, PERIOD));
      if (pos + 1 > (rates_total - 1)) { continue; }
      double plot1Value = plot1.SetByColor(lrl[pos], pos, (SafeGreater(lrl[pos], lrl[pos + 1]) ? Green : Red));
      plot3[pos] = SafePlus(lrl[pos], SafeMultiply(variance, Deviation));
      plot4[pos] = SafeMinus(lrl[pos], SafeMultiply(variance, Deviation));
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75525
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