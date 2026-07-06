//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74242

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


#define TIMER_MINI  // one session at day

#ifdef TIMER_MINI
input string T1 = "== Trading Sessions ==";  // ————————————
input string timeStart = "00:00:00";                // Time Start GMT
input string timeEnd = "23:59:59";                // Time End GMT
#endif

double gd_unused_76 = 0.0;
double gd_unused_84 = 0.0;
double gd_unused_92 = 0.0;
input string Fixed_Lots = "== Fixed_Lots ==";
extern double Lots = 0.1;
input string Lot_Management = "== Lot_Management ==";
extern bool Money_Management = false;
input string Risk_Management = "== Risk_Management ==";
extern double Risk = 0.05;
int magico = 1010;
bool gi_120 = FALSE;
bool gi_124 = FALSE;
bool gi_128 = FALSE;
bool gi_132 = FALSE;
bool gi_136 = FALSE;
bool gi_140 = FALSE;
bool gi_144 = FALSE;
bool gi_148 = FALSE;
bool gi_152 = FALSE;
bool gi_156 = FALSE;
bool gi_160 = FALSE;
bool gi_164 = TRUE;
bool gi_168 = FALSE;
bool gi_172 = FALSE;
bool gi_176 = FALSE;
bool gi_180 = FALSE;
bool gi_184 = TRUE;
bool gi_188 = FALSE;
bool gi_192 = TRUE;
bool gi_196 = FALSE;
double gd_200 = 3.0;
double gd_208 = 4.0;
int gi_216 = 10;
bool gi_unused_220 = TRUE;
double gd_224 = 23.0;
double gd_232 = 23.0;
double g_slippage_240 = 10000;
double g_price_248 = 0.0;
double g_price_256 = 0.0;
double gd_264 = 1.0;
double gd_272 = 1.1;
bool gi_280 = TRUE;
double gd_284;
bool gi_292 = FALSE;
bool gi_296 = FALSE;
bool gi_unused_300 = FALSE;
bool gi_unused_304 = FALSE;
double gd_308 = 0.0;
double gd_316 = 0.0;
bool gi_324 = FALSE;
bool gi_328 = FALSE;
double g_period_332 = 1.0;
double g_period_340 = 1.0;
int gi_348 = 0;
bool gi_352 = FALSE;
double gd_unused_356 = 0.0;
double gd_unused_364 = 0.0;
double gd_372;
double gd_380;
double gd_388;
double gd_396;
double gd_unused_404 = 0.0;
double gd_412;
double gd_420;
double gd_428;
double gd_436;
double gd_444;
double gd_452;
double gd_460;
double gd_468;
double gd_476;
double gd_484;
int g_ticket_492;
int g_order_total_496;
int g_pos_500;
double gd_504;
double gd_512;
double gd_520;
double gd_552;
double gd_560;
double gd_568;
double gd_576;
double gd_584;
double gd_592;
double gd_600;
double gd_608;
double gd_616;
double gd_624;
double gd_632;
double gd_640;
double g_low_648;
double g_high_656;
double g_time_664;
double g_bid_672;
double g_ask_680;
double gd_688;
double g_digits_696;
double gd_704;
double gd_712;
double g_lotsize_720;
double g_tickvalue_728;
double g_ticksize_736;
double g_swaplong_744;
double g_swapshort_752;
double g_starting_760;
double g_expiration_768;
double g_tradeallowed_776;
double g_minlot_784;
double g_lotstep_792;


// NOTE: enums
enum enumDays {
    sunday,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    EA_OFF
};

enum TSLMode {
    byPips,  // By Pips
    byMA     // By Moving Average
};

// NOTE: Inputs
#define TRAILING_STOP_ON
#ifdef TRAILING_STOP_ON
input string tTailingStop = "== TrailingStop Setup ==";  // ————————————
input bool   TslON = false;                       // TSL ON:
TSLMode      userTslMode = byPips;                      // TSL Mode:
input int    userTslInitialStep = 1;                           // TSL Initial Step:
input int    userTslDistance = 10;                          // TSL Distance:
int    userTslStep = 1;                           // TSL Step:
#endif
// ------------------------------------------------------------------
input string tGrid = "== Grid Setup ==";  // ————————————
input bool   GridON = true;               // Grid On:
input int    GridUser_maxCount = 10;                   // Max attempts:
input double GridUser_maxLot = 100;                  // Max lot value:
input double GridUser_multiplier = 1.5;                 // Multiplier:
input int    GridUser_gap = 30;                  // Gap betwen orders (pips):
input bool   closeGridOn = false;                // Use Close Grid?
input double closeGridTP = 100;                 // Take Profit Grid $
input double closeGridSL = -100;                // Stop Loss Grid -$


interface IOrders
{
    public:
    virtual void Add() = 0;
    virtual void Release() = 0;

    virtual bool AddOrder() = 0;
    virtual bool DeleteOrder() = 0;
    virtual bool Select() = 0;
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
        _countPartials(countPartials)
    {}

    Order() {}
    ~Order() {}

    // clang-format off
    Order* id(int id) { _id = id; return &this; }
    Order* symbol(string symbol) { _symbol = symbol; return &this; }
    Order* price(double price) { _price = price; return &this; }
    Order* sl(double sl) { _sl = sl; return &this; }
    Order* tp(double tp) { _tp = tp; return &this; }
    Order* lot(double lot) { _lot = lot; return &this; }
    Order* type(int type) { _type = type; return &this; }
    Order* magic(int magic) { _magic = magic; return &this; }
    Order* comment(string comment) { _comment = comment; return &this; }
    Order* expireTime(datetime expireTm) { _expireTime = expireTm; return &this; }
    Order* signalTime(datetime signalTm) { _signalTime = signalTm; return &this; }
    Order* profit(double profit) { _profit = profit; return &this; }
    Order* strategy(string strategy) { _strategy = strategy; return &this; }
    Order* tslNext(double tslNext) { _tslNext = tslNext; return &this; }
    Order* breakevenWasDoIt(bool bkvWasDoIt) { _bkvWasDoIt = bkvWasDoIt; return &this; }
    Order* countPartials(int count) { _countPartials = _countPartials + count; return &this; }

    int            id() { return _id; }
    string         symbol() { return _symbol; }
    double         price() { return _price; }
    double         sl() { return _sl; }
    double         tp() { return _tp; }
    double         lot() { return _lot; }
    int            type() { return _type; }
    int            magic() { return _magic; }
    string         comment() { return _comment; }
    string         strategy() { return _strategy; }
    datetime       expireTime() { return _expireTime; }
    datetime       signalTime() { return _signalTime; }
    double         profit() { if(OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit() + OrderCommission() + OrderSwap(); return -1; }
    double         tslNext() { return _tslNext; }
    double         breakevenWasDoIt() { return _bkvWasDoIt; }
    int            countPartials() { return _countPartials; }
};

class FilterBySymbols
{
    string _symbols [];

    public:
    FilterBySymbols(string userSymbols) { getSymbols(userSymbols); }
    ~FilterBySymbols() { ; }

    void getSymbols(string userSymbols)
    {
        string Simbolos [];
        string sep = ",";
        ushort u_sep;
        u_sep = StringGetCharacter(sep, 0);
        int k = StringSplit(userSymbols, u_sep, Simbolos);
        ArrayResize(_symbols, ArrayRange(Simbolos, 0), 0);
        for(int i = 0; i < ArrayRange(Simbolos, 0); i++)
        {
            _symbols[i] = Simbolos[i];
        }
        printSymbols();
    }

    bool control(const string symbolToControl)
    {
        if(ArraySize(_symbols) > 0)
        {
            for(int i = 0; i < ArraySize(_symbols); i++)
            {
                if(_symbols[i] == symbolToControl)
                {
                    return true;
                }
            }
        }

        return false;
    }

    void printSymbols()
    {
        for(int i = 0; i < ArraySize(_symbols); i++)
        {
            //Print(_symbols[i]);
        }
    }

    //---
};
class FilterByMagics
{
    int _magics [];

    public:
    FilterByMagics(string userMagics) { getMagics(userMagics); }
    ~FilterByMagics() { ; }

    void getMagics(string userMagics)
    {
        string Magicos [];
        string sep = ",";
        ushort u_sep;
        u_sep = StringGetCharacter(sep, 0);
        int k = StringSplit(userMagics, u_sep, Magicos);
        ArrayResize(_magics, ArrayRange(Magicos, 0), 0);
        for(int i = 0; i < ArrayRange(Magicos, 0); i++)
        {
            _magics[i] = (int) Magicos[i];
        }
        if(ArrayRange(_magics, 0) > 0)
        {
            ArraySort(_magics, WHOLE_ARRAY, 0, MODE_ASCEND);
        }
        printMagics();
    }

    bool control(const int magicToControl)
    {
        if(ArraySize(_magics) > 0)
        {
            int p = ArrayBsearch(_magics, magicToControl, WHOLE_ARRAY, 0, MODE_ASCEND);
            if(_magics[p] == magicToControl)
            {
                return true;
            }
        }

        return false;
    }

    void printMagics()
    {
        for(int i = 0; i < ArraySize(_magics); i++)
        {
            //Print(_magics[i]);
        }
    }


    //---
};
class OrdersList
{
    Order* orders [];
    bool            _filterByMagicOn;
    bool            _filterBySymbolsOn;
    FilterByMagics* _magics;
    FilterBySymbols* _symbols;

    public:
    OrdersList() { ; }
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
        if(ArrayResize(orders, t + 1))
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
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if(_filterByMagicOn) if(!_magics.control(OrderMagicNumber())) { continue; }
                if(_filterBySymbolsOn) if(!_symbols.control(OrderSymbol())) { continue; }

                if(exist(OrderTicket()) == true) { continue; }

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

                if(AddOrder(newOrder))
                {
                    //PrintOrder(i);                    
                }
            }
        }
    }

    // agrega la última orden si no está en el array
    // ——————————————————————————————————————————————————————————————————
    bool GetLastMarketOrder()
    {
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if(_filterByMagicOn) if(!_magics.control(OrderMagicNumber())) { continue; }
                if(_filterBySymbolsOn) if(!_symbols.control(OrderSymbol())) { continue; }
                if(exist(OrderTicket()) == true) { continue; }

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

                if(AddOrder(newOrder))
                {
                    Print(__FUNCTION__, " ", "* Nueva Orden De Mercado * ", id(i), "magic: ", magic(i));
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
        for(int i = qnt() - 1; i >= 0; i--)
        {
            if(id(i) == id)
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
        if(notOverFlow(index))
        {
            delete orders[index];
        }

        if(qnt() > index)
        {
            for(int i = index; i < qnt() - 1; i++)
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
        for(int i = 0; i < qnt(); i++)
        {
            if(CheckPointer(orders[i]) != POINTER_INVALID)
            {
                deleteOrder(i);
            }
        }
    }

    // devuelve el puntero a la última orden
    Order* last()
    {
        int lastIndex = ArraySize(orders) - 1;
        if(lastIndex == -1)
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
        if(index > ArraySize(orders) - 1) return false;
        if(index < 0) return false;
        if(CheckPointer(orders[index]) == POINTER_INVALID) return false;

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
        if(notOverFlow(index))
        {
            return orders[index].id();
        }
        return -1;
    }
    string symbol(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].symbol();
        }
        return "";
    }
    double price(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].price();
        }
        return -1;
    }
    double sl(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].sl();
        }
        return -1;
    }
    double tp(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].tp();
        }
        return -1;
    }
    double lot(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].lot();
        }
        return -1;
    }
    int magic(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].magic();
        }
        return -1;
    }
    datetime expire(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].expireTime();
        }
        return -1;
    }
    datetime signalTime(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].signalTime();
        }
        return -1;
    }
    string comment(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].comment();
        }
        return "";
    }
    ENUM_ORDER_TYPE type(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].type();
        }
        return -1;
    }
    double profit(int index)
    {
        if(notOverFlow(index))
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
        if(notOverFlow(index))
        {
            if(OrderSelect(id(index), SELECT_BY_TICKET))
            {
                if(OrderCloseTime() != 0) return true;
            }
        }
        return false;
    }

    // borra de la lista los trades cerrados
    // ——————————————————————————————————————————————————————————————————
    void cleanCloseOrders()
    {
        // if(qnt() == 0)
        // {
        //     return;
        // }

        for(int i = 0; i < qnt(); i++)
        {
            if(isClose(i))
            {
                Print(__FUNCTION__, " ID to close: ", id(i));
                int id = id(i);
                deleteOrder(i);
                CloseGrid(id);
            }
        }
    }

    // cierra todas las ordenes en la lista y la limpia, te retorna la cantidad de errores
    int closeAllInList()
    {
        cleanCloseOrders();
        int errors = 0;

        for(int i = 0; i < ArraySize(orders); i++)
        {
            int tk;
            if(isClose(i))
            {
                continue;
            }
            if(CheckPointer(orders[i]) != POINTER_INVALID)
            {
                tk = orders[i].id();
            }
            else
            {
                continue;
            }
            if(OrderSelect(tk, SELECT_BY_TICKET))
            {
                double ask = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
                double bid = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
                double closePrice = OrderType() == OP_BUY ? bid : ask;
                if(!OrderClose(OrderTicket(), OrderLots(), closePrice, 1000, clrNONE))
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
        if(!notOverFlow(index))
        {
            return;
        }
        if(CheckPointer(orders[index]) == POINTER_INVALID)
        {
            return;
        }
        // clang-format off
        Print("Order ", index, " id: ", orders[index].id());
        Print("Order ", index, " symbol: ", orders[index].symbol());
        Print("Order ", index, " type: ", orders[index].type());
        Print("Order ", index, " lot: ", orders[index].lot());
        Print("Order ", index, " price: ", orders[index].price());
        Print("Order ", index, " sl: ", orders[index].sl());
        Print("Order ", index, " tp: ", orders[index].tp());
        Print("Order ", index, " magic: ", orders[index].magic());
        Print("Order ", index, " comment: ", orders[index].comment());
        Print("Order ", index, " strategy: ", orders[index].strategy());
        Print("Order ", index, " expire time: ", orders[index].expireTime());
        Print("Order ", index, " signal time: ", orders[index].signalTime());
        Print("Order ", index, " profit: ", orders[index].profit());
        Print("Order ", index, " countPartials: ", orders[index].countPartials());
        // clang-format on
    }
    // ——————————————————————————————————————————————————————————————————
    void PrintList()
    {
        for(int i = 0; i < qnt(); i++)
        {
            //PrintOrder(i);
        }
    }
};
OrdersList mainOrders(true, (string) magico, true, _Symbol);

interface iActions
{
    bool doAction();
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
        _TslStep = TslStep * 10;
        _Distance = Distance * 10;
    }
    ~TslByPips() { ; }

    void setInitialStep(Order* order)
    {
        double mPoint = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _InitialStep * mPoint;
        if(order.type() == OP_SELL)
        {
            pointsToMove *= -1;
        }
        order.tslNext(order.price() + pointsToMove);

        //Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        //Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
        //Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
    }

    void setNextStep(Order* order)
    {
        double mPoint = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _TslStep * mPoint;
        if(order.type() == OP_SELL)
        {
            pointsToMove *= -1;
        }
        order.tslNext(order.tslNext() + pointsToMove);

        //Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        //Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
        //Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
    }

    double newSL(Order* order)
    {
        double mPoint = MarketInfo(order.symbol(), MODE_POINT);
        double pointsToMove = _Distance * mPoint;
        if(order.type() == OP_SELL)
        {
            pointsToMove *= -1;
        }

        double newSl = order.tslNext() - pointsToMove;
        //Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        //Print(__FUNCTION__, " ", "TSL New SL: ", " ", newSl);

        return newSl;
    }
};

class TrailingStop
{
    OrdersList* _orders;
    iTSL* _TslMode;

    public:
    TrailingStop(OrdersList* uOrders, TSLMode mode)
    {
        _orders = uOrders;

        switch(mode)
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
        for(int i = 0; i < _orders.qnt(); i++)
        {
            if(CheckPointer(_orders.index(i)) == POINTER_INVALID)
            {
                // Print(__FUNCTION__, " ", "Pointer invalid i= ", i);
                continue;
            }


            // si la primer orden esta en perdidas salir
            if(_orders.index(i).profit() < 0) return;

            // seteo Initial:
            if(_orders.index(i).tslNext() == 0)
            {
                _TslMode.setInitialStep(_orders.index(i));
            }

            if(MatchNextTsl(_orders.index(i)))
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
        if(order.type() == OP_BUY)
        {
            if(bid >= order.tslNext())
            {
                return true;
            }
        }
        if(order.type() == OP_SELL)
        {
            if(ask <= order.tslNext())
            {
                return true;
            }
        }
        return false;
    }

    void moveSL(int tk, double newSl)
    {
        if(OrderSelect(tk, SELECT_BY_TICKET))
        {
            if(!OrderModify(tk, OrderOpenPrice(), newSl, OrderTakeProfit(), 0))
            {
                // Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " ", GetLastError());
            }
            else
            {
                // Print(__FUNCTION__, " trailing stop in tk: ", tk);
            }
        }
    }
};
TrailingStop* tsl;


interface iConditions
{
    bool evaluate();
};
class ConcurrentConditions
{
    protected:
    iConditions* _conditions [];

    public:
    ConcurrentConditions(void) {}
    ~ConcurrentConditions(void) { releaseConditions(); }

    // ——————————————————————————————————————————————————————————————————
    void releaseConditions()
    {
        for(int i = 0; i < ArraySize(_conditions); i++)
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
        for(int i = 0; i < ArraySize(_conditions); i++)
        {
            if(!_conditions[i].evaluate())
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
        _side = Side;
        _price = Price;
        _mode = Mode;
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

        if(_mode == 0)
        {
            if(_side == "buy")
            {
                if(ask >= _price)
                {
                    return true;
                }
                return false;
            }
            if(_side == "sell")
            {
                if(bid <= _price)
                {
                    return true;
                }
                return false;
            }
        }

        if(_mode == 1)
        {
            if(_side == "buy")
            {
                if(ask <= _price)
                {
                    return true;
                }
                return false;
            }
            if(_side == "sell")
            {
                if(bid >= _price)
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
        _lot = Lot;
    }
    ~ConditionMaxLot() { ; }
    void lot(double inplot) { _lot = inplot; }

    bool evaluate()
    {
        if(_maxLot >= _lot)
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
        if(_orders.qnt() < _maxQnt)
        {
            return true;
        }
        return false;
    }
};

enum DayLimitsMode {
    LimitsByAmount,         // by Amount
    LimitsByAccountPercent  // by Account %
};
string        Tlimits = "== Daily Limits Setup ==";  // ————————————
bool          uDailyProfitOn = false;                       // Control Daily Profit On:
DayLimitsMode limitProfitMode = LimitsByAmount;              // Mode to control daily profit:
double        uDayLimitProfit = 2000;                        // Max Daily Profit ($ or %):
bool          uDailyLossOn = false;                       // Control Daily Loss On:
DayLimitsMode limitLossMode = LimitsByAmount;              // Mode to control daily loss:
double        uDayLimitLoss = -1000;                       // Max Daily Loss ($ or %):
bool          uConsiderFloatting = false;                       // Consider Floating:

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
        if(_mode == "profit")
        {
            if(TodayProfit() >= Limit())
            {
                Print("DAILY PROFIT REACHED: ", TodayProfit());
                return true;
            }
        }
        if(_mode == "loss")
        {
            if(TodayProfit() <= Limit())
            {
                Print("DAILY LOSS REACHED: ", TodayProfit());
                return true;
            }
        }
        return false;
    }

    double Limit()
    {
        if(_limitMode == LimitsByAmount)
        {
            return _limit;
        }
        if(_limitMode == LimitsByAccountPercent)
        {
            return _limit / 100 * AccountInfoDouble(ACCOUNT_BALANCE);
        }
        return 0;
    }

    double TodayProfit()
    {
        datetime iniDay = iTime(NULL, PERIOD_D1, 0);

        double profit = 0;
        for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
            {
                if(OrderCloseTime() >= iniDay)
                {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }

        if(_considerOpen)
        {
            for(int i = OrdersTotal() - 1; i >= 0; i--)
            {
                if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
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

class SendNewOrder : public iActions
{
    private:
    Order* newOrder;

    public:
    SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
    {
        string _symbol = setSymbol(symbol);
        double _price = setPrice(side, price, _symbol);
        int    _type = SetType(side, price, _symbol);
        if(_type == -1)
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
        if(sim == "")
        {
            return Symbol();
        }
        return sim;
    }

    double setPrice(string side, double pr, string sym)
    {
        if(pr == 0)
        {
            if(side == "buy")
            {
                return SymbolInfoDouble(sym, SYMBOL_ASK);
            }
            if(side == "sell")
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

        if(priceClient == 0)
        {
            if(side == "buy")
            {
                return (int) OP_BUY;
            }
            if(side == "sell")
            {
                return (int) OP_SELL;
            }
        }
        else
        {
            if(side == "buy")
            {
                if(priceClient > ask)
                {
                    return (int) OP_BUYSTOP;
                }
                if(priceClient < ask)
                {
                    return (int) OP_BUYLIMIT;
                }
            }
            if(side == "sell")
            {
                if(priceClient > bid)
                {
                    return (int) OP_SELLLIMIT;
                }
                if(priceClient < bid)
                {
                    return (int) OP_SELLSTOP;
                }
            }
        }

        return -1;
    }

    bool doAction()
    {
        color clr = newOrder.type() == OP_BUY ? clrBlue : clrOrange;
        int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, newOrder.sl(), newOrder.tp(), newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clr);

        if(tk < 0)
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
SendNewOrder* actionSendOrder;

// GRID
// ——————————————————————————————————————————————————————————————————
class Grid
{
    ConcurrentConditions conditionsToOpenNewTrade;
    ConcurrentConditions conditionsToCloseGrid;
    ConditionMatchPrice* cdMatchPrice;
    ConditionOrderCount* cdMaxOrders;
    ConditionMaxLot* cdMaxLot;
    SendNewOrder* openTrade;
    // ActionCloseOrdersByType* actionCloseGrid;
    string     _symbol;
    string     _side;
    double     _nextPrice;
    double     _lastPrice;
    double     _gap;
    double     _multiplier;
    int        _maxQnt;
    double     _maxLot;
    double     _initialLot;
    double     _nextLot;
    int        _qnt;
    bool       _active;
    int        _magico;
    OrdersList gridOrders;
    int _id;

    public:
    // NOTE: GRID constructor
    Grid(string Symbol, string Side, double LastPrice, double Gap, double Multiplier, int MaxQnt, double MaxLot, double InitialLot, int magic, bool simbolFilterOn = true, bool magicFilterOn = true, int id = 0)
    {
        _symbol = Symbol;
        _side = Side;
        _lastPrice = LastPrice;
        _gap = Gap;
        _nextPrice = nextPrice(LastPrice);
        _multiplier = Multiplier;
        _maxQnt = MaxQnt + 1;
        _maxLot = MaxLot;
        _initialLot = InitialLot;
        _nextLot = nextLot();
        _magico = magic;
        _id = id;

        Print(_id);
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

        gridOrders.setOrdersList(magicFilterOn, IntegerToString(_magico), simbolFilterOn, _symbol);
        gridOrders.GetLastMarketOrder();

        // Set Conditions:
        cdMatchPrice = new ConditionMatchPrice(_symbol, _side, _nextPrice, 1);
        cdMaxOrders = new ConditionOrderCount(GetPointer(gridOrders), _maxQnt);
        cdMaxLot = new ConditionMaxLot(_maxLot, _nextLot);

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

    int id() { return _id; }

    void lastPrice(int inplastPrice) { _lastPrice = inplastPrice; }
    bool active(void)
    {
        // si la primer orden está en perdidas:
        if(gridOrders.profit(0) < 0)
        {
            _active = true;
        }
        else
        {
            _active = false;
        }
        return _active;
    }
    double nextPrice(double inpLastPrice)
    {
        double mPoint = MarketInfo(_symbol, MODE_POINT);

        if(_side == "buy") _nextPrice = inpLastPrice - (_gap * mPoint * 10);
        if(_side == "sell") _nextPrice = inpLastPrice + (_gap * mPoint * 10);

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
    }
    double nextLot(void)
    {
        return NormalizeDouble(_initialLot * pow(_multiplier, qnt()), 2);
    };

    double profit()
    {
        double gridResult = 0;

        for(int i = 0; i < qnt(); i++)
        {
            if(CheckPointer(gridOrders.index(i)) != POINTER_INVALID)
                gridResult += gridOrders.profit(i);
        }
        return gridResult;
    }

    void doGrid()
    {
        if(conditionsToOpenNewTrade.EvaluateConditions())
        {
            if(_side == "buy")
            {
                openTrade = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), _magico, "grid");
                if(openTrade.doAction())
                {
                    if(gridOrders.GetLastMarketOrder()){ setNextTrade(); }
                }
                delete openTrade;
            }

            if(_side == "sell")
            {
                openTrade = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), _magico, "grid");
                if(openTrade.doAction())
                {
                    if(gridOrders.GetLastMarketOrder()){ setNextTrade(); }
                }
                delete openTrade;
            }
        }
    }

    void setNextTrade()
    {
        nextPrice(gridOrders.last().price());
        // Print(__FUNCTION__, " ", "nextPrice: ", " ", _nextPrice);
        cdMaxLot.lot(nextLot());
        // Print(__FUNCTION__, " ", "nextLot()", " ", nextLot());
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
        if(qnt() == 0)
        {
            return;
        }

        int attempts = 0;
        while(gridOrders.closeAllInList() != 0 || attempts < 10)
        {
            attempts++;
        }
    }
};
Grid* gridBuy [];
Grid* gridSell [];

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
        if(CheckPointer(_grid) != POINTER_INVALID)
        {
            if(_grid.active())
            {
                return false;
            }
        }
        return true;
    }
};
ConditionGridActive* gridActiveCondition;

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
    double _price;

    public:
    ByFixPips(string inpSymbol, string inpSide, int inpPips, string inpMode, double Price = 0)
    {
        _pips = inpPips;
        _symbol = inpSymbol;
        _side = inpSide;
        _mode = inpMode;
        _price = Price;
    }
    ~ByFixPips() { ; }

    double pips() { return _pips; }

    double calculateLevel()
    {
        double mPoint = MarketInfo(_symbol, MODE_POINT);
        double distance = _pips * 10 * mPoint;

        if(_pips == 0)
        {
            return 0;
        }

        if(_mode == "SL")
        {
            distance *= -1;
        }

        if(_side == "buy")
        {
            double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
            double entryPrice = _price == 0 ? ask : _price;
            return entryPrice + distance;
        }

        if(_side == "sell")
        {
            double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);
            double entryPrice = _price == 0 ? bid : _price;
            return entryPrice - distance;
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
        _lot = Lot;
        _symbol = Symbol;
        _side = Side;
        _mode = Mode;
        _money = Money;
    }
    ~ByMoney() { ; }

    double pips()
    {
        double _tickValue = MarketInfo(_symbol, MODE_TICKVALUE);
        double _modeCalc = MarketInfo(_symbol, MODE_PROFITCALCMODE);
        double _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        double _step = MarketInfo(_symbol, MODE_LOTSTEP);
        double _points = MarketInfo(_symbol, MODE_POINT);
        double _digits = MarketInfo(_symbol, MODE_DIGITS);

        // FOREX
        if(_modeCalc == 0)
        {
            // lot = return NormalizeDouble(_money / distance / _tickValue, 2);
            return NormalizeDouble(_money / (_lot * _tickValue), 2);
        }

        // FUTUROS
        if(_modeCalc == 1 && _step != 1.0)
        {
            double c = _contractSize * _step;
            // return NormalizeDouble(_money / (distance * c), 2);
            // lot = _money / (distance * c)
            return NormalizeDouble((_money / c / _lot), 2);
        }

        // FUTUROS SIN DECIMALES
        if(_modeCalc == 1 && _step == 1.0)
        {
            double c = _contractSize * _step;
            // return MathFloor(_money / (distance * c) * 100);
            return MathFloor((_money / c / _lot) / 100);
        }

        return 0;
    }

    double calculateLevel()
    {
        _pips = (int) pips();
        double mPoint = MarketInfo(_symbol, MODE_POINT);
        // double distance = _pips * 10 * mPoint;
        double distance = _pips * mPoint;
        double result = 0;
        double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);

        if(_pips == 0)
        {
            return 0;
        }
        if(_mode == "SL")
        {
            distance *= -1;
        }
        if(_side == "buy")
        {
            return ask + distance;
        }
        if(_side == "sell")
        {
            return bid - distance;
        }
        return -1;
    }
};
class ByPipsFromCandle : public iLevels
{
    string _symbol;
    string _side;
    int    _pips;
    string _mode;  // TP SL
    int    _tfCandle;
    int    _shiftCandle;

    public:
    ByPipsFromCandle(string inpSymbol, string inpSide, int inpPips, string inpMode, int timeFrameCandle, int shiftCandle)
    {
        _pips = inpPips;
        _symbol = inpSymbol;
        _side = inpSide;
        _mode = inpMode;
        _tfCandle = timeFrameCandle;
        _shiftCandle = shiftCandle;
    }
    ~ByPipsFromCandle() { ; }
    double pips()
    {
        return _pips;
    }

    double calculateLevel()
    {
        double mPoint = MarketInfo(_symbol, MODE_POINT);
        double distance = _pips * 10 * mPoint;
        double result = 0;
        double high = iHigh(_symbol, _tfCandle, _shiftCandle);
        double low = iLow(_symbol, _tfCandle, _shiftCandle);

        if(_pips == 0)
        {
            return 0;
        }

        if(_side == "buy")
        {
            if(_mode == "TP") return high + distance;
            if(_mode == "SL") return low - distance;
        }
        if(_side == "sell")
        {
            if(_mode == "TP") return low - distance;
            if(_mode == "SL") return high + distance;
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
        if(CheckPointer(_level) == 1)
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
        if(side == "buy") _type = OP_BUY;
        if(side == "sell") _type = OP_SELL;
        if(symbol == "")
        {
            _symbol = Symbol();
        }
        else
        {
            _symbol = symbol;
        }
        if(magic != 0)
        {
            _magic = magic;
        }
        if(slippage != 10000)
        {
            _slippage = slippage;
        }
    }
    ~ActionCloseOrdersByType() {}

    void setPrice()
    {
        if(_type == OP_BUY)
        {
            _price = SymbolInfoDouble(_symbol, SYMBOL_BID);
        }
        if(_type == OP_SELL)
        {
            _price = SymbolInfoDouble(_symbol, SYMBOL_ASK);
        }
    }

    bool doAction()
    {
        setPrice();
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic && OrderType() == _type)
            {
                if(!OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE))
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

class LotCalculator
{
    double _tickValue;
    double _modeCalc;
    double _contractSize;
    double _step;
    string _symbol;
    double _points;
    double _digits;
    double _min;
    double _max;

    public:
    LotCalculator(string inpSymbol = "") { setSymbol(inpSymbol); };
    ~LotCalculator() { ; }

    void setSymbol(string sym)
    {
        if(sym == "")
        {
            _symbol = Symbol();
        }
        else
        {
            _symbol = sym;
        }
        _tickValue = MarketInfo(_symbol, MODE_TICKVALUE);
        _modeCalc = MarketInfo(_symbol, MODE_PROFITCALCMODE);
        _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        _step = MarketInfo(_symbol, MODE_LOTSTEP);
        _points = MarketInfo(_symbol, MODE_POINT);
        _digits = MarketInfo(_symbol, MODE_DIGITS);
        _min = MarketInfo(_symbol, MODE_MINLOT);
        _max = MarketInfo(_symbol, MODE_MAXLOT);

    }


    double LotsByBalancePercent(double BalancePercent, double Distance)
    {
        double risk = AccountBalance() * BalancePercent / 100;
        return CalculateLots(risk, Distance);
    }

    // NOTE: Equity Lots
    double LotsByEquityPercent(double Percent)
    {
        double lot = 1;
        double marginConsumido = AccountFreeMargin() - AccountFreeMarginCheck(Symbol(), OP_BUY, lot);
        double mcPercent = (marginConsumido / AccountFreeMargin()) * 100;
        double lotsCalc = NormalizeDouble(Percent / mcPercent, 2);

        return CheckLimits(lotsCalc);
    }

    double CheckLimits(double lot)
    {
        double l = lot;
        if(lot < _min) l = _min;
        if(lot > _max) l = _max;
        return l;
    }

    double LotsByMoney(double Money, double Distance)
    {
        double risk = fabs(Money);
        return CalculateLots(risk, Distance);
    }

    double CalculateLots(double risk, double distance)
    {
        distance *= 10;
        if(distance == 0)
        {
            Print(__FUNCTION__, " ", "Set Distance");
            return 0;
        }

        // FOREX
        if(_modeCalc == 0)
        {
            return NormalizeDouble(risk / distance / _tickValue, 2);
        }

        // FUTUROS
        if(_modeCalc == 1 && _step != 1.0)
        {
            double c = _contractSize * _step;
            return NormalizeDouble(risk / (distance * c), 2);
        }

        // FUTUROS SIN DECIMALES
        if(_modeCalc == 1 && _step == 1.0)
        {
            double c = _contractSize * _step;
            return MathFloor(risk / (distance * c) * 100);
        }

        return 0;
    }
};
LotCalculator* lotProvider;

class Session
{
    int _iniTime;  // second from 00:00 hr of the day
    int _endTime;
    int _dayNumber;

    public:
    // receive time in format 00:00
    Session(string iniTime, string endTime, int dayNumber = 0)
    {
        _iniTime = secondsFromZeroHour(iniTime);
        _endTime = secondsFromZeroHour(endTime);
        _dayNumber = dayNumber;
    };

    ~Session() {}

    int iniTime() { return _iniTime; }
    int endTime() { return _endTime; }
    int dayNumber() { return _dayNumber; }

    int secondsFromZeroHour(string time)
    {
        int hh = (int) StringSubstr(time, 0, 2);
        int mm = (int) StringSubstr(time, 3, 2);

        return (hh * 3600) + (mm * 60);
    }
};
class ScheduleController
{
    Session* schedules [];
    int      _actualIndex;
    Session* _actualSession;
    int      _currentDay;
    double   _timeZone;  // modificador para ajustar GMT

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

    void setTimeZone(double hs)
    {
        _timeZone = hs * 60 * 60;
    }

    void setCurrentDay()
    {
        _currentDay = TimeDay(TimeGMT() + _timeZone);  // return the day of the month 1-31
    }

    bool isNewDay()
    {
        if(TimeDay(TimeGMT() + _timeZone) != _currentDay)
        {
            setCurrentDay();
            return true;
        }

        return false;
    }

    void setActualSession(int index)
    {
        _actualIndex = index;

        if(index > -1)
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
        int      t = qnt();
        if(ArrayResize(schedules, t + 1))
        {
            schedules[t] = sc;
            return true;
        }

        return false;
    }

    bool ClearShchedules()
    {
        for(int i = 0; i < qnt(); i++)
        {
            delete schedules[i];
        }
        ArrayFree(schedules);

        return true;
    }

    bool doSessionControl()  // control day and hours for every session
    {
        Comment("Daily Control - EA OFF");

        int actual = (TimeHour(TimeGMT() + _timeZone) * 3600) + (TimeMinute(TimeGMT() + _timeZone) * 60);

        for(int i = 0; i < qnt(); i++)
        {
            if(schedules[i].dayNumber() == EA_OFF)
            {
                continue;
            }

            if(schedules[i].dayNumber() != 0)
            {
                if(schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT() + _timeZone))
                {
                    if((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
                    {
                        setActualSession(i);
                        Comment("Daily Control - EA ON");
                        return true;
                    }
                }
            }

            if(schedules[i].dayNumber() == 0)
            {
                if((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
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
        for(int i = 0; i < qnt(); i++)
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
    m_symbol = Symbol();
    m_tf = Period();
}
CNewCandle::~CNewCandle() {}
bool CNewCandle::IsNewCandle()
{
    int velasActuales = iBars(m_symbol, m_tf);
    if(velasActuales > velasInicio)
    {
        velasInicio = velasActuales;
        return true;
    }

    //---
    return false;
}
CNewCandle* newCandle;





// ------------------------------------------------------------------

int f0_14()
{
    g_low_648 = MarketInfo(Symbol(), MODE_LOW);
    g_high_656 = MarketInfo(Symbol(), MODE_HIGH);
    g_time_664 = MarketInfo(Symbol(), MODE_TIME);
    g_bid_672 = MarketInfo(Symbol(), MODE_BID);
    g_ask_680 = MarketInfo(Symbol(), MODE_ASK);
    gd_688 = 0.0001;
    g_digits_696 = MarketInfo(Symbol(), MODE_DIGITS);
    gd_704 = 5;
    gd_712 = MarketInfo(Symbol(), MODE_STOPLEVEL);
    g_lotsize_720 = MarketInfo(Symbol(), MODE_LOTSIZE);
    g_tickvalue_728 = MarketInfo(Symbol(), MODE_TICKVALUE);
    g_ticksize_736 = MarketInfo(Symbol(), MODE_TICKSIZE);
    g_swaplong_744 = MarketInfo(Symbol(), MODE_SWAPLONG);
    g_swapshort_752 = MarketInfo(Symbol(), MODE_SWAPSHORT);
    g_starting_760 = MarketInfo(Symbol(), MODE_STARTING);
    g_expiration_768 = MarketInfo(Symbol(), MODE_EXPIRATION);
    g_tradeallowed_776 = MarketInfo(Symbol(), MODE_TRADEALLOWED);
    g_minlot_784 = MarketInfo(Symbol(), MODE_MINLOT);
    g_lotstep_792 = MarketInfo(Symbol(), MODE_LOTSTEP);
    if(gi_128 == TRUE) {
        Print("ModeLow:", g_low_648);
        Print("ModeHigh:", g_high_656);
        Print("ModeTime:", g_time_664);
        Print("ModeBid:", g_bid_672);
        Print("ModeAsk:", g_ask_680);
        Print("ModePoint:", gd_688);
        Print("ModeDigits:", g_digits_696);
        Print("ModeSpread:", gd_704);
        Print("ModeStopLevel:", gd_712);
        Print("ModeLotSize:", g_lotsize_720);
        Print("ModeTickValue:", g_tickvalue_728);
        Print("ModeTickSize:", g_ticksize_736);
        Print("ModeSwapLong:", g_swaplong_744);
        Print("ModeSwapShort:", g_swapshort_752);
        Print("ModeStarting:", g_starting_760);
        Print("ModeExpiration:", g_expiration_768);
        Print("ModeTradeAllowed:", g_tradeallowed_776);
        Print("ModeMinLot:", g_minlot_784);
        Print("ModeLotStep:", g_lotstep_792);
    }
    return (0);
}

int f0_7()
{
    double ld_0;
    f0_14();
    if(Money_Management == TRUE) {
        if(gd_264 != OrdersTotal()) ld_0 = (AccountBalance() * Risk - AccountMargin()) * AccountLeverage() / (gd_264 - OrdersTotal());
        else ld_0 = 0;
        if(StringFind(Symbol(), "USD") == -1) {
            if(StringFind(Symbol(), "EUR") == -1) ld_0 = 0;
            else {
                ld_0 /= iClose("EURUSD", PERIOD_M1, 0);
                if(StringFind(Symbol(), "EUR") != 0) ld_0 /= Bid;
            }
        }
        else
            if(StringFind(Symbol(), "USD") != 0) ld_0 /= Bid;
        ld_0 /= g_lotsize_720;
        ld_0 -= g_minlot_784;
        ld_0 /= g_lotstep_792;
        ld_0 = NormalizeDouble(ld_0, 0);
        ld_0 *= g_lotstep_792;
        ld_0 += g_minlot_784;
        Lots = ld_0;
        if(gi_156 == TRUE) Print("Lots:", Lots);
    }
    return (0);
}

// NOTE: oninit
int init()
{

#ifdef TIMER_MINI
    sesionControl.AddSession(timeStart, timeEnd);
#endif
    tsl = new TrailingStop(GetPointer(mainOrders), byPips);

    f0_19();
    f0_14();
    gd_444 = g_period_332 * gd_224;
    if(g_period_332 != 0.0) gd_452 = gd_444 / g_period_332;
    f0_13();
    return (0);
}

int f0_13()
{
    gd_460 = Ask - Bid;
    return (0);
}

int f0_1(int ai_0)
{
    gd_476 = iClose(Symbol(), PERIOD_M1, g_period_332 * ai_0) - iOpen(Symbol(), PERIOD_M1, g_period_332 * ai_0);
    gd_484 = iClose(Symbol(), PERIOD_M1, g_period_332 * (ai_0 + 1)) - iOpen(Symbol(), PERIOD_M1, g_period_332 * (ai_0 + 1));
    gd_512 = 0;
    gd_504 = 0;
    gd_520 = 0;
    if(gd_476 != 0.0) {
        if(gd_476 > 0.0) {
            if(gd_484 < 0.0) {
                gd_468 = 0;
                gd_504 = 0;
                gd_512 = gd_476;
                gd_520 = 0;
            }
            else {
                gd_468 = -1;
                gd_520 = gd_476;
                gd_504 = 0;
                gd_512 = 0;
            }
        }
        else {
            if(gd_484 > 0.0) {
                gd_468 = 1;
                gd_512 = 0;
                gd_520 = 0;
                gd_504 = -1.0 * gd_476;
            }
            else {
                gd_468 = -1;
                gd_520 = -1.0 * gd_476;
                gd_512 = 0;
                gd_504 = 0;
            }
        }
    }
    else {
        gd_468 = -1;
        gd_520 = 0;
        gd_512 = 0;
        gd_504 = 0;
    }
    return (gd_468);
}

int f0_2()
{
    gd_584 = 0;
    gd_576 = 0;
    gd_592 = 0;
    gd_632 = 0;
    gd_624 = 0;
    gd_640 = 0;
    gd_552 = 0;
    gd_560 = 0;
    gd_568 = 0;
    gd_372 = 0;
    gd_380 = 0;
    gd_388 = 0;
    gd_396 = 0;
    gd_412 = 0;
    gd_420 = 0;
    gd_428 = 0;
    gd_436 = 0;
    for(int count_0 = 0; count_0 < gd_452; count_0++) {
        f0_1(count_0);
        if(gd_468 == 0.0) gd_380++;
        if(gd_468 == 1.0) gd_372++;
        if(gd_468 == -1.0) gd_388++;
        if(gd_504 > gd_460 || gd_512 > gd_460 || gd_520 > gd_460) {
            if(gd_468 == 0.0) gd_420++;
            if(gd_468 == 1.0) gd_412++;
            if(gd_468 == -1.0) gd_428++;
        }
        gd_600 *= gd_632;
        gd_632++;
        gd_600 += gd_504;
        if(gd_632 != 0.0) gd_600 /= gd_632;
        else gd_600 = 0;
        gd_608 *= gd_624;
        gd_624++;
        gd_608 += gd_512;
        if(gd_624 != 0.0) gd_608 /= gd_624;
        else gd_608 = 0;
        gd_616 *= gd_640;
        gd_640++;
        gd_616 += gd_520;
        if(gd_640 != 0.0) gd_616 /= gd_640;
        else gd_616 = 0;
        if(gd_504 > gd_460) {
            gd_552 *= gd_584;
            gd_584++;
            gd_552 += gd_504;
            if(gd_584 != 0.0) gd_552 /= gd_584;
            else gd_552 = 0;
        }
        if(gd_512 > gd_460) {
            gd_560 *= gd_576;
            gd_576++;
            gd_560 += gd_512;
            if(gd_576 != 0.0) gd_560 /= gd_576;
            else gd_560 = 0;
        }
        if(gd_520 > gd_460) {
            gd_568 *= gd_592;
            gd_592++;
            gd_568 += gd_520;
            if(gd_592 != 0.0) {
                gd_568 /= gd_592;
                continue;
            }
            gd_568 = 0;
        }
    }
    if(gd_388 + gd_380 + gd_372 != 0.0) gd_396 = (gd_380 + gd_372) / (gd_388 + gd_380 + gd_372);
    else gd_396 = 0;
    if(gd_428 + gd_420 + gd_412 != 0.0) gd_436 = (gd_420 + gd_412) / (gd_428 + gd_420 + gd_412);
    else gd_436 = 0;
    return (0);
}

int f0_0()
{
    if(gi_136 == TRUE) {
        Print("SellPossibilityMid*SellPossibilityQuality:", gd_608 * gd_380);
        Print("BuyPossibilityMid*BuyPossibilityQuality:", gd_600 * gd_372);
        Print("UndefinedPossibilityMid*UndefinedPossibilityQuality:", gd_616 * gd_388);
        Print("UndefinedSucPossibilityQuality:", gd_428);
        Print("SellSucPossibilityQuality:", gd_420);
        Print("BuySucPossibilityQuality:", gd_412);
        Print("UndefinedPossibilityQuality:", gd_388);
        Print("SellPossibilityQuality:", gd_380);
        Print("BuyPossibilityQuality:", gd_372);
        Print("UndefinedSucPossibilityMid:", gd_568);
        Print("SellSucPossibilityMid:", gd_560);
        Print("BuySucPossibilityMid:", gd_552);
        Print("UndefinedPossibilityMid:", gd_616);
        Print("SellPossibilityMid:", gd_608);
        Print("BuyPossibilityMid:", gd_600);
    }
    return (0);
}

int f0_10()
{
    f0_2();
    f0_1(0);
    f0_0();
    return (gd_468);
}

int f0_11()
{
    gi_324 = FALSE;
    gi_328 = FALSE;
    gi_352 = FALSE;
    gi_292 = FALSE;
    gi_296 = FALSE;
    if(gi_184 == TRUE) f0_17();
    if(gi_176 == TRUE) f0_21();
    if(gi_180 == TRUE) f0_20();
    if(gi_196 == TRUE) f0_16();
    return (0);
}

int f0_16()
{
    if((gd_504 > gd_600 * gd_200 && gd_504 != 0.0 && gd_600 != 0.0) || (gd_512 > gd_608 * gd_200 && gd_512 != 0.0 && gd_608 != 0.0)) {
        if(gi_292 == TRUE) gi_292 = FALSE;
        else gi_292 = TRUE;
        if(gi_296 == TRUE) gi_296 = FALSE;
        else gi_296 = TRUE;
        if(gi_324 == TRUE) gi_324 = FALSE;
        else gi_324 = TRUE;
        if(gi_328 == TRUE) gi_328 = FALSE;
        else gi_328 = TRUE;
    }
    return (0);
}

int f0_17()
{
    if(g_period_332 > g_period_340) {
        if(gd_608 * gd_380 > gd_600 * gd_372) {
            gi_292 = FALSE;
            gi_296 = TRUE;
            gi_328 = TRUE;
            if(gd_560 * gd_420 > gd_552 * gd_412) gi_292 = TRUE;
        }
        if(gd_608 * gd_380 < gd_600 * gd_372) {
            gi_292 = TRUE;
            gi_296 = FALSE;
            gi_324 = TRUE;
            if(gd_560 * gd_420 < gd_552 * gd_412) gi_296 = TRUE;
        }
    }
    if(g_period_332 < g_period_340) {
        if(gd_608 * gd_380 > gd_600 * gd_372) {
            gi_292 = TRUE;
            gi_296 = TRUE;
        }
        if(gd_608 * gd_380 < gd_600 * gd_372) {
            gi_292 = TRUE;
            gi_296 = TRUE;
        }
    }
    if(gd_608 * gd_380 == gd_600 * gd_372) {
        gi_292 = TRUE;
        gi_296 = TRUE;
        gi_352 = FALSE;
    }
    if(gd_512 > 2.0 * gd_560 && gd_560 > 0.0) {
        gi_292 = TRUE;
        gi_324 = TRUE;
    }
    if(gd_504 > 2.0 * gd_552 && gd_552 > 0.0) {
        gi_296 = TRUE;
        gi_328 = TRUE;
    }
    if(gi_144 == TRUE) {
        if(gi_292 == TRUE) Print("", gd_608 * gd_380);
        else Print("", gd_608 * gd_380);
        if(gi_296 == TRUE) Print("", gd_600 * gd_372);
        else Print("", gd_600 * gd_372);
    }
    if(gi_140 == TRUE) {
        if(gd_468 == 0.0) Print(" ", gd_476);
        if(gd_468 == 1.0) Print(" ", gd_476);
        if(gd_468 == -1.0) Print(" ", gd_476);
    }
    return (0);
}

int f0_20()
{
    if(iMA(Symbol(), PERIOD_M1, g_period_332, 0, MODE_EMA, PRICE_CLOSE, 0) > iMA(Symbol(), PERIOD_M1, g_period_332, 0, MODE_EMA, PRICE_CLOSE, 1)) {
        gi_292 = TRUE;
        gi_324 = TRUE;
    }
    if(iMA(Symbol(), PERIOD_M1, g_period_332, 0, MODE_EMA, PRICE_CLOSE, 0) < iMA(Symbol(), PERIOD_M1, g_period_332, 0, MODE_EMA, PRICE_CLOSE, 1)) {
        gi_296 = TRUE;
        gi_328 = TRUE;
    }
    return (0);
}

int f0_21()
{
    double ld_unused_0 = 0;
    double ld_8 = 0;
    double ld_16 = 0;
    double ld_unused_24 = 0;
    double ld_unused_32 = 0;
    double ld_unused_40 = 0;
    double ld_unused_48 = 0;
    gi_352 = FALSE;
    gi_324 = FALSE;
    gi_328 = FALSE;
    gi_296 = FALSE;
    gi_292 = FALSE;
    gi_168 = FALSE;
    gi_172 = FALSE;
    for(int li_56 = 0; li_56 < gi_216; li_56++) {
        if(iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 0) < iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 1)) ld_8 += iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 0);
        if(iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 0) > iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 1)) ld_16 += iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 0);
    }
    if(ld_8 > ld_16) {
        gi_296 = TRUE;
        gi_328 = TRUE;
    }
    if(ld_8 < ld_16) {
        gi_292 = TRUE;
        gi_324 = TRUE;
    }
    return (0);
}

int f0_3()
{
    if(gi_348 == FALSE) {
        gd_308 = iHigh(Symbol(), PERIOD_M1, 0) - iLow(Symbol(), PERIOD_M1, 0);
        if(gd_468 == 0.0) {
            if((iClose(Symbol(), PERIOD_M1, 0) - iClose(Symbol(), PERIOD_M1, g_period_332)) / gd_208 >= gd_560 && gd_560 != 0.0 && gi_192 == TRUE) {
                gd_704 += 1.0;
                if(Bid - gd_560 * gd_272 - gd_704 * Point > Bid - gd_712 * gd_688 - gd_704 * Point) g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - gd_308;
                else {
                    if(gd_560 != 0.0) g_price_248 = Bid - gd_560 * gd_272 - gd_704 * Point - gd_308;
                    else g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - gd_308;
                }
                if(gi_152 == TRUE) return (0);
                gd_284 = g_price_248;
                Print("", gd_284);
                if(gi_160 == TRUE) g_price_248 = 0;
                g_price_248 = NormalizeDouble(g_price_248, 4);

                // NOTE: SELL
                g_ticket_492 = OrderSend(Symbol(), OP_SELL, Lots, Ask, g_slippage_240, 0, g_price_256, "chang", magico, 0, clrNONE);

                if(g_ticket_492 > 0) {
                    if(OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print(" ", OrderOpenPrice());
                }
                else {
                    Print(" ", GetLastError());
                    f0_4();
                }
                return (0);
            }
        }
        if(gd_468 == 1.0) {
            if((iClose(Symbol(), PERIOD_M1, g_period_332) - iClose(Symbol(), PERIOD_M1, 0)) / gd_208 >= gd_552 && gd_552 != 0.0 && gi_192 == TRUE) {
                gd_704 += 1.0;
                if(Ask + gd_552 * gd_272 + gd_704 * Point < Ask + gd_712 * gd_688 + gd_704 * Point) g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + gd_308;
                else {
                    if(gd_552 != 0.0) g_price_248 = Ask + gd_552 * gd_272 + gd_704 * Point + gd_308;
                    else g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + gd_308;
                }
                if(gi_148 == TRUE) return (0);
                gd_284 = g_price_248;
                Print("", gd_284);
                if(gi_160 == TRUE) g_price_248 = 0;
                g_price_248 = NormalizeDouble(g_price_248, 4);

                // NOTE: BUY
                g_ticket_492 = OrderSend(Symbol(), OP_BUY, Lots, Bid, g_slippage_240, 0, g_price_256, "chang", magico, 0, Green);

                if(g_ticket_492 > 0) {
                    if(OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print(" ", OrderOpenPrice());
                }
                else {
                    Print("", GetLastError());
                    f0_4();
                }
                return (0);
            }
        }
    }
    return (0);
}

int f0_22()
{
    if(Lots == 0.0) return (0);
    if(gi_120 == FALSE) {
        if(gi_348 == FALSE) {
            gd_308 = iHigh(Symbol(), PERIOD_M1, 0) - iLow(Symbol(), PERIOD_M1, 0);
            if(gd_468 == 0.0) {
                if(gd_512 >= gd_560) {
                    if(Ask + gd_552 * gd_272 + gd_704 * Point < Ask + gd_712 * gd_688 + gd_704 * Point) g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + gd_308;
                    else {
                        if(gd_552 != 0.0) g_price_248 = Ask + gd_552 * gd_272 + gd_704 * Point + gd_308;
                        else g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + gd_308;
                    }
                    if(gi_292 == TRUE) return (0);
                    if(gi_148 == TRUE) return (0);
                    gd_284 = g_price_248;
                    Print("", gd_284);
                    if(gi_160 == TRUE) g_price_248 = 0;
                    g_price_248 = NormalizeDouble(g_price_248, 4);

                    // NOTE: BUY2
                    g_ticket_492 = OrderSend(Symbol(), OP_BUY, Lots, Bid, g_slippage_240, 0, g_price_256, "chang", magico, 0, Green);

                    if(g_ticket_492 > 0) {
                        if(OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print(" ", OrderOpenPrice());
                    }
                    else {
                        Print(" ", GetLastError());
                        f0_4();
                    }
                    return (0);
                }
            }
            if(gd_468 == 1.0) {
                if(gd_504 >= gd_552) {
                    if(Bid - gd_560 * gd_272 - gd_704 * Point > Bid - gd_712 * gd_688 - gd_704 * Point) g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - gd_308;
                    else {
                        if(gd_560 != 0.0) g_price_248 = Bid - gd_560 * gd_272 - gd_704 * Point - gd_308;
                        else g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - gd_308;
                    }
                    if(gi_296 == TRUE) return (0);
                    if(gi_152 == TRUE) return (0);
                    gd_284 = g_price_248;
                    Print("", gd_284);
                    if(gi_160 == TRUE) g_price_248 = 0;
                    g_price_248 = NormalizeDouble(g_price_248, 4);

                    // NOTE: SELL2                    
                    g_ticket_492 = OrderSend(Symbol(), OP_SELL, Lots, Ask, g_slippage_240, 0, g_price_256, "chang", magico, 0, clrNONE);

                    if(g_ticket_492 > 0) {
                        if(OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print("", OrderOpenPrice());
                    }
                    else {
                        Print(" ", GetLastError());
                        f0_4();
                    }
                    return (0);
                }
            }
        }
    }
    return (0);
}

int f0_12()
{
    gi_348 = FALSE;
    g_order_total_496 = OrdersTotal();
    for(g_pos_500 = 0; g_pos_500 < g_order_total_496; g_pos_500++) {
        OrderSelect(g_pos_500, SELECT_BY_POS, MODE_TRADES);
        if(OrderSymbol() == Symbol()) {
            gi_348 = TRUE;
            break;
        }
        gd_284 = 0;
        g_price_248 = 0;
    }
    return (0);
}

int f0_18()
{
    int count_0 = 0;
    f0_12();
    if(Lots == 0.0) return (0);
    gd_308 = 0;
    if(gi_120 == FALSE) {
        if(gi_348 == FALSE) {
            gd_308 = 0;
            gd_316 = 0;
            for(count_0 = 0; count_0 < g_period_332; count_0++) {
                gd_308 = iHigh(Symbol(), PERIOD_M1, count_0 + 1) - iLow(Symbol(), PERIOD_M1, count_0 + 1);
                if(gd_308 > gd_316) gd_316 = gd_308;
            }
            gd_308 = gd_316 * gd_272;
            if(gd_308 == 0.0) gd_308 = gd_712 * Point;
            for(count_0 = 0; count_0 < g_period_332; count_0++) {
                if(Bid - iClose(Symbol(), PERIOD_M1, count_0 + 1) > gd_560 * (count_0 + 1) && gd_560 != 0.0 && gi_352 == FALSE && gi_324 == FALSE) {
                    if(Ask + gd_704 * Point + gd_308 < Ask + gd_712 * gd_688 + gd_704 * Point) g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + Point;
                    else {
                        if(gd_552 != 0.0) g_price_248 = Ask + gd_704 * Point + gd_308 + Point;
                        else g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + Point;
                    }
                    if(gi_148 == TRUE) return (0);
                    if(gi_292 == TRUE) return (0);
                    gd_284 = g_price_248;
                    Print("", gd_284);
                    if(gi_160 == TRUE) g_price_248 = 0;
                    g_price_248 = NormalizeDouble(g_price_248, 4);

                    // NOTE: BUY3
                    g_ticket_492 = OrderSend(Symbol(), OP_BUY, Lots, Bid, g_slippage_240, 0, g_price_256, "chang", magico, 0, Green);

                    if(g_ticket_492 > 0) {
                        if(OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print("", OrderOpenPrice());
                    }
                    else {
                        Print(" ", GetLastError());
                        f0_4();
                    }
                    return (0);
                }
                if(iClose(Symbol(), PERIOD_M1, count_0 + 1) - Bid > gd_552 * (count_0 + 1) && gd_552 != 0.0 && gi_352 == FALSE && gi_328 == FALSE) {
                    if(Bid - gd_704 * Point - gd_308 > Bid - gd_712 * gd_688 - gd_704 * Point) g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - Point;
                    else {
                        if(gd_560 != 0.0) g_price_248 = Bid - gd_704 * Point - gd_308 - Point;
                        else g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - Point;
                    }
                    if(gi_296 == TRUE) return (0);
                    if(gi_152 == TRUE) return (0);
                    gd_284 = g_price_248;
                    Print("", gd_284);
                    if(gi_160 == TRUE) g_price_248 = 0;
                    g_price_248 = NormalizeDouble(g_price_248, 4);

                    // NOTE: SELL3
                    g_ticket_492 = OrderSend(Symbol(), OP_SELL, Lots, Ask, g_slippage_240, 0, g_price_256, "chang", magico, 0, clrNONE);

                    if(g_ticket_492 > 0) {
                        if(OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print(" ", OrderOpenPrice());
                    }
                    else {
                        Print(" ", GetLastError());
                        f0_4();
                    }
                    return (0);
                }
            }
        }
    }
    return (0);
}

int f0_6()
{
    if(gi_348 == TRUE) {
        if(OrderType() == OP_SELL) {
            if(Bid + 1000.0 * Point <= gd_284 && gi_164 == FALSE && gd_284 != 0.0) {
                OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
                return (0);
            }
            if(gi_172 == TRUE) return (0);
            if(OrderOpenPrice() + 1000.0 * Point < Bid) {
                OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
                return (0);
            }
            if(iClose(Symbol(), PERIOD_M1, 0) - iClose(Symbol(), PERIOD_M1, 1) >= 4.0 * gd_560 && gd_560 > 0.0) return (0);
            if(OrderOpenPrice() + 1000.0 * Point < Bid && Bid - OrderOpenPrice() + 1000.0 * Point >= gd_560 && gd_560 > 0.0) {
                OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
                return (0);
            }
            if(OrderOpenPrice() + 1000.0 * Point < Bid && Bid - OrderOpenPrice() + 1000.0 * Point >= gd_552 && gd_552 > 0.0) {
                OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
                return (0);
            }
            if(gd_468 == 0.0) {
                if(OrderOpenPrice() + 1000.0 * Point < Bid) {
                    if(gd_512 >= gd_608 - Point) {
                        OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
                        return (0);
                    }
                }
            }
            if(OrderOpenPrice() + 1000.0 * Point < Bid && Bid - OrderOpenPrice() + 1000.0 * Point >= gd_616) {
                OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
                return (0);
            }
            if(gd_468 == 1.0) return (0);
        }
        if(OrderType() == OP_BUY) {
            if(Ask - 1000.0 * Point >= gd_284 && gi_164 == FALSE && gd_284 != 0.0) {
                OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
                return (0);
            }
            if(gi_168 == TRUE) return (0);
            if(OrderOpenPrice() - 1000.0 * Point > Ask) {
                OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
                return (0);
            }
            if(iClose(Symbol(), PERIOD_M1, 1) - iClose(Symbol(), PERIOD_M1, 0) >= 4.0 * gd_552 && gd_552 > 0.0) return (0);
            if(OrderOpenPrice() - 1000.0 * Point > Ask && OrderOpenPrice() - 1000.0 * Point - Ask >= gd_552 && gd_552 > 0.0) {
                OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
                return (0);
            }
            if(OrderOpenPrice() - 1000.0 * Point > Ask && OrderOpenPrice() - 1000.0 * Point - Ask >= gd_560 && gd_560 > 0.0) {
                OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
                return (0);
            }
            if(gd_468 == 1.0) {
                if(OrderOpenPrice() - 1000.0 * Point > Ask) {
                    if(gd_504 >= gd_600 - Point) {
                        OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
                        return (0);
                    }
                }
            }
            if(OrderOpenPrice() - 1000.0 * Point > Ask && OrderOpenPrice() - 1000.0 * Point - Ask >= gd_616) {
                OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
                return (0);
            }
            if(gd_468 == 0.0) return (0);
        }
    }
    return (0);
}

int f0_9()
{
    gd_unused_356 = Bid;
    gd_unused_364 = Ask;
    g_period_340 = g_period_332;
    return (0);
}

int f0_5()
{
    f0_12();
    f0_11();
    f0_15();
    if(gi_348 == FALSE) {
        if(gi_192 == TRUE) f0_3();
        if(gi_188 == TRUE) f0_22();
        if(gi_352 == FALSE) f0_18();
    }
    else f0_6();
    return (0);
}

int f0_19()
{
    if(gi_132 == TRUE) {
        Print("AccountBalance:", AccountBalance());
        Print("AccountCompany:", AccountCompany());
        Print("AccountCredit:", AccountCredit());
        Print("AccountCurrency:", AccountCurrency());
        Print("AccountEquity:", AccountEquity());
        Print("AccountFreeMargin:", AccountFreeMargin());
        Print("AccountLeverage:", AccountLeverage());
        Print("AccountMargin:", AccountMargin());
        Print("AccountName:", AccountName());
        Print("AccountNumber:", AccountNumber());
        Print("AccountProfit:", AccountProfit());
    }
    return (0);
}

int f0_8()
{
    double ld_0 = (-1.0 * gd_232) * gd_232;
    double ld_ret_8 = 0;
    for(int count_16 = 0; count_16 < gd_232; count_16++) {
        g_period_332 = count_16 + 1;
        gd_224 = 5.0 * g_period_332;
        init();
        f0_2();
        if(gd_436 > ld_0) {
            ld_0 = gd_436;
            ld_ret_8 = count_16 + 1;
        }
    }
    g_period_332 = ld_ret_8;
    init();
    if(gi_124 == TRUE) Print("", ld_ret_8, " ", ld_0);
    return (ld_ret_8);
}

int f0_15()
{
    if(gi_280 == TRUE) gd_272 = gd_704;
    return (0);
}

int f0_4()
{
    Print("ErrorValues:Symbol=", Symbol(), ",Lots=", Lots, ",Bid=", Bid, ",Ask=", Ask, ",SlipPage=", g_slippage_240, "StopLoss=", g_price_248, ",TakeProfit=", g_price_256);
    return (0);
}

int start()
{

    mainOrders.cleanCloseOrders();

    // if(mainOrders.GetMarketOrders())
    if(mainOrders.GetLastMarketOrder())
        CheckearOrdernesyGenerarGrids();

    if(GridON)
    {
        for(int i = 0; i < ArraySize(gridSell); i++) {
            if(CheckPointer(gridSell[i]) == POINTER_INVALID) continue;
            gridSell[i].doGrid();
        }
        for(int i = 0; i < ArraySize(gridBuy); i++) {
            if(CheckPointer(gridBuy[i]) == POINTER_INVALID) continue;
            gridBuy[i].doGrid();
        }
        mainOrders.GetMarketOrders();
    }

    if(GridON == true && closeGridOn == true)
    {
        doCloseGridControl();
    }

    if(TslON) tsl.doTSL();
    if(!sesionControl.doSessionControl()) { return 0; }


    //--- funciones originales
    f0_14();
    f0_7();
    f0_13();
    f0_8();
    f0_10();
    f0_5();
    f0_9();



    return (0);
}

void CheckearOrdernesyGenerarGrids()
{
    if(mainOrders.last().type() == OP_BUY) // && CheckPointer(gridBuy) == POINTER_INVALID)
    {
        int t = ArraySize(gridBuy);
        if(ArrayResize(gridBuy, t + 1))
        {
            gridBuy[t] = new Grid(_Symbol, "buy", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico, true, true, mainOrders.last().id());
            Print("se cargó la grid BUY: ", gridBuy[t].id());
        }
    }
    if(mainOrders.last().type() == OP_SELL)//  && CheckPointer(gridSell) == POINTER_INVALID)
    {
        int t = ArraySize(gridSell);
        if(ArrayResize(gridSell, t + 1))
        {
            gridSell[t] = new Grid(_Symbol, "sell", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico, true, true, mainOrders.last().id());
            Print("se cargó la grid SELL: ", gridSell[t].id());
        }
    }
}

void deleteGrids()
{
    for(int i = 0; i < ArraySize(gridSell); i++) {
        if(CheckPointer(gridSell[i]) == POINTER_INVALID) continue;
        gridSell[i].closeGrid();
        delete  gridSell[i];
    }
    for(int i = 0; i < ArraySize(gridBuy); i++) {
        if(CheckPointer(gridBuy[i]) == POINTER_INVALID) continue;
        gridBuy[i].closeGrid();
        delete gridBuy[i];
    }
}

void CloseGrid(int id)
{
    for(int i = 0; i < ArraySize(gridSell); i++) {
        if(CheckPointer(gridSell[i]) == POINTER_INVALID) continue;

        if(gridSell[i].id() == id)
        {
            int id = gridSell[i].id();
            Print(__FUNCTION__, " se CERRO LA GRID id: ", id);

            gridSell[i].closeGrid();
            delete  gridSell[i];
        }

    }

    for(int i = 0; i < ArraySize(gridBuy); i++) {
        if(CheckPointer(gridBuy[i]) == POINTER_INVALID) continue;

        if(gridBuy[i].id() == id)
        {
            int id = gridBuy[i].id();
            Print(__FUNCTION__, " se CERRO LA GRID id: ", id);

            gridBuy[i].closeGrid();
            delete gridBuy[i];
        }
    }
}

void doCloseGridControl()
{
    if(closeGridTP > 0)
    {
        for(int i = 0; i < ArraySize(gridBuy); i++) {
            if(CheckPointer(gridBuy[i]) != POINTER_INVALID)
                if(gridBuy[i].profit() >= closeGridTP) { CloseGrid(gridBuy[i].id()); }
        }

        for(int i = 0; i < ArraySize(gridSell); i++) {
            if(CheckPointer(gridSell[i]) != POINTER_INVALID)
                if(gridSell[i].profit() >= closeGridTP) { CloseGrid(gridSell[i].id()); }
        }

        if(closeGridSL < 0)
        {
            for(int i = 0; i < ArraySize(gridBuy); i++) {
                if(CheckPointer(gridBuy[i]) != POINTER_INVALID)
                    if(gridBuy[i].profit() <= closeGridSL) { CloseGrid(gridBuy[i].id()); }
            }
            for(int i = 0; i < ArraySize(gridSell); i++) {
                if(CheckPointer(gridSell[i]) != POINTER_INVALID)
                    if(gridSell[i].profit() <= closeGridSL) { CloseGrid(gridSell[i].id()); }
            }
        }
    }
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//| USDT Donations                                                                                 |
//+------------------------------------------------+-----------------------------------------------+
//| Network                                        |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+