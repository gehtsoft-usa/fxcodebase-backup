//+------------------------------------------------------------------+
//|                                         Standard_Error_Bands.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red

extern int Length=21;
extern int Smoothing_Length=3;
extern double Multiplier=2.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Top[], Central[],  Bottom[];
double lreg[], Pr[];

int init()
{
 IndicatorShortName("Standard Error Bands");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Central);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Bottom);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,lreg);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Pr);

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
 double x, y, xy, x2;
 int i;
 double Temp, m, yint;

 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  x=0; y=0; xy=0; x2=0;
  for (i=0;i<Length;i++)
  {
   y=y+Pr[pos+i];
   xy=xy+Pr[pos+i]*i;
   x=x+i;
   x2=x2+i*i;
  }
  Temp=Length*x2-x*x;
  m=(Length*xy-x*y)/Temp;
  yint=(y+m*x)/Length;
  lreg[pos]=yint-m*Length;

  pos--;
 } 
 
 double Deviation;
 pos=limit;
 while(pos>=0)
 {
  Central[pos]=iMAOnArray(lreg, 0, Smoothing_Length, 0, MODE_SMA, pos);
  Deviation=iStdDevOnArray(lreg, 0, Smoothing_Length, 0, MODE_SMA, pos);
  
  Top[pos]=Central[pos]+Multiplier*Deviation;
  Bottom[pos]=Central[pos]-Multiplier*Deviation;

  pos--;
 }
   
 return(0);
}

