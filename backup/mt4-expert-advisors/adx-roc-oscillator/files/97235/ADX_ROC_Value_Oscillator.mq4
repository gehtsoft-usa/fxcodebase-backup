//+------------------------------------------------------------------+
//|                                     ADX_ROC_Value_Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red

extern int Length=14;
extern double Fast_Level=5.;
extern double Slow_Level=2.5;
extern int ROC_Length=1;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Fast[], Moderate[], Slow[];

int init()
{
 IndicatorShortName("ADX ROC value oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Fast);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Moderate);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Slow);

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
 double ADX0, ADX_ROC;
 double diff, Absdiff;
 pos=limit;
 while(pos>=0)
 {
  ADX0=iADX(NULL, 0, Length, Price, MODE_MAIN, pos);
  ADX_ROC=iADX(NULL, 0, Length, Price, MODE_MAIN, pos+ROC_Length);
  diff=ADX0-ADX_ROC;
  Absdiff=MathAbs(diff);
  
  Fast[pos]=0.;
  Moderate[pos]=0.;
  Slow[pos]=0.;
  
  if (Absdiff>=Fast_Level)
  {
   Fast[pos]=diff;
  }
  else
  {
   if (Absdiff<=Slow_Level)
   {
    Slow[pos]=diff;
   }
   else
   {
    Moderate[pos]=diff;
   }
  }

  pos--;
 } 
 return(0);
}

