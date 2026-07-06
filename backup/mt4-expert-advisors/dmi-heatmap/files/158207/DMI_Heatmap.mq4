//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75597

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
 
#property indicator_separate_window
#property strict
#property indicator_buffers 27

input int param1 = 14; // ADX Smoothing
input int param2 = 14; // DI Length
input bool Include_M1 = false; // Include M1
input bool Include_M5 = false; // Include M5
input bool Include_M15 = false; // Include M15
input bool Include_M30 = false; // Include M30
input bool Include_H1 = true; // Include H1
input bool Include_H4 = false; // Include H4
input bool Include_D1 = true; // Include D1
input bool Include_W1 = true; // Include W1
input bool Include_MN1 = false; // Include MN1
input color up_color = Green; // Up color
input color dn_color = Red; // Down color
input color ne_color = Gray; // Neutral color

// Heatmap value calculator v2.2

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

#ifndef IHeatMapValueCalculator_IMP
#define IHeatMapValueCalculator_IMP

class IHeatMapValueCalculator
{
public:
   virtual void UpdateValue(const int period) = 0;
};

class StreamOnCondition
{
   ICondition* _condition;
   double _stream[];
   double _value;
public:
   StreamOnCondition(ICondition* condition, double value)
   {
      _value = value;
      _condition = condition;
      _condition.AddRef();
   }

   ~StreamOnCondition()
   {
      _condition.Release();
   }

   int RegisterStreams(int id, string name, color clr)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, clr);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name);
      ++id;

      return id;
   }

   void Set(int period, datetime date)
   {
      _stream[period] = _condition.IsPass(period, date) ? _value : EMPTY_VALUE;
   }
};

class MultiHeatMapValueCalculator : public IHeatMapValueCalculator
{
   double _value;
   StreamOnCondition* _streams[];
public:
   MultiHeatMapValueCalculator(const double value)
   {
      _value = value;
   }

   ~MultiHeatMapValueCalculator()
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         delete _streams[i];
      }
      ArrayResize(_streams, 0);
   }

   int RegisterStreams(int id, color clr, ICondition* condition, string name)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new StreamOnCondition(condition, _value);
      return _streams[size].RegisterStreams(id, name, clr);
   }

   void UpdateValue(const int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         StreamOnCondition* item = _streams[i];
         item.Set(period, Time[period]);
      }
   }
};

class HeatMapValueCalculator : public IHeatMapValueCalculator
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
      _upCondition.AddRef();
      _downCondition = downCondition;
      _downCondition.AddRef();
      _value = value;
   }

   ~HeatMapValueCalculator()
   {
      _upCondition.Release();
      _downCondition.Release();
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

class SingleHeatMapValueCalculator : public IHeatMapValueCalculator
{
   double _value;
   ICondition* _condition;
   double pos[];
   double nt[];
public:
   SingleHeatMapValueCalculator(const double value, ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
      _value = value;
   }

   ~SingleHeatMapValueCalculator()
   {
      _condition.Release();
   }

   int RegisterStreams(int id, color positiveColor, color neutralColor, string name)
   {
      SetIndexBuffer(id, nt);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, neutralColor);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name + " N");
      ++id;

      SetIndexBuffer(id, pos);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, positiveColor);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name + " P");
      ++id;

      return id;
   }

   void UpdateValue(const int period)
   {
      pos[period] = EMPTY_VALUE;
      nt[period] = EMPTY_VALUE;
      if (_condition.IsPass(period, Time[period]))
         pos[period] = _value;
      else
         nt[period] = _value;
   }
};

#endif

IHeatMapValueCalculator* conditions[];

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

// ACondition v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ACondition_IMP
#define ACondition_IMP
// Abstract condition v1.1

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

class LongCondition : public ACondition
{
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      double dip = iCustom(_symbol, _timeframe, "DMI", param1, param2, 1, index);
      double dim = iCustom(_symbol, _timeframe, "DMI", param1, param2, 2, index);
      return dip > dim;
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
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      double dip = iCustom(_symbol, _timeframe, "DMI", param1, param2, 1, index);
      double dim = iCustom(_symbol, _timeframe, "DMI", param1, param2, 2, index);
      return dip < dim;
   }
};

int CreateHeatmap(int id, int index, string name, ICondition* longCondition, ICondition* shortCondition)
{
   HeatMapValueCalculator* calc = new HeatMapValueCalculator(index + 1, longCondition, shortCondition);
   longCondition.Release();
   shortCondition.Release();
   conditions[index] = calc;
   return calc.RegisterStreams(id, up_color, dn_color, ne_color, name);
}

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("DMIHM");
   IndicatorShortName("DMIHM.");

   int rows = 9;
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + rows);
   IndicatorBuffers(3 * rows);

   int id = 0;
   int index = rows - 1;
   if (Include_M1)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_M1), 
         new ShortCondition(_Symbol, PERIOD_M1));
   }
   if (Include_M5)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_M5), 
         new ShortCondition(_Symbol, PERIOD_M5));
   }
   if (Include_M15)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_M15), 
         new ShortCondition(_Symbol, PERIOD_M15));
   }
   if (Include_M30)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_M30), 
         new ShortCondition(_Symbol, PERIOD_M30));
   }
   if (Include_H1)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_H1), 
         new ShortCondition(_Symbol, PERIOD_H1));
   }
   if (Include_H4)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_H4), 
         new ShortCondition(_Symbol, PERIOD_H4));
   }
   if (Include_D1)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_D1), 
         new ShortCondition(_Symbol, PERIOD_D1));
   }
   if (Include_W1)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_W1), 
         new ShortCondition(_Symbol, PERIOD_W1));
   }
   if (Include_MN1)
   {
      id = CreateHeatmap(id, index--, "...", 
         new LongCondition(_Symbol, PERIOD_MN1), 
         new ShortCondition(_Symbol, PERIOD_MN1));
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
         if (conditions[conditionIndex] != NULL)
         {
            conditions[conditionIndex].UpdateValue(i);
         }
      }
   }
   return 0;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75597

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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