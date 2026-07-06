//+------------------------------------------------------------------+
//|                                                          APZ.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Yellow

extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Length=10;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern double width=2.;

double UP[], DN[];
double Range[];

int init()
{
 IndicatorShortName("Adaptive Price Zone");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,DN);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Range);

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
  Range[pos]=High[pos]-Low[pos];

  pos--;
 } 
 
 double MA1, MA2;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMA(NULL, 0, Length, 0, Method, Price, pos);
  MA2=iMAOnArray(Range, 0, Length, 0, Method, pos);
  
  UP[pos]=width*MA2+MA1;
  DN[pos]=MA1-width*MA2;

  pos--;
 }
   
 return(0);
}

