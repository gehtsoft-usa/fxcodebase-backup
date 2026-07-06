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
#property indicator_buffers 2
#property indicator_color1 Red

input string start = "08:00:00"; // Session start
input string end = "16:00:00"; // Session end

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

int TimeToInt(const MqlDateTime &current_time)
{
   return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
}

int ParseTime(const string time, string &error)
{
   string items[];
   StringSplit(time, ':', items);
   int hours;
   int minutes;
   int seconds;
   if (ArraySize(items) > 1)
   {
      if (ArraySize(items) != 3)
      {
         error = "Bad format for " + time;
         return -1;
      }
      //hh:mm:ss
      seconds = (int)StringToInteger(items[2]);
      minutes = (int)StringToInteger(items[1]);
      hours = (int)StringToInteger(items[0]);
   }
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
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

double out[], h[], l[], startMark[];
int _startTime, _endTime;

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("tsr");
   IndicatorShortName("Trade Session Range");

   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "Range");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, startMark);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, h);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, l);
   string error;
   _startTime = ParseTime(start, error);
   if (_startTime == -1)
   {
      Print(error);
      return INIT_FAILED;
   }
   _endTime = ParseTime(end, error);
   if (_endTime == -1)
   {
      Print(error);
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

bool IsIntradayTradingTime(const MqlDateTime &current_time)
{
   if (_startTime == _endTime)
      return true;
   int current_t = TimeToInt(current_time);
   if (_startTime > _endTime)
      return current_t >= _startTime || current_t <= _endTime;
   return current_t >= _startTime && current_t <= _endTime;
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
      ArrayInitialize(h, EMPTY_VALUE);
      ArrayInitialize(l, EMPTY_VALUE);
      ArrayInitialize(startMark, EMPTY_VALUE);
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

   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;

   int toSkip = 1;
   for (int pos = rates_total - 1 - toSkip; pos >= 0; --pos)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(time[pos], current_time))
      {
         continue;
      }
      if (!IsIntradayTradingTime(current_time))
      {
         out[pos] = out[pos + 1];
         h[pos] = EMPTY_VALUE;
         l[pos] = EMPTY_VALUE;
         continue;
      }
      if (h[pos + 1] == EMPTY_VALUE)
      {
         h[pos] = high[pos];
         l[pos] = low[pos];
         out[pos] = (h[pos] - l[pos]) / pipSize;
         startMark[pos] = 1;
         continue;
      }
      h[pos] = MathMax(h[pos + 1], high[pos]);
      l[pos] = MathMin(l[pos + 1], low[pos]);
      out[pos] = (h[pos] - l[pos]) / pipSize;
      startMark[pos] = EMPTY_VALUE;
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return 0;
}
