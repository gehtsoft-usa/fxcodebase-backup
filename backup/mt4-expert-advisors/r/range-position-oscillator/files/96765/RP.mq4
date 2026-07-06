//+------------------------------------------------------------------+
//|                                                           RP.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern double Level1=38.2;
extern double Level2=50.;
extern double Level3=61.8;

double RP[];

int init()
{
 IndicatorShortName("Range Position");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RP);
 
 SetLevelValue(0, Level1);
 SetLevelValue(1, Level2);
 SetLevelValue(2, Level3);

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
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos+1)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos+1)];
  
  if (Max!=Min)
  {
   RP[pos]=100.*(Close[pos]-Min)/(Max-Min);
  } 

  pos--;
 } 
 return(0);
}

