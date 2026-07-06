//+------------------------------------------------------------------+
//|                                                         TATR.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;
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

double TATR[];
double tr[];

int init()
{
 IndicatorShortName("Tick ATR");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TATR);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,tr);

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
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  tr[pos]=MathAbs(Pr1-Pr0);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  TATR[pos]=iMAOnArray(tr, 0, Length, 0, Method, pos)/Point;

  pos--;
 }
   
 return(0);
}

