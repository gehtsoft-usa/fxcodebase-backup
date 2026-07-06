// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70136

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
#property indicator_buffers 1
#property indicator_color1 Red

enum Method
{
   Classical,
   Alternative1, // 1. Alternative
   Alternative2 // 2. Alternative
};

input Method type = Classical; // OBV Method

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

double out[];

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("aobv");
   IndicatorShortName("Alternative OBV");

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "AOBV");

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
      ArrayInitialize(out, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickvolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 1;
   for (int pos = rates_total - 1 - MathMax(prev_calculated, toSkip); pos >= 0; --pos)
   {
      switch (type)
      {
         case Classical:
            {
               double prev = out[pos + 1] == EMPTY_VALUE ? tick_volume[pos + 1] : out[pos + 1];
               if (close[pos] > close[pos + 1])
               {
                  out[pos] = out[pos + 1] + tick_volume[pos];
               }
               else if (close[pos] < close[pos + 1])
               {
                  out[pos] = out[pos + 1] - tick_volume[pos];
               }
               else
               {
                  out[pos] = out[pos + 1];
               }
            }
            break;
         case Alternative1:
            {
               if (high[pos] == low[pos] || open[pos] == close[pos] || close[pos] == close[pos + 1])
               {
                  out[pos] = out[pos + 1];
               }
               else
               {
                  if (close[pos] > open[pos])
                  {
                     out[pos] = out[pos + 1] + (tick_volume[pos] * (close[pos] - open[pos]) / (high[pos] - low[pos]));
                  }
                  else
                  {
                     out[pos] = out[pos + 1] - (tick_volume[pos] * (open[pos] - close[pos]) / (high[pos] - low[pos]));
                  }
               }
            }
            break;
         case Alternative2:
            {
               if (high[pos] == low[pos] || open[pos] == close[pos] || close[pos] == close[pos + 1])
               {
                  out[pos] = out[pos + 1];
               }
               else
               {
                  out[pos] = out[pos + 1] + (tick_volume[pos] * (high[pos] - open[pos]) / (high[pos] - low[pos])) -
                     (tick_volume[pos] * (open[pos] - low[pos]) / (high[pos] - low[pos]));
               }
            }
            break;
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickvolumeSeries);
   return 0;
}
