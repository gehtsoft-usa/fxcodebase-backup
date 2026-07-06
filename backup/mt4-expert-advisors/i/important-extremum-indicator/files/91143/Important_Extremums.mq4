//+------------------------------------------------------------------+
//|                                          Important_Extremums.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=15;

double UP[], DN[];

int init()
{
 IndicatorShortName("Important Extremums indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,DN);

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
  if (High[pos+1]>=High[iHighest(NULL, 0, MODE_HIGH, Length, pos+2)] && High[pos+1]>High[pos])
  {
   UP[pos+1]=High[pos+1];
  }
  else
  {
   UP[pos+1]=EMPTY_VALUE;
  }

  if (Low[pos+1]<=Low[iLowest(NULL, 0, MODE_LOW, Length, pos+2)] && Low[pos+1]<Low[pos])
  {
   DN[pos+1]=Low[pos+1];
  }
  else
  {
   DN[pos+1]=EMPTY_VALUE;
  }
  
  pos--;
 } 
 return(0);
}

