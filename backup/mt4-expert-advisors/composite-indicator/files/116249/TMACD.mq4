//+------------------------------------------------------------------+
//|                                                        TMACD.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Fast_Length=7;
extern int Slow_Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double TMACD[];
double F_WMA[], S_WMA[];
int len_F, len_S;

int init()
{
 IndicatorShortName("Triangular Moving Average Convergence/Divergence");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,TMACD);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,F_WMA);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,S_WMA);
 
 len_F=MathFloor(Fast_Length/2)+1;
 len_S=MathFloor(Slow_Length/2)+1;

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
  F_WMA[pos]=iMA(NULL, 0, len_F, 0, MODE_SMA, Price, pos)*Point;
  S_WMA[pos]=iMA(NULL, 0, len_S, 0, MODE_SMA, Price, pos)*Point;

  pos--;
 } 
 
 double F_TMA, S_TMA;
 pos=limit;
 while(pos>=0)
 {
  F_TMA=iMAOnArray(F_WMA, 0, len_F, 0, MODE_SMA, pos);
  S_TMA=iMAOnArray(S_WMA, 0, len_S, 0, MODE_SMA, pos);
  
  TMACD[pos]=(F_TMA-S_TMA)/Point;

  pos--;
 }
   
 return(0);
}

