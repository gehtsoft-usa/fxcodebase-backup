//+------------------------------------------------------------------+
//|                                                       ADX_MA.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int ADX_Length=10;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 
extern int MA_Length=14;                       
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA

double ADX_MA[];
double ADX[];

int init()
{
 IndicatorShortName("MA of ADX");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ADX_MA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,ADX);

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
  ADX[pos]=iADX(NULL, 0, ADX_Length, Price, MODE_MAIN, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  ADX_MA[pos]=iMAOnArray(ADX, 0, MA_Length, 0, MA_Method, pos);

  pos--;
 }
   
 return(0);
}

