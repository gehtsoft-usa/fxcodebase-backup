//+------------------------------------------------------------------+
//|                                                          XMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern double Step=2.;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double XMA[];
double StepPoint;

int init()
{
 IndicatorShortName("Digital adaptive Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,XMA);
 
 StepPoint=Step*Point;

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
 double MA0, MA1;
 pos=limit;
 while(pos>=0)
 {
  MA0=iMA(NULL, 0, Length, 0, Method, Price, pos);
  MA1=iMA(NULL, 0, Length, 0, Method, Price, pos+1);
  
  if (MathAbs(MA0-MA1)>=StepPoint)
  {
   XMA[pos]=MA0;
  }
  else
  {
   XMA[pos]=XMA[pos+1];
  }

  pos--;
 } 
 return(0);
}

