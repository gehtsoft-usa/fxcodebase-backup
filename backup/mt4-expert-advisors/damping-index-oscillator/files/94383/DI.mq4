//+------------------------------------------------------------------+
//|                                                           DI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=5;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double DI[];
double H[], L[];

int init()
{
 IndicatorShortName("Damping index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,H);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,L);

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
  H[pos]=iMA(NULL, 0, Length, 0, Method, PRICE_HIGH, pos);
  L[pos]=iMA(NULL, 0, Length, 0, Method, PRICE_LOW, pos);

  pos--;
 } 
 
 double R;
 pos=limit;
 while(pos>=0)
 {
  R=H[pos+Length]-L[pos+Length];
  if (R!=0.)
  {
   DI[pos]=(H[pos]-L[pos])/R;
  } 
  
  pos--;
 }
   
 return(0);
}

