//+------------------------------------------------------------------+
//|                                            Smoothed_Momentum.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Momentum_Length=12;
extern bool Use_Smoothing=true;
extern int Smoothing_Method=0;  // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Smoothing_Length=20;                                
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double SM[];
double Momentum[];

int init()
{
 IndicatorShortName("Smoothed Momentum");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SM);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Momentum);

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
 double Pr, Pr2;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr2=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Momentum_Length);
  
  if (Pr2!=0.)
  {
   Momentum[pos]=100.*Pr/Pr2;
  } 

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Use_Smoothing)
  {
   SM[pos]=iMAOnArray(Momentum, 0, Smoothing_Length, 0, Smoothing_Method, pos);
  }
  else
  {
   SM[pos]=Momentum[pos];
  }

  pos--;
 }
   
 return(0);
}

