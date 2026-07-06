// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70958
//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright c 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright c 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
// Based on Ngapak Boyz, https://www.facebook.com/djong.liongfoi

#define NEWS_FILTER
#define DAILY_LIMITS
#define CLOSE_ALL_ON
#define BREAKEVEN_ON
#define TRAILING_STOP_ON


// NOTE: enums
// ------------------------------------------------------------------
enum TSLMode {
  byPips,  // By Pips
  byMA     // By Moving Average
};
enum CloseAllMode {
  CloseByMoney,           // by Money
  CloseByAccountPercent,  // by Account Percent
  CloseByPips             // By Pips
};

// ------------------------------------------------------------------

extern string EA_Name        = "EA HOKKYDJONG";
extern string Use_TradeAgain = "If => TRUE,EA will trade again,If => FALSE => EA will Off";
extern bool   TradeAgain     = TRUE;
extern string Use_Loop       = "Example = 10,EA will trader for 10 Laps";
extern int    Loop           = 10000;
int           Gi_108;
extern int    StartTrade    = 0;
extern int    EndTrade      = 24;
extern string Use_DbLots    = "If = 1-> Use Multiplier Lot, If = 2-> Use Fixed Lot";
extern int    DbLots        = 1;
extern double Lots          = 0.01;
extern double SL            = 0.0;
extern double TP            = 4.0;
extern double Distance      = 3.0;
extern double Multiplier    = 1.6;
extern int    MaxLevel      = 20;
double        Gd_176        = 3.0;
extern double LotsDecimal   = 2.0;
extern int    MagicNumber   = 163991;
extern string EA_Comment    = "ea_hokkydjong";
double        Gd_unused_204 = 0.0;
double        G_price_212;
double        G_price_220;
double        G_bid_228;
double        G_ask_236;
double        Gd_244;
double        Gd_252;
bool          Gi_260;
datetime      G_time_264 = 0;
int           Gi_268     = 0;
double        Gd_272;
int           G_pos_280 = 0;
int           Gi_284;
double        Gd_288 = 0.0;
bool          Gi_296 = FALSE;
bool          Gi_300 = FALSE;
bool          Gi_304 = FALSE;
int           Gi_308;
bool          Gi_312 = FALSE;
double        Gd_316;
int           Gi_324 = 65535;
int           Gi_328 = 65535;
int           Gi_332 = 16776960;
double        Gd_336;
extern double MoneyPerLot = 1.7;
int     magico      = MagicNumber;

#ifdef NEWS_FILTER
input string TNewsFilter     = "== News ==";  // 覧覧覧覧覧覧
input bool   newsOn          = false;         // News Filter On:
int input    Turn_OFF_Before = 30;            // Turn OFF before (min.)
int input    Turn_ON_After   = 30;            // Turn ON after (min.)

enum SourceNews { Manual,
                  Auto,
                  None };

SourceNews News_Fuente = Auto;  // News Source:

int          AfterNewsStop  = 5;                                  // Indent after News, minuts
int          BeforeNewsStop = 5;                                  // Indent before News, minut
input bool   NewsLight      = false;                              // Enable light news
input bool   NewsMedium     = false;                              // Enable medium news
input bool   NewsHard       = true;                               // Enable hard news
input int    offset         = 0;                                  // Your Time Zone, GMT (for news)
input string NewsSymb       = "USD,EUR,GBP,CHF,CAD,AUD,NZD,JPY";  // Currency to display the news (empty - only the current currencies)
input bool   DrawLines      = true;                               // Draw lines on the chart
input bool   Next           = false;                              // Draw only the future of news line
bool         Signal         = true;                               // Signals on the upcoming news

color highc   = clrRed;      // Colour important news
color mediumc = clrOrange;   // Colour medium news
color lowc    = clrSkyBlue;  // The color of weak news
int   Style   = 2;           // Line style
int   Upd     = 86400;       // Period news updates in seconds

bool Vhigh     = false;
bool Vmedium   = false;
bool Vlow      = false;
int  MinBefore = 10;  // MINUTOS DE AVISO ANTES DE UNA NOTICIA
int  MinAfter  = 10;  // MINUTOS DE AVISO DESPUES DE UNA NOTICIA

int      NomNews = 0;
string   NewsArr[4][1000];
int      Now = 0;
datetime LastUpd;
string   str1;

#endif

#ifdef DAILY_LIMITS
enum DayLimitsMode {
  LimitsByAmount,         // by Amount
  LimitsByAccountPercent  // by Account %
};
input string        Tlimits            = "== Daily Limits Setup ==";  // 覧覧覧覧覧覧
input bool          uDailyProfitOn     = false;                       // Control Daily Profit On:
input DayLimitsMode limitProfitMode    = LimitsByAmount;              // Mode to control daily profit:
input double        uDayLimitProfit    = 2000;                        // Max Daily Profit ($ or %):
input bool          uDailyLossOn       = false;                       // Control Daily Loss On:
input DayLimitsMode limitLossMode      = LimitsByAmount;              // Mode to control daily loss:
input double        uDayLimitLoss      = -1000;                       // Max Daily Loss ($ or %):
input bool          uConsiderFloatting = false;                       // Consider Floating:
#endif

#ifdef CLOSE_ALL_ON
input string       TtpOptions              = "== Close All Options ==";  // 覧覧覧覧覧覧
input bool         closeAllControlON       = false;                      // Close All Control On:
input CloseAllMode closeBy                 = CloseByMoney;               // Close All Mode:
input double       closeAllMoney           = 100;                        // Close by Money $:
input double       closeAllMoneyLoss       = -100;                       // Close by Money Lossing $:
input double       accountPerWin           = 1;                          // Account Percent Win:
input double       accountPerLos           = -1;                         // Account Percent Loss:
input double       closeByPipsWin          = 10;                         // Close Pips Win:
input double       closeByPipsLoss         = 10;                         // Close Pips Loss:
#endif

#ifdef BREAKEVEN_ON
input string Tbk         = "== Breakeven Setup ==";  // 覧覧覧覧覧覧
input bool   breakevenOn = false;                    // Breakeven On:
input double userBkvPips = 3;                        // Breakeven Pips
#endif

#ifdef TRAILING_STOP_ON
input string tTailingStop       = "== TrailingStop Setup ==";  // 覧覧覧覧覧覧
input bool   TslON              = false;                       // TSL ON:
TSLMode      userTslMode        = byPips;                      // TSL Mode:
input int    userTslInitialStep = 1;                           // TSL Initial Step:
input int    userTslStep        = 1;                           // TSL Step:
input int    userTslDistance    = 20;                          // TSL Distance:
#endif

bool   filterMagicsOn  = true;                    // Use magic number filter?

// ------------------------------------------------------------------

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
   double         profit()           { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit(); return -1; }
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

   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

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

   // recorrer las ordenes de mercado y agregar las que no est駭 en el array
   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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

   // agrega la 伃tima orden si no est・en el array
   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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

   // controlar si el id ya est・adentro del array
   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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

   // borra una orden en la posici indicada y acomoda el array
   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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

   // devuelve el puntero a la 伃tima orden
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

   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
   bool notOverFlow(int index)
   {
      if (index > ArraySize(orders) - 1) return false;
      if (index < 0) return false;
      if (CheckPointer(orders[index]) == POINTER_INVALID) return false;

      return true;
   }

   // cantidad de ordenes guardadas
   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
   int qnt()
   {
      return ArraySize(orders);
   }

   // clang-format off
   // Metodos para acceder a informaci de cada trade mediante su index:
   // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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

  // comprueba si la orden est・cerrada
  // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
  // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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

  // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
  // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  void PrintList()
  {
    for (int i = 0; i < qnt(); i++)
    {
      PrintOrder(i);
    }
  }
};
OrdersList mainOrders(filterMagicsOn, (string)magico, true, _Symbol);

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

  // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  void releaseConditions()
  {
    for (int i = 0; i < ArraySize(_conditions); i++)
    {
      delete _conditions[i];
    }
    ArrayFree(_conditions);
  }
  // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  void AddCondition(iConditions* condition)
  {
    int t = ArraySize(_conditions);
    ArrayResize(_conditions, t + 1);
    _conditions[t] = condition;
  }

  // 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
MoveSL* breackevenAction;

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

class DailyProfitCondition : public iConditions
{
  int           _magic;
  double        _limit;
  bool          _considerOpen;  // Considera el flotante profit flotante
  string        _mode;          // loss or profit
  DayLimitsMode _limitMode;     // Amount or AccountPer
 public:
  DailyProfitCondition(double limit, int mag, bool considerOpen, string mode, DayLimitsMode limitMode) : _limit(limit), _magic(mag), _considerOpen(considerOpen), _mode(mode), _limitMode(limitMode) { ; }
  ~DailyProfitCondition() { ; }

  bool evaluate()
  {
    if (_mode == "profit")
    {
      if (TodayProfit() >= Limit())
      {
        Print("DAILY PROFIT REACHED: ", TodayProfit());
        return true;
      }
    }
    if (_mode == "loss")
    {
      if (TodayProfit() <= Limit())
      {
        Print("DAILY LOSS REACHED: ", TodayProfit());
        return true;
      }
    }
    return false;
  }

  double Limit()
  {
    if (_limitMode == LimitsByAmount)
    {
      return _limit;
    }
    if (_limitMode == LimitsByAccountPercent)
    {
      return _limit / 100 * AccountInfoDouble(ACCOUNT_BALANCE);
    }
    return 0;
  }

  double TodayProfit()
  {
    datetime iniDay = iTime(NULL, PERIOD_D1, 0);

    double profit = 0;
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
    {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
      {
        if (OrderCloseTime() >= iniDay)
        {
          profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
      }
    }

    if (_considerOpen)
    {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
        {
          profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
      }
    }

    return profit;
  }
};
DailyProfitCondition dailyProfitCondition(uDayLimitProfit, magico, uConsiderFloatting, "profit", limitProfitMode);
DailyProfitCondition dailyLossCondition(uDayLimitLoss, magico, uConsiderFloatting, "loss", limitLossMode);


// NOTE: close Conditions
class ConditionToCloseBuy : public iConditions
{
 public:
  bool evaluate()
  {
    // if (closeAllInOpositeSignal)
    // {
    //   return sellCondition1.evaluate() && sellCondition2.evaluate();
    // }
    if (closeAllControlON)
    {
      return CloseAllControl();
    }

#ifdef DAILY_LIMITS
    if (uDailyProfitOn)
    {
      if (dailyProfitCondition.evaluate()) return true;
    }
    if (uDailyLossOn)
    {
      if (dailyLossCondition.evaluate()) return true;
    }
#endif

    return false;
  }
};
ConditionToCloseBuy* conditionCloseBuy;

class ConditionToCloseSell : public iConditions
{
 public:
  bool evaluate()
  {
    // if (closeAllInOpositeSignal)
    // {
      // return buyCondition1.evaluate() && buyCondition2.evaluate();
    // }
    if (closeAllControlON)
    {
      return CloseAllControl();
    }

#ifdef DAILY_LIMITS
    if (uDailyProfitOn)
    {
      if (dailyProfitCondition.evaluate()) return true;
    }
    if (uDailyLossOn)
    {
      if (dailyLossCondition.evaluate()) return true;
    }
#endif

    return false;
  }
};
ConditionToCloseSell* conditionCloseSell;

class BreackevenCondition : public iConditions
{
  Order* _order;

 public:
  void setOrder(Order* or)
  {
    _order = or ;
  }

 // TODO: bk condition
  bool evaluate()
  {
    // si el precio actual coindide con el momento de hacer bk ret true
    double mPoints = MarketInfo(_order.symbol(), MODE_POINT);
    double ask     = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
    double bid     = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);
    double dist    = userBkvPips * mPoints * 10;

    if (_order.type() == OP_BUY)
    {
      if (bid >= _order.price() + dist)
      {
        return true;
      }
    }
    if (_order.type() == OP_SELL)
    {
      if (ask <= _order.price() - dist)
      {
        return true;
      }
    }

    return false;
  }
};
BreackevenCondition* breackevenCondition;

ConcurrentConditions conditionsToCloseBuy;
ConcurrentConditions conditionsToCloseSell;
ConcurrentConditions conditionsToBreackeven;


// ------------------------------------------------------------------

// NOTE: init
int init()
{
  if (Digits == 3 || Digits == 5)
    Gd_316 = 10.0 * Point;
  else
    Gd_316 = Point;


  //--- CONDITIONS TO CLOSE TRADES:
  conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());
  conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());

  //--- CONDITIONS TO BREAKEVEN:
  conditionsToBreackeven.AddCondition(breackevenCondition = new BreackevenCondition());
	tsl = new TrailingStop(GetPointer(mainOrders), byPips);


#ifdef NEWS_FILTER
  if (StringLen(NewsSymb) > 1)
    str1 = NewsSymb;
  else
    str1 = Symbol();

  Vhigh   = NewsHard;
  Vmedium = NewsMedium;
  Vlow    = NewsLight;

  MinBefore = BeforeNewsStop;
  MinAfter  = AfterNewsStop;

  LastUpd = 0;
#endif

return 0;
}

int deinit()
{
  ObjectsDeleteAll();
  return (0);
}

// NOTE: tick
int start()
{
#ifdef NEWS_FILTER
  if (newsOn)
  {
    News_Automatic();
    if (ControlNewsTime())
    {
      return 0;
    }
  }
#endif

	mainOrders.cleanCloseOrders();
	mainOrders.GetMarketOrders();

    if (breakevenOn) doBreackevenAction();
    if (TslON) tsl.doTSL();
    if (conditionsToCloseBuy.EvaluateConditions()) closeAll("buy");
    if (conditionsToCloseSell.EvaluateConditions()) closeAll("sell");

	#ifdef DAILY_LIMITS
  if (uDailyProfitOn)
  {
    if (dailyProfitCondition.evaluate()) return 0;
  }
  if (uDailyLossOn)
  {
    if (dailyLossCondition.evaluate()) return 0;
  }
#endif


  double order_lots_0;
  double order_lots_8;
  double iclose_16;
  double iclose_24;
  double Ld_32;
  f0_8();
  f0_9();
  f0_0();

  if (f0_10())
  {
    if (G_time_264 == Time[0]) return (0);
    G_time_264 = Time[0];
    Gi_284     = f0_12();
    if (Gi_284 == 0) Gi_260 = FALSE;
    for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--)
    {
      if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
        if (OrderType() == OP_BUY)
        {
          Gi_300       = TRUE;
          Gi_304       = FALSE;
          order_lots_0 = OrderLots();
          break;
        }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
        if (OrderType() == OP_SELL)
        {
          Gi_300       = FALSE;
          Gi_304       = TRUE;
          order_lots_8 = OrderLots();
          break;
        }
      }
    }
    if (Gi_284 > 0 && Gi_284 <= MaxLevel)
    {
      RefreshRates();
      Gd_244 = f0_11();
      Gd_252 = f0_3();
      if (Gi_300 && Gd_244 - Ask >= Distance * Gd_316) Gi_296 = TRUE;
      if (Gi_304 && Bid - Gd_252 >= Distance * Gd_316) Gi_296 = TRUE;
    }
    if (Gi_284 < 1)
    {
      Gi_304 = FALSE;
      Gi_300 = FALSE;
      Gi_296 = TRUE;
    }
    if (Gi_296)
    {
      Gd_244 = f0_11();
      Gd_252 = f0_3();
      if (Gi_304)
      {
        Gd_272 = f0_4(OP_SELL);
        Gi_268 = Gi_284;
        if (Gd_272 > 0.0)
        {
          RefreshRates();
          Gi_308 = f0_5(1, Gd_272, Bid, Gd_176, Ask, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
          if (Gi_308 < 0)
          {
            Print("Error: ", GetLastError());
            return (0);
          }
          Gd_252 = f0_3();
          Gi_296 = FALSE;
          Gi_312 = TRUE;
        }
      } else
      {
        if (Gi_300)
        {
          Gd_272 = f0_4(OP_BUY);
          Gi_268 = Gi_284;
          if (Gd_272 > 0.0)
          {
            Gi_308 = f0_5(0, Gd_272, Ask, Gd_176, Bid, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
            if (Gi_308 < 0)
            {
              Print("Error: ", GetLastError());
              return (0);
            }
            Gd_244 = f0_11();
            Gi_296 = FALSE;
            Gi_312 = TRUE;
          }
        }
      }
    }
    if (Hour() >= StartTrade && Hour() < EndTrade)
    {
      if (Gi_108 < Loop && TradeAgain)
      {
        if (Gi_296 && Gi_284 < 1)
        {
          iclose_16 = iClose(Symbol(), 0, 2);
          iclose_24 = iClose(Symbol(), 0, 1);
          G_bid_228 = Bid;
          G_ask_236 = Ask;
          if ((!Gi_304) && (!Gi_300))
          {
            Gi_268 = Gi_284;
            if (iclose_16 > iclose_24)
            {
              Gd_272 = f0_4(OP_SELL);
              if (Gd_272 > 0.0)
              {
                Gi_308 = f0_5(1, Gd_272, G_bid_228, Gd_176, G_bid_228, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
                Gi_108++;
                if (Gi_308 < 0)
                {
                  Print(Gd_272, "Error: ", GetLastError());
                  return (0);
                }
                Gd_244 = f0_11();
                Gi_312 = TRUE;
              }
            } else
            {
              Gd_272 = f0_4(OP_BUY);
              if (Gd_272 > 0.0)
              {
                Gi_308 = f0_5(0, Gd_272, G_ask_236, Gd_176, G_ask_236, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
                Gi_108++;
                if (Gi_308 < 0)
                {
                  Print(Gd_272, "Error: ", GetLastError());
                  return (0);
                }
                Gd_252 = f0_3();
                Gi_312 = TRUE;
              }
            }
          }
        }
      }
    }
    Gi_284      = f0_12();
    G_price_220 = 0;
    Ld_32       = 0;
    for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--)
    {
      if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
        if (OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
          G_price_220 += OrderOpenPrice() * OrderLots();
          Ld_32 += OrderLots();
        }
      }
    }
    if (Gi_284 > 0) G_price_220 = NormalizeDouble(G_price_220 / Ld_32, Digits);
    if (Gi_312)
    {
      for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--)
      {
        if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
          if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
          if (OrderType() == OP_BUY)
          {
            G_price_212 = G_price_220 + TP * Gd_316;
            Gd_288      = G_price_220 - SL * Gd_316;
            Gi_260      = TRUE;
          }
        }
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
          if (OrderType() == OP_SELL)
          {
            G_price_212 = G_price_220 - TP * Gd_316;
            Gd_288      = G_price_220 + SL * Gd_316;
            Gi_260      = TRUE;
          }
        }
      }
    }
    if (!Gi_312) return (0);
    if (Gi_260 != TRUE) return (0);
    for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--)
    {
      if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        if (OrderModify(OrderTicket(), G_price_220, OrderStopLoss(), G_price_212, 0, White))
          Gi_312 = FALSE;
    }
  }
  return (0);
}

double f0_4(int A_cmd_0)
{
  double lots_4;
  int    datetime_12;
  switch (DbLots)
  {
    case 0:
      lots_4 = Lots;
      break;
    case 1:
      lots_4 = NormalizeDouble(Lots * MathPow(Multiplier, Gi_268), LotsDecimal);
      break;
    case 2:
      datetime_12 = 0;
      lots_4      = Lots;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--)
      {
        if (OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY))
        {
          if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
          {
            if (datetime_12 < OrderCloseTime())
            {
              datetime_12 = OrderCloseTime();
              if (OrderProfit() < 0.0)
              {
                lots_4 = NormalizeDouble(OrderLots() * Multiplier, LotsDecimal);
                continue;
              }
              lots_4 = Lots;
            }
          }
        } else
          return (-3);
      }
  }
  if (AccountFreeMarginCheck(Symbol(), A_cmd_0, lots_4) <= 0.0) return (-1);
  if (GetLastError() == 134 /* NOT_ENOUGH_MONEY */) return (-2);
  return (lots_4);
}

int f0_12()
{
  int count_0 = 0;
  for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--)
  {
    if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
  }
  return (count_0);
}

int f0_5(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_unused_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56)
{
  int ticket_60 = 0;
  int error_64  = 0;
  int count_68  = 0;
  int Li_72     = 100;
  switch (Ai_0)
  {
    case 2:
      for (count_68 = 0; count_68 < Li_72; count_68++)
      {
        ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, SL), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                              A_color_56);
        error_64  = GetLastError();
        if (error_64 == 0 /* NO_ERROR */) break;
        if (!((error_64 == 4 /* SERVER_BUSY */ || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */))) break;
        Sleep(1000);
      }
      break;
    case 4:
      for (count_68 = 0; count_68 < Li_72; count_68++)
      {
        ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, SL), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                              A_color_56);
        error_64  = GetLastError();
        if (error_64 == 0 /* NO_ERROR */) break;
        if (!((error_64 == 4 /* SERVER_BUSY */ || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */))) break;
        Sleep(5000);
      }
      break;
    case 0:
      for (count_68 = 0; count_68 < Li_72; count_68++)
      {
        RefreshRates();
        ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_14(Bid, SL), f0_1(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
        error_64  = GetLastError();
        if (error_64 == 0 /* NO_ERROR */) break;
        if (!((error_64 == 4 /* SERVER_BUSY */ || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */))) break;
        Sleep(5000);
      }
      break;
    case 3:
      for (count_68 = 0; count_68 < Li_72; count_68++)
      {
        ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_7(Ad_24, SL), f0_2(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                              A_color_56);
        error_64  = GetLastError();
        if (error_64 == 0 /* NO_ERROR */) break;
        if (!((error_64 == 4 /* SERVER_BUSY */ || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */))) break;
        Sleep(5000);
      }
      break;
    case 5:
      for (count_68 = 0; count_68 < Li_72; count_68++)
      {
        ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_7(Ad_24, SL), f0_2(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                              A_color_56);
        error_64  = GetLastError();
        if (error_64 == 0 /* NO_ERROR */) break;
        if (!((error_64 == 4 /* SERVER_BUSY */ || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */))) break;
        Sleep(5000);
      }
      break;
    case 1:
      for (count_68 = 0; count_68 < Li_72; count_68++)
      {
        ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_7(Ask, SL), f0_2(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
        error_64  = GetLastError();
        if (error_64 == 0 /* NO_ERROR */) break;
        if (!((error_64 == 4 /* SERVER_BUSY */ || error_64 == 137 /* BROKER_BUSY */ || error_64 == 146 /* TRADE_CONTEXT_BUSY */ || error_64 == 136 /* OFF_QUOTES */))) break;
        Sleep(5000);
      }
  }
  return (ticket_60);
}

double f0_14(double Ad_0, int Ai_8)
{
  if (Ai_8 == 0) return (0);
  return (Ad_0 - Ai_8 * Gd_316);
}

double f0_7(double Ad_0, int Ai_8)
{
  if (Ai_8 == 0) return (0);
  return (Ad_0 + Ai_8 * Gd_316);
}

double f0_1(double Ad_0, int Ai_8)
{
  if (Ai_8 == 0) return (0);
  return (Ad_0 + Ai_8 * Gd_316);
}

double f0_2(double Ad_0, int Ai_8)
{
  if (Ai_8 == 0) return (0);
  return (Ad_0 - Ai_8 * Gd_316);
}

double f0_11()
{
  double order_open_price_0;
  int    ticket_8;
  double Ld_unused_12 = 0;
  int    ticket_20    = 0;
  for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
  {
    if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY)
    {
      ticket_8 = OrderTicket();
      if (ticket_8 > ticket_20)
      {
        order_open_price_0 = OrderOpenPrice();
        Ld_unused_12       = order_open_price_0;
        ticket_20          = ticket_8;
      }
    }
  }
  return (order_open_price_0);
}

double f0_3()
{
  double order_open_price_0;
  int    ticket_8;
  double Ld_unused_12 = 0;
  int    ticket_20    = 0;
  for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
  {
    if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL)
    {
      ticket_8 = OrderTicket();
      if (ticket_8 > ticket_20)
      {
        order_open_price_0 = OrderOpenPrice();
        Ld_unused_12       = order_open_price_0;
        ticket_20          = ticket_8;
      }
    }
  }
  return (order_open_price_0);
}

void f0_0()
{
  if (iClose(Symbol(), PERIOD_H1, 0) > iClose(Symbol(), PERIOD_H1, 2))
  {
    if (iClose(Symbol(), PERIOD_H1, 0) < iClose(Symbol(), PERIOD_H1, 2))
    {
      if (iClose(Symbol(), PERIOD_H1, 0) > iClose(Symbol(), PERIOD_H1, 1))
      {
        if (iClose(Symbol(), PERIOD_H1, 0) < iClose(Symbol(), PERIOD_H1, 1))
        {
          if (iOpen(Symbol(), 0, 0) > iOpen(Symbol(), 0, 1))
          {
            if (iOpen(Symbol(), 0, 0) < iOpen(Symbol(), 0, 1))
            {
              if (iClose(Symbol(), 0, 0) > iClose(Symbol(), 0, 1))
              {
                if (iClose(Symbol(), 0, 0) >= iClose(Symbol(), 0, 1))
                {
                }
              }
            }
          }
        }
      }
    }
  }
}

double f0_13()
{
  Gd_336          = 0;
  double Ld_ret_0 = 0;
  for (int pos_8 = 0; pos_8 < OrdersHistoryTotal(); pos_8++)
  {
    if (OrderSelect(pos_8, SELECT_BY_POS, MODE_HISTORY))
      if (OrderType() == OP_BUY && 1) Gd_336 += OrderLots();
  }
  Ld_ret_0 = Gd_336 * MoneyPerLot;
  return (Ld_ret_0);
}

void f0_8()
{
  ObjectCreate("Original", OBJ_LABEL, 0, 0, 0);
  ObjectSetText("Original", " ", 10, "Arial Bold", Red);
  ObjectSet("Original", OBJPROP_CORNER, 2);
  ObjectSet("Original", OBJPROP_XDISTANCE, 200);
  ObjectSet("Original", OBJPROP_YDISTANCE, 10);
}

void f0_9()
{
  color color_0;
  int   Li_4 = 65280;
  if (AccountEquity() - AccountBalance() < 0.0) Li_4 = 255;
  if (Seconds() >= 0 && Seconds() < 10) color_0 = Red;
  if (Seconds() >= 10 && Seconds() < 20) color_0 = Violet;
  if (Seconds() >= 20 && Seconds() < 30) color_0 = Orange;
  if (Seconds() >= 30 && Seconds() < 40) color_0 = Blue;
  if (Seconds() >= 40 && Seconds() < 50) color_0 = Yellow;
  if (Seconds() >= 50 && Seconds() <= 59) color_0 = Aqua;
  string Ls_8 = "-------------------------------------------";
  f0_6("L01", "Arial", 9, 10, 10, Gi_328, 1, Ls_8);
  f0_6("L02", "Verdana", 15, 10, 25, color_0, 1, "EA HOKKYDJONG");
  f0_6("L0i", "Mistral", 12, 10, 45, Gi_324, 1, "Price Action Scalping Style");
  f0_6("L03", "Arial", 9, 10, 60, Gi_328, 1, Ls_8);
  f0_6("L04", "Arial", 9, 10, 75, Gi_332, 1, ">> Account Company : " + AccountCompany());
  f0_6("L05", "Arial", 9, 10, 90, Gi_332, 1, ">> Name Server  : " + AccountServer());
  f0_6("L06", "Arial", 9, 10, 105, Gi_332, 1, ">> Account Name  : " + AccountName());
  f0_6("L07", "Arial", 9, 10, 120, Gi_332, 1, ">> Name Number  : " + AccountNumber());
  f0_6("L08", "Arial", 9, 10, 135, Gi_332, 1, ">> Account Leverage  : 1 " + AccountLeverage());
  f0_6("L09", "Arial", 9, 10, 150, Gi_332, 1, ">> Time Server  : " + TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS));
  f0_6("L10", "Arial", 9, 10, 165, Gi_332, 1, ">> Spread  : " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0));
  f0_6("L11", "Arial", 9, 10, 180, Gi_332, 1, ">> Account Balance  : $ " + DoubleToStr(AccountBalance(), 2));
  f0_6("L12", "Arial", 9, 10, 195, Gi_332, 1, ">> Account Equity  : $ " + DoubleToStr(AccountEquity(), 2));
  f0_6("L13", "Arial", 9, 10, 210, Gi_332, 1, ">> Order Total  : " + DoubleToStr(OrdersTotal(), 0));
  f0_6("L14", "Arial", 9, 10, 390, Li_4, 1, ">> Profit / Loss  : $ " + DoubleToStr(AccountEquity() - AccountBalance(), 2));
  f0_6("L15", "Arial", 15, 10, 425, Li_4, 1, " Rebate  : $ " + DoubleToStr(f0_13(), 2));
  ObjectCreate("j", OBJ_LABEL, 0, 0, 0);
  ObjectSet("j", OBJPROP_CORNER, 3);
  ObjectSet("j", OBJPROP_XDISTANCE, 10);
  ObjectSet("j", OBJPROP_YDISTANCE, 10);
  ObjectSetText("j", "ｩ 2014 || DJONG LIONG FOI ", 15, "Mistral", color_0);
}

void f0_6(string A_name_0, string A_fontname_8, int A_fontsize_16, int A_x_20, int A_y_24, color A_color_28, int A_corner_32, string A_text_36)
{
  if (ObjectFind(A_name_0) < 0) ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0);
  ObjectSetText(A_name_0, A_text_36, A_fontsize_16, A_fontname_8, A_color_28);
  ObjectSet(A_name_0, OBJPROP_CORNER, A_corner_32);
  ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_20);
  ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_24);
}

int f0_10()
{
  if (IsTesting()) return (1);
  if (IsTradeAllowed()) return (1);
  return (0);
}

#ifdef NEWS_FILTER
void News_Automatic()
{
  if (News_Fuente == Auto)
  {
    double CheckNews = 0;
    if (AfterNewsStop > 0)
    {
      if (TimeCurrent() - LastUpd >= Upd)
      {
        Comment("News Loading...");
        Print("News Loading...");
        UpdateNews();
        LastUpd = TimeCurrent();
        Comment("");
      }
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if (DrawLines)
      {
        for (int i = 0; i < NomNews; i++)
        {
          string Name = StringSubstr(TimeToStr(TimeNewsFunck(i), TIME_MINUTES) + "_" + NewsArr[1][i] + "_" + NewsArr[3][i], 0, 63);
          if (NewsArr[3][i] != "")
            if (ObjectFind(Name) == 0) continue;
          if (StringFind(str1, NewsArr[1][i]) < 0) continue;
          if (TimeNewsFunck(i) < TimeCurrent() && Next) continue;

          color clrf = clrNONE;
          if (Vhigh && StringFind(NewsArr[2][i], "High") >= 0) clrf = highc;
          if (Vmedium && StringFind(NewsArr[2][i], "Moderate") >= 0) clrf = mediumc;
          if (Vlow && StringFind(NewsArr[2][i], "Low") >= 0) clrf = lowc;

          if (clrf == clrNONE) continue;

          if (NewsArr[3][i] != "")
          {
            ObjectCreate(Name, 0, OBJ_VLINE, TimeNewsFunck(i), 0);
            ObjectSet(Name, OBJPROP_COLOR, clrf);
            ObjectSet(Name, OBJPROP_STYLE, Style);
            ObjectSetInteger(0, Name, OBJPROP_BACK, true);
          }

          Print(NewsArr[0, i]);  // tiene la fecha y hora
          Print(NewsArr[1, i]);  // tiene el Par
          Print(NewsArr[2, i]);  // tiene el Impacto (low med hi)
          Print(NewsArr[3, i]);  // tiene el texto de la noticia
        }
      }
      //---------------event Processing------------------------------------
      int i;
      CheckNews = 0;
      for (i = 0; i < NomNews; i++)
      {
        int power = 0;
        if (Vhigh && StringFind(NewsArr[2][i], "High") >= 0) power = 1;
        if (Vmedium && StringFind(NewsArr[2][i], "Moderate") >= 0) power = 2;
        if (Vlow && StringFind(NewsArr[2][i], "Low") >= 0) power = 3;
        if (power == 0) continue;
        if (TimeCurrent() + MinBefore * 60 > TimeNewsFunck(i) && TimeCurrent() - MinAfter * 60 < TimeNewsFunck(i) && StringFind(str1, NewsArr[1][i]) >= 0)
        {
          CheckNews = 1;
          break;
        } else
          CheckNews = 0;
      }
      if (CheckNews == 1 && i != Now && Signal)
      {
        Alert("In ", (int)(TimeNewsFunck(i) - TimeCurrent()) / 60, " minutes released news ", NewsArr[1][i], "_", NewsArr[3][i]);
        Now = i;
      }
      /***  ***/
    }

    if (CheckNews > 0)
    {
      /////  We are doing here if we are in the framework of the news
      Comment("News time");

    } else
    {
      // We are out of scope of the news release (No News)
      // Comment("No news");
    }
  }
}


// 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧


//////////////////////////////////////////////////////////////////////////////////
// Download CBOE page source code in a text variable
// And returns the result
//////////////////////////////////////////////////////////////////////////////////

string ReadCBOE()
{
  string cookie = NULL, headers;
  char   post[], result[];
  string TXT = "";
  int    res;
  //--- to work with the server, you must add the URL "https://www.google.com/finance"
  //--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"):
  string google_url = "http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
  //---
  ResetLastError();
  //--- download html-pages
  int timeout = 5000;  //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
  res         = WebRequest("GET", google_url, cookie, NULL, timeout, post, 0, result, headers);
  //--- error checking
  if (res == -1)
  {
    Print("WebRequest error, err.code  =", GetLastError());
    MessageBox("You must add the address ' " + google_url + "' in the list of allowed URL tab 'Advisors' ", " Error ", MB_ICONINFORMATION);
    //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
  } else
  {
    //--- successful download
    PrintFormat("File successfully downloaded, the file size in bytes  =%d.", ArraySize(result));
    //--- save the data in the file
    int filehandle = FileOpen("news-log.html", FILE_WRITE | FILE_BIN);
    //--- ???????? ??????
    if (filehandle != INVALID_HANDLE)
    {
      //---save the contents of the array result [] in file
      FileWriteArray(filehandle, result, 0, ArraySize(result));
      //--- close file
      FileClose(filehandle);

      int filehandle2 = FileOpen("news-log.html", FILE_READ | FILE_BIN);
      TXT             = FileReadString(filehandle2, ArraySize(result));
      FileClose(filehandle2);
    } else
    {
      Print("Error in FileOpen. Error code =", GetLastError());
    }
  }

  return (TXT);
}
// 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
datetime TimeNewsFunck(int nomf)
{
  string s    = NewsArr[0][nomf];
  string time = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
  return ((datetime)(StringToTime(time) + offset * 3600));
}
// 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
void UpdateNews()
{
  string TEXT = ReadCBOE();
  int    sh   = StringFind(TEXT, "pageStartAt>") + 12;
  int    sh2  = StringFind(TEXT, "</tbody>");
  TEXT        = StringSubstr(TEXT, sh, sh2 - sh);

  sh = 0;
  while (!IsStopped())
  {
    sh  = StringFind(TEXT, "event_timestamp", sh) + 17;
    sh2 = StringFind(TEXT, "onclick", sh) - 2;
    if (sh < 17 || sh2 < 0) break;
    NewsArr[0][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);

    sh  = StringFind(TEXT, "flagCur", sh) + 10;
    sh2 = sh + 3;
    if (sh < 10 || sh2 < 3) break;
    NewsArr[1][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
    if (StringFind(str1, NewsArr[1][NomNews]) < 0) continue;

    sh  = StringFind(TEXT, "title", sh) + 7;
    sh2 = StringFind(TEXT, "Volatility", sh) - 1;
    if (sh < 7 || sh2 < 0) break;
    NewsArr[2][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
    if (StringFind(NewsArr[2][NomNews], "High") >= 0 && !Vhigh) continue;
    if (StringFind(NewsArr[2][NomNews], "Moderate") >= 0 && !Vmedium) continue;
    if (StringFind(NewsArr[2][NomNews], "Low") >= 0 && !Vlow) continue;

    sh      = StringFind(TEXT, "left event", sh) + 12;
    int sh1 = StringFind(TEXT, "Speaks", sh);
    sh2     = StringFind(TEXT, "<", sh);
    if (sh < 12 || sh2 < 0) break;
    if (sh1 < 0 || sh1 > sh2)
      NewsArr[3][NomNews] = StringSubstr(TEXT, sh, sh2 - sh);
    else

    NomNews++;
    if (NomNews == 300) break;
  }
}

bool ControlNewsTime()
{
  if (News_Fuente != Auto)
  {
    return false;
  }
  bool   TieneNewsProxHora = false;
  string symNews;
  string SymPanel = Symbol();
  int    ahora    = TimeGMT();  // hora actual

  int t = ArrayRange(NewsArr, 1);
  // parte1 = StringSubstr(SymPanel, 0, 3);  // saca la primera parte del simbolo (EUR por ej para EURUSD)
  // parte2 = StringSubstr(SymPanel, 3, 6);  // saca la segunda (USD por ej para EURUSD)

  for (int j = 0; j < t; j++)
  {
    symNews         = NewsArr[1, j];  // tiene el Par / tomas el par j del array de news
    string s        = NewsArr[0][j];
    string time     = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
    int    NewsHora = ((datetime)(StringToTime(time)));  // hora de la noticia guardada en el array de news

    // Si la noticia est・dentro del rango de minutos en adelante "Turn_Off_Before"
    if (ahora + Turn_OFF_Before * 60 >= NewsHora && NewsHora > ahora)
    {
      Comment("||------ EA OFF for futures News ------||");
      return true;
    } else
    {
      int UltimaNewsPasada = 0;

      // recorre todas las noticias buscando la mayor hora del pasado
      for (int j = 0; j < t; j++)
      {
        string s        = NewsArr[0][j];
        string time     = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 4));
        int    NewsHora = ((datetime)(StringToTime(time)));  // hora de la noticia guardada en el array de news

        if (NewsHora < ahora && NewsHora > UltimaNewsPasada)
        {
          UltimaNewsPasada = NewsHora;
        }
      }

      if (UltimaNewsPasada >= ahora - Turn_ON_After * 60)
      {
        Comment("||------ EA OFF for pass News ------||");
        return true;
      }
    }
  }

  return false;
}

#endif

double floatingEA()
{
  double profit = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      profit += OrderProfit() + OrderSwap() + OrderCommission();
    }
  }

  return profit;
}

// clang-format off
bool CloseAllControl()
{
   switch (closeBy)
   {
      case CloseByMoney:
         if (floatingEA() >= closeAllMoney && closeAllMoney>0)        { return true; }
         if (floatingEA() < closeAllMoneyLoss && closeAllMoneyLoss<0) { return true; }
         break;

      case CloseByAccountPercent: 
		{
         double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
         double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;

         if (floatingEA() >= moneyByAccountPerWin && moneyByAccountPerWin>0) { return true; }
         if (floatingEA() < moneyByAccountPerLos && moneyByAccountPerLos<0) { return true; }
         break;
      }
      case CloseByPips: 
      {
         double moneyLimitWin = openVolume()*closeByPipsWin*10;
         double moneyLimitLoss = -openVolume()*closeByPipsLoss*10;
         if (floatingEA() >=moneyLimitWin) {return true; }
         if (floatingEA() < moneyLimitLoss) { return true; }
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

  }

  if (side == "sell")
  {
    actionCloseSells = new ActionCloseOrdersByType("sell", magico);
    actionCloseSells.doAction();
    delete actionCloseSells;
  }
}

void doBreackevenAction()
{
  for (int i = mainOrders.qnt() - 1; i >= 0; i--)
  {
    if (!mainOrders.index(i).breakevenWasDoIt())
    {
      breackevenCondition.setOrder(mainOrders.index(i));
      if (conditionsToBreackeven.EvaluateConditions())
      {
        breackevenAction = new MoveSL();
        breackevenAction.order(mainOrders.index(i)).newSL(mainOrders.index(i).price());
        breackevenAction.doAction();
        delete breackevenAction;
      }
    }
  }
}

double openVolume()
{
  double volume = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      volume += OrderLots();
    }
  }

  return volume;
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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