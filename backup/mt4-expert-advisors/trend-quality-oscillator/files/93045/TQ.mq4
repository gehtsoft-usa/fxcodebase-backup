//+------------------------------------------------------------------+
//|                                                           TQ.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Fast_Length=7;
extern int Slow_Length=14;
extern int Scalar_Trend_Length=5;
extern int Scalar_Nise_Length=250;
extern int Scalar_Correction_Factor=2;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double TQ[], TQ_DN[], T[];
double Reversals[], CPC[], Trend[], DT[];

int init()
{
 IndicatorShortName("Trend Quality oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,TQ);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,TQ_DN);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,T);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Reversals);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,CPC);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Trend);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,DT);

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
 double Fast_EMA, Slow_EMA;
 double DC;
 double Pr0, Pr1;
 
 pos=limit;
 while(pos>=0)
 {
  Fast_EMA=iMA(NULL, 0, Fast_Length, 0, MODE_EMA, Price, pos);
  Slow_EMA=iMA(NULL, 0, Slow_Length, 0, MODE_EMA, Price, pos);
  if (Fast_EMA>Slow_EMA)
  {
   T[pos]=1.;
  }
  else
  {
   T[pos]=-1.;
  }
  Reversals[pos]=Fast_EMA-Slow_EMA;
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  DC=Pr0-Pr1;
  if (Reversals[pos]*Reversals[pos+1]<=0.)
  {
   CPC[pos]=0.;
   Trend[pos]=0.;
  }
  else
  {
   CPC[pos]=CPC[pos+1]+DC;
   Trend[pos]=CPC[pos]/(0.+Scalar_Trend_Length)+Trend[pos+1]*(1.-1./(0.+Scalar_Trend_Length));
  }
  DT[pos]=(CPC[pos]-Trend[pos])*(CPC[pos]-Trend[pos]);
  
  pos--;
 } 

 double Average;
 double Noise;
 pos=limit;
 while(pos>=0)
 {
  Average=iMAOnArray(DT, 0, Scalar_Nise_Length, 0, MODE_SMA, pos);
  Noise=MathSqrt(Average);
  if (Noise!=0.)
  {
   TQ[pos]=Scalar_Correction_Factor*Trend[pos]/Noise;
  }
  if (TQ[pos]<TQ[pos+1]) 
  {
   TQ_DN[pos]=TQ[pos];
  }
  else
  {
   TQ_DN[pos]=EMPTY_VALUE;
  }
  
  pos--;
 }
   
 return(0);
}

