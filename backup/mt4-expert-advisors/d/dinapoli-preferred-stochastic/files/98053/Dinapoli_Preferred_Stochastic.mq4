//+------------------------------------------------------------------+
//|                                Dinapoli_Preferred_Stochastic.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int K_Length=10;
extern int D_Slowing=5;
extern int D_Length=5;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double K[], D[];
double Pr[];

int init()
{
 IndicatorShortName("Dinapoli Preferred Stochastic");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,D);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Pr);

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
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 double FastK;
 pos=limit;
 while(pos>=0)
 {
  Min=Pr[ArrayMinimum(Pr, K_Length, pos)];
  Max=Pr[ArrayMaximum(Pr, K_Length, pos)];
  
  if (Max!=Min)
  {
   FastK=100.*(Pr[pos]-Min)/(Max-Min);
   K[pos]=K[pos+1]+(FastK-K[pos+1])/D_Slowing;
   
   D[pos]=D[pos+1]+(K[pos]-D[pos+1])/D_Length;
  }

  pos--;
 }
   
 return(0);
}

