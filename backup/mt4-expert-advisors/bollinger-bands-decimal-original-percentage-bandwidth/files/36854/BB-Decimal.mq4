//+------------------------------------------------------------------+
//|                                                   BB-Decimal.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

extern int Length=20;
extern double Deviation=2;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Upper[], Middle[], Lower[];

int init()
  {
   IndicatorShortName("BB-Decimal");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Upper);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Middle);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Lower);

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
 double MA, StdDev;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  StdDev=iStdDev(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  Middle[pos]=MA;
  Upper[pos]=MA+Deviation*StdDev;
  Lower[pos]=MA-Deviation*StdDev;
  pos--;
 } 

 return(0);
}

