//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74053

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>

#define GUI_ON

int mReason;

//--- indicator buffers
double ArrowUp [];
double ArrowDn [];
double LineFast [];
double LineSlow [];

// ------------------------------------------------------------------

input int    fastPeriods = 5;
input int    slowPeriods = 20;
int fastPer = fastPeriods;
int slowPer = slowPeriods;

input string T1 = "== Notifications ==";  // === Notifications ===
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
input string T2 = "== Set Lines ==";      // === Set  Lines ===
input bool   LinesOn = true;                   // Line On?
input color  LineUpClr = clrBlue;                // Line Up Color:
input color  LineDnClr = clrRed;                 // Line Down Color:
input string T3 = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:

// ------------------------------------------------------------------


interface iActions
{
  bool doAction();
};

// NOTE: GUI 
// ------------------------------------------------------------------
#ifdef GUI_ON

bool OnInit_GUI()
{
    bool res = true;
    // if(gui.reason() != REASON_CHARTCHANGE && gui.reason() != REASON_TEMPLATE && gui.reason() != REASON_PARAMETERS)
    // {
        res = gui.Create(0, "Moving Average Pannel", 0, 400, 0, 590, 110);

        gui.setButton1Action(&btnPlusFast);
        gui.setButton2Action(&btnMinusFast);
        gui.setButton3Action(&btnPlusSlow);
        gui.setButton4Action(&btnMinusSlow);
        gui.edit1.Text((string) fastPer);
        gui.edit2.Text((string) slowPer);
    
        if(res) gui.Run();
    // }
    return res;
}

void OnDeinit_GUI(int reason)
{
    // gui.reason(reason);
    // Print(__FUNCTION__, " reason ", reason);
    // if(gui.reason() != REASON_CHARTCHANGE && gui.reason() != REASON_PARAMETERS)
    // {
        gui.Destroy(reason);
    // }
}

// NOTE: Buttons Actions
class PlusFastMA : public iActions
{
    bool doAction()
    {
        fastPer += 1;
        return true;
    }
};
PlusFastMA btnPlusFast();

class MinusFastMA : public iActions
{
    bool doAction()
    {
        fastPer -= 1;
        if(fastPer <= 1) fastPer = 1;
        return true;
    }
};
MinusFastMA btnMinusFast();

class PlusSlowMA : public iActions
{
    bool doAction()
    {
        slowPer += 1;
        return true;
    }
};
PlusSlowMA btnPlusSlow();

class MinusSlowMA : public iActions
{
    bool doAction()
    {
        slowPer -= 1;
        if(slowPer <= 1) slowPer = 1;
        return true;
    }
};
MinusSlowMA btnMinusSlow();

// clang-format off
class GUI : public CAppDialog
{

    int _magic;
    int _high, _width, _widthEdit;
    int _x, _y;
    int _gapV, _gapH;
    int _reason; // la voy a usar para cuando se resetea el EA
    iActions* button1Action;
    iActions* button2Action;
    iActions* button3Action;
    iActions* button4Action;

    public:
    GUI(int magic = 0)
    {
        _high = 18;
        _width = 30;
        _widthEdit = 50;
        _x = 10;
        _y = 10;
        _gapV = 3;
        _gapH = 5;
        _magic = magic;
    }
    ~GUI()
    {
        delete button1Action;
        delete button2Action;
        delete button3Action;
        delete button4Action;
    }

    CLabel  lb1, lb2;
    CButton bt1, bt2, bt3, bt4;
    CEdit   edit1, edit2;

    void setButton1Action(iActions* action) { button1Action = action; }
    void setButton2Action(iActions* action) { button2Action = action; }
    void setButton3Action(iActions* action) { button3Action = action; }
    void setButton4Action(iActions* action) { button4Action = action; }


    void reason(int inpreason) { _reason = inpreason; }
    int  reason(void) { return _reason; }

    // Create Pannel:
    // ------------------------------------------------------------------
    int Row(int r) { return _x + (r * _high) + r * _gapV; }
    int Col(int c) { return _y + (c * _width) + c * _gapH; }

    bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
    {

        if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;

        if(!Create_button("minF", Col(2), Row(0), _high, _width, bt2, "-")) return false;
        if(!Create_button("plusF", Col(3), Row(0), _high, _width, bt1, "+")) return false;
        if(!Create_Edit("Fast_MA", Col(1), Row(0), _high, _width, edit1)) return false;

        if(!Create_button("minS", Col(2), Row(1), _high, _width, bt4, "-")) return false;
        if(!Create_button("plusS", Col(3), Row(1), _high, _width, bt3, "+")) return false;
        if(!Create_Edit("Slow_MA", Col(1), Row(1), _high, _width, edit2)) return false;

        if(!Create_label("Fast", Col(0), Row(0), _high, _width, lb1)) return false;
        if(!Create_label("Slow", Col(0), Row(1), _high, _width, lb2)) return false;
        
        return true;
    }
    
    virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);

    void HoverEvents(const int id, const long& lparam, const double& dparam, const string& sparam)
    {
        if(bt1.IsActive()) bt1.ColorBackground(RoyalBlue); else bt1.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(bt2.IsActive()) bt2.ColorBackground(RoyalBlue); else bt2.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(bt3.IsActive()) bt3.ColorBackground(RoyalBlue); else bt3.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
        if(bt4.IsActive()) bt4.ColorBackground(RoyalBlue); else bt4.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
    }

    protected:
    void OnEndEdit_edit1() { fastPer = (int)edit1.Text(); Recalculate(); }
    void OnEndEdit_edit2() { slowPer = (int)edit2.Text(); Recalculate(); }
    void OnClick_button1() { button1Action.doAction(); edit1.Text(fastPer); Recalculate(); }
    void OnClick_button2() { button2Action.doAction(); edit1.Text(fastPer); Recalculate(); }

    void OnClick_button3() { button3Action.doAction(); edit2.Text(slowPer); Recalculate(); }
    void OnClick_button4() { button4Action.doAction(); edit2.Text(slowPer); Recalculate(); }

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
    bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton& bt, string txt)
    {
        int x2 = x1 + width;
        int y2 = y1 + high;

        bt.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
        bt.Text(txt);
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
ON_EVENT(ON_END_EDIT, edit1, OnEndEdit_edit1)
ON_EVENT(ON_END_EDIT, edit2, OnEndEdit_edit2)
ON_EVENT(ON_CLICK, bt1, OnClick_button1)
ON_EVENT(ON_CLICK, bt2, OnClick_button2)
ON_EVENT(ON_CLICK, bt3, OnClick_button3)
ON_EVENT(ON_CLICK, bt4, OnClick_button4)
EVENT_MAP_END(CAppDialog)

GUI gui();

#endif
// ------------------------------------------------------------------

class CNewCandle
{
    private:
    int    _initialCandles;
    string _symbol;
    int    _tf;

    public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
    CNewCandle()
    {
        // toma los valores del chart actual
        _initialCandles = iBars(Symbol(), Period());
        _symbol = Symbol();
        _tf = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if(_currentCandles > _initialCandles)
        {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineFast, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
    SetIndexLabel(0, "Line Fast");

    SetIndexBuffer(1, LineSlow, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
    SetIndexLabel(1, "Line Slow");

    if(!LinesOn)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(2, 233);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexLabel(2, "Arrow Up");

    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(3, 234);
    SetIndexLabel(3, "Arrow Dn");

    if(!ArrowsOn)
    {
        SetIndexStyle(2, DRAW_NONE);
        SetIndexStyle(3, DRAW_NONE);
    }

    //---

    if(!OnInit_GUI()) { return INIT_FAILED; }

  //--- 
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

void OnChartEvent(const int     id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam)
{
    gui.ChartEvent(id, lparam, dparam, sparam);
    gui.HoverEvents(id, lparam, dparam, sparam);
}


// NOTE: Ondeinit
void OnDeinit(const int reason)
{
    mReason = reason;
    OnDeinit_GUI(reason);
}

// ------------------------------------------------------------------
bool reiniciar = false;

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{
    int start, i;
    if(prev_calculated == 0) { start = rates_total - slowPeriods; }
    // else { start = rates_total - (prev_calculated - 1); }
    else { start = 500; }

    if(reiniciar) start = 500;
    
    for(i = start; i >= 0; i--)
    {
        if(ConditionsToLineUp(i)) { LineFast[i] = valueLineFast(i); }
        if(ConditionsToLineDn(i)) { LineSlow[i] = valueLineSlow(i); }

        if(haveSignalUp(i))
        {
            ArrowUp[i] = LineSlow[i]-20 *_Point;
            notify(0);
        }

        if(haveSignalDown(i))
        {
            ArrowDn[i] = LineSlow[i]+20 *_Point;
            notify(1);
        }
    }
    reiniciar = false;
    return (rates_total);
}

// ------------------------------------------------------------------

double valueLineFast(int i)
{
    double sum = 0;
    for(int j = 0; j < fastPer; j++)
    {
        sum += iClose(NULL, 0, i + j);
    }
    return sum / fastPer;
}

double valueLineSlow(int i)
{
    double sum = 0;
    for(int j = 0; j < slowPeriods; j++)
    {
        sum += iClose(NULL, 0, i + j);
    }
    return sum / slowPeriods;
}

bool ConditionsToLineUp(int i)
{
    return true;
}

bool ConditionsToLineDn(int i)
{
    return true;
}

bool haveSignalUp(int i)
{
    // TODO: signal up
  //   return (iClose(NULL, 0, i + 2) > iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) > iOpen(NULL, 0, i + 1));
    return LineFast[i] > LineSlow[i] && LineFast[i + 1] <= LineSlow[i + 1];
    // return true;
}

bool haveSignalDown(int i)
{
    // TODO: signal down
  //   return (iClose(NULL, 0, i + 2) < iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) < iOpen(NULL, 0, i + 1));
    return LineFast[i] < LineSlow[i] && LineFast[i + 1] >= LineSlow[i + 1];
    // return true;
}

void notify(int type)
{
    if(newCandle.IsNewCandle())
    {
        Notifications(type);
    }
}

void Notifications(int type)
{
    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if(!notifications)
        return;
    if(desktop_notifications)
        Alert(text);
    if(push_notifications)
        SendNotification(text);
    if(email_notifications)
        SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
        case PERIOD_M1: return ("M1");
        case PERIOD_M5: return ("M5");
        case PERIOD_M15: return ("M15");
        case PERIOD_M30: return ("M30");
        case PERIOD_H1: return ("H1");
        case PERIOD_H4: return ("H4");
        case PERIOD_D1: return ("D1");
        case PERIOD_W1: return ("W1");
        case PERIOD_MN1: return ("MN1");
    }
    return IntegerToString(lPeriod);
}

void Recalculate()
{
  for (int i = 0; i < ArraySize(LineFast); i++) {
      LineFast[i] = EMPTY_VALUE;
      LineSlow[i] = EMPTY_VALUE;
      ArrowUp[i] = EMPTY_VALUE;
      ArrowDn[i] = EMPTY_VALUE;
      
  }
    // ArrayFree(ArrowDn);
    // ArrayFree(ArrowUp);
    // ArrayFree(LineSlow);
    // ArrayFree(LineFast);
    reiniciar = true;
    
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