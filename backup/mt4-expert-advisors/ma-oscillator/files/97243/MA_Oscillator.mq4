//+------------------------------------------------------------------+
//|                                                MA_Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Length=20;
extern int Method=0;  // 0 - SMA
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

double MAO[], MAO_Dn[];

int init()
{
 IndicatorShortName("MA Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,MAO);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,MAO_Dn);

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
 double MA;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  
  if (MA!=0.)
  {
   MAO[pos]=Pr/MA-1.;
  }
  
  if (MAO[pos]>MAO[pos+1])
  {
   MAO_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   MAO_Dn[pos]=MAO[pos];
  }

  pos--;
 } 
 
 return(0);
}

