//+------------------------------------------------------------------+
//|                                                         PWMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;
extern double Power=2.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double PWMA[];
double Pr[];

int init()
{
 IndicatorShortName("Power weighted moving average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PWMA);
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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 double Sum1, Sum2;
 int i;
 pos=limit;
 while(pos>=0)
 {
  Sum1=0.;
  Sum2=0.;
  for (i=0;i<Length;i++)
  {
   Sum1=Sum1+Pr[pos+i]*MathPow(Length-i, Power);
   Sum2=Sum2+MathPow(Length-i, Power);
  }
  
  if (Sum2!=0.)
  {
   PWMA[pos]=Sum1/Sum2;
  }
  else
  {
   PWMA[pos]=EMPTY_VALUE;
  }

  pos--;
 }
   
 return(0);
}

