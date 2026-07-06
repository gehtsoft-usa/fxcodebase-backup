// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66670

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

// Trade controller v.1.8
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

extern int BBLength = 20; // BB length
extern double BBDeviation = 2; // BB deviation
extern int ADXLength = 14; // ADX length
extern int ADXEntryLevel1 = 15; // ADX entry level 1
extern int ADXEntryLevel2 = 20; // ADX entry level 2
extern int ADXEntryLevel3 = 25; // ADX entry level 3
extern int ADXEntryLevel4 = 30; // ADX entry level 4
extern int ADXEntryLevel5 = 45; // ADX entry level 5
extern int ADXExitLevel1 = 75; // ADX exit level 1
extern int ADXExitLevel2 = 65; // ADX exit level 2
extern int ADXExitLevel3 = 55; // ADX exit level 3
extern int ADXExitLevel4 = 45; // ADX exit level 4
extern int ADXExitLevel5 = 35; // ADX exit level 5
extern TradingDirection TradeType = Both; // What trades should be taken
extern double Lots            = 0.1; // Position size
extern PositionSizeType LotsType = PositionSizeContract; // Position size type
extern int Slippage           = 3;
extern bool close_on_opposite = true; // Close on opposite
extern StopLimitType StopType = StopLimitPips; // Stop loss type
extern double Stop            = 10; // Stop loss value
extern TrailingType Trailing = TrailingDontUse; // Trailing type
extern double TrailingStep = 10; // Trailing step
extern StopLimitType LimitType = StopLimitPips; // Take profit type
extern double Limit           = 10; // Take profit value
extern StopLimitType BreakevenTriggerType = StopLimitPips; // Trigger type for the breakeven
extern double BreakevenTrigger = 10; // Trigger for the breakeven
extern int MagicNumber        = 42; // Magic number
extern PositionDirection LogicType = DirectLogic; // Logic type
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
                        Print("Your stop level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points");
                     }
                     else
                     {
                        Print("Invalid stop in the request");
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
                     Print("Invalid stop in the request");
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

class TradeController
{
   bool IsExitBuyCondition()
   {
      if ((TradeType == Sell && LogicType == DirectLogic)
         || (TradeType == Buy && LogicType == ReversalLogic))
      {
         return false;
      }
      return IsADXExitConfirmed(0);
   }

   bool IsExitSellCondition()
   {
      if ((TradeType == Buy && LogicType == DirectLogic)
         || (TradeType == Sell && LogicType == ReversalLogic))
      {
         return false;
      }
      return IsADXExitConfirmed(0);
   }
   
   bool IsADXExitConfirmed(const int period)
   {
      double adxCurrent = iADX(_symbol, _timeframe, ADXLength, PRICE_CLOSE, MODE_MAIN, period);
      double adxPrevious = iADX(_symbol, _timeframe, ADXLength, PRICE_CLOSE, MODE_MAIN, period + 1);
      for (int i = 0; i < 5; ++i)
      {
         if (adxCurrent < exitLevels[i] && adxPrevious >= exitLevels[i])
         {
            return true;
         }
      }
      return false;
   }
   
   bool IsADXConfirmed(const int period)
   {
      double adxCurrent = iADX(_symbol, _timeframe, ADXLength, PRICE_CLOSE, MODE_MAIN, period);
      double adxPrevious = iADX(_symbol, _timeframe, ADXLength, PRICE_CLOSE, MODE_MAIN, period + 1);
      for (int i = 0; i < 5; ++i)
      {
         if (adxCurrent > entryLevels[i] && adxPrevious <= entryLevels[i])
         {
            return true;
         }
      }
      return false;
   }
   
   double GetSignal(const int period)
   {
      double currentClose = iClose(_symbol, _timeframe, period);
      double previousClose = iClose(_symbol, _timeframe, period + 1);
      
      double currentUpper = iBands(_symbol, _timeframe, BBLength, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, period);
      double previousUpper = iBands(_symbol, _timeframe, BBLength, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, period + 1);
      if (currentUpper < currentClose && previousUpper >= previousClose)
         return currentClose;
      
      double currentLower = iBands(_symbol, _timeframe, BBLength, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, period);
      double previousLower = iBands(_symbol, _timeframe, BBLength, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, period + 1);
      if (currentLower > currentClose && previousLower <= previousClose)
         return -currentClose;
      
      return 0;
   }
   
   double GetSignal()
   {
      for (int i = 0; i < iBars(_symbol, _timeframe) - 1; ++i)
      {
         double signal = GetSignal(i);
         if (signal != 0.0)
            return signal;
      }
      return 0;
   }

   bool IsBuyCondition()
   {
      if ((TradeType == Sell && LogicType == DirectLogic)
         || (TradeType == Buy && LogicType == ReversalLogic))
      {
         return false;
      }
      if (!IsADXConfirmed(0))
         return false;
      double signal = GetSignal();
      if (signal > 0)
         return iClose(_symbol, _timeframe, 0) > signal;
      return false;
   }

   bool IsSellCondition()
   {
      if ((TradeType == Buy && LogicType == DirectLogic)
         || (TradeType == Sell && LogicType == ReversalLogic))
      {
         return false;
      }
      if (!IsADXConfirmed(0))
         return false;
      double signal = GetSignal();
      if (signal < 0)
         return iClose(_symbol, _timeframe, 0) < -signal;
      return false;
   }
   
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
public:
   TradeController(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
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
      if (current_time == _lastbartime)
      {
         return;
      }

      if (IsExitBuyCondition())
      {
         switch (LogicType)
         {
            case DirectLogic:
               if (CloseTrades(OP_BUY))
                  _signaler.SendNotifications(EXIT_BUY_SIGNAL);
               break;
            case ReversalLogic:
               if (CloseTrades(OP_SELL))
                  _signaler.SendNotifications(EXIT_SELL_SIGNAL);
               break;
         }
      }
      if (IsExitSellCondition())
      {
         switch (LogicType)
         {
            case DirectLogic:
               if (CloseTrades(OP_SELL))
                  _signaler.SendNotifications(EXIT_SELL_SIGNAL);
               break;
            case ReversalLogic:
               if (CloseTrades(OP_BUY))
                  _signaler.SendNotifications(EXIT_BUY_SIGNAL);
               break;
         }
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

      if (IsBuyCondition())
      {
         switch (LogicType)
         {
            case DirectLogic:
               DoBuy();
               _signaler.SendNotifications(ENTER_BUY_SIGNAL);
               break;
            case ReversalLogic:
               DoSell();
               _signaler.SendNotifications(ENTER_SELL_SIGNAL);
               break;
         }
      }
      if (IsSellCondition())
      {
         switch (LogicType)
         {
            case DirectLogic:
               DoSell();
               _signaler.SendNotifications(ENTER_SELL_SIGNAL);
               break;
            case ReversalLogic:
               DoBuy();
               _signaler.SendNotifications(ENTER_BUY_SIGNAL);
               break;
         }
      }
   }
private:
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

   void DoBuy()
   {
      if (close_on_opposite)
      {
         CloseTrades(OP_SELL);
      }

      double amount = 0.0;
      double stop = 0.0;
      if (LotsType == PositionSizeRisk)
      {
         stop = CalculateStop(true, 0.0, Ask);
         amount = GetLots(Ask - stop);
      }
      else
      {
         amount = GetLots(0.0);
         stop = CalculateStop(true, amount, Ask);
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
         .SetLimit(CalculateLimit(true, amount, Ask))
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
         }
      }
      else
      {
         Print("Failed to open long position: " + IntegerToString(GetLastError()));
      }
   }

   void DoSell()
   {
      if (close_on_opposite)
      {
         CloseTrades(OP_BUY);
      }

      double amount = 0.0;
      double stop = 0.0;
      if (LotsType == PositionSizeRisk)
      {
         stop = CalculateStop(false, 0.0, Bid);
         amount = GetLots(stop - Bid);
      }
      else
      {
         amount = GetLots(0.0);
         stop = CalculateStop(false, amount, Bid);
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
         .SetLimit(CalculateLimit(false, amount, Bid))
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
         }
      }
      else
      {
         Print("Failed to open short position: " + IntegerToString(GetLastError()));
      }
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

double entryLevels[5];
double exitLevels[5];

int OnInit()
{
   entryLevels[0] = ADXEntryLevel1;
   entryLevels[1] = ADXEntryLevel2;
   entryLevels[2] = ADXEntryLevel3;
   entryLevels[3] = ADXEntryLevel4;
   entryLevels[4] = ADXEntryLevel5;
   exitLevels[0] = ADXExitLevel1;
   exitLevels[1] = ADXExitLevel2;
   exitLevels[2] = ADXExitLevel3;
   exitLevels[3] = ADXExitLevel4;
   exitLevels[4] = ADXExitLevel5;
   if(!IsDllsAllowed() && Advanced_Alert)
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
   controller = new TradeController(_Symbol, (ENUM_TIMEFRAMES)_Period);

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
