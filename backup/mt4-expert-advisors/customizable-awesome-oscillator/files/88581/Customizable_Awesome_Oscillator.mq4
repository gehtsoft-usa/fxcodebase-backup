//+------------------------------------------------------------------+
//|                              Customizable_Awesome_Oscillator.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Fast_Length=5;
extern int Slow_Length=35;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double UpBuff[], DnBuff[];
int MaxLength;

int init()
{
 IndicatorShortName("Customizable Awesome Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UpBuff);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DnBuff);
 MaxLength=MathMax(Fast_Length, Slow_Length);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=MaxLength) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  UpBuff[pos]=iMA(NULL, 0, Fast_Length, 0, Method, Price, pos)-iMA(NULL, 0, Slow_Length, 0, Method, Price, pos);
  if (UpBuff[pos]<UpBuff[pos+1])
  {
   DnBuff[pos]=UpBuff[pos];
  }
  else
  {
   DnBuff[pos]=EMPTY_VALUE;
  }
  pos--;
 } 
 return(0);
}

