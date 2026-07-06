//+------------------------------------------------------------------+
//|                                                     Blau_CMI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Yellow

extern int Length=1;
extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Smooth_Length3=3;
extern int Price1=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Price2=1;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  

double Blau_CMI[];
double CM[], EMA1[], EMA2[];
double Abs_CM[], Abs_EMA1[], Abs_EMA2[];

int init()
{
 IndicatorShortName("William Blau Candlestick Momentum Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Blau_CMI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,CM);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,EMA1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,EMA2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Abs_CM);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Abs_EMA1);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Abs_EMA2);

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
 pos=limit;
 while(pos>=0)
 {
  CM[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price1, pos)-iMA(NULL, 0, 1, 0, MODE_SMA, Price2, pos+Length-1);
  Abs_CM[pos]=MathAbs(CM[pos]);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  EMA1[pos]=iMAOnArray(CM, 0, Smooth_Length1, 0, MODE_EMA, pos);
  Abs_EMA1[pos]=iMAOnArray(Abs_CM, 0, Smooth_Length1, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  EMA2[pos]=iMAOnArray(EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  Abs_EMA2[pos]=iMAOnArray(Abs_EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  pos--;
 }  

 double EMA3, Abs_EMA3;
 pos=limit;
 while(pos>=0)
 {
  EMA3=iMAOnArray(EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  Abs_EMA3=iMAOnArray(Abs_EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  if (Abs_EMA3>0)
  {
   Blau_CMI[pos]=100.*EMA3/Abs_EMA3;
  }
  else
  {
   Blau_CMI[pos]=0;
  } 
  pos--;
 }  

 return(0);
}

