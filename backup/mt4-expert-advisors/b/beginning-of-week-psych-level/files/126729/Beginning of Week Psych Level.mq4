// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68538

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_chart_window

string IndicatorName;
string IndicatorObjPrefix;

enum DayOfWeek
{
   DayOfWeekSunday = 0, // Sunday
   DayOfWeekMonday = 1, // Monday
   DayOfWeekTuesday = 2, // Tuesday
   DayOfWeekWednesday = 3, // Wednesday
   DayOfWeekThursday = 4, // Thursday
   DayOfWeekFriday = 5, // Friday
   DayOfWeekSaturday = 6 // Saturday
};

input string start_time = "000000"; // Start time in hhmmss format
input string stop_time = "000000"; // Stop time in hhmmss format
input DayOfWeek day = DayOfWeekMonday; // Day of week
input color high_color = Red; // High line color
input int high_width = 1; // High line style
input ENUM_LINE_STYLE high_style = STYLE_SOLID; // High line style
input color low_color = Green; // Low line color
input int low_width = 1; // Low line style
input ENUM_LINE_STYLE low_style = STYLE_SOLID; // Low line style
input bool extend_line = false; // Extend lines

// Trading time v.1.5
class TradingTime
{
   int _startTime;
   int _endTime;
   bool _useWeekTime;
   int _weekStartTime;
   int _weekStartDay;
   int _weekStopTime;
   int _weekStopDay;
public:
   TradingTime()
   {
      _startTime = 0;
      _endTime = 0;
      _useWeekTime = false;
   }

   bool SetWeekTradingTime(const DayOfWeek startDay, const string startTime, const DayOfWeek stopDay, 
      const string stopTime, string &error)
   {
      _useWeekTime = true;
      _weekStartTime = ParseTime(startTime, error);
      if (_weekStartTime == -1)
         return false;
      _weekStopTime = ParseTime(stopTime, error);
      if (_weekStopTime == -1)
         return false;
      
      _weekStartDay = (int)startDay;
      _weekStopDay = (int)stopDay;
      return true;
   }

   bool Init(const string startTime, const string endTime, string &error)
   {
      _startTime = ParseTime(startTime, error);
      if (_startTime == -1)
         return false;
      _endTime = ParseTime(endTime, error);
      if (_endTime == -1)
         return false;

      return true;
   }

   bool IsTradingTime(datetime dt)
   {
      if (_startTime == _endTime && !_useWeekTime)
         return true;
      MqlDateTime current_time;
      if (!TimeToStruct(dt, current_time))
         return false;
      if (!IsIntradayTradingTime(current_time))
         return false;
      return IsWeeklyTradingTime(current_time);
   }

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
         start -= 86400;
      }
   }
private:
   bool IsIntradayTradingTime(const MqlDateTime &current_time)
   {
      if (_startTime == _endTime)
         return true;
      int current_t = TimeToInt(current_time);
      if (_startTime > _endTime)
         return current_t >= _startTime || current_t <= _endTime;
      return current_t >= _startTime && current_t <= _endTime;
   }

   int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }

   bool IsWeeklyTradingTime(const MqlDateTime &current_time)
   {
      if (!_useWeekTime)
         return true;
      if (current_time.day_of_week < _weekStartDay || current_time.day_of_week > _weekStopDay)
         return false;

      if (current_time.day_of_week == _weekStartDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t >= _weekStartTime;
      }
      if (current_time.day_of_week == _weekStopDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t < _weekStopTime;
      }

      return true;
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
};

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

TradingTime* tradingTime;

int init()
{
   IndicatorName = GenerateIndicatorName("Beginning of Week Psych Level");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   tradingTime = new TradingTime();
   string error;
   if (!tradingTime.Init(start_time, stop_time, error) 
      || !tradingTime.SetWeekTradingTime(day, start_time, day, stop_time, error))
   {
      Print(error);
      delete tradingTime;
      tradingTime = NULL;
      return INIT_FAILED;
   }

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

   delete tradingTime;
   tradingTime = NULL;
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   bool calculated = false;
   double rangeHigh = 0, rangeLow = 0;
   datetime startDate = 0;
   datetime stopDate = 0;
   for (int pos = 0; pos < Bars; ++pos)
   {
      if (tradingTime.IsTradingTime(Time[pos]))
      {
         if (!calculated)
         {
            stopDate = extend_line ? Time[0] : Time[pos];
            rangeHigh = High[pos];
            rangeLow = Low[pos];
            calculated = true;
         }
         else
         {
            rangeHigh = MathMax(rangeHigh, High[pos]);
            rangeLow = MathMin(rangeLow, Low[pos]);
         }
         startDate = Time[pos];
      }
      else if (calculated)
         break;
   }
   if (!calculated)
      return 0;

   ResetLastError();
   string highLine = IndicatorObjPrefix + "highValue";
   ObjectCreate(0, highLine, OBJ_TREND, 0, startDate, rangeHigh, stopDate, rangeHigh);
   ObjectSetInteger(0, highLine, OBJPROP_COLOR, high_color);
   ObjectSetInteger(0, highLine, OBJPROP_STYLE, high_style);
   ObjectSetInteger(0, highLine, OBJPROP_WIDTH, high_width);

   ResetLastError();
   string lowLine = IndicatorObjPrefix + "lowValue";
   ObjectCreate(0, lowLine, OBJ_TREND, 0, startDate, rangeLow, stopDate, rangeLow);
   ObjectSetInteger(0, lowLine, OBJPROP_COLOR, low_color);
   ObjectSetInteger(0, lowLine, OBJPROP_STYLE, low_style);
   ObjectSetInteger(0, lowLine, OBJPROP_WIDTH, low_width);
   return 0;
}