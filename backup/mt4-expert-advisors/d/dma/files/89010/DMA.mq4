//+------------------------------------------------------------------+
//|                                                          DMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=17;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double DMA[];
double Pr[];

int init()
{
 IndicatorShortName("DMA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DMA);
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
 if(Bars<=Length) return(0);
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
 
 int i;
 double A, B, C, D, E;
 pos=limit;
 while(pos>=0)
 {
  A=Pr[pos]-Pr[pos+Length-1];
  B=0;
  for (i=pos;i<pos+Length;i++)
  {
   B=B+MathAbs(Pr[i]-Pr[i+1]);
  }
  if (B==0) B=0.00001;
  C=A/B;
  D=C*(2./31.)+(1-C)*(2./3.);
  E=D*D;
  DMA[pos]=E*Pr[pos]+(1-E)*DMA[pos+1];
  pos--;
 }  
 return(0);
}

