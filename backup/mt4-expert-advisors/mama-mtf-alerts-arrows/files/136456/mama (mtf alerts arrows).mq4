// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70245


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"


//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrOrange
#property strict

enum enPrices
{
   pr_close,       // Close
   pr_open,        // Open
   pr_high,        // High
   pr_low,         // Low
   pr_median,      // Median
   pr_typical,     // Typical
   pr_weighted,    // Weighted
   pr_average,     // Average (high+low+open+close)/4
   pr_medianb,     // Average median body (open+close)/2
   pr_tbiased,     // Trend biased price
   pr_tbiased2,    // Trend biased (extreme) price
   pr_haclose,     // Heiken ashi close
   pr_haopen,      // Heiken ashi open
   pr_hahigh,      // Heiken ashi high
   pr_halow,       // Heiken ashi low
   pr_hamedian,    // Heiken ashi median
   pr_hatypical,   // Heiken ashi typical
   pr_haweighted,  // Heiken ashi weighted
   pr_haaverage,   // Heiken ashi average
   pr_hamedianb,   // Heiken ashi median body
   pr_hatbiased,   // Heiken ashi trend biased price
   pr_hatbiased2,  // Heiken ashi trend biased (extreme) price
   pr_habclose,    // Heiken ashi (better formula) close
   pr_habopen,     // Heiken ashi (better formula) open
   pr_habhigh,     // Heiken ashi (better formula) high
   pr_hablow,      // Heiken ashi (better formula) low
   pr_habmedian,   // Heiken ashi (better formula) median
   pr_habtypical,  // Heiken ashi (better formula) typical
   pr_habweighted, // Heiken ashi (better formula) weighted
   pr_habaverage,  // Heiken ashi (better formula) average
   pr_habmedianb,  // Heiken ashi (better formula) median body
   pr_habtbiased,  // Heiken ashi (better formula) trend biased price
   pr_habtbiased2  // Heiken ashi (better formula) trend biased (extreme) price
};
enum enMaTypes
{
   ma_sma,   // Simple moving average
   ma_ema,   // Exponential moving average
   ma_smma,  // Smoothed MA
   ma_lwma,  // Linear weighted MA
   ma_slwma, // Smoothed LWMA
   ma_dsema, // Double Smoothed Exponential average
   ma_tema,  // Triple exponential moving average - TEMA
   ma_lsma   // Linear regression value (lsma)
};
enum enDisplay
{
   en_lin, // Display lines
   en_lid, // Display lines with dots
   en_dot  // Display dots
};

ENUM_TIMEFRAMES TimeFrame;
input ENUM_TIMEFRAMES TimeFrame_ = PERIOD_CURRENT; // Time frame
input double FastLimit = 0.5;                      // Fast mesa period
input double SlowLimit = 0.05;                     // Slow mesa period
input enPrices Price = pr_hamedianb;               // Price to use
input int PriceFilter = 1;                         // Price pre filtering period
input enMaTypes PriceFilterMode = ma_sma;          // Price pre filtering method
input enDisplay DisplayType = en_lin;              // Display type
input int LinesWidth = 3;                          // Lines width (when lines are included in display)
input bool alertsOn = true;                        // Turn alerts on?
input bool alertsOnCurrent = false;                // Alerts on current (still opened) bar?
input bool alertsMessage = true;                   // Alerts should display a message?
input bool alertsSound = false;                    // Alerts should play a sound?
input bool alertsEmail = false;                    // Alerts should send an email?
input bool alertsNotify = false;                   // Alerts should send notification?
input bool ArrowOnFirst = true;                    // Arrow on first bars
input int UpArrowSize = 2;                         // Up Arrow size
input int DnArrowSize = 2;                         // Down Arrow size
input int UpArrowCode = 159;                       // Up Arrow code
input int DnArrowCode = 159;                       // Down arrow code
input double UpArrowGap = 0.5;                     // Up Arrow gap
input double DnArrowGap = 0.5;                     // Dn Arrow gap
input color UpArrowColor = clrLimeGreen;           // Up Arrow Color
input color DnArrowColor = clrOrange;              // Down Arrow Color
input bool Interpolate = true;                     // Interpolate in multi time frame mode?

double mama[], fama[], arrUp[], arrDn[], trend[], count[], work[][14];
string indicatorFileName;
#define _mtfCall(_buff, _ind) iCustom(NULL, TimeFrame, indicatorFileName, 0, FastLimit, SlowLimit, Price, PriceFilter, PriceFilterMode, DisplayType, LinesWidth, alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsEmail, alertsNotify, ArrowOnFirst, UpArrowSize, DnArrowSize, UpArrowCode, DnArrowCode, UpArrowGap, DnArrowGap, UpArrowColor, DnArrowColor, _buff, _ind)

int OnInit()
{
   IndicatorBuffers(6);
   int lstyle = DRAW_LINE;
   if (DisplayType == en_dot)
      lstyle = DRAW_NONE;
   int astyle = DRAW_ARROW;
   if (DisplayType < en_lid)
      astyle = DRAW_NONE;
   SetIndexBuffer(0, mama);
   SetIndexStyle(0, lstyle, EMPTY, LinesWidth);
   SetIndexBuffer(1, fama);
   SetIndexStyle(1, lstyle, EMPTY, LinesWidth);
   SetIndexBuffer(2, arrUp);
   SetIndexStyle(2, astyle, 0, UpArrowSize, UpArrowColor);
   SetIndexArrow(2, UpArrowCode);
   SetIndexBuffer(3, arrDn);
   SetIndexStyle(3, astyle, 0, DnArrowSize, DnArrowColor);
   SetIndexArrow(3, DnArrowCode);
   SetIndexBuffer(4, trend);
   SetIndexBuffer(5, count);
   indicatorFileName = WindowExpertName();
   TimeFrame = fmax(TimeFrame_, _Period);
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}

double GetWork(int index, int item)
{
   if (index < 0)
   {
      return 0;
   }
   return work[index][item];
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &btime[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   #define _price 0
   #define _smooth 1
   #define _detrender 2
   #define _period 3
   #define _phase 4
   #define _Q1 5
   #define _I1 6
   #define _JI 7
   #define _JQ 8
   #define _Q2 9
   #define _I2 10
   #define _Re 11
   #define _Im 12
   #define _sa 13

   double rad2degree = 180.0 / M_PI;
   int i, r, counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = fmin(rates_total - counted_bars - 1, Bars - 2);
   count[0] = limit;
   if (TimeFrame != _Period)
   {
      limit = (int)fmax(limit, fmin(rates_total - 1, _mtfCall(5, 0) * TimeFrame / _Period));
      for (i = limit; i >= 0 && !_StopFlag; i--)
      {
         int y = iBarShift(NULL, TimeFrame, Time[i]);
         int x = y;
         if (ArrowOnFirst)
         {
            if (i < rates_total - 1)
               x = iBarShift(NULL, TimeFrame, Time[i + 1]);
         }
         else
         {
            if (i > 0)
               x = iBarShift(NULL, TimeFrame, Time[i - 1]);
            else
               x = -1;
         }
         mama[i] = _mtfCall(0, y);
         fama[i] = _mtfCall(1, y);
         arrUp[i] = EMPTY_VALUE;
         arrDn[i] = EMPTY_VALUE;
         if (x != y)
         {
            arrUp[i] = _mtfCall(2, y);
            arrDn[i] = _mtfCall(3, y);
         }

         if (!Interpolate || (i > 0 && y == iBarShift(NULL, TimeFrame, Time[i - 1])))
            continue;
         #define _interpolate(buff) buff[i + k] = buff[i] + (buff[i + n] - buff[i]) * k / n
         int n, k;
         datetime time = iTime(NULL, TimeFrame, y);
         for (n = 1; (i + n) < rates_total && Time[i + n] >= time; n++)
            continue;
         for (k = 1; k < n && (i + n) < Bars && (i + k) < rates_total; k++)
         {
            _interpolate(mama);
            _interpolate(fama);
         }
      }
      return (0);
   }
   if (ArrayRange(work, 0) != Bars)
      ArrayResize(work, Bars);
   for (i = limit, r = rates_total - i - 1; i >= 0; i--, r++)
   {
      double price = getPrice(Price, open, close, high, low, i, rates_total);
      work[r][_price] = iCustomMa(PriceFilterMode, price, PriceFilter, i, rates_total);
      work[r][_smooth] = (4.0 * work[r][_price] + 3.0 * GetWork(r - 1, _price) + 2.0 * GetWork(r - 2, _price) + GetWork(r - 3, _price)) / 10.0;
      work[r][_detrender] = calcComp(r, _smooth);
      work[r][_Q1] = calcComp(r, _detrender);
      work[r][_I1] = GetWork(r - 3, _detrender);
      work[r][_JI] = calcComp(r, _I1);
      work[r][_JQ] = calcComp(r, _Q1);
      work[r][_I2] = 0.2 * (work[r][_I1] - work[r][_JQ]) + 0.8 * GetWork(r - 1, _I2);
      work[r][_Q2] = 0.2 * (work[r][_Q1] + work[r][_JI]) + 0.8 * GetWork(r - 1, _Q2);
      work[r][_Re] = 0.2 * (work[r][_I2] * GetWork(r - 1, _I2) + work[r][_Q2] * GetWork(r - 1, _Q2)) + 0.8 * GetWork(r - 1, _Re);
      work[r][_Im] = 0.2 * (work[r][_I2] * GetWork(r - 1, _Q2) - work[r][_Q2] * GetWork(r - 1, _I2)) + 0.8 * GetWork(r - 1, _Im);

      if (work[r][_Re] != 0 && work[r][_Im] != 0)
         work[r][_period] = 360.0 / (MathArctan(work[r][_Im] / work[r][_Re]) * rad2degree);
      work[r][_period] = fmin(work[r][_period], 1.50 * GetWork(r - 1, _period));
      work[r][_period] = fmax(work[r][_period], 0.67 * GetWork(r - 1, _period));
      work[r][_period] = fmin(fmax(work[r][_period], 6), 50);
      work[r][_period] = 0.2 * work[r][_period] + 0.8 * GetWork(r - 1, _period);

      if (work[r][_I1] != 0)
         work[r][_phase] = MathArctan(work[r][_Q1] / work[r][_I1]) * rad2degree;
      double DeltaPhase = fmax(GetWork(r - 1, _phase) - work[r][_phase], 1);
      double Alpha = fmax(fmin(FastLimit / DeltaPhase, FastLimit), SlowLimit);
      work[r][_sa] = Alpha;

      mama[i] = work[r][_sa] * work[r][_price] + (1.0 - work[r][_sa]) * mama[i + 1];
      fama[i] = 0.5 * work[r][_sa] * mama[i] + (1.0 - 0.5 * work[r][_sa]) * fama[i + 1];
      arrUp[i] = EMPTY_VALUE;
      arrDn[i] = EMPTY_VALUE;
      trend[i] = (i < rates_total - 1) ? (fama[i] < mama[i]) ? 1 : (fama[i] > mama[i]) ? -1 : trend[i + 1] : 0;
      if (i < rates_total - 1 && trend[i] != trend[i + 1])
      {
         if (trend[i] == 1)
            arrUp[i] = fmin(mama[i], Low[i]) - iATR(NULL, 0, 15, i) * UpArrowGap;
         if (trend[i] == -1)
            arrDn[i] = fmax(mama[i], High[i]) + iATR(NULL, 0, 15, i) * DnArrowGap;
      }
   }

   if (alertsOn)
   {
      int whichBar = 1;
      if (alertsOnCurrent)
         whichBar = 0;
      if (trend[whichBar] != trend[whichBar + 1])
         if (trend[whichBar] == 1)
            doAlert("crossing fama up");
         else
            doAlert("crossing fama down");
   }
   return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double calcComp(int r, int from)
{
   return ((0.0962 * work[r][from] +
            0.5769 * GetWork(r - 2, from) -
            0.5769 * GetWork(r - 4, from) -
            0.0962 * GetWork(r - 6, from)) *
           (0.075 * GetWork(r - 1, _period) + 0.54));
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
#define _maWorkBufferx1 1 * _maInstances
#define _maWorkBufferx2 2 * _maInstances
#define _maWorkBufferx3 3 * _maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo = 0)
{
   r = bars - r - 1;
   switch (mode)
   {
   case ma_sma:
      return (iSma(price, (int)length, r, bars, instanceNo));
   case ma_ema:
      return (iEma(price, length, r, bars, instanceNo));
   case ma_smma:
      return (iSmma(price, (int)length, r, bars, instanceNo));
   case ma_lwma:
      return (iLwma(price, (int)length, r, bars, instanceNo));
   case ma_slwma:
      return (iSlwma(price, (int)length, r, bars, instanceNo));
   case ma_dsema:
      return (iDsema(price, length, r, bars, instanceNo));
   case ma_tema:
      return (iTema(price, (int)length, r, bars, instanceNo));
   case ma_lsma:
      return (iLinr(price, (int)length, r, bars, instanceNo));
   default:
      return (price);
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
   if (ArrayRange(workSma, 0) != _bars)
      ArrayResize(workSma, _bars);

   workSma[r][instanceNo + 0] = price;
   double avg = price;
   int k = 1;
   for (; k < period && (r - k) >= 0; k++)
      avg += workSma[r - k][instanceNo + 0];
   return (avg / (double)k);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo = 0)
{
   if (ArrayRange(workEma, 0) != _bars)
      ArrayResize(workEma, _bars);

   workEma[r][instanceNo] = price;
   if (r > 0 && period > 1)
      workEma[r][instanceNo] = workEma[r - 1][instanceNo] + (2.0 / (1.0 + period)) * (price - workEma[r - 1][instanceNo]);
   return (workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo = 0)
{
   if (ArrayRange(workSmma, 0) != _bars)
      ArrayResize(workSmma, _bars);

   workSmma[r][instanceNo] = price;
   if (r > 1 && period > 1)
      workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
   return (workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo = 0)
{
   if (ArrayRange(workLwma, 0) != _bars)
      ArrayResize(workLwma, _bars);

   workLwma[r][instanceNo] = price;
   if (period <= 1)
      return (price);
   double sumw = period;
   double sum = period * price;

   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = period - k;
      sumw += weight;
      sum += weight * workLwma[r - k][instanceNo];
   }
   return (sum / sumw);
}

//
//
//
//
//

double workSlwma[][_maWorkBufferx2];
double iSlwma(double price, double period, int r, int _bars, int instanceNo = 0)
{
   if (ArrayRange(workSlwma, 0) != _bars)
      ArrayResize(workSlwma, _bars);

   //
   //
   //
   //
   //

   int SqrtPeriod = (int)MathFloor(MathSqrt(period));
   instanceNo *= 2;
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
   return (sum / sumw);
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
   if (ArrayRange(workDsema, 0) != _bars)
      ArrayResize(workDsema, _bars);
   instanceNo *= 2;

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
   return (workDsema[r][_ema2 + instanceNo]);
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
   if (ArrayRange(workTema, 0) != bars)
      ArrayResize(workTema, bars);
   instanceNo *= 3;

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
   return (workTema[r][_tema3 + instanceNo] + 3.0 * (workTema[r][_tema1 + instanceNo] - workTema[r][_tema2 + instanceNo]));
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, int period, int r, int bars, int instanceNo = 0)
{
   if (ArrayRange(workLinr, 0) != bars)
      ArrayResize(workLinr, bars);

   //
   //
   //
   //
   //

   period = MathMax(period, 1);
   workLinr[r][instanceNo] = price;
   if (r < period)
      return (price);
   double lwmw = period;
   double lwma = lwmw * price;
   double sma = price;
   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = period - k;
      lwmw += weight;
      lwma += weight * workLinr[r - k][instanceNo];
      sma += workLinr[r - k][instanceNo];
   }

   return (3.0 * lwma / lwmw - 2.0 * sma / period);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _prHABF(_prtype) (_prtype >= pr_habclose && _prtype <= pr_habtbiased2)
#define _priceInstances 1
#define _priceInstancesSize 4
double workHa[][_priceInstances * _priceInstancesSize];
double getPrice(int tprice, const double &open[], const double &close[], const double &high[], const double &low[], int i, int bars, int instanceNo = 0)
{
   if (tprice >= pr_haclose)
   {
      if (ArrayRange(workHa, 0) != bars)
         ArrayResize(workHa, bars);
      instanceNo *= _priceInstancesSize;
      int r = bars - i - 1;

      //
      //
      //
      //
      //

      double haOpen = (r > 0) ? (workHa[r - 1][instanceNo + 2] + workHa[r - 1][instanceNo + 3]) / 2.0 : (open[i] + close[i]) / 2;
      ;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      if (_prHABF(tprice))
         if (high[i] != low[i])
            haClose = (open[i] + close[i]) / 2.0 + (((close[i] - open[i]) / (high[i] - low[i])) * MathAbs((close[i] - open[i]) / 2.0));
         else
            haClose = (open[i] + close[i]) / 2.0;
      double haHigh = fmax(high[i], fmax(haOpen, haClose));
      double haLow = fmin(low[i], fmin(haOpen, haClose));

      //
      //
      //
      //
      //

      if (haOpen < haClose)
      {
         workHa[r][instanceNo + 0] = haLow;
         workHa[r][instanceNo + 1] = haHigh;
      }
      else
      {
         workHa[r][instanceNo + 0] = haHigh;
         workHa[r][instanceNo + 1] = haLow;
      }
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
      case pr_habclose:
         return (haClose);
      case pr_haopen:
      case pr_habopen:
         return (haOpen);
      case pr_hahigh:
      case pr_habhigh:
         return (haHigh);
      case pr_halow:
      case pr_hablow:
         return (haLow);
      case pr_hamedian:
      case pr_habmedian:
         return ((haHigh + haLow) / 2.0);
      case pr_hamedianb:
      case pr_habmedianb:
         return ((haOpen + haClose) / 2.0);
      case pr_hatypical:
      case pr_habtypical:
         return ((haHigh + haLow + haClose) / 3.0);
      case pr_haweighted:
      case pr_habweighted:
         return ((haHigh + haLow + haClose + haClose) / 4.0);
      case pr_haaverage:
      case pr_habaverage:
         return ((haHigh + haLow + haClose + haOpen) / 4.0);
      case pr_hatbiased:
      case pr_habtbiased:
         if (haClose > haOpen)
            return ((haHigh + haClose) / 2.0);
         else
            return ((haLow + haClose) / 2.0);
      case pr_hatbiased2:
      case pr_habtbiased2:
         if (haClose > haOpen)
            return (haHigh);
         if (haClose < haOpen)
            return (haLow);
         return (haClose);
      }
   }

   //
   //
   //
   //
   //

   switch (tprice)
   {
   case pr_close:
      return (close[i]);
   case pr_open:
      return (open[i]);
   case pr_high:
      return (high[i]);
   case pr_low:
      return (low[i]);
   case pr_median:
      return ((high[i] + low[i]) / 2.0);
   case pr_medianb:
      return ((open[i] + close[i]) / 2.0);
   case pr_typical:
      return ((high[i] + low[i] + close[i]) / 3.0);
   case pr_weighted:
      return ((high[i] + low[i] + close[i] + close[i]) / 4.0);
   case pr_average:
      return ((high[i] + low[i] + close[i] + open[i]) / 4.0);
   case pr_tbiased:
      if (close[i] > open[i])
         return ((high[i] + close[i]) / 2.0);
      else
         return ((low[i] + close[i]) / 2.0);
   case pr_tbiased2:
      if (close[i] > open[i])
         return (high[i]);
      if (close[i] < open[i])
         return (low[i]);
      return (close[i]);
   }
   return (0);
}

//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

string timeFrameToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
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
   static string previousAlert = "nothing";
   static datetime previousTime;
   string message;

   if (previousAlert != doWhat || previousTime != Time[0])
   {
      previousAlert = doWhat;
      previousTime = Time[0];

      //
      //
      //
      //
      //

      message = StringConcatenate(Symbol(), " ", timeFrameToString(TimeFrame), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " mama ", doWhat);
      if (alertsMessage)
         Alert(message);
      if (alertsNotify)
         SendNotification(message);
      if (alertsEmail)
         SendMail(StringConcatenate(Symbol(), " mama  "), message);
      if (alertsSound)
         PlaySound("alert2.wav");
   }
}
