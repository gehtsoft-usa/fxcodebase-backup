// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69805

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 3

string IndicatorName;
string IndicatorObjPrefix;
input int per = 150; // Calculate for last bars

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

double f1[], f2[], f3[];
void OnInit()
{
   IndicatorName = GenerateIndicatorName("Fibonacci retracement lines");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id + 0, f1, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   id++;
   SetIndexBuffer(id + 0, f2, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   id++;
   SetIndexBuffer(id + 0, f3, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   id++;
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
      ArrayInitialize(f1, EMPTY_VALUE);
      ArrayInitialize(f2, EMPTY_VALUE);
      ArrayInitialize(f3, EMPTY_VALUE);
   }
   int first = per;
   for (int pos = MathMax(first, prev_calculated); pos < rates_total; ++pos)
   {
      int highIndex = iHighest(_Symbol, _Period, MODE_HIGH, per, rates_total - pos - 1);
      double hl = iHigh(_Symbol, _Period, highIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, per, rates_total - pos - 1);
      double ll = iLow(_Symbol, _Period, lowestIndex);
      double dist = hl - ll;
      f1[pos] = close[pos - per] > close[pos] ? hl : ll + dist;
      f2[pos] = close[pos - per] > close[pos] ? hl - dist * 0.5 : ll + dist * 0.5;
      f3[pos] = close[pos - per] > close[pos] ? hl - dist : ll;
   }
   return rates_total;
}