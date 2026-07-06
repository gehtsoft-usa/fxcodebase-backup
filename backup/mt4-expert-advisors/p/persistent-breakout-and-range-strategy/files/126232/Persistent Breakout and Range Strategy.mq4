// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68436

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

enum TradingMode
{
   TradingModeRange, // Range
   TradingModeBreakout // Breakout
};
enum OrderSide
{
   BuySide,
   SellSide
};
enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk // Risk in % of equity
};
enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $,
   StopLimitRiskReward, // Set in % of stop loss
   StopLimitAbsolute // Set in absolite value (rate)
};

input TradingMode trading_mode = TradingModeBreakout; // Trading mode
input double X = 10; // X pips
input double Y = 10; // Y pips
input double lots_value = 1; // Lots
input double stop_loss = 10; // Stop loss, pips
input double take_profit = 10; // Take profit, pips
input int slippage_points = 5; // Slippage, points
input int magic_number = 42; // Magic number
bool ecn_broker = false;

// Instrument info v.1.4
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

// Order builder v.1.3
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
   string _comment;
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
   
   int Execute(string &errorMessage)
   {
      InstrumentInfo instrument(_instrument);
      double rate = instrument.RoundRate(_rate);
      double sl = instrument.RoundRate(_stop);
      double tp = instrument.RoundRate(_limit);
      int orderType;
      if (_orderSide == BuySide)
         orderType = rate > instrument.GetAsk() ? OP_BUYSTOP : OP_BUYLIMIT;
      else
         orderType = rate < instrument.GetBid() ? OP_SELLSTOP : OP_SELLLIMIT;
      bool ecnBroker = false;
      int order;
      if (ecn_broker)
         order = OrderSend(_instrument, orderType, _amount, rate, _slippage, 0, 0, _comment, _magicNumber);
      else
         order = OrderSend(_instrument, orderType, _amount, rate, _slippage, sl, tp, _comment, _magicNumber);
      if (order == -1)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_TRADE_NOT_ALLOWED:
               errorMessage = "Trading is not allowed";
               break;
            case ERR_INVALID_STOPS:
               {
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  int minStopDistancePoints = (int)MarketInfo(_instrument, MODE_STOPLEVEL);
                  if (sl != 0.0 && MathRound(MathAbs(_rate - sl) / point) < minStopDistancePoints)
                     errorMessage = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                  else if (tp != 0.0 && MathRound(MathAbs(_rate - tp) / point) < minStopDistancePoints)
                     errorMessage = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                  else
                  {
                     double rateDistance = _orderSide == BuySide
                        ? MathAbs(rate - instrument.GetAsk()) / instrument.GetPointSize()
                        : MathAbs(rate < instrument.GetBid()) / instrument.GetPointSize();
                     if (rateDistance < minStopDistancePoints)
                        errorMessage = "Distance to the pending order rate is too close: " + DoubleToStr(rateDistance, 1)
                           + ". Min. allowed distance: " + IntegerToString(minStopDistancePoints);
                     else
                        errorMessage = "Invalid take profit in the request";
                  }
               }
               break;
            default:
               errorMessage = "Failed to create order: " + IntegerToString(error);
               break;
         }
      }
      return order;
   }
};

// Trade calculator v.1.15
class TradeCalculator
{
   InstrumentInfo *_symbol;

   TradeCalculator(const string symbol)
   {
      _symbol = new InstrumentInfo(symbol);
   }
public:
   static TradeCalculator *Create(const string symbol)
   {
      ResetLastError();
      double temp = MarketInfo(symbol, MODE_POINT); 
      if (GetLastError() != 0)
         return NULL;

      return new TradeCalculator(symbol);
   }

   ~TradeCalculator()
   {
      delete _symbol;
   }

   double GetPipSize() { return _symbol.GetPipSize(); }
   string GetSymbol() { return _symbol.GetSymbol(); }
   double GetBid() { return _symbol.GetBid(); }
   double GetAsk() { return _symbol.GetAsk(); }
   int GetDigits() { return _symbol.GetDigits(); }
   double GetSpread() { return _symbol.GetSpread(); }

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

   double GetLots(const PositionSizeType lotsType, const double lotsValue, const double stopDistance, const double leverageOverride = 0)
   {
      switch (lotsType)
      {
         case PositionSizeAmount:
            return GetLotsForMoney(lotsValue, leverageOverride);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(AccountEquity() * lotsValue / 100.0, leverageOverride);
         case PositionSizeRisk:
         {
            double affordableLoss = AccountEquity() * lotsValue / 100.0;
            double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
            double tickSize = _symbol.GetTickSize();
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

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
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

   double GetLotsForMoney(const double money, const double leverageOverride = 0)
   {
      if (leverageOverride != 0)
      {
         double lotSize = MarketInfo(_symbol.GetSymbol(), MODE_LOTSIZE);
         double lots = RoundLots(money * leverageOverride / lotSize);
         return LimitLots(lots);
      }
      double marginRequired = MarketInfo(_symbol.GetSymbol(), MODE_MARGINREQUIRED);
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
      double lotStep = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = _symbol.GetMinLots();
      if (minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
         return maxVolume;
      return lots;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
      double tickSize = _symbol.GetTickSize();
      return (money / (unitCost / tickSize)) / amount;
   }
};

// Action v1.0
interface IAction
{
public:
   virtual void DoAction() = 0;
};

// Trade trigger v1.0
class TradeTrigger
{
   int _order;
   IAction *_action;
public:
   TradeTrigger()
   {
      _order = 0;
      _action = NULL;
   }

   bool SetAction(const int order, IAction *actionOnTade)
   {
      if (_order != 0)
         return false;

      _order = order;
      _action = actionOnTade;
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

class TradeTriggerManager
{
   TradeTrigger *_triggers[];
public:
   ~TradeTriggerManager()
   {
      int count = ArraySize(_triggers);
      for (int i = 0; i < count; ++i)
      {
         delete _triggers[i];
      }
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
      _triggers[count] = new TradeTrigger();
      _triggers[count].SetAction(order, actionOnTade);
   }
};

TradeTriggerManager tradeTriggerManager;

bool executed = false;
double upLevel;
double downLevel;
int upTicket;
int downTicket;

class OnTradeAction : public IAction
{
public:
   virtual void DoAction()
   {
      int orderType = OrderType();
      if (orderType == OP_BUY)
      {
         if (trading_mode == TradingModeBreakout)
            EnsureDownOrderExist();
         else
            EnsureUpOrderExist();
         return;
      }
      if (trading_mode == TradingModeBreakout)
         EnsureUpOrderExist();
      else
         EnsureDownOrderExist();
   }
};

int OnInit()
{
   action = new OnTradeAction();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete action;
}

OnTradeAction *action;

bool IsEntryOrderExist(int order)
{
   if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
      return false;
   int orderType = OrderType();
   return orderType != OP_BUY && orderType != OP_SELL;
}

void EnsureDownOrderExist()
{
   if (!IsEntryOrderExist(downTicket))
      CreateDownOrder();
}
void EnsureUpOrderExist()
{
   if (!IsEntryOrderExist(upTicket))
      CreateUpOrder();
}

bool CreateUpOrder()
{
   TradeCalculator *calc = TradeCalculator::Create(_Symbol);
   if (calc == NULL)
   {
      Print("Incorrect symbol");
      return false;
   }
   double upTakeProfit = calc.CalculateTakeProfit(true, take_profit, StopLimitPips, lots_value, upLevel);
   double upStopLoss = calc.CalculateStopLoss(false, stop_loss, StopLimitPips, lots_value, upLevel);
   delete calc;

   string error;
   OrderBuilder upOrder;
   upTicket = upOrder.SetSide(trading_mode == TradingModeBreakout ? BuySide : SellSide)
      .SetInstrument(_Symbol)
      .SetAmount(lots_value)
      .SetRate(upLevel)
      .SetSlippage(slippage_points)
      .SetStopLoss(trading_mode == TradingModeBreakout ? downLevel : upStopLoss)
      .SetTakeProfit(trading_mode == TradingModeBreakout ? upTakeProfit : downLevel)
      .SetMagicNumber(magic_number)
      .Execute(error);
   if (upTicket == -1)
   {
      Print(error);
      return false;
   }
   tradeTriggerManager.SetAction(upTicket, action);
   return true;
}

bool CreateDownOrder()
{
   TradeCalculator *calc = TradeCalculator::Create(_Symbol);
   if (calc == NULL)
   {
      Print("Incorrect symbol");
      return false;
   }
   double downTakeProfit = calc.CalculateTakeProfit(false, take_profit, StopLimitPips, lots_value, downLevel);
   double downStopLoss = calc.CalculateStopLoss(true, stop_loss, StopLimitPips, lots_value, downLevel);
   delete calc;

   string error;
   OrderBuilder downOrder;
   downTicket = downOrder.SetSide(trading_mode == TradingModeBreakout ? SellSide : BuySide)
      .SetInstrument(_Symbol)
      .SetAmount(lots_value)
      .SetRate(downLevel)
      .SetSlippage(slippage_points)
      .SetStopLoss(trading_mode == TradingModeBreakout ? upLevel : downStopLoss)
      .SetTakeProfit(trading_mode == TradingModeBreakout ? downTakeProfit : upLevel)
      .SetMagicNumber(magic_number)
      .Execute(error);
   if (downTicket == -1)
   {
      Print(error);
      return false;
   }
   tradeTriggerManager.SetAction(downTicket, action);
   return true;
}

void OnTick()
{
   tradeTriggerManager.DoLogic();
   if (!executed)
   {
      upLevel = Close[0] + X * InstrumentInfo::GetPipSize(_Symbol);
      downLevel = Close[0] - Y * InstrumentInfo::GetPipSize(_Symbol);
      if (!CreateUpOrder())
         return;
      if (!CreateDownOrder())
         return;

      executed = true;
   }
}
