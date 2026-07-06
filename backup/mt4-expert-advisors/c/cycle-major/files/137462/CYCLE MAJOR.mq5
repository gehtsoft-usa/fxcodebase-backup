// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70409

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
#property indicator_buffers 21
#property indicator_plots 6
#property indicator_type1  DRAW_COLOR_HISTOGRAM
#property indicator_label1 "Name"
#property indicator_color1 DeepSkyBlue, Red
#property indicator_type2  DRAW_NONE
#property indicator_width1 4

#property indicator_minimum -1.0
#property indicator_maximum 1.0

input int       PriceActionFilter=1;
input int       Length=3;
input int       MajorCycleStrength=4;
input bool      UseCycleFilter=false;
input int       UseFilterSMAorRSI=1;
input int       FilterStrengthSMA=12;
input int       FilterStrengthRSI=21;
double MinorCycle[];
double MajorCycle[];
double MajorCycle_color[];
double ZL1[];

double Switch[], Switch2[];
double Price1BuyA[], Price2BuyA[];
double Price1BuyB[], Price2BuyB[];
double Price1SellA[], Price2SellA[];
double Price1SellB[], Price2SellB[];
double BuySwitchA[], BuySwitchB[], SellSwitchA[], SellSwitchB[], signal[];

string IndicatorObjPrefix;

#define ACT_ON_SWITCH

input color up_color = Green; // Up color
input color down_color = Red; // Down color
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
#ifdef ADVANCED_ALERTS
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";
#endif

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
// Act on switch condition v1.0



#ifndef ActOnSwitchCondition_IMP
#define ActOnSwitchCondition_IMP

class ActOnSwitchCondition : public ACondition
{
   ICondition* _condition;
   bool _current;
   datetime _currentDate;
   bool _last;
public:
   ActOnSwitchCondition(string symbol, ENUM_TIMEFRAMES timeframe, ICondition* condition)
      :ACondition(symbol, timeframe)
   {
      _last = false;
      _current = false;
      _currentDate = 0;
      _condition = condition;
      _condition.AddRef();
   }

   ~ActOnSwitchCondition()
   {
      _condition.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      datetime time = iTime(_symbol, _timeframe, period);
      if (time != _currentDate)
      {
         _last = _current;
         _currentDate = time;
      }
      _current = _condition.IsPass(period, date);
      return _current && !_last;
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
// Constant value stream v1.0

#ifndef ConstValueStream_IMP
#define ConstValueStream_IMP

class ConstValueStream : public ABaseStream
{
   double _value;
public:
   ConstValueStream(string symbol, const ENUM_TIMEFRAMES timeframe, double value)
      :ABaseStream(symbol, timeframe)
   {
      _value = value;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         val[i] = _value;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         val[i] = _value;
      }
      return true;
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

   int RegisterStreams(int id, int shift, string name, int code, color clr, IStream* price)
   {
      _message = name;
      _price = price;
      _price.AddRef();
      SetIndexBuffer(id, _signals, INDICATOR_DATA);
      PlotIndexSetInteger(id - shift, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id - shift, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id - shift, PLOT_LABEL, name);
      PlotIndexSetInteger(id - shift, PLOT_ARROW, code);
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

AlertSignal* alerts[];
Signaler* mainSignaler;

class UpAlertCondition : public ACondition
{
public:
   UpAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = iBars(_symbol, _timeframe) - period - 1;
      return signal[index] == 1;
   }
};

class DownAlertCondition : public ACondition
{
public:
   DownAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      int index = iBars(_symbol, _timeframe) - period - 1;
      return signal[index] == -1;
   }
};

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

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("cm");
   IndicatorSetString(INDICATOR_SHORTNAME, "Cycle Major");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id++, MajorCycle, INDICATOR_DATA);
   SetIndexBuffer(id++, MajorCycle_color, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(id++, MinorCycle, INDICATOR_DATA);

   ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
   ConstValueStream* valueStream = new ConstValueStream(_Symbol, timeframe, 0.5);

   mainSignaler = new Signaler(_Symbol, timeframe);
   mainSignaler.SetPopupAlert(Popup_Alert);
   mainSignaler.SetEmailAlert(Email_Alert);
   mainSignaler.SetPlaySound(Play_Sound, Sound_File);
   mainSignaler.SetNotificationAlert(Notification_Alert);
   #ifdef ADVANCED_ALERTS
   mainSignaler.SetAdvancedAlert(Advanced_Alert, Advanced_Key);
   #endif
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");
   {
      ICondition* upCondition = new UpAlertCondition(_Symbol, timeframe);
      ICondition* downCondition = new DownAlertCondition(_Symbol, timeframe);
      #ifdef ACT_ON_SWITCH
         ActOnSwitchCondition* upSwitch = new ActOnSwitchCondition(_Symbol, timeframe, upCondition);
         upCondition.Release();
         upCondition = upSwitch;
         ActOnSwitchCondition* downSwitch = new ActOnSwitchCondition(_Symbol, timeframe, downCondition);
         downCondition.Release();
         downCondition = downSwitch;
      #endif
      int size = ArraySize(alerts);
      ArrayResize(alerts, size + 2);
      alerts[size] = new AlertSignal(upCondition, mainSignaler);
      alerts[size + 1] = new AlertSignal(downCondition, mainSignaler);
      id = alerts[size].RegisterStreams(id, 1, "Up", 217, up_color, valueStream);
      id = alerts[size + 1].RegisterStreams(id, 1, "Down", 218, down_color, valueStream);
   }
   valueStream.Release();
   ma = iMA(_Symbol, _Period, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE);
   rsi = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   SetIndexBuffer(id++, ZL1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Price1BuyA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Price1SellA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Price2BuyA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Price2SellA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Price1BuyB, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Price1SellB, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Price2BuyB, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Price2SellB, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, BuySwitchA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, BuySwitchB, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, SellSwitchA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, SellSwitchB, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Switch, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Switch2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, signal, INDICATOR_CALCULATIONS);
}

int ma, rsi;

void OnDeinit(const int reason)
{
   IndicatorRelease(ma);
   delete mainSignaler;
   mainSignaler = NULL;
   for (int i = 0; i < ArraySize(alerts); ++i)
   {
      delete alerts[i];
   }
   ArrayResize(alerts, 0);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
      ArrayInitialize(MajorCycle, EMPTY_VALUE);
      ArrayInitialize(MajorCycle_color, 0);
      ArrayInitialize(MinorCycle, EMPTY_VALUE);
      ArrayInitialize(ZL1, EMPTY_VALUE);
      for (int i = 0; i < ArraySize(alerts); ++i)
      {
         alerts[i].Init();
      }
   }
   int first = 250;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;

      double srange = 0.0;
      int j = 0;
      for (int i = 0; i < 250; i++)
      {
         j++;
         int posr = pos - i;
         if (posr >= rates_total)
            break;
            
         srange = srange + (high[posr] - low[posr]);
      }
      double range = srange / j * Length;
      double buffer[1];
      if (CopyBuffer(ma, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      double CyclePrice = buffer[0];
      if (UseFilterSMAorRSI == 1)
      {
         ZL1[pos] = ZeroLag(CyclePrice, FilterStrengthSMA, pos);
      }
      else
      {
         if (CopyBuffer(rsi, 0, oldPos, 1, buffer) != 1)
         {
            continue;
         }
         ZL1[pos] = ZeroLag(buffer[0], FilterStrengthRSI, pos);
      }
      if (pos == first)
      {
         Price1BuyA[pos] = CyclePrice;
         Price1SellA[pos] = CyclePrice;
         Price1BuyB[pos] = pos;
         Price1SellB[pos] = pos;
         Price2BuyA[pos] = CyclePrice;
         Price2SellA[pos] = CyclePrice;
         Price2BuyB[pos] = pos;
         Price2SellB[pos] = pos;
      }
      else
      {
         Price1BuyA[pos] = Price1BuyA[pos - 1];
         Price1SellA[pos] = Price1SellA[pos - 1];
         Price2BuyA[pos] = Price2BuyA[pos - 1];
         Price2SellA[pos] = Price2SellA[pos - 1];
         Price1BuyB[pos] = Price1BuyB[pos - 1];
         Price1SellB[pos] = Price1SellB[pos - 1];
         Price2BuyB[pos] = Price2BuyB[pos - 1];
         Price2SellB[pos] = Price2SellB[pos - 1];

         BuySwitchA[pos] = BuySwitchA[pos - 1];
         SellSwitchA[pos] = SellSwitchA[pos - 1];
         BuySwitchB[pos] = BuySwitchB[pos - 1];
         SellSwitchB[pos] = SellSwitchB[pos - 1];
         Switch[pos] = Switch[pos - 1];
         Switch2[pos] = Switch2[pos - 1];
         if (Switch[pos] > -1)
         {
            if (CyclePrice < Price1BuyA[pos])
            {
               if ((!UseCycleFilter || ZL1[pos] <= ZL1[pos - 1]) && BuySwitchA[pos] == 1)
               {
                  MinorCycle[(int)Price1BuyB[pos]] = EMPTY_VALUE;
               }
               Price1BuyA[pos] = CyclePrice;
               Price1BuyB[pos] = pos;
               BuySwitchA[pos] = 1;
            }
            else if (CyclePrice > Price1BuyA[pos])
            {
               if (!UseCycleFilter || ZL1[pos] > ZL1[pos - 1])
               {
                  MinorCycle[(int)Price1BuyB[pos]] = -1;
                  signal[pos] = -1;
               }
               BuySwitchA[pos] = 1;
               if (CopyBuffer(ma, 0, rates_total - 1 - (int)Price1BuyB[pos], 1, buffer) != 1)
               {
                  continue;
               }
               double cyclePrice1 = buffer[0];
               if (CyclePrice - cyclePrice1 >= range) 
               {
                  Switch[pos] = -1;
                  Price1SellA[pos] = CyclePrice;
                  Price1SellB[pos] = pos;
                  SellSwitchA[pos] = 0;
                  BuySwitchA[pos] = 0;
               }            
            }
         }
         else
         {
            if (CyclePrice > Price1SellA[pos])
            {
               if ((!UseCycleFilter || ZL1[pos] > ZL1[pos - 1]) && SellSwitchA[pos] == 1)
               {
                  MinorCycle[(int)Price1SellB[pos]] = EMPTY_VALUE;
			      }
               Price1SellA[pos] = CyclePrice;
               Price1SellB[pos] = pos;
               SellSwitchA[pos] = 1;   
            }
            else if (CyclePrice < Price1SellA[pos])
            {
               if (!UseCycleFilter || ZL1[pos] <= ZL1[pos - 1])
               {
                  MinorCycle[(int)Price1SellB[pos]] = 1; 
                  signal[pos] = 1;
			      }

               SellSwitchA[pos] = 0;
               if (CopyBuffer(ma, 0, rates_total - 1 - (int)Price1SellB[pos], 1, buffer) != 1)
               {
                  continue;
               }
			      double cyclePrice2 = buffer[0];
			      if ((cyclePrice2 - CyclePrice) >= range)
			      {
				      Switch[pos] = 1;
                  Price1BuyA[pos] = CyclePrice;
                  Price1BuyB[pos] = pos;
                  SellSwitchA[pos] = 0;
                  BuySwitchA[pos] = 0;
               }
            } 
         }
         if (Switch2[pos] > -1)
         {
            if (CyclePrice < Price2BuyA[pos])
            {
               if ((!UseCycleFilter || ZL1[pos] <= ZL1[pos - 1]) && BuySwitchB[pos] == 1)
               {
                  MajorCycle[(int)Price2BuyB[pos]] = EMPTY_VALUE;
               }
			      Price2BuyA[pos] = CyclePrice;
               Price2BuyB[pos] = pos;
               BuySwitchB[pos] = 1;
            } 
            else if (CyclePrice > Price2BuyA[pos])
            {
			      if (!UseCycleFilter || ZL1[pos] > ZL1[pos - 1])
               {  
                  MajorCycle[(int)Price2BuyB[pos]] = -1; 
                  MajorCycle_color[(int)Price2BuyB[pos]] = 0;
               }

               BuySwitchB[pos] = 1;
               if (CopyBuffer(ma, 0, rates_total - 1 - (int)Price2BuyB[pos], 1, buffer) != 1)
               {
                  continue;
               }
			      double cyclePrice3 = buffer[0];
			      if (CyclePrice - cyclePrice3 >= range *  MajorCycleStrength)
			      {
                  Switch2[pos] = -1;
                  Price2SellA[pos] = CyclePrice;
                  Price2SellB[pos] = pos;
                  SellSwitchB[pos] = 0;
                  BuySwitchB[pos] = 0;
               }
            }
         }
         else
         {
            if (CyclePrice  > Price2SellA[pos])
            {
			      if ((!UseCycleFilter || ZL1[pos] > ZL1[pos - 1]) && SellSwitchB[pos] == 1)
				   {
                  MajorCycle[(int)Price2SellB[pos]] = EMPTY_VALUE;
               }
			      Price2SellA[pos] = CyclePrice;
               Price2SellB[pos] = pos;
               SellSwitchB[pos] = 1;
            }
            else if (CyclePrice < Price2SellA[pos])
            {
      			if (!UseCycleFilter || ZL1[pos] <= ZL1[pos - 1]) 
      			{
      			   MajorCycle[(int)Price2SellB[pos]] = 1;
      			   MajorCycle_color[(int)Price2SellB[pos]] = 1;
			      }

               SellSwitchB[pos] = 1;
               if (CopyBuffer(ma, 0, rates_total - 1 - (int)Price2SellB[pos], 1, buffer) != 1)
               {
                  continue;
               }
	            double cyclePrice4 = buffer[0];
			      if (cyclePrice4 - CyclePrice >= range *  MajorCycleStrength)
			      {
                  Switch2[pos] = 1;
                  Price2BuyA[pos] = CyclePrice;
                  Price2BuyB[pos] = pos;
                  SellSwitchB[pos] = 0;
                  BuySwitchB[pos] = 0;
               }
            }
         }
      }
      for (int i = 0; i < ArraySize(alerts); ++i)
      {
         alerts[i].Update(oldPos, time[pos]);
      }
   }
   return rates_total;
}

double ZeroLag(double price, int length, int pos)
{   
   if (length < 3)
   {
      return price;
   }
   double aa = MathExp(-1.414 * 3.14159 / length);
   double bb = 2 * aa * MathCos(1.414 * 180 / length);
   double CB = bb;
   double CC = -aa * aa;
   double CA = 1 - CB - CC;
   double CD = CA * price + CB * ZL1[pos - 1] + CC * ZL1[pos - 2];
   return CD;
}


