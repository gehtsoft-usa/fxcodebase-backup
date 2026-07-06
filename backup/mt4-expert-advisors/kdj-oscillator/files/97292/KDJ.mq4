//+------------------------------------------------------------------+
//|                                                          KDJ.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=9;
extern double Factor1=0.666666;
extern double Factor2=0.333333;

double K[], D[], J[];

int init()
{
 IndicatorShortName("KDJ oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,D);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,J);

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
 double Cn, Ln, Hn;
 double RSV;
 pos=limit;
 while(pos>=0)
 {
  Cn=Close[pos];
  Ln=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Hn=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  
  Ln=MathMin(Cn, Ln);
  Hn=MathMax(Cn, Hn);
  
  if (Hn!=Ln)
  {
   RSV=100.*(Cn-Ln)/(Hn-Ln);
  }
  else
  {
   RSV=50.;
  }
  
  K[pos]=Factor1*K[pos+1]+Factor2*RSV;
  D[pos]=Factor1*D[pos+1]+Factor2*K[pos];
  J[pos]=3.*D[pos]-2.*K[pos];

  pos--;
 } 
 return(0);
}

