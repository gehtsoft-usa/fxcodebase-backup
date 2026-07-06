
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70489

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

//---- The indicator is drawn in a separate window
#property indicator_separate_window 
//---- The number of indicator buffers is 3
#property indicator_buffers 5
//---- 1 graphical construction is used
#property indicator_plots   3

//+-----------------------------------+
//|  Parameters of indicator 1        |
//+-----------------------------------+
//---- The indicator is drawn as a colored cloud
#property indicator_type3   DRAW_FILLING
//---- The following colors are used
#property indicator_color3  clrThistle,clrOrange
//---- The label of the indicator
#property indicator_label3  "Lower Damiani_volatmeter;Upper Damiani_volatmeter"

#define ACT_ON_SWITCH
//+-----------------------------------+
//|  Declaring constants              |
//+-----------------------------------+
#define RESET  0 // A constant for returning an indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int    Viscosity=7;
input int    Sedimentation=50;
input double Threshold_level=1.1;
input bool   lag_supressor=true;
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

//+-----------------------------------+

//---- Declaring integer variables of data calculation start
int  min_rates_total;
//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double DnBuffer[],ThBuffer[],ClBuffer[];

double lag_s_K;
//---- Declaring integer variables for the indicator handles
int ATR1_Handle,ATR2_Handle,Std1_Handle,Std2_Handle;

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

// Base condition v1.1

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

// Condition base v2.1

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
// Act on switch condition v1.1



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

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Switch of (" + _condition.GetLogMessage(period, date) + (IsPass(period, date) ? ")=true" : ")=false");
   }
};
#endif
// ABaseStream v1.1
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

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};
#endif

// PriceStream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

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
      _signals[period] = UpBuffer._data[period];
   }
};

#endif

class IndicatorOutputStream : public ABaseStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_DATA);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_CALCULATIONS);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[period + i];
      }
      return true;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[size - 1 - period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period - i];
      }
      return true;
   }
};

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
      return DnBuffer[period] > UpBuffer._data[period];
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
      return DnBuffer[period] < UpBuffer._data[period];
   }
};

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
IndicatorOutputStream* UpBuffer;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(Viscosity,Sedimentation)+4);
   lag_s_K=0.5;

   ATR1_Handle=iATR(NULL,0,Viscosity);
   if(ATR1_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the ATR indicator");
   ATR2_Handle=iATR(NULL,0,Sedimentation);
   if(ATR2_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the ATR indicator");
   Std1_Handle=iStdDev(NULL,0,Viscosity,0,MODE_LWMA,PRICE_TYPICAL);
   if(Std1_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the StdDev indicator");
   Std2_Handle=iStdDev(NULL,0,Sedimentation,0,MODE_LWMA,PRICE_TYPICAL);
   if(Std2_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the StdDev indicator");
   
   UpBuffer = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   UpBuffer.RegisterStream(2);
   ArraySetAsSeries(UpBuffer._data,true);

   SetIndexBuffer(3,DnBuffer,INDICATOR_DATA);
   ArraySetAsSeries(DnBuffer,true);

   SetIndexBuffer(4,ClBuffer,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(ClBuffer,true);

   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

   IndicatorSetString(INDICATOR_SHORTNAME,"Damiani_volatmeter");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
   IndicatorObjPrefix = GenerateIndicatorPrefix("dv");

   ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
   int id = 0;

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
      id = alerts[size].RegisterStreams(id, 0, "Up", 217, up_color, UpBuffer);
      id = alerts[size + 1].RegisterStreams(id, 0, "Down", 218, down_color, UpBuffer);
   }
}

void OnDeinit(const int reason)
{
   UpBuffer.Release();
   delete mainSignaler;
   mainSignaler = NULL;
   for (int i = 0; i < ArraySize(alerts); ++i)
   {
      delete alerts[i];
   }
   ArrayResize(alerts, 0);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- Checking if the number of bars is enough for the calculation
   if(BarsCalculated(ATR1_Handle)<rates_total
      || BarsCalculated(ATR2_Handle)<rates_total
      || BarsCalculated(Std1_Handle)<rates_total
      || BarsCalculated(Std2_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      //ArrayInitialize(out, EMPTY_VALUE);
      for (int i = 0; i < ArraySize(alerts); ++i)
      {
         alerts[i].Init();
      }
   }

//---- Declaring floating point variables  
   double ATR1[],ATR2[],STD1[],STD2[];
   double vol;
//---- Declaration of integer variables
   int to_copy,limit;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for the calculation of the new bars only

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(ATR1_Handle,0,0,to_copy,ATR1)<=0) return(RESET);
   if(CopyBuffer(ATR2_Handle,0,0,to_copy,ATR2)<=0) return(RESET);
   if(CopyBuffer(Std1_Handle,0,0,to_copy,STD1)<=0) return(RESET);
   if(CopyBuffer(Std2_Handle,0,0,to_copy,STD2)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(ATR1,true);
   ArraySetAsSeries(ATR2,true);
   ArraySetAsSeries(STD1,true);
   ArraySetAsSeries(STD2,true);

//---- main cycle of calculation of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
   {
      double sa=ATR1[bar];
      double s1=ClBuffer[bar+1];
      double s3=ClBuffer[bar+3];
      double atr=NormalizeDouble(sa,_Digits);

      if (lag_supressor)
         vol = sa / ATR2[bar] + lag_s_K * (s1 - s3);
      else
         vol = sa / ATR2[bar];
      double anti_thres=STD1[bar];
      anti_thres/=STD2[bar];
      double t = Threshold_level - anti_thres;
      if(vol>t)
      {
         DnBuffer[bar]=vol;
         IndicatorSetString(INDICATOR_SHORTNAME,
                            "DAMIANI Signal/Noise: TRADE  /  ATR= "+DoubleToString(atr,_Digits)+"    values:");
      }
      else
      {
         DnBuffer[bar]=vol;
         IndicatorSetString(INDICATOR_SHORTNAME,
                            "DAMIANI Signal/Noise: DO NOT trade  /  ATR= "+DoubleToString(atr,_Digits)+"    values:");
      }

      ClBuffer[bar]=vol;
      UpBuffer._data[bar] = t;

      for (int i = 0; i < ArraySize(alerts); ++i)
      {
         alerts[i].Update(bar, Time[bar]);
      }
   }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
