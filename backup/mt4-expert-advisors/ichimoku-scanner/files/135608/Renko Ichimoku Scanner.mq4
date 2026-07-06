// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68827&start=40

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
#property version   "1.5"
#property strict

#property indicator_separate_window

enum RenkoMode
{
   RenkoTraditional,
   RenkoATR
};

input RenkoMode renko_mode = RenkoTraditional; // Renko mode
input double renko_step = 2; // Renko step
input int  Tenkan_Sen_Period = 9;
input int  Kijun_Sen_Period = 26;
input int  Senkou_Span_B_Period = 52;

enum DisplayMode
{
   Vertical,
   Horizontal
};

input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD";
input bool     Include_M1               = false;
input bool     Include_M5               = false;
input bool     Include_M15              = false;
input bool     Include_M30              = false;
input bool     Include_H1               = true;
input bool     Include_H4               = false;
input bool     Include_D1               = true;
input bool     Include_W1               = true;
input bool     Include_MN1              = false;
input color    Labels_Color             = clrWhite;
input color    Up_Color                 = clrLime;
input color    Dn_Color                 = clrRed;
input color    Neutral_Color            = clrDarkGray;
input int x_shift = 900; // X coordinate
input DisplayMode display_mode = Vertical; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height
input bool alert_on_close = false; // Alert of bar close
input int expiration_min = 5; // Signal expiration, minutes

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool cross_alarm = true; // Cross alarm
input bool kumo_switches = true; // Kumo switches
input bool road_cross = true; // Road cross
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

#define MAX_LOOPBACK 500

string   WindowName;
int      WindowNumber;

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
// Instrument info v.1.6
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

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

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

class ACustomBarStream : public IBarStream
{
protected:
   int _references;

   datetime _dates[];
   double _open[];
   double _close[];
   double _high[];
   double _low[];
   int _size;

   ACustomBarStream()
   {
      _size = 0;
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

   virtual bool GetValue(const int period, double &val)
   {
      if (period >= _size)
         return false;
      val = _close[_size - 1 - period];
      return true;
   }

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      for (int i = 0; i < _size; ++i)
      {
         if (_dates[_size - 1 - i] <= date)
         {
            period = MathMax(i, 0);
            return true;
         }
      }
      return false;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (period >= _size)
         return false;
      dt = _dates[_size - 1 - period];
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      if (_size <= period)
         return false;
      open = _open[_size - 1 - period];
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (_size <= period)
         return false;
      high = _high[_size - 1 - period];
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (_size <= period)
         return false;
      low = _low[_size - 1 - period];
      return true;
   }

   virtual bool GetClose(const int period, double &close)
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

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      if (period >= _size)
         return false;
      close = _close[_size - 1 - period];
      open = _open[_size - 1 - period];
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
};

class RenkoStream : public ACustomBarStream
{
   int _barsLimit;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _step;
   RenkoMode _mode;
   int _lastDirection;
   double _initialPrice;
   InstrumentInfo _instrument;
public:
   RenkoStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int barsLimit)
      :_instrument(symbol)
   {
      _barsLimit = barsLimit;
      _symbol = symbol;
      _timeframe = timeframe;
      _lastDirection = 0;
      _initialPrice = 0;
   }

   bool SetStep(const RenkoMode mode, const double step)
   {
      _mode = mode;
      if (_mode != RenkoATR)
      {
         _step = step * _instrument.GetPipSize();
         return true;
      }
      _step = step;
      return true;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, _timeframe) - 1;
      if (_size > 0)
      {
         start = iBarShift(_symbol, _timeframe, _dates[_size - 1]);
      }
      start = MathMin(_barsLimit, start);

      for (int i = start; i >= 0; --i)
      {
         if (_initialPrice == 0 || _size == 0)
         {
            calcFirstValueValue(i);
            continue;
         }
         double diff = _instrument.RoundRate(_close[_size - 1] - _open[_size - 1]);
         if (diff > 0 || (diff == 0 && _lastDirection == 1))
         {
            HandleUp(i);
         }
         if (diff < 0 || (diff == 0 && _lastDirection == -1))
         {
            HandleDown(i);
         }
      }
   }
private:

   bool GetStep(const int period, double &step)
   {
      if (_mode == RenkoATR)
      {
         double atrValue = iATR(_symbol, _timeframe, (int)_step, period);
         if (atrValue == EMPTY_VALUE)
            return false;
         step = _instrument.RoundRate(atrValue);
         return step != 0.0;
      }
      
      step = _step;
      return true;
   }

   void AddBar(datetime date)
   {
      ++_size;
      ArrayResize(_dates, _size);
      ArrayResize(_open, _size);
      ArrayResize(_high, _size);
      ArrayResize(_low, _size);
      ArrayResize(_close, _size);
      if (_size == 1)
         _dates[_size - 1] = date;
      else if (_dates[_size - 2] >= date)
         _dates[_size - 1] = _dates[_size - 2] + 1;
      else
         _dates[_size - 1] = date;
   }

   void calcFirstValueValue(const int period)
   {
      double step;
      if (!GetStep(period, step))
         return;
      double price = iClose(_symbol, _timeframe, period);
      if (_initialPrice == 0.0)
      {
         _initialPrice = price;
         return;
      }
      datetime date = iTime(_symbol, _timeframe, period);
      double openVal = _instrument.RoundRate(MathFloor(_initialPrice / step) * step);
      if (price > _instrument.RoundRate(openVal + step))
      {
         while (price > _instrument.RoundRate(openVal + step))
         {
            AddBar(date);
            _open[_size - 1] = openVal;
            _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] + step);
            _low[_size - 1] = _open[_size - 1];
            _high[_size - 1] = _close[_size - 1];
            openVal = _instrument.RoundRate(openVal + step);
         }
         _lastDirection = 1;
         return;
      }
      
      while (price < _instrument.RoundRate(openVal - step))
      {
         AddBar(date);
         _open[_size - 1] = openVal;
         _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] - step);
         _high[_size - 1] = _open[_size - 1];
         _low[_size - 1] = _close[_size - 1];
         openVal = _instrument.RoundRate(openVal - step);
      }
      _lastDirection = -1;
   }
   void HandleUp(const int period)
   {
      double step;
      if (!GetStep(period, step))
         return;
      
      double price = iClose(_symbol, _timeframe, period);
      datetime date = iTime(_symbol, _timeframe, period);
      _lastDirection = 1;
      while (price > _instrument.RoundRate(_close[_size - 1] + step))
      {
         AddBar(date);
         _open[_size - 1] = _close[_size - 2];
         _low[_size - 1] = _open[_size - 1];
         _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] + step);
         _high[_size - 1] = _close[_size - 1];
      }
      double doubleStep = _instrument.RoundRate(step * 2);
      if (price < _instrument.RoundRate(_close[_size - 1] - doubleStep))
      {
         while (price < _instrument.RoundRate(_close[_size - 1] - step))
         {
            AddBar(date);
            if (_close[_size - 2] > _open[_size - 2])
            {
               _open[_size - 1] = _instrument.RoundRate(_close[_size - 2] - step);
            }
            else
            {
               _open[_size - 1] = _close[_size - 2];
            }
            _high[_size - 1] = _open[_size - 1];
            _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] - step);
            _low[_size - 1] = _close[_size - 1];
         }
      }
   }

   void HandleDown(const int period)
   {
      double step;
      if (!GetStep(period, step))
         return;
      
      double price = iClose(_symbol, _timeframe, period);
      datetime date = iTime(_symbol, _timeframe, period);
      _lastDirection = -1;
      while (price < _instrument.RoundRate(_close[_size - 1] - step))
      {
         AddBar(date);
         _open[_size - 1] = _close[_size - 2];
         _high[_size - 1] = _open[_size - 1];
         _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] - step);
         _low[_size - 1] = _close[_size - 1];
      }
      double doubleStep = _instrument.RoundRate(step * 2);
      if (price > _instrument.RoundRate(_close[_size - 1] + doubleStep))
      {
         while (price > _instrument.RoundRate(_close[_size - 1] + step))
         {
            AddBar(date);
            if (_close[_size - 2] < _open[_size - 2])
            {
               _open[_size - 1] = _instrument.RoundRate(_close[_size - 2] + step);
            }
            else
            {
               _open[_size - 1] = _close[_size - 2];
            }
            _low[_size - 1] = _open[_size - 1];
            _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] + step);
            _high[_size - 1] = _close[_size - 1];
         }
      }
   }
};

class IchimokuStream : public AStreamBase
{
   int _tenkan;   // Tenkan-sen
   int _kijun;   // Kijun-sen
   int _senkou;  // Senkou Span B
   IBarStream* _source;
   double tenkanSen[];
   double kijunSen[];
   double spanA[];
   double ExtSpanA_Buffer[];
   double spanB[];
public:
   IchimokuStream(int tenkan, int kijun, int senkou, IBarStream* source)
   {
      _tenkan = tenkan;
      _kijun = kijun;
      _senkou = senkou;
      _source = source;
      _source.AddRef();
   }

   ~IchimokuStream()
   {
      _source.Release();
   }

   virtual int Size()
   {
      return _source.Size();
   }

   double GetTenkanSen(const int period)
   {
      return tenkanSen[Size() - period - 1];
   }
   double GetKijunSen(const int period)
   {
      return kijunSen[Size() - period - 1];
   }
   double GetSpanA(const int period)
   {
      return spanA[Size() - period - 1];
   }
   double GetSpanB(const int period)
   {
      return spanB[Size() - period - 1];
   }

   void Calculate(int period)
   {
      int size = Size();
      if (ArraySize(tenkanSen) < size)
      {
         ArrayResize(tenkanSen, size);
         ArrayResize(kijunSen, size);
         ArrayResize(spanA, size);
         ArrayResize(spanB, size);
      }
      int index = size - period - 1;
      double high, low;
      if (!_source.GetHighLow(period, high, low))
      {
         return;
      }
      double high_value = high;
      double low_value = low;
      for (int k = 0; k <= _tenkan; ++k)
      {
         if (!_source.GetHighLow(period + k, high, low))
         {
            return;
         }
         if (high_value < high)
            high_value = high;
         if(low_value > low)
            low_value = low;
      }
      tenkanSen[index] = (high_value + low_value) / 2;

      if (!_source.GetHighLow(period, high, low))
      {
         return;
      }
      high_value = high;
      low_value = low;
      for (int k = 0; k <= _kijun; ++k)
      {
         if (!_source.GetHighLow(period + k, high, low))
         {
            return;
         }
         if (high_value < high)
            high_value = high;
         if (low_value > low)
            low_value = low;
      }
      kijunSen[index] = (high_value + low_value) / 2;

      spanA[index] = (kijunSen[index] + tenkanSen[index]) / 2;

      high_value = high;
      low_value = low;
      for (int k = 0; k <= _senkou; ++k)
      {
         if (!_source.GetHighLow(period + k, high, low))
         {
            return;
         }
         if (high_value < high)
            high_value = high;
         if (low_value > low)
            low_value = low;
      }
      spanB[index] = (high_value + low_value) / 2;
   }

   virtual bool GetValue(const int period, double &val)
   {
      return true;
   }
};

class UpCondition : public ACondition
{
   RenkoStream* _renko;
   IchimokuStream* _ichimoku;
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe, RenkoStream* renko, IchimokuStream* ichimoku)
      :ACondition(symbol, timeframe)
   {
      _renko = renko;
      _renko.AddRef();
      _ichimoku = ichimoku;
      _ichimoku.AddRef();
   }

   ~UpCondition()
   {
      _renko.Release();
      _ichimoku.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      _renko.Refresh();
      _ichimoku.Calculate(period);
      _ichimoku.Calculate(period + 1);

      double TENKANSEN_0 = _ichimoku.GetTenkanSen(period);
      double KIJUNSEN_0 = _ichimoku.GetKijunSen(period);
      double TENKANSEN_1 = _ichimoku.GetTenkanSen(period + 1);
      double KIJUNSEN_1 = _ichimoku.GetKijunSen(period + 1);
      
      return TENKANSEN_0 > KIJUNSEN_0 && TENKANSEN_1 <= KIJUNSEN_1;
   }
};

class RoadCrossCondition : public ACondition
{
   RenkoStream* _renko;
   IchimokuStream* _ichimoku;
public:
   RoadCrossCondition(const string symbol, ENUM_TIMEFRAMES timeframe, RenkoStream* renko, IchimokuStream* ichimoku)
      :ACondition(symbol, timeframe)
   {
      _renko = renko;
      _renko.AddRef();
      _ichimoku = ichimoku;
      _ichimoku.AddRef();
   }

   ~RoadCrossCondition()
   {
      _renko.Release();
      _ichimoku.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      _renko.Refresh();
      _ichimoku.Calculate(period);
      _ichimoku.Calculate(period + 1);
      
      double TENKANSEN_0 = _ichimoku.GetTenkanSen(period);
      double KIJUNSEN_0 = _ichimoku.GetKijunSen(period);
      
      return TENKANSEN_0 == KIJUNSEN_0;
   }
};

class DownCondition : public ACondition
{
   RenkoStream* _renko;
   IchimokuStream* _ichimoku;
public:
   DownCondition(const string symbol, ENUM_TIMEFRAMES timeframe, RenkoStream* renko, IchimokuStream* ichimoku)
      :ACondition(symbol, timeframe)
   {
      _renko = renko;
      _renko.AddRef();
      _ichimoku = ichimoku;
      _ichimoku.AddRef();
   }

   ~DownCondition()
   {
      _renko.Release();
      _ichimoku.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      _renko.Refresh();
      _ichimoku.Calculate(period);
      _ichimoku.Calculate(period + 1);

      double TENKANSEN_0 = _ichimoku.GetTenkanSen(period);
      double KIJUNSEN_0 = _ichimoku.GetKijunSen(period);
      double TENKANSEN_1 = _ichimoku.GetTenkanSen(period + 1);
      double KIJUNSEN_1 = _ichimoku.GetKijunSen(period + 1);
      
      return TENKANSEN_0 < KIJUNSEN_0 && TENKANSEN_1 >= KIJUNSEN_1;
   }
};

// Dashboard v.1.2
class Iterator
{
   int _initialValue; int _shift; int _current;
public:
   Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
   int GetNext() { _current += _shift; return _current; }
};

// Empty cell v1.0

// Interface for a cell v1.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw() = 0;
   virtual void HandleButtonClicks() = 0;
protected:
   void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
   { 
      ObjectDelete(nm); 
      ObjectCreate(nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSet(nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSet(nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSet(nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSet(nm, OBJPROP_BACK, false); 
      ObjectSetText(nm, LabelTexto, FSize, Font, LabelColor);
   }
};

#endif

#ifndef EmptyCell_IMP
#define EmptyCell_IMP

class EmptyCell : public ICell
{
public:
   virtual void Draw() { }
   virtual void HandleButtonClicks() {}
};

#endif
// Label cell v1.0



#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ICell
{
   string _id;
   string _text; 
   int _x; 
   int _y;
public:
   LabelCell(const string id, const string text, const int x, const int y) 
   { 
      _id = id; 
      _text = text; 
      _x = x; 
      _y = y; 
   } 
   virtual void Draw() 
   { 
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, 1, WindowNumber, "Arial", font_size); 
   }

   virtual void HandleButtonClicks()
   {
      
   }
};

#endif
// Grid v1.0

// Row v1.0

#ifndef Row_IMP
#define Row_IMP

class Row
{
   ICell *_cells[];
public:
   ~Row() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         delete _cells[i]; 
      } 
   }

   void Draw() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].Draw(); 
      } 
   }

   void HandleButtonClicks() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].HandleButtonClicks(); 
      } 
   }

   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};

#endif

#ifndef Grid_IMP
#define Grid_IMP

class Grid
{
   Row *_rows[];
public:
   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   Row *AddRow()
   {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
   }
   
   Row *GetRow(const int index)
   {
      return _rows[index];
   }
   
   void Draw()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Draw();
      }
   }

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
      }
   }
};

#endif
// Trend value cell factory v1.1

// Interface for a cell factory v1.0



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
   virtual string GetHeader() = 0;
};

#endif

// Fixed text and color formatter v1.0

// Abstract value formatter v1.0

// Interface for a value formatter v1.0

#ifndef IValueFormatter_IMP
#define IValueFormatter_IMP

class IValueFormatter
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual string FormatItem(const int period, const datetime date, color& clr) = 0;
};

#endif

#ifndef AValueFormatter_IMP
#define AValueFormatter_IMP

class AValueFormatter : public IValueFormatter
{
   int _references;
public:
   AValueFormatter()
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
};

#endif

#ifndef FixedTextFormatter_IMP
#define FixedTextFormatter_IMP
class FixedTextFormatter : public AValueFormatter
{
   string _text;
   color _clr;
public:
   FixedTextFormatter(string text, color clr)
   {
      _text = text;
      _clr = clr;
   }

   virtual string FormatItem(const int period, const datetime date, color& clr)
   {
      clr = _clr;
      return _text;
   }
};
#endif

// Trend value cell v1.3

#ifndef TrendValueCell_IMP
#define TrendValueCell_IMP

#ifndef ENTER_BUY_SIGNAL
#define ENTER_BUY_SIGNAL 1
#endif
#ifndef ENTER_SELL_SIGNAL
#define ENTER_SELL_SIGNAL -1
#endif

class TrendValueCell : public ICell
{
   string _id;
   int _x;
   int _y;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
   ICondition* _conditions[];
   IValueFormatter* _valueFormatters[];
   IValueFormatter* _signalFormatters[];
   Signaler* _signaler;
   datetime _lastSignalDate;
   int _lastSignal;
   int _alertShift;
   IValueFormatter* _defaultValue;
public:
   TrendValueCell(const string id, const int x, const int y, const string symbol, 
      const ENUM_TIMEFRAMES timeframe, int alertShift, 
      IValueFormatter* defaultValue)
   { 
      _lastSignal = 0;
      _alertShift = alertShift;
      _signaler = new Signaler(symbol, timeframe);
      _signaler.SetMessagePrefix(symbol + "/" + _signaler.GetTimeframeStr() + ": ");
      _id = id; 
      _x = x; 
      _y = y; 
      _symbol = symbol;
      _timeframe = timeframe;
      _defaultValue = defaultValue;
      _defaultValue.AddRef();
   }

   ~TrendValueCell()
   {
      delete _signaler;
      _defaultValue.Release();
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         _conditions[i].Release();
         _valueFormatters[i].Release();
         if (_signalFormatters[i] != NULL)
         {
            _signalFormatters[i].Release();
         }
      }
      ArrayResize(_conditions, 0);
      ArrayResize(_valueFormatters, 0);
      ArrayResize(_signalFormatters, 0);
   }

   void AddCondition(ICondition* condition, IValueFormatter* value, IValueFormatter* signal)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      ArrayResize(_valueFormatters, size + 1);
      ArrayResize(_signalFormatters, size + 1);
      _conditions[size] = condition;
      condition.AddRef();
      _valueFormatters[size] = value;
      value.AddRef();
      _signalFormatters[size] = signal;
      if (signal != NULL)
      {
         signal.AddRef();
      }
   }

   virtual void HandleButtonClicks()
   {
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         string id = _id + "B";
         if (ObjectGetInteger(0, id, OBJPROP_STATE))
         {
            ObjectSetInteger(0, id, OBJPROP_STATE, false);
            ChartOpen(_symbol, _timeframe);
         }
      }
   }

   virtual void Draw()
   {
      datetime date = iTime(_symbol, _timeframe, _alertShift);
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         if (_conditions[i].IsPass(_alertShift, date))
         {
            color clr;
            string text = _valueFormatters[i].FormatItem(_alertShift, date, clr);
            DrawItem(text, clr, TimeCurrent() - _lastSignalDate >= expiration_min * 60);
            if (_signalFormatters[i] != NULL)
            {
               text = _signalFormatters[i].FormatItem(_alertShift, date, clr);
               SendAlert(text, i);
            }
            return;
         }
      }
      for (int i = _alertShift + 1; i < 1000; ++i)
      {
         date = iTime(_symbol, _timeframe, i);
         for (int ii = 0; ii < ArraySize(_conditions); ++ii)
         {
            if (_conditions[ii].IsPass(i, date))
            {
               color clr;
               string text = _valueFormatters[ii].FormatItem(_alertShift, date, clr);
               DrawItem(text, clr, true);
               return;
            }
         }
      }
   }

private:
   void DrawItem(string text, color clr, bool simpleLabel)
   {
      string id = _id + "B";
      if (simpleLabel)
      {
         ObjectDelete(id);
         ObjectMakeLabel(id, _x, _y, text, clr, 1, WindowNumber, "Arial", font_size); 
      }
      else
      {
         ObjectDelete(id);
         if (ObjectFind(id) < 0)
         {
            ObjectCreate(id, OBJ_BUTTON, WindowNumber, 0, 0);
         }
         ObjectSet(id, OBJPROP_XDISTANCE, _x);
         ObjectSet(id, OBJPROP_YDISTANCE, _y);
         ObjectSet(id, OBJPROP_CORNER, 1); 
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetString(0, id, OBJPROP_TEXT, text);
         ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, font_size);
         TextSetFont("Arial", -font_size * 10);
         int width, height;
         TextGetSize(text, width, height);
         ObjectSetInteger(0, id, OBJPROP_XSIZE, width + 5);
         ObjectSetInteger(0, id, OBJPROP_YSIZE, height + 5);
      }
   }

   void SendAlert(string text, int direction)
   {
      if (iTime(_symbol, _timeframe, 0) != _lastSignalDate && _lastSignal != direction)
      {
         _signaler.SendNotifications(text);
         _lastSignalDate = iTime(_symbol, _timeframe, 0);
         _lastSignal = direction;
      }
   }
};
#endif

#ifndef TrendValueCellFactory_IMP
#define TrendValueCellFactory_IMP

class TrendValueCellFactory : public ICellFactory
{
   int _alertShift;
public:
   TrendValueCellFactory(int alertShift = 0)
   {
      _alertShift = alertShift;
   }

   virtual string GetHeader()
   {
      return "Cross";
   }

   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", Neutral_Color);
      TrendValueCell* cell = new TrendValueCell(id, x, y, symbol, timeframe, _alertShift, defaultValue);
      defaultValue.Release();

      RenkoStream* renko = new RenkoStream(symbol, timeframe, 100);
      renko.SetStep(renko_mode, renko_step);
      IchimokuStream* ichimoku = new IchimokuStream(Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, renko);

      ICondition* upCondition = new UpCondition(symbol, timeframe, renko, ichimoku);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", Up_Color);
      cell.AddCondition(upCondition, upValue, cross_alarm ? upValue : NULL);
      upCondition.Release();
      upValue.Release();

      ICondition* downCondition = new DownCondition(symbol, timeframe, renko, ichimoku);
      IValueFormatter* downValue = new FixedTextFormatter("Sell", Dn_Color);
      cell.AddCondition(downCondition, downValue, cross_alarm ? downValue : NULL);
      downCondition.Release();
      downValue.Release();

      ICondition* rcCondition = new RoadCrossCondition(symbol, timeframe, renko, ichimoku);
      IValueFormatter* rcValue = new FixedTextFormatter("RC", Neutral_Color);
      IValueFormatter* rcSignal = road_cross ? new FixedTextFormatter("Road Cross", Neutral_Color) : NULL;
      cell.AddCondition(rcCondition, rcValue, rcSignal);
      rcCondition.Release();
      rcValue.Release();
      if (rcSignal != NULL)
      {
         rcSignal.Release();
      }

      return cell;
   }
};

string GetIchimokuStreamName(int streamIndex)
{
   switch (streamIndex)
   {
      case MODE_TENKANSEN:
         return "Tenkan-sen";
      case MODE_KIJUNSEN:
         return "Kijun-sen";
      case MODE_SENKOUSPANA:
         return "Senkou Span A";
      case MODE_SENKOUSPANB:
         return "Senkou Span B";
      case MODE_CHIKOUSPAN:
         return "Chikou Span";
   }
   return "";
}

class IchimokeStreamAboveIchimokuStreamCondition : public ACondition
{
   int _tenkanSen;
   int _kijunSen;
   int _senkoiSpanB;
   int _firstStreamIndex;
   int _firstStreamPeriodShift;
   int _secondStreamIndex;
   int _secondStreamPeriodShift;
public:
   IchimokeStreamAboveIchimokuStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      int firstStreamIndex, 
      int secondStreamIndex,
      int firstStreamPeriodShift = 0,
      int secondStreamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _firstStreamPeriodShift = firstStreamPeriodShift;
      _secondStreamPeriodShift = secondStreamPeriodShift;
      _firstStreamIndex = firstStreamIndex;
      _secondStreamIndex = secondStreamIndex;
      _tenkanSen = tenkanSen;
      _kijunSen = kijunSen;
      _senkoiSpanB = senkoiSpanB;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return GetIchimokuStreamName(_firstStreamIndex) + " > " + GetIchimokuStreamName(_secondStreamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double value1 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _firstStreamIndex, period + _firstStreamPeriodShift);
      double value2 = iIchimoku(_symbol, _timeframe, _tenkanSen, _kijunSen, _senkoiSpanB, _secondStreamIndex, period + _secondStreamPeriodShift);
      return value1 > value2;
   }
};

class KumoTrendValueCellFactory : public ICellFactory
{
   int _alertShift;
public:
   KumoTrendValueCellFactory(int alertShift = 0)
   {
      _alertShift = alertShift;
   }

   virtual string GetHeader()
   {
      return "Kumo";
   }

   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", Neutral_Color);
      TrendValueCell* cell = new TrendValueCell(id, x, y, symbol, timeframe, _alertShift, defaultValue);
      defaultValue.Release();

      ICondition* upCondition = new IchimokeStreamAboveIchimokuStreamCondition(symbol, timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 
         MODE_SENKOUSPANA, MODE_SENKOUSPANB, -Kijun_Sen_Period, -Kijun_Sen_Period);
      IValueFormatter* upValue = new FixedTextFormatter("Up", Blue);
      IValueFormatter* upSignal = kumo_switches ? new FixedTextFormatter("Kumo UP", Blue) : NULL;
      cell.AddCondition(upCondition, upValue, upSignal);
      upCondition.Release();
      upValue.Release();
      if (upSignal != NULL)
      {
         upSignal.Release();
      }

      ICondition* downCondition = new IchimokeStreamAboveIchimokuStreamCondition(symbol, timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 
         MODE_SENKOUSPANB, MODE_SENKOUSPANA, -Kijun_Sen_Period, -Kijun_Sen_Period);
      IValueFormatter* downValue = new FixedTextFormatter("Down", Yellow);
      IValueFormatter* downSignal = kumo_switches ? new FixedTextFormatter("Kumo DOWN", Yellow) : NULL;
      cell.AddCondition(downCondition, downValue, downSignal);
      downCondition.Release();
      downValue.Release();
      if (downSignal != NULL)
      {
         downSignal.Release();
      }

      return cell;
   }
};
#endif

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

Grid *grid;

// Grid builder v2.0



#ifndef GridBuilder_IMP
#define GridBuilder_IMP

class GridBuilder
{
   string _symbols[];
   int _symbolsCount;
   Grid *grid;
   int _originalX;
   int _originalY;
   Iterator _xIterator;
   Iterator _yIterator;
   bool _verticalMode;
   int _cellHeight;
   int _headerHeight;
   ICellFactory* _cellFactory[];
public:
   GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode)
      :_xIterator(x, -cell_width), _yIterator(y, cellHeight)
   {
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
      _verticalMode = verticalMode;
      _originalY = y;
      _originalX = x;
      grid = new Grid();
   }

   ~GridBuilder()
   {
      for (int i = 0; i < ArraySize(_cellFactory); ++i)
      {
         delete _cellFactory[i];
      }
      ArrayResize(_cellFactory, 0);
   }

   void AddCell(ICellFactory* cellFactory)
   {
      int size = ArraySize(_cellFactory);
      ArrayResize(_cellFactory, size + 1);
      _cellFactory[size] = cellFactory;
   }

   void SetSymbols(const string symbols)
   {
      StringSplit(symbols, ',', _symbols);
      _symbolsCount = ArraySize(_symbols);

      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         Iterator yIterator(_originalY, _cellHeight);
         if (cellFactorySize > 1)
         {
            yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _originalX + cell_width, yIterator.GetNext()));
         }
      }
      else
      {
         //TODO: add support of multiple values
         Iterator xIterator(_originalX - cell_width, -cell_width);
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], xIterator.GetNext(), _originalY - _headerHeight));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         int x[];
         ArrayResize(x, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            x[ii] = _xIterator.GetNext();
         }

         Row* column[];
         ArrayResize(column, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            column[ii] = grid.AddRow();
            if (ii > 0)
            {
               column[ii].Add(new EmptyCell());
            }
            else
            {
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_h", label, x[0], _headerHeight));
            }
         }
         
         Iterator yIterator(_originalY, _cellHeight);
         if (cellFactorySize > 1)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string index = IntegerToString(ii + 1);
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_sh" + index, _cellFactory[ii].GetHeader(), x[ii], y));
            }
         }

         for (int i = 0; i < _symbolsCount; i++)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string id = IndicatorObjPrefix + _symbols[i] + "_" + label + IntegerToString(ii);
               column[ii].Add(_cellFactory[ii].Create(id, x[ii], y, _symbols[i], timeframe));
            }
         }
      }
      else
      {
         //TODO: add support of multiple values
         int y[];
         ArrayResize(y, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            y[ii] = _yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y[0]));
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            int x = xIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               row.Add(_cellFactory[ii].Create(id, x, y[ii], _symbols[i], timeframe));
            }
         }
      }
   }

   Grid* Build()
   {
      return grid;
   }
};
#endif

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   grid.HandleButtonClicks();
}

// void handleButtonClicks()
// {
//    int pair_num = ArraySize(pairs) - 1;
//    for (int p = 0; p < pair_num; p++)
//    {
//       string pair = pairs[p];
//       for (int t = 0; t < ArraySize(iTF); t++)
//       {  
//          if (!bTF[t])
//             continue;
      
//          string arrow_id = Pref + "AO direction " + pair + " " + sTF[t];
//          if (ObjectGetInteger(0, arrow_id, OBJPROP_STATE))
//          {
//             ObjectSetInteger(0, arrow_id, OBJPROP_STATE, false);
//             ChartSetSymbolPeriod(0, pair, iTF[t]);
//             return;
//          }
//       }
//       string symbolId = "ADR " + pair;
//       if (ObjectGetInteger(0, symbolId, OBJPROP_STATE))
//       {
//          ObjectSetInteger(0, symbolId, OBJPROP_STATE, false);
//          ChartOpen(pair, _Period);
//          return;
//       }
//    }
// }

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   IndicatorName = GenerateIndicatorName("Renko Ichimoku Scanner");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   GridBuilder builder(x_shift, 50, cell_height, cell_height, display_mode == Vertical);
   builder.AddCell(new TrendValueCellFactory(alert_on_close ? 1 : 0));
   builder.AddCell(new KumoTrendValueCellFactory(alert_on_close ? 1 : 0));
   builder.SetSymbols(Pairs);

   if (Include_M1)
      builder.AddTimeframe("M1", PERIOD_M1);
   if (Include_M5)
      builder.AddTimeframe("M5", PERIOD_M5);
   if (Include_M15)
      builder.AddTimeframe("M15", PERIOD_M15);
   if (Include_M30)
      builder.AddTimeframe("M30", PERIOD_M30);
   if (Include_H1)
      builder.AddTimeframe("H1", PERIOD_H1);
   if (Include_H4)
      builder.AddTimeframe("H4", PERIOD_H4);
   if (Include_D1)
      builder.AddTimeframe("D1", PERIOD_D1);
   if (Include_W1)
      builder.AddTimeframe("W1", PERIOD_W1);
   if (Include_MN1)
      builder.AddTimeframe("MN1", PERIOD_MN1);

   grid = builder.Build();

   //ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete grid;
   grid = NULL;
   return 0;
}

int start()
{
   //handleButtonClicks();
   WindowNumber = MathMax(0, WindowFind(IndicatorName));
   grid.HandleButtonClicks();
   grid.Draw();
   
   return 0;
}
