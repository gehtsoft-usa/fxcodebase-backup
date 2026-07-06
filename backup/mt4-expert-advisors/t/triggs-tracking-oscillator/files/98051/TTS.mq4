//+------------------------------------------------------------------+
//|                                                          TTS.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Green

extern double A=0.5;

double Slow[], Fast[];
double L3[], L6[], L7[], L9[], L10[];
double B;

int init()
{
 IndicatorShortName("Triggs Tracking oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Slow);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Fast);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,L3);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,L6);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,L7);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,L9);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,L10);
 
 B=1.-A;

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
 double L1, L2, L4, L5, L8, L11;
 int period;
 pos=limit;
 while(pos>=0)
 {
  period=Bars-2-pos;
  
  if (period==0)
  {
   L3[pos]=Close[pos];
  }
  
  if (period==1)
  {
   L6[pos]=Close[pos]/40.;
   L9[pos]=Close[pos]/40.;
  }
  
  if (period==2)
  {
   if (L8!=0.)
   {
    L7[pos]=L6[pos]/L8;
   } 
   L8=0.5;
   if (L11!=0.)
   {
    L10[pos]=L9[pos]/L11;
   }
   L11=0.5;
  }
  
  if (period>=1)
  {
   L1=Close[pos]*A;
   L2=L3[pos+1]*B;
   if (period>=2)
   {
    L3[pos]=L1+L2;
   }
   L4=Close[pos]-L3[pos];
   L5=MathAbs(L4);
   if (period>=3)
   {
    L6[pos]=0.1*L4+0.9*L6[pos+1];
   }
   if (period>=4)
   {
    L7[pos]=0.1*L5+0.9*L7[pos+1];
    if (L7[pos]!=0.)
    {
     L8=L6[pos]/L7[pos];
    }
    Slow[pos]=L8; 
   }
   if (period>=3)
   {
    L9[pos]=0.2*L4+0.8*L9[pos+1];
   }
   if (period>=4)
   {
    L10[pos]=0.2*L5+0.8*L10[pos+1];
    if (L10[pos]!=0.)
    {
     L11=L9[pos]/L10[pos];
    }
    Fast[pos]=L11; 
   }
  }

  pos--;
 } 
 return(0);
}

