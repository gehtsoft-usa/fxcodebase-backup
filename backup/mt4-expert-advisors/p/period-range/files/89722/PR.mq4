//+------------------------------------------------------------------+
//|                                                           PR.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Length=14;
extern bool UseLastPeriod=true;

double Top[], Bottom[], Central[];

int init()
{
 IndicatorShortName("Period Range");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bottom);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Central);

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
  if (UseLastPeriod)
  {
   Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
   Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  }
  else
  {
   Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos+1)];
   Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos+1)];
  } 
  Top[pos]=0;
  Bottom[pos]=100;
  if (Min!=Max)
  {
   Central[pos]=100*(Close[pos]-Min)/(Max-Min);
  }
  else
  {
   Central[pos]=EMPTY_VALUE;
  }
  pos--;
 } 
 return(0);
}

