//+------------------------------------------------------------------+
//|                                                     FX_Trend.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Short_Length=7;
extern int Mid_Length=14;
extern int Long_Length=28;

double FXT[];
double Const;

int init()
{
 IndicatorShortName("FX Trend oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,FXT);
 
 Const=100./(1./Short_Length+1./Mid_Length+1./Long_Length);

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
 double ll1, hh1, ll2, hh2, ll3, hh3;
 double diff1, diff2, diff3;
 pos=limit;
 while(pos>=0)
 {
  ll1=Low[iLowest(NULL, 0, MODE_LOW, Short_Length, pos)];
  hh1=High[iHighest(NULL, 0, MODE_HIGH, Short_Length, pos)];
  ll2=Low[iLowest(NULL, 0, MODE_LOW, Mid_Length, pos)];
  hh2=High[iHighest(NULL, 0, MODE_HIGH, Mid_Length, pos)];
  ll3=Low[iLowest(NULL, 0, MODE_LOW, Long_Length, pos)];
  hh3=High[iHighest(NULL, 0, MODE_HIGH, Long_Length, pos)];
  
  diff1=hh1-ll1;
  diff2=hh2-ll2;
  diff3=hh3-ll3;
  
  FXT[pos]=Const*((Close[pos]-ll1)/(diff1*Short_Length)+(Close[pos]-ll2)/(diff2*Mid_Length)+(Close[pos]-ll3)/(diff3*Long_Length));

  pos--;
 } 
 return(0);
}

