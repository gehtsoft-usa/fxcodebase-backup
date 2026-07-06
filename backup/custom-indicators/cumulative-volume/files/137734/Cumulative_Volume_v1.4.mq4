// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=17&t=42392

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
#property version   "1.4"
#property strict

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 clrMagenta
#property indicator_color2 Green
#property  indicator_width1  2
#property  indicator_width2  2
input string session_start = "000000"; // Session Start
input bool Combined=true;
input bool Relative=false;
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

double Positive[], Negative[], Cumulative[];
double APos[], ANeg[];

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

int startTime;

int init()
{
   IndicatorShortName("Cumulative Volume");
   IndicatorDigits(Digits);
   if (Combined)
   {
      SetIndexStyle(2,DRAW_LINE);
      SetIndexBuffer(0,Cumulative);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexBuffer(1,Positive);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,Negative);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,APos);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexBuffer(4,ANeg);
   }
   else
   {
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(0,Positive);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(1,Negative);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,APos);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,ANeg);
   }
   string error;
   startTime = ParseTime(session_start, error);
   if (startTime < 0)
   {
      Print(error);
      return INIT_FAILED;
   }
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars<0) 
      return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) 
      limit=Bars-ExtCountedBars-1;
   for (int pos = limit; pos >= 0; --pos)
   {
      if (_Period == timeframe || timeframe == PERIOD_CURRENT)
      {
         if (Close[pos] > Close[pos + 1])
         {
            APos[pos] = Volume[pos] / 100;
            ANeg[pos] = 0;
         }
         else
         {
            APos[pos] = 0;
            ANeg[pos] = Volume[pos] / 100;
         }
         datetime sessionStart = (Time[pos] / 86400) * 86400 + startTime;
         if (sessionStart > Time[pos])
         {
            sessionStart -= 86400;
         }
         int index = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, sessionStart);
         if (index < 0)
         {
            continue;
         }
         int smoothingPeriod = index - pos + 1;
         double p = iMAOnArray(APos, 0, smoothingPeriod, 0, MODE_SMA, pos) * smoothingPeriod;
         double n = iMAOnArray(ANeg, 0, smoothingPeriod, 0, MODE_SMA, pos) * smoothingPeriod;
         if (pos > Bars - 1 - smoothingPeriod)
            continue;
         double SVolume = 0.;
         for (int i = 0; i < smoothingPeriod; i++)
         {
            SVolume = SVolume + Volume[pos + i];
         }
         SVolume = SVolume / 100;
         if (Combined)
         {
            if (Relative)
               Cumulative[pos] = (p - n) * 1000 / SVolume;
            else
               Cumulative[pos] = p - n;
         }
         else
         {
            if (Relative)
            {
               Positive[pos] = p * 1000 / SVolume;
               Negative[pos] = -n * 1000 / SVolume;
            }
            else
            {
               Positive[pos] = p;
               Negative[pos] = -n;
            }
         }
      }
      else
      {
         int index = iBarShift(_Symbol, timeframe, Time[pos]);
         if (index < 0)
            continue;
         if (Combined)
            Cumulative[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume_v1.4", session_start, Combined, Relative, 0, index);
         else
         {
            Positive[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume_v1.4", session_start, Combined, Relative, 0, index);
            Negative[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume_v1.4", session_start, Combined, Relative,1, index);
         }
      }
   }
   
   return(0);
}

