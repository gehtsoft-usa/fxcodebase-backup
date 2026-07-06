// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=159185#p159185

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 3
#property indicator_label1 "Follow Line"
#property indicator_type1 DRAW_COLOR_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

// Pine-script like safe operations
// v1.2

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

double SafeMathMax(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(MathMax(param1, param2), param3);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathMin(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(MathMin(param1, param2), param3);
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
double InvertSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return -value;
}
#define ColorRGB(red, green, blue, transp) (uint)((red) + ((green) << 8) + ((blue) << 16) + ((uint)(transp * 2.55) << 24))
#define ColorR(clr) ((clr & 0x00FF0000) >> 16)
#define ColorG(clr) ((clr & 0x0000FF00) >> 8)
#define ColorB(clr) (clr & 0x000000FF)
#define GetColorOnly(clr) (clr & 0xFFFFFF)
#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)
#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

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

uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   double range = topValue - bottomValue;
   double rate = (value - bottomValue) / range;
   if (rate > 1)
   {
      return bottomColor;
   }
   if (rate < 0)
   {
      return topColor;
   }
   uint bottomR = ColorR(bottomColor);
   uint bottomG = ColorG(bottomColor);
   uint bottomB = ColorB(bottomColor);
   uint topR = ColorR(topColor);
   uint topG = ColorG(topColor);
   uint topB = ColorB(topColor);
   return ColorRGB(bottomR + int(rate * (topR - bottomR)), bottomG + int(rate * (topG - bottomG)), bottomB + int(rate * (topB - bottomB)), 0);
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

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

// Colored plor v1.0


class ColoredPlot
{
   int plotIndex;
   double values[];
   double colors[];
   double buffer[];
   
   uint initColors[];
   int offset;
public:
   ColoredPlot(int plotIndex)
   {
      this.plotIndex = plotIndex;
      offset = INT_MIN;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      int colorsCount = ArraySize(initColors);
      ArrayResize(initColors, colorsCount + 1);
      initColors[colorsCount] = GetColorOnly(clr);
   }
   
   void SetOffset(int offset)
   {
      this.offset = offset;
   }
   
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, values, INDICATOR_DATA);
      int colorsCount = ArraySize(initColors);
      PlotIndexSetInteger(plotIndex, PLOT_COLOR_INDEXES, colorsCount);
      for (int i = 0; i < colorsCount; ++i)
      {
         PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, i, initColors[i]);
      }
      if (offset != INT_MIN)
      {
         PlotIndexSetInteger(plotIndex, PLOT_SHIFT, offset);
      }
      id += 1;
      SetIndexBuffer(id++, colors, INDICATOR_COLOR_INDEX);
      return id;
   }
   int RegisterInternalStreams(int id)
   {
      SetIndexBuffer(id++, buffer, INDICATOR_CALCULATIONS);
      return id;
   }
   
   void Init()
   {
      ArrayInitialize(values, EMPTY_VALUE);
      ArrayInitialize(colors, EMPTY_VALUE);
      ArrayInitialize(buffer, EMPTY_VALUE);
   }
   
   double Set(int pos, double value, uint clr)
   {
      int transp = GetTranparency(clr);
      buffer[pos] = value;
      values[pos] = value;
      colors[pos] = FindColorIndex(clr);
      if (value == EMPTY_VALUE)
      {
         values[pos] = EMPTY_VALUE;
         colors[pos] = EMPTY_VALUE;
         buffer[pos] = EMPTY_VALUE;
         return EMPTY_VALUE;
      }
      int prevValueIndex = FindPrevValueIndex(pos);
      if (prevValueIndex == -1)
      {
         return EMPTY_VALUE;
      }
      int length = pos - prevValueIndex + 1;
      if (colors[pos] == -1)
      {
         for (int i = 1; i < length; ++i)
         {
            values[prevValueIndex + i] = EMPTY_VALUE;
            colors[prevValueIndex + i] = EMPTY_VALUE;
         }
         return EMPTY_VALUE;
      }
      double diff = buffer[pos] - buffer[prevValueIndex];
      double step = diff / (length - 1);
      for (int i = 0; i < length; ++i)
      {
         values[prevValueIndex + i] = buffer[prevValueIndex] + step * i;
         colors[prevValueIndex + i] = colors[pos];
      }
      return value;
   }
private:
   int FindPrevValueIndex(int pos)
   {
      for (int i = pos - 1; i >= 0; --i)
      {
         if (buffer[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return -1;
   }
   int FindColorIndex(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return -1;
      }
      color searchingColor = GetColorOnly(clr);
      int colorsCount = ArraySize(initColors);
      for (int i = 0; i < colorsCount; ++i)
      {
         if (initColors[i] == searchingColor)
         {
            return i;
         }
      }
      return -1;
   }
};
enum MATypes
{
   ma_sma,     // Simple moving average - SMA
   ma_ema,     // Exponential moving average - EMA
   //ma_dsema,   // Double smoothed exponential moving average - DSEMA
   ma_dema,    // Double exponential moving average - DEMA
   ma_tema,    // Tripple exponential moving average - TEMA
   //ma_smma,    // Smoothed moving average - SMMA
   //ma_lwma,    // Linear weighted moving average - LWMA
   //ma_pwma,    // Parabolic weighted moving average - PWMA
   //ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // Volume weighted moving average - VWMA
   ma_hull,    // Hull moving average
   ma_rma,       // RMA
   //ma_tma,     // Triangular moving average
   //ma_sine,    // Sine weighted moving average
   ma_linr,    // Linear regression value
   //ma_ie2,     // IE/2
   //ma_nlma,    // Non lag moving average
   //ma_zlma,    // Zero lag moving average
   //ma_lead,    // Leader exponential moving average
   //ma_ssm,     // Super smoother
   //ma_smoo     // Smoother
};
input int param1 = 5; // ATR Period
input MATypes avg_type = ma_sma; // Averages type
input int param2 = 21; // Bollinger Bands Period
input double param3 = 1.00; // Bollinger Bands Deviation
input bool param4 = true; // ATR Filter On/Off
input bool param5 = true; // Show Signals 
input int bars_limit = 1000; // Bars limit
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

#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v2.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL
// Date/time Stream v.1.0

#ifndef TIStream_IMPL
#define TIStream_IMPL

template <typename T>
interface TIStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, T &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, T &val[]) = 0;
};

#endif

class AFloatStream : public TIStream<double>
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
// Float stream v2.0

class FloatStream : public AFloatStream
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


//AOnStream v3.0
class AStreamBase : public TIStream<double>
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

//AOnStream v3.0
class AOnStream : public AStreamBase
{
protected:
   TIStream<double> *_source;
public:
   AOnStream(TIStream<double> *source)
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

// StDev stream v2.0

class StDevStream : public AOnStream
{
   int _period;
public:
   StDevStream(TIStream<double>* __source, int period)
      :AOnStream(__source)
   {
      _period = period;
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      double sum = 0;
      double ssum = 0;
      double __data[];
      ArrayResize(__data, _period);
      if (!_source.GetSeriesValues(period, _period, __data))
      {
         return false;
      }
      for (int i = 0; i < _period; i++)
      {
         sum += __data[i];
         ssum += MathPow(__data[i], 2);
      }
      val = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
      return true;
   }
};

// AStream v1.1

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

//SMAOnStream v5.0
#ifndef SmaOnStream_IMPL
#define SmaOnStream_IMPL

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(TIStream<double> *source, const int length)
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
#endif

// Average true range stream v4.0

#ifndef ATRStream_IMP
#define ATRStream_IMP

class ATRStream : public AStream
{
   TIStream<double>* _avg;
public:
   ATRStream(int length)
      :AStream(_Symbol, (ENUM_TIMEFRAMES)_Period)
   {
      TIStream<double>* tr = new TrueRangeStream(_Symbol, (ENUM_TIMEFRAMES)_Period, true);
      _avg = new SmaOnStream(tr, length);
      tr.Release();
   }
   ATRStream(const string symbol, ENUM_TIMEFRAMES timeframe, int length)
      :AStream(symbol, timeframe)
   {
      TIStream<double>* tr = new TrueRangeStream(symbol, timeframe, true);
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

//SMAOnStream v5.0
#ifndef SmaOnStream_IMPL
#define SmaOnStream_IMPL

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(TIStream<double> *source, const int length)
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
#endif

// TemaOnStream v3.0

class TemaOnStream : public AOnStream
{
   double _alpha;
   double _buffer1[];
   double _buffer2[];
   double _buffer3[];
public:
   TemaOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _alpha = 2.0 / (1.0 + length);
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
         return false;

      int size = Size();
      if (ArrayRange(_buffer1, 0) < size) 
         ArrayResize(_buffer1, size);
      if (ArrayRange(_buffer2, 0) < size) 
         ArrayResize(_buffer2, size);
      if (ArrayRange(_buffer3, 0) < size) 
         ArrayResize(_buffer3, size);

      _buffer1[size - 1 - period] = _buffer1[size - 1 - period - 1] + _alpha * (price[0] - _buffer1[size - 1 - period - 1]);
      _buffer2[size - 1 - period] = _buffer2[size - 1 - period - 1] + _alpha * (_buffer1[size - 1 - period] - _buffer2[size - 1 - period - 1]);
      _buffer3[size - 1 - period] = _buffer3[size - 1 - period - 1] + _alpha * (_buffer2[size - 1 - period] - _buffer3[size - 1 - period - 1]);
      val = (_buffer3[size - 1 - period] + 3.0 * (_buffer1[size - 1 - period] - _buffer2[size - 1 - period]));
      return true;
   }
};


#ifndef PriceType_IMPL
#define PriceType_IMPL
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
#endif

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
#ifndef PriceType_IMPL
#define PriceType_IMPL
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
#endif
// VwmaOnStream v3.0
class VwmaOnStream : public AOnStream
{
   TIStream<double> *_volumeSource;
   int _length;
public:
   VwmaOnStream(TIStream<double> *source, TIStream<double> *volumeSource, const int length)
      :AOnStream(source)
   {
      _volumeSource = volumeSource;
      _volumeSource.AddRef();
      _length = length;
   }

   VwmaOnStream(string symbol, ENUM_TIMEFRAMES timeframe, TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _volumeSource = new SimplePriceStream(symbol, timeframe, PriceVolume);
      _length = length;
   }

   ~VwmaOnStream()
   {
      _volumeSource.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double price[1];
      double volume[1];
      double sumw = 0;
      double sum = 0;
      for (int k = 0; k < _length; k++)
      {
         if (!_source.GetSeriesValues(period + k, 1, price) || !_volumeSource.GetSeriesValues(period + k, 1, volume))
            return false;
         sumw += volume[0];
         sum += volume[0] * price[0];
      }
      val = sum / sumw;
      return true;
   }
};

// CustomStream v2.0

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

class CustomStream : public AStreamBase
{
   StreamBuffer _data;
   TIStream<double> *_source;
public:
   CustomStream(TIStream<double>* base)
   {
      _source = base;
      _source.AddRef();
   }
   ~CustomStream()
   {
      _source.Release();
   }

   virtual int Size()
   {
      return _source.Size();
   }

   virtual void SetValue(int period, double value)
   {
      _data.EnsureSize(Size());
      _data._data[period] = value;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      _data.EnsureSize(size);
      for (int i = 0; i < count; ++i)
      {
         double value = _data._data[size - 1 - period + i];
         if (value == EMPTY_VALUE)
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      _data.EnsureSize(Size());
      int bars = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};


//RmaOnStream v3.0
class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
         return false;

      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != size) 
      {
         ArrayResize(_buffer, size);
         for (int i = currentBufferSize; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double alpha = 1.0 / _length;
      int index = size - 1 - period;
      if (index == 0 || _buffer[index - 1] == EMPTY_VALUE)
      {
         _buffer[index] = price[0];
      }
      else
      {
         _buffer[index] = alpha * price[0] + (1 - alpha) * _buffer[index - 1];
      }
      val = _buffer[index];
      return true;
   }
};


// HullOnStream v3.1
class HullOnStream : public AOnStream
{
   int _length;
   CustomStream* _buffer;
   TIStream<double>* _half;
   TIStream<double>* _full;
   TIStream<double>* _hull;
public:
   HullOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _source = source;
      _half = new RmaOnStream(source, (int)MathFloor(length / 2));
      _full = new RmaOnStream(source, length);
      _buffer = new CustomStream(source);
      _hull = new RmaOnStream(_buffer, (int)MathFloor(MathSqrt(length)));
   }

   ~HullOnStream()
   {
      _hull.Release();
      _buffer.Release();
      _half.Release();
      _full.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double half[1];
      double full[1];
      if (!_half.GetSeriesValues(period, 1, half) || !_full.GetSeriesValues(period, 1, full))
         return false;
      
      _buffer.SetValue(period, half[0] * 2 - full[0]);
      double res[1];
      if (!_hull.GetSeriesValues(period, 1, res))
         return false;
      val = res[0];
      return true;
   }
};





// DEMAOnStream v2.1
class DEMAOnStream : public AOnStream
{
   double _alpha;
   CustomStream* _buffer;
   CustomStream* _buffer2;
public:
   DEMAOnStream(TIStream<double>* source, const int length)
      :AOnStream(source)
   {
      _alpha = 2.0 / (1.0 + length);
      _source = source;
      _buffer = new CustomStream(source);
      _buffer2 = new CustomStream(source);
   }

   ~DEMAOnStream()
   {
      _buffer.Release();
      _buffer2.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      
      double prices[1];
      if (!_source.GetSeriesValues(period, 1, prices))
      {
         return false;
      }

      double buffer_prev[1];
      if (!_buffer.GetSeriesValues(period - 1, 1, buffer_prev))
      {
         return false;
      }

      double val1 = buffer_prev[0] + _alpha * (prices[0] - buffer_prev[0]);
      _buffer.SetValue(period, val1);

      double buffer2_prev[1];
      if (!_buffer2.GetSeriesValues(period - 1, 1, buffer2_prev))
      {
         return false;
      }

      double val2 = buffer2_prev[0] + _alpha * (val1 - buffer_prev[0]);
      _buffer2.SetValue(period, val2);
      val = val1 * 2.0 - val2;
      return true;
   }
};

//LinearRegressionOnStream v2.0

class LinearRegressionOnStream : public AOnStream
{
   int _length;
   double _buffer[];
   int _offset;
public:
   LinearRegressionOnStream(TIStream<double> *source, const int length, int offset = 0)
      :AOnStream(source)
   {
      _offset = offset;
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period - _offset < 0)
      {
         return false;
      }
      int size = Size();
      int index = size - 1 - period;
      int range = ArrayRange(_buffer, 0);
      if (range < size)
      {
         ArrayResize(_buffer, size);
         for (int i = range; i < size; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double price[1];
      if (!_source.GetSeriesValues(period - _offset, 1, price))
      {
         return false;
      }
      if (index < _length || _buffer[index + 1 - _length] == 0)
      {
         _buffer[index] = price[0];
         return false;
      }

      double lwmw = _length;
      double lwma = lwmw * price[0];
      double sma  = price[0];
      for (int i = 1; i < _length; ++i)
      {
         if (_buffer[index - i] == EMPTY_VALUE)
         {
            _buffer[index] = price[0];
            return false;
         }
         double weight = _length - i;
         lwmw += weight;
         lwma += weight * _buffer[index - i];  
         sma += _buffer[index - i];
      }
      _buffer[index] = (3.0 * lwma / lwmw - 2.0 * sma / _length);
      val = _buffer[index];
      return true;
   }
};


// EMA on stream v2.0

class EMAOnStream : public AOnStream
{
   int _length;
   double _k;
   double _buffer[];
public:
   EMAOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 2.0 / (_length + 1.0);
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }
      
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
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current[0];
      _buffer[bufferIndex] = (1 - _k) * last + _k * current[0];
      val = _buffer[bufferIndex];
      return true;
   }
};


// AveragesStreamFactory v2.0

class AveragesStreamFactory
{
public:
   static TIStream<double>* Create(MATypes method, TIStream<double>* source, TIStream<double>* volumeSource, int period)
   {
      switch (method)
      {
         case ma_sma:
            return new SmaOnStream(source, period);
         case ma_ema:
            return new EMAOnStream(source, period);
         case ma_tema:
            return new TemaOnStream(source, period);
         case ma_vwma:
            return new VwmaOnStream(source, volumeSource, period);
         case ma_hull:
            return new HullOnStream(source, period);
         case ma_rma:
            return new RmaOnStream(source, period);
         case ma_dema:
            return new DEMAOnStream(source, period);
         case ma_linr:
            return new LinearRegressionOnStream(source, period);
      }
      return NULL;
   }
};
Signaler* _signaler;
int ATRperiod;
int BBperiod;
double BBdeviation;
int UseATRfilter;
int showsignals;
FloatStream* sma1Source;
TIStream<double>* sma1;
FloatStream* stdev1Source;
StDevStream* stdev1;
FloatStream* sma2Source;
TIStream<double>* sma2;
FloatStream* stdev2Source;
StDevStream* stdev2;
ATRStream* atr1;
double FollowLine[];
double FollowLine_DEFAULT_VALUE;
double BBSignal[];
double BBSignal_DEFAULT_VALUE;
double iTrend[];
double iTrend_DEFAULT_VALUE;
ColoredPlot* plot1;
double plot2[];
double plot3[];

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
   ATRperiod = param1;
   BBperiod = param2;
   BBdeviation = param3;
   UseATRfilter = param4;
   showsignals = param5;
   sma1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma1 = AveragesStreamFactory::Create(avg_type, sma1Source, NULL, BBperiod);
   stdev1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev1 = new StDevStream(stdev1Source, BBperiod);
   sma2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   sma2 = AveragesStreamFactory::Create(avg_type,sma2Source, NULL, BBperiod);
   stdev2Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   stdev2 = new StDevStream(stdev2Source, BBperiod);
   atr1 = new ATRStream(ATRperiod);
   plot1 = new ColoredPlot(0);
   plot1.AddColor(ColorRGB(9, 98, 232, 0));
   plot1.AddColor(AddTransparency(ColorRGB(220, 20, 60, 0), 0));
   plot1.SetOffset(0);
   id = plot1.RegisterStreams(id);
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, Blue);
   PlotIndexSetInteger(2, PLOT_ARROW, 241);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot3, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, ColorRGB(102, 15, 15, 0));
   PlotIndexSetInteger(3, PLOT_ARROW, 242);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 5);
   ++id;
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("FL");
   IndicatorSetString(INDICATOR_SHORTNAME, "Follow Line");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, FollowLine, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, BBSignal, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, iTrend, INDICATOR_CALCULATIONS);
   id = plot1.RegisterInternalStreams(id);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   sma1Source.Release();
   sma1.Release();
   stdev1Source.Release();
   stdev1.Release();
   sma2Source.Release();
   sma2.Release();
   stdev2Source.Release();
   stdev2.Release();
   atr1.Release();
   delete plot1;
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
      sma1Source.Init();
      stdev1Source.Init();
      sma2Source.Init();
      stdev2Source.Init();
      FollowLine_DEFAULT_VALUE = EMPTY_VALUE;
      ArrayInitialize(FollowLine, FollowLine_DEFAULT_VALUE);
      BBSignal_DEFAULT_VALUE = 0;
      ArrayInitialize(BBSignal, BBSignal_DEFAULT_VALUE);
      iTrend_DEFAULT_VALUE = 0;
      ArrayInitialize(iTrend, iTrend_DEFAULT_VALUE);
      plot1.Init();
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      FollowLine[pos] = pos > 0 ? FollowLine[pos - 1] : EMPTY_VALUE;
      BBSignal[pos] = pos > 0 ? BBSignal[pos - 1] : 0;
      iTrend[pos] = pos > 0 ? iTrend[pos - 1] : 0;
      sma1Source.SetValue(pos, close[pos]);
      double sma1Value[1];
      if (!sma1.GetValues(pos, 1, sma1Value)) { sma1Value[0] = EMPTY_VALUE; }
      stdev1Source.SetValue(pos, close[pos]);
      double stdev1Value[1];
      if (!stdev1.GetValues(pos, 1, stdev1Value)) { stdev1Value[0] = EMPTY_VALUE; }
      double BBUpper = SafePlus(sma1Value[0], SafeMultiply(stdev1Value[0], BBdeviation));
      sma2Source.SetValue(pos, close[pos]);
      double sma2Value[1];
      if (!sma2.GetValues(pos, 1, sma2Value)) { sma2Value[0] = EMPTY_VALUE; }
      stdev2Source.SetValue(pos, close[pos]);
      double stdev2Value[1];
      if (!stdev2.GetValues(pos, 1, stdev2Value)) { stdev2Value[0] = EMPTY_VALUE; }
      double BBLower = SafeMinus(sma2Value[0], SafeMultiply(stdev2Value[0], BBdeviation));
      double atr1Value[1];
      if (!atr1.GetValues(pos, 1, atr1Value)) { atr1Value[0] = EMPTY_VALUE; }
      double atrValue = atr1Value[0];
      if ((SafeGreater(close[pos], BBUpper)))
      {
         SetStream(BBSignal, pos, 1, BBSignal_DEFAULT_VALUE);
      }
      else if ((SafeLess(close[pos], BBLower)))
      {
         SetStream(BBSignal, pos, (-1), BBSignal_DEFAULT_VALUE);
      }
      if (((BBSignal[pos] == 1)))
      {
         if ((UseATRfilter))
         {
            SetStream(FollowLine, pos, SafeMinus(low[pos], atrValue), FollowLine_DEFAULT_VALUE);
         }
         else
         {
            SetStream(FollowLine, pos, low[pos], FollowLine_DEFAULT_VALUE);
         }
         if (pos - 1 < 0) { continue; }
         if ((SafeLess(FollowLine[pos], Nz(FollowLine[pos - 1]))))
         {
            if (pos - 1 < 0) { continue; }
            SetStream(FollowLine, pos, Nz(FollowLine[pos - 1]), FollowLine_DEFAULT_VALUE);
         }
      }
      if (((BBSignal[pos] == (-1))))
      {
         if ((UseATRfilter))
         {
            SetStream(FollowLine, pos, SafePlus(high[pos], atrValue), FollowLine_DEFAULT_VALUE);
         }
         else
         {
            SetStream(FollowLine, pos, high[pos], FollowLine_DEFAULT_VALUE);
         }
         if (pos - 1 < 0) { continue; }
         if ((SafeGreater(FollowLine[pos], Nz(FollowLine[pos - 1]))))
         {
            if (pos - 1 < 0) { continue; }
            SetStream(FollowLine, pos, Nz(FollowLine[pos - 1]), FollowLine_DEFAULT_VALUE);
         }
      }
      if (pos - 1 < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      if ((SafeGreater(Nz(FollowLine[pos]), Nz(FollowLine[pos - 1]))))
      {
         SetStream(iTrend, pos, 1, iTrend_DEFAULT_VALUE);
      }
      else if ((SafeLess(Nz(FollowLine[pos]), Nz(FollowLine[pos - 1]))))
      {
         SetStream(iTrend, pos, (-1), iTrend_DEFAULT_VALUE);
      }
      uint lineColor = ((iTrend[pos] > 0) ? ColorRGB(9, 98, 232, 0) : AddTransparency(ColorRGB(220, 20, 60, 0), 0));
      double buy = 0.0;
      double sell = 0.0;
      if (pos - 1 < 0) { continue; }
      buy = ((iTrend[pos - 1] == (-1)) && (iTrend[pos] == 1) ? 1 : INT_MIN);
      if (pos - 1 < 0) { continue; }
      sell = ((iTrend[pos - 1] == 1) && (iTrend[pos] == (-1)) ? 1 : INT_MIN);
      if ((sell == 1)) { _signaler.SendNotifications("Sell", "Follow Line Sell"); }
      if ((buy == 1)) { _signaler.SendNotifications("Buy", "Follow Line Buy"); }
      if (((buy == 1) || (sell == 1))) { _signaler.SendNotifications("Signal", "Follow Line Signal"); }
      double plot1Value = plot1.Set(pos, FollowLine[pos], lineColor);
      plot2[pos] = ((buy == 1) && showsignals ? SafeMinus(FollowLine[pos], atrValue) : EMPTY_VALUE);
      plot3[pos] = ((sell == 1) && showsignals ? SafePlus(FollowLine[pos], atrValue) : EMPTY_VALUE);
   }
   return rates_total;
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=159185#p159185

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 