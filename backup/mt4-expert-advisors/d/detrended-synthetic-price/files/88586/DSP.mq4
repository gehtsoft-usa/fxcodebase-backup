//+------------------------------------------------------------------+
//|                                                          DSP.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
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

double DSP[];

int init()
{
 IndicatorShortName("Detrended Synthetic Price");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DSP);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=2*Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double MA1, MA2;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMA(NULL, 0, Length, 0, Method, Price, pos);
  MA2=iMA(NULL, 0, 2*Length, 0, Method, Price, pos);
  DSP[pos]=MA1-MA2;
  pos--;
 } 
 return(0);
}

