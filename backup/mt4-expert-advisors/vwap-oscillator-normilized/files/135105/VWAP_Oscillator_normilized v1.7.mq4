// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69640

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.7"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Blue
#property indicator_color6 Blue

input bool Show_m5 = true;
input bool Show_m15 = true;
input bool Show_m30 = true;
input bool Show_H4 = true;
input bool Show_Daily=true;
input bool Show_Weekly=true;
input int range_bars = 10; // Range bars
input int bars_limit = 1000; // Bars limit
input string symbol = "EURUSD"; // Symbol
input ENUM_TIMEFRAMES stf = PERIOD_CURRENT; // Timeframe

double H4[], Daily[], Weekly[], m5[], m15[], m30[];
double RawH4[], RawDaily[], RawWeekly[], RawMonthly[], RawM5[], RawM15[], RawM30[];
double WP[];

int init()
{
   IndicatorBuffers(14);
   
   IndicatorShortName("VWAP Oscillator");
   IndicatorDigits(Digits);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Daily);
   SetIndexLabel(0, "Daily");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Weekly);
   SetIndexLabel(1, "Weekly");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,H4);
   SetIndexLabel(2, "H4");

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,m30);
   SetIndexLabel(3, "m30");
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,m15);
   SetIndexLabel(4, "m15");
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,m5);
   SetIndexLabel(5, "m5");
   
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,RawDaily);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,RawWeekly);
   SetIndexStyle(8,DRAW_NONE);
   SetIndexBuffer(8,RawMonthly);
   SetIndexStyle(13,DRAW_NONE);
   SetIndexBuffer(13,RawH4);

   SetIndexStyle(9,DRAW_NONE);
   SetIndexBuffer(9,RawM30);
   SetIndexStyle(10,DRAW_NONE);
   SetIndexBuffer(10,RawM15);
   SetIndexStyle(11,DRAW_NONE);
   SetIndexBuffer(11,RawM5);
   
   SetIndexStyle(12,DRAW_NONE);
   SetIndexBuffer(12,WP);
   
   
   return(0);
}

int deinit()
{
   return(0);
}

int GetHour(datetime date)
{
   MqlDateTime current_time;
   TimeToStruct(date, current_time);
   return current_time.hour;
}

double CalcCustom(int pos, ENUM_TIMEFRAMES tf)
{
   int index = iBarShift(symbol, stf, Time[pos]);
   if (index < 0)
   {
      return EMPTY_VALUE;
   }
   double Sum1 = 0.;
   double Sum2 = 0.;
   int DT = iBarShift(symbol, tf, iTime(symbol, stf, index));
   while (iBarShift(symbol, tf,iTime(symbol, stf, index)) == DT && pos < Bars && index >= 0)
   {
      if (WP[pos] != EMPTY_VALUE)
      {
         Sum1 += WP[pos];
         Sum2 += iVolume(symbol, stf, index);
      }
      
      pos++;
      if (pos < Bars)
      {
         index = iBarShift(symbol, stf, Time[pos]);
      }
   }
   
   if (Sum2 != 0.)
   {
      return Sum1 / Sum2;
   }
   return EMPTY_VALUE;
}

double CalcH4(int pos)
{
   int index = iBarShift(symbol, stf, Time[pos]);
   if (index < 0)
   {
      return EMPTY_VALUE;
   }
   double Sum1 = 0.;
   double Sum2 = 0.;
   
   int DT = GetHour(iTime(symbol, stf, index));
   while (GetHour(iTime(symbol, stf, index))==DT && index<Bars && index >= 0)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[pos];
         Sum2 += iVolume(symbol, stf, index);
      }
      
      pos++;
      index = iBarShift(symbol, stf, Time[pos]);
   }
   
   if (Sum2!=0.)
   {
      return (Sum1/Sum2);
   }
   else
   {
      return (EMPTY_VALUE);
   }
}

double CalcDaily(int pos)
{
   int index = iBarShift(symbol, stf, Time[pos]);
   if (index < 0)
   {
      return EMPTY_VALUE;
   }
   double Sum1=0.;
   double Sum2=0.;
   int DT=TimeDay(iTime(symbol, stf, index));
   while (TimeDay(iTime(symbol, stf, index))==DT && pos < Bars && index >= 0)
   {
      if (WP[pos] != EMPTY_VALUE)
      {
         Sum1 += WP[pos];
         Sum2 += iVolume(symbol, stf, index);
      }
      
      pos++;
      if (pos < Bars)
      {
         index = iBarShift(symbol, stf, Time[pos]);
      }
   }
   
   if (Sum2!=0.)
   {
      return (Sum1/Sum2);
   }
   else
   {
      return (EMPTY_VALUE);
   }
}

double CalcWeekly(int pos)
{
   int index = iBarShift(symbol, stf, Time[pos + 1]);
   if (index < 0)
   {
      return EMPTY_VALUE;
   }
   double Sum1 = WP[pos];
   double Sum2 = iVolume(symbol, stf, index);
   while (TimeDayOfWeek(iTime(symbol, stf, index + 1))<=TimeDayOfWeek(iTime(symbol, stf, index)) && pos < Bars && index >= 0)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[pos];
         Sum2 += iVolume(symbol, stf, index);
      }
      
      pos++;
      if (pos < Bars)
      {
         index = iBarShift(symbol, stf, Time[pos]);
      }
   }
   
   if (Sum2!=0.)
   {
      return (Sum1/Sum2);
   }
   else
   {
      return (EMPTY_VALUE);
   }
}

double CalcMonthly(int pos)
{
   int index = iBarShift(symbol, stf, Time[pos]);
   if (index < 0)
   {
      return EMPTY_VALUE;
   }
   double Sum1=0.;
   double Sum2=0.;
   int DT=TimeMonth(iTime(symbol, stf, index));
   while (TimeMonth(Time[index]) == DT && pos < Bars && index >= 0)
   {
      if (WP[pos] != EMPTY_VALUE)
      {
         Sum1 += WP[pos];
         Sum2 += iVolume(symbol, stf, index);
      }
      
      pos++;
      if (pos < Bars)
      {
         index = iBarShift(symbol, stf, Time[pos]);
      }
   }
   
   if (Sum2!=0.)
   {
      return (Sum1/Sum2);
   }
   else
   {
      return (EMPTY_VALUE);
   }
}

int start()
{
   if (Bars <= 1) 
   {
      return 0;
   }
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
   {
      return -1;
   }
   int limit = ExtCountedBars > 1 ? MathMin(bars_limit, Bars - ExtCountedBars - 1) : MathMin(bars_limit, Bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      int index = iBarShift(symbol, stf, Time[pos]);
      WP[pos] = iVolume(symbol, stf, index) * (iHigh(symbol, stf, index) + iLow(symbol, stf, index) + iClose(symbol, stf, index)) / 3;
      RawM5[pos] = CalcCustom(pos, PERIOD_M5);
      RawM15[pos] = CalcCustom(pos, PERIOD_M15);
      RawM30[pos] = CalcCustom(pos, PERIOD_M30);

      RawH4[pos] = CalcH4(pos);
      RawDaily[pos]=CalcDaily(pos);
      RawWeekly[pos]=CalcWeekly(pos); 
      RawMonthly[pos]=CalcMonthly(pos);

      double ll = DBL_MAX;
      double hh = -DBL_MAX;
      for (int i = 0; i < range_bars; ++i)
      {
         if (pos + i > Bars - 1)
         {
            break;
         }
         if (RawH4[pos] - RawMonthly[pos] < ll && Show_H4)
         {
            ll = RawH4[pos] - RawMonthly[pos];
         }
         if (RawH4[pos] - RawMonthly[pos] > hh && Show_H4)
         {
            hh = RawH4[pos] - RawMonthly[pos];
         }
         if (RawDaily[pos] - RawMonthly[pos] < ll && Show_Daily)
         {
            ll = RawDaily[pos] - RawMonthly[pos];
         }
         if (RawDaily[pos] - RawMonthly[pos] > hh && Show_Daily)
         {
            hh = RawDaily[pos] - RawMonthly[pos];
         }
         if (RawWeekly[pos] - RawMonthly[pos] < ll && Show_Weekly)
         {
            ll = RawWeekly[pos] - RawMonthly[pos];
         }
         if (RawWeekly[pos] - RawMonthly[pos] > hh && Show_Weekly)
         {
            hh = RawWeekly[pos] - RawMonthly[pos];
         }
         if (RawM30[pos] - RawMonthly[pos] < ll && Show_m30)
         {
            ll = RawM30[pos] - RawMonthly[pos];
         }
         if (RawM30[pos] - RawMonthly[pos] > hh && Show_m30)
         {
            hh = RawM30[pos] - RawMonthly[pos];
         }
         if (RawM15[pos] - RawMonthly[pos] < ll && Show_m15)
         {
            ll = RawM15[pos] - RawMonthly[pos];
         }
         if (RawM15[pos] - RawMonthly[pos] > hh && Show_m15)
         {
            hh = RawM15[pos] - RawMonthly[pos];
         }
         if (RawM5[pos] - RawMonthly[pos] < ll && Show_m5)
         {
            ll = RawM5[pos] - RawMonthly[pos];
         }
         if (RawM5[pos] - RawMonthly[pos] > hh && Show_m5)
         {
            hh = RawM5[pos] - RawMonthly[pos];
         }
      }
      double range = (hh - ll) / 100;
      if (range == 0)
      {
         continue;
      }
      if (Show_H4)
      {
         H4[pos] = (RawH4[pos] - RawMonthly[pos] - ll) / range;
      }
      if (Show_Daily)
      {
         Daily[pos] = (RawDaily[pos] - RawMonthly[pos] - ll) / range;
      }
      if (Show_Weekly)
      {
         Weekly[pos] = (RawWeekly[pos] - RawMonthly[pos] - ll) / range;
      }
      if (Show_m30 && _Period <= PERIOD_M30)
      {
         m30[pos] = (RawM30[pos] - RawMonthly[pos] - ll) / range;
      }
      if (Show_m15 && _Period <= PERIOD_M15)
      {
         m15[pos] = (RawM15[pos] - RawMonthly[pos] - ll) / range;
      }
      if (Show_m5 && _Period <= PERIOD_M5)
      {
         m5[pos] = (RawM5[pos] - RawMonthly[pos] - ll) / range;
      }
   } 
   return 0;
}