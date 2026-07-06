//+------------------------------------------------------------------+
//|                                                          HVC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Red

extern double a=0.2;
extern double b=0.1;
extern double c=0.1;
extern double d=0.1;
extern double Multiplier=1.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double HVMA[], Top[], Bottom[];
double F[], V[], A[], Var[];

int init()
{
 IndicatorShortName("Holt-Winter Channel");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,HVMA);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Top);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Bottom);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,F);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,V);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,A);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Var);

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
 double Pr, Pr1;
 double Stdt;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   F[pos]=0.;
   V[pos]=0.;
   A[pos]=0.;
   Var[pos]=0.;
  }
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  F[pos]=(1.-a)*(F[pos+1]+V[pos+1]+0.5*A[pos+1])+a*Pr;
  V[pos]=(1.-b)*(V[pos+1]+A[pos+1])+b*(F[pos]-F[pos+1]);
  A[pos]=(1.-c)*A[pos+1]+c*(V[pos]-V[pos+1]);
  
  HVMA[pos]=F[pos]+V[pos]+0.5*A[pos];
  
  Var[pos]=(1.-d)*Var[pos+1]+d*(Pr1-HVMA[pos+1])*(Pr1-HVMA[pos+1]);
  Stdt=MathSqrt(Var[pos+1]);
  Top[pos]=HVMA[pos]+Multiplier*Stdt;
  Bottom[pos]=HVMA[pos]-Multiplier*Stdt;

  pos--;
 } 
 return(0);
}

