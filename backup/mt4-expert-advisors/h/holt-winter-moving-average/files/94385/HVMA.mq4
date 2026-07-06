//+------------------------------------------------------------------+
//|                                                         HVMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern double a=0.2;
extern double b=0.1;
extern double c=0.1;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double HVMA[];
double F[], V[], A[];

int init()
{
 IndicatorShortName("Holt-Winter Moving Averege");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,HVMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,F);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,V);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,A);

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
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   F[pos]=0.;
   V[pos]=0.;
   A[pos]=0.;
  }
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  F[pos]=(1.-a)*(F[pos+1]+V[pos+1]+0.5*A[pos+1])+a*Pr;
  V[pos]=(1.-b)*(V[pos+1]+A[pos+1])+b*(F[pos]-F[pos+1]);
  A[pos]=(1.-c)*A[pos+1]+c*(V[pos]-V[pos+1]);
  
  HVMA[pos]=F[pos]+V[pos]+0.5*A[pos];

  pos--;
 } 
 return(0);
}

