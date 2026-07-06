// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69050

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

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

input color Label = Gray; // Labels color
input int x = 50; // X
input int y = 50; // Y

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

class GridTextCell
{
   string _text;
   color _clr;
   uint _width;
   uint _height;
   string _id;
public:
   GridTextCell(string id)
   {
      _id = id;
   }

   void SetData(string text, color clr)
   {
      TextSetFont("Arial", -120);
      TextGetSize(text, _width, _height);
      _text = text;
      _clr = clr;
   }

   void Draw(int __x, int __y)
   {
      ResetLastError();
      string id = _id;
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetInteger(0, id, OBJPROP_XDISTANCE, __x);
         ObjectSetInteger(0, id, OBJPROP_YDISTANCE, __y);
         ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      }
      ObjectSetString(0, id, OBJPROP_TEXT, _text);
   }

   int GetWidth()
   {
      return (int)_width;
   }

   int GetHeight()
   {
      return (int)_height;
   }
};

class GridRow
{
   GridTextCell* _cells[];
   string _id;
public:
   GridRow(string id)
   {
      _id = id;
   }

   ~GridRow()
   {
      for (int i = 0; i < ArraySize(_cells); ++i)
      {
         delete _cells[i];
      }
      ArrayResize(_cells, 0);
   }

   void EnsureEnoughtCells(int newSize)
   {
      int oldSize = ArraySize(_cells);
      if (newSize <= oldSize)
         return;
      ArrayResize(_cells, newSize);
      for (int i = oldSize; i < newSize; ++i)
      {
         _cells[i] = new GridTextCell(_id + "-" + IntegerToString(i));
      }
   }

   int Size()
   {
      return ArraySize(_cells);
   }

   GridTextCell* Get(int index)
   {
      return _cells[index];
   }
};

class GridCells
{
   string _id;
   GridRow* _columns[];
   double _gap;
public:
   GridCells(string id, double gap)
   {
      _gap = gap;
      _id = id;
   }

   ~GridCells()
   {
      for (int i = 0; i < ArraySize(_columns); ++i)
      {
         delete _columns[i];
      }
      ArrayResize(_columns, 0);
   }

   void Clear()
   {

   }

   void Add(string text, color clr, int column, int row)
   {
      EnsureEnoughtColumns(column + 1);
      _columns[column].EnsureEnoughtCells(row + 1);
      _columns[column].Get(row).SetData(text, clr);
   }

   void Draw(int __x, int __y)
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }

         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }

      int currentX = __x;
      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentY = __y;
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            _columns[columnIndex].Get(rowIndex).Draw(currentX, currentY);
            currentY += maxHeight[rowIndex] * _gap;
         }
         currentX += maxWidth[columnIndex] * _gap;
      }
   }
private:
   void EnsureEnoughtColumns(int newSize)
   {
      int oldSize = ArraySize(_columns);
      if (oldSize <= newSize)
      {
         ArrayResize(_columns, newSize);
         for (int i = oldSize; i < newSize; ++i)
         {
            _columns[i] = new GridRow(_id + "-" + IntegerToString(i));
         }
      }
   }
};

GridCells* grid;

int init()
{
   IndicatorName = GenerateIndicatorName("Risk Reward Positions Overview");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   grid = new GridCells(IndicatorObjPrefix, 1.3);

   return 0;
}

int deinit()
{
   delete grid;
   grid = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

// Orders iterator v 1.11
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

enum CompareType
{
   CompareLessThan
};

// Order side enum v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide,
   SellSide
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

#endif

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   grid.Clear();
   int rowIndex = 1;
   grid.Add("Ticket", Label, 1, rowIndex);
   grid.Add("Symbol", Label, 2, rowIndex);
   grid.Add("S/B", Label, 3, rowIndex);
   grid.Add("R/R", Label, 4, rowIndex);
   grid.Add("Pips", Label, 5, rowIndex);
   grid.Add("Gross P/L", Label, 6, rowIndex);
   rowIndex = rowIndex + 1;

   double totalPL = 0;
   double totalGrossPL = 0;
   
   OrdersIterator trades;
   trades.WhenTrade();
   while (trades.Next())
   {
      double stopLoss = trades.GetStopLoss();
      double takeProfit = trades.GetTakeProfit();
      double open = trades.GetOpenPrice();
      string symbol = trades.GetSymbol();
      double close = iClose(symbol, PERIOD_M1, 0);
      string Risk = stopLoss == 0 || takeProfit == 0 ? "-" : "1";
      string Reward = stopLoss == 0 || takeProfit == 0 
         ? "-" 
         : DoubleToString(MathFloor(MathAbs(open - takeProfit) / MathAbs(open - stopLoss) + 0.5), 0);
      double point = MarketInfo(symbol, MODE_POINT);
      int digits = (int)MarketInfo(symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;
      double profit = trades.IsBuy() ? (close - open) / pipSize : (open - close) / pipSize;
      double grossProfit = trades.GetProfit();
      totalPL += profit;
      totalGrossPL += grossProfit;
      grid.Add(IntegerToString(trades.GetTicket()), Label, 1, rowIndex);
      grid.Add(symbol, Label, 2, rowIndex);
      grid.Add(trades.IsBuy() ? "B" : "S", Label, 3, rowIndex);
      grid.Add(Risk + ":" + Reward, Label, 4, rowIndex);
      grid.Add(DoubleToString(profit, 2), Label, 5, rowIndex);
      grid.Add(DoubleToString(grossProfit, 2), Label, 6, rowIndex);

      rowIndex = rowIndex + 1;
   }

   grid.Add("Total", Label, 4, rowIndex);
   grid.Add(DoubleToString(totalPL, 2), Label, 5, rowIndex);
   grid.Add("$" + DoubleToString(totalGrossPL, 2), Label, 6, rowIndex);
   rowIndex = rowIndex + 1;

   grid.Add("Active Trades: " + IntegerToString(rowIndex - 3), Label, 1, 0);
   int ordersIndex = rowIndex + 1;
   rowIndex = rowIndex + 2;

   grid.Add("Ticket", Label, 1, rowIndex);
   grid.Add("Symbol", Label, 2, rowIndex);
   grid.Add("S/B", Label, 3, rowIndex);
   grid.Add("R/R", Label, 4, rowIndex);
   grid.Add("Distance", Label, 5, rowIndex);
   rowIndex = rowIndex + 1;

   int ordersCount = 0;
   OrdersIterator orders;
   orders.WhenOrder();
   while (orders.Next())
   {
      double stopLoss = orders.GetStopLoss();
      double takeProfit = orders.GetTakeProfit();
      double open = orders.GetOpenPrice();
      string Risk = stopLoss == 0 || takeProfit == 0 ? "-" : "1";
      string Reward = stopLoss == 0 || takeProfit == 0 
         ? "-" 
         : DoubleToString(MathFloor(MathAbs(open - takeProfit) / MathAbs(open - stopLoss) + 0.5), 0);

      string symbol = orders.GetSymbol();
      double point = MarketInfo(symbol, MODE_POINT);
      int digits = (int)MarketInfo(symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;
      double distance = 0;
      double bid = MarketInfo(OrderSymbol(), MODE_BID);
      double ask = MarketInfo(OrderSymbol(), MODE_ASK);
      if (orders.IsBuy())
         distance = MathAbs(open - ask) / pipSize;
      else
         distance = MathAbs(open - bid) / pipSize;

      grid.Add(IntegerToString(orders.GetTicket()), Label, 1, rowIndex);
      grid.Add(symbol, Label, 2, rowIndex);
      grid.Add(orders.IsBuy() ? "B" : "S", Label, 3, rowIndex);
      grid.Add(Risk + ":" + Reward, Label, 4, rowIndex);
      grid.Add(DoubleToString(distance, 2), Label, 5, rowIndex);
      ordersCount = ordersCount + 1;
   }

   grid.Add("Entry Orders: " + IntegerToString(ordersCount), Label, 1, ordersIndex);
   grid.Draw(x, y);
   return 0;
}