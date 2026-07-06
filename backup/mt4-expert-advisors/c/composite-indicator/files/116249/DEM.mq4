//+------------------------------------------------------------------+
//|                                                          DEM.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double DEM[];
double max[], min[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DEM);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,max);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,min);

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
  if (High[pos]>High[pos+1])
  {
   max[pos]=High[pos]-High[pos+1];
  }
  else
  {
   max[pos]=0.;
  }
  
  if (Low[pos]<Low[pos+1])
  {
   min[pos]=Low[pos+1]-Low[pos];
  }
  else
  {
   min[pos]=0.;
  }
  
  pos--;
 } 
 
 double vmax, vmin;
 pos=limit;
 while(pos>=0)
 {
  vmax=iMAOnArray(max, 0, Length, 0, Method, pos);
  vmin=iMAOnArray(min, 0, Length, 0, Method, pos);
  
  if (vmax==0. && vmin==0.)
  {
   DEM[pos]=EMPTY_VALUE;
  }
  else
  {
   DEM[pos]=vmax/(vmax+vmin);
  }

  pos--;
 }
   
 return(0);
}

