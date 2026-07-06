//+------------------------------------------------------------------+
//|                                                      MA_Zone.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Red
#property indicator_color6 Green
#property indicator_color7 Red

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
extern double Level1=100.;
extern double Level2=500.;
extern double Level3=1000.;                      

double Central[], Top1[], Bottom1[], Top2[], Bottom2[], Top3[], Bottom3[];

int init()
{
 IndicatorShortName("MA Zone");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Central);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Top1);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Bottom1);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,Top2);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,Bottom2);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,Top3);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,Bottom3);

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
 double MA;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
  Central[pos]=MA;
  
  Top1[pos]=MA+Level1*Point;
  Bottom1[pos]=MA-Level1*Point;
  Top2[pos]=MA+Level2*Point;
  Bottom2[pos]=MA-Level2*Point;
  Top3[pos]=MA+Level3*Point;
  Bottom3[pos]=MA-Level3*Point;

  pos--;
 } 
 return(0);
}

