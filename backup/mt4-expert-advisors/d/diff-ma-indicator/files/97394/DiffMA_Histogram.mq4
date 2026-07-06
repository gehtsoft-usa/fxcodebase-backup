//+------------------------------------------------------------------+
//|                                             DiffMA_Histogram.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;
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
 IndicatorShortName("Diff MA");
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
 int i;
 double SumUp, SumDn;
 int CountUp, CountDn;
 double Prev;
 double MA_Up, MA_Dn;
 double Diff;
 pos=limit;
 while(pos>=0)
 {
  SumUp=0.; SumDn=0.;
  CountUp=0; CountDn=0;
  i=pos;
  while (i<=Bars-2 && (CountUp<Length || CountDn<Length))
  {
   if (Close[i]>Open[i] && CountUp<Length)
   {
    CountUp++;
    SumUp=SumUp+iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
   }
   else
   {
    if (Close[i]<Open[i] && CountDn<Length)
    {
     CountDn++;
     SumDn=SumDn+iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
    }
   }
   i++;
  }
  
  if (CountUp>0 && CountDn>0)
  {
   MA_Up=SumUp/CountUp;
   MA_Dn=SumDn/CountDn;
   Diff=MA_Up-MA_Dn;
   Prev=Up[pos+1]+Dn[pos+1];
   
   if (Diff>=Prev)
   {
    Up[pos]=Diff;
    Dn[pos]=0.;
   }
   else
   {
    Up[pos]=0.;
    Dn[pos]=Diff;
   }
  }
  
  pos--;
 } 
 return(0);
}

