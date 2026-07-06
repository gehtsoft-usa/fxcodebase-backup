// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70921

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
#property link "http://fxcodebase.com"
#property version "1.0"

// based on mladenfx@gmail.com
#property strict
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Ivory
#property indicator_width1 2
#property indicator_style2 STYLE_DASH
#property indicator_levelcolor DarkSlateGray

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_haclose,    // Heiken ashi close
   pr_haopen,     // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};

input ENUM_TIMEFRAMES TimeFrame_ = PERIOD_CURRENT;
input int NdxPeriod = 40;
input int NdxSmoothLength = 20;
input double NdxSmoothPhase = 0;
input bool NdxSmoothDouble = false;
input enPrices NdxPrice = pr_average;
input int NstPeriod = 20;
input int NstSmoothLength = 10;
input double NstSmoothPhase = 0;
input bool NstSmoothDouble = false;
input int NxcMaPeriod = 7;
input ENUM_MA_METHOD NxcMaMode = MODE_LWMA;
input int LinearRegressionLength = 150;
input double LinearRegressionChannelWidth = 2.0;
input string IndicatorUniqueID = "Nxc slope divergence";
input color ChartLineColor = MediumOrchid;
input ENUM_LINE_STYLE ChartLineMiddleStyle = STYLE_DOT;
input ENUM_LINE_STYLE ChartLineStyle = STYLE_DASH;
input color NxcLineColor = MediumOrchid;
input ENUM_LINE_STYLE NxcLineMiddleStyle = STYLE_DOT;
input ENUM_LINE_STYLE NxcLineStyle = STYLE_DASH;
input int levelOb = 50;
input int levelOs = -50;
input bool Interpolate = true;
input int HistoryBars = 1000;
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
   upCondition.Add(new RegularBullishDivergenceCondition(nxcma, _Symbol, tf), false);
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
   downCondition.Add(new RegularBearishDivergenceCondition(nxcma, _Symbol, tf), false);
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

// Regilar bearish divergence condition v1.1

#ifndef RegularBearishDivergenceCondition_IMP
#define RegularBearishDivergenceCondition_IMP

// Trough Condition v1.1





#ifndef TroughCondition_IMP
#define TroughCondition_IMP

class TroughCondition : public AConditionBase
{
   IStream* _source;
   int _bars;
public:
   TroughCondition(IStream* source, int bars)
   {
      _source = source;
      _source.AddRef();
      _bars = bars;
   }

   ~TroughCondition()
   {
      _source.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double centerValue;
      if (!_source.GetValue(period + _bars, centerValue))
         return false;

      for (int i = 0; i < _bars; ++i)
      {
         double leftValue;
         if (!_source.GetValue(period + _bars + i + 1, leftValue) || leftValue < centerValue)
            return false;
         double rightValue;
         if (!_source.GetValue(period + i, rightValue) || rightValue < centerValue)
            return false;
      }
      return true;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Trough: " + (result ? "true" : "false");
   }
};

#endif
// Peak Condition v1.1


#ifndef PeakCondition_IMP
#define PeakCondition_IMP

class PeakCondition : public AConditionBase
{
   IStream* _source;
   int _bars;
public:
   PeakCondition(IStream* source, int bars)
   {
      _source = source;
      _source.AddRef();
      _bars = bars;
   }

   ~PeakCondition()
   {
      _source.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double centerValue;
      if (!_source.GetValue(period + _bars, centerValue))
         return false;

      for (int i = 0; i < _bars; ++i)
      {
         double leftValue;
         if (!_source.GetValue(period + _bars + i + 1, leftValue) || leftValue > centerValue)
            return false;
         double rightValue;
         if (!_source.GetValue(period + i, rightValue) || rightValue > centerValue)
            return false;
      }
      return true;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Peak: " + (result ? "true" : "false");
   }
};

#endif


class RegularBearishDivergenceCondition : public AConditionBase
{
   TroughCondition* _trough;
   PeakCondition* _pricePeak;
public:
   RegularBearishDivergenceCondition(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _trough = new TroughCondition(stream, 2);
      SimplePriceStream* high = new SimplePriceStream(symbol, timeframe, PriceHigh);
      _pricePeak = new PeakCondition(high, 2);
      high.Release();
   }

   ~RegularBearishDivergenceCondition()
   {
      delete _pricePeak;
      delete _trough;
   }

   virtual bool IsPass(const int period, datetime date)
   {
      return _trough.IsPass(period, date) && _pricePeak.IsPass(period, date);
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Regular bearish divergence: " + (result ? "true" : "false");
   }
};

#endif
// Regilar bullush divergence condition v1.1

#ifndef RegularBullishDivergenceCondition_IMP
#define RegularBullishDivergenceCondition_IMP





class RegularBullishDivergenceCondition : public AConditionBase
{
   TroughCondition* _priceTrough;
   PeakCondition* _peak;
public:
   RegularBullishDivergenceCondition(IStream* stream, string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _peak = new PeakCondition(stream, 2);
      SimplePriceStream* low = new SimplePriceStream(symbol, timeframe, PriceLow);
      _priceTrough = new TroughCondition(low, 2);
      low.Release();
   }

   ~RegularBullishDivergenceCondition()
   {
      delete _priceTrough;
      delete _peak;
   }

   virtual bool IsPass(const int period, datetime date)
   {
      return _peak.IsPass(period, date) && _priceTrough.IsPass(period, date);
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Regular bullish divergence: " + (result ? "true" : "false");
   }
};

#endif

// Custom stream v2.1

#ifndef CustomStream_IMP
#define CustomStream_IMP

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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

// IndicatorOutputStream v3.0
class IndicatorOutputStream : public AStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, string name)
   {
      SetIndexStyle(id, DRAW_LINE);
      SetIndexBuffer(id, _data);
      SetIndexLabel(id, name);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, _data);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValue(const int period, double& val)
   {
      if (_data[period] == EMPTY_VALUE)
         return false;
      val = _data[period];
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};

double nxc[];
IndicatorOutputStream* nxcma;
double tBuffer[][7];
string indicatorFileName;
bool returnBars;
string shortName;
ENUM_TIMEFRAMES TimeFrame;

int init()
{
   SetIndexBuffer(0, nxc);
   nxcma = new IndicatorOutputStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   nxcma.RegisterStream(1, Ivory, "NXCMA");
   
   SetLevelValue(0, 0);
   SetLevelValue(1, levelOb);
   SetLevelValue(2, levelOs);

   indicatorFileName = WindowExpertName();
   returnBars = (TimeFrame == -99);
   TimeFrame = TimeFrame_ == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : TimeFrame_;

   shortName = IndicatorUniqueID + " - " + timeFrameToString(TimeFrame) + " nxc (ndx: " + NdxPeriod + "," + NdxSmoothLength + ") (nst: " + NstPeriod + "," + NstSmoothLength + ")";
   IndicatorShortName(shortName);

   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorObjPrefix = GenerateIndicatorPrefix("OCNNXC");
   IndicatorShortName("Ocn nxc jsmooth slope divergence 3 mtf");
   mainSignaler = new Signaler();
   mainSignaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");

   int id = 3;

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
   return (0);
}

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
   delete nxcma;
   for (int i = ObjectsTotal(); i >= 0; i--)
   {
      string name = ObjectName(i);
      if (StringFind(name, IndicatorUniqueID) == 0)
         ObjectDelete(name);
   }
   return (0);
}

#define iPrc 6

void DoAlerts()
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
   int minBars = 2;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0 && !IsStopped(); --pos)
   {
      if (customStream != NULL)
      {
         customStream.SetValue(pos, nxcma._data[pos]);
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
}

int start()
{
   int counted_bars = IndicatorCounted();
   int i, k, r, limit;

   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   limit = MathMin(Bars - counted_bars, Bars - NdxPeriod - 1);
   limit = MathMin(limit, Bars - NstPeriod - 1);
   if (returnBars)
   {
      nxc[0] = limit + 1;
      return (0);
   }

   if (TimeFrame == Period())
   {
      if (ArrayRange(tBuffer, 0) != Bars)
         ArrayResize(tBuffer, Bars);
      if (limit > HistoryBars)
         limit = HistoryBars;
      for (i = limit, r = Bars - i - 1; i >= 0; i--, r++)
      {
         double currPrice = getPrice(NdxPrice, Open, Close, High, Low, i);
         if (currPrice > 0)
            tBuffer[r][iPrc] = MathLog(currPrice);
         else
            tBuffer[r][iPrc] = 0.00;

         double sumMom = 0;
         double sumDen = 0;
         double sumDif = 0;

         for (k = 1; k < NdxPeriod; k++)
         {
            sumDif += MathAbs(tBuffer[r - k + 1][iPrc] - tBuffer[r - k][iPrc]);
            double stoch = sumDif != 0 ? (tBuffer[r][iPrc] - tBuffer[r - k][iPrc]) / sumDif : 0;
            double coeff = 1.0 / MathSqrt(k);

            sumMom += coeff * stoch;
            sumDen += coeff;
         }

         double ndxTemp = iDSmooth(100.0 * (sumMom / sumDen), NdxSmoothLength, NdxSmoothPhase, NdxSmoothDouble, i, 0);
         if (ndxTemp > 90)
            ndxTemp = 90 + (ndxTemp - 90) * 0.5;
         if (ndxTemp < -90)
            ndxTemp = -90 - (-ndxTemp - 90) * 0.5;

         double max = High[i];
         double min = Low[i];
         double sumSto = 0;

         for (k = 0, sumDen = 0; k < NstPeriod; k++)
         {
            if (max < High[i + k])
               max = High[i + k];
            if (min > Low[i + k])
               min = Low[i + k];
            double stoch = max != min ? (Close[i] - min) / (max - min) : 0;
            double coeff = 1.0 / MathSqrt(k + 1.0);

            sumSto += coeff * stoch;
            sumDen += coeff;
         }

         double nstTemp = iDSmooth((200.0 * sumSto / sumDen) - 100.0, NstSmoothLength, NstSmoothPhase, NstSmoothDouble, i, 20);
         if (nstTemp > 85)
            nstTemp = 85 + (nstTemp - 85) * 0.5;
         if (nstTemp < -85)
            nstTemp = -85 - (-nstTemp - 85) * 0.5;

         nxc[i] = ((MathAbs(ndxTemp) * nstTemp) + (MathAbs(nstTemp) * ndxTemp)) * 0.5;
         if (nxc[i] > 0)
            nxc[i] = MathSqrt(nxc[i]);
         else
            nxc[i] = MathSqrt(MathAbs(nxc[i])) * (-1);
         fillLrArray(i, 0, nxc[i]);
         fillLrArray(i, 1, getPrice(NdxPrice, Open, Close, High, Low, i));
      }
      if (limit > HistoryBars)
         limit = HistoryBars;
      for (i = limit; i >= 0; i--)
         nxcma._data[i] = iMAOnArray(nxc, 0, NxcMaPeriod, 0, NxcMaMode, i);
      double nxcError;
      double nxcSlope;
      double lrnxc = iLrValue(nxc[0], LinearRegressionLength, nxcSlope, nxcError, 0, 0);
      double prcError;
      double prcSlope;
      double lrPrc = iLrValue(getPrice(NdxPrice, Open, Close, High, Low, 0), LinearRegressionLength, prcSlope, prcError, 0, 1);
      int window = WindowFind(shortName);
      createLine(window, lrnxc, lrnxc - (LinearRegressionLength - 1.0) * nxcSlope, "nxcLine", NxcLineColor, NxcLineStyle, NxcLineMiddleStyle, nxcError * LinearRegressionChannelWidth);
      createLine(0, lrPrc, lrPrc - (LinearRegressionLength - 1.0) * prcSlope, "prcLine", ChartLineColor, ChartLineStyle, ChartLineMiddleStyle, prcError * LinearRegressionChannelWidth);
      DoAlerts();
      return (0);
   }

   limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, TimeFrame, indicatorFileName, -99, 0, 0) * TimeFrame / Period()));
   if (limit > HistoryBars)
      limit = HistoryBars;
   for (i = limit; i >= 0; i--)
   {
      int y = iBarShift(NULL, TimeFrame, Time[i]);
      nxc[i] = iCustom(NULL, TimeFrame, indicatorFileName, PERIOD_CURRENT, NdxPeriod, NdxSmoothLength, NdxSmoothPhase, NdxSmoothDouble, NdxPrice, NstPeriod, NstSmoothLength, NstSmoothPhase, NstSmoothDouble, NxcMaPeriod, NxcMaMode, LinearRegressionLength, LinearRegressionChannelWidth, IndicatorUniqueID, ChartLineColor, ChartLineMiddleStyle, ChartLineStyle, NxcLineColor, NxcLineMiddleStyle, NxcLineStyle, levelOb, levelOs, 0, y);
      nxcma._data[i] = iCustom(NULL, TimeFrame, indicatorFileName, PERIOD_CURRENT, NdxPeriod, NdxSmoothLength, NdxSmoothPhase, NdxSmoothDouble, NdxPrice, NstPeriod, NstSmoothLength, NstSmoothPhase, NstSmoothDouble, NxcMaPeriod, NxcMaMode, LinearRegressionLength, LinearRegressionChannelWidth, IndicatorUniqueID, ChartLineColor, ChartLineMiddleStyle, ChartLineStyle, NxcLineColor, NxcLineMiddleStyle, NxcLineStyle, levelOb, levelOs, 1, y);

      if (!Interpolate || y == iBarShift(NULL, TimeFrame, Time[i - 1]))
         continue;

      datetime time = iTime(NULL, TimeFrame, y);
      int n;
      for (n = 1; i + n < Bars && Time[i + n] >= time; n++)
         continue;
      for (int j = 1; j < n; j++)
      {
         nxc[i + j] = nxc[i] + (nxc[i + n] - nxc[i]) * j / n;
         nxcma._data[i + j] = nxcma._data[i] + (nxcma._data[i + n] - nxcma._data[i]) * j / n;
      }
   }
   DoAlerts();
   return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double wrk[][40];

#define bsmax 5
#define bsmin 6
#define volty 7
#define vsum 8
#define avolty 9

//
//
//
//
//

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s = 0)
{
   if (isDouble)
      return (iSmooth(iSmooth(price, MathSqrt(length), phase, i, s), MathSqrt(length), phase, i, s + 10));
   else
      return (iSmooth(price, length, phase, i, s));
}

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s = 0)
{
   if (length <= 1)
      return (price);
   if (ArrayRange(wrk, 0) != Bars)
      ArrayResize(wrk, Bars);

   int r = Bars - i - 1;
   if (r == 0)
   {
      int k;
      for (k = 0; k < 7; k++)
         wrk[r][k + s] = price;
      for (; k < 10; k++)
         wrk[r][k + s] = 0;
      return (price);
   }

   //
   //
   //
   //
   //

   double len1 = MathMax(MathLog(MathSqrt(0.5 * (length - 1))) / MathLog(2.0) + 2.0, 0);
   double pow1 = MathMax(len1 - 2.0, 0.5);
   double del1 = price - wrk[r - 1][bsmax + s];
   double del2 = price - wrk[r - 1][bsmin + s];
   double div = 1.0 / (10.0 + 10.0 * (MathMin(MathMax(length - 10, 0), 100)) / 100);
   int forBar = MathMin(r, 10);

   wrk[r][volty + s] = 0;
   if (MathAbs(del1) > MathAbs(del2))
      wrk[r][volty + s] = MathAbs(del1);
   if (MathAbs(del1) < MathAbs(del2))
      wrk[r][volty + s] = MathAbs(del2);
   wrk[r][vsum + s] = wrk[r - 1][vsum + s] + (wrk[r][volty + s] - wrk[r - forBar][volty + s]) * div;

   //
   //
   //
   //
   //

   wrk[r][avolty + s] = wrk[r - 1][avolty + s] + (2.0 / (MathMax(4.0 * length, 30) + 1.0)) * (wrk[r][vsum + s] - wrk[r - 1][avolty + s]);
   double dVolty = wrk[r][avolty + s] > 0 ? wrk[r][volty + s] / wrk[r][avolty + s] : 0;
   if (dVolty > MathPow(len1, 1.0 / pow1))
      dVolty = MathPow(len1, 1.0 / pow1);
   if (dVolty < 1)
      dVolty = 1.0;

   //
   //
   //
   //
   //

   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5 * (length - 1)) * len1;
   double Kv = MathPow(len2 / (len2 + 1), MathSqrt(pow2));

   if (del1 > 0)
      wrk[r][bsmax + s] = price;
   else
      wrk[r][bsmax + s] = price - Kv * del1;
   if (del2 < 0)
      wrk[r][bsmin + s] = price;
   else
      wrk[r][bsmin + s] = price - Kv * del2;

   //
   //
   //
   //
   //

   double R = MathMax(MathMin(phase, 100), -100) / 100.0 + 1.5;
   double beta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2);
   double alpha = MathPow(beta, pow2);

   wrk[r][0 + s] = price + alpha * (wrk[r - 1][0 + s] - price);
   wrk[r][1 + s] = (price - wrk[r][0 + s]) * (1 - beta) + beta * wrk[r - 1][1 + s];
   wrk[r][2 + s] = (wrk[r][0 + s] + R * wrk[r][1 + s]);
   wrk[r][3 + s] = (wrk[r][2 + s] - wrk[r - 1][4 + s]) * MathPow((1 - alpha), 2) + MathPow(alpha, 2) * wrk[r - 1][3 + s];
   wrk[r][4 + s] = (wrk[r - 1][4 + s] + wrk[r][3 + s]);

   //
   //
   //
   //
   //

   return (wrk[r][4 + s]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void createLine(int window, double price1, double price2, string addName, color theColor, int theStyle, int theMiddleStyle, double error)
{
   string name = IndicatorUniqueID + addName;
   if (ObjectFind(name) == -1)
      ObjectCreate(name, OBJ_TREND, window, 0, 0, 0, 0);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_PRICE2, price2);
   ObjectSet(name, OBJPROP_TIME1, Time[0]);
   ObjectSet(name, OBJPROP_TIME2, Time[LinearRegressionLength - 1]);
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_COLOR, theColor);
   ObjectSet(name, OBJPROP_STYLE, theMiddleStyle);
   if (error <= 0)
      return;
   name = IndicatorUniqueID + addName + "up";
   if (ObjectFind(name) == -1)
      ObjectCreate(name, OBJ_TREND, window, 0, 0, 0, 0);
   ObjectSet(name, OBJPROP_PRICE1, price1 + error);
   ObjectSet(name, OBJPROP_PRICE2, price2 + error);
   ObjectSet(name, OBJPROP_TIME1, Time[0]);
   ObjectSet(name, OBJPROP_TIME2, Time[LinearRegressionLength - 1]);
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_COLOR, theColor);
   ObjectSet(name, OBJPROP_STYLE, theStyle);
   name = IndicatorUniqueID + addName + "down";
   if (ObjectFind(name) == -1)
      ObjectCreate(name, OBJ_TREND, window, 0, 0, 0, 0);
   ObjectSet(name, OBJPROP_PRICE1, price1 - error);
   ObjectSet(name, OBJPROP_PRICE2, price2 - error);
   ObjectSet(name, OBJPROP_TIME1, Time[0]);
   ObjectSet(name, OBJPROP_TIME2, Time[LinearRegressionLength - 1]);
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_COLOR, theColor);
   ObjectSet(name, OBJPROP_STYLE, theStyle);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workLr[][2];
void fillLrArray(int i, int instanceNo, double value)
{
   if (ArrayRange(workLr, 0) != Bars)
      ArrayResize(workLr, Bars);
   i = Bars - i - 1;
   workLr[i][instanceNo] = value;
}
double iLrValue(double value, int period, double &slope, double &error, int r, int instanceNo = 0)
{
   if (ArrayRange(workLr, 0) != Bars)
      ArrayResize(workLr, Bars);
   r = Bars - r - 1;
   workLr[r][instanceNo] = value;
   if (r < period || period < 2)
      return (value);

   //
   //
   //
   //
   //

   double sumx = 0, sumxx = 0, sumxy = 0, sumy = 0, sumyy = 0;
   for (int k = 0; k < period; k++)
   {
      double price = workLr[r - k][instanceNo];
      sumx += k;
      sumxx += k * k;
      sumxy += k * price;
      sumy += price;
      sumyy += price * price;
   }
   slope = (period * sumxy - sumx * sumy) / (sumx * sumx - period * sumxx);
   error = MathSqrt((period * sumyy - sumy * sumy - slope * slope * (period * sumxx - sumx * sumx)) / (period * (period - 2)));

   //
   //
   //
   //
   //

   return ((sumy + slope * sumx) / period);
}

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//
//

double workHa[][4];
double getPrice(int price, const double &open[], const double &close[], const double &high[], const double &low[], int i, int instanceNo = 0)
{
   if (price >= pr_haclose && price <= pr_hatbiased)
   {
      if (ArrayRange(workHa, 0) != Bars)
         ArrayResize(workHa, Bars);
      int r = Bars - i - 1;

      double haOpen;
      if (r > 0)
         haOpen = (workHa[r - 1][instanceNo + 2] + workHa[r - 1][instanceNo + 3]) / 2.0;
      else
         haOpen = (open[i] + close[i]) / 2;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh = MathMax(high[i], MathMax(haOpen, haClose));
      double haLow = MathMin(low[i], MathMin(haOpen, haClose));

      if (haOpen < haClose)
      {
         workHa[r][instanceNo + 0] = haLow;
         workHa[r][instanceNo + 1] = haHigh;
      }
      else
      {
         workHa[r][instanceNo + 0] = haHigh;
         workHa[r][instanceNo + 1] = haLow;
      }
      workHa[r][instanceNo + 2] = haOpen;
      workHa[r][instanceNo + 3] = haClose;

      switch (price)
      {
      case pr_haclose:
         return (haClose);
      case pr_haopen:
         return (haOpen);
      case pr_hahigh:
         return (haHigh);
      case pr_halow:
         return (haLow);
      case pr_hamedian:
         return ((haHigh + haLow) / 2.0);
      case pr_hamedianb:
         return ((haOpen + haClose) / 2.0);
      case pr_hatypical:
         return ((haHigh + haLow + haClose) / 3.0);
      case pr_haweighted:
         return ((haHigh + haLow + haClose + haClose) / 4.0);
      case pr_haaverage:
         return ((haHigh + haLow + haClose + haOpen) / 4.0);
      case pr_hatbiased:
         if (haClose > haOpen)
            return ((haHigh + haClose) / 2.0);
         else
            return ((haLow + haClose) / 2.0);
      }
   }

   switch (price)
   {
   case pr_close:
      return (close[i]);
   case pr_open:
      return (open[i]);
   case pr_high:
      return (high[i]);
   case pr_low:
      return (low[i]);
   case pr_median:
      return ((high[i] + low[i]) / 2.0);
   case pr_medianb:
      return ((open[i] + close[i]) / 2.0);
   case pr_typical:
      return ((high[i] + low[i] + close[i]) / 3.0);
   case pr_weighted:
      return ((high[i] + low[i] + close[i] + close[i]) / 4.0);
   case pr_average:
      return ((high[i] + low[i] + close[i] + open[i]) / 4.0);
   case pr_tbiased:
      if (close[i] > open[i])
         return ((high[i] + close[i]) / 2.0);
      else
         return ((low[i] + close[i]) / 2.0);
   }
   return (0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

string timeFrameToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
}
