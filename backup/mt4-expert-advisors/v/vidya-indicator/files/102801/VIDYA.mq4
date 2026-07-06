//+------------------------------------------------------------------+
//|                                                        VIDYA.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=9;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double VIDYA[];
double cmo1[], cmo2[];
double sc;

int init()
{
 IndicatorShortName("Chande's Variable Index Dynamic Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VIDYA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,cmo1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,cmo2);
 
 sc=2./(1.+Length);

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
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  
  diff=Pr0-Pr1;
  if (diff>0.)
  {
   cmo1[pos]=diff;
   cmo2[pos]=0.;
  }
  else
  {
   cmo1[pos]=0.;
   cmo2[pos]=-diff;
  }

  pos--;
 } 
 
 double s1, s2, cmo;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  
  if (pos==Bars-2)
  {
   VIDYA[pos]=Pr0;
  }
  else
  {
   s1=iMAOnArray(cmo1, 0, Length, 0, MODE_SMA, pos);
   s2=iMAOnArray(cmo2, 0, Length, 0, MODE_SMA, pos);
   if (s1+s2==0.)
   {
    cmo=0.;
   }
   else
   {
    cmo=MathAbs((s1-s2)/(s1+s2));
    VIDYA[pos]=sc*cmo*Pr0+(1.-sc*cmo)*VIDYA[pos+1];
   }
  }

  pos--;
 }
   
 return(0);
}

