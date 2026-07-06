// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=31&t=70648
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

input string GeneralSection = ""; // == General ==
input double lots_value            = 0.1; // Position size
input int slippage_points           = 3; // Slippage, in points

input string SLSection            = ""; // == Stop loss/TakeProfit ==
input double stop_loss_value            = 10; // Stop loss value
input double take_profit_value           = 10; // Take profit value

input string OtherSection            = ""; // == Other ==
input int magic_number        = 42; // Magic number
input int length = 12; // High/low bars
input string entry_time = "231500"; // Entry time in hhmmss format
input string long_exit_time = "080000"; // Long exit time in hhmmss format
input string short_exit_time = "200000"; // Short exit time in hhmmss format

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

// Order side v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide,
   SellSide
};

#endif
// Symbol info v.1.2

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

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
   static double GetBid(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_BID); }
   static double GetAsk(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
   double GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double GetMinVolume() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
   }
};

#endif
// Order builder v1.3

#ifndef OrderBuilder_IMP
#define OrderBuilder_IMP

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
   
   OrderBuilder *SetStopLoss(const double stop)
   {
      _stop = stop;
      return &this;
   }
   
   OrderBuilder *SetTakeProfit(const double limit)
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
            case TRADE_RETCODE_INVALID_VOLUME:
               error = "Volume/lot size is invalid";
               return 0;
            case TRADE_RETCODE_CLIENT_DISABLES_AT:
               error = "Trading is disabled";
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

#endif
// Trades iterator v 1.3

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
   double GetSwap() { return PositionGetDouble(POSITION_SWAP); }
   double GetProfit() { return PositionGetDouble(POSITION_PROFIT); }
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
// Trading commands v.2.0





// Orders iterator v1.9

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

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
   string GetComment() { return OrderGetString(ORDER_COMMENT); }
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

   static bool MoveTP(const ulong ticket, const double takeProfit, string &error)
   {
      if (!PositionSelectByTicket(ticket))
      {
         error = "Invalid ticket";
         return false;
      }
      return tradeManager.PositionModify(ticket, PositionGetDouble(POSITION_SL), takeProfit);
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
// Action on condition logic v2.0

// Action on condition v3.0

// ICondition v3.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};
#endif
// Action v2.0

#ifndef IAction_IMP

interface IAction
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool DoAction(const int period, const datetime date) = 0;
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
         if (_action.DoAction(period, date))
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
ActionOnConditionLogic* _actions;

int entryTime, shortExitTime, longExitTime;
int OnInit()
{
   _actions = new ActionOnConditionLogic();
   string error;
   entryTime = ParseTime(entry_time, error);
   if (entryTime == -1)
   {
      return INIT_FAILED;
   }
   shortExitTime = ParseTime(long_exit_time, error);
   if (entryTime == -1)
   {
      return INIT_FAILED;
   }
   longExitTime = ParseTime(short_exit_time, error);
   if (entryTime == -1)
   {
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete _actions;
}

int TimeToInt(const MqlDateTime &current_time)
{
   return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
}

void OpenOrder(bool isBuy, double entryPrice)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digit = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int mult = digit == 3 || digit == 5 ? 10 : 1;
   double pipSize = point * mult;

   OrderBuilder *orderBuilder = new OrderBuilder();
   double stopLoss = isBuy ? entryPrice - stop_loss_value * pipSize : entryPrice + stop_loss_value * pipSize;
   double takeProfit = isBuy ? entryPrice + take_profit_value * pipSize : entryPrice - take_profit_value * pipSize;
   string error;
   ulong order = orderBuilder
      .SetRate(entryPrice)
      .SetSide(isBuy ? BuySide : SellSide)
      .SetInstrument(_Symbol)
      .SetAmount(lots_value)
      .SetSlippage(slippage_points)
      .SetMagicNumber(magic_number)
      .SetStopLoss(stopLoss)
      .SetTakeProfit(takeProfit)
      .Execute(error);
   delete orderBuilder;
}

void CloseTrades(bool isBuy)
{
   TradesIterator it;
   it.WhenSymbol(_Symbol);
   it.WhenSide(isBuy);
   it.WhenMagicNumber(magic_number);
   TradingCommands::CloseTrades(it);
}

datetime last_date;
void OnTick()
{
   _actions.DoLogic(0, 0);
   if (last_date == iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0))
   {
      return;
   }
   last_date = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   MqlDateTime current_time;
   if (!TimeToStruct(last_date, current_time))
   {
      return;
   }
   int bar_time = TimeToInt(current_time);
   if (bar_time == entryTime && current_time.day_of_week < 6)
   {
      int maxIndex = iHighest(_Symbol, _Period, MODE_HIGH, length, 0);
      double max = iHigh(_Symbol, _Period, maxIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, length, 0);
      double min = iLow(_Symbol, _Period, lowestIndex);
      double amplitude = max - min;
      OpenOrder(false, iClose(_Symbol, _Period, 0) - amplitude * 0.5);
      OpenOrder(true, iClose(_Symbol, _Period, 0) + amplitude * 0.5);
   }
   if (bar_time == shortExitTime)
   {
      CloseTrades(false);
   }
   if (bar_time == longExitTime)
   {
      CloseTrades(true);
   }
}