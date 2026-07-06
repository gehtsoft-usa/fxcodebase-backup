// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71830

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+

#property strict
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_label1 "StoRSI"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Aqua
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "slow"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Regular Bullish"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Regular Bullish Label"
#property indicator_type4 DRAW_ARROW
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Hidden Bullish"
#property indicator_type5 DRAW_LINE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Hidden Bullish Label"
#property indicator_type6 DRAW_ARROW
#property indicator_color6 Blue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Regular Bearish"
#property indicator_type7 DRAW_LINE
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Regular Bearish Label"
#property indicator_type8 DRAW_ARROW
#property indicator_color8 Blue
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Hidden Bearish"
#property indicator_type9 DRAW_LINE
#property indicator_color9 Blue
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Hidden Bearish Label"
#property indicator_type10 DRAW_ARROW
#property indicator_color10 Blue
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_level1 50
#property indicator_level2 0
#property indicator_level3 30
#property indicator_level4 70
#property indicator_level5 100

input int len = 14; // StoRSI Period
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
input PriceType src = PriceClose; // StoRSI Source
input int smoothK = 3;
input int smoothD = 3;
input int lbR = 5; // Pivot Lookback Right
input int lbL = 5; // Pivot Lookback Left
input int rangeUpper = 60; // Max of Lookback Range
input int rangeLower = 5; // Min of Lookback Range
input bool plotBull = true; // Plot Bullish
input bool plotHiddenBull = true; // Plot Hidden Bullish
input bool plotBear = true; // Plot Bearish
input bool plotHiddenBear = true; // Plot Hidden Bearish
input int bars_limit = 100000; // Bars limit
double plot1[], plot2[], plot3[], plot4[], plot5[], plot6[], plot7[], plot8[], plot9[], plot10[];
double osc[], plFound[], phFound[];
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
class _inRangeStream
{
   IStream* cond;
   BarsSinceStream* barssince1;
public:
   _inRangeStream(IStream* cond)
   {
      this.cond = cond;
      cond.AddRef();
      barssince1 = new BarsSinceStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ~_inRangeStream()
   {
      cond.Release();
      barssince1.Release();
   }
   bool GetValue(const int period, double &__out1)
   {
      double condValue;
      if (!cond.GetValue(period, condValue))
      {
         return false;
      }
      barssince1.SetCondition(period, (condValue == true));
      double barssince1Value;
      if (!barssince1.GetValue(period, barssince1Value))
      {
         return false;
      }
      int bars = barssince1Value;
      __out1 = (((rangeLower <= bars) && (bars <= rangeUpper)) ? 1 : 0);
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

// Simple price stream v1.0



class SimplePriceStream : public AStream
{
   PriceType _price;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period);
               if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                  val = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period);
            break;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};


//AOnStream v1.0

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
      _source.AddRef();
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

// RSI stream v1.0

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSIStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSIStream(IStream* stream, int period)
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

#endif








// Price stream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

class PriceStream : public AStreamBase
{
   PriceType _price;
   IBarStream* _source;
public:
   PriceStream(IBarStream* source, const PriceType __price)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
      _price = __price;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            if (!_source.GetClose(period, val))
            {
               return false;
            }
            break;
         case PriceOpen:
            if (!_source.GetOpen(period, val))
            {
               return false;
            }
            break;
         case PriceHigh:
            if (!_source.GetHigh(period, val))
            {
               return false;
            }
            break;
         case PriceLow:
            if (!_source.GetLow(period, val))
            {
               return false;
            }
            break;
         case PriceMedian:
            {
               double high, low;
               if (!_source.GetHighLow(period, high, low))
               {
                  return false;
               }
               val = (high + low) / 2.0;
            }
            break;
         case PriceTypical:
            {
               double open1, high1, low1, close1;
               if (!_source.GetValues(period, open1, high1, low1, close1))
               {
                  return false;
               }
               val = (high1 + low1 + close1) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open2, high2, low2, close2;
               if (!_source.GetValues(period, open2, high2, low2, close2))
               {
                  return false;
               }
               val = (high2 + low2 + close2 * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         // case PriceVolume:
         //    if (!_source.GetVolume(period, val))
         //    {
         //       return false;
         //    }
         //    break;
      }
      return true;
   }
};


#endif


// Highest high stream v1.2

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




// Lowest low stream v1.2

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

// Stochastics on stream v1.0

class StochOnStream : public AStreamBase
{
   IStream* _closeStream;
   HighestHighStream* _highest;
   LowestLowStream* _lowest;
   int _period;
public:
   StochOnStream(IStream* closeStream, IStream* highStream, IStream* lowStream, int period)
      :AStreamBase()
   {
      _period = period;
      _closeStream = closeStream;
      _closeStream.AddRef();
      _highest = new HighestHighStream(highStream, period);
      _lowest = new LowestLowStream(lowStream, period);
   }

   ~StochOnStream()
   {
      _closeStream.Release();
      _highest.Release();
      _lowest.Release();
   }
   
   virtual int Size()
   {
      return _closeStream.Size();
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double close;
      if (!_closeStream.GetValue(period, close))
      {
         return false;
      }
      double lowest;
      if (!_lowest.GetValue(period, lowest))
      {
         return false;
      }
      double highest;
      if (!_highest.GetValue(period, highest))
      {
         return false;
      }
      double diff = (highest - lowest);
      val = diff == 0 ? 0 : 100 * (close - lowest) / diff;
      return true;
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
// Pivot low stream v1.1



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

   bool GetValue(const int period, double &val)
   {
      double center;
      if (!_source.GetValue(period + _rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < _rightBars; ++i)
      {
         if (!_source.GetValue(period + i, value) || center > value)
         {
            return false;
         }
      }
      for (int ii = 0; ii < _leftBars; ++ii)
      {
         if (!_source.GetValue(period + ii + _rightBars, value) || center > value)
         {
            return false;
         }
      }
      val = center;
      return true;
   }
};
// Pivot high stream v1.1



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

   bool GetValue(const int period, double &val)
   {
      double center;
      if (!_source.GetValue(period + _rightBars, center))
      {
         return false;
      }
      double value;
      for (int i = 0; i < _rightBars; ++i)
      {
         if (!_source.GetValue(period + i, value) || center < value)
         {
            return false;
         }
      }
      for (int ii = 0; ii < _leftBars; ++ii)
      {
         if (!_source.GetValue(period + ii + _rightBars, value) || center < value)
         {
            return false;
         }
      }
      val = center;
      return true;
   }
};
// Value when stream (condition as a parameter) v1.0




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

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_NONE);
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
         if (size > _shift)
         {
            _stream[period] = _values[size - 1 - _shift];
         }
      }
      else if (iBars(_symbol, _timeframe) - 1 > period)
      {
         _stream[period] = _stream[period + 1];
      }
      return _stream[period];
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};
SimplePriceStream* srcInputStream;
IStream* rsi1;
CustomStream* stoch2Source;
CustomStream* stoch2High;
CustomStream* stoch2Low;
IStream* stoch2;
IStream* sma3;
CustomStream* sma4Source;
IStream* sma4;
CustomStream* pivotlow5Source;
IStream* pivotlow5;
CustomStream* pivothigh6Source;
IStream* pivothigh6;
ValueWhenSimpleStream* valuewhen7;
ValueWhenSimpleStream* valuewhen8;
ValueWhenSimpleStream* valuewhen9;
ValueWhenSimpleStream* valuewhen10;
ValueWhenSimpleStream* valuewhen11;
ValueWhenSimpleStream* valuewhen12;
ValueWhenSimpleStream* valuewhen13;
ValueWhenSimpleStream* valuewhen14;
CustomStream* _inRangeFunc1param1;
_inRangeStream* _inRangeFunc1;
CustomStream* _inRangeFunc2param1;
_inRangeStream* _inRangeFunc2;
CustomStream* _inRangeFunc3param1;
_inRangeStream* _inRangeFunc3;
CustomStream* _inRangeFunc4param1;
_inRangeStream* _inRangeFunc4;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("DiverStoRSI");
   IndicatorShortName("Divergence Stoch RSI[mado]");
   IndicatorBuffers(21);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id, plot4);
   SetIndexArrow(id++, 233);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id, plot6);
   SetIndexArrow(id++, 233);
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id, plot8);
   SetIndexArrow(id++, 234);
   SetIndexBuffer(id++, plot9);
   SetIndexBuffer(id, plot10);
   SetIndexArrow(id++, 234);
   SetIndexBuffer(id++, osc);
   SetIndexBuffer(id++, plFound);
   SetIndexBuffer(id++, phFound);
   srcInputStream = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, src);
   rsi1 = new RSIStream(srcInputStream, len);
   stoch2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch2High = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch2Low = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stoch2 = new StochOnStream(stoch2Source, stoch2High, stoch2Low, len);
   sma3 = new SmaOnStream(stoch2, smoothK);
   sma4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma4 = new SmaOnStream(sma4Source, smoothD);
   pivotlow5Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pivotlow5 = new PivotLowStream(pivotlow5Source, lbL, lbR);
   pivothigh6Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   pivothigh6 = new PivotHighStream(pivothigh6Source, lbL, lbR);
   valuewhen7 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen7.RegisterInternalStream(id);
   valuewhen8 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen8.RegisterInternalStream(id);
   valuewhen9 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen9.RegisterInternalStream(id);
   valuewhen10 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen10.RegisterInternalStream(id);
   valuewhen11 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen11.RegisterInternalStream(id);
   valuewhen12 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen12.RegisterInternalStream(id);
   valuewhen13 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen13.RegisterInternalStream(id);
   valuewhen14 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen14.RegisterInternalStream(id);
   _inRangeFunc1param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRangeFunc1 = new _inRangeStream(_inRangeFunc1param1);
   _inRangeFunc2param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRangeFunc2 = new _inRangeStream(_inRangeFunc2param1);
   _inRangeFunc3param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRangeFunc3 = new _inRangeStream(_inRangeFunc3param1);
   _inRangeFunc4param1 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRangeFunc4 = new _inRangeStream(_inRangeFunc4param1);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   srcInputStream.Release();
   rsi1.Release();
   stoch2Source.Release();
   stoch2High.Release();
   stoch2Low.Release();
   stoch2.Release();
   sma3.Release();
   sma4Source.Release();
   sma4.Release();
   pivotlow5Source.Release();
   pivotlow5.Release();
   pivothigh6Source.Release();
   pivothigh6.Release();
   valuewhen7.Release();
   valuewhen8.Release();
   valuewhen9.Release();
   valuewhen10.Release();
   valuewhen11.Release();
   valuewhen12.Release();
   valuewhen13.Release();
   valuewhen14.Release();
   _inRangeFunc1param1.Release();
   delete _inRangeFunc1;
   _inRangeFunc2param1.Release();
   delete _inRangeFunc2;
   _inRangeFunc3param1.Release();
   delete _inRangeFunc3;
   _inRangeFunc4param1.Release();
   delete _inRangeFunc4;
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
      ArrayInitialize(plot8, EMPTY_VALUE);
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(osc, EMPTY_VALUE);
      ArrayInitialize(plFound, EMPTY_VALUE);
      ArrayInitialize(phFound, EMPTY_VALUE);
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
      color bearColor = Red;
      color bullColor = Navy;
      color hiddenBullColor = Yellow;
      color hiddenBearColor = Yellow;
      color textColor = White;
      color noneColor = White;
      double rsi1Value;
      if (!rsi1.GetValue(pos, rsi1Value))
      {
         continue;
      }
      double rsi1 = rsi1Value;
      stoch2Source.SetValue(pos, rsi1);
      stoch2High.SetValue(pos, rsi1);
      stoch2Low.SetValue(pos, rsi1);
      double sma3Value;
      if (!sma3.GetValue(pos, sma3Value))
      {
         continue;
      }
      double k = sma3Value;
      sma4Source.SetValue(pos, k);
      double sma4Value;
      if (!sma4.GetValue(pos, sma4Value))
      {
         continue;
      }
      double d = sma4Value;
      osc[pos] = k;
      plot1[pos] = osc[pos];
      plot2[pos] = d;
      pivotlow5Source.SetValue(pos, osc[pos]);
      double pivotlow5Value;
      if (!pivotlow5.GetValue(pos, pivotlow5Value))
      {
         continue;
      }
      plFound[pos] = ((pivotlow5Value) == EMPTY_VALUE ? false : true);
      pivothigh6Source.SetValue(pos, osc[pos]);
      double pivothigh6Value;
      if (!pivothigh6.GetValue(pos, pivothigh6Value))
      {
         continue;
      }
      phFound[pos] = ((pivothigh6Value) == EMPTY_VALUE ? false : true);
      double valuewhen7Value = valuewhen7.Update(pos, time[pos], plFound[pos], osc[pos + lbR]);
      _inRangeFunc1param1.SetValue(pos, plFound[pos + 1]);
      double _inRangeFunc1Value;
      if (!_inRangeFunc1.GetValue(pos, _inRangeFunc1Value))
      {
         continue;
      }
      bool oscHL = ((osc[pos + lbR] > valuewhen7Value) && _inRangeFunc1Value);
      double valuewhen8Value = valuewhen8.Update(pos, time[pos], plFound[pos], low[pos + lbR]);
      bool priceLL = (low[pos + lbR] < valuewhen8Value);
      bool bullCond = (((plotBull && priceLL) && oscHL) && plFound[pos]);
      plot3[pos + lbR] = (plFound[pos] ? osc[pos + lbR] : EMPTY_VALUE);
      plot1[pos + lbR] = (bullCond ? osc[pos + lbR] : EMPTY_VALUE);
      double valuewhen9Value = valuewhen9.Update(pos, time[pos], plFound[pos], osc[pos + lbR]);
      _inRangeFunc2param1.SetValue(pos, plFound[pos + 1]);
      double _inRangeFunc2Value;
      if (!_inRangeFunc2.GetValue(pos, _inRangeFunc2Value))
      {
         continue;
      }
      bool oscLL = ((osc[pos + lbR] < valuewhen9Value) && _inRangeFunc2Value);
      double valuewhen10Value = valuewhen10.Update(pos, time[pos], plFound[pos], low[pos + lbR]);
      bool priceHL = (low[pos + lbR] > valuewhen10Value);
      bool hiddenBullCond = (((plotHiddenBull && priceHL) && oscLL) && plFound[pos]);
      plot4[pos + lbR] = (plFound[pos] ? osc[pos + lbR] : EMPTY_VALUE);
      plot2[pos + lbR] = (hiddenBullCond ? osc[pos + lbR] : EMPTY_VALUE);
      double valuewhen11Value = valuewhen11.Update(pos, time[pos], phFound[pos], osc[pos + lbR]);
      _inRangeFunc3param1.SetValue(pos, phFound[pos + 1]);
      double _inRangeFunc3Value;
      if (!_inRangeFunc3.GetValue(pos, _inRangeFunc3Value))
      {
         continue;
      }
      bool oscLH = ((osc[pos + lbR] < valuewhen11Value) && _inRangeFunc3Value);
      double valuewhen12Value = valuewhen12.Update(pos, time[pos], phFound[pos], high[pos + lbR]);
      bool priceHH = (high[pos + lbR] > valuewhen12Value);
      bool bearCond = (((plotBear && priceHH) && oscLH) && phFound[pos]);
      plot5[pos + lbR] = (phFound[pos] ? osc[pos + lbR] : EMPTY_VALUE);
      plot3[pos + lbR] = (bearCond ? osc[pos + lbR] : EMPTY_VALUE);
      double valuewhen13Value = valuewhen13.Update(pos, time[pos], phFound[pos], osc[pos + lbR]);
      _inRangeFunc4param1.SetValue(pos, phFound[pos + 1]);
      double _inRangeFunc4Value;
      if (!_inRangeFunc4.GetValue(pos, _inRangeFunc4Value))
      {
         continue;
      }
      bool oscHH = ((osc[pos + lbR] > valuewhen13Value) && _inRangeFunc4Value);
      double valuewhen14Value = valuewhen14.Update(pos, time[pos], phFound[pos], high[pos + lbR]);
      bool priceLH = (high[pos + lbR] < valuewhen14Value);
      bool hiddenBearCond = (((plotHiddenBear && priceLH) && oscHH) && phFound[pos]);
      plot6[pos + lbR] = (phFound[pos] ? osc[pos + lbR] : EMPTY_VALUE);
      plot4[pos + lbR] = (hiddenBearCond ? osc[pos + lbR] : EMPTY_VALUE);
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
