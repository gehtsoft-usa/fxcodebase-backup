// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71809

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description "The EA recognize the trade open in chart, and initialize a martingale during the trade is in losss. First trade can be open mannually or by another EA, in this case set the input Magic in same value that the EA you wanna to recognize"
#property strict
//////////////////////////////////////////////////////////////////////
input string tGrid               = "== Martingale Setup ==";  // == Martingale Setup ==
input bool   GridON              = true;                // Martingale ON:
input int    GridUser_maxCount   = 5;                   // Max attempts:
input double GridUser_maxLot     = 10;                  // Max lot value:
input double GridUser_multiplier = 1.5;                 // Multiplier:
input int    GridUser_gap        = 30;                  // Gap betwen orders (pips):
input int    magico              = 0;                   // Magic (zero if first order is Mannual):

enum CloseAllMode {
   byMoney,
   byAccountPercent
};
input string       TtpOptions        = "== Close All Options ==";  // == Close All Options ==
input bool         closeAllControlON = true;                       // Close All Control ON:
input CloseAllMode closeBy           = byMoney;                    // Close All Mode:
input double       closeAllMoney     = 100;                        // Close by Money $:
input double       closeAllMoneyLoss = -100;                       // Close by Money Lossing $:
input double       accountPerWin     = 1;                          // Account Percent Win
input double       accountPerLos     = -1;                         // Account Percent Loss

//////////////////////////////////////////////////////////////////////

interface IOrders
{
  public:
   virtual void Add()     = 0;
   virtual void Release() = 0;

   virtual bool AddOrder()    = 0;
   virtual bool DeleteOrder() = 0;
   virtual bool Select()      = 0;
};
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
       double   profit) : _id(id),
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
                        _profit(profit) {}

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

   int            id()         { return _id; }
   string         symbol()     { return _symbol; }
   double         price()      { return _price; }
   double         sl()         { return _sl; }
   double         tp()         { return _tp; }
   double         lot()        { return _lot; }
   int            type()       { return _type; }
   int            magic()      { return _magic; }
   string         comment()    { return _comment; }
   string         strategy()   { return _strategy; }
   datetime       expireTime() { return _expireTime; }
   datetime       signalTime() { return _signalTime; }
   double         profit()     { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit(); return -1; }
   double         tslNext()    { return _tslNext; }
};
class OrdersList
{
   Order* orders[];
   int    _magic;
   bool   _useMagic;

  public:
   
   OrdersList() 
   { 
      // _useMagic = false;
      Print("New OrderList Created");
   }

   OrdersList(int magic, bool useMagic) : _magic(magic), _useMagic(useMagic){Print("New OrderList Created");};
   ~OrdersList() { clearList(); }

   //+------------------------------------------------------------------+
   void setOrderList(int magic, bool useMagic)
   {
      _magic = magic;
      _useMagic = useMagic;
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
   //+------------------------------------------------------------------+
   void GetMarketOrders()
   {
      for (int i = OrdersTotal()-1; i >=0 ; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            // Print(__FUNCTION__," ",i," OrderTicket()"," ",OrderTicket());
				if( _useMagic ==true && OrderMagicNumber()!=_magic ) { continue; }
            if(exist(OrderTicket())==true){ continue;}

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
					.profit(OrderProfit());

   				if(AddOrder(newOrder)) { PrintOrder(i); }
         }
      }
   }
   
   // agrega la última orden si no está en el array
   //+------------------------------------------------------------------+
   bool GetLastMarketOrder()
   {
      for (int i = OrdersTotal()-1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         { 
				if( _useMagic==true && OrderMagicNumber()!=_magic ) { continue; }
            if(exist(OrderTicket())==true){ continue;}

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
					.profit(OrderProfit());

   				if(AddOrder(newOrder)) 
               { 
                  // Print(__FUNCTION__," ","* Nueva Orden De Mercado * ",id(i));
                  // PrintOrder(i);
                  return true;
               }
         }
         return false;
      }
         return false;
   }

   // controlar si el id ya está adentro del array
   //+------------------------------------------------------------------+
   bool exist(int id)
   {
      for (int i = qnt()-1; i >= 0; i--)
      {
         if (id(i) == id) { return true; }
      }
      return false;
   }

   // borra una orden en la posición indicada y acomoda el array
   //+------------------------------------------------------------------+
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
   //+------------------------------------------------------------------+
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
      int lastIndex = ArraySize(orders)-1 ;
      if(lastIndex ==-1) { return NULL; }
      return GetPointer(orders[lastIndex]);
   }
   
   Order* index(int in)
   {
      return GetPointer(orders[in]);
   }

   //+------------------------------------------------------------------+
   bool notOverFlow(int index)
   {
      if (index > ArraySize(orders) - 1) return false;
      if (index < 0) return false;
      if (CheckPointer(orders[index]) == POINTER_INVALID) return false;

      return true;
   }

   // cantidad de ordenes guardadas
   //+------------------------------------------------------------------+
   int qnt()
   {
      return ArraySize(orders);
   }


	// clang-format off 	
	// Metodos para acceder a información de cada trade mediante su index:
	//+------------------------------------------------------------------+
	int      id(int index)             { if (notOverFlow(index)) { return orders[index].id(); } return -1; }
	string   symbol(int index)         { if (notOverFlow(index)) { return orders[index].symbol(); } return ""; }
	double   price(int index)          { if (notOverFlow(index)) { return orders[index].price(); } return -1; }
	double   sl(int index)             { if (notOverFlow(index)) { return orders[index].sl(); } return -1; }
	double   tp(int index)             { if (notOverFlow(index)) { return orders[index].tp(); } return -1; }
	double   lot(int index)            { if (notOverFlow(index)) { return orders[index].lot(); } return -1; }
	int      magic(int index)          { if (notOverFlow(index)) { return orders[index].magic(); } return -1; }
	datetime expire(int index)         { if (notOverFlow(index)) { return orders[index].expireTime(); } return -1; }
	datetime signalTime(int index)     { if (notOverFlow(index)) { return orders[index].signalTime(); } return -1; }
	string   comment(int index)        { if (notOverFlow(index)) { return orders[index].comment(); } return ""; }
	ENUM_ORDER_TYPE type(int index)    { if (notOverFlow(index)) { return orders[index].type(); } return -1; }
	double   profit(int index)         { if (notOverFlow(index)) { return orders[index].profit(); } return -1; }

   // clang-format on

   // comprueba si la orden está cerrada
   //+------------------------------------------------------------------+
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
   //+------------------------------------------------------------------+
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
         double tk;
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

   //+------------------------------------------------------------------+
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
      // clang-format on
   }
   //+------------------------------------------------------------------+
   void PrintList()
   {
      for (int i = 0; i < qnt(); i++)
      {
         PrintOrder(i);
      }
   }
};
OrdersList mainOrders(magico, true);

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

   //+------------------------------------------------------------------+
   void releaseConditions()
   {
      for (int i = 0; i < ArraySize(_conditions); i++)
      {
         delete _conditions[i];
      }
      ArrayFree(_conditions);
   }
   //+------------------------------------------------------------------+
   void AddCondition(iConditions* condition)
   {
      int t = ArraySize(_conditions);
      ArrayResize(_conditions, t + 1);
      _conditions[t] = condition;
   }

   //+------------------------------------------------------------------+
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
class ConditionMaxLot : public iConditions
{
   double _maxLot;
   double _lot;

  public:
   ConditionMaxLot(double MaxLot, double Lot)
   {
      _maxLot = MaxLot;
      _lot    = Lot;
   }
   ~ConditionMaxLot() { ; }
   void lot(double inplot) { _lot = inplot; }

   bool evaluate()
   {
      if (_maxLot >= _lot)
      {
         return true;
      }
      return false;
   }
};
class ConditionOrderCount : public iConditions
{
   OrdersList* _orders;
   int         _maxQnt;

  public:
   ConditionOrderCount(OrdersList* Orders, int MaxQnt)
   {
      _orders = Orders;
      _maxQnt = MaxQnt;
   }
   ~ConditionOrderCount() { ; }

   bool evaluate()
   {
      if (_orders.qnt() < _maxQnt)
      {
         return true;
      }
      return false;
   }
};

interface iActions
{
   bool doAction();
};
class SendNewOrder : public iActions
{
  private:
   Order* newOrder;

  public:
   SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
   {
      string _symbol = setSymbol(symbol);
      double _price  = setPrice(side, price, _symbol);
      int    _type   = SetType(side, price, _symbol);
      if (_type == -1)
      {
         Print(__FUNCTION__, " ", "Imposible to set OrderType");
         return;
      }

      newOrder = new Order();

      newOrder
          .id(OrderTicket())
          .symbol(_symbol)
          .type(_type)
          .price(_price)
          .sl(sl)
          .tp(tp)
          .lot(lots)
          .magic(magic)
          .comment(coment)
          .expireTime(expire)
          .profit(0);
   }

   ~SendNewOrder()
   {
      delete newOrder;
   }

   string setSymbol(string sim)
   {
      if (sim == "")
      {
         return Symbol();
      }
      return sim;
   }

   double setPrice(string side, double pr, string sym)
   {
      if (pr == 0)
      {
         if (side == "buy")
         {
            return SymbolInfoDouble(sym, SYMBOL_ASK);
         }
         if (side == "sell")
         {
            return SymbolInfoDouble(sym, SYMBOL_BID);
         }
      }

      return pr;
   }

   int SetType(string side, double priceClient, string sym)
   {
      double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
      double bid = SymbolInfoDouble(sym, SYMBOL_BID);

      if (priceClient == 0)
      {
         if (side == "buy")
         {
            return (int)OP_BUY;
         }
         if (side == "sell")
         {
            return (int)OP_SELL;
         }
      } else
      {
         if (side == "buy")
         {
            if (priceClient > ask)
            {
               return (int)OP_BUYSTOP;
            }
            if (priceClient < ask)
            {
               return (int)OP_BUYLIMIT;
            }
         }
         if (side == "sell")
         {
            if (priceClient > bid)
            {
               return (int)OP_SELLLIMIT;
            }
            if (priceClient < bid)
            {
               return (int)OP_SELLSTOP;
            }
         }
      }

      return -1;
   }

   bool doAction()
   {
      int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, newOrder.sl(), newOrder.tp(), newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);

      if (tk < 0)
      {
         Print(__FUNCTION__, " ", "Connot Send Order, error: ", GetLastError());
         return false;
      }

      return true;
   }

   Order* lastOrder()
   {
      return GetPointer(newOrder);
   }
};

class Grid
{
   ConcurrentConditions conditionsToOpenNewTrade;
   ConcurrentConditions conditionsToCloseGrid;
   ConditionMatchPrice* cdMatchPrice;
   ConditionOrderCount* cdMaxOrders;
   ConditionMaxLot*     cdMaxLot;
   SendNewOrder*        openTrade;
   OrdersList           gridOrders;
   // ActionCloseOrdersByType* actionCloseGrid;
   string _symbol;
   string _side;
   double _nextPrice;
   double _lastPrice;
   double _gap;
   double _multiplier;
   int    _maxQnt;
   double _maxLot;
   double _initialLot;
   double _nextLot;
   int    _qnt;
   bool   _active;
   int    _magico;

  public:
   Grid(string Symbol, string Side, double LastPrice, double Gap, double Multiplier, int MaxQnt, double MaxLot, double InitialLot, int magic)
   {
      _symbol     = Symbol;
      _side       = Side;
      _lastPrice  = LastPrice;
      _gap        = Gap;
      _nextPrice  = nextPrice(LastPrice);
      _multiplier = Multiplier;
      _maxQnt     = MaxQnt + 1;
      _maxLot     = MaxLot;
      _initialLot = InitialLot;
      _nextLot    = nextLot();
      _magico     = magic;

      Print(_symbol);
      Print(_side);
      Print(_lastPrice);
      Print(_nextPrice);
      Print(_gap);
      Print(_multiplier);
      Print(_maxQnt);
      Print(_maxLot);
      Print(_initialLot);
      Print(_nextLot);

      gridOrders.setOrderList(_magico, true);
      // Print(__FUNCTION__," ","puntero de gridOrders:"," ",GetPointer(gridOrders));
      gridOrders.GetLastMarketOrder();
      // Set Conditions:
      cdMatchPrice = new ConditionMatchPrice(_symbol, _side, _nextPrice, 1);
      cdMaxOrders  = new ConditionOrderCount(GetPointer(gridOrders), _maxQnt);
      cdMaxLot     = new ConditionMaxLot(_maxLot, _nextLot);

      cdMaxLot.lot(_nextLot);
      cdMatchPrice.price(_nextPrice);

      conditionsToOpenNewTrade.AddCondition(cdMatchPrice);
      conditionsToOpenNewTrade.AddCondition(cdMaxOrders);
      conditionsToOpenNewTrade.AddCondition(cdMaxLot);
   }
   ~Grid()
   {
      delete cdMatchPrice;
      delete cdMaxOrders;
      delete cdMaxLot;
      delete openTrade;
   }

   void lastPrice(int inplastPrice) { _lastPrice = inplastPrice; }
   // void active(bool inpactive) { _active = inpactive; }
   bool active(void)
   {
      // si la primer orden está en perdidas:
      if (gridOrders.profit(0) < 0)
      {
         _active = true;
      } else
      {
         _active = false;
      }
      return _active;
   }
   double nextPrice(double inpLastPrice)
   {
      double mPoint = MarketInfo(_symbol, MODE_POINT);

      if (_side == "buy") _nextPrice = inpLastPrice - (_gap * mPoint * 10);
      if (_side == "sell") _nextPrice = inpLastPrice + (_gap * mPoint * 10);

      Print(__FUNCTION__, " ", "_nextPrice", " ", _nextPrice);
      return _nextPrice;
   }
   void   gap(double inpGap) { _gap = inpGap; }
   void   multiplier(double inpmultiplier) { _multiplier = inpmultiplier; }
   void   maxQnt(int inpmaxQnt) { _maxQnt = inpmaxQnt; }
   void   maxLot(double inpmaxLot) { _maxLot = inpmaxLot; }
   double maxLot() { return _maxLot; }
   void   side(string inpside) { _side = inpside; }
   void   symbol(string inpsymbol) { _symbol = inpsymbol; }
   int    qnt()
   {
      return gridOrders.qnt();
      ;
   }
   double nextLot(void)
   {
      // Print(__FUNCTION__, " ", "_nextLot", " ", _nextLot);
      return NormalizeDouble(_initialLot * pow(_multiplier, qnt()), 2);
   };

   void doGrid()
   {
      if (conditionsToOpenNewTrade.EvaluateConditions())
      {
         if (_side == "buy")
         {
            openTrade = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), _magico);
            if (openTrade.doAction())
            {
               // Print("pointer de la ultima orden: ", openTrade.lastOrder());
               if (gridOrders.AddOrder(openTrade.lastOrder()))
                  setNextTrade();
            }
            delete openTrade;
         }

         if (_side == "sell")
         {
            openTrade = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), _magico);
            if (openTrade.doAction())
            {
               // Print("pointer de la ultima orden: ", openTrade.lastOrder());
               if (gridOrders.AddOrder(openTrade.lastOrder()))
                  setNextTrade();
            }
            delete openTrade;
         }
      }
   }

   void setNextTrade()
   {
      nextPrice(gridOrders.last().price());
      Print(__FUNCTION__, " ", "nextPrice: ", " ", _nextPrice);
      cdMaxLot.lot(nextLot());
      Print(__FUNCTION__, " ", "nextLot()", " ", nextLot());
      cdMatchPrice.price(_nextPrice);
   }

   double Lots()
   {
      return nextLot();
   }

   double SL(string side)
   {
      return 0;
   }
   double TP(string side)
   {
      return 0;
   }

   void closeGrid()
   {
      gridOrders.cleanCloseOrders();
      if (qnt() == 0)
      {
         return;
      }

      int attempts = 0;
      while (gridOrders.closeAllInList() != 0 || attempts < 10)
      {
         attempts++;
      }
   }
};
Grid* gridBuy;
Grid* gridSell;

class ActionCloseOrdersByType : public iActions
{
   ENUM_ORDER_TYPE _type;
   string          _symbol;
   int             _magic;
   int             _slippage;
   double          _price;

  public:
   ActionCloseOrdersByType(string side, int magic = 0, string symbol = "", int slippage = 10000)
   {
      if (side == "buy") _type = OP_BUY;
      if (side == "sell") _type = OP_SELL;
      if (symbol == "")
      {
         _symbol = Symbol();
      } else
      {
         _symbol = symbol;
      }
      if (magic != 0)
      {
         _magic = magic;
      }
      if (slippage != 10000)
      {
         _slippage = slippage;
      }
   }
   ~ActionCloseOrdersByType() {}

   void setPrice()
   {
      if (_type == OP_BUY)
      {
         _price = SymbolInfoDouble(_symbol, SYMBOL_BID);
      }
      if (_type == OP_SELL)
      {
         _price = SymbolInfoDouble(_symbol, SYMBOL_ASK);
      }
   }

   bool doAction()
   {
      setPrice();
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic && OrderType() == _type)
         {
            if (!OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE))
            {
               Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
               return false;
            }
         }
      }
      return true;
   }
};
ActionCloseOrdersByType* actionCloseSells;
ActionCloseOrdersByType* actionCloseBuys;

//////////////////////////////////////////////////////////////////////

int OnInit()
{
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   mainOrders.clearList();
   delete actionCloseSells;
   delete actionCloseBuys;
}

void OnTick()
{
   // cerrar todo:
   if (closeAllControlON)
   {
      CloseALlControl();
   }

   mainOrders.GetMarketOrders();
   mainOrders.cleanCloseOrders();
   CheckearOrdernesyGenerarGrids();
   // Ejecutar grid:
   if (GridON == true && CheckPointer(gridSell) != POINTER_INVALID)
   {
      gridSell.doGrid();
      mainOrders.GetMarketOrders();
   }
   if (GridON == true && CheckPointer(gridBuy) != POINTER_INVALID)
   {
      gridBuy.doGrid();
      mainOrders.GetMarketOrders();
   }
}

//////////////////////////////////////////////////////////////////////
double floatingEA()
{
   double profit = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
      {
         profit += OrderProfit();
      }
   }

   return profit;
}

void closeAll(string side)
{
   if (side == "buy")
   {
      actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
      actionCloseBuys.doAction();
      if (GridON && CheckPointer(gridBuy) != POINTER_INVALID)
      {
         gridBuy.closeGrid();
         delete gridBuy;
      }
      delete actionCloseBuys;
   }
   if (side == "sell")
   {
      actionCloseSells = new ActionCloseOrdersByType("sell", magico);
      actionCloseSells.doAction();
      if (GridON && CheckPointer(gridSell) != POINTER_INVALID)
      {
         gridSell.closeGrid();
         delete gridSell;
      }
      delete actionCloseSells;
   }
}

// NOTE: Genera las Nuevas GRIDS:
void CheckearOrdernesyGenerarGrids()
{
   if (mainOrders.qnt() == 1)
   {
      if (mainOrders.last().type() == OP_BUY && CheckPointer(gridBuy) == POINTER_INVALID)
      {
         gridBuy = new Grid(_Symbol, "buy", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
      }
      if (mainOrders.last().type() == OP_SELL && CheckPointer(gridSell) == POINTER_INVALID)
      {
         gridSell = new Grid(_Symbol, "sell", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
      }
   }
   if (mainOrders.qnt() == 0)
   {
      deleteGrid();
   }
}

void deleteGrid()
{
   if (CheckPointer(gridSell) != POINTER_INVALID)
   {
      delete gridSell;
   }
   if (CheckPointer(gridBuy) != POINTER_INVALID)
   {
      delete gridBuy;
   }
}

void CloseALlControl()
{
   switch (closeBy)
   {
      case byMoney:
         if (floatingEA() >= closeAllMoney)
         {
            closeAll("sell");
            closeAll("buy");
         }
         if (floatingEA() < closeAllMoneyLoss)
         {
            closeAll("sell");
            closeAll("buy");
         }
         break;

      case byAccountPercent:
		{
         double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
         double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;

         if (floatingEA() >= moneyByAccountPerWin)
         {
            closeAll("sell");
            closeAll("buy");
         }
         if (floatingEA() < moneyByAccountPerLos)
         {
            closeAll("sell");
            closeAll("buy");
         }
         break;
		}
   }
}