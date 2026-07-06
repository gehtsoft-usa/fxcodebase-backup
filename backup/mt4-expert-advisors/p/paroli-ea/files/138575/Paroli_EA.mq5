// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70585

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

#define X_OFFSET_RIGHT 60
// Position size type

#ifndef PositionSizeType_IMP
#define PositionSizeType_IMP

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
   PositionSizeMoneyPerPip, // $ per pip
   PositionSizeRiskCurrency // Risk in $
};

#endif

input double lots_value = 0.1; // Position size
input PositionSizeType lots_type = PositionSizeContract; // Position size type
input int _slippagePoints = 3; // Slippage, points
input int _magicNumber = 42; // Magic number

input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
#ifdef ADVANCED_ALERTS
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
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
   SLAtr // Set in ATR(value) * mult
};

#endif
// Stop/limit type v1.0

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
// Take profit type v1.0

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
string StopLossSection            = ""; // == Stop loss ==
input StopLossType stop_loss_type = SLDoNotUse; // Stop loss type
input double stop_loss_value = 10; // Stop loss value
input double stop_loss_atr_multiplicator = 1; // Stop loss multiplicator (for ATR SL)
input string TakeProfitSection            = ""; // == Take Profit ==
input TakeProfitType take_profit_type = TPDoNotUse; // Take profit type
input double take_profit_value = 10; // Take profit value
input double take_profit_atr_multiplicator = 1; // Take profit multiplicator (for ATR TP)
input bool _ecnBroker = false; // ECN Broker

input ENUM_BASE_CORNER InpCorner = 0;        // Corner
input int InpXOffSet = 0;                   // X Off Set
input int InpYOffSet = 40;                  // Y Off Set

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

// Order side v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide,
   SellSide
};

#endif

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
// Closed trades iterator v 1.2
#ifndef ClosedTradesIterator_IMP
class ClosedTradesIterator
{
   int _lastIndex;
   int _total;
   ulong _currentTicket;
   string _symbol;

public:
   ClosedTradesIterator()
   {
      _lastIndex = INT_MIN;
   }

   void WhenSymbol(string symbol)
   {
      _symbol = symbol;
   }

   ulong GetTicket() { return _currentTicket; }
   ENUM_DEAL_TYPE GetPositionType() { return (ENUM_DEAL_TYPE)HistoryDealGetInteger(_currentTicket, DEAL_TYPE); }
   string GetSymbol() { return HistoryDealGetString(_currentTicket, DEAL_SYMBOL); }
   datetime GetCloseTime() { return (datetime)HistoryDealGetInteger(_currentTicket, DEAL_TIME); }

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
      {
         return false;
      }
      if (_symbol != NULL && GetSymbol() != _symbol)
      {
         return false;
      }
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

class TicketTarget : public ITicketTarget
{
   ulong _ticket;
public:
   virtual void SetTicket(ulong ticket)
   {
      _ticket = ticket;
   }
   
   ulong GetTicket()
   {
      return _ticket;
   }   
};

// Trades monitor v2.0

#ifndef TradingMonitor_IMP
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
               _onNewTrade.DoAction(0, 0);
         }
         else
         {
            if (it.GetStopLoss() != active_stoploss[index] ||
                  it.GetTakeProfit() != active_takeprofit[index])
            {
               if (_onTradeChanged != NULL)
                  // ignore result of DoAction
                  _onTradeChanged.DoAction(0, 0);
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
               _onClosedTrade.DoAction(0, 0);
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
// Trading calculator v.1.3




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
   bool _ecnBroker;
   ActionOnConditionLogic* _actions;
public:
   MarketOrderBuilder(ActionOnConditionLogic* actions)
   {
      _ecnBroker = false;
      _actions = actions;
      _btcAccount = false;
      _amount = 0;
      _rate = 0;
      _slippage = 0;
      _stop = 0;
      _limit = 0;
      _magicNumber = 0;
   }

   // Sets ECN broker flag
   MarketOrderBuilder* SetECNBroker(bool isEcn) { _ecnBroker = isEcn; return &this; }
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

class ILotsProvider
{
public:
   virtual double GetLots(double stopLoss) = 0;
};

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
      return _calculator.GetLots(_lotsType, _lots, BuySide, 0, 0);
   }
};

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
      amount = _calculator.GetLots(PositionSizeRisk, _lots, _isBuy ? BuySide : SellSide, entryPrice, _isBuy ? (entryPrice - stopLoss) : (stopLoss - entryPrice));
   }
};

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
   }
};

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

#ifndef MoneyManagementFunctions_IMP
#define MoneyManagementFunctions_IMP

MoneyManagementStrategy* CreateMoneyManagementStrategy(TradingCalculator* tradingCalculator, string symbol
   , ENUM_TIMEFRAMES timeframe, bool isBuy, PositionSizeType lotsType, double lotsValue
   , StopLossType stopLossType, double stopLossValue, TakeProfitType takeProfitType, double takeProfitValue, double takeProfitATRMult)
{
   ILotsProvider* lots = NULL;
   switch (lotsType)
   {
      case PositionSizeRisk:
      case PositionSizeRiskCurrency:
         break;
      default:
         lots = new DefaultLotsProvider(tradingCalculator, lotsType, lotsValue);
         break;
   }
   IStopLossAndAmountStrategy* sl = NULL;
   switch (stopLossType)
   {
      case SLDoNotUse:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitDoNotUse, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitDoNotUse, stopLossValue, isBuy);
         }
         break;
      case SLPercent:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitPercent, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitPercent, stopLossValue, isBuy);
         }
         break;
      case SLPips:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitPips, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitPips, stopLossValue, isBuy);
         }
         break;
      case SLDollar:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitDollar, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitDollar, stopLossValue, isBuy);
         }
         break;
      case SLAbsolute:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitAbsolute, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitAbsolute, stopLossValue, isBuy);
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
            tp = new ATRTakeProfitStrategy(symbol, timeframe, (int)takeProfitValue, takeProfitATRMult, isBuy);
            break;
      #endif
   }
   
   return new MoneyManagementStrategy(sl, tp);
}
#endif

double current_lots;
OrderSide lastSide;
Signaler* signaler;

class LotMultiplierAction : public AAction
{
public:
   virtual bool DoAction(const int period, const datetime date)
   {
      ulong ticket = ticketTarget.GetTicket();
      if (current_lots == lots_value * 4 || HistoryDealGetInteger(ticket, DEAL_MAGIC) != _magicNumber)
      {
         return true;
      }
      string comment = HistoryDealGetString(ticket, DEAL_COMMENT);
      if (StringFind(comment, "[sl]", 0) != -1)
      {
         signaler.SendNotifications("Trade closed by stop loss. Opening with default lot size");
         OpenTrade(lots_value, SellSide);
      }
      else if (StringFind(comment, "[tp]", 0) != -1)
      {
         current_lots *= 2;
         signaler.SendNotifications("Trade closed by take profit. Opening with double lot size");
         OpenTrade(current_lots, lastSide);
      }
      return true;
   }
};

ActionOnConditionLogic* actions;
TradingMonitor monitor;
TicketTarget* ticketTarget;
int OnInit()
{
   ticketTarget = new TicketTarget();
   ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
   signaler = new Signaler(_Symbol, timeframe);
   signaler.SetPopupAlert(Popup_Alert);
   signaler.SetEmailAlert(Email_Alert);
   signaler.SetPlaySound(Play_Sound, Sound_File);
   signaler.SetNotificationAlert(Notification_Alert);
   #ifdef ADVANCED_ALERTS
   signaler.SetAdvancedAlert(Advanced_Alert, Advanced_Key);
   #endif
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");

   LotMultiplierAction* closeTradeAction = new LotMultiplierAction();
   monitor.SetOnClosedTrade(closeTradeAction, ticketTarget);
   closeTradeAction.Release();

   if (!GlobalVariableGet("Piroli", current_lots))
   {
      current_lots = lots_value;
   }

   actions = new ActionOnConditionLogic();
   CreatePanel();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete signaler;
   delete ticketTarget;
   RemovePanel();
}

void OpenTrade(double amount, OrderSide side)
{
   string error;
   TradingCalculator* tradingCalculator = TradingCalculator::Create(_Symbol);
   if (!tradingCalculator.IsLotsValid(amount, lots_type, error))
   {
      delete tradingCalculator;
      return;
   }
   IMoneyManagementStrategy* moneyManagement = CreateMoneyManagementStrategy(tradingCalculator, _Symbol, (ENUM_TIMEFRAMES)_Period, side == BuySide, 
      lots_type, amount, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   double entryPrice = side == BuySide ? InstrumentInfo::GetAsk(_Symbol) : InstrumentInfo::GetBid(_Symbol);
   double takeProfit;
   double stopLoss;
   moneyManagement.Get(0, entryPrice, amount, stopLoss, takeProfit);
   delete moneyManagement;
   delete tradingCalculator;
   if (amount == 0.0)
   {
      Print("Lot size is too small");
      return;
   }
   MarketOrderBuilder *orderBuilder = new MarketOrderBuilder(actions);
   int order = orderBuilder
      .SetSide(side)
      .SetECNBroker(_ecnBroker)
      .SetInstrument(_Symbol)
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
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam )
{
   if (id == CHARTEVENT_OBJECT_CLICK)
   {
      if (ObjectGetInteger(ChartID(), "EA BUY", OBJPROP_STATE))
      {
         current_lots = lots_value;
         lastSide = BuySide;
         OpenTrade(lots_value, BuySide);
         ObjectSetInteger(ChartID(), "EA BUY", OBJPROP_STATE, false);
      }
      else if (ObjectGetInteger(ChartID(), "EA SELL", OBJPROP_STATE))
      {
         current_lots = lots_value;
         lastSide = SellSide;
         OpenTrade(lots_value, SellSide);
         ObjectSetInteger(ChartID(), "EA SELL", OBJPROP_STATE, false);
      }
   }
}

void OnTick()
{
   actions.DoLogic(0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0));
   monitor.DoWork();
}
//+------------------------------------------------------------------+
//| Create the panel                                                 |
//+------------------------------------------------------------------+
void CreatePanel()
{
   int rightOffset = InpXOffSet;
   if(InpCorner == CORNER_RIGHT_LOWER || InpCorner == CORNER_RIGHT_UPPER) rightOffset = X_OFFSET_RIGHT + InpXOffSet;

   object("EA BUY", OBJ_BUTTON, 20 + rightOffset, 120 + InpYOffSet, 30, 60, "BUY", clrWhite, clrGreen);
   object("EA SELL", OBJ_BUTTON, 90 + rightOffset, 120 + InpYOffSet, 30, 60, "SELL", clrWhite, clrRed);

   // move the chart to back
   ChartSetInteger(0, CHART_FOREGROUND, false);
}
//+------------------------------------------------------------------+
//| Remove the panel                                                 |
//+------------------------------------------------------------------+
void RemovePanel()
{
   ObjectDelete(ChartID(), "EA BUY");
   ObjectDelete(ChartID(), "EA SELL");
}

void ObjectSetText(string id, string text, int fontSize, string font, color clr)
{
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
}
//+------------------------------------------------------------------+
//| Create the object                                                |
//+------------------------------------------------------------------+
void object(string name, ENUM_OBJECT obj, int x, int y, int width, int lengh, string text, color colorText = clrBlack, color back = clrWhite)
{
   // to prevent repeated execution of the code
   long chartId = ChartID();

   ObjectCreate(chartId, name, obj, 0, 0, 0);
   ObjectSetText(name, text, 12, "Arial", colorText);
   ObjectSetInteger(chartId, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chartId, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chartId, name, OBJPROP_YSIZE, width);
   ObjectSetInteger(chartId, name, OBJPROP_XSIZE, lengh);
   ObjectSetInteger(chartId, name, OBJPROP_BGCOLOR, back);
   ObjectSetInteger(chartId, name, OBJPROP_COLOR, colorText);
   ObjectSetInteger(chartId, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(chartId, name, OBJPROP_BORDER_TYPE, BORDER_SUNKEN);
}
