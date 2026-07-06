//+------------------------------------------------------------------+
//|                                                          LRL.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=10;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double LRL[], Pr[];

int init()
{
 IndicatorShortName("Linear regression line");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,LRL);
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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 double x, y, xy, x2;
 int i;
 double Temp, m, yint;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  x=0; y=0; xy=0; x2=0;
  for (i=0;i<Length;i++)
  {
   y=y+Pr[pos+i];
   xy=xy+Pr[pos+i]*i;
   x=x+i;
   x2=x2+i*i;
  }
  Temp=Length*x2-x*x;
  m=(Length*xy-x*y)/Temp;
  yint=(y+m*x)/Length;
  LRL[pos]=yint-m*Length;
  pos--;
 } 

 return(0);
}

