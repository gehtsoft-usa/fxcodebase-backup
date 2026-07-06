// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71147

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |   
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
//+------------------------------------------------------------------------+
//+------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict

input double step = 0.02; // Step
input double maximum = 0.2; // Maximum
input double stop_distance = 10; // Distance between real and virtual stops

// Action on condition logic v1.0

// Action on condition v1.0

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
      if (_action != NULL)
         _action.Release();
      if (_condition != NULL)
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

   void DoLogic(const int period, const datetime date)
   {
      if (_finished)
         return;

      if ( _condition.IsPass(period, date))
      {
         if (_action.DoAction())
            _finished = true;
      }
   }
};

#endif

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

   void DoLogic(const int period, const datetime date)
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
// Trades monitor v.1.2

#ifndef TradingMonitor_IMP
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
// Orders iterator v 1.9


// Order side v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide,
   SellSide
};

#endif

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

// Ticket target interface v1.0
class ITicketTarget
{
public:
   virtual void SetTicket(ulong ticket) = 0;
};

#define TRADING_MONITOR_ORDER 0
#define TRADING_MONITOR_TRADE 1
#define TRADING_MONITOR_CLOSED_TRADE 2

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
   IAction* _onTradeChanged;
   ITicketTarget* _ticketTarget;
public:
   TradingMonitor()
   {
      active_total = 0;
      _onClosedTrade = NULL;
      _onNewTrade = NULL;
      _onTradeChanged = NULL;
      _ticketTarget = NULL;
   }

   ~TradingMonitor()
   {
      if (_onClosedTrade != NULL)
         _onClosedTrade.Release();
      if (_onNewTrade != NULL)
         _onNewTrade.Release();
      if (_onTradeChanged != NULL)
         _onTradeChanged.Release();
   }

   void SetOnClosedTrade(IAction* action, ITicketTarget* ticketTarget)
   {
      if (_onClosedTrade != NULL)
         _onClosedTrade.Release();
      _onClosedTrade = action;
      if (_onClosedTrade != NULL)
         _onClosedTrade.AddRef();
      _ticketTarget = ticketTarget;
   }

   void SetOnNewTrade(IAction* action)
   {
      if (_onNewTrade != NULL)
         _onNewTrade.Release();
      _onNewTrade = action;
      if (_onNewTrade != NULL)
         _onNewTrade.AddRef();
   }

   void SetOnTradeChanged(IAction* action)
   {
      if (_onTradeChanged != NULL)
         _onTradeChanged.Release();
      _onTradeChanged = action;
      if (_onTradeChanged != NULL)
         _onTradeChanged.AddRef();
   }

   void DoWork()
   {
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
               if (_onTradeChanged != NULL)
                  // ignore result of DoAction
                  _onTradeChanged.DoAction();
               changed = true;
            }
         }
      }

      ClosedTradesIterator closedTrades;
      while (closedTrades.Next())
      {
         ulong ticket = closedTrades.GetTicket();
         int index = getOrderCacheIndex(ticket, TRADING_MONITOR_CLOSED_TRADE);
         if (index == -1)
         {
            changed = true;
            if (_onClosedTrade != NULL)
            {
               _ticketTarget.SetTicket(ticket);
               // ignore result of DoAction
               _onClosedTrade.DoAction();
            }
         }
      }

      if (changed)
         updateActiveOrders();
   }
private:
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

      ClosedTradesIterator closedTrades;
      while (closedTrades.Next())
      {
         active_ticket[active_total] = closedTrades.GetTicket();
         active_order_type[active_total] = TRADING_MONITOR_CLOSED_TRADE;
         ++active_total;
      }
   }

   void OnNewOrder()
   {
      
   }
};

#define TradingMonitor_IMP

#endif
// Profit in range condition v1.0

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
// Trade v1.0

#ifndef Trade_IMP
#define Trade_IMP

class ITrade
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool Select() = 0;
   virtual ulong GetTicket() = 0;
};

class TradeByTicketId : public ITrade
{
   ulong _ticket;
   int _references;
public:
   TradeByTicketId(ulong ticket)
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
      return PositionSelectByTicket(_ticket);
   }

   virtual ulong GetTicket()
   {
      return _ticket;
   }
};

#endif
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

#ifndef ProfitInRangeCondition_IMP
#define ProfitInRangeCondition_IMP

class ProfitInRangeCondition : public AConditionBase
{
   ITrade* _trade;
   InstrumentInfo* _instrument;
   double _minProfit;
   double _maxProfit;
public:
   ProfitInRangeCondition(ITrade* trade, double minProfit, double maxProfit)
   {
      _trade = trade;
      _trade.AddRef();
      _minProfit = minProfit;
      _maxProfit = maxProfit;
      _instrument = NULL;
   }

   ~ProfitInRangeCondition()
   {
      _trade.Release();
      if (_instrument != NULL)
         delete _instrument;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!_trade.Select())
         return true;
      
      string symbol = PositionGetString(POSITION_SYMBOL);
      if (_instrument == NULL)
         _instrument = new InstrumentInfo(symbol);

      double closePrice = iClose(symbol, PERIOD_M1, 0);
      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      if (positionType == POSITION_TYPE_BUY)
      {
         double profit = (closePrice - openPrice) / _instrument.GetPipSize();
         return profit >= _minProfit && profit <= _maxProfit;
      }
      else
      {
         double profit = (openPrice - closePrice) / _instrument.GetPipSize();
         return profit >= _minProfit && profit <= _maxProfit;
      }
      return false;
   }
};

#endif

TradingMonitor tradingMonitor;
ActionOnConditionLogic* actions;
IAction* createTPSL;

// Create hidden take profit/stop loss controller action v1.0

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


// Not condition v1.0



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

   virtual bool IsPass(const int period, const datetime date)
   {
      return !_condition.IsPass(period, date);
   }
};
#endif

// Close trade action v1.0


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

#ifndef CloseTradeAction_IMP
#define CloseTradeAction_IMP

class CloseTradeAction : public AAction
{
   ITrade* _trade;
public:
   CloseTradeAction(ITrade* trade)
   {
      _trade = trade;
      _trade.AddRef();
   }

   ~CloseTradeAction()
   {
      _trade.Release();
   }

   virtual bool DoAction()
   {
      string error;
      return TradingCommands::CloseTrade(_trade.GetTicket(), error);
   }
};

#endif

#ifndef CreateHiddenTPSLControllerAction_IMP
#define CreateHiddenTPSLControllerAction_IMP

class CreateHiddenTPSLControllerAction : public AAction
{
   ActionOnConditionLogic* _actions;
public:
   CreateHiddenTPSLControllerAction(ActionOnConditionLogic* actions)
   {
      _actions = actions;
   }

   virtual bool DoAction()
   {
      TradeByTicketId* trade = new TradeByTicketId(PositionGetInteger(POSITION_TICKET));
      ICondition* inRangeCondition = new SarCondition(trade);
      ICondition* notInRangeCondition = new NotCondition(inRangeCondition);
      inRangeCondition.Release();
      CloseTradeAction* closeTrade = new CloseTradeAction(trade);
      _actions.AddActionOnCondition(closeTrade, notInRangeCondition);
      closeTrade.Release();
      notInRangeCondition.Release();
      trade.Release();
      return true;
   }
};

class SarCondition : public AConditionBase
{
   int sar;
   ITrade* _trade;
   InstrumentInfo* _instrument;
public:
   SarCondition(ITrade* trade)
   {
      _trade = trade;
      _trade.AddRef();
      _instrument = NULL;
      sar = 0;
   }

   ~SarCondition()
   {
      if (sar != 0)
      {
         IndicatorRelease(sar);
      }
      _trade.Release();
      if (_instrument != NULL)
         delete _instrument;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!_trade.Select())
         return true;
      
      string symbol = PositionGetString(POSITION_SYMBOL);
      if (_instrument == NULL)
      {
         _instrument = new InstrumentInfo(symbol);
         sar = iSAR(symbol, _Period, step, maximum);
      }
      double buffer[1];
      if (CopyBuffer(sar, 0, 0, 1, buffer) != 1)
      {
         return false;
      }

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      double pipSize = point * mult;

      double closePrice = iClose(symbol, PERIOD_M1, 0);
      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if (positionType == POSITION_TYPE_BUY)
      {
         string error;
         double newStop = sar - stop_distance * pipSize;
         if (PositionGetDouble(POSITION_SL) != newStop)
            TradingCommands::MoveSL(_trade.GetTicket(), newStop, error);
         return buffer[0] < closePrice;
      }
      else
      {
         string error;
         double newStop = sar + stop_distance * pipSize;
         if (PositionGetDouble(POSITION_SL) != newStop)
            TradingCommands::MoveSL(_trade.GetTicket(), newStop, error);
         return buffer[0] > closePrice;
      }
      return false;
   }
};

#endif
int OnInit()
{
   actions = new ActionOnConditionLogic();
   createTPSL = new CreateHiddenTPSLControllerAction(actions);
   tradingMonitor.SetOnNewTrade(createTPSL);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete actions;
   createTPSL.Release();
   createTPSL = NULL;
}

void OnTick()
{
   tradingMonitor.DoWork();
   actions.DoLogic(0, 0);
}