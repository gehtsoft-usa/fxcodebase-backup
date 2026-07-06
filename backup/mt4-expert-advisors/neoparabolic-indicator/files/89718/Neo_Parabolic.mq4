//+------------------------------------------------------------------+
//|                                                Neo_Parabolic.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;

double Upper[], Lower[];

int init()
{
 IndicatorShortName("Neo parabolic indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Upper);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Lower);

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
 int i;
 double Min, Max;
 double L, H;
 pos=limit;
 while(pos>=0)
 {
  Min=0;
  Max=0;
  for (i=1;i<=Length;i++)
  {
   L=Low[iLowest(NULL, 0, MODE_LOW, i, pos)];
   H=High[iHighest(NULL, 0, MODE_HIGH, i, pos)];
   Min=Min+L;
   Max=Max+H;
  }
  Upper[pos]=Max/Length;
  Lower[pos]=Min/Length;
  pos--;
 } 
 return(0);
}

