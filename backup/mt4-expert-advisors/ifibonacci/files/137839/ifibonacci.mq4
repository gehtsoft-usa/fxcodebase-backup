// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70475

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
//Based on Awran5. awran5@yahoo.com
#property description "This indicator will Draw Fibonacci Tools e.g. Retracement, Arc, Fan, Expansion, TimeZones. Based on zigzag indicator.\n"
#property description "Credit: \n      JimDandy, \n      WHRoeder, \n      RaptorUK, \n      deVries"
#property strict
#property indicator_chart_window
#property indicator_buffers 8

// Retrieves the coordinates of a window's client area, Used for Fibo Arc scale
#import "user32.dll"
int GetClientRect(int hWnd, int &lpRect[]);
#import
//---
enum ArcScale
{
   Math,       // MathAbs
   ClientRect, // ClientRect
   Manual      // Set Manually
};
//|--------------------------------------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                                                      |
//|--------------------------------------------------------------------------------------------------------------------|
//---------------------------------------------------------------------------------------------------------------------
ENUM_TIMEFRAMES FixedPeriod;
input string lb_0 = "";                // ----------  Z I G Z A G   S E T T I N G
input int ExtDepth = 21;               // ZigZag Depth
input int ExtDeviation = 5;            // ZigZag Deviation
input int ExtBackstep = 3;             // ZigZag Backstep
input int MaxBars = 5000;              // Maximum Bars
input ENUM_TIMEFRAMES _FixedPeriod = 0; // Time Frame to use
//---------------------------------------------------------------------------------------------------------------------
input string lb_1 = "";            // --------------------------------------------------------
input string lb_2 = "";            // ----------  F I B O   R E T R A C E M E N T
input bool ShowRetracement = true; // Show Retracement
input ENUM_LINE_STYLE rStyle = 0;  // Levels Style
input color rColor = clrGold;      // Levels Color
input int rWidth = 1;              // Levels Width
input double l0 = 0.0;             // Level 0
input double l38 = 0.382;          // Level 38.2
input double l50 = 0.5;            // Level 50
input double l61 = 0.618;          // Level 61.8
input double l100 = 1.0;           // Level 100
input bool ExtraLevels = false;    // Extra levels: 14.6, 23.6, 76.4, 88.6, 127.2
input double l14 = 0.146;          // Level 14.6
input double l23 = 0.236;          // Level 23.6
input double l74 = 0.764;          // Level 76.4
input double l88 = 0.886;          // Level 88.6
input double l127 = 1.272;         // Level 127.2
input bool LevelPrice = false;     // Show Prices
//---------------------------------------------------------------------------------------------------------------------
input string lb_3 = "";                                                // --------------------------------------------------------
input string lb_4 = "";                                                // ----------  F I B O   A R C
input bool ShowArc = false;                                            // Show Arc
input ArcScale ScaleMethod = Math;                                     // Scalling Method
input string info = "If ClientRect, you must allow DLL imports first"; // ----------  NOTE!
input double ManualScale = 0;                                          // Manual Scale value
input color aColor = clrTomato;                                        // Arc Color
input ENUM_LINE_STYLE aStyle = 0;                                      // Arc Style
input int aWidth = 1;                                                  // Arc Width
input double ARC38 = 0.382;                                            // Level 38.2
input double ARC50 = 0.500;                                            // Level 50
input double ARC61 = 0.618;                                            // Level 61.8
input bool ExtraARC = false;                                           // Show extra levels: 14.6, 23.6, 76.4
input double ARC14 = 0.146;                                            // Level 14.6
input double ARC23 = 0.236;                                            // Level 23.6
input double ARC74 = 0.764;                                            // Level 76.4
//---------------------------------------------------------------------------------------------------------------------
input string lb_5 = "";           // --------------------------------------------------------
input string lb_6 = "";           // ----------  F I B O   F A N
input bool ShowFan = true;        // Show Fan
input color fColor = clrGold;     // Fan Color
input ENUM_LINE_STYLE fStyle = 2; // Fan Style
input int fWidth = 1;             // Fan Width
input double FAN38 = 0.382;       // Level 38.2
input double FAN50 = 0.5;         // Level 50
input double FAN61 = 0.618;       // Level 61.8
input bool ExtraFAN = false;      // Show extra levels: 14.6, 23.6, 76.4
input double FAN14 = 0.146;       // Level 14.6
input double FAN23 = 0.236;       // Level 23.6
input double FAN74 = 0.764;       // Level 76.4
//---------------------------------------------------------------------------------------------------------------------
input string lb_7 = "";                // --------------------------------------------------------
input string lb_8 = "";                // ----------  F I B O   T I M E Z O N E S
input bool ShowZone = true;            // Show Time Zones
input color zColor = clrDarkGoldenrod; // Time Color
input ENUM_LINE_STYLE zStyle = 2;      // Time Style
input int zWidth = 1;                  // Time Width
input double Zone0 = 0;                // Level 0
input double Zone1 = 1;                // Level 100
input double Zone2 = 2;                // Level 200
input double Zone3 = 3;                // Level 300
input double Zone5 = 5;                // Level 500
input double Zone8 = 8;                // Level 800
input double Zone13 = 13;              // Level 1300
input double Zone21 = 21;              // Level 2100
input double Zone34 = 34;              // Level 3400
//---------------------------------------------------------------------------------------------------------------------
input string lb_9 = "";           // --------------------------------------------------------
input string lb_10 = "";          // ----------  F I B O   E X P A N S I O N
input bool ShowExpansion = false; // Show Expansion
input color eColor = clrBlue;     // Expansion Color
input ENUM_LINE_STYLE eStyle = 0; // Expansion Style
input int eWidth = 2;             // Expansion Width
input double EXP61 = 0.618;       // Level 61.8
input double EXP100 = 1;          // Level 100
input double EXP161 = 1.618;      // Level 161.8
input double EXP261 = 2.618;      // Level 261.8
input bool ExtraEXP = false;      // Show extra levels: 78.66, 138.2, 200
input double EXP78 = 0.786;       // Level 78.6
input double EXP138 = 1.382;      // Level 138.2
input double EXP200 = 2;          // Level 200
//---------------------------------------------------------------------------------------------------------------------
input string lb_13 = "";           // --------------------------------------------------------
input string lb_14 = "";           // ----------  D R A W   P A T T E R N
input bool ShowPattern = false;    // Show Pattern
input color pColor = clrFireBrick; // Pattern Color
//---------------------------------------------------------------------------------------------------------------------
input string lb_15 = "";               // --------------------------------------------------------
input string lb_16 = "";               // ----------  D A I L Y   H I G H / L O W
input bool ShowDaily = true;           // Show Daily High/Low
input color DayColor = clrPurple;      // Daily High/Low Color
input color DayWidth = 1;              // Daily High/Low Width
input ENUM_LINE_STYLE DayStyle = 0;    // Daily High/Low Style
input bool ShowPivot = true;           // Show Daily Pivot
input color PivotColor = clrLightGray; // Pivot Line Color
input color PivotWidth = 1;            // Pivot Line Width
input ENUM_LINE_STYLE PivotStyle = 0;  // Pivot Line Style
input string lb_17 = "";               // --------------------------------------------------------
input string lb_18 = "";               // ----------  W E E K L Y   H I G H / L O W
input bool ShowWeekly = true;          // Show Weekly High/Low
input color WeekColor = clrDarkBlue;   // Weekly Lines Color
input color WeekWidth = 1;             // Weekly Lines Width
input ENUM_LINE_STYLE WeekStyle = 0;   // Weekly Lines Style
input string lb_19 = "";               // --------------------------------------------------------
input string lb_20 = "";               // ----------  M O N T H L Y   H I G H / L O W
input bool ShowMonthly = false;        // Show Monthly High/Low
input color MonthColor = clrFireBrick; // Monthly Lines Color
input color MonthWidth = 1;            // Monthly Lines Width
input ENUM_LINE_STYLE MonthStyle = 0;  // Monthly Lines Style
input string lb_21 = "";               // --------------------------------------------------------
input string lb_22 = "";               // ----------  C A N D L E    T I M E
input bool ShowCanldeTime = true;      // Show Candle Time
input color TimerColor = clrYellow;    // Time Left Color
input int TimerFontSize = 7;           // Time Left Font Size

input double level = 0.618; // Alert Level
#define ACT_ON_SWITCH

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
// Act on switch condition v4.2



#ifndef ActOnSwitchCondition_IMP
#define ActOnSwitchCondition_IMP

class ActOnSwitchCondition : public ACondition
{
   ICondition* _condition;
   bool _current;
   datetime _currentDate;
   bool _last;
public:
   ActOnSwitchCondition(string symbol, ENUM_TIMEFRAMES timeframe, ICondition* condition)
      :ACondition(symbol, timeframe)
   {
      _last = false;
      _current = false;
      _currentDate = 0;
      _condition = condition;
      _condition.AddRef();
   }

   ~ActOnSwitchCondition()
   {
      _condition.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      datetime time = iTime(_symbol, _timeframe, period);
      if (_currentDate == 0)
      {
         _currentDate = time;
         _current = _condition.IsPass(period, date);
         _last = _current;
      }
      else if (time != _currentDate)
      {
         _last = _current;
         _currentDate = time;
         _current = _condition.IsPass(period, date);
      }
      else
      {
         _current = _condition.IsPass(period, date);
      }
      return _current && !_last;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Switch of (" + _condition.GetLogMessage(period, date) + (IsPass(period, date) ? ")=true" : ")=false");
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

// Alert signal v4.0
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

AlertSignal* conditions[];
Signaler* mainSignaler;
StreamWrapper* customStream;

int CreateAlert(int id, ICondition* upCondition, IAction* upAction, ICondition* downCondition, IAction* downAction, int upCode, int downCode, string upMessage = "Up", string downMessage = "Down")
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 2);
   #ifdef ACT_ON_SWITCH
      ActOnSwitchCondition* upSwitch = new ActOnSwitchCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, upCondition);
      upCondition.Release();
      upCondition = upSwitch;
      ActOnSwitchCondition* downSwitch = new ActOnSwitchCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, downCondition);
      downCondition.Release();
      downCondition = downSwitch;
   #endif
   conditions[size] = new AlertSignal(upCondition, upAction, _Symbol, (ENUM_TIMEFRAMES)_Period, mainSignaler, signal_mode == SingalModeOnBarClose);
   conditions[size + 1] = new AlertSignal(downCondition, downAction, _Symbol, (ENUM_TIMEFRAMES)_Period, mainSignaler, signal_mode == SingalModeOnBarClose);
      
   switch (Type)
   {
      case Arrows:
         {
            id = conditions[size].RegisterStreams(id, upMessage, upCode, up_color, customStream);
            id = conditions[size + 1].RegisterStreams(id, downMessage, downCode, down_color, customStream);
         }
         break;
      case ArrowsOnMainChart:
         {
            PriceStream* highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
            highStream.SetShift(shift_arrows_pips);
            PriceStream* lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
            lowStream.SetShift(-shift_arrows_pips);
            id = conditions[size].RegisterArrows(id, upMessage, IndicatorObjPrefix + "_up", upCode, up_color, highStream);
            id = conditions[size + 1].RegisterArrows(id, downMessage, IndicatorObjPrefix + "_down", downCode, down_color, lowStream);
            lowStream.Release();
            highStream.Release();
         }
         break;
      case Candles:
         {
            id = conditions[size].RegisterStreams(id, upMessage, up_color);
            id = conditions[size + 1].RegisterStreams(id, downMessage, down_color);
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
      double val1 = ObjectGetDouble(0, FibRetracement, OBJPROP_PRICE, 0);
      double val2 = ObjectGetDouble(0, FibRetracement, OBJPROP_PRICE, 1);
      double top = MathMax(val1, val2);
      double bottom = MathMin(val1, val2);
      for (int i = 0; i < 1000; ++i)
      {
         if (iHigh(_symbol, _timeframe, period + i) >= top)
         {
            break;
         }
         if (iLow(_symbol, _timeframe, period + i) <= bottom)
         {
            return false;
         }
      }
      double price = val2 + (val1 - val2) * level;
      return iClose(_symbol, _timeframe, period) <= price
         && iClose(_symbol, _timeframe, period + 1) > price;
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
      double val1 = ObjectGetDouble(0, FibRetracement, OBJPROP_PRICE, 0);
      double val2 = ObjectGetDouble(0, FibRetracement, OBJPROP_PRICE, 1);
      double top = MathMax(val1, val2);
      double bottom = MathMin(val1, val2);
      for (int i = 0; i < 1000; ++i)
      {
         if (iHigh(_symbol, _timeframe, period + i) >= top)
         {
            return false;
         }
         if (iLow(_symbol, _timeframe, period + i) <= bottom)
         {
            break;
         }
      }
      double price = val2 + (val1 - val2) * level;
      return iClose(_symbol, _timeframe, period) >= price
         && iClose(_symbol, _timeframe, period + 1) < price;
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
//|--------------------------------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                                                      |
//|--------------------------------------------------------------------------------------------------------------------|
string FibRetracement = "  Fibo Retracement";
string FibArc = "  Fibo Arc";
string FibFan = "  Fibo Fan";
string FibZone = "  Fibo TimeZones";
string FibExpansion = "  Fibo Expansion";
string FibChannel = "  Fibo Channel";
string A = "  Pattern1";
string B = "  Pattern2";
string DayHighName = "  Yesterday High Line";
string DayLowName = "  Yesterday Low Line";
string DayHighLabel = "       YH";
string DayLowLabel = "       YL";
//---
string WeekHighName = "  Weekly High Line";
string WeekLowName = "  Weekly Low Line";
string WeekHighLabel = "       WH";
string WeekLowLabel = "       WL";
//---
string MonthHighName = "  Monthly High Line";
string MonthLowName = "  Monthly Low Line";
string MonthHighLabel = "       MH";
string MonthLowLabel = "       ML";
//---
string PivotName = "  Daily Pivot";
string PivotLabel = "       PVT";
//---
string Timer = "  Candle Time";
//---
double zValue[5];  // zigzag swings value. zValue[1] = swing 1, and so on.
datetime zTime[5]; // Time for zigzag swings value
//---
int rect[4]; // defines the coordinates of window.
int hwnd;    // A handle to the window whose client coordinates are to be retrieved.
int gPixels, vPixels;
//---
double DayLow;
double DayHigh;
double DayClose;
double DayPivot;
double WeekLow;
double WeekHigh;
double MonthLow;
double MonthHigh;

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
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
   return "";
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   if (!IsDllsAllowed())
   {
      Print("One of Fibo ARC Methods is requires DLL, Remember to allow DLL imports if you like to use it.");
      return (INIT_SUCCEEDED);
   }
   IndicatorBuffers(8);
   IndicatorObjPrefix = GenerateIndicatorPrefix("ifb");
   IndicatorShortName("FiboTools");
   mainSignaler = new Signaler();
   mainSignaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");

   hwnd = WindowHandle(Symbol(), Period());
   if (hwnd > 0)
   {
      GetClientRect(hwnd, rect);
      gPixels = rect[2];
      vPixels = rect[3];
   }
   int id = 0;

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
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
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

   for (int i = ObjectsTotal() - 1; i > -1; i--)
   {
      if (StringFind(ObjectName(i), "  ") >= 0)
         ObjectDelete(ObjectName(i));
   }
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   //---
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = Bars - 1 - counted_bars;
   if (MaxBars > 0 && limit > MaxBars)
      limit = MaxBars;
   FixedPeriod = _FixedPeriod;
   if (FixedPeriod == 0)
      FixedPeriod = (ENUM_TIMEFRAMES)Period();
   int n = 0;
   // Call ZigZag
   for (int i = 0; i < limit; i++)
   {
      double zz = iCustom(NULL, FixedPeriod, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, i);
      if (zz != 0 && zz != EMPTY_VALUE)
      {
         zValue[n] = zz;
         zTime[n] = iTime(NULL, FixedPeriod, i);
         n++;
         if (n >= 5)
         {
            break;
         }
      }
   }
   //---
   FibonacciTools();
   HighAndLow();
   //---
   if (ShowCanldeTime)
      CandleTimeLeft();

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
   limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
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
   //--- return value of prev_calculated for next call
   return (rates_total);
}
//|--------------------------------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                                                      |
//|--------------------------------------------------------------------------------------------------------------------|
//+------------------------------------------------------------------+
//|  Fibonacci Tools                                                 |
//+------------------------------------------------------------------+
void FibonacciTools()
{
   //---
   if (ShowRetracement)
   {
      DrawRetracement(FibRetracement, "FR ", rColor, rWidth, rStyle, zTime[1], zValue[1], zTime[0], zValue[0]);
   }
   if (ShowArc)
   {
      DrawArc(FibArc, "FA", aColor, aWidth, aStyle, zTime[1], zValue[1], zTime[0], zValue[0]);
   }
   if (ShowFan)
   {
      DrawFan(FibFan, "FF ", fColor, fWidth, fStyle, zTime[1], zValue[1], zTime[0], zValue[0]);
   }
   if (ShowZone)
   {
      DrawZone(FibZone, "FZ ", zColor, zWidth, zStyle, zTime[1], zValue[1], zTime[0], zValue[0]);
   }
   if (ShowExpansion)
   {
      DrawExpansion(FibExpansion, "FE ", eColor, eWidth, eStyle, zTime[3], zValue[3], zTime[2], zValue[2], zTime[1], zValue[1]);
   }
   if (ShowPattern)
   {
      ObjectDelete(A);
      ObjectCreate(A, OBJ_TRIANGLE, 0, zTime[4], zValue[4], zTime[3], zValue[3], zTime[2], zValue[2]);
      ObjectSet(A, OBJPROP_COLOR, pColor);
      //---
      ObjectDelete(B);
      ObjectCreate(B, OBJ_TRIANGLE, 0, zTime[2], zValue[2], zTime[1], zValue[1], zTime[0], zValue[0]);
      ObjectSet(B, OBJPROP_COLOR, pColor);
   }
}
//+------------------------------------------------------------------+
//|  Daily, Weekly, Monthly high and low lines                       |
//+------------------------------------------------------------------+

void HighAndLow()
{
   //---
   //--- daily:
   DayHigh = iHigh(NULL, PERIOD_D1, 1);
   DayLow = iLow(NULL, PERIOD_D1, 1);
   DayClose = iClose(NULL, PERIOD_D1, 1);
   DayPivot = (DayHigh + DayLow + DayClose) / 3;
   //--- weekly
   WeekHigh = iHigh(NULL, PERIOD_W1, 1);
   WeekLow = iLow(NULL, PERIOD_W1, 1);
   //WeekClose  = iClose(NULL, PERIOD_W1, 1);
   //--- monthly
   MonthHigh = iHigh(NULL, PERIOD_MN1, 1);
   MonthLow = iLow(NULL, PERIOD_MN1, 1);
   //MonthClose = iClose(NULL, PERIOD_MN1, 1);
   //---
   if (ShowDaily && Period() < 1440)
   {
      DrawTrend(DayHighName, DayHighLabel, DayStyle, DayColor, DayWidth, DayHigh);
      DrawTrend(DayLowName, DayLowLabel, DayStyle, DayColor, DayWidth, DayLow);
      if (ShowPivot)
         DrawTrend(PivotName, PivotLabel, PivotStyle, PivotColor, PivotWidth, DayPivot);
   }
   if (ShowWeekly && Period() < 10080)
   {
      DrawTrend(WeekHighName, WeekHighLabel, WeekStyle, WeekColor, WeekWidth, WeekHigh);
      DrawTrend(WeekLowName, WeekLowLabel, WeekStyle, WeekColor, WeekWidth, WeekLow);
      if (WeekLow == DayLow)
         WeekLow = WeekLow - Time[0] + Period() * 50;
      if (WeekHigh == DayHigh)
         WeekHigh = WeekHigh + Time[0] + Period() * 50;
   }
   if (ShowMonthly && Period() < 43200)
   {
      DrawTrend(MonthHighName, MonthHighLabel, MonthStyle, MonthColor, MonthWidth, MonthHigh);
      DrawTrend(MonthLowName, MonthLowLabel, MonthStyle, MonthColor, MonthWidth, MonthLow);
      if (MonthLow == DayLow)
         MonthLow = MonthLow - Time[0] + Period() * 50;
      if (MonthHigh == DayHigh)
         MonthHigh = MonthHigh + Time[0] + Period() * 50;
   }
}
//+------------------------------------------------------------------+
//|  1- Draw Retracement                                             |
//+------------------------------------------------------------------+
void DrawRetracement(string name, string label, color clr, int width, int style, datetime t1, double p1, datetime t2, double p2)
{
   //---
   ObjectDelete(name);
   ObjectCreate(name, OBJ_FIBO, 0, t1, p1, t2, p2);
   if (ExtraLevels)
      ObjectSet(name, OBJPROP_FIBOLEVELS, 10);
   else
      ObjectSet(name, OBJPROP_FIBOLEVELS, 5);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 0, l0);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 1, l38);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 2, l50);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 3, l61);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 4, l100);
   //--- Extra
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 5, l14);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 6, l23);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 7, l74);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 8, l88);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 9, l127);
   //---
   ObjectSet(name, OBJPROP_LEVELCOLOR, clr);
   ObjectSet(name, OBJPROP_LEVELWIDTH, width);
   ObjectSet(name, OBJPROP_LEVELSTYLE, style);
   ObjectSet(name, OBJPROP_COLOR, clr);
   //---
   string prices = "";
   if (LevelPrice)
      prices = " --> %$  ";
   ObjectSetFiboDescription(name, 0, label + "  " + DoubleToStr(l0 * 100, 1) + "  " + prices);
   ObjectSetFiboDescription(name, 1, label + "  " + DoubleToStr(l38 * 100, 1) + "  " + prices);
   ObjectSetFiboDescription(name, 2, label + "  " + DoubleToStr(l50 * 100, 1) + "  " + prices);
   ObjectSetFiboDescription(name, 3, label + "  " + DoubleToStr(l61 * 100, 1) + "  " + prices);
   ObjectSetFiboDescription(name, 4, label + "  " + DoubleToStr(l100 * 100, 1) + "  " + prices);
   //--- Extra
   ObjectSetFiboDescription(name, 5, label + "  " + DoubleToStr(l14 * 100, 1) + "  " + prices);
   ObjectSetFiboDescription(name, 6, label + "  " + DoubleToStr(l23 * 100, 1) + "  " + prices);
   ObjectSetFiboDescription(name, 7, label + "  " + DoubleToStr(l74 * 100, 1) + "  " + prices);
   ObjectSetFiboDescription(name, 8, label + "  " + DoubleToStr(l88 * 100, 1) + "  " + prices);
   ObjectSetFiboDescription(name, 9, label + "  " + DoubleToStr(l127 * 100, 1) + "  " + prices);
}
//+------------------------------------------------------------------+
//|  2- Draw Fibonacci Arc                                           |
//+------------------------------------------------------------------+
void DrawArc(string name, string label, color clr, int width, int style, datetime t1, double p1, datetime t2, double p2)
{
   //---
   ObjectDelete(name);
   ObjectCreate(name, OBJ_FIBOARC, 0, t1, p1, t2, p2);
   if (ExtraARC)
      ObjectSet(name, OBJPROP_FIBOLEVELS, 6);
   else
      ObjectSet(name, OBJPROP_FIBOLEVELS, 3);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 0, ARC38);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 1, ARC50);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 2, ARC61);
   //--- Extra
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 3, ARC14);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 4, ARC23);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 5, ARC74);
   //---
   ObjectSet(name, OBJPROP_LEVELCOLOR, clr);
   ObjectSet(name, OBJPROP_LEVELWIDTH, width);
   ObjectSet(name, OBJPROP_LEVELSTYLE, style);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_ELLIPSE, false);
   ObjectSet(name, OBJPROP_SCALE, FibArcScale());
   //---
   ObjectSetFiboDescription(name, 0, label + "  " + DoubleToStr(ARC38 * 100, 1));
   ObjectSetFiboDescription(name, 1, label + "  " + DoubleToStr(ARC50 * 100, 1));
   ObjectSetFiboDescription(name, 2, label + "  " + DoubleToStr(ARC61 * 100, 1));
   //--- Extra
   ObjectSetFiboDescription(name, 3, label + "  " + DoubleToStr(ARC14 * 100, 1));
   ObjectSetFiboDescription(name, 4, label + "  " + DoubleToStr(ARC23 * 100, 1));
   ObjectSetFiboDescription(name, 5, label + "  " + DoubleToStr(ARC74 * 100, 1));
}
//+------------------------------------------------------------------+
//|  3- Draw Fibonacci Fan                                           |
//+------------------------------------------------------------------+
void DrawFan(string name, string label, color clr, int width, int style, datetime t1, double p1, datetime t2, double p2)
{
   //---
   ObjectDelete(name);
   ObjectCreate(name, OBJ_FIBOFAN, 0, t1, p1, t2, p2);
   if (ExtraFAN)
      ObjectSet(name, OBJPROP_FIBOLEVELS, 6);
   else
      ObjectSet(name, OBJPROP_FIBOLEVELS, 3);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 0, FAN38);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 1, FAN50);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 2, FAN61);
   //--- Extra
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 3, FAN14);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 4, FAN23);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 5, FAN74);
   //---
   ObjectSet(name, OBJPROP_LEVELCOLOR, clr);
   ObjectSet(name, OBJPROP_LEVELWIDTH, width);
   ObjectSet(name, OBJPROP_LEVELSTYLE, style);
   ObjectSet(name, OBJPROP_COLOR, clr);
   //---
   ObjectSetFiboDescription(name, 0, label + "  " + DoubleToStr(FAN38 * 100, 1));
   ObjectSetFiboDescription(name, 1, label + "  " + DoubleToStr(FAN50 * 100, 1));
   ObjectSetFiboDescription(name, 2, label + "  " + DoubleToStr(FAN61 * 100, 1));
   //--- Extra
   ObjectSetFiboDescription(name, 3, label + "  " + DoubleToStr(FAN14 * 100, 1));
   ObjectSetFiboDescription(name, 4, label + "  " + DoubleToStr(FAN23 * 100, 1));
   ObjectSetFiboDescription(name, 5, label + "  " + DoubleToStr(FAN74 * 100, 1));
}
//+------------------------------------------------------------------+
//|  4- Draw Fibonacci Time Zones                                    |
//+------------------------------------------------------------------+
void DrawZone(string name, string label, color clr, int width, int style, datetime t1, double p1, datetime t2, double p2)
{
   //---
   ObjectDelete(name);
   ObjectCreate(name, OBJ_FIBOTIMES, 0, t1, p1, t2, p2);
   ObjectSet(name, OBJPROP_FIBOLEVELS, 9);
   // 1, 2, 3, 5, 8, 13, 21, 34
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 0, Zone0);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 1, Zone1);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 2, Zone2);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 3, Zone3);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 4, Zone5);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 5, Zone8);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 6, Zone13);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 7, Zone21);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 8, Zone34);
   //---
   ObjectSet(name, OBJPROP_LEVELCOLOR, clr);
   ObjectSet(name, OBJPROP_LEVELWIDTH, width);
   ObjectSet(name, OBJPROP_LEVELSTYLE, style);
   ObjectSet(name, OBJPROP_COLOR, clr);
   //---
   ObjectSetFiboDescription(name, 0, label + "  " + DoubleToStr(Zone0 * 100, 1));
   ObjectSetFiboDescription(name, 1, label + "  " + DoubleToStr(Zone1 * 100, 1));
   ObjectSetFiboDescription(name, 2, label + "  " + DoubleToStr(Zone2 * 100, 1));
   ObjectSetFiboDescription(name, 3, label + "  " + DoubleToStr(Zone3 * 100, 1));
   ObjectSetFiboDescription(name, 4, label + "  " + DoubleToStr(Zone5 * 100, 1));
   ObjectSetFiboDescription(name, 5, label + "  " + DoubleToStr(Zone8 * 100, 1));
   ObjectSetFiboDescription(name, 6, label + "  " + DoubleToStr(Zone13 * 100, 1));
   ObjectSetFiboDescription(name, 7, label + "  " + DoubleToStr(Zone21 * 100, 1));
   ObjectSetFiboDescription(name, 8, label + "  " + DoubleToStr(Zone34 * 100, 1));
}
//+------------------------------------------------------------------+
//|  5- Draw Fibonacci Expansion                                     |
//+------------------------------------------------------------------+
void DrawExpansion(string name, string label, color clr, int width, int style, datetime t1, double p1, datetime t2, double p2, datetime t3, double p3)
{
   //---
   ObjectDelete(name);
   ObjectCreate(name, OBJ_EXPANSION, 0, t1, p1, t2, p2, t3, p3);
   ObjectSet(name, OBJPROP_FIBOLEVELS, 7);
   if (ExtraEXP)
      ObjectSet(name, OBJPROP_FIBOLEVELS, 7);
   else
      ObjectSet(name, OBJPROP_FIBOLEVELS, 4);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 0, EXP61);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 1, EXP100);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 2, EXP161);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 3, EXP261);
   //---Extra
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 4, EXP78);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 5, EXP138);
   ObjectSet(name, OBJPROP_FIRSTLEVEL + 6, EXP200);
   //---
   ObjectSet(name, OBJPROP_LEVELCOLOR, clr);
   ObjectSet(name, OBJPROP_LEVELWIDTH, width);
   ObjectSet(name, OBJPROP_LEVELSTYLE, style);
   ObjectSet(name, OBJPROP_COLOR, clr);
   //---
   ObjectSetFiboDescription(name, 0, label + "  " + DoubleToStr(EXP61 * 100, 1) + "  ");
   ObjectSetFiboDescription(name, 1, label + "  " + DoubleToStr(EXP100 * 100, 1) + "  ");
   ObjectSetFiboDescription(name, 2, label + "  " + DoubleToStr(EXP161 * 100, 1) + "  ");
   ObjectSetFiboDescription(name, 3, label + "  " + DoubleToStr(EXP261 * 100, 1) + "  ");
   //---Extra
   ObjectSetFiboDescription(name, 4, label + "  " + DoubleToStr(EXP78 * 100, 1) + "  ");
   ObjectSetFiboDescription(name, 5, label + "  " + DoubleToStr(EXP138 * 100, 1) + "  ");
   ObjectSetFiboDescription(name, 6, label + "  " + DoubleToStr(EXP200 * 100, 1) + "  ");
}
//+------------------------------------------------------------------+
//|  Draw High/Low lines                                             |
//+------------------------------------------------------------------+
void DrawTrend(string name, string label, int style, color clr, int width, double price)
{
   //---
   datetime startline = iTime(NULL, 1440, 0) - 3600;
   datetime stopline = iTime(NULL, 240, 0) + 43200;
   //---
   ObjectDelete(name);
   ObjectCreate(name, OBJ_TREND, 0, startline, price, stopline, price);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, false);
   if (ObjectFind(label) != 0)
   {
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TEXT, 0, startline, price, stopline, price);
      ObjectSetText(label, label, 7, "Verdana", clrDarkGray);
   }
   else
   {
      ObjectMove(label, 0, startline, price);
   }
}
//+------------------------------------------------------------------+
//|  determine Scale for Fibo Arc                                    |
//+------------------------------------------------------------------+
double FibArcScale()
{
   //---
   //--- Scale Calculation
   double AutoScale = 0;
   //---
   if (ScaleMethod == ClientRect)
   {
      double priceRange, barsCount, chartScale;
      priceRange = WindowPriceMax(0) - WindowPriceMin(0);
      barsCount = WindowBarsPerChart();
      chartScale = (priceRange / Point) / barsCount;
      if (!IsDllsAllowed())
      {
         Alert("DLL imports is not allowed! Please Allow DLL imports in Common tab of indicator properties and try again.");
         return (0);
      }
      AutoScale = chartScale * gPixels / vPixels;
   }
   else if (ScaleMethod == Math)
   {
      double ScaleValue, ScaleTime;
      ScaleValue = MathAbs(zValue[1] - zValue[0]) / Point;
      ScaleTime = MathAbs(iBarShift(Symbol(), Period(), zTime[1]) - iBarShift(Symbol(), Period(), zTime[0]));
      AutoScale = ScaleValue / ScaleTime;
   }
   else if (ScaleMethod == Manual && ManualScale > 0)
      AutoScale = ManualScale;
   //---
   return (AutoScale);
}
//+------------------------------------------------------------------+
//| Show Candle Time Left                                            |
//+------------------------------------------------------------------+
void CandleTimeLeft()
{
   //---
   string TimeLeft;
   int offset;
   TimeLeft = TimeToStr(Time[0] + Period() * 60 - TimeCurrent(), TIME_MINUTES | TIME_SECONDS);
   offset = Period() * 150;
   ObjectDelete(Timer);
   ObjectCreate(Timer, OBJ_TEXT, 0, Time[0] + offset, Close[0]);
   ObjectSetText(Timer, TimeLeft, TimerFontSize, "Calibri", TimerColor);
}
//|--------------------------------------------------------------------------------------------------------------------|
//|                                                      E N D                                                         |
//|--------------------------------------------------------------------------------------------------------------------|
