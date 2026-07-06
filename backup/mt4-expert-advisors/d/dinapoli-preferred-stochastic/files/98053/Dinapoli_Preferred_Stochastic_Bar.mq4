//+------------------------------------------------------------------+
//|                            Dinapoli_Preferred_Stochastic_Bar.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int K_Length=10;
extern int D_Slowing=5;
extern int D_Length=5;

double K[], D[];

int init()
{
 IndicatorShortName("Dinapoli Preferred Stochastic");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,D);

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
 double FastK;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, K_Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, K_Length, pos)];
  
  if (Max!=Min)
  {
   FastK=100.*(Close[pos]-Min)/(Max-Min);
   K[pos]=K[pos+1]+(FastK-K[pos+1])/D_Slowing;
   
   D[pos]=D[pos+1]+(K[pos]-D[pos+1])/D_Length;
  }

  pos--;
 }
   
 return(0);
}

