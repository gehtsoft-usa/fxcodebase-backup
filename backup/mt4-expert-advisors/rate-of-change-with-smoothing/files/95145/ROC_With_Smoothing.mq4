//+------------------------------------------------------------------+
//|                                           ROC_With_Smoothing.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Method1=0;      // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA
extern int Length1=16;
extern int Method2=0;      // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA
extern int Length2=16;
extern int ROC_Length=16;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double SROC[];
double Inp[], ROC[];

int init()
{
 IndicatorShortName("Rate of Change with Smoothing");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SROC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Inp);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,ROC);

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
  Inp[pos]=iMA(NULL, 0, Length1, 0, Method1, Price, pos);

  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  if (Inp[pos+ROC_Length]!=0.)
  {
   ROC[pos]=(Inp[pos]/Inp[pos+ROC_Length]-1.)*100.;
  }
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  SROC[pos]=iMAOnArray(ROC, 0, Length2, 0, Method2, pos);

  pos--;
 } 
 
 return(0);
}

