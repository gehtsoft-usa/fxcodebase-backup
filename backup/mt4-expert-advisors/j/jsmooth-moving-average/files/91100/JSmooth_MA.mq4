//+------------------------------------------------------------------+
//|                                                   JSmooth_MA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
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

double JSmooth[];
double Pr[], A1[], A2[], A3[], A4[];
double Alpha;
double Alpha2, Alpha12;

int init()
{
 IndicatorShortName("JSmooth Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,JSmooth);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,A1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,A2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,A3);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,A4);
 
 Alpha=0.45*(Length-1.)/(0.45*(Length-1)+2);
 Alpha2=Alpha*Alpha;
 Alpha12=(1-Alpha)*(1-Alpha);
 
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
 
 pos=limit;
 while(pos>=0)
 {
  A1[pos]=(1-Alpha)*Pr[pos]+Alpha*A1[pos+1];
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  A2[pos]=(1-Alpha)*(Pr[pos]-A1[pos])+Alpha*A2[pos+1];
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  A3[pos]=A1[pos]+A2[pos];
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  A4[pos]=(A3[pos]-JSmooth[pos+1])*Alpha12+Alpha2*A4[pos+1];
  JSmooth[pos]=JSmooth[pos+1]+A4[pos];
  pos--;
 }  
 
 return(0);
}

