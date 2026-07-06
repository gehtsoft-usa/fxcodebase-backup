//Available @   https://fxcodebase.com/code/viewtopic.php?f=38&t=74899

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
 
 
#property strict
input int             Back             = 10;          // days back
input int             uExpansion       = 2;           // Expand fibos:
input int             DWidthlines      = 0;
input ENUM_LINE_STYLE DFiboStyle       = STYLE_SOLID; //  level style?
extern bool           D_Indicator_On   = true;
extern color          D_UpperFiboColor = Black;
extern bool           D_UpperFiboOn    = true;
extern color          D_MainFiboColor  = Black;
extern bool           D_MainFiboOn     = true;
extern color          D_LowerFiboColor = Black;
extern bool           D_LowerFiboOn    = true;
input bool            d_showClose      = true; // Show Close lines to D

#property indicator_width1 1

extern string         _1_________________________ = "+++++++++++++++++++++++++++++++++++++++++";
input int             WWidthlines                 = 0;
input ENUM_LINE_STYLE WFiboStyle                  = STYLE_SOLID; //  level style?
extern bool           W_Indicator_On              = False;
extern color          W_UpperFiboColor            = Black;
extern bool           W_UpperFiboOn               = False;
extern color          W_MainFiboColor             = Black;
extern bool           W_MainFiboOn                = False;
extern color          W_LowerFiboColor            = Black;
extern bool           W_LowerFiboOn               = False;
input bool            w_showClose                 = true; // Show Close lines to W

extern string         _2_________________________ = "+++++++++++++++++++++++++++++++++++++++++";
input int             MWidthlines                 = 0;
input ENUM_LINE_STYLE MFiboStyle                  = STYLE_SOLID; //  level style?
extern bool           M_Indicator_On              = False;
extern color          M_UpperFiboColor            = Black;
extern bool           M_UpperFiboOn               = False;
extern color          M_MainFiboColor             = Black;
extern bool           M_MainFiboOn                = False;
extern color          M_LowerFiboColor            = Black;
extern bool           M_LowerFiboOn               = False;
input bool            m_showClose                 = true; // Show Close lines to M

extern string         _3_________________________ = "+++++++++++++++++++++++++++++++++++++++++";
input int             YWidthlines                 = 0;
input ENUM_LINE_STYLE YFiboStyle                  = STYLE_SOLID; //  level style?
extern bool           Y_Indicator_On              = False;
extern color          Y_UpperFiboColor            = Black;
extern bool           Y_UpperFiboOn               = False;
extern color          Y_MainFiboColor             = Black;
extern bool           Y_MainFiboOn                = False;
extern color          Y_LowerFiboColor            = Black;
extern bool           Y_LowerFiboOn               = False;
input bool            y_showClose                 = true; // Show Close lines to Y

double                D_HiPrice, D_LoPrice, D_Range;
datetime              D_StartTime, d_end, y_endTm, m_endTm, w_endTm;

double                W_HiPrice, W_LoPrice, W_Range;
datetime              W_StartTime;

double                M_HiPrice, M_LoPrice, M_Range;
datetime              M_StartTime;

double                Y_HiPrice, Y_LoPrice, Y_Range;
datetime              Y_StartTime;
int                   D_shift, W_shift, M_shift, Y_shift;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int                   OnInit()
{
    //--- indicator buffers mapping

    //---
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Indicator De-initializtion                                       |
//+------------------------------------------------------------------+
int deinit()
{
    ObjectsDeleteAll(0, "D_FiboDn_");
    ObjectsDeleteAll(0, "D_FiboIn_");
    ObjectsDeleteAll(0, "D_FiboUp_");

    ObjectsDeleteAll(0, "W_FiboDn_");
    ObjectsDeleteAll(0, "W_FiboIn_");
    ObjectsDeleteAll(0, "W_FiboUp_");

    ObjectsDeleteAll(0, "M_FiboDn_");
    ObjectsDeleteAll(0, "M_FiboIn_");
    ObjectsDeleteAll(0, "M_FiboUp_");

    ObjectsDeleteAll(0, "Y_FiboDn_");
    ObjectsDeleteAll(0, "Y_FiboIn_");
    ObjectsDeleteAll(0, "Y_FiboUp_");

    ObjectsDeleteAll(0, "d_close_");
    ObjectsDeleteAll(0, "w_close_");
    ObjectsDeleteAll(0, "m_close_");
    ObjectsDeleteAll(0, "y_close_");

    return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
    // clang-format off
int start, i;
if (prev_calculated == 0) { start = Back; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    Comment("");
    for (i = start; i >= 0; i--) {

        //------- D
        if (D_Indicator_On == true) {
            D_shift     = iBarShift(NULL, PERIOD_D1, iTime(NULL, PERIOD_D1, i + 1)); // yesterday
            D_HiPrice   = iHigh(NULL, PERIOD_D1, D_shift);
            D_LoPrice   = iLow(NULL, PERIOD_D1, D_shift);
            D_StartTime = iTime(NULL, PERIOD_D1, D_shift);
            d_end       = D_StartTime + uExpansion * 60 * 60;

            if (d_showClose) {
                string nm = "d_close_" + i;
                hline(nm, iClose(NULL, PERIOD_D1, D_shift), iTime(NULL, PERIOD_D1, D_shift));
            }

            if (TimeDayOfWeek(D_StartTime) == 0 /*Sunday*/) { // Add fridays high and low
                D_HiPrice = MathMax(D_HiPrice, iHigh(NULL, PERIOD_D1, D_shift + 1));
                D_LoPrice = MathMin(D_LoPrice, iLow(NULL, PERIOD_D1, D_shift + 1));
            }

            D_Range = D_HiPrice - D_LoPrice;
            DrawFibo_D(i);
        }
        //------ W
        if (W_Indicator_On == true) {
            W_shift     = iBarShift(NULL, PERIOD_W1, iTime(NULL, PERIOD_W1, i + 1)); // yesterday
            W_HiPrice   = iHigh(NULL, PERIOD_W1, W_shift);
            W_LoPrice   = iLow(NULL, PERIOD_W1, W_shift);
            W_StartTime = iTime(NULL, PERIOD_W1, W_shift);
            w_endTm     = W_StartTime + uExpansion * 60 * 60;

            W_Range     = W_HiPrice - W_LoPrice;
            DrawFibo_W(i);

            if (w_showClose) {
                string nm = "w_close_" + i;
                hline(nm, iClose(NULL, PERIOD_D1, W_shift), iTime(NULL, PERIOD_D1, W_shift));
            }
        }
        //------ M
        if (M_Indicator_On == true) {
            M_shift     = iBarShift(NULL, PERIOD_MN1, iTime(NULL, PERIOD_MN1, i + 1));
            M_HiPrice   = iHigh(NULL, PERIOD_MN1, M_shift);
            M_LoPrice   = iLow(NULL, PERIOD_MN1, M_shift);
            M_StartTime = iTime(NULL, PERIOD_MN1, M_shift);
            m_endTm     = M_StartTime + uExpansion * 60 * 60;

            M_Range     = M_HiPrice - M_LoPrice;
            DrawFibo_M(i);
            
            if (m_showClose) {
                string nm = "m_close_" + i;
                hline(nm, iClose(NULL, PERIOD_D1, M_shift), iTime(NULL, PERIOD_D1, M_shift));
            }
        }
        //------ Y
        if (Y_Indicator_On == true) {
            Y_shift     = iBarShift(NULL, PERIOD_MN1, iTime(NULL, PERIOD_MN1, i + 12)); // yesterday
            Y_StartTime = iTime(NULL, PERIOD_MN1, Y_shift);

            Y_HiPrice   = iHigh(NULL, PERIOD_MN1, iHighest(NULL, PERIOD_MN1, MODE_HIGH, 12, Month()));
            Y_LoPrice   = iLow(NULL, PERIOD_MN1, iLowest(NULL, PERIOD_MN1, MODE_LOW, 12, Month()));
            Y_Range     = Y_HiPrice - Y_LoPrice;
            y_endTm     = Y_StartTime + uExpansion * 60 * 60;

            DrawFibo_Y(i);

            if (y_showClose) {
                string nm = "y_close_" + i;
                hline(nm, iClose(NULL, PERIOD_D1, Y_shift), iTime(NULL, PERIOD_D1, Y_shift));
            }
        }

        //-----------
    }
    Comment("\nPrevious Day: ", NormalizeDouble(D_Range / Point / 10, 1), " Pips", "\nPrevious Week: ", NormalizeDouble(W_Range / Point / 10, 1), " Pips", "\nPrevious Month: ", NormalizeDouble(M_Range / Point / 10, 1), " Pips", "\nPrevious Year: ", NormalizeDouble(Y_Range / Point / 10, 1), " Pips");

    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Day Indicator Draw Fibo Sub-routine                              |
//+------------------------------------------------------------------+

// NOTE: d
void DrawFibo_D(int i)
{
    if (D_UpperFiboOn) {
        string _name = "D_FiboUp_" + (string)i;
        if (ObjectFind(_name) == -1)
            ObjectCreate(_name, OBJ_FIBO, 0, D_StartTime, D_HiPrice + D_Range, d_end, D_HiPrice + D_Range * 0.236);
        else {
            ObjectSet(_name, OBJPROP_TIME2, d_end);
            ObjectSet(_name, OBJPROP_TIME1, D_StartTime);
            ObjectSet(_name, OBJPROP_PRICE1, D_HiPrice + D_Range);
            ObjectSet(_name, OBJPROP_PRICE2, D_HiPrice + D_Range * 0.236);
        }
        ObjectSet(_name, OBJPROP_LEVELCOLOR, D_UpperFiboColor);
        ObjectSet(_name, OBJPROP_LEVELWIDTH, DWidthlines);
        ObjectSet(_name, OBJPROP_LEVELSTYLE, DFiboStyle);
        ObjectSet(_name, OBJPROP_FIBOLEVELS, 18);
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(_name, 0, "(125.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 2, 0.346);
        ObjectSetFiboDescription(_name, 2, "(150.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 4, 0.691);
        ObjectSetFiboDescription(_name, 4, "(175.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 5, 1.000);
        ObjectSetFiboDescription(_name, 5, "(200.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 6, 1.311);
        ObjectSetFiboDescription(_name, 6, "(225.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 8, 1.654);
        ObjectSetFiboDescription(_name, 8, "(250.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 10, 2.000);
        ObjectSetFiboDescription(_name, 10, "(275.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 11, 2.309);
        ObjectSetFiboDescription(_name, 11, "(300.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 12, 2.960);
        ObjectSetFiboDescription(_name, 12, "(350.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 13, 3.618);
        ObjectSetFiboDescription(_name, 13, "(400.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 14, 4.272);
        ObjectSetFiboDescription(_name, 14, "(450.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 15, 4.927);
        ObjectSetFiboDescription(_name, 15, "(500.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 16, 5.578);
        ObjectSetFiboDescription(_name, 16, "(550.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 17, 6.236);
        ObjectSetFiboDescription(_name, 17, "(600.0%) -  %$");
        ObjectSet(_name, OBJPROP_RAY, false);
        ObjectSet(_name, OBJPROP_BACK, true);
        ObjectSet(_name, OBJPROP_SELECTABLE, false);
        ObjectSet(_name, OBJPROP_WIDTH, 2);
    }

    //-----------------------------------------------------------------
    if (D_MainFiboOn) {

        string _name = "D_FiboIn_" + (string)i;
        if (ObjectFind(_name) == -1)
            ObjectCreate(_name, OBJ_FIBO, 0, D_StartTime, D_HiPrice, d_end, D_LoPrice); // vertical line
        else {
            ObjectSet(_name, OBJPROP_TIME2, d_end);
            ObjectSet(_name, OBJPROP_TIME1, D_StartTime);                               // creates vertical line
            ObjectSet(_name, OBJPROP_PRICE1, D_HiPrice);
            ObjectSet(_name, OBJPROP_PRICE2, D_LoPrice);
        }
        ObjectSet(_name, OBJPROP_LEVELCOLOR, D_MainFiboColor);
        ObjectSet(_name, OBJPROP_LEVELWIDTH, DWidthlines);
        ObjectSet(_name, OBJPROP_LEVELSTYLE, DFiboStyle);
        ObjectSet(_name, OBJPROP_FIBOLEVELS, 7);
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(_name, 0, "LOW ");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 1, 0.250);
        ObjectSetFiboDescription(_name, 1, "");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 3, 0.500);
        ObjectSetFiboDescription(_name, 3, "MID");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 5, 0.750);
        ObjectSetFiboDescription(_name, 5, "");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 6, 1.000);
        ObjectSetFiboDescription(_name, 6, "HIGH ");
        ObjectSet(_name, OBJPROP_RAY, false);
        ObjectSet(_name, OBJPROP_BACK, true);
        ObjectSet(_name, OBJPROP_SELECTABLE, false);
    }


    //-----------------------------------------------------------------
    if (D_LowerFiboOn) {
        string _name = "D_FiboDn_" + (string)i;

        if (ObjectFind(_name) == -1)
            // ObjectCreate(_name,OBJ_FIBO,0,D_StartTime,D_LoPrice-D_Range,D_StartTime,D_LoPrice);
            ObjectCreate(_name, OBJ_FIBO, 0, D_StartTime, D_LoPrice - D_Range, d_end, D_LoPrice - D_Range * 0.236);
        else {
            ObjectSet(_name, OBJPROP_TIME2, d_end);
            ObjectSet(_name, OBJPROP_TIME1, D_StartTime);
            ObjectSet(_name, OBJPROP_PRICE1, D_LoPrice - D_Range);
            // ObjectSet(_name,OBJPROP_PRICE1,D_LoPrice);
            ObjectSet(_name, OBJPROP_PRICE2, D_LoPrice - D_Range * 0.236);
        }
        ObjectSet(_name, OBJPROP_LEVELCOLOR, D_LowerFiboColor);
        ObjectSet(_name, OBJPROP_LEVELWIDTH, DWidthlines);
        ObjectSet(_name, OBJPROP_LEVELSTYLE, DFiboStyle);
        ObjectSet(_name, OBJPROP_FIBOLEVELS, 18);
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(_name, 0, "(-25.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 2, 0.346);
        ObjectSetFiboDescription(_name, 2, "(-50.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 4, 0.691);
        ObjectSetFiboDescription(_name, 4, "(-75.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 5, 1.000);
        ObjectSetFiboDescription(_name, 5, "(-100.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 6, 1.311);
        ObjectSetFiboDescription(_name, 6, "(-125.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 8, 1.654);
        ObjectSetFiboDescription(_name, 8, "(-150.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 10, 2.000);
        ObjectSetFiboDescription(_name, 10, "(-175.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 11, 2.309);
        ObjectSetFiboDescription(_name, 11, "(-200.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 12, 2.960);
        ObjectSetFiboDescription(_name, 12, "(-250.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 13, 3.618);
        ObjectSetFiboDescription(_name, 13, "(-300.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 14, 4.272);
        ObjectSetFiboDescription(_name, 14, "(-350.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 15, 4.927);
        ObjectSetFiboDescription(_name, 15, "(-400.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 16, 5.578);
        ObjectSetFiboDescription(_name, 16, "(-450.0%) -  %$");
        ObjectSet(_name, OBJPROP_FIRSTLEVEL + 17, 6.236);
        ObjectSetFiboDescription(_name, 17, "(-500.0%) -  %$");
        ObjectSet(_name, OBJPROP_RAY, false);
        ObjectSet(_name, OBJPROP_BACK, true);
        ObjectSet(_name, OBJPROP_SELECTABLE, false);
    }
}

//+------------------------------------------------------------------+
//| Week Indicator Draw Fibo Sub-routine                             |
//+------------------------------------------------------------------+

void DrawFibo_W(int i)
{
    string nm = "W_FiboUp_" + (string)i;
    if (W_UpperFiboOn) {
        if (ObjectFind(nm) == -1)
            ObjectCreate(nm, OBJ_FIBO, 0, W_StartTime, W_HiPrice + W_Range, w_endTm, W_HiPrice + W_Range * 0.236);
        else {
            ObjectSet(nm, OBJPROP_TIME2, w_endTm);
            ObjectSet(nm, OBJPROP_TIME1, W_StartTime);
            ObjectSet(nm, OBJPROP_PRICE1, W_HiPrice + W_Range);
            ObjectSet(nm, OBJPROP_PRICE2, W_HiPrice + W_Range * 0.236);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, W_UpperFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, WWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, WFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 18);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "(125.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 2, 0.346);
        ObjectSetFiboDescription(nm, 2, "(150.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 4, 0.691);
        ObjectSetFiboDescription(nm, 4, "(175.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 1.000);
        ObjectSetFiboDescription(nm, 5, "(200.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.311);
        ObjectSetFiboDescription(nm, 6, "(225.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 8, 1.654);
        ObjectSetFiboDescription(nm, 8, "(250.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 10, 2.000);
        ObjectSetFiboDescription(nm, 10, "(275.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 11, 2.309);
        ObjectSetFiboDescription(nm, 11, "(300.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 12, 2.960);
        ObjectSetFiboDescription(nm, 12, "(350.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 13, 3.618);
        ObjectSetFiboDescription(nm, 13, "(400.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 14, 4.272);
        ObjectSetFiboDescription(nm, 14, "(450.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 15, 4.927);
        ObjectSetFiboDescription(nm, 15, "(500.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 16, 5.578);
        ObjectSetFiboDescription(nm, 16, "(550.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 17, 6.236);
        ObjectSetFiboDescription(nm, 17, "(600.0%) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }

    //-----------------------------------------------------------------
    if (W_MainFiboOn) {
        string nm = "W_FiboIn_" + (string)i;
        if (ObjectFind(nm) == -1)
            ObjectCreate(nm, OBJ_FIBO, 0, W_StartTime, W_HiPrice, w_endTm, W_LoPrice); // vertical line
        else {
            ObjectSet(nm, OBJPROP_TIME2, w_endTm);
            ObjectSet(nm, OBJPROP_TIME1, W_StartTime);                                 // creates vertical line
            ObjectSet(nm, OBJPROP_PRICE1, W_HiPrice);
            ObjectSet(nm, OBJPROP_PRICE2, W_LoPrice);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, W_MainFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, WWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, WFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 7);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "Previous Week LOW  (  0  ) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 1, 0.236);
        ObjectSetFiboDescription(nm, 1, "(25.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 3, 0.500);
        ObjectSetFiboDescription(nm, 3, "(50.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 0.764);
        ObjectSetFiboDescription(nm, 5, "(75.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.000);
        ObjectSetFiboDescription(nm, 6, "Previous Week HIGH  (100) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }


    //-----------------------------------------------------------------
    if (W_LowerFiboOn) {
        string nm = "W_FiboDn_" + (string)i;
        if (ObjectFind(nm) == -1)
            // ObjectCreate(nm,OBJ_FIBO,0,W_StartTime,W_LoPrice-W_Range,W_StartTime,W_LoPrice);
            ObjectCreate(nm, OBJ_FIBO, 0, W_StartTime, W_LoPrice - W_Range, w_endTm, W_LoPrice - W_Range * 0.236);
        else {
            ObjectSet(nm, OBJPROP_TIME2, w_endTm);
            ObjectSet(nm, OBJPROP_TIME1, W_StartTime);
            ObjectSet(nm, OBJPROP_PRICE1, W_LoPrice - W_Range);
            ObjectSet(nm, OBJPROP_PRICE2, W_LoPrice - W_Range * 0.236);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, W_LowerFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, WWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, WFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 18);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "(-25.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 2, 0.346);
        ObjectSetFiboDescription(nm, 2, "(-50.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 4, 0.691);
        ObjectSetFiboDescription(nm, 4, "(-75.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 1.000);
        ObjectSetFiboDescription(nm, 5, "(-100.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.311);
        ObjectSetFiboDescription(nm, 6, "(-125.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 8, 1.654);
        ObjectSetFiboDescription(nm, 8, "(-150.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 10, 2.000);
        ObjectSetFiboDescription(nm, 10, "(-175.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 11, 2.309);
        ObjectSetFiboDescription(nm, 11, "(-200.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 12, 2.960);
        ObjectSetFiboDescription(nm, 12, "(-250.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 13, 3.618);
        ObjectSetFiboDescription(nm, 13, "(-300.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 14, 4.272);
        ObjectSetFiboDescription(nm, 14, "(-350.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 15, 4.927);
        ObjectSetFiboDescription(nm, 15, "(-400.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 16, 5.578);
        ObjectSetFiboDescription(nm, 16, "(-450.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 17, 6.236);
        ObjectSetFiboDescription(nm, 17, "(-500.0%) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }
}

//+------------------------------------------------------------------+
//| Month Indicator Draw Fibo Sub-routine                            |
//+------------------------------------------------------------------+

void DrawFibo_M(int i)
{
    if (M_UpperFiboOn) {
        string nm = "M_FiboUp_" + (string)i;
        if (ObjectFind(nm) == -1)
            ObjectCreate(nm, OBJ_FIBO, 0, M_StartTime, M_HiPrice + M_Range, m_endTm, M_HiPrice + M_Range * 0.236);
        else {
            ObjectSet(nm, OBJPROP_TIME2, m_endTm);
            ObjectSet(nm, OBJPROP_TIME1, M_StartTime);
            ObjectSet(nm, OBJPROP_PRICE1, M_HiPrice + M_Range);
            ObjectSet(nm, OBJPROP_PRICE2, M_HiPrice + M_Range * 0.236);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, M_UpperFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, MWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, MFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 18);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "(125.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 2, 0.346);
        ObjectSetFiboDescription(nm, 2, "(150.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 4, 0.691);
        ObjectSetFiboDescription(nm, 4, "(175.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 1.000);
        ObjectSetFiboDescription(nm, 5, "(200.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.311);
        ObjectSetFiboDescription(nm, 6, "(225.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 8, 1.654);
        ObjectSetFiboDescription(nm, 8, "(250.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 10, 2.000);
        ObjectSetFiboDescription(nm, 10, "(275.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 11, 2.309);
        ObjectSetFiboDescription(nm, 11, "(300.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 12, 2.960);
        ObjectSetFiboDescription(nm, 12, "(350.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 13, 3.618);
        ObjectSetFiboDescription(nm, 13, "(400.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 14, 4.272);
        ObjectSetFiboDescription(nm, 14, "(450.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 15, 4.927);
        ObjectSetFiboDescription(nm, 15, "(500.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 16, 5.578);
        ObjectSetFiboDescription(nm, 16, "(550.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 17, 6.236);
        ObjectSetFiboDescription(nm, 17, "(600.0%) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }

    //-----------------------------------------------------------------
    if (M_MainFiboOn) {
        string nm = "M_FiboIn_" + (string)i;
        if (ObjectFind(nm) == -1)
            ObjectCreate(nm, OBJ_FIBO, 0, M_StartTime, M_HiPrice, m_endTm, M_LoPrice); // vertical line
        else {
            ObjectSet(nm, OBJPROP_TIME2, m_endTm);
            ObjectSet(nm, OBJPROP_TIME1, M_StartTime);                                 // creates vertical line
            ObjectSet(nm, OBJPROP_PRICE1, M_HiPrice);
            ObjectSet(nm, OBJPROP_PRICE2, M_LoPrice);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, M_MainFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, MWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, MFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 7);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "Previous Month LOW  (  0  ) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 1, 0.250);
        ObjectSetFiboDescription(nm, 1, "(25.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 3, 0.500);
        ObjectSetFiboDescription(nm, 3, "(50.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 0.750);
        ObjectSetFiboDescription(nm, 5, "(75.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.000);
        ObjectSetFiboDescription(nm, 6, "Previous Month HIGH  (100) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }


    //-----------------------------------------------------------------
    if (M_LowerFiboOn) {
        string nm = "M_FiboDn_" + (string)i;
        if (ObjectFind(nm) == -1)
            ObjectCreate(nm, OBJ_FIBO, 0, M_StartTime, M_LoPrice - M_Range, m_endTm, M_LoPrice - M_Range * 0.236);
        else {
            ObjectSet(nm, OBJPROP_TIME2, m_endTm);
            ObjectSet(nm, OBJPROP_TIME1, M_StartTime);
            ObjectSet(nm, OBJPROP_PRICE1, M_LoPrice - M_Range);
            ObjectSet(nm, OBJPROP_PRICE2, M_LoPrice - M_Range * 0.236);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, M_LowerFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, MWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, MFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 18);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "(-25.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 2, 0.346);
        ObjectSetFiboDescription(nm, 2, "(-50.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 4, 0.691);
        ObjectSetFiboDescription(nm, 4, "(-75.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 1.000);
        ObjectSetFiboDescription(nm, 5, "(-100.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.311);
        ObjectSetFiboDescription(nm, 6, "(-125.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 8, 1.654);
        ObjectSetFiboDescription(nm, 8, "(-150.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 10, 2.000);
        ObjectSetFiboDescription(nm, 10, "(-175.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 11, 2.309);
        ObjectSetFiboDescription(nm, 11, "(-200.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 12, 2.960);
        ObjectSetFiboDescription(nm, 12, "(-250.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 13, 3.618);
        ObjectSetFiboDescription(nm, 13, "(-300.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 14, 4.272);
        ObjectSetFiboDescription(nm, 14, "(-350.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 15, 4.927);
        ObjectSetFiboDescription(nm, 15, "(-400.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 16, 5.578);
        ObjectSetFiboDescription(nm, 16, "(-450.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 17, 6.236);
        ObjectSetFiboDescription(nm, 17, "(-500.0%) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }
}

//+------------------------------------------------------------------+
//| Year Indicator Draw Fibo Sub-routine                            |
//+------------------------------------------------------------------+

void DrawFibo_Y(int i)
{
    if (Y_UpperFiboOn) {
        string nm = "Y_FiboUp_" + (string)i;
        if (ObjectFind(nm) == -1)
            ObjectCreate(nm, OBJ_FIBO, 0, Y_StartTime, Y_HiPrice + Y_Range, y_endTm, Y_HiPrice + Y_Range * 0.236);
        else {
            ObjectSet(nm, OBJPROP_TIME2, y_endTm);
            ObjectSet(nm, OBJPROP_TIME1, Y_StartTime);
            ObjectSet(nm, OBJPROP_PRICE1, Y_HiPrice + Y_Range);
            // ObjectSet(nm,OBJPROP_PRICE2,Y_HiPrice);
            ObjectSet(nm, OBJPROP_PRICE2, Y_HiPrice + Y_Range * 0.236);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, Y_UpperFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, YWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, YFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 18);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "(125.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 2, 0.346);
        ObjectSetFiboDescription(nm, 2, "(150.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 4, 0.691);
        ObjectSetFiboDescription(nm, 4, "(175.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 1.000);
        ObjectSetFiboDescription(nm, 5, "(200.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.311);
        ObjectSetFiboDescription(nm, 6, "(225.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 8, 1.654);
        ObjectSetFiboDescription(nm, 8, "(250.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 10, 2.000);
        ObjectSetFiboDescription(nm, 10, "(275.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 11, 2.309);
        ObjectSetFiboDescription(nm, 11, "(300.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 12, 2.960);
        ObjectSetFiboDescription(nm, 12, "(350.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 13, 3.618);
        ObjectSetFiboDescription(nm, 13, "(400.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 14, 4.272);
        ObjectSetFiboDescription(nm, 14, "(450.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 15, 4.927);
        ObjectSetFiboDescription(nm, 15, "(500.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 16, 5.578);
        ObjectSetFiboDescription(nm, 16, "(550.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 17, 6.236);
        ObjectSetFiboDescription(nm, 17, "(600.0%) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }

    //-----------------------------------------------------------------
    if (Y_MainFiboOn) {
        string nm = "Y_FiboIn_" + (string)i;
        if (ObjectFind(nm) == -1)
            ObjectCreate(nm, OBJ_FIBO, 0, Y_StartTime, Y_HiPrice, y_endTm, Y_LoPrice); // vertical line
        else {
            ObjectSet(nm, OBJPROP_TIME2, y_endTm);
            ObjectSet(nm, OBJPROP_TIME1, Y_StartTime);                                 // creates vertical line
            ObjectSet(nm, OBJPROP_PRICE1, Y_HiPrice);
            ObjectSet(nm, OBJPROP_PRICE2, Y_LoPrice);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, Y_MainFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, YWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, YFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 7);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "Previous Year LOW  (  0  ) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 1, 0.250);
        ObjectSetFiboDescription(nm, 1, "(25.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 3, 0.500);
        ObjectSetFiboDescription(nm, 3, "(50.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 0.750);
        ObjectSetFiboDescription(nm, 5, "(75.0) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.000);
        ObjectSetFiboDescription(nm, 6, "Previous Year HIGH  (100) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }


    //-----------------------------------------------------------------
    if (Y_LowerFiboOn) {
        string nm = "Y_FiboDn_" + (string)i;
        if (ObjectFind(nm) == -1)
            ObjectCreate(nm, OBJ_FIBO, 0, Y_StartTime, Y_LoPrice - Y_Range, y_endTm, Y_LoPrice - Y_Range * 0.236);
        else {
            ObjectSet(nm, OBJPROP_TIME2, y_endTm);
            ObjectSet(nm, OBJPROP_TIME1, Y_StartTime);
            ObjectSet(nm, OBJPROP_PRICE1, Y_LoPrice - Y_Range);
            ObjectSet(nm, OBJPROP_PRICE2, Y_LoPrice - Y_Range * 0.236);
        }
        ObjectSet(nm, OBJPROP_LEVELCOLOR, Y_LowerFiboColor);
        ObjectSet(nm, OBJPROP_LEVELWIDTH, YWidthlines);
        ObjectSet(nm, OBJPROP_LEVELSTYLE, YFiboStyle);
        ObjectSet(nm, OBJPROP_FIBOLEVELS, 18);
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 0, 0.000);
        ObjectSetFiboDescription(nm, 0, "(-25.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 2, 0.346);
        ObjectSetFiboDescription(nm, 2, "(-50.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 4, 0.691);
        ObjectSetFiboDescription(nm, 4, "(-75.5%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 5, 1.000);
        ObjectSetFiboDescription(nm, 5, "(-100.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 6, 1.311);
        ObjectSetFiboDescription(nm, 6, "(-125.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 8, 1.654);
        ObjectSetFiboDescription(nm, 8, "(-150.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 10, 2.000);
        ObjectSetFiboDescription(nm, 10, "(-175.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 11, 2.309);
        ObjectSetFiboDescription(nm, 11, "(-200.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 12, 2.960);
        ObjectSetFiboDescription(nm, 12, "(-250.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 13, 3.618);
        ObjectSetFiboDescription(nm, 13, "(-300.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 14, 4.272);
        ObjectSetFiboDescription(nm, 14, "(-350.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 15, 4.927);
        ObjectSetFiboDescription(nm, 15, "(-400.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 16, 5.578);
        ObjectSetFiboDescription(nm, 16, "(-450.0%) -  %$");
        ObjectSet(nm, OBJPROP_FIRSTLEVEL + 17, 6.236);
        ObjectSetFiboDescription(nm, 17, "(-500.0%) -  %$");
        ObjectSet(nm, OBJPROP_RAY, false);
        ObjectSet(nm, OBJPROP_BACK, true);
        ObjectSet(nm, OBJPROP_SELECTABLE, false);
    }
}


void hline(string _name, double _price, datetime _tm)
{
    ObjectCreate(0, _name, OBJ_TREND, 0, _tm, _price, TimeCurrent(), _price);
    ObjectSetInteger(0, _name, OBJPROP_COLOR, Blue);
    ObjectSetInteger(0, _name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, _name, OBJPROP_STYLE, STYLE_DOT);
}