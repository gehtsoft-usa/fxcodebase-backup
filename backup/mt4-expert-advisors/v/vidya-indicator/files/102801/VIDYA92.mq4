//+------------------------------------------------------------------+
//|                                                      VIDYA92.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Short_Length=9;
extern int Long_Length=20;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double VIDYA92[];
double sc;

int init()
{
 IndicatorShortName("Chande's Variable Index Dynamic Average 1992 version");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VIDYA92);
 
 sc=2./(1.+Short_Length);

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
 double Pr0;
 
 double s1, s2, cmo;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  
  if (pos==Bars-2)
  {
   VIDYA92[pos]=Pr0;
  }
  else
  {
   s1=iStdDev(NULL, 0, Short_Length, 0, MODE_SMA, Price, pos);
   s2=iStdDev(NULL, 0, Long_Length, 0, MODE_SMA, Price, pos);
  
   if (s2==0.)
   {
    cmo=0.;
   }
   else
   {
    cmo=s1/s2;
    VIDYA92[pos]=sc*cmo*Pr0+(1.-sc*cmo)*VIDYA92[pos+1];
   }
  }

  pos--;
 }
   
 return(0);
}

