//+------------------------------------------------------------------+
//|                                               Period_Extreme.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=0;
extern int Label_Size=3;

double Up[], Dn[];

int init()
{
 IndicatorShortName("Period Extreme");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,Label_Size);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_ARROW,0,Label_Size);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,Dn);

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
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length+1, pos+1)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length+1, pos+1)];
  
  Up[pos]=EMPTY_VALUE;
  Dn[pos]=EMPTY_VALUE;
  
  if (Close[pos]>Max)
  {
   Up[pos]=High[pos];
  }
  else
  {
   if (Close[pos]<Min)
   {
    Dn[pos]=Low[pos];
   }
  }

  pos--;
 } 
 return(0);
}

