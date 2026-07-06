//+------------------------------------------------------------------+
//|                                           Adaptable_StochRSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int RSI_Length=14;
extern int Stoch_K_Length=14;
extern int K_Smooth_Length=8;
extern int K_Smooth_Method=1;  // 0 - SMA
                               // 1 - EMA
                               // 2 - SMMA
                               // 3 - LWMA
extern int D_Smooth_Length=8;
extern int D_Smooth_Method=1;  // 0 - SMA
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

double K[], D[];
double SKI[], RSI[];

int init()
{
 IndicatorShortName("Adaptable Stochastic RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,D);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,SKI);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,RSI);

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
  RSI[pos]=iRSI(NULL, 0, RSI_Length, Price, pos);

  pos--;
 } 
 
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=RSI[ArrayMinimum(RSI, Stoch_K_Length, pos)];
  Max=RSI[ArrayMaximum(RSI, Stoch_K_Length, pos)];
  if (Min==Max)
  {
   SKI[pos]=1.;
  }
  else
  {
   SKI[pos]=(RSI[pos]-Min)/(Max-Min);
  }

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  K[pos]=100.*iMAOnArray(SKI, 0, K_Smooth_Length, 0, K_Smooth_Method, pos);

  pos--;
 }  
   
 pos=limit;
 while(pos>=0)
 {
  D[pos]=iMAOnArray(K, 0, D_Smooth_Length, 0, D_Smooth_Method, pos);

  pos--;
 }  
   
 return(0);
}


