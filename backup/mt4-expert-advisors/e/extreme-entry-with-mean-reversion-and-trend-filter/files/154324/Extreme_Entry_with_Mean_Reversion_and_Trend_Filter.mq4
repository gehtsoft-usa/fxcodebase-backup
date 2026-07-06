//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74597

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_label1 "BUY"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "SELL"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Upper Band"
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Mean"
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Lower Band"
#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "EMA (Trend Filter)"
#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

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


// SMA on stream v1.0

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
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
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


// Difference between two streams v1.0

class TwoStreamDifferenceStream : public AStreamBase
{
   IStream* _first;
   IStream* _second;
public:
   TwoStreamDifferenceStream(IStream* first, IStream* second)
      :AStreamBase()
   {
      _first = first;
      _first.AddRef();
      _second = second;
      _second.AddRef();
   }
   ~TwoStreamDifferenceStream()
   {
      _first.Release();
      _second.Release();
   }

   virtual int Size()
   {
      return _first.Size();
   }

   bool GetValue(const int period, double &val)
   {
      double first;
      double second;
      if (!_first.GetValue(period, first) || !_second.GetValue(period, second))
      {
         return false;
      }
      val = first - second;
      return true;
   }
};


//AbsStream v1.0
class AbsStream : public AOnStream
{
public:
   AbsStream(IStream *source)
      :AOnStream(source)
   {
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
      {
         return false;
      }
      val = MathAbs(price);
      return true;
   }
};



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

// CCI on stream v1.0

class CCIOnStream : public AOnStream
{
   double _length;
   TwoStreamDifferenceStream* _diff;
   SumOnStream* _sum;
   double _mul;
public:
   CCIOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      SmaOnStream* mov = new SmaOnStream(source, length);
      _mul = 0.015 / length;
      _diff = new TwoStreamDifferenceStream(source, mov);
      mov.Release();
      AbsStream* diffAbs = new AbsStream(_diff);
      _sum = new SumOnStream(diffAbs, length);
      diffAbs.Release();
   }

   ~CCIOnStream()
   {
      _diff.Release();
      _sum.Release();
   }

   bool GetValue(const int period, double &val)
   {
      double sum = 0;
      double diff = 0;
      if (!_sum.GetValue(period, sum) || !_diff.GetValue(period, diff))
      {
         return false;
      }
      sum *= _mul;
      val = diff / sum;
      return true;
   }
};
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

   virtual bool GetValue(const int period, bool &val) = 0;
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
// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

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

// IBarStream v2.1



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

// Stream-stream condition v1.0

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

   static IBoolStream* CreateCrossover(IStream *left, IStream* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
};
#endif


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
// Pine-script like safe operations
// v.1.0

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}

double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
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

double SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left > right;
}

double SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left >= right;
}

double SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left < right;
}

double SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left <= right;
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


// Change stream v1.0

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
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


// EMA on stream v1.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(IStream *source, const int length)
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


// StDev stream v1.2

class StDevStream : public AOnStream
{
   int _period;
public:
   StDevStream(IStream* __source, int period)
      :AOnStream(__source)
   {
      _period = period;
   }
   
   bool GetValue(const int period, double &val)
   {
      double sum = 0;
      double ssum = 0;
      for (int i = 0; i < _period; i++)
      {
         double __data;
         if (!_source.GetValue(period + i, __data))
            return false;
         sum += __data;
         ssum += MathPow(__data, 2);
      }
      val = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
      return true;
   }
};

input string param1 = "CCI"; // Entry Signal Source
input int param2 = 10; // CCI/Momentum Length
input bool param3 = false; // Find Regular Bullish/Bearish Divergence
input int param4 = 65; // RSI Overbought Level
input int param5 = 35; // RSI Oversold Level
input int param6 = 14; // RSI Length
input bool param7 = true; // Plot Mean Reversion on the chart
input string param8 = "All Entries"; // Mean Reversion Signal Filter
input int param9 = 200; // MR Lookback Period (EMA)
input double param10 = 1.8; // MR Bands Multiplier
input bool param11 = false; // Enable Trend Filter
input int param12 = 200; // EMA Period (Trend Filter)
input int bars_limit = 100000; // Bars limit
string ccimomCross;
int ccimomLength;
bool useDivergence;
int rsiOverbought;
int rsiOversold;
int rsiLength;
bool plotMeanReversion;
string meanReversionFilter;
int emaPeriod;
double bandMultiplier;
bool enableTrendFilter;
int emaPeriodFilter;
FloatStream* cci1Source;
CCIOnStream* cci1;
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
FloatStream* rma1Source;
RmaOnStream* rma1;
FloatStream* change1Source;
ChangeStream* change1;
FloatStream* rma2Source;
RmaOnStream* rma2;
FloatStream* change2Source;
ChangeStream* change2;
double rsi[];
FloatStream* ema1Source;
EMAOnStream* ema1;
FloatStream* stdev1Source;
StDevStream* stdev1;
FloatStream* ema2Source;
EMAOnStream* ema2;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
//Signaler v2.1
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

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
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

Signaler* _signaler;

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
   IndicatorBuffers(7);
   int id = 0;
   ccimomCross = param1;
   ccimomLength = param2;
   useDivergence = param3;
   rsiOverbought = param4;
   rsiOversold = param5;
   rsiLength = param6;
   plotMeanReversion = param7;
   meanReversionFilter = param8;
   emaPeriod = param9;
   bandMultiplier = param10;
   enableTrendFilter = param11;
   emaPeriodFilter = param12;
   cci1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cci1 = new CCIOnStream(cci1Source, ccimomLength);
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
   change1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   rma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma1 = new RmaOnStream(rma1Source, rsiLength);
   change2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change2 = new ChangeStream(change2Source, 1);
   rma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rma2 = new RmaOnStream(rma2Source, rsiLength);
   ema1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, emaPeriod);
   stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev1 = new StDevStream(stdev1Source, emaPeriod);
   ema2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, emaPeriodFilter);
   SetIndexBuffer(id, plot1);
   SetIndexArrow(id, 217);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, Lime);
   SetIndexBuffer(id, plot2);
   SetIndexArrow(id, 218);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, Red);
   SetIndexBuffer(id, plot3);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Fuchsia);
   SetIndexBuffer(id, plot4);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Gray);
   SetIndexBuffer(id, plot5);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Blue);
   SetIndexBuffer(id, plot6);
   SetIndexStyle(id++, DRAW_LINE, STYLE_SOLID, 1, Orange);
   IndicatorObjPrefix = GenerateIndicatorPrefix("Extreme Entry with MR and TR");
   IndicatorShortName("Extreme Entry with Mean Reversion and Trend Filter");
   SetIndexBuffer(id++, rsi);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   cci1Source.Release();
   cci1.Release();
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
   rma1Source.Release();
   rma1.Release();
   change1Source.Release();
   change1.Release();
   rma2Source.Release();
   rma2.Release();
   change2Source.Release();
   change2.Release();
   ema1Source.Release();
   ema1.Release();
   stdev1Source.Release();
   stdev1.Release();
   ema2Source.Release();
   ema2.Release();
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
      cci1Source.Init();
      cross1X.Init();
      cross1Y.Init();
      cross2X.Init();
      cross2Y.Init();
      cross3X.Init();
      cross3Y.Init();
      cross4X.Init();
      cross4Y.Init();
      change1Source.Init();
      rma1Source.Init();
      change2Source.Init();
      rma2Source.Init();
      ArrayInitialize(rsi, EMPTY_VALUE);
      ema1Source.Init();
      stdev1Source.Init();
      ema2Source.Init();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
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
      int momLength = ((ccimomCross == "Momentum") ? ccimomLength : 10);
      if (pos + momLength > (rates_total - 1)) { continue; }
      double mom = close[pos] - close[pos + momLength];
      cci1Source.SetValue(pos, close[pos]);
      double cci1Value;
      if (!cci1.GetValue(pos, cci1Value)) { cci1Value = EMPTY_VALUE; }
      double cci = cci1Value;
      cross1X.SetValue(pos, mom);
      cross1Y.SetValue(pos, 0);
      bool cross1Value;
      if (!cross1.GetValue(pos, cross1Value)) { cross1Value = EMPTY_VALUE; }
      cross2X.SetValue(pos, cci);
      cross2Y.SetValue(pos, 0);
      bool cross2Value;
      if (!cross2.GetValue(pos, cross2Value)) { cross2Value = EMPTY_VALUE; }
      bool ccimomCrossUp = ((ccimomCross == "Momentum") ? cross1Value : cross2Value);
      cross3X.SetValue(pos, 0);
      cross3Y.SetValue(pos, mom);
      bool cross3Value;
      if (!cross3.GetValue(pos, cross3Value)) { cross3Value = EMPTY_VALUE; }
      cross4X.SetValue(pos, 0);
      cross4Y.SetValue(pos, cci);
      bool cross4Value;
      if (!cross4.GetValue(pos, cross4Value)) { cross4Value = EMPTY_VALUE; }
      bool ccimomCrossDown = ((ccimomCross == "Momentum") ? cross3Value : cross4Value);
      double src = close[pos];
      change1Source.SetValue(pos, src);
      double change1Value;
      if (!change1.GetValue(pos, change1Value)) { change1Value = EMPTY_VALUE; }
      rma1Source.SetValue(pos, SafeMathMax(change1Value, 0));
      double rma1Value;
      if (!rma1.GetValue(pos, rma1Value)) { rma1Value = EMPTY_VALUE; }
      double up = rma1Value;
      change2Source.SetValue(pos, src);
      double change2Value;
      if (!change2.GetValue(pos, change2Value)) { change2Value = EMPTY_VALUE; }
      rma2Source.SetValue(pos, (-SafeMathMin(change2Value, 0)));
      double rma2Value;
      if (!rma2.GetValue(pos, rma2Value)) { rma2Value = EMPTY_VALUE; }
      double down = rma2Value;
      rsi[pos] = ((down == 0) ? 100 : ((up == 0) ? 0 : SafeMinus(100, SafeDivide(100, (SafePlus(1, SafeDivide(up, down)))))));
      if (pos + 0 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      bool oversoldAgo = (((SafeLE(rsi[pos + 0], rsiOversold) || SafeLE(rsi[pos + 1], rsiOversold)) || SafeLE(rsi[pos + 2], rsiOversold)) || SafeLE(rsi[pos + 3], rsiOversold));
      if (pos + 0 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      if (pos + 3 > (rates_total - 1)) { continue; }
      bool overboughtAgo = (((SafeGE(rsi[pos + 0], rsiOverbought) || SafeGE(rsi[pos + 1], rsiOverbought)) || SafeGE(rsi[pos + 2], rsiOverbought)) || SafeGE(rsi[pos + 3], rsiOverbought));
      if (pos + 0 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      bool bullishDivergenceCondition = SafeGreater(rsi[pos + 0], rsi[pos + 1]) && SafeLess(rsi[pos + 1], rsi[pos + 2]);
      if (pos + 0 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 1 > (rates_total - 1)) { continue; }
      if (pos + 2 > (rates_total - 1)) { continue; }
      bool bearishDivergenceCondition = SafeLess(rsi[pos + 0], rsi[pos + 1]) && SafeGreater(rsi[pos + 1], rsi[pos + 2]);
      bool longEntryCondition = ccimomCrossUp && oversoldAgo && ((!useDivergence || bullishDivergenceCondition));
      bool shortEntryCondition = ccimomCrossDown && overboughtAgo && ((!useDivergence || bearishDivergenceCondition));
      ema1Source.SetValue(pos, close[pos]);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { ema1Value = EMPTY_VALUE; }
      double meanReversion = (plotMeanReversion ? ema1Value : EMPTY_VALUE);
      stdev1Source.SetValue(pos, close[pos]);
      double stdev1Value;
      if (!stdev1.GetValue(pos, stdev1Value)) { stdev1Value = EMPTY_VALUE; }
      double stdDev = (plotMeanReversion ? stdev1Value : EMPTY_VALUE);
      double upperBand = (plotMeanReversion ? SafePlus(meanReversion, SafeMultiply(stdDev, bandMultiplier)) : EMPTY_VALUE);
      double lowerBand = (plotMeanReversion ? SafeMinus(meanReversion, SafeMultiply(stdDev, bandMultiplier)) : EMPTY_VALUE);
      if (plotMeanReversion)
      {
         if ((meanReversionFilter == "Range Entries"))
         {
            longEntryCondition = ((longEntryCondition) == EMPTY_VALUE ? EMPTY_VALUE : longEntryCondition && (SafeGreater(close[pos], lowerBand) && SafeLess(close[pos], upperBand)));
            shortEntryCondition = ((shortEntryCondition) == EMPTY_VALUE ? EMPTY_VALUE : shortEntryCondition && (SafeGreater(close[pos], lowerBand) && SafeLess(close[pos], upperBand)));
         }
         else if ((meanReversionFilter == "Extreme Entries"))
         {
            longEntryCondition = ((longEntryCondition) == EMPTY_VALUE ? EMPTY_VALUE : longEntryCondition && ((SafeLess(close[pos], lowerBand) || SafeGreater(close[pos], upperBand))));
            shortEntryCondition = ((shortEntryCondition) == EMPTY_VALUE ? EMPTY_VALUE : shortEntryCondition && ((SafeLess(close[pos], lowerBand) || SafeGreater(close[pos], upperBand))));
         }
      }
      ema2Source.SetValue(pos, close[pos]);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { ema2Value = EMPTY_VALUE; }
      double emaPeriodFiltered = (enableTrendFilter ? ema2Value : EMPTY_VALUE);
      if (enableTrendFilter)
      {
         longEntryCondition = longEntryCondition && (SafeGreater(close[pos], emaPeriodFiltered));
         shortEntryCondition = shortEntryCondition && (SafeLess(close[pos], emaPeriodFiltered));
      }
      bool plotshape1_condition = longEntryCondition;
      if (plotshape1_condition) { plot1[pos] = low[pos]; }
      bool plotshape2_condition = shortEntryCondition;
      if (plotshape2_condition) { plot2[pos] = high[pos]; }
      color plot3_color = Fuchsia;
      if (plot3_color != EMPTY_VALUE) { plot3[pos] = (plotMeanReversion ? upperBand : EMPTY_VALUE); }
      else { plot3[pos] = EMPTY_VALUE; }
      color plot4_color = Gray;
      if (plot4_color != EMPTY_VALUE) { plot4[pos] = (plotMeanReversion ? meanReversion : EMPTY_VALUE); }
      else { plot4[pos] = EMPTY_VALUE; }
      color plot5_color = Blue;
      if (plot5_color != EMPTY_VALUE) { plot5[pos] = (plotMeanReversion ? lowerBand : EMPTY_VALUE); }
      else { plot5[pos] = EMPTY_VALUE; }
      color plot6_color = Orange;
      if (plot6_color != EMPTY_VALUE) { plot6[pos] = (enableTrendFilter ? emaPeriodFiltered : EMPTY_VALUE); }
      else { plot6[pos] = EMPTY_VALUE; }
      if (longEntryCondition) { _signaler.SendNotifications("BUY Signal", "Buy Entry Signal"); }
      if (shortEntryCondition) { _signaler.SendNotifications("SELL Signal", "Sell Entry Signal"); }
      if ((longEntryCondition || shortEntryCondition)) { _signaler.SendNotifications("BUY or SELL Signal", "Entry Signal"); }
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
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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