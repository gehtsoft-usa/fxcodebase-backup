// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76113

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 9
#property strict

enum enMaTypes
  {
   avgSma,  // Simple moving average
   avgEma,  // Exponential moving average
   avgSmma, // Smoothed MA
   avgLwma  // Linear weighted MA
  };

enum enTimeFrames
  {
   tf_current = 0, // Current timeframe
   tf_M1 = 1,      // 1 minute
   tf_M5 = 5,      // 5 minutes
   tf_M15 = 15,    // 15 minutes
   tf_M30 = 30,    // 30 minutes
   tf_H1 = 60,     // 1 hour
   tf_H4 = 240,    // 4 hours
   tf_D1 = 1440,   // Daily
   tf_W1 = 10080,  // Weekly
   tf_MN1 = 43200  // Monthly
  };

extern enTimeFrames TimeFrame = tf_current; // Time frame
extern int HlPeriod = 1;                    // High low period
extern int AvgPeriod = 13;                  // Average period
extern enMaTypes AvgType = avgSma;          // Average method
extern color colorUp = clrWhite;            // Color for up
extern color colorDown = clrBlack;          // Color for down
extern color colorNeutral = clrSilver;      // Color for neutral
extern color colorShadow = clrDimGray;      // Color for "shadow"
extern int linesWidth = 3;                  // Lines width

double avg[], avgda[], avgdb[], avgua[], avgub[], shadow[], slope[], flu[], flm[], fld[];

int mtfTimeFrame;
string mtfSymbol;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   mtfTimeFrame = TimeFrame;
   if(mtfTimeFrame == 0)
      mtfTimeFrame = Period();
   mtfSymbol = Symbol();
   string shortName = "Low-high bands MTF (" + IntegerToString(mtfTimeFrame) + ")";
   IndicatorShortName(shortName);
   for(int i = 0; i < indicator_buffers; i++)
      SetIndexStyle(i, DRAW_LINE);
   IndicatorBuffers(10);
   SetIndexBuffer(0, flu);
   SetIndexStyle(0, EMPTY, STYLE_DOT, 0, clrNONE);
   SetIndexBuffer(1, flm);
   SetIndexStyle(1, EMPTY, STYLE_DOT, 0, clrNONE);
   SetIndexBuffer(2, fld);
   SetIndexStyle(2, EMPTY, STYLE_DOT, 0, clrNONE);
   SetIndexBuffer(3, shadow);
   SetIndexStyle(3, EMPTY, EMPTY, linesWidth + 6, colorShadow);
   SetIndexBuffer(4, avg);
   SetIndexStyle(4, EMPTY, EMPTY, linesWidth, colorNeutral);
   SetIndexBuffer(5, avgda);
   SetIndexStyle(5, EMPTY, EMPTY, linesWidth, colorDown);
   SetIndexBuffer(6, avgdb);
   SetIndexStyle(6, EMPTY, EMPTY, linesWidth, colorDown);
   SetIndexBuffer(7, avgua);
   SetIndexStyle(7, EMPTY, EMPTY, linesWidth, colorUp);
   SetIndexBuffer(8, avgub);
   SetIndexStyle(8, EMPTY, EMPTY, linesWidth, colorUp);
   SetIndexBuffer(9, slope);
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)
      return (-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   if(mtfTimeFrame == Period())
     {
      if(slope[limit] == -1)
         CleanPoint(limit, avgda, avgdb);
      if(slope[limit] == 1)
         CleanPoint(limit, avgua, avgub);
      for(int i = limit; i >= 0; i--)
        {
         flu[i] = High[ArrayMaximum(High, HlPeriod, i)];
         fld[i] = Low[ArrayMinimum(Low, HlPeriod, i)];
         flm[i] = (flu[i] + fld[i]) / 2.0;
         avg[i] = iCustomMa(AvgType, flm[i], AvgPeriod, i, 0);
         shadow[i] = avg[i];
         avgda[i] = EMPTY_VALUE;
         avgdb[i] = EMPTY_VALUE;
         avgua[i] = EMPTY_VALUE;
         avgub[i] = EMPTY_VALUE;
         if(i < Bars - 1)
           {
            slope[i] = slope[i + 1];
            if(avg[i] > flm[i])
               slope[i] = -1;
            if(avg[i] < flm[i])
               slope[i] = 1;
           }
         if(slope[i] == -1)
            PlotPoint(i, avgda, avgdb, avg);
         if(slope[i] == 1)
            PlotPoint(i, avgua, avgub, avg);
        }
     }
   else
     {
      if(slope[limit] == -1)
         CleanPoint(limit, avgda, avgdb);
      if(slope[limit] == 1)
         CleanPoint(limit, avgua, avgub);
      for(int i = limit; i >= 0; i--)
        {
         datetime barTime = Time[i];
         int mtfShift = iBarShift(mtfSymbol, mtfTimeFrame, barTime, false);
         if(mtfShift >= 0)
           {
            double mtfHigh = getMtfHigh(mtfShift);
            double mtfLow = getMtfLow(mtfShift);
            flu[i] = mtfHigh;
            fld[i] = mtfLow;
            flm[i] = (flu[i] + fld[i]) / 2.0;
            avg[i] = getMtfAverage(mtfShift, flm[i]);
            shadow[i] = avg[i];
            avgda[i] = EMPTY_VALUE;
            avgdb[i] = EMPTY_VALUE;
            avgua[i] = EMPTY_VALUE;
            avgub[i] = EMPTY_VALUE;
            if(i < Bars - 1)
              {
               slope[i] = slope[i + 1];
               if(avg[i] > flm[i])
                  slope[i] = -1;
               if(avg[i] < flm[i])
                  slope[i] = 1;
              }
            if(slope[i] == -1)
               PlotPoint(i, avgda, avgdb, avg);
            if(slope[i] == 1)
               PlotPoint(i, avgua, avgub, avg);
           }
         else
           {
            flu[i] = EMPTY_VALUE;
            fld[i] = EMPTY_VALUE;
            flm[i] = EMPTY_VALUE;
            avg[i] = EMPTY_VALUE;
            shadow[i] = EMPTY_VALUE;
            avgda[i] = EMPTY_VALUE;
            avgdb[i] = EMPTY_VALUE;
            avgua[i] = EMPTY_VALUE;
            avgub[i] = EMPTY_VALUE;
           }
        }
     }
   return (0);
  }

#define _maInstances 1
#define _maWorkBufferx1 1 * _maInstances
#define _maWorkBufferx2 2 * _maInstances

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iCustomMa(int mode, double price, double length, int r, int instanceNo = 0)
  {
   r = Bars - r - 1;
   switch(mode)
     {
      case avgSma:
         return (iSma(price, (int)length, r, instanceNo));
      case avgEma:
         return (iEma(price, length, r, instanceNo));
      case avgSmma:
         return (iSmma(price, (int)length, r, instanceNo));
      case avgLwma:
         return (iLwma(price, (int)length, r, instanceNo));
      default:
         return (price);
     }
  }

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo = 0)
  {
   if(period <= 1)
      return (price);
   if(ArrayRange(workSma, 0) != Bars)
      ArrayResize(workSma, Bars);
   instanceNo *= 2;
   int k;
   workSma[r][instanceNo + 0] = price;
   workSma[r][instanceNo + 1] = price;
   for(k = 1; k < period && (r - k) >= 0; k++)
      workSma[r][instanceNo + 1] += workSma[r - k][instanceNo + 0];
   workSma[r][instanceNo + 1] /= 1.0 * k;
   return (workSma[r][instanceNo + 1]);
  }

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo = 0)
  {
   if(period <= 1)
      return (price);
   if(ArrayRange(workEma, 0) != Bars)
      ArrayResize(workEma, Bars);
   workEma[r][instanceNo] = price;
   double alpha = 2.0 / (1.0 + period);
   if(r > 0)
      workEma[r][instanceNo] = workEma[r - 1][instanceNo] + alpha * (price - workEma[r - 1][instanceNo]);
   return (workEma[r][instanceNo]);
  }

//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo = 0)
  {
   if(period <= 1)
      return (price);
   if(ArrayRange(workSmma, 0) != Bars)
      ArrayResize(workSmma, Bars);
   if(r < period)
      workSmma[r][instanceNo] = price;
   else
      workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
   return (workSmma[r][instanceNo]);
  }

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo = 0)
  {
   if(period <= 1)
      return (price);
   if(ArrayRange(workLwma, 0) != Bars)
      ArrayResize(workLwma, Bars);
   workLwma[r][instanceNo] = price;
   double sumw = period;
   double sum = period * price;
   for(int k = 1; k < period && (r - k) >= 0; k++)
     {
      double weight = period - k;
      sumw += weight;
      sum += weight * workLwma[r - k][instanceNo];
     }
   return (sum / sumw);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanPoint(int i, double &first[], double &second[])
  {
   if(i >= Bars - 3)
      return;
   if((second[i] != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
      second[i + 1] = EMPTY_VALUE;
   else
      if((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
         first[i + 1] = EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlotPoint(int i, double &first[], double &second[], double &from[])
  {
   if(i >= Bars - 2)
      return;
   if(first[i + 1] == EMPTY_VALUE)
      if(first[i + 2] == EMPTY_VALUE)
        {
         first[i] = from[i];
         first[i + 1] = from[i + 1];
         second[i] = EMPTY_VALUE;
        }
      else
        {
         second[i] = from[i];
         second[i + 1] = from[i + 1];
         first[i] = EMPTY_VALUE;
        }
   else
     {
      first[i] = from[i];
      second[i] = EMPTY_VALUE;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMtfHigh(int shift)
  {
   double maxHigh = iHigh(mtfSymbol, mtfTimeFrame, shift);
   for(int k = 1; k < HlPeriod; k++)
     {
      double high = iHigh(mtfSymbol, mtfTimeFrame, shift + k);
      if(high > maxHigh)
         maxHigh = high;
     }
   return maxHigh;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMtfLow(int shift)
  {
   double minLow = iLow(mtfSymbol, mtfTimeFrame, shift);
   for(int k = 1; k < HlPeriod; k++)
     {
      double low = iLow(mtfSymbol, mtfTimeFrame, shift + k);
      if(low < minLow)
         minLow = low;
     }
   return minLow;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMtfAverage(int shift, double price)
  {
   double sum = 0;
   int count = 0;
   for(int k = 0; k < AvgPeriod; k++)
     {
      double mtfHigh = iHigh(mtfSymbol, mtfTimeFrame, shift + k);
      double mtfLow = iLow(mtfSymbol, mtfTimeFrame, shift + k);
      if(mtfHigh > 0 && mtfLow > 0)
        {
         sum += (mtfHigh + mtfLow) / 2.0;
         count++;
        }
     }
   if(count > 0)
     {
      double avgPrice = sum / count;
      switch(AvgType)
        {
         case avgSma:
            return avgPrice;
         case avgEma:
            return getMtfEma(shift, avgPrice);
         case avgSmma:
            return getMtfSmma(shift, avgPrice);
         case avgLwma:
            return getMtfLwma(shift, avgPrice);
         default:
            return avgPrice;
        }
     }
   return price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMtfEma(int shift, double price)
  {
   static double prevValue = 0;
   double alpha = 2.0 / (1.0 + AvgPeriod);
   if(shift == 0 || prevValue == 0)
      prevValue = price;
   else
      prevValue = prevValue + alpha * (price - prevValue);
   return prevValue;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMtfSmma(int shift, double price)
  {
   static double prevValue = 0;
   if(shift == 0 || prevValue == 0)
      prevValue = price;
   else
      prevValue = prevValue + (price - prevValue) / AvgPeriod;
   return prevValue;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMtfLwma(int shift, double price)
  {
   double sum = 0;
   double sumw = 0;
   for(int k = 0; k < AvgPeriod; k++)
     {
      double mtfHigh = iHigh(mtfSymbol, mtfTimeFrame, shift + k);
      double mtfLow = iLow(mtfSymbol, mtfTimeFrame, shift + k);
      if(mtfHigh > 0 && mtfLow > 0)
        {
         double weight = AvgPeriod - k;
         sum += weight * (mtfHigh + mtfLow) / 2.0;
         sumw += weight;
        }
     }
   return (sumw > 0) ? sum / sumw : price;
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76113

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+