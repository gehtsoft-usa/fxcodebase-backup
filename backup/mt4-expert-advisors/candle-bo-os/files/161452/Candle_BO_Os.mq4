/* HEADER:BEGIN */
//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |
//|                                                                         mario.jemic@gmail.com  |
//|                                                        https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
/* HEADER:END */

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3

#property indicator_label1  "Bullish"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Bearish"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Sideways"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

// Threshold lines drawn as constant buffers
#property indicator_buffers 6

double BullBuf[];
double BearBuf[];
double SideBuf[];
double TopLine[];
double BottomLine[];
double SignalBuf[]; // unused, reserved

// Inputs
input int    windowInput = 100;
input int    smoothingMethod = 0; // 0=NONE,1=RMA,2=SMA,3=TMA,4=EMA,5=DEMA,6=TEMA,7=HMA,8=WMA,9=SWMA,10=VWMA
input int    smoothingLen = 2;
input int    weightMethod = 0; // 0=NONE,1=VOLUME,2=PRICE
input int    topThreshold = 80;
input int    bottomThreshold = 20;

// internal arrays
static double RM_Bulls[]; // rolling metric
static double RM_Bears[];
static double RM_Side[];
static double NormB[];
static double NormBe[];
static double NormS[];

int OnInit()
{
    IndicatorBuffers(6);
    SetIndexBuffer(0, BullBuf);
    SetIndexBuffer(1, BearBuf);
    SetIndexBuffer(2, SideBuf);
    SetIndexBuffer(3, TopLine);
    SetIndexBuffer(4, BottomLine);
    SetIndexBuffer(5, SignalBuf);

    PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
    PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
    PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

    return(INIT_SUCCEEDED);
}

// Helper helpers
int BarsAvailable()
{
    return(Bars);
}

// compute bull/bear/side indicator at shift
int isBull(int shift)
{
    if (shift+1 >= Bars) return(0);
    return (Close[shift] > High[shift+1]) ? 1 : -1;
}
int isBear(int shift)
{
    if (shift+1 >= Bars) return(0);
    return (Close[shift] < Low[shift+1]) ? 1 : -1;
}
int isSide(int shift)
{
    int b = isBull(shift);
    int br = isBear(shift);
    return (b==0 || br==0) ? 0 : ((b==1 || br==1) ? 0 : 1); // fallback
}

double absd(double x){ return x<0?-x:x; }

// smoothing functions implemented as series: smoothed[shift] depends on smoothed[shift+1]

// EMA: alpha = 2/(len+1)
double calcEMA(double value, int len, double prevEMA)
{
    if (len <= 1) return value;
    double alpha = 2.0 / (len + 1.0);
    return alpha * value + (1.0 - alpha) * prevEMA;
}
// RMA (Wilder)
double calcRMA(double value, int len, double prevRMA)
{
    if (len <= 1) return value;
    return (prevRMA * (len - 1) + value) / len;
}

// simple average across array of values starting at shift for length len
double calcSMA_series(double &arr[], int fstShift, int len, int maxShift)
{
    double s = 0; int cnt = 0;
    for (int k=0;k<len;k++){
        int idx = fstShift + k;
        if (idx > maxShift) break;
        s += arr[idx]; cnt++;
    }
    if (cnt==0) return 0;
    return s / cnt;
}

// WMA for a small length using values arr starting at shift
double calcWMA_series(double &arr[], int fstShift, int len, int maxShift)
{
    double s=0; double wsum=0; int cnt=0;
    for (int k=0;k<len;k++){
        int idx = fstShift + k;
        if (idx > maxShift) break;
        int w = len - k;
        s += arr[idx] * w; wsum += w; cnt++;
    }
    if (wsum==0) return 0;
    return s/wsum;
}

// HMA: HMA(n) = WMA(2*WMA(n/2)-WMA(n), sqrt(n)) we will compute on Norm arrays

double calcHMA_series(double &arr[], int fstShift, int n, int maxShift)
{
    int half = MathMax(1, n/2);
    int sq = MathMax(1, (int)MathSqrt(n));
    // compute WMA(n/2) and WMA(n)
    double wma_half = calcWMA_series(arr, fstShift, half, maxShift);
    double wma_full = calcWMA_series(arr, fstShift, n, maxShift);
    // construct intermediate series value: 2*wma_half - wma_full
    // We will treat as single value for the window starting at fstShift
    double val = 2.0 * wma_half - wma_full;
    // to get final HMA we need WMA of this 'series' but we approximate by returning val
    return val; // approximation
}

// apply smoothing method to Norm arrays producing Smoothed arrays
void applySmoothing(double &Norm[], double &Smoothed[], int rates_total, int startShift)
{
    int maxShift = rates_total - 1;
    // initialize last element (oldest computed) as itself
    // process from oldest (highest index) down to 0
    for (int s = startShift; s >= 0; s--){
        double val = Norm[s];
        if (s == startShift) {
            Smoothed[s] = val; continue;
        }
        double prev = Smoothed[s+1];
        switch(smoothingMethod){
            case 1: // RMA
                Smoothed[s] = calcRMA(val, smoothingLen, prev);
                break;
            case 2: // SMA
                Smoothed[s] = calcSMA_series(Norm, s, smoothingLen, maxShift);
                break;
            case 3: // TMA = SMA of SMA
                {
                    double tmp = calcSMA_series(Norm, s, smoothingLen, maxShift);
                    // for simplicity use sma of tmp and neighbors => approximate by tmp
                    Smoothed[s] = tmp;
                }
                break;
            case 4: // EMA
                Smoothed[s] = calcEMA(val, smoothingLen, prev);
                break;
            case 5: // DEMA = 2*EMA - EMA(EMA)
                {
                    double ema1 = calcEMA(val, smoothingLen, prev);
                    double ema2 = calcEMA(ema1, smoothingLen, prev);
                    Smoothed[s] = 2*ema1 - ema2;
                }
                break;
            case 6: // TEMA (approx)
                {
                    double ema1 = calcEMA(val, smoothingLen, prev);
                    double ema2 = calcEMA(ema1, smoothingLen, prev);
                    double ema3 = calcEMA(ema2, smoothingLen, prev);
                    Smoothed[s] = 3*ema1 - 3*ema2 + ema3;
                }
                break;
            case 7: // HMA approx
                Smoothed[s] = calcHMA_series(Norm, s, smoothingLen, maxShift);
                break;
            case 8: // WMA
                Smoothed[s] = calcWMA_series(Norm, s, smoothingLen, maxShift);
                break;
            case 9: // SWMA (use WMA)
                Smoothed[s] = calcWMA_series(Norm, s, smoothingLen, maxShift);
                break;
            case 10: // VWMA
                // compute weighted by volume across smoothingLen
                {
                    double num=0, den=0;
                    for (int k=0;k<smoothingLen;k++){
                        int idx = s + k;
                        if (idx > maxShift) break;
                        num += Norm[idx] * Volume[idx];
                        den += Volume[idx];
                    }
                    Smoothed[s] = den==0?0:num/den;
                }
                break;
            default:
                Smoothed[s] = val; break;
        }
    }
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    int rt = rates_total;
    if (rt < windowInput + 2) return(prev_calculated);

    int maxShift = rt - 1;
    int lastValidShift = rt - windowInput; // inclusive
    if (lastValidShift < 0) lastValidShift = 0;

    ArrayResize(RM_Bulls, rt);
    ArrayResize(RM_Bears, rt);
    ArrayResize(RM_Side, rt);
    ArrayResize(NormB, rt);
    ArrayResize(NormBe, rt);
    ArrayResize(NormS, rt);
    ArrayResize(BullBuf, rt);
    ArrayResize(BearBuf, rt);
    ArrayResize(SideBuf, rt);
    ArrayResize(TopLine, rt);
    ArrayResize(BottomLine, rt);

    // compute rolling metric RM for each shift where window fits: shift from lastValidShift down to 0
    for (int s = lastValidShift; s >= 0; s--){
        double sumBull = 0; double sumBear = 0; double sumSide = 0;
        double denBull = 0; double denBear = 0; double denSide = 0;
        for (int k=0;k<windowInput;k++){
            int idx = s + k;
            // ensure idx and idx+1 are within available range to avoid array out of bounds
            if (idx > maxShift || (idx + 1) > maxShift) break;
            int b = (Close[idx] > High[idx+1]) ? 1 : -1;
            int br = (Close[idx] < Low[idx+1]) ? 1 : -1;
            int side = (!(Close[idx] > High[idx+1]) && !(Close[idx] < Low[idx+1])) ? 1 : -1;
            double w = 1.0;
            if (weightMethod == 1) w = Volume[idx];
            else if (weightMethod == 2){
                // price weight: absolute distance
                double bw = absd(Close[idx] - High[idx+1]);
                double brw = absd(Close[idx] - Low[idx+1]);
                // choose appropriate
                w = 1.0; // fallback
            }
            sumBull += (b == 1 ? 1 : -1) * w;
            sumBear += (br == 1 ? 1 : -1) * w;
            sumSide += (side == 1 ? 1 : -1) * w;
            denBull += w; denBear += w; denSide += w;
        }
        double valBull = (weightMethod != 0 && denBull != 0) ? sumBull / denBull : sumBull;
        double valBear = (weightMethod != 0 && denBear != 0) ? sumBear / denBear : sumBear;
        double valSide = (weightMethod != 0 && denSide != 0) ? sumSide / denSide : sumSide;
        RM_Bulls[s] = valBull;
        RM_Bears[s] = valBear;
        RM_Side[s]  = valSide;
    }

    // Now compute normalized values Norm[s] using min/max of RM in window across future window
    for (int s = lastValidShift; s >= 0; s--){
        // find min/max across RM_Bulls[s .. s+window-1]
        double minB = DBL_MAX, maxB = -DBL_MAX;
        double minBr = DBL_MAX, maxBr = -DBL_MAX;
        double minS = DBL_MAX, maxS = -DBL_MAX;
        for (int k=0;k<windowInput;k++){
            int idx = s + k;
            if (idx > maxShift) break;
            double vB = RM_Bulls[idx]; if (vB < minB) minB = vB; if (vB > maxB) maxB = vB;
            double vBr = RM_Bears[idx]; if (vBr < minBr) minBr = vBr; if (vBr > maxBr) maxBr = vBr;
            double vS = RM_Side[idx];  if (vS < minS) minS = vS; if (vS > maxS) maxS = vS;
        }
        double curB = RM_Bulls[s];
        double curBr = RM_Bears[s];
        double curS = RM_Side[s];
        double denomB = (maxB - minB);
        double denomBr = (maxBr - minBr);
        double denomS = (maxS - minS);
        NormB[s] = denomB==0 ? 50 : 100.0*(curB - minB)/denomB;
        NormBe[s] = denomBr==0 ? 50 : 100.0*(curBr - minBr)/denomBr;
        NormS[s] = denomS==0 ? 50 : 100.0*(curS - minS)/denomS;
    }

    // Apply smoothing: we will compute smoothed arrays into BullBuf etc.
    // Use startShift = lastValidShift as the oldest computed index
    applySmoothing(NormB, BullBuf, rt, lastValidShift);
    applySmoothing(NormBe, BearBuf, rt, lastValidShift);
    applySmoothing(NormS, SideBuf, rt, lastValidShift);

    // fill threshold buffers
    for (int i=0;i<rt;i++){
        TopLine[i] = topThreshold;
        BottomLine[i] = bottomThreshold;
    }

    // For shifts newer than lastValidShift set EMPTY
    for (int i=0;i<rt;i++){
        if (i > lastValidShift){ BullBuf[i] = EMPTY_VALUE; BearBuf[i] = EMPTY_VALUE; SideBuf[i] = EMPTY_VALUE; }
    }

    return(rt);
}


/* FOOTER:BEGIN */
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
/* FOOTER:END */