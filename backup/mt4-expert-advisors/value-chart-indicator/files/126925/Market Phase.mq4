// This indicator shows the relation of price against different period ma's.
// When put in daily Timeframe it gives the 1400 Day (= 200 Weekly) && the 200 ,100 an 50 Daily.
// Features:
// - The lines show the 200,100 && 50 ma in relation to the 1400 ma.
// - The  arrows indicate possible (retracement) entry points
// Coded by AlexF

// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68578
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
#property indicator_buffers 9
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
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

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
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

// Instrument info v.1.4
// More templates and snippets on https://github.com/sibvic/mq4-templates

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

// Condition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

class ABaseCondition : public ICondition
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   string _symbol;
public:
   ABaseCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ABaseCondition()
   {
      delete _instrument;
   }
};

class UpAlertCondition : public ABaseCondition
{
public:
   UpAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return trend[period] == -1 && ma50._stream[period] < 0 && ma50._stream[period + 1] >= 0;
   }
};

class DownAlertCondition : public ABaseCondition
{
public:
   DownAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return trend[period] == 1 && ma50._stream[period] > 0 && ma50._stream[period + 1] <= 0;
   }
};

// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

struct CandleData
{
   double Open;
   double High;
   double Low;
   double Close;
   datetime Date;
};

interface IBarStreamIterator
{
public:
   virtual bool Next() = 0;
   virtual IBarStreamIterator *CreateForwardIterator() = 0;
   virtual IBarStreamIterator *CreateReverseIterator() = 0;

   virtual datetime GetDate() = 0;

   virtual double GetOpen() = 0;
   virtual double GetHigh() = 0;
   virtual double GetLow() = 0;
   virtual double GetClose() = 0;
   virtual void GetData(CandleData &candle) = 0;
};

interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual double GetOpen(const int period, double &open) = 0;
   virtual double GetHigh(const int period, double &high) = 0;
   virtual double GetLow(const int period, double &low) = 0;
   virtual double GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;

   virtual bool GetIsAscending(const int period, bool &res) = 0;

   virtual bool GetIsDescending(const int period, bool &res) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual int Size() = 0;

   virtual void Refresh() = 0;

   virtual IBarStreamIterator *CreateForwardIterator() = 0;
   virtual IBarStreamIterator *CreateReverseIterator() = 0;
};

class BarStreamIterator : public IBarStreamIterator 
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _index;
   bool _forward;
public:
   BarStreamIterator(const string symbol, const ENUM_TIMEFRAMES timeframe, const bool forward)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _index = -1;
      _forward = forward;
   }

   virtual datetime GetDate()
   {
      return iTime(_symbol, _timeframe, _index);
   }

   virtual double GetOpen()
   {
      return iOpen(_symbol, _timeframe, _index);
   }

   virtual double GetHigh()
   {
      return iHigh(_symbol, _timeframe, _index);
   }

   virtual double GetLow()
   {
      return iLow(_symbol, _timeframe, _index);
   }

   virtual double GetClose()
   {
      return iClose(_symbol, _timeframe, _index);
   }

   virtual void GetData(CandleData &candle)
   {
      candle.Date = iTime(_symbol, _timeframe, _index);
      candle.Open = iOpen(_symbol, _timeframe, _index);
      candle.High = iHigh(_symbol, _timeframe, _index);
      candle.Low = iLow(_symbol, _timeframe, _index);
      candle.Close = iClose(_symbol, _timeframe, _index);
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      BarStreamIterator *copy = new BarStreamIterator(_symbol, _timeframe, true);
      copy._index = _index;
      if (!copy.MoveBackward())
         copy._index = -1;
      return copy;
   }
   virtual IBarStreamIterator *CreateReverseIterator()
   {
      BarStreamIterator *copy = new BarStreamIterator(_symbol, _timeframe, false);
      copy._index = _index;
      if (!copy.MoveForward())
         copy._index = -1;
      return copy;
   }
   
   virtual bool Next()
   {
      if (_forward)
         return MoveForward();
      return MoveBackward();
   }
private:
   bool MoveForward()
   {
      if (_index == 0)
         return false;
      if (_index == -1)
         _index = iBars(_symbol, _timeframe) - 1;
      else
         --_index;
      return true;
   }

   bool MoveBackward()
   {
      if (iBars(_symbol, _timeframe) - 1 <= _index)
         return false;
      ++_index;
      return true;
   }
};

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      return new BarStreamIterator(_symbol, _timeframe, true);
   }

   virtual IBarStreamIterator *CreateReverseIterator()
   {
      return new BarStreamIterator(_symbol, _timeframe, false);
   }

   virtual bool GetValue(const int period, double &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      val = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      dt = iTime(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetOpen(const int period, double &open)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetHigh(const int period, double &high)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetLow(const int period, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetClose(const int period, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      res = iOpen(_symbol, _timeframe, period) < iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      res = iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void Refresh() { }
};

class CandleBodyBarStream : public IBarStream
{
   IBarStream *_source;
public:
   CandleBodyBarStream(IBarStream *source)
   {
      _source = source;
   }

   virtual bool GetValue(const int period, double &val)
   {
      return _source.GetValue(period, val);
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (!_source.GetValues(period, open, high, low, close))
         return false;

      high = MathMax(open, close);
      low = MathMin(open, close);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      double open, close;
      if (!_source.GetValues(period, open, high, low, close))
         return false;
      
      high = MathMax(open, close);
      low = MathMin(open, close);
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      return _source.GetIsAscending(period, res);
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      return _source.GetIsDescending(period, res);
   }
};

class CustomTimeframeBarStreamIterator : public IBarStreamIterator
{
private:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
   int _startIndex;
   int _endIndex;
   bool _forward;
public:
   CustomTimeframeBarStreamIterator(const string symbol, const ENUM_TIMEFRAMES timeframe, const int timeframeMult, const bool forward)
   {
      _forward = forward;
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
      _startIndex = -1;
      _endIndex = -1;
   }

   virtual datetime GetDate()
   {
      return iTime(_symbol, _timeframe, _startIndex);
   }

   virtual double GetOpen()
   {
      return iOpen(_symbol, _timeframe, _startIndex);
   }

   virtual double GetHigh()
   {
      return iHigh(_symbol, _timeframe, iHighest(_symbol, _timeframe, MODE_HIGH, _endIndex - _startIndex, _endIndex));
   }

   virtual double GetLow()
   {
      return iLow(_symbol, _timeframe, iLowest(_symbol, _timeframe, MODE_LOW, _endIndex - _startIndex, _endIndex));
   }

   virtual double GetClose()
   {
      return iClose(_symbol, _timeframe, _endIndex);
   }

   virtual void GetData(CandleData &candle)
   {
      candle.Date = GetDate();
      candle.Open = GetOpen();
      candle.High = GetHigh();
      candle.Low = GetLow();
      candle.Close = GetClose();
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      CustomTimeframeBarStreamIterator *copy = new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, true);
      copy._startIndex = _startIndex;
      copy._endIndex = _endIndex;
      if (!copy.MoveBackward())
      {
         copy._startIndex = -1;
         copy._endIndex = -1;
      }
      return copy;
   }
   virtual IBarStreamIterator *CreateReverseIterator()
   {
      CustomTimeframeBarStreamIterator *copy = new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, false);
      copy._startIndex = _startIndex;
      copy._endIndex = _endIndex;
      if (!copy.MoveBackward())
      {
         copy._startIndex = -1;
         copy._endIndex = -1;
      }
      return copy;
   }

   virtual bool Next()
   {
      if (_forward)
         return MoveForward();
      return MoveBackward();
   }
private:
   bool MoveForward()
   {
      if (_endIndex == 0)
         return false;
      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      if (_startIndex == -1)
      {
         datetime barStart = (Time[iBars(_symbol, _timeframe)] / periodLength) * periodLength;
         _startIndex = iBarShift(_symbol, _timeframe, barStart);
         if (_startIndex == -1)
         {
            barStart += periodLength;
            _startIndex = iBarShift(_symbol, _timeframe, barStart);
            if (_startIndex == -1)
               return false;
         }
         _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
         return true;
      }
      --_endIndex;
      
      datetime barStart = (Time[_endIndex] / periodLength) * periodLength;
      _startIndex = iBarShift(_symbol, _timeframe, barStart);
      _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
      return true;
   }

   bool MoveBackward()
   {
      int maxIndex = iBars(_symbol, _timeframe) - 1;
      if (maxIndex <= _startIndex)
         return false;
      ++_startIndex;

      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      datetime barStart = (Time[_startIndex] / periodLength) * periodLength;
      _startIndex = iBarShift(_symbol, _timeframe, barStart);
      if (_startIndex == -1)
      {
         _startIndex = maxIndex;
         return false;
      }
      _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
      return true;
   }
};

class CustomTimeframeBarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
   
   datetime _dates[];
   double _open[];
   double _close[];
   double _high[];
   double _low[];
   int _size;
public:
   CustomTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int timeframeMult)
   {
      _size = 0;
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      return new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, true);
   }

   virtual IBarStreamIterator *CreateReverseIterator()
   {
      return new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, false);
   }

   virtual bool GetValue(const int period, double &val)
   {
      if (period >= _size)
         return false;
      val = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (period >= _size)
         return false;
      dt = _dates[_size - 1 - period];
      return true;
   }

   virtual double GetOpen(const int period, double &open)
   {
      if (_size <= period)
         return false;
      open = _open[_size - 1 - period];
      return true;
   }

   virtual double GetHigh(const int period, double &high)
   {
      if (_size <= period)
         return false;
      high = _high[_size - 1 - period];
      return true;
   }

   virtual double GetLow(const int period, double &low)
   {
      if (_size <= period)
         return false;
      low = _low[_size - 1 - period];
      return true;
   }

   virtual double GetClose(const int period, double &close)
   {
      if (_size <= period)
         return false;
      close = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (period >= _size)
         return false;
      high = _high[_size - 1 - period];
      low = _low[_size - 1 - period];
      open = _open[_size - 1 - period];
      close = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (period >= _size)
         return false;
      high = _high[_size - 1 - period];
      low = _low[_size - 1 - period];
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      if (period >= _size)
         return false;
      res = _open[_size - 1 - period] < _close[_size - 1 - period];
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      if (period >= _size)
         return false;
      res = _open[_size - 1 - period] > _close[_size - 1 - period];
      return true;
   }

   virtual int Size()
   {
      return _size;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, _timeframe) - 1;
      if (_size > 0)
      {
         start = iBarShift(_symbol, _timeframe, _dates[_size - 1]);
      }
      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      for (int i = start; i >= 0; --i)
      {
         datetime barStart = (iTime(_symbol, _timeframe, i) / periodLength) * periodLength;
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, _timeframe, i);
            _high[_size - 1] = iHigh(_symbol, _timeframe, i);
            _low[_size - 1] = iLow(_symbol, _timeframe, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, _timeframe, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, _timeframe, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, _timeframe, i);
         while (barStart == _dates[_size - 1] && i >= 0)
         {
            barStart = (iTime(_symbol, _timeframe, --i) / periodLength) * periodLength;
         }
      }
   }
};

interface IStreamFactory
{
public:
   virtual IStream *Create(const int order) = 0;
};

class StreamFactory : public IStreamFactory
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   StreamFactory(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   virtual IStream *Create(const int order)
   {
      return NULL;
   }
};

// Alert signal v.1.0

class AlertSignal
{
   double _signals[];
   ICondition* _condition;
   IStream* _price;
   Signaler* _signaler;
   string _message;
   datetime _lastSignal;
public:
   AlertSignal(ICondition* condition, IStream* price, Signaler* signaler)
   {
      _condition = condition;
      _price = price;
      _price.AddRef();
      _signaler = signaler;
   }

   ~AlertSignal()
   {
      _price.Release();
      delete _condition;
   }

   int RegisterStreams(int id, string name, int code, color clr)
   {
      SetIndexStyle(id + 0, DRAW_ARROW, 0, 2, clr);
      SetIndexBuffer(id + 0, _signals);
      SetIndexLabel(id + 0, name);
      SetIndexArrow(id + 0, code);
      _message = name;
      
      return id + 1;
   }

   void Update(int period)
   {
      if (_condition.IsPass(period))
      {
         double price;
         if (_price.GetValue(period, price))
         {
            _signals[period] = price;
            if (period != 0)
                return;
            string symbol = _signaler.GetSymbol();
            datetime dt = iTime(symbol, _signaler.GetTimeframe(), 0);
            if (_lastSignal != dt)
            {
               _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
               _lastSignal = dt;
            }
            return;
         }
      }
      _signals[period] = EMPTY_VALUE;
   }
};

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

class CustomStream : public AStream
{
public:
   double _stream[];

   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

AlertSignal* up;
AlertSignal* down;
Signaler* mainSignaler;
double trend[], ma1400[], ma200[], ma100[], dma50[], dma100[], dma200[];
CustomStream* ma50;

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("Market Phase");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(10);

   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);

   int id = 0;
   ma50 = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = ma50.RegisterStream(id, Yellow, 1, STYLE_SOLID, "50 phase");

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, dma50);
   SetIndexLabel(id, "50");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, ma100);
   SetIndexLabel(id, "100 phase");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, dma100);
   SetIndexLabel(id, "100");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, ma200);
   SetIndexLabel(id, "200 phase");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, dma200);
   SetIndexLabel(id, "200");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, ma1400);
   SetIndexLabel(id, "1400 phase");
   ++id;

   up = new AlertSignal(new UpAlertCondition(_Symbol, (ENUM_TIMEFRAMES)_Period), ma50, mainSignaler);
   id = up.RegisterStreams(id, "Up", 218, Red);
   down = new AlertSignal(new DownAlertCondition(_Symbol, (ENUM_TIMEFRAMES)_Period), ma50, mainSignaler);
   id = down.RegisterStreams(id, "Down", 217, Green);
   SetIndexStyle(9, DRAW_NONE);
   SetIndexBuffer(9, trend);

   return 0;
}

int deinit()
{
   ma50.Release();
   delete mainSignaler;
   delete up;
   delete down;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1 - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      ma50._stream[pos] = Close[pos] - iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE, pos);
      ma100[pos] = Close[pos] - iMA(_Symbol, _Period, 100, 0, MODE_EMA, PRICE_CLOSE, pos);
      ma200[pos] = Close[pos] - iMA(_Symbol, _Period, 200, 0, MODE_SMA, PRICE_CLOSE, pos);
      ma1400[pos] = Close[pos] - iMA(_Symbol, _Period, 1400, 0, MODE_SMA, PRICE_CLOSE, pos);
      dma50[pos] = ma1400[pos] - ma50._stream[pos];
      dma100[pos] = ma1400[pos] - ma100[pos];
      dma200[pos] = ma1400[pos] - ma200[pos];

      trend[pos] = trend[pos + 1];
      if (dma50[pos] < dma50[pos + 1] 
         && dma100[pos] < dma100[pos + 1] 
         && dma200[pos] < dma200[pos + 1] 
         && ma50._stream[pos] < 0 
         && ma100[pos] < 0 
         && ma200[pos] < 0 
         && ma1400[pos] < 0)
      {
         trend[pos] = -1;
      }
      else if (dma50[pos] > dma50[pos + 1] 
         && dma100[pos] > dma100[pos + 1] 
         && dma200[pos] > dma200[pos + 1] 
         && ma50._stream[pos] > 0 
         && ma100[pos] > 0 
         && ma200[pos] > 0 
         && ma1400[pos] > 0)
      {
         trend[pos] = 1;
      }

      up.Update(pos);
      down.Update(pos);
   } 
   return 0;
}