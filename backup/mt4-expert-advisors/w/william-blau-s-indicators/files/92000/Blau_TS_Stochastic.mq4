//+------------------------------------------------------------------+
//|                                           Blau_TS_Stochastic.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Gray
#property indicator_color2 Yellow

extern int Length=5;
extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Smooth_Length3=3;
extern int Signal_Length=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Blau_TStoch[], Signal[];
double Stoch[], Stoch_EMA1[], Stoch_EMA2[];
double HH[], HH_EMA1[], HH_EMA2[];

int init()
{
 IndicatorShortName("William Blau Stochastic oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Blau_TStoch);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Stoch);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Stoch_EMA1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Stoch_EMA2);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,HH);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,HH_EMA1);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,HH_EMA2);

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
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  HH[pos]=Max-Min;
  Stoch[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-Min;
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  HH_EMA1[pos]=iMAOnArray(HH, 0, Smooth_Length1, 0, MODE_EMA, pos);
  Stoch_EMA1[pos]=iMAOnArray(Stoch, 0, Smooth_Length1, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  HH_EMA2[pos]=iMAOnArray(HH_EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  Stoch_EMA2[pos]=iMAOnArray(Stoch_EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  pos--;
 }  

 double HH_EMA3, Stoch_EMA3;
 pos=limit;
 while(pos>=0)
 {
  HH_EMA3=iMAOnArray(HH_EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  Stoch_EMA3=iMAOnArray(Stoch_EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  if (HH_EMA3>0.)
  {
   Blau_TStoch[pos]=100.*Stoch_EMA3/HH_EMA3;
  }
  else
  {
   Blau_TStoch[pos]=0;
  }
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(Blau_TStoch, 0, Signal_Length, 0, MODE_EMA, pos);
  pos--;
 }
   
 return(0);
}

