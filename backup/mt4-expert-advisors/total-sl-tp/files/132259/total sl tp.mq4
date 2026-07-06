// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69573

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
#property strict

// Account statistics v1.4

extern color color_text = Lime; // General text color
extern color header_color = Yellow; // Headers color

// Orders iterator v 1.12
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

enum CompareType
{
   CompareLessThan,
   CompareMoreThan
};

// Order side enum v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide, // Buy/long
   SellSide // Sell/short
};

#endif

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
// Instrument info v.1.6
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

class AccountStatistics
{
   InstrumentInfo *_symbol;
   int _textCorner;
   string _eaName;
   int _fontSize;
   string _fontName;
   string _headersFontName;
public:
   AccountStatistics(string eaName)
   {
      _fontSize = 10;
      _eaName = eaName;
      _textCorner = 1;
      _symbol = new InstrumentInfo(_Symbol);
      _headersFontName = "Impact";
      _fontName = "Cambria";

      string_window(eaName + "EA_NAME", 5, 5, 0); 
      ObjectSet(eaName + "EA_NAME", OBJPROP_CORNER, 3); 
      ObjectSetText(eaName + "EA_NAME", _eaName, _fontSize + 3, _headersFontName, header_color);
   }

   ~AccountStatistics()
   {
      ObjectsDeleteAll(ChartID(), _eaName);
      delete _symbol;
   }

   void Update()
   {
      OrdersIterator it();
      it.WhenTrade().WhenSymbol(_Symbol);
      double tp = 0.0;
      double sl = 0.0;
      while (it.Next())
      {
         if (it.IsBuy())
         {
            if (it.GetTakeProfit() != 0)
            {
               tp += it.GetTakeProfit() - it.GetOpenPrice();
            }
            if (it.GetStopLoss() != 0)
            {
               sl += it.GetOpenPrice() - it.GetStopLoss();
            }
         }
         else
         {
            if (it.GetTakeProfit() != 0)
            {
               tp += it.GetOpenPrice() - it.GetTakeProfit();
            }
            if (it.GetStopLoss() != 0)
            {
               sl += it.GetStopLoss() - it.GetOpenPrice();
            }
         }
      }
      double point = MarketInfo(_Symbol, MODE_POINT);
      int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;
      string currentDate;
      MqlDateTime current_time;
      TimeToStruct(TimeCurrent(), current_time);
      switch (current_time.day_of_week)
      {
         case MONDAY:
            currentDate = "MONDAY";
            break;
         case TUESDAY:
            currentDate = "TUESDAY";
            break;
         case WEDNESDAY:
            currentDate = "WEDNESDAY";
            break;
         case THURSDAY:
            currentDate = "THURSDAY";
            break;
         case FRIDAY:
            currentDate = "FRIDAY";
            break;
         case SATURDAY:
            currentDate = "SATURDAY";
            break;
         case SUNDAY:
            currentDate = "SUNDAY";
            break;
      }
      string_window(_eaName + "currentDate", 5, 18, 0);
      ObjectSetText(_eaName + "currentDate", currentDate + ", " + DoubleToStr(Day(), 0) + " - " + DoubleToStr(Month(), 0) + " - " + DoubleToStr(Year(), 0), _fontSize+ 1 , _headersFontName, header_color);
      ObjectSet(_eaName + "currentDate", OBJPROP_CORNER, _textCorner);

      string_window(_eaName + "Balance", 5, 15 + 20, 0);
      ObjectSetText(_eaName + "Balance", "Stop loss: " + DoubleToStr(sl / pipSize, 1), _fontSize, _fontName, color_text);
      ObjectSet(_eaName + "Balance", OBJPROP_CORNER, _textCorner);  

      string_window(_eaName + "Equity", 5, 30 + 20, 0);
      ObjectSetText(_eaName + "Equity", "Take profit: " + DoubleToStr(tp / pipSize, 1), _fontSize, _fontName, color_text); 
      ObjectSet(_eaName + "Equity", OBJPROP_CORNER, _textCorner);  
   }
private:
   int string_window(string n, int xoff, int yoff, int WindowToUse)
   {
      ObjectCreate(n, OBJ_LABEL, WindowToUse, 0, 0);
      ObjectSet(n, OBJPROP_CORNER, 1);
      ObjectSet(n, OBJPROP_XDISTANCE, xoff);
      ObjectSet(n, OBJPROP_YDISTANCE, yoff);
      ObjectSet(n, OBJPROP_BACK, true);
      return 0;
   }
};

AccountStatistics* statistics;
int OnInit()
{
   statistics = new AccountStatistics("Total SL/TP");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete statistics;
   statistics = NULL;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   statistics.Update();
   return 0;
}