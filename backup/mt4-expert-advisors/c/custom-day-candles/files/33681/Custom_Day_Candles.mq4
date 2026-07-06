//+------------------------------------------------------------------+
//|                                           Custom_Day_Candles.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4

extern int BeginDayHour=0;
extern int Shift=500;
extern color BullBarColor = MediumSeaGreen;
extern color BearBarColor = Orange;

//Indicator Buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

int init()
  {
   if (Period()!=PERIOD_D1) 
   {
    Alert("Timeframe must be D1");
    return (0);
   }
   IndicatorShortName("Custom Day Candles");
   IndicatorDigits(Digits);

   SetIndexBuffer( 0, ExtMapBuffer1 );
   SetIndexBuffer( 1, ExtMapBuffer2 );
   SetIndexBuffer( 2, ExtMapBuffer3 );
   SetIndexBuffer( 3, ExtMapBuffer4 );

   SetIndexStyle( 0, DRAW_HISTOGRAM, DRAW_LINE, 1, BullBarColor );
   SetIndexStyle( 1, DRAW_HISTOGRAM, DRAW_LINE, 1, BearBarColor );
   SetIndexStyle ( 2, DRAW_HISTOGRAM, DRAW_LINE, 4, BullBarColor );
   SetIndexStyle( 3, DRAW_HISTOGRAM, DRAW_LINE, 4, BearBarColor );

   SetIndexEmptyValue( 0, 0.0 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexEmptyValue( 2, 0.0 );
   SetIndexEmptyValue( 3, 0.0 );
   

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   int i, x, y, counted=IndicatorCounted();
   if (counted>0) counted--;
   int limit=Bars-counted;
   double O, H, L, C;
   int Bar1, Bar2;
   datetime DT1, DT2;
   
   for (i=limit;i>=0;i--)
   {
    DT1=Time[i]+BeginDayHour*3600;
    DT2=Time[i]+86400+(BeginDayHour)*3600-1;
    Bar1=iBarShift(NULL, PERIOD_H1, DT1, false);
    Bar2=iBarShift(NULL, PERIOD_H1, DT2, false);
    if (iTime(NULL, PERIOD_H1, Bar1)<DT1) Bar1--;
    if (iTime(NULL, PERIOD_H1, Bar2)>DT2) Bar2++;
    if (Bar1<Bar2) continue;
    O=iOpen(NULL, PERIOD_H1, Bar1);
    C=iClose(NULL, PERIOD_H1, Bar2);
    H=iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, Bar1-Bar2+1, Bar2));
    L=iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, Bar1-Bar2+1, Bar2));
    
    if (DT1>TimeCurrent()) return;
   
    if (O<C)
    {
     ExtMapBuffer1[i]=H+Shift*Point;
     ExtMapBuffer2[i]=L+Shift*Point;
    }
    else
    {
     ExtMapBuffer1[i]=L+Shift*Point;
     ExtMapBuffer2[i]=H+Shift*Point;
    }
    ExtMapBuffer3[i]=C+Shift*Point;
    ExtMapBuffer4[i]=O+Shift*Point;
   } 
   return(0);
  }

