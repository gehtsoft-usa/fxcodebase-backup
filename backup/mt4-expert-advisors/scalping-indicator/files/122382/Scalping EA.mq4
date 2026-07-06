// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67015

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

// Trade controller v.2.3
#define USE_STOP_LOSS
#define USE_ATR_TRAILLING
#define USE_REVERSABLE_LOGIC
#define USE_TAKE_PROFIT
#define USE_NET_TAKE_PROFIT
#define USE_MARTINGALE

extern int LIN = 29; // LIN
extern int WHB = 6; // WHB
extern int WHS = 6; // WHS
extern int BIB = 6; // BIB
extern int BIS = 6; // BIS
extern double PPKKS = 0.994; // PPKKS
extern double PPKKB = 0.994; // PPKKB
extern double RES = 3; // RES
extern double SUP = 3; // SUP

extern string GeneralSection = ""; // == General ==
enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk // Risk in % of equity
};
enum LogicDirection
{
   DirectLogic, // Direct
   ReversalLogic // Reversal
};
enum TradingSide
{
   LongSideOnly, // Long
   ShortSideOnly, // Short
   BothSides // Both
};
extern double lots_value = 0.1; // Position size
extern PositionSizeType lots_type = PositionSizeContract; // Position size type
extern int slippage_pips = 3; // Slippage
extern TradingSide trading_side = BothSides; // What trades should be taken
#ifdef USE_REVERSABLE_LOGIC
   extern LogicDirection logic_direction = DirectLogic; // Logic type
#else
   LogicDirection logic_direction = DirectLogic;
#endif
extern bool close_on_opposite = true; // Close on opposite signal

extern string CapSection = ""; // == Position cap ==
extern bool position_cap = false; // Position Cap
extern int no_of_positions = 1; // Max # of buy+sell positions
extern int no_of_buy_position = 1; // Max # of buy positions
extern int no_of_sell_position = 1; // Max # of sell positions

#ifdef USE_MARTINGALE
   extern string MartingaleSection = ""; // == Martingale type ==
   enum MartingaleType
   {
      MartingaleDoNotUse, // Do not use
      MartingaleOnLoss // Open another position on loss
   };
   enum MartingaleLotSizingType
   {
      MartingaleLotSizingNo, // No lot sizing
      MartingaleLotSizingMultiplicator, // Using miltiplicator
      MartingaleLotSizingAdd // Addition
   };
   extern MartingaleType martingale_type = MartingaleDoNotUse; // Martingale type
   extern MartingaleLotSizingType martingale_lot_sizing_type = MartingaleLotSizingNo; // Martingale lot sizing type
   extern double martingale_lot_value = 1.5; // Matringale lot sizing value
   extern double martingale_step = 5; // Open matringale position step, pips
#endif

#ifdef USE_STOP_LOSS
   extern string StopLossSection            = ""; // == Stop loss ==
#endif
enum TrailingType
{
   TrailingDontUse, // No trailing
   TrailingPips, // Use trailing in pips
   TrailingPercent // Use trailing in % of stop
#ifdef USE_ATR_TRAILLING
   ,TrailingATR // Use ATR trailing
#endif
};
enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar // Set in $
};
#ifdef USE_STOP_LOSS
   extern StopLimitType stop_loss_type = StopLimitDoNotUse; // Stop loss type
   extern double stop_loss_value            = 10; // Stop loss value
   extern TrailingType trailing_type = TrailingDontUse; // Trailing type
   extern double trailing_step = 10; // Trailing step
   #ifdef USE_ATR_TRAILLING
      extern double atr_trailing_multiplier = 0.1; // Multiplier for ATR trailing
   #endif
   extern StopLimitType breakeven_type = StopLimitDoNotUse; // Trigger type for the breakeven
   extern double breakeven_value = 10; // Trigger for the breakeven
   extern double breakeven_level = 0; // Breakeven targer
   extern StopLimitType net_stop_loss_type = StopLimitDoNotUse; // Net stop loss type
   extern double net_stop_loss_value = 10; // Net stop loss value
#else
   StopLimitType stop_loss_type = StopLimitDoNotUse;
   double stop_loss_value = 0;
   TrailingType trailing_type = TrailingDontUse;
   double trailing_step = 10;
   StopLimitType breakeven_type = StopLimitDoNotUse; // Trigger type for the breakeven
   double breakeven_value = 10; // Trigger for the breakeven
   StopLimitType net_stop_loss_type = StopLimitDoNotUse; // Net stop loss type
   double net_stop_loss_value = 10; // Net stop loss value
#endif

#ifdef USE_TAKE_PROFIT
   extern string TakeProfitSection            = ""; // == Take Profit ==
   extern StopLimitType take_profit_type = StopLimitDoNotUse; // Take profit type
   extern double take_profit_value           = 10; // Take profit value
#else
   StopLimitType take_profit_type = StopLimitDoNotUse;
   double take_profit_value           = 10;
#endif
#ifdef USE_NET_TAKE_PROFIT
   extern StopLimitType net_take_profit_type = StopLimitDoNotUse; // Net take profit type
   extern double net_take_profit_value = 10; // Net take profit value
#endif

enum DayOfWeek
{
   DayOfWeekSunday = 0, // Sunday
   DayOfWeekMonday = 1, // Monday
   DayOfWeekTuesday = 2, // Tuesday
   DayOfWeekWednesday = 3, // Wednesday
   DayOfWeekThursday = 4, // Thursday
   DayOfWeekFriday = 5, // Friday
   DayOfWeekSaturday = 6 // Saturday
};

extern string OtherSection            = ""; // == Other ==
extern int magic_number        = 42; // Magic number
extern string start_time = "000000"; // Start time in hhmmss format
extern string stop_time = "000000"; // Stop time in hhmmss format
extern bool use_weekly_timing = false; // Weekly time
extern DayOfWeek week_start_day = DayOfWeekSunday; // Start day
extern string week_start_time = "000000"; // Start time in hhmmss format
extern DayOfWeek week_stop_day = DayOfWeekSaturday; // Stop day
extern string week_stop_time = "235959"; // Stop time in hhmmss format
extern bool mandatory_closing = false; // Mandatory closing for non-trading time
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
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

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

interface ICondition
{
public:
   bool IsPass(const int period) = 0;
};

// Instrument info v.1.1
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
   double GetPipSize() { return _pipSize; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathCeil(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};

class ABaseCondition : public ICondition
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
public:
   ABaseCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _instrument = new InstrumentInfo(_symbol);
      _timeframe = timeframe;
   }
   ~ABaseCondition()
   {
      delete _instrument;
   }
};

class LongCondition : public ABaseCondition
{
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      double value = iCustom(_symbol, _timeframe, "Scalping indicator", LIN, WHB, WHS, BIB, BIS, PPKKS, PPKKB, RES, SUP, 0, period);
      return value != EMPTY_VALUE;
   }
};

class ExitLongCondition : public ABaseCondition
{
public:
   ExitLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period)
   {
      return false;
   }
};

class ShortCondition : public ABaseCondition
{
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      double value = iCustom(_symbol, _timeframe, "Scalping indicator", LIN, WHB, WHS, BIB, BIS, PPKKS, PPKKB, RES, SUP, 1, period);
      return value != EMPTY_VALUE;
   }
};

class ExitShortCondition : public ABaseCondition
{
public:
   ExitShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period)
   {
      //TODO: implement
      return false;
   }
};

class DisabledCondition : public ICondition
{
public:
   bool IsPass(const int period)
   {
      return false;
   }
};

enum OrderSide
{
   BuySide,
   SellSide
};

// Breakeven logic v. 1.5

interface IBreakevenLogic
{
public:
   virtual void DoLogic() = 0;
   virtual void CreateBreakeven(const int order) = 0;
};

class DisabledBreakevenLogic : public IBreakevenLogic
{
public:
   void DoLogic() {}
   void CreateBreakeven(const int order) {}
};

class BreakevenController
{
   int _order;
   bool _finished;
   double _trigger;
   double _target;
   Signaler *_signaler;
   InstrumentInfo *_instrument;
public:
   BreakevenController(Signaler *signaler)
   {
      _instrument = NULL;
      _signaler = signaler;
      _finished = true;
   }

   ~BreakevenController()
   {
      delete _instrument;
   }
   
   bool SetOrder(const int order, const double trigger, const double target)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
         return false;

      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
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
         if (_instrument.GetAsk() >= _trigger)
         {
            int ticket = OrderTicket();
            _signaler.SendNotifications("Trade " + IntegerToString(ticket) + " has reached " 
               + DoubleToString(_trigger, _instrument.GetDigits()) + ". Stop loss moved to " 
               + DoubleToString(_target, _instrument.GetDigits()));
            int res = OrderModify(ticket, OrderOpenPrice(), _target, OrderTakeProfit(), 0, CLR_NONE);
            _finished = true;
         }
      } 
      else if (type == OP_SELL) 
      {
         if (_instrument.GetBid() < _trigger) 
         {
            int ticket = OrderTicket();
            _signaler.SendNotifications("Trade " + IntegerToString(ticket) + " has reached " 
               + DoubleToString(_trigger, _instrument.GetDigits()) + ". Stop loss moved to " 
               + DoubleToString(_target, _instrument.GetDigits()));
            int res = OrderModify(ticket, OrderOpenPrice(), _target, OrderTakeProfit(), 0, CLR_NONE);
            _finished = true;
         }
      } 
   }
};

// Orders iterator v 1.7
enum CompareType
{
   CompareLessThan
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

   int GetOrderType() { return OrderType(); }
   double GetProfit() { return OrderProfit(); }

   int Count()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
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
         _lastIndex = OrdersTotal() - 1;
      }
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
         {
            return true;
         }
      }
      return false;
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
            if (_isBuySide && OrderType() != OP_BUY)
               return false;
            if (!_isBuySide && OrderType() != OP_SELL)
               return false;
         }
         else
         {
            //TODO: IMPLEMENT!!!!
         }
      }
      return true;
   }

   bool IsTrade()
   {
      return (OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0.0;
   }
};

// Trade calculator v.1.10

class TradeCalculator
{
   InstrumentInfo *_symbol;
public:
   TradeCalculator(const string symbol)
   {
      _symbol = new InstrumentInfo(symbol);
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

   double GetBreakevenPrice(const int side, const int magicNumber, double &totalAmount)
   {
      totalAmount = 0.0;
      double lotStep = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_STEP);
      double price = side == OP_BUY ? GetBid() : GetAsk();
      double totalPL = 0;
      OrdersIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(_symbol.GetSymbol());
      it1.WhenOrderType(side);
      while (it1.Next())
      {
         double orderLots = OrderLots();
         totalAmount += orderLots / lotStep;
         if (side == OP_BUY)
            totalPL += (price - OrderOpenPrice()) * (OrderLots() / lotStep);
         else
            totalPL += (OrderOpenPrice() - price) * (OrderLots() / lotStep);
      }
      if (totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return side == OP_BUY ? price + shift : price - shift;
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
      double minVolume = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_MIN);
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
      double minVolume = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_MIN);
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

class BreakevenLogic : public IBreakevenLogic
{
   BreakevenController *_breakeven[];
   StopLimitType _breakevenTriggerType;
   double _breakevenTrigger;
   double _breakevenTarget;
   TradeCalculator *_calculator;
   Signaler *_signaler;
public:
   BreakevenLogic(TradeCalculator *calculator, const StopLimitType breakevenTriggerType, const double breakevenTrigger,
      const double breakevenTarget, Signaler *signaler)
   {
      _signaler = signaler;
      _calculator = calculator;
      _breakevenTriggerType = breakevenTriggerType;
      _breakevenTrigger = breakevenTrigger;
      _breakevenTarget = breakevenTarget;
   }

   ~BreakevenLogic()
   {
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         delete _breakeven[i];
      }
   }

   void DoLogic()
   {
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         _breakeven[i].DoLogic();
      }
   }

   void CreateBreakeven(const int order)
   {
      if (_breakevenTriggerType == StopLimitDoNotUse)
         return;
      
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (symbol != _calculator.GetSymbol())
      {
         Print("Erro in breakeven logic usage");
         return;
      }
      int isBuy = OrderType() == OP_BUY;
      double basePrice = isBuy ? _calculator.GetAsk() : _calculator.GetBid();
      double target = isBuy ? basePrice - _breakevenTarget * _calculator.GetPipSize()
          : basePrice + _breakevenTarget * _calculator.GetPipSize();
      double trigger = _calculator.CalculateTakeProfit(isBuy, _breakevenTrigger, _breakevenTriggerType, OrderLots(), basePrice);
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         if (_breakeven[i].SetOrder(order, trigger, target))
         {
            return;
         }
      }

      ArrayResize(_breakeven, i_count + 1);
      _breakeven[i_count] = new BreakevenController(_signaler);
      _breakeven[i_count].SetOrder(order, trigger, target);
   }
};

// Trailing controller v.2.0

interface ITrailingLogic
{
public:
   virtual void DoLogic() = 0;
   virtual void Create(const int order, const double stop) = 0;
};

class DisabledTrailingLogic : public ITrailingLogic
{
public:
   void DoLogic() {};
   void Create(const int order, const double stop) {};
};

enum TrailingControllerType
{
   TrailingControllerTypeStandard
#ifdef USE_ATR_TRAILLING
   ,TrailingControllerTypeATR
#endif
   ,TrailingControllerTypeStream
};

interface ITrailingController
{
public:
   virtual bool IsFinished() = 0;
   virtual void UpdateStop() = 0;
   virtual TrailingControllerType GetType() = 0;
};

// Net take profit v 1.5

interface INetTakeProfitStrategy
{
public:
   virtual void DoLogic() = 0;
};

// Disabled net take profit
class NoNetTakeProfitStrategy : public INetTakeProfitStrategy
{
public:
   virtual void DoLogic()
   {
      // Do nothing
   }
};

class NetTakeProfitStrategy : public INetTakeProfitStrategy
{
   TradeCalculator *_calculator;
   int _magicNumber;
   double _takeProfit;
   StopLimitType _type;
   Signaler *_signaler;
public:
   NetTakeProfitStrategy(TradeCalculator *calculator, StopLimitType type, const double takeProfit, Signaler *signaler, const int magicNumber)
   {
      _type = type;
      _calculator = calculator;
      _takeProfit = takeProfit;
      _signaler = signaler;
      _magicNumber = magicNumber;
   }

   void DoLogic()
   {
      MoveTakeProfit(OP_BUY);
      MoveTakeProfit(OP_SELL);
   }
private:
   void MoveTakeProfit(const int side)
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenOrderType(side);
      it.WhenTrade();
      if (it.Count() <= 1)
         return;
      double totalAmount;
      double averagePrice = _calculator.GetBreakevenPrice(side, _magicNumber, totalAmount);
      if (averagePrice == 0.0)
         return;
         
      double takeProfit = _calculator.CalculateTakeProfit(side == OP_BUY, _takeProfit, _type, totalAmount, averagePrice);
      
      OrdersIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbol());
      it1.WhenOrderType(side);
      it1.WhenTrade();
      int count = 0;
      while (it1.Next())
      {
         if (OrderTakeProfit() != takeProfit)
         {
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), takeProfit, 0, CLR_NONE);
            if (res == 0)
            {
               int error = GetLastError();
               switch (error)
               {
                  case ERR_NO_RESULT:
                     break;
                  case ERR_INVALID_TICKET:
                     break;
               }
            }
            else
               ++count;
         }
      }
      if (_signaler != NULL && count > 0)
         _signaler.SendNotifications("Moving net take profit to " + DoubleToStr(takeProfit));
   }
};

// Stream v.1.0
interface IStream
{
public:
   virtual bool GetValue(const int period, double &val) = 0;
};

class StreamTrailingController : public ITrailingController
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   double _distance;
   IStream *_stream;
   InstrumentInfo *_instrument;
public:
   StreamTrailingController(Signaler *signaler = NULL)
   {
      _instrument = NULL;
      _stream = NULL;
      _finished = true;
      _order = -1;
      _signaler = signaler;
   }

   ~StreamTrailingController()
   {
      delete _instrument;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const int order, IStream *stream)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return false;
      }
      string symbol = OrderSymbol();
      if (_instrument == NULL || _instrument.GetSymbol() != symbol)
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      _stream = stream;

      _finished = false;
      _order = order;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _finished = true;
         return;
      }

      double newStop;
      if (!_stream.GetValue(0, newStop))
         return;
      newStop = _instrument.RoundRate(newStop);

      if (newStop == OrderStopLoss()) 
         return;

      if (_signaler != NULL)
      {
         string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(newStop, _instrument.GetDigits());
         _signaler.SendNotifications(message);
      }
      int res = OrderModify(_order, OrderOpenPrice(), newStop, OrderTakeProfit(), 0, CLR_NONE);
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

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeStream;
   }
};

class IndicatorTrailingLogic : public ITrailingLogic
{
   ITrailingController *_trailing[];
   InstrumentInfo *_instrument;
   IStream *_longStream;
   IStream *_shortStream;
   Signaler *_signaler;
public:
   IndicatorTrailingLogic(IStream *longStream, IStream *shortStream, Signaler *signaler)
   {
      _longStream = longStream;
      _shortStream = shortStream;
      _signaler = signaler;
      _instrument = NULL;
   }

   ~IndicatorTrailingLogic()
   {
      delete _longStream;
      delete _shortStream;
      delete _instrument;
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         delete _trailing[i];
      }
   }

   void DoLogic()
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         _trailing[i].UpdateStop();
      }
   }

   void Create(const int order, const double stop)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (_instrument == NULL)
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      if (symbol != _instrument.GetSymbol())
      {
         return;
      }
      bool isBuy = OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP;
      IStream *stream = isBuy ? _longStream : _shortStream;
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeStream)
            continue;
         StreamTrailingController *trailingController = (StreamTrailingController *)_trailing[i];
         if (trailingController.SetOrder(order, stream))
         {
            return;
         }
      }

      StreamTrailingController *trailingController = new StreamTrailingController(_signaler);
      trailingController.SetOrder(order, stream);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }
};

#ifdef USE_ATR_TRAILLING
class TrailingControllerATR : public ITrailingController
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   int _atrPeriod;
   double _multiplier;
   double _tickSize;
   int _digits;
   double _distance;
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
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return false;
      }
      _digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
      _tickSize = MarketInfo(OrderSymbol(), MODE_TICKSIZE);
      _distance = stop;
      _atrPeriod = atrPeriod;
      _multiplier = multiplier;
      _timeframe = timeframe;

      _finished = false;
      _order = order;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _finished = true;
         return;
      }

      int type = OrderType();
      double trailingStep = iATR(OrderSymbol(), _timeframe, _atrPeriod, 0) * _multiplier;
      if (type == OP_BUY)
      {
         double newStop = OrderStopLoss();
         while (NormalizeDouble(newStop + trailingStep, _digits) < NormalizeDouble(Ask - _distance, _digits))
         {
            newStop = NormalizeDouble(newStop + trailingStep, _digits);
         }
         if (newStop != OrderStopLoss()) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(newStop);
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
         while (NormalizeDouble(newStop - trailingStep, _digits) > NormalizeDouble(Bid + _distance, _digits))
         {
            newStop = NormalizeDouble(newStop - trailingStep, _digits);
         }
         if (newStop != OrderStopLoss()) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(newStop);
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
#endif

class TrailingController : public ITrailingController
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   double _distance;
   double _trailingStep;
   InstrumentInfo *_instrument;
public:
   TrailingController(Signaler *signaler = NULL)
   {
      _finished = true;
      _order = -1;
      _signaler = signaler;
      _instrument = NULL;
   }

   ~TrailingController()
   {
      delete _instrument;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const int order, const double distance, const double trailingStep)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return false;
      }
      string symbol = OrderSymbol();
      if (_instrument == NULL || _instrument.GetSymbol() != symbol)
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      _trailingStep = _instrument.RoundRate(trailingStep);
      if (_trailingStep == 0)
         return false;

      _finished = false;
      _order = order;
      _distance = distance;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _finished = true;
         return;
      }
      int type = OrderType();
      if (type == OP_BUY)
      {
         UpdateStopForLong();
      } 
      else if (type == OP_SELL) 
      {
         UpdateStopForShort();
      } 
   }

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeStandard;
   }
private:
   void UpdateStopForLong()
   {
      double initialStop = OrderStopLoss();
      if (initialStop == 0.0)
         return;
      double ask = _instrument.GetAsk();
      double openPrice = OrderOpenPrice();
      double newStop = initialStop;
      int digits = _instrument.GetDigits();
      while (NormalizeDouble(newStop + _trailingStep, digits) < NormalizeDouble(ask - _distance, digits))
      {
         newStop = NormalizeDouble(newStop + _trailingStep, digits);
      }
      if (newStop == initialStop) 
         return;
      if (_signaler != NULL)
      {
         string message = "Trailing stop for " + IntegerToString(_order) + " to " + DoubleToString(newStop, digits);
         _signaler.SendNotifications(message);
      }
      int res = OrderModify(OrderTicket(), openPrice, newStop, OrderTakeProfit(), 0, CLR_NONE);
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

   void UpdateStopForShort()
   {
      double initialStop = OrderStopLoss();
      if (initialStop == 0.0)
         return;
      double bid = _instrument.GetBid();
      double openPrice = OrderOpenPrice();
      double newStop = initialStop;
      int digits = _instrument.GetDigits();
      while (NormalizeDouble(newStop - _trailingStep, digits) > NormalizeDouble(bid + _distance, digits))
      {
         newStop = NormalizeDouble(newStop - _trailingStep, digits);
      }
      if (newStop == initialStop) 
         return;
         
      if (_signaler != NULL)
      {
         string message = "Trailing stop for " + IntegerToString(_order) + " to " + DoubleToString(newStop, digits);
         _signaler.SendNotifications(message);
      }
      int res = OrderModify(OrderTicket(), openPrice, newStop, OrderTakeProfit(), 0, CLR_NONE);
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
};

class TrailingLogic : public ITrailingLogic
{
   ITrailingController *_trailing[];
   TrailingType _trailingType;
   double _trailingStep;
   double _atrTrailingMultiplier;
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   Signaler *_signaler;
public:
   TrailingLogic(TrailingType trailing, double trailingStep, double atrTrailingMultiplier, ENUM_TIMEFRAMES timeframe,
      Signaler *signaler)
   {
      _signaler = signaler;
      _instrument = NULL;
      _trailingType = trailing;
      _trailingStep = trailingStep;
      _atrTrailingMultiplier = atrTrailingMultiplier;
      _timeframe = timeframe;
   }

   ~TrailingLogic()
   {
      delete _instrument;
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         delete _trailing[i];
      }
   }

   void DoLogic()
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         _trailing[i].UpdateStop();
      }
   }

   void Create(const int order, const double distancePips)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      double distance = distancePips * _instrument.GetPipSize();
      switch (_trailingType)
      {
         case TrailingPips:
            CreateTrailing(order, distance, _trailingStep * _instrument.GetPipSize());
            break;
         case TrailingPercent:
            CreateTrailing(order, distance, distance * _trailingStep / 100.0);
            break;
#ifdef USE_ATR_TRAILLING
         case TrailingATR:
            CreateATRTrailing(order, distance, (int)_trailingStep, _atrTrailingMultiplier);
            break;
#endif
      }
   }
private:
#ifdef USE_ATR_TRAILLING
   void CreateATRTrailing(const int order, const double distance, const int atrPeriod, const double multiplier)
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeATR)
            continue;
         TrailingControllerATR *trailingController = (TrailingControllerATR *)_trailing[i];
         if (trailingController.SetOrder(order, distance, atrPeriod, multiplier, _timeframe))
         {
            return;
         }
      }

      TrailingControllerATR *trailingController = new TrailingControllerATR();
      trailingController.SetOrder(order, distance, atrPeriod, multiplier, _timeframe);

      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }
#endif
   void CreateTrailing(const int order, const double distance, const double trailingStep)
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeStandard)
            continue;
         TrailingController *trailingController = (TrailingController *)_trailing[i];
         if (trailingController.SetOrder(order, distance, trailingStep))
         {
            return;
         }
      }

      TrailingController *trailingController = new TrailingController(_signaler);
      trailingController.SetOrder(order, distance, trailingStep);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }
};

// Net stop loss v 1.5
interface INetStopLossStrategy
{
public:
   virtual void DoLogic() = 0;
};

// Disabled net stop loss
class NoNetStopLossStrategy : public INetStopLossStrategy
{
public:
   void DoLogic()
   {
      // Do nothing
   }
};

class NetStopLossStrategy : public INetStopLossStrategy
{
   TradeCalculator *_calculator;
   int _magicNumber;
   double _stopLoss;
   StopLimitType _type;
   Signaler *_signaler;
public:
   NetStopLossStrategy(TradeCalculator *calculator, StopLimitType type, const double stopLoss, Signaler *signaler, const int magicNumber)
   {
      _type = type;
      _calculator = calculator;
      _stopLoss = stopLoss;
      _signaler = signaler;
      _magicNumber = magicNumber;
   }

   void DoLogic()
   {
      MoveStopLoss(OP_BUY);
      MoveStopLoss(OP_SELL);
   }
private:
   void MoveStopLoss(const int side)
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenOrderType(side);
      it.WhenTrade();
      if (it.Count() <= 1)
         return;
      double totalAmount;
      double averagePrice = _calculator.GetBreakevenPrice(side, _magicNumber, totalAmount);
      if (averagePrice == 0.0)
         return;
         
      double stopLoss = _calculator.CalculateStopLoss(side == OP_BUY, _stopLoss, _type, totalAmount, averagePrice);
      
      OrdersIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbol());
      it1.WhenOrderType(side);
      it1.WhenTrade();
      int count = 0;
      while (it1.Next())
      {
         if (OrderStopLoss() != stopLoss)
         {
            int res = OrderModify(OrderTicket(), OrderOpenPrice(), stopLoss, OrderTakeProfit(), 0, CLR_NONE);
            if (res == 0)
            {
               int error = GetLastError();
               switch (error)
               {
                  case ERR_NO_RESULT:
                     break;
                  case ERR_INVALID_TICKET:
                     break;
               }
            }
            else
               ++count;
         }
      }
      if (_signaler != NULL && count > 0)
         _signaler.SendNotifications("Moving net stop loss to " + DoubleToStr(stopLoss));
   }
};

// Trading time v.1.3

class TradingTime
{
   int _startTime;
   int _endTime;
   bool _useWeekTime;
   int _weekStartTime;
   int _weekStartDay;
   int _weekStopTime;
   int _weekStopDay;
public:
   TradingTime()
   {
      _startTime = 0;
      _endTime = 0;
      _useWeekTime = false;
   }

   bool SetWeekTradingTime(const DayOfWeek startDay, const string startTime, const DayOfWeek stopDay, 
      const string stopTime, string &error)
   {
      _useWeekTime = true;
      _weekStartTime = ParseTime(startTime, error);
      if (_weekStartTime == -1)
         return false;
      _weekStopTime = ParseTime(stopTime, error);
      if (_weekStopTime == -1)
         return false;
      
      _weekStartDay = (int)startDay;
      _weekStopDay = (int)stopDay;
      return true;
   }

   bool Init(const string startTime, const string endTime, string &error)
   {
      _startTime = ParseTime(startTime, error);
      if (_startTime == -1)
         return false;
      _endTime = ParseTime(endTime, error);
      if (_endTime == -1)
         return false;

      return true;
   }

   bool IsTradingTime(datetime dt)
   {
      if (_startTime == _endTime && !_useWeekTime)
         return true;
      MqlDateTime current_time;
      if (!TimeToStruct(dt, current_time))
         return false;
      if (!IsIntradayTradingTime(current_time))
         return false;
      return IsWeeklyTradingTime(current_time);
   }
private:
   bool IsIntradayTradingTime(const MqlDateTime &current_time)
   {
      if (_startTime == _endTime)
         return true;
      int current_t = TimeToInt(current_time);
      if (_startTime > _endTime)
         return current_t >= _startTime || current_t <= _endTime;
      return current_t >= _startTime && current_t <= _endTime;
   }

   int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }

   bool IsWeeklyTradingTime(const MqlDateTime &current_time)
   {
      if (!_useWeekTime)
         return true;
      if (current_time.day_of_week < _weekStartDay || current_time.day_of_week > _weekStopDay)
         return false;

      if (current_time.day_of_week == _weekStartDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t >= _weekStartTime;
      }
      if (current_time.day_of_week == _weekStopDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t < _weekStopTime;
      }

      return true;
   }

   int ParseTime(const string time, string &error)
   {
      int time_parsed = (int)StringToInteger(time);
      int seconds = time_parsed % 100;
      if (seconds > 59)
      {
         error = "Incorrect number of seconds in " + time;
         return -1;
      }
      time_parsed /= 100;
      int minutes = time_parsed % 100;
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }
      time_parsed /= 100;
      int hours = time_parsed % 100;
      if (hours > 23)
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      return (hours * 60 + minutes) * 60 + seconds;
   }
};

// Money management strategy v.1.0

interface IMoneyManagementStrategy
{
public:
   virtual void Get(double &amount, double &stopLoss, double &takeProfit) = 0;
};

class LongMoneyManagementStrategy : public IMoneyManagementStrategy
{
   TradeCalculator *_calculator;
public:
   LongMoneyManagementStrategy(TradeCalculator *calculator)
   {
      _calculator = calculator;
   }

   void Get(double &amount, double &stopLoss, double &takeProfit)
   {
      double ask = _calculator.GetAsk();
      if (lots_type == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, stop_loss_type, 0.0, ask);
         amount = _calculator.GetLots(lots_type, lots_value, ask - stopLoss);
      }
      else
      {
         amount = _calculator.GetLots(lots_type, lots_value, 0.0);
         stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, stop_loss_type, amount, ask);
      }
      takeProfit = _calculator.CalculateTakeProfit(true, take_profit_value, take_profit_type, amount, ask);
   }
};

class ShortMoneyManagementStrategy : public IMoneyManagementStrategy
{
   TradeCalculator *_calculator;
public:
   ShortMoneyManagementStrategy(TradeCalculator *calculator)
   {
      _calculator = calculator;
   }

   void Get(double &amount, double &stopLoss, double &takeProfit)
   {
      double bid = _calculator.GetBid();
      if (lots_type == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, stop_loss_type, 0.0, bid);
         amount = _calculator.GetLots(lots_type, lots_value, stopLoss - bid);
      }
      else
      {
         amount = _calculator.GetLots(lots_type, lots_value, 0.0);
         stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, stop_loss_type, amount, bid);
      }
      takeProfit = _calculator.CalculateTakeProfit(false, take_profit_value, take_profit_type, amount, bid);
   }
};

// Martingale strategy v.1.3

interface IMartingaleStrategy
{
public:
   virtual void OnOrder(const int order) = 0;
   virtual bool NeedAnotherPosition(OrderSide &side) = 0;
   virtual IMoneyManagementStrategy *GetMoneyManagement() = 0;
};

class NoMartingaleStrategy : public IMartingaleStrategy
{
public:
   void OnOrder(const int order) { }
   bool NeedAnotherPosition(OrderSide &side) { return false; }
   IMoneyManagementStrategy *GetMoneyManagement() { return NULL; }
};

class ACustomAmountMoneyManagementStrategy : public IMoneyManagementStrategy
{
protected:
   TradeCalculator *_calculator;
   double _amount;
public:
   ACustomAmountMoneyManagementStrategy(TradeCalculator *calculator)
   {
      _calculator = calculator;
      _amount = 0.0;
   }

   void SetAmount(const double amount)
   {
      _amount = amount;
   }
};

class CustomAmountLongMoneyManagementStrategy : public ACustomAmountMoneyManagementStrategy
{
public:
   CustomAmountLongMoneyManagementStrategy(TradeCalculator *calculator)
      :ACustomAmountMoneyManagementStrategy(calculator)
   {
   }

   void Get(double &amount, double &stopLoss, double &takeProfit)
   {
      double ask = _calculator.GetAsk();
      amount = _amount;
      stopLoss = _calculator.CalculateStopLoss(true, stop_loss_value, stop_loss_type, amount, ask);
      takeProfit = _calculator.CalculateTakeProfit(true, take_profit_value, take_profit_type, amount, ask);
   }
};

class CustomAmountShortMoneyManagementStrategy : public ACustomAmountMoneyManagementStrategy
{
public:
   CustomAmountShortMoneyManagementStrategy(TradeCalculator *calculator)
      :ACustomAmountMoneyManagementStrategy(calculator)
   {
   }

   void Get(double &amount, double &stopLoss, double &takeProfit)
   {
      double bid = _calculator.GetBid();
      amount = _amount;
      stopLoss = _calculator.CalculateStopLoss(false, stop_loss_value, stop_loss_type, amount, bid);
      takeProfit = _calculator.CalculateTakeProfit(false, take_profit_value, take_profit_type, amount, bid);
   }
};

class ActiveMartingaleStrategy : public IMartingaleStrategy
{
   int _order;
   TradeCalculator *_calculator;
   CustomAmountLongMoneyManagementStrategy *_longMoneyManagement;
   CustomAmountShortMoneyManagementStrategy *_shortMoneyManagement;
   double _lotValue;
   double _stepPips;
   MartingaleLotSizingType _martingaleLotSizingType;
public:
   ActiveMartingaleStrategy(TradeCalculator *calculator, MartingaleLotSizingType martingaleLotSizingType, const double stepPips, const double lotValue)
   {
      _martingaleLotSizingType = martingaleLotSizingType;
      _stepPips = stepPips;
      _lotValue = lotValue;
      _order = -1;
      _calculator = calculator;
      _longMoneyManagement = new CustomAmountLongMoneyManagementStrategy(_calculator);
      _shortMoneyManagement = new CustomAmountShortMoneyManagementStrategy(_calculator);
   }

   ~ActiveMartingaleStrategy()
   {
      delete _longMoneyManagement;
      delete _shortMoneyManagement;
   }

   void OnOrder(const int order)
   {
      _order = order;
   }

   IMoneyManagementStrategy *GetMoneyManagement()
   {
      if (_order == -1)
         return NULL;
      if (!OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return NULL;
      }
      double lots = OrderLots();
      switch (_martingaleLotSizingType)
      {
         case MartingaleLotSizingNo:
            break;
         case MartingaleLotSizingMultiplicator:
            lots = _calculator.NormalizeLots(lots * _lotValue);
            break;
         case MartingaleLotSizingAdd:
            lots = _calculator.NormalizeLots(lots + _lotValue);
            break;
      }
      if (OrderType() == OP_BUY)
      {
         _longMoneyManagement.SetAmount(lots);
         return _longMoneyManagement;
      }
      _shortMoneyManagement.SetAmount(lots);
      return _shortMoneyManagement;
   }

   bool NeedAnotherPosition(OrderSide &side)
   {
      if (_order == -1)
         return false;
      if (!OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _order = -1;
         return false;
      }
      if (OrderType() == OP_BUY)
      {
         if ((OrderOpenPrice() - _calculator.GetAsk()) / _calculator.GetPipSize() > _stepPips)
         {
            side = BuySide;
            return true;
         }
      }
      else
      {
         if ((_calculator.GetBid() - OrderOpenPrice()) / _calculator.GetPipSize() > _stepPips)
         {
            side = SellSide;
            return true;
         }
      }
      return false;
   }
};

// Trading commands v.2.0
class TradingCommands
{
public:
   static void DeleteOrders(const int magicNumber)
   {
      OrdersIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenOrder();
      while (it1.Next())
      {
         int ticket = OrderTicket();
         if (!OrderDelete(ticket))
         {
            Print("Failed to delete the order " + IntegerToString(ticket));
         }
      }
   }
   
   static bool CloseCurrentOrder(const double price, string &error)
   {
      bool closed = OrderClose(OrderTicket(), OrderLots(), price, 5);
      if (closed)
         return true;
      int lastError = GetLastError();
      switch (lastError)
      {
         case ERR_TRADE_NOT_ALLOWED:
            error = "Trading is not allowed";
            break;
         default:
            error = "Last error: " + IntegerToString(lastError);
            break;
      }
      return false;
   }

   static int CloseTrades(OrdersIterator &it)
   {
      int closedPositions = 0;
      while (it.Next())
      {
         int orderType = it.GetOrderType();
         string error;
         bool closed = false;
         if (orderType == OP_BUY)
            closed = CloseCurrentOrder(InstrumentInfo::GetBid(OrderSymbol()), error);
         else if (orderType == OP_SELL)
            closed = CloseCurrentOrder(InstrumentInfo::GetAsk(OrderSymbol()), error);

         if (!closed)
            Print("Failed to close positoin. ", error);
         else
            ++closedPositions;
      }
      return closedPositions;
   }
};

// Market order builder v 1.2
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
      int order = OrderSend(_instrument, orderType, _amount, rate, _slippage, _stop, _limit, _comment, _magicNumber);
      if (order == -1)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_NOT_ENOUGH_MONEY:
               errorMessage = "Not enought money";
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
            case ERR_TRADE_NOT_ALLOWED:
               errorMessage = "Trading is not allowed";
               return -1;
            case ERR_INVALID_STOPS:
               {
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
                  if (_stop != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _stop) / point) < minStopDistancePoints)
                        errorMessage = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                     else
                        errorMessage = "Invalid stop loss in the request";
                  }
                  else if (_limit != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _limit) / point) < minStopDistancePoints)
                        errorMessage = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                     else
                        errorMessage = "Invalid take profit in the request";
                  }
                  else
                     errorMessage = "Invalid take profit in the request";
               }
               return -1;
            default:
               errorMessage = "Failed to create order: " + IntegerToString(error);
               return -1;
         }
      }
      return order;
   }
};

class TradeController
{
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastbartime;
   double _lastLot;
   IBreakevenLogic *_breakeven;
   ITrailingLogic *_trailing;
   Signaler *_signaler;
   datetime _lastBarDate;
   TradeCalculator *_calculator;
   INetStopLossStrategy *_netStopLoss;
   INetTakeProfitStrategy *_netTakeProfit;
   TradingTime *_tradingTime;
   ICondition *_longCondition;
   ICondition *_shortCondition;
   ICondition *_exitAllCondition;
   ICondition *_exitLongCondition;
   ICondition *_exitShortCondition;
   IMartingaleStrategy *_shortMartingale;
   IMartingaleStrategy *_longMartingale;
   IMoneyManagementStrategy *_longMoneyManagement;
   IMoneyManagementStrategy *_shortMoneyManagement;
public:
   TradeController(TradeCalculator *calculator, ENUM_TIMEFRAMES timeframe, Signaler *signaler)
   {
      _shortMartingale = NULL;
      _longMartingale = NULL;
      _longMoneyManagement = NULL;
      _shortMoneyManagement = NULL;
      _longCondition = NULL;
      _shortCondition = NULL;
      _netStopLoss = NULL;
      _netTakeProfit = NULL;
      _calculator = calculator;
      _signaler = signaler;
      _timeframe = timeframe;
      _lastLot = lots_value;
      _exitAllCondition = NULL;
      _exitLongCondition = NULL;
      _exitShortCondition = NULL;
      _tradingTime = NULL;
   }

   ~TradeController()
   {
      delete _longMoneyManagement;
      delete _shortMoneyManagement;
      delete _shortMartingale;
      delete _longMartingale;
      delete _exitAllCondition;
      delete _exitLongCondition;
      delete _exitShortCondition;
      delete _calculator;
      delete _signaler;
      delete _breakeven;
      delete _trailing;
      delete _longCondition;
      delete _shortCondition;
      delete _netStopLoss;
      delete _netTakeProfit;
      delete _tradingTime;
   }

   void SetTradingTime(TradingTime *tradingTime) { _tradingTime = tradingTime; }
   void SetBreakeven(IBreakevenLogic *breakeven) { _breakeven = breakeven; }
   void SetTrailing(ITrailingLogic *trailing) { _trailing = trailing; }
   void SetNetStopLossStrategy(INetStopLossStrategy *strategy) { _netStopLoss = strategy; }
   void SetNetTakeProfitStrategy(INetTakeProfitStrategy *strategy) { _netTakeProfit = strategy; }
   void SetLongCondition(ICondition *condition) { _longCondition = condition; }
   void SetShortCondition(ICondition *condition) { _shortCondition = condition; }
   void SetExitAllCondition(ICondition *condition) { _exitAllCondition = condition; }
   void SetExitLongCondition(ICondition *condition) { _exitLongCondition = condition; }
   void SetExitShortCondition(ICondition *condition) { _exitShortCondition = condition; }
   void SetShortMartingaleStrategy(IMartingaleStrategy *martingale) { _shortMartingale = martingale; }
   void SetLongMartingaleStrategy(IMartingaleStrategy *martingale) { _longMartingale = martingale; }
   void SetLongMoneyManagement(IMoneyManagementStrategy *moneyManagement) { _longMoneyManagement = moneyManagement; }
   void SetShortMoneyManagement(IMoneyManagementStrategy *moneyManagement) { _shortMoneyManagement = moneyManagement; }

   void DoTrading()
   {
      _breakeven.DoLogic();
      _trailing.DoLogic();
      _netStopLoss.DoLogic();
      _netTakeProfit.DoLogic();
      datetime current_time = iTime(_calculator.GetSymbol(), _timeframe, 0);
      if (_lastBarDate != current_time)
      {
         OnBar();
         _lastBarDate = current_time;
      }

      DoMartingale(_shortMartingale);
      DoMartingale(_longMartingale);

      bool exitAll = _exitAllCondition.IsPass(0);
      if (exitAll || (_exitLongCondition.IsPass(0) && !_exitLongCondition.IsPass(1)))
      {
         OrdersIterator toClose();
         toClose.WhenSide(BuySide).WhenMagicNumber(magic_number).WhenTrade();
         if (TradingCommands::CloseTrades(toClose) > 0)
            _signaler.SendNotifications(EXIT_BUY_SIGNAL);
      }
      if (exitAll || (_exitShortCondition.IsPass(0) && !_exitShortCondition.IsPass(1)))
      {
         OrdersIterator toClose();
         toClose.WhenSide(SellSide).WhenMagicNumber(magic_number).WhenTrade();
         if (TradingCommands::CloseTrades(toClose) > 0)
            _signaler.SendNotifications(EXIT_SELL_SIGNAL);
      }

      if (_tradingTime != NULL && !_tradingTime.IsTradingTime(current_time))
      {
         if (mandatory_closing)
         {
            OrdersIterator toClose();
            toClose.WhenMagicNumber(magic_number).WhenTrade();
            int positionsClosed = TradingCommands::CloseTrades(toClose);
            TradingCommands::DeleteOrders(magic_number);
            if (positionsClosed > 0)
               _signaler.SendNotifications("Mandatory closing");
         }
         return;
      }
      if (current_time == _lastbartime)
      {
         return;
      }

      if (_longCondition.IsPass(0) && !_longCondition.IsPass(1))
      {
         if (position_cap)
         {
            OrdersIterator it1();
            it1.WhenMagicNumber(magic_number);
            it1.WhenOrderType(OP_BUY);
            int buy_positions = it1.Count();
            OrdersIterator it2();
            it2.WhenMagicNumber(magic_number);
            int positions = it2.Count();
            if (positions >= no_of_positions || buy_positions >= no_of_buy_position)
            {
               _signaler.SendNotifications("Positions limit has been reached");
               return;
            }
         }
         if (close_on_opposite)
         {
            OrdersIterator toClose();
            toClose.WhenSide(SellSide).WhenMagicNumber(magic_number).WhenTrade();
            TradingCommands::CloseTrades(toClose);
         }
         double stopLoss = 0.0;
         int order = OpenPosition(BuySide, _longMoneyManagement, "Main position", stopLoss);
         if (order >= 0)
         {
            _longMartingale.OnOrder(order);
            _breakeven.CreateBreakeven(order);
            _trailing.Create(order, (_calculator.GetAsk() - stopLoss) / _calculator.GetPipSize());
         }
         _signaler.SendNotifications(ENTER_BUY_SIGNAL);
      }
      if (_shortCondition.IsPass(0) && !_shortCondition.IsPass(1))
      {
         if (position_cap)
         {
            OrdersIterator it1();
            it1.WhenMagicNumber(magic_number);
            it1.WhenOrderType(OP_SELL);
            int sell_positions = it1.Count();
            OrdersIterator it2();
            it2.WhenMagicNumber(magic_number);
            int positions = it2.Count();
            if (positions >= no_of_positions || sell_positions >= no_of_sell_position)
            {
               _signaler.SendNotifications("Positions limit has been reached");
               return;
            }
         }
         if (close_on_opposite)
         {
            OrdersIterator toClose();
            toClose.WhenSide(BuySide).WhenMagicNumber(magic_number).WhenTrade();
            TradingCommands::CloseTrades(toClose);
         }
         double stopLoss = 0.0;
         int order = OpenPosition(SellSide, _shortMoneyManagement, "Main position", stopLoss);
         if (order >= 0)
         {
            _shortMartingale.OnOrder(order);
            _breakeven.CreateBreakeven(order);
            _trailing.Create(order, (stopLoss - _calculator.GetBid()) / _calculator.GetPipSize());
         }
         _signaler.SendNotifications(ENTER_SELL_SIGNAL);
      }
   }
private:
   void DoMartingale(IMartingaleStrategy *martingale)
   {
      OrderSide anotherSide;
      if (martingale.NeedAnotherPosition(anotherSide))
      {
         double stopLoss;
         int order = OpenPosition(anotherSide, martingale.GetMoneyManagement(), "Martingale position", stopLoss);
         if (order >= 0)
         {
            martingale.OnOrder(order);
         }
         if (anotherSide == BuySide)
         {
            _signaler.SendNotifications("Opening martingale long position");
         }
         else
         {
            _signaler.SendNotifications("Opening martingale short position");
         }
      }
   }

   void OnBar()
   {
   }

   int OpenPosition(OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment, double &stopLoss)
   {
      double amount;
      double takeProfit;
      moneyManagement.Get(amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return -1;
      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      int order = orderBuilder
         .SetSide(side)
         .SetInstrument(_calculator.GetSymbol())
         .SetAmount(amount)
         .SetSlippage(slippage_pips)
         .SetMagicNumber(magic_number)
         .SetStop(stopLoss)
         .SetLimit(takeProfit)
         .SetComment(comment)
         .Execute(error);
      delete orderBuilder;
      if (order != -1)
      {
         _lastbartime = iTime(NULL, _timeframe, 0);
      }
      else
      {
         Print("Failed to open position: " + error);
      }
      return order;
   }
};

extern color equity_color = White; // Equity & profit color
extern color color_text = Lime; // General text color
extern color header_color = Yellow; // Headers color

// Account statistics v.1.2
class AccountStatistics
{
   InstrumentInfo *_symbol;
   int text_corner;
   string _eaName;
   int _fontSize;
public:
   AccountStatistics(string eaName)
   {
      _fontSize = 10;
      _eaName = eaName;
      text_corner = 1;
      _symbol = new InstrumentInfo(_Symbol);

      string_window("EA_NAME", 5, 5, 0); 
      ObjectSet("EA_NAME", OBJPROP_CORNER, 3); 
      ObjectSetText("EA_NAME", _eaName, _fontSize + 3, "Impact", header_color);
   }

   ~AccountStatistics()
   {
      delete _symbol;
   }

   void Update()
   {
      OrdersIterator it();
      it.WhenTrade().WhenMagicNumber(magic_number);
      double profit = 0.0;
      double XYZ = 0.0;
      while (it.Next())
      {
         profit += it.GetProfit();
         XYZ += it.GetProfit() + OrderCommission() + OrderSwap();
      }
      string hari;
      MqlDateTime current_time;
      TimeToStruct(TimeCurrent(), current_time);
      switch (current_time.day_of_week)
      {
         case MONDAY:
            hari = "MONDAY";
            break;
         case TUESDAY:
            hari = "TUESDAY";
            break;
         case WEDNESDAY:
            hari = "WEDNESDAY";
            break;
         case THURSDAY:
            hari = "THURSDAY";
            break;
         case FRIDAY:
            hari = "FRIDAY";
            break;
         case SATURDAY:
            hari = "SATURDAY";
            break;
         case SUNDAY:
            hari = "SUNDAY";
            break;
      }
      string_window("hari", 5, 18, 0);
      ObjectSetText("hari", hari + ", " + DoubleToStr(Day(), 0) + " - " + DoubleToStr(Month(), 0) + " - " + DoubleToStr(Year(), 0), _fontSize+ 1 , "Impact", header_color);
      ObjectSet( "hari", OBJPROP_CORNER, text_corner);

      string_window( "Balance", 5, 15+20, 0); //
      ObjectSetText( "Balance","Balance   : " + DoubleToStr(AccountBalance(), 2), _fontSize, "Cambria", color_text);
      ObjectSet( "Balance", OBJPROP_CORNER,text_corner);  

      string_window( "Equity", 5, 30+20, 0); //
      ObjectSetText( "Equity","Equity     : " + DoubleToStr(AccountEquity(),2), _fontSize, "Cambria", equity_color); 
      ObjectSet( "Equity", OBJPROP_CORNER, text_corner);  
      
      string_window( "Profit", 5, 45+20, 0); 
      ObjectSetText( "Profit", "Profit    : " + DoubleToStr( XYZ,2) , _fontSize, "Cambria", equity_color); 
      ObjectSet( "Profit", OBJPROP_CORNER, text_corner);
      
      string_window("Leverage", 5, 60 + 20, 0);
      ObjectSetText("Leverage", "Leverage   : " + DoubleToStr(AccountLeverage(), 0), _fontSize, "Cambria", color_text);
      ObjectSet("Leverage", OBJPROP_CORNER, text_corner);

      string_window( "Spread", 5,75+20, 0);
      ObjectSetText( "Spread","Spread   : " + DoubleToStr(_symbol.GetSpread(), 1), _fontSize, "Cambria", color_text);
      ObjectSet( "Spread", OBJPROP_CORNER, text_corner);
      
      double Range = (iHigh(NULL, 1440, 0) - iLow(NULL, 1440, 0)) / _symbol.GetPipSize();
      string_window( "Range", 5, 90+20, 0); //
      ObjectSetText( "Range","Range : " + DoubleToStr(Range,1) , _fontSize, "Cambria", color_text); 
      ObjectSet( "Range", OBJPROP_CORNER, text_corner); 
      
      string_window( "Price", 5, 125, 0); //
      ObjectSetText("Price", "Price : " + DoubleToStr(Bid, Digits), _fontSize, "Cambria", GetPriceColor()); 
      ObjectSet( "Price", OBJPROP_CORNER, text_corner); 
   }
private:
   color GetPriceColor()
   {
      return Volume[0] %2 == 0 ? color_text : equity_color;
   }

   int string_window( string n, int xoff, int yoff, int WindowToUse )
   {
      ObjectCreate( n, OBJ_LABEL, WindowToUse, 0, 0 );
      ObjectSet( n, OBJPROP_CORNER, 1 );
      ObjectSet( n, OBJPROP_XDISTANCE, xoff );
      ObjectSet( n, OBJPROP_YDISTANCE, yoff );
      ObjectSet( n, OBJPROP_BACK, true );
      return (0);
   }
};

TradeController *controller;
AccountStatistics *stats;

int OnInit()
{
   double temp = iCustom(NULL, 0, "Scalping indicator", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Scalping indicator' indicator");
      return INIT_FAILED;
   }
   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   stats = NULL;
   controller = NULL;
   TradingTime *tradingTime = new TradingTime();
   string error;
   if (!tradingTime.Init(start_time, stop_time, error))
   {
      delete tradingTime;
      Print(error);
      return INIT_FAILED;
   }
   if (use_weekly_timing && !tradingTime.SetWeekTradingTime(week_start_day, week_start_time, week_stop_day, week_stop_time, error))
   {
      delete tradingTime;
      Print(error);
      return INIT_FAILED;
   }
#ifdef USE_MARTINGALE
   if (lots_type == PositionSizeRisk && martingale_type == MartingaleOnLoss)
   {
      Print("Error: martingale_type couldn't be used with this lot type!");
      delete tradingTime;
      return INIT_FAILED;
   }
#endif

   TradeCalculator *tradeCalculator = new TradeCalculator(_Symbol);
   if (!tradeCalculator.IsLotsValid(lots_value, lots_type, error))
   {
      delete tradeCalculator;
      Print("Error: " + error);
      delete tradingTime;
      return INIT_FAILED;
   }
   Signaler *signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   controller = new TradeController(tradeCalculator, (ENUM_TIMEFRAMES)_Period, signaler);
#ifdef USE_STOP_LOSS
   controller.SetBreakeven(new BreakevenLogic(tradeCalculator, breakeven_type, breakeven_value, breakeven_level, signaler));
   controller.SetTrailing(new TrailingLogic(trailing_type, trailing_step, atr_trailing_multiplier, (ENUM_TIMEFRAMES)_Period, signaler));
#else
   controller.SetBreakeven(new DisabledBreakevenLogic());
   controller.SetTrailing(new DisabledTrailingLogic());
#endif
   controller.SetTradingTime(tradingTime);
#ifdef USE_MARTINGALE
   switch (martingale_type)
   {
      case MartingaleDoNotUse:
         controller.SetShortMartingaleStrategy(new NoMartingaleStrategy());
         controller.SetLongMartingaleStrategy(new NoMartingaleStrategy());
         break;
      case MartingaleOnLoss:
         controller.SetShortMartingaleStrategy(new ActiveMartingaleStrategy(tradeCalculator, martingale_lot_sizing_type, martingale_step, martingale_lot_value));
         controller.SetLongMartingaleStrategy(new ActiveMartingaleStrategy(tradeCalculator, martingale_lot_sizing_type, martingale_step, martingale_lot_value));
         break;
   }
#else
   controller.SetMartingaleStrategy(new NoMartingaleStrategy());
#endif

   ICondition *longCondition = trading_side != ShortSideOnly ? (ICondition *)new LongCondition(_Symbol, (ENUM_TIMEFRAMES)_Period) : (ICondition *)new DisabledCondition();
   ICondition *shortCondition = trading_side != LongSideOnly ? (ICondition *)new ShortCondition(_Symbol, (ENUM_TIMEFRAMES)_Period) : (ICondition *)new DisabledCondition();
   IMoneyManagementStrategy *longMoneyManagement = new LongMoneyManagementStrategy(tradeCalculator);
   IMoneyManagementStrategy *shortMoneyManagement = new ShortMoneyManagementStrategy(tradeCalculator);
   ICondition *exitLongCondition = new ExitLongCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ICondition *exitShortCondition = new ExitShortCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   switch (logic_direction)
   {
      case DirectLogic:
         controller.SetLongCondition(longCondition);
         controller.SetShortCondition(shortCondition);
         controller.SetLongMoneyManagement(longMoneyManagement);
         controller.SetShortMoneyManagement(shortMoneyManagement);
         controller.SetExitLongCondition(exitLongCondition);
         controller.SetExitShortCondition(exitShortCondition);
         break;
      case ReversalLogic:
         controller.SetLongCondition(shortCondition);
         controller.SetShortCondition(longCondition);
         controller.SetLongMoneyManagement(shortMoneyManagement);
         controller.SetShortMoneyManagement(longMoneyManagement);
         controller.SetExitLongCondition(exitShortCondition);
         controller.SetExitShortCondition(exitLongCondition);
         break;
   }
   controller.SetExitAllCondition(new DisabledCondition());
   if (net_stop_loss_type != StopLimitDoNotUse)
      controller.SetNetStopLossStrategy(new NetStopLossStrategy(tradeCalculator, net_stop_loss_type, net_stop_loss_value, signaler, magic_number));
   else
      controller.SetNetStopLossStrategy(new NoNetStopLossStrategy());
#ifdef USE_NET_TAKE_PROFIT
   if (net_take_profit_type != StopLimitDoNotUse)
      controller.SetNetTakeProfitStrategy(new NetTakeProfitStrategy(tradeCalculator, net_take_profit_type, net_take_profit_value, signaler, magic_number));
   else
#endif
      controller.SetNetTakeProfitStrategy(new NoNetTakeProfitStrategy());

   stats = new AccountStatistics("Scalping EA");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete stats;
   delete controller;
}

void OnTick()
{
   controller.DoTrading();
   stats.Update();
}
