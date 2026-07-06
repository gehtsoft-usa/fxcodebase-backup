// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69712
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69712

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

input string start_time = "000000"; // Start time
input int bars = 10; // Bars
input color clr = Red; // Color

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

#property indicator_chart_window
#property indicator_buffers 0

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

int startTime;

int init()
{
   IndicatorName = GenerateIndicatorName("Rectangle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   string error;
   startTime = ParseTime(start_time, error);
   if (startTime < 0)
   {
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(Time[i], current_time))
         continue;

      current_time.hour = 0;
      current_time.min = 0;
      current_time.sec = 0;
      datetime reference = StructToTime(current_time) + startTime;
      if (reference > Time[i])
      {
         reference -= 86400;
      }
      int index = iBarShift(_Symbol, _Period, reference);
      if (index < 0)
      {
         continue;
      }
      int from = index - bars + 1;
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, MathMin(bars, bars + from), MathMax(0, from));
      double highest = iHigh(_Symbol, _Period, highestIndex);
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, MathMin(bars, bars + from), MathMax(0, from));
      double lowest = iLow(_Symbol, _Period, lowestIndex);
      ResetLastError();
      string id = IndicatorObjPrefix + TimeToString(reference);
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_RECTANGLE, 0, reference, highest, Time[MathMax(0, from)], lowest))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            continue;
         }
         ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, id, OBJPROP_FILL, true);
      }
      ObjectSetDouble(0, id, OBJPROP_PRICE1, highest);
      ObjectSetDouble(0, id, OBJPROP_PRICE2, lowest);
      ObjectSetInteger(0, id, OBJPROP_TIME1, reference);
      ObjectSetInteger(0, id, OBJPROP_TIME2, Time[MathMax(0, from)]);
   }
   return 0;
}
