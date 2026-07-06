// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70652

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
#property indicator_buffers 21
#property indicator_plots 5

input bool showExtra = true; // Show Higher Timeframe
input ENUM_TIMEFRAMES higherTime = PERIOD_M15; // Extra Timeframe
input bool std = false; // Line chart
input bool candles = true; // Candle chart
input bool wicks = true; // Wicks
input int len = 14; // Current Length
input int len2 = 14; // Extra Timeframe Length
input color RSI_close_color = Yellow; // RSI Close Color
input color RSI_extra_color = Blue; // RSI Extra Color
input int bars_limit = 100000; // Bars limit

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

double RSI_extra[], RSI_close[], gain_loss_close[], gain_loss_close_abs[], gain_loss_high[], gain_loss_high_abs[], gain_loss_open[];
double RSI_close_ma[], gain_loss_close_ma[], gain_loss_close_abs_ma[], gain_loss_high_ma[], gain_loss_high_abs_ma[], gain_loss_open_ma[];
double gain_loss_open_abs[], gain_loss_low[], gain_loss_low_abs[], RSI_high[], RSI_open[], RSI_low[];
double gain_loss_open_abs_ma[], gain_loss_low_ma[], gain_loss_low_abs_ma[];
int rsi;

int OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("ts");
   IndicatorSetString(INDICATOR_SHORTNAME, "Trend Sniper");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, RSI_extra, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, RSI_extra_color);
   PlotIndexSetString(id, PLOT_LABEL, "RSI Extra");
   ++id;

   SetIndexBuffer(id, RSI_close, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, RSI_close_color);
   PlotIndexSetString(id, PLOT_LABEL, "RSI Close");
   ++id;

   SetIndexBuffer(id, RSI_open, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, RSI_close_color);
   PlotIndexSetString(id, PLOT_LABEL, "RSI Open");
   ++id;

   SetIndexBuffer(id, RSI_high, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, RSI_close_color);
   PlotIndexSetString(id, PLOT_LABEL, "RSI High");
   ++id;

   SetIndexBuffer(id, RSI_low, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, RSI_close_color);
   PlotIndexSetString(id, PLOT_LABEL, "RSI Low");
   ++id;

   SetIndexBuffer(id++, gain_loss_close, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_close_abs, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_high, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_high_abs, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_open, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_open_abs, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_low, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_low_abs, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_close_ma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_close_abs_ma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_high_ma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_high_abs_ma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_open_ma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_open_abs_ma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_low_ma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, gain_loss_low_abs_ma, INDICATOR_CALCULATIONS);

   rsi = iRSI(_Symbol, higherTime, len2, PRICE_CLOSE);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(rsi);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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
      ArrayInitialize(RSI_extra, EMPTY_VALUE);
      ArrayInitialize(RSI_close, EMPTY_VALUE);
      ArrayInitialize(gain_loss_close, EMPTY_VALUE);
      ArrayInitialize(gain_loss_close_abs, EMPTY_VALUE);
      ArrayInitialize(gain_loss_high, EMPTY_VALUE);
      ArrayInitialize(gain_loss_high_abs, EMPTY_VALUE);
      ArrayInitialize(gain_loss_open, EMPTY_VALUE);
      ArrayInitialize(gain_loss_open_abs, EMPTY_VALUE);
      ArrayInitialize(gain_loss_low, EMPTY_VALUE);
      ArrayInitialize(gain_loss_low_abs, EMPTY_VALUE);
      ArrayInitialize(RSI_open, EMPTY_VALUE);
      ArrayInitialize(RSI_high, EMPTY_VALUE);
      ArrayInitialize(RSI_low, EMPTY_VALUE);
   }

   int first = 1;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      if (showExtra)
      {
         int index = pos == 0 ? 0 : iBarShift(_Symbol, higherTime, time[pos]);
         if (index >= 0)
         {
            double buffer[1];
            if (CopyBuffer(rsi, 0, index, 1, buffer) != 1)
            {
               continue;
            }
            RSI_extra[pos] = buffer[0];
         }
      }

      double norm_close = (close[pos] + close[pos - 1]) / 2;
      gain_loss_close[pos] = (close[pos] - close[pos - 1]) / norm_close;
      gain_loss_close_abs[pos] = MathAbs(gain_loss_close[pos]);

      double norm_open = (open[pos] + open[pos - 1]) / 2;
      if (wicks)
      {
         norm_open = (close[pos] + close[pos - 1]) / 2;
      }
      gain_loss_open[pos] = (open[pos] - open[pos - 1]) / norm_open;
      gain_loss_open_abs[pos] = MathAbs(gain_loss_open[pos]);
      
      double norm_high = (high[pos] + high[pos - 1]) / 2;
      if (wicks)
      {
         norm_high = (close[pos] + close[pos - 1]) / 2;
      }
      gain_loss_high[pos] = (high[pos] - high[pos - 1]) / norm_high;
      gain_loss_high_abs[pos] = MathAbs(gain_loss_high[pos]);

      double norm_low = (low[pos] + low[pos - 1]) / 2;
      if (wicks)
      {
         norm_low = (close[pos] + close[pos - 1]) / 2;
      }
      gain_loss_low[pos] = (low[pos] - low[pos - 1]) / norm_low;
      gain_loss_low_abs[pos] = MathAbs(gain_loss_low[pos]);
   }

   MAOnArray(rates_total, prev_calculated, len, MODE_EMA, len, gain_loss_close, gain_loss_close_ma);
   MAOnArray(rates_total, prev_calculated, len, MODE_EMA, len, gain_loss_close_abs, gain_loss_close_abs_ma);
   MAOnArray(rates_total, prev_calculated, len, MODE_EMA, len, gain_loss_open, gain_loss_open_ma);
   MAOnArray(rates_total, prev_calculated, len, MODE_EMA, len, gain_loss_open_abs, gain_loss_open_abs_ma);
   MAOnArray(rates_total, prev_calculated, len, MODE_EMA, len, gain_loss_high, gain_loss_high_ma);
   MAOnArray(rates_total, prev_calculated, len, MODE_EMA, len, gain_loss_high_abs, gain_loss_high_abs_ma);
   MAOnArray(rates_total, prev_calculated, len, MODE_EMA, len, gain_loss_low, gain_loss_low_ma);
   MAOnArray(rates_total, prev_calculated, len, MODE_EMA, len, gain_loss_low_abs, gain_loss_low_abs_ma);
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      RSI_close[pos] = 50 + 50 * gain_loss_close_ma[pos] / gain_loss_close_abs_ma[pos];
      RSI_open[pos] = 50 + 50 * gain_loss_open_ma[pos] / gain_loss_open_abs_ma[pos];
      RSI_high[pos] = 50 + 50 * gain_loss_high_ma[pos] / gain_loss_high_abs_ma[pos];
      RSI_low[pos] = 50 + 50 * gain_loss_low_ma[pos] / gain_loss_low_abs_ma[pos];
   }

   return rates_total;
}
