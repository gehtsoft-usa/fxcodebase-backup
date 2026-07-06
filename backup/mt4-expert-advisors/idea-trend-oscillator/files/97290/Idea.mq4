//+------------------------------------------------------------------+
//|                                                         Idea.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=20;
extern double Level=1.;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double Idea[], Idea_Dn[];

int init()
{
 IndicatorShortName("Idea oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Idea);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Idea_Dn);

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
 double MA_H, MA_L, MA_C;
 pos=limit;
 while(pos>=0)
 {
  MA_H=iMA(NULL, 0, Length, 0, Method, PRICE_HIGH, pos);
  MA_L=iMA(NULL, 0, Length, 0, Method, PRICE_LOW, pos);
  MA_C=iMA(NULL, 0, Length, 0, Method, PRICE_CLOSE, pos);
  
  if (MA_C!=MA_L)
  {
   Idea[pos]=(MA_H-MA_C)/(MA_C-MA_L);
  }
  
  if (Idea[pos]<Level)
  {
   Idea_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   Idea_Dn[pos]=Idea[pos];
  }

  pos--;
 } 
 return(0);
}

