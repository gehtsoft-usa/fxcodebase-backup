// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68811

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
#property version   "1.1"
#property strict

#property indicator_chart_window
#property indicator_buffers 12
#property indicator_color1 Blue
#property indicator_color2 LightBlue
#property indicator_color3 Pink
#property indicator_color4 Red

input int mva_period = 7; // SMA period
input double sf = 1; // Scaling factor
input double asf = 90; // Scaling factor %avg
input int loopback_period = 100; // Loopback periods
input int max_peaks = 3; // Max peaks
input int min_peaks = 3; // Min peaks
input bool manual_max_ob = false; // Manual Max.OB
input double max_ob_val = 0; // Max.OB Value
input bool manual_avg_ob = false; // Manual %Avg.OB
input double avg_ob_val = 0; // %Avg.OB Value
input bool manual_avg_os = false; // Manual %Avg.OS
input double avg_os_val = 0; // %Avg.OS Value
input bool manual_max_os = false; // Manual Max.OS
input double max_os_val = 0; // Max.OS Value

enum DisplayType
{
   Arrows, // Arrows
   Candles // Candles Color
};
input double pips = 20; // Pips for the alert
input DisplayType Type = Arrows; // Presentation Type
input color up_color = Green; // Up color
input color down_color = Red; // Down color

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

double max_ob[], max_os[], avg_ob[], avg_os[], ddpo[];

// ICondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
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

// ABaseCondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

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
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};
// Abstract stream v1.0
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
};
#define AStream_IMP
#endif
// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

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
// Condition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IConditionFactory
{
public:
   virtual ICondition *CreateCondition(const int order) = 0;
};

class LongCondition : public ABaseCondition
{
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      //TODO: implement
      return false;
   }
};

class ShortCondition : public ABaseCondition
{
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      //TODO: implement
      return false;
   }
};

class ExitLongCondition : public ABaseCondition
{
public:
   ExitLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period)
   {
      //TODO: implement
      return false;
   }
};

class ExitShortCondition : public ABaseCondition
{
public:
   ExitShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period)
   {
      //TODO: implement
      return false;
   }
};

class DisabledCondition : public ICondition
{
public:
   bool IsPass(const int period) { return false; }
};

class OrCondition : public ICondition
{
   ICondition *_conditions[];
public:
   ~OrCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         delete _conditions[i];
      }
   }

   void Add(ICondition *condition)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
   }

   virtual bool IsPass(const int period)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (_conditions[i].IsPass(period))
            return true;
      }
      return false;
   }
};
//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = false; // Popup message
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

// int OnInit()
// {
//    if (!IsDllsAllowed() && advanced_alert)
//    {
//       Print("Error: Dll calls must be allowed!");
//       return INIT_FAILED;
//    }
// }
// Alert signal v.2.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AlertSignal_IMP
#define AlertSignal_IMP

// Candles stream v.1.2
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

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

class AlertSignal
{
   double _signals[];
   ICondition* _condition;
   IStream* _price;
   Signaler* _signaler;
   string _message;
   datetime _lastSignal;
   CandleStreams* _candleStreams;
public:
   AlertSignal(ICondition* condition, Signaler* signaler)
   {
      _condition = condition;
      _price = NULL;
      _candleStreams = NULL;
      _signaler = signaler;
   }

   ~AlertSignal()
   {
      if (_price != NULL)
         _price.Release();
      if (_candleStreams != NULL)
         delete _candleStreams;
      delete _condition;
   }

   int RegisterStreams(int id, string name, int code, color clr, IStream* price)
   {
      _message = name;
      _price = price;
      _price.AddRef();
      SetIndexStyle(id + 0, DRAW_ARROW, 0, 2, clr);
      SetIndexBuffer(id + 0, _signals);
      SetIndexLabel(id + 0, name);
      SetIndexArrow(id + 0, code);
      
      return id + 1;
   }

   int RegisterStreams(int id, string name, color clr)
   {
      _message = name;
      _candleStreams = new CandleStreams();
      return _candleStreams.RegisterStreams(id, clr);
   }

   void Update(int period)
   {
      if (!_condition.IsPass(period))
      {
         if (_candleStreams != NULL)
            _candleStreams.Clear(period);
         else
            _signals[period] = EMPTY_VALUE;
         return;
      }

      if (period == 0)
      {
         string symbol = _signaler.GetSymbol();
         datetime dt = iTime(symbol, _signaler.GetTimeframe(), 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
            _lastSignal = dt;
         }
      }

      if (_candleStreams != NULL)
      {
         _candleStreams.Set(period, Open[period], High[period], Low[period], Close[period]);
         return;
      }
      double price;
      if (!_price.GetValue(period, price))
         return;

      _signals[period] = price;
   }
};

#endif


AlertSignal* up;
AlertSignal* down;
Signaler* mainSignaler;

class UpAlertCondition : public ABaseCondition
{
public:
   UpAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return MathAbs(max_ob[period] - avg_ob[period]) / _instrument.GetPipSize() < pips;
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
      return MathAbs(max_os[period] - avg_os[period]) / _instrument.GetPipSize() < pips;
   }
};

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("DDPO OBOS Price Projection Band");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(13);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, max_ob);
   SetIndexLabel(0, "Max.OB");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, avg_ob);
   SetIndexLabel(1, "%Avg.OB");
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, avg_os);
   SetIndexLabel(2, "%Avg.OS");
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, max_os);
   SetIndexLabel(3, "Max.OS");
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, ddpo);

   ICondition* upCondition = new UpAlertCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ICondition* downCondition = new DownAlertCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   up = new AlertSignal(upCondition, mainSignaler);
   down = new AlertSignal(downCondition, mainSignaler);
      
   int id = 5;
   if (Type == Arrows)
   {
      PriceStream* highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
      PriceStream* lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
      id = up.RegisterStreams(id, "Up", 217, up_color, highStream);
      id = down.RegisterStreams(id, "Down", 218, down_color, lowStream);
      lowStream.Release();
      highStream.Release();
   }
   else
   {
      id = up.RegisterStreams(id, "Up", up_color);
      id = down.RegisterStreams(id, "Down", down_color);
   }
   
   return 0;
}

int deinit()
{
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
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      double maValue = iMA(_Symbol, _Period, mva_period, 0, MODE_SMA, PRICE_CLOSE, pos);
      ddpo[pos] = sf * (Close[pos] - maValue);
      if (Bars < pos + loopback_period + 1)
         continue;
      double ob = 0;
      double os = 0;
      double levels[];
      for (int i = 0; i < loopback_period; ++i)
      {
         if (ob == 0 || ob < ddpo[pos + i])
            ob = ddpo[pos + i];
         if (os == 0 || os > ddpo[pos + i])
            os = ddpo[pos + i];
         if (i != 0 && IsRising(ddpo, pos + i) == IsFalling(ddpo, pos + i - 1))
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 1);
            levels[size] = ddpo[pos + i];
         }
      }
      ArraySort(levels);

      int size = ArraySize(levels);
      double summ = 0;
      for (int i = 0; i < MathMin(size, min_peaks); ++i)
      {
         summ += levels[size - i - 1];
      }
      double mva2 = iMA(_Symbol, _Period, mva_period - 1, 0, MODE_SMA, PRICE_CLOSE, pos);
      if (!manual_avg_ob)
         avg_ob[pos] = (asf / sf) * (summ / min_peaks) / 100 * (mva_period / (mva_period - 1)) + mva2;
      else
         avg_ob[pos] = (asf / sf) * avg_ob_val / 100 * (mva_period / (mva_period - 1)) + mva2;
      if (!manual_max_ob)
         max_ob[pos] = (levels[size - 1] / sf) * (mva_period / (mva_period - 1)) + mva2;
      else
         max_ob[pos] = (max_ob_val / sf) * (mva_period / (mva_period - 1)) + mva2;
      summ = 0;
      for (int i = 0; i < MathMin(size, max_peaks); ++i)
      {
         summ += levels[i];
      }
      if (!manual_avg_os)
         avg_os[pos] = (asf / sf) * (summ / max_peaks) / 100 * (mva_period / (mva_period - 1)) + mva2;
      else
         avg_os[pos] = (asf / sf) * avg_os_val / 100 * (mva_period / (mva_period - 1)) + mva2;
      if (!manual_max_os)
         max_os[pos] = (levels[0] / sf) * (mva_period / (mva_period - 1)) + mva2;
      else
         max_os[pos] = (max_os_val / sf) * (mva_period / (mva_period - 1)) + mva2;
      up.Update(pos);
      down.Update(pos);
   }

   return 0;
}

bool IsRising(double &stream[], int period)
{
   return stream[period] > stream[period + 1];
}

bool IsFalling(double &stream[], int period)
{
   return stream[period] < stream[period + 1];
}

