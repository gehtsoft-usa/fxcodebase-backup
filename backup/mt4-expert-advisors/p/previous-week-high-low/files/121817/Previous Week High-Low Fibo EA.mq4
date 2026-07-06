// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66866

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
#property version   "1.0"
#property strict

extern double Fib1Level = 0.382;
extern double Fib2Level = 1.27;

// Trade controller v.1.14

enum TradingDirection
{
   BuySideOnly,
   SellSideOnly,
   BothSides
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
   TrailingPercent, // Use trailing in % of stop
   TrailingATR // Use ATR trailing
};

extern string GeneralSection = ""; // == General ==
extern double Lots = 0.1; // Position size
extern PositionSizeType LotsType = PositionSizeContract; // Position size type
extern int Slippage = 3;
extern TradingDirection TradeType = BothSides; // What trades should be taken
PositionDirection LogicType = DirectLogic; // Logic type
extern bool close_on_opposite = true; // Close on opposite signal

extern string SLSection            = ""; // == Stop loss/TakeProfit ==
extern StopLimitType StopType = StopLimitPips; // Stop loss type
extern double Stop            = 10; // Stop loss value
extern TrailingType Trailing = TrailingDontUse; // Trailing type
extern double TrailingStep = 10; // Trailing step
extern double ATRTrailingMultiplier = 0.1; // Multiplier for ATR trailing
extern StopLimitType BreakevenTriggerType = StopLimitPips; // Trigger type for the breakeven
extern double BreakevenTrigger = 10; // Trigger for the breakeven

extern string OtherSection            = ""; // == Other ==
extern int MagicNumber        = 42; // Magic number
extern string StartTime = "000000"; // Start time in hhmmss format
extern string EndTime = "235959"; // End time in hhmmss format
extern bool MandatoryClosing = false; // Mandatory closing for non-trading time
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

// Market order builder
// v.1.0.0

enum OrderSide
{
   BuySide,
   SellSide
};

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
public:
   MarketOrderBuilder *SetSide(const OrderSide orderSide)
   {
      _orderSide = orderSide;
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
   
   MarketOrderBuilder *SetStop(const double stop)
   {
      _stop = NormalizeDouble(stop, Digits);
      return &this;
   }
   
   MarketOrderBuilder *SetLimit(const double limit)
   {
      _limit = NormalizeDouble(limit, Digits);
      return &this;
   }
   
   MarketOrderBuilder *SetMagicNumber(const int magicNumber)
   {
      _magicNumber = magicNumber;
      return &this;
   }
   
   int Execute()
   {
      int orderType = _orderSide == BuySide ? OP_BUY : OP_SELL;
      double minstoplevel = MarketInfo(_instrument, MODE_STOPLEVEL); 
      
      double rate = _orderSide == BuySide ? Ask : Bid;
      int order = OrderSend(_instrument, orderType, _amount, rate, _slippage, _stop, _limit, NULL, _magicNumber);
      if (order == -1)
      {
         int error = GetLastError();
         switch (error)
         {
            case 4109:
               Print("Trading is not allowed");
               break;
            case ERR_INVALID_STOPS:
               {
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
                  if (_stop != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _stop) / point) < minStopDistancePoints)
                     {
                        Print("Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points");
                     }
                     else
                     {
                        Print("Invalid stop loss in the request");
                     }
                  }
                  else if (_limit != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _limit) / point) < minStopDistancePoints)
                     {
                        Print("Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points");
                     }
                     else
                     {
                        Print("Invalid take profit in the request");
                     }
                  }
                  else
                  {
                     Print("Invalid take profit in the request");
                  }
               }
               break;
            default:
               Print("Failed to create order: " + IntegerToString(error));
               break;
         }
      }
      return order;
   }
};

// Trailing controller v.1.5

enum TrailingControllerType
{
   TrailingControllerTypeStandard,
   TrailingControllerTypeATR
};

interface ITrailingController
{
public:
   virtual bool IsFinished() = 0;
   virtual void UpdateStop() = 0;
   virtual TrailingControllerType GetType() = 0;
};

class TrailingControllerATR : public ITrailingController
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   int _atrPeriod;
   double _multiplier;
   double _tickSize;
   int _digits;
   double _stop;
   ENUM_TIMEFRAMES _timeframe;
public:
   TrailingControllerATR(Signaler *signaler = NULL)
   {
      _finished = true;
      _order = -1;
      _signaler = signaler;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const int order, const double stop, const int atrPeriod, const double multiplier, ENUM_TIMEFRAMES timeframe)
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
      _stop = stop;
      _atrPeriod = atrPeriod;
      _multiplier = multiplier;
      _timeframe = timeframe;

      _finished = false;
      _order = order;
      
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
      double trailingStep = iATR(OrderSymbol(), _timeframe, _atrPeriod, 0) * _multiplier;
      if (type == OP_BUY)
      {
         double newStop = OrderStopLoss();
         while (NormalizeDouble(newStop + trailingStep, _digits) < NormalizeDouble(Ask - _stop, _digits))
         {
            newStop = NormalizeDouble(newStop + trailingStep, _digits);
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
         while (NormalizeDouble(newStop - trailingStep, _digits) > NormalizeDouble(Bid + _stop, _digits))
         {
            newStop = NormalizeDouble(newStop - trailingStep, _digits);
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

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeATR;
   }
};

class TrailingController : public ITrailingController
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   double _stop;
   double _trailingStep;
   double _tickSize;
   int _digits;
public:
   TrailingController(Signaler *signaler = NULL)
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

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeStandard;
   }
};

// Trade calculator v.1.1
class TradeCalculator
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digit;
public:
   TradeCalculator(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digit = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
   }

   double GetPipSize()
   {
      return _pipSize;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   double GetBreakevenPrice(const int side, const int magicNumber)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      double totalPL = 0;
      double totalAmount = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderMagicNumber() == magicNumber
               && OrderSymbol() == _symbol
               && OrderType() == side)
            {
               totalAmount += OrderLots() / lotStep;
               if (side == OP_BUY)
                  totalPL += (Bid - OrderOpenPrice()) * (OrderLots() / lotStep);
               else
                  totalPL += (OrderOpenPrice() - Ask) * (OrderLots() / lotStep);
            }
         }
      }
      double shift = -(totalPL / totalAmount);
      if (side == OP_BUY)
      {
         return MarketInfo(_symbol, MODE_BID) + shift;
      }
      return MarketInfo(_symbol, MODE_ASK) - shift;
   }
   
   double CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (takeProfitType)
      {
         case StopLimitPercent:
            return basePrice + basePrice * takeProfit / 100.0 * direction;
         case StopLimitPips:
            return basePrice + takeProfit * _mult * _point * direction;
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
            return basePrice - stopLoss * _mult * _point * direction;
         case StopLimitDollar:
            return basePrice - CalculateSLShift(amount, stopLoss) * direction;
      }
      return 0.0;
   }

   double GetLots(PositionSizeType lotsType, double lotsValue, double stopDistance)
   {
      switch (lotsType)
      {
         case PositionSizeAmount:
            return GetLotsForMoney(lotsValue);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(AccountEquity() * lotsValue / 100.0);
         case PositionSizeRisk:
         {
            double affordableLoss = AccountEquity() * lotsValue / 100.0;
            double unitCost = MarketInfo(_symbol, MODE_TICKVALUE);
            double tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
               return 0;
            return LimitLots(RoundLots(affordableLoss / possibleLoss));
         }
      }
      return Lots;
   }

private:
   double GetLotsForMoney(const double money)
   {
      double marginRequired = MarketInfo(_symbol, MODE_MARGINREQUIRED);
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
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN);
      if (minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
         return maxVolume;
      return lots;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = MarketInfo(_symbol, MODE_TICKVALUE);
      double tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
      return (money / (unitCost / tickSize)) / amount;
   }
   
};

// Martingale strategy v.1.0

interface IMartingaleTakeProfitStrategy
{
public:
   virtual void DoLogic(const int side, const int magicNumber) = 0;
};

// Martingale turned off
class MartingaleStrategyTakeProfitDoNotUse : public IMartingaleTakeProfitStrategy
{
public:
   void DoLogic(const int side, const int magicNumber)
   {
      // Do nothing
   }
};

// Moves take profit to the breakeven level + n pips
class MartingaleTakeProfitStrategyBreakeven : public IMartingaleTakeProfitStrategy
{
   TradeCalculator *_calculator;
   double _takeProfit;
   Signaler *_signaler;
public:
   MartingaleTakeProfitStrategyBreakeven(TradeCalculator *calculator, const double takeProfit, Signaler *signaler)
   {
      _calculator = calculator;
      _takeProfit = takeProfit;
      _signaler = signaler;
   }
   
   void DoLogic(const int side, const int magicNumber)
   {
      double averagePrice = _calculator.GetBreakevenPrice(side, magicNumber);
      double pipSize = _calculator.GetPipSize();
      double takeProfit = side == OP_BUY ? averagePrice + _takeProfit * pipSize : averagePrice - _takeProfit * pipSize;
      if (_signaler != NULL)
         _signaler.SendNotifications("Moving martingale take profit to " + DoubleToStr(takeProfit));
      string symbol = _calculator.GetSymbol();
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (OrderMagicNumber() == magicNumber
               && OrderSymbol() == symbol
               && OrderType() == side)
            {
               int res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), takeProfit, 0, CLR_NONE);
               if (res == 0)
               {
                  int error = GetLastError();
                  switch (error)
                  {
                     case ERR_INVALID_TICKET:
                        break;
                  }
               }
            }
         }
      }
   }
};

class TradeController
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _point;
   datetime _lastbartime;
   int _digit;
   double _mult;
   double _pipSize;
   double _lastLot;
   BreakevenController *_breakeven[];
   ITrailingController *_trailing[];
   Signaler *_signaler;
   int _lastOrder;
   datetime _lastBarDate;
   TradeCalculator *_calculator;
   IMartingaleTakeProfitStrategy *_martingaleTakeProfitStrategy;
public:
   TradeController(TradeCalculator *calculator, const string symbol, ENUM_TIMEFRAMES timeframe, Signaler *signaler)
   {
      _calculator = calculator;
      _martingaleTakeProfitStrategy = NULL;
      _signaler = signaler;
      _timeframe = timeframe;
      _symbol = symbol;
      _point = MarketInfo(_symbol, MODE_POINT);
      _digit = (int)MarketInfo(_symbol, MODE_DIGITS); 
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _lastLot = Lots;
      _lastOrder = -1;
   }

   ~TradeController()
   {
      delete _martingaleTakeProfitStrategy;
      delete _calculator;
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

   void SetMartingaleTakeProfitStrategy(IMartingaleTakeProfitStrategy *strategy)
   {
      _martingaleTakeProfitStrategy = strategy;
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
      datetime current_time = iTime(_symbol, _timeframe, 0);
      if (_lastBarDate != current_time)
      {
         OnBar();
         _lastBarDate = current_time;
      }

      if (!IsTradingTime(current_time))
      {
         if (MandatoryClosing)
         {
            int buyPositionsClosed = CloseTrades(OP_BUY);
            int sellPositionsClosed = CloseTrades(OP_SELL);
            if (buyPositionsClosed + sellPositionsClosed > 0)
               _signaler.SendNotifications("Mandatory closing", "Mandatory closing", _symbol, "");
         }
         return;
      }
      if (current_time == _lastbartime)
      {
         return;
      }
   }
private:
   void OnBar()
   {
      if (iBarShift(_symbol, PERIOD_W1, iTime(_symbol, _timeframe, 0)) != iBarShift(_symbol, PERIOD_W1, iTime(_symbol, _timeframe, 1)))
      {
         CloseTrades(OP_BUY);
         CloseTrades(OP_SELL);
         if (iOpen(_symbol, PERIOD_W1, 1) > iClose(_symbol, PERIOD_W1, 1))
         {
            if (TradeType == SellSideOnly)
               return;
            DoBuy();
         }
         else
         {
            if (TradeType == BuySideOnly)
               return;
            DoSell();
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

   void DoBuy(double amount = 0.0)
   {
      if (close_on_opposite)
      {
         CloseTrades(OP_SELL);
      }
      double week_high = iHigh(_symbol, PERIOD_W1, 1);
      double week_low = iLow(_symbol, PERIOD_W1, 1);
      double range = week_high - week_low;
      double fib1 = week_low + range * Fib1Level;
      double takeProfit = week_low + range * Fib2Level;

      double stop = 0.0;
      if (LotsType == PositionSizeRisk)
      {
         stop = _calculator.CalculateStopLoss(true, Stop, StopType, 0.0, Ask);
         amount = _calculator.GetLots(LotsType, Lots, Ask - stop);
      }
      else
      {
         if (amount == 0.0)
            amount = _calculator.GetLots(LotsType, Lots, 0.0);
         stop = _calculator.CalculateStopLoss(true, Stop, StopType, amount, Ask);
      }
      if (amount == 0.0)
         return;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      int order = orderBuilder
         .SetSide(BuySide)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(Slippage)
         .SetMagicNumber(MagicNumber)
         .SetStop(stop)
         .SetLimit(takeProfit)
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
               CreateTrailing(order, Ask - stop, TrailingStep * _pipSize);
               break;
            case TrailingPercent:
               CreateTrailing(order, Ask - stop, (Ask - stop) * TrailingStep / 100.0);
               break;
            case TrailingATR:
               CreateATRTrailing(order, Ask - stop, (int)TrailingStep, ATRTrailingMultiplier);
               break;
         }
         _lastOrder = order;
         _lastLot = amount;
      }
      else
      {
         Print("Failed to open long position: " + IntegerToString(GetLastError()));
      }
   }

   void DoSell(double amount = 0.0)
   {
      if (close_on_opposite)
      {
         CloseTrades(OP_BUY);
      }
      double week_high = iHigh(_symbol, PERIOD_W1, 1);
      double week_low = iLow(_symbol, PERIOD_W1, 1);
      double range = week_high - week_low;
      double fib1 = week_high - range * Fib1Level;
      double takeProfit = week_high - range * Fib2Level;

      double stop = 0.0;
      if (LotsType == PositionSizeRisk)
      {
         stop = _calculator.CalculateStopLoss(false, Stop, StopType, 0.0, Bid);
         amount = _calculator.GetLots(LotsType, Lots, stop - Bid);
      }
      else
      {
         if (amount == 0.0)
            amount = _calculator.GetLots(LotsType, Lots, 0.0);
         stop = _calculator.CalculateStopLoss(false, Stop, StopType, amount, Bid);
      }
      if (amount == 0.0)
         return;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      int order = orderBuilder
         .SetSide(SellSide)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(Slippage)
         .SetMagicNumber(MagicNumber)
         .SetStop(stop)
         .SetLimit(takeProfit)
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
               CreateTrailing(order, stop - Bid, TrailingStep * _pipSize);
               break;
            case TrailingPercent:
               CreateTrailing(order, stop - Bid, (stop - Bid) * TrailingStep / 100.0);
               break;
            case TrailingATR:
               CreateATRTrailing(order, stop - Bid, (int)TrailingStep, ATRTrailingMultiplier);
               break;
         }
         _lastOrder = order;
         _lastLot = amount;
      }
      else
      {
         Print("Failed to open short position: " + IntegerToString(GetLastError()));
      }
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
      double trigger = _calculator.CalculateTakeProfit(OrderType() == OP_BUY, BreakevenTrigger, BreakevenTriggerType, OrderLots(), target);
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

   void CreateATRTrailing(const int order, const double stop, const int atrPeriod, const double multiplier)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
         return;

      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeATR)
            continue;
         TrailingControllerATR *trailingController = (TrailingControllerATR *)_trailing[i];
         if (trailingController.SetOrder(order, stop, atrPeriod, multiplier, _timeframe))
         {
            return;
         }
      }

      TrailingControllerATR *trailingController = new TrailingControllerATR();
      trailingController.SetOrder(order, stop, atrPeriod, multiplier, _timeframe);

      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }

   void CreateTrailing(const int order, const double stop, const double trailingStep)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
         return;

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

      TrailingController *trailingController = new TrailingController();
      trailingController.SetOrder(order, stop, trailingStep);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
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
   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   start_time = ParseTime(StartTime);
   if (start_time == -1)
      return INIT_FAILED;
   end_time = ParseTime(EndTime);
   if (end_time == -1)
      return INIT_FAILED;
   
   TradeCalculator *tradeCalculator = new TradeCalculator(_Symbol);
   Signaler *signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   controller = new TradeController(tradeCalculator, _Symbol, (ENUM_TIMEFRAMES)_Period, signaler);
   controller.SetMartingaleTakeProfitStrategy(new MartingaleStrategyTakeProfitDoNotUse());

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
