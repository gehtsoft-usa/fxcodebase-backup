// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=64496

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
#property indicator_buffers 3
#property indicator_plots 1

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

input int Avg1_Periods = 7;
input int Avg2_Periods = 14;
input int Avg3_Periods = 28;
input int OB_Level     = 70;
input int OS_Level     = 30;

double BP[];
double TR[];
double UO[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("uo");
   IndicatorSetString(INDICATOR_SHORTNAME, "Ultimate Oscillator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, UO, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id, TR, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, BP, INDICATOR_CALCULATIONS);
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
      ArrayInitialize(UO, EMPTY_VALUE);
      ArrayInitialize(BP, EMPTY_VALUE);
      ArrayInitialize(TR, EMPTY_VALUE);
   }
   int first = MathMax(MathMax(Avg1_Periods, Avg2_Periods), Avg3_Periods);
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      BP[pos] = close[pos] - MathMin(low[pos], close[pos - 1]);
      TR[pos] = MathMax(high[pos], close[pos - 1]) - MathMin(low[pos], close[pos - 1]);
      double bpsum1=0;
      double trsum1=0;
      double bpsum2=0;
      double trsum2=0;
      double bpsum3=0;
      double trsum3=0;
      double avg1=0;
      double avg2=0;
      double avg3=0;
      for (int i = 0; i < Avg1_Periods; ++i)
      {
         bpsum1 = bpsum1 + BP[pos - i];
         trsum1 = trsum1 + TR[pos - i];
      }
      avg1 = bpsum1 / trsum1;
      for (int i = 0; i < Avg2_Periods; ++i)
      {
         bpsum2 = bpsum2 + BP[pos - i];
         trsum2 = trsum2 + TR[pos - i];
      }
      avg2 = bpsum2 / trsum2;
      for (int i = 0; i < Avg3_Periods; ++i)
      {
         bpsum3 = bpsum3 + BP[pos - i];
         trsum3 = trsum3 + TR[pos - i];
      }
      avg3 = bpsum3 / trsum3;
      
      UO[pos] = 100 * ((4 * avg1) + (2 * avg2) + avg3) / (4 + 2 + 1);
   }
   return rates_total;
}