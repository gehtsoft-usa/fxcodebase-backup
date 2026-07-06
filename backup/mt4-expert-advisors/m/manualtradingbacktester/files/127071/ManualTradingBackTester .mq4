// Id: 25382
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68379

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

#property strict

#import "user32.dll"
   bool GetAsyncKeyState(int a0);
#import

extern string KEY = " --- Hot Key Settings --- ";
extern string HotKey_Buy = "B";
extern string HotKey_Sell = "S";
extern string HotKey_Close_Buy = "0";
extern string HotKey_Close_Sell = "1";
extern string HotKey_CloseAll = "C";
extern string HotKey_Breakeven = "R";
extern string GENERAL = " --- General Settings --- ";
extern double OpenLot = 0.1;
extern bool UseAutoLots = FALSE;
extern double Risk_Ratio = 5.0;
extern double TakeProfit = 50.0;
extern double StopLoss = 50.0;
extern bool UseBE = FALSE;
extern double BEPoint = 25.0;
extern bool UseTrailingStop = FALSE;
extern double TrailingStop = 25.0;
extern double TrailingStep = 1.0;
extern bool DisplayData = TRUE;
int G_digits_204;
int G_count_208;
int G_count_212;
int buy_key;
int sell_key;
int close_buy_key;
int close_sell_key;
int close_all_key;
int breakeven_key;
int G_magic_236 = 100;
double Gd_240;
double Gd_248;
double Gd_256;
string G_comment_264;
int G_datetime_272;

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


// Orders iterator v 1.8
// More templates and snippets on https://github.com/sibvic/mq4-templates
enum CompareType
{
   CompareLessThan
};

enum OrderSide
{
   BuySide,
   SellSide
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

enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $,
   StopLimitRiskReward, // Set in % of stop loss
   StopLimitAbsolute // Set in absolite value (rate)
};

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk // Risk in % of equity
};

// Trade calculator v.1.15
// More templates and snippets on https://github.com/sibvic/mq4-templates

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

// Trading commands v.2.6
// More templates and snippets on https://github.com/sibvic/mq4-templates

class TradingCommands
{
public:
   static bool MoveSLTP(const int ticketId, const double newStopLoss, const double newTakeProfit, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
      {
         error = "Trade not found";
         return false;
      }

      int res = OrderModify(ticketId, OrderOpenPrice(), newStopLoss, newTakeProfit, 0, CLR_NONE);
      if (res == 0)
      {
         int errorCode = GetLastError();
         switch (errorCode)
         {
            case ERR_INVALID_TICKET:
               error = "Trade not found";
               return false;
            default:
               error = "Last error: " + IntegerToString(errorCode);
               break;
         }
      }
      return true;
   }

   static bool MoveSL(const int ticketId, const double newStopLoss, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
      {
         error = "Trade not found";
         return false;
      }

      int res = OrderModify(ticketId, OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, CLR_NONE);
      if (res == 0)
      {
         int errorCode = GetLastError();
         switch (errorCode)
         {
            case ERR_INVALID_TICKET:
               error = "Trade not found";
               return false;
            default:
               error = "Last error: " + IntegerToString(errorCode);
               break;
         }
      }
      return true;
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
         case ERR_TRADE_NOT_ALLOWED:
            error = "Trading is not allowed";
            break;
         case ERR_INVALID_PRICE:
            error = "Invalid closing price: " + DoubleToStr(price);
            break;
         case ERR_INVALID_TRADE_VOLUME:
            error = "Invalid trade volume: " + DoubleToStr(amount);
            break;
         default:
            error = "Last error: " + IntegerToString(lastError);
            break;
      }
      return false;
   }

   static int CloseTrades(OrdersIterator &it, const int slippage)
   {
      int closedPositions = 0;
      while (it.Next())
      {
         string error;
         if (!CloseCurrentOrder(slippage, error))
            Print("Failed to close positoin. ", error);
         else
            ++closedPositions;
      }
      return closedPositions;
   }
};

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

TradeCalculator* _calculator;

int init() 
{
   _calculator = TradeCalculator::Create(_Symbol);
   Gd_240 = MarketInfo(Symbol(), MODE_POINT);
   G_digits_204 = MarketInfo(Symbol(), MODE_DIGITS);
   if (G_digits_204 == 3 || G_digits_204 == 5) Gd_240 = 10.0 * Gd_240;
   buy_key = GetKey(HotKey_Buy);
   sell_key = GetKey(HotKey_Sell);
   close_buy_key = GetKey(HotKey_Close_Buy);
   close_sell_key = GetKey(HotKey_Close_Sell);
   close_all_key = GetKey(HotKey_CloseAll);
   breakeven_key = GetKey(HotKey_Breakeven);
   G_comment_264 = "ManualTradingBackTester, " + Symbol() + " " + Period();
   G_datetime_272 = TimeCurrent();
   IndicatorName = GenerateIndicatorName("ManualTradingBackTester");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return (0);
}

int deinit() 
{
   delete _calculator;
   _calculator = NULL;
   Comment("");
   f0_0("LOGO");
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}

#define VK_LSHIFT         0xA0
#define VK_RSHIFT         0xA1
#define VK_LCONTROL       0xA2
#define VK_RCONTROL       0xA3
#define VK_LMENU          0xA4
#define VK_RMENU          0xA5

int start() 
{
   f0_8();
   if (GetAsyncKeyState(VK_LCONTROL))
   {
      if (GetAsyncKeyState(buy_key)) 
         f0_6(OP_BUY);
      else if (GetAsyncKeyState(sell_key)) 
         f0_6(OP_SELL);
      else if (GetAsyncKeyState(close_buy_key)) 
         f0_7(OP_BUY);
      else if (GetAsyncKeyState(close_sell_key)) 
         f0_7(OP_SELL);
      else if (GetAsyncKeyState(close_all_key)) 
         f0_7(OP_BUYLIMIT);
      else if (GetAsyncKeyState(breakeven_key))
         DoBreakeven();
   }
   f0_9();
   f0_5();
   return (0);
}

void DoBreakeven()
{
   OrdersIterator longTrades();
   longTrades.WhenSymbol(_Symbol);
   longTrades.WhenOrderType(OP_BUY);
   double amount;
   double longBreakeven = _calculator.GetBreakevenPrice(longTrades, BuySide, amount);
   string error;
   if (longBreakeven != 0.0)
   {
      longTrades.Reset();
      while (longTrades.Next())
      {
         if (!TradingCommands::MoveSL(longTrades.GetTicket(), longBreakeven, error))
         {
            Print(error);
         }
      }
   }

   OrdersIterator shortTrades();
   shortTrades.WhenSymbol(_Symbol);
   shortTrades.WhenOrderType(OP_SELL);
   double shortBreakeven = _calculator.GetBreakevenPrice(shortTrades, SellSide, amount);
   if (shortBreakeven != 0.0)
   {
      shortTrades.Reset();
      while (shortTrades.Next())
      {
         if (!TradingCommands::MoveSL(shortTrades.GetTicket(), shortBreakeven, error))
         {
            Print(error);
         }
      }
   }
}

void f0_8() 
{
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) 
   {
      if (OrderSelect(pos_0, SELECT_BY_POS)) 
      {
         if (OrderSymbol() == Symbol()) 
         {
            if (OrderMagicNumber() == G_magic_236) 
            {
               if (UseBE) 
                  f0_4();
               if (UseTrailingStop) 
                  f0_2();
            }
         }
      }
   }
}

void f0_2() 
{
   if (OrderType() == OP_BUY && Bid >= OrderOpenPrice() + TrailingStop * Gd_240) 
   {
      if (!(OrderStopLoss() == 0.0 || OrderStopLoss() < Bid - TrailingStop * Gd_240 - TrailingStep * Gd_240)) 
         return;
      OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * Gd_240, OrderTakeProfit(), 0, CLR_NONE);
      return;
   }
   if (OrderType() == OP_SELL && Ask <= OrderOpenPrice() - TrailingStop * Gd_240)
      if (OrderStopLoss() == 0.0 || OrderStopLoss() > Ask + TrailingStop * Gd_240 + TrailingStep * Gd_240) 
         OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TrailingStop * Gd_240, OrderTakeProfit(), 0, CLR_NONE);
}

void f0_4() 
{
   if (OrderStopLoss() != OrderOpenPrice()) 
   {
      if (OrderType() == OP_BUY) 
      {
         if (!(OrderStopLoss() == 0.0 || OrderStopLoss() < OrderOpenPrice() && Bid >= OrderOpenPrice() + BEPoint * Gd_240)) 
            return;
         OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, CLR_NONE);
         return;
      }
      if (OrderType() == OP_SELL)
         if (OrderStopLoss() == 0.0 || OrderStopLoss() > OrderOpenPrice() && Ask <= OrderOpenPrice() - BEPoint * Gd_240) 
            OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, CLR_NONE);
   }
}

void f0_7(int A_cmd_0) 
{
   int pos_4 = 0;
   while (pos_4 < OrdersTotal()) 
   {
      if (!(OrderSelect(pos_4, SELECT_BY_POS))) 
         continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_236 && A_cmd_0 == OP_BUYLIMIT || OrderType() == A_cmd_0) 
         f0_12();
      else 
         pos_4++;
   }
}

void f0_9() 
{
   string Ls_4;
   if (DisplayData) 
   {
      Gd_248 = 0;
      Gd_256 = 0;
      G_count_208 = 0;
      G_count_212 = 0;
      for (int pos_0 = OrdersHistoryTotal() - 1; pos_0 >= 0; pos_0--) 
      {
         if (OrderSelect(pos_0, SELECT_BY_POS, MODE_HISTORY)) 
         {
            if (OrderSymbol() == Symbol()) 
            {
               if (OrderMagicNumber() == G_magic_236) 
               {
                  if (OrderCloseTime() >= G_datetime_272) 
                  {
                     if (OrderProfit() >= 0.0) 
                     {
                        G_count_208++;
                        Gd_248 += OrderProfit();
                        continue;
                     }
                     G_count_212++;
                     Gd_256 += OrderProfit();
                  }
               }
            }
         }
      }
   }
   if (!DisplayData) 
      Ls_4 = "";
   else 
   {
      Ls_4 = "\n-----------------------------" 
         + "\n-- " + "Total realized profit/loss:  " + DoubleToStr(Gd_248 + Gd_256, 2) 
         + "\n-- " + "Total # of trades:  " + ((G_count_208 + G_count_212)) 
         + "\n-----------------------------" 
         + "\n-- " + "# of winning trades:  " + G_count_208 
         + "\n-- " + "Total realized profit from winning trades:  " + DoubleToStr(Gd_248, 2) 
         + "\n-- " + "# of losing trades:  " + G_count_212 
      + "\n-- " + "Total realized loss from losing trades:  " + DoubleToStr(Gd_256, 2);
   }
   Comment("\nWise-EA Concept EA: CL_EC_01_ManualTradingBackTester" 
      + "\n-----------------------------" 
      + "\n-- " + "Buy:  " + HotKey_Buy + " | Sell:  " + HotKey_Sell + " | Close_Buy:  " + HotKey_Close_Buy + " | Close_Sell:  " + HotKey_Close_Sell + " | Close All:  " + HotKey_CloseAll + Ls_4 
   + "\n-----------------------------");
}

void f0_6(int A_cmd_0) 
{
   string Ls_4;
   double price_12;
   double price_20;
   double price_28;
   int error_48;
   color color_36 = Lime;
   if (A_cmd_0 == OP_SELL || A_cmd_0 == OP_SELLLIMIT || A_cmd_0 == OP_SELLSTOP) 
      color_36 = Red;
   if (A_cmd_0 == OP_BUY) 
   {
      price_12 = Ask;
      Ls_4 = " BUY";
   } 
   else 
   {
      if (A_cmd_0 == OP_SELL) 
      {
         price_12 = Bid;
         Ls_4 = " SELL";
      }
   }
   int ticket_40 = OrderSend(Symbol(), A_cmd_0, f0_10(), price_12, 5, 0, 0, G_comment_264, G_magic_236, 0, color_36);
   if (ticket_40 > 0) 
   {
      if (ticket_40 > 0 && OrderSelect(ticket_40, SELECT_BY_TICKET, MODE_TRADES)) 
      {
         Alert(TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + G_comment_264 + " | " + Ls_4 + " order (" + OrderTicket() + ") opened: " + " @" + DoubleToStr(OrderOpenPrice(),
            G_digits_204));
         if (A_cmd_0 == OP_BUY) 
         {
            if (StopLoss != 0.0) 
               price_20 = OrderOpenPrice() - StopLoss * Gd_240;
            else 
               price_20 = 0;
            if (TakeProfit != 0.0) 
               price_28 = OrderOpenPrice() + TakeProfit * Gd_240;
            else 
               price_28 = 0;
         } 
         else 
         {
            if (A_cmd_0 == OP_SELL) 
            {
               if (StopLoss != 0.0) 
                  price_20 = OrderOpenPrice() + StopLoss * Gd_240;
               else 
                  price_20 = 0;
               if (TakeProfit != 0.0) 
                  price_28 = OrderOpenPrice() - TakeProfit * Gd_240;
               else 
                  price_28 = 0;
            }
         }
         if (price_28 != 0.0 || price_20 != 0.0) 
         {
            for (int Li_44 = 5; Li_44 > 0; Li_44--) 
            {
               OrderModify(ticket_40, OrderOpenPrice(), price_20, price_28, 0, CLR_NONE);
               error_48 = GetLastError();
               if (error_48 == 1/* NO_RESULT */) 
                  error_48 = 0;
               if (error_48 == 0/* NO_ERROR */) 
                  break;
               Sleep(1000);
               RefreshRates();
            }
         }
      }
   } 
   else 
      Print(TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + G_comment_264 + " | " + " Error opening order : ", GetLastError());
}

void f0_12() 
{
   double price_0;
   if (OrderType() == OP_BUY) 
      price_0 = Bid;
   else if (OrderType() == OP_SELL) 
      price_0 = Ask;
   bool is_closed_8 = OrderClose(OrderTicket(), OrderLots(), price_0, 5, MediumSeaGreen);
   if (is_closed_8) 
   {
      Alert(TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + G_comment_264 + " | " + " Order (" + OrderTicket() + ")  closed: " + " @" + DoubleToStr(OrderClosePrice(),
         G_digits_204));
      return;
   }
   Print(TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + G_comment_264 + " | " + " Error closing order : ", GetLastError());
}

double f0_10() 
{
   int Li_8;
   double marginrequired_12;
   double Ld_ret_0 = 0;
   if (UseAutoLots) 
   {
      if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.01) 
         Li_8 = 2;
      else 
      {
         if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) 
            Li_8 = 1;
         else 
            Li_8 = 0;
      }
      marginrequired_12 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
      Ld_ret_0 = NormalizeDouble(AccountBalance() * (Risk_Ratio / 100.0) / marginrequired_12, Li_8);
   } 
   else 
      Ld_ret_0 = OpenLot;
   if (Ld_ret_0 < MarketInfo(Symbol(), MODE_MINLOT)) 
      Ld_ret_0 = MarketInfo(Symbol(), MODE_MINLOT);
   else if (Ld_ret_0 > MarketInfo(Symbol(), MODE_MAXLOT)) 
      Ld_ret_0 = MarketInfo(Symbol(), MODE_MAXLOT);
   return (Ld_ret_0);
}

int GetKey(string As_0) 
{
   if (StringFind(f0_3(As_0), "0") > -1) return (48);
   if (StringFind(f0_3(As_0), "1") > -1) return (49);
   if (StringFind(f0_3(As_0), "2") > -1) return (50);
   if (StringFind(f0_3(As_0), "3") > -1) return (51);
   if (StringFind(f0_3(As_0), "4") > -1) return (52);
   if (StringFind(f0_3(As_0), "5") > -1) return (53);
   if (StringFind(f0_3(As_0), "6") > -1) return (54);
   if (StringFind(f0_3(As_0), "7") > -1) return (55);
   if (StringFind(f0_3(As_0), "8") > -1) return (56);
   if (StringFind(f0_3(As_0), "9") > -1) return (57);
   if (StringFind(f0_3(As_0), "A") > -1) return (65);
   if (StringFind(f0_3(As_0), "B") > -1) return (66);
   if (StringFind(f0_3(As_0), "C") > -1) return (67);
   if (StringFind(f0_3(As_0), "D") > -1) return (68);
   if (StringFind(f0_3(As_0), "E") > -1) return (69);
   if (StringFind(f0_3(As_0), "F") > -1) return (70);
   if (StringFind(f0_3(As_0), "G") > -1) return (71);
   if (StringFind(f0_3(As_0), "H") > -1) return (72);
   if (StringFind(f0_3(As_0), "I") > -1) return (73);
   if (StringFind(f0_3(As_0), "J") > -1) return (74);
   if (StringFind(f0_3(As_0), "K") > -1) return (75);
   if (StringFind(f0_3(As_0), "L") > -1) return (76);
   if (StringFind(f0_3(As_0), "M") > -1) return (77);
   if (StringFind(f0_3(As_0), "N") > -1) return (78);
   if (StringFind(f0_3(As_0), "O") > -1) return (79);
   if (StringFind(f0_3(As_0), "P") > -1) return (80);
   if (StringFind(f0_3(As_0), "Q") > -1) return (81);
   if (StringFind(f0_3(As_0), "R") > -1) return (82);
   if (StringFind(f0_3(As_0), "S") > -1) return (83);
   if (StringFind(f0_3(As_0), "T") > -1) return (84);
   if (StringFind(f0_3(As_0), "U") > -1) return (85);
   if (StringFind(f0_3(As_0), "V") > -1) return (86);
   if (StringFind(f0_3(As_0), "W") > -1) return (87);
   if (StringFind(f0_3(As_0), "X") > -1) return (88);
   if (StringFind(f0_3(As_0), "Y") > -1) return (89);
   if (StringFind(f0_3(As_0), "Z") > -1) return (90);
   return (0);
}

string f0_3(string As_0) 
{
   string Ls_ret_16;
   int str_len_8 = StringLen(As_0);
   int Li_12 = 0;
   for (int Li_24 = 0; Li_24 < str_len_8; Li_24++) 
   {
      Li_12 = StringGetChar(As_0, Li_24);
      if (Li_12 >= 97 && Li_12 <= 122) 
         Li_12 -= 32;
      Ls_ret_16 = Ls_ret_16 + CharToStr(Li_12);
   }
   return (Ls_ret_16);
}

void f0_5() 
{
   f0_1("LOGO" + "0", "", 20, DarkGray, 3, 275, 5, "Arial", 150);
   f0_1("LOGO" + "1", "Product of Wise-EA Programming", 10, DarkGray, 3, 70, 10, "Arial", 0);
   f0_1("LOGO" + "2", "", 20, DarkGray, 3, 37, 5, "Arial", 151);
}

void f0_1(string A_name_0, string A_text_8, int A_fontsize_16, color A_color_20, int A_corner_24, int A_x_28, int A_y_32, string A_fontname_36, int Ai_44) 
{
   ObjectDelete(IndicatorObjPrefix + A_name_0);
   ObjectCreate(IndicatorObjPrefix + A_name_0, OBJ_LABEL, 0, 0, 0);
   if (A_text_8 != "") 
      ObjectSetText(IndicatorObjPrefix + A_name_0, A_text_8, A_fontsize_16, A_fontname_36, A_color_20);
   else 
      ObjectSetText(IndicatorObjPrefix + A_name_0, CharToStr(Ai_44), A_fontsize_16, "Wingdings", A_color_20);
   ObjectSet(IndicatorObjPrefix + A_name_0, OBJPROP_CORNER, A_corner_24);
   ObjectSet(IndicatorObjPrefix + A_name_0, OBJPROP_XDISTANCE, A_x_28);
   ObjectSet(IndicatorObjPrefix + A_name_0, OBJPROP_YDISTANCE, A_y_32);
}

void f0_0(string As_0) 
{
   string name_12;
   int Li_8 = 0;
   while (Li_8 < ObjectsTotal()) 
   {
      name_12 = ObjectName(Li_8);
      if (StringSubstr(name_12, 0, StringLen(As_0)) == As_0) 
         ObjectDelete(name_12);
      else 
         Li_8++;
   }
}
