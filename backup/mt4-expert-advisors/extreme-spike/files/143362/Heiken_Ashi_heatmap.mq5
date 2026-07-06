// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=143304#p143304

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
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

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property version   "1.0"
#property indicator_separate_window
#property strict
#define rows 3
#define plots (rows * 3)
#property indicator_plots plots
#property indicator_buffers plots

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
// IBarStream v1.0

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

// Standard timeframe bar stream v1.0

class AStandardTimeframeBarStream : public IBarStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _references;
   AStandardTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }
public:
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

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = Size();
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

// HA bar steam v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef HABarStream_IMP
#define HABarStream_IMP

class HABarStream : public AStandardTimeframeBarStream
{
   double _open[];
   double _high[];
   double _low[];
   double _close[];
   int _lastCalculated;
public:
   HABarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStandardTimeframeBarStream(symbol, timeframe)
   {
      _lastCalculated = 0;
   }

   virtual bool GetSeriesValue(const int period, double &val)
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

// Base condition v1.1

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

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
   HABarStream* _ha;
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe, HABarStream* stream)
      :ACondition(symbol, timeframe)
   {
      _ha = stream;
      _ha.AddRef();
   }

   ~LongCondition()
   {
      _ha.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      double open, high, low, close;
      if (!_ha.GetValues(period, open, high, low, close))
      {
         return false;
      }
      return open < close;
   }
};

class ShortCondition : public ACondition
{
   HABarStream* _ha;
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe, HABarStream* stream)
      :ACondition(symbol, timeframe)
   {
      _ha = stream;
      _ha.AddRef();
   }

   ~ShortCondition()
   {
      _ha.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      double open, high, low, close;
      if (!_ha.GetValues(period, open, high, low, close))
      {
         return false;
      }
      return open > close;
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

HABarStream* ha[];

int Create(int id, ENUM_TIMEFRAMES tf, int index)
{
   int size = ArraySize(ha);
   ArrayResize(ha, size + 1);
   ha[size] = new HABarStream(_Symbol, tf);
   id = CreateHeatmap(id, index, "HA", 
      new LongCondition(_Symbol, tf, ha[size]), 
      new ShortCondition(_Symbol, tf, ha[size]));
   return id;
}

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("HABTF");
   IndicatorSetString(INDICATOR_SHORTNAME, "HABTF");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int size = ArraySize(conditions);
   ArrayResize(conditions, size + rows);

   int id = 0;
   int index = rows - 1;
   if (Include_M1)
   {
      id = Create(id, PERIOD_M1, index--);
   }
   if (Include_M5)
   {
      id = Create(id, PERIOD_M5, index--);
   }
   if (Include_M15)
   {
      id = Create(id, PERIOD_M15, index--);
   }
   if (Include_M30)
   {
      id = Create(id, PERIOD_M30, index--);
   }
   if (Include_H1)
   {
      id = Create(id, PERIOD_H1, index--);
   }
   if (Include_H4)
   {
      id = Create(id, PERIOD_H4, index--);
   }
   if (Include_D1)
   {
      id = Create(id, PERIOD_D1, index--);
   }
   if (Include_W1)
   {
      id = Create(id, PERIOD_W1, index--);
   }
   if (Include_MN1)
   {
      id = Create(id, PERIOD_MN1, index--);
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
   for (int i = 0; i < ArraySize(ha); ++i)
   {
      ha[i].Refresh();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      for (int conditionIndex = 0; conditionIndex < ArraySize(conditions); ++conditionIndex)
      {
         conditions[conditionIndex].UpdateValue(oldPos);
      }
   }
   return rates_total;
}