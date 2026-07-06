// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=27&t=70216

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
#property version   "1.1"
#property strict

#define ACT_ON_SWITCH_CONDITION
#define REVERSABLE_LOGIC_FEATURE
#define STOP_LOSS_FEATURE
#define TAKE_PROFIT_FEATURE
#define USE_MARKET_ORDERS
#define TRADING_TIME_FEATURE
#define POSITION_CAP_FEATURE 

#ifdef SHOW_ACCOUNT_STAT
   string EA_NAME = "[EA NAME]";
#endif

enum TradingMode
{
   TradingModeLive, // Live
   TradingModeOnBarClose // On bar close
};

input ENUM_TIMEFRAMES trading_timeframe = PERIOD_CURRENT; // Trading timeframe
input int K_periods_1 = 7; // Stoch %K
input int D_periods_1 = 3; // Stoch %D
input int Slowing_1 = 3; // Stoch Slowing
input ENUM_MA_METHOD method_1 = MODE_SMA; // Smoothing method
input ENUM_STO_PRICE price_1 = STO_LOWHIGH;    //Price Field
input double os_1 = 10; // Oversold
input double ob_1 = 90; // Overbought
input ENUM_TIMEFRAMES tf2 = PERIOD_CURRENT; // Timeframe 2
input int K_periods_2 = 7; // Stoch %K
input int D_periods_2 = 3; // Stoch %D
input int Slowing_2 = 3; // Stoch Slowing
input ENUM_MA_METHOD method_2 = MODE_SMA; // Smoothing method
input ENUM_STO_PRICE price_2 = STO_LOWHIGH;    //Price Field
input double os_2 = 10; // Oversold
input double ob_2 = 90; // Overbought
input ENUM_TIMEFRAMES tf3 = PERIOD_CURRENT; // Timeframe 3
input int K_periods_3 = 7; // Stoch %K
input int D_periods_3 = 3; // Stoch %D
input int Slowing_3 = 3; // Stoch Slowing
input ENUM_MA_METHOD method_3 = MODE_SMA; // Smoothing method
input ENUM_STO_PRICE price_3 = STO_LOWHIGH;    //Price Field
input double os_3 = 10; // Oversold
input double ob_3 = 90; // Overbought

input string GeneralSection = ""; // == General ==
input string GeneralSectionDesc = "https://github.com/sibvic/mq4-templates/wiki/EA_Base-template-parameters"; // Description of parameters could be found at
input bool ecn_broker = false; // ECN Broker? 
TradingMode entry_logic = TradingModeLive; // Entry logic
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
   input bool position_cap = false; // Position Cap
   input int no_of_positions = 1; // Max # of buy+sell positions
   input int no_of_buy_position = 1; // Max # of buy positions
   input int no_of_sell_position = 1; // Max # of sell positions
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
   input MartingaleStepSizeType martingale_step_type = MartingaleStepSizePercent; // Step unit
   input double martingale_step = 5; // Open matringale position step
#endif

enum TrailingType
{
   TrailingDontUse, // No trailing
   TrailingPips // Use trailing in pips
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
   SLHighLow // High/low of X bars
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
#ifdef STOP_LOSS_FEATURE
   string StopLossSection            = ""; // == Stop loss ==
   input StopLossType stop_loss_type = SLDoNotUse; // Stop loss type
   input double stop_loss_value = 10; // Stop loss value
   input double stop_loss_atr_multiplicator = 1; // Stop loss multiplicator (for ATR SL)
   input TrailingType trailing_type = TrailingDontUse; // Trailing type
   input double trailing_step = 10; // Trailing step
   input double trailing_start = 0; // Min distance to order to activate the trailing
#else
   StopLossType stop_loss_type = SLDoNotUse; // Stop loss type
   double stop_loss_value = 10;
#endif
input StopLimitType breakeven_type = StopLimitDoNotUse; // Trigger type for the breakeven
input double breakeven_value = 10; // Trigger for the breakeven
input double breakeven_level = 0; // Breakeven target
#ifdef NET_STOP_LOSS_FEATURE
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
#endif
#ifdef NET_TAKE_PROFIT_FEATURE
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
#ifdef TRADING_TIME_FEATURE
   input string start_time = "000000"; // Start time in hhmmss format
   input string stop_time = "000000"; // Stop time in hhmmss format
   input bool mandatory_closing = false; // Mandatory closing for non-trading time
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
input string log_file = "log.csv"; // Log file name

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
      return _condition.GetLogMessage(period, date);
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
// Action on condition logic v2.0






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

// Money management strategy interface v1.0

#ifndef IMoneyManagementStrategy_IMP
#define IMoneyManagementStrategy_IMP
interface IMoneyManagementStrategy
{
public:
   virtual void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit) = 0;
};
#endif

// Lots provider interface v1.0

#ifndef ILotsProvider_IMP
#define ILotsProvider_IMP
class ILotsProvider
{
public:
   virtual double GetValue(int period, double entryPrice) = 0;
};
#endif


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
   StopLimitType _stopLossType;
   double _stopLoss;
   bool _isBuy;
   ILotsProvider* _lotsStrategy;
public:
   DollarStopLossStrategy(TradingCalculator* calculator, StopLimitType stopLossType, double stopLoss, bool isBuy, ILotsProvider* lotsStrategy)
   {
      _lotsStrategy = lotsStrategy;
      _isBuy = isBuy;
      _stopLoss = stopLoss;
      _stopLossType = stopLossType;
      _calculator = calculator;
   }

   virtual double GetValue(const int period, double entryPrice)
   {
      double amount = _lotsStrategy.GetValue(period, entryPrice);
      return _calculator.CalculateStopLoss(_isBuy, _stopLoss, _stopLossType, amount, entryPrice);
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
         return NULL; // Not supported at all
   }
   return NULL;
}

MoneyManagementStrategy* CreateMoneyManagementStrategy(TradingCalculator* tradingCalculator, string symbol,
   ENUM_TIMEFRAMES timeframe, bool isBuy, PositionSizeType lotsType, double lotsValue,
   StopLossType stopLossType, double stopLossValue, double stopLosstAtrMultiplicator,
   TakeProfitType takeProfitType, double takeProfitValue, double takeProfitAtrMultiplicator)
{
   ILotsProvider* lots = NULL;
   IStopLossStrategy* stopLoss = NULL;
   switch (lotsType)
   {
      case PositionSizeRisk:
         stopLoss = CreateStopLossStrategy(tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLosstAtrMultiplicator);
         lots = new RiskLotsProvider(tradingCalculator, lotsType, lotsValue, stopLoss);
         break;
      default:
         lots = new DefaultLotsProvider(tradingCalculator, lotsType, lotsValue);
         switch (stopLossType)
         {
            case SLDollar:
               stopLoss = new DollarStopLossStrategy(tradingCalculator, StopLimitDollar, stopLossValue, isBuy, lots);
               break;
            default:
               stopLoss = CreateStopLossStrategy(tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLosstAtrMultiplicator);
               break;
         }
         break;
   }
   ITakeProfitStrategy* tp = NULL;
   switch (takeProfitType)
   {
      case TPDoNotUse:
         tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDoNotUse, takeProfitValue, isBuy);
         break;
      #ifdef TAKE_PROFIT_FEATURE
         case TPPercent:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPercent, takeProfitValue, isBuy);
            break;
         case TPPips:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPips, takeProfitValue, isBuy);
            break;
         case TPDollar:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDollar, takeProfitValue, isBuy);
            break;
         case TPRiskReward:
            tp = new RiskToRewardTakeProfitStrategy(takeProfitValue, isBuy);
            break;
         case TPAbsolute:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitAbsolute, takeProfitValue, isBuy);
            break;
         case TPAtr:
            tp = new ATRTakeProfitStrategy(symbol, timeframe, (int)takeProfitValue, takeProfitAtrMultiplicator, isBuy);
            break;
      #endif
   }
   
   return new MoneyManagementStrategy(lots, stopLoss, tp);
}
#endif
// Martingale strategy v2.1



interface IMartingaleStrategy
{
public:
   virtual void OnOrder(const int order) = 0;
   virtual bool NeedAnotherPosition(OrderSide &side) = 0;
   virtual IMoneyManagementStrategy *GetMoneyManagement() = 0;
};

class NoMartingaleStrategy : public IMartingaleStrategy
{
public:
   void OnOrder(const int order) { }
   bool NeedAnotherPosition(OrderSide &side) { return false; }
   IMoneyManagementStrategy *GetMoneyManagement() { return NULL; }
};

class ACustomAmountMoneyManagementStrategy : public IMoneyManagementStrategy
{
protected:
   TradingCalculator *_calculator;
   double _amount;
public:
   ACustomAmountMoneyManagementStrategy(TradingCalculator *calculator)
   {
      _calculator = calculator;
      _amount = 0.0;
   }

   void SetAmount(const double amount)
   {
      _amount = amount;
   }
};

class CustomAmountLongMoneyManagementStrategy : public ACustomAmountMoneyManagementStrategy
{
public:
   CustomAmountLongMoneyManagementStrategy(TradingCalculator *calculator)
      :ACustomAmountMoneyManagementStrategy(calculator)
   {
   }

   void Get(const int period, const double rate, double &amount, double &stopLoss, double &takeProfit)
   {
      double ask = rate;
      amount = _amount;
      switch (stop_loss_type)
      {
         case SLDoNotUse:
            stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, StopLimitDoNotUse, amount, ask);
            break;
         case SLPercent:
            stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, StopLimitPercent, amount, ask);
            break;
         case SLPips:
            stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, StopLimitPips, amount, ask);
            break;
         case SLDollar:
            stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, StopLimitDollar, amount, ask);
            break;
         case SLAbsolute:
            stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, StopLimitAbsolute, amount, ask);
            break;
         case SLAtr:
            Print("Not supported yet");
            stopLoss = -1;
            break;
      }
      
      switch (take_profit_type)
      {
         case TPDoNotUse:
            takeProfit = _calculator.CalculateTakeProfit(true, take_profit_value, StopLimitDoNotUse, amount, ask);
            break;
         case TPPercent:
            takeProfit = _calculator.CalculateTakeProfit(true, take_profit_value, StopLimitPercent, amount, ask);
            break;
         case TPPips:
            takeProfit = _calculator.CalculateTakeProfit(true, take_profit_value, StopLimitPips, amount, ask);
            break;
         case TPDollar:
            takeProfit = _calculator.CalculateTakeProfit(true, take_profit_value, StopLimitDollar, amount, ask);
            break;
         case TPRiskReward:
            Print("Not supported yet");
            takeProfit = -1;
            break;
         case TPAbsolute:
            takeProfit = _calculator.CalculateTakeProfit(true, take_profit_value, StopLimitAbsolute, amount, ask);
            break;
         case TPAtr:
            Print("Not supported yet");
            takeProfit = -1;
            break;
      }
   }
};

class CustomAmountShortMoneyManagementStrategy : public ACustomAmountMoneyManagementStrategy
{
public:
   CustomAmountShortMoneyManagementStrategy(TradingCalculator *calculator)
      :ACustomAmountMoneyManagementStrategy(calculator)
   {
   }

   void Get(const int period, const double rate, double &amount, double &stopLoss, double &takeProfit)
   {
      double bid = rate;
      amount = _amount;
      switch (stop_loss_type)
      {
         case SLDoNotUse:
            stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, StopLimitDoNotUse, amount, bid);
            break;
         case SLPercent:
            stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, StopLimitPercent, amount, bid);
            break;
         case SLPips:
            stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, StopLimitPips, amount, bid);
            break;
         case SLDollar:
            stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, StopLimitDollar, amount, bid);
            break;
         case SLAbsolute:
            stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, StopLimitAbsolute, amount, bid);
            break;
         case SLAtr:
            Print("Not supported yet");
            stopLoss = -1;
            break;
      }
      switch (take_profit_type)
      {
         case TPDoNotUse:
            takeProfit = _calculator.CalculateTakeProfit(false, take_profit_value, StopLimitDoNotUse, amount, bid);
            break;
         case TPPercent:
            takeProfit = _calculator.CalculateTakeProfit(false, take_profit_value, StopLimitPercent, amount, bid);
            break;
         case TPPips:
            takeProfit = _calculator.CalculateTakeProfit(false, take_profit_value, StopLimitPips, amount, bid);
            break;
         case TPDollar:
            takeProfit = _calculator.CalculateTakeProfit(false, take_profit_value, StopLimitDollar, amount, bid);
            break;
         case TPRiskReward:
            Print("Not supported yet");
            takeProfit = -1;
            break;
         case TPAbsolute:
            takeProfit = _calculator.CalculateTakeProfit(false, take_profit_value, StopLimitAbsolute, amount, bid);
            break;
         case TPAtr:
            Print("Not supported yet");
            takeProfit = -1;
            break;
      }
   }
};

class ActiveMartingaleStrategy : public IMartingaleStrategy
{
   int _order;
   TradingCalculator *_calculator;
   CustomAmountLongMoneyManagementStrategy *_longMoneyManagement;
   CustomAmountShortMoneyManagementStrategy *_shortMoneyManagement;
   double _lotValue;
   MartingaleLotSizingType _martingaleLotSizingType;
   ICondition* _condition;
public:
   ActiveMartingaleStrategy(TradingCalculator *calculator, 
      MartingaleLotSizingType martingaleLotSizingType, 
      const double lotValue,
      ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
      _martingaleLotSizingType = martingaleLotSizingType;
      _lotValue = lotValue;
      _order = -1;
      _calculator = calculator;
      _longMoneyManagement = new CustomAmountLongMoneyManagementStrategy(_calculator);
      _shortMoneyManagement = new CustomAmountShortMoneyManagementStrategy(_calculator);
   }

   ~ActiveMartingaleStrategy()
   {
      _condition.Release();
      delete _longMoneyManagement;
      delete _shortMoneyManagement;
   }

   void OnOrder(const int order)
   {
      _order = order;
   }

   IMoneyManagementStrategy *GetMoneyManagement()
   {
      if (_order == -1)
         return NULL;
      if (!OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return NULL;

      double lots = OrderLots();
      switch (_martingaleLotSizingType)
      {
         case MartingaleLotSizingNo:
            break;
         case MartingaleLotSizingMultiplicator:
            lots = _calculator.NormalizeLots(lots * _lotValue);
            break;
         case MartingaleLotSizingAdd:
            lots = _calculator.NormalizeLots(lots + _lotValue);
            break;
      }
      if (OrderType() == OP_BUY)
      {
         _longMoneyManagement.SetAmount(lots);
         return _longMoneyManagement;
      }
      _shortMoneyManagement.SetAmount(lots);
      return _shortMoneyManagement;
   }

   bool NeedAnotherPosition(OrderSide &side)
   {
      if (_order == -1)
         return false;
      if (!OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _order = -1;
         return false;
      }
      if (!_condition.IsPass(0, 0))
         return false;
      if (OrderType() == OP_BUY)
         side = BuySide;
      else
         side = SellSide;
      return true;
   }
};






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
// Order action (abstract) v2.0
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
};

#define AOrderAction_IMP
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









// Order handlers v1.0

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
      for (int i = 0; i < ArraySize(_orderHandlers); ++i)
      {
         delete _orderHandlers[i];
      }
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

// Entry position controller v1.0

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
   IMoneyManagementStrategy *_moneyManagement[];
   IEntryStrategy *_entryStrategy;
   string _algorithmId;
   string _alertMessage;
   OrderHandlers* _orderHandlers;
public:
   EntryPositionController(OrderSide side, ICondition* condition, ICondition* filterCondition, IEntryStrategy *entryStrategy,
      ICloseOnOppositeStrategy *closeOnOpposite, OrderHandlers* orderHandlers, Signaler* signaler, 
      string algorithmId, string alertMessage)
   {
      _orderHandlers = orderHandlers;
      _orderHandlers.AddRef();
      _algorithmId = algorithmId;
      _filterCondition = filterCondition;
      _filterCondition.AddRef();
      _entryStrategy = entryStrategy;
      _entryStrategy.AddRef();
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
      _orderHandlers.Release();
      _entryStrategy.Release();
      _closeOnOpposite.Release();
      _condition.Release();
      _filterCondition.Release();
      
      for (int i = 0; i < ArraySize(_moneyManagement); ++i)
      {
         delete _moneyManagement[i];
      }
   }

   void IncludeLog()
   {
      _includeLog = true;
   }

   void AddMoneyManagement(IMoneyManagementStrategy *moneyManagement)
   {
      int count = ArraySize(_moneyManagement);
      ArrayResize(_moneyManagement, count + 1);
      _moneyManagement[count] = moneyManagement;
   }

   bool DoEntry(int period, datetime date, string& logMessage)
   {
      bool conditionPassed = _condition.IsPass(period, date);
      if (_includeLog)
      {
         logMessage = _condition.GetLogMessage(period, date) + "; Condition passed: " + (conditionPassed ? "true" : "false");
         if (_filterCondition != NULL)
         {
            logMessage += ";" + _filterCondition.GetLogMessage(period, date);
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
      
      for (int i = 0; i < ArraySize(_moneyManagement); ++i)
      {
         int order = _entryStrategy.OpenPosition(period, _side, _moneyManagement[i], _algorithmId);
         if (order >= 0)
         {
            _orderHandlers.DoAction(order);
         }
      }
      _signaler.SendNotifications(_alertMessage);
      return true;
   }
};

#endif

// Trading controller v7.8

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
   EntryPositionController* _longPosition;
   EntryPositionController* _shortPosition;
public:
   TradingController(TradingCalculator *calculator, 
                     ENUM_TIMEFRAMES entryTimeframe, 
                     ENUM_TIMEFRAMES exitTimeframe, 
                     EntryPositionController* longPosition,
                     EntryPositionController* shortPosition,
                     ActionOnConditionLogic* actions,
                     Signaler *signaler, 
                     const string algorithmId = "")
   {
      _longPosition = longPosition;
      _shortPosition = shortPosition;
      _entryLogic = TradingModeOnBarClose;
      _exitLogic = TradingModeLive;
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
      delete _longPosition;
      delete _shortPosition;
      delete _actions;
      delete _entryStrategy;
      if (_exitLongCondition != NULL)
         _exitLongCondition.Release();
      if (_exitShortCondition != NULL)
         _exitShortCondition.Release();
      delete _calculator;
      delete _signaler;
   }

   void SetPrintLog(string logFile)
   {
      _logFile = FileOpen(logFile, FILE_WRITE | FILE_CSV, ",");
      _longPosition.IncludeLog();
      _shortPosition.IncludeLog();
   }
   void SetEntryLogic(TradingMode logicType) { _entryLogic = logicType; }
   void SetExitLogic(TradingMode logicType) { _exitLogic = logicType; }
   void SetExitLongCondition(ICondition *condition) { _exitLongCondition = condition; }
   void SetExitShortCondition(ICondition *condition) { _exitShortCondition = condition; }
   void SetEntryStrategy(IEntryStrategy *entryStrategy) { _entryStrategy = entryStrategy; }

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
            "Entry long: " + entryLongLog, 
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
         }
      }
      if (exitShortPassed)
      {
         if (_entryStrategy.Exit(SellSide) > 0)
         {
            _signaler.SendNotifications("Exit Sell");
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
      bool longOpened = _longPosition.DoEntry(entryTradePeriod, date, longLog);
      bool shortOpened = _shortPosition.DoEntry(entryTradePeriod, date, shortLog);
      return longOpened || shortOpened;
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
// Account statistics v1.4

input color equity_color = White; // Equity & profit color
input color color_text = Lime; // General text color
input color header_color = Yellow; // Headers color

class AccountStatistics
{
   InstrumentInfo *_symbol;
   int _textCorner;
   string _eaName;
   int _fontSize;
   string _fontName;
   string _headersFontName;
public:
   AccountStatistics(string eaName)
   {
      _fontSize = 10;
      _eaName = eaName;
      _textCorner = 1;
      _symbol = new InstrumentInfo(_Symbol);
      _headersFontName = "Impact";
      _fontName = "Cambria";

      string_window(eaName + "EA_NAME", 5, 5, 0); 
      ObjectSet(eaName + "EA_NAME", OBJPROP_CORNER, 3); 
      ObjectSetText(eaName + "EA_NAME", _eaName, _fontSize + 3, _headersFontName, header_color);
   }

   ~AccountStatistics()
   {
      ObjectsDeleteAll(ChartID(), _eaName);
      delete _symbol;
   }

   void Update()
   {
      OrdersIterator it();
      it.WhenTrade().WhenMagicNumber(magic_number);
      double profit = 0.0;
      double profitWithCommissions = 0.0;
      while (it.Next())
      {
         profit += it.GetProfit();
         profitWithCommissions += it.GetProfit() + OrderCommission() + OrderSwap();
      }
      string currentDate;
      MqlDateTime current_time;
      TimeToStruct(TimeCurrent(), current_time);
      switch (current_time.day_of_week)
      {
         case MONDAY:
            currentDate = "MONDAY";
            break;
         case TUESDAY:
            currentDate = "TUESDAY";
            break;
         case WEDNESDAY:
            currentDate = "WEDNESDAY";
            break;
         case THURSDAY:
            currentDate = "THURSDAY";
            break;
         case FRIDAY:
            currentDate = "FRIDAY";
            break;
         case SATURDAY:
            currentDate = "SATURDAY";
            break;
         case SUNDAY:
            currentDate = "SUNDAY";
            break;
      }
      string_window(_eaName + "currentDate", 5, 18, 0);
      ObjectSetText(_eaName + "currentDate", currentDate + ", " + DoubleToStr(Day(), 0) + " - " + DoubleToStr(Month(), 0) + " - " + DoubleToStr(Year(), 0), _fontSize+ 1 , _headersFontName, header_color);
      ObjectSet(_eaName + "currentDate", OBJPROP_CORNER, _textCorner);

      string_window(_eaName + "Balance", 5, 15 + 20, 0);
      ObjectSetText(_eaName + "Balance"," Balance: " + DoubleToStr(AccountBalance(), 2), _fontSize, _fontName, color_text);
      ObjectSet(_eaName + "Balance", OBJPROP_CORNER,_textCorner);  

      string_window(_eaName + "Equity", 5, 30 + 20, 0);
      ObjectSetText(_eaName + "Equity", "Equity: " + DoubleToStr(AccountEquity(),2), _fontSize, _fontName, equity_color); 
      ObjectSet(_eaName + "Equity", OBJPROP_CORNER, _textCorner);  
      
      string_window(_eaName + "Profit", 5, 45 + 20, 0); 
      ObjectSetText(_eaName + "Profit", "Profit: " + DoubleToStr(profitWithCommissions, 2) , _fontSize, _fontName, equity_color); 
      ObjectSet(_eaName + "Profit", OBJPROP_CORNER, _textCorner);
      
      string_window(_eaName + "Leverage", 5, 60 + 20, 0);
      ObjectSetText(_eaName + "Leverage", "Leverage: " + DoubleToStr(AccountLeverage(), 0), _fontSize, _fontName, color_text);
      ObjectSet(_eaName + "Leverage", OBJPROP_CORNER, _textCorner);

      string_window(_eaName + "Spread", 5,75 + 20, 0);
      ObjectSetText(_eaName + "Spread", "Spread: " + DoubleToStr(_symbol.GetSpread(), 1), _fontSize, _fontName, color_text);
      ObjectSet(_eaName + "Spread", OBJPROP_CORNER, _textCorner);
      
      double Range = (iHigh(_symbol.GetSymbol(), 1440, 0) - iLow(_symbol.GetSymbol(), 1440, 0)) / _symbol.GetPipSize();
      string_window(_eaName + "Range", 5, 90 + 20, 0);
      ObjectSetText(_eaName + "Range","Range: " + DoubleToStr(Range, 1) , _fontSize, _fontName, color_text); 
      ObjectSet(_eaName + "Range", OBJPROP_CORNER, _textCorner); 
      
      string_window(_eaName + "Price", 5, 125, 0);
      ObjectSetText(_eaName + "Price", "Bid Price: " + DoubleToStr(_symbol.GetBid(), _symbol.GetDigits()), _fontSize, _fontName, GetPriceColor());
      ObjectSet(_eaName + "Price", OBJPROP_CORNER, _textCorner); 
   }
private:
   color GetPriceColor()
   {
      return Volume[0] %2 == 0 ? color_text : equity_color;
   }

   int string_window(string n, int xoff, int yoff, int WindowToUse)
   {
      ObjectCreate(n, OBJ_LABEL, WindowToUse, 0, 0);
      ObjectSet(n, OBJPROP_CORNER, 1);
      ObjectSet(n, OBJPROP_XDISTANCE, xoff);
      ObjectSet(n, OBJPROP_YDISTANCE, yoff);
      ObjectSet(n, OBJPROP_BACK, true);
      return 0;
   }
};

TradingController *controllers[];
#ifdef SHOW_ACCOUNT_STAT
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



// Create trailing action v2.1

#ifndef CreateTrailingAction_IMP
#define CreateTrailingAction_IMP

// Automatically saves data about trailing as globals.
// You need to call RestoreActions() after creation of this object to restore tracking of old trades.
class CreateTrailingAction : public AOrderAction
{
   double _start;
   double _step;
   ActionOnConditionLogic* _actions;
public:
   CreateTrailingAction(double start, double step, ActionOnConditionLogic* actions)
   {
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

      string ticketIdStr = IntegerToString(_currentTicket);
      GlobalVariableSet("tr_" + ticketIdStr + "_stp", _step);
      GlobalVariableSet("tr_" + ticketIdStr + "_strt", _start);
      GlobalVariableSet("tr_" + ticketIdStr + "_d", distance);
      
      TrailingPipsAction* action = new TrailingPipsAction(order, distance, _step);
      ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, _start, 100000);
      _actions.AddActionOnCondition(action, condition);
      condition.Release();
      action.Release();

      order.Release();

      return true;
   }
};

#endif
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
   {
      _startTime = startTime;
      _endTime = endTime;
      _useWeekTime = false;
   }

   TradingTimeCondition(int startTime, int endTime, const DayOfWeek startDay,
      int weekStartTime, const DayOfWeek stopDay, int weekEndTime)
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
// Price moved from trade open condition v1.0




#ifndef PriceMovedFromTradeOpenCondition_IMP
#define PriceMovedFromTradeOpenCondition_IMP

class PriceMovedFromTradeOpenCondition : public ACondition
{
   MartingaleStepSizeType _stepUnit;
   double _step;
   TradingCalculator *_calculator;
public:
   PriceMovedFromTradeOpenCondition(string symbol, ENUM_TIMEFRAMES timeframe, MartingaleStepSizeType stepUnit, double step)
      :ACondition(symbol, timeframe)
   {
      _stepUnit = stepUnit;
      _step = step;
      _calculator = NULL;
   }

   ~PriceMovedFromTradeOpenCondition()
   {
      delete _calculator;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      string symbol = OrderSymbol();
      if (_calculator == NULL || _calculator.GetSymbol() != symbol)
      {
         delete _calculator;
         _calculator = TradingCalculator::Create(symbol);
      }

      if (OrderType() == OP_BUY)
         return NeedAnotherBuy();
      return NeedAnotherSell();
   }
private:
   bool NeedAnotherSell()
   {
      switch (_stepUnit)
      {
         case MartingaleStepSizePips:
            return (_calculator.GetBid() - OrderOpenPrice()) / _calculator.GetPipSize() > _step;
         case MartingaleStepSizePercent:
            {
               double openPrice = OrderOpenPrice();
               return (_calculator.GetBid() - openPrice) / openPrice > _step / 100.0;
            }
      }
      return false;
   }

   bool NeedAnotherBuy()
   {
      switch (_stepUnit)
      {
         case MartingaleStepSizePips:
            return (OrderOpenPrice() - _calculator.GetAsk()) / _calculator.GetPipSize() > _step;
         case MartingaleStepSizePercent:
            {
               double openPrice = OrderOpenPrice();
               return (openPrice - _calculator.GetAsk()) / openPrice > _step / 100.0;
            }
      }
      return false;
   }
};

#endif
// Stochastic conditions v2.0

#ifndef StochConditions_IMP
#define StochConditions_IMP


class StochKAboveDCondition : public ACondition
{
   int _kPeriod;
   int _dPeriod;
   int _slowingPeriod;
public:
   StochKAboveDCondition(const string symbol, ENUM_TIMEFRAMES timeframe, int kPeriod, int dPeriod, int slowingPeriod)
      :ACondition(symbol, timeframe)
   {
      _kPeriod = kPeriod;
      _dPeriod = dPeriod;
      _slowingPeriod = slowingPeriod;
   }

   bool IsPass(const int period, const datetime date)
   {
      double stochValue = iStochastic(_symbol, _timeframe, _kPeriod, _dPeriod, _slowingPeriod, MODE_SMA, 0, MODE_MAIN, period);
      double signalValue = iStochastic(_symbol, _timeframe, _kPeriod, _dPeriod, _slowingPeriod, MODE_SMA, 0, MODE_SIGNAL, period);
      return stochValue > signalValue;
   }
};

class StochKBelowDCondition : public ACondition
{
   int _kPeriod;
   int _dPeriod;
   int _slowingPeriod;
public:
   StochKBelowDCondition(const string symbol, ENUM_TIMEFRAMES timeframe, int kPeriod, int dPeriod, int slowingPeriod)
      :ACondition(symbol, timeframe)
   {
      _kPeriod = kPeriod;
      _dPeriod = dPeriod;
      _slowingPeriod = slowingPeriod;
   }

   bool IsPass(const int period, const datetime date)
   {
      double stochValue = iStochastic(_symbol, _timeframe, _kPeriod, _dPeriod, _slowingPeriod, MODE_SMA, 0, MODE_MAIN, period);
      double signalValue = iStochastic(_symbol, _timeframe, _kPeriod, _dPeriod, _slowingPeriod, MODE_SMA, 0, MODE_SIGNAL, period);
      return stochValue < signalValue;
   }
};

class StochKOversoldCondition : public ACondition
{
   int _kPeriod;
   int _dPeriod;
   int _slowingPeriod;
   double _oversold;
   ENUM_MA_METHOD _method;
   int _price;
public:
   StochKOversoldCondition(const string symbol, ENUM_TIMEFRAMES timeframe, int kPeriod, int dPeriod, int slowingPeriod, ENUM_MA_METHOD method, int price, double oversold)
      :ACondition(symbol, timeframe)
   {
      _method = method;
      _price = price;
      _kPeriod = kPeriod;
      _dPeriod = dPeriod;
      _slowingPeriod = slowingPeriod;
      _oversold = oversold;
   }

   bool IsPass(const int period, const datetime date)
   {
      double stochValue = iStochastic(_symbol, _timeframe, _kPeriod, _dPeriod, _slowingPeriod, _method, _price, MODE_MAIN, period);
      return stochValue < _oversold;
   }
};

class StochKOverboughtCondition : public ACondition
{
   int _kPeriod;
   int _dPeriod;
   int _slowingPeriod;
   double _overbought;
   ENUM_MA_METHOD _method;
   int _price;
public:
   StochKOverboughtCondition(const string symbol, ENUM_TIMEFRAMES timeframe, int kPeriod, int dPeriod, int slowingPeriod, ENUM_MA_METHOD method, int price, double overbought)
      :ACondition(symbol, timeframe)
   {
      _method = method;
      _price = price;
      _kPeriod = kPeriod;
      _dPeriod = dPeriod;
      _slowingPeriod = slowingPeriod;
      _overbought = overbought;
   }

   bool IsPass(const int period, const datetime date)
   {
      double stochValue = iStochastic(_symbol, _timeframe, _kPeriod, _dPeriod, _slowingPeriod, _method, _price, MODE_MAIN, period);
      return stochValue > _overbought;
   }
};
#endif

class ExitLongCondition : public ACondition
{
public:
   ExitLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period, const datetime date)
   {
      //TODO: implement
      return false;
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
      //TODO: implement
      return false;
   }
};

ICondition* CreateLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }

   AndCondition* condition = new AndCondition();
   condition.Add(new StochKOversoldCondition(symbol, timeframe, K_periods_1, D_periods_1, Slowing_1, method_1, price_1, os_1), false);
   condition.Add(new StochKOversoldCondition(symbol, tf2, K_periods_2, D_periods_2, Slowing_2, method_2, price_2, os_2), false);
   condition.Add(new StochKOversoldCondition(symbol, tf3, K_periods_3, D_periods_3, Slowing_3, method_3, price_3, os_3), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else 
      return (ICondition*) condition;
   #endif
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

   AndCondition* condition = new AndCondition();
   condition.Add(new StochKOverboughtCondition(symbol, timeframe, K_periods_1, D_periods_1, Slowing_1, method_1, price_1, ob_1), false);
   condition.Add(new StochKOverboughtCondition(symbol, tf2, K_periods_2, D_periods_2, Slowing_2, method_2, price_2, ob_2), false);
   condition.Add(new StochKOverboughtCondition(symbol, tf3, K_periods_3, D_periods_3, Slowing_3, method_3, price_3, ob_3), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else 
      return (ICondition*) condition;
   #endif
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

TradingController *CreateController(const string symbol, const ENUM_TIMEFRAMES timeframe, string &error)
{
   #ifdef TRADING_TIME_FEATURE
      ICondition* tradingTimeCondition = CreateTradingTimeCondition(start_time, stop_time, use_weekly_timing,
         week_start_day, week_start_time, week_stop_day, 
         week_stop_time, error);
      if (tradingTimeCondition == NULL)
         return NULL;
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

   Signaler* signaler = new Signaler(symbol, timeframe);
   signaler.SetMessagePrefix(symbol + "/" + signaler.GetTimeframeStr() + ": ");
   
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
   
   EntryPositionController* longPosition = new EntryPositionController(BuySide, longCondition, longFilterCondition, 
      entryStrategy, closeOnOpposite, orderHandlers, signaler, "", "Buy");
   EntryPositionController* shortPosition = new EntryPositionController(SellSide, shortCondition, shortFilterCondition,
      entryStrategy, closeOnOpposite, orderHandlers, signaler, "", "Sell");
   longCondition.Release();
   shortCondition.Release();
   longFilterCondition.Release();
   shortFilterCondition.Release();
      
   orderHandlers.Release();
   closeOnOpposite.Release();
   
   TradingController* controller = new TradingController(tradingCalculator, timeframe, timeframe, longPosition, shortPosition, actions, signaler);
   
   if (breakeven_type != StopLimitDoNotUse)
   {
      #ifndef USE_NET_BREAKEVEN
         MoveStopLossOnProfitOrderAction* orderAction = new MoveStopLossOnProfitOrderAction(breakeven_type, breakeven_value, breakeven_level, signaler, actions);
         orderAction.RestoreActions(_Symbol, magic_number);
         orderHandlers.AddOrderAction(orderAction);
         orderAction.Release();
      #endif
   }

   #ifdef STOP_LOSS_FEATURE
      switch (trailing_type)
      {
         case TrailingDontUse:
            break;
      #ifdef INDICATOR_BASED_TRAILING
         case TrailingIndicator:
            break;
      #endif
         case TrailingPips:
            {
               CreateTrailingAction* trailingAction = new CreateTrailingAction(trailing_start, trailing_step, actions);
               trailingAction.RestoreActions(_Symbol, magic_number);
               orderHandlers.AddOrderAction(trailingAction);
               trailingAction.Release();
            }
            break;
      }
   #endif

   // #ifdef MARTINGALE_FEATURE
   //    switch (martingale_type)
   //    {
   //       case MartingaleDoNotUse:
   //          controller.SetShortMartingaleStrategy(new NoMartingaleStrategy());
   //          controller.SetLongMartingaleStrategy(new NoMartingaleStrategy());
   //          break;
   //       case MartingaleOnLoss:
   //          {
   //             PriceMovedFromTradeOpenCondition* condition = new PriceMovedFromTradeOpenCondition(symbol, timeframe, martingale_step_type, martingale_step);
   //             controller.SetShortMartingaleStrategy(new ActiveMartingaleStrategy(tradingCalculator, martingale_lot_sizing_type, martingale_lot_value, condition));
   //             controller.SetLongMartingaleStrategy(new ActiveMartingaleStrategy(tradingCalculator, martingale_lot_sizing_type, martingale_lot_value, condition));
   //             condition.Release();
   //          }
   //          break;
   //    }
   // #endif

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
   if (mandatory_closing)
   {
      NotCondition* condition = new NotCondition(tradingTimeCondition);
      IAction* action = new CloseAllAction(magic_number, slippage_points);
      actions.AddActionOnCondition(action, condition);
      action.Release();
      condition.Release();
   }
   
   IMoneyManagementStrategy* longMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, true, 
      lots_type, lots_value, stop_loss_type, stop_loss_value, stop_loss_atr_multiplicator, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   IMoneyManagementStrategy* shortMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, false, 
      lots_type, lots_value, stop_loss_type, stop_loss_value, stop_loss_atr_multiplicator, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   longPosition.AddMoneyManagement(longMoneyManagement);
   shortPosition.AddMoneyManagement(shortMoneyManagement);

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
      controller.SetPrintLog(log_file);
   }

   return controller;
}

int OnInit()
{
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
   TradingController *controller = CreateController(_Symbol, trading_timeframe, error);
   if (controller == NULL)
   {
      Print(error);
      return INIT_FAILED;
   }
   int controllersCount = 0;
   ArrayResize(controllers, controllersCount + 1);
   controllers[controllersCount++] = controller;
   
   #ifdef SHOW_ACCOUNT_STAT
      stats = new AccountStatistics(EA_NAME);
   #endif
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
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
   int i_count = ArraySize(controllers);
   for (int i = 0; i < i_count; ++i)
   {
      controllers[i].DoTrading();
   }
   #ifdef SHOW_ACCOUNT_STAT
      stats.Update();
   #endif
}
