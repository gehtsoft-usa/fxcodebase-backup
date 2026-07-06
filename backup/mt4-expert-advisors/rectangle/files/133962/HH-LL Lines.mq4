// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69712

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
input int bars_length = 10; // Line length
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
   IndicatorName = GenerateIndicatorName("HH-LL Lines");
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
   int i = 0;
   MqlDateTime current_time;
   if (!TimeToStruct(Time[i], current_time))
      return 0;

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
      return 0;
   }
   int from = index - bars + 1;
   int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, MathMin(bars, bars + from), MathMax(0, from));
   double highest = iHigh(_Symbol, _Period, highestIndex);
   int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, MathMin(bars, bars + from), MathMax(0, from));
   double lowest = iLow(_Symbol, _Period, lowestIndex);
   ResetLastError();
   string hid = IndicatorObjPrefix + "h";
   if (ObjectFind(0, hid) == -1)
   {
      if (!ObjectCreate(0, hid, OBJ_TREND, 0, reference, highest, Time[MathMax(0, index - bars_length)], highest))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetInteger(0, hid, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, hid, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, hid, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, hid, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, hid, OBJPROP_PRICE1, highest);
   ObjectSetDouble(0, hid, OBJPROP_PRICE2, highest);
   ObjectSetInteger(0, hid, OBJPROP_TIME1, reference);
   ObjectSetInteger(0, hid, OBJPROP_TIME2, Time[MathMax(0, index - bars_length)]);
   ResetLastError();
   string lhid = IndicatorObjPrefix + "hl";
   if (ObjectFind(0, lhid) == -1)
   {
      if (!ObjectCreate(0, lhid, OBJ_TEXT, 0, Time[MathMax(0, index - bars_length)], highest))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetString(0, lhid, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, lhid, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, lhid, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, lhid, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   }
   ObjectSetInteger(0, lhid, OBJPROP_TIME, Time[MathMax(0, index - bars_length)]);
   ObjectSetDouble(0, lhid, OBJPROP_PRICE1, highest);
   ObjectSetString(0, lhid, OBJPROP_TEXT, DoubleToString(highest, _Digits));

   ResetLastError();
   string lid = IndicatorObjPrefix + "l";
   if (ObjectFind(0, lid) == -1)
   {
      if (!ObjectCreate(0, lid, OBJ_TREND, 0, reference, lowest, Time[MathMax(0, index - bars_length)], lowest))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetInteger(0, lid, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, lid, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, lid, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, lid, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, lid, OBJPROP_PRICE1, lowest);
   ObjectSetDouble(0, lid, OBJPROP_PRICE2, lowest);
   ObjectSetInteger(0, lid, OBJPROP_TIME1, reference);
   ObjectSetInteger(0, lid, OBJPROP_TIME2, Time[MathMax(0, index - bars_length)]);

   ResetLastError();
   string llid = IndicatorObjPrefix + "ll";
   if (ObjectFind(0, llid) == -1)
   {
      if (!ObjectCreate(0, llid, OBJ_TEXT, 0, Time[MathMax(0, index - bars_length)], lowest))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetString(0, llid, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, llid, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, llid, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, llid, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   }
   ObjectSetInteger(0, llid, OBJPROP_TIME, Time[MathMax(0, index - bars_length)]);
   ObjectSetDouble(0, llid, OBJPROP_PRICE1, lowest);
   ObjectSetString(0, llid, OBJPROP_TEXT, DoubleToString(lowest, _Digits));

   return 0;
}
