// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70200

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

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrPaleVioletRed
#property indicator_color3 clrLimeGreen
#property indicator_color4 clrPaleVioletRed
#property indicator_color5 clrLimeGreen
#property indicator_color6 clrPaleVioletRed
#property indicator_color7 clrLimeGreen
#property indicator_color8 clrPaleVioletRed
#property indicator_minimum 0
#property indicator_maximum 5

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
   ma_lsma,  // Linear regression value (lsma)
   ma_dema   // Double exponential moving average - DEMA
};

input string TimeFrame1 = "Current time frame";
input string TimeFrame2 = "next1";
input string TimeFrame3 = "next2";
input string TimeFrame4 = "next3";
input int HMAPeriod_ = 15;                // Hma Period to use
input enPrices HMAPrice = pr_haweighted; // Price to use
input enMaTypes HMAMethod = ma_lwma;     // Hma average type
input double HMASpeed = 1.8;             // Hma Speed
input string UniqueID = "4 Time hull trend";
input int LinesWidth = 0;
input color LabelsColor = clrDarkGray;
input int LabelsHorizontalShift = 5;
input double LabelsVerticalShift = 1.25;
input bool alertsOn = false;
input bool alertsMessage = true;
input bool alertsSound = false;
input bool alertsEmail = false;
input bool alertsNotify = false;

double hulltre1u[];
double hulltre1d[];
double hulltre2u[];
double hulltre2d[];
double hulltre3u[];
double hulltre3d[];
double hulltre4u[];
double hulltre4d[];

int HalfPeriod, HullPeriod;
int timeFrames[4];
bool returnBars;
bool calculateValue;
string indicatorFileName;
int HMAPeriod;
int init()
{
   SetIndexBuffer(0, hulltre1u);
   SetIndexBuffer(1, hulltre1d);
   SetIndexBuffer(2, hulltre2u);
   SetIndexBuffer(3, hulltre2d);
   SetIndexBuffer(4, hulltre3u);
   SetIndexBuffer(5, hulltre3d);
   SetIndexBuffer(6, hulltre4u);
   SetIndexBuffer(7, hulltre4d);

   HMAPeriod = (int)fmax(2, HMAPeriod_);
   HalfPeriod = (int)floor(HMAPeriod / HMASpeed);
   HullPeriod = (int)floor(sqrt(HMAPeriod));
   indicatorFileName = WindowExpertName();
   returnBars = (TimeFrame1 == "returnBars");
   if (returnBars)
      return (0);
   calculateValue = (TimeFrame1 == "calculateValue");
   if (calculateValue)
      return (0);

   for (int i = 0; i < 8; i++)
   {
      SetIndexStyle(i, DRAW_ARROW, EMPTY, LinesWidth);
      SetIndexArrow(i, 110);
   }
   timeFrames[0] = stringToTimeFrame(TimeFrame4);
   timeFrames[1] = stringToTimeFrame(TimeFrame3);
   timeFrames[2] = stringToTimeFrame(TimeFrame2);
   timeFrames[3] = stringToTimeFrame(TimeFrame1);
   IndicatorShortName(UniqueID);
   return (0);
}

int deinit()
{
   for (int t = 0; t < 4; t++)
      ObjectDelete(UniqueID + t);
   return (0);
}

double trend[][2];
#define _up 0
#define _dn 1
int start()
{
   int i, r, counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   if (returnBars)
   {
      hulltre1u[0] = limit + 1;
      return (0);
   }
   if (calculateValue)
   {
      calculateHull(limit);
      return (0);
   }

   if (timeFrames[0] != Period())
      limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, timeFrames[0], indicatorFileName, "returnBars", 0, 0) * timeFrames[0] / Period()));
   if (timeFrames[1] != Period())
      limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, timeFrames[1], indicatorFileName, "returnBars", 0, 0) * timeFrames[1] / Period()));
   if (timeFrames[2] != Period())
      limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, timeFrames[2], indicatorFileName, "returnBars", 0, 0) * timeFrames[2] / Period()));
   if (timeFrames[3] != Period())
      limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, timeFrames[3], indicatorFileName, "returnBars", 0, 0) * timeFrames[3] / Period()));
   if (ArrayRange(trend, 0) != Bars)
      ArrayResize(trend, Bars);

   bool initialized = false;
   if (!initialized)
   {
      initialized = true;
      int window = WindowFind(UniqueID);
      for (int t = 0; t < 4; t++)
      {
         string label = timeFrameToString(timeFrames[t]);
         ObjectCreate(UniqueID + t, OBJ_TEXT, window, 0, 0);
         ObjectSet(UniqueID + t, OBJPROP_COLOR, LabelsColor);
         ObjectSet(UniqueID + t, OBJPROP_PRICE1, t + LabelsVerticalShift);
         ObjectSetText(UniqueID + t, label, 8, "Arial");
      }
   }
   for (t = 0; t < 4; t++)
      ObjectSet(UniqueID + t, OBJPROP_TIME1, Time[0] + Period() * LabelsHorizontalShift * 60);

   for (i = limit, r = Bars - i - 1; i >= 0; i--, r++)
   {
      trend[r][_up] = 0;
      trend[r][_dn] = 0;
      for (int k = 0; k < 4; k++)
      {
         int y = iBarShift(NULL, timeFrames[k], Time[i]);
         double state = iCustom(NULL, timeFrames[k], indicatorFileName, "calculateValue", "", "", "", HMAPeriod, HMAPrice, HMAMethod, HMASpeed, 0, y);
         bool isUp = (state > 0);
         switch (k)
         {
         case 0:
            if (isUp)
            {
               hulltre1u[i] = k + 1;
               hulltre1d[i] = EMPTY_VALUE;
            }
            else
            {
               hulltre1d[i] = k + 1;
               hulltre1u[i] = EMPTY_VALUE;
            }
            break;
         case 1:
            if (isUp)
            {
               hulltre2u[i] = k + 1;
               hulltre2d[i] = EMPTY_VALUE;
            }
            else
            {
               hulltre2d[i] = k + 1;
               hulltre2u[i] = EMPTY_VALUE;
            }
            break;
         case 2:
            if (isUp)
            {
               hulltre3u[i] = k + 1;
               hulltre3d[i] = EMPTY_VALUE;
            }
            else
            {
               hulltre3d[i] = k + 1;
               hulltre3u[i] = EMPTY_VALUE;
            }
            break;
         case 3:
            if (isUp)
            {
               hulltre4u[i] = k + 1;
               hulltre4d[i] = EMPTY_VALUE;
            }
            else
            {
               hulltre4d[i] = k + 1;
               hulltre4u[i] = EMPTY_VALUE;
            }
            break;
         }
         if (isUp)
            trend[r][_up] += 1;
         else
            trend[r][_dn] += 1;
      }
   }
   manageAlerts();
   return (0);
}

void calculateHull(int limit)
{
   for (int i = limit; i >= 0; i--)
   {
      double price = getPrice(HMAPrice, Open, Close, High, Low, i, Bars);
      hulltre3u[i] = iCustomMa(HMAMethod, price, HalfPeriod, i, Bars, 0) * 2 - iCustomMa(HMAMethod, price, HMAPeriod, i, Bars, 1);
      hulltre4u[i] = iCustomMa(HMAMethod, hulltre3u[i], HullPeriod, i, Bars, 2);
      hulltre1u[i] = (i < Bars - 1) ? (hulltre4u[i] > hulltre4u[i + 1]) ? 1 : (hulltre4u[i] < hulltre4u[i + 1]) ? -1 : hulltre1u[i + 1] : 0;
   }
}

bool IsBuyAlert(int period)
{
   return hulltre2u[period] != EMPTY_VALUE && hulltre3u[period] != EMPTY_VALUE && hulltre4u[period] != EMPTY_VALUE;
}
bool IsSellAlert(int period)
{
   return hulltre2d[period] != EMPTY_VALUE && hulltre3d[period] != EMPTY_VALUE && hulltre4d[period] != EMPTY_VALUE;
}

void manageAlerts()
{
   if (alertsOn)
   {
      static datetime time1 = 0;
      static string mess1 = "";
      if (IsBuyAlert(0) && !IsBuyAlert(1))
         doAlert(time1, mess1, 0, "up", trend[0][_up]);
      if (IsSellAlert(0) && !IsSellAlert(1))
         doAlert(time1, mess1, 0, "down", trend[0][_dn]);
   }
}

void doAlert(datetime &previousTime, string &previousAlert, int forBar, string doWhat, int howMany)
{
   string message;

   if (previousAlert != doWhat || previousTime != Time[forBar])
   {
      previousAlert = doWhat;
      previousTime = Time[forBar];

      //
      //
      //
      //
      //

      message = _Symbol + " at " + TimeToStr(TimeLocal(), TIME_SECONDS) + " " + howMany + " time frames of hull trend are aligned " + doWhat;
      if (alertsMessage)
         Alert(message);
      if (alertsEmail)
         SendMail(_Symbol + " 4 time frame hull trend", message);
      if (alertsNotify)
         SendNotification(message);
      if (alertsSound)
         PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 3
#define _maWorkBufferx1 1 * _maInstances
#define _maWorkBufferx2 2 * _maInstances
#define _maWorkBufferx3 3 * _maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo = 0)
{
   r = bars - r - 1;
   switch (mode)
   {
   case ma_sma:
      return (iSma(price, (int)MathCeil(length), r, bars, instanceNo));
   case ma_ema:
      return (iEma(price, length, r, bars, instanceNo));
   case ma_smma:
      return (iSmma(price, length, r, bars, instanceNo));
   case ma_lwma:
      return (iLwma(price, (int)MathCeil(length), r, bars, instanceNo));
   case ma_slwma:
      return (iSlwma(price, (int)MathCeil(length), r, bars, instanceNo));
   case ma_dsema:
      return (iDsema(price, length, r, bars, instanceNo));
   case ma_tema:
      return (iTema(price, length, r, bars, instanceNo));
   case ma_lsma:
      return (iLinr(price, (int)MathCeil(length), r, bars, instanceNo));
   case ma_dema:
      return (iDema(price, length, r, bars, instanceNo));
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
   for (k = 1; k < SqrtPeriod && (r - k) >= 0; k++)
   {
      weight = SqrtPeriod - k;
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
      double alpha = 2.0 / (1.0 + MathSqrt(period));
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

//
//
//
//
//

double workDema[][_maWorkBufferx2];
#define _dema1 0
#define _dema2 1

double iDema(double price, double period, int r, int bars, int instanceNo = 0)
{
   if (period <= 1)
      return (price);
   if (ArrayRange(workDema, 0) != bars)
      ArrayResize(workDema, bars);
   instanceNo *= 2;

   //
   //
   //
   //
   //

   workDema[r][_dema1 + instanceNo] = price;
   workDema[r][_dema2 + instanceNo] = price;
   double alpha = 2.0 / (1.0 + period);
   if (r > 0)
   {
      workDema[r][_dema1 + instanceNo] = workDema[r - 1][_dema1 + instanceNo] + alpha * (price - workDema[r - 1][_dema1 + instanceNo]);
      workDema[r][_dema2 + instanceNo] = workDema[r - 1][_dema2 + instanceNo] + alpha * (workDema[r][_dema1 + instanceNo] - workDema[r - 1][_dema2 + instanceNo]);
   }
   return (workDema[r][_dema1 + instanceNo] * 2.0 - workDema[r][_dema2 + instanceNo]);
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
      if (ArrayRange(workHa, 0) != Bars)
         ArrayResize(workHa, Bars);
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

//
//
//
//
//

int toInt(double value) { return (value); }
int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   int max = ArraySize(iTfTable) - 1, add = 0;
   int nxt = (StringFind(tfs, "NEXT1") > -1);
   if (nxt > 0)
   {
      tfs = "" + Period();
      add = 1;
   }
   nxt = (StringFind(tfs, "NEXT2") > -1);
   if (nxt > 0)
   {
      tfs = "" + Period();
      add = 2;
   }
   nxt = (StringFind(tfs, "NEXT3") > -1);
   if (nxt > 0)
   {
      tfs = "" + Period();
      add = 3;
   }

   for (int i = max; i >= 0; i--)
      if (tfs == sTfTable[i] || tfs == "" + iTfTable[i])
         return (MathMax(iTfTable[toInt(MathMin(max, i + add))], Period()));
   return (Period());
}
string timeFrameToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
}

string stringUpperCase(string str)
{
   string s = str;

   for (int length = StringLen(str) - 1; length >= 0; length--)
   {
      int tchar = StringGetChar(s, length);
      if ((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
         s = StringSetChar(s, length, tchar - 32);
      else if (tchar > -33 && tchar < 0)
         s = StringSetChar(s, length, tchar + 224);
   }
   return (s);
}