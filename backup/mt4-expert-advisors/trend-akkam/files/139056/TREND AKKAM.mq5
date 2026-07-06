
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70649

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

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1
#property indicator_color1 Orange
double     akk_range=100;
double     ima_range = 1;
input double     akk_factor=6;
input int bars_limit = 1000; // Bars limit
int        Mode = 0;
double     DeltaPrice = 30;

double TrStop[],STOOP, DeltaStop[];
double ATR[];


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
int atr;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("TREND");
   IndicatorSetString(INDICATOR_SHORTNAME, "TREND");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, TrStop, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id++, ATR, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, DeltaStop, INDICATOR_CALCULATIONS);

   atr = iATR(_Symbol, _Period, akk_range);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(atr);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

#include <MovingAverages.mqh>
void MAOnArray(const int rates_total, const int prev_calculated, int sourceFirst, ENUM_MA_METHOD method, int period, double& in[], double& out[])
{
   if (period == 1)
   {
      for (int pos = sourceFirst; pos < rates_total; ++pos)
      {
         out[pos] = in[pos];
      }
      return;
   }
   int weightsum;
   switch (method)
   {
      case MODE_SMA:
         SimpleMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_EMA:
         ExponentialMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_SMMA:
         SmoothedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out);
         break;
      case MODE_LWMA:
         LinearWeightedMAOnBuffer(rates_total, prev_calculated, sourceFirst, period, in, out, weightsum);
         break;
   }
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
      ArrayInitialize(TrStop, EMPTY_VALUE);
      ArrayInitialize(ATR, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double buffer[1];
      if (CopyBuffer(atr, 0, oldPos, 1, buffer) != 1)
      {
         continue;
      }
      ATR[pos] = buffer[0];
      if (Mode != 0)
      {
         DeltaStop[pos] = DeltaPrice * Point();
      }
   }
   if (Mode == 0) 
   {
      MAOnArray(rates_total, prev_calculated, ima_range, MODE_EMA, ima_range, ATR, DeltaStop);
   }
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      if (open[pos] == TrStop[pos - 1])
      {
         TrStop[pos] = TrStop[pos - 1];
      }
      else
      {
         if (open[pos - 1] < TrStop[pos - 1] && open[pos] < TrStop[pos - 1])
         {
            TrStop[pos] = MathMin(TrStop[pos - 1], open[pos] + DeltaStop[pos]);
         }
         else
         {
            if (open[pos - 1] > TrStop[pos - 1] && open[pos] > TrStop[pos - 1])
            {
               TrStop[pos] = MathMax(TrStop[pos - 1], open[pos] - DeltaStop[pos]);
            }
            else
            {
               if (open[pos] > TrStop[pos - 1])
               {
                  TrStop[pos] = open[pos] - DeltaStop[pos];
               }
               else
               {
                  TrStop[pos] = open[pos] + DeltaStop[pos];
               }
            }
         }
      }
   }
   return rates_total;
}
  