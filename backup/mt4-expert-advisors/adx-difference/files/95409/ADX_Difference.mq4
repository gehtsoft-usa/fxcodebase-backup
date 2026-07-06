//+------------------------------------------------------------------+
//|                                               ADX_Difference.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern int Difference=1;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double ADX_Diff[], ADX_Diff_DN[];

int init()
{
 IndicatorShortName("ADX Difference");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,ADX_Diff);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,ADX_Diff_DN);

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
 double ADX1, ADX2;
 pos=limit;
 while(pos>=0)
 {
  ADX1=iADX(NULL, 0, Length, Price, MODE_MAIN, pos);
  ADX2=iADX(NULL, 0, Length, Price, MODE_MAIN, pos+Difference);
  ADX_Diff[pos]=ADX1-ADX2;
  if (ADX_Diff[pos]>ADX_Diff[pos+1])
  {
   ADX_Diff_DN[pos]=ADX_Diff[pos];
  }
  else
  {
   ADX_Diff_DN[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

