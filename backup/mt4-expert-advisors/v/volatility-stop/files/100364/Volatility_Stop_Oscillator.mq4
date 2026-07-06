//+------------------------------------------------------------------+
//|                                   Volatility_Stop_Oscillator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern double Multiplier=2.;
extern int Length=20;

double VS[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VS);

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

 double HiLoAvg;
 pos=limit;
 while(pos>=0)
 {
  HiLoAvg=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_HIGH, pos)-iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_LOW, pos);
  
  if (Close[pos]!=0.)
  {
   VS[pos]=Multiplier*HiLoAvg/Close[pos];
  } 

  pos--;
 }
   
 return(0);
}

