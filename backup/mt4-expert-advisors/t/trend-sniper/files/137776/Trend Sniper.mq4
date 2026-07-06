// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70468

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
#property indicator_buffers 5

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
   for (int k = ObjectsTotal(); k >= 0; k--)
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
double gain_loss_open_abs[], gain_loss_low[], gain_loss_low_abs[], RSI_high[], RSI_open[], RSI_low[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("ts");
   IndicatorShortName("Trend Sniper");

   IndicatorBuffers(13);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, RSI_extra_color);
   SetIndexBuffer(id, RSI_extra);
   SetIndexLabel(id, "RSI Extra");
   ++id;

   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, RSI_close_color);
   SetIndexBuffer(id, RSI_close);
   SetIndexLabel(id, "RSI Close");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, RSI_close_color);
   SetIndexBuffer(id, RSI_open);
   SetIndexLabel(id, "RSI Open");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, RSI_close_color);
   SetIndexBuffer(id, RSI_high);
   SetIndexLabel(id, "RSI High");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, RSI_close_color);
   SetIndexBuffer(id, RSI_low);
   SetIndexLabel(id, "RSI Low");
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, gain_loss_close);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, gain_loss_close_abs);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, gain_loss_high);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, gain_loss_high_abs);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, gain_loss_open);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, gain_loss_open_abs);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, gain_loss_low);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, gain_loss_low_abs);
   ++id;

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
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
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 1;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      if (showExtra)
      {
         int index = pos == 0 ? 0 : iBarShift(_Symbol, higherTime, time[pos]);
         if (index >= 0)
         {
            RSI_extra[pos] = iRSI(_Symbol, higherTime, len2, PRICE_CLOSE, pos);
         }
      }

      double norm_close = (close[pos] + close[pos + 1]) / 2;
      gain_loss_close[pos] = (close[pos] - close[pos + 1]) / norm_close;
      gain_loss_close_abs[pos] = MathAbs(gain_loss_close[pos]);
      double gain_loss_close_ma = iMAOnArray(gain_loss_close, 0, len, 0, MODE_EMA, pos);
      double gain_loss_close_abs_ma = iMAOnArray(gain_loss_close_abs, 0, len, 0, MODE_EMA, pos);
      RSI_close[pos] = 50 + 50 * gain_loss_close_ma / gain_loss_close_abs_ma;

      double norm_open = (open[pos] + open[pos + 1]) / 2;
      if (wicks)
      {
         norm_open = (close[pos] + close[pos + 1]) / 2;
      }
      gain_loss_open[pos] = (open[pos] - open[pos + 1]) / norm_open;
      gain_loss_open_abs[pos] = MathAbs(gain_loss_open[pos]);
      double gain_loss_open_ma = iMAOnArray(gain_loss_open, 0, len, 0, MODE_EMA, pos);
      double gain_loss_open_abs_ma = iMAOnArray(gain_loss_open_abs, 0, len, 0, MODE_EMA, pos);
      RSI_open[pos] = 50 + 50 * gain_loss_open_ma / gain_loss_open_abs_ma;

      double norm_high = (high[pos] + high[pos + 1]) / 2;
      if (wicks)
      {
         norm_high = (close[pos] + close[pos + 1]) / 2;
      }
      gain_loss_high[pos] = (high[pos] - high[pos + 1]) / norm_high;
      gain_loss_high_abs[pos] = MathAbs(gain_loss_high[pos]);
      double gain_loss_high_ma = iMAOnArray(gain_loss_high, 0, len, 0, MODE_EMA, pos);
      double gain_loss_high_abs_ma = iMAOnArray(gain_loss_high_abs, 0, len, 0, MODE_EMA, pos);
      RSI_high[pos] = 50 + 50 * gain_loss_high_ma / gain_loss_high_abs_ma;

      double norm_low = (low[pos] + low[pos + 1]) / 2;
      if (wicks)
      {
         norm_low = (close[pos] + close[pos + 1]) / 2;
      }
      gain_loss_low[pos] = (low[pos] - low[pos + 1]) / norm_low;
      gain_loss_low_abs[pos] = MathAbs(gain_loss_low[pos]);
      double gain_loss_low_ma = iMAOnArray(gain_loss_low, 0, len, 0, MODE_EMA, pos);
      double gain_loss_low_abs_ma = iMAOnArray(gain_loss_low_abs, 0, len, 0, MODE_EMA, pos);
      RSI_low[pos] = 50 + 50 * gain_loss_low_ma / gain_loss_low_abs_ma;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
