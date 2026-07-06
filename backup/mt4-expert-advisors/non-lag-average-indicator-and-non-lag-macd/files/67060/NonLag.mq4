//+------------------------------------------------------------------+
//|                                                       NonLag.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define Pi 3.1415926535

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red

extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Length=10;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Filter=0;
extern double Deviation=0;

double NonLag[], NL_Up[], NL_Dn[], trend[];
double Coeff, Phase, Len, dT1, dT2, Kd, Fi;

int init()
  {
   IndicatorShortName("Non lag");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,NonLag);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,NL_Up);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,NL_Dn);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,trend);
   Coeff=3.*Pi;
   Phase=Length-1;
   Len=4.*Length+Phase;
   dT1=7./(4.*Length-1.);
   dT2=1./(Phase-1.);
   Kd=1.+Deviation/100.;
   Fi=Filter*Point;
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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double Weight, Sum, t, g;
 int i;
 double alpha, beta;
 while(pos>=0)
 {
  Weight=0.;
  Sum=0.;
  t=0.;
  for (i=0;i<Len;i++)
  {
   g=1./(Coeff*t+1);
   if (t<=0.5) g=1;
   beta=MathCos(Pi*t);
   alpha=g*beta;
   Sum=Sum+alpha*iMA(NULL, 0, Length, 0, Method, Price, pos+i);
   Weight=Weight+alpha;
   if (t<1.) t=t+dT2; else if (t<Len-1) t=t+dT1;
  }
  if (Weight>0)
  {
   NonLag[pos]=Kd*Sum/Weight;
  }
  if (Filter>0)
  {
   if (MathAbs(NonLag[pos]-NonLag[pos+1])<Fi)
   {
    NonLag[pos]=NonLag[pos+1];
   }
  } 
  trend[pos]=trend[pos+1];
  if (NonLag[pos]-NonLag[pos+1]>Fi)
  {
   trend[pos]=1;
  }
  if (NonLag[pos+1]-NonLag[pos]>Fi)
  {
   trend[pos]=-1;
  }
  if (trend[pos]==1)
  {
   NL_Up[pos]=NonLag[pos];
   NL_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   NL_Up[pos]=EMPTY_VALUE;
   NL_Dn[pos]=NonLag[pos];
  }
  pos--;
 } 

 return(0);
}

