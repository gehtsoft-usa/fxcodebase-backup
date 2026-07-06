// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74732s

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description "Expert Advisor"
#property strict

#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>

// Gobal Variables
// ------------------------------------------------------------------
int AllowedAccount= 888342294;
datetime ExpireDate = D'2025.12.31';
// ------------------------------------------------------------------

// NOTE: inputs
// ------------------------------------------------------------------
input double uProfitGoal = 8;  // Profit Goal (Account %)
input double uStopOut    = 10; // Stop Out (Account %)

double maxLots = 0;

// Classes
// ------------------------------------------------------------------
interface iActions
{
    bool doAction();
};

#define stadistics
#ifdef stadistics

class Stats
{
    int    magic;
    int    q_trades;
    int    q_buys;
    int    q_sells;
    int    q_buys_pending;
    int    q_sells_pending;
    double lots_buys;
    double lots_sells;
    double lots_open;
    double lots_buys_pending;
    double lots_sells_pending;
    double profit_buys;
    double profit_sells;
    double open_profit;
    datetime startTime;
    double max_drowDown;
   
   public:
    Stats(int _magic) : magic(_magic) { startTime=TimeCurrent(); }
    Stats(){ startTime=TimeCurrent(); }
    ~Stats() { ; }

    // clang-format off
    int    q_Trades()            { RefreshStats(); return q_trades; }
    int    q_Buys()              { RefreshStats(); return q_buys; }
    int    q_Sells()             { RefreshStats(); return q_sells; }
    int    q_Buys_Pending()      { RefreshStats(); return q_buys_pending; }
    int    q_Sells_Pending()     { RefreshStats(); return q_sells_pending; }
    double lots_Buys()           { RefreshStats(); return lots_buys; }
    double lots_Sells()          { RefreshStats(); return lots_sells; }
    double lots_Open()           { RefreshStats(); return lots_open; }
    double lots_Buys_Pending()   { RefreshStats(); return lots_buys_pending; }
    double lots_Sells_Pending()  { RefreshStats(); return lots_sells_pending; }
    double profit_Buys()         { RefreshStats(); return profit_buys; }
    double profit_Sells()        { RefreshStats(); return profit_sells; }
    double open_Profit()         { RefreshStats(); return open_profit; }
  
    // clang-format on

    void toZero()
    {
        q_trades           = 0;
        q_buys             = 0;
        q_sells            = 0;
        q_buys_pending     = 0;
        q_sells_pending    = 0;
        profit_sells       = 0;
        profit_buys        = 0;
        open_profit        = 0;
        lots_buys          = 0;
        lots_sells         = 0;
        lots_open          = 0;
        lots_buys_pending  = 0;
        lots_sells_pending = 0;
    }

    void Normalize()
    {
        profit_buys  = NormalizeDouble(profit_buys, 2);
        profit_sells = NormalizeDouble(profit_sells, 2);
        open_profit  = NormalizeDouble(open_profit, 2);
    }

    void RefreshStats()
    {
        toZero();
        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if(OrderSelect(i, SELECT_BY_POS))
            {
                double profit = OrderProfit() + OrderCommission() + OrderSwap();

                q_trades++;
                lots_open += OrderLots();
                open_profit += profit;
                
                MaxDrowDown(open_profit);

                if (OrderType() == OP_BUY)
                {
                    q_buys++;
                    profit_buys += profit;
                    lots_buys += OrderLots();
                }
                if (OrderType() == OP_SELL)
                {
                    q_sells++;
                    profit_sells += profit;
                    lots_sells += OrderLots();
                }
                if (OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)
                {
                    q_buys_pending++;
                    lots_buys_pending += OrderLots();
                }
                if (OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
                {
                    q_sells_pending++;
                    lots_sells_pending += OrderLots();
                }
            }
        }
        Normalize();
    }

    double ProfitToday()
    {
        datetime iniDay = iTime(NULL, PERIOD_D1, 0);

        double profit = 0;
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
                if (OrderCloseTime() >= iniDay) {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }
        return NormalizeDouble(profit, 2);
    }
    double ProfitMonth()
    {
        datetime iniDay = iTime(NULL, PERIOD_MN1, 0);

        double profit = 0;
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
                if (OrderCloseTime() >= iniDay) {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }
        return NormalizeDouble(profit, 2);
    }
    double ProfitWeek()
    {
        datetime iniDay = iTime(NULL, PERIOD_W1, 0);

        double profit = 0;
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
                if (OrderCloseTime() >= iniDay) {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }
        return NormalizeDouble(profit, 2);
    }
    double ProfitYesterday()
    {
        datetime iniDay = iTime(NULL, PERIOD_D1, 1);
        datetime endDay = iTime(NULL, PERIOD_D1, 0);

        double profit = 0;
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
                if (OrderCloseTime() >= iniDay && OrderCloseTime() <= endDay) {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }
        return NormalizeDouble(profit, 2);
    }
    double ProfitFromStart()
    {
        double profit = 0;
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
                if (OrderCloseTime() >= startTime) {
                    profit += OrderProfit() + OrderSwap() + OrderCommission();
                }
            }
        }
        return NormalizeDouble(profit, 2);
    }
    double ProfitWin()
    {
        double profit = 0;
        double sum = 0;
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
                if (OrderCloseTime() >= startTime) {
                    sum = OrderProfit() + OrderSwap() + OrderCommission();
                    if(sum >0)profit += sum;
                }
            }
        }
        return NormalizeDouble(profit, 2);
    }
    double ProfitLoss()
    {
        double profit = 0;
        double sum = 0;
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
                if (OrderCloseTime() >= startTime) {
                    sum = OrderProfit() + OrderSwap() + OrderCommission();
                    if(sum < 0)profit += sum;
                }
            }
        }
        return NormalizeDouble(profit, 2);
    }
    double PL()
    {
            double pl = ProfitWin()/ProfitLoss();
            return NormalizeDouble(pl,2);
    }
    void MaxDrowDown(double floating)
    {
        if(floating < max_drowDown || max_drowDown==0) {
            max_drowDown = floating;
        }
    }
    double MaxDrowDown() { return NormalizeDouble(max_drowDown,2); }

double open_Profits_balance_percent ()   { 
    RefreshStats(); 
    double bal = AccountInfoDouble(ACCOUNT_BALANCE);
    double profits_in_bal_percent = NormalizeDouble(open_profit*100/bal, 2);
    return profits_in_bal_percent; }

};

Stats stats();
#endif 

// NOTE: GUI
// ------------------------------------------------------------------
#define GUI_ON
#ifdef GUI_ON



bool OnInit_GUI()
{
    ChartSetDouble(0, CHART_SHIFT_SIZE, 30);
    ChartSetInteger(0, CHART_FOREGROUND, 0, false);
    bool res = true;
    if (gui.reason() != REASON_CHARTCHANGE && gui.reason() != REASON_TEMPLATE && gui.reason() != REASON_PARAMETERS) {
        int x1 = 10;
        int x2 = 230;
        int y1 = 10;
        int y2 = 240;

        res = gui.Create(0, "Mywalletfx", 0, x1, y1, x2, y2);
        if (res)
            gui.Run();
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

// NOTE: Refresh
void RefreshGUI()
{

    stats.RefreshStats();
    // balance
    gui.RefreshLabelText(DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2), gui.lb_balance);
    // # trades:
    gui.RefreshLabelText((string)stats.q_Trades(), gui.lb_trades);
    // Floating
    gui.RefreshLabelText(DoubleToString(stats.open_Profit(), 2), gui.lb_floating);
    // # Goal:
    gui.RefreshLabelText((string)uProfitGoal + " % ", gui.lb_goal);
    // Stop
    gui.RefreshLabelText((string)uStopOut + " % ", gui.lb_stop);
    
    // Maximum Lots
    double lots = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE) / 200000, 2);
    gui.RefreshLabelText(DoubleToString(lots, 2), gui.lb_lots);
    maxLots = lots;
    // Max Drawdown
    gui.RefreshLabelText(DoubleToString((stats.MaxDrowDown()/AccountInfoDouble(ACCOUNT_BALANCE))*100,2) + " % ", gui.lb_dd);
}

// clang-format off
class GUI : public CAppDialog
{
    int _magic;
    int _high, _width;
    int _x, _y;
    int _gapV, _gapH;
    int _reason; // la voy a usar para cuando se resetea el EA
    iActions* button1Action;
    iActions* button2Action;
    iActions* button3Action;

    public:
    GUI(int magic = 0)
    {
        _high = 18;
        _width = 75;
        _x = 10;
        _y = 10;
        _gapV = 3;
        _gapH = 10;
        _magic = magic;
    }
    ~GUI()
    {
        // delete button1Action;
        // delete button2Action;
        // delete button3Action;
    }

    CLabel  lb_floating, lb_balance, lb_trades, lb_goal, lb_stop, lb_lots, lb7, lb8,lb_dd;
    CButton bt1, bt2, bt3;
    CEdit   edit1, edit2;

    void setButton1Action(iActions* action) { button1Action = action; }
    void setButton2Action(iActions* action) { button2Action = action; }
    void setButton3Action(iActions* action) { button3Action = action; }

    void reason(int inpreason) { _reason = inpreason; }
    int  reason(void) { return _reason; }
    
    // Create Pannel:
    // ------------------------------------------------------------------
    int Row(int r) { return _x + (r * _high) + r * _gapV; }
    int Col(int c) { return _y + (c * _width) + c * _gapH; }

    bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
    {

        if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;

        if(!Create_label("Balance:", Col(0), Row(0), _high, _width, lb_balance)) return false;
        if(!Create_label("#Trades:", Col(0), Row(1), _high, _width, lb_trades)) return false;
        if(!Create_label("Floating:", Col(0), Row(2), _high, _width, lb_floating)) return false;
        if(!Create_label("Profit Goal:", Col(0), Row(3), _high, _width, lb_goal)) return false;
        if(!Create_label("Stopout Level:", Col(0), Row(4), _high, _width, lb_stop)) return false;
        if(!Create_label("Maximum Lot:", Col(0), Row(5), _high, _width, lb_lots)) return false;
        if(!Create_label("Maximum Drawdown:", Col(0), Row(6), _high, _width, lb_dd)) return false;

        return true;
    }

    virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);

    void HoverEvents(const int id, const long& lparam, const double& dparam, const string& sparam)
    {
        // if(bt1.IsActive()) bt1.ColorBackground(RoyalBlue); else bt1.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        // if(bt2.IsActive()) bt2.ColorBackground(RoyalBlue); else bt2.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
    }

    void RefreshLabelText(string txt, CLabel& label)
    {
        label.Text(StringConcatenate(label.Name(), "    ", txt));
    }

    protected:
    // void OnEndEdit_edit1(){ Print("edit 1 ok");}
    // void OnEndEdit_edit2(){ Print("edit 2 ok");}
    // void OnClick_button1(){ button1Action.doAction();}
    // void OnClick_button2(){ button2Action.doAction();}
    // void OnClick_button3(){ button3Action.doAction();}

    bool Create_label(string name, int x1, int y1, int high, int width, CLabel& label)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        label.Create(m_chart_id, name, 0, x1, y1, x2, y2);
        label.Text(name);
        label.Font("Calibri");
        label.Color(C'80,80,80');
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
        ed.Text("0");
        ed.Font("Calibri");
        ed.FontSize(10);

        Add(ed);
        return true;
    }

};

//Mapa de eventos (MACRO substituciones)
EVENT_MAP_BEGIN(GUI)
// ON_EVENT(ON_END_EDIT, edit1, OnEndEdit_edit1)
// ON_EVENT(ON_END_EDIT, edit2, OnEndEdit_edit2)
// ON_EVENT(ON_CLICK, bt1, OnClick_button1)
// ON_EVENT(ON_CLICK, bt2, OnClick_button2)
// ON_EVENT(ON_CLICK, bt3, OnClick_button3)
EVENT_MAP_END(CAppDialog)

GUI    gui();
#endif


// NOTE: License
#define LICENSE_CONTROL_ON
#ifdef LICENSE_CONTROL_ON

class ConditionLicense
{
 private:
  string   _names[];
  datetime _date;
  int      _accounts[];

 public:
  ConditionLicense(const string name) { addName(name);       }
  ConditionLicense(datetime date)     { _date = date;        }
  ConditionLicense(int account)       { addAccount(account); }
  ~ConditionLicense() {}

  void addDate(datetime dt) { _date = dt; }

  bool addName(string name)
  {
    int t = ArraySize(_names);
    if (ArrayResize(_names, t + 1))
    {
      _names[t] = name;
      return true;
    }
    return false;
  }

  bool addAccount(int account)
  {
    int t = ArraySize(_accounts);
    if (ArrayResize(_accounts, t + 1))
    {
      _accounts[t] = account;
      return true;
    }
    return false;
  }

  bool controlByName()
  {
    for (int i = 0; i < ArraySize(_names); i++)
    {
      string name        = _names[i];
      string accountName = AccountInfoString(ACCOUNT_NAME);

      if (StringToUpper(name) && StringToUpper(accountName))
      {
        if (name == accountName)
        {
          return true;
        }
      }

      // busca si coincide una parte de name dentro de accountName:
      if (StringFind(accountName, name, 0) != -1)
      {
        return true;
      }
    }

    Alert("Account Without Licences");
    return false;
  }

  bool controlByDate()
  {
    datetime today = TimeCurrent();
    if (today >= _date)
    {
      Alert("Licences Expire");
      return false;
    }
    return true;
  }

  bool controlByAccount()
  {
    int accountNumber = AccountNumber();
    for (int i = 0; i < ArraySize(_accounts); i++)
    {
      if (_accounts[i] == accountNumber) { return true; }
    }
    return false;
  }
};
ConditionLicense license(AllowedAccount);
#endif


#define NOTIFICATIONS_ON
#ifdef NOTIFICATIONS_ON
input string TZ                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
int    minutesBetwenNotify   = 1;                     // Minutes Betwen Notifications
int    timeNextNotify        = 0;
#endif


//////////////////////////////////////////////////////////////////////
int OnInit() {

    license.addDate(ExpireDate);
    if(!license.controlByAccount()){ return (INIT_FAILED); }
    if(!license.controlByDate()){ return (INIT_FAILED); }

    if(!OnInit_GUI()) { return (INIT_FAILED); }

    EventSetMillisecondTimer(100);

    return(INIT_SUCCEEDED);
}
 
void OnDeinit(const int reason) { 
    OnDeinit_GUI(reason);
}
 
void OnTick() {
    // RefreshGUI();
    // ControlProfits();
    if(IsTesting()) { test(); }
}
 
void OnTimer(void) {
    RefreshGUI();
    ControlProfits();
}
 
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam){
    gui.OnEvent(id, lparam, dparam, sparam);
}
 
void ControlProfits()
{
    Print(__FUNCTION__," stats.open_Profits_balance_percent(): ",stats.open_Profits_balance_percent());
    
    if(stats.open_Profits_balance_percent() > uProfitGoal)
    {
        CloseAllTrades();
        Notifications("win");
    }
    if(stats.open_Profits_balance_percent() < -uStopOut)
    {
        CloseAllTrades();
        Notifications("loss");
    }
}


void CloseAllTrades()
{
    double _price=0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS)) {
            if (OrderType() == OP_BUY) { _price = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID); }
            if (OrderType() == OP_SELL){ _price = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK); }
        if (!OrderClose(OrderTicket(), OrderLots(), _price, 100000, clrNONE)) {
            Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
            }
        }
    }
}


void test(){
   if(OrdersTotal()<2){
   
        double pr = Price("buy");
        double tp = 0;
        double sl = 0;
 
        if(OrderSend(NULL, OP_BUY, maxLots, pr, 1000, sl, tp, "", 0, 0, clrNONE)){;}
   }
}

double Price(string side)
{    
    double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    if (side == "sell") return bid;
    if (side == "buy") return ask;
    return 0;
}


void Notifications(string type)
{

    string text = _Symbol + " " + GetTimeFrame(_Period) + " : ";
    if (type == "win") text += " REACH THE GOAL LIMIT " + (string)uProfitGoal + " %";
    if (type == "loss") text += " REACH THE STOPUT LIMIT " + (string)uStopOut + " %" ;


    if (!notifications) return;
    if (desktop_notifications) Alert(text);
    if (push_notifications) SendNotification(text);
    if (email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch (lPeriod) {
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