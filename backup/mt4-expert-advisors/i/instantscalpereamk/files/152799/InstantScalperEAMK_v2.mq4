//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74219

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

int Magic = 888;                       // Magic Number
int magico = Magic;

#define PENDING_ENTRYS
enum ModeEntry {
    Market,
    Pending
};

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
        int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, newOrder.sl(), newOrder.tp(), newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);

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

class ActionDeletePendings : public iActions
{
    string _symbol;
    int    _magic;
    string _side;
    int _candles; 

    public:
    ActionDeletePendings(string side, int magic = 0, string symbol = "", int candles = 0)
    {
        _side = side;
        _symbol = symbol == "" ? Symbol() : symbol;
        _magic = magic != 0 ? magic : 0;
        _candles = candles;
    }
    ~ActionDeletePendings() {}

    bool doAction()
    {
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic)
            {
                if(_side == "buy" && (OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT))
                {
                    if(OrderOpenTime() < (TimeCurrent() - _candles * CandleSeconds()))
                        OrderDelete(OrderTicket());
                }
                if(_side == "sell" && (OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT))
                {
                    if(OrderOpenTime() < (TimeCurrent() - _candles * CandleSeconds()))
                        OrderDelete(OrderTicket());
                }
            }
        }
        return true;
    }
};
ActionDeletePendings* actionDeletePendingsBuys;
ActionDeletePendings* actionDeletePendingsSells;

#ifdef PENDING_ENTRYS
input string    Tpom = "== Pending or Market Setup ==";  // ————————————
input ModeEntry modeEntry = Market;                      // Mode Entry:
input double    uEntryDistance = 10;                     // Pips distance for pending orders:
input bool      uDeletePendingsOn = true;                // Delete pendings after #Candles:
input int pendingOrderLife = 5; // #Candles to Delete Pending Orders:
#endif

//=================== Security ===================
bool     UseAccNumber = false;
const long allowed_accounts [] =
{
    6904916,
    10501881,
    235617,
    9845450,
};

bool     UseMultinames = false;
const string allowednames [] =
{
    "Mehulbhai Patel",
    "Steven Chandra",

};
bool     UseExpiry = false;
datetime expiryDate = D'2022.8.15 09:38';

bool     UseAccName = false;
string   Account_Name = "Name";//Case Sensitive

bool     UsePassword = false;
string   Password_ = "abcd";
//================= End of Security ===============

input string                  Password = "";
bool validAccount;
bool validAccount1;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
enum ENUM_TP_MODE { Basket = 0, Individual = 1 };
enum ENUM_CLOSE_OUT_STYLE { BE = 0/*Break_Even*/, Profit = 1 };
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx external variables xxx//
extern string settings = "=====Time Settings=====";
extern int Corner = 3;
extern int Signal = 1;
extern int SL_pips = 90;
extern bool AlertON = TRUE;
extern bool Email = TRUE;
extern int sipk = 8;
input string Start_Hour = "00:01";
input string End_Hour = "23:59";
extern int TakeProfit = 30;
extern int StopLoss = 0;

input string         Trailing_Stop________________ = "Trailing _Stop______________";
input double         TrailingStop = 10;
input double         TrailingStep = 10;
ENUM_TP_MODE         TP_Mode = Individual;                // TP Mode
input double         Lot_Size = 0.05;                      // Lot Size
double               TP_money = 0;                     // TP ( IN $ )
double               SL_money = 0;                     // SL ( IN $ )
double               Trail_TP = 0;                     // Trail TP ( IN $ )
double               Trail_Step = 0;                      // Trail Step ( IN $ )
double               Break_Even = 0;                     // Break Even ( IN $ )
input string         Custom_Ind_Name = "Instantscalper5";                       // Custom Indicator Name
input int            Buy_Buffer_NO = 2;                         // Buy Buffer NO
input int            Sell_Buffer_NO = 3;                         // Sell Buffer NO
bool                 UseBreakEven = false;                     // Use Break Even
bool                 UseTrailingStop = false;                     // Use Trailing Stop
input bool           UseCloseOnOppSign = false;                     // Use Close On Opposite Signal
bool                 UseCloseOut = false;                     // Use Close Out
int                  CloseOutTradesLevel = 200;                       // Close Out Trades Level
ENUM_CLOSE_OUT_STYLE CloseOutStyle = BE;                        // Close Out Style

/*input*/ int              Slippage = 10;                        // 
/*input*/ ENUM_TIMEFRAMES  Tf = PERIOD_CURRENT;            // 
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx global variables xxx//
datetime
timePrev;
double pips;
double
SL, TP, MaxProfitTrail,
TickSize, TickValue, Spread, StopLevel, MinLot, MaxLot, LotStep, Pnt;
int
order_type, T, nT, T_CloseOut,
nBO, nSO, nBS, nSS, nBL, nSL, nO, nS, nL, _nBO, _nSO, _nBS, _nSS, _nBL, _nSL, _nO, _nS, _nL, Slip;
bool
IsProfitBE, CloseContinue,
Ans, _Ans, Activate, FatalError, FreeMarginAlert, IsModify, IsTester, IsVisual;
int
tickets [];
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx The initialization function of the expert xxx//
int OnInit()
{
    if(UseExpiry && TimeCurrent() > expiryDate) { Alert("Expired, Please Contact telegram @bullionstrategy ");ExpertRemove();return(INIT_FAILED); }
    if(UseAccName && AccountName() != Account_Name) { Alert("Invalid name, Please Contact ");ExpertRemove();return(INIT_FAILED); }
    if(UsePassword && Password_ != Password) { Alert("Invalid password, Please Contact ");ExpertRemove();return(INIT_FAILED); }

    if(UseAccNumber) {
        for(int i = 0;i < ArraySize(allowed_accounts);i++){
            if(allowed_accounts[i] == AccountInfoInteger(ACCOUNT_LOGIN)){
                validAccount = true;
            }
        }
        if(!validAccount){
            Alert("Invalid account");
            ExpertRemove();
            return(INIT_FAILED);
        }
    }
    if(UseMultinames) {
        for(int jk = 0;jk < ArraySize(allowednames);jk++){
            if(allowednames[jk] == AccountName()){
                validAccount1 = true;
            }
        }
        if(!validAccount){
            Alert("Invalid account");
            ExpertRemove();
            return(INIT_FAILED);
        }
    }
    double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
    if(ticksize == 0.00001 || ticksize == 0.001)
        pips = ticksize * 10;
    else pips = ticksize;
    Activate = false; FatalError = false;

    //if( TimeCurrent() >= StringToTime( "2021.12.20 00:00" ) ) { Alert("The EA has expired !");  return( INIT_SUCCEEDED ); }

    if(IsTesting() || IsOptimization() || IsVisualMode()) IsTester = true; else IsTester = false;
    if(IsOptimization() || (IsTesting() && !IsVisualMode())) IsVisual = false; else IsVisual = true;
    Pnt = pips();  Slip = Slippage;

    GetMarketInfo();
    HistoryCheck();

    timePrev = iTime(_Symbol, Tf, 0);

    if(IsTester || !GVC("CloseContinue"))
    {
        CloseContinue = false;
        T_CloseOut = -1;
        MaxProfitTrail = 0.0;
        IsProfitBE = false;

        if(!IsTester)
        {
            GVS("MaxProfitTrail", MaxProfitTrail);
            GVS("CloseContinue", (double) CloseContinue);  GVS("T_CloseOut", (double) T_CloseOut);  GVS("IsProfitBE", (double) IsProfitBE);
        }
    }

    Activate = true;
    return(INIT_SUCCEEDED);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx The deinitialization function of the expert xxx//
void OnDeinit(const int reason)
{
    Comment("");

    if(!IsTester)
    {
        if(reason == 0 || reason == 1)
        {
            GVD("MaxProfitTrail"); GVD("CloseContinue"); GVD("T_CloseOut"); GVD("IsProfitBE");

            if(ObjectFind(0, "TSL_lev") >= 0) { ObjectDelete(0, "TSL_lev");  ChartRedraw(); }

            ArrayFree(tickets);
        }
    }

}

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx The main function of the expert xxx//
void OnTick()
{
    if(!Activate || FatalError) return;
    if(!IsTester) GetMarketInfo();
    HistoryCheck(3, 333);

    //xxxxx
    if(!IsTester) CloseContinue = (bool) GVG("CloseContinue");
    if(CloseContinue)
    {
        if(ClosePos()) { CloseContinue = false;  if(!IsTester) { GVS("CloseContinue", (double) CloseContinue); GlobalVariablesFlush(); } }
        else return;
    }

    //xxxxx
    if(!IsTester) T_CloseOut = (int) GVG("T_CloseOut");
    if(T_CloseOut != -1)
    {
        if(CloseByTicket(T_CloseOut)) { T_CloseOut = -1;  if(!IsTester) { GVS("T_CloseOut", (double) T_CloseOut); GlobalVariablesFlush(); } }
    }

    if(TimeFilter(Start_Hour, End_Hour) == true)
    {
        Trade();
    }
    if(TrailingStop > 0 && Orderscnt() >= 1)MoveTrailingStop();
    //xxxxx
    getTickets();
    _numbOrders();

    //xxxxx
    if(nO > 0)
    {
        if(UseCloseOut)
            CloseOut();

        //xxxxx   
        if(TP_Mode == Individual)
        {
            if(SL_money > 0.0 || TP_money > 0.0)
                Check_SL_TP();



        }

        //xxxxx
        else
            if(TP_Mode == Basket)
            {
                if(SL_money > 0.0 || TP_money > 0.0)
                {
                    Check_SL_TP_basket();
                    if(CloseContinue || nO <= 0) return;
                }

                if(UseBreakEven)
                {
                    Breakeven_basket();
                    if(CloseContinue || nO <= 0) return;
                }

                if(UseTrailingStop)
                {
                    Trail_basket();
                    if(CloseContinue || nO <= 0) return;
                }
            }
    }

    //xxxxx
    else
        if(nO <= 0)
        {
            if(TP_Mode == Basket)
            {
                if(UseBreakEven && !IsTester) IsProfitBE = (bool) GVG("IsProfitBE");
                if(UseBreakEven && IsProfitBE)
                {
                    IsProfitBE = false;  if(!IsTester) { GVS("IsProfitBE", (double) IsProfitBE); GlobalVariablesFlush(); }
                }

                if(UseTrailingStop && !IsTester) MaxProfitTrail = GVG("MaxProfitTrail");
                if(UseTrailingStop && MaxProfitTrail > 0.0)
                {
                    MaxProfitTrail = 0.0;  if(!IsTester) { GVS("MaxProfitTrail", MaxProfitTrail); GlobalVariablesFlush(); }
                }
            }
        }

    //xxxxx
    if(IsVisual && TP_Mode == Basket && UseTrailingStop) TSL_info();


    // ------------------------------------------------------------------

    if(uDeletePendingsOn) ControlDeletePendings();

}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Trade()
{
    int sign = GetSign();

    if(sign == 1) order_type = OP_BUY; else if(sign == -1) order_type = OP_SELL; else return;

    if(UseCloseOnOppSign)
    {
        getTickets(); _numbOrders();

        if((sign == 1 && nSO > 0) || (sign == -1 && nBO > 0))
        {
            if(!ClosePos(sign == 1 ? OP_SELL : OP_BUY))   return;
        }
    }

    if(modeEntry == Market)
    {
        if(MO(order_type, Lot_Size) == -1) return;
    }
    else
    {
        // NOTE: pending buy
        if(order_type == OP_BUY)
        {
            // double pr = Price("buy", uEntryDistance, _Symbol);
            double pr = iHigh(Symbol(), 0, 1) + (uEntryDistance * pips);
            actionSendOrder = new SendNewOrder("buy", NL(Lot_Size), "", pr, SL("buy", pr), TP("buy", pr), magico);
            actionSendOrder.doAction();
            delete actionSendOrder;
        }

        if(order_type == OP_SELL)
        {
            // double pr = Price("sell", uEntryDistance, _Symbol);
            double pr = iLow(Symbol(), 0, 1) - (uEntryDistance * pips);
            actionSendOrder = new SendNewOrder("sell", NL(Lot_Size), "", pr, SL("sell", pr), TP("sell", pr), magico);
            actionSendOrder.doAction();
            delete actionSendOrder;
        }


    }


    timePrev = iTime(_Symbol, Tf, 0);


}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
int GetSign()
{
    if(timePrev == iTime(_Symbol, Tf, 0)) return(0);

    double i_val = 0.0;

    i_val = i_custom(Buy_Buffer_NO, 1);  if(i_val > 0.0 && i_val != EMPTY_VALUE) return(1);

    i_val = i_custom(Sell_Buffer_NO, 1);  if(i_val > 0.0 && i_val != EMPTY_VALUE) return(-1);

    timePrev = iTime(_Symbol, Tf, 0);
    return(0);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double i_custom(int buf, int bar) { return(iCustom(_Symbol, Tf, Custom_Ind_Name, Corner, Signal, SL_pips, AlertON, Email, sipk, buf, bar)); }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void CloseOut()
{
    if(nO < CloseOutTradesLevel || nBO <= 0 || nSO <= 0) return;

    int
        i = 0, j = 0, t_buy = -1, t_sell = -1;
    double
        pf = 0.0, pf_buy = 0.0, pf_sell = 0.0;


    if(CloseOutStyle == BE)
    {
        for(i = 0; i < nT; i++)
        {
            if(!OrderSelect(tickets[i], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() != OP_BUY) continue;

            pf_buy = (OrderProfit() + OrderCommission() + OrderSwap());

            for(j = 0; j < nT; j++)
            {
                if(!OrderSelect(tickets[j], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() != OP_SELL) continue;

                pf_sell = (OrderProfit() + OrderCommission() + OrderSwap());

                if(pf == 0 || fabs(pf_buy + pf_sell) < pf)
                {
                    pf = fabs(pf_buy + pf_sell);
                    t_buy = tickets[i];
                    t_sell = tickets[j];
                }
            }//for
        }//for
    }

    else
        if(CloseOutStyle == Profit)
        {
            for(i = 0; i < nT; i++)
            {
                if(!OrderSelect(tickets[i], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() > 1) continue;

                pf = (OrderProfit() + OrderCommission() + OrderSwap());

                if(OrderType() == OP_BUY && (pf_buy == 0.0 || pf > pf_buy))
                {
                    pf_buy = pf;
                    t_buy = tickets[i];
                }

                else
                    if(OrderType() == OP_SELL && (pf_sell == 0.0 || pf > pf_sell))
                    {
                        pf_sell = pf;
                        t_sell = tickets[i];
                    }
            }
        }


    if(t_buy != -1 && t_sell != -1)
    {
        if(CloseByTicket(t_buy))
        {
            if(CloseByTicket(t_sell))
            {
                if(T_CloseOut != -1) T_CloseOut = -1;
            }
            else
                T_CloseOut = t_sell;

            if(!IsTester) { GVS("T_CloseOut", (double) T_CloseOut); GlobalVariablesFlush(); }

            getTickets();
            _numbOrders();
        }
    }

}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Check_SL_TP_basket()
{
    double curr_result = GetCurrResultBasket();

    if((SL_money != 0.0 && curr_result <= -fabs(SL_money)) || (TP_money > 0.0 && curr_result >= TP_money))
    {
        CloseContinue = true;  if(ClosePos()) CloseContinue = false;

        if(!IsTester) { GVS("CloseContinue", (double) CloseContinue); GlobalVariablesFlush(); }

        getTickets();
        _numbOrders();

    }
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Breakeven_basket()
{
    if(!IsTester) IsProfitBE = (bool) GVG("IsProfitBE");

    if(!IsProfitBE && GetCurrResultBasket() >= Break_Even)
    {
        IsProfitBE = true;
        if(!IsTester) { GVS("IsProfitBE", (double) IsProfitBE); GlobalVariablesFlush(); }
    }

    else
        if(IsProfitBE)
        {
            double money_lev_be = 0.0, lots_diff = CurrLotsDiffBuySell_basket();

            if(lots_diff > 0.0 && tickValue() > 0.0) money_lev_be = tickValue() * lots_diff;

            if(GetCurrResultBasket() <= money_lev_be)
            {
                CloseContinue = true;  if(ClosePos()) CloseContinue = false;

                if(!CloseContinue)
                {
                    IsProfitBE = false;
                    if(!IsTester) { GVS("IsProfitBE", (double) IsProfitBE); GlobalVariablesFlush(); }
                }

                if(!IsTester) { GVS("CloseContinue", (double) CloseContinue); GlobalVariablesFlush(); }

                getTickets();
                _numbOrders();
            }
        }

}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Trail_basket()
{
    if(!IsTester) MaxProfitTrail = GVG("MaxProfitTrail");

    double curr_result_basket = GetCurrResultBasket();

    if(MaxProfitTrail <= 0.0 && curr_result_basket >= Trail_TP)
    {
        MaxProfitTrail = curr_result_basket;
        if(!IsTester) { GVS("MaxProfitTrail", MaxProfitTrail); GlobalVariablesFlush(); }
    }

    else
        if(MaxProfitTrail > 0.0 && curr_result_basket > MaxProfitTrail)
        {
            MaxProfitTrail = curr_result_basket;
            if(!IsTester) { GVS("MaxProfitTrail", MaxProfitTrail); GlobalVariablesFlush(); }
        }

        else
            if(MaxProfitTrail > 0.0 && curr_result_basket <= MaxProfitTrail - Trail_Step)
            {
                CloseContinue = true;  if(ClosePos()) CloseContinue = false;

                if(!CloseContinue)
                {
                    MaxProfitTrail = 0.0;
                    if(!IsTester) { GVS("MaxProfitTrail", MaxProfitTrail); GlobalVariablesFlush(); }
                }

                if(!IsTester) { GVS("CloseContinue", (double) CloseContinue); GlobalVariablesFlush(); }

                getTickets();
                _numbOrders();
            }
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Check_SL_TP()
{
    int
        i = 0;
    color
        c = clrNONE;
    double
        sl = 0.0, tp = 0.0, sl_lev = 0.0, tp_lev = 0.0, comm_and_swap = 0.0, comm_swap_pnt = 0.0;

    for(i = 0; i < nT; i++)
    {
        if(!OrderSelect(tickets[i], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() > 1) continue;

        comm_and_swap = (OrderCommission() + OrderSwap());

        comm_swap_pnt = 0.0;
        if(comm_and_swap < 0.0 && tickValue() > 0.0 && tickSize() > 0.0 && pips() > 0.0)
        {
            comm_swap_pnt = fabs(comm_and_swap) / (tickValue() * OrderLots()) * (tickSize() / pips());
            comm_swap_pnt = MathCeil(comm_swap_pnt);
        }

        if(SL_money > 0.0) sl = SL_money / (tickValue() * OrderLots()) * (tickSize() / pips()) - comm_swap_pnt; else sl = 0.0;

        if(TP_money > 0.0) tp = TP_money / (tickValue() * OrderLots()) * (tickSize() / pips()) + comm_swap_pnt; else tp = 0.0;

        if(OrderType() == OP_BUY)
        {
            if(OrderStopLoss() > 0.0 && OrderStopLoss() >= OrderOpenPrice())
                sl_lev = OrderStopLoss();
            else
                sl_lev = sl > 0.0 ? OrderOpenPrice() - sl * Pnt : 0.0;

            tp_lev = tp > 0.0 ? OrderOpenPrice() + tp * Pnt : 0.0;

            if((tp_lev > 0.0 && tp_lev - Bid < _stopLevel()) || (sl_lev > 0.0 && Bid - sl_lev < _stopLevel()))  continue;

            c = clrBlue;
        }

        else
            if(OrderType() == OP_SELL)
            {
                if(OrderStopLoss() > 0.0 && OrderStopLoss() <= OrderOpenPrice())
                    sl_lev = OrderStopLoss();
                else
                    sl_lev = sl > 0.0 ? OrderOpenPrice() + sl * Pnt : 0.0;

                tp_lev = tp > 0.0 ? OrderOpenPrice() - tp * Pnt : 0.0;

                if((tp_lev > 0.0 && Ask - tp_lev < _stopLevel()) || (sl_lev > 0.0 && sl_lev - Ask < _stopLevel())) continue;

                c = clrRed;
            }


    }
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
int getTickets()
{
    int
        j = 0, n = 0, pos = 0;

    ArrayResize(tickets, 1, 10); ArrayInitialize(tickets, -1);

    for(pos = OrdersTotal() - 1;pos >= 0;pos--)
    {
        for(j = 0;j < 10;j++){ if(OrderSelect(pos, SELECT_BY_POS))break;/*=>*/if(j < 9)Sleep(100); }/*for =>*/if(j == 10)continue;

        if(OrderSymbol() != _Symbol || OrderMagicNumber() != Magic)continue;

        ArrayResize(tickets, n + 1, 10); tickets[n] = OrderTicket(); n++;
    }//for

    nT = n;
    return(n);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void _numbOrders(int i = 0)
{
    nBO = 0;nSO = 0;nBS = 0;nSS = 0;nBL = 0;nSL = 0;nO = 0;nS = 0;nL = 0;
    int
        j = 0, pos = 0;
    nT = getTickets();
    for(pos = 0;pos < nT;pos++) {
        for(j = 0;j < 10;j++){ if(OrderSelect(tickets[pos], SELECT_BY_TICKET))break;/*=>*/if(j < 9)Sleep(100); }/*for =>*/if(j == 10)continue;
        if(OrderCloseTime() != 0)continue;

        switch(OrderType()){
            case 0: nBO++; break;  case 1: nSO++; break;
            case 2: nBL++; break;  case 3: nSL++; break;
            case 4: nBS++; break;  case 5: nSS++; break;
        }/*switch*/
    }//for  

    nO = nBO + nSO; nS = nBS + nSS; nL = nBL + nSL;

    if(i == 0) return; else

        if(i == 1) { _nBO = nBO; _nSO = nSO; _nBS = nBS; _nSS = nSS; _nBL = nBL; _nSL = nSL; _nO = nO; _nS = nS; _nL = nL; }
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double GetCurrResultBasket()
{
    double curr_profit_basket = 0.0;

    for(int i = 0; i < nT; i++)
    {
        if(!OrderSelect(tickets[i], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() > 1) continue;

        curr_profit_basket += (OrderProfit() + OrderCommission() + OrderSwap());
    }

    return(curr_profit_basket);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double CurrLotsDiffBuySell_basket()
{
    double curr_lots_buy = 0.0, curr_lots_sell = 0.0;

    for(int i = 0; i < nT; i++)
    {
        if(!OrderSelect(tickets[i], SELECT_BY_TICKET) || OrderCloseTime() > 0) continue;

        if(OrderType() == OP_BUY) curr_lots_buy += OrderLots();
        else
            if(OrderType() == OP_SELL) curr_lots_sell += OrderLots();
    }

    return(fabs(curr_lots_buy - curr_lots_sell));
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double op(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderOpenPrice()); }
double cp(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderClosePrice()); }
double lot(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderLots()); }
double sl(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderStopLoss()); }
double tp(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderTakeProfit()); }
double profit(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderProfit()); }
double swap(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderSwap()); }
double commission(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderCommission()); }
double result(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderProfit() + OrderSwap() + OrderCommission()); }
int type(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderType()); }
int id(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return(OrderMagicNumber()); }
int ot(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return((int) OrderOpenTime()); }
int ct(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0);else return((int) OrderCloseTime()); }
string comm(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return("");else return(OrderComment()); }
string symb(int t = -1) { if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return("");else return(OrderSymbol()); }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//

// NOTE: tp sl
double TP(string side, double price = 0)
{
    if(TakeProfit == 0) return 0;

    double _tp = 0;
    if(side == "sell")
        _tp = price - (TakeProfit * pips);

    if(side == "buy")
        _tp = price + (TakeProfit * pips);

    return NormalizeDouble(_tp, Digits);
}

double SL(string side, double price = 0)
{
    if(StopLoss == 0) return 0;

    double _sl = 0;
    if(side == "sell")
        _sl = price + (StopLoss * pips);

    if(side == "buy")
        _sl = price - (StopLoss * pips);

    return NormalizeDouble(_sl, Digits);
}

// NOTE: MO
int MO(int type, double lot, string comment = "")
{ // market order
    double price;  color c;  int i = 0;  T = -1;  RefreshRates();
    double bsl, btp;
    if(type == OP_BUY) {
        c = clrBlue;
        price = Ask;
        if(StopLoss != 0) bsl = Ask - (StopLoss * pips);
        if(TakeProfit != 0)btp = Ask + (TakeProfit * pips);
    }
    else if(type == OP_SELL) {
        c = clrRed;
        price = Bid;
        if(StopLoss != 0) bsl = Bid + (StopLoss * pips);
        if(TakeProfit != 0)btp = Bid - (TakeProfit * pips);
    }
    else return(T);



    while(T < 0 && i < 5) {
        T = OrderSend(Symbol(), type, NL(lot), NT(price), 2 * (int) MarketInfo(Symbol(), MODE_SPREAD), bsl, btp, comment, Magic, NULL, c);
        if(T < 0) { if(!Errors(GetLastError())) return(T); } i++;
    } /*while*/ return(T);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool ClosePos(int type = -1)
{
    double price;  int i;  color c;
    _Ans = true;
    for(int pos = OrdersTotal() - 1; pos >= 0; pos--) {
        if(!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) || OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
        if(OrderType() > 1 || (type >= 0 && type != OrderType())) continue;
        RefreshRates();
        i = 0; Ans = false;
        while(!Ans && i < 5) {
            if(OrderType() == OP_BUY) { price = Bid; c = clrBlue; }
            else { price = Ask; c = clrRed; }
            Ans = OrderClose(OrderTicket(), OrderLots(), NT(price), 2 * (int) MarketInfo(Symbol(), MODE_SPREAD), c);
            if(!Ans) { if(!Errors(GetLastError())) break; } i++;
        } /*while*/ if(!Ans) _Ans = false;
    } /*for*/ return(_Ans);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool CloseByTicket(int ticket, double lot = 0.0)
{
    if(!OrderSelect(ticket, SELECT_BY_TICKET))return(false);
    if(OrderCloseTime() > 0)return(true);
    if(lot <= 0.0) lot = OrderLots();
    double price;  int i;  color c;
    RefreshRates();
    i = 0; Ans = false;
    while(!Ans && i < 5) {
        if(OrderType() == OP_BUY) { price = Bid; c = clrBlue; }
        else { price = Ask; c = clrRed; }
        Ans = OrderClose(OrderTicket(), NL(lot), NT(price), 2 * (int) MarketInfo(Symbol(), MODE_SPREAD), c);
        if(!Ans) { if(!Errors(GetLastError())) break; } i++;
    } /*while*/ return(Ans);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool HistoryCheck(int n = 10, int sleep = 1000)
{
    int i = 0;
    while(i < n) {
        if(TimeCurrent() - iTime(NULL, Tf, 0) < PeriodSeconds(Tf))
        {
            break;
        }

        Comment("Loading history of quotes ...");
        Sleep(sleep);
        i++;
    }//while

    if(i == n) { /*Comment("Update failed. Go to the next attempt.");*/Comment(""); return(false); }

    Comment(""); return(true);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void GetMarketInfo()
{
    TickSize = tickSize(); TickValue = tickValue(); Spread = _spread(); StopLevel = _stopLevel(); MinLot = minLot(); MaxLot = maxLot(); LotStep = lotStep();
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double tickSize(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_TICKSIZE)); }
double tickValue(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_TICKVALUE)); }
double spread(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_SPREAD)); }
double _spread(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_SPREAD) * pips()); }
double stopLevel(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_STOPLEVEL)); }
double _stopLevel(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_STOPLEVEL) * pips()); }
double freezeLevel(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_FREEZELEVEL)); }
double _freezeLevel(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_FREEZELEVEL) * pips()); }
double minLot(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_MINLOT)); }
double maxLot(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_MAXLOT)); }
double lotStep(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_LOTSTEP)); }
double bid(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_BID)); }
double ask(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_ASK)); }
double pips(string symb = "") { if(symb == "")symb = Symbol();return(MarketInfo(symb, MODE_POINT)); }
int digits(string symb = "") { if(symb == "")symb = Symbol();return((int) MarketInfo(symb, MODE_DIGITS)); }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double NL(double L)
{
    return(MathRound(MathMin(MathMax(L, MinLot), MaxLot) / LotStep) * LotStep);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double ND(double A, int digits = 0)
{
    if(digits <= 0) digits = Digits();
    return(NormalizeDouble(A, digits));
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double NT(double A, int direction = 0)
{
    double _A = MathRound(A / TickSize) * TickSize;
    if(direction == 1) { if(ND(A - _A) > 0.0) _A += TickSize; }
    else if(direction == -1) { if(ND(A - _A) < 0.0) _A -= TickSize; }
    return(_A);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
datetime GVS(string name, double value) { return(GlobalVariableSet(name + Name(), value)); }
datetime GVZ(string name) { return(GlobalVariableSet(name + Name(), 0.0)); }
double GVG(string name) { return(GlobalVariableGet(name + Name())); }
bool GVD(string name) { return((bool) GlobalVariableDel(name + Name())); }
bool GVC(string name) { return(GlobalVariableCheck(name + Name())); }
string Name() { if(IsTester)return("_" + IntegerToString(Magic) + "_" + Symbol() + "_" + "Tester");else return("_" + IntegerToString(Magic) + "_" + Symbol()); }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool Errors(int Error)
{
    if(Error == 0) return(false); // No error

    switch(Error) {
        // Crucial errors:
        case 4: // Trade server is busy  
            Sleep(3000); RefreshRates();
            return(true); // Avoidable error
        case 129: // Wrong price
        case 135: // Price changed
            RefreshRates(); // Refresh data
            return(true); // Avoidable error
        case 136: // No prices. Waiting for a new tick.
            while(!RefreshRates()) Sleep(1);
            return(true); // Avoidable error
        case 137: // Broker is busy 
            Sleep(3000); RefreshRates();
            return(true); // Avoidable error
        case 146: // Trading subsystem is busy
            Sleep(500); RefreshRates();
            return(true); // Avoidable error
            // Fatal error:
        case 2:  // Generic error 
        case 5:  // The old version of the client terminal
        case 64:  // Account blocked
        case 133: // Trading is prohibited
            Alert("A fatal error - expert stopped!"); FatalError = true; return(false); // Fatal error 
        default:  // Other variants
            return(false);
    } /*switch*/
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void TSL_info()
{
    if(!IsTester) MaxProfitTrail = GVG("MaxProfitTrail");

    if(MaxProfitTrail > 0.0)
    {
        drawLbl("TSL_lev", "TSL LEVEL : " + DoubleToString(MaxProfitTrail - Trail_Step, 2) + " " + AccountCurrency(),
                 CORNER_LEFT_UPPER, 20, 20, 12, "Tahoma", clrGold);
    }

    else
        if(MaxProfitTrail <= 0.0)
        {
            if(ObjectFind(0, "TSL_lev") >= 0) ObjectDelete(0, "TSL_lev");
        }

    ChartRedraw();
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void drawLbl(string name, string s, ENUM_BASE_CORNER corner, int DX, int DY, int FSize, string Font, color c, bool bg = false)
{
    if(ObjectFind(0, name) < 0) { ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0); }
    ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, DX);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, DY);
    ObjectSetInteger(0, name, OBJPROP_BACK, bg);
    ObjectSetString(0, name, OBJPROP_TEXT, s);
    ObjectSetString(0, name, OBJPROP_FONT, Font);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FSize);
    ObjectSetInteger(0, name, OBJPROP_COLOR, c);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//

bool TimeFilter(string StartH, string EndH)
{
    datetime Start = StrToTime(TimeToStr(TimeGMT(), TIME_DATE) + " " + StartH);
    datetime End = StrToTime(TimeToStr(TimeGMT(), TIME_DATE) + " " + EndH);
    if(!(Time[0] >= Start && Time[0] <= End))
    {
        return(false);
    }
    return(true);
}

void MoveTrailingStop()
{
    bool s, mod;
    for(int cnt = 0;cnt < OrdersTotal();cnt++)
    {
        s = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        string sy = OrderSymbol();
        int    tk = OrderTicket(),
            ot = OrderType(),
            mn = OrderMagicNumber();
        double op = OrderOpenPrice(),
            sl = OrderStopLoss(),
            tp = OrderTakeProfit();
        if(sy == Symbol() && mn == Magic && ot <= OP_SELL)
        {
            if(ot == OP_BUY)
            {
                if(TrailingStop >
                0 && NormalizeDouble(Ask - (TrailingStep * pips), Digits) > NormalizeDouble((op + (TrailingStop * pips)), Digits))
                {
                    if((NormalizeDouble(sl, Digits) < NormalizeDouble(Bid - (TrailingStop * pips), Digits)) || (sl == 0))
                    {
                        mod = OrderModify(tk, op, NormalizeDouble(Bid - (TrailingStop * pips), Digits), tp, 0, Blue);
                    }
                }
            }
            else
            {
                if(TrailingStop > 0 && NormalizeDouble(Bid + (TrailingStep * pips), Digits) < NormalizeDouble((op - (TrailingStop * pips)), Digits))
                {
                    if((NormalizeDouble(sl, Digits) > (NormalizeDouble(Ask + (TrailingStop * pips), Digits))) || (sl == 0))
                    {
                        mod = OrderModify(tk, op, NormalizeDouble(Ask + (TrailingStop * pips), Digits), tp, 0, Red);
                    }
                }
            }
        }
    }
}

int Orderscnt(int type = -1)
{
    int cnt = 0;
    for(int i = 0;i < OrdersTotal();i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && (OrderType() == type || type == -1))
            {
                cnt++;
            }
        }
    }
    return(cnt);
}

int CandleSeconds()
{
    switch(Period())
    {
        case PERIOD_M1:  return 1 * 60;
        case PERIOD_M5:  return 5 * 60;
        case PERIOD_M15: return 15 * 60;
        case PERIOD_M30: return 30 * 60;
        case PERIOD_H1:  return 60 * 60;
        case PERIOD_H4:  return 240 * 60;
        case PERIOD_D1:  return 24 * 60 * 60;
        case PERIOD_W1:  return 24 * 60 * 60 * 5;
        case PERIOD_MN1: return 24 * 60 * 60 * 20;
    }
    return 0;
}

void ControlDeletePendings()
{
    // sell
    actionDeletePendingsSells = new ActionDeletePendings("sell", magico,"", pendingOrderLife);
    actionDeletePendingsSells.doAction();
    delete actionDeletePendingsSells;

    // buy
    actionDeletePendingsBuys = new ActionDeletePendings("buy", magico,"", pendingOrderLife);
    actionDeletePendingsBuys.doAction();
    delete actionDeletePendingsBuys;
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
