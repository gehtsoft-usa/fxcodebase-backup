//+------------------------------------------------------------------+
//|                                                         TD_I.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Shift=1;
extern int Length=8;

double TD_I[];
double High_Diff[], Low_Diff[];

int init()
{
 IndicatorShortName("TD_I oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TD_I);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,High_Diff);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Low_Diff);

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
  High_Diff[pos]=MathMax(0., High[pos]-High[pos+Shift]);
  Low_Diff[pos]=MathMax(0., Low[pos+Shift]-Low[pos]);

  pos--;
 } 
 
 double High_Avg, Low_Avg;
 pos=limit;
 while(pos>=0)
 {
  High_Avg=iMAOnArray(High_Diff, 0, Length, 0, MODE_SMA, pos);
  Low_Avg=iMAOnArray(Low_Diff, 0, Length, 0, MODE_SMA, pos);
  
  if (High_Avg+Low_Avg!=0.)
  {
   TD_I[pos]=100.*High_Avg/(High_Avg+Low_Avg);
  }

  pos--;
 }
   
 return(0);
}


