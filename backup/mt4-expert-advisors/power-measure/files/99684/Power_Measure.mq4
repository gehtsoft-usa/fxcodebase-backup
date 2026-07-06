//+------------------------------------------------------------------+
//|                                                Power_Measure.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=20;

double PM[];
double CC[], HL[];

int init()
{
 IndicatorShortName("Power measure oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PM);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,CC);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,HL);

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
  CC[pos]=100.*(Close[pos]-Close[pos+1])/Close[pos+1];
  HL[pos]=100.*(High[pos]-Low[pos+1])/Low[pos+1];

  pos--;
 } 
 
 double MA_CC, MA_HL;
 int i;
 double Sum, Sum_CC2, Sum_HL2;
 pos=limit;
 while(pos>=0)
 {
  MA_CC=iMAOnArray(CC, 0, Length, 0, MODE_SMA, pos);
  MA_HL=iMAOnArray(HL, 0, Length, 0, MODE_SMA, pos);
  
  Sum=0.; Sum_CC2=0.; Sum_HL2=0.;
  for (i=0;i<Length;i++)
  {
   Sum=Sum+(CC[pos+i]-MA_CC)*(HL[pos+i]-MA_HL);
   Sum_CC2=Sum_CC2+(CC[pos+i]-MA_CC)*(CC[pos+i]-MA_CC);
   Sum_HL2=Sum_HL2+(HL[pos+i]-MA_HL)*(HL[pos+i]-MA_HL);
  }
  
  if (Sum_CC2!=0. && Sum_HL2!=0.)
  {
   PM[pos]=Sum/MathSqrt(Sum_CC2*Sum_HL2);
  } 

  pos--;
 }
   
 return(0);
}

