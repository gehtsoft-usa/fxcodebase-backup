//+------------------------------------------------------------------+
//|                                                   Cutler_RSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted
extern double Overbought_Level=80;
extern double Oversold_Level=20;                        
extern int LevelWidth=1;
extern color LevelColor=Gray;                        

double C_RSI[];
double positive[], negative[];

int init()
{
 IndicatorShortName("Cutler RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,C_RSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,positive);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,negative);
 SetLevelValue(0, 50);
 SetLevelValue(1, Overbought_Level);
 SetLevelValue(2, Oversold_Level);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);
 

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
 double Pr0, Pr1;
 double diff;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  diff=Pr0-Pr1;
  if (diff>0.)
  {
   positive[pos]=diff;
   negative[pos]=0.;
  }
  else
  {
   positive[pos]=0.;
   negative[pos]=-diff;
  }

  pos--;
 } 
 
 double P, N;
 pos=limit;
 while(pos>=0)
 {
  P=iMAOnArray(positive, 0, Length, 0, Method, pos);
  N=iMAOnArray(negative, 0, Length, 0, Method, pos);
  if (N==0.)
  {
   C_RSI[pos]=0.;
  }
  else
  {
   C_RSI[pos]=100.-(100./(1.+P/N));
  }

  pos--;
 }
   
 return(0);
}

