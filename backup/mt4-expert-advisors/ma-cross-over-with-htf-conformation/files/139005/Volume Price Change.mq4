// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68550

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_label1 "Oscillator"

input int length = 15; // Period
input int price_smoothing = 15; // Price Smoothing
input int signal_smoothing = 15; // Signal Smoothing
input int overbought = 80; // Overbought Level
input int oversold = 20; // Oversold Level
input color vpc_color = Red; // VPC color
input color signal_color = Green; // Signal color
input bool line_zero_alert = false; // Alert Line/Zero
input bool line_signal_alert = false; // Alert Line/Signal
input bool line_os_alert = false; // Alert Line/Oversold
input bool line_ob_alert = false; // Alert Line/Overbought
//Signaler v 1.6
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = true; // Popup message
extern bool     notification_alert       = false; // Push notification
extern bool     email_alert              = false; // Email
extern bool     play_sound               = false; // Play sound on alert
extern string   sound_file               = ""; // Sound file
extern bool     start_program            = false; // Start external program
extern string   program_path             = ""; // Path to the external program executable
extern bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
extern string   advanced_key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const int direction)
   {
      if (direction == 0)
         return;

      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            alert_Subject = "Buy signal on " + _symbol + "/" + tf;
            alert_Body = "Buy signal on " + _symbol + "/" + tf;
            break;
         case ENTER_SELL_SIGNAL:
            alert_Subject = "Sell signal on " + _symbol + "/" + tf;
            alert_Body = "Sell signal on " + _symbol + "/" + tf;
            break;
         case EXIT_BUY_SIGNAL:
            alert_Subject = "Exit buy signal on " + _symbol + "/" + tf;
            alert_Body = "Exit buy signal on " + _symbol + "/" + tf;
            break;
         case EXIT_SELL_SIGNAL:
            alert_Subject = "Exit sell signal on " + _symbol + "/" + tf;
            alert_Body = "Exit sell signal on " + _symbol + "/" + tf;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _symbol, tf);
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframe();

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

private:
   string GetTimeframe()
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
};

double signal[], up[], down[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

// Instrument info v.1.4
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

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

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
};

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
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType price)
      :AStream(symbol, timeframe)
   {
      _price = price;
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
            val = iVolume(_symbol, _timeframe, period);
            break;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};

class SmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
   int _references;
public:
   SmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
   }

   ~SmaOnStream()
   {
      _source.Release();
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

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - _length)
         return false;

      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - _length && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         double current;
         double last;
         if (!_source.GetValue(period, current) || !_source.GetValue(period + _length, last))
            return false;
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + (current - last) / _length;
      }
      else 
      {
         _buffer[bufferIndex] = EMPTY_VALUE; 
         double summ = 0;
         for(int i = 0; i < _length; i++) 
         {
            double current;
            if (!_source.GetValue(period + i, current))
               return false;

           summ += current;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};

class EmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
   double _alpha;
   int _references;
public:
   EmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _alpha = 2.0 / (1.0 + _length);
      _references = 1;
   }

   ~EmaOnStream()
   {
      _source.Release();
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

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - 1 || period < 0)
         return false;

      double price;
      if (!_source.GetValue(period, price))
         return false;

      int bufferIndex = totalBars - 1 - period;
      if (bufferIndex == 0)
         _buffer[bufferIndex] = price;
      else
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + _alpha * (price - _buffer[bufferIndex - 1]);
      val = _buffer[bufferIndex];
      return true;
   }
};

class CustomStream : public AStream
{
public:
   double _stream[];

   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      return id + 1;
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

IStream* EMA1;
IStream* EMA3;
IStream* MVA;
CustomStream *vpc;
Signaler* signaler;
int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);

   IndicatorName = GenerateIndicatorName("Volume Price Change");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(2);

   if (price_smoothing > 1)
   {
      IStream* ema1Source = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceClose);
      EMA1 = new EmaOnStream(ema1Source, price_smoothing);
      ema1Source.Release();

      IStream* ema2Source = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceVolume);
      IStream* EMA2 = new EmaOnStream(ema2Source, price_smoothing);
      ema2Source.Release();

      MVA = new SmaOnStream(EMA2, length);
      EMA2.Release();
   }
   else
   {
      IStream* ema2Source = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceVolume);
      MVA = new SmaOnStream(ema2Source, price_smoothing);
      ema2Source.Release();
   }

   vpc = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   int id = vpc.RegisterStream(0, vpc_color, 1, STYLE_SOLID);
   SetIndexBuffer(id, signal);
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, signal_color);
   ++id;
   
   SetIndexStyle(id, DRAW_ARROW, 0, 2);
   SetIndexArrow(id, 217);
   SetIndexBuffer(id, up);
   ++id;
   SetIndexStyle(id, DRAW_ARROW, 0, 2);
   SetIndexArrow(id, 218);
   SetIndexBuffer(id, down);

   EMA3 = new EmaOnStream(vpc, signal_smoothing);
   
   return(0);
}

int deinit()
{
   delete signaler;
   signaler = NULL;
   EMA3.Release();
   EMA3 = NULL;
   MVA.Release();
   MVA = NULL;
   if (EMA1 != NULL)
      EMA1.Release();
   EMA1 = NULL;
   vpc.Release();
   vpc = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

datetime last_signal;

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   for (int pos = limit; pos >= 0; --pos)
   {
      if (price_smoothing > 1)
      {
         double ema1Value0, ema1Value1, mvaValue;
         if (EMA1.GetValue(pos, ema1Value0) && EMA1.GetValue(pos + length - 1, ema1Value1) && MVA.GetValue(pos, mvaValue))
            vpc._stream[pos] = (ema1Value0 - ema1Value1) * mvaValue;
      }
      else
      {
         double mvaValue;
         if (MVA.GetValue(pos, mvaValue))
            vpc._stream[pos] = (Close[pos] - Close[pos + length - 1]) * mvaValue;
      }
      double ema3Value;
      if (!EMA3.GetValue(pos, ema3Value))
         continue;

      signal[pos] = ema3Value;
   } 

   if (last_signal == Time[0])
      return 0;

   if (line_zero_alert)
   {
      if (vpc._stream[0] > 0 && vpc._stream[1] <= 0)
      {
         signaler.SendNotifications("Line/Zero. Cross Over");
         last_signal = Time[0];
      }
      else if (vpc._stream[0] < 0 && vpc._stream[1] >= 0)
      {
         signaler.SendNotifications("Line/Zero. Cross Under");
         last_signal = Time[0];
      }
   }
   if (line_signal_alert)
   {
      if (vpc._stream[0] > signal[0] && vpc._stream[1] <= signal[1])
      {
         signaler.SendNotifications("Line/Signal. Cross Over");
         last_signal = Time[0];
      }
      else if (vpc._stream[0] < signal[0] && vpc._stream[1] >= signal[1])
      {
         signaler.SendNotifications("Line/Signal. Cross Under");
         last_signal = Time[0];
      }
   }
   if (line_os_alert)
   {
      if (signal[0] > oversold && signal[1] < oversold)
      {
         signaler.SendNotifications("Line/Oversold. Cross Over");
         last_signal = Time[0];
      }
      else if (signal[0] < oversold && signal[1] > oversold)
      {
         signaler.SendNotifications("Line/Oversold. Cross Under");
         last_signal = Time[0];
      }
   }
   if (line_ob_alert)
   {
      if (signal[0] > overbought && signal[1] < overbought)
      {
         signaler.SendNotifications("Line/Overbought. Cross Over");
         last_signal = Time[0];
      }
      else if (signal[0] < overbought && signal[1] > overbought)
      {
         signaler.SendNotifications("Line/Overbought. Cross Under");
         last_signal = Time[0];
      }
   }
   return 0;
}