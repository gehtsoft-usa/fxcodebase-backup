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
#property indicator_buffers 14
#property indicator_color1 LimeGreen
#property indicator_color2 Orange
#property indicator_color3 Orange
#property indicator_color5 clrDodgerBlue
#property indicator_color6 clrDodgerBlue
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width5 2
#property indicator_width6 2

enum maTypes
{
   ma_sma,   // simple moving average - SMA
   ma_ema,   // exponential moving average - EMA
   ma_dsema, // double smoothed exponential moving average - DSEMA
   ma_dema,  // double exponential moving average - DEMA
   ma_tema,  // tripple exponential moving average - TEMA
   ma_smma,  // smoothed moving average - SMMA
   ma_lwma,  // linear weighted moving average - LWMA
   ma_pwma,  // parabolic weighted moving average - PWMA
   ma_alxma, // Alexander moving average - ALXMA
   ma_vwma,  // volume weighted moving average - VWMA
   ma_hull,  // Hull moving average
   ma_tma,   // triangular moving average
   ma_sine,  // sine weighted moving average
   ma_linr,  // linear regression value
   ma_ie2,   // IE/2
   ma_nlma,  // non lag moving average
   ma_zlma,  // zero lag moving average
   ma_lead,  // leader exponential moving average
   ma_ssm,   // super smoother
   ma_smoo   // smoother
};

extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;
extern int AMAPeriod = 10;
extern ENUM_APPLIED_PRICE AMAPrice = PRICE_CLOSE;
extern int Nfast = 2;
extern int Nslow = 30;
extern double GCoeff = 2;
extern int PriceFilter = 5;
extern maTypes PriceFilterMode = ma_smoo;
extern bool Interpolate = true;

double kAMAbuffer[];
double kAMAbufferda[];
double kAMAbufferdb[];
double slope[];
double atrUpper[], atrLower[];
string indicatorFileName;
bool returnBars;
int atrPeriod = 14;
double atrDev = 1;


enum SingalMode
{
   SingalModeLive, // Live
   SingalModeOnBarClose // On bar close
};

enum DisplayType
{
   Arrows, // Arrows
   ArrowsOnMainChart, // Arrows on main chart
   Candles // Candles color
};
input SingalMode signal_mode = SingalModeLive; // Signal mode
input DisplayType Type = Arrows; // Presentation Type
input double shift_arrows_pips = 0.1; // Shift arrows
input color up_color = Blue; // Up color
input color down_color = Red; // Down color

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
// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

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
//Signaler v 1.7
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

// Alert signal v3.0
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
public:
   AlertSignal(ICondition* condition, IAction* actionOnCondition, Signaler* signaler, bool onBarClose = false)
   {
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
      string symbol = _signaler.GetSymbol();
      datetime dt = iTime(symbol, _signaler.GetTimeframe(), _onBarClose ? period + 1 : period);

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
         dt = iTime(symbol, _signaler.GetTimeframe(), 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
            _lastSignal = dt;
         }
      }

      _signalOutput.Set(period);
   }
};

#endif

// Custom stream v1.0

#ifndef CustomStream_IMP
#define CustomStream_IMP



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

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

#endif

AlertSignal* conditions[];
Signaler* mainSignaler;
CustomStream* customStream;

int CreateAlert(int id, ICondition* upCondition, IAction* upAction, ICondition* downCondition, IAction* downAction)
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 2);
   conditions[size] = new AlertSignal(upCondition, upAction, mainSignaler, signal_mode == SingalModeOnBarClose);
   conditions[size + 1] = new AlertSignal(downCondition, downAction, mainSignaler, signal_mode == SingalModeOnBarClose);
      
   switch (Type)
   {
      case Arrows:
         {
            id = conditions[size].RegisterStreams(id, "Up", 217, up_color, customStream);
            id = conditions[size + 1].RegisterStreams(id, "Down", 218, down_color, customStream);
         }
         break;
      case ArrowsOnMainChart:
         {
            PriceStream* highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
            highStream.SetShift(shift_arrows_pips);
            PriceStream* lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
            lowStream.SetShift(-shift_arrows_pips);
            id = conditions[size].RegisterArrows(id, "Up", IndicatorObjPrefix + "_up", 217, up_color, highStream);
            id = conditions[size + 1].RegisterArrows(id, "Down", IndicatorObjPrefix + "_down", 218, down_color, lowStream);
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
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return kAMAbufferda[period] == EMPTY_VALUE && kAMAbufferda[period + 1] != EMPTY_VALUE;
   }
};

class DownCondition : public ACondition
{
public:
   DownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return kAMAbufferda[period] != EMPTY_VALUE && kAMAbufferda[period + 1] == EMPTY_VALUE;
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

int init()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0, kAMAbuffer);
   SetIndexBuffer(1, kAMAbufferda);
   SetIndexBuffer(2, kAMAbufferdb);
   SetIndexBuffer(3, slope);
   SetIndexBuffer(4, atrUpper);
   SetIndexBuffer(5, atrLower);

   indicatorFileName = WindowExpertName();
   returnBars = TimeFrame == -99;
   TimeFrame = MathMax(TimeFrame, _Period);

   IndicatorShortName(timeFrameToString(TimeFrame) + " Kaufman AMA " + getAverageName(PriceFilterMode) + " filtered (" + AMAPeriod + ")");

   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorBuffers(8);
   IndicatorObjPrefix = GenerateIndicatorPrefix("kamaafatrb");
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");

   int id = 6;

   if (Type == Arrows)
   {
      customStream = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ICondition* upCondition = (ICondition*) new UpCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ICondition* downCondition = (ICondition*) new DownCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = CreateAlert(id, upCondition, NULL, downCondition, NULL);
   if (customStream != NULL)
   {
      id = customStream.RegisterInternalStream(id);
   }
   return (0);
}

int deinit()
{
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
   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - 1 - AMAPeriod, Bars - counted_bars - 1);
   if (returnBars)
   {
      kAMAbuffer[0] = limit + 1;
      return (0);
   }

   if (TimeFrame == Period())
   {
      if (slope[limit] == -1)
         CleanPoint(limit, kAMAbufferda, kAMAbufferdb);
      for (int i = limit; i >= 0; i--)
      {
         double maval1 = iMA(NULL, 0, 1, 0, MODE_SMA, AMAPrice, i);
         double maval2 = iCustomMa(PriceFilterMode, maval1, PriceFilter, i);
         kAMAbuffer[i] = iKama(maval2, AMAPeriod, Nfast, Nslow, GCoeff, i);
         kAMAbufferda[i] = EMPTY_VALUE;
         kAMAbufferdb[i] = EMPTY_VALUE;
         slope[i] = slope[i + 1];
         if (kAMAbuffer[i] > kAMAbuffer[i + 1])
            slope[i] = 1;
         if (kAMAbuffer[i] < kAMAbuffer[i + 1])
            slope[i] = -1;
         if (slope[i] == -1)
            PlotPoint(i, kAMAbufferda, kAMAbufferdb, kAMAbuffer);
      }
      for (int j = limit; j >= 0; j--)
      {
         atrUpper[j] = kAMAbuffer[j] + atrDev * iATR(NULL, 0, atrPeriod, j);
         atrLower[j] = kAMAbuffer[j] - atrDev * iATR(NULL, 0, atrPeriod, j);
      }
       counted_bars = IndicatorCounted();
      if (counted_bars <= 0 || counted_bars > Bars)
      {
         for (int i = 0; i < ArraySize(conditions); ++i)
         {
            AlertSignal* item = conditions[i];
            item.Init();
         }
      }
      int minBars = 1;
      limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
      for (int pos = limit; pos >= 0; --pos)
      {
         if (customStream != NULL)
         {
            customStream._stream[pos] = Close[pos];
         }
         for (int i = 0; i < ArraySize(conditions); ++i)
         {
            AlertSignal* item = conditions[i];
            item.Update(pos);
         }
      }
      return (0);
   }

   limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, TimeFrame, indicatorFileName, -99, 0, 0) * TimeFrame / Period()));
   if (slope[limit] == -1)
      CleanPoint(limit, kAMAbufferda, kAMAbufferdb);
   for (int i = limit; i >= 0; i--)
   {
      int y = iBarShift(NULL, TimeFrame, Time[i]);
      kAMAbuffer[i] = iCustom(NULL, TimeFrame, indicatorFileName, PERIOD_CURRENT, AMAPeriod, AMAPrice, Nfast, Nslow, GCoeff, PriceFilter, PriceFilterMode, 0, y);
      slope[i] = iCustom(NULL, TimeFrame, indicatorFileName, PERIOD_CURRENT, AMAPeriod, AMAPrice, Nfast, Nslow, GCoeff, PriceFilter, PriceFilterMode, 3, y);
      kAMAbufferda[i] = EMPTY_VALUE;
      kAMAbufferdb[i] = EMPTY_VALUE;

      if (!Interpolate || y == iBarShift(NULL, TimeFrame, Time[i - 1]))
         continue;

      datetime time = iTime(NULL, TimeFrame, y);
      int n;
      for (n = 1; i + n < Bars && Time[i + n] >= time; n++)
         continue;
      for (int x = 1; x < n; x++)
      {
         kAMAbuffer[i + x] = kAMAbuffer[i] + (kAMAbuffer[i + n] - kAMAbuffer[i]) * x / n;
      }
   }
   for (int i = limit; i >= 0; i--)
      if (slope[i] == -1)
         PlotPoint(i, kAMAbufferda, kAMAbufferdb, kAMAbuffer);

   counted_bars = IndicatorCounted();
   if (counted_bars <= 0 || counted_bars > Bars)
   {
      for (int i = 0; i < ArraySize(conditions); ++i)
      {
         AlertSignal* item = conditions[i];
         item.Init();
      }
   }
   int minBars = 1;
   limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      if (customStream != NULL)
      {
         customStream._stream[pos] = Close[pos];
      }
      for (int i = 0; i < ArraySize(conditions); ++i)
      {
         AlertSignal* item = conditions[i];
         item.Update(pos);
      }
   } 
   return (0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

double kWork[][3];
#define _kprice 0
#define _kdiff 1
#define _kama 2

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iKama(double tprice, int period, double gFast, double gSlow, double gCoeff, int i, int instanceNo = 0)
{
   if (ArrayRange(kWork, 0) != Bars)
      ArrayResize(kWork, Bars);
   int r = Bars - i - 1;
   instanceNo *= 3;
   kWork[r][instanceNo + _kprice] = tprice;
   if (i > Bars - period)
   {
      kWork[r][instanceNo + _kama] = tprice;
      kWork[r][instanceNo + _kdiff] = 0;
      return (kWork[r][instanceNo + _kama]);
   }

   //
   //
   //
   //
   //

   double efratio = 1.00;
   double fastend = (2.0 / (gFast + 1));
   double slowend = (2.0 / (gSlow + 1));
   double smooth;
   double signal;
   double noise = 0;
   signal = MathAbs(kWork[r][instanceNo + _kprice] - kWork[r - period][instanceNo + _kprice]);
   kWork[r][instanceNo + _kdiff] = MathAbs(kWork[r][instanceNo + _kprice] - kWork[r - 1][instanceNo + _kprice]);
   for (int k = 0; k < period; k++)
      noise += kWork[r - k][instanceNo + _kdiff];

   //
   //
   //
   //
   //

   if (noise != 0)
      efratio = signal / noise;
   smooth = MathPow(efratio * (fastend - slowend) + slowend, gCoeff);
   kWork[r][instanceNo + _kama] = kWork[r - 1][instanceNo + _kama] + smooth * (kWork[r][instanceNo + _kprice] - kWork[r - 1][instanceNo + _kama]);
   //
   //
   //
   //
   //

   return (kWork[r][instanceNo + _kama]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanPoint(int i, double &first[], double &second[])
{
   if ((second[i] != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
      second[i + 1] = EMPTY_VALUE;
   else if ((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
      first[i + 1] = EMPTY_VALUE;
}
void PlotPoint(int i, double &first[], double &second[], double &from[])
{
   if (first[i + 1] == EMPTY_VALUE)
      if (first[i + 2] == EMPTY_VALUE)
      {
         first[i] = from[i];
         first[i + 1] = from[i + 1];
         second[i] = EMPTY_VALUE;
      }
      else
      {
         second[i] = from[i];
         second[i + 1] = from[i + 1];
         first[i] = EMPTY_VALUE;
      }
   else
   {
      first[i] = from[i];
      second[i] = EMPTY_VALUE;
   }
}

//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
{
   StringToUpper(tfs);
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tfs == sTfTable[i] || tfs == "" + iTfTable[i])
         return (MathMax(iTfTable[i], Period()));
   return (Period());
}
string timeFrameToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

string methodNames[] = {"SMA", "EMA", "Double smoothed EMA", "Double EMA", "Tripple EMA", "Smoothed MA", "Linear weighted MA", "Parabolic weighted MA", "Alexander MA", "Volume weghted MA", "Hull MA", "Triangular MA", "Sine weighted MA", "Linear regression", "IE/2", "NonLag MA", "Zero lag EMA", "Leader EMA", "Super smoother", "Smoothed"};
string getAverageName(int method)
{
   int max = ArraySize(methodNames) - 1;
   method = MathMax(MathMin(method, max), 0);
   return (methodNames[method]);
}

//
//
//
//
//

#define _maWorkBufferx1 1
#define _maWorkBufferx2 2
#define _maWorkBufferx3 3
#define _maWorkBufferx5 5

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iCustomMa(int mode, double price, double length, int i, int instanceNo = 0)
{
   int r = Bars - i - 1;
   switch (mode)
   {
   case 0:
      return (iSma(price, (int)length, r, instanceNo));
   case 1:
      return (iEma(price, length, r, instanceNo));
   case 2:
      return (iDsema(price, length, r, instanceNo));
   case 3:
      return (iDema(price, length, r, instanceNo));
   case 4:
      return (iTema(price, length, r, instanceNo));
   case 5:
      return (iSmma(price, length, r, instanceNo));
   case 6:
      return (iLwma(price, length, r, instanceNo));
   case 7:
      return (iLwmp(price, length, r, instanceNo));
   case 8:
      return (iAlex(price, length, r, instanceNo));
   case 9:
      return (iWwma(price, length, r, instanceNo));
   case 10:
      return (iHull(price, length, r, instanceNo));
   case 11:
      return (iTma(price, length, r, instanceNo));
   case 12:
      return (iSineWMA(price, (int)length, r, instanceNo));
   case 13:
      return (iLinr(price, length, r, instanceNo));
   case 14:
      return (iIe2(price, length, r, instanceNo));
   case 15:
      return (iNonLagMa(price, length, r, instanceNo));
   case 16:
      return (iZeroLag(price, length, r, instanceNo));
   case 17:
      return (iLeader(price, length, r, instanceNo));
   case 18:
      return (iSsm(price, length, r, instanceNo));
   case 19:
      return (iSmooth(price, (int)length, r, instanceNo));
   default:
      return (0);
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo = 0)
{
   if (ArrayRange(workSma, 0) != Bars)
      ArrayResize(workSma, Bars);
   instanceNo *= 2;

   //
   //
   //
   //
   //

   workSma[r][instanceNo] = price;
   if (r >= period)
      workSma[r][instanceNo + 1] = workSma[r - 1][instanceNo + 1] + (workSma[r][instanceNo] - workSma[r - period][instanceNo]) / period;
   else
   {
      workSma[r][instanceNo + 1] = 0;
      int k;
      for (k = 0; k < period && (r - k) >= 0; k++)
         workSma[r][instanceNo + 1] += workSma[r - k][instanceNo];
      workSma[r][instanceNo + 1] /= k;
   }
   return (workSma[r][instanceNo + 1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workEma, 0) != Bars)
      ArrayResize(workEma, Bars);

   //
   //
   //
   //
   //

   double alpha = 2.0 / (1.0 + period);
   workEma[r][instanceNo] = workEma[r - 1][instanceNo] + alpha * (price - workEma[r - 1][instanceNo]);
   return (workEma[r][instanceNo]);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iDsema(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workDsema, 0) != Bars)
      ArrayResize(workDsema, Bars);
   instanceNo *= 2;

   //
   //
   //
   //
   //

   double alpha = 2.0 / (1.0 + MathSqrt(period));
   workDsema[r][_ema1 + instanceNo] = workDsema[r - 1][_ema1 + instanceNo] + alpha * (price - workDsema[r - 1][_ema1 + instanceNo]);
   workDsema[r][_ema2 + instanceNo] = workDsema[r - 1][_ema2 + instanceNo] + alpha * (workDsema[r][_ema1 + instanceNo] - workDsema[r - 1][_ema2 + instanceNo]);
   return (workDsema[r][_ema2 + instanceNo]);
}

//
//
//
//
//

double workDema[][_maWorkBufferx2];
#define _dema1 0
#define _dema2 1

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iDema(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workDema, 0) != Bars)
      ArrayResize(workDema, Bars);
   instanceNo *= 2;

   //
   //
   //
   //
   //

   double alpha = 2.0 / (1.0 + period);
   workDema[r][_dema1 + instanceNo] = workDema[r - 1][_dema1 + instanceNo] + alpha * (price - workDema[r - 1][_dema1 + instanceNo]);
   workDema[r][_dema2 + instanceNo] = workDema[r - 1][_dema2 + instanceNo] + alpha * (workDema[r][_dema1 + instanceNo] - workDema[r - 1][_dema2 + instanceNo]);
   return (workDema[r][_dema1 + instanceNo] * 2.0 - workDema[r][_dema2 + instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iTema(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workTema, 0) != Bars)
      ArrayResize(workTema, Bars);
   instanceNo *= 3;

   //
   //
   //
   //
   //

   double alpha = 2.0 / (1.0 + period);
   workTema[r][_tema1 + instanceNo] = workTema[r - 1][_tema1 + instanceNo] + alpha * (price - workTema[r - 1][_tema1 + instanceNo]);
   workTema[r][_tema2 + instanceNo] = workTema[r - 1][_tema2 + instanceNo] + alpha * (workTema[r][_tema1 + instanceNo] - workTema[r - 1][_tema2 + instanceNo]);
   workTema[r][_tema3 + instanceNo] = workTema[r - 1][_tema3 + instanceNo] + alpha * (workTema[r][_tema2 + instanceNo] - workTema[r - 1][_tema3 + instanceNo]);
   return (workTema[r][_tema3 + instanceNo] + 3.0 * (workTema[r][_tema1 + instanceNo] - workTema[r][_tema2 + instanceNo]));
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workSmma, 0) != Bars)
      ArrayResize(workSmma, Bars);

   //
   //
   //
   //
   //

   if (r < period)
      workSmma[r][instanceNo] = price;
   else
      workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
   return (workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workLwma, 0) != Bars)
      ArrayResize(workLwma, Bars);

   //
   //
   //
   //
   //

   workLwma[r][instanceNo] = price;
   double sumw = period;
   double sum = period * price;

   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = period - k;
      sumw += weight;
      sum += weight * workLwma[r - k][instanceNo];
   }
   return (sum / sumw);
}

//
//
//
//
//

double workLwmp[][_maWorkBufferx1];
double iLwmp(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workLwmp, 0) != Bars)
      ArrayResize(workLwmp, Bars);

   //
   //
   //
   //
   //

   workLwmp[r][instanceNo] = price;
   double sumw = period * period;
   double sum = sumw * price;

   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = (period - k) * (period - k);
      sumw += weight;
      sum += weight * workLwmp[r - k][instanceNo];
   }
   return (sum / sumw);
}

//
//
//
//
//

double workAlex[][_maWorkBufferx1];
double iAlex(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workAlex, 0) != Bars)
      ArrayResize(workAlex, Bars);
   if (period < 4)
      return (price);

   //
   //
   //
   //
   //

   workAlex[r][instanceNo] = price;
   double sumw = period - 2;
   double sum = sumw * price;

   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = period - k - 2;
      sumw += weight;
      sum += weight * workAlex[r - k][instanceNo];
   }
   return (sum / sumw);
}

//
//
//
//
//

double workTma[][_maWorkBufferx1];
double iTma(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workTma, 0) != Bars)
      ArrayResize(workTma, Bars);

   //
   //
   //
   //
   //

   workTma[r][instanceNo] = price;

   double half = (period + 1.0) / 2.0;
   double sum = price;
   double sumw = 1;

   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = k + 1;
      if (weight > half)
         weight = period - k;
      sumw += weight;
      sum += weight * workTma[r - k][instanceNo];
   }
   return (sum / sumw);
}

//
//
//
//
//

double workSineWMA[][_maWorkBufferx1];
#define Pi 3.14159265358979323846264338327950288

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSineWMA(double price, int period, int r, int instanceNo = 0)
{
   if (period < 1)
      return (price);
   if (ArrayRange(workSineWMA, 0) != Bars)
      ArrayResize(workSineWMA, Bars);

   //
   //
   //
   //
   //

   workSineWMA[r][instanceNo] = price;
   double sum = 0;
   double sumw = 0;

   for (int k = 0; k < period && (r - k) >= 0; k++)
   {
      double weight = MathSin(Pi * (k + 1.0) / (period + 1.0));
      sumw += weight;
      sum += weight * workSineWMA[r - k][instanceNo];
   }
   return (sum / sumw);
}

//
//
//
//
//

double workWwma[][_maWorkBufferx1];
double iWwma(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workWwma, 0) != Bars)
      ArrayResize(workWwma, Bars);

   //
   //
   //
   //
   //

   workWwma[r][instanceNo] = price;
   int i = Bars - r - 1;
   double sumw = Volume[i];
   double sum = sumw * price;

   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = Volume[i + k];
      sumw += weight;
      sum += weight * workWwma[r - k][instanceNo];
   }
   return (sum / sumw);
}

//
//
//
//
//

double workHull[][_maWorkBufferx2];
double iHull(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workHull, 0) != Bars)
      ArrayResize(workHull, Bars);

   //
   //
   //
   //
   //

   int HmaPeriod = MathMax(period, 2);
   int HalfPeriod = MathFloor(HmaPeriod / 2);
   int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
   double hma, hmw, weight;
   instanceNo *= 2;

   workHull[r][instanceNo] = price;

   //
   //
   //
   //
   //

   hmw = HalfPeriod;
   hma = hmw * price;
   for (int k = 1; k < HalfPeriod && (r - k) >= 0; k++)
   {
      weight = HalfPeriod - k;
      hmw += weight;
      hma += weight * workHull[r - k][instanceNo];
   }
   workHull[r][instanceNo + 1] = 2.0 * hma / hmw;

   hmw = HmaPeriod;
   hma = hmw * price;
   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      weight = HmaPeriod - k;
      hmw += weight;
      hma += weight * workHull[r - k][instanceNo];
   }
   workHull[r][instanceNo + 1] -= hma / hmw;

   //
   //
   //
   //
   //

   hmw = HullPeriod;
   hma = hmw * workHull[r][instanceNo + 1];
   for (int k = 1; k < HullPeriod && (r - k) >= 0; k++)
   {
      weight = HullPeriod - k;
      hmw += weight;
      hma += weight * workHull[r - k][1 + instanceNo];
   }
   return (hma / hmw);
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workLinr, 0) != Bars)
      ArrayResize(workLinr, Bars);

   //
   //
   //
   //
   //

   period = MathMax(period, 1);
   workLinr[r][instanceNo] = price;
   double lwmw = period;
   double lwma = lwmw * price;
   double sma = price;
   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = period - k;
      lwmw += weight;
      lwma += weight * workLinr[r - k][instanceNo];
      sma += workLinr[r - k][instanceNo];
   }

   return (3.0 * lwma / lwmw - 2.0 * sma / period);
}

//
//
//
//
//

double workIe2[][_maWorkBufferx1];
double iIe2(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workIe2, 0) != Bars)
      ArrayResize(workIe2, Bars);

   //
   //
   //
   //
   //

   period = MathMax(period, 1);
   workIe2[r][instanceNo] = price;
   double sumx = 0, sumxx = 0, sumxy = 0, sumy = 0;
   for (int k = 0; k < period; k++)
   {
      price = workIe2[r - k][instanceNo];
      sumx += k;
      sumxx += k * k;
      sumxy += k * price;
      sumy += price;
   }
   double tslope = (period * sumxy - sumx * sumy) / (sumx * sumx - period * sumxx);
   double average = sumy / period;
   return (((average + tslope) + (sumy + tslope * sumx) / period) / 2.0);
}

//
//
//
//
//

double workLeader[][_maWorkBufferx2];
double iLeader(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workLeader, 0) != Bars)
      ArrayResize(workLeader, Bars);
   instanceNo *= 2;

   //
   //
   //
   //
   //

   period = MathMax(period, 1);
   double alpha = 2.0 / (period + 1.0);
   workLeader[r][instanceNo] = workLeader[r - 1][instanceNo] + alpha * (price - workLeader[r - 1][instanceNo]);
   workLeader[r][instanceNo + 1] = workLeader[r - 1][instanceNo + 1] + alpha * (price - workLeader[r][instanceNo] - workLeader[r - 1][instanceNo + 1]);

   return (workLeader[r][instanceNo] + workLeader[r][instanceNo + 1]);
}

//
//
//
//
//

double workZl[][_maWorkBufferx2];
#define _price 0
#define _zlema 1

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iZeroLag(double price, double length, int r, int instanceNo = 0)
{
   if (ArrayRange(workZl, 0) != Bars)
      ArrayResize(workZl, Bars);
   instanceNo *= 2;

   //
   //
   //
   //
   //

   double alpha = 2.0 / (1.0 + length);
   int per = (length - 1.0) / 2.0;

   workZl[r][_price + instanceNo] = price;
   if (r < per)
      workZl[r][_zlema + instanceNo] = price;
   else
      workZl[r][_zlema + instanceNo] = workZl[r - 1][_zlema + instanceNo] + alpha * (2.0 * price - workZl[r - per][_price + instanceNo] - workZl[r - 1][_zlema + instanceNo]);
   return (workZl[r][_zlema + instanceNo]);
}

//
//
//
//
//

double workSmooth[][_maWorkBufferx5];
double iSmooth(double price, int length, int r, int instanceNo = 0)
{
   if (ArrayRange(workSmooth, 0) != Bars)
      ArrayResize(workSmooth, Bars);
   instanceNo *= 5;
   if (r <= 2)
   {
      workSmooth[r][instanceNo] = price;
      workSmooth[r][instanceNo + 2] = price;
      workSmooth[r][instanceNo + 4] = price;
      return (price);
   }

   //
   //
   //
   //
   //

   double alpha = 0.45 * (length - 1.0) / (0.45 * (length - 1.0) + 2.0);
   workSmooth[r][instanceNo + 0] = price + alpha * (workSmooth[r - 1][instanceNo] - price);
   workSmooth[r][instanceNo + 1] = (price - workSmooth[r][instanceNo]) * (1 - alpha) + alpha * workSmooth[r - 1][instanceNo + 1];
   workSmooth[r][instanceNo + 2] = workSmooth[r][instanceNo + 0] + workSmooth[r][instanceNo + 1];
   workSmooth[r][instanceNo + 3] = (workSmooth[r][instanceNo + 2] - workSmooth[r - 1][instanceNo + 4]) * MathPow(1.0 - alpha, 2) + MathPow(alpha, 2) * workSmooth[r - 1][instanceNo + 3];
   workSmooth[r][instanceNo + 4] = workSmooth[r][instanceNo + 3] + workSmooth[r - 1][instanceNo + 4];
   return (workSmooth[r][instanceNo + 4]);
}

//
//
//
//
//

double workSsm[][_maWorkBufferx2];
#define _tprice 0
#define _ssm 1

double workSsmCoeffs[][4];
#define _period 0
#define _c1 1
#define _c2 2
#define _c3 3

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSsm(double price, double period, int i, int instanceNo)
{
   if (ArrayRange(workSsm, 0) != Bars)
      ArrayResize(workSsm, Bars);
   if (ArrayRange(workSsmCoeffs, 0) < (instanceNo + 1))
      ArrayResize(workSsmCoeffs, instanceNo + 1);
   if (workSsmCoeffs[instanceNo][_period] != period)
   {
      workSsmCoeffs[instanceNo][_period] = period;
      double a1 = MathExp(-1.414 * Pi / period);
      double b1 = 2.0 * a1 * MathCos(1.414 * Pi / period);
      workSsmCoeffs[instanceNo][_c2] = b1;
      workSsmCoeffs[instanceNo][_c3] = -a1 * a1;
      workSsmCoeffs[instanceNo][_c1] = 1.0 - workSsmCoeffs[instanceNo][_c2] - workSsmCoeffs[instanceNo][_c3];
   }

   //
   //
   //
   //
   //

   int s = instanceNo * 2;
   workSsm[i][s + _tprice] = price;
   workSsm[i][s + _ssm] = workSsmCoeffs[instanceNo][_c1] * (workSsm[i][s + _tprice] + workSsm[i - 1][s + _tprice]) / 2.0 +
                          workSsmCoeffs[instanceNo][_c2] * workSsm[i - 1][s + _ssm] +
                          workSsmCoeffs[instanceNo][_c3] * workSsm[i - 2][s + _ssm];
   return (workSsm[i][s + _ssm]);
}

//
//
//
//
//

#define _length 0
#define _len 1
#define _weight 2

double nlmvalues[3][_maWorkBufferx1];
double nlmprices[][_maWorkBufferx1];
double nlmalphas[][_maWorkBufferx1];

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iNonLagMa(double price, double length, int r, int instanceNo = 0)
{
   if (ArrayRange(nlmprices, 0) != Bars)
      ArrayResize(nlmprices, Bars);
   if (ArrayRange(nlmvalues, 0) < instanceNo)
      ArrayResize(nlmvalues, instanceNo);
   nlmprices[r][instanceNo] = price;
   if (length < 3 || r < 3)
      return (nlmprices[r][instanceNo]);

   //
   //
   //
   //
   //

   if (nlmvalues[_length][instanceNo] != length || ArraySize(nlmalphas) == 0)
   {
      double Cycle = 4.0;
      double Coeff = 3.0 * Pi;
      int Phase = length - 1;

      nlmvalues[_length][instanceNo] = length;
      nlmvalues[_len][instanceNo] = length * 4 + Phase;
      nlmvalues[_weight][instanceNo] = 0;

      if (ArrayRange(nlmalphas, 0) < nlmvalues[_len][instanceNo])
         ArrayResize(nlmalphas, nlmvalues[_len][instanceNo]);
      for (int k = 0; k < nlmvalues[_len][instanceNo]; k++)
      {
         double t;
         if (k <= Phase - 1)
            t = 1.0 * k / (Phase - 1);
         else
            t = 1.0 + (k - Phase + 1) * (2.0 * Cycle - 1.0) / (Cycle * length - 1.0);
         double beta = MathCos(Pi * t);
         double g = 1.0 / (Coeff * t + 1);
         if (t <= 0.5)
            g = 1;

         nlmalphas[k][instanceNo] = g * beta;
         nlmvalues[_weight][instanceNo] += nlmalphas[k][instanceNo];
      }
   }

   //
   //
   //
   //
   //

   if (nlmvalues[_weight][instanceNo] > 0)
   {
      double sum = 0;
      for (int k = 0; k < nlmvalues[_len][instanceNo]; k++)
         sum += nlmalphas[k][instanceNo] * nlmprices[r - k][instanceNo];
      return (sum / nlmvalues[_weight][instanceNo]);
   }
   else
      return (0);
}
//+------------------------------------------------------------------+
