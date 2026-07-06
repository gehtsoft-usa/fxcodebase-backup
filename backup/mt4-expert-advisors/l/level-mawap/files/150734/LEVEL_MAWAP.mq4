//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73692

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
 

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 4
#property indicator_color1  Yellow
#property indicator_color2  White
#property strict

#property indicator_label3 "Arrow Up"
#property  indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Arrow Down"
#property  indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------

enum enPrices
{
    pr_close,      // Close
    pr_open,       // Open
    pr_high,       // High
    pr_low,        // Low
    pr_median,     // Median
    pr_typical,    // Typical
    pr_weighted,   // Weighted
    pr_average,    // Average (high+low+open+close)/4
    pr_medianb,    // Average median body (open+close)/2
    pr_tbiased,    // Trend biased price
    pr_tbiased2,   // Trend biased (extreme) price
    pr_haclose,    // Heiken ashi close
    pr_haopen,    // Heiken ashi open
    pr_hahigh,     // Heiken ashi high
    pr_halow,      // Heiken ashi low
    pr_hamedian,   // Heiken ashi median
    pr_hatypical,  // Heiken ashi typical
    pr_haweighted, // Heiken ashi weighted
    pr_haaverage,  // Heiken ashi average
    pr_hamedianb,  // Heiken ashi median body
    pr_hatbiased,  // Heiken ashi trend biased price
    pr_hatbiased2, // Heiken ashi trend biased (extreme) price
    pr_habclose,   // Heiken ashi (better formula) close
    pr_habopen,   // Heiken ashi (better formula) open
    pr_habhigh,    // Heiken ashi (better formula) high
    pr_hablow,     // Heiken ashi (better formula) low
    pr_habmedian,  // Heiken ashi (better formula) median
    pr_habtypical, // Heiken ashi (better formula) typical
    pr_habweighted,// Heiken ashi (better formula) weighted
    pr_habaverage, // Heiken ashi (better formula) average
    pr_habmedianb, // Heiken ashi (better formula) median body
    pr_habtbiased, // Heiken ashi (better formula) trend biased price
    pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};
enum enMaTypes
{
    ma_sma,     // Simple moving average
    ma_ema,     // Exponential moving average
    ma_smma,    // Smoothed MA
    ma_lwma,    // Linear weighted MA
    ma_slwma,   // Smoothed LWMA
    ma_dsema,   // Double Smoothed Exponential average
    ma_tema,    // Triple exponential moving average - TEMA
    ma_lsma,    // Linear regression value (lsma)
    ma_nlma     // Non Lag moving average - NLMA
};

input int        VwapPeriod = 165;          // Volume weighted average period
input bool       UseRealVolume = false;       // Use real volume?
input int        MaPeriod = 44;          // Ma period
input enMaTypes  MaMethod = ma_sma;      // Moving average method  
input enPrices   Price = pr_close;    // Price
input bool       alertsOn = true;        // Alerts on/off?
input bool       alertsOnCurrent = false;       // Alerts on current bar on/off?
input bool       alertsMessage = false;        // Alerts pop-up message on/off?
input bool       alertsSound = false;       // Alerts sound on/off?
input bool       alertsNotify = true;       // Alerts push notification on/off?
input bool       alertsEmail = false;       // Alerts email on/off?

input string T2 = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:

double vwap[], ma[], prices[], trend[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
    IndicatorBuffers(6);
    SetIndexBuffer(0, vwap, INDICATOR_DATA); SetIndexStyle(0, DRAW_LINE); SetIndexLabel(0, "Vwap");
    SetIndexBuffer(1, ma, INDICATOR_DATA); SetIndexStyle(1, DRAW_LINE); SetIndexLabel(1, "Ema");

    SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(2, 221);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(3, 222);

    if (!ArrowsOn)
    {
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
    }
    
    SetIndexBuffer(4, prices, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, trend, INDICATOR_CALCULATIONS);
    
    IndicatorShortName("LEVEL_MAWAP");
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int       rates_total,
    const int       prev_calculated,
    const datetime& btime[],
    const double& open[],
    const double& high[],
    const double& low[],
    const double& close[],
    const long& tick_volume[],
    const long& real_volume[],
    const int& spread[])
{

    int counted_bars = prev_calculated;
    if (counted_bars < 0) return(-1);
    if (counted_bars > 0) counted_bars--;
    int limit = fmin(rates_total - counted_bars, rates_total - 1);

    //
    //
    //
    //
    //

    for (int i = limit; i >= 0; i--)
    {
        if (i >= Bars - VwapPeriod) continue;
        prices[i] = getPrice(Price, Open, Close, High, Low, i, Bars);
        double sum1 = 0, sum2 = 0;

        for (int k = 0; k < VwapPeriod && (i + k) <= Bars; k++)
        {
            double volume = (UseRealVolume) ? (double) real_volume[i + k] : (double) tick_volume[i + k];
            sum1 += volume * prices[i + k];
            sum2 += volume;
        }

        vwap[i] = (sum2 != 0) ? sum1 / sum2 : prices[i];
        ma[i] = iCustomMa(MaMethod, prices[i], MaPeriod, i, Bars);
        trend[i] = (ma[i] > vwap[i]) ? 1 : (ma[i] < vwap[i]) ? -1 : (i < Bars - 1) ? trend[i + 1] : 0;

        // cross up
        // if (vwap[i + 1] <= ma[i + 1] && vwap[i] > ma[i]) ArrowDn[i] = NormalizeDouble(ma[i]*1.10, _Digits);
        if (vwap[i + 1] <= ma[i + 1] && vwap[i] > ma[i]) ArrowDn[i] = ma[i+10];
        // croos dn
        // if (vwap[i + 1] >= ma[i + 1] && vwap[i] < ma[i]) ArrowUp[i] = NormalizeDouble(ma[i]*0.90,_Digits);
        if (vwap[i + 1] >= ma[i + 1] && vwap[i] < ma[i]) ArrowUp[i] = ma[i+10];
    }
    if (alertsOn)
    {
        int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
        if (trend[whichBar] != trend[whichBar + 1])
            if (trend[whichBar] == 1)
                doAlert("BUY");
            else  doAlert("SELL");
    }
    return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances * _priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo = 0)
{
    if (tprice >= pr_haclose)
    {
        if (ArrayRange(workHa, 0) != bars) ArrayResize(workHa, bars); instanceNo *= _priceInstancesSize; int r = bars - i - 1;

        //
        //
        //
        //
        //

        double haOpen = (r > 0) ? (workHa[r - 1][instanceNo + 2] + workHa[r - 1][instanceNo + 3]) / 2.0 : (open[i] + close[i]) / 2;;
        double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
        if (_prHABF(tprice))
            if (high[i] != low[i])
                haClose = (open[i] + close[i]) / 2.0 + (((close[i] - open[i]) / (high[i] - low[i])) * MathAbs((close[i] - open[i]) / 2.0));
            else  haClose = (open[i] + close[i]) / 2.0;
        double haHigh = fmax(high[i], fmax(haOpen, haClose));
        double haLow = fmin(low[i], fmin(haOpen, haClose));

        //
        //
        //
        //
        //

        if (haOpen < haClose) { workHa[r][instanceNo + 0] = haLow;  workHa[r][instanceNo + 1] = haHigh; }
        else { workHa[r][instanceNo + 0] = haHigh; workHa[r][instanceNo + 1] = haLow; }
        workHa[r][instanceNo + 2] = haOpen;
        workHa[r][instanceNo + 3] = haClose;
        //
        //
        //
        //
        //

        switch (tprice)
        {
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:
            case pr_habopen:     return(haOpen);
            case pr_hahigh:
            case pr_habhigh:     return(haHigh);
            case pr_halow:
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh + haLow) / 2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen + haClose) / 2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh + haLow + haClose) / 3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh + haLow + haClose + haClose) / 4.0);
            case pr_haaverage:
            case pr_habaverage:  return((haHigh + haLow + haClose + haOpen) / 4.0);
            case pr_hatbiased:
            case pr_habtbiased:
                if (haClose > haOpen)
                    return((haHigh + haClose) / 2.0);
                else  return((haLow + haClose) / 2.0);
            case pr_hatbiased2:
            case pr_habtbiased2:
                if (haClose > haOpen)  return(haHigh);
                if (haClose < haOpen)  return(haLow);
                return(haClose);
        }
    }

    //
    //
    //
    //
    //

    switch (tprice)
    {
        case pr_close:     return(close[i]);
        case pr_open:      return(open[i]);
        case pr_high:      return(high[i]);
        case pr_low:       return(low[i]);
        case pr_median:    return((high[i] + low[i]) / 2.0);
        case pr_medianb:   return((open[i] + close[i]) / 2.0);
        case pr_typical:   return((high[i] + low[i] + close[i]) / 3.0);
        case pr_weighted:  return((high[i] + low[i] + close[i] + close[i]) / 4.0);
        case pr_average:   return((high[i] + low[i] + close[i] + open[i]) / 4.0);
        case pr_tbiased:
            if (close[i] > open[i])
                return((high[i] + close[i]) / 2.0);
            else  return((low[i] + close[i]) / 2.0);
        case pr_tbiased2:
            if (close[i] > open[i]) return(high[i]);
            if (close[i] < open[i]) return(low[i]);
            return(close[i]);
    }
    return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo = 0)
{
    r = bars - r - 1;
    switch (mode)
    {
        case ma_sma: return(iSma(price, (int) ceil(length), r, bars, instanceNo));
        case ma_ema: return(iEma(price, length, r, bars, instanceNo));
        case ma_smma: return(iSmma(price, (int) ceil(length), r, bars, instanceNo));
        case ma_lwma: return(iLwma(price, (int) ceil(length), r, bars, instanceNo));
        case ma_slwma: return(iSlwma(price, (int) ceil(length), r, bars, instanceNo));
        case ma_dsema: return(iDsema(price, length, r, bars, instanceNo));
        case ma_tema: return(iTema(price, (int) ceil(length), r, bars, instanceNo));
        case ma_lsma: return(iLinr(price, (int) ceil(length), r, bars, instanceNo));
        case ma_nlma: return(iNonLagMa(price, length, r, bars, instanceNo));
        default: return(price);
    }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo = 0)
{
    if (ArrayRange(workSma, 0) != _bars) ArrayResize(workSma, _bars);

    workSma[r][instanceNo + 0] = price;
    double avg = price; int k = 1;  for (; k < period && (r - k) >= 0; k++) avg += workSma[r - k][instanceNo + 0];
    return(avg / (double) k);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo = 0)
{
    if (ArrayRange(workEma, 0) != _bars) ArrayResize(workEma, _bars);

    workEma[r][instanceNo] = price;
    if (r > 0 && period > 1)
        workEma[r][instanceNo] = workEma[r - 1][instanceNo] + (2.0 / (1.0 + period)) * (price - workEma[r - 1][instanceNo]);
    return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo = 0)
{
    if (ArrayRange(workSmma, 0) != _bars) ArrayResize(workSmma, _bars);

    workSmma[r][instanceNo] = price;
    if (r > 1 && period > 1)
        workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
    return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo = 0)
{
    if (ArrayRange(workLwma, 0) != _bars) ArrayResize(workLwma, _bars);

    workLwma[r][instanceNo] = price; if (period <= 1) return(price);
    double sumw = period;
    double sum = period * price;

    for (int k = 1; k < period && (r - k) >= 0; k++)
    {
        double weight = period - k;
        sumw += weight;
        sum += weight * workLwma[r - k][instanceNo];
    }
    return(sum / sumw);
}

//
//
//
//
//


double workSlwma[][_maWorkBufferx2];
double iSlwma(double price, double period, int r, int _bars, int instanceNo = 0)
{
    if (ArrayRange(workSlwma, 0) != _bars) ArrayResize(workSlwma, _bars);

    //
    //
    //
    //
    //

    int SqrtPeriod = (int) floor(sqrt(period)); instanceNo *= 2;
    workSlwma[r][instanceNo] = price;

    //
    //
    //
    //
    //

    double sumw = period;
    double sum = period * price;

    for (int k = 1; k < period && (r - k) >= 0; k++)
    {
        double weight = period - k;
        sumw += weight;
        sum += weight * workSlwma[r - k][instanceNo];
    }
    workSlwma[r][instanceNo + 1] = (sum / sumw);

    //
    //
    //
    //
    //

    sumw = SqrtPeriod;
    sum = SqrtPeriod * workSlwma[r][instanceNo + 1];
    for (int k = 1; k < SqrtPeriod && (r - k) >= 0; k++)
    {
        double weight = SqrtPeriod - k;
        sumw += weight;
        sum += weight * workSlwma[r - k][instanceNo + 1];
    }
    return(sum / sumw);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int _bars, int instanceNo = 0)
{
    if (ArrayRange(workDsema, 0) != _bars) ArrayResize(workDsema, _bars); instanceNo *= 2;

    //
    //
    //
    //
    //

    workDsema[r][_ema1 + instanceNo] = price;
    workDsema[r][_ema2 + instanceNo] = price;
    if (r > 0 && period > 1)
    {
        double alpha = 2.0 / (1.0 + sqrt(period));
        workDsema[r][_ema1 + instanceNo] = workDsema[r - 1][_ema1 + instanceNo] + alpha * (price - workDsema[r - 1][_ema1 + instanceNo]);
        workDsema[r][_ema2 + instanceNo] = workDsema[r - 1][_ema2 + instanceNo] + alpha * (workDsema[r][_ema1 + instanceNo] - workDsema[r - 1][_ema2 + instanceNo]);
    }
    return(workDsema[r][_ema2 + instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo = 0)
{
    if (ArrayRange(workTema, 0) != bars) ArrayResize(workTema, bars); instanceNo *= 3;

    //
    //
    //
    //
    //

    workTema[r][_tema1 + instanceNo] = price;
    workTema[r][_tema2 + instanceNo] = price;
    workTema[r][_tema3 + instanceNo] = price;
    if (r > 0 && period > 1)
    {
        double alpha = 2.0 / (1.0 + period);
        workTema[r][_tema1 + instanceNo] = workTema[r - 1][_tema1 + instanceNo] + alpha * (price - workTema[r - 1][_tema1 + instanceNo]);
        workTema[r][_tema2 + instanceNo] = workTema[r - 1][_tema2 + instanceNo] + alpha * (workTema[r][_tema1 + instanceNo] - workTema[r - 1][_tema2 + instanceNo]);
        workTema[r][_tema3 + instanceNo] = workTema[r - 1][_tema3 + instanceNo] + alpha * (workTema[r][_tema2 + instanceNo] - workTema[r - 1][_tema3 + instanceNo]);
    }
    return(workTema[r][_tema3 + instanceNo] + 3.0 * (workTema[r][_tema1 + instanceNo] - workTema[r][_tema2 + instanceNo]));
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, int period, int r, int bars, int instanceNo = 0)
{
    if (ArrayRange(workLinr, 0) != bars) ArrayResize(workLinr, bars);

    //
    //
    //
    //
    //

    period = fmax(period, 1);
    workLinr[r][instanceNo] = price;
    if (r < period) return(price);
    double lwmw = period; double lwma = lwmw * price;
    double sma = price;
    for (int k = 1; k < period && (r - k) >= 0; k++)
    {
        double weight = period - k;
        lwmw += weight;
        lwma += weight * workLinr[r - k][instanceNo];
        sma += workLinr[r - k][instanceNo];
    }

    return(3.0 * lwma / lwmw - 2.0 * sma / period);
}

//
//
//
//
//

#define _length  0
#define _len     1
#define _weight  2

double  nlmvalues[][3];
double  nlmprices[][_maWorkBufferx1];
double  nlmalphas[][_maWorkBufferx1];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int bars, int instanceNo = 0)
{
    if (ArrayRange(nlmprices, 0) != bars)         ArrayResize(nlmprices, bars);
    if (ArrayRange(nlmvalues, 0) < instanceNo + 1) ArrayResize(nlmvalues, instanceNo + 1);
    nlmprices[r][instanceNo] = price;
    if (length < 5 || r < 3) return(nlmprices[r][instanceNo]);

    //
    //
    //
    //
    //

    if (nlmvalues[instanceNo][_length] != length)
    {
        double Cycle = 4.0;
        double Coeff = 3.0 * M_PI;
        int    Phase = (int) (length - 1);

        nlmvalues[instanceNo][_length] = length;
        nlmvalues[instanceNo][_len] = (int) (length * 4) + Phase;
        nlmvalues[instanceNo][_weight] = 0;

        if (ArrayRange(nlmalphas, 0) < (int) nlmvalues[instanceNo][_len]) ArrayResize(nlmalphas, (int) nlmvalues[instanceNo][_len]);
        for (int k = 0; k < (int) nlmvalues[instanceNo][_len]; k++)
        {
            double t;
            if (k <= Phase - 1)
                t = 1.0 * k / (Phase - 1);
            else  t = 1.0 + (k - Phase + 1) * (2.0 * Cycle - 1.0) / (Cycle * length - 1.0);
            double beta = cos(M_PI * t);
            double g = 1.0 / (Coeff * t + 1); if (t <= 0.5) g = 1;

            nlmalphas[k][instanceNo] = g * beta;
            nlmvalues[instanceNo][_weight] += nlmalphas[k][instanceNo];
        }
    }

    //
    //
    //
    //
    //

    if (nlmvalues[instanceNo][_weight] > 0)
    {
        double sum = 0;
        for (int k = 0; k < (int) nlmvalues[instanceNo][_len] && (r - k) >= 0; k++) sum += nlmalphas[k][instanceNo] * nlmprices[r - k][instanceNo];
        return(sum / nlmvalues[instanceNo][_weight]);
    }
    else return(0);
}

//
//
//
//
//

string sTfTable[] = { "M1","M5","M15","M30","H1","H4","D1","W1","MN" };
int    iTfTable[] = { 1,5,15,30,60,240,1440,10080,43200 };

string timeFrameToString(int tf)
{
    for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
        if (tf == iTfTable[i]) return(sTfTable[i]);
    return("");
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
    static string   previousAlert = "nothing";
    static datetime previousTime;
    string message;

    if (previousAlert != doWhat || previousTime != Time[0]) {
        previousAlert = doWhat;
        previousTime = Time[0];

        //
        //
        //
        //
        //

        message = StringConcatenate(Symbol(), " ", timeFrameToString(_Period), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " CHECK FOR ", doWhat);
        if (alertsMessage) Alert(message);
        if (alertsNotify)  SendNotification(message);
        if (alertsEmail)   SendMail(StringConcatenate(Symbol(), " Vwap Ma cross "), message);
        if (alertsSound)   PlaySound("alert2.wav");
    }
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