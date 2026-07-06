//+------------------------------------------------------------------+
//|                                                       Avg_MA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int First_Length=5;
extern string ModeStr="Mode: 0 - Add, 1 - Mult";
extern int Mode=0;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int K=2;
extern int Count_Of_MA=5;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Avg_MA[];

int init()
{
 IndicatorShortName("Average of MA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Avg_MA);

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
 int i;
 double Sum;
 double MA;
 int Count;
 int Length;
 pos=limit;
 while(pos>=0)
 {
  Sum=0.;
  Count=0;
  Length=First_Length;
  for (i=1;i<=Count_Of_MA;i++)
  {
   MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
   if (MA!=0.)
   {
    Sum=Sum+MA;
    Count++;
   } 
   if (Mode==0)
   {
    Length=Length+K;
   }
   else
   {
    Length=Length*K;
   }
  }
  
  if (Count>0)
  {
   Avg_MA[pos]=Sum/Count;
  }

  pos--;
 } 
 return(0);
}

