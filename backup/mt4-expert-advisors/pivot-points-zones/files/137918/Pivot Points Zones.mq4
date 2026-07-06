// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70486

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
#property indicator_buffers 0

input ENUM_TIMEFRAMES tf = PERIOD_D1; // Pivot timeframe
input int bars_limit = 100000; // Bars limit
input color p_s1_color = Red; // P-S1 Color
input color p_r1_color = Red; // P-R1 Color
input color s1_s2_color = Yellow; // S1-S2 Color
input color r1_r2_color = Yellow; // R1-R2 Color
input color s2_s3_color = Green; // S2-S3 Color
input color r2_r3_color = Green; // R2-R3 Color

class Pivot
{
   ENUM_TIMEFRAMES _timeframe;
   ENUM_TIMEFRAMES _chartTimeframe;
   string _symbol;
public:
   Pivot(string symbol, ENUM_TIMEFRAMES timeframe, ENUM_TIMEFRAMES chartTimeframe)
   {
      _chartTimeframe = chartTimeframe;
      _symbol = symbol;
      _timeframe = timeframe;
   }

   bool Get(const int i, double &p, double &s1, double &s2, double &s3, double &r1, double &r2, double &r3)
   {
      int btf_i = i == 0 ? 0 : iBarShift(_symbol, _timeframe, iTime(NULL, _chartTimeframe, i));
      if (btf_i == -1)
      {
         return false;
      }
      if (!CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3))
      {
         return false;
      }
      return true;
   }
private:
   bool CalcPivot(const int i, double &p, 
      double &s1, double &s2, double &s3,
      double &r1, double &r2, double &r3)
   {
      ResetLastError();
      double high  = iHigh(_symbol, _timeframe, i+1);
      int error = GetLastError();
      switch (error)
      {
         case ERR_HISTORY_WILL_UPDATED:
         case ERR_NO_HISTORY_DATA:
            {
               static bool ERR_HISTORY_NOT_FOUND_printed = false;
               if (!ERR_HISTORY_NOT_FOUND_printed)
               {
                  Print("No history");
                  ERR_HISTORY_NOT_FOUND_printed = true;
               }
            }
            return false;
      }
      double low   = iLow(_symbol, _timeframe, i+1);
      double open  = iOpen(_symbol, _timeframe, i+1);
      double close = iClose(_symbol, _timeframe, i+1);
      p = (high + low + close) / 3;
      r1 = (2 * p) - low;
      s1 = (2 * p) - high;
      r2 = p + (high - low);
      s2 = p - (high - low);
      r3 = p + (high - low) * 2;
      s3 = p - (high - low) * 2;
      return true;
   }
};

Pivot* pivot;

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
   IndicatorObjPrefix = GenerateIndicatorPrefix("ppz");
   IndicatorShortName("Pivot Points Zones");

   pivot = new Pivot(_Symbol, tf, (ENUM_TIMEFRAMES)_Period);

   return INIT_SUCCEEDED;
}

int deinit()
{
   delete pivot;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void CreateRect(string id, double price1, datetime time1, double price2, datetime time2, color clr)
{
   ResetLastError();
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_RECTANGLE, 0, time1, price1, time2, price2))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_FILL, true);
      ObjectSetInteger(0, id, OBJPROP_BACK, true);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, price1);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, price2);
   ObjectSetInteger(0, id, OBJPROP_TIME1, time1);
   ObjectSetInteger(0, id, OBJPROP_TIME2, time2);
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

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double p, s1, s2, s3, r1, r2, r3;
      if (pivot.Get(pos, p, s1, s2, s3, r1, r2, r3))
      {
         int index = pos == 0 ? 0 : iBarShift(_Symbol, tf, time[pos]);
         if (index < 0)
         {
            continue;
         }
         datetime time1 = iTime(_Symbol, tf, index);
         CreateRect(IndicatorObjPrefix + TimeToString(time1) + "ps1", p, time1, s1, time[pos], p_s1_color);
         CreateRect(IndicatorObjPrefix + TimeToString(time1) + "s12", s1, time1, s2, time[pos], s1_s2_color);
         CreateRect(IndicatorObjPrefix + TimeToString(time1) + "s23", s2, time1, s3, time[pos], s2_s3_color);
         CreateRect(IndicatorObjPrefix + TimeToString(time1) + "pr1", p, time1, r1, time[pos], p_r1_color);
         CreateRect(IndicatorObjPrefix + TimeToString(time1) + "r12", r1, time1, r2, time[pos], r1_r2_color);
         CreateRect(IndicatorObjPrefix + TimeToString(time1) + "r23", r2, time1, r3, time[pos], r2_r3_color);
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
