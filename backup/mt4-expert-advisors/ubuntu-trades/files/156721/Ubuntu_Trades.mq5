//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75216

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
#property indicator_buffers 86
#property indicator_plots 16
#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_label2 "LimitLong"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Green
#property indicator_style2 STYLE_SOLID
#property indicator_width2 3
#property indicator_label3 "LimitShort"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Red
#property indicator_style3 STYLE_SOLID
#property indicator_width3 3
#property indicator_label4 "DailyOpenPrice"
#property indicator_type4 DRAW_COLOR_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Target 1"
#property indicator_type5 DRAW_COLOR_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Target 3"
#property indicator_type6 DRAW_COLOR_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Target 5"
#property indicator_type7 DRAW_COLOR_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Target 7"
#property indicator_type8 DRAW_COLOR_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Target 9"
#property indicator_type9 DRAW_COLOR_LINE
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Target 11"
#property indicator_type10 DRAW_COLOR_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "Target 13"
#property indicator_type11 DRAW_COLOR_LINE
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_label12 "Target 15"
#property indicator_type12 DRAW_COLOR_LINE
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_label13 "Target 17"
#property indicator_type13 DRAW_COLOR_LINE
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
#property indicator_label14 "Target 19"
#property indicator_type14 DRAW_COLOR_LINE
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
#property indicator_label15 "StopLong"
#property indicator_type15 DRAW_LINE
#property indicator_color15 Purple
#property indicator_style15 STYLE_SOLID
#property indicator_width15 5
#property indicator_label16 "StopShort"
#property indicator_type16 DRAW_LINE
#property indicator_color16 Yellow
#property indicator_style16 STYLE_SOLID
#property indicator_width16 5

// Abstract date/time stream v1.0

#ifndef ADateTimeStream_IMPL
#define ADateTimeStream_IMPL
// Boolean Stream v.1.0

#ifndef IDateTimeStream_IMPL
#define IDateTimeStream_IMPL

interface IDateTimeStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, datetime &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, datetime &val[]) = 0;
};

#endif

class ADateTimeStream : public IDateTimeStream
{
   int _refs;   
public:
   ADateTimeStream()
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

// Date/time stream v1.0

#ifndef DateTimeStream_IMP
#define DateTimeStream_IMP

class DateTimeStream : public ADateTimeStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   DateTimeStream(const string symbol, string resolution)
   {
      _symbol = symbol;
      _timeframe = GetTimeframe(resolution);
   }
   ~DateTimeStream()
   {
   }

   bool GetSeriesValues(const int period, const int count, datetime &val[])
   {
      int size = Size();
      if (period >= size - count)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iTime(_symbol, _timeframe, period + i);
      }
      return true;
   }
   bool GetValues(const int period, const int count, datetime &val[])
   {
      int size = iBars(_Symbol, _Period);
      int oldPos = size - period - 1;
      if (oldPos + count - 1 >= size)
      {
         return false;  
      }
      for (int i = 0; i < count; ++i)
      {
         datetime barTime = iTime(_Symbol, _Period, oldPos + i);
         int position = iBarShift(_symbol, _timeframe, barTime);
         if (position == -1)
         {
            return false;
         }
         val[i] = iTime(_symbol, _timeframe, position);
      }
      return true;
   }
   
   int Size()
   {
      return iBars(_Symbol, _Period);
   }
private:
   ENUM_TIMEFRAMES GetTimeframe(string resolution)
   {
      if (resolution == "1") { return PERIOD_M1; }
      if (resolution == "2") { return PERIOD_M2; }
      if (resolution == "3") { return PERIOD_M3; }
      if (resolution == "4") { return PERIOD_M4; }
      if (resolution == "5") { return PERIOD_M5; }
      if (resolution == "6") { return PERIOD_M6; }
      if (resolution == "10") { return PERIOD_M10; }
      if (resolution == "12") { return PERIOD_M12; }
      if (resolution == "15") { return PERIOD_M15; }
      if (resolution == "20") { return PERIOD_M20; }
      if (resolution == "30") { return PERIOD_M30; }
      if (resolution == "60") { return PERIOD_H1; }
      if (resolution == "120") { return PERIOD_H2; }
      if (resolution == "180") { return PERIOD_H3; }
      if (resolution == "240") { return PERIOD_H4; }
      if (resolution == "360") { return PERIOD_H6; }
      if (resolution == "480") { return PERIOD_H8; }
      if (resolution == "720") { return PERIOD_H12; }
      if (resolution == "D") { return PERIOD_D1; }
      if (resolution == "W") { return PERIOD_W1; }
      if (resolution == "M") { return PERIOD_MN1; }
      return PERIOD_CURRENT;
   }
};
#endif
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

//ChangeStream v1.1
class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period >= Size() - 2)
      {
         return false;
      }
      int size = Size();
      double src1[1], src2[1];
      if (!_source.GetSeriesValues(period, 1, src1) || !_source.GetSeriesValues(period + _period, 1, src2))
      {
         return false;
      }
      val = src1[0] - src2[0];
      return true;
   }
};

// Value when stream (condition as a parameter) v1.0

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

class ValueWhenSimpleStream : public AStream
{
   datetime _periods[];
   double _values[];
   int _shift;
public:
   double _stream[];

   ValueWhenSimpleStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int shift)
      :AStream(symbol, timeframe)
   {
      _shift = shift;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream, INDICATOR_CALCULATIONS);
      return id + 1;
   }

   double Update(const int period, datetime date, bool condition, double val)
   {
      if (condition)
      {
         int size = ArraySize(_periods);
         if (size == 0 || _periods[size - 1] != date)
         {
            ArrayResize(_periods, size + 1);
            ArrayResize(_values, size + 1);
            _values[size] = val;
            _periods[size] = date;
            ++size;
         }
         else
         {
            _values[size - 1] = val;
         }
         if (size - 1 - _shift >= 0)
         {
            _stream[period] = _values[size - 1 - _shift];
         }
         else
         {
            _stream[period] = EMPTY_VALUE;
         }
      }
      else if (period > 0)
      {
         _stream[period] = _stream[period - 1];
      }
      return _stream[period];
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; i++)
      {
         if (_stream[period - i] == EMPTY_VALUE)
         {
            return false;
         }
         val[i] = _stream[period - i];
      }
      return true;
   }
};
// Pine-script like safe operations
// v1.1

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
double SyminfoMintick(string symbol)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   return point * mult;
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
#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL
// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
// Boolean Stream v.1.0

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


//ConditionStreamV2 v1.0

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
// Candles stream v.1.0
class CandleStreams
{
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];
   double ColorIndex[];
   color colors[];
   int streamIndex;
public:
   CandleStreams(int streamIndex)
   {
      this.streamIndex = streamIndex;
   }
   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
      ArrayInitialize(ColorIndex, 0);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
      ColorIndex[index] = 0;
   }
   
   void AddColor(color clr)
   {
      int size = ArraySize(colors);
      ArrayResize(colors, size + 1);
      colors[size] = clr;
   }

   int RegisterStreams(const int id)
   {
      SetIndexBuffer(id, OpenStream, INDICATOR_DATA);
      SetIndexBuffer(id + 1, HighStream, INDICATOR_DATA);
      SetIndexBuffer(id + 2, LowStream, INDICATOR_DATA);
      SetIndexBuffer(id + 3, CloseStream, INDICATOR_DATA);
      SetIndexBuffer(id + 4, ColorIndex, INDICATOR_COLOR_INDEX);
      int size = ArraySize(colors);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, size);
      for (int i = 0; i < size; ++i)
      {
         PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, i, colors[i]);
      }
      return id + 5;
   }
   
   void Set(const int index, const double open, const double high, const double low, const double close, color clr)
   {
      if (clr == (color)EMPTY_VALUE)
      {
         return;
      }
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
      ColorIndex[index] = FindColor(clr);
   }
   
   void SetOffset(int offset)
   {
   }
private:
   int FindColor(color clr)
   {
      int size = ArraySize(colors);
      for (int i = 0; i < size; ++i)
      {
         if (colors[i] == clr)
         {
            return i;
         }
      }
      return 0;
   }
};
// Colored plor v1.0


class ColoredPlot
{
   int plotIndex;
   double values[];
   double colors[];
   double buffer[];
   
   uint initColors[];
   int offset;
public:
   ColoredPlot(int plotIndex)
   {
      this.plotIndex = plotIndex;
      offset = INT_MIN;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      int colorsCount = ArraySize(initColors);
      ArrayResize(initColors, colorsCount + 1);
      initColors[colorsCount] = GetColorOnly(clr);
   }
   
   void SetOffset(int offset)
   {
      this.offset = offset;
   }
   
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, values, INDICATOR_DATA);
      int colorsCount = ArraySize(initColors);
      PlotIndexSetInteger(plotIndex, PLOT_COLOR_INDEXES, colorsCount);
      for (int i = 0; i < colorsCount; ++i)
      {
         PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, i, initColors[i]);
      }
      if (offset != INT_MIN)
      {
         PlotIndexSetInteger(plotIndex, PLOT_SHIFT, offset);
      }
      id += 1;
      SetIndexBuffer(id++, colors, INDICATOR_COLOR_INDEX);
      return id;
   }
   int RegisterInternalStreams(int id)
   {
      SetIndexBuffer(id++, buffer, INDICATOR_CALCULATIONS);
      return id;
   }
   
   void Init()
   {
      ArrayInitialize(values, EMPTY_VALUE);
      ArrayInitialize(colors, EMPTY_VALUE);
      ArrayInitialize(buffer, EMPTY_VALUE);
   }
   
   void Set(int pos, double value, uint clr)
   {
      int transp = GetTranparency(clr);
      buffer[pos] = value;
      values[pos] = value;
      colors[pos] = FindColorIndex(clr);
      if (value == EMPTY_VALUE)
      {
         values[pos] = EMPTY_VALUE;
         colors[pos] = EMPTY_VALUE;
         buffer[pos] = EMPTY_VALUE;
         return;
      }
      int prevValueIndex = FindPrevValueIndex(pos);
      if (prevValueIndex == -1)
      {
         return;
      }
      int length = pos - prevValueIndex + 1;
      if (colors[pos] == -1)
      {
         for (int i = 1; i < length; ++i)
         {
            values[prevValueIndex + i] = EMPTY_VALUE;
            colors[prevValueIndex + i] = EMPTY_VALUE;
         }
         return;
      }
      double diff = buffer[pos] - buffer[prevValueIndex];
      double step = diff / (length - 1);
      for (int i = 0; i < length; ++i)
      {
         values[prevValueIndex + i] = buffer[prevValueIndex] + step * i;
         colors[prevValueIndex + i] = colors[pos];
      }
   }
private:
   int FindPrevValueIndex(int pos)
   {
      for (int i = pos - 1; i >= 0; --i)
      {
         if (buffer[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return -1;
   }
   int FindColorIndex(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return -1;
      }
      color searchingColor = GetColorOnly(clr);
      int colorsCount = ArraySize(initColors);
      for (int i = 0; i < colorsCount; ++i)
      {
         if (initColors[i] == searchingColor)
         {
            return i;
         }
      }
      return -1;
   }
};
// Collection of labels v1.1

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.2

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   color _color;
   color _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   int _window;
public:
   Label(int x, double y, string labelId, string collectionId, int window)
   {
      _refs = 1;
      _window = window;
      _textColor = Yellow;
      _x = x;
      _y = y;
      _labelId = labelId;
      _collectionId = collectionId;
      _font = "Arial";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
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

   static Label* Create(string id, int x, double y, datetime dateId)
   {
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
      Label* label = new Label(x, y, labelId, id, ChartWindowOnDropped());
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      _all.Add(label);
      if (_all.Count() > _maxLabels)
      {
         Delete(_all.GetFirst());
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
input string param1 = "Dark Mode"; // Chart Colors
input string param2 = "BreakEven After 2nd Target Hit"; // Trade Logic
input string param3 = "D"; // Resolution For Targets?
input double param4 = 1.0; // Target Multiple
input string param5 = "D";
input string param6 = "1600-0600";
input string param7 = "5-Day Average Absolute %-Change"; // Calculation Method
input double param8 = 0.618;
input double param9 = 1.0;
input int bars_limit = 10000; // Bars limit
string chartColor;
string tradeLogic;
string res1;
double targetMultiple;
string highTimeFrame;
string sessSpec;
DateTimeStream* time1;
class is_newbar_sStream
{
   string res;
   DateTimeStream* time2;
   FloatStream* change1Source;
   ChangeStream* change1;
   bool _initialized;
public:
   is_newbar_sStream(string res)
   {
      _initialized = false;
      this.res = res;
      time2 = new DateTimeStream(_Symbol, res);
      change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      change1 = new ChangeStream(change1Source, 1);
   }
   ~is_newbar_sStream()
   {
      time2.Release();
      change1Source.Release();
      change1.Release();
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
      if (!_initialized)
      {
         change1Source.Init();
         _initialized = true;
      }
      datetime time2Value[1];
      if (!time2.GetValues(pos, 1, time2Value)) { time2Value[0] = EMPTY_VALUE; }
      datetime t = time2Value[0];
      change1Source.SetValue(pos, t);
      double change1Value[1];
      if (!change1.GetValues(pos, 1, change1Value)) { change1Value[0] = EMPTY_VALUE; }
      __out1 = ((change1Value[0] != 0) ? 1 : 0);
      return true;
   }
};
is_newbar_sStream* is_newbar_s1;
double sopen;
ValueWhenSimpleStream* valuewhen1;
ValueWhenSimpleStream* valuewhen2;
ValueWhenSimpleStream* valuewhen3;
ValueWhenSimpleStream* valuewhen4;
ValueWhenSimpleStream* valuewhen5;
ValueWhenSimpleStream* valuewhen6;
ValueWhenSimpleStream* valuewhen7;
ValueWhenSimpleStream* valuewhen8;
ValueWhenSimpleStream* valuewhen9;
ValueWhenSimpleStream* valuewhen10;
ValueWhenSimpleStream* valuewhen11;
ValueWhenSimpleStream* valuewhen12;
ValueWhenSimpleStream* valuewhen13;
ValueWhenSimpleStream* valuewhen14;
ValueWhenSimpleStream* valuewhen15;
ValueWhenSimpleStream* valuewhen16;
ValueWhenSimpleStream* valuewhen17;
ValueWhenSimpleStream* valuewhen18;
ValueWhenSimpleStream* valuewhen19;
ValueWhenSimpleStream* valuewhen20;
ValueWhenSimpleStream* valuewhen21;
string calculationMethod;
double defaultStop;
class RoundToTick_fSStream
{
   IStream* _price;
   bool _initialized;
public:
   RoundToTick_fSStream(IStream* _price)
   {
      _initialized = false;
      this._price = _price;
      _price.AddRef();
   }
   ~RoundToTick_fSStream()
   {
      _price.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, double &__out1)
   {
      double _priceValue[1];
      if (!_price.GetValues(pos, 1, _priceValue)) { _priceValue[0] = EMPTY_VALUE; }
      __out1 = SafeMultiply(MathRound(SafeDivide(_priceValue[0], SyminfoMintick(_Symbol))), SyminfoMintick(_Symbol));
      return true;
   }
};
FloatStream* RoundToTick_fS2_param1;
RoundToTick_fSStream* RoundToTick_fS2;
FloatStream* RoundToTick_fS3_param1;
RoundToTick_fSStream* RoundToTick_fS3;
double threshold;
FloatStream* RoundToTick_fS4_param1;
RoundToTick_fSStream* RoundToTick_fS4;
FloatStream* RoundToTick_fS5_param1;
RoundToTick_fSStream* RoundToTick_fS5;
FloatStream* RoundToTick_fS6_param1;
RoundToTick_fSStream* RoundToTick_fS6;
FloatStream* RoundToTick_fS7_param1;
RoundToTick_fSStream* RoundToTick_fS7;
FloatStream* RoundToTick_fS8_param1;
RoundToTick_fSStream* RoundToTick_fS8;
FloatStream* RoundToTick_fS9_param1;
RoundToTick_fSStream* RoundToTick_fS9;
FloatStream* RoundToTick_fS10_param1;
RoundToTick_fSStream* RoundToTick_fS10;
FloatStream* RoundToTick_fS11_param1;
RoundToTick_fSStream* RoundToTick_fS11;
FloatStream* RoundToTick_fS12_param1;
RoundToTick_fSStream* RoundToTick_fS12;
FloatStream* RoundToTick_fS13_param1;
RoundToTick_fSStream* RoundToTick_fS13;
FloatStream* RoundToTick_fS14_param1;
RoundToTick_fSStream* RoundToTick_fS14;
FloatStream* RoundToTick_fS15_param1;
RoundToTick_fSStream* RoundToTick_fS15;
FloatStream* RoundToTick_fS16_param1;
RoundToTick_fSStream* RoundToTick_fS16;
FloatStream* RoundToTick_fS17_param1;
RoundToTick_fSStream* RoundToTick_fS17;
FloatStream* RoundToTick_fS18_param1;
RoundToTick_fSStream* RoundToTick_fS18;
FloatStream* RoundToTick_fS19_param1;
RoundToTick_fSStream* RoundToTick_fS19;
FloatStream* RoundToTick_fS20_param1;
RoundToTick_fSStream* RoundToTick_fS20;
FloatStream* RoundToTick_fS21_param1;
RoundToTick_fSStream* RoundToTick_fS21;
FloatStream* RoundToTick_fS22_param1;
RoundToTick_fSStream* RoundToTick_fS22;
FloatStream* RoundToTick_fS23_param1;
RoundToTick_fSStream* RoundToTick_fS23;
FloatStream* RoundToTick_fS24_param1;
RoundToTick_fSStream* RoundToTick_fS24;
FloatStream* RoundToTick_fS25_param1;
RoundToTick_fSStream* RoundToTick_fS25;
FloatStream* RoundToTick_fS26_param1;
RoundToTick_fSStream* RoundToTick_fS26;
FloatStream* RoundToTick_fS27_param1;
RoundToTick_fSStream* RoundToTick_fS27;
FloatStream* RoundToTick_fS28_param1;
RoundToTick_fSStream* RoundToTick_fS28;
FloatStream* RoundToTick_fS29_param1;
RoundToTick_fSStream* RoundToTick_fS29;
FloatStream* RoundToTick_fS30_param1;
RoundToTick_fSStream* RoundToTick_fS30;
FloatStream* RoundToTick_fS31_param1;
RoundToTick_fSStream* RoundToTick_fS31;
FloatStream* RoundToTick_fS32_param1;
RoundToTick_fSStream* RoundToTick_fS32;
FloatStream* RoundToTick_fS33_param1;
RoundToTick_fSStream* RoundToTick_fS33;
FloatStream* RoundToTick_fS34_param1;
RoundToTick_fSStream* RoundToTick_fS34;
FloatStream* RoundToTick_fS35_param1;
RoundToTick_fSStream* RoundToTick_fS35;
FloatStream* RoundToTick_fS36_param1;
RoundToTick_fSStream* RoundToTick_fS36;
FloatStream* RoundToTick_fS37_param1;
RoundToTick_fSStream* RoundToTick_fS37;
FloatStream* RoundToTick_fS38_param1;
RoundToTick_fSStream* RoundToTick_fS38;
FloatStream* RoundToTick_fS39_param1;
RoundToTick_fSStream* RoundToTick_fS39;
FloatStream* RoundToTick_fS40_param1;
RoundToTick_fSStream* RoundToTick_fS40;
FloatStream* RoundToTick_fS41_param1;
RoundToTick_fSStream* RoundToTick_fS41;
FloatStream* RoundToTick_fS42_param1;
RoundToTick_fSStream* RoundToTick_fS42;
FloatStream* RoundToTick_fS43_param1;
RoundToTick_fSStream* RoundToTick_fS43;
double stopLong[];
double stopLong_DEFAULT_VALUE;
double stopShort[];
double stopShort_DEFAULT_VALUE;
double position[];
double position_DEFAULT_VALUE;
double t1[];
double t1_DEFAULT_VALUE;
double t2[];
double t2_DEFAULT_VALUE;
double t3[];
double t3_DEFAULT_VALUE;
double t4[];
double t4_DEFAULT_VALUE;
double t5[];
double t5_DEFAULT_VALUE;
double t6[];
double t6_DEFAULT_VALUE;
double t7[];
double t7_DEFAULT_VALUE;
double t8[];
double t8_DEFAULT_VALUE;
double t9[];
double t9_DEFAULT_VALUE;
double t10[];
double t10_DEFAULT_VALUE;
double t11[];
double t11_DEFAULT_VALUE;
double t12[];
double t12_DEFAULT_VALUE;
double t13[];
double t13_DEFAULT_VALUE;
double t14[];
double t14_DEFAULT_VALUE;
double t15[];
double t15_DEFAULT_VALUE;
double t16[];
double t16_DEFAULT_VALUE;
double t17[];
double t17_DEFAULT_VALUE;
double t18[];
double t18_DEFAULT_VALUE;
double t19[];
double t19_DEFAULT_VALUE;
double t20[];
double t20_DEFAULT_VALUE;
FloatStream* cross1X;
FloatStream* cross1Y;
IBoolStream* cross1;
FloatStream* cross2X;
FloatStream* cross2Y;
IBoolStream* cross2;
FloatStream* cross3X;
FloatStream* cross3Y;
IBoolStream* cross3;
FloatStream* cross4X;
FloatStream* cross4Y;
IBoolStream* cross4;
FloatStream* cross5X;
FloatStream* cross5Y;
IBoolStream* cross5;
FloatStream* cross6X;
FloatStream* cross6Y;
IBoolStream* cross6;
CandleStreams* barcolor1;
double plot2[];
double plot3[];
ColoredPlot* plot4;
ColoredPlot* plot5;
ColoredPlot* plot6;
ColoredPlot* plot7;
ColoredPlot* plot8;
ColoredPlot* plot9;
ColoredPlot* plot10;
ColoredPlot* plot11;
ColoredPlot* plot12;
ColoredPlot* plot13;
ColoredPlot* plot14;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
IBoolStream* crossunder1;
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
double plot15[];
double plot16[];

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
   chartColor = param1;
   tradeLogic = param2;
   res1 = param3;
   targetMultiple = param4;
   highTimeFrame = param5;
   sessSpec = param6;
   time1 = new DateTimeStream(_Symbol, "1");
   calculationMethod = param7;
   cross1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1 = CrossStreamFactory::CreateCross(cross1X, cross1Y);
   cross2X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross2Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross2 = CrossStreamFactory::CreateCross(cross2X, cross2Y);
   cross3X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross3Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross3 = CrossStreamFactory::CreateCross(cross3X, cross3Y);
   cross4X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross4Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross4 = CrossStreamFactory::CreateCross(cross4X, cross4Y);
   cross5X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross5Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross5 = CrossStreamFactory::CreateCross(cross5X, cross5Y);
   cross6X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross6Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross6 = CrossStreamFactory::CreateCross(cross6X, cross6Y);
   barcolor1 = new CandleStreams(0);
   barcolor1.AddColor(Lime);
   barcolor1.AddColor(Red);
   barcolor1.AddColor(White);
   barcolor1.AddColor(Black);
   barcolor1.SetOffset(0);
   id = barcolor1.RegisterStreams(id);
   SetIndexBuffer(id++, plot2, INDICATOR_DATA);
   SetIndexBuffer(id++, plot3, INDICATOR_DATA);
   plot4 = new ColoredPlot(3);
   plot4.AddColor(White);
   plot4.AddColor(Black);
   plot4.SetOffset(0);
   id = plot4.RegisterStreams(id);
   plot5 = new ColoredPlot(4);
   plot5.AddColor(White);
   plot5.AddColor(Black);
   plot5.SetOffset(0);
   id = plot5.RegisterStreams(id);
   plot6 = new ColoredPlot(5);
   plot6.AddColor(White);
   plot6.AddColor(Black);
   plot6.SetOffset(0);
   id = plot6.RegisterStreams(id);
   plot7 = new ColoredPlot(6);
   plot7.AddColor(White);
   plot7.AddColor(Black);
   plot7.SetOffset(0);
   id = plot7.RegisterStreams(id);
   plot8 = new ColoredPlot(7);
   plot8.AddColor(White);
   plot8.AddColor(Black);
   plot8.SetOffset(0);
   id = plot8.RegisterStreams(id);
   plot9 = new ColoredPlot(8);
   plot9.AddColor(White);
   plot9.AddColor(Black);
   plot9.SetOffset(0);
   id = plot9.RegisterStreams(id);
   plot10 = new ColoredPlot(9);
   plot10.AddColor(White);
   plot10.AddColor(Black);
   plot10.SetOffset(0);
   id = plot10.RegisterStreams(id);
   plot11 = new ColoredPlot(10);
   plot11.AddColor(White);
   plot11.AddColor(Black);
   plot11.SetOffset(0);
   id = plot11.RegisterStreams(id);
   plot12 = new ColoredPlot(11);
   plot12.AddColor(White);
   plot12.AddColor(Black);
   plot12.SetOffset(0);
   id = plot12.RegisterStreams(id);
   plot13 = new ColoredPlot(12);
   plot13.AddColor(White);
   plot13.AddColor(Black);
   plot13.SetOffset(0);
   id = plot13.RegisterStreams(id);
   plot14 = new ColoredPlot(13);
   plot14.AddColor(White);
   plot14.AddColor(Black);
   plot14.SetOffset(0);
   id = plot14.RegisterStreams(id);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   SetIndexBuffer(id++, plot15, INDICATOR_DATA);
   SetIndexBuffer(id++, plot16, INDICATOR_DATA);
   LabelsCollection::SetMaxLabels(50);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "Trade Manager");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   is_newbar_s1 = new is_newbar_sStream(res1);
   id = is_newbar_s1.Init(id);
   valuewhen1 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   id = valuewhen1.RegisterInternalStream(id);
   valuewhen2 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen2.RegisterInternalStream(id);
   valuewhen3 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 2);
   id = valuewhen3.RegisterInternalStream(id);
   valuewhen4 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 3);
   id = valuewhen4.RegisterInternalStream(id);
   valuewhen5 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 4);
   id = valuewhen5.RegisterInternalStream(id);
   valuewhen6 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 5);
   id = valuewhen6.RegisterInternalStream(id);
   valuewhen7 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 6);
   id = valuewhen7.RegisterInternalStream(id);
   valuewhen8 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 7);
   id = valuewhen8.RegisterInternalStream(id);
   valuewhen9 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 8);
   id = valuewhen9.RegisterInternalStream(id);
   valuewhen10 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 9);
   id = valuewhen10.RegisterInternalStream(id);
   valuewhen11 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 10);
   id = valuewhen11.RegisterInternalStream(id);
   valuewhen12 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 11);
   id = valuewhen12.RegisterInternalStream(id);
   valuewhen13 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 12);
   id = valuewhen13.RegisterInternalStream(id);
   valuewhen14 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 13);
   id = valuewhen14.RegisterInternalStream(id);
   valuewhen15 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 14);
   id = valuewhen15.RegisterInternalStream(id);
   valuewhen16 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 15);
   id = valuewhen16.RegisterInternalStream(id);
   valuewhen17 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 16);
   id = valuewhen17.RegisterInternalStream(id);
   valuewhen18 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 17);
   id = valuewhen18.RegisterInternalStream(id);
   valuewhen19 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 18);
   id = valuewhen19.RegisterInternalStream(id);
   valuewhen20 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 19);
   id = valuewhen20.RegisterInternalStream(id);
   valuewhen21 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 20);
   id = valuewhen21.RegisterInternalStream(id);
   RoundToTick_fS2_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS2 = new RoundToTick_fSStream(RoundToTick_fS2_param1);
   id = RoundToTick_fS2.Init(id);
   RoundToTick_fS3_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS3 = new RoundToTick_fSStream(RoundToTick_fS3_param1);
   id = RoundToTick_fS3.Init(id);
   RoundToTick_fS4_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS4 = new RoundToTick_fSStream(RoundToTick_fS4_param1);
   id = RoundToTick_fS4.Init(id);
   RoundToTick_fS5_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS5 = new RoundToTick_fSStream(RoundToTick_fS5_param1);
   id = RoundToTick_fS5.Init(id);
   RoundToTick_fS6_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS6 = new RoundToTick_fSStream(RoundToTick_fS6_param1);
   id = RoundToTick_fS6.Init(id);
   RoundToTick_fS7_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS7 = new RoundToTick_fSStream(RoundToTick_fS7_param1);
   id = RoundToTick_fS7.Init(id);
   RoundToTick_fS8_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS8 = new RoundToTick_fSStream(RoundToTick_fS8_param1);
   id = RoundToTick_fS8.Init(id);
   RoundToTick_fS9_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS9 = new RoundToTick_fSStream(RoundToTick_fS9_param1);
   id = RoundToTick_fS9.Init(id);
   RoundToTick_fS10_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS10 = new RoundToTick_fSStream(RoundToTick_fS10_param1);
   id = RoundToTick_fS10.Init(id);
   RoundToTick_fS11_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS11 = new RoundToTick_fSStream(RoundToTick_fS11_param1);
   id = RoundToTick_fS11.Init(id);
   RoundToTick_fS12_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS12 = new RoundToTick_fSStream(RoundToTick_fS12_param1);
   id = RoundToTick_fS12.Init(id);
   RoundToTick_fS13_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS13 = new RoundToTick_fSStream(RoundToTick_fS13_param1);
   id = RoundToTick_fS13.Init(id);
   RoundToTick_fS14_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS14 = new RoundToTick_fSStream(RoundToTick_fS14_param1);
   id = RoundToTick_fS14.Init(id);
   RoundToTick_fS15_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS15 = new RoundToTick_fSStream(RoundToTick_fS15_param1);
   id = RoundToTick_fS15.Init(id);
   RoundToTick_fS16_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS16 = new RoundToTick_fSStream(RoundToTick_fS16_param1);
   id = RoundToTick_fS16.Init(id);
   RoundToTick_fS17_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS17 = new RoundToTick_fSStream(RoundToTick_fS17_param1);
   id = RoundToTick_fS17.Init(id);
   RoundToTick_fS18_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS18 = new RoundToTick_fSStream(RoundToTick_fS18_param1);
   id = RoundToTick_fS18.Init(id);
   RoundToTick_fS19_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS19 = new RoundToTick_fSStream(RoundToTick_fS19_param1);
   id = RoundToTick_fS19.Init(id);
   RoundToTick_fS20_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS20 = new RoundToTick_fSStream(RoundToTick_fS20_param1);
   id = RoundToTick_fS20.Init(id);
   RoundToTick_fS21_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS21 = new RoundToTick_fSStream(RoundToTick_fS21_param1);
   id = RoundToTick_fS21.Init(id);
   RoundToTick_fS22_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS22 = new RoundToTick_fSStream(RoundToTick_fS22_param1);
   id = RoundToTick_fS22.Init(id);
   RoundToTick_fS23_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS23 = new RoundToTick_fSStream(RoundToTick_fS23_param1);
   id = RoundToTick_fS23.Init(id);
   RoundToTick_fS24_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS24 = new RoundToTick_fSStream(RoundToTick_fS24_param1);
   id = RoundToTick_fS24.Init(id);
   RoundToTick_fS25_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS25 = new RoundToTick_fSStream(RoundToTick_fS25_param1);
   id = RoundToTick_fS25.Init(id);
   RoundToTick_fS26_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS26 = new RoundToTick_fSStream(RoundToTick_fS26_param1);
   id = RoundToTick_fS26.Init(id);
   RoundToTick_fS27_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS27 = new RoundToTick_fSStream(RoundToTick_fS27_param1);
   id = RoundToTick_fS27.Init(id);
   RoundToTick_fS28_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS28 = new RoundToTick_fSStream(RoundToTick_fS28_param1);
   id = RoundToTick_fS28.Init(id);
   RoundToTick_fS29_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS29 = new RoundToTick_fSStream(RoundToTick_fS29_param1);
   id = RoundToTick_fS29.Init(id);
   RoundToTick_fS30_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS30 = new RoundToTick_fSStream(RoundToTick_fS30_param1);
   id = RoundToTick_fS30.Init(id);
   RoundToTick_fS31_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS31 = new RoundToTick_fSStream(RoundToTick_fS31_param1);
   id = RoundToTick_fS31.Init(id);
   RoundToTick_fS32_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS32 = new RoundToTick_fSStream(RoundToTick_fS32_param1);
   id = RoundToTick_fS32.Init(id);
   RoundToTick_fS33_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS33 = new RoundToTick_fSStream(RoundToTick_fS33_param1);
   id = RoundToTick_fS33.Init(id);
   RoundToTick_fS34_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS34 = new RoundToTick_fSStream(RoundToTick_fS34_param1);
   id = RoundToTick_fS34.Init(id);
   RoundToTick_fS35_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS35 = new RoundToTick_fSStream(RoundToTick_fS35_param1);
   id = RoundToTick_fS35.Init(id);
   RoundToTick_fS36_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS36 = new RoundToTick_fSStream(RoundToTick_fS36_param1);
   id = RoundToTick_fS36.Init(id);
   RoundToTick_fS37_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS37 = new RoundToTick_fSStream(RoundToTick_fS37_param1);
   id = RoundToTick_fS37.Init(id);
   RoundToTick_fS38_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS38 = new RoundToTick_fSStream(RoundToTick_fS38_param1);
   id = RoundToTick_fS38.Init(id);
   RoundToTick_fS39_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS39 = new RoundToTick_fSStream(RoundToTick_fS39_param1);
   id = RoundToTick_fS39.Init(id);
   RoundToTick_fS40_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS40 = new RoundToTick_fSStream(RoundToTick_fS40_param1);
   id = RoundToTick_fS40.Init(id);
   RoundToTick_fS41_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS41 = new RoundToTick_fSStream(RoundToTick_fS41_param1);
   id = RoundToTick_fS41.Init(id);
   RoundToTick_fS42_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS42 = new RoundToTick_fSStream(RoundToTick_fS42_param1);
   id = RoundToTick_fS42.Init(id);
   RoundToTick_fS43_param1 = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   RoundToTick_fS43 = new RoundToTick_fSStream(RoundToTick_fS43_param1);
   id = RoundToTick_fS43.Init(id);
   SetIndexBuffer(id++, stopLong, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, stopShort, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, position, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t3, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t4, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t5, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t6, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t7, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t8, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t9, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t10, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t11, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t12, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t13, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t14, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t15, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t16, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t17, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t18, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t19, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, t20, INDICATOR_CALCULATIONS);
   id = plot4.RegisterInternalStreams(id);
   id = plot5.RegisterInternalStreams(id);
   id = plot6.RegisterInternalStreams(id);
   id = plot7.RegisterInternalStreams(id);
   id = plot8.RegisterInternalStreams(id);
   id = plot9.RegisterInternalStreams(id);
   id = plot10.RegisterInternalStreams(id);
   id = plot11.RegisterInternalStreams(id);
   id = plot12.RegisterInternalStreams(id);
   id = plot13.RegisterInternalStreams(id);
   id = plot14.RegisterInternalStreams(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   time1.Release();
   delete is_newbar_s1;
   valuewhen1.Release();
   valuewhen2.Release();
   valuewhen3.Release();
   valuewhen4.Release();
   valuewhen5.Release();
   valuewhen6.Release();
   valuewhen7.Release();
   valuewhen8.Release();
   valuewhen9.Release();
   valuewhen10.Release();
   valuewhen11.Release();
   valuewhen12.Release();
   valuewhen13.Release();
   valuewhen14.Release();
   valuewhen15.Release();
   valuewhen16.Release();
   valuewhen17.Release();
   valuewhen18.Release();
   valuewhen19.Release();
   valuewhen20.Release();
   valuewhen21.Release();
   RoundToTick_fS2_param1.Release();
   delete RoundToTick_fS2;
   RoundToTick_fS3_param1.Release();
   delete RoundToTick_fS3;
   RoundToTick_fS4_param1.Release();
   delete RoundToTick_fS4;
   RoundToTick_fS5_param1.Release();
   delete RoundToTick_fS5;
   RoundToTick_fS6_param1.Release();
   delete RoundToTick_fS6;
   RoundToTick_fS7_param1.Release();
   delete RoundToTick_fS7;
   RoundToTick_fS8_param1.Release();
   delete RoundToTick_fS8;
   RoundToTick_fS9_param1.Release();
   delete RoundToTick_fS9;
   RoundToTick_fS10_param1.Release();
   delete RoundToTick_fS10;
   RoundToTick_fS11_param1.Release();
   delete RoundToTick_fS11;
   RoundToTick_fS12_param1.Release();
   delete RoundToTick_fS12;
   RoundToTick_fS13_param1.Release();
   delete RoundToTick_fS13;
   RoundToTick_fS14_param1.Release();
   delete RoundToTick_fS14;
   RoundToTick_fS15_param1.Release();
   delete RoundToTick_fS15;
   RoundToTick_fS16_param1.Release();
   delete RoundToTick_fS16;
   RoundToTick_fS17_param1.Release();
   delete RoundToTick_fS17;
   RoundToTick_fS18_param1.Release();
   delete RoundToTick_fS18;
   RoundToTick_fS19_param1.Release();
   delete RoundToTick_fS19;
   RoundToTick_fS20_param1.Release();
   delete RoundToTick_fS20;
   RoundToTick_fS21_param1.Release();
   delete RoundToTick_fS21;
   RoundToTick_fS22_param1.Release();
   delete RoundToTick_fS22;
   RoundToTick_fS23_param1.Release();
   delete RoundToTick_fS23;
   RoundToTick_fS24_param1.Release();
   delete RoundToTick_fS24;
   RoundToTick_fS25_param1.Release();
   delete RoundToTick_fS25;
   RoundToTick_fS26_param1.Release();
   delete RoundToTick_fS26;
   RoundToTick_fS27_param1.Release();
   delete RoundToTick_fS27;
   RoundToTick_fS28_param1.Release();
   delete RoundToTick_fS28;
   RoundToTick_fS29_param1.Release();
   delete RoundToTick_fS29;
   RoundToTick_fS30_param1.Release();
   delete RoundToTick_fS30;
   RoundToTick_fS31_param1.Release();
   delete RoundToTick_fS31;
   RoundToTick_fS32_param1.Release();
   delete RoundToTick_fS32;
   RoundToTick_fS33_param1.Release();
   delete RoundToTick_fS33;
   RoundToTick_fS34_param1.Release();
   delete RoundToTick_fS34;
   RoundToTick_fS35_param1.Release();
   delete RoundToTick_fS35;
   RoundToTick_fS36_param1.Release();
   delete RoundToTick_fS36;
   RoundToTick_fS37_param1.Release();
   delete RoundToTick_fS37;
   RoundToTick_fS38_param1.Release();
   delete RoundToTick_fS38;
   RoundToTick_fS39_param1.Release();
   delete RoundToTick_fS39;
   RoundToTick_fS40_param1.Release();
   delete RoundToTick_fS40;
   RoundToTick_fS41_param1.Release();
   delete RoundToTick_fS41;
   RoundToTick_fS42_param1.Release();
   delete RoundToTick_fS42;
   RoundToTick_fS43_param1.Release();
   delete RoundToTick_fS43;
   cross1X.Release();
   cross1Y.Release();
   cross1.Release();
   cross2X.Release();
   cross2Y.Release();
   cross2.Release();
   cross3X.Release();
   cross3Y.Release();
   cross3.Release();
   cross4X.Release();
   cross4Y.Release();
   cross4.Release();
   cross5X.Release();
   cross5Y.Release();
   cross5.Release();
   cross6X.Release();
   cross6Y.Release();
   cross6.Release();
   delete barcolor1;
   delete plot4;
   delete plot5;
   delete plot6;
   delete plot7;
   delete plot8;
   delete plot9;
   delete plot10;
   delete plot11;
   delete plot12;
   delete plot13;
   delete plot14;
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   LabelsCollection::Clear(true);
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
      is_newbar_s1.Clear();
      RoundToTick_fS2_param1.Init();
      RoundToTick_fS2.Clear();
      RoundToTick_fS3_param1.Init();
      RoundToTick_fS3.Clear();
      RoundToTick_fS4_param1.Init();
      RoundToTick_fS4.Clear();
      RoundToTick_fS5_param1.Init();
      RoundToTick_fS5.Clear();
      RoundToTick_fS6_param1.Init();
      RoundToTick_fS6.Clear();
      RoundToTick_fS7_param1.Init();
      RoundToTick_fS7.Clear();
      RoundToTick_fS8_param1.Init();
      RoundToTick_fS8.Clear();
      RoundToTick_fS9_param1.Init();
      RoundToTick_fS9.Clear();
      RoundToTick_fS10_param1.Init();
      RoundToTick_fS10.Clear();
      RoundToTick_fS11_param1.Init();
      RoundToTick_fS11.Clear();
      RoundToTick_fS12_param1.Init();
      RoundToTick_fS12.Clear();
      RoundToTick_fS13_param1.Init();
      RoundToTick_fS13.Clear();
      RoundToTick_fS14_param1.Init();
      RoundToTick_fS14.Clear();
      RoundToTick_fS15_param1.Init();
      RoundToTick_fS15.Clear();
      RoundToTick_fS16_param1.Init();
      RoundToTick_fS16.Clear();
      RoundToTick_fS17_param1.Init();
      RoundToTick_fS17.Clear();
      RoundToTick_fS18_param1.Init();
      RoundToTick_fS18.Clear();
      RoundToTick_fS19_param1.Init();
      RoundToTick_fS19.Clear();
      RoundToTick_fS20_param1.Init();
      RoundToTick_fS20.Clear();
      RoundToTick_fS21_param1.Init();
      RoundToTick_fS21.Clear();
      RoundToTick_fS22_param1.Init();
      RoundToTick_fS22.Clear();
      RoundToTick_fS23_param1.Init();
      RoundToTick_fS23.Clear();
      RoundToTick_fS24_param1.Init();
      RoundToTick_fS24.Clear();
      RoundToTick_fS25_param1.Init();
      RoundToTick_fS25.Clear();
      RoundToTick_fS26_param1.Init();
      RoundToTick_fS26.Clear();
      RoundToTick_fS27_param1.Init();
      RoundToTick_fS27.Clear();
      RoundToTick_fS28_param1.Init();
      RoundToTick_fS28.Clear();
      RoundToTick_fS29_param1.Init();
      RoundToTick_fS29.Clear();
      RoundToTick_fS30_param1.Init();
      RoundToTick_fS30.Clear();
      RoundToTick_fS31_param1.Init();
      RoundToTick_fS31.Clear();
      RoundToTick_fS32_param1.Init();
      RoundToTick_fS32.Clear();
      RoundToTick_fS33_param1.Init();
      RoundToTick_fS33.Clear();
      RoundToTick_fS34_param1.Init();
      RoundToTick_fS34.Clear();
      RoundToTick_fS35_param1.Init();
      RoundToTick_fS35.Clear();
      RoundToTick_fS36_param1.Init();
      RoundToTick_fS36.Clear();
      RoundToTick_fS37_param1.Init();
      RoundToTick_fS37.Clear();
      RoundToTick_fS38_param1.Init();
      RoundToTick_fS38.Clear();
      RoundToTick_fS39_param1.Init();
      RoundToTick_fS39.Clear();
      RoundToTick_fS40_param1.Init();
      RoundToTick_fS40.Clear();
      RoundToTick_fS41_param1.Init();
      RoundToTick_fS41.Clear();
      RoundToTick_fS42_param1.Init();
      RoundToTick_fS42.Clear();
      RoundToTick_fS43_param1.Init();
      RoundToTick_fS43.Clear();
      stopLong_DEFAULT_VALUE = SafeMinus(SafePlus(sopen, threshold), defaultStop);
      ArrayInitialize(stopLong, stopLong_DEFAULT_VALUE);
      stopShort_DEFAULT_VALUE = SafePlus(SafeMinus(sopen, threshold), defaultStop);
      ArrayInitialize(stopShort, stopShort_DEFAULT_VALUE);
      position_DEFAULT_VALUE = 0;
      ArrayInitialize(position, position_DEFAULT_VALUE);
      t1_DEFAULT_VALUE = 0;
      ArrayInitialize(t1, t1_DEFAULT_VALUE);
      t2_DEFAULT_VALUE = 0;
      ArrayInitialize(t2, t2_DEFAULT_VALUE);
      t3_DEFAULT_VALUE = 0;
      ArrayInitialize(t3, t3_DEFAULT_VALUE);
      t4_DEFAULT_VALUE = 0;
      ArrayInitialize(t4, t4_DEFAULT_VALUE);
      t5_DEFAULT_VALUE = 0;
      ArrayInitialize(t5, t5_DEFAULT_VALUE);
      t6_DEFAULT_VALUE = 0;
      ArrayInitialize(t6, t6_DEFAULT_VALUE);
      t7_DEFAULT_VALUE = 0;
      ArrayInitialize(t7, t7_DEFAULT_VALUE);
      t8_DEFAULT_VALUE = 0;
      ArrayInitialize(t8, t8_DEFAULT_VALUE);
      t9_DEFAULT_VALUE = 0;
      ArrayInitialize(t9, t9_DEFAULT_VALUE);
      t10_DEFAULT_VALUE = 0;
      ArrayInitialize(t10, t10_DEFAULT_VALUE);
      t11_DEFAULT_VALUE = 0;
      ArrayInitialize(t11, t11_DEFAULT_VALUE);
      t12_DEFAULT_VALUE = 0;
      ArrayInitialize(t12, t12_DEFAULT_VALUE);
      t13_DEFAULT_VALUE = 0;
      ArrayInitialize(t13, t13_DEFAULT_VALUE);
      t14_DEFAULT_VALUE = 0;
      ArrayInitialize(t14, t14_DEFAULT_VALUE);
      t15_DEFAULT_VALUE = 0;
      ArrayInitialize(t15, t15_DEFAULT_VALUE);
      t16_DEFAULT_VALUE = 0;
      ArrayInitialize(t16, t16_DEFAULT_VALUE);
      t17_DEFAULT_VALUE = 0;
      ArrayInitialize(t17, t17_DEFAULT_VALUE);
      t18_DEFAULT_VALUE = 0;
      ArrayInitialize(t18, t18_DEFAULT_VALUE);
      t19_DEFAULT_VALUE = 0;
      ArrayInitialize(t19, t19_DEFAULT_VALUE);
      t20_DEFAULT_VALUE = 0;
      ArrayInitialize(t20, t20_DEFAULT_VALUE);
      cross1X.Init();
      cross1Y.Init();
      cross2X.Init();
      cross2Y.Init();
      cross3X.Init();
      cross3Y.Init();
      cross4X.Init();
      cross4Y.Init();
      cross5X.Init();
      cross5Y.Init();
      cross6X.Init();
      cross6Y.Init();
      barcolor1.Init();
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      plot4.Init();
      plot5.Init();
      plot6.Init();
      plot7.Init();
      plot8.Init();
      plot9.Init();
      plot10.Init();
      plot11.Init();
      plot12.Init();
      plot13.Init();
      plot14.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      crossover1X.Init();
      crossover1Y.Init();
      ArrayInitialize(plot15, EMPTY_VALUE);
      ArrayInitialize(plot16, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      stopLong[pos] = pos > 0 ? stopLong[pos - 1] : SafeMinus(SafePlus(sopen, threshold), defaultStop);
      stopShort[pos] = pos > 0 ? stopShort[pos - 1] : SafePlus(SafeMinus(sopen, threshold), defaultStop);
      position[pos] = pos > 0 ? position[pos - 1] : 0;
      t1[pos] = pos > 0 ? t1[pos - 1] : 0;
      t2[pos] = pos > 0 ? t2[pos - 1] : 0;
      t3[pos] = pos > 0 ? t3[pos - 1] : 0;
      t4[pos] = pos > 0 ? t4[pos - 1] : 0;
      t5[pos] = pos > 0 ? t5[pos - 1] : 0;
      t6[pos] = pos > 0 ? t6[pos - 1] : 0;
      t7[pos] = pos > 0 ? t7[pos - 1] : 0;
      t8[pos] = pos > 0 ? t8[pos - 1] : 0;
      t9[pos] = pos > 0 ? t9[pos - 1] : 0;
      t10[pos] = pos > 0 ? t10[pos - 1] : 0;
      t11[pos] = pos > 0 ? t11[pos - 1] : 0;
      t12[pos] = pos > 0 ? t12[pos - 1] : 0;
      t13[pos] = pos > 0 ? t13[pos - 1] : 0;
      t14[pos] = pos > 0 ? t14[pos - 1] : 0;
      t15[pos] = pos > 0 ? t15[pos - 1] : 0;
      t16[pos] = pos > 0 ? t16[pos - 1] : 0;
      t17[pos] = pos > 0 ? t17[pos - 1] : 0;
      t18[pos] = pos > 0 ? t18[pos - 1] : 0;
      t19[pos] = pos > 0 ? t19[pos - 1] : 0;
      t20[pos] = pos > 0 ? t20[pos - 1] : 0;
      int logic = 0;
      logic = ((tradeLogic == "BreakEven After 2nd Target Hit") ? 1 : ((tradeLogic == "BreakEven After 1st Target Hit") ? 2 : EMPTY_VALUE));
      bool drawTargets = true;
      bool use_trade_session = true;
      datetime time1Value[1];
      if (!time1.GetValues(pos, 1, time1Value)) { time1Value[0] = EMPTY_VALUE; }
      bool isinsession = (use_trade_session ? !((time1Value[0]) == NULL) : true);
      int is_newbar_s1Value;
      if (!is_newbar_s1.GetValue(pos, oldPos, is_newbar_s1Value)) { is_newbar_s1Value = EMPTY_VALUE; }
      int new_day = is_newbar_s1Value;
      sopen = valuewhen1.Update(pos, time[pos], new_day, open[pos]);
      double sopen1 = valuewhen2.Update(pos, time[pos], new_day, open[pos]);
      double sopen2 = valuewhen3.Update(pos, time[pos], new_day, open[pos]);
      double sopen3 = valuewhen4.Update(pos, time[pos], new_day, open[pos]);
      double sopen4 = valuewhen5.Update(pos, time[pos], new_day, open[pos]);
      double sopen5 = valuewhen6.Update(pos, time[pos], new_day, open[pos]);
      double sopen6 = valuewhen7.Update(pos, time[pos], new_day, open[pos]);
      double sopen7 = valuewhen8.Update(pos, time[pos], new_day, open[pos]);
      double sopen8 = valuewhen9.Update(pos, time[pos], new_day, open[pos]);
      double sopen9 = valuewhen10.Update(pos, time[pos], new_day, open[pos]);
      double sopen10 = valuewhen11.Update(pos, time[pos], new_day, open[pos]);
      double sopen11 = valuewhen12.Update(pos, time[pos], new_day, open[pos]);
      double sopen12 = valuewhen13.Update(pos, time[pos], new_day, open[pos]);
      double sopen13 = valuewhen14.Update(pos, time[pos], new_day, open[pos]);
      double sopen14 = valuewhen15.Update(pos, time[pos], new_day, open[pos]);
      double sopen15 = valuewhen16.Update(pos, time[pos], new_day, open[pos]);
      double sopen16 = valuewhen17.Update(pos, time[pos], new_day, open[pos]);
      double sopen17 = valuewhen18.Update(pos, time[pos], new_day, open[pos]);
      double sopen18 = valuewhen19.Update(pos, time[pos], new_day, open[pos]);
      double sopen19 = valuewhen20.Update(pos, time[pos], new_day, open[pos]);
      double sopen20 = valuewhen21.Update(pos, time[pos], new_day, open[pos]);
      double change1 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen, sopen1)), SafeMathAbs(sopen1)), 100));
      double change2 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen2, sopen3)), SafeMathAbs(sopen3)), 100));
      double change3 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen4, sopen5)), SafeMathAbs(sopen5)), 100));
      double change4 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen6, sopen7)), SafeMathAbs(sopen7)), 100));
      double change5 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen8, sopen9)), SafeMathAbs(sopen9)), 100));
      double change6 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen1, sopen2)), SafeMathAbs(sopen2)), 100));
      double change7 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen3, sopen4)), SafeMathAbs(sopen4)), 100));
      double change8 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen5, sopen6)), SafeMathAbs(sopen6)), 100));
      double change9 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen7, sopen8)), SafeMathAbs(sopen8)), 100));
      double change10 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen9, sopen10)), SafeMathAbs(sopen10)), 100));
      double change11 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen10, sopen11)), SafeMathAbs(sopen11)), 100));
      double change12 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen11, sopen12)), SafeMathAbs(sopen12)), 100));
      double change13 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen12, sopen13)), SafeMathAbs(sopen13)), 100));
      double change14 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen13, sopen14)), SafeMathAbs(sopen14)), 100));
      double change15 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen14, sopen15)), SafeMathAbs(sopen15)), 100));
      double change16 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen15, sopen16)), SafeMathAbs(sopen16)), 100));
      double change17 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen16, sopen17)), SafeMathAbs(sopen17)), 100));
      double change18 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen17, sopen18)), SafeMathAbs(sopen18)), 100));
      double change19 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen18, sopen19)), SafeMathAbs(sopen19)), 100));
      double change20 = SafeMathAbs(SafeMultiply(SafeDivide((SafeMinus(sopen19, sopen20)), SafeMathAbs(sopen20)), 100));
      int calculation = 0;
      calculation = ((calculationMethod == "10-Day Average Absolute %-Change") ? 1 : ((calculationMethod == "5-Day Average Absolute %-Change") ? 2 : ((calculationMethod == "20-Day Average Absolute %-Change") ? 3 : EMPTY_VALUE)));
      double avgChange = 0.0;
      avgChange = ((calculation == 3) ? SafeDivide((SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(change1, change2), change3), change4), change5), change6), change7), change8), change9), change10), change11), change12), change13), change14), change15), change16), change17), change18), change19), change20)), 20) : ((calculation == 2) ? SafeDivide((SafePlus(SafePlus(SafePlus(SafePlus(change1, change6), change2), change7), change3)), 5) : ((calculation == 1) ? SafeDivide((SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(change1, change2), change3), change4), change5), change6), change7), change8), change9), change10)), 10) : EMPTY_VALUE)));
      avgChange = avgChange * targetMultiple;
      defaultStop = SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * param8, 100), sopen);
      RoundToTick_fS2_param1.SetValue(pos, defaultStop);
      double RoundToTick_fS2Value;
      if (!RoundToTick_fS2.GetValue(pos, oldPos, RoundToTick_fS2Value)) { RoundToTick_fS2Value = EMPTY_VALUE; }
      defaultStop = RoundToTick_fS2Value;
      bool useThreshold = true;
      double defaultThreshold = SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * param9, 100), sopen);
      RoundToTick_fS3_param1.SetValue(pos, defaultThreshold);
      double RoundToTick_fS3Value;
      if (!RoundToTick_fS3.GetValue(pos, oldPos, RoundToTick_fS3Value)) { RoundToTick_fS3Value = EMPTY_VALUE; }
      defaultThreshold = RoundToTick_fS3Value;
      threshold = defaultThreshold;
      RoundToTick_fS4_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 2, 100), sopen), sopen), threshold));
      double RoundToTick_fS4Value;
      if (!RoundToTick_fS4.GetValue(pos, oldPos, RoundToTick_fS4Value)) { RoundToTick_fS4Value = EMPTY_VALUE; }
      double target1 = RoundToTick_fS4Value;
      RoundToTick_fS5_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 2, 100), sopen), sopen), threshold));
      double RoundToTick_fS5Value;
      if (!RoundToTick_fS5.GetValue(pos, oldPos, RoundToTick_fS5Value)) { RoundToTick_fS5Value = EMPTY_VALUE; }
      double target2 = RoundToTick_fS5Value;
      RoundToTick_fS6_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 4.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS6Value;
      if (!RoundToTick_fS6.GetValue(pos, oldPos, RoundToTick_fS6Value)) { RoundToTick_fS6Value = EMPTY_VALUE; }
      double target3 = RoundToTick_fS6Value;
      RoundToTick_fS7_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 4.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS7Value;
      if (!RoundToTick_fS7.GetValue(pos, oldPos, RoundToTick_fS7Value)) { RoundToTick_fS7Value = EMPTY_VALUE; }
      double target4 = RoundToTick_fS7Value;
      RoundToTick_fS8_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 7, 100), sopen), sopen), threshold));
      double RoundToTick_fS8Value;
      if (!RoundToTick_fS8.GetValue(pos, oldPos, RoundToTick_fS8Value)) { RoundToTick_fS8Value = EMPTY_VALUE; }
      double target5 = RoundToTick_fS8Value;
      RoundToTick_fS9_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 7, 100), sopen), sopen), threshold));
      double RoundToTick_fS9Value;
      if (!RoundToTick_fS9.GetValue(pos, oldPos, RoundToTick_fS9Value)) { RoundToTick_fS9Value = EMPTY_VALUE; }
      double target6 = RoundToTick_fS9Value;
      RoundToTick_fS10_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 9.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS10Value;
      if (!RoundToTick_fS10.GetValue(pos, oldPos, RoundToTick_fS10Value)) { RoundToTick_fS10Value = EMPTY_VALUE; }
      double target7 = RoundToTick_fS10Value;
      RoundToTick_fS11_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 9.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS11Value;
      if (!RoundToTick_fS11.GetValue(pos, oldPos, RoundToTick_fS11Value)) { RoundToTick_fS11Value = EMPTY_VALUE; }
      double target8 = RoundToTick_fS11Value;
      RoundToTick_fS12_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 12, 100), sopen), sopen), threshold));
      double RoundToTick_fS12Value;
      if (!RoundToTick_fS12.GetValue(pos, oldPos, RoundToTick_fS12Value)) { RoundToTick_fS12Value = EMPTY_VALUE; }
      double target9 = RoundToTick_fS12Value;
      RoundToTick_fS13_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 12, 100), sopen), sopen), threshold));
      double RoundToTick_fS13Value;
      if (!RoundToTick_fS13.GetValue(pos, oldPos, RoundToTick_fS13Value)) { RoundToTick_fS13Value = EMPTY_VALUE; }
      double target10 = RoundToTick_fS13Value;
      RoundToTick_fS14_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 2, 100), sopen))));
      double RoundToTick_fS14Value;
      if (!RoundToTick_fS14.GetValue(pos, oldPos, RoundToTick_fS14Value)) { RoundToTick_fS14Value = EMPTY_VALUE; }
      double target11 = RoundToTick_fS14Value;
      RoundToTick_fS15_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 2, 100), sopen))));
      double RoundToTick_fS15Value;
      if (!RoundToTick_fS15.GetValue(pos, oldPos, RoundToTick_fS15Value)) { RoundToTick_fS15Value = EMPTY_VALUE; }
      double target12 = RoundToTick_fS15Value;
      RoundToTick_fS16_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 4.5, 100), sopen))));
      double RoundToTick_fS16Value;
      if (!RoundToTick_fS16.GetValue(pos, oldPos, RoundToTick_fS16Value)) { RoundToTick_fS16Value = EMPTY_VALUE; }
      double target13 = RoundToTick_fS16Value;
      RoundToTick_fS17_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 4.5, 100), sopen))));
      double RoundToTick_fS17Value;
      if (!RoundToTick_fS17.GetValue(pos, oldPos, RoundToTick_fS17Value)) { RoundToTick_fS17Value = EMPTY_VALUE; }
      double target14 = RoundToTick_fS17Value;
      RoundToTick_fS18_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 7, 100), sopen))));
      double RoundToTick_fS18Value;
      if (!RoundToTick_fS18.GetValue(pos, oldPos, RoundToTick_fS18Value)) { RoundToTick_fS18Value = EMPTY_VALUE; }
      double target15 = RoundToTick_fS18Value;
      RoundToTick_fS19_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 7, 100), sopen))));
      double RoundToTick_fS19Value;
      if (!RoundToTick_fS19.GetValue(pos, oldPos, RoundToTick_fS19Value)) { RoundToTick_fS19Value = EMPTY_VALUE; }
      double target16 = RoundToTick_fS19Value;
      RoundToTick_fS20_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 9.5, 100), sopen))));
      double RoundToTick_fS20Value;
      if (!RoundToTick_fS20.GetValue(pos, oldPos, RoundToTick_fS20Value)) { RoundToTick_fS20Value = EMPTY_VALUE; }
      double target17 = RoundToTick_fS20Value;
      RoundToTick_fS21_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 9.5, 100), sopen))));
      double RoundToTick_fS21Value;
      if (!RoundToTick_fS21.GetValue(pos, oldPos, RoundToTick_fS21Value)) { RoundToTick_fS21Value = EMPTY_VALUE; }
      double target18 = RoundToTick_fS21Value;
      RoundToTick_fS22_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 12, 100), sopen))));
      double RoundToTick_fS22Value;
      if (!RoundToTick_fS22.GetValue(pos, oldPos, RoundToTick_fS22Value)) { RoundToTick_fS22Value = EMPTY_VALUE; }
      double target19 = RoundToTick_fS22Value;
      RoundToTick_fS23_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 12, 100), sopen))));
      double RoundToTick_fS23Value;
      if (!RoundToTick_fS23.GetValue(pos, oldPos, RoundToTick_fS23Value)) { RoundToTick_fS23Value = EMPTY_VALUE; }
      double target20 = RoundToTick_fS23Value;
      RoundToTick_fS24_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 14.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS24Value;
      if (!RoundToTick_fS24.GetValue(pos, oldPos, RoundToTick_fS24Value)) { RoundToTick_fS24Value = EMPTY_VALUE; }
      double Target11 = RoundToTick_fS24Value;
      RoundToTick_fS25_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 14.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS25Value;
      if (!RoundToTick_fS25.GetValue(pos, oldPos, RoundToTick_fS25Value)) { RoundToTick_fS25Value = EMPTY_VALUE; }
      double Target12 = RoundToTick_fS25Value;
      RoundToTick_fS26_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 16.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS26Value;
      if (!RoundToTick_fS26.GetValue(pos, oldPos, RoundToTick_fS26Value)) { RoundToTick_fS26Value = EMPTY_VALUE; }
      double Target13 = RoundToTick_fS26Value;
      RoundToTick_fS27_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 16.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS27Value;
      if (!RoundToTick_fS27.GetValue(pos, oldPos, RoundToTick_fS27Value)) { RoundToTick_fS27Value = EMPTY_VALUE; }
      double Target14 = RoundToTick_fS27Value;
      RoundToTick_fS28_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 18.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS28Value;
      if (!RoundToTick_fS28.GetValue(pos, oldPos, RoundToTick_fS28Value)) { RoundToTick_fS28Value = EMPTY_VALUE; }
      double Target15 = RoundToTick_fS28Value;
      RoundToTick_fS29_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 18.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS29Value;
      if (!RoundToTick_fS29.GetValue(pos, oldPos, RoundToTick_fS29Value)) { RoundToTick_fS29Value = EMPTY_VALUE; }
      double Target16 = RoundToTick_fS29Value;
      RoundToTick_fS30_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 20.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS30Value;
      if (!RoundToTick_fS30.GetValue(pos, oldPos, RoundToTick_fS30Value)) { RoundToTick_fS30Value = EMPTY_VALUE; }
      double Target17 = RoundToTick_fS30Value;
      RoundToTick_fS31_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 20.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS31Value;
      if (!RoundToTick_fS31.GetValue(pos, oldPos, RoundToTick_fS31Value)) { RoundToTick_fS31Value = EMPTY_VALUE; }
      double Target18 = RoundToTick_fS31Value;
      RoundToTick_fS32_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 22.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS32Value;
      if (!RoundToTick_fS32.GetValue(pos, oldPos, RoundToTick_fS32Value)) { RoundToTick_fS32Value = EMPTY_VALUE; }
      double Target19 = RoundToTick_fS32Value;
      RoundToTick_fS33_param1.SetValue(pos, SafePlus(SafePlus(SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 22.5, 100), sopen), sopen), threshold));
      double RoundToTick_fS33Value;
      if (!RoundToTick_fS33.GetValue(pos, oldPos, RoundToTick_fS33Value)) { RoundToTick_fS33Value = EMPTY_VALUE; }
      double Target20 = RoundToTick_fS33Value;
      RoundToTick_fS34_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 14.5, 100), sopen))));
      double RoundToTick_fS34Value;
      if (!RoundToTick_fS34.GetValue(pos, oldPos, RoundToTick_fS34Value)) { RoundToTick_fS34Value = EMPTY_VALUE; }
      double Target21 = RoundToTick_fS34Value;
      RoundToTick_fS35_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 14.5, 100), sopen))));
      double RoundToTick_fS35Value;
      if (!RoundToTick_fS35.GetValue(pos, oldPos, RoundToTick_fS35Value)) { RoundToTick_fS35Value = EMPTY_VALUE; }
      double Target22 = RoundToTick_fS35Value;
      RoundToTick_fS36_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 16.5, 100), sopen))));
      double RoundToTick_fS36Value;
      if (!RoundToTick_fS36.GetValue(pos, oldPos, RoundToTick_fS36Value)) { RoundToTick_fS36Value = EMPTY_VALUE; }
      double Target23 = RoundToTick_fS36Value;
      RoundToTick_fS37_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 16.5, 100), sopen))));
      double RoundToTick_fS37Value;
      if (!RoundToTick_fS37.GetValue(pos, oldPos, RoundToTick_fS37Value)) { RoundToTick_fS37Value = EMPTY_VALUE; }
      double Target24 = RoundToTick_fS37Value;
      RoundToTick_fS38_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 18.5, 100), sopen))));
      double RoundToTick_fS38Value;
      if (!RoundToTick_fS38.GetValue(pos, oldPos, RoundToTick_fS38Value)) { RoundToTick_fS38Value = EMPTY_VALUE; }
      double Target25 = RoundToTick_fS38Value;
      RoundToTick_fS39_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 18.5, 100), sopen))));
      double RoundToTick_fS39Value;
      if (!RoundToTick_fS39.GetValue(pos, oldPos, RoundToTick_fS39Value)) { RoundToTick_fS39Value = EMPTY_VALUE; }
      double Target26 = RoundToTick_fS39Value;
      RoundToTick_fS40_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 20.5, 100), sopen))));
      double RoundToTick_fS40Value;
      if (!RoundToTick_fS40.GetValue(pos, oldPos, RoundToTick_fS40Value)) { RoundToTick_fS40Value = EMPTY_VALUE; }
      double Target27 = RoundToTick_fS40Value;
      RoundToTick_fS41_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 20.5, 100), sopen))));
      double RoundToTick_fS41Value;
      if (!RoundToTick_fS41.GetValue(pos, oldPos, RoundToTick_fS41Value)) { RoundToTick_fS41Value = EMPTY_VALUE; }
      double Target28 = RoundToTick_fS41Value;
      RoundToTick_fS42_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 22.5, 100), sopen))));
      double RoundToTick_fS42Value;
      if (!RoundToTick_fS42.GetValue(pos, oldPos, RoundToTick_fS42Value)) { RoundToTick_fS42Value = EMPTY_VALUE; }
      double Target29 = RoundToTick_fS42Value;
      RoundToTick_fS43_param1.SetValue(pos, SafeMinus(SafeMinus(sopen, threshold), (SafeMultiply(SafeDivide(SafeDivide(avgChange, 5) * 22.5, 100), sopen))));
      double RoundToTick_fS43Value;
      if (!RoundToTick_fS43.GetValue(pos, oldPos, RoundToTick_fS43Value)) { RoundToTick_fS43Value = EMPTY_VALUE; }
      double Target30 = RoundToTick_fS43Value;
      double hardStopLong = SafeMinus(SafePlus(sopen, threshold), defaultStop);
      double hardStopShort = SafePlus(SafeMinus(sopen, threshold), defaultStop);
      double defaultLimitLong = SafePlus(sopen, threshold);
      double defaultLimitShort = SafeMinus(sopen, threshold);
      double buy_line = SafePlus(sopen, threshold);
      double sel_line = SafeMinus(sopen, threshold);
      double limitLong = (isinsession ? buy_line : EMPTY_VALUE);
      double limitShort = (isinsession ? sel_line : EMPTY_VALUE);
      if (NumberToBool(new_day))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         SetStream(t1, pos, 0, t1_DEFAULT_VALUE);
         SetStream(t2, pos, 0, t2_DEFAULT_VALUE);
         SetStream(t3, pos, 0, t3_DEFAULT_VALUE);
         SetStream(t4, pos, 0, t4_DEFAULT_VALUE);
         SetStream(t5, pos, 0, t5_DEFAULT_VALUE);
         SetStream(t6, pos, 0, t6_DEFAULT_VALUE);
         SetStream(t7, pos, 0, t7_DEFAULT_VALUE);
         SetStream(t8, pos, 0, t8_DEFAULT_VALUE);
         SetStream(t9, pos, 0, t9_DEFAULT_VALUE);
         SetStream(t10, pos, 0, t10_DEFAULT_VALUE);
         SetStream(t11, pos, 0, t11_DEFAULT_VALUE);
         SetStream(t12, pos, 0, t12_DEFAULT_VALUE);
         SetStream(t13, pos, 0, t13_DEFAULT_VALUE);
         SetStream(t14, pos, 0, t14_DEFAULT_VALUE);
         SetStream(t15, pos, 0, t15_DEFAULT_VALUE);
         SetStream(t16, pos, 0, t16_DEFAULT_VALUE);
         SetStream(t17, pos, 0, t17_DEFAULT_VALUE);
         SetStream(t18, pos, 0, t18_DEFAULT_VALUE);
         SetStream(t19, pos, 0, t19_DEFAULT_VALUE);
         SetStream(t20, pos, 0, t20_DEFAULT_VALUE);
      }
      cross1X.SetValue(pos, high[pos]);
      cross1Y.SetValue(pos, limitLong);
      bool cross1Value[1];
      if (!cross1.GetValues(pos, 1, cross1Value)) { cross1Value[0] = EMPTY_VALUE; }
      if ((isinsession && cross1Value[0] || (high[pos] == limitLong) && (position[pos] == 0)))
      {
         SetStream(position, pos, 1, position_DEFAULT_VALUE);
      }
      cross2X.SetValue(pos, high[pos]);
      cross2Y.SetValue(pos, target1);
      bool cross2Value[1];
      if (!cross2.GetValues(pos, 1, cross2Value)) { cross2Value[0] = EMPTY_VALUE; }
      if ((cross2Value[0] || (high[pos] == target1)))
      {
         SetStream(t1, pos, 1, t1_DEFAULT_VALUE);
         SetStream(t2, pos, 1, t2_DEFAULT_VALUE);
      }
      cross3X.SetValue(pos, high[pos]);
      cross3Y.SetValue(pos, target3);
      bool cross3Value[1];
      if (!cross3.GetValues(pos, 1, cross3Value)) { cross3Value[0] = EMPTY_VALUE; }
      if ((cross3Value[0] || (high[pos] == target3)))
      {
         SetStream(t3, pos, 1, t3_DEFAULT_VALUE);
         SetStream(t4, pos, 1, t4_DEFAULT_VALUE);
      }
      cross4X.SetValue(pos, high[pos]);
      cross4Y.SetValue(pos, target5);
      bool cross4Value[1];
      if (!cross4.GetValues(pos, 1, cross4Value)) { cross4Value[0] = EMPTY_VALUE; }
      if ((cross4Value[0] || (high[pos] == target5)))
      {
         SetStream(t5, pos, 1, t5_DEFAULT_VALUE);
         SetStream(t6, pos, 1, t6_DEFAULT_VALUE);
      }
      cross5X.SetValue(pos, high[pos]);
      cross5Y.SetValue(pos, target7);
      bool cross5Value[1];
      if (!cross5.GetValues(pos, 1, cross5Value)) { cross5Value[0] = EMPTY_VALUE; }
      if ((cross5Value[0] || (high[pos] == target7)))
      {
         SetStream(t7, pos, 1, t7_DEFAULT_VALUE);
         SetStream(t8, pos, 1, t8_DEFAULT_VALUE);
      }
      cross6X.SetValue(pos, high[pos]);
      cross6Y.SetValue(pos, target9);
      bool cross6Value[1];
      if (!cross6.GetValues(pos, 1, cross6Value)) { cross6Value[0] = EMPTY_VALUE; }
      if ((cross6Value[0] || (high[pos] == target9)))
      {
         SetStream(t9, pos, 1, t9_DEFAULT_VALUE);
         SetStream(t10, pos, 1, t10_DEFAULT_VALUE);
      }
      if ((isinsession && SafeLess(low[pos], limitShort) || (low[pos] == limitShort) && (position[pos] == 0)))
      {
         SetStream(position, pos, 2, position_DEFAULT_VALUE);
      }
      if ((SafeLess(low[pos], target11) || (low[pos] == target11) && (position[pos] == 2)))
      {
         SetStream(t11, pos, 1, t11_DEFAULT_VALUE);
         SetStream(t12, pos, 1, t12_DEFAULT_VALUE);
      }
      if ((SafeLess(low[pos], target13) || (low[pos] == target13) && (position[pos] == 2)))
      {
         SetStream(t13, pos, 1, t13_DEFAULT_VALUE);
         SetStream(t14, pos, 1, t14_DEFAULT_VALUE);
      }
      if ((SafeLess(low[pos], target15) || (low[pos] == target15) && (position[pos] == 2)))
      {
         SetStream(t15, pos, 1, t15_DEFAULT_VALUE);
         SetStream(t16, pos, 1, t16_DEFAULT_VALUE);
      }
      if ((SafeLess(low[pos], target17) || (low[pos] == target17) && (position[pos] == 2)))
      {
         SetStream(t17, pos, 1, t17_DEFAULT_VALUE);
         SetStream(t18, pos, 1, t18_DEFAULT_VALUE);
      }
      if ((SafeLess(low[pos], target19) || (low[pos] == target19) && (position[pos] == 2)))
      {
         SetStream(t19, pos, 1, t19_DEFAULT_VALUE);
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(t20, pos, 1, t20_DEFAULT_VALUE);
      }
      if (((position[pos] == 1) && SafeLess(low[pos], limitShort) || (low[pos] == limitShort)))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         SetStream(t1, pos, 0, t1_DEFAULT_VALUE);
         SetStream(t2, pos, 0, t2_DEFAULT_VALUE);
         SetStream(t3, pos, 0, t3_DEFAULT_VALUE);
         SetStream(t4, pos, 0, t4_DEFAULT_VALUE);
         SetStream(t5, pos, 0, t5_DEFAULT_VALUE);
         SetStream(t6, pos, 0, t6_DEFAULT_VALUE);
         SetStream(t7, pos, 0, t7_DEFAULT_VALUE);
         SetStream(t8, pos, 0, t8_DEFAULT_VALUE);
         SetStream(t9, pos, 0, t9_DEFAULT_VALUE);
         SetStream(t10, pos, 0, t10_DEFAULT_VALUE);
      }
      if ((position[pos] == 1) && SafeLess(open[pos], limitShort))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         SetStream(t1, pos, 0, t1_DEFAULT_VALUE);
         SetStream(t2, pos, 0, t2_DEFAULT_VALUE);
         SetStream(t3, pos, 0, t3_DEFAULT_VALUE);
         SetStream(t4, pos, 0, t4_DEFAULT_VALUE);
         SetStream(t5, pos, 0, t5_DEFAULT_VALUE);
         SetStream(t6, pos, 0, t6_DEFAULT_VALUE);
         SetStream(t7, pos, 0, t7_DEFAULT_VALUE);
         SetStream(t8, pos, 0, t8_DEFAULT_VALUE);
         SetStream(t9, pos, 0, t9_DEFAULT_VALUE);
         SetStream(t10, pos, 0, t10_DEFAULT_VALUE);
      }
      if (((position[pos] == 2) && SafeGreater(high[pos], limitLong) || (high[pos] == limitLong)))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         SetStream(t11, pos, 0, t11_DEFAULT_VALUE);
         SetStream(t12, pos, 0, t12_DEFAULT_VALUE);
         SetStream(t13, pos, 0, t13_DEFAULT_VALUE);
         SetStream(t14, pos, 0, t14_DEFAULT_VALUE);
         SetStream(t15, pos, 0, t15_DEFAULT_VALUE);
         SetStream(t16, pos, 0, t16_DEFAULT_VALUE);
         SetStream(t17, pos, 0, t17_DEFAULT_VALUE);
         SetStream(t18, pos, 0, t18_DEFAULT_VALUE);
         SetStream(t19, pos, 0, t19_DEFAULT_VALUE);
         SetStream(t20, pos, 0, t20_DEFAULT_VALUE);
      }
      if ((position[pos] == 2) && SafeGreater(open[pos], limitLong))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         SetStream(t11, pos, 0, t11_DEFAULT_VALUE);
         SetStream(t12, pos, 0, t12_DEFAULT_VALUE);
         SetStream(t13, pos, 0, t13_DEFAULT_VALUE);
         SetStream(t14, pos, 0, t14_DEFAULT_VALUE);
         SetStream(t15, pos, 0, t15_DEFAULT_VALUE);
         SetStream(t16, pos, 0, t16_DEFAULT_VALUE);
         SetStream(t17, pos, 0, t17_DEFAULT_VALUE);
         SetStream(t18, pos, 0, t18_DEFAULT_VALUE);
         SetStream(t19, pos, 0, t19_DEFAULT_VALUE);
         SetStream(t20, pos, 0, t20_DEFAULT_VALUE);
      }
      if ((position[pos] == 0))
      {
         SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         SetStream(t1, pos, 0, t1_DEFAULT_VALUE);
         SetStream(t2, pos, 0, t2_DEFAULT_VALUE);
         SetStream(t3, pos, 0, t3_DEFAULT_VALUE);
         SetStream(t4, pos, 0, t4_DEFAULT_VALUE);
         SetStream(t5, pos, 0, t5_DEFAULT_VALUE);
         SetStream(t6, pos, 0, t6_DEFAULT_VALUE);
         SetStream(t7, pos, 0, t7_DEFAULT_VALUE);
         SetStream(t8, pos, 0, t8_DEFAULT_VALUE);
         SetStream(t9, pos, 0, t9_DEFAULT_VALUE);
         SetStream(t10, pos, 0, t10_DEFAULT_VALUE);
         SetStream(t11, pos, 0, t11_DEFAULT_VALUE);
         SetStream(t12, pos, 0, t12_DEFAULT_VALUE);
         SetStream(t13, pos, 0, t13_DEFAULT_VALUE);
         SetStream(t14, pos, 0, t14_DEFAULT_VALUE);
         SetStream(t15, pos, 0, t15_DEFAULT_VALUE);
         SetStream(t16, pos, 0, t16_DEFAULT_VALUE);
         SetStream(t17, pos, 0, t17_DEFAULT_VALUE);
         SetStream(t18, pos, 0, t18_DEFAULT_VALUE);
         SetStream(t19, pos, 0, t19_DEFAULT_VALUE);
         SetStream(t20, pos, 0, t20_DEFAULT_VALUE);
      }
      uint color1 = ((chartColor == "Dark Mode") ? White : Black);
      barcolor1.Set(pos, open[pos], high[pos], low[pos], close[pos], ((position[pos] == 1) ? Lime : ((position[pos] == 2) ? Red : color1)));
      plot2[pos] = limitLong;
      plot3[pos] = limitShort;
      plot4.Set(pos, sopen, color1);
      Label* openLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", pos, sopen, time[pos]).SetText("Daily Open Price").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
      Label* longLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", pos, limitLong, time[pos]).SetText("Long Limit Price").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
      Label* shortLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", pos, limitShort, time[pos]).SetText("Short Limit Price").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
      Label* longStopLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_4_id", pos, stopLong[pos], time[pos]).SetText("Long Hard Stop").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
      Label* shortStopLabel = LabelsCollection::Create(IndicatorObjPrefix + "label_5_id", pos, stopShort[pos], time[pos]).SetText("Short Hard Stop").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
      LabelsCollection::Delete(LabelsCollection::Get(openLabel, 1));
      LabelsCollection::Delete(LabelsCollection::Get(longLabel, 1));
      LabelsCollection::Delete(LabelsCollection::Get(shortLabel, 1));
      LabelsCollection::Delete(LabelsCollection::Get(longStopLabel, 1));
      LabelsCollection::Delete(LabelsCollection::Get(shortStopLabel, 1));
      if (drawTargets)
      {
         Label* target1Label = LabelsCollection::Create(IndicatorObjPrefix + "label_6_id", pos, target1, time[pos]).SetText("Long Target 1").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         Label* target3Label = LabelsCollection::Create(IndicatorObjPrefix + "label_7_id", pos, target3, time[pos]).SetText("Long Target 3").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         Label* target5Label = LabelsCollection::Create(IndicatorObjPrefix + "label_8_id", pos, target5, time[pos]).SetText("Long Target 5").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         LabelsCollection::Delete(LabelsCollection::Get(target1Label, 1));
         LabelsCollection::Delete(LabelsCollection::Get(target3Label, 1));
         LabelsCollection::Delete(LabelsCollection::Get(target5Label, 1));
         Label* target7Label = LabelsCollection::Create(IndicatorObjPrefix + "label_9_id", pos, target7, time[pos]).SetText("Long Target 7").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         Label* target9Label = LabelsCollection::Create(IndicatorObjPrefix + "label_10_id", pos, target9, time[pos]).SetText("Long Target 9").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         LabelsCollection::Delete(LabelsCollection::Get(target7Label, 1));
         LabelsCollection::Delete(LabelsCollection::Get(target9Label, 1));
         Label* target11Label = LabelsCollection::Create(IndicatorObjPrefix + "label_11_id", pos, target11, time[pos]).SetText("Short Target 1").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         Label* target13Label = LabelsCollection::Create(IndicatorObjPrefix + "label_12_id", pos, target13, time[pos]).SetText("Short Target 3").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         Label* target15Label = LabelsCollection::Create(IndicatorObjPrefix + "label_13_id", pos, target15, time[pos]).SetText("Short Target 5").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         LabelsCollection::Delete(LabelsCollection::Get(target11Label, 1));
         LabelsCollection::Delete(LabelsCollection::Get(target13Label, 1));
         LabelsCollection::Delete(LabelsCollection::Get(target15Label, 1));
         Label* target17Label = LabelsCollection::Create(IndicatorObjPrefix + "label_14_id", pos, target17, time[pos]).SetText("Short Target 7").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         Label* target19Label = LabelsCollection::Create(IndicatorObjPrefix + "label_15_id", pos, target19, time[pos]).SetText("Short Target 9").SetTextColor(color1).SetStyle("none").SetSize("small").SetYLoc("price");
         LabelsCollection::Delete(LabelsCollection::Get(target17Label, 1));
         LabelsCollection::Delete(LabelsCollection::Get(target19Label, 1));
      }
      plot5.Set(pos, target1, color1);
      plot6.Set(pos, target3, color1);
      plot7.Set(pos, target5, color1);
      plot8.Set(pos, target7, color1);
      plot9.Set(pos, target9, color1);
      plot10.Set(pos, target11, color1);
      plot11.Set(pos, target13, color1);
      plot12.Set(pos, target15, color1);
      plot13.Set(pos, target17, color1);
      plot14.Set(pos, target19, color1);
      if ((tradeLogic == "BreakEven After 1st Target Hit"))
      {
         if (NumberToBool(t1[pos]) && !NumberToBool(t3[pos]))
         {
            SetStream(stopLong, pos, limitLong, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t3[pos]) && !NumberToBool(t5[pos]))
         {
            SetStream(stopLong, pos, target1, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t5[pos]) && !NumberToBool(t7[pos]))
         {
            SetStream(stopLong, pos, target3, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t7[pos]) && !NumberToBool(t9[pos]))
         {
            SetStream(stopLong, pos, target5, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t9[pos]))
         {
            SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t11[pos]) && !NumberToBool(t13[pos]))
         {
            SetStream(stopShort, pos, limitShort, stopShort_DEFAULT_VALUE);
         }
         if (NumberToBool(t13[pos]) && !NumberToBool(t15[pos]))
         {
            SetStream(stopShort, pos, target11, stopShort_DEFAULT_VALUE);
         }
         if (NumberToBool(t15[pos]) && !NumberToBool(t17[pos]))
         {
            SetStream(stopShort, pos, target13, stopShort_DEFAULT_VALUE);
         }
         if (NumberToBool(t17[pos]) && !NumberToBool(t19[pos]))
         {
            SetStream(stopShort, pos, target15, stopShort_DEFAULT_VALUE);
         }
         if (NumberToBool(t19[pos]))
         {
            SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         }
      }
      if ((tradeLogic == "BreakEven After 2nd Target Hit"))
      {
         if (NumberToBool(t3[pos]) && !NumberToBool(t5[pos]))
         {
            SetStream(stopLong, pos, target1, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t5[pos]) && !NumberToBool(t7[pos]))
         {
            SetStream(stopLong, pos, target3, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t7[pos]) && !NumberToBool(t9[pos]))
         {
            SetStream(stopLong, pos, target5, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t9[pos]))
         {
            SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         }
         if (NumberToBool(t13[pos]) && !NumberToBool(t15[pos]))
         {
            SetStream(stopShort, pos, target1, stopShort_DEFAULT_VALUE);
         }
         if (NumberToBool(t15[pos]) && !NumberToBool(t17[pos]))
         {
            SetStream(stopShort, pos, target13, stopShort_DEFAULT_VALUE);
         }
         if (NumberToBool(t17[pos]) && !NumberToBool(t19[pos]))
         {
            SetStream(stopShort, pos, target15, stopShort_DEFAULT_VALUE);
         }
         if (NumberToBool(t19[pos]))
         {
            SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         }
      }
      crossunder1X.SetValue(pos, low[pos]);
      crossunder1Y.SetValue(pos, limitShort);
      bool crossunder1Value[1];
      if (!crossunder1.GetValues(pos, 1, crossunder1Value)) { crossunder1Value[0] = EMPTY_VALUE; }
      if (((position[pos] == 1) && crossunder1Value[0] || (low[pos] == limitShort)))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         SetStream(t1, pos, 0, t1_DEFAULT_VALUE);
         SetStream(t2, pos, 0, t2_DEFAULT_VALUE);
         SetStream(t3, pos, 0, t3_DEFAULT_VALUE);
         SetStream(t4, pos, 0, t4_DEFAULT_VALUE);
         SetStream(t5, pos, 0, t5_DEFAULT_VALUE);
         SetStream(t6, pos, 0, t6_DEFAULT_VALUE);
         SetStream(t7, pos, 0, t7_DEFAULT_VALUE);
         SetStream(t8, pos, 0, t8_DEFAULT_VALUE);
         SetStream(t9, pos, 0, t9_DEFAULT_VALUE);
         SetStream(t10, pos, 0, t10_DEFAULT_VALUE);
      }
      if ((position[pos] == 1) && SafeLess(open[pos], limitShort))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         SetStream(t1, pos, 0, t1_DEFAULT_VALUE);
         SetStream(t2, pos, 0, t2_DEFAULT_VALUE);
         SetStream(t3, pos, 0, t3_DEFAULT_VALUE);
         SetStream(t4, pos, 0, t4_DEFAULT_VALUE);
         SetStream(t5, pos, 0, t5_DEFAULT_VALUE);
         SetStream(t6, pos, 0, t6_DEFAULT_VALUE);
         SetStream(t7, pos, 0, t7_DEFAULT_VALUE);
         SetStream(t8, pos, 0, t8_DEFAULT_VALUE);
         SetStream(t9, pos, 0, t9_DEFAULT_VALUE);
         SetStream(t10, pos, 0, t10_DEFAULT_VALUE);
      }
      crossover1X.SetValue(pos, high[pos]);
      crossover1Y.SetValue(pos, limitLong);
      bool crossover1Value[1];
      if (!crossover1.GetValues(pos, 1, crossover1Value)) { crossover1Value[0] = EMPTY_VALUE; }
      if (((position[pos] == 2) && crossover1Value[0] || (high[pos] == limitLong)))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         SetStream(t11, pos, 0, t11_DEFAULT_VALUE);
         SetStream(t12, pos, 0, t12_DEFAULT_VALUE);
         SetStream(t13, pos, 0, t13_DEFAULT_VALUE);
         SetStream(t14, pos, 0, t14_DEFAULT_VALUE);
         SetStream(t15, pos, 0, t15_DEFAULT_VALUE);
         SetStream(t16, pos, 0, t16_DEFAULT_VALUE);
         SetStream(t17, pos, 0, t17_DEFAULT_VALUE);
         SetStream(t18, pos, 0, t18_DEFAULT_VALUE);
         SetStream(t19, pos, 0, t19_DEFAULT_VALUE);
         SetStream(t20, pos, 0, t20_DEFAULT_VALUE);
      }
      if ((position[pos] == 2) && SafeGreater(open[pos], limitLong))
      {
         SetStream(position, pos, 0, position_DEFAULT_VALUE);
         SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         SetStream(t11, pos, 0, t11_DEFAULT_VALUE);
         SetStream(t12, pos, 0, t12_DEFAULT_VALUE);
         SetStream(t13, pos, 0, t13_DEFAULT_VALUE);
         SetStream(t14, pos, 0, t14_DEFAULT_VALUE);
         SetStream(t15, pos, 0, t15_DEFAULT_VALUE);
         SetStream(t16, pos, 0, t16_DEFAULT_VALUE);
         SetStream(t17, pos, 0, t17_DEFAULT_VALUE);
         SetStream(t18, pos, 0, t18_DEFAULT_VALUE);
         SetStream(t19, pos, 0, t19_DEFAULT_VALUE);
         SetStream(t20, pos, 0, t20_DEFAULT_VALUE);
      }
      if ((position[pos] == 0))
      {
         SetStream(stopLong, pos, hardStopLong, stopLong_DEFAULT_VALUE);
         SetStream(stopShort, pos, hardStopShort, stopShort_DEFAULT_VALUE);
         SetStream(t1, pos, 0, t1_DEFAULT_VALUE);
         SetStream(t2, pos, 0, t2_DEFAULT_VALUE);
         SetStream(t3, pos, 0, t3_DEFAULT_VALUE);
         SetStream(t4, pos, 0, t4_DEFAULT_VALUE);
         SetStream(t5, pos, 0, t5_DEFAULT_VALUE);
         SetStream(t6, pos, 0, t6_DEFAULT_VALUE);
         SetStream(t7, pos, 0, t7_DEFAULT_VALUE);
         SetStream(t8, pos, 0, t8_DEFAULT_VALUE);
         SetStream(t9, pos, 0, t9_DEFAULT_VALUE);
         SetStream(t10, pos, 0, t10_DEFAULT_VALUE);
         SetStream(t11, pos, 0, t11_DEFAULT_VALUE);
         SetStream(t12, pos, 0, t12_DEFAULT_VALUE);
         SetStream(t13, pos, 0, t13_DEFAULT_VALUE);
         SetStream(t14, pos, 0, t14_DEFAULT_VALUE);
         SetStream(t15, pos, 0, t15_DEFAULT_VALUE);
         SetStream(t16, pos, 0, t16_DEFAULT_VALUE);
         SetStream(t17, pos, 0, t17_DEFAULT_VALUE);
         SetStream(t18, pos, 0, t18_DEFAULT_VALUE);
         SetStream(t19, pos, 0, t19_DEFAULT_VALUE);
         SetStream(t20, pos, 0, t20_DEFAULT_VALUE);
      }
      plot15[pos] = stopLong[pos];
      plot16[pos] = stopShort[pos];
   }
   LabelsCollection::Redraw();
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