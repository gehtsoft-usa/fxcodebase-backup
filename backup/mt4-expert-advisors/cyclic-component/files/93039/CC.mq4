//+------------------------------------------------------------------+
//|                                                           CC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double CC[];
double HP[];
double alpha;
double pi=3.1415926535;

int init()
{
 IndicatorShortName("Cyclic Component oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,HP);
 
 alpha=(1.-MathSin(2.*pi/Length))/MathCos(2.*pi/Length);
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
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  HP[pos]=0.5*(1.+alpha)*(Pr0-Pr1)+alpha*HP[pos+1];
  CC[pos]=(HP[pos]+2.*HP[pos+1]+2.*HP[pos+2]+HP[pos+3])/6.;
  pos--;
 } 
 return(0);
}

