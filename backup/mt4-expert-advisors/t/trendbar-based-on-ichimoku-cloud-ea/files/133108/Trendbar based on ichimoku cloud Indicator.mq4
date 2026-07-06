// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69721

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

#property strict
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_minimum 0
#property indicator_maximum 1

input ENUM_TIMEFRAMES tf1 = PERIOD_CURRENT; // Timeframe 1
input ENUM_TIMEFRAMES tf2 = PERIOD_CURRENT; // Timeframe 2
input ENUM_TIMEFRAMES tf3 = PERIOD_CURRENT; // Timeframe 3
input int period1 = 14; // Period 1
input ENUM_MA_METHOD method1 = MODE_SMA; // Method 1
input int period2 = 21; // Period 2
input ENUM_MA_METHOD method2 = MODE_SMA; // Method 2

input int tenkan_sen = 9; // Tenkan sen
input int kijun_sen = 26; // Kijun sen
input int senkou_span_b = 52; // Senkou span b

enum SingalMode
{
   SingalModeLive, // Live
   SingalModeOnBarClose // On bar close
};

enum DisplayType
{
   Arrows, // Arrows
   ArrowsOnMainChart, // Arrows on main chart
   Candles // Candles color
};
input SingalMode signal_mode = SingalModeLive; // Signal mode
input DisplayType Type = Arrows; // Presentation Type
input double shift_arrows_pips = 0.1; // Shift arrows
input color up_color = Blue; // Up color
input color down_color = Red; // Down color
#property indicator_label1  "Bull"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Green
#property indicator_style1  STYLE_SOLID
#property indicator_label2  "Bear"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_label3  "Neutral"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  Gray
#property indicator_style3  STYLE_SOLID

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
// And condition v4.1

#ifndef AndCondition_IMP
#define AndCondition_IMP
class AndCondition : public AConditionBase
{
   ICondition *_conditions[];
public:
   ~AndCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         _conditions[i].Release();
      }
   }

   void Add(ICondition* condition, bool addRef)
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
         if (!_conditions[i].IsPass(period, date))
            return false;
      }
      return true;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      string messages = "";
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         string logMessage = _conditions[i].GetLogMessage(period, date);
         if (messages != "")
            messages = messages + " and (" + logMessage + ")";
         else
            messages = "(" + logMessage + ")";
      }
      return messages + (IsPass(period, date) ? "=true" : "=false");
   }
};
#endif
// MA Conditions v2.0

#ifndef MAConditions_IMP
#define MAConditions_IMP



class MACrossOverMACondition : public ACondition
{
   ENUM_MA_METHOD _method1;
   int _period1;
   ENUM_MA_METHOD _method2;
   int _period2;
public:
   MACrossOverMACondition(const string symbol, ENUM_TIMEFRAMES timeframe, ENUM_MA_METHOD method1, int period1
      , ENUM_MA_METHOD method2, int period2)
      :ACondition(symbol, timeframe)
   {
      _method1 = method1;
      _period1 = period1;
      _method2 = method2;
      _period2 = period2;
   }

   bool IsPass(const int period, const datetime date)
   {
      double ma1Value0 = iMA(_symbol, _timeframe, _period1, 0, _method1, PRICE_CLOSE, period);
      double ma1Value1 = iMA(_symbol, _timeframe, _period1, 0, _method1, PRICE_CLOSE, period + 1);
      double ma2Value0 = iMA(_symbol, _timeframe, _period2, 0, _method2, PRICE_CLOSE, period);
      double ma2Value1 = iMA(_symbol, _timeframe, _period2, 0, _method2, PRICE_CLOSE, period + 1);
      return ma1Value0 >= ma2Value0 && ma1Value1 < ma2Value1;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "MA cross over MA: " + (result ? "true" : "false");
   }
};

class MACrossUnderMACondition : public ACondition
{
   ENUM_MA_METHOD _method1;
   int _period1;
   ENUM_MA_METHOD _method2;
   int _period2;
public:
   MACrossUnderMACondition(const string symbol, ENUM_TIMEFRAMES timeframe, ENUM_MA_METHOD method1, int period1
      , ENUM_MA_METHOD method2, int period2)
      :ACondition(symbol, timeframe)
   {
      _method1 = method1;
      _period1 = period1;
      _method2 = method2;
      _period2 = period2;
   }

   bool IsPass(const int period, const datetime date)
   {
      double ma1Value0 = iMA(_symbol, _timeframe, _period1, 0, _method1, PRICE_CLOSE, period);
      double ma1Value1 = iMA(_symbol, _timeframe, _period1, 0, _method1, PRICE_CLOSE, period + 1);
      double ma2Value0 = iMA(_symbol, _timeframe, _period2, 0, _method2, PRICE_CLOSE, period);
      double ma2Value1 = iMA(_symbol, _timeframe, _period2, 0, _method2, PRICE_CLOSE, period + 1);
      return ma1Value0 <= ma2Value0 && ma1Value1 > ma2Value1;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "MA cross under MA: " + (result ? "true" : "false");
   }
};

class MAAbovePriceCondition : public ACondition
{
   ENUM_MA_METHOD _method;
   int _period;
   double _maxDistance;
public:
   MAAbovePriceCondition(const string symbol, ENUM_TIMEFRAMES timeframe, ENUM_MA_METHOD method, int period, double maxDistancePips = 0)
      :ACondition(symbol, timeframe)
   {
      _method = method;
      _period = period;
      _maxDistance = maxDistancePips * _instrument.GetPipSize(); 
   }

   bool IsPass(const int period, const datetime date)
   {
      double maValue = iMA(_symbol, _timeframe, _period, 0, _method, PRICE_CLOSE, period);
      double diff = maValue - iClose(_symbol, _timeframe, period);
      if (_maxDistance != 0.0 && diff > _maxDistance)
      {
         return false;
      }
      return diff > 0;
   }
};

class MABelowPriceCondition : public ACondition
{
   ENUM_MA_METHOD _method;
   int _period;
   double _maxDistance;
public:
   MABelowPriceCondition(const string symbol, ENUM_TIMEFRAMES timeframe, ENUM_MA_METHOD method, int period, double maxDistancePips = 0)
      :ACondition(symbol, timeframe)
   {
      _method = method;
      _period = period;
      _maxDistance = maxDistancePips * _instrument.GetPipSize(); 
   }

   bool IsPass(const int period, const datetime date)
   {
      double maValue = iMA(_symbol, _timeframe, _period, 0, _method, PRICE_CLOSE, period);
      double diff = iClose(_symbol, _timeframe, period) - maValue;
      if (_maxDistance != 0.0 && diff > _maxDistance)
      {
         return false;
      }
      return diff > 0;
   }
};

class MAAboveMACondition : public ACondition
{
   ENUM_MA_METHOD _method1;
   int _period1;
   ENUM_MA_METHOD _method2;
   int _period2;
   ENUM_TIMEFRAMES _timeframe2;
public:
   MAAboveMACondition(const string symbol, ENUM_TIMEFRAMES timeframe1, ENUM_MA_METHOD method1, int period1,
      ENUM_TIMEFRAMES timeframe2, ENUM_MA_METHOD method2, int period2)
      :ACondition(symbol, timeframe1)
   {
      _method1 = method1;
      _period1 = period1;
      _method2 = method2;
      _period2 = period2;
      _timeframe2 = timeframe2;
   }

   bool IsPass(const int period, const datetime date)
   {
      double ma1Value = iMA(_symbol, _timeframe, _period1, 0, _method1, PRICE_CLOSE, period);
      int secondPeriod = period;
      if (_timeframe2 != _timeframe)
      {
         secondPeriod = iBarShift(_symbol, _timeframe2, date);
         if (secondPeriod < 0)
         {
            return false;
         }
      }
      double ma2Value = iMA(_symbol, _timeframe2, _period2, 0, _method2, PRICE_CLOSE, secondPeriod);
      return ma1Value > ma2Value;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "MA above MA: " + (result ? "true" : "false");
   }
};

class MABelowMACondition : public ACondition
{
   ENUM_MA_METHOD _method1;
   int _period1;
   ENUM_MA_METHOD _method2;
   int _period2;
   ENUM_TIMEFRAMES _timeframe2;
public:
   MABelowMACondition(const string symbol, ENUM_TIMEFRAMES timeframe1, ENUM_MA_METHOD method1, int period1,
      ENUM_TIMEFRAMES timeframe2, ENUM_MA_METHOD method2, int period2)
      :ACondition(symbol, timeframe1)
   {
      _method1 = method1;
      _period1 = period1;
      _method2 = method2;
      _period2 = period2;
      _timeframe2 = timeframe2;
   }

   bool IsPass(const int period, const datetime date)
   {
      double ma1Value = iMA(_symbol, _timeframe, _period1, 0, _method1, PRICE_CLOSE, period);
      int secondPeriod = period;
      if (_timeframe2 != _timeframe)
      {
         secondPeriod = iBarShift(_symbol, _timeframe2, date);
         if (secondPeriod < 0)
         {
            return false;
         }
      }
      double ma2Value = iMA(_symbol, _timeframe2, _period2, 0, _method2, PRICE_CLOSE, secondPeriod);
      return ma1Value < ma2Value;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "MA below MA: " + (result ? "true" : "false");
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
      double close = iClose(_symbol, _timeframe, period);
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
      double close = iClose(_symbol, _timeframe, period);
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
      double close = iClose(_symbol, _timeframe, period);
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
      double close = iClose(_symbol, _timeframe, period);
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
// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};


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

class PriceStream : public AStream
{
   PriceType _price;
public:
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
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
#endif
//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start inputal program
input string   program_path             = ""; // Path to the inputal program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

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
         AdvancedAlert(advanced_key, message, symbol, timeframe);
   }
};

// Alert signal v3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

// Candles stream v.1.2
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
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
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};
// Action v2.0

#ifndef IAction_IMP
#define IAction_IMP

interface IAction
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool DoAction(const int period, const datetime date) = 0;
};

#endif

#ifndef AlertSignal_IMP
#define AlertSignal_IMP

class IAlertSignalOutput
{
public:
   virtual void Clear(int period) = 0;
   virtual void Set(int period) = 0;
};

class AlertSignalCandleColor : public IAlertSignalOutput
{
   CandleStreams* _candleStreams;
public:
   AlertSignalCandleColor()
   {
      _candleStreams = new CandleStreams();
   }

   ~AlertSignalCandleColor()
   {
      delete _candleStreams;
   }

   int Register(int id, color clr)
   {
      return _candleStreams.RegisterStreams(id, clr);
   }

   virtual void Clear(int period)
   {
      _candleStreams.Clear(period);
   }

   virtual void Set(int period)
   {
      _candleStreams.Set(period, Open[period], High[period], Low[period], Close[period]);
   }
};

class AlertSignalArrow : public IAlertSignalOutput
{
   double _signals[];
   IStream* _price;
public:
   AlertSignalArrow()
   {
      _price = NULL;
   }

   ~AlertSignalArrow()
   {
      if (_price != NULL)
         _price.Release();
   }

   int Register(int id, string name, int code, color clr, IStream* price)
   {
      if (_price != NULL)
         _price.Release();
      _price = price;
      _price.AddRef();

      SetIndexStyle(id, DRAW_ARROW, 0, 2, clr);
      SetIndexBuffer(id, _signals);
      SetIndexLabel(id, name);
      SetIndexArrow(id, code);
      return id + 1;
   }

   virtual void Clear(int period)
   {
      _signals[period] = EMPTY_VALUE;
   }

   virtual void Set(int period)
   {
      double price;
      if (!_price.GetValue(period, price))
         return;

      _signals[period] = price;
   }
};

class MainChartAlertSignalArrow : public IAlertSignalOutput
{
   IStream* _price;
   string _labelId;
   color _color;
   uchar _code;
public:
   MainChartAlertSignalArrow()
   {
      _price = NULL;
   }

   ~MainChartAlertSignalArrow()
   {
      if (_price != NULL)
         _price.Release();
   }

   int Register(int id, string labelId, uchar code, color clr, IStream* price)
   {
      if (_price != NULL)
         _price.Release();
      _price = price;
      _price.AddRef();
      _labelId = labelId;
      _color = clr;
      _code = code;
      
      return id;
   }

   virtual void Clear(int period)
   {
      ResetLastError();
      string id = _labelId + TimeToString(Time[period]);
      ObjectDelete(id);
   }

   virtual void Set(int period)
   {
      double price;
      if (!_price.GetValue(period, price))
         return;
      
      ResetLastError();
      string id = _labelId + TimeToString(Time[period]);
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[period], price))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetString(0, id, OBJPROP_FONT, "Wingdings");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, _color);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, Time[period]);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, CharToStr(_code));
   }
};

class AlertSignal
{
   IAction* _actionOnCondition;
   ICondition* _condition;
   Signaler* _signaler;
   string _message;
   datetime _lastSignal;
   bool _onBarClose;
   IAlertSignalOutput* _signalOutput;
public:
   AlertSignal(ICondition* condition, IAction* actionOnCondition, Signaler* signaler, bool onBarClose = false)
   {
      _actionOnCondition = actionOnCondition;
      if (_actionOnCondition != NULL)
      {
         _actionOnCondition.AddRef();
      }
      _signalOutput = NULL;
      _condition = condition;
      _signaler = signaler;
      _onBarClose = onBarClose;
   }

   ~AlertSignal()
   {
      if (_actionOnCondition != NULL)
      {
         _actionOnCondition.Release();
      }
      delete _signalOutput;
      delete _condition;
   }

   int RegisterArrows(int id, string name, string labelId, int code, color clr, IStream* price)
   {
      _message = name;
      MainChartAlertSignalArrow* signalOutput = new MainChartAlertSignalArrow();
      _signalOutput = signalOutput;
      return signalOutput.Register(id, labelId, (uchar)code, clr, price);
   }

   int RegisterStreams(int id, string name, int code, color clr, IStream* price)
   {
      _message = name;
      AlertSignalArrow* signalOutput = new AlertSignalArrow();
      _signalOutput = signalOutput;
      return signalOutput.Register(id, name, code, clr, price);
   }

   int RegisterStreams(int id, string name, color clr)
   {
      _message = name;
      AlertSignalCandleColor* signalOutput = new AlertSignalCandleColor();
      _signalOutput = signalOutput;
      return signalOutput.Register(id, clr);
   }

   void Update(int period)
   {
      string symbol = _signaler.GetSymbol();
      datetime dt = iTime(symbol, _signaler.GetTimeframe(), _onBarClose ? period + 1 : period);

      if (!_condition.IsPass(_onBarClose ? period + 1 : period, dt))
      {
         _signalOutput.Clear(period);
         return;
      }
      if (_actionOnCondition != NULL)
      {
         _actionOnCondition.DoAction(period, dt);
      }

      if (period == 0)
      {
         dt = iTime(symbol, _signaler.GetTimeframe(), 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
            _lastSignal = dt;
         }
      }

      _signalOutput.Set(period);
   }
};

#endif

// Custom stream v1.0

#ifndef CustomStream_IMP
#define CustomStream_IMP



class CustomStream : public AStream
{
public:
   double _stream[];

   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
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

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

#endif

AlertSignal* conditions[];
Signaler* mainSignaler;
CustomStream* customStream;

int CreateAlert(int id, ICondition* upCondition, IAction* upAction, ICondition* downCondition, IAction* downAction)
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 2);
   conditions[size] = new AlertSignal(upCondition, upAction, mainSignaler, signal_mode == SingalModeOnBarClose);
   conditions[size + 1] = new AlertSignal(downCondition, downAction, mainSignaler, signal_mode == SingalModeOnBarClose);
      
   switch (Type)
   {
      case Arrows:
         {
            id = conditions[size].RegisterStreams(id, "Up", 217, up_color, customStream);
            id = conditions[size + 1].RegisterStreams(id, "Down", 218, down_color, customStream);
         }
         break;
      case ArrowsOnMainChart:
         {
            PriceStream* highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
            highStream.SetShift(shift_arrows_pips);
            PriceStream* lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
            lowStream.SetShift(-shift_arrows_pips);
            id = conditions[size].RegisterArrows(id, "Up", IndicatorObjPrefix + "_up", 217, up_color, highStream);
            id = conditions[size + 1].RegisterArrows(id, "Down", IndicatorObjPrefix + "_down", 218, down_color, lowStream);
            lowStream.Release();
            highStream.Release();
         }
         break;
      case Candles:
         {
            id = conditions[size].RegisterStreams(id, "Up", up_color);
            id = conditions[size + 1].RegisterStreams(id, "Down", down_color);
         }
         break;
   }
   return id;
}

double bull[], bear[], neutral[];
AndCondition* bullCondition;
AndCondition* bearCondition;

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("TBOICI");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");

   bullCondition = new AndCondition();
   bullCondition.Add(new PriceBelowKumhoCondition(_Symbol, tf1, tenkan_sen, kijun_sen, senkou_span_b), false);
   bullCondition.Add(new PriceBelowKumhoCondition(_Symbol, tf2, tenkan_sen, kijun_sen, senkou_span_b), false);
   bullCondition.Add(new PriceBelowKumhoCondition(_Symbol, tf3, tenkan_sen, kijun_sen, senkou_span_b), false);
   bearCondition = new AndCondition();
   bearCondition.Add(new PriceAboveKumhoCondition(_Symbol, tf1, tenkan_sen, kijun_sen, senkou_span_b), false);
   bearCondition.Add(new PriceAboveKumhoCondition(_Symbol, tf2, tenkan_sen, kijun_sen, senkou_span_b), false);
   bearCondition.Add(new PriceAboveKumhoCondition(_Symbol, tf3, tenkan_sen, kijun_sen, senkou_span_b), false);

   SetIndexBuffer(0, bull);
   SetIndexBuffer(1, bear);
   SetIndexBuffer(2, neutral);

   int id = 3;
   if (Type == Arrows)
   {
      customStream = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   AndCondition* upCondition = new AndCondition();
   upCondition.Add(new MACrossOverMACondition(_Symbol, (ENUM_TIMEFRAMES)_Period, method1, period1, method2, period2), false);
   upCondition.Add(bullCondition, true);
   AndCondition* downCondition = new AndCondition();
   downCondition.Add(new MACrossUnderMACondition(_Symbol, (ENUM_TIMEFRAMES)_Period, method1, period1, method2, period2), false);
   downCondition.Add(bearCondition, true);
   id = CreateAlert(id, upCondition, NULL, downCondition, NULL);
   if (customStream != NULL)
   {
      id = customStream.RegisterInternalStream(id);
   }

   return 0;
}

int deinit()
{
   bullCondition.Release();
   bullCondition = NULL;
   bearCondition.Release();
   bearCondition = NULL;
   if (customStream != NULL)
   {
      customStream.Release();
      customStream = NULL;
   }
   delete mainSignaler;
   mainSignaler = NULL;
   for (int i = 0; i < ArraySize(conditions); ++i)
   {
      delete conditions[i];
   }
   ArrayResize(conditions, 0);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      bull[pos] = 0;
      bear[pos] = 0;
      neutral[pos] = 0;
      if (bullCondition.IsPass(pos, Time[pos]))
      {
         bull[pos] = 1;
      }
      else if (bearCondition.IsPass(pos, Time[pos]))
      {
         bear[pos] = 1;
      }
      else
      {
         neutral[pos] = 1;
      }
      if (customStream != NULL)
      {
         customStream._stream[pos] = 0.5;
      }
      for (int i = 0; i < ArraySize(conditions); ++i)
      {
         AlertSignal* item = conditions[i];
         item.Update(pos);
      }
   } 
   return 0;
}