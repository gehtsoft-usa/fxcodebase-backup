//+------------------------------------------------------------------+
//|                                                           VA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Velocity_Length=14;
extern int Acceleration_Length=10;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double V[], A[];
int MaxLength;

int init()
{
 IndicatorShortName("Velocity/Acceleration");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,V);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,A);
 MaxLength=MathMax(Velocity_Length, Acceleration_Length);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=MaxLength) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-MaxLength;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Pr0, PrL;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  PrL=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Velocity_Length);
  if (PrL!=0)
  {
   V[pos]=100*Pr0/PrL;
  } 
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (V[pos+Acceleration_Length]!=0)
  {
   A[pos]=100*V[pos]/V[pos+Acceleration_Length];
  } 
  pos--;
 }  
 return(0);
}

