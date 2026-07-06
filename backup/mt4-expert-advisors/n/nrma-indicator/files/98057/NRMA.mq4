//+------------------------------------------------------------------+
//|                                                         NRMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Blue

extern double K=1.;
extern int Smooth=3;
extern double Fast=2.;
extern double Sharp=2.;
extern int Dot_Size=2;

double NRMA[], Up[], Dn[];
double Trend[], NRTR[], Oscil[];
double F;

int init()
{
 IndicatorShortName("NRMA indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,NRMA);
 SetIndexStyle(1,DRAW_ARROW, 0, Dot_Size);
 SetIndexBuffer(1,Up);
 SetIndexArrow(1,119);
 SetIndexStyle(2,DRAW_ARROW, 0, Dot_Size);
 SetIndexBuffer(2,Dn);
 SetIndexArrow(2,119);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Trend);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,NRTR);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Oscil);
 
 F=2./(1.+Fast);

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
 double NRatio;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   if (Close[pos]>Open[pos])
   {
    Trend[pos]=1.;
    NRTR[pos]=Close[pos]*(1.-K/100.);
    Dn[pos]=NRTR[pos];
   }
   else
   {
    Trend[pos]=-1.;
    NRTR[pos]=Close[pos]*(1.+K/100.);
    Up[pos]=NRTR[pos];
   }
  }
  else
  {
   if (Trend[pos+1]>0.)
   {
    if (Close[pos]<NRTR[pos+1])
    {
     Trend[pos]=-1.;
     NRTR[pos]=Close[pos]*(1.+K/100.);
     Up[pos]=NRTR[pos];
    }
    else
    {
     Trend[pos]=1.;
     if (Close[pos]*(1.-K/100.)>NRTR[pos+1])
     {
      NRTR[pos]=Close[pos]*(1.-K/100.);
     }
     else
     {
      NRTR[pos]=NRTR[pos+1];
     }
     Dn[pos]=NRTR[pos];
    }
   }
   else
   {
    if (Close[pos]>NRTR[pos+1])
    {
     Trend[pos]=1.;
     NRTR[pos]=Close[pos]*(1.-K/100.);
     Dn[pos]=NRTR[pos];
    }
    else
    {
     Trend[pos]=-1.;
     if (Close[pos]*(1.+K/100.)<NRTR[pos+1])
     {
      NRTR[pos]=Close[pos]*(1.+K/100.);
     }
     else
     {
      NRTR[pos]=NRTR[pos+1];
     }
     Up[pos]=NRTR[pos];
    }
   }
  } 
  
  Oscil[pos]=100.*MathAbs(Close[pos]-NRTR[pos])/(K*Close[pos]);

  pos--;
 } 
 
 double Avg;
 pos=limit;
 while(pos>=0)
 {
  Avg=iMAOnArray(Oscil, 0, Smooth, 0, MODE_SMA, pos);
  NRatio=MathPow(Avg, Sharp);
  NRMA[pos]=NRMA[pos+1]+NRatio*F*(Close[pos]-NRMA[pos+1]);

  pos--;
 }  
 
 return(0);
}

