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

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 5
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 DeepSkyBlue

string IndicatorObjPrefix;
input int SignalPeriod = 12;
input int ArrowPeriod = 2;
double up_trend_stop[];
double down_trend_stop[];
double up_trend_signal[];
double down_trend_signal[];
double zz_line[];
double lda_20[];
double lda_24[];

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
int bb;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("indi02");
   IndicatorSetString(INDICATOR_SHORTNAME, "Indicator 02");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   bb = iBands(_Symbol, _Period, SignalPeriod, ArrowPeriod, 0, PRICE_CLOSE);

   int id = 0;
   SetIndexBuffer(id, up_trend_stop, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 159);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetString(id, PLOT_LABEL, "UpTrend Stop");
   ++id;
   SetIndexBuffer(id, down_trend_stop, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 159);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetString(id, PLOT_LABEL, "DownTrend Stop");
   ++id;
   SetIndexBuffer(id, up_trend_signal, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 233);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetString(id, PLOT_LABEL, "UpTrend Signal");
   ++id;
   SetIndexBuffer(id, down_trend_signal, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 234);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetString(id, PLOT_LABEL, "DownTrend Signal");
   ++id;
   SetIndexBuffer(id, zz_line, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ZIGZAG);
   PlotIndexSetString(id, PLOT_LABEL, "UpTrend Line");
   ++id;

   SetIndexBuffer(id, lda_20, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, lda_24, INDICATOR_CALCULATIONS);
   ++id;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(bb);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

void AddZZ(int pos, double val)
{
   zz_line[pos] = val;
   int last1 = -1;
   int last2 = -1;
   for (int i = pos - 1; i >= 0; --i)
   {
      if (zz_line[i] != EMPTY_VALUE)
      {
         if (last1 == -1)
         {
            last1 = i;
         }
         else
         {
            last2 = i;
            break;
         }
      }
   }
   if (last2 == -1)
   {
      return;
   }
   bool upTrend = val > zz_line[last1];
   if (upTrend)
   {
      if (zz_line[last1] > zz_line[last2])
      {
         zz_line[last1] = EMPTY_VALUE;
      }
   }
   else
   {
      if (zz_line[last1] < zz_line[last2])
      {
         zz_line[last1] = EMPTY_VALUE;
      }
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
      ArrayInitialize(up_trend_stop, EMPTY_VALUE);
      ArrayInitialize(down_trend_stop, EMPTY_VALUE);
      ArrayInitialize(up_trend_signal, EMPTY_VALUE);
      ArrayInitialize(down_trend_signal, EMPTY_VALUE);
      ArrayInitialize(zz_line, EMPTY_VALUE);
   }
   int first = SignalPeriod + ArrowPeriod;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double lda_12[2], lda_16[2];
      if (CopyBuffer(bb, UPPER_BAND, oldPos, 2, lda_12) != 2 || CopyBuffer(bb, LOWER_BAND, oldPos, 2, lda_16) != 2)
      {
         continue;
      }
      int li_8 = 0;
      if (close[pos] > lda_12[1]) 
      {
         li_8 = 1;
      }
      if (close[pos] < lda_16[1]) 
      {
         li_8 = -1;
      }
      if (li_8 > 0 && lda_16[0] < lda_16[1]) 
      {
         lda_16[0] = lda_16[1];
      }
      if (li_8 < 0 && lda_12[0] > lda_12[1])
      {
         lda_12[0] = lda_12[1];
      }
      lda_20[pos] = lda_12[0];
      lda_24[pos] = lda_16[0];
      if (li_8 > 0 && lda_24[pos] < lda_24[pos - 1]) 
      {
         lda_24[pos] = lda_24[pos - 1];
      }
      if (li_8 < 0 && lda_20[pos] > lda_20[pos - 1])
      {
         lda_20[pos] = lda_20[pos - 1];
      }
      if (li_8 > 0) 
      {
         if (up_trend_stop[pos - 1] == EMPTY_VALUE) 
         {
            up_trend_signal[pos] = lda_24[pos];
            up_trend_stop[pos] = lda_24[pos];
            AddZZ(pos, lda_24[pos]);
         } 
         else 
         {
            up_trend_stop[pos] = lda_24[pos];
         }
         down_trend_signal[pos] = EMPTY_VALUE;
         down_trend_stop[pos] = EMPTY_VALUE;
      }
      if (li_8 < 0) 
      {
         if (down_trend_stop[pos - 1] == EMPTY_VALUE) 
         {
            down_trend_signal[pos] = lda_20[pos];
            down_trend_stop[pos] = lda_20[pos];
            AddZZ(pos, lda_20[pos]);
         } 
         else 
         {
            down_trend_stop[pos] = lda_20[pos];
         }
         up_trend_signal[pos] = EMPTY_VALUE;
         up_trend_stop[pos] = EMPTY_VALUE;
      }
   }
   return rates_total;
}
