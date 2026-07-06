// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71116


//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

enum MartingaleType
{
   MartingaleDoNotUse, // Do not use
   MartingaleOnLoss, // Open another position on loss
   MartingaleOnProfit // Open another position on profit
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
input string MartingaleSection = ""; // == Martingale ==
input MartingaleType martingale_type = MartingaleDoNotUse; // Martingale type
input MartingaleLotSizingType martingale_lot_sizing_type = MartingaleLotSizingNo; // Martingale lot sizing type
input double martingale_lot_value = 1.5; // Matringale lot sizing value
MartingaleStepSizeType martingale_step_type = MartingaleStepSizePips; // Step unit
input double martingale_step = 50; // Open matringale position step
input int max_longs = 5; // Max long positions
input int max_shorts = 5; // Max short positions

input double stop_loss = 60; // Stop Loss in Pips
input double take_profit = 30; // Take Profit in Pips
input int magic_number = 42; // Magic number
input int slippage_points = 3; // Slippage, points
input bool ecn_broker = false; // ECN Broker?

// Trades monitor v3.0

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
#ifndef TradingMonitor_IMP
#define TradingMonitor_IMP

class TradingMonitor
{
   int active_ticket[1000];
   double active_type[1000];
   double active_price[1000];
   double active_stoploss[1000];
   double active_takeprofit[1000];
   bool active_still_active[1000];
   int active_total;
   IAction* _closedTradeAction;
   IAction* _orderChangedAction;
   IAction* _newOrderAction;
public:
   TradingMonitor()
   {
      _closedTradeAction = NULL;
      _orderChangedAction = NULL;
      _newOrderAction = NULL;
   }

   ~TradingMonitor()
   {
      if (_closedTradeAction != NULL)
         _closedTradeAction.Release();
      if (_orderChangedAction != NULL)
         _orderChangedAction.Release();
      if (_newOrderAction != NULL)
         _newOrderAction.Release();
   }

   void SetClosedTradeAction(IAction* action)
   {
      if (_closedTradeAction != NULL)
         _closedTradeAction.Release();
      _closedTradeAction = action;
      if (_closedTradeAction != NULL)
         _closedTradeAction.AddRef();
   }

   void SetOnOrderChanged(IAction* action)
   {
      if (_orderChangedAction != NULL)
         _orderChangedAction.Release();
      _orderChangedAction = action;
      if (_orderChangedAction != NULL)
         _orderChangedAction.AddRef();
   }

   void SetOnNewOrder(IAction* action)
   {
      if (_newOrderAction != NULL)
         _newOrderAction.Release();
      _newOrderAction = action;
      if (_newOrderAction != NULL)
         _newOrderAction.AddRef();
   }

   void DoWork()
   {
      bool changed = false;
      int total = OrdersTotal();
      for (int i = 0; i < total; i++)
      {
         if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
         int ticket = OrderTicket();
         int index = getOrderCacheIndex(ticket);
         if (index == -1)
         {
            changed = true;
            if (_newOrderAction != NULL)
               _newOrderAction.DoAction(0, 0);
         }
         else
         {
            active_still_active[index] = true; // order is still there
            if (OrderOpenPrice() != active_price[index] ||
                  OrderStopLoss() != active_stoploss[index] ||
                  OrderTakeProfit() != active_takeprofit[index] ||
                  OrderType() != active_type[index])
            {
               changed = true;
               if (_orderChangedAction != NULL)
                  _orderChangedAction.DoAction(0, 0);
            }
         }
      }

      for (int index = 0; index < active_total; index++)
      {
         if (active_still_active[index] == false)
         {
            changed = true;
            if (_closedTradeAction != NULL && OrderSelect(active_ticket[index], MODE_HISTORY))
               _closedTradeAction.DoAction(0, 0);
         }
         
         active_still_active[index] = false;
      }
      if (changed)
         updateActiveOrders();
   }
private:
   int getOrderCacheIndex(const int ticket)
   {
      for (int i = 0; i < active_total; i++)
      {
         if (active_ticket[i] == ticket)
            return i;
      }
      return -1;
   }

   /**
   * read in the current state of all open orders 
   * and trades so we can track any changes in the next tick
   */ 
   void updateActiveOrders()
   {
      active_total = OrdersTotal();
      for (int i = 0; i < active_total; i++)
      {
         if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
         active_ticket[i] = OrderTicket();
         active_type[i] = OrderType();
         active_price[i] = OrderOpenPrice();
         active_stoploss[i] = OrderStopLoss();
         active_takeprofit[i] = OrderTakeProfit();
         active_still_active[i] = false; // filled in the next tick
      }
   }
};

#endif
// Trade calculator v2.4
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
// Money management strategy interface v1.0

#ifndef IMoneyManagementStrategy_IMP
#define IMoneyManagementStrategy_IMP
interface IMoneyManagementStrategy
{
public:
   virtual void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit) = 0;
};
#endif
// Order builder v2.2





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
// Money management strategy v1.1


// Stop loss strategy interface v1.0

#ifndef IStopLossStrategy_IMP
#define IStopLossStrategy_IMP

class IStopLossStrategy
{
public:
   virtual double GetValue(const int period, double entryPrice) = 0;
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
class CreateMartingaleAction : public AOrderAction
{
   ActionOnConditionLogic* _actions;
   double _martingaleStepPips;
   IAction* _longAction;
   IAction* _shortAction;
   int _maxLongPositions;
   int _maxShortPositions;
   double _lotsValue;
   MartingaleLotSizingType _lotsSizingType;
   CustomLotsProvider* _lots;
   bool _inProfit;
public:
   CreateMartingaleAction(CustomLotsProvider* lots, MartingaleLotSizingType lotsSizingType, double lotsValue, 
      double martingaleStepPips, IAction* longAction, IAction* shortAction, 
      int maxLongPositions, int maxShortPositions, ActionOnConditionLogic* actions, bool inProfit)
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
      _martingaleStepPips = martingaleStepPips;
      _inProfit = inProfit;
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
      if (IsLimitHit())
      {
         return false;
      }
      OrderByTicketId* order = new OrderByTicketId(_currentTicket);
      if (!order.Select())
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
      ProfitInRangeCondition* condition;
      if (_inProfit)
      {
         condition = new ProfitInRangeCondition(order, _martingaleStepPips, 100000);
      }
      else
      {
         condition = new ProfitInRangeCondition(order, -100000, -_martingaleStepPips);
      }
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

TradingMonitor tradingMonitor;
ActionOnConditionLogic* actions;

class OnTradeCloseAction : public AAction
{
public:
   virtual bool DoAction(const int period, const datetime date)
   {
      return true;
   }
};

class OnTradeOpenActionAction : public AAction
{
public:
   virtual bool DoAction(const int period, const datetime date)
   {
      orderHandlers.DoAction(OrderTicket());
      return true;
   }
};

OrderHandlers* orderHandlers;
int OnInit()
{
   orderHandlers = new OrderHandlers();
   actions = new ActionOnConditionLogic();
   
   OnTradeOpenActionAction* onNewTradeAction = new OnTradeOpenActionAction();
   tradingMonitor.SetOnNewOrder(onNewTradeAction);
   onNewTradeAction.Release();

   OnTradeCloseAction* onTradeClosedAction = new OnTradeCloseAction();
   tradingMonitor.SetClosedTradeAction(onTradeClosedAction);
   onTradeClosedAction.Release();

   TradingCalculator* tradingCalculator = TradingCalculator::Create(_Symbol);
   IEntryStrategy* entryStrategy = new MarketEntryStrategy(_Symbol, magic_number, slippage_points, actions, ecn_broker);
   switch (martingale_type)
   {
      case MartingaleOnLoss:
         {
            CreateMartingale(tradingCalculator, _Symbol, (ENUM_TIMEFRAMES)_Period, entryStrategy, orderHandlers, actions, false);
         }
         break;
      case MartingaleOnProfit:
         {
            CreateMartingale(tradingCalculator, _Symbol, (ENUM_TIMEFRAMES)_Period, entryStrategy, orderHandlers, actions, true);
         }
         break;
   }
   entryStrategy.Release();
   delete tradingCalculator;

   return INIT_SUCCEEDED;
}
enum StopLossType
{
   SLDoNotUse, // Do not use
   SLPercent, // Set in %
   SLPips, // Set in Pips
   SLDollar, // Set in $,
   SLAbsolute, // Set in absolite value (rate),
   SLAtr, // Set in ATR(value) * mult,
   SLHighLow, // High/low of X bars
   SLRiskBalance, // Set in % of risked balance
   #ifdef CUSTOM_SL
   SLCustom // Use custom strategy SL algorithm
   #endif
};
enum TakeProfitType
{
   TPDoNotUse,    // Do not use
   TPPercent,     // Set in %
   TPPips,        // Set in Pips
   TPDollar,      // Set in $,
   TPRiskReward,  // Set in % of stop loss
   TPAbsolute,    // Set in absolite value (rate),
   TPAtr,         // Set in ATR(value) * mult
#ifdef CUSTOM_TP
   TPCustom       // Use custom strategy TP algorithm
#endif
};
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
      default:
         return CreateStopLossStrategy(tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLossAtrMultiplicator);
   }
   return NULL;
}
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
      #endif
   }
   return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDoNotUse, takeProfitValue, isBuy);
}
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
MoneyManagementStrategy* CreateMoneyManagementStrategy(TradingCalculator* tradingCalculator, string symbol,
   ENUM_TIMEFRAMES timeframe, bool isBuy, PositionSizeType lotsType, double lotsValue,
   StopLossType stopLossType, double stopLossValue, double stopLossAtrMultiplicator,
   TakeProfitType takeProfitType, double takeProfitValue, double takeProfitAtrMultiplicator)
{
   ILotsProvider* lots = NULL;
   IStopLossStrategy* stopLoss = NULL;
   switch (lotsType)
   {
      default:
         lots = new DefaultLotsProvider(tradingCalculator, lotsType, lotsValue);
         stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLossAtrMultiplicator);
         break;
   }
   ITakeProfitStrategy* tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, isBuy, takeProfitType, takeProfitValue, takeProfitAtrMultiplicator);
   return new MoneyManagementStrategy(lots, stopLoss, tp);
}
void CreateMartingale(TradingCalculator* tradingCalculator, string symbol, ENUM_TIMEFRAMES timeframe, IEntryStrategy* entryStrategy, 
   OrderHandlers* orderHandlers, ActionOnConditionLogic* actions, bool inProfit)
{
   CustomLotsProvider* lots = new CustomLotsProvider();

   IStopLossStrategy* stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, true, SLPips, stop_loss, 1);
   ITakeProfitStrategy* tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, true, TPPips, take_profit, 0);
   IMoneyManagementStrategy* longMoneyManagement = new MoneyManagementStrategy(lots, stopLoss, tp);
   IAction* openLongAction = new EntryAction(entryStrategy, BuySide, longMoneyManagement, "", orderHandlers, true);
   
   stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, false, SLPips, stop_loss, 1);
   tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, false, TPPips, take_profit, 0);
   IMoneyManagementStrategy* shortMoneyManagement = new MoneyManagementStrategy(lots, stopLoss, tp);
   IAction* openShortAction = new EntryAction(entryStrategy, SellSide, shortMoneyManagement, "", orderHandlers, true);

   CreateMartingaleAction* martingaleAction = new CreateMartingaleAction(lots, martingale_lot_sizing_type, martingale_lot_value, 
      martingale_step, openLongAction, openShortAction, max_longs, max_shorts, actions, inProfit);
   openLongAction.Release();
   openShortAction.Release();
   
   martingaleAction.RestoreActions(_Symbol, magic_number);
   orderHandlers.AddOrderAction(martingaleAction);
   martingaleAction.Release();
}

void OnDeinit(const int reason)
{
   orderHandlers.Clear();
   orderHandlers.Release();
   delete actions;
}

bool first = true;
void OnTick()
{
   tradingMonitor.DoWork();
   actions.DoLogic(0, 0);
   if (first)
   {
      first = false;
   }
}

