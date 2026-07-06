// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71860

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

enum ModeCalcLots { Money,
                    AccountPercent,
                    UserLots };
enum TSLMode { byPips,
               byMA };

input string T0                      = "== Trade Setup ==";        // == Trade Setup ==
ModeCalcLots modeCalcLots            = UserLots;                   // Mode to Calc Lots:
double       userMoney               = 10;                         // Setup Lots by "Money":
double       userBalancePer          = 0.1;                        // Setup Lots by "Account Percent":
input double userLots                = 0.01;                       // Lots:
input bool   useSLOn                 = true;                       // Use SL?:
int          userTPpips              = 20;                         // Pips TP
int          userSLpips              = 20;                         // Pips SL
input string Tpc                     = "== Partial Close ==";      // == Partial Close ==
input bool   partialCloseOn          = false;                      // Use Partial Close ?
double       userPartialClosePercent = 33;                         // Partial Close Percent:
double       userPartialClosePips    = 20;                         // Partial Close Pips:
input bool   closeInOposite          = false;                      // Close in Oposite Signal:
string Tbk                     = "== Breakeven Setup ==";    // == Breakeven Setup ==
bool   breakevenOn             = false;                      // Use Breakeven?
double userBkvPips             = 3;                          // Breakeven Pips
input string tTailingStop            = "== TailingStop Setup ==";  // == TailingStop Setup ==
input bool   TslON                   = false;                      // TSL ON:
TSLMode      userTslMode             = byPips;                     // TSL Mode:
int    userTslInitialStep      = 1;                          // TSL Initial Step:
int    userTslStep             = 1;                          // TSL Step:
int    userTslDistance         = 20;                         // TSL Distance:
input string T1                      = "== Timer ==";              // Timer
input bool   timerOn                 = false;                      // Timer On:
input string timeStart               = "00:00:00";                 // Time Start GMT
input string timeEnd                 = "23:59:59";                 // Time End GMT
input string TZ                      = "== Notifications ==";      // Notifications
input bool   notifications           = false;                      // Notifications
input bool   desktop_notifications   = false;                      // Desktop MT4 Notifications
input bool   email_notifications     = false;                      // Email Notifications
input bool   push_notifications      = false;                      // Push Mobile Notifications
input int    magico                  = 1035;                       // Magic Number:
string       T01                     = "== Filters Orders ==";     // == Filters Orders ==
bool         filterSymbolsOn         = true;                       // Use symbols filter?
string       SymbolsList             = "GBPUSD,EURUSD";            // Symbols (separate by comma ","):
bool         filterMagicsOn          = true;                       // Use magic number filter?
string       MagicsList              = "1";                        // Magics numbers (separate by comma ","):
input string ICustom         = "== TrendLinePro Setup ==";  // == TrendLinePro Setup ==
string       Separator0      = "///////////////////";
input string       PathName        = "TL_Optimizer_Settings";
input bool         UseAutoSetting  = true;
input double       iAmplitude      = 12;
input int          iDays           = 150;
input double       iLevelTP1       = 0.2;
input double       iLevelTP2       = 0.8;
input double       iLevelTP3       = 1.7;
input double       iLevelSL        = 1.0;
input bool         iUseFilter      = false;
input int          iTimeFrameF     = 240;
input bool         iTimeFilter_Use = false;
input string       iTimeStart      = "10:00";
input string       iTimeEnd        = "21:00";
input color        TimeFilterColor = Pink;
string       Separator3      = "///////////////////";
bool         AlertON         = false;
bool         PushON          = false;
bool         EmailON         = false;
string       Separator5      = "///////////////////";
input bool         ShowPanel       = true;
input bool         ShowTPSLline    = true;
input color        _TextColor      = Black;
input color        TPcolor         = Black;
input color        TPRcolor        = Black;
input color        SLcolor         = Red;
input color        DealColor       = Blue;
input double       TPSize          = 8;
input double       SLSize          = 8;



// ------------------------------------------------------------------
// NOTE: Includes:

interface iIndicators
{
   double calculate(int bufferNumber, int shift);
};

class TrendLinePro : public iIndicators
{
   string _symbol;
   int    _tf;
   string _file;
   struct Parameters
   {
      // NOTE: pasar los parametro del archivo .set
      string setup0;   // Separator0
      string setup1;   // PathName
      bool   setup2;   // UseAutoSetting
      double setup3;   // iAmplitude
      int    setup4;   // iDays
      double setup5;   // iLevelTP1
      double setup6;   // iLevelTP2
      double setup7;   // iLevelTP3
      double setup8;   // iLevelSL
      bool   setup9;   // iUseFilter
      int    setup10;  // iTimeFrameF
      bool   setup11;  // iTimeFilter_Use
      string setup12;  // iTimeStart
      string setup13;  // iTimeEnd
      color  setup14;  // TimeFilterColor
      string setup15;  // Separator3
      bool   setup16;  // AlertON
      bool   setup17;  // PushON
      bool   setup18;  // EmailON
      string setup19;  // Separator5
      bool   setup20;  // ShowPanel
      bool   setup21;  // ShowTPSLline
      color  setup22;  // _TextColor
      color  setup23;  // TPcolor
      color  setup24;  // TPRcolor
      color  setup25;  // SLcolor
      color  setup26;  // DealColor
      double setup27;  // TPSize
      double setup28;  // SLSize
   };
   Parameters _setup;

  public:
   TrendLinePro(string Symbol, int TimeFrame)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
      _file   = "TrendLine PRO MT4.ex4";
   }
   ~TrendLinePro() { ; }

   TrendLinePro* file(string setfile)
   {
      _file = setfile;
      return &this;
   }

   void setSetup(string set0, 
                 string set1, 
                 bool   set2, 
                 double set3, 
                 int    set4, 
                 double set5, 
                 double set6, 
                 double set7, 
                 double set8, 
                 bool   set9, 
                 int    set10, 
                 bool   set11, 
                 string set12, 
                 string set13, 
                 color  set14, 
                 string set15, 
                 bool   set16, 
                 bool   set17, 
                 bool   set18, 
                 string set19, 
                 bool   set20, 
                 bool   set21, 
                 color  set22, 
                 color  set23, 
                 color  set24, 
                 color  set25, 
                 color  set26, 
                 double set27, 
                 double set28
   )
   {
      _setup.setup0  = set0;
      _setup.setup1  = set1;
      _setup.setup2  = set2;
      _setup.setup3  = set3;
      _setup.setup4  = set4;
      _setup.setup5  = set5;
      _setup.setup6  = set6;
      _setup.setup7  = set7;
      _setup.setup8  = set8;
      _setup.setup9  = set9;
      _setup.setup10 = set10;
      _setup.setup11 = set11;
      _setup.setup12 = set12;
      _setup.setup13 = set13;
      _setup.setup14 = set14;
      _setup.setup15 = set15;
      _setup.setup16 = set16;
      _setup.setup17 = set17;
      _setup.setup18 = set18;
      _setup.setup19 = set19;
      _setup.setup20 = set20;
      _setup.setup21 = set21;
      _setup.setup22 = set22;
      _setup.setup23 = set23;
      _setup.setup24 = set24;
      _setup.setup25 = set25;
      _setup.setup26 = set26;
      _setup.setup27 = set27;
      _setup.setup28 = set28;
   }

   double calculate(int buffer, int shift)
   {
      return iCustom(_symbol, _tf, _file, _setup.setup0, 
      _setup.setup1, 
      _setup.setup2, 
      _setup.setup3, 
      _setup.setup4, 
      _setup.setup5, 
      _setup.setup6, 
      _setup.setup7, 
      _setup.setup8, 
      _setup.setup9, 
      _setup.setup10, 
      _setup.setup11, 
      _setup.setup12, 
      _setup.setup13, 
      _setup.setup14, 
      _setup.setup15, 
      _setup.setup16, 
      _setup.setup17, 
      _setup.setup18, 
      _setup.setup19, 
      _setup.setup20, 
      _setup.setup21, 
      _setup.setup22, 
      _setup.setup23, 
      _setup.setup24, 
      _setup.setup25, 
      _setup.setup26, 
      _setup.setup27, 
      _setup.setup28,      
      buffer, shift);
   }

   double lastValue(int buffer, bool candle = false)
   {
      double value = EMPTY_VALUE;
      int    i     = 0;
      while (value == EMPTY_VALUE || i == 2000)
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

   double BuySignal()  
   {
      return lastValue(7);
   }
   int BuyCandle()  
   {
      return lastValue(7,true);
   }

   double SellSignal()  
   {
      return lastValue(8);
   }
   int SellCandle()  
   {
      return lastValue(8,true);
   }
   int actualSide()
   {
      int lastBuy  = (int)lastValue(7, true);
      int lastSell = (int)lastValue(8, true);
      if (lastBuy < lastSell)
      {
         return 0;  // BUY
      } else
      {
         return 1;  // SELL
      }
   }
   
   double SL()
   {
      return lastValue(9);
   }
   double TP1()
   {
      return lastValue(10);
   }
   double TP2()
   {
      return lastValue(11);
   }
   double TP3()
   {
      return lastValue(12);
   }

   void printSetup()
   {
      Print("setup0 : ", _setup.setup0);
      Print("setup1 : ", _setup.setup1);
      Print("setup2 : ", _setup.setup2);
      Print("setup3 : ", _setup.setup3);
      Print("setup4 : ", _setup.setup4);
      Print("setup5 : ", _setup.setup5);
      Print("setup6 : ", _setup.setup6);
      Print("setup7 : ", _setup.setup7);
      Print("setup8 : ", _setup.setup8);
      Print("setup9 : ", _setup.setup9);
      Print("setup10: ", _setup.setup10);
      Print("setup11: ", _setup.setup11);
      Print("setup12: ", _setup.setup12);
      Print("setup13: ", _setup.setup13);
      Print("setup14: ", _setup.setup14);
      Print("setup15: ", _setup.setup15);
      Print("setup16: ", _setup.setup16);
      Print("setup17: ", _setup.setup17);
      Print("setup18: ", _setup.setup18);
      Print("setup19: ", _setup.setup19);
      Print("setup20: ", _setup.setup20);
      Print("setup21: ", _setup.setup21);
      Print("setup22: ", _setup.setup22);
      Print("setup23: ", _setup.setup23);
      Print("setup24: ", _setup.setup24);
      Print("setup25: ", _setup.setup25);
      Print("setup26: ", _setup.setup26);
      Print("setup27: ", _setup.setup27);
      Print("setup28: ", _setup.setup28);
   }
};
TrendLinePro trendLine(Symbol(), Period());

// Global Variables
//////////////////////////////////////////////////////////////////////
interface IOrders {
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
      if (ArrayRange(_symbols, 0) > 0)
      {
         ArraySort(_symbols, WHOLE_ARRAY, 0, MODE_ASCEND);
      }
      printSymbols();
   }

   bool control(const string symbolToControl)
   {
      Print(__FUNCTION__, " ", "ArraySize(_symbols)", " ", ArraySize(_symbols));
      if (ArraySize(_symbols) > 0)
      {
         for (int i = 0; i < ArraySize(_symbols); i++)
         {
            if (_symbols[i] == symbolToControl)
            {
         Print(__FUNCTION__, " ", "i", " ", i);
         Print(__FUNCTION__, " ", "_symbols[i]", " ", _symbols[i]);
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
		Print(__FUNCTION__," ","ArraySize(_magics)"," ",ArraySize(_magics));
      if (ArraySize(_magics) > 0)
      {			
         int p = ArrayBsearch(_magics, magicToControl, WHOLE_ARRAY, 0, MODE_ASCEND);
			Print(__FUNCTION__," ","p"," ",p);
			Print(__FUNCTION__," ","_magics[p]"," ",_magics[p]);         
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
      clearList(); 
      delete _symbols;
      delete _magics;
   }

   //+------------------------------------------------------------------+

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
					 .signalTime(OrderOpenTime())
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
   //+------------------------------------------------------------------+
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
                .signalTime(OrderOpenTime())
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
   //+------------------------------------------------------------------+
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

   bool isClose(Order* order)
   {
      if (OrderSelect(order.id(), SELECT_BY_TICKET))
      {
         if (OrderCloseTime() != 0) return true;
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
      Print("Order ", index, " countPartials: ", orders[index].countPartials());
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
OrdersList ordersList(filterMagicsOn, (string)magico, filterSymbolsOn, _Symbol);

interface iTSL {
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
	   order.tslNext(trendLine.TP1());
   }

   void setNextStep(Order* order)
   {
      double price;
      if (order.countPartials() == 1)
      {
         price = trendLine.TP2();
      }
      if (order.countPartials() == 2)
      {
         price = trendLine.TP3();
      }
      
		order.tslNext(price);
   }

   double newSL(Order* order)
   {
      double newSl        = order.sl();

      if (order.countPartials() == 1)
      {
         newSl = order.price();
      }
      if (order.countPartials() == 2)
      {
         newSl = trendLine.TP1();
      }

      return newSl;
   }
};

class TrailingStop
{
   OrdersList* _orders;
   iTSL*       _TslMode;

  public:
   TrailingStop(OrdersList* uOrdersList, TSLMode mode)
   {
      _orders = uOrdersList;

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
            Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " error:", GetLastError());
         } else
         {
            Print(__FUNCTION__, " trailing stop in tk: ", tk);
         }
      }
   }
};
TrailingStop* tsl;

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

      // FOREX
      if (_modeCalc == 0)
      {
         return NormalizeDouble(risk / distance / _tickValue, 2);
      }

      // FUTUROS
      if (_modeCalc == 1 && _step != 1.0)
      {
         double c = _contractSize * _step;
         return NormalizeDouble(risk / (distance * c), 2);
      }

      // FUTUROS SIN DECIMALES
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

interface iConditions {
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

interface iActions {
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
class PartialClose : public iActions
{
   Order* _order;
   double _percentToClose;

  public:
   PartialClose() { ; }
   ~PartialClose() { ; }

   PartialClose* order(Order* or)
   {
      _order = or ;
      return &this;
   }
   PartialClose* percent(double percentToClose)
   {
      _percentToClose = percentToClose;
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

   double lots()
   {
      return NormalizeDouble((_order.lot() * _percentToClose / 100), 2);
   }

   double price()
   {
      double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
      double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

      if (_order.type() == OP_BUY)
      {
         return bid;
      }
      if (_order.type() == OP_SELL)
      {
         return ask;
      }
      return 0;
   }

   bool doAction()
   {
      if (!controlPointer(_order))
      {
         Print(__FUNCTION__, " ", "Can't Take Partial");
         return false;
      }
      if (OrderSelect(_order.id(), SELECT_BY_TICKET))
      {
         if (OrderCloseTime() > 0)
         {
            Print(__FUNCTION__, " ", "Order are closed ", _order.id());
            return false;
         }

         if (OrderClose(_order.id(), lots(), price(), 1000, clrNONE))
         {
            _order.countPartials(1);
            // remplazar el tk por el nuevo tk
            changeTk(_order.id());

            Print(__FUNCTION__, " ", _order.id(), " Partial TP taked ");
            return true;
         }

      } else
      {
         Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
      }

      return false;
   }

   void changeTk(int tk)
   {
      if (OrderSelect(tk, SELECT_BY_TICKET))
      {
         datetime dt     = OrderCloseTime();
         string   coment = OrderComment();
         int      pos    = StringFind(coment, "#") + 1;
         string   newId  = StringSubstr(coment, pos, StringLen(coment));
         _order.id((int)newId);
      }
   }
};

class SendNewOrder : public iActions
{
  private:
   Order newOrder;

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
          .signalTime(OrderOpenTime())
          .profit(0);
   }

   ~SendNewOrder() {}

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
};

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
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         setPrice();
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic)
         {
            if (!OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE))
            {
               Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
            }
         }
      }
      return true;
   }
};

ConcurrentConditions     conditionsToBuy;
ConcurrentConditions     conditionsToSell;
ConcurrentConditions     conditionsToCloseBuy;
ConcurrentConditions     conditionsToCloseSell;
ConcurrentConditions     conditionsToBreackeven;
ConcurrentConditions     conditionsToPartialClose;
SendNewOrder*            actionSendOrder;
ActionCloseOrdersByType* actionCloseSells;
ActionCloseOrdersByType* actionCloseBuys;
MoveSL*                  breackevenAction;
PartialClose*            partialCloseAction;

// NOTE: buy sell conditions
class CustomConditionBUY : public iConditions
{
  public:
   bool evaluate()
   {
      // TODO: dev condition
      if (trendLine.actualSide() == 0 && trendLine.BuyCandle() < 3)
      {
         return true;
      }
      return false;
   }
};
CustomConditionBUY* entryBuy;
class CustomConditionBUY2 : public iConditions
{
  public:
   bool evaluate()
   {
      // TODO: dev condition // last buy 3 candles back
      if (CheckPointer(ordersList.last()) != POINTER_INVALID)
      {
         if (ordersList.last().type() == OP_BUY)
         {
            datetime timeLastBuy = ordersList.last().signalTime();
            int      barsLastBuy = Bars(Symbol(), Period(), timeLastBuy, TimeCurrent());
            if (barsLastBuy < 3)
            {
               return false;
            }
         }
      }
      return true;
   }
};
CustomConditionBUY2* customConditionBuy2;
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
class CustomConditionSELL : public iConditions
{
  public:
   bool evaluate()
   {
      // TODO: dev condition
      if (trendLine.actualSide() == 1 && trendLine.SellCandle() < 3)
      {
         return true;
      }
      return false;
   }
};
CustomConditionSELL* entrySell;
class CustomConditionSELL2 : public iConditions
{
  public:
   bool evaluate()
   {
      // TODO: dev condition
      if (CheckPointer(ordersList.last()) != POINTER_INVALID)
      {
         if (ordersList.last().type() == OP_SELL)
         {
            datetime timeLastBuy = ordersList.last().signalTime();
            int      barsLastBuy = Bars(Symbol(), Period(), timeLastBuy, TimeCurrent());
            if (barsLastBuy < 3)
            {
               return false;
            }
         }
      }
      return true;
   }
};
CustomConditionSELL2* customConditionSell2;
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
class ConditionToCloseBuy : public iConditions
{
  public:
   bool evaluate()
   {
      if (closeInOposite)
      {
         if (conditionsToSell.EvaluateConditions())
         {
            return true;
         }
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
      if (closeInOposite)
      {
         if (conditionsToBuy.EvaluateConditions())
         {
            return true;
         }
      }
      return false;
   }
};
ConditionToCloseSell* conditionCloseSell;

class BreackevenCondition : public iConditions
{
   // TODO: bk
   Order* _order;

  public:
   void setOrder(Order* or)
   {
      _order = or ;
   }

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

class PartialCloseCondition : public iConditions
{
   // TODO: PC
   Order* _order;

  public:
   void setOrder(Order* or)
   {
      _order = or ;
   }

   bool evaluate()
   {
      double mPoints      = MarketInfo(_order.symbol(), MODE_POINT);
      double ask          = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
      double bid          = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);
      double dist         = userPartialClosePips * mPoints * 10;
      double priceToClose = 0;

      // TODO: setear priceToClose con los TP que dá el indicador

      if (_order.countPartials() == 0)
      {
         priceToClose = trendLine.TP1();
      }
      if (_order.countPartials() == 1)
      {
         priceToClose = trendLine.TP2();
      }
      if (_order.countPartials() == 2)
      {
         priceToClose = trendLine.TP3();
      }

      if (_order.type() == OP_BUY)
      {
         if (bid >= priceToClose)
         {
            Print(__FUNCTION__, " ", "priceToClose", " ", priceToClose);
            Print(__FUNCTION__, " ", "bid", " ", bid);
            return true;
         }
      }
      if (_order.type() == OP_SELL)
      {
         if (ask <= priceToClose)
         {
            return true;
         }
      }

      return false;
   }
};
PartialCloseCondition* partialCloseCondition;

class OrderMannager
{
   OrdersList*            _orders;
   bool                   _partialCloseOn;
   ConcurrentConditions   _conditionsToPartial;
   PartialCloseCondition* _partialCloseCondition;
   PartialClose*          _partialCloseAction;

  public:
   OrderMannager(OrdersList& orders, bool partialOn)
   {
      _orders         = GetPointer(orders);
      _partialCloseOn = partialOn;
   }
   ~OrderMannager() { ; }

   void setConditionsToPartialClose(iConditions* condition)
   {
      _conditionsToPartial.AddCondition(condition);
      _partialCloseCondition = condition;
   }

   void execute()
   {
      for (int i = _orders.qnt() - 1; i >= 0; i--)
      {
         // if (_orders.index(i).countPartials() <= _maxPartials)
         if (_partialCloseOn)
         {
            _partialCloseCondition.setOrder(_orders.index(i));
            if (_conditionsToPartial.EvaluateConditions())
            {
               _partialCloseAction = new PartialClose();
               _partialCloseAction.order(_orders.index(i)).percent(userPartialClosePercent);
               _partialCloseAction.doAction();
               delete _partialCloseAction;
            }
         }
         //---
      }
   }
};
OrderMannager manager(ordersList, partialCloseOn);

//////////////////////////////////////////////////////////////////////

int OnInit()
{
   newCandle = new CNewCandle();
   tsl       = new TrailingStop(GetPointer(ordersList), byPips);

   //--- CONDITIONS TO OPEN TRADES:
   conditionsToBuy.AddCondition(entryBuy = new CustomConditionBUY());
   conditionsToBuy.AddCondition(customConditionBuy2 = new CustomConditionBUY2());
   conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1));

   conditionsToSell.AddCondition(entrySell = new CustomConditionSELL());
   conditionsToSell.AddCondition(customConditionSell2 = new CustomConditionSELL2());
   conditionsToSell.AddCondition(countSells = new ConditionCountSells(1));

   // --- CONDITIONS TO CLOSE TRADES:
   conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());
   conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());

   //--- CONDITIONS TO BREAKEVEN:
   conditionsToBreackeven.AddCondition(breackevenCondition = new BreackevenCondition());

   //--- CONDITIONS TO PARTIAL CLOSE:
   // conditionsToPartialClose.AddCondition(partialCloseCondition = new PartialCloseCondition());
   manager.setConditionsToPartialClose(partialCloseCondition = new PartialCloseCondition());

   //--- SESSIONS CONTROL:
   sesionControl.AddSession(timeStart, timeEnd);
   // EventSetTimer(1);

   trendLine.setSetup(
       Separator0,
       PathName,
       UseAutoSetting,
       iAmplitude,
       iDays,
       iLevelTP1,
       iLevelTP2,
       iLevelTP3,
       iLevelSL,
       iUseFilter,
       iTimeFrameF,
       iTimeFilter_Use,
       iTimeStart,
       iTimeEnd,
       TimeFilterColor,
       Separator3,
       AlertON,
       PushON,
       EmailON,
       Separator5,
       ShowPanel,
       ShowTPSLline,
       _TextColor,
       TPcolor,
       TPRcolor,
       SLcolor,
       DealColor,
       TPSize,
       SLSize);

   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   delete newCandle;
   delete tsl;
}
void OnTick()
{
   ordersList.cleanCloseOrders();
   // breackeven Conditions & action
   // ------------------------------------------------------------------
   if (breakevenOn) doBreackevenAction();
   if (TslON) tsl.doTSL();
   // ------------------------------------------------------------------
   // Partial Close:
   // ------------------------------------------------------------------
   if (partialCloseOn) doPartialCloseAction();
   // ------------------------------------------------------------------

   if (CloseCandleMode)
      if (!newCandle.IsNewCandle())
      {
         return;
      }

   if (!sesionControl.doSessionControl())
   {
      return;
   }

   if (conditionsToCloseBuy.EvaluateConditions())
   {
      actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
      actionCloseBuys.doAction();
      delete actionCloseBuys;
   }
   if (conditionsToCloseSell.EvaluateConditions())
   {
      actionCloseSells = new ActionCloseOrdersByType("sell", magico);
      actionCloseSells.doAction();
      delete actionCloseSells;
   }

   if (conditionsToBuy.EvaluateConditions())
   {
      actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
      if (actionSendOrder.doAction())
      {
         ordersList.GetLastMarketOrder();
         Notifications(0);
      }
      delete actionSendOrder;
   }
   if (conditionsToSell.EvaluateConditions())
   {
      actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
      if (actionSendOrder.doAction())
      {
         ordersList.GetLastMarketOrder();
         Notifications(1);
      }
      delete actionSendOrder;
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
double SL(string direction)
{
   double result = 0;
   // if (userSLpips == 0)
   // {
   //    return 0;
   // }
   if (!useSLOn)
   {
      return 0;
   }
   if (direction == "buy")
   {
      // double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      // result     = ask - userSLpips * 10 * _Point;
      result = trendLine.SL();
      return result;
   }

   if (direction == "sell")
   {
      // double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      // result     = bid + userSLpips * 10 * _Point;
      result = trendLine.SL();
      return result;
   }

   return -1;
}
double TP(string direction)
{
   double result = 0;
   // if (userTPpips == 0)
   // {
   //    return 0;
   // }
   if (direction == "buy")
   {
      // double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      // result     = ask + userTPpips * 10 * _Point;
		result = trendLine.TP3();
      return result;
   }

   if (direction == "sell")
   {
      // double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      // result     = bid - userTPpips * 10 * _Point;
		result = trendLine.TP3();
      return result;
   }

   return -1;
}
double Lots()
{
   lotProvider = new LotCalculator();
   double lots = -1;
   switch (modeCalcLots)
   {
      case Money:
         lots = lotProvider.LotsByMoney(userMoney, userTPpips);
         break;

      case AccountPercent:
         lots = lotProvider.LotsByBalancePercent(userBalancePer, userTPpips);
         break;

      case UserLots:
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

void doBreackevenAction()
{
   for (int i = ordersList.qnt() - 1; i >= 0; i--)
   {
      if (!ordersList.index(i).breakevenWasDoIt())
      {
         breackevenCondition.setOrder(ordersList.index(i));
         if (conditionsToBreackeven.EvaluateConditions())
         {
            breackevenAction = new MoveSL();
            breackevenAction.order(ordersList.index(i)).newSL(ordersList.index(i).price());
            breackevenAction.doAction();
            delete breackevenAction;
         }
      }
   }
}

void doPartialCloseAction()
{
   manager.execute();
}