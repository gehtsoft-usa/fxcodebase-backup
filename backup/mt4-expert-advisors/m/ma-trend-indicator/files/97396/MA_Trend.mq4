//+------------------------------------------------------------------+
//|                                                     MA_Trend.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Start_Period=10;
extern int Step_Period=10;
extern int Count_Of_MAs=50;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double L[], Up[], Dn[];

int init()
{
 IndicatorShortName("MA Trend oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,L);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Dn);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int i;
 double Sum;
 double Pr, MA;
 int Length;
 pos=limit;
 while(pos>=0)
 {
  Sum=0.;
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  for (i=1;i<=Count_Of_MAs;i++)
  {
   Length=Start_Period+(i-1)*Step_Period;
   MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
   if (Pr>MA)
   {
    Sum++;
   }
   else
   {
    if (Pr<MA)
    {
     Sum--;
    }
   }
  }
  
  L[pos]=Sum/Count_Of_MAs;
  if (L[pos]>0.)
  {
   Up[pos]=L[pos];
   Dn[pos]=0.;
  }
  else
  {
   Up[pos]=0.;
   Dn[pos]=L[pos];
  }

  pos--;
 } 
 return(0);
}

