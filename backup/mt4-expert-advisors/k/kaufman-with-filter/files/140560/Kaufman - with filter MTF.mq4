// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70886

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrYellow
#property indicator_color2 clrDeepPink
#property indicator_color3 clrDeepPink
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
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

input int inpPeriod = 14;              // Ama period
input int inpFastPeriod = 2;           // Ama fast end period
input int inpSlowPeriod = 30;          // Ama slow end period
input double inpPower = 2;             // Ama smooth power
input int inpFilter = 50;              // Filter
input int inpFilterPeriod = 4;         // Filter period
input double inpFilterDifference = 50; // Filter difference
input enPrices inpPrice = pr_close;    // Ama price
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int bars_limit = 1000; // Bars limit

double val[], valc[], ama[], valDa[], valDb[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int OnInit()
{
   double temp = iCustom(NULL, 0, "Kaufman - with filter (alerts)", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Kaufman - with filter (alerts)' indicator");
      return INIT_FAILED;
   }
   IndicatorBuffers(5);
   SetIndexBuffer(0, val, INDICATOR_DATA);
   SetIndexBuffer(1, valDa, INDICATOR_DATA);
   SetIndexBuffer(2, valDb, INDICATOR_DATA);
   SetIndexBuffer(3, ama, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, valc, INDICATOR_CALCULATIONS);

   IndicatorShortName("KAMA with filter (" + (string)inpPeriod + ")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(val, EMPTY_VALUE);
      ArrayInitialize(valDa, EMPTY_VALUE);
      ArrayInitialize(valDb, EMPTY_VALUE);
      ArrayInitialize(ama, EMPTY_VALUE);
      ArrayInitialize(valc, EMPTY_VALUE);
   }
   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      int index = pos == 0 ? 0 : iBarShift(_Symbol, tf, time[pos]);
      if (index < 0)
      {
         continue;
      }
      val[pos] = iCustom(_Symbol, tf, "Kaufman - with filter (alerts)", inpPeriod, inpFastPeriod, inpSlowPeriod, inpPower, 
         inpFilter, inpFilterPeriod, inpFilterDifference, inpPrice, 0, index);
      valDa[pos] = iCustom(_Symbol, tf, "Kaufman - with filter (alerts)", inpPeriod, inpFastPeriod, inpSlowPeriod, inpPower, 
         inpFilter, inpFilterPeriod, inpFilterDifference, inpPrice, 1, index);
      valDb[pos] = iCustom(_Symbol, tf, "Kaufman - with filter (alerts)", inpPeriod, inpFastPeriod, inpSlowPeriod, inpPower, 
         inpFilter, inpFilterPeriod, inpFilterDifference, inpPrice, 2, index);
      ama[pos] = iCustom(_Symbol, tf, "Kaufman - with filter (alerts)", inpPeriod, inpFastPeriod, inpSlowPeriod, inpPower, 
         inpFilter, inpFilterPeriod, inpFilterDifference, inpPrice, 3, index);
      valc[pos] = iCustom(_Symbol, tf, "Kaufman - with filter (alerts)", inpPeriod, inpFastPeriod, inpSlowPeriod, inpPower, 
         inpFilter, inpFilterPeriod, inpFilterDifference, inpPrice, 4, index);
   }
   return rates_total;
}
