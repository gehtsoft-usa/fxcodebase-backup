//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74285

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0" 
#property strict


extern   string   _comment1=" ----------- News settings ----------- ";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeNS
  {
   INVEST=0,   // Investing.com
   DAILYFX=1,  // Dailyfx.com
  };
//--- input parameters 
extern TypeNS SourceNews=INVEST;
extern double   Lots                = 0.1;
extern bool     LowNews             = true;
extern int      LowIndentBefore     = 15;
extern int      LowIndentAfter      = 15;
extern bool     MidleNews           = true;
extern int      MidleIndentBefore   = 30;
extern int      MidleIndentAfter    = 30;
extern bool     HighNews            = true;
extern int      HighIndentBefore    = 60;
extern int      HighIndentAfter     = 60;
extern bool     NFPNews             = true;
extern int      NFPIndentBefore     = 180;
extern int      NFPIndentAfter      = 180;

extern bool    DrawNewsLines        = true;
extern color   LowColor             = clrGreen;
extern color   MidleColor           = clrBlue;
extern color   HighColor            = clrRed;
extern int     LineWidth            = 1;
extern ENUM_LINE_STYLE LineStyle    = STYLE_DOT;
extern bool    OnlySymbolNews       = true;
extern int  GMTplus=3;     // Your Time Zone, GMT (for news)

// ------------------------------------------------------------------
#define TRAILING_STOP_ON
#ifdef TRAILING_STOP_ON
enum TSLMode {
  byPips,  // By Pips
  byMA     // By Moving Average
};
input string tTailingStop = "== TrailingStop Setup ==";  // ————————————
input bool   TslON = true;                               // TSL ON:
TSLMode      userTslMode        = byPips;                // TSL Mode:
input int    userTslInitialStep = 1;                     // TSL Initial Step:
input int    userTslDistance    = 20;                    // TSL Distance:
int    userTslStep        = 1;                     // TSL Step:
#endif

class Order
{
  int      _id;
  string   _symbol;
  double   _price;
  double   _sl;
  double   _tp;
  double   _lot;
  int      _type;
  int      _magic;
  string   _comment;
  string   _strategy;
  datetime _expireTime;
  datetime _signalTime;
  double   _profit;
  double   _tslNext;
  bool     _bkvWasDoIt;
  int      _countPartials;

 public:
  Order(
      int      id,
      string   symbol,
      double   price,
      double   sl,
      double   tp,
      double   lot,
      int      type,
      int      magic,
      string   comment,
      string   strategy,
      datetime expireTime,
      datetime signalTime,
      double   profit,
      double   bkvWasDoIt,
      int      countPartials) : _id(id),
                           _symbol(symbol),
                           _price(price),
                           _sl(sl),
                           _tp(tp),
                           _lot(lot),
                           _type(type),
                           _magic(magic),
                           _comment(comment),
                           _strategy(strategy),
                           _expireTime(expireTime),
                           _signalTime(signalTime),
                           _profit(profit),
                           _bkvWasDoIt(bkvWasDoIt),
                           _countPartials(countPartials) {}

  Order() {}
  ~Order() {}

  // clang-format off
	Order* id(int id){_id=id; return &this;}
	Order* symbol(string symbol){_symbol=symbol; return &this;}
	Order* price(double price){_price=price; return &this;}
	Order* sl(double sl){_sl=sl; return &this;}
	Order* tp(double tp){_tp=tp; return &this;}
	Order* lot(double lot){_lot=lot; return &this;}
	Order* type(int type){_type=type; return &this;}
	Order* magic(int magic){_magic=magic; return &this;}
	Order* comment(string comment){_comment=comment; return &this;}
	Order* expireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* signalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* profit(double profit){_profit=profit; return &this;}
	Order* strategy(string strategy){_strategy=strategy; return &this;}
	Order* tslNext(double tslNext){_tslNext=tslNext; return &this;}
	Order* breakevenWasDoIt(bool bkvWasDoIt){_bkvWasDoIt=bkvWasDoIt; return &this;}
	Order* countPartials(int count){_countPartials=_countPartials + count; return &this;}

   int            id()               { return _id; }
   string         symbol()           { return _symbol; }
   double         price()            { return _price; }
   double         sl()               { return _sl; }
   double         tp()               { return _tp; }
   double         lot()              { return _lot; }
   int            type()             { return _type; }
   int            magic()            { return _magic; }
   string         comment()          { return _comment; }
   string         strategy()         { return _strategy; }
   datetime       expireTime()       { return _expireTime; }
   datetime       signalTime()       { return _signalTime; }
   double         profit()           { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit()+OrderCommission()+OrderSwap(); return -1; }
   double         tslNext()          { return _tslNext; }
   double         breakevenWasDoIt() { return _bkvWasDoIt; }
   int            countPartials()    { return _countPartials; }
};

class FilterBySymbols
{
   string _symbols[];

  public:
   FilterBySymbols(string userSymbols) { getSymbols(userSymbols); }
   ~FilterBySymbols() { ; }

   void getSymbols(string userSymbols)
   {
      string Simbolos[];
      string sep = ",";
      ushort u_sep;
      u_sep = StringGetCharacter(sep, 0);
      int k = StringSplit(userSymbols, u_sep, Simbolos);
      ArrayResize(_symbols, ArrayRange(Simbolos, 0), 0);
      for (int i = 0; i < ArrayRange(Simbolos, 0); i++)
      {
         _symbols[i] = Simbolos[i];
      }
      printSymbols();
   }

   bool control(const string symbolToControl)
   {
      if (ArraySize(_symbols) > 0)
      {
         for (int i = 0; i < ArraySize(_symbols); i++)
         {
            if (_symbols[i] == symbolToControl)
            {
               return true;
            }
         }
      }

      return false;
   }

   void printSymbols()
   {
      for (int i = 0; i < ArraySize(_symbols); i++)
      {
         Print(_symbols[i]);
      }
   }

   //---
};
class FilterByMagics
{
   int _magics[];

  public:
   FilterByMagics(string userMagics) { getMagics(userMagics); }
   ~FilterByMagics() { ; }

   void getMagics(string userMagics)
   {
      string Magicos[];
      string sep = ",";
      ushort u_sep;
      u_sep = StringGetCharacter(sep, 0);
      int k = StringSplit(userMagics, u_sep, Magicos);
      ArrayResize(_magics, ArrayRange(Magicos, 0), 0);
      for (int i = 0; i < ArrayRange(Magicos, 0); i++)
      {
         _magics[i] = (int)Magicos[i];
      }
      if (ArrayRange(_magics, 0) > 0)
      {
         ArraySort(_magics, WHOLE_ARRAY, 0, MODE_ASCEND);
      }
      printMagics();
   }

   bool control(const int magicToControl)
   {
      if (ArraySize(_magics) > 0)
      {			
         int p = ArrayBsearch(_magics, magicToControl, WHOLE_ARRAY, 0, MODE_ASCEND);
			if (_magics[p] == magicToControl)
         {
            return true;
         }
      }

      return false;
   }

   void printMagics()
   {
      for (int i = 0; i < ArraySize(_magics); i++)
      {
         Print(_magics[i]);
      }
   }
  
  
   //---
};
class OrdersList
{
   Order*          orders[];
   bool            _filterByMagicOn;
   bool            _filterBySymbolsOn;
   FilterByMagics* _magics;
   FilterBySymbols* _symbols;

  public:
  OrdersList(){;}
   OrdersList(bool uFilterByMagicOn, string uMagics, bool uFilterBySymbolsOn, string uSymbols)
   {
		_filterByMagicOn = uFilterByMagicOn;
		_filterBySymbolsOn = uFilterBySymbolsOn;
      _magics = new FilterByMagics(uMagics);
      _symbols = new FilterBySymbols(uSymbols);

      Print("New OrderList Created");
   }
   ~OrdersList() 
	{ 
		delete _magics;
		delete _symbols;
		clearList(); 
	}

   // ——————————————————————————————————————————————————————————————————

void setOrdersList(bool magicOn, string magics, bool symbolsOn, string symbols)
{
		_filterByMagicOn = magicOn;
		_filterBySymbolsOn = symbolsOn;
      _magics = new FilterByMagics(magics);
      _symbols = new FilterBySymbols(symbols);

}

   bool AddOrder(Order* order)
   {
      int t = ArraySize(orders);
      if (ArrayResize(orders, t + 1))
      {
         orders[t] = order;
         return true;
      }

      return false;
   }

   // recorrer las ordenes de mercado y agregar las que no estén en el array
   // ——————————————————————————————————————————————————————————————————
   void GetMarketOrders()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (_filterByMagicOn) if (!_magics.control(OrderMagicNumber())) { continue; }
            if (_filterBySymbolsOn) if (!_symbols.control(OrderSymbol())) { continue; }

            if (exist(OrderTicket()) == true) { continue; }

            Order* newOrder = new Order();
            newOrder
                .id(OrderTicket())
                .symbol(OrderSymbol())
                .price(OrderOpenPrice())
                .sl(OrderStopLoss())
                .tp(OrderTakeProfit())
                .lot(OrderLots())
                .type(OrderType())
                .magic(OrderMagicNumber())
                .comment(OrderComment())
                .expireTime(OrderExpiration())
                .profit(OrderProfit())
                .breakevenWasDoIt(false)
                .countPartials(0);

            if (AddOrder(newOrder))
            {
               PrintOrder(i);
            }
         }
      }
   }

   // agrega la última orden si no está en el array
   // ——————————————————————————————————————————————————————————————————
   bool GetLastMarketOrder()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (_filterByMagicOn) if(!_magics.control(OrderMagicNumber())) { continue; }
            if (_filterBySymbolsOn) if (!_symbols.control(OrderSymbol())) { continue; }
            if (exist(OrderTicket()) == true) { continue; }

            Order* newOrder = new Order();
            newOrder
                .id(OrderTicket())
                .symbol(OrderSymbol())
                .price(OrderOpenPrice())
                .sl(OrderStopLoss())
                .tp(OrderTakeProfit())
                .lot(OrderLots())
                .type(OrderType())
                .magic(OrderMagicNumber())
                .comment(OrderComment())
                .expireTime(OrderExpiration())
                .profit(OrderProfit())
                .breakevenWasDoIt(false)
                .countPartials(0);

            if (AddOrder(newOrder))
            {
                  Print(__FUNCTION__," ","* Nueva Orden De Mercado * ",id(i), "magic: ",magic(i));
                  // PrintOrder(i);
                  return true;
            }
         }
         return false;
      }
      return false;
   }

   // controlar si el id ya está adentro del array
   // ——————————————————————————————————————————————————————————————————
   bool exist(int id)
   {
      for (int i = qnt() - 1; i >= 0; i--)
      {
         if (id(i) == id)
         {
            return true;
         }
      }
      return false;
   }

   // borra una orden en la posición indicada y acomoda el array
   // ——————————————————————————————————————————————————————————————————
   bool deleteOrder(int index)
   {
      if (notOverFlow(index))
      {
         delete orders[index];
      }

      if (qnt() > index)
      {
         for (int i = index; i < qnt() - 1; i++)
         {
            orders[i] = orders[i + 1];
         }
         ArrayResize(orders, qnt() - 1);
         return true;
      }

      return false;
   }

   // borra todos los elementos de la lista
   // ——————————————————————————————————————————————————————————————————
   void clearList()
   {
      for (int i = 0; i < qnt(); i++)
      {
         if (CheckPointer(orders[i]) != POINTER_INVALID)
         {
            deleteOrder(i);
         }
      }
   }

   // devuelve el puntero a la última orden
   Order* last()
   {
      int lastIndex = ArraySize(orders) - 1;
      if (lastIndex == -1)
      {
         return NULL;
      }
      return GetPointer(orders[lastIndex]);
   }

   Order* index(int in)
   {
      return GetPointer(orders[in]);
   }

   int lastId()
   {
      int lastIndex = ArraySize(orders) - 1;
      return orders[lastIndex].id();
   }

   // ——————————————————————————————————————————————————————————————————
   bool notOverFlow(int index)
   {
      if (index > ArraySize(orders) - 1) return false;
      if (index < 0) return false;
      if (CheckPointer(orders[index]) == POINTER_INVALID) return false;

      return true;
   }

   // cantidad de ordenes guardadas
   // ——————————————————————————————————————————————————————————————————
   int qnt()
   {
      return ArraySize(orders);
   }

   // clang-format off
   // Metodos para acceder a información de cada trade mediante su index:
   // ——————————————————————————————————————————————————————————————————
   int id(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].id();
      }
      return -1;
   }
   string symbol(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].symbol();
      }
      return "";
   }
   double price(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].price();
      }
      return -1;
   }
   double sl(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].sl();
      }
      return -1;
   }
   double tp(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].tp();
      }
      return -1;
   }
   double lot(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].lot();
      }
      return -1;
   }
   int magic(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].magic();
      }
      return -1;
   }
   datetime expire(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].expireTime();
      }
      return -1;
   }
   datetime signalTime(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].signalTime();
      }
      return -1;
   }
   string comment(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].comment();
      }
      return "";
   }
   ENUM_ORDER_TYPE type(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].type();
      }
      return -1;
   }
   double profit(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].profit();
      }
      return -1;
   }

  // clang-format on

  // comprueba si la orden está cerrada
  // ——————————————————————————————————————————————————————————————————
  bool isClose(int index)
  {
    if (notOverFlow(index))
    {
      if (OrderSelect(id(index), SELECT_BY_TICKET))
      {
        if (OrderCloseTime() != 0) return true;
      }
    }
    return false;
  }

  // borra de la lista los trades cerrados
  // ——————————————————————————————————————————————————————————————————
  void cleanCloseOrders()
  {
    if (qnt() == 0)
    {
      return;
    }

    for (int i = 0; i < qnt(); i++)
    {
      if (isClose(i))
      {
        deleteOrder(i);
      }
    }
  }

  // cierra todas las ordenes en la lista y la limpia, te retorna la cantidad de errores
  int closeAllInList()
  {
    cleanCloseOrders();
    int errors = 0;

    for (int i = 0; i < ArraySize(orders); i++)
    {
      int tk;
      if (isClose(i))
      {
        continue;
      }
      if (CheckPointer(orders[i]) != POINTER_INVALID)
      {
        tk = orders[i].id();
      } else
      {
        continue;
      }
      if (OrderSelect(tk, SELECT_BY_TICKET))
      {
        double ask        = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
        double bid        = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
        double closePrice = OrderType() == OP_BUY ? bid : ask;
        if (!OrderClose(OrderTicket(), OrderLots(), closePrice, 1000, clrNONE))
        {
          Print(__FUNCTION__, " ", "Error in close order ", orders[i].id(), ": ", GetLastError());
          errors++;
        }
      }
    }

    cleanCloseOrders();

    return errors;
  }

  // ——————————————————————————————————————————————————————————————————
  void PrintOrder(const int index)
  {
    if (!notOverFlow(index))
    {
      return;
    }
    if (CheckPointer(orders[index]) == POINTER_INVALID)
    {
      return;
    }
    // clang-format off
      Print("Order ", index, " id: ",          orders[index].id());
      Print("Order ", index, " symbol: ",      orders[index].symbol());
      Print("Order ", index, " type: ",        orders[index].type());
      Print("Order ", index, " lot: ",         orders[index].lot());
      Print("Order ", index, " price: ",       orders[index].price());
      Print("Order ", index, " sl: ",          orders[index].sl());
      Print("Order ", index, " tp: ",          orders[index].tp());
      Print("Order ", index, " magic: ",       orders[index].magic());
      Print("Order ", index, " comment: ",     orders[index].comment());
      Print("Order ", index, " strategy: ",    orders[index].strategy());
      Print("Order ", index, " expire time: ", orders[index].expireTime());
      Print("Order ", index, " signal time: ", orders[index].signalTime());
      Print("Order ", index, " profit: ",      orders[index].profit());
      Print("Order ", index, " countPartials: ", orders[index].countPartials());
    // clang-format on
  }
  // ——————————————————————————————————————————————————————————————————
  void PrintList()
  {
    for (int i = 0; i < qnt(); i++)
    {
      PrintOrder(i);
    }
  }
};
OrdersList mainOrders(true, "0", true, _Symbol);

interface iConditions
{
  bool evaluate();
};
class ConcurrentConditions
{
 protected:
  iConditions* _conditions[];

 public:
  ConcurrentConditions(void) {}
  ~ConcurrentConditions(void) { releaseConditions(); }

  // ——————————————————————————————————————————————————————————————————
  void releaseConditions()
  {
    for (int i = 0; i < ArraySize(_conditions); i++)
    {
      delete _conditions[i];
    }
    ArrayFree(_conditions);
  }
  // ——————————————————————————————————————————————————————————————————
  void AddCondition(iConditions* condition)
  {
    int t = ArraySize(_conditions);
    ArrayResize(_conditions, t + 1);
    _conditions[t] = condition;
  }

  // ——————————————————————————————————————————————————————————————————
  bool EvaluateConditions(void)
  {
    for (int i = 0; i < ArraySize(_conditions); i++)
    {
      if (!_conditions[i].evaluate())
      {
        return false;
      }
    }
    return true;
  }
};
class ConditionMatchPrice : public iConditions
{
  string _symbol;
  string _side;
  double _price;
  int    _mode;  // 0: Ask>=Price & Bid <=Price , 1: Ask <= Price && Bid >= Price

 public:
  ConditionMatchPrice(string Symbol, string Side, double Price, int Mode)
  {
    _symbol = Symbol;
    _side   = Side;
    _price  = Price;
    _mode   = Mode;
  }
  ~ConditionMatchPrice() { ; }

  void   side(string inpside) { _side = inpside; }
  string side(void) { return _side; }
  void   symbol(string inpsymbol) { _symbol = inpsymbol; }
  string symbol(void) { return _symbol; }
  void   price(double inpprice) { _price = inpprice; }
  double price(void) { return _price; }
  void   mode(int inpmode) { _mode = inpmode; }
  int    mode(void) { return _mode; }

  bool evaluate()
  {
    double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);

    if (_mode == 0)
    {
      if (_side == "buy")
      {
        if (ask >= _price)
        {
          return true;
        }
        return false;
      }
      if (_side == "sell")
      {
        if (bid <= _price)
        {
          return true;
        }
        return false;
      }
    }

    if (_mode == 1)
    {
      if (_side == "buy")
      {
        if (ask <= _price)
        {
          return true;
        }
        return false;
      }
      if (_side == "sell")
      {
        if (bid >= _price)
        {
          return true;
        }
        return false;
      }
    }
    return false;
  }
};

interface iActions
{
  bool doAction();
};
class MoveSL : public iActions
{
  Order* _order;
  double _newSL;

 public:
  MoveSL() { ; }
  ~MoveSL() { ; }
    
  MoveSL* order(Order* or)
  {
    _order = or ;
    return &this;
  }
  MoveSL* newSL(double newSL)
  {
    _newSL = newSL;
    return &this;
  }

  bool controlPointer(Order* or)
  {
    if (CheckPointer(or))
    {
      return true;
    } else
    {
      Print("Order Pointer Invalid");
      return false;
    }
  }

  bool doAction()
  {
    if (!controlPointer(_order))
    {
      Print(__FUNCTION__, " ", "Can't Move Stop Loss");
      return false;
    }
    if (OrderSelect(_order.id(), SELECT_BY_TICKET))
    {
      if (OrderCloseTime() > 0)
      {
        Print(__FUNCTION__, " ", "Order are closed ", _order.id());
        return false;
      }

      if (OrderModify(_order.id(), OrderOpenPrice(), _newSL, OrderTakeProfit(), OrderExpiration(), clrNONE))
      {
        _order.sl(_newSL);
        _order.breakevenWasDoIt(true);
        Print(__FUNCTION__, " ", _order.id(), " Modify: new SL: ", _newSL);
        return true;
      }

    } else
    {
      Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
    }

    return false;
  }
};

interface iTSL
{
  void   setInitialStep(Order* order);
  void   setNextStep(Order* order);
  double newSL(Order* order);
};
class TslByPips : public iTSL
{
  int    _InitialStep;
  int    _TslStep;
  double _Distance;

 public:
  TslByPips(int InitialStep, int TslStep, double Distance)
  {
    _InitialStep = InitialStep * 10;
    _TslStep     = TslStep * 10;
    _Distance    = Distance * 10;
  }
  ~TslByPips() { ; }

  void setInitialStep(Order* order)
  {
    double mPoint       = MarketInfo(order.symbol(), MODE_POINT);
    double pointsToMove = _InitialStep * mPoint;
    if (order.type() == OP_SELL)
    {
      pointsToMove *= -1;
    }
    order.tslNext(order.price() + pointsToMove);

    Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
    Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
    Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
  }

  void setNextStep(Order* order)
  {
    double mPoint       = MarketInfo(order.symbol(), MODE_POINT);
    double pointsToMove = _TslStep * mPoint;
    if (order.type() == OP_SELL)
    {
      pointsToMove *= -1;
    }
    order.tslNext(order.tslNext() + pointsToMove);

    Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
    Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
    Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
  }

  double newSL(Order* order)
  {
    double mPoint       = MarketInfo(order.symbol(), MODE_POINT);
    double pointsToMove = _Distance * mPoint;
    if (order.type() == OP_SELL)
    {
      pointsToMove *= -1;
    }

    double newSl = order.tslNext() - pointsToMove;
    Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
    Print(__FUNCTION__, " ", "TSL New SL: ", " ", newSl);

    return newSl;
  }
};

class TrailingStop
{
  OrdersList* _orders;
  iTSL*       _TslMode;

 public:
  TrailingStop(OrdersList* uOrders, TSLMode mode)
  {
    _orders = uOrders;

    switch (mode)
    {
      case byPips:
        _TslMode = new TslByPips(userTslInitialStep, userTslStep, userTslDistance);
        break;
        // case byMA:
        // _TslMode = new TslByMA(userTslMaTf, tslMaPeriod, tslMaShift, tslMaMethod, tslMaAppliedPrice);
        // break;
    }
  }
  ~TrailingStop()
  {
    // delete _orders;
    delete _TslMode;
  }

  void doTSL()
  {
    for (int i = 0; i < _orders.qnt(); i++)
    {
      if (CheckPointer(_orders.index(i)) == POINTER_INVALID)
      {
        Print(__FUNCTION__, " ", "Pointer invalid i= ", i);
        continue;
      }

      // seteo Initial:
      if (_orders.index(i).tslNext() == 0)
      {
        _TslMode.setInitialStep(_orders.index(i));
      }

      if (MatchNextTsl(_orders.index(i)))
      {
        double newSl = _TslMode.newSL(_orders.index(i));
        moveSL(_orders.index(i).id(), newSl);
        _TslMode.setNextStep(_orders.index(i));
      }
    }
  }

  bool MatchNextTsl(Order* order)
  {
    double ask = SymbolInfoDouble(order.symbol(), SYMBOL_ASK);
    double bid = SymbolInfoDouble(order.symbol(), SYMBOL_BID);
    if (order.type() == OP_BUY)
    {
      if (bid >= order.tslNext())
      {
        return true;
      }
    }
    if (order.type() == OP_SELL)
    {
      if (ask <= order.tslNext())
      {
        return true;
      }
    }
    return false;
  }

  void moveSL(int tk, double newSl)
  {
    if (OrderSelect(tk, SELECT_BY_TICKET))
    {
      if (!OrderModify(tk, OrderOpenPrice(), newSl, OrderTakeProfit(), 0))
      {
        Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " ", GetLastError());
      } else
      {
        Print(__FUNCTION__, " trailing stop in tk: ", tk);
      }
    }
  }
};
TrailingStop* tsl;


// ------------------------------------------------------------------
int NomNews = 0, Now = 0, MinBefore = 0, MinAfter = 0;
string NewsArr[4][1000];
datetime LastUpd;
string ValStr;
int   Upd            = 86400;      // Period news updates in seconds
bool  Next           = false;      // Draw only the future of news line
bool  Signal         = false;      // Signals on the upcoming news
datetime TimeNews[300];
string Valuta[300],News[300],Vazn[300];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    tsl       = new TrailingStop(GetPointer(mainOrders), byPips);
    //---
   string v1=StringSubstr(_Symbol,0,3); string v2=StringSubstr(_Symbol,3,3);
   ValStr=v1+","+v2;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    //---
    delete tsl;
    Comment("");
   del("NS_");
  }
//+------------------------------------------------------------------+
//| Expert tick function    OnTick()                                 |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string TextDisplay="";

  mainOrders.cleanCloseOrders();
  mainOrders.GetMarketOrders();
   if (TslON) tsl.doTSL();
   /*  Check News   */
   bool trade=true; string nstxt=""; int NewsPWR=0; datetime nextSigTime=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(SourceNews==0)
        {// Investing
         if(CheckInvestingNews(NewsPWR,nextSigTime)){ trade=false; } // news time
        }
      if(SourceNews==1)
        {//DailyFX
         if(CheckDailyFXNews(NewsPWR,nextSigTime)){ trade=false; } // news time
        }
     }
   if(trade)
     {// No News, Trade enabled
      nstxt="No News";
      if(ObjectFind(0,"NS_Label")!=-1){ ObjectDelete(0,"NS_Label"); }

        }else{// waiting news , check news power
      color clrT=LowColor;
      if(NewsPWR>3)
        {
         nstxt= "Waiting Non-farm Payrolls News";
         clrT = HighColor;
           }else{
         if(NewsPWR>2)
           {
            nstxt= "Waiting High News";
            clrT = HighColor;
              }else{
            if(NewsPWR>1)
              {
               nstxt= "Waiting Midle News";
               clrT = MidleColor;
                 }else{
               nstxt= "Waiting Low News";
               clrT = LowColor;
              }
           }
        }
      // Make Text Label
      if(nextSigTime>0){ nstxt=nstxt+" "+TimeToString(nextSigTime,TIME_MINUTES); }
      if(ObjectFind(0,"NS_Label")==-1)
        {
         LabelCreate(StringConcatenate(nstxt),clrT);
        }
      if(ObjectGetInteger(0,"NS_Label",OBJPROP_COLOR)!=clrT)
        {
         ObjectDelete(0,"NS_Label");
         LabelCreate(StringConcatenate(nstxt),clrT);
        }
     }
   nstxt="\n"+nstxt;
/*  End Check News   */

   if(IsTradeAllowed() && trade)
     {// No news and Trade Allowed
      ManageTrade(); // Your trade functions
     }

   TextDisplay=TextDisplay+nstxt;
   Comment(TextDisplay);

   return;
  }
//+------------------------------------------------------------------+
void ManageTrade()
  {
   int tkt=0;
   if(iOpen(_Symbol,PERIOD_H1,1)<iClose(_Symbol,PERIOD_H1,0) && OrdersTotal()<1)
     {
      tkt=OrderSend(Symbol(),OP_BUY,Lots,Ask,2,Ask-100*_Point,Ask+100*_Point,"",0,0,clrBlue);
     }
   if(iOpen(_Symbol,PERIOD_H1,1)>iClose(_Symbol,PERIOD_H1,0) && OrdersTotal()<1)
     {
      tkt=OrderSend(Symbol(),OP_SELL,Lots,Bid,2,Bid+100*_Point,Bid-100*_Point,"",0,0,clrRed);
     }
   return;
  }
//////////////////////////////////////////////////////////////////////////////////
string ReadCBOE()
  {

   string cookie=NULL,headers;
   char post[],result[];     string TXT="";
   int res;
//--- to work with the server, you must add the URL "https://www.google.com/finance"  
//--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"): 
   string google_url="http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
//--- 
   ResetLastError();
//--- download html-pages
   int timeout=5000; //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
//--- error checking
   if(res==-1)
     {
      Print("WebRequest error, err.code  =",GetLastError());
      MessageBox("You must add the address 'http://ec.forexprostools.com/' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
      //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
     }
   else
     {
      //--- successful download
      //PrintFormat("File successfully downloaded, the file size in bytes  =%d.",ArraySize(result)); 
      //--- save the data in the file
      int filehandle=FileOpen("news-log.html",FILE_WRITE|FILE_BIN);
      //--- проверка ошибки 
      if(filehandle!=INVALID_HANDLE)
        {
         //---save the contents of the array result [] in file 
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- close file 
         FileClose(filehandle);

         int filehandle2=FileOpen("news-log.html",FILE_READ|FILE_BIN);
         TXT=FileReadString(filehandle2,ArraySize(result));
         FileClose(filehandle2);
           }else{
         Print("Error in FileOpen. Error code =",GetLastError());
        }
     }

   return(TXT);
  }
//+------------------------------------------------------------------+
datetime TimeNewsFunck(int nomf)
  {
   string s=NewsArr[0][nomf];
   string time=StringConcatenate(StringSubstr(s,0,4),".",StringSubstr(s,5,2),".",StringSubstr(s,8,2)," ",StringSubstr(s,11,2),":",StringSubstr(s,14,4));
   return((datetime)(StringToTime(time) + GMTplus*3600));
  }
//////////////////////////////////////////////////////////////////////////////////
void UpdateNews()
  {
   string TEXT=ReadCBOE();
   int sh = StringFind(TEXT,"pageStartAt>")+12;
   int sh2= StringFind(TEXT,"</tbody>");
   TEXT=StringSubstr(TEXT,sh,sh2-sh);

   sh=0;
   while(!IsStopped())
     {
      sh = StringFind(TEXT,"event_timestamp",sh)+17;
      sh2= StringFind(TEXT,"onclick",sh)-2;
      if(sh<17 || sh2<0)break;
      NewsArr[0][NomNews]=StringSubstr(TEXT,sh,sh2-sh);

      sh = StringFind(TEXT,"flagCur",sh)+10;
      sh2= sh+3;
      if(sh<10 || sh2<3)break;
      NewsArr[1][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(OnlySymbolNews && StringFind(ValStr,NewsArr[1][NomNews])<0)continue;

      sh = StringFind(TEXT,"title",sh)+7;
      sh2= StringFind(TEXT,"Volatility",sh)-1;
      if(sh<7 || sh2<0)break;
      NewsArr[2][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(NewsArr[2][NomNews],"High")>=0 && !HighNews)continue;
      if(StringFind(NewsArr[2][NomNews],"Moderate")>=0 && !MidleNews)continue;
      if(StringFind(NewsArr[2][NomNews],"Low")>=0 && !LowNews)continue;

      sh=StringFind(TEXT,"left event",sh)+12;
      int sh1=StringFind(TEXT,"Speaks",sh);
      sh2=StringFind(TEXT,"<",sh);
      if(sh<12 || sh2<0)break;
      if(sh1<0 || sh1>sh2)NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      else NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh1-sh);

      NomNews++;
      if(NomNews==300)break;
     }
  }
//+------------------------------------------------------------------+
int del(string name) // Спец. ф-ия deinit()
  {
   for(int n=ObjectsTotal()-1; n>=0; n--)
     {
      string Obj_Name=ObjectName(n);
      if(StringFind(Obj_Name,name,0)!=-1)
        {
         ObjectDelete(Obj_Name);
        }
     }
   return 0;                                      // Выход из deinit()
  }
//+------------------------------------------------------------------+
bool CheckInvestingNews(int &pwr,datetime &mintime)
  {

   bool CheckNews=false; pwr=0; int maxPower=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(TimeCurrent()-LastUpd>=Upd){Print("Investing.com News Loading...");UpdateNews();LastUpd=TimeCurrent();Comment("");}
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0;i<NomNews;i++)
           {
            string Name=StringSubstr("NS_"+TimeToStr(TimeNewsFunck(i),TIME_MINUTES)+"_"+NewsArr[1][i]+"_"+NewsArr[3][i],0,63);
            if(NewsArr[3][i]!="")if(ObjectFind(Name)==0)continue;
            if(OnlySymbolNews && StringFind(ValStr,NewsArr[1][i])<0)continue;
            if(TimeNewsFunck(i)<TimeCurrent() && Next)continue;

            color clrf=clrNONE;
            if(HighNews && StringFind(NewsArr[2][i],"High")>=0)clrf=HighColor;
            if(MidleNews && StringFind(NewsArr[2][i],"Moderate")>=0)clrf=MidleColor;
            if(LowNews && StringFind(NewsArr[2][i],"Low")>=0)clrf=LowColor;

            if(clrf==clrNONE)continue;

            if(NewsArr[3][i]!="")
              {
               ObjectCreate(0,Name,OBJ_VLINE,0,TimeNewsFunck(i),0);
               ObjectSet(Name,OBJPROP_COLOR,clrf);
               ObjectSet(Name,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Name,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Name,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      int ii;
      CheckNews=false;
      for(ii=0;ii<NomNews;ii++)
        {
         int power=0;
         if(HighNews && StringFind(NewsArr[2][ii],"High")>=0){ power=3; MinBefore=HighIndentBefore; MinAfter=HighIndentAfter; }
         if(MidleNews && StringFind(NewsArr[2][ii],"Moderate")>=0){ power=2; MinBefore=MidleIndentBefore; MinAfter=MidleIndentAfter; }
         if(LowNews && StringFind(NewsArr[2][ii],"Low")>=0){ power=1; MinBefore=LowIndentBefore; MinAfter=LowIndentAfter; }
         if(NFPNews && StringFind(NewsArr[3][ii],"Nonfarm Payrolls")>=0){ power=4; MinBefore=NFPIndentBefore; MinAfter=NFPIndentAfter; }
         if(power==0)continue;

         if(TimeCurrent()+MinBefore*60>TimeNewsFunck(ii) && TimeCurrent()-MinAfter*60<TimeNewsFunck(ii) && (!OnlySymbolNews || (OnlySymbolNews && StringFind(ValStr,NewsArr[1][ii])>=0)))
           {
            if(power>maxPower){   maxPower=power; mintime=TimeNewsFunck(ii); }
              }else{
            CheckNews=false;
           }
        }
      if(maxPower>0){ CheckNews=true; }
     }
   pwr=maxPower;
   return(CheckNews);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(const string text="Label",const color clr=clrRed)
  {
   long x_distance;  long y_distance; long chart_ID=0;  string name="NS_Label"; int sub_window=0;
   ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER;
   string font="Arial"; int font_size=28; double angle=0.0; ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER;
   bool back=false; bool selection=false;  bool hidden=true;  long z_order=0;
//--- определим размеры окна 
   ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance);
   ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,(int)(x_distance/2.7));
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,(int)(y_distance/1.5));
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateDFX()
  {
   string DF=""; string MF="";
   int DeltaGMT=GMTplus; // 0 -(TimeGMTOffset()/60/60)-DeltaTime;
   int ChasPoyasServera=DeltaGMT;
   datetime NowTimeD1=Time[0];
   datetime LastSunday=NowTimeD1-TimeDayOfWeek(NowTimeD1)*86399;
   int DayFile=TimeDay(LastSunday);
   if(DayFile<10) DF="0"+(string)DayFile;
   else DF=(string)DayFile;
   int MonthFile=TimeMonth(LastSunday);
   if(MonthFile<10) MF="0"+(string)MonthFile;
   else MF=(string)MonthFile;
   int YearFile=TimeYear(LastSunday);
   string DateFile=MF+"-"+DF+"-"+(string)YearFile;
   string FileName= DateFile+"_dfx.csv";
   int handle;

   if(!FileIsExist(FileName))
     {
      string url="http://www.dailyfx.com/files/Calendar-"+DateFile+".csv";
      string cookie=NULL,headers;
      char post[],result[]; string TXT=""; int res; string text="";
      ResetLastError();
      int timeout=5000;
      res=WebRequest("GET",url,cookie,NULL,timeout,post,0,result,headers);
      if(res==-1)
        {
         Print("WebRequest error, err.code  =",GetLastError());
         MessageBox("You must add the address 'http://www.dailyfx.com/' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
        }
      else
        {
         int filehandle=FileOpen(FileName,FILE_WRITE|FILE_BIN);
         if(filehandle!=INVALID_HANDLE)
           {
            FileWriteArray(filehandle,result,0,ArraySize(result));
            FileClose(filehandle);
              }else{
            Print("Error in FileOpen. Error code =",GetLastError());
           }
        }
     }
   handle=FileOpen(FileName,FILE_READ|FILE_CSV);
   string data,time,month,valuta;
   int startStr=0;
   if(handle!=INVALID_HANDLE)
     {
      while(!FileIsEnding(handle))
        {
         int str_size=FileReadInteger(handle,INT_VALUE);
         string str=FileReadString(handle,str_size);
         string value[10];
         int k=StringSplit(str,StringGetCharacter(",",0),value);
         data = value[0];
         time = value[1];
         if(time==""){ continue; }
         month=StringSubstr(data,4,3);
         if(month=="Jan") month="01";
         if(month=="Feb") month="02";
         if(month=="Mar") month="03";
         if(month=="Apr") month="04";
         if(month=="May") month="05";
         if(month=="Jun") month="06";
         if(month=="Jul") month="07";
         if(month=="Aug") month="08";
         if(month=="Sep") month="09";
         if(month=="Oct") month="10";
         if(month=="Nov") month="11";
         if(month=="Dec") month="12";
         TimeNews[startStr]=StrToTime((string)YearFile+"."+month+"."+StringSubstr(data,8,2)+" "+time)+ChasPoyasServera*3600;
         valuta=value[3];
         if(valuta=="eur" ||valuta=="EUR")Valuta[startStr]="EUR";
         if(valuta=="usd" ||valuta=="USD")Valuta[startStr]="USD";
         if(valuta=="jpy" ||valuta=="JPY")Valuta[startStr]="JPY";
         if(valuta=="gbp" ||valuta=="GBP")Valuta[startStr]="GBP";
         if(valuta=="chf" ||valuta=="CHF")Valuta[startStr]="CHF";
         if(valuta=="cad" ||valuta=="CAD")Valuta[startStr]="CAD";
         if(valuta=="aud" ||valuta=="AUD")Valuta[startStr]="AUD";
         if(valuta=="nzd" ||valuta=="NZD")Valuta[startStr]="NZD";
         News[startStr]=value[4];
         News[startStr]=StringSubstr(News[startStr],0,60);
         Vazn[startStr]=value[5];
         if(Vazn[startStr]!="High" && Vazn[startStr]!="HIGH" && Vazn[startStr]!="Medium" && Vazn[startStr]!="MEDIUM" && Vazn[startStr]!="MED" && Vazn[startStr]!="Low" && Vazn[startStr]!="LOW")Vazn[startStr]=FileReadString(handle);
         startStr++;
        }
        }else{
      PrintFormat("Error in FileOpen = %s. Error code= %d",FileName,GetLastError());
     }
   NomNews=startStr-1;
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckDailyFXNews(int &pwr,datetime &mintime)
  {

   bool CheckNews=false; pwr=0; int maxPower=0; color clrf=clrNONE; mintime=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(Time[0]-LastUpd>=Upd){Print("News DailyFX Loading...");UpdateDFX();LastUpd=Time[0];}
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0;i<NomNews;i++)
           {
            string Lname=StringSubstr("NS_"+TimeToStr(TimeNews[i],TIME_MINUTES)+"_"+News[i],0,63);
            if(News[i]!="")if(ObjectFind(0,Lname)==0){  continue; }
            if(TimeNews[i]<TimeCurrent() && Next){ continue; }
            if((Vazn[i]=="High" || Vazn[i]=="HIGH") && HighNews==false){ continue; }
            if((Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED") && MidleNews==false){ continue; }
            if((Vazn[i]=="Low" || Vazn[i]=="LOW") && LowNews==false){ continue; }
            if(Vazn[i]=="High" || Vazn[i]=="HIGH"){ clrf=HighColor; }
            if(Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED"){ clrf=MidleColor; }
            if(Vazn[i]=="Low" || Vazn[i]=="LOW"){ clrf=LowColor; }
            if(News[i]!="" && ObjectFind(0,Lname)<0)
              {
               if(OnlySymbolNews && (Valuta[i]!=StringSubstr(_Symbol,0,3) && Valuta[i]!=StringSubstr(_Symbol,3,3))){ continue; }
               ObjectCreate(0,Lname,OBJ_VLINE,0,TimeNews[i],0);
               ObjectSet(Lname,OBJPROP_COLOR,clrf);
               ObjectSet(Lname,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Lname,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Lname,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      for(int i=0;i<NomNews;i++)
        {
         int power=0;
         if(HighNews && (Vazn[i]=="High" || Vazn[i]=="HIGH")){ power=3; MinBefore=HighIndentBefore; MinAfter=HighIndentAfter; }
         if(MidleNews && (Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED")){ power=2; MinBefore=MidleIndentBefore; MinAfter=MidleIndentAfter; }
         if(LowNews && (Vazn[i]=="Low" || Vazn[i]=="LOW")){ power=1; MinBefore=LowIndentBefore; MinAfter=LowIndentAfter; }
         if(NFPNews && StringFind(News[i],"Non-farm Payrolls")>=0){ power=4; MinBefore=NFPIndentBefore; MinAfter=NFPIndentAfter; }
         if(power==0)continue;

         if(TimeCurrent()+MinBefore*60>TimeNews[i] && TimeCurrent()-MinAfter*60<TimeNews[i] && (!OnlySymbolNews || (OnlySymbolNews && (StringSubstr(Symbol(),0,3)==Valuta[i] || StringSubstr(Symbol(),3,3)==Valuta[i]))))
           {
            if(power>maxPower){ maxPower=power; mintime=TimeNews[i]; }
           }
         else
           {
            CheckNews=false;
           }
        }
      if(maxPower>0){ CheckNews=true; }
     }
   pwr=maxPower;
   return(CheckNews);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+