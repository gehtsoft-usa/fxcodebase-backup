// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70150

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
#property indicator_chart_window
#property indicator_plots 4
#property indicator_buffers 4
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  DarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  DarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

input int bb_period = 20; // BB length
input double bb_deviation = 2; // BB deviation
input int bb_shift = 0; // BB shift
input ENUM_APPLIED_PRICE bb_price = PRICE_CLOSE; // BB Price type
input double body_size = 80; // Body size, %

input color up_color = Green; // Up color
input color down_color = Red; // Down color

//Signaler v 4.0

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#endif

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
   bool _popupAlert;
   bool _emailAlert;
   bool _playSound;
   string _soundFile;
   bool _notificationAlert;
   bool _advancedAlert;
   string _advancedKey;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _popupAlert = false;
      _emailAlert = false;
      _playSound = false;
      _notificationAlert = false;
      _advancedAlert = false;
   }

   void SetPopupAlert(bool isEnabled) { _popupAlert = isEnabled; }
   void SetEmailAlert(bool isEnabled) { _emailAlert = isEnabled; }
   void SetPlaySound(bool isEnabled, string fileName) 
   { 
      _playSound = isEnabled;
      _soundFile = fileName;
   }
   void SetNotificationAlert(bool isEnabled) { _notificationAlert = isEnabled; }
   void SetAdvancedAlert(bool isEnabled, string key)
   {
      _advancedAlert = isEnabled;
      _advancedKey = key;
   }

   void SendNotifications(string message, string subject = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (subject == NULL)
         subject = message;

      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (_popupAlert)
         Alert(message);
      if (_emailAlert)
         SendMail(subject, message);
      if (_playSound)
         PlaySound(_soundFile);
      if (_notificationAlert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (_advancedAlert && _advancedKey != "")
         AdvancedAlert(_advancedKey, message, symbol, timeframe);
#endif
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
         case PERIOD_M2: return "M2";
         case PERIOD_M3: return "M3";
         case PERIOD_M4: return "M4";
         case PERIOD_M5: return "M5";
         case PERIOD_M6: return "M6";
         case PERIOD_M10: return "M10";
         case PERIOD_M12: return "M12";
         case PERIOD_M15: return "M15";
         case PERIOD_M20: return "M20";
         case PERIOD_M30: return "M30";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H2: return "H2";
         case PERIOD_H3: return "H3";
         case PERIOD_H4: return "H4";
         case PERIOD_H6: return "H6";
         case PERIOD_H8: return "H8";
         case PERIOD_H12: return "H12";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

// Base condition v1.0

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

// Condition base v2.0

#ifndef ACondition_IMP
#define ACondition_IMP

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
// Symbol info v.1.2

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
   double GetMinVolume() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
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
// And condition v1.0



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

   void Add(ICondition *condition, bool addRef)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
      if (addRef)
      {
         condition.AddRef();
      }
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
};
#endif

// Bar condnitions v1.0

#ifndef BarConditions_IMP
#define BarConditions_IMP

class MinBodySizeCondition : public ACondition
{
   double _minSize;
public:
   MinBodySizeCondition(const string symbol, ENUM_TIMEFRAMES timeframe, double minSize)
      :ACondition(symbol, timeframe)
   {
      _minSize = minSize;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double body = MathAbs(iOpen(_symbol, _timeframe, period) - iClose(_symbol, _timeframe, period));
      double candle = iHigh(_symbol, _timeframe, period) - iLow(_symbol, _timeframe, period);
      return candle == 0 ? (_minSize == 0) : (body / candle >= _minSize / 100.0);
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Min body size: " + (result ? "true" : "false");
   }
};
#endif

#ifndef TwoStreamsConditionType_IMP
#define TwoStreamsConditionType_IMP

enum TwoStreamsConditionType
{
   FirstAboveSecond,
   FirstBelowSecond,
   FirstCrossOverSecond,
   FirstCrossUnderSecond
};

#endif
// Bands conditions v1.0

#ifndef BB_Conditions_IMP
#define BB_Conditions_IMP

string GetPriceName(ENUM_APPLIED_PRICE price)
{
   switch (price)
   {
      case PRICE_CLOSE:
         return "Close";
      case PRICE_OPEN:
         return "Open";
      case PRICE_HIGH:
         return "High";
      case PRICE_LOW:
         return "Low";
      case PRICE_MEDIAN:
         return "Median";
      case PRICE_TYPICAL:
         return "Typical";
      case PRICE_WEIGHTED:
         return "Weighted";
   }
   return "";
}
int _indi;

class PriceBandsStreamCondition : public ACondition
{
   int _period;
   double _deviation;
   int _shift;
   ENUM_APPLIED_PRICE _price;
   TwoStreamsConditionType _condition;
   int _streamIndex;
public:
   PriceBandsStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      TwoStreamsConditionType condition,
      int period,
      double deviation,
      int shift,
      ENUM_APPLIED_PRICE price,
      int streadIndex)
      :ACondition(symbol, timeframe)
   {
      _streamIndex = streadIndex;
      _condition = condition;
      _period = period;
      _deviation = deviation;
      _shift = shift;
      _price = price;
   }

   ~PriceBandsStreamCondition()
   {
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      string sign = "";
      switch (_condition)
      {
         case FirstAboveSecond:
            sign = ">";
            break;
         case FirstBelowSecond:
            sign = "<";
            break;
         case FirstCrossOverSecond:
            sign = "co";
            break;
         case FirstCrossUnderSecond:
            sign = "cu";
            break;
      }
      return GetPriceName(_price) + " " + sign + " " + GetBBStreamName() + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double price0 = GetPrice(period);
      double price1 = GetPrice(period + 1);
      double buffer[2];
      if (CopyBuffer(_indi, _streamIndex, period, 2, buffer) != 2)
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return price0 > buffer[0];
         case FirstBelowSecond:
            return price0 < buffer[0];
         case FirstCrossOverSecond:
            return price0 >= buffer[0] && price1 < buffer[1];
         case FirstCrossUnderSecond:
            return price0 <= buffer[0] && price1 > buffer[1];
      }
      return false;
   }
private:
   string GetBBStreamName()
   {
      switch (_streamIndex)
      {
         case BASE_LINE:
            return "Average";
         case UPPER_BAND:
            return "Upper";
         case LOWER_BAND:
            return "Lower";
      }
      return "";
   }
   double GetPrice(int period)
   {
      switch (_price)
      {
         case PRICE_CLOSE:
            return iClose(_symbol, _timeframe, period);
         case PRICE_OPEN:
            return iOpen(_symbol, _timeframe, period);
         case PRICE_HIGH:
            return iHigh(_symbol, _timeframe, period);
         case PRICE_LOW:
            return iLow(_symbol, _timeframe, period);
         case PRICE_MEDIAN:
            return (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period)) / 2.0;
         case PRICE_TYPICAL:
            return (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 3.0;
         case PRICE_WEIGHTED:
            return (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
      }
      return 0;
   }
};

#endif
// PriceStream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

// ABaseStream v1.0
#ifndef ABaseStream_IMP
#define ABaseStream_IMP
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
class ABaseStream : public IStream
{
protected:
   int _references;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   ABaseStream(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }

   ~ABaseStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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
class PriceStream : public ABaseStream
{
   ENUM_APPLIED_PRICE _price;
   double _pipSize;
public:
   PriceStream(string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_PRICE price)
      :ABaseStream(symbol, timeframe)
   {
      _price = price;

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PRICE_CLOSE:
               val[i] = iClose(_symbol, _timeframe, period + i);
               break;
            case PRICE_OPEN:
               val[i] = iOpen(_symbol, _timeframe, period + i);
               break;
            case PRICE_HIGH:
               val[i] = iHigh(_symbol, _timeframe, period + i);
               break;
            case PRICE_LOW:
               val[i] = iLow(_symbol, _timeframe, period + i);
               break;
            case PRICE_MEDIAN:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i)) / 2.0;
               break;
            case PRICE_TYPICAL:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i)) / 3.0;
               break;
            case PRICE_WEIGHTED:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i) * 2) / 4.0;
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

#endif
// Alert signal v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AlertSignal_IMP
#define AlertSignal_IMP





class AlertSignal
{
   double _signals[];
   ICondition* _condition;
   IStream* _price;
   Signaler* _signaler;
   string _message;
   datetime _lastSignal;
public:
   AlertSignal(ICondition* condition, Signaler* signaler)
   {
      _condition = condition;
      _price = NULL;
      _signaler = signaler;
   }

   ~AlertSignal()
   {
      if (_price != NULL)
         _price.Release();
      if (_condition != NULL)
         _condition.Release();
   }

   void Init()
   {
      ArrayInitialize(_signals, EMPTY_VALUE);
   }

   int RegisterStreams(int id, string name, int code, color clr, IStream* price)
   {
      _message = name;
      _price = price;
      _price.AddRef();
      SetIndexBuffer(id, _signals, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id, PLOT_LABEL, name);
      PlotIndexSetInteger(id, PLOT_ARROW, code);
      ArraySetAsSeries(_signals, true);
      
      return id + 1;
   }

   void Update(int period, datetime date)
   {
      if (!_condition.IsPass(period, date))
      {
         _signals[period] = EMPTY_VALUE;
         return;
      }

      if (period == 0)
      {
         string symbol = _signaler.GetSymbol();
         datetime dt = iTime(symbol, _signaler.GetTimeframe(), 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
            _lastSignal = dt;
         }
      }

      double price[1];
      if (!_price.GetSeriesValues(period, 1, price))
      {
         return;
      }

      _signals[period] = price[0];
   }
};

#endif

AlertSignal* up;
AlertSignal* down;
Signaler* mainSignaler;
double bl[], tl[];

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

int OnInit(void)
{
   _indi = iBands(_Symbol, (ENUM_TIMEFRAMES)_Period, bb_period, bb_shift, bb_deviation, bb_price);
   IndicatorObjPrefix = GenerateIndicatorPrefix("bbwsf");
   IndicatorSetString(INDICATOR_SHORTNAME, "BB with shadow filter");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   
   //register outputs

   SetIndexBuffer(0, tl, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   SetIndexBuffer(1, bl, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);

   ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
   mainSignaler = new Signaler(_Symbol, timeframe);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");
   
   AndCondition* upCondition = new AndCondition();
   upCondition.Add(new PriceBandsStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, bb_period, bb_deviation, bb_shift, bb_price, LOWER_BAND), false);
   upCondition.Add(new MinBodySizeCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, body_size), false);
   AndCondition* downCondition = new AndCondition();
   downCondition.Add(new PriceBandsStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, bb_period, bb_deviation, bb_shift, bb_price, UPPER_BAND), false);
   downCondition.Add(new MinBodySizeCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, body_size), false);
   up = new AlertSignal(upCondition, mainSignaler);
   down = new AlertSignal(downCondition, mainSignaler);
      
   int id = 2;
   PriceStream* highStream = new PriceStream(_Symbol, timeframe, PRICE_HIGH);
   PriceStream* lowStream = new PriceStream(_Symbol, timeframe, PRICE_LOW);
   id = up.RegisterStreams(id, "Up", 217, up_color, highStream);
   id = down.RegisterStreams(id, "Down", 218, down_color, lowStream);
   lowStream.Release();
   highStream.Release();
   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   IndicatorRelease(_indi);
   delete mainSignaler;
   mainSignaler = NULL;
   delete up;
   up = NULL;
   delete down;
   down = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      //ArrayInitialize(out, EMPTY_VALUE);
      up.Init();
      down.Init();
   }
   int first = 0;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldIndex = rates_total - 1 - pos;
      double buffer[1];
      if (CopyBuffer(_indi, UPPER_BAND, oldIndex, 1, buffer) != 1)
      {
         continue;
      }
      tl[pos] = buffer[0];
      if (CopyBuffer(_indi, LOWER_BAND, oldIndex, 1, buffer) != 1)
      {
         continue;
      }
      bl[pos] = buffer[0];
      up.Update(oldIndex, time[pos]);
      down.Update(oldIndex, time[pos]);
   }
   return rates_total;
}