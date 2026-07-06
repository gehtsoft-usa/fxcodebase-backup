//+------------------------------------------------------------------+
//|                                             Volatility_Ratio.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;

double VR[];

int init()
{
 IndicatorShortName("Volatility Ratio oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VR);

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
 double Min, Max;
 double hl, hc, lc;
 double pr, tr;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  pr=MathMax(Max, Open[pos+Length-1])-MathMin(Min, Open[pos+Length-1]);
  hl=MathAbs(High[pos]-Low[pos]);
  hc=MathAbs(High[pos]-Close[pos+1]);
  lc=MathAbs(Low[pos]-Close[pos+1]);
  tr=MathMax(hl, MathMax(hc, lc));
  if (pr!=0.)
  {
   VR[pos]=tr/pr;
  }
  pos--;
 } 
 return(0);
}

