// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70103

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

input int length = 10; // Length of lines, periods

#property strict
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

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

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("shl");
   IndicatorShortName("Swing High Low");

   IndicatorBuffers(1);

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

   int toSkip = 2;
   for (int pos = MathMax(2, rates_total - 1 - toSkip); pos >= 2; --pos)
   {
      bool swingHigh = true;
      bool swingLow = true;
      for (int i = 0; i < 2; ++i)
      {
         if (high[pos] < high[pos - i] || high[pos] < high[pos + i])
         {
            swingHigh = false;
         }
         if (low[pos] > low[pos - i] || low[pos] > low[pos + i])
         {
            swingLow = false;
         }
      }
      if (swingLow)
      {
         ResetLastError();
         string id = IndicatorObjPrefix + "l" + TimeToString(time[pos]);
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TREND, 0, time[pos], low[pos], (time[pos] + (time[pos - 2] - time[pos + 2]) / 5) * length, low[pos]))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               continue;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Red);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
         }
         ObjectSetDouble(0, id, OBJPROP_PRICE1, low[pos]);
         ObjectSetDouble(0, id, OBJPROP_PRICE2, low[pos]);
         ObjectSetInteger(0, id, OBJPROP_TIME1, time[pos]);
         ObjectSetInteger(0, id, OBJPROP_TIME2, time[pos] + ((time[pos - 2] - time[pos + 2]) / 5) * length);
      }
      if (swingHigh)
      {
         ResetLastError();
         string id = IndicatorObjPrefix + "h" + TimeToString(time[pos]);
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TREND, 0, time[pos], high[pos], (time[pos] + (time[pos - 2] - time[pos + 2]) / 5) * length, high[pos]))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               continue;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Green);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
         }
         ObjectSetDouble(0, id, OBJPROP_PRICE1, high[pos]);
         ObjectSetDouble(0, id, OBJPROP_PRICE2, high[pos]);
         ObjectSetInteger(0, id, OBJPROP_TIME1, time[pos]);
         ObjectSetInteger(0, id, OBJPROP_TIME2, time[pos] + ((time[pos - 2] - time[pos + 2]) / 5) * length);
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
