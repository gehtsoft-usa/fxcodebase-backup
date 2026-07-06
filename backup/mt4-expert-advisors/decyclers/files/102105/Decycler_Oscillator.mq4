//+------------------------------------------------------------------+
//|                                          Decycler_Oscillator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define PI 3.1415926

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern double HP_Length=125.;
extern double K=1.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double DO[];
double HP[], Decycle[], DecycleOsc[], Pr[];
double Angle1, Angle2, Alpha1, Alpha2;

int init()
{
 IndicatorShortName("Decycler Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DO);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,HP);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Decycle);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,DecycleOsc);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Pr);

 Angle1=1.414*PI/HP_Length;
 Angle2=2.*Angle1;
 
 Alpha1=(MathCos(Angle1)+MathSin(Angle1)-1.)/MathCos(Angle1);
 Alpha2=(MathCos(Angle2)+MathSin(Angle2)-1.)/MathCos(Angle2);
 
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
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  HP[pos]=(1.-Alpha1/2.)*(1.-Alpha1/2.)*(Pr[pos]-2.*Pr[pos+1]+Pr[pos+2])+2.*(1.-Alpha1)*HP[pos+1]-(1.-Alpha1)*(1.-Alpha1)*HP[pos+2];
  Decycle[pos]=Pr[pos]-HP[pos];
  DecycleOsc[pos]=(1.-Alpha2/2.)*(1.-Alpha2/2.)*(Decycle[pos]-2.*Decycle[pos+1]+Decycle[pos+2])+2.*(1.-Alpha2)*DecycleOsc[pos+1]-(1.-Alpha2)*(1.-Alpha2)*DecycleOsc[pos+2];
  
  if (Pr[pos]!=0.)
  {
   DO[pos]=100.*K*DecycleOsc[pos]/Pr[pos];
  } 

  pos--;
 }
   
 return(0);
}

