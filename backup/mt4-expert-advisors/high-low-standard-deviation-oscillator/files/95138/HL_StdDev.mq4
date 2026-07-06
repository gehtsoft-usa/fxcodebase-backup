//+------------------------------------------------------------------+
//|                                                    HL_StdDev.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=30;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double HL_StdDev[];
double HL[];

int init()
{
 IndicatorShortName("Standard deviation of High/Low");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,HL_StdDev);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,HL);

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
 pos=limit;
 while(pos>=0)
 {
  HL[pos]=High[pos]-Low[pos];
  
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  HL_StdDev[pos]=iStdDevOnArray(HL, 0, Length, 0, Method, pos)/Point;
  
  pos--;
 } 
 return(0);
}

