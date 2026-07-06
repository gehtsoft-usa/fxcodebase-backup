//+------------------------------------------------------------------+
//|                                             Projection_Bands.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Green

extern int Length=14;

double UpBand[], DnBand[];
double H[], L[];

int init()
{
 IndicatorShortName("Projection Bands indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,UpBand);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,DnBand);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,H);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,L);

 return(0);
}

int deinit()
{

 return(0);
}

double lregSlope(double Pr[], int index)
{
 double x, y, xy, x2;
 int i;
 double Temp, m;

 x=0; y=0; xy=0; x2=0;
 for (i=0;i<Length;i++)
 {
  y=y+Pr[index+i];
  xy=xy+Pr[index+i]*i;
  x=x+i;
  x2=x2+i*i;
 }
 Temp=Length*x2-x*x;
 m=(Length*xy-x*y)/Temp;
 
 return (-m);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double SlopeHigh, SlopeLow;
 int i;
 double UpProjBand, DnProjBand;
 pos=limit;
 while(pos>=0)
 {
  H[pos]=High[pos];
  L[pos]=Low[pos];
 
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  SlopeHigh=lregSlope(H, pos);
  SlopeLow=lregSlope(L, pos);
  UpProjBand=High[pos];
  DnProjBand=Low[pos];
  
  for (i=1;i<=Length;i++)
  {
   UpProjBand=MathMax(UpProjBand, High[pos+i]+i*SlopeHigh);
   DnProjBand=MathMin(DnProjBand, Low[pos+i]-i*SlopeLow);
  }
  
  UpBand[pos]=UpProjBand;
  DnBand[pos]=DnProjBand;

  pos--;
 } 
 
 return(0);
}

