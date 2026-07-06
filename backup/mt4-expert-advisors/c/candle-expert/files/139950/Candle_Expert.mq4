// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70775

//+------------------------------------------------------------------+
//|                               Copyright � 2020, Gehtsoft USA LLC |
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

#property copyright "Copyright � 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

input double upper_line = 0; // Initial upper level line
input double lower_line = 0; // Initial lower level line
input double prev_buy_point = 0; // Previous call point
input double prev_sell_point = 0; // Previous short point
input color main_line_color = White; // Main line color
input color half_line_color = Red; // Half level line color
input color neutral_buy_color = Lime; // Neutral buy color
input color neutral_sell_color = Pink; // Neutral sell color
input color ref_buy_color = Green; // Referential buy color
input color ref_sell_color = Red; // Referential sell color

int lines = 10;
string EA_ID = "Candle_Expert";
double neutralLevel;
double referentialLevel;
double protectionLine;
double upperLine;
double lowerLine;

void DrawLine(string id, double price, color clr, int width, ENUM_LINE_STYLE style)
{
   ResetLastError();
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, iTime(_Symbol, _Period, iBars(_Symbol, _Period) - 1), price, iTime(_Symbol, _Period, 0), price))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, style);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, true);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, price);
   ObjectSetInteger(0, id, OBJPROP_TIME1, iTime(_Symbol, _Period, iBars(_Symbol, _Period) - 1));
   ObjectSetInteger(0, id, OBJPROP_TIME2, iTime(_Symbol, _Period, 0));
}

void DrawRect(string id, double from, double to, color clr)
{
   ResetLastError();
   datetime dateFrom = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - 1);
   datetime dateTo = iTime(_Symbol, _Period, 0);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_RECTANGLE, 0, dateFrom, from, dateTo, to))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_FILL, true);
      ObjectSetInteger(0, id, OBJPROP_BACK, true);
   }
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
   ObjectSetDouble(0, id, OBJPROP_PRICE1, from);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, to);
   ObjectSetInteger(0, id, OBJPROP_TIME1, dateFrom);
   ObjectSetInteger(0, id, OBJPROP_TIME2, dateTo);
}

void DrawLines()
{
   double range = upperLine - lowerLine;
   DrawLine(EA_ID + "c", (upperLine + lowerLine) / 2, half_line_color, 1, STYLE_DASH);
   for (int i = 0; i < lines; ++i)
   {
      DrawLine(EA_ID + "u" + IntegerToString(i), upperLine + range * i, main_line_color, 2, STYLE_SOLID);
      DrawLine(EA_ID + "d" + IntegerToString(i), lowerLine - range * i, main_line_color, 2, STYLE_SOLID);
      DrawLine(EA_ID + "hu" + IntegerToString(i), upperLine + range * i - range / 2, half_line_color, 1, STYLE_DASH);
      DrawLine(EA_ID + "hd" + IntegerToString(i), lowerLine - range * i + range / 2, half_line_color, 1, STYLE_DASH);
   }
   double center = (neutralLevel + referentialLevel) / 2;
   if (neutralLevel > referentialLevel)
   {
      DrawRect(EA_ID + "nr", neutralLevel, center, neutral_sell_color);
      DrawRect(EA_ID + "rr", referentialLevel, center, ref_sell_color);
   }
   else
   {
      DrawRect(EA_ID + "nr", neutralLevel, center, neutral_buy_color);
      DrawRect(EA_ID + "rr", referentialLevel, center, ref_buy_color);
   }
}

#define ACT_ON_SWITCH_CONDITION
#define SHOW_ACCOUNT_STAT
#define REVERSABLE_LOGIC_FEATURE
#define STOP_LOSS_FEATURE
#define TAKE_PROFIT_FEATURE
#define USE_MARKET_ORDERS
#define TRADING_TIME_FEATURE
#define POSITION_CAP_FEATURE 
#define WITH_EXIT_LOGIC

#ifdef SHOW_ACCOUNT_STAT
   string EA_NAME = "Candle Expert";
#endif

enum TradingMode
{
   TradingModeLive, // Live
   TradingModeOnBarClose // On bar close
};

input string GeneralSection = ""; // == General ==
input string GeneralSectionDesc = "https://github.com/sibvic/mq4-templates/wiki/EA_Base-template-parameters"; // Description of parameters could be found at
input ENUM_TIMEFRAMES trading_timeframe = PERIOD_CURRENT; // Trading timeframe
input bool ecn_broker = false; // ECN Broker? 
input TradingMode entry_logic = TradingModeLive; // Entry logic
#ifdef WITH_EXIT_LOGIC
   input TradingMode exit_logic = TradingModeLive; // Exit logic
#endif
// Supported position size types v1.0

#ifndef PositionSizeType_IMP
#define PositionSizeType_IMP

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
   PositionSizeRiskBalance, // Risk in % of balance
   PositionSizeRiskCurrency // Risk in $
};

#endif
enum LogicDirection
{
   DirectLogic, // Direct
   ReversalLogic // Reversal
};
enum TradingSide
{
   LongSideOnly, // Long
   ShortSideOnly, // Short
   BothSides // Both
};
input double lots_value = 0.1; // Position size
input PositionSizeType lots_type = PositionSizeContract; // Position size type
input int slippage_points = 3; // Slippage, points
input TradingSide trading_side = BothSides; // What trades should be taken
#ifdef REVERSABLE_LOGIC_FEATURE
   input LogicDirection logic_direction = DirectLogic; // Logic type
#else
   LogicDirection logic_direction = DirectLogic;
#endif
#ifdef USE_MARKET_ORDERS
   input bool close_on_opposite = true; // Close on opposite signal
#else
   bool close_on_opposite = false;
#endif

#ifdef POSITION_CAP_FEATURE
   input string CapSection = ""; // == Position cap ==
   bool position_cap = false; // Position Cap
   int no_of_positions = 2; // Max # of buy+sell positions
   int no_of_buy_position = 1; // Max # of buy positions
   int no_of_sell_position = 1; // Max # of sell positions
   input bool cap_by_margin = false; // Cap by usable margin
   input double min_margin = 50; // Min usable margin
#endif

enum MartingaleType
{
   MartingaleDoNotUse, // Do not use
   MartingaleOnLoss // Open another position on loss
};
enum MartingaleLotSizingType
{
   MartingaleLotSizingNo, // No lot sizing
   MartingaleLotSizingMultiplicator, // Using miltiplicator
   MartingaleLotSizingAdd // Addition
};
enum MartingaleStepSizeType
{
   MartingaleStepSizePips, // Pips
   MartingaleStepSizePercent, // %
};
#ifdef MARTINGALE_FEATURE
   input string MartingaleSection = ""; // == Martingale type ==
   input MartingaleType martingale_type = MartingaleDoNotUse; // Martingale type
   input MartingaleLotSizingType martingale_lot_sizing_type = MartingaleLotSizingNo; // Martingale lot sizing type
   input double martingale_lot_value = 1.5; // Matringale lot sizing value
   MartingaleStepSizeType martingale_step_type = MartingaleStepSizePips; // Step unit
   input double martingale_step = 50; // Open matringale position step
   input int max_longs = 5; // Max long positions
   input int max_shorts = 5; // Max short positions
#endif

enum TrailingType
{
   TrailingDontUse, // No trailing
   TrailingPips, // Use trailing in pips
   TrailingATR, // Use trailing with ATR start
   TrailingSLPercent, // Use trailing, in % of stop loss
};
// Supported stop loss types v1.0

#ifndef StopLossType_IMP
#define StopLossType_IMP

enum StopLossType
{
   SLDoNotUse, // Do not use
   SLPercent, // Set in %
   SLPips, // Set in Pips
   SLDollar, // Set in $,
   SLAbsolute, // Set in absolite value (rate),
   SLAtr, // Set in ATR(value) * mult,
   SLHighLow, // High/low of X bars
   SLRiskBalance // Set in % of risked balance
};

#endif
// Supported stop loss/take profit types (outdated) v1.0

#ifndef StopLimitType_IMP
#define StopLimitType_IMP

enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $,
   StopLimitRiskReward, // Set in % of stop loss (take profit only)
   StopLimitAbsolute // Set in absolite value (rate)
};

#endif

#ifndef MATypes_IMP
#define MATypes_IMP

enum MATypes
{
   ma_sma,     // Simple moving average - SMA
   ma_ema,     // Exponential moving average - EMA
   //ma_dsema,   // Double smoothed exponential moving average - DSEMA
   //ma_dema,    // Double exponential moving average - DEMA
   ma_tema,    // Tripple exponential moving average - TEMA
   //ma_smma,    // Smoothed moving average - SMMA
   ma_lwma,    // Linear weighted moving average - LWMA
   //ma_pwma,    // Parabolic weighted moving average - PWMA
   //ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // Volume weighted moving average - VWMA
   //ma_hull,    // Hull moving average
   //ma_tma,     // Triangular moving average
   //ma_sine,    // Sine weighted moving average
   //ma_linr,    // Linear regression value
   //ma_ie2,     // IE/2
   //ma_nlma,    // Non lag moving average
   ma_zlma,    // Zero lag moving average
   //ma_lead,    // Leader exponential moving average
   //ma_ssm,     // Super smoother
   //ma_smoo,     // Smoother,
   ma_zltema, // Zero lag TEMA
   ma_rma // RMA
};

#endif
enum TrailingTargetType
{
   TrailingTargetStep, // Move each n pips
   TrailingTargetMA, // Sync with MA
};
#ifdef STOP_LOSS_FEATURE
   string StopLossSection            = ""; // == Stop loss ==
   input StopLossType stop_loss_type = SLDoNotUse; // Stop loss type
   input double stop_loss_value = 10; // Stop loss value
   input double stop_loss_atr_multiplicator = 1; // Stop loss multiplicator (for ATR SL)
   input TrailingType trailing_type = TrailingDontUse; // Trailing start type
   input double trailing_start = 0; // Min distance to order to activate the trailing
   input TrailingTargetType trailing_target_type = TrailingTargetStep; // Trailing target
   input double trailing_step = 10; // Trailing step
   input int trailing_ma_length = 14; // Trailing MA Length
   input MATypes trailing_ma_type = ma_sma; // Trailing MA Type
#else
   StopLossType stop_loss_type = SLDoNotUse; // Stop loss type
   double stop_loss_value = 10;
#endif
input string BreakevenSection = ""; // == Breakeven ==
input StopLimitType breakeven_type = StopLimitDoNotUse; // Trigger type for the breakeven
input double breakeven_value = 10; // Trigger for the breakeven
input double breakeven_level = 0; // Breakeven target
#ifdef NET_STOP_LOSS_FEATURE
   input string NetStopSection = ""; // == Net stop ==
   input StopLimitType net_stop_loss_type = StopLimitDoNotUse; // Net stop loss type
   input double net_stop_loss_value = 10; // Net stop loss value
#endif

#ifndef TakeProfitType_IMP
#define TakeProfitType_IMP
enum TakeProfitType
{
   TPDoNotUse, // Do not use
   TPPercent, // Set in %
   TPPips, // Set in Pips
   TPDollar, // Set in $,
   TPRiskReward, // Set in % of stop loss
   TPAbsolute, // Set in absolite value (rate),
   TPAtr // Set in ATR(value) * mult
};
#endif
#ifdef TAKE_PROFIT_FEATURE
   input string TakeProfitSection            = ""; // == Take Profit ==
   input TakeProfitType take_profit_type = TPDoNotUse; // Take profit type
   input double take_profit_value = 10; // Take profit value
   input double take_profit_atr_multiplicator = 1; // Take profit multiplicator (for ATR TP)
#else
   TakeProfitType take_profit_type = TPDoNotUse;
   double take_profit_value = 10;
   double take_profit_atr_multiplicator = 1;
#endif
#ifdef NET_TAKE_PROFIT_FEATURE
   input string NetTakeProfitSection            = ""; // == Net Take Profit ==
   input StopLimitType net_take_profit_type = StopLimitDoNotUse; // Net take profit type
   input double net_take_profit_value = 10; // Net take profit value
#endif

// Day of week v1.0

#ifndef DayOfWeek_IMP
   enum DayOfWeek
   {
      DayOfWeekSunday = 0, // Sunday
      DayOfWeekMonday = 1, // Monday
      DayOfWeekTuesday = 2, // Tuesday
      DayOfWeekWednesday = 3, // Wednesday
      DayOfWeekThursday = 4, // Thursday
      DayOfWeekFriday = 5, // Friday
      DayOfWeekSaturday = 6 // Saturday
   };
   #define DayOfWeek_IMP
#endif
input string OtherSection            = ""; // == Other ==
input int magic_number        = 42; // Magic number
input string trade_comment = ""; // Comment for orders
#ifdef TRADING_TIME_FEATURE
   input string start_time = "000000"; // Start time in hhmmss format
   input string stop_time = "000000"; // Stop time in hhmmss format
   input bool mandatory_closing = false; // Mandatory closing for non-trading time
#else
   string start_time = "000000"; // Start time in hhmmss format
   string stop_time = "000000"; // Stop time in hhmmss format
   bool mandatory_closing = false;
#endif
#ifdef WEEKLY_TRADING_TIME_FEATURE
   input bool use_weekly_timing = false; // Weekly time
   input DayOfWeek week_start_day = DayOfWeekSunday; // Start day
   input string week_start_time = "000000"; // Start time in hhmmss format
   input DayOfWeek week_stop_day = DayOfWeekSaturday; // Stop day
   input string week_stop_time = "235959"; // Stop time in hhmmss format
#else
   bool use_weekly_timing = false; // Weekly time
   DayOfWeek week_start_day = DayOfWeekSunday; // Start day
   string week_start_time = "000000"; // Start time in hhmmss format
   DayOfWeek week_stop_day = DayOfWeekSaturday; // Stop day
   string week_stop_time = "235959"; // Stop time in hhmmss format
#endif
input bool print_log = false; // Print decisions into the log
input string log_file = "log.csv"; // Log file name (empty for auto naming)

#ifdef SHOW_ACCOUNT_STAT
   input string   DashboardSection            = ""; // == Dashboard ==
   input color color_text = White; // General text color
   input color color_buy_signal = Green; // Buy signal color
   input color color_sell_signal = Red; // Sell signal color
   input color color_profit = Green; // Profit color
   input color color_loss = Red; // Loss color
   input color background_color = DarkBlue; // Background color
   input int x = 50; // Dashboard X coordinate
   input int y = 50; // Dashboard Y coordinate
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
// Act on switch condition v4.2

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
// Disabled condition v3.0



#ifndef DisabledCondition_IMP
#define DisabledCondition_IMP
class DisabledCondition : public AConditionBase
{
public:
   bool IsPass(const int period, const datetime date) { return false; }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Disabled";
   }
};
#endif
// v1.0

#ifndef MinMarginCondition_IMP
#define MinMarginCondition_IMP
class MinMarginCondition : public AConditionBase
{
   datetime _minMargin;
public:
   MinMarginCondition(double minMargin)
      :AConditionBase("Min margin")
   {
      _minMargin = minMargin;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      return (100 * AccountFreeMargin() / AccountEquity()) >= _minMargin;
   }
};
#endif
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
// Price stream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
// Stream base v1.0



#ifndef AStreamBase_IMP
#define AStreamBase_IMP

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
#endif

// IBarStream v2.1



#ifndef IBarStream_IMP
#define IBarStream_IMP

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

class PriceStream : public AStreamBase
{
   PriceType _price;
   IBarStream* _source;
public:
   PriceStream(IBarStream* source, const PriceType __price)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
      _price = __price;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            if (!_source.GetClose(period, val))
            {
               return false;
            }
            break;
         case PriceOpen:
            if (!_source.GetOpen(period, val))
            {
               return false;
            }
            break;
         case PriceHigh:
            if (!_source.GetHigh(period, val))
            {
               return false;
            }
            break;
         case PriceLow:
            if (!_source.GetLow(period, val))
            {
               return false;
            }
            break;
         case PriceMedian:
            {
               double high, low;
               if (!_source.GetHighLow(period, high, low))
               {
                  return false;
               }
               val = (high + low) / 2.0;
            }
            break;
         case PriceTypical:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open, close;
               if (!_source.GetOpenClose(period, open, close))
               {
                  return false;
               }
               val = (open + close) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close + open) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               if (open > close)
                  val = (high + close) / 2.0;
               else
                  val = (low + close) / 2.0;
            }
            break;
         // case PriceVolume:
         //    if (!_source.GetVolume(period, val))
         //    {
         //       return false;
         //    }
         //    break;
      }
      return true;
   }
};

class SimplePriceStream : public AStream
{
   PriceType _price;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
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
#ifndef USE_MARKET_ORDERS
   class LongEntryStream : public AStream
   {
   public:
      LongEntryStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
         :AStream(symbol, timeframe)
      {
      }

      bool GetValue(const int period, double &val)
      {
         val = iHigh(_symbol, _timeframe, period);
         return true;
      }
   };

   class ShortEntryStream : public AStream
   {
   public:
      ShortEntryStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
         :AStream(symbol, timeframe)
      {
      }

      bool GetValue(const int period, double &val)
      {
         val = iHigh(_symbol, _timeframe, period);
         return true;
      }
   };
#endif

// Orders iterator v 1.12
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

enum CompareType
{
   CompareLessThan,
   CompareMoreThan
};

// Order side enum v1.1

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide, // Buy/long
   SellSide // Sell/short
};

OrderSide GetOppositeSide(OrderSide side)
{
   return side == BuySide ? SellSide : BuySide;
}

#endif

class OrdersIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   bool _useOrderType;
   int _orderType;
   bool _trades;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _useProfit;
   double _profit;
   bool _useComment;
   string _comment;
   CompareType _profitCompare;
   bool _orders;
public:
   OrdersIterator()
   {
      _useOrderType = false;
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _trades = false;
      _useSymbol = false;
      _useProfit = false;
      _orders = false;
      _useComment = false;
   }

   OrdersIterator *WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
      return &this;
   }

   OrdersIterator *WhenProfit(const double profit, const CompareType compare)
   {
      _useProfit = true;
      _profit = profit;
      _profitCompare = compare;
      return &this;
   }

   OrdersIterator *WhenTrade()
   {
      _trades = true;
      return &this;
   }

   OrdersIterator *WhenOrder()
   {
      _orders = true;
      return &this;
   }

   OrdersIterator *WhenSide(const OrderSide side)
   {
      _useSide = true;
      _isBuySide = side == BuySide;
      return &this;
   }

   OrdersIterator *WhenOrderType(const int orderType)
   {
      _useOrderType = true;
      _orderType = orderType;
      return &this;
   }

   OrdersIterator *WhenMagicNumber(const int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
      return &this;
   }

   OrdersIterator *WhenComment(const string comment)
   {
      _useComment = true;
      _comment = comment;
      return &this;
   }

   int GetOrderType() { return OrderType(); }
   double GetProfit() { return OrderProfit(); }
   double IsBuy() { return OrderType() == OP_BUY; }
   double IsSell() { return OrderType() == OP_SELL; }
   int GetTicket() { return OrderTicket(); }
   datetime GetOpenTime() { return OrderOpenTime(); }
   double GetOpenPrice() { return OrderOpenPrice(); }
   double GetStopLoss() { return OrderStopLoss(); }
   double GetTakeProfit() { return OrderTakeProfit(); }
   string GetSymbol() { return OrderSymbol(); }

   int Count()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            count++;
      }
      return count;
   }

   bool Next()
   {
      if (_lastIndex == INT_MIN)
         _lastIndex = OrdersTotal() - 1;
      else
         _lastIndex = _lastIndex - 1;
      while (_lastIndex >= 0)
      {
         if (OrderSelect(_lastIndex, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return true;
      }
      return false;
   }

   int First()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return OrderTicket();
      }
      return -1;
   }

   void Reset()
   {
      _lastIndex = INT_MIN;
   }

private:
   bool PassFilter()
   {
      if (_useMagicNumber && OrderMagicNumber() != _magicNumber)
         return false;
      if (_useOrderType && OrderType() != _orderType)
         return false;
      if (_trades && !IsTrade())
         return false;
      if (_orders && IsTrade())
         return false;
      if (_useSymbol && OrderSymbol() != _symbol)
         return false;
      if (_useProfit)
      {
         switch (_profitCompare)
         {
            case CompareLessThan:
               if (OrderProfit() >= _profit)
               {
                  return false;
               }
               break;
            case CompareMoreThan:
               if (OrderProfit() <= _profit)
               {
                  return false;
               }
               break;
         }
      }
      if (_useSide)
      {
         if (_trades)
         {
            if (_isBuySide && !IsBuy())
               return false;
            if (!_isBuySide && !IsSell())
               return false;
         }
         else
         {
            //TODO: IMPLEMENT!!!!
         }
      }
      if (_useComment && OrderComment() != _comment)
         return false;
      return true;
   }

   bool IsTrade()
   {
      return (OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0.0;
   }
};

#endif
// Trade calculator v2.4
// More templates and snippets on https://github.com/sibvic/mq4-templates







#ifndef TradingCalculator_IMP
#define TradingCalculator_IMP

class TradingCalculator
{
   InstrumentInfo *_symbol;

   TradingCalculator(const string symbol)
   {
      _symbol = new InstrumentInfo(symbol);
   }
public:
   static TradingCalculator *Create(const string symbol)
   {
      ResetLastError();
      double temp = MarketInfo(symbol, MODE_POINT); 
      if (GetLastError() != 0)
         return NULL;

      return new TradingCalculator(symbol);
   }

   ~TradingCalculator()
   {
      delete _symbol;
   }

   double GetPipSize() { return _symbol.GetPipSize(); }
   string GetSymbol() { return _symbol.GetSymbol(); }
   double GetBid() { return _symbol.GetBid(); }
   double GetAsk() { return _symbol.GetAsk(); }
   int GetDigits() { return _symbol.GetDigits(); }
   double GetSpread() { return _symbol.GetSpread(); }
   double GetMinLots() { return _symbol.GetMinLots(); }

   static bool IsBuyOrder()
   {
      switch (OrderType())
      {
         case OP_BUY:
         case OP_BUYLIMIT:
         case OP_BUYSTOP:
            return true;
      }
      return false;
   }

   double GetBreakevenPrice(OrdersIterator &it1, const OrderSide side, double &totalAmount)
   {
      totalAmount = 0.0;
      double lotStep = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_STEP);
      double price = side == BuySide ? _symbol.GetBid() : _symbol.GetAsk();
      double totalPL = 0;
      while (it1.Next())
      {
         double orderLots = OrderLots();
         totalAmount += orderLots / lotStep;
         if (side == BuySide)
            totalPL += (price - OrderOpenPrice()) * (OrderLots() / lotStep);
         else
            totalPL += (OrderOpenPrice() - price) * (OrderLots() / lotStep);
      }
      if (totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return side == BuySide ? price + shift : price - shift;
   }

   double GetBreakevenPrice(const int side, const int magicNumber, double &totalAmount)
   {
      totalAmount = 0.0;
      OrdersIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(_symbol.GetSymbol());
      it1.WhenOrderType(side);
      return GetBreakevenPrice(it1, side == OP_BUY ? BuySide : SellSide, totalAmount);
   }
   
   double CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (takeProfitType)
      {
         case StopLimitPercent:
            return RoundRate(basePrice + basePrice * takeProfit / 100.0 * direction);
         case StopLimitPips:
            return RoundRate(basePrice + takeProfit * _symbol.GetPipSize() * direction);
         case StopLimitDollar:
            return RoundRate(basePrice + CalculateSLShift(amount, takeProfit) * direction);
         case StopLimitAbsolute:
            return takeProfit;
      }
      return 0.0;
   }
   
   double CalculateStopLoss(const bool isBuy, const double stopLoss, const StopLimitType stopLossType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (stopLossType)
      {
         case StopLimitPercent:
            return RoundRate(basePrice - basePrice * stopLoss / 100.0 * direction);
         case StopLimitPips:
            return RoundRate(basePrice - stopLoss * _symbol.GetPipSize() * direction);
         case StopLimitDollar:
            return RoundRate(basePrice - CalculateSLShift(amount, stopLoss) * direction);
         case StopLimitAbsolute:
            return stopLoss;
      }
      return 0.0;
   }

   double GetLots(const PositionSizeType lotsType, const double lotsValue, const double stopDistance)
   {
      switch (lotsType)
      {
         case PositionSizeAmount:
            return GetLotsForMoney(lotsValue);
         case PositionSizeContract:
            return _symbol.NormalizeLots(lotsValue);
         case PositionSizeEquity:
            return GetLotsForMoney(AccountEquity() * lotsValue / 100.0);
         case PositionSizeRiskBalance:
         {
            double affordableLoss = AccountBalance() * lotsValue / 100.0;
            double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
            double tickSize = _symbol.GetTickSize();
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
            {
               return 0;
            }
            return _symbol.NormalizeLots(affordableLoss / possibleLoss);
         }
         case PositionSizeRisk:
         {
            double affordableLoss = AccountEquity() * lotsValue / 100.0;
            double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
            double tickSize = _symbol.GetTickSize();
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
            {
               return 0;
            }
            return _symbol.NormalizeLots(affordableLoss / possibleLoss);
         }
         case PositionSizeRiskCurrency:
         {
            double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
            double tickSize = _symbol.GetTickSize();
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
            {
               return 0;
            }
            return _symbol.NormalizeLots(lotsValue / possibleLoss);
         }
      }
      return lotsValue;
   }

   bool IsLotsValid(const double lots, PositionSizeType lotsType, string &error)
   {
      switch (lotsType)
      {
         case PositionSizeContract:
            return IsContractLotsValid(lots, error);
      }
      return true;
   }

   double NormalizeLots(const double lots)
   {
      return _symbol.NormalizeLots(lots);
   }

   double RoundLots(const double lots)
   {
      return _symbol.RoundLots(lots);
   }

   double RoundRate(const double rate)
   {
      return _symbol.RoundRate(rate);
   }

private:
   bool IsContractLotsValid(const double lots, string &error)
   {
      double minVolume = _symbol.GetMinLots();
      if (minVolume > lots)
      {
         error = "Min. allowed lot size is " + DoubleToString(minVolume);
         return false;
      }
      double maxVolume = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         error = "Max. allowed lot size is " + DoubleToString(maxVolume);
         return false;
      }
      return true;
   }

   double GetLotsForMoney(const double money)
   {
      double marginRequired = MarketInfo(_symbol.GetSymbol(), MODE_MARGINREQUIRED);
      if (marginRequired <= 0.0)
      {
         Print("Margin is 0. Server misconfiguration?");
         return 0.0;
      }
      return _symbol.NormalizeLots(money / marginRequired);
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
      double tickSize = _symbol.GetTickSize();
      return (money / (unitCost / tickSize)) / amount;
   }
};

#endif
// Order v1.1

interface IOrder
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool Select() = 0;
};

class OrderByMagicNumber : public IOrder
{
   int _magicNumber;
   int _references;
public:
   OrderByMagicNumber(int magicNumber)
   {
      _magicNumber = magicNumber;
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

   virtual bool Select()
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber);
      int ticketId = it.First();
      return OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES);
   }
};

class OrderByTicketId : public IOrder
{
   int _ticket;
   int _references;
public:
   OrderByTicketId(int ticket)
   {
      _ticket = ticket;
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

   virtual bool Select()
   {
      return OrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES);
   }
};
// AAction v1.0
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

#ifndef AAction_IMP
#define AAction_IMP

class AAction : public IAction
{
protected:
   int _references;
   AAction()
   {
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
};

#endif
// v2.1
// Used to execute action on orders

#ifndef AOrderAction_IMP

class AOrderAction : public AAction
{
protected:
   int _currentTicket;
public:
   virtual bool DoAction(int ticket)
   {
      _currentTicket = ticket;
      return DoAction(0, 0);
   }

   virtual void RestoreActions(string symbol, int magicNumber) = 0;
};

#define AOrderAction_IMP
#endif
// Trailiong stream action v1.0

class TrailingStreamAction : public AAction
{
   IOrder* _order;
   InstrumentInfo* _instrument;
   IStream* _stream;
public:
   TrailingStreamAction(IOrder* order, IStream* stream)
   {
      _stream = stream;
      _stream.AddRef();
      _order = order;
      _order.AddRef();
      _instrument = NULL;
   }

   ~TrailingStreamAction()
   {
      _stream.Release();
      _order.Release();
      delete _instrument;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!_order.Select())
      {
         return true;
      }

      double newStop;
      if (!_stream.GetValue(period, newStop) || newStop == 0.0)
      {
         return false;
      }
      
      string error;
      TradingCommands::MoveSL(OrderTicket(), newStop, error);
      
      return false;
   }
};

// Action on condition logic v2.0



// Action on condition controller interface v1.0

#ifndef IActionOnConditionController_IMP
#define IActionOnConditionController_IMP

class IActionOnConditionController
{
public:
   virtual bool Set(IAction* action, ICondition *condition) = 0;
   virtual void DoLogic(const int period, datetime date) = 0;
};

#endif

// Action on condition v3.0

#ifndef ActionOnConditionController_IMP
#define ActionOnConditionController_IMP

class ActionOnConditionController : public IActionOnConditionController
{
   bool _finished;
   ICondition *_condition;
   IAction* _action;
public:
   ActionOnConditionController()
   {
      _action = NULL;
      _condition = NULL;
      _finished = true;
   }

   ~ActionOnConditionController()
   {
      _action.Release();
      _condition.Release();
   }
   
   bool Set(IAction* action, ICondition *condition)
   {
      if (!_finished || action == NULL)
         return false;

      if (_action != NULL)
         _action.Release();
      _action = action;
      _action.AddRef();
      _finished = false;
      if (_condition != NULL)
         _condition.Release();
      _condition = condition;
      _condition.AddRef();
      return true;
   }

   void DoLogic(const int period, datetime date)
   {
      if (_finished)
         return;

      if (_condition.IsPass(period, date) && _action.DoAction(period, date))
      {
         _finished = true;
      }
   }
};

#endif




// Multi action on condition v1.0

#ifndef MultiActionOnConditionController_IMP
#define MultiActionOnConditionController_IMP

class MultiActionOnConditionController : public IActionOnConditionController
{
   ICondition *_condition;
   IAction* _action;
public:
   MultiActionOnConditionController()
   {
      _action = NULL;
      _condition = NULL;
   }

   ~MultiActionOnConditionController()
   {
      _action.Release();
      _condition.Release();
   }
   
   bool Set(IAction* action, ICondition *condition)
   {
      if (action == NULL)
      {
         return false;
      }

      if (_action != NULL)
      {
         _action.Release();
      }
      _action = action;
      _action.AddRef();
      if (_condition != NULL)
      {
         _condition.Release();
      }
      _condition = condition;
      _condition.AddRef();
      return true;
   }

   void DoLogic(const int period, datetime date)
   {
      if (_condition.IsPass(period, date))
      {
         _action.DoAction(period, date);
      }
   }
};

#endif

#ifndef ActionOnConditionLogic_IMP
#define ActionOnConditionLogic_IMP

class ActionOnConditionLogic
{
   IActionOnConditionController* _controllers[];
public:
   ~ActionOnConditionLogic()
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         delete _controllers[i];
      }
   }

   void DoLogic(const int period, datetime date)
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         _controllers[i].DoLogic(period, date);
      }
   }

   bool AddActionOnCondition(IAction* action, ICondition* condition)
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         if (_controllers[i].Set(action, condition))
            return true;
      }

      ArrayResize(_controllers, count + 1);
      _controllers[count] = new ActionOnConditionController();
      return _controllers[count].Set(action, condition);
   }

   bool AddMultiActionOnCondition(IAction* action, ICondition* condition)
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         if (_controllers[i].Set(action, condition))
            return true;
      }

      ArrayResize(_controllers, count + 1);
      _controllers[count] = new MultiActionOnConditionController();
      return _controllers[count].Set(action, condition);
   }
};

#endif
// v1.0

#ifndef CreateTrailingStreamAction_IMP
#define CreateTrailingStreamAction_IMP

class CreateTrailingStreamAction : public AOrderAction
{
   double _start;
   IStream* _stream;
   bool _startInPercent;
   ActionOnConditionLogic* _actions;
public:
   CreateTrailingStreamAction(double start, bool startInPercent, IStream* stream, ActionOnConditionLogic* actions)
   {
      _stream = stream;
      _stream.AddRef();
      _startInPercent = startInPercent;
      _start = start;
      _actions = actions;
   }

   ~CreateTrailingStreamAction()
   {
      _stream.Release();
   }

   void RestoreActions(string symbol, int magicNumber)
   {
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      OrderByTicketId* order = new OrderByTicketId(_currentTicket);
      if (!order.Select() || OrderStopLoss() == 0)
      {
         order.Release();
         return false;
      }

      double point = MarketInfo(OrderSymbol(), MODE_POINT);
      int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;

      double distance = (OrderOpenPrice() - OrderStopLoss()) / pipSize;
      double start = _startInPercent ? distance * _start / 100.0 : _start;
      
      TrailingStreamAction* action = new TrailingStreamAction(order, _stream);
      ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, start, 100000);
      _actions.AddActionOnCondition(action, condition);
      condition.Release();
      action.Release();

      order.Release();

      return true;
   }
};

#endif
// Partial close of the order action v1.0




#ifndef PartialCloseOrderAction_IMP
#define PartialCloseOrderAction_IMP

class PartialCloseOrderAction : public AAction
{
   IOrder* _order;
   int _slippagePoints;
   double _toClose;
public:
   PartialCloseOrderAction(IOrder* order, double toClose, int slippagePoints)
   {
      _order = order;
      _order.AddRef();
      _toClose = toClose;
      _slippagePoints = slippagePoints;
   }

   ~PartialCloseOrderAction()
   {
      _order.Release();
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!_order.Select() || OrderCloseTime() != 0)
      {
         return false;
      }

      int orderType = OrderType();
      string error;
      double price = orderType == OP_BUY ? InstrumentInfo::GetBid(OrderSymbol()) : InstrumentInfo::GetAsk(OrderSymbol());
      if (!TradingCommands::CloseCurrentOrder(price, _slippagePoints, _toClose, error))
      {
         Print("Position close error: " + error);
         return false;
      }
      return true;
   }
};

#endif




// v1.0

class PartialCloseOnProfitOrderAction : public AOrderAction
{
   StopLimitType _triggerType;
   double _trigger;
   double _toClose;
   TradingCalculator *_calculator;
   Signaler *_signaler;
   ActionOnConditionLogic* _actions;
public:
   PartialCloseOnProfitOrderAction(const StopLimitType triggerType, const double trigger,
      const double toClose, Signaler *signaler, ActionOnConditionLogic* actions)
   {
      _calculator = NULL;
      _signaler = signaler;
      _triggerType = triggerType;
      _trigger = trigger;
      _toClose = toClose;
      _actions = actions;
   }

   ~PartialCloseOnProfitOrderAction()
   {
      delete _calculator;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!OrderSelect(_currentTicket, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return false;

      string symbol = OrderSymbol();
      if (_calculator == NULL || symbol != _calculator.GetSymbol())
      {
         delete _calculator;
         _calculator = TradingCalculator::Create(symbol);
         if (_calculator == NULL)
            return false;
      }
      int isBuy = TradingCalculator::IsBuyOrder();
      double basePrice = OrderOpenPrice();
      double triggerValue = _calculator.CalculateTakeProfit(isBuy, _trigger, _triggerType, OrderLots(), basePrice);

      if (!OrderSelect(_currentTicket, SELECT_BY_TICKET, MODE_TRADES))
         return true;
      IOrder *order = new OrderByTicketId(_currentTicket);
      HitProfitCondition* condition = new HitProfitCondition();
      condition.Set(order, triggerValue);
      IAction* action = new PartialCloseOrderAction(order, _toClose, slippage_points);
      order.Release();
      _actions.AddActionOnCondition(action, condition);
      condition.Release();
      action.Release();
      return true;
   }
};
// Lots provider interface v1.0

#ifndef ILotsProvider_IMP
#define ILotsProvider_IMP
class ILotsProvider
{
public:
   virtual double GetValue(int period, double entryPrice) = 0;
};
#endif




// v1.0

class CustomLotsProvider : public ILotsProvider
{
   double _lots;
public:
   void SetLots(double lots)
   {
      _lots = lots;
   }

   virtual double GetValue(int period, double entryPrice)
   {
      return _lots;
   }
};

class CreateMartingaleAction : public AOrderAction
{
   ActionOnConditionLogic* _actions;
   double _partingaleStepPips;
   IAction* _longAction;
   IAction* _shortAction;
   int _maxLongPositions;
   int _maxShortPositions;
   double _lotsValue;
   MartingaleLotSizingType _lotsSizingType;
   CustomLotsProvider* _lots;
public:
   CreateMartingaleAction(CustomLotsProvider* lots, MartingaleLotSizingType lotsSizingType, double lotsValue, 
      double partingaleStepPips, IAction* longAction, IAction* shortAction, 
      int maxLongPositions, int maxShortPositions, ActionOnConditionLogic* actions)
   {
      _lots = lots;
      _lotsValue = lotsValue;
      _lotsSizingType = lotsSizingType;
      _maxLongPositions = maxLongPositions;
      _maxShortPositions = maxShortPositions;
      _longAction = longAction;
      _longAction.AddRef();
      _shortAction = shortAction;
      _shortAction.AddRef();
      _actions = actions;
      _partingaleStepPips = partingaleStepPips;
   }

   ~CreateMartingaleAction()
   {
      _longAction.Release();
      _shortAction.Release();
   }

   void RestoreActions(string symbol, int magicNumber)
   {
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      OrderByTicketId* order = new OrderByTicketId(_currentTicket);
      if (!order.Select())
      {
         order.Release();
         return false;
      }

      if (IsLimitHit())
      {
         order.Release();
         return false;
      }
      InstrumentInfo instrument(OrderSymbol());
      switch (_lotsSizingType)
      {
         case MartingaleLotSizingNo:
            _lots.SetLots(OrderLots());
            break;
         case MartingaleLotSizingMultiplicator:
            _lots.SetLots(instrument.NormalizeLots(OrderLots() * _lotsValue));
            break;
         case MartingaleLotSizingAdd:
            _lots.SetLots(instrument.NormalizeLots(OrderLots() + _lotsValue));
            break;
      }
      ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, -100000, -_partingaleStepPips);
      if (TradingCalculator::IsBuyOrder())
      {
         _actions.AddActionOnCondition(_longAction, condition);
      }
      else
      {
         _actions.AddActionOnCondition(_shortAction, condition);
      }
      condition.Release();
      order.Release();

      return true;
   }
private:
   bool IsLimitHit()
   {
      OrdersIterator sideSpecificIterator();
      sideSpecificIterator.WhenMagicNumber(magic_number).WhenTrade();
      sideSpecificIterator.WhenSymbol(OrderSymbol());
      if (TradingCalculator::IsBuyOrder())
      {
         sideSpecificIterator.WhenSide(BuySide);
         int side_positions = sideSpecificIterator.Count();
         return side_positions >= _maxLongPositions;
      }
      sideSpecificIterator.WhenSide(SellSide);
      int side_positions = sideSpecificIterator.Count();
      return side_positions >= _maxShortPositions;
   }
};




// Hit profit condition v3.0

#ifndef HitProfitCondition_IMP
#define HitProfitCondition_IMP

class HitProfitCondition : public AConditionBase
{
   IOrder* _order;
   double _trigger;
   InstrumentInfo *_instrument;
public:
   HitProfitCondition()
   {
      _order = NULL;
      _instrument = NULL;
   }

   ~HitProfitCondition()
   {
      delete _instrument;
      if (_order != NULL)
         _order.Release();
   }

   void Set(IOrder* order, double trigger)
   {
      if (!order.Select())
         return;

      _order = order;
      _order.AddRef();
      _trigger = trigger;
      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (_order == NULL || !_order.Select())
      {
         return true;
      }

      int type = OrderType();
      if (type == OP_BUY)
         return _instrument.GetAsk() >= _trigger;
      else if (type == OP_SELL)
         return _instrument.GetBid() <= _trigger;
      return false;
   }
};

#endif





// Position limit hit condition v1.0

#ifndef PositionLimitHitCondition_IMP
#define PositionLimitHitCondition_IMP

class PositionLimitHitCondition : public AConditionBase
{
   int _magicNumber;
   int _maxSidePositions;
   int _totalPositions;
   string _symbol;
   OrderSide _side;
public:
   PositionLimitHitCondition(const OrderSide side, const int magicNumber, const int maxSidePositions, const int totalPositions,
      const string symbol = "")
   {
      _symbol = symbol;
      _side = side;
      _magicNumber = magicNumber;
      _maxSidePositions = maxSidePositions;
      _totalPositions = totalPositions;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      OrdersIterator sideSpecificIterator();
      sideSpecificIterator.WhenMagicNumber(_magicNumber).WhenTrade().WhenSide(_side);
      if (_symbol != "")
      {
         sideSpecificIterator.WhenSymbol(_symbol);
      }
      int side_positions = sideSpecificIterator.Count();
      if (side_positions >= _maxSidePositions)
      {
         return true;
      }

      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber).WhenTrade();
      if (_symbol != "")
      {
         it.WhenSymbol(_symbol);
      }
      int positions = it.Count();
      return positions >= _totalPositions;
   }
};

#endif
// Move net stop loss action v 2.0




// Trading commands v.2.14
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef TradingCommands_IMP
#define TradingCommands_IMP

class TradingCommands
{
public:
   static bool MoveSLTP(const int ticketId, const double newStopLoss, const double newTakeProfit, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0)
      {
         error = "Trade not found";
         return false;
      }

      double rate = OrderOpenPrice();
      ResetLastError();
      int res = OrderModify(ticketId, rate, newStopLoss, newTakeProfit, 0, CLR_NONE);
      int errorCode = GetLastError();
      switch (errorCode)
      {
         case ERR_NO_ERROR:
            break;
         case ERR_NO_RESULT:
            error = "Broker returned no error but no confirmation as well";
            break;
         case ERR_INVALID_TICKET:
            error = "Trade not found";
            return false;
         case ERR_INVALID_STOPS:
            {
               string symbol = OrderSymbol();
               InstrumentInfo instrument(symbol);
               double point = instrument.GetPointSize();
               int minStopDistancePoints = (int)MarketInfo(symbol, MODE_STOPLEVEL);
               if (newStopLoss != 0.0 && MathRound(MathAbs(rate - newStopLoss) / point) < minStopDistancePoints)
                  error = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
               else if (newTakeProfit != 0.0 && MathRound(MathAbs(rate - newTakeProfit) / point) < minStopDistancePoints)
                  error = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
               else
               {
                  int orderType = OrderType();
                  bool isBuyOrder = orderType == OP_BUY || orderType == OP_BUYLIMIT || orderType == OP_BUYSTOP;
                  double rateDistance = orderType
                     ? MathAbs(rate - instrument.GetAsk()) / point
                     : MathAbs(rate - instrument.GetBid()) / point;
                  if (rateDistance < minStopDistancePoints)
                     error = "Distance to the pending order rate is too close: " + DoubleToStr(rateDistance, 1)
                        + ". Min. allowed distance: " + IntegerToString(minStopDistancePoints);
                  else
                     error = "Invalid stop loss or take profit in the request";
               }
            }
            return false;
         default:
            error = "Last error: " + IntegerToString(errorCode);
            return false;
      }
      return true;
   }

   static bool MoveSL(const int ticketId, const double newStopLoss, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0)
      {
         error = "Trade not found";
         return false;
      }
      return MoveSLTP(ticketId, newStopLoss, OrderTakeProfit(), error);
   }

   static bool MoveTP(const int ticketId, const double newTakeProfit, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0)
      {
         error = "Trade not found";
         return false;
      }
      return MoveSLTP(ticketId, OrderStopLoss(), newTakeProfit, error);
   }

   static void DeleteOrders(const int magicNumber)
   {
      OrdersIterator orders();
      orders.WhenMagicNumber(magicNumber);
      orders.WhenOrder();
      DeleteOrders(orders);
   }

   static void DeleteOrders(OrdersIterator& orders)
   {
      while (orders.Next())
      {
         int ticket = OrderTicket();
         if (!OrderDelete(ticket))
            Print("Failed to delete the order " + IntegerToString(ticket));
      }
   }

   static bool DeleteCurrentOrder(string &error)
   {
      int ticket = OrderTicket();
      if (!OrderDelete(ticket))
      {
         error = "Failed to delete the order " + IntegerToString(ticket);
         return false;
      }
      return true;
   }

   static bool CloseCurrentOrder(const int slippage, const double amount, string &error)
   {
      int orderType = OrderType();
      if (orderType == OP_BUY)
         return CloseCurrentOrder(InstrumentInfo::GetBid(OrderSymbol()), slippage, amount, error);
      if (orderType == OP_SELL)
         return CloseCurrentOrder(InstrumentInfo::GetAsk(OrderSymbol()), slippage, amount, error);
      return false;
   }
   
   static bool CloseCurrentOrder(const int slippage, string &error)
   {
      return CloseCurrentOrder(slippage, OrderLots(), error);
   }

   static bool CloseCurrentOrder(const double price, const int slippage, string &error)
   {
      return CloseCurrentOrder(price, slippage, OrderLots(), error);
   }
   
   static bool CloseCurrentOrder(const double price, const int slippage, const double amount, string &error)
   {
      bool closed = OrderClose(OrderTicket(), amount, price, slippage);
      if (closed)
         return true;
      int lastError = GetLastError();
      switch (lastError)
      {
         case ERR_NOT_ENOUGH_MONEY:
            error = "Not enough money";
            break;
         case ERR_TRADE_NOT_ALLOWED:
            error = "Trading is not allowed";
            break;
         case ERR_INVALID_PRICE:
            error = "Invalid closing price: " + DoubleToStr(price);
            break;
         case ERR_INVALID_TRADE_VOLUME:
            error = "Invalid trade volume: " + DoubleToStr(amount);
            break;
         case ERR_TRADE_PROHIBITED_BY_FIFO:
            error = "Prohibited by FIFO";
            break;
         case ERR_MARKET_CLOSED:
            error = "The market is closed";
            break;
         default:
            error = "Last error: " + IntegerToString(lastError);
            break;
      }
      return false;
   }

   static int CloseTrades(OrdersIterator &it, const int slippage)
   {
      int failed = 0;
      return CloseTrades(it, slippage, failed);
   }

   static int CloseTrades(OrdersIterator &it, const int slippage, int& failed)
   {
      int closedPositions = 0;
      failed = 0;
      while (it.Next())
      {
         string error;
         if (!CloseCurrentOrder(slippage, error))
         {
            ++failed;
            Print("Failed to close positoin. ", error);
         }
         else
            ++closedPositions;
      }
      return closedPositions;
   }
};

#endif

#ifndef MoveNetStopLossAction_IMP
#define MoveNetStopLossAction_IMP

class MoveNetStopLossAction : public AAction
{
   TradingCalculator *_calculator;
   int _magicNumber;
   double _stopLoss;
   double _breakevenTrigger;
   double _breakevenTarget;
   bool _useBreakeven;
   StopLimitType _type;
public:
   MoveNetStopLossAction(TradingCalculator *calculator, 
      StopLimitType type, 
      const double stopLoss, 
      const int magicNumber)
   {
      _useBreakeven = false;
      _type = type;
      _calculator = calculator;
      _stopLoss = stopLoss;
      _magicNumber = magicNumber;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      MoveStopLoss(OP_BUY);
      MoveStopLoss(OP_SELL);
      return false;
   }

   void SetBreakeven(const double breakevenTrigger, const double breakevenTarget)
   {
      _useBreakeven = true;
      _breakevenTrigger = breakevenTrigger;
      _breakevenTarget = breakevenTarget;
   }
private:
   double GetDistance(const int side, double averagePrice)
   {
      if (side == OP_BUY)
      {
         return (_calculator.GetBid() - averagePrice) / _calculator.GetPipSize();
      }
      return (averagePrice - _calculator.GetAsk()) / _calculator.GetPipSize();
   }

   double GetTarget(const int side, double averagePrice)
   {
      if (!_useBreakeven)
      {
         return _stopLoss;
      }
      double distance = GetDistance(side, averagePrice);
      if (distance < _breakevenTrigger)
      {
         return _stopLoss;
      }
      return _breakevenTarget;
   }

   double GetStopLoss(int side)
   {
      double totalAmount;
      double averagePrice = _calculator.GetBreakevenPrice(side, _magicNumber, totalAmount);
      if (averagePrice == 0.0)
      {
         return 0;
      }
      return _calculator.CalculateStopLoss(side == OP_BUY, GetTarget(side, averagePrice), _type, totalAmount, averagePrice);
   }

   void MoveStopLoss(const int side)
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenOrderType(side);
      it.WhenTrade();
      if (it.Count() <= 1)
      {
         return;
      }
      double stopLoss = GetStopLoss(side);
      if (stopLoss == 0)
      {
         return;
      }
      
      OrdersIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbol());
      it1.WhenOrderType(side);
      it1.WhenTrade();
      int count = 0;
      while (it1.Next())
      {
         if (OrderStopLoss() != stopLoss)
         {
            string error;
            if (!TradingCommands::MoveSL(OrderTicket(), stopLoss, error))
            {
               Print(error);
            }
            else
            {
               ++count;
            }
         }
      }
   }
};

#endif
// Move net take profit action v 2.0


#ifndef MoveNetTakeProfitAction_IMP

class MoveNetTakeProfitAction : public AAction
{
   TradingCalculator *_calculator;
   int _magicNumber;
   double _takeProfit;
   StopLimitType _type;
public:
   MoveNetTakeProfitAction(TradingCalculator *calculator, StopLimitType type, const double takeProfit, const int magicNumber)
   {
      _type = type;
      _calculator = calculator;
      _takeProfit = takeProfit;
      _magicNumber = magicNumber;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      MoveTakeProfit(OP_BUY);
      MoveTakeProfit(OP_SELL);
      return false;
   }
private:
   void MoveTakeProfit(const int side)
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenOrderType(side);
      it.WhenTrade();
      if (it.Count() <= 1)
         return;
      double totalAmount;
      double averagePrice = _calculator.GetBreakevenPrice(side, _magicNumber, totalAmount);
      if (averagePrice == 0.0)
         return;
         
      double takeProfit = _calculator.CalculateTakeProfit(side == OP_BUY, _takeProfit, _type, totalAmount, averagePrice);
      
      OrdersIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbol());
      it1.WhenOrderType(side);
      it1.WhenTrade();
      int count = 0;
      while (it1.Next())
      {
         if (OrderTakeProfit() != takeProfit)
         {
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), takeProfit, 0, CLR_NONE);
            if (res == 0)
            {
               int error = GetLastError();
               switch (error)
               {
                  case ERR_NO_RESULT:
                     break;
                  case ERR_INVALID_TICKET:
                     break;
               }
            }
            else
               ++count;
         }
      }
   }
};

#define MoveNetTakeProfitAction_IMP

#endif
// Money management strategy interface v1.0

#ifndef IMoneyManagementStrategy_IMP
#define IMoneyManagementStrategy_IMP
interface IMoneyManagementStrategy
{
public:
   virtual void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit) = 0;
};
#endif


// Entry strategy v4.0

interface IEntryStrategy
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment) = 0;

   virtual int Exit(const OrderSide side) = 0;
};

#ifndef USE_MARKET_ORDERS

class PendingEntryStrategy : public IEntryStrategy
{
   string _symbol;
   int _magicNumber;
   int _slippagePoints;
   IStream* _longEntryPrice;
   IStream* _shortEntryPrice;
   ActionOnConditionLogic* _actions;
   int _references;
   bool _ecnBroker;
public:
   PendingEntryStrategy(const string symbol, 
      const int magicMumber, 
      const int slippagePoints, 
      IStream* longEntryPrice, 
      IStream* shortEntryPrice,
      ActionOnConditionLogic* actions,
      bool ecnBroker)
   {
      _ecnBroker = ecnBroker;
      _actions = actions;
      _magicNumber = magicMumber;
      _slippagePoints = slippagePoints;
      _symbol = symbol;
      _longEntryPrice = longEntryPrice;
      _shortEntryPrice = shortEntryPrice;
      _references = 1;
   }

   ~PendingEntryStrategy()
   {
      delete _longEntryPrice;
      delete _shortEntryPrice;
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

   int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment)
   {
      double entryPrice;
      if (!GetEntryPrice(period, side, entryPrice))
         return -1;
      string error = "";
      double amount;
      double takeProfit;
      double stopLoss;
      moneyManagement.Get(period, entryPrice, amount, stopLoss, takeProfit);
      if (amount == 0.0)
      {
         Print("Lot size is too small");
         return -1;
      }
      OrderBuilder *orderBuilder = new OrderBuilder(_actions);
      int order = orderBuilder
         .SetRate(entryPrice)
         .SetECNBroker(_ecnBroker)
         .SetSide(side)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(_slippagePoints)
         .SetMagicNumber(_magicNumber)
         .SetStopLoss(stopLoss)
         .SetTakeProfit(takeProfit)
         .SetComment(comment)
         .Execute(error);
      delete orderBuilder;
      if (error != "")
      {
         Print("Failed to open position: " + error);
      }
      return order;
   }

   int Exit(const OrderSide side)
   {
      TradingCommands::DeleteOrders(_magicNumber);
      return 0;
   }
private:
   bool GetEntryPrice(const int period, const OrderSide side, double &price)
   {
      if (side == BuySide)
         return _longEntryPrice.GetValue(period, price);

      return _shortEntryPrice.GetValue(period, price);
   }
};
#else
class MarketEntryStrategy : public IEntryStrategy
{
   string _symbol;
   int _magicNumber;
   int _slippagePoints;
   ActionOnConditionLogic* _actions;
   int _references;
   bool _ecnBroker;
public:
   MarketEntryStrategy(const string symbol, 
      const int magicMumber, 
      const int slippagePoints,
      ActionOnConditionLogic* actions,
      bool ecnBroker)
   {
      _ecnBroker = ecnBroker;
      _actions = actions;
      _magicNumber = magicMumber;
      _slippagePoints = slippagePoints;
      _symbol = symbol;
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

   int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment)
   {
      double entryPrice = side == BuySide ? InstrumentInfo::GetAsk(_symbol) : InstrumentInfo::GetBid(_symbol);
      double amount;
      double takeProfit;
      double stopLoss;
      moneyManagement.Get(period, entryPrice, amount, stopLoss, takeProfit);
      if (amount == 0.0)
      {
         Print("Lot size is too small");
         return -1;
      }
      string error = "";
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder(_actions);
      int order = orderBuilder
         .SetSide(side)
         .SetECNBroker(_ecnBroker)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(_slippagePoints)
         .SetMagicNumber(_magicNumber)
         .SetStopLoss(stopLoss)
         .SetTakeProfit(takeProfit)
         .SetComment(comment)
         .Execute(error);
      delete orderBuilder;
      if (error != "")
      {
         Print("Failed to open position: " + error);
      }
      return order;
   }

   int Exit(const OrderSide side)
   {
      OrdersIterator toClose();
      toClose.WhenSide(side).WhenMagicNumber(_magicNumber).WhenTrade();
      return TradingCommands::CloseTrades(toClose, _slippagePoints);
   }
};
#endif

// Order handlers v1.1

#ifndef OrderHandlers_IMP
#define OrderHandlers_IMP

class OrderHandlers
{
   AOrderAction* _orderHandlers[];
   int _references;
public:
   OrderHandlers()
   {
      _references = 1;
   }

   ~OrderHandlers()
   {
      Clear();
   }

   void Clear()
   {
      for (int i = 0; i < ArraySize(_orderHandlers); ++i)
      {
         delete _orderHandlers[i];
      }
      ArrayResize(_orderHandlers, 0);
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

   void AddOrderAction(AOrderAction* orderAction)
   {
      int count = ArraySize(_orderHandlers);
      ArrayResize(_orderHandlers, count + 1);
      _orderHandlers[count] = orderAction;
      orderAction.AddRef();
   }

   void DoAction(int order)
   {
      for (int orderHandlerIndex = 0; orderHandlerIndex < ArraySize(_orderHandlers); ++orderHandlerIndex)
      {
         _orderHandlers[orderHandlerIndex].DoAction(order);
      }
   }
};

#endif

// Entry action v1.1

#ifndef EntryAction_IMP
#define EntryAction_IMP

class EntryAction : public AAction
{
   IEntryStrategy* _entryStrategy;
   OrderSide _side;
   IMoneyManagementStrategy* _moneyManagement;
   string _algorithmId;
   OrderHandlers* _orderHandlers;
   bool _singleAction;
public:
   EntryAction(IEntryStrategy* entryStrategy, OrderSide side, IMoneyManagementStrategy* moneyManagement, string algorithmId, 
      OrderHandlers* orderHandlers, bool singleAction = false)
   {
      _singleAction = singleAction;
      _orderHandlers = orderHandlers;
      _orderHandlers.AddRef();
      _algorithmId = algorithmId;
      _moneyManagement = moneyManagement;
      _side = side;
      _entryStrategy = entryStrategy;
      _entryStrategy.AddRef();
   }

   ~EntryAction()
   {
      _orderHandlers.Release();
      _entryStrategy.Release();
      delete _moneyManagement;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      int order = _entryStrategy.OpenPosition(period, _side, _moneyManagement, _algorithmId);
      if (order >= 0)
      {
         _orderHandlers.DoAction(order);
      }
      return _singleAction;
   }
};

#endif



// Stop loss strategy interface v1.0

#ifndef IStopLossStrategy_IMP
#define IStopLossStrategy_IMP

class IStopLossStrategy
{
public:
   virtual double GetValue(const int period, double entryPrice) = 0;
};

#endif
// Default stop loss stream v2.0

#ifndef DefaultStopLossStrategy_IMP
#define DefaultStopLossStrategy_IMP

class DefaultStopLossStrategy : public IStopLossStrategy
{
   TradingCalculator* _calculator;
   StopLimitType _stopLossType;
   double _stopLoss;
   bool _isBuy;
public:
   DefaultStopLossStrategy(TradingCalculator* calculator, StopLimitType stopLossType, double stopLoss, bool isBuy)
   {
      _isBuy = isBuy;
      _stopLoss = stopLoss;
      _stopLossType = stopLossType;
      _calculator = calculator;
   }

   virtual double GetValue(const int period, double entryPrice)
   {
      return _calculator.CalculateStopLoss(_isBuy, _stopLoss, _stopLossType, 0.0, entryPrice);
   }
};

#endif
// High/low stop loss stream v1.0

#ifndef HighLowStopLossProvider_IMP
#define HighLowStopLossProvider_IMP

class HighLowStopLossStrategy : public IStopLossStrategy
{
   int _bars;
   bool _isBuy;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   HighLowStopLossStrategy(int bars, bool isBuy, string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _bars = bars;
      _isBuy = isBuy;
   }

   virtual double GetValue(const int period, double entryPrice)
   {
      if (_isBuy)
      {
         int lowestIndex = iLowest(_symbol, _timeframe, MODE_LOW, _bars, period);
         return iLow(_symbol, _timeframe, lowestIndex);
      }
      int highestIndex = iHighest(_symbol, _timeframe, MODE_HIGH, _bars, period);
      return iHigh(_symbol, _timeframe, highestIndex);
   }
};


#endif
// Money management strategy v1.1




// Take profit strategy interface v1.0

#ifndef ITakeProfitStrategy_IMP
#define ITakeProfitStrategy_IMP

class ITakeProfitStrategy
{
public:
   virtual void GetTakeProfit(const int period, const double entryPrice, double stopLoss, double amount, double& takeProfit) = 0;
};

#endif

#ifndef MoneyManagementStrategy_IMP
#define MoneyManagementStrategy_IMP

class MoneyManagementStrategy : public IMoneyManagementStrategy
{
public:
   ILotsProvider* _lots;
   ITakeProfitStrategy* _takeProfit;
   IStopLossStrategy* _stopLoss;

   MoneyManagementStrategy(ILotsProvider* lots, IStopLossStrategy* stopLoss, ITakeProfitStrategy* takeProfit)
   {
      _lots = lots;
      _stopLoss = stopLoss;
      _takeProfit = takeProfit;
   }

   ~MoneyManagementStrategy()
   {
      delete _lots;
      delete _stopLoss;
      delete _takeProfit;
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      amount = _lots.GetValue(period, entryPrice);
      stopLoss = _stopLoss.GetValue(period, entryPrice);
      _takeProfit.GetTakeProfit(period, entryPrice, stopLoss, amount, takeProfit);
   }
};

#endif


// ATR stop loss strategy v1.0

#ifndef ATRStopLossStrategy_IMP
#define ATRStopLossStrategy_IMP

class ATRStopLossStrategy : public IStopLossStrategy
{
   int _period;
   double _multiplicator;
   bool _isBuy;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   ATRStopLossStrategy(string symbol, ENUM_TIMEFRAMES timeframe, int period, double multiplicator, bool isBuy)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _period = period;
      _multiplicator = multiplicator;
      _isBuy = true;
   }

   virtual double GetValue(const int period, double entryPrice)
   {
      double atrValue = iATR(_symbol, _timeframe, _period, period) * _multiplicator;
      return _isBuy ? (entryPrice - atrValue) : (entryPrice + atrValue);
   }
};
#endif


// Risks % of the balance v1.0

#ifndef RiskBalanceStopLossStrategy_IMP
#define RiskBalanceStopLossStrategy_IMP

class RiskBalanceStopLossStrategy : public IStopLossStrategy
{
   TradingCalculator* _calculator;
   double _stopLoss;
   bool _isBuy;
   ILotsProvider* _lotsStrategy;
public:
   RiskBalanceStopLossStrategy(TradingCalculator* calculator, double stopLoss, bool isBuy, ILotsProvider* lotsStrategy)
   {
      _lotsStrategy = lotsStrategy;
      _isBuy = isBuy;
      _stopLoss = stopLoss / 100.0;
      _calculator = calculator;
   }

   virtual double GetValue(const int period, double entryPrice)
   {
      double amount = _lotsStrategy.GetValue(period, entryPrice);
      double dollars = AccountBalance() * _stopLoss;

      return _calculator.CalculateStopLoss(_isBuy, dollars, StopLimitDollar, amount, entryPrice);
   }
};

#endif

// Risk lots provider v2.1

#ifndef RiskLotsProvider_IMP
#define RiskLotsProvider_IMP

class RiskLotsProvider : public ILotsProvider
{
   PositionSizeType _lotsType;
   double _lots;
   TradingCalculator *_calculator;
   IStopLossStrategy* _stopLoss;
public:
   RiskLotsProvider(TradingCalculator *calculator, PositionSizeType lotsType, double lots, IStopLossStrategy* stopLoss)
   {
      _stopLoss = stopLoss;
      _calculator = calculator;
      _lotsType = lotsType;
      _lots = lots;
   }

   virtual double GetValue(int period, double entryPrice)
   {
      double sl = _stopLoss.GetValue(period, entryPrice);
      return _calculator.GetLots(_lotsType, _lots, MathAbs(sl - entryPrice));
   }
};

#endif
// Default lots provider v2.0

#ifndef DefaultLotsProvider_IMP
#define DefaultLotsProvider_IMP
class DefaultLotsProvider : public ILotsProvider
{
   PositionSizeType _lotsType;
   double _lots;
   TradingCalculator *_calculator;
public:
   DefaultLotsProvider(TradingCalculator *calculator, PositionSizeType lotsType, double lots)
   {
      _calculator = calculator;
      _lotsType = lotsType;
      _lots = lots;
   }

   virtual double GetValue(int period, double entryPrice)
   {
      return _calculator.GetLots(_lotsType, _lots, 0.0);
   }
};

#endif
// Dollar stop loss stream v1.0

#ifndef DollarStopLossStrategy_IMP
#define DollarStopLossStrategy_IMP

class DollarStopLossStrategy : public IStopLossStrategy
{
   TradingCalculator* _calculator;
   double _stopLoss;
   bool _isBuy;
   ILotsProvider* _lotsStrategy;
public:
   DollarStopLossStrategy(TradingCalculator* calculator, double stopLoss, bool isBuy, ILotsProvider* lotsStrategy)
   {
      _lotsStrategy = lotsStrategy;
      _isBuy = isBuy;
      _stopLoss = stopLoss;
      _calculator = calculator;
   }

   virtual double GetValue(const int period, double entryPrice)
   {
      double amount = _lotsStrategy.GetValue(period, entryPrice);
      return _calculator.CalculateStopLoss(_isBuy, _stopLoss, StopLimitDollar, amount, entryPrice);
   }
};

#endif

// Default take profit strategy v1.1




#ifndef DefaultTakeProfitStrategy_IMP
#define DefaultTakeProfitStrategy_IMP

class DefaultTakeProfitStrategy : public ITakeProfitStrategy
{
   StopLimitType _takeProfitType;
   TradingCalculator *_calculator;
   double _takeProfit;
   bool _isBuy;
public:
   DefaultTakeProfitStrategy(TradingCalculator *calculator, StopLimitType takeProfitType, double takeProfit, bool isBuy)
   {
      _calculator = calculator;
      _takeProfitType = takeProfitType;
      _takeProfit = takeProfit;
      _isBuy = isBuy;
   }

   virtual void GetTakeProfit(const int period, const double entryPrice, double stopLoss, double amount, double& takeProfit)
   {
      takeProfit = _calculator.CalculateTakeProfit(_isBuy, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

#endif
// Risk to reward take profit strategy v1.1



#ifndef RiskToRewardTakeProfitStrategy_IMP
#define RiskToRewardTakeProfitStrategy_IMP

class RiskToRewardTakeProfitStrategy : public ITakeProfitStrategy
{
   double _takeProfit;
   bool _isBuy;
public:
   RiskToRewardTakeProfitStrategy(double takeProfit, bool isBuy)
   {
      _isBuy = isBuy;
      _takeProfit = takeProfit;
   }

   virtual void GetTakeProfit(const int period, const double entryPrice, double stopLoss, double amount, double& takeProfit)
   {
      if (_isBuy)
         takeProfit = entryPrice + MathAbs(entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = entryPrice - MathAbs(entryPrice - stopLoss) * _takeProfit / 100;
   }
};
#endif
// ATR take profit strategy v1.0



#ifndef ATRTakeProfitStrategy_IMP
#define ATRTakeProfitStrategy_IMP

class ATRTakeProfitStrategy : public ITakeProfitStrategy
{
   int _period;
   double _multiplicator;
   bool _isBuy;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   ATRTakeProfitStrategy(string symbol, ENUM_TIMEFRAMES timeframe, int period, double multiplicator, bool isBuy)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _period = period;
      _multiplicator = multiplicator;
      _isBuy = true;
   }

   virtual void GetTakeProfit(const int period, const double entryPrice, double stopLoss, double amount, double& takeProfit)
   {
      double atrValue = iATR(_symbol, _timeframe, _period, period) * _multiplicator;
      takeProfit = _isBuy ? (entryPrice + atrValue) : (entryPrice - atrValue);
   }
};
#endif


#ifndef MoneyManagementFunctions_IMP
#define MoneyManagementFunctions_IMP

IStopLossStrategy* CreateStopLossStrategy(TradingCalculator* tradingCalculator, string symbol,
   ENUM_TIMEFRAMES timeframe, bool isBuy, StopLossType stopLossType, double stopLossValue, double stopLosstAtrMultiplicator)
{
   switch (stopLossType)
   {
      case SLDoNotUse:
         return new DefaultStopLossStrategy(tradingCalculator, StopLimitDoNotUse, stopLossValue, isBuy);
      case SLPercent:
         return new DefaultStopLossStrategy(tradingCalculator, StopLimitPercent, stopLossValue, isBuy);
      case SLPips:
         return new DefaultStopLossStrategy(tradingCalculator, StopLimitPips, stopLossValue, isBuy);
      case SLAbsolute:
         return new DefaultStopLossStrategy(tradingCalculator, StopLimitAbsolute, stopLossValue, isBuy);
      case SLHighLow:
         return new HighLowStopLossStrategy((int)stopLossValue, isBuy, symbol, timeframe);
      case SLAtr:
         return new ATRStopLossStrategy(symbol, timeframe, (int)stopLossValue, stopLosstAtrMultiplicator, isBuy);
      case SLDollar:
      case SLRiskBalance:
         Print("Not supported stop loss and amount types");
         return NULL; // Not supported at all
   }
   return NULL;
}

IStopLossStrategy* CreateStopLossStrategyForLots(ILotsProvider* lots, TradingCalculator* tradingCalculator,
   string symbol, ENUM_TIMEFRAMES timeframe, bool isBuy, 
   StopLossType stopLossType, double stopLossValue, double stopLossAtrMultiplicator)
{
   switch (stopLossType)
   {
      case SLDollar:
         return new DollarStopLossStrategy(tradingCalculator, stopLossValue, isBuy, lots);
      case SLRiskBalance:
         return new RiskBalanceStopLossStrategy(tradingCalculator, stopLossValue, isBuy, lots);
      default:
         return CreateStopLossStrategy(tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLossAtrMultiplicator);
   }
   return NULL;
}

ITakeProfitStrategy* CreateTakeProfitStrategy(TradingCalculator* tradingCalculator, 
   string symbol, ENUM_TIMEFRAMES timeframe, bool isBuy, 
   TakeProfitType takeProfitType, double takeProfitValue, double takeProfitAtrMultiplicator)
{
   switch (takeProfitType)
   {
      #ifdef TAKE_PROFIT_FEATURE
         case TPPercent:
            return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPercent, takeProfitValue, isBuy);
         case TPPips:
            return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPips, takeProfitValue, isBuy);
         case TPDollar:
            return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDollar, takeProfitValue, isBuy);
         case TPRiskReward:
            return new RiskToRewardTakeProfitStrategy(takeProfitValue, isBuy);
         case TPAbsolute:
            return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitAbsolute, takeProfitValue, isBuy);
         case TPAtr:
            return new ATRTakeProfitStrategy(symbol, timeframe, (int)takeProfitValue, takeProfitAtrMultiplicator, isBuy);
      #endif
   }
   return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDoNotUse, takeProfitValue, isBuy);
}

MoneyManagementStrategy* CreateMoneyManagementStrategy(TradingCalculator* tradingCalculator, string symbol,
   ENUM_TIMEFRAMES timeframe, bool isBuy, PositionSizeType lotsType, double lotsValue,
   StopLossType stopLossType, double stopLossValue, double stopLossAtrMultiplicator,
   TakeProfitType takeProfitType, double takeProfitValue, double takeProfitAtrMultiplicator)
{
   ILotsProvider* lots = NULL;
   IStopLossStrategy* stopLoss = NULL;
   switch (lotsType)
   {
      case PositionSizeRisk:
         stopLoss = CreateStopLossStrategy(tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLossAtrMultiplicator);
         lots = new RiskLotsProvider(tradingCalculator, lotsType, lotsValue, stopLoss);
         break;
      default:
         lots = new DefaultLotsProvider(tradingCalculator, lotsType, lotsValue);
         stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLossAtrMultiplicator);
         break;
   }
   ITakeProfitStrategy* tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, isBuy, takeProfitType, takeProfitValue, takeProfitAtrMultiplicator);
   return new MoneyManagementStrategy(lots, stopLoss, tp);
}
#endif




// Close on opposite v.1.1

interface ICloseOnOppositeStrategy
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual void DoClose(const OrderSide side) = 0;
};

class DontCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
   int _references;
public:
   DontCloseOnOppositeStrategy()
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

   void DoClose(const OrderSide side)
   {
      // do nothing
   }
};

class DoCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
   int _magicNumber;
   int _slippage;
   int _references;
public:
   DoCloseOnOppositeStrategy(const int slippage, const int magicNumber)
   {
      _magicNumber = magicNumber;
      _slippage = slippage;
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

   void DoClose(const OrderSide side)
   {
      OrdersIterator toClose();
      toClose.WhenSide(side).WhenMagicNumber(_magicNumber).WhenTrade();
      TradingCommands::CloseTrades(toClose, _slippage);
   }
};
// Order builder v2.2





// No stop loss or take profit condition v1.0



#ifndef NoStopLossOrTakeProfitCondition_IMP
#define NoStopLossOrTakeProfitCondition_IMP

class NoStopLossOrTakeProfitCondition : public AConditionBase
{
   int _currentTicket;
public:
   NoStopLossOrTakeProfitCondition(int currentTicket)
   {
      _currentTicket = currentTicket;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!OrderSelect(_currentTicket, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return true;
      return OrderStopLoss() == 0 || OrderTakeProfit() == 0;
   }
};

#endif
// Set stop loss and/or take profit action v2.0




#ifndef SetStopLossAndTakeProfitAction_IMP
#define SetStopLossAndTakeProfitAction_IMP

class SetStopLossAndTakeProfitAction : public AAction
{
   double _stopLoss;
   double _takeProfit;
   int _currentTicket;
public:
   SetStopLossAndTakeProfitAction(double stopLoss, double takeProfit, int currentTicket)
   {
      _stopLoss = stopLoss;
      _takeProfit = takeProfit;
      _currentTicket = currentTicket;
   }

   ~SetStopLossAndTakeProfitAction()
   {
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!OrderSelect(_currentTicket, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return true;

      if ((OrderStopLoss() != 0 || _stopLoss == 0) && (OrderTakeProfit() != 0 || _takeProfit == 0))
         return true;
      
      string errorMessage;
      bool success = TradingCommands::MoveSLTP(_currentTicket, _stopLoss, _takeProfit, errorMessage);
      return success && (errorMessage == NULL || errorMessage == "");
   }
};

#endif

#ifndef OrderBuilder_IMP
#define OrderBuilder_IMP

class OrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stopLoss;
   double _takeProfit;
   int _magicNumber;
   string _comment;
   bool _ecnBroker;
   int _orderType;
   ActionOnConditionLogic* _actions;
public:
   OrderBuilder(ActionOnConditionLogic* actions)
   {
      _orderType = -1;
      _actions = actions;
      _ecnBroker = false;
   }

   OrderBuilder* SetOrderType(int orderType)
   {
      _orderType = orderType;
      return &this;
   }

   // Sets ECN broker flag
   OrderBuilder* SetECNBroker(bool isEcn)
   {
      _ecnBroker = isEcn;
      return &this;
   }

   OrderBuilder *SetSide(const OrderSide orderSide)
   {
      _orderSide = orderSide;
      return &this;
   }
   
   OrderBuilder *SetInstrument(const string instrument)
   {
      _instrument = instrument;
      return &this;
   }
   
   OrderBuilder *SetAmount(const double amount)
   {
      _amount = amount;
      return &this;
   }
   
   OrderBuilder *SetRate(const double rate)
   {
      _rate = rate;
      return &this;
   }
   
   OrderBuilder *SetSlippage(const int slippage)
   {
      _slippage = slippage;
      return &this;
   }
   
   OrderBuilder *SetStopLoss(const double stop)
   {
      _stopLoss = stop;
      return &this;
   }
   
   OrderBuilder *SetTakeProfit(const double limit)
   {
      _takeProfit = limit;
      return &this;
   }
   
   OrderBuilder *SetMagicNumber(const int magicNumber)
   {
      _magicNumber = magicNumber;
      return &this;
   }

   OrderBuilder *SetComment(const string comment)
   {
      _comment = comment;
      return &this;
   }

   int GetOrderType()
   {
      if (_orderType != -1)
      {
         return _orderType;
      }
      if (_orderSide == BuySide)
      {
         return _rate > InstrumentInfo::GetAsk(_instrument) ? OP_BUYSTOP : OP_BUYLIMIT;
      }
      return _rate < InstrumentInfo::GetBid(_instrument) ? OP_SELLSTOP : OP_SELLLIMIT;
   }
   
   int Execute(string &errorMessage)
   {
      InstrumentInfo instrument(_instrument);
      double rate = instrument.RoundRate(_rate);
      double sl = instrument.RoundRate(_stopLoss);
      double tp = instrument.RoundRate(_takeProfit);
      int orderType = GetOrderType();
      int order;
      if (_ecnBroker)
         order = OrderSend(_instrument, orderType, _amount, rate, _slippage, 0, 0, _comment, _magicNumber);
      else
         order = OrderSend(_instrument, orderType, _amount, rate, _slippage, sl, tp, _comment, _magicNumber);
      if (order == -1)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_OFF_QUOTES:
               errorMessage = "No quotes";
               return -1;
            case ERR_NOT_ENOUGH_MONEY:
               errorMessage = "Not enough money";
               break;
            case ERR_TRADE_NOT_ALLOWED:
               errorMessage = "Trading is not allowed";
               break;
            case ERR_TRADE_TOO_MANY_ORDERS:
               errorMessage = "Too many orders opened";
               break;
            case ERR_INVALID_STOPS:
               {
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
                  if (_stopLoss != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _stopLoss) / point) < minStopDistancePoints)
                        errorMessage = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                     else
                        errorMessage = "Invalid stop loss in the request. Do you have ECN broker and forget to enable ECN?";
                  }
                  else if (_takeProfit != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _takeProfit) / point) < minStopDistancePoints)
                        errorMessage = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                     else
                        errorMessage = "Invalid take profit in the request. Do you have ECN broker and forget to enable ECN?";
                  }
                  else
                     errorMessage = "Invalid stop loss or take profit in the request. Do you have ECN broker and forget to enable ECN?";
               }
               break;
            case ERR_INVALID_TRADE_PARAMETERS:
               errorMessage = "Incorrect trade parameters. Symbol: " 
                  + _instrument
                  + " Order type: " + IntegerToString(orderType)
                  + " Amount: " + DoubleToString(_amount)
                  + " Rate: " + DoubleToString(rate)
                  + " Slippage: " + DoubleToString(_slippage)
                  + " SL: " + DoubleToString(sl)
                  + " TP: " + DoubleToString(tp)
                  + " Comment: " + _comment == NULL ? "" : _comment
                  + " Magic number: " + IntegerToString(_magicNumber);
               break;
            default:
               errorMessage = "Failed to create order: " + IntegerToString(error);
               break;
         }
      }
      else if (_ecnBroker && (_stopLoss != 0 || _takeProfit != 0))
      {
         NoStopLossOrTakeProfitCondition* condition = new NoStopLossOrTakeProfitCondition(order);
         SetStopLossAndTakeProfitAction* action = new SetStopLossAndTakeProfitAction(_stopLoss, _takeProfit, order);
         _actions.AddActionOnCondition(action, condition);
         condition.Release();
         action.Release();
      }
      return order;
   }
};

#endif
// Market order builder v 2.3
// More templates and snippets on https://github.com/sibvic/mq4-templates





#ifndef MarketOrderBuilder_IMP
#define MarketOrderBuilder_IMP

class MarketOrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stopLoss;
   double _takeProfit;
   int _magicNumber;
   string _comment;
   bool _ecnBroker;
   ActionOnConditionLogic* _actions;
   int _retries;
public:
   MarketOrderBuilder(ActionOnConditionLogic* actions)
   {
      _retries = 1;
      _actions = actions;
      _ecnBroker = false;
   }

   MarketOrderBuilder* SetRetries(int retries)
   {
      _retries = retries;
      return &this;
   }

   MarketOrderBuilder *SetSide(const OrderSide orderSide)
   {
      _orderSide = orderSide;
      return &this;
   }
   
   // Sets ECN broker flag
   MarketOrderBuilder* SetECNBroker(bool isEcn)
   {
      _ecnBroker = isEcn;
      return &this;
   }

   MarketOrderBuilder *SetInstrument(const string instrument)
   {
      _instrument = instrument;
      return &this;
   }
   
   MarketOrderBuilder *SetAmount(const double amount)
   {
      _amount = amount;
      return &this;
   }
   
   MarketOrderBuilder *SetSlippage(const int slippage)
   {
      _slippage = slippage;
      return &this;
   }
   
   MarketOrderBuilder *SetStopLoss(const double stop)
   {
      _stopLoss = NormalizeDouble(stop, Digits);
      return &this;
   }
   
   MarketOrderBuilder *SetTakeProfit(const double limit)
   {
      _takeProfit = NormalizeDouble(limit, Digits);
      return &this;
   }
   
   MarketOrderBuilder *SetMagicNumber(const int magicNumber)
   {
      _magicNumber = magicNumber;
      return &this;
   }

   MarketOrderBuilder *SetComment(const string comment)
   {
      _comment = comment;
      return &this;
   }
   
   int Execute(string &errorMessage)
   {
      int orderType = _orderSide == BuySide ? OP_BUY : OP_SELL;
      double minstoplevel = MarketInfo(_instrument, MODE_STOPLEVEL); 
      
      double rate = _orderSide == BuySide ? MarketInfo(_instrument, MODE_ASK) : MarketInfo(_instrument, MODE_BID);
      for (int i = 0; i < _retries; ++i)
      {
         int order;
         if (_ecnBroker)
            order = OrderSend(_instrument, orderType, _amount, rate, _slippage, 0, 0, _comment, _magicNumber);
         else
            order = OrderSend(_instrument, orderType, _amount, rate, _slippage, _stopLoss, _takeProfit, _comment, _magicNumber);
         if (order == -1)
         {
            int error = GetLastError();
            switch (error)
            {
               case ERR_REQUOTE:
                  RefreshRates();
                  continue;
               case ERR_NOT_ENOUGH_MONEY:
                  errorMessage = "Not enougth money";
                  return -1;
               case ERR_INVALID_TRADE_VOLUME:
                  {
                     double minVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MIN);
                     if (_amount < minVolume)
                     {
                        errorMessage = "Volume of the lot is too low: " + DoubleToStr(_amount) + " Min lot is: " + DoubleToStr(minVolume);
                        return -1;
                     }
                     double maxVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MAX);
                     if (_amount > maxVolume)
                     {
                        errorMessage = "Volume of the lot is too high: " + DoubleToStr(_amount) + " Max lot is: " + DoubleToStr(maxVolume);
                        return -1;
                     }
                     errorMessage = "Invalid volume: " + DoubleToStr(_amount);
                  }
                  return -1;
               case ERR_OFF_QUOTES:
                  errorMessage = "No quotes";
                  return -1;
               case ERR_TRADE_NOT_ALLOWED:
                  errorMessage = "Trading is not allowed";
                  return -1;
               case ERR_TRADE_HEDGE_PROHIBITED:
                  errorMessage = "Trade hedge prohibited";
                  return -1;
               case ERR_TRADE_TOO_MANY_ORDERS:
                  errorMessage = "Too many orders opened";
                  return -1;
               case ERR_INVALID_STOPS:
                  {
                     double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                     int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
                     if (_stopLoss != 0.0)
                     {
                        if (MathRound(MathAbs(rate - _stopLoss) / point) < minStopDistancePoints)
                           errorMessage = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                        else
                           errorMessage = "Invalid stop loss in the request. Do you have ECN broker and forget to enable ECN?";
                     }
                     else if (_takeProfit != 0.0)
                     {
                        if (MathRound(MathAbs(rate - _takeProfit) / point) < minStopDistancePoints)
                           errorMessage = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                        else
                           errorMessage = "Invalid take profit in the request. Do you have ECN broker and forget to enable ECN?";
                     }
                     else
                        errorMessage = "Invalid stop loss or take profit in the request. Do you have ECN broker and forget to enable ECN?";
                  }
                  return -1;
               case ERR_INVALID_PRICE:
                  errorMessage = "Invalid price";
                  return -1;
               default:
                  errorMessage = "Failed to create order: " + IntegerToString(error);
                  return -1;
            }
         }
         else if (_ecnBroker && (_stopLoss != 0 || _takeProfit != 0))
         {
            NoStopLossOrTakeProfitCondition* condition = new NoStopLossOrTakeProfitCondition(order);
            SetStopLossAndTakeProfitAction* action = new SetStopLossAndTakeProfitAction(_stopLoss, _takeProfit, order);
            _actions.AddActionOnCondition(action, condition);
            condition.Release();
            action.Release();
         }
         return order;
      }
      errorMessage = "Requote";
      return -1;
   }
};

#endif


//Move to breakeven action v3.0

#ifndef MoveToBreakevenAction_IMP
#define MoveToBreakevenAction_IMP

class MoveToBreakevenAction : public AAction
{
   double _target;
   InstrumentInfo *_instrument;
   IOrder* _order;
   string _name;
public:
   MoveToBreakevenAction(double target, string name, IOrder* order)
   {
      _target = target;
      _name = name;

      _order = order;
      _order.AddRef();
      _order.Select();
      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
   }

   ~MoveToBreakevenAction()
   {
      delete _instrument;
      _order.Release();
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!_order.Select() || OrderCloseTime() != 0)
      {
         return false;
      }
      int ticketId = OrderTicket();
      string error;
      if (!TradingCommands::MoveSL(ticketId, _target, error))
      {
         Print(error);
         return false;
      }
      string ticketIdStr = IntegerToString(ticketId);
      GlobalVariableDel("be_" + ticketIdStr + "_ta");
      GlobalVariableDel("be_" + ticketIdStr + "_tr");
      return true;
   }
};

#endif

// Move stop loss on profit order action v3.0

#ifndef MoveStopLossOnProfitOrderAction_IMP
#define MoveStopLossOnProfitOrderAction_IMP

// Automatically saves data about breakeven levels as globals.
// You need to call RestoreActions() after creation of this object to restore tracking of old trades.
class MoveStopLossOnProfitOrderAction : public AOrderAction
{
   StopLimitType _triggerType;
   double _trigger;
   double _target;
   TradingCalculator *_calculator;
   Signaler *_signaler;
   ActionOnConditionLogic* _actions;
public:
   MoveStopLossOnProfitOrderAction(const StopLimitType triggerType, const double trigger,
      const double target, Signaler *signaler, ActionOnConditionLogic* actions)
   {
      _calculator = NULL;
      _signaler = signaler;
      _triggerType = triggerType;
      _trigger = trigger;
      _target = target;
      _actions = actions;
   }

   ~MoveStopLossOnProfitOrderAction()
   {
      delete _calculator;
   }

   void RestoreActions(string symbol, int magicNumber)
   {
      OrdersIterator trades;
      trades.WhenSymbol(symbol).WhenTrade().WhenMagicNumber(magicNumber);
      while (trades.Next())
      {
         int ticketId = trades.GetTicket();
         string ticketIdStr = IntegerToString(ticketId);
         double trigger = GlobalVariableGet("be_" + ticketIdStr + "_tr");
         if (trigger == 0)
         {
            continue;
         }
         double target = GlobalVariableGet("be_" + ticketIdStr + "_ta");
         if (target == 0)
         {
            continue;
         }
         CreateBreakeven(ticketId, trigger, target, "");
      }
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!OrderSelect(_currentTicket, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return false;
      }

      string symbol = OrderSymbol();
      if (_calculator == NULL || symbol != _calculator.GetSymbol())
      {
         delete _calculator;
         _calculator = TradingCalculator::Create(symbol);
         if (_calculator == NULL)
         {
            return false;
         }
      }
      int isBuy = TradingCalculator::IsBuyOrder();
      double basePrice = OrderOpenPrice();
      double targetValue = _calculator.CalculateTakeProfit(isBuy, _target, StopLimitPips, OrderLots(), basePrice);
      double triggerValue = _calculator.CalculateTakeProfit(isBuy, _trigger, _triggerType, OrderLots(), basePrice);
      CreateBreakeven(_currentTicket, triggerValue, targetValue, "");
      return true;
   }
private:
   void CreateBreakeven(const int ticketId, const double trigger, const double target, const string name)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
      {
         return;
      }
      string ticketIdStr = IntegerToString(ticketId);
      GlobalVariableSet("be_" + ticketIdStr + "_tr", trigger);
      GlobalVariableSet("be_" + ticketIdStr + "_ta", target);
      IOrder *order = new OrderByTicketId(ticketId);
      HitProfitCondition* condition = new HitProfitCondition();
      condition.Set(order, trigger);
      IAction* action = new MoveToBreakevenAction(target, name, order);
      order.Release();
      if (!_actions.AddActionOnCondition(action, condition))
      {
      }
      condition.Release();
      action.Release();
   }
};

#endif







// Entry position controller v2.0

#ifndef EntryPositionController_IMP
#define EntryPositionController_IMP

class EntryPositionController
{
   bool _includeLog;
   ICondition* _condition;
   ICondition* _filterCondition;
   OrderSide _side;
   ICloseOnOppositeStrategy *_closeOnOpposite;
   Signaler* _signaler;
   IAction* _actions[];
   string _algorithmId;
   string _alertMessage;
public:
   EntryPositionController(OrderSide side, ICondition* condition, ICondition* filterCondition, 
      ICloseOnOppositeStrategy *closeOnOpposite, Signaler* signaler, 
      string algorithmId, string alertMessage)
   {
      _algorithmId = algorithmId;
      _filterCondition = filterCondition;
      _filterCondition.AddRef();
      _signaler = signaler;
      _side = side;
      _includeLog = false;
      _condition = NULL;
      _condition = condition;
      _condition.AddRef();
      _closeOnOpposite = closeOnOpposite;
      _closeOnOpposite.AddRef();
   }

   ~EntryPositionController()
   {
      _closeOnOpposite.Release();
      _condition.Release();
      _filterCondition.Release();
      
      for (int i = 0; i < ArraySize(_actions); ++i)
      {
         _actions[i].Release();
      }
   }

   void IncludeLog()
   {
      _includeLog = true;
   }

   void AddAction(IAction* action)
   {
      int count = ArraySize(_actions);
      ArrayResize(_actions, count + 1);
      _actions[count] = action;
      _actions[count].AddRef();
   }

   bool DoEntry(int period, datetime date, string& logMessage)
   {
      bool conditionPassed = _condition.IsPass(period, date);
      if (_includeLog)
      {
         logMessage = _condition.GetLogMessage(period, date) + "; Condition passed: " + (conditionPassed ? "true" : "false");
         if (_filterCondition != NULL)
         {
            logMessage += "; Filter: " + _filterCondition.GetLogMessage(period, date);
         }
      }
      if (!conditionPassed)
      {
         return false;
      }
      bool filterPassed = _filterCondition == NULL || _filterCondition.IsPass(period, date);
      if (_includeLog)
      {
         logMessage += "; Filter passed: " + (filterPassed ? "true" : "false");
      }
      if (!filterPassed)
      {
         return false;
      }
      _closeOnOpposite.DoClose(GetOppositeSide(_side));
      
      for (int i = 0; i < ArraySize(_actions); ++i)
      {
         _actions[i].DoAction(period, date);
      }
      _signaler.SendNotifications(_alertMessage);
      return true;
   }
};

#endif

// Trading controller v8.0

#ifndef TradingController_IMP
#define TradingController_IMP

class TradingController
{
   ENUM_TIMEFRAMES _entryTimeframe;
   ENUM_TIMEFRAMES _exitTimeframe;
   datetime _lastActionTime;
   Signaler *_signaler;
   datetime _lastEntryTime;
   datetime _lastExitTime;
   TradingCalculator *_calculator;
   ICondition* _exitLongCondition;
   ICondition* _exitShortCondition;
   IEntryStrategy *_entryStrategy;
   ActionOnConditionLogic* _actions;
   TradingMode _entryLogic;
   TradingMode _exitLogic;
   int _logFile;
   EntryPositionController* _longPositions[];
   EntryPositionController* _shortPositions[];
public:
   TradingController(TradingCalculator *calculator, 
                     ENUM_TIMEFRAMES entryTimeframe, 
                     ENUM_TIMEFRAMES exitTimeframe, 
                     ActionOnConditionLogic* actions,
                     Signaler *signaler, 
                     const string algorithmId = "")
   {
      _entryLogic = TradingModeOnBarClose;
      _exitLogic = TradingModeOnBarClose;
      _actions = actions;
      _calculator = calculator;
      _signaler = signaler;
      _entryTimeframe = entryTimeframe;
      _exitTimeframe = exitTimeframe;
      _exitLongCondition = NULL;
      _exitShortCondition = NULL;
      _logFile = -1;
   }

   ~TradingController()
   {
      if (_logFile != -1)
      {
         FileClose(_logFile);
      }
      for (int i = 0; i < ArraySize(_longPositions); ++i)
      {
         delete _longPositions[i];
      }
      ArrayResize(_longPositions, 0);
      for (int i = 0; i < ArraySize(_shortPositions); ++i)
      {
         delete _shortPositions[i];
      }
      ArrayResize(_shortPositions, 0);
      delete _actions;
      delete _entryStrategy;
      if (_exitLongCondition != NULL)
         _exitLongCondition.Release();
      if (_exitShortCondition != NULL)
         _exitShortCondition.Release();
      delete _calculator;
      delete _signaler;
   }

   void AddLongPosition(EntryPositionController* entryPos)
   {
      int size = ArraySize(_longPositions);
      ArrayResize(_longPositions, size + 1);
      _longPositions[size] = entryPos;
   }
   void AddShortPosition(EntryPositionController* entryPos)
   {
      int size = ArraySize(_shortPositions);
      ArrayResize(_shortPositions, size + 1);
      _shortPositions[size] = entryPos;
   }

   void SetPrintLog(string logFile)
   {
      _logFile = FileOpen(logFile, FILE_WRITE | FILE_CSV, ",");
      for (int i = 0; i < ArraySize(_longPositions); ++i)
      {
         _longPositions[i].IncludeLog();
      }
      for (int i = 0; i < ArraySize(_shortPositions); ++i)
      {
         _shortPositions[i].IncludeLog();
      }
   }
   void SetEntryLogic(TradingMode logicType) { _entryLogic = logicType; }
   void SetExitLogic(TradingMode logicType) { _exitLogic = logicType; }
   void SetExitLongCondition(ICondition *condition) { _exitLongCondition = condition; }
   void SetExitShortCondition(ICondition *condition) { _exitShortCondition = condition; }
   void SetEntryStrategy(IEntryStrategy *entryStrategy)
   { 
      _entryStrategy = entryStrategy; 
      _entryStrategy.AddRef(); 
   }

   void DoTrading()
   {
      int entryTradePeriod = _entryLogic == TradingModeLive ? 0 : 1;
      datetime entryTime = iTime(_calculator.GetSymbol(), _entryTimeframe, entryTradePeriod);
      _actions.DoLogic(entryTradePeriod, entryTime);
      string entryLongLog = "";
      string entryShortLog = "";
      string exitLongLog = "";
      string exitShortLog = "";
      if (_lastEntryTime != 0 && EntryAllowed(entryTime))
      {
         if (DoEntryLogic(entryTradePeriod, entryTime, entryLongLog, entryShortLog))
         {
            _lastActionTime = entryTime;
         }
         _lastEntryTime = entryTime;
      }
      else if (_lastEntryTime == 0)
      {
         _lastEntryTime = entryTime;
      }

      int exitTradePeriod = _exitLogic == TradingModeLive ? 0 : 1;
      datetime exitTime = iTime(_calculator.GetSymbol(), _exitTimeframe, exitTradePeriod);
      if (ExitAllowed(exitTime))
      {
         DoExitLogic(exitTradePeriod, exitTime, exitLongLog, exitShortLog);
         _lastExitTime = exitTime;
      }
      if (_logFile != -1 && (entryLongLog != "" || entryShortLog != "" || exitLongLog != "" || exitShortLog != ""))
      {
         FileWrite(_logFile, TimeToString(TimeCurrent()), 
            ";Entry long: " + entryLongLog, 
            ";Entry short: " + entryShortLog, 
            ";Exit long: " + exitLongLog, 
            ";Exit short: " + exitShortLog);
      }
   }
private:
   bool ExitAllowed(datetime exitTime)
   {
      return _exitLogic != TradingModeOnBarClose || _lastExitTime != exitTime;
   }

   void DoExitLogic(int exitTradePeriod, datetime date, string& longLog, string& shortLog)
   {
      bool exitLongPassed = _exitLongCondition.IsPass(exitTradePeriod, date);
      bool exitShortPassed = _exitShortCondition.IsPass(exitTradePeriod, date);
      if (_logFile != -1)
      {
         longLog = _exitLongCondition.GetLogMessage(exitTradePeriod, date) + "; Exit long executed: " + (exitLongPassed ? "true" : "false");
         shortLog = _exitShortCondition.GetLogMessage(exitTradePeriod, date) + "; Exit short executed: " + (exitShortPassed ? "true" : "false");
      }
      if (exitLongPassed)
      {
         if (_entryStrategy.Exit(BuySide) > 0)
         {
            _signaler.SendNotifications("Exit Buy");
            neutralLevel = 0;
            referentialLevel = 0;
         }
      }
      if (exitShortPassed)
      {
         if (_entryStrategy.Exit(SellSide) > 0)
         {
            _signaler.SendNotifications("Exit Sell");
            neutralLevel = 0;
            referentialLevel = 0;
         }
      }
   }

   bool EntryAllowed(datetime entryTime)
   {
      if (_entryLogic == TradingModeOnBarClose)
      {
         return _lastEntryTime != entryTime;
      }
      return _lastActionTime != entryTime;
   }
   bool DoEntryLogic(int entryTradePeriod, datetime date, string& longLog, string& shortLog)
   {
      bool positionOpened = false;
      for (int i = 0; i < ArraySize(_longPositions); ++i)
      {
         if (_longPositions[i].DoEntry(entryTradePeriod, date, longLog))
         {
            positionOpened = true;
         }
      }
      for (int i = 0; i < ArraySize(_shortPositions); ++i)
      {
         if (_shortPositions[i].DoEntry(entryTradePeriod, date, shortLog))
         {
            positionOpened = true;
         }
      }
      return positionOpened;
   }
};
#endif
// No condition v3.0



#ifndef NoCondition_IMP
#define NoCondition_IMP

class NoCondition : public AConditionBase
{
public:
   bool IsPass(const int period, const datetime date) { return true; }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "No condition";
   }
};

#endif

double GetClosestLevel(double price)
{
   double level = upperLine;
   double selectedLevel = level;
   double error = MathAbs(selectedLevel - price);
   double range = upperLine - lowerLine;
   if (level < price)
   {
      while (true)
      {
         double newLevel = selectedLevel + range;
         double newError = MathAbs(newLevel - price);
         if (newError < error)
         {
            selectedLevel = newLevel;
            error = newError;
            continue;
         }
         return selectedLevel;
      }
   }
   while (true)
   {
      double newLevel = selectedLevel - range;
      double newError = MathAbs(newLevel - price);
      if (newError < error)
      {
         selectedLevel = newLevel;
         error = newError;
         continue;
      }
      return selectedLevel;
   }
   return price;
}

class RememberLevelOrderAction : public AOrderAction
{
public:
   void RestoreActions(string symbol, int magicNumber) { }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!OrderSelect(_currentTicket, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return false;
      }

      double range = upperLine - lowerLine;
      int isBuy = TradingCalculator::IsBuyOrder();
      if (isBuy)
      {
         prevBuyPoint = GetClosestLevel(OrderOpenPrice());
         neutralLevel = prevBuyPoint - range;
         referentialLevel = prevBuyPoint + range;
         protectionLine = prevBuyPoint - range * 2;
      }
      else
      {
         prevSellPoint = GetClosestLevel(OrderOpenPrice());
         neutralLevel = prevSellPoint + range;
         referentialLevel = prevSellPoint - range;
         protectionLine = prevSellPoint + range * 2;
      }
      return true;
   }
};

TradingController *controllers[];
#ifdef SHOW_ACCOUNT_STAT
// Grid cells v3.0

// Grid text cell v3.0

#ifndef GridTextCell_IMP
#define GridTextCell_IMP

class GridTextCell
{
   string _text;
   color _clr;
   uint _width;
   uint _height;
   string _id;
   int _fontSize;
   string _fontName;
   ENUM_ANCHOR_POINT _anchor;
   int _cellWidth;
public:
   GridTextCell(string id)
   {
      _id = id;
   }

   void SetData(string text, color clr, string fontName, int fontSize, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT)
   {
      TextSetFont(fontName, fontSize * (-10));
      TextGetSize(text, _width, _height);
      _fontName = fontName;
      _fontSize = fontSize;
      _text = text;
      _clr = clr;
      _anchor = anchor;
   }

   void Draw(int __x, int __y)
   {
      ResetLastError();
      string id = _id;
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetString(0, id, OBJPROP_FONT, _fontName);
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, _fontSize);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, _anchor);
      }
      if (_anchor == ANCHOR_CENTER)
      {
         ObjectSetInteger(0, id, OBJPROP_XDISTANCE, __x + _cellWidth / 2);
      }
      else
      {
         ObjectSetInteger(0, id, OBJPROP_XDISTANCE, __x);
      }
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, __y);
      ObjectSetInteger(0, id, OBJPROP_COLOR, _clr);
      ObjectSetString(0, id, OBJPROP_TEXT, _text);
   }

   void SetMinWidth(int width)
   {
      _cellWidth = width;
   }

   int GetWidth()
   {
      return (int)_width;
   }

   int GetHeight()
   {
      return (int)_height;
   }
};

#endif
// Grid row v3.0

#ifndef GridRow_IMP
#define GridRow_IMP

class GridRow
{
   GridTextCell* _cells[];
   string _id;
public:
   GridRow(string id)
   {
      _id = id;
   }

   ~GridRow()
   {
      for (int i = 0; i < ArraySize(_cells); ++i)
      {
         delete _cells[i];
      }
      ArrayResize(_cells, 0);
   }

   void EnsureEnoughtCells(int newSize)
   {
      int oldSize = ArraySize(_cells);
      if (newSize <= oldSize)
         return;
      ArrayResize(_cells, newSize);
      for (int i = oldSize; i < newSize; ++i)
      {
         _cells[i] = new GridTextCell(_id + "-" + IntegerToString(i));
      }
   }

   int Size()
   {
      return ArraySize(_cells);
   }

   GridTextCell* Get(int index)
   {
      return _cells[index];
   }
};
#endif

#ifndef GridCells_IMP
#define GridCells_IMP

class GridCells
{
   string _id;
   GridRow* _columns[];
   double _gap;
public:
   GridCells(string id, double gap)
   {
      _gap = gap;
      _id = id;
   }

   ~GridCells()
   {
      for (int i = 0; i < ArraySize(_columns); ++i)
      {
         delete _columns[i];
      }
      ArrayResize(_columns, 0);
   }

   void Clear()
   {

   }

   void Add(string text, color clr, string fontName, int fontSize, int column, int row, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT)
   {
      EnsureEnoughtColumns(column + 1);
      _columns[column].EnsureEnoughtCells(row + 1);
      _columns[column].Get(row).SetData(text, clr, fontName, fontSize, anchor);
   }

   void Draw(int __x, int __y)
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }

         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }

      int currentX = __x;
      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentY = __y;
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            _columns[columnIndex].Get(rowIndex).Draw(currentX, currentY);
            currentY += (int)(maxHeight[rowIndex] * _gap);
         }
         currentX += (int)(maxWidth[columnIndex] * _gap);
      }
   }

   void SetMinWidth(int width)
   {
      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            _columns[columnIndex].Get(rowIndex).SetMinWidth(width);
         }
      }
   }

   int GetTotalWidth()
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }
      int total = 0;
      int count = ArraySize(maxWidth);
      for (int i = 0; i < count; ++i)
      {
         total += (int)((i < count - 1) ? maxWidth[i] * _gap : maxWidth[i]);
      }
      return total;
   }
   int GetTotalHeight()
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }
      int total = 0;
      int count = ArraySize(maxHeight);
      for (int i = 0; i < count; ++i)
      {
         total += (int)((i < count - 1) ? maxHeight[i] * _gap : maxHeight[i]);
      }
      return total;
   }
private:
   void EnsureEnoughtColumns(int newSize)
   {
      int oldSize = ArraySize(_columns);
      if (oldSize <= newSize)
      {
         ArrayResize(_columns, newSize);
         for (int i = oldSize; i < newSize; ++i)
         {
            _columns[i] = new GridRow(_id + "-" + IntegerToString(i));
         }
      }
   }
};

#endif

// Account statistics v1.5

string IndicatorObjPrefix = "EA";
class AccountStatistics
{
   InstrumentInfo *_symbol;
   int _fontSize;
   string _fontName;
   GridCells* cells0;
public:
   AccountStatistics()
   {
      _fontSize = 10;
      _symbol = new InstrumentInfo(_Symbol);
      _fontName = "Cambria";
      cells0 = new GridCells(IndicatorObjPrefix + "0", 1.2);
   }

   ~AccountStatistics()
   {
      delete cells0;
      delete _symbol;
   }

   void Update()
   {
      int row = 0;
      cells0.Add("Initial upper level line", color_text, _fontName, _fontSize, 0, row);
      cells0.Add(DoubleToString(upperLine, _symbol.GetDigits()), color_text, _fontName, _fontSize, 1, row++);
      cells0.Add("Initial lower level line", color_text, _fontName, _fontSize, 0, row);
      cells0.Add(DoubleToString(lowerLine, _symbol.GetDigits()), color_text, _fontName, _fontSize, 1, row++);
      cells0.Add("Protection line position", color_text, _fontName, _fontSize, 0, row);
      cells0.Add(DoubleToString(protectionLine, _symbol.GetDigits()), color_text, _fontName, _fontSize, 1, row++);
      
      int height0 = cells0.GetTotalHeight();
      int width0 = cells0.GetTotalWidth();
      ResetLastError();
      string id = IndicatorObjPrefix + "idValue2";
      ObjectCreate(0, id, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, id, OBJPROP_BGCOLOR, background_color);
      ObjectSetInteger(0, id, OBJPROP_FILL, true);
      ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x - 10); 
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y - 10); 
      ObjectSetInteger(0, id, OBJPROP_XSIZE, width0 + 20); 
      ObjectSetInteger(0, id, OBJPROP_YSIZE, height0 + 20);
      
      cells0.Draw(x, y);
   }
};

   AccountStatistics *stats;
#endif





// Profit in range condition v2.0

#ifndef ProfitInRangeCondition_IMP
#define ProfitInRangeCondition_IMP

class ProfitInRangeCondition : public AConditionBase
{
   IOrder* _order;
   InstrumentInfo* _instrument;
   double _minProfit;
   double _maxProfit;
public:
   ProfitInRangeCondition(IOrder* order, double minProfit, double maxProfit)
   {
      _order = order;
      _order.AddRef();
      _minProfit = minProfit;
      _maxProfit = maxProfit;
      _instrument = NULL;
   }

   ~ProfitInRangeCondition()
   {
      _order.Release();
      delete _instrument;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!_order.Select())
         return true;
      
      string symbol = OrderSymbol();
      if (_instrument == NULL)
         _instrument = new InstrumentInfo(symbol);

      double closePrice = iClose(symbol, PERIOD_M1, 0);
      int orderType = OrderType();
      if (orderType == OP_BUY)
      {
         double profit = (closePrice - OrderOpenPrice()) / _instrument.GetPipSize();
         return profit >= _minProfit && profit <= _maxProfit;
      }
      else if (orderType == OP_SELL)
      {
         double profit = (OrderOpenPrice() - closePrice) / _instrument.GetPipSize();
         return profit >= _minProfit && profit <= _maxProfit;
      }
      return false;
   }
};

#endif





// Trailing action v3.1

#ifndef TrailingAction_IMP
#define TrailingAction_IMP

class TrailingPipsAction : public AAction
{
   IOrder* _order;
   InstrumentInfo* _instrument;
   double _distancePips;
   double _stepPips;
   double _distance;
   double _step;
public:
   TrailingPipsAction(IOrder* order, double distancePips, double stepPips)
   {
      _distancePips = distancePips;
      _stepPips = stepPips;
      _distance = 0;
      _step = 0;
      _order = order;
      _order.AddRef();
      _instrument = NULL;
   }

   ~TrailingPipsAction()
   {
      _order.Release();
      delete _instrument;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!_order.Select())
         return true;

      string symbol = OrderSymbol();
      double closePrice = iClose(symbol, PERIOD_M1, 0);
      if (_step == 0)
      {
         _instrument = new InstrumentInfo(symbol);
         _distance = _distancePips * _instrument.GetPipSize();
         _step = _stepPips * _instrument.GetPipSize();
      }

      double newStop = GetNewStopLoss(closePrice);
      if (newStop == 0.0)
         return false;
      
      string error;
      TradingCommands::MoveSL(OrderTicket(), newStop, error);
      
      return false;
   }
private:
   double GetNewStopLoss(double closePrice)
   {
      double stopLoss = OrderStopLoss();
      if (stopLoss == 0.0)
         return 0;
         
      double newStop = stopLoss;
      int orderType = OrderType();
      if (orderType == OP_BUY)
      {
         while (_instrument.RoundRate(newStop + _step) < _instrument.RoundRate(closePrice - _distance))
         {
            newStop = _instrument.RoundRate(newStop + _step);
         }
         if (newStop == stopLoss) 
            return 0;
      }
      else if (orderType == OP_SELL)
      {
         while (_instrument.RoundRate(newStop - _step) > _instrument.RoundRate(closePrice + _distance))
         {
            newStop = _instrument.RoundRate(newStop - _step);
         }
         if (newStop == stopLoss) 
            return 0;
      }
      else
         return 0;
      return newStop;
   }
};
#endif



// Create trailing action v3.0

#ifndef CreateTrailingAction_IMP
#define CreateTrailingAction_IMP

// Automatically saves data about trailing as globals.
// You need to call RestoreActions() after creation of this object to restore tracking of old trades.
class CreateTrailingAction : public AOrderAction
{
   double _start;
   double _step;
   bool _startInPercent;
   ActionOnConditionLogic* _actions;
public:
   CreateTrailingAction(double start, bool startInPercent, double step, ActionOnConditionLogic* actions)
   {
      _startInPercent = startInPercent;
      _start = start;
      _step = step;
      _actions = actions;
   }

   void RestoreActions(string symbol, int magicNumber)
   {
      OrdersIterator trades;
      trades.WhenSymbol(symbol).WhenTrade().WhenMagicNumber(magicNumber);
      while (trades.Next())
      {
         int ticketId = trades.GetTicket();
         string ticketIdStr = IntegerToString(ticketId);
         double step = GlobalVariableGet("tr_" + ticketIdStr + "_stp");
         if (step == 0)
         {
            continue;
         }
         double start = GlobalVariableGet("tr_" + ticketIdStr + "_strt");
         if (start == 0)
         {
            continue;
         }
         double distance = GlobalVariableGet("tr_" + ticketIdStr + "_d");
         if (distance == 0)
         {
            continue;
         }
         OrderByTicketId* order = new OrderByTicketId(ticketId);
         TrailingPipsAction* action = new TrailingPipsAction(order, distance, step);
         ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, start, 100000);
         _actions.AddActionOnCondition(action, condition);
         condition.Release();
         action.Release();
         order.Release();
      }
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      OrderByTicketId* order = new OrderByTicketId(_currentTicket);
      if (!order.Select() || OrderStopLoss() == 0)
      {
         order.Release();
         return false;
      }

      double point = MarketInfo(OrderSymbol(), MODE_POINT);
      int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;

      double distance = (OrderOpenPrice() - OrderStopLoss()) / pipSize;
      double start = _startInPercent ? distance * _start / 100.0 : _start;

      string ticketIdStr = IntegerToString(_currentTicket);
      GlobalVariableSet("tr_" + ticketIdStr + "_stp", _step);
      GlobalVariableSet("tr_" + ticketIdStr + "_strt", start);
      GlobalVariableSet("tr_" + ticketIdStr + "_d", distance);
      
      TrailingPipsAction* action = new TrailingPipsAction(order, distance, _step);
      ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, start, 100000);
      _actions.AddActionOnCondition(action, condition);
      condition.Release();
      action.Release();

      order.Release();

      return true;
   }
};

#endif





// Create ATR Trailing action v1.0

class CreateATRTrailingAction : public AOrderAction
{
   double _step;
   ActionOnConditionLogic* _actions;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _period;
public:
   CreateATRTrailingAction(string symbol, ENUM_TIMEFRAMES timeframe, int period, double step, ActionOnConditionLogic* actions)
   {
      _step = step;
      _actions = actions;
      _symbol = symbol;
      _timeframe = timeframe;
      _period = period;
   }

   virtual void RestoreActions(string symbol, int magicNumber)
   {
      
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      OrderByTicketId* order = new OrderByTicketId(_currentTicket);
      if (!order.Select() || OrderStopLoss() == 0)
      {
         order.Release();
         return false;
      }

      double point = MarketInfo(OrderSymbol(), MODE_POINT);
      int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;

      double distance = (OrderOpenPrice() - OrderStopLoss()) / pipSize;

      double atrValue = iATR(_symbol, _timeframe, _period, period) / pipSize;
      TrailingPipsAction* action = new TrailingPipsAction(order, distance, _step);
      ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, atrValue, 100000);
      _actions.AddActionOnCondition(action, condition);
      condition.Release();
      action.Release();

      order.Release();

      return true;
   }
};
// Close all action v2.0





#ifndef CloseAllAction_IMP
#define CloseAllAction_IMP

class CloseAllAction : public AAction
{
   int _magicNumber;
   double _slippagePoints;
public:
   CloseAllAction(int magicNumber, double slippagePoints)
   {
      _magicNumber = magicNumber;
      _slippagePoints = slippagePoints;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      OrdersIterator toClose();
      toClose.WhenMagicNumber(_magicNumber).WhenTrade();
      return TradingCommands::CloseTrades(toClose, (int)_slippagePoints) > 0;
   }
};
#endif
// Averages stream factory v1.0





//AOnStream v1.0

class AOnStream : public IStream
{
protected:
   IStream *_source;
   int _references;
public:
   AOnStream(IStream *source)
   {
      _references = 1;
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
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

   virtual int Size()
   {
      return _source.Size();
   }
};

// SMA on stream v1.0

#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
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
#endif


// EMA on stream v1.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
      _k = 2.0 / (_length + 1.0);
   }

   ~EMAOnStream()
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
      {
         delete &this;
      }
   }
   
   virtual int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_buffer, 0) != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
      }
      
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current;
      _buffer[bufferIndex] = (1 - _k) * last + _k * current;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif



// TEMA on stream v1.0

#ifndef TemaOnStream_IMP
#define TemaOnStream_IMP

class TemaOnStream : public AStreamBase
{
   EMAOnStream *_ema1;
   EMAOnStream *_ema2;
   EMAOnStream *_ema3;
public:
   TemaOnStream(IStream *source, const int length)
   {
      _ema1 = new EMAOnStream(source, length);
      _ema2 = new EMAOnStream(_ema1, length);
      _ema3 = new EMAOnStream(_ema2, length);
   }

   ~TemaOnStream()
   {
      delete _ema3;
      delete _ema2;
      delete _ema1;
   }

   int Size()
   {
      return _ema3.Size();
   }

   bool GetValue(const int period, double &val)
   {
      double ema1, ema2, ema3;
      if (!_ema1.GetValue(period + 1, ema1) || !_ema2.GetValue(period, ema2) || !_ema3.GetValue(period, ema3))
         return false;
         
      val = ema3 + 3.0 * (ema1 - ema2);
      return true;
   }
};

#endif


// LWMA on stream v1.0

#ifndef LwmaOnStream_IMP
#define LwmaOnStream_IMP

class LwmaOnStream : public AOnStream
{
   int _length;
public:
   LwmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      double sumw = _length;
      double sum = _length * price;
      for(int i = 1; i < _length; i++)
      {
         double weight = _length - i;
         sumw += weight;
         if (!_source.GetValue(period + i, price))
            return false;
         sum += weight * price;
      }
      val = sum / sumw;
      return true;
   }
};

#endif


#ifndef VwmaOnStream_IMP
#define VwmaOnStream_IMP

class VwmaOnStream : public AOnStream
{
   int _length;
public:
   VwmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (period > totalBars - _length)
         return false;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      long sumw = Volume[period];
      double sum = sumw * price;
      for (int k = 1; k < _length; k++)
      {
         long weight = Volume[period + k];
         sumw += weight;
         if (!_source.GetValue(period + k, price))
            return false;
         sum += weight * price;  
      }
      val = sum / sumw;
      return true;
   }
};

#endif


//RmaOnStream v1.0

#ifndef RmaOnStream_IMP
#define RmaOnStream_IMP

class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      int index = size - 1 - period;
      if (index == 0)
      {
         _buffer[index] = price;
      }
      else
      {
         _buffer[index] = (_buffer[index - 1] * (_length - 1) + price) / _length;
      }
      val = _buffer[index];
      return true;
   }
};

#endif
// Zero lag TEMA on stream v1.0




#ifndef ZeroLagTEMAOnStream_IMP
#define ZeroLagTEMAOnStream_IMP

class ZeroLagTEMAOnStream : public AStreamBase
{
   TemaOnStream *_tema1;
   TemaOnStream *_tema2;
public:
   ZeroLagTEMAOnStream(IStream *source, const int length)
   {
      _tema1 = new TemaOnStream(source, length);
      _tema2 = new TemaOnStream(_tema1, length);
   }

   ~ZeroLagTEMAOnStream()
   {
      delete _tema2;
      delete _tema1;
   }

   int Size()
   {
      return _tema2.Size();
   }

   bool GetValue(const int period, double &val)
   {
      double tema1, tema2;
      if (!_tema1.GetValue(period, tema1) || !_tema2.GetValue(period, tema2))
         return false;

      val = (2.0 * tema1 - tema2);
      return true;
   }
};

#endif


// Zero lag MA on stream v1.0

#ifndef ZeroLagMAOnStream_IMP
#define ZeroLagMAOnStream_IMP

class ZeroLagMAOnStream : public AOnStream
{
   int _length;
   double _buffer[];
   double _alpha;
public:
   ZeroLagMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _alpha = 2.0 / (1.0 + _length);
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - 1)
         return false;

      double price;
      if (!_source.GetValue(period, price))
         return false;

      int bufferIndex = totalBars - 1 - period;
      int shift = (int)((_length - 1.0) / 2.0);
      double prevPrice;
      if (period < shift || !_source.GetValue(period - shift, prevPrice))
      {
         _buffer[bufferIndex] = price;
         return true;
      }

      _buffer[bufferIndex] = _buffer[bufferIndex - 1] + _alpha * (2.0 * price - prevPrice - _buffer[bufferIndex - 1]);
      val = _buffer[bufferIndex];
      return true;
   }
};

#endif

#ifndef AveragesStreamFactory_IMP
#define AveragesStreamFactory_IMP

// Averages v. 1.1

class AveragesStreamFactory
{
public:
   static IStream *Create(IStream *source, const int length, const MATypes type)
   {
      switch (type)
      {
         case ma_sma:
            return new SmaOnStream(source, length);
         case ma_ema:
            return new EMAOnStream(source, length);
         //case 2  : return(iDsema(price,length,r,instanceNo));
         // case 3  : return(iDema(price,length,r,instanceNo));
         case ma_tema:
            return new TemaOnStream(source, length);
         // case 5  : return(iSmma(price,length,r,instanceNo));
         case ma_lwma:
            return new LwmaOnStream(source, length);
         // case 7  : return(iLwmp(price,length,r,instanceNo));
         // case 8  : return(iAlex(price,length,r,instanceNo));
         case ma_vwma:
            return new VwmaOnStream(source, length);
         // case 10 : return(iHull(price,length,r,instanceNo));
         // case 11 : return(iTma(price,length,r,instanceNo));
         // case 12 : return(iSineWMA(price,(int)length,r,instanceNo));
         // case 13 : return(iLinr(price,length,r,instanceNo));
         // case 14 : return(iIe2(price,length,r,instanceNo));
         // case 15 : return(iNonLagMa(price,length,r,instanceNo));
         case ma_zlma:
            return new ZeroLagMAOnStream(source, length);
         case ma_rma:
            return new RmaOnStream(source, length);
         case ma_zltema:
            return new ZeroLagTEMAOnStream(source, length);
         // case 17 : return(iLeader(price,length,r,instanceNo));
         // case 18 : return(iSsm(price,length,r,instanceNo));
         // case 19 : return(iSmooth(price,(int)length,r,instanceNo));
         // default : return(0);
      }
      return NULL;
   }
};

#endif


// Trading time condition v3.2





#ifndef TradingTimeCondition_IMP
#define TradingTimeCondition_IMP

int ParseTime(const string time, string &error)
{
   string items[];
   StringSplit(time, ':', items);
   int hours;
   int minutes;
   int seconds;
   if (ArraySize(items) > 1)
   {
      if (ArraySize(items) != 3)
      {
         error = "Bad format for " + time;
         return -1;
      }
      //hh:mm:ss
      seconds = (int)StringToInteger(items[2]);
      minutes = (int)StringToInteger(items[1]);
      hours = (int)StringToInteger(items[0]);
   }
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
   }
   if (hours > 24)
   {
      error = "Incorrect number of hours in " + time;
      return -1;
   }
   if (minutes > 59)
   {
      error = "Incorrect number of minutes in " + time;
      return -1;
   }
   if (seconds > 59)
   {
      error = "Incorrect number of seconds in " + time;
      return -1;
   }
   if (hours == 24 && (minutes != 0 || seconds != 0))
   {
      error = "Incorrect date";
      return -1;
   }
   return (hours * 60 + minutes) * 60 + seconds;
}

ICondition* CreateTradingTimeCondition(const string startTime, const string endTime, bool useWeekly,
   const DayOfWeek startDay, const string weekStartTime, const DayOfWeek stopDay, 
   const string weekEndTime, string &error)
{
   int _startTime = ParseTime(startTime, error);
   if (_startTime == -1)
      return NULL;
   int _endTime = ParseTime(endTime, error);
   if (_endTime == -1)
      return NULL;
   if (!useWeekly)
   {
      if (_startTime == _endTime)
         return new NoCondition();
      return new TradingTimeCondition(_startTime, _endTime);
   }

   int _weekStartTime = ParseTime(weekStartTime, error);
   if (_weekStartTime == -1)
      return NULL;
   int _weekEndTime = ParseTime(weekEndTime, error);
   if (_weekEndTime == -1)
      return NULL;

   return new TradingTimeCondition(_startTime, _endTime, startDay, _weekStartTime, stopDay, _weekEndTime);
}

class TradingTimeCondition : public AConditionBase
{
   int _startTime;
   int _endTime;
   bool _useWeekTime;
   int _weekStartTime;
   int _weekStartDay;
   int _weekStopTime;
   int _weekStopDay;
public:
   TradingTimeCondition(int startTime, int endTime)
      :AConditionBase("Trading Time")
   {
      _startTime = startTime;
      _endTime = endTime;
      _useWeekTime = false;
   }

   TradingTimeCondition(int startTime, int endTime, const DayOfWeek startDay,
      int weekStartTime, const DayOfWeek stopDay, int weekEndTime)
      :AConditionBase("Trading Time")
   {
      _startTime = startTime;
      _endTime = endTime;
      _useWeekTime = true;
      _weekStartDay = (int)startDay;
      _weekStopDay = (int)stopDay;
      _weekStartTime = weekStartTime;
      _weekStopTime = weekEndTime;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(TimeCurrent(), current_time))
         return false;
      if (!IsIntradayTradingTime(current_time))
         return false;
      return IsWeeklyTradingTime(current_time);
   }

   void GetStartEndTime(const datetime date, datetime &start, datetime &end)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
         return;

      current_time.hour = 0;
      current_time.min = 0;
      current_time.sec = 0;
      datetime referece = StructToTime(current_time);

      start = referece + _startTime;
      end = referece + _endTime;
      if (_startTime > _endTime)
      {
         start += 86400;
      }
   }
private:
   bool IsIntradayTradingTime(const MqlDateTime &current_time)
   {
      if (_startTime == _endTime)
         return true;
      int current_t = TimeToInt(current_time);
      if (_startTime > _endTime)
         return current_t >= _startTime || current_t <= _endTime;
      return current_t >= _startTime && current_t <= _endTime;
   }

   int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }

   bool IsWeeklyTradingTime(const MqlDateTime &current_time)
   {
      if (!_useWeekTime)
         return true;
      if (current_time.day_of_week < _weekStartDay || current_time.day_of_week > _weekStopDay)
         return false;

      if (current_time.day_of_week == _weekStartDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t >= _weekStartTime;
      }
      if (current_time.day_of_week == _weekStopDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t < _weekStopTime;
      }

      return true;
   }
};

class TokyoTimezoneCondition : public TradingTimeCondition
{
public:
   TokyoTimezoneCondition()
      : TradingTimeCondition((-5) * 3600, (-5 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Tokyo TZ: " + (result ? "true" : "false");
   }
};

class NewYorkTimezoneCondition : public TradingTimeCondition
{
public:
   NewYorkTimezoneCondition()
      : TradingTimeCondition(8 * 3600, (8 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "NY TZ: " + (result ? "true" : "false");
   }
};

class LondonTimezoneCondition : public TradingTimeCondition
{
public:
   LondonTimezoneCondition()
      : TradingTimeCondition(3 * 3600, (3 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "London TZ: " + (result ? "true" : "false");
   }
};

class DayTimeCondition : public TradingTimeCondition
{
   int _dayOfMonth;
public:
   DayTimeCondition(int dayOfMonth, int startTime, int intervalSeconds)
      :TradingTimeCondition(startTime, startTime + intervalSeconds)
   {
      _dayOfMonth = dayOfMonth;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(TimeCurrent(), current_time) || current_time.day != _dayOfMonth)
      {
         return false;
      }
      
      return TradingTimeCondition::IsPass(period, date);
   }
};

#endif
// And condition v4.1

#ifndef AndCondition_IMP
#define AndCondition_IMP
class AndCondition : public AConditionBase
{
   ICondition *_conditions[];
public:
   ~AndCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         _conditions[i].Release();
      }
   }

   void Add(ICondition* condition, bool addRef)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
      if (addRef)
         condition.AddRef();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (!_conditions[i].IsPass(period, date))
            return false;
      }
      return true;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      string messages = "";
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         string logMessage = _conditions[i].GetLogMessage(period, date);
         if (messages != "")
            messages = messages + " and (" + logMessage + ")";
         else
            messages = "(" + logMessage + ")";
      }
      return messages + (IsPass(period, date) ? "=true" : "=false");
   }
};
#endif
// Or condition v4.1



#ifndef OrCondition_IMP
#define OrCondition_IMP

class OrCondition : public AConditionBase
{
   ICondition *_conditions[];
public:
   ~OrCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         _conditions[i].Release();
      }
   }

   void Add(ICondition *condition, bool addRef)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
      if (addRef)
         condition.AddRef();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (_conditions[i].IsPass(period, date))
            return true;
      }
      return false;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      string messages = "";
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         string logMessage = _conditions[i].GetLogMessage(period, date);
         if (messages != "")
            messages = messages + " or (" + logMessage + ")";
         else
            messages = "(" + logMessage + ")";
      }
      return messages + (IsPass(period, date) ? "=true" : "=false");
   }
};
#endif
// Not condition v2.0



#ifndef NotCondition_IMP
#define NotCondition_IMP

class NotCondition : public AConditionBase
{
   ICondition* _condition;
public:
   NotCondition(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~NotCondition()
   {
      _condition.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      return !_condition.IsPass(period, date); 
   }
};

#endif

class LongCondition : public ACondition
{
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return protectionLine == 0 && iClose(_symbol, _timeframe, period) > prevBuyPoint;
   }
};

class ShortCondition : public ACondition
{
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return protectionLine == 0 && iClose(_symbol, _timeframe, period) < prevSellPoint;
   }
};
class Long2Condition : public ACondition
{
public:
   Long2Condition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return protectionLine != 0 && iClose(_symbol, _timeframe, period) > protectionLine;
   }
};

class Short2Condition : public ACondition
{
public:
   Short2Condition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return protectionLine != 0 && iClose(_symbol, _timeframe, period) < protectionLine;
   }
};

class ExitLongCondition : public ACondition
{
public:
   ExitLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period, const datetime date)
   {
      return protectionLine != 0 && iClose(_symbol, _timeframe, period) < protectionLine;
   }
};

class ExitShortCondition : public ACondition
{
public:
   ExitShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period, const datetime date)
   {
      return protectionLine != 0 && iClose(_symbol, _timeframe, period) > protectionLine;
   }
};

ICondition* CreateLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }

   OrCondition* or = new OrCondition();

   AndCondition* condition = new AndCondition();
   condition.Add(new LongCondition(symbol, timeframe), false);

   Long2Condition* condition2 = new Long2Condition(symbol, timeframe);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      or.Add(switchCondition, false);
      ActOnSwitchCondition* switchCondition2 = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition2);
      condition2.Release();
      or.Add(switchCondition2, false);
   #else 
      or.Add((ICondition*) condition, false);
      or.Add((ICondition*) condition2, false);
   #endif
   return or;
}

ICondition* CreateLongFilterCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }
   AndCondition* condition = new AndCondition();
   condition.Add(new NoCondition(), false);
   return condition;
}

ICondition* CreateShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == LongSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }

   OrCondition* or = new OrCondition();

   AndCondition* condition = new AndCondition();
   condition.Add(new ShortCondition(symbol, timeframe), false);
      
   Short2Condition* condition2 = new Short2Condition(symbol, timeframe);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      or.Add(switchCondition, false);
      ActOnSwitchCondition* switchCondition2 = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition2);
      condition2.Release();
      or.Add(switchCondition2, false);
   #else 
      or.Add((ICondition*) condition, false);
      or.Add((ICondition*) condition2, false);
   #endif
   return or;
}

ICondition* CreateShortFilterCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == LongSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }
   AndCondition* condition = new AndCondition();
   condition.Add(new NoCondition(), false);
   return condition;
}

ICondition* CreateExitLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   AndCondition* condition = new AndCondition();
   condition.Add(new ExitLongCondition(symbol, timeframe), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else
      return (ICondition *)condition;
   #endif
}

ICondition* CreateExitShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   AndCondition* condition = new AndCondition();
   condition.Add(new ExitShortCondition(symbol, timeframe), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else
      return (ICondition *)condition;
   #endif
}

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

IStream* CreateTrailingStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
{
   if (trailing_target_type == TrailingTargetMA)
   {
      IStream* source = new SimplePriceStream(symbol, timeframe, PriceClose);
      IStream* trailingStream = AveragesStreamFactory::Create(source, trailing_ma_length, trailing_ma_type);
      source.Release();
      return trailingStream;
   }
   return NULL;
}

AOrderAction* CreateTrailing(const string symbol, const ENUM_TIMEFRAMES timeframe, ActionOnConditionLogic* actions)
{
   #ifdef STOP_LOSS_FEATURE
      switch (trailing_type)
      {
         case TrailingDontUse:
            return NULL;
      #ifdef INDICATOR_BASED_TRAILING
         case TrailingIndicator:
            return NULL;
      #endif
         case TrailingPips:
            {
               if (trailing_target_type == TrailingTargetStep)
               {
                  return new CreateTrailingAction(trailing_start, false, trailing_step, actions);
               }
               IStream* stream = CreateTrailingStream(symbol, timeframe);
               AOrderAction* action = new CreateTrailingStreamAction(trailing_start, false, stream, actions);
               stream.Release();
               return action;
            }
         case TrailingATR:
            return new CreateATRTrailingAction(symbol, timeframe, trailing_start, trailing_step, actions);
         case TrailingSLPercent:
            {
               if (trailing_target_type == TrailingTargetStep)
               {
                  return new CreateTrailingAction(trailing_start, true, trailing_step, actions);
               }
               IStream* stream = CreateTrailingStream(symbol, timeframe);
               AOrderAction* action = new CreateTrailingStreamAction(trailing_start, true, stream, actions);
               stream.Release();
               return action;
            }
      }
   #endif
   return NULL;
}

#ifdef MARTINGALE_FEATURE
void CreateMartingale(TradingCalculator* tradingCalculator, string symbol, ENUM_TIMEFRAMES timeframe, IEntryStrategy* entryStrategy, 
   OrderHandlers* orderHandlers, ActionOnConditionLogic* actions)
{
   CustomLotsProvider* lots = new CustomLotsProvider();

   IStopLossStrategy* stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, true, stop_loss_type, stop_loss_value, stop_loss_atr_multiplicator);
   ITakeProfitStrategy* tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, true, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   IMoneyManagementStrategy* longMoneyManagement = new MoneyManagementStrategy(lots, stopLoss, tp);
   IAction* openLongAction = new EntryAction(entryStrategy, BuySide, longMoneyManagement, "", orderHandlers, true);
   
   stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, false, stop_loss_type, stop_loss_value, stop_loss_atr_multiplicator);
   tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, false, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   IMoneyManagementStrategy* shortMoneyManagement = new MoneyManagementStrategy(lots, stopLoss, tp);
   IAction* openShortAction = new EntryAction(entryStrategy, SellSide, shortMoneyManagement, "", orderHandlers, true);

   CreateMartingaleAction* martingaleAction = new CreateMartingaleAction(lots, martingale_lot_sizing_type, martingale_lot_value, 
      martingale_step, openLongAction, openShortAction, max_longs, max_shorts, actions);
   openLongAction.Release();
   openShortAction.Release();
   
   martingaleAction.RestoreActions(_Symbol, magic_number);
   orderHandlers.AddOrderAction(martingaleAction);
   martingaleAction.Release();
}
#endif

TradingController *CreateController(const string symbol, const ENUM_TIMEFRAMES timeframe, string algoId, string &error)
{
   #ifdef TRADING_TIME_FEATURE
      ICondition* tradingTimeCondition = CreateTradingTimeCondition(start_time, stop_time, use_weekly_timing,
         week_start_day, week_start_time, week_stop_day, 
         week_stop_time, error);
      if (tradingTimeCondition == NULL)
      {
         return NULL;
      }
   #else
      ICondition* tradingTimeCondition = NULL;
   #endif

   TradingCalculator* tradingCalculator = TradingCalculator::Create(symbol);
   if (!tradingCalculator.IsLotsValid(lots_value, lots_type, error))
   {
      #ifdef TRADING_TIME_FEATURE
         tradingTimeCondition.Release();
      #endif
      delete tradingCalculator;
      return NULL;
   }

   Signaler* signaler = new Signaler();
   signaler.SetMessagePrefix(symbol + "/" + TimeframeToString(timeframe) + ": ");
   
   ICloseOnOppositeStrategy* closeOnOpposite = close_on_opposite 
      ? (ICloseOnOppositeStrategy*)new DoCloseOnOppositeStrategy(slippage_points, magic_number)
      : (ICloseOnOppositeStrategy*)new DontCloseOnOppositeStrategy();
   OrderHandlers* orderHandlers = new OrderHandlers();
   ActionOnConditionLogic* actions = new ActionOnConditionLogic();
   #ifdef USE_MARKET_ORDERS
      IEntryStrategy* entryStrategy = new MarketEntryStrategy(symbol, magic_number, slippage_points, actions, ecn_broker);
   #else
      AStream *longPrice = new LongEntryStream(symbol, timeframe);
      AStream *shortPrice = new ShortEntryStream(symbol, timeframe);
      IEntryStrategy* entryStrategy = new PendingEntryStrategy(symbol, magic_number, slippage_points, longPrice, shortPrice, actions, ecn_broker);
   #endif

   AndCondition* longCondition = new AndCondition();
   AndCondition* shortCondition = new AndCondition();
   #ifdef TRADING_TIME_FEATURE
      longCondition.Add(tradingTimeCondition, true);
      shortCondition.Add(tradingTimeCondition, true);
      tradingTimeCondition.Release();
   #endif

   AndCondition* longFilterCondition = new AndCondition();
   AndCondition* shortFilterCondition = new AndCondition();

   switch (logic_direction)
   {
      case DirectLogic:
         longFilterCondition.Add(CreateLongFilterCondition(symbol, timeframe), false);
         shortFilterCondition.Add(CreateShortFilterCondition(symbol, timeframe), false);
         longCondition.Add(CreateLongCondition(symbol, timeframe), false);
         shortCondition.Add(CreateShortCondition(symbol, timeframe), false);
         break;
      case ReversalLogic:
         shortFilterCondition.Add(CreateLongFilterCondition(symbol, timeframe), false);
         longFilterCondition.Add(CreateShortFilterCondition(symbol, timeframe), false);
         longCondition.Add(CreateShortCondition(symbol, timeframe), false);
         shortCondition.Add(CreateLongCondition(symbol, timeframe), false);
         break;
   }
   if (position_cap)
   {
      ICondition* buyLimitCondition = new PositionLimitHitCondition(BuySide, magic_number, no_of_buy_position, no_of_positions, symbol);
      ICondition* sellLimitCondition = new PositionLimitHitCondition(SellSide, magic_number, no_of_sell_position, no_of_positions, symbol);
      longFilterCondition.Add(new NotCondition(buyLimitCondition), false);
      shortFilterCondition.Add(new NotCondition(sellLimitCondition), false);
      buyLimitCondition.Release();
      sellLimitCondition.Release();
   }
   if (cap_by_margin)
   {
      ICondition* minMarginCondition = new MinMarginCondition(min_margin);
      longFilterCondition.Add(new NotCondition(minMarginCondition), false);
      shortFilterCondition.Add(new NotCondition(minMarginCondition), false);
      minMarginCondition.Release();
   }
   
   EntryPositionController* longPosition = new EntryPositionController(BuySide, longCondition, longFilterCondition, 
      closeOnOpposite, signaler, "", "Buy");
   EntryPositionController* shortPosition = new EntryPositionController(SellSide, shortCondition, shortFilterCondition,
      closeOnOpposite, signaler, "", "Sell");
   longCondition.Release();
   shortCondition.Release();
   longFilterCondition.Release();
   shortFilterCondition.Release();
      
   closeOnOpposite.Release();
   
   TradingController* controller = new TradingController(tradingCalculator, timeframe, timeframe, actions, signaler, algoId);
   controller.AddLongPosition(longPosition);
   controller.AddShortPosition(shortPosition);

   RememberLevelOrderAction* orderAction = new RememberLevelOrderAction();
   orderHandlers.AddOrderAction(orderAction);
   orderAction.Release();
   
   if (breakeven_type != StopLimitDoNotUse)
   {
      #ifndef USE_NET_BREAKEVEN
         MoveStopLossOnProfitOrderAction* orderAction = new MoveStopLossOnProfitOrderAction(breakeven_type, breakeven_value, breakeven_level, signaler, actions);
         orderAction.RestoreActions(_Symbol, magic_number);
         orderHandlers.AddOrderAction(orderAction);
         orderAction.Release();
      #endif
   }
   #ifdef TWO_LEVEL_TP
   switch (take_profit_type)
   {
      case TPDoNotUse:
         break;
      case TPPercent:
         {
            PartialCloseOnProfitOrderAction* orderAction = new PartialCloseOnProfitOrderAction(StopLimitPercent, take_profit_value_1, take_profit_1_close, signaler, actions);
            orderHandlers.AddOrderAction(orderAction);
            orderAction.Release();
         }
         break;
      case TPPips:
         {
            PartialCloseOnProfitOrderAction* orderAction = new PartialCloseOnProfitOrderAction(StopLimitPips, take_profit_value_1, take_profit_1_close, signaler, actions);
            orderHandlers.AddOrderAction(orderAction);
            orderAction.Release();
         }
         break;
      case TPDollar:
         {
            PartialCloseOnProfitOrderAction* orderAction = new PartialCloseOnProfitOrderAction(StopLimitDollar, take_profit_value_1, take_profit_1_close, signaler, actions);
            orderHandlers.AddOrderAction(orderAction);
            orderAction.Release();
         }
         break;
      case TPRiskReward:
         {
            PartialCloseOnProfitOrderAction* orderAction = new PartialCloseOnProfitOrderAction(StopLimitRiskReward, take_profit_value_1, take_profit_1_close, signaler, actions);
            orderHandlers.AddOrderAction(orderAction);
            orderAction.Release();
         }
         break;
      case TPAbsolute:
         {
            PartialCloseOnProfitOrderAction* orderAction = new PartialCloseOnProfitOrderAction(StopLimitAbsolute, take_profit_value_1, take_profit_1_close, signaler, actions);
            orderHandlers.AddOrderAction(orderAction);
            orderAction.Release();
         }
         break;
      default:
         Print("Not supported take profit type");
         break;
   }
   #endif

   AOrderAction* trailingAction = CreateTrailing(symbol, timeframe, actions);
   if (trailingAction != NULL)
   {
      trailingAction.RestoreActions(_Symbol, magic_number);
      orderHandlers.AddOrderAction(trailingAction);
      trailingAction.Release();
   }

   #ifdef MARTINGALE_FEATURE
      switch (martingale_type)
      {
         case MartingaleOnLoss:
            {
               CreateMartingale(tradingCalculator, symbol, timeframe, entryStrategy, orderHandlers, actions);
            }
            break;
      }
   #endif

   #ifdef WITH_EXIT_LOGIC
      controller.SetExitLogic(exit_logic);
      ICondition* exitLongCondition = CreateExitLongCondition(symbol, timeframe);
      ICondition* exitShortCondition = CreateExitShortCondition(symbol, timeframe);
   #else
      ICondition* exitLongCondition = new DisabledCondition();
      ICondition* exitShortCondition = new DisabledCondition();
   #endif

   switch (logic_direction)
   {
      case DirectLogic:
         controller.SetExitLongCondition(exitLongCondition);
         controller.SetExitShortCondition(exitShortCondition);
         break;
      case ReversalLogic:
         controller.SetExitLongCondition(exitShortCondition);
         controller.SetExitShortCondition(exitLongCondition);
         break;
   }
   if (mandatory_closing && tradingTimeCondition != NULL)
   {
      NotCondition* condition = new NotCondition(tradingTimeCondition);
      IAction* action = new CloseAllAction(magic_number, slippage_points);
      actions.AddActionOnCondition(action, condition);
      action.Release();
      condition.Release();
   }
   
   IMoneyManagementStrategy* longMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, true, 
      lots_type, lots_value, stop_loss_type, stop_loss_value, stop_loss_atr_multiplicator, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   IAction* openLongAction = new EntryAction(entryStrategy, BuySide, longMoneyManagement, "", orderHandlers);
   longPosition.AddAction(openLongAction);
   openLongAction.Release();
   IMoneyManagementStrategy* shortMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, false, 
      lots_type, lots_value, stop_loss_type, stop_loss_value, stop_loss_atr_multiplicator, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   IAction* openShortAction = new EntryAction(entryStrategy, SellSide, shortMoneyManagement, "", orderHandlers);
   shortPosition.AddAction(openShortAction);
   openShortAction.Release();

   #ifdef NET_STOP_LOSS_FEATURE
      if (net_stop_loss_type != StopLimitDoNotUse)
      {
         MoveNetStopLossAction* action = new MoveNetStopLossAction(tradingCalculator, net_stop_loss_type, net_stop_loss_value, magic_number);
         #ifdef USE_NET_BREAKEVEN
            if (breakeven_type != StopLimitDoNotUse)
            {
               //TODO: use breakeven_type as well
               action.SetBreakeven(breakeven_value, breakeven_level);
            }
         #endif

         NoCondition* condition = new NoCondition();
         actions.AddActionOnCondition(action, condition);
         action.Release();
         condition.Release();
      }
   #endif
   #ifdef NET_TAKE_PROFIT_FEATURE
      if (net_take_profit_type != StopLimitDoNotUse)
      {
         IAction* action = new MoveNetTakeProfitAction(tradingCalculator, net_take_profit_type, net_take_profit_value, magic_number);
         NoCondition* condition = new NoCondition();
         actions.AddActionOnCondition(action, condition);
         action.Release();
         condition.Release();
      }
   #endif

   controller.SetEntryLogic(entry_logic);
   controller.SetEntryStrategy(entryStrategy);
   entryStrategy.Release();
   if (print_log)
   {
      string name = log_file;
      if (name == "")
      {
         name = symbol;
      }
      if (algoId != "" && algoId != NULL)
      {
         name = name + "_" + algoId;
      }
      MqlDateTime current_time;
      string suffix = "";
      if (TimeToStruct(TimeCurrent(), current_time))
      {
         name = name + "_" + IntegerToString(current_time.hour) + "-" + IntegerToString(current_time.min) + "-" + IntegerToString(current_time.sec);
      }
      name = name + ".csv";
      controller.SetPrintLog(name);
   }

   return controller;
}

OrderHandlers* orderHandlers;
double prevBuyPoint;
double prevSellPoint;
int OnInit()
{
   upperLine = upper_line;
   lowerLine = lower_line;
   prevBuyPoint = prev_buy_point;
   prevSellPoint = prev_sell_point;
   if (upperLine == 0)
   {
      double point = MarketInfo(_Symbol, MODE_POINT);
      int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;
      upperLine = MathFloor((iClose(_Symbol, _Period, 0)) / pipSize) * pipSize;
      lowerLine = upperLine - 30 * pipSize;
      prevBuyPoint = upperLine + 30 * pipSize;
      prevSellPoint = lowerLine - 30 * pipSize;
   }

   DrawLines();
   orderHandlers = new OrderHandlers();
   #ifdef SHOW_ACCOUNT_STAT
      stats = NULL;
   #endif
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   #ifdef MARTINGALE_FEATURE
      if (lots_type == PositionSizeRisk && martingale_type == MartingaleOnLoss)
      {
         Print("Error: martingale_type couldn't be used with this lot type!");
         return INIT_FAILED;
      }
   #endif

   string error;
   TradingController *controller = CreateController(_Symbol, trading_timeframe, trade_comment, error);
   if (controller == NULL)
   {
      Print(error);
      return INIT_FAILED;
   }
   int controllersCount = 0;
   ArrayResize(controllers, controllersCount + 1);
   controllers[controllersCount++] = controller;
   
   #ifdef SHOW_ACCOUNT_STAT
      stats = new AccountStatistics();
   #endif
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(ChartID(), EA_ID);
   orderHandlers.Clear();
   orderHandlers.Release();

   #ifdef SHOW_ACCOUNT_STAT
      delete stats;
   #endif
   int i_count = ArraySize(controllers);
   for (int i = 0; i < i_count; ++i)
   {
      delete controllers[i];
   }
}

void OnTick()
{
   double range = upperLine - lowerLine;
   if (neutralLevel > referentialLevel)
   {
      if (iClose(_Symbol, _Period, 1) < referentialLevel)
      {
         neutralLevel -= range;
         referentialLevel -= range;
         protectionLine = neutralLevel;
      }
   }
   else if (neutralLevel < referentialLevel)
   {
      if (iClose(_Symbol, _Period, 1) > referentialLevel)
      {
         neutralLevel += range;
         referentialLevel += range;
         protectionLine = neutralLevel;
      }
   }
   DrawLines();
   int i_count = ArraySize(controllers);
   for (int i = 0; i < i_count; ++i)
   {
      controllers[i].DoTrading();
   }
   #ifdef SHOW_ACCOUNT_STAT
      stats.Update();
   #endif
}
