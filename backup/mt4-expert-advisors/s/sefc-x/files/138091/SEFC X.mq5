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
#property indicator_minimum -0.0001
#property indicator_maximum 0.0001
#property indicator_buffers 4
#property indicator_plots 3
#property indicator_color1 Black
#property indicator_color2 LimeGreen
#property indicator_width2 4
#property indicator_color3 Violet
#property indicator_width3 4

input int period = 12;
double g_ibuf_80[];
double g_ibuf_84[];
double g_ibuf_88[];
string gs_100 = "[+]";

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

double out[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("sefcx");
   IndicatorSetString(INDICATOR_SHORTNAME, "SEFC X");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, g_ibuf_80, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, g_ibuf_84, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, g_ibuf_88, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id, ld_48, INDICATOR_CALCULATIONS);
}
double ld_48[];

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
      ArrayInitialize(ld_48, 0);
      ArrayInitialize(g_ibuf_80, 0);
      ArrayInitialize(g_ibuf_84, 0);
      ArrayInitialize(g_ibuf_88, 0);
   }
   int first = 1;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double l_high_104 = iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, iHighest(NULL, 0, MODE_HIGH, period, oldPos));
      double l_low_96 = iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, iLowest(NULL, 0, MODE_LOW, period, oldPos));
      double ld_16 = (high[pos] + low[pos]) / 2.0;
      ld_48[pos] = 0.66 * ((ld_16 - l_low_96) / (l_high_104 - l_low_96) - 0.5) + 0.67 * ld_48[pos - 1];
      ld_48[pos] = MathMin(MathMax(ld_48[pos], -0.999), 0.999);
      g_ibuf_80[pos] = MathLog((ld_48[pos] + 1.0) / (1 - ld_48[pos])) / 2.0 + g_ibuf_80[pos - 1] / 2.0;
      if ((g_ibuf_80[pos] > 0.0 && g_ibuf_80[pos - 1] < 0.0) || g_ibuf_80[pos] > 0.0) 
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
