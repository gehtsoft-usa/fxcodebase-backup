//+------------------------------------------------------------------+
//|                                                       ZScore.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 Red

extern int Length=20;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double ZScore[];

int init()
  {
   IndicatorShortName("ZScore");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ZScore);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double StdDev;
 while(pos>=0)
 {
  StdDev=iStdDev(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  if (StdDev!=0)
  {
   ZScore[pos]=(iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos))/StdDev;
  }
  else
  {
   ZScore[pos]=EMPTY_VALUE;
  }
  pos--;
 } 

 return(0);
}

