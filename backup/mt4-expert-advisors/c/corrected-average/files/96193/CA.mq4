//+------------------------------------------------------------------+
//|                                                           CA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double CA[];

int init()
{
 IndicatorShortName("Corrected Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CA);

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
 double MA, StdDev;
 double StdDev2, diff2, k;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
  StdDev=iStdDev(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  StdDev2=StdDev*StdDev;
  diff2=(CA[pos+1]-MA)*(CA[pos+1]-MA);
  if (diff2>StdDev2 && diff2!=0.)
  {
   k=1.-StdDev2/diff2;
  }
  else
  {
   k=0.;
  }
  
  CA[pos]=CA[pos+1]+k*(MA-CA[pos+1]);

  pos--;
 } 
 return(0);
}

