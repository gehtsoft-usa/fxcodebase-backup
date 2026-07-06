//+------------------------------------------------------------------+
//|                                                          RTR.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Fast_Length=2;
extern int Slow_Length=7;

double RTR[];

int init()
{
 IndicatorShortName("Range To Range");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RTR);

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
 double Fast_ATR, Slow_ATR;
 pos=limit;
 while(pos>=0)
 {
  Fast_ATR=iATR(NULL, 0, Fast_Length, pos);
  Slow_ATR=iATR(NULL, 0, Slow_Length, pos);
  if (Slow_ATR!=0.)
  {
   RTR[pos]=100.*Fast_ATR/Slow_ATR;
  }
  else
  {
   RTR[pos]=EMPTY_VALUE;
  }
  
  pos--;
 } 
 return(0);
}

