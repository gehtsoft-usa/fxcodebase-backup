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
#property indicator_buffers 0

input color pClr = Blue; // P color
input color s1Clr = Green; // S1 color
input color s2Clr = Green; // S2 color
input color s3Clr = Green; // S3 color
input color r1Clr = Red; // R1 color
input color r2Clr = Red; // R2 color
input color r3Clr = Red; // R3 color
input ENUM_LINE_STYLE hist_style = STYLE_SOLID; // Historical line style
input ENUM_LINE_STYLE curr_style = STYLE_DASH; // Current line style

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

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
      int btf_i = iBarShift(_symbol, _timeframe, iTime(NULL, _chartTimeframe, i));
      if (btf_i == -1)
         return false;
      if (!CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3))
         return false;
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

Pivot* _pivot;

int init()
{
   IndicatorName = GenerateIndicatorName("Future Pivot");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   _pivot = new Pivot(_Symbol, PERIOD_D1, (ENUM_TIMEFRAMES)_Period);

   return 0;
}

int deinit()
{
   delete _pivot;
   _pivot = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void DrawLine(datetime d1Time, double p, string id, color clr, ENUM_LINE_STYLE style)
{
   ResetLastError();
   string pid = IndicatorObjPrefix + TimeToString(d1Time) + id;
   if (ObjectFind(0, pid) == -1)
   {
      if (!ObjectCreate(0, pid, OBJ_TREND, 0, d1Time, p, d1Time + 86400, p))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return;
      }
      ObjectSetInteger(0, pid, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, pid, OBJPROP_STYLE, style);
      ObjectSetInteger(0, pid, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, pid, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, pid, OBJPROP_PRICE1, p);
   ObjectSetDouble(0, pid, OBJPROP_PRICE2, p);
   ObjectSetInteger(0, pid, OBJPROP_TIME1, d1Time);
   ObjectSetInteger(0, pid, OBJPROP_TIME2, d1Time + 86400);
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMin(Bars - 1 - 0, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double p, s1, s2, s3, r1, r2, r3;
      if (!_pivot.Get(i, p, s1, s2, s3, r1, r2, r3))
      {
         continue;
      }
      int index = i == 0 ? 0 : iBarShift(_Symbol, PERIOD_D1, Time[i]);
      if (index < 0)
      {
         continue;
      }
      datetime d1Time = iTime(_Symbol, PERIOD_D1, index);
      ENUM_LINE_STYLE style = index == 0 ? curr_style : hist_style;
      DrawLine(d1Time, p, "p", pClr, style);
      DrawLine(d1Time, s1, "s1", s1Clr, style);
      DrawLine(d1Time, s2, "s2", s2Clr, style);
      DrawLine(d1Time, s3, "s3", s3Clr, style);
      DrawLine(d1Time, r1, "r1", r1Clr, style);
      DrawLine(d1Time, r2, "r2", r2Clr, style);
      DrawLine(d1Time, r3, "r3", r3Clr, style);
   }
   return 0;
}
