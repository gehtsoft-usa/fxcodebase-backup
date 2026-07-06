//+------------------------------------------------------------------+
//|                                                       MA_Gap.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern string Type_Str="Type: 0 - Absolute, 1 - Relative, 2 - Pips";
extern int Type=0;   // 0 - Absolute, 1 - Relative, 2 - Pips
extern int First_Length=10;
extern int First_Method=0;  // 0 - SMA
                            // 1 - EMA
                            // 2 - SMMA
                            // 3 - LWMA
extern int Second_Length=20;
extern int Second_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Gap[];

int init()
{
 IndicatorShortName("MA Gap");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Gap);

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
 double MA1, MA2;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMA(NULL, 0, First_Length, 0, First_Method, Price, pos);
  MA2=iMA(NULL, 0, Second_Length, 0, Second_Method, Price, pos);
  
  if (Type==0)
  {
   Gap[pos]=MA1-MA2;
  }
  else
  {
   if (Type==1)
   {
    if (MA1!=0.)
    {
     Gap[pos]=100.*(MA1-MA2)/MA1;
    } 
   }
   else
   {
    Gap[pos]=(MA1-MA2)/Point;
   }
  }

  pos--;
 }
  
 return(0);
}

