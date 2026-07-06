//+------------------------------------------------------------------+
//|                                                         SWMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

#define PI 3.141592653589793

extern int Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double SWMA[];
double Pr[];

int init()
{
 IndicatorShortName("Sine-Weighted Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SWMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 } 
 
 int i;
 double Numerator;
 double Denominator;
 pos=limit;
 while(pos>=0)
 {
  Numerator=0;
  Denominator=0;
  for (i=1;i<=Length;i++)
  {
   Numerator+=MathSin(PI*(Length-i+1)/(Length+1))*Pr[pos+Length-i];
   Denominator+=MathSin(PI*(Length-i+1)/(Length+1));
   if (Denominator!=0)
   {
    SWMA[pos]=Numerator/Denominator;
   }
   else
   {
    SWMA[pos]=0;
   }
  }
  pos--;
 } 
 return(0);
}

