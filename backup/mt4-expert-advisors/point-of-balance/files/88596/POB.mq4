//+------------------------------------------------------------------+
//|                                                          POB.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

extern int Length=14;

double BL[], POB[], BR[];

int init()
{
 IndicatorShortName("Point of Balance");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,BL);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,POB);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,BR);

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
 int limit=Bars-Length;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double MinH, MaxH, MinL, MaxL;
 pos=limit;
 while(pos>=0)
 {
  MinH=High[iLowest(NULL, 0, MODE_HIGH, Length, pos)];
  MaxH=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  MinL=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  MaxL=Low[iHighest(NULL, 0, MODE_LOW, Length, pos)];
  BL[pos]=(MinH+MaxH)/2;
  BR[pos]=(MinL+MaxL)/2;
  POB[pos]=(BL[pos]+BR[pos])/2;
  pos--;
 } 
 return(0);
}


