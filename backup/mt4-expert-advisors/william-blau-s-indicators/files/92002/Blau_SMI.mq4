//+------------------------------------------------------------------+
//|                                                     Blau_SMI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Yellow

extern int Length=5;
extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Smooth_Length3=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Blau_SMI[];
double HH[], EMA1[], EMA2[];
double Half_HH[], Half_EMA1[], Half_EMA2[];

int init()
{
 IndicatorShortName("William Blau Stochastic Momentum Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Blau_SMI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,HH);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,EMA1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,EMA2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Half_HH);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Half_EMA1);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Half_EMA2);

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
  HH[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-(Max+Min)/2.;
  Half_HH[pos]=(Max-Min)/2.;
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  EMA1[pos]=iMAOnArray(HH, 0, Smooth_Length1, 0, MODE_EMA, pos);
  Half_EMA1[pos]=iMAOnArray(Half_HH, 0, Smooth_Length1, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  EMA2[pos]=iMAOnArray(EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  Half_EMA2[pos]=iMAOnArray(Half_EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  pos--;
 }  

 double EMA3, Half_EMA3;
 pos=limit;
 while(pos>=0)
 {
  EMA3=iMAOnArray(EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  Half_EMA3=iMAOnArray(Half_EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  if (Half_EMA3>0)
  {
   Blau_SMI[pos]=100.*EMA3/Half_EMA3;
  }
  else
  {
   Blau_SMI[pos]=0;
  } 
  pos--;
 }  
 return(0);
}

