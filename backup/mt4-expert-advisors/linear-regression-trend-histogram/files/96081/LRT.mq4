//+------------------------------------------------------------------+
//|                                                          LRT.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=34;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double LRT[], LRT_Dn[];
double sumx, sumx2;

int init()
{
 IndicatorShortName("Linear Regression Trend Histogram");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,LRT);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,LRT_Dn);
 
 sumx=(1.+Length)*Length/2.;
 sumx2=(2.*Length+1.)*(1.+Length)*Length/6.;

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
 double sumy, sumxy;
 double b, c;
 double Pr;
 int i;
 pos=limit;
 while(pos>=0)
 {
  sumy=0.;
  sumxy=0.;
  for (i=1;i<=Length;i++)
  {
   Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Length-i);
   sumy=sumy+Pr;
   sumxy=sumxy+Pr*i;
  }
  
  c=sumx2*Length-sumx*sumx;
  if (c!=0.)
  {
   b=(sumxy*Length-sumx*sumy)/c;
   LRT[pos]=b/Point;
   if (LRT[pos]<LRT[pos+1])
   {
    LRT_Dn[pos]=LRT[pos];
   }
   else
   {
    LRT_Dn[pos]=EMPTY_VALUE;
   }
  } 

  pos--;
 } 
 return(0);
}

