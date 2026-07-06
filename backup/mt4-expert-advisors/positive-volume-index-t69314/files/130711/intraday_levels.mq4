// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69314&p=130711#p130711

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

input string start_time = "020000"; // Start time in hhmmss format
input string stop_time = "015959"; // Stop time in hhmmss format
input color price_line_color = Blue; // Price line color
input int price_line_width = 1; // Price line width
input ENUM_LINE_STYLE price_line_style = STYLE_SOLID; // Price line style

input color sup_line_color = Green; // Support line color
input int sup_line_width = 1; // Support line width
input ENUM_LINE_STYLE sup_line_style = STYLE_SOLID; // Support line style

input color res_line_color = Red; // Resistance line color
input int res_line_width = 1; // Resistance line width
input ENUM_LINE_STYLE res_line_style = STYLE_SOLID; // Resistance line style

// Trading time v.1.5

#ifndef DayOfWeek_IMP
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
#define DayOfWeek_IMP
#endif

#ifndef TradingTime_IMP
#define TradingTime_IMP

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
         start += 86400;
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
#endif

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

TradingTime* tradingTime;

int init()
{
   IndicatorName = GenerateIndicatorName("Time price level");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   tradingTime = new TradingTime();
   string error;
   if (!tradingTime.Init(start_time, stop_time, error))
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
   delete tradingTime;
   tradingTime = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void DrawLevel(double price, datetime dt, string name, color clr, int width, ENUM_LINE_STYLE style)
{
   string trendId = IndicatorObjPrefix + name;
   datetime s, e;
   tradingTime.GetStartEndTime(dt, s, e);
   ResetLastError();
   if (ObjectFind(0, trendId) == -1)
   {
      ObjectCreate(0, trendId, OBJ_TREND, 0, s, price, e, price);
      ObjectSetInteger(0, trendId, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, trendId, OBJPROP_STYLE, style);
      ObjectSetInteger(0, trendId, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, trendId, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, trendId, OBJPROP_PRICE1, price);
   ObjectSetDouble(0, trendId, OBJPROP_PRICE2, price);
   ObjectSetInteger(0, trendId, OBJPROP_TIME1, s);
   ObjectSetInteger(0, trendId, OBJPROP_TIME2, e);

   ResetLastError();
   string text_id = trendId + "Text";
   if (ObjectFind(0, text_id) == -1)
   {
      if (!ObjectCreate(0, text_id, OBJ_TEXT, 0, e, price))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetString(0, text_id, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, text_id, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, text_id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, text_id, OBJPROP_ANCHOR, ANCHOR_LOWER);
   }
   ObjectSetInteger(0, text_id, OBJPROP_TIME, e);
   ObjectSetDouble(0, text_id, OBJPROP_PRICE1, price);
   ObjectSetString(0, text_id, OBJPROP_TEXT, name);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 2;
   for (int pos = limit; pos >= 0; --pos)
   {
      datetime s1, e1;
      tradingTime.GetStartEndTime(Time[pos], s1, e1);
      datetime s2, e2;
      tradingTime.GetStartEndTime(Time[pos + 1], s2, e2);
      if (s1 != s2)
      {
         DrawLevel(Open[pos], Time[pos], "P", price_line_color, price_line_width, price_line_style);
         DrawLevel(Open[pos] / 1.00236, Time[pos], "S1", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] / 1.00382, Time[pos], "S2", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] / 1.005, Time[pos], "S3", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] / 1.00618, Time[pos], "S4", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] / 1.00762, Time[pos], "S5", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] / 1.01, Time[pos], "S6", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] / 1.01236, Time[pos], "S7", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] / 1.01382, Time[pos], "S8", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] / 1.015, Time[pos], "S9", sup_line_color, sup_line_width, sup_line_style);
         DrawLevel(Open[pos] * 1.00236, Time[pos], "R1", res_line_color, res_line_width, res_line_style);
         DrawLevel(Open[pos] * 1.00382, Time[pos], "R2", res_line_color, res_line_width, res_line_style);
         DrawLevel(Open[pos] * 1.005, Time[pos], "R3", res_line_color, res_line_width, res_line_style);
         DrawLevel(Open[pos] * 1.00618, Time[pos], "R4", res_line_color, res_line_width, res_line_style);
         DrawLevel(Open[pos] * 1.00762, Time[pos], "R5", res_line_color, res_line_width, res_line_style);
         DrawLevel(Open[pos] * 1.01, Time[pos], "R6", res_line_color, res_line_width, res_line_style);
         DrawLevel(Open[pos] * 1.01236, Time[pos], "R7", res_line_color, res_line_width, res_line_style);
         DrawLevel(Open[pos] * 1.01382, Time[pos], "R8", res_line_color, res_line_width, res_line_style);
         DrawLevel(Open[pos] * 1.015, Time[pos], "R9", res_line_color, res_line_width, res_line_style);
      }
   } 
   return 0;
}
