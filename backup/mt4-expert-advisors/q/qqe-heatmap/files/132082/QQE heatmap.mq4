// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69544
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69544

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
#property indicator_buffers 12

input int    SF                     = 5;
input int    RSIPeriod              = 6;
input double WP                     = 4.236;
input color up_color = Green; // Up color
input color dn_color = Red; // Down color
color ne_color = Gray; // Neutral color

// Heatmap value calculator v1.0

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
      SetIndexLabel(id, name + ": -");
      ++id;

      SetIndexBuffer(id, up);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, upClor);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name + ": up");
      ++id;

      SetIndexBuffer(id, dn);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, downColor);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name + ": down");
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

class LongCondition : public ACondition
{
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = iBarShift(_symbol, _timeframe, Time[period]);
      if (index < 0)
      {
         return false;
      }
      double value4 = iCustom(_symbol, _timeframe, "qqe_new", SF, RSIPeriod, WP, 0, 0, "", false, false, false, false, false, false, false, false, "", false, 4, index);
      double value5 = iCustom(_symbol, _timeframe, "qqe_new", SF, RSIPeriod, WP, 0, 0, "", false, false, false, false, false, false, false, false, "", false, 5, index);
      return value5 < value4;
   }
};

class ShortCondition : public ACondition
{
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = iBarShift(_symbol, _timeframe, Time[period]);
      if (index < 0)
      {
         return false;
      }
      double value4 = iCustom(_symbol, _timeframe, "qqe_new", SF, RSIPeriod, WP, 0, 0, "", false, false, false, false, false, false, false, false, "", false, 4, index);
      double value5 = iCustom(_symbol, _timeframe, "qqe_new", SF, RSIPeriod, WP, 0, 0, "", false, false, false, false, false, false, false, false, "", false, 5, index);
      return value5 > value4;
   }
};

ENUM_TIMEFRAMES GetNextTimeframe(const ENUM_TIMEFRAMES timeframe)
{
   switch (timeframe)
   {
      case PERIOD_M1:
         return PERIOD_M5;
      case PERIOD_M5:
         return PERIOD_M15;
      case PERIOD_D1:
         return PERIOD_W1;
      case PERIOD_MN1:
      case PERIOD_W1:
         return PERIOD_MN1;
      case PERIOD_H1:
         return PERIOD_H4;
      case PERIOD_H4:
         return PERIOD_D1;
      case PERIOD_M15:
         return PERIOD_M30;
      case PERIOD_M30:
         return PERIOD_H1;
      case PERIOD_CURRENT:
         return GetNextTimeframe((ENUM_TIMEFRAMES)_Period);
   }
   return timeframe;
}

string GetTimeframeStr(ENUM_TIMEFRAMES _timeframe)
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

int init()
{
   double temp = iCustom(NULL, 0, "qqe_new", SF, RSIPeriod, WP, 0, 0, "", false, false, false, false, false, false, false, false, "", false, 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'qqe_new' indicator");
      return INIT_FAILED;
   }
   IndicatorBuffers(12);

   IndicatorName = GenerateIndicatorName("QQE Heatmap");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 4);

   int id = 0;

   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)_Period;
   LongCondition* longCondition1 = new LongCondition(_Symbol, tf);
   ShortCondition* shortCondition1 = new ShortCondition(_Symbol, tf);
   conditions[0] = new HeatMapValueCalculator(1, longCondition1, shortCondition1);
   id = conditions[0].RegisterStreams(id, up_color, dn_color, ne_color, GetTimeframeStr(tf));

   tf = GetNextTimeframe(tf);
   LongCondition* longCondition2 = new LongCondition(_Symbol, tf);
   ShortCondition* shortCondition2 = new ShortCondition(_Symbol, tf);
   conditions[1] = new HeatMapValueCalculator(2, longCondition2, shortCondition2);
   id = conditions[1].RegisterStreams(id, up_color, dn_color, ne_color, GetTimeframeStr(tf));
   
   tf = GetNextTimeframe(tf);
   LongCondition* longCondition3 = new LongCondition(_Symbol, tf);
   ShortCondition* shortCondition3 = new ShortCondition(_Symbol, tf);
   conditions[2] = new HeatMapValueCalculator(3, longCondition3, shortCondition3);
   id = conditions[2].RegisterStreams(id, up_color, dn_color, ne_color, GetTimeframeStr(tf));
   
   tf = GetNextTimeframe(tf);
   LongCondition* longCondition4 = new LongCondition(_Symbol, tf);
   ShortCondition* shortCondition4 = new ShortCondition(_Symbol, tf);
   conditions[3] = new HeatMapValueCalculator(4, longCondition4, shortCondition4);
   id = conditions[3].RegisterStreams(id, up_color, dn_color, ne_color, GetTimeframeStr(tf));

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
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;
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
