//+------------------------------------------------------------------+
//|                                                         ROCX.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=1;
extern string ModeStr="Mode: 0 - Absolute value, 1 - % value, 2 - %% value";
extern int Mode=0;  // 0 - Absolute value, 1 - % value, 2 - %% value
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double ROCX[];

int init()
{
 IndicatorShortName("Rate Of Change (Modified version)");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ROCX);

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
 double diff;
 double Pr0, PrN;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  PrN=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Length);
  diff=Pr0-PrN;
  
  if (Mode==0)
  {
   ROCX[pos]=diff;
  }
  else
  {
   if (Mode==1)
   {
    ROCX[pos]=100.*diff/PrN;
   }
   else
   {
    ROCX[pos]=1000.*diff/PrN;
   }
  }

  pos--;
 } 
 return(0);
}

