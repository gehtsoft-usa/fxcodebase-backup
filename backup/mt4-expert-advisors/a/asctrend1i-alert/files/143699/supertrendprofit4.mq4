// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70239
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
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 12
#property indicator_color1 DarkTurquoise
#property indicator_color2 Orange

int g_width_76 = 3;
input int SignalPeriod = 29;
int gi_84 = 0;
int g_ma_method_88 = MODE_LWMA;
int g_applied_price_92 = PRICE_CLOSE;
double gd_96 = 1.8;
bool gi_104 = TRUE;
int gi_108 = 0;
int gi_112 = 10000;
bool gi_116 = FALSE;
input int aTake_Profit = 15;
input int aStop_Loss = 15;
datetime g_time_136;
string gs_148;
string gs_156 = "Super Trend Profit";
double g_ibuf_164[];
double g_ibuf_168[];
double g_ibuf_172[];
int gi_180;
string gs_184;
string g_name_196 = "informerR";
string gs_signall_204 = "signalL";
input int SignalTextSize = 14;
input int InformerTextSize = 14;
input color BuySignalColor = DarkTurquoise;
input color SellSignalColor = Red;
enum SingalMode
{
   SingalModeLive,      // Live
   SingalModeOnBarClose // On bar close
};

enum DisplayType
{
   Arrows,            // Arrows
   ArrowsOnMainChart, // Arrows on main chart
   Candles            // Candles color
};
input SingalMode signal_mode = SingalModeLive; // Signal mode
input DisplayType Type = Arrows;               // Presentation Type
input double shift_arrows_pips = 0.1;          // Shift arrows
input color up_color = Blue;                   // Up color
input color down_color = Red;                  // Down color

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
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe, string name = "")
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
// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
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
//Signaler v2.0
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
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

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
         AdvancedAlert(advanced_key, message, "", "");
   }
};

// Alert signal v3.1
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
      SetIndexEmptyValue(id, EMPTY_VALUE);
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
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   AlertSignal(ICondition* condition, IAction* actionOnCondition, string symbol, ENUM_TIMEFRAMES timeframe, Signaler* signaler, bool onBarClose = false)
   {
      _symbol = symbol;
      _timeframe = timeframe;
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
      datetime dt = iTime(_symbol, _timeframe, _onBarClose ? period + 1 : period);

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
         dt = iTime(_symbol, _timeframe, 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(_message);
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

AlertSignal *conditions[];
Signaler *mainSignaler;
StreamWrapper *customStream;

int CreateAlert(int id, ICondition *upCondition, IAction *upAction, ICondition *downCondition, IAction *downAction, int upCode, int downCode)
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 2);
   conditions[size] = new AlertSignal(upCondition, upAction, _Symbol, (ENUM_TIMEFRAMES)_Period, mainSignaler, signal_mode == SingalModeOnBarClose);
   conditions[size + 1] = new AlertSignal(downCondition, downAction, _Symbol, (ENUM_TIMEFRAMES)_Period, mainSignaler, signal_mode == SingalModeOnBarClose);

   switch (Type)
   {
   case Arrows:
   {
      id = conditions[size].RegisterStreams(id, "Up", upCode, up_color, customStream);
      id = conditions[size + 1].RegisterStreams(id, "Down", downCode, down_color, customStream);
   }
   break;
   case ArrowsOnMainChart:
   {
      PriceStream *highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
      highStream.SetShift(shift_arrows_pips);
      PriceStream *lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
      lowStream.SetShift(-shift_arrows_pips);
      id = conditions[size].RegisterArrows(id, "Up", IndicatorObjPrefix + "_up", upCode, up_color, highStream);
      id = conditions[size + 1].RegisterArrows(id, "Down", IndicatorObjPrefix + "_down", downCode, down_color, lowStream);
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

class UpCondition : public ACondition
{
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
       : ACondition(symbol, timeframe)
   {
   }

   bool IsPass(const int period, const datetime date)
   {
      return (gi_116 == FALSE && g_ibuf_164[period] != EMPTY_VALUE && g_ibuf_164[period + 1] == EMPTY_VALUE) 
         || (gi_116 == TRUE && g_ibuf_164[period] != EMPTY_VALUE && g_ibuf_164[period + 1] != EMPTY_VALUE && g_ibuf_164[period + 2] == EMPTY_VALUE);
   }
};

class DownCondition : public ACondition
{
public:
   DownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
       : ACondition(symbol, timeframe)
   {
   }

   bool IsPass(const int period, const datetime date)
   {
      return (gi_116 == FALSE && g_ibuf_172[period] != EMPTY_VALUE && g_ibuf_172[period + 1] == EMPTY_VALUE) 
         || (gi_116 == TRUE && g_ibuf_172[period] != EMPTY_VALUE && g_ibuf_172[period + 1] != EMPTY_VALUE && g_ibuf_172[period + 2] == EMPTY_VALUE);
   }
};

// Colored stream v3.2

class ColoredStreamData
{
public:
   double Stream[];
};

class ColoredStream : public AStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         ArrayInitialize(_streams[i].Stream, defaultValue);
      }
      ArrayInitialize(_data, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data);
      SetIndexStyle(id + 0, DRAW_NONE);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      SetIndexStyle(id, lineType, lineStyle, width, clr);
      SetIndexBuffer(id, _streams[size].Stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      if (label != "")
         SetIndexLabel(id, label);
      return id + 1;
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Stream[period] != EMPTY_VALUE)
            return i;
      }
      return -1;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (period + 1 < iBars(_symbol, _timeframe) && _streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
      }
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= iBars(_symbol, _timeframe))
      {
         return false;
      }
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

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

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
   case PERIOD_M1:
      return "M1";
   case PERIOD_M5:
      return "M5";
   case PERIOD_D1:
      return "D1";
   case PERIOD_H1:
      return "H1";
   case PERIOD_H4:
      return "H4";
   case PERIOD_M15:
      return "M15";
   case PERIOD_M30:
      return "M30";
   case PERIOD_MN1:
      return "MN1";
   case PERIOD_W1:
      return "W1";
   }
   return "";
}
string f0_4()
{
   string timeframe_4;
   switch (Period())
   {
   case PERIOD_M1:
      timeframe_4 = "M1";
      break;
   case PERIOD_M5:
      timeframe_4 = "M5";
      break;
   case PERIOD_M15:
      timeframe_4 = "M15";
      break;
   case PERIOD_M30:
      timeframe_4 = "M30";
      break;
   case PERIOD_H1:
      timeframe_4 = "H1";
      break;
   case PERIOD_H4:
      timeframe_4 = "H4";
      break;
   case PERIOD_D1:
      timeframe_4 = "D1";
      break;
   case PERIOD_W1:
      timeframe_4 = "W1";
      break;
   case PERIOD_MN1:
      timeframe_4 = "MN1";
      break;
   default:
      timeframe_4 = Period();
   }
   return (timeframe_4);
}

ColoredStream* out;

int init()
{
   IndicatorBuffers(14);
   SetIndexBuffer(0, g_ibuf_164);
   SetIndexBuffer(1, g_ibuf_168);
   SetIndexBuffer(2, g_ibuf_172);
   if (gi_104)
   {
      SetIndexStyle(0, DRAW_NONE, EMPTY, g_width_76 - 1);
      SetIndexStyle(1, DRAW_NONE, EMPTY, g_width_76 - 1);
      SetIndexStyle(2, DRAW_NONE, EMPTY, g_width_76 - 1);
      SetIndexArrow(0, 159);
      SetIndexArrow(1, 159);
      SetIndexArrow(2, 159);
   }
   else
   {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
      SetIndexStyle(2, DRAW_NONE);
   }
   gi_180 = SignalPeriod + MathFloor(MathSqrt(SignalPeriod));
   SetIndexDrawBegin(0, gi_180);
   SetIndexDrawBegin(1, gi_180);
   SetIndexDrawBegin(2, gi_180);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS) + 1.0);
   SetIndexLabel(0, "Super Trend Profit");
   gs_184 = Symbol() + " (" + f0_4() + "):  ";
   gs_148 = "";
   ArrayInitialize(g_ibuf_164, EMPTY_VALUE);
   ArrayInitialize(g_ibuf_172, EMPTY_VALUE);
   ArrayInitialize(g_ibuf_168, EMPTY_VALUE);

   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorObjPrefix = GenerateIndicatorPrefix("stp");
   IndicatorShortName("Super Trend Profit(" + SignalPeriod + ")");
   mainSignaler = new Signaler();
   mainSignaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");

   int id = 3;
   out = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = out.RegisterStream(id, BuySignalColor);
   id = out.RegisterStream(id, SellSignalColor);
   id = out.RegisterInternalStream(id);

   if (Type == Arrows)
   {
      customStream = new StreamWrapper(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   {
      ICondition* upCondition = (ICondition*) new UpCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
      ICondition* downCondition = (ICondition*) new DownCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
      id = CreateAlert(id, upCondition, NULL, downCondition, NULL, 217, 218);
   }
   if (customStream != NULL)
   {
      id = customStream.RegisterInternalStream(id);
   }
   return (0);
}

int deinit()
{
   out.Release();
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
   f0_7();
   ObjectsDeleteAll(0, OBJ_TEXT);
   ObjectsDeleteAll(0, OBJ_LABEL);
   return (0);
}

int start()
{
   double ima_on_arr_20;
   int ind_counted_8 = IndicatorCounted();
   int li_0 = Bars - ind_counted_8 - 2;
   for (int li_4 = li_0; li_4 >= 0; li_4--)
   {
      double val = 2.0 * iMA(NULL, 0, MathFloor(SignalPeriod / gd_96), gi_84, g_ma_method_88, g_applied_price_92, li_4) 
         - iMA(NULL, 0, SignalPeriod, gi_84, g_ma_method_88, g_applied_price_92, li_4);
      int index = out._data[li_4 + 1] > val ? 1 : 0;
      out.Set(val, li_4, index);
   }
   double ima_on_arr_12 = iMAOnArray(out._data, 0, MathFloor(MathSqrt(SignalPeriod)), 0, g_ma_method_88, 1);
   for (int li_4 = 2; li_4 < li_0 + 1; li_4++)
   {
      ima_on_arr_20 = iMAOnArray(out._data, 0, MathFloor(MathSqrt(SignalPeriod)), 0, g_ma_method_88, li_4);
      if (ima_on_arr_20 > ima_on_arr_12)
      {
         g_ibuf_172[li_4 - 1] = ima_on_arr_12 - gi_108 * Point;
      }
      else
      {
         if (ima_on_arr_20 < ima_on_arr_12)
         {
            g_ibuf_164[li_4 - 1] = ima_on_arr_12 + gi_108 * Point;
         }
         else
         {
            g_ibuf_164[li_4 - 1] = EMPTY_VALUE;
            g_ibuf_168[li_4 - 1] = ima_on_arr_12;
            g_ibuf_172[li_4 - 1] = EMPTY_VALUE;
         }
      }
      if (ind_counted_8 > 0)
      {
      }
      ima_on_arr_12 = ima_on_arr_20;
   }
   if (li_0 > gi_112)
      li_0 = gi_112;
   for (int li_4 = 2; li_4 <= li_0; li_4++)
   {
      if (g_ibuf_164[li_4 - 1] != EMPTY_VALUE)
      {
         if (g_ibuf_164[li_4] != EMPTY_VALUE)
            f0_9(li_4 - 1, li_4, 1);
         else
         {
            f0_9(li_4 - 1, li_4, 10);
            f0_2(li_4, g_ibuf_172[li_4], 0);
         }
      }
      if (g_ibuf_172[li_4 - 1] != EMPTY_VALUE)
      {
         if (g_ibuf_172[li_4] != EMPTY_VALUE)
         {
            f0_9(li_4 - 1, li_4, -1);
            continue;
         }
         f0_9(li_4 - 1, li_4, -10);
         f0_2(li_4, g_ibuf_164[li_4] + MathAbs(Close[li_4] - iSAR(NULL, 0, 0.02, 0.2, li_4)), 1);
      }
   }
   if (g_ibuf_172[1] != EMPTY_VALUE)
      f0_1(1);
   if (g_ibuf_164[1] != EMPTY_VALUE)
      f0_1(0);

   int counted_bars = IndicatorCounted();
   if (counted_bars <= 0 || counted_bars > Bars)
   {
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
   for (int pos = limit; pos >= 0 && !IsStopped(); --pos)
   {
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
   return (0);
}

double f0_8()
{
   return (Bid - aTake_Profit * Point);
}

double f0_6()
{
   return (Ask + aTake_Profit * Point);
}

double f0_0()
{
   return (Bid + aStop_Loss * Point);
}

double f0_5()
{
   return (Ask - aStop_Loss * Point);
}

int f0_3()
{
   return (10000.0 * (SignalPeriod * Point));
}

void f0_7()
{
   string name_0;
   int str_len_12;
   for (int li_8 = ObjectsTotal() - 1; li_8 >= 0; li_8--)
   {
      name_0 = ObjectName(li_8);
      str_len_12 = StringLen(gs_156);
      if (StringSubstr(name_0, 0, str_len_12) == gs_156)
         ObjectDelete(name_0);
   }
}

void f0_9(int ai_0, int ai_4, int ai_8)
{
   double price_20;
   double price_28;
   color color_36;
   if (ai_8 > 0)
   {
      price_20 = g_ibuf_164[ai_0];
      if (ai_8 == 1)
         price_28 = g_ibuf_164[ai_4];
      else
         price_28 = g_ibuf_172[ai_4];
      color_36 = DarkTurquoise;
   }
   else
   {
      price_20 = g_ibuf_172[ai_0];
      if (ai_8 == -1)
         price_28 = g_ibuf_172[ai_4];
      else
         price_28 = g_ibuf_164[ai_4];
      color_36 = Red;
   }
   int time_12 = Time[ai_0];
   int time_16 = Time[ai_4];
   if (price_20 == EMPTY_VALUE || price_28 == EMPTY_VALUE)
   {
      Print("Empty value for price line encountered!");
      return;
   }
   string name_40 = gs_156 + "_segment_" + color_36 + time_12 + "_" + time_16;
   ObjectDelete(name_40);
   ObjectCreate(name_40, OBJ_TREND, 0, time_12, price_20, time_16, price_28, 0, 0);
   ObjectSet(name_40, OBJPROP_WIDTH, g_width_76);
   ObjectSet(name_40, OBJPROP_COLOR, color_36);
   ObjectSet(name_40, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name_40, OBJPROP_RAY, FALSE);
}

void f0_2(int ai_0, double a_price_4, int ai_12)
{
   string text_16 = "BUY";
   color color_24 = BuySignalColor;
   if (ai_12 == 1)
   {
      text_16 = "SELL";
      color_24 = SellSignalColor;
   }
   int time_28 = Time[ai_0];
   string name_32 = gs_signall_204 + DoubleToStr(time_28, 0);
   if (ObjectFind(name_32) != -1)
      ObjectDelete(name_32);
   ObjectCreate(name_32, OBJ_TEXT, 0, time_28, a_price_4);
   ObjectSetText(name_32, text_16, SignalTextSize);
   ObjectSet(name_32, OBJPROP_COLOR, color_24);
}

void f0_1(int ai_0)
{
   string text_4 = "Current trend is: UP";
   string text_12 = "Current trading signal: BUY";
   color color_20 = BuySignalColor;
   if (ai_0 == 1)
   {
      text_4 = "Current trend is: DOWN";
      text_12 = "Current trading signal: SELL";
      color_20 = SellSignalColor;
   }
   if (ObjectFind(g_name_196) != -1)
      ObjectDelete(g_name_196);
   ObjectCreate(g_name_196, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(g_name_196, text_4, SignalTextSize);
   ObjectSet(g_name_196, OBJPROP_COLOR, color_20);
   ObjectSet(g_name_196, OBJPROP_XDISTANCE, 30);
   ObjectSet(g_name_196, OBJPROP_YDISTANCE, 30);
   string name_24 = g_name_196 + "LL";
   if (ObjectFind(name_24) != -1)
      ObjectDelete(name_24);
   ObjectCreate(name_24, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name_24, text_12, SignalTextSize);
   ObjectSet(name_24, OBJPROP_COLOR, color_20);
   ObjectSet(name_24, OBJPROP_XDISTANCE, 30);
   ObjectSet(name_24, OBJPROP_YDISTANCE, InformerTextSize + 35);
}
