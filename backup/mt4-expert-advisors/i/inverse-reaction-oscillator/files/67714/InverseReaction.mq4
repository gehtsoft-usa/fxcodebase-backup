//+------------------------------------------------------------------+
//|                                              InverseReaction.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Gray
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Length=3;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern double Coeff=1.618;

double CO[], U[], D[], AbsCO[];

int init()
  {
   IndicatorShortName("Inverse reaction");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,CO);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,U);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,D);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,AbsCO);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  CO[pos]=Close[pos]-Open[pos];
  AbsCO[pos]=MathAbs(CO[pos]);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  U[pos]=Coeff*iMAOnArray(AbsCO, 0, Length, 0, Method, pos);
  D[pos]=-U[pos];
  pos--;
 }  

 return(0);
}

