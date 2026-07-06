//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=152872#p152872

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_ARROW
#property indicator_color3 Green
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_type4 DRAW_ARROW
#property indicator_color4 Red
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

input int length = 20; // Period
input int bars_limit = 100000; // Bars limit
double max_level[], min_level[], bullish_breakout[], bearish_breakout[];

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



// Highest high stream v1.3

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _source.Release();
   }
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetValue(period, val))
         return false;

      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
      }
      return true;
   }
};




// Lowest low stream v1.3

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetValue(period, val))
         return false;

      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
      }
      return true;
   }
};

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

// Stream-value condition v1.0

class StreamValueCondition : public ACondition
{
   IStream* _stream1;
   int _periodShift1;
   string _name1;
   TwoStreamsConditionType _condition;
   double _value;
public:
   StreamValueCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      TwoStreamsConditionType condition,
      IStream* stream1,
      double value,
      string name1,
      int streamPeriodShift1 = 0)
      :ACondition(symbol, timeframe)
   {
      _name1 = name1;
      _stream1 = stream1;
      _stream1.AddRef();
      _condition = condition;
      _periodShift1 = streamPeriodShift1;
      _value = value;
   }

   ~StreamValueCondition()
   {
      _stream1.Release();
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      switch (_condition)
      {
         case FirstAboveSecond:
            return _name1 + " > " + DoubleToString(_value) + ": " + (result ? "true" : "false");
         case FirstBelowSecond:
            return _name1 + " < " + DoubleToString(_value) + ": " + (result ? "true" : "false");
         case FirstCrossOverSecond:
            return _name1 + " co " + DoubleToString(_value) + ": " + (result ? "true" : "false");
         case FirstCrossUnderSecond:
            return _name1 + " cu " + DoubleToString(_value) + ": " + (result ? "true" : "false");
         case FirstEqualsSecond:
            return _name1 + " = " + DoubleToString(_value) + ": " + (result ? "true" : "false");
      }
      return _name1 + "-" + DoubleToString(_value) + ": " + (result ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value10, value11;
      if (!_stream1.GetValue(period + _periodShift1, value10) || !_stream1.GetValue(period + _periodShift1 + 1, value11))
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return value10 > _value;
         case FirstBelowSecond:
            return value10 < _value;
         case FirstEqualsSecond:
            return value10 == _value;
         case FirstCrossOverSecond:
            return value10 >= _value && value11 < _value;
         case FirstCrossUnderSecond:
            return value10 <= _value && value11 > _value;
      }
      return value10 >= _value && value11 < _value;
   }
};


// Counts number of bars since last condition.
// In case of stream check it's value equal to 1
// v1.1

class BarsSinceStream : public AStream
{
   CustomStream* _stream;
   ICondition* _condition;
   int _bars[];
public:
   BarsSinceStream(string symbol, ENUM_TIMEFRAMES timeframe, ICondition* condition)
      :AStream(symbol, timeframe)
   {
      _stream = NULL;
      _condition = condition;
      _condition.AddRef();
   }

   BarsSinceStream(string symbol, ENUM_TIMEFRAMES timeframe, IStream* condition)
      :AStream(symbol, timeframe)
   {
      _stream = NULL;
      _condition = new StreamValueCondition(symbol, timeframe, FirstEqualsSecond, condition, 1, "Stream");
   }

   BarsSinceStream(string symbol, ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
      _stream = new CustomStream(symbol, timeframe);
      _condition = new StreamValueCondition(symbol, timeframe, FirstEqualsSecond, _stream, 1, "Stream");
   }

   ~BarsSinceStream()
   {
      if (_stream != NULL)
      {
         _stream.Release();
      }
      _condition.Release();
   }

   void SetCondition(int period, bool value)
   {
      if (_stream == NULL)
      {
         return;
      }
      _stream.SetValue(period, value ? 1 : 0);
   }

   virtual bool GetValue(const int period, double &val)
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
      return true;
   }
private:
   void FillHistory(int period)
   {
      int size = Size();
      for (int periodIndex = period; periodIndex < size; ++periodIndex)
      {
         int index = size - periodIndex - 1;
         if (!_condition.IsPass(periodIndex, 0))
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
SimplePriceStream* ta_highest1Source;
IStream* ta_highest1;
SimplePriceStream* ta_lowest2Source;
IStream* ta_lowest2;
BarsSinceStream* ta_barssince3;
BarsSinceStream* ta_barssince4;
BarsSinceStream* ta_barssince5;
BarsSinceStream* ta_barssince6;




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
SimplePriceStream* ta_crossover1X;
CustomStream* ta_crossover1Y;
IStream* ta_crossover1;
SimplePriceStream* ta_crossunder1X;
CustomStream* ta_crossunder1Y;
IStream* ta_crossunder1;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Dynamic Levels Breakouts");
   IndicatorShortName("Dynamic Levels Breakouts");
   IndicatorBuffers(8);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id, plot3);
   SetIndexArrow(id++, 233);
   SetIndexBuffer(id, plot4);
   SetIndexArrow(id++, 234);
   SetIndexBuffer(id++, max_level);
   SetIndexBuffer(id++, min_level);
   SetIndexBuffer(id++, bullish_breakout);
   SetIndexBuffer(id++, bearish_breakout);
   ta_crossover1X = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ta_crossover1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossover1 = new CrossoverStream(ta_crossover1X, ta_crossover1Y);
   ta_crossunder1X = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
   ta_crossunder1Y = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_crossunder1 = new CrossunderStream(ta_crossunder1X, ta_crossunder1Y);
   ta_highest1Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   ta_highest1 = new HighestHighStream(ta_highest1Source, length);
   ta_lowest2Source = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   ta_lowest2 = new LowestLowStream(ta_lowest2Source, length);
   ta_barssince3 = new BarsSinceStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_barssince4 = new BarsSinceStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_barssince5 = new BarsSinceStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ta_barssince6 = new BarsSinceStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   ta_highest1Source.Release();
   ta_highest1.Release();
   ta_lowest2Source.Release();
   ta_lowest2.Release();
   ta_barssince3.Release();
   ta_barssince4.Release();
   ta_barssince5.Release();
   ta_barssince6.Release();
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
      ArrayInitialize(max_level, EMPTY_VALUE);
      ArrayInitialize(min_level, EMPTY_VALUE);
      ArrayInitialize(bullish_breakout, EMPTY_VALUE);
      ArrayInitialize(bearish_breakout, EMPTY_VALUE);
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
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos > 0 && !IsStopped(); --pos)
   {
      double ta_highest1Value;
      if (!ta_highest1.GetValue(pos, ta_highest1Value))
      {
         continue;
      }
      max_level[pos] = ta_highest1Value;
      double ta_lowest2Value;
      if (!ta_lowest2.GetValue(pos, ta_lowest2Value))
      {
         continue;
      }
      min_level[pos] = ta_lowest2Value;
      bool max_color_cond = ((((max_level[pos + 1] == max_level[pos + 2])) && ((close[pos + 1] <= max_level[pos + 1]))) && ((close[pos + 1] >= min_level[pos + 1])));
      bool min_color_cond = ((((min_level[pos + 1] == min_level[pos + 2])) && ((close[pos + 1] <= max_level[pos + 1]))) && ((close[pos + 1] >= min_level[pos + 1])));
      color max_level_color = (max_color_cond ? Red : EMPTY_VALUE);
      color min_level_color = (min_color_cond ? Green : EMPTY_VALUE);
      ta_crossover1Y.SetValue(pos, max_level[pos + 1]);
      double ta_crossover1Value;
      if (!ta_crossover1.GetValue(pos, ta_crossover1Value))
      {
         continue;
      }
      bullish_breakout[pos] = ta_crossover1Value;
      ta_crossunder1Y.SetValue(pos, min_level[pos + 1]);
      double ta_crossunder1Value;
      if (!ta_crossunder1.GetValue(pos, ta_crossunder1Value))
      {
         continue;
      }
      bearish_breakout[pos] = ta_crossunder1Value;
      plot1[pos] = max_level[pos + 1];
      plot2[pos] = min_level[pos + 1];
      ta_barssince3.SetCondition(pos, bullish_breakout[pos + 1]);
      double ta_barssince3Value;
      if (!ta_barssince3.GetValue(pos, ta_barssince3Value))
      {
         continue;
      }
      ta_barssince4.SetCondition(pos, bearish_breakout[pos + 1]);
      double ta_barssince4Value;
      if (!ta_barssince4.GetValue(pos, ta_barssince4Value))
      {
         continue;
      }
      bool not_bullish = (ta_barssince3Value > ta_barssince4Value);
      ta_barssince5.SetCondition(pos, bullish_breakout[pos + 1]);
      double ta_barssince5Value;
      if (!ta_barssince5.GetValue(pos, ta_barssince5Value))
      {
         continue;
      }
      ta_barssince6.SetCondition(pos, bearish_breakout[pos + 1]);
      double ta_barssince6Value;
      if (!ta_barssince6.GetValue(pos, ta_barssince6Value))
      {
         continue;
      }
      bool not_bearish = (ta_barssince5Value < ta_barssince6Value);
      if ((bullish_breakout[pos] && not_bullish))
         plot3[pos] = low[pos];
      if ((bearish_breakout[pos] && not_bearish))
         plot4[pos] = high[pos];
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=152872#p152872

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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