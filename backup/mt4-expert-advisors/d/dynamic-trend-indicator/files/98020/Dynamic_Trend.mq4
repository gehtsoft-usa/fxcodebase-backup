//+------------------------------------------------------------------+
//|                                                Dynamic_Trend.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Percent=10;
extern int MaxPeriod=14;
extern int ArrowSize=4;

double Line[], Up[], Dn[];

int init()
{
 IndicatorShortName("Dynamic Trend Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Line);
 SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(1,233);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(2,234);
 SetIndexBuffer(2,Dn);

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
 int index;
 pos=limit;
 while(pos>=0)
 {
  if (Close[pos]<Line[pos+1])
  {
   index=iHighest(NULL, 0, MODE_CLOSE, MaxPeriod, pos+1);
   Line[pos]=Close[index]-Percent*Point;
  }
  else
  {
   index=iLowest(NULL, 0, MODE_CLOSE, MaxPeriod, pos+1);
   Line[pos]=Close[index]+Percent*Point;
  }
  
  if (Close[pos+3]>Line[pos+2] && Close[pos+2]<Line[pos+3])
  {
   Up[pos]=Low[pos]-10.*Point;
  }
  
  if (Close[pos+2]<Line[pos+1] && Close[pos+2]>Line[pos+3])
  {
   Dn[pos]=High[pos]+10.*Point;
  }

  pos--;
 } 
 return(0);
}

