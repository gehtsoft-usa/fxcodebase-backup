//+------------------------------------------------------------------+
//|                                                         TOSC.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double TOSC[];
double b0[], b1[];
double Alpha;

int init()
{
 IndicatorShortName("Difference between the recursive trendline value and the exponential moving average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TOSC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,b0);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,b1);
 Alpha=2./(Length+1.);
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
 double Pr;
 double EMA;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   b0[pos]=0;
   b1[pos]=0;
  }
  else
  {
   Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
   b0[pos]=(1-Alpha)*b0[pos+1]+Pr;
   b1[pos]=(1-Alpha)*b1[pos+1]+Alpha*(Pr+b0[pos]-b0[pos+1]);
   EMA=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);
   TOSC[pos]=(b1[pos]-EMA)/Point;
  } 
  pos--;
 } 
 return(0);
}

