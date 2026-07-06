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
#property version   "1.0"
#property strict

#define ACT_ON_SWITCH_CONDITION

input string PeriodBegin="00:00";
input string PeriodEnd="05:00";
input string BoxEnd="23:00";
input int       ZZLength=20;
input int       ZZPatternLength=10;
input int        ZZPatternWidth=4;
input int RSI_Length = 14; // RSI Length
input double RSI_Level = 50; // RSI Level

// Order side v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide,
   SellSide
};

#endif

#ifndef tradeManager_INSTANCE
#define tradeManager_INSTANCE
#include <Trade\Trade.mqh>
CTrade tradeManager;
#endif

enum EntryType
{
   EntryOnClose, // Entry on candle close
   EntryLive // Entry on tick
};

enum TradingDirection
{
   LongSideOnly, // Long only
   ShortSideOnly, // Short only
   BothSides // Both
};

// Stop/limit type v1.0

#ifndef StopLimitType_IMP
#define StopLimitType_IMP

enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $
   StopLimitRiskReward // Set in % of stop loss
};
// Position size type

#ifndef PositionSizeType_IMP
#define PositionSizeType_IMP

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
   PositionSizeMoneyPerPip // $ per pip
};

#endif

enum PositionDirection
{
   DirectLogic, // Direct
   ReversalLogic // Reversal
};

enum TrailingType
{
   TrailingDontUse, // No trailing
   TrailingPips, // Use trailing in pips
   TrailingPercent // Use trailing in % of stop
};

input string GeneralSection = ""; // == General ==
input string symbols = ""; // Symbols to trade. Separated by ","
input bool allow_trading = true; // Allow trading
input bool BTCAccount = false; // Is BTC Account?
input EntryType entry_type = EntryOnClose; // Entry type
input TradingDirection trading_side = BothSides; // What trades should be taken
input double lot_size            = 0.1; // Position size
input PositionSizeType lot_type = PositionSizeContract; // Position size type
input int slippage_points           = 3; // Slippage, in points
input bool close_on_opposite = true; // Close on opposite

input string SLSection            = ""; // == Stop loss/TakeProfit ==
input StopLimitType stop_loss_type = StopLimitPips; // Stop loss type
input double stop_loss_value            = 10; // Stop loss value
input TrailingType trailing_type = TrailingDontUse; // Use trailing
input double TrailingStep = 10; // Trailing step
input StopLimitType take_profit_type = StopLimitPips; // Take profit type
input double take_profit_value           = 10; // Take profit value
input StopLimitType breakeven_type = StopLimitPips; // Trigger type for the breakeven
input double breakeven_value = 10; // Trigger for the breakeven

input string PositionCapSection = ""; // == Position cap ==
input bool use_position_cap = true; // Use position cap?
input int max_positions = 2; // Max positions

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

input string OtherSection            = ""; // == Other ==
input int magic_number        = 42; // Magic number
input PositionDirection LogicType = DirectLogic; // Logic type
input string StartTime = "000000"; // Start time in hhmmss format
input string EndTime = "235959"; // End time in hhmmss format
input bool LimitWeeklyTime = false; // Weekly time
input DayOfWeek WeekStartDay = DayOfWeekSunday; // Start day
input string WeekStartTime = "000000"; // Start time in hhmmss format
input DayOfWeek WeekStopDay = DayOfWeekSaturday; // Stop day
input string WeekStopTime = "235959"; // Stop time in hhmmss format
input bool MandatoryClosing = false; // Mandatory closing for non-trading time

//Signaler v 1.4
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment5                 = "- DISABLED IN THIS VERSION -";
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
//#import "AdvancedNotificationsLib.dll"
//void AdvancedAlert(string key, string text, string instrument, string timeframe);
//#import

// Trading time condition v1.0

// ICondition v3.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
};
#endif

#ifndef TradingTimeCondition_IMP
#define TradingTimeCondition_IMP

class TradingTime
{
   int _startTime;
   int _endTime;
   bool _useWeekTime;
   int _weekStartTime;
   int _weekStartDay;
   int _weekStopTime;
   int _weekStopDay;
public:
   TradingTime()
   {
      _startTime = 0;
      _endTime = 0;
      _useWeekTime = false;
   }

   bool SetWeekTradingTime(const DayOfWeek startDay, const string startTime, const DayOfWeek stopDay, 
      const string stopTime, string &error)
   {
      _useWeekTime = true;
      _weekStartTime = ParseTime(startTime, error);
      if (_weekStartTime == -1)
         return false;
      _weekStopTime = ParseTime(stopTime, error);
      if (_weekStopTime == -1)
         return false;
      
      _weekStartDay = (int)startDay;
      _weekStopDay = (int)stopDay;
      return true;
   }

   bool Init(const string startTime, const string endTime, string &error)
   {
      _startTime = ParseTime(startTime, error);
      if (_startTime == -1)
         return false;
      _endTime = ParseTime(endTime, error);
      if (_endTime == -1)
         return false;

      return true;
   }

   bool IsTradingTime(datetime dt)
   {
      if (_startTime == _endTime && !_useWeekTime)
         return true;
      MqlDateTime current_time;
      if (!TimeToStruct(dt, current_time))
         return false;
      if (!IsIntradayTradingTime(current_time))
         return false;
      return IsWeeklyTradingTime(current_time);
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

   int ParseTime(const string time, string &error)
   {
      int time_parsed = (int)StringToInteger(time);
      int seconds = time_parsed % 100;
      if (seconds > 59)
      {
         error = "Incorrect number of seconds in " + time;
         return -1;
      }
      time_parsed /= 100;
      int minutes = time_parsed % 100;
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }
      time_parsed /= 100;
      int hours = time_parsed % 100;
      if (hours > 24 || (hours == 24 && (minutes > 0 || seconds > 0)))
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      return (hours * 60 + minutes) * 60 + seconds;
   }
};

class TradingTimeCondition : public ICondition
{
   TradingTime *_tradingTime;
   ENUM_TIMEFRAMES _timeframe;
public:
   TradingTimeCondition(ENUM_TIMEFRAMES timeframe)
   {
      _timeframe = timeframe;
      _tradingTime = new TradingTime();
   }

   ~TradingTimeCondition()
   {
      delete _tradingTime;
   }

   bool Init(const string startTime, const string endTime, string &error)
   {
      return _tradingTime.Init(startTime, endTime, error);
   }

   virtual bool IsPass(const int period)
   {
      datetime time = iTime(_Symbol, _timeframe, period);
      return _tradingTime.IsTradingTime(time);
   }
};
#endif
// Disabled condition v1.0
// Condition base v1.0

#ifndef ACondition_IMP
#define ACondition_IMP


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
};

#endif

#ifndef DisabledCondition_IMP
#define DisabledCondition_IMP
class DisabledCondition : public AConditionBase
{
public:
   virtual bool IsPass(const int period, const datetime date) { return false; }
};
#endif
// And condition v1.0



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

   void Add(ICondition *condition, bool addRef)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
      if (addRef)
      {
         condition.AddRef();
      }
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
};
#endif
// Base condition v1.0

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP


// Symbol info v.1.2
class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digit;
   double _ticksize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      _digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _ticksize = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), _digit);
   }

   static double GetPipSize(const string symbol)
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      double mult = digit == 3 || digit == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPointSize() { return _point; }
   double GetPipSize() { return _pipSize; }
   int GetDigits() { return _digit; }
   string GetSymbol() { return _symbol; }
   double GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double GetMinVolume() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
   }
};
class ACondition : public AConditionBase
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo* _instrument;
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
#ifdef ACT_ON_SWITCH_CONDITION
// Act on switch condition v1.0



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
};
#endif
#endif

// Trades iterator v 1.2

// Compare type v1.0

#ifndef CompareType_IMP
#define CompareType_IMP

enum CompareType
{
   CompareLessThan
};

#endif

#ifndef TradesIterator_IMP

class TradesIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   int _orderType;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _useProfit;
   double _profit;
   CompareType _profitCompare;
   string _comment;
public:
   TradesIterator()
   {
      _comment = NULL;
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useProfit = false;
   }

   TradesIterator* WhenComment(string comment)
   {
      _comment = comment;
      return &this;
   }

   void WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
   }

   void WhenProfit(const double profit, const CompareType compare)
   {
      _useProfit = true;
      _profit = profit;
      _profitCompare = compare;
   }

   void WhenSide(const bool isBuy)
   {
      _useSide = true;
      _isBuySide = isBuy;
   }

   void WhenMagicNumber(const int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
   }
   
   ulong GetTicket() { return PositionGetTicket(_lastIndex); }
   double GetLots() { return PositionGetDouble(POSITION_VOLUME); }
   double GetOpenPrice() { return PositionGetDouble(POSITION_PRICE_OPEN); }
   double GetStopLoss() { return PositionGetDouble(POSITION_SL); }
   double GetTakeProfit() { return PositionGetDouble(POSITION_TP); }
   ENUM_POSITION_TYPE GetPositionType() { return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); }
   bool IsBuyOrder() { return GetPositionType() == POSITION_TYPE_BUY; }
   string GetSymbol() { return PositionGetSymbol(_lastIndex); }

   int Count()
   {
      int count = 0;
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) && PassFilter(i))
         {
            count++;
         }
      }
      return count;
   }

   bool Next()
   {
      if (_lastIndex == INT_MIN)
      {
         _lastIndex = PositionsTotal() - 1;
      }
      else
         _lastIndex = _lastIndex - 1;
      while (_lastIndex >= 0)
      {
         ulong ticket = PositionGetTicket(_lastIndex);
         if (PositionSelectByTicket(ticket) && PassFilter(_lastIndex))
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) && PassFilter(i))
         {
            return true;
         }
      }
      return false;
   }

   ulong First()
   {
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) && PassFilter(i))
         {
            return ticket;
         }
      }
      return 0;
   }

private:
   bool PassFilter(const int index)
   {
      if (_useMagicNumber && PositionGetInteger(POSITION_MAGIC) != _magicNumber)
         return false;
      if (_useSymbol && PositionGetSymbol(index) != _symbol)
         return false;
      if (_useProfit)
      {
         switch (_profitCompare)
         {
            case CompareLessThan:
               if (PositionGetDouble(POSITION_PROFIT) >= _profit)
                  return false;
               break;
         }
      }
      if (_useSide)
      {
         ENUM_POSITION_TYPE positionType = GetPositionType();
         if (_isBuySide && positionType != POSITION_TYPE_BUY)
            return false;
         if (!_isBuySide && positionType != POSITION_TYPE_SELL)
            return false;
      }
      if (_comment != NULL)
      {
         if (_comment != PositionGetString(POSITION_COMMENT))
            return false;
      }
      return true;
   }
};
#define TradesIterator_IMP
#endif
// Trading calculator v.1.3







#ifndef TradingCalculator_IMP
#define TradingCalculator_IMP

class TradingCalculator
{
   InstrumentInfo *_symbolInfo;
public:
   static TradingCalculator* Create(string symbol)
   {
      return new TradingCalculator(symbol);
   }

   TradingCalculator(const string symbol)
   {
      _symbolInfo = new InstrumentInfo(symbol);
   }

   ~TradingCalculator()
   {
      delete _symbolInfo;
   }

   InstrumentInfo *GetSymbolInfo()
   {
      return _symbolInfo;
   }

   double GetBreakevenPrice(const bool isBuy, const int magicNumber)
   {
      string symbol = _symbolInfo.GetSymbol();
      double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      double price = isBuy ? _symbolInfo.GetBid() : _symbolInfo.GetAsk();
      double totalPL = 0;
      double totalAmount = 0;
      TradesIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(symbol);
      it1.WhenSide(isBuy);
      while (it1.Next())
      {
         double orderLots = PositionGetDouble(POSITION_VOLUME);
         totalAmount += orderLots / lotStep;
         double openPrice = it1.GetOpenPrice();
         if (isBuy)
            totalPL += (price - openPrice) * (orderLots / lotStep);
         else
            totalPL += (openPrice - price) * (orderLots / lotStep);
      }
      if (totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return isBuy ? price + shift : price - shift;
   }
   
   double CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (takeProfitType)
      {
         case StopLimitPercent:
            return basePrice + basePrice * takeProfit / 100.0 * direction;
         case StopLimitPips:
            return basePrice + takeProfit * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice + CalculateSLShift(amount, takeProfit) * direction;
      }
      return 0.0;
   }
   
   double CalculateStopLoss(const bool isBuy, const double stopLoss, const StopLimitType stopLossType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (stopLossType)
      {
         case StopLimitPercent:
            return basePrice - basePrice * stopLoss / 100.0 * direction;
         case StopLimitPips:
            return basePrice - stopLoss * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice - CalculateSLShift(amount, stopLoss) * direction;
      }
      return 0.0;
   }

   double GetLots(PositionSizeType lotsType, double lotsValue, const OrderSide orderSide, const double price, double stopDistance)
   {
      switch (lotsType)
      {
         case PositionSizeMoneyPerPip:
         {
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double mult = _symbolInfo.GetPipSize() / _symbolInfo.GetPointSize();
            double lots = RoundLots(lotsValue / (unitCost * mult));
            return LimitLots(lots);
         }
         case PositionSizeAmount:
            return GetLotsForMoney(orderSide, price, lotsValue);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(orderSide, price, AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0);
         case PositionSizeRisk:
         {
            double affordableLoss = AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0;
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
               return 0;
            return LimitLots(RoundLots(affordableLoss / possibleLoss));
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

   double NormilizeLots(double lots)
   {
      return LimitLots(RoundLots(lots));
   }

private:
   bool IsContractLotsValid(const double lots, string &error)
   {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if (minVolume > lots)
      {
         error = "Min. allowed lot size is " + DoubleToString(minVolume);
         return false;
      }
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         error = "Max. allowed lot size is " + DoubleToString(maxVolume);
         return false;
      }
      return true;
   }

   double GetLotsForMoney(const OrderSide orderSide, const double price, const double money)
   {
      ENUM_ORDER_TYPE orderType = orderSide != BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      string symbol = _symbolInfo.GetSymbol();
      double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double marginRequired;
      if (!OrderCalcMargin(orderType, symbol, minVolume, price, marginRequired))
      {
         return 0.0;
      }
      if (marginRequired <= 0.0)
      {
         Print("Margin is 0. Server misconfiguration?");
         return 0.0;
      }
      double lots = RoundLots(money / marginRequired);
      return LimitLots(lots);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if (minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
         return maxVolume;
      return lots;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
      return (money / (unitCost / tickSize)) / amount;
   }
};

#endif
// Money management strategy v.1.2
interface IMoneyManagementStrategy
{
public:
   virtual void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit) = 0;
};

class AMoneyManagementStrategy : public IMoneyManagementStrategy
{
protected:
   TradingCalculator *_calculator;
   PositionSizeType _lotsType;
   double _lots;
   StopLimitType _stopLossType;
   double _stopLoss;
   StopLimitType _takeProfitType;
   double _takeProfit;

   AMoneyManagementStrategy(TradingCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
   {
      _calculator = calculator;
      _lotsType = lotsType;
      _lots = lots;
      _stopLossType = stopLossType;
      _stopLoss = stopLoss;
      _takeProfitType = takeProfitType;
      _takeProfit = takeProfit;
   }
};

// IStream v.1.2
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

class StopLossStreamLongMoneyManagementStrategy : public AMoneyManagementStrategy
{
   IStream *_stopLossStream;
public:
   StopLossStreamLongMoneyManagementStrategy(TradingCalculator *calculator, PositionSizeType lotsType, double lots
      , IStream *stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, 0, 0, takeProfitType, takeProfit)
   {
      _stopLossStream = stopLoss;
   }
   ~StopLossStreamLongMoneyManagementStrategy()
   {
      delete _stopLossStream;
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      double stopLossVal[1];
      if (!_stopLossStream.GetValues(period, 1, stopLossVal))
      {
         amount = 0;
         stopLoss = 0;
         takeProfit = 0;
         return;
      }
      if (_lotsType == PositionSizeRisk)
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, entryPrice, entryPrice - stopLoss);
      else
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, 0.0, 0);
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice + (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(true, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

class StopLossStreamShortMoneyManagementStrategy : public AMoneyManagementStrategy
{
   IStream *_stopLossStream;
public:
   StopLossStreamShortMoneyManagementStrategy(TradingCalculator *calculator, PositionSizeType lotsType, double lots
      , IStream *stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, 0, 0, takeProfitType, takeProfit)
   {
      _stopLossStream = stopLoss;
   }
   ~StopLossStreamShortMoneyManagementStrategy()
   {
      delete _stopLossStream;
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      double stopLossVal[1];
      if (!_stopLossStream.GetValues(period, 1, stopLossVal))
      {
         amount = 0;
         stopLoss = 0;
         takeProfit = 0;
         return;
      }
      if (_lotsType == PositionSizeRisk)
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, entryPrice, stopLoss - entryPrice);
      else
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, 0.0, 0);
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice - (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(false, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

class LongMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   LongMoneyManagementStrategy(TradingCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, entryPrice, entryPrice - stopLoss);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, 0.0, 0);
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice + (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(true, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

class ShortMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   ShortMoneyManagementStrategy(TradingCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, entryPrice, stopLoss - entryPrice);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, 0.0, 0);
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice - (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(false, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};
// Orders iterator v 1.9




#ifndef OrdersIterator_IMP

class OrdersIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   bool _useOrderType;
   ENUM_ORDER_TYPE _orderType;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _usePendingOrder;
   bool _pendingOrder;
   bool _useComment;
   string _comment;
   CompareType _profitCompare;
public:
   OrdersIterator()
   {
      _useOrderType = false;
      _useMagicNumber = false;
      _usePendingOrder = false;
      _pendingOrder = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useComment = false;
   }

   OrdersIterator *WhenPendingOrder()
   {
      _usePendingOrder = true;
      _pendingOrder = true;
      return &this;
   }

   OrdersIterator *WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
      return &this;
   }

   OrdersIterator *WhenSide(const OrderSide side)
   {
      _useSide = true;
      _isBuySide = side == BuySide;
      return &this;
   }

   OrdersIterator *WhenOrderType(const ENUM_ORDER_TYPE orderType)
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

   long GetMagicNumger() { return OrderGetInteger(ORDER_MAGIC); }
   ENUM_ORDER_TYPE GetType() { return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); }
   string GetSymbol() { return OrderGetString(ORDER_SYMBOL); }
   ulong GetTicket() { return OrderGetTicket(_lastIndex); }
   double GetOpenPrice() { return OrderGetDouble(ORDER_PRICE_OPEN); }
   double GetStopLoss() { return OrderGetDouble(ORDER_SL); }
   double GetTakeProfit() { return OrderGetDouble(ORDER_TP); }

   int Count()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
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
         ulong ticket = OrderGetTicket(_lastIndex);
         if (OrderSelect(ticket) && PassFilter())
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
            return true;
      }
      return false;
   }

   ulong First()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
            return ticket;
      }
      return -1;
   }

private:
   bool PassFilter()
   {
      if (_useMagicNumber && GetMagicNumger() != _magicNumber)
         return false;
      if (_useOrderType && GetType() != _orderType)
         return false;
      if (_useSymbol && OrderGetString(ORDER_SYMBOL) != _symbol)
         return false;
      if (_usePendingOrder && !IsPendingOrder())
         return false;
      if (_useComment && OrderGetString(ORDER_COMMENT) != _comment)
         return false;
      return true;
   }

   bool IsPendingOrder()
   {
      switch (GetType())
      {
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_STOP_LIMIT:
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
         case ORDER_TYPE_SELL_STOP_LIMIT:
            return true;
      }
      return false;
   }
};
#define OrdersIterator_IMP
#endif
// Trading commands v.2.0




#ifndef tradeManager_INSTANCE
#define tradeManager_INSTANCE
#include <Trade\Trade.mqh>
CTrade tradeManager;
#endif

#ifndef TradingCommands_IMP
#define TradingCommands_IMP

class TradingCommands
{
public:
   static bool MoveSLTP(const ulong ticket, const double stopLoss, double takeProfit, string &error)
   {
      if (!PositionSelectByTicket(ticket))
      {
         error = "Invalid ticket";
         return false;
      }
      return tradeManager.PositionModify(ticket, stopLoss, takeProfit);
   }

   static bool MoveSL(const ulong ticket, const double stopLoss, string &error)
   {
      if (!PositionSelectByTicket(ticket))
      {
         error = "Invalid ticket";
         return false;
      }
      return tradeManager.PositionModify(ticket, stopLoss, PositionGetDouble(POSITION_TP));
   }

   static void DeleteOrders(const int magicNumber, const string symbol)
   {
      OrdersIterator it();
      it.WhenMagicNumber(magicNumber);
      it.WhenSymbol(symbol);
      while (it.Next())
      {
         tradeManager.OrderDelete(it.GetTicket());
      }
   }

   static bool CloseTrade(ulong ticket, string error)
   {
      if (!tradeManager.PositionClose(ticket)) 
      {
         error = IntegerToString(GetLastError());
         return false;
      }
      return true;
   }

   static int CloseTrades(TradesIterator &it)
   {
      int close = 0;
      while (it.Next())
      {
         string error;
         if (!CloseTrade(it.GetTicket(), error)) 
            Print("LastError = ", error);
         else
            ++close;
      }
      return close;
   }
};

#endif
// Trailing controller v.1.7
enum TrailingControllerType
{
   TrailingControllerTypeStandard,
   TrailingControllerTypeCustom
};

interface ITrailingController
{
public:
   virtual bool IsFinished() = 0;
   virtual void UpdateStop() = 0;
   virtual TrailingControllerType GetType() = 0;
};

//Signaler v 4.0

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#endif

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
   bool _popupAlert;
   bool _emailAlert;
   bool _playSound;
   string _soundFile;
   bool _notificationAlert;
   bool _advancedAlert;
   string _advancedKey;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _popupAlert = false;
      _emailAlert = false;
      _playSound = false;
      _notificationAlert = false;
      _advancedAlert = false;
   }

   void SetPopupAlert(bool isEnabled) { _popupAlert = isEnabled; }
   void SetEmailAlert(bool isEnabled) { _emailAlert = isEnabled; }
   void SetPlaySound(bool isEnabled, string fileName) 
   { 
      _playSound = isEnabled;
      _soundFile = fileName;
   }
   void SetNotificationAlert(bool isEnabled) { _notificationAlert = isEnabled; }
   void SetAdvancedAlert(bool isEnabled, string key)
   {
      _advancedAlert = isEnabled;
      _advancedKey = key;
   }

   void SendNotifications(string message, string subject = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (subject == NULL)
         subject = message;

      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (_popupAlert)
         Alert(message);
      if (_emailAlert)
         SendMail(subject, message);
      if (_playSound)
         PlaySound(_soundFile);
      if (_notificationAlert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (_advancedAlert && _advancedKey != "")
         AdvancedAlert(_advancedKey, message, symbol, timeframe);
#endif
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
         case PERIOD_M2: return "M2";
         case PERIOD_M3: return "M3";
         case PERIOD_M4: return "M4";
         case PERIOD_M5: return "M5";
         case PERIOD_M6: return "M6";
         case PERIOD_M10: return "M10";
         case PERIOD_M12: return "M12";
         case PERIOD_M15: return "M15";
         case PERIOD_M20: return "M20";
         case PERIOD_M30: return "M30";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H2: return "H2";
         case PERIOD_H3: return "H3";
         case PERIOD_H4: return "H4";
         case PERIOD_H6: return "H6";
         case PERIOD_H8: return "H8";
         case PERIOD_H12: return "H12";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};


class CustomLevelController : public ITrailingController
{
   Signaler *_signaler;
   ulong _order;
   bool _finished;
   double _stop;
   double _trigger;
   TradingCalculator *_tradeCalculator;
public:
   CustomLevelController(TradingCalculator *tradeCalculator, Signaler *signaler = NULL)
   {
      _tradeCalculator = tradeCalculator;
      _finished = true;
      _order = 0;
      _signaler = signaler;
      _trigger = 0;
      _stop = 0;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const ulong order, const double stop, const double trigger)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order))
      {
         return false;
      }
      _trigger = trigger;
      _finished = false;
      _order = order;
      _stop = stop;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished)
         return;
      if (!PositionSelectByTicket(_order))
      {
         if (!OrderSelect(_order))
            _finished = true;
         return;
      }

      int type = (int)PositionGetInteger(POSITION_TYPE);
      double newStop = PositionGetDouble(POSITION_SL);
      if (type == POSITION_TYPE_BUY)
      {
         if (_trigger < _tradeCalculator.GetSymbolInfo().GetAsk()) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(_stop);
               _signaler.SendNotifications(message);
            }
            string error;
            if (!TradingCommands::MoveSL(_order, _stop, error))
            {
               Print(error);
               return;
            }
            _finished = true;
         }
      }
      else if (type == POSITION_TYPE_SELL) 
      {
         if (_trigger > _tradeCalculator.GetSymbolInfo().GetBid()) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(_stop);
               _signaler.SendNotifications(message);
            }
            string error;
            if (!TradingCommands::MoveSL(_order, _stop, error))
            {
               Print(error);
               return;
            }
            _finished = true;
         }
      }
   }

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeCustom;
   }
};

class TrailingController : public ITrailingController
{
   Signaler *_signaler;
   ulong _order;
   bool _finished;
   double _stop;
   double _trailingStep;
   TradingCalculator *_tradeCalculator;
public:
   TrailingController(TradingCalculator *tradeCalculator, Signaler *signaler = NULL)
   {
      _tradeCalculator = tradeCalculator;
      _finished = true;
      _order = 0;
      _signaler = signaler;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const ulong order, const double stop, const double trailingStep)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order))
      {
         return false;
      }
      _trailingStep = _tradeCalculator.GetSymbolInfo().RoundRate(trailingStep);
      if (_trailingStep == 0)
         return false;

      _finished = false;
      _order = order;
      _stop = stop;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished)
         return;
      if (!PositionSelectByTicket(_order))
      {
         if (!OrderSelect(_order))
            _finished = true;
         return;
      }

      int type = (int)PositionGetInteger(POSITION_TYPE);
      double originalStop = PositionGetDouble(POSITION_SL);
      double newStop = originalStop;
      if (type == POSITION_TYPE_BUY)
      {
         while (_tradeCalculator.GetSymbolInfo().RoundRate(newStop + _trailingStep) < _tradeCalculator.GetSymbolInfo().RoundRate(_tradeCalculator.GetSymbolInfo().GetAsk() - _stop))
         {
            newStop = _tradeCalculator.GetSymbolInfo().RoundRate(newStop + _trailingStep);
         }
         if (newStop != originalStop) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(newStop, _tradeCalculator.GetSymbolInfo().GetDigits());
               _signaler.SendNotifications(message);
            }
            string error;
            if (!TradingCommands::MoveSL(_order, newStop, error))
            {
               Print(error);
               _finished = true;
               return;
            }
         }
      } 
      else if (type == POSITION_TYPE_SELL) 
      {
         while (_tradeCalculator.GetSymbolInfo().RoundRate(newStop - _trailingStep) > _tradeCalculator.GetSymbolInfo().RoundRate(_tradeCalculator.GetSymbolInfo().GetBid() + _stop))
         {
            newStop = _tradeCalculator.GetSymbolInfo().RoundRate(newStop - _trailingStep);
         }
         if (newStop != originalStop) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(newStop, _tradeCalculator.GetSymbolInfo().GetDigits());
               _signaler.SendNotifications(message);
            }
            string error;
            if (!TradingCommands::MoveSL(_order, newStop, error))
            {
               Print(error);
               _finished = true;
               return;
            }
         }
      } 
   }

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeStandard;
   }
};

class TrailingLogic
{
   ITrailingController *_trailing[];
   TradingCalculator *_calculator;
   TrailingType _trailingType;
   double _trailingStep;
   double _atrTrailingMultiplier;
   ENUM_TIMEFRAMES _timeframe;
public:
   TrailingLogic(TradingCalculator *calculator, TrailingType trailing, 
      double trailingStep, double atrTrailingMultiplier, ENUM_TIMEFRAMES timeframe)
   {
      _calculator = calculator;
      _trailingType = trailing;
      _trailingStep = trailingStep;
      _atrTrailingMultiplier = atrTrailingMultiplier;
      _timeframe = timeframe;
   }

   ~TrailingLogic()
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         delete _trailing[i];
      }
   }

   void DoLogic()
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         _trailing[i].UpdateStop();
      }
   }

   void CreateCustom(const ulong order, const double stop, const bool isBuy, const double triggerLevel)
   {
      if (!OrderSelect(order))
         return;

      string symbol = OrderGetString(ORDER_SYMBOL);
      if (symbol != _calculator.GetSymbolInfo().GetSymbol())
      {
         Print("Error in trailing usage");
         return;
      }

      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeCustom)
            continue;
         CustomLevelController *trailingController = (CustomLevelController *)_trailing[i];
         if (trailingController.SetOrder(order, stop, triggerLevel))
         {
            return;
         }
      }

      CustomLevelController *trailingController = new CustomLevelController(_calculator);
      trailingController.SetOrder(order, stop, triggerLevel);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }

   void Create(const ulong order, const double stop, const bool isBuy)
   {
      if (!OrderSelect(order))
         return;

      string symbol = OrderGetString(ORDER_SYMBOL);
      if (symbol != _calculator.GetSymbolInfo().GetSymbol())
      {
         Print("Error in trailing usage");
         return;
      }
      double stopDiff = isBuy ? _calculator.GetSymbolInfo().GetAsk() - stop : stop - _calculator.GetSymbolInfo().GetBid();
      switch (_trailingType)
      {
         case TrailingPips:
            CreateTrailing(order, stopDiff, _trailingStep * _calculator.GetSymbolInfo().GetPipSize());
            break;
         case TrailingPercent:
            CreateTrailing(order, stopDiff, stopDiff * _trailingStep / 100.0);
            break;
      }
   }
private:
   void CreateTrailing(const ulong order, const double stop, const double trailingStep)
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeStandard)
            continue;
         TrailingController *trailingController = (TrailingController *)_trailing[i];
         if (trailingController.SetOrder(order, stop, trailingStep))
         {
            return;
         }
      }

      TrailingController *trailingController = new TrailingController(_calculator);
      trailingController.SetOrder(order, stop, trailingStep);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }
};
// Net stop loss v 1.1
interface INetStopLossStrategy
{
public:
   virtual void DoLogic() = 0;
};

// Disabled net stop loss
class NoNetStopLossStrategy : public INetStopLossStrategy
{
public:
   void DoLogic()
   {
      // Do nothing
   }
};

class NetStopLossStrategy : public INetStopLossStrategy
{
   TradingCalculator *_calculator;
   int _magicNumber;
   double _stopLossPips;
   Signaler *_signaler;
public:
   NetStopLossStrategy(TradingCalculator *calculator, const double stopLossPips, Signaler *signaler, const int magicNumber)
   {
      _calculator = calculator;
      _stopLossPips = stopLossPips;
      _signaler = signaler;
      _magicNumber = magicNumber;
   }

   void DoLogic()
   {
      MoveStopLoss(true);
      MoveStopLoss(false);
   }
private:
   void MoveStopLoss(const bool isBuy)
   {
      TradesIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenSide(isBuy);
      if (it.Count() <= 1)
         return;
      double averagePrice = _calculator.GetBreakevenPrice(isBuy, _magicNumber);
      if (averagePrice == 0.0)
         return;
         
      double pipSize = _calculator.GetSymbolInfo().GetPipSize();
      double stopLoss = isBuy ? _calculator.GetSymbolInfo().RoundRate(averagePrice - _stopLossPips * pipSize)
         : _calculator.GetSymbolInfo().RoundRate(averagePrice + _stopLossPips * pipSize);
      if (isBuy)
      {
         if (stopLoss >= _calculator.GetSymbolInfo().GetBid())
            return;
      }
      else
      {
         if (stopLoss <= _calculator.GetSymbolInfo().GetAsk())
            return;
      }
      
      TradesIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbolInfo().GetSymbol());
      it1.WhenSide(isBuy);
      int count = 0;
      while (it1.Next())
      {
         if (it1.GetStopLoss() != stopLoss)
         {
            string error = "";
            if (!TradingCommands::MoveSL(it1.GetTicket(), stopLoss, error))
            {
               if (error != "")
                  Print(error);
            }
            else
               ++count;
         }
      }
      if (_signaler != NULL && count > 0)
         _signaler.SendNotifications("Moving net stop loss to " + DoubleToString(stopLoss, _calculator.GetSymbolInfo().GetDigits()));
   }
};
// Market order builder v1.4


#ifndef MarketOrderBuilder_IMP
#define MarketOrderBuilder_IMP
class MarketOrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stop;
   double _limit;
   int _magicNumber;
   string _comment;
   bool _btcAccount;
public:
   MarketOrderBuilder()
   {
      _btcAccount = false;
      _amount = 0;
      _rate = 0;
      _slippage = 0;
      _stop = 0;
      _limit = 0;
      _magicNumber = 0;
   }

   MarketOrderBuilder* SetComment(const string comment) { _comment = comment; return &this; }
   MarketOrderBuilder* SetSide(const OrderSide orderSide) { _orderSide = orderSide; return &this; }
   MarketOrderBuilder* SetInstrument(const string instrument) { _instrument = instrument; return &this; }
   MarketOrderBuilder* SetAmount(const double amount) { _amount = amount; return &this; }
   MarketOrderBuilder* SetSlippage(const int slippage) { _slippage = slippage; return &this; }
   MarketOrderBuilder* SetStopLoss(const double stop) { _stop = stop; return &this; }
   MarketOrderBuilder* SetTakeProfit(const double limit) { _limit = limit; return &this; }
   MarketOrderBuilder* SetMagicNumber(const int magicNumber) { _magicNumber = magicNumber; return &this; }
   MarketOrderBuilder* SetBTCAccount(const bool isBtcAccount) { _btcAccount = isBtcAccount; return &this; }
   
   ulong Execute(string &error)
   {
      int tradeMode = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_MODE);
      switch (tradeMode)
      {
         case SYMBOL_TRADE_MODE_DISABLED:
            error = "Trading is disbled";
            return 0;
         case SYMBOL_TRADE_MODE_CLOSEONLY:
            error = "Only close is allowed";
            return 0;
         case SYMBOL_TRADE_MODE_SHORTONLY:
            if (_orderSide == BuySide)
            {
               error = "Only short are allowed";
               return 0;
            }
            break;
         case SYMBOL_TRADE_MODE_LONGONLY:
            if (_orderSide == SellSide)
            {
               error = "Only long are allowed";
               return 0;
            }
            break;
      }
      ENUM_ORDER_TYPE orderType = _orderSide == BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      int digits = (int)SymbolInfoInteger(_instrument, SYMBOL_DIGITS);
      double rate = _orderSide == BuySide ? SymbolInfoDouble(_instrument, SYMBOL_ASK) : SymbolInfoDouble(_instrument, SYMBOL_BID);
      double ticksize = SymbolInfoDouble(_instrument, SYMBOL_TRADE_TICK_SIZE);
      
      MqlTradeRequest request;
      ZeroMemory(request);
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _instrument;
      request.type = orderType;
      request.volume = _amount;
      request.price = MathRound(rate / ticksize) * ticksize;
      request.deviation = _slippage;
      request.sl = MathRound(_stop / ticksize) * ticksize;
      request.tp = MathRound(_limit / ticksize) * ticksize;
      request.magic = _magicNumber;
      if (_comment != "")
         request.comment = _comment;
      if (_btcAccount)
         request.type_filling = SYMBOL_FILLING_FOK;
      MqlTradeResult result;
      ZeroMemory(result);
      bool res = OrderSend(request, result);
      switch (result.retcode)
      {
         case TRADE_RETCODE_INVALID_FILL:
            error = "Invalid order filling type";
            return 0;
         case TRADE_RETCODE_LONG_ONLY:
            error = "Only long trades are allowed for " + _instrument;
            return 0;
         case TRADE_RETCODE_INVALID_VOLUME:
            {
               double minVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MIN);
               error = "Invalid volume in the request. Min volume is: " + DoubleToString(minVolume);
            }
            return 0;
         case TRADE_RETCODE_INVALID_PRICE:
            error = "Invalid price in the request";
            return 0;
         case TRADE_RETCODE_INVALID_STOPS:
            {
               int filling = (int)SymbolInfoInteger(_instrument, SYMBOL_ORDER_MODE); 
               if ((filling & SYMBOL_ORDER_SL) != SYMBOL_ORDER_SL)
               {
                  error = "Stop loss in now allowed for " + _instrument;
                  return 0;
               }

               int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
               double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
               double price = request.stoplimit > 0.0 ? request.stoplimit : request.price;
               if (MathRound(MathAbs(price - request.sl) / point) < minStopDistancePoints)
               {
                  error = "Your stop level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
               }
               else
               {
                  error = "Invalid stops in the request";
               }
            }
            return 0;
         case TRADE_RETCODE_DONE:
            break;
         default:
            error = "Unknown error: " + IntegerToString(result.retcode);
            return 0;
      }
      return result.order;
   }
};
#endif
// Position cap v.1.1
interface IPositionCapStrategy
{
public:
   virtual bool IsLimitHit() = 0;
};

class PositionCapStrategy : public IPositionCapStrategy
{
   int _totalPositions;
   string _symbol;
   bool _useMagicNumber;
   int _magicNumber;
public:
   PositionCapStrategy(const int totalPositions)
   {
      _totalPositions = totalPositions;
      _symbol = "";
      _useMagicNumber = false;
   }

   PositionCapStrategy* WhenSymbol(string symbol)
   {
      _symbol = symbol;
      return &this;
   }

   PositionCapStrategy* WhenMagicNumber(int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
      return &this;
   }

   bool IsLimitHit()
   {
      TradesIterator it();
      if (_symbol != "")
         it.WhenSymbol(_symbol);
      if (_useMagicNumber)
         it.WhenMagicNumber(_magicNumber);
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
// Trade controller v.2.0

#include <Trade\Trade.mqh>
// Breakeven controller v. 1.4
class BreakevenController
{
   ulong _order;
   bool _finished;
   double _trigger;
   double _target;
public:
   BreakevenController()
   {
      _finished = false;
   }
   
   bool SetOrder(const ulong order, const double trigger, const double target)
   {
      if (!_finished)
      {
         return false;
      }
      _finished = false;
      _trigger = trigger;
      _target = target;
      _order = order;
      return true;
   }

   void DoLogic()
   {
      if (_finished || !OrderSelect(_order))
      {
         _finished = true;
         return;
      }

      string symbol = OrderGetString(ORDER_SYMBOL);
      int type = (int)OrderGetInteger(ORDER_TYPE);
      if (type == ORDER_TYPE_BUY)
      {
         if (SymbolInfoDouble(symbol, SYMBOL_ASK) >= _trigger)
         {
            string error;
            bool res = TradingCommands::MoveSL(_order, _target, error);
            if (!res)
            {
               return;
            }
            _finished = true;
         }
      } 
      else if (type == ORDER_TYPE_SELL) 
      {
         if (SymbolInfoDouble(symbol, SYMBOL_BID) < _trigger) 
         {
            string error;
            bool res = TradingCommands::MoveSL(_order, _target, error);
            if (!res)
            {
               return;
            }
            _finished = true;
         }
      } 
   }
};

class TradingController
{   
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastbartime;
   datetime _lastEntry;
   EntryType _entryType;
   Signaler *_signaler;
   TradingTime *_tradingTime;
   BreakevenController *_breakeven[];
   INetStopLossStrategy *_netStopLoss;
   TradingCalculator *_calculator;
   TrailingLogic *_trailing;
   ICondition *_longCondition;
   ICondition *_shortCondition;
   IMoneyManagementStrategy *_longMoneyManagementStrategy;
   IMoneyManagementStrategy *_shortMoneyManagementStrategy;
   IPositionCapStrategy* _positionCap;
   bool _allowTrading;
   bool _closeOnOpposite;
   int _slippage;
   StopLimitType _breakevenType;
   double _breakevenValue;
   int _magicNumber;
public:
   TradingController(Signaler *signaler, TradingCalculator *calculator, ENUM_TIMEFRAMES timeframe, EntryType entryType, bool allowTrading)
   {
      _closeOnOpposite = false;
      _positionCap = NULL;
      _allowTrading = allowTrading;
      _longCondition = NULL;
      _shortCondition = NULL;
      _longMoneyManagementStrategy = NULL;
      _shortMoneyManagementStrategy = NULL;
      _netStopLoss = NULL;
      _signaler = signaler;
      _entryType = entryType;
      _timeframe = timeframe;
      _calculator = calculator;
      _tradingTime = NULL;
      _trailing = NULL;
      _magicNumber = 0;
   }

   ~TradingController()
   {
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         delete _breakeven[i];
      }
      delete _positionCap;
      delete _longMoneyManagementStrategy;
      delete _shortMoneyManagementStrategy;
      delete _longCondition;
      delete _shortCondition;
      delete _trailing;
      delete _calculator;
      delete _signaler;
      delete _tradingTime;
      delete _netStopLoss;
   }

   TradingController* SetSlippage(int slippage) { _slippage = slippage; return &this; }
   TradingController* SetBreakevenType(StopLimitType breakevenType, double breakevenValue) { _breakevenType = breakevenType; _breakevenValue = breakevenValue; return &this; }
   TradingController* SetCloseOnOpposite(bool closeOnOpposite) { _closeOnOpposite = closeOnOpposite; return &this; }
   TradingController* SetPositionCap(IPositionCapStrategy* positionCap) { _positionCap = positionCap; return &this; }
   TradingController* SetLongCondition(ICondition *condition) { _longCondition = condition; return &this; }
   TradingController* SetShortCondition(ICondition *condition) { _shortCondition = condition; return &this; }
   TradingController* SetTradingTime(TradingTime *tradingTime) { _tradingTime = tradingTime; return &this; }
   TradingController* SetTrailing(TrailingLogic *trailing) { _trailing = trailing; return &this; }
   TradingController* SetNetStopLossStrategy(INetStopLossStrategy *strategy) { _netStopLoss = strategy; return &this; }
   TradingController* SetLongMoneyManagementStrategy(IMoneyManagementStrategy *moneyManagementStrategy) { _longMoneyManagementStrategy = moneyManagementStrategy; return &this; }
   TradingController* SetShortMoneyManagementStrategy(IMoneyManagementStrategy *moneyManagementStrategy) { _shortMoneyManagementStrategy = moneyManagementStrategy; return &this; }
   TradingController* SetMagicNumber(int magicNumber) { _magicNumber = magicNumber; return &this; }

   void DoTrading()
   {
      _netStopLoss.DoLogic();
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         _breakeven[i].DoLogic();
      }
      _trailing.DoLogic();

      // if (IsExitBuyCondition() && _allowTrading)
      // {
      //    switch (LogicType)
      //    {
      //       case DirectLogic:
      //          {
      //             if (CloseTrades(POSITION_TYPE_BUY))
      //                _signaler.SendNotifications(EXIT_BUY_SIGNAL);
      //             break;
      //          }
      //       case ReversalLogic:
      //          {
      //             if (CloseTrades(POSITION_TYPE_SELL))
      //                _signaler.SendNotifications(EXIT_SELL_SIGNAL);
      //             break;
      //          }
      //    }
      // }
      // if (IsExitSellCondition() && _allowTrading)
      // {
      //    switch (LogicType)
      //    {
      //       case DirectLogic:
      //          if (CloseTrades(POSITION_TYPE_SELL))
      //             _signaler.SendNotifications(EXIT_SELL_SIGNAL);
      //          break;
      //       case ReversalLogic:
      //          if (CloseTrades(POSITION_TYPE_BUY))
      //             _signaler.SendNotifications(EXIT_BUY_SIGNAL);
      //          break;
      //    }
      // }
      
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      datetime current_time = iTime(symbol, _timeframe, 0);
      if (_tradingTime != NULL && !_tradingTime.IsTradingTime(current_time))
      {
         if (MandatoryClosing && _allowTrading)
         {
            TradesIterator it;
            it.WhenSymbol(symbol);
            it.WhenMagicNumber(_magicNumber);
            int closedCount = TradingCommands::CloseTrades(it);
            TradingCommands::DeleteOrders(_magicNumber, symbol);
            if (closedCount)
               _signaler.SendNotifications("Mandatory closing");
         }
         return;
      }

      int shift = 0;
      if (_entryType == EntryOnClose)
      {
         if (_lastEntry == current_time)
            return;
         _lastEntry = current_time;
         shift = 1;
      }
      datetime entryTyme = iTime(symbol, _timeframe, shift);
      if (_longCondition.IsPass(shift, entryTyme))
      {
         if (_allowTrading)
         {
            if (!_positionCap.IsLimitHit())
               GoLong(_longMoneyManagementStrategy, shift);
         }
         //_signaler.SendNotifications(ENTER_BUY_SIGNAL);
      }
      if (_shortCondition.IsPass(shift, entryTyme))
      {
         if (_allowTrading)
         {
            if (!_positionCap.IsLimitHit())
               GoShort(_shortMoneyManagementStrategy, shift);
         }
         //_signaler.SendNotifications(ENTER_SELL_SIGNAL);
      }
   }
private:
   ulong GoLong(IMoneyManagementStrategy *moneyManagementStrategy, const int period)
   {
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      if (_closeOnOpposite)
      {
         TradesIterator it();
         it.WhenMagicNumber(_magicNumber);
         it.WhenSide(SellSide);
         it.WhenSymbol(symbol);
         TradingCommands::CloseTrades(it);
      }

      double ask = _calculator.GetSymbolInfo().GetAsk();
      double amount = 0.0;
      double stopLoss = 0.0;
      double takeProfit = 0.0;
      moneyManagementStrategy.Get(period, ask, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return 0;
      
      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      ulong order = orderBuilder
         .SetStopLoss(stopLoss)
         .SetSide(BuySide)
         .SetInstrument(symbol)
         .SetAmount(amount)
         .SetSlippage(_slippage)
         .SetMagicNumber(_magicNumber)
         .SetTakeProfit(takeProfit)
         .SetComment("")
         .Execute(error);
      delete orderBuilder;
      if (order != 0)
      {
         _trailing.Create(order, stopLoss, true);
         if (_breakevenType != StopLimitDoNotUse)
            CreateBreakeven(order);
      }
      else
         Print("Failed to open long position: " + error);
      return order;
   }

   ulong GoShort(IMoneyManagementStrategy *moneyManagementStrategy, const int period)
   {
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      if (_closeOnOpposite)
      {
         TradesIterator it();
         it.WhenMagicNumber(_magicNumber);
         it.WhenSide(BuySide);
         it.WhenSymbol(symbol);
         TradingCommands::CloseTrades(it);
      }

      double bid = _calculator.GetSymbolInfo().GetBid();
      double amount = 0.0;
      double stopLoss = 0.0;
      double takeProfit = 0.0;
      moneyManagementStrategy.Get(period, bid, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return 0;

      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      ulong order = orderBuilder
         .SetStopLoss(stopLoss)
         .SetSide(SellSide)
         .SetInstrument(symbol)
         .SetAmount(amount)
         .SetSlippage(_slippage)
         .SetMagicNumber(_magicNumber)
         .SetTakeProfit(takeProfit)
         .SetComment("")
         .Execute(error);
      delete orderBuilder;
      if (order != 0)
      {
         _trailing.Create(order, stopLoss, false);
         if (_breakevenType != StopLimitDoNotUse)
            CreateBreakeven(order);
      }
      else
         Print("Failed to open short position: " + error);
      return order;
   }

   void CreateBreakeven(const ulong order)
   {
      if (!OrderSelect(order))
         return;
      ulong orderType = OrderGetInteger(ORDER_TYPE);
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      bool isBuy = orderType == ORDER_TYPE_BUY;
      double basePrice = isBuy ? _calculator.GetSymbolInfo().GetAsk() : _calculator.GetSymbolInfo().GetBid();
      double target = 0;
      double targetValue = isBuy 
         ? basePrice - target * _calculator.GetSymbolInfo().GetPipSize()
         : basePrice + target * _calculator.GetSymbolInfo().GetPipSize();
      double triggerValue = _calculator.CalculateTakeProfit(isBuy, _breakevenValue, _breakevenType, OrderGetDouble(ORDER_VOLUME_CURRENT), basePrice);

      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         if (_breakeven[i].SetOrder(order, triggerValue, targetValue))
         {
            return;
         }
      }

      ArrayResize(_breakeven, i_count + 1);
      _breakeven[i_count] = new BreakevenController();
      _breakeven[i_count].SetOrder(order, triggerValue, targetValue);
   }
};

class BreakoutLongCondition : public ACondition
{
   int handle;
public:
   BreakoutLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      handle = iCustom(symbol, timeframe, "Breakout", PeriodBegin, PeriodEnd, BoxEnd);
   }
   ~BreakoutLongCondition()
   {
      IndicatorRelease(handle);
   }

   bool IsPass(const int period, const datetime date)
   {
      double BrU[1];
      if (CopyBuffer(handle, 2, period, 1, BrU) != 1)
      {
         return false;
      }
      return iClose(_symbol, _timeframe, period) > BrU[0];
   }
};

class BreakoutShortCondition : public ACondition
{
   int handle;
public:
   BreakoutShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      handle = iCustom(symbol, timeframe, "Breakout", PeriodBegin, PeriodEnd, BoxEnd);
   }
   ~BreakoutShortCondition()
   {
      IndicatorRelease(handle);
   }

   bool IsPass(const int period, const datetime date)
   {
      double BrU[1];
      if (CopyBuffer(handle, 3, period, 1, BrU) != 1)
      {
         return false;
      }
      return iClose(_symbol, _timeframe, period) < BrU[0];
   }
};

class ZZUpCondition : public ACondition
{
   int handle;
public:
   ZZUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      handle = iCustom(symbol, timeframe, "Examples/ZigZag", ZZLength, ZZPatternLength, ZZPatternWidth);
   }
   ~ZZUpCondition()
   {
      IndicatorRelease(handle);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      for (int i = 0; i < ZZPatternLength; ++i)
      {
         double BrU[1];
         if (CopyBuffer(handle, 0, period + i, 1, BrU) != 1)
         {
            return false;
         }
         if (BrU[0] != EMPTY_VALUE && BrU[0] != 0)
         {
            return BrU[0] <= iClose(_symbol, _timeframe, period + i);
         }
      }
      
      return false;
   }
};

class ZZDownCondition : public ACondition
{
   int handle;
public:
   ZZDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      handle = iCustom(symbol, timeframe, "Examples/ZigZag", ZZLength, ZZPatternLength, ZZPatternWidth);
   }
   ~ZZDownCondition()
   {
      IndicatorRelease(handle);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      for (int i = 0; i < ZZPatternLength; ++i)
      {
         double BrU[1];
         if (CopyBuffer(handle, 0, period + i, 1, BrU) != 1)
         {
            return false;
         }
         if (BrU[0] != EMPTY_VALUE && BrU[0] != 0)
         {
            return BrU[0] >= iClose(_symbol, _timeframe, period + i);
         }
      }
      return false;
   }
};

class RSIAboveLevelCondition : public ACondition
{
   double _level;
   int handle;
public:
   RSIAboveLevelCondition(const string symbol, ENUM_TIMEFRAMES timeframe, int rsiPeriod, double level)
      :ACondition(symbol, timeframe)
   {
      handle = iRSI(symbol, timeframe, rsiPeriod, PRICE_CLOSE); 
      _level = level;
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double val[1];
      if (CopyBuffer(handle, 0, period, 1, val) != 1)
      {
         return false;
      }
      return val[0] > _level;
   }
};

class RSIBelowLevelCondition : public ACondition
{
   double _level;
   int handle;
public:
   RSIBelowLevelCondition(const string symbol, ENUM_TIMEFRAMES timeframe, int rsiPeriod, double level)
      :ACondition(symbol, timeframe)
   {
      handle = iRSI(symbol, timeframe, rsiPeriod, PRICE_CLOSE); 
      _level = level;
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double val[1];
      if (CopyBuffer(handle, 0, period, 1, val) != 1)
      {
         return false;
      }
      return val[0] < _level;
   }
};

ICondition* CreateLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }

   AndCondition* condition = new AndCondition();
   condition.Add(new BreakoutLongCondition(symbol, timeframe), false);
   condition.Add(new ZZUpCondition(symbol, timeframe), false);
   condition.Add(new RSIAboveLevelCondition(symbol, timeframe, RSI_Length, RSI_Level), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else 
      return (ICondition*) condition;
   #endif
}

ICondition* CreateShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == LongSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }

   AndCondition* condition = new AndCondition();
   condition.Add(new BreakoutShortCondition(symbol, timeframe), false);
   condition.Add(new ZZDownCondition(symbol, timeframe), false);
   condition.Add(new RSIBelowLevelCondition(symbol, timeframe, RSI_Length, RSI_Level), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else 
      return (ICondition*) condition;
   #endif
}

TradingController* controllers[];

TradingController* CreateController(const string symbol, ENUM_TIMEFRAMES tf, string &error)
{
   TradingTime *tradingTime = new TradingTime();
   if (!tradingTime.Init(StartTime, EndTime, error))
   {
      delete tradingTime;
      return NULL;
   }
   if (LimitWeeklyTime && !tradingTime.SetWeekTradingTime(WeekStartDay, WeekStartTime, WeekStopDay, WeekStopTime, error))
   {
      delete tradingTime;
      return NULL;
   }
   
   TradingCalculator *tradeCalculator = new TradingCalculator(symbol);
   Signaler *signaler = new Signaler(symbol, tf);
   TradingController* tradingController = new TradingController(signaler, tradeCalculator, tf, entry_type, allow_trading);
   tradingController.SetTradingTime(tradingTime)
      .SetCloseOnOpposite(close_on_opposite)
      .SetSlippage(slippage_points)
      .SetMagicNumber(magic_number)
      .SetBreakevenType(breakeven_type, breakeven_value)
      .SetTrailing(new TrailingLogic(tradeCalculator, trailing_type, TrailingStep, 0, tf))
      .SetNetStopLossStrategy(new NoNetStopLossStrategy());
   IPositionCapStrategy* positionCap = use_position_cap 
      ? (IPositionCapStrategy*)new PositionCapStrategy(max_positions)
      : (IPositionCapStrategy*)new NoPositionCapStrategy();
   tradingController.SetPositionCap(positionCap);

   ICondition *longCondition = CreateLongCondition(symbol, tf);
   ICondition *shortCondition = CreateShortCondition(symbol, tf);
   IMoneyManagementStrategy *longMoneyManagement = new LongMoneyManagementStrategy(tradeCalculator
      , lot_type, lot_size, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value);
   IMoneyManagementStrategy *shortMoneyManagement = new ShortMoneyManagementStrategy(tradeCalculator
      , lot_type, lot_size, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value);
   if (LogicType == DirectLogic)
   {
      tradingController.SetLongCondition(longCondition);
      tradingController.SetShortCondition(shortCondition);
      tradingController.SetLongMoneyManagementStrategy(longMoneyManagement);
      tradingController.SetShortMoneyManagementStrategy(shortMoneyManagement);
   }
   else
   {
      tradingController.SetLongCondition(shortCondition);
      tradingController.SetShortCondition(longCondition);
      tradingController.SetLongMoneyManagementStrategy(shortMoneyManagement);
      tradingController.SetShortMoneyManagementStrategy(longMoneyManagement);
   }
   
   return tradingController;
}

void split(string& arr[], string str, string sym) 
{
   ArrayResize(arr, 0);
   int len = StringLen(str);
   for (int i=0; i < len;)
   {
      int pos = StringFind(str, sym, i);
      if (pos == -1)
         pos = len;

      string item = StringSubstr(str, i, pos-i);
      StringTrimLeft(item);
      StringTrimRight(item);

      int size = ArraySize(arr);
      ArrayResize(arr, size+1);
      arr[size] = item;

      i = pos+1;
   }
}

int OnInit()
{
   string error;
   string sym_arr[];
   if (symbols != "")
   {
      split(sym_arr, symbols, ",");
   }
   else
   {
      ArrayResize(sym_arr, 1);
      sym_arr[0] = _Symbol;
   }
   int sym_count = ArraySize(sym_arr);
   for (int i = 0; i < sym_count; i++)
   {
      string symbol = sym_arr[i];
      TradingController* controller = CreateController(symbol, (ENUM_TIMEFRAMES)_Period, error);
      if (controller == NULL)
      {
         Print(error);
         return INIT_FAILED;
      }
      int controllersCount = ArraySize(controllers);
      ArrayResize(controllers, controllersCount + 1);
      controllers[controllersCount] = controller;
   }
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   for (int i = 0; i < ArraySize(controllers); ++i)
   {
      delete controllers[i];
   }
}

void OnTick()
{
   for (int i = 0; i < ArraySize(controllers); ++i)
   {
      controllers[i].DoTrading();
   }
}