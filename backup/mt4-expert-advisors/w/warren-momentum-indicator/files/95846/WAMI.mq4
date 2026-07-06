//+------------------------------------------------------------------+
//|                                                         WAMI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red

extern int MA1_Length=4;
extern int MA1_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA2_Length=13;
extern int MA2_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA3_Length=13;
extern int MA3_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int Signal_Length=4;
extern int Signal_Method=0;  // 0 - SMA
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

double WAMI[], Signal[];
double Difference[], MA1[], MA2[], MA3[];

int init()
{
 IndicatorShortName("Warren Momentum Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,WAMI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Difference);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MA1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,MA2);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,MA3);

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
  Difference[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  MA1[pos]=iMAOnArray(Difference, 0, MA1_Length, 0, MA1_Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  MA2[pos]=iMAOnArray(MA1, 0, MA2_Length, 0, MA2_Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  MA3[pos]=iMAOnArray(MA2, 0, MA3_Length, 0, MA3_Method, pos);

  pos--;
 }
 
 double SigMA;  
 pos=limit;
 while(pos>=0)
 {
  SigMA=iMAOnArray(MA3, 0, Signal_Length, 0, Signal_Method, pos);
  
  WAMI[pos]=MA3[pos]/Point;
  Signal[pos]=SigMA/Point;

  pos--;
 }
   
 return(0);
}

