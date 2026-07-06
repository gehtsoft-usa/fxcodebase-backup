// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75313

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description "Expert Advisor"
#property strict

#define Section_Arquitecture
#ifdef Section_Arquitecture
// MARK: arquitecture
int magico = 0;

interface iActions { bool execute(); };
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

    bool execute(void)
    {
        for (int i = 0; i < ArraySize(_actions); i++) {
            if (!_actions[i].execute()) {
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

    void set(iConditions *condition, iActions *action)
    {
        addCondition(condition);
        addAction(action);
    }
    void addCondition(iConditions *aCondition) { conditions.add(aCondition); }
    void addAction(iActions *Action) { actions.add(Action); }

    bool execute()
    {
        bool result = false;

        if (_mode == true)
            if (conditions.evaluate()) {
                result = actions.execute();
            }

        if (_mode == false)
            if (!conditions.evaluate()) {
                result = actions.execute();
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

    bool execute()
    {
        for (int i = 0; i < ArraySize(_strategys); i++) {
            _strategys[i].execute();
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

    bool execute()
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic) {
                for (int n = 0; n < ArraySize(_strategys); n++) {
                    _strategys[n].execute();
                    int c = OrderSelect(i, SELECT_BY_POS); // si alguna estrategia cambia la selección vuelvo a la que está seleccionada
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

    Strategys            strategys;
    PositionsMannagement management;

    void doTrading()
    {
        management.execute();
        strategys.execute();
    }
};
Trading Trader();

#endif


#define Section_SendOrder
#ifdef Section_SendOrder
// Mark: Section_SendOrder


void calculateTPPips()
{
    double sl_pips = (double)gui.eSl.Text();
    double rb      = (double)gui.eRB.Text();
    double tp_pips = sl_pips * rb;
    gui.eTp.Text((string)tp_pips);
}

void calculateLots()
{
    double money   = (double)gui.eRisk.Text();
    double sl_pips = (double)gui.eSl.Text();
    double l       = lotsProvider.LotsByMoney(money, sl_pips);
    gui.eVolumen.Text(DoubleToString(l, 2));
}


class ActionBuy : public iActions
{
  public:
    bool execute()
    {
        ENUM_ORDER_TYPE cmd     = OP_BUY;
        double          tp_pips = (double)gui.eTp.Text();
        double          sl_pips = (double)gui.eSl.Text();
        double          l       = (double)gui.eVolumen.Text();
        double          sl      = NormalizeDouble(Ask - sl_pips * 10 * _Point, _Digits);
        double          tp      = NormalizeDouble(Ask + tp_pips * 10 * _Point, _Digits);
        if (!sl_on) sl = 0;
        if (!tp_on) tp = 0;
        double price = Ask;
        int    r     = OrderSend(_Symbol, cmd, l, price, 0, sl, tp, NULL, 0, 0, clrNONE);
        return true;
    }
};
ActionBuy acBuy;


class ActionSell : public iActions
{
  public:
    bool execute()
    {

        ENUM_ORDER_TYPE cmd     = OP_SELL;
        double          tp_pips = (double)gui.eTp.Text();
        double          sl_pips = (double)gui.eSl.Text();
        double          l       = (double)gui.eVolumen.Text();

        double sl = NormalizeDouble(Bid + sl_pips * 10 * _Point, _Digits);
        double tp = NormalizeDouble(Bid - tp_pips * 10 * _Point, _Digits);
        if (!sl_on) sl = 0;
        if (!tp_on) tp = 0;

        double price = Bid;
        int    r     = OrderSend(_Symbol, cmd, l, price, 0, sl, tp, NULL, 0, 0, clrNONE);
        return true;
    }
};
ActionSell acSell;


bool tp_on = true;
bool sl_on = true;
bool calculate_lots_on = true;

void TpOn()
{
    tp_on = !tp_on;
}
void SlOn()
{
    sl_on = !sl_on;
}
void CalculateLotsOn()
{
    calculate_lots_on = !calculate_lots_on;
}

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
        if (sym == "") {
            _symbol = Symbol();
        } else {
            _symbol = sym;
        }
        _tickValue    = MarketInfo(_symbol, MODE_TICKVALUE);
        _modeCalc     = MarketInfo(_symbol, MODE_PROFITCALCMODE);
        _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        _step         = MarketInfo(_symbol, MODE_LOTSTEP);
        _points       = MarketInfo(_symbol, MODE_POINT);
        _digits       = MarketInfo(_symbol, MODE_DIGITS);
        _min          = MarketInfo(_symbol, MODE_MINLOT);
        _max          = MarketInfo(_symbol, MODE_MAXLOT);
    }

    double LotsByBalancePercent(double BalancePercent, double Distance)
    {
        double risk = AccountBalance() * BalancePercent / 100;
        return CalculateLots(risk, Distance);
    }

    double LotsByEquityPercent(double Percent)
    {
        double lot             = 1;
        double marginConsumido = AccountFreeMargin() - AccountFreeMarginCheck(Symbol(), OP_BUY, lot);
        double mcPercent       = (marginConsumido / AccountFreeMargin()) * 100;
        double lotsCalc        = NormalizeDouble(Percent / mcPercent, 2);

        return CheckLimits(lotsCalc);
    }

    double CheckLimits(double lot)
    {
        double l = lot;
        if (lot < _min) l = _min;
        if (lot > _max) l = _max;
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
        if (distance == 0) {
            // Print(__FUNCTION__, " ", "Set Distance");
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
LotCalculator lotsProvider;


void ActionSellButton()
{
    acSell.execute();
}
void ActionBuyButton()
{
    acBuy.execute();
}

#endif



#define Action_Buttons
#ifdef Action_Buttons

class ActionCloseAll : public iActions
{
  public:
    bool execute()
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS)) {
                if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                    double bid   = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
                    double ask   = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
                    double price = OrderType() == OP_BUY ? bid : ask;
                    int    r     = OrderClose(OrderTicket(), OrderLots(), price, 0, CLR_NONE);
                }
            }
        }
        return true;
    }
};
ActionCloseAll acCloseAll;

class ActionClosePair : public iActions
{
  public:
    bool execute()
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol) {
                if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                    double bid   = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
                    double ask   = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
                    double price = OrderType() == OP_BUY ? bid : ask;
                    int    r     = OrderClose(OrderTicket(), OrderLots(), price, 0, CLR_NONE);
                }
            }
        }
        return true;
    }
};
ActionClosePair acClosePair;

class ActionClosePartialPair : public iActions
{
  public:
    bool execute()
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol) {
                if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                    double bid   = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
                    double ask   = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
                    double price = OrderType() == OP_BUY ? bid : ask;
                    double l     = NormalizeDouble(OrderLots() * 0.25, 2);
                    int    r     = OrderClose(OrderTicket(), l, price, 0, CLR_NONE);
                }
            }
        }
        return true;
    }
};
ActionClosePartialPair acClosePartialPair;

class ActionHedge : public iActions
{
    double          open_lots;
    ENUM_ORDER_TYPE last_cmd;

  public:
    bool execute()
    {
        OpenHedge();
        return true;
    }

    double OpenLots()
    {
        open_lots = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol) {
                open_lots += OrderLots();
                last_cmd = (ENUM_ORDER_TYPE)OrderType();
            }
        }
        return open_lots;
    }

    void OpenHedge()
    {
        double          l     = OpenLots();
        double          price = 0, sl = 0, tp = 0;
        ENUM_ORDER_TYPE cmd = last_cmd == OP_BUY ? (ENUM_ORDER_TYPE)OP_SELL : (ENUM_ORDER_TYPE)OP_BUY;

        if (cmd == OP_BUY) {
            price = Ask;
        }
        if (cmd == OP_SELL) {
            price = Bid;
        }

        int r = OrderSend(_Symbol, cmd, l, price, 0, sl, tp, NULL, 0, 0, clrNONE);
    }
};
ActionHedge acHedge;

class ActionReverse : public iActions
{
    double          open_lots;
    ENUM_ORDER_TYPE last_cmd;

  public:
    bool execute()
    {
        UpdateInfo();
        acClosePair.execute();
        OpenReverse();
        return true;
    }

    double UpdateInfo()
    {
        open_lots = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol) {
                open_lots += OrderLots();
                last_cmd = (ENUM_ORDER_TYPE)OrderType();
            }
        }
        return open_lots;
    }

    void OpenReverse()
    {
        ENUM_ORDER_TYPE cmd   = last_cmd == OP_BUY ? (ENUM_ORDER_TYPE)OP_SELL : (ENUM_ORDER_TYPE)OP_BUY;
        double          price = 0, sl = 0, tp = 0;
        double          l = open_lots;

        if (cmd == OP_BUY) {
            price = Ask;
        }
        if (cmd == OP_SELL) {
            price = Bid;
        }

        int r = OrderSend(_Symbol, cmd, l, price, 0, sl, tp, NULL, 0, 0, clrNONE);
    }
};
ActionReverse acReverse;

class ActionBreakeven : public iActions
{
  public:
    bool execute()
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol) {
                double bk = OrderOpenPrice();
                if (OrderType() == OP_BUY) {
                    bk += 10 * _Point;
                }
                if (OrderType() == OP_SELL) {
                    bk -= 10 * _Point;
                }

                if (OrderProfit() > 0) {
                    int r = OrderModify(OrderTicket(), OrderOpenPrice(), bk, OrderTakeProfit(), 0, CLR_NONE);
                }
            }
        }
        return true;
    }
};
ActionBreakeven acBreackeven;

#endif


#define GUI_ON
#ifdef GUI_ON
#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>

// Mark: GUI

bool OnInit_GUI()
{
    bool res = true;
    if (gui.reason() != REASON_CHARTCHANGE && gui.reason() != REASON_TEMPLATE && gui.reason() != REASON_PARAMETERS) {
        int rows      = 30;
        int altoPanel = (rows + 1) * 10;
        res           = gui.Create(0, "Risk Calculator", 0, 0, 0, 185, altoPanel);
        if (res) gui.Run();
    }
    return res;
}

void OnDeinit_GUI(int reason)
{
    gui.reason(reason);
    if (gui.reason() != REASON_CHARTCHANGE && gui.reason() != REASON_PARAMETERS) {
        gui.Destroy(reason);
    }
}

// clang-format off
class GUI : public CAppDialog
{

    int _magic;
    int _high, _width, _widthFull;
    int _x, _y;
    int _gapV, _gapH;
    int _reason; // la voy a usar para cuando se resetea el EA

    public:
    GUI(int magic = 0)
    {
        _high = 18;
        _width = 75;
        _x = 10;
        _y = 10;
        _gapV = 3;
        _gapH = 5;
        _magic = magic;
        _widthFull = _width * 2 + _gapH;
    }
    ~GUI() {}


    CLabel  lbLots, lbSl, lbTp, lbCandles, lbRB, lbRisk, lbProfitSymbol, lbProfitTotal;
    CButton btBuy, btSell, btCloseAll, btClosePartialPair, btClosePair, btReverse, btHedge, btBreackeven, btAutoTrade,btControlLoss, btControlWin, btLots;
    CButton btTp, btSl;
    CEdit   eCandles, edit2, eRisk, eSl, eTp, eVolumen, eRB, eControlLoss, eControlWin, eTSLPips, eProfitSymbol, eProfitTotal;

    void reason(int inpreason) { _reason = inpreason; }
    int  reason(void) { return _reason; }

    // NOTE: Create Pannel:
    // ------------------------------------------------------------------
    int Row(int r) { return _x + (r * _high) + r * _gapV; }
    int Col(int c) { return _y + (c * _width) + c * _gapH; }

    bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
    {
        if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;

        if(!Create_label("Money Risk:",  Col(0), Row(0), _high, _width, lbRisk)) return false;
        if(!Create_Edit("eRisk",         Col(1), Row(0), _high, _width, eRisk)) return false; eRisk.Text("100");
        
        if(!Create_button("Auto Lots",   Col(0), Row(1), _high, _width, btLots)) return false;
        if(!Create_Edit("eVolumen",      Col(1), Row(1), _high, _width, eVolumen)) return false; eVolumen.Text("0.00");

        if(!Create_button("SL",          Col(0), Row(2), _high, _width, btSl)) return false;
        if(!Create_Edit("eSL",           Col(1), Row(2), _high, _width, eSl)) return false; eSl.Text("20");
        if(!Create_button("TP",          Col(0), Row(3), _high, _width, btTp)) return false;
        if(!Create_Edit("eTP",           Col(1), Row(3), _high, _width, eTp)) return false; eTp.Text("20");
        if(!Create_label("Ratio RR:",    Col(0), Row(4), _high, _width, lbRB)) return false;
        if(!Create_Edit("eRatio",        Col(1), Row(4), _high, _width, eRB)) return false; eRB.Text("2");

        if(!Create_button("BUY",         Col(0), Row(6), _high, _width, btBuy)) return false;
        if(!Create_button("SELL",        Col(1), Row(6), _high, _width, btSell)) return false;
        

        if(!Create_label("Symbol:",      Col(0), Row(8), _high, _width, lbProfitSymbol)) return false;
        if(!Create_label("TOTAL:",       Col(0), Row(9), _high, _width, lbProfitTotal)) return false;
        if(!Create_Edit("eProfitSymbol", Col(1), Row(8), _high, _width, eProfitSymbol)) return false; eProfitSymbol.Text("0.00");
        if(!Create_Edit("eProfitTotal",  Col(1), Row(9), _high, _width, eProfitTotal)) return false; eProfitTotal.Text("0.00");

        return true;
    }

    virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);

    void HoverEvents(const int id, const long& lparam, const double& dparam, const string& sparam)
    {

        if(btBuy.IsActive()) btBuy.ColorBackground(PaleGreen); else btBuy.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(btSell.IsActive()) btSell.ColorBackground(Tomato); else btSell.ColorBackground(CONTROLS_BUTTON_COLOR_BG);

        // if(btCloseAll.IsActive()) btCloseAll.ColorBackground(RoyalBlue); else btCloseAll.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        // if(btClosePair.IsActive()) btClosePair.ColorBackground(RoyalBlue); else btClosePair.ColorBackground(CONTROLS_BUTTON_COLOR_BG);        
        // if(btClosePartialPair.IsActive()) btClosePartialPair.ColorBackground(RoyalBlue); else btClosePartialPair.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        // if(btClosePartialPair.IsActive()) btClosePartialPair.ColorBackground(RoyalBlue); else btClosePartialPair.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        
        if(tp_on) btTp.ColorBackground(PaleGreen); else btTp.ColorBackground(CONTROLS_BUTTON_COLOR_BG);        
        if(sl_on) btSl.ColorBackground(PaleGreen); else btSl.ColorBackground(CONTROLS_BUTTON_COLOR_BG);        
        if(calculate_lots_on) btLots.ColorBackground(PaleGreen); else btLots.ColorBackground(CONTROLS_BUTTON_COLOR_BG);        

        // if(btHedge.IsActive()) btHedge.ColorBackground(RoyalBlue); else btHedge.ColorBackground(CONTROLS_BUTTON_COLOR_BG);        
        
        // if(control_loss_on) btControlLoss.ColorBackground(PaleGreen); else btControlLoss.ColorBackground(CONTROLS_BUTTON_COLOR_BG);        
        // if(control_win_on) btControlWin.ColorBackground(Tomato); else btControlWin.ColorBackground(CONTROLS_BUTTON_COLOR_BG);                
        
        
        // if(tsl_on) btLots.ColorBackground(PaleGreen); else btLots.ColorBackground(CONTROLS_BUTTON_COLOR_BG);        
        
        // if(btReverse.IsActive()) btReverse.ColorBackground(RoyalBlue); else btReverse.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        // if(btBreackeven.IsActive()) btBreackeven.ColorBackground(RoyalBlue); else btBreackeven.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
    }

    void UpdateProfits()
    {
        double profit_symbol = 0;
        double profit_global = 0;

        for(int i=OrdersTotal()-1;i>=0;i--)
        {
            if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol() == _Symbol)
            {
                profit_symbol += OrderProfit()+OrderCommission()+OrderSwap();
            }            
        }
        for(int i=OrdersTotal()-1;i>=0;i--)
        {
            if(OrderSelect(i,SELECT_BY_POS))
            {
                profit_global += OrderProfit()+OrderCommission()+OrderSwap();
            }            
        }
    
        eProfitSymbol.Text(DoubleToString(profit_symbol, 2));        
        lbProfitSymbol.Text(_Symbol);        
        eProfitTotal.Text(DoubleToString(profit_global, 2));

        if (profit_symbol >= 0) { eProfitSymbol.Color(PaleGreen); }
        if (profit_symbol < 0) { eProfitSymbol.Color(Tomato); }
        if (profit_global >= 0) { eProfitTotal.Color(PaleGreen); }
        if (profit_global < 0) { eProfitTotal.Color(Tomato); }
        
    }

    void EventsWhenChangeSL()
    {
        calculateLots();
        calculateTPPips();
    }

    protected:
    bool Create_label(string name, int x1, int y1, int high, int width, CLabel& label)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        label.Create(m_chart_id, name, 0, x1, y1, x2, y2);
        label.Text(name);
        label.Font("Calibri");
        label.Color(C'121, 125, 127');
        label.FontSize(10);
        Add(label);
        return true;
    }
    bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton& bt)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        bt.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        bt.Text(name);
        bt.Font("Calibri");
        bt.FontSize(10);

        Add(bt);
        return true;
    }
    bool Create_Edit(string name, const int x1, const int y1, const int high, const int width, CEdit& ed)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        ed.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        ed.Text("");
        ed.Font("Calibri");
        ed.FontSize(10);
        ed.TextAlign(ALIGN_RIGHT);

        Add(ed);
        return true;
    }

    
};

//Mapa de eventos (MACRO substituciones)
EVENT_MAP_BEGIN(GUI)
ON_EVENT(ON_CLICK, btSl,            SlOn )
ON_EVENT(ON_CLICK, btTp,            TpOn )
ON_EVENT(ON_END_EDIT, eSl,          EventsWhenChangeSL)
ON_EVENT(ON_END_EDIT, eRisk,        calculateLots)
ON_EVENT(ON_END_EDIT, eRB,          calculateTPPips)
ON_EVENT(ON_CLICK, btBuy,           ActionBuyButton)
ON_EVENT(ON_CLICK, btSell,          ActionSellButton)
ON_EVENT(ON_CLICK, btLots,          CalculateLotsOn)
EVENT_MAP_END(CAppDialog)

GUI    gui();

#endif


#define Metatrader_Functions
#ifdef Metatrader_Functions
// Mark: oninit

int OnInit()
{
    if (!OnInit_GUI()) {
        return INIT_FAILED;
    }

    Trader.management.set(_Symbol, magico);

    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { OnDeinit_GUI(reason); }
void OnTick() { 
    Trader.doTrading(); 
    gui.UpdateProfits();
}
void OnTimer(void) {}
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    gui.ChartEvent(id, lparam, dparam, sparam);
    gui.HoverEvents(id, lparam, dparam, sparam);
}

#endif
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
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