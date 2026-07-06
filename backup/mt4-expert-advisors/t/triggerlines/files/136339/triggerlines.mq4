// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70231

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
#property indicator_buffers 6
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrRed
#property indicator_color3 clrRed
#property indicator_color4 clrLimeGreen
#property indicator_color5 clrRed
#property indicator_color6 clrRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property strict

//
//
//
//
//

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

input int inpPeriod = 20;           // Lsma period
input enPrices Price = pr_habclose; // Lsma price
input int button_x = 20;
input int button_y = 30;

//Visibility controller v1.3
class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;

public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;

      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
   {
      ObjectDelete(0, buttonID);
      ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
      ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
      ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
      ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
      ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
      ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
      ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width);
      ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
      ObjectSetString(0, buttonID, OBJPROP_FONT, font);
      ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
      ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
      ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
      ObjectSetInteger(0, buttonID, OBJPROP_CORNER, 2);
      ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
   }
};
VisibilityCotroller visibility;

double lsma[], lsmaUa[], lsmaUb[], lwma[], lwmaUa[], lwmaUb[], vals[], valw[];

int OnInit()
{
   visibility.Init("triggerlines", "tl", "Show/Hide", button_x, button_y);
   IndicatorBuffers(8);
   SetIndexBuffer(0, lsma, INDICATOR_DATA);
   SetIndexBuffer(1, lsmaUa, INDICATOR_DATA);
   SetIndexBuffer(2, lsmaUb, INDICATOR_DATA);
   SetIndexBuffer(3, lwma, INDICATOR_DATA);
   SetIndexBuffer(4, lwmaUa, INDICATOR_DATA);
   SetIndexBuffer(5, lwmaUb, INDICATOR_DATA);
   SetIndexBuffer(6, vals);
   SetIndexBuffer(7, valw);

   IndicatorSetString(INDICATOR_SHORTNAME, "Triggerlines");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   visibility.DeInit();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      ChartRedraw();
   }
}
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   visibility.HandleButtonClicks();
   int i = rates_total - prev_calculated + 1;
   if (i >= rates_total)
      i = rates_total - 2;

   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         i = rates_total - 2;
      }
      else
      {
         ArrayInitialize(lsma, EMPTY_VALUE);
         ArrayInitialize(lwma, EMPTY_VALUE);
         ArrayInitialize(vals, EMPTY_VALUE);
         ArrayInitialize(valw, EMPTY_VALUE);
         ArrayInitialize(lsmaUa, EMPTY_VALUE);
         ArrayInitialize(lwmaUa, EMPTY_VALUE);
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return 0;
   }

   if (vals[i] == -1)
      CleanPoint(i, lsmaUa, lsmaUb);
   if (valw[i] == -1)
      CleanPoint(i, lwmaUa, lwmaUb);
   for (; i >= 0 && !_StopFlag; i--)
   {
      double prc = getPrice(Price, open, close, high, low, i, rates_total);
      lsma[i] = iLinr(prc, inpPeriod, i, rates_total);
      lwma[i] = lsma[i + 1];
      vals[i] = (i < rates_total - 1) ? (lsma[i] > lsma[i + 1]) ? 1 : (lsma[i] < lsma[i + 1]) ? -1 : vals[i + 1] : 0;
      valw[i] = (i < rates_total - 1) ? (lwma[i] > lwma[i + 1]) ? 1 : (lwma[i] < lwma[i + 1]) ? -1 : valw[i + 1] : 0;
      lsmaUa[i] = lsmaUb[i] = EMPTY_VALUE;
      if (vals[i] == -1)
         PlotPoint(i, lsmaUa, lsmaUb, lsma);
      lwmaUa[i] = lwmaUb[i] = EMPTY_VALUE;
      if (valw[i] == -1)
         PlotPoint(i, lwmaUa, lwmaUb, lwma);
   }
   return (rates_total);
}

double workLinr[][1];
double iLinr(double price, int period, int r, int bars, int instanceNo = 0)
{
   if (ArrayRange(workLinr, 0) != bars)
      ArrayResize(workLinr, bars);
   r = bars - r - 1;

   period = fmax(period, 1);
   workLinr[r][instanceNo] = price;
   if (r < period)
      return (price);
   double lwmw = period;
   double liwma = lwmw * price;
   double sma = price;
   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = period - k;
      lwmw += weight;
      liwma += weight * workLinr[r - k][instanceNo];
      sma += workLinr[r - k][instanceNo];
   }

   return (3.0 * liwma / lwmw - 2.0 * sma / period);
}

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

      double haOpen = (r > 0) ? (open[i + 1] + close[i + 1]) * 0.5 : (open[i] + close[i]) * 0.5;
      double haClose = (open[i] + high[i] + low[i] + close[i]) * 0.25;
      if (_prHABF(tprice))
         if (high[i] != low[i])
            haClose = (open[i] + close[i]) / 2.0 + (((close[i] - open[i]) / (high[i] - low[i])) * fabs((close[i] - open[i]) / 2.0));
         else
            haClose = (open[i] + close[i]) / 2.0;
      double haHigh = fmax(high[i], fmax(haOpen, haClose));
      double haLow = fmin(low[i], fmin(haOpen, haClose));

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

void CleanPoint(int i, double &first[], double &second[])
{
   if (i >= Bars - 2)
      return;
   if ((second[i] != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
      second[i + 1] = EMPTY_VALUE;
   else if ((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
      first[i + 1] = EMPTY_VALUE;
}

void PlotPoint(int i, double &first[], double &second[], double &from[])
{
   if (i >= Bars - 2)
      return;
   if (first[i + 1] == EMPTY_VALUE)
      if (first[i + 2] == EMPTY_VALUE)
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
