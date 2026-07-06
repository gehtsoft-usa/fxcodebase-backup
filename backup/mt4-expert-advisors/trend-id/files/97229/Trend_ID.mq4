//+------------------------------------------------------------------+
//|                                                     Trend_ID.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue

extern int MVA_Length=200;
extern int StdDev_Length=20;
extern int Smoothing_Length=20;
extern double Multiplier=2.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double B1[], B2[], B3[];
double Raw[], Avg[];

int init()
{
 IndicatorShortName("Trend ID");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,B1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,B2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,B3);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Raw);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Avg);

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
 double MA, Pr;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, MVA_Length, 0, MODE_SMA, Price, pos);
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  if (MA!=0.)
  {
   Raw[pos]=100.*(Pr-MA)/MA;
  } 

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Avg[pos]=iMAOnArray(Raw, 0, Smoothing_Length, 0, MODE_SMA, pos);

  pos--;
 }
 
 double StdDev;
 pos=limit;
 while(pos>=0)
 {
  StdDev=iStdDevOnArray(Avg, 0, StdDev_Length, 0, MODE_SMA, pos);
  B1[pos]=Multiplier*StdDev;
  B2[pos]=Avg[pos];
  B3[pos]=-1.*Multiplier*StdDev;

  pos--;
 }  
   
 return(0);
}

