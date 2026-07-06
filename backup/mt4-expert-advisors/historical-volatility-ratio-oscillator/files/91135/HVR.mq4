//+------------------------------------------------------------------+
//|                                                          HVR.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length1=6;
extern int Length2=100;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double HVR[];
double Pr[], St[];
int MaxLength;

int init()
{
 IndicatorShortName("Historical Volatility Ratio");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,HVR);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,St);
 MaxLength=MathMax(Length1, Length2);
 return(0);
}

int deinit()
{

 return(0);
}

double StdDev(double A[], int Length, int index)
{
 double avg=0;
 int i;
 for (i=0;i<Length;i++)
 {
  avg+=A[index+i];
 }
 avg=avg/Length;
 double SD=0;
 for (i=0;i<Length;i++)
 {
  SD+=(avg-A[index+i])*(avg-A[index+i]);
 }
 SD=MathSqrt(SD/Length);
 return (SD);
}

int start()
{
 if(Bars<=MaxLength) return(0);
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
 
 pos=limit;
 while(pos>=0)
 {
  St[pos]=MathLog(Pr[pos]/Pr[pos+1]);
  pos--;
 }
 
 double StdDev1, StdDev2;
 pos=limit;
 while(pos>=0)
 {
  StdDev1=StdDev(St, Length1, pos);
  StdDev2=StdDev(St, Length2, pos);
  if (StdDev2!=0)
  {
   HVR[pos]=StdDev1/StdDev2;
  }
  else
  {
   HVR[pos]=EMPTY_VALUE;
  }
  pos--;
 }
  
 return(0);
}

