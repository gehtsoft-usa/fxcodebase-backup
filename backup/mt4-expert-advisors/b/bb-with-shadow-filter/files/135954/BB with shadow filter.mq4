// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70150

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
#property version   "1.1"

#property strict
#property indicator_chart_window
#property indicator_buffers 10
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

input int K_periods = 7; // Stoch %K
input int D_periods = 3; // Stoch %D
input int Slowing = 3; // Stoch Slowing
input int ob = 80; // Overbought level
input int os = 20; // Oversold level

enum SingalMode
{
   SingalModeLive, // Live
   SingalModeOnBarClose // On bar close
};

enum DisplayType
{
   Arrows, // Arrows
   ArrowsOnMainChart, // Arrows on main chart
   Candles // Candles color
};
input SingalMode signal_mode = SingalModeLive; // Signal mode
input DisplayType Type = Arrows; // Presentation Type
input double shift_arrows_pips = 0.1; // Shift arrows
input color up_color = Blue; // Up color
input color down_color = Red; // Down color

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
      int streamIndex)
      :ACondition(symbol, timeframe)
   {
      _streamIndex = streamIndex;
      _condition = condition;
      _period = period;
      _deviation = deviation;
      _shift = shift;
      _price = price;
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
      double value0 = iBands(_symbol, _timeframe, _period, _deviation, _shift, _price, _streamIndex, period);
      double value1 = iBands(_symbol, _timeframe, _period, _deviation, _shift, _price, _streamIndex, period + 1);
      switch (_condition)
      {
         case FirstAboveSecond:
            return price0 > value0;
         case FirstBelowSecond:
            return price0 < value0;
         case FirstCrossOverSecond:
            return price0 >= value0 && price1 < value1;
         case FirstCrossUnderSecond:
            return price0 <= value0 && price1 > value1;
      }
      return false;
   }
private:
   string GetBBStreamName()
   {
      switch (_streamIndex)
      {
         case MODE_MAIN:
            return "Average";
         case MODE_UPPER:
            return "Upper";
         case MODE_LOWER:
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

// IBarStream v2.1

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

// Bar condnitions v2.2

#ifndef BarConditions_IMP
#define BarConditions_IMP

class BarAscendingCondition : public AConditionBase
{
   IBarStream* _stream;
   int _periodShift;
public:
   BarAscendingCondition(IBarStream* stream)
   {
      _periodShift = 0;
      _stream = stream;
      _stream.AddRef();
   }

   ~BarAscendingCondition()
   {
      _stream.Release();
   }

   void SetPeriodShift(int shift)
   {
      _periodShift = shift;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double open, close;
      return _stream.GetOpenClose(period + _periodShift, open, close) && open < close;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Bar ascending: " + (result ? "true" : "false");
   }
};

class BarDescendingCondition : public AConditionBase
{
   IBarStream* _stream;
   int _periodShift;
public:
   BarDescendingCondition(IBarStream* stream)
   {
      _periodShift = 0;
      _stream = stream;
      _stream.AddRef();
   }

   ~BarDescendingCondition()
   {
      _stream.Release();
   }

   void SetPeriodShift(int shift)
   {
      _periodShift = shift;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double open, close;
      return _stream.GetOpenClose(period + _periodShift, open, close) && open > close;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Bar descending: " + (result ? "true" : "false");
   }
};

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

class StochOSCondition : public ACondition
{
public:
   StochOSCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double stochValue = iStochastic(_symbol, _timeframe, K_periods, D_periods, Slowing, MODE_SMA, 0, MODE_MAIN, period);
      return stochValue < os;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Stoch OS: " + (result ? "true" : "false");
   }
};
class StochOBCondition : public ACondition
{
public:
   StochOBCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double stochValue = iStochastic(_symbol, _timeframe, K_periods, D_periods, Slowing, MODE_SMA, 0, MODE_MAIN, period);
      return stochValue > ob;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Stoch OB: " + (result ? "true" : "false");
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
// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP



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

class PriceStream : public AStream
{
   PriceType _price;
public:
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
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
//Signaler v 1.7
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
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
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
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

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
         AdvancedAlert(advanced_key, message, symbol, timeframe);
   }
};

// Alert signal v3.0
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
public:
   MainChartAlertSignalArrow()
   {
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
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, _color);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, Time[period]);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, CharToStr(_code));
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
public:
   AlertSignal(ICondition* condition, IAction* actionOnCondition, Signaler* signaler, bool onBarClose = false)
   {
      _actionOnCondition = actionOnCondition;
      if (_actionOnCondition != NULL)
      {
         _actionOnCondition.AddRef();
      }
      _signalOutput = NULL;
      _condition = condition;
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
      delete _condition;
   }

   int RegisterArrows(int id, string name, string labelId, int code, color clr, IStream* price)
   {
      _message = name;
      MainChartAlertSignalArrow* signalOutput = new MainChartAlertSignalArrow();
      _signalOutput = signalOutput;
      return signalOutput.Register(id, labelId, (uchar)code, clr, price);
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
      string symbol = _signaler.GetSymbol();
      datetime dt = iTime(symbol, _signaler.GetTimeframe(), _onBarClose ? period + 1 : period);

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
         dt = iTime(symbol, _signaler.GetTimeframe(), 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
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

AlertSignal* conditions[];
Signaler* mainSignaler;
StreamWrapper* customStream;
double bl[], tl[];

int CreateAlert(int id, ICondition* upCondition, IAction* upAction, ICondition* downCondition, IAction* downAction)
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 2);
   conditions[size] = new AlertSignal(upCondition, upAction, mainSignaler, signal_mode == SingalModeOnBarClose);
   conditions[size + 1] = new AlertSignal(downCondition, downAction, mainSignaler, signal_mode == SingalModeOnBarClose);
      
   switch (Type)
   {
      case Arrows:
         {
            id = conditions[size].RegisterStreams(id, "Up", 217, up_color, customStream);
            id = conditions[size + 1].RegisterStreams(id, "Down", 218, down_color, customStream);
         }
         break;
      case ArrowsOnMainChart:
         {
            PriceStream* highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
            highStream.SetShift(shift_arrows_pips);
            PriceStream* lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
            lowStream.SetShift(-shift_arrows_pips);
            id = conditions[size].RegisterArrows(id, "Up", IndicatorObjPrefix + "_up", 217, up_color, highStream);
            id = conditions[size + 1].RegisterArrows(id, "Down", IndicatorObjPrefix + "_down", 218, down_color, lowStream);
            lowStream.Release();
            highStream.Release();
         }
         break;
      case Candles:
         {
            id = conditions[size].RegisterStreams(id, "Up", up_color);
            id = conditions[size + 1].RegisterStreams(id, "Down", down_color);
         }
         break;
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

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorBuffers(8);
   IndicatorObjPrefix = GenerateIndicatorPrefix("bbwsd");
   IndicatorShortName("BB with shadow filter");
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, tl);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, bl);

   int id = 2;
   if (Type == Arrows)
   {
      customStream = new StreamWrapper(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   AndCondition* upCondition = new AndCondition();
   upCondition.Add(new PriceBandsStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, bb_period, bb_deviation, bb_shift, bb_price, MODE_LOWER), false);
   upCondition.Add(new MinBodySizeCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, body_size), false);
   upCondition.Add(new StochOSCondition(_Symbol, (ENUM_TIMEFRAMES)_Period), false);
   AndCondition* downCondition = new AndCondition();
   downCondition.Add(new PriceBandsStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, bb_period, bb_deviation, bb_shift, bb_price, MODE_UPPER), false);
   downCondition.Add(new MinBodySizeCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, body_size), false);
   downCondition.Add(new StochOBCondition(_Symbol, (ENUM_TIMEFRAMES)_Period), false);
   id = CreateAlert(id, upCondition, NULL, downCondition, NULL);
   if (customStream != NULL)
   {
      id = customStream.RegisterInternalStream(id);
   }

   return 0;
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
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars <= 0 || counted_bars > Bars)
   {
      ArrayInitialize(bl, EMPTY_VALUE);
      ArrayInitialize(tl, EMPTY_VALUE);
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
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      tl[pos] = iBands(_Symbol, _Period, bb_period, bb_deviation, bb_shift, bb_price, MODE_UPPER, pos);
      bl[pos] = iBands(_Symbol, _Period, bb_period, bb_deviation, bb_shift, bb_price, MODE_LOWER, pos);
      if (customStream != NULL)
      {
         customStream.SetValue(pos, Close[pos]);
      }
      for (int i = 0; i < ArraySize(conditions); ++i)
      {
         AlertSignal* item = conditions[i];
         item.Update(pos);
      }
   } 
   return 0;
}