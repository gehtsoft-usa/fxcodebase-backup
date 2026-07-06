//+------------------------------------------------------------------+
//|                                                JB_Volatility.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Gray

extern int Length=20;
extern int ATR_Length=10;
extern double Multiplier=2.;

double Hist_High[], Hist_Low[], Hist_N[];

int init()
{
 IndicatorShortName("JB Volatility");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Hist_High);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Hist_Low);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Hist_N);

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
 double ATR;
 double ATR_M;
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, ATR_Length, pos);
  ATR_M=ATR*Multiplier;
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  
  Hist_High[pos]=0.;
  Hist_Low[pos]=0.;
  Hist_N[pos]=0.;
  
  if (Close[pos]>Min+ATR_M)
  {
   Hist_High[pos]=1.;
  }
  else
  {
   if (Close[pos]<Max-ATR_M)
   {
    Hist_Low[pos]=1.;
   }
   else
   {
    Hist_N[pos]=1.;
   }
  }

  pos--;
 } 
 return(0);
}

