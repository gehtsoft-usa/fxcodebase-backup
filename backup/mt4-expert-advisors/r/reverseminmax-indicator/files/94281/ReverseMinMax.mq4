//+------------------------------------------------------------------+
//|                                                ReverseMinMax.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue
#property indicator_color4 Blue

extern int Length=20;
extern int Reverse_Length=5;
extern bool Show_Min_Max=false;

double ReverseMin[], ReverseMax[], Min[], Max[];

int init()
{
 IndicatorShortName("Reverse Min Max");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ReverseMin);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,ReverseMax);
 SetIndexBuffer(2,Min);
 SetIndexBuffer(3,Max);
 if (Show_Min_Max)
 {
  SetIndexStyle(2,DRAW_LINE);
  SetIndexStyle(3,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(3,DRAW_NONE);
 }

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
  Min[pos]=Low[iLowest(NULL, 0, MODE_LOW, Length-1, pos+1)];
  Max[pos]=High[iHighest(NULL, 0, MODE_HIGH, Length-1, pos+1)];
  ReverseMin[pos]=Low[iHighest(NULL, 0, MODE_LOW, Reverse_Length-1, pos+1)];
  ReverseMax[pos]=High[iLowest(NULL, 0, MODE_HIGH, Reverse_Length-1, pos+1)];
  pos--;
 } 
 return(0);
}

