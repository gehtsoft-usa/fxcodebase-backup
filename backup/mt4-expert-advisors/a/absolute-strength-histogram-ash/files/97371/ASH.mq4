//+------------------------------------------------------------------+
//|                                                          ASH.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red

extern string ModeStr="Mode: 0 - RSI, 1 - Stoch";
extern int Mode=0;  // 0 - RSI, 1 - Stoch
extern int Length=9;
extern int Smooth_Length=2;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA


double BullsOut[], BearsOut[];
double Bulls[], Bears[], AvgBulls[], AvgBears[];

int init()
{
 IndicatorShortName("Absolute Strength oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,BullsOut);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,BearsOut);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Bulls);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Bears);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,AvgBulls);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,AvgBears);

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
 double smax, smin;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  
  if (Mode==0)
  {
   Bulls[pos]=0.5*MathAbs(Pr0-Pr1)+Pr0-Pr1;
   Bears[pos]=0.5*MathAbs(Pr0-Pr1)-Pr0+Pr1;
  }
  else
  {
   smax=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
   smin=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
   Bulls[pos]=Pr0-smin;
   Bears[pos]=smax-Pr0;
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  AvgBulls[pos]=iMAOnArray(Bulls, 0, Length, 0, Method, pos);
  AvgBears[pos]=iMAOnArray(Bears, 0, Length, 0, Method, pos);

  pos--;
 }
 
 double SmoothBulls, SmoothBears;
 pos=limit;
 while(pos>=0)
 {
  SmoothBulls=iMAOnArray(AvgBulls, 0, Smooth_Length, 0, Method, pos);
  SmoothBears=iMAOnArray(AvgBears, 0, Smooth_Length, 0, Method, pos);
  
  BullsOut[pos]=SmoothBulls/Point;
  BearsOut[pos]=SmoothBears/Point;

  pos--;
 }  
   
 return(0);
}

