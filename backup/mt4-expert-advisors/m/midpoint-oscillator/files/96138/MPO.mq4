//+------------------------------------------------------------------+
//|                                                          MPO.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=26;
extern int Smoothing_Length=9;
extern int Smoothing_Method=0;  // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA

double M[], S[];

int init()
{
 IndicatorShortName("Midpoint Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,M);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,S);

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
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  
  if (Max!=Min)
  {
   M[pos]=100.*(2.*Close[pos]-Max-Min)/(Max-Min);
  } 

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  S[pos]=iMAOnArray(M, 0, Smoothing_Length, 0, Smoothing_Method, pos);

  pos--;
 }
   
 return(0);
}

