//+------------------------------------------------------------------+
//|                              Double_Smoothed_MACD_Stochastic.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Stoch_Length=32;
extern int Smooth_EMA=9;
extern int Signal_EMA=5;
extern int MACD_Fast=12;
extern int MACD_Slow=26;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double DSS[], Signal[];
double DDS2[], MACD[];

double alpha, beta;

int init()
{
 IndicatorShortName("Double smoothed MACD Stochastic oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DSS);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,DDS2);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MACD);
 
 alpha=2./(1.+Signal_EMA);
 beta=2./(1.+Smooth_EMA);

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
 double FastEMA, SlowEMA;
 pos=limit;
 while(pos>=0)
 {
  FastEMA=iMA(NULL, 0, MACD_Fast, 0, MODE_EMA, Price, pos);
  SlowEMA=iMA(NULL, 0, MACD_Slow, 0, MODE_EMA, Price, pos);
  
  MACD[pos]=FastEMA-SlowEMA;

  pos--;
 } 
 
 double Min, Max;
 double DDS1, DDS3;
 pos=limit;
 while(pos>=0)
 {
  Min=MACD[ArrayMinimum(MACD, Stoch_Length, pos)];
  Max=MACD[ArrayMaximum(MACD, Stoch_Length, pos)];
  
  if (Min!=Max)
  {
   DDS1=100.*(MACD[pos]-Min)/(Max-Min);
  }
  else
  {
   DDS1=0.;
  }
  
  DDS2[pos]=DDS2[pos+1]+beta*(DDS1-DDS2[pos+1]);

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  Min=DDS2[ArrayMinimum(DDS2, Stoch_Length, pos)];
  Max=DDS2[ArrayMaximum(DDS2, Stoch_Length, pos)];
  
  if (Min!=Max)
  {
   DDS3=100.*(DDS2[pos]-Min)/(Max-Min);
  }
  else
  {
   DDS3=0.;
  }
  
  DSS[pos]=DSS[pos+1]+beta*(DDS3-DSS[pos+1]);
  
  Signal[pos]=Signal[pos+1]+alpha*(DSS[pos]-Signal[pos+1]);

  pos--;
 }  
   
 return(0);
}

