//+------------------------------------------------------------------+
//|                                            Anchored_Momentum.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int First_Length=2;
extern int First_Method=2;  // 0 - SMA
                            // 1 - EMA
                            // 2 - SMMA
                            // 3 - LWMA
extern int Second_Length=42;
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

double Up[], Dn[];

int init()
{
 IndicatorShortName("Anchored Momentum");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Dn);

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
 double First_MA, Second_MA;
 double AM, PrevAM;
 pos=limit;
 while(pos>=0)
 {
  First_MA=iMA(NULL, 0, First_Length, 0, First_Method, Price, pos);
  Second_MA=iMA(NULL, 0, Second_Length, 0, Second_Method, Price, pos);
  
  if (Second_MA!=0.)
  {
   AM=100.*(First_MA/Second_MA-1.);
   PrevAM=Up[pos+1]+Dn[pos+1];
   
   if (AM>=PrevAM)
   {
    Up[pos]=AM;
    Dn[pos]=0.;
   }
   else
   {
    Up[pos]=0.;
    Dn[pos]=AM;
   }
  }

  pos--;
 } 
 return(0);
}

