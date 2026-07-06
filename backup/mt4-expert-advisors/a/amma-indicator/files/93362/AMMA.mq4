//+------------------------------------------------------------------+
//|                                                         AMMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=15;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double AMMA[];

int init()
{
 IndicatorShortName("AMMA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,AMMA);

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
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   AMMA[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  }
  else
  {
   AMMA[pos]=(AMMA[pos+1]*(Length-2)+2.*iMA(NULL, 0, 2, 0, MODE_SMA, Price, pos))/Length;
  }
  
  pos--;
 } 
 return(0);
}

