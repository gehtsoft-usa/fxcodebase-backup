// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=74700

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict

#define ACT_ON_SWITCH_CONDITION
#define REVERSABLE_LOGIC_FEATURE
#define STOP_LOSS_FEATURE
#define TAKE_PROFIT_FEATURE
#define USE_MARKET_ORDERS
#define TRADING_TIME_FEATURE
#define POSITION_CAP_FEATURE 

input int RsiOma_Period   = 14;
input int RsiOma_Price    = 0;
input int RsiOma_Mode     = MODE_LWMA;
input int MaPeriod        = 10;
input int MaType          = MODE_LWMA;
input int rsi_period_2 = 8; // Second RSI period
input int adx_period = 14; // ADX period
input int             shortPeriod      =  5;                // EW Short period
input int             longPeriod       = 35;                // EW Long period 
input ENUM_APPLIED_PRICE Price         = PRICE_MEDIAN;      // EW Price (original should be median)
input ENUM_MA_METHOD  MaMethod         = MODE_SMA;          // EW Average method to use (original should be SMA)

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
// Supported position size types v1.0

#ifndef PositionSizeType_IMP
#define PositionSizeType_IMP

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
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
   SLAtr // Set in ATR(value) * mult
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
   input TrailingType trailing_type = TrailingDontUse; // Trailing type
   input double trailing_step = 10; // Trailing step
   input double trailing_start = 0; // Min distance to order to activate the trailing
#else
   StopLossType stop_loss_type = SLDoNotUse; // Stop loss type
   double stop_loss_value = 10;
#endif
StopLimitType breakeven_type = StopLimitDoNotUse; // Trigger type for the breakeven
double breakeven_value = 10; // Trigger for the breakeven
double breakeven_level = 0; // Breakeven target
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
#ifdef TAKE_PROFIT_FEATURE
   input string TakeProfitSection            = ""; // == Take Profit ==
   TakeProfitType take_profit_type = TPPips; // Take profit type
   input double take_profit_value = 15; // Take profit value 1
   input double take_profit_value_2 = 30; // Take profit value 2
   double take_profit_atr_multiplicator = 1; // Take profit multiplicator (for ATR TP)
#else
   TakeProfitType take_profit_type = TPDoNotUse;
   double take_profit_value = 10;
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
input bool PrintLog = false; // Print decisions into the log (On bar close only!)

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
// Act on switch condition v4.1

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
      if (time != _currentDate)
      {
         _last = _current;
         _currentDate = time;
      }
      _current = _condition.IsPass(period, date);
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

// Order side enum v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide, // Buy/long
   SellSide // Sell/short
};

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
// Trade calculator v2.2
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
   
   // NOTE: Calculate TakeProfit
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
         case PositionSizeRisk:
         {
            double affordableLoss = AccountEquity() * lotsValue / 100.0;
            double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
            double tickSize = _symbol.GetTickSize();
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
               return 0;
            return _symbol.NormalizeLots(affordableLoss / possibleLoss);
         }
         case PositionSizeRiskCurrency:
         {
            double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
            double tickSize = _symbol.GetTickSize();
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
               return 0;
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
// Action on condition v3.0




#ifndef ActionOnConditionController_IMP
#define ActionOnConditionController_IMP

class ActionOnConditionController
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



#ifndef ActionOnConditionLogic_IMP
#define ActionOnConditionLogic_IMP

class ActionOnConditionLogic
{
   ActionOnConditionController* _controllers[];
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
// Move net stop loss action v 2.0

// Trading commands v.2.13
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
      OrdersIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenOrder();
      while (it1.Next())
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

// Default lots provider v1.0

// Lots provider interface v1.0

#ifndef ILotsProvider_IMP
#define ILotsProvider_IMP
class ILotsProvider
{
public:
   virtual double GetLots(double stopLoss) = 0;
};
#endif



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

   virtual double GetLots(double stopLoss)
   {
      return _calculator.GetLots(_lotsType, _lots, 0.0);
   }
};
#endif
// Money management strategy v1.0

// Money management strategy interface v1.0

#ifndef IMoneyManagementStrategy_IMP
#define IMoneyManagementStrategy_IMP
interface IMoneyManagementStrategy
{
public:
   virtual void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit) = 0;
};
#endif
// Stop Loss and amount strategy interface v1.0

#ifndef IStopLossAndAmountStrategy_IMP
#define IStopLossAndAmountStrategy_IMP

class IStopLossAndAmountStrategy
{
public:
   virtual void GetStopLossAndAmount(const int period, const double entryPrice, double &amount, double &stopLoss) = 0;
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
   IStopLossAndAmountStrategy* _stopLossAndAmount;
   ITakeProfitStrategy* _takeProfit;

   MoneyManagementStrategy(IStopLossAndAmountStrategy* stopLossAndAmount, ITakeProfitStrategy* takeProfit)
   {
      _stopLossAndAmount = stopLossAndAmount;
      _takeProfit = takeProfit;
   }

   ~MoneyManagementStrategy()
   {
      delete _stopLossAndAmount;
      delete _takeProfit;
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      _stopLossAndAmount.GetStopLossAndAmount(period, entryPrice, amount, stopLoss);
      _takeProfit.GetTakeProfit(period, entryPrice, stopLoss, amount, takeProfit);
   }
};

#endif
// Risk to reward take profit strategy v1.0



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
         takeProfit = entryPrice + (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = entryPrice - (entryPrice - stopLoss) * _takeProfit / 100;
   }
};
#endif
// Stop loss and amount strategy for position size risk v1.1




#ifndef PositionSizeRiskStopLossAndAmountStrategy_IMP
#define PositionSizeRiskStopLossAndAmountStrategy_IMP

class PositionSizeRiskStopLossAndAmountStrategy : public IStopLossAndAmountStrategy
{
   double _lots;
   TradingCalculator *_calculator;
   StopLimitType _stopLossType;
   double _stopLoss;
   bool _isBuy;
public:
   PositionSizeRiskStopLossAndAmountStrategy(TradingCalculator *calculator, double lots,
      StopLimitType stopLossType, double stopLoss, bool isBuy)
   {
      _calculator = calculator;
      _lots = lots;
      _stopLossType = stopLossType;
      _stopLoss = stopLoss;
      _isBuy = isBuy;
   }
   
   void GetStopLossAndAmount(const int period, const double entryPrice, double &amount, double &stopLoss)
   {
      stopLoss = _calculator.CalculateStopLoss(_isBuy, _stopLoss, _stopLossType, 0.0, entryPrice);
      if (_isBuy)
      {
         stopLoss = MathMin(Low[1], stopLoss);
      }
      else
      {
         stopLoss = MathMax(High[1], stopLoss);
      }
      amount = _calculator.GetLots(PositionSizeRisk, _lots, _isBuy ? (entryPrice - stopLoss) : (stopLoss - entryPrice));
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
      // if (_calculator.GetMinLots() == amount)
      // {
      //    takeProfit = 0;   
      //    return;
      // }
      takeProfit = _calculator.CalculateTakeProfit(_isBuy, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

#endif

// ATR take profit strategy v1.0
// Default stop loss and amount strategy v1.0

#ifndef DefaultStopLossAndAmountStrategy_IMP
#define DefaultStopLossAndAmountStrategy_IMP

class DefaultStopLossAndAmountStrategy : public IStopLossAndAmountStrategy
{
   TradingCalculator *_calculator;
   StopLimitType _stopLossType;
   double _stopLoss;
   bool _isBuy;
   ILotsProvider* _lotsProvider;
public:
   DefaultStopLossAndAmountStrategy(TradingCalculator *calculator, ILotsProvider* lotsProvider,
      StopLimitType stopLossType, double stopLoss, bool isBuy)
   {
      _lotsProvider = lotsProvider;
      _isBuy = isBuy;
      _calculator = calculator;
      _stopLossType = stopLossType;
      _stopLoss = stopLoss;
   }

   ~DefaultStopLossAndAmountStrategy()
   {
      delete _lotsProvider;
   }
   
   void GetStopLossAndAmount(const int period, const double entryPrice, double &amount, double &stopLoss)
   {
      amount = _lotsProvider.GetLots(0.0);
      stopLoss = _calculator.CalculateStopLoss(_isBuy, _stopLoss, _stopLossType, amount, entryPrice);
      if (_isBuy)
      {
         stopLoss = MathMin(Low[1], stopLoss);
      }
      else
      {
         stopLoss = MathMax(High[1], stopLoss);
      }
   }
};

#endif

// Close on opposite v.1.1


interface ICloseOnOppositeStrategy
{
public:
   virtual void DoClose(const OrderSide side) = 0;
};

class DontCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
public:
   void DoClose(const OrderSide side)
   {
      // do nothing
   }
};

class DoCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
   int _magicNumber;
   int _slippage;
public:
   DoCloseOnOppositeStrategy(const int slippage, const int magicNumber)
   {
      _magicNumber = magicNumber;
      _slippage = slippage;
   }

   void DoClose(const OrderSide side)
   {
      OrdersIterator toClose();
      toClose.WhenSide(side).WhenMagicNumber(_magicNumber).WhenTrade();
      TradingCommands::CloseTrades(toClose, _slippage);
   }
};
// Position cap v.1.1

interface IPositionCapStrategy
{
public:
   virtual bool IsLimitHit() = 0;
};

class PositionCapStrategy : public IPositionCapStrategy
{
   int _magicNumber;
   int _maxSidePositions;
   int _totalPositions;
   string _symbol;
   OrderSide _side;
public:
   PositionCapStrategy(const OrderSide side, const int magicNumber, const int maxSidePositions, const int totalPositions,
      const string symbol = "")
   {
      _symbol = symbol;
      _side = side;
      _magicNumber = magicNumber;
      _maxSidePositions = maxSidePositions;
      _totalPositions = totalPositions;
   }

   bool IsLimitHit()
   {
      OrdersIterator sideSpecificIterator();
      sideSpecificIterator.WhenMagicNumber(_magicNumber).WhenTrade().WhenSide(_side);
      if (_symbol != "")
         sideSpecificIterator.WhenSymbol(_symbol);
      int side_positions = sideSpecificIterator.Count();
      if (side_positions >= _maxSidePositions)
         return true;

      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber).WhenTrade();
      if (_symbol != "")
         it.WhenSymbol(_symbol);
      int positions = it.Count();
      return positions >= _totalPositions;
   }
};

class NoPositionCapStrategy : public IPositionCapStrategy
{
public:
   bool IsLimitHit()
   {
      return false;
   }
};
// Order builder v2.1





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
   ActionOnConditionLogic* _actions;
public:
   OrderBuilder(ActionOnConditionLogic* actions)
   {
      _actions = actions;
      _ecnBroker = false;
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
   
   int Execute(string &errorMessage)
   {
      InstrumentInfo instrument(_instrument);
      double rate = instrument.RoundRate(_rate);
      double sl = instrument.RoundRate(_stopLoss);
      double tp = instrument.RoundRate(_takeProfit);
      int orderType;
      if (_orderSide == BuySide)
         orderType = rate > instrument.GetAsk() ? OP_BUYSTOP : OP_BUYLIMIT;
      else
         orderType = rate < instrument.GetBid() ? OP_SELLSTOP : OP_SELLLIMIT;
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
// Market order builder v 2.2
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
public:
   MarketOrderBuilder(ActionOnConditionLogic* actions)
   {
      _actions = actions;
      _ecnBroker = false;
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
};

#endif
// Entry strategy v4.0

interface IEntryStrategy
{
public:
   virtual int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment, bool ecnBroker) = 0;

   virtual int Exit(const OrderSide side) = 0;
};

class MarketEntryStrategy : public IEntryStrategy
{
   string _symbol;
   int _magicNumber;
   int _slippagePoints;
   ActionOnConditionLogic* _actions;
public:
   MarketEntryStrategy(const string symbol, 
      const int magicMumber, 
      const int slippagePoints,
      ActionOnConditionLogic* actions)
   {
      _actions = actions;
      _magicNumber = magicMumber;
      _slippagePoints = slippagePoints;
      _symbol = symbol;
   }

   int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment, bool ecnBroker)
   {
      double entryPrice = side == BuySide ? InstrumentInfo::GetAsk(_symbol) : InstrumentInfo::GetBid(_symbol);
      double amount;
      double takeProfit;
      double stopLoss;
      moneyManagement.Get(period, entryPrice, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return -1;
      string error = "";
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder(_actions);
      int order = orderBuilder
         .SetSide(side)
         .SetECNBroker(ecnBroker)
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
// Move stop loss on profit order action v2.0
#ifndef MoveStopLossOnProfitOrderAction_IMP
#define MoveStopLossOnProfitOrderAction_IMP

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
//Move to breakeven action v2.0

#ifndef MoveToBreakevenAction_IMP
#define MoveToBreakevenAction_IMP

class MoveToBreakevenAction : public AAction
{
   Signaler* _signaler;
   double _trigger;
   double _target;
   InstrumentInfo *_instrument;
   IOrder* _order;
   string _name;
   double _refLots;
public:
   MoveToBreakevenAction(double trigger, double target, string name, IOrder* order, Signaler *signaler, double refLots = 0)
   {
      _signaler = signaler;
      _trigger = trigger;
      _target = target;
      _name = name;

      _order = order;
      _order.AddRef();
      _order.Select();
      string symbol = OrderSymbol();
      _instrument = new InstrumentInfo(symbol);
      _refLots = refLots;
   }

   ~MoveToBreakevenAction()
   {
      delete _instrument;
      _order.Release();
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!_order.Select() || OrderCloseTime() != 0 || (_refLots != 0 && _instrument.CompareLots(OrderLots(), _refLots) != 0))
      {
         return false;
      }
      int ticket = OrderTicket();
      string error;
      if (!TradingCommands::MoveSL(ticket, _target, error))
      {
         Print(error);
         return false;
      }
      if (_signaler != NULL)
      {
         _signaler.SendNotifications(GetNamePrefix() + "Trade " + IntegerToString(ticket) + " has reached " 
            + DoubleToString(_trigger, _instrument.GetDigits()) + ". Stop loss moved to " 
            + DoubleToString(_target, _instrument.GetDigits()));
      }
      return true;
   }
private:
   string GetNamePrefix()
   {
      if (_name == "")
         return "";
      return _name + ". ";
   }
};

#endif

class SetTakeProfitAction : public AAction
{
   double _takeProfit;
   IOrder* _order;
public:
   SetTakeProfitAction(double takeProfit, IOrder* order)
   {
      _takeProfit = takeProfit;
      _order = order;
      _order.AddRef();
   }

   ~SetTakeProfitAction()
   {
      _order.Release();
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!_order.Select() || OrderCloseTime() != 0)
         return true;

      int ticket = OrderTicket();
      string errorMessage;
      bool success = TradingCommands::MoveTP(ticket, _takeProfit, errorMessage);
      return success && (errorMessage == NULL || errorMessage == "");
   }
};

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

class CustomMoveStopLossOnProfitOrderAction : public AOrderAction
{
   TradingCalculator *_calculator;
   ActionOnConditionLogic* _actions;
public:
   CustomMoveStopLossOnProfitOrderAction(ActionOnConditionLogic* actions)
   {
      _calculator = NULL;
      _actions = actions;
   }

   ~CustomMoveStopLossOnProfitOrderAction()
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
      CreateBreakeven(_currentTicket);
      return true;
   }
private:
   void CreateBreakeven(const int ticketId)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
      {
         return;
      }

      double lots = _calculator.NormalizeLots(OrderLots() / 3);
      // if (lots == OrderLots()) { return; }

      int isBuy = TradingCalculator::IsBuyOrder();
      double firstTPLevel = _calculator.CalculateTakeProfit(isBuy, take_profit_value, StopLimitPips, OrderLots(), OrderOpenPrice());
      double secondTPLevel = _calculator.CalculateTakeProfit(isBuy, take_profit_value_2, StopLimitPips, OrderLots(), OrderOpenPrice());

      IOrder *order = new OrderByMagicNumber(magic_number);
      HitProfitCondition* firstProfitCondition = new HitProfitCondition();
      firstProfitCondition.Set(order, firstTPLevel);
      HitProfitCondition* secondProfitCondition = new HitProfitCondition();
      secondProfitCondition.Set(order, secondTPLevel);
      if (lots * 2 >= OrderLots())
      {
         double firstSLLevel = _calculator.CalculateStopLoss(isBuy, 0, StopLimitPips, OrderLots(), OrderOpenPrice());

         IAction* moveSLAction = new MoveToBreakevenAction(firstTPLevel, firstSLLevel, "", order, NULL);
         _actions.AddActionOnCondition(moveSLAction, firstProfitCondition);
         moveSLAction.Release();

         IAction* closeThird = new PartialCloseOrderAction(order, lots, slippage_points);
         _actions.AddActionOnCondition(closeThird, firstProfitCondition);
         _actions.AddActionOnCondition(closeThird, secondProfitCondition);
         closeThird.Release();

         IAction* addTrailing = new TrailingPipsAction(order, take_profit_value_2 - take_profit_value, 0.1);
         _actions.AddActionOnCondition(addTrailing, secondProfitCondition);
         addTrailing.Release();
      }
      if (lots >= OrderLots())
      {
         double firstSLLevel = _calculator.CalculateStopLoss(isBuy, 5, StopLimitPips, OrderLots(), OrderOpenPrice());
         lots = _calculator.NormalizeLots(OrderLots() / 2);

         IAction* moveSLAction = new MoveToBreakevenAction(firstTPLevel, firstSLLevel, "", order, NULL);
         _actions.AddActionOnCondition(moveSLAction, firstProfitCondition);
         moveSLAction.Release();

         IAction* moveTPAction = new SetTakeProfitAction(secondTPLevel, order);
         _actions.AddActionOnCondition(moveTPAction, secondProfitCondition);
         moveTPAction.Release();

         IAction* closeHalf = new PartialCloseOrderAction(order, lots, slippage_points);
         _actions.AddActionOnCondition(closeHalf, firstProfitCondition);
         closeHalf.Release();
      }
      order.Release();
      firstProfitCondition.Release();
      secondProfitCondition.Release();
   }
};
#endif
// Trading controller v7.5




class TradingController
{
   ENUM_TIMEFRAMES _entryTimeframe;
   ENUM_TIMEFRAMES _exitTimeframe;
   datetime _lastActionTime;
   double _lastLot;
   ActionOnConditionLogic* actions;
   Signaler *_signaler;
   datetime _lastLimitPositionMessage;
   datetime _lastEntryTime;
   datetime _lastExitTime;
   TradingCalculator *_calculator;
   ICondition* _longCondition;
   ICondition* _shortCondition;
   ICondition* _longFilterCondition;
   ICondition* _shortFilterCondition;
   ICondition* _exitLongCondition;
   ICondition* _exitShortCondition;
   IMoneyManagementStrategy *_longMoneyManagement[];
   IMoneyManagementStrategy *_shortMoneyManagement[];
   ICloseOnOppositeStrategy *_closeOnOpposite;
   #ifdef POSITION_CAP_FEATURE
   IPositionCapStrategy *_longPositionCap;
   IPositionCapStrategy *_shortPositionCap;
   #endif
   IEntryStrategy *_entryStrategy;
   string _algorithmId;
   ActionOnConditionLogic* _actions;
   AOrderAction* _orderHandlers[];
   TradingMode _entryLogic;
   TradingMode _exitLogic;
   bool _ecnBroker;
   bool _printLog;
public:
   TradingController(TradingCalculator *calculator, 
                     ENUM_TIMEFRAMES entryTimeframe, 
                     ENUM_TIMEFRAMES exitTimeframe, 
                     Signaler *signaler, 
                     const string algorithmId = "")
   {
      _lastLimitPositionMessage = 0;
      _ecnBroker = false;
      _entryLogic = TradingModeOnBarClose;
      _exitLogic = TradingModeLive;
      _actions = NULL;
      _algorithmId = algorithmId;
      #ifdef POSITION_CAP_FEATURE
      _longPositionCap = NULL;
      _shortPositionCap = NULL;
      #endif
      _closeOnOpposite = NULL;
      _longCondition = NULL;
      _shortCondition = NULL;
      _longFilterCondition = NULL;
      _shortFilterCondition = NULL;
      _calculator = calculator;
      _signaler = signaler;
      _entryTimeframe = entryTimeframe;
      _exitTimeframe = exitTimeframe;
      _lastLot = lots_value;
      _exitLongCondition = NULL;
      _exitShortCondition = NULL;
      _printLog = false;
   }

   ~TradingController()
   {
      for (int i = 0; i < ArraySize(_orderHandlers); ++i)
      {
         delete _orderHandlers[i];
      }
      delete _actions;
      delete _entryStrategy;
      #ifdef POSITION_CAP_FEATURE
      delete _longPositionCap;
      delete _shortPositionCap;
      #endif
      delete _closeOnOpposite;
      for (int i = 0; i < ArraySize(_longMoneyManagement); ++i)
      {
         delete _longMoneyManagement[i];
      }
      for (int i = 0; i < ArraySize(_shortMoneyManagement); ++i)
      {
         delete _shortMoneyManagement[i];
      }
      if (_exitLongCondition != NULL)
         _exitLongCondition.Release();
      if (_exitShortCondition != NULL)
         _exitShortCondition.Release();
      delete _calculator;
      delete _signaler;
      if (_longCondition != NULL)
         _longCondition.Release();
      if (_shortCondition != NULL)
         _shortCondition.Release();
      if (_longFilterCondition != NULL)
         _longFilterCondition.Release();
      if (_shortFilterCondition != NULL)
         _shortFilterCondition.Release();
   }

   void AddOrderAction(AOrderAction* orderAction)
   {
      int count = ArraySize(_orderHandlers);
      ArrayResize(_orderHandlers, count + 1);
      _orderHandlers[count] = orderAction;
      orderAction.AddRef();
   }
   void SetECNBroker(bool ecn) { _ecnBroker = ecn; }
   void SetPrintLog(bool print) { _printLog = print; }
   void SetEntryLogic(TradingMode logicType) { _entryLogic = logicType; }
   void SetExitLogic(TradingMode logicType) { _exitLogic = logicType; }
   void SetActions(ActionOnConditionLogic* __actions) { _actions = __actions; }
   void SetLongCondition(ICondition *condition) { _longCondition = condition; }
   void SetShortCondition(ICondition *condition) { _shortCondition = condition; }
   void SetLongFilterCondition(ICondition *condition) { _longFilterCondition = condition; }
   void SetShortFilterCondition(ICondition *condition) { _shortFilterCondition = condition; }
   void SetExitLongCondition(ICondition *condition) { _exitLongCondition = condition; }
   void SetExitShortCondition(ICondition *condition) { _exitShortCondition = condition; }
   void AddLongMoneyManagement(IMoneyManagementStrategy *moneyManagement)
   {
      int count = ArraySize(_longMoneyManagement);
      ArrayResize(_longMoneyManagement, count + 1);
      _longMoneyManagement[count] = moneyManagement;
   }
   void AddShortMoneyManagement(IMoneyManagementStrategy *moneyManagement)
   {
      int count = ArraySize(_shortMoneyManagement);
      ArrayResize(_shortMoneyManagement, count + 1);
      _shortMoneyManagement[count] = moneyManagement;
   }
   void SetCloseOnOpposite(ICloseOnOppositeStrategy *closeOnOpposite) { _closeOnOpposite = closeOnOpposite; }
   #ifdef POSITION_CAP_FEATURE
      void SetLongPositionCap(IPositionCapStrategy *positionCap) { _longPositionCap = positionCap; }
      void SetShortPositionCap(IPositionCapStrategy *positionCap) { _shortPositionCap = positionCap; }
   #endif
   void SetEntryStrategy(IEntryStrategy *entryStrategy) { _entryStrategy = entryStrategy; }

   void DoTrading()
   {
      int entryTradePeriod = _entryLogic == TradingModeLive ? 0 : 1;
      datetime entryTime = iTime(_calculator.GetSymbol(), _entryTimeframe, entryTradePeriod);
      _actions.DoLogic(entryTradePeriod, entryTime);
      if (EntryAllowed(entryTime))
      {
         if (DoEntryLogic(entryTradePeriod, entryTime))
            _lastActionTime = entryTime;
            _lastEntryTime = entryTime;
      }

      int exitTradePeriod = _exitLogic == TradingModeLive ? 0 : 1;
      datetime exitTime = iTime(_calculator.GetSymbol(), _exitTimeframe, exitTradePeriod);
      if (ExitAllowed(exitTime))
      {
         DoExitLogic(exitTradePeriod, exitTime);
         _lastExitTime = exitTime;
      }
   }
private:
   bool ExitAllowed(datetime exitTime)
   {
      return _exitLogic != TradingModeOnBarClose || _lastExitTime != exitTime;
   }

   void DoExitLogic(int exitTradePeriod, datetime date)
   {
      if (_printLog && _exitLogic == TradingModeOnBarClose)
      {
         string logMessage = _exitLongCondition.GetLogMessage(exitTradePeriod, date);
         Print("Long exit: " + logMessage);
         logMessage = _exitShortCondition.GetLogMessage(exitTradePeriod, date);
         Print("Short exit: " + logMessage);
      }
      if (_exitLongCondition.IsPass(exitTradePeriod, date))
      {
         if (_entryStrategy.Exit(BuySide) > 0)
            _signaler.SendNotifications("Exit Buy");
      }
      if (_exitShortCondition.IsPass(exitTradePeriod, date))
      {
         if (_entryStrategy.Exit(SellSide) > 0)
            _signaler.SendNotifications("Exit Sell");
      }
   }

   bool EntryAllowed(datetime entryTime)
   {
      if (_entryLogic == TradingModeOnBarClose)
         return _lastEntryTime != entryTime;
      return _lastActionTime != entryTime;
   }

   bool DoEntryLongLogic(int period, datetime date)
   {
      if (_printLog && _entryLogic == TradingModeOnBarClose)
      {
         string logMessage = _longCondition.GetLogMessage(period, date);
         Print("Long entry: " + logMessage);
      }
      if (!_longCondition.IsPass(period, date))
      {
         return false;
      }
      if (_longFilterCondition != NULL && !_longFilterCondition.IsPass(period, date))
      {
         return false;
      }
      _closeOnOpposite.DoClose(SellSide);
      #ifdef POSITION_CAP_FEATURE
         if (_longPositionCap.IsLimitHit() && _lastLimitPositionMessage != date)
         {
            _lastLimitPositionMessage = date;
            _signaler.SendNotifications("Positions limit has been reached");
            return false;
         }
      #endif
      for (int i = 0; i < ArraySize(_longMoneyManagement); ++i)
      {
         int order = _entryStrategy.OpenPosition(period, BuySide, _longMoneyManagement[i], _algorithmId, _ecnBroker);
         if (order >= 0)
         {
            for (int orderHandlerIndex = 0; orderHandlerIndex < ArraySize(_orderHandlers); ++orderHandlerIndex)
            {
               _orderHandlers[orderHandlerIndex].DoAction(order);
            }
         }
      }
      _signaler.SendNotifications("Buy");
      return true;
   }

   bool DoEntryShortLogic(int period, datetime date)
   {
      if (_printLog && _entryLogic == TradingModeOnBarClose)
      {
         string logMessage = _shortCondition.GetLogMessage(period, date);
         Print("Short entry: " + logMessage);
      }
      if (!_shortCondition.IsPass(period, date))
      {
         return false;
      }
      if (_shortFilterCondition != NULL && !_shortFilterCondition.IsPass(period, date))
      {
         return false;
      }
      _closeOnOpposite.DoClose(BuySide);
      #ifdef POSITION_CAP_FEATURE
         if (_shortPositionCap.IsLimitHit() && _lastLimitPositionMessage != date)
         {
            _lastLimitPositionMessage = date;
            _signaler.SendNotifications("Positions limit has been reached");
            return false;
         }
      #endif
      for (int i = 0; i < ArraySize(_shortMoneyManagement); ++i)
      {
         int order = _entryStrategy.OpenPosition(period, SellSide, _shortMoneyManagement[i], _algorithmId, _ecnBroker);
         if (order >= 0)
         {
            for (int orderHandlerIndex = 0; orderHandlerIndex < ArraySize(_orderHandlers); ++orderHandlerIndex)
            {
               _orderHandlers[orderHandlerIndex].DoAction(order);
            }
         }
      }
      _signaler.SendNotifications("Sell");
      return true;
   }

   bool DoEntryLogic(int entryTradePeriod, datetime date)
   {
      bool longOpened = DoEntryLongLogic(entryTradePeriod, date);
      bool shortOpened = DoEntryShortLogic(entryTradePeriod, date);
      return longOpened || shortOpened;
   }
};
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

TradingController *controllers[];
// Create trailing action v2.0

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
// Trailing action v3.0






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
         while (_instrument.RoundRate(newStop - _step) < _instrument.RoundRate(closePrice - _distance))
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



#ifndef CreateTrailingAction_IMP
#define CreateTrailingAction_IMP

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

      TrailingPipsAction* action = new TrailingPipsAction(order, distance, _step);
      ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, 0, _start);
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


// Trading time condition v3.1





#ifndef TradingTimeCondition_IMP
#define TradingTimeCondition_IMP

int ParseTime(const string time, string &error)
{
   int hours;
   int minutes;
   int seconds;
   if (StringFind(time, ":") == -1)
   {
      //hh:mm:ss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
   }
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      hours = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      seconds = time_parsed % 100;
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
// And condition v4.0

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
      return messages;
   }
};
#endif
// Or condition v4.0



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
      return messages;
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

class RSI1LongCondition : public ACondition
{
public:
   RSI1LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      double ma0 = iCustom(_symbol, _timeframe, "RSI_MA", "Current time frame", RsiOma_Period, RsiOma_Price, RsiOma_Mode, MaPeriod, MaType, 3, period);
      double rsi0 = iCustom(_symbol, _timeframe, "RSI_MA", "Current time frame", RsiOma_Period, RsiOma_Price, RsiOma_Mode, MaPeriod, MaType, 0, period);
      double ma1 = iCustom(_symbol, _timeframe, "RSI_MA", "Current time frame", RsiOma_Period, RsiOma_Price, RsiOma_Mode, MaPeriod, MaType, 3, period + 1);
      double rsi1 = iCustom(_symbol, _timeframe, "RSI_MA", "Current time frame", RsiOma_Period, RsiOma_Price, RsiOma_Mode, MaPeriod, MaType, 0, period + 1);
      return ((ma0 >= rsi0 && ma1 < rsi1) 
         || (ma0 <= rsi0 && ma1 > rsi1))
         && rsi0 <= 30;
   }
};
class RSI2LongCondition : public ACondition
{
public:
   RSI2LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      double rsi = iRSI(_symbol, _timeframe, rsi_period_2, PRICE_CLOSE, period);
      return rsi >= 45 && rsi <= 55;
   }
};
class ADXLongCondition : public ACondition
{
public:
   ADXLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      double adxp = iADX(_symbol, _timeframe, adx_period, PRICE_CLOSE, MODE_PLUSDI, period);
      double adxm = iADX(_symbol, _timeframe, adx_period, PRICE_CLOSE, MODE_MINUSDI, period);
      return adxp > adxm;
   }
};
class EOWLongCondition : public ACondition
{
public:
   EOWLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return iCustom(_symbol, _timeframe, "Elliot oscillator - waves", _timeframe, shortPeriod, longPeriod, Price, MaMethod, 1, period) != EMPTY_VALUE;
   }
};

class RSI1ShortCondition : public ACondition
{
public:
   RSI1ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      double ma0 = iCustom(_symbol, _timeframe, "RSI_MA", "Current time frame", RsiOma_Period, RsiOma_Price, RsiOma_Mode, MaPeriod, MaType, 3, period);
      double rsi0 = iCustom(_symbol, _timeframe, "RSI_MA", "Current time frame", RsiOma_Period, RsiOma_Price, RsiOma_Mode, MaPeriod, MaType, 0, period);
      double ma1 = iCustom(_symbol, _timeframe, "RSI_MA", "Current time frame", RsiOma_Period, RsiOma_Price, RsiOma_Mode, MaPeriod, MaType, 3, period + 1);
      double rsi1 = iCustom(_symbol, _timeframe, "RSI_MA", "Current time frame", RsiOma_Period, RsiOma_Price, RsiOma_Mode, MaPeriod, MaType, 0, period + 1);
      return ((ma0 >= rsi0 && ma1 < rsi1) 
         || (ma0 <= rsi0 && ma1 > rsi1))
         && rsi0 >= 70;
   }
};
class RSI2ShortCondition : public ACondition
{
public:
   RSI2ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      double rsi = iRSI(_symbol, _timeframe, rsi_period_2, PRICE_CLOSE, period);
      return rsi >= 45 && rsi <= 55;
   }
};
class ADXShortCondition : public ACondition
{
public:
   ADXShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      double adxp = iADX(_symbol, _timeframe, adx_period, PRICE_CLOSE, MODE_PLUSDI, period);
      double adxm = iADX(_symbol, _timeframe, adx_period, PRICE_CLOSE, MODE_MINUSDI, period);
      return adxp < adxm;
   }
};
class EOWShortCondition : public ACondition
{
public:
   EOWShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      return iCustom(_symbol, _timeframe, "Elliot oscillator - waves", _timeframe, shortPeriod, longPeriod, Price, MaMethod, 0, period) != EMPTY_VALUE;
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
   condition.Add(new RSI1LongCondition(symbol, timeframe), false);
   condition.Add(new RSI2LongCondition(symbol, timeframe), false);
   condition.Add(new ADXLongCondition(symbol, timeframe), false);
   condition.Add(new EOWLongCondition(symbol, timeframe), false);
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
   return new NoCondition();
}

ICondition* CreateShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == LongSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }

   AndCondition* condition = new AndCondition();
   condition.Add(new RSI1ShortCondition(symbol, timeframe), false);
   condition.Add(new RSI2ShortCondition(symbol, timeframe), false);
   condition.Add(new ADXShortCondition(symbol, timeframe), false);
   condition.Add(new EOWShortCondition(symbol, timeframe), false);
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
   return new NoCondition();
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

MoneyManagementStrategy* CreateMoneyManagementStrategy(TradingCalculator* tradingCalculator, string symbol,
   ENUM_TIMEFRAMES timeframe, bool isBuy)
{
   ILotsProvider* lots = NULL;
   switch (lots_type)
   {
      case PositionSizeRisk:
      case PositionSizeRiskCurrency:
         break;
      default:
         lots = new DefaultLotsProvider(tradingCalculator, lots_type, lots_value);
         break;
   }
   IStopLossAndAmountStrategy* sl = NULL;
   switch (stop_loss_type)
   {
      case SLDoNotUse:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitDoNotUse, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitDoNotUse, stop_loss_value, isBuy);
         }
         break;
      case SLPercent:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitPercent, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitPercent, stop_loss_value, isBuy);
         }
         break;
      case SLPips:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitPips, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitPips, stop_loss_value, isBuy);
         }
         break;
      case SLDollar:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitDollar, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitDollar, stop_loss_value, isBuy);
         }
         break;
      case SLAbsolute:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitAbsolute, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitAbsolute, stop_loss_value, isBuy);
         }
         break;
   }
   ITakeProfitStrategy* tp = NULL;
   switch (take_profit_type)
   {
      case TPDoNotUse:
         tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDoNotUse, take_profit_value, isBuy);
         break;
      #ifdef TAKE_PROFIT_FEATURE
         case TPPercent:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPercent, take_profit_value, isBuy);
            break;
         case TPPips:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPips, take_profit_value, isBuy);
            break;
         case TPDollar:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDollar, take_profit_value, isBuy);
            break;
         case TPRiskReward:
            tp = new RiskToRewardTakeProfitStrategy(take_profit_value, isBuy);
            break;
         case TPAbsolute:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitAbsolute, take_profit_value, isBuy);
            break;
      #endif
   }
   
   return new MoneyManagementStrategy(sl, tp);
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
      tradingTimeCondition.Release();
      delete tradingCalculator;
      return NULL;
   }

   Signaler* signaler = new Signaler(symbol, timeframe);
   signaler.SetMessagePrefix(symbol + "/" + signaler.GetTimeframeStr() + ": ");
   
   TradingController* controller = new TradingController(tradingCalculator, timeframe, timeframe, signaler);
   
   ActionOnConditionLogic* actions = new ActionOnConditionLogic();
   controller.SetActions(actions);
   controller.SetECNBroker(ecn_broker);
   
   CustomMoveStopLossOnProfitOrderAction* orderAction = new CustomMoveStopLossOnProfitOrderAction(actions);
   controller.AddOrderAction(orderAction);
   orderAction.Release();

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
               controller.AddOrderAction(trailingAction);
               trailingAction.Release();
            }
            break;
      }
   #endif

   AndCondition* longCondition = new AndCondition();
   longCondition.Add(CreateLongCondition(symbol, timeframe), false);
   AndCondition* shortCondition = new AndCondition();
   shortCondition.Add(CreateShortCondition(symbol, timeframe), false);
   #ifdef TRADING_TIME_FEATURE
      longCondition.Add(tradingTimeCondition, true);
      shortCondition.Add(tradingTimeCondition, true);
   #endif
   tradingTimeCondition.Release();

   ICondition* longFilterCondition = CreateLongFilterCondition(symbol, timeframe);
   ICondition* shortFilterCondition = CreateShortFilterCondition(symbol, timeframe);

      ICondition* exitLongCondition = new DisabledCondition();
      ICondition* exitShortCondition = new DisabledCondition();

   switch (logic_direction)
   {
      case DirectLogic:
         controller.SetLongCondition(longCondition);
         controller.SetLongFilterCondition(longFilterCondition);
         controller.SetShortCondition(shortCondition);
         controller.SetShortFilterCondition(shortFilterCondition);
         controller.SetExitLongCondition(exitLongCondition);
         controller.SetExitShortCondition(exitShortCondition);
         break;
      case ReversalLogic:
         controller.SetLongCondition(shortCondition);
         controller.SetLongFilterCondition(shortFilterCondition);
         controller.SetShortCondition(longCondition);
         controller.SetShortFilterCondition(longFilterCondition);
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
   
   IMoneyManagementStrategy* longMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, true);
   IMoneyManagementStrategy* shortMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, false);
   controller.AddLongMoneyManagement(longMoneyManagement);
   controller.AddShortMoneyManagement(shortMoneyManagement);

   if (close_on_opposite)
      controller.SetCloseOnOpposite(new DoCloseOnOppositeStrategy(slippage_points, magic_number));
   else
      controller.SetCloseOnOpposite(new DontCloseOnOppositeStrategy());

   #ifdef POSITION_CAP_FEATURE
      if (position_cap)
      {
         controller.SetLongPositionCap(new PositionCapStrategy(BuySide, magic_number, no_of_buy_position, no_of_positions, symbol));
         controller.SetShortPositionCap(new PositionCapStrategy(SellSide, magic_number, no_of_sell_position, no_of_positions, symbol));
      }
      else
      {
         controller.SetLongPositionCap(new NoPositionCapStrategy());
         controller.SetShortPositionCap(new NoPositionCapStrategy());
      }
   #endif

   controller.SetEntryLogic(entry_logic);
   #ifdef USE_MARKET_ORDERS
      controller.SetEntryStrategy(new MarketEntryStrategy(symbol, magic_number, slippage_points, actions));
   #else
      AStream *longPrice = new LongEntryStream(symbol, timeframe);
      AStream *shortPrice = new ShortEntryStream(symbol, timeframe);
      controller.SetEntryStrategy(new PendingEntryStrategy(symbol, magic_number, slippage_points, longPrice, shortPrice, actions));
   #endif
   controller.SetPrintLog(PrintLog);

   return controller;
}

int OnInit()
{
   double temp = iCustom(NULL, 0, "RSI_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'RSI_MA' indicator");
      return INIT_FAILED;
   }
   temp = iCustom(NULL, 0, "Elliot oscillator - waves", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Elliot oscillator - waves' indicator");
      return INIT_FAILED;
   }
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   
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
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
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
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+