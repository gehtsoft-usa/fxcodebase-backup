//+------------------------------------------------------------------+
//|                                                           IT.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
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

double IT[];
double Slope[];

int init()
{
 IndicatorShortName("Instantaneous Trendline");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,IT);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Slope);

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
 double Pr0, PrL;
 double MA;
 double SmoothSlope;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  PrL=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Length-1);
  Slope[pos]=Pr0-PrL;
  MA=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  SmoothSlope=(Slope[pos]+2.*Slope[pos+1]+2.*Slope[pos+2]+Slope[pos+3])/6.;
  IT[pos]=MA+SmoothSlope/2.;
  
  pos--;
 } 
 return(0);
}

