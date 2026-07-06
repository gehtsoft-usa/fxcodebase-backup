//+------------------------------------------------------------------+
//|                                                    Stoch_RSI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int RSI_Length=14;
extern int K_Stochastic_Length=14;
extern int K_Slowing_Length=5;
extern int D_Slowing_Stochastic_Length=3;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double K[], D[];
double RSI[], SKI[];

int init()
{
 IndicatorShortName("Stochastic RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_ARROW);
 SetIndexBuffer(1,D);
 SetIndexArrow(1,108);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,RSI);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,SKI);

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
  Min=RSI[ArrayMinimum(RSI, K_Stochastic_Length, pos)];
  Max=RSI[ArrayMaximum(RSI, K_Stochastic_Length, pos)];
  if (Min==Max)
  {
   SKI[pos]=100.;
  }
  else
  {
   SKI[pos]=100.*(RSI[pos]-Min)/(Max-Min);
  }
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  K[pos]=iMAOnArray(SKI, 0, K_Slowing_Length, 0, MODE_SMA, pos);
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  D[pos]=iMAOnArray(K, 0, D_Slowing_Stochastic_Length, 0, MODE_SMA, pos);
  pos--;
 }  
 
 return(0);
}

