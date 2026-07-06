// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65662

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.5"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Blue
#property indicator_color6 Blue
#property indicator_color7 Blue

input bool Show_m5 = true;
input bool Show_m15 = true;
input bool Show_m30 = true;
input bool Show_H4 = true;
input bool Show_Daily=true;
input bool Show_Weekly=true;
input bool Show_Monthly=true;
input int bars_limit = 1000; // Bars limit

double H4[], Daily[], Weekly[], m5[], m15[], m30[], M1[];
double RawH4[], RawDaily[], RawWeekly[], RawMonthly[], RawM5[], RawM15[], RawM30[], RawY1[];
double WP[];

int init()
{
   IndicatorBuffers(16);
   
   IndicatorShortName("VWAP Oscillator");
   IndicatorDigits(Digits);
   
   int id = 0;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, Daily);
   SetIndexLabel(id, "Daily");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, Weekly);
   SetIndexLabel(id, "Weekly");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, H4);
   SetIndexLabel(id, "H4");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, m30);
   SetIndexLabel(id, "m30");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, m15);
   SetIndexLabel(id, "m15");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, m5);
   SetIndexLabel(id, "m5");
   ++id;

   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, M1);
   SetIndexLabel(id, "M1");
   ++id;
   
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RawDaily);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RawWeekly);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RawMonthly);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RawH4);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RawM30);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RawM15);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RawM5);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, RawY1);
   ++id;
   
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, WP);
   ++id;
   
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
   int index = pos;
   double Sum1 = 0.;
   double Sum2 = 0.;
   
   int DT = iBarShift(_Symbol, tf, Time[pos]);
   while (iBarShift(_Symbol, tf, Time[index]) == DT && index < Bars)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
   }
   
   if (Sum2 != 0.)
   {
      return Sum1 / Sum2;
   }
   return EMPTY_VALUE;
}

double CalcH4(int pos)
{
   int index = pos;
   double Sum1 = 0.;
   double Sum2 = 0.;
   
   int DT = GetHour(Time[pos]);
   while (GetHour(Time[index])==DT && index<Bars)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
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
   int index=pos;
   double Sum1=0.;
   double Sum2=0.;
   int DT=TimeDay(Time[pos]);
   while (TimeDay(Time[index])==DT && index<Bars)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
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
   int index=pos+1;
   double Sum1=WP[pos];
   double Sum2=Volume[pos];
   while (TimeDayOfWeek(Time[index+1])<=TimeDayOfWeek(Time[index]) && index<Bars)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
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
   int index = pos;
   double Sum1 = 0.;
   double Sum2 = 0.;
   int DT = TimeMonth(Time[pos]);
   while (TimeMonth(Time[index]) == DT && index < Bars)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
   }
   
   return Sum2 != 0. ? (Sum1 / Sum2) : EMPTY_VALUE;
}

double CalcYearly(int pos)
{
   int index = pos;
   double Sum1 = 0.;
   double Sum2 = 0.;
   int DT = TimeYear(Time[pos]);
   while (TimeYear(Time[index]) == DT && index < Bars)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
   }
   
   return Sum2 != 0. ? (Sum1 / Sum2) : EMPTY_VALUE;
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
      WP[pos]=Volume[pos]*(High[pos]+Low[pos]+Close[pos])/3;
      RawM5[pos] = CalcCustom(pos, PERIOD_M5);
      RawM15[pos] = CalcCustom(pos, PERIOD_M15);
      RawM30[pos] = CalcCustom(pos, PERIOD_M30);
      RawY1[pos] = CalcYearly(pos);

      RawH4[pos]=CalcH4(pos);
      RawDaily[pos]=CalcDaily(pos);
      RawWeekly[pos]=CalcWeekly(pos); 
      RawMonthly[pos]=CalcMonthly(pos);
      if (Show_H4)
         H4[pos] = RawH4[pos] - RawMonthly[pos];
      if (Show_Daily)
         Daily[pos]= RawDaily[pos]-RawMonthly[pos];  
      if (Show_Weekly)
         Weekly[pos]= RawWeekly[pos]-RawMonthly[pos]; 
      if (Show_m30 && _Period <= PERIOD_M30)
      {
         m30[pos] = RawM30[pos] - RawMonthly[pos];
      }
      if (Show_m15 && _Period <= PERIOD_M15)
      {
         m15[pos] = RawM15[pos] - RawMonthly[pos];
      }
      if (Show_m5 && _Period <= PERIOD_M5)
      {
         m5[pos] = RawM5[pos] - RawMonthly[pos];
      }
      if (Show_Monthly)
      {
         M1[pos] = RawMonthly[pos] - RawY1[pos];
      }
   } 
   return 0;
}