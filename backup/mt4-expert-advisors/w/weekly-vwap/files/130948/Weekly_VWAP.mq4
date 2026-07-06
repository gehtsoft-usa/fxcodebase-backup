// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69355

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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 11
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Green
#property indicator_color8 Green
#property indicator_color9 Green
#property indicator_color10 Green
#property indicator_color11 Green

input double level1 = 1; // Level 1
input double level2 = 2; // Level 2
input double level3 = 3; // Level 3
input double level4 = 4; // Level 4
input double level5 = 5; // Level 5
input string StartTime = "00:00:00"; // Start Time for Trading
input string StopTime = "23:15:00"; // Stop Time for Trading
input int bars_limit = 1000; // Bars limit

string IndicatorName;
string IndicatorObjPrefix;
double VAMA[], up1[], up2[], up3[], up4[], up5[], down1[], down2[], down3[], down4[], down5[], PriceTimesVolume[];

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

int init()
{
   IndicatorName = GenerateIndicatorName("Weekly VWAP");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(12);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VAMA);
   SetIndexLabel(0, "VAMA");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, up1);
   SetIndexLabel(1, "UP1");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, up2);
   SetIndexLabel(2, "UP2");

   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, up3);
   SetIndexLabel(3, "UP3");

   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, up4);
   SetIndexLabel(4, "UP4");

   SetIndexStyle(5, DRAW_LINE);
   SetIndexBuffer(5, up5);
   SetIndexLabel(5, "UP5");

   SetIndexStyle(6, DRAW_LINE);
   SetIndexBuffer(6, down1);
   SetIndexLabel(6, "DOWN1");

   SetIndexStyle(7, DRAW_LINE);
   SetIndexBuffer(7, down2);
   SetIndexLabel(7, "DOWN2");

   SetIndexStyle(8, DRAW_LINE);
   SetIndexBuffer(8, down3);
   SetIndexLabel(8, "DOWN3");

   SetIndexStyle(9, DRAW_LINE);
   SetIndexBuffer(9, down4);
   SetIndexLabel(9, "DOWN4");

   SetIndexStyle(10, DRAW_LINE);
   SetIndexBuffer(10, down5);
   SetIndexLabel(10, "DOWN5");

   SetIndexStyle(11, DRAW_NONE);
   SetIndexBuffer(11, PriceTimesVolume);

   string error;
   _startTime = ParseTime(StartTime, error);
   if (_startTime < 0)
   {
      Print(error);
      return INIT_FAILED;
   }
   _endTime = ParseTime(StopTime, error);
   if (_endTime < 0)
   {
      Print(error);
      return INIT_FAILED;
   }

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
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

int startIndex;
int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMin(bars_limit, MathMin(Bars - 1 - 0, Bars - counted_bars - 1));
   for (int i = limit; i >= 0; i--)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(Time[i], current_time))
      {
         continue;
      }

      datetime st, et;
      GetStartEndTime(Time[i], st, et);
      if (current_time.day_of_week == 6 || current_time.day_of_week == 0
         || (current_time.day_of_week == 5 && et < Time[i]) 
         || (current_time.day_of_week == 1 && st > Time[i])
         || (startIndex != -1 && startIndex < i))
      {
         startIndex = -1;
         continue;
      }
      if (startIndex == -1)
      {
         startIndex = i;
      }

      PriceTimesVolume[i] = Close[i] * Volume[i];
      double vamaSum = 0;
      double volumeSum = 0;
      for (int ii = startIndex; ii >= i; --ii)
      {
         vamaSum += PriceTimesVolume[ii];
         volumeSum += Volume[ii];
      }
      VAMA[i] = vamaSum / volumeSum;

      double sum = 0;
      double ssum = 0;
      for (int ii = startIndex; ii >= i; --ii)
      {
         double __data = Close[ii] - VAMA[ii];
         sum += __data;
         ssum += MathPow(__data, 2);
      }
      int _period = startIndex - i;
      if (_period <= 1)
      {
         continue;
      }
      double DEV = MathSqrt((ssum * _period - sum * sum) / (_period * (_period - 1)));
      up1[i] = VAMA[i] + DEV * level1;
      up2[i] = VAMA[i] + DEV * level2;
      up3[i] = VAMA[i] + DEV * level3;
      up4[i] = VAMA[i] + DEV * level4;
      up5[i] = VAMA[i] + DEV * level5;
      down1[i] = VAMA[i] - DEV * level1;
      down2[i] = VAMA[i] - DEV * level2;
      down3[i] = VAMA[i] - DEV * level3;
      down4[i] = VAMA[i] - DEV * level4;
      down5[i] = VAMA[i] - DEV * level5;
   }
   return 0;
}
