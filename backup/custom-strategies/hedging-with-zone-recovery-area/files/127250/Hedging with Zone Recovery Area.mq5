// More information about this indicator can be found at:
// http://fxcodebase.com/

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

#include <Trade\Trade.mqh>

enum OrderSide
{
   BuySide,
   SellSide
};

bool BTCAccount = false;

CTrade tradeManager;

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

enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $
   StopLimitRiskReward // Set in % of stop loss
};

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
   PositionSizeMoneyPerPip // $ per pip
};

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
input int area = 35; // Zone recovery area
input int tp = 80; // Take profit

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
input double amount_multiplicator = 2; // Amount multiplicator

// Symbol info v.1.1
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

// Trades iterator v 1.1
enum CompareType
{
   CompareLessThan
};

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
public:
   TradesIterator()
   {
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useProfit = false;
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
   double GetOpenPrice() { return PositionGetDouble(POSITION_PRICE_OPEN); }
   double GetStopLoss() { return PositionGetDouble(POSITION_SL); }
   double GetTakeProfit() { return PositionGetDouble(POSITION_TP); }
   ENUM_POSITION_TYPE GetPositionType() { return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); }

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
      return true;
   }
};

// Trading calculator v.1.3
class TradingCalculator
{
   InstrumentInfo *_symbolInfo;
public:
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

// Conditions v.1.1
interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

class DisabledCondition : public ICondition
{
public:
   virtual bool IsPass(const int period) { return false; }
};

class AndCondition : public ICondition
{
   ICondition *_conditions[];
public:
   ~AndCondition()
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
         if (!_conditions[i].IsPass(period))
            return false;
      }
      return true;
   }
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

// Money management strategy v.1.1
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

// Stream v.1.2
interface IStream
{
public:
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

class AStream : public IStream
{
protected:
   InstrumentInfo *_symbolInfo;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;

   AStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe)
   {
      _shift = 0.0;
      _symbolInfo = symbolInfo;
      _timeframe = timeframe;
   }

   ~AStream()
   {
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbolInfo.GetSymbol(), _timeframe);
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

// Action v1.0

#ifndef IAction_IMP

interface IAction
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool DoAction() = 0;
};
#define IAction_IMP
#endif

// AAction v1.0

#ifndef AAction_IMP

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

#define AAction_IMP

#endif

// Closed trades iterator v 1.0
#ifndef ClosedTradesIterator_IMP
class ClosedTradesIterator
{
   int _lastIndex;
   int _total;
   ulong _currentTicket;
public:
   ClosedTradesIterator()
   {
      _lastIndex = INT_MIN;
   }
   
   ulong GetTicket() { return _currentTicket; }
   ENUM_ORDER_TYPE GetPositionType() { return (ENUM_ORDER_TYPE)HistoryOrderGetInteger(_currentTicket, ORDER_TYPE); }

   int Count()
   {
      int count = 0;
      for (int i = 0; i < Total(); i--)
      {
         _currentTicket = HistoryDealGetTicket(i);
         if (PassFilter(i))
         {
            count++;
         }
      }
      return count;
   }

   bool Next()
   {
      _total = Total();
      if (_lastIndex == INT_MIN)
         _lastIndex = 0;
      else
         ++_lastIndex;
      while (_lastIndex != _total)
      {
         _total = Total();
         _currentTicket = HistoryDealGetTicket(_lastIndex);
         if (PassFilter(_lastIndex))
            return true;
         ++_lastIndex;
      }
      return false;
   }

   bool Any()
   {
      for (int i = 0; i < Total(); i++)
      {
         _currentTicket = HistoryDealGetTicket(i);
         if (PassFilter(i))
         {
            return true;
         }
      }
      return false;
   }

private:
   int Total()
   {
      bool res = HistorySelect(0, TimeCurrent());
      return HistoryDealsTotal();
   }

   bool PassFilter(const int index)
   {
      long entry = HistoryDealGetInteger(_currentTicket, DEAL_ENTRY);
      if (entry != DEAL_ENTRY_OUT)
         return false;
      return true;
   }
};
#define ClosedTradesIterator_IMP
#endif

// Trades monitor v.1.0
#ifndef TradingMonitor_IMP

#define TRADING_MONITOR_ORDER 0
#define TRADING_MONITOR_TRADE 1

class TradingMonitor
{
   ulong active_ticket[1000];
   double active_type[1000];
   double active_price[1000];
   double active_stoploss[1000];
   double active_takeprofit[1000];
   int active_order_type[1000];
   int active_total;
   IAction* _onClosedTrade;
   IAction* _onNewTrade;
   bool _firstStart;
   ulong _closedTrades[];
public:
   TradingMonitor()
   {
      active_total = 0;
      _onClosedTrade = NULL;
      _onNewTrade = NULL;
      _firstStart = true;
   }

   ~TradingMonitor()
   {
      if (_onClosedTrade != NULL)
         _onClosedTrade.Release();
      if (_onNewTrade != NULL)
         _onNewTrade.Release();
   }

   void SetOnClosedTrade(IAction* action)
   {
      if (_onClosedTrade != NULL)
         _onClosedTrade.Release();
      _onClosedTrade = action;
      if (_onClosedTrade != NULL)
         _onClosedTrade.AddRef();
   }

   void SetOnNewTrade(IAction* action)
   {
      if (_onNewTrade != NULL)
         _onNewTrade.Release();
      _onNewTrade = action;
      if (_onNewTrade != NULL)
         _onNewTrade.AddRef();
   }

   void DoWork()
   {
      if (_firstStart)
      {
         updateActiveOrders();
         ClosedTradesIterator closedTrades;
         while (closedTrades.Next())
         {
            ulong ticket = closedTrades.GetTicket();
            int size = ArraySize(_closedTrades);
            ArrayResize(_closedTrades, size + 1);
            _closedTrades[size] = ticket;
            ++active_total;
         }
         _firstStart = false;
         return;
      }
      bool changed = false;
      OrdersIterator orders;
      while (orders.Next())
      {
         ulong ticket = orders.GetTicket();
         int index = getOrderCacheIndex(ticket, TRADING_MONITOR_ORDER);
         if (index == -1)
         {
            changed = true;
            OnNewOrder();
         }
         else
         {
            if (orders.GetOpenPrice() != active_price[index] ||
                  orders.GetStopLoss() != active_stoploss[index] ||
                  orders.GetTakeProfit() != active_takeprofit[index] ||
                  orders.GetType() != active_type[index])
            {
               // already active order was changed
               changed = true;
               //messageChangedOrder(index);
            }
         }
      }
      TradesIterator it;
      while (it.Next())
      {
         ulong ticket = it.GetTicket();
         int index = getOrderCacheIndex(ticket, TRADING_MONITOR_TRADE);
         if (index == -1)
         {
            changed = true;
            if (_onNewTrade != NULL)
               // ignore result of DoAction
               _onNewTrade.DoAction();
         }
         else
         {
            if (it.GetStopLoss() != active_stoploss[index] ||
                  it.GetTakeProfit() != active_takeprofit[index])
            {
               // already active order was changed
               changed = true;
               //messageChangedOrder(index);
            }
         }
      }

      ExecuteClosedTradesAction();

      if (changed)
         updateActiveOrders();
   }
private:
   void ExecuteClosedTradesAction()
   {
      if (_onClosedTrade == NULL)
         return ;

      ClosedTradesIterator closedTrades;
      while (closedTrades.Next())
      {
         ulong ticket = closedTrades.GetTicket();
         if (!ClosedTradeHandled(ticket))
         {
            // ignore result of DoAction
            _onClosedTrade.DoAction();
            int size = ArraySize(_closedTrades);
            ArrayResize(_closedTrades, size + 1);
            _closedTrades[size] = ticket;
         }
      }
   }

   bool ClosedTradeHandled(ulong ticket)
   {
      int size = ArraySize(_closedTrades);
      for (int i = 0; i < size; ++i)
      {
         if (_closedTrades[i] == ticket)
            return true;
      }
      return false;
   }

   int getOrderCacheIndex(const ulong ticket, int type)
   {
      for (int i = 0; i < active_total; i++)
      {
         if (active_ticket[i] == ticket && active_order_type[i] == type)
            return i;
      }
      return -1;
   }

   void updateActiveOrders()
   {
      active_total = 0;
      OrdersIterator orders;
      while (orders.Next())
      {
         active_ticket[active_total] = orders.GetTicket();
         active_type[active_total] = orders.GetType();
         active_price[active_total] = orders.GetOpenPrice();
         active_stoploss[active_total] = orders.GetStopLoss();
         active_takeprofit[active_total] = orders.GetTakeProfit();
         active_order_type[active_total] = TRADING_MONITOR_ORDER;
         ++active_total;
      }

      TradesIterator trades;
      while (trades.Next())
      {
         active_ticket[active_total] = trades.GetTicket();
         active_stoploss[active_total] = trades.GetStopLoss();
         active_takeprofit[active_total] = trades.GetTakeProfit();
         active_order_type[active_total] = TRADING_MONITOR_TRADE;
         ++active_total;
      }
   }

   void OnNewOrder()
   {
      
   }
};

#define TradingMonitor_IMP

#endif

// Trading commands v.1.1
class TradingCommands
{
public:
   static bool MoveStop(const ulong ticket, const double stopLoss, string &error)
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

   static void DeleteOrders(OrdersIterator& it)
   {
      while (it.Next())
      {
         tradeManager.OrderDelete(it.GetTicket());
      }
   }

   static int CloseTrades(TradesIterator &it)
   {
      int close = 0;
      while (it.Next())
      {
         switch (it.GetPositionType())
         {
            case POSITION_TYPE_BUY:
               {
                  if (!tradeManager.PositionClose(it.GetTicket())) 
                     Print("LastError = ", GetLastError());
                  else
                     ++close;
               }
               break;
            case POSITION_TYPE_SELL:
               {
                  if (!tradeManager.PositionClose(it.GetTicket())) 
                     Print("LastError = ", GetLastError());
                  else
                     ++close;
               }
               break;
         }
      }
      return close;
   }
};

// Market order builder
// v.1.2
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
public:
   MarketOrderBuilder *SetComment(const string comment) { _comment = comment; return &this; }
   MarketOrderBuilder *SetSide(const OrderSide orderSide) { _orderSide = orderSide; return &this; }
   MarketOrderBuilder *SetInstrument(const string instrument) { _instrument = instrument; return &this; }
   MarketOrderBuilder *SetAmount(const double amount) { _amount = amount; return &this; }
   MarketOrderBuilder *SetSlippage(const int slippage) { _slippage = slippage; return &this; }
   MarketOrderBuilder *SetStopLoss(const double stop) { _stop = stop; return &this; }
   MarketOrderBuilder *SetTakeProfit(const double limit) { _limit = limit; return &this; }
   MarketOrderBuilder *SetMagicNumber(const int magicNumber) { _magicNumber = magicNumber; return &this; }
   
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
         case SYMBOL_TRADE_MODE_LONGONLY:
            if (_orderSide == SellSide)
            {
               error = "Only long are allowed";
               return 0;
            }
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
      if (BTCAccount)
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
      }
      return result.order;
   }
};

// Order builder
// v.1.3

class OrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stop;
   double _limit;
   double _stopLimit;
   int _magicNumber;
   datetime _expiration;
   string _comment;
public:
   OrderBuilder()
   {
      _comment = "";
      _expiration = 0;
      _stopLimit = 0;
      _orderSide = BuySide;
      _instrument = "";
      _amount = 0;
      _rate = 0;
      _slippage = 0;
      _stop = 0;
      _limit = 0;
      _stopLimit = 0;
      _magicNumber = 0;
   }
   
   OrderBuilder *SetExpiration(const datetime expiration)
   {
      _expiration = expiration;
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
   
   OrderBuilder *SetStopLimit(const double stopLimit)
   {
      _stopLimit = stopLimit;
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
   
   OrderBuilder *SetStop(const double stop)
   {
      _stop = stop;
      return &this;
   }
   
   OrderBuilder *SetLimit(const double limit)
   {
      _limit = limit;
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
   
   ulong Execute(string &error)
   {
      InstrumentInfo instrument(_instrument);
      MqlTradeRequest request;
      ZeroMemory(request);
      double tickSize = SymbolInfoDouble(_instrument, SYMBOL_TRADE_TICK_SIZE);
      if (_orderSide == BuySide)
      {
         double ask = SymbolInfoDouble(_instrument, SYMBOL_ASK);
         if (_rate > ask)
         {
            request.type = _stopLimit == 0.0 ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_STOP_LIMIT;
            request.stoplimit = MathRound(_stopLimit / tickSize) * tickSize;
         }
         else
            request.type = ORDER_TYPE_BUY_LIMIT;
      }
      else
      {
         double bid = SymbolInfoDouble(_instrument, SYMBOL_BID);
         if (_rate < bid)
         {
            request.type = _stopLimit == 0.0 ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_STOP_LIMIT;
            request.stoplimit = MathRound(_stopLimit / tickSize) * tickSize;
         }
         else
            request.type = ORDER_TYPE_SELL_LIMIT;
      }
      int digits = (int)SymbolInfoInteger(_instrument, SYMBOL_DIGITS);
      request.action = TRADE_ACTION_PENDING;
      request.symbol = _instrument;
      request.volume = _amount;
      request.price = instrument.RoundRate(_rate);
      request.deviation = _slippage;
      if (_stop != 0.0)
         request.sl = instrument.RoundRate(_stop);
      if (_limit != 0.0)
         request.tp = instrument.RoundRate(_limit);
      request.magic = _magicNumber;
      if (_comment != "")
         request.comment = _comment;
      if (_expiration != 0)
      {
         request.type_time = ORDER_TIME_SPECIFIED;
         request.expiration = _expiration;
      }
      MqlTradeResult result;
      ZeroMemory(result);
      bool res = OrderSend(request, result);
      if (!res)
      {
         switch (result.retcode)
         {
            case TRADE_RETCODE_LIMIT_VOLUME:
               error = "The volume of orders and positions for the symbol has reached the limit";
               return 0;
            case TRADE_RETCODE_INVALID_PRICE:
               error = "Invalid price in the request";
               return 0;
            case TRADE_RETCODE_INVALID_STOPS:
               {
                  int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  double price = request.stoplimit > 0.0 ? request.stoplimit : request.price;
                  if (request.sl != 0.0)
                  {
                     double diff = MathRound((price - request.sl) / point);
                     if (_orderSide == BuySide)
                     {
                        if (diff <= 0)
                        {
                           error = "The stop loss should be lower than the rate for the buy order";
                           return 0;
                        }
                     }
                     else if (diff >= 0)
                     {
                        error = "The stop loss should be higher than the rate for the sell order";
                        return 0;
                     }
                     if (MathAbs(diff) < minStopDistancePoints)
                     {
                        error = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                        return 0;
                     }
                  }
                  if (request.tp != 0.0)
                  {
                     double diff = MathRound((price - request.tp) / point);
                     if (_orderSide == BuySide)
                     {
                        if (diff >= 0)
                        {
                           error = "The take profit should be lower than the rate for the buy order";
                           return 0;
                        }
                     }
                     else if (diff <= 0)
                     {
                        error = "The take profit should be higher than the rate for the sell order";
                        return 0;
                     }
                     if (MathAbs(diff) < minStopDistancePoints)
                     {
                        error = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                        return 0;
                     }
                  }
                  error = "Invalid stops in the request";
               }
               return 0;
         }
         int error = GetLastError();
         switch (error)
         {
            case 4109:
               error = "Trading is not allowed";
               break;
            case 130:
               error = "Failed to create order: stoploss/takeprofit is too close";
               break;
            case ERR_TRADE_SEND_FAILED:
               error = "Trade request sending failed";
               break;
            default:
               error = "Failed to create order: " + IntegerToString(error);
               break;
         }
      }
      return result.order;
   }
};

class OnClosedTradeAction : public AAction
{
public:
   virtual bool DoAction()
   {
      OrdersIterator orders;
      orders.WhenSymbol(PositionGetString(POSITION_SYMBOL));
      TradingCommands::DeleteOrders(orders);
      TradesIterator trades;
      trades.WhenSymbol(PositionGetString(POSITION_SYMBOL));
      TradingCommands::CloseTrades(trades);
      return true;
   }
};
double last_amount;

class OnNewTradeAction : public AAction
{
   double original_rate;
   double opposite_rate;
   double buy_stop;
   double sell_stop;
public:
   OnNewTradeAction()
   {
      original_rate = 0;
      opposite_rate = 0;
   }

   virtual bool DoAction()
   {
      string symbol = PositionGetString(POSITION_SYMBOL);
      TradingCalculator calc(symbol);
      InstrumentInfo instrument(symbol);
      double openRate = PositionGetDouble(POSITION_PRICE_OPEN);
      ENUM_POSITION_TYPE side = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if (original_rate == 0)
      {
         original_rate = openRate;
         if (side == POSITION_TYPE_BUY)
         {
            opposite_rate = original_rate - area * instrument.GetPipSize();
            buy_stop = opposite_rate - tp * instrument.GetPipSize();
            sell_stop = original_rate + tp * instrument.GetPipSize();
         }
         else
         {
            opposite_rate = original_rate + area * instrument.GetPipSize();
            sell_stop = opposite_rate + tp * instrument.GetPipSize();
            buy_stop = original_rate - tp * instrument.GetPipSize();
         }
      }
      double rate = MathAbs(openRate - original_rate) < MathAbs(openRate - opposite_rate) ? opposite_rate : original_rate;
      TradesIterator trades;
      trades.WhenSymbol(symbol);
      double total_profit = area;
      while (trades.Next())
      {
         int mult = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == side ? -1 : 1;
         double open = PositionGetDouble(POSITION_PRICE_OPEN);
         double stop = side == POSITION_TYPE_BUY ? buy_stop : sell_stop;
         double pl = side == POSITION_TYPE_BUY ? (open - stop) : (stop - open);
         total_profit += (pl * PositionGetDouble(POSITION_VOLUME) * mult) / instrument.GetPipSize();
      }
      double order_amount = MathMax(instrument.GetMinVolume(), calc.NormilizeLots(-total_profit / tp * last_amount));
      last_amount = last_amount * amount_multiplicator;

      double takeProfit = calc.CalculateTakeProfit(side != POSITION_TYPE_BUY, tp, StopLimitPips, order_amount, rate);
      OrderBuilder order;
      string error;
      ulong ticket = order.SetSide(side == POSITION_TYPE_BUY ? SellSide : BuySide)
         .SetInstrument(symbol)
         .SetRate(rate)
         .SetAmount(order_amount)
         .SetMagicNumber(magic_number)
         .SetLimit(takeProfit)
         .Execute(error);
      if (ticket == 0)
      {
         Print(error);
      }
      return true;
   }
};

TradingMonitor tradingMonitor;

int OnInit()
{
   IAction* onClosedTradeAction = new OnClosedTradeAction();
   tradingMonitor.SetOnClosedTrade(onClosedTradeAction);
   onClosedTradeAction.Release();

   IAction* onNewTadeAction = new OnNewTradeAction();
   tradingMonitor.SetOnNewTrade(onNewTadeAction);
   onNewTadeAction.Release();

   last_amount = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   tradingMonitor.DoWork();
}