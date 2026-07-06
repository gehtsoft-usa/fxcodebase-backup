//+------------------------------------------------------------------+
//|                                                           MM.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define Pi 3.1415926

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green

extern int Length=20;
extern double Delta=0.1;
extern double Fract=0.25;

double Mode[], Peak[], Valley[];
double BP[], fPeak[], fValley[];
double fBeta, fGamma, fAlpha;

int init()
{
 IndicatorShortName("Market Mode oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Mode);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Peak);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Valley);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,BP);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,fPeak);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,fValley);
 
 fBeta=MathCos(2.*Pi/(0.+Length));
 fGamma=1./MathCos(4.*Pi*Delta/(0.+Length));
 fAlpha=fGamma-MathSqrt(fGamma*fGamma-1.);

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
  BP[pos]=0.25*(1.-fAlpha)*(High[pos]+Low[pos]-High[pos+2]-Low[pos+2])+fBeta*(1.+fAlpha)*BP[pos+1]-fAlpha*BP[pos+2];
  
  if (BP[pos+1]>BP[pos] && BP[pos+1]>BP[pos+2])
  {
   fPeak[pos]=BP[pos+1];
  }
  else
  {
   fPeak[pos]=fPeak[pos+1];
  }
  
  if (BP[pos+1]<BP[pos] && BP[pos+1]<BP[pos+2])
  {
   fValley[pos]=BP[pos+1];
  }
  else
  {
   fValley[pos]=fValley[pos+1];
  }

  pos--;
 } 
 
 double AvgBP, AvgPeak, AvgValley;
 pos=limit;
 while(pos>=0)
 {
  AvgBP=iMAOnArray(BP, 0, 2*Length+5, 0, MODE_SMA, pos);
  AvgPeak=iMAOnArray(fPeak, 0, 50, 0, MODE_SMA, pos);
  AvgValley=iMAOnArray(fValley, 0, 50, 0, MODE_SMA, pos);
  
  Mode[pos]=AvgBP/Point;
  Peak[pos]=Fract*AvgPeak/Point;
  Valley[pos]=Fract*AvgValley/Point;

  pos--;
 }
   
 return(0);
}

