// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70643

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

input int _TF = 0;
input int G_period_80 = 12;
input int G_period_84 = 12;
input int G_period_88 = 7;

#property strict

#property indicator_separate_window
#property indicator_buffers 13
#property indicator_plots 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Ivory

input int bars_limit = 10000; // Bars limit

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

double G_ibuf_180[], G_ibuf_184[], G_ibuf_188[], G_ibuf_192[], G_ibuf_196[], G_ibuf_200[], G_ibuf_204[], Gda_208[], Gda_212[], Gda_216[], Gda_220[], Gda_224[], Gda_228[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("GadiTV");
   IndicatorSetString(INDICATOR_SHORTNAME, "Gadi TickVolume");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, G_ibuf_180, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, G_ibuf_184, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, G_ibuf_188, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, G_ibuf_192, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, G_ibuf_196, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id++, G_ibuf_200, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, G_ibuf_204, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Gda_208, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Gda_212, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Gda_216, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Gda_220, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Gda_224, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, Gda_228, INDICATOR_CALCULATIONS);
}

void OnDeinit(const int reason)
{
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
      ArrayInitialize(G_ibuf_180, EMPTY_VALUE);
      ArrayInitialize(G_ibuf_184, EMPTY_VALUE);
      ArrayInitialize(G_ibuf_188, EMPTY_VALUE);
      ArrayInitialize(G_ibuf_192, EMPTY_VALUE);
      ArrayInitialize(G_ibuf_196, EMPTY_VALUE);
      ArrayInitialize(G_ibuf_200, EMPTY_VALUE);
      ArrayInitialize(G_ibuf_204, EMPTY_VALUE);
      ArrayInitialize(Gda_208, EMPTY_VALUE);
      ArrayInitialize(Gda_212, EMPTY_VALUE);
      ArrayInitialize(Gda_216, EMPTY_VALUE);
      ArrayInitialize(Gda_220, EMPTY_VALUE);
      ArrayInitialize(Gda_224, EMPTY_VALUE);
      ArrayInitialize(Gda_228, EMPTY_VALUE);
   }
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digit = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int mult = digit == 3 || digit == 5 ? 10 : 1;
   double pipSize = point * mult;
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      Gda_208[pos] = (tick_volume[pos] + (close[pos] - open[pos]) / pipSize) / 2.0;
      Gda_212[pos] = tick_volume[pos] - Gda_208[pos];
   }
   MAOnArray(rates_total, prev_calculated, G_period_80, MODE_EMA, G_period_80, Gda_208, Gda_216);
   MAOnArray(rates_total, prev_calculated, G_period_80, MODE_EMA, G_period_80, Gda_212, Gda_220);
   MAOnArray(rates_total, prev_calculated, G_period_80 + G_period_84, MODE_EMA, G_period_84, Gda_216, Gda_224);
   MAOnArray(rates_total, prev_calculated, G_period_80 + G_period_84, MODE_EMA, G_period_84, Gda_220, Gda_228);
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax( G_period_80 + G_period_84, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      if (Gda_224[pos] + Gda_228[pos] != 0)
      {
         G_ibuf_200[pos] = 100.0 * (Gda_224[pos] - Gda_228[pos]) / (Gda_224[pos] + Gda_228[pos]);
      }
   }
   MAOnArray(rates_total, prev_calculated,  G_period_80 + G_period_84 + G_period_88, MODE_EMA, G_period_88, G_ibuf_200, G_ibuf_196);
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(1, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      G_ibuf_204[pos] = G_ibuf_204[pos - 1];
      if (G_ibuf_196[pos] > G_ibuf_196[pos - 1]) 
         G_ibuf_204[pos] = 1;
      else if (G_ibuf_196[pos] < G_ibuf_196[pos - 1])
         G_ibuf_204[pos] = -1;
      if (G_ibuf_204[pos] > 0.0) 
      {
         if (G_ibuf_196[pos] >= 0.0) 
         {
            G_ibuf_180[pos] = G_ibuf_196[pos];
            G_ibuf_184[pos] = EMPTY_VALUE;
            continue;
         }
         G_ibuf_188[pos] = G_ibuf_196[pos];
         G_ibuf_192[pos] = EMPTY_VALUE;
      } 
      else 
      {
         if (G_ibuf_204[pos] < 0.0) 
         {
            if (G_ibuf_196[pos] >= 0.0) 
            {
               G_ibuf_184[pos] = G_ibuf_196[pos];
               G_ibuf_180[pos] = EMPTY_VALUE;
               continue;
            }
            G_ibuf_192[pos] = G_ibuf_196[pos];
            G_ibuf_188[pos] = EMPTY_VALUE;
         }
      }
   }
   string Ls_12;
   if (G_ibuf_204[rates_total - 1] == 1.0) 
      Ls_12 = "UP Trend";
   else 
      Ls_12 = "DOWN Trend";
   string Ls_20 = " Buyers: " + DoubleToString(Gda_208[rates_total - 1], 0) + "";
   string Ls_28 = "Sellers: " + DoubleToString(Gda_212[rates_total - 1], 0) + "";
   double diff = Gda_208[rates_total - 1] - Gda_212[rates_total - 1];
   string diffLabel = DoubleToString(diff, 0);
   ObjectCreate(0, IndicatorObjPrefix + "Trend", OBJ_LABEL, ChartWindowFind(), 0, 0);
   if (G_ibuf_204[rates_total - 1] == 1.0) 
      ObjectSetText(IndicatorObjPrefix + "Trend", StringSubstr(Ls_12, 0), 12, "Tahoma", Green);
   else 
      ObjectSetText(IndicatorObjPrefix + "Trend", StringSubstr(Ls_12, 0), 12, "Tahoma", Red);
   ObjectSetInteger(0, IndicatorObjPrefix + "Trend", OBJPROP_CORNER, 1);
   ObjectSetInteger(0, IndicatorObjPrefix + "Trend", OBJPROP_XDISTANCE, 120);
   ObjectSetInteger(0, IndicatorObjPrefix + "Trend", OBJPROP_YDISTANCE, 36);

   ObjectCreate(0, IndicatorObjPrefix + "UpTicks2", OBJ_LABEL, ChartWindowFind(), 0, 0);
   ObjectSetText(IndicatorObjPrefix + "UpTicks2", StringSubstr(Ls_20, 0), 10, "Tahoma", Green);
   ObjectSetInteger(0, IndicatorObjPrefix + "UpTicks2", OBJPROP_CORNER, 1);
   ObjectSetInteger(0, IndicatorObjPrefix + "UpTicks2", OBJPROP_XDISTANCE, 120);
   ObjectSetInteger(0, IndicatorObjPrefix + "UpTicks2", OBJPROP_YDISTANCE, 60);

   ObjectCreate(0, IndicatorObjPrefix + "DownTicks2", OBJ_LABEL, ChartWindowFind(), 0, 0);
   ObjectSetText(IndicatorObjPrefix + "DownTicks2", StringSubstr(Ls_28, 0), 10, "Tahoma", Red);
   ObjectSetInteger(0, IndicatorObjPrefix + "DownTicks2", OBJPROP_CORNER, 1);
   ObjectSetInteger(0, IndicatorObjPrefix + "DownTicks2", OBJPROP_XDISTANCE, 120);
   ObjectSetInteger(0, IndicatorObjPrefix + "DownTicks2", OBJPROP_YDISTANCE, 90);
   
   ObjectCreate(0, IndicatorObjPrefix + "diff2", OBJ_LABEL, ChartWindowFind(), 0, 0);
   ObjectSetInteger(0, IndicatorObjPrefix + "diff2", OBJPROP_CORNER, 1);
   ObjectSetInteger(0, IndicatorObjPrefix + "diff2", OBJPROP_XDISTANCE, 120);
   ObjectSetInteger(0, IndicatorObjPrefix + "diff2", OBJPROP_YDISTANCE, 120);
   ObjectSetInteger(0, IndicatorObjPrefix + "diff2", OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, IndicatorObjPrefix + "diff2", OBJPROP_FONT, "Tahoma");
   ObjectSetInteger(0, IndicatorObjPrefix + "diff2", OBJPROP_COLOR, diff < 0 ? Red : Green);
   ObjectSetString(0, IndicatorObjPrefix + "diff2", OBJPROP_TEXT, "Diff: " + diffLabel);
   return rates_total;
}

void ObjectSetText(string id, string text, int fontSize, string font, color clr)
{
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
}