//+------------------------------------------------------------------+
//|                                                       DEROSC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int RSI_Length=14;
extern int EMA1_Length=5;
extern int EMA2_Length=3;
extern int MVA_Length=9;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double DEROSC[];
double RSI[], EMA1[], EMA2[];

int init()
{
 IndicatorShortName("Derivative Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,DEROSC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,RSI);
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
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSI(NULL, 0, RSI_Length, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  EMA1[pos]=iMAOnArray(RSI, 0, EMA1_Length, 0, MODE_EMA, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  EMA2[pos]=iMAOnArray(EMA1, 0, EMA2_Length, 0, MODE_EMA, pos);

  pos--;
 }

 double MVA;
 pos=limit;
 while(pos>=0)
 {
  MVA=iMAOnArray(EMA2, 0, MVA_Length, 0, MODE_SMA, pos);
  
  DEROSC[pos]=(EMA2[pos]-MVA)/Point;

  pos--;
 }
   
   
 return(0);
}

