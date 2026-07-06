// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69701

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property indicator_separate_window
#property strict
#property indicator_buffers 21

input int tenkan_sen = 9; // Tenkan sen
input int kijun_sen = 26; // Kijun sen
input int senkoi_span_b = 52; // Senkoi span b
input color up_color = Green; // Up color
input color dn_color = Red; // Down color
input color ne_color = Gray; // Neutral color

// Heatmap value calculator v2.1

// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

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

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

class HeatMapValueCalculator
{
   double _value;
   ICondition* _upCondition;
   ICondition* _downCondition;
   double up[];
   double dn[];
   double nt[];
public:
   HeatMapValueCalculator(const double value, ICondition* upCondition, ICondition* downCondition)
   {
      _upCondition = upCondition;
      _downCondition = downCondition;
      _value = value;
   }

   ~HeatMapValueCalculator()
   {
      delete _upCondition;
      delete _downCondition;
   }

   int RegisterStreams(int id, color upClor, color downColor, color neutralColor, string name)
   {
      SetIndexBuffer(id, nt);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, neutralColor);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name + " N");
      ++id;

      SetIndexBuffer(id, up);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, upClor);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name + " U");
      ++id;

      SetIndexBuffer(id, dn);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, downColor);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name + " D");
      ++id;

      return id;
   }

   void UpdateValue(const int period)
   {
      up[period] = EMPTY_VALUE;
      dn[period] = EMPTY_VALUE;
      nt[period] = EMPTY_VALUE;
      if (_upCondition.IsPass(period, Time[period]))
         up[period] = _value;
      else if (_downCondition.IsPass(period, Time[period]))
         dn[period] = _value;
      else
         nt[period] = _value;
   }
};

HeatMapValueCalculator* conditions[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

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
public:
   AConditionBase()
   {
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
      return "";
   }
};

#endif
// Instrument info v.1.6
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
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe)
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
// Ichimoku conditions v2.1
// More templates and snippets on https://github.com/sibvic/mq4-templates



#ifndef ICH_Conditions_IMP
#define ICH_Conditions_IMP

class PriceAboveKumhoCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _streamPeriodShift;
public:
   PriceAboveKumhoCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen,
      int kijunSen, 
      int senkoiSpanB,
      int streamPeriodShift = 0)

      :ACondition(symbol, timeframe)
   {
      _streamPeriodShift = streamPeriodShift;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Price > Kumho: " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double close = iClose(_symbol, _timeframe, period + _streamPeriodShift);
      double saValue = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, MODE_SENKOUSPANA, period + _streamPeriodShift);
      double sbValue = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, MODE_SENKOUSPANB, period + _streamPeriodShift);
      return close > saValue && close > sbValue;
   }
};

class PriceBelowKumhoCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _streamPeriodShift;
public:
   PriceBelowKumhoCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB,
      int streamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _streamPeriodShift = streamPeriodShift;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Price < Kumho: " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double close = iClose(_symbol, _timeframe, period + _streamPeriodShift);
      double saValue = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, MODE_SENKOUSPANA, period + _streamPeriodShift);
      double sbValue = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, MODE_SENKOUSPANB, period + _streamPeriodShift);
      return close < saValue && close < sbValue;
   }
};

string GetIchimokuStreamName(int streamIndex)
{
   switch (streamIndex)
   {
      case MODE_TENKANSEN:
         return "Tenkan-sen";
      case MODE_KIJUNSEN:
         return "Kijun-sen";
      case MODE_SENKOUSPANA:
         return "Senkou Span A";
      case MODE_SENKOUSPANB:
         return "Senkou Span B";
      case MODE_CHIKOUSPAN:
         return "Chikou Span";
   }
   return "";
}

class PriceAboveIchimokuStreamCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _streamIndex;
   int _streamPeriodShift;
public:
   PriceAboveIchimokuStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      int streamIndex, 
      int streamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _streamPeriodShift = streamPeriodShift;
      _streamIndex = streamIndex;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Price > " + GetIchimokuStreamName(_streamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double close = iClose(_symbol, _timeframe, period + _streamPeriodShift);
      double value = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _streamIndex, period + _streamPeriodShift);
      return close > value;
   }
};

class PriceBelowIchimokuStreamCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _streamIndex;
   int _streamPeriodShift;
public:
   PriceBelowIchimokuStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      int streamIndex, 
      int streamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _streamPeriodShift = streamPeriodShift;
      _streamIndex = streamIndex;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Price < " + GetIchimokuStreamName(_streamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double close = iClose(_symbol, _timeframe, period + _streamPeriodShift);
      double value = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _streamIndex, period + _streamPeriodShift);
      return close < value;
   }
};

class IchimokeStreamAboveIchimokuStreamCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _firstStreamIndex;
   int _firstStreamPeriodShift;
   int _secondStreamIndex;
   int _secondStreamPeriodShift;
public:
   IchimokeStreamAboveIchimokuStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      int firstStreamIndex, 
      int secondStreamIndex,
      int firstStreamPeriodShift = 0,
      int secondStreamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _firstStreamPeriodShift = firstStreamPeriodShift;
      _secondStreamPeriodShift = secondStreamPeriodShift;
      _firstStreamIndex = firstStreamIndex;
      _secondStreamIndex = secondStreamIndex;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return GetIchimokuStreamName(_firstStreamIndex) + " > " + GetIchimokuStreamName(_secondStreamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value1 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _firstStreamIndex, period + _firstStreamPeriodShift);
      double value2 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _secondStreamIndex, period + _secondStreamPeriodShift);
      return value1 > value2;
   }
};

class IchimokeStreamBelowIchimokuStreamCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _firstStreamIndex;
   int _firstStreamPeriodShift;
   int _secondStreamIndex;
   int _secondStreamPeriodShift;
public:
   IchimokeStreamBelowIchimokuStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      int firstStreamIndex, 
      int secondStreamIndex,
      int firstStreamPeriodShift = 0,
      int secondStreamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _firstStreamPeriodShift = firstStreamPeriodShift;
      _secondStreamPeriodShift = secondStreamPeriodShift;
      _firstStreamIndex = firstStreamIndex;
      _secondStreamIndex = secondStreamIndex;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return GetIchimokuStreamName(_firstStreamIndex) + " < " + GetIchimokuStreamName(_secondStreamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value1 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _firstStreamIndex, period + _firstStreamPeriodShift);
      double value2 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _secondStreamIndex, period + _secondStreamPeriodShift);
      return value1 < value2;
   }
};


class IchimokeStreamAboveOrEqualIchimokuStreamCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _firstStreamIndex;
   int _firstStreamPeriodShift;
   int _secondStreamIndex;
   int _secondStreamPeriodShift;
public:
   IchimokeStreamAboveOrEqualIchimokuStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      int firstStreamIndex, 
      int secondStreamIndex,
      int firstStreamPeriodShift = 0,
      int secondStreamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _firstStreamPeriodShift = firstStreamPeriodShift;
      _secondStreamPeriodShift = secondStreamPeriodShift;
      _firstStreamIndex = firstStreamIndex;
      _secondStreamIndex = secondStreamIndex;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return GetIchimokuStreamName(_firstStreamIndex) + " > " + GetIchimokuStreamName(_secondStreamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value1 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _firstStreamIndex, period + _firstStreamPeriodShift);
      double value2 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _secondStreamIndex, period + _secondStreamPeriodShift);
      return value1 >= value2;
   }
};

class IchimokeStreamBelowOrEqualIchimokuStreamCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _firstStreamIndex;
   int _firstStreamPeriodShift;
   int _secondStreamIndex;
   int _secondStreamPeriodShift;
public:
   IchimokeStreamBelowOrEqualIchimokuStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      int firstStreamIndex, 
      int secondStreamIndex,
      int firstStreamPeriodShift = 0,
      int secondStreamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _firstStreamPeriodShift = firstStreamPeriodShift;
      _secondStreamPeriodShift = secondStreamPeriodShift;
      _firstStreamIndex = firstStreamIndex;
      _secondStreamIndex = secondStreamIndex;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return GetIchimokuStreamName(_firstStreamIndex) + " < " + GetIchimokuStreamName(_secondStreamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value1 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _firstStreamIndex, period + _firstStreamPeriodShift);
      double value2 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _secondStreamIndex, period + _secondStreamPeriodShift);
      return value1 <= value2;
   }
};

#endif

class HABarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _open[];
   double _high[];
   double _low[];
   double _close[];
   int _lastCalculated;
   int _references;
public:
   HABarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _lastCalculated = 0;
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

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = iBarShift(_symbol, _timeframe, date);
      return true;
   }

   virtual bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      val = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      dt = iTime(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      high = _high[totalBars - 1 - period];
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      low = _low[totalBars - 1 - period];
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      high = _high[totalBars - 1 - period];
      low = _low[totalBars - 1 - period];
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      high = _high[totalBars - 1 - period];
      low = _low[totalBars - 1 - period];
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void Refresh()
   {
      int totalBars = Size();
      if (ArrayRange(_open, 0) != totalBars)
      {
         ArrayResize(_open, totalBars);
         ArrayResize(_high, totalBars);
         ArrayResize(_low, totalBars);
         ArrayResize(_close, totalBars);
      }
      for (int i = MathMax(0, _lastCalculated - 1); i < totalBars; ++i)
      {
         double open = iOpen(_symbol, _timeframe, totalBars - 1 - i);
         double high = iHigh(_symbol, _timeframe, totalBars - 1 - i);
         double low = iLow(_symbol, _timeframe, totalBars - 1 - i);
         double close = iClose(_symbol, _timeframe, totalBars - 1 - i);
         _open[i] = i == 0 ? (open + close) / 2 : (_open[i - 1] + _close[i - 1]) / 2;
         _close[i] = (open + high + low + close) / 4;
         _high[i] = fmax(high, fmax(_open[i], _close[i]));
         _low[i] = fmin(low,fmin(_open[i], _close[i]));
      }
      _lastCalculated = totalBars;
   }
};
class HALongCondition : public ACondition
{
   HABarStream* _ha;
public:
   HALongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _ha = new HABarStream(symbol, timeframe);
   }

   ~HALongCondition()
   {
      _ha.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      _ha.Refresh();
      double hahigh;
      if (!_ha.GetHigh(period, hahigh))
      {
         return false;
      }
      for (int i = 1; i <= 2; ++i)
      {
         double hahigh1;
         if (!_ha.GetHigh(period + i, hahigh1) || hahigh < hahigh1)
         {
            return false;
         }
      }
      return true;
   }
};

class HAShortCondition : public ACondition
{
   HABarStream* _ha;
public:
   HAShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _ha = new HABarStream(symbol, timeframe);
   }
   
   ~HAShortCondition()
   {
      _ha.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      _ha.Refresh();
      double halow;
      if (!_ha.GetLow(period, halow))
      {
         return false;
      }
      for (int i = 1; i <= 2; ++i)
      {
         double halow1;
         if (!_ha.GetLow(period + i, halow1) || halow > halow1)
         {
            return false;
         }
      }
      return true;
   }
};

class ExitLongCondition : public ACondition
{
public:
   ExitLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period, const datetime date)
   {
      double ichA = iIchimoku(_symbol, _timeframe, tenkan_sen, kijun_sen, senkoi_span_b, MODE_SENKOUSPANA, period);
      double ichB = iIchimoku(_symbol, _timeframe, tenkan_sen, kijun_sen, senkoi_span_b, MODE_SENKOUSPANB, period);
      double close = iClose(_symbol, _timeframe, period);
      return close < MathMin(ichA, ichB);
   }
};

class ExitShortCondition : public ACondition
{
public:
   ExitShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period, const datetime date)
   {
      double ichA = iIchimoku(_symbol, _timeframe, tenkan_sen, kijun_sen, senkoi_span_b, MODE_SENKOUSPANA, period);
      double ichB = iIchimoku(_symbol, _timeframe, tenkan_sen, kijun_sen, senkoi_span_b, MODE_SENKOUSPANB, period);
      double close = iClose(_symbol, _timeframe, period);
      return close > MathMax(ichA, ichB);
   }
};

int init()
{
   IndicatorName = GenerateIndicatorName("Heiken Ashi and Ichimoku Kinko Hyo Heatmap");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   int rows = 5;
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + rows);
   IndicatorBuffers(3 * rows);

   int id = 0;
   int index = 0;

   {
      ICondition* longCondition1 = new HALongCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ICondition* shortCondition1 = new HAShortCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
      conditions[index] = new HeatMapValueCalculator(index + 1, longCondition1, shortCondition1);
      id = conditions[index].RegisterStreams(id, up_color, dn_color, ne_color, "HA Condition");
      ++index;
   }
   {
      ICondition* longCondition1 = new PriceAboveKumhoCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, tenkan_sen, kijun_sen, senkoi_span_b, -kijun_sen);
      ICondition* shortCondition1 = new PriceBelowKumhoCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, tenkan_sen, kijun_sen, senkoi_span_b, -kijun_sen);
      conditions[index] = new HeatMapValueCalculator(index + 1, longCondition1, shortCondition1);
      id = conditions[index].RegisterStreams(id, up_color, dn_color, ne_color, "Price/Kumho");
      ++index;
   }
   {
      ICondition* longCondition1 = new PriceAboveIchimokuStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, tenkan_sen, kijun_sen, senkoi_span_b, MODE_CHIKOUSPAN, kijun_sen);
      ICondition* shortCondition1 = new PriceBelowIchimokuStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, tenkan_sen, kijun_sen, senkoi_span_b, MODE_CHIKOUSPAN, kijun_sen);
      conditions[index] = new HeatMapValueCalculator(index + 1, longCondition1, shortCondition1);
      id = conditions[index].RegisterStreams(id, up_color, dn_color, ne_color, "Price/Chikou");
      ++index;
   }
   {
      ICondition* longCondition1 = new PriceAboveIchimokuStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, tenkan_sen, kijun_sen, senkoi_span_b, MODE_KIJUNSEN);
      ICondition* shortCondition1 = new PriceBelowIchimokuStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, tenkan_sen, kijun_sen, senkoi_span_b, MODE_KIJUNSEN);
      conditions[index] = new HeatMapValueCalculator(index + 1, longCondition1, shortCondition1);
      id = conditions[index].RegisterStreams(id, up_color, dn_color, ne_color, "Price/Kijun");
      ++index;
   }
   {
      ICondition* longCondition1 = new IchimokeStreamAboveOrEqualIchimokuStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, tenkan_sen, kijun_sen, senkoi_span_b, 
         MODE_TENKANSEN, MODE_KIJUNSEN);
      ICondition* shortCondition1 = new IchimokeStreamBelowOrEqualIchimokuStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, tenkan_sen, kijun_sen, senkoi_span_b, 
         MODE_TENKANSEN, MODE_KIJUNSEN);
      conditions[index] = new HeatMapValueCalculator(index + 1, longCondition1, shortCondition1);
      id = conditions[index].RegisterStreams(id, up_color, dn_color, ne_color, "Tenkan/Kijun");
      ++index;
   }
   return 0;
}

int deinit()
{
   for (int i = 0; i < ArraySize(conditions); ++i)
   {
      delete conditions[i];
   }
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      for (int conditionIndex = 0; conditionIndex < ArraySize(conditions); ++conditionIndex)
      {
         HeatMapValueCalculator* condition = conditions[conditionIndex];
         condition.UpdateValue(i);
      }
   }
   return 0;
}
