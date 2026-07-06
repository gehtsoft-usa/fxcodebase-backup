//+------------------------------------------------------------------+
//|                                          Stochastic_Momentum.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=13;
extern int Signal_Length=3;
extern int Signal_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern bool Use_Smoothing=true;
extern int First_Smoothing_Length=10;
extern int First_Smoothing_Method=0;  // 0 - SMA
                                      // 1 - EMA
                                      // 2 - SMMA
                                      // 3 - LWMA
extern int Second_Smoothing_Length=10;
extern int Second_Smoothing_Method=0;  // 0 - SMA
                                       // 1 - EMA
                                       // 2 - SMMA
                                       // 3 - LWMA

double SM[], Signal[];
double Raw[], MA[];

int init()
{
 IndicatorShortName("Stochastic Momentum");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SM);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Raw);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MA);

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
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  Raw[pos]=Close[pos]-(Min+Max)/2;
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMAOnArray(Raw, 0, First_Smoothing_Length, 0, First_Smoothing_Method, pos);
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  if (Use_Smoothing)
  {
   SM[pos]=iMAOnArray(MA, 0, Second_Smoothing_Length, 0, Second_Smoothing_Method, pos);
  }
  else
  {
   SM[pos]=Raw[pos];
  }
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(SM, 0, Signal_Length, 0, Signal_Method, pos);
  pos--;
 } 
 return(0);
}

