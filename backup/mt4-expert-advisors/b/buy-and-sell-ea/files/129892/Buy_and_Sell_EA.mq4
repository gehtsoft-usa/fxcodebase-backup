// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69116

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
#property version   "1.1"
#property strict

input bool ecn_broker = false; // ECN Broker? 
input int x_pips = 10; // X pips
input double lots_value = 0.1; // Position size
input int slippage_points = 3; // Slippage, points
input double stop_loss_value = 10; // Stop loss value
input double trailing_step = 5; // Trailing step
input double trailing_start = 0; // Trailing start

input double take_profit_value = 10; // Take profit value
input int magic_number = 42; // Magic number

// Trailing action v2.0

// AAction v1.0
// Action v1.0

#ifndef IAction_IMP
#define IAction_IMP

interface IAction
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool DoAction() = 0;
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
// Trading commands v.2.13
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef TradingCommands_IMP
#define TradingCommands_IMP

// Orders iterator v 1.12
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

enum CompareType
{
   CompareLessThan
};

// Order side enum v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide,
   SellSide
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
                  return false;
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
// Instrument info v.1.4
// More templates and snippets on https://github.com/sibvic/mq4-templates

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
};


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

   virtual bool DoAction()
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
// Profit in range condition v2.0

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

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "";
   }
};

#endif



#ifndef ProfitInRangeCondition_IMP
#define ProfitInRangeCondition_IMP

class ProfitInRangeCondition : public ACondition
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

// Orders iterator v 1.12
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

enum CompareType
{
   CompareLessThan
};

// Order side enum v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide,
   SellSide
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
                  return false;
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
// Order builder v2.1

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

// Action on condition logic v2.0

// Action on condition v2.2

// Action v1.0

#ifndef IAction_IMP
#define IAction_IMP

interface IAction
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool DoAction() = 0;
};

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

      if (_condition.IsPass(period, date) && _action.DoAction())
      {
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
// No stop loss or take profit condition v1.0

// Abstract condition v1.1



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

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "";
   }
};

#endif

#ifndef NoStopLossOrTakeProfitCondition_IMP
#define NoStopLossOrTakeProfitCondition_IMP

class NoStopLossOrTakeProfitCondition : public ACondition
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
// Set stop loss and/or take profit action v1.0

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

   virtual bool DoAction()
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
// Trade trigger logic v1.0

// Trade trigger controller v1.0

#ifndef TradeTriggerController_IMP
#define TradeTriggerController_IMP
class TradeTriggerController
{
   int _order;
   IAction *_action;
public:
   TradeTriggerController()
   {
      _order = 0;
      _action = NULL;
   }

   bool SetAction(const int order, IAction *action)
   {
      if (_order != 0)
         return false;

      _order = order;
      _action = action;
      return true;
   }

   void DoLogic()
   {
      if (_order == 0)
         return;
      if (!OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES))
      {
         _order = 0;
         return;
      }
      int orderType = OrderType();
      if (orderType != OP_BUY && orderType != OP_SELL)
         return;

      _action.DoAction();
      _order = 0;
   }
};

#endif

#ifndef TradeTriggerLogic_IMP
#define TradeTriggerLogic_IMP

class TradeTriggerLogic
{
   TradeTriggerController *_triggers[];
public:
   ~TradeTriggerLogic()
   {
      Clear();
   }

   void Clear()
   {
      int count = ArraySize(_triggers);
      for (int i = 0; i < count; ++i)
      {
         delete _triggers[i];
      }
      ArrayResize(_triggers, 0);
   }

   void DoLogic()
   {
      int count = ArraySize(_triggers);
      for (int i = 0; i < count; ++i)
      {
         _triggers[i].DoLogic();
      }
   }

   void SetAction(const int order, IAction *actionOnTade)
   {
      int count = ArraySize(_triggers);
      for (int i = 0; i < count; ++i)
      {
         if (_triggers[i].SetAction(order, actionOnTade))
            return;
      }
      ArrayResize(_triggers, count + 1);
      _triggers[count] = new TradeTriggerController();
      _triggers[count].SetAction(order, actionOnTade);
   }
};

#endif


class DeleteOrders : public AAction
{
public:
   virtual bool DoAction()
   {
      TradingCommands::DeleteOrders(magic_number);
      return true;
   }
};
DeleteOrders* deleteOrders;
ActionOnConditionLogic *actions;
TradeTriggerLogic tradeTrigger;
int OnInit(void)
{
   actions = new ActionOnConditionLogic();
   deleteOrders = new DeleteOrders();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   deleteOrders.Release();
   delete actions;
}

void CreateActions(int ticket)
{
   OrderByTicketId* order = new OrderByTicketId(ticket);
   if (!order.Select() || OrderStopLoss() == 0)
   {
      order.Release();
      return;
   }

   double point = MarketInfo(OrderSymbol(), MODE_POINT);
   int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;

   double distance = (OrderOpenPrice() - OrderStopLoss()) / pipSize;

   TrailingPipsAction* action = new TrailingPipsAction(order, distance, trailing_step);
   ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, 0, trailing_start);
   actions.AddActionOnCondition(action, condition);
   condition.Release();
   action.Release();

   order.Release();
}

void OnTick()
{
   actions.DoLogic(0, Time[0]);
   tradeTrigger.DoLogic();
   OrdersIterator it;
   it.WhenSymbol(_Symbol);
   it.WhenOrder();
   it.WhenMagicNumber(magic_number);
   if (it.Any())
      return;

   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   
   string error = "";
   OrderBuilder order1(actions);
   double rate1 = Close[0] - x_pips * pipSize;
   int buyOrder = order1.SetECNBroker(ecn_broker)
      .SetSide(BuySide)
      .SetInstrument(_Symbol)
      .SetAmount(lots_value)
      .SetRate(rate1)
      .SetSlippage(slippage_points)
      .SetStopLoss(rate1 - stop_loss_value * pipSize)
      .SetTakeProfit(rate1 + take_profit_value * pipSize)
      .SetMagicNumber(magic_number)
      .Execute(error);
   if (error != "")
   {
      Print(error);
      return;
   }
   CreateActions(buyOrder);

   OrderBuilder order2(actions);
   double rate2 = Close[0] + x_pips * pipSize;
   int sellOrder = order2.SetECNBroker(ecn_broker)
      .SetSide(SellSide)
      .SetInstrument(_Symbol)
      .SetAmount(lots_value)
      .SetRate(rate2)
      .SetSlippage(slippage_points)
      .SetStopLoss(rate2 + stop_loss_value * pipSize)
      .SetTakeProfit(rate2 - take_profit_value * pipSize)
      .SetMagicNumber(magic_number)
      .Execute(error);
   if (error != "")
   {
      Print(error);
      return;
   }
   CreateActions(sellOrder);

   tradeTrigger.SetAction(buyOrder, deleteOrders);
   tradeTrigger.SetAction(sellOrder, deleteOrders);
}
