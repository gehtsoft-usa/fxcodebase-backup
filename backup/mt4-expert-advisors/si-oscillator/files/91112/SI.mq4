//+------------------------------------------------------------------+
//|                                                           SI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=15;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double SI[], SI_Dn[];
double D[];

int init()
{
 IndicatorShortName("SI oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,SI);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,SI_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,D);

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
 double R1, R2, R3, R4, K, R, X;
 pos=limit;
 while(pos>=0)
 {
  R1=MathAbs(High[pos]-Close[pos+1]);
  R2=MathAbs(Low[pos]-Close[pos+1]);
  R3=MathAbs(High[pos]-Low[pos]);
  R4=MathAbs(Close[pos+1]-Open[pos+1]);
  K=MathMax(R1, R2);
  R=0;
  if (R1>=MathMax(R2, R3))
  {
   R=R1-R2/2+R4/4;
  }
  else
  {
   if (R2>=MathMax(R1, R3))
   {
    R=R2-R1/2+R4/4;
   }
   else
   {
    R=R3+R4/4;
   }
  }
  if (R==0)
  {
   D[pos]=0;
  }
  else
  {
   X=0.25*Open[pos]-1.5*Close[pos+1]+0.75*Close[pos]+0.5*Open[pos+1];
   D[pos]=50*X*K/R;
  }
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  SI[pos]=iMAOnArray(D, 0, Length, 0, Method, pos)/Point;
  if (SI[pos]>=SI[pos+1])
  {
   SI_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   SI_Dn[pos]=SI[pos];
  }
  pos--;
 }
   
 return(0);
}

