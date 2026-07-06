//+------------------------------------------------------------------+
//|                                                 Silver_Trend.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern int SSP=6;
extern double K=50.6;

double S1[], S2[];

int init()
{
 IndicatorShortName("Silver Trend indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,S1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,S2);

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
 double smax;
 pos=limit;
 while(pos>=0)
 {
  Max=High[iHighest(NULL, 0, MODE_HIGH, SSP, pos)];
  Min=Low[iLowest(NULL, 0, MODE_LOW, SSP, pos)];
  
  smax=Max-(Max-Min)*K/100.;
  
  S1[pos]=smax;
  S2[pos+SSP]=smax;

  pos--;
 } 
 return(0);
}

