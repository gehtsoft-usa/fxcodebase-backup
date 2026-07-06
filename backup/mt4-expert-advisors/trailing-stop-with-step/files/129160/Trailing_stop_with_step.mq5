// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=27&t=68991

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

input string GeneralSection = ""; // == General ==
input double price_1 = 0; // Price, pips #1
input double distance_1 = 20; // Distance, pips #1
input double price_2 = 7; // Price, pips #2
input double distance_2 = 5; // Distance, pips #2
input double price_3 = 20; // Price, pips #3
input double distance_3 = 10; // Distance, pips #3
input double price_4 = 50; // Price, pips #4
input double distance_4 = 10; // Distance, pips #4
input double price_5 = 100; // Price, pips #5
input double distance_5 = 5; // Distance, pips #5

// Action on condition logic v1.0

// Action on condition v1.0

// ICondition v1.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period) = 0;
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

   void DoLogic(const int period)
   {
      if (_finished)
         return;

      if ( _condition.IsPass(period))
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

   void DoLogic(const int period)
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         _controllers[i].DoLogic(period);
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
// Trailing action v1.0

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
// Trade v1.0

#ifndef Trade_IMP
#define Trade_IMP

class ITrade
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool Select() = 0;
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
};

#endif
// Trading commands v.2.0

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

#ifndef TrailingAction_IMP
#define TrailingAction_IMP

class TrailingPipsAction : public AAction
{
   ITrade* _trade;
   InstrumentInfo* _instrument;
   double _lastClose;
   double _distance;
public:
   TrailingPipsAction(ITrade* trade, double distance)
   {
      _distance = distance;
      _trade = trade;
      _trade.AddRef();
      _lastClose = 0;
      _instrument = NULL;
   }

   ~TrailingPipsAction()
   {
      _trade.Release();
      delete _instrument;
   }

   virtual bool DoAction()
   {
      if (!_trade.Select())
         return true;
      string symbol = PositionGetString(POSITION_SYMBOL);
      double closePrice = iClose(symbol, PERIOD_M1, 0);
      if (_lastClose == 0)
      {
         _lastClose = closePrice;
         _instrument = new InstrumentInfo(symbol);
      }

      double stopLoss = PositionGetDouble(POSITION_SL);
      double stopDistance = MathAbs(closePrice - stopLoss) / _instrument.GetPipSize();
      if (stopDistance <= _distance)
         return false;

      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ulong ticketId = PositionGetInteger(POSITION_TICKET);
      string error;
      if (positionType == POSITION_TYPE_BUY)
      {
         TradingCommands::MoveSL(ticketId, closePrice - _distance * _instrument.GetPipSize(), error);
      }
      else
      {
         TradingCommands::MoveSL(ticketId, closePrice + _distance * _instrument.GetPipSize(), error);
      }
      _lastClose = closePrice;
      
      return false;
   }
};
#endif

// Profit in range condition v1.0

// Condition base v1.0

#ifndef ACondition_IMP
#define ACondition_IMP


class ACondition : public ICondition
{
   int _references;
public:
   ACondition()
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



#ifndef ProfitInRangeCondition_IMP
#define ProfitInRangeCondition_IMP

class ProfitInRangeCondition : public ACondition
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

   virtual bool IsPass(const int period)
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
// Trades monitor v.1.1

#ifndef TradingMonitor_IMP


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

TradingMonitor _tradingMonitor;
ActionOnConditionLogic _actions;

class CreateTrailingAction : public AAction
{
public:
   virtual bool DoAction()
   {
      TradeByTicketId* trade = new TradeByTicketId(PositionGetInteger(POSITION_TICKET));

      TrailingPipsAction* action1 = new TrailingPipsAction(trade, distance_1);
      ProfitInRangeCondition* condition1 = new ProfitInRangeCondition(trade, -10000, price_1);
      _actions.AddActionOnCondition(action1, condition1);
      condition1.Release();
      action1.Release();

      TrailingPipsAction* action2 = new TrailingPipsAction(trade, distance_2);
      ProfitInRangeCondition* condition2 = new ProfitInRangeCondition(trade, price_1, price_2);
      _actions.AddActionOnCondition(action2, condition2);
      condition2.Release();
      action2.Release();

      TrailingPipsAction* action3 = new TrailingPipsAction(trade, distance_3);
      ProfitInRangeCondition* condition3 = new ProfitInRangeCondition(trade, price_2, price_3);
      _actions.AddActionOnCondition(action3, condition3);
      condition3.Release();
      action3.Release();

      TrailingPipsAction* action4 = new TrailingPipsAction(trade, distance_4);
      ProfitInRangeCondition* condition4 = new ProfitInRangeCondition(trade, price_3, price_4);
      _actions.AddActionOnCondition(action4, condition4);
      condition4.Release();
      action4.Release();

      TrailingPipsAction* action5 = new TrailingPipsAction(trade, distance_5);
      ProfitInRangeCondition* condition5 = new ProfitInRangeCondition(trade, price_4, price_5);
      _actions.AddActionOnCondition(action5, condition5);
      condition5.Release();
      action5.Release();
      
      trade.Release();

      return true;
   }
};

int OnInit()
{
   IAction* createTrailing = (IAction*) new CreateTrailingAction();
   _tradingMonitor.SetOnNewTrade(createTrailing);
   createTrailing.Release();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   _actions.DoLogic(0);
   _tradingMonitor.DoWork();
}
