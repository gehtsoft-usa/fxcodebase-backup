// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=63204
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
#property version   "1.2"

#property indicator_separate_window
#property strict
#property indicator_buffers 21
#property indicator_maximum 6;
#property indicator_minimum 0;

input int Fast_MA_Length=5;
input int Slow_MA_Length=35;
input int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
input int Smoothing_Method=0;  // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA

input color up_up_color = 0x008800; // Up-Up color
input color up_dn_color = 0x00FF00; // Up-Down color
input color dn_up_color = 0x0000FF; // Down-Up color
input color dn_dn_color = 0x000088; // Up-Down color

input string symbol1 = ""; // Symbol 1
input ENUM_TIMEFRAMES tf1 = PERIOD_CURRENT; // Timeframe 1
input string symbol2 = ""; // Symbol 2
input ENUM_TIMEFRAMES tf2 = PERIOD_CURRENT; // Timeframe 2
input string symbol3 = ""; // Symbol 3
input ENUM_TIMEFRAMES tf3 = PERIOD_CURRENT; // Timeframe 3
input string symbol4 = ""; // Symbol 4
input ENUM_TIMEFRAMES tf4 = PERIOD_CURRENT; // Timeframe 4
input string symbol5 = ""; // Symbol 5
input ENUM_TIMEFRAMES tf5 = PERIOD_CURRENT; // Timeframe 5

// Heatmap value calculator v2.1

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
   string _name;
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
      _name = name;
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_ARROW, EMPTY, EMPTY, clr);
      SetIndexArrow(id, 110);
      SetIndexLabel(id, name);
      ++id;

      return id;
   }

   string GetName()
   {
      return _name;
   }

   void Set(int period, datetime date)
   {
      _stream[period] = _condition.IsPass(period, date) ? _value : EMPTY_VALUE;
   }
};

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
      case PERIOD_CURRENT: return TimeframeToString((ENUM_TIMEFRAMES)_Period);
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
   return "";
}

class MultiHeatMapValueCalculator : public IHeatMapValueCalculator
{
   double _value;
   StreamOnCondition* _streams[];
   string _name;
public:
   MultiHeatMapValueCalculator(const double value, string name)
   {
      _value = value;
      _name = name;
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
      ResetLastError();
      string id = IndicatorObjPrefix + DoubleToString(_value, 1);
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_TEXT, WindowFind("EWO Heat Map"), Time[0], _value))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return;
         }
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, Red);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, Time[0]);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, _value);
      ObjectSetString(0, id, OBJPROP_TEXT, _name);
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

class UpUpCondition : public ACondition
{
public:
   UpUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = iBarShift(_symbol, _timeframe, Time[period]);
      return iCustom(_symbol, _timeframe, "EWO", Fast_MA_Length, Slow_MA_Length, Price, Smoothing_Method, 1, index) != 0;
   }
};
class UpDownCondition : public ACondition
{
public:
   UpDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = iBarShift(_symbol, _timeframe, Time[period]);
      return iCustom(_symbol, _timeframe, "EWO", Fast_MA_Length, Slow_MA_Length, Price, Smoothing_Method, 0, index) != 0;
   }
};
class DownUpCondition : public ACondition
{
public:
   DownUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = iBarShift(_symbol, _timeframe, Time[period]);
      return iCustom(_symbol, _timeframe, "EWO", Fast_MA_Length, Slow_MA_Length, Price, Smoothing_Method, 3, index) != 0;
   }
};
class DownDownCondition : public ACondition
{
public:
   DownDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = iBarShift(_symbol, _timeframe, Time[period]);
      return iCustom(_symbol, _timeframe, "EWO", Fast_MA_Length, Slow_MA_Length, Price, Smoothing_Method, 2, index) != 0;
   }
};

int init()
{
   double temp = iCustom(NULL, 0, "EWO", Fast_MA_Length, Slow_MA_Length, Price, Smoothing_Method, 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'EWO' indicator");
      return INIT_FAILED;
   } 
   IndicatorObjPrefix = GenerateIndicatorPrefix("ewohm");
   IndicatorShortName("EWO Heat Map");

   int rows = 5;
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + rows);
   IndicatorBuffers(3 * rows);

   int id = 0;
   int index = rows - 1;

   id = Add(symbol1 != "" ? symbol1 : _Symbol, tf1, id, index);
   --index;
   id = Add(symbol2 != "" ? symbol2 : _Symbol, tf2, id, index);
   --index;
   id = Add(symbol3 != "" ? symbol3 : _Symbol, tf3, id, index);
   --index;
   id = Add(symbol4 != "" ? symbol4 : _Symbol, tf4, id, index);
   --index;
   id = Add(symbol5 != "" ? symbol5 : _Symbol, tf5, id, index);
   --index;

   return 0;
}

int Add(string symbol, ENUM_TIMEFRAMES tf, int id, int index)
{
   string name = symbol + "/" + TimeframeToString(tf);
   MultiHeatMapValueCalculator* calc = new MultiHeatMapValueCalculator(index + 1, name);
   conditions[index] = calc;
   ICondition* upUpCondition = new UpUpCondition(symbol, tf);
   ICondition* upDownCondition = new UpDownCondition(symbol, tf);
   ICondition* downUpCondition = new DownUpCondition(symbol, tf);
   ICondition* downDownCondition = new DownDownCondition(symbol, tf);
   id = calc.RegisterStreams(id, up_up_color, upUpCondition, name + " UP-UP");
   id = calc.RegisterStreams(id, up_dn_color, upDownCondition, name + " UP-DN");
   id = calc.RegisterStreams(id, dn_up_color, downUpCondition, name + " DN-UP");
   id = calc.RegisterStreams(id, dn_dn_color, downDownCondition, name + " DN-DN");
   upUpCondition.Release();
   upDownCondition.Release();
   downUpCondition.Release();
   downDownCondition.Release();
   return id;
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
         conditions[conditionIndex].UpdateValue(i);
      }
   }
   return 0;
}
