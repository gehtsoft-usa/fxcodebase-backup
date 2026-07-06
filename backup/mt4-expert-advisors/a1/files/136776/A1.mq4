// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70283

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

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 EMPTY //Aqua
#property indicator_color2 EMPTY //Yellow
#property indicator_color3 Aqua
#property indicator_color4 Yellow
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 2
#property indicator_width4 2
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
enum enTimeFrames
{
   tf_cu = 0,           // Current time frame
   tf_m1 = PERIOD_M1,   // 1 minute
   tf_m5 = PERIOD_M5,   // 5 minutes
   tf_m15 = PERIOD_M15, // 15 minutes
   tf_m30 = PERIOD_M30, // 30 minutes
   tf_h1 = PERIOD_H1,   // 1 hour
   tf_h4 = PERIOD_H4,   // 4 hours
   tf_d1 = PERIOD_D1,   // Daily
   tf_w1 = PERIOD_W1,   // Weekly
   tf_mb1 = PERIOD_MN1, // Monthly
   tf_cus = 12345678    // Custom time frame
};

int TimeFrameCustom;
enTimeFrames TimeFrame;
input enTimeFrames TimeFrame_ = tf_cu;   // Time frame
input int TimeFrameCustom_ = 0;          // Custom time frame to use (if custom time frame used)
input int FastMaPeriod = 5;             // Fast moving average period
input int SlowMaPeriod = 8;             // Slow moving average period
input int RsiPeriod = 14;               // Rsi period
input enMaTypes FastMaMethod = ma_lwma; // Fast moving average method
input enPrices FastMaPrice = pr_close;  // Fast moving average price to use
input enMaTypes SlowMaMethod = ma_lwma; // Slow moving average method
input enPrices SlowMaPrice = pr_close;  // Slow moving average price to use
input ENUM_APPLIED_PRICE rsi_price = PRICE_CLOSE; // RSI Price Type
input bool alertsOn = false;            // Turn alerts on?
input bool alertsOnCurrent = true;      // Alerts on current (still opened) bar?
input bool alertsMessage = true;        // Alerts should show pop-up message?
input bool alertsSound = false;         // Alerts should play alert sound?
input bool alertsPushNotif = false;     // Alerts should send push notification?
input bool alertsEmail = false;         // Alerts should send email?
input string soundFile = "alert2.wav";  // Sound file
input int ArrowSize = 3;                // Arrow size
input int ArrowCodeUp = 233;            // Arrow code up
input int ArrowCodeDn = 234;            // Arrow code down
input bool ArrowOnFirst = true;         // Arrow on first bars
input bool Interpolate = true;          // Interpolate in multi time frame mode?

double fastMa[], slowMa[], arrowu[], arrowd[], trend[], count[];
string indicatorFileName;
#define _mtfCall(_buff, _y) iCustom(NULL, TimeFrame, indicatorFileName, tf_cu, 0, FastMaPeriod, FastMaMethod, FastMaPrice, SlowMaPeriod, SlowMaMethod, SlowMaPrice, RsiPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsPushNotif, alertsEmail, soundFile, ArrowSize, ArrowCodeUp, ArrowCodeDn, ArrowOnFirst, _buff, _y)

int init()
{
   for (int i = 0; i < indicator_buffers; i++)
      SetIndexStyle(i, DRAW_LINE);
   IndicatorBuffers(6);
   SetIndexBuffer(0, fastMa);
   SetIndexBuffer(1, slowMa);
   SetIndexBuffer(2, arrowu);
   SetIndexStyle(2, DRAW_ARROW, 0, ArrowSize);
   SetIndexArrow(2, ArrowCodeUp);
   SetIndexBuffer(3, arrowd);
   SetIndexStyle(3, DRAW_ARROW, 0, ArrowSize);
   SetIndexArrow(3, ArrowCodeDn);
   SetIndexBuffer(4, trend);
   SetIndexBuffer(5, count);

   indicatorFileName = WindowExpertName();
   TimeFrame = TimeFrame_;
   TimeFrameCustom = TimeFrameCustom_;
   if (TimeFrameCustom == 0)
      TimeFrameCustom = MathMax(TimeFrameCustom, _Period);
   if (TimeFrame != tf_cus)
      TimeFrame = MathMax(TimeFrame, _Period);
   else
      TimeFrame = (enTimeFrames)TimeFrameCustom;
   IndicatorShortName(timeFrameToString(TimeFrame) + " Sidus ");
   return (0);
}
int deinit()
{
   Comment("");
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

int start()
{
   int i, counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = fmin(Bars - counted_bars, Bars - 1);
   count[0] = limit;

   //
   //
   //
   //
   //

   if (TimeFrame == _Period)
   {

      for (i = limit; i >= 0; i--)
      {
         fastMa[i] = iCustomMa(FastMaMethod, getPrice(FastMaPrice, Open, Close, High, Low, i, Bars, 0), FastMaPeriod, i, Bars, 0);
         slowMa[i] = iCustomMa(SlowMaMethod, getPrice(SlowMaPrice, Open, Close, High, Low, i, Bars, 1), SlowMaPeriod, i, Bars, 1);
         double dist = iATR(NULL, 0, 20, i);
         double rsi = iRSI(NULL, 0, RsiPeriod, rsi_price, i);
         double diff = (fastMa[i] - slowMa[i]);
         Comment("pipdiffCurrent = " + (string)diff + " ");
         arrowu[i] = EMPTY_VALUE;
         arrowd[i] = EMPTY_VALUE;
         trend[i] = (i < Bars - 1) ? (diff > 0 && rsi > 50) ? 1 : (diff < 0 && rsi < 50) ? -1 : trend[i + 1] : 0;
         if (i < Bars - 1 && trend[i] != trend[i + 1])
         {
            if (trend[i] == 1)
               arrowu[i] = fastMa[i] - dist;
            if (trend[i] == -1)
               arrowd[i] = fastMa[i] + dist;
         }
      }

      //
      //
      //
      //
      //

      if (alertsOn)
      {
         int whichBar = 1;
         if (alertsOnCurrent)
            whichBar = 0;
         if (trend[whichBar] != trend[whichBar + 1])
         {
            if (trend[whichBar] == 1)
               doAlert(" up");
            if (trend[whichBar] == -1)
               doAlert(" down");
         }
      }
      return (0);
   }
   //
   //
   //
   //
   //

   limit = (int)fmax(limit, fmin(Bars - 1, _mtfCall(5, 0) * TimeFrame / _Period));
   for (i = limit; i >= 0; i--)
   {
      int y = iBarShift(NULL, TimeFrame, Time[i]);
      int x = y;
      if (ArrowOnFirst)
      {
         if (i < Bars - 1)
            x = iBarShift(NULL, TimeFrame, Time[i + 1]);
      }
      else
      {
         if (i > 0)
            x = iBarShift(NULL, TimeFrame, Time[i - 1]);
         else
            x = -1;
      }
      fastMa[i] = _mtfCall(0, y);
      slowMa[i] = _mtfCall(1, y);
      arrowu[i] = EMPTY_VALUE;
      arrowd[i] = EMPTY_VALUE;
      if (x != y)
      {
         arrowu[i] = _mtfCall(2, y);
         arrowd[i] = _mtfCall(3, y);
      }
      if (!Interpolate || (i > 0 && y == iBarShift(NULL, TimeFrame, Time[i - 1])))
         continue;

         //
         //
         //
         //
         //

#define _interpolate(buff) buff[i + k] = buff[i] + (buff[i + n] - buff[i]) * k / n
      int n, k;
      datetime time = iTime(NULL, TimeFrame, y);
      for (n = 1; (i + n) < Bars && Time[i + n] >= time; n++)
         continue;
      for (k = 1; k < n && (i + n) < Bars && (i + k) < Bars; k++)
      {
         _interpolate(fastMa);
         _interpolate(slowMa);
      }
   }
   return (0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 2
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _prHABF(_prtype) (_prtype >= pr_habclose && _prtype <= pr_habtbiased2)
#define _priceInstances 2
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

      message = timeFrameToString(_Period) + " " + _Symbol + " at " + TimeToStr(TimeLocal(), TIME_SECONDS) + " Sidus " + doWhat;
      if (alertsMessage)
         Alert(message);
      if (alertsPushNotif)
         SendNotification(message);
      if (alertsEmail)
         SendMail(_Symbol + " Sidus ", message);
      if (alertsSound)
         PlaySound(soundFile);
   }
}

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
