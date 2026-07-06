//+------------------------------------------------------------------+
//|                                                        ADMIR.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern int Difference=14;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double ADMIR[];

int init()
{
 IndicatorShortName("Average Directional Movement Index Rating");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ADMIR);

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
  ADMIR[pos]=(ADX1+ADX2)/2.;

  pos--;
 } 
 return(0);
}

