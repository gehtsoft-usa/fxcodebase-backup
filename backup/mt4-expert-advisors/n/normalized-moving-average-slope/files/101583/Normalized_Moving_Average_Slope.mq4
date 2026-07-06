//+------------------------------------------------------------------+
//|                              Normalized_Moving_Average_Slope.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int MA_Price=0;    // Applied price
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
extern int ATR_Length=14;

double NMAS[];

int init()
{
 IndicatorShortName("Normalized Moving Average Slope");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,NMAS);

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
 double ATR, MA, MA1;
 pos=limit;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, ATR_Length, pos);
  MA=iMA(NULL, 0, MA_Length, 0, MA_Method, MA_Price, pos);
  MA1=iMA(NULL, 0, MA_Length, 0, MA_Method, MA_Price, pos+1);
  
  if (ATR!=0.)
  {
   NMAS[pos]=100.*(MA-MA1)/ATR;
  } 

  pos--;
 } 
 return(0);
}

