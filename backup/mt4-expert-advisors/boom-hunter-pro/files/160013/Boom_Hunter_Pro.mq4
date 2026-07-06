//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76182

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
#property indicator_separate_window
#property indicator_buffers 58
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Quotient 1"
#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Quotient 2"
#property indicator_type7 DRAW_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Quotient 1"
#property indicator_type8 DRAW_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Quotient 1"
#property indicator_type9 DRAW_LINE
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Quotient 1"
#property indicator_type10 DRAW_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "Exit Warning"
#property indicator_type11 DRAW_ARROW
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_label12 "Exit Warning"
#property indicator_type12 DRAW_ARROW
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_label13 "Resistance"
#property indicator_type13 DRAW_LINE
#property indicator_color13 Red
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_label14 "Support"
#property indicator_type14 DRAW_LINE
#property indicator_color14 Silver
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_label15 "Support"
#property indicator_type15 DRAW_LINE
#property indicator_color15 Blue
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_label16 "Quotient 2"
#property indicator_type16 DRAW_LINE
#property indicator_color16 0xaaff00
#property indicator_style16 STYLE_SOLID
#property indicator_width16 2
#property indicator_label17 "Quotient 2"
#property indicator_type17 DRAW_LINE
#property indicator_color17 Purple
#property indicator_style17 STYLE_SOLID
#property indicator_width17 2
#property indicator_label18 "Quotient 2"
#property indicator_type18 DRAW_LINE
#property indicator_color18 Yellow
#property indicator_style18 STYLE_SOLID
#property indicator_width18 2
#property indicator_label19 "Quotient 2"
#property indicator_type19 DRAW_LINE
#property indicator_color19 White
#property indicator_style19 STYLE_SOLID
#property indicator_width19 2
#property indicator_label20 "Quotient 2"
#property indicator_type20 DRAW_LINE
#property indicator_color20 Red
#property indicator_style20 STYLE_SOLID
#property indicator_width20 2
#property indicator_label21 "Quotient 2"
#property indicator_type21 DRAW_LINE
#property indicator_color21 Gray
#property indicator_style21 STYLE_SOLID
#property indicator_width21 2
#property indicator_label22 "Quotient 2"
#property indicator_type22 DRAW_LINE
#property indicator_style22 STYLE_SOLID
#property indicator_width22 2
#property indicator_label23 "Quotient 1"
#property indicator_type23 DRAW_LINE
#property indicator_style23 STYLE_SOLID
#property indicator_width23 2
#property indicator_label24 "Pressure"
#property indicator_type24 DRAW_ARROW
#property indicator_color24 0xaaff00
#property indicator_style24 STYLE_SOLID
#property indicator_width24 2
#property indicator_label25 "Pressure"
#property indicator_type25 DRAW_ARROW
#property indicator_color25 Red
#property indicator_style25 STYLE_SOLID
#property indicator_width25 2
#property indicator_label26 "Pressure"
#property indicator_type26 DRAW_ARROW
#property indicator_style26 STYLE_SOLID
#property indicator_width26 2
#property indicator_label27 "Long gray"
#property indicator_type27 DRAW_ARROW
#property indicator_style27 STYLE_SOLID
#property indicator_width27 1
#property indicator_label28 "Long yellow"
#property indicator_type28 DRAW_ARROW
#property indicator_style28 STYLE_SOLID
#property indicator_width28 1
#property indicator_label29 "Long blue"
#property indicator_type29 DRAW_ARROW
#property indicator_style29 STYLE_SOLID
#property indicator_width29 1
#property indicator_label30 "Long Lime"
#property indicator_type30 DRAW_ARROW
#property indicator_style30 STYLE_SOLID
#property indicator_width30 1
#property indicator_label31 "Break"
#property indicator_type31 DRAW_ARROW
#property indicator_style31 STYLE_SOLID
#property indicator_width31 1
#property indicator_label32 "Break"
#property indicator_type32 DRAW_ARROW
#property indicator_style32 STYLE_SOLID
#property indicator_width32 1
#property indicator_type57 DRAW_ARROW
#property indicator_color57 Yellow
#property indicator_style57 STYLE_SOLID
#property indicator_width57 1
#property indicator_type58 DRAW_ARROW
#property indicator_color58 Yellow
#property indicator_style58 STYLE_SOLID
#property indicator_width58 1

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
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return MathCeil(value);
}
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
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract integer stream v1.0

#ifndef TAStream_IMPL
#define TAStream_IMPL


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


// EMA on stream v3.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public TIStream<double>
{
   TIStream<double>* _source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(TIStream<double>* source, const int length)
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

// Sum on stream v2.0

class SumOnStream : public AOnStream
{
   double _buffer[];
   int _length;
public:
   SumOnStream(TIStream<double>* source, int length)
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
// Change stream v2.0

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

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
// v2.0
// Wraps IBoolStream and provides TIStream<double>

#ifndef BoolToFloatStreamWrapper_IMPL
#define BoolToFloatStreamWrapper_IMPL

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
   virtual bool GetValue(const int period, int &val) = 0;
};

#endif

class BoolToFloatStreamWrapper : public TAStream<double>
{
   IBoolStream* _source;
public:
   BoolToFloatStreamWrapper(IBoolStream* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~BoolToFloatStreamWrapper()
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
// v2.0
// Wraps IDateTimeStream and provides TIStream<double>

#ifndef DateTimeToFloatStreamWrapper_IMPL
#define DateTimeToFloatStreamWrapper_IMPL



class DateTimeToFloatStreamWrapper : public TAStream<double>
{
   TIStream<datetime>* _source;
public:
   DateTimeToFloatStreamWrapper(TIStream<datetime>* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~DateTimeToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   bool GetValue(const int period, double &val)
   {
      datetime intVal;
      if (!_source.GetValue(period, intVal))
      {
         return false;
      }
      val = intVal;
      return true;
   }
};
#endif

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(TIStream<double>* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   ChangeStream(IIntStream* stream, int period = 1)
      :AOnStream(new IntToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }
   
   ChangeStream(IBoolStream* stream, int period = 1)
      :AOnStream(new BoolToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }
   
   ChangeStream(TIStream<datetime>* stream, int period = 1)
      :AOnStream(new DateTimeToFloatStreamWrapper(stream))
   {
      _source.Release();
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


// Stream base v2.0



#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public TIStream<double>
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

// RSI stream v2.0

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSISimpleStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSISimpleStream(TIStream<double>* stream, int period)
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

class PineScriptRSIUpDownStream : public AStreamBase
{
   TIStream<double>* _up;
   TIStream<double>* _down;
public:
   PineScriptRSIUpDownStream(TIStream<double>* up, TIStream<double>* down)
   {
      _up = up;
      _up.AddRef();
      _down = down;
      _down.AddRef();
   }
   ~PineScriptRSIUpDownStream()
   {
      _up.Release();
      _down.Release();
   }
   
   virtual int Size()
   {
      return _up.Size();
   }

   virtual bool GetValue(const int period, double &val)
   {
      double up;
      double down;
      if (!_up.GetValue(period, up) || !_down.GetValue(period, down))
      {
         return false;
      }
      if (down == 0)
      {
         val = 0;
         return true;
      }
      double rs = up / down;
      val = 100 - 100.0 / (1.0 + rs);
      return true;
   }
};

class RSIStream : public AStreamBase
{
   TIStream<double>* _impl;
public:
   RSIStream(TIStream<double>* stream, int period)
   {
      _impl = new RSISimpleStream(stream, period);
   }

   RSIStream(TIStream<double>* up, TIStream<double>* down)
   {
      _impl = new PineScriptRSIUpDownStream(up, down);
   }

   ~RSIStream()
   {
      _impl.Release();
   }
   
   virtual int Size()
   {
      return _impl.Size();
   }

   virtual bool GetValue(const int period, double &val)
   {
      return _impl.GetValue(period, val);
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

//LinearRegressionOnStream v2.0

class LinearRegressionOnStream : public AOnStream
{
   double _length;
   double _buffer[];
   int _offset;
public:
   LinearRegressionOnStream(TIStream<double> *source, const int length, int offset = 0)
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
         for (int i = range; i < size; ++i)
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
// PlotShape v1.2
#ifndef PlotShape_IMPL
#define PlotShape_IMPL

class PlotShape
{
private:
   static void SetNA(double& plot[], int period)
   {
      plot[period] = EMPTY_VALUE;
   }
   
   static void SetValue(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift)
   {
      if (location == "abovebar" || location == "top")
      {
         plot[period] = high[period + shift];
         return;
      }
      if (location == "belowbar" || location == "bottom")
      {
         plot[period] = low[period + shift];
         return;
      }
      plot[period] = seriesValue;
   }
public:
   static void Set(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == EMPTY_VALUE)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void Set(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == INT_MIN)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void SetBool(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == -1 || seriesValue == 0)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
};

#endif
#ifndef FixnanStream_IMP
#define FixnanStream_IMP
// Fix NAN stream v2.0



class FixnanStream : public AOnStream
{
   int _maxLookback;
public:
   FixnanStream(TIStream<double>* source)
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
   static TIStream<double>* Create(TIStream<double>* source)
   {
      return new FixnanStream(source);
   }
};
#endif
// Pivot high stream v2.0


// Simple price stream v1.2

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

   static bool GetValue(const int period, double &val, string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValue(period, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int leftBars, int rightBars)
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

   
   static bool GetValue(const int period, double &val, string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValue(period, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }

   static bool GetValue(const int period, double &val, TIStream<double>* source, int leftBars, int rightBars)
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
#ifndef BarsSinceStreamV2_IMPL
#define BarsSinceStreamV2_IMPL

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


// Counts number of bars since last condition.
// v2.0

class BarsSinceStreamV2 : public AIntStream
{
   TIStream<int>* _condition;
   int _bars[];
public:
   BarsSinceStreamV2(TIStream<int>* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~BarsSinceStreamV2()
   {
      _condition.Release();
   }

   int Size()
   {
      return _condition.Size();
   }

   virtual bool GetValue(const int period, int &val)
   {
      int size = Size();
      if (period >= size)
      {
         return false;
      }
      if (ArraySize(_bars) < size)
      {
         ArrayResize(_bars, size);
      }
      int index = size - period - 1;
      if (_bars[index] == 0)
      {
         FillHistory(period);
      }
      val = _bars[index];
      return val != INT_MIN;
   }
private:
   void FillHistory(int period)
   {
      int size = Size();
      for (int periodIndex = period; periodIndex < size; ++periodIndex)
      {
         int index = size - periodIndex - 1;
         int val;
         if (!_condition.GetValue(periodIndex, val) || val == INT_MIN)
         {
            if (_bars[index] == 0)
            {
               continue;
            }
         }
         else
         {
            _bars[index] = 0;
         }
         for (int ii = index + 1; ii <= size - period - 1; ++ii)
         {
            _bars[ii] = _bars[ii - 1] + 1;
         }
         return;
      }
   }
};
#endif
// Candles stream v.1.5
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
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
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
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
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
      int size = ArraySize(OpenStream);
      if (index < 0 || index >= size)
      {
         return;
      }
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
//Signaler v2.2
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
public:
   Signaler(string frequency)
   {
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

input bool param1 = false; // Show Fibonacci Lines?
input bool param2 = true; // Show Entry and Exit Points?
input bool param3 = true; // Square Line?
input bool param4 = true; // Show Downward Boom Line?
input bool param5 = true; // Show Long Entries?
input bool param6 = true; // Show Short Entries?
input int param7 = 6; // Quotient | LPPeriod
input int param8 = 0; // K1
input int param9 = 2; // Trigger Length
input color param10 = Blue; // Oscillator Color:
input color param11 = White; // Trigger Color:
input int param12 = 27; // LPPeriod2
input double param13 = 0.8; // K1
input double param14 = 0.3; // K2
input color param15 = Red; // Line Color:
input color param16 = Red; // Fill Color:
input int param17 = 11; // LPPeriod3
input double param18 = 0.99; // K1
input color param19 = Yellow; // Line Color:
input int param20 = 9; // WT | master
input int param21 = 6; // time 1
input int param22 = 3; // 2
input int param23 = 21; // LSMA | 1
input int param24 = 0; // 2
input int param25 = 200; // LSMA Long
input bool param26 = false; // Show Break Lines?
input int param27 = 1; // Resistance | Left Bars 
input int param28 = 1; // Right Bars
input int param29 = 5; // Support (Long) | Left Bars 
input int param30 = 5; // Right Bars
input int param31 = 1; // Support (Short) |Left Bars 
input int param32 = 1; // Right Bars
input int param33 = 3;
input bool param34 = false; // Show Bar Colors?
input bool param35 = false; // Show Pump Bar Colors?
input int bars_limit = 100000; // Bars limit
Signaler* _signaler;
string title;
string stitle;
string version;
int showfib;
int showentry;
int square;
int showdboom;
int showlongs;
int showshorts;
int LPPeriod;
int K1;
int trigno;
uint osccol;
uint trigcol;
int LPPeriod2;
double K12;
double K22;
uint osccol2;
uint osccol22;
int LPPeriod3;
double K13;
uint osccol3;
int n1;
int n2;
int n3;
int n4;
int n5;
int lsmaline;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double HP[];
double HP_DEFAULT_VALUE;
double Filt[];
double Filt_DEFAULT_VALUE;
double Peak[];
double Peak_DEFAULT_VALUE;
double HP2[];
double HP2_DEFAULT_VALUE;
double Filt2[];
double Filt2_DEFAULT_VALUE;
double Peak2[];
double Peak2_DEFAULT_VALUE;
double HP3[];
double HP3_DEFAULT_VALUE;
double Filt3[];
double Filt3_DEFAULT_VALUE;
double Peak3[];
double Peak3_DEFAULT_VALUE;
TIStream<double>* tr1;
class tci_fSStream
{
   TIStream<double>* src;
   FloatStream* ema1Source;
   EMAOnStream* ema1;
   FloatStream* ema2Source;
   EMAOnStream* ema2;
   FloatStream* ema3Source;
   EMAOnStream* ema3;
   FloatStream* ema4Source;
   EMAOnStream* ema4;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   tci_fSStream(TIStream<double>* src, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.src = src;
      src.AddRef();
      ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema2 = new EMAOnStream(ema2Source, n1);
      ema4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema4 = new EMAOnStream(ema4Source, n1);
      ema3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema3 = new EMAOnStream(ema3Source, n1);
      ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ema1 = new EMAOnStream(ema1Source, n2);
   }
   ~tci_fSStream()
   {
      src.Release();
      ema1Source.Release();
      ema1.Release();
      ema2Source.Release();
      ema2.Release();
      ema3Source.Release();
      ema3.Release();
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
         ema2Source.Init();
         ema4Source.Init();
         ema3Source.Init();
         ema1Source.Init();
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      ema2Source.SetValue(pos, srcValue);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      ema4Source.SetValue(pos, srcValue);
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value)) { ema4Value = EMPTY_VALUE; }
      ema3Source.SetValue(pos, SafeMathAbs(SafeMinus(srcValue, ema4Value)));
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { ema3Value = EMPTY_VALUE; }
      ema1Source.SetValue(pos, SafeDivide((SafeMinus(srcValue, ema2Value)), (SafeMultiply(0.025, ema3Value))));
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      __out1 = SafePlus(ema1Value, 50);
      return true;
   }
};
class mf_fSStream
{
   TIStream<double>* src;
   FloatStream* sum1Source;
   SumOnStream* sum1;
   FloatStream* change1Source;
   ChangeStream* change1;
   FloatStream* sum2Source;
   SumOnStream* sum2;
   FloatStream* change2Source;
   ChangeStream* change2;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   mf_fSStream(TIStream<double>* src, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.src = src;
      src.AddRef();
      change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      change1 = new ChangeStream(change1Source, 1);
      sum1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sum1 = new SumOnStream(sum1Source, n3);
      change2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      change2 = new ChangeStream(change2Source, 1);
      sum2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sum2 = new SumOnStream(sum2Source, n3);
   }
   ~mf_fSStream()
   {
      src.Release();
      sum1Source.Release();
      sum1.Release();
      change1Source.Release();
      change1.Release();
      sum2Source.Release();
      sum2.Release();
      change2Source.Release();
      change2.Release();
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
         change1Source.Init();
         sum1Source.Init();
         change2Source.Init();
         sum2Source.Init();
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      change1Source.SetValue(pos, srcValue);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      sum1Source.SetValue(pos, iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) * ((SafeLE(change1Value, 0) ? 0 : srcValue)));
      double sum1Value;
      if (!sum1.GetValue(pos, sum1Value)) { sum1Value = EMPTY_VALUE; }
      change2Source.SetValue(pos, srcValue);
      double change2Value;
      if (!change2.GetValue(pos, change2Value)) { change2Value = EMPTY_VALUE; }
      sum2Source.SetValue(pos, iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) * ((SafeGE(change2Value, 0) ? 0 : srcValue)));
      double sum2Value;
      if (!sum2.GetValue(pos, sum2Value)) { sum2Value = EMPTY_VALUE; }
      __out1 = SafeMinus(100.0, SafeDivide(100.0, (SafePlus(1.0, SafeDivide(sum1Value, sum2Value)))));
      return true;
   }
};
class tradition_fSStream
{
   TIStream<double>* src;
   FloatStream* tci_fS1_param1;
   tci_fSStream* tci_fS1;
   FloatStream* mf_fS2_param1;
   mf_fSStream* mf_fS2;
   FloatStream* rsi1X;
   RSIStream* rsi1;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   tradition_fSStream(TIStream<double>* src, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.src = src;
      src.AddRef();
      rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      rsi1 = new RSIStream(rsi1X, n3);
   }
   ~tradition_fSStream()
   {
      src.Release();
      tci_fS1_param1.Release();
      delete tci_fS1;
      mf_fS2_param1.Release();
      delete mf_fS2;
      rsi1X.Release();
      rsi1.Release();
   }
   int Init(int id)
   {
      tci_fS1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
      tci_fS1 = new tci_fSStream(tci_fS1_param1, IndicatorObjPrefix + "_1");
      id = tci_fS1.Init(id);
      mf_fS2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
      mf_fS2 = new mf_fSStream(mf_fS2_param1, IndicatorObjPrefix + "_2");
      id = mf_fS2.Init(id);
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
         tci_fS1_param1.Init();
         tci_fS1.Clear();
         mf_fS2_param1.Init();
         mf_fS2.Clear();
         rsi1X.Init();
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      tci_fS1_param1.SetValue(pos, srcValue);
      double tci_fS1Value;
      if (!tci_fS1.GetValue(pos, tci_fS1Value)) { tci_fS1Value = EMPTY_VALUE; }
      mf_fS2_param1.SetValue(pos, srcValue);
      double mf_fS2Value;
      if (!mf_fS2.GetValue(pos, mf_fS2Value)) { mf_fS2Value = EMPTY_VALUE; }
      rsi1X.SetValue(pos, srcValue);
      double rsi1Value;
      if (!rsi1.GetValue(pos, rsi1Value)) { rsi1Value = EMPTY_VALUE; }
      __out1 = SafeDivide((SafePlus(SafePlus(tci_fS1Value, mf_fS2Value), rsi1Value)), 3);
      return true;
   }
};
FloatStream* tradition_fS3_param1;
tradition_fSStream* tradition_fS3;
FloatStream* sma1Source;
SmaOnStream* sma1;
FloatStream* linreg1Source;
LinearRegressionOnStream* linreg1;
FloatStream* ema5Source;
EMAOnStream* ema5;
FloatStream* sma2Source;
SmaOnStream* sma2;
double plot6[];
double plot7[];
FloatStream* sma3Source;
SmaOnStream* sma3;
FloatStream* linreg2Source;
LinearRegressionOnStream* linreg2;
double plot8[];
ColoredStream* plot9;
FloatStream* sma4Source;
SmaOnStream* sma4;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
TIStream<int>* crossunder1;
FloatStream* cross1X;
FloatStream* cross1Y;
TIStream<int>* cross1;
FloatStream* cross2X;
FloatStream* cross2Y;
TIStream<int>* cross2;
FloatStream* crossover1X;
FloatStream* crossover1Y;
TIStream<int>* crossover1;
FloatStream* cross3X;
FloatStream* cross3Y;
TIStream<int>* cross3;
FloatStream* crossover2X;
FloatStream* crossover2Y;
TIStream<int>* crossover2;
double plot11[];
double plot12[];
int toggleBreaks;
int leftBars;
int rightBars;
int leftBars2;
int rightBars2;
int leftBars3;
int rightBars3;
FloatStream* fixnan1X;
TIStream<double>* fixnan1;
FloatStream* highestpivot1Source;
double methodReturnedValue1[];
double methodReturnedValue1_DEFAULT_VALUE;
FloatStream* fixnan2X;
TIStream<double>* fixnan2;
FloatStream* lowestpivot1Source;
double methodReturnedValue2[];
double methodReturnedValue2_DEFAULT_VALUE;
FloatStream* fixnan3X;
TIStream<double>* fixnan3;
FloatStream* lowestpivot2Source;
double methodReturnedValue3[];
double methodReturnedValue3_DEFAULT_VALUE;
FloatStream* fixnan4X;
TIStream<double>* fixnan4;
FloatStream* highestpivot2Source;
double methodReturnedValue4[];
double methodReturnedValue4_DEFAULT_VALUE;
double plot13[];
FloatStream* change3Source;
ChangeStream* change3;
double plot14[];
FloatStream* change4Source;
ChangeStream* change4;
double plot15[];
FloatStream* change5Source;
ChangeStream* change5;
FloatStream* crossover3X;
FloatStream* crossover3Y;
TIStream<int>* crossover3;
FloatStream* crossunder2X;
FloatStream* crossunder2Y;
TIStream<int>* crossunder2;
double ubreak[];
double ubreak_DEFAULT_VALUE;
double ubreak2[];
double ubreak2_DEFAULT_VALUE;
double dbreak[];
double dbreak_DEFAULT_VALUE;
double cont[];
double cont_DEFAULT_VALUE;
double cont2[];
double cont2_DEFAULT_VALUE;
double pull[];
double pull_DEFAULT_VALUE;
double dbreak2[];
double dbreak2_DEFAULT_VALUE;
double cross[];
double cross_DEFAULT_VALUE;
FloatStream* crossunder3X;
FloatStream* crossunder3Y;
TIStream<int>* crossunder3;
FloatStream* linreg3Source;
LinearRegressionOnStream* linreg3;
double drag[];
double drag_DEFAULT_VALUE;
FloatStream* crossover4X;
FloatStream* crossover4Y;
TIStream<int>* crossover4;
FloatStream* crossover5X;
FloatStream* crossover5Y;
TIStream<int>* crossover5;
int dragno;
FloatStream* crossover6X;
FloatStream* crossover6Y;
TIStream<int>* crossover6;
FloatStream* crossover7X;
FloatStream* crossover7Y;
TIStream<int>* crossover7;
FloatStream* crossunder4X;
FloatStream* crossunder4Y;
TIStream<int>* crossunder4;
FloatStream* crossunder5X;
FloatStream* crossunder5Y;
TIStream<int>* crossunder5;
FloatStream* crossunder6X;
FloatStream* crossunder6Y;
TIStream<int>* crossunder6;
ColoredStream* plot16;
double plot22[];
double plot23[];
ColoredStream* plot24;
FloatStream* crossover8X;
FloatStream* crossover8Y;
TIStream<int>* crossover8;
FloatStream* crossover9X;
FloatStream* crossover9Y;
TIStream<int>* crossover9;
FloatStream* crossunder7X;
FloatStream* crossunder7Y;
TIStream<int>* crossunder7;
FloatStream* crossover10X;
FloatStream* crossover10Y;
TIStream<int>* crossover10;
BoolStream* barssince1Condition;
BarsSinceStreamV2* barssince1;
FloatStream* crossover11X;
FloatStream* crossover11Y;
TIStream<int>* crossover11;
BoolStream* barssince2Condition;
BarsSinceStreamV2* barssince2;
BoolStream* barssince3Condition;
BarsSinceStreamV2* barssince3;
FloatStream* crossover12X;
FloatStream* crossover12Y;
TIStream<int>* crossover12;
FloatStream* crossover13X;
FloatStream* crossover13Y;
TIStream<int>* crossover13;
BoolStream* barssince4Condition;
BarsSinceStreamV2* barssince4;
FloatStream* crossover14X;
FloatStream* crossover14Y;
TIStream<int>* crossover14;
BoolStream* barssince5Condition;
BarsSinceStreamV2* barssince5;
FloatStream* crossunder8X;
FloatStream* crossunder8Y;
TIStream<int>* crossunder8;
FloatStream* crossover15X;
FloatStream* crossover15Y;
TIStream<int>* crossover15;
BoolStream* barssince6Condition;
BarsSinceStreamV2* barssince6;
FloatStream* crossunder9X;
FloatStream* crossunder9Y;
TIStream<int>* crossunder9;
FloatStream* crossover16X;
FloatStream* crossover16Y;
TIStream<int>* crossover16;
FloatStream* crossover17X;
FloatStream* crossover17Y;
TIStream<int>* crossover17;
FloatStream* crossunder10X;
FloatStream* crossunder10Y;
TIStream<int>* crossunder10;
BoolStream* barssince7Condition;
BarsSinceStreamV2* barssince7;
BoolStream* barssince8Condition;
BarsSinceStreamV2* barssince8;
FloatStream* crossover18X;
FloatStream* crossover18Y;
TIStream<int>* crossover18;
double plot27[];
double plot28[];
double plot29[];
double plot30[];
double plot31[];
double plot32[];
FloatStream* crossover19X;
FloatStream* crossover19Y;
TIStream<int>* crossover19;
int allbars;
int barc;
CandleStreams* barcolor1;
CandleStreams* barcolor2;
double plot57[];
BoolStream* barssince9Condition;
BarsSinceStreamV2* barssince9;
FloatStream* crossover20X;
FloatStream* crossover20Y;
TIStream<int>* crossover20;
FloatStream* crossunder11X;
FloatStream* crossunder11Y;
TIStream<int>* crossunder11;
double plot58[];
BoolStream* barssince10Condition;
BarsSinceStreamV2* barssince10;
FloatStream* crossunder12X;
FloatStream* crossunder12Y;
TIStream<int>* crossunder12;
FloatStream* crossover21X;
FloatStream* crossover21Y;
TIStream<int>* crossover21;
FloatStream* crossunder13X;
FloatStream* crossunder13Y;
TIStream<int>* crossunder13;
FloatStream* crossover22X;
FloatStream* crossover22Y;
TIStream<int>* crossover22;
FloatStream* crossunder14X;
FloatStream* crossunder14Y;
TIStream<int>* crossunder14;
FloatStream* crossover23X;
FloatStream* crossover23Y;
TIStream<int>* crossover23;
BoolStream* barssince11Condition;
BarsSinceStreamV2* barssince11;
FloatStream* crossover24X;
FloatStream* crossover24Y;
TIStream<int>* crossover24;
FloatStream* crossunder15X;
FloatStream* crossunder15Y;
TIStream<int>* crossunder15;
BoolStream* barssince12Condition;
BarsSinceStreamV2* barssince12;
FloatStream* crossunder16X;
FloatStream* crossunder16Y;
TIStream<int>* crossunder16;
FloatStream* crossover25X;
FloatStream* crossover25Y;
TIStream<int>* crossover25;

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
   IndicatorBuffers(83);
   showfib = param1;
   showentry = param2;
   square = param3;
   showdboom = param4;
   showlongs = param5;
   showshorts = param6;
   LPPeriod = param7;
   K1 = param8;
   trigno = param9;
   osccol = param10;
   trigcol = param11;
   LPPeriod2 = param12;
   K12 = param13;
   K22 = param14;
   osccol2 = param15;
   osccol22 = param16;
   LPPeriod3 = param17;
   K13 = param18;
   osccol3 = param19;
   n1 = param20;
   n2 = param21;
   n3 = param22;
   n4 = param23;
   n5 = param24;
   lsmaline = param25;
   int id = 0;
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Blue, 50));
   SetIndexBuffer(id, plot2);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Blue, 50));
   SetIndexBuffer(id, plot3);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Blue, 50));
   SetIndexBuffer(id, plot4);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Blue, 50));
   SetIndexBuffer(id, plot5);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Blue, 50));
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = new SmaOnStream(sma1Source, 6);
   linreg1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   linreg1 = new LinearRegressionOnStream(linreg1Source, n4, n5);
   ema5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema5 = new EMAOnStream(ema5Source, n3);
   int smalen = 2;
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = new SmaOnStream(sma2Source, smalen);
   SetIndexBuffer(id, plot6);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Red, 50));
   SetIndexBuffer(id, plot7);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Red, 50));
   sma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma3 = new SmaOnStream(sma3Source, trigno);
   linreg2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   linreg2 = new LinearRegressionOnStream(linreg2Source, lsmaline, 0);
   SetIndexBuffer(id, plot8);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, AddTransparency(Blue, 0));
   plot9 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot9.RegisterStream(id, AddTransparency(Orange, 0));
   id = plot9.RegisterStream(id, AddTransparency(Yellow, 0));
   sma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma4 = new SmaOnStream(sma4Source, 200);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   cross1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1 = CrossStreamFactory::CreateCross(cross1X, cross1Y);
   cross2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross2 = CrossStreamFactory::CreateCross(cross2X, cross2Y);
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   cross3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross3 = CrossStreamFactory::CreateCross(cross3X, cross3Y);
   crossover2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover2 = CrossStreamFactory::CreateCrossover(crossover2X, crossover2Y);
   SetIndexBuffer(id, plot11);
   SetIndexArrow(id, 161);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Orange, 0));
   SetIndexBuffer(id, plot12);
   SetIndexArrow(id, 161);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Red, 0));
   toggleBreaks = param26;
   leftBars = param27;
   rightBars = param28;
   leftBars2 = param29;
   rightBars2 = param30;
   leftBars3 = param31;
   rightBars3 = param32;
   highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan1 = FixnanStreamFactory::Create(fixnan1X);
   lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan2 = FixnanStreamFactory::Create(fixnan2X);
   lowestpivot2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan3 = FixnanStreamFactory::Create(fixnan3X);
   highestpivot2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   fixnan4 = FixnanStreamFactory::Create(fixnan4X);
   change3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change3 = new ChangeStream(change3Source, 1);
   SetIndexBuffer(id, plot13);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Red);
   change4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change4 = new ChangeStream(change4Source, 1);
   SetIndexBuffer(id, plot14);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Silver);
   change5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change5 = new ChangeStream(change5Source, 1);
   SetIndexBuffer(id, plot15);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Blue);
   crossover3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover3 = CrossStreamFactory::CreateCrossover(crossover3X, crossover3Y);
   crossunder2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder2 = CrossStreamFactory::CreateCrossunder(crossunder2X, crossunder2Y);
   crossunder3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder3 = CrossStreamFactory::CreateCrossunder(crossunder3X, crossunder3Y);
   linreg3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   linreg3 = new LinearRegressionOnStream(linreg3Source, 20, 0);
   crossover4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover4Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover4 = CrossStreamFactory::CreateCrossover(crossover4X, crossover4Y);
   crossover5X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover5Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover5 = CrossStreamFactory::CreateCrossover(crossover5X, crossover5Y);
   dragno = param33;
   crossover6X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover6Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover6 = CrossStreamFactory::CreateCrossover(crossover6X, crossover6Y);
   crossover7X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover7Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover7 = CrossStreamFactory::CreateCrossover(crossover7X, crossover7Y);
   crossunder4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder4Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder4 = CrossStreamFactory::CreateCrossunder(crossunder4X, crossunder4Y);
   crossunder5X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder5Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder5 = CrossStreamFactory::CreateCrossunder(crossunder5X, crossunder5Y);
   crossunder6X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder6Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder6 = CrossStreamFactory::CreateCrossunder(crossunder6X, crossunder6Y);
   plot16 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot16.RegisterStream(id, 0xaaff00);
   id = plot16.RegisterStream(id, Purple);
   id = plot16.RegisterStream(id, Yellow);
   id = plot16.RegisterStream(id, White);
   id = plot16.RegisterStream(id, Red);
   id = plot16.RegisterStream(id, Gray);
   SetIndexBuffer(id, plot22);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 2, osccol);
   SetIndexBuffer(id, plot23);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 2, trigcol);
   plot24 = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = plot24.RegisterArrowStream(id, 0xaaff00, 161);
   id = plot24.RegisterArrowStream(id, Red, 161);
   id = plot24.RegisterArrowStream(id, INT_MAX, 161);
   crossover8X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover8Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover8 = CrossStreamFactory::CreateCrossover(crossover8X, crossover8Y);
   crossover9X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover9Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover9 = CrossStreamFactory::CreateCrossover(crossover9X, crossover9Y);
   crossunder7X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder7Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder7 = CrossStreamFactory::CreateCrossunder(crossunder7X, crossunder7Y);
   crossover10X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover10Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover10 = CrossStreamFactory::CreateCrossover(crossover10X, crossover10Y);
   barssince1Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince1 = new BarsSinceStreamV2(barssince1Condition);
   crossover11X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover11Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover11 = CrossStreamFactory::CreateCrossover(crossover11X, crossover11Y);
   barssince2Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince2 = new BarsSinceStreamV2(barssince2Condition);
   crossover12X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover12Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover12 = CrossStreamFactory::CreateCrossover(crossover12X, crossover12Y);
   barssince3Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince3 = new BarsSinceStreamV2(barssince3Condition);
   crossover13X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover13Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover13 = CrossStreamFactory::CreateCrossover(crossover13X, crossover13Y);
   barssince4Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince4 = new BarsSinceStreamV2(barssince4Condition);
   crossover14X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover14Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover14 = CrossStreamFactory::CreateCrossover(crossover14X, crossover14Y);
   crossunder8X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder8Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder8 = CrossStreamFactory::CreateCrossunder(crossunder8X, crossunder8Y);
   barssince5Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince5 = new BarsSinceStreamV2(barssince5Condition);
   crossover15X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover15Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover15 = CrossStreamFactory::CreateCrossover(crossover15X, crossover15Y);
   crossunder9X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder9Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder9 = CrossStreamFactory::CreateCrossunder(crossunder9X, crossunder9Y);
   barssince6Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince6 = new BarsSinceStreamV2(barssince6Condition);
   crossover16X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover16Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover16 = CrossStreamFactory::CreateCrossover(crossover16X, crossover16Y);
   crossover17X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover17Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover17 = CrossStreamFactory::CreateCrossover(crossover17X, crossover17Y);
   crossunder10X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder10Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder10 = CrossStreamFactory::CreateCrossunder(crossunder10X, crossunder10Y);
   barssince7Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince7 = new BarsSinceStreamV2(barssince7Condition);
   crossover18X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover18Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover18 = CrossStreamFactory::CreateCrossover(crossover18X, crossover18Y);
   barssince8Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince8 = new BarsSinceStreamV2(barssince8Condition);
   SetIndexBuffer(id, plot27);
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Silver, 20));
   SetIndexBuffer(id, plot28);
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Yellow, 20));
   SetIndexBuffer(id, plot29);
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Blue, 20));
   SetIndexBuffer(id, plot30);
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Lime, 20));
   SetIndexBuffer(id, plot31);
   SetIndexArrow(id, 242);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(Red, 20));
   SetIndexBuffer(id, plot32);
   SetIndexArrow(id, 217);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, AddTransparency(0xaaff00, 0));
   crossover19X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover19Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover19 = CrossStreamFactory::CreateCrossover(crossover19X, crossover19Y);
   allbars = param34;
   barc = param35;
   barcolor1 = new CandleStreams();
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id, Purple);
   id = barcolor1.RegisterStreams(id, White);
   id = barcolor1.RegisterStreams(id, Yellow);
   barcolor2 = new CandleStreams();
   barcolor2.SetOffset(0);
   id = barcolor2.RegisterStreams(id, 0xaaff00);
   id = barcolor2.RegisterStreams(id, Red);
   id = barcolor2.RegisterStreams(id, Gray);
   SetIndexBuffer(id, plot57);
   SetIndexArrow(id++, 218);
   crossover20X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover20Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover20 = CrossStreamFactory::CreateCrossover(crossover20X, crossover20Y);
   barssince9Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince9 = new BarsSinceStreamV2(barssince9Condition);
   crossunder11X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder11Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder11 = CrossStreamFactory::CreateCrossunder(crossunder11X, crossunder11Y);
   SetIndexBuffer(id, plot58);
   SetIndexArrow(id++, 217);
   crossunder12X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder12Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder12 = CrossStreamFactory::CreateCrossunder(crossunder12X, crossunder12Y);
   barssince10Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince10 = new BarsSinceStreamV2(barssince10Condition);
   crossover21X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover21Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover21 = CrossStreamFactory::CreateCrossover(crossover21X, crossover21Y);
   crossunder13X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder13Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder13 = CrossStreamFactory::CreateCrossunder(crossunder13X, crossunder13Y);
   crossover22X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover22Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover22 = CrossStreamFactory::CreateCrossover(crossover22X, crossover22Y);
   crossunder14X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder14Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder14 = CrossStreamFactory::CreateCrossunder(crossunder14X, crossunder14Y);
   crossover23X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover23Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover23 = CrossStreamFactory::CreateCrossover(crossover23X, crossover23Y);
   crossover24X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover24Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover24 = CrossStreamFactory::CreateCrossover(crossover24X, crossover24Y);
   barssince11Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince11 = new BarsSinceStreamV2(barssince11Condition);
   crossunder15X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder15Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder15 = CrossStreamFactory::CreateCrossunder(crossunder15X, crossunder15Y);
   crossunder16X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder16Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder16 = CrossStreamFactory::CreateCrossunder(crossunder16X, crossunder16Y);
   barssince12Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   barssince12 = new BarsSinceStreamV2(barssince12Condition);
   crossover25X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover25Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover25 = CrossStreamFactory::CreateCrossover(crossover25X, crossover25Y);
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix(stitle);
   IndicatorShortName(title + version);
   SetIndexBuffer(id++, HP);
   SetIndexBuffer(id++, Filt);
   SetIndexBuffer(id++, Peak);
   SetIndexBuffer(id++, HP2);
   SetIndexBuffer(id++, Filt2);
   SetIndexBuffer(id++, Peak2);
   SetIndexBuffer(id++, HP3);
   SetIndexBuffer(id++, Filt3);
   SetIndexBuffer(id++, Peak3);
   tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   tradition_fS3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period, EMPTY_VALUE);
   tradition_fS3 = new tradition_fSStream(tradition_fS3_param1, IndicatorObjPrefix + "_3");
   id = tradition_fS3.Init(id);
   id = plot9.RegisterInternalStream(id);
   SetIndexBuffer(id++, methodReturnedValue1);
   SetIndexBuffer(id++, methodReturnedValue2);
   SetIndexBuffer(id++, methodReturnedValue3);
   SetIndexBuffer(id++, methodReturnedValue4);
   SetIndexBuffer(id++, ubreak);
   SetIndexBuffer(id++, ubreak2);
   SetIndexBuffer(id++, dbreak);
   SetIndexBuffer(id++, cont);
   SetIndexBuffer(id++, cont2);
   SetIndexBuffer(id++, pull);
   SetIndexBuffer(id++, dbreak2);
   SetIndexBuffer(id++, cross);
   SetIndexBuffer(id++, drag);
   id = plot16.RegisterInternalStream(id);
   id = plot24.RegisterInternalStream(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   tr1.Release();
   tradition_fS3_param1.Release();
   delete tradition_fS3;
   sma1Source.Release();
   sma1.Release();
   linreg1Source.Release();
   linreg1.Release();
   ema5Source.Release();
   ema5.Release();
   sma2Source.Release();
   sma2.Release();
   sma3Source.Release();
   sma3.Release();
   linreg2Source.Release();
   linreg2.Release();
   delete plot9;
   sma4Source.Release();
   sma4.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   cross1X.Release();
   cross1Y.Release();
   cross1.Release();
   cross2X.Release();
   cross2Y.Release();
   cross2.Release();
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   cross3X.Release();
   cross3Y.Release();
   cross3.Release();
   crossover2X.Release();
   crossover2Y.Release();
   crossover2.Release();
   fixnan1X.Release();
   fixnan1.Release();
   highestpivot1Source.Release();
   fixnan2X.Release();
   fixnan2.Release();
   lowestpivot1Source.Release();
   fixnan3X.Release();
   fixnan3.Release();
   lowestpivot2Source.Release();
   fixnan4X.Release();
   fixnan4.Release();
   highestpivot2Source.Release();
   change3Source.Release();
   change3.Release();
   change4Source.Release();
   change4.Release();
   change5Source.Release();
   change5.Release();
   crossover3X.Release();
   crossover3Y.Release();
   crossover3.Release();
   crossunder2X.Release();
   crossunder2Y.Release();
   crossunder2.Release();
   crossunder3X.Release();
   crossunder3Y.Release();
   crossunder3.Release();
   linreg3Source.Release();
   linreg3.Release();
   crossover4X.Release();
   crossover4Y.Release();
   crossover4.Release();
   crossover5X.Release();
   crossover5Y.Release();
   crossover5.Release();
   crossover6X.Release();
   crossover6Y.Release();
   crossover6.Release();
   crossover7X.Release();
   crossover7Y.Release();
   crossover7.Release();
   crossunder4X.Release();
   crossunder4Y.Release();
   crossunder4.Release();
   crossunder5X.Release();
   crossunder5Y.Release();
   crossunder5.Release();
   crossunder6X.Release();
   crossunder6Y.Release();
   crossunder6.Release();
   delete plot16;
   delete plot24;
   crossover8X.Release();
   crossover8Y.Release();
   crossover8.Release();
   crossover9X.Release();
   crossover9Y.Release();
   crossover9.Release();
   crossunder7X.Release();
   crossunder7Y.Release();
   crossunder7.Release();
   crossover10X.Release();
   crossover10Y.Release();
   crossover10.Release();
   barssince1Condition.Release();
   barssince1.Release();
   crossover11X.Release();
   crossover11Y.Release();
   crossover11.Release();
   barssince2Condition.Release();
   barssince2.Release();
   barssince3Condition.Release();
   barssince3.Release();
   crossover12X.Release();
   crossover12Y.Release();
   crossover12.Release();
   crossover13X.Release();
   crossover13Y.Release();
   crossover13.Release();
   barssince4Condition.Release();
   barssince4.Release();
   crossover14X.Release();
   crossover14Y.Release();
   crossover14.Release();
   barssince5Condition.Release();
   barssince5.Release();
   crossunder8X.Release();
   crossunder8Y.Release();
   crossunder8.Release();
   crossover15X.Release();
   crossover15Y.Release();
   crossover15.Release();
   barssince6Condition.Release();
   barssince6.Release();
   crossunder9X.Release();
   crossunder9Y.Release();
   crossunder9.Release();
   crossover16X.Release();
   crossover16Y.Release();
   crossover16.Release();
   crossover17X.Release();
   crossover17Y.Release();
   crossover17.Release();
   crossunder10X.Release();
   crossunder10Y.Release();
   crossunder10.Release();
   barssince7Condition.Release();
   barssince7.Release();
   barssince8Condition.Release();
   barssince8.Release();
   crossover18X.Release();
   crossover18Y.Release();
   crossover18.Release();
   crossover19X.Release();
   crossover19Y.Release();
   crossover19.Release();
   delete barcolor1;
   delete barcolor2;
   barssince9Condition.Release();
   barssince9.Release();
   crossover20X.Release();
   crossover20Y.Release();
   crossover20.Release();
   crossunder11X.Release();
   crossunder11Y.Release();
   crossunder11.Release();
   barssince10Condition.Release();
   barssince10.Release();
   crossunder12X.Release();
   crossunder12Y.Release();
   crossunder12.Release();
   crossover21X.Release();
   crossover21Y.Release();
   crossover21.Release();
   crossunder13X.Release();
   crossunder13Y.Release();
   crossunder13.Release();
   crossover22X.Release();
   crossover22Y.Release();
   crossover22.Release();
   crossunder14X.Release();
   crossunder14Y.Release();
   crossunder14.Release();
   crossover23X.Release();
   crossover23Y.Release();
   crossover23.Release();
   barssince11Condition.Release();
   barssince11.Release();
   crossover24X.Release();
   crossover24Y.Release();
   crossover24.Release();
   crossunder15X.Release();
   crossunder15Y.Release();
   crossunder15.Release();
   barssince12Condition.Release();
   barssince12.Release();
   crossunder16X.Release();
   crossunder16Y.Release();
   crossunder16.Release();
   crossover25X.Release();
   crossover25Y.Release();
   crossover25.Release();
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
      ArrayInitialize(plot1, (showfib ? 84 : EMPTY_VALUE));
      ArrayInitialize(plot2, (showfib ? 64 : EMPTY_VALUE));
      ArrayInitialize(plot3, (showfib ? 50 : EMPTY_VALUE));
      ArrayInitialize(plot4, (showfib ? 36 : EMPTY_VALUE));
      ArrayInitialize(plot5, (showfib ? 18 : EMPTY_VALUE));
      HP_DEFAULT_VALUE = 0.00;
      ArrayInitialize(HP, HP_DEFAULT_VALUE);
      Filt_DEFAULT_VALUE = 0.00;
      ArrayInitialize(Filt, Filt_DEFAULT_VALUE);
      Peak_DEFAULT_VALUE = 0.00;
      ArrayInitialize(Peak, Peak_DEFAULT_VALUE);
      HP2_DEFAULT_VALUE = 0.00;
      ArrayInitialize(HP2, HP2_DEFAULT_VALUE);
      Filt2_DEFAULT_VALUE = 0.00;
      ArrayInitialize(Filt2, Filt2_DEFAULT_VALUE);
      Peak2_DEFAULT_VALUE = 0.00;
      ArrayInitialize(Peak2, Peak2_DEFAULT_VALUE);
      HP3_DEFAULT_VALUE = 0.00;
      ArrayInitialize(HP3, HP3_DEFAULT_VALUE);
      Filt3_DEFAULT_VALUE = 0.00;
      ArrayInitialize(Filt3, Filt3_DEFAULT_VALUE);
      Peak3_DEFAULT_VALUE = 0.00;
      ArrayInitialize(Peak3, Peak3_DEFAULT_VALUE);
      tradition_fS3_param1.Init();
      tradition_fS3.Clear();
      sma1Source.Init();
      linreg1Source.Init();
      ema5Source.Init();
      sma2Source.Init();
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      sma3Source.Init();
      linreg2Source.Init();
      ArrayInitialize(plot8, EMPTY_VALUE);
      plot9.Init(EMPTY_VALUE);
      sma4Source.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      cross1X.Init();
      cross1Y.Init();
      cross2X.Init();
      cross2Y.Init();
      crossover1X.Init();
      crossover1Y.Init();
      cross3X.Init();
      cross3Y.Init();
      crossover2X.Init();
      crossover2Y.Init();
      ArrayInitialize(plot11, EMPTY_VALUE);
      ArrayInitialize(plot12, EMPTY_VALUE);
      highestpivot1Source.Init();
      methodReturnedValue1_DEFAULT_VALUE = NULL;
      ArrayInitialize(methodReturnedValue1, methodReturnedValue1_DEFAULT_VALUE);
      fixnan1X.Init();
      lowestpivot1Source.Init();
      methodReturnedValue2_DEFAULT_VALUE = NULL;
      ArrayInitialize(methodReturnedValue2, methodReturnedValue2_DEFAULT_VALUE);
      fixnan2X.Init();
      lowestpivot2Source.Init();
      methodReturnedValue3_DEFAULT_VALUE = NULL;
      ArrayInitialize(methodReturnedValue3, methodReturnedValue3_DEFAULT_VALUE);
      fixnan3X.Init();
      highestpivot2Source.Init();
      methodReturnedValue4_DEFAULT_VALUE = NULL;
      ArrayInitialize(methodReturnedValue4, methodReturnedValue4_DEFAULT_VALUE);
      fixnan4X.Init();
      change3Source.Init();
      ArrayInitialize(plot13, EMPTY_VALUE);
      change4Source.Init();
      ArrayInitialize(plot14, EMPTY_VALUE);
      change5Source.Init();
      ArrayInitialize(plot15, EMPTY_VALUE);
      crossover3X.Init();
      crossover3Y.Init();
      crossunder2X.Init();
      crossunder2Y.Init();
      ubreak_DEFAULT_VALUE = 0;
      ArrayInitialize(ubreak, ubreak_DEFAULT_VALUE);
      ubreak2_DEFAULT_VALUE = 0;
      ArrayInitialize(ubreak2, ubreak2_DEFAULT_VALUE);
      dbreak_DEFAULT_VALUE = 0;
      ArrayInitialize(dbreak, dbreak_DEFAULT_VALUE);
      cont_DEFAULT_VALUE = 0;
      ArrayInitialize(cont, cont_DEFAULT_VALUE);
      cont2_DEFAULT_VALUE = 0;
      ArrayInitialize(cont2, cont2_DEFAULT_VALUE);
      pull_DEFAULT_VALUE = 0;
      ArrayInitialize(pull, pull_DEFAULT_VALUE);
      dbreak2_DEFAULT_VALUE = 0;
      ArrayInitialize(dbreak2, dbreak2_DEFAULT_VALUE);
      cross_DEFAULT_VALUE = 0;
      ArrayInitialize(cross, cross_DEFAULT_VALUE);
      crossunder3X.Init();
      crossunder3Y.Init();
      linreg3Source.Init();
      drag_DEFAULT_VALUE = 0;
      ArrayInitialize(drag, drag_DEFAULT_VALUE);
      crossover4X.Init();
      crossover4Y.Init();
      crossover5X.Init();
      crossover5Y.Init();
      crossover6X.Init();
      crossover6Y.Init();
      crossover7X.Init();
      crossover7Y.Init();
      crossunder4X.Init();
      crossunder4Y.Init();
      crossunder5X.Init();
      crossunder5Y.Init();
      crossunder6X.Init();
      crossunder6Y.Init();
      plot16.Init(EMPTY_VALUE);
      ArrayInitialize(plot22, EMPTY_VALUE);
      ArrayInitialize(plot23, EMPTY_VALUE);
      plot24.Init(EMPTY_VALUE);
      crossover8X.Init();
      crossover8Y.Init();
      crossover9X.Init();
      crossover9Y.Init();
      crossunder7X.Init();
      crossunder7Y.Init();
      crossover10X.Init();
      crossover10Y.Init();
      barssince1Condition.Init();
      crossover11X.Init();
      crossover11Y.Init();
      barssince2Condition.Init();
      crossover12X.Init();
      crossover12Y.Init();
      barssince3Condition.Init();
      crossover13X.Init();
      crossover13Y.Init();
      barssince4Condition.Init();
      crossover14X.Init();
      crossover14Y.Init();
      crossunder8X.Init();
      crossunder8Y.Init();
      barssince5Condition.Init();
      crossover15X.Init();
      crossover15Y.Init();
      crossunder9X.Init();
      crossunder9Y.Init();
      barssince6Condition.Init();
      crossover16X.Init();
      crossover16Y.Init();
      crossover17X.Init();
      crossover17Y.Init();
      crossunder10X.Init();
      crossunder10Y.Init();
      barssince7Condition.Init();
      crossover18X.Init();
      crossover18Y.Init();
      barssince8Condition.Init();
      ArrayInitialize(plot27, EMPTY_VALUE);
      ArrayInitialize(plot28, EMPTY_VALUE);
      ArrayInitialize(plot29, EMPTY_VALUE);
      ArrayInitialize(plot30, EMPTY_VALUE);
      ArrayInitialize(plot31, EMPTY_VALUE);
      ArrayInitialize(plot32, EMPTY_VALUE);
      crossover19X.Init();
      crossover19Y.Init();
      barcolor1.Init();
      barcolor2.Init();
      ArrayInitialize(plot57, EMPTY_VALUE);
      crossover20X.Init();
      crossover20Y.Init();
      barssince9Condition.Init();
      crossunder11X.Init();
      crossunder11Y.Init();
      ArrayInitialize(plot58, EMPTY_VALUE);
      crossunder12X.Init();
      crossunder12Y.Init();
      barssince10Condition.Init();
      crossover21X.Init();
      crossover21Y.Init();
      crossunder13X.Init();
      crossunder13Y.Init();
      crossover22X.Init();
      crossover22Y.Init();
      crossunder14X.Init();
      crossunder14Y.Init();
      crossover23X.Init();
      crossover23Y.Init();
      crossover24X.Init();
      crossover24Y.Init();
      barssince11Condition.Init();
      crossunder15X.Init();
      crossunder15Y.Init();
      crossunder16X.Init();
      crossunder16Y.Init();
      barssince12Condition.Init();
      crossover25X.Init();
      crossover25Y.Init();
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
      ubreak[pos] = pos < (rates_total - 1) ? ubreak[pos + 1] : 0;
      ubreak2[pos] = pos < (rates_total - 1) ? ubreak2[pos + 1] : 0;
      dbreak[pos] = pos < (rates_total - 1) ? dbreak[pos + 1] : 0;
      cont[pos] = pos < (rates_total - 1) ? cont[pos + 1] : 0;
      cont2[pos] = pos < (rates_total - 1) ? cont2[pos + 1] : 0;
      pull[pos] = pos < (rates_total - 1) ? pull[pos + 1] : 0;
      dbreak2[pos] = pos < (rates_total - 1) ? dbreak2[pos + 1] : 0;
      cross[pos] = pos < (rates_total - 1) ? cross[pos + 1] : 0;
      drag[pos] = pos < (rates_total - 1) ? drag[pos + 1] : 0;
      title = "Boom Hunter Pro";
      stitle = "Boom Pro";
      version = " 1.022";
      string theme = "Dark";
      double K2 = 0.3;
      int esize = 60;
      int ey = 50;
      int esize3 = 60;
      int ey3 = 50;
      double K33 = K13 * (-1);
      int esize2 = 60;
      int ey2 = 50;
      int smalen = 2;
      if (square)
      {
         K13 = 0.9999;
         K33 = (-0.9999);
      }
      double alpha1 = 0.00;
      double a1 = 0.00;
      double b1 = 0.00;
      double c1 = 0.00;
      double c2 = 0.00;
      double c3 = 0.00;
      double X = 0.00;
      double Quotient1 = 0.00;
      double Quotient2 = 0.00;
      double pi = SafeMultiply(2, MathArcsin(1));
      alpha1 = SafeDivide((SafeMinus(SafePlus(SafeCos(SafeDivide(SafeMultiply(.707 * 2, pi), 100)), SafeSin(SafeDivide(SafeMultiply(.707 * 2, pi), 100))), 1)), SafeCos(SafeDivide(SafeMultiply(.707 * 2, pi), 100)));
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      SetStream(HP, pos, SafePlus(SafeMultiply(SafeMultiply((SafeMinus(1, SafeDivide(alpha1, 2))), (SafeMinus(1, SafeDivide(alpha1, 2)))), (SafePlus(SafeMinus(close[pos], SafeMultiply(2, Nz(close[pos + 1]))), Nz(close[pos + 2])))), SafeMinus(SafeMultiply(2 * (1 - alpha1), Nz(HP[pos + 1])), SafeMultiply((1 - alpha1) * (1 - alpha1), Nz(HP[pos + 2])))), HP_DEFAULT_VALUE);
      a1 = SafeMathExp(SafeDivide(SafeMultiply((-1.414), pi), LPPeriod));
      b1 = SafeMultiply(2 * a1, SafeCos(SafeDivide(SafeMultiply(1.414, pi), LPPeriod)));
      c2 = b1;
      c3 = (-a1) * a1;
      c1 = 1 - c2 - c3;
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      SetStream(Filt, pos, SafePlus(SafeDivide(SafeMultiply(c1, (SafePlus(HP[pos], Nz(HP[pos + 1])))), 2), SafePlus(SafeMultiply(c2, Nz(Filt[pos + 1])), SafeMultiply(c3, Nz(Filt[pos + 2])))), Filt_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(Peak, pos, SafeMultiply(.991, Nz(Peak[pos + 1])), Peak_DEFAULT_VALUE);
      if (SafeGreater(MathAbs(Filt[pos]), Peak[pos]))
      {
         SetStream(Peak, pos, MathAbs(Filt[pos]), Peak_DEFAULT_VALUE);
      }
      if ((Peak[pos] != 0))
      {
         X = SafeDivide(Filt[pos], Peak[pos]);
      }
      Quotient1 = SafeDivide((X + K1), (K1 * X + 1));
      Quotient2 = SafeDivide((X + K2), (K2 * X + 1));
      double alpha1222 = 0.00;
      double a12 = 0.00;
      double b12 = 0.00;
      double c12 = 0.00;
      double c22 = 0.00;
      double c32 = 0.00;
      double X2 = 0.00;
      double Quotient3 = 0.00;
      double Quotient4 = 0.00;
      alpha1222 = SafeDivide((SafeMinus(SafePlus(SafeCos(SafeDivide(SafeMultiply(.707 * 2, pi), 100)), SafeSin(SafeDivide(SafeMultiply(.707 * 2, pi), 100))), 1)), SafeCos(SafeDivide(SafeMultiply(.707 * 2, pi), 100)));
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      SetStream(HP2, pos, SafePlus(SafeMultiply(SafeMultiply((SafeMinus(1, SafeDivide(alpha1222, 2))), (SafeMinus(1, SafeDivide(alpha1222, 2)))), (SafePlus(SafeMinus(close[pos], SafeMultiply(2, Nz(close[pos + 1]))), Nz(close[pos + 2])))), SafeMinus(SafeMultiply(2 * (1 - alpha1222), Nz(HP2[pos + 1])), SafeMultiply((1 - alpha1222) * (1 - alpha1222), Nz(HP2[pos + 2])))), HP2_DEFAULT_VALUE);
      a12 = SafeMathExp(SafeDivide(SafeMultiply((-1.414), pi), LPPeriod2));
      b12 = SafeMultiply(2 * a12, SafeCos(SafeDivide(SafeMultiply(1.414, pi), LPPeriod2)));
      c22 = b12;
      c32 = (-a12) * a12;
      c12 = 1 - c22 - c32;
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      SetStream(Filt2, pos, SafePlus(SafeDivide(SafeMultiply(c12, (SafePlus(HP2[pos], Nz(HP2[pos + 1])))), 2), SafePlus(SafeMultiply(c22, Nz(Filt2[pos + 1])), SafeMultiply(c32, Nz(Filt2[pos + 2])))), Filt2_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(Peak2, pos, SafeMultiply(.991, Nz(Peak2[pos + 1])), Peak2_DEFAULT_VALUE);
      if (SafeGreater(MathAbs(Filt2[pos]), Peak2[pos]))
      {
         SetStream(Peak2, pos, MathAbs(Filt2[pos]), Peak2_DEFAULT_VALUE);
      }
      if ((Peak2[pos] != 0))
      {
         X2 = SafeDivide(Filt2[pos], Peak2[pos]);
      }
      Quotient3 = SafeDivide((X2 + K12), (K12 * X2 + 1));
      Quotient4 = SafeDivide((X2 + K22), (K22 * X2 + 1));
      double alpha1333 = 0.12;
      double a13 = 0.00;
      double b13 = 0.00;
      double c13 = 0.00;
      double c33 = 0.00;
      double c333 = 0.00;
      double X3 = 0.00;
      double Quotient5 = 0.00;
      double Quotient6 = 0.00;
      alpha1333 = SafeDivide((SafeMinus(SafePlus(SafeCos(SafeDivide(SafeMultiply(.707 * 2, pi), 100)), SafeSin(SafeDivide(SafeMultiply(.707 * 2, pi), 100))), 1)), SafeCos(SafeDivide(SafeMultiply(.707 * 2, pi), 100)));
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      SetStream(HP3, pos, SafePlus(SafeMultiply(SafeMultiply((SafeMinus(1, SafeDivide(alpha1333, 3))), (SafeMinus(1, SafeDivide(alpha1333, 2)))), (SafePlus(SafeMinus(close[pos], SafeMultiply(2, Nz(close[pos + 1]))), Nz(close[pos + 2])))), SafeMinus(SafeMultiply(2 * (1 - alpha1333), Nz(HP3[pos + 1])), SafeMultiply((1 - alpha1333) * (1 - alpha1333), Nz(HP3[pos + 2])))), HP3_DEFAULT_VALUE);
      a13 = SafeMathExp(SafeDivide(SafeMultiply((-1.414), pi), LPPeriod3));
      b13 = SafeMultiply(2 * a13, SafeCos(SafeDivide(SafeMultiply(1.414, pi), LPPeriod3)));
      c33 = b13;
      c333 = (-a13) * a13;
      c13 = 1 - c33 - c333;
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      SetStream(Filt3, pos, SafePlus(SafeDivide(SafeMultiply(c13, (SafePlus(HP3[pos], Nz(HP3[pos + 1])))), 2), SafePlus(SafeMultiply(c33, Nz(Filt3[pos + 1])), SafeMultiply(c333, Nz(Filt3[pos + 2])))), Filt3_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      SetStream(Peak3, pos, SafeMultiply(.991, Nz(Peak3[pos + 1])), Peak3_DEFAULT_VALUE);
      if (SafeGreater(MathAbs(Filt3[pos]), Peak3[pos]))
      {
         SetStream(Peak3, pos, MathAbs(Filt3[pos]), Peak3_DEFAULT_VALUE);
      }
      if ((Peak3[pos] != 0))
      {
         X3 = SafeDivide(Filt3[pos], Peak3[pos]);
      }
      Quotient5 = SafeDivide((X3 + K13), (K13 * X3 + 1));
      Quotient6 = SafeDivide((X3 + K33), (K33 * X3 + 1));
      double line1 = (-0.9);
      double src0 = open[pos];
      double src1 = high[pos];
      double src2 = low[pos];
      double src3 = close[pos];
      double src4 = SafeDivide((high[pos] + low[pos]), 2);
      double src5 = SafeDivide((high[pos] + low[pos] + close[pos]), 3);
      double src6 = SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4);
      double tr1Value;
      if (!tr1.GetValue(pos, tr1Value)) { tr1Value = EMPTY_VALUE; }
      double src7 = tr1Value;
      double vol = tick_volume[pos];
      tradition_fS3_param1.SetValue(pos, src5);
      double tradition_fS3Value;
      if (!tradition_fS3.GetValue(pos, tradition_fS3Value)) { tradition_fS3Value = EMPTY_VALUE; }
      double wt1 = tradition_fS3Value;
      sma1Source.SetValue(pos, wt1);
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double wt2 = sma1Value;
      linreg1Source.SetValue(pos, wt1);
      double linreg1Value;
      if (!linreg1.GetValue(pos, linreg1Value)) { linreg1Value = EMPTY_VALUE; }
      double wt3 = linreg1Value;
      ema5Source.SetValue(pos, SafePlus(SafeMultiply((SafeMinus(wt1, wt2)), 2), 50));
      double ema5Value;
      if (!ema5.GetValue(pos, ema5Value)) { ema5Value = EMPTY_VALUE; }
      double wt4 = ema5Value;
      sma2Source.SetValue(pos, wt3);
      double sma2Value;
      if (!sma2.GetValue(pos, sma2Value)) { sma2Value = EMPTY_VALUE; }
      double trig = sma2Value;
      double q3 = Quotient3 * esize + ey;
      double q4 = Quotient4 * esize + ey;
      uint plot6_color = AddTransparency(Red, 50);
      if (plot6_color != INT_MAX) { plot6[pos] = q3; }
      else { plot6[pos] = EMPTY_VALUE; }
      double Plot33 = plot6[pos];
      uint plot7_color = AddTransparency(Red, 50);
      if (plot7_color != INT_MAX) { plot7[pos] = q4; }
      else { plot7[pos] = EMPTY_VALUE; }
      double Plot44 = plot7[pos];
      double q1 = Quotient1 * esize + ey;
      double q2 = Quotient2 * esize + ey;
      sma3Source.SetValue(pos, q1);
      double sma3Value;
      if (!sma3.GetValue(pos, sma3Value)) { sma3Value = EMPTY_VALUE; }
      double trigger = sma3Value;
      double ext1 = (SafeLess(wt2, 20) ? SafePlus(trigger, 9) : (SafeGreater(wt2, 80) ? SafeMinus(trigger, 9) : EMPTY_VALUE));
      linreg2Source.SetValue(pos, wt3);
      double linreg2Value;
      if (!linreg2.GetValue(pos, linreg2Value)) { linreg2Value = EMPTY_VALUE; }
      double lsma = linreg2Value;
      double q5 = Quotient5 * esize2 + ey2;
      double q6 = Quotient6 * esize2 + ey2;
      uint plot8_color = AddTransparency(Blue, 0);
      if (plot8_color != INT_MAX) { plot8[pos] = (showdboom ? q6 : EMPTY_VALUE); }
      else { plot8[pos] = EMPTY_VALUE; }
      double Plot54 = plot8[pos];
      double plot9Value = plot9.SetByColor(q5, pos, ((theme == "Light") ? AddTransparency(Orange, 0) : AddTransparency(Yellow, 0)));
      double Plot55 = plot9Value;
      sma4Source.SetValue(pos, close[pos]);
      double sma4Value;
      if (!sma4.GetValue(pos, sma4Value)) { sma4Value = EMPTY_VALUE; }
      double sma200 = sma4Value;
      crossunder1X.SetValue(pos, Quotient2);
      crossunder1Y.SetValue(pos, line1);
      int crossunder1Value;
      if (!crossunder1.GetValue(pos, crossunder1Value)) { crossunder1Value = (-1); }
      int entry = crossunder1Value;
      int color2 = (Quotient1 <= (-1)) && (Quotient2 <= (-1));
      cross1X.SetValue(pos, Quotient1);
      cross1Y.SetValue(pos, Quotient2);
      int cross1Value;
      if (!cross1.GetValue(pos, cross1Value)) { cross1Value = (-1); }
      int exit = cross1Value && SafeGreater(close[pos], sma200) && (Quotient1 > 0.5);
      cross2X.SetValue(pos, Quotient5);
      cross2Y.SetValue(pos, Quotient6);
      int cross2Value;
      if (!cross2.GetValue(pos, cross2Value)) { cross2Value = (-1); }
      int over = cross2Value && (Quotient5 > 0.5);
      crossover1X.SetValue(pos, Quotient5);
      crossover1Y.SetValue(pos, Quotient6);
      int crossover1Value;
      if (!crossover1.GetValue(pos, crossover1Value)) { crossover1Value = (-1); }
      int over2 = crossover1Value && (Quotient5 > 0.5);
      cross3X.SetValue(pos, Quotient3);
      cross3Y.SetValue(pos, Quotient4);
      int cross3Value;
      if (!cross3.GetValue(pos, cross3Value)) { cross3Value = (-1); }
      int over3 = cross3Value && (Quotient3 > 0);
      crossover2X.SetValue(pos, q1);
      crossover2Y.SetValue(pos, trigger);
      int crossover2Value;
      if (!crossover2.GetValue(pos, crossover2Value)) { crossover2Value = (-1); }
      int enter = crossover2Value && SafeLess(q1, lsma);
      PlotShape::SetBool(plot11, pos, "bottom", (showentry ? over : (-1)), high, low, 0, AddTransparency(Orange, 0));
      PlotShape::SetBool(plot12, pos, "bottom", (showentry ? over3 : (-1)), high, low, 0, AddTransparency(Red, 0));
      highestpivot1Source.SetValue(pos, q1);
      double highestpivot1Value;
      if (!PivotHighStream::GetValue(pos, highestpivot1Value, highestpivot1Source, leftBars, rightBars)) { highestpivot1Value = EMPTY_VALUE; }
      SetStream(methodReturnedValue1, pos, highestpivot1Value, methodReturnedValue1_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      fixnan1X.SetValue(pos, methodReturnedValue1[pos + 1]);
      double fixnan1Value;
      if (!fixnan1.GetValue(pos, fixnan1Value)) { fixnan1Value = EMPTY_VALUE; }
      double highUsePivot = fixnan1Value;
      lowestpivot1Source.SetValue(pos, q1);
      double lowestpivot1Value;
      if (!PivotLowStream::GetValue(pos, lowestpivot1Value, lowestpivot1Source, leftBars2, rightBars2)) { lowestpivot1Value = EMPTY_VALUE; }
      SetStream(methodReturnedValue2, pos, lowestpivot1Value, methodReturnedValue2_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      fixnan2X.SetValue(pos, methodReturnedValue2[pos + 1]);
      double fixnan2Value;
      if (!fixnan2.GetValue(pos, fixnan2Value)) { fixnan2Value = EMPTY_VALUE; }
      double lowUsePivot = fixnan2Value;
      lowestpivot2Source.SetValue(pos, q1);
      double lowestpivot2Value;
      if (!PivotLowStream::GetValue(pos, lowestpivot2Value, lowestpivot2Source, leftBars3, rightBars3)) { lowestpivot2Value = EMPTY_VALUE; }
      SetStream(methodReturnedValue3, pos, lowestpivot2Value, methodReturnedValue3_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      fixnan3X.SetValue(pos, methodReturnedValue3[pos + 1]);
      double fixnan3Value;
      if (!fixnan3.GetValue(pos, fixnan3Value)) { fixnan3Value = EMPTY_VALUE; }
      double lowUsePivot2 = fixnan3Value;
      highestpivot2Source.SetValue(pos, q1);
      double highestpivot2Value;
      if (!PivotHighStream::GetValue(pos, highestpivot2Value, highestpivot2Source, leftBars3, rightBars3)) { highestpivot2Value = EMPTY_VALUE; }
      SetStream(methodReturnedValue4, pos, highestpivot2Value, methodReturnedValue4_DEFAULT_VALUE);
      if (pos + 1 > (rates_total - 1)) { continue; }
      fixnan4X.SetValue(pos, methodReturnedValue4[pos + 1]);
      double fixnan4Value;
      if (!fixnan4.GetValue(pos, fixnan4Value)) { fixnan4Value = EMPTY_VALUE; }
      double highUsePivot2 = fixnan4Value;
      change3Source.SetValue(pos, highUsePivot);
      double change3Value;
      if (!change3.GetValue(pos, change3Value)) { change3Value = EMPTY_VALUE; }
      uint plot13_color = (NumberToBool(change3Value) ? INT_MAX : Red);
      if (plot13_color != INT_MAX) { plot13[pos] = (toggleBreaks ? highUsePivot : EMPTY_VALUE); }
      else { plot13[pos] = EMPTY_VALUE; }
      double r1 = plot13[pos];
      change4Source.SetValue(pos, lowUsePivot2);
      double change4Value;
      if (!change4.GetValue(pos, change4Value)) { change4Value = EMPTY_VALUE; }
      uint plot14_color = (NumberToBool(change4Value) ? INT_MAX : Silver);
      if (plot14_color != INT_MAX) { plot14[pos] = (toggleBreaks ? lowUsePivot2 : EMPTY_VALUE); }
      else { plot14[pos] = EMPTY_VALUE; }
      double s2 = plot14[pos];
      change5Source.SetValue(pos, lowUsePivot);
      double change5Value;
      if (!change5.GetValue(pos, change5Value)) { change5Value = EMPTY_VALUE; }
      uint plot15_color = (NumberToBool(change5Value) ? INT_MAX : Blue);
      if (plot15_color != INT_MAX) { plot15[pos] = (toggleBreaks ? lowUsePivot : EMPTY_VALUE); }
      else { plot15[pos] = EMPTY_VALUE; }
      double s1 = plot15[pos];
      crossover3X.SetValue(pos, q1);
      crossover3Y.SetValue(pos, trigger);
      int crossover3Value;
      if (!crossover3.GetValue(pos, crossover3Value)) { crossover3Value = (-1); }
      int crossover = crossover3Value;
      crossunder2X.SetValue(pos, q1);
      crossunder2Y.SetValue(pos, trigger);
      int crossunder2Value;
      if (!crossunder2.GetValue(pos, crossunder2Value)) { crossunder2Value = (-1); }
      int crossunder = crossunder2Value;
      if (crossunder)
      {
         SetStream(cross, pos, 0, cross_DEFAULT_VALUE);
      }
      if (crossover)
      {
         SetStream(cross, pos, 1, cross_DEFAULT_VALUE);
      }
      crossunder3X.SetValue(pos, q1);
      crossunder3Y.SetValue(pos, lowUsePivot);
      int crossunder3Value;
      if (!crossunder3.GetValue(pos, crossunder3Value)) { crossunder3Value = (-1); }
      if (crossunder3Value)
      {
         SetStream(dbreak, pos, dbreak[pos] + 1, dbreak_DEFAULT_VALUE);
      }
      if (entry)
      {
         SetStream(dbreak, pos, 0, dbreak_DEFAULT_VALUE);
         SetStream(dbreak2, pos, 0, dbreak2_DEFAULT_VALUE);
         SetStream(ubreak, pos, 0, ubreak_DEFAULT_VALUE);
         SetStream(ubreak2, pos, 0, ubreak2_DEFAULT_VALUE);
         SetStream(cont, pos, 0, cont_DEFAULT_VALUE);
         SetStream(cont2, pos, 0, cont2_DEFAULT_VALUE);
      }
      linreg3Source.SetValue(pos, tick_volume[pos]);
      double linreg3Value;
      if (!linreg3.GetValue(pos, linreg3Value)) { linreg3Value = EMPTY_VALUE; }
      double volcond = linreg3Value;
      if ((Quotient1 <= (-1)))
      {
         SetStream(drag, pos, drag[pos] + 1, drag_DEFAULT_VALUE);
      }
      crossover4X.SetValue(pos, Quotient1);
      crossover4Y.SetValue(pos, (-0.9));
      int crossover4Value;
      if (!crossover4.GetValue(pos, crossover4Value)) { crossover4Value = (-1); }
      if (crossover4Value)
      {
         SetStream(drag, pos, 0, drag_DEFAULT_VALUE);
      }
      crossover5X.SetValue(pos, q1);
      crossover5Y.SetValue(pos, highUsePivot);
      int crossover5Value;
      if (!crossover5.GetValue(pos, crossover5Value)) { crossover5Value = (-1); }
      if (crossover5Value && (dbreak[pos] >= 1))
      {
         SetStream(ubreak, pos, ubreak[pos] + 1, ubreak_DEFAULT_VALUE);
      }
      crossover6X.SetValue(pos, q1);
      crossover6Y.SetValue(pos, highUsePivot);
      int crossover6Value;
      if (!crossover6.GetValue(pos, crossover6Value)) { crossover6Value = (-1); }
      if (crossover6Value && (dbreak[pos] >= 1) && (ubreak[pos] <= 1))
      {
         SetStream(cont, pos, 1, cont_DEFAULT_VALUE);
      }
      crossover7X.SetValue(pos, q1);
      crossover7Y.SetValue(pos, highUsePivot);
      int crossover7Value;
      if (!crossover7.GetValue(pos, crossover7Value)) { crossover7Value = (-1); }
      if (crossover7Value && (dbreak[pos] >= 2) && (ubreak[pos] >= 2) && (cont[pos] <= 2))
      {
         SetStream(cont2, pos, 1, cont2_DEFAULT_VALUE);
      }
      crossunder4X.SetValue(pos, q1);
      crossunder4Y.SetValue(pos, lowUsePivot2);
      int crossunder4Value;
      if (!crossunder4.GetValue(pos, crossunder4Value)) { crossunder4Value = (-1); }
      if (crossunder4Value)
      {
         SetStream(dbreak2, pos, dbreak2[pos] + 1, dbreak2_DEFAULT_VALUE);
      }
      crossunder5X.SetValue(pos, q1);
      crossunder5Y.SetValue(pos, highUsePivot2);
      int crossunder5Value;
      if (!crossunder5.GetValue(pos, crossunder5Value)) { crossunder5Value = (-1); }
      if (crossunder5Value)
      {
         SetStream(ubreak2, pos, ubreak2[pos] + 1, ubreak2_DEFAULT_VALUE);
      }
      crossunder6X.SetValue(pos, q1);
      crossunder6Y.SetValue(pos, lowUsePivot2);
      int crossunder6Value;
      if (!crossunder6.GetValue(pos, crossunder6Value)) { crossunder6Value = (-1); }
      if (crossunder6Value && (dbreak2[pos] == 1))
      {
         SetStream(ubreak2, pos, 0, ubreak2_DEFAULT_VALUE);
      }
      double plot16Value = plot16.SetByColor(q1, pos, ((cross[pos] == 1) ? 0xaaff00 : ((drag[pos] >= dragno) ? Purple : ((Quotient1 <= (-0.8)) ? Yellow : ((Quotient3 <= (-0.9)) ? White : ((cross[pos] == 0) ? Red : Gray))))));
      double Plot = plot16Value;
      uint plot22_color = osccol;
      if (plot22_color != INT_MAX) { plot22[pos] = q1; }
      else { plot22[pos] = EMPTY_VALUE; }
      double Plot4 = plot22[pos];
      uint plot23_color = trigcol;
      if (plot23_color != INT_MAX) { plot23[pos] = trigger; }
      else { plot23[pos] = EMPTY_VALUE; }
      double Plot3 = plot23[pos];
      double plot24Value = plot24.SetByColor(ext1, pos, (SafeLess(wt2, 20) ? 0xaaff00 : (SafeGreater(wt2, 80) ? Red : INT_MAX)));
      crossover8X.SetValue(pos, Quotient3);
      crossover8Y.SetValue(pos, (-0.9));
      int crossover8Value;
      if (!crossover8.GetValue(pos, crossover8Value)) { crossover8Value = (-1); }
      int warn = crossover8Value;
      crossover9X.SetValue(pos, Quotient1);
      crossover9Y.SetValue(pos, (-0.9));
      int crossover9Value;
      if (!crossover9.GetValue(pos, crossover9Value)) { crossover9Value = (-1); }
      int warn2 = crossover9Value;
      crossunder7X.SetValue(pos, Quotient1);
      crossunder7Y.SetValue(pos, 0.9);
      int crossunder7Value;
      if (!crossunder7.GetValue(pos, crossunder7Value)) { crossunder7Value = (-1); }
      int warn3 = crossunder7Value;
      crossover10X.SetValue(pos, q1);
      crossover10Y.SetValue(pos, trigger);
      int crossover10Value;
      if (!crossover10.GetValue(pos, crossover10Value)) { crossover10Value = (-1); }
      barssince1Condition.SetValue(pos, warn);
      int barssince1Value;
      if (!barssince1.GetValue(pos, barssince1Value)) { barssince1Value = INT_MIN; }
      int enter2 = (Quotient1 <= (-0.9)) && crossover10Value && SafeLE(barssince1Value, 7);
      crossover11X.SetValue(pos, q1);
      crossover11Y.SetValue(pos, trigger);
      int crossover11Value;
      if (!crossover11.GetValue(pos, crossover11Value)) { crossover11Value = (-1); }
      barssince2Condition.SetValue(pos, warn2);
      int barssince2Value;
      if (!barssince2.GetValue(pos, barssince2Value)) { barssince2Value = INT_MIN; }
      crossover12X.SetValue(pos, q1);
      crossover12Y.SetValue(pos, 20);
      int crossover12Value;
      if (!crossover12.GetValue(pos, crossover12Value)) { crossover12Value = (-1); }
      barssince3Condition.SetValue(pos, crossover12Value);
      int barssince3Value;
      if (!barssince3.GetValue(pos, barssince3Value)) { barssince3Value = INT_MIN; }
      int enter3 = (Quotient3 <= (-0.9)) && crossover11Value && SafeLE(barssince2Value, 7) && (q1 <= 20) && SafeLE(barssince3Value, 21);
      crossover13X.SetValue(pos, q1);
      crossover13Y.SetValue(pos, trigger);
      int crossover13Value;
      if (!crossover13.GetValue(pos, crossover13Value)) { crossover13Value = (-1); }
      int entercond = crossover13Value && (q1 < 10);
      barssince4Condition.SetValue(pos, entercond);
      int barssince4Value;
      if (!barssince4.GetValue(pos, barssince4Value)) { barssince4Value = INT_MIN; }
      crossover14X.SetValue(pos, q1);
      crossover14Y.SetValue(pos, trigger);
      int crossover14Value;
      if (!crossover14.GetValue(pos, crossover14Value)) { crossover14Value = (-1); }
      int enter4 = (q1 <= 20) && SafeLE(barssince4Value, 5) && crossover14Value;
      crossunder8X.SetValue(pos, q1);
      crossunder8Y.SetValue(pos, trigger);
      int crossunder8Value;
      if (!crossunder8.GetValue(pos, crossunder8Value)) { crossunder8Value = (-1); }
      barssince5Condition.SetValue(pos, (q1 <= 0) && crossunder8Value);
      int barssince5Value;
      if (!barssince5.GetValue(pos, barssince5Value)) { barssince5Value = INT_MIN; }
      crossover15X.SetValue(pos, q1);
      crossover15Y.SetValue(pos, trigger);
      int crossover15Value;
      if (!crossover15.GetValue(pos, crossover15Value)) { crossover15Value = (-1); }
      int enter5 = SafeLE(barssince5Value, 5) && crossover15Value;
      crossunder9X.SetValue(pos, q1);
      crossunder9Y.SetValue(pos, trigger);
      int crossunder9Value;
      if (!crossunder9.GetValue(pos, crossunder9Value)) { crossunder9Value = (-1); }
      barssince6Condition.SetValue(pos, (q1 <= 20) && crossunder9Value);
      int barssince6Value;
      if (!barssince6.GetValue(pos, barssince6Value)) { barssince6Value = INT_MIN; }
      crossover16X.SetValue(pos, q1);
      crossover16Y.SetValue(pos, trigger);
      int crossover16Value;
      if (!crossover16.GetValue(pos, crossover16Value)) { crossover16Value = (-1); }
      int enter6 = SafeLE(barssince6Value, 11) && crossover16Value;
      crossover17X.SetValue(pos, q1);
      crossover17Y.SetValue(pos, trigger);
      int crossover17Value;
      if (!crossover17.GetValue(pos, crossover17Value)) { crossover17Value = (-1); }
      int enter7 = (Quotient3 <= (-0.9)) && crossover17Value;
      crossunder10X.SetValue(pos, q1);
      crossunder10Y.SetValue(pos, trigger);
      int crossunder10Value;
      if (!crossunder10.GetValue(pos, crossunder10Value)) { crossunder10Value = (-1); }
      barssince7Condition.SetValue(pos, warn3);
      int barssince7Value;
      if (!barssince7.GetValue(pos, barssince7Value)) { barssince7Value = INT_MIN; }
      crossover18X.SetValue(pos, q1);
      crossover18Y.SetValue(pos, 80);
      int crossover18Value;
      if (!crossover18.GetValue(pos, crossover18Value)) { crossover18Value = (-1); }
      barssince8Condition.SetValue(pos, crossover18Value);
      int barssince8Value;
      if (!barssince8.GetValue(pos, barssince8Value)) { barssince8Value = INT_MIN; }
      int senter3 = (Quotient3 >= (-0.9)) && crossunder10Value && SafeLE(barssince7Value, 7) && (q1 >= 99) && SafeLE(barssince8Value, 21);
      PlotShape::SetBool(plot27, pos, "top", showlongs && enter6 && (q1 <= 60), high, low, 0, AddTransparency(Silver, 20));
      PlotShape::SetBool(plot28, pos, "top", showlongs && enter7, high, low, 0, AddTransparency(Yellow, 20));
      PlotShape::SetBool(plot29, pos, "top", showlongs && enter5, high, low, 0, AddTransparency(Blue, 20));
      PlotShape::SetBool(plot30, pos, "top", showlongs && enter3, high, low, 0, AddTransparency(Lime, 20));
      PlotShape::SetBool(plot31, pos, "top", (showshorts ? senter3 : (-1)), high, low, 0, AddTransparency(Red, 20));
      crossover19X.SetValue(pos, q1);
      crossover19Y.SetValue(pos, highUsePivot);
      int crossover19Value;
      if (!crossover19.GetValue(pos, crossover19Value)) { crossover19Value = (-1); }
      PlotShape::SetBool(plot32, pos, "bottom", crossover19Value && (dbreak[pos] >= 1) && (ubreak[pos] <= 1), high, low, 0, AddTransparency(0xaaff00, 0));
      uint barcolor1_color = (allbars && (drag[pos] >= dragno) ? Purple : (allbars && (Quotient3 <= (-0.9)) ? White : (allbars && (Quotient1 <= (-0.9)) ? Yellow : INT_MAX)));
      if (barcolor1_color != INT_MAX)
      {
         barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor1_color);
      }
      else
      {
         barcolor1.Clear(pos);
      }
      uint barcolor2_color = (allbars && barc && SafeGreater(q1, trigger) ? 0xaaff00 : (allbars && barc && SafeLess(q1, trigger) ? Red : (allbars && barc ? Gray : INT_MAX)));
      if (barcolor2_color != INT_MAX)
      {
         barcolor2.Set(pos, open[pos], high[pos], low[pos], close[pos], barcolor2_color);
      }
      else
      {
         barcolor2.Clear(pos);
      }
      crossover20X.SetValue(pos, wt2);
      crossover20Y.SetValue(pos, 80);
      int crossover20Value;
      if (!crossover20.GetValue(pos, crossover20Value)) { crossover20Value = (-1); }
      barssince9Condition.SetValue(pos, crossover20Value);
      int barssince9Value;
      if (!barssince9.GetValue(pos, barssince9Value)) { barssince9Value = INT_MIN; }
      crossunder11X.SetValue(pos, wt2);
      crossunder11Y.SetValue(pos, 80);
      int crossunder11Value;
      if (!crossunder11.GetValue(pos, crossunder11Value)) { crossunder11Value = (-1); }
      PlotShape::Set(plot57, pos, "absolute", (SafeLE(barssince9Value, 1) && crossunder11Value ? SafePlus(wt2, 9) : EMPTY_VALUE), high, low, 0);
      crossunder12X.SetValue(pos, wt2);
      crossunder12Y.SetValue(pos, 20);
      int crossunder12Value;
      if (!crossunder12.GetValue(pos, crossunder12Value)) { crossunder12Value = (-1); }
      barssince10Condition.SetValue(pos, crossunder12Value);
      int barssince10Value;
      if (!barssince10.GetValue(pos, barssince10Value)) { barssince10Value = INT_MIN; }
      crossover21X.SetValue(pos, wt2);
      crossover21Y.SetValue(pos, 20);
      int crossover21Value;
      if (!crossover21.GetValue(pos, crossover21Value)) { crossover21Value = (-1); }
      PlotShape::Set(plot58, pos, "absolute", (SafeLE(barssince10Value, 1) && crossover21Value ? SafeMinus(wt2, 9) : EMPTY_VALUE), high, low, 0);
      if (crossover) { _signaler.SendNotifications("Crossover", ""); }
      if (crossunder) { _signaler.SendNotifications("Crossunder", ""); }
      if ((((enter6 || enter7) || enter5) || enter3)) { _signaler.SendNotifications("Long", ""); }
      crossunder13X.SetValue(pos, Quotient5);
      crossunder13Y.SetValue(pos, (-0.9));
      int crossunder13Value;
      if (!crossunder13.GetValue(pos, crossunder13Value)) { crossunder13Value = (-1); }
      if (crossunder13Value) { _signaler.SendNotifications("Entry Zone", ""); }
      crossover22X.SetValue(pos, q1);
      crossover22Y.SetValue(pos, highUsePivot);
      int crossover22Value;
      if (!crossover22.GetValue(pos, crossover22Value)) { crossover22Value = (-1); }
      if (crossover22Value) { _signaler.SendNotifications("Break Resistance", ""); }
      crossunder14X.SetValue(pos, q1);
      crossunder14Y.SetValue(pos, lowUsePivot);
      int crossunder14Value;
      if (!crossunder14.GetValue(pos, crossunder14Value)) { crossunder14Value = (-1); }
      if (crossunder14Value) { _signaler.SendNotifications("Break Support", ""); }
      if ((Quotient1 <= (-0.9)) && crossover) { _signaler.SendNotifications("Crossover - Market Low", ""); }
      if ((Quotient1 >= 0.9) && crossunder) { _signaler.SendNotifications("Crossunder - Market High", ""); }
      if (SafeLE(wt2, 20) && crossover) { _signaler.SendNotifications("Crossover With Pressure", ""); }
      if (SafeGE(wt2, 80) && crossunder) { _signaler.SendNotifications("Crossunder With Pressure", ""); }
      crossover23X.SetValue(pos, q1);
      crossover23Y.SetValue(pos, highUsePivot);
      int crossover23Value;
      if (!crossover23.GetValue(pos, crossover23Value)) { crossover23Value = (-1); }
      if (crossover23Value && (dbreak[pos] >= 1) && (ubreak[pos] <= 1)) { _signaler.SendNotifications("Continuation", ""); }
      if (over) { _signaler.SendNotifications("Orange - Overbought", ""); }
      if (over3) { _signaler.SendNotifications("Red - Overbought", ""); }
      crossover24X.SetValue(pos, wt2);
      crossover24Y.SetValue(pos, 80);
      int crossover24Value;
      if (!crossover24.GetValue(pos, crossover24Value)) { crossover24Value = (-1); }
      barssince11Condition.SetValue(pos, crossover24Value);
      int barssince11Value;
      if (!barssince11.GetValue(pos, barssince11Value)) { barssince11Value = INT_MIN; }
      crossunder15X.SetValue(pos, wt2);
      crossunder15Y.SetValue(pos, 80);
      int crossunder15Value;
      if (!crossunder15.GetValue(pos, crossunder15Value)) { crossunder15Value = (-1); }
      if (SafeLE(barssince11Value, 1) && crossunder15Value) { _signaler.SendNotifications("Bounce down", ""); }
      crossunder16X.SetValue(pos, wt2);
      crossunder16Y.SetValue(pos, 20);
      int crossunder16Value;
      if (!crossunder16.GetValue(pos, crossunder16Value)) { crossunder16Value = (-1); }
      barssince12Condition.SetValue(pos, crossunder16Value);
      int barssince12Value;
      if (!barssince12.GetValue(pos, barssince12Value)) { barssince12Value = INT_MIN; }
      crossover25X.SetValue(pos, wt2);
      crossover25Y.SetValue(pos, 20);
      int crossover25Value;
      if (!crossover25.GetValue(pos, crossover25Value)) { crossover25Value = (-1); }
      if (SafeLE(barssince12Value, 1) && crossover25Value) { _signaler.SendNotifications("Bounce up", ""); }
      if (senter3) { _signaler.SendNotifications("Short", ""); }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76182

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