//+------------------------------------------------------------------+
//|                                          Blau_Trend_Momentum.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;

double TM[];

int init()
{
 IndicatorShortName("William Blau Trend Momentum");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TM);

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

 double H, L;
 pos=limit;
 while(pos>=0)
 {
  H=High[pos]-High[pos+Length];
  if (H<0) H=0;
  L=Low[pos+Length]-Low[pos];
  if (L<0) L=0;
  TM[pos]=H-L;
  pos--;
 }
 
 return(0);
}

