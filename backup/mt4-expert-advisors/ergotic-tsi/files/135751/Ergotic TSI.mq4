// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70143

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

input int r = 4;
input int s = 8;
input int u = 6;
input int SmthLen = 3;
input int bars_limit = 1000; // Bars limit

#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

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

double xTSI[], xEMA_TSI[], close1[], close2[], close1e1[], close2e1[], close1e2[], close2e2[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("etsi");
   IndicatorShortName("Ergotic TSI");

   IndicatorBuffers(8);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, xTSI);
   SetIndexLabel(0, "Ergotic TSI");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, xEMA_TSI);
   SetIndexLabel(1, "SigLin");

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, close1);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, close2);

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, close1e1);

   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, close1e2);

   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, close2e1);

   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, close2e2);

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
      ArrayInitialize(xTSI, EMPTY_VALUE);
      ArrayInitialize(xEMA_TSI, EMPTY_VALUE);
      ArrayInitialize(close1, EMPTY_VALUE);
      ArrayInitialize(close2, EMPTY_VALUE);
      ArrayInitialize(close1e1, EMPTY_VALUE);
      ArrayInitialize(close1e2, EMPTY_VALUE);
      ArrayInitialize(close2e1, EMPTY_VALUE);
      ArrayInitialize(close2e2, EMPTY_VALUE);
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
      close1[pos] = close[pos] - close[pos + 1];
      close2[pos] = MathAbs(close[pos] - close[pos + 1]);
      close1e1[pos] = iMAOnArray(close1, 0, r, 0, MODE_EMA, pos);
      close1e2[pos] = iMAOnArray(close1e1, 0, s, 0, MODE_EMA, pos);
      double xSMA_R = iMAOnArray(close1e2, 0, u, 0, MODE_EMA, pos);
      close2e1[pos] = iMAOnArray(close2, 0, r, 0, MODE_EMA, pos);
      close2e2[pos] = iMAOnArray(close2e1, 0, s, 0, MODE_EMA, pos);
      double xSMA_aR = iMAOnArray(close2e2, 0, u, 0, MODE_EMA, pos);
      double Val1 = 100 * xSMA_R;
      double Val2 = xSMA_aR;
      xTSI[pos] = Val2 != 0 ? Val1 / Val2 : 0;
      xEMA_TSI[pos] = iMAOnArray(xTSI, 0, SmthLen, 0, MODE_EMA, pos);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
