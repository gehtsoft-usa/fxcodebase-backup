//+------------------------------------------------------------------+
//|                                                   Difference.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Method=0;  // 0 - High/Low
                      // 1 - Open/Close

extern int Length=10;

double Data[], DifferenceUp[], DifferenceDn[];

int init()
  {
   IndicatorShortName("Difference");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,DifferenceUp);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DifferenceDn);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,Data);

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
  if (Method==0) Data[pos]=High[pos]-Low[pos]; else Data[pos]=Close[pos]-Open[pos];
  pos--;
 }

 pos=limit;
 double Diff;
 while(pos>=0)
 {
  Diff=iMAOnArray(Data, 0, Length, 0, MODE_SMA, pos)/Point;
  if (Diff>=DifferenceUp[pos+1]+DifferenceDn[pos+1])
  {
   DifferenceUp[pos]=Diff;
   DifferenceDn[pos]=0;
  }
  else
  {
   DifferenceUp[pos]=0;
   DifferenceDn[pos]=Diff;
  }
  pos--;
 }

 return(0);
}

