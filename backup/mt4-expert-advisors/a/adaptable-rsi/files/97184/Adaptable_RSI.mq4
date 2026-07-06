//+------------------------------------------------------------------+
//|                                                Adaptable_RSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=14;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted
extern double OverBoughtLevel=70;
extern double OverSoldLevel=30;
extern int LevelWidth=1;
extern color LevelColor=Gray;                        

double ARSI[];
double Loss[], Gain[];

int init()
{
 IndicatorShortName("Adaptable RSI oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ARSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Loss);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Gain);

 SetLevelValue(0, 50.);
 SetLevelValue(1, OverBoughtLevel);
 SetLevelValue(2, OverSoldLevel);
 SetLevelValue(3, 0.);
 SetLevelValue(4, 100.);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);

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
 double Pr0, Pr1;
 double diff;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  diff=Pr0-Pr1;
  
  if (diff>0.)
  {
   Loss[pos]=0.;
   Gain[pos]=diff;
  }
  else
  {
   Loss[pos]=-diff;
   Gain[pos]=0.;
  }

  pos--;
 } 
 
 double MA_Loss, MA_Gain;
 pos=limit;
 while(pos>=0)
 {
  MA_Loss=iMAOnArray(Loss, 0, Length, 0, Method, pos);
  MA_Gain=iMAOnArray(Gain, 0, Length, 0, Method, pos);
  
  if (MA_Loss!=0.)
  {
   ARSI[pos]=100.-100./(1.+MA_Gain/MA_Loss);
  }
  
  pos--;
 }
   
 return(0);
}

