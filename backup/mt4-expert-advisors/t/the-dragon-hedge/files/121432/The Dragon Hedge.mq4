// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66713

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict

// Trade controller v.1.9

enum TradingDirection
{
   Buy,
   Sell,
   Both
};

enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar // Set in $
};

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk // Risk in % of equity
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

extern int DistanceToOrders = 10; // Distance to orders, in pips
extern TradingDirection TradeType = Both; // What trades should be taken
extern double Lots            = 0.1; // Position size
extern PositionSizeType LotsType = PositionSizeContract; // Position size type
extern int Slippage           = 3;
extern StopLimitType StopType = StopLimitPips; // Stop loss type
extern double Stop            = 10; // Stop loss value
extern TrailingType Trailing = TrailingDontUse; // Trailing type
extern double TrailingStep = 10; // Trailing step
extern StopLimitType LimitType = StopLimitPips; // Take profit type
extern double Limit           = 10; // Take profit value
extern StopLimitType BreakevenTriggerType = StopLimitPips; // Trigger type for the breakeven
extern double BreakevenTrigger = 10; // Trigger for the breakeven
extern int MagicNumber        = 42; // Magic number
//Signaler v 1.5
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll and cpprest141_2_10.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const int direction)
   {
      if (direction == 0)
         return;

      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            alert_Subject = "Buy signal on " + _symbol + "/" + tf;
            alert_Body = "Buy signal on " + _symbol + "/" + tf;
            break;
         case ENTER_SELL_SIGNAL:
            alert_Subject = "Sell signal on " + _symbol + "/" + tf;
            alert_Body = "Sell signal on " + _symbol + "/" + tf;
            break;
         case EXIT_BUY_SIGNAL:
            alert_Subject = "Exit buy signal on " + _symbol + "/" + tf;
            alert_Body = "Exit buy signal on " + _symbol + "/" + tf;
            break;
         case EXIT_SELL_SIGNAL:
            alert_Subject = "Exit sell signal on " + _symbol + "/" + tf;
            alert_Body = "Exit sell signal on " + _symbol + "/" + tf;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _symbol, tf);
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframe();

      if (Popup_Alert)
         Alert(message);
      if (Email_Alert)
         SendMail(subject, message);
      if (Play_Sound)
         PlaySound(Sound_File);
      if (Notification_Alert)
         SendNotification(message);
      if (Advanced_Alert && Advanced_Key != "" && !IsTesting())
         AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

private:
   string GetTimeframe()
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
};

// Trailing controller v.1.4
class TrailingControler
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   double _stop;
   double _trailingStep;
   double _tickSize;
   int _digits;
public:
   TrailingControler(Signaler *signaler = NULL)
   {
      _finished = true;
      _order = -1;
      _signaler = signaler;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const int order, const double stop, const double trailingStep)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
      {
         return false;
      }
      _digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
      _tickSize = MarketInfo(OrderSymbol(), MODE_TICKSIZE);
      _trailingStep = NormalizeDouble(MathCeil(trailingStep / _tickSize) * _tickSize, _digits);
      if (_trailingStep == 0)
         return false;

      _finished = false;
      _order = order;
      _stop = stop;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES))
      {
         _finished = true;
         return;
      }

      int type = OrderType();
      if (type == OP_BUY)
      {
         double newStop = OrderStopLoss();
         while (NormalizeDouble(newStop + _trailingStep, _digits) < NormalizeDouble(Ask - _stop, _digits))
         {
            newStop = NormalizeDouble(newStop + _trailingStep, _digits);
         }
         if (newStop != OrderStopLoss()) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop for " + IntegerToString(_order) + " to " + DoubleToString(newStop);
               _signaler.SendNotifications(message);
            }
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, CLR_NONE);
            if (res == 0)
            {
               int error = GetLastError();
               switch (error)
               {
                  case ERR_INVALID_TICKET:
                     _finished = true;
                     break;
               }
            }
         }
      } 
      else if (type == OP_SELL) 
      {
         double newStop = OrderStopLoss();
         while (NormalizeDouble(newStop - _trailingStep, _digits) > NormalizeDouble(Bid + _stop, _digits))
         {
            newStop = NormalizeDouble(newStop - _trailingStep, _digits);
         }
         if (newStop != OrderStopLoss()) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop for " + IntegerToString(_order) + " to " + DoubleToString(newStop);
               _signaler.SendNotifications(message);
            }
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, CLR_NONE);
            if (res == 0)
            {
               int error = GetLastError();
               switch (error)
               {
                  case ERR_INVALID_TICKET:
                     _finished = true;
                     break;
               }
            }
         }
      } 
   }
};

// Breakeven controller v. 1.0.1
class BreakevenController
{
   int _order;
   bool _finished;
   double _trigger;
   double _target;
public:
   BreakevenController()
   {
      _finished = false;
   }
   
   bool SetOrder(const int order, const double trigger, const double target)
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
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES))
      {
         _finished = true;
         return;
      }

      int type = OrderType();
      if (type == OP_BUY)
      {
         if (Ask >= _trigger)
         {
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), _target, OrderTakeProfit(), 0, CLR_NONE);
            _finished = true;
         }
      } 
      else if (type == OP_SELL) 
      {
         if (Bid < _trigger) 
         {
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), _target, OrderTakeProfit(), 0, CLR_NONE);
            _finished = true;
         }
      } 
   }
};

// Order builder
// v.1.0.0

enum OrderSide
{
   BuySide,
   SellSide
};

class OrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stop;
   double _limit;
   int _magicNumber;
public:
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
      _rate = NormalizeDouble(rate, Digits);
      return &this;
   }
   
   OrderBuilder *SetSlippage(const int slippage)
   {
      _slippage = slippage;
      return &this;
   }
   
   OrderBuilder *SetStop(const double stop)
   {
      _stop = NormalizeDouble(stop, Digits);
      return &this;
   }
   
   OrderBuilder *SetLimit(const double limit)
   {
      _limit = NormalizeDouble(limit, Digits);
      return &this;
   }
   
   OrderBuilder *SetMagicNumber(const int magicNumber)
   {
      _magicNumber = magicNumber;
      return &this;
   }
   
   int Execute()
   {
      int orderType;
      if (_orderSide == BuySide)
      {
         orderType = _rate > Ask ? OP_BUYSTOP : OP_BUYLIMIT;
      }
      else
      {
         orderType = _rate < Bid ? OP_SELLSTOP : OP_SELLLIMIT;
      }
      double minstoplevel=MarketInfo(_instrument,MODE_STOPLEVEL); 
      
      Print("Creating " + (_orderSide == BuySide ? "buy" : "sell")
         + " order at " + DoubleToStr(_rate, Digits) 
         + ". Amount: " + DoubleToStr(_amount, 2)
         + ". Stop: " + DoubleToStr(_stop, Digits)
         + ". Limit: " + DoubleToStr(_limit, Digits));
      int order = OrderSend(_instrument, orderType, _amount, _rate, _slippage, _stop, _limit, NULL, _magicNumber);
      if (order == -1)
      {
         int error = GetLastError();
         switch (error)
         {
            case 4109:
               Print("Trading is not allowed");
               break;
            case 130:
               Print("Failed to create order: stoploss/takeprofit is too close");
               break;
            default:
               Print("Failed to create order: " + IntegerToString(error));
               break;
         }
      }
      return order;
   }
};

class TradeController
{
   bool IsDayStart()
   {
      datetime date = iTime(_symbol, PERIOD_D1, 0);
      if (_lastOpenDate == 0)
         _lastOpenDate = date;
      if (_lastOpenDate != date)
      {
         _lastOpenDate = date;
         return true;
      }
      return false;
   }
   
   datetime _lastOpenDate;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _point;
   datetime _lastbartime;
   int _digit;
   double _mult;
   double _pipSize;
   BreakevenController *_breakeven[];
   TrailingControler *_trailing[];
   Signaler *_signaler;
   int _upOrder;
   int _downOrder;
   int _middleOrder;
   int _middleOrderSide;
   int active_ticket[1000];
   double active_type[1000];
   double active_price[1000];
   double active_stoploss[1000];
   double active_takeprofit[1000];
   bool active_still_active[1000];
   int active_total;
public:
   TradeController(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _upOrder = -1;
      _downOrder = -1;
      _middleOrder = -1;
      _lastOpenDate = 0;
      _middleOrderSide = 0;
      _signaler = new Signaler(symbol, timeframe);
      _timeframe = timeframe;
      _symbol = symbol;
      _point = MarketInfo(_symbol, MODE_POINT);
      _digit = (int)MarketInfo(_symbol, MODE_DIGITS); 
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
   }

   ~TradeController()
   {
      delete _signaler;
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         delete _breakeven[i];
      }
      i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         delete _trailing[i];
      }
   }
   
   bool IsTraderType(const int type)
   {
      return type == OP_BUY || type == OP_SELL;
   }

   void DoTrading()
   {
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         _breakeven[i].DoLogic();
      }
      i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         _trailing[i].UpdateStop();
      }
      if (IsDayStart())
      {
         if (TradeType != Sell)
         {
            _upOrder = DoBuy(DistanceToOrders);
         }
         if (TradeType != Buy)
         {
            _downOrder = DoSell(DistanceToOrders);
         }
         _signaler.SendNotifications("Creating orders");
      }
      else
      {
         SendNotifications();
         if (_upOrder != -1)
         {
            if (!OrderSelect(_upOrder, SELECT_BY_TICKET) || IsTraderType(OrderType()))
            {
               _middleOrder = DoSell(0);
               _middleOrderSide = -1;
               _upOrder = -1;
            }
         }
         if (_downOrder != -1)
         {
            if (!OrderSelect(_downOrder, SELECT_BY_TICKET) || IsTraderType(OrderType()))
            {
               _middleOrder = DoBuy(0);
               _middleOrderSide = 1;
               _downOrder = -1;
            }
         }
         if (_middleOrder != -1)
         {
            if (!OrderSelect(_middleOrder, SELECT_BY_TICKET) || IsTraderType(OrderType()))
            {
               _middleOrder = -1;
               if (_middleOrderSide == 1)
               {
                  _upOrder = DoBuy(DistanceToOrders);
               }
               else
               {
                  _downOrder = DoSell(DistanceToOrders);
               }
            }
         }
      }
   }
private:
   void SendNotifications()
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
            // new order
            changed = true;
            OnNewOrder();
         }
         else
         {
            active_still_active[index] = true; // order is still there
            if (OrderOpenPrice() != active_price[index] ||
                  OrderStopLoss() != active_stoploss[index] ||
                  OrderTakeProfit() != active_takeprofit[index] ||
                  OrderType() != active_type[index])
            {
               // already active order was changed
               changed = true;
               //messageChangedOrder(index);
            }
         }
      }

      // find closed orders. Orders that are in our cached list 
      // from the last tick but were not seen in the previous step.
      for (int index = 0; index < active_total; index++)
      {
         if (active_still_active[index] == false)
         {
            // the order must have been closed.
            changed = true;
            OnClosedTrade(active_ticket[index]);
         }
         
         // reset all these temporary flags again for the next tick
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

   void OnClosedTrade(const int ticket)
   {
      if (!OrderSelect(ticket, SELECT_BY_TICKET))
         return;

      if (OrderClosePrice() == OrderTakeProfit())
      {
         DeleteOrders();
      }
   }

   void OnNewOrder()
   {
      
   }

   void DeleteOrders()
   {
      _upOrder = -1;
      _downOrder = -1;
      _middleOrder = -1;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber && OrderType() != OP_BUY && OrderType() != OP_SELL)
         {
            if (!OrderDelete(OrderTicket()))
            {
               Print("Failed to delete the order " + IntegerToString(OrderTicket()));
            }
         }
      }
   }
    
   bool IsTradingTime(datetime dt)
   {
      if (start_time == end_time)
         return true;
      MqlDateTime current_time;
      if (!TimeToStruct(dt, current_time))
         return false;
      int current_t = (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
      if (start_time > end_time)
         return current_t >= start_time || current_t <= end_time;
      return current_t >= start_time && current_t <= end_time;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = MarketInfo(_symbol, MODE_TICKVALUE);
      double tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
      return (money / (unitCost / tickSize)) / amount;
   }

   double CalculateStop(const bool isBuy, const double amount, double basePrice)
   {
      if (StopType == StopLimitDoNotUse)
         return 0;

      int direction = isBuy ? 1 : -1;
      switch (StopType)
      {
         case StopLimitPercent:
            return basePrice - basePrice * Stop / 100.0 * direction;
         case StopLimitPips:
            return basePrice - Stop * _mult * _point * direction;
         case StopLimitDollar:
            return basePrice - CalculateSLShift(amount, Stop) * direction;
      }
      return 0.0;
   }

   double CalculateLimit(const bool isBuy, const double limit, const StopLimitType limitType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (limitType)
      {
         case StopLimitPercent:
            return basePrice + basePrice * limit / 100.0 * direction;
         case StopLimitPips:
            return basePrice + limit * _mult * _point * direction;
         case StopLimitDollar:
            return basePrice + CalculateSLShift(amount, limit) * direction;
      }
      return 0.0;
   }
   
   double CalculateLimit(const bool isBuy, const double amount, double basePrice)
   {
      if (LimitType == StopLimitDoNotUse)
         return 0;

      return CalculateLimit(isBuy, Limit, LimitType, amount, basePrice);
   }

   int DoBuy(const int shift)
   {
      double rate = iOpen(_symbol, PERIOD_D1, 0) + shift * _pipSize;
      double amount = 0.0;
      double stop = 0.0;
      if (LotsType == PositionSizeRisk)
      {
         stop = CalculateStop(true, 0.0, rate);
         amount = GetLots(rate - stop);
      }
      else
      {
         amount = GetLots(0.0);
         stop = CalculateStop(true, amount, rate);
      }
      if (amount == 0.0)
         return -1;
      OrderBuilder *orderBuilder = new OrderBuilder();
      int order = orderBuilder
         .SetSide(BuySide)
         .SetRate(rate)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(Slippage)
         .SetMagicNumber(MagicNumber)
         .SetStop(stop)
         .SetLimit(CalculateLimit(true, amount, rate))
         .Execute();
      delete orderBuilder;
      if (order != -1)
      {
         _lastbartime = iTime(NULL, _timeframe, 0);
         if (BreakevenTriggerType != StopLimitDoNotUse)
            CreateBreakeven(order);
         switch (Trailing)
         {
            case TrailingPips:
               CreateTrailing(order, rate - stop, TrailingStep * _pipSize);
               break;
            case TrailingPercent:
               CreateTrailing(order, rate - stop, (rate - stop) * TrailingStep / 100.0);
               break;
         }
      }
      else
      {
         Print("Failed to open long position: " + IntegerToString(GetLastError()));
      }
      return order;
   }

   int DoSell(const int shift)
   {
      double rate = iOpen(_symbol, PERIOD_D1, 0) - shift * _pipSize;
      double amount = 0.0;
      double stop = 0.0;
      if (LotsType == PositionSizeRisk)
      {
         stop = CalculateStop(false, 0.0, rate);
         amount = GetLots(stop - rate);
      }
      else
      {
         amount = GetLots(0.0);
         stop = CalculateStop(false, amount, rate);
      }
      if (amount == 0.0)
         return -1;
      OrderBuilder *orderBuilder = new OrderBuilder();
      int order = orderBuilder
         .SetSide(SellSide)
         .SetRate(rate)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(Slippage)
         .SetMagicNumber(MagicNumber)
         .SetStop(stop)
         .SetLimit(CalculateLimit(false, amount, rate))
         .Execute();
      delete orderBuilder;
      if (order != -1)
      {
         _lastbartime = iTime(NULL, _timeframe, 0);
         if (BreakevenTriggerType != StopLimitDoNotUse)
            CreateBreakeven(order);
         switch (Trailing)
         {
            case TrailingPips:
               CreateTrailing(order, stop - rate, TrailingStep * _pipSize);
               break;
            case TrailingPercent:
               CreateTrailing(order, stop - rate, (stop - rate) * TrailingStep / 100.0);
               break;
         }
      }
      else
      {
         Print("Failed to open short position: " + IntegerToString(GetLastError()));
      }
      return order;
   }

   double GetLotsForMoney(const double money)
   {
      double marginRequired = MarketInfo(_symbol, MODE_MARGINREQUIRED);
      double minVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN);
      if (marginRequired <= 0.0)
      {
         Print("Margin is 0. Server misconfiguration?");
         return 0.0;
      }
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      double lots = floor((money / marginRequired) / lotStep) * lotStep;
      if (minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
         return maxVolume;
      return lots;
   }

   double GetLots(double stopDistance)
   {
      switch (LotsType)
      {
         case PositionSizeAmount:
            return GetLotsForMoney(Lots);
         case PositionSizeContract:
            return Lots;
         case PositionSizeEquity:
            return GetLotsForMoney(AccountEquity() * Lots / 100.0);
         case PositionSizeRisk:
         {
            double affordableLoss = AccountEquity() * Lots / 100.0;
            double unitCost = MarketInfo(_symbol, MODE_TICKVALUE);
            double tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
               return 0;
            double tarketLots = affordableLoss / possibleLoss;
            double lotsMin = MarketInfo(_symbol, MODE_MINLOT);
            return MathRound(tarketLots / lotsMin) * lotsMin;
         }
      }
      return Lots;
   }

   int CloseTrades(const int side)
   {
      int closedPositions = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderMagicNumber() == MagicNumber
               && OrderSymbol() == _symbol
               && OrderType() == side)
            {
               if (OrderType() == OP_BUY)
               {
                  if (!OrderClose(OrderTicket(), OrderLots(), Bid, 5)) 
                  {
                     Print("LastError = ", GetLastError());
                  }
                  else
                  {
                     ++closedPositions;
                  }
               }
               if (OrderType() == OP_SELL)
               {
                  if (!OrderClose(OrderTicket(), OrderLots(), Ask, 5)) 
                  {
                     Print("LastError = ", GetLastError());
                  }
                  else
                  {
                     ++closedPositions;
                  }
               }
            }
         }
      }
      return closedPositions;
   }

   void CreateBreakeven(const int order)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
         return;

      double target = OrderType() == OP_BUY ? Ask : Bid;
      double trigger = CalculateLimit(OrderType() == OP_BUY, BreakevenTrigger, BreakevenTriggerType, OrderLots(), target);
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         if (_breakeven[i].SetOrder(order, trigger, target))
         {
            return;
         }
      }

      ArrayResize(_breakeven, i_count + 1);
      _breakeven[i_count] = new BreakevenController();
      _breakeven[i_count].SetOrder(order, trigger, target);
   }

   void CreateTrailing(const int order, const double stop, const double trailingStep)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
         return;

      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].SetOrder(order, stop, trailingStep))
         {
            return;
         }
      }

      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = new TrailingControler();
      _trailing[i_count].SetOrder(order, stop, trailingStep);
   }
};

int ParseTime(const string time)
{
   int time_parsed = (int)StringToInteger(time);
   int seconds = time_parsed % 100;
   if (seconds > 59)
   {
      Print("Incorrect number of seconds in " + time);
      return -1;
   }
   time_parsed /= 100;
   int minutes = time_parsed % 100;
   if (minutes > 59)
   {
      Print("Incorrect number of minutes in " + time);
      return -1;
   }
   time_parsed /= 100;
   int hours = time_parsed % 100;
   if (hours > 23)
   {
      Print("Incorrect number of hours in " + time);
      return -1;
   }
   return (hours * 60 + minutes) * 60 + seconds;
}
int start_time;
int end_time;
TradeController *controller;

int OnInit()
{
   controller = new TradeController(_Symbol, (ENUM_TIMEFRAMES)_Period);
   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete controller;
}

void OnTick()
{
   controller.DoTrading();
}

