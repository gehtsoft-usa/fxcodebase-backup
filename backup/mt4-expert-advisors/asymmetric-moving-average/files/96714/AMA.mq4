//+------------------------------------------------------------------+
//|                                                          AMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

extern int Before=7;
extern int Forward=7;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

double AMA[];

int init()
  {
   IndicatorShortName("Asymmetric moving average");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,AMA);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 double Sum, Count;
 int i;
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int    pos=Bars-2-Before;
 if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
 while(pos>0)
 {
  Sum=0;
  Count=0;
  for (i=pos+Before;i>pos-Forward;i--)
  {
   if (i>=0)
   {
    Sum=Sum+iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
    Count++;
   }
  }
  if (Count>0) AMA[pos]=Sum/Count; else AMA[pos]=EMPTY_VALUE;
  pos--;
 }  

 return(0);
}

