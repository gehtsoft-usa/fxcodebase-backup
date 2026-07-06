//+------------------------------------------------------------------+
//|                                                 Period_Above.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double PA[], PA_Dn[];

int init()
{
 IndicatorShortName("Period Above oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,PA);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,PA_Dn);

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
 double Pr0, Pr1, MA0, MA1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  MA0=iMA(NULL, 0, Length, 0, Method, Price, pos);
  MA1=iMA(NULL, 0, Length, 0, Method, Price, pos+1);
  
  if (Pr0>MA0)
  {
   PA[pos]=PA[pos+1]+1.;
  }
  else
  {
   PA[pos]=PA[pos+1]-1.;
  }
  
  if (Pr0>MA0 && Pr1<MA1)
  {
   PA[pos]=1.;
  }
  else
  {
   if (Pr0<MA0 && Pr1>MA1)
   {
    PA[pos]=-1.;
   }
  }
  
  if (PA[pos]<0.)
  {
   PA_Dn[pos]=PA[pos];
  }
  else
  {
   PA_Dn[pos]=0.;
  }

  pos--;
 } 
 return(0);
}

