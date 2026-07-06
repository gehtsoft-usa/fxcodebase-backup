//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=156916#p156916

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
#property indicator_buffers 10
#property indicator_label1 "Upper Boundary: Far (Custom)"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Upper Boundary: Average (Custom)"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Upper Boundary: Near (Custom)"
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Custom Estimation"
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 2
#property indicator_label5 "Custom Estimation"
#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 2
#property indicator_label6 "Custom Estimation"
#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 2
#property indicator_label7 "Custom Estimation"
#property indicator_type7 DRAW_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 2
#property indicator_label8 "Lower Boundary: Near (Custom)"
#property indicator_type8 DRAW_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Lower Boundary: Average (Custom)"
#property indicator_type9 DRAW_LINE
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Lower Boundary: Far (Custom)"
#property indicator_type10 DRAW_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1

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

//RmaOnStream v1.0

#ifndef RmaOnStream_IMP
#define RmaOnStream_IMP

class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
         return false;

      int currentSize = ArrayRange(_buffer, 0);
      if (currentSize < size)
      {
         ArrayResize(_buffer, size);
         for (int i = currentSize; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double alpha = 1.0 / _length;
      int index = size - 1 - period;
      if (index == 0 || _buffer[index - 1] == EMPTY_VALUE)
      {
         _buffer[index] = price;
      }
      else
      {
         _buffer[index] =  alpha * price + (1 - alpha) * _buffer[index - 1];
      }
      val = _buffer[index];
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
input int param1 = 8; // Lookback Window (Custom)
input double param2 = 8.; // Relative Weighting (Custom)
input int param3 = 25; // Start Regression at Bar (Custom)
input int param4 = 60; // ATR Length (Custom)
input double param5 = 1.5; // Near ATR Factor (Custom)
input double param6 = 2.0; // Far ATR Factor (Custom)
input int bars_limit = 100000; // Bars limit
int customLookbackWindow;
double customRelativeWeighting;
int customStartRegressionBar;
class customKernel_fS_i_f_iStream
{
   IStream* x;
   int h;
   double alpha;
   int x_0;
   bool _initialized;
public:
   customKernel_fS_i_f_iStream(IStream* x, int h, double alpha, int x_0)
   {
      _initialized = false;
      this.x = x;
      x.AddRef();
      this.h = h;
      this.alpha = alpha;
      this.x_0 = x_0;
   }
   ~customKernel_fS_i_f_iStream()
   {
      x.Release();
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
      double sumWeights = 0.0;
      double sumXWeights = 0.0;
      int for1_from = 0;
      int for1_to = h;
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { return false; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         double weight = SafeMathPow(SafePlus(1, (SafeDivide(MathPow((x_0 - i), 2), (2 * alpha * h * h)))), (-alpha));
         sumWeights = SafePlus(sumWeights, weight);
         double xValue_i;
         if (!x.GetValue(pos + i, xValue_i)) { xValue_i = EMPTY_VALUE; }
         sumXWeights = SafePlus(sumXWeights, SafeMultiply(weight, xValue_i));
      }
      __out1 = SafeDivide(sumXWeights, sumWeights);
      return true;
   }
};
FloatStream* customKernel_fS_i_f_i1_param1;
customKernel_fS_i_f_iStream* customKernel_fS_i_f_i1;
FloatStream* customKernel_fS_i_f_i2_param1;
customKernel_fS_i_f_iStream* customKernel_fS_i_f_i2;
FloatStream* customKernel_fS_i_f_i3_param1;
customKernel_fS_i_f_iStream* customKernel_fS_i_f_i3;
int customATRLength;
class customATR_i_fS_fS_fSStream
{
   int length;
   IStream* _high;
   IStream* _low;
   IStream* _close;
   FloatStream* rma1Source;
   RmaOnStream* rma1;
   bool _initialized;
public:
   customATR_i_fS_fS_fSStream(int length, IStream* _high, IStream* _low, IStream* _close)
   {
      _initialized = false;
      this.length = length;
      this._high = _high;
      _high.AddRef();
      this._low = _low;
      _low.AddRef();
      this._close = _close;
      _close.AddRef();
      rma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      rma1 = new RmaOnStream(rma1Source, length);
   }
   ~customATR_i_fS_fS_fSStream()
   {
      _high.Release();
      _low.Release();
      _close.Release();
      rma1Source.Release();
      rma1.Release();
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
         rma1Source.Init();
         _initialized = true;
      }
      double _highValue_1;
      if (!_high.GetValue(pos + 1, _highValue_1)) { _highValue_1 = EMPTY_VALUE; }
      double _highValue;
      if (!_high.GetValue(pos, _highValue)) { _highValue = EMPTY_VALUE; }
      double _lowValue;
      if (!_low.GetValue(pos, _lowValue)) { _lowValue = EMPTY_VALUE; }
      double _closeValue_1;
      if (!_close.GetValue(pos + 1, _closeValue_1)) { _closeValue_1 = EMPTY_VALUE; }
      double trueRange = (((_highValue_1) == EMPTY_VALUE) ? SafeMinus(MathLog(_highValue), MathLog(_lowValue)) : SafeMathMax(SafeMathMax(SafeMinus(MathLog(_highValue), MathLog(_lowValue)), SafeMathAbs(SafeMinus(MathLog(_highValue), SafeLog(_closeValue_1)))), SafeMathAbs(SafeMinus(MathLog(_lowValue), SafeLog(_closeValue_1)))));
      rma1Source.SetValue(pos, trueRange);
      double rma1Value;
      if (!rma1.GetValue(pos, rma1Value)) { rma1Value = EMPTY_VALUE; }
      __out1 = rma1Value;
      return true;
   }
};
FloatStream* customATR_i_fS_fS_fS4_param2;
FloatStream* customATR_i_fS_fS_fS4_param3;
FloatStream* customATR_i_fS_fS_fS4_param4;
customATR_i_fS_fS_fSStream* customATR_i_fS_fS_fS4;
double customNearATRFactor;
double customFarATRFactor;
class getEnvelopeBounds_fS_f_f_fSStream
{
   IStream* _atr;
   double _nearFactor;
   double _farFactor;
   IStream* _envelope;
   bool _initialized;
public:
   getEnvelopeBounds_fS_f_f_fSStream(IStream* _atr, double _nearFactor, double _farFactor, IStream* _envelope)
   {
      _initialized = false;
      this._atr = _atr;
      _atr.AddRef();
      this._nearFactor = _nearFactor;
      this._farFactor = _farFactor;
      this._envelope = _envelope;
      _envelope.AddRef();
   }
   ~getEnvelopeBounds_fS_f_f_fSStream()
   {
      _atr.Release();
      _envelope.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1, double &__out2, double &__out3, double &__out4, double &__out5, double &__out6)
   {
      double _envelopeValue;
      if (!_envelope.GetValue(pos, _envelopeValue)) { _envelopeValue = EMPTY_VALUE; }
      double _atrValue;
      if (!_atr.GetValue(pos, _atrValue)) { _atrValue = EMPTY_VALUE; }
      double _upperFar = _envelopeValue + _farFactor * _atrValue;
      double _upperNear = _envelopeValue + _nearFactor * _atrValue;
      double _lowerNear = _envelopeValue - _nearFactor * _atrValue;
      double _lowerFar = _envelopeValue - _farFactor * _atrValue;
      double _upperAvg = SafeDivide((_upperFar + _upperNear), 2);
      double _lowerAvg = SafeDivide((_lowerFar + _lowerNear), 2);
      __out1 = _upperNear;
      __out2 = _upperFar;
      __out3 = _upperAvg;
      __out4 = _lowerNear;
      __out5 = _lowerFar;
      __out6 = _lowerAvg;
      return true;
   }
};
FloatStream* getEnvelopeBounds_fS_f_f_fS5_param1;
FloatStream* getEnvelopeBounds_fS_f_f_fS5_param4;
getEnvelopeBounds_fS_f_f_fSStream* getEnvelopeBounds_fS_f_f_fS5;
double plot1[];
double plot2[];
double plot3[];
double customEnvelope[];
double customEnvelope_DEFAULT_VALUE;
ColoredStream* plot4;
ColoredStream* plot6;
double plot8[];
double plot9[];
double plot10[];

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
   IndicatorBuffers(13);
   int id = 0;
   customLookbackWindow = param1;
   customRelativeWeighting = param2;
   customStartRegressionBar = param3;
   customATRLength = param4;
   customNearATRFactor = param5;
   customFarATRFactor = param6;
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Red, 60));
   SetIndexBuffer(id, plot2);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Red, 80));
   SetIndexBuffer(id, plot3);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Red, 80));
   plot4 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot4.RegisterStream(id, AddTransparency(Teal, 50));
   id = plot4.RegisterStream(id, AddTransparency(Red, 50));
   plot6 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot6.RegisterStream(id, AddTransparency(Teal, 50));
   id = plot6.RegisterStream(id, AddTransparency(Red, 50));
   SetIndexBuffer(id, plot8);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Teal, 80));
   SetIndexBuffer(id, plot9);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Teal, 80));
   SetIndexBuffer(id, plot10);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Teal, 60));
   IndicatorObjPrefix = GenerateIndicatorPrefix("NW Envelope");
   IndicatorShortName("Nadaraya-Watson Envelope (Non -Repainting) Log Scale");
   customKernel_fS_i_f_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customKernel_fS_i_f_i1 = new customKernel_fS_i_f_iStream(customKernel_fS_i_f_i1_param1, customLookbackWindow, customRelativeWeighting, customStartRegressionBar);
   id = customKernel_fS_i_f_i1.Init(id);
   customKernel_fS_i_f_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customKernel_fS_i_f_i2 = new customKernel_fS_i_f_iStream(customKernel_fS_i_f_i2_param1, customLookbackWindow, customRelativeWeighting, customStartRegressionBar);
   id = customKernel_fS_i_f_i2.Init(id);
   customKernel_fS_i_f_i3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customKernel_fS_i_f_i3 = new customKernel_fS_i_f_iStream(customKernel_fS_i_f_i3_param1, customLookbackWindow, customRelativeWeighting, customStartRegressionBar);
   id = customKernel_fS_i_f_i3.Init(id);
   customATR_i_fS_fS_fS4_param2 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customATR_i_fS_fS_fS4_param3 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customATR_i_fS_fS_fS4_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   customATR_i_fS_fS_fS4 = new customATR_i_fS_fS_fSStream(customATRLength, customATR_i_fS_fS_fS4_param2, customATR_i_fS_fS_fS4_param3, customATR_i_fS_fS_fS4_param4);
   id = customATR_i_fS_fS_fS4.Init(id);
   getEnvelopeBounds_fS_f_f_fS5_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getEnvelopeBounds_fS_f_f_fS5_param4 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   getEnvelopeBounds_fS_f_f_fS5 = new getEnvelopeBounds_fS_f_f_fSStream(getEnvelopeBounds_fS_f_f_fS5_param1, customNearATRFactor, customFarATRFactor, getEnvelopeBounds_fS_f_f_fS5_param4);
   id = getEnvelopeBounds_fS_f_f_fS5.Init(id);
   SetIndexBuffer(id++, customEnvelope);
   id = plot4.RegisterInternalStream(id);
   id = plot6.RegisterInternalStream(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   customKernel_fS_i_f_i1_param1.Release();
   delete customKernel_fS_i_f_i1;
   customKernel_fS_i_f_i2_param1.Release();
   delete customKernel_fS_i_f_i2;
   customKernel_fS_i_f_i3_param1.Release();
   delete customKernel_fS_i_f_i3;
   customATR_i_fS_fS_fS4_param2.Release();
   customATR_i_fS_fS_fS4_param3.Release();
   customATR_i_fS_fS_fS4_param4.Release();
   delete customATR_i_fS_fS_fS4;
   getEnvelopeBounds_fS_f_f_fS5_param1.Release();
   getEnvelopeBounds_fS_f_f_fS5_param4.Release();
   delete getEnvelopeBounds_fS_f_f_fS5;
   delete plot4;
   delete plot6;
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
      customKernel_fS_i_f_i1_param1.Init();
      customKernel_fS_i_f_i1.Clear();
      customKernel_fS_i_f_i2_param1.Init();
      customKernel_fS_i_f_i2.Clear();
      customKernel_fS_i_f_i3_param1.Init();
      customKernel_fS_i_f_i3.Clear();
      customATR_i_fS_fS_fS4_param2.Init();
      customATR_i_fS_fS_fS4_param3.Init();
      customATR_i_fS_fS_fS4_param4.Init();
      customATR_i_fS_fS_fS4.Clear();
      getEnvelopeBounds_fS_f_f_fS5_param1.Init();
      getEnvelopeBounds_fS_f_f_fS5_param4.Init();
      getEnvelopeBounds_fS_f_f_fS5.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      customEnvelope_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(customEnvelope, customEnvelope_DEFAULT_VALUE);
      plot4.Init(EMPTY_VALUE);
      plot6.Init(EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
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
      customKernel_fS_i_f_i1_param1.SetValue(pos, MathLog(close[pos]));
      double customKernel_fS_i_f_i1Value;
      if (!customKernel_fS_i_f_i1.GetValue(pos, customKernel_fS_i_f_i1Value)) { customKernel_fS_i_f_i1Value = EMPTY_VALUE; }
      double customEnvelopeClose = SafeMathExp(customKernel_fS_i_f_i1Value);
      customKernel_fS_i_f_i2_param1.SetValue(pos, MathLog(high[pos]));
      double customKernel_fS_i_f_i2Value;
      if (!customKernel_fS_i_f_i2.GetValue(pos, customKernel_fS_i_f_i2Value)) { customKernel_fS_i_f_i2Value = EMPTY_VALUE; }
      double customEnvelopeHigh = SafeMathExp(customKernel_fS_i_f_i2Value);
      customKernel_fS_i_f_i3_param1.SetValue(pos, MathLog(low[pos]));
      double customKernel_fS_i_f_i3Value;
      if (!customKernel_fS_i_f_i3.GetValue(pos, customKernel_fS_i_f_i3Value)) { customKernel_fS_i_f_i3Value = EMPTY_VALUE; }
      double customEnvelopeLow = SafeMathExp(customKernel_fS_i_f_i3Value);
      SetStream(customEnvelope, pos, customEnvelopeClose, customEnvelope_DEFAULT_VALUE);
      customATR_i_fS_fS_fS4_param2.SetValue(pos, customEnvelopeHigh);
      customATR_i_fS_fS_fS4_param3.SetValue(pos, customEnvelopeLow);
      customATR_i_fS_fS_fS4_param4.SetValue(pos, customEnvelopeClose);
      double customATR_i_fS_fS_fS4Value;
      if (!customATR_i_fS_fS_fS4.GetValue(pos, customATR_i_fS_fS_fS4Value)) { customATR_i_fS_fS_fS4Value = EMPTY_VALUE; }
      double customATR = customATR_i_fS_fS_fS4Value;
      getEnvelopeBounds_fS_f_f_fS5_param1.SetValue(pos, customATR);
      getEnvelopeBounds_fS_f_f_fS5_param4.SetValue(pos, SafeLog(customEnvelopeClose));
      double getEnvelopeBounds_fS_f_f_fS5Value1;
      double getEnvelopeBounds_fS_f_f_fS5Value2;
      double getEnvelopeBounds_fS_f_f_fS5Value3;
      double getEnvelopeBounds_fS_f_f_fS5Value4;
      double getEnvelopeBounds_fS_f_f_fS5Value5;
      double getEnvelopeBounds_fS_f_f_fS5Value6;
      if (!getEnvelopeBounds_fS_f_f_fS5.GetValue(pos, getEnvelopeBounds_fS_f_f_fS5Value1, getEnvelopeBounds_fS_f_f_fS5Value2, getEnvelopeBounds_fS_f_f_fS5Value3, getEnvelopeBounds_fS_f_f_fS5Value4, getEnvelopeBounds_fS_f_f_fS5Value5, getEnvelopeBounds_fS_f_f_fS5Value6)) { getEnvelopeBounds_fS_f_f_fS5Value1 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value2 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value3 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value4 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value5 = EMPTY_VALUE; getEnvelopeBounds_fS_f_f_fS5Value6 = EMPTY_VALUE; }
      double customUpperNear = getEnvelopeBounds_fS_f_f_fS5Value1;
      double customUpperFar = getEnvelopeBounds_fS_f_f_fS5Value2;
      double customUpperAvg = getEnvelopeBounds_fS_f_f_fS5Value3;
      double customLowerNear = getEnvelopeBounds_fS_f_f_fS5Value4;
      double customLowerFar = getEnvelopeBounds_fS_f_f_fS5Value5;
      double customLowerAvg = getEnvelopeBounds_fS_f_f_fS5Value6;
      uint customUpperBoundaryColorFar = AddTransparency(Red, 60);
      uint customUpperBoundaryColorNear = AddTransparency(Red, 80);
      uint customBullishEstimatorColor = AddTransparency(Teal, 50);
      uint customBearishEstimatorColor = AddTransparency(Red, 50);
      uint customLowerBoundaryColorNear = AddTransparency(Teal, 80);
      uint customLowerBoundaryColorFar = AddTransparency(Teal, 60);
      color plot1_color = customUpperBoundaryColorFar;
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = SafeMathExp(customUpperFar); }
      else { plot1[pos] = EMPTY_VALUE; }
      double customUpperBoundaryFar = plot1[pos];
      color plot2_color = customUpperBoundaryColorNear;
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = SafeMathExp(customUpperAvg); }
      else { plot2[pos] = EMPTY_VALUE; }
      double customUpperBoundaryAvg = plot2[pos];
      color plot3_color = customUpperBoundaryColorNear;
      if (plot3_color != EMPTY_VALUE) { plot3[pos] = SafeMathExp(customUpperNear); }
      else { plot3[pos] = EMPTY_VALUE; }
      double customUpperBoundaryNear = plot3[pos];
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
plot4.SetByColor(customEnvelopeClose, pos, (SafeGreater(customEnvelope[pos], customEnvelope[pos + 1]) ? customBullishEstimatorColor : customBearishEstimatorColor));
      double customEstimationPlot = plot6.SetByColor(customEnvelopeClose, pos, (SafeGreater(customEnvelope[pos], customEnvelope[pos + 1]) ? customBullishEstimatorColor : customBearishEstimatorColor));
;
      color plot8_color = customLowerBoundaryColorNear;
      if (plot8_color != EMPTY_VALUE) { plot8[pos] = SafeMathExp(customLowerNear); }
      else { plot8[pos] = EMPTY_VALUE; }
      double customLowerBoundaryNear = plot8[pos];
      color plot9_color = customLowerBoundaryColorNear;
      if (plot9_color != EMPTY_VALUE) { plot9[pos] = SafeMathExp(customLowerAvg); }
      else { plot9[pos] = EMPTY_VALUE; }
      double customLowerBoundaryAvg = plot9[pos];
      color plot10_color = customLowerBoundaryColorFar;
      if (plot10_color != EMPTY_VALUE) { plot10[pos] = SafeMathExp(customLowerFar); }
      else { plot10[pos] = EMPTY_VALUE; }
      double customLowerBoundaryFar = plot10[pos];
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