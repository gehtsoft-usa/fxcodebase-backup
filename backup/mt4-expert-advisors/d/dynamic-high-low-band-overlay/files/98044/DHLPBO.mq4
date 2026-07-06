//+------------------------------------------------------------------+
//|                                                       DHLPBO.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Look_Back_Length=14;
extern double Step=0.7071;

double Up[], Dn[];

int init()
{
 IndicatorShortName("Dynamic High/Low Band");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_LINE);
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
 double Max, Min;
 int MaxIndex, MinIndex;
 pos=limit;
 while(pos>=0)
 {
  MaxIndex=iHighest(NULL, 0, MODE_HIGH, Look_Back_Length, pos);
  Max=High[MaxIndex];
  MinIndex=iLowest(NULL, 0, MODE_LOW, Look_Back_Length, pos);
  Min=Low[MinIndex];
  
  Up[pos]=Max-(Max-Min)*(MaxIndex-pos)*Step/100.;
  Dn[pos]=Min+(Max-Min)*(MinIndex-pos)*Step/100.;

  pos--;
 } 
 return(0);
}

