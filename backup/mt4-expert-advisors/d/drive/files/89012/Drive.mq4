//+------------------------------------------------------------------+
//|                                                        Drive.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double Up[], Dn[];
double U[], D[];

int init()
{
 IndicatorShortName("Drive");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,U);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,D);

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
  U[pos]=(High[pos]-Open[pos]+Close[pos]-Low[pos])/2;
  D[pos]=(Open[pos]-Low[pos]+High[pos]-Close[pos])/2;
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Up[pos]=iMAOnArray(U, 0, Length, 0, Method, pos)/Point;
  Dn[pos]=iMAOnArray(D, 0, Length, 0, Method, pos)/Point;
  pos--;
 }
   
 return(0);
}

