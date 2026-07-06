//+------------------------------------------------------------------+
//|                                                          AML.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

extern int Fractal=6;
extern int Lag=7;

double AML[], AML_Up[], AML_Dn[];
double fr[];
double Lag2;

int init()
{
 IndicatorShortName("Adaptive Market Level");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,AML);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,AML_Up);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,AML_Dn);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,fr);
 
 Lag2=Lag*Lag*Point;

 return(0);
}

int deinit()
{

 return(0);
}

double Range(int Len, int index)
{
 double Min, Max;
 Min=Low[iLowest(NULL, 0, MODE_LOW, Len, index)];
 Max=High[iHighest(NULL, 0, MODE_HIGH, Len, index)];
 
 return (Max-Min);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double R1, R2, R3;
 double dim;
 double alpha;
 double price;
 pos=limit;
 while(pos>=0)
 {
  R1=Range(Fractal, pos)/Fractal;
  R2=Range(Fractal, pos+Fractal)/Fractal;
  R3=Range(2*Fractal, pos)/(2.*Fractal);
  
  dim=0.;
  if (R1+R2>0. && R3>0.)
  {
   dim=1.44269504088896*(MathLog(R1+R2)-MathLog(R3));
  }
  alpha=MathExp(-1.*Lag*(dim-1.));
  alpha=MathMin(alpha, 1.);
  alpha=MathMax(alpha, 0.01);
  price=(High[pos]+Low[pos]+2.*Open[pos]+2.*Close[pos])/6.;
  
  fr[pos]=alpha*price+(1.-alpha)*fr[pos+1];

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (MathAbs(fr[pos]-fr[pos+Lag])>=Lag2)
  {
   AML[pos]=fr[pos];
  }
  else
  {
   AML[pos]=AML[pos+1];
  }
  
  if (AML[pos]>AML[pos+1])
  {
   AML_Up[pos]=AML[pos];
   AML_Up[pos+1]=AML[pos+1];
  }
  else
  {
   if (AML[pos]<AML[pos+1])
   {
    AML_Dn[pos]=AML[pos];
    AML_Dn[pos+1]=AML[pos+1];
   }
   else
   {
    AML_Up[pos]=EMPTY_VALUE;
    AML_Dn[pos]=EMPTY_VALUE;
   }
  }

  pos--;
 }
   
 return(0);
}

