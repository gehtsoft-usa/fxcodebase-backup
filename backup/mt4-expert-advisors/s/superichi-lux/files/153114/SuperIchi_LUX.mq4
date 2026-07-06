//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74297

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_label1 "Tenkan-Sen"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0x2157f3
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Kijun-Sen"
#property indicator_type2 DRAW_LINE
#property indicator_color2 0xff5d00
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Crossover"
#property indicator_type3 DRAW_LINE
#property indicator_color3 0x2157f3
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Crossunder"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0xff5d00
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Senkou Span A"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Senkou Span B"
#property indicator_type6 DRAW_LINE
#property indicator_color6 Blue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Chikou"
#property indicator_type7 DRAW_LINE
#property indicator_color7 0x7b1fa2
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1

input int tenkan_len = 9; // Tenkan??????????
input double tenkan_mult = 2;
input int kijun_len = 26; // Kijun?????????????
input double kijun_mult = 4;
input int spanB_len = 52; // Senkou Span B?
input double spanB_mult = 6;
input int offset = 26; // Displacement
input int bars_limit = 100000; // Bars limit
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

// Average true range stream v2.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      IStream* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ~ATRStream()
   {
      _avg.Release();
   }

   bool GetValue(const int period, double &val)
   {
      return _avg.GetValue(period, val);
   }
};
#endif
// Stream base v1.0



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
// Custom stream v2.2

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      if (ArrayRange(_stream, 0) != size) 
      {
         ArrayResize(_stream, size);
      }
   }
};


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

//AOnStream v1.0

class ConditionStream : public AStreamBase
{
protected:
   ICondition* _condition;
public:
   ConditionStream(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~ConditionStream()
   {
      _condition.Release();
   }

   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   bool GetValue(const int period, double &val)
   {
      val = _condition.IsPass(period, 0) ? 1 : 0;
      return true;
   }
};
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


//CrossStream v1.0

class CrossStream : public ConditionStream
{
public:
   CrossStream(IStream *left, IStream* right)
      :ConditionStream(new OrCondition())
   {
      OrCondition* or = (OrCondition*)(_condition);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""), false);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, right, left, "", ""), false);
      or.Release();
   }
};
class avg__customStream
{
   int length;
   double mult;
   IStream* src;
   IStream* ta_atr1;
   CustomStream* upper;
   CustomStream* lower;
   CustomStream* os;
   CustomStream* max;
   CustomStream* min;
   CustomStream* ta_cross1X;
   CustomStream* ta_cross1Y;
   IStream* ta_cross1;
   CustomStream* ta_cross2X;
   CustomStream* ta_cross2Y;
   IStream* ta_cross2;
public:
   avg__customStream(int length, double mult, IStream* src)
   {
      ta_cross1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_cross1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_cross1 = new CrossStream(ta_cross1X, ta_cross1Y);
      ta_cross2X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_cross2Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ta_cross2 = new CrossStream(ta_cross2X, ta_cross2Y);
      this.length = length;
      this.mult = mult;
      this.src = src;
      src.AddRef();
      ta_atr1 = new ATRStream(_Symbol, (ENUM_TIMEFRAMES)_Period, length);
      upper = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      lower = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      os = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      max = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      min = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~avg__customStream()
   {
      src.Release();
      ta_atr1.Release();
      upper.Release();
      lower.Release();
      os.Release();
      max.Release();
      min.Release();
      ta_cross1X.Release();
      ta_cross1Y.Release();
      ta_cross1.Release();
      ta_cross2X.Release();
      ta_cross2Y.Release();
      ta_cross2.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double ta_atr1Value;
      if (!ta_atr1.GetValue(period, ta_atr1Value))
      {
         return false;
      }
      double atr = ta_atr1Value * mult;
      double up = (iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, period) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, period)) / 2 + atr;
      double dn = (iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, period) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, period)) / 2 - atr;
      upper.SetValue(period, 0.);

      lower.SetValue(period, 0.);
      double srcValue_1;
      if (!src.GetValue(period + 1, srcValue_1))
      {
         return false;
      }
      double upperValue_1;
      if (!upper.GetValue(period + 1, upperValue_1))
      {
         return false;
      }
      upper.SetValue(period, ((srcValue_1 < upperValue_1) ? MathMin(up, upperValue_1) : up));
      double lowerValue_1;
      if (!lower.GetValue(period + 1, lowerValue_1))
      {
         return false;
      }
      lower.SetValue(period, ((srcValue_1 > lowerValue_1) ? MathMax(dn, lowerValue_1) : dn));
      os.SetValue(period, 0);

      max.SetValue(period, 0.);

      min.SetValue(period, 0.);
      double srcValue;
      if (!src.GetValue(period, srcValue))
      {
         return false;
      }
      double upperValue;
      if (!upper.GetValue(period, upperValue))
      {
         return false;
      }
      double lowerValue;
      if (!lower.GetValue(period, lowerValue))
      {
         return false;
      }
      double osValue_1;
      if (!os.GetValue(period + 1, osValue_1))
      {
         return false;
      }
      os.SetValue(period, ((srcValue > upperValue) ? 1 : ((srcValue < lowerValue) ? 0 : osValue_1)));
      double osValue;
      if (!os.GetValue(period, osValue))
      {
         return false;
      }
      double spt = ((osValue == 1) ? lowerValue : upperValue);
      ta_cross1X.SetValue(period, srcValue);
      ta_cross1Y.SetValue(period, spt);
      double ta_cross1Value;
      if (!ta_cross1.GetValue(period, ta_cross1Value))
      {
         return false;
      }
      double maxValue_1;
      if (!max.GetValue(period + 1, maxValue_1))
      {
         return false;
      }
      max.SetValue(period, (ta_cross1Value ? MathMax(srcValue, maxValue_1) : ((osValue == 1) ? MathMax(srcValue, maxValue_1) : spt)));
      ta_cross2X.SetValue(period, srcValue);
      ta_cross2Y.SetValue(period, spt);
      double ta_cross2Value;
      if (!ta_cross2.GetValue(period, ta_cross2Value))
      {
         return false;
      }
      double minValue_1;
      if (!min.GetValue(period + 1, minValue_1))
      {
         return false;
      }
      min.SetValue(period, (ta_cross2Value ? MathMin(srcValue, minValue_1) : ((osValue == 0) ? MathMin(srcValue, minValue_1) : spt)));
      double maxValue;
      if (!max.GetValue(period, maxValue))
      {
         return false;
      }
      double minValue;
      if (!min.GetValue(period, minValue))
      {
         return false;
      }
      __out1 = (maxValue + minValue) / 2;
      return true;
   }
};

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

// Simple price stream v1.2

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




//AOnStream v1.0

class CrossoverStream : public ConditionStream
{
public:
   CrossoverStream(IStream *left, IStream* right)
      :ConditionStream(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""))
   {
      _condition.Release();
   }
};




//AOnStream v1.0

class CrossunderStream : public ConditionStream
{
public:
   CrossunderStream(IStream *left, IStream* right)
      :ConditionStream(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", ""))
   {
      _condition.Release();
   }
};
SimplePriceStream* avg__customFunc1param3;
avg__customStream* avg__customFunc1;
SimplePriceStream* avg__customFunc2param3;
avg__customStream* avg__customFunc2;
SimplePriceStream* avg__customFunc3param3;
avg__customStream* avg__customFunc3;
double plot1[];
double plot2[];
double plot3[];
CustomStream* ta_crossover1X;
CustomStream* ta_crossover1Y;
IStream* ta_crossover1;
double plot4[];
CustomStream* ta_crossunder1X;
CustomStream* ta_crossunder1Y;
IStream* ta_crossunder1;
double plot5[];
double plot6[];
double plot7[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("SuperIchi [LuxAlgo]");
   IndicatorShortName("SuperIchi [LUX]");
   IndicatorBuffers(7);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id, plot5);
   SetIndexShift(id++, offset - 1);
   SetIndexBuffer(id, plot6);
   SetIndexShift(id++, offset - 1);
   SetIndexBuffer(id, plot7);
   SetIndexShift(id++, (-offset) + 1);
   avg__customFunc1param3 = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   avg__customFunc1 = new avg__customStream(tenkan_len, tenkan_mult, avg__customFunc1param3);
   avg__customFunc2param3 = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   avg__customFunc2 = new avg__customStream(kijun_len, kijun_mult, avg__customFunc2param3);
   avg__customFunc3param3 = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   avg__customFunc3 = new avg__customStream(spanB_len, spanB_mult, avg__customFunc3param3);
   ta_crossover1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossover1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossover1 = new CrossoverStream(ta_crossover1X, ta_crossover1Y);
   ta_crossunder1X = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossunder1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossunder1 = new CrossunderStream(ta_crossunder1X, ta_crossunder1Y);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   avg__customFunc1param3.Release();
   delete avg__customFunc1;
   avg__customFunc2param3.Release();
   delete avg__customFunc2;
   avg__customFunc3param3.Release();
   delete avg__customFunc3;
   ta_crossover1X.Release();
   ta_crossover1Y.Release();
   ta_crossover1.Release();
   ta_crossunder1X.Release();
   ta_crossunder1Y.Release();
   ta_crossunder1.Release();
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
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
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
      double avg__customFunc1Value;
      if (!avg__customFunc1.GetValue(pos, avg__customFunc1Value))
      {
         continue;
      }
      double tenkan = avg__customFunc1Value;
      double avg__customFunc2Value;
      if (!avg__customFunc2.GetValue(pos, avg__customFunc2Value))
      {
         continue;
      }
      double kijun = avg__customFunc2Value;
      double senkouA = (kijun + tenkan) / 2;
      double avg__customFunc3Value;
      if (!avg__customFunc3.GetValue(pos, avg__customFunc3Value))
      {
         continue;
      }
      double senkouB = avg__customFunc3Value;
      color tenkan_css = 0x2157f3;
      color kijun_css = 0xff5d00;
      color cloud_a = Teal;
      color cloud_b = Red;
      color chikou_css = 0x7b1fa2;
      plot1[pos] = tenkan;
      plot2[pos] = kijun;
      ta_crossover1X.SetValue(pos, tenkan);
      ta_crossover1Y.SetValue(pos, kijun);
      double ta_crossover1Value;
      if (!ta_crossover1.GetValue(pos, ta_crossover1Value))
      {
         continue;
      }
      plot3[pos] = (ta_crossover1Value ? kijun : EMPTY_VALUE);
      ta_crossunder1X.SetValue(pos, tenkan);
      ta_crossunder1Y.SetValue(pos, kijun);
      double ta_crossunder1Value;
      if (!ta_crossunder1.GetValue(pos, ta_crossunder1Value))
      {
         continue;
      }
      plot4[pos] = (ta_crossunder1Value ? kijun : EMPTY_VALUE);
      double A = plot5[pos] = senkouA;
      double B = plot6[pos] = senkouB;
      plot7[pos] = close[pos];
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