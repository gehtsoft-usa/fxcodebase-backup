// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70860
//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

//---------ang_pr (Din)--------------------
#property indicator_separate_window
#property indicator_buffers 16
//---
//#property indicator_color1 clrDarkGray  //Olive
#property indicator_color1 clrSteelBlue  //Olive
#property indicator_color2 clrIndianRed  //Tomato
#property indicator_color3 clrGreenYellow //DarkBlue
//---
#property indicator_color4 clrOrange  //RoyalBlue
#property indicator_color5 clrDeepPink  //Red
#property indicator_color6 clrLimeGreen
#property indicator_color7 clrHotPink  //Orange
#property indicator_color8 clrSpringGreen  //LimeGreen
//---
//#property indicator_width1 2
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 0
//---
#property indicator_width4 2
#property indicator_width5 0
#property indicator_width6 0
#property indicator_width7 2
#property indicator_width8 2
//---
//#property indicator_style1 0
#property indicator_style1 0
#property indicator_style2 0
#property indicator_style3 2
//---
#property indicator_style4 0
#property indicator_style5 1
#property indicator_style6 1
#property indicator_style7 0
#property indicator_style8 0
//---
#property indicator_level1 0
#property indicator_level2 -20  //30
#property indicator_level3 20  //70
#property indicator_levelstyle 2
#property indicator_levelcolor clrDimGray
//-----------------------------------
//-----------------------------------

input int               RSIPeriod = 15;   
input ENUM_APPLIED_PRICE RSIPrice = PRICE_CLOSE;
input int               SigPeriod = 21;  //42;  //32;  
input ENUM_MA_METHOD      SigMode = MODE_LWMA;  

input int                BarsBack = 240;
input double             FiboBand = 0.786;
input double              StdKoef = 3.32;     // 0.1454, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.414, 1.618, 2.058, 2.618, 3.32, 4.236, 5.35, 6.853....
input int                    mPer = 3;
input int                    iPer = 0;
input double buy_level = 5; // Buy level
input double sell_level = -5; // Sell level

//-----------------------------------
//-----------------------------------
double HISTOUP[],HISTODN[], SIGMA[], FINRSI[];
double CENTER[], StdHI[], StdLO[], FibHI[], FibLO[];
double ai[10,10], b[10], x[10], sx[20];
double sum;
int    ip, p, n, f;
double qq, mm, tt;
int    ii, jj, kk, ll, nn;
double sq, std;
#define ACT_ON_SWITCH

enum SingalMode
{
   SingalModeLive, // Live
   SingalModeOnBarClose // On bar close
};

enum DisplayType
{
   Arrows, // Arrows
   ArrowsOnMainChart, // Arrows on main chart
   Candles, // Candles color
   Lines // Lines
};
input SingalMode signal_mode = SingalModeLive; // Signal mode
input bool filter_consecutive = false; // Filter consecutive alerts
input DisplayType Type = Arrows; // Presentation Type
input double shift_arrows_pips = 0.1; // Shift arrows
input color up_color = Blue; // Up color
input color down_color = Red; // Down color
input int font_size = 12; // Font size

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
// Act on switch condition v4.2



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
      if (_currentDate == 0)
      {
         _currentDate = time;
         _current = _condition.IsPass(period, date);
         _last = _current;
      }
      else if (time != _currentDate)
      {
         _last = _current;
         _currentDate = time;
         _current = _condition.IsPass(period, date);
      }
      else
      {
         _current = _condition.IsPass(period, date);
      }
      return _current && !_last;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Switch of (" + _condition.GetLogMessage(period, date) + (IsPass(period, date) ? ")=true" : ")=false");
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
// Price stream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
// Stream base v1.0

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
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



// Abstract stream v1.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

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

   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
#define AStream_IMP
#endif
// IBarStream v2.1



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

   virtual void Refresh() = 0;
};
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

class PriceStream : public AStreamBase
{
   PriceType _price;
   IBarStream* _source;
public:
   PriceStream(IBarStream* source, const PriceType __price)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
      _price = __price;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            if (!_source.GetClose(period, val))
            {
               return false;
            }
            break;
         case PriceOpen:
            if (!_source.GetOpen(period, val))
            {
               return false;
            }
            break;
         case PriceHigh:
            if (!_source.GetHigh(period, val))
            {
               return false;
            }
            break;
         case PriceLow:
            if (!_source.GetLow(period, val))
            {
               return false;
            }
            break;
         case PriceMedian:
            {
               double high, low;
               if (!_source.GetHighLow(period, high, low))
               {
                  return false;
               }
               val = (high + low) / 2.0;
            }
            break;
         case PriceTypical:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open, close;
               if (!_source.GetOpenClose(period, open, close))
               {
                  return false;
               }
               val = (open + close) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close + open) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               if (open > close)
                  val = (high + close) / 2.0;
               else
                  val = (low + close) / 2.0;
            }
            break;
         // case PriceVolume:
         //    if (!_source.GetVolume(period, val))
         //    {
         //       return false;
         //    }
         //    break;
      }
      return true;
   }
};

class SimplePriceStream : public AStream
{
   PriceType _price;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
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
//Signaler v2.0
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
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

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
         AdvancedAlert(advanced_key, message, "", "");
   }
};

// Alert signal v4.2
// More templates and snippets on https://github.com/sibvic/mq4-templates

// Candles stream v.1.3
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
   }

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
   virtual void Init() = 0;
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

   void Init()
   {
      _candleStreams.Init();
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
      SetIndexEmptyValue(id, EMPTY_VALUE);
      return id + 1;
   }

   void Init()
   {
      ArrayInitialize(_signals, EMPTY_VALUE);
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
   int _fontSize;
public:
   MainChartAlertSignalArrow(int fontSize)
   {
      _fontSize = fontSize;
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

   void Init()
   {
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
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, _fontSize);
         ObjectSetInteger(0, id, OBJPROP_COLOR, _color);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, Time[period]);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, CharToStr(_code));
   }
};


class MainChartAlertSignalLine : public IAlertSignalOutput
{
   string _labelId;
   color _color;
public:
   int Register(int id, string labelId, color clr)
   {
      _labelId = labelId;
      _color = clr;
      
      return id;
   }

   void Init()
   {
   }

   virtual void Clear(int period)
   {
      ResetLastError();
      string id = _labelId + TimeToString(Time[period]);
      ObjectDelete(id);
   }

   virtual void Set(int period)
   {
      ResetLastError();
      string id = _labelId + TimeToString(Time[period]);
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_VLINE, 0, Time[period], 0))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetInteger(0, id, OBJPROP_COLOR, _color);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, Time[period]);
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
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   AlertSignal(ICondition* condition, IAction* actionOnCondition, string symbol, ENUM_TIMEFRAMES timeframe, Signaler* signaler, bool onBarClose = false)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _actionOnCondition = actionOnCondition;
      if (_actionOnCondition != NULL)
      {
         _actionOnCondition.AddRef();
      }
      _signalOutput = NULL;
      _condition = condition;
      _condition.AddRef();
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
      _condition.Release();
   }

   int RegisterArrows(int id, string name, string labelId, int code, color clr, IStream* price, int fontSize)
   {
      _message = name;
      MainChartAlertSignalArrow* signalOutput = new MainChartAlertSignalArrow(fontSize);
      _signalOutput = signalOutput;
      return signalOutput.Register(id, labelId, (uchar)code, clr, price);
   }

   int RegisterLines(int id, string name, string labelId, color clr)
   {
      _message = name;
      MainChartAlertSignalLine* signalOutput = new MainChartAlertSignalLine();
      _signalOutput = signalOutput;
      return signalOutput.Register(id, labelId, clr);
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

   void Init()
   {
      _signalOutput.Init();
   }

   void Update(int period)
   {
      datetime dt = iTime(_symbol, _timeframe, _onBarClose ? period + 1 : period);

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
         dt = iTime(_symbol, _timeframe, 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(_message);
            _lastSignal = dt;
         }
      }

      _signalOutput.Set(period);
   }
};

#endif



// Stream wrapper v1.0

#ifndef StreamWrapper_IMP
#define StreamWrapper_IMP

class StreamWrapper : public AStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   StreamWrapper(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, _stream);
      return id + 1;
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (ArrayRange(_stream, 0) != totalBars) 
      {
         ArrayResize(_stream, totalBars);
      }
      _stream[period] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      if (ArrayRange(_stream, 0) != totalBars) 
      {
         ArrayResize(_stream, totalBars);
      }
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

#endif
// AAction v1.0


#ifndef AAction_IMP
#define AAction_IMP

class AAction : public IAction
{
protected:
   int _references;
   AAction()
   {
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
};

#endif

class SetLastSignalAction : public AAction
{
   int _signal;
public:
   SetLastSignalAction(int signal)
   {
      _signal = signal;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      current_signal_date = date;
      current_signal_side = _signal;
      return true;
   }
};
class LastSignalNotCondition : public AConditionBase
{
   int _signal;
public:
   LastSignalNotCondition(int signal)
   {
      _signal = signal;
   }

   bool IsPass(const int period, const datetime date)
   {
      return last_signal_side != _signal;
   }
};

AlertSignal* conditions[];
Signaler* mainSignaler;
StreamWrapper* customStream;
int last_signal_side;
datetime current_signal_date;
int current_signal_side;

int CreateAlert(int id, ICondition* condition, IAction* action, int code, string message, color clr, PriceType priceType, int sign)
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 1);
   #ifdef ACT_ON_SWITCH
      ActOnSwitchCondition* upSwitch = new ActOnSwitchCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, condition);
      condition = upSwitch;
   #endif
   conditions[size] = new AlertSignal(condition, action, _Symbol, (ENUM_TIMEFRAMES)_Period, mainSignaler, signal_mode == SingalModeOnBarClose);
   condition.Release();
      
   switch (Type)
   {
      case Arrows:
         {
            id = conditions[size].RegisterStreams(id, message, code, clr, customStream);
         }
         break;
      case ArrowsOnMainChart:
         {
            SimplePriceStream* highStream = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, priceType);
            highStream.SetShift(shift_arrows_pips * sign);
            static int lastId = 1;
            id = conditions[size].RegisterArrows(id, message, IndicatorObjPrefix + IntegerToString(lastId++), code, clr, highStream, font_size);
            highStream.Release();
         }
         break;
      case Candles:
         {
            id = conditions[size].RegisterStreams(id, message, clr);
         }
         break;
      case Lines:
         {
            id = conditions[size].RegisterLines(id, message, IndicatorObjPrefix + IntegerToString(id), clr);
         }
         break;
   }
   return id;
}

int CreateAlert(int id, ENUM_TIMEFRAMES tf, color upColor, color downColor)
{
   AndCondition* upCondition = new AndCondition();
   upCondition.Add(new UpCondition(_Symbol, tf), false);
   SetLastSignalAction* upAction = NULL;
   if (filter_consecutive)
   {
      upCondition.Add(new LastSignalNotCondition(1), false);
      upAction = new SetLastSignalAction(1);
   }
   id = CreateAlert(id, upCondition, upAction, 217, "Up " + TimeframeToString(tf), upColor, PriceLow, -1);
   upCondition.Release();
   if (upAction != NULL)
   {
      upAction.Release();
   }
   
   AndCondition* downCondition = new AndCondition();
   downCondition.Add(new DownCondition(_Symbol, tf), false);
   SetLastSignalAction* downAction = NULL;
   if (filter_consecutive)
   {
      downCondition.Add(new LastSignalNotCondition(-1), false);
      downAction = new SetLastSignalAction(-1);
   }
   id = CreateAlert(id, downCondition, downAction, 218, "Down " + TimeframeToString(tf), downColor, PriceHigh, 1);
   downCondition.Release();
   if (downAction != NULL)
   {
      downAction.Release();
   }
   
   return id;
}

class UpCondition : public ACondition
{
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return HISTOUP[period] != EMPTY_VALUE && HISTOUP[period] > buy_level;
   }
};

class DownCondition : public ACondition
{
public:
   DownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return HISTODN[period] != EMPTY_VALUE && HISTODN[period] < sell_level;
   }
};
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

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
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
   return "";
}
int init()
{
   IndicatorShortName("COG RSI ["+(string)RSIPeriod+">"+(string)SigPeriod+"]");   //"COGMACD: Mod by Brooky-Indicators.com");
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorBuffers(17);   IndicatorDigits(0);
   //---
   SetIndexBuffer(0,HISTOUP);  SetIndexStyle(0,DRAW_HISTOGRAM);   SetIndexDrawBegin(0,RSIPeriod+SigPeriod);
   SetIndexBuffer(1,HISTODN);  SetIndexStyle(1,DRAW_HISTOGRAM);   SetIndexDrawBegin(1,RSIPeriod+SigPeriod);
   SetIndexBuffer(2,SIGMA);    SetIndexStyle(2,DRAW_LINE);        SetIndexDrawBegin(2,RSIPeriod+SigPeriod);   
   //---
   SetIndexBuffer(3,CENTER);   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4,StdHI);    SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(5,StdLO);    SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(6,FibHI);    SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(7,FibLO);    SetIndexStyle(7,DRAW_LINE);
   
   IndicatorObjPrefix = GenerateIndicatorPrefix("cogrsih");
   
   mainSignaler = new Signaler();
   mainSignaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");

   int id = 8;

   if (Type == Arrows)
   {
      customStream = new StreamWrapper(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   {
      id = CreateAlert(id, (ENUM_TIMEFRAMES)_Period, up_color, down_color);
   }
   if (customStream != NULL)
   {
      id = customStream.RegisterInternalStream(id);
   }
   SetIndexBuffer(16,FINRSI);   SetIndexStyle(16,DRAW_NONE);    //SetIndexDrawBegin(0,RSIPeriod+SigPeriod);

   p = MathRound(BarsBack);
   
   nn = mPer + 1;
   //------
   return(0);
}
//----------------------------------------------------------
int deinit()
{
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
   Comment("");  return(0);
}
//**********************************************************************************************
int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars <= 0 || counted_bars > Bars)
   {
      //TODO: initialize your streams here
      //ArrayInitialize(ll, EMPTY_VALUE);
      if (customStream != NULL)
      {
         customStream.Init();
      }
      for (int i = 0; i < ArraySize(conditions); ++i)
      {
         AlertSignal* item = conditions[i];
         item.Init();
      }
   }

   p = BarsBack; 
   sx[1] = p + 1;
   SetIndexDrawBegin(4, Bars - p - 1);
   SetIndexDrawBegin(5, Bars - p - 1);
   SetIndexDrawBegin(6, Bars - p - 1);
   SetIndexDrawBegin(7, Bars - p - 1);
   SetIndexDrawBegin(8, Bars - p - 1); 
//----------------------sx-------------------------------------------------------------------

     int i, limit;
     int CountedBars=IndicatorCounted();
  //---- check for possible errors
     if (CountedBars<0) return(-1);
  //---- the last counted bar will be recounted
     if (CountedBars>0) CountedBars--;
     limit=Bars-CountedBars;
  //---- main loop
     for (i=0; i<limit; i++)
      {
       FINRSI[i] = iRSI(NULL,0,RSIPeriod,RSIPrice,i)-50;
       if (FINRSI[i] > 0)  HISTOUP[i] = FINRSI[i];
       if (FINRSI[i] < 0)  HISTODN[i] = FINRSI[i];
       //HISTOUP[ri]= iMACD(NULL,0,fma,sma,sigma,PRICE_CLOSE,MODE_MAIN,ri);//iStochastic(NULL,0,fma,sma,sigma,MODE_SMA,0,MODE_MAIN,ri);
       //SIGMA[ri]= iMACD(NULL,0,fma,sma,sigma,PRICE_CLOSE,MODE_SIGNAL,ri);//iStochastic(NULL,0,fma,sma,sigma,MODE_SMA,0,MODE_SIGNAL,ri);
      }
   
   for (i=0; i<limit; i++)  SIGMA[i] = iMAOnArray(FINRSI,Bars,SigPeriod,0,SigMode,i);

   for (int mi = 1; mi <= nn * 2 - 2; mi++)
   {
      sum = 0;
      for(n = iPer; n <= iPer + p; n++)
      {
         sum += MathPow(n, mi);
      }
      sx[mi + 1] = sum;
   }  
//----------------------syx-----------
   for (int mi = 1; mi <= nn; mi++)
   {
   
      sum = 0.00000;
      for(n = iPer; n <= iPer + p; n++)
      {
         if(mi == 1)
            sum += (( FINRSI[n]+SIGMA[n] )+0.0000001)/2;//rsi_period  iRSI(NULL,0,rsi_period,prICE_CLOSE,n)
         else
            sum += (((FINRSI[n]+SIGMA[n])+0.0000001)/2) * MathPow(n, mi - 1);
      }
      b[mi] = sum;
   } 
//===============Matrix=======================================================================================================
   for(jj = 1; jj <= nn; jj++)
   {
      for(ii = 1; ii <= nn; ii++)
      {
         kk = ii + jj - 1;
         ai[ii, jj] = sx[kk];
      }
   }  
//===============Gauss========================================================================================================
   for(kk = 1; kk <= nn - 1; kk++)
   {
      ll = 0; mm = 0;
      for(ii = kk; ii <= nn; ii++)
      {
         if(MathAbs(ai[ii, kk]) > mm)
         {
            mm = MathAbs(ai[ii, kk]);
            ll = ii;
         }
      }
      if(ll == 0)
         return(0);   

      if(ll != kk)
      {
         for(jj = 1; jj <= nn; jj++)
         {
            tt = ai[kk, jj];
            ai[kk, jj] = ai[ll, jj];
            ai[ll, jj] = tt;
         }
         tt = b[kk]; b[kk] = b[ll]; b[ll] = tt;
      }  
      for(ii = kk + 1; ii <= nn; ii++)
      {
         qq = ai[ii, kk] / ai[kk, kk];
         for(jj = 1; jj <= nn; jj++)
         {
            if(jj == kk)
               ai[ii, jj] = 0;
            else
               ai[ii, jj] = ai[ii, jj] - qq * ai[kk, jj];
         }
         b[ii] = b[ii] - qq * b[kk];
      }
   }  
   x[nn] = b[nn] / ai[nn, nn];
   for(ii = nn - 1; ii >= 1; ii--)
   {
      tt = 0;
      for(jj = 1; jj <= nn - ii; jj++)
      {
         tt = tt + ai[ii, ii + jj] * x[ii + jj];
         x[ii] = (1 / ai[ii, ii]) * (b[ii] - tt);
      }
   } 
//===========================================================================================================================
   for(n = iPer; n <= iPer + p; n++)
   {
      sum = 0;
      for(kk = 1; kk <= mPer; kk++)
      {
         sum += x[kk + 1] * MathPow(n, kk);
      }
      CENTER[n] = x[1] + sum;
   } 
//-----------------------------------Std-----------------------------------------------------------------------------------
   sq = 0.0;
   for(n = iPer; n <= iPer + p; n++)
   {
      sq += MathPow((((FINRSI[n]+SIGMA[n])+0.0000001)/2) - CENTER[n], 2);
   }
   sq = MathSqrt(sq / (p + 1)) * StdKoef;
   std = iStdDevOnArray(FINRSI,0,p,0,MODE_SMA,iPer) * StdKoef;
   for(n = iPer; n <= iPer + p; n++)
   {
      StdHI[n] = CENTER[n] + sq;
      StdLO[n] = CENTER[n] - sq;
      FibHI[n] = CENTER[n] + (FiboBand*std);
      FibLO[n] = CENTER[n] - (FiboBand*std);
   } 

   int minBars = 1;
   limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0 && !IsStopped(); --pos)
   {
      if (customStream != NULL)
      {
         customStream.SetValue(pos, FINRSI[pos]);
      }
      if (current_signal_date < Time[pos] && current_signal_side != 0)
      {
         last_signal_side = current_signal_side;
         current_signal_date = Time[signal_mode == SingalModeOnBarClose ? pos + 1 : pos];
      }
      current_signal_side = 0;
      for (int i = 0; i < ArraySize(conditions); ++i)
      {
         AlertSignal* item = conditions[i];
         item.Update(pos);
      }
   } 
//-------------------------------------------------------------------------------
   //ObjectMove("sstart" + sName, 0, Time[p], fx[p]);
//----------------------------------------------------------------------------------------------------------------------------
return(0);
}
//==========================================================================================================================   