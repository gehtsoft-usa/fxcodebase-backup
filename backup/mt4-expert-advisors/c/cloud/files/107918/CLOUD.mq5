// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=63831

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

input int      Fast_Average_Period = 50;
input ENUM_MA_METHOD Fast_MA_Method = MODE_EMA; // Fast Smoothing method
input ENUM_APPLIED_PRICE Fast_Price_Type = PRICE_CLOSE; // Fast Price type
input int      Slow_Average_Period = 200;
input ENUM_MA_METHOD Slow_MA_Method = MODE_EMA; // Slow Smoothing method
input ENUM_APPLIED_PRICE Slow_Price_Type = PRICE_CLOSE; // Slow Price type
input color    Color_Fast_MA       = clrYellow;
input color    Color_Slow_MA       = clrWhite;

double Fast_MA[];
double Slow_MA[];
double ma_color[];

bool   OriginalCalculation = false;

int i;
datetime LastAlert;

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 4
#property indicator_type1  DRAW_COLOR_HISTOGRAM2
#property indicator_color1 clrGreen, clrLime, clrOrange, clrRed, clrYellow, clrWhite

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
// PriceStream v1.1

#ifndef PriceStream_IMP
#define PriceStream_IMP

// ABaseStream v1.0
#ifndef ABaseStream_IMP
#define ABaseStream_IMP
// IStream v.1.2
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;

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

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PRICE_CLOSE:
               val[i] = iClose(_symbol, _timeframe, oldIndex + i);
               break;
            case PRICE_OPEN:
               val[i] = iOpen(_symbol, _timeframe, oldIndex + i);
               break;
            case PRICE_HIGH:
               val[i] = iHigh(_symbol, _timeframe, oldIndex + i);
               break;
            case PRICE_LOW:
               val[i] = iLow(_symbol, _timeframe, oldIndex + i);
               break;
            case PRICE_MEDIAN:
               val[i] = (iHigh(_symbol, _timeframe, oldIndex + i) + iLow(_symbol, _timeframe, oldIndex + i)) / 2.0;
               break;
            case PRICE_TYPICAL:
               val[i] = (iHigh(_symbol, _timeframe, oldIndex + i) + iLow(_symbol, _timeframe, oldIndex + i) + iClose(_symbol, _timeframe, oldIndex + i)) / 3.0;
               break;
            case PRICE_WEIGHTED:
               val[i] = (iHigh(_symbol, _timeframe, oldIndex + i) + iLow(_symbol, _timeframe, oldIndex + i) + iClose(_symbol, _timeframe, oldIndex + i) * 2) / 4.0;
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }
};

#endif
// Alert signal v1.1
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
      if (!_price.GetValues(period, 1, price))
         return;

      _signals[period] = price[0];
   }
};

#endif

AlertSignal* up;
AlertSignal* down;
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
      return Fast_MA[period] > Slow_MA[period] && Fast_MA[period + 1] < Slow_MA[period + 1];
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
      return Fast_MA[period] < Slow_MA[period] && Fast_MA[period + 1] > Slow_MA[period + 1];
   }
};

double out[];
int fastMA, slowMA;

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("cloud");
   IndicatorSetString(INDICATOR_SHORTNAME, "Cloud");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, Fast_MA, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_COLOR_HISTOGRAM2);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Color_Fast_MA);
   PlotIndexSetString(id, PLOT_LABEL, "Fast MA");
   ++id;

   SetIndexBuffer(id, Slow_MA, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_COLOR_HISTOGRAM2);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Color_Slow_MA);
   PlotIndexSetString(id, PLOT_LABEL, "Slow MA");
   ++id;

   SetIndexBuffer(id++, ma_color, INDICATOR_COLOR_INDEX);

   fastMA = iMA(_Symbol, _Period, Fast_Average_Period, 0, Fast_MA_Method, Fast_Price_Type);
   slowMA = iMA(_Symbol, _Period, Slow_Average_Period, 0, Slow_MA_Method, Slow_Price_Type);

   ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
   mainSignaler = new Signaler(_Symbol, timeframe);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");
   ICondition* upCondition = new UpAlertCondition(_Symbol, timeframe);
   ICondition* downCondition = new DownAlertCondition(_Symbol, timeframe);
   up = new AlertSignal(upCondition, mainSignaler);
   down = new AlertSignal(downCondition, mainSignaler);
      
   PriceStream* highStream = new PriceStream(_Symbol, timeframe, PRICE_HIGH);
   PriceStream* lowStream = new PriceStream(_Symbol, timeframe, PRICE_LOW);
   id = up.RegisterStreams(id, "Up", 217, up_color, highStream);
   id = down.RegisterStreams(id, "Down", 218, down_color, lowStream);
   lowStream.Release();
   highStream.Release();
}

void OnDeinit(const int reason)
{
   delete mainSignaler;
   mainSignaler = NULL;
   delete up;
   up = NULL;
   delete down;
   down = NULL;
   IndicatorRelease(fastMA);
   IndicatorRelease(slowMA);
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
      ArrayInitialize(Fast_MA, EMPTY_VALUE);
      ArrayInitialize(Slow_MA, EMPTY_VALUE);
      ArrayInitialize(ma_color, 0);
   }
   int first = MathMax(Fast_Average_Period, Slow_Average_Period);
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double fma[1];
      if (CopyBuffer(fastMA, 0, oldPos, 1, fma) != 1)
      {
         continue;
      }
      double sma[1];
      if (CopyBuffer(slowMA, 0, oldPos, 1, sma) != 1)
      {
         continue;
      }
      Fast_MA[pos] = fma[0];
      Slow_MA[pos] = sma[0];

      if (OriginalCalculation)
      {
         if (Fast_MA[pos] >= Fast_MA[pos - 1])
         {
            ma_color[pos] = (Slow_MA[pos] >= Slow_MA[pos - 1]) ? 0 : 1;
         }
         else
         {
            ma_color[pos] = (Slow_MA[pos] >= Slow_MA[pos - 1]) ? 2 : 3;
         }
      }
      else
      {
         if (Fast_MA[pos] >= Slow_MA[pos])
         {
            ma_color[pos] = (Fast_MA[pos] >= Fast_MA[pos - 1]) ? 0 : 1;
         }
         else
         {
            ma_color[pos] = (Fast_MA[pos] >= Fast_MA[pos - 1]) ? 2 : 3;
         }
      }
      up.Update(pos, 0);
      down.Update(pos, 0);
   }
   return rates_total;
}