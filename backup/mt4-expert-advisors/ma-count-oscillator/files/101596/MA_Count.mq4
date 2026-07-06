//+------------------------------------------------------------------+
//|                                                     MA_Count.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;
extern int Method=0;  // 0 - SMA
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
 IndicatorShortName("MA Count oscillator");
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
 double MA, Pr;
 double Sum;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   Up[pos]=0.;
   Dn[pos]=0.;
  }
  else
  {
   Sum=Up[pos+1]+Dn[pos+1];
   MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
   Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
   if (Sum>=0)
   {
    if (Pr>MA)
    {
     Up[pos]=Up[pos+1]+1.;
     Dn[pos]=0.;
    }
    else
    {
     Up[pos]=0.;
     Dn[pos]=-1.;
    }
   }
   else
   {
    if (Pr<MA)
    {
     Up[pos]=0.;
     Dn[pos]=Dn[pos+1]-1.;
    }
    else
    {
     Up[pos]=1.;
     Dn[pos]=0.;
    }
   }
  } 

  pos--;
 } 
 return(0);
}

