//+------------------------------------------------------------------+
//|                                                  Blau_TStoch.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Length=5;
extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Smooth_Length3=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Blau_TStoch[];
double Stoch[], EMA1[], EMA2[];

int init()
{
 IndicatorShortName("William Blau Stochastic");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Blau_TStoch);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Stoch);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,EMA1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,EMA2);

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
 double Min;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Stoch[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-Min;
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  EMA1[pos]=iMAOnArray(Stoch, 0, Smooth_Length1, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  EMA2[pos]=iMAOnArray(EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  Blau_TStoch[pos]=iMAOnArray(EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos)/Point;
  pos--;
 }  
 return(0);
}

