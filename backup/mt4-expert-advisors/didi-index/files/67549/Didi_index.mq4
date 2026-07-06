//+------------------------------------------------------------------+
//|                                                   Didi_index.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

extern int Curta_Length=3;
extern int Media_Length=8;
extern int Longa_Length=20;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Curta[], Media[], Longa[];

int init()
{
 IndicatorShortName("Didi index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Curta);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Media);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Longa);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=2) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double M_MA;
 while(pos>=0)
 {
  M_MA=iMA(NULL, 0, Media_Length, 0, Method, Price, pos);
  if (M_MA>0)
  {
   Curta[pos]=iMA(NULL, 0, Curta_Length, 0, Method, Price, pos)/M_MA;
   Media[pos]=1;
   Longa[pos]=iMA(NULL, 0, Longa_Length, 0, Method, Price, pos)/M_MA;
  } 
  pos--;
 } 

 return(0);
}

