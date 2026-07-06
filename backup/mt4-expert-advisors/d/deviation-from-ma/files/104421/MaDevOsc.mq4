//+------------------------------------------------------------------+
//|                                                     MaDevOsc.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Method=1;  // 0 - SMA
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
extern int Length=20;
extern int Frame=3;

double MDO[], MDO_Up[], MDO_Dn[];
int Shift;

int init()
{
 IndicatorShortName("MaDev oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,MDO);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,MDO_Up);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,MDO_Dn);
 
 Shift=MathFloor((Frame-1.)/2.);

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
 double Pr, MA;
 bool Min, Max;
 int i;
 
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
  
  MDO[pos]=Pr-MA;
  
  Min=true;
  Max=true;
  
  for (i=1;i<=Shift;i++)
  {
   if (MDO[pos+Shift+1]>=MDO[pos+i+Shift+1] || MDO[pos+Shift+1]>=MDO[pos-i+Shift+1])
   {
    Min=false;
   }
   if (MDO[pos+Shift+1]<=MDO[pos+i+Shift+1] || MDO[pos+Shift+1]<=MDO[pos-i+Shift+1])
   {
    Max=false;
   }
  }
  
  MDO_Up[pos+Shift+1]=0.;
  MDO_Dn[pos+Shift+1]=0.;
  
  if (Min && MDO[pos+Shift+1]<0.)
  {
   MDO_Dn[pos+Shift+1]=MDO[pos+Shift+1];
  }

  if (Max && MDO[pos+Shift+1]>0.)
  {
   MDO_Up[pos+Shift+1]=MDO[pos+Shift+1];
  }

  pos--;
 } 
 return(0);
}

