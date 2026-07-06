//+------------------------------------------------------------------+
//|                                                          APR.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern string Description="1-M1, 5-M5, 15-M15, 30-M30, 60-H1, 240-H4, 1440-D1, 10080-W1, 43200-MN";
extern int TimeFrame=1440;
extern int Length=5;
extern bool Use_High_Low=true;
extern bool Absolute=true;

double APR[];

int init()
{
 IndicatorShortName("Average Period Range");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,APR);

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
 int index;
 int i;
 double Sum;
 pos=limit;
 while(pos>=0)
 {
  index=iBarShift(NULL, TimeFrame, Time[pos], false);
  Sum=0;
  for (i=0;i<Length;i++)
  {
   if (Use_High_Low)
   {
    Sum=Sum+iHigh(NULL, TimeFrame, index+i)-iLow(NULL, TimeFrame, index+i);
   }
   else
   {
    Sum=Sum+MathAbs(iOpen(NULL, TimeFrame, index+i)-iClose(NULL, TimeFrame, index+i));
   }
  }
  if (Absolute)
  {
   APR[pos]=Sum/Length;
  }
  else
  {
   APR[pos]=100*Sum/(Length*iOpen(NULL, TimeFrame, index));
  }
  pos--;
 } 
 return(0);
}

