//+------------------------------------------------------------------+
//|                                                MA_Difference.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern bool Show_MA1_Price_Diff=true;
extern bool Show_MA2_Price_Diff=true;
extern bool Show_MA1_MA2_Diff=true;
extern int MA1_Period=14;
extern int MA1_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA2_Period=14;
extern int MA2_Method=1;  // 0 - SMA
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
extern bool UseAbsoluteDiff=true;                         


double Buff1[], Buff2[], Buff3[];

int init()
{
 IndicatorShortName("MA difference");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Buff1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Buff2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Buff3);

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
 double Pr, MA1, MA2;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  MA1=iMA(NULL, 0, MA1_Period, 0, MA1_Method, Price, pos);
  MA2=iMA(NULL, 0, MA2_Period, 0, MA2_Method, Price, pos);
  if (Show_MA1_Price_Diff)
  {
   if (UseAbsoluteDiff)
   {
    Buff1[pos]=MathAbs(MA1-Pr)/Point;
   }
   else
   {
    Buff1[pos]=(MA1-Pr)/Point;
   }
  } 
  if (Show_MA2_Price_Diff)
  {
   if (UseAbsoluteDiff)
   {
    Buff2[pos]=MathAbs(MA2-Pr)/Point;
   }
   else
   {
    Buff2[pos]=(MA2-Pr)/Point;
   }
  } 
  if (Show_MA1_MA2_Diff)
  {
   if (UseAbsoluteDiff)
   {
    Buff3[pos]=MathAbs(MA1-MA2)/Point;
   }
   else
   {
    Buff3[pos]=(MA1-MA2)/Point;
   }
  }
  pos--;
 } 
 return(0);
}

