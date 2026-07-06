//+------------------------------------------------------------------+
//|                                               DMI_Difference.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double DMI_D[];

int init()
{
 IndicatorShortName("DMI Difference oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DMI_D);

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
 double DIP, DIM;
 pos=limit;
 while(pos>=0)
 {
  DIP=iADX(NULL, 0, Length, Price,  MODE_PLUSDI, pos);
  DIM=iADX(NULL, 0, Length, Price,  MODE_MINUSDI, pos);
  
  DMI_D[pos]=DIP-DIM;

  pos--;
 } 
 return(0);
}

