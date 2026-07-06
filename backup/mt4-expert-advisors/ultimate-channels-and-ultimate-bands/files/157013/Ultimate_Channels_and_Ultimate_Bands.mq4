//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75284&p=157013#p157013

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
#property indicator_buffers 2
#property indicator_label1 "Upper"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Lower"
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

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

// SMA on stream v1.1
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
input string param1 = "Channel"; // Mode:
input int param2 = 20; // Length:
input int param3 = 20; // STR Length:
input double param4 = 1.0; // Width Multiplier:
input int bars_limit = 100000; // Bars limit
string title;
string stitle;
string mode;
int length0;
int length1;
double multiplier;
class UltimateSmoother_fS_iStream
{
   IStream* src;
   int period;
   double us[];
   double us_DEFAULT_VALUE;
   bool _initialized;
public:
   UltimateSmoother_fS_iStream(IStream* src, int period)
   {
      _initialized = false;
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
      SetIndexBuffer(id++, us);
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
         us_DEFAULT_VALUE = EMPTY_VALUE;
         ArrayInitialize(us, us_DEFAULT_VALUE);
         _initialized = true;
      }
      double a1 = MathExp(SafeDivide((-1.414) * 3.1415926535897932, period));
      double c2 = SafeMultiply(SafeMultiply(2.0, a1), MathCos(SafeDivide(1.414 * 3.1415926535897932, period)));
      double c3 = SafeMultiply(InvertSign(a1), a1);
      double c1 = SafeDivide((SafeMinus(SafePlus(1.0, c2), c3)), 4.0);
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      SetStream(us, pos, srcValue, us_DEFAULT_VALUE);
      if ((((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos) >= 4))
      {
         double srcValue_1;
         if (!src.GetValue(pos + 1, srcValue_1)) { srcValue_1 = EMPTY_VALUE; }
         double srcValue_2;
         if (!src.GetValue(pos + 2, srcValue_2)) { srcValue_2 = EMPTY_VALUE; }
         if (pos + 1 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
         if (pos + 2 > (iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1)) { return false; }
         SetStream(us, pos, SafePlus(SafeMultiply((SafeMinus(1.0, c1)), srcValue), SafePlus(SafeMinus(SafeMultiply((SafeMinus(SafeMultiply(2.0, c1), c2)), srcValue_1), SafeMultiply((SafePlus(c1, c3)), srcValue_2)), SafePlus(SafeMultiply(c2, Nz(us[pos + 1])), SafeMultiply(c3, Nz(us[pos + 2]))))), us_DEFAULT_VALUE);
      }
      __out1 = us[pos];
      return true;
   }
};
class UltimateChannel_i_i_fStream
{
   int length;
   int lengthSTR;
   double mult;
   FloatStream* UltimateSmoother_fS_i1_param1;
   UltimateSmoother_fS_iStream* UltimateSmoother_fS_i1;
   IStream* tr1;
   FloatStream* UltimateSmoother_fS_i2_param1;
   UltimateSmoother_fS_iStream* UltimateSmoother_fS_i2;
   bool _initialized;
public:
   UltimateChannel_i_i_fStream(int length, int lengthSTR, double mult)
   {
      _initialized = false;
      this.length = length;
      this.lengthSTR = lengthSTR;
      this.mult = mult;
   }
   ~UltimateChannel_i_i_fStream()
   {
      UltimateSmoother_fS_i1_param1.Release();
      delete UltimateSmoother_fS_i1;
      tr1.Release();
      UltimateSmoother_fS_i2_param1.Release();
      delete UltimateSmoother_fS_i2;
   }
   int Init(int id)
   {
      UltimateSmoother_fS_i1_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      UltimateSmoother_fS_i1 = new UltimateSmoother_fS_iStream(UltimateSmoother_fS_i1_param1, length);
      id = UltimateSmoother_fS_i1.Init(id);
      tr1 = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      UltimateSmoother_fS_i2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      UltimateSmoother_fS_i2 = new UltimateSmoother_fS_iStream(UltimateSmoother_fS_i2_param1, lengthSTR);
      id = UltimateSmoother_fS_i2.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1, double &__out2)
   {
      if (!_initialized)
      {
         UltimateSmoother_fS_i1_param1.Init();
         UltimateSmoother_fS_i1.Clear();
         UltimateSmoother_fS_i2_param1.Init();
         UltimateSmoother_fS_i2.Clear();
         _initialized = true;
      }
      UltimateSmoother_fS_i1_param1.SetValue(pos, iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      double UltimateSmoother_fS_i1Value;
      if (!UltimateSmoother_fS_i1.GetValue(pos, UltimateSmoother_fS_i1Value)) { UltimateSmoother_fS_i1Value = EMPTY_VALUE; }
      double mid = UltimateSmoother_fS_i1Value;
      double tr1Value;
      if (!tr1.GetValue(pos, tr1Value)) { tr1Value = EMPTY_VALUE; }
      UltimateSmoother_fS_i2_param1.SetValue(pos, tr1Value);
      double UltimateSmoother_fS_i2Value;
      if (!UltimateSmoother_fS_i2.GetValue(pos, UltimateSmoother_fS_i2Value)) { UltimateSmoother_fS_i2Value = EMPTY_VALUE; }
      double str = SafeMultiply(UltimateSmoother_fS_i2Value, mult);
      __out1 = SafePlus(mid, str);
      __out2 = SafeMinus(mid, str);
      return true;
   }
};
UltimateChannel_i_i_fStream* UltimateChannel_i_i_f3;
class UltimateBands_fS_i_fStream
{
   IStream* src;
   int length;
   double mult;
   FloatStream* UltimateSmoother_fS_i4_param1;
   UltimateSmoother_fS_iStream* UltimateSmoother_fS_i4;
   FloatStream* sma1Source;
   SmaOnStream* sma1;
   bool _initialized;
public:
   UltimateBands_fS_i_fStream(IStream* src, int length, double mult)
   {
      _initialized = false;
      this.src = src;
      src.AddRef();
      this.length = length;
      this.mult = mult;
      sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      sma1 = new SmaOnStream(sma1Source, length);
   }
   ~UltimateBands_fS_i_fStream()
   {
      src.Release();
      UltimateSmoother_fS_i4_param1.Release();
      delete UltimateSmoother_fS_i4;
      sma1Source.Release();
      sma1.Release();
   }
   int Init(int id)
   {
      UltimateSmoother_fS_i4_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      UltimateSmoother_fS_i4 = new UltimateSmoother_fS_iStream(UltimateSmoother_fS_i4_param1, length);
      id = UltimateSmoother_fS_i4.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, double &__out1, double &__out2)
   {
      if (!_initialized)
      {
         UltimateSmoother_fS_i4_param1.Init();
         UltimateSmoother_fS_i4.Clear();
         sma1Source.Init();
         _initialized = true;
      }
      double srcValue;
      if (!src.GetValue(pos, srcValue)) { srcValue = EMPTY_VALUE; }
      UltimateSmoother_fS_i4_param1.SetValue(pos, srcValue);
      double UltimateSmoother_fS_i4Value;
      if (!UltimateSmoother_fS_i4.GetValue(pos, UltimateSmoother_fS_i4Value)) { UltimateSmoother_fS_i4Value = EMPTY_VALUE; }
      double mid = UltimateSmoother_fS_i4Value;
      sma1Source.SetValue(pos, SafeMathPow(SafeMinus(srcValue, mid), 2));
      double sma1Value;
      if (!sma1.GetValue(pos, sma1Value)) { sma1Value = EMPTY_VALUE; }
      double sd = SafeMultiply(SafeMathSqrt(sma1Value), mult);
      __out1 = SafePlus(mid, sd);
      __out2 = SafeMinus(mid, sd);
      return true;
   }
};
FloatStream* UltimateBands_fS_i_f5_param1;
UltimateBands_fS_i_fStream* UltimateBands_fS_i_f5;
double plot1[];
double plot2[];

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
   IndicatorBuffers(5);
   int id = 0;
   mode = param1;
   length0 = param2;
   length1 = param3;
   multiplier = param4;
   SetIndexBuffer(id, plot1);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 2, ColorRGB(30, 150, 250, 0));
   SetIndexBuffer(id, plot2);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 2, ColorRGB(30, 150, 250, 0));
   IndicatorObjPrefix = GenerateIndicatorPrefix(stitle);
   IndicatorShortName(title);
   UltimateChannel_i_i_f3 = new UltimateChannel_i_i_fStream(length0, length1, multiplier);
   id = UltimateChannel_i_i_f3.Init(id);
   UltimateBands_fS_i_f5_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   UltimateBands_fS_i_f5 = new UltimateBands_fS_i_fStream(UltimateBands_fS_i_f5_param1, length0, multiplier);
   id = UltimateBands_fS_i_f5.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete UltimateChannel_i_i_f3;
   UltimateBands_fS_i_f5_param1.Release();
   delete UltimateBands_fS_i_f5;
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
      UltimateChannel_i_i_f3.Clear();
      UltimateBands_fS_i_f5_param1.Init();
      UltimateBands_fS_i_f5.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
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
      title = "TASC 2024.05 Ultimate Channels and Ultimate Bands";
      stitle = "UCUB";
      string M00 = "Channel";
      string M01 = "Bands";
      string TT01 = "Switch between the Ultimate channel and Ultimate bands indicators";
      string TT02 = "The smooth true range (STR) length defining the Ultimate Channel";
      double uc = EMPTY_VALUE;
      double lc = EMPTY_VALUE;
      if ((mode == M00))
      {
         double UltimateChannel_i_i_f3Value1;
         double UltimateChannel_i_i_f3Value2;
         if (!UltimateChannel_i_i_f3.GetValue(pos, UltimateChannel_i_i_f3Value1, UltimateChannel_i_i_f3Value2)) { UltimateChannel_i_i_f3Value1 = EMPTY_VALUE; UltimateChannel_i_i_f3Value2 = EMPTY_VALUE; }
         uc = UltimateChannel_i_i_f3Value1;
         lc = UltimateChannel_i_i_f3Value2;
      }
      else
      {
         UltimateBands_fS_i_f5_param1.SetValue(pos, close[pos]);
         double UltimateBands_fS_i_f5Value1;
         double UltimateBands_fS_i_f5Value2;
         if (!UltimateBands_fS_i_f5.GetValue(pos, UltimateBands_fS_i_f5Value1, UltimateBands_fS_i_f5Value2)) { UltimateBands_fS_i_f5Value1 = EMPTY_VALUE; UltimateBands_fS_i_f5Value2 = EMPTY_VALUE; }
         uc = UltimateBands_fS_i_f5Value1;
         lc = UltimateBands_fS_i_f5Value2;
      }
      color plot1_color = ColorRGB(30, 150, 250, 0);
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = uc; }
      else { plot1[pos] = EMPTY_VALUE; }
      double u = plot1[pos];
      color plot2_color = ColorRGB(30, 150, 250, 0);
      if (plot2_color != EMPTY_VALUE) { plot2[pos] = lc; }
      else { plot2[pos] = EMPTY_VALUE; }
      double l = plot2[pos];
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