//+------------------------------------------------------------------+
//|                                                          NMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double NMA[];
double Pr[];

int init()
{
 IndicatorShortName("Navel MA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,NMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);

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
  Pr[pos]=(5.*Close[pos]+2.*Open[pos]+High[pos]+Low[pos])/9.;

  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  NMA[pos]=iMAOnArray(Pr, 0, Length, 0, Method, pos);

  pos--;
 } 
 return(0);
}

