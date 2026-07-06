//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75235

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
#property indicator_separate_window
#property indicator_buffers 10

enum MATYPE { SMA, EMA, HMA, RMA, WMA };

enum AVGTYPE { Simple, Same_RRoF };

enum EVEREXMode {
    one  = 100, // 100
    two  = 200, // 200
    four = 400  // 400
};
enum BANDTYPE { Joint, Separate };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string     grp_1          = "===== Rate of FLow (RoF) ====="; //.
input int        length         = 10;
input MATYPE     MA_Type        = WMA;                               // MA Type
input int        smooth         = 3;                                 // Smooth
input int        sig_length     = 5;                                 // Signal Length
input MATYPE     S_Type         = WMA;                               // Signal Type
input string     grp_2          = "===== Lookback Parameters ====="; //.
input int        lookback       = 20;                                // Length
input AVGTYPE    lkbk_Calc      = Simple;                            // Averaging
input string     grp_3          = "===== Bias / Sentiment =====";    //.
input bool       showBias       = true;                              // Bias Plot ? --
input int        B_Length       = 30;                                // Length
input MATYPE     B_Type         = WMA;                               // MA type
input string     grp_4          = "===== EVEREX Bands =====";        //.
input bool       showEVEREX     = false;                             // Show EVEREX Bands ? --
input EVEREXMode bandscale      = one;                               // Band Scale
input BANDTYPE   Eq_band_option = Joint;                             // Band Option
input bool       showMarkers    = true;                              // Show EVEREX Markers

double circleGreen[], circleRed[], triangleup[], triangledn[];
double RROF_Raw[], RROF_Smooth[], Bias_Sent[], Bias_Sent1[], Bias_Sent2[], Bias_Sent_clr[];
double Signal_Line[], Signal_Line1[], Signal_Line2[], Signal_Line_clr[];
double POpen[], PHigh[], PLow[], PClose[], PColor[];
double VOpen[], VHigh[], VLow[], VClose[], VColor[];
double vol[];
double NormalVol[], NormalPri[];

double peak[], valley[], diverUp[], diverDn[];

double Atmp1[];
double Btmp1[];
double Ctmp1[];
double Dtmp1[];
double Etmp1[];
double Ftmp1[];
double Gtmp1[];
double Htmp1[];
string prefix = "aaa ";

double v[];
double Vola[];
double BarSpread_avg[], BarSpread_abs[];
double SrcShift_abs[], srcshift_avg[];
double bulls[], bears[], bulls_avg[], bears_avg[];
double RROF[], RROF_s[];
double Signal[];
double Gavg[], Havg[];

double RROF_b[], RROF_bs[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void NewArray(int totals)
{
    ResizeBuffer(Bias_Sent, totals);
    ResizeBuffer(Bias_Sent_clr, totals);
    ResizeBuffer(Signal_Line, totals);
    ResizeBuffer(Signal_Line_clr, totals);

    ResizeBuffer(POpen, totals);
    ResizeBuffer(PHigh, totals);
    ResizeBuffer(PLow, totals);
    ResizeBuffer(PClose, totals);
    ResizeBuffer(PColor, totals);

    ResizeBuffer(VOpen, totals);
    ResizeBuffer(VHigh, totals);
    ResizeBuffer(VLow, totals);
    ResizeBuffer(VClose, totals);
    ResizeBuffer(VColor, totals);

    ResizeBuffer(circleGreen, totals);
    ResizeBuffer(circleRed, totals);
    ResizeBuffer(triangleup, totals);
    ResizeBuffer(triangledn, totals);
    ResizeBuffer(NormalVol, totals);
    ResizeBuffer(NormalPri, totals);

    ResizeBuffer(RROF_b, totals);
    ResizeBuffer(RROF_bs, totals);

    ResizeBuffer(Signal, totals);
    ResizeBuffer(Gavg, totals);
    ResizeBuffer(Havg, totals);

    ResizeBuffer(RROF, totals);
    ResizeBuffer(RROF_s, totals);

    ResizeBuffer(bulls, totals);
    ResizeBuffer(bears, totals);
    ResizeBuffer(bulls_avg, totals);
    ResizeBuffer(bears_avg, totals);

    ResizeBuffer(SrcShift_abs, totals);
    ResizeBuffer(srcshift_avg, totals);

    ResizeBuffer(BarSpread_avg, totals);
    ResizeBuffer(BarSpread_abs, totals);
    ResizeBuffer(Vola, totals);
    ResizeBuffer(v, totals);
    ResizeBuffer(vol, totals);

    ResizeBuffer(Atmp1, totals);
    ResizeBuffer(Btmp1, totals);
    ResizeBuffer(Ctmp1, totals);
    ResizeBuffer(Dtmp1, totals);
    ResizeBuffer(Etmp1, totals);
    ResizeBuffer(Ftmp1, totals);
    ResizeBuffer(Gtmp1, totals);
    ResizeBuffer(Htmp1, totals);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Process(int i, const double &open[], const double &high[], const double &low[], const double &close[], const double &volume[])
{
    v[i]                = na(volume[i]) ? 1 : volume[i];
    bool   NoVol_Flag   = na(volume[i]) ? true : false;
    MATYPE lkbk_MA_Type = lkbk_Calc == Simple ? SMA : MA_Type;
    Vola[i]             = GetAverage(lkbk_MA_Type, "A", i, lookback, Vola[i + 1], v);
    double Vola_n_pre   = Normalize(v[i], Vola[i]) * 100;
    double Vola_n       = NoVol_Flag ? 100 : Vola_n_pre;

    double BarSpread   = close[i] - open[i];
    double BarRange    = high[i] - low[i];
    double R2          = Highest(_Symbol, PERIOD_CURRENT, i, high, 2) - Lowest(_Symbol, PERIOD_CURRENT, i, low, 2);
    double SrcShift    = close[i] - close[i + 1];
    double sign_shift  = MathSign(SrcShift);
    double sign_spread = MathSign(BarSpread);

    double barclosing = BarRange != 0.0 ? 2 * (close[i] - low[i]) / BarRange * 100 - 100 : 0.0;
    double s2r        = BarRange != 0.0 ? BarSpread / BarRange * 100 : 0.0;

    BarSpread_abs[i]         = MathAbs(BarSpread);
    BarSpread_avg[i]         = GetAverage(lkbk_MA_Type, "B", i, lookback, BarSpread_avg[i + 1], BarSpread_abs);
    double BarSpread_ratio_n = Normalize(BarSpread_abs[i], BarSpread_avg[i]) * 100 * sign_spread;

    double barclosing_2   = R2 != 0.0 ? 2 * (close[i] - Lowest(_Symbol, PERIOD_CURRENT, i, low, 2)) / R2 * 100 - 100 : 0.0;
    double Shift2Bar_toR2 = R2 != 0.0 ? SrcShift / R2 * 100 : 0.0;

    SrcShift_abs[i]         = MathAbs(SrcShift);
    srcshift_avg[i]         = GetAverage(lkbk_MA_Type, "C", i, lookback, srcshift_avg[i + 1], SrcShift_abs);
    double srcshift_ratio_n = Normalize(SrcShift_abs[i], srcshift_avg[i]) * 100 * sign_shift;

    double Pricea_n = (barclosing + s2r + BarSpread_ratio_n + barclosing_2 + Shift2Bar_toR2 + srcshift_ratio_n) / 6;
    double bar_flow = Pricea_n * Vola_n / 100;

    bulls[i] = MathMax(bar_flow, 0);
    bears[i] = -1 * MathMin(bar_flow, 0);

    bulls_avg[i] = GetAverage(MA_Type, "D", i, length, bulls_avg[i + 1], bulls);
    bears_avg[i] = GetAverage(MA_Type, "E", i, length, bears_avg[i + 1], bears);

    double dx = bears_avg[i] != 0.0 ? bulls_avg[i] / bears_avg[i] : 0.0;
    RROF[i]   = 2 * (100 - 100 / (1 + dx)) - 100;
    RROF_s[i] = WeightMA(i, smooth, RROF);

    Signal[i]   = GetAverage(S_Type, "F", i, sig_length, Signal[i + 1], RROF_s);
    Gavg[i]     = GetAverage(B_Type, "G", i, B_Length, Gavg[i + 1], bulls);
    Havg[i]     = GetAverage(B_Type, "H", i, B_Length, Havg[i + 1], bears);
    double dx_b = Havg[i] != 0.0 ? Gavg[i] / Havg[i] : 0.0;

    RROF_b[i]  = 2 * (100 - 100 / (1 + dx_b)) - 100;
    RROF_bs[i] = WeightMA(i, smooth, RROF_b);

    color c_zero = clrBlue;
    color c_band = clrYellow;

    bool up   = RROF_s[i] >= 0;
    bool s_up = RROF_bs[i] >= 0;

    if (showEVEREX) {
        string name = prefix + "Zero Line";
        if (ObjectFind(0, name) < 0) HLineCreate(0, name, 1, 0, c_zero);

        name = prefix + "'1/4 Level";
        if (ObjectFind(0, name) < 0) HLineCreate(0, name, 1, 0.25 * bandscale, c_band);

        name = prefix + "2/4 Level";
        if (ObjectFind(0, name) < 0) HLineCreate(0, name, 1, 0.50 * bandscale, c_band);

        name = prefix + "3/4 Level";
        if (ObjectFind(0, name) < 0) HLineCreate(0, name, 1, 0.75 * bandscale, c_band);

        name = prefix + "4/4 Level";
        if (ObjectFind(0, name) < 0) HLineCreate(0, name, 1, bandscale, c_band);
    }

    Bias_Sent[i]     = showBias ? RROF_bs[i] : EMPTY_VALUE;
    Bias_Sent_clr[i] = s_up ? 1 : 0;
    Bias_Sent2[i]    = s_up ? Bias_Sent[i] : EMPTY_VALUE;
    Bias_Sent1[i]    = s_up ? EMPTY_VALUE : Bias_Sent[i];

    if (Bias_Sent2[i + 1] == EMPTY_VALUE && Bias_Sent2[i] != EMPTY_VALUE && Bias_Sent1[i + 1] != EMPTY_VALUE && Bias_Sent1[i] == EMPTY_VALUE) Bias_Sent2[i + 1] = Bias_Sent1[i + 1];
    //
    if (Bias_Sent1[i + 1] == EMPTY_VALUE && Bias_Sent1[i] != EMPTY_VALUE && Bias_Sent2[i + 1] != EMPTY_VALUE && Bias_Sent2[i] == EMPTY_VALUE) Bias_Sent1[i + 1] = Bias_Sent2[i + 1];

    double nPrice = MathMax(MathMin(Pricea_n, 100), -100);
    double nVol   = MathMax(MathMin(Vola_n, 100), -100);
    double bar    = bar_flow;
    VColor[i]     = bar > 0 ? 0 : 1;
    if (showEVEREX) {
        VLow[i]   = 0.0;
        VHigh[i]  = nVol * bandscale / 100 / 2;
        VOpen[i]  = VLow[i];
        VClose[i] = VHigh[i];
    } else {
        VLow[i]   = EMPTY_VALUE;
        VHigh[i]  = EMPTY_VALUE;
        VOpen[i]  = EMPTY_VALUE;
        VClose[i] = EMPTY_VALUE;
    }

    PColor[i]         = bar > 0 ? 0 : 1;
    double pc_lo_base = Eq_band_option == Joint ? VHigh[i] : 0.50 * bandscale;
    if (showEVEREX) {
        PLow[i]   = pc_lo_base;
        PHigh[i]  = pc_lo_base + MathAbs(nPrice) * bandscale / 100 / 2;
        POpen[i]  = PLow[i];
        PClose[i] = PHigh[i];
    } else {
        PLow[i]   = EMPTY_VALUE;
        PHigh[i]  = EMPTY_VALUE;
        POpen[i]  = EMPTY_VALUE;
        PClose[i] = EMPTY_VALUE;
    }

    NormalVol[i] = nVol;
    NormalPri[i] = nPrice;

    RROF_Raw[i]    = RROF[i];
    RROF_Smooth[i] = RROF_s[i];

    Signal_Line[i]     = Signal[i];
    Signal_Line_clr[i] = up ? 0 : 1;
    Signal_Line1[i]    = up ? Signal_Line[i] : EMPTY_VALUE;
    Signal_Line2[i]    = up ? EMPTY_VALUE : Signal_Line[i];

    if (Signal_Line2[i + 1] == EMPTY_VALUE && Signal_Line2[i] != EMPTY_VALUE && Signal_Line1[i + 1] != EMPTY_VALUE && Signal_Line1[i] == EMPTY_VALUE) Signal_Line2[i + 1] = Signal_Line1[i + 1];
    //
    if (Signal_Line1[i + 1] == EMPTY_VALUE && Signal_Line1[i] != EMPTY_VALUE && Signal_Line2[i + 1] != EMPTY_VALUE && Signal_Line2[i] == EMPTY_VALUE) Signal_Line1[i + 1] = Signal_Line2[i + 1];

    double nPrice_abs     = MathAbs(nPrice);
    double EV_Ratio       = 100 * nPrice_abs / nVol;
    bool   is_positive    = nPrice > 0;
    bool   is_Compression = EV_Ratio <= 50;
    bool   is_EoM         = EV_Ratio >= 120;

    triangleup[i] = showMarkers && is_EoM && is_positive ? 0 : EMPTY_VALUE;
    triangledn[i] = showMarkers && is_EoM && !(is_positive) ? 0 : EMPTY_VALUE;

    circleGreen[i] = showMarkers && is_Compression && is_positive ? 0 : EMPTY_VALUE;
    circleRed[i]   = showMarkers && is_Compression && !(is_positive) ? 0 : EMPTY_VALUE;
}
//+------------------------------------------------------------------+
bool na(double price) { return price == EMPTY_VALUE || price == 0.0; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ResizeBuffer(double &buffer[], int size)
{
    if (ArrayRange(buffer, 0) != size) // ArrayRange allows 1D or 2D arrays
    {
        ArraySetAsSeries(buffer, false); // Shift values B[2]=B[1]; B[1]=B[0]
        if (ArrayResize(buffer, size) <= 0) {
            return (false);
        }
        ArraySetAsSeries(buffer, true);
    }
    return (true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ResizeBuffer(long &buffer[], int size)
{
    if (ArrayRange(buffer, 0) != size) // ArrayRange allows 1D or 2D arrays
    {
        ArraySetAsSeries(buffer, false); // Shift values B[2]=B[1]; B[1]=B[0]
        if (ArrayResize(buffer, size) <= 0) {
            return (false);
        }
        ArraySetAsSeries(buffer, true);
    }
    return (true);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorDigits(Digits);
    IndicatorSetDouble(INDICATOR_MAXIMUM, bandscale);
    //--- indicator buffers mapping
    SetIndexStyle(0, DRAW_NONE, STYLE_SOLID, 2, clrBlue);
    SetIndexBuffer(0, RROF_Raw);
    SetIndexLabel(0, "RROF Raw");

    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, clrGray);
    SetIndexBuffer(1, RROF_Smooth);
    SetIndexLabel(1, "RROF Smooth");

    SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2, clrBrown);
    SetIndexBuffer(2, Bias_Sent1);
    SetIndexLabel(2, "Bias_Sent1");
    SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 2, clrDarkGreen);
    SetIndexBuffer(3, Bias_Sent2);
    SetIndexLabel(3, "Bias_Sent2");

    SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 2, clrSkyBlue);
    SetIndexBuffer(4, Signal_Line1);
    SetIndexLabel(4, "Signal_Line1");
    SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 2, clrOrange);
    SetIndexBuffer(5, Signal_Line2);
    SetIndexLabel(5, "Signal_Line2");

    SetIndexBuffer(6, peak);
    SetIndexStyle(6, DRAW_NONE);
    SetIndexArrow(6, 234);

    SetIndexBuffer(7, valley);
    SetIndexStyle(7, DRAW_NONE);
    SetIndexArrow(7, 233);

    SetIndexBuffer(8, diverDn);
    SetIndexStyle(8, DRAW_ARROW, EMPTY, 1, Crimson);
    SetIndexArrow(8, 234);
    SetIndexLabel(8, "Divergence up");

    SetIndexBuffer(9, diverUp);
    SetIndexStyle(9, DRAW_ARROW, EMPTY, 1, clrGreen);
    SetIndexArrow(9, 233);
    SetIndexLabel(9, "Divergence down");


    //---
    return (INIT_SUCCEEDED);
}

bool first_peak   = true;
bool first_valley = true;

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{

    // if(TimeCurrent()>D'2024. 04. 10')
    //   return 0;
    //---
    int limit;
    limit = rates_total - prev_calculated - 10;

    if (rates_total == prev_calculated) limit = 0;

    if (limit >= 0) NewArray(rates_total);

    for (int i = limit; i >= 0; i--) {
        Comment("===", i);
        vol[i]         = (double)iVolume(_Symbol, PERIOD_CURRENT, i);
        circleGreen[i] = EMPTY_VALUE;
        circleRed[i]   = EMPTY_VALUE;
        triangleup[i]  = EMPTY_VALUE;
        triangledn[i]  = EMPTY_VALUE;

        if (i > MathMin(Bars(_Symbol, PERIOD_CURRENT) - 500, 5000)) {
            Vola[i]          = 0.0;
            BarSpread_avg[i] = 0.0;
            srcshift_avg[i]  = 0.0;
            Signal[i]        = 0.0;
            bulls_avg[i]     = 0.0;
            bears_avg[i]     = 0.0;
            Gavg[i]          = 0.0;
            Havg[i]          = 0.0;
            continue;
        }
        Process(i, open, high, low, close, vol);
    // }

    // for (int i = limit; i >= 0; i--) {
        if (RROF_Smooth[i + 3] > RROF_Smooth[i + 2] && RROF_Smooth[i + 1] > RROF_Smooth[i + 2]) {
            valley[i + 2] = RROF_Smooth[i + 2];

            int n = i + 3;
            if (!first_valley) {
                while (valley[n] == EMPTY_VALUE || n == ArraySize(valley) - 1) {
                    n++;
                }
                double prevLow = Low[n];
                double currLow = Low[i + 2];
                if (prevLow > currLow && valley[n] < valley[i + 2]) {
                    diverUp[i + 2] = RROF_Smooth[i + 2];
                    DrawDivergence(Time[n], valley[n], Time[i+2], diverUp[i + 2], 1);
                    DrawDivergence(Time[n], Low[n], Time[i+2], Low[i + 2], 0);
                }
            }
            first_valley = false;
        }
        if (RROF_Smooth[i + 3] < RROF_Smooth[i + 2] && RROF_Smooth[i + 1] <= RROF_Smooth[i + 2]) {
            peak[i + 2] = RROF_Smooth[i + 2];

            if (!first_peak) {
                int n = i + 3;
                while (peak[n] == EMPTY_VALUE || n == ArraySize(peak) - 1) {
                    n++;
                }
                double prevhigh = High[n];
                double currHigh = High[i + 2];
                if (prevhigh < currHigh && peak[n] > peak[i + 2]) {
                    diverDn[i + 2] = RROF_Smooth[i + 2];
                    DrawDivergence(Time[n], peak[n], Time[i+2], diverDn[i + 2], 1);
                    DrawDivergence(Time[n], High[n], Time[i+2], High[i + 2], 0);
                }
            }
            first_peak = false;
        }
    }

    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+

bool DrawDivergence(datetime time1 = 0, double price1 = 0, datetime time2 = 0, double price2 = 0, int sub=0)
{
    string name = "divergence_"+sub+"_"+ time2;

    if (!ObjectCreate(0, name, OBJ_TREND, sub, time1, price1, time2, price2)) { return (false); }
    
    ObjectSetInteger(0, name, OBJPROP_COLOR, Gold);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);

    return (true);
}

//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID   = 0,         // chart's ID
                 const string          name       = "HLine",   // line name
                 const int             sub_window = 0,         // subwindow index
                 double                price      = 0,         // line price
                 const color           clr        = clrRed,    // line color
                 const ENUM_LINE_STYLE style      = STYLE_DOT, // line style
                 const int             width      = 1,         // line width
                 const bool            back       = false,     // in the background
                 const bool            selection  = false,     // highlight to move
                 const bool            hidden     = true,      // hidden in the object list
                 const long            z_order    = 0)                       // priority for mouse click
{
    //--- if the price is not set, set it at the current Bid price level
    if (!price) price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    //--- reset the error value
    ResetLastError();
    //--- create a horizontal line
    if (!ObjectCreate(chart_ID, name, OBJ_HLINE, sub_window, 0, price)) {
        Print(__FUNCTION__, ": failed to create a horizontal line! Error code = ", GetLastError());
        return (false);
    }
    //--- set line color
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
    //--- set line display style
    ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
    //--- set line width
    ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
    //--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
    //--- enable (true) or disable (false) the mode of moving the line by mouse
    //--- when creating a graphical object using ObjectCreate function, the object cannot be
    //--- highlighted and moved by default. Inside this method, selection parameter
    //--- is true by default making it possible to highlight and move the object
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
    //--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
    //--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
    //--- successful execution
    return (true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Highest(string symbol, ENUM_TIMEFRAMES timeframe, int i, const double &_src[], int _length)
{
    if (i > iBars(symbol, timeframe) - 1 - _length) return (0.0);
    double res = DBL_MIN;

    for (int index = i + _length - 1; index >= i; index--) {
        if (_src[index] > res) res = _src[index];
    }

    return (res);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lowest(string symbol, ENUM_TIMEFRAMES timeframe, int i, const double &_src[], int _length)
{
    if (i > iBars(symbol, timeframe) - 1 - _length) return (0.0);
    double res = DBL_MAX;

    for (int index = i + _length - 1; index >= i; index--) {
        if (_src[index] < res) res = _src[index];
    }

    return (res);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0, prefix);
    ObjectsDeleteAll(0, "divergence");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MathSign(double number)
{
    if (number == 0.0) return 0.0;
    if (number > 0.0) return 1.0;
    return -1.0;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAverage(MATYPE type, string HType, const int position, const int period, const double prev_value, const double &price[])
{
    if (type == SMA) return SimpleMA(position, period, price);
    if (type == EMA) return ExponentMA(position, period, prev_value, price);
    if (type == HMA) return HMovingAverage(HType, position, period, price);
    if (type == WMA) return WeightMA(position, period, price);

    return RelatedMA(position, period, prev_value, price);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Normalize(double _Value, double _Avg)
{
    double _X = _Avg != 0.0 ? _Value / _Avg : 0.0;
    return _X > 1.50 ? 1.00 : _X > 1.20 ? 0.90 : _X > 1.00 ? 0.80 : _X > 0.80 ? 0.70 : _X > 0.60 ? 0.60 : _X > 0.40 ? 0.50 : _X > 0.20 ? 0.25 : 0.1;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SimpleMA(const int position, const int period, const double &price[])
{
    //---
    double result = 0.0;
    //--- check position
    if (period > 0) {
        //--- calculate value
        for (int i = 0; i < period; i++)
            result += price[position + i];
        result /= period;
    }
    //---
    return (result);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ExponentMA(const int position, const int period, const double prev_value, const double &price[])
{
    double result = 0.0;
    if (period > 0) {
        double alpha = 2.0 / (period + 1);
        result       = price[position] * alpha + (1 - alpha) * prev_value;
    }
    return (result);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RelatedMA(const int position, const int period, const double prev_value, const double &price[])
{
    double result = 0.0;
    if (period > 0) {
        double alpha = 1.0 / period;
        result       = price[position] * alpha + (1 - alpha) * prev_value;
    }
    return (result);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double HMovingAverage(string HType, const int i, const int _length, const double &src[])
{
    double buff1 = WeightMA(i, _length / 2, src);
    double buff2 = WeightMA(i, _length, src);
    int    _len  = (int)MathRound(MathSqrt(_length));
    if (HType == "A") {
        Atmp1[i] = 2 * buff1 - buff2;
        return WeightMA(i, _len, Atmp1);
    }
    if (HType == "B") {
        Btmp1[i] = 2 * buff1 - buff2;
        return WeightMA(i, _len, Btmp1);
    }
    if (HType == "C") {
        Ctmp1[i] = 2 * buff1 - buff2;
        return WeightMA(i, _len, Ctmp1);
    }
    if (HType == "D") {
        Dtmp1[i] = 2 * buff1 - buff2;
        return WeightMA(i, _len, Dtmp1);
    }
    if (HType == "E") {
        Etmp1[i] = 2 * buff1 - buff2;
        return WeightMA(i, _len, Etmp1);
    }
    if (HType == "F") {
        Ftmp1[i] = 2 * buff1 - buff2;
        return WeightMA(i, _len, Ftmp1);
    }
    if (HType == "G") {
        Gtmp1[i] = 2 * buff1 - buff2;
        return WeightMA(i, _len, Gtmp1);
    }
    if (HType == "H") {
        Htmp1[i] = 2 * buff1 - buff2;
        return WeightMA(i, _len, Htmp1);
    }

    return 0.0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double WeightMA(const int position, const int period, const double &price[])
{

    if (position > Bars(_Symbol, PERIOD_CURRENT) - 1 - period) return (0.0);

    double result = 0.0;
    double norm   = 0.0;
    //--- check position
    if (period > 0) {
        //--- calculate value
        for (int i = 0; i < period; i++) {
            double weight = (period - i) * period;
            norm += weight;
            result += price[position + i] * weight;
        }
    }

    if (norm == 0)
        result = 0;
    else
        result /= norm;
    //---
    return (result);
}

//+------------------------------------------------------------------+
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