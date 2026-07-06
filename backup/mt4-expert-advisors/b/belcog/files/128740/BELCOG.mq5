// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68929

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
#property version   "1.1"
#property strict

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 7
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red

input int N = 180; // Number of bars
input int O = 3; // Order
input double E = 1.61803399; // Eccart value

double L1[], L2[], L3[], L4[], L5[], L6[], L7[];

datetime prevCandle;

double StDev(int Per)
{
   return(MathSqrt(Variance(Per)));
}
double Variance(int Per)
{
   double sum = 0;
   double ssum = 0;
   for (int i=0; i<Per; i++)
   {
      double high = iHigh(_Symbol, 0, i);
      sum += high;
      ssum += MathPow(high, 2);
   }
   return((ssum*Per - sum*sum)/(Per*(Per-1)));
}

int start()
{
   
   return 0;
}

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
   IndicatorObjPrefix = GenerateIndicatorPrefix("bcog");
   IndicatorSetString(INDICATOR_SHORTNAME, "Belkhayate's Center Of Gravity");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, L1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "L1");
   ++id;
   SetIndexBuffer(id, L2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "L2");
   ++id;
   SetIndexBuffer(id, L3, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "L3");
   ++id;
   SetIndexBuffer(id, L4, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "L4");
   ++id;
   SetIndexBuffer(id, L5, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "L5");
   ++id;
   SetIndexBuffer(id, L6, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "L6");
   ++id;
   SetIndexBuffer(id, L7, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "L7");
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
      ArrayInitialize(L1, EMPTY_VALUE);
      ArrayInitialize(L2, EMPTY_VALUE);
      ArrayInitialize(L3, EMPTY_VALUE);
      ArrayInitialize(L4, EMPTY_VALUE);
      ArrayInitialize(L5, EMPTY_VALUE);
      ArrayInitialize(L6, EMPTY_VALUE);
      ArrayInitialize(L7, EMPTY_VALUE);
   }
   if (prevCandle == time[rates_total - 1])
   {
      return rates_total;
   }
   prevCandle = time[rates_total - 1];
   int pos = 0;
   int s = O + 1;
   double a1[], a2[], a3[], a4[];
   ArrayResize(a1, s * s);
   ArrayResize(a2, (s - 1) * 2 + 1);
   ArrayResize(a3, s);
   ArrayResize(a4, s);
   ArrayInitialize(a1, 0);
   ArrayInitialize(a2, 0);
   ArrayInitialize(a3, 0);
   ArrayInitialize(a4, 0);
   a2[0] = N + 1;
   for (int i = 1; i <= (s - 1) * 2; ++i)
   {
      a2[i] = 0;
      for (int j = 0; j <= N; ++j)
      {
         a2[i] += MathPow(j, i);
      }
   }

   for (int j = 1; j <= s; ++j)
   {
      for (int i = 0; i <= N; ++i)
      {
         if (j == 1)
            a3[j - 1] += (iHigh(_Symbol, 0, pos + i) + iLow(_Symbol, 0, pos + i)) / 2;
         else
            a3[j - 1] += (iHigh(_Symbol, 0, pos + i) + iLow(_Symbol, 0, pos + i)) / 2 * (MathPow(i, j - 1));
      }
      for (int i = 1; i <= s; ++i)
      {
         a1[(i - 1) * s + j - 1] = a2[i + j - 2];
      }
   }

   for (int i = 1; i <= s - 1; ++i)
   {
      int si = 0;
      int v1 = 0;
      for (int j = i; j <= s; ++j)
      {
         if (MathAbs(a1[(j - 1) * s + i - 1]) > v1)
         {
            v1 = MathAbs(a1[(j - 1) * s + i - 1]);
            si = j;
         }
      }
      if (si == 0)
      {
         continue;
      }

      if (si != i)
      {
         for (int j = 1; j <= s; ++j)
         {
            double t = a1[(i - 1) * s + j - 1];
            a1[(i - 1) * s + j - 1] = a1[(si - 1) * s + j - 1];
            a1[(si - 1) * s + j - 1] = t;
         }
         double t = a3[i - 1];
         a3[i - 1] = a3[si - 1];
         a3[si - 1] = t;
      }

      for (int j = i + 1; j <= s; ++j)
      {
         double v1 = a1[(j - 1) * s + i - 1] / a1[(i - 1) * s + i - 1];
         for (int k = 1; k <= s; ++k)
         {
            if (k == i)
            {
               a1[(j - 1) * s + k - 1] = 0;
            }
            else
            {
               a1[(j - 1) * s + k - 1] = a1[(j - 1) * s + k - 1] - v1 * a1[(i - 1) * s + k - 1];
            }
         }
         a3[j - 1] = a3[j - 1] - v1 * a3[i - 1];
      }
   }

   a4[s - 1] = a3[s - 1] / a1[(s - 1) * s + s - 1];

   for (int i = s - 1; i >= 1; --i)
   {
      double v1 = 0;
      for (int j = 1; j <= s - i; ++j)
      {
         v1 = v1 + (a1[(i - 1) * s + i + j - 1]) * (a4[i + j - 1]);
         a4[i - 1] = 1 / a1[(i - 1) * s + i - 1] * (a3[i - 1] - v1);
      }
   }

   for (int i = 0; i <= N; ++i)
   {
      double v1 = 0;
      for (int j = 1; j <= O; ++j)
      {
         v1 = v1 + (a4[j + 1 - 1]) * MathPow(i, j);
      }
      L1[rates_total - 1 - pos - i] = a4[0] + v1;
   }

   double v2 = StDev(N) * E;
   for (int i = 0; i <= N; ++i)
   {
      L4[rates_total - 1 - pos - i] = L1[rates_total - 1 - pos - i] + v2;
      L3[rates_total - 1 - pos - i] = L1[rates_total - 1 - pos - i] + (L4[rates_total - 1 - pos - i] - L1[rates_total - 1 - pos - i]) / 1.382;
      L2[rates_total - 1 - pos - i] = L1[rates_total - 1 - pos - i] + (L3[rates_total - 1 - pos - i] - L1[rates_total - 1 - pos - i]) / 1.618;
      L7[rates_total - 1 - pos - i] = L1[rates_total - 1 - pos - i] - v2;
      L6[rates_total - 1 - pos - i] = L1[rates_total - 1 - pos - i] - (L1[rates_total - 1 - pos - i] - L7[rates_total - 1 - pos - i]) / 1.382;
      L5[rates_total - 1 - pos - i] = L1[rates_total - 1 - pos - i] - (L1[rates_total - 1 - pos - i] - L6[rates_total - 1 - pos - i]) / 1.618;
   }
   for (int i = N + 1; i <= N + 10; ++i)
   {
      L1[rates_total - 1 - pos - i] = EMPTY_VALUE;
      L2[rates_total - 1 - pos - i] = EMPTY_VALUE;
      L3[rates_total - 1 - pos - i] = EMPTY_VALUE;
      L4[rates_total - 1 - pos - i] = EMPTY_VALUE;
      L5[rates_total - 1 - pos - i] = EMPTY_VALUE;
      L6[rates_total - 1 - pos - i] = EMPTY_VALUE;
      L7[rates_total - 1 - pos - i] = EMPTY_VALUE;
   }
   return rates_total;
}