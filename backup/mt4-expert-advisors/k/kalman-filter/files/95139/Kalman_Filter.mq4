//+------------------------------------------------------------------+
//|                                                Kalman_Filter.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern double K=1.;
extern double Sharpness=1.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double KF[];
double Velocity[];
double ShK;

int init()
{
 IndicatorShortName("Kalman Filter");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,KF);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Velocity);
 
 ShK=MathSqrt(Sharpness*K/100.);

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
 double Pr;
 double Distance, Error;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  if (pos==Bars-2)
  {
   Velocity[pos]=0.;
   KF[pos]=Pr;
  }
  else
  {
   Distance=Pr-KF[pos+1];
   Error=KF[pos+1]+Distance*ShK;
   Velocity[pos]=Velocity[pos+1]+Distance*K/100.;
   KF[pos]=Error+Velocity[pos];
  }

  pos--;
 } 
 return(0);
}

