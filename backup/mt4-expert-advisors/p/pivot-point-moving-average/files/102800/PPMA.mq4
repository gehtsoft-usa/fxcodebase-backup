//+------------------------------------------------------------------+
//|                                                         PPMA.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;

double PPMA[];

int init()
{
 IndicatorShortName("Pivot Point Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PPMA);

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
  PPMA[pos]=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_TYPICAL, pos);

  pos--;
 } 
 return(0);
}

