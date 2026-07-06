// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68559

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
#property indicator_buffers 10
#property indicator_chart_window

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
            val = (double)iVolume(_symbol, _timeframe, period);
            break;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};

interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

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
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
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
            string symbol = _signaler.GetSymbol();
            if (period == 0 && _lastSignal != iTime(symbol, _signaler.GetTimeframe(), 0))
            {
               _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
               _lastSignal = iTime(symbol, _signaler.GetTimeframe(), 0);
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

// CUSTOM LOGIC

input int K = 5; // K Period
input int SD = 3; // SD Period
input int D = 3; // D period
input int overbought = 80; // OB Level
input int oversold = 20; // OS Level
input bool k_d_alert = true; // Show K/D Alert
input bool k_ob_alert = false; // Show K/overbought Alert
input bool k_os_alert = false; // Show K/oversold Alert
input bool d_ob_alert = false; // Show D/overbought Alert
input bool d_os_alert = false; // Show D/oversold Alert
//Signaler v 1.7
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

class KDDownAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double kValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period);
      double dValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period);
      double kValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period + 1);
      double dValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period + 1);
      return kValue_0 < dValue_0 && kValue_1 >= dValue_1;
   }
};

class KDUpAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double kValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period);
      double dValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period);
      double kValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period + 1);
      double dValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period + 1);
      return kValue_0 > dValue_0 && kValue_1 <= dValue_1;
   }
};

class KOBDownAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double kValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period);
      double kValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period + 1);
      return kValue_0 > overbought && kValue_1 <= overbought;
   }
};

class KOBUpAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double kValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period);
      double kValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period + 1);
      return kValue_0 < overbought && kValue_1 >= overbought;
   }
};

class KOSDownAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double kValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period);
      double kValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period + 1);
      return kValue_0 > oversold && kValue_1 <= oversold;
   }
};

class KOSUpAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double kValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period);
      double kValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, period + 1);
      return kValue_0 < oversold && kValue_1 >= oversold; 
   }
};

class DOBDownAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double dValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period);
      double dValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period + 1);
      return dValue_0 < overbought && dValue_1 >= overbought;
   }
};

class DOBUpAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double dValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period);
      double dValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period + 1);
      return dValue_0 > overbought && dValue_1 <= overbought;
   }
};

class DOSDownAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double dValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period);
      double dValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period + 1);
      return dValue_0 < oversold && dValue_1 >= oversold;
   }
};

class DOSUpAlertCondition : public ICondition
{
public:
   virtual bool IsPass(const int period)
   {
      double dValue_0 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period);
      double dValue_1 = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, period + 1);
      return dValue_0 > oversold && dValue_1 <= oversold;
   }
};

AlertSignal* signals[];
Signaler* signaler1;

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   signaler1 = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   IndicatorName = GenerateIndicatorName("Slow stochastic with alert");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   PriceStream* highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
   PriceStream* lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
   int id = 0;
   if (k_d_alert)
   {
      int size = ArraySize(signals);
      ArrayResize(signals, size + 2);
      signals[size] = new AlertSignal(new KDDownAlertCondition(), highStream, signaler1);
      id = signals[size].RegisterStreams(id, "K/D Down", 218, Red);
      signals[size + 1] = new AlertSignal(new KDUpAlertCondition(), lowStream, signaler1);
      id = signals[size + 1].RegisterStreams(id, "K/D Up", 217, Green);
   }
   if (k_ob_alert)
   {
      int size = ArraySize(signals);
      ArrayResize(signals, size + 2);
      signals[size] = new AlertSignal(new KOBDownAlertCondition(), highStream, signaler1);
      id = signals[size].RegisterStreams(id, "K/OB Down", 218, Red);
      signals[size + 1] = new AlertSignal(new KOBUpAlertCondition(), lowStream, signaler1);
      id = signals[size + 1].RegisterStreams(id, "K/OB Up", 217, Green);
   }
   if (k_os_alert)
   {
      int size = ArraySize(signals);
      ArrayResize(signals, size + 2);
      signals[size] = new AlertSignal(new KOSDownAlertCondition(), highStream, signaler1);
      id = signals[size].RegisterStreams(id, "K/OS Down", 218, Red);
      signals[size + 1] = new AlertSignal(new KOSUpAlertCondition(), lowStream, signaler1);
      id = signals[size + 1].RegisterStreams(id, "K/OS Up", 217, Green);
   }
   if (d_ob_alert)
   {
      int size = ArraySize(signals);
      ArrayResize(signals, size + 2);
      signals[size] = new AlertSignal(new DOBDownAlertCondition(), highStream, signaler1);
      id = signals[size].RegisterStreams(id, "D/OB Down", 218, Red);
      signals[size + 1] = new AlertSignal(new DOBUpAlertCondition(), lowStream, signaler1);
      id = signals[size + 1].RegisterStreams(id, "D/OB Up", 217, Green);
   }
   if (d_os_alert)
   {
      int size = ArraySize(signals);
      ArrayResize(signals, size + 2);
      signals[size] = new AlertSignal(new DOSDownAlertCondition(), highStream, signaler1);
      id = signals[size].RegisterStreams(id, "D/OS Down", 218, Red);
      signals[size + 1] = new AlertSignal(new DOSUpAlertCondition(), lowStream, signaler1);
      id = signals[size + 1].RegisterStreams(id, "D/OS Up", 217, Green);
   }

   lowStream.Release();
   highStream.Release();

   return 0;
}

int deinit()
{
   delete signaler1;
   for (int i = 0; i < ArraySize(signals); ++i)
   {
      AlertSignal* item = signals[i];
      delete item;
   }
   ArrayResize(signals, 0);
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
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      for (int i = 0; i < ArraySize(signals); ++i)
      {
         AlertSignal* item = signals[i];
         item.Update(pos);
      }
   } 
   return 0;
}