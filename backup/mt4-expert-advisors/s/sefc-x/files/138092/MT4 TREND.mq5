// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70512

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
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 3
#property indicator_color1 Black
#property indicator_color2 Blue
#property indicator_width2 3
#property indicator_color3 Red
#property indicator_width3 3

input int bars_limit = 1000; // Bars limit
string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double g_ibuf_80[];
double g_ibuf_84[];
double g_ibuf_88[];
double ld_40[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Trend");
   IndicatorSetString(INDICATOR_SHORTNAME, "Trend");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, g_ibuf_80, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, g_ibuf_84, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, g_ibuf_88, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id, ld_40, INDICATOR_CALCULATIONS);
   ++id;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(g_ibuf_80, 0);
      ArrayInitialize(g_ibuf_84, EMPTY_VALUE);
      ArrayInitialize(g_ibuf_88, EMPTY_VALUE);
      ArrayInitialize(ld_40, 0);
   }
   int first = 30;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      int highestIndex = ArrayMaximum(high, pos - 30, 30);
      double l_high_96 = high[highestIndex];
      int lowestIndex = ArrayMinimum(low, pos - 30, 30);
      double l_low_88 = low[lowestIndex];
      double ld_80 = (high[pos] + low[pos]) / 2.0;
      double diff = l_high_96 - l_low_88;
      double val = diff == 0 ? 0 : (ld_80 - l_low_88) / diff;
      ld_40[pos] = MathMax(-0.999, MathMin(0.999, 0.66 * (val - 0.5) + 0.67 * ld_40[pos - 1]));
      double val2 = MathLog((ld_40[pos] + 1.0) / (1 - ld_40[pos]));
      g_ibuf_80[pos] = g_ibuf_80[pos - 1] == 0 ? val2 : val2 / 2.0 + g_ibuf_80[pos - 1] / 2.0;
      if ((g_ibuf_80[pos] < 0.0 && g_ibuf_80[pos - 1] > 0.0) || g_ibuf_80[pos] < 0.0)
      {
         g_ibuf_88[pos] = g_ibuf_80[pos];
         g_ibuf_84[pos] = 0.0;
      }
      else
      {
         g_ibuf_84[pos] = g_ibuf_80[pos];
         g_ibuf_88[pos] = 0.0;
      }
   }
   return rates_total;
}
