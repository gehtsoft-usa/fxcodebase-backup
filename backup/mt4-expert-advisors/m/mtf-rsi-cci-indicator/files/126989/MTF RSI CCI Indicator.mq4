// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewforum.php?f=50

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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red

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

input bool Use_RSI = true; // Use RSI
input bool Use_REX = true; // Use REX
input bool Use_ADX = true; // Use ADX
input bool Use_HA = true; // Use HA
input ENUM_TIMEFRAMES TF1 = PERIOD_H4; // Lower Time frame
input int CCI_Period = 14; // CCI Period
input ENUM_TIMEFRAMES TF2 = PERIOD_W1; // Higher Time frame
input int RSI_Period = 14; // RSI Period
input int SP = 14; // Rex Smoothing Period
input int SS = 14; // Rex Signal Period
input int ADX_Period = 14; // ADX Period
input double ADX_Level = 25; // ADX Level
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
input int BarsLimit = 5000; // Bars limit

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

// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};


// More templates and snippets on https://github.com/sibvic/mq4-templates

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

// Alert signal v.1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

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

AlertSignal* up;
AlertSignal* down;
Signaler* mainSignaler;

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
};

class HABarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _open[];
   double _high[];
   double _low[];
   double _close[];
   int _lastCalculated;
   int _references;
public:
   HABarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _lastCalculated = 0;
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

   virtual bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      val = _close[totalBars - 1 - period];
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
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      return true;
   }

   virtual double GetHigh(const int period, double &high)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      high = _high[totalBars - 1 - period];
      return true;
   }

   virtual double GetLow(const int period, double &low)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      low = _low[totalBars - 1 - period];
      return true;
   }

   virtual double GetClose(const int period, double &close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      high = _high[totalBars - 1 - period];
      low = _low[totalBars - 1 - period];
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      high = _high[totalBars - 1 - period];
      low = _low[totalBars - 1 - period];
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      res = _open[totalBars - 1 - period] < _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      res = _open[totalBars - 1 - period] > _close[totalBars - 1 - period];
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void Refresh()
   {
      int totalBars = Size();
      if (ArrayRange(_open, 0) != totalBars)
      {
         ArrayResize(_open, totalBars);
         ArrayResize(_high, totalBars);
         ArrayResize(_low, totalBars);
         ArrayResize(_close, totalBars);
      }
      for (int i = _lastCalculated; i < totalBars; ++i)
      {
         double open = iOpen(_symbol, _timeframe, totalBars - 1 - i);
         double high = iHigh(_symbol, _timeframe, totalBars - 1 - i);
         double low = iLow(_symbol, _timeframe, totalBars - 1 - i);
         double close = iClose(_symbol, _timeframe, totalBars - 1 - i);
         _open[i] = i == 0 ? (open + close) / 2 : (_open[i - 1] + _close[i - 1]) / 2;
         _close[i] = (open + high + low + close) / 4;
         _high[i] = fmax(high, fmax(_open[i], _close[i]));
         _low[i] = fmin(low,fmin(_open[i], _close[i]));
      }
      _lastCalculated = totalBars;
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
            val = (double)iVolume(_symbol, _timeframe, period);
            break;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};

HABarStream* ha;

bool LevelConfirmation(int period, int Side)
{
   for (int i = period + 1; i < 10000; ++i)
   {
      double cciValue = iCCI(_Symbol, TF1, CCI_Period, PRICE_CLOSE, i);
      if (Side == 1 && cciValue > -100)
         return iClose(_Symbol, TF1, period) > iClose(_Symbol, TF1, i);
      if (Side == -1 && cciValue < 100)
      return iClose(_Symbol, TF1, period) < iClose(_Symbol, TF1, i);
   }
   return false;
}

class UpAlertCondition : public ABaseCondition
{
public:
   UpAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      int tf2Period = iBarShift(_symbol, TF2, Time[period]);
      if (tf2Period < 0)
         return false;
      int tf1Period = iBarShift(_symbol, TF1, Time[period]);
      if (tf1Period < 0)
         return false;

      double rsiValue = iRSI(_symbol, TF2, RSI_Period, PRICE_CLOSE, tf2Period);
      double cciValue = iCCI(_symbol, TF1, CCI_Period, PRICE_CLOSE, tf1Period);
      double cciValue1 = iCCI(_symbol, TF1, CCI_Period, PRICE_CLOSE, tf1Period + 1);
      double adxValue = iADX(_symbol, TF2, ADX_Period, PRICE_CLOSE, MODE_MAIN, tf2Period);
      double haopen, haclose;
      if (!ha.GetOpen(tf2Period, haopen) || !ha.GetClose(tf2Period, haclose))
         return false;

      double rex = iCustom(_symbol, TF2, "Rex", SP, 0, SS, 0, tf2Period);
      double signal = iCustom(_symbol, TF2, "Rex", SP, 0, SS, 1, tf2Period);

      return (rsiValue > 50 || !Use_RSI)
         && cciValue > -100 && cciValue1 <= -100 && LevelConfirmation(tf1Period, 1) 
         && (rex > signal || !Use_REX) 
         && (adxValue > ADX_Level || !Use_ADX)
         && (!Use_HA || haopen < haclose);
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
      int tf2Period = iBarShift(_symbol, TF2, Time[period]);
      if (tf2Period < 0)
         return false;
      int tf1Period = iBarShift(_symbol, TF1, Time[period]);
      if (tf1Period < 0)
         return false;

      double rsiValue = iRSI(_symbol, TF2, RSI_Period, PRICE_CLOSE, tf2Period);
      double cciValue = iCCI(_symbol, TF1, CCI_Period, PRICE_CLOSE, tf1Period);
      double cciValue1 = iCCI(_symbol, TF1, CCI_Period, PRICE_CLOSE, tf1Period + 1);
      double adxValue = iADX(_symbol, TF2, ADX_Period, PRICE_CLOSE, MODE_MAIN, tf2Period);
      double haopen, haclose;
      if (!ha.GetOpen(tf2Period, haopen) || !ha.GetClose(tf2Period, haclose))
         return false;

      double rex = iCustom(_symbol, TF2, "Rex", SP, 0, SS, 0, tf2Period);
      double signal = iCustom(_symbol, TF2, "Rex", SP, 0, SS, 1, tf2Period);
      return (rsiValue < 50 || !Use_RSI) 
         && cciValue < 100 && cciValue1 >= 100 && LevelConfirmation(tf1Period, -1) 
         && (rex < signal || !Use_REX) 
         && (adxValue > ADX_Level || !Use_ADX)
         && (!Use_HA || haopen > haclose);
   }
};

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   double temp = iCustom(NULL, 0, "Rex", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Rex' indicator");
      return INIT_FAILED;
   }

   IndicatorName = GenerateIndicatorName("MTF RSI CCI Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   PriceStream* highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   PriceStream* lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   ha = new HABarStream(_Symbol, TF2);

   int id = 0;
   up = new AlertSignal(new UpAlertCondition(_Symbol, (ENUM_TIMEFRAMES)_Period), highStream, mainSignaler);
   id = up.RegisterStreams(id, "Up", 218, Red);
   down = new AlertSignal(new DownAlertCondition(_Symbol, (ENUM_TIMEFRAMES)_Period), lowStream, mainSignaler);
   id = down.RegisterStreams(id, "Down", 217, Green);
   lowStream.Release();
   highStream.Release();

   return 0;
}

int deinit()
{
   delete ha;
   ha = NULL;
   delete mainSignaler;
   mainSignaler = NULL;
   delete up;
   up = NULL;
   delete down;
   down = NULL;
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
   int limit = MathMin(BarsLimit, ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      ha.Refresh();
      up.Update(pos);
      down.Update(pos);
   } 
   return 0;
}