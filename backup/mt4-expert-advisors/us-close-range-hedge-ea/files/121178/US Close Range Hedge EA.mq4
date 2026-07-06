// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66658

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

extern string   TradingSection            = ""; // == Trading ==
extern TradingDirection TradeType = Both; // What trades should be taken
extern double Lots            = 0.1; // Position size
extern PositionSizeType LotsType = PositionSizeContract; // Position size type
extern int Slippage           = 3;
extern TrailingType Trailing = TrailingDontUse; // Trailing type
extern double TrailingStep = 10; // Trailing step
extern StopLimitType BreakevenTriggerType = StopLimitPips; // Trigger type for the breakeven
extern double BreakevenTrigger = 10; // Trigger for the breakeven
extern string   OtherSection            = ""; // == Other ==
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

// Trailing controller v.1.3
class TrailingControler
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   double _stop;
   double _trailingStep;
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
      _finished = false;
      _order = order;
      _stop = stop;
      _trailingStep = trailingStep;
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
         while (newStop + _trailingStep < Ask - _stop)
         {
            newStop += _trailingStep;
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
         while (newStop - _trailingStep > Bid + _stop)
         {
            newStop -= _trailingStep;
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

      if (IsOpenTime(current_time))
      {
         double min = EMPTY_VALUE;
         double max = EMPTY_VALUE;
         for (int i = 0; i < 3; ++i)
         {
            double high = iHigh(_symbol, PERIOD_H1, i);
            double low = iLow(_symbol, PERIOD_H1, i);
            if (min == EMPTY_VALUE)
            {
               min = low;
               max = high;
            }
            else
            {
               if (min > low)
                  min = low;
               if (max < high)
                  max = high;
            }
         }

         DoBuy(max, min);
         DoSell(max, min);
      }
   }
private:

   bool IsOpenTime(datetime dt)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(dt, current_time))
         return false;
      return current_time.hour == 20 && current_time.min == 0;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = MarketInfo(_symbol, MODE_TICKVALUE);
      double tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
      return (money / (unitCost / tickSize)) / amount;
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
   
   void DoBuy(double high, double low)
   {
      double buyAmount = 0.0;
      double stop = low;
      if (LotsType == PositionSizeRisk)
      {
         buyAmount = GetLots(Ask - stop);
      }
      else
      {
         buyAmount = GetLots(0.0);
      }
      if (buyAmount == 0.0)
         return;
      OrderBuilder *orderBuilder = new OrderBuilder();
      int order = orderBuilder
         .SetSide(BuySide)
         .SetInstrument(_symbol)
         .SetAmount(buyAmount)
         .SetSlippage(Slippage)
         .SetMagicNumber(MagicNumber)
         .SetStop(stop)
         .SetLimit(Ask + (high - low) * 2)
         .SetRate(high)
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

   void DoSell(double high, double low)
   {
      double sellAmount = 0.0;
      double stop = high;
      if (LotsType == PositionSizeRisk)
      {
         sellAmount = GetLots(stop - Bid);
      }
      else
      {
         sellAmount = GetLots(0.0);
      }
      if (sellAmount == 0.0)
         return;
      OrderBuilder *orderBuilder = new OrderBuilder();
      int order = orderBuilder
         .SetSide(SellSide)
         .SetInstrument(_symbol)
         .SetAmount(sellAmount)
         .SetSlippage(Slippage)
         .SetMagicNumber(MagicNumber)
         .SetStop(stop)
         .SetLimit(Bid - (high - low) * 2)
         .SetRate(low)
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
TradeController *controller = NULL;

void OnTick()
{
   controller.DoTrading();
}

int OnInit()
{
   controller = new TradeController(_Symbol, (ENUM_TIMEFRAMES)_Period);

   if(!IsDllsAllowed() && Advanced_Alert) {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete controller;
}