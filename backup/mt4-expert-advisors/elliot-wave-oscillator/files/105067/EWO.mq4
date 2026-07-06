//+------------------------------------------------------------------+
//|                                                          EWO.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 LightGreen
#property indicator_color2 Green
#property indicator_color3 DarkRed
#property indicator_color4 Red

extern int Fast_MA_Length=5;
extern int Slow_MA_Length=35;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Smoothing_Method=0;  // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA

double UG[], UF[], LG[], LF[];
double EWO[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UG);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,UF);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,LG);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,LF);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,EWO);

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
 double FMA, SMA;
 pos=limit;
 while(pos>=0)
 {
  FMA=iMA(NULL, 0, Fast_MA_Length, 0, Smoothing_Method, Price, pos);
  SMA=iMA(NULL, 0, Slow_MA_Length, 0, Smoothing_Method, Price, pos);
  
  EWO[pos]=FMA-SMA;
  UG[pos]=0.;
  UF[pos]=0.;
  LG[pos]=0.;
  LF[pos]=0.;
  
  if (EWO[pos]>=0.)
  {
   if (EWO[pos]>EWO[pos+1])
   {
    UG[pos]=EWO[pos];
   }
   else
   {
    UF[pos]=EWO[pos];
   }
  }
  else
  {
   if (EWO[pos]>EWO[pos+1])
   {
    LG[pos]=EWO[pos];
   }
   else
   {
    LF[pos]=EWO[pos];
   }
  }

  pos--;
 } 
 return(0);
}

