//+------------------------------------------------------------------+
//|                                                          TAI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int MA_Length=28;
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int TAI_Length=5;                         
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double TAI[];
double MA[];

int init()
{
 IndicatorShortName("Trend Analysis Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TAI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,MA);

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
  MA[pos]=iMA(NULL, 0, MA_Length, 0, MA_Method, Price, pos);

  pos--;
 } 
 
 double MAMin, MAMax;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  MAMin=MA[ArrayMinimum(MA, TAI_Length, pos)];
  MAMax=MA[ArrayMaximum(MA, TAI_Length, pos)];
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  if (Pr!=0.)
  {
   TAI[pos]=(MAMax-MAMin)/(Pr*Point);
  }
  else
  {
   TAI[pos]=EMPTY_VALUE;
  }

  pos--;
 }
   
 return(0);
}

