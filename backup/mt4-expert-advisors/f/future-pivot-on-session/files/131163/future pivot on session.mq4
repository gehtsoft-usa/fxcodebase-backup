// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69398

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
#property indicator_buffers 0

input color pClr = Blue; // P color
input color s1Clr = Green; // S1 color
input color s2Clr = Green; // S2 color
input color s3Clr = Green; // S3 color
input color r1Clr = Red; // R1 color
input color r2Clr = Red; // R2 color
input color r3Clr = Red; // R3 color
input string start_time = "03:30:00"; // Start time
input string stop_time = "10:00:00"; // Stop time
input ENUM_LINE_STYLE hist_style = STYLE_SOLID; // Historical line style
input ENUM_LINE_STYLE curr_style = STYLE_DASH; // Current line style

int ParseTime(const string time, string &error)
{
   int hours;
   int minutes;
   int seconds;
   if (StringFind(time, ":") == -1)
   {
      //hh:mm:ss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
   }
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      hours = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      seconds = time_parsed % 100;
   }
   if (hours > 24)
   {
      error = "Incorrect number of hours in " + time;
      return -1;
   }
   if (minutes > 59)
   {
      error = "Incorrect number of minutes in " + time;
      return -1;
   }
   if (seconds > 59)
   {
      error = "Incorrect number of seconds in " + time;
      return -1;
   }
   if (hours == 24 && (minutes != 0 || seconds != 0))
   {
      error = "Incorrect date";
      return -1;
   }
   return (hours * 60 + minutes) * 60 + seconds;
}

int _startTime, _endTime;

void GetStartEndTime(const datetime date, datetime &start, datetime &end)
{
   MqlDateTime current_time;
   if (!TimeToStruct(date, current_time))
      return;

   current_time.hour = 0;
   current_time.min = 0;
   current_time.sec = 0;
   datetime referece = StructToTime(current_time);

   start = referece + _startTime;
   end = referece + _endTime;
   if (_startTime > _endTime)
   {
      start += 86400;
   }
}

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
      if (!CalcPivot(i, p, s1, s2, s3, r1, r2, r3))
         return false;
      return true;
   }
private:
   bool CalcPivot(const int i, double &p, 
      double &s1, double &s2, double &s3,
      double &r1, double &r2, double &r3)
   {
      datetime s, e;
      GetStartEndTime(Time[i], s, e);
      int sIndex = iBarShift(_Symbol, PERIOD_M15, s);
      int eIndex = iBarShift(_Symbol, PERIOD_M15, e);
      if (sIndex < 0)
      {
         return false;
      }

      double open = iOpen(_Symbol, PERIOD_M15, sIndex);
      double close = iClose(_Symbol, PERIOD_M15, eIndex);
      int highestIndex = iHighest(_Symbol, PERIOD_M15, MODE_HIGH, sIndex - eIndex, eIndex);
      double high = iHigh(_Symbol, PERIOD_M15, highestIndex);
      int lowestIndex = iLowest(_Symbol, PERIOD_M15, MODE_LOW, sIndex - eIndex, eIndex);
      double low = iLow(_Symbol, PERIOD_M15, lowestIndex);
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

   string error;
   _startTime = ParseTime(start_time, error);
   if (_startTime == -1)
   {
      return INIT_FAILED;
   }
   _endTime = ParseTime(stop_time, error);
   if (_endTime == -1)
   {
      return INIT_FAILED;
   }

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

   ResetLastError();
   string lid = IndicatorObjPrefix + TimeToString(d1Time) + "l" + id;
   if (ObjectFind(0, lid) == -1)
   {
      if (!ObjectCreate(0, lid, OBJ_TEXT, 0, MathMin(d1Time + 86400, Time[0]), p))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetString(0, lid, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, lid, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, lid, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, lid, OBJPROP_ANCHOR, ANCHOR_LOWER);
   }
   ObjectSetInteger(0, lid, OBJPROP_TIME, MathMin(d1Time + 86400, Time[0]));
   ObjectSetDouble(0, lid, OBJPROP_PRICE1, p);
   ObjectSetString(0, lid, OBJPROP_TEXT, id);
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
      DrawLine(d1Time, p, "P", pClr, style);
      DrawLine(d1Time, s1, "S1", s1Clr, style);
      DrawLine(d1Time, s2, "S2", s2Clr, style);
      DrawLine(d1Time, s3, "S3", s3Clr, style);
      DrawLine(d1Time, r1, "R1", r1Clr, style);
      DrawLine(d1Time, r2, "R2", r2Clr, style);
      DrawLine(d1Time, r3, "R3", r3Clr, style);
   }
   return 0;
}
