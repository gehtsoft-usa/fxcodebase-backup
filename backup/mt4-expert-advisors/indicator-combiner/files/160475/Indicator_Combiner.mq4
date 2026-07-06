// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76295
//
// Copyright © 2025, Gehtsoft USA LLC
// Website: http://fxcodebase.com
// PayPal: https://goo.gl/9Rj74e
//
// Developed by: Mario Jemic
// Email: mario.jemic@gmail.com
// Website: https://mario-jemic.com
// Patreon: http://tiny.cc/1ybwxz
// Buy Me a Coffee: http://tiny.cc/bj7vxz
//
// Crypto Donations
// BTC  : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
// SOL  : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
// ETH / BNB / USDT / XRP (ERC20 & BEP20) : 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

double Indicator1Buy[];
double Indicator1Sell[];
double Indicator2Buy[];
double Indicator2Sell[];

#define Section_Arquitecture
#ifdef Section_Arquitecture
// MARK: arquitecture

interface iConditions { bool evaluate(int index); };
interface iActions { bool execute(int index); };

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

    bool evaluate(int _index)
    {
        for (int i = 0; i < ArraySize(_conditions); i++) {
            if (!_conditions[i].evaluate(_index)) {
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

    bool execute(int _index)
    {
        for (int i = 0; i < ArraySize(_actions); i++) {
            if (!_actions[i].execute(_index)) {
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

    bool execute(int _index)
    {
        bool result = false;

        if (_mode == true)
            if (conditions.evaluate(_index)) {
                result = actions.execute(_index);
            }

        if (_mode == false)
            if (!conditions.evaluate(_index)) {
                result = actions.execute(_index);
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

    bool execute(int _index)
    {
        for (int i = 0; i < ArraySize(_strategys); i++) {
            _strategys[i].execute(_index);
        }
        return true;
    }
};

class Trading
{
  public:
    Trading() { ; }
    ~Trading() { ; }

    Strategys strategys;

    void doTrading(int _index) { strategys.execute(_index); }
};
Trading Trader();

#endif

#define Section_Custom_Indicator
#ifdef Section_Custom_Indicator
// MARK: Custom Indicator

// ------------------------------------------------------------------
#property description "--- IMPORTANT ---"
#property description "This EA request to have installed the indicator file"
#property description "in the folder: MQL4/Indicators"
// ------------------------------------------------------------------

input string       indi1_Tcustom                     = "==== Indicator Setup ====";   // ————————————————————————
input const string indi1_file                        = "AJ_ARROW";                            // Indicator File:
input int          indi1_buffer_To_Buy               = 1;                             // Buy Buffer
input int          indi1_buffer_To_Sell              = 0;                             // Sell Buffer
input int          indi1_candles                     = 1;                             // How many candles back to check for signals
input string       indi1_tBuy                        = "==== Condition To Buy ====";  // ————————————————————————
input bool         indi1_condition_Buy_Not_Empty     = true;                          // Condition is signal not empty (arrows)
input double       indi1_condition_Buy_Greater_Than  = 0;                             // Condition is signal greater than (lines value)
input double       indi1_condition_Buy_Lower_Than    = 0;                             // Condition is signal lower than (lines value)
input string       indi1_tSell                       = "==== Condition To Sell ===="; // ————————————————————————
input bool         indi1_condition_Sell_Not_Empty    = true;                          // Condition is signal not empty (arrows)
input double       indi1_condition_Sell_Greater_Than = 0;                             // Condition is signal greater than (lines value)
input double       indi1_condition_Sell_Lower_Than   = 0;                             // Condition is signal lower than (lines value)
input string       indi2_Tcustom                     = "==== Indicator Setup ====";   // ————————————————————————
input const string indi2_file                        = "CCI";                            // Indicator File:
input int          indi2_buffer_To_Buy               = 0;                             // Buy Buffer
input int          indi2_buffer_To_Sell              = 0;                             // Sell Buffer
input int          indi2_candles                     = 1;                             // How many candles back to check for signals
input string       indi2_tBuy                        = "==== Condition To Buy ====";  // ————————————————————————
input bool         indi2_condition_Buy_Not_Empty     = false;                          // Condition is signal not empty (arrows)
input double       indi2_condition_Buy_Greater_Than  = 0;                             // Condition is signal greater than (lines value)
input double       indi2_condition_Buy_Lower_Than    = -100;                             // Condition is signal lower than (lines value)
input string       indi2_tSell                       = "==== Condition To Sell ===="; // ————————————————————————
input bool         indi2_condition_Sell_Not_Empty    = false;                          // Condition is signal not empty (arrows)
input double       indi2_condition_Sell_Greater_Than = 100;                             // Condition is signal greater than (lines value)
input double       indi2_condition_Sell_Lower_Than   = 0;                             // Condition is signal lower than (lines value)

//---

class ConditionIndicator : public iConditions
{
    string file;
    double lastSignal;
    int    candles;
    int    buffer;
    bool   condition_Not_Empty;
    double condition_Greater_Than;
    double condition_Lower_Than;

    double Indi(int index = 1) { return iCustom(NULL, 0, file, buffer, index); }

  public:
    ConditionIndicator(string _file, int _candles, int _buffer, bool _condition_Not_Empty, double _condition_Greater_Than, double _condition_Lower_Than)
        : file(_file), candles(_candles), buffer(_buffer), condition_Not_Empty(_condition_Not_Empty), condition_Greater_Than(_condition_Greater_Than), condition_Lower_Than(_condition_Lower_Than)
    {
        ;
    }
    ~ConditionIndicator(void) { ; }

    bool evaluate(int index)
    {
        for (int i = index; i <= index+candles; i++) {
            double indi = Indi(i);

            if (condition_Not_Empty == true && indi > 0 && indi != EMPTY_VALUE && indi != lastSignal) {
                lastSignal = indi;
                return true;
            }
            if (condition_Greater_Than > 0 && indi > condition_Greater_Than && indi != lastSignal) {
                lastSignal = indi;
                return true;
            }
            if (condition_Lower_Than != 0 && indi < condition_Lower_Than && indi != lastSignal) {
                lastSignal = indi;
                return true;
            }
        }
        return false;
    }
};

ConditionIndicator cd_indi1_buy(indi1_file, indi1_candles, indi1_buffer_To_Buy, indi1_condition_Buy_Not_Empty, indi1_condition_Buy_Greater_Than, indi1_condition_Buy_Lower_Than);
ConditionIndicator cd_indi1_sell(indi1_file, indi1_candles, indi1_buffer_To_Sell, indi1_condition_Sell_Not_Empty, indi1_condition_Sell_Greater_Than, indi1_condition_Sell_Lower_Than);
ConditionIndicator cd_indi2_buy(indi2_file, indi2_candles, indi2_buffer_To_Buy, indi2_condition_Buy_Not_Empty, indi2_condition_Buy_Greater_Than, indi2_condition_Buy_Lower_Than);
ConditionIndicator cd_indi2_sell(indi2_file, indi2_candles, indi2_buffer_To_Sell, indi2_condition_Sell_Not_Empty, indi2_condition_Sell_Greater_Than, indi2_condition_Sell_Lower_Than);


#endif

#define Section_Indicators_Combiner
#ifdef Section_Indicators_Combiner
// Mark: Section_Indicators_Combiner

class ActionUP : public iActions
{
  public:
    bool execute(int _index)
    {
        ArrowUp[_index] = Low[_index] - (0.5 * (High[_index] - Low[_index]));
        return true;
    }
};
ActionUP acUP;
class ActionDN : public iActions
{
  public:
    bool execute(int _index)
    {
        ArrowDn[_index] = High[_index] - (0.5 * (High[_index] - Low[_index]));
        return true;
    }
};
ActionDN acDN;

Strategy st_Signal_UP;
Strategy st_Signal_DN;

void OnInit_Combiner()
{
    st_Signal_UP.set(&cd_indi1_buy, &acUP);
    st_Signal_UP.addCondition(&cd_indi2_buy);

    st_Signal_DN.set(&cd_indi1_sell, &acDN);
    st_Signal_DN.addCondition(&cd_indi2_sell);

    Trader.strategys.add(&st_Signal_UP);
    Trader.strategys.add(&st_Signal_DN);
}

#endif

// ------------------------------------------------------------------

input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:

// ------------------------------------------------------------------

int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);

    //---
    OnInit_Combiner();

    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int i = rates_total - prev_calculated + 1;
    if (i >= rates_total) i = rates_total - 1;

    for (; i > 0; i--) {
        Trader.doTrading(i);

        if(i== 0)
        {
            if(ArrowUp[i+1] != EMPTY_VALUE) notify(0);
            if(ArrowDn[i+1] != EMPTY_VALUE) notify(1);
        }

    }

    return (rates_total);
}

void notify(int type)
{
    if (IsNewCandle()) {
        Notifications(type);
    }
}

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

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


bool IsNewCandle()
{
    static datetime last;
    datetime        current = iTime(NULL, 0, 1);
    if (last != current) {
        last = current;
        return true;
    }
    return false;
}
// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76295
//
// Copyright © 2025, Gehtsoft USA LLC
// Website: http://fxcodebase.com
// PayPal: https://goo.gl/9Rj74e
//
// Developed by: Mario Jemic
// Email: mario.jemic@gmail.com
// Website: https://mario-jemic.com
// Patreon: http://tiny.cc/1ybwxz
// Buy Me a Coffee: http://tiny.cc/bj7vxz
//
// Crypto Donations
// BTC  : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
// SOL  : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
// ETH / BNB / USDT / XRP (ERC20 & BEP20) : 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7