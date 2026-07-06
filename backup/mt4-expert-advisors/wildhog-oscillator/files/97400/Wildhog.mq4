//+------------------------------------------------------------------+
//|                                                      Wildhog.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=8;
extern double Overbought_Level=60.;
extern double Oversold_Level=40.;

double Wildhog[];

int init()
{
 IndicatorShortName("Wildhog");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Wildhog);
 
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
   Wildhog[pos]=100.*(Close[pos]-Min)/(3.*(Max-Min))+Wildhog[pos+1]/1.5;
  } 

  pos--;
 } 
 return(0);
}

