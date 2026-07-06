// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65662

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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.1"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Red

extern bool Show_Daily=true;
extern bool Show_Weekly=true;
input int bars_limit = 1000; // Bars limit

double Daily[] , Weekly[];
double RawDaily[], RawWeekly[], RawMonthly[];
double WP[];

int init()
{

 IndicatorBuffers(6);
 
 IndicatorShortName("VWAP Oscillator");
 IndicatorDigits(Digits);
 
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Daily);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Weekly);
 
  
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,WP);
 
  SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,RawDaily);
  SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,RawWeekly);
  SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,RawMonthly);

 return(0);
}

int deinit()
{

 return(0);
}

double CalcDaily(int pos)
{
 int index=pos;
 double Sum1=0.;
 double Sum2=0.;
 int DT=TimeDay(Time[pos]);
 while (TimeDay(Time[index])==DT && index<Bars)
 {
  Sum1+=WP[index];
  Sum2+=Volume[index];
  
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
  Sum1+=WP[index];
  Sum2+=Volume[index];
  
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
 int index=pos;
 double Sum1=0.;
 double Sum2=0.;
 int DT=TimeMonth(Time[pos]);
 while (TimeMonth(Time[index])==DT && index<Bars)
 {
  Sum1+=WP[index];
  Sum2+=Volume[index];
  
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


int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? MathMin(bars_limit, Bars - ExtCountedBars - 1) : MathMin(bars_limit, Bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      WP[pos]=Volume[pos]*(High[pos]+Low[pos]+Close[pos])/3;
      RawDaily[pos]=CalcDaily(pos);  
      RawWeekly[pos]=CalcWeekly(pos); 
      RawMonthly[pos]=CalcMonthly(pos);
      if (Show_Daily)
         Daily[pos]= RawDaily[pos]-RawMonthly[pos] ;  
      if (Show_Weekly)
         Weekly[pos]= RawWeekly[pos]-RawMonthly[pos] ; 
   } 
   return 0;
}