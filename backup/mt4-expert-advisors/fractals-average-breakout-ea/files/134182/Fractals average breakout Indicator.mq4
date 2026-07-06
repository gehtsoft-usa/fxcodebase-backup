// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69899
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69899

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
#property version   "1.1"

#property strict
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

string IndicatorObjPrefix;

input int Loopback = 5; // Loopback

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

double h[], l[], m[];
double hh[10], ll[10];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("fab");
   IndicatorShortName("Fractals average breakout");

   if (Loopback > 10)
   {
      Print("Max allowed loopback is 10");
      return INIT_FAILED;
   }

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, h);
   SetIndexLabel(0, "High");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, m);
   SetIndexLabel(1, "Middle");
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, l);
   SetIndexLabel(2, "Low");

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
      ArrayInitialize(h, EMPTY_VALUE);
      ArrayInitialize(l, EMPTY_VALUE);
      ArrayInitialize(m, EMPTY_VALUE);
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

   int toSkip = 5;
   for (int pos = rates_total - 1 - toSkip; pos >= 1; --pos)
   {
      int th = high[pos + 2] > high[pos + 1] && high[pos + 2] > high[pos] && high[pos + 2] > high[pos + 3] && high[pos + 2] > high[pos + 4] ? -1 : 0;
      int bl = low[pos + 2] < low[pos + 1] && low[pos + 2] < low[pos] && low[pos + 2] < low[pos + 3] && low[pos + 2] < low[pos + 4] ? 1 : 0;
      int tot = th + bl;
      int pl = MathAbs(tot) >= 1 ? 1 : 0;
      if (tot == 1)
      {
         for (int i = Loopback - 1; i > 0; --i)
         {
            ll[i] = ll[i - 1];
         }
         ll[0] = low[pos + 2];
      }
      else if (tot == -1)
      {
         for (int i = Loopback - 1; i > 0; --i)
         {
            hh[i] = hh[i - 1];
         }
         hh[0] = high[pos + 2];
      }
      l[pos] = 0;
      h[pos] = 0;
      for (int i = 0; i < Loopback; ++i)
      {
         l[pos] += ll[i];
         h[pos] += hh[i];
      }
      l[pos] /= Loopback;
      h[pos] /= Loopback;
      m[pos] = (h[pos] + l[pos]) / 2;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
