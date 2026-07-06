//+------------------------------------------------------------------+
//|                                         Volatility_Arbitrage.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue

extern int ROC_Length=1;
extern int Length=20;
extern double Multiplier=2.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double ROC[], Top[], Bottom[];

int init()
{
 IndicatorShortName("Volatility Arbitrage");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ROC);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Top);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Bottom);

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
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+ROC_Length);
  if (Pr1!=0.)
  {
   ROC[pos]=100.*(Pr0/Pr1-1.);
  } 

  pos--;
 } 

 double StdDev;
 pos=limit;
 while(pos>=0)
 {
  StdDev=iStdDevOnArray(ROC, 0, Length, 0, MODE_SMA, pos);
  
  Top[pos]=StdDev*Multiplier;
  Bottom[pos]=-1.*Top[pos];

  pos--;
 }

 return(0);
}

