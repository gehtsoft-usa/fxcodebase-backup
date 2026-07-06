// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71838

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
#property strict
// Includes

// ------------------------------------------------------------------
enum ModeLevels { FixPips,
                  byMoney
};
enum TSLMode { byPips,
               byMA
};
enum ModeCalcLots { Money,
                    AccountPercent,
                    FixLots
};
enum CloseAllMode {
   CloseByMoney,
   CloseByAccountPercent
};
// ------------------------------------------------------------------
input string             T0                      = "== Trade Setup ==";        // == Trade Setup ==
input ModeCalcLots       modeCalcLots            = FixLots;                    // Mode to Calc Lots:
input double             userMoney               = 10;                         // Setup Lots by "Money":
input double             userBalancePer          = 0.1;                        // Setup Lots by "Account Percent":
input double             userLots                = 0.01;                       // Setup Lots by "User Lots":
input string             T01                     = "- Take Profit -";          // Setup Hard Take Profit
input ModeLevels         modeTP                  = FixPips;                    // Mode Take Profit:
input int                userTPpips              = 20;                         // Pips TP
input double             userTPmoney             = 15;                         // Money TP
input string             T02                     = "- Stop Loss -";            // Setup hard Stop Loss
input ModeLevels         modeSL                  = FixPips;                    // Mode Stop Loss:
input int                userSLpips              = 20;                         // Pips SL
input double             userSLmoney             = 15;                         // Money SL
input string             TtpOptions              = "== Close All Options ==";  // == Close All Options ==
input bool               closeAllControlON       = false;                      // Close All Control ON:
input CloseAllMode       closeBy                 = CloseByMoney;               // Close All Mode:
input double             closeAllMoney           = 100;                        // Close by Money $:
input double             closeAllMoneyLoss       = -100;                       // Close by Money Lossing $:
input double             accountPerWin           = 1;                          // Account Percent Win
input double             accountPerLos           = -1;                         // Account Percent Loss
input bool               closeAllInOpositeSignal = false;                      // CLose All In Oposite Signal
input string             tTailingStop            = "== TailingStop Setup ==";  // == TailingStop Setup ==
input bool               TslON                   = false;                      // TSL ON:
TSLMode                  userTslMode             = byPips;                     // TSL Mode:
input string             tTslBypips              = "-- TSL By Pips Setup --";  // -- TSL By Pips Setup --
input int                userTslInitialStep      = 1;                          // TSL Initial Step:
input int                userTslStep             = 1;                          // TSL Step:
input int                userTslDistance         = 20;                         // TSL Distance:
input string             tGrid                   = "== Grid Setup ==";         // == Grid Setup ==
input bool               GridON                  = false;                      // Use Grid:
input int                GridUser_maxCount       = 5;                          // Max attempts:
input double             GridUser_maxLot         = 10;                         // Max lot value:
input double             GridUser_multiplier     = 1.5;                        // Multiplier:
input int                GridUser_gap            = 30;                         // Gap betwen orders (pips):
input string             fast_Iema               = "== High MA Setup ==";      // == High MA Setup ==
input int                fast_maPeriod           = 50;                         // Period
int                      fast_maShift            = 0;                          // Ma Shift
input ENUM_MA_METHOD     fast_maMethod           = MODE_EMA;                    // Method
input ENUM_APPLIED_PRICE fast_maAppliedPrice     = PRICE_HIGH;                 // Applied Price
input string             slow_Iema               = "== Low MA Setup ==";       // == Low MA Setup ==
input int                slow_maPeriod           = 50;                         // Period
int                      slow_maShift            = 0;                          // Ma Shift
input ENUM_MA_METHOD     slow_maMethod           = MODE_EMA;                    // Method
input ENUM_APPLIED_PRICE slow_maAppliedPrice     = PRICE_LOW;                  // Applied Price

input string T1                    = "== Timer ==";          // Timer
input string timeStart             = "00:00:00";             // Time Start GMT
input string timeEnd               = "23:59:59";             // Time End GMT
input string TZ                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input int    magico                = 2;                      // Magic Number:

// Gobal Variables
// ------------------------------------------------------------------

interface iIndicators
{
   double calculate(int bufferNumber, int shift);
};
class MovingAverage : public iIndicators
{
   string _symbol;
   int    _tf;

   struct MovingAverageParameters
   {
      int setup0;  //  Period
      int setup1;  //  Ma Shift
      int setup2;  //  Method
      int setup3;  //  Applied Price
   };
   MovingAverageParameters _setup;

  public:
   MovingAverage(string Symbol, int TimeFrame)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
      // setSetup(Period, maShift, Method, AppliedPrice);
   }
   ~MovingAverage() { ; }

   void setSetup(
       int set0,
       int set1,
       int set2,
       int set3)
   {
      _setup.setup0 = set0;
      _setup.setup1 = set1;
      _setup.setup2 = set2;
      _setup.setup3 = set3;
   }

   double calculate(int buffer, int shift)
   {
      return iMA(_symbol, _tf,
                 _setup.setup0,
                 _setup.setup1,
                 _setup.setup2,
                 _setup.setup3,
                 shift);
   }

   double index(int shift)
   {
      return calculate(0, shift);
   }

   double lastValue(int buffer, bool candle = false)
   {
      double value = EMPTY_VALUE;
      int    i     = 0;

      while (value == EMPTY_VALUE || i == 500)
      {
         value = calculate(buffer, i);
         i++;
      }

      if (candle)
      {
         return i;
      }
      return value;
   }

   void printSetup()
   {
      Print("setup0 : ", _setup.setup0);
      Print("setup1 : ", _setup.setup1);
      Print("setup2 : ", _setup.setup2);
      Print("setup3 : ", _setup.setup3);
   }
};
MovingAverage highMA(Symbol(), Period());
MovingAverage lowMA(Symbol(), Period());

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

// GRID
// ------------------------------------------------------------------
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

class ConditionSignalLimiter : public iConditions
{
   string _side;
   string _lastSide;

  public:
   ConditionSignalLimiter(string Side)
   {
      _side = Side;
   }
   ~ConditionSignalLimiter() { ; }

   void lastSide(string lastSignal)
   {
      _lastSide = lastSignal;
   }

   bool evaluate()
   {
      if (_side != _lastSide)
      {
         return true;
      }

      return false;
   }
};
ConditionSignalLimiter* availableToTakeSignalBuy;
ConditionSignalLimiter* availableToTakeSignalSell;

class ConditionGridActive : public iConditions
{
   Grid* _grid;

  public:
   ConditionGridActive(Grid* grid)
   {
      _grid = grid;
   }
   ~ConditionGridActive() { delete _grid; }

   bool evaluate()
   {
      if (CheckPointer(_grid) != POINTER_INVALID)
      {
         if (_grid.active())
         {
            return false;
         }
      }
      return true;
   }
};
ConditionGridActive* gridActiveCondition;

class ConditionsModeOneTrue
{
  protected:
   iConditions* _conditions[];

  public:
   ConditionsModeOneTrue(void) {}
   ~ConditionsModeOneTrue(void) { releaseConditions(); }

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
         if (_conditions[i].evaluate())
         {
            return true;
         }
      }
      return false;
   }
};

interface iLevels
{
   double calculateLevel();
   double pips();
};
class ByFixPips : public iLevels
{
   string _symbol;
   string _side;
   int    _pips;
   string _mode;  // TP SL

  public:
   ByFixPips(string inpSymbol, string inpSide, int inpPips, string inpMode)
   {
      _pips   = inpPips;
      _symbol = inpSymbol;
      _side   = inpSide;
      _mode   = inpMode;
   }
   ~ByFixPips() { ; }
   double pips()
   {
      return _pips;
   }

   double calculateLevel()
   {
      double mPoint   = MarketInfo(_symbol, MODE_POINT);
      double distance = _pips * 10 * mPoint;
      double result   = 0;
      double ask      = SymbolInfoDouble(_symbol, SYMBOL_ASK);
      double bid      = SymbolInfoDouble(_symbol, SYMBOL_BID);

      if (_pips == 0)
      {
         return 0;
      }

      if (_mode == "SL")
      {
         distance *= -1;
      }

      if (_side == "buy")
      {
         return ask + distance;
      }
      if (_side == "sell")
      {
         return bid - distance;
      }
      return -1;
   }
};
class ByMoney : public iLevels
{
   string _symbol;
   string _side;
   int    _pips;
   double _money;
   string _mode;  // TP SL
   double _lot;

  public:
   ByMoney(string Symbol, string Side, double Lot, double Money, string Mode)
   {
      _lot    = Lot;
      _symbol = Symbol;
      _side   = Side;
      _mode   = Mode;
      _money  = Money;
   }
   ~ByMoney() { ; }

   double pips()
   {
      double _tickValue    = MarketInfo(_symbol, MODE_TICKVALUE);
      double _modeCalc     = MarketInfo(_symbol, MODE_PROFITCALCMODE);
      double _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      double _step         = MarketInfo(_symbol, MODE_LOTSTEP);
      double _points       = MarketInfo(_symbol, MODE_POINT);
      double _digits       = MarketInfo(_symbol, MODE_DIGITS);

      //FOREX
      if (_modeCalc == 0)
      {
         // lot = return NormalizeDouble(_money / distance / _tickValue, 2);
         return NormalizeDouble(_money / (_lot * _tickValue), 2);
      }

      //FUTUROS
      if (_modeCalc == 1 && _step != 1.0)
      {
         double c = _contractSize * _step;
         // return NormalizeDouble(_money / (distance * c), 2);
         // lot = _money / (distance * c)
         return NormalizeDouble((_money / c / _lot), 2);
      }

      //FUTUROS SIN DECIMALES
      if (_modeCalc == 1 && _step == 1.0)
      {
         double c = _contractSize * _step;
         // return MathFloor(_money / (distance * c) * 100);
         return MathFloor((_money / c / _lot) / 100);
      }

      return 0;
   }

   double calculateLevel()
   {
      _pips         = (int)pips();
      double mPoint = MarketInfo(_symbol, MODE_POINT);
      // double distance = _pips * 10 * mPoint;
      double distance = _pips * mPoint;
      double result   = 0;
      double ask      = SymbolInfoDouble(_symbol, SYMBOL_ASK);
      double bid      = SymbolInfoDouble(_symbol, SYMBOL_BID);

      if (_pips == 0)
      {
         return 0;
      }
      if (_mode == "SL")
      {
         distance *= -1;
      }
      if (_side == "buy")
      {
         return ask + distance;
      }
      if (_side == "sell")
      {
         return bid - distance;
      }
      return -1;
   }
};
class Levels
{
   iLevels* _level;

  public:
   Levels(iLevels* inpLevel)
   {
      _level = inpLevel;
   }
   ~Levels()
   {
      if (CheckPointer(_level) == 1)
         delete _level;
   }

   double calculateLevel()
   {
      return _level.calculateLevel();
   }
   double pips()
   {
      return _level.pips();
   }
};
Levels* levelTP;
Levels* levelSL;

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

interface iTSL
{
   void   setInitialStep(Order * order);
   void   setNextStep(Order * order);
   double newSL(Order * order);
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
   TrailingStop(OrdersList* ordersList, TSLMode mode)
   {
      _orders = ordersList;

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

//////////////////////////////////////////////////////////////////////

bool CloseCandleMode = true;  // meter en la clase CloseCandle
class LotCalculator
{
   double _tickValue;
   double _modeCalc;
   double _contractSize;
   double _step;
   string _symbol;
   double _points;
   double _digits;

  public:
   LotCalculator(string inpSymbol = "") { setSymbol(inpSymbol); };
   ~LotCalculator() { ; }

   void setSymbol(string sym)
   {
      if (sym == "")
      {
         _symbol = Symbol();
      } else
      {
         _symbol = sym;
      }
      _tickValue    = MarketInfo(_symbol, MODE_TICKVALUE);
      _modeCalc     = MarketInfo(_symbol, MODE_PROFITCALCMODE);
      _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      _step         = MarketInfo(_symbol, MODE_LOTSTEP);
      _points       = MarketInfo(_symbol, MODE_POINT);
      _digits       = MarketInfo(_symbol, MODE_DIGITS);
   }

   double LotsByBalancePercent(double BalancePercent, double Distance)
   {
      double risk = AccountBalance() * BalancePercent / 100;
      return CalculateLots(risk, Distance);
   }

   double LotsByMoney(double Money, double Distance)
   {
      double risk = fabs(Money);
      return CalculateLots(risk, Distance);
   }

   double CalculateLots(double risk, double distance)
   {
      distance *= 10;
      if (distance == 0)
      {
         Print(__FUNCTION__, " ", "Set Distance");
         return 0;
      }

      //FOREX
      if (_modeCalc == 0)
      {
         return NormalizeDouble(risk / distance / _tickValue, 2);
      }

      //FUTUROS
      if (_modeCalc == 1 && _step != 1.0)
      {
         double c = _contractSize * _step;
         return NormalizeDouble(risk / (distance * c), 2);
      }

      //FUTUROS SIN DECIMALES
      if (_modeCalc == 1 && _step == 1.0)
      {
         double c = _contractSize * _step;
         return MathFloor(risk / (distance * c) * 100);
      }

      return 0;
   }
};
LotCalculator* lotProvider;

enum enumDays { sunday,
                monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                EA_OFF };
class Session
{
   int _iniTime;  // second from 00:00 hr of the day
   int _endTime;
   int _dayNumber;

  public:
   // receive time in format 00:00
   Session(string iniTime, string endTime, int dayNumber = 0)
   {
      _iniTime   = secondsFromZeroHour(iniTime);
      _endTime   = secondsFromZeroHour(endTime);
      _dayNumber = dayNumber;
   };

   ~Session() {}

   int iniTime() { return _iniTime; }
   int endTime() { return _endTime; }
   int dayNumber() { return _dayNumber; }

   int secondsFromZeroHour(string time)
   {
      int hh = (int)StringSubstr(time, 0, 2);
      int mm = (int)StringSubstr(time, 3, 2);

      return (hh * 3600) + (mm * 60);
   }
};
class ScheduleController
{
   Session* schedules[];
   int      _actualIndex;
   Session* _actualSession;
   int      _currentDay;

  public:
   ScheduleController()
   {
      setCurrentDay();
   };
   ~ScheduleController()
   {
      ClearShchedules();
   }

   Session* at() { return _actualSession; }

   void setCurrentDay()
   {
      _currentDay = TimeDay(TimeGMT());  // return the day of the month 1-31
   }

   bool isNewDay()
   {
      if (TimeDay(TimeGMT()) != _currentDay)
      {
         setCurrentDay();
         return true;
      }

      return false;
   }

   void setActualSession(int index)
   {
      _actualIndex = index;

      if (index > -1)
      {
         _actualSession = schedules[index];
      }
   }

   int qnt()
   {
      return ArraySize(schedules);
   }

   bool AddSession(string ini, string end, int day = 0)
   {
      Session* sc = new Session(ini, end, day);
      int      t  = qnt();
      if (ArrayResize(schedules, t + 1))
      {
         schedules[t] = sc;
         return true;
      }

      return false;
   }

   bool ClearShchedules()
   {
      for (int i = 0; i < qnt(); i++)
      {
         delete schedules[i];
      }
      ArrayFree(schedules);

      return true;
   }

   bool doSessionControl()  // control day and hours for every session
   {
      Comment("Daily Control - EA OFF");

      int actual = (TimeHour(TimeGMT()) * 3600) + (TimeMinute(TimeGMT()) * 60);

      for (int i = 0; i < qnt(); i++)
      {
         if (schedules[i].dayNumber() == EA_OFF)
         {
            continue;
         }

         if (schedules[i].dayNumber() != 0)
         {
            if (schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT()))
            {
               if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
               {
                  setActualSession(i);
                  Comment("Daily Control - EA ON");
                  return true;
               }
            }
         }

         if (schedules[i].dayNumber() == 0)
         {
            if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
            {
               setActualSession(i);
               Comment("Daily Control - EA ON");
               return true;
            }
         }
      }

      //---
      setActualSession(-1);
      return false;
   }

   void PrintDays()
   {
      for (int i = 0; i < qnt(); i++)
      {
         PrintDay(i);
      }
   }

   void PrintDay(int i)
   {
      Print("Day Nr: ", schedules[i].dayNumber());
      Print("Day Ini Time: ", schedules[i].iniTime());
      Print("Day End Time: ", schedules[i].endTime());
   }
};
ScheduleController sesionControl;

class CNewCandle
{
  private:
   int    velasInicio;
   string m_symbol;
   int    m_tf;

  public:
   CNewCandle();
   CNewCandle(string symbol, int tf) : m_symbol(symbol), m_tf(tf), velasInicio(iBars(symbol, tf)) {}
   ~CNewCandle();

   bool IsNewCandle();
};
CNewCandle::CNewCandle()
{
   // toma los valores del chart actual
   velasInicio = iBars(Symbol(), Period());
   m_symbol    = Symbol();
   m_tf        = Period();
}
CNewCandle::~CNewCandle() {}
bool CNewCandle::IsNewCandle()
{
   int velasActuales = iBars(m_symbol, m_tf);
   if (velasActuales > velasInicio)
   {
      velasInicio = velasActuales;
      return true;
   }

   //---
   return false;
}
CNewCandle* newCandle;

ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;
// ConditionsModeOneTrue    conditionsToCloseBuy;
ConcurrentConditions conditionsToCloseBuy;
// ConditionsModeOneTrue    conditionsToCloseSell;
ConcurrentConditions conditionsToCloseSell;
SendNewOrder*        actionSendOrder;

// NOTE: buy sell conditions
class BUYcondition1 : public iConditions
{
  public:
   bool evaluate()
   {
      // NOTE: condition Buy 1
      double open  = iOpen(Symbol(), Period(), 1);
      double close = iClose(Symbol(), Period(), 1);

      if (open <= highMA.index(1) && close > highMA.index(1))
      {
         return true;
      }

      return false;
   }
};
BUYcondition1* buyCondition1;
class BUYcondition2 : public iConditions
{
  public:
   bool evaluate()
   {
      // NOTE: condition Buy 2
      if (highMA.index(1) > lowMA.index(1))
      {
         return true;
      }
      return false;
   }
};
BUYcondition2* buyCondition2;
class BUYcondition3 : public iConditions
{
  public:
   bool evaluate()
   {
      // NOTE: condition Buy 3
      return false;
   }
};
BUYcondition3* buyCondition3;
class ConditionCountBuys : public iConditions
{
   int _maxBuys;

  public:
   ConditionCountBuys(int maxBuys)
   {
      _maxBuys = maxBuys;
   }
   ~ConditionCountBuys() { ; }

   bool evaluate()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
         {
            if (OrderType() == OP_BUY)
            {
               count += 1;
            }

            if (count == _maxBuys)
            {
               return false;
            }
         }
      }
      return true;
   }
};
ConditionCountBuys* countBuys;

class SELLcondition1 : public iConditions
{
  public:
   bool evaluate()
   {
      // NOTE: condition sell 1
      double open  = iOpen(Symbol(), Period(), 1);
      double close = iClose(Symbol(), Period(), 1);

      if (open >= lowMA.index(1) && close < lowMA.index(1))
      {
         return true;
      }
      return false;
   }
};
SELLcondition1* sellCondition1;
class SELLcondition2 : public iConditions
{
  public:
   bool evaluate()
   {
      // NOTE: condition sell 2
      if (highMA.index(1) < lowMA.index(1))
      {
         return true;
      }
      return false;
   }
};
SELLcondition2* sellCondition2;
class SELLcondition3 : public iConditions
{
  public:
   bool evaluate()
   {
      // NOTE: condition sell 3

      return false;
   }
};
SELLcondition3* sellCondition3;
class ConditionCountSells : public iConditions
{
   int _maxSells;

  public:
   ConditionCountSells(int maxSells)
   {
      _maxSells = maxSells;
   }
   ~ConditionCountSells() { ; }

   bool evaluate()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
         {
            if (OrderType() == OP_SELL)
            {
               count += 1;
            }

            if (count == _maxSells)
            {
               return false;
            }
         }
      }
      return true;
   }
};
ConditionCountSells* countSells;

// NOTE: close Conditions
class ConditionToCloseBuy : public iConditions
{
  public:
   bool evaluate()
   {
      if (closeAllInOpositeSignal)
      {
         return conditionsToSell.EvaluateConditions();
      }
      if (closeAllControlON)
      {
         return CloseALlControl();
      }
      return false;
   }
};
ConditionToCloseBuy* conditionCloseBuy;
class ConditionToCloseSell : public iConditions
{
  public:
   bool evaluate()
   {
      if (closeAllInOpositeSignal)
      {
         return conditionsToBuy.EvaluateConditions();
      }
      if (closeAllControlON)
      {
         return CloseALlControl();
      }
      return false;
   }
};
ConditionToCloseSell* conditionCloseSell;

//////////////////////////////////////////////////////////////////////

int OnInit()
{
   newCandle = new CNewCandle();
   tsl       = new TrailingStop(GetPointer(mainOrders), byPips);

   //--- CONDITIONS TO OPEN TRADES:
   //--- buys:
   conditionsToBuy.AddCondition(buyCondition1 = new BUYcondition1());
   // conditionsToBuy.AddCondition(buyCondition2 = new BUYcondition2());
   // conditionsToBuy.AddCondition(buyCondition3 = new BUYcondition3());
   conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1));
   availableToTakeSignalBuy = new ConditionSignalLimiter("buy");
   // conditionsToBuy.AddCondition(availableToTakeSignalBuy);

   //--- sell:
   conditionsToSell.AddCondition(sellCondition1 = new SELLcondition1());
   // conditionsToSell.AddCondition(sellCondition2 = new SELLcondition2());
   // conditionsToSell.AddCondition(sellCondition3 = new SELLcondition3());
   conditionsToSell.AddCondition(countSells = new ConditionCountSells(1));
   availableToTakeSignalSell = new ConditionSignalLimiter("sell");
   // conditionsToSell.AddCondition(availableToTakeSignalSell);

   //--- CONDITIONS TO CLOSE TRADES:
   conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());
   conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());

   //--- SESSIONS CONTROL:
   sesionControl.AddSession(timeStart, timeEnd);

   // EventSetTimer(1);

   // NOTE: set Indicators if use it
   // Example: indicator.setSetup(set0, set1... setn);
   //--- INDICATORS SETUPS:
   highMA.setSetup(fast_maPeriod, fast_maShift, fast_maMethod, fast_maAppliedPrice);
   lowMA.setSetup(slow_maPeriod, slow_maShift, slow_maMethod, slow_maAppliedPrice);

   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete newCandle;
}

void OnTick()
{
   if (TslON) tsl.doTSL();
   mainOrders.GetMarketOrders();
   mainOrders.cleanCloseOrders();
   CheckearOrdernesyGenerarGrids();

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

   if (!sesionControl.doSessionControl())
   {
      return;
   }

   //--- CANDLE CLOSE:
   if (CloseCandleMode)
      if (!newCandle.IsNewCandle())
      {
         return;
      }

   // ------------------------------------------------------------------
   if (conditionsToCloseBuy.EvaluateConditions())
   {
      closeAll("buy");
   }
   if (conditionsToCloseSell.EvaluateConditions())
   {
      closeAll("sell");
   }

   // ------------------------------------------------------------------
   if (conditionsToBuy.EvaluateConditions())
   {
      actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
      if (actionSendOrder.doAction())
      {
         mainOrders.GetMarketOrders();

         if (GridON == true && CheckPointer(gridBuy) == POINTER_INVALID)
         {
            gridBuy = new Grid(_Symbol, "buy", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
            conditionsToBuy.AddCondition(gridActiveCondition = new ConditionGridActive(gridBuy));
         }

         availableToTakeSignalBuy.lastSide("buy");
         availableToTakeSignalSell.lastSide("buy");
         Notifications(0);
      }

      delete actionSendOrder;
      delete levelTP;
      delete levelSL;
   }
   if (conditionsToSell.EvaluateConditions())
   {
      actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
      if (actionSendOrder.doAction())
      {
         mainOrders.GetMarketOrders();

         if (GridON == true && CheckPointer(gridSell) == POINTER_INVALID)
         {
            Print(__FUNCTION__, " ", "Voy a setear la gridSell");
            gridSell = new Grid(_Symbol, "sell", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
            Print(__FUNCTION__, " ", "pointer de la grid", GetPointer(gridSell));
            conditionsToSell.AddCondition(gridActiveCondition = new ConditionGridActive(gridSell));
         }

         availableToTakeSignalBuy.lastSide("sell");
         availableToTakeSignalSell.lastSide("sell");
         Notifications(1);
      }
      delete actionSendOrder;
      delete levelTP;
      delete levelSL;
   }
}

void OnTimer(void) {}

//////////////////////////////////////////////////////////////////////

double Price(string direction)
{
   double result = 0;
   if (direction == "buy")
   {
      result = Ask;
      return result;
   }

   if (direction == "sell")
   {
      result = Bid;
      return result;
   }

   return -1;
}
double SL(string side)
{
   double result = 0;
   switch (modeSL)
   {
      case FixPips:
         levelSL = new Levels(new ByFixPips(_Symbol, side, userSLpips, "SL"));
         result  = levelSL.calculateLevel();
         break;

      case byMoney:
         levelSL = new Levels(new ByMoney(_Symbol, side, userLots, userSLmoney, "SL"));
         result  = levelSL.calculateLevel();
         break;
   }

   // delete level;
   return result;
}
double TP(string side)
{
   double result = 0;
   switch (modeTP)
   {
      case FixPips:
         levelTP = new Levels(new ByFixPips(_Symbol, side, userTPpips, "TP"));
         result  = levelTP.calculateLevel();
         break;

      case byMoney:
         levelTP = new Levels(new ByMoney(_Symbol, side, userLots, userTPmoney, "TP"));
         result  = levelTP.calculateLevel();
         break;
   }
   // delete level;
   return result;
}
double Lots()
{
   lotProvider = new LotCalculator();
   double lots = -1;
   switch (modeCalcLots)
   {
      case Money:
         lots = lotProvider.LotsByMoney(userMoney, levelSL.pips());
         break;

      case AccountPercent:
         lots = lotProvider.LotsByBalancePercent(userBalancePer, levelSL.pips());
         break;

      case FixLots:
         lots = userLots;
         break;
   }
   delete lotProvider;
   return lots;
}
void Notifications(int type)
{
   string text = "";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

   text += " ";

   if (!notifications)
      return;
   if (desktop_notifications)
      Alert(text);
   if (push_notifications)
      SendNotification(text);
   if (email_notifications)
      SendMail("MetaTrader Notification", text);
}
string GetTimeFrame(int lPeriod)
{
   switch (lPeriod)
   {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
   }
   return IntegerToString(lPeriod);
}

int Distancia(double precioA, double precioB, string par, string mode = "pips")
{
   double mPoint = MarketInfo(par, MODE_POINT);
   double dist   = fabs(precioA - precioB);
   if (mode == "points") return (int)(dist / mPoint);
   if (mode == "pips") return (int)((dist / mPoint) / 10);
   return 0;
}

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

// clang-format off
bool CloseALlControl()
{
   switch (closeBy)
   {
      case CloseByMoney:
         if (floatingEA() >= closeAllMoney) { return true; }
         if (floatingEA() < closeAllMoneyLoss) { return true; }
         break;

      case CloseByAccountPercent: 
		{
         double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
         double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;

         if (floatingEA() >= moneyByAccountPerWin) { return true; }
         if (floatingEA() < moneyByAccountPerLos) { return true; }
         break;
      }
   }
	return false;
}
// clang-format on

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
