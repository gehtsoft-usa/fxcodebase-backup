//+------------------------------------------------------------------+
//|                                                       GenXMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue

extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Length=50;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
                       

double GenXMA[];
double MA[];
double Alpha;

int init()
  {
   IndicatorShortName("GenXMA indicator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,GenXMA);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,MA);
   Alpha=(2*Length-1)/(Length-1);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMA(NULL, 0, 2*Length, 0, Method, Price, pos);
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  double MA2=iMAOnArray(MA, 0, Length, 0, Method, pos);
  GenXMA[pos]=(1+Alpha)*MA[pos]-Alpha*MA2;
  pos--;
 }

 return(0);
}

