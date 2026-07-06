//+------------------------------------------------------------------+
//|                                                          SS2.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Length=14;
extern double Threshold=0.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted

double SS[];
double Anchor[], Trend[];

int init()
{
 IndicatorShortName("Swing Shift oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SS);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Anchor);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Trend);

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
 double MA0, MA1;
 double Slope;
 pos=limit;
 while(pos>=0)
 {
  MA0=iMA(NULL, 0, Length, 0, Method, Price, pos);
  MA1=iMA(NULL, 0, Length, 0, Method, Price, pos+1);
  Slope=(MA0-MA1)/Point;
  if (pos==Bars-2)
  {
   Anchor[pos]=MA0;
   Trend[pos]=0.;
   SS[pos]=0.;
  }
  else
  {
   if (Slope>Threshold && Trend[pos+1]<1.)
   {
    Anchor[pos]=MA0;
    Trend[pos]=1.;
   }
   else
   {
    if (Slope<-Threshold && Trend[pos+1]>0.)
    {
     Anchor[pos]=MA0;
     Trend[pos]=0.;
    }
    else
    {
     Anchor[pos]=Anchor[pos+1];
     Trend[pos]=Trend[pos+1];
    }
   }
   
   if (Anchor[pos]!=0.)
   {
    SS[pos]=100.*(MA0-Anchor[pos])/Anchor[pos];
   }
  }

  pos--;
 } 
 return(0);
}

