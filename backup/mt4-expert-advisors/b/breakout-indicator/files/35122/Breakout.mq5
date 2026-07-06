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
#property indicator_buffers 3
#property indicator_plots 3

input string PeriodBegin = "00:00:00";
input string PeriodEnd = "05:00:00";

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

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

double up[], down[];
int _startTime, _endTime;

void OnInit()
{
   string error;
   _startTime = ParseTime(PeriodBegin, error);
   if (_startTime < 0)
   {
      Print(error);
      return;
   }
   _endTime = ParseTime(PeriodEnd, error);
   if (_endTime < 0)
   {
      Print(error);
      return;
   }
   IndicatorName = GenerateIndicatorName("Breakout");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, up, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, Green);
   PlotIndexSetString(0, PLOT_LABEL, "Up");

   SetIndexBuffer(1, down, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, Red);
   PlotIndexSetString(1, PLOT_LABEL, "Down");
}

bool GetStartEndTime(const datetime date, datetime &start, datetime &end)
{
   MqlDateTime current_time;
   if (!TimeToStruct(date, current_time))
   {
      return false;
   }

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
   return true;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
      ArrayInitialize(up, EMPTY_VALUE);
      ArrayInitialize(down, EMPTY_VALUE);
   }
   for (int pos = MathMax(0, prev_calculated); pos < rates_total; ++pos)
   {
      datetime s, e;
      if (GetStartEndTime(time[pos], s, e))
      {
         int start_index = iBarShift(_Symbol, _Period, s);
         int end_index = iBarShift(_Symbol, _Period, e);
         if (start_index >= 0)
         {
            if (start_index == end_index)
            {
               up[pos] = iHigh(_Symbol, _Period, 0);
               down[pos] = iLow(_Symbol, _Period, 0);
            }
            else
            {
               int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, start_index - end_index, end_index);
               up[pos] = iHigh(_Symbol, _Period, highestIndex);
               int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, start_index - end_index, end_index);
               down[pos] = iLow(_Symbol, _Period, lowestIndex);
            }
         }
      }
   }
   return rates_total;
}