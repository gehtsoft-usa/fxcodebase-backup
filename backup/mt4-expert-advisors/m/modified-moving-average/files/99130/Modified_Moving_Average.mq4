//+------------------------------------------------------------------+
//|                                      Modified_Moving_Average.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=5;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double MMM[];
double Pr[];

int init()
{
 IndicatorShortName("Modified moving average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MMM);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);

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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 int i;
 double SMA;
 double Slope, Factor;
 pos=limit;
 while(pos>=0)
 {
  Slope=0.;
  for (i=1;i<=Length;i++)
  {
   Factor=1.+2.*(i-1.);
   Slope=Slope+Pr[pos+i-1]*(Length-Factor)/2.;
  }
  SMA=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  
  MMM[pos]=SMA+6.*Slope/(Length*(Length+1.));

  pos--;
 }
   
 return(0);
}

