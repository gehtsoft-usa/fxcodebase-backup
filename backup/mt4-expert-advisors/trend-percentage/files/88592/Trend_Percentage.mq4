//+------------------------------------------------------------------+
//|                                             Trend_Percentage.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double Bulls[], Bears[];

int init()
{
 IndicatorShortName("Trend Percentage");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Bulls);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bears);

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
 int i;
 double SBull, SBear;
 double Sum;
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  SBull=0;
  SBear=0;
  for (i=1;i<=Length;i++)
  {
   Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i);
   Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i+1);
   if (Pr0>Pr1)
   {
    SBull=SBull+MathAbs(Pr0-Pr1);
   }
   else
   {
    if (Pr0<Pr1)
    {
     SBear=SBear+MathAbs(Pr0-Pr1);
    }
   }
  }
  Sum=SBull+SBear;
  if (Sum>0)
  {
   Bulls[pos]=100*SBull/Sum;
   Bears[pos]=100*SBear/Sum;
  }
  pos--;
 } 
 return(0);
}

