//+------------------------------------------------------------------+
//|                                             Blau_Ergodic_MDI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Gray
#property indicator_color2 Yellow

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

double Blau_MDI[];
double Blau_EMDI[];
double MD[], EMA2[];

int init()
{
 IndicatorShortName("William Blau Mean Deviation Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Blau_MDI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Blau_EMDI);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,MD);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,EMA2);

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
  MD[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, Smooth_Length1, 0, MODE_EMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  EMA2[pos]=iMAOnArray(MD, 0, Smooth_Length2, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  Blau_MDI[pos]=iMAOnArray(EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  Blau_EMDI[pos]=iMAOnArray(Blau_MDI, 0, Signal_Length, 0, MODE_EMA, pos);
  pos--;
 }  

 return(0);
}

