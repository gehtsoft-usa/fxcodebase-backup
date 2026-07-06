//+------------------------------------------------------------------+
//|                                                         FTNP.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Fisher[], Trigger[];
double Pr[], V1[];

int init()
{
 IndicatorShortName("Fisher Transform of Normalized Prices");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Fisher);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Trigger);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Pr);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,V1);

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
 
 double MinPr, MaxPr;
 pos=limit;
 while(pos>=0)
 {
  MinPr=Pr[ArrayMinimum(Pr, Length, pos)];
  MaxPr=Pr[ArrayMaximum(Pr, Length, pos)];
  if (MaxPr!=MinPr)
  {
   V1[pos]=0.667*((Pr[pos]-MinPr)/(MaxPr-MinPr)-0.5+V1[pos+1]);
   V1[pos]=MathMin(V1[pos], 0.999);
   V1[pos]=MathMax(V1[pos], -0.999);
   Fisher[pos]=0.5*(MathLog((1.+V1[pos])/(1.-V1[pos]))+Fisher[pos+1]);
   Trigger[pos]=Fisher[pos+1];
  } 

  pos--;
 }
   
 return(0);
}

