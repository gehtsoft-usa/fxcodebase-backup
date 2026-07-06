//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75190

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_label1 "MAVW"
#property indicator_type1 DRAW_COLOR_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "MavWOld"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

#ifndef FloatStream_IMPL
#define FloatStream_IMPL

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

//AOnStream v2.0
class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
   }

   ~AStreamBase()
   {
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
// Float stream v1.1

class FloatStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      int currentSize = ArrayRange(_stream, 0);
      if (currentSize != size) 
      {
         ArrayResize(_stream, size);
         for (int i = currentSize; i < size; ++i)
         {
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif
// WMA on stream v1.1



//AOnStream v2.0
class AOnStream : public AStreamBase
{
protected:
   IStream *_source;
public:
   AOnStream(IStream *source)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
   {
      _source.Release();
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

   bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};
class StreamBuffer
{
public:
   double _data[];

   void EnsureSize(int size)
   {
      int currentSize = ArrayRange(_data, 0);
      if (currentSize != size) 
      {
         ArrayResize(_data, size);
         for (int i = currentSize; i < size; ++i)
         {
            _data[i] = EMPTY_VALUE;
         }
      }
   }
};

class WMAOnStream : public AOnStream
{
   int _length;
   double _k;
   StreamBuffer _buffer;
public:
   WMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 1.0 / (_length);
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      _buffer.EnsureSize(totalBars);
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current[1];
      if (!_source.GetSeriesValues(period, 1, current))
      {
         return false;
      }
      
      double last = _buffer._data[bufferIndex - 1] != EMPTY_VALUE ? _buffer._data[bufferIndex - 1] : current[0];

      _buffer._data[bufferIndex] = (current[0] - last) * _k + last;
      val = _buffer._data[bufferIndex];
      return true;
   }
};
// Pine-script like safe operations
// v1.0

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
double SafePlus(int left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
string SafePlus(string left, string right)
{
   if (left == NULL || right == NULL)
   {
      return NULL;
   }
   return left + right;
}

double SafeMinus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left - right;
}

double SafeDivide(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0)
   {
      return EMPTY_VALUE;
   }
   return left / right;
}

double SafeMultiply(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left * right;
}

bool SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left <= right;
}

double SafeMathExp(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathExp(value);
}

double SafeMathMax(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(left, right);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathPow(double value, double power)
{
   if (value == EMPTY_VALUE || power == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathPow(value, power);
}

double SafeMathAbs(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathAbs(value);
}

double SafeMathRound(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathRound(value);
}

double SafeMathRound(double value, int precision)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return NormalizeDouble(value, precision);
}

double SafeMathSqrt(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSqrt(value);
}

int SafeSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

double SafeLog(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog(value);
}
double SafeLog10(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog10(value);
}
double SafeCos(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathCos(value);
}
double SafeArccos(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArccos(value);
}
double SafeSin(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSin(value);
}
double SafeArcsin(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArcsin(value);
}
double SafeTan(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathTan(value);
}
double SafeArctan(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArctan(value);
}
#define ColorRGB(red, green, blue, transp) red + (green << 8) + (blue << 16)

bool NumberToBool(double number)
{
   return number != EMPTY_VALUE && number != 0;
}

class FirstBarState
{
   bool _first;
public:
   FirstBarState()
   {
      _first = true;
   }
   void Clear()
   {
      _first = true;
   }
   bool IsFirst()
   {
      bool first = _first;
      _first = false;
      return first;
   }
};

color FromGradient(double value, double bottomValue, double topValue, color bottomColor, color topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   return value - bottomValue < topValue - value 
      ? bottomColor
      : topColor;
}
//Signaler v5.0
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   advanced_server          = "https://profitrobots.com"; // Advanced alert server url
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import
#endif

enum SignalerFrequency
{
   SignalsAll,
   SignalsOncePerBarClose,
   SignalsOncePerBar
};

class Signaler
{
   string _prefix;
   SignalerFrequency _frequency;
   datetime _lastSignal;
public:
   Signaler(string frequency)
   {
      if (frequency == "all")
      {
         _frequency = SignalsAll;
      }
      else if (frequency == "once_per_bar_close")
      {
         _frequency = SignalsOncePerBarClose;
      }
      else if (frequency == "once_per_bar")
      {
         _frequency = SignalsOncePerBar;
      }
      _lastSignal = 0;
   }
   Signaler()
   {
      _lastSignal = 0;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void Alert(string message, int position, datetime time)
   {
      if (position != 0)
      {
         return;
      }
      if (_frequency != SignalsAll)
      {
         if (_lastSignal == time)
         {
            return;
         }
      }
      _lastSignal = time;
      SendNotifications("", message);
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

#ifdef ADVANCED_ALERTS
      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
#endif
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
#endif
   }
};

#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL
// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
// Boolean Stream v.1.0

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, bool &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, bool &val[]) = 0;
};

#endif

class ABoolStream : public IBoolStream
{
   int _refs;   
public:
   ABoolStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif
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

//ConditionStreamV2 v1.0

class ConditionStreamV2 : public ABoolStream
{
protected:
   ICondition* _condition;
public:
   ConditionStreamV2(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~ConditionStreamV2()
   {
      _condition.Release();
   }

   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   bool GetValue(const int period, bool &val)
   {
      val = _condition.IsPass(period, 0);
      return true;
   }
   virtual bool GetValues(const int period, const int count, bool &val[])
   {
      if (Size() <= period || period - count + 1 < 0)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = _condition.IsPass(period - i, 0);
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, bool &val[])
   {
      int pos = Size() - period - 1;
      return GetValues(pos, count, val);
   }
};
#endif


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

// Base condition v1.1

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

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

// IBarStream v1.0



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

// Stream-stream condition v2.0

#ifndef StreamStreamCondition_IMP
#define StreamStreamCondition_IMP

class StreamStreamCondition : public ACondition
{
   IStream* _stream1;
   IStream* _stream2;
   int _periodShift1;
   int _periodShift2;
   string _name1;
   string _name2;
   TwoStreamsConditionType _condition;
public:
   StreamStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      TwoStreamsConditionType condition,
      IStream* stream1,
      IStream* stream2,
      string name1,
      string name2,
      int streamPeriodShift1 = 0,
      int streamPeriodShift2 = 0)
      :ACondition(symbol, timeframe)
   {
      _name1 = name1;
      _name2 = name2;
      _stream1 = stream1;
      _stream1.AddRef();
      _stream2 = stream2;
      _stream2.AddRef();
      _condition = condition;
      _periodShift1 = streamPeriodShift1;
      _periodShift2 = streamPeriodShift2;
   }

   ~StreamStreamCondition()
   {
      _stream1.Release();
      _stream2.Release();
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      switch (_condition)
      {
         case FirstAboveSecond:
            return _name1 + " > " + _name2 + ": " + (result ? "true" : "false");
         case FirstBelowSecond:
            return _name1 + " < " + _name2 + ": " + (result ? "true" : "false");
         case FirstCrossOverSecond:
            return _name1 + " co " + _name2 + ": " + (result ? "true" : "false");
         case FirstCrossUnderSecond:
            return _name1 + " cu " + _name2 + ": " + (result ? "true" : "false");
      }
      return _name1 + "-" + _name2 + ": " + (result ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value1[2];
      if (!_stream1.GetValues(period - _periodShift1, 2, value1))
      {
         return false;
      }
      double value2[2];
      if (!_stream2.GetValues(period - _periodShift2, 2, value2))
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return value1[0] > value2[0];
         case FirstBelowSecond:
            return value1[0] < value2[0];
         case FirstCrossOverSecond:
            return value1[0] >= value2[0] && value1[1] < value2[1];
         case FirstCrossUnderSecond:
            return value1[0] <= value2[0] && value1[1] > value2[1];
      }
      return value1[0] >= value2[0] && value1[1] < value2[1];
   }
};
#endif

// Or condition v1.0

// Returns true when at least one of the conditions returns true.

class OrCondition : public AConditionBase
{
   ICondition *_conditions[];
public:
   ~OrCondition()
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
         if (_conditions[i].IsPass(period, date))
            return true;
      }
      return false;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      string messages = "";
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         string logMessage = _conditions[i].GetLogMessage(period, date);
         if (messages != "")
            messages = messages + " or (" + logMessage + ")";
         else
            messages = "(" + logMessage + ")";
      }
      return messages + (IsPass(period, date) ? "=true" : "=false");
   }
};

// v1.0
// Wraps IIntStream and provides IStream

#ifndef IntToFloatStreamWrapper_IMPL
#define IntToFloatStreamWrapper_IMPL
// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL


class AFloatStream : public IStream
{
   int _refs;   
public:
   AFloatStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif
// Integer Stream v.1.0

#ifndef IIntStream_IMPL
#define IIntStream_IMPL

interface IIntStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, int &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
};

#endif

class IntToFloatStreamWrapper : public AFloatStream
{
   IIntStream* _source;
public:
   IntToFloatStreamWrapper(IIntStream* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~IntToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int intVal[];
      ArrayResize(intVal, count);
      if (!_source.GetValues(period, count, intVal))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = intVal[i];
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
};
#endif

//CrossStreamV2 v1.0

class CrossStreamFactory
{
public:
   static IBoolStream* CreateCross(IStream *left, IStream* right)
   {
      OrCondition* or = new OrCondition();
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""), false);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, right, left, "", ""), false);
      ConditionStreamV2* result = new ConditionStreamV2(or);
      or.Release();
      return result;
   }

   static IBoolStream* CreateCrossunder(IStream *left, IStream* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
   static IBoolStream* CreateCrossunder(IStream *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      IBoolStream* condition = CreateCrossunder(left, rightWrapper);
      rightWrapper.Release();
      return condition;
   }

   static IBoolStream* CreateCrossover(IStream *left, IStream* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
   static IBoolStream* CreateCrossover(IIntStream *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* leftWrapper = new IntToFloatStreamWrapper(left);
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      IBoolStream* condition = CreateCrossover(leftWrapper, rightWrapper);
      leftWrapper.Release();
      rightWrapper.Release();
      return condition;
   }
   static IBoolStream* CreateCrossover(IStream *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      IBoolStream* condition = CreateCrossover(left, rightWrapper);
      rightWrapper.Release();
      return condition;
   }
};
#endif
input bool param1 = false; // Show Previous Version of MavilimW?
input int param2 = 3; // First Moving Average length
input int param3 = 5; // Second Moving Average length
input int bars_limit = 1000; // Bars limit
bool mavilimold;
int fmal;
int smal;
FloatStream* wma1Source;
WMAOnStream* wma1;
FloatStream* wma2Source;
WMAOnStream* wma2;
FloatStream* wma3Source;
WMAOnStream* wma3;
FloatStream* wma4Source;
WMAOnStream* wma4;
FloatStream* wma5Source;
WMAOnStream* wma5;
FloatStream* wma6Source;
WMAOnStream* wma6;
double MAVW[];
double plot1[];
double plot_color1[];
int GetPlot1Color(color clr)
{
   if (clr == Blue) { return 0; }
   if (clr == Red) { return 1; }
   if (clr == Yellow) { return 2; }
   return 0;
}
FloatStream* wma7Source;
WMAOnStream* wma7;
FloatStream* wma8Source;
WMAOnStream* wma8;
FloatStream* wma9Source;
WMAOnStream* wma9;
FloatStream* wma10Source;
WMAOnStream* wma10;
FloatStream* wma11Source;
WMAOnStream* wma11;
FloatStream* wma12Source;
WMAOnStream* wma12;
double plot2[];
Signaler* _signaler;
FloatStream* crossover1X;
FloatStream* crossover1Y;
IBoolStream* crossover1;
FloatStream* crossunder1X;
FloatStream* crossunder1Y;
IBoolStream* crossunder1;
FloatStream* cross1X;
FloatStream* cross1Y;
IBoolStream* cross1;

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

void OnInit()
{
   int id = 0;
   mavilimold = param1;
   fmal = param2;
   smal = param3;
   wma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma1 = new WMAOnStream(wma1Source, fmal);
   wma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma2 = new WMAOnStream(wma2Source, smal);
   int tmal = fmal + smal;
   wma3Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma3 = new WMAOnStream(wma3Source, tmal);
   int Fmal = smal + tmal;
   wma4Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma4 = new WMAOnStream(wma4Source, Fmal);
   int Ftmal = tmal + Fmal;
   wma5Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma5 = new WMAOnStream(wma5Source, Ftmal);
   int Smal = Fmal + Ftmal;
   wma6Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma6 = new WMAOnStream(wma6Source, Smal);
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_COLOR_INDEXES, 3);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 0, Blue);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 1, Red);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 2, Yellow);
   id += 1;
   SetIndexBuffer(id++, plot_color1, INDICATOR_COLOR_INDEX);
   wma7Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma7 = new WMAOnStream(wma7Source, 3);
   wma8Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma8 = new WMAOnStream(wma8Source, 5);
   wma9Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma9 = new WMAOnStream(wma9Source, 8);
   wma10Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma10 = new WMAOnStream(wma10Source, 13);
   wma11Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma11 = new WMAOnStream(wma11Source, 21);
   wma12Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   wma12 = new WMAOnStream(wma12Source, 34);
   SetIndexBuffer(id++, plot2, INDICATOR_DATA);
   crossover1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossover1 = CrossStreamFactory::CreateCrossover(crossover1X, crossover1Y);
   crossunder1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   crossunder1 = CrossStreamFactory::CreateCrossunder(crossunder1X, crossunder1Y);
   cross1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1Y = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   cross1 = CrossStreamFactory::CreateCross(cross1X, cross1Y);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "MavilimW");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, MAVW, INDICATOR_CALCULATIONS);
   _signaler = new Signaler();
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   wma1Source.Release();
   wma1.Release();
   wma2Source.Release();
   wma2.Release();
   wma3Source.Release();
   wma3.Release();
   wma4Source.Release();
   wma4.Release();
   wma5Source.Release();
   wma5.Release();
   wma6Source.Release();
   wma6.Release();
   wma7Source.Release();
   wma7.Release();
   wma8Source.Release();
   wma8.Release();
   wma9Source.Release();
   wma9.Release();
   wma10Source.Release();
   wma10.Release();
   wma11Source.Release();
   wma11.Release();
   wma12Source.Release();
   wma12.Release();
   crossover1X.Release();
   crossover1Y.Release();
   crossover1.Release();
   crossunder1X.Release();
   crossunder1Y.Release();
   crossunder1.Release();
   cross1X.Release();
   cross1Y.Release();
   cross1.Release();
   delete _signaler;
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
      wma1Source.Init();
      wma2Source.Init();
      wma3Source.Init();
      wma4Source.Init();
      wma5Source.Init();
      wma6Source.Init();
      ArrayInitialize(MAVW, EMPTY_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot_color1, 0);
      wma7Source.Init();
      wma8Source.Init();
      wma9Source.Init();
      wma10Source.Init();
      wma11Source.Init();
      wma12Source.Init();
      ArrayInitialize(plot2, EMPTY_VALUE);
      crossover1X.Init();
      crossover1Y.Init();
      crossunder1X.Init();
      crossunder1Y.Init();
      cross1X.Init();
      cross1Y.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      int tmal = fmal + smal;
      int Fmal = smal + tmal;
      int Ftmal = tmal + Fmal;
      int Smal = Fmal + Ftmal;
      wma1Source.SetValue(pos, close[pos]);
      double wma1Value[1];
      if (!wma1.GetValues(pos, 1, wma1Value)) { wma1Value[0] = EMPTY_VALUE; }
      double M1 = wma1Value[0];
      wma2Source.SetValue(pos, M1);
      double wma2Value[1];
      if (!wma2.GetValues(pos, 1, wma2Value)) { wma2Value[0] = EMPTY_VALUE; }
      double M2 = wma2Value[0];
      wma3Source.SetValue(pos, M2);
      double wma3Value[1];
      if (!wma3.GetValues(pos, 1, wma3Value)) { wma3Value[0] = EMPTY_VALUE; }
      double M3 = wma3Value[0];
      wma4Source.SetValue(pos, M3);
      double wma4Value[1];
      if (!wma4.GetValues(pos, 1, wma4Value)) { wma4Value[0] = EMPTY_VALUE; }
      double M4 = wma4Value[0];
      wma5Source.SetValue(pos, M4);
      double wma5Value[1];
      if (!wma5.GetValues(pos, 1, wma5Value)) { wma5Value[0] = EMPTY_VALUE; }
      double M5 = wma5Value[0];
      wma6Source.SetValue(pos, M5);
      double wma6Value[1];
      if (!wma6.GetValues(pos, 1, wma6Value)) { wma6Value[0] = EMPTY_VALUE; }
      MAVW[pos] = wma6Value[0];
      if (pos - 1 < 0) { continue; }
      bool col1 = SafeGreater(MAVW[pos], MAVW[pos - 1]);
      if (pos - 1 < 0) { continue; }
      bool col3 = SafeLess(MAVW[pos], MAVW[pos - 1]);
      color colorM = (col1 ? Blue : (col3 ? Red : Yellow));
      plot1[pos] = MAVW[pos];
      plot_color1[pos] = GetPlot1Color(colorM);
      wma7Source.SetValue(pos, close[pos]);
      double wma7Value[1];
      if (!wma7.GetValues(pos, 1, wma7Value)) { wma7Value[0] = EMPTY_VALUE; }
      double M12 = wma7Value[0];
      wma8Source.SetValue(pos, M12);
      double wma8Value[1];
      if (!wma8.GetValues(pos, 1, wma8Value)) { wma8Value[0] = EMPTY_VALUE; }
      double M22 = wma8Value[0];
      wma9Source.SetValue(pos, M22);
      double wma9Value[1];
      if (!wma9.GetValues(pos, 1, wma9Value)) { wma9Value[0] = EMPTY_VALUE; }
      double M32 = wma9Value[0];
      wma10Source.SetValue(pos, M32);
      double wma10Value[1];
      if (!wma10.GetValues(pos, 1, wma10Value)) { wma10Value[0] = EMPTY_VALUE; }
      double M42 = wma10Value[0];
      wma11Source.SetValue(pos, M42);
      double wma11Value[1];
      if (!wma11.GetValues(pos, 1, wma11Value)) { wma11Value[0] = EMPTY_VALUE; }
      double M52 = wma11Value[0];
      wma12Source.SetValue(pos, M52);
      double wma12Value[1];
      if (!wma12.GetValues(pos, 1, wma12Value)) { wma12Value[0] = EMPTY_VALUE; }
      double MAVW2 = wma12Value[0];
      plot2[pos] = (mavilimold && NumberToBool(MAVW2) ? MAVW2 : EMPTY_VALUE);
      if (pos - 1 < 0) { continue; }
      crossover1X.SetValue(pos, MAVW[pos]);
      crossover1Y.SetValue(pos, MAVW[pos - 1]);
      bool crossover1Value[1];
      if (!crossover1.GetValues(pos, 1, crossover1Value)) { crossover1Value[0] = EMPTY_VALUE; }
      if (crossover1Value[0]) { _signaler.SendNotifications("MAVW BUY", "MAVW BUY!"); }
      if (pos - 1 < 0) { continue; }
      crossunder1X.SetValue(pos, MAVW[pos]);
      crossunder1Y.SetValue(pos, MAVW[pos - 1]);
      bool crossunder1Value[1];
      if (!crossunder1.GetValues(pos, 1, crossunder1Value)) { crossunder1Value[0] = EMPTY_VALUE; }
      if (crossunder1Value[0]) { _signaler.SendNotifications("MAVW SELL", "MAVW SELL!"); }
      if (pos - 1 < 0) { continue; }
      cross1X.SetValue(pos, MAVW[pos]);
      cross1Y.SetValue(pos, MAVW[pos - 1]);
      bool cross1Value[1];
      if (!cross1.GetValues(pos, 1, cross1Value)) { cross1Value[0] = EMPTY_VALUE; }
      if (cross1Value[0]) { _signaler.SendNotifications("Color ALARM", "MavilimW has changed color!"); }
   }
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 