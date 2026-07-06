//+------------------------------------------------------------------+
//|                                              Open_Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_width1 1
#property indicator_color2 Green
#property indicator_width2 1
#property indicator_color3 Red
#property indicator_width3 3
#property indicator_color4 Green
#property indicator_width4 3

extern int Length=20;
extern int Signal_Length=10;

double L[], H[], SignalL[], SignalH[];

int init()
{
 IndicatorShortName("Open oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,L);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,H);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,SignalL);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,SignalH);

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
 int MinPos, MaxPos;
 pos=limit;
 while(pos>=0)
 {
  MinPos=iLowest(NULL, 0, MODE_LOW, Length, pos);
  MaxPos=iHighest(NULL, 0, MODE_HIGH, Length, pos);
  
  L[pos]=Open[MinPos]-Open[pos];
  H[pos]=Open[pos]-Open[MaxPos];

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  SignalL[pos]=iMAOnArray(L, 0, Signal_Length, 0, MODE_EMA, pos);
  SignalH[pos]=iMAOnArray(H, 0, Signal_Length, 0, MODE_EMA, pos);

  pos--;
 }
   
 return(0);
}

