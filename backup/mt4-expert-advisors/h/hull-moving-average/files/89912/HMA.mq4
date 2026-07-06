//+------------------------------------------------------------------+
//|                                                          HMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double HMA[];
double St[];

int L2, SqrtL;

int init()
{
 IndicatorShortName("Hull Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,HMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,St);
 
 L2=MathFloor((Length+0.)/2.);
 SqrtL=MathFloor(MathSqrt(Length))-1; 
 
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
 pos=limit;
 while(pos>=0)
 {
  St[pos]=2*iMA(NULL, 0, L2, 0, MODE_LWMA, Price, pos)-iMA(NULL, 0, Length, 0, MODE_LWMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  HMA[pos]=iMAOnArray(St, 0, SqrtL, 0, MODE_LWMA, pos);
  pos--;
 }  
 
 return(0);
}

