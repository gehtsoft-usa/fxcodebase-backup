//+------------------------------------------------------------------+
//|                                        Better_Bollinger_Band.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red

extern int Length=20;
extern double Deviation=2.;

double Top[], Central[], Bottom[];
double mt[], ut[], mt2[], ut2[];

double Alpha;

int init()
{
 IndicatorShortName("Better bollinger band");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Central);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Bottom);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,mt);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,ut);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,mt2);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,ut2);
 
 Alpha=2./(1.+Length);

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
 double Median;
 double dt2;
 pos=limit;
 while(pos>=0)
 {
  Median=(High[pos]+Low[pos])/2.;
  mt[pos]=Alpha*Median+(1.-Alpha)*mt[pos+1];
  ut[pos]=Alpha*mt[pos]+(1.-Alpha)*ut[pos+1];
  
  Central[pos]=((2.-Alpha)*mt[pos]-ut[pos])/(1.-Alpha);
  
  mt2[pos]=Alpha*MathAbs(Median-Central[pos])+(1.-Alpha)*mt2[pos+1];
  ut2[pos]=Alpha*mt2[pos]+(1.-Alpha)*ut2[pos+1];
  
  dt2=((2.-Alpha)*mt2[pos]-ut2[pos])/(1.-Alpha);
  
  Top[pos]=Central[pos]+Deviation*dt2;
  Bottom[pos]=Central[pos]-Deviation*dt2;

  pos--;
 } 
 return(0);
}

