//+------------------------------------------------------------------+
//|                                                     MA_Delta.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=10;
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

double MA_Delta[];

int init()
{
 IndicatorShortName("MA Delta");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA_Delta);
 
 SetLevelValue(0, 0.);
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
  
  MA_Delta[pos]=(MA0-MA1)/Point;

  pos--;
 } 
 return(0);
}

