//+------------------------------------------------------------------+
//|                                                           UI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;
extern bool Inverse_Pair=false;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double UI[];
double PD[];

int init()
{
 IndicatorShortName("Ulcer index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,UI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,PD);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int index;
 double Max;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  if (Inverse_Pair)
  {
   index=iLowest(NULL, 0, Price, Length, pos);
   Max=1/iMA(NULL, 0, 1, 0, MODE_SMA, Price, index);
   Pr=1/iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  }
  else
  {
   index=iHighest(NULL, 0, Price, Length, pos);
   Max=iMA(NULL, 0, 1, 0, MODE_SMA, Price, index);
   Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  }
  PD[pos]=MathPow((Pr-Max)/Max, 2);
  pos--;
 } 

 double MA;
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(PD, 0, Length, 0, MODE_SMA, pos);
  UI[pos]=MathSqrt(MA)*100;
  pos--;
 }
  
 return(0);
}

