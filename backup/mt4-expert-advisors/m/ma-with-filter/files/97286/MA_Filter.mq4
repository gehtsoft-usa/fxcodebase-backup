//+------------------------------------------------------------------+
//|                                                    MA_Filter.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red

extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Length=20;
extern int Shift=1;
extern int MinDiff=10;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double MA[], MA_Up[], MA_Dn[];
double MinDiffPips;

int init()
{
 IndicatorShortName("MA with filter");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,MA_Up);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,MA_Dn);
 
 MinDiffPips=MinDiff*Point;

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
  MA[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
  
  if (MA[pos]>MA[pos+Shift] && MathAbs(MA[pos]-MA[pos+Shift])>=MinDiffPips)
  {
   MA_Up[pos]=MA[pos];
   MA_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   if (MA[pos]<MA[pos+Shift] && MathAbs(MA[pos]-MA[pos+Shift])>=MinDiffPips)
   {
    MA_Up[pos]=EMPTY_VALUE;
    MA_Dn[pos]=MA[pos];
   }
   else
   {
    MA_Up[pos]=EMPTY_VALUE;
    MA_Dn[pos]=EMPTY_VALUE;
   }
  }

  pos--;
 } 
 return(0);
}

