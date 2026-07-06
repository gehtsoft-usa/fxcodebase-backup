//+------------------------------------------------------------------+
//|                                                        EVWMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;

double EVWMA[];
double V[];

int init()
{
 IndicatorShortName("Elastic Volume Weighted Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,EVWMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,V);

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
  V[pos]=Volume[pos];
  pos--;
 } 
 
 double Total;
 pos=limit;
 while(pos>=0)
 {
  Total=iMAOnArray(V, 0, Length, 0, MODE_SMA, pos)*Length;
  if (Total!=0)
  {
   EVWMA[pos]=((Total-Volume[pos])*EVWMA[pos+1]+Volume[pos]*Close[pos])/Total;
  }
  else
  {
   EVWMA[pos]=0;
  } 
  pos--;
 }  
 return(0);
}

