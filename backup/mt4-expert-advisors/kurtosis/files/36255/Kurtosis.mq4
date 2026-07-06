//+------------------------------------------------------------------+
//|                                                     Kurtosis.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red

extern int Length=4;
extern int FirstSmoothPeriod=66;
extern int SecondSmoothPeriod=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  


double Kurtosis[];
double Momentum[], RAW[], MA[];

int init()
  {
   IndicatorShortName("Kurtosis");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Kurtosis);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,Momentum);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,RAW);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,MA);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  Momentum[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Length);
  RAW[pos]=Momentum[pos]-Momentum[pos+1];
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMAOnArray(RAW, 0, FirstSmoothPeriod, 0, MODE_EMA, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Kurtosis[pos]=iMAOnArray(MA, 0, SecondSmoothPeriod, 0, MODE_SMA, pos)/Point;
  pos--;
 }

 return(0);
}

