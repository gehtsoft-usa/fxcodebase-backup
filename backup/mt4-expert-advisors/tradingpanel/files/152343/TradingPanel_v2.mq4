// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72704

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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


interface iActions
{
    bool doAction();
};

// Includes
// #include "Panel.mqh"
#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
// #include <FrameWork/Actions/iActions.mqh>
#include <Controls\WndObj.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

class CButtonStates : public CWndObj
{
    private:
    int                _currState;
    int                _qntStates;

    CChartObjectButton m_button;  // chart object

    public:
    CButtonStates(void);
    ~CButtonStates(void);
    //--- create
    virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2, int qntStates = 2);
    //--- state
    bool              Pressed(void)          const { return(m_button.State()); }
    bool              Pressed(const bool pressed) { return(m_button.State(pressed)); }

    void              ChangeState(void) { if(_currState == _qntStates - 1) { _currState = 0; } else { _currState++; } }
    int               CurrentState(void) { return _currState; }

    //--- properties
    bool              Locking(void)          const { return(IS_CAN_LOCK); }
    void              Locking(const bool flag);

    protected:
    //--- handlers of object settings
    virtual bool      OnSetText(void) { return(m_button.Description(m_text)); }
    virtual bool      OnSetColor(void) { return(m_button.Color(m_color)); }
    virtual bool      OnSetColorBackground(void) { return(m_button.BackColor(m_color_background)); }
    virtual bool      OnSetColorBorder(void) { return(m_button.BorderColor(m_color_border)); }
    virtual bool      OnSetFont(void) { return(m_button.Font(m_font)); }
    virtual bool      OnSetFontSize(void) { return(m_button.FontSize(m_font_size)); }
    //--- internal event handlers
    virtual bool      OnCreate(void);
    virtual bool      OnShow(void);
    virtual bool      OnHide(void);
    virtual bool      OnMove(void);
    virtual bool      OnResize(void);
    //--- новые обработчики
    virtual bool      OnMouseDown(void);
    virtual bool      OnMouseUp(void);
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CButtonStates::CButtonStates(void)
{
    m_color = CONTROLS_BUTTON_COLOR;
    m_color_background = CONTROLS_BUTTON_COLOR_BG;
    m_color_border = CONTROLS_BUTTON_COLOR_BORDER;
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CButtonStates::~CButtonStates(void)
{}
//+------------------------------------------------------------------+
//| Create a control                                                 |
//+------------------------------------------------------------------+
bool CButtonStates::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2, int qntStates)
{
    //--- call method of the parent class
    if(!CWndObj::Create(chart, name, subwin, x1, y1, x2, y2)) return(false);
    //--- create the chart object
    if(!m_button.Create(chart, name, subwin, x1, y1, Width(), Height())) return(false);

    //--- setup
    _qntStates = qntStates;

    //--- call the settings handler
    return(OnChange());
}
//+------------------------------------------------------------------+
//| Locking flag                                                     |
//+------------------------------------------------------------------+
void CButtonStates::Locking(const bool flag)
{
    if(flag)
        PropFlagsSet(WND_PROP_FLAG_CAN_LOCK);
    else
        PropFlagsReset(WND_PROP_FLAG_CAN_LOCK);
}
//+------------------------------------------------------------------+
//| Create object on chart                                           |
//+------------------------------------------------------------------+
bool CButtonStates::OnCreate(void)
{
    //--- create the chart object by previously set parameters
    return(m_button.Create(m_chart_id, m_name, m_subwin, m_rect.left, m_rect.top, m_rect.Width(), m_rect.Height()));
}
//+------------------------------------------------------------------+
//| Display object on chart                                          |
//+------------------------------------------------------------------+
bool CButtonStates::OnShow(void)
{
    return(m_button.Timeframes(OBJ_ALL_PERIODS));
}
//+------------------------------------------------------------------+
//| Hide object from chart                                           |
//+------------------------------------------------------------------+
bool CButtonStates::OnHide(void)
{
    return(m_button.Timeframes(OBJ_NO_PERIODS));
}
//+------------------------------------------------------------------+
//| Absolute movement of the chart object                            |
//+------------------------------------------------------------------+
bool CButtonStates::OnMove(void)
{
    //--- position the chart object
    return(m_button.X_Distance(m_rect.left) && m_button.Y_Distance(m_rect.top));
}
//+------------------------------------------------------------------+
//| Resize the chart object                                          |
//+------------------------------------------------------------------+
bool CButtonStates::OnResize(void)
{
    //--- resize the chart object
    return(m_button.X_Size(m_rect.Width()) && m_button.Y_Size(m_rect.Height()));
}
//+------------------------------------------------------------------+
//| Handler of click on the left mouse button                        |
//+------------------------------------------------------------------+
bool CButtonStates::OnMouseDown(void)
{
    if(!IS_CAN_LOCK)
        Pressed(!Pressed());
    //--- call of the method of the parent class
    return(CWnd::OnMouseDown());
}
//+------------------------------------------------------------------+
//| Handler of click on the left mouse button                        |
//+------------------------------------------------------------------+
bool CButtonStates::OnMouseUp(void)
{
    //--- depress the button if it is not fixed
    if(m_button.State() && !IS_CAN_LOCK)
        m_button.State(false);
    //--- call of the method of the parent class
    return(CWnd::OnMouseUp());
}
//+------------------------------------------------------------------+


// clang-format off
class GUI : public CAppDialog
{

    int _magic;
    int _high, _width;
    int _x, _y;
    int _gapV, _gapH;
    iActions* button1Action;
    iActions* button2Action;
    iActions* button3Action;
    iActions* button4Action;
    iActions* button5Action;
    iActions* button6Action;
    int _rows, _columns;

    public:
    GUI(int Rows = 10, int Columns = 2, int magic = 0)
    {
        _high = 17;
        _width = 80;
        _x = 10;
        _y = 10;
        _gapV = 2;
        _gapH = 10;
        _magic = magic;
        _rows = Rows;
        _columns = Columns;
    }
    ~GUI()
    {
        delete button1Action;
        delete button2Action;
        delete button3Action;
        delete button4Action;
        delete button5Action;
        delete button6Action;
    }

    CEdit ed1, ed2, ed3, ed4, ed5, ed6, ed7, ed8, ed9, ed10, ed11, ed12, ed13, ed14, ed15, ed16, ed17, ed18, ed19, ed20, ed21;
    CLabel  lb1, lb2, lb3, lb4, lb5, lb6, lb7, lb8, lb9, lb10, lb11, lb12, lb13, lb14, lb15, lb16, lb17, lb18, lb19, lb20;
    CButtonStates bt1, bt2, bt3, bt4, bt5, bt6;

    // void setButton1Action(iActions *action) { button1Action = action; }
    // void setButton2Action(iActions *action) { button2Action = action; }
    // void setButton3Action(iActions *action) { button3Action = action; }
    // void setButton4Action(iActions *action) { button4Action = action; }
    void setButton5Action(iActions* action) { button5Action = action; }
    void setButton6Action(iActions* action) { button6Action = action; }

    // Create Pannel:
    // ------------------------------------------------------------------
    int Row(int r) { return _x + (r * _high) + r * _gapV; }
    int Col(int c) { return _y + (c * _width) + c * _gapH; }

    bool Create(const long chart, const string name, const int subwin, const int x1, const int y1)
    {

        int x2 = x1 + _columns * _width + (_columns + 2) * _gapH;
        int y2 = y1 + _rows * _high + (_rows + 2) * _gapV;

        if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;

        if(!Create_label("Acc Balance: ", Col(0), Row(0), _high, _width, lb1)) return false;
        if(!Create_label("Direction: ", Col(0), Row(1), _high, _width, lb2)) return false;
        if(!Create_label("Order Type: ", Col(0), Row(2), _high, _width, lb3)) return false;
        if(!Create_label("Price: ", Col(0), Row(3), _high, _width, lb4)) return false;
        if(!Create_label("SL: ", Col(0), Row(4), _high, _width, lb5)) return false;
        if(!Create_label("TP: ", Col(0), Row(5), _high, _width, lb6)) return false;

        if(!Create_label("Use ATR: ", Col(0), Row(7), _high, _width, lb7)) return false;
        if(!Create_label("ATR Periods: ", Col(0), Row(8), _high, _width, lb8)) return false;
        if(!Create_label("ATR SL: ", Col(0), Row(9), _high, _width, lb9)) return false;
        if(!Create_label("ATR TP: ", Col(0), Row(10), _high, _width, lb10)) return false;

        if(!Create_label("Money Mannagment ", Col(0), Row(12), _high, _width, lb11)) return false;
        if(!Create_label("Risk %: ", Col(0), Row(13), _high, _width, lb12)) return false;
        // if (!Create_label("Risk GBP: ",          Col(0), Row(14), _high, _width, lb13)) return false;
        // if (!Create_label("Reward TP GBP: ",     Col(0), Row(15), _high, _width, lb14)) return false;

        if(!Create_label("Take Profits ", Col(0), Row(17), _high, _width, lb15)) return false;
        if(!Create_label("TP1 ", Col(1), Row(18), _high, _width, lb16)) return false;
        if(!Create_label("TP2 ", Col(2), Row(18), _high, _width, lb17)) return false;
        if(!Create_label("Pips or %: ", Col(0), Row(19), _high, _width, lb18)) return false;
        if(!Create_label("% Lots to close: ", Col(0), Row(20), _high, _width, lb19)) return false;
        if(!Create_label("Move SL: ", Col(0), Row(21), _high, _width, lb20)) return false;

        if(!Create_edit("edBalance", Col(1), Row(0), _high, _width, ed1)) return false;
        if(!Create_button("btDirection", Col(1), Row(1), _high, _width, bt1)) return false;
        if(!Create_button("btType", Col(1), Row(2), _high, _width, bt2)) return false;
        if(!Create_edit("edPrice", Col(1), Row(3), _high, _width, ed2)) return false;
        if(!Create_edit("edSL", Col(1), Row(4), _high, _width, ed3)) return false;
        if(!Create_edit("edTP1", Col(1), Row(5), _high, _width, ed4)) return false;
        if(!Create_edit("edTP2", Col(2), Row(5), _high, _width, ed5)) return false;

        if(!Create_button("btATROn", Col(1), Row(7), _high, _width, bt3)) return false;
        if(!Create_edit("edATRPeriods", Col(1), Row(8), _high, _width, ed6)) return false;
        if(!Create_edit("edATR_SL", Col(1), Row(9), _high, _width, ed7)) return false;
        if(!Create_edit("edATR_TP1", Col(1), Row(10), _high, _width, ed8)) return false;
        if(!Create_edit("edATR_TP2", Col(2), Row(10), _high, _width, ed9)) return false;

        if(!Create_edit("edRisk%", Col(1), Row(13), _high, _width, ed10)) return false;
        if(!Create_edit("edRiskUsd", Col(2), Row(13), _high, _width, ed11)) return false;
        // if (!Create_edit("edRiskGBP1",           Col(1), Row(14), _high, _width, ed12)) return false;
        // if (!Create_edit("edRiskGBP2",           Col(2), Row(14), _high, _width, ed13)) return false;
        // if (!Create_edit("edRewardTP1",          Col(1), Row(15), _high, _width, ed14)) return false;
        // if (!Create_edit("edRewardTP2",          Col(2), Row(15), _high, _width, ed15)) return false;

        if(!Create_button("btTPtype", Col(1), Row(17), _high, _width, bt4)) return false;
        if(!Create_edit("edTP1Pips", Col(1), Row(19), _high, _width, ed16)) return false;
        if(!Create_edit("edTP2Pips", Col(2), Row(19), _high, _width, ed17)) return false;
        if(!Create_edit("edTP1Lots", Col(1), Row(20), _high, _width, ed18)) return false;
        if(!Create_edit("edTP2Lots", Col(2), Row(20), _high, _width, ed19)) return false;
        if(!Create_edit("edTP1MoveSl", Col(1), Row(21), _high, _width, ed20)) return false;
        if(!Create_edit("edTP2MoveSl", Col(2), Row(21), _high, _width, ed21)) return false;

        if(!Create_button("Send Order", Col(2), Row(23), _high, _width, bt5)) return false;

        if(!Create_button("Close All", Col(1), Row(23), _high, _width, bt6)) return false;


        return true;
    }

    virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);

    void HoverEvents(const int id, const long& lparam, const double& dparam, const string& sparam)
    {
        // if(bt1.IsActive()) bt1.ColorBackground(RoyalBlue); else bt1.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(bt2.IsActive()) bt2.ColorBackground(RoyalBlue); else bt2.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(bt3.IsActive()) bt3.ColorBackground(RoyalBlue); else bt3.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(bt4.IsActive()) bt4.ColorBackground(RoyalBlue); else bt4.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(bt5.IsActive()) bt5.ColorBackground(RoyalBlue); else bt5.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(bt6.IsActive()) bt6.ColorBackground(RoyalBlue); else bt6.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
    }

    // NOTE: ACTIONS	
    void OnEndEdit_ed1() { ; }
    void OnClick_button1()
    {
        bt1.ChangeState();
        if(bt1.CurrentState() == 0){ bt1.Text("Sell");bt1.ColorBackground(clrTomato); }
        if(bt1.CurrentState() == 1){ bt1.Text("Buy"); bt1.ColorBackground(clrPaleGreen); }

    }
    void OnClick_button2()
    {
        bt2.ChangeState();
        if(bt2.CurrentState() == 0){ bt2.Text("Market"); }// bt2.ColorBackground(clrTomato);}
        if(bt2.CurrentState() == 1){ bt2.Text("Pending"); }// bt2.ColorBackground(clrPaleGreen);}
    }
    void OnClick_button3()
    {
        bt3.ChangeState();
        if(bt3.CurrentState() == 0){ bt3.Text("No"); } // bt3.ColorBackground(clrTomato);}
        if(bt3.CurrentState() == 1){ bt3.Text("Yes"); } // bt3.ColorBackground(clrPaleGreen);}
    }
    void OnClick_button4()
    {
        bt4.ChangeState();
        if(bt4.CurrentState() == 0){ bt4.Text("by Pips"); }// bt4.ColorBackground(clrTomato);}
        if(bt4.CurrentState() == 1){ bt4.Text("by Percent"); }// bt4.ColorBackground(clrPaleGreen);}
    }
    void OnClick_button5()
    {
        // Print(ed2.Text());
        button5Action.doAction();

    }
    void OnClick_button6()
    {
        // Print(ed2.Text());
        button6Action.doAction();
    }

    private:

    bool Create_label(string name, int x1, int y1, int high, int width, CLabel& label)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        label.Create(m_chart_id, name, 0, x1, y1, x2, y2);
        label.Text(name);
        label.Font("Calibri");
        //  label.Color(C'121, 125, 127');
        label.Color(clrBlack);
        label.FontSize(9);
        Add(label);
        return true;
    }
    bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButtonStates& bt)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        bt.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        bt.Text(name);
        bt.Font("Calibri");
        bt.FontSize(8);

        Add(bt);
        return true;
    }
    bool Create_edit(string name, const int x1, const int y1, const int high, const int width, CEdit& ed)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        ed.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        ed.Text(name);
        ed.Font("Calibri");
        ed.FontSize(8);
        Add(ed);

        return true;
    }

};

//Mapa de eventos (MACRO substituciones)
EVENT_MAP_BEGIN(GUI)
ON_EVENT(ON_END_EDIT, ed1, OnEndEdit_ed1)
ON_EVENT(ON_CLICK, bt1, OnClick_button1)
ON_EVENT(ON_CLICK, bt2, OnClick_button2)
ON_EVENT(ON_CLICK, bt3, OnClick_button3)
ON_EVENT(ON_CLICK, bt4, OnClick_button4)
ON_EVENT(ON_CLICK, bt5, OnClick_button5)
ON_EVENT(ON_CLICK, bt6, OnClick_button6)
EVENT_MAP_END(CAppDialog)

GUI gui(27, 3, 2022);
int i_reason;

// NOTE: INPUTS
// ------------------------------------------------------------------
enum ModeLevels {
    FixPips,            // Fix Pips
    byMoney,            // Money
    PipsFromOpenCandle  // Pips from Candle
};
enum TSLMode {
    byPips,  // By Pips
    byMA     // By Moving Average
};
enum ModeCalcLots {
    Money,           // by Money
    AccountPercent,  // by Account Percent
    FixLots          // Fix Lots
};
enum CloseAllMode {
    CloseByMoney,           // by Money
    CloseByAccountPercent,  // by Account Percent
    CloseByPips             // By Pips
};
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
// ------------------------------------------------------------------
input string     T0 = "== Trade Setup ==";  // == Trade Setup ==
input int        magico = 2022;                 // Magic Number:
input double     userBalancePer = 1;                    // Setup Lots by "Account Percent":
ModeCalcLots     modeCalcLots = Money;                // Mode to Calc Lots:
double           userMoney = 10;                   // Setup Lots by "Money":
double           userLots = 0.01;                 // Setup Lots by "User Lots":
input string     T3 = "== TP Setup ==";     // == Take Profits
input bool       takeProfitOn = true;                 // Take Profit On:
input ModeLevels modeTP = FixPips;              // Mode Take Profit: 
int        userTPpips = 0;                   // TP1 Pips/Percent:
// int        userTPpips     = 0;                   // TP2 Pips/Percent:

input double     uTP1_value = 1;                    // TP1 Pips/Percent:
input double     uTP1_Lots = 50;                   // TP1 % Lots:
input double     uTP1_MoveSL = 0;                    // TP1 Move SL:
input double     uTP2_value = 1;                    // TP2 Pips/Percent:
input double     uTP2_Lots = 50;                   // TP2 % Lots:
input double     uTP2_MoveSL = 0;                    // TP1 Move SL:
double           userTPmoney = 15;                   // Money TP

input string     T02 = "== Stop Loss ==";          // Setup Stop Loss
bool       stopLossOn = true;                       // Stop Loss On:
ModeLevels modeSL = FixPips;                    // Mode Stop Loss:
input int        userSLpips = 20;                         // SL Pips:
double           userSLmoney = 15;                         // Money SL

input string     Tpc = "== Partial Close ==";      // == Partial Close ==
input bool       partialCloseOn = false;                      // Use Partial Close ?
input double     userPartialClosePercent = 50;                         // Partial Close Percent:
input double     userPartialClosePips = 20;                         // Partial Close Pips:
input string     Tbk = "== Breakeven Setup ==";    // == Breakeven Setup ==
input bool       breakevenOn = false;                      // Use Breakeven?
input double     userBkvPips = 3;                          // Breakeven Pips
input string     tTailingStop = "== TailingStop Setup ==";  // == TailingStop Setup ==
input bool       TslON = false;                      // TSL ON:
TSLMode          userTslMode = byPips;                     // TSL Mode:
input int        userTslInitialStep = 1;                          // TSL Initial Step:
input int        userTslStep = 1;                          // TSL Step:
input int        userTslDistance = 20;                         // TSL Distance:
string           TFilters = "== Filters Orders ==";     // == Filters Orders ==
bool             filterSymbolsOn = true;                       // Use symbols filter?
string           SymbolsList = "GBPUSD,EURUSD";            // Symbols (separate by comma ","):
bool             filterMagicsOn = true;                       // Use magic number filter?
string           MagicsList = "2022";                     // Magics numbers (separate by comma ","):
// ------------------------------------------------------------------
input string T1 = "== ATR Setup ==";  // == ATR
input int    uATR_Periods = 20;                 // ATR Periods:
input double uATR_SL_Multiplier = 1.5;                // ATR SL Multiplier:
input double uATR_TP1_Multiplier = 2;                  // ATR TP1 Multiplier:
input double uATR_TP2_Multiplier = 3;                  // ATR TP2 Multiplier:
input string T2 = "== MM Setup ==";   // == MM
input double uRiskPer = 1;                  // Risk Percent:
input double uRiskGBP = 100;                // Risk GBP:
input double uReward = 1000;               // Reward TP GBP
input color     tpColor = clrLimeGreen;                   // TP Color:
input color     slColor = clrRed;                         // SL Color:
input color  entryColor = clrDodgerBlue;                //Entry Color:
//////////////////////////////////////////////////////////////////////
interface IOrders
{
    public:
    virtual void Add() = 0;
    virtual void Release() = 0;

    virtual bool AddOrder() = 0;
    virtual bool DeleteOrder() = 0;
    virtual bool Select() = 0;
};

// NOTE: ORDER Class 
class Order
{
    int      _id;
    string   _symbol;
    double   _price;
    double   _sl;
    double   _tp;
    double   _tp2;
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
        double   tp2,
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
        _tp2(tp2),
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
    Order* tp2(double tp2) { _tp2 = tp2; return &this; }
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
    double         tp2() { return _tp2; }
    double         lot() { return _lot; }
    int            type() { return _type; }
    int            magic() { return _magic; }
    string         comment() { return _comment; }
    string         strategy() { return _strategy; }
    datetime       expireTime() { return _expireTime; }
    datetime       signalTime() { return _signalTime; }
    double         profit() { if(OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit(); return -1; }
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
            Print(_symbols[i]);
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
            Print(_magics[i]);
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

    //+------------------------------------------------------------------+

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
            PrintOrder(t);
            return true;
        }

        return false;
    }

    // recorrer las ordenes de mercado y agregar las que no estén en el array
    //+------------------------------------------------------------------+
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
                    PrintOrder(i);
                }
            }
        }
    }

    // agrega la última orden si no está en el array
    //+------------------------------------------------------------------+
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
    //+------------------------------------------------------------------+
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
    //+------------------------------------------------------------------+
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
    //+------------------------------------------------------------------+
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
        return orders[lastIndex];
    }

    Order* index(int in)
    {
        return orders[in];
    }

    int lastId()
    {
        int lastIndex = ArraySize(orders) - 1;
        return orders[lastIndex].id();
    }

    //+------------------------------------------------------------------+
    bool notOverFlow(int index)
    {
        if(index > ArraySize(orders) - 1) return false;
        if(index < 0) return false;
        if(CheckPointer(orders[index]) == POINTER_INVALID) return false;

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
    double tp2(int index)
    {
        if(notOverFlow(index))
        {
            return orders[index].tp2();
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
    //+------------------------------------------------------------------+
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
    //+------------------------------------------------------------------+
    void cleanCloseOrders()
    {
        if(qnt() == 0)
        {
            return;
        }

        for(int i = 0; i < qnt(); i++)
        {
            if(isClose(i))
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

    //+------------------------------------------------------------------+
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
        Print("Order ", index, " tp2: ", orders[index].tp2());
        Print("Order ", index, " magic: ", orders[index].magic());
        Print("Order ", index, " comment: ", orders[index].comment());
        Print("Order ", index, " strategy: ", orders[index].strategy());
        Print("Order ", index, " expire time: ", orders[index].expireTime());
        Print("Order ", index, " signal time: ", orders[index].signalTime());
        Print("Order ", index, " profit: ", orders[index].profit());
        Print("Order ", index, " countPartials: ", orders[index].countPartials());
        // clang-format on
    }
    //+------------------------------------------------------------------+
    void PrintList()
    {
        for(int i = 0; i < qnt(); i++)
        {
            PrintOrder(i);
        }
    }
};
OrdersList mainOrders(filterMagicsOn, (string) magico, filterSymbolsOn, _Symbol);

// interface iActions {
//    bool doAction();
// };

// NOTE: MOVE SL
class MoveSL : public iActions
{
    Order* _order;
    double _newSL;

    public:
    MoveSL() { ; }
    ~MoveSL() { ; }

    MoveSL* order(Order* or )
    {
        _order = or ;
        return &this;
    }
    MoveSL* newSL(double newSL)
    {
        _newSL = newSL;
        return &this;
    }

    bool controlPointer(Order* or )
    {
        if(CheckPointer(or ))
        {
            return true;
        }
        else
        {
            Print("Order Pointer Invalid");
            return false;
        }
    }

    bool doAction()
    {
        if(!controlPointer(_order))
        {
            Print(__FUNCTION__, " ", "Can't Move Stop Loss");
            return false;
        }

        if(OrderSelect(_order.id(), SELECT_BY_TICKET))
        {
            if(OrderCloseTime() > 0)
            {
                Print(__FUNCTION__, " ", "Order are closed ", _order.id());
                return false;
            }

            if(OrderModify(_order.id(), OrderOpenPrice(), _newSL, OrderTakeProfit(), OrderExpiration(), clrNONE))
            {
                _order.sl(_newSL);
                // _order.breakevenWasDoIt(true);
                Print(__FUNCTION__, " ", _order.id(), " Modify: new SL: ", _newSL);
                return true;
            }

        }
        else
        {
            Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
        }

        return false;
    }
};
MoveSL* breackevenAction;
MoveSL* moveSLAction;

class ActionCloseAll : public iActions
{
    ENUM_ORDER_TYPE _type;
    string          _symbol;
    int             _magic;
    int             _slippage;
    double          _price;

    public:
    ActionCloseAll(int magic, string symbol = "", int slippage = 10000)
    {
        _magic = magic;
        if(symbol == "")      { _symbol = Symbol();   } else { _symbol = symbol; }
        if(slippage != 10000) { _slippage = slippage; }
    }
    ~ActionCloseAll() {}

    void setPrice()
    {
        if(_type == OP_BUY) { _price = SymbolInfoDouble(_symbol, SYMBOL_BID); }
        if(_type == OP_SELL) { _price = SymbolInfoDouble(_symbol, SYMBOL_ASK); }
    }

    bool doAction()
    {
        for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic)
            {
                _type = OrderType();
                setPrice();
                
                if(!OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE))
                {
                    Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
                }
            }
        }
        return true;
    }
};
ActionCloseAll* actionCloseAll;

class PartialClose : public iActions
{
    Order* _order;
    double _percentToClose;

    public:
    PartialClose() { ; }
    ~PartialClose() { ; }

    PartialClose* order(Order* or )
    {
        _order = or ;
        return &this;
    }
    PartialClose* percent(double percentToClose)
    {
        _percentToClose = percentToClose;
        return &this;
    }

    bool controlPointer(Order* or )
    {
        if(CheckPointer(or ))
        {
            return true;
        }
        else
        {
            Print("Order Pointer Invalid");
            return false;
        }
    }

    double lots()
    {

        double calulatedLots = NormalizeDouble((_order.lot() * _percentToClose / 100), 2);
        Print("calulatedLots: ", calulatedLots, " ", 852);
        OrderSelect(_order.id(), SELECT_BY_TICKET, MODE_TRADES);
        double openLots = OrderLots();

        if(calulatedLots >= openLots) return openLots;

        return calulatedLots;
    }

    double price()
    {
        double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

        if(_order.type() == OP_BUY)
        {
            return bid;
        }
        if(_order.type() == OP_SELL)
        {
            return ask;
        }
        return 0;
    }

    bool doAction()
    {
        if(!controlPointer(_order))
        {
            Print(__FUNCTION__, " ", "Can't Take Partial");
            return false;
        }
        if(OrderSelect(_order.id(), SELECT_BY_TICKET))
        {
            if(OrderCloseTime() > 0)
            {
                Print(__FUNCTION__, " ", "Order are closed ", _order.id());
                return false;
            }

            if(OrderClose(_order.id(), lots(), price(), 1000, clrNONE))
            {
                int count = _order.countPartials() + 1;
                _order.countPartials(count);
                // remplazar el tk por el nuevo tk
                changeTk(_order.id());

                Print(__FUNCTION__, " ", _order.id(), " Partial TP taked ");
                return true;
            }

        }
        else
        {
            Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
        }

        return false;
    }

    void changeTk(int tk)
    {
        if(OrderSelect(tk, SELECT_BY_TICKET))
        {
            datetime dt = OrderCloseTime();
            string   coment = OrderComment();
            int      pos = StringFind(coment, "#") + 1;
            string   newId = StringSubstr(coment, pos, StringLen(coment));
            _order.id((int) newId);
        }
    }
};
PartialClose* partialCloseAction;

class SendNewOrder : public iActions
{
    private:
    Order* newOrder;

    public:
    SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, double tp2 = 0, int magic = 0, string coment = "", datetime expire = 0)
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
            .tp2(tp2)
            .lot(lots)
            .magic(magic)
            .comment(coment)
            .expireTime(expire)
            .profit(0);
    }

    ~SendNewOrder()
    {
        // delete newOrder;
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
        double tp = 0; // No tiene que pasar el tp al mercado

        int tk = -1;
        if(CheckPointer(newOrder) != POINTER_INVALID)
        {
            tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, newOrder.sl(), tp, newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);
        }

        if(tk < 0)
        {
            Print(__FUNCTION__, " ", "Connot Send Order, error: ", GetLastError());
            return false;
        }
        else
        {
            newOrder.id(tk);
        }

        return true;
    }

    Order* lastOrder()
    {
        return newOrder;
    }
};
SendNewOrder* actionSendOrder;

class SendOrder : public iActions
{
    public:
    SendOrder() { ; }
    ~SendOrder() { ; }

    // NOTE: SEND ORDER ACTION
    bool doAction()
    {
        // BUY
        // ------------------------------------------------------------------
        if(gui.bt1.CurrentState() == 1)
        {
            double price = gui.bt2.CurrentState() == 0 ? 0 : Price("buy");
            actionSendOrder = new SendNewOrder("buy", Lots(), "", price, SL("buy"), TP("buy", 1), TP("buy", 2), magico);

            if(actionSendOrder.doAction())
            {
                mainOrders.AddOrder(actionSendOrder.lastOrder());
            }

            // delete actionSendOrder;
            delete levelTP;
            delete levelSL;
        }

        // SELL
        // ------------------------------------------------------------------
        if(gui.bt1.CurrentState() == 0)
        {
            double price = gui.bt2.CurrentState() == 0 ? 0 : Price("sell");
            actionSendOrder = new SendNewOrder("sell", Lots(), "", price, SL("sell"), TP("sell", 1), TP("sell", 2), magico);

            if(actionSendOrder.doAction())
            {
                mainOrders.AddOrder(actionSendOrder.lastOrder());
            }

            // delete actionSendOrder;
            delete levelTP;
            delete levelSL;
        }

        return true;
    }
};
SendOrder* sendOrder;

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
    double _entryPrice;

    public:
    ByFixPips(string inpSymbol, string inpSide, int inpPips, string inpMode, double entryPrice = 0)
    {
        _pips = inpPips;
        _symbol = inpSymbol;
        _side = inpSide;
        _mode = inpMode;
        _entryPrice = entryPrice;
    }
    ~ByFixPips() { ; }
    double pips()
    {
        return _pips;
    }

    double calculateLevel()
    {
        double mPoint = MarketInfo(_symbol, MODE_POINT);
        double distance = _pips * 10 * mPoint;
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
            if(_entryPrice == 0) return ask + distance;
            return _entryPrice + distance;
        }
        if(_side == "sell")
        {
            if(_entryPrice == 0) return bid - distance;
            return _entryPrice - distance;
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

        Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
        Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
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

        Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        Print(__FUNCTION__, " ", "TSL Order Price: ", " ", order.price());
        Print(__FUNCTION__, " ", "TSL tslNext: ", " ", order.tslNext());
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
        Print(__FUNCTION__, " ", "TSL Order: ", " ", order.id());
        Print(__FUNCTION__, " ", "TSL New SL: ", " ", newSl);

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
                Print(__FUNCTION__, " ", "Pointer invalid i= ", i);
                continue;
            }

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
                Print(__FUNCTION__, " ", "error when make TSL in TK: ", tk, " ", GetLastError());
            }
            else
            {
                Print(__FUNCTION__, " trailing stop in tk: ", tk);
            }
        }
    }
};
TrailingStop* tsl;

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

    //+------------------------------------------------------------------+
    void releaseConditions()
    {
        for(int i = 0; i < ArraySize(_conditions); i++)
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

ConcurrentConditions conditionsToBreackeven;
ConcurrentConditions conditionsToPartialClose;

class BreackevenCondition : public iConditions
{
    // TODO: bk condition
    Order* _order;

    public:
    void setOrder(Order* or )
    {
        _order = or ;
    }

    bool evaluate()
    {
        // si el precio actual coindide con el momento de hacer bk ret true
        double mPoints = MarketInfo(_order.symbol(), MODE_POINT);
        double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);
        double dist = userBkvPips * mPoints * 10;

        if(_order.type() == OP_BUY)
        {
            if(bid >= _order.price() + dist)
            {
                return true;
            }
        }
        if(_order.type() == OP_SELL)
        {
            if(ask <= _order.price() - dist)
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
    // TODO: PC condition
    Order* _order;

    public:
    void setOrder(Order* or )
    {
        _order = or ;
    }

    bool evaluate()
    {
        double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
        double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

        if(_order.type() == OP_BUY)
        {
            if((_order.countPartials() == 0 && bid >= _order.tp()) || (_order.countPartials() == 1 && bid >= _order.tp2()))
            {
                return true;
            }
        }

        if(_order.type() == OP_SELL)
        {
            if((_order.countPartials() == 0 && ask <= _order.tp()) || (_order.countPartials() == 1 && ask <= _order.tp2()))
            {
                return true;
            }
        }

        return false;
    }
};
PartialCloseCondition* partialCloseCondition;

//////////////////////////////////////////////////////////////////////

// NOTE: SET ORDER FUNCIONES
double Price(string direction)
{
    double result = -1;

    // Market
    if(gui.bt2.CurrentState() == 0)
    {
        if(direction == "buy") { result = Ask; }
        if(direction == "sell") { result = Bid; }
    }

    //  Pendng
    if(gui.bt2.CurrentState() == 1)
    {
        result = (double) gui.ed2.Text();
    }

    return result;
}
double SL(string side)
{
    double result = 0;
    double SLpips = userSLpips;

    // NOTE: SL ATR ON
    if(gui.bt3.CurrentState() == 1)
    {
        double atr = iATR(NULL, 0, (int) gui.ed6.Text(), 1) / _Point / 10;
        SLpips = (int) gui.ed7.Text() * atr;
    }

    if(stopLossOn)
        switch(modeSL)
        {
            case FixPips:
                levelSL = new Levels(new ByFixPips(_Symbol, side, SLpips, "SL", Price(side)));
                result = levelSL.calculateLevel();
                break;

            case byMoney:
                levelSL = new Levels(new ByMoney(_Symbol, side, userLots, userSLmoney, "SL"));
                result = levelSL.calculateLevel();
                break;

            case PipsFromOpenCandle:
                levelSL = new Levels(new ByPipsFromCandle(_Symbol, side, userSLpips, "SL", 0, 1));
                result = levelSL.calculateLevel();
        }

    return result;
}

// NOTE: TP
double TP(string side, int tp_)
{
    double result = 0;

    // by Pips:
    double TPpips = 0;
    if(gui.bt4.CurrentState() == 0)
    {
        TPpips = tp_ == 1 ? (double) gui.ed16.Text() : (double) gui.ed17.Text();
    }

    // by Percent:
    if(gui.bt4.CurrentState() == 1)
    {
        double SLpips;
        double price = (double) gui.ed2.Text();

        if(side == "buy") SLpips = (price - SL("buy")) / _Point / 10;
        if(side == "sell") SLpips = fabs((price - SL("sell"))) / _Point / 10;

        // calcular el porcentaje
        double percent = tp_ == 1 ? (double) gui.ed16.Text() : (double) gui.ed17.Text();
        percent /= 100;
        TPpips = percent * SLpips;
    }

    // USA ATR
    if(gui.bt3.CurrentState() == 1)
    {
        double atr = iATR(NULL, 0, (int) gui.ed6.Text(), 1) / _Point / 10;
        TPpips = tp_ == 1 ? (int) gui.ed8.Text() * atr : (int) gui.ed9.Text() * atr;
    }

    if(takeProfitOn)
        switch(modeTP)
        {
            case FixPips:
                levelTP = new Levels(new ByFixPips(_Symbol, side, TPpips, "TP", Price(side)));
                result = levelTP.calculateLevel();
                break;

            case byMoney:
                levelTP = new Levels(new ByMoney(_Symbol, side, userLots, userTPmoney, "TP"));
                result = levelTP.calculateLevel();
                break;

            case PipsFromOpenCandle:
                levelSL = new Levels(new ByPipsFromCandle(_Symbol, side, userSLpips, "TP", 0, 1));
                result = levelSL.calculateLevel();
        }
    return result;
}
double Lots()
{
    lotProvider = new LotCalculator();
    double lots = -1;

    double money = RiskMoney();

    switch(modeCalcLots)
    {
        case Money:
            lots = lotProvider.LotsByMoney(money, levelSL.pips());
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
int Distancia(double precioA, double precioB, string par, string mode = "pips")
{
    double mPoint = MarketInfo(par, MODE_POINT);
    double dist = fabs(precioA - precioB);
    if(mode == "points") return (int) (dist / mPoint);
    if(mode == "pips") return (int) ((dist / mPoint) / 10);
    return 0;
}
void doBreackevenAction()
{
    for(int i = mainOrders.qnt() - 1; i >= 0; i--)
    {
        if(!mainOrders.index(i).breakevenWasDoIt())
        {
            breackevenCondition.setOrder(mainOrders.index(i));
            if(conditionsToBreackeven.EvaluateConditions())
            {
                breackevenAction = new MoveSL();
                breackevenAction.order(mainOrders.index(i)).newSL(mainOrders.index(i).price());
                breackevenAction.doAction();
                delete breackevenAction;
            }
        }
    }
}

void doPartialCloseAction()
{
    for(int i = 0; i < mainOrders.qnt(); i++)
    {
        double perToClose = mainOrders.index(i).countPartials() == 0 ? (double) gui.ed18.Text() : (double) gui.ed19.Text();

        partialCloseCondition.setOrder(mainOrders.index(i));

        if(conditionsToPartialClose.EvaluateConditions())
        {
            partialCloseAction = new PartialClose();
            partialCloseAction.order(mainOrders.index(i)).percent(perToClose);
            partialCloseAction.doAction();
            delete partialCloseAction;

            doMoveSL(mainOrders.index(i));
        }
    }
}

//////////////////////////////////////////////////////////////////////
// NOTE: OnInit
int OnInit()
{

    if(i_reason != REASON_CHARTCHANGE && i_reason != REASON_TEMPLATE && i_reason != REASON_PARAMETERS)
    {
        gui.Create(0, "EA", 0, 200, 0);
        gui.Run();
        GuiInitialization();
    }

    gui.setButton5Action(sendOrder = new SendOrder());
    gui.setButton6Action(actionCloseAll = new ActionCloseAll(magico));

    //--- CONDITIONS TO PARTIAL CLOSE:
    conditionsToPartialClose.AddCondition(partialCloseCondition = new PartialCloseCondition());

    EventSetTimer(1);
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    i_reason = reason;
    if(i_reason != REASON_CHARTCHANGE && i_reason != REASON_PARAMETERS)
    {
        gui.Destroy(reason);
    }

    deletePanelObjects();
}

void OnTick()
{
    // RefreshGui();
    mainOrders.cleanCloseOrders();
    doPartialCloseAction();
}

void OnTimer(void)
{
    RefreshGui();
}

void OnChartEvent(const int     id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam)
{
    gui.ChartEvent(id, lparam, dparam, sparam);
    gui.HoverEvents(id, lparam, dparam, sparam);
}

//////////////////////////////////////////////////////////////////////

// NOTE: RefreshGui
void RefreshGui()
{

    // Market Order:
    string side = gui.bt1.Text() == "Buy" ? "buy" : "sell";
    if(gui.bt2.CurrentState() == 0)
    {
        gui.ed2.Text(DoubleToString(Price(side), _Digits));
        gui.ed3.Text(DoubleToString(SL(side), _Digits));
        gui.ed4.Text(DoubleToString(TP(side, 1), _Digits));
        gui.ed5.Text(DoubleToString(TP(side, 2), _Digits));
    }

    // NOTE: Pending Order	
    if(gui.bt2.CurrentState() == 1)
    {
        // gui.ed2.Text(DoubleToString(Price(side),_Digits));
        gui.ed3.Text(DoubleToString(SL(side), _Digits));
        gui.ed4.Text(DoubleToString(TP(side, 1), _Digits));
        gui.ed5.Text(DoubleToString(TP(side, 2), _Digits));
    }

    // Money Mannagement
    gui.ed11.Text(DoubleToString(RiskMoney(), 2));

    drawPanelLevels();
}

// clang-format off

// NOTE: Initilization
void GuiInitialization()
{
    // Buttons:
    gui.OnClick_button1();
    gui.OnClick_button2();
    gui.OnClick_button3();
    gui.OnClick_button4();

    // Edits:
    gui.ed1.Text((string) AccountInfoDouble(ACCOUNT_EQUITY));
    gui.ed2.Text((string) Bid);
    gui.ed3.Text("0");
    gui.ed4.Text("0");
    gui.ed5.Text("0");

    // ATR:
    gui.ed6.Text((string) uATR_Periods);
    gui.ed7.Text((string) uATR_SL_Multiplier);
    gui.ed8.Text((string) uATR_TP1_Multiplier);
    gui.ed9.Text((string) uATR_TP2_Multiplier);

    // Money Mannagement
    gui.ed10.Text((string) uRiskPer); gui.ed11.Text(DoubleToString(RiskMoney(), 2));
    gui.ed12.Text((string) uRiskGBP); gui.ed13.Text("0");
    gui.ed14.Text((string) uReward);  gui.ed15.Text("0");

    // Take Profits:
    gui.ed16.Text((string) uTP1_value); gui.ed17.Text((string) uTP2_value);
    gui.ed18.Text((string) uTP1_Lots); gui.ed19.Text((string) uTP2_Lots);
    gui.ed20.Text((string) uTP1_MoveSL); gui.ed21.Text((string) uTP2_MoveSL);
}

double RiskMoney()
{
    double percent = (double) gui.ed10.Text();
    percent /= 100;

    double balance = (double) gui.ed1.Text();
    double riskMoney = balance * percent;

    return NormalizeDouble(riskMoney, 2);
}


void drawPanelLevels()
{
    deletePanelObjects();
    color clr;

    // Entry line:
    clr = entryColor;
    double entry = (double) gui.ed2.Text();
    string name = "panel_Entry";
    ObjectCreate(0, name, OBJ_TREND, 0, iTime(_Symbol, 0, 5), entry, TimeCurrent(), entry);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);

    // SL line
    clr = slColor;
    double precio = (double) gui.ed3.Text();
    name = "panel_SL";
    ObjectCreate(0, name, OBJ_TREND, 0, iTime(_Symbol, 0, 5), precio, TimeCurrent(), precio);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);

    // TPs:
    clr = tpColor;
    for(int i = 0; i < 2; i++)
    {
        double precio = i == 0 ? (double) gui.ed4.Text() : (double) gui.ed5.Text();
        if(precio == 0) return;

        string name = "panel_TP" + (string) (i + 1);

        ObjectCreate(0, name, OBJ_TREND, 0, iTime(_Symbol, 0, 5), precio, TimeCurrent(), precio);
        ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);
    }

}

void deletePanelObjects()
{
    ObjectsDeleteAll(0, "panel");
}


// gestionar el movimeinto del SL:

// NOTE: MOVE SL
void doMoveSL(Order* or )
{
    Print(__FUNCTION__, " Order.id()", or .id());
    int partials = or .countPartials();
    string side = or .type() == OP_BUY ? "buy" : "sell";

    // by Pips:
    double TPpips = 0;
    if(gui.bt4.CurrentState() == 0)
    {
        TPpips = partials == 1 ? (double) gui.ed16.Text() : (double) gui.ed17.Text();
    }

    // by Percent:
    if(gui.bt4.CurrentState() == 1)
    {
        double SLpips;
        double price = (double) gui.ed2.Text();

        if(side == "buy") SLpips = (price - SL("buy")) / _Point / 10;
        if(side == "sell") SLpips = fabs((price - SL("sell"))) / _Point / 10;

        // calcular el porcentaje
        double percent = partials == 1 ? (double) gui.ed16.Text() : (double) gui.ed17.Text();
        percent /= 100;
        TPpips = percent * SLpips;
    }


    // calculate new level
    levelSL = new Levels(new ByFixPips(_Symbol, side, TPpips, "SL", Price(side)));
    double sl = levelSL.calculateLevel();
    Print(__FUNCTION__, " sl: ", sl);

    // move sl
    moveSLAction = new MoveSL();
    moveSLAction.order(or ).newSL(sl);
    moveSLAction.doAction();

    delete moveSLAction;
    delete levelSL;
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+