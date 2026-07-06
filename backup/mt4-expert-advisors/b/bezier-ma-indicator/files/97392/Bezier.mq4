//+------------------------------------------------------------------+
//|                                                       Bezier.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=8;
extern double Sensitivity=0.5;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Bezier[];
double Pr[];
double Fact[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Bezier);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);
 
 ArrayResize(Fact, Length+1);
 int i;
 Fact[0]=1.;
 for (i=1;i<=Length;i++)
 {
  Fact[i]=Fact[i-1]*i;
 }

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
 int i;
 double Sum;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
 
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  Sum=0.;
  for (i=Length;i>=0;i--)
  {
   Sum=Sum+Pr[pos+i]*(Fact[Length]/(Fact[i]*Fact[Length-i]))*MathPow(Sensitivity, i)*MathPow(1.-Sensitivity, Length-i);
  }
  
  Bezier[pos]=Sum;

  pos--;
 } 
 return(0);
}

