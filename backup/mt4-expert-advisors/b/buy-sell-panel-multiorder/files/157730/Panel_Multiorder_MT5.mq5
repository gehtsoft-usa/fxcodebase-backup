//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=157579#p157579

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#include <Trade/Trade.mqh>
CTrade trade;

int i_reason;
// #include "Panel.mqh"
#include <Controls\Button.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>




#define Section_Arquitecture
#ifdef Section_Arquitecture
// MARK: arquitecture

interface iActions { bool doAction(); };
interface iConditions { bool evaluate(); };

class Conditions
{
  protected:
    iConditions *_conditions[];

  public:
    Conditions(void) {}
    ~Conditions(void) { releaseConditions(); }

    void releaseConditions()
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            delete _conditions[i];
        }
        ArrayFree(_conditions);
    }

    void add(iConditions *condition)
    {
        int t = ArraySize(_conditions);
        ArrayResize(_conditions, t + 1);
        _conditions[t] = condition;
    }

    bool evaluate(void)
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            if (!_conditions[i].evaluate()) {
                return false;
            }
        }
        return true;
    }
};
class Actions
{
  protected:
    iActions *_actions[];

  public:
    Actions(void) {}
    ~Actions(void) { release(); }

    void release()
    {
        for (int i = 0; i < ArraySize(_actions); i++) {
            delete _actions[i];
        }
        ArrayFree(_actions);
    }

    void add(iActions *action)
    {
        int t = ArraySize(_actions);
        ArrayResize(_actions, t + 1);
        _actions[t] = action;
    }

    bool doAction(void)
    {
        for (int i = 0; i < ArraySize(_actions); i++) {
            if (!_actions[i].doAction()) {
                return false;
            }
        }
        return true;
    }
};
class Strategy
{
    Conditions conditions;
    Actions    actions;
    bool       _mode;

  public:
    Strategy(bool mode = true) { _mode = mode; }

    Strategy(iConditions *condition, iActions *action, bool mode = true)
    {
        addCondition(condition);
        addAction(action);
        _mode = mode;
    }
    ~Strategy() { ; }

    void set(iConditions *aCondition, iActions *Action)
    {
        conditions.add(aCondition);
        actions.add(Action);
    }
    void addCondition(iConditions *aCondition) { conditions.add(aCondition); }
    void addAction(iActions *Action) { actions.add(Action); }

    bool doAction()
    {
        bool result = false;

        if (_mode == true)
            if (conditions.evaluate()) {
                result = actions.doAction();
            }

        if (_mode == false)
            if (!conditions.evaluate()) {
                result = actions.doAction();
            }
        return result;
    }
};
class Strategys
{
    Strategy *_strategys[];

  public:
    Strategys() {}
    ~Strategys() { release(); }

    void release()
    {
        for (int i = 0; i < ArraySize(_strategys); i++) {
            delete _strategys[i];
        }
        ArrayFree(_strategys);
    }

    void add(Strategy *newStrategy)
    {
        int t = ArraySize(_strategys);
        ArrayResize(_strategys, t + 1);
        _strategys[t] = newStrategy;
    }

    bool doAction()
    {
        for (int i = 0; i < ArraySize(_strategys); i++) {
            _strategys[i].doAction();
        }
        return true;
    }
};
class PositionsMannagement
{
    Strategy *_strategys[];
    string    _symbol;
    int       _magic;

  public:
    PositionsMannagement() { ; }
    ~PositionsMannagement() { release(); }

    void set(string sym, int magi)
    {
        _symbol = sym;
        _magic  = magi;
    }
    void release()
    {
        for (int i = 0; i < ArraySize(_strategys); i++) {
            delete _strategys[i];
        }
        ArrayFree(_strategys);
    }

    void add(Strategy *newStrategy)
    {
        int t = ArraySize(_strategys);
        ArrayResize(_strategys, t + 1);
        _strategys[t] = newStrategy;
    }

    bool doAction()
    {
        for (int i = PositionsTotal(); i >= 0; i--) {
            ulong tk = PositionGetTicket(i);
            if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == _magic) {
                for (int n = 0; n < ArraySize(_strategys); n++) {
                    _strategys[n].doAction();
                }
            }
        }

        return true;
    }
};

class Trading
{
  public:
    Trading() { ; }
    ~Trading() { ; }

    Conditions           filters;
    Strategys            strategys;
    PositionsMannagement management;

    void doTrading()
    {
        management.doAction();
        if (filters.evaluate()) {
            strategys.doAction();
        }
    }
};
Trading Trader();

#endif


// ——————————————————————————————————————————————————————————————————
enum ModeLevels {
    FixPips,           // Fix Pips
    byMoney,           // Money
    PipsFromOpenCandle // Pips from Candle
};
enum TSLMode {
    byPips, // By Pips
    byMA    // By Moving Average
};
enum ModeCalcLots {
    FixLots,       // Fix Lots
    EquityPercent, // by Equity Percent
    // Money,           // by Money
    // AccountPercent,  // by Account Percent
};

enum CloseAllMode {
    CloseByMoney,          // by Money
    CloseByAccountPercent, // by Account Percent
    CloseByPips            // By Pips
};
enum enumDays { sunday, monday, tuesday, wednesday, thursday, friday, saturday, EA_OFF };
enum ModeEntry { Market, PendingStop, PendingLimit };
// ——————————————————————————————————————————————————————————————————

input string T0           = "== Trade Setup =="; // ————————————
input int    uMaxTrades   = 5;                   // Trades At Same Time:
int          userNoTrades = uMaxTrades;
input int    GapBtwOrders = 1; // Gap Betwen Orders (pips):
int          userGappips  = GapBtwOrders;

bool               uTradeReverse = false;         // Trade Reverse:
input int          magico        = 2022;          // Magic Number:
input string       Tvolumen      = "= Volumen ="; // ————————————
ModeCalcLots modeCalcLots  = FixLots;       // Mode to Calc Lots:
input double       userLots      = 0.01;          // Fixed Lots:
double             userLotSize   = userLots;
double       userEquityPer = 1;                 // Setup Lots by "Equity Percent":
input string       T01           = "= Take Profit ="; // ————————————
input bool         takeProfitOn  = true;              // Take Profit On:
input ModeLevels   modeTP        = FixPips;           // Mode Take Profit:
input int          uTPpips       = 20;                // Pips TP
int                userTPpips    = uTPpips;           // Pips TP
input double       userTPmoney   = 15;                // Money TP
input string       T02           = "= Stop Loss =";   // ————————————
input bool         stopLossOn    = true;              // Stop Loss On:
input ModeLevels   modeSL        = FixPips;           // Mode Stop Loss:
input int          uSLpips       = 20;                // Pips SL
int                userSLpips    = uSLpips;           // Pips SL
input double       userSLmoney   = 15;                // Money

#define Section_Traling_Stop
#ifdef Section_Traling_Stop

input string       ttsl         = "== TrailingStop Setup =="; // ————————————————————————
input const bool   tsl_on       = false;                      // TSL ON:
bool _tsl_on = tsl_on;
input const double tsl_start    = 10;                         // TSL Start:
input const double tsl_step     = 10;                         // TSL Step:
input const double tsl_distance = 20;                         // TSL Distance:

class ConditionTSL : public iConditions
{
  public:
    bool evaluate()
    {
        if(!_tsl_on) { return false; }

        double profit = PositionGetDouble(POSITION_PROFIT);
        if (profit < 0) return false;
        return true;
    }
};
ConditionTSL conditionTSL;

class ActionTSL : public iActions
{
  public:
    bool doAction()
    {
        string symbol     = PositionGetString(POSITION_SYMBOL);
        int    digi       = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        double mPoints    = SymbolInfoDouble(symbol, SYMBOL_POINT);
        bool   r          = false;
        long   tk         = PositionGetInteger(POSITION_TICKET);
        double currentsl  = PositionGetDouble(POSITION_SL);
        double tp         = PositionGetDouble(POSITION_TP);
        double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double profit     = PositionGetDouble(POSITION_PROFIT);

        double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
        double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

        double step     = tsl_step * mPoints * 10;
        double distance = tsl_distance * mPoints * 10;

        // double allowed = MarketInfo(symbol, MODE_STOPLEVEL) * mPoints;
        double allowed = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * mPoints;
        double newsl   = 0;

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            double last_step = open_price + tsl_start * mPoints * 10;
            if (bid < last_step) return false;
            double n = 1;
            while (last_step < ask) {
                last_step = open_price + (step * n);
                n++;
            }
            allowed = bid - allowed;
            newsl   = MathMin(NormalizeDouble(last_step - distance, digi), allowed);
            if (currentsl < newsl || currentsl == 0) {
                r = trade.PositionModify(tk, newsl, tp);
            }
        }

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
            double last_step = open_price - tsl_start * mPoints * 10;
            if (ask > last_step) return false;
            int n = 1;
            while (last_step >= ask) {
                last_step = open_price - (step * n);
                n++;
            }
            allowed = ask + allowed;
            newsl   = MathMax(NormalizeDouble(last_step + distance, digi), allowed);
            if (currentsl > newsl || currentsl == 0) {
                r = trade.PositionModify(tk, newsl, tp);
            }
        }
        return true;
    }
};
ActionTSL actionTSL;

Strategy TSL;
void     Initiate_TSL()
{
    TSL.addCondition(&conditionTSL);
    TSL.addAction(&actionTSL);

    Trader.management.add(&TSL);
}

#endif


#define Section_Entry
#ifdef Section_Entry
// MARK: Section Entry

// enum ModeEntry {
//     Market, // Market
//     PendingStop, // Pending Stop
//     PendingLimit // Pending Limit
// };

input string    TmodeEntry = "== Entry Setup =="; // ————————————————————————
ModeEntry modeEntry  = Market;              // Mode Entry:

#ifdef pending_orders_on
input double uEntryDistance = 10; // Pips distance for pending orders:
#endif



// MARK: funcion Price
double Price(string side, double pips = 0, string _symbol = "")
{
    string symbol = _symbol == "" ? Symbol() : _symbol;
    int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

    MqlTick data;
    SymbolInfoTick(symbol, data);
    double price = side == "buy" ? data.ask : data.bid;

    Print(__FUNCTION__, " ", side, " price: ", price);

    double points   = SymbolInfoDouble(symbol, SYMBOL_POINT);
    double distance = pips * 10 * points;

    if (side == "buy") {
        price = distance != 0 ? price + distance : price;

        switch (modeEntry) {
        case PendingStop:
            price += distance;
            break;
        case PendingLimit:
            price -= distance;
            break;
        }
    }

    if (side == "sell") {
        price = distance != 0 ? price + distance : price;

        switch (modeEntry) {
        case PendingStop:
            price -= distance;
            break;
        case PendingLimit:
            price += distance;
            break;
        }
    }

    return NormalizeDouble(price, digits);
}

#endif








#define GUI_ON
#ifdef GUI_ON
// Mark: GUI

// interface iActions { bool doAction(); };



// NOTE: Buttons Actions
class BuyStopAction : public iActions
{
    bool doAction()
    {
        bool result=false;
        int n = 0;
        double pr, prGrid;
        int distance = 0;
        int gap = (int) gui.editGappips.Text();
        double tp = 0;
        
        while(n < userNoTrades)
        {
            distance = gap * (n+1);
            pr = Price("buy", distance, _Symbol);
            if(distance == 0) return result;

            SendNewOrder* SendOrder;
            tp = TP("buy", pr);
            double sl = SL("buy", pr);
            double lot = (double)gui.editLots.Text();
            
            Print("line: ",__LINE__," pr: ",pr);
            Print("line: ",__LINE__," lot: ",lot);
            Print("line: ",__LINE__," tp: ",tp);
            Print("line: ",__LINE__," sl: ",sl);
            
            SendOrder = new SendNewOrder("buy", lot, "", pr, sl, tp, magico);
            result = SendOrder.doAction();
            n++;
            delete SendOrder;            
        }

        // if(TPModifyOn) handleTP("buy", tp);

        return result;
    }
};
BuyStopAction btnBuyStopAction();

class SellStopAction : public iActions
{
    bool doAction()
    {
        bool result=false;
        int n = 0;
        double pr, prGrid;
        int distance = 0;
        int gap = (int)gui.editGappips.Text();
        double tp = 0;

        while(n < userNoTrades)
        {
            distance = (gap*(-1)) * (n+1);
            pr = Price("sell", distance, _Symbol);
            if(distance == 0) return result;
            tp = TP("sell", pr);
            double sl = SL("buy", pr);
            double lot = (double)gui.editLots.Text();

            Print("line: ",__LINE__," pr: ",pr);
            Print("line: ",__LINE__," lot: ",lot);
            Print("line: ",__LINE__," tp: ",tp);
            Print("line: ",__LINE__," sl: ",sl);

            SendNewOrder* SendOrder;
            SendOrder = new SendNewOrder("sell", lot, "", pr, sl, tp, magico);
            result = SendOrder.doAction();
            n++;
            delete SendOrder;            
        }

        // if(TPModifyOn)handleTP("sell", tp);

        return result;
    }
};
SellStopAction btnSellStopAction();


class ActionCloseAll : public iActions
{
  public:
    bool doAction()
    {
        for (int i = PositionsTotal(); i >= 0; i--) {
            ulong tk = PositionGetTicket(i);
            if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magico) {
                trade.PositionClose(tk, 0);
            }
        }
        return true;
    }
};
ActionCloseAll acCloseAll;

class ActionNewSl : public iActions
{
    public:
    bool doAction()
    {
        Print("line: ",__LINE__," MODIFICANDO TP ");

        for (int i = PositionsTotal(); i >= 0; i--) {
            ulong tk = PositionGetTicket(i);
            if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magico) {
                
                ENUM_POSITION_TYPE type = PositionGetInteger(POSITION_TYPE);
                
                // if(type == ORDER_TYPE_BUY || type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP ) {
                
                // buy
                if(type == POSITION_TYPE_BUY) {
                    double Price = PositionGetDouble(POSITION_PRICE_OPEN);
                    double newSl = Price - ((int)gui.eNewSl.Text() *10* _Point);
                    double tp = PositionGetDouble(POSITION_TP);
                    // PositionModify(const string symbol,const double sl,const double tp);
                    trade.PositionModify(tk, newSl, tp);
                }
                
                // sell
                if(type == POSITION_TYPE_SELL) {
                    double Price = PositionGetDouble(POSITION_PRICE_OPEN);
                    double newSl = Price + ((int)gui.eNewSl.Text() *10* _Point);
                    double tp = PositionGetDouble(POSITION_TP);
                    // PositionModify(const string symbol,const double sl,const double tp);
                    trade.PositionModify(tk, newSl, tp);
                }
            }
        }
        for (int i = OrdersTotal(); i >= 0; i--) {
            ulong tk = OrderGetTicket(i);
            if (OrderGetString(ORDER_SYMBOL) == Symbol() && OrderGetInteger(ORDER_MAGIC) == magico) {
                
                ENUM_ORDER_TYPE type = OrderGetInteger(ORDER_TYPE);                
                
                // buy
                if(type == ORDER_TYPE_BUY || type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP ) {
                    double Price = OrderGetDouble(ORDER_PRICE_OPEN);
                    double newSl = Price - ((int)gui.eNewSl.Text() *10* _Point);
                    double tp = OrderGetDouble(ORDER_TP);
                    
                    trade.OrderModify(tk, Price, newSl, tp, 0, 0);
                }
                
                // sell
                if(type == ORDER_TYPE_SELL || type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP ) {
                    double Price = OrderGetDouble(ORDER_PRICE_OPEN);
                    double newSl = Price + ((int)gui.eNewSl.Text() *10* _Point);
                    double tp = OrderGetDouble(ORDER_TP);
                    
                    trade.OrderModify(tk, Price, newSl, tp, 0, 0);
                }
            }
        }
        return true;
    }
};
ActionNewSl acNewSl;



// clang-format off
class GUI : public CAppDialog
{

 int _magic;
 int _high, _width;
 int _PanelWidth, _PanelHigh;
 int _x, _y;
 int _gapV, _gapH;
 iActions* button1Action; 
 iActions* button2Action; 
 iActions* button3Action; 
 iActions* btBuyStopAction; 
 iActions* btSellStopAction; 
 iActions* btCloseAllAction; 
 
 // CEdit   edit1;

 public: 
  GUI(int magic=0)
	{
		int columns = 2;
		int rows = 13;

    _high = 18;
    _width = 75;
    _x = 10;
    _y = 10;
    _gapV = 3;
    _gapH = 10;
    _magic = magic;
    
    // _high  = (_PanelHigh/rows)-_gapV;
    // _width = (_PanelWidth/columns)-_gapH;
	_PanelWidth = 2 * _x + _width * columns + columns * _gapH;
	_PanelHigh  = 2 * _y + _high * rows + rows * _gapV;
  }
  ~GUI() 
	{ 
		delete button1Action;
		delete button2Action;
		delete button3Action;
		delete btSellStopAction;
		delete btBuyStopAction;
		delete btCloseAllAction;
	}

	CLabel  lb1, lb2, lb3, lb4, lbLots, lb6, lb7, lb8, lb9;
    CButton bt1, bt2, btCloseAll, bt4,bt5, btBuyStop, btSellStop;
    CEdit   edit1, edit2, edit3;
    CLabel  lNewSl;
    CEdit   eNewSl;
    CEdit   editTPpips, editSLpips,editNoOrders,editLots,editGappips;
    CCheckBox chTslOn;

	void setButton1Action(iActions *action) { button1Action = action; }
	void setButton2Action(iActions *action) { button2Action = action; }
	void setButton3Action(iActions *action) { button3Action = action; }
	void setBtBuyStopAction(iActions *action) { btBuyStopAction = action; }
	void setBtSellStopAction(iActions *action) { btSellStopAction = action; }
	void setBtCloseAllAction(iActions *action) { btCloseAllAction = action; }
	
	// Create Pannel:
	// ------------------------------------------------------------------
	int Row(int r) { return _y + (r * _high)+ r * _gapV; }  
	int Col(int c) { return _x + (c * _width)+ c * _gapH; }

	bool Create(const string name, const long chart=0,  const int subwin=0)
  {
		int x1 = 10;
		int y1 = 10;
		int x2 = x1+_PanelWidth;
		int y2 = y1+_PanelHigh;

    if (!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;

        if(!Create_label("#Orders", Col(0), Row(0), _high, _width, lb4)) return false;
        if(!Create_label("Lots", Col(1), Row(0), _high, _width, lbLots)) return false;
        if(!Create_Edit("No of Orders", Col(0), Row(1), _high, _width, editNoOrders, (string)uMaxTrades)) return false;
        if(!Create_Edit("Lot size", Col(1), Row(1), _high, _width, editLots, (string)userLots)) return false;
        if(!Create_button("Buy", Col(0), Row(2), _high, _width, bt1)) return false;
        if(!Create_button("Sell", Col(1), Row(2), _high, _width, bt2)) return false;

        if(!Create_button("Buy Stop",  Col(0), Row(3), _high, _width, btBuyStop)) return false;
        if(!Create_button("Sell Stop", Col(1), Row(3), _high, _width, btSellStop)) return false; 

    if(!Create_Edit("Pips TP", Col(1), Row(4), _high, _width, editTPpips, (string) uTPpips)) return false;
        if(!Create_Edit("Pips SL", Col(1), Row(5), _high, _width, editSLpips, (string) uSLpips)) return false;
        if(!Create_label("TP pips", Col(0), Row(4), _high, _width, lb1)) return false;
        if(!Create_label("SL pips", Col(0), Row(5), _high, _width, lb2)) return false;
        if(!Create_label("Gap ", Col(0), Row(6), _high, _width, lb3)) return false;
        if(!Create_Edit("Gap", Col(1), Row(6), _high, _width,  editGappips, (string)GapBtwOrders)) return false;
        if(!Create_button("CLOSE ALL", Col(0), Row(7), _high, _width*2.14, btCloseAll)) return false;
        
        if(!Create_button("All Order Change TP ", Col(0), Row(8), _high, _width * 2.14, bt5)) return false;

        if(!Create_label("New SL ", Col(0), Row(9), _high, _width, lNewSl)) return false;
        if(!Create_Edit("eNewSl", Col(1), Row(9), _high, _width,  eNewSl, (string)uSLpips)) return false;

        if(!Create_Check("TSL ON", Col(0), Row(10), _high, _width*2, chTslOn)) return false;
		

    return true;
  }

	virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);

	void HoverEvents(const int id, const long& lparam, const double& dparam, const string& sparam)
	{
		if(bt1.IsActive()) bt1.ColorBackground(RoyalBlue); else bt1.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
		if(bt2.IsActive()) bt2.ColorBackground(RoyalBlue); else bt2.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
		if(btCloseAll.IsActive()) btCloseAll.ColorBackground(RoyalBlue); else btCloseAll.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
	}
	
 protected:
  void OnEndEdit_edit1(){;}
  void OnClick_button1(){ button1Action.doAction();}
  void OnClick_button2(){ button2Action.doAction();}
  void OnClick_btBuyStop(){ btBuyStopAction.doAction();}
  void OnClick_btSellStop(){ btSellStopAction.doAction();}
  void OnClick_btCloseAll(){ btCloseAllAction.doAction();}

    void OnChange_chTslOn()
    {
      _tsl_on =!_tsl_on;
      Print("line: ",__LINE__," _tsl_on: ",_tsl_on);
    }


	bool Create_label(string name,int x1, int y1, int high, int width, CLabel &label, string txt="")
	{
   int x2 = x1+width;
   int y2 = y1+high;
   
	 label.Create(m_chart_id, name, 0, x1, y1, x2, y2);
	
	 string tx = txt ==""? name : txt;
   label.Text(tx);
   label.Font("Calibri");
   label.Color(C'121, 125, 127');
   label.FontSize(9);
   Add(label);
   return true;
	}

	bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton &bt)
	{
	 int x2 = x1+width;
   int y2 = y1+high;

	 bt.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
   bt.Text(name);
   bt.Font("Calibri");
   bt.FontSize(9);

   Add(bt);
   return true;
	}

   bool Create_Edit(string name, const int x1, const int y1, const int high, const int width, CEdit& ed, string txt="0")
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        ed.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        ed.Text(txt);
        ed.Font("Calibri");
        ed.FontSize(10);

        Add(ed);
        return true;
    }

    bool Create_Check(string name, const int x1, const int y1, const int high, const int width, CCheckBox& ch)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        ch.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        ch.Text(name);        
        
        Add(ch);
        return true;
    }
};

//Mapa de eventos (MACRO substituciones)
EVENT_MAP_BEGIN(GUI)
// ON_EVENT(ON_END_EDIT, edit1, OnEndEdit_edit1)
ON_EVENT(ON_CLICK, bt1, OnClick_button1)
ON_EVENT(ON_CLICK, bt2, OnClick_button2)
ON_EVENT(ON_CLICK, btCloseAll, OnClick_btCloseAll)
ON_EVENT(ON_CLICK, btBuyStop, OnClick_btBuyStop)
ON_EVENT(ON_CLICK, btSellStop, OnClick_btSellStop)
ON_EVENT(ON_END_EDIT, eNewSl, acNewSl.doAction)
ON_EVENT(ON_CHANGE, chTslOn,OnChange_chTslOn)
EVENT_MAP_END(CAppDialog)

GUI gui;

#endif

// clang-format on

// Gobal Variables
input double uLots = 0.01; // Lots

//////////////////////////////////////////////////////////////////////

int OnInit()
{
    trade.SetExpertMagicNumber(magico);    
    Trader.management.set(_Symbol, magico);
    Initiate_TSL();

    if (i_reason != REASON_CHARTCHANGE && i_reason != REASON_TEMPLATE && i_reason != REASON_PARAMETERS) {
        gui.Create("Multi Order Panel NRH");
        gui.Run();
    }
    gui.setButton1Action(sendBuy = new SendBuy());
    gui.setButton2Action(sendSell = new SendSell());
    gui.setBtBuyStopAction(&btnBuyStopAction);
    gui.setBtSellStopAction(&btnSellStopAction);
    gui.setBtCloseAllAction(&acCloseAll);

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    i_reason = reason;
    if (i_reason != REASON_CHARTCHANGE && i_reason != REASON_PARAMETERS) {
        gui.Destroy(reason);
    }
}

void OnTick() {
    Trader.doTrading();
}

void OnTimer(void) {}

void OnTrade(void) {}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{

    gui.ChartEvent(id, lparam, dparam, sparam);
    gui.HoverEvents(id, lparam, dparam, sparam);
}

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
    int             _id;
    string          _symbol;
    double          _price;
    double          _sl;
    double          _tp;
    double          _lot;
    ENUM_ORDER_TYPE _type;
    int             _magic;
    string          _comment;
    string          _strategy;
    datetime        _expireTime;
    datetime        _signalTime;
    double          _profit;
    double          _tslNext;

  public:
    Order(int id, string symbol, double price, double sl, double tp, double lot, ENUM_ORDER_TYPE type, int magic, string comment, string strategy, datetime expireTime, datetime signalTime,
          double profit)
        : _id(id), _symbol(symbol), _price(price), _sl(sl), _tp(tp), _lot(lot), _type(type), _magic(magic), _comment(comment), _strategy(strategy), _expireTime(expireTime), _signalTime(signalTime),
          _profit(profit)
    {
    }

    Order() {}
    ~Order() {}

    // clang-format off
	Order* id(int id){_id=id; return &this;}
	Order* symbol(string symbol){_symbol=symbol; return &this;}
	Order* price(double price){_price=price; return &this;}
	Order* sl(double sl){_sl=sl; return &this;}
	Order* tp(double tp){_tp=tp; return &this;}
	Order* lot(double lot){_lot=lot; return &this;}
	Order* type(ENUM_ORDER_TYPE type){_type=type; return &this;}
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
   ENUM_ORDER_TYPE type()      { return _type; }
   int            magic()      { return _magic; }
   string         comment()    { return _comment; }
   string         strategy()   { return _strategy; }
   datetime       expireTime() { return _expireTime; }
   datetime       signalTime() { return _signalTime; }
   // double         profit()     { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit(); return -1; }
   double         profit()     { return _profit; }
   double         tslNext()    { return _tslNext; }
};
class SendNewOrder : public iActions
{
 private:
  Order* newOrder;
  CTrade trade;

 public:
  SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
  {
    string          _symbol = setSymbol(symbol);
    double          _price  = setPrice(side, price, _symbol);
    ENUM_ORDER_TYPE _type   = SetType(side, price, _symbol);
    trade.SetExpertMagicNumber(magic);

    if (_type == -1) {
      Print(__FUNCTION__, " ", "Imposible to set OrderType");
      return;
    }

    newOrder = new Order();

    newOrder
        .id(0)
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
    //  delete newOrder;
  }

  string setSymbol(string sim)
  {
    if (sim == "") {
      return Symbol();
    }
    return sim;
  }

  double setPrice(string side, double pr, string sym)
  {
    if (pr == 0) {
      if (side == "buy") {
        return SymbolInfoDouble(sym, SYMBOL_ASK);
      }
      if (side == "sell") {
        return SymbolInfoDouble(sym, SYMBOL_BID);
      }
    }

    return pr;
  }

  ENUM_ORDER_TYPE SetType(string side, double priceClient, string sym)
  {
    double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
    double bid = SymbolInfoDouble(sym, SYMBOL_BID);

    if (priceClient == 0) {
      if (side == "buy") {
        return ORDER_TYPE_BUY;
      }
      if (side == "sell") {
        return ORDER_TYPE_SELL;
      }
    } else {
      if (side == "buy") {
        if (priceClient > ask) {
          return ORDER_TYPE_BUY_STOP;
        }
        if (priceClient < ask) {
          return ORDER_TYPE_BUY_LIMIT;
        }
      }
      if (side == "sell") {
        if (priceClient > bid) {
          return ORDER_TYPE_SELL_LIMIT;
        }
        if (priceClient < bid) {
          return ORDER_TYPE_SELL_STOP;
        }
      }
    }

    return -1;
  }

  bool doAction()
  {
    if (!trade.PositionOpen(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), newOrder.sl(), newOrder.tp(), newOrder.comment())) {
      Print(__FUNCTION__, " ", "Cannot Send Order, error: ", GetLastError());
      return false;
    }
    return true;
  }

  Order* lastOrder()
  {
    return GetPointer(newOrder);
  }
};

class SendBuy : public iActions
{
 SendNewOrder* actionBuy;
	
     public:
	 SendBuy(){;}
	 ~SendBuy(){;}

	 bool doAction()
	 {
            double l = (double)gui.editLots.Text();
			actionBuy = new SendNewOrder("buy", l, "", 0, SL("buy"), TP("buy"), magico);
			actionBuy.doAction();
			delete actionBuy;
			
			return true;
	 }
};
SendBuy* sendBuy;

class SendSell : public iActions
{
 SendNewOrder* actionSell;
	
	 public:
	 SendSell(){;}
	 ~SendSell(){;}

	 bool doAction()
	 {
            double l = (double)gui.editLots.Text();
			actionSell = new SendNewOrder("sell", l, "", 0, SL("sell"), TP("sell"), magico);
			actionSell.doAction();
			delete actionSell;
			
			return true;
	 }
};
SendSell* sendSell;




// ------------------------------------------------------------------
double Bid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
double Ask() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }

class LotCalculator
{
  double _tickValue;
  long   _modeCalc;
  double _contractSize;
  double _step;
  string _symbol;
  double _points;
  long   _digits;

 public:
  LotCalculator(string inpSymbol = "") { setSymbol(inpSymbol); };
  ~LotCalculator() { ; }

  void setSymbol(string sym)
  {
    if (sym == "") {
      _symbol = Symbol();
    } else {
      _symbol = sym;
    }
    _modeCalc     = SymbolInfoInteger(_symbol, SYMBOL_TRADE_CALC_MODE);
    _digits       = SymbolInfoInteger(_symbol, SYMBOL_DIGITS);
    _tickValue    = SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE);
    _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    _step         = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
    _points       = SymbolInfoDouble(_symbol, SYMBOL_POINT);
  }

  double LotsByBalancePercent(double BalancePercent, double Distance)
  {
    double risk = AccountInfoDouble(ACCOUNT_BALANCE) * BalancePercent / 100;
    return CalculateLots(risk, Distance);
  }

  double LotsByMoney(double Money, double Distance)
  {
    double risk = fabs(Money);
    return CalculateLots(risk, Distance);
  }

  double CalculateLots(double risk, double distance)  // distance in pips
  {
    distance *= 10;
    if (distance == 0) {
      Print(__FUNCTION__, " ", "Set Distance");
      return 0;
    }

    // FOREX
    if (_modeCalc == 0) {
      return NormalizeDouble(risk / distance / _tickValue, 2);
    }

    // FUTUROS
    if (_modeCalc == 1 && _step != 1.0) {
      double c = _contractSize * _step;
      return NormalizeDouble(risk / (distance * c), 2);
    }

    // FUTUROS SIN DECIMALES
    if (_modeCalc == 1 && _step == 1.0) {
      double c = _contractSize * _step;
      return MathFloor(risk / (distance * c) * 100);
    }

    return 0;
  }
};
LotCalculator* lotProvider;

// double Price(string direction, double distance, )
// {
//   double result = 0;
//   if (direction == "buy") {
//     result = Ask();
//     return result;
//   }

//   if (direction == "sell") {
//     result = Bid();
//     return result;
//   }

//   return -1;
// }

double SL(string direction, double price=0)
{
  if (!stopLossOn) return 0;
  double result = 0;

  if (direction == "buy") {
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
	int Buy_SLpips = (int)gui.editSLpips.Text();
    result     = ask - Buy_SLpips * 10 * _Point;
    return result;
  }

  if (direction == "sell") {
	int Sell_SLpips = (int)gui.editSLpips.Text();
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    result     = bid + Sell_SLpips * 10 * _Point;
    return result;
  }

  return -1;
}

double TP(string direction,  double price=0)
{
  if (!takeProfitOn) return 0;
  double result = 0;

	
  if (direction == "buy") {
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    if(price == 0) { price = ask; }
  	int Buy_TPpips = (int)gui.editTPpips.Text();
	  result     = price + Buy_TPpips * 10 * _Point;
    return result;
  }

  if (direction == "sell") {
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    if(price == 0) { price = bid; }
	int Sell_TPpips = (int)gui.editTPpips.Text();
    result     = price - Sell_TPpips * 10 * _Point;
    return result;
  }

  return -1;
}

//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=157579#p157579

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 
 