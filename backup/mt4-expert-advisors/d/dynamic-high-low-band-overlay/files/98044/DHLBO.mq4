//+------------------------------------------------------------------+
//|                                                        DHLBO.mq4 |
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
 pos=limit;
 while(pos>=0)
 {
  Max=High[iHighest(NULL, 0, MODE_HIGH, Look_Back_Length, pos)];
  Min=Low[iLowest(NULL, 0, MODE_LOW, Look_Back_Length, pos)];
  
  Up[pos]=Min+(Max-Min)*Step;
  Dn[pos]=Max-(Max-Min)*Step;

  pos--;
 } 
 return(0);
}

