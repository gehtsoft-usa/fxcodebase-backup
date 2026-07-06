//+------------------------------------------------------------------+
//|                                         Directional_Breakout.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Red

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
extern int Length=20;

double UP[], N1[], N2[], DN[];

int init()
{
 IndicatorShortName("Directional Breakout");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,N1);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,N2);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,DN);

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
 double MA;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
  UP[pos]=EMPTY_VALUE;
  N1[pos]=EMPTY_VALUE;
  N2[pos]=EMPTY_VALUE;
  DN[pos]=EMPTY_VALUE;
  
  if (Low[pos]>MA)
  {
   UP[pos]=2.;
  }
  else
  {
   if (High[pos]<MA)
   {
    DN[pos]=-2.;
   }
   else
   {
    N1[pos]=1.;
    N2[pos]=-1.;
   }
  }

  pos--;
 } 
 return(0);
}

