// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70536

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
//#property indicator_separate_window
#property indicator_buffers 9
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Black
#property indicator_color4 Lime
#property indicator_color5 Red
#property indicator_color6 Lime
#property indicator_color7 Red
#property indicator_color8 Lime
#property indicator_color9 Red

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input double multiplier = 1; // Range Multiplier
input int bars_limit = 100000; // Bars limit

string IndicatorObjPrefix;
double d_open[];
double d_high[];
double d_low[];
double d_open_buy[];
double d_open_sel[];
double d_high_buy[];
double d_high_sel[];
double d_low_buy[];
double d_low_sel[];

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

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("mtfcatrshl");
   IndicatorShortName("MTF CATR Stop Hunt Levels");

   IndicatorBuffers(9);

   double temp = iCustom(NULL, 0, "Cum_TR", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Cum_TR' indicator");
      return INIT_FAILED;
   }
   int id = 0;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_open);
   SetIndexLabel(id, "Open");
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_high);
   SetIndexLabel(id, "High");
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_low);
   SetIndexLabel(id, "Low");
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_open_buy);
   SetIndexLabel(id, "Open Buy");
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_open_sel);
   SetIndexLabel(id, "Open Sell");
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_high_buy);
   SetIndexLabel(id, "High Buy");
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_high_sel);
   SetIndexLabel(id, "High Sell");
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_low_buy);
   SetIndexLabel(id, "Low Buy");
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, d_low_sel);
   SetIndexLabel(id, "Low Sell");
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
      ArrayInitialize(d_open, 0);
      ArrayInitialize(d_high, 0);
      ArrayInitialize(d_low, 0);
      ArrayInitialize(d_open_buy, 0);
      ArrayInitialize(d_open_sel, 0);
      ArrayInitialize(d_high_buy, 0);
      ArrayInitialize(d_high_sel, 0);
      ArrayInitialize(d_low_buy, 0);
      ArrayInitialize(d_low_sel, 0);
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
      int index = iBarShift(_Symbol, tf, time[pos]);
      if (index < 0)
      {
         continue;
      }
      double cum_tr = iCustom(_Symbol, tf, "Cum_TR", 0, index);
      double n = iBars(_Symbol, tf) - 1 - index;
      double catr = cum_tr / (n + 1);
      d_open[pos] = catr == 0 ? 0 : MathRound(iClose(_Symbol, tf, index) / catr) * catr;
      d_high[pos] = catr == 0 ? 0 : MathRound(1 + iClose(_Symbol, tf, index) / catr) * catr;
      d_low[pos] = catr == 0 ? 0 : MathRound(iClose(_Symbol, tf, index) / catr - 1) * catr;

      d_open_buy[pos] = d_open[pos] + catr * multiplier;
      d_open_sel[pos] = d_open[pos] - catr * multiplier;
      d_high_buy[pos] = d_high[pos] + catr * multiplier;
      d_high_sel[pos] = d_high[pos] - catr * multiplier;
      d_low_buy[pos] = d_low[pos] + catr * multiplier;
      d_low_sel[pos] = d_low[pos] - catr * multiplier;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
