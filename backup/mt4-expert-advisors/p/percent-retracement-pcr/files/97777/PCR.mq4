//+------------------------------------------------------------------+
//|                                                          PCR.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=10;
extern double Overbought_Level=80.;
extern double Oversold_Level=20.;

double PCR[];

int init()
{
 IndicatorShortName("Percent Retracement");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PCR);

 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);

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
  
  if (Max!=Min)
  {
   PCR[pos]=100.*(1.-(Max-Close[pos])/(Max-Min));
  } 

  pos--;
 } 
 return(0);
}

