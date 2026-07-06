//+------------------------------------------------------------------+
//|                                         Breakdown_Oscillator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Short_Length=10;
extern int Band_Length=20;
extern double Deviation=1.5;
extern double Slope_Factor=2.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Breakdown[];
double Difference[];

int init()
{
 IndicatorShortName("Breakdown oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Breakdown);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Difference);

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
 double SMA0, SMA1;
 double Bottom, StdDev;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  SMA0=iMA(NULL, 0, Short_Length, 0, MODE_SMA, Price, pos);
  SMA1=iMA(NULL, 0, Short_Length, 0, MODE_SMA, Price, pos+1);
  StdDev=iStdDev(NULL, 0, Band_Length, 0, MODE_SMA, Price, pos);
  Bottom=SMA0-Deviation*StdDev;
  
  Difference[pos]=Pr-Bottom+Slope_Factor*(SMA0-SMA1);

  pos--;
 } 
 
 double EMA;
 pos=limit;
 while(pos>=0)
 {
  EMA=iMAOnArray(Difference, 0, Short_Length, 0, MODE_EMA, pos);
  
  if (Bottom!=0.)
  {
   Breakdown[pos]=100.*EMA/Bottom;
  } 

  pos--;
 }
   
 return(0);
}


