//+------------------------------------------------------------------+
//|                                         Deviation_Oscillator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length1=40;
extern int Length2=80;
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

double DO[];
double PD[];

int init()
{
 IndicatorShortName("Deviation oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DO);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,PD);

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
 double Pr, MA;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  MA=iMA(NULL, 0, Length1, 0, Method, Price, pos);
  
  PD[pos]=Pr-MA;

  pos--;
 } 
 
 double Min, Max, nf;
 pos=limit;
 while(pos>=0)
 {
  Min=PD[ArrayMinimum(PD, Length2, pos)];
  Max=PD[ArrayMaximum(PD, Length2, pos)];
  
  if (Min!=Max)
  {
   nf=200./(Max-Min);
   
   DO[pos]=nf*(PD[pos]-Min)-100.;
  }

  pos--;
 }
   
 return(0);
}

