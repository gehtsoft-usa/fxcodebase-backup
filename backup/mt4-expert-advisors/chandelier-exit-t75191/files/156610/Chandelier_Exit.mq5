
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75191&p=156610#p156610

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
#property indicator_buffers 19
#property indicator_plots 9
#property indicator_label1 "Long Stop"
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Long Stop Start"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Buy Label"
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Short Stop"
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 2
#property indicator_label5 "Short Stop Start"
#property indicator_type5 DRAW_ARROW
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Sell Label"
#property indicator_type6 DRAW_ARROW
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 ""
#property indicator_type7 DRAW_NONE
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 0
#property indicator_type8 DRAW_FILLING
#property indicator_width8 1
#property indicator_type9 DRAW_FILLING
#property indicator_width9 1

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
// AStream v1.1
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
class AStream : public AStreamBase
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   AStream(string symbol, ENUM_TIMEFRAMES timeframe)
      :AStreamBase()
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   ~AStream()
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
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

//True range stream v1.1

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      if ((_handleNa && period + count > size) || (!_handleNa && period + count + 1 > size))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         if ((period + i + 1 == size) && _handleNa)
         {
            double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
            double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));
            double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i));

            val[i] = MathMax(lc, MathMax(hl, hc));
            continue;
         }
         double hl = MathAbs(iHigh(_symbol, _timeframe, period + i) - iLow(_symbol, _timeframe, period + i));
         double hc = MathAbs(iHigh(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));
         double lc = MathAbs(iLow(_symbol, _timeframe, period + i) - iClose(_symbol, _timeframe, period + i + 1));

         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
   }
};


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
//SMAOnStream v4.0

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double summ = 0;
      for (int i = 0; i < _length; ++i)
      {
         double price[1];
         if (!_source.GetSeriesValues(period + i, 1, price))
            return false;
         summ += price[0];
      }
      val = summ / _length;
      return true;
   }
};

// Average true range stream v3.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   IStream* _avg;
public:
   ATRStream(int length)
      :AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
   {
      IStream* tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      IStream* tr = new TrueRangeStream(symbol, timeframe, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ~ATRStream()
   {
      _avg.Release();
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      return _avg.GetValues(period, count, val);
   }
   
   bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int oldPos = Size() - period - 1;
      return GetValues(oldPos, count, val);
   }

};
#endif
#ifndef FloatStream_IMPL
#define FloatStream_IMPL


// Float stream v1.0

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
      return iBars(_symbol, _timeframe);
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

// Simple price stream v1.0
class SimplePriceStream : public AStream
{
   PriceType _price;
   double _pipSize;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;

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
            case PriceClose:
               val[i] = iClose(_symbol, _timeframe, period + i);
               break;
            case PriceOpen:
               val[i] = iOpen(_symbol, _timeframe, period + i);
               break;
            case PriceHigh:
               val[i] = iHigh(_symbol, _timeframe, period + i);
               break;
            case PriceLow:
               val[i] = iLow(_symbol, _timeframe, period + i);
               break;
            case PriceMedian:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i)) / 2.0;
               break;
            case PriceTypical:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i)) / 3.0;
               break;
            case PriceWeighted:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
               break;
            case PriceMedianBody:
               val[i] = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
               break;
            case PriceAverage:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
               break;
            case PriceTrendBiased:
               {
                  double close = iClose(_symbol, _timeframe, period);
                  if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                     val[i] = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
                  else
                     val[i] = (iLow(_symbol, _timeframe, period) + close) / 2.0;
               }
               break;
            case PriceVolume:
               val[i] = (double)iVolume(_symbol, _timeframe, period);
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


// Highest high stream v1.5

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _loopback = loopback;
      _source.Release();
   }
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      double values[];
      ArrayResize(values, loopback);
      if (!source.GetValues(period, loopback, values))
      {
         return false;
      }
      val = values[0];

      for (int i = 1; i < loopback; ++i)
      {
         val = MathMax(val, values[i]);
      }
      return true;
   }
   
   static bool GetValues(const int period, int count, double &val[], IStream* source, int loopback)
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period - i, v, source, loopback))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int oldPos = Size() - period - 1;
      return HighestHighStream::GetValue(period, val, _source, _loopback);
   }
};




// Lowest low stream v1.5

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _loopback = loopback;
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   static bool GetValue(const int period, double &val, IStream* source, int loopback)
   {
      double values[];
      ArrayResize(values, loopback);
      if (!source.GetValues(period, loopback, values))
      {
         return false;
      }
      val = values[0];

      for (int i = 1; i < loopback; ++i)
      {
         val = MathMin(val, values[i]);
      }
      return true;
   }
   
   static bool GetValues(const int period, int count, double &val[], IStream* source, int loopback)
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period - i, v, source, loopback))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int oldPos = Size() - period - 1;
      return LowestLowStream::GetValue(period, val, _source, _loopback);
   }
};
// Colored fill v1.0

#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   color upColor;
   color dnColor;
   int streamIndex;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void AddColor(color clr)
   {
      dnColor = colorsCount == 0 ? clr : upColor;
      upColor = clr;
      colorsCount++;
   }
   void AddColor(double clr)
   {
      if (clr == EMPTY_VALUE)
      {
         return;
      }
      AddColor((color)clr);
   }
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, upColor); 
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, dnColor);
      return id + 2;
   }
   
   void Set(int period, double value1, double value2, color clr)
   {
      if (clr == EMPTY_VALUE || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
};
#endif
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

input int param1 = 22; // ATR Period
input double param2 = 3.0; // ATR Multiplier
input bool param3 = true; // Use Close Price for Extremums
input bool param4 = true; // Show Buy/Sell Labels
input bool param5 = true; // Highlight State
input bool param6 = true; // Await Bar Confirmation
input int bars_limit = 1000; // Bars limit
string calcGroup;
int length;
double mult;
bool useClose;
string visualGroup;
bool showLabels;
bool highlightState;
string alertGroup;
bool awaitBarConfirmation;
ATRStream* atr1;
FloatStream* highest1Source;
HighestHighStream* highest2;
double longStop[];
FloatStream* lowest1Source;
LowestLowStream* lowest2;
double shortStop[];
double dir[];
double longColor[];
double shortColor[];
double longFillColor[];
double shortFillColor[];
double textColor[];
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
ColoredFill* fill8;
ColoredFill* fill9;
Signaler* _signaler;

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
   length = param1;
   mult = param2;
   useClose = param3;
   showLabels = param4;
   highlightState = param5;
   awaitBarConfirmation = param6;
   atr1 = new ATRStream(length);
   highest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highest2 = new HighestHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, length);
   lowest1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   lowest2 = new LowestLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, length);
   SetIndexBuffer(id, plot1, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Green);
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Green);
   PlotIndexSetInteger(id, PLOT_ARROW, 161);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot3, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Green);
   PlotIndexSetInteger(id, PLOT_ARROW, 241);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot4, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Red);
   SetIndexBuffer(id, plot5, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(id, PLOT_ARROW, 161);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot6, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(id, PLOT_ARROW, 242);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   SetIndexBuffer(id, plot7, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_ARROW, 161);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   fill8 = new ColoredFill(7);
   fill8.AddColor(Green);
   fill8.AddColor(EMPTY_VALUE);
   id = fill8.RegisterStreams(id);
   fill9 = new ColoredFill(8);
   fill9.AddColor(Red);
   fill9.AddColor(EMPTY_VALUE);
   id = fill9.RegisterStreams(id);
   IndicatorObjPrefix = GenerateIndicatorPrefix("CE");
   IndicatorSetString(INDICATOR_SHORTNAME, "Chandelier Exit");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, longStop, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, shortStop, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, dir, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, longColor, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, shortColor, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, longFillColor, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, shortFillColor, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, textColor, INDICATOR_CALCULATIONS);
   _signaler = new Signaler();
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   atr1.Release();
   highest1Source.Release();
   highest2.Release();
   lowest1Source.Release();
   lowest2.Release();
   delete fill8;
   delete fill9;
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
      calcGroup = "Calculation";
      visualGroup = "Visuals";
      alertGroup = "Alerts";
      highest1Source.Init();
      ArrayInitialize(longStop, EMPTY_VALUE);
      lowest1Source.Init();
      ArrayInitialize(shortStop, EMPTY_VALUE);
      ArrayInitialize(dir, 1);
      ArrayInitialize(longColor, Green);
      ArrayInitialize(shortColor, Red);
      ArrayInitialize(longFillColor, Green);
      ArrayInitialize(shortFillColor, Red);
      ArrayInitialize(textColor, White);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      fill8.Init();
      fill9.Init();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      dir[pos] = pos > 0 ? dir[pos - 1] : 1;
      longColor[pos] = pos > 0 ? longColor[pos - 1] : Green;
      shortColor[pos] = pos > 0 ? shortColor[pos - 1] : Red;
      longFillColor[pos] = pos > 0 ? longFillColor[pos - 1] : Green;
      shortFillColor[pos] = pos > 0 ? shortFillColor[pos - 1] : Red;
      textColor[pos] = pos > 0 ? textColor[pos - 1] : White;
      double atr1Value[1];
      if (!atr1.GetValues(pos, 1, atr1Value)) { atr1Value[0] = EMPTY_VALUE; }
      double atr = SafeMultiply(mult, atr1Value[0]);
      highest1Source.SetValue(pos, close[pos]);
      double highest1Value[1];
      if (!HighestHighStream::GetValues(pos, 1, highest1Value, highest1Source, length)) { highest1Value[0] = EMPTY_VALUE; }
      double highest2Value[1];
      if (!highest2.GetValues(pos, 1, highest2Value)) { highest2Value[0] = EMPTY_VALUE; }
      longStop[pos] = SafeMinus(((useClose ? highest1Value[0] : highest2Value[0])), atr);
      if (pos - 1 < 0) { continue; }
      double longStopPrev = Nz(longStop[pos - 1], longStop[pos]);
      if (pos - 1 < 0) { continue; }
      longStop[pos] = (SafeGreater(close[pos - 1], longStopPrev) ? SafeMathMax(longStop[pos], longStopPrev) : longStop[pos]);
      lowest1Source.SetValue(pos, close[pos]);
      double lowest1Value[1];
      if (!LowestLowStream::GetValues(pos, 1, lowest1Value, lowest1Source, length)) { lowest1Value[0] = EMPTY_VALUE; }
      double lowest2Value[1];
      if (!lowest2.GetValues(pos, 1, lowest2Value)) { lowest2Value[0] = EMPTY_VALUE; }
      shortStop[pos] = SafePlus(((useClose ? lowest1Value[0] : lowest2Value[0])), atr);
      if (pos - 1 < 0) { continue; }
      double shortStopPrev = Nz(shortStop[pos - 1], shortStop[pos]);
      if (pos - 1 < 0) { continue; }
      shortStop[pos] = (SafeLess(close[pos - 1], shortStopPrev) ? SafeMathMin(shortStop[pos], shortStopPrev) : shortStop[pos]);
      dir[pos] = (SafeGreater(close[pos], shortStopPrev) ? 1 : (SafeLess(close[pos], longStopPrev) ? (-1) : dir[pos]));
      color plot1_color = longColor[pos];
      if (plot1_color != EMPTY_VALUE) { plot1[pos] = ((dir[pos] == 1) ? longStop[pos] : EMPTY_VALUE); }
      else { plot1[pos] = EMPTY_VALUE; }
      double longStopPlot = plot1[pos];
      if (pos - 1 < 0) { continue; }
      bool buySignal = (dir[pos] == 1) && (dir[pos - 1] == (-1));
      plot2[pos] = (buySignal ? longStop[pos] : EMPTY_VALUE);
      plot3[pos] = (buySignal && showLabels ? longStop[pos] : EMPTY_VALUE);
      color plot4_color = shortColor[pos];
      if (plot4_color != EMPTY_VALUE) { plot4[pos] = ((dir[pos] == 1) ? EMPTY_VALUE : shortStop[pos]); }
      else { plot4[pos] = EMPTY_VALUE; }
      double shortStopPlot = plot4[pos];
      if (pos - 1 < 0) { continue; }
      bool sellSignal = (dir[pos] == (-1)) && (dir[pos - 1] == 1);
      plot5[pos] = (sellSignal ? shortStop[pos] : EMPTY_VALUE);
      plot6[pos] = (sellSignal && showLabels ? shortStop[pos] : EMPTY_VALUE);
      plot7[pos] = SafeDivide((open[pos] + high[pos] + low[pos] + close[pos]), 4);
      double midPricePlot = plot7[pos];
      color longStateFillColor = (highlightState ? ((dir[pos] == 1) ? longFillColor[pos] : EMPTY_VALUE) : EMPTY_VALUE);
      color shortStateFillColor = (highlightState ? ((dir[pos] == (-1)) ? shortFillColor[pos] : EMPTY_VALUE) : EMPTY_VALUE);
      fill8.Set(pos, midPricePlot, longStopPlot, longStateFillColor);
      fill9.Set(pos, midPricePlot, shortStopPlot, shortStateFillColor);
      bool await = (awaitBarConfirmation ? (pos < rates_total - 1) : true);
      if (pos - 1 < 0) { continue; }
      if ((dir[pos] != dir[pos - 1]) && await) { _signaler.SendNotifications("Alert: CE Direction Change", "Chandelier Exit has changed direction!"); }
      if (buySignal && await) { _signaler.SendNotifications("Alert: CE Buy", "Chandelier Exit Buy!"); }
      if (sellSignal && await) { _signaler.SendNotifications("Alert: CE Sell", "Chandelier Exit Sell!"); }
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