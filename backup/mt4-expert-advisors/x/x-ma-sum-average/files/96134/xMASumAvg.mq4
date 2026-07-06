//+------------------------------------------------------------------+
//|                                                    xMASumAvg.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Start_Length=20;
extern int End_Length=100;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double xMA[];
double C;

int init()
{
 IndicatorShortName("X MA Sum Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,xMA);
 
 C=End_Length-Start_Length+1.;

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
 double MA;
 pos=limit;
 while(pos>=0)
 {
  Sum=0.;
  for (i=Start_Length;i<=End_Length;i++)
  {
   MA=iMA(NULL, 0, i, 0, Method, Price, pos);
   Sum=Sum+MA;
  }
  
  if (C!=0.)
  {
   xMA[pos]=Sum/C;
  }

  pos--;
 } 
 return(0);
}

