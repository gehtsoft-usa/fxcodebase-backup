//+------------------------------------------------------------------+
//|                                               Dominant_Color.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA


double DC[], DC_Dn[];
double Diff[];

int init()
{
 IndicatorShortName("Dominant color");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,DC);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DC_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Diff);

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
  Diff[pos]=Close[pos]-Open[pos];
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  DC[pos]=iMAOnArray(Diff, 0, Length, 0, Method, pos)/Point;
  if (DC[pos]<DC[pos+1])
  {
   DC_Dn[pos]=DC[pos];
  }
  else
  {
   DC_Dn[pos]=EMPTY_VALUE;
  }
  pos--;
 }
   
 return(0);
}

