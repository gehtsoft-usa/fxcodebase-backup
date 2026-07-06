// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=27&t=67271
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
#property version "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 14
#property indicator_minimum - 20
#property indicator_maximum 105
#property indicator_level1 50
#property indicator_levelcolor clrDodgerBlue
#property indicator_levelstyle 1

input int limit = 1000;
string ID = "Brax>";
//+------------------------------------------------------------------------------------------------------------------+
input string RS01 = "====================================================";
input string RS02 = "<<<==== [01] RSIOMA Settings ====>>>";
input string RS03 = "====================================================";
int RSIOMA = 10,
    RSIOMA_MODE = MODE_LWMA,
    RSIOMA_PRICE = PRICE_CLOSE,
    Ma_RSIOMA = 14, //16
    Ma_RSIOMA_MODE = MODE_SMA;
double BuyTrigger = 30.00,
       SellTrigger = 70.00,
       XardOB = 90.00,
       XardOS = 10.00;
input color BuyTriggerColor = clrHotPink,
            SellTriggerColor = clrDodgerBlue,
            MainTrendLongColor = clrDodgerBlue,
            MainTrendShortColor = clrHotPink;
input color marsiomaXupSigColor = clrAqua,
            marsiomaXdnSigColor = clrDeepPink;
double MainTrendLong = 10.00, MainTrendShort = 90.00, MajorTrend = 50;
input string SL01 = "====================================================";
input string SL02 = "<<<==== [02] Line Settings ====>>>";
input string SL03 = "====================================================";
input string LinesIdentifier = "rsioma lines";
input int LinesStyle = STYLE_DASH;
input string AL01 = "====================================================";
input string AL02 = "<<<==== [03] Alert Settings ====>>>";
input string AL03 = "====================================================";
input string TF01 = "====================================================";
input string TF02 = "<<<==== [04] TF Period Chart Settings ====>>>";
input string TF03 = "====================================================";
input string note_Choose_TimeFrames = "TF as in MT4 Periodicity bar:";
input string as_Periods = "(M1;M5;M15;M30;H1;H4;D1;W1;MN; or:)";
input string or_Minutes = "(1,5,15,30,60,240,1440,10080,43200)";
input string CurrentTF_0 = "Current TF = 0 (Zero)";
input string Timeframe = "0",
             TimeFrames_Periods = "M1;M5;M15;M30;H1;H4;D1;W1;MN";
input string BT01 = "====================================================";
input string BT02 = "<<<==== [05] BOXtext on 1Hr Chart Settings ====>>>";
input string BT03 = "====================================================";
input bool showBOXtext = true;
input int PanelBorderWidth = 1;
input color PanelBorderColor = C'120,120,120';
string BOXtxt;
color BOXclr;

double MABuffer1[], RSIBuffer1[], marsioma1[];
double RSIBuffer[], bdn[], bup[], sdn[], sup[];
double marsioma[];
int correction, TimeFrame;
datetime lastBarTime, TimeArray[];
bool DiferentTimeFrame;


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
      return RSIBuffer[period + 1] <= marsioma[period + 1] && RSIBuffer[period] > marsioma[period];
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
      return RSIBuffer[period + 1] >= marsioma[period + 1] && RSIBuffer[period] < marsioma[period];
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
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorObjPrefix = GenerateIndicatorPrefix("xrsioma");
   IndicatorShortName("X-RSIOMA");
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");
   IndicatorBuffers(14 + 3);

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

   SetIndexBuffer(0, RSIBuffer);
   SetIndexStyle(0, DRAW_LINE, EMPTY, 2, clrDodgerBlue);
   SetIndexBuffer(1, bdn);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 7, C'155,5,16');
   SetIndexBuffer(2, bup);
   SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, 7, C'16,195,5');
   SetIndexBuffer(3, sdn);
   SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, 2, C'155,5,16');
   SetIndexBuffer(4, sup);
   SetIndexStyle(4, DRAW_HISTOGRAM, EMPTY, 2, C'16,5,195');
   SetIndexBuffer(5, marsioma);
   SetIndexStyle(5, DRAW_LINE, EMPTY, 2, clrRed);
   for (int Bufx = 0; Bufx < indicator_buffers; Bufx++)
   {
      SetIndexLabel(Bufx, NULL);
   }
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, MABuffer1);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RSIBuffer1);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, marsioma1);
   ++id;
   //+------------------------------------------------------------------------------------------------------------------+
   TimeFrame = stringToTimeFrame(Timeframe);
   DiferentTimeFrame = (TimeFrame != Period());
   correction = RSIOMA + RSIOMA + Ma_RSIOMA;
   lastBarTime = EMPTY_VALUE;
   return (0);
}
//+------------------------------------------------------------------------------------------------------------------+
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
   return (0);
}
//+------------------------------------------------------------------------------------------------------------------+
int start()
{
   static bool init = false;
   if (!init)
   {
      init = true;
      drawLine(BuyTrigger, IndicatorObjPrefix + "BuyTrigger", BuyTriggerColor);
      drawLine(SellTrigger, IndicatorObjPrefix + "SellTrigger", SellTriggerColor);
      drawLine(XardOB, IndicatorObjPrefix + "XardOB", MainTrendShortColor);
      drawLine(XardOS, IndicatorObjPrefix + "XardOS", MainTrendLongColor);
   }
   int counted_bars = IndicatorCounted();
   if (counted_bars <= 0 || counted_bars > Bars)
   {
      ArrayInitialize(RSIBuffer, EMPTY_VALUE);
      ArrayInitialize(bdn, EMPTY_VALUE);
      ArrayInitialize(bup, EMPTY_VALUE);
      ArrayInitialize(sdn, EMPTY_VALUE);
      ArrayInitialize(sup, EMPTY_VALUE);
      ArrayInitialize(marsioma, EMPTY_VALUE);
      
      if (customStream != NULL)
      {
         ArrayInitialize(customStream._stream, EMPTY_VALUE);
      }
      for (int i = 0; i < ArraySize(conditions); ++i)
      {
         AlertSignal* item = conditions[i];
         item.Init();
      }
   }
   ArrayCopySeries(TimeArray, MODE_TIME, NULL, TimeFrame);
   int minBars = RSIOMA;
   int limit = MathMin(limit, MathMin(Bars - 1 - minBars, Bars - counted_bars - 1));
   for (int pos = limit; pos >= 0; --pos)
   {
      int index = iBarShift(_Symbol, TimeFrame, Time[pos]);
      if (index > iBars(_Symbol, TimeFrame) - minBars)
      {
         continue;
      }
      MABuffer1[index] = iMA(Symbol(), TimeFrame, RSIOMA, 0, RSIOMA_MODE, RSIOMA_PRICE, index);
      RSIBuffer1[index] = iRSIOnArray(MABuffer1, 0, RSIOMA, index);
      marsioma1[index] = iMAOnArray(RSIBuffer1, 0, Ma_RSIOMA, 0, Ma_RSIOMA_MODE, index);
      RSIBuffer[pos] = RSIBuffer1[index];
      marsioma[pos] = marsioma1[index];
      bup[pos] = EMPTY_VALUE;
      bdn[pos] = EMPTY_VALUE;
      sup[pos] = EMPTY_VALUE;
      sdn[pos] = EMPTY_VALUE;
      if (RSIBuffer[pos] <= 50.)
         bdn[pos] = -12;
      if (RSIBuffer[pos] > 50.)
         bup[pos] = 12;
      BOXtxt = "  WAITING...";
      BOXclr = C'40,40,40';
      if (RSIBuffer[pos] <= marsioma[pos] && RSIBuffer[pos] < 50.)
      {
         BOXtxt = "SELLS ONLY";
         BOXclr = clrRed;
      }
      if (RSIBuffer[pos] >= marsioma[pos] && RSIBuffer[pos] > 50.)
      {
         BOXtxt = " BUYS ONLY";
         BOXclr = clrBlue;
      }
      if (Period() <= PERIOD_W1)
      {
         if (showBOXtext)
         {
            SetPanel(0, IndicatorObjPrefix + ID + "Brax1", 1, 0, 4, 6, 140, 22, BOXclr, PanelBorderColor, PanelBorderWidth, false);
            ObjectSetInteger(0, IndicatorObjPrefix + ID + "Brax1", OBJPROP_BGCOLOR, BOXclr);
            SetLabel(0, IndicatorObjPrefix + ID + "Brax2", 1, 0, 8, 6, BOXtxt, 16, "Arial Bold", clrSilver, 0, false, true, 0, ANCHOR_LEFT_UPPER);
         }
      }
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
//+------------------------------------------------------------------------------------------------------------------+
void drawLine(double lvl, string name, color Col)
{
   ObjectDelete(name);
   ObjectCreate(name, OBJ_HLINE, WindowFind(IndicatorObjPrefix), Time[0], lvl, Time[0], lvl);
   ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(name, OBJPROP_COLOR, Col);
   ObjectSet(name, OBJPROP_WIDTH, 1);
}
//+------------------------------------------------------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
{
   int tf = 0;
   tfs = StringUpperCase(tfs);
   if (tfs == "M1" || tfs == "1")
      tf = PERIOD_M1;
   if (tfs == "M5" || tfs == "5")
      tf = PERIOD_M5;
   if (tfs == "M15" || tfs == "15")
      tf = PERIOD_M15;
   if (tfs == "M30" || tfs == "30")
      tf = PERIOD_M30;
   if (tfs == "H1" || tfs == "60")
      tf = PERIOD_H1;
   if (tfs == "H4" || tfs == "240")
      tf = PERIOD_H4;
   if (tfs == "D1" || tfs == "1440")
      tf = PERIOD_D1;
   if (tfs == "W1" || tfs == "10080")
      tf = PERIOD_W1;
   if (tfs == "MN" || tfs == "43200")
      tf = PERIOD_MN1;
   return (tf);
}
//+------------------------------------------------------------------------------------------------------------------+
string TimeFrameToString(int tf)
{
   string tfs = "0";
   switch (tf)
   {
   case PERIOD_M1:
      tfs = "Period M1";
      break;
   case PERIOD_M5:
      tfs = "Period M5";
      break;
   case PERIOD_M15:
      tfs = "Period M15";
      break;
   case PERIOD_M30:
      tfs = "Period M30";
      break;
   case PERIOD_H1:
      tfs = "Period H1";
      break;
   case PERIOD_H4:
      tfs = "Period H4";
      break;
   case PERIOD_D1:
      tfs = "Period D1";
      break;
   case PERIOD_W1:
      tfs = "Period W1";
      break;
   case PERIOD_MN1:
      tfs = "Period MN1";
   }
   return (tfs);
}
//+------------------------------------------------------------------------------------------------------------------+
string StringUpperCase(string str)
{
   string s = str;
   int lenght = StringLen(str) - 1;
   int tchar;
   while (lenght >= 0)
   {
      tchar = StringGetChar(s, lenght);
      if ((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
         s = StringSetChar(s, lenght, tchar - 32);
      else if (tchar > -33 && tchar < 0)
         s = StringSetChar(s, lenght, tchar + 224);
      lenght--;
   }
   return (s);
}
//+----SetPanel Function---------------------------------------------------------------------------------------------+
void SetPanel(long IDchart = 0, string name = "Panel", int window = 0, int corner = 0, int PosX = 0, int PosY = 0, int width = 0, int height = 0,
              int bg_color = 0, int border_color = 0, int border_width = 1, bool bg = true, bool del = false)
{
   if (StringLen(name) < 1)
      return;
   if (del)
      ObjectDelete(IDchart, name);
   window = MathMax(window, 0);
   if (bg_color < 0)
      bg_color = White;
   if (border_color < 0)
      border_color = White;
   if (ObjectCreate(IDchart, name, OBJ_RECTANGLE_LABEL, window, 0, 0))
   {
      ObjectSetInteger(IDchart, name, OBJPROP_XDISTANCE, PosX);
      ObjectSetInteger(IDchart, name, OBJPROP_YDISTANCE, PosY);
      ObjectSetInteger(IDchart, name, OBJPROP_XSIZE, width);
      ObjectSetInteger(IDchart, name, OBJPROP_YSIZE, height);
      ObjectSetInteger(IDchart, name, OBJPROP_COLOR, border_color);
      ObjectSetInteger(IDchart, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(IDchart, name, OBJPROP_WIDTH, border_width);
      ObjectSetInteger(IDchart, name, OBJPROP_CORNER, corner);
      ObjectSetInteger(IDchart, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(IDchart, name, OBJPROP_BACK, bg);
      ObjectSetInteger(IDchart, name, OBJPROP_SELECTABLE, 0);
      ObjectSetInteger(IDchart, name, OBJPROP_SELECTED, 0);
      ObjectSetInteger(IDchart, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(IDchart, name, OBJPROP_ZORDER, 0);
      ObjectSetInteger(IDchart, name, OBJPROP_BGCOLOR, bg_color);
   }
}
//+----SetLabel Function---------------------------------------------------------------------------------------------+
void SetLabel(long IDchart = 0, string name = "Label", int window = 0, int corner = 0, int PosX = 0, int PosY = 0, string thetext = " ",
              int fontsize = 12, string fontname = "Arial", int colour = 0, double angle = 0, bool back = true, bool del = false, int vis = 0,
              int align = ANCHOR_LEFT_UPPER, bool HideObjects = true)
{
   if (del)
      ObjectDelete(IDchart, name);
   corner = MathMax(corner, 0);
   window = MathMax(window, 0);
   if (colour < 0)
      colour = White;
   if (fontsize == 0)
      fontsize = 8;
   if (fontname == "")
      fontname = "Arial";
   if (ObjectFind(IDchart, name) < 0)
      ObjectCreate(IDchart, name, OBJ_LABEL, window, 0, 0, 0, 0);
   ObjectSetInteger(IDchart, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(IDchart, name, OBJPROP_XDISTANCE, PosX);
   ObjectSetInteger(IDchart, name, OBJPROP_YDISTANCE, PosY);
   ObjectSetString(IDchart, name, OBJPROP_TEXT, thetext);
   ObjectSetInteger(IDchart, name, OBJPROP_FONTSIZE, fontsize);
   ObjectSetString(IDchart, name, OBJPROP_FONT, fontname);
   ObjectSetInteger(IDchart, name, OBJPROP_COLOR, colour);
   ObjectSetDouble(IDchart, name, OBJPROP_ANGLE, angle);
   ObjectSetInteger(IDchart, name, OBJPROP_BACK, back);
   ObjectSetInteger(IDchart, name, OBJPROP_TIMEFRAMES, vis);
   ObjectSetInteger(IDchart, name, OBJPROP_ANCHOR, align);
   ObjectSetInteger(IDchart, name, OBJPROP_HIDDEN, HideObjects);
}