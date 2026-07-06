//+------------------------------------------------------------------+
//|                                                         REMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double REMA[];

double Alpha;
double Lambda;

int init()
{
 IndicatorShortName("Regularized Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,REMA);

 Alpha=2./(Length+1.); 
 Lambda=0.5;
 
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  REMA[pos]=(REMA[pos+1]*(1+2*Lambda)+Alpha*(Pr-REMA[pos+1])-Lambda*REMA[pos+2])/(1+Lambda);
  pos--;
 } 
 
 return(0);
}

