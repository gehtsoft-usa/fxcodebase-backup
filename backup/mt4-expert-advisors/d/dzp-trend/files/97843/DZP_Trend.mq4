//+------------------------------------------------------------------+
//|                                                    DZP_Trend.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int EMA_Length=20;
extern int Shift=22;
extern bool Histogram=false;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double DZP[], DZP_Dn[];

int init()
{
 IndicatorShortName("DZP Trend oscillator");
 IndicatorDigits(Digits);
 if (Histogram)
 {
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexStyle(1,DRAW_HISTOGRAM);
 }
 else
 {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_NONE);
 } 
 SetIndexBuffer(0,DZP);
 SetIndexBuffer(1,DZP_Dn);

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
 double EMA0, EMAS;
 double Pr0, PrS;
 double A, B;
 pos=limit;
 while(pos>=0)
 {
  EMA0=iMA(NULL, 0, EMA_Length, 0, MODE_EMA, Price, pos);
  EMAS=iMA(NULL, 0, EMA_Length, 0, MODE_EMA, Price, pos+Shift);
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  PrS=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Shift);
  
  if (PrS!=0. && EMAS!=0.)
  {
   A=(Pr0-PrS)/PrS;
   B=(EMA0-EMAS)/EMAS;
   DZP[pos]=100.*(A-B);
   
   if (DZP[pos]>=DZP[pos+1])
   {
    DZP_Dn[pos]=0.;
   }
   else
   {
    DZP_Dn[pos]=DZP[pos];
   }
  } 

  pos--;
 } 
 return(0);
}


