// Id: 22852
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66948

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

extern string start_time = "170000"; // Start time in hhmmss format
extern string stop_time = "000000"; // Stop time in hhmmss format

extern string File = ""; // File
extern string Separator = ","; // Separator
extern int UpdatePeriod = 30; // Update Period (min)

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

TradingTime *tradingTime;

int OnInit()
{
   tradingTime = new TradingTime();
   string error;
   if (!tradingTime.Init(start_time, stop_time, error))
   {
      delete tradingTime;
      Print(error);
      return INIT_FAILED;
   }
   EventSetTimer(UpdatePeriod * 60);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   delete tradingTime;
}

void OnTimer()
{
   if (!tradingTime.IsTradingTime(Time[0]))
      return;

   logMerge();
}

void logMerge()
{
   int fileHandle = FileOpen(File + ".csv", FILE_WRITE | FILE_CSV, Separator);
   if (fileHandle == -1)
      fileHandle = FileOpen("mt4.csv", FILE_WRITE | FILE_CSV, Separator);
   FileWrite(fileHandle, "Balance", "Equity", "Used Mr", "Usable Mr %", "Gross P/L"); 
   double Balance = AccountBalance();
   double Equity = AccountEquity();
   double Used = AccountMargin();
   double Usable = NormalizeDouble(((Equity - Used) / Equity) * 100.0, 2);
   double Gross = Equity - Balance;
   FileWrite(fileHandle, DoubleToStr(Balance, 2), DoubleToStr(Equity, 2), DoubleToStr(Used, 2), DoubleToStr(Usable, 0), DoubleToStr(Gross, 2)); 
   FileWrite(fileHandle, "Symbol", "Amount", "S/B", "P/L", "Gross P/L", "Limit", "Stop"); 
   logTradesTable(fileHandle);
}

// Orders iterator v 1.7
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

struct TradeData
{
   int Ticket;
   double Profit;
   double TP;
   double SL;
   string Type;
   string Instrument;
   double Lots;
   double PLPips;
   int digits;
};

int FindMostProfit(TradeData &trades[])
{
   int index = -1;
   for (int i = 0; i < ArraySize(trades); ++i)
   {
      if (trades[i].Ticket < 0)
         continue;
      if (index == -1 || trades[index].Profit < trades[i].Profit)
         index = i;
   }
   return index;
}

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


void logTradesTable(int fileHandle)
{
   TradeData trades[];
   OrdersIterator it();
   it.WhenTrade();
   int arraySize = 0;
   while (it.Next())
   {
      ArrayResize(trades, ++arraySize);
      InstrumentInfo instrument(OrderSymbol());
      trades[arraySize - 1].digits = instrument.GetDigits();
      trades[arraySize - 1].Ticket = OrderTicket();
      if (OrderType() == OP_BUY)
         trades[arraySize - 1].PLPips = (instrument.GetBid() - OrderOpenPrice()) / instrument.GetPipSize();
      else
         trades[arraySize - 1].PLPips = (OrderOpenPrice() - instrument.GetAsk()) / instrument.GetPipSize();
      trades[arraySize - 1].Profit = OrderProfit();
      trades[arraySize - 1].TP = OrderTakeProfit();
      trades[arraySize - 1].SL = OrderStopLoss();
      trades[arraySize - 1].Type = OrderType() == OP_BUY ? "B" : "S";
      trades[arraySize - 1].Lots = OrderLots();
      trades[arraySize - 1].Instrument = OrderSymbol();
   }
   
   int i = FindMostProfit(trades);
   while (i != -1)
   {
      FileWrite(fileHandle, trades[i].Instrument, trades[i].Lots, trades[i].Type, 
         DoubleToStr(trades[i].PLPips, 1), DoubleToStr(trades[i].Profit, 2), 
         DoubleToString(trades[i].TP, trades[i].digits), DoubleToStr(trades[i].SL, trades[i].digits));
      trades[i].Ticket = -1;
      i = FindMostProfit(trades);
   }
   FileClose(fileHandle);
}
