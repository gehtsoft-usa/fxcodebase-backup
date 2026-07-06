// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70594

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
input string obj_id = "Triangle"; // Objects id

// Action on condition logic v2.0

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

// Market order builder v 2.3
// More templates and snippets on https://github.com/sibvic/mq4-templates
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

// No stop loss or take profit condition v1.0

// Abstract condition v1.1



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

// AAction v1.0


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
// Orders iterator v 1.12
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

enum CompareType
{
   CompareLessThan,
   CompareMoreThan
};



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

// Trade calculator v2.4
// More templates and snippets on https://github.com/sibvic/mq4-templates


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

// Open market order action v1.0

#ifndef OpenMarketOrderAction_IMP
#define OpenMarketOrderAction_IMP

class OpenMarketOrderAction : public AAction
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _amount;
   PositionSizeType _lotsType;
   OrderSide _side;
   StopLossType _stopLossType;
   double _stopLossValue;
   double _stopLossAtrMultiplicator;
   TakeProfitType _takeProfitType;
   double _takeProfitValue;
   double _takeProfitAtrMultiplicator;
   bool _ecnBroker;
   double _slippagePoints;
   int _magicNumber;
   ActionOnConditionLogic* _actions;
public:
   OpenMarketOrderAction(string symbol, PositionSizeType lotsType, double lotsValue, OrderSide side, ActionOnConditionLogic* actions)
   {
      _actions = actions;
      _side = side;
      _timeframe = PERIOD_CURRENT;
      _symbol = symbol;
      _amount = lotsValue;
      _lotsType = lotsType;
      _stopLossType = SLDoNotUse;
      _takeProfitType = TPDoNotUse;
   }

   void SetECNBroker(bool ecn)
   {
      _ecnBroker = ecn;
   }

   void SetSlippagePoints(double points)
   {
      _slippagePoints = points;
   }

   void SetMagicNumber(int number)
   {
      _magicNumber = number;
   }

   void SetTimeframe(ENUM_TIMEFRAMES tf)
   {
      _timeframe = tf;
   }

   void SetStopLoss(StopLossType stopLossType, double stopLossValue, double stopLossAtrMultiplicator)
   {
      _stopLossAtrMultiplicator = stopLossAtrMultiplicator;
      _stopLossType = stopLossType;
      _stopLossValue = stopLossValue;
   }

   void SetTakeProfit(TakeProfitType takeProfitType, double takeProfitValue, double takeProfitAtrMultiplicator)
   {
      _takeProfitAtrMultiplicator = takeProfitAtrMultiplicator;
      _takeProfitType = takeProfitType;
      _takeProfitValue = takeProfitValue;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      string error;
      TradingCalculator* tradingCalculator = TradingCalculator::Create(_symbol);
      if (tradingCalculator == NULL || !tradingCalculator.IsLotsValid(_amount, _lotsType, error))
      {
         delete tradingCalculator;
         return false;
      }
      IMoneyManagementStrategy* moneyManagement = CreateMoneyManagementStrategy(tradingCalculator, _symbol, _timeframe, _side == BuySide, 
         _lotsType, _amount, _stopLossType, _stopLossValue, _stopLossAtrMultiplicator, _takeProfitType, _takeProfitValue, _takeProfitAtrMultiplicator);
      double entryPrice = _side == BuySide ? InstrumentInfo::GetAsk(_symbol) : InstrumentInfo::GetBid(_symbol);
      double takeProfit;
      double stopLoss;
      double amount;
      moneyManagement.Get(0, entryPrice, amount, stopLoss, takeProfit);
      delete moneyManagement;
      delete tradingCalculator;
      if (amount == 0.0)
      {
         Print("Lot size is too small");
         return false;
      }
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder(_actions);
      int order = orderBuilder
         .SetSide(_side)
         .SetECNBroker(_ecnBroker)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(_slippagePoints)
         .SetMagicNumber(_magicNumber)
         .SetStopLoss(stopLoss)
         .SetTakeProfit(takeProfit)
         .Execute(error);
      delete orderBuilder;
      if (error != "")
      {
         Print("Failed to open position: " + error);
      }

      return true;
   }
};

#endif


// Line cross condition v1.0

#ifndef LineCrossCondition_IMP
#define LineCrossCondition_IMP

class LineCrossUpCondition : public AConditionBase
{
   string _lineId;
public:
   LineCrossUpCondition(string lineId)
      :AConditionBase("Line cross up")
   {
      _lineId = lineId;
   }

   bool IsPass(const int period, const datetime date)
   {
      double val0 = iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, period);
      double val1 = iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, period + 1);
      int x1 = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, ObjectGetInteger(0, _lineId, OBJPROP_TIME, 0));
      int x2 = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, ObjectGetInteger(0, _lineId, OBJPROP_TIME, 1));
      double y1 = ObjectGetDouble(0, _lineId, OBJPROP_PRICE, 0);
      double y2 = ObjectGetDouble(0, _lineId, OBJPROP_PRICE, 1);
      if (x1 > x2)
      {
         datetime temp = x1;
         x1 = x2;
         x2 = temp;
         double temp1 = y1;
         y1 = y2;
         y2 = temp1;
      }
      double a = (x2 - x1) == 0 ? 0 : ((y2 - y1) / (x2 - x1));
      double c = (y1 - a * x1);
      double y_current = a * period + c;
      double y_previous = a * (period + 1) + c;
      return y_current > val0 && y_previous <= val1;
   }
};

class LineCrossDownCondition : public AConditionBase
{
   string _lineId;
public:
   LineCrossDownCondition(string lineId)
      :AConditionBase("Line cross down")
   {
      _lineId = lineId;
   }

   bool IsPass(const int period, const datetime date)
   {
      double val0 = iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, period);
      double val1 = iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, period + 1);
      int x1 = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, ObjectGetInteger(0, _lineId, OBJPROP_TIME, 0));
      int x2 = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, ObjectGetInteger(0, _lineId, OBJPROP_TIME, 1));
      double y1 = ObjectGetDouble(0, _lineId, OBJPROP_PRICE, 0);
      double y2 = ObjectGetDouble(0, _lineId, OBJPROP_PRICE, 1);
      if (x1 > x2)
      {
         datetime temp = x1;
         x1 = x2;
         x2 = temp;
         double temp1 = y1;
         y1 = y2;
         y2 = temp1;
      }
      double a = (x2 - x1) == 0 ? 0 : ((y2 - y1) / (x2 - x1));
      double c = (y1 - a * x1);
      double y_current = a * period + c;
      double y_previous = a * (period + 1) + c;
      return y_current < val0 && y_previous >= val1;
   }
};

#endif

ActionOnConditionLogic* _actions;

input bool ecn_broker = false; // ECN Broker? 
input double lots_value = 0.1; // Position size
input PositionSizeType lots_type = PositionSizeContract; // Position size type
input int slippage_points = 3; // Slippage, points
input string StopLossSection            = ""; // == Stop loss ==
input StopLossType stop_loss_type = SLDoNotUse; // Stop loss type
input double stop_loss_value = 10; // Stop loss value
input double stop_loss_atr_multiplicator = 1; // Stop loss multiplicator (for ATR SL)
input string TakeProfitSection            = ""; // == Take Profit ==
input TakeProfitType take_profit_type = TPDoNotUse; // Take profit type
input double take_profit_value = 10; // Take profit value
input double take_profit_atr_multiplicator = 1; // Take profit multiplicator (for ATR TP)
input int magic_number        = 42; // Magic number

enum Action
{
   ActionNo, // No action
   ActionBuy, // Buy action
   ActionSell // Sell action
};
input Action cross_up_action = ActionSell; // Cross up action
input Action cross_down_action = ActionBuy; // Cross down action

string ids[];

bool IsCreated(string name)
{
   for (int i = 0; i < ArraySize(ids); ++i)
   {
      if (ids[i] == name)
      {
         return true;
      }
   }
   return false;
}

void Create(string name, OrderSide side, ICondition* condition)
{
   OpenMarketOrderAction* action = new OpenMarketOrderAction(_Symbol, lots_type, lots_value, side, _actions);
   action.SetECNBroker(ecn_broker);
   action.SetSlippagePoints(slippage_points);
   action.SetMagicNumber(magic_number);
   action.SetStopLoss(stop_loss_type, stop_loss_value, stop_loss_atr_multiplicator);
   action.SetTakeProfit(take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   _actions.AddActionOnCondition(action, condition);
   action.Release();
   condition.Release();
}

void Create(string name)
{
   switch (cross_up_action)
   {
      case ActionBuy:
         Create(name, BuySide, new LineCrossUpCondition(name));
         break;
      case ActionSell:
         Create(name, SellSide, new LineCrossUpCondition(name));
         break;
   }
   switch (cross_down_action)
   {
      case ActionBuy:
         Create(name, BuySide, new LineCrossDownCondition(name));
         break;
      case ActionSell:
         Create(name, SellSide, new LineCrossDownCondition(name));
         break;
   }
   
   int size = ArraySize(ids);
   ArrayResize(ids, size + 1);
   ids[size] = name;
}

int OnInit()
{
   _actions = new ActionOnConditionLogic();

   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      string name = ObjectName(0, k);
      if (StringFind(name, obj_id) == 0)
      {
         Create(name);
      }
   }
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete _actions;
}

void OnTick()
{
   _actions.DoLogic(0, Time[0]);
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      string name = ObjectName(0, k);
      if (StringFind(name, obj_id) == 0 && !IsCreated(name))
      {
         Create(name);
      }
   }
}