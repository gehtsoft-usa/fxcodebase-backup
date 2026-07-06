//+------------------------------------------------------------------+
//|                                                         Pain.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=10;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double Pain[];

int init()
{
 IndicatorShortName("Pain oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Pain);

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
 double MA_O, MA_H, MA_L, MA_C;
 pos=limit;
 while(pos>=0)
 {
  MA_O=iMA(NULL, 0, Length, 0, Method, PRICE_OPEN, pos);
  MA_H=iMA(NULL, 0, Length, 0, Method, PRICE_HIGH, pos);
  MA_L=iMA(NULL, 0, Length, 0, Method, PRICE_LOW, pos);
  MA_C=iMA(NULL, 0, Length, 0, Method, PRICE_CLOSE, pos);
  
  Pain[pos]=(3.*MA_C-MA_O-MA_H-MA_L)/2.;

  pos--;
 } 
 return(0);
}

