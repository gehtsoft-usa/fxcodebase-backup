//+------------------------------------------------------------------+
//|                                                         Trix.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Red

extern int Length=14;
extern int FirstMethod=0;
extern int SecondMethod=0;
extern int ThirdMethod=0;
extern int SignalLength=9;
extern int SignalMethod=0;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Trix[], Signal[], HistogramUp[], HistogramDn[];
double MA1[], MA2[];

int init()
  {
   IndicatorShortName("Trix");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Trix);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Signal);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,HistogramUp);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,HistogramDn);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,MA1);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,MA2);

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
 double Hist;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  MA1[pos]=iMA(NULL, 0, Length, 0, FirstMethod, Price, pos);
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  MA2[pos]=iMAOnArray(MA1, 0, Length, 0, SecondMethod, pos);
  pos--;
 }
 
 pos=limit;
 double MA3_0, MA3_1;
 while(pos>=0)
 {
  MA3_0=iMAOnArray(MA2, 0, Length, 0, ThirdMethod, pos);
  MA3_1=iMAOnArray(MA2, 0, Length, 0, ThirdMethod, pos+1);
  if (MA3_1!=0) Trix[pos]=(MA3_0-MA3_1)/MA3_1/Point;
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(Trix, 0, SignalLength, 0, SignalMethod, pos);
  Hist=Trix[pos]-Signal[pos];
  if (Hist>=HistogramUp[pos+1]+HistogramDn[pos+1])
  {
   HistogramUp[pos]=Hist;
   HistogramDn[pos]=0;
  }
  else
  {
   HistogramUp[pos]=0;
   HistogramDn[pos]=Hist;
  } 
  pos--;
 }
 
 
 return(0);
}

