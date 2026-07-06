//+------------------------------------------------------------------+
//|                                        Blau_Stochastic_Index.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Magenta

extern int Length=10;
extern int SmoothLength1=5;
extern int SmoothLength2=15;
extern int SignalLength=10;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double H_Up[], H_Dn[];
double Diff[], Range[], Diff_MA1[], Range_MA1[], Diff_MA2[], Range_MA2[];

int init()
{
 IndicatorShortName("Blau Stochastic Index oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,H_Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,H_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Diff);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Range);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Diff_MA1);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Range_MA1);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Diff_MA2);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,Range_MA2);

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
  Diff[pos]=Close[pos]-Min;
  Range[pos]=Max-Min;
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  Diff_MA1[pos]=iMAOnArray(Diff, 0, SmoothLength1, 0, Method, pos);
  Range_MA1[pos]=iMAOnArray(Range, 0, SmoothLength1, 0, Method, pos);
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  Diff_MA2[pos]=iMAOnArray(Diff_MA1, 0, SmoothLength2, 0, Method, pos);
  Range_MA2[pos]=iMAOnArray(Range_MA1, 0, SmoothLength2, 0, Method, pos);
  pos--;
 }  

 double Diff_MA3, Range_MA3;  
 pos=limit;
 while(pos>=0)
 {
  Diff_MA3=iMAOnArray(Diff_MA2, 0, SignalLength, 0, Method, pos);
  Range_MA3=iMAOnArray(Range_MA2, 0, SignalLength, 0, Method, pos);
  if (Range_MA3!=0)
  {
   H_Up[pos]=100*Diff_MA3/Range_MA3-50;
  }
  else
  {
   H_Up[pos]=0;
  }
  if (H_Up[pos]>=H_Up[pos+1]) 
  {
   H_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   H_Dn[pos]=H_Up[pos];
  }
  pos--;
 }  
  
 return(0);
}

