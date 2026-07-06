//+------------------------------------------------------------------+
//|                                             Trend_Linear_Reg.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 SeaGreen
#property indicator_color2 YellowGreen
#property indicator_color3 HotPink
#property indicator_color4 Red

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double Buff1[], Buff2[], Buff3[], Buff4[];
double Pr[];
double sumx, sumx2;
double c;

int init()
{
 IndicatorShortName("Trend Linear Reg oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Buff1);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Buff2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Buff3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,Buff4);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Pr);
 sumx=(Length+0.)*(Length-1.)/2.;
 sumx2=(Length+0.)*(Length-1.)*(2.*Length-1.)/6.;
 c=sumx2*Length-sumx*sumx;

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double sumy, sumxy;
 int i;
 double b;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  sumy=0;
  sumxy=0;
  for (i=0;i<Length;i++)
  {
   sumy+=Pr[pos+i];
   sumxy+=Pr[pos+i]*i;
  }
  b=(sumxy*Length-sumx*sumy)/c;
  Buff1[pos]=-b/Point;
  Buff2[pos]=EMPTY_VALUE;
  Buff3[pos]=EMPTY_VALUE;
  Buff4[pos]=EMPTY_VALUE;
  if (Buff1[pos]>0)
  {
   if (Buff1[pos]<Buff1[pos+1])
   {
    Buff2[pos]=Buff1[pos];
   }
  }
  else
  {
   if (Buff1[pos]>Buff1[pos+1])
   {
    Buff3[pos]=Buff1[pos];
   }
   else
   {
    Buff4[pos]=Buff1[pos];
   }
  }
  pos--;
 } 
 return(0);
}

