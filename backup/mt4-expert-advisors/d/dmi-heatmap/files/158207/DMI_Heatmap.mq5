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
#define rows 9
#define plots (rows * 3)
#property indicator_plots plots
#property indicator_buffers plots

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
input int bars_limit = 1000; // Bars limit

// Heatmap value calculator v1.0

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
      SetIndexBuffer(id, _stream, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id, PLOT_LABEL, name);
      ++id;

      return id;
   }

   void Set(int period, datetime date)
   {
      int index = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1 - period;
      _stream[index] = _condition.IsPass(period, date) ? _value : EMPTY_VALUE;
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
         item.Set(period, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period));
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
      SetIndexBuffer(id, nt, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, neutralColor);
      PlotIndexSetString(id, PLOT_LABEL, name + " N");
      ++id;

      SetIndexBuffer(id, up, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, upClor);
      PlotIndexSetString(id, PLOT_LABEL, name + " U");
      ++id;

      SetIndexBuffer(id, dn, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, downColor);
      PlotIndexSetString(id, PLOT_LABEL, name + " D");
      ++id;

      return id;
   }

   void UpdateValue(const int period)
   {
      int index = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1 - period;
      up[index] = EMPTY_VALUE;
      dn[index] = EMPTY_VALUE;
      nt[index] = EMPTY_VALUE;
      if (_upCondition.IsPass(period, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period)))
         up[index] = _value;
      else if (_downCondition.IsPass(period, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period)))
         dn[index] = _value;
      else
         nt[index] = _value;
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
      SetIndexBuffer(id, pos, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, positiveColor);
      PlotIndexSetString(id, PLOT_LABEL, name + " P");
      ++id;

      SetIndexBuffer(id, nt, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, neutralColor);
      PlotIndexSetString(id, PLOT_LABEL, name + " N");
      ++id;

      return id;
   }

   void UpdateValue(const int period)
   {
      int index = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1 - period;
      pos[index] = EMPTY_VALUE;
      nt[index] = EMPTY_VALUE;
      if (_condition.IsPass(period, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period)))
         pos[index] = _value;
      else
         nt[index] = _value;
   }
};

#endif

IHeatMapValueCalculator* conditions[];

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

class LongCondition : public ACondition
{
   int indi;
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      indi = iCustom(_symbol, _timeframe, "DMI", param1, param2);
   }

   ~LongCondition()
   {
      IndicatorRelease(indi);
   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      double dip[1];
      if (CopyBuffer(indi, 1, index, 1, dip) != 1)
      {
         return false;
      }
      double dim[1];
      if (CopyBuffer(indi, 2, index, 1, dim) != 1)
      {
         return false;
      }
      return dip[0] > dim[0];
   }
};

class ShortCondition : public ACondition
{
   int indi;
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      indi = iCustom(_symbol, _timeframe, "DMI", param1, param2);
   }

   ~ShortCondition()
   {
      IndicatorRelease(indi);
   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      double dip[1];
      if (CopyBuffer(indi, 1, index, 1, dip) != 1)
      {
         return false;
      }
      double dim[1];
      if (CopyBuffer(indi, 2, index, 1, dim) != 1)
      {
         return false;
      }
      return dip[0] < dim[0];
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

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("DMIHM");
   IndicatorSetString(INDICATOR_SHORTNAME, "DMIHM");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int size = ArraySize(conditions);
   ArrayResize(conditions, size + rows);

   int id = 0;
   int index = rows - 1;
   if (Include_M1)
   {
      id = CreateHeatmap(id, index--, "M1", 
         new LongCondition(_Symbol, PERIOD_M1), 
         new ShortCondition(_Symbol, PERIOD_M1));
   }
   if (Include_M5)
   {
      id = CreateHeatmap(id, index--, "M5", 
         new LongCondition(_Symbol, PERIOD_M5), 
         new ShortCondition(_Symbol, PERIOD_M5));
   }
   if (Include_M15)
   {
      id = CreateHeatmap(id, index--, "M15", 
         new LongCondition(_Symbol, PERIOD_M15), 
         new ShortCondition(_Symbol, PERIOD_M15));
   }
   if (Include_M30)
   {
      id = CreateHeatmap(id, index--, "M30", 
         new LongCondition(_Symbol, PERIOD_M30), 
         new ShortCondition(_Symbol, PERIOD_M30));
   }
   if (Include_H1)
   {
      id = CreateHeatmap(id, index--, "H1", 
         new LongCondition(_Symbol, PERIOD_H1), 
         new ShortCondition(_Symbol, PERIOD_H1));
   }
   if (Include_H4)
   {
      id = CreateHeatmap(id, index--, "H4", 
         new LongCondition(_Symbol, PERIOD_H4), 
         new ShortCondition(_Symbol, PERIOD_H4));
   }
   if (Include_D1)
   {
      id = CreateHeatmap(id, index--, "D1", 
         new LongCondition(_Symbol, PERIOD_D1), 
         new ShortCondition(_Symbol, PERIOD_D1));
   }
   if (Include_W1)
   {
      id = CreateHeatmap(id, index--, "W1", 
         new LongCondition(_Symbol, PERIOD_W1), 
         new ShortCondition(_Symbol, PERIOD_W1));
   }
   if (Include_MN1)
   {
      id = CreateHeatmap(id, index--, "MN1", 
         new LongCondition(_Symbol, PERIOD_MN1), 
         new ShortCondition(_Symbol, PERIOD_MN1));
   }
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   for (int i = 0; i < ArraySize(conditions); ++i)
   {
      delete conditions[i];
   }
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
      //ArrayInitialize(out, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      for (int conditionIndex = 0; conditionIndex < ArraySize(conditions); ++conditionIndex)
      {
         if (conditions[conditionIndex] != NULL)
         {
            conditions[conditionIndex].UpdateValue(oldPos);
         }
      }
   }
   return rates_total;
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