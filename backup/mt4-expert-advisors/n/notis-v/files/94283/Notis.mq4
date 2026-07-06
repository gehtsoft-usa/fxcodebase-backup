//+------------------------------------------------------------------+
//|                                                        Notis.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern bool Cumulative=false;
extern bool Inverse=false;
double Plus[], Minus[], Notis[];
double P[], M[];

int init()
{
 IndicatorShortName("Notis");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,Plus);
 SetIndexBuffer(1,Minus);
 SetIndexBuffer(2,Notis);
 SetIndexBuffer(3,P);
 SetIndexBuffer(4,M);
 
 if (Cumulative)
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_NONE);
  SetIndexStyle(2,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_LINE);
  SetIndexStyle(2,DRAW_NONE);
 }
 SetIndexStyle(3,DRAW_NONE);
 SetIndexStyle(4,DRAW_NONE);

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
  P[pos]=High[pos]-Close[pos];
  M[pos]=Close[pos]-Low[pos];
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  Plus[pos]=iMAOnArray(P, 0, Length, 0, Method, pos);
  Minus[pos]=iMAOnArray(M, 0, Length, 0, Method, pos);
  if (Plus[pos]+Minus[pos]>0. && Cumulative)
  {
  
   Notis[pos]=100.*Plus[pos]/(Plus[pos]+Minus[pos]);
   if (Inverse)  Notis[pos]=  100- Notis[pos];
   
  }
  else
  {
   Notis[pos]=EMPTY_VALUE;
  } 
  pos--;
 } 
 return(0);
}

