// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70657

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
#property indicator_buffers 10
#property indicator_plots 4

double long_src;
double short_src;
input double _long_src = 0; // Long price
input double Factor1 = 1; // Factor1
input int atr_period = 14; // ATR 1 period
input ENUM_TIMEFRAMES tf1 = PERIOD_CURRENT; // Timeframe 1
input double _short_src = 0; // Short price
input double Factor2 = 1; // Factor2
input int atr_period_2 = 14; // ATR 2 period
input ENUM_TIMEFRAMES tf2 = PERIOD_CURRENT; // Timeframe 2
input color entry_buy_color = Green; // Entry Buy Color
input color exit_buy_color = Green; // Exit Buy Color
input color entry_sell_color = Red; // Entry Sell Color
input color exit_sell_color = Red; // Exit Sell Color
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

double TRAILINGUP[], TRAILINGDOWN[], LONGUP1[], SHORTUP1[], LONGDN1[], SHORTDN1[];
double entry_buy[], exit_buy[], entry_sell[], exit_sell[];

int atr, atr2;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("lsi");
   IndicatorSetString(INDICATOR_SHORTNAME, "Longer/Shorter Indicator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   long_src = _long_src;
   short_src = _short_src;

   int id = 0;
   SetIndexBuffer(id, entry_buy, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, entry_buy_color);
   PlotIndexSetString(id, PLOT_LABEL, "Entry Buy");
   ++id;
   SetIndexBuffer(id, exit_buy, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, exit_buy_color);
   PlotIndexSetString(id, PLOT_LABEL, "Exit Buy");
   ++id;
   SetIndexBuffer(id, entry_sell, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, entry_sell_color);
   PlotIndexSetString(id, PLOT_LABEL, "Entry Buy");
   ++id;
   SetIndexBuffer(id, exit_sell, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, exit_sell_color);
   PlotIndexSetString(id, PLOT_LABEL, "Exit Buy");
   ++id;
   SetIndexBuffer(id++, TRAILINGUP, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, TRAILINGDOWN, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, LONGUP1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, SHORTUP1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, LONGDN1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, SHORTDN1, INDICATOR_CALCULATIONS);
   atr = iATR(_Symbol, tf1, atr_period);
   atr2 = iATR(_Symbol, tf2, atr_period_2);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(atr);
   IndicatorRelease(atr2);
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
      ArrayInitialize(TRAILINGUP, EMPTY_VALUE);
      ArrayInitialize(TRAILINGDOWN, EMPTY_VALUE);
      ArrayInitialize(LONGUP1, EMPTY_VALUE);
      ArrayInitialize(SHORTUP1, EMPTY_VALUE);
      ArrayInitialize(LONGDN1, EMPTY_VALUE);
      ArrayInitialize(SHORTDN1, EMPTY_VALUE);
      ArrayInitialize(entry_buy, EMPTY_VALUE);
      ArrayInitialize(exit_buy, EMPTY_VALUE);
      ArrayInitialize(entry_sell, EMPTY_VALUE);
      ArrayInitialize(exit_sell, EMPTY_VALUE);
      long_src = close[rates_total - 1 - bars_limit];
      short_src = close[rates_total - 1 - bars_limit];
   }
   
   int first = 1;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      int atr_period = pos == 0 ? 0 : iBarShift(_Symbol, tf1, time[pos]);
      if (atr_period < 0)
      {
         continue;
      }
      int atr2_period = pos == 0 ? 0 : iBarShift(_Symbol, tf2, time[pos]);
      if (atr2_period < 0)
      {
         continue;
      }
      double atrValue[1];
      if (CopyBuffer(atr, 0, atr_period + 1, 1, atrValue) != 1)
      {
         continue;
      }
      double atr2Value[1];
      if (CopyBuffer(atr2, 0, atr2_period + 1, 1, atr2Value) != 1)
      {
         continue;
      }
      if (close[pos] > long_src && TRAILINGUP[pos - 1] != EMPTY_VALUE)
      {
         double Up1 = close[pos] - Factor1 * atrValue[0];
         TRAILINGUP[pos] = MathMax(Up1, TRAILINGUP[pos - 1]);
      }
      else
      {
         TRAILINGUP[pos] = long_src;
      }
      double Up2 = close[pos - 1] - (Factor2 * atr2Value[0]);
      double LONGUPX = MathMax(TRAILINGUP[pos], long_src);
      double LONGUP = MathMin(LONGUPX, Up2);
      if (close[pos] > LONGUP1[pos - 1] && LONGUP1[pos - 1] != EMPTY_VALUE)
      {
         LONGUP1[pos] = MathMax(LONGUP, LONGUP1[pos - 1]);
      }
      else
      {
         LONGUP1[pos] = LONGUP;
      }
      double LONGDNX = MathMax(TRAILINGUP[pos], long_src);
      double Dn2 = close[pos - 1] + (Factor2 * atr2Value[0]);
      double LONGDN = MathMax(LONGDNX, Dn2);
      if (close[pos] < LONGDN1[pos - 1] && LONGDN1[pos - 1] != EMPTY_VALUE)
      {
         LONGDN1[pos] = MathMin(LONGDN, LONGDN1[pos - 1]);
      }
      else
      {
         LONGDN1[pos] = LONGDN;
      }
      if (close[pos] < LONGDN1[pos] && LONGDN1[pos - 1] != EMPTY_VALUE)
      {
         entry_buy[pos] = MathMin(LONGDN, LONGDN1[pos - 1]);
      }
      else
      {
         entry_buy[pos] = LONGDN;
      }
      if (close[pos] > LONGUP1[pos] && LONGUP1[pos - 1] != EMPTY_VALUE)
      {
         exit_buy[pos] = MathMax(LONGUP, LONGUP1[pos - 1]);
      }
      else
      {
         exit_buy[pos] = LONGUP;
      }
      if (close[pos] < short_src && TRAILINGDOWN[pos - 1] != EMPTY_VALUE)
      {
         double Dn1 = close[pos] + Factor1 * atrValue[0];
         TRAILINGDOWN[pos] = MathMax(Dn1, TRAILINGDOWN[pos - 1]);
      }
      else
      {
         TRAILINGDOWN[pos] = short_src;
      }
      double SHORTUPX = MathMin(TRAILINGDOWN[pos], short_src);
      double SHORTUP = MathMin(SHORTUPX, Up2);
      if (close[pos] > SHORTUP1[pos - 1] && SHORTUP1[pos - 1] != EMPTY_VALUE)
      {
         SHORTUP1[pos] = MathMax(SHORTUP, SHORTUP1[pos - 1]);
      }
      else
      {
         SHORTUP1[pos] = SHORTUP;
      }
      double SHORTDNX = MathMin(TRAILINGDOWN[pos], short_src);
      double SHORTDN = MathMax(SHORTDNX, Dn2);
      if (close[pos] < SHORTDN1[pos - 1] && SHORTDN1[pos - 1] != EMPTY_VALUE)
      {
         SHORTDN1[pos] = MathMin(SHORTDN, SHORTDN1[pos - 1]);
      }
      else
      {
         SHORTDN1[pos] = SHORTDN;
      }
      if (close[pos] > SHORTUP1[pos] && SHORTUP1[pos - 1] != EMPTY_VALUE)
      {
         entry_sell[pos] = MathMax(SHORTUP, SHORTUP1[pos - 1]);
      }
      else
      {
         entry_sell[pos] = SHORTUP;
      }
      if (close[pos] < SHORTDN1[pos] && SHORTDN1[pos - 1] != EMPTY_VALUE)
      {
         exit_sell[pos] = MathMin(SHORTUP, SHORTDN1[pos - 1]);
      }
      else
      {
         exit_sell[pos] = SHORTDN;
      }
   }
   return rates_total;
}