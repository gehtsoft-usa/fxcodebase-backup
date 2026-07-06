// -- Project -------------------------------------------------------------------------------
/*
Name:        Corridor_SSA
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=159626#p159626
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/

#property copyright "Copyright (c) 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots 5
#property indicator_color1 clrYellow
#property indicator_color2 clrLimeGreen
#property indicator_color3 clrOrange
#property indicator_color4 clrLime
#property indicator_color5 clrRed
#property indicator_width2 2
#property indicator_width3 2
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_ARROW
#property indicator_type5 DRAW_ARROW
#property indicator_level1 0.0
input string TimeFrame               = "Current time frame";
input ENUM_APPLIED_PRICE SSAPrice    = PRICE_CLOSE;
input int    SSALag                  = 25;
input int    SSANumberOfComputations = 2;
input int    SSAPeriodNormalization  = 25;
input int    SSANumberOfBars         = 300;
input int    FirstBar                = 400;
input double HighLowStep             = 0.005;
input int    Shift                   = 0;
input bool   showdivergences         = true; // Divergences
double in[];
double max[];
double min[];
double no[];
double bullDiv[];
double bearDiv[];
double indiMin[];
double indiMax[];
double ssaIn[];
double ssaOut[];
int    timeFrame;
string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    ma_handle;
int    dev_handle;
int    price_handle;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   SetIndexBuffer(0, in, INDICATOR_DATA);
   SetIndexBuffer(1, max, INDICATOR_DATA);
   SetIndexBuffer(2, min, INDICATOR_DATA);
   SetIndexBuffer(3, bullDiv, INDICATOR_DATA);
   SetIndexBuffer(4, bearDiv, INDICATOR_DATA);
   SetIndexBuffer(5, no, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, indiMin, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, indiMax, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(in, true);
   ArraySetAsSeries(max, true);
   ArraySetAsSeries(min, true);
   ArraySetAsSeries(bullDiv, true);
   ArraySetAsSeries(bearDiv, true);
   ArraySetAsSeries(no, true);
   ArraySetAsSeries(indiMin, true);
   ArraySetAsSeries(indiMax, true);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(3, PLOT_ARROW, 233);
   PlotIndexSetString(3, PLOT_LABEL, "Bullish Divergence");
   PlotIndexSetInteger(4, PLOT_ARROW, 234);
   PlotIndexSetString(4, PLOT_LABEL, "Bearish Divergence");
   indicatorFileName = MQLInfoString(MQL_PROGRAM_NAME);
   calculateValue = (TimeFrame == "calculateValue");
   if(calculateValue)
      return(INIT_SUCCEEDED);
   returnBars = (TimeFrame == "returnBars");
   if(returnBars)
      return(INIT_SUCCEEDED);
   timeFrame = stringToTimeFrame(TimeFrame);
   PlotIndexSetInteger(0, PLOT_SHIFT, Shift * timeFrame / PeriodSeconds(PERIOD_CURRENT));
   PlotIndexSetInteger(1, PLOT_SHIFT, Shift * timeFrame / PeriodSeconds(PERIOD_CURRENT));
   PlotIndexSetInteger(2, PLOT_SHIFT, Shift * timeFrame / PeriodSeconds(PERIOD_CURRENT));
   ma_handle = iMA(NULL, PERIOD_CURRENT, SSAPeriodNormalization, 0, MODE_SMA, SSAPrice);
   dev_handle = iStdDev(NULL, PERIOD_CURRENT, SSAPeriodNormalization, 0, MODE_SMA, SSAPrice);
   price_handle = iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_SMA, SSAPrice);
   if(ma_handle == INVALID_HANDLE || dev_handle == INVALID_HANDLE || price_handle == INVALID_HANDLE)
     {
      Print("Error creating indicator handles");
      return(INIT_FAILED);
     }
   IndicatorSetString(INDICATOR_SHORTNAME, timeFrameToString(timeFrame) + " Corridor SSA normalized end-pointed");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ma_handle != INVALID_HANDLE)
      IndicatorRelease(ma_handle);
   if(dev_handle != INVALID_HANDLE)
      IndicatorRelease(dev_handle);
   if(price_handle != INVALID_HANDLE)
      IndicatorRelease(price_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   int counted_bars = prev_calculated;
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = MathMin(rates_total - counted_bars, rates_total - 1);
   if(returnBars)
     {
      in[0] = limit + 1;
      return(rates_total);
     }
   if(calculateValue || timeFrame == PeriodSeconds(PERIOD_CURRENT))
     {
      double ma_buffer[];
      double dev_buffer[];
      double price_buffer[];
      ArraySetAsSeries(ma_buffer, true);
      ArraySetAsSeries(dev_buffer, true);
      ArraySetAsSeries(price_buffer, true);
      int to_copy = rates_total;
      if(CopyBuffer(ma_handle, 0, 0, to_copy, ma_buffer) <= 0)
         return(0);
      if(CopyBuffer(dev_handle, 0, 0, to_copy, dev_buffer) <= 0)
         return(0);
      if(CopyBuffer(price_handle, 0, 0, to_copy, price_buffer) <= 0)
         return(0);
      ArrayInitialize(bullDiv, EMPTY_VALUE);
      ArrayInitialize(bearDiv, EMPTY_VALUE);
      ArrayInitialize(indiMin, EMPTY_VALUE);
      ArrayInitialize(indiMax, EMPTY_VALUE);
      for(int i = limit; i >= 0; i--)
        {
         double ma = ma_buffer[i];
         double dev = 3.0 * dev_buffer[i];
         double price = price_buffer[i];
         if(dev == 0)
            dev = 0.000001;
         no[i] = (price - ma) / dev;
         in[i] = 0;
         min[i] = 0;
         max[i] = 0;
         if(i <= FirstBar)
           {
            int ssaBars = MathMin(rates_total - i, SSANumberOfBars);
            if(ssaBars < SSALag)
               continue;
            if(ArraySize(ssaIn) != ssaBars)
              {
               ArrayResize(ssaIn, ssaBars);
               ArrayResize(ssaOut, ssaBars);
               ArraySetAsSeries(ssaIn, true);
               ArraySetAsSeries(ssaOut, true);
              }
            ArrayCopy(ssaIn, no, 0, i, ssaBars);
            fastSingular(ssaIn, ssaBars, SSALag, SSANumberOfComputations, ssaOut);
            in[i] = ssaOut[0];
            if(i + 1 < rates_total)
               max[i] = MathMax(in[i], max[i + 1] - HighLowStep);
            else
               max[i] = in[i];
            if(i + 1 < rates_total)
               min[i] = MathMin(in[i], min[i + 1] + HighLowStep);
            else
               min[i] = in[i];
           }
         indiMin[i] = EMPTY_VALUE;
         indiMax[i] = EMPTY_VALUE;
         if(i + 2 < rates_total && in[i + 1] < in[i + 2] && in[i + 1] < in[i])
           {
            indiMin[i + 1] = in[i + 1];
           }
         if(i + 2 < rates_total && in[i + 1] > in[i + 2] && in[i + 1] > in[i])
           {
            indiMax[i + 1] = in[i + 1];
           }
        }
      PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, rates_total - FirstBar);
      PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, rates_total - FirstBar);
      PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, rates_total - FirstBar);
      if(showdivergences)
        {
         for(int i = 0; i < rates_total; i++)
           {
            bullDiv[i] = EMPTY_VALUE;
            bearDiv[i] = EMPTY_VALUE;
           }
         double tolerance = 0.0001;
         for(int i = limit; i >= 1 && i < rates_total - 1; i++)
           {
            if(in[i] == 0 || max[i] == 0 || min[i] == 0 || in[i + 1] == 0 || max[i + 1] == 0 || min[i + 1] == 0)
               continue;
            if(MathAbs(in[i + 1] - max[i + 1]) < tolerance && in[i] < max[i] - tolerance)
              {
               bearDiv[i] = in[i];
              }
            if(MathAbs(in[i + 1] - min[i + 1]) < tolerance && in[i] > min[i] + tolerance)
              {
               bullDiv[i] = in[i];
              }
           }
        }
      return(rates_total);
     }
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)timeFrame;
   limit = MathMax(limit, MathMin(rates_total - 1, (int)(iCustom(NULL, tf, indicatorFileName, "returnBars", 0, 0) * timeFrame / PeriodSeconds(PERIOD_CURRENT))));
   for(int i = limit; i >= 0; i--)
     {
      int y = iBarShift(NULL, tf, time[i]);
      in[i] = iCustom(NULL, tf, indicatorFileName, "calculateValue", SSAPrice, SSALag, SSANumberOfComputations, SSAPeriodNormalization, SSANumberOfBars, FirstBar, HighLowStep, 0, 0, y);
      max[i] = iCustom(NULL, tf, indicatorFileName, "calculateValue", SSAPrice, SSALag, SSANumberOfComputations, SSAPeriodNormalization, SSANumberOfBars, FirstBar, HighLowStep, 0, 1, y);
      min[i] = iCustom(NULL, tf, indicatorFileName, "calculateValue", SSAPrice, SSALag, SSANumberOfComputations, SSAPeriodNormalization, SSANumberOfBars, FirstBar, HighLowStep, 0, 2, y);
     }
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, rates_total - FirstBar * timeFrame / PeriodSeconds(PERIOD_CURRENT));
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, rates_total - FirstBar * timeFrame / PeriodSeconds(PERIOD_CURRENT));
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, rates_total - FirstBar * timeFrame / PeriodSeconds(PERIOD_CURRENT));
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fastSingular(double &sourceArray[], int arraySize, int lag, int numberOfComputationLoops, double &destinationArray[])
  {
   if(arraySize < lag || lag < 2)
     {
      ArrayCopy(destinationArray, sourceArray);
      return;
     }
   int K = arraySize - lag + 1;
   int L = lag;
   double trajectory[];
   ArrayResize(trajectory, L * K);
   ArraySetAsSeries(trajectory, true);
   for(int i = 0; i < L; i++)
     {
      for(int j = 0; j < K; j++)
        {
         trajectory[i * K + j] = sourceArray[i + j];
        }
     }
   double covariance[];
   ArrayResize(covariance, L * L);
   ArraySetAsSeries(covariance, true);
   for(int i = 0; i < L; i++)
     {
      for(int j = 0; j < L; j++)
        {
         double sum = 0;
         for(int k = 0; k < K; k++)
           {
            sum += trajectory[i * K + k] * trajectory[j * K + k];
           }
         covariance[i * L + j] = sum / K;
        }
     }
   double eigenvectors[];
   double eigenvalues[];
   ArrayResize(eigenvectors, numberOfComputationLoops * L);
   ArrayResize(eigenvalues, numberOfComputationLoops);
   ArraySetAsSeries(eigenvalues, true);
   ArraySetAsSeries(eigenvectors, true);
   for(int comp = 0; comp < numberOfComputationLoops; comp++)
     {
      for(int i = 0; i < L; i++)
        {
         eigenvectors[comp * L + i] = MathRand() / 32767.0 - 0.5;
        }
      for(int iter = 0; iter < 50; iter++)
        {
         double newVec[];
         ArrayResize(newVec, L);
         ArraySetAsSeries(newVec, true);
         for(int i = 0; i < L; i++)
           {
            double sum = 0;
            for(int j = 0; j < L; j++)
              {
               sum += covariance[i * L + j] * eigenvectors[comp * L + j];
              }
            newVec[i] = sum;
           }
         double norm = 0;
         for(int i = 0; i < L; i++)
           {
            norm += newVec[i] * newVec[i];
           }
         norm = MathSqrt(norm);
         if(norm > 0)
           {
            for(int i = 0; i < L; i++)
              {
               eigenvectors[comp * L + i] = newVec[i] / norm;
              }
           }
        }
      double ev = 0;
      for(int i = 0; i < L; i++)
        {
         double sum = 0;
         for(int j = 0; j < L; j++)
           {
            sum += covariance[i * L + j] * eigenvectors[comp * L + j];
           }
         ev += eigenvectors[comp * L + i] * sum;
        }
      eigenvalues[comp] = ev;
      for(int i = 0; i < L; i++)
        {
         for(int j = 0; j < L; j++)
           {
            covariance[i * L + j] -= eigenvalues[comp] * eigenvectors[comp * L + i] * eigenvectors[comp * L + j];
           }
        }
     }
   ArrayResize(destinationArray, arraySize);
   ArraySetAsSeries(destinationArray, true);
   ArrayInitialize(destinationArray, 0);
   for(int comp = 0; comp < numberOfComputationLoops; comp++)
     {
      double principalComponent[];
      ArrayResize(principalComponent, K);
      ArraySetAsSeries(principalComponent, true);
      for(int j = 0; j < K; j++)
        {
         double sum = 0;
         for(int i = 0; i < L; i++)
           {
            sum += eigenvectors[comp * L + i] * trajectory[i * K + j];
           }
         principalComponent[j] = sum;
        }
      double reconstructed[];
      ArrayResize(reconstructed, arraySize);
      ArraySetAsSeries(reconstructed, true);
      ArrayInitialize(reconstructed, 0);
      int counts[];
      ArrayResize(counts, arraySize);
      ArraySetAsSeries(counts, true);
      ArrayInitialize(counts, 0);
      for(int i = 0; i < L; i++)
        {
         for(int j = 0; j < K; j++)
           {
            int idx = i + j;
            if(idx < arraySize)
              {
               reconstructed[idx] += eigenvectors[comp * L + i] * principalComponent[j];
               counts[idx]++;
              }
           }
        }
      for(int i = 0; i < arraySize; i++)
        {
         if(counts[i] > 0)
           {
            destinationArray[i] += reconstructed[i] / counts[i];
           }
        }
     }
  }
string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {60, 300, 900, 1800, 3600, 14400, 86400, 604800, 2592000};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
  {
   tfs = stringUpperCase(tfs);
   for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
     {
      if(tfs == sTfTable[i] || tfs == IntegerToString(iTfTable[i]))
         return(MathMax(iTfTable[i], PeriodSeconds(PERIOD_CURRENT)));
     }
   return(PeriodSeconds(PERIOD_CURRENT));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
     {
      if(tf == iTfTable[i])
         return(sTfTable[i]);
     }
   return("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string stringUpperCase(string str)
  {
   string s = str;
   StringToUpper(s);
   return(s);
  }
//+------------------------------------------------------------------+
