//+------------------------------------------------------------------+
//|                                              Trend_Component.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define Pi 3.1415926

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=11;
extern double Delta=0.05;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double Alpha, Beta, Gamma;

double TC[];
double bp[];

int init()
{
 IndicatorShortName("Trend Component");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,bp);
 Beta=MathCos(2.*Pi/Length);
 Gamma=1./MathCos(4.*Pi*Delta/Length);
 Alpha=Gamma*MathSqrt(Gamma*Gamma-1.);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=2*Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Pr0, Pr2;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr2=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+2);
  bp[pos]=0.5*(1.-Alpha)*(Pr0-Pr2)+Beta*(1.+Alpha)*bp[pos+1]-Alpha*bp[pos+2];
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  TC[pos]=iMAOnArray(bp, 0, 2.*Length+1, 0, MODE_SMA, pos)*(2.*Length+1);
  
  pos--;
 }
   
 return(0);
}

