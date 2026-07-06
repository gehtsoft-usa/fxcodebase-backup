//+------------------------------------------------------------------+
//|                                       Accelerator_Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Fast_Length=5;
extern int Slow_Length=34;
extern int Smooth_Length=5;
extern int Method=0;     // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
                         
extern int Price=4;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double AC[], AC_DN[];
double AO[];

int init()
{
 IndicatorShortName("Accelerator oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,AC);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,AC_DN);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,AO);

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
 double Fast_MA, Slow_MA;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Fast_MA=iMA(NULL, 0, Fast_Length, 0, Method, Price, pos);
  Slow_MA=iMA(NULL, 0, Slow_Length, 0, Method, Price, pos);
  AO[pos]=(Fast_MA-Slow_MA)/10;

  pos--;
 } 
 
 double Smooth_AO;
 pos=limit;
 while(pos>=0)
 {
  Smooth_AO=iMAOnArray(AO, 0, Smooth_Length, 0, Method, pos);
  AC[pos]=(AO[pos]-Smooth_AO)*10;
  if (AC[pos]<AC[pos+1])
  {
   AC_DN[pos]=AC[pos];
  }
  else
  {
   AC_DN[pos]=EMPTY_VALUE;
  }
  pos--;
 }
   
 return(0);
}

