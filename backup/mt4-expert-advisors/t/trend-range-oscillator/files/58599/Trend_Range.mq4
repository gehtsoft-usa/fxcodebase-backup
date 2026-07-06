//+------------------------------------------------------------------+
//|                                                  Trend_Range.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Gray
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Blue

extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Length=10;
extern double Deviation=1;

double TrendRange[], Level1[], Level2[];
double TR1[], TR2[];

int init()
  {
   IndicatorShortName("Trend Range");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,TrendRange);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,TR1);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,TR2);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Level1);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Level2);
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
 int pos;
 int limit=Bars-2;
 double res1;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  res1=(High[pos]-Low[pos])/Point;
  TrendRange[pos]=res1*Volume[pos];
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  double MA=iMAOnArray(TrendRange, 0, Length, 0, Method, pos);
  double StdDev=iStdDevOnArray(TrendRange, 0, Length, 0, Method, pos);
  double Max=MA+StdDev*Deviation;
  double Flat=Max/2;
  Level1[pos]=Flat;
  Level2[pos]=Max;
  
  if (TrendRange[pos]>Flat)
  {
   TR1[pos]=TrendRange[pos];
  }
  else
  {
   TR1[pos]=EMPTY_VALUE;
  }
  
  if (TrendRange[pos]>Max)
  {
   TR2[pos]=TrendRange[pos];
  }
  else
  {
   TR2[pos]=EMPTY_VALUE;
  }
  
  pos--;
 }
 return(0);
}

