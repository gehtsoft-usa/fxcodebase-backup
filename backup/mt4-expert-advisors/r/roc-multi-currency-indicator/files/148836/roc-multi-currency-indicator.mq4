// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=148753

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 16
#property indicator_color1 DeepSkyBlue
#property indicator_color2 DarkOrange
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_color5 Green
#property indicator_color6 Olive
#property indicator_color7 WhiteSmoke
#property indicator_color8 DarkOrchid

//---- Param�tres
input int Periode=14;
input bool show_chart_only = false; // Show chart only currencies
input bool show_eur = true; // Show EUR
input bool show_usd = true; // Show USD
input bool show_jpy = true; // Show JPY
input bool show_gbp = true; // Show GBP
input bool show_chf = true; // Show CHF
input bool show_cad = true; // Show CAD
input bool show_aud = true; // Show AUD
input bool show_nzd = true; // Show NZD

int TotalDevise=8;

//---- buffers
double BufferEUR[];
double BufferUSD[];
double BufferJPY[];
double BufferGBP[];
double BufferCHF[];
double BufferCAD[];
double BufferAUD[];
double BufferNZD[];

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
   Lines, // Lines
   Text // Label
};


input SingalMode signal_mode = SingalModeLive; // Signal mode
input bool filter_consecutive = false; // Filter consecutive alerts
input DisplayType Type = Arrows; // Presentation Type
input double shift_arrows_pips = 0.1; // Shift arrows
input color up_color = Blue; // Up color
input color down_color = Red; // Down color
input int font_size = 12; // Font size
input int bars_limit = 1000; // Bars limit

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
input bool     alertsOn                 = true; // Alerts On:
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
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

// Alert signal v4.3
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

class MainChartAlertSignalText : public IAlertSignalOutput
{
   IStream* _price;
   string _labelId;
   color _color;
   string _text;
   int _fontSize;
   ENUM_ANCHOR_POINT _anchor;
public:
   MainChartAlertSignalText(int fontSize)
   {
      _fontSize = fontSize;
      _price = NULL;
   }

   ~MainChartAlertSignalText()
   {
      if (_price != NULL)
         _price.Release();
   }

   int Register(int id, string labelId, string text, color clr, IStream* price, ENUM_ANCHOR_POINT anchor)
   {
      if (_price != NULL)
         _price.Release();
      _price = price;
      _price.AddRef();
      _labelId = labelId;
      _color = clr;
      _text = text;
      _anchor = anchor;
      
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
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, _fontSize);
         ObjectSetInteger(0, id, OBJPROP_COLOR, _color);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, _anchor);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, Time[period]);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, _text);
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

   int RegisterText(int id, string name, string labelId, string text, color clr, IStream* price, int fontSize, ENUM_ANCHOR_POINT anchor)
   {
      _message = name;
      MainChartAlertSignalText* signalOutput = new MainChartAlertSignalText(fontSize);
      _signalOutput = signalOutput;
      return signalOutput.Register(id, labelId, text, clr, price, anchor);
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

int CreateAlert(int id, ICondition* condition, IAction* action, int code, string codeStr, string message, color clr, PriceType priceType, int sign)
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 1);
   #ifdef ACT_ON_SWITCH
      ActOnSwitchCondition* upSwitch = new ActOnSwitchCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, condition);
      condition = upSwitch;
   #endif
   conditions[size] = new AlertSignal(condition, action, _Symbol, (ENUM_TIMEFRAMES)_Period, mainSignaler, signal_mode == SingalModeOnBarClose);
   #ifdef ACT_ON_SWITCH
      condition.Release();
   #endif
      
   static int lastId = 1;
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
      case Text:
         {
            SimplePriceStream* highStream = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, priceType);
            highStream.SetShift(shift_arrows_pips * sign);
            id = conditions[size].RegisterArrows(id, message, IndicatorObjPrefix + IntegerToString(lastId++), codeStr, clr, highStream, font_size);
            highStream.Release();
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
   id = CreateAlert(id, upCondition, upAction, 217, "Up", "Up " + TimeframeToString(tf), upColor, PriceLow, -1);
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
   id = CreateAlert(id, downCondition, downAction, 218, "Down", "Down " + TimeframeToString(tf), downColor, PriceHigh, 1);
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
      return GetFirst(period) > GetSecond(period);
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
      return GetFirst(period) < GetSecond(period);
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

input int button_x = 20;
input int button_y = 30;

//Visibility controller v1.3
class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};

VisibilityCotroller visibility;

double GetFirst(int period)
{
   if (StringFind(_Symbol, "EUR") == 0) 
   {
      return BufferEUR[period];
   }
   if (StringFind(_Symbol, "USD") == 0) 
   {
      return BufferUSD[period];
   }
   if (StringFind(_Symbol, "JPY") == 0) 
   {
      return BufferJPY[period];
   }
   if (StringFind(_Symbol, "GBP") == 0) 
   {
      return BufferGBP[period];
   }
   if (StringFind(_Symbol, "CHF") == 0) 
   {
      return BufferCHF[period];
   }
   if (StringFind(_Symbol, "CAD") == 0) 
   {
      return BufferCAD[period];
   }
   if (StringFind(_Symbol, "AUD") == 0) 
   {
      return BufferAUD[period];
   }
   if (StringFind(_Symbol, "NZD") == 0) 
   {
      return BufferNZD[period];
   }
   return 0;
}
double GetSecond(int period)
{
   if (StringFind(_Symbol, "EUR") > 0) 
   {
      return BufferEUR[period];
   }
   if (StringFind(_Symbol, "USD") > 0) 
   {
      return BufferUSD[period];
   }
   if (StringFind(_Symbol, "JPY") > 0) 
   {
      return BufferJPY[period];
   }
   if (StringFind(_Symbol, "GBP") > 0) 
   {
      return BufferGBP[period];
   }
   if (StringFind(_Symbol, "CHF") > 0) 
   {
      return BufferCHF[period];
   }
   if (StringFind(_Symbol, "CAD") > 0) 
   {
      return BufferCAD[period];
   }
   if (StringFind(_Symbol, "AUD") > 0) 
   {
      return BufferAUD[period];
   }
   if (StringFind(_Symbol, "NZD") > 0) 
   {
      return BufferNZD[period];
   }
   return 0;
}

bool ShowEUR()
{
   if (show_chart_only)
   {
      return StringFind(_Symbol, "EUR") >= 0;
   }
   return show_eur;
}
bool ShowUSD()
{
   if (show_chart_only)
   {
      return StringFind(_Symbol, "USD") >= 0;
   }
   return show_usd;
}
bool ShowJPY()
{
   if (show_chart_only)
   {
      return StringFind(_Symbol, "JPY") >= 0;
   }
   return show_jpy;
}
bool ShowGBP()
{
   if (show_chart_only)
   {
      return StringFind(_Symbol, "GBP") >= 0;
   }
   return show_gbp;
}
bool ShowCHF()
{
   if (show_chart_only)
   {
      return StringFind(_Symbol, "CHF") >= 0;
   }
   return show_chf;
}
bool ShowCAD()
{
   if (show_chart_only)
   {
      return StringFind(_Symbol, "CAD") >= 0;
   }
   return show_cad;
}
bool ShowAUD()
{
   if (show_chart_only)
   {
      return StringFind(_Symbol, "AUD") >= 0;
   }
   return show_aud;
}
bool ShowNZD()
{
   if (show_chart_only)
   {
      return StringFind(_Symbol, "NZD") >= 0;
   }
   return show_nzd;
}

//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
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

   IndicatorObjPrefix = GenerateIndicatorPrefix("roc");
   IndicatorBuffers(16);

   string short_name;
   short_name="ROC-";
   IndicatorShortName(short_name);
   IndicatorDigits(0);
     
   SetIndexStyle(0, ShowEUR() ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(0,BufferEUR);
   SetIndexDrawBegin(0,0);
   
   SetIndexStyle(1, ShowUSD() ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(1,BufferUSD);
   SetIndexDrawBegin(1,0);

   SetIndexStyle(2, ShowJPY() ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(2,BufferJPY);
   SetIndexDrawBegin(2,0);

   SetIndexStyle(3, ShowGBP() ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(3,BufferGBP);
   SetIndexDrawBegin(3,0);
   
   SetIndexStyle(4, ShowCHF() ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(4,BufferCHF);
   SetIndexDrawBegin(4,0);
   
   SetIndexStyle(5, ShowCAD() ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(5,BufferCAD);
   SetIndexDrawBegin(5,0);
   
   SetIndexStyle(6, ShowAUD() ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(6,BufferAUD);
   SetIndexDrawBegin(6,0);
   
   SetIndexStyle(7, ShowNZD() ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(7,BufferNZD);
   SetIndexDrawBegin(7,0);
   
   SetLevelStyle(STYLE_SOLID,1,Silver);
   SetLevelValue(0,0);

	visibility.Init("show_hide_roc", "ROC", "Show/Hide", button_x, button_y);
   
   return(0);
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
   visibility.DeInit();
   return(0);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      start();
   }
}

//+------------------------------------------------------------------+
//|  Main fonction                                                   |
//+------------------------------------------------------------------+
int start()
{
   int limit,i,counted_bars=IndicatorCounted();
   visibility.HandleButtonClicks();
   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         counted_bars = 0;
      }
      else
      {
         ArrayInitialize(BufferEUR, EMPTY_VALUE);
         ArrayInitialize(BufferUSD, EMPTY_VALUE);
         ArrayInitialize(BufferJPY, EMPTY_VALUE);
         ArrayInitialize(BufferGBP, EMPTY_VALUE);
         ArrayInitialize(BufferCHF, EMPTY_VALUE);
         ArrayInitialize(BufferCAD, EMPTY_VALUE);
         ArrayInitialize(BufferAUD, EMPTY_VALUE);
         ArrayInitialize(BufferNZD, EMPTY_VALUE);

         ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
         visibility.ResetRecalc();
         return 0;
      }
      visibility.ResetRecalc();
   }

   int mEURUSD;
   int mEURJPY;
   int mUSDJPY;
   int mGBPUSD;
   int mEURGBP;
   int mGBPJPY;
   int mGBPCHF;
   int mCHFJPY;
   int mEURCHF;
   int mUSDCHF;
   int mAUDNZD;
   
   int mNZDCAD;
   int mCHFCAD;
   int mAUDCAD;
   
   int mNZDCHF;
   int mAUDCHF;
   int mCADCHF;
   
   int mGBPNZD;
   int mGBPAUD;
   int mGBPCAD;
   
   int mNZDJPY;
   int mAUDJPY;
   int mCADJPY;  
   
   int mEURCAD;
   int mEURAUD;
   int mEURNZD; 
   
   int mUSDCAD;
   int mAUDUSD;
   int mNZDUSD;
      
   int TotalWindow=WindowsTotal();

   if (ObjectFind(IndicatorObjPrefix + "EUR") < 0 && ShowEUR())
   {
      ObjectCreate(IndicatorObjPrefix + "EUR",OBJ_LABEL,TotalWindow-1,0,0);
      ObjectSet(IndicatorObjPrefix + "EUR",OBJPROP_XDISTANCE,150);
      ObjectSet(IndicatorObjPrefix + "EUR",OBJPROP_YDISTANCE,1);
      ObjectSetText(IndicatorObjPrefix + "EUR","EUR",12,"Arial",indicator_color1);
   }
   if (ObjectFind(IndicatorObjPrefix + "USD")<0 && ShowUSD())
   {
      ObjectCreate(IndicatorObjPrefix + "USD",OBJ_LABEL,TotalWindow-1,0,0);
      ObjectSet(IndicatorObjPrefix + "USD",OBJPROP_XDISTANCE,200);
      ObjectSet(IndicatorObjPrefix + "USD",OBJPROP_YDISTANCE,1);
      ObjectSetText(IndicatorObjPrefix + "USD","USD",12,"Arial",indicator_color2);
   }
   if (ObjectFind(IndicatorObjPrefix + "JPY")<0 && ShowJPY())
   {
      ObjectCreate(IndicatorObjPrefix + "JPY",OBJ_LABEL,TotalWindow-1,0,0);
      ObjectSet(IndicatorObjPrefix + "JPY",OBJPROP_XDISTANCE,250);
      ObjectSet(IndicatorObjPrefix + "JPY",OBJPROP_YDISTANCE,1);
      ObjectSetText(IndicatorObjPrefix + "JPY","JPY",12,"Arial",indicator_color3);
   }
   if (ObjectFind(IndicatorObjPrefix + "GBP")<0 && ShowGBP())
   {
      ObjectCreate(IndicatorObjPrefix + "GBP",OBJ_LABEL,TotalWindow-1,0,0);
      ObjectSet(IndicatorObjPrefix + "GBP",OBJPROP_XDISTANCE,300);
      ObjectSet(IndicatorObjPrefix + "GBP",OBJPROP_YDISTANCE,1);
      ObjectSetText(IndicatorObjPrefix + "GBP","GBP",12,"Arial",indicator_color4);
   }
   if (ObjectFind(IndicatorObjPrefix + "CHF")<0 && ShowCHF())
   {
      ObjectCreate(IndicatorObjPrefix + "CHF",OBJ_LABEL,TotalWindow-1,0,0);
      ObjectSet(IndicatorObjPrefix + "CHF",OBJPROP_XDISTANCE,350);
      ObjectSet(IndicatorObjPrefix + "CHF",OBJPROP_YDISTANCE,1);
      ObjectSetText(IndicatorObjPrefix + "CHF","CHF",12,"Arial",indicator_color5);
   }
   if (ObjectFind(IndicatorObjPrefix + "CAD")<0 && ShowCAD())
   {
      ObjectCreate(IndicatorObjPrefix + "CAD",OBJ_LABEL,TotalWindow-1,0,0);
      ObjectSet(IndicatorObjPrefix + "CAD",OBJPROP_XDISTANCE,400);
      ObjectSet(IndicatorObjPrefix + "CAD",OBJPROP_YDISTANCE,1);
      ObjectSetText(IndicatorObjPrefix + "CAD","CAD",12,"Arial",indicator_color6);
   }
   if (ObjectFind(IndicatorObjPrefix + "AUD")<0 && ShowAUD())
   {
      ObjectCreate(IndicatorObjPrefix + "AUD",OBJ_LABEL,TotalWindow-1,0,0);
      ObjectSet(IndicatorObjPrefix + "AUD",OBJPROP_XDISTANCE,450);
      ObjectSet(IndicatorObjPrefix + "AUD",OBJPROP_YDISTANCE,1);
      ObjectSetText(IndicatorObjPrefix + "AUD","AUD",12,"Arial",indicator_color7);	 
   }
   if (ObjectFind(IndicatorObjPrefix + "NZD")<0 && ShowNZD())
   {
      ObjectCreate(IndicatorObjPrefix + "NZD",OBJ_LABEL,TotalWindow-1,0,0);
      ObjectSet(IndicatorObjPrefix + "NZD",OBJPROP_XDISTANCE,500);
      ObjectSet(IndicatorObjPrefix + "NZD",OBJPROP_YDISTANCE,1);
      ObjectSetText(IndicatorObjPrefix + "NZD","NZD",12,"Arial",indicator_color8);	 
   }

   if(Bars<=Periode+1) return(0);
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
	
	if(counted_bars == 0) limit = Bars;
	if(counted_bars > 0)	limit = Bars - counted_bars;
	
   int toSkip = 2;
   for (int i = MathMin(bars_limit, Bars - 1 - MathMax(counted_bars - 1, toSkip)); i >= 0 && !IsStopped(); --i)
   {
      mEURUSD= NormalizeDouble((iClose("EURUSD",0,i)-iClose("EURUSD",0,i+Periode))/0.0001,0);  
      mEURJPY= NormalizeDouble((iClose("EURJPY",0,i)-iClose("EURJPY",0,i+Periode))/0.01,0);  
      mUSDJPY= NormalizeDouble((iClose("USDJPY",0,i)-iClose("USDJPY",0,i+Periode))/0.01,0);  
      mCHFJPY= NormalizeDouble((iClose("USDJPY",0,i)-iClose("USDJPY",0,i+Periode))/0.01,0);
      mUSDCHF= NormalizeDouble((iClose("USDCHF",0,i)-iClose("USDCHF",0,i+Periode))/0.0001,0); 
      
      mGBPJPY= NormalizeDouble((iClose("GBPJPY",0,i)-iClose("GBPJPY",0,i+Periode))/0.01,0);  
      mEURGBP= NormalizeDouble((iClose("EURGBP",0,i)-iClose("EURGBP",0,i+Periode))/0.0001,0);  
      mGBPUSD= NormalizeDouble((iClose("GBPUSD",0,i)-iClose("GBPUSD",0,i+Periode))/0.0001,0);
      mGBPCHF= NormalizeDouble((iClose("GBPCHF",0,i)-iClose("GBPCHF",0,i+Periode))/0.0001,0); 
      mEURCHF= NormalizeDouble((iClose("EURCHF",0,i)-iClose("EURCHF",0,i+Periode))/0.0001,0); 
      mEURCAD= NormalizeDouble((iClose("EURCAD",0,i)-iClose("EURCAD",0,i+Periode))/0.0001,0); 
      mEURAUD= NormalizeDouble((iClose("EURAUD",0,i)-iClose("EURAUD",0,i+Periode))/0.0001,0); 
      mEURNZD= NormalizeDouble((iClose("EURNZD",0,i)-iClose("EURNZD",0,i+Periode))/0.0001,0); 

      mUSDCAD= NormalizeDouble((iClose("USDCAD",0,i)-iClose("USDCAD",0,i+Periode))/0.0001,0); 
      mAUDUSD= NormalizeDouble((iClose("AUDUSD",0,i)-iClose("AUDUSD",0,i+Periode))/0.0001,0); 
      mNZDUSD = NormalizeDouble((iClose("NZDUSD",0,i)-iClose("NZDUSD",0,i+Periode))/0.0001,0); 


      mCADJPY= NormalizeDouble((iClose("CADJPY",0,i)-iClose("CADJPY",0,i+Periode))/0.01,0);  
      mAUDJPY= NormalizeDouble((iClose("AUDJPY",0,i)-iClose("AUDJPY",0,i+Periode))/0.01,0);  
      mNZDJPY= NormalizeDouble((iClose("NZDJPY",0,i)-iClose("NZDJPY",0,i+Periode))/0.01,0);  
      
      mGBPCAD= NormalizeDouble((iClose("GBPCAD",0,i)-iClose("GBPCAD",0,i+Periode))/0.0001,0);  
      mGBPAUD= NormalizeDouble((iClose("GBPAUD",0,i)-iClose("GBPAUD",0,i+Periode))/0.0001,0);  
      mGBPNZD= NormalizeDouble((iClose("GBPNZD",0,i)-iClose("GBPNZD",0,i+Periode))/0.0001,0);  

      mCADCHF= NormalizeDouble((iClose("CADCHF",0,i)-iClose("CADCHF",0,i+Periode))/0.0001,0);  
      mAUDCHF= NormalizeDouble((iClose("AUDCHF",0,i)-iClose("AUDCHF",0,i+Periode))/0.0001,0);  
      mNZDCHF= NormalizeDouble((iClose("NZDCHF",0,i)-iClose("NZDCHF",0,i+Periode))/0.0001,0); 
      
      mAUDCAD= NormalizeDouble((iClose("AUDCAD",0,i)-iClose("AUDCAD",0,i+Periode))/0.0001,0); 
      mCHFCAD= NormalizeDouble((iClose("CHFCAD",0,i)-iClose("CHFCAD",0,i+Periode))/0.0001,0); 	 
      mNZDCAD= NormalizeDouble((iClose("NZDCAD",0,i)-iClose("NZDCAD",0,i+Periode))/0.0001,0); 
      
      mAUDNZD= NormalizeDouble((iClose("AUDNZD",0,i)-iClose("AUDNZD",0,i+Periode))/0.0001,0); 
   
      BufferEUR[i]=(BufferEUR[i+1]+BufferEUR[i+2]+((mEURUSD+mEURJPY+mEURGBP+mEURCHF+mEURCAD+mEURAUD+mEURNZD)/(TotalDevise-1)))/7;
      BufferUSD[i]=(BufferUSD[i+1]+BufferUSD[i+2]+((mUSDJPY-mEURUSD-mGBPUSD+mUSDCHF+mUSDCAD- mAUDUSD - mNZDUSD   )/(TotalDevise-1)))/7;
      BufferJPY[i]=(BufferJPY[i+1]+BufferJPY[i+2]+((mEURJPY-mUSDJPY-mGBPJPY-mCHFJPY-mCADJPY-mAUDJPY -mNZDJPY)/(TotalDevise-1)))/7;  
      BufferGBP[i]=(BufferGBP[i+1]+BufferGBP[i+2]+((mEURGBP+mGBPJPY+mGBPUSD+mGBPCHF+mGBPCAD+mGBPAUD  +mGBPNZD  )/(TotalDevise-1)))/7; 
      BufferCHF[i]=(BufferCHF[i+1]+BufferCHF[i+2]+((mCHFJPY-mGBPCHF-mUSDCHF-mEURCHF+mCADCHF-mAUDCHF  +mNZDCHF)/(TotalDevise-1)))/7; 
      BufferCAD[i]=(BufferCAD[i+1]+BufferCAD[i+2]+((mCADJPY-mGBPCAD-mUSDCAD-mEURCAD-mAUDCAD  -mNZDCAD-mCHFCAD)/(TotalDevise-1)))/7;
      BufferAUD[i]=(BufferAUD[i+1]+BufferAUD[i+2]+((mAUDJPY-mGBPAUD   -mEURAUD + mAUDUSD + mAUDCHF - mNZDCAD +mAUDCAD )/(TotalDevise-1)))/7;
      
      BufferNZD[i]=(BufferNZD[i+1]+BufferNZD[i+2]+((mNZDUSD -mEURNZD-mGBPNZD+ mNZDJPY+  mNZDCHF +mNZDCAD - mAUDNZD)/(TotalDevise-1)))/7;

      if (customStream != NULL)
      {
         customStream.SetValue(i, Close[i]);
      }
      if (current_signal_date < Time[i] && current_signal_side != 0)
      {
         last_signal_side = current_signal_side;
         current_signal_date = Time[signal_mode == SingalModeOnBarClose ? i + 1 : i];
      }
      current_signal_side = 0;
      
			if(alertsOn)
			for (int ii = 0; ii < ArraySize(conditions); ++ii)
      {
         AlertSignal* item = conditions[ii];
         item.Update(i);
      }
   }
   return(0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+