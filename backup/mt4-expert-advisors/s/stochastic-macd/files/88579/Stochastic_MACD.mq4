//+------------------------------------------------------------------+
//|                                              Stochastic_MACD.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Short_Length=12;
extern int Long_Length=35;
extern int Signal_Length=9;
extern int Stochastic_Length=18;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double StochMACD[];
int MaxLength;
double B1[], B2[], MA[];

int init()
{
 IndicatorShortName("Stochastic MACD");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,StochMACD);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,B1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,B2);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MA);
 MaxLength=MathMax(Short_Length, MathMax(Long_Length, Signal_Length));
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=MaxLength) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  B1[pos]=iMA(NULL, 0, Short_Length, 0, Method, Price, pos)-iMA(NULL, 0, Long_Length, 0, Method, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMAOnArray(B1, 0, Signal_Length, 0, Method, pos);
  B2[pos]=B1[pos]-MA[pos];
  pos--;
 }
 
 double Min, Max; 
 pos=limit;
 while(pos>=0)
 {
  Min=B2[ArrayMinimum(B2, Stochastic_Length, pos)];
  Max=B2[ArrayMaximum(B2, Stochastic_Length, pos)];
  if (Min!=Max)
  {
   StochMACD[pos]=100*(B1[pos]-MA[pos]-Min)/(Max-Min);
  }
  else
  {
   StochMACD[pos]=0;
  } 
  
  pos--;
 }
  
 return(0);
}

