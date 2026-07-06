//+------------------------------------------------------------------+
//|                                         Elsigs_Shifting_Mean.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=5;

double ESM[];

int init()
{
 IndicatorShortName("Elsig_s Shifting Mean");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ESM);

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
 int F;
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  F=Bars-MathFloor((Bars-pos)/Length)*Length;
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, F)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, F)];
  ESM[pos]=(Min+Max)/2.;
  
  pos--;
 } 
 return(0);
}

