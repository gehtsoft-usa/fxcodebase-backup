//+------------------------------------------------------------------+
//|                                                      SineWMA.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define Pi 3.1415926

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double SineWMA[];
double Pr[];
double SinCoeff[];
double SinCoeffSum;

int init()
{
 IndicatorShortName("Sine Weighted Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SineWMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);
 
 ArrayResize(SinCoeff, Length);
 int i;
 SinCoeffSum=0.;
 for (i=0;i<Length;i++)
 {
  SinCoeff[i]=MathSin(Pi*(1.+i)/(1.+Length));
  SinCoeffSum=SinCoeffSum+SinCoeff[i];
 }

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
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 double Sum;
 int i;
 pos=limit;
 while(pos>=0)
 {
  Sum=0.;
  for (i=0;i<Length;i++)
  {
   Sum=Sum+SinCoeff[i]*Pr[pos+i];
  }
  
  SineWMA[pos]=Sum/SinCoeffSum;

  pos--;
 }
   
 return(0);
}

