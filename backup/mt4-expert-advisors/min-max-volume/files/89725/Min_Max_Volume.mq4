//+------------------------------------------------------------------+
//|                                               Min_Max_Volume.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=20;

double Up[], Dn[];

int init()
{
 IndicatorShortName("Min max volume");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexBuffer(0,Up);
 SetIndexArrow(0,119);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexBuffer(1,Dn);
 SetIndexArrow(1,119);

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
 int Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=iLowest(NULL, 0, MODE_VOLUME, Length, pos);
  Max=iHighest(NULL, 0, MODE_VOLUME, Length, pos);
  Up[pos]=EMPTY_VALUE;
  Dn[pos]=EMPTY_VALUE;
  if (pos==Max)
  {
   Up[pos]=High[pos];
  }
  if (pos==Min)
  {
   Dn[pos]=Low[pos];
  }
  
  pos--;
 } 
 return(0);
}

