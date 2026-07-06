//+------------------------------------------------------------------+
//|                                                         GAPO.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;

double GAPO[];
double LogLength;

int init()
{
 IndicatorShortName("Gopalakrishnan Range Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,GAPO);
 LogLength=MathLog(Length);

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
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  if (Min!=Max)
  {
   GAPO[pos]=MathLog(Max-Min)/LogLength;
  }
  else
  {
   GAPO[pos]=EMPTY_VALUE;
  } 
  
  pos--;
 } 
 return(0);
}


