//+------------------------------------------------------------------+
//|                                                          TTF.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=15;
extern double OB_OS_Level=100.;

double TTF[];

int init()
{
 IndicatorShortName("Trend Trigger Factor");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TTF);
 
 SetLevelValue(0, OB_OS_Level);
 SetLevelValue(1, -OB_OS_Level);

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
 double Min, Max, Min2, Max2;
 double bp, sp;
 pos=limit;
 while(pos>=0)
 {
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max2=High[iHighest(NULL, 0, MODE_HIGH, Length, pos+Length-1)];
  Min2=Low[iLowest(NULL, 0, MODE_LOW, Length, pos+Length-1)];
  
  bp=Max-Min2;
  sp=Max2-Min;
  
  if (bp+sp!=0.)
  {
   TTF[pos]=200.*(bp-sp)/(bp+sp);
  } 

  pos--;
 } 
 return(0);
}

