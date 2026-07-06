//+------------------------------------------------------------------+
//|                                                   LSMA_Angle.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Gray
#property indicator_color2 Blue
#property indicator_color3 Aqua
#property indicator_color4 Pink
#property indicator_color5 DeepPink

extern int Length=25;
extern int Angle_Treshold=15;
extern int Start_Shift=4;
extern int End_Shift=0;

double LSMA_Angle[], PUP[], PDN[], NUP[], NDN[];
double mFactor;

int init()
{
 IndicatorShortName("LSMA angle indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,LSMA_Angle);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,PUP);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,PDN);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,NUP);
 SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexBuffer(4,NDN);
 mFactor=100000./(Start_Shift-End_Shift);

 return(0);
}

int deinit()
{

 return(0);
}

double LSMA(int index, int shift)
{
 int i;
 double sum=0.;
 double tmp;
 double len=(1.+Length)/3.;
 for (i=1;i<=Length;i++)
 {
  tmp=(i-len)*Close[index+shift+Length-i];
  sum=sum+tmp;
 }
 return (6.*sum/(Length*(Length+1.)));
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double fEnd, fStart, fAngle;
 pos=limit;
 while(pos>=0)
 {
  fEnd=LSMA(pos, End_Shift);
  fStart=LSMA(pos, Start_Shift);
  fAngle=mFactor*(fEnd-fStart)/2.;
  LSMA_Angle[pos]=fAngle;
  PUP[pos]=EMPTY_VALUE;
  PDN[pos]=EMPTY_VALUE;
  NUP[pos]=EMPTY_VALUE;
  NDN[pos]=EMPTY_VALUE;
  if (MathAbs(LSMA_Angle[pos])>=Angle_Treshold)
  {
   if (LSMA_Angle[pos]>0.)
   {
    if (LSMA_Angle[pos]>=LSMA_Angle[pos+1])
    {
     PUP[pos]=LSMA_Angle[pos];
    }
    else
    {
     PDN[pos]=LSMA_Angle[pos];
    }
   }
   else
   {
    if (LSMA_Angle[pos]>=LSMA_Angle[pos+1])
    {
     NUP[pos]=LSMA_Angle[pos];
    }
    else
    {
     NDN[pos]=LSMA_Angle[pos];
    }
   }
  }
  pos--;
 } 
 return(0);
}

