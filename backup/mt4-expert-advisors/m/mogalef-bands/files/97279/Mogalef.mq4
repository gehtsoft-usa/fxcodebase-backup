//+------------------------------------------------------------------+
//|                                                      Mogalef.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Linear_Regression_Length=3;
extern int Standard_Deviation_Length=7;
extern double Multiplier=2.;

double Top[], Median[], Bottom[];
double Pr[];

int init()
{
 IndicatorShortName("Mogalef");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Median);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Bottom);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Pr);

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
  Pr[pos]=(2.*Close[pos]+Open[pos]+Low[pos]+High[pos])/5.;

  pos--;
 } 

 double x, y, xy, x2;
 int i;
 double Temp, m, yint;
 double StdDev;
 pos=limit;
 while(pos>=0)
 {
  x=0; y=0; xy=0; x2=0;
  for (i=0;i<Linear_Regression_Length;i++)
  {
   y=y+Pr[pos+i];
   xy=xy+Pr[pos+i]*i;
   x=x+i;
   x2=x2+i*i;
  }
  Temp=Linear_Regression_Length*x2-x*x;
  m=(Linear_Regression_Length*xy-x*y)/Temp;
  yint=(y+m*x)/Linear_Regression_Length;
  Median[pos]=yint-m*Linear_Regression_Length;
  
  StdDev=iStdDev(NULL, 0, Standard_Deviation_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  Top[pos]=Median[pos]+Multiplier*StdDev;
  Bottom[pos]=Median[pos]-Multiplier*StdDev;
  
  if (Median[pos]<Top[pos+1] && Median[pos]>Bottom[pos+1])
  {
   Top[pos]=Top[pos+1];
   Median[pos]=Median[pos+1];
   Bottom[pos]=Bottom[pos+1];
  }
  
  pos--;
 } 
 
 return(0);
}

