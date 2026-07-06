//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76326
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
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
//HEADER:END

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers    18
#property indicator_color1     clrGray
#property indicator_levelcolor clrPeru
#property indicator_maximum    100
#property indicator_minimum    0
#property strict

//
//
//
//
//

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
   pr_haopen,     // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
  };

extern int                Length1               = 4;                // Rsx1 length
extern enPrices           Price1                = pr_close;         // Rsx1 price
extern color              ColorUp1              = clrLimeGreen;     // Color for up
extern color              ColorDown1            = clrRed;           // Color for down
extern double             levelOb1              = 80;               // Overbought level
extern double             levelOs1              = 20;               // Oversold level
extern string             arrowsIdentifier1     = "RSX1_Arrow";    // Unique ID for RSX1 arrows

// Second RSX instance parameters
extern int                Length2               = 14;               // Rsx2 length
extern enPrices           Price2                = pr_close;         // Rsx2 price
extern color              ColorUp2              = clrLimeGreen;     // Color for up (RSX2)
extern color              ColorDown2            = clrRed;           // Color for down (RSX2)
extern double             levelOb2              = 95;               // Overbought level
extern double             levelOs2              = 5;                // Oversold level
extern string             arrowsIdentifier2     = "RSX2_Arrow";    // Unique ID for RSX2 arrows

extern color              ShadowColor           = clrGray;          // Shadow color
extern int                LineWidth             = 3;                // Main line width
extern int                ShadowWidth           = 0;                // Shadow width (<=0 main line width+3)
extern bool               drawRSX1              = true;             // Draw RSX1 line?
extern bool               drawRSX2              = true;             // Draw RSX2 line?
extern bool               arrowsVisible         = true;             // Arrows visible?
extern bool               preventRepeatingArrows  = false;          // Prevent repeating arrows
extern int                barsToIgnore          = 100;              // Bars to prevent repeatint arrows
extern double             arrowsUpperGap         = 1.0;             // Upper arrow gap
extern double             arrowsLowerGap        = 1.0;              // Lower arrow gap
extern color              arrowsUpColor         = clrDeepSkyBlue;   // Up arrow color
extern color              arrowsDnColor         = clrPaleVioletRed; // Down arrow color
extern int                arrowsUpCode          = 139;              // Up arrow code
extern int                arrowsDnCode          = 139;              // Down arrow code
extern bool               alertsOn              = false;            // Turn alerts on?
extern bool               alertsOnCurrent       = false;            // Alerts on still opened bar?
extern bool               alertsMessage         = true;             // Alerts should display message?
extern bool               alertsSound           = false;            // Alerts should play a sound?
extern bool               alertsNotify          = false;            // Alerts should send a notification?
extern bool               alertsEmail           = false;            // Alerts should send an email?
extern string             soundFile             = "alert2.wav";     // Sound file


double rsx[], buffer1da[], buffer1db[], buffer1ua[], buffer1ub[], shadowa[], shadowb[], value[], trend[];
double rsx2[], buffer1da2[], buffer1db2[], buffer1ua2[], buffer1ub2[], shadowa2[], shadowb2[], value2[], trend2[];

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
   {
    int shadowWidth = (ShadowWidth <= 0) ? LineWidth + 3 : ShadowWidth;
    IndicatorBuffers(18);
    SetIndexBuffer(0, rsx);
    SetIndexBuffer(1, shadowa);
    SetIndexBuffer(2, shadowb);
    SetIndexBuffer(3, buffer1ua);
    SetIndexBuffer(4, buffer1ub);
    SetIndexBuffer(5, buffer1da);
    SetIndexBuffer(6, buffer1db);
    SetIndexBuffer(7, trend);
    SetIndexBuffer(8, value);
    SetIndexBuffer(9, rsx2);
    SetIndexBuffer(10, shadowa2);
    SetIndexBuffer(11, shadowb2);
    SetIndexBuffer(12, buffer1ua2);
    SetIndexBuffer(13, buffer1ub2);
    SetIndexBuffer(14, buffer1da2);
    SetIndexBuffer(15, buffer1db2);
    SetIndexBuffer(16, trend2);
    SetIndexBuffer(17, value2);

    if(drawRSX1)
       {
         SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, LineWidth, ShadowColor);
         SetIndexLabel(0, "RSX1");
         SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, shadowWidth, ShadowColor);
         SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, shadowWidth, ShadowColor);
         SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, LineWidth, ColorUp1);
         SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, LineWidth, ColorUp1);
         SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, LineWidth, ColorDown1);
         SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, LineWidth, ColorDown1);
       }
    else
       {
         SetIndexStyle(0, DRAW_NONE);
         SetIndexLabel(0, "");
         SetIndexStyle(1, DRAW_NONE);
         SetIndexStyle(2, DRAW_NONE);
         SetIndexStyle(3, DRAW_NONE);
         SetIndexStyle(4, DRAW_NONE);
         SetIndexStyle(5, DRAW_NONE);
         SetIndexStyle(6, DRAW_NONE);
       }

    if(drawRSX2)
       {
         SetIndexStyle(9, DRAW_LINE, STYLE_SOLID, LineWidth, ShadowColor);
         SetIndexLabel(9, "RSX2");
         SetIndexStyle(10, DRAW_LINE, STYLE_SOLID, shadowWidth, ShadowColor);
         SetIndexStyle(11, DRAW_LINE, STYLE_SOLID, shadowWidth, ShadowColor);
         SetIndexStyle(12, DRAW_LINE, STYLE_SOLID, LineWidth, ColorUp2);
         SetIndexStyle(13, DRAW_LINE, STYLE_SOLID, LineWidth, ColorUp2);
         SetIndexStyle(14, DRAW_LINE, STYLE_SOLID, LineWidth, ColorDown2);
         SetIndexStyle(15, DRAW_LINE, STYLE_SOLID, LineWidth, ColorDown2);
       }
    else
       {
         SetIndexStyle(9, DRAW_NONE);
         SetIndexLabel(9, "");
         SetIndexStyle(10, DRAW_NONE);
         SetIndexStyle(11, DRAW_NONE);
         SetIndexStyle(12, DRAW_NONE);
         SetIndexStyle(13, DRAW_NONE);
         SetIndexStyle(14, DRAW_NONE);
         SetIndexStyle(15, DRAW_NONE);
       }
    SetLevelValue(0, levelOs1);
    SetLevelValue(1, levelOb1);
    SetLevelValue(2, levelOs2);
    SetLevelValue(3, levelOb2);
    SetLevelValue(4, 50);
    IndicatorShortName("RSX1 (" + (string)Length1 + ") / RSX2 (" + (string)Length2 + ")");
    return(0);
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
   {
    ClearArrows(arrowsIdentifier1);
    ClearArrows(arrowsIdentifier2);
    return(0);
   }

void ClearArrows(const string identifier)
   {
    string lookFor       = identifier + ":";
    int    lookForLength = StringLen(lookFor);
    for(int i = ObjectsTotal() - 1; i >= 0; i--)
       {
         string objectName = ObjectName(i);
         if(StringSubstr(objectName, 0, lookForLength) == lookFor)
             ObjectDelete(objectName);
       }
   }

double wrkBuffer[][13];
double wrkBuffer2[][13];

void calculateRSX1(int limit);
void calculateRSX2(int limit);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
   {
    int counted_bars = IndicatorCounted();
    if(counted_bars < 0)
         return(-1);
      if(counted_bars > 0)
         counted_bars--;
    int limit = MathMin(Bars - counted_bars, Bars - 1);

    calculateRSX1(limit);
    calculateRSX2(limit);

    return(0);
   }

void calculateRSX1(int limit)
   {
    if(limit < 0)
         return;
    double Kg = (3.0) / (2.0 + Length1);
    double Hg = 1.0 - Kg;
    if(ArrayRange(wrkBuffer, 0) != Bars)
         ArrayResize(wrkBuffer, Bars);
    if(value[limit] == -1)
       {
         CleanPoint(limit, buffer1da, buffer1db);
         CleanPoint(limit, shadowa, shadowb);
       }
    if(value[limit] == 1)
       {
         CleanPoint(limit, buffer1ua, buffer1ub);
         CleanPoint(limit, shadowa, shadowb);
       }
    for(int i = limit, r = Bars - i - 1; i >= 0; i--, r++)
       {
         wrkBuffer[r][12] = getPrice(Price1, Open, Close, High, Low, i);
         if(i == (Bars - 1))
            {
             for(int c = 0; c < 12; c++)
                  wrkBuffer[r][c] = 0;
             continue;
            }
         double mom = wrkBuffer[r][12] - wrkBuffer[r - 1][12];
         double moa = fabs(mom);
         for(int k = 0; k < 3; k++)
            {
             int kk = k * 2;
             wrkBuffer[r][kk + 0] = Kg * mom                + Hg * wrkBuffer[r - 1][kk + 0];
             wrkBuffer[r][kk + 1] = Kg * wrkBuffer[r][kk + 0] + Hg * wrkBuffer[r - 1][kk + 1];
             mom = 1.5 * wrkBuffer[r][kk + 0] - 0.5 * wrkBuffer[r][kk + 1];
             wrkBuffer[r][kk + 6] = Kg * moa                + Hg * wrkBuffer[r - 1][kk + 6];
             wrkBuffer[r][kk + 7] = Kg * wrkBuffer[r][kk + 6] + Hg * wrkBuffer[r - 1][kk + 7];
             moa = 1.5 * wrkBuffer[r][kk + 6] - 0.5 * wrkBuffer[r][kk + 7];
            }
         if(moa != 0)
             rsx[i] = fmax(fmin((mom / moa + 1.0) * 50.0, 100.00), 0.00);
         else
             rsx[i] = 50;
         buffer1da[i] = EMPTY_VALUE;
         buffer1db[i] = EMPTY_VALUE;
         buffer1ua[i] = EMPTY_VALUE;
         buffer1ub[i] = EMPTY_VALUE;
         shadowa[i]   = EMPTY_VALUE;
         shadowb[i]   = EMPTY_VALUE;
         value[i] = (rsx[i] > levelOb1) ? -1 : (rsx[i] < levelOs1) ? 1 : 0;
         trend[i] = (rsx[i] > levelOb1) ? 1 : (rsx[i] < levelOs1) ? -1 : 0;
         if(value[i] == -1)
            {
             PlotPoint(i, buffer1da, buffer1db, rsx);
             PlotPoint(i, shadowa, shadowb, rsx);
            }
         if(value[i] == 1)
            {
             PlotPoint(i, buffer1ua, buffer1ub, rsx);
             PlotPoint(i, shadowa, shadowb, rsx);
            }
         if(arrowsVisible)
            {
             string lookFor = arrowsIdentifier1 + ":" + (string)Time[i];
             ObjectDelete(lookFor);
             bool arrDn = true;
             bool arrUp = true;
             if(i < Bars - 1 && trend[i] != trend[i + 1])
                {
                  if(preventRepeatingArrows)
                     {
                      arrDn = true;
                      arrUp = true;
                      for(int k = i; k < MathMin(Bars - 1, i + barsToIgnore); k++)
                         {
                           string name = arrowsIdentifier1 + ":" + (string)Time[k];
                           if(ObjectFind(0, name) >= 0 && ObjectGetDouble(0, name, OBJPROP_PRICE) <= Low[k])
                              {
                               arrUp = false;
                               break;
                              }
                           if(ObjectFind(0, name) >= 0 && ObjectGetDouble(0, name, OBJPROP_PRICE) >= High[k])
                              {
                               arrDn = false;
                               break;
                              }
                         }
                     }
                  if(trend[i + 1] == 1 && trend[i] != 1 && arrDn)
                      drawArrow(i, arrowsDnColor, arrowsDnCode, true);
                  if(trend[i + 1] == -1 && trend[i] != -1 && arrUp)
                      drawArrow(i, arrowsUpColor, arrowsUpCode, false);
                }
            }
       }
    if(alertsOn)
       {
         int whichBar = 1;
         if(alertsOnCurrent)
             whichBar = 0;
         string name = arrowsIdentifier1 + ":" + (string)Time[whichBar];
         if(trend[whichBar] != trend[whichBar + 1])
            {
             if(ObjectFind(0, name) >= 0 && ObjectGetDouble(0, name, OBJPROP_PRICE) >= High[whichBar])
                  doAlert(whichBar, "sell");
             if(ObjectFind(0, name) >= 0 && ObjectGetDouble(0, name, OBJPROP_PRICE) <= Low[whichBar])
                  doAlert(whichBar, "buy");
            }
       }
   }

void calculateRSX2(int limit)
   {
    if(limit < 0)
         return;
    double Kg = (3.0) / (2.0 + Length2);
    double Hg = 1.0 - Kg;
    if(ArrayRange(wrkBuffer2, 0) != Bars)
         ArrayResize(wrkBuffer2, Bars);
    if(value2[limit] == -1)
       {
         CleanPoint2(limit, buffer1da2, buffer1db2);
         CleanPoint2(limit, shadowa2, shadowb2);
       }
    if(value2[limit] == 1)
       {
         CleanPoint2(limit, buffer1ua2, buffer1ub2);
         CleanPoint2(limit, shadowa2, shadowb2);
       }
    for(int i = limit, r = Bars - i - 1; i >= 0; i--, r++)
       {
         wrkBuffer2[r][12] = getPrice2(Price2, Open, Close, High, Low, i);
         if(i == (Bars - 1))
            {
             for(int c = 0; c < 12; c++)
                  wrkBuffer2[r][c] = 0;
             continue;
            }
         double mom = wrkBuffer2[r][12] - wrkBuffer2[r - 1][12];
         double moa = fabs(mom);
         for(int k = 0; k < 3; k++)
            {
             int kk = k * 2;
             wrkBuffer2[r][kk + 0] = Kg * mom                + Hg * wrkBuffer2[r - 1][kk + 0];
             wrkBuffer2[r][kk + 1] = Kg * wrkBuffer2[r][kk + 0] + Hg * wrkBuffer2[r - 1][kk + 1];
             mom = 1.5 * wrkBuffer2[r][kk + 0] - 0.5 * wrkBuffer2[r][kk + 1];
             wrkBuffer2[r][kk + 6] = Kg * moa                + Hg * wrkBuffer2[r - 1][kk + 6];
             wrkBuffer2[r][kk + 7] = Kg * wrkBuffer2[r][kk + 6] + Hg * wrkBuffer2[r - 1][kk + 7];
             moa = 1.5 * wrkBuffer2[r][kk + 6] - 0.5 * wrkBuffer2[r][kk + 7];
            }
         if(moa != 0)
             rsx2[i] = fmax(fmin((mom / moa + 1.0) * 50.0, 100.00), 0.00);
         else
             rsx2[i] = 50;
         buffer1da2[i] = EMPTY_VALUE;
         buffer1db2[i] = EMPTY_VALUE;
         buffer1ua2[i] = EMPTY_VALUE;
         buffer1ub2[i] = EMPTY_VALUE;
         shadowa2[i]   = EMPTY_VALUE;
         shadowb2[i]   = EMPTY_VALUE;
         value2[i] = (rsx2[i] > levelOb2) ? -1 : (rsx2[i] < levelOs2) ? 1 : 0;
         trend2[i] = (rsx2[i] > levelOb2) ? 1 : (rsx2[i] < levelOs2) ? -1 : 0;
         if(value2[i] == -1)
            {
             PlotPoint2(i, buffer1da2, buffer1db2, rsx2);
             PlotPoint2(i, shadowa2, shadowb2, rsx2);
            }
         if(value2[i] == 1)
            {
             PlotPoint2(i, buffer1ua2, buffer1ub2, rsx2);
             PlotPoint2(i, shadowa2, shadowb2, rsx2);
            }
         if(arrowsVisible)
            {
             string lookFor = arrowsIdentifier2 + ":" + (string)Time[i];
             ObjectDelete(lookFor);
             bool arrDn = true;
             bool arrUp = true;
             if(i < Bars - 1 && trend2[i] != trend2[i + 1])
                {
                  if(preventRepeatingArrows)
                     {
                      arrDn = true;
                      arrUp = true;
                      for(int k = i; k < MathMin(Bars - 1, i + barsToIgnore); k++)
                         {
                           string name = arrowsIdentifier2 + ":" + (string)Time[k];
                           if(ObjectFind(0, name) >= 0 && ObjectGetDouble(0, name, OBJPROP_PRICE) <= Low[k])
                              {
                               arrUp = false;
                               break;
                              }
                           if(ObjectFind(0, name) >= 0 && ObjectGetDouble(0, name, OBJPROP_PRICE) >= High[k])
                              {
                               arrDn = false;
                               break;
                              }
                         }
                     }
                  if(trend2[i + 1] == 1 && trend2[i] != 1 && arrDn)
                      drawArrow2(i, arrowsDnColor, arrowsDnCode, true);
                  if(trend2[i + 1] == -1 && trend2[i] != -1 && arrUp)
                      drawArrow2(i, arrowsUpColor, arrowsUpCode, false);
                }
            }
       }
    if(alertsOn)
       {
         int whichBar = 1;
         if(alertsOnCurrent)
             whichBar = 0;
         string name = arrowsIdentifier2 + ":" + (string)Time[whichBar];
         if(trend2[whichBar] != trend2[whichBar + 1])
            {
             if(ObjectFind(0, name) >= 0 && ObjectGetDouble(0, name, OBJPROP_PRICE) >= High[whichBar])
                  doAlert2(whichBar, "sell");
             if(ObjectFind(0, name) >= 0 && ObjectGetDouble(0, name, OBJPROP_PRICE) <= Low[whichBar])
                  doAlert2(whichBar, "buy");
            }
       }
   }

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanPoint(int i, double& first[], double& second[])
  {
   if(i >= Bars - 3)
      return;
   if((second[i]  != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
      second[i + 1] = EMPTY_VALUE;
   else
      if((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
         first[i + 1] = EMPTY_VALUE;
  }

void CleanPoint2(int i, double& first[], double& second[])
  {
   if(i >= Bars - 3)
      return;
   if((second[i]  != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
      second[i + 1] = EMPTY_VALUE;
   else
      if((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
         first[i + 1] = EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlotPoint(int i, double& first[], double& second[], double& from[])
  {
   if(i >= Bars - 2)
      return;
   if(first[i + 1] == EMPTY_VALUE)
      if(first[i + 2] == EMPTY_VALUE)
        { first[i]  = from[i]; first[i + 1]  = from[i + 1]; second[i] = EMPTY_VALUE; }
      else
        {
         second[i] = from[i];
         second[i + 1] = from[i + 1];
         first[i]  = EMPTY_VALUE;
        }
   else
     {
      first[i]  = from[i];
      second[i] = EMPTY_VALUE;
     }
  }

void PlotPoint2(int i, double& first[], double& second[], double& from[])
   {
    if(i >= Bars - 2)
         return;
    if(first[i + 1] == EMPTY_VALUE)
         if(first[i + 2] == EMPTY_VALUE)
            { first[i]  = from[i]; first[i + 1]  = from[i + 1]; second[i] = EMPTY_VALUE; }
         else
            {
             second[i] = from[i];
             second[i + 1] = from[i + 1];
             first[i]  = EMPTY_VALUE;
            }
    else
       {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
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
//

#define priceInstances 3
double workHa[][priceInstances * 4];
double workHa2[][priceInstances * 4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo = 0)
  {
   if(tprice >= pr_haclose)
     {
      if(ArrayRange(workHa, 0) != Bars)
         ArrayResize(workHa, Bars);
      instanceNo *= 4;
      int r = Bars - i - 1;
      //
      //
      //
      //
      //
      double haOpen;
      if(r > 0)
         haOpen  = (workHa[r - 1][instanceNo + 2] + workHa[r - 1][instanceNo + 3]) / 2.0;
      else
         haOpen  = (open[i] + close[i]) / 2;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh  = MathMax(high[i], MathMax(haOpen, haClose));
      double haLow   = MathMin(low[i], MathMin(haOpen, haClose));
      if(haOpen  < haClose)
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
      switch(tprice)
        {
         case pr_haclose:
            return(haClose);
         case pr_haopen:
            return(haOpen);
         case pr_hahigh:
            return(haHigh);
         case pr_halow:
            return(haLow);
         case pr_hamedian:
            return((haHigh + haLow) / 2.0);
         case pr_hamedianb:
            return((haOpen + haClose) / 2.0);
         case pr_hatypical:
            return((haHigh + haLow + haClose) / 3.0);
         case pr_haweighted:
            return((haHigh + haLow + haClose + haClose) / 4.0);
         case pr_haaverage:
            return((haHigh + haLow + haClose + haOpen) / 4.0);
         case pr_hatbiased:
            if(haClose > haOpen)
               return((haHigh + haClose) / 2.0);
            else
               return((haLow + haClose) / 2.0);
         case pr_hatbiased2:
            if(haClose > haOpen)
               return(haHigh);
            if(haClose < haOpen)
               return(haLow);
            return(haClose);
        }
     }
//
//
//
//
//
   switch(tprice)
     {
      case pr_close:
         return(close[i]);
      case pr_open:
         return(open[i]);
      case pr_high:
         return(high[i]);
      case pr_low:
         return(low[i]);
      case pr_median:
         return((high[i] + low[i]) / 2.0);
      case pr_medianb:
         return((open[i] + close[i]) / 2.0);
      case pr_typical:
         return((high[i] + low[i] + close[i]) / 3.0);
      case pr_weighted:
         return((high[i] + low[i] + close[i] + close[i]) / 4.0);
      case pr_average:
         return((high[i] + low[i] + close[i] + open[i]) / 4.0);
      case pr_tbiased:
         if(close[i] > open[i])
            return((high[i] + close[i]) / 2.0);
         else
            return((low[i] + close[i]) / 2.0);
      case pr_tbiased2:
         if(close[i] > open[i])
            return(high[i]);
         if(close[i] < open[i])
            return(low[i]);
         return(close[i]);
     }
   return(0);
  }

double getPrice2(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo = 0)
  {
   if(tprice >= pr_haclose)
     {
      if(ArrayRange(workHa2, 0) != Bars)
         ArrayResize(workHa2, Bars);
      instanceNo *= 4;
      int r = Bars - i - 1;
      double haOpen;
      if(r > 0)
         haOpen  = (workHa2[r - 1][instanceNo + 2] + workHa2[r - 1][instanceNo + 3]) / 2.0;
      else
         haOpen  = (open[i] + close[i]) / 2;
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh  = MathMax(high[i], MathMax(haOpen, haClose));
      double haLow   = MathMin(low[i], MathMin(haOpen, haClose));
      if(haOpen  < haClose)
        {
         workHa2[r][instanceNo + 0] = haLow;
         workHa2[r][instanceNo + 1] = haHigh;
        }
      else
        {
         workHa2[r][instanceNo + 0] = haHigh;
         workHa2[r][instanceNo + 1] = haLow;
        }
      workHa2[r][instanceNo + 2] = haOpen;
      workHa2[r][instanceNo + 3] = haClose;
      switch(tprice)
        {
         case pr_haclose:
            return(haClose);
         case pr_haopen:
            return(haOpen);
         case pr_hahigh:
            return(haHigh);
         case pr_halow:
            return(haLow);
         case pr_hamedian:
            return((haHigh + haLow) / 2.0);
         case pr_hamedianb:
            return((haOpen + haClose) / 2.0);
         case pr_hatypical:
            return((haHigh + haLow + haClose) / 3.0);
         case pr_haweighted:
            return((haHigh + haLow + haClose + haClose) / 4.0);
         case pr_haaverage:
            return((haHigh + haLow + haClose + haOpen) / 4.0);
         case pr_hatbiased:
            if(haClose > haOpen)
               return((haHigh + haClose) / 2.0);
            else
               return((haLow + haClose) / 2.0);
         case pr_hatbiased2:
            if(haClose > haOpen)
               return(haHigh);
            if(haClose < haOpen)
               return(haLow);
            return(haClose);
        }
     }
   switch(tprice)
     {
      case pr_close:
         return(close[i]);
      case pr_open:
         return(open[i]);
      case pr_high:
         return(high[i]);
      case pr_low:
         return(low[i]);
      case pr_median:
         return((high[i] + low[i]) / 2.0);
      case pr_medianb:
         return((open[i] + close[i]) / 2.0);
      case pr_typical:
         return((high[i] + low[i] + close[i]) / 3.0);
      case pr_weighted:
         return((high[i] + low[i] + close[i] + close[i]) / 4.0);
      case pr_average:
         return((high[i] + low[i] + close[i] + open[i]) / 4.0);
      case pr_tbiased:
         if(close[i] > open[i])
            return((high[i] + close[i]) / 2.0);
         else
            return((low[i] + close[i]) / 2.0);
      case pr_tbiased2:
         if(close[i] > open[i])
            return(high[i]);
         if(close[i] < open[i])
            return(low[i]);
         return(close[i]);
     }
   return(0);
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert = "nothing";
   static datetime previousTime;
   string message;
   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];
      //
      //
      //
      //
      //
      message =  StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " RSX1 ", doWhat);
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol(), " RSX1 "), message);
      if(alertsSound)
         PlaySound(soundFile);
     }
  }

void doAlert2(int forBar, string doWhat)
  {
   static string   previousAlert = "nothing2";
   static datetime previousTime;
   string message;
   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];
      message =  StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " RSX2 ", doWhat);
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol(), " RSX2 "), message);
      if(alertsSound)
         PlaySound(soundFile);
     }
  }

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(int i, color theColor, int theCode, bool up)
  {
   string name = arrowsIdentifier1 + ":" + (string)Time[i];
   double gap  = iATR(NULL, 0, 20, i);
//
//
//
//
//
//int add = 0; if (!arrowsOnFirst) add = _Period*60-1;
   ObjectCreate(name, OBJ_ARROW, 0, Time[i], 0);
   ObjectSet(name, OBJPROP_ARROWCODE, theCode);
   ObjectSet(name, OBJPROP_COLOR, theColor);
   if(up)
      ObjectSet(name, OBJPROP_PRICE1, High[i] + arrowsUpperGap * gap);
   else
      ObjectSet(name, OBJPROP_PRICE1, Low[i]  - arrowsLowerGap * gap);
  }

void drawArrow2(int i, color theColor, int theCode, bool up)
  {
   string name = arrowsIdentifier2 + ":" + (string)Time[i];
   double gap  = iATR(NULL, 0, 20, i);
//
//
//
//
//
//int add = 0; if (!arrowsOnFirst) add = _Period*60-1;
   ObjectCreate(name, OBJ_ARROW, 0, Time[i], 0);
   ObjectSet(name, OBJPROP_ARROWCODE, theCode);
   ObjectSet(name, OBJPROP_COLOR, theColor);
   if(up)
      ObjectSet(name, OBJPROP_PRICE1, High[i] + arrowsUpperGap * gap);
   else
      ObjectSet(name, OBJPROP_PRICE1, Low[i]  - arrowsLowerGap * gap);
  }
//+------------------------------------------------------------------+
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76326
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
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
//FOOTER:END 